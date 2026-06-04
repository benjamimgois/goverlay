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
unit PasVulkan.Scene3D.Renderer.Passes.AtmosphereCloudRenderPass;
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
     PasVulkan.Scene3D.Atmosphere,
     PasVulkan.Scene3D.Renderer.Globals,
     PasVulkan.Scene3D.Renderer,
     PasVulkan.Scene3D.Renderer.Instance,
     PasVulkan.Scene3D.Renderer.SkyBox;

type { TpvScene3DRendererPassesAtmosphereCloudRenderPass }
     TpvScene3DRendererPassesAtmosphereCloudRenderPass=class(TpvFrameGraph.TRenderPass)
      public
      private
       fInstance:TpvScene3DRendererInstance;
       fVulkanRenderPass:TpvVulkanRenderPass;
       fResourceCascadedShadowMap:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceDepth:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceOutput:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceTransmittance:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceLinearDepth:TpvFrameGraph.TPass.TUsedImageResource;
       fVulkanTransferCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanTransferCommandBufferFence:TpvVulkanFence;
       fVulkanVertexShaderModule:TpvVulkanShaderModule;
       fVulkanFragmentShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageFragment:TpvVulkanPipelineShaderStage;
       fVulkanGraphicsPipeline:TpvVulkanGraphicsPipeline;
{      fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fVulkanPipelineLayout:TpvVulkanPipelineLayout;}
       fPushConstants:TpvScene3DAtmosphereGlobals.TCloudRaymarchingPushConstants;
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

{ TpvScene3DRendererPassesAtmosphereCloudRenderPass }

constructor TpvScene3DRendererPassesAtmosphereCloudRenderPass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin

 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='AtmosphereCloudRenderPass';

 MultiviewMask:=0;//fInstance.SurfaceMultiviewMask;

 Queue:=aFrameGraph.UniversalQueue;

//SeparatePhysicalPass:=true;

//SeparateCommandBuffer:=true;

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

 if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
  fResourceDepth:=AddImageDepthInput('resourcetype_depth',
                                     'resource_depth_data',
                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                     []
                                    );
 end else begin
  fResourceDepth:=AddImageDepthInput('resourcetype_msaa_depth',
                                     'resource_msaa_depth_data',
                                      VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                      []
                                     );
 end;

 begin

  fResourceOutput:=AddImageOutput('resourcetype_inscattering',
                                  'resource_clouds_inscattering',
                                  VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                  TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                               TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0)),
                                  [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                 );

  fResourceTransmittance:=AddImageOutput('resourcetype_transmittance',
                                         'resource_clouds_transmittance',
                                         VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                         TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                                      TpvVector4.InlineableCreate(1.0,1.0,1.0,0.0)),
                                         [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                        );

  fResourceLinearDepth:=AddImageOutput('resourcetype_lineardepth',
                                       'resource_clouds_lineardepth',
                                       VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                       TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                                    TpvVector4.InlineableCreate(Infinity,0.0,0.0,0.0)),
                                       [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                      );

 end;

//fInstance.LastOutputResource:=fResourceOutput;

end;

destructor TpvScene3DRendererPassesAtmosphereCloudRenderPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesAtmosphereCloudRenderPass.AcquirePersistentResources;
var ShadowType:String;
    Stream:TStream;
begin

 inherited AcquirePersistentResources;

 fVulkanTransferCommandBuffer:=TpvVulkanCommandBuffer.Create(FrameGraph.TransferQueue.CommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

 fVulkanTransferCommandBufferFence:=TpvVulkanFence.Create(fInstance.Renderer.VulkanDevice);

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('fullscreen_vert.spv');
 try
  fVulkanVertexShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 if fInstance.Renderer.RaytracingActive then begin
  ShadowType:='shadows_raytracing_';
 end else begin
  case fInstance.Renderer.ShadowMode of
   TpvScene3DRendererShadowMode.PCF,TpvScene3DRendererShadowMode.DPCF,TpvScene3DRendererShadowMode.PCSS:begin
    ShadowType:='shadows_pcfpcss_';
   end;
   TpvScene3DRendererShadowMode.MSM:begin
    ShadowType:='shadows_msm_';
   end;
   else begin
    ShadowType:='';
   end;
  end;
 end;

 begin
  if fResourceDepth.CountArrayLayers>0 {fInstance.CountSurfaceViews>1} then begin
   if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('atmosphere_clouds_raymarch_'+ShadowType+'multiview_frag.spv');
   end else begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('atmosphere_clouds_raymarch_'+ShadowType+'multiview_msaa_frag.spv');
   end;
  end else begin
   if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('atmosphere_clouds_raymarch_'+ShadowType+'frag.spv');
   end else begin
    Stream:=pvScene3DShaderVirtualFileSystem.GetFile('atmosphere_clouds_raymarch_'+ShadowType+'msaa_frag.spv');
   end;
  end;
 end;
 try
  fVulkanFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fVulkanVertexShaderModule,'main');

 fVulkanPipelineShaderStageFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fVulkanFragmentShaderModule,'main');

 fVulkanGraphicsPipeline:=nil;

