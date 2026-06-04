(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                   Version see PasVulkan.TransferQueue.pas                  *
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
unit PasVulkan.TransferQueue;
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
     Vulkan,
     PasMP,
     PasVulkan.Types,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Collections,
     PasVulkan.Utils;

// This transfer queue is a queue which is used for transfer operations, from CPU to a GPU temporary buffer and from there to the final GPU buffer, for
// updating non-double-buffered data in a thread-safe way, which is too large to be in-flight-frame-wise double- or triple-buffered, like large vertex 
// buffers, index buffers and the like. But the usage of this class must be well thought out, because it could be a performance bottleneck, if used.
// Double-/Triple-buffering with direct streaming from CPU to GPU is always better, if possible. For other cases, this class could be useful.

type { TpvTransferQueue }
     TpvTransferQueue=class
      public
       type TBlock=class
             private
              fTransferQueue:TpvTransferQueue;
              fBuffer:TpvVulkanBuffer;
             public
              constructor Create(const aTransferQueue:TpvTransferQueue);
              destructor Destroy; override;
            end;
            TBlocks=TpvObjectGenericList<TBlock>;
            TQueueItem=record
             public
              SourceBlock:TBlock;
              SourceOffset:TpvSizeInt;
              DestinationBuffer:TpvVulkanBuffer;
              DestinationOffset:TpvSizeInt;
              Size:TpvSizeInt;
            end; 
            PQueueItem=^TQueueItem;
            TQueueItems=TpvDynamicArrayList<TQueueItem>;
      private
       fDevice:TpvVulkanDevice;
       fLock:TPasMPSlimReaderWriterLock;
       fBlockSize:TpvSizeInt;
       fBlocks:TBlocks;
       fQueueItems:TQueueItems;
       fCurrentBlockIndex:TpvSizeInt;
       fOffset:TpvSizeInt;
       fMemoryRequiredPropertyFlags:TVkMemoryPropertyFlags;
       fMemoryPreferredPropertyFlags:TVkMemoryPropertyFlags;
       fMemoryAvoidPropertyFlags:TVkMemoryPropertyFlags;
       fMemoryPreferredNotPropertyFlags:TVkMemoryPropertyFlags;
      public
       constructor Create(const aDevice:TpvVulkanDevice); reintroduce;
       destructor Destroy; override;
       procedure Reset;
       procedure Queue(const aTransferQueue:TpvVulkanQueue;
                       const aTransferCommandBuffer:TpvVulkanCommandBuffer;
                       const aTransferFence:TpvVulkanFence;
                       const aSourceData;
                       const aDestinationBuffer:TpvVulkanBuffer;
                       const aDestinationOffset:TpvSizeInt;
                       const aSize:TpvSizeInt);
        procedure Flush(aCommandBuffer:TpvVulkanCommandBuffer); // for example for embedding into a command buffer of the frame graph, so it's in sync with the frame graph.
        procedure Execute(const aTransferQueue:TpvVulkanQueue;const aTransferCommandBuffer:TpvVulkanCommandBuffer;const aTransferFence:TpvVulkanFence); // for direct execution
       public
        property QueueItems:TQueueItems read fQueueItems;
     end;

     TpvInFlightFrameTransferQueues=array[0..MaxInFlightFrames-1] of TpvTransferQueue;

implementation

{ TpvTransferQueue.TBlock }

constructor TpvTransferQueue.TBlock.Create(const aTransferQueue:TpvTransferQueue);
begin
 inherited Create;
 fTransferQueue:=aTransferQueue;
 fBuffer:=TpvVulkanBuffer.Create(fTransferQueue.fDevice,
                                 fTransferQueue.fBlockSize,
                                 TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_SRC_BIT),
                                 TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                 [],
                                 fTransferQueue.fMemoryRequiredPropertyFlags,
                                 fTransferQueue.fMemoryPreferredPropertyFlags,
                                 fTransferQueue.fMemoryAvoidPropertyFlags,
                                 fTransferQueue.fMemoryPreferredNotPropertyFlags,
                                 0,
                                 0,
                                 0,
                                 0,
                                 [TpvVulkanBufferFlag.PersistentMappedIfPossible]);
 fTransferQueue.fDevice.DebugUtils.SetObjectName(fBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvTransferQueue.TBlock.fBuffer');
end;

destructor TpvTransferQueue.TBlock.Destroy;
begin
 FreeAndNil(fBuffer);
 inherited Destroy;
end;

{ TpvTransferQueue }

constructor TpvTransferQueue.Create(const aDevice:TpvVulkanDevice);
begin
 
 inherited Create;
 
 fDevice:=aDevice;

 case fDevice.PhysicalDevice.Properties.vendorID of
  TpvUInt32(TpvVulkanVendorID.AMD),
  TpvUInt32(TpvVulkanVendorID.NVIDIA),
  TpvUInt32(TpvVulkanVendorID.Intel):begin
   // For desktop/notebook GPUs, like NVIDIA, AMD and Intel GPUs
   if fDevice.MemoryManager.MaximumMemoryMappableNonDeviceLocalHeapSize>=(16 shl 20) then begin
    fBlockSize:=Min(Max(TpvUInt64(fDevice.MemoryManager.MaximumMemoryMappableNonDeviceLocalHeapSize shr 6),TpvUInt64(16 shl 20)),TpvUInt64(128 shl 20));
    fMemoryRequiredPropertyFlags:=TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT);
    fMemoryPreferredPropertyFlags:=TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
    fMemoryAvoidPropertyFlags:=0;
    fMemoryPreferredNotPropertyFlags:=0;
   end else if fDevice.MemoryManager.MaximumMemoryMappableDeviceLocalHeapSize>=(16 shl 20) then begin
    fBlockSize:=Min(Max(TpvUInt64(fDevice.MemoryManager.MaximumMemoryMappableDeviceLocalHeapSize shr 6),TpvUInt64(16 shl 20)),TpvUInt64(128 shl 20));
    fMemoryRequiredPropertyFlags:=TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT);
    fMemoryPreferredPropertyFlags:=TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
    fMemoryAvoidPropertyFlags:=0;
    fMemoryPreferredNotPropertyFlags:=0;
   end else begin
    fBlockSize:=16 shl 20; // 16MB
    fMemoryRequiredPropertyFlags:=TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT);
    fMemoryPreferredPropertyFlags:=TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
    fMemoryAvoidPropertyFlags:=0;
    fMemoryPreferredNotPropertyFlags:=0;
   end;
  end;
  else begin
   // And for other (mobile) GPUs, like for example Mali, Adreno and PowerVR
   fBlockSize:=8 shl 20; // 8MB
   fMemoryRequiredPropertyFlags:=TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT);
   fMemoryPreferredPropertyFlags:=TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
   fMemoryAvoidPropertyFlags:=0;
   fMemoryPreferredNotPropertyFlags:=0;
  end;
 end;

 fLock:=TPasMPSlimReaderWriterLock.Create;

 fBlocks:=TBlocks.Create(true);

 fQueueItems:=TQueueItems.Create;

 fCurrentBlockIndex:=-1;

 fOffset:=0;

