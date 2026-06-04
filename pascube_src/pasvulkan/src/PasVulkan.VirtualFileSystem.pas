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
unit PasVulkan.VirtualFileSystem;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$scopedenums on}
{$m+}

interface

uses SysUtils,
     Classes,
     Math,
     PasJSON,
     PasVulkan.Types,
     PasVulkan.Assets,
     PasVulkan.Streams,
     PasVulkan.Math,
     PasVulkan.Collections,
     PasVulkan.Archive.ZIP,
     PasVulkan.Archive.SPK;

type EpvVirtualFileSystem=class(Exception);

     EpvVirtualFileSystemFileNotFound=class(EpvVirtualFileSystem);

     { TpvVirtualFileSystem }

     TpvVirtualFileSystem=class
      public
       type TArchiveType=
             (
              ZIP,
              SPK
             );
       type TVirtualSymLinkHashMap=TpvStringHashMap<string>; // string <=> string
      private
       fArchiveType:TArchiveType;
       fArchiveSPK:TpvArchiveSPK;
       fArchiveZIP:TpvArchiveZIP;
       fStream:TStream;
       fVirtualSymLinkHashMap:TVirtualSymLinkHashMap;
       fRaiseOnNonFoundFiles:Boolean;
      public
       constructor Create(const aData:pointer;const aDataSize:TpvSizeInt;const aFileName:string='';const aRaiseOnNonFoundFiles:Boolean=false); reintroduce; virtual;
       destructor Destroy; override;
       function ExistFile(const aFileName:string):boolean;
       function GetFile(const aFileName:string):TStream;
      published
       property ArchiveType:TArchiveType read fArchiveType;
       property ArchiveSPK:TpvArchiveSPK read fArchiveSPK;
       property ArchiveZIP:TpvArchiveZIP read fArchiveZIP;
     end;

implementation

uses PasVulkan.Application,PasVulkan.Compression;

{ TpvVirtualFileSystem }

constructor TpvVirtualFileSystem.Create(const aData:pointer;const aDataSize:TpvSizeInt;const aFileName:string;const aRaiseOnNonFoundFiles:Boolean);
var Index:TpvSizeInt;
    Stream,UncompressedStream:TStream;
    ZIPEntry:TpvArchiveZIPEntry;
    VirtualSymLinksJSONStream:TStream;
    VirtualSymLinksJSON:TPasJSONItem;
    VirtualSymLinksJSONObject:TPasJSONItemObject;
    Key,Value:string;
    Compressed:Boolean;
begin
 inherited Create;

 fRaiseOnNonFoundFiles:=aRaiseOnNonFoundFiles;

 if (aDataSize>=3) and (PpvUInt8Array(aData)^[0]=Ord('S')) and (PpvUInt8Array(aData)^[1]=Ord('P')) and (PpvUInt8Array(aData)^[2]=Ord('K')) then begin
  // Uncompressed SPK archive
  fArchiveType:=TArchiveType.SPK;
  Compressed:=false;
 end else if (aDataSize>=4) and (PpvUInt8Array(aData)^[0]=Ord('C')) and (PpvUInt8Array(aData)^[1]=Ord('O')) and (PpvUInt8Array(aData)^[2]=Ord('F')) and (PpvUInt8Array(aData)^[3]=Ord('I')) then begin
  // Compressed SPK archive (with big chance since COFI is the magic signature of the just compression format itself)
  fArchiveType:=TArchiveType.SPK;
  Compressed:=true;
 end else begin
  fArchiveType:=TArchiveType.ZIP;
  Compressed:=false;
 end;

 fStream:=TMemoryStream.Create;
 
 fArchiveSPK:=nil;
 fArchiveZIP:=nil;

 case fArchiveType of
  TArchiveType.SPK:begin
   fArchiveSPK:=TpvArchiveSPK.Create;
  end;
  TArchiveType.ZIP:begin
   fArchiveZIP:=TpvArchiveZIP.Create;
  end;
 end;
 
 if (length(aFileName)>0) and FileExists(aFileName) then begin
  Stream:=TFileStream.Create(aFileName,fmOpenRead or fmShareDenyWrite);
 end else begin
  Stream:=TMemoryStream.Create;
  if assigned(aData) and (aDataSize>0) then begin
   Stream.Write(aData^,aDataSize);
   Stream.Seek(0,soBeginning);
  end;
 end;
 try
  fStream.CopyFrom(Stream,Stream.Size);
  fStream.Seek(0,soBeginning);
  case fArchiveType of
   TArchiveType.SPK:begin
    if Compressed then begin
     UncompressedStream:=TMemoryStream.Create;
     try
      DecompressStream(fStream,UncompressedStream);
      UncompressedStream.Seek(0,soBeginning);
      fArchiveSPK.LoadFromStream(UncompressedStream);       
     finally
      FreeAndNil(UncompressedStream);
     end;
    end else begin
     fArchiveSPK.LoadFromStream(fStream);
    end; 
   end;
   TArchiveType.ZIP:begin
    fArchiveZIP.LoadFromStream(fStream);
   end;
  end;
 finally
  FreeAndNil(Stream);
 end;

 // Load virtual symlinks and add them to the hashmap for further use
 case fArchiveType of
  TArchiveType.SPK:begin
   fVirtualSymLinkHashMap:=TVirtualSymLinkHashMap.Create('');
   VirtualSymLinksJSONStream:=fArchiveSPK.GetStreamCopy('virtualsymlinks.json');
   if assigned(VirtualSymLinksJSONStream) then begin
    try
     VirtualSymLinksJSONStream.Seek(0,soBeginning);
     VirtualSymLinksJSON:=TPasJSON.Parse(VirtualSymLinksJSONStream);
     try
      if assigned(VirtualSymLinksJSON) and (VirtualSymLinksJSON is TPasJSONItemObject) then begin
       VirtualSymLinksJSONObject:=TPasJSONItemObject(VirtualSymLinksJSON);
       for Index:=0 to VirtualSymLinksJSONObject.Count-1 do begin
        Key:=VirtualSymLinksJSONObject.Keys[Index];
        Value:=TPasJSON.GetString(VirtualSymLinksJSONObject.Values[Index],'');
        fVirtualSymLinkHashMap.Add(Key,Value);
       end;
      end;
     finally
      FreeAndNil(VirtualSymLinksJSON);
     end;
    finally
     FreeAndNil(VirtualSymLinksJSONStream);
    end;
   end;
  end;
  TArchiveType.ZIP:begin
   fVirtualSymLinkHashMap:=TVirtualSymLinkHashMap.Create('');
   ZIPEntry:=fArchiveZIP.Entries.Find('virtualsymlinks.json');
   if assigned(ZIPEntry) then begin
    VirtualSymLinksJSONStream:=TMemoryStream.Create;
    try
     ZIPEntry.SaveToStream(VirtualSymLinksJSONStream);
     VirtualSymLinksJSONStream.Seek(0,soBeginning);
     VirtualSymLinksJSON:=TPasJSON.Parse(VirtualSymLinksJSONStream);
     try
      if assigned(VirtualSymLinksJSON) and (VirtualSymLinksJSON is TPasJSONItemObject) then begin
       VirtualSymLinksJSONObject:=TPasJSONItemObject(VirtualSymLinksJSON);
       for Index:=0 to VirtualSymLinksJSONObject.Count-1 do begin
        Key:=VirtualSymLinksJSONObject.Keys[Index];
        Value:=TPasJSON.GetString(VirtualSymLinksJSONObject.Values[Index],'');
        fVirtualSymLinkHashMap.Add(Key,Value);
       end;
      end;
     finally
      FreeAndNil(VirtualSymLinksJSON);
     end;
    finally
     FreeAndNil(VirtualSymLinksJSONStream);
    end;
   end;
  end;
  else begin
   Assert(false); 
  end;
 end;  

