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
 ******************************************************************************)
unit PasVulkan.Scene3D.DebugDump;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

uses SysUtils,
     Classes,
     Math,
     SyncObjs,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Collections,
     PasVulkan.Framework;

type TpvScene3DDebugDumpFourCC=array[0..3] of AnsiChar;

     TpvScene3DDebugDumpEntry=record
      Tag:TpvScene3DDebugDumpFourCC;
      ReadbackBuffer:TpvVulkanBuffer;
      CapturedSize:TVkDeviceSize;
      ExtraInfo:TpvUInt64;
      FrameIndex:TpvUInt32;
      Dirty:Boolean;
     end;
     PpvScene3DDebugDumpEntry=^TpvScene3DDebugDumpEntry;

     TpvScene3DDebugDumpEntries=array of TpvScene3DDebugDumpEntry;

     { TpvScene3DDebugDumpManager }
     TpvScene3DDebugDumpManager=class
      public
       type TStringHashMap=TpvStringHashMap<TpvSizeInt>;
      private
       fVulkanDevice:TpvVulkanDevice;
       fCountInFlightFrames:TpvSizeInt;
       fEntries:array[0..15] of TpvScene3DDebugDumpEntries;
       fOutputDir:String;
       fLock:TCriticalSection;
       fOnceDumpedIdentifiers:TStringHashMap;
       function FindOrAddEntry(const aInFlightFrameIndex:TpvSizeInt;const aTag:TpvScene3DDebugDumpFourCC;const aRequiredSize:TVkDeviceSize;const aObjectName:String):PpvScene3DDebugDumpEntry;
       procedure WriteDumpFile(const aFilename:String;const aTag:TpvScene3DDebugDumpFourCC;const aFrameIndex:TpvUInt32;const aInFlightFrameIndex:TpvUInt32;const aData;const aSize:TVkDeviceSize;const aExtraInfo:TpvUInt64);
      public
       constructor Create(const aVulkanDevice:TpvVulkanDevice;const aCountInFlightFrames:TpvSizeInt;const aOutputDir:String);
       destructor Destroy; override;
       procedure RecordCopy(const aCommandBuffer:TpvVulkanCommandBuffer;
                            const aInFlightFrameIndex:TpvSizeInt;
                            const aTag:TpvScene3DDebugDumpFourCC;
                            const aSourceBuffer:TpvVulkanBuffer;
                            const aSrcAccessMask:TVkAccessFlags;
                            const aSrcStageMask:TVkPipelineStageFlags;
                            const aCaptureSize:TVkDeviceSize;
                            const aExtraInfo:TpvUInt64);
       procedure FlushInFlightFrame(const aInFlightFrameIndex:TpvSizeInt);
       procedure DumpRawOnce(const aTag:TpvScene3DDebugDumpFourCC;const aData;const aSize:TpvSizeInt;const aIdentifier:String;const aExtraInfo:TpvUInt64);
       procedure DumpRaw(const aTag:TpvScene3DDebugDumpFourCC;const aFrameIndex,aInFlightFrameIndex:TpvUInt32;const aData;const aSize:TpvSizeInt;const aExtraInfo:TpvUInt64);
     end;

const TpvScene3DDebugDumpTagMeshletBoundingSpheres:TpvScene3DDebugDumpFourCC=('M','B','S','P');
      TpvScene3DDebugDumpTagGlobalBoundingSpheres:TpvScene3DDebugDumpFourCC=('G','B','S','P');
      TpvScene3DDebugDumpTagMeshletDescriptors:TpvScene3DDebugDumpFourCC=('M','D','S','C');
      TpvScene3DDebugDumpTagJointBlocks:TpvScene3DDebugDumpFourCC=('J','B','L','K');
      TpvScene3DDebugDumpTagNodeMatrices:TpvScene3DDebugDumpFourCC=('N','M','T','X');
      TpvScene3DDebugDumpTagMorphTargetVertexWeights:TpvScene3DDebugDumpFourCC=('M','T','W','G');
      TpvScene3DDebugDumpTagCachedVertices:TpvScene3DDebugDumpFourCC=('C','V','T','X');
      TpvScene3DDebugDumpTagNodeMap:TpvScene3DDebugDumpFourCC=('N','M','A','P');

