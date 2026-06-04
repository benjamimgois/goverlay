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
unit PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass;
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

type { TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass }
     TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass=class(TpvFrameGraph.TRenderPass)
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
       fResourceColor:TpvFrameGraph.TPass.TUsedImageResource;
       fMeshVertexShaderModule:TpvVulkanShaderModule;
       fMeshGeometryShaderModule:TpvVulkanShaderModule;
       fMeshFragmentShaderModule:TpvVulkanShaderModule;
       fPassVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fPassVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fPassVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fVulkanPipelineShaderStageMeshVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshGeometry:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshFragment:TpvVulkanPipelineShaderStage;
       fVulkanGraphicsPipelines:TpvScene3D.TGraphicsPipelines;
       fVulkanPipelineLayout:TpvVulkanPipelineLayout;
       fParticleVertexShaderModule:TpvVulkanShaderModule;
       fParticleGeometryShaderModule:TpvVulkanShaderModule;
       fParticleFragmentShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageParticleVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageParticleGeometry:TpvVulkanPipelineShaderStage;
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

{ TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass }

constructor TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='GlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass';

 MultiviewMask:=0;

 Queue:=aFrameGraph.UniversalQueue;

 Size:=TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,
                                       fInstance.Renderer.GlobalIlluminationVoxelGridSize,
                                       fInstance.Renderer.GlobalIlluminationVoxelGridSize,
                                       1.0,
                                       0);

 fResourceCascadedShadowMap:=AddImageInput('resourcetype_cascadedshadowmap_data',
                                           'resource_cascadedshadowmap_data_final',
                                           VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                           []
                                          );

 fResourceColor:=AddImageOutput('resourcetype_voxelization',
                                'resource_voxelization',
                                VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                             TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0)),
                                [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                               );

end;

destructor TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass.AcquirePersistentResources;
var Index:TpvSizeInt;
    Stream:TStream;
begin
 inherited AcquirePersistentResources;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_voxelization_vert.spv');
 try
  fMeshVertexShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 case fInstance.Renderer.GlobalIlluminationVoxelCountCascades of
  1:begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_voxelization_1_geom.spv');
  end;
  2:begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_voxelization_2_geom.spv');
  end;
  3:begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_voxelization_3_geom.spv');
  end;
  4:begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_voxelization_4_geom.spv');
  end;
  5:begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_voxelization_5_geom.spv');
  end;
  6:begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_voxelization_6_geom.spv');
  end;
  7:begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_voxelization_7_geom.spv');
  end;
  else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_voxelization_8_geom.spv');
  end;
 end;
 try
  fMeshGeometryShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'_voxelization_frag.spv');
 try
  fMeshFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageMeshVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fMeshVertexShaderModule,'main');

 fVulkanPipelineShaderStageMeshGeometry:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_GEOMETRY_BIT,fMeshGeometryShaderModule,'main');

 fVulkanPipelineShaderStageMeshFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fMeshFragmentShaderModule,'main');

 /// --

 if fInstance.Renderer.Scene3D.RaytracingActive then begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_voxelization_vert.spv');
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_voxelization_vert.spv');
 end;
 try
  fParticleVertexShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
  FrameGraph.VulkanDevice.DebugUtils.SetObjectName(fParticleVertexShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'fParticleVertexShaderModule');
 finally
  Stream.Free;
 end;

{if fInstance.Renderer.Scene3D.RaytracingActive then begin
  case fInstance.Renderer.GlobalIlluminationVoxelCountCascades of
   1:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_voxelization_1_geom.spv');
   end;
   2:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_voxelization_2_geom.spv');
   end;
   3:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_voxelization_3_geom.spv');
   end;
   4:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_voxelization_4_geom.spv');
   end;
   5:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_voxelization_5_geom.spv');
   end;
   6:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_voxelization_6_geom.spv');
   end;
   7:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_voxelization_7_geom.spv');
   end;
   else begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_voxelization_8_geom.spv');
   end;
  end;
 end else}begin
  case fInstance.Renderer.GlobalIlluminationVoxelCountCascades of
   1:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_voxelization_1_geom.spv');
   end;
   2:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_voxelization_2_geom.spv');
   end;
   3:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_voxelization_3_geom.spv');
   end;
   4:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_voxelization_4_geom.spv');
   end;
   5:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_voxelization_5_geom.spv');
   end;
   6:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_voxelization_6_geom.spv');
   end;
   7:begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_voxelization_7_geom.spv');
   end;
   else begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_voxelization_8_geom.spv');
   end;
  end;
 end;
 try
  fParticleGeometryShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
  FrameGraph.VulkanDevice.DebugUtils.SetObjectName(fParticleGeometryShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'fParticleGeometryShaderModule');
 finally
  Stream.Free;
 end;

 if fInstance.Renderer.Scene3D.RaytracingActive then begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_raytracing_voxelization_frag.spv');
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('particle_voxelization_frag.spv');
 end;
 try
  fParticleFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
  FrameGraph.VulkanDevice.DebugUtils.SetObjectName(fParticleFragmentShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'fParticleFragmentShaderModule');
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageParticleVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fParticleVertexShaderModule,'main');

 fVulkanPipelineShaderStageParticleGeometry:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_GEOMETRY_BIT,fParticleGeometryShaderModule,'main');

 fVulkanPipelineShaderStageParticleFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fParticleFragmentShaderModule,'main');
