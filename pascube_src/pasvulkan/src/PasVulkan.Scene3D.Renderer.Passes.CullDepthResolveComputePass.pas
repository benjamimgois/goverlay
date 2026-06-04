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
unit PasVulkan.Scene3D.Renderer.Passes.CullDepthResolveComputePass;
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
     PasVulkan.Scene3D.Renderer.Array2DImage;

type { TpvScene3DRendererPassesCullDepthResolveComputePass }
     TpvScene3DRendererPassesCullDepthResolveComputePass=class(TpvFrameGraph.TComputePass)
      public
       type TPushConstants=packed record
             CountSamples:TpvUInt32;
            end;
      private
       fInstance:TpvScene3DRendererInstance;
       fCullRenderPass:TpvScene3DRendererCullRenderPass;
       fFarthest:boolean;
       fResourceInput:TpvFrameGraph.TPass.TUsedImageResource;
       fComputeShaderModule:TpvVulkanShaderModule;
       fVulkanImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
       fVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fPipelineLayout:TpvVulkanPipelineLayout;
       fPipeline:TpvVulkanComputePipeline;
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

{ TpvScene3DRendererPassesCullDepthResolveComputePass  }

constructor TpvScene3DRendererPassesCullDepthResolveComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance;const aCullRenderPass:TpvScene3DRendererCullRenderPass);
begin
 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 fCullRenderPass:=aCullRenderPass;

 case fCullRenderPass of
  TpvScene3DRendererCullRenderPass.FinalView:begin
   Name:='FinalViewCullDepthResolveComputePass';
  end;
  TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
   Name:='CascadedShadowMapCullDepthResolveComputePass';
  end;
  else begin
   Name:='CullDepthResolveComputePass';
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

    fResourceInput:=AddImageInput('resourcetype_msaa_depth',
                                  'resource_msaa_depth_data',
                                  VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                  [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                 );

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
      fResourceInput:=AddImageInput('resourcetype_cascadedshadowmap_msaa_depth',
                                    'resource_cascadedshadowmap_msaa_depth',
                                    VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                    [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                   );
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
   Assert(false);
  end;

 end;

end;

destructor TpvScene3DRendererPassesCullDepthResolveComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesCullDepthResolveComputePass.AcquirePersistentResources;
var Stream:TStream;
begin

 inherited AcquirePersistentResources;

 case fCullRenderPass of

  TpvScene3DRendererCullRenderPass.FinalView:begin

   if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
    if fInstance.ZFar<0.0 then begin
     if fInstance.CountSurfaceViews>1 then begin
      Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cull_depth_resolve_multiview_reversedz_comp.spv');
     end else begin
      Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cull_depth_resolve_reversedz_comp.spv');
     end;
    end else begin
     if fInstance.CountSurfaceViews>1 then begin
      Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cull_depth_resolve_multiview_comp.spv');
     end else begin
      Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cull_depth_resolve_resolve_comp.spv');
     end;
    end;
   end else begin
    if fInstance.ZFar<0.0 then begin
     if fInstance.CountSurfaceViews>1 then begin
      Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cull_depth_resolve_multiview_msaa_reversedz_comp.spv');
     end else begin
      Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cull_depth_resolve_msaa_reversedz_comp.spv');
     end;
    end else begin
     if fInstance.CountSurfaceViews>1 then begin
      Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cull_depth_resolve_multiview_msaa_comp.spv');
     end else begin
      Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cull_depth_resolve_msaa_comp.spv');
     end;
    end;
   end;

  end;

  TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin

   if (fInstance.Renderer.ShadowMode=TpvScene3DRendererShadowMode.MSM) and (fInstance.Renderer.ShadowMapSampleCountFlagBits<>TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT)) then begin
    if TpvScene3DRendererInstance.CountCascadedShadowMapCascades>1 then begin
     Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cull_depth_resolve_multiview_msaa_comp.spv');
    end else begin
     Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cull_depth_resolve_msaa_comp.spv');
    end;
   end else begin
    if TpvScene3DRendererInstance.CountCascadedShadowMapCascades>1 then begin
     Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cull_depth_resolve_multiview_comp.spv');
    end else begin
     Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cull_depth_resolve_resolve_comp.spv');
    end;
   end;

  end;

  else begin
   Stream:=nil;
  end;

 end;
 try
  fComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModule,'main');

end;