var pvScene3DDumpBoundingSpheres:Boolean=false;
    pvScene3DDumpAnimationBuffers:Boolean=false;
    pvScene3DDebugDumpManager:TpvScene3DDebugDumpManager=nil;
    pvScene3DDebugDumpFrameIndex:TpvUInt32=0;

implementation

type TpvScene3DDebugDumpFileHeaderSignature=array[0..3] of AnsiChar;
     TpvScene3DDebugDumpFileHeader=packed record
      Magic:TpvScene3DDebugDumpFileHeaderSignature;
      Version:TpvUInt32;
      FrameIndex:TpvUInt32;
      InFlightFrameIndex:TpvUInt32;
      Tag:TpvScene3DDebugDumpFourCC;
      Reserved:TpvUInt32;
      SizeBytes:TpvUInt64;
      ExtraInfo:TpvUInt64;
     end;

const DumpFileMagic:TpvScene3DDebugDumpFileHeaderSignature=('P','V','S','D');
      DumpFileVersion:TpvUInt32=1;

{ TpvScene3DDebugDumpManager }

constructor TpvScene3DDebugDumpManager.Create(const aVulkanDevice:TpvVulkanDevice;const aCountInFlightFrames:TpvSizeInt;const aOutputDir:String);
var Index:TpvSizeInt;
begin
 inherited Create;
 fVulkanDevice:=aVulkanDevice;
 fCountInFlightFrames:=aCountInFlightFrames;
 fOutputDir:=IncludeTrailingPathDelimiter(aOutputDir);
 fLock:=TCriticalSection.Create;
 fOnceDumpedIdentifiers:=TStringHashMap.Create(-1);
 for Index:=0 to length(fEntries)-1 do begin
  fEntries[Index]:=nil;
 end;
 if not DirectoryExists(fOutputDir) then begin
  ForceDirectories(fOutputDir);
 end;
end;

destructor TpvScene3DDebugDumpManager.Destroy;
var InFlightFrameIndex,EntryIdx:TpvSizeInt;
begin
 for InFlightFrameIndex:=0 to length(fEntries)-1 do begin
  for EntryIdx:=0 to length(fEntries[InFlightFrameIndex])-1 do begin
   FreeAndNil(fEntries[InFlightFrameIndex][EntryIdx].ReadbackBuffer);
  end;
  fEntries[InFlightFrameIndex]:=nil;
 end;
 FreeAndNil(fOnceDumpedIdentifiers);
 FreeAndNil(fLock);
 inherited Destroy;
end;

function TpvScene3DDebugDumpManager.FindOrAddEntry(const aInFlightFrameIndex:TpvSizeInt;const aTag:TpvScene3DDebugDumpFourCC;const aRequiredSize:TVkDeviceSize;const aObjectName:String):PpvScene3DDebugDumpEntry;
var EntryIdx,NewIdx:TpvSizeInt;
    Entry:PpvScene3DDebugDumpEntry;
begin
 result:=nil;
 if (aInFlightFrameIndex<0) or (aInFlightFrameIndex>=length(fEntries)) then begin
  exit;
 end;
 for EntryIdx:=0 to length(fEntries[aInFlightFrameIndex])-1 do begin
  Entry:=@fEntries[aInFlightFrameIndex][EntryIdx];
  if (Entry^.Tag[0]=aTag[0]) and (Entry^.Tag[1]=aTag[1]) and (Entry^.Tag[2]=aTag[2]) and (Entry^.Tag[3]=aTag[3]) then begin
   result:=Entry;
   break;
  end;
 end;
 if not assigned(result) then begin
  NewIdx:=length(fEntries[aInFlightFrameIndex]);
  SetLength(fEntries[aInFlightFrameIndex],NewIdx+1);
  FillChar(fEntries[aInFlightFrameIndex][NewIdx],SizeOf(TpvScene3DDebugDumpEntry),#0);
  fEntries[aInFlightFrameIndex][NewIdx].Tag:=aTag;
  result:=@fEntries[aInFlightFrameIndex][NewIdx];
 end;
 if (not assigned(result^.ReadbackBuffer)) or (result^.ReadbackBuffer.Size<aRequiredSize) then begin
  fVulkanDevice.WaitIdle;
  FreeAndNil(result^.ReadbackBuffer);
  result^.ReadbackBuffer:=TpvVulkanBuffer.Create(fVulkanDevice,
                                                 Max(aRequiredSize,1024),
                                                 TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT),
                                                 TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                 [],
                                                 TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                 TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_CACHED_BIT),
                                                 0,
                                                 0,
                                                 0,
                                                 0,
                                                 0,
                                                 0,
                                                 [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                 0,
                                                 pvAllocationGroupIDScene3DDynamic,
                                                 'Scene3DDebugDump.'+aObjectName);
  fVulkanDevice.DebugUtils.SetObjectName(result^.ReadbackBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'Scene3DDebugDump.'+aObjectName);
 end;
