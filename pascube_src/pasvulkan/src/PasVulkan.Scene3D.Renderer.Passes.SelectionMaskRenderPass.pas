(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                       Version see PasVulkan.Framework.pas                  *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2026, Benjamin Rosseaux (benjamin@rosseaux.de)          *
 *                                                                            *
 ******************************************************************************)
unit PasVulkan.Scene3D.Renderer.Passes.SelectionMaskRenderPass;
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

type { TpvScene3DRendererPassesSelectionMaskRenderPass }
     // Object-selection outline (branch objectselectiontry1, fork A): rasterizes the selected-only indirect draw list (built
     // by SelectionListComputePass) into a RG32UI mask (x = objectID = instanceDataIndex, y = floatBitsToUint(gl_FragCoord.z))
     // using its OWN depth buffer (GREATER+write -> the frontmost selected surface wins per pixel). Drawn WITHOUT the scene
     // depth, so occluded selected geometry is also captured; visible-vs-occluded is resolved later in the compose pass by
     // comparing y against the scene depth at the seed position. Custom indirect draw (NOT Scene3D.Draw, which is hardwired to
     // cull-output drawcall slots): bind global set + view UBO + index buffer, push, vkCmdDrawIndexedIndirectCount (stride 32).
     // The command's firstInstance (=cmd1.x=meshObjectID) drives gl_InstanceIndex -> mesh.vert's per-draw fetch (BDA pulling).
     // Simplification for the first experiment: a single SELECTIONMASK alphatest pipeline (triangles, back-cull) for the whole
     // list (opaque -> alpha=1 passes the test); mixed topology/face-culling is not split yet.
     // Mesh-shader configs (Scene3D.MeshShaderSupport): the selection list holds TGPUDrawMeshTasksIndirectCommand and is drawn
     // with a task+mesh (mesh_task_pass1 + mesh_mesh) + SELECTIONMASK-frag pipeline via vkCmdDrawMeshTasksIndirectCountEXT;
     // mesh.mesh shares mesh.vert's BDA interface (outInstanceDataIndex @ loc 10) and the set-1 uboViews, so the same layout
     // and SELECTIONMASK frag are reused. Either/or by MeshShaderSupport (the input commands are one format or the other).
     TpvScene3DRendererPassesSelectionMaskRenderPass=class(TpvFrameGraph.TRenderPass)
      private
       fInstance:TpvScene3DRendererInstance;
       fResourceMask:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceDepth:TpvFrameGraph.TPass.TUsedImageResource;
       fVulkanRenderPass:TpvVulkanRenderPass;
       fMeshShader:Boolean;     // mesh-shader config -> draw the mesh-task selection list via mesh shaders instead of vertex/index
       fMeshTaskStage:Boolean;  // non-expand path (NOT UseMeshletExpand) -> a task shader expands meshlets; expand path uses mesh-only
       fMeshVertexShaderModule:TpvVulkanShaderModule;
       fMeshTaskShaderModule:TpvVulkanShaderModule;
       fMeshMeshShaderModule:TpvVulkanShaderModule;
       fMeshFragmentShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageMeshVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshTask:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshMesh:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageMeshFragment:TpvVulkanPipelineShaderStage;
       fPassVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fPassVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fPassVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fVulkanPipelineLayout:TpvVulkanPipelineLayout;
       fVulkanGraphicsPipeline:TpvVulkanGraphicsPipeline;
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

{ TpvScene3DRendererPassesSelectionMaskRenderPass }

constructor TpvScene3DRendererPassesSelectionMaskRenderPass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='SelectionMaskRenderPass';

 MultiviewMask:=fInstance.SurfaceMultiviewMask;

 Queue:=aFrameGraph.UniversalQueue;

 Size:=TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,
                                       fInstance.SizeFactor,
                                       fInstance.SizeFactor,
                                       1.0,
                                       fInstance.CountSurfaceViews);

 fResourceMask:=AddImageOutput('resourcetype_selection_mask',
                               'resource_selection_mask',
                               VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                               TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                            TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0)),
                               [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                              );

 fResourceDepth:=AddImageDepthOutput('resourcetype_selection_mask_depth',
                                     'resource_selection_mask_depth',
                                     VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
                                     TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                                  // reverse-Z: clear depth to the far value (0.0 when ZFar<0)
                                                                  TpvVector4.InlineableCreate(IfThen(fInstance.ZFar<0.0,0.0,1.0),0.0,0.0,0.0)),
                                     [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                    );

end;

