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
unit PasVulkan.Scene3D.Renderer.Passes.CanvasRenderPass;
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

type { TpvScene3DRendererPassesCanvasRenderPass }
     TpvScene3DRendererPassesCanvasRenderPass=class(TpvFrameGraph.TRenderPass)
      public
       type TPushConstants=packed record
             ViewBaseIndex:TpvUInt32;
             CountViews:TpvUInt32;
             CountAllViews:TpvUInt32;
             Dummy:TpvUInt32;
             ViewPortSize:TpvVector2;
            end;
            PPushConstants=^TPushConstants;
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
       fResourceColor:TpvFrameGraph.TPass.TUsedImageResource;
       fGeometryShaderSupport:boolean;
       fDebugPrimitiveVertexShaderModule:TpvVulkanShaderModule;
       fDebugPrimitiveGeometryShaderModule:TpvVulkanShaderModule;
       fDebugPrimitiveFragmentShaderModule:TpvVulkanShaderModule;
       fSolidPrimitiveVertexShaderModule:TpvVulkanShaderModule;
       fSolidPrimitiveFragmentShaderModule:TpvVulkanShaderModule;
       fPassVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fPassVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fPassVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fVulkanPipelineShaderStageDebugPrimitiveVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageDebugPrimitiveGeometry:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageDebugPrimitiveFragment:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageSolidPrimitiveVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageSolidPrimitiveFragment:TpvVulkanPipelineShaderStage;
       fVulkanDebugPrimitiveGraphicsPipeline:TpvVulkanGraphicsPipeline;
       fVulkanSolidPrimitiveGraphicsPipeline:TpvVulkanGraphicsPipeline;
       fVulkanPipelineLayout:TpvVulkanPipelineLayout;
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

{ TpvScene3DRendererPassesCanvasRenderPass }

constructor TpvScene3DRendererPassesCanvasRenderPass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='CanvasRenderPass';

 MultiviewMask:=fInstance.SurfaceMultiviewMask;

 Queue:=aFrameGraph.UniversalQueue;

 Size:=TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,
                                       1.0,
                                       1.0,
                                       1.0,
                                       fInstance.CountSurfaceViews);

 fResourceColor:=AddImageInput('resourcetype_color_tonemapping',
                               'resource_tonemapping_color',
                               VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                               [TpvFrameGraph.TResourceTransition.TFlag.Attachment,
                                TpvFrameGraph.TResourceTransition.TFlag.ExplicitOutputAttachment]
                              );

 fGeometryShaderSupport:=fInstance.Renderer.VulkanDevice.PhysicalDevice.Features.GeometryShader<>VK_FALSE;

end;

destructor TpvScene3DRendererPassesCanvasRenderPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesCanvasRenderPass.AcquirePersistentResources;
var Index:TpvSizeInt;
    Stream:TStream;
    MeshFragmentSpecializationConstants:TpvScene3DRendererInstance.TMeshFragmentSpecializationConstants;
    VelocityVariant:TpvUTF8String;
