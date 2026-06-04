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
unit PasVulkan.Scene3D.Renderer.Passes.AntialiasingTAARenderPass;
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

type { TpvScene3DRendererPassesAntialiasingTAARenderPass }
      TpvScene3DRendererPassesAntialiasingTAARenderPass=class(TpvFrameGraph.TRenderPass)
       public
        const FLAG_FIRST_FRAME_DISOCCLUSION=TpvUInt32(TpvUInt32(1) shl 0); // First frame disocclusion
              FLAG_TRANSLUCENT_DISOCCLUSION=TpvUInt32(TpvUInt32(1) shl 1); // Translucent disocclusion
              FLAG_VELOCITY_DISOCCLUSION=TpvUInt32(TpvUInt32(1) shl 2); // Velocity disocclusion
              FLAG_DEPTH_DISOCCLUSION=TpvUInt32(TpvUInt32(1) shl 3); // Depth disocclusion
              FLAG_INCLUDE_BACKGROUND=TpvUInt32(TpvUInt32(1) shl 4); // Include background in the temporal antialiasing.
              FLAG_VARIANCE_CLIPPING=TpvUInt32(TpvUInt32(1) shl 5); // Variance clipping
              FLAG_CHROMA_SHRINKING=TpvUInt32(TpvUInt32(1) shl 6); // Chroma shrinking
              FLAG_CLIPPING=TpvUInt32(TpvUInt32(1) shl 7); // Clipping
              FLAG_LUMINANCE_WEIGHTING=TpvUInt32(TpvUInt32(1) shl 8); // Luminance weighting
              FLAG_USE_FALLBACK_FXAA=TpvUInt32(TpvUInt32(1) shl 9); // Use fallback FXAA for disoccluded or otherwise rejected areas.
              FLAG_DISABLE_TEMPORAL_ANTIALIASING=TpvUInt32(TpvUInt32(1) shl 10); // For debugging purposes and for showing the raw jittered input without any temporal antialiasing when FLAG_USE_FALLBACK_FXAA is even not set.
        type TPushConstants=packed record

              BaseViewIndex:TpvUInt32;
              CountViews:TpvUInt32;
              Flags:TpvUInt32;
              VarianceClipGamma:TpvFloat;

              BackgroundFeedbackMin:TpvFloat;
              BackgroundFeedbackMax:TpvFloat;
              TranslucentFeedbackMin:TpvFloat;
              TranslucentFeedbackMax:TpvFloat;

              OpaqueFeedbackMin:TpvFloat;
              OpaqueFeedbackMax:TpvFloat;
              ZMul:TpvFloat;
              ZAdd:TpvFloat;

              DisocclusionDebugFactor:TpvFloat;
              VelocityDisocclusionThreshold:TpvFloat;
              DepthDisocclusionThreshold:TpvFloat;
              SharpingFactor:TpvFloat; // <= 0.0 = disabled, > 0.0 = enabled (although 1e-7 is the real threshold, not 0.0) 

              JitterUV:TpvVector2;

             end;
       private
        fInstance:TpvScene3DRendererInstance;
        fVulkanRenderPass:TpvVulkanRenderPass;
        fResourceCurrentColor:TpvFrameGraph.TPass.TUsedImageResource;
        fResourceCurrentDepth:TpvFrameGraph.TPass.TUsedImageResource;
        fResourceCurrentVelocity:TpvFrameGraph.TPass.TUsedImageResource;
        fResourceSurface:TpvFrameGraph.TPass.TUsedImageResource;
        fVulkanTransferCommandBuffer:TpvVulkanCommandBuffer;
        fVulkanTransferCommandBufferFence:TpvVulkanFence;
        fVulkanVertexShaderModule:TpvVulkanShaderModule;
        fVulkanFragmentShaderModule:TpvVulkanShaderModule;
        fVulkanPipelineShaderStageVertex:TpvVulkanPipelineShaderStage;
        fVulkanPipelineShaderStageFragment:TpvVulkanPipelineShaderStage;
        fVulkanGraphicsPipeline:TpvVulkanGraphicsPipeline;
        fVulkanDescriptorPool:TpvVulkanDescriptorPool;
        fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
        fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
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

{ TpvScene3DRendererPassesAntialiasingTAARenderPass }

constructor TpvScene3DRendererPassesAntialiasingTAARenderPass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin

 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='AntialiasingTAARenderPass';

 MultiviewMask:=fInstance.SurfaceMultiviewMask;

 Queue:=aFrameGraph.UniversalQueue;

//SeparatePhysicalPass:=true;

//SeparateCommandBuffer:=true;

 Size:=TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,
                                       fInstance.SizeFactor,
                                       fInstance.SizeFactor,
                                       1.0,
                                       fInstance.CountSurfaceViews);

 fResourceCurrentColor:=AddImageInput(fInstance.LastOutputResource.ResourceType.Name,
                                      fInstance.LastOutputResource.Resource.Name,
                                      VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                      []);

