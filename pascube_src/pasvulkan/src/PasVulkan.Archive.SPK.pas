(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                       Version see PasVulkan.Framework.pas                  *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2024, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
 * 3. This PasVulkan wrapper may be used only with the PasVulkan-own Vulkan   *
 *    Pascal header.                                                          *
 * 4. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pasvulkan                                    *
 * 5. Write code which's compatible with Delphi >= 2009 and FreePascal >=     *
 *    3.1.1                                                                   *
 * 6. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 7. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 8. Try to use const when possible.                                         *
 * 9. Make sure to comment out writeln, used while debugging.                 *
 * 10. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,    *
 *     x86-64, ARM, ARM64, etc.).                                             *
 * 11. Make sure the code runs on all platforms with Vulkan support           *
 *                                                                            *
 ******************************************************************************)
unit PasVulkan.Archive.SPK; // Simple Package
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}

interface

uses SysUtils, 
     Classes,
     Math,
     PasVulkan.Types,
     PasVulkan.Collections;

type EpvArchiveSPK=class(Exception);

     TpvArchiveSPK=class
      public
       type { TFileItem }
            TFileItem=class
             private
              fFileName:TpvRawByteString;
              fOffset:TpvUInt64;
              fOffsetOffset:TpvUInt64;
              fSize:TpvUInt64;
              fStream:TMemoryStream;
             public
              constructor Create(const aFileName:TpvRawByteString);
              destructor Destroy; override;
              property FileName:TpvRawByteString read fFileName write fFileName;
              property Offset:TpvUInt64 read fOffset write fOffset;
              property Size:TpvUInt64 read fSize write fSize;
              property Stream:TMemoryStream read fStream write fStream;
            end;
            TFileItemClass=class of TFileItem;
            { TFileItemList }
            TFileItemList=TpvObjectGenericList<TFileItem>;
            { TFileItemHashMap }
            TFileItemHashMap=TpvStringHashMap<TFileItem>;
            TFileSignature=packed array[0..3] of AnsiChar;
            TFileHeader=packed record
             Signature:TFileSignature;
             Version:TpvUInt32;
             FileCount:TpvUInt64;
            end;
       const SPKSignature:TFileSignature=('S','P','K',#0);
             SPKVersion=TpvUInt32(1);    
      private
       fFileName:TpvRawByteString;
       fFileItemList:TFileItemList;
       fFileItemHashMap:TFileItemHashMap;
       function GetFileCount:TpvSizeInt;
       function GetFileItem(const Index:TpvSizeInt):TFileItem;
       function GetFileItemByName(const aFileName:TpvRawByteString):TFileItem;
      public
       constructor Create; reintroduce; 
       destructor Destroy; override;
       procedure Clear;
       procedure LoadFromStream(const aStream:TStream);
       procedure LoadFromFile(const aFileName:TpvRawByteString);
       procedure SaveToStream(const aStream:TStream);
       procedure SaveToFile(const aFileName:TpvRawByteString);
       function AddFile(const aFileName:TpvRawByteString;const aStream:TStream):TFileItem; overload;
       function AddFile(const aFileName:TpvRawByteString;const aData:TpvPointer;const aSize:TpvSizeUInt):TFileItem; overload;
       function AddFile(const aFileName:TpvRawByteString;const aData:TpvRawByteString):TFileItem; overload;
       function AddFile(const aFileName:TpvRawByteString;const aData:array of TpvUInt8):TFileItem; overload;
       function RemoveFile(const aFileName:TpvRawByteString):boolean;
       function FileExists(const aFileName:TpvRawByteString):boolean;
       function FindFile(const aFileName:TpvRawByteString):TFileItem;
       function GetStream(const aFileName:TpvRawByteString):TStream;
       function GetStreamCopy(const aFileName:TpvRawByteString):TStream;
      public
       property FileName:TpvRawByteString read fFileName write fFileName;
       property CountFiles:TpvSizeInt read GetFileCount;
       property Files[const Index:TpvSizeInt]:TFileItem read GetFileItem; 
       property FileItems:TFileItemList read fFileItemList;
       property FileItemHashMap:TFileItemHashMap read fFileItemHashMap;
       property FileByName[const aFileName:TpvRawByteString]:TFileItem read GetFileItemByName; default;
     end;

implementation

{ TpvArchiveSPK.TFileItem }

constructor TpvArchiveSPK.TFileItem.Create(const aFileName:TpvRawByteString);
begin
 inherited Create;
 fFileName:=aFileName;
 fOffset:=0;
 fSize:=0;
 fStream:=nil;
end;

destructor TpvArchiveSPK.TFileItem.Destroy;
begin
 FreeAndNil(fStream);
 inherited Destroy;
end;

{ TpvArchiveSPK }

constructor TpvArchiveSPK.Create;
begin
 inherited Create;
 fFileItemList:=TFileItemList.Create(true); // Owns objects
 fFileItemHashMap:=TFileItemHashMap.Create(nil); // Nil as default value if non existing
 fFileName:='';
end;

destructor TpvArchiveSPK.Destroy;
begin
 Clear;
 FreeAndNil(fFileItemHashMap);
 FreeAndNil(fFileItemList);
 inherited Destroy;
end;

procedure TpvArchiveSPK.Clear;
var Index:TpvSizeInt;
begin
 fFileItemList.Clear;
 fFileItemHashMap.Clear;
end;

function TpvArchiveSPK.GetFileCount:TpvSizeInt;
begin
 result:=fFileItemList.Count;
end;

function TpvArchiveSPK.GetFileItem(const Index:TpvSizeInt):TFileItem;
begin
 result:=fFileItemList[Index];
end;

function TpvArchiveSPK.GetFileItemByName(const aFileName:TpvRawByteString):TFileItem;
begin
 if not fFileItemHashMap.TryGet(aFileName,result) then begin
  result:=nil;
 end;
end;

procedure TpvArchiveSPK.LoadFromStream(const aStream:TStream);
var FileHeader:TpvArchiveSPK.TFileHeader;
    Index:TpvSizeInt;
    FileItem:TFileItem;
    FileNameLength:TpvUInt32;
    FileName:TpvRawByteString;
begin

 aStream.Seek(0,soBeginning);

 aStream.Read(FileHeader,SizeOf(TpvArchiveSPK.TFileHeader));

 if (FileHeader.Signature<>SPKSignature) or (FileHeader.Version<>SPKVersion) then begin
  raise EpvArchiveSPK.Create('Invalid SPK file');
 end;

 Clear;

 for Index:=0 to TpvSizeInt(FileHeader.FileCount)-1 do begin
  aStream.Read(FileNameLength,SizeOf(TpvUInt32));
  if FileNameLength>0 then begin
   SetLength(FileName,FileNameLength);
   aStream.Read(FileName[1],FileNameLength);
   FileItem:=TFileItem.Create(FileName);
   try
    aStream.Read(FileItem.fOffset,SizeOf(TpvUInt64));
    aStream.Read(FileItem.fSize,SizeOf(TpvUInt64));
    fFileItemHashMap.Add(FileName,FileItem);
   finally 
    fFileItemList.Add(FileItem);
   end; 
  end else begin
   raise EpvArchiveSPK.Create('Invalid SPK file');
  end;
 end;

 for Index:=0 to fFileItemList.Count-1 do begin
  FileItem:=fFileItemList[Index];
  FileItem.Stream:=TMemoryStream.Create;
  if FileItem.Size>0 then begin
   aStream.Seek(FileItem.Offset,soBeginning);
   FileItem.Stream.CopyFrom(aStream,FileItem.Size);
   FileItem.Stream.Seek(0,soBeginning);
  end; 
 end;

 fFileName:=''; 

end; 

procedure TpvArchiveSPK.LoadFromFile(const aFileName:TpvRawByteString);
var Stream:TFileStream;
begin
 Stream:=TFileStream.Create(aFileName,fmOpenRead{or fmShareDenyWrite});
 try
  LoadFromStream(Stream);
 finally
  FreeAndNil(Stream);
 end;
 fFileName:=aFileName;
end;

procedure TpvArchiveSPK.SaveToStream(const aStream:TStream);
var FileHeader:TpvArchiveSPK.TFileHeader;
    Index:TpvSizeInt;
    FileItem:TFileItem;
    FileNameLength:TpvUInt32;
    FileName:TpvRawByteString;
begin

 FileHeader.Signature:=SPKSignature;
 FileHeader.Version:=SPKVersion;
 FileHeader.FileCount:=fFileItemList.Count;

 aStream.Seek(0,soBeginning);
 aStream.Write(FileHeader,SizeOf(TpvArchiveSPK.TFileHeader));

 for Index:=0 to fFileItemList.Count-1 do begin
  FileItem:=fFileItemList[Index];
  FileName:=FileItem.fFileName;
  FileNameLength:=TpvUInt32(length(FileName));
  aStream.Write(FileNameLength,SizeOf(TpvUInt32));
  if FileNameLength>0 then begin
   aStream.Write(FileName[1],FileNameLength);
   FileItem.fOffsetOffset:=aStream.Position;
   aStream.Write(FileItem.fOffset,SizeOf(TpvUInt64));
   aStream.Write(FileItem.fSize,SizeOf(TpvUInt64));
  end else begin
   raise EpvArchiveSPK.Create('Invalid SPK file');
  end;
 end;

 for Index:=0 to fFileItemList.Count-1 do begin
  FileItem:=fFileItemList[Index];
  if assigned(FileItem.Stream) and (FileItem.Stream.Size>0) then begin
   FileItem.Offset:=aStream.Position;
   if FileItem.Size=FileItem.Stream.Size then begin
    aStream.CopyFrom(FileItem.Stream,0);
   end else begin 
    raise EpvArchiveSPK.Create('Invalid SPK file');
   end;
  end else if FileItem.Size<>0 then begin
   raise EpvArchiveSPK.Create('Invalid SPK file');
  end;
 end;

 for Index:=0 to fFileItemList.Count-1 do begin
  FileItem:=fFileItemList[Index];
  FileName:=FileItem.fFileName;
  FileNameLength:=TpvUInt32(length(FileName));
  if FileNameLength>0 then begin
   aStream.Seek(FileItem.fOffsetOffset,soBeginning);
   aStream.Write(FileItem.fOffset,SizeOf(TpvUInt64));
  end else begin
   raise EpvArchiveSPK.Create('Invalid SPK file');
  end;
 end;

 aStream.Seek(0,soEnd);
 
 fFileName:='';

end;

procedure TpvArchiveSPK.SaveToFile(const aFileName:TpvRawByteString);
var Stream:TFileStream;
begin
 Stream:=TFileStream.Create(aFileName,fmCreate);
 try
  SaveToStream(Stream);
 finally
  FreeAndNil(Stream);
 end;
 fFileName:=aFileName;
end;

function TpvArchiveSPK.AddFile(const aFileName:TpvRawByteString;const aStream:TStream):TFileItem;
var WorkFileName:TpvRawByteString; 
begin
 result:=nil;
 WorkFileName:=LowerCase(aFileName);
 if not fFileItemHashMap.TryGet(WorkFileName,result) then begin
  result:=TFileItem.Create(WorkFileName);
  try
   result.Stream:=TMemoryStream.Create;   
   result.Stream.CopyFrom(aStream,0);
   result.Stream.Position:=0;
   result.Offset:=0;
   result.Size:=result.Stream.Size;
   fFileItemHashMap.Add(WorkFileName,result);
   fFileItemList.Add(result);
  except
   FreeAndNil(result);
   raise;
  end;
 end else begin
  raise EpvArchiveSPK.Create('File already exists');
 end;
end;

function TpvArchiveSPK.AddFile(const aFileName:TpvRawByteString;const aData:TpvPointer;const aSize:TpvSizeUInt):TFileItem;
var WorkFileName:TpvRawByteString; 
begin
 result:=nil;
 WorkFileName:=LowerCase(aFileName);
 if not fFileItemHashMap.TryGet(WorkFileName,result) then begin
  result:=TFileItem.Create(WorkFileName);
  try
   result.Stream:=TMemoryStream.Create;
   result.Stream.Write(aData^,aSize);
   result.Stream.Position:=0;
   result.Offset:=0;
   result.Size:=result.Stream.Size;
   fFileItemHashMap.Add(WorkFileName,result);
   fFileItemList.Add(result);
  except
   FreeAndNil(result);
   raise;
  end;
 end else begin
  raise EpvArchiveSPK.Create('File already exists');
 end;
end;

function TpvArchiveSPK.AddFile(const aFileName:TpvRawByteString;const aData:TpvRawByteString):TFileItem;
var WorkFileName:TpvRawByteString; 
begin
 result:=nil;
 WorkFileName:=LowerCase(aFileName);
 if not fFileItemHashMap.TryGet(WorkFileName,result) then begin
  result:=TFileItem.Create(WorkFileName);
  try
   result.Stream:=TMemoryStream.Create;
   result.Stream.Write(aData[1],length(aData));
   result.Stream.Position:=0;
   result.Offset:=0;
   result.Size:=result.Stream.Size;
   fFileItemHashMap.Add(WorkFileName,result);
   fFileItemList.Add(result);
  except
   FreeAndNil(result);
   raise;
  end;
 end else begin
  raise EpvArchiveSPK.Create('File already exists');
 end;
end;

function TpvArchiveSPK.AddFile(const aFileName:TpvRawByteString;const aData:array of TpvUInt8):TFileItem;
var WorkFileName:TpvRawByteString; 
begin
 result:=nil;
 WorkFileName:=LowerCase(aFileName);
 if not fFileItemHashMap.TryGet(WorkFileName,result) then begin
  result:=TFileItem.Create(WorkFileName);
  try
   result.Stream:=TMemoryStream.Create;
   result.Stream.Write(aData[0],length(aData));
   result.Stream.Position:=0;
   result.Offset:=0;
   result.Size:=result.Stream.Size;
   fFileItemHashMap.Add(WorkFileName,result);
   fFileItemList.Add(result);
  except
   FreeAndNil(result);
   raise;
  end;
 end else begin
  raise EpvArchiveSPK.Create('File already exists');
 end;
end;

function TpvArchiveSPK.RemoveFile(const aFileName:TpvRawByteString):boolean;
var FileItem:TFileItem;
    WorkFileName:TpvRawByteString; 
begin
 WorkFileName:=LowerCase(aFileName);
 result:=fFileItemHashMap.TryGet(WorkFileName,FileItem);
 if result then begin
  try
   fFileItemHashMap.Delete(WorkFileName);
   fFileItemList.Remove(FileItem);
  finally
   FreeAndNil(FileItem);
  end;
 end;
end;

function TpvArchiveSPK.FileExists(const aFileName:TpvRawByteString):boolean;
begin
 result:=fFileItemHashMap.ExistKey(LowerCase(aFileName));
end;

function TpvArchiveSPK.FindFile(const aFileName:TpvRawByteString):TFileItem;
begin
 if not fFileItemHashMap.TryGet(LowerCase(aFileName),result) then begin
  result:=nil;
 end;
end;

function TpvArchiveSPK.GetStream(const aFileName:TpvRawByteString):TStream;
var FileItem:TFileItem;
begin
 if fFileItemHashMap.TryGet(LowerCase(aFileName),FileItem) then begin
  result:=FileItem.Stream;
 end else begin
  result:=nil;
 end;
end;

function TpvArchiveSPK.GetStreamCopy(const aFileName:TpvRawByteString):TStream;
var Stream:TStream;
begin
 Stream:=GetStream(aFileName);
 if assigned(Stream) then begin
  result:=TMemoryStream.Create;
  if Stream.Size>0 then begin
   Stream.Seek(0,soBeginning);
   result.CopyFrom(Stream,Stream.Size);
  end;
  result.Seek(0,soBeginning);
 end else begin
  result:=nil;
 end;
end;

end.
