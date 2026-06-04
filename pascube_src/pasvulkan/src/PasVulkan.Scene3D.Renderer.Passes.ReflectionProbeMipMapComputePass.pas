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
unit PasVulkan.Scene3D.Renderer.Passes.ReflectionProbeMipMapComputePass;
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
     PasVulkan.Scene3D.Renderer.Instance,
     PasVulkan.Scene3D.Renderer.SkyBox;

type { TpvScene3DRendererPassesReflectionProbeMipMapComputePass }
     TpvScene3DRendererPassesReflectionProbeMipMapComputePass=class(TpvFrameGraph.TComputePass)
      private
       fInstance:TpvScene3DRendererInstance;
       fResourceInput:TpvFrameGraph.TPass.TUsedImageResource;
       fDownsampleLevel0ComputeShaderModule:TpvVulkanShaderModule;
       fDownsampleLevel1ComputeShaderModule:TpvVulkanShaderModule;
       fDownsampleLevel2ComputeShaderModule:TpvVulkanShaderModule;
       fVulkanImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
       fVulkanPipelineShaderStageDownsampleLevel0Compute:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageDownsampleLevel1Compute:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageDownsampleLevel2Compute:TpvVulkanPipelineShaderStage;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1,0..15] of TpvVulkanDescriptorSet;
       fPipelineLayout:TpvVulkanPipelineLayout;
       fPipelineLevel0:TpvVulkanComputePipeline;
       fPipelineLevel1:TpvVulkanComputePipeline;
       fPipelineLevel2:TpvVulkanComputePipeline;
      public
       constructor Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance); reintroduce;
       destructor Destroy; override;
       procedure AcquirePersistentResources; override;
       procedure ReleasePersistentResources; override;
       procedure AcquireVolatileResources; override;
       procedure ReleaseVolatileResources; override;
       procedure Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt); override;
       procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt); override;
     end;

implementation

{ TpvScene3DRendererPassesReflectionProbeMipMapComputePass }

constructor TpvScene3DRendererPassesReflectionProbeMipMapComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='ReflectionProbeMipMapComputePass';

 fResourceInput:=AddImageInput('resourcetype_reflectionprobe_color',
                               'resource_reflectionprobe_color',
                               VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                               []
                              );

end;

destructor TpvScene3DRendererPassesReflectionProbeMipMapComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesReflectionProbeMipMapComputePass.AcquirePersistentResources;
var Stream:TStream;
    Format:string;
begin

 inherited AcquirePersistentResources;

{case fInstance.Renderer.OptimizedNonAlphaFormat of
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
 end;}
 Format:='rgba16f';

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_'+Format+'_multiview_level0_comp.spv');
 try
  fDownsampleLevel0ComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_'+Format+'_multiview_level1_comp.spv');
 try
  fDownsampleLevel1ComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_'+Format+'_multiview_level2_comp.spv');
 try
  fDownsampleLevel2ComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageDownsampleLevel0Compute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fDownsampleLevel0ComputeShaderModule,'main');

 fVulkanPipelineShaderStageDownsampleLevel1Compute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fDownsampleLevel1ComputeShaderModule,'main');

 fVulkanPipelineShaderStageDownsampleLevel2Compute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fDownsampleLevel2ComputeShaderModule,'main');

end;

