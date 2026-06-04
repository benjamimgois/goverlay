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
unit PasVulkan.Scene3D.Renderer.CubeMapIBLFilter;
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
     PasVulkan.FrameGraph,
     PasVulkan.Scene3D,
     PasVulkan.Scene3D.Renderer.Globals,
     PasVulkan.Scene3D.Renderer,
     PasVulkan.Scene3D.Renderer.MipmapImageCubeMap;

type { TpvScene3DRendererCubeMapIBLFilter }
     TpvScene3DRendererCubeMapIBLFilter=class
      public
       const GGX=0;
             Charlie=1;
             Lambertian=2;
       type TPushConstants=record
             MipMapLevel:TpvInt32;
             MaxMipMapLevel:TpvInt32;
             NumSamples:TpvInt32;
             Which:TpvInt32;
            end;
      private
       fScene3D:TpvScene3D;
       fRenderer:TpvScene3DRenderer;
       fVulkanDevice:TpvVulkanDevice;
       fSourceCubeMap:TpvScene3DRendererMipmapImageCubeMap;
       fDestinationCubeMap:TpvScene3DRendererMipmapImageCubeMap;
       fWhich:TpvSizeInt;
       fComputeShaderModule:TpvVulkanShaderModule;
       fVulkanImageView:TpvVulkanImageView;
       fVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSets:array[0..15] of TpvVulkanDescriptorSet;
       fPipelineLayout:TpvVulkanPipelineLayout;
       fPipeline:TpvVulkanComputePipeline;
      public
       constructor Create(const aScene3D:TpvScene3D;
                          const aRenderer:TpvScene3DRenderer; 
                          const aSourceCubeMap:TpvScene3DRendererMipmapImageCubeMap;
                          const aDestinationCubeMap:TpvScene3DRendererMipmapImageCubeMap;
                          const aWhich:TpvSizeInt); reintroduce;
       destructor Destroy; override;
       procedure AcquirePersistentResources;
       procedure ReleasePersistentResources;
       procedure AcquireVolatileResources;
       procedure ReleaseVolatileResources;
       procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
     end;

implementation

{ TpvScene3DRendererCubeMapIBLFilter }

constructor TpvScene3DRendererCubeMapIBLFilter.Create(const aScene3D:TpvScene3D;
                                                      const aRenderer:TpvScene3DRenderer;       
                                                      const aSourceCubeMap:TpvScene3DRendererMipmapImageCubeMap;
                                                      const aDestinationCubeMap:TpvScene3DRendererMipmapImageCubeMap;
                                                      const aWhich:TpvSizeInt);
begin

 inherited Create;

 fScene3D:=aScene3D;

 fRenderer:=aRenderer;
 
 fVulkanDevice:=fScene3D.VulkanDevice;

 fSourceCubeMap:=aSourceCubeMap;
 
 fDestinationCubeMap:=aDestinationCubeMap;

 fWhich:=aWhich;

end;

destructor TpvScene3DRendererCubeMapIBLFilter.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererCubeMapIBLFilter.AcquirePersistentResources;
var Stream:TStream;
    Format:string;
begin

 case fSourceCubeMap.Format of
  VK_FORMAT_B10G11R11_UFLOAT_PACK32:begin
   Format:='r11g11b10f';
  end;
  VK_FORMAT_R16G16B16A16_SFLOAT:begin
   Format:='rgba16f';
  end;
  else begin
   Assert(false);
   Format:='';
  end;
 end;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cubemap_filter_comp.spv');
 try
  fComputeShaderModule:=TpvVulkanShaderModule.Create(fVulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fVulkanDevice.DebugUtils.SetObjectName(fComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererCubeMapIBLFilter.ComputeShaderModule');

 fVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModule,'main');

end;

procedure TpvScene3DRendererCubeMapIBLFilter.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStageCompute);
 FreeAndNil(fComputeShaderModule);
end;

procedure TpvScene3DRendererCubeMapIBLFilter.AcquireVolatileResources;
var MipMapLevelIndex:TpvInt32;
    ImageViewType:TVkImageViewType;
begin

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fVulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fSourceCubeMap.MipMapLevels);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fSourceCubeMap.MipMapLevels);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fDestinationCubeMap.MipMapLevels);
 fVulkanDescriptorPool.Initialize;

 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fVulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0,
                                       VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(1,
                                       VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.Initialize;

 fPipelineLayout:=TpvVulkanPipelineLayout.Create(fVulkanDevice);
 fPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TpvScene3DRendererCubeMapIBLFilter.TPushConstants));
 fPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 fPipelineLayout.Initialize;

 fPipeline:=TpvVulkanComputePipeline.Create(fVulkanDevice,
                                            fScene3D.VulkanPipelineCache,
                                            0,
                                            fVulkanPipelineShaderStageCompute,
                                            fPipelineLayout,
                                            nil,
                                            0);

 ImageViewType:=TVkImageViewType(VK_IMAGE_VIEW_TYPE_CUBE);

 fVulkanImageView:=TpvVulkanImageView.Create(fVulkanDevice,
                                             fSourceCubeMap.VulkanImage,
                                             ImageViewType,
                                             fSourceCubeMap.Format,
                                             VK_COMPONENT_SWIZZLE_IDENTITY,
                                             VK_COMPONENT_SWIZZLE_IDENTITY,
                                             VK_COMPONENT_SWIZZLE_IDENTITY,
                                             VK_COMPONENT_SWIZZLE_IDENTITY,
                                             TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                             0,
                                             fSourceCubeMap.MipMapLevels,
                                             0,
                                             6
                                            );

 for MipMapLevelIndex:=0 to fDestinationCubeMap.MipMapLevels-1 do begin
  fVulkanDescriptorSets[MipMapLevelIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                                         fVulkanDescriptorSetLayout);
  fVulkanDescriptorSets[MipMapLevelIndex].WriteToDescriptorSet(0,
                                                               0,
                                                               1,
                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                               [TVkDescriptorImageInfo.Create(fRenderer.ClampedSampler.Handle,
                                                                                              fVulkanImageView.Handle,
                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                               [],
                                                               [],
                                                               false
                                                              );
   fVulkanDescriptorSets[MipMapLevelIndex].WriteToDescriptorSet(1,
                                                                0,
                                                                1,
                                                                TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                               fDestinationCubeMap.VulkanImageViews[MipMapLevelIndex].Handle,
                                                                                               VK_IMAGE_LAYOUT_GENERAL)],
                                                                [],
                                                                [],
                                                                false
                                                               );
  fVulkanDescriptorSets[MipMapLevelIndex].Flush;
 end;

