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
unit PasVulkan.Scene3D.Renderer.MipmapImage3D;
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

type { TpvScene3DRendererMipmapImage3D }
     TpvScene3DRendererMipmapImage3D=class
      private
       fVulkanDevice:TpvVulkanDevice;
       fVulkanImage:TpvVulkanImage;
       fVulkanImageView:TpvVulkanImageView;
       fMemoryBlock:TpvVulkanDeviceMemoryBlock;
       fWidth:TpvInt32;
       fHeight:TpvInt32;
       fDepth:TpvInt32;
       fMipMapLevels:TpvInt32;
       fFormat:TVkFormat;
      public

       VulkanImageViews:array of TpvVulkanImageView;

       constructor Create(const aDevice:TpvVulkanDevice;const aWidth,aHeight,aDepth:TpvInt32;const aFormat:TVkFormat;const aStorage:Boolean;const aSampleBits:TVkSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT);const aImageLayout:TVkImageLayout=TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL);const aSharingMode:TVkSharingMode=TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE);const aQueueFamilyIndices:TpvVulkanQueueFamilyIndices=nil;const aAllocationGroupID:TpvUInt64=0;const aName:TpvUTF8String='');

       destructor Destroy; override;

       procedure Generate(const aQueue:TpvVulkanQueue;
                          const aCommandBuffer:TpvVulkanCommandBuffer;
                          const aFence:TpvVulkanFence;
                          const aShaderFileName:TpvUTF8String;
                          const aWorkGroupCountX:TpvInt32;
                          const aWorkGroupCountY:TpvInt32;
                          const aWorkGroupCountZ:TpvInt32);

       procedure GenerateMipMaps(const aQueue:TpvVulkanQueue;
                                 const aCommandBuffer:TpvVulkanCommandBuffer;
                                 const aFence:TpvVulkanFence);

      published

       property VulkanImage:TpvVulkanImage read fVulkanImage;

       property VulkanImageView:TpvVulkanImageView read fVulkanImageView;

       property Width:TpvInt32 read fWidth;

       property Height:TpvInt32 read fHeight;

       property Depth:TpvInt32 read fDepth;

       property MipMapLevels:TpvInt32 read fMipMapLevels;

       property Format:TVkFormat read fFormat;

     end;

implementation

uses PasVulkan.Scene3D.Assets,
     PasVulkan.Scene3D.Renderer.Globals;

{ TpvScene3DRendererMipmapImage3D }