end;

destructor TpvTransferQueue.Destroy;
begin
 FreeAndNil(fBlocks);
 FreeAndNil(fQueueItems);
 FreeAndNil(fLock);
 inherited Destroy;
end;

procedure TpvTransferQueue.Reset;
var Index:TpvSizeInt;
begin
 fQueueItems.ClearNoFree;
 fCurrentBlockIndex:=-1;
 fOffset:=0;
end;

procedure TpvTransferQueue.Queue(const aTransferQueue:TpvVulkanQueue;
                                 const aTransferCommandBuffer:TpvVulkanCommandBuffer;
                                 const aTransferFence:TpvVulkanFence;
                                 const aSourceData;
                                 const aDestinationBuffer:TpvVulkanBuffer;
                                 const aDestinationOffset:TpvSizeInt;
                                 const aSize:TpvSizeInt);
var QueueItem:TpvTransferQueue.PQueueItem;
    Block:TpvTransferQueue.TBlock;
    SourceRemain,SourceOffset,ToDo:TpvSizeInt;
begin

 if aSize>0 then begin

  fLock.Acquire;
  try

   SourceRemain:=aSize;
   SourceOffset:=0;

   while SourceRemain>0 do begin

    if (fCurrentBlockIndex<0) or (fOffset>=fBlockSize) then begin
     inc(fCurrentBlockIndex);
     if fCurrentBlockIndex>=fBlocks.Count then begin
      fCurrentBlockIndex:=fBlocks.Add(TpvTransferQueue.TBlock.Create(self));
     end;
     fOffset:=0;
    end;    

    Block:=fBlocks[fCurrentBlockIndex];

    ToDo:=fBlockSize-fOffset;
    if ToDo>SourceRemain then begin
     ToDo:=SourceRemain;
    end;

    QueueItem:=Pointer(fQueueItems.AddNew);
    QueueItem^.SourceBlock:=Block;
    QueueItem^.SourceOffset:=fOffset;
    QueueItem^.DestinationBuffer:=aDestinationBuffer;
    QueueItem^.DestinationOffset:=aDestinationOffset+SourceOffset;
    QueueItem^.Size:=ToDo;

    fDevice.MemoryStaging.Upload(aTransferQueue,
                                 aTransferCommandBuffer,
                                 aTransferFence,
                                 pointer(TpvPtrUInt(TpvPtrUInt(@aSourceData)+TpvPtrUInt(SourceOffset)))^,
                                 Block.fBuffer,
                                 fOffset,
                                 ToDo);

    inc(fOffset,ToDo);

    dec(SourceRemain,ToDo);
    
    inc(SourceOffset,ToDo);

   end; 

  finally
   fLock.Release;
  end;

 end;

