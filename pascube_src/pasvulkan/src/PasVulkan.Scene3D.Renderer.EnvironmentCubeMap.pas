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
unit PasVulkan.Scene3D.Renderer.EnvironmentCubeMap;
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
     PasVulkan.Application,
     PasVulkan.Scene3D,
     PasVulkan.Scene3D.Renderer.Globals;

type { TpvScene3DRendererEnvironmentCubeMap }
     TpvScene3DRendererEnvironmentCubeMap=class
      public
       type TPushConstants=packed record
             LightDirectionIntensityFactor:TpvVector4; // xyz = light direction, w = intensity factor
            end;
            PPushConstants=^TPushConstants;
      private
       fComputeShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fVulkanImage:TpvVulkanImage;
       fVulkanSampler:TpvVulkanSampler;
       fVulkanImageView:TpvVulkanImageView;
       fMemoryBlock:TpvVulkanDeviceMemoryBlock;
       fDescriptorImageInfo:TVkDescriptorImageInfo;
       fLightDirection:TpvVector3;
       fIntensityFactor:TpvFloat;
       fPushConstants:TPushConstants;
       fWidth:TpvInt32;
       fHeight:TpvInt32;
      public

       constructor Create(const aVulkanDevice:TpvVulkanDevice;const aVulkanPipelineCache:TpvVulkanPipelineCache;const aSampler:TpvVulkanSampler;const aLightDirection:TpvVector3;const aIntensityFactor:TpvFloat;const aForEnvMap:Boolean;const aImageFormat:TVkFormat=TVkFormat(VK_FORMAT_R16G16B16A16_SFLOAT);const aTexture:TpvVulkanTexture=nil;const aEnvironmentMode:TpvScene3DEnvironmentMode=TpvScene3DEnvironmentMode.Sky;const aName:TpvUTF8String='');

       destructor Destroy; override;

      published

       property VulkanImage:TpvVulkanImage read fVulkanImage;

       property VulkanSampler:TpvVulkanSampler read fVulkanSampler;

       property VulkanImageView:TpvVulkanImageView read fVulkanImageView;

       property Width:TpvInt32 read fWidth;

       property Height:TpvInt32 read fHeight;

      public

       property DescriptorImageInfo:TVkDescriptorImageInfo read fDescriptorImageInfo;

       property LightDirection:TpvVector3 read fLightDirection;

     end;

implementation

{ TpvScene3DRendererEnvironmentCubeMap }

constructor TpvScene3DRendererEnvironmentCubeMap.Create(const aVulkanDevice:TpvVulkanDevice;const aVulkanPipelineCache:TpvVulkanPipelineCache;const aSampler:TpvVulkanSampler;const aLightDirection:TpvVector3;const aIntensityFactor:TpvFloat;const aForEnvMap:Boolean;const aImageFormat:TVkFormat;const aTexture:TpvVulkanTexture;const aEnvironmentMode:TpvScene3DEnvironmentMode;const aName:TpvUTF8String);
var Index,FaceIndex,MipMaps,CountMipMapLevelSets,MipMapLevelSetIndex:TpvSizeInt;
    Stream:TStream;
    MemoryRequirements:TVkMemoryRequirements;
    RequiresDedicatedAllocation,
    PrefersDedicatedAllocation:boolean;
    MemoryBlockFlags:TpvVulkanDeviceMemoryBlockFlags;
    ImageSubresourceRange:TVkImageSubresourceRange;
    GraphicsQueue:TpvVulkanQueue;
    GraphicsCommandPool:TpvVulkanCommandPool;
    GraphicsCommandBuffer:TpvVulkanCommandBuffer;
    GraphicsFence:TpvVulkanFence;
    ComputeQueue:TpvVulkanQueue;
    ComputeCommandPool:TpvVulkanCommandPool;
    ComputeCommandBuffer:TpvVulkanCommandBuffer;
    ComputeFence:TpvVulkanFence;
    ImageView:TpvVulkanImageView;
    DescriptorImageInfo:TVkDescriptorImageInfo;
    VulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
    VulkanDescriptorPool:TpvVulkanDescriptorPool;
    VulkanDescriptorSet:TpvVulkanDescriptorSet;
    FrameBuffer:TpvVulkanFrameBuffer;
    RenderPass:TpvVulkanRenderPass;
    FrameBufferColorAttachment:TpvVulkanFrameBufferAttachment;
    PipelineLayout:TpvVulkanPipelineLayout;
    Pipeline:TpvVulkanComputePipeline;
    ImageBlit:TVkImageBlit;
    ImageMemoryBarrier:TVkImageMemoryBarrier;
    AdditionalImageFormat:TVkFormat;
    FormatVariant,DownsampleFormatVariant:String;
    DownsampleComputeShaderModule:TpvVulkanShaderModule;
    DownsampleVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
    DownsampleVulkanSourceImageViews:array[0..7] of TpvVulkanImageView;
    DownsampleVulkanTargetImageViews:array[0..7,0..3] of TpvVulkanImageView;
    DownsampleVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
    DownsampleVulkanDescriptorPool:TpvVulkanDescriptorPool;
    DownsampleVulkanDescriptorSets:array[0..7] of TpvVulkanDescriptorSet;
    DownsampleVulkanComputePipelineLayout:TpvVulkanPipelineLayout;
    DownsampleVulkanComputePipeline:TpvVulkanComputePipeline;    
    DownsampleMipMapIndex:TpvInt32;
    DownsampleCountMipMaps:TpvInt32;
