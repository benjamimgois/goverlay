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
function InferGameInstallRoot(const AInitialExePath, ASteamInstallPath: string): string;
function ScoreGameExecutableCandidate(const AExePath: string; const AInstallRoot: string = ''): Integer;
function ResolveRealGameExecutable(const AInitialExePath: string; const ASteamInstallPath: string = ''): string;
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
    (Pos('crashhandler', Low) > 0) or
    (Pos('crashpad', Low) > 0) or
    (Pos('bugreport', Low) > 0) or
    (Pos('unitycrashhandler', Low) > 0) or
    (Pos('vc_redist', Low) > 0) or
    (Pos('vcredist', Low) > 0) or
    (Pos('dxsetup', Low) > 0) or
    (Pos('dotnet', Low) > 0) or
    (Pos('ue4prereq', Low) > 0) or
    (Pos('ueprereq', Low) > 0) or
    (Pos('cef_process', Low) > 0) or
    (Pos('cefsubprocess', Low) > 0) or
    (Pos('zfgamebrowser', Low) > 0) or
    (Pos('easyanticheat', Low) > 0) or
    (Pos('beservice', Low) > 0) or
    (Pos('battleye', Low) > 0);
end;

function FileExistsInDirCaseInsensitive(const ADir, ATargetName: string): Boolean;
var
  SR: TSearchRec;
  LowTarget: string;
begin
  Result := False;
  if (ADir = '') or not DirectoryExists(ADir) then Exit;
  if FileExists(IncludeTrailingPathDelimiter(ADir) + ATargetName) then
    Exit(True);
  LowTarget := LowerCase(ATargetName);
  if FindFirst(IncludeTrailingPathDelimiter(ADir) + '*', faAnyFile and not faDirectory, SR) = 0 then
  begin
    try
      repeat
        if LowerCase(SR.Name) = LowTarget then
        begin
          Result := True;
          Break;
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;
end;

function DirectoryExistsCaseInsensitive(const AParentDir, ATargetDirName: string): Boolean;
var
  SR: TSearchRec;
  LowTarget: string;
begin
  Result := False;
  if (AParentDir = '') or not DirectoryExists(AParentDir) then Exit;
  if DirectoryExists(IncludeTrailingPathDelimiter(AParentDir) + ATargetDirName) then
    Exit(True);
  LowTarget := LowerCase(ATargetDirName);
  if FindFirst(IncludeTrailingPathDelimiter(AParentDir) + '*', faDirectory, SR) = 0 then
  begin
    try
      repeat
        if ((SR.Attr and faDirectory) <> 0) and (SR.Name <> '.') and (SR.Name <> '..') then
        begin
          if LowerCase(SR.Name) = LowTarget then
          begin
            Result := True;
            Break;
          end;
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;
end;

function DirHasNativeUpscalerDll(const ADir: string): Boolean;
var
  SR: TSearchRec;
  Low: string;
begin
  Result := False;
  if (ADir = '') or not DirectoryExists(ADir) then Exit;
  if FindFirst(IncludeTrailingPathDelimiter(ADir) + '*.dll', faAnyFile and not faDirectory, SR) = 0 then
  begin
    try
      repeat
        Low := LowerCase(SR.Name);
        if (Low = 'nvngx_dlss.dll') or
           (Low = 'nvngx_dlssd.dll') or
           (Low = 'nvngx_dlssg.dll') or
           (Low = 'libxess.dll') or
           (Low = 'libxess_fg.dll') or
           (Low = 'sl.interposer.dll') or
           (Pos('amd_fidelityfx_', Low) = 1) or
           (Pos('ffx_fsr', Low) = 1) then
        begin
          Result := True;
          Break;
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;
end;

function IsLauncherOrBinSubfolderName(const AFolderName: string): Boolean;
var
  Low: string;
