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
unit PasVulkan.Scene3D.Renderer.Passes.DeepAndFastApproximateOrderIndependentTransparencyRenderPass;
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
     PasVulkan.Scene3D.Renderer.IBLDescriptor;

type { TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyRenderPass }
     TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyRenderPass=class(TpvFrameGraph.TRenderPass)
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
       fMeshVertexShaderModule:TpvVulkanShaderModule;
       fMeshFragmentShaderModule:TpvVulkanShaderModule;
       fMeshMaskedFragmentShaderModule:TpvVulkanShaderModule;
       fPassVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fPassVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fPassVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fIBLDescriptors:array[0..MaxInFlightFrames-1] of TpvScene3DRendererIBLDescriptor;
       fVulkanPipelineShaderStageMeshVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshFragment:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshMaskedFragment:TpvVulkanPipelineShaderStage;
       fVulkanGraphicsPipelines:array[TpvScene3D.TMaterial.TAlphaMode] of TpvScene3D.TGraphicsPipelines;
       fVulkanPipelineLayout:TpvVulkanPipelineLayout;
       fParticleVertexShaderModule:TpvVulkanShaderModule;
       fParticleFragmentShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageParticleVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageParticleFragment:TpvVulkanPipelineShaderStage;
       fVulkanParticleGraphicsPipeline:TpvVulkanGraphicsPipeline;
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

{ TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyRenderPass }

constructor TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyRenderPass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='DeepAndFastApproximateOrderIndependentTransparencyRenderPass';

 MultiviewMask:=fInstance.SurfaceMultiviewMask;

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

  fResourceDepth:=AddImageDepthInput('resourcetype_depth',
                                     'resource_depth_data',
                                     VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL,//VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                     [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                    );

  fResourceColor:=AddImageOutput('resourcetype_color',
                                 'resource_orderindependenttransparency_tailblending_color',
                                 VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                 TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                              TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0)),
                                 [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                );

 end else begin

  fResourceDepth:=AddImageDepthInput('resourcetype_msaa_depth',
                                     'resource_msaa_depth_data',
                                     VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL,//VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                     [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                    );

  fResourceColor:=AddImageOutput('resourcetype_msaa_color',
                                 'resource_orderindependenttransparency_tailblending_msaa_color',
                                 VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                 TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                              TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0)),
                                 [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                );

{ fResourceColor:=AddImageResolveOutput('resourcetype_color',
                                        'resource_orderindependenttransparency_tailblending_color',
                                        'resource_orderindependenttransparency_tailblending_msaa_color',
                                        VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                        TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.DontCare,
                                                                     TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0)),
                                        [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                       );}

 end;

end;

destructor TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyRenderPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyRenderPass.AcquirePersistentResources;
var Index:TpvSizeInt;
    Stream:TStream;
    OITVariant:TpvUTF8String;
    MeshFragmentSpecializationConstants:TpvScene3DRendererInstance.TMeshFragmentSpecializationConstants;
begin
 inherited AcquirePersistentResources;

 MeshFragmentSpecializationConstants:=fInstance.MeshFragmentSpecializationConstants;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_vert.spv');
 try
  fMeshVertexShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
//fFrameGraph.VulkanDevice.DebugMarker.SetObjectName(fMeshVertexShaderModule.Handle,TVkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_SHADER_MODULE_EXT,'fMeshVertexShaderModule');
 finally
  Stream.Free;
 end;

 case fInstance.Renderer.TransparencyMode of
  TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT:begin
   OITVariant:='spinlock';
  end;
  TpvScene3DRendererTransparencyMode.INTERLOCKDFAOIT:begin
   OITVariant:='interlock';
  end;
  else begin
   Assert(false);
   OITVariant:='';
  end;
 end;

 if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
  if fInstance.ZFar<0.0 then begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_reversedz_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+fInstance.Renderer.MeshFragShadowTypeName+'_'+OITVariant+'_dfaoit_frag.spv');
  end else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+fInstance.Renderer.MeshFragShadowTypeName+'_'+OITVariant+'_dfaoit_frag.spv');
  end;
 end else begin
  if fInstance.ZFar<0.0 then begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_reversedz_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+'msaa_'+fInstance.Renderer.MeshFragShadowTypeName+'_'+OITVariant+'_dfaoit_frag.spv');
  end else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+'msaa_'+fInstance.Renderer.MeshFragShadowTypeName+'_'+OITVariant+'_dfaoit_frag.spv');
  end;
 end;
 try
  fMeshFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