procedure TpvScene3DRendererPassesReflectionProbeMipMapComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStageDownsampleLevel2Compute);
 FreeAndNil(fVulkanPipelineShaderStageDownsampleLevel1Compute);
 FreeAndNil(fVulkanPipelineShaderStageDownsampleLevel0Compute);
 FreeAndNil(fDownsampleLevel2ComputeShaderModule);
 FreeAndNil(fDownsampleLevel1ComputeShaderModule);
 FreeAndNil(fDownsampleLevel0ComputeShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesReflectionProbeMipMapComputePass.AcquireVolatileResources;
var InFlightFrameIndex,MipMapLevelIndex:TpvInt32;
    ImageViewType:TVkImageViewType;
begin

 inherited AcquireVolatileResources;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames*fInstance.ImageBasedLightingReflectionProbeCubeMaps.MipMaps);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fInstance.Renderer.CountInFlightFrames*fInstance.ImageBasedLightingReflectionProbeCubeMaps.MipMaps);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fInstance.Renderer.CountInFlightFrames*fInstance.ImageBasedLightingReflectionProbeCubeMaps.MipMaps);
 fVulkanDescriptorPool.Initialize;

 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
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

 fPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 fPipelineLayout.Initialize;

 fPipelineLevel0:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                  fInstance.Renderer.VulkanPipelineCache,
                                                  0,
                                                  fVulkanPipelineShaderStageDownsampleLevel0Compute,
                                                  fPipelineLayout,
                                                  nil,
                                                  0);

 fPipelineLevel1:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                  fInstance.Renderer.VulkanPipelineCache,
                                                  0,
                                                  fVulkanPipelineShaderStageDownsampleLevel1Compute,
                                                  fPipelineLayout,
                                                  nil,
                                                  0);

 fPipelineLevel2:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                  fInstance.Renderer.VulkanPipelineCache,
                                                  0,
                                                  fVulkanPipelineShaderStageDownsampleLevel2Compute,
                                                  fPipelineLayout,
                                                  nil,
                                                  0);

 ImageViewType:=TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D_ARRAY);

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  fVulkanImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(fInstance.Renderer.VulkanDevice,
                                                                   fResourceInput.VulkanImages[InFlightFrameIndex],
                                                                   ImageViewType,
                                                                   TpvFrameGraph.TImageResourceType(fResourceInput.ResourceType).Format,
                                                                   VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                   VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                   VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                   VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                   TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                   0,
                                                                   1,
                                                                   0,
                                                                   6
                                                                  );
  for MipMapLevelIndex:=0 to fInstance.ImageBasedLightingReflectionProbeCubeMaps.MipMaps-1 do begin
   fVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                                                             fVulkanDescriptorSetLayout);
   if MipMapLevelIndex=0 then begin
    fVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelIndex].WriteToDescriptorSet(0,
                                                                                    0,
                                                                                    1,
                                                                                    TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                    [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                                                                   fVulkanImageViews[InFlightFrameIndex].Handle,
                                                                                                                   fResourceInput.ResourceTransition.Layout)],
                                                                                    [],
                                                                                    [],
                                                                                    false
                                                                                   );
   end else begin
    fVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelIndex].WriteToDescriptorSet(0,
                                                                                    0,
                                                                                    1,
                                                                                    TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                    [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                                                                   fInstance.ImageBasedLightingReflectionProbeCubeMaps.RawImageViews[InFlightFrameIndex,MipMapLevelIndex-1].Handle,
                                                                                                                   VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                                    [],
                                                                                    [],
                                                                                    false
                                                                                   );
   end;
   fVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelIndex].WriteToDescriptorSet(1,
                                                                                   0,
                                                                                   1,
                                                                                   TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                                   [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                                  fInstance.ImageBasedLightingReflectionProbeCubeMaps.RawImageViews[InFlightFrameIndex,MipMapLevelIndex].Handle,
                                                                                                                  VK_IMAGE_LAYOUT_GENERAL)],
                                                                                   [],
                                                                                   [],
                                                                                   false
                                                                                  );
   fVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelIndex].Flush;
  end;
 end;

end;