end;

procedure TpvScene3DRendererPassesAtmosphereCloudRenderPass.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStageVertex);
 FreeAndNil(fVulkanPipelineShaderStageFragment);
 FreeAndNil(fVulkanFragmentShaderModule);
 FreeAndNil(fVulkanVertexShaderModule);
 FreeAndNil(fVulkanTransferCommandBufferFence);
 FreeAndNil(fVulkanTransferCommandBuffer);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesAtmosphereCloudRenderPass.AcquireVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin
 inherited AcquireVolatileResources;

 fVulkanRenderPass:=VulkanRenderPass;

{fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT,1*fInstance.Renderer.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,4*fInstance.Renderer.CountInFlightFrames);
 fVulkanDescriptorPool.Initialize;

 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0,
                                       VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(1,
                                       VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(2,
                                       VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                       3,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                       []);
 fVulkanDescriptorSetLayout.Initialize;

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  fVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                                           fVulkanDescriptorSetLayout);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT),
                                                                 [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                fResourceScene.VulkanImageViews[InFlightFrameIndex].Handle,
                                                                                                fResourceScene.ResourceTransition.Layout)],// TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))],
                                                                 [],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                 [TVkDescriptorImageInfo.Create(fInstance.Renderer.GeneralSampler.Handle,
                                                                                                fInstance.FullResSceneMipmappedArray2DImage.VulkanArrayImageView.Handle,
                                                                                                TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))],
                                                                 [],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                 0,
                                                                 3,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                 [fInstance.Renderer.LensColor.DescriptorImageInfo,
                                                                  fInstance.Renderer.LensDirt.DescriptorImageInfo,
                                                                  fInstance.Renderer.LensStar.DescriptorImageInfo],
                                                                 [],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].Flush;
 end;

 fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 fVulkanPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),0,SizeOf(TpvScene3DRendererPassesAtmosphereCloudRenderPass.TPushConstants));
 fVulkanPipelineLayout.Initialize;}

 fVulkanGraphicsPipeline:=TpvVulkanGraphicsPipeline.Create(fInstance.Renderer.VulkanDevice,
                                                           fInstance.Renderer.VulkanPipelineCache,
                                                           0,
                                                           [],
                                                           TpvScene3DAtmosphereGlobals(fInstance.Scene3D.AtmosphereGlobals).CloudRaymarchingPipelineLayout,
                                                           fVulkanRenderPass,
                                                           VulkanRenderPassSubpassIndex,
                                                           nil,
                                                           0);

 fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageVertex);
 fVulkanGraphicsPipeline.AddStage(fVulkanPipelineShaderStageFragment);

 fVulkanGraphicsPipeline.InputAssemblyState.Topology:=VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
 fVulkanGraphicsPipeline.InputAssemblyState.PrimitiveRestartEnable:=false;

 fVulkanGraphicsPipeline.ViewPortState.AddViewPort(0.0,0.0,fResourceOutput.Width,fResourceOutput.Height,0.0,1.0);
 fVulkanGraphicsPipeline.ViewPortState.AddScissor(0,0,fResourceOutput.Width,fResourceOutput.Height);

 fVulkanGraphicsPipeline.RasterizationState.DepthClampEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.RasterizerDiscardEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.PolygonMode:=VK_POLYGON_MODE_FILL;
 fVulkanGraphicsPipeline.RasterizationState.CullMode:=TVkCullModeFlags(VK_CULL_MODE_NONE);
 fVulkanGraphicsPipeline.RasterizationState.FrontFace:=VK_FRONT_FACE_CLOCKWISE;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasEnable:=false;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasConstantFactor:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasClamp:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasSlopeFactor:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.LineWidth:=1.0;

 fVulkanGraphicsPipeline.MultisampleState.RasterizationSamples:=VK_SAMPLE_COUNT_1_BIT;//fInstance.Renderer.SurfaceSampleCountFlagBits;
 fVulkanGraphicsPipeline.MultisampleState.SampleShadingEnable:=false;
 fVulkanGraphicsPipeline.MultisampleState.MinSampleShading:=0.0;
 fVulkanGraphicsPipeline.MultisampleState.CountSampleMasks:=0;
 fVulkanGraphicsPipeline.MultisampleState.AlphaToCoverageEnable:=false;
 fVulkanGraphicsPipeline.MultisampleState.AlphaToOneEnable:=false;

 fVulkanGraphicsPipeline.ColorBlendState.LogicOpEnable:=false;
 fVulkanGraphicsPipeline.ColorBlendState.LogicOp:=VK_LOGIC_OP_COPY;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[0]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[1]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[2]:=0.0;
 fVulkanGraphicsPipeline.ColorBlendState.BlendConstants[3]:=0.0;
 begin
  fVulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(true,
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
  fVulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(true,
                                                                       VK_BLEND_FACTOR_DST_COLOR,
                                                                       VK_BLEND_FACTOR_ZERO,
                                                                       VK_BLEND_OP_ADD,
                                                                       VK_BLEND_FACTOR_ONE,
                                                                       VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                                                                       VK_BLEND_OP_ADD,
                                                                       TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                       TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                       TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                       TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));
 end;
 fVulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                      VK_BLEND_FACTOR_ONE,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_OP_ADD,
                                                                      VK_BLEND_FACTOR_ONE,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_OP_ADD,
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT));

 fVulkanGraphicsPipeline.DepthStencilState.DepthTestEnable:=false;
 fVulkanGraphicsPipeline.DepthStencilState.DepthWriteEnable:=false;
 fVulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_ALWAYS;
 fVulkanGraphicsPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
 fVulkanGraphicsPipeline.DepthStencilState.StencilTestEnable:=false;

 fVulkanGraphicsPipeline.Initialize;

 fVulkanGraphicsPipeline.FreeMemory;

