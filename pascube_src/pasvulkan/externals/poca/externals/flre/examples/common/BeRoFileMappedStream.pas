(******************************************************************************
 *                             BeRoFileMappedStream                           *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (c) 2015, Benjamin Rosseaux (benjamin@rosseaux.de)               *
 *                                                                            *
 * This software is provided 'as-is', without any express or implied          *
 * warranty. In no event will the authors be held liable for any damages      *
 * arising from the use of this software.                                     *
 *                                                                            *
 * Permission is granted to anyone to use this software for any purpose,      *
 * including commercial applications, and to alter it and redistribute it     *
 * freely, subject to the following restrictions:                             *
 *                                                                            *
 * 1. The origin of this software must not be misrepresented; you must not    *
 *    claim that you wrote the original software. If you use this software    *
 *    in a product, an acknowledgement in the product documentation would be  *
 *    appreciated but is not required.                                        *
 * 2. Altered source versions must be plainly marked as such, and must not be *
 *    misrepresented as being the original software.                          *
 * 3. This notice may not be removed or altered from any source distribution. *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the zlib *
 *    license.                                                                *
 * 2. The zlib license header goes at the top of each source file, with       *
 *    appropriate copyright notice.                                           *
 * 3. Write code, which is compatible with Delphi 7-XE7 and FreePascal >= 2.6 *
 *    so don't use generics/templates, operator overloading and another newer *
 *    syntax features than Delphi 7 has support for that.                     *
 * 4. Don't use Delphi VCL, FreePascal FCL or Lazarus LCL libraries/units.    *
 * 5. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able                                                       *
 * 6. Try to use const when possible.                                         *
 * 7. Make sure to comment out writeln, used while debugging                  *
 * 8. Make sure the code compiles on 32-bit and 64-bit platforms              *
 *                                                                            *
 ******************************************************************************)
unit BeRoFileMappedStream;
{$ifdef fpc}
 {$mode delphi}
 {$warnings off}
 {$hints off}
 {$define caninline}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpuamd64}
  {$define cpux86_64}
  {$define cpux64}
 {$else}
  {$ifdef cpux86_64}
   {$define cpuamd64}
   {$define cpux64}
  {$endif}
 {$endif}
 {$ifdef cpu386}
  {$define cpu386}
  {$asmmode intel}
  {$define canx86simd}
 {$endif}
 {$ifdef FPC_LITTLE_ENDIAN}
  {$define LITTLE_ENDIAN}
 {$else}
  {$ifdef FPC_BIG_ENDIAN}
   {$define BIG_ENDIAN}
  {$endif}
 {$endif}
{$else}
 {$define LITTLE_ENDIAN}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$safedivide off}
 {$optimization on}
 {$undef caninline}
 {$undef canx86simd}
 {$ifdef ver180}
  {$define caninline}
  {$ifdef cpu386}
   {$define canx86simd}
  {$endif}
  {$finitefloat off}
 {$endif}
{$endif}
{$ifdef win32}
 {$define windows}
{$endif}
{$ifdef win64}
 {$define windows}
{$endif}
{$extendedsyntax on}
{$writeableconst on}
{$varstringchecks on}
{$typedaddress off}
{$overflowchecks off}
{$rangechecks off}
{$ifndef fpc}
{$realcompatibility off}
{$endif}
{$openstrings on}
{$longstrings on}
{$booleval off}

interface

uses {$ifdef unix}BaseUnix,Unix,UnixType,UnixUtil,{$else}Windows,{$endif}SysUtils,Classes;

const fmCreateTemporary=4;

{$ifndef fpc}
      feInvalidHandle=longint(-1);
{$endif}

      DefaultViewSize=64 shl 20; // 64MB