begin
  Low := LowerCase(Trim(AFolderName));
  Result :=
    (Low = 'launcher') or
    (Low = '2klauncher') or
    (Low = 'paradox launcher') or
    (Low = 'boot') or
    (Low = 'bin') or
    (Low = 'binaries') or
    (Low = 'binaries_dx12') or
    (Low = 'x64') or
    (Low = 'x64_dx12') or
    (Low = 'x86') or
    (Low = 'win64') or
    (Low = 'win32') or
    (Low = 'retail') or
    (Low = 'system') or
    (Pos('launcher', Low) > 0);
end;

function InferGameInstallRoot(const AInitialExePath, ASteamInstallPath: string): string;
var
  CurDir, ParentDir, FolderName: string;
  Steps: Integer;
begin
  if (ASteamInstallPath <> '') and DirectoryExists(ASteamInstallPath) then
    Exit(ExcludeTrailingPathDelimiter(ASteamInstallPath));

  if (AInitialExePath <> '') and DirectoryExists(AInitialExePath) then
    CurDir := ExcludeTrailingPathDelimiter(AInitialExePath)
  else
    CurDir := ExcludeTrailingPathDelimiter(ExtractFilePath(AInitialExePath));

  if CurDir = '' then Exit('');

  Steps := 0;
  while Steps < 3 do
  begin
    FolderName := LowerCase(ExtractFileName(CurDir));
    ParentDir := ExcludeTrailingPathDelimiter(ExtractFilePath(CurDir));
    if (ParentDir = '') or (ParentDir = CurDir) then Break;

    if IsLauncherOrBinSubfolderName(FolderName) or
       DirectoryExistsCaseInsensitive(ParentDir, 'Engine') then
    begin
      CurDir := ParentDir;
      Inc(Steps);
    end
    else
      Break;
  end;

  Result := CurDir;
end;

function GetSingleFileSize(const AFilePath: string): Int64;
var
  SR: TSearchRec;
begin
  Result := 0;
  if FindFirst(AFilePath, faAnyFile and not faDirectory, SR) = 0 then
  begin
    Result := SR.Size;
    FindClose(SR);
  end;
end;

function ScoreGameExecutableCandidate(const AExePath: string; const AInstallRoot: string = ''): Integer;
var
  FileName, ExeDir, BaseName, LowName, ParentFolderName, NormPath: string;
  HasUpscaler, HasEngineSig, HasLauncherPenalty: Boolean;
  Api: TDetectedGraphicsApi;
  FileSize: Int64;
