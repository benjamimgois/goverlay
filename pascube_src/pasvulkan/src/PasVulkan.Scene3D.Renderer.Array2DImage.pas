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
unit PasVulkan.Scene3D.Renderer.Array2DImage;
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
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application;

type { TpvScene3DRendererArray2DImage }
     TpvScene3DRendererArray2DImage=class
      private
       fVulkanImage:TpvVulkanImage;
       fVulkanImageView:TpvVulkanImageView;
       fVulkanArrayImageView:TpvVulkanImageView;
       fVulkanOtherArrayImageView:TpvVulkanImageView;
       fMemoryBlock:TpvVulkanDeviceMemoryBlock;
       fWidth:TpvInt32;
       fHeight:TpvInt32;
       fLayers:TpvInt32;
       fFormat:TVkFormat;
      public

       constructor Create(const aDevice:TpvVulkanDevice;const aWidth,aHeight,aLayers:TpvInt32;const aFormat:TVkFormat;const aSampleBits:TVkSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT);const aImageLayout:TVkImageLayout=TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL);const aStorage:boolean=false;const aAllocationGroupID:TpvUInt64=0;const aOtherFormat:TVkFormat=VK_FORMAT_UNDEFINED;const aSharingMode:TVkSharingMode=TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE);const aQueueFamilyIndices:TpvVulkanQueueFamilyIndices=nil;const aName:TpvUTF8String='');

       destructor Destroy; override;

      published

       property VulkanImage:TpvVulkanImage read fVulkanImage;

       property VulkanArrayImageView:TpvVulkanImageView read fVulkanArrayImageView;

       property VulkanOtherArrayImageView:TpvVulkanImageView read fVulkanOtherArrayImageView;

       property VulkanImageView:TpvVulkanImageView read fVulkanImageView;

       property Width:TpvInt32 read fWidth;

       property Height:TpvInt32 read fHeight;

       property Layers:TpvInt32 read fLayers;

       property Format:TVkFormat read fFormat;

     end;

implementation

{ TpvScene3DRendererArray2DImage }

constructor TpvScene3DRendererArray2DImage.Create(const aDevice:TpvVulkanDevice;const aWidth,aHeight,aLayers:TpvInt32;const aFormat:TVkFormat;const aSampleBits:TVkSampleCountFlagBits;const aImageLayout:TVkImageLayout;const aStorage:boolean;const aAllocationGroupID:TpvUInt64;const aOtherFormat:TVkFormat;const aSharingMode:TVkSharingMode;const aQueueFamilyIndices:TpvVulkanQueueFamilyIndices;const aName:TpvUTF8String);
var MemoryRequirements:TVkMemoryRequirements;
    RequiresDedicatedAllocation,
    PrefersDedicatedAllocation:boolean;
    MemoryBlockFlags:TpvVulkanDeviceMemoryBlockFlags;
    ImageSubresourceRange:TVkImageSubresourceRange;
    Queue:TpvVulkanQueue;
    CommandPool:TpvVulkanCommandPool;
    CommandBuffer:TpvVulkanCommandBuffer;
    Fence:TpvVulkanFence;
    ImageViewType:TVkImageViewType;
    ImageAspectMask:TVkImageAspectFlags;
    p:pointer;
