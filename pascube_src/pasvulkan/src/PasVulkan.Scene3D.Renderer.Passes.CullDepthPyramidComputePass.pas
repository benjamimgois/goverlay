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
unit PasVulkan.Scene3D.Renderer.Passes.CullDepthPyramidComputePass;
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
     PasVulkan.Scene3D.Renderer.MipmappedArray2DImage;

type { TpvScene3DRendererPassesCullDepthPyramidComputePass }
     TpvScene3DRendererPassesCullDepthPyramidComputePass=class(TpvFrameGraph.TComputePass)
      private
       fInstance:TpvScene3DRendererInstance;
       fCullRenderPass:TpvScene3DRendererCullRenderPass;
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
       constructor Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance;const aCullRenderPass:TpvScene3DRendererCullRenderPass); reintroduce;
       destructor Destroy; override;
       procedure AcquirePersistentResources; override;
       procedure ReleasePersistentResources; override;
       procedure AcquireVolatileResources; override;
       procedure ReleaseVolatileResources; override;
       procedure Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt); override;
       procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt); override;
     end;

implementation

{ TpvScene3DRendererPassesCullDepthPyramidComputePass  }

constructor TpvScene3DRendererPassesCullDepthPyramidComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance;const aCullRenderPass:TpvScene3DRendererCullRenderPass);
begin
 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 fCullRenderPass:=aCullRenderPass;

 case fCullRenderPass of
  TpvScene3DRendererCullRenderPass.FinalView:begin
   Name:='FinalViewCullDepthPyramidComputePass';
  end;
  TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
   Name:='CascadedShadowMapCullDepthPyramidComputePass';
  end;
  else begin
   Name:='CullDepthPyramidComputePass';
  end;
 end;

 case fCullRenderPass of

  TpvScene3DRendererCullRenderPass.FinalView:begin

   if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin

    fResourceInput:=AddImageInput('resourcetype_depth',
                                  'resource_depth_data',
   	                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
	                                [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
	                               );

    end else begin

     fResourceInput:=nil;
  	                 {AddImageInput('resourcetype_msaa_depth',
                                    'resource_msaa_cull_depth_data',
	                                  VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
	                                  [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
	                                 );}

   end;

  end;

  TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin

   case fInstance.Renderer.ShadowMode of
    TpvScene3DRendererShadowMode.MSM:begin
     if fInstance.Renderer.ShadowMapSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
      fResourceInput:=AddImageInput('resourcetype_cascadedshadowmap_depth',
                                    'resource_cascadedshadowmap_single_depth',
                                    VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                    [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                   );
     end else begin
      fResourceInput:=nil;
     end;
    end
    else begin
     fResourceInput:=AddImageInput('resourcetype_cascadedshadowmap_data',
                                   'resource_cascadedshadowmap_data_final',
                                   VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                   [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                  );
    end;
   end;

  end;

  else begin
  end;
 end;

end;

destructor TpvScene3DRendererPassesCullDepthPyramidComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesCullDepthPyramidComputePass.AcquirePersistentResources;
var Stream:TStream;
begin

 inherited AcquirePersistentResources;

 case fCullRenderPass of
  TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
   if TpvScene3DRendererInstance.CountCascadedShadowMapCascades>1 then begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_culldepthpyramid_multiview_firstpass_comp.spv');
   end else begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_culldepthpyramid_firstpass_comp.spv');
   end;
  end;
  else begin
   if fInstance.ZFar<0.0 then begin
    if fInstance.CountSurfaceViews>1 then begin
     Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_culldepthpyramid_multiview_reversedz_firstpass_comp.spv');
    end else begin
     Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_culldepthpyramid_reversedz_firstpass_comp.spv');
    end;
   end else begin
    if fInstance.CountSurfaceViews>1 then begin
     Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_culldepthpyramid_multiview_firstpass_comp.spv');
    end else begin
     Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_culldepthpyramid_firstpass_comp.spv');
    end;
   end;
  end;
 end;
 try
  fFirstPassComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fFirstPassComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,Name+'.fFirstPassComputeShaderModule');

 case fCullRenderPass of
  TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
   if TpvScene3DRendererInstance.CountCascadedShadowMapCascades>1 then begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_culldepthpyramid_multiview_reduction_comp.spv');
   end else begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_culldepthpyramid_reduction_comp.spv');
   end;
  end;
  else begin
   if fInstance.ZFar<0.0 then begin
    if fInstance.CountSurfaceViews>1 then begin
     Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_culldepthpyramid_multiview_reversedz_reduction_comp.spv');
    end else begin
     Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_culldepthpyramid_reversedz_reduction_comp.spv');
    end;
   end else begin
    if fInstance.CountSurfaceViews>1 then begin
     Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_culldepthpyramid_multiview_reduction_comp.spv');
    end else begin
     Stream:=pvScene3DShaderVirtualFileSystem.GetFile('downsample_culldepthpyramid_reduction_comp.spv');
    end;
   end;
  end;
 end;
 try
  fReductionComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fReductionComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,Name+'.fReductionComputeShaderModule');

 fFirstPassVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fFirstPassComputeShaderModule,'main');

 fReductionVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fReductionComputeShaderModule,'main');

