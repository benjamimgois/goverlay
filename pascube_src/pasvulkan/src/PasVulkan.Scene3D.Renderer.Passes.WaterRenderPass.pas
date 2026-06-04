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
unit PasVulkan.Scene3D.Renderer.Passes.WaterRenderPass;
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
     PasVulkan.Scene3D.Renderer.IBLDescriptor,
     PasVulkan.Scene3D.Planet;

type { TpvScene3DRendererPassesWaterRenderPass }
     TpvScene3DRendererPassesWaterRenderPass=class(TpvFrameGraph.TRenderPass)
      private
       fOnSetRenderPassResourcesDone:boolean;
       procedure OnSetRenderPassResources(const aCommandBuffer:TpvVulkanCommandBuffer;
                                          const aPipelineLayout:TpvVulkanPipelineLayout;
                                          const aRendererInstance:TObject;
                                          const aRenderPass:TpvScene3DRendererRenderPass;
                                          const aPreviousInFlightFrameIndex:TpvSizeInt;
                                          const aInFlightFrameIndex:TpvSizeInt);
      private
       fVulkanRenderPass:TpvVulkanRenderPass;
       fInstance:TpvScene3DRendererInstance;
       fResourceCascadedShadowMap:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceSSAO:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceDepth:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceColor:TpvFrameGraph.TPass.TUsedImageResource;
       fPassVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fPassVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fPassVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fIBLDescriptors:array[0..MaxInFlightFrames-1] of TpvScene3DRendererIBLDescriptor;
       fVulkanPipelineLayout:TpvVulkanPipelineLayout;
       fPlanetWaterRenderPass:TpvScene3DPlanet.TWaterRenderPass;
       fMSAA:Boolean;
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

{ TpvScene3DRendererPassesWaterRenderPass }

constructor TpvScene3DRendererPassesWaterRenderPass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='WaterRenderPass';

{if (fInstance.Renderer.SurfaceSampleCountFlagBits<>TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT)) and not fInstance.Renderer.SupersampleWaterWhenMSAA then begin
  MultiviewMask:=0;
 end else begin
  MultiviewMask:=fInstance.SurfaceMultiviewMask;
 end;}

 if fInstance.CountSurfaceViews=1 then begin
  MultiviewMask:=0;
 end else begin
  MultiviewMask:=fInstance.SurfaceMultiviewMask;
 end;

 SeparateCommandBuffer:=true;

 Queue:=aFrameGraph.UniversalQueue;

 Size:=TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,
                                       fInstance.SizeFactor,
                                       fInstance.SizeFactor,
                                       1.0,
                                       fInstance.CountSurfaceViews);

 fResourceCascadedShadowMap:=AddImageInput('resourcetype_cascadedshadowmap_data',
                                           'resource_cascadedshadowmap_data_final',
                                           VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                           []
                                          );

 if fInstance.Renderer.ScreenSpaceAmbientOcclusion then begin
  fResourceSSAO:=AddImageInput('resourcetype_ambientocclusion_final',
                               'resource_ambientocclusion_data_final',
                               VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                               []
                              );
 end else begin
  fResourceSSAO:=nil;
 end;

 if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin

  fMSAA:=false;

  fResourceDepth:=AddImageDepthInput('resourcetype_depth',
                                     'resource_depth_data',
                                   {  VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL,//VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                     [TpvFrameGraph.TResourceTransition.TFlag.Attachment]}
                                     VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
                                     [TpvFrameGraph.TResourceTransition.TFlag.Attachment,
                                      TpvFrameGraph.TResourceTransition.TFlag.ExplicitOutputAttachment]
                                    );


  fResourceColor:=AddImageOutput('resourcetype_color',
                                 'resource_water_color',
                                 VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                 TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                              TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0)),
                                 [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                );

 end else begin

  fMSAA:=fInstance.Renderer.SupersampleWaterWhenMSAA;

  if fMSAA then begin

   fResourceDepth:=AddImageDepthInput('resourcetype_msaa_depth',
                                      'resource_msaa_depth_data',
                                   {  VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL,//VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                      [TpvFrameGraph.TResourceTransition.TFlag.Attachment]}
                                      VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
                                      [TpvFrameGraph.TResourceTransition.TFlag.Attachment,
                                       TpvFrameGraph.TResourceTransition.TFlag.ExplicitOutputAttachment]
                                     );

   fResourceColor:=AddImageOutput('resourcetype_msaa_color',
                                  'resource_water_msaa_color',
                                  VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                  TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                               TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0)),
                                  [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                 );

   fResourceColor:=AddImageResolveOutput('resourcetype_color',
                                         'resource_water_color',
                                         'resource_water_msaa_color',
                                         VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                         TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.DontCare,
                                                                      TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0)),
                                         [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                        );

  end else begin

   fResourceDepth:=nil;

   fResourceColor:=AddImageOutput('resourcetype_color',
                                  'resource_water_color',
                                  VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                  TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                               TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0)),
                                  [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                 );

  end;

 end;

