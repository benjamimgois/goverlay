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
unit PasVulkan.Scene3D.Renderer.Passes.AmbientOcclusionDepthMipMapComputePass;
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
     PasVulkan.Scene3D.Renderer.Instance;

type { TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass }
     TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass=class(TpvFrameGraph.TComputePass)
      public
       type TPushConstants=packed record
             CountSamples:TpvUInt32;
             BaseViewIndex:TpvUInt32;
            end;
      private
       fInstance:TpvScene3DRendererInstance;
       fResourceInput:TpvFrameGraph.TPass.TUsedImageResource;
       fFirstPassComputeShaderModule:TpvVulkanShaderModule;
       fReductionComputeShaderModule:TpvVulkanShaderModule;
       fVulkanImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
       fFirstPassVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fReductionVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fFirstPassVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fFirstPassVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fFirstPassVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fReductionVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fReductionVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fReductionVulkanDescriptorSets:array[0..MaxInFlightFrames-1,0..7] of TpvVulkanDescriptorSet;
       fFirstPassPipelineLayout:TpvVulkanPipelineLayout;
       fReductionPipelineLayout:TpvVulkanPipelineLayout;
       fFirstPassPipeline:TpvVulkanComputePipeline;
       fReductionPipeline:TpvVulkanComputePipeline;
       fCountMipMapLevelSets:TpvSizeInt;
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

{ TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass  }

constructor TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='AmbientOcclusionDepthMipMapComputePass';

 if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin

  fResourceInput:=AddImageInput('resourcetype_depth',
                                'resource_depth_data',
                                VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                               );

 end else begin

  fResourceInput:=AddImageInput('resourcetype_msaa_depth',
                                'resource_msaa_depth_data',
                                VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                               );

 end;

end;

destructor TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass.AcquirePersistentResources;
var Stream:TStream;
begin

 inherited AcquirePersistentResources;

 if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
  if fInstance.CountSurfaceViews>1 then begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_ambientocclusion_gtao_depth_multiview_firstpass_comp.spv');
  end else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_ambientocclusion_gtao_depth_firstpass_comp.spv');
  end;
 end else begin
  if fInstance.CountSurfaceViews>1 then begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_ambientocclusion_gtao_depth_multiview_msaa_firstpass_comp.spv');
  end else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_ambientocclusion_gtao_depth_msaa_firstpass_comp.spv');
  end;
 end;
 try
  fFirstPassComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fFirstPassComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'AmbientOcclusionDepthMipMapComputePass.fFirstPassComputeShaderModule');

 if fInstance.CountSurfaceViews>1 then begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_ambientocclusion_gtao_depth_multiview_reduction_comp.spv');
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_ambientocclusion_gtao_depth_reduction_comp.spv');
 end;
 try
  fReductionComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fReductionComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'AmbientOcclusionDepthMipMapComputePass.fReductionComputeShaderModule');

 fFirstPassVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fFirstPassComputeShaderModule,'main');

 fReductionVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fReductionComputeShaderModule,'main');

end;