begin
  Result := -1000;
  if (AExePath = '') or not FileExists(AExePath) then Exit;

  FileName := ExtractFileName(AExePath);
  if IsIgnoredHelperExe(FileName) then Exit;

  Result := 0;
  ExeDir := IncludeTrailingPathDelimiter(ExtractFilePath(AExePath));
  BaseName := ChangeFileExt(FileName, '');
  LowName := LowerCase(BaseName);
  ParentFolderName := LowerCase(ExtractFileName(ExcludeTrailingPathDelimiter(ExeDir)));
  NormPath := LowerCase(StringReplace(AExePath, '\', '/', [rfReplaceAll]));

  HasLauncherPenalty := False;
  if (Pos('launcher', LowName) > 0) or
     (Pos('prelauncher', LowName) > 0) or
     (Pos('dowser', LowName) > 0) or
     (Pos('patcher', LowName) > 0) or
     (Pos('updater', LowName) > 0) or
     (Pos('setup', LowName) > 0) or
     (Pos('install', LowName) > 0) or
     (LowName = 'boot') or
     (Pos('ffxivboot', LowName) > 0) or
     (Pos('webview', LowName) > 0) or
     (Pos('launcher', ParentFolderName) > 0) or
     (ParentFolderName = 'boot') then
  begin
    Dec(Result, 150);
    HasLauncherPenalty := True;
  end;

  HasUpscaler := DirHasNativeUpscalerDll(ExeDir);
  if HasUpscaler then
    Inc(Result, 120);

  HasEngineSig := False;

  // Unity Engine signature: <ExeBaseName>_Data folder and/or UnityPlayer.dll / GameAssembly.dll
  if DirectoryExistsCaseInsensitive(ExeDir, BaseName + '_Data') then
  begin
    HasEngineSig := True;
    Inc(Result, 100);
  end;
  if FileExistsInDirCaseInsensitive(ExeDir, 'UnityPlayer.dll') or
     FileExistsInDirCaseInsensitive(ExeDir, 'GameAssembly.dll') then
  begin
    HasEngineSig := True;
    Inc(Result, 60);
  end;

  // Unreal Engine Shipping signature
  if (Pos('-shipping', LowName) > 0) or
     (Pos('/binaries/win64/', NormPath) > 0) or
     (Pos('/binaries/win32/', NormPath) > 0) then
  begin
    HasEngineSig := True;
    Inc(Result, 90);
  end
  else if DirectoryExistsCaseInsensitive(ExeDir, 'Engine') then
  begin
    // Root-level Unreal Engine bootstrapper sitting beside Engine/ directory
    Dec(Result, 40);
  end;

  // Common game binary directory bonus
  if (ParentFolderName = 'bin') or
     (ParentFolderName = 'x64') or
     (ParentFolderName = 'x86_64') or
     (ParentFolderName = 'x64_dx12') or
     (ParentFolderName = 'binaries') or
     (ParentFolderName = 'binaries_dx12') or
     (ParentFolderName = 'win64') or
     (ParentFolderName = 'retail') or
     (ParentFolderName = 'game') then
    Inc(Result, 25);

  if (Pos('dx12', ParentFolderName) > 0) or (Pos('dx12', LowName) > 0) then
    Inc(Result, 15);

  // Store / DRM / Middleware DLLs in the same directory
  if FileExistsInDirCaseInsensitive(ExeDir, 'steam_api64.dll') or
     FileExistsInDirCaseInsensitive(ExeDir, 'steam_api.dll') or
     FileExistsInDirCaseInsensitive(ExeDir, 'EOSSDK-Win64-Shipping.dll') or
     FileExistsInDirCaseInsensitive(ExeDir, 'galaxy64.dll') or
     FileExistsInDirCaseInsensitive(ExeDir, 'bink2w64.dll') then
    Inc(Result, 30);

  // CEF / Electron / Qt UI Launcher signature
  if (not HasUpscaler) and (not HasEngineSig) and
     (FileExistsInDirCaseInsensitive(ExeDir, 'libcef.dll') or
      FileExistsInDirCaseInsensitive(ExeDir, 'chrome_elf.dll') or
      FileExistsInDirCaseInsensitive(ExeDir, 'Qt5Core.dll') or
      FileExistsInDirCaseInsensitive(ExeDir, 'Qt6Core.dll')) then
  begin
    Dec(Result, 100);
    HasLauncherPenalty := True;
  end;

  // PE Import Table 3D Graphics API
  Api := DetectPEGraphicsApi(AExePath);
  case Api of
    gapiDX12:   Inc(Result, 55);
    gapiDX11:   Inc(Result, 40);
    gapiDX9,
    gapiOpenGL: Inc(Result, 30);
  end;

  // File size bonus
  FileSize := GetSingleFileSize(AExePath);
  if FileSize >= 20 * 1024 * 1024 then
    Inc(Result, 20)
  else if FileSize >= 5 * 1024 * 1024 then
    Inc(Result, 10)
  else if (FileSize > 0) and (not HasLauncherPenalty) then
    Inc(Result, 5);
end;

function ShouldSkipCandidateScanDir(const ADirName: string): Boolean;
var
  Low: string;
begin
  Low := LowerCase(ADirName);
  Result :=
    (Low = '.') or
    (Low = '..') or
    (Low = '_commonredist') or
    (Low = 'directx') or
    (Low = 'vc') or
    (Low = 'vcredist') or
    (Low = 'dotnet') or
    (Low = 'mono') or
    (Low = 'monobleedingedge') or
    (Low = 'crashreportclient') or
    (Low = 'bugreportclient') or
    (Low = 'shadercache') or
    (Low = 'shaders') or
    (Low = 'plugins') or
    (Low = 'mods') or
    (Low = 'content') or
    (Low = 'paks') or
    (Low = 'cooked') or
    (Low = 'movies') or
    (Low = 'audio') or
    (Low = 'sound') or
    (Low = 'music') or
    (Low = 'logs') or
    ((Length(Low) > 5) and (Copy(Low, Length(Low) - 4, 5) = '_data'));
end;

procedure ScanTreeForBestExe(const ADir, AInstallRoot: string; ADepth, AMaxDepth: Integer;
  var BestPath: string; var BestScore: Integer; var BestSize: Int64);
var
  SR: TSearchRec;
  FullPath: string;
  CandScore: Integer;
  CandSize: Int64;
begin
  if (ADepth > AMaxDepth) or (ADir = '') or not DirectoryExists(ADir) then Exit;

  if FindFirst(IncludeTrailingPathDelimiter(ADir) + '*.exe', faAnyFile and not faDirectory, SR) = 0 then
  begin
    try
      repeat
        if not IsIgnoredHelperExe(SR.Name) then
        begin
          FullPath := IncludeTrailingPathDelimiter(ADir) + SR.Name;
          CandScore := ScoreGameExecutableCandidate(FullPath, AInstallRoot);
          CandSize := SR.Size;
          if (CandScore > BestScore) or
             ((CandScore = BestScore) and (CandSize > BestSize)) then
          begin
            BestScore := CandScore;
            BestSize := CandSize;
            BestPath := FullPath;
          end;
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;

  if ADepth >= AMaxDepth then Exit;

  if FindFirst(IncludeTrailingPathDelimiter(ADir) + '*', faDirectory, SR) = 0 then
  begin
    try
      repeat
        if ((SR.Attr and faDirectory) <> 0) and not ShouldSkipCandidateScanDir(SR.Name) then
        begin
          ScanTreeForBestExe(IncludeTrailingPathDelimiter(ADir) + SR.Name,
            AInstallRoot, ADepth + 1, AMaxDepth, BestPath, BestScore, BestSize);
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;
end;

function ResolveRealGameExecutable(const AInitialExePath: string; const ASteamInstallPath: string = ''): string;
var
  InstallRoot, BestPath: string;
  InitialScore, BestScore: Integer;
  BestSize: Int64;
begin
  Result := AInitialExePath;
  InstallRoot := InferGameInstallRoot(AInitialExePath, ASteamInstallPath);
  if (InstallRoot = '') or not DirectoryExists(InstallRoot) then
    Exit;

  InitialScore := -1000;
  if (AInitialExePath <> '') and FileExists(AInitialExePath) then
    InitialScore := ScoreGameExecutableCandidate(AInitialExePath, InstallRoot);

  BestPath := '';
  BestScore := -1000;
  BestSize := -1;
  ScanTreeForBestExe(InstallRoot, InstallRoot, 0, 4, BestPath, BestScore, BestSize);

  if (BestPath <> '') and (BestScore > 0) then
  begin
    if (InitialScore < 0) or (AInitialExePath = '') or not FileExists(AInitialExePath) then
      Result := BestPath
    else if (BestScore >= InitialScore + 30) then
      Result := BestPath;
  end;
end;

function FindMainGameExecutable(const AGameDir: string): string;
var
  BestScore: Integer;
  BestSize: Int64;
begin
  Result := '';
  if (AGameDir = '') or not DirectoryExists(AGameDir) then Exit;
  BestScore := -1000;
  BestSize := -1;
  ScanTreeForBestExe(ExcludeTrailingPathDelimiter(AGameDir),
    ExcludeTrailingPathDelimiter(AGameDir), 0, 4, Result, BestScore, BestSize);
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