//fFrameGraph.VulkanDevice.DebugMarker.SetObjectName(fMeshFragmentShaderModule.Handle,TVkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_SHADER_MODULE_EXT,'fMeshFragmentShaderModule');
 finally
  Stream.Free;
 end;

 if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
  if fInstance.ZFar<0.0 then begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_reversedz_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+fInstance.Renderer.MeshFragShadowTypeName+'_'+OITVariant+'_dfaoit_alphatest_frag.spv');
  end else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+fInstance.Renderer.MeshFragShadowTypeName+'_'+OITVariant+'_dfaoit_alphatest_frag.spv');
  end;
 end else begin
  if fInstance.ZFar<0.0 then begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_reversedz_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+'msaa_'+fInstance.Renderer.MeshFragShadowTypeName+'_'+OITVariant+'_dfaoit_alphatest_frag.spv');
  end else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_shading_'+fInstance.Renderer.MeshFragGlobalIlluminationTypeName+'msaa_'+fInstance.Renderer.MeshFragShadowTypeName+'_'+OITVariant+'_dfaoit_alphatest_frag.spv');
  end;
 end;
 try
  fMeshMaskedFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
//fFrameGraph.VulkanDevice.DebugMarker.SetObjectName(fMeshMaskedFragmentShaderModule.Handle,TVkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_SHADER_MODULE_EXT,'fMeshMaskedFragmentShaderModule');
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageMeshVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fMeshVertexShaderModule,'main');

 fVulkanPipelineShaderStageMeshFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fMeshFragmentShaderModule,'main');
 MeshFragmentSpecializationConstants.SetPipelineShaderStage(fVulkanPipelineShaderStageMeshFragment);

 fVulkanPipelineShaderStageMeshMaskedFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fMeshMaskedFragmentShaderModule,'main');
 MeshFragmentSpecializationConstants.SetPipelineShaderStage(fVulkanPipelineShaderStageMeshMaskedFragment);

 /// --

 if fInstance.Renderer.Scene3D.RaytracingActive then begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_vert.spv');
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_vert.spv');
 end;
 try
  fParticleVertexShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
//fFrameGraph.VulkanDevice.DebugMarker.SetObjectName(fParticleVertexShaderModule.Handle,TVkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_SHADER_MODULE_EXT,'fParticleVertexShaderModule');
 finally
  Stream.Free;
 end;

 case fInstance.Renderer.TransparencyMode of
  TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT:begin
   OITVariant:='spinlock';
  end;
  TpvScene3DRendererTransparencyMode.INTERLOCKDFAOIT:begin
   OITVariant:='interlock';
  end;
  else begin
   Assert(false);
   OITVariant:='';
  end;
 end;

 if fInstance.Renderer.Scene3D.RaytracingActive then begin
  if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
   if fInstance.ZFar<0.0 then begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_reversedz_'+OITVariant+'_dfaoit_frag.spv');
   end else begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_'+OITVariant+'_dfaoit_frag.spv');
   end;
  end else begin
   if fInstance.ZFar<0.0 then begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_reversedz_msaa_'+OITVariant+'_dfaoit_frag.spv');
   end else begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_msaa_'+OITVariant+'_dfaoit_frag.spv');
   end;
  end;
 end else begin
  if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
   if fInstance.ZFar<0.0 then begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_reversedz_'+OITVariant+'_dfaoit_frag.spv');
   end else begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_'+OITVariant+'_dfaoit_frag.spv');
   end;
  end else begin
   if fInstance.ZFar<0.0 then begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_reversedz_msaa_'+OITVariant+'_dfaoit_frag.spv');
   end else begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_msaa_'+OITVariant+'_dfaoit_frag.spv');
   end;
  end;
 end;
 try
  fParticleFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
//fFrameGraph.VulkanDevice.DebugMarker.SetObjectName(fParticleFragmentShaderModule.Handle,TVkDebugReportObjectTypeEXT.VK_DEBUG_REPORT_OBJECT_TYPE_SHADER_MODULE_EXT,'fParticleFragmentShaderModule');
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageParticleVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fParticleVertexShaderModule,'main');

 fVulkanPipelineShaderStageParticleFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fParticleFragmentShaderModule,'main');
//ParticleFragmentSpecializationConstants.SetPipelineShaderStage(fVulkanPipelineShaderStageParticleFragment);

end;