{if fInstance.Renderer.TransparencyMode in [TpvScene3DRendererTransparencyMode.DIRECT,
                                            TpvScene3DRendererTransparencyMode.SPINLOCKOIT,
                                            TpvScene3DRendererTransparencyMode.INTERLOCKOIT,
                                            TpvScene3DRendererTransparencyMode.LOOPOIT,
                                            TpvScene3DRendererTransparencyMode.WBOIT,
                                            TpvScene3DRendererTransparencyMode.MBOIT] then begin
  fResourceCurrentColor:=AddImageInput('resourcetype_color_optimized_non_alpha',
                                       'resource_combinedopaquetransparency_final_color',
                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                       []
                                      );
 end else begin
  fResourceCurrentColor:=AddImageInput('resourcetype_color_optimized_non_alpha',
                                       'resource_forwardrendering_color',
                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                       []
                                      );
 end;}

 fResourceCurrentDepth:=AddImageInput('resourcetype_depth',
                                      'resource_depth_data',
                                      VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                      []
                                     );

 fResourceCurrentVelocity:=AddImageInput('resourcetype_velocity',
                                         'resource_velocity_data',
                                         VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                         []
                                        );

 fResourceSurface:=AddImageOutput('resourcetype_color_temporal_antialiasing',
                                  'resource_temporal_antialiasing_color',
                                  VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                  TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                               TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0)),
                                  [TpvFrameGraph.TResourceTransition.TFlag.Attachment]
                                 );

 fInstance.LastOutputResource:=fResourceSurface;

end;

destructor TpvScene3DRendererPassesAntialiasingTAARenderPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesAntialiasingTAARenderPass.AcquirePersistentResources;
var Stream:TStream;
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

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('antialiasing_taa_frag.spv');
 try
  fVulkanFragmentShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fVulkanVertexShaderModule,'main');

 fVulkanPipelineShaderStageFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fVulkanFragmentShaderModule,'main');

 fVulkanGraphicsPipeline:=nil;

end;

procedure TpvScene3DRendererPassesAntialiasingTAARenderPass.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStageVertex);
 FreeAndNil(fVulkanPipelineShaderStageFragment);
 FreeAndNil(fVulkanFragmentShaderModule);
 FreeAndNil(fVulkanVertexShaderModule);
 FreeAndNil(fVulkanTransferCommandBufferFence);
 FreeAndNil(fVulkanTransferCommandBuffer);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesAntialiasingTAARenderPass.AcquireVolatileResources;
var InFlightFrameIndex,PreviousInFlightFrameIndex:TpvSizeInt;
begin
 inherited AcquireVolatileResources;

 fVulkanRenderPass:=VulkanRenderPass;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fInstance.Renderer.CountInFlightFrames*6);
 fVulkanDescriptorPool.Initialize;

 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0,
                                       VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
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
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(3,
                                       VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(4,
                                       VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(5,
                                       VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                       []);
 fVulkanDescriptorSetLayout.Initialize;

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  PreviousInFlightFrameIndex:=InFlightFrameIndex-1;
  if PreviousInFlightFrameIndex<0 then begin
   inc(PreviousInFlightFrameIndex,FrameGraph.CountInFlightFrames);
  end;
  fVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                                           fVulkanDescriptorSetLayout);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                 [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                                                fResourceCurrentColor.VulkanImageViews[InFlightFrameIndex].Handle,
                                                                                                fResourceCurrentColor.ResourceTransition.Layout)],// TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))],
                                                                 [],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                 [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                                                fResourceCurrentDepth.VulkanImageViews[InFlightFrameIndex].Handle,
                                                                                                fResourceCurrentDepth.ResourceTransition.Layout)],// TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))],
                                                                 [],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                 [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                                                fResourceCurrentVelocity.VulkanImageViews[InFlightFrameIndex].Handle,
                                                                                                fResourceCurrentVelocity.ResourceTransition.Layout)],// TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))],
                                                                 [],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                 [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                                                fInstance.TAAHistoryColorImages[PreviousInFlightFrameIndex].VulkanArrayImageView.Handle,
                                                                                                TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))],
                                                                 [],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                 [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                                                fInstance.TAAHistoryDepthImages[PreviousInFlightFrameIndex].VulkanArrayImageView.Handle,
                                                                                                TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))],
                                                                 [],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                 [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                                                fInstance.TAAHistoryVelocityImages[PreviousInFlightFrameIndex].VulkanArrayImageView.Handle,
                                                                                                TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))],
                                                                 [],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].Flush;
 end;

 fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 fVulkanPipelineLayout.AddDescriptorSetLayout(fInstance.ViewBuffersDescriptorSetLayout);
 fVulkanPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),0,SizeOf(TPushConstants));
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
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasConstantFactor:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasClamp:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.DepthBiasSlopeFactor:=0.0;
 fVulkanGraphicsPipeline.RasterizationState.LineWidth:=1.0;

 fVulkanGraphicsPipeline.MultisampleState.RasterizationSamples:=VK_SAMPLE_COUNT_1_BIT;
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
 fVulkanGraphicsPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                                      VK_BLEND_FACTOR_SRC_ALPHA,
                                                                      VK_BLEND_FACTOR_DST_ALPHA,
                                                                      VK_BLEND_OP_ADD,
                                                                      VK_BLEND_FACTOR_ONE,
                                                                      VK_BLEND_FACTOR_ZERO,
                                                                      VK_BLEND_OP_ADD,
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) or
                                                                      TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT));

 fVulkanGraphicsPipeline.DepthStencilState.DepthTestEnable:=true;
 fVulkanGraphicsPipeline.DepthStencilState.DepthWriteEnable:=true;
 fVulkanGraphicsPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_ALWAYS;
 fVulkanGraphicsPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
 fVulkanGraphicsPipeline.DepthStencilState.StencilTestEnable:=false;

 fVulkanGraphicsPipeline.Initialize;

 fVulkanGraphicsPipeline.FreeMemory;