end;

procedure TpvScene3DRendererCubeMapIBLFilter.ReleaseVolatileResources;
var MipMapLevelIndex:TpvInt32;
begin
 FreeAndNil(fPipeline);
 FreeAndNil(fPipelineLayout);
 for MipMapLevelIndex:=0 to fDestinationCubeMap.MipMapLevels-1 do begin
  FreeAndNil(fVulkanDescriptorSets[MipMapLevelIndex]);
 end;
 FreeAndNil(fVulkanImageView);
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanDescriptorPool);
end;

procedure TpvScene3DRendererCubeMapIBLFilter.Execute(const aCommandBuffer:TpvVulkanCommandBuffer);
const Samples=128;
var MipMapLevelIndex:TpvInt32;
    Pipeline:TpvVulkanComputePipeline;
    ImageMemoryBarrier:TVkImageMemoryBarrier;
    PushConstants:TpvScene3DRendererCubeMapIBLFilter.TPushConstants;
begin

{FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
 ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
 ImageMemoryBarrier.pNext:=nil;
 ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
 ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
 ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
 ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
 ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 ImageMemoryBarrier.image:=fSourceCubeMap.VulkanImage.Handle;
 ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
 ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
 ImageMemoryBarrier.subresourceRange.levelCount:=1;
 ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
 ImageMemoryBarrier.subresourceRange.layerCount:=6;
 aCommandBuffer.CmdPipelineBarrier(fVulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   0,
                                   0,nil,
                                   0,nil,
                                   1,@ImageMemoryBarrier);//}

 FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
 ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
 ImageMemoryBarrier.pNext:=nil;
 ImageMemoryBarrier.srcAccessMask:=0;//TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
 ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
 ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_UNDEFINED;
 ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_GENERAL;
 ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 ImageMemoryBarrier.image:=fDestinationCubeMap.VulkanImage.Handle;
 ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
 ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
 ImageMemoryBarrier.subresourceRange.levelCount:=fDestinationCubeMap.MipMapLevels;
 ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
 ImageMemoryBarrier.subresourceRange.layerCount:=6;
 aCommandBuffer.CmdPipelineBarrier(fVulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   0,
                                   0,nil,
                                   0,nil,
                                   1,@ImageMemoryBarrier);

 Pipeline:=fPipeline;

 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,Pipeline.Handle);

 for MipMapLevelIndex:=0 to fDestinationCubeMap.MipMapLevels-1 do begin

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       fPipelineLayout.Handle,
                                       0,
                                       1,
                                       @fVulkanDescriptorSets[MipMapLevelIndex].Handle,
                                       0,
                                       nil);

  PushConstants.MipMapLevel:=MipMapLevelIndex;
  PushConstants.MaxMipMapLevel:=fDestinationCubeMap.MipMapLevels-1;
  if (fWhich=0) and (MipMapLevelIndex=0) then begin
   PushConstants.NumSamples:=1;
  end else begin
   PushConstants.NumSamples:=128;//Min(32 shl MipMapLevelIndex,Samples);
  end;
  PushConstants.Which:=fWhich;

  aCommandBuffer.CmdPushConstants(fPipelineLayout.Handle,
                                  TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TpvScene3DRendererCubeMapIBLFilter.TPushConstants),
                                  @PushConstants);

  aCommandBuffer.CmdDispatch(Max(1,(fDestinationCubeMap.Width+((1 shl (4+MipMapLevelIndex))-1)) shr (4+MipMapLevelIndex)),
                             Max(1,(fDestinationCubeMap.Height+((1 shl (4+MipMapLevelIndex))-1)) shr (4+MipMapLevelIndex)),
                             6);

 end;

 FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
 ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
 ImageMemoryBarrier.pNext:=nil;
 ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
 ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
 ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
 ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
 ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 ImageMemoryBarrier.image:=fDestinationCubeMap.VulkanImage.Handle;
 ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
 ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
 ImageMemoryBarrier.subresourceRange.levelCount:=fDestinationCubeMap.MipMapLevels;
 ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
 ImageMemoryBarrier.subresourceRange.layerCount:=6;
 aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   fVulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                   0,
                                   0,nil,
                                   0,nil,
                                   1,@ImageMemoryBarrier);

end;

end.
