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
unit PasVulkan.Scene3D.Renderer.Passes.ReflectionProbeRenderPass;
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
     PasVulkan.Scene3D.Renderer.SkyBox,
     PasVulkan.Scene3D.Renderer.IBLDescriptor;

type { TpvScene3DRendererPassesReflectionProbeRenderPass }
     TpvScene3DRendererPassesReflectionProbeRenderPass=class(TpvFrameGraph.TRenderPass)
      private
       fOnSetRenderPassResourcesDone:boolean;
       procedure OnSetRenderPassResources(const aCommandBuffer:TpvVulkanCommandBuffer;
                                          const aPipelineLayout:TpvVulkanPipelineLayout;
                                          const aRendererInstance:TObject;
                                          const aRenderPass:TpvScene3DRendererRenderPass;
                                          const aPreviousInFlightFrameIndex:TpvSizeInt;
                                          const aInFlightFrameIndex:TpvSizeInt);
      public
       fVulkanRenderPass:TpvVulkanRenderPass;
       fInstance:TpvScene3DRendererInstance;
       fResourceCascadedShadowMap:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceColor:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceDepth:TpvFrameGraph.TPass.TUsedImageResource;
       fMeshVertexShaderModule:TpvVulkanShaderModule;
       fMeshFragmentShaderModule:TpvVulkanShaderModule;
       fMeshMaskedFragmentShaderModule:TpvVulkanShaderModule;
       fMeshDepthFragmentShaderModule:TpvVulkanShaderModule;
       fMeshDepthMaskedFragmentShaderModule:TpvVulkanShaderModule;
       fDebugPrimitiveVertexShaderModule:TpvVulkanShaderModule;
       fDebugPrimitiveFragmentShaderModule:TpvVulkanShaderModule;
       fPassVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fPassVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fPassVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fIBLDescriptors:array[0..MaxInFlightFrames-1] of TpvScene3DRendererIBLDescriptor;
       fVulkanPipelineShaderStageMeshVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshFragment:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshMaskedFragment:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshDepthFragment:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshDepthMaskedFragment:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageDebugPrimitiveVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageDebugPrimitiveFragment:TpvVulkanPipelineShaderStage;
       fVulkanGraphicsPipelines:array[boolean,TpvScene3D.TMaterial.TAlphaMode] of TpvScene3D.TGraphicsPipelines;
       fVulkanDebugPrimitiveGraphicsPipeline:TpvVulkanGraphicsPipeline;
       fVulkanPipelineLayout:TpvVulkanPipelineLayout;
       fSkyBox:TpvScene3DRendererSkyBox;
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

{ TpvScene3DRendererPassesReflectionProbeRenderPass }

constructor TpvScene3DRendererPassesReflectionProbeRenderPass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='ReflectionProbeRenderPass';

 MultiviewMask:=(1 shl 0) or (1 shl 1) or (1 shl 2) or (1 shl 3) or (1 shl 4) or (1 shl 5);

 Queue:=aFrameGraph.UniversalQueue;

 Size:=TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,
                                       fInstance.ReflectionProbeWidth,
                                       fInstance.ReflectionProbeHeight,
                                       1.0,
                                       6);

 fResourceCascadedShadowMap:=AddImageInput('resourcetype_cascadedshadowmap_data',
                                           'resource_cascadedshadowmap_data_final',
                                           VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                           []
                                          );

 fResourceColor:=AddImageOutput('resourcetype_reflectionprobe_color',
                                'resource_reflectionprobe_color', //_optimized_non_alpha
                                VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                             TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0)),
                                [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                               );

 fResourceDepth:=AddImageDepthOutput('resourcetype_reflectionprobe_depth',
                                     'resource_reflectionprobe_depth',
                                     VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
                                     TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                                  TpvVector4.InlineableCreate(IfThen(fInstance.ZFar<0.0,0.0,1.0),0.0,0.0,0.0)),
                                     [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                     );//}


end;

destructor TpvScene3DRendererPassesReflectionProbeRenderPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesReflectionProbeRenderPass.AcquirePersistentResources;
var Index:TpvSizeInt;
    Stream:TStream;
    MeshFragmentSpecializationConstants:TpvScene3DRendererInstance.TMeshFragmentSpecializationConstants;