type TBeRoFileMappedStream=class(TStream)
      private
       fFileHandle:{$ifdef unix}longint{$else}hFile{$endif};
{$ifndef unix}
       fMapHandle:{$ifdef unix}pointer{$else}THandle{$endif};
{$endif}
       fAllocationGranularity:int64;
       fMemory:pointer;
       fReadOnly:boolean;
       fCurrentViewOffset:int64;
       fCurrentViewSize:int64;
       fViewSize:int64;
       fViewMask:int64;
       fPosition:int64;
       fSize:int64;
       fFileName:string;
{$ifdef unix}
       FTemporary:boolean;
{$endif}
       procedure CreateMapView;
       procedure UpdateMapView;
       procedure CloseMapView;
      protected
       procedure SetSize(NewSize:longint); overload; override;
       procedure SetSize(const NewSize:int64); overload; override;
      public
       constructor Create(const FileName:string;Mode:Word);
       destructor Destroy; override;
       procedure Clear;
       procedure Flush;
       function Read(var Buffer;Count:longint):longint; override;
       function Write(const Buffer;Count:longint):longint; override;
       function Seek(const Offset:int64;Origin:TSeekOrigin):int64; override;
       property Memory:pointer read fMemory;
       property MemoryViewOffset:int64 read fCurrentViewOffset;
       property MemoryViewSize:int64 read fCurrentViewSize;
       property ReadOnly:boolean read fReadOnly;
     end;

implementation

{$ifdef fpc}
 {$undef OldDelphi}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=23.0}
   {$undef OldDelphi}
type qword=uint64;
     ptruint=NativeUInt;
     ptrint=NativeInt;
  {$else}
   {$define OldDelphi}
  {$ifend}
 {$else}
  {$define OldDelphi}
 {$endif}
{$endif}
{$ifdef OldDelphi}
type qword=int64;
{$ifdef cpu64}
     ptruint=qword;
     ptrint=int64;
{$else}
     ptruint=longword;
     ptrint=longint;
{$endif}
{$endif}

constructor TBeRoFileMappedStream.Create(const FileName:string;Mode:Word);
{$ifdef unix}
const Access:array[0..4] of longword=(O_RdOnly,O_WrOnly,O_RdWr,O_RdWr,O_RdWr);
      CreateFlag:array[0..4] of longword=(0,0,0,O_Creat,O_Creat);
var StatInfo:BaseUnix.Stat;
    ModeEx:longword;
begin
 inherited Create;
 fAllocationGranularity:=65556;
 fFileName:=FileName;
 ModeEx:=Mode and not (fmShareExclusive or fmShareExclusive or fmShareDenyRead or fmShareDenyWrite or fmShareDenyNone);
 fCurrentViewOffset:=0;
 fCurrentViewSize:=0;
 fViewSize:=DefaultViewSize;
 fViewMask:=fViewSize-1;
 fReadOnly:=ModeEx=0;
 FTemporary:=ModeEx=fmCreateTemporary;
 if Mode=fmCreate then begin
  ModeEx:=3;
 end;
 fFileHandle:=fpOpen(PChar(fFileName),Access[ModeEx] or CreateFlag[ModeEx]);
 if fFileHandle<>feInvalidHandle then begin
  if fpfstat(fFileHandle,StatInfo)<>0 then begin
   raise Exception.Create('Cann''t access file');
  end;
  fSize:=StatInfo.st_size;
  if fSize<1 then begin
   FpLseek(fFileHandle,1,Seek_Set);
   fSize:=1;
  end;
  CreateMapView;
 end else begin
  raise Exception.Create('Can''t access file');
 end;
end;
{$else}
const Access:array[0..4] of longword=(GENERIC_READ,GENERIC_WRITE,GENERIC_READ or GENERIC_WRITE,GENERIC_READ or GENERIC_WRITE,GENERIC_READ or GENERIC_WRITE);
      CreateFlag:array[0..4] of longword=(OPEN_EXISTING,OPEN_EXISTING,OPEN_EXISTING,CREATE_ALWAYS,CREATE_ALWAYS);
var ModeEx,FileFlags,ShareFlags:longword;
    SystemInfo:TSystemInfo;
