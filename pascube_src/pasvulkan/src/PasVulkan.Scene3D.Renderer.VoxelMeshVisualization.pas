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
unit PasVulkan.Scene3D.Renderer.VoxelMeshVisualization;
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
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Scene3D,
     PasVulkan.Scene3D.Renderer.Globals,
     PasVulkan.Scene3D.Renderer,
     PasVulkan.Scene3D.Renderer.Instance;

type { TpvScene3DRendererVoxelMeshVisualization }
     TpvScene3DRendererVoxelMeshVisualization=class
      public
       type TPushConstants=record
             ViewBaseIndex:TpvUInt32;
             CountViews:TpvUInt32;
             GridSizeBits:TpvUInt32;
             CascadeIndex:TpvUInt32;
            end;
      private
       fInstance:TpvScene3DRendererInstance;
       fRenderer:TpvScene3DRenderer;
       fScene3D:TpvScene3D;
       fMeshShader:Boolean; // MeshShaders -> mesh-shader path (one workgroup per voxel, GPU-side empty cull) instead of the vertex-instanced cubes
       fVertexShaderModule:TpvVulkanShaderModule;
       fMeshShaderModule:TpvVulkanShaderModule;
       //fGeometryShaderModule:TpvVulkanShaderModule;
       fFragmentShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMesh:TpvVulkanPipelineShaderStage;
       //fVulkanPipelineShaderStageGeometry:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageFragment:TpvVulkanPipelineShaderStage;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fVulkanPipelineLayout:TpvVulkanPipelineLayout;
       fVulkanPipeline:TpvVulkanGraphicsPipeline;
      public

       constructor Create(const aInstance:TpvScene3DRendererInstance;const aRenderer:TpvScene3DRenderer;const aScene3D:TpvScene3D);

       destructor Destroy; override;

       procedure AllocateResources(const aRenderPass:TpvVulkanRenderPass;
                                   const aWidth:TpvInt32;
                                   const aHeight:TpvInt32;
                                   const aVulkanSampleCountFlagBits:TVkSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT));

       procedure ReleaseResources;

       procedure Draw(const aInFlightFrameIndex,aViewBaseIndex,aCountViews:TpvSizeInt;const aCommandBuffer:TpvVulkanCommandBuffer);

     end;

implementation

{ TpvScene3DRendererVoxelMeshVisualization }

constructor TpvScene3DRendererVoxelMeshVisualization.Create(const aInstance:TpvScene3DRendererInstance;const aRenderer:TpvScene3DRenderer;const aScene3D:TpvScene3D);
var Index:TpvSizeInt;
    Stream:TStream;
    PrimaryStageFlags:TVkShaderStageFlags; // VERTEX or (mesh-shader path) MESH: the stage that consumes the view UBO + push constants
begin
 inherited Create;

 fInstance:=aInstance;

 fRenderer:=aRenderer;

 fScene3D:=aScene3D;

 fMeshShader:=fScene3D.MeshShaders;

 if fMeshShader then begin
  PrimaryStageFlags:=TVkShaderStageFlags(VK_SHADER_STAGE_MESH_BIT_EXT);
 end else begin
  PrimaryStageFlags:=TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT);
 end;

 if fMeshShader then begin
  // Mesh-shader path: one workgroup per voxel (3D dispatch), emits a cube only for non-empty voxels.
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('voxel_mesh_visualization_mesh.spv');
  try
   fMeshShaderModule:=TpvVulkanShaderModule.Create(fRenderer.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
  fVulkanPipelineShaderStageMesh:=TpvVulkanPipelineShaderStage.Create(TVkShaderStageFlagBits(VK_SHADER_STAGE_MESH_BIT_EXT),fMeshShaderModule,'main');
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('voxel_mesh_visualization_vert.spv');
  try
   fVertexShaderModule:=TpvVulkanShaderModule.Create(fRenderer.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
  fVulkanPipelineShaderStageVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fVertexShaderModule,'main');
 end;

{Stream:=pvScene3DShaderVirtualFileSystem.GetFile('voxel_mesh_visualization_geom.spv');
 try
  fGeometryShaderModule:=TpvVulkanShaderModule.Create(fRenderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;}

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('voxel_mesh_visualization_frag.spv');
 try
  fFragmentShaderModule:=TpvVulkanShaderModule.Create(fRenderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

//fVulkanPipelineShaderStageGeometry:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_GEOMETRY_BIT,fGeometryShaderModule,'main');

 fVulkanPipelineShaderStageFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fFragmentShaderModule,'main');

 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fRenderer.VulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0,
                                       VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                       1,
                                       PrimaryStageFlags,
                                       []);
 // binding 1 = voxel content meta-data SSBO, binding 2 = voxel content data SSBO. Always bound so the layout matches whether
 // or not the shader is the VOXEL_MESH_VIS_RAW_CONTENT diagnostic variant (extra bindings unused by the normal variant are valid).
 fVulkanDescriptorSetLayout.AddBinding(1,
                                       VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(2,
                                       VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT),
                                       []);
 fVulkanDescriptorSetLayout.Initialize;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fRenderer.VulkanDevice,TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),fScene3D.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,fScene3D.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,fScene3D.CountInFlightFrames*2);
 fVulkanDescriptorPool.Initialize;

 for Index:=0 to fScene3D.CountInFlightFrames-1 do begin
  fVulkanDescriptorSets[Index]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                              fVulkanDescriptorSetLayout);
  fVulkanDescriptorSets[Index].WriteToDescriptorSet(0,
                                                    0,
                                                    1,
                                                    TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                    [],
                                                    [fInstance.VulkanViewUniformBuffers[Index].DescriptorBufferInfo],
                                                    [],
                                                    false);
  fVulkanDescriptorSets[Index].WriteToDescriptorSet(1,
                                                    0,
                                                    1,
                                                    TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                    [],
                                                    [fInstance.GlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers[Index].DescriptorBufferInfo],
                                                    [],
                                                    false);
  fVulkanDescriptorSets[Index].WriteToDescriptorSet(2,
                                                    0,
                                                    1,
                                                    TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                    [],
                                                    [fInstance.GlobalIlluminationCascadedVoxelConeTracingContentDataBuffers[Index].DescriptorBufferInfo],
                                                    [],
                                                    false);
  fVulkanDescriptorSets[Index].Flush;
 end;

 fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(fRenderer.VulkanDevice);
 fVulkanPipelineLayout.AddPushConstantRange(PrimaryStageFlags,0,SizeOf(TpvScene3DRendererVoxelMeshVisualization.TPushConstants));
 fVulkanPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 fVulkanPipelineLayout.AddDescriptorSetLayout(fInstance.GlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout);
 fVulkanPipelineLayout.Initialize;