begin
 inherited Create;

 fLightDirection:=aLightDirection;

 fIntensityFactor:=aIntensityFactor;
 
 fPushConstants.LightDirectionIntensityFactor:=TpvVector4.InlineableCreate(fLightDirection,fIntensityFactor);

 case aImageFormat of
  VK_FORMAT_B10G11R11_UFLOAT_PACK32:begin
   DownsampleFormatVariant:='r11g11b10f';
   FormatVariant:='r11g11b10f';
   AdditionalImageFormat:=VK_FORMAT_UNDEFINED;
  end;
  VK_FORMAT_R16G16B16A16_SFLOAT:begin
   DownsampleFormatVariant:='rgba16f';
   FormatVariant:='rgba16f';
   AdditionalImageFormat:=VK_FORMAT_UNDEFINED;
  end;
  VK_FORMAT_R32G32B32A32_SFLOAT:begin
   DownsampleFormatVariant:='rgba32f';
   FormatVariant:='rgba32f';
   AdditionalImageFormat:=VK_FORMAT_UNDEFINED;
  end;
  VK_FORMAT_E5B9G9R9_UFLOAT_PACK32:begin
   DownsampleFormatVariant:='rgb9e5';
   FormatVariant:='rgb9e5';
   AdditionalImageFormat:=VK_FORMAT_R32_UINT;
  end;
  VK_FORMAT_R8G8B8A8_UNORM,
  VK_FORMAT_B8G8R8A8_UNORM:begin
   DownsampleFormatVariant:='rgba8';
   FormatVariant:='rgba8';
   AdditionalImageFormat:=VK_FORMAT_UNDEFINED;
  end;
  else begin
   Assert(false); // Unsupported format
   DownsampleFormatVariant:='';
   FormatVariant:='';
   AdditionalImageFormat:=VK_FORMAT_UNDEFINED;
  end;
 end;

 if (aEnvironmentMode=TpvScene3DEnvironmentMode.Texture) and assigned(aTexture) then begin
  if aTexture.CountFaces=6 then begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cubemap_cubemap_'+FormatVariant+'_comp.spv');
   fWidth:=RoundDownToPowerOfTwo(aTexture.Width);
   fHeight:=RoundDownToPowerOfTwo(aTexture.Height);
  end else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cubemap_equirectangularmap_'+FormatVariant+'_comp.spv');
   fWidth:=RoundUpToPowerOfTwo(Min(Max(round(Max(aTexture.Width,aTexture.Height)/PI),512),8192));
   fHeight:=fWidth;
  end;
 end else begin
  case aEnvironmentMode of
   TpvScene3DEnvironmentMode.Starlight,TpvScene3DEnvironmentMode.CachedStarlight:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cubemap_starlight_'+FormatVariant+'_comp.spv');
    case pvApplication.VulkanDevice.PhysicalDevice.Properties.deviceType of
     TVkPhysicalDeviceType.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU:begin
      if aForEnvMap then begin
       // EnvMap (for IBL-Lighting)
       fWidth:=1024;
       fHeight:=1024;
      end else begin
       // SkyBox
       if aEnvironmentMode=TpvScene3DEnvironmentMode.Starlight then begin
        // Not yet anyway, because it will be rendered in real-time then, so 64x64 dummy cube map
        fWidth:=64;
        fHeight:=64;
       end else begin
        // But for the cached version, it should be a bigger cube map texture
        if TVkUInt64(pvApplication.VulkanDevice.MemoryManager.MaximumMemoryMappableDeviceLocalHeapSize)>=(TVkUInt64(16) shl 30) then begin
         fWidth:=4096;
         fHeight:=4096;
        end else begin
         fWidth:=2048;
         fHeight:=2048;
        end;
       end;
      end;
     end;
     else begin
      if aForEnvMap then begin
       // EnvMap (for IBL-Lighting)
       fWidth:=512;
       fHeight:=512;
      end else begin
       // SkyBox
       fWidth:=1024;
       fHeight:=1024;
      end;
     end;
    end;
   end;
   else begin
    case pvApplication.VulkanDevice.PhysicalDevice.Properties.vendorID of
     TVkUInt32(TpvVulkanVendorID.NVIDIA),TVkUInt32(TpvVulkanVendorID.AMD):begin
      Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cubemap_sky_'+FormatVariant+'_comp.spv');
      fWidth:=256;
      fHeight:=256;
     end;
     else begin
      Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cubemap_sky_fast_'+FormatVariant+'_comp.spv');
      fWidth:=128;
      fHeight:=128;
     end;
    end;
   end;
  end;
 end;
 try
  fComputeShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 MipMaps:=IntLog2(Max(fWidth,fHeight))+1;

 fVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModule,'main');

 fVulkanImage:=TpvVulkanImage.Create(pvApplication.VulkanDevice,
                                     TVkImageCreateFlags(VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT) or
                                     TVkImageCreateFlags(IfThen(AdditionalImageFormat<>VK_FORMAT_UNDEFINED,TVkUInt32(VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT) or TVkUInt32(VK_IMAGE_CREATE_EXTENDED_USAGE_BIT),0)),
                                     VK_IMAGE_TYPE_2D,
                                     aImageFormat,
                                     fWidth,
                                     fHeight,
                                     1,
                                     MipMaps,
                                     6,
                                     VK_SAMPLE_COUNT_1_BIT,
                                     VK_IMAGE_TILING_OPTIMAL,
                                     TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT) or
                                     TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT) or
                                     TVkImageUsageFlags(VK_IMAGE_USAGE_STORAGE_BIT) or
                                     TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                     VK_SHARING_MODE_EXCLUSIVE,
                                     0,
                                     nil,
                                     VK_IMAGE_LAYOUT_UNDEFINED,
                                     AdditionalImageFormat
                                    );

 pvApplication.VulkanDevice.DebugUtils.SetObjectName(fVulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'EnvironmentCubeMap["'+aName+'"].fVulkanImage');

 MemoryRequirements:=pvApplication.VulkanDevice.MemoryManager.GetImageMemoryRequirements(fVulkanImage.Handle,
                                                                                         RequiresDedicatedAllocation,
                                                                                         PrefersDedicatedAllocation);

 MemoryBlockFlags:=[];

 if RequiresDedicatedAllocation or PrefersDedicatedAllocation then begin
  Include(MemoryBlockFlags,TpvVulkanDeviceMemoryBlockFlag.DedicatedAllocation);
 end;

 fMemoryBlock:=pvApplication.VulkanDevice.MemoryManager.AllocateMemoryBlock(MemoryBlockFlags,
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
                                                                            pvAllocationGroupIDScene3DTexture,
                                                                            'EnvironmentCubeMap["'+aName+'"].fMemoryBlock');
 if not assigned(fMemoryBlock) then begin
  raise EpvVulkanMemoryAllocationException.Create('Memory for texture couldn''t be allocated!');
 end;

 fMemoryBlock.AssociatedObject:=self;

 VulkanCheckResult(pvApplication.VulkanDevice.Commands.BindImageMemory(pvApplication.VulkanDevice.Handle,
                                                                       fVulkanImage.Handle,
                                                                       fMemoryBlock.MemoryChunk.Handle,
                                                                       fMemoryBlock.Offset));

 GraphicsQueue:=pvApplication.VulkanDevice.GraphicsQueue;

 ComputeQueue:=pvApplication.VulkanDevice.ComputeQueue;

 GraphicsCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                  pvApplication.VulkanDevice.GraphicsQueueFamilyIndex,
                                                  TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
 try

  GraphicsCommandBuffer:=TpvVulkanCommandBuffer.Create(GraphicsCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
  try

   GraphicsFence:=TpvVulkanFence.Create(pvApplication.VulkanDevice);
   try

    ComputeCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                    pvApplication.VulkanDevice.ComputeQueueFamilyIndex,
                                                    TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
    try

     ComputeCommandBuffer:=TpvVulkanCommandBuffer.Create(ComputeCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
     try

      ComputeFence:=TpvVulkanFence.Create(pvApplication.VulkanDevice);
      try

       FillChar(ImageSubresourceRange,SizeOf(TVkImageSubresourceRange),#0);
       ImageSubresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
       ImageSubresourceRange.baseMipLevel:=0;
       ImageSubresourceRange.levelCount:=MipMaps;
       ImageSubresourceRange.baseArrayLayer:=0;
       ImageSubresourceRange.layerCount:=6;

       fVulkanImage.SetLayout(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                              TVkImageLayout(VK_IMAGE_LAYOUT_UNDEFINED),
                              TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                              @ImageSubresourceRange,
                              GraphicsCommandBuffer,
                              GraphicsQueue,
                              GraphicsFence,
                              true);

       fVulkanSampler:=aSampler;

       fVulkanImageView:=TpvVulkanImageView.Create(pvApplication.VulkanDevice,
                                                   fVulkanImage,
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
                                                   6,
                                                   true,
                                                   TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT) or
                                                   TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT) or
                                                   TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT));

       pvApplication.VulkanDevice.DebugUtils.SetObjectName(fVulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'EnvironmentCubeMap["'+aName+'"].fVulkanImageView');

       fDescriptorImageInfo:=TVkDescriptorImageInfo.Create(fVulkanSampler.Handle,
                                                           fVulkanImageView.Handle,
                                                           VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);

       ImageView:=TpvVulkanImageView.Create(pvApplication.VulkanDevice,
                                            fVulkanImage,
                                            TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE),
                                            TVkFormat(IfThen(AdditionalImageFormat<>VK_FORMAT_UNDEFINED,TVkInt32(AdditionalImageFormat),TVkInt32(aImageFormat))),
                                            TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                            TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                            TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                            TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                            TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                            0,
                                            1,
                                            0,
                                            6);
       try

        pvApplication.VulkanDevice.DebugUtils.SetObjectName(ImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'EnvironmentCubeMap["'+aName+'"].ImageView');

        DescriptorImageInfo:=TVkDescriptorImageInfo.Create(fVulkanSampler.Handle,
                                                           ImageView.Handle,
                                                           VK_IMAGE_LAYOUT_GENERAL);
        try

         VulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(pvApplication.VulkanDevice);
         try
          VulkanDescriptorSetLayout.AddBinding(0,
                                               VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                               1,
                                               TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                               []);
          if assigned(aTexture) then begin
           VulkanDescriptorSetLayout.AddBinding(1,
                                                VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                1,
                                                TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                []);
          end;
          VulkanDescriptorSetLayout.Initialize;

          VulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(pvApplication.VulkanDevice,
                                                               TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                               1);
          try

           VulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,1);
           if assigned(aTexture) then begin
            VulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,1);
           end;
           VulkanDescriptorPool.Initialize;

           VulkanDescriptorSet:=TpvVulkanDescriptorSet.Create(VulkanDescriptorPool,
                                                              VulkanDescriptorSetLayout);
           try

            VulkanDescriptorSet.WriteToDescriptorSet(0,
                                                     0,
                                                     1,
                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                     [DescriptorImageInfo],
                                                     [],
                                                     [],
                                                     false);
            if assigned(aTexture) then begin
             VulkanDescriptorSet.WriteToDescriptorSet(1,
                                                      0,
                                                      1,
                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                      [TVkDescriptorImageInfo.Create(fVulkanSampler.Handle,
                                                                                     aTexture.ImageView.Handle,
                                                                                     aTexture.ImageLayout)],
                                                      [],
                                                      [],
                                                      false);
            end;
            VulkanDescriptorSet.Flush;

            PipelineLayout:=TpvVulkanPipelineLayout.Create(pvApplication.VulkanDevice);
            try
             PipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TpvScene3DRendererEnvironmentCubeMap.TPushConstants));
             PipelineLayout.AddDescriptorSetLayout(VulkanDescriptorSetLayout);
             PipelineLayout.Initialize;

             Pipeline:=TpvVulkanComputePipeline.Create(pvApplication.VulkanDevice,
                                                       pvApplication.VulkanPipelineCache,
                                                       0,
                                                       fVulkanPipelineShaderStageCompute,
                                                       PipelineLayout,
                                                       nil,
                                                       0);
             try

              ComputeCommandBuffer.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));

              ComputeCommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT));

 {            FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
              ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
              ImageMemoryBarrier.pNext:=nil;
              ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
              ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
              ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
              ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_GENERAL;
              ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
              ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
              ImageMemoryBarrier.image:=fVulkanImage.Handle;
              ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
              ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
              ImageMemoryBarrier.subresourceRange.levelCount:=MipMaps;
              ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
              ImageMemoryBarrier.subresourceRange.layerCount:=1;
              ComputeCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                                      0,
                                                      0,nil,
                                                      0,nil,
                                                      1,@ImageMemoryBarrier);
 }
              ComputeCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,Pipeline.Handle);

              ComputeCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                                         PipelineLayout.Handle,
                                                         0,
                                                         1,
                                                         @VulkanDescriptorSet.Handle,
                                                         0,
                                                         nil);

              ComputeCommandBuffer.CmdPushConstants(PipelineLayout.Handle,
                                                    TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                                    0,
                                                    SizeOf(TpvScene3DRendererEnvironmentCubeMap.TPushConstants),
                                                    @fPushConstants);

              ComputeCommandBuffer.CmdDispatch(Max(1,(fWidth+((1 shl 4)-1)) shr 4),
                                               Max(1,(fHeight+((1 shl 4)-1)) shr 4),
                                               6);

 {            FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
              ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
              ImageMemoryBarrier.pNext:=nil;
              ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
              ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT);
              ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
              ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_GENERAL;
              ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
              ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
              ImageMemoryBarrier.image:=fVulkanImage.Handle;
              ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
              ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
              ImageMemoryBarrier.subresourceRange.levelCount:=MipMaps;
              ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
              ImageMemoryBarrier.subresourceRange.layerCount:=1;
              ComputeCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                                      0,
                                                      0,nil,
                                                      0,nil,
                                                      1,@ImageMemoryBarrier); }

              ComputeCommandBuffer.EndRecording;

              ComputeCommandBuffer.Execute(ComputeQueue,TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),nil,nil,ComputeFence,true);

             finally
              FreeAndNil(Pipeline);
             end;

            finally
             FreeAndNil(PipelineLayout);
            end;

           finally
            FreeAndNil(VulkanDescriptorSet);
           end;

          finally
           FreeAndNil(VulkanDescriptorPool);
          end;

         finally
          FreeAndNil(VulkanDescriptorSetLayout);
         end;

        finally
        end;

       finally
        FreeAndNil(ImageView);
       end;

      finally
       FreeAndNil(ComputeFence);
      end;

     finally
      FreeAndNil(ComputeCommandBuffer);
     end;

    finally
     FreeAndNil(ComputeCommandPool);
    end;

    // Generate mipmaps
    if true {AdditionalImageFormat<>VK_FORMAT_UNDEFINED} then begin

     // With compute shader, 4 mipmaps at once per compute pass 

     ComputeCommandPool:=TpvVulkanCommandPool.Create(pvApplication.VulkanDevice,
                                                     pvApplication.VulkanDevice.ComputeQueueFamilyIndex,
                                                     TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
     try

      ComputeCommandBuffer:=TpvVulkanCommandBuffer.Create(ComputeCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
      try

       ComputeFence:=TpvVulkanFence.Create(pvApplication.VulkanDevice);
       try

        CountMipMapLevelSets:=Min(((MipMaps-1)+3) shr 2,8);

        Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_cubemap_'+DownsampleFormatVariant+'_comp.spv');
        try
         DownsampleComputeShaderModule:=TpvVulkanShaderModule.Create(pvApplication.VulkanDevice,Stream);
        finally
         Stream.Free;
        end;

        try

         DownsampleVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,DownsampleComputeShaderModule,'main');

         try

          DownsampleVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(pvApplication.VulkanDevice);
          DownsampleVulkanDescriptorSetLayout.AddBinding(0,
                                                         VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                                         1,
                                                         TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                         []);
          DownsampleVulkanDescriptorSetLayout.AddBinding(1,
                                                         VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                                         4,
                                                         TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                         []);
          DownsampleVulkanDescriptorSetLayout.Initialize;

          DownsampleVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(pvApplication.VulkanDevice,
                                                                         TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                         CountMipMapLevelSets);
          DownsampleVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,CountMipMapLevelSets*5);
          DownsampleVulkanDescriptorPool.Initialize;

          for MipMapLevelSetIndex:=0 to CountMipMapLevelSets-1 do begin

           DownsampleVulkanSourceImageViews[MipMapLevelSetIndex]:=TpvVulkanImageView.Create(pvApplication.VulkanDevice,
                                                                                            fVulkanImage,
                                                                                            TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE),
                                                                                            TVkFormat(IfThen(AdditionalImageFormat<>VK_FORMAT_UNDEFINED,TVkInt32(AdditionalImageFormat),TVkInt32(aImageFormat))),
                                                                                            TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                            TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                            TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                            TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                            TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                            Min(MipMapLevelSetIndex shl 2,MipMaps-1),
                                                                                            1,
                                                                                            0,
                                                                                            6);

           for Index:=0 to 3 do begin
            DownsampleVulkanTargetImageViews[MipMapLevelSetIndex,Index]:=TpvVulkanImageView.Create(pvApplication.VulkanDevice,
                                                                                                   fVulkanImage,
                                                                                                   TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE),
                                                                                                   TVkFormat(IfThen(AdditionalImageFormat<>VK_FORMAT_UNDEFINED,TVkInt32(AdditionalImageFormat),TVkInt32(aImageFormat))),
                                                                                                   TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                                   TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                                   TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                                   TVkComponentSwizzle(VK_COMPONENT_SWIZZLE_IDENTITY),
                                                                                                   TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                                   Min(Min(MipMapLevelSetIndex shl 2,MipMaps-1)+(Index+1),MipMaps-1),
                                                                                                   1,
                                                                                                   0,
                                                                                                   6);
           end;

           DownsampleVulkanDescriptorSets[MipMapLevelSetIndex]:=TpvVulkanDescriptorSet.Create(DownsampleVulkanDescriptorPool,
                                                                                              DownsampleVulkanDescriptorSetLayout);
           try
            DownsampleVulkanDescriptorSets[MipMapLevelSetIndex].WriteToDescriptorSet(0,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                                     [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                                    DownsampleVulkanSourceImageViews[MipMapLevelSetIndex].Handle,
                                                                                                                    VK_IMAGE_LAYOUT_GENERAL)],
                                                                                     [],
                                                                                     [],
                                                                                     false);
            DownsampleVulkanDescriptorSets[MipMapLevelSetIndex].WriteToDescriptorSet(1,
                                                                                     0,
                                                                                     4,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                                     [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                                    DownsampleVulkanTargetImageViews[MipMapLevelSetIndex,0].Handle,
                                                                                                                    VK_IMAGE_LAYOUT_GENERAL),
                                                                                      TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                                    DownsampleVulkanTargetImageViews[MipMapLevelSetIndex,1].Handle,
                                                                                                                    VK_IMAGE_LAYOUT_GENERAL),
                                                                                      TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                                    DownsampleVulkanTargetImageViews[MipMapLevelSetIndex,2].Handle,
                                                                                                                    VK_IMAGE_LAYOUT_GENERAL),
                                                                                      TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                                    DownsampleVulkanTargetImageViews[MipMapLevelSetIndex,3].Handle,
                                                                                                                    VK_IMAGE_LAYOUT_GENERAL)],
                                                                                     [],
                                                                                     [],
                                                                                     false);
           finally
            DownsampleVulkanDescriptorSets[MipMapLevelSetIndex].Flush;
           end;

          end;

          try

           DownsampleVulkanComputePipelineLayout:=TpvVulkanPipelineLayout.Create(pvApplication.VulkanDevice);
           try
            DownsampleVulkanComputePipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TpvUInt32)); // for base mip map level set index
            DownsampleVulkanComputePipelineLayout.AddDescriptorSetLayout(DownsampleVulkanDescriptorSetLayout);
            DownsampleVulkanComputePipelineLayout.Initialize;

            DownsampleVulkanComputePipeline:=TpvVulkanComputePipeline.Create(pvApplication.VulkanDevice,
                                                                             pvApplication.VulkanPipelineCache,
                                                                             0,
                                                                             DownsampleVulkanPipelineShaderStageCompute,
                                                                             DownsampleVulkanComputePipelineLayout,
                                                                             nil,
                                                                             0);
            try

             ComputeCommandBuffer.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));

             ComputeCommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT));

             ComputeCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,DownsampleVulkanComputePipeline.Handle);

             for MipMapLevelSetIndex:=0 to CountMipMapLevelSets-1 do begin

              DownsampleMipMapIndex:=(MipMapLevelSetIndex shl 2) or 1;

              DownsampleCountMipMaps:=Min(4,MipMaps-TpvInt32(DownsampleMipMapIndex));

              if DownsampleCountMipMaps<=0 then begin
               break;
              end;

              ComputeCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                                         DownsampleVulkanComputePipelineLayout.Handle,
                                                         0,
                                                         1,
                                                         @DownsampleVulkanDescriptorSets[MipMapLevelSetIndex].Handle,
                                                         0,
                                                         nil);

              ComputeCommandBuffer.CmdPushConstants(DownsampleVulkanComputePipelineLayout.Handle,
                                                    TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                                    0,
                                                    SizeOf(TpvUInt32),
                                                    @DownsampleCountMipMaps);

              ComputeCommandBuffer.CmdDispatch(Max(1,(fWidth+((1 shl (3+DownsampleMipMapIndex))-1)) shr (3+DownsampleMipMapIndex)),
                                               Max(1,(fHeight+((1 shl (3+DownsampleMipMapIndex))-1)) shr (3+DownsampleMipMapIndex)),
                                               6);

              FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
              ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
              ImageMemoryBarrier.pNext:=nil;
              ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
              ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
              ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
              ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_GENERAL;
              ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
              ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
              ImageMemoryBarrier.image:=fVulkanImage.Handle;
              ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
              ImageMemoryBarrier.subresourceRange.baseMipLevel:=DownsampleMipMapIndex;
              ImageMemoryBarrier.subresourceRange.levelCount:=DownsampleCountMipMaps;
              ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
              ImageMemoryBarrier.subresourceRange.layerCount:=1;
              ComputeCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                                      0,
                                                      0,nil,
                                                      0,nil,
                                                      1,@ImageMemoryBarrier);

             end;