procedure TpvScene3DRendererPassesReflectionProbeMipMapComputePass.ReleaseVolatileResources;
var InFlightFrameIndex,MipMapLevelIndex:TpvInt32;
begin
 FreeAndNil(fPipelineLevel2);
 FreeAndNil(fPipelineLevel1);
 FreeAndNil(fPipelineLevel0);
 FreeAndNil(fPipelineLayout);
 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  for MipMapLevelIndex:=0 to fInstance.ImageBasedLightingReflectionProbeCubeMaps.MipMaps-1 do begin
   FreeAndNil(fVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelIndex]);
  end;
  FreeAndNil(fVulkanImageViews[InFlightFrameIndex]);
 end;
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanDescriptorPool);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesReflectionProbeMipMapComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesReflectionProbeMipMapComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameIndex,MipMapLevelIndex:TpvInt32;
    Pipeline:TpvVulkanComputePipeline;
    ImageMemoryBarrier:TVkImageMemoryBarrier;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 InFlightFrameIndex:=aInFlightFrameIndex;

{FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
 ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
 ImageMemoryBarrier.pNext:=nil;
 ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
 ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
 ImageMemoryBarrier.oldLayout:=fResourceInput.ResourceTransition.Layout;
 ImageMemoryBarrier.newLayout:=fResourceInput.ResourceTransition.Layout;
 ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 ImageMemoryBarrier.image:=fResourceInput.VulkanImages[InFlightFrameIndex].Handle;
 ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
 ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
 ImageMemoryBarrier.subresourceRange.levelCount:=1;
 ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
 ImageMemoryBarrier.subresourceRange.layerCount:=6;
 aCommandBuffer.CmdPipelineBarrier(FrameGraph.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   0,
                                   0,nil,
                                   0,nil,
                                   1,@ImageMemoryBarrier);}

 FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
 ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
 ImageMemoryBarrier.pNext:=nil;
 ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
 ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
 ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
 ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_GENERAL;
 ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 ImageMemoryBarrier.image:=fInstance.ImageBasedLightingReflectionProbeCubeMaps.RawImages[InFlightFrameIndex].Handle;
 ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
 ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
 ImageMemoryBarrier.subresourceRange.levelCount:=fInstance.ImageBasedLightingReflectionProbeCubeMaps.MipMaps;
 ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
 ImageMemoryBarrier.subresourceRange.layerCount:=6;
 aCommandBuffer.CmdPipelineBarrier(FrameGraph.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   0,
                                   0,nil,
                                   0,nil,
                                   1,@ImageMemoryBarrier);

 for MipMapLevelIndex:=0 to fInstance.ImageBasedLightingReflectionProbeCubeMaps.MipMaps-1 do begin

  case MipMapLevelIndex of
   0:begin
    Pipeline:=fPipelineLevel0;
   end;
   1:begin
    Pipeline:=fPipelineLevel1;
   end;
   else begin
    Pipeline:=fPipelineLevel2;
   end;
  end;

  if MipMapLevelIndex<3 then begin
   aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,Pipeline.Handle);
  end;

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       fPipelineLayout.Handle,
                                       0,
                                       1,
                                       @fVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelIndex].Handle,
                                       0,
                                       nil);

  aCommandBuffer.CmdDispatch(Max(1,(fInstance.ImageBasedLightingReflectionProbeCubeMaps.Width+((1 shl (4+MipMapLevelIndex))-1)) shr (4+MipMapLevelIndex)),
                             Max(1,(fInstance.ImageBasedLightingReflectionProbeCubeMaps.Height+((1 shl (4+MipMapLevelIndex))-1)) shr (4+MipMapLevelIndex)),
                             6);

  FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarrier.pNext:=nil;
  ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
  ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.image:=fInstance.ImageBasedLightingReflectionProbeCubeMaps.RawImages[InFlightFrameIndex].Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=MipMapLevelIndex;
  ImageMemoryBarrier.subresourceRange.levelCount:=1;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=6;
  if (MipMapLevelIndex+1)<fInstance.ImageBasedLightingReflectionProbeCubeMaps.MipMaps then begin
   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     0,
                                     0,nil,
                                     0,nil,
                                     1,@ImageMemoryBarrier);
  end else begin
   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     FrameGraph.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                     0,
                                     0,nil,
                                     0,nil,
                                     1,@ImageMemoryBarrier);
  end;

 end;

end;

end.
