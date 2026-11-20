unit pe_utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TDetectedGraphicsApi = (
    gapiUnknown,
    gapiDX9,
    gapiDX11,
    gapiDX12,
    gapiOpenGL
  );

function DetectPEGraphicsApi(const AExePath: string): TDetectedGraphicsApi;
function FindMainGameExecutable(const AGameDir: string): string;
function RecommendedProxyForApi(AApi: TDetectedGraphicsApi): string;
function GraphicsApiDisplayName(AApi: TDetectedGraphicsApi): string;

implementation

type
  TSectionRange = record
    VirtualAddress: LongWord;
    SpanSize: LongWord;
    PointerToRawData: LongWord;
  end;

function RvaToFileOffset(ARva: LongWord; const ASections: array of TSectionRange;
  AStreamSize: Int64; out AOffset: Int64): Boolean;
var
  i: Integer;
  StartVA, EndVA: Int64;
begin
  Result := False;
  for i := 0 to High(ASections) do
  begin
    StartVA := Int64(ASections[i].VirtualAddress);
    EndVA := StartVA + Int64(ASections[i].SpanSize);
    if (Int64(ARva) >= StartVA) and (Int64(ARva) < EndVA) then
    begin
      AOffset := Int64(ASections[i].PointerToRawData) + (Int64(ARva) - StartVA);
      if (AOffset >= 0) and (AOffset < AStreamSize) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function ReadNullTerminatedAscii(AStream: TStream; AOffset: Int64): string;
var
  Buf: array[0..255] of Byte;
  BytesRead, i: Integer;
begin
  Result := '';
  if (AOffset < 0) or (AOffset >= AStream.Size) then Exit;
  AStream.Position := AOffset;
  BytesRead := AStream.Read(Buf, SizeOf(Buf));
  for i := 0 to BytesRead - 1 do
  begin
    if Buf[i] = 0 then
    begin
      SetString(Result, PAnsiChar(@Buf[0]), i);
      Exit;
    end;
  end;
  if BytesRead > 0 then
    SetString(Result, PAnsiChar(@Buf[0]), BytesRead);
end;

function DetectPEGraphicsApi(const AExePath: string): TDetectedGraphicsApi;
var
  Stream: TFileStream;
  PeOffset, ImportRVA: LongWord;
  OptOffset, DataDirOffset, SecTableOffset, CurOffset, NameOffset: Int64;
  Sig: array[0..3] of Byte;
  NumSections, OptHeaderSize, Magic: Word;
  SecRaw: array[0..39] of Byte;
  ImpRaw: array[0..19] of Byte;
  Sections: array of TSectionRange;
  VSize, VAddr, RSize, RPtr, OriginalFirstThunk, NameRVA, FirstThunk: LongWord;
  i, Count: Integer;
  DllName: string;
  HasD3D9, HasD3D11, HasD3D12, HasDXGI, HasOpenGL: Boolean;