destructor TpvScene3DRendererPassesSelectionMaskRenderPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesSelectionMaskRenderPass.AcquirePersistentResources;
var Stream:TStream;
begin

 inherited AcquirePersistentResources;

 fMeshShader:=fInstance.Renderer.Scene3D.MeshShaders;

 if fMeshShader then begin
  // Mirror CullDepthRenderPass: non-expand (NOT UseMeshletExpand) uses a task shader (mesh_task_pass0) that expands meshlets +
  // mesh_mesh; expand uses mesh-only (mesh_notask_mesh, no task). mesh.mesh shares mesh.vert's BDA interface (inInstanceDataIndex
  // @ loc 10) + set-1 uboViews. The selection list builds the NON-EXPAND mesh-task command (groupCount = ceil(count/32)).
  fMeshTaskStage:=not fInstance.Renderer.UseMeshletExpand;
  if fMeshTaskStage then begin
   // SELECTIONMASK task variant: emits all meshlets, no culling, no HiZ uTextureDepths binding -> compatible with this pass's
   // set-1 layout (view UBO only) + x-ray.
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_task_selectionmask_pass0.spv');
   try
    fMeshTaskShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
   finally
    Stream.Free;
   end;
   fVulkanPipelineShaderStageMeshTask:=TpvVulkanPipelineShaderStage.Create(TVkShaderStageFlagBits(VK_SHADER_STAGE_TASK_BIT_EXT),fMeshTaskShaderModule,'main');
  end;
  if fInstance.Renderer.UseMeshletExpand then begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_notask_mesh.spv');
  end else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_mesh.spv');
  end;
  try
   fMeshMeshShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
  fVulkanPipelineShaderStageMeshMesh:=TpvVulkanPipelineShaderStage.Create(TVkShaderStageFlagBits(VK_SHADER_STAGE_MESH_BIT_EXT),fMeshMeshShaderModule,'main');
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_vert.spv');
  try
   fMeshVertexShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
  fVulkanPipelineShaderStageMeshVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fMeshVertexShaderModule,'main');
 end;

 // Single alphatest SELECTIONMASK fragment variant (handles opaque too: alpha=1 passes the cutoff).
 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_'+fInstance.Renderer.MeshFragTypeName+'selectionmask_alphatest_frag.spv');
 try
  fMeshFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageMeshFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fMeshFragmentShaderModule,'main');

end;

procedure TpvScene3DRendererPassesSelectionMaskRenderPass.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStageMeshVertex);
 FreeAndNil(fVulkanPipelineShaderStageMeshTask);
 FreeAndNil(fVulkanPipelineShaderStageMeshMesh);
 FreeAndNil(fVulkanPipelineShaderStageMeshFragment);
 FreeAndNil(fMeshVertexShaderModule);
 FreeAndNil(fMeshTaskShaderModule);
 FreeAndNil(fMeshMeshShaderModule);
 FreeAndNil(fMeshFragmentShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesSelectionMaskRenderPass.AcquireVolatileResources;
var InFlightFrameIndex:TpvInt32;
begin

 inherited AcquireVolatileResources;

 fVulkanRenderPass:=VulkanRenderPass;

 // Pass set 1: binding 0 = the per-instance view UBO (uView). Read by mesh.vert in the vertex stage OR by mesh.task/mesh.mesh
 // in the task/mesh stages -> the stage flags MUST cover whichever path is active, else pipeline creation fails (VUID-07988).
 fPassVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 if fMeshShader then begin
  fPassVulkanDescriptorSetLayout.AddBinding(0,VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_TASK_BIT_EXT) or TVkShaderStageFlags(VK_SHADER_STAGE_MESH_BIT_EXT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]);
 end else begin
  fPassVulkanDescriptorSetLayout.AddBinding(0,VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]);
 end;
 fPassVulkanDescriptorSetLayout.Initialize;

 fPassVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                           TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                           fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,fInstance.Renderer.CountInFlightFrames);
 fPassVulkanDescriptorPool.Initialize;

 fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 if fMeshShader then begin
  fVulkanPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_TASK_BIT_EXT) or TVkShaderStageFlags(VK_SHADER_STAGE_MESH_BIT_EXT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),0,SizeOf(TpvScene3D.TMeshStagePushConstants));
 end else begin
  fVulkanPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),0,SizeOf(TpvScene3D.TMeshStagePushConstants));
 end;
 fVulkanPipelineLayout.AddDescriptorSetLayout(fInstance.Renderer.Scene3D.GlobalVulkanDescriptorSetLayout); // set 0
 fVulkanPipelineLayout.AddDescriptorSetLayout(fPassVulkanDescriptorSetLayout);                             // set 1
 fVulkanPipelineLayout.Initialize;

 fVulkanGraphicsPipeline:=TpvVulkanGraphicsPipeline.Create(fInstance.Renderer.VulkanDevice,
                                                           fInstance.Renderer.VulkanPipelineCache,
                                                           0,
                                                           [],
                                                           fVulkanPipelineLayout,
                                                           fVulkanRenderPass,
                                                           VulkanRenderPassSubpassIndex,
                                                           nil,
                                                           0);
 if fMeshShader then begin
  if fMeshTaskStage then begin
   fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshTask);
  end;
  fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshMesh);
 end else begin
  fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshVertex);
 end;
 fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageMeshFragment);

 fVulkanGraphicsPipeline.InputAssemblyState.Topology:=VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
 fVulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

 fInstance.Renderer.Scene3D.InitializeGraphicsPipeline(fVulkanGraphicsPipeline,false); // empty vertex input (BDA pulling / mesh-shader)

 fVulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,fResourceMask.Width,fResourceMask.Height,0.0,1.0);
 fVulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,fResourceMask.Width,fResourceMask.Height);

 fVulkanGraphicsPipeline.RasterizationState.DepthClampEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.RasterizerDiscardEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
 fVulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_BACK_BIT);
 fVulkanGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_COUNTER_CLOCKWISE;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.LineWidth:=1.0;

 fVulkanGraphicsPipeline.MultisampleState.RasterizationSamples:=VK_SAMPLE_COUNT_1_BIT;
 fVulkanGraphicsPipeline.MultisampleState.SampleShadingEnable:=false;

 // UINT color attachment: no blend, write R+G (id + depth).
 fVulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                      VK_BLEND_FACTOR_ZERO,VK_BLEND_FACTOR_ZERO,VK_BLEND_OP_ADD,
                                                                      VK_BLEND_FACTOR_ZERO,VK_BLEND_FACTOR_ZERO,VK_BLEND_OP_ADD,
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT));

 fVulkanGraphicsPipeline.DepthStencilState.DepthTestEnable:=true;
 fVulkanGraphicsPipeline.DepthStencilState.DepthWriteEnable:=true;
 if fInstance.ZFar<0.0 then begin
  fVulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_GREATER_OR_EQUAL; // reverse-Z -> frontmost selected wins
 end else begin
  fVulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_LESS_OR_EQUAL;
 end;
 fVulkanGraphicsPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
 fVulkanGraphicsPipeline.DepthStencilState.StencilTestEnable:=false;

 fVulkanGraphicsPipeline.Initialize;

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  fPassVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fPassVulkanDescriptorPool,fPassVulkanDescriptorSetLayout);
  fPassVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),[],
   [fInstance.VulkanViewUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false);
  fPassVulkanDescriptorSets[InFlightFrameIndex].Flush;
 end;

