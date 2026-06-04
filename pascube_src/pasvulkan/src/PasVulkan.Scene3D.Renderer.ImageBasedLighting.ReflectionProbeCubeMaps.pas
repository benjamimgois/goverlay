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
unit PasVulkan.Scene3D.Renderer.ImageBasedLighting.ReflectionProbeCubeMaps;
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
     PasMP,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Scene3D.Renderer.Globals;

type { TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps }
     TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps=class
      public
       type TImages=array[0..MaxInFlightFrames-1] of TpvVulkanImage;
            TImageViews=array[0..MaxInFlightFrames-1,0..31] of TpvVulkanImageView;
            TDescriptorImageInfos=array[0..MaxInFlightFrames-1] of TVkDescriptorImageInfo;
      private
       fWidth:TpvInt32;
       fHeight:TpvInt32;
       fMipMaps:TpvInt32;
       fCountInFlightFrames:TpvInt32;
       fVulkanRawImages:TImages;
       fVulkanGGXImages:TImages;
       fVulkanCharlieImages:TImages;
       fVulkanLambertianImages:TImages;
       fRawImageViews:TImageViews;
       fGGXImageViews:TImageViews;
       fCharlieImageViews:TImageViews;
       fLambertianImageViews:TImageViews;
       fVulkanSampler:TpvVulkanSampler;
       fVulkanRawImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
       fVulkanGGXImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
       fVulkanCharlieImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
       fVulkanLambertianImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
       fRawMemoryBlocks:array[0..MaxInFlightFrames-1] of TpvVulkanDeviceMemoryBlock;
       fGGXMemoryBlocks:array[0..MaxInFlightFrames-1] of TpvVulkanDeviceMemoryBlock;
       fCharlieMemoryBlocks:array[0..MaxInFlightFrames-1] of TpvVulkanDeviceMemoryBlock;
       fLambertianMemoryBlocks:array[0..MaxInFlightFrames-1] of TpvVulkanDeviceMemoryBlock;
       fRawDescriptorImageInfos:TDescriptorImageInfos;
       fGGXDescriptorImageInfos:TDescriptorImageInfos;
       fCharlieDescriptorImageInfos:TDescriptorImageInfos;
       fLambertianDescriptorImageInfos:TDescriptorImageInfos;
      public

       constructor Create(const aVulkanDevice:TpvVulkanDevice;
                          const aVulkanSampler:TpvVulkanSampler;
                          const aWidth:TpvInt32;
                          const aHeight:TpvInt32;
                          const aCountInFlightFrames:TpvInt32;
                          const aImageFormat:TVkFormat=TVkFormat(VK_FORMAT_R16G16B16A16_SFLOAT));

       destructor Destroy; override;

      published

       property Width:TpvInt32 read fWidth;

       property Height:TpvInt32 read fHeight;

       property MipMaps:TpvInt32 read fMipMaps;

      public

       property RawImages:TImages read fVulkanRawImages;

       property GGXImages:TImages read fVulkanGGXImages;

       property CharlieImages:TImages read fVulkanCharlieImages;

       property LambertianImages:TImages read fVulkanLambertianImages;

       property RawImageViews:TImageViews read fRawImageViews;

       property GGXImageViews:TImageViews read fGGXImageViews;

       property CharlieImageViews:TImageViews read fCharlieImageViews;

       property LambertianImageViews:TImageViews read fLambertianImageViews;

       property RawDescriptorImageInfos:TDescriptorImageInfos read fRawDescriptorImageInfos;

       property GGXDescriptorImageInfos:TDescriptorImageInfos read fGGXDescriptorImageInfos;

       property CharlieDescriptorImageInfos:TDescriptorImageInfos read fCharlieDescriptorImageInfos;

       property LambertianDescriptorImageInfos:TDescriptorImageInfos read fLambertianDescriptorImageInfos;

     end;

implementation

{ TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps }

constructor TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.Create(const aVulkanDevice:TpvVulkanDevice;
                                                                               const aVulkanSampler:TpvVulkanSampler;        
                                                                               const aWidth:TpvInt32;
                                                                               const aHeight:TpvInt32;
                                                                               const aCountInFlightFrames:TpvInt32;
                                                                               const aImageFormat:TVkFormat=TVkFormat(VK_FORMAT_R16G16B16A16_SFLOAT));