procedure TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fReductionVulkanPipelineShaderStageCompute);
 FreeAndNil(fFirstPassVulkanPipelineShaderStageCompute);
 FreeAndNil(fReductionComputeShaderModule);
 FreeAndNil(fFirstPassComputeShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass.AcquireVolatileResources;
var InFlightFrameIndex,MipMapLevelSetIndex:TpvInt32;
    ImageViewType:TVkImageViewType;
    Sampler:TpvVulkanSampler;
begin

 inherited AcquireVolatileResources;

 if fInstance.CountSurfaceViews>1 then begin
  ImageViewType:=TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D_ARRAY);
 end else begin
  ImageViewType:=TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D);
 end;

 if fInstance.ZFar<0.0 then begin
  Sampler:=fInstance.Renderer.MipMapMinFilterSampler;
 end else begin
  Sampler:=fInstance.Renderer.MipMapMaxFilterSampler;
 end;

 fFirstPassVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                                TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                fInstance.Renderer.CountInFlightFrames);
 fFirstPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fInstance.Renderer.CountInFlightFrames);
 fFirstPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fInstance.Renderer.CountInFlightFrames);
 fFirstPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,fInstance.Renderer.CountInFlightFrames*fInstance.AmbientOcclusionDepthMipmappedArray2DImage.MipMapLevels);
 fFirstPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,fInstance.Renderer.CountInFlightFrames*fInstance.AmbientOcclusionDepthMipmappedArray2DImage.MipMapLevels);
 fFirstPassVulkanDescriptorPool.Initialize;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fFirstPassVulkanDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'AmbientOcclusionDepthMipMapComputePass.fFirstPassVulkanDescriptorPool');

 fFirstPassVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fFirstPassVulkanDescriptorSetLayout.AddBinding(0,
                                                VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                1,
                                                TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                []);
 fFirstPassVulkanDescriptorSetLayout.AddBinding(1,
                                                VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                                1,
                                                TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                []);
 fFirstPassVulkanDescriptorSetLayout.AddBinding(2,
                                                VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                                1,
                                                TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                []);
 fFirstPassVulkanDescriptorSetLayout.Initialize;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fFirstPassVulkanDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'AmbientOcclusionDepthMipMapComputePass.fFirstPassVulkanDescriptorSetLayout');

 fFirstPassPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fFirstPassPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass.TPushConstants));
 fFirstPassPipelineLayout.AddDescriptorSetLayout(fFirstPassVulkanDescriptorSetLayout);
 fFirstPassPipelineLayout.Initialize;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fFirstPassPipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'AmbientOcclusionDepthMipMapComputePass.fFirstPassPipelineLayout');

 fFirstPassPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                     fInstance.Renderer.VulkanPipelineCache,
                                                     0,
                                                     fFirstPassVulkanPipelineShaderStageCompute,
                                                     fFirstPassPipelineLayout,
                                                     nil,
                                                     0);
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fFirstPassPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'AmbientOcclusionDepthMipMapComputePass.fFirstPassPipeline');

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  fVulkanImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(fInstance.Renderer.VulkanDevice,
                                                                   fResourceInput.VulkanImages[InFlightFrameIndex],
                                                                   ImageViewType,
                                                                   TpvFrameGraph.TImageResourceType(fResourceInput.ResourceType).Format,
                                                                   VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                   VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                   VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                   VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                   TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT),
                                                                   0,
                                                                   1,
                                                                   0,
                                                                   fInstance.CountSurfaceViews
                                                                  );
  fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fVulkanImageViews[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'AmbientOcclusionDepthMipMapComputePass.fVulkanImageViews['+IntToStr(InFlightFrameIndex)+']');

  fFirstPassVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fFirstPassVulkanDescriptorPool,
                                                                                    fFirstPassVulkanDescriptorSetLayout);
  fFirstPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                          [TVkDescriptorImageInfo.Create(Sampler.Handle,
                                                                                                         fVulkanImageViews[InFlightFrameIndex].Handle,
                                                                                                         fResourceInput.ResourceTransition.Layout)],
                                                                          [],
                                                                          [],
                                                                          false
                                                                         );
  fFirstPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                          [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                                         fInstance.AmbientOcclusionDepthMipmappedArray2DImage.VulkanImageViews[0].Handle,
                                                                                                         VK_IMAGE_LAYOUT_GENERAL)],
                                                                          [],
                                                                          [],
                                                                          false
                                                                         );
  fFirstPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                          [],
                                                                           [fInstance.VulkanViewUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                          [],
                                                                          false
                                                                         );
  fFirstPassVulkanDescriptorSets[InFlightFrameIndex].Flush;
  fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fFirstPassVulkanDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'AmbientOcclusionDepthMipMapComputePass.fFirstPassVulkanDescriptorSets['+IntToStr(InFlightFrameIndex)+']');
 end;

 /////

 fReductionVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames*4);
 fReductionVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fInstance.Renderer.CountInFlightFrames);
 fReductionVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fInstance.Renderer.CountInFlightFrames*(4*4));
 fReductionVulkanDescriptorPool.Initialize;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fReductionVulkanDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'AmbientOcclusionDepthMipMapComputePass.fReductionVulkanDescriptorPool');

 fReductionVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fReductionVulkanDescriptorSetLayout.AddBinding(0,
                                                VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                1,
                                                TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                []);
 fReductionVulkanDescriptorSetLayout.AddBinding(1,
                                                VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                                4,
                                                TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                []);
 fReductionVulkanDescriptorSetLayout.Initialize;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fReductionVulkanDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'AmbientOcclusionDepthMipMapComputePass.fReductionVulkanDescriptorSetLayout');

 fReductionPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fReductionPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TpvInt32));
 fReductionPipelineLayout.AddDescriptorSetLayout(fReductionVulkanDescriptorSetLayout);
 fReductionPipelineLayout.Initialize;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fReductionPipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'AmbientOcclusionDepthMipMapComputePass.fReductionPipelineLayout');

 fReductionPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                     fInstance.Renderer.VulkanPipelineCache,
                                                     0,
                                                     fReductionVulkanPipelineShaderStageCompute,
                                                     fReductionPipelineLayout,
                                                     nil,
                                                     0);
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fReductionPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'AmbientOcclusionDepthMipMapComputePass.fReductionPipeline');

 fCountMipMapLevelSets:=Min(((fInstance.AmbientOcclusionDepthMipmappedArray2DImage.MipMapLevels-1)+3) shr 2,8);

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  for MipMapLevelSetIndex:=0 to fCountMipMapLevelSets-1 do begin
   fReductionVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelSetIndex]:=TpvVulkanDescriptorSet.Create(fReductionVulkanDescriptorPool,
                                                                                                         fReductionVulkanDescriptorSetLayout);

   fReductionVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelSetIndex].WriteToDescriptorSet(0,
                                                                                               0,
                                                                                               1,
                                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                               [TVkDescriptorImageInfo.Create(Sampler.Handle,
                                                                                                                              fInstance.AmbientOcclusionDepthMipmappedArray2DImage.VulkanImageViews[Min(MipMapLevelSetIndex shl 2,fInstance.AmbientOcclusionDepthMipmappedArray2DImage.MipMapLevels-1)].Handle,
                                                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                                               [],
                                                                                               [],
                                                                                               false
                                                                                              );
   fReductionVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelSetIndex].WriteToDescriptorSet(1,
                                                                                               0,
                                                                                               4,
                                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                                               [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                                                              fInstance.AmbientOcclusionDepthMipmappedArray2DImage.VulkanImageViews[Min(((MipMapLevelSetIndex shl 2)+1),fInstance.AmbientOcclusionDepthMipmappedArray2DImage.MipMapLevels-1)].Handle,
                                                                                                                              VK_IMAGE_LAYOUT_GENERAL),
                                                                                                TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                                                              fInstance.AmbientOcclusionDepthMipmappedArray2DImage.VulkanImageViews[Min(((MipMapLevelSetIndex shl 2)+2),fInstance.AmbientOcclusionDepthMipmappedArray2DImage.MipMapLevels-1)].Handle,
                                                                                                                              VK_IMAGE_LAYOUT_GENERAL),
                                                                                                TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                                                              fInstance.AmbientOcclusionDepthMipmappedArray2DImage.VulkanImageViews[Min(((MipMapLevelSetIndex shl 2)+3),fInstance.AmbientOcclusionDepthMipmappedArray2DImage.MipMapLevels-1)].Handle,
                                                                                                                              VK_IMAGE_LAYOUT_GENERAL),
                                                                                                TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                                                              fInstance.AmbientOcclusionDepthMipmappedArray2DImage.VulkanImageViews[Min(((MipMapLevelSetIndex shl 2)+4),fInstance.AmbientOcclusionDepthMipmappedArray2DImage.MipMapLevels-1)].Handle,
                                                                                                                              VK_IMAGE_LAYOUT_GENERAL)],
                                                                                               [],
                                                                                               [],
                                                                                               false
                                                                                              );
   fReductionVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelSetIndex].Flush;
   fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fReductionVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelSetIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'AmbientOcclusionDepthMipMapComputePass.fReductionVulkanDescriptorSets['+IntToStr(InFlightFrameIndex)+','+IntToStr(MipMapLevelSetIndex)+']');
  end;
 end;