end;

procedure TpvScene3DRendererPassesSelectionMaskRenderPass.ReleaseVolatileResources;
var InFlightFrameIndex:TpvInt32;
begin
 FreeAndNil(fVulkanGraphicsPipeline);
 FreeAndNil(fVulkanPipelineLayout);
 for InFlightFrameIndex:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fPassVulkanDescriptorSets[InFlightFrameIndex]);
 end;
 FreeAndNil(fPassVulkanDescriptorSetLayout);
 FreeAndNil(fPassVulkanDescriptorPool);
 fVulkanRenderPass:=nil;
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesSelectionMaskRenderPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesSelectionMaskRenderPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameState:TpvScene3DRendererInstance.PInFlightFrameState;
    PushConstants:TpvScene3D.TMeshStagePushConstants;
    DescriptorSets:array[0..1] of TVkDescriptorSet;
    MaxCommands:TpvUInt32;
    vkCmdDrawIndexedIndirectCount:TvkCmdDrawIndexedIndirectCount;
    vkCmdDrawMeshTasksIndirectCountEXT:TvkCmdDrawMeshTasksIndirectCountEXT;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 InFlightFrameState:=@fInstance.InFlightFrameStates^[aInFlightFrameIndex];
 if not InFlightFrameState^.Ready then begin
  exit;
 end;

 // Nothing selected -> skip the draw; the attachment load-op already cleared the mask to empty (selection-outline skip).
 if fInstance.Scene3D.CountSelectedInstances<=0 then begin
  exit;
 end;

 // Base push (size/time/frame), but use the UN-JITTERED final view matrices so the mask (and thus the outline) is stable and
 // not shimmering with the TAA jitter that is baked into the regular FinalView projection matrices.
 PushConstants:=fInstance.MeshStagePushConstants[TpvScene3DRendererRenderPass.View];
 PushConstants.ViewBaseIndex:=InFlightFrameState^.FinalUnjitteredViewIndex;
 PushConstants.CountViews:=InFlightFrameState^.CountFinalViews;
 PushConstants.FrameIndex:=TpvUInt32(aFrameIndex);

 if fMeshShader then begin
  // mesh.task / mesh.mesh read the per-draw command (meshletBase/Count/objID) via MeshDrawCommandsBDA + gl_DrawID. The copied
  // push points at the MAIN render's command buffer -> redirect it to OUR selection list buffer, else they fetch wrong metadata.
  PushConstants.MeshDrawCommandsBDA:=fInstance.SelectionListDrawIndexedIndirectCommandBuffers[aInFlightFrameIndex].DeviceAddress;
 end;

 MaxCommands:=fInstance.PerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex];

 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanGraphicsPipeline.Handle);

 DescriptorSets[0]:=fInstance.Renderer.Scene3D.GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle;
 DescriptorSets[1]:=fPassVulkanDescriptorSets[aInFlightFrameIndex].Handle;
 aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanPipelineLayout.Handle,0,2,@DescriptorSets[0],0,nil);

 if fMeshShader then begin

  // Disable meshlet culling for the selection draw so occluded selected meshlets are still rasterized (x-ray) -> matches the
  // vertex/index path, which draws the pre-occlusion list. With FLAG_MESHLET_CULLING_ENABLED (bit 3) cleared, mesh.task takes
  // its "culling disabled" branch and emits all meshlets conservatively (no frustum/HiZ cull).
  PushConstants.DrawFlags:=PushConstants.DrawFlags and not TpvUInt32(1 shl 3);

  aCommandBuffer.CmdPushConstants(fVulkanPipelineLayout.Handle,
                                  TVkShaderStageFlags(VK_SHADER_STAGE_TASK_BIT_EXT) or TVkShaderStageFlags(VK_SHADER_STAGE_MESH_BIT_EXT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                  0,SizeOf(TpvScene3D.TMeshStagePushConstants),@PushConstants);

  // Mesh-shader path: the selection list now holds TGPUDrawMeshTasksIndirectCommand (groupCount xyz @ offset 0); draw via
  // vkCmdDrawMeshTasksIndirectCountEXT (not wrapped on TpvVulkanCommandBuffer -> resolve the device command, like Scene3D.Draw).
  if assigned(fInstance.Renderer.VulkanDevice.Commands.Commands.CmdDrawMeshTasksIndirectCountEXT) then begin
   vkCmdDrawMeshTasksIndirectCountEXT:=fInstance.Renderer.VulkanDevice.Commands.Commands.CmdDrawMeshTasksIndirectCountEXT;
  end else begin
   vkCmdDrawMeshTasksIndirectCountEXT:=nil;
  end;

  if assigned(vkCmdDrawMeshTasksIndirectCountEXT) then begin
   vkCmdDrawMeshTasksIndirectCountEXT(aCommandBuffer.Handle,
                                      fInstance.SelectionListDrawIndexedIndirectCommandBuffers[aInFlightFrameIndex].Handle,
                                      0,
                                      fInstance.SelectionListDrawIndexedIndirectCommandCountBuffers[aInFlightFrameIndex].Handle,
                                      0,
                                      MaxCommands,
                                      SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand)); // stride 32
  end;

 end else begin

  aCommandBuffer.CmdPushConstants(fVulkanPipelineLayout.Handle,
                                  TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                  0,SizeOf(TpvScene3D.TMeshStagePushConstants),@PushConstants);

  aCommandBuffer.CmdBindIndexBuffer(fInstance.Renderer.Scene3D.VulkanDrawIndexBuffer.Handle,0,TVkIndexType.VK_INDEX_TYPE_UINT32);

  // vkCmdDrawIndexedIndirectCount is not wrapped on TpvVulkanCommandBuffer -> resolve the device command (core or KHR), like
  // TpvScene3DPlanet.TRenderPass.Draw does.
  if assigned(fInstance.Renderer.VulkanDevice.Commands.Commands.CmdDrawIndexedIndirectCount) then begin
   vkCmdDrawIndexedIndirectCount:=fInstance.Renderer.VulkanDevice.Commands.Commands.CmdDrawIndexedIndirectCount;
  end else if assigned(fInstance.Renderer.VulkanDevice.Commands.Commands.CmdDrawIndexedIndirectCountKHR) then begin
   vkCmdDrawIndexedIndirectCount:=addr(fInstance.Renderer.VulkanDevice.Commands.Commands.CmdDrawIndexedIndirectCountKHR);
  end else begin
   vkCmdDrawIndexedIndirectCount:=nil;
  end;

  if assigned(vkCmdDrawIndexedIndirectCount) then begin
   vkCmdDrawIndexedIndirectCount(aCommandBuffer.Handle,
                                 fInstance.SelectionListDrawIndexedIndirectCommandBuffers[aInFlightFrameIndex].Handle,
                                 0,
                                 fInstance.SelectionListDrawIndexedIndirectCommandCountBuffers[aInFlightFrameIndex].Handle,
                                 0,
                                 MaxCommands,
                                 SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand)); // stride 32
  end;

 end;

end;

end.