procedure TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyRenderPass.ReleasePersistentResources;
begin

 FreeAndNil(fVulkanPipelineShaderStageMeshVertex);

 FreeAndNil(fVulkanPipelineShaderStageMeshFragment);

 FreeAndNil(fVulkanPipelineShaderStageMeshMaskedFragment);

 FreeAndNil(fMeshVertexShaderModule);

 FreeAndNil(fMeshFragmentShaderModule);

 FreeAndNil(fMeshMaskedFragmentShaderModule);

 FreeAndNil(fVulkanPipelineShaderStageParticleVertex);

 FreeAndNil(fVulkanPipelineShaderStageParticleFragment);

 FreeAndNil(fParticleVertexShaderModule);

 FreeAndNil(fParticleFragmentShaderModule);

 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyRenderPass.AcquireVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
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
                                             3,
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
 fPassVulkanDescriptorSetLayout.AddBinding(9,
                                             VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(10,
                                             VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(11,
                                             VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(12,
                                             VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(13,
                                             VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 case fInstance.Renderer.TransparencyMode of
  TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT:begin
   fPassVulkanDescriptorSetLayout.AddBinding(14,
                                               VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                               1,
                                               TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                               []);
  end;
  TpvScene3DRendererTransparencyMode.INTERLOCKDFAOIT:begin
  end;
  else begin
  end;
 end;
 fPassVulkanDescriptorSetLayout.Initialize;

 fPassVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,13*fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT,fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,4*fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,2*fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,5*fInstance.Renderer.CountInFlightFrames);
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
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(10,
                                                                       0,
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                       [fInstance.DeepAndFastApproximateOrderIndependentTransparencyFragmentCounterFragmentDepthsSampleMaskImage.DescriptorImageInfo],
                                                                       [],
                                                                       [],
                                                                       false);
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(11,
                                                                       0,
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                       [fInstance.DeepAndFastApproximateOrderIndependentTransparencyAccumulationImage.DescriptorImageInfo],
                                                                       [],
                                                                       [],
                                                                       false);
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(12,
                                                                       0,
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                       [fInstance.DeepAndFastApproximateOrderIndependentTransparencyAverageImage.DescriptorImageInfo],
                                                                       [],
                                                                       [],
                                                                       false);
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(13,
                                                                       0,
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                       [fInstance.DeepAndFastApproximateOrderIndependentTransparencyBucketImage.DescriptorImageInfo],
                                                                       [],
                                                                       [],
                                                                       false);
  case fInstance.Renderer.TransparencyMode of
   TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT:begin
    fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(14,
                                                                         0,
                                                                         1,
                                                                         TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                         [fInstance.DeepAndFastApproximateOrderIndependentTransparencySpinLockImage.DescriptorImageInfo],
                                                                         [],
                                                                         [],
                                                                         false);
   end;
   TpvScene3DRendererTransparencyMode.INTERLOCKDFAOIT:begin
   end;
   else begin
   end;
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

 for AlphaMode:=Low(TpvScene3D.TMaterial.TAlphaMode) to High(TpvScene3D.TMaterial.TAlphaMode) do begin
  for PrimitiveTopology:=Low(TpvScene3D.TPrimitiveTopology) to High(TpvScene3D.TPrimitiveTopology) do begin
   for FaceCullingMode:=Low(TpvScene3D.TFaceCullingMode) to High(TpvScene3D.TFaceCullingMode) do begin
    FreeAndNil(fVulkanGraphicsPipelines[AlphaMode,PrimitiveTopology,FaceCullingMode]);
   end;
  end;
 end;

 for AlphaMode:=Low(TpvScene3D.TMaterial.TAlphaMode) to High(TpvScene3D.TMaterial.TAlphaMode) do begin

  if AlphaMode=TpvScene3D.TMaterial.TAlphaMode.Opaque then begin
   continue;
  end;

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
     if AlphaMode=TpvScene3D.TMaterial.TAlphaMode.Mask then begin
      VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshMaskedFragment);
     end else begin
      VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshFragment);
     end;

     VulkanGraphicsPipeline.InputAssemblyState.Topology:=TpvScene3D.VulkanPrimitiveTopologies[PrimitiveTopology];
     VulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

     fInstance.Renderer.Scene3D.InitializeGraphicsPipeline(VulkanGraphicsPipeline);

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
     if (AlphaMode=TpvScene3D.TMaterial.TAlphaMode.Mask) and (VulkanGraphicsPipeline.MultisampleState.RasterizationSamples<>VK_SAMPLE_COUNT_1_BIT) then begin
      VulkanGraphicsPipeline.MultisampleState.SampleShadingEnable:=true;
      VulkanGraphicsPipeline.MultisampleState.MinSampleShading:=1.0;
      VulkanGraphicsPipeline.MultisampleState.CountSampleMasks:=0;
      VulkanGraphicsPipeline.MultisampleState.AlphaToCoverageEnable:=true;
      VulkanGraphicsPipeline.MultisampleState.AlphaToOneEnable:=false;
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
     VulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(true,
                                                                         VK_BLEND_FACTOR_ONE,
                                                                         VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                         VK_BLEND_OP_ADD,
                                                                         VK_BLEND_FACTOR_ONE,
                                                                         VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                         VK_BLEND_OP_ADD,
                                                                         TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                         TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                         TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                         TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));

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
     fVulkanGraphicsPipelines[AlphaMode,PrimitiveTopology,FaceCullingMode]:=VulkanGraphicsPipeline;
    end;

   end;

  end;

 end;

 FreeAndNil(fVulkanParticleGraphicsPipeline);

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

  VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageParticleVertex);
  VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageParticleFragment);

  VulkanGraphicsPipeline.InputAssemblyState.Topology:=VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
  VulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

  fInstance.Renderer.Scene3D.InitializeParticleGraphicsPipeline(VulkanGraphicsPipeline);

  VulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,fInstance.Width,fInstance.Height,0.0,1.0);
  VulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,fInstance.Width,fInstance.Height);

  VulkanGraphicsPipeline.RasterizationState.DepthClampEnable:=false;
  VulkanGraphicsPipeline.RasterizationState.RasterizerDiscardEnable:=false;
  VulkanGraphicsPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
{ VulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_BACK_BIT);
  VulkanGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_COUNTER_CLOCKWISE;}
  VulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_NONE);
  VulkanGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_COUNTER_CLOCKWISE;
  VulkanGraphicsPipeline.RasterizationState.DepthBiasEnable:=false;
  VulkanGraphicsPipeline.RasterizationState.DepthBiasConstantFactor:=0.0;
  VulkanGraphicsPipeline.RasterizationState.DepthBiasClamp:=0.0;
  VulkanGraphicsPipeline.RasterizationState.DepthBiasSlopeFactor:=0.0;
  VulkanGraphicsPipeline.RasterizationState.LineWidth:=1.0;

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
                                                                      VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                      VK_BLEND_OP_ADD,
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));

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
  fVulkanParticleGraphicsPipeline:=VulkanGraphicsPipeline;
 end;

