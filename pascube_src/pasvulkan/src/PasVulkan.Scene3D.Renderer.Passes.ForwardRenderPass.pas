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
unit PasVulkan.Scene3D.Renderer.Passes.ForwardRenderPass;
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
     PasVulkan.Scene3D.Renderer.VoxelVisualization,
     PasVulkan.Scene3D.Renderer.VoxelMeshVisualization,
     PasVulkan.Scene3D.Renderer.IBLDescriptor,
     PasVulkan.Scene3D.Planet;

type { TpvScene3DRendererPassesForwardRenderPass }
     TpvScene3DRendererPassesForwardRenderPass=class(TpvFrameGraph.TRenderPass)
      public
       type TSpaceLinesPushConstants=packed record
             ViewBaseIndex:TpvUInt32;
             CountViews:TpvUInt32;
             CountAllViews:TpvUInt32;
             Dummy:TpvUInt32;
             ViewPortSize:TpvVector2;
            end;
            PSpaceLinesPushConstants=^TSpaceLinesPushConstants;      
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
       fUsePreviousDepth:Boolean;
       fUseDepthPrepass:Boolean;
       fResourceCascadedShadowMap:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceSSAO:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceColor:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceVelocity:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceDepth:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceWetnessMap:TpvFrameGraph.TPass.TUsedImageResource;
       fMeshVertexShaderModule:TpvVulkanShaderModule;
       fMeshVelocityVertexShaderModule:TpvVulkanShaderModule;
       fMeshFragmentShaderModule:TpvVulkanShaderModule;
       fMeshMaskedFragmentShaderModule:TpvVulkanShaderModule;
       fMeshDepthFragmentShaderModule:TpvVulkanShaderModule;
       fMeshDepthMaskedFragmentShaderModule:TpvVulkanShaderModule;
       fSpaceLinesVertexShaderModule:TpvVulkanShaderModule;
       fSpaceLinesFragmentShaderModule:TpvVulkanShaderModule;
       fPassVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fPassVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fPassVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fIBLDescriptors:array[0..MaxInFlightFrames-1] of TpvScene3DRendererIBLDescriptor;
       fVulkanPipelineShaderStageMeshVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshVelocityVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshFragment:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshMaskedFragment:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshDepthFragment:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshDepthMaskedFragment:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageSpaceLinesVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageSpaceLinesFragment:TpvVulkanPipelineShaderStage;
       fVulkanGraphicsPipelines:array[boolean,TpvScene3D.TMaterial.TAlphaMode] of TpvScene3D.TGraphicsPipelines;
       fVulkanSpaceLinesGraphicsPipeline:TpvVulkanGraphicsPipeline;
       fVulkanPipelineLayout:TpvVulkanPipelineLayout;
       fVulkanSpaceLinesPipelineLayout:TpvVulkanPipelineLayout;
       fSkyBox:TpvScene3DRendererSkyBox;
       fPlanetDepthPrePass:TpvScene3DPlanet.TRenderPass;
       fPlanetOpaquePass:TpvScene3DPlanet.TRenderPass;
//     fPlanetRainStreakRenderPass:TpvScene3DPlanet.TRainStreakRenderPass;
       fVoxelVisualization:TpvScene3DRendererVoxelVisualization;
       fVoxelMeshVisualization:TpvScene3DRendererVoxelMeshVisualization;
       fSpaceLinesPushConstants:TSpaceLinesPushConstants;
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

{ TpvScene3DRendererPassesForwardRenderPass }

constructor TpvScene3DRendererPassesForwardRenderPass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='ForwardRenderPass';

 if fInstance.SurfaceMultiviewMask=1 then begin
  MultiviewMask:=0;
 end else begin
  MultiviewMask:=fInstance.SurfaceMultiviewMask;
 end;

 Queue:=aFrameGraph.UniversalQueue;

 Size:=TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,
                                       fInstance.SizeFactor,
                                       fInstance.SizeFactor,
                                       1.0,
                                       fInstance.CountSurfaceViews);

 fUsePreviousDepth:=fInstance.Renderer.GPUCulling or fInstance.Renderer.EarlyDepthPrepassNeeded;

 fUseDepthPrepass:=fInstance.Renderer.UseDepthPrepass and not ({fInstance.Renderer.GPUCulling or} fInstance.Renderer.EarlyDepthPrepassNeeded);

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

 fResourceVelocity:=nil;

 if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin

  fResourceColor:=AddImageOutput('resourcetype_color_optimized_non_alpha',
                                 'resource_forwardrendering_color',
                                 VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                 TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                              TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0)),
                                 [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                );

  if fInstance.Renderer.VelocityBufferNeeded then begin

   fResourceVelocity:=AddImageOutput('resourcetype_velocity',
                                     'resource_velocity_data',
                                     VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                     TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                                  TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0)),
                                     [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                    );

  end;

  if fUsePreviousDepth then begin

   fResourceDepth:=AddImageDepthInput('resourcetype_depth',
                                      'resource_depth_data',
//                                    VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL,//VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL,//VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
                                      VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
                                      [TpvFrameGraph.TResourceTransition.TFlag.Attachment,
                                       TpvFrameGraph.TResourceTransition.TFlag.ExplicitOutputAttachment]
                                     );//}

  end else begin

   fResourceDepth:=AddImageDepthOutput('resourcetype_depth',
                                       'resource_depth_data',
                                       VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
                                       TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                                    TpvVector4.InlineableCreate(IfThen(fInstance.ZFar<0.0,0.0,1.0),0.0,0.0,0.0)),
                                       [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                      ); //}

  end;

  if fInstance.Renderer.WetnessMapActive then begin
   fResourceWetnessMap:=AddImageInput('resourcetype_wetnessmap',
                                       'resource_wetnessmap',
                                       VK_IMAGE_LAYOUT_GENERAL,
                                       []
                                      );
  end else begin
   fResourceWetnessMap:=nil;
  end;

 end else begin

  fResourceColor:=AddImageOutput('resourcetype_msaa_color_optimized_non_alpha',
                                 'resource_forwardrendering_msaa_color',
                                 VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                 TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                              TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0)),
                                 [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                );