begin
 inherited AcquirePersistentResources;

 MeshFragmentSpecializationConstants:=fInstance.MeshFragmentSpecializationConstants;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_vert.spv');
 try
  fMeshVertexShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragShadowTypeName+'_frag.spv');
 try
  fMeshFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 if fInstance.Renderer.UseDemote then begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragShadowTypeName+'_alphatest_demote_frag.spv');
 end else if fInstance.Renderer.UseNoDiscard then begin
  if fInstance.ZFar<0.0 then begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_reversedz_shading_'+fInstance.Renderer.MeshFragShadowTypeName+'_alphatest_nodiscard_frag.spv');
  end else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragShadowTypeName+'_alphatest_nodiscard_frag.spv');
  end;
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragShadowTypeName+'_alphatest_frag.spv');
 end;
 try
  fMeshMaskedFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 if fInstance.Renderer.UseDepthPrepass then begin

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_depth_frag.spv');
  try
   fMeshDepthFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;

  if fInstance.Renderer.UseDemote then begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_depth_alphatest_demote_frag.spv');
  end else if fInstance.Renderer.UseNoDiscard then begin
   if fInstance.ZFar<0.0 then begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_reversedz_depth_alphatest_nodiscard_frag.spv');
   end else begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_depth_alphatest_nodiscard_frag.spv');
   end;
  end else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_depth_alphatest_frag.spv');
  end;
  try
   fMeshDepthMaskedFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;

 end;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('debug_primitive_vert.spv');
 try
  fDebugPrimitiveVertexShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('debug_primitive_frag.spv');
 try
  fDebugPrimitiveFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageMeshVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fMeshVertexShaderModule,'main');

 fVulkanPipelineShaderStageMeshFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fMeshFragmentShaderModule,'main');
 MeshFragmentSpecializationConstants.SetPipelineShaderStage(fVulkanPipelineShaderStageMeshFragment);

 fVulkanPipelineShaderStageMeshMaskedFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fMeshMaskedFragmentShaderModule,'main');
 MeshFragmentSpecializationConstants.SetPipelineShaderStage(fVulkanPipelineShaderStageMeshMaskedFragment);

 if fInstance.Renderer.UseDepthPrepass then begin

  fVulkanPipelineShaderStageMeshDepthFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fMeshDepthFragmentShaderModule,'main');
  MeshFragmentSpecializationConstants.SetPipelineShaderStage(fVulkanPipelineShaderStageMeshDepthFragment);

  fVulkanPipelineShaderStageMeshDepthMaskedFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fMeshDepthMaskedFragmentShaderModule,'main');
  MeshFragmentSpecializationConstants.SetPipelineShaderStage(fVulkanPipelineShaderStageMeshDepthMaskedFragment);

 end;

 fVulkanPipelineShaderStageDebugPrimitiveVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fDebugPrimitiveVertexShaderModule,'main');

 fVulkanPipelineShaderStageDebugPrimitiveFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fDebugPrimitiveFragmentShaderModule,'main');

 fSkyBox:=TpvScene3DRendererSkyBox.Create(fInstance.Renderer,
                                          fInstance,
                                          fInstance.Renderer.Scene3D,
                                          fInstance.Renderer.SkyBoxCubeMap.DescriptorImageInfo);

end;

procedure TpvScene3DRendererPassesReflectionProbeRenderPass.ReleasePersistentResources;
begin

 FreeAndNil(fSkyBox);

 FreeAndNil(fVulkanPipelineShaderStageMeshVertex);

 FreeAndNil(fVulkanPipelineShaderStageMeshFragment);

 FreeAndNil(fVulkanPipelineShaderStageMeshMaskedFragment);

 if fInstance.Renderer.UseDepthPrepass then begin

  FreeAndNil(fVulkanPipelineShaderStageMeshDepthFragment);

  FreeAndNil(fVulkanPipelineShaderStageMeshDepthMaskedFragment);

 end;

 FreeAndNil(fVulkanPipelineShaderStageDebugPrimitiveVertex);

 FreeAndNil(fVulkanPipelineShaderStageDebugPrimitiveFragment);

 FreeAndNil(fMeshVertexShaderModule);

 FreeAndNil(fMeshFragmentShaderModule);

 FreeAndNil(fMeshMaskedFragmentShaderModule);

 if fInstance.Renderer.UseDepthPrepass then begin

  FreeAndNil(fMeshDepthFragmentShaderModule);

  FreeAndNil(fMeshDepthMaskedFragmentShaderModule);

 end;

 FreeAndNil(fDebugPrimitiveVertexShaderModule);

 FreeAndNil(fDebugPrimitiveFragmentShaderModule);

 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesReflectionProbeRenderPass.AcquireVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
    DepthPrePass:boolean;
    AlphaMode:TpvScene3D.TMaterial.TAlphaMode;
    PrimitiveTopology:TpvScene3D.TPrimitiveTopology;
    FaceCullingMode:TpvScene3D.TFaceCullingMode;
    VulkanGraphicsPipeline:TpvVulkanGraphicsPipeline;