end;

destructor TpvScene3DRendererPassesWaterRenderPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesWaterRenderPass.AcquirePersistentResources;
begin

 inherited AcquirePersistentResources;

 fPlanetWaterRenderPass:=TpvScene3DPlanet.TWaterRenderPass.Create(fInstance.Renderer,
                                                                  fInstance,
                                                                  fInstance.Renderer.Scene3D,
                                                                  fMSAA,
                                                                  0,
                                                                  fResourceCascadedShadowMap,
                                                                  fResourceSSAO);

end;

procedure TpvScene3DRendererPassesWaterRenderPass.ReleasePersistentResources;
begin

 FreeAndNil(fPlanetWaterRenderPass);

 inherited ReleasePersistentResources;

end;

procedure TpvScene3DRendererPassesWaterRenderPass.AcquireVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
    AlphaMode:TpvScene3D.TMaterial.TAlphaMode;
    PrimitiveTopology:TpvScene3D.TPrimitiveTopology;
    FaceCullingMode:TpvScene3D.TFaceCullingMode;
begin

 inherited AcquireVolatileResources;

 fVulkanRenderPass:=VulkanRenderPass;

 fPassVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fPassVulkanDescriptorSetLayout.AddBinding(0,
                                             VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(1,
                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                             3,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(2,
                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                             6,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(3,
                                             VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(4,
                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(5,
                                           VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                           3,
                                           TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or
                                           TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT) or
                                           TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT) or
                                           TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                           []);
 fPassVulkanDescriptorSetLayout.AddBinding(6,
                                             VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(7,
                                             VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(8,
                                             VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
{if assigned(fResourceDepth) then begin
  fPassVulkanDescriptorSetLayout.AddBinding(9,
                                            VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT,
                                            1,
                                            TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                            []);
 end;}
 fPassVulkanDescriptorSetLayout.Initialize;

 fPassVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,13*fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT,fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,3*fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,2*fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.Initialize;

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  fPassVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fPassVulkanDescriptorPool,
                                                                                 fPassVulkanDescriptorSetLayout);
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                       0,
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                       [],
                                                                       [fInstance.VulkanViewUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                       [],
                                                                       false);
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                       0,
                                                                       3,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                       [fInstance.Renderer.GGXBRDF.DescriptorImageInfo,
                                                                        fInstance.Renderer.CharlieBRDF.DescriptorImageInfo,
                                                                        fInstance.Renderer.SheenEBRDF.DescriptorImageInfo],
                                                                       [],
                                                                       [],
                                                                       false);
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                       0,
                                                                       6,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                       [fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.GGXDescriptorImageInfo,
                                                                        fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.CharlieDescriptorImageInfo,
                                                                        fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.LambertianDescriptorImageInfo,
                                                                        fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.GGXDescriptorImageInfo,
                                                                        fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.CharlieDescriptorImageInfo,
                                                                        fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.LambertianDescriptorImageInfo],
                                                                       [],
                                                                       [],
                                                                       false);
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                       0,
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                       [],
                                                                       [fInstance.CascadedShadowMapVulkanUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                       [],
                                                                       false);
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,
                                                                       0,
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                       [TVkDescriptorImageInfo.Create(fInstance.Renderer.ShadowMapSampler.Handle,
                                                                                                      fResourceCascadedShadowMap.VulkanImageViews[InFlightFrameIndex].Handle,
                                                                                                      fResourceCascadedShadowMap.ResourceTransition.Layout)],// TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))],
                                                                       [],
                                                                       [],
                                                                       false);
  if fInstance.Renderer.ScreenSpaceAmbientOcclusion then begin
   fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,
                                                                        0,
                                                                        3,
                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                        [TVkDescriptorImageInfo.Create(fInstance.Renderer.AmbientOcclusionSampler.Handle,
                                                                                                       fResourceSSAO.VulkanImageViews[InFlightFrameIndex].Handle,
                                                                                                       fResourceSSAO.ResourceTransition.Layout),// TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))],
                                                                         TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                                                       fInstance.SceneMipmappedArray2DImage.VulkanArrayImageView.Handle,
                                                                                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                                         TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                                       fInstance.DepthMipmappedArray2DImage.VulkanArrayImageView.Handle,
                                                                                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                        [],
                                                                        [],
                                                                        false);
  end else begin
   fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,
                                                                        0,
                                                                        3,
                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                        [TVkDescriptorImageInfo.Create(fInstance.Renderer.AmbientOcclusionSampler.Handle,
                                                                                                       fInstance.Renderer.EmptyAmbientOcclusionTexture.ImageView.Handle,
                                                                                                       TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)),
                                                                         TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                                                       fInstance.SceneMipmappedArray2DImage.VulkanArrayImageView.Handle,
                                                                                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                                         TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                                       fInstance.DepthMipmappedArray2DImage.VulkanArrayImageView.Handle,
                                                                                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                        [],
                                                                        [],
                                                                        false);
  end;
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(6,
                                                                       0,
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                       [],
                                                                       [fInstance.FrustumClusterGridGlobalsVulkanBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                       [],
                                                                       false);
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(7,
                                                                       0,
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                       [],
                                                                       [fInstance.FrustumClusterGridIndexListVulkanBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                       [],
                                                                       false);
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(8,
                                                                       0,
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                       [],
                                                                       [fInstance.FrustumClusterGridDataVulkanBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                       [],
                                                                       false);
{ if assigned(fResourceDepth) then begin
   fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(9,
                                                                      0,
                                                                      1,
                                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT),
                                                                      [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                     fResourceDepth.VulkanImageViews[InFlightFrameIndex].Handle,
                                                                                                     fResourceDepth.ResourceTransition.Layout)],// TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))],
                                                                      [],
                                                                      [],
                                                                      false);
  end;}
  fPassVulkanDescriptorSets[InFlightFrameIndex].Flush;
  fIBLDescriptors[InFlightFrameIndex]:=TpvScene3DRendererIBLDescriptor.Create(fInstance.Renderer.VulkanDevice,
                                                                              fPassVulkanDescriptorSets[InFlightFrameIndex],
                                                                              2,
                                                                              fInstance.Renderer.ClampedSampler.Handle);
 end;

 fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),0,SizeOf(TpvScene3D.TMeshStagePushConstants));
 fVulkanPipelineLayout.AddDescriptorSetLayout(fInstance.Renderer.Scene3D.GlobalVulkanDescriptorSetLayout);
 fVulkanPipelineLayout.AddDescriptorSetLayout(fPassVulkanDescriptorSetLayout);
 case fInstance.Renderer.GlobalIlluminationMode of
  TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints:begin
   fVulkanPipelineLayout.AddDescriptorSetLayout(fInstance.GlobalIlluminationRadianceHintsDescriptorSetLayout);
  end;
  TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing:begin
   fVulkanPipelineLayout.AddDescriptorSetLayout(fInstance.GlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout);
  end;
  else begin
  end;
 end;
 fVulkanPipelineLayout.Initialize;

 fPlanetWaterRenderPass.AllocateResources(fVulkanRenderPass,
                                          fPassVulkanDescriptorSetLayout,
                                          fResourceColor.Width,
                                          fResourceColor.Height,
                                          fInstance.Renderer.SurfaceSampleCountFlagBits);