end;

procedure TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyRenderPass.ReleaseVolatileResources;
var Index:TpvSizeInt;
    AlphaMode:TpvScene3D.TMaterial.TAlphaMode;
    PrimitiveTopology:TpvScene3D.TPrimitiveTopology;
    FaceCullingMode:TpvScene3D.TFaceCullingMode;
begin
 FreeAndNil(fVulkanParticleGraphicsPipeline);
 for AlphaMode:=Low(TpvScene3D.TMaterial.TAlphaMode) to High(TpvScene3D.TMaterial.TAlphaMode) do begin
  for PrimitiveTopology:=Low(TpvScene3D.TPrimitiveTopology) to High(TpvScene3D.TPrimitiveTopology) do begin
   for FaceCullingMode:=Low(TpvScene3D.TFaceCullingMode) to High(TpvScene3D.TFaceCullingMode) do begin
    FreeAndNil(fVulkanGraphicsPipelines[AlphaMode,PrimitiveTopology,FaceCullingMode]);
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

procedure TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyRenderPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyRenderPass.OnSetRenderPassResources(const aCommandBuffer:TpvVulkanCommandBuffer;
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

procedure TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyRenderPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;
                                                                          const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameState:TpvScene3DRendererInstance.PInFlightFrameState;
begin
 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 InFlightFrameState:=@fInstance.InFlightFrameStates^[aInFlightFrameIndex];

 if InFlightFrameState^.Ready then begin

  fOnSetRenderPassResourcesDone:=false;

  fIBLDescriptors[aInFlightFrameIndex].SetFrom(fInstance.Renderer.Scene3D,fInstance,aInFlightFrameIndex);
  fIBLDescriptors[aInFlightFrameIndex].Update(true);

  if fInstance.Renderer.UseOITAlphaTest or fInstance.Renderer.Scene3D.HasTransmission then begin
   fInstance.Renderer.Scene3D.Draw(fInstance,
                                   fVulkanGraphicsPipelines[TpvScene3D.TMaterial.TAlphaMode.Mask],
                                   -1,
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

  fInstance.Renderer.Scene3D.Draw(fInstance,
                                  fVulkanGraphicsPipelines[TpvScene3D.TMaterial.TAlphaMode.Blend],
                                  -1,
                                  aInFlightFrameIndex,
                                  TpvScene3DRendererRenderPass.View,
                                  InFlightFrameState^.FinalViewIndex,
                                  InFlightFrameState^.CountFinalViews,
                                  FrameGraph.DrawFrameIndex,
                                  aCommandBuffer,
                                  fVulkanPipelineLayout,
                                  OnSetRenderPassResources,
                                  [TpvScene3D.TMaterial.TAlphaMode.Blend],
                                  @InFlightFrameState^.Jitter);

  fInstance.Renderer.Scene3D.DrawParticles(fInstance,
                                           fVulkanParticleGraphicsPipeline,
                                           -1,
                                           aInFlightFrameIndex,
                                           TpvScene3DRendererRenderPass.View,
                                           InFlightFrameState^.FinalViewIndex,
                                           InFlightFrameState^.CountFinalViews,
                                           FrameGraph.DrawFrameIndex,
                                           aCommandBuffer,
                                           fVulkanPipelineLayout,
                                           OnSetRenderPassResources);

 end;

end;

end.