begin

 inherited AcquireVolatileResources;

 fVulkanRenderPass:=VulkanRenderPass;

 fPassVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fPassVulkanDescriptorSetLayout.AddBinding(0,
                                             VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(1,
                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                             3,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(2,
                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                             6,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(3,
                                             VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(4,
                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(5,
                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                             2,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             [],
                                             TVkDescriptorBindingFlags(VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT_EXT));
 fPassVulkanDescriptorSetLayout.AddBinding(6,
                                             VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(7,
                                             VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(8,
                                             VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.Initialize;

 fPassVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,13*fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,3*fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,3*fInstance.Renderer.CountInFlightFrames);
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
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,
                                                                       0,
                                                                       2,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                       [TVkDescriptorImageInfo.Create(fInstance.Renderer.AmbientOcclusionSampler.Handle,
                                                                                                      fInstance.Renderer.EmptyAmbientOcclusionTexture.ImageView.Handle,
                                                                                                      TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)),
                                                                        // Duplicate as dummy really non-used opaque texture
                                                                        TVkDescriptorImageInfo.Create(fInstance.Renderer.AmbientOcclusionSampler.Handle,
                                                                                                      fInstance.Renderer.EmptyAmbientOcclusionTexture.ImageView.Handle,
                                                                                                      TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))
                                                                       ],
                                                                       [],
                                                                       [],
                                                                       false);
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
 fVulkanPipelineLayout.Initialize;

 for DepthPrePass:=false to fInstance.Renderer.UseDepthPrepass do begin
  for AlphaMode:=Low(TpvScene3D.TMaterial.TAlphaMode) to High(TpvScene3D.TMaterial.TAlphaMode) do begin
   for PrimitiveTopology:=Low(TpvScene3D.TPrimitiveTopology) to High(TpvScene3D.TPrimitiveTopology) do begin
    for FaceCullingMode:=Low(TpvScene3D.TFaceCullingMode) to High(TpvScene3D.TFaceCullingMode) do begin
     FreeAndNil(fVulkanGraphicsPipelines[DepthPrePass,AlphaMode,PrimitiveTopology,FaceCullingMode]);
    end;
   end;
  end;
 end;

 for DepthPrePass:=false to fInstance.Renderer.UseDepthPrepass do begin

  for AlphaMode:=Low(TpvScene3D.TMaterial.TAlphaMode) to High(TpvScene3D.TMaterial.TAlphaMode) do begin

   for PrimitiveTopology:=Low(TpvScene3D.TPrimitiveTopology) to High(TpvScene3D.TPrimitiveTopology) do begin

    for FaceCullingMode:=Low(TpvScene3D.TFaceCullingMode) to High(TpvScene3D.TFaceCullingMode) do begin

     VulkanGraphicsPipeline:=TpvVulkanGraphicsPipeline.Create(fInstance.Renderer.VulkanDevice,
                                                              fInstance.Renderer.VulkanPipelineCache,
                                                              0,
                                                              [],
                                                              fVulkanPipelineLayout,
                                                              fVulkanRenderPass,
                                                              VulkanRenderPassSubpassIndex,
                                                              nil,
                                                              0);

     try

      VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshVertex);
      if DepthPrePass then begin
       if AlphaMode=TpvScene3D.TMaterial.TAlphaMode.Mask then begin
        VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshDepthMaskedFragment);
       end else begin
        VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshDepthFragment);
       end;
      end else begin
       if AlphaMode=TpvScene3D.TMaterial.TAlphaMode.Mask then begin
        VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshMaskedFragment);
       end else begin
        VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshFragment);
       end;
      end;

      VulkanGraphicsPipeline.InputAssemblyState.Topology:=TpvScene3D.VulkanPrimitiveTopologies[PrimitiveTopology];
      VulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

      fInstance.Renderer.Scene3D.InitializeGraphicsPipeline(VulkanGraphicsPipeline);

      VulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,fInstance.ReflectionProbeWidth,fInstance.ReflectionProbeHeight,0.0,1.0);
      VulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,fInstance.ReflectionProbeWidth,fInstance.ReflectionProbeHeight);

      VulkanGraphicsPipeline.RasterizationState.DepthClampEnable:=false;
      VulkanGraphicsPipeline.RasterizationState.RasterizerDiscardEnable:=false;
      VulkanGraphicsPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
      case FaceCullingMode of
       TpvScene3D.TFaceCullingMode.Normal:begin
        VulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_BACK_BIT);
        VulkanGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_COUNTER_CLOCKWISE;
       end;
       TpvScene3D.TFaceCullingMode.Inversed:begin
        VulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_BACK_BIT);
        VulkanGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_CLOCKWISE;
       end;
       else begin
        VulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_NONE);
        VulkanGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_COUNTER_CLOCKWISE;
       end;
      end;
      VulkanGraphicsPipeline.RasterizationState.DepthBiasEnable:=false;
      VulkanGraphicsPipeline.RasterizationState.DepthBiasConstantFactor:=0.0;
      VulkanGraphicsPipeline.RasterizationState.DepthBiasClamp:=0.0;
      VulkanGraphicsPipeline.RasterizationState.DepthBiasSlopeFactor:=0.0;
      VulkanGraphicsPipeline.RasterizationState.LineWidth:=1.0;

      VulkanGraphicsPipeline.MultisampleState.RasterizationSamples:=VK_SAMPLE_COUNT_1_BIT;
      VulkanGraphicsPipeline.MultisampleState.SampleShadingEnable:=false;
      VulkanGraphicsPipeline.MultisampleState.MinSampleShading:=0.0;
      VulkanGraphicsPipeline.MultisampleState.CountSampleMasks:=0;
      VulkanGraphicsPipeline.MultisampleState.AlphaToCoverageEnable:=false;
      VulkanGraphicsPipeline.MultisampleState.AlphaToOneEnable:=false;

      VulkanGraphicsPipeline.ColorBlendState.LogicOpEnable:=false;
      VulkanGraphicsPipeline.ColorBlendState.LogicOp:=VK_LOGIC_OP_COPY;
      VulkanGraphicsPipeline.ColorBlendState.BlendConstants[0]:=0.0;
      VulkanGraphicsPipeline.ColorBlendState.BlendConstants[1]:=0.0;
      VulkanGraphicsPipeline.ColorBlendState.BlendConstants[2]:=0.0;
      VulkanGraphicsPipeline.ColorBlendState.BlendConstants[3]:=0.0;
      if DepthPrePass then begin
       VulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                           VK_BLEND_FACTOR_ZERO,
                                                                           VK_BLEND_FACTOR_ZERO,
                                                                           VK_BLEND_OP_ADD,
                                                                           VK_BLEND_FACTOR_ZERO,
                                                                           VK_BLEND_FACTOR_ZERO,
                                                                           VK_BLEND_OP_ADD,
                                                                           0);
      end else begin
       if AlphaMode=TpvScene3D.TMaterial.TAlphaMode.Blend then begin
        VulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(true,
                                                                            VK_BLEND_FACTOR_SRC_ALPHA,
                                                                            VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                            VK_BLEND_OP_ADD,
                                                                            VK_BLEND_FACTOR_ONE,
                                                                            VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                            VK_BLEND_OP_ADD,
                                                                            TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                            TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                            TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                            TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));
       end else begin
        VulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                            VK_BLEND_FACTOR_ZERO,
                                                                            VK_BLEND_FACTOR_ZERO,
                                                                            VK_BLEND_OP_ADD,
                                                                            VK_BLEND_FACTOR_ZERO,
                                                                            VK_BLEND_FACTOR_ZERO,
                                                                            VK_BLEND_OP_ADD,
                                                                            TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                            TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                            TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                            TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));
       end;
      end;

      VulkanGraphicsPipeline.DepthStencilState.DepthTestEnable:=true;
      VulkanGraphicsPipeline.DepthStencilState.DepthWriteEnable:=AlphaMode<>TpvScene3D.TMaterial.TAlphaMode.Blend;
      if fInstance.ZFar<0.0 then begin
       VulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_GREATER_OR_EQUAL;
       end else begin
       VulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_LESS_OR_EQUAL;
      end;
      VulkanGraphicsPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
      VulkanGraphicsPipeline.DepthStencilState.StencilTestEnable:=false;

      VulkanGraphicsPipeline.Initialize;

      VulkanGraphicsPipeline.FreeMemory;

     finally
      fVulkanGraphicsPipelines[DepthPrePass,AlphaMode,PrimitiveTopology,FaceCullingMode]:=VulkanGraphicsPipeline;
     end;

    end;

   end;

  end;

 end;

 VulkanGraphicsPipeline:=TpvVulkanGraphicsPipeline.Create(fInstance.Renderer.VulkanDevice,
                                                          fInstance.Renderer.VulkanPipelineCache,
                                                          0,
                                                          [],
                                                          fVulkanPipelineLayout,
                                                          fVulkanRenderPass,
                                                          VulkanRenderPassSubpassIndex,
                                                          nil,
                                                          0);

 try

  VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageDebugPrimitiveVertex);
  VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageDebugPrimitiveFragment);

  VulkanGraphicsPipeline.InputAssemblyState.Topology:=TVkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_LINE_LIST;
  VulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

  fInstance.Renderer.Scene3D.InitializeDebugPrimitiveGraphicsPipeline(VulkanGraphicsPipeline);

  VulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,fInstance.ReflectionProbeWidth,fInstance.ReflectionProbeHeight,0.0,1.0);
  VulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,fInstance.ReflectionProbeWidth,fInstance.ReflectionProbeHeight);

  VulkanGraphicsPipeline.RasterizationState.DepthClampEnable:=false;
  VulkanGraphicsPipeline.RasterizationState.RasterizerDiscardEnable:=false;
  VulkanGraphicsPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
  VulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_NONE);
  VulkanGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_COUNTER_CLOCKWISE;
  VulkanGraphicsPipeline.RasterizationState.DepthBiasEnable:=false;
  VulkanGraphicsPipeline.RasterizationState.DepthBiasConstantFactor:=0.0;
  VulkanGraphicsPipeline.RasterizationState.DepthBiasClamp:=0.0;
  VulkanGraphicsPipeline.RasterizationState.DepthBiasSlopeFactor:=0.0;
  VulkanGraphicsPipeline.RasterizationState.LineWidth:=3.0;

  VulkanGraphicsPipeline.MultisampleState.RasterizationSamples:=VK_SAMPLE_COUNT_1_BIT;
  VulkanGraphicsPipeline.MultisampleState.SampleShadingEnable:=false;
  VulkanGraphicsPipeline.MultisampleState.MinSampleShading:=0.0;
  VulkanGraphicsPipeline.MultisampleState.CountSampleMasks:=0;
  VulkanGraphicsPipeline.MultisampleState.AlphaToCoverageEnable:=false;
  VulkanGraphicsPipeline.MultisampleState.AlphaToOneEnable:=false;

  VulkanGraphicsPipeline.ColorBlendState.LogicOpEnable:=false;
  VulkanGraphicsPipeline.ColorBlendState.LogicOp:=VK_LOGIC_OP_COPY;
  VulkanGraphicsPipeline.ColorBlendState.BlendConstants[0]:=0.0;
  VulkanGraphicsPipeline.ColorBlendState.BlendConstants[1]:=0.0;
  VulkanGraphicsPipeline.ColorBlendState.BlendConstants[2]:=0.0;
  VulkanGraphicsPipeline.ColorBlendState.BlendConstants[3]:=0.0;
  VulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_OP_ADD,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_OP_ADD,
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));

  VulkanGraphicsPipeline.DepthStencilState.DepthTestEnable:=false;
  VulkanGraphicsPipeline.DepthStencilState.DepthWriteEnable:=false;
  if fInstance.ZFar<0.0 then begin
   VulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_GREATER_OR_EQUAL;
   end else begin
   VulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_LESS_OR_EQUAL;
  end;
  VulkanGraphicsPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
  VulkanGraphicsPipeline.DepthStencilState.StencilTestEnable:=false;

  VulkanGraphicsPipeline.Initialize;

  VulkanGraphicsPipeline.FreeMemory;

 finally
  fVulkanDebugPrimitiveGraphicsPipeline:=VulkanGraphicsPipeline;
 end;

 fSkyBox.AllocateResources(fVulkanRenderPass,
                           fInstance.ReflectionProbeWidth,
                           fInstance.ReflectionProbeHeight,
                           VK_SAMPLE_COUNT_1_BIT);