{            FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
             ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
             ImageMemoryBarrier.pNext:=nil;
             ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
             ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
             ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
             ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
             ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
             ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
             ImageMemoryBarrier.image:=fVulkanImage.Handle;
             ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
             ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
             ImageMemoryBarrier.subresourceRange.levelCount:=MipMaps;
             ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
             ImageMemoryBarrier.subresourceRange.layerCount:=1;
             ComputeCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                                     0,
                                                     0,nil,
                                                     0,nil,
                                                     1,@ImageMemoryBarrier);//}

             ComputeCommandBuffer.EndRecording;

             ComputeCommandBuffer.Execute(ComputeQueue,TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),nil,nil,ComputeFence,true);

            finally
             FreeAndNil(DownsampleVulkanComputePipeline);
            end; 

           finally
            FreeAndNil(DownsampleVulkanComputePipelineLayout);
           end;

          finally
            
           for MipMapLevelSetIndex:=0 to CountMipMapLevelSets-1 do begin
            FreeAndNil(DownsampleVulkanDescriptorSets[MipMapLevelSetIndex]);
            for Index:=0 to 3 do begin
             FreeAndNil(DownsampleVulkanTargetImageViews[MipMapLevelSetIndex,Index]);
            end;
            FreeAndNil(DownsampleVulkanSourceImageViews[MipMapLevelSetIndex]);
           end;

           FreeAndNil(DownsampleVulkanDescriptorPool);

           FreeAndNil(DownsampleVulkanDescriptorSetLayout);

          end;
          
         finally
          FreeAndNil(DownsampleVulkanPipelineShaderStageCompute);
         end; 

        finally
         FreeAndNil(DownsampleComputeShaderModule);
        end;  

        FillChar(ImageSubresourceRange,SizeOf(TVkImageSubresourceRange),#0);
        ImageSubresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
        ImageSubresourceRange.baseMipLevel:=0;
        ImageSubresourceRange.levelCount:=MipMaps;
        ImageSubresourceRange.baseArrayLayer:=0;
        ImageSubresourceRange.layerCount:=6;

       finally
        FreeAndNil(ComputeFence);
       end;

      finally
       FreeAndNil(ComputeCommandBuffer);
      end;

     finally
      FreeAndNil(ComputeCommandPool);
     end; 

     fVulkanImage.SetLayout(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                            TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                            TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                            @ImageSubresourceRange,
                            GraphicsCommandBuffer,
                            GraphicsQueue,
                            GraphicsFence,
                            true);

    end else begin

     // Without compute shader
     
     fVulkanImage.SetLayout(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                            TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                            TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL),
                            @ImageSubresourceRange,
                            GraphicsCommandBuffer,
                            GraphicsQueue,
                            GraphicsFence,
                            true);

     ImageMemoryBarrier:=TVkImageMemoryBarrier.Create(0,
                                                      0,
                                                      VK_IMAGE_LAYOUT_UNDEFINED,
                                                      VK_IMAGE_LAYOUT_UNDEFINED,
                                                      TVkQueue(VK_QUEUE_FAMILY_IGNORED),
                                                      TVkQueue(VK_QUEUE_FAMILY_IGNORED),
                                                      fVulkanImage.Handle,
                                                      ImageSubresourceRange);

     GraphicsCommandBuffer.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));
     GraphicsCommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT));
     for Index:=1 to MipMaps-1 do begin

      ImageMemoryBarrier.subresourceRange.levelCount:=1;
      ImageMemoryBarrier.subresourceRange.baseMipLevel:=Index-1;
      ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
      ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
      ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
      ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
      GraphicsCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                               TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                               0,
                                               0,
                                               nil,
                                               0,
                                               nil,
                                               1,
                                               @ImageMemoryBarrier);

      for FaceIndex:=0 to 5 do begin
       ImageBlit:=TVkImageBlit.Create(TVkImageSubresourceLayers.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                       Index-1,
                                                                       FaceIndex,
                                                                       1),
                                      [TVkOffset3D.Create(0,
                                                          0,
                                                          0),
                                       TVkOffset3D.Create(fWidth shr (Index-1),
                                                          fHeight shr (Index-1),
                                                          1)],
                                      TVkImageSubresourceLayers.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                       Index,
                                                                       FaceIndex,
                                                                       1),
                                      [TVkOffset3D.Create(0,
                                                          0,
                                                          0),
                                       TVkOffset3D.Create(fWidth shr Index,
                                                          fHeight shr Index,
                                                          1)]
                                     );

       GraphicsCommandBuffer.CmdBlitImage(fVulkanImage.Handle,VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                                          fVulkanImage.Handle,VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                                          1,
                                          @ImageBlit,
                                          TVkFilter(VK_FILTER_LINEAR));
      end;

      ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
      ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
      ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
      ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
      GraphicsCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                               TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                               0,
                                               0,
                                               nil,
                                               0,
                                               nil,
                                               1,
                                               @ImageMemoryBarrier);

     end;
     ImageMemoryBarrier.subresourceRange.baseMipLevel:=MipMaps-1;
     ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
     ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
     ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
     ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
     GraphicsCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                              TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                              0,
                                              0,
                                              nil,
                                              0,
                                              nil,
                                              1,
                                              @ImageMemoryBarrier);
     GraphicsCommandBuffer.EndRecording;
     GraphicsCommandBuffer.Execute(GraphicsQueue,TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),nil,nil,GraphicsFence,true);

{   end else begin

     fVulkanImage.SetLayout(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                            TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                            TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                            @ImageSubresourceRange,
                            GraphicsCommandBuffer,
                            GraphicsQueue,
                            GraphicsFence,
                            true);}

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

destructor TpvScene3DRendererEnvironmentCubeMap.Destroy;
begin
{if assigned(fMemoryBlock) and assigned(fMemoryBlock.MemoryManager) then begin
  fMemoryBlock.MemoryManager.FreeMemoryBlock(fMemoryBlock);
 end;}
 FreeAndNil(fMemoryBlock);
 FreeAndNil(fVulkanImageView);
 FreeAndNil(fVulkanImage);
 FreeAndNil(fVulkanPipelineShaderStageCompute);
 FreeAndNil(fComputeShaderModule);
 inherited Destroy;
end;

end.