end;

procedure TpvScene3DRendererPassesWaterRenderPass.ReleaseVolatileResources;
var Index:TpvSizeInt;
    AlphaMode:TpvScene3D.TMaterial.TAlphaMode;
    PrimitiveTopology:TpvScene3D.TPrimitiveTopology;
    FaceCullingMode:TpvScene3D.TFaceCullingMode;
begin
 fPlanetWaterRenderPass.ReleaseResources;
 FreeAndNil(fVulkanPipelineLayout);
 for Index:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fPassVulkanDescriptorSets[Index]);
  FreeAndNil(fIBLDescriptors[Index]);
 end;
 FreeAndNil(fPassVulkanDescriptorPool);
 FreeAndNil(fPassVulkanDescriptorSetLayout);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesWaterRenderPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesWaterRenderPass.OnSetRenderPassResources(const aCommandBuffer:TpvVulkanCommandBuffer;
                                                                                        const aPipelineLayout:TpvVulkanPipelineLayout;
                                                                                        const aRendererInstance:TObject;
                                                                                        const aRenderPass:TpvScene3DRendererRenderPass;
                                                                                        const aPreviousInFlightFrameIndex:TpvSizeInt;
                                                                                        const aInFlightFrameIndex:TpvSizeInt);
var DescriptorSets:array[0..1] of TVkDescriptorSet;
begin
 if not fOnSetRenderPassResourcesDone then begin
  fOnSetRenderPassResourcesDone:=true;
  case fInstance.Renderer.GlobalIlluminationMode of
   TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints:begin
    DescriptorSets[0]:=fPassVulkanDescriptorSets[aInFlightFrameIndex].Handle;
    DescriptorSets[1]:=fInstance.GlobalIlluminationRadianceHintsDescriptorSets[aInFlightFrameIndex].Handle;
    aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                         fVulkanPipelineLayout.Handle,
                                         1,
                                         2,
                                         @DescriptorSets,
                                         0,
                                         nil);
   end;
   TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing:begin
    DescriptorSets[0]:=fPassVulkanDescriptorSets[aInFlightFrameIndex].Handle;
    DescriptorSets[1]:=fInstance.GlobalIlluminationCascadedVoxelConeTracingDescriptorSets[aInFlightFrameIndex].Handle;
    aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                         fVulkanPipelineLayout.Handle,
                                         1,
                                         2,
                                         @DescriptorSets[0],
                                         0,
                                         nil);
   end;
   else begin
    aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                         fVulkanPipelineLayout.Handle,
                                         1,
                                         1,
                                         @fPassVulkanDescriptorSets[aInFlightFrameIndex].Handle,
                                         0,
                                         nil);
   end;
  end;
 end;
end;

procedure TpvScene3DRendererPassesWaterRenderPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;
                                                            const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameState:TpvScene3DRendererInstance.PInFlightFrameState;
begin
 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 InFlightFrameState:=@fInstance.InFlightFrameStates^[aInFlightFrameIndex];

 if InFlightFrameState^.Ready then begin

  fIBLDescriptors[aInFlightFrameIndex].SetFrom(fInstance.Renderer.Scene3D,fInstance,aInFlightFrameIndex);
  fIBLDescriptors[aInFlightFrameIndex].Update(true);

  fPlanetWaterRenderPass.Draw(aInFlightFrameIndex,
                              aFrameIndex,
                              TpvScene3DRendererRenderPass.View,
                              InFlightFrameState^.FinalViewIndex,
                              InFlightFrameState^.CountFinalViews,
                              aCommandBuffer,
                              fPassVulkanDescriptorSets[aInFlightFrameIndex]);


 end;

end;

end.