end;

destructor TpvScene3DRendererVoxelMeshVisualization.Destroy;
var Index:TpvSizeInt;
begin
 FreeAndNil(fVulkanPipelineLayout);
 for Index:=0 to fScene3D.CountInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[Index]);
 end;
 FreeAndNil(fVulkanDescriptorPool);
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanPipelineShaderStageVertex);
 FreeAndNil(fVulkanPipelineShaderStageMesh);
//FreeAndNil(fVulkanPipelineShaderStageGeometry);
 FreeAndNil(fVulkanPipelineShaderStageFragment);
 FreeAndNil(fVertexShaderModule);
 FreeAndNil(fMeshShaderModule);
//FreeAndNil(fGeometryShaderModule);
 FreeAndNil(fFragmentShaderModule);
 inherited Destroy;
end;

procedure TpvScene3DRendererVoxelMeshVisualization.AllocateResources(const aRenderPass:TpvVulkanRenderPass;
                                                                     const aWidth:TpvInt32;
                                                                     const aHeight:TpvInt32;
                                                                     const aVulkanSampleCountFlagBits:TVkSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT));
begin

 fVulkanPipeline:=TpvVulkanGraphicsPipeline.Create(fRenderer.VulkanDevice,
                                                   fRenderer.VulkanPipelineCache,
                                                   0,
                                                   [],
                                                   fVulkanPipelineLayout,
                                                   aRenderPass,
                                                   0,
                                                   nil,
                                                   0);

 if fMeshShader then begin
  fVulkanPipeline.AddStage(fVulkanPipelineShaderStageMesh);
 end else begin
  fVulkanPipeline.AddStage(fVulkanPipelineShaderStageVertex);
 end;