begin
 inherited AcquirePersistentResources;

 MeshFragmentSpecializationConstants:=fInstance.MeshFragmentSpecializationConstants;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('debug_primitive_vert.spv');
 try
  fDebugPrimitiveVertexShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 if fGeometryShaderSupport then begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('debug_primitive_geom.spv');
  try
   fDebugPrimitiveGeometryShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
 end else begin
  fDebugPrimitiveGeometryShaderModule:=nil;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fDebugPrimitiveGeometryShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererPassesCanvasRenderPass.DebugPrimitiveGeometryShaderModule');

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('debug_primitive_frag.spv');
 try
  fDebugPrimitiveFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
  fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fDebugPrimitiveFragmentShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererPassesCanvasRenderPass.DebugPrimitiveFragmentShaderModule');

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('solid_primitive_vert.spv');
 try
  fSolidPrimitiveVertexShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fSolidPrimitiveVertexShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererPassesCanvasRenderPass.SolidPrimitiveVertexShaderModule');

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('solid_primitive_frag.spv');
 try
  fSolidPrimitiveFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fSolidPrimitiveFragmentShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererPassesCanvasRenderPass.SolidPrimitiveFragmentShaderModule');

 fVulkanPipelineShaderStageDebugPrimitiveVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fDebugPrimitiveVertexShaderModule,'main');

 if assigned(fDebugPrimitiveGeometryShaderModule) then begin
  fVulkanPipelineShaderStageDebugPrimitiveGeometry:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_GEOMETRY_BIT,fDebugPrimitiveGeometryShaderModule,'main');
 end else begin
  fVulkanPipelineShaderStageDebugPrimitiveGeometry:=nil;
 end; 

 fVulkanPipelineShaderStageDebugPrimitiveFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fDebugPrimitiveFragmentShaderModule,'main');

 fVulkanPipelineShaderStageSolidPrimitiveVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fSolidPrimitiveVertexShaderModule,'main');

 fVulkanPipelineShaderStageSolidPrimitiveFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fSolidPrimitiveFragmentShaderModule,'main');

end;

procedure TpvScene3DRendererPassesCanvasRenderPass.ReleasePersistentResources;
begin

 FreeAndNil(fVulkanPipelineShaderStageSolidPrimitiveVertex);

 FreeAndNil(fVulkanPipelineShaderStageSolidPrimitiveFragment);

 FreeAndNil(fVulkanPipelineShaderStageDebugPrimitiveVertex);

 FreeAndNil(fVulkanPipelineShaderStageDebugPrimitiveGeometry);

 FreeAndNil(fVulkanPipelineShaderStageDebugPrimitiveFragment);

 FreeAndNil(fSolidPrimitiveVertexShaderModule);

 FreeAndNil(fSolidPrimitiveFragmentShaderModule);

 FreeAndNil(fDebugPrimitiveVertexShaderModule);

 FreeAndNil(fDebugPrimitiveGeometryShaderModule);

 FreeAndNil(fDebugPrimitiveFragmentShaderModule);

 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesCanvasRenderPass.AcquireVolatileResources;