{ fResourceColor:=AddImageResolveOutput('resourcetype_color_optimized_non_alpha',
                                        'resource_forwardrendering_color',
                                        'resource_forwardrendering_msaa_color',
                                        VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                        TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.DontCare,
                                                                     TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0)),
                                        [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                       );}

  if fInstance.Renderer.VelocityBufferNeeded then begin

   fResourceVelocity:=AddImageOutput('resourcetype_msaa_velocity',
                                     'resource_forwardrendering_msaa_velocity',
                                     VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                     TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                                  TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0)),
                                     [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                    );

   fResourceVelocity:=AddImageResolveOutput('resourcetype_velocity',
                                            'resource_velocity_data',
                                            'resource_forwardrendering_msaa_velocity',
                                            VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                            TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.DontCare,
                                                                         TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0)),
                                            [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                          );

  end;

  if fUsePreviousDepth then begin

   fResourceDepth:=AddImageDepthInput('resourcetype_msaa_depth',
                                      'resource_msaa_depth_data',
//                                    VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL,//VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL,//VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
                                      VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
                                      [TpvFrameGraph.TResourceTransition.TFlag.Attachment,
                                       TpvFrameGraph.TResourceTransition.TFlag.ExplicitOutputAttachment]
                                     );

  end else begin

   fResourceDepth:=AddImageDepthOutput('resourcetype_msaa_depth',
                                       'resource_msaa_depth_data',
                                       VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
                                       TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                                    TpvVector4.InlineableCreate(IfThen(fInstance.ZFar<0.0,0.0,1.0),0.0,0.0,0.0)),
                                       [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                      );

  end;

  if fInstance.Renderer.WetnessMapActive then begin
   fResourceWetnessMap:=AddImageInput('resourcetype_msaa_wetnessmap',
                                       'resource_msaa_wetnessmap',
                                       VK_IMAGE_LAYOUT_GENERAL,
                                       []
                                      );
  end else begin
   fResourceWetnessMap:=nil;
  end;

 end;

end;

destructor TpvScene3DRendererPassesForwardRenderPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesForwardRenderPass.AcquirePersistentResources;
var Index:TpvSizeInt;
    Stream:TStream;
    MeshFragmentSpecializationConstants:TpvScene3DRendererInstance.TMeshFragmentSpecializationConstants;
    VelocityVariant,WetnessMapVariant:TpvUTF8String;