//fVulkanPipeline.AddStage(fVulkanPipelineShaderStageGeometry);
 fVulkanPipeline.AddStage(fVulkanPipelineShaderStageFragment);

 fVulkanPipeline.InputAssemblyState.Topology:=TVkPrimitiveTopology(VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST);
 fVulkanPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

 fVulkanPipeline.ViewPortState.AddViewPort(0.0,0.0,aWidth,aHeight,0.0,1.0);
 fVulkanPipeline.ViewPortState.AddScissor(0,0,aWidth,aHeight);

 fVulkanPipeline.RasterizationState.DepthClampEnable:=false;
 fVulkanPipeline.RasterizationState.RasterizerDiscardEnable:=false;
 fVulkanPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
 fVulkanPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_NONE);
 fVulkanPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_CLOCKWISE;
 fVulkanPipeline.RasterizationState.DepthBiasEnable:=false;
 fVulkanPipeline.RasterizationState.DepthBiasConstantFactor:=0.0;
 fVulkanPipeline.RasterizationState.DepthBiasClamp:=0.0;
 fVulkanPipeline.RasterizationState.DepthBiasSlopeFactor:=0.0;
 fVulkanPipeline.RasterizationState.LineWidth:=1.0;

 fVulkanPipeline.MultisampleState.RasterizationSamples:=aVulkanSampleCountFlagBits;
 fVulkanPipeline.MultisampleState.SampleShadingEnable:=false;
 fVulkanPipeline.MultisampleState.MinSampleShading:=0.0;
 fVulkanPipeline.MultisampleState.CountSampleMasks:=0;
 fVulkanPipeline.MultisampleState.AlphaToCoverageEnable:=false;
 fVulkanPipeline.MultisampleState.AlphaToOneEnable:=false;

 fVulkanPipeline.ColorBlendState.LogicOpEnable:=false;
 fVulkanPipeline.ColorBlendState.LogicOp:=VK_LOGIC_OP_COPY;
 fVulkanPipeline.ColorBlendState.BlendConstants[0]:=0.0;
 fVulkanPipeline.ColorBlendState.BlendConstants[1]:=0.0;
 fVulkanPipeline.ColorBlendState.BlendConstants[2]:=0.0;
 fVulkanPipeline.ColorBlendState.BlendConstants[3]:=0.0;
 fVulkanPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
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
 if fInstance.Renderer.VelocityBufferNeeded then begin
  fVulkanPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                               VK_BLEND_FACTOR_ZERO,
                                                               VK_BLEND_FACTOR_ZERO,
                                                               VK_BLEND_OP_ADD,
                                                               VK_BLEND_FACTOR_ZERO,
                                                               VK_BLEND_FACTOR_ZERO,
                                                               VK_BLEND_OP_ADD,
                                                               0);
 end;


 fVulkanPipeline.DepthStencilState.DepthTestEnable:=true;
 fVulkanPipeline.DepthStencilState.DepthWriteEnable:=true;
 if fInstance.ZFar<0.0 then begin
  fVulkanPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_GREATER_OR_EQUAL;
 end else begin
  fVulkanPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_LESS_OR_EQUAL;
 end;
 fVulkanPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
 fVulkanPipeline.DepthStencilState.StencilTestEnable:=false;

 fVulkanPipeline.Initialize;

 fVulkanPipeline.FreeMemory;

end;

procedure TpvScene3DRendererVoxelMeshVisualization.ReleaseResources;
begin
 FreeAndNil(fVulkanPipeline);
end;

procedure TpvScene3DRendererVoxelMeshVisualization.Draw(const aInFlightFrameIndex,aViewBaseIndex,aCountViews:TpvSizeInt;const aCommandBuffer:TpvVulkanCommandBuffer);
var CascadeIndex:TpvInt32;
    PushConstants:TpvScene3DRendererVoxelMeshVisualization.TPushConstants;
    DescriptorSets:array[0..1] of TVkDescriptorSet;
    PushStageFlags:TVkShaderStageFlags;
begin

 if fMeshShader then begin
  PushStageFlags:=TVkShaderStageFlags(VK_SHADER_STAGE_MESH_BIT_EXT);
 end else begin
  PushStageFlags:=TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT);
 end;

 PushConstants.ViewBaseIndex:=aViewBaseIndex;
 PushConstants.CountViews:=aCountViews;
 PushConstants.GridSizeBits:=IntLog2(fInstance.Renderer.GlobalIlluminationVoxelGridSize);

 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanPipeline.Handle);

 DescriptorSets[0]:=fVulkanDescriptorSets[aInFlightFrameIndex].Handle;
 DescriptorSets[1]:=fInstance.GlobalIlluminationCascadedVoxelConeTracingDescriptorSets[aInFlightFrameIndex].Handle;
 aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                      fVulkanPipelineLayout.Handle,
                                      0,
                                      2,
                                      @DescriptorSets[0],
                                      0,
                                      nil);

 for CascadeIndex:=0 to fInstance.Renderer.GlobalIlluminationVoxelCountCascades-1 do begin
  PushConstants.CascadeIndex:=CascadeIndex;
  aCommandBuffer.CmdPushConstants(fVulkanPipelineLayout.Handle,
                                  PushStageFlags,
                                  0,
                                  SizeOf(TpvScene3DRendererVoxelMeshVisualization.TPushConstants),
                                  @PushConstants);
  if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
   fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.Draw,'VoxelMeshVisualization');
  end;
  if fMeshShader then begin
   // Mesh-shader path: one workgroup per voxel via a 3D dispatch (gl_WorkGroupID.xyz = voxel position). Avoids the per-dimension
   // workgroup-count limit a flat gridSize^3 dispatch would hit, and lets the mesh shader cull empty voxels (emit nothing).
   if assigned(fScene3D.VulkanDevice.Commands.Commands.CmdDrawMeshTasksEXT) then begin
    fScene3D.VulkanDevice.Commands.Commands.CmdDrawMeshTasksEXT(aCommandBuffer.Handle,
                                                               fInstance.Renderer.GlobalIlluminationVoxelGridSize,
                                                               fInstance.Renderer.GlobalIlluminationVoxelGridSize,
                                                               fInstance.Renderer.GlobalIlluminationVoxelGridSize);
   end;
  end else begin
   aCommandBuffer.CmdDraw(fInstance.Renderer.GlobalIlluminationVoxelGridSize*
                          fInstance.Renderer.GlobalIlluminationVoxelGridSize*
                          fInstance.Renderer.GlobalIlluminationVoxelGridSize*36,
                          1,
                          0,
                          0);
  end;
  if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
   fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
  end;
 end;

end;

end.
