(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                        Version 2018-04-22-22-26-0000                       *
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
unit PasVulkan.FramebufferCapture;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

uses SysUtils,Classes,SyncObjs,Math,{$ifdef fpc}dynlibs,{$endif}
     PasMP,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Collections,
     PasVulkan.Framework;

type EpvFramebufferCapture=class(Exception);

     { TpvFramebufferCapture }
     TpvFramebufferCapture=class
      public
       type TImage=record
             Width:TpvInt32;
             Height:TpvInt32;
             Data:TVkUInt8Array;
            end;          
            PImage=^TImage;
      private
       fSwapChain:TpvVulkanSwapChain;
       fDevice:TpvVulkanDevice;
       fNeedTwoSteps:boolean;
       fCopyOnly:boolean;
       fBlitSupported:boolean;
       fNeedColorSwizzle:boolean;
       fSrcColorFormatProperties:TVkFormatProperties;
       fDstColorFormatProperties:TVkFormatProperties;
       fMemoryRequirements:TVkMemoryRequirements;
       fFirstImage:TpvVulkanImage;
       fSecondImage:TpvVulkanImage;
       fFirstMemoryBlock:TpvVulkanDeviceMemoryBlock;
       fSecondMemoryBlock:TpvVulkanDeviceMemoryBlock;
       fImageMemoryBarriers:array[0..2] of TVkImageMemoryBarrier;
       fSrcStages:TVkPipelineStageFlags;
       fDstStages:TVkPipelineStageFlags;
       fImageBlit:TVkImageBlit;
       fImageCopy:TVkImageCopy;
       fImageSubresource:TVkImageSubresource;
       fSubresourceLayout:TVkSubresourceLayout;
       fDestColorFormat:TVkFormat;
       fQueue:TpvVulkanQueue;
       fCommandPool:TpvVulkanCommandPool;
       fCommandBuffer:TpvVulkanCommandBuffer;
       fFence:TpvVulkanFence;
       fWidth:TpvSizeInt;
       fHeight:TpvSizeInt;
       fImageFormat:TVkFormat;
       fReady:boolean;
       procedure AllocateResources;
       procedure ReleaseResources;
       procedure SetSwapChain(const aSwapChain:TpvVulkanSwapChain);
      public
       constructor Create(const aSwapChain:TpvVulkanSwapChain);
       destructor Destroy; override;
       function Compatible(const aSwapChain:TpvVulkanSwapChain):boolean;
       procedure Capture(var aImage:TpvFramebufferCapture.TImage;const aSwapChainImage:TpvVulkanImage=nil);
      published 
       property Width:TpvSizeInt read fWidth;
       property Height:TpvSizeInt read fHeight;
       property SwapChain:TpvVulkanSwapChain read fSwapChain write SetSwapChain;
     end;

implementation

uses PasVulkan.Application;

{ TpvFramebufferCapture }

constructor TpvFramebufferCapture.Create(const aSwapChain:TpvVulkanSwapChain);
begin
 inherited Create;

 fSwapChain:=aSwapChain;

 fDevice:=fSwapChain.Device;

 AllocateResources;

end;

destructor TpvFramebufferCapture.Destroy;
begin

 ReleaseResources;

 inherited Destroy;

end;

procedure TpvFramebufferCapture.AllocateResources;
var RequiresDedicatedAllocation:boolean;
    PrefersDedicatedAllocation:boolean;
    MemoryBlockFlags:TpvVulkanDeviceMemoryBlockFlags;
begin

 if not fReady then begin

  fDevice:=fSwapChain.Device;
  
  fWidth:=fSwapChain.Width;
  
  fHeight:=fSwapChain.Height;
  
  fImageFormat:=fSwapChain.ImageFormat;
  
  fSrcColorFormatProperties:=fDevice.PhysicalDevice.GetFormatProperties(fImageFormat);
  
  if fImageFormat in [VK_FORMAT_R8G8B8A8_SRGB,VK_FORMAT_B8G8R8A8_SRGB] then begin
   fDestColorFormat:=VK_FORMAT_R8G8B8A8_SRGB;
  end else begin
   fDestColorFormat:=VK_FORMAT_R8G8B8A8_UNORM;
  end;
  
  fDstColorFormatProperties:=fDevice.PhysicalDevice.GetFormatProperties(fDestColorFormat);
  
  fBlitSupported:=((fSrcColorFormatProperties.optimalTilingFeatures and TVkFormatFeatureFlags(VK_FORMAT_FEATURE_BLIT_SRC_BIT))<>0) and
                  ((fDstColorFormatProperties.optimalTilingFeatures and TVkFormatFeatureFlags(VK_FORMAT_FEATURE_BLIT_DST_BIT))<>0);
  
  fNeedTwoSteps:=(fImageFormat<>fDestColorFormat) and
                 (((fDstColorFormatProperties.linearTilingFeatures and TVkFormatFeatureFlags(VK_FORMAT_FEATURE_BLIT_DST_BIT))=0) and
                  ((fDstColorFormatProperties.optimalTilingFeatures and TVkFormatFeatureFlags(VK_FORMAT_FEATURE_BLIT_DST_BIT))<>0));
  
  fCopyOnly:=(fImageFormat=fDestColorFormat) or
             (((fDstColorFormatProperties.linearTilingFeatures or fDstColorFormatProperties.optimalTilingFeatures) and TVkFormatFeatureFlags(VK_FORMAT_FEATURE_BLIT_DST_BIT))=0);
  
  fFirstImage:=TpvVulkanImage.Create(fDevice,
                                     0,
                                     VK_IMAGE_TYPE_2D,
                                     fDestColorFormat,
                                     fWidth,
                                     fHeight,
                                     1,
                                     1,
                                     1,
                                     VK_SAMPLE_COUNT_1_BIT,
                                     TVkImageTiling(TpvInt32(IfThen(fNeedTwoSteps,
                                                                    TpvInt32(VK_IMAGE_TILING_OPTIMAL),
                                                                    TpvInt32(VK_IMAGE_TILING_LINEAR)))),
                                     IfThen(fNeedTwoSteps,
                                            TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT),
                                            TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT)),
                                     VK_SHARING_MODE_EXCLUSIVE,
                                     [],
                                     VK_IMAGE_LAYOUT_UNDEFINED);

  fMemoryRequirements:=fDevice.MemoryManager.GetImageMemoryRequirements(fFirstImage.Handle,
                                                                        RequiresDedicatedAllocation,
                                                                        PrefersDedicatedAllocation);

  MemoryBlockFlags:=[];

  if RequiresDedicatedAllocation then begin
   Include(MemoryBlockFlags,TpvVulkanDeviceMemoryBlockFlag.DedicatedAllocation);
  end else if PrefersDedicatedAllocation then begin
   Include(MemoryBlockFlags,TpvVulkanDeviceMemoryBlockFlag.PreferDedicatedAllocation);
  end;

  if fNeedTwoSteps then begin
   fFirstMemoryBlock:=fDevice.MemoryManager.AllocateMemoryBlock(MemoryBlockFlags,
                                                                fMemoryRequirements.size,
                                                                fMemoryRequirements.alignment,
                                                                fMemoryRequirements.memoryTypeBits,
                                                                TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                0,
                                                                0,
                                                                0,
                                                                0,
                                                                0,
                                                                0,
                                                                0,
                                                                TpvVulkanDeviceMemoryAllocationType.ImageOptimal,
                                                                @fFirstImage.Handle,
                                                                pvAllocationGroupIDScreenShot);
  end else begin
   fFirstMemoryBlock:=fDevice.MemoryManager.AllocateMemoryBlock([TpvVulkanDeviceMemoryBlockFlag.PersistentMapped]+MemoryBlockFlags,
                                                                fMemoryRequirements.size,
                                                                fMemoryRequirements.alignment,
                                                                fMemoryRequirements.memoryTypeBits,
                                                                TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_CACHED_BIT),
                                                                0,
                                                                TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                0,
                                                                0,
                                                                0,
                                                                0,
                                                                TpvVulkanDeviceMemoryAllocationType.ImageLinear,
                                                                @fFirstImage.Handle,
                                                                pvAllocationGroupIDScreenShot);
  end;

  if not assigned(fFirstMemoryBlock) then begin
   raise EpvVulkanMemoryAllocationException.Create('Memory for screenshot couldn''t be allocated!');
  end;

  VulkanCheckResult(fDevice.Commands.BindImageMemory(fDevice.Handle,fFirstImage.Handle,fFirstMemoryBlock.MemoryChunk.Handle,fFirstMemoryBlock.Offset));

  if fNeedTwoSteps then begin
   fSecondImage:=TpvVulkanImage.Create(fDevice,
                                       0,
                                       VK_IMAGE_TYPE_2D,
                                       fDestColorFormat,
                                       fWidth,
                                       fHeight,
                                       1,
                                       1,
                                       1,
                                       VK_SAMPLE_COUNT_1_BIT,
                                       VK_IMAGE_TILING_LINEAR,
                                       TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT),
                                       VK_SHARING_MODE_EXCLUSIVE,
                                       [],
                                       VK_IMAGE_LAYOUT_UNDEFINED);
  end else begin
   fSecondImage:=nil;
  end;

  if assigned(fSecondImage) then begin

   fMemoryRequirements:=fDevice.MemoryManager.GetImageMemoryRequirements(fSecondImage.Handle,
                                                                         RequiresDedicatedAllocation,
                                                                         PrefersDedicatedAllocation);

   MemoryBlockFlags:=[TpvVulkanDeviceMemoryBlockFlag.PersistentMapped];

   if RequiresDedicatedAllocation or PrefersDedicatedAllocation then begin
    Include(MemoryBlockFlags,TpvVulkanDeviceMemoryBlockFlag.DedicatedAllocation);
   end;

   fSecondMemoryBlock:=fDevice.MemoryManager.AllocateMemoryBlock(MemoryBlockFlags,
                                                                 fMemoryRequirements.size,
                                                                 fMemoryRequirements.alignment,
                                                                 fMemoryRequirements.memoryTypeBits,
                                                                 TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                 TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_CACHED_BIT),
                                                                 0,
                                                                 TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                 0,
                                                                 0,
                                                                 0,
                                                                 0,
                                                                 TpvVulkanDeviceMemoryAllocationType.ImageLinear,
                                                                 @fSecondImage.Handle,
                                                                 pvAllocationGroupIDScreenShot);

  end else begin

   fSecondMemoryBlock:=nil;

  end;

  if assigned(fSecondImage) then begin

   if not assigned(fSecondMemoryBlock) then begin
    raise EpvVulkanMemoryAllocationException.Create('Memory for screenshot couldn''t be allocated!');
   end;

   VulkanCheckResult(fDevice.Commands.BindImageMemory(fDevice.Handle,fSecondImage.Handle,fSecondMemoryBlock.MemoryChunk.Handle,fSecondMemoryBlock.Offset));

  end;

  fCommandPool:=TpvVulkanCommandPool.Create(fDevice,
                                            fDevice.GraphicsQueueFamilyIndex,
                                            TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

  fCommandBuffer:=TpvVulkanCommandBuffer.Create(fCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

  fFence:=TpvVulkanFence.Create(fDevice);

  fReady:=true;

 end;

end;

procedure TpvFramebufferCapture.ReleaseResources;
begin

 if fReady then begin

  fReady:=false;

  FreeAndNil(fFence);

  FreeAndNil(fCommandBuffer);

  FreeAndNil(fCommandPool);

  FreeAndNil(fSecondMemoryBlock);

  FreeAndNil(fSecondImage);

  FreeAndNil(fFirstMemoryBlock);

  FreeAndNil(fFirstImage);

  fDevice:=nil;

  fWidth:=0;

  fHeight:=0;

  fImageFormat:=VK_FORMAT_UNDEFINED;

  fDestColorFormat:=VK_FORMAT_UNDEFINED;

  fSwapChain:=nil;

  fReady:=false;

 end;

end;

function TpvFramebufferCapture.Compatible(const aSwapChain:TpvVulkanSwapChain):boolean;
begin
 result:=(fSwapChain=aSwapChain) and
         (fWidth=aSwapChain.Width) and
         (fHeight=aSwapChain.Height) and
         (fImageFormat=aSwapChain.ImageFormat);
end;

procedure TpvFramebufferCapture.SetSwapChain(const aSwapChain:TpvVulkanSwapChain);
begin
 if (fSwapChain<>aSwapChain) or (assigned(fSwapChain) and not Compatible(fSwapChain)) then begin
  if assigned(fSwapChain) then begin
   if Compatible(aSwapChain) then begin
    fSwapChain:=aSwapChain;
   end else begin 
    ReleaseResources;
    fSwapChain:=aSwapChain;
    AllocateResources;
   end;  
  end else begin
   raise EpvFramebufferCapture.Create('Swap chain is nil');
  end;
 end;
end;

procedure TpvFramebufferCapture.Capture(var aImage:TpvFramebufferCapture.TImage;const aSwapChainImage:TpvVulkanImage=nil);
var Size,Index,y:TpvSizeInt;
    p,pp:PpvUInt32;
    Pixel:TpvUInt32;
    SwapChainImageHandle:TVkImage;
    MappedMemoryRange:TVkMappedMemoryRange;
begin
 
 if not fReady then begin
  AllocateResources;
 end else if not Compatible(fSwapChain) then begin
  ReleaseResources;
  AllocateResources;
 end;

 if assigned(aSwapChainImage) then begin
  SwapChainImageHandle:=aSwapChainImage.Handle;
 end else begin
  SwapChainImageHandle:=fSwapChain.CurrentImage.Handle;
 end;

 fDevice.GraphicsQueue.WaitIdle; 

 fDevice.WaitIdle;

 Size:=fWidth*fHeight*SizeOf(TpvUInt8)*4;

 aImage.Width:=fWidth;
 aImage.Height:=fHeight;

 if length(aImage.Data)<>Size then begin
  SetLength(aImage.Data,Size);
 end;
 
 // PresentImageMemoryBarrier
 FillChar(fImageMemoryBarriers[0],SizeOf(TVkImageMemoryBarrier),#0);
 fImageMemoryBarriers[0].sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
 fImageMemoryBarriers[0].pNext:=nil;
 fImageMemoryBarriers[0].srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
 fImageMemoryBarriers[0].dstAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
 fImageMemoryBarriers[0].oldLayout:=VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
 fImageMemoryBarriers[0].newLayout:=VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
 fImageMemoryBarriers[0].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 fImageMemoryBarriers[0].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 fImageMemoryBarriers[0].image:=SwapChainImageHandle;
 fImageMemoryBarriers[0].subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
 fImageMemoryBarriers[0].subresourceRange.baseMipLevel:=0;
 fImageMemoryBarriers[0].subresourceRange.levelCount:=1;
 fImageMemoryBarriers[0].subresourceRange.baseArrayLayer:=0;
 fImageMemoryBarriers[0].subresourceRange.layerCount:=1;

 // DestImageMemoryBarrier
 FillChar(fImageMemoryBarriers[1],SizeOf(TVkImageMemoryBarrier),#0);
 fImageMemoryBarriers[1].sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
 fImageMemoryBarriers[1].pNext:=nil;
 fImageMemoryBarriers[1].srcAccessMask:=TVkAccessFlags(0);
 fImageMemoryBarriers[1].dstAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
 fImageMemoryBarriers[1].oldLayout:=VK_IMAGE_LAYOUT_UNDEFINED;
 fImageMemoryBarriers[1].newLayout:=VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
 fImageMemoryBarriers[1].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 fImageMemoryBarriers[1].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 fImageMemoryBarriers[1].image:=fFirstImage.Handle;
 fImageMemoryBarriers[1].subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
 fImageMemoryBarriers[1].subresourceRange.baseMipLevel:=0;
 fImageMemoryBarriers[1].subresourceRange.levelCount:=1;
 fImageMemoryBarriers[1].subresourceRange.baseArrayLayer:=0;
 fImageMemoryBarriers[1].subresourceRange.layerCount:=1;

 // GeneralImageMemoryBarrier
 FillChar(fImageMemoryBarriers[2],SizeOf(TVkImageMemoryBarrier),#0);
 fImageMemoryBarriers[2].sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
 fImageMemoryBarriers[2].pNext:=nil;
 fImageMemoryBarriers[2].srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
 fImageMemoryBarriers[2].dstAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
 fImageMemoryBarriers[2].oldLayout:=VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
 fImageMemoryBarriers[2].newLayout:=VK_IMAGE_LAYOUT_GENERAL;
 fImageMemoryBarriers[2].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 fImageMemoryBarriers[2].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 fImageMemoryBarriers[2].image:=fFirstImage.Handle;
 fImageMemoryBarriers[2].subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
 fImageMemoryBarriers[2].subresourceRange.baseMipLevel:=0;
 fImageMemoryBarriers[2].subresourceRange.levelCount:=1;
 fImageMemoryBarriers[2].subresourceRange.baseArrayLayer:=0;
 fImageMemoryBarriers[2].subresourceRange.layerCount:=1;

 fSrcStages:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT);
 fDstStages:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT);

 fQueue:=fDevice.GraphicsQueue;

 fCommandBuffer.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));
 fCommandBuffer.BeginRecording;

 fCommandBuffer.CmdPipelineBarrier(fSrcStages,
                                   fDstStages,
                                   0,
                                   0,nil,
                                   0,nil,
                                   2,@fImageMemoryBarriers[0]);
 
 FillChar(fImageCopy,SizeOf(TVkImageCopy),#0);
 fImageCopy.srcSubresource.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
 fImageCopy.srcSubresource.mipLevel:=0;
 fImageCopy.srcSubresource.baseArrayLayer:=0;
 fImageCopy.srcSubresource.layerCount:=1;
 fImageCopy.dstSubresource.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
 fImageCopy.dstSubresource.mipLevel:=0;
 fImageCopy.dstSubresource.baseArrayLayer:=0;
 fImageCopy.dstSubresource.layerCount:=1;
 fImageCopy.extent.width:=fWidth;
 fImageCopy.extent.height:=fHeight;
 fImageCopy.extent.depth:=1;

 if fCopyOnly then begin

  fCommandBuffer.CmdCopyImage(SwapChainImageHandle,VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                              fFirstImage.Handle,VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                              1,@fImageCopy);

 end else begin

  FillChar(fImageBlit,SizeOf(TVkImageBlit),#0);
  fImageBlit.srcSubresource.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  fImageBlit.srcSubresource.mipLevel:=0;
  fImageBlit.srcSubresource.baseArrayLayer:=0;
  fImageBlit.srcSubresource.layerCount:=1;
  fImageBlit.srcOffsets[0].x:=0;
  fImageBlit.srcOffsets[0].y:=0;
  fImageBlit.srcOffsets[0].z:=0;
  fImageBlit.srcOffsets[1].x:=fWidth;
  fImageBlit.srcOffsets[1].y:=fHeight;
  fImageBlit.srcOffsets[1].z:=1;
  fImageBlit.dstSubresource.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  fImageBlit.dstSubresource.mipLevel:=0;
  fImageBlit.dstSubresource.baseArrayLayer:=0;
  fImageBlit.dstSubresource.layerCount:=1;
  fImageBlit.dstOffsets[0].x:=0;
  fImageBlit.dstOffsets[0].y:=0;
  fImageBlit.dstOffsets[0].z:=0;
  fImageBlit.dstOffsets[1].x:=fWidth;
  fImageBlit.dstOffsets[1].y:=fHeight;
  fImageBlit.dstOffsets[1].z:=1;
  fCommandBuffer.CmdBlitImage(SwapChainImageHandle,VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                              fFirstImage.Handle,VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                              1,@fImageBlit,
                              VK_FILTER_NEAREST);

  if fNeedTwoSteps then begin

   fImageMemoryBarriers[1].image:=fSecondImage.Handle;
   fCommandBuffer.CmdPipelineBarrier(fSrcStages,
                                     fDstStages,
                                     0,
                                     0,nil,
                                     0,nil,
                                     1,@fImageMemoryBarriers[1]);

   fImageMemoryBarriers[1].srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
   fImageMemoryBarriers[1].dstAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
   fImageMemoryBarriers[1].oldLayout:=VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
   fImageMemoryBarriers[1].newLayout:=VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
   fImageMemoryBarriers[1].image:=fFirstImage.Handle;
   fCommandBuffer.CmdPipelineBarrier(fSrcStages,
                                     fDstStages,
                                     0,
                                     0,nil,
                                     0,nil,
                                     1,@fImageMemoryBarriers[1]);

   fCommandBuffer.CmdCopyImage(fFirstImage.Handle,VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                               fSecondImage.Handle,VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                               1,@fImageCopy);
   fImageMemoryBarriers[2].image:=fSecondImage.Handle;

  end;

 end;

 fCommandBuffer.CmdPipelineBarrier(fSrcStages,
                                   fDstStages,
                                   0,
                                   0,nil,
                                   0,nil,
                                   1,@fImageMemoryBarriers[2]);

 fImageMemoryBarriers[0].srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
 fImageMemoryBarriers[0].dstAccessMask:=TVkAccessFlags(0);
 fImageMemoryBarriers[0].oldLayout:=VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
 fImageMemoryBarriers[0].newLayout:=VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;

 fCommandBuffer.CmdPipelineBarrier(fSrcStages,
                                   fDstStages,
                                   0,
                                   0,nil,
                                   0,nil,
                                   1,@fImageMemoryBarriers[0]);

 fCommandBuffer.EndRecording;

 fCommandBuffer.Execute(fQueue,0,nil,nil,fFence,true);

 fQueue.WaitIdle;

 fDevice.WaitIdle;

 FillChar(fImageSubresource,SizeOf(TVkImageSubresource),#0);
 fImageSubresource.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
 fImageSubresource.mipLevel:=0;
 fImageSubresource.arrayLayer:=0;

 fSubresourceLayout.offset:=0;

 if fNeedTwoSteps then begin
  fDevice.Commands.GetImageSubresourceLayout(fDevice.Handle,fSecondImage.Handle,@fImageSubresource,@fSubresourceLayout);
  if (fSecondMemoryBlock.MemoryChunk.MemoryPropertyFlags and TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_CACHED_BIT))=0 then begin
   MappedMemoryRange:=TVkMappedMemoryRange.Create(fSecondMemoryBlock.MemoryChunk.Handle,0,VK_WHOLE_SIZE);
   fDevice.Commands.InvalidateMappedMemoryRanges(fDevice.Handle,1,@MappedMemoryRange);
  end;
  p:=fSecondMemoryBlock.MapMemory(0,fSecondMemoryBlock.Size);
 end else begin
  fDevice.Commands.GetImageSubresourceLayout(fDevice.Handle,fFirstImage.Handle,@fImageSubresource,@fSubresourceLayout);
  if (fFirstMemoryBlock.MemoryChunk.MemoryPropertyFlags and TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_CACHED_BIT))=0 then begin
   MappedMemoryRange:=TVkMappedMemoryRange.Create(fFirstMemoryBlock.MemoryChunk.Handle,0,VK_WHOLE_SIZE);
   fDevice.Commands.InvalidateMappedMemoryRanges(fDevice.Handle,1,@MappedMemoryRange);
  end;
  p:=fFirstMemoryBlock.MapMemory(0,fFirstMemoryBlock.Size);
 end;

 if assigned(p) then begin
 
  try

   inc(p,fSubresourceLayout.offset);

   fNeedColorSwizzle:=(not fBlitSupported) and (fImageFormat in [VK_FORMAT_B8G8R8A8_SRGB,VK_FORMAT_B8G8R8A8_UNORM,VK_FORMAT_B8G8R8A8_SNORM]);

   pp:=@aImage.Data[0];
   if (SizeOf(TpvUInt32)*fWidth)=fSubresourceLayout.rowPitch then begin
    Move(p^,pp^,SizeOf(TpvUInt32)*fWidth*fHeight);
   end else begin
    for y:=0 to fHeight-1 do begin
     Move(p^,pp^,SizeOf(TpvUInt32)*fWidth);
     inc(p,fSubresourceLayout.rowPitch);
     inc(pp,SizeOf(TpvUInt32)*fWidth);
    end;
   end;

  finally
   if fNeedTwoSteps then begin
    fSecondMemoryBlock.UnmapMemory;
   end else begin
    fFirstMemoryBlock.UnmapMemory;
   end;
  end;

 end; 

 p:=Pointer(@aImage.Data[0]);
 if fNeedColorSwizzle then begin
  for Index:=0 to TpvSizeInt(fWidth*fHeight)-1 do begin
   Pixel:=p^;
   p^:=((Pixel and $00ff0000) shr 16) or
       ((Pixel and $000000ff) shl 16) or
       (Pixel and $0000ff00) or
       TpvUInt32($ff000000);
   inc(p);
  end;
 end else begin
  for Index:=0 to TpvSizeInt(fWidth*fHeight)-1 do begin
   p^:=p^ or TpvUInt32($ff000000);
   inc(p);
  end;
 end;

end; 

end.