end;

destructor TpvVirtualFileSystem.Destroy;
begin
 FreeAndNil(fVirtualSymLinkHashMap);
 FreeAndNil(fArchiveZIP);
 FreeAndNil(fArchiveSPK);
 FreeAndNil(fStream);
 inherited Destroy;
end;

function TpvVirtualFileSystem.ExistFile(const aFileName:string):boolean;
var FileName:string;
begin
 case fArchiveType of
  TArchiveType.SPK:begin
   if fVirtualSymLinkHashMap.TryGet(aFileName,FileName) then begin
    result:=fArchiveSPK.FileExists(FileName);
   end else begin
    result:=fArchiveSPK.FileExists(aFileName);
   end; 
  end;
  TArchiveType.ZIP:begin
   if fVirtualSymLinkHashMap.TryGet(aFileName,FileName) then begin
    result:=assigned(fArchiveZIP.Entries.Find(FileName));
   end else begin
    result:=assigned(fArchiveZIP.Entries.Find(aFileName));
   end; 
  end;
  else begin
   result:=false;
  end;
 end;
end;

function TpvVirtualFileSystem.GetFile(const aFileName:string):TStream;
var ZIPEntry:TpvArchiveZIPEntry;
    FileName:string;
begin
{$ifdef Android}
 if assigned(pvApplication) then begin
  pvApplication.Log(LOG_DEBUG,'TpvVirtualFileSystem.GetFile',aFileName);
 end;
{$endif}
 case fArchiveType of
  TArchiveType.SPK:begin
   if fVirtualSymLinkHashMap.TryGet(aFileName,FileName) then begin
    result:=fArchiveSPK.GetStreamCopy(FileName);
   end else begin
    result:=fArchiveSPK.GetStreamCopy(aFileName);
   end;
  end;
  TArchiveType.ZIP:begin
   if fVirtualSymLinkHashMap.TryGet(aFileName,FileName) then begin
    ZIPEntry:=fArchiveZIP.Entries.Find(FileName);
   end else begin
    ZIPEntry:=fArchiveZIP.Entries.Find(aFileName);
   end;
   if assigned(ZIPEntry) then begin
    result:=TMemoryStream.Create;
    ZIPEntry.SaveToStream(result);
    result.Seek(0,soBeginning);
   end else begin
    result:=nil;
   end;
  end;
  else begin 
   result:=nil;
  end;
 end;
 if fRaiseOnNonFoundFiles and not assigned(result) then begin
  raise EpvVirtualFileSystemFileNotFound.Create('"'+aFileName+'" not found');
 end;
end;

end.