begin
 inherited AcquirePersistentResources;

 MeshFragmentSpecializationConstants:=fInstance.MeshFragmentSpecializationConstants;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_vert.spv');
 try
  fMeshVertexShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 if fInstance.Renderer.VelocityBufferNeeded then begin

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_velocity_vert.spv');
  try
   fMeshVelocityVertexShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;

  VelocityVariant:='_velocity';

 end else begin

  fMeshVelocityVertexShaderModule:=nil;

  VelocityVariant:='';

 end;

 if fInstance.Renderer.WetnessMapActive then begin
  WetnessMapVariant:='wetness_';
 end else begin
  WetnessMapVariant:='';
 end;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+WetnessMapVariant+fInstance.Renderer.MeshFragShadowTypeName+VelocityVariant+'_frag.spv');
 try
  fMeshFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 if fInstance.Renderer.UseDemote then begin
  if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+WetnessMapVariant+fInstance.Renderer.MeshFragShadowTypeName+VelocityVariant+'_alphatest_demote_frag.spv');
  end else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+'msaa_'+WetnessMapVariant+fInstance.Renderer.MeshFragShadowTypeName+VelocityVariant+'_alphatest_demote_frag.spv');
  end;
 end else if fInstance.Renderer.UseNoDiscard then begin
  if fInstance.ZFar<0.0 then begin
   if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_reversedz_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+WetnessMapVariant+fInstance.Renderer.MeshFragShadowTypeName+VelocityVariant+'_alphatest_nodiscard_frag.spv');
   end else begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_reversedz_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+'msaa_'+WetnessMapVariant+fInstance.Renderer.MeshFragShadowTypeName+VelocityVariant+'_alphatest_nodiscard_frag.spv');
   end;
  end else begin
   if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+WetnessMapVariant+fInstance.Renderer.MeshFragShadowTypeName+VelocityVariant+'_alphatest_nodiscard_frag.spv');
   end else begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+'msaa_'+WetnessMapVariant+fInstance.Renderer.MeshFragShadowTypeName+VelocityVariant+'_alphatest_nodiscard_frag.spv');
   end;
  end;
 end else begin
  if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+WetnessMapVariant+fInstance.Renderer.MeshFragShadowTypeName+VelocityVariant+'_alphatest_frag.spv');
  end else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+'msaa_'+WetnessMapVariant+fInstance.Renderer.MeshFragShadowTypeName+VelocityVariant+'_alphatest_frag.spv');
  end;
 end;
 try
  fMeshMaskedFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 if fUseDepthPrepass then begin

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

 end else begin

  fMeshDepthFragmentShaderModule:=nil;

  fMeshDepthMaskedFragmentShaderModule:=nil;

 end;

 fVulkanPipelineShaderStageMeshVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fMeshVertexShaderModule,'main');

 if assigned(fMeshVelocityVertexShaderModule) then begin
  fVulkanPipelineShaderStageMeshVelocityVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fMeshVelocityVertexShaderModule,'main');
 end else begin
  fVulkanPipelineShaderStageMeshVelocityVertex:=nil;
 end;

 fVulkanPipelineShaderStageMeshFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fMeshFragmentShaderModule,'main');
 MeshFragmentSpecializationConstants.SetPipelineShaderStage(fVulkanPipelineShaderStageMeshFragment);

 fVulkanPipelineShaderStageMeshMaskedFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fMeshMaskedFragmentShaderModule,'main');
 MeshFragmentSpecializationConstants.SetPipelineShaderStage(fVulkanPipelineShaderStageMeshMaskedFragment);

 if fUseDepthPrepass then begin

  fVulkanPipelineShaderStageMeshDepthFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fMeshDepthFragmentShaderModule,'main');
  MeshFragmentSpecializationConstants.SetPipelineShaderStage(fVulkanPipelineShaderStageMeshDepthFragment);

  fVulkanPipelineShaderStageMeshDepthMaskedFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fMeshDepthMaskedFragmentShaderModule,'main');
  MeshFragmentSpecializationConstants.SetPipelineShaderStage(fVulkanPipelineShaderStageMeshDepthMaskedFragment);

 end else begin

  fVulkanPipelineShaderStageMeshDepthFragment:=nil;

  fVulkanPipelineShaderStageMeshDepthMaskedFragment:=nil;

 end;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('space_lines_vert.spv');
 try
  fSpaceLinesVertexShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fSpaceLinesVertexShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererPassesForwardRenderPass.SpaceLinesVertexShaderModule');

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('space_lines_frag.spv');
 try
  fSpaceLinesFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fSpaceLinesFragmentShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererPassesForwardRenderPass.SpaceLinesFragmentShaderModule');

 fVulkanPipelineShaderStageSpaceLinesVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fSpaceLinesVertexShaderModule,'main');

 fVulkanPipelineShaderStageSpaceLinesFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fSpaceLinesFragmentShaderModule,'main');

 fSkyBox:=TpvScene3DRendererSkyBox.Create(fInstance.Renderer,
                                          fInstance,
                                          fInstance.Renderer.Scene3D,
                                          fInstance.Renderer.SkyBoxCubeMap.DescriptorImageInfo);

 if fUseDepthPrepass then begin
  if fInstance.Renderer.GPUCulling then begin
   fPlanetDepthPrePass:=TpvScene3DPlanet.TRenderPass.Create(fInstance.Renderer,
                                                            fInstance,
                                                            fInstance.Renderer.Scene3D,
                                                            TpvScene3DPlanet.TRenderPass.TMode.DepthPrepassDisocclusion,
                                                            fResourceCascadedShadowMap,
                                                            fResourceSSAO);
  end else begin
   fPlanetDepthPrePass:=TpvScene3DPlanet.TRenderPass.Create(fInstance.Renderer,
                                                            fInstance,
                                                            fInstance.Renderer.Scene3D,
                                                            TpvScene3DPlanet.TRenderPass.TMode.DepthPrePass,
                                                            fResourceCascadedShadowMap,
                                                            fResourceSSAO);
  end;
 end;

 fPlanetOpaquePass:=TpvScene3DPlanet.TRenderPass.Create(fInstance.Renderer,
                                                        fInstance,
                                                        fInstance.Renderer.Scene3D,
                                                        TpvScene3DPlanet.TRenderPass.TMode.Opaque,
                                                        fResourceCascadedShadowMap,
                                                        fResourceSSAO);