end;

procedure TpvScene3DRendererPassesCullDepthPyramidComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fReductionVulkanPipelineShaderStageCompute);
 FreeAndNil(fFirstPassVulkanPipelineShaderStageCompute);
 FreeAndNil(fReductionComputeShaderModule);
 FreeAndNil(fFirstPassComputeShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesCullDepthPyramidComputePass.AcquireVolatileResources;
var InFlightFrameIndex,MipMapLevelSetIndex,CountViews:TpvInt32;
    ImageViewType:TVkImageViewType;
    Sampler:TpvVulkanSampler;
    MipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage;
begin

 inherited AcquireVolatileResources;

 case fCullRenderPass of

  TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin

   if TpvScene3DRendererInstance.CountCascadedShadowMapCascades>1 then begin
    ImageViewType:=TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D_ARRAY);
   end else begin
    ImageViewType:=TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D);
   end;

   Sampler:=fInstance.Renderer.MipMapMaxFilterSampler;

  end;

  else begin

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

  end;

 end;

 case fCullRenderPass of
  TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
   MipmappedArray2DImage:=fInstance.CascadedShadowMapCullDepthPyramidMipmappedArray2DImage;
   CountViews:=TpvScene3DRendererInstance.CountCascadedShadowMapCascades;
  end;
  else begin
   MipmappedArray2DImage:=fInstance.CullDepthPyramidMipmappedArray2DImage;
   CountViews:=fInstance.CountSurfaceViews;
  end;
 end;

 fFirstPassVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                                TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                fInstance.Renderer.CountInFlightFrames);
 fFirstPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fInstance.Renderer.CountInFlightFrames*1);
 fFirstPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fInstance.Renderer.CountInFlightFrames*1);
 fFirstPassVulkanDescriptorPool.Initialize;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fFirstPassVulkanDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,Name+'.fFirstPassVulkanDescriptorPool');

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
 fFirstPassVulkanDescriptorSetLayout.Initialize;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fFirstPassVulkanDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,Name+'.fFirstPassVulkanDescriptorSetLayout');

 fFirstPassPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fFirstPassPipelineLayout.AddDescriptorSetLayout(fFirstPassVulkanDescriptorSetLayout);
 fFirstPassPipelineLayout.Initialize;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fFirstPassPipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,Name+'.fFirstPassPipelineLayout');

 fFirstPassPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                     fInstance.Renderer.VulkanPipelineCache,
                                                     0,
                                                     fFirstPassVulkanPipelineShaderStageCompute,
                                                     fFirstPassPipelineLayout,
                                                     nil,
                                                     0);
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fFirstPassPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,Name+'.fFirstPassPipeline');

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  case fCullRenderPass of
   TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
    if assigned(fResourceInput) then begin
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
                                                                      CountViews
                                                                     );
    end else begin
     fVulkanImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(fInstance.Renderer.VulkanDevice,
                                                                      fInstance.CascadedShadowMapCullDepthArray2DImage.VulkanImage,
                                                                      ImageViewType,
                                                                      fInstance.CascadedShadowMapCullDepthArray2DImage.Format,
                                                                      VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                      VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                      VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                      VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                      TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                      0,
                                                                      1,
                                                                      0,
                                                                      CountViews
                                                                     );
    end;
   end;
   else begin
    if assigned(fResourceInput) then begin
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
                                                                      CountViews
                                                                     );
    end else begin
     fVulkanImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(fInstance.Renderer.VulkanDevice,
                                                                      fInstance.CullDepthArray2DImage.VulkanImage,
                                                                      ImageViewType,
                                                                      fInstance.CullDepthArray2DImage.Format,
                                                                      VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                      VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                      VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                      VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                      TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                      0,
                                                                      1,
                                                                      0,
                                                                      CountViews
                                                                     );
    end;
   end;
  end;
  fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fVulkanImageViews[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_IMAGE_VIEW,Name+'.fVulkanImageViews['+IntToStr(InFlightFrameIndex)+']');

  fFirstPassVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fFirstPassVulkanDescriptorPool,
                                                                                    fFirstPassVulkanDescriptorSetLayout);
  if assigned(fResourceInput) then begin
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
  end else begin
   fFirstPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                           0,
                                                                           1,
                                                                           TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                           [TVkDescriptorImageInfo.Create(Sampler.Handle,
                                                                                                          fVulkanImageViews[InFlightFrameIndex].Handle,
                                                                                                          VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                           [],
                                                                           [],
                                                                           false
                                                                          );
  end;
  fFirstPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                          [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                                         MipmappedArray2DImage.VulkanImageViews[0].Handle,
                                                                                                         VK_IMAGE_LAYOUT_GENERAL)],
                                                                          [],
                                                                          [],
                                                                          false
                                                                         );
  fFirstPassVulkanDescriptorSets[InFlightFrameIndex].Flush;
  fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fFirstPassVulkanDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,Name+'.fFirstPassVulkanDescriptorSets['+IntToStr(InFlightFrameIndex)+']');
 end;

 /////

 fCountMipMapLevelSets:=Min(((MipmappedArray2DImage.MipMapLevels-1)+3) shr 2,8);

 fReductionVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames*fCountMipMapLevelSets*4);
 fReductionVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fInstance.Renderer.CountInFlightFrames*fCountMipMapLevelSets);
 fReductionVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fInstance.Renderer.CountInFlightFrames*fCountMipMapLevelSets*(4*4));
 fReductionVulkanDescriptorPool.Initialize;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fReductionVulkanDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,Name+'.fReductionVulkanDescriptorPool');

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
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fReductionVulkanDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,Name+'.fReductionVulkanDescriptorSetLayout');

 fReductionPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fReductionPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TpvInt32));
 fReductionPipelineLayout.AddDescriptorSetLayout(fReductionVulkanDescriptorSetLayout);
 fReductionPipelineLayout.Initialize;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fReductionPipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,Name+'.fReductionPipelineLayout');

 fReductionPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                     fInstance.Renderer.VulkanPipelineCache,
                                                     0,
                                                     fReductionVulkanPipelineShaderStageCompute,
                                                     fReductionPipelineLayout,
                                                     nil,
                                                     0);
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fReductionPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'CullDepthPyramidComputePass.fReductionPipeline');

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  for MipMapLevelSetIndex:=0 to fCountMipMapLevelSets-1 do begin
   fReductionVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelSetIndex]:=TpvVulkanDescriptorSet.Create(fReductionVulkanDescriptorPool,
                                                                                                         fReductionVulkanDescriptorSetLayout);

   fReductionVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelSetIndex].WriteToDescriptorSet(0,
                                                                                               0,
                                                                                               1,
                                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                               [TVkDescriptorImageInfo.Create(Sampler.Handle,
                                                                                                                              MipmappedArray2DImage.VulkanImageViews[Min(MipMapLevelSetIndex shl 2,MipmappedArray2DImage.MipMapLevels-1)].Handle,
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
                                                                                                                              MipmappedArray2DImage.VulkanImageViews[Min(((MipMapLevelSetIndex shl 2)+1),MipmappedArray2DImage.MipMapLevels-1)].Handle,
                                                                                                                              VK_IMAGE_LAYOUT_GENERAL),
                                                                                                TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                                                              MipmappedArray2DImage.VulkanImageViews[Min(((MipMapLevelSetIndex shl 2)+2),MipmappedArray2DImage.MipMapLevels-1)].Handle,
                                                                                                                              VK_IMAGE_LAYOUT_GENERAL),
                                                                                                TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                                                              MipmappedArray2DImage.VulkanImageViews[Min(((MipMapLevelSetIndex shl 2)+3),MipmappedArray2DImage.MipMapLevels-1)].Handle,
                                                                                                                              VK_IMAGE_LAYOUT_GENERAL),
                                                                                                TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                                                              MipmappedArray2DImage.VulkanImageViews[Min(((MipMapLevelSetIndex shl 2)+4),MipmappedArray2DImage.MipMapLevels-1)].Handle,
                                                                                                                              VK_IMAGE_LAYOUT_GENERAL)],
                                                                                               [],
                                                                                               [],
                                                                                               false
                                                                                              );
   fReductionVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelSetIndex].Flush;
   fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fReductionVulkanDescriptorSets[InFlightFrameIndex,MipMapLevelSetIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,Name+'.fReductionVulkanDescriptorSets['+IntToStr(InFlightFrameIndex)+','+IntToStr(MipMapLevelSetIndex)+']');
  end;
 end;