begin
 inherited Create;
 GetSystemInfo(SystemInfo);
 fAllocationGranularity:=SystemInfo.dwAllocationGranularity;
 fFileName:=FileName;
 ModeEx:=Mode and not (fmShareExclusive or fmShareExclusive or fmShareDenyRead or fmShareDenyWrite or fmShareDenyNone);
 fCurrentViewOffset:=0;
 fCurrentViewSize:=0;
 fViewSize:=DefaultViewSize;
 fViewMask:=fViewSize-1;
 fReadOnly:=ModeEx=0;
 if Mode=fmCreate then begin
  ModeEx:=3;
 end;
 if ModeEx<>4 then begin
  FileFlags:=FILE_ATTRIBUTE_NORMAL;
 end else begin
  FileFlags:=FILE_FLAG_DELETE_ON_CLOSE;
 end;
 ShareFlags:=FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE;
 if (Mode and fmShareDenyNone)=0 then begin
  if (Mode and fmShareExclusive)<>0 then begin
   ShareFlags:=0;
  end else begin
   if (Mode and fmShareDenyRead)<>0 then begin
    ShareFlags:=ShareFlags and not FILE_SHARE_READ;
   end;
   if (Mode and fmShareDenyWrite)<>0 then begin
    ShareFlags:=ShareFlags and not (FILE_SHARE_WRITE or FILE_SHARE_DELETE);
   end;
  end;
 end;
 fFileHandle:=CreateFile(PChar(fFileName),Access[ModeEx],ShareFlags,nil,CreateFlag[ModeEx],FileFlags,0);
 if fFileHandle<>INVALID_HANDLE_VALUE then begin
  fSize:=GetFileSize(fFileHandle,nil);
  if fSize<1 then begin
   SetFilePointer(fFileHandle,1,nil,FILE_BEGIN);
   SetEndOfFile(fFileHandle);
   fSize:=1;
  end;
  CreateMapView;
 end else begin
  raise Exception.Create(SysErrorMessage(GetLastError));
 end;
end;
{$endif}

destructor TBeRoFileMappedStream.Destroy;
begin
 CloseMapView;
{$ifdef unix}
 if fFileHandle<>feInvalidHandle then begin
  fpclose(fFileHandle);
  fFileHandle:=feInvalidHandle;
 end;
 if FTemporary then begin
  FpUnlink(fFileName);
 end;
{$else}
 if fFileHandle<>INVALID_HANDLE_VALUE then begin
  CloseHandle(fFileHandle);
  fFileHandle:=INVALID_HANDLE_VALUE;
 end;
{$endif}
 inherited Destroy;
end;

procedure TBeRoFileMappedStream.CreateMapView;
{$ifdef unix}
var StatInfo:BaseUnix.Stat;
begin
 if fpfstat(fFileHandle,StatInfo)<>0 then begin
  CloseMapView;
  raise Exception.Create('Cannot create map view.');
  exit;
 end;
 fSize:=StatInfo.st_size;
 if fSize=0 then begin
  CloseMapView;
  raise Exception.Create('Cannot create map view.');
  exit;
 end;
 fCurrentViewSize:=fViewSize;
 if (fCurrentViewOffset+fCurrentViewSize)>fSize then begin
  fCurrentViewSize:=fSize-fCurrentViewOffset;
 end;
 if ReadOnly then begin
  fMemory:=fpmmap(nil,fCurrentViewSize,PROT_READ,MAP_PRIVATE,fFileHandle,fCurrentViewOffset);
 end else begin
  fMemory:=fpmmap(nil,fCurrentViewSize,PROT_READ or PROT_WRITE,MAP_SHARED,fFileHandle,fCurrentViewOffset);
 end;
 if ptruint(fMemory)=ptruint(ptrint(-1)) then begin
  fMemory:=nil;
  CloseMapView;
  raise Exception.Create('Cannot create map view.');
 end;
