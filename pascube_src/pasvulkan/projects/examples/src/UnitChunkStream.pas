unit UnitChunkStream; // Copyright (C) 2006-2017, Benjamin Rosseaux - License: zlib
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
 {$ifdef fpc_little_endian}
  {$define little_endian}
 {$else}
  {$ifdef fpc_big_endian}
   {$define big_endian}
  {$endif}
 {$endif}
 {$ifdef fpc_has_internal_sar}
  {$define HasSAR}
 {$endif}
 {-$pic off}
 {$define caninline}
 {$ifdef FPC_HAS_TYPE_EXTENDED}
  {$define HAS_TYPE_EXTENDED}
 {$else}
  {$undef HAS_TYPE_EXTENDED}
 {$endif}
 {$ifdef FPC_HAS_TYPE_DOUBLE}
  {$define HAS_TYPE_DOUBLE}
 {$else}
  {$undef HAS_TYPE_DOUBLE}
 {$endif}
 {$ifdef FPC_HAS_TYPE_SINGLE}
  {$define HAS_TYPE_SINGLE}
 {$else}
  {$undef HAS_TYPE_SINGLE}
 {$endif}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
 {$realcompatibility off}
 {$localsymbols on}
 {$define little_endian}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$define delphi} 
 {$undef HasSAR}
 {$define UseDIV}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$define HAS_TYPE_SINGLE}
{$endif}
{$ifdef cpu386}
 {$define cpux86}
{$endif}
{$ifdef cpuamd64}
 {$define cpux86}
{$endif}
{$ifdef win32}
 {$define windows}
{$endif}
{$ifdef win64}
 {$define windows}
{$endif}
{$ifdef wince}
 {$define windows}
{$endif}
{$ifdef windows}
 {$define win}
{$endif}
{$ifdef sdl20}
 {$define sdl}
{$endif}
{$rangechecks off}
{$extendedsyntax on}
{$writeableconst on}
{$hints off}
{$booleval off}
{$typedaddress off}
{$stackframes off}
{$varstringchecks on}
{$typeinfo on}
{$overflowchecks off}
{$longstrings on}
{$openstrings on}
{$ifndef HAS_TYPE_DOUBLE}
 {$error No double floating point precision}
{$endif}
{$ifdef fpc}
 {$define caninline}
{$else}
 {$undef caninline}
 {$ifdef ver180}
  {$define caninline}
 {$else}
  {$ifdef conditionalexpressions}
   {$if compilerversion>=18}
    {$define caninline}
   {$ifend}
  {$endif}
 {$endif}
{$endif}

interface

uses SysUtils,Classes;

type PChunkSignature=^TChunkSignature;
     TChunkSignature=array[0..3] of ansichar;

     PChunk=^TChunk;
     TChunk=packed record
      Signature:TChunkSignature;
      Offset:longint;
      Size:longint;
      Reserved:longword;
     end;

     TChunks=array of TChunk;

     EChunkStream=class(Exception);

     TChunkStream=class(TStream)
      private
       fStream:TStream;
       fOffset:int64;
       fSize:int64;
       fPosition:int64;
       fMemory:boolean;
      public
       constructor Create(const AStream:TStream;const AOffset,ASize:int64;const AMemory:boolean=true);
       destructor Destroy; override;
       function Read(var Buffer;Count:longint):longint; override;
       function Write(const Buffer;Count:longint):longint; override;
       function Seek(Offset:longint;Origin:word):longint; override;
       function Seek(const Offset:int64;Origin:TSeekOrigin):int64; override;
       procedure SetSize(NewSize:longint); override;
       procedure SetSize(const NewSize:int64); override;
       function ReadWithCheck(var Buffer;Count:longint):longint;
       function ReadString:ansistring;
       function ReadByte:byte;
       function ReadInt32:longint;
       function ReadUInt32:longword;
       function ReadFloat:single;
     end;

implementation