//ParticleFragmentSpecializationConstants.SetPipelineShaderStage(fVulkanPipelineShaderStageParticleFragment);

end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass.ReleasePersistentResources;
begin

 FreeAndNil(fVulkanPipelineShaderStageMeshVertex);

 FreeAndNil(fVulkanPipelineShaderStageMeshGeometry);

 FreeAndNil(fVulkanPipelineShaderStageMeshFragment);

 FreeAndNil(fMeshVertexShaderModule);

 FreeAndNil(fMeshGeometryShaderModule);

 FreeAndNil(fMeshFragmentShaderModule);

 FreeAndNil(fVulkanPipelineShaderStageParticleVertex);

 FreeAndNil(fVulkanPipelineShaderStageParticleGeometry);

 FreeAndNil(fVulkanPipelineShaderStageParticleFragment);

 FreeAndNil(fParticleVertexShaderModule);

 FreeAndNil(fParticleGeometryShaderModule);

 FreeAndNil(fParticleFragmentShaderModule);

 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass.AcquireVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
    PrimitiveTopology:TpvScene3D.TPrimitiveTopology;
    FaceCullingMode:TpvScene3D.TFaceCullingMode;
    VulkanGraphicsPipeline:TpvVulkanGraphicsPipeline;
    PipelineRasterizationConservativeStateCreateInfoEXT:TVkPipelineRasterizationConservativeStateCreateInfoEXT;
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
                                             VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_GEOMETRY_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(2,
                                             VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_GEOMETRY_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.AddBinding(3,
                                             VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_GEOMETRY_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                             []);
 fPassVulkanDescriptorSetLayout.Initialize;

 fPassVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,2*fInstance.Renderer.CountInFlightFrames);
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
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                       [],
                                                                       [fInstance.GlobalIlluminationCascadedVoxelConeTracingUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                       [],
                                                                       false);
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                       0,
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                       [],
                                                                       [fInstance.GlobalIlluminationCascadedVoxelConeTracingContentDataBuffer.DescriptorBufferInfo],
                                                                       [],
                                                                       false);
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                       0,
                                                                       1,
                                                                       TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                       [],
                                                                       [fInstance.GlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffer.DescriptorBufferInfo],
                                                                       [],
                                                                       false);
  fPassVulkanDescriptorSets[InFlightFrameIndex].Flush;
 end;

 fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),0,SizeOf(TpvScene3D.TMeshStagePushConstants));
 fVulkanPipelineLayout.AddDescriptorSetLayout(fInstance.Renderer.Scene3D.GlobalVulkanDescriptorSetLayout);
 fVulkanPipelineLayout.AddDescriptorSetLayout(fPassVulkanDescriptorSetLayout);
 fVulkanPipelineLayout.Initialize;

 for PrimitiveTopology:=Low(TpvScene3D.TPrimitiveTopology) to High(TpvScene3D.TPrimitiveTopology) do begin
  for FaceCullingMode:=Low(TpvScene3D.TFaceCullingMode) to High(TpvScene3D.TFaceCullingMode) do begin
   FreeAndNil(fVulkanGraphicsPipelines[PrimitiveTopology,FaceCullingMode]);
  end;
 end;

 PrimitiveTopology:=TpvScene3D.TPrimitiveTopology.Triangles;
 begin

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

    if assigned(fInstance.Renderer.VulkanDevice.PhysicalDevice.ConservativeRasterizationPropertiesEXT.pNext) then begin
     FillChar(PipelineRasterizationConservativeStateCreateInfoEXT,SizeOf(TVkPipelineRasterizationConservativeStateCreateInfoEXT),#0);
     PipelineRasterizationConservativeStateCreateInfoEXT.sType:=VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_CONSERVATIVE_STATE_CREATE_INFO_EXT;
     PipelineRasterizationConservativeStateCreateInfoEXT.flags:=0;
     PipelineRasterizationConservativeStateCreateInfoEXT.conservativeRasterizationMode:=VK_CONSERVATIVE_RASTERIZATION_MODE_OVERESTIMATE_EXT;
     PipelineRasterizationConservativeStateCreateInfoEXT.extraPrimitiveOverestimationSize:=Min(0.75,fInstance.Renderer.VulkanDevice.PhysicalDevice.ConservativeRasterizationPropertiesEXT.maxExtraPrimitiveOverestimationSize);
     VulkanGraphicsPipeline.RasterizationState.SetPipelineRasterizationConservativeStateCreateInfoEXT(PipelineRasterizationConservativeStateCreateInfoEXT);
    end;

    VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshVertex);
    VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshGeometry);
    VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshFragment);

    VulkanGraphicsPipeline.InputAssemblyState.Topology:=TpvScene3D.VulkanPrimitiveTopologies[PrimitiveTopology];
    VulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

    fInstance.Renderer.Scene3D.InitializeGraphicsPipeline(VulkanGraphicsPipeline);

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
    VulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                        VK_BLEND_FACTOR_ZERO,
                                                                        VK_BLEND_FACTOR_ZERO,
                                                                        VK_BLEND_OP_ADD,
                                                                        VK_BLEND_FACTOR_ZERO,
                                                                        VK_BLEND_FACTOR_ZERO,
                                                                        VK_BLEND_OP_ADD,
                                                                        0{TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                        TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                        TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                        TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT)});

    VulkanGraphicsPipeline.DepthStencilState.DepthTestEnable:=false;
    VulkanGraphicsPipeline.DepthStencilState.DepthWriteEnable:=false;
    VulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_LESS_OR_EQUAL;
    VulkanGraphicsPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
    VulkanGraphicsPipeline.DepthStencilState.StencilTestEnable:=false;

    VulkanGraphicsPipeline.Initialize;

    VulkanGraphicsPipeline.FreeMemory;

   finally
    fVulkanGraphicsPipelines[PrimitiveTopology,FaceCullingMode]:=VulkanGraphicsPipeline;
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

  VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageParticleVertex);
  VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageParticleGeometry);
  VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageParticleFragment);

  VulkanGraphicsPipeline.InputAssemblyState.Topology:=VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
  VulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

  fInstance.Renderer.Scene3D.InitializeParticleGraphicsPipeline(VulkanGraphicsPipeline);

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
  VulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_LESS_OR_EQUAL;
  VulkanGraphicsPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
  VulkanGraphicsPipeline.DepthStencilState.StencilTestEnable:=false;

  VulkanGraphicsPipeline.Initialize;

  VulkanGraphicsPipeline.FreeMemory;

 finally
  fVulkanParticleGraphicsPipeline:=VulkanGraphicsPipeline;
 end;