procedure TpvScene3DRendererPassesCullDepthResolveComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStageCompute);
 FreeAndNil(fComputeShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesCullDepthResolveComputePass.AcquireVolatileResources;
var InFlightFrameIndex,MipMapLevelIndex,CountViews:TpvInt32;
    ImageViewType:TVkImageViewType;
    Array2DImage:TpvScene3DRendererArray2DImage;
begin

 inherited AcquireVolatileResources;

 case fCullRenderPass of
  TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
   Array2DImage:=fInstance.CascadedShadowMapCullDepthArray2DImage;
   CountViews:=TpvScene3DRendererInstance.CountCascadedShadowMapCascades;
  end;
  else begin
   Array2DImage:=fInstance.CullDepthArray2DImage;
   CountViews:=fInstance.CountSurfaceViews;
  end;
 end;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fInstance.Renderer.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fInstance.Renderer.CountInFlightFrames);
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
 fPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TpvScene3DRendererPassesCullDepthResolveComputePass.TPushConstants));
 fPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 fPipelineLayout.Initialize;

 fPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                  fInstance.Renderer.VulkanPipelineCache,
                                                  0,
                                                  fVulkanPipelineShaderStageCompute,
                                                  fPipelineLayout,
                                                  nil,
                                                  0);

 if CountViews>1 then begin
  ImageViewType:=TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D_ARRAY);
 end else begin
  ImageViewType:=TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D);
 end;

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
                                                                   CountViews
                                                                  );
  begin
   fVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                                            fVulkanDescriptorSetLayout);
   fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                  0,
                                                                  1,
                                                                  TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                  [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                                 fVulkanImageViews[InFlightFrameIndex].Handle,
                                                                                                 fResourceInput.ResourceTransition.Layout)],
                                                                  [],
                                                                  [],
                                                                  false
                                                                 );
   fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                  0,
                                                                  1,
                                                                  TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                  [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                                 Array2DImage.VulkanImageView.Handle,
                                                                                                 VK_IMAGE_LAYOUT_GENERAL)],
                                                                  [],
                                                                  [],
                                                                  false
                                                                 );
   fVulkanDescriptorSets[InFlightFrameIndex].Flush;
  end;
 end;

end;

procedure TpvScene3DRendererPassesCullDepthResolveComputePass.ReleaseVolatileResources;
var InFlightFrameIndex,MipMapLevelIndex:TpvInt32;
begin
 FreeAndNil(fPipeline);
 FreeAndNil(fPipelineLayout);
 for InFlightFrameIndex:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fVulkanImageViews[InFlightFrameIndex]);
 end;
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanDescriptorPool);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesCullDepthResolveComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesCullDepthResolveComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameIndex,CountViews:TpvInt32;
    ImageMemoryBarrier:TVkImageMemoryBarrier;
    PushConstants:TpvScene3DRendererPassesCullDepthResolveComputePass.TPushConstants;
    Array2DImage:TpvScene3DRendererArray2DImage;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 InFlightFrameIndex:=aInFlightFrameIndex;

 case fCullRenderPass of
  TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
   Array2DImage:=fInstance.CascadedShadowMapCullDepthArray2DImage;
   CountViews:=TpvScene3DRendererInstance.CountCascadedShadowMapCascades;
  end;
  else begin
   Array2DImage:=fInstance.CullDepthArray2DImage;
   CountViews:=fInstance.CountSurfaceViews;
  end;
 end;

 FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
 ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
 ImageMemoryBarrier.pNext:=nil;
 ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
 ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
 ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
 ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_GENERAL;
 ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 ImageMemoryBarrier.image:=Array2DImage.VulkanImage.Handle;
 ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
 ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
 ImageMemoryBarrier.subresourceRange.levelCount:=1;
 ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
 ImageMemoryBarrier.subresourceRange.layerCount:=CountViews;
 aCommandBuffer.CmdPipelineBarrier(FrameGraph.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   0,
                                   0,nil,
                                   0,nil,
                                   1,@ImageMemoryBarrier);

 begin

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipeline.Handle);

  case fCullRenderPass of
   TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
    PushConstants.CountSamples:=fInstance.Renderer.CountCascadedShadowMapMSAASamples;
   end;
   else begin
    PushConstants.CountSamples:=fInstance.Renderer.CountSurfaceMSAASamples;
   end;
  end;

  aCommandBuffer.CmdPushConstants(fPipelineLayout.Handle,
                                  TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TpvScene3DRendererPassesCullDepthResolveComputePass.TPushConstants),
                                  @PushConstants);

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       fPipelineLayout.Handle,
                                       0,
                                       1,
                                       @fVulkanDescriptorSets[InFlightFrameIndex].Handle,
                                       0,
                                       nil);

  aCommandBuffer.CmdDispatch(Max(1,(fResourceInput.Width+((1 shl 4)-1)) shr 4),
                             Max(1,(fResourceInput.Height+((1 shl 4)-1)) shr 4),
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
  ImageMemoryBarrier.image:=Array2DImage.VulkanImage.Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=1;
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