end;

procedure TpvScene3DDebugDumpManager.RecordCopy(const aCommandBuffer:TpvVulkanCommandBuffer;
                                                const aInFlightFrameIndex:TpvSizeInt;
                                                const aTag:TpvScene3DDebugDumpFourCC;
                                                const aSourceBuffer:TpvVulkanBuffer;
                                                const aSrcAccessMask:TVkAccessFlags;
                                                const aSrcStageMask:TVkPipelineStageFlags;
                                                const aCaptureSize:TVkDeviceSize;
                                                const aExtraInfo:TpvUInt64);
var Entry:PpvScene3DDebugDumpEntry;
    SrcBarrier:TVkBufferMemoryBarrier;
    BufferCopy:TVkBufferCopy;
    ActualSize:TVkDeviceSize;
    ObjectName:String;
begin
 if not assigned(aSourceBuffer) then begin
  exit;
 end;
 ActualSize:=aCaptureSize;
 if (ActualSize=0) or (ActualSize>aSourceBuffer.Size) then begin
  ActualSize:=aSourceBuffer.Size;
 end;
 if ActualSize=0 then begin
  exit;
 end;
 fLock.Acquire;
 try
  ObjectName:=aTag[0]+aTag[1]+aTag[2]+aTag[3]+'_iff_'+IntToStr(aInFlightFrameIndex);
  Entry:=FindOrAddEntry(aInFlightFrameIndex,aTag,ActualSize,ObjectName);
  if not assigned(Entry) then begin
   exit;
  end;
  FillChar(SrcBarrier,SizeOf(TVkBufferMemoryBarrier),#0);
  SrcBarrier.sType:=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
  SrcBarrier.srcAccessMask:=aSrcAccessMask;
  SrcBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
  SrcBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  SrcBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  SrcBarrier.buffer:=aSourceBuffer.Handle;
  SrcBarrier.offset:=0;
  SrcBarrier.size:=ActualSize;
  aCommandBuffer.CmdPipelineBarrier(aSrcStageMask,
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                    0,
                                    0,nil,
                                    1,@SrcBarrier,
                                    0,nil);
  FillChar(BufferCopy,SizeOf(TVkBufferCopy),#0);
  BufferCopy.srcOffset:=0;
  BufferCopy.dstOffset:=0;
  BufferCopy.size:=ActualSize;
  aCommandBuffer.CmdCopyBuffer(aSourceBuffer.Handle,Entry^.ReadbackBuffer.Handle,1,@BufferCopy);
  Entry^.CapturedSize:=ActualSize;
  Entry^.ExtraInfo:=aExtraInfo;
  Entry^.FrameIndex:=pvScene3DDebugDumpFrameIndex;
  Entry^.Dirty:=true;
 finally
  fLock.Release;
 end;
end;

procedure TpvScene3DDebugDumpManager.WriteDumpFile(const aFilename:String;const aTag:TpvScene3DDebugDumpFourCC;const aFrameIndex:TpvUInt32;const aInFlightFrameIndex:TpvUInt32;const aData;const aSize:TVkDeviceSize;const aExtraInfo:TpvUInt64);
var FileStream:TFileStream;
    Header:TpvScene3DDebugDumpFileHeader;
begin
 FileStream:=TFileStream.Create(aFilename,fmCreate);
 try
  FillChar(Header,SizeOf(Header),#0);
  Header.Magic:=DumpFileMagic;
  Header.Version:=DumpFileVersion;
  Header.FrameIndex:=aFrameIndex;
  Header.InFlightFrameIndex:=aInFlightFrameIndex;
  Header.Tag:=aTag;
  Header.Reserved:=0;
  Header.SizeBytes:=aSize;
  Header.ExtraInfo:=aExtraInfo;
  FileStream.WriteBuffer(Header,SizeOf(Header));
  if aSize>0 then begin
   FileStream.WriteBuffer(aData,aSize);
  end;
 finally
  FreeAndNil(FileStream);
 end;
end;

procedure TpvScene3DDebugDumpManager.FlushInFlightFrame(const aInFlightFrameIndex:TpvSizeInt);
var EntryIdx:TpvSizeInt;
    Entry:PpvScene3DDebugDumpEntry;
    DataPtr:Pointer;
    Filename:String;
    TagStr:String;
begin
 if (aInFlightFrameIndex<0) or (aInFlightFrameIndex>=length(fEntries)) then begin
  exit;
 end;
 fLock.Acquire;
 try
  for EntryIdx:=0 to length(fEntries[aInFlightFrameIndex])-1 do begin
   Entry:=@fEntries[aInFlightFrameIndex][EntryIdx];
   if (not Entry^.Dirty) or (not assigned(Entry^.ReadbackBuffer)) or (Entry^.CapturedSize=0) then begin
    continue;
   end;
   DataPtr:=Entry^.ReadbackBuffer.Memory.MapMemory;
   if not assigned(DataPtr) then begin
    continue;
   end;
   try
    Entry^.ReadbackBuffer.Memory.InvalidateMappedMemory;
    TagStr:=Entry^.Tag[0]+Entry^.Tag[1]+Entry^.Tag[2]+Entry^.Tag[3];
    Filename:=fOutputDir+'frame_'+Format('%.8d',[Entry^.FrameIndex])+'_iff_'+IntToStr(aInFlightFrameIndex)+'_'+TagStr+'.bin';
    WriteDumpFile(Filename,Entry^.Tag,Entry^.FrameIndex,aInFlightFrameIndex,DataPtr^,Entry^.CapturedSize,Entry^.ExtraInfo);
   finally
    Entry^.ReadbackBuffer.Memory.UnmapMemory;
   end;
   Entry^.Dirty:=false;
  end;
 finally
  fLock.Release;
 end;
end;

procedure TpvScene3DDebugDumpManager.DumpRawOnce(const aTag:TpvScene3DDebugDumpFourCC;const aData;const aSize:TpvSizeInt;const aIdentifier:String;const aExtraInfo:TpvUInt64);
var Filename,Key,TagStr:String;
begin
 if aSize<=0 then begin
  exit;
 end;
 fLock.Acquire;
 try
  TagStr:=aTag[0]+aTag[1]+aTag[2]+aTag[3];
  Key:=TagStr+'/'+aIdentifier;
  if fOnceDumpedIdentifiers.ExistKey(Key) then begin
   exit;
  end;
  fOnceDumpedIdentifiers.Add(Key,0);
  Filename:=fOutputDir+'once_'+aIdentifier+'_'+TagStr+'.bin';
  WriteDumpFile(Filename,aTag,0,0,aData,aSize,aExtraInfo);
 finally
  fLock.Release;
 end;
end;

procedure TpvScene3DDebugDumpManager.DumpRaw(const aTag:TpvScene3DDebugDumpFourCC;const aFrameIndex,aInFlightFrameIndex:TpvUInt32;const aData;const aSize:TpvSizeInt;const aExtraInfo:TpvUInt64);
var Filename,TagStr:String;
begin
 if aSize<=0 then begin
  exit;
 end;
 fLock.Acquire;
 try
  TagStr:=aTag[0]+aTag[1]+aTag[2]+aTag[3];
  Filename:=fOutputDir+'frame_'+Format('%.8d',[aFrameIndex])+'_iff_'+IntToStr(aInFlightFrameIndex)+'_'+TagStr+'.bin';
  WriteDumpFile(Filename,aTag,aFrameIndex,aInFlightFrameIndex,aData,aSize,aExtraInfo);
 finally
  fLock.Release;
 end;
end;

end.
