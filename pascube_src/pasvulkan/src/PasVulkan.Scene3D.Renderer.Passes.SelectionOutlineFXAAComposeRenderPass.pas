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
unit PasVulkan.Scene3D.Renderer.Passes.SelectionOutlineFXAAComposeRenderPass;
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

type { TpvScene3DRendererPassesSelectionOutlineFXAAComposeRenderPass }
     // Object-selection outline — FXAA + composite pass (branch objectselectiontry1). Fullscreen. Anti-aliases the isolated
     // premultiplied outline buffer (from the outline-build pass) in isolation, then composites it over the scene color
     // (premultiplied-over) and updates LastOutputResource -> the UI (canvas, which reads LastOutputResource) ends up on top.
     // FXAA only ever sees the outline buffer, so the already-AA'd scene never gets a second blur.
     TpvScene3DRendererPassesSelectionOutlineFXAAComposeRenderPass=class(TpvFrameGraph.TRenderPass)
      private
       fInstance:TpvScene3DRendererInstance;
       fResourceOutline:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceColor:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceSurface:TpvFrameGraph.TPass.TUsedImageResource;
       fVulkanRenderPass:TpvVulkanRenderPass;
       fVulkanVertexShaderModule:TpvVulkanShaderModule;
       fVulkanFragmentShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageFragment:TpvVulkanPipelineShaderStage;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
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

{ TpvScene3DRendererPassesSelectionOutlineFXAAComposeRenderPass }

constructor TpvScene3DRendererPassesSelectionOutlineFXAAComposeRenderPass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
var InputColorTypeName:TpvRawByteString;
begin

 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='SelectionOutlineFXAAComposeRenderPass';

 MultiviewMask:=fInstance.SurfaceMultiviewMask;

 Queue:=aFrameGraph.UniversalQueue;

 // Full resolution (1.0), NOT SizeFactor: this pass lives in the post-tonemapping space. It composites over the full-res scene
 // color (LastOutputResource = tonemapping output, resourcetype_color_tonemapping @ 1.0) and its own output becomes the new
 // LastOutputResource that the canvas/UI read at full res. The attachment output therefore inherits the 1.0-sized tonemapping
 // resource type, so the pass Size must be 1.0 too (otherwise EpvFrameGraphMismatchImageSize when SizeFactor<>1.0). The outline
 // buffer and scene color inputs are plain sampler reads (no attachment flag), so they can stay at SizeFactor and get upscaled.
 Size:=TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,
                                       1.0,
                                       1.0,
                                       1.0,
                                       fInstance.CountSurfaceViews);

 InputColorTypeName:=fInstance.LastOutputResource.ResourceType.Name;

 // Isolated premultiplied outline buffer (combined LINEAR sampler for the FXAA sub-pixel taps).
 fResourceOutline:=AddImageInput('resourcetype_selection_outline_buffer',
                                 'resource_selection_outline_buffer',
                                 VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                 []);

 // Current scene color (whatever the post chain produced so far); point-read, composited under the outline.
 fResourceColor:=AddImageInput(InputColorTypeName,
                               fInstance.LastOutputResource.Resource.Name,
                               VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                               []);

 fResourceSurface:=AddImageOutput(InputColorTypeName,
                                  'resource_selection_outline_color',
                                  VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                  TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.DontCare),
                                  [TpvFrameGraph.TResourceTransition.TFlag.Attachment]);

 fInstance.LastOutputResource:=fResourceSurface;

end;

destructor TpvScene3DRendererPassesSelectionOutlineFXAAComposeRenderPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesSelectionOutlineFXAAComposeRenderPass.AcquirePersistentResources;
var Stream:TStream;
begin

 inherited AcquirePersistentResources;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('fullscreen_vert.spv');
 try
  fVulkanVertexShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 if fInstance.CountSurfaceViews>1 then begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('selection_outline_fxaa_compose_multiview_frag.spv');
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('selection_outline_fxaa_compose_frag.spv');
 end;
 try
  fVulkanFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fVulkanVertexShaderModule,'main');
 fVulkanPipelineShaderStageFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fVulkanFragmentShaderModule,'main');