constructor TChunkStream.Create(const AStream:TStream;const AOffset,ASize:int64;const AMemory:boolean=true);
begin
 inherited Create;
 if (not assigned(AStream)) or ((AOffset<0) or ((AOffset+ASize)>AStream.Size)) then begin
  raise EChunkStream.Create('Stream slice error');
 end;
 fPosition:=0;
 fMemory:=AMemory;
 if fMemory then begin
  fStream:=TMemoryStream.Create;
  fOffset:=0;
  fSize:=ASize;
  if AStream.Seek(AOffset,soBeginning)<>AOffset then begin
   raise EChunkStream.Create('Stream seek error');
  end;
  if fStream.CopyFrom(AStream,ASize)<>ASize then begin
   raise EChunkStream.Create('Stream copy error');
  end;
  if fStream.Seek(0,soBeginning)<>fOffset then begin
   raise EChunkStream.Create('Stream seek error');
  end;
 end else begin
  fStream:=AStream;
  fOffset:=AOffset;
  fSize:=ASize;
 end;
end;

destructor TChunkStream.Destroy;
begin
 if fMemory then begin
  fStream.Free;
 end;
 inherited Destroy;
end;

function TChunkStream.Read(var Buffer;Count:longint):longint;
begin
 if (fPosition+Count)>fSize then begin
  Count:=fSize-fPosition;
 end;
 if Count>0 then begin
  if fStream.Position<>(fOffset+fPosition) then begin
   if fStream.Seek(fOffset+fPosition,soBeginning)<>(fOffset+fPosition) then begin
    raise EChunkStream.Create('Stream seek error');
   end;
  end;
  result:=fStream.Read(Buffer,Count);
  inc(fPosition,result);
 end else begin
  result:=0;
 end;
end;

function TChunkStream.Write(const Buffer;Count:longint):longint;
begin
 if (fPosition+Count)>fSize then begin
  Count:=fSize-fPosition;
 end;
 if Count>0 then begin
  if fStream.Position<>(fOffset+fPosition) then begin
   if fStream.Seek(fOffset+fPosition,soBeginning)<>(fOffset+fPosition) then begin
    raise EChunkStream.Create('Stream seek error');
   end;
  end;
  result:=fStream.Write(Buffer,Count);
  inc(fPosition,result);
 end else begin
  result:=0;
 end;
end;

function TChunkStream.Seek(Offset:longint;Origin:word):longint;
begin
 case Origin of
  soFromBeginning:begin
   fPosition:=Offset;
  end;
  soFromCurrent:begin
   inc(fPosition,Offset);
  end;
  soFromEnd:begin
   fPosition:=fSize+Offset;
  end;
 end;
 if (fPosition<0) or (fPosition>fSize) then begin
  raise EChunkStream.Create('Stream seek error');
 end;
 result:=fPosition;
end;

function TChunkStream.Seek(const Offset:int64;Origin:TSeekOrigin):int64;
begin
 case Origin of
  soBeginning:begin
   fPosition:=Offset;
  end;
  soCurrent:begin
   inc(fPosition,Offset);
  end;
  soEnd:begin
   fPosition:=fSize+Offset;
  end;
 end;
 if (fPosition<0) or (fPosition>fSize) then begin
  raise EChunkStream.Create('Stream seek error');
 end;
 result:=fPosition;
end;

procedure TChunkStream.SetSize(NewSize:longint);
begin
 if fSize<>NewSize then begin
  raise EChunkStream.Create('Stream set size error');
 end;
end;

procedure TChunkStream.SetSize(const NewSize:int64);
begin
 if fSize<>NewSize then begin
  raise EChunkStream.Create('Stream set size error');
 end;
end;

function TChunkStream.ReadWithCheck(var Buffer;Count:longint):longint;
begin
 result:=Read(Buffer,Count);
 if result<>Count then begin
  raise EChunkStream.Create('Stream read error');
 end;
end;

function TChunkStream.ReadString:ansistring;
var Len:longint;
begin
 ReadWithCheck(Len,SizeOf(longint));
 SetLength(result,Len);
 if Len>0 then begin
  ReadWithCheck(result[1],Len*SizeOf(AnsiChar));
 end;
end;

function TChunkStream.ReadByte:byte;
begin
 ReadWithCheck(result,SizeOf(byte));
end;

function TChunkStream.ReadInt32:longint;
begin
 ReadWithCheck(result,SizeOf(longint));
end;

function TChunkStream.ReadUInt32:longword;
begin
 ReadWithCheck(result,SizeOf(longword));
end;

function TChunkStream.ReadFloat:single;
begin
 ReadWithCheck(result,SizeOf(single));
end;

end.
 