begin
  Result := gapiUnknown;
  if (AExePath = '') or not FileExists(AExePath) then Exit;

  HasD3D9 := False;
  HasD3D11 := False;
  HasD3D12 := False;
  HasDXGI := False;
  HasOpenGL := False;

  try
    Stream := TFileStream.Create(AExePath, fmOpenRead or fmShareDenyNone);
    try
      if Stream.Size < $40 then Exit;
      Stream.Position := $3C;
      if Stream.Read(PeOffset, SizeOf(PeOffset)) <> SizeOf(PeOffset) then Exit;
      PeOffset := LEtoN(PeOffset);

      if Int64(PeOffset) + 24 > Stream.Size then Exit;
      Stream.Position := PeOffset;
      if Stream.Read(Sig, SizeOf(Sig)) <> SizeOf(Sig) then Exit;
      if (Sig[0] <> $50) or (Sig[1] <> $45) or (Sig[2] <> 0) or (Sig[3] <> 0) then Exit;

      Stream.Position := Int64(PeOffset) + 6;
      if Stream.Read(NumSections, SizeOf(NumSections)) <> SizeOf(NumSections) then Exit;
      NumSections := LEtoN(NumSections);
      if (NumSections = 0) or (NumSections > 256) then Exit;

      Stream.Position := Int64(PeOffset) + 20;
      if Stream.Read(OptHeaderSize, SizeOf(OptHeaderSize)) <> SizeOf(OptHeaderSize) then Exit;
      OptHeaderSize := LEtoN(OptHeaderSize);

      OptOffset := Int64(PeOffset) + 24;
      if OptOffset + Int64(OptHeaderSize) > Stream.Size then Exit;
      if OptHeaderSize < 2 then Exit;

      Stream.Position := OptOffset;
      if Stream.Read(Magic, SizeOf(Magic)) <> SizeOf(Magic) then Exit;
      Magic := LEtoN(Magic);

      if Magic = $010B then
        DataDirOffset := OptOffset + 96   // PE32
      else if Magic = $020B then
        DataDirOffset := OptOffset + 112  // PE32+
      else
        Exit;

      // Ensure at least DataDirectory[0..1] (Export + Import) fit inside OptionalHeader
      if (DataDirOffset - OptOffset) + 16 > Int64(OptHeaderSize) then Exit;
      if DataDirOffset + 16 > Stream.Size then Exit;

      Stream.Position := DataDirOffset + 8;
      if Stream.Read(ImportRVA, SizeOf(ImportRVA)) <> SizeOf(ImportRVA) then Exit;
      ImportRVA := LEtoN(ImportRVA);
      if ImportRVA = 0 then Exit;

      SecTableOffset := OptOffset + Int64(OptHeaderSize);
      if SecTableOffset + Int64(NumSections) * 40 > Stream.Size then Exit;

      SetLength(Sections, NumSections);
      Stream.Position := SecTableOffset;
      for i := 0 to NumSections - 1 do
      begin
        if Stream.Read(SecRaw, SizeOf(SecRaw)) <> SizeOf(SecRaw) then Exit;
        Move(SecRaw[8], VSize, 4);
        Move(SecRaw[12], VAddr, 4);
        Move(SecRaw[16], RSize, 4);
        Move(SecRaw[20], RPtr, 4);
        VSize := LEtoN(VSize);
        VAddr := LEtoN(VAddr);
        RSize := LEtoN(RSize);
        RPtr := LEtoN(RPtr);

        Sections[i].VirtualAddress := VAddr;
        if VSize > RSize then
          Sections[i].SpanSize := VSize
        else
          Sections[i].SpanSize := RSize;
        Sections[i].PointerToRawData := RPtr;
      end;

      if not RvaToFileOffset(ImportRVA, Sections, Stream.Size, CurOffset) then Exit;

      Count := 0;
      while (CurOffset + 20 <= Stream.Size) and (Count < 512) do
      begin
        Inc(Count);
        Stream.Position := CurOffset;
        if Stream.Read(ImpRaw, SizeOf(ImpRaw)) <> SizeOf(ImpRaw) then Break;
        Move(ImpRaw[0], OriginalFirstThunk, 4);
        Move(ImpRaw[12], NameRVA, 4);
        Move(ImpRaw[16], FirstThunk, 4);
        OriginalFirstThunk := LEtoN(OriginalFirstThunk);
        NameRVA := LEtoN(NameRVA);
        FirstThunk := LEtoN(FirstThunk);

        if (OriginalFirstThunk = 0) and (NameRVA = 0) and (FirstThunk = 0) then Break;
        if NameRVA = 0 then
        begin
          Inc(CurOffset, 20);
          Continue;
        end;

        if RvaToFileOffset(NameRVA, Sections, Stream.Size, NameOffset) then
        begin
          DllName := LowerCase(ExtractFileName(ReadNullTerminatedAscii(Stream, NameOffset)));
          if DllName = 'd3d9.dll' then
            HasD3D9 := True
          else if DllName = 'd3d11.dll' then
            HasD3D11 := True
          else if DllName = 'd3d12.dll' then
            HasD3D12 := True
          else if DllName = 'dxgi.dll' then
            HasDXGI := True
          else if DllName = 'opengl32.dll' then
            HasOpenGL := True;
        end;

        Inc(CurOffset, 20);
      end;
    finally
      Stream.Free;
    end;
  except
    Exit(gapiUnknown);
  end;

  if HasD3D12 then
    Result := gapiDX12
  else if HasD3D11 or HasDXGI then
    Result := gapiDX11
  else if HasD3D9 then
    Result := gapiDX9
  else if HasOpenGL then
    Result := gapiOpenGL;
end;

function IsIgnoredHelperExe(const AFileName: string): Boolean;
var
  Low: string;
begin
  Low := LowerCase(AFileName);
  Result :=
    (Pos('unins', Low) = 1) or
    (Pos('crashreport', Low) > 0) or
    (Pos('unitycrashhandler', Low) > 0) or
    (Pos('vc_redist', Low) > 0) or
    (Pos('vcredist', Low) > 0) or
    (Pos('dxsetup', Low) > 0) or
    (Pos('dotnet', Low) > 0) or
    (Pos('ue4prereq', Low) > 0) or
    (Pos('ueprereq', Low) > 0);
end;

procedure ScanDirForLargestExe(const ADir: string; var BestPath: string; var BestSize: Int64);
var
  SR: TSearchRec;
  FullPath: string;
begin
  if not DirectoryExists(ADir) then Exit;
  if FindFirst(IncludeTrailingPathDelimiter(ADir) + '*.exe', faAnyFile and not faDirectory, SR) = 0 then
  begin
    try
      repeat
        if not IsIgnoredHelperExe(SR.Name) then
        begin
          FullPath := IncludeTrailingPathDelimiter(ADir) + SR.Name;
          if SR.Size > BestSize then
          begin
            BestSize := SR.Size;
            BestPath := FullPath;
          end;
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;
end;

function FindMainGameExecutable(const AGameDir: string): string;
const
  SubDirs: array[0..5] of string = (
    'System',
    'bin',
    'x64',
    'x86',
    'Binaries/Win64',
    'Binaries/Win32'
  );
var
  BaseDir: string;
  BestSize: Int64;
  i: Integer;
begin
  Result := '';
  if (AGameDir = '') or not DirectoryExists(AGameDir) then Exit;
  BaseDir := IncludeTrailingPathDelimiter(AGameDir);
  BestSize := -1;

  ScanDirForLargestExe(BaseDir, Result, BestSize);
  if Result <> '' then Exit;

  for i := 0 to High(SubDirs) do
    ScanDirForLargestExe(BaseDir + SubDirs[i], Result, BestSize);
end;

function RecommendedProxyForApi(AApi: TDetectedGraphicsApi): string;
begin
  case AApi of
    gapiDX9:    Result := 'd3d9.dll';
    gapiDX11:   Result := 'dxgi.dll';
    gapiDX12:   Result := 'dxgi.dll';
    gapiOpenGL: Result := 'opengl32.dll';
  else
    Result := '';
  end;
end;

function GraphicsApiDisplayName(AApi: TDetectedGraphicsApi): string;
begin
  case AApi of
    gapiDX9:    Result := 'DirectX 9';
    gapiDX11:   Result := 'DirectX 11';
    gapiDX12:   Result := 'DirectX 12';
    gapiOpenGL: Result := 'OpenGL';
  else
    Result := '';
  end;
end;

end.