end;

procedure TpvScene3DRendererPassesAtmosphereCloudRenderPass.ReleaseVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin

 FreeAndNil(fVulkanGraphicsPipeline);
(*

 FreeAndNil(fVulkanPipelineLayout);

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[InFlightFrameIndex]);
 end;

 FreeAndNil(fVulkanDescriptorSetLayout);

 FreeAndNil(fVulkanDescriptorPool);

  *)

 fVulkanRenderPass:=nil;

 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesAtmosphereCloudRenderPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesAtmosphereCloudRenderPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameState:TpvScene3DRendererInstance.PInFlightFrameState;
begin
 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanGraphicsPipeline.Handle);

 InFlightFrameState:=@TpvScene3DRendererInstance(fInstance).InFlightFrameStates[aInFlightFrameIndex];

 fPushConstants.BaseViewIndex:=InFlightFrameState^.FinalUnjitteredViewIndex;
 fPushConstants.CountViews:=InFlightFrameState^.CountFinalViews;

 if fInstance.Renderer.AnimatedAtmosphereNoise then begin
  fPushConstants.FrameIndex:=aFrameIndex;
 end else begin
  fPushConstants.FrameIndex:=0;
 end;

 fPushConstants.Flags:=0;
 if TpvScene3DRenderer(TpvScene3DRendererInstance(fInstance).Renderer).FastSky then begin
  fPushConstants.Flags:=fPushConstants.Flags or (TpvUInt32(1) shl 0);
 end;
 if TpvScene3DRenderer(TpvScene3DRendererInstance(fInstance).Renderer).FastAerialPerspective then begin
  fPushConstants.Flags:=fPushConstants.Flags or (TpvUInt32(1) shl 1);
 end;
 if TpvScene3DRenderer(TpvScene3DRendererInstance(fInstance).Renderer).AtmosphereBlueNoise then begin
  fPushConstants.Flags:=fPushConstants.Flags or (TpvUInt32(1) shl 2);
 end;
 if TpvScene3DRenderer(TpvScene3DRendererInstance(fInstance).Renderer).AtmosphereShadows then begin
  fPushConstants.Flags:=fPushConstants.Flags or (TpvUInt32(1) shl 3);
 end;
 if TpvScene3DRendererInstance(fInstance).ZFar<0.0 then begin
  fPushConstants.Flags:=fPushConstants.Flags or (TpvUInt32(1) shl 16);
 end;
 fPushConstants.CountSamples:=TpvScene3DRenderer(TpvScene3DRendererInstance(fInstance).Renderer).CountSurfaceMSAASamples;

 aCommandBuffer.CmdPushConstants(TpvScene3DAtmosphereGlobals(fInstance.Scene3D.AtmosphereGlobals).CloudRaymarchingPipelineLayout.Handle,
                                 TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_FRAGMENT_BIT),
                                 0,
                                 SizeOf(TpvScene3DAtmosphereGlobals.TCloudRaymarchingPushConstants),
                                 @fPushConstants);

 TpvScene3DAtmospheres(fInstance.Scene3D.Atmospheres).DrawClouds(aInFlightFrameIndex,
                                                                 aCommandBuffer,
                                                                 fResourceDepth.VulkanImageViews[aInFlightFrameIndex].Handle,
                                                                 fResourceCascadedShadowMap.VulkanImageViews[aInFlightFrameIndex].Handle,
                                                                 fInstance);

end;

end.