end;

procedure TpvScene3DRendererPassesAntialiasingTAARenderPass.ReleaseVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin

 FreeAndNil(fVulkanGraphicsPipeline);

 FreeAndNil(fVulkanPipelineLayout);

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[InFlightFrameIndex]);
 end;

 FreeAndNil(fVulkanDescriptorSetLayout);

 FreeAndNil(fVulkanDescriptorPool);

 fVulkanRenderPass:=nil;

 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesAntialiasingTAARenderPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesAntialiasingTAARenderPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var PushConstants:TPushConstants;
    DescriptorSets:array[0..1] of TVkDescriptorSet;
begin
 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);
 
 PushConstants.BaseViewIndex:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].FinalViewIndex;
 PushConstants.CountViews:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].CountFinalViews;

 PushConstants.Flags:=//FLAG_TRANSLUCENT_DISOCCLUSION or
                      FLAG_VELOCITY_DISOCCLUSION or
                    //FLAG_DEPTH_DISOCCLUSION or // works not yet so good, needs more work
                      FLAG_INCLUDE_BACKGROUND or
                      FLAG_VARIANCE_CLIPPING or
                      //FLAG_CHROMA_SHRINKING or // problematic with very bright pixels at bloom and so on later
                      FLAG_CLIPPING or
                      FLAG_LUMINANCE_WEIGHTING or
                      FLAG_USE_FALLBACK_FXAA;
 if aFrameIndex=0 then begin
  PushConstants.Flags:=PushConstants.Flags or FLAG_FIRST_FRAME_DISOCCLUSION;
 end;
 if (fInstance.DebugTAAMode and 2)<>0 then begin
  PushConstants.Flags:=(PushConstants.Flags or FLAG_DISABLE_TEMPORAL_ANTIALIASING) and not FLAG_USE_FALLBACK_FXAA;
 end;

 PushConstants.VarianceClipGamma:=1.0;

 PushConstants.BackgroundFeedbackMin:=0.5;
 PushConstants.BackgroundFeedbackMax:=0.75;

 PushConstants.TranslucentFeedbackMin:=0.8;
 PushConstants.TranslucentFeedbackMax:=0.9;

 PushConstants.OpaqueFeedbackMin:=0.88;
 PushConstants.OpaqueFeedbackMax:=0.97;

 if fInstance.ZFar>0.0 then begin
  PushConstants.ZMul:=-1.0;
  PushConstants.ZAdd:=1.0;
 end else begin
  PushConstants.ZMul:=1.0;
  PushConstants.ZAdd:=0.0; 
 end;
 
 if (fInstance.DebugTAAMode and 1)<>0 then begin
  PushConstants.DisocclusionDebugFactor:=1.0;
 end else begin
  PushConstants.DisocclusionDebugFactor:=0.0;
 end;

 PushConstants.VelocityDisocclusionThreshold:=1e-2;//32.0/TpvVector2.InlineableCreate(fResourceCurrentColor.Width,fResourceCurrentColor.Height).Length;

 PushConstants.DepthDisocclusionThreshold:=1.0;//32.0/TpvVector2.InlineableCreate(fResourceCurrentColor.Width,fResourceCurrentColor.Height).Length;

 PushConstants.SharpingFactor:=0.0; // No sharping for now

 PushConstants.JitterUV:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].Jitter.xy;

 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanGraphicsPipeline.Handle);

 aCommandBuffer.CmdPushConstants(fVulkanPipelineLayout.Handle,
                                  TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_FRAGMENT_BIT),
                                  0,
                                  SizeOf(TPushConstants),
                                  @PushConstants);

 DescriptorSets[0]:=fVulkanDescriptorSets[aInFlightFrameIndex].Handle;
 DescriptorSets[1]:=fInstance.ViewBuffersDescriptorSets[aInFlightFrameIndex].Handle;
 
 aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                      fVulkanPipelineLayout.Handle,
                                      0,
                                      2,@DescriptorSets,
                                      0,nil);

 aCommandBuffer.CmdDraw(3,1,0,0);
end;

end.