{fPlanetRainStreakRenderPass:=TpvScene3DPlanet.TRainStreakRenderPass.Create(fInstance.Renderer,
                                                                            fInstance,
                                                                            fInstance.Renderer.Scene3D);//}

 fVoxelVisualization:=nil;
 fVoxelMeshVisualization:=nil;

 if fInstance.Renderer.GlobalIlluminationMode=TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing then begin
{ fVoxelVisualization:=TpvScene3DRendererVoxelVisualization.Create(fInstance,
                                                                   fInstance.Renderer,
                                                                   fInstance.Renderer.Scene3D);//}
  fVoxelMeshVisualization:=TpvScene3DRendererVoxelMeshVisualization.Create(fInstance,
                                                                           fInstance.Renderer,
                                                                           fInstance.Renderer.Scene3D);//}
 end;

end;

procedure TpvScene3DRendererPassesForwardRenderPass.ReleasePersistentResources;
begin

 FreeAndNil(fVoxelVisualization);

 FreeAndNil(fVoxelMeshVisualization);

 if fUseDepthPrepass then begin
  FreeAndNil(fPlanetDepthPrePass);
 end; 

 FreeAndNil(fPlanetOpaquePass);

//FreeAndNil(fPlanetRainStreakRenderPass);

 FreeAndNil(fSkyBox);

 FreeAndNil(fVulkanPipelineShaderStageSpaceLinesVertex);

 FreeAndNil(fVulkanPipelineShaderStageSpaceLinesFragment);

 FreeAndNil(fVulkanPipelineShaderStageMeshVertex);

 FreeAndNil(fVulkanPipelineShaderStageMeshVelocityVertex);

 FreeAndNil(fVulkanPipelineShaderStageMeshFragment);

 FreeAndNil(fVulkanPipelineShaderStageMeshMaskedFragment);

 if fUseDepthPrepass then begin

  FreeAndNil(fVulkanPipelineShaderStageMeshDepthFragment);

  FreeAndNil(fVulkanPipelineShaderStageMeshDepthMaskedFragment);

 end;

 FreeAndNil(fSpaceLinesVertexShaderModule);

 FreeAndNil(fSpaceLinesFragmentShaderModule);

 FreeAndNil(fMeshVertexShaderModule);

 FreeAndNil(fMeshVelocityVertexShaderModule);

 FreeAndNil(fMeshFragmentShaderModule);

 FreeAndNil(fMeshMaskedFragmentShaderModule);

 if fUseDepthPrepass then begin

  FreeAndNil(fMeshDepthFragmentShaderModule);

  FreeAndNil(fMeshDepthMaskedFragmentShaderModule);

 end;

 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesForwardRenderPass.AcquireVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
    DepthPrePass:boolean;
    AlphaMode:TpvScene3D.TMaterial.TAlphaMode;
    PrimitiveTopology:TpvScene3D.TPrimitiveTopology;
    FaceCullingMode:TpvScene3D.TFaceCullingMode;
    VulkanGraphicsPipeline:TpvVulkanGraphicsPipeline;
    DescriptorImageInfos:array of TVkDescriptorImageInfo;
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
                                           4,
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
 if assigned(fResourceWetnessMap) then begin
  fPassVulkanDescriptorSetLayout.AddBinding(9,
                                            VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,
                                            1,
                                            TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                            []);
  fPassVulkanDescriptorSetLayout.AddBinding(10,
                                            VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                            3,
                                            TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                            []);
 end;
 fPassVulkanDescriptorSetLayout.Initialize;

 fPassVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,22*fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,3*fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,3*fInstance.Renderer.CountInFlightFrames);
 if assigned(fResourceWetnessMap) then begin
  fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,1*fInstance.Renderer.CountInFlightFrames); 
 end; 
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
  DescriptorImageInfos:=nil;
  try
   // 0 = SSAO, 1 = Opaque frame buffer, 2 = Opaque depth buffer, 3 = Clouds shadow map
   SetLength(DescriptorImageInfos,4);
   if fInstance.Renderer.ScreenSpaceAmbientOcclusion then begin
    DescriptorImageInfos[0]:=TVkDescriptorImageInfo.Create(fInstance.Renderer.AmbientOcclusionSampler.Handle,
                                                           fResourceSSAO.VulkanImageViews[InFlightFrameIndex].Handle,
                                                           fResourceSSAO.ResourceTransition.Layout);// TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL));
   end else begin
    DescriptorImageInfos[0]:=TVkDescriptorImageInfo.Create(fInstance.Renderer.AmbientOcclusionSampler.Handle,
                                                           fInstance.Renderer.EmptyAmbientOcclusionTexture.ImageView.Handle,
                                                           TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL));
   end;
   // Duplicate as dummy really non-used opaque texture
   DescriptorImageInfos[1]:=DescriptorImageInfos[0]; // Opaque frame buffer
   DescriptorImageInfos[2]:=DescriptorImageInfos[0]; // Opaque depth buffer
   DescriptorImageInfos[3]:=DescriptorImageInfos[0]; // Clouds shadow map (replaced with the real texture later, if implemented later, dummy for now)
   fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,
                                                                      0,
                                                                      Length(DescriptorImageInfos),
                                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                      DescriptorImageInfos,
                                                                      [],
                                                                      [],
                                                                      false); 
  finally
   DescriptorImageInfos:=nil;
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
  if assigned(fResourceWetnessMap) then begin
   fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(9,
                                                                      0,
                                                                      1,
                                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE),
                                                                      [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                     fResourceWetnessMap.VulkanImageViews[InFlightFrameIndex].Handle,
                                                                                                     fResourceWetnessMap.ResourceTransition.Layout)],
                                                                      [],
                                                                      [],
                                                                      false);
   fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(10,
                                                                      0,
                                                                      3,
                                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                      [TVkDescriptorImageInfo.Create(fInstance.Renderer.Scene3D.GeneralRepeatingSampler.Handle,
                                                                                                     fInstance.Renderer.Scene3D.RainTexture.ImageView.Handle,
                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                                       TVkDescriptorImageInfo.Create(fInstance.Renderer.Scene3D.GeneralRepeatingSampler.Handle,
                                                                                                     fInstance.Renderer.Scene3D.RainNormalTexture.ImageView.Handle,
                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                                       TVkDescriptorImageInfo.Create(fInstance.Renderer.Scene3D.GeneralRepeatingSampler.Handle,
                                                                                                     fInstance.Renderer.Scene3D.RainStreaksNormalTexture.ImageView.Handle,
                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                      [],
                                                                      [],
                                                                      false);
  end;
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

 fVulkanSpaceLinesPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanSpaceLinesPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),0,SizeOf(TSpaceLinesPushConstants));
 fVulkanSpaceLinesPipelineLayout.AddDescriptorSetLayout(fInstance.Renderer.Scene3D.GlobalVulkanDescriptorSetLayout);
 fVulkanSpaceLinesPipelineLayout.AddDescriptorSetLayout(fPassVulkanDescriptorSetLayout);
 fVulkanSpaceLinesPipelineLayout.Initialize;

 for DepthPrePass:=false to fUseDepthPrepass do begin
  for AlphaMode:=Low(TpvScene3D.TMaterial.TAlphaMode) to High(TpvScene3D.TMaterial.TAlphaMode) do begin
   for PrimitiveTopology:=Low(TpvScene3D.TPrimitiveTopology) to High(TpvScene3D.TPrimitiveTopology) do begin
    for FaceCullingMode:=Low(TpvScene3D.TFaceCullingMode) to High(TpvScene3D.TFaceCullingMode) do begin
     FreeAndNil(fVulkanGraphicsPipelines[DepthPrePass,AlphaMode,PrimitiveTopology,FaceCullingMode]);
    end;
   end;
  end;
 end;

 for DepthPrePass:=false to fUseDepthPrepass do begin

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

      if DepthPrePass then begin
       VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshVertex);
       if AlphaMode=TpvScene3D.TMaterial.TAlphaMode.Mask then begin
        VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshDepthMaskedFragment);
{      end else begin
        VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshDepthFragment);}
       end;
      end else begin
       if fInstance.Renderer.VelocityBufferNeeded then begin
        VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshVelocityVertex);
       end else begin
        VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshVertex);
       end;
       if AlphaMode=TpvScene3D.TMaterial.TAlphaMode.Mask then begin
        VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshMaskedFragment);
       end else begin
        VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshFragment);
       end;
      end;

      VulkanGraphicsPipeline.InputAssemblyState.Topology:=TpvScene3D.VulkanPrimitiveTopologies[PrimitiveTopology];
      VulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

      fInstance.Renderer.Scene3D.InitializeGraphicsPipeline(VulkanGraphicsPipeline,fInstance.Renderer.VelocityBufferNeeded and not DepthPrePass);

      VulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,fResourceColor.Width,fResourceColor.Height,0.0,1.0);
      VulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,fResourceColor.Width,fResourceColor.Height);

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

      VulkanGraphicsPipeline.MultisampleState.RasterizationSamples:=fInstance.Renderer.SurfaceSampleCountFlagBits;
      if (not DepthPrePass) and
         (AlphaMode=TpvScene3D.TMaterial.TAlphaMode.Mask) and
         (VulkanGraphicsPipeline.MultisampleState.RasterizationSamples<>VK_SAMPLE_COUNT_1_BIT) then begin
       VulkanGraphicsPipeline.MultisampleState.SampleShadingEnable:=true;
       VulkanGraphicsPipeline.MultisampleState.MinSampleShading:=1.0;
       VulkanGraphicsPipeline.MultisampleState.CountSampleMasks:=0;
       VulkanGraphicsPipeline.MultisampleState.AlphaToCoverageEnable:=true;
       VulkanGraphicsPipeline.MultisampleState.AlphaToOneEnable:=false;
       VulkanGraphicsPipeline.MultisampleState.AddSampleMask((1 shl fInstance.Renderer.CountSurfaceMSAASamples)-1);
      end else begin
       VulkanGraphicsPipeline.MultisampleState.SampleShadingEnable:=false;
       VulkanGraphicsPipeline.MultisampleState.MinSampleShading:=0.0;
       VulkanGraphicsPipeline.MultisampleState.CountSampleMasks:=0;
       VulkanGraphicsPipeline.MultisampleState.AlphaToCoverageEnable:=false;
       VulkanGraphicsPipeline.MultisampleState.AlphaToOneEnable:=false;
      end;

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
       if fInstance.Renderer.VelocityBufferNeeded then begin
        VulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                            VK_BLEND_FACTOR_ZERO,
                                                                            VK_BLEND_FACTOR_ZERO,
                                                                            VK_BLEND_OP_ADD,
                                                                            VK_BLEND_FACTOR_ZERO,
                                                                            VK_BLEND_FACTOR_ZERO,
                                                                            VK_BLEND_OP_ADD,
                                                                            0);
       end;
      end else begin
       if ((VulkanGraphicsPipeline.MultisampleState.RasterizationSamples<>VK_SAMPLE_COUNT_1_BIT) and
           (AlphaMode=TpvScene3D.TMaterial.TAlphaMode.Mask)) or
          (AlphaMode=TpvScene3D.TMaterial.TAlphaMode.Blend) then begin
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
       if fInstance.Renderer.VelocityBufferNeeded then begin
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

 begin

  VulkanGraphicsPipeline:=TpvVulkanGraphicsPipeline.Create(fInstance.Renderer.VulkanDevice,
                                                           fInstance.Renderer.VulkanPipelineCache,
                                                           0,
                                                           [],
                                                           fVulkanSpaceLinesPipelineLayout,
                                                           fVulkanRenderPass,
                                                           VulkanRenderPassSubpassIndex,
                                                           nil,
                                                           0);

  try

   VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageSpaceLinesVertex);
   VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageSpaceLinesFragment);

   VulkanGraphicsPipeline.InputAssemblyState.Topology:=TVkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
   VulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

   fInstance.InitializeSpaceLinesGraphicsPipeline(VulkanGraphicsPipeline);

   VulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,fResourceColor.Width,fResourceColor.Height,0.0,1.0);
   VulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,fResourceColor.Width,fResourceColor.Height);

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

   VulkanGraphicsPipeline.MultisampleState.RasterizationSamples:=fInstance.Renderer.SurfaceSampleCountFlagBits;
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
   VulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(true,
                                                                       VK_BLEND_FACTOR_ONE,
                                                                       VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                       VK_BLEND_OP_ADD,
                                                                       VK_BLEND_FACTOR_ONE,
                                                                       VK_BLEND_FACTOR_ZERO,
                                                                       VK_BLEND_OP_ADD,
                                                                       TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                       TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                       TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                       TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));
   if fInstance.Renderer.VelocityBufferNeeded then begin
    VulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                        VK_BLEND_FACTOR_ZERO,
                                                                        VK_BLEND_FACTOR_ZERO,
                                                                        VK_BLEND_OP_ADD,
                                                                        VK_BLEND_FACTOR_ZERO,
                                                                        VK_BLEND_FACTOR_ZERO,
                                                                        VK_BLEND_OP_ADD,
                                                                        0);
   end;

   VulkanGraphicsPipeline.DepthStencilState.DepthTestEnable:=true;
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
   fVulkanSpaceLinesGraphicsPipeline:=VulkanGraphicsPipeline;
   fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(VulkanGraphicsPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DRendererPassesForwardRenderPass.SpaceLinesGraphicsPipeline');
  end;

 end;

 fSkyBox.AllocateResources(fVulkanRenderPass,
                           fInstance.ScaledWidth,
                           fInstance.ScaledHeight,
                           fInstance.Renderer.SurfaceSampleCountFlagBits);
 
 if fUseDepthPrepass then begin
  fPlanetDepthPrePass.AllocateResources(fVulkanRenderPass,
                                        fInstance.ScaledWidth,
                                        fInstance.ScaledHeight,
                                        fInstance.Renderer.SurfaceSampleCountFlagBits);
 end;

 fPlanetOpaquePass.AllocateResources(fVulkanRenderPass,
                                     fInstance.ScaledWidth,
                                     fInstance.ScaledHeight,
                                     fInstance.Renderer.SurfaceSampleCountFlagBits);

{fPlanetRainStreakRenderPass.AllocateResources(fVulkanRenderPass,
                                               fInstance.ScaledWidth,
                                               fInstance.ScaledHeight,
                                               fInstance.Renderer.SurfaceSampleCountFlagBits);//}

 if assigned(fVoxelVisualization) then begin
  fVoxelVisualization.AllocateResources(fVulkanRenderPass,
                                        fInstance.ScaledWidth,
                                        fInstance.ScaledHeight,
                                        fInstance.Renderer.SurfaceSampleCountFlagBits);
 end;

 if assigned(fVoxelMeshVisualization) then begin
  fVoxelMeshVisualization.AllocateResources(fVulkanRenderPass,
                                            fInstance.ScaledWidth,
                                            fInstance.ScaledHeight,
                                            fInstance.Renderer.SurfaceSampleCountFlagBits);
 end;

end;

procedure TpvScene3DRendererPassesForwardRenderPass.ReleaseVolatileResources;
var Index:TpvSizeInt;
    DepthPrePass:boolean;
    AlphaMode:TpvScene3D.TMaterial.TAlphaMode;
    PrimitiveTopology:TpvScene3D.TPrimitiveTopology;
    FaceCullingMode:TpvScene3D.TFaceCullingMode;
begin
 if assigned(fVoxelVisualization) then begin
  fVoxelVisualization.ReleaseResources;
 end;
 if assigned(fVoxelMeshVisualization) then begin
  fVoxelMeshVisualization.ReleaseResources;
 end;
 fSkyBox.ReleaseResources;
 if fUseDepthPrepass then begin
  fPlanetDepthPrePass.ReleaseResources;
 end;
 fPlanetOpaquePass.ReleaseResources;
 //fPlanetRainStreakRenderPass.ReleaseResources;
 for DepthPrePass:=false to fUseDepthPrepass do begin
  for AlphaMode:=Low(TpvScene3D.TMaterial.TAlphaMode) to High(TpvScene3D.TMaterial.TAlphaMode) do begin
   for PrimitiveTopology:=Low(TpvScene3D.TPrimitiveTopology) to High(TpvScene3D.TPrimitiveTopology) do begin
    for FaceCullingMode:=Low(TpvScene3D.TFaceCullingMode) to High(TpvScene3D.TFaceCullingMode) do begin
     FreeAndNil(fVulkanGraphicsPipelines[DepthPrePass,AlphaMode,PrimitiveTopology,FaceCullingMode]);
    end;
   end;
  end;
 end;
 FreeAndNil(fVulkanSpaceLinesGraphicsPipeline);
 FreeAndNil(fVulkanPipelineLayout);
 FreeAndNil(fVulkanSpaceLinesPipelineLayout);
 for Index:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fPassVulkanDescriptorSets[Index]);
  FreeAndNil(fIBLDescriptors[Index]);
 end;
 FreeAndNil(fPassVulkanDescriptorPool);
 FreeAndNil(fPassVulkanDescriptorSetLayout);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesForwardRenderPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesForwardRenderPass.OnSetRenderPassResources(const aCommandBuffer:TpvVulkanCommandBuffer;
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
                                         @DescriptorSets[0],
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

procedure TpvScene3DRendererPassesForwardRenderPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;
                                                            const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameState:TpvScene3DRendererInstance.PInFlightFrameState;
    PreviousInFlightFrameIndex:TpvSizeInt;
begin
 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 InFlightFrameState:=@fInstance.InFlightFrameStates^[aInFlightFrameIndex];

 if InFlightFrameState^.Ready then begin

  fOnSetRenderPassResourcesDone:=false;

  fIBLDescriptors[aInFlightFrameIndex].SetFrom(fInstance.Renderer.Scene3D,fInstance,aInFlightFrameIndex);
  fIBLDescriptors[aInFlightFrameIndex].Update(true);

  if fInstance.Renderer.VelocityBufferNeeded then begin
   PreviousInFlightFrameIndex:=IfThen(aFrameIndex=0,aInFlightFrameIndex,FrameGraph.DrawPreviousInFlightFrameIndex);
  end else begin
   PreviousInFlightFrameIndex:=-1;
  end;

  if fInstance.GlobalIlluminationCascadedVoxelConeTracingDebugVisualization then begin

{  fSkyBox.Draw(aInFlightFrameIndex,
                InFlightFrameState^.FinalViewIndex,
                InFlightFrameState^.CountFinalViews,
                aCommandBuffer);//}

   if assigned(fVoxelMeshVisualization) then begin
    fVoxelMeshVisualization.Draw(aInFlightFrameIndex,
                                 InFlightFrameState^.FinalViewIndex,
                                 InFlightFrameState^.CountFinalViews,
                                 aCommandBuffer);
   end else if assigned(fVoxelVisualization) then begin
    fVoxelVisualization.Draw(aInFlightFrameIndex,
                             InFlightFrameState^.FinalViewIndex,
                             InFlightFrameState^.CountFinalViews,
                             aCommandBuffer);
   end;
  end else begin

   if fUseDepthPrepass then begin

    fPlanetDepthPrePass.Draw(aInFlightFrameIndex,
                             aFrameIndex,
                             TpvScene3DRendererRenderPass.View,
                             InFlightFrameState^.FinalViewIndex,
                             InFlightFrameState^.CountFinalViews,
                             aCommandBuffer);//}

    fInstance.Renderer.Scene3D.Draw(fInstance,
                                    fVulkanGraphicsPipelines[true,TpvScene3D.TMaterial.TAlphaMode.Opaque],
                                    -1,
                                    aInFlightFrameIndex,
                                    TpvScene3DRendererRenderPass.View,
                                    InFlightFrameState^.FinalViewIndex,
                                    InFlightFrameState^.CountFinalViews,
                                    FrameGraph.DrawFrameIndex,
                                    aCommandBuffer,
                                    fVulkanPipelineLayout,
                                    OnSetRenderPassResources,
                                    [TpvScene3D.TMaterial.TAlphaMode.Opaque],
                                    @InFlightFrameState^.Jitter,
                                    true);

 {  if fInstance.Renderer.SurfaceSampleCountFlagBits=VK_SAMPLE_COUNT_1_BIT then begin
     fInstance.Renderer.Scene3D.Draw(fInstance,
                                     fVulkanGraphicsPipelines[true,TpvScene3D.TMaterial.TAlphaMode.Mask],
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
                                     true);
    end;}

   end;   //*)

   fSkyBox.Draw(aInFlightFrameIndex,
                InFlightFrameState^.FinalUnjitteredViewIndex,
                InFlightFrameState^.CountFinalViews,
                aCommandBuffer,
                InFlightFrameState.SkyBoxOrientation);

   fPlanetOpaquePass.Draw(aInFlightFrameIndex,
                          aFrameIndex,
                          TpvScene3DRendererRenderPass.View,
                          InFlightFrameState^.FinalViewIndex,
                          InFlightFrameState^.CountFinalViews,
                          aCommandBuffer);

   fOnSetRenderPassResourcesDone:=false;

   fInstance.Renderer.Scene3D.Draw(fInstance,
                                   fVulkanGraphicsPipelines[false,TpvScene3D.TMaterial.TAlphaMode.Opaque],
                                   PreviousInFlightFrameIndex,
                                   aInFlightFrameIndex,
                                   TpvScene3DRendererRenderPass.View,
                                   InFlightFrameState^.FinalViewIndex,
                                   InFlightFrameState^.CountFinalViews,
                                   FrameGraph.DrawFrameIndex,
                                   aCommandBuffer,
                                   fVulkanPipelineLayout,
                                   OnSetRenderPassResources,
                                   [TpvScene3D.TMaterial.TAlphaMode.Opaque],
                                   @InFlightFrameState^.Jitter);

  if (InFlightFrameState^.FinalViewIndex>=0) and (InFlightFrameState^.CountFinalViews>0) and (fInstance.SpaceLinesPrimitiveDynamicArrays[aInFlightFrameIndex].Count>0) then begin

   FrameGraph.VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'Space Lines',[0.45,0.25,0.3725,1.0]);

   fSpaceLinesPushConstants.ViewBaseIndex:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].FinalViewIndex;
   fSpaceLinesPushConstants.CountViews:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].CountFinalViews;
   fSpaceLinesPushConstants.CountAllViews:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].CountViews;
   fSpaceLinesPushConstants.ViewPortSize:=TpvVector2.Create(fResourceColor.Width,fResourceColor.Height);
  
   aCommandBuffer.CmdPushConstants(fVulkanSpaceLinesPipelineLayout.Handle,
                                   TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_FRAGMENT_BIT),
                                   0,
                                   SizeOf(TSpaceLinesPushConstants),
                                   @fSpaceLinesPushConstants);

   aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                        fVulkanSpaceLinesPipelineLayout.Handle,
                                        0,
                                        1,
                                        @fInstance.Scene3D.GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle,
                                        0,
                                        nil);

   aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                        fVulkanSpaceLinesPipelineLayout.Handle,
                                        1,
                                        1,
                                        @fPassVulkanDescriptorSets[aInFlightFrameIndex].Handle,
                                        0,
                                        nil);

   fInstance.DrawSpaceLines(fInstance,
                            fVulkanSpaceLinesGraphicsPipeline,
                            -1,
                            aInFlightFrameIndex,
                            TpvScene3DRendererRenderPass.View,
                            InFlightFrameState^.FinalViewIndex,
                            InFlightFrameState^.CountFinalViews,
                            FrameGraph.DrawFrameIndex,
                            aCommandBuffer,
                            fVulkanSpaceLinesPipelineLayout,
                            nil);

   // Set flag to false, because we have to call OnSetRenderPassResources for the next draw call, as space lines were drawn with a different pipeline
   fOnSetRenderPassResourcesDone:=false;

   FrameGraph.VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

  end;

