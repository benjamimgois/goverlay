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
unit PasVulkan.Scene3D.Renderer.Passes.SelectionOutlineBuildRenderPass;
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

type { TpvScene3DRendererPassesSelectionOutlineBuildRenderPass }
     // Object-selection outline — outline BUILD pass (branch objectselectiontry1). Fullscreen. Reads ONLY the selection mask and
     // writes the border ring into an isolated premultiplied outline buffer (rgb = outlineColor*coverage, a = coverage); it does
     // NOT touch the scene color or LastOutputResource. The following SelectionOutlineFXAAComposeRenderPass anti-aliases this
     // buffer in isolation and composites it over the scene (so the already-AA'd scene never gets a second blur).
     TpvScene3DRendererPassesSelectionOutlineBuildRenderPass=class(TpvFrameGraph.TRenderPass)
      public
       type TPushConstants=record
             OutlineColor:TpvVector4; // xyz = color, w = strength
             Params:TpvVector4;       // x = thickness(px), y/z/w = unused
            end;
            PPushConstants=^TPushConstants;
      private
       fInstance:TpvScene3DRendererInstance;
       fResourceMask:TpvFrameGraph.TPass.TUsedImageResource;
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

{ TpvScene3DRendererPassesSelectionOutlineBuildRenderPass }

constructor TpvScene3DRendererPassesSelectionOutlineBuildRenderPass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin

 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='SelectionOutlineBuildRenderPass';

 MultiviewMask:=fInstance.SurfaceMultiviewMask;

 Queue:=aFrameGraph.UniversalQueue;

 Size:=TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,
                                       fInstance.SizeFactor,
                                       fInstance.SizeFactor,
                                       1.0,
                                       fInstance.CountSurfaceViews);

 // Read only the selection mask; write the isolated premultiplied outline buffer (cleared to transparent). The scene and
 // LastOutputResource are untouched here — the FXAA+composite pass that follows does that.
 fResourceMask:=AddImageInput('resourcetype_selection_mask',
                              'resource_selection_mask',
                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                              []);

 fResourceSurface:=AddImageOutput('resourcetype_selection_outline_buffer',
                                  'resource_selection_outline_buffer',
                                  VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                  TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                               TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0)),
                                  [TpvFrameGraph.TResourceTransition.TFlag.Attachment]);

end;

destructor TpvScene3DRendererPassesSelectionOutlineBuildRenderPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesSelectionOutlineBuildRenderPass.AcquirePersistentResources;
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
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('selection_outline_build_multiview_frag.spv');
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('selection_outline_build_frag.spv');
 end;
 try
  fVulkanFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fVulkanVertexShaderModule,'main');
 fVulkanPipelineShaderStageFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fVulkanFragmentShaderModule,'main');

end;

procedure TpvScene3DRendererPassesSelectionOutlineBuildRenderPass.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStageVertex);
 FreeAndNil(fVulkanPipelineShaderStageFragment);
 FreeAndNil(fVulkanFragmentShaderModule);
 FreeAndNil(fVulkanVertexShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesSelectionOutlineBuildRenderPass.AcquireVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin

 inherited AcquireVolatileResources;

 fVulkanRenderPass:=VulkanRenderPass;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,fInstance.Renderer.CountInFlightFrames*1);
 fVulkanDescriptorPool.Initialize;

 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0,VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,1,TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]); // selection mask (utexture)
 fVulkanDescriptorSetLayout.Initialize;

 fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),0,SizeOf(TPushConstants));
 fVulkanPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);                        // set 0 (pass-specific: mask)
 fVulkanPipelineLayout.AddDescriptorSetLayout(fInstance.Scene3D.GlobalVulkanDescriptorSetLayout); // set 1 (InstanceData @6 for per-object color)
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
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE),
   [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,fResourceMask.VulkanImageViews[InFlightFrameIndex].Handle,fResourceMask.ResourceTransition.Layout)],[],[],false);
  fVulkanDescriptorSets[InFlightFrameIndex].Flush;
 end;

end;

procedure TpvScene3DRendererPassesSelectionOutlineBuildRenderPass.ReleaseVolatileResources;
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

procedure TpvScene3DRendererPassesSelectionOutlineBuildRenderPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesSelectionOutlineBuildRenderPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
const ReferenceHeight=1080.0; // render-buffer height that SelectionOutlineThickness is tuned for
      MinThicknessPixels=3.0; // hard lower bound: below ~3 render px an outline aliases/disappears, so never thin past this
      MaxThicknessPixels=8.0; // the build-shader dilation is O(thickness^2) per pixel -> clamp to bound the cost (JFA path planned for genuinely thick outlines)
var PushConstants:TPushConstants;
    DescriptorSets:array[0..1] of TVkDescriptorSet;
    Thickness:TpvScalar;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 // Nothing selected -> skip the dilation draw; the load-op already cleared the outline buffer to transparent.
 if fInstance.Scene3D.CountSelectedInstances<=0 then begin
  exit;
 end;

 // Resolution-scale the outline thickness so it stays a constant on-screen fraction across render resolutions and
 // AI/EASU upscaling: the outline buffer is built at render resolution (fResourceSurface.Height) and upscaled at
 // compose time, so scaling by renderHeight/ReferenceHeight self-normalizes the upscale. Clamp to an absolute
 // [MinThicknessPixels, MaxThicknessPixels] render-px range: the lower bound stops sub-1080p from thinning out
 // (pure linear made 720p = 2 px, too thin), the upper bound caps the O(thickness^2) dilation cost.
 Thickness:=Clamp(fInstance.SelectionOutlineThickness*(fResourceSurface.Height/ReferenceHeight),MinThicknessPixels,MaxThicknessPixels);

 // Fallback color/strength used by the shader only when the selected object has no SelectedColorIntensity set.
 PushConstants.OutlineColor:=TpvVector4.InlineableCreate(1.0,0.55,0.1,1.0); // warm orange fallback
 PushConstants.Params:=TpvVector4.InlineableCreate(Thickness,0.0,0.0,0.0);  // thickness (render px), resolution-scaled + clamped

 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanGraphicsPipeline.Handle);
 DescriptorSets[0]:=fVulkanDescriptorSets[aInFlightFrameIndex].Handle;                              // set 0: mask
 DescriptorSets[1]:=fInstance.Scene3D.GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle;       // set 1: InstanceData @6
 aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanPipelineLayout.Handle,0,2,@DescriptorSets[0],0,nil);
 aCommandBuffer.CmdPushConstants(fVulkanPipelineLayout.Handle,TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),0,SizeOf(TPushConstants),@PushConstants);
 aCommandBuffer.CmdDraw(3,1,0,0);

end;

end.