end;

procedure TpvScene3DRendererPassesReflectionProbeRenderPass.ReleaseVolatileResources;
var Index:TpvSizeInt;
    DepthPrePass:boolean;
    AlphaMode:TpvScene3D.TMaterial.TAlphaMode;
    PrimitiveTopology:TpvScene3D.TPrimitiveTopology;
    FaceCullingMode:TpvScene3D.TFaceCullingMode;
begin
 fSkyBox.ReleaseResources;
 FreeAndNil(fVulkanDebugPrimitiveGraphicsPipeline);
 for DepthPrePass:=false to fInstance.Renderer.UseDepthPrepass do begin
  for AlphaMode:=Low(TpvScene3D.TMaterial.TAlphaMode) to High(TpvScene3D.TMaterial.TAlphaMode) do begin
   for PrimitiveTopology:=Low(TpvScene3D.TPrimitiveTopology) to High(TpvScene3D.TPrimitiveTopology) do begin
    for FaceCullingMode:=Low(TpvScene3D.TFaceCullingMode) to High(TpvScene3D.TFaceCullingMode) do begin
     FreeAndNil(fVulkanGraphicsPipelines[DepthPrePass,AlphaMode,PrimitiveTopology,FaceCullingMode]);
    end;
   end;
  end;
 end;
 FreeAndNil(fVulkanPipelineLayout);
 for Index:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fPassVulkanDescriptorSets[Index]);
  FreeAndNil(fIBLDescriptors[Index]);
 end;
 FreeAndNil(fPassVulkanDescriptorPool);
 FreeAndNil(fPassVulkanDescriptorSetLayout);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesReflectionProbeRenderPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesReflectionProbeRenderPass.OnSetRenderPassResources(const aCommandBuffer:TpvVulkanCommandBuffer;
                                                                                     const aPipelineLayout:TpvVulkanPipelineLayout;
                                                                                     const aRendererInstance:TObject;
                                                                                     const aRenderPass:TpvScene3DRendererRenderPass;
                                                                                     const aPreviousInFlightFrameIndex:TpvSizeInt;
                                                                                     const aInFlightFrameIndex:TpvSizeInt);