end;

procedure TpvScene3DRendererPassesSelectionOutlineFXAAComposeRenderPass.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStageVertex);
 FreeAndNil(fVulkanPipelineShaderStageFragment);
 FreeAndNil(fVulkanFragmentShaderModule);
 FreeAndNil(fVulkanVertexShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesSelectionOutlineFXAAComposeRenderPass.AcquireVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin

 inherited AcquireVolatileResources;

 fVulkanRenderPass:=VulkanRenderPass;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fInstance.Renderer.CountInFlightFrames*1); // outline buffer (linear)
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,fInstance.Renderer.CountInFlightFrames*1);          // scene color (point)
 fVulkanDescriptorPool.Initialize;

 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0,VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,1,TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]); // outline buffer
 fVulkanDescriptorSetLayout.AddBinding(1,VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,1,TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]);          // scene color
 fVulkanDescriptorSetLayout.Initialize;

 fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
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
 fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageVertex);
 fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageFragment);
 fVulkanGraphicsPipeline.InputAssemblyState.Topology:=VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
 fVulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;
 fVulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,fResourceSurface.Width,fResourceSurface.Height,0.0,1.0);
 fVulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,fResourceSurface.Width,fResourceSurface.Height);
 fVulkanGraphicsPipeline.RasterizationState.DepthClampEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.RasterizerDiscardEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
 fVulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_NONE);
 fVulkanGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_CLOCKWISE;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.LineWidth:=1.0;
 fVulkanGraphicsPipeline.MultisampleState.RasterizationSamples:=VK_SAMPLE_COUNT_1_BIT;
 fVulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                      VK_BLEND_FACTOR_ZERO,VK_BLEND_FACTOR_ZERO,VK_BLEND_OP_ADD,
                                                                      VK_BLEND_FACTOR_ZERO,VK_BLEND_FACTOR_ZERO,VK_BLEND_OP_ADD,
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));
 fVulkanGraphicsPipeline.DepthStencilState.DepthTestEnable:=false;
 fVulkanGraphicsPipeline.DepthStencilState.DepthWriteEnable:=false;
 fVulkanGraphicsPipeline.DepthStencilState.StencilTestEnable:=false;
 fVulkanGraphicsPipeline.Initialize;

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  fVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,fVulkanDescriptorSetLayout);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
   [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,fResourceOutline.VulkanImageViews[InFlightFrameIndex].Handle,fResourceOutline.ResourceTransition.Layout)],[],[],false);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE),
   [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,fResourceColor.VulkanImageViews[InFlightFrameIndex].Handle,fResourceColor.ResourceTransition.Layout)],[],[],false);
  fVulkanDescriptorSets[InFlightFrameIndex].Flush;
 end;

end;

procedure TpvScene3DRendererPassesSelectionOutlineFXAAComposeRenderPass.ReleaseVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin
 FreeAndNil(fVulkanGraphicsPipeline);
 FreeAndNil(fVulkanPipelineLayout);
 for InFlightFrameIndex:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[InFlightFrameIndex]);
 end;
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanDescriptorPool);
 fVulkanRenderPass:=nil;
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesSelectionOutlineFXAAComposeRenderPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesSelectionOutlineFXAAComposeRenderPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 // Always runs (produces LastOutputResource that the UI/blit read); when nothing is selected the outline buffer is transparent
 // so the composite just passes the scene through.
 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanGraphicsPipeline.Handle);
 aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanPipelineLayout.Handle,0,1,@fVulkanDescriptorSets[aInFlightFrameIndex].Handle,0,nil);
 aCommandBuffer.CmdDraw(3,1,0,0);

end;

end.