{ if fPlanetRainStreakRenderPass.Draw(aInFlightFrameIndex,
                                      aFrameIndex,
                                      TpvScene3DRendererRenderPass.View,
                                      InFlightFrameState^.FinalViewIndex,
                                      InFlightFrameState^.CountFinalViews,
                                      aCommandBuffer) then begin
   fOnSetRenderPassResourcesDone:=false;
  end;//}

  if ((fInstance.Renderer.TransparencyMode=TpvScene3DRendererTransparencyMode.Direct) and not fInstance.Renderer.Scene3D.HasTransmission) or
     (not (fInstance.Renderer.UseOITAlphaTest or fInstance.Renderer.Scene3D.HasTransmission)) then begin
   fInstance.Renderer.Scene3D.Draw(fInstance,
                                   fVulkanGraphicsPipelines[false,TpvScene3D.TMaterial.TAlphaMode.Mask],
                                   PreviousInFlightFrameIndex,
                                   aInFlightFrameIndex,
                                   TpvScene3DRendererRenderPass.View,
                                   InFlightFrameState^.FinalViewIndex,
                                   InFlightFrameState^.CountFinalViews,
                                   FrameGraph.DrawFrameIndex,
                                   aCommandBuffer,
                                   fVulkanPipelineLayout,
                                   OnSetRenderPassResources,
                                   [TpvScene3D.TMaterial.TAlphaMode.Mask],
                                   @InFlightFrameState^.Jitter);
  end;

 {if fUseDepthPrepass then begin

   fInstance.Renderer.Scene3D.Draw(fInstance,
                                   fVulkanGraphicsPipelines[true,TpvScene3D.TMaterial.TAlphaMode.Mask],
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
                                   @InFlightFrameState^.Jitter);

   end;}

  end;

 end;

end;

end.