end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass.ReleaseVolatileResources;
var Index:TpvSizeInt;
    PrimitiveTopology:TpvScene3D.TPrimitiveTopology;
    FaceCullingMode:TpvScene3D.TFaceCullingMode;
begin
 FreeAndNil(fVulkanParticleGraphicsPipeline);
 for PrimitiveTopology:=Low(TpvScene3D.TPrimitiveTopology) to High(TpvScene3D.TPrimitiveTopology) do begin
  for FaceCullingMode:=Low(TpvScene3D.TFaceCullingMode) to High(TpvScene3D.TFaceCullingMode) do begin
   FreeAndNil(fVulkanGraphicsPipelines[PrimitiveTopology,FaceCullingMode]);
  end;
 end;
 FreeAndNil(fVulkanPipelineLayout);
 for Index:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fPassVulkanDescriptorSets[Index]);
 end;
 FreeAndNil(fPassVulkanDescriptorPool);
 FreeAndNil(fPassVulkanDescriptorSetLayout);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass.OnSetRenderPassResources(const aCommandBuffer:TpvVulkanCommandBuffer;
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

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;
                                                                                                               const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameState:TpvScene3DRendererInstance.PInFlightFrameState;
begin
 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 InFlightFrameState:=@fInstance.InFlightFrameStates^[aInFlightFrameIndex];

 if InFlightFrameState^.Ready then begin

  fOnSetRenderPassResourcesDone:=false;

  fInstance.Renderer.Scene3D.Draw(fInstance,
                                  fVulkanGraphicsPipelines,
                                  -1,
                                  aInFlightFrameIndex,
                                  TpvScene3DRendererRenderPass.Voxelization,
                                  InFlightFrameState^.FinalViewIndex,
                                  Min(1,InFlightFrameState^.CountFinalViews),
                                  FrameGraph.DrawFrameIndex,
                                  aCommandBuffer,
                                  fVulkanPipelineLayout,
                                  OnSetRenderPassResources,
                                  [TpvScene3D.TMaterial.TAlphaMode.Opaque,
                                   TpvScene3D.TMaterial.TAlphaMode.Mask,
                                   TpvScene3D.TMaterial.TAlphaMode.Blend]);

  fInstance.Renderer.Scene3D.DrawParticles(fInstance,
                                           fVulkanParticleGraphicsPipeline,
                                           -1,
                                           aInFlightFrameIndex,
                                           TpvScene3DRendererRenderPass.Voxelization,
                                           InFlightFrameState^.FinalViewIndex,
                                           Min(1,InFlightFrameState^.CountFinalViews),
                                           FrameGraph.DrawFrameIndex,
                                           aCommandBuffer,
                                           fVulkanPipelineLayout,
                                           OnSetRenderPassResources);

 end;

end;

end.