end;
{$else}
begin
 if ReadOnly then begin
  fMapHandle:=CreateFileMapping(fFileHandle,nil,PAGE_READONLY,0,fSize,nil);
 end else begin
  fMapHandle:=CreateFileMapping(fFileHandle,nil,PAGE_READWRITE,0,fSize,nil);
 end;
 if fMapHandle=0 then begin
  raise Exception.Create(SysErrorMessage(GetLastError));
 end;
 fCurrentViewSize:=fViewSize;
 if (fCurrentViewOffset+fCurrentViewSize)>fSize then begin
  fCurrentViewSize:=fSize-fCurrentViewOffset;
 end;
 if ReadOnly then begin
  fMemory:=MapViewOfFile(fMapHandle,FILE_MAP_READ,longword(fCurrentViewOffset shr 32),longword(fCurrentViewOffset),fCurrentViewSize);
 end else begin
  fMemory:=MapViewOfFile(fMapHandle,FILE_MAP_READ or FILE_MAP_WRITE,longword(fCurrentViewOffset shr 32),longword(fCurrentViewOffset),fCurrentViewSize);
 end;
 if not assigned(fMemory) then begin
  raise Exception.Create(SysErrorMessage(GetLastError));
 end;
end;
{$endif}

procedure TBeRoFileMappedStream.UpdateMapView;
begin
 if (fPosition<fCurrentViewOffset) or ((fCurrentViewOffset+fCurrentViewSize)<fPosition) then begin
  if (fAllocationGranularity and (fAllocationGranularity-1))<>0 then begin
   fCurrentViewOffset:=fPosition;
   if (fCurrentViewOffset mod fAllocationGranularity)<>0 then begin
    dec(fCurrentViewOffset,fCurrentViewOffset mod fAllocationGranularity);
   end;
   fCurrentViewSize:=fViewSize;
   if (fCurrentViewSize mod fAllocationGranularity)<>0 then begin
    inc(fCurrentViewSize,fAllocationGranularity-(fCurrentViewOffset mod fAllocationGranularity));
   end;
  end else begin
   fCurrentViewOffset:=fPosition and not (fAllocationGranularity-1);
   fCurrentViewSize:=(fViewSize+(fAllocationGranularity-1)) and not (fAllocationGranularity-1);
  end;
  if fCurrentViewOffset<0 then begin
   fCurrentViewOffset:=0;
  end;
  if (fCurrentViewOffset+fCurrentViewSize)>fSize then begin
   fCurrentViewSize:=fSize-fCurrentViewOffset;
  end;
{$ifdef unix}
  if assigned(fMemory) then begin
   fpmunmap(fMemory,fCurrentViewSize);
   fMemory:=nil;
  end;
  if ReadOnly then begin
   fMemory:=fpmmap(nil,fCurrentViewSize,PROT_READ,MAP_PRIVATE,fFileHandle,fCurrentViewOffset);
  end else begin
   fMemory:=fpmmap(nil,fCurrentViewSize,PROT_READ or PROT_WRITE,MAP_SHARED,fFileHandle,fCurrentViewOffset);
  end;
  if ptruint(fMemory)=ptruint(ptrint(-1)) then begin
   fMemory:=nil;
   CloseMapView;
   raise Exception.Create('Cannot create map view.');
  end;
{$else}
  if assigned(fMemory) then begin
   UnmapViewOfFile(fMemory);
   fMemory:=nil;
  end;
  if ReadOnly then begin
   fMemory:=MapViewOfFile(fMapHandle,FILE_MAP_READ,longword(fCurrentViewOffset shr 32),longword(fCurrentViewOffset),fCurrentViewSize);
  end else begin
   fMemory:=MapViewOfFile(fMapHandle,FILE_MAP_READ or FILE_MAP_WRITE,longword(fCurrentViewOffset shr 32),longword(fCurrentViewOffset),fCurrentViewSize);
  end;
  if not assigned(fMemory) then begin
   raise Exception.Create(SysErrorMessage(GetLastError));
  end;
{$endif}
 end;
end;

procedure TBeRoFileMappedStream.CloseMapView;
begin
{$ifdef unix}
 if assigned(fMemory) then begin
  fpmunmap(fMemory,fCurrentViewSize);
  fMemory:=nil;
 end;
 if fFileHandle<>feInvalidHandle then begin
  fpClose(fFileHandle);
  fFileHandle:=feInvalidHandle;
 end;
{$else}
 if assigned(fMemory) then begin
  UnmapViewOfFile(fMemory);
  fMemory:=nil;
 end;
 if fMapHandle<>0 then begin
  CloseHandle(fMapHandle);
 end;
{$endif}
end;