begin
 inherited Create;

 fWidth:=aWidth;

 fHeight:=aHeight;

 fLayers:=aLayers;

 fFormat:=aFormat;

 case aFormat of
  VK_FORMAT_D16_UNORM,
  VK_FORMAT_D16_UNORM_S8_UINT,
  VK_FORMAT_D24_UNORM_S8_UINT,
  VK_FORMAT_D32_SFLOAT,
  VK_FORMAT_D32_SFLOAT_S8_UINT:begin
   ImageAspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT);
  end;
  else begin
   ImageAspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  end;
 end;

 if aLayers>1 then begin
  ImageViewType:=TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D_ARRAY);
 end else begin
  ImageViewType:=TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D);
 end;

 if length(aQueueFamilyIndices)>0 then begin
  p:=@aQueueFamilyIndices[0];
 end else begin
  p:=nil;
 end;

 fVulkanImage:=TpvVulkanImage.Create(aDevice,
                                     IfThen(aOtherFormat<>VK_FORMAT_UNDEFINED,TVkImageCreateFlags(VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT),0), //TVkImageCreateFlags(VK_IMAGE_CREATE_2D_ARRAY_COMPATIBLE_BIT),
                                     VK_IMAGE_TYPE_2D,
                                     aFormat,
                                     aWidth,
                                     aHeight,
                                     1,
                                     1,
                                     aLayers,
                                     aSampleBits,
                                     VK_IMAGE_TILING_OPTIMAL,
                                     TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or
                                     IfThen(aStorage,TVkImageUsageFlags(VK_IMAGE_USAGE_STORAGE_BIT),0) or
                                     TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT) or
                                     TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT),
                                     aSharingMode,
                                     length(aQueueFamilyIndices),
                                     p,
                                     VK_IMAGE_LAYOUT_UNDEFINED,
                                     aOtherFormat
                                    );
 aDevice.DebugUtils.SetObjectName(fVulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererArray2DImage["'+aName+'"].fVulkanImage.Handle');

 MemoryRequirements:=aDevice.MemoryManager.GetImageMemoryRequirements(fVulkanImage.Handle,
                                                                      RequiresDedicatedAllocation,
                                                                      PrefersDedicatedAllocation);

 MemoryBlockFlags:=[];

 if RequiresDedicatedAllocation or PrefersDedicatedAllocation then begin
  Include(MemoryBlockFlags,TpvVulkanDeviceMemoryBlockFlag.DedicatedAllocation);
 end;

 fMemoryBlock:=aDevice.MemoryManager.AllocateMemoryBlock(MemoryBlockFlags,
                                                         MemoryRequirements.size,
                                                         MemoryRequirements.alignment,
                                                         MemoryRequirements.memoryTypeBits,
                                                         TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                         0,
                                                         0,
                                                         0,
                                                         0,
                                                         0,
                                                         0,
                                                         0,
                                                         TpvVulkanDeviceMemoryAllocationType.ImageOptimal,
                                                         @fVulkanImage.Handle,
                                                         aAllocationGroupID,
                                                         'TpvScene3DRendererArray2DImage["'+aName+'"].fMemoryBlock');
 if not assigned(fMemoryBlock) then begin
  raise EpvVulkanMemoryAllocationException.Create('Memory for texture couldn''t be allocated!');
 end;

 fMemoryBlock.AssociatedObject:=self;

 VulkanCheckResult(aDevice.Commands.BindImageMemory(aDevice.Handle,
                                                    fVulkanImage.Handle,
                                                    fMemoryBlock.MemoryChunk.Handle,
                                                    fMemoryBlock.Offset));

 Queue:=aDevice.GraphicsQueue;

 CommandPool:=TpvVulkanCommandPool.Create(aDevice,
                                          aDevice.GraphicsQueueFamilyIndex,
                                          TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
 try

  CommandBuffer:=TpvVulkanCommandBuffer.Create(CommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
  try

   Fence:=TpvVulkanFence.Create(aDevice);
   try

    FillChar(ImageSubresourceRange,SizeOf(TVkImageSubresourceRange),#0);
    ImageSubresourceRange.aspectMask:=ImageAspectMask;
    ImageSubresourceRange.baseMipLevel:=0;
    ImageSubresourceRange.levelCount:=1;
    ImageSubresourceRange.baseArrayLayer:=0;
    ImageSubresourceRange.layerCount:=aLayers;
    fVulkanImage.SetLayout(ImageAspectMask,
                           TVkImageLayout(VK_IMAGE_LAYOUT_UNDEFINED),
                           aImageLayout,
                           @ImageSubresourceRange,
                           CommandBuffer,
                           Queue,
                           Fence,
                           true);

    fVulkanImageView:=TpvVulkanImageView.Create(aDevice,
                                                fVulkanImage,
                                                ImageViewType,
                                                aFormat,
                                                TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                ImageAspectMask,
                                                0,
                                                1,
                                                0,
                                                aLayers);
    aDevice.DebugUtils.SetObjectName(fVulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererArray2DImage["'+aName+'"].fVulkanImageView.Handle');                                            

    fVulkanArrayImageView:=TpvVulkanImageView.Create(aDevice,
                                                     fVulkanImage,
                                                     TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D_ARRAY),
                                                     aFormat,
                                                     TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                     TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                     TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                     TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                     ImageAspectMask,
                                                     0,
                                                     1,
                                                     0,
                                                     aLayers);
    aDevice.DebugUtils.SetObjectName(fVulkanArrayImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererArray2DImage["'+aName+'"].fVulkanArrayImageView.Handle');

    if aOtherFormat<>VK_FORMAT_UNDEFINED then begin

     fVulkanOtherArrayImageView:=TpvVulkanImageView.Create(aDevice,
                                                           fVulkanImage,
                                                           TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D_ARRAY),
                                                           aOtherFormat,
                                                           TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                           TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                           TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                           TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                           ImageAspectMask,
                                                           0,
                                                           1,
                                                           0,
                                                           aLayers);
     aDevice.DebugUtils.SetObjectName(fVulkanOtherArrayImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererArray2DImage["'+aName+'"].fVulkanOtherArrayImageView.Handle');

    end else begin

     fVulkanOtherArrayImageView:=nil;

    end;

   finally
    FreeAndNil(Fence);
   end;

  finally
   FreeAndNil(CommandBuffer);
  end;

 finally
  FreeAndNil(CommandPool);
 end;

end;

destructor TpvScene3DRendererArray2DImage.Destroy;
begin
 FreeAndNil(fMemoryBlock);
 FreeAndNil(fVulkanArrayImageView);
 FreeAndNil(fVulkanOtherArrayImageView);
 FreeAndNil(fVulkanImageView);
 FreeAndNil(fVulkanImage);
 inherited Destroy;
end;

end.