constructor TpvScene3DRendererMipmapImage3D.Create(const aDevice:TpvVulkanDevice;const aWidth,aHeight,aDepth:TpvInt32;const aFormat:TVkFormat;const aStorage:Boolean;const aSampleBits:TVkSampleCountFlagBits;const aImageLayout:TVkImageLayout;const aSharingMode:TVkSharingMode;const aQueueFamilyIndices:TpvVulkanQueueFamilyIndices;const aAllocationGroupID:TpvUInt64;const aName:TpvUTF8String);
var MipMapLevelIndex:TpvSizeInt;
    MemoryRequirements:TVkMemoryRequirements;
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

 fVulkanDevice:=aDevice;

 fWidth:=aWidth;

 fHeight:=aHeight;

 fDepth:=aDepth;

 fMipMapLevels:=Max(1,IntLog2(Max(aWidth,Max(aHeight,aDepth)))+1);

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

 ImageViewType:=TVkImageViewType(VK_IMAGE_VIEW_TYPE_3D);

 if length(aQueueFamilyIndices)>0 then begin
  p:=@aQueueFamilyIndices[0];
 end else begin
  p:=nil;
 end;

 fVulkanImage:=TpvVulkanImage.Create(aDevice,
                                     0, //TVkImageCreateFlags(VK_IMAGE_CREATE_3D_ARRAY_COMPATIBLE_BIT),
                                     VK_IMAGE_TYPE_3D,
                                     aFormat,
                                     aWidth,
                                     aHeight,
                                     aDepth,
                                     fMipMapLevels,
                                     1,
                                     aSampleBits,
                                     VK_IMAGE_TILING_OPTIMAL,
                                     TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or
                                     IfThen(aStorage,TVkImageUsageFlags(VK_IMAGE_USAGE_STORAGE_BIT),TVkImageUsageFlags(0)) or
                                     TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT) or
                                     TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT),
                                     aSharingMode,
                                     length(aQueueFamilyIndices),
                                     p,
                                     VK_IMAGE_LAYOUT_UNDEFINED
                                    );
 if length(aName)>0 then begin
  aDevice.DebugUtils.SetObjectName(fVulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererMipmapImage3D["'+aName+'"].Image');
 end;

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
                                                         'TpvScene3DRendererMipmapImage3D["'+aName+'"].MemoryBlock');
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
    ImageSubresourceRange.levelCount:=fMipMapLevels;
    ImageSubresourceRange.baseArrayLayer:=0;
    ImageSubresourceRange.layerCount:=1;
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
                                                fMipMapLevels,
                                                0,
                                                1);
    if length(aName)>0 then begin
     aDevice.DebugUtils.SetObjectName(fVulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererMipmapImage3D["'+aName+'"].ImageView');
    end;

    SetLength(VulkanImageViews,fMipMapLevels);

    for MipMapLevelIndex:=0 to fMipMapLevels-1 do begin
     VulkanImageViews[MipMapLevelIndex]:=TpvVulkanImageView.Create(aDevice,
                                                                   fVulkanImage,
                                                                   ImageViewType,
                                                                   aFormat,
                                                                   TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                   TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                   TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                   TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                   TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                   MipMapLevelIndex,
                                                                   1,
                                                                   0,
                                                                   1);
     if length(aName)>0 then begin
      aDevice.DebugUtils.SetObjectName(VulkanImageViews[MipMapLevelIndex].Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererMipmapImage3D["'+aName+'"].ImageViews['+IntToStr(MipMapLevelIndex)+']');
     end;
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

destructor TpvScene3DRendererMipmapImage3D.Destroy;
var MipMapLevelIndex:TpvSizeInt;
begin
 for MipMapLevelIndex:=0 to fMipMapLevels-1 do begin
  FreeAndNil(VulkanImageViews[MipMapLevelIndex]);
 end;
 VulkanImageViews:=nil;
 FreeAndNil(fVulkanImageView);
 FreeAndNil(fVulkanImage);
 FreeAndNil(fMemoryBlock);
 inherited Destroy;
end;

procedure TpvScene3DRendererMipmapImage3D.Generate(const aQueue:TpvVulkanQueue;
                                                   const aCommandBuffer:TpvVulkanCommandBuffer;
                                                   const aFence:TpvVulkanFence;
                                                   const aShaderFileName:TpvUTF8String;
                                                   const aWorkGroupCountX:TpvInt32;
                                                   const aWorkGroupCountY:TpvInt32;
                                                   const aWorkGroupCountZ:TpvInt32);
var Stream:TStream;
    ComputeShader:TpvVulkanShaderModule;
    ComputeShaderStage:TpvVulkanPipelineShaderStage;
    PipelineLayout:TpvVulkanPipelineLayout;
    ComputePipeline:TpvVulkanComputePipeline;
    DescriptorSetLayout:TpvVulkanDescriptorSetLayout;
    DescriptorPool:TpvVulkanDescriptorPool;
    DescriptorSet:TpvVulkanDescriptorSet;
    ImageMemoryBarrier:TVkImageMemoryBarrier;
begin

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile(aShaderFileName);
 try
  ComputeShader:=TpvVulkanShaderModule.Create(fVulkanImage.Device,Stream);
 finally
  Stream.Free;
 end;
 fVulkanImage.Device.DebugUtils.SetObjectName(ComputeShader.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererMipmapImage3D.GenerateComputeShader');

 try

  ComputeShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,ComputeShader,'main');
  try

   DescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fVulkanImage.Device);
   try

    DescriptorSetLayout.AddBinding(0,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
    DescriptorSetLayout.Initialize;

    DescriptorPool:=TpvVulkanDescriptorPool.Create(fVulkanImage.Device,
                                                   TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                   1);
    try

     DescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,1);
     DescriptorPool.Initialize;

     DescriptorSet:=TpvVulkanDescriptorSet.Create(DescriptorPool,
                                                  DescriptorSetLayout);
     try
      DescriptorSet.WriteToDescriptorSet(0,
                                         0,
                                         1,
                                         TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                         [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                        VulkanImageViews[0].Handle,
                                                                        VK_IMAGE_LAYOUT_GENERAL)],
                                         [],
                                         [],
                                         false);
      DescriptorSet.Flush;

      PipelineLayout:=TpvVulkanPipelineLayout.Create(fVulkanImage.Device);
      PipelineLayout.AddDescriptorSetLayout(DescriptorSetLayout);
      PipelineLayout.Initialize;
      try

       ComputePipeline:=TpvVulkanComputePipeline.Create(fVulkanDevice,
                                                        pvApplication.VulkanPipelineCache,
                                                        0,
                                                        ComputeShaderStage,
                                                        PipelineLayout,
                                                        nil,
                                                        0);
       try

        begin

         aCommandBuffer.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));

         aCommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT));

        end;

        FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
        ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        ImageMemoryBarrier.pNext:=nil;
        ImageMemoryBarrier.srcAccessMask:=0;
        ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
        ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_UNDEFINED;
        ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_GENERAL;
        ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
        ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
        ImageMemoryBarrier.image:=fVulkanImage.Handle;
        ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
        ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
        ImageMemoryBarrier.subresourceRange.levelCount:=1;
        ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
        ImageMemoryBarrier.subresourceRange.layerCount:=1;
        aCommandBuffer.CmdPipelineBarrier(fVulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                          0,
                                          0,nil,
                                          0,nil,
                                          1,@ImageMemoryBarrier);

        aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,ComputePipeline.Handle);

        aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                             PipelineLayout.Handle,
                                             0,
                                             1,
                                             @DescriptorSet.Handle,
                                             0,
                                             nil);

        aCommandBuffer.CmdDispatch(((fWidth+(aWorkGroupCountX-1)) div aWorkGroupCountX),
                                   ((fHeight+(aWorkGroupCountY-1)) div aWorkGroupCountY),
                                   ((fDepth+(aWorkGroupCountZ-1)) div aWorkGroupCountZ));

        FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
        ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        ImageMemoryBarrier.pNext:=nil;
        ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
        ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
        ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
        ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
        ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
        ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
        ImageMemoryBarrier.image:=fVulkanImage.Handle;
        ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
        ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
        ImageMemoryBarrier.subresourceRange.levelCount:=1;
        ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
        ImageMemoryBarrier.subresourceRange.layerCount:=1;
        aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                          fVulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                          0,
                                          0,nil,
                                          0,nil,
                                          1,@ImageMemoryBarrier);

        begin

         aCommandBuffer.EndRecording;

         aCommandBuffer.Execute(aQueue,TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),nil,nil,aFence,true);

        end;

       finally
        FreeAndNil(ComputePipeline);
       end;

      finally
       FreeAndNil(PipelineLayout);
      end;

     finally
      FreeAndNil(DescriptorSet);
     end;

    finally
     FreeAndNil(DescriptorPool);
    end;

   finally
    FreeAndNil(DescriptorSetLayout);
   end;

  finally
   FreeAndNil(ComputeShaderStage);
  end;

 finally
  FreeAndNil(ComputeShader);
 end;