procedure TBeRoFileMappedStream.SetSize(NewSize:longint);
begin
 SetSize(int64(NewSize));
end;

procedure TBeRoFileMappedStream.SetSize(const NewSize:int64);
begin
 CloseMapView;
{$ifdef unix}
 FpLseek(fFileHandle,NewSize,Seek_Set);
{$else}
 SetFilePointer(fFileHandle,NewSize,nil,FILE_BEGIN);
 SetEndOfFile(fFileHandle);
{$endif}
 if fCurrentViewOffset>NewSize then begin
  fCurrentViewOffset:=(NewSize-1) and fViewMask;
 end;
 if fCurrentViewOffset<0 then begin
  fCurrentViewOffset:=0;
 end;
 fSize:=NewSize;
 CreateMapView;
end;

procedure TBeRoFileMappedStream.Clear;
begin
 SetSize(1);
 fPosition:=0;
 fCurrentViewOffset:=0;
end;

procedure TBeRoFileMappedStream.Flush;
begin
{$ifdef unix}
 // At freepascal is no fpmsync or msync, so we must do it over this workaround
 CloseMapView;
 fpfsync(fFileHandle);
 CreateMapView;
{$else}
 if assigned(fMemory) then begin
  FlushViewOfFile(fMemory,fCurrentViewSize);
  FlushFileBuffers(fFileHandle);
 end else begin
  CloseMapView;
  FlushFileBuffers(fFileHandle);
  CreateMapView;
 end;
{$endif}
end;

function TBeRoFileMappedStream.Seek(const Offset:int64;Origin:TSeekOrigin):int64;
begin
 case Origin of
  soBeginning:begin
   fPosition:=Offset;
  end;
  soCurrent:begin
   fPosition:=fPosition+Offset;
  end;
  soEnd:begin
   fPosition:=fSize+Offset;
  end;
 end;
 if fPosition>fSize then begin
  SetSize(fPosition);
 end;
 UpdateMapView;
 result:=fPosition;
end;

function TBeRoFileMappedStream.Read(var Buffer;Count:longint):longint;
var Remain,ToDo:longint;
    BufferPointer:PAnsiChar;
begin
 if assigned(fMemory) then begin
  if (fPosition+Count)>Size then begin
   Count:=fSize-fPosition;
  end;
  Remain:=Count;
  BufferPointer:=@Buffer;
  while Remain>0 do begin
   UpdateMapView;
   ToDo:=Remain;
   if (fPosition+ToDo)>(fCurrentViewOffset+fCurrentViewSize) then begin
    ToDo:=(fCurrentViewOffset+fCurrentViewSize)-fPosition;
   end;
   Move(pointer(ptrint(ptrint(fMemory)+(fPosition-fCurrentViewOffset)))^,BufferPointer^,ToDo);
   inc(fPosition,ToDo);
   inc(BufferPointer,ToDo);
   dec(Remain,ToDo);
  end;
  result:=Count;
 end else begin
  raise Exception.Create('No data available');
 end;
end;

function TBeRoFileMappedStream.Write(const Buffer;Count:longint):longint;
var Remain,ToDo:longint;
    BufferPointer:PAnsiChar;
begin
 if assigned(fMemory) and not ReadOnly then begin
  if (fPosition+Count)>fSize then begin
   SetSize(fPosition+Count);
  end;
  Remain:=Count;
  BufferPointer:=@Buffer;
  while Remain>0 do begin
   UpdateMapView;
   ToDo:=Remain;
   if (fPosition+ToDo)>(fCurrentViewOffset+fCurrentViewSize) then begin
    ToDo:=(fCurrentViewOffset+fCurrentViewSize)-fPosition;
   end;
   Move(BufferPointer^,pointer(ptrint(ptrint(fMemory)+(fPosition-fCurrentViewOffset)))^,ToDo);
   inc(fPosition,ToDo);
   inc(BufferPointer,ToDo);
   dec(Remain,ToDo);
  end;
  result:=Count;
 end else begin
  raise Exception.Create('Cannot access memory data');
 end;
end;

end.