type PpvVulkanImage=^TpvVulkanImage;
     PpvVulkanDeviceMemoryBlock=^TpvVulkanDeviceMemoryBlock;
var ImageIndex,InFlightFrameIndex,Index:TpvSizeInt;
    MemoryRequirements:TVkMemoryRequirements;
    RequiresDedicatedAllocation,
    PrefersDedicatedAllocation:boolean;
    MemoryBlockFlags:TpvVulkanDeviceMemoryBlockFlags;
    ImageSubresourceRange:TVkImageSubresourceRange;
    GraphicsQueue:TpvVulkanQueue;
    GraphicsCommandPool:TpvVulkanCommandPool;
    GraphicsCommandBuffer:TpvVulkanCommandBuffer;
    GraphicsFence:TpvVulkanFence;
//ImageMemoryBarrier:TVkImageMemoryBarrier;
    Images:array[0..MaxInFlightFrames-1,0..3] of PpvVulkanImage;
    MemoryBlocks:array[0..MaxInFlightFrames-1,0..3] of PpvVulkanDeviceMemoryBlock;
    Name:TpvUTF8String;
//  ImportanceSamples:TImportanceSamples;
begin
 inherited Create;

 fWidth:=aWidth;

 fHeight:=aHeight;

 fMipMaps:=IntLog2(Max(fWidth,fHeight))+1;

 fCountInFlightFrames:=aCountInFlightFrames;

 for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin

  Images[InFlightFrameIndex,0]:=@fVulkanRawImages[InFlightFrameIndex];
  Images[InFlightFrameIndex,1]:=@fVulkanGGXImages[InFlightFrameIndex];
  Images[InFlightFrameIndex,2]:=@fVulkanCharlieImages[InFlightFrameIndex];
  Images[InFlightFrameIndex,3]:=@fVulkanLambertianImages[InFlightFrameIndex];

  MemoryBlocks[InFlightFrameIndex,0]:=@fRawMemoryBlocks[InFlightFrameIndex];
  MemoryBlocks[InFlightFrameIndex,1]:=@fGGXMemoryBlocks[InFlightFrameIndex];
  MemoryBlocks[InFlightFrameIndex,2]:=@fCharlieMemoryBlocks[InFlightFrameIndex];
  MemoryBlocks[InFlightFrameIndex,3]:=@fLambertianMemoryBlocks[InFlightFrameIndex];

  for ImageIndex:=0 to 3 do begin

   Images[InFlightFrameIndex,ImageIndex]^:=TpvVulkanImage.Create(aVulkanDevice,
                                                                 TVkImageCreateFlags(VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT),
                                                                 VK_IMAGE_TYPE_2D,
                                                                 aImageFormat,
                                                                 fWidth,
                                                                 fHeight,
                                                                 1,
                                                                 fMipMaps,
                                                                 6,
                                                                 VK_SAMPLE_COUNT_1_BIT,
                                                                 VK_IMAGE_TILING_OPTIMAL,
                                                                 TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or
                                                                 TVkImageUsageFlags(VK_IMAGE_USAGE_STORAGE_BIT) or
                                                                 TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                                                 VK_SHARING_MODE_EXCLUSIVE,
                                                                 0,
                                                                 nil,
                                                                 VK_IMAGE_LAYOUT_UNDEFINED
                                                                );

   MemoryRequirements:=aVulkanDevice.MemoryManager.GetImageMemoryRequirements(Images[InFlightFrameIndex,ImageIndex]^.Handle,
                                                                              RequiresDedicatedAllocation,
                                                                              PrefersDedicatedAllocation);

   MemoryBlockFlags:=[];

   if RequiresDedicatedAllocation or PrefersDedicatedAllocation then begin
    Include(MemoryBlockFlags,TpvVulkanDeviceMemoryBlockFlag.DedicatedAllocation);
   end;

   case ImageIndex of
    0:begin
     Name:='TpScene3DRendererImageBasedLightingReflectionProbeCubeMaps.Raw.MemoryBlocks['+IntToStr(InFlightFrameIndex)+']';
    end;
    1:begin
     Name:='TpScene3DRendererImageBasedLightingReflectionProbeCubeMaps.GGX.MemoryBlocks['+IntToStr(InFlightFrameIndex)+']';
    end;
    2:begin
     Name:='TpScene3DRendererImageBasedLightingReflectionProbeCubeMaps.Charlie.MemoryBlocks['+IntToStr(InFlightFrameIndex)+']';
    end;
    else begin
     Name:='TpScene3DRendererImageBasedLightingReflectionProbeCubeMaps.Lambertian.MemoryBlocks['+IntToStr(InFlightFrameIndex)+']';
    end;
   end;

   MemoryBlocks[InFlightFrameIndex,ImageIndex]^:=aVulkanDevice.MemoryManager.AllocateMemoryBlock(MemoryBlockFlags,
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
                                                                                                 @Images[InFlightFrameIndex,ImageIndex]^.Handle,
                                                                                                 pvAllocationGroupIDScene3DTexture,
                                                                                                 Name);
   if not assigned(MemoryBlocks[InFlightFrameIndex,ImageIndex]^) then begin
    raise EpvVulkanMemoryAllocationException.Create('Memory for texture couldn''t be allocated!');
   end;

   MemoryBlocks[InFlightFrameIndex,ImageIndex]^.AssociatedObject:=self;

   VulkanCheckResult(aVulkanDevice.Commands.BindImageMemory(aVulkanDevice.Handle,
                                                            Images[InFlightFrameIndex,ImageIndex]^.Handle,
                                                            MemoryBlocks[InFlightFrameIndex,ImageIndex]^.MemoryChunk.Handle,
                                                            MemoryBlocks[InFlightFrameIndex,ImageIndex]^.Offset));

  end;

  aVulkanDevice.DebugUtils.SetObjectName(fVulkanRawImages[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.RawImages['+IntToStr(InFlightFrameIndex)+']');
  aVulkanDevice.DebugUtils.SetObjectName(fVulkanGGXImages[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.GGXImages['+IntToStr(InFlightFrameIndex)+']');
  aVulkanDevice.DebugUtils.SetObjectName(fVulkanCharlieImages[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.CharlieImages['+IntToStr(InFlightFrameIndex)+']');
  aVulkanDevice.DebugUtils.SetObjectName(fVulkanLambertianImages[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.LambertianImages['+IntToStr(InFlightFrameIndex)+']');

 end;

 GraphicsQueue:=aVulkanDevice.GraphicsQueue;

 GraphicsCommandPool:=TpvVulkanCommandPool.Create(aVulkanDevice,
                                                  aVulkanDevice.GraphicsQueueFamilyIndex,
                                                  TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
 try

  GraphicsCommandBuffer:=TpvVulkanCommandBuffer.Create(GraphicsCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
  try

   GraphicsFence:=TpvVulkanFence.Create(aVulkanDevice);
   try

    FillChar(ImageSubresourceRange,SizeOf(TVkImageSubresourceRange),#0);
    ImageSubresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
    ImageSubresourceRange.baseMipLevel:=0;
    ImageSubresourceRange.levelCount:=MipMaps;
    ImageSubresourceRange.baseArrayLayer:=0;
    ImageSubresourceRange.layerCount:=6;

    for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
     for ImageIndex:=0 to 2 do begin
      Images[InFlightFrameIndex,ImageIndex]^.SetLayout(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                       TVkImageLayout(VK_IMAGE_LAYOUT_UNDEFINED),
                                                       TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                       @ImageSubresourceRange,
                                                       GraphicsCommandBuffer,
                                                       GraphicsQueue,
                                                       GraphicsFence,
                                                       true);
     end;
    end;

{   fVulkanSampler:=TpvVulkanSampler.Create(aVulkanDevice,
                                            TVkFilter(VK_FILTER_LINEAR),
                                            TVkFilter(VK_FILTER_LINEAR),
                                            TVkSamplerMipmapMode(VK_SAMPLER_MIPMAP_MODE_LINEAR),
                                            TVkSamplerAddressMode(VK_SAMPLER_ADDRESS_MODE_REPEAT),
                                            TVkSamplerAddressMode(VK_SAMPLER_ADDRESS_MODE_REPEAT),
                                            TVkSamplerAddressMode(VK_SAMPLER_ADDRESS_MODE_REPEAT),
                                            0.0,
                                            false,
                                            1.0,
                                            false,
                                            TVkCompareOp(VK_COMPARE_OP_NEVER),
                                            0.0,
                                            MipMaps,
                                            TVkBorderColor(VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK),
                                            false);
    aVulkanDevice.DebugUtils.SetObjectName(fVulkanSampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.Sampler');}
    fVulkanSampler:=aVulkanSampler;

    for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin

     fVulkanRawImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(aVulkanDevice,
                                                                         fVulkanRawImages[InFlightFrameIndex],
                                                                         TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE),
                                                                         aImageFormat,
                                                                         TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                         TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                         TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                         TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                         TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                         0,
                                                                         MipMaps,
                                                                         0,
                                                                         6);
     aVulkanDevice.DebugUtils.SetObjectName(fVulkanRawImageViews[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.RawImageViews['+IntToStr(InFlightFrameIndex)+']');                                                                    

     fVulkanGGXImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(aVulkanDevice,
                                                                         fVulkanGGXImages[InFlightFrameIndex],
                                                                         TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE),
                                                                         aImageFormat,
                                                                         TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                         TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                         TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                         TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                         TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                         0,
                                                                         MipMaps,
                                                                         0,
                                                                         6);
     aVulkanDevice.DebugUtils.SetObjectName(fVulkanGGXImageViews[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.GGXImageViews['+IntToStr(InFlightFrameIndex)+']');

     fVulkanCharlieImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(aVulkanDevice,
                                                                             fVulkanCharlieImages[InFlightFrameIndex],
                                                                             TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE),
                                                                             aImageFormat,
                                                                             TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                             TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                             TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                             TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                             TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                             0,
                                                                             MipMaps,
                                                                             0,
                                                                             6);
     aVulkanDevice.DebugUtils.SetObjectName(fVulkanCharlieImageViews[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.CharlieImageViews['+IntToStr(InFlightFrameIndex)+']');

     fVulkanLambertianImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(aVulkanDevice,
                                                                                fVulkanLambertianImages[InFlightFrameIndex],
                                                                                TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE),
                                                                                aImageFormat,
                                                                                TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                0,
                                                                                MipMaps,
                                                                                0,
                                                                                6);
     aVulkanDevice.DebugUtils.SetObjectName(fVulkanLambertianImageViews[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.LambertianImageViews['+IntToStr(InFlightFrameIndex)+']');

     fRawDescriptorImageInfos[InFlightFrameIndex]:=TVkDescriptorImageInfo.Create(fVulkanSampler.Handle,
                                                                                 fVulkanRawImageViews[InFlightFrameIndex].Handle,
                                                                                 VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);

     fGGXDescriptorImageInfos[InFlightFrameIndex]:=TVkDescriptorImageInfo.Create(fVulkanSampler.Handle,
                                                                                 fVulkanGGXImageViews[InFlightFrameIndex].Handle,
                                                                                 VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);

     fCharlieDescriptorImageInfos[InFlightFrameIndex]:=TVkDescriptorImageInfo.Create(fVulkanSampler.Handle,
                                                                                     fVulkanCharlieImageViews[InFlightFrameIndex].Handle,
                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);

     fLambertianDescriptorImageInfos[InFlightFrameIndex]:=TVkDescriptorImageInfo.Create(fVulkanSampler.Handle,
                                                                                        fVulkanLambertianImageViews[InFlightFrameIndex].Handle,
                                                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);

     for Index:=0 to fMipMaps-1 do begin

      fRawImageViews[InFlightFrameIndex,Index]:=TpvVulkanImageView.Create(aVulkanDevice,
                                                                          fVulkanRawImages[InFlightFrameIndex],
                                                                          TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D_ARRAY),
                                                                          aImageFormat,
                                                                          TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                          TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                          TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                          TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                          TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                          Index,
                                                                          1,
                                                                          0,
                                                                          6);
      aVulkanDevice.DebugUtils.SetObjectName(fRawImageViews[InFlightFrameIndex,Index].Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.RawImageViews['+IntToStr(InFlightFrameIndex)+','+IntToStr(Index)+']');

      fGGXImageViews[InFlightFrameIndex,Index]:=TpvVulkanImageView.Create(aVulkanDevice,
                                                                          fVulkanGGXImages[InFlightFrameIndex],
                                                                          TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE),
                                                                          aImageFormat,
                                                                          TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                          TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                          TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                          TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                          TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                          Index,
                                                                          1,
                                                                          0,
                                                                          6);
      aVulkanDevice.DebugUtils.SetObjectName(fGGXImageViews[InFlightFrameIndex,Index].Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.GGXImageViews['+IntToStr(InFlightFrameIndex)+','+IntToStr(Index)+']');

      fCharlieImageViews[InFlightFrameIndex,Index]:=TpvVulkanImageView.Create(aVulkanDevice,
                                                                              fVulkanCharlieImages[InFlightFrameIndex],
                                                                              TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE),
                                                                              aImageFormat,
                                                                              TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                              TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                              TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                              TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                              TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                              Index,
                                                                              1,
                                                                              0,
                                                                              6);
      aVulkanDevice.DebugUtils.SetObjectName(fCharlieImageViews[InFlightFrameIndex,Index].Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.CharlieImageViews['+IntToStr(InFlightFrameIndex)+','+IntToStr(Index)+']');

      fLambertianImageViews[InFlightFrameIndex,Index]:=TpvVulkanImageView.Create(aVulkanDevice,
                                                                                 fVulkanLambertianImages[InFlightFrameIndex],
                                                                                 TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE),
                                                                                 aImageFormat,
                                                                                 TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                 TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                 TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                 TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                 TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                 Index,
                                                                                 1,
                                                                                 0,
                                                                                 6);
      aVulkanDevice.DebugUtils.SetObjectName(fLambertianImageViews[InFlightFrameIndex,Index].Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.LambertianImageViews['+IntToStr(InFlightFrameIndex)+','+IntToStr(Index)+']');

     end;

    end;

   finally
    FreeAndNil(GraphicsFence);
   end;

  finally
   FreeAndNil(GraphicsCommandBuffer);
  end;

 finally
  FreeAndNil(GraphicsCommandPool);
 end;

end;

destructor TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.Destroy;
var InFlightFrameIndex,Index:TpvSizeInt;
begin
 for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
  for Index:=0 to fMipMaps-1 do begin
   FreeAndNil(fRawImageViews[InFlightFrameIndex,Index]);
   FreeAndNil(fGGXImageViews[InFlightFrameIndex,Index]);
   FreeAndNil(fCharlieImageViews[InFlightFrameIndex,Index]);
   FreeAndNil(fLambertianImageViews[InFlightFrameIndex,Index]);
  end;
  FreeAndNil(fRawMemoryBlocks[InFlightFrameIndex]);
  FreeAndNil(fGGXMemoryBlocks[InFlightFrameIndex]);
  FreeAndNil(fCharlieMemoryBlocks[InFlightFrameIndex]);
  FreeAndNil(fLambertianMemoryBlocks[InFlightFrameIndex]);
  FreeAndNil(fVulkanRawImageViews[InFlightFrameIndex]);
  FreeAndNil(fVulkanGGXImageViews[InFlightFrameIndex]);
  FreeAndNil(fVulkanCharlieImageViews[InFlightFrameIndex]);
  FreeAndNil(fVulkanLambertianImageViews[InFlightFrameIndex]);
  FreeAndNil(fVulkanRawImages[InFlightFrameIndex]);
  FreeAndNil(fVulkanGGXImages[InFlightFrameIndex]);
  FreeAndNil(fVulkanCharlieImages[InFlightFrameIndex]);
  FreeAndNil(fVulkanLambertianImages[InFlightFrameIndex]);
 end;
//FreeAndNil(fVulkanSampler);
 inherited Destroy;
end;

end.