var InFlightFrameIndex,PipelineIndex:TpvSizeInt;
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
 fPassVulkanDescriptorSetLayout.Initialize;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fPassVulkanDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DRendererPassesCanvasRenderPass.DescriptorSetLayout');

 fPassVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,1*fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.Initialize;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fPassVulkanDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DRendererPassesCanvasRenderPass.DescriptorPool');

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
  fPassVulkanDescriptorSets[InFlightFrameIndex].Flush;
 end;

 fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT) or IfThen(fGeometryShaderSupport,TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_GEOMETRY_BIT),0),0,SizeOf(TPushConstants));
 fVulkanPipelineLayout.AddDescriptorSetLayout(fInstance.Renderer.Scene3D.GlobalVulkanDescriptorSetLayout);
 fVulkanPipelineLayout.AddDescriptorSetLayout(fPassVulkanDescriptorSetLayout);
 fVulkanPipelineLayout.Initialize;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fVulkanPipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DRendererPassesCanvasRenderPass.PipelineLayout');

 for PipelineIndex:=0 to 1 do begin

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

   if PipelineIndex=0 then begin
    VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageDebugPrimitiveVertex);
    if assigned(fVulkanPipelineShaderStageDebugPrimitiveGeometry) then begin
     VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageDebugPrimitiveGeometry);
    end;
    VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageDebugPrimitiveFragment);
   end else begin
    VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageSolidPrimitiveVertex);
    VulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageSolidPrimitiveFragment);
   end;

   if PipelineIndex=0 then begin
    VulkanGraphicsPipeline.InputAssemblyState.Topology:=TVkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_LINE_LIST;
   end else begin
    VulkanGraphicsPipeline.InputAssemblyState.Topology:=TVkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
   end;
   VulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

   if PipelineIndex=0 then begin
    fInstance.Renderer.Scene3D.InitializeDebugPrimitiveGraphicsPipeline(VulkanGraphicsPipeline);
   end else begin
    fInstance.InitializeSolidPrimitiveGraphicsPipeline(VulkanGraphicsPipeline);
   end;

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
   if (PipelineIndex=0) and not fGeometryShaderSupport then begin
    // Debug primitives uses no blending, since they are simply just native GPU lines, not anti-aliased 
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
   end else begin
    // Solid primitives uses additive blending with premultiplied alpha
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
   end;

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
   if PipelineIndex=0 then begin
    fVulkanDebugPrimitiveGraphicsPipeline:=VulkanGraphicsPipeline;
    fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(VulkanGraphicsPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DRendererPassesCanvasRenderPass.DebugPrimitiveGraphicsPipeline');
   end else begin
    fVulkanSolidPrimitiveGraphicsPipeline:=VulkanGraphicsPipeline;
    fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(VulkanGraphicsPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DRendererPassesCanvasRenderPass.SolidPrimitiveGraphicsPipeline');
   end;
  end;

 end;

end;

procedure TpvScene3DRendererPassesCanvasRenderPass.ReleaseVolatileResources;
var Index:TpvSizeInt;
begin
 FreeAndNil(fVulkanDebugPrimitiveGraphicsPipeline);
 FreeAndNil(fVulkanSolidPrimitiveGraphicsPipeline);
 FreeAndNil(fVulkanPipelineLayout);
 for Index:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fPassVulkanDescriptorSets[Index]);
 end;
 FreeAndNil(fPassVulkanDescriptorPool);
 FreeAndNil(fPassVulkanDescriptorSetLayout);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesCanvasRenderPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesCanvasRenderPass.OnSetRenderPassResources(const aCommandBuffer:TpvVulkanCommandBuffer;
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

procedure TpvScene3DRendererPassesCanvasRenderPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;
                                                            const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameState:TpvScene3DRendererInstance.PInFlightFrameState;
    PushConstants:TPushConstants;
begin
 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 PushConstants.ViewBaseIndex:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].FinalUnjitteredViewIndex;
 PushConstants.CountViews:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].CountFinalViews;
 PushConstants.CountAllViews:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].CountViews;
 PushConstants.ViewPortSize:=TpvVector2.Create(fResourceColor.Width,fResourceColor.Height);

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 InFlightFrameState:=@fInstance.InFlightFrameStates^[aInFlightFrameIndex];

 if InFlightFrameState^.Ready then begin

  fOnSetRenderPassResourcesDone:=false;

  aCommandBuffer.CmdPushConstants(fVulkanPipelineLayout.Handle,
                                  TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_FRAGMENT_BIT) or IfThen(fGeometryShaderSupport,TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_GEOMETRY_BIT),0),
                                  0,
                                  SizeOf(TPushConstants),
                                  @PushConstants);

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                       fVulkanPipelineLayout.Handle,
                                       0,
                                       1,
                                       @fInstance.Scene3D.GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle,
                                       0,
                                       nil);

  fInstance.Renderer.Scene3D.DrawDebugPrimitives(fInstance,
                                                 fVulkanDebugPrimitiveGraphicsPipeline,
                                                 -1,
                                                 aInFlightFrameIndex,
                                                 TpvScene3DRendererRenderPass.View,
                                                 InFlightFrameState^.FinalUnjitteredViewIndex,
                                                 InFlightFrameState^.CountFinalViews,
                                                 FrameGraph.DrawFrameIndex,
                                                 aCommandBuffer,
                                                 fVulkanPipelineLayout,
                                                 OnSetRenderPassResources);

  fInstance.DrawSolidPrimitives(fInstance,
                                fVulkanSolidPrimitiveGraphicsPipeline,
                                -1,
                                aInFlightFrameIndex,
                                TpvScene3DRendererRenderPass.View,
                                InFlightFrameState^.FinalUnjitteredViewIndex,
                                InFlightFrameState^.CountFinalViews,
                                FrameGraph.DrawFrameIndex,
                                aCommandBuffer,
                                fVulkanPipelineLayout,
                                OnSetRenderPassResources);

 end;

end;

end.