end;

procedure TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass.ReleaseVolatileResources;
var InFlightFrameIndex,MipMapLevelSetIndex:TpvInt32;
begin
 FreeAndNil(fReductionPipeline);
 FreeAndNil(fFirstPassPipeline);
 FreeAndNil(fReductionPipelineLayout);
 FreeAndNil(fFirstPassPipelineLayout);
 for InFlightFrameIndex:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  for MipMapLevelSetIndex:=0 to fCountMipMapLevelSets-1 do begin
   FreeAndNil(fReductionVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelSetIndex]);
  end;
  FreeAndNil(fFirstPassVulkanDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fVulkanImageViews[InFlightFrameIndex]);
 end;
 FreeAndNil(fReductionVulkanDescriptorSetLayout);
 FreeAndNil(fReductionVulkanDescriptorPool);
 FreeAndNil(fFirstPassVulkanDescriptorSetLayout);
 FreeAndNil(fFirstPassVulkanDescriptorPool);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var MipMapLevelIndex,MipMapLevelSetIndex:TpvSizeInt;
    CountMipMaps:TpvInt32;
    ImageMemoryBarrier:TVkImageMemoryBarrier;
    PushConstants:TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass.TPushConstants;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 //////////////////////////

 begin

  FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarrier.pNext:=nil;
  ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_GENERAL;
  ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.image:=fInstance.AmbientOcclusionDepthMipmappedArray2DImage.VulkanImage.Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=fInstance.AmbientOcclusionDepthMipmappedArray2DImage.MipMapLevels;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=fInstance.CountSurfaceViews;

  aCommandBuffer.CmdPipelineBarrier(FrameGraph.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarrier);

 end;

 //////////////////////////

 begin

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fFirstPassPipeline.Handle);

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       fFirstPassPipelineLayout.Handle,
                                       0,
                                       1,
                                       @fFirstPassVulkanDescriptorSets[aInFlightFrameIndex].Handle,
                                       0,
                                       nil);

  PushConstants.CountSamples:=fInstance.Renderer.CountSurfaceMSAASamples;
  PushConstants.BaseViewIndex:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].FinalViewIndex;

  aCommandBuffer.CmdPushConstants(fFirstPassPipelineLayout.Handle,
                                  TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass.TPushConstants),
                                  @PushConstants);

  aCommandBuffer.CmdDispatch(Max(1,(fInstance.AmbientOcclusionDepthMipmappedArray2DImage.Width+((1 shl 4)-1)) shr 4),
                             Max(1,(fInstance.AmbientOcclusionDepthMipmappedArray2DImage.Height+((1 shl 4)-1)) shr 4),
                             fInstance.CountSurfaceViews);

  FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarrier.pNext:=nil;
  ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
  ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.image:=fInstance.AmbientOcclusionDepthMipmappedArray2DImage.VulkanImage.Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=1;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=fInstance.CountSurfaceViews;
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarrier);

 end;

 //////////////////////////

 begin

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fReductionPipeline.Handle);

  for MipMapLevelSetIndex:=0 to fCountMipMapLevelSets-1 do begin

   MipMapLevelIndex:=(MipMapLevelSetIndex shl 2) or 1;

   CountMipMaps:=Min(4,fInstance.AmbientOcclusionDepthMipmappedArray2DImage.MipMapLevels-MipMapLevelIndex);

   if CountMipMaps<=0 then begin
    break;
   end;

   aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                        fReductionPipelineLayout.Handle,
                                        0,
                                        1,
                                        @fReductionVulkanDescriptorSets[aInFlightFrameIndex,MipMapLevelSetIndex].Handle,
                                        0,
                                        nil);

   aCommandBuffer.CmdPushConstants(fReductionPipelineLayout.Handle,
                                   TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                   0,
                                   SizeOf(TpvInt32),
                                   @CountMipMaps);

   aCommandBuffer.CmdDispatch(Max(1,(fInstance.AmbientOcclusionDepthMipmappedArray2DImage.Width+((1 shl (3+MipMapLevelIndex))-1)) shr (3+MipMapLevelIndex)),
                              Max(1,(fInstance.AmbientOcclusionDepthMipmappedArray2DImage.Height+((1 shl (3+MipMapLevelIndex))-1)) shr (3+MipMapLevelIndex)),
                              fInstance.CountSurfaceViews);

   FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
   ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
   ImageMemoryBarrier.pNext:=nil;
   ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
   ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
   ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
   ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
   ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
   ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
   ImageMemoryBarrier.image:=fInstance.AmbientOcclusionDepthMipmappedArray2DImage.VulkanImage.Handle;
   ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
   ImageMemoryBarrier.subresourceRange.baseMipLevel:=MipMapLevelIndex;
   ImageMemoryBarrier.subresourceRange.levelCount:=CountMipMaps;
   ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
   ImageMemoryBarrier.subresourceRange.layerCount:=fInstance.CountSurfaceViews;
   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     0,
                                     0,nil,
                                     0,nil,
                                     1,@ImageMemoryBarrier);

  end;

 end;

 //////////////////////////

 begin

  FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarrier.pNext:=nil;
  ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.image:=fInstance.AmbientOcclusionDepthMipmappedArray2DImage.VulkanImage.Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=fInstance.AmbientOcclusionDepthMipmappedArray2DImage.MipMapLevels;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=fInstance.CountSurfaceViews;
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    FrameGraph.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarrier);

 end;

end;

end.