begin
 if not fOnSetRenderPassResourcesDone then begin
  fOnSetRenderPassResourcesDone:=true;
  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                       fVulkanPipelineLayout.Handle,
                                       1,
                                       1,
                                       @fPassVulkanDescriptorSets[aInFlightFrameIndex].Handle,
                                       0,
                                       nil);
 end;
end;

procedure TpvScene3DRendererPassesReflectionProbeRenderPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;
                                                            const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameState:TpvScene3DRendererInstance.PInFlightFrameState;
begin
 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 InFlightFrameState:=@fInstance.InFlightFrameStates^[aInFlightFrameIndex];

 if InFlightFrameState^.Ready then begin

  fIBLDescriptors[aInFlightFrameIndex].SetFrom(fInstance.Renderer.Scene3D,fInstance,aInFlightFrameIndex);
  fIBLDescriptors[aInFlightFrameIndex].Update(true);

{}fSkyBox.Draw(aInFlightFrameIndex,
               InFlightFrameState^.ReflectionProbeViewIndex,
               InFlightFrameState^.CountReflectionProbeViews,
               aCommandBuffer,
               InFlightFrameState^.SkyBoxOrientation);//{}

  if true then begin

   fOnSetRenderPassResourcesDone:=false;

   if fInstance.Renderer.UseDepthPrepass then begin

    fInstance.Renderer.Scene3D.Draw(fInstance,
                                    fVulkanGraphicsPipelines[true,TpvScene3D.TMaterial.TAlphaMode.Opaque],
                                    -1,
                                    aInFlightFrameIndex,
                                    TpvScene3DRendererRenderPass.ReflectionProbe,
                                    InFlightFrameState^.ReflectionProbeViewIndex,
                                    InFlightFrameState^.CountReflectionProbeViews,
                                    FrameGraph.DrawFrameIndex,
                                    aCommandBuffer,
                                    fVulkanPipelineLayout,
                                    OnSetRenderPassResources,
                                    [TpvScene3D.TMaterial.TAlphaMode.Opaque],
                                    nil);

    if fInstance.Renderer.SurfaceSampleCountFlagBits=VK_SAMPLE_COUNT_1_BIT then begin
     fInstance.Renderer.Scene3D.Draw(fInstance,
                                     fVulkanGraphicsPipelines[true,TpvScene3D.TMaterial.TAlphaMode.Mask],
                                     -1,
                                     aInFlightFrameIndex,
                                     TpvScene3DRendererRenderPass.ReflectionProbe,
                                     InFlightFrameState^.ReflectionProbeViewIndex,
                                     InFlightFrameState^.CountReflectionProbeViews,
                                     FrameGraph.DrawFrameIndex,
                                     aCommandBuffer,
                                     fVulkanPipelineLayout,
                                     OnSetRenderPassResources,
                                     [TpvScene3D.TMaterial.TAlphaMode.Mask],
                                     nil);
    end; //}

   end;  // *)

   fInstance.Renderer.Scene3D.Draw(fInstance,
                                   fVulkanGraphicsPipelines[false,TpvScene3D.TMaterial.TAlphaMode.Opaque],
                                   -1,
                                   aInFlightFrameIndex,
                                   TpvScene3DRendererRenderPass.ReflectionProbe,
                                   InFlightFrameState^.ReflectionProbeViewIndex,
                                   InFlightFrameState^.CountReflectionProbeViews,
                                   FrameGraph.DrawFrameIndex,
                                   aCommandBuffer,
                                   fVulkanPipelineLayout,
                                   OnSetRenderPassResources,
                                   [TpvScene3D.TMaterial.TAlphaMode.Opaque],
                                   nil);

  if ((fInstance.Renderer.TransparencyMode=TpvScene3DRendererTransparencyMode.Direct) and not fInstance.Renderer.Scene3D.HasTransmission) or not (fInstance.Renderer.UseOITAlphaTest or fInstance.Renderer.Scene3D.HasTransmission) then begin
   fInstance.Renderer.Scene3D.Draw(fInstance,
                                   fVulkanGraphicsPipelines[false,TpvScene3D.TMaterial.TAlphaMode.Mask],
                                   -1,
                                   aInFlightFrameIndex,
                                   TpvScene3DRendererRenderPass.ReflectionProbe,
                                   InFlightFrameState^.ReflectionProbeViewIndex,
                                   InFlightFrameState^.CountReflectionProbeViews,
                                   FrameGraph.DrawFrameIndex,
                                   aCommandBuffer,
                                   fVulkanPipelineLayout,
                                   OnSetRenderPassResources,
                                   [TpvScene3D.TMaterial.TAlphaMode.Mask],
                                   nil);
  end;

 { if fInstance.Renderer.UseDepthPrepass then begin

   fInstance.Renderer.Scene3D.Draw(fVulkanGraphicsPipelines[true,TpvScene3D.TMaterial.TAlphaMode.Mask],
                                   -1,
                                   aInFlightFrameIndex,
                                   TpvScene3DRendererRenderPass.View,
                                   InFlightFrameState^.FinalViewIndex,
                                   InFlightFrameState^.CountFinalViews,
                                   fFrameGraph.DrawFrameIndex,
                                   aCommandBuffer,
                                   fVulkanPipelineLayout,
                                   OnSetRenderPassResources,
                                   [TpvScene3D.TMaterial.TAlphaMode.Mask],
                                   nil);

   end;}

  end;

 end;

end;

end.