end;

function TpvTransferQueueFlushCompareQueueItems(const a,b:TpvTransferQueue.TQueueItem):TpvInt32;
begin
 if TpvPtrUInt(a.DestinationBuffer)<TpvPtrUInt(b.DestinationBuffer) then begin
  result:=-1;
 end else if TpvPtrUInt(a.DestinationBuffer)>TpvPtrUInt(b.DestinationBuffer) then begin
  result:=1;
 end else begin
  if a.DestinationOffset<b.DestinationOffset then begin
   result:=-1;
  end else if a.DestinationOffset>b.DestinationOffset then begin
   result:=1;
  end else begin
   result:=0;
  end;
 end;
end;

procedure TpvTransferQueue.Flush(aCommandBuffer:TpvVulkanCommandBuffer);
var Index:TpvSizeInt;
    QueueItem,OtherQueueItem:PQueueItem;
    MemoryBarrier:TVkMemoryBarrier;
    Region:TVkBufferCopy;
begin

 fLock.Acquire;
 try

  if fQueueItems.Count>0 then begin

   // Using a memory barrier to ensure that all previous host writes are visible to the transfer queue, where
   // a global memory barrier is using here for simplicity, but it could be more fine-grained with buffer
   // memory barriers, but it would be more complex, since we would need to track all used buffers and their
   // usage flags and so on. So we use a global memory barrier here just for the sake of simplicity, so long
   // as it works. Indeed, vkQueueSubmit() already has also an implicit host memory barrier, but safe is safe.
   MemoryBarrier.sType:=VK_STRUCTURE_TYPE_MEMORY_BARRIER;
   MemoryBarrier.pNext:=nil;
   MemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_HOST_WRITE_BIT) or
                                TVkAccessFlags(VK_ACCESS_HOST_READ_BIT) or
                                TVkAccessFlags(VK_ACCESS_MEMORY_WRITE_BIT) or
                                TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT);
   MemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT) or
                                TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT),
                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                     0,
                                     1,
                                     @MemoryBarrier,
                                     0,
                                     nil,
                                     0,
                                     nil);

   // If there are more than one transfer commands, we can sort and merge them
   if fQueueItems.Count>1 then begin

    // Sort all transfer commands by destination buffer and destination offset
    TpvTypedSort<TpvTransferQueue.TQueueItem>.IntroSort(@fQueueItems.ItemArray[0],0,fQueueItems.Count-1,TpvTransferQueueFlushCompareQueueItems);

    // Merge all transfer commands into one single commands as much as possible for better performance
    Index:=0;
    while (Index+1)<fQueueItems.Count do begin
     QueueItem:=@fQueueItems.ItemArray[Index];
     OtherQueueItem:=@fQueueItems.ItemArray[Index+1];
     if (QueueItem^.SourceBlock=OtherQueueItem^.SourceBlock) and
        ((QueueItem^.SourceOffset+QueueItem^.Size)=OtherQueueItem^.SourceOffset) and
        (QueueItem^.DestinationBuffer=OtherQueueItem^.DestinationBuffer) and
        ((QueueItem^.DestinationOffset+QueueItem^.Size)=OtherQueueItem^.DestinationOffset) then begin
      inc(QueueItem^.Size,OtherQueueItem^.Size);
      fQueueItems.Delete(Index+1);
     end else begin
      inc(Index);
     end;
    end;

   end;

   // Execute the actual transfer commands
   for Index:=0 to fQueueItems.Count-1 do begin
    QueueItem:=@fQueueItems.ItemArray[Index];
    if QueueItem^.Size>0 then begin
     Region.srcOffset:=QueueItem^.SourceOffset;
     Region.dstOffset:=QueueItem^.DestinationOffset;
     Region.size:=QueueItem^.Size;
     aCommandBuffer.CmdCopyBuffer(QueueItem^.SourceBlock.fBuffer.Handle,
                                  QueueItem^.DestinationBuffer.Handle,
                                  1,
                                  @Region);
    end;
   end;

   // Using a memory barrier to ensure that all previous transfer writes are visible to the rest of the GPU, where
   // a global memory barrier is using here for simplicity as well, for the reasons mentioned above.
   MemoryBarrier.sType:=VK_STRUCTURE_TYPE_MEMORY_BARRIER;
   MemoryBarrier.pNext:=nil;
   MemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT) or
                                TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
   MemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT) or
                                TVkAccessFlags(VK_ACCESS_INDEX_READ_BIT) or
                                TVkAccessFlags(VK_ACCESS_UNIFORM_READ_BIT) or
                                TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or
                                TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT) or
                                TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or
                                TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT) or
                                TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT) or
                                TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT) or
                                TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT) or
                                TVkAccessFlags(VK_ACCESS_HOST_READ_BIT) or
                                TVkAccessFlags(VK_ACCESS_HOST_WRITE_BIT) or
                                TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT) or
                                TVkAccessFlags(VK_ACCESS_MEMORY_WRITE_BIT);
   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT),
                                     0,
                                     1,
                                     @MemoryBarrier,
                                     0,
                                     nil,
                                     0,
                                     nil);

   fQueueItems.ClearNoFree;
   fCurrentBlockIndex:=-1;
   fOffset:=0;

  end;

 finally
  fLock.Release;
 end;

end;

procedure TpvTransferQueue.Execute(const aTransferQueue:TpvVulkanQueue;const aTransferCommandBuffer:TpvVulkanCommandBuffer;const aTransferFence:TpvVulkanFence);
begin
 
 aTransferCommandBuffer.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));
 aTransferCommandBuffer.BeginRecording;

 Flush(aTransferCommandBuffer);

 aTransferCommandBuffer.EndRecording;

 aTransferCommandBuffer.Execute(aTransferQueue,TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),nil,nil,aTransferFence,true);

end; 
 
end.