end;

procedure TpvScene3DRendererPassesCullDepthPyramidComputePass.ReleaseVolatileResources;
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

procedure TpvScene3DRendererPassesCullDepthPyramidComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesCullDepthPyramidComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var MipMapLevelIndex,MipMapLevelSetIndex,CountViews:TpvSizeInt;
    CountMipMaps:TpvInt32;
    ImageMemoryBarrier:TVkImageMemoryBarrier;
    MipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 //////////////////////////

 case fCullRenderPass of
  TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
   MipmappedArray2DImage:=fInstance.CascadedShadowMapCullDepthPyramidMipmappedArray2DImage;
   CountViews:=TpvScene3DRendererInstance.CountCascadedShadowMapCascades;
  end;
  else begin
   MipmappedArray2DImage:=fInstance.CullDepthPyramidMipmappedArray2DImage;
   CountViews:=fInstance.CountSurfaceViews;
  end;
 end;

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
  ImageMemoryBarrier.image:=MipmappedArray2DImage.VulkanImage.Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=MipmappedArray2DImage.MipMapLevels;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=CountViews;
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

  aCommandBuffer.CmdDispatch(Max(1,(MipmappedArray2DImage.Width+((1 shl 4)-1)) shr 4),
                             Max(1,(MipmappedArray2DImage.Height+((1 shl 4)-1)) shr 4),
                             CountViews);

  FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarrier.pNext:=nil;
  ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
  ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.image:=MipmappedArray2DImage.VulkanImage.Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=1;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=CountViews;
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

   CountMipMaps:=Min(4,MipmappedArray2DImage.MipMapLevels-MipMapLevelIndex);

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

   aCommandBuffer.CmdDispatch(Max(1,(MipmappedArray2DImage.Width+((1 shl (3+MipMapLevelIndex))-1)) shr (3+MipMapLevelIndex)),
                              Max(1,(MipmappedArray2DImage.Height+((1 shl (3+MipMapLevelIndex))-1)) shr (3+MipMapLevelIndex)),
                              CountViews);

   FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
   ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
   ImageMemoryBarrier.pNext:=nil;
   ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
   ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
   ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
   ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
   ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
   ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
   ImageMemoryBarrier.image:=MipmappedArray2DImage.VulkanImage.Handle;
   ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
   ImageMemoryBarrier.subresourceRange.baseMipLevel:=MipMapLevelIndex;
   ImageMemoryBarrier.subresourceRange.levelCount:=CountMipMaps;
   ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
   ImageMemoryBarrier.subresourceRange.layerCount:=CountViews;
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
  ImageMemoryBarrier.image:=MipmappedArray2DImage.VulkanImage.Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=MipmappedArray2DImage.MipMapLevels;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=CountViews;
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    FrameGraph.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarrier);

 end;

end;

end.