end;

procedure TpvScene3DRendererMipmapImage3D.GenerateMipMaps(const aQueue:TpvVulkanQueue;
                                                          const aCommandBuffer:TpvVulkanCommandBuffer;
                                                          const aFence:TpvVulkanFence);
var MipMapLevelIndex:TpvSizeInt;
    ImageMemoryBarriers:array[0..1] of TVkImageMemoryBarrier;
    ComputeShader:TpvVulkanShaderModule;
    ComputeShaderStage:TpvVulkanPipelineShaderStage;
    PipelineLayout:TpvVulkanPipelineLayout;
    ComputePipeline:TpvVulkanComputePipeline;
    DescriptorSetLayout:TpvVulkanDescriptorSetLayout;
    DescriptorPool:TpvVulkanDescriptorPool;
    DescriptorSets:array[1..15] of TpvVulkanDescriptorSet;
    Stream:TStream;
    FormatType:string;
begin

 case fFormat of
  VK_FORMAT_R8G8B8A8_UNORM:begin
   FormatType:='rgba8';
  end;
  VK_FORMAT_R16G16B16A16_SFLOAT:begin
   FormatType:='rgba16f';
  end;
  VK_FORMAT_R32G32B32A32_SFLOAT:begin
   FormatType:='rgba32f';
  end;
  VK_FORMAT_B10G11R11_UFLOAT_PACK32:begin
   FormatType:='r11g11b10f';
  end;
  VK_FORMAT_E5B9G9R9_UFLOAT_PACK32:begin
   FormatType:='rgb9e5';
  end;
  else begin
   FormatType:=''; // To suppress uninitialized warning at some compilers
   raise EpvVulkanException.Create('Unsupported format');
  end;
 end;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_3d_'+FormatType+'_comp.spv');
 try
  ComputeShader:=TpvVulkanShaderModule.Create(fVulkanImage.Device,Stream);
 finally
  Stream.Free;
 end;
 fVulkanImage.Device.DebugUtils.SetObjectName(ComputeShader.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererMipmapImage3D.ComputeShader');

 try

  ComputeShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,ComputeShader,'main');
  try

   DescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fVulkanImage.Device);
   try

    DescriptorSetLayout.AddBinding(0,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
    DescriptorSetLayout.AddBinding(1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
    DescriptorSetLayout.Initialize;

    DescriptorPool:=TpvVulkanDescriptorPool.Create(fVulkanImage.Device,
                                                   TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                   fMipMapLevels);
    try

     DescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fMipMapLevels*2);
     DescriptorPool.Initialize;

     PipelineLayout:=TpvVulkanPipelineLayout.Create(fVulkanImage.Device);
     PipelineLayout.AddDescriptorSetLayout(DescriptorSetLayout);
     PipelineLayout.Initialize;
     try

      ComputePipeline:=TpvVulkanComputePipeline.Create(fVulkanDevice,
                                                       pvApplication.VulkanPipelineCache,
                                                       0,
                                                       ComputeShaderStage,
                                                       PipelineLayout,
                                                       nil,
                                                       0);
      try

       for MipMapLevelIndex:=1 to fMipMapLevels-1 do begin

        DescriptorSets[MipMapLevelIndex]:=TpvVulkanDescriptorSet.Create(DescriptorPool,
                                                                        DescriptorSetLayout);
        DescriptorSets[MipMapLevelIndex].WriteToDescriptorSet(0,
                                                              0,
                                                              1,
                                                              TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                              [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                             VulkanImageViews[MipMapLevelIndex-1].Handle,
                                                                                             VK_IMAGE_LAYOUT_GENERAL)],
                                                              [],
                                                              [],
                                                              false);
        DescriptorSets[MipMapLevelIndex].WriteToDescriptorSet(1,
                                                              0,
                                                              1,
                                                              TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                              [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                             VulkanImageViews[MipMapLevelIndex].Handle,
                                                                                             VK_IMAGE_LAYOUT_GENERAL)],
                                                              [],
                                                              [],
                                                              false);
        DescriptorSets[MipMapLevelIndex].Flush;

       end;

       try

        begin

         aCommandBuffer.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));

         aCommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT));

        end;

        FillChar(ImageMemoryBarriers[0],SizeOf(TVkImageMemoryBarrier),#0);
        ImageMemoryBarriers[0].sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        ImageMemoryBarriers[0].pNext:=nil;
        ImageMemoryBarriers[0].srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
        ImageMemoryBarriers[0].dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
        ImageMemoryBarriers[0].oldLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
        ImageMemoryBarriers[0].newLayout:=VK_IMAGE_LAYOUT_GENERAL;
        ImageMemoryBarriers[0].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
        ImageMemoryBarriers[0].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
        ImageMemoryBarriers[0].image:=fVulkanImage.Handle;
        ImageMemoryBarriers[0].subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
        ImageMemoryBarriers[0].subresourceRange.baseMipLevel:=0;
        ImageMemoryBarriers[0].subresourceRange.levelCount:=1;
        ImageMemoryBarriers[0].subresourceRange.baseArrayLayer:=0;
        ImageMemoryBarriers[0].subresourceRange.layerCount:=1;

        FillChar(ImageMemoryBarriers[1],SizeOf(TVkImageMemoryBarrier),#0);
        ImageMemoryBarriers[1].sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        ImageMemoryBarriers[1].pNext:=nil;
        ImageMemoryBarriers[1].srcAccessMask:=0;//TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
        ImageMemoryBarriers[1].dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
        ImageMemoryBarriers[1].oldLayout:=VK_IMAGE_LAYOUT_UNDEFINED;
        ImageMemoryBarriers[1].newLayout:=VK_IMAGE_LAYOUT_GENERAL;
        ImageMemoryBarriers[1].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
        ImageMemoryBarriers[1].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
        ImageMemoryBarriers[1].image:=fVulkanImage.Handle;
        ImageMemoryBarriers[1].subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
        ImageMemoryBarriers[1].subresourceRange.baseMipLevel:=1;
        ImageMemoryBarriers[1].subresourceRange.levelCount:=fMipMapLevels-1;
        ImageMemoryBarriers[1].subresourceRange.baseArrayLayer:=0;
        ImageMemoryBarriers[1].subresourceRange.layerCount:=1;

        aCommandBuffer.CmdPipelineBarrier(fVulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                          0,
                                          0,nil,
                                          0,nil,
                                          2,@ImageMemoryBarriers[0]);

        for MipMapLevelIndex:=1 to fMipMapLevels-1 do begin

         aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,ComputePipeline.Handle);

         aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                              PipelineLayout.Handle,
                                              0,
                                              1,
                                              @DescriptorSets[MipMapLevelIndex].Handle,
                                              0,
                                              nil);

         aCommandBuffer.CmdDispatch(((fWidth shr MipMapLevelIndex)+7) shr 3,
                                    ((fHeight shr MipMapLevelIndex)+7) shr 3,
                                    ((fDepth shr MipMapLevelIndex)+7) shr 3);

         if MipMapLevelIndex<(fMipMapLevels-1) then begin

          FillChar(ImageMemoryBarriers[0],SizeOf(TVkImageMemoryBarrier),#0);
          ImageMemoryBarriers[0].sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
          ImageMemoryBarriers[0].pNext:=nil;
          ImageMemoryBarriers[0].srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
          ImageMemoryBarriers[0].dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
          ImageMemoryBarriers[0].oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
          ImageMemoryBarriers[0].newLayout:=VK_IMAGE_LAYOUT_GENERAL;
          ImageMemoryBarriers[0].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
          ImageMemoryBarriers[0].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
          ImageMemoryBarriers[0].image:=fVulkanImage.Handle;
          ImageMemoryBarriers[0].subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
          ImageMemoryBarriers[0].subresourceRange.baseMipLevel:=MipMapLevelIndex;
          ImageMemoryBarriers[0].subresourceRange.levelCount:=1;
          ImageMemoryBarriers[0].subresourceRange.baseArrayLayer:=0;
          ImageMemoryBarriers[0].subresourceRange.layerCount:=1;
          aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                            0,
                                            0,nil,
                                            0,nil,
                                            1,@ImageMemoryBarriers[0]);

         end;

        end;

        FillChar(ImageMemoryBarriers[0],SizeOf(TVkImageMemoryBarrier),#0);
        ImageMemoryBarriers[0].sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        ImageMemoryBarriers[0].pNext:=nil;
        ImageMemoryBarriers[0].srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
        ImageMemoryBarriers[0].dstAccessMask:=0;//TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
        ImageMemoryBarriers[0].oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
        ImageMemoryBarriers[0].newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
        ImageMemoryBarriers[0].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
        ImageMemoryBarriers[0].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
        ImageMemoryBarriers[0].image:=fVulkanImage.Handle;
        ImageMemoryBarriers[0].subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
        ImageMemoryBarriers[0].subresourceRange.baseMipLevel:=0;
        ImageMemoryBarriers[0].subresourceRange.levelCount:=fMipMapLevels;
        ImageMemoryBarriers[0].subresourceRange.baseArrayLayer:=0;
        ImageMemoryBarriers[0].subresourceRange.layerCount:=1;
        aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                          fVulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                          0,
                                          0,nil,
                                          0,nil,
                                          1,@ImageMemoryBarriers[0]);

        begin

         aCommandBuffer.EndRecording;

         aCommandBuffer.Execute(aQueue,TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),nil,nil,aFence,true);

        end;

       finally
        for MipMapLevelIndex:=1 to fMipMapLevels-1 do begin
         FreeAndNil(DescriptorSets[MipMapLevelIndex]);
        end;
       end;

      finally
       FreeAndNil(ComputePipeline);
      end;

     finally
      FreeAndNil(PipelineLayout);
     end;

    finally
     FreeAndNil(DescriptorPool);
    end;

   finally
    FreeAndNil(DescriptorSetLayout);
   end;

  finally
   FreeAndNil(ComputeShaderStage);
  end;

 finally
  FreeAndNil(ComputeShader);
 end;

end;

end.

