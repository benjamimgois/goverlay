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
unit PasVulkan.Scene3D.Renderer.SkyBox;
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
     PasVulkan.FrameGraph,
     PasVulkan.Scene3D,
     PasVulkan.Scene3D.Renderer.Globals,
     PasVulkan.Scene3D.Renderer,
     PasVulkan.Scene3D.Renderer.Array2DImage,
     PasVulkan.Scene3D.Renderer.Instance;

type { TpvScene3DRendererSkyBox }
     TpvScene3DRendererSkyBox=class
      public
       type TPushConstants=packed record

             CurrentOrientation:TpvVector4;
             PreviousOrientation:TpvVector4;

             LightDirection:TpvVector4;

             ViewBaseIndex:TpvUInt32;
             CountViews:TpvUInt32;
             SkyBoxBrightnessFactor:TpvFloat;
             WidthHeight:TpvUInt32;

             Mode:TpvUInt32;
             // Cached reprojection fields (GLSL truncates if not needed)
             CountAllViews:TpvUInt32;
             FrameIndex:TpvUInt32;
             SkyBoxIntensityFactor:TpvFloat;

            end;
            PPushConstants=^TPushConstants;
      private
       fRenderer:TpvScene3DRenderer;
       fRendererInstance:TpvScene3DRendererInstance;
       fOrientation:TpvVector4;
       fScene3D:TpvScene3D;
       fCached:Boolean;
       fUseRGB9E5:Boolean;
       fWidth:TpvInt32;
       fHeight:TpvInt32;
       fCountSurfaceViews:TpvInt32;
       fVertexShaderModule:TpvVulkanShaderModule;
       fFragmentShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageVertex:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageFragment:TpvVulkanPipelineShaderStage;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fVulkanPipelineLayout:TpvVulkanPipelineLayout;
       fVulkanPipeline:TpvVulkanGraphicsPipeline;
       // Cached reprojection resources
       fHistoryImages:array[0..MaxInFlightFrames-1] of TpvScene3DRendererArray2DImage;
       fHistoryImageLayouts:array[0..MaxInFlightFrames-1] of TVkImageLayout;
       fHistorySampler:TpvVulkanSampler;
       fFrameIndex:TpvUInt32;
       fHistoryValid:array[0..MaxInFlightFrames-1] of Boolean;
      public

       constructor Create(const aRenderer:TpvScene3DRenderer;const aRendererInstance:TpvScene3DRendererInstance;const aScene3D:TpvScene3D;const aSkyCubeMap:TVkDescriptorImageInfo;const aCached:Boolean=false);

       destructor Destroy; override;

       procedure AllocateResources(const aRenderPass:TpvVulkanRenderPass;
                                   const aWidth:TpvInt32;
                                   const aHeight:TpvInt32;
                                   const aCountSurfaceViews:TpvInt32;
                                   const aVulkanSampleCountFlagBits:TVkSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT));

       procedure ReleaseResources;

       procedure ClearHistoryImageAndPrepareLayouts(const aInFlightFrameIndex:TpvSizeInt;const aCommandBuffer:TpvVulkanCommandBuffer);
 
       procedure Draw(const aInFlightFrameIndex,aViewBaseIndex,aCountViews,aCountAllViews:TpvSizeInt;const aCommandBuffer:TpvVulkanCommandBuffer;const aOrientation:TpvMatrix4x4);

       property Cached:Boolean read fCached;

       property UseRGB9E5:Boolean read fUseRGB9E5;

     end;

implementation

{ TpvScene3DRendererSkyBox }

constructor TpvScene3DRendererSkyBox.Create(const aRenderer:TpvScene3DRenderer;const aRendererInstance:TpvScene3DRendererInstance;const aScene3D:TpvScene3D;const aSkyCubeMap:TVkDescriptorImageInfo;const aCached:Boolean=false);
var Index:TpvSizeInt;
    Stream:TStream;
    FormatProperties:TVkFormatProperties;
begin
 inherited Create;

 fRenderer:=aRenderer;

 fRendererInstance:=aRendererInstance;

 fOrientation:=TpvVector4.Null;

 fScene3D:=aScene3D;

 fCached:=aCached;

 // Auto-detect RGB9E5 support: need sampled + storage image support
 if fCached then begin
  FormatProperties:=fRenderer.VulkanDevice.PhysicalDevice.GetFormatProperties(VK_FORMAT_E5B9G9R9_UFLOAT_PACK32);
  fUseRGB9E5:=((FormatProperties.optimalTilingFeatures and TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT))<>0) and
              ((FormatProperties.optimalTilingFeatures and TVkFormatFeatureFlags(VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT))<>0);
 end else begin
  fUseRGB9E5:=false;
 end;

 fWidth:=0;
 fHeight:=0;
 fCountSurfaceViews:=0;
 fFrameIndex:=0;

 for Index:=0 to MaxInFlightFrames-1 do begin
  fHistoryImages[Index]:=nil;
  fHistoryImageLayouts[Index]:=VK_IMAGE_LAYOUT_UNDEFINED;
  fHistoryValid[Index]:=false;
 end;
 fHistorySampler:=nil;

 if fCached then begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('skybox_cached_vert.spv');
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('skybox_vert.spv');
 end;
 try
  fVertexShaderModule:=TpvVulkanShaderModule.Create(fRenderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 if fCached then begin
  if fUseRGB9E5 then begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('skybox_cached_rgb9e5_frag.spv');
  end else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('skybox_cached_rgba16f_frag.spv');
  end;
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('skybox_frag.spv');
 end;
 try
  fFragmentShaderModule:=TpvVulkanShaderModule.Create(fRenderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageVertex:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_VERTEX_BIT,fVertexShaderModule,'main');

 fVulkanPipelineShaderStageFragment:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_FRAGMENT_BIT,fFragmentShaderModule,'main');

 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fRenderer.VulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0,
                                       VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(1,
                                       VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                       []);
 if fCached then begin
  fVulkanDescriptorSetLayout.AddBinding(2,
                                        VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                        1,
                                        TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                        []);
  fVulkanDescriptorSetLayout.AddBinding(3,
                                        VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                        1,
                                        TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                        []);
 end;
 fVulkanDescriptorSetLayout.Initialize;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fRenderer.VulkanDevice,TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),fScene3D.CountInFlightFrames*3);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,fScene3D.CountInFlightFrames);
 if fCached then begin
  fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fScene3D.CountInFlightFrames*2);
  fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fScene3D.CountInFlightFrames);
 end else begin
  fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fScene3D.CountInFlightFrames);
 end;
 fVulkanDescriptorPool.Initialize;

 for Index:=0 to fScene3D.CountInFlightFrames-1 do begin
  fVulkanDescriptorSets[Index]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                              fVulkanDescriptorSetLayout);
  fVulkanDescriptorSets[Index].WriteToDescriptorSet(0,
                                                    0,
                                                    1,
                                                    TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                    [],
                                                    [fRendererInstance.VulkanViewUniformBuffers[Index].DescriptorBufferInfo],
                                                    [],
                                                    false);
  fVulkanDescriptorSets[Index].WriteToDescriptorSet(1,
                                                    0,
                                                    1,
                                                    TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                    [aSkyCubeMap],
                                                    [],
                                                    [],
                                                    false);
  // Note: binding 2 (history texture) will be written in AllocateResources when we have the images
  fVulkanDescriptorSets[Index].Flush;
 end;

 fVulkanPipelineLayout:=TpvVulkanPipelineLayout.Create(fRenderer.VulkanDevice);
 fVulkanPipelineLayout.AddPushConstantRange(TVkPipelineStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkPipelineStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),0,SizeOf(TpvScene3DRendererSkyBox.TPushConstants));
 fVulkanPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 fVulkanPipelineLayout.Initialize;

 // Create history sampler for cached mode
 if fCached then begin
  fHistorySampler:=TpvVulkanSampler.Create(fRenderer.VulkanDevice,
                                           VK_FILTER_LINEAR,
                                           VK_FILTER_LINEAR,
                                           VK_SAMPLER_MIPMAP_MODE_NEAREST,
                                           VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                           VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                           VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                           0.0,
                                           false,
                                           1.0,
                                           false,
                                           VK_COMPARE_OP_NEVER,
                                           0.0,
                                           0.0,
                                           VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK,
                                           false);
  fRenderer.VulkanDevice.DebugUtils.SetObjectName(fHistorySampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRendererSkyBox.fHistorySampler');
 end;

end;

destructor TpvScene3DRendererSkyBox.Destroy;
var Index:TpvSizeInt;
begin
 FreeAndNil(fHistorySampler);
 FreeAndNil(fVulkanPipelineLayout);
 for Index:=0 to fScene3D.CountInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[Index]);
 end;
 FreeAndNil(fVulkanDescriptorPool);
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanPipelineShaderStageVertex);
 FreeAndNil(fVulkanPipelineShaderStageFragment);
 FreeAndNil(fVertexShaderModule);
 FreeAndNil(fFragmentShaderModule);
 inherited Destroy;
end;

procedure TpvScene3DRendererSkyBox.AllocateResources(const aRenderPass:TpvVulkanRenderPass;
                                                     const aWidth:TpvInt32;
                                                     const aHeight:TpvInt32;
                                                     const aCountSurfaceViews:TpvInt32;
                                                     const aVulkanSampleCountFlagBits:TVkSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT));
var Index:TpvSizeInt;
    PreviousIndex:TpvSizeInt;
    HistoryImageInfo:TVkDescriptorImageInfo;
    NeedsRecreate:Boolean;
    HistoryImageFormat:TVkFormat;
    HistoryImageOtherFormat:TVkFormat;
begin

 // Check if we need to recreate resources due to size change
 NeedsRecreate:=(fWidth<>aWidth) or (fHeight<>aHeight) or (fCountSurfaceViews<>aCountSurfaceViews);

 // Release old resources if size changed
 if NeedsRecreate then begin
  FreeAndNil(fVulkanPipeline);
  if fCached then begin
   for Index:=0 to fScene3D.CountInFlightFrames-1 do begin
    FreeAndNil(fHistoryImages[Index]);
    fHistoryValid[Index]:=false;
   end;
  end;
 end;

 fWidth:=aWidth;

 fHeight:=aHeight;

 fCountSurfaceViews:=aCountSurfaceViews;

 // Create history images for cached mode
 if fCached then begin
  if fUseRGB9E5 then begin
   HistoryImageFormat:=VK_FORMAT_E5B9G9R9_UFLOAT_PACK32;
   HistoryImageOtherFormat:=VK_FORMAT_R32_UINT;
  end else begin
   HistoryImageFormat:=VK_FORMAT_R16G16B16A16_SFLOAT;
   HistoryImageOtherFormat:=VK_FORMAT_UNDEFINED;
  end;
  for Index:=0 to fScene3D.CountInFlightFrames-1 do begin
   if not assigned(fHistoryImages[Index]) then begin
    fHistoryImages[Index]:=TpvScene3DRendererArray2DImage.Create(fScene3D.VulkanDevice,
                                                                 fWidth,
                                                                 fHeight,
                                                                 fCountSurfaceViews,
                                                                 HistoryImageFormat,
                                                                 TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                                                 VK_IMAGE_LAYOUT_GENERAL,
                                                                 true,
                                                                 pvAllocationGroupIDScene3DSurface,
                                                                 HistoryImageOtherFormat,
                                                                 VK_SHARING_MODE_EXCLUSIVE,
                                                                 nil,
                                                                 'TpvScene3DRendererSkyBox.fHistoryImages['+IntToStr(Index)+']');
    fRenderer.VulkanDevice.DebugUtils.SetObjectName(fHistoryImages[Index].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererSkyBox.fHistoryImages['+IntToStr(Index)+'].Image');
    fRenderer.VulkanDevice.DebugUtils.SetObjectName(fHistoryImages[Index].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererSkyBox.fHistoryImages['+IntToStr(Index)+'].ImageView');
    fHistoryImageLayouts[Index]:=VK_IMAGE_LAYOUT_GENERAL;
    fHistoryValid[Index]:=false;
   end;
  end;

  // Update descriptor sets with history textures
  // Each frame reads from the previous frame's history (binding 2) and writes to current (binding 3)
  for Index:=0 to fScene3D.CountInFlightFrames-1 do begin
   PreviousIndex:=((Index-1)+fScene3D.CountInFlightFrames) mod fScene3D.CountInFlightFrames;
   // Binding 2: read from previous frame's history (use array image view for sampler2DArray)
   HistoryImageInfo.sampler:=fHistorySampler.Handle;
   HistoryImageInfo.imageView:=fHistoryImages[PreviousIndex].VulkanArrayImageView.Handle;
   HistoryImageInfo.imageLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
   fVulkanDescriptorSets[Index].WriteToDescriptorSet(2,
                                                     0,
                                                     1,
                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                     [HistoryImageInfo],
                                                     [],
                                                     [],
                                                     false);
   // Binding 3: write to current frame's history (storage image, use array view for image2DArray)
   HistoryImageInfo.sampler:=VK_NULL_HANDLE;
   if fUseRGB9E5 then begin
    // RGB9E5 uses R32_UINT alias for imageStore
    HistoryImageInfo.imageView:=fHistoryImages[Index].VulkanOtherArrayImageView.Handle;
   end else begin
    // RGBA16F uses array image view
    HistoryImageInfo.imageView:=fHistoryImages[Index].VulkanArrayImageView.Handle;
   end;
   HistoryImageInfo.imageLayout:=VK_IMAGE_LAYOUT_GENERAL;
   fVulkanDescriptorSets[Index].WriteToDescriptorSet(3,
                                                     0,
                                                     1,
                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                     [HistoryImageInfo],
                                                     [],
                                                     [],
                                                     false);
   fVulkanDescriptorSets[Index].Flush;
  end;
 end;

 fVulkanPipeline:=TpvVulkanGraphicsPipeline.Create(fRenderer.VulkanDevice,
                                                   fRenderer.VulkanPipelineCache,
                                                   0,
                                                   [],
                                                   fVulkanPipelineLayout,
                                                   aRenderPass,
                                                   0,
                                                   nil,
                                                   0);

 fVulkanPipeline.AddStage(fVulkanPipelineShaderStageVertex);
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
 if fRenderer.VelocityBufferNeeded then begin
  fVulkanPipeline.ColorBlendState.AddColorBlendAttachmentState(false,
                                                               VK_BLEND_FACTOR_ZERO,
                                                               VK_BLEND_FACTOR_ZERO,
                                                               VK_BLEND_OP_ADD,
                                                               VK_BLEND_FACTOR_ZERO,
                                                               VK_BLEND_FACTOR_ZERO,
                                                               VK_BLEND_OP_ADD,
                                                               0);
 end;

 fVulkanPipeline.DepthStencilState.DepthTestEnable:=false;
 fVulkanPipeline.DepthStencilState.DepthWriteEnable:=false;
 fVulkanPipeline.DepthStencilState.DepthCompareOp:=VK_COMPARE_OP_ALWAYS;
 fVulkanPipeline.DepthStencilState.DepthBoundsTestEnable:=false;
 fVulkanPipeline.DepthStencilState.StencilTestEnable:=false;

 fVulkanPipeline.Initialize;

 fVulkanPipeline.FreeMemory;

end;

procedure TpvScene3DRendererSkyBox.ReleaseResources;
var Index:TpvSizeInt;
begin
 FreeAndNil(fVulkanPipeline);
 if fCached then begin
  for Index:=0 to fScene3D.CountInFlightFrames-1 do begin
   FreeAndNil(fHistoryImages[Index]);
   fHistoryImageLayouts[Index]:=VK_IMAGE_LAYOUT_UNDEFINED;
   fHistoryValid[Index]:=false;
  end;
 end;
end;

procedure TpvScene3DRendererSkyBox.ClearHistoryImageAndPrepareLayouts(const aInFlightFrameIndex:TpvSizeInt;const aCommandBuffer:TpvVulkanCommandBuffer);
var ImageMemoryBarriers:array[0..1] of TVkImageMemoryBarrier;
    ClearColorValue:TVkClearColorValue;
    ImageSubresourceRange:TVkImageSubresourceRange;
    PreviousIndex:TpvSizeInt;
    BarrierCount:TpvInt32;
begin

 // For cached mode: prepare history images before rendering
 // 1. Clear current frame's history image to 0 (sentinel for unwritten pixels)
 // 2. Transition previous frame's history to SHADER_READ_ONLY for reading

 if fCached and (fWidth>0) and (fHeight>0) and (fCountSurfaceViews>0) and assigned(fHistoryImages[aInFlightFrameIndex]) then begin

  fScene3D.VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'SkyBox.ClearHistoryImageAndPrepareLayouts',[0.25,0.75,0.75,1.0]);

  // Calculate previous frame index 
  PreviousIndex:=(aInFlightFrameIndex-1)+fScene3D.CountInFlightFrames;
  if PreviousIndex>=fScene3D.CountInFlightFrames then begin
   if (fScene3D.CountInFlightFrames and (fScene3D.CountInFlightFrames-1))=0 then begin
    PreviousIndex:=PreviousIndex and (fScene3D.CountInFlightFrames-1);
   end else begin
    while PreviousIndex>=fScene3D.CountInFlightFrames do begin
     dec(PreviousIndex,fScene3D.CountInFlightFrames);
    end;
   end;
  end;

  // Transition current frame's history to TRANSFER_DST for clear
  FillChar(ImageMemoryBarriers,SizeOf(ImageMemoryBarriers),#0);
  ImageMemoryBarriers[0].sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  case fHistoryImageLayouts[aInFlightFrameIndex] of
   VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:begin
    ImageMemoryBarriers[0].srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
   end;
   VK_IMAGE_LAYOUT_GENERAL:begin
    ImageMemoryBarriers[0].srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
   end;
   VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL:begin
    ImageMemoryBarriers[0].srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
   end;
   else begin
    ImageMemoryBarriers[0].srcAccessMask:=0;
   end;
  end;
  ImageMemoryBarriers[0].dstAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
  ImageMemoryBarriers[0].oldLayout:=fHistoryImageLayouts[aInFlightFrameIndex];
  ImageMemoryBarriers[0].newLayout:=VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
  ImageMemoryBarriers[0].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarriers[0].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarriers[0].image:=fHistoryImages[aInFlightFrameIndex].VulkanImage.Handle;
  ImageMemoryBarriers[0].subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarriers[0].subresourceRange.baseMipLevel:=0;
  ImageMemoryBarriers[0].subresourceRange.levelCount:=1;
  ImageMemoryBarriers[0].subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarriers[0].subresourceRange.layerCount:=fCountSurfaceViews;
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);

  // Clear current frame's history to 0
  FillChar(ClearColorValue,SizeOf(TVkClearColorValue),#0);
  FillChar(ImageSubresourceRange,SizeOf(TVkImageSubresourceRange),#0);
  ImageSubresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageSubresourceRange.baseMipLevel:=0;
  ImageSubresourceRange.levelCount:=1;
  ImageSubresourceRange.baseArrayLayer:=0;
  ImageSubresourceRange.layerCount:=fCountSurfaceViews;
  aCommandBuffer.CmdClearColorImage(fHistoryImages[aInFlightFrameIndex].VulkanImage.Handle,
                                    VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                                    @ClearColorValue,
                                    1,
                                    @ImageSubresourceRange);

  // Batch transitions:
  // 0: Current frame: TRANSFER_DST -> GENERAL (for shader write)
  // 1: Previous frame: GENERAL -> SHADER_READ_ONLY (for reading during skybox draw)
  // 2: Frame-before-previous: SHADER_READ_ONLY -> GENERAL (was left in READ_ONLY from last frame)
  FillChar(ImageMemoryBarriers,SizeOf(ImageMemoryBarriers),#0);
  BarrierCount:=0;

  // Current frame: TRANSFER_DST -> GENERAL
  ImageMemoryBarriers[BarrierCount].sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarriers[BarrierCount].srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
  ImageMemoryBarriers[BarrierCount].dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarriers[BarrierCount].oldLayout:=VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
  ImageMemoryBarriers[BarrierCount].newLayout:=VK_IMAGE_LAYOUT_GENERAL;
  ImageMemoryBarriers[BarrierCount].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarriers[BarrierCount].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarriers[BarrierCount].image:=fHistoryImages[aInFlightFrameIndex].VulkanImage.Handle;
  ImageMemoryBarriers[BarrierCount].subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarriers[BarrierCount].subresourceRange.baseMipLevel:=0;
  ImageMemoryBarriers[BarrierCount].subresourceRange.levelCount:=1;
  ImageMemoryBarriers[BarrierCount].subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarriers[BarrierCount].subresourceRange.layerCount:=fCountSurfaceViews;
  inc(BarrierCount);

  // Previous frame: transition to SHADER_READ_ONLY for reading during skybox draw
  // Skip if already in correct layout
  if fHistoryImageLayouts[PreviousIndex]<>VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL then begin
   ImageMemoryBarriers[BarrierCount].sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
   case fHistoryImageLayouts[PreviousIndex] of
    VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:begin
     ImageMemoryBarriers[BarrierCount].srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
    end;
    VK_IMAGE_LAYOUT_GENERAL:begin
     ImageMemoryBarriers[BarrierCount].srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
    end;
    else begin
     ImageMemoryBarriers[BarrierCount].srcAccessMask:=0;
    end;
   end;
   ImageMemoryBarriers[BarrierCount].dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
   ImageMemoryBarriers[BarrierCount].oldLayout:=fHistoryImageLayouts[PreviousIndex];
   ImageMemoryBarriers[BarrierCount].newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
   ImageMemoryBarriers[BarrierCount].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
   ImageMemoryBarriers[BarrierCount].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
   ImageMemoryBarriers[BarrierCount].image:=fHistoryImages[PreviousIndex].VulkanImage.Handle;
   ImageMemoryBarriers[BarrierCount].subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
   ImageMemoryBarriers[BarrierCount].subresourceRange.baseMipLevel:=0;
   ImageMemoryBarriers[BarrierCount].subresourceRange.levelCount:=1;
   ImageMemoryBarriers[BarrierCount].subresourceRange.baseArrayLayer:=0;
   ImageMemoryBarriers[BarrierCount].subresourceRange.layerCount:=fCountSurfaceViews;
   fHistoryImageLayouts[PreviousIndex]:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
   inc(BarrierCount);
  end;

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    BarrierCount,@ImageMemoryBarriers[0]);

  // Update tracked layout for current frame (now in GENERAL after the barrier above)
  fHistoryImageLayouts[aInFlightFrameIndex]:=VK_IMAGE_LAYOUT_GENERAL;

  fScene3D.VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

 end;

end;

procedure TpvScene3DRendererSkyBox.Draw(const aInFlightFrameIndex,aViewBaseIndex,aCountViews,aCountAllViews:TpvSizeInt;const aCommandBuffer:TpvVulkanCommandBuffer;const aOrientation:TpvMatrix4x4);
var PushConstants:TpvScene3DRendererSkyBox.TPushConstants;
begin

 fScene3D.VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'Skybox',[0.25,0.75,0.75,1.0]);

 PushConstants.PreviousOrientation:=fOrientation;
 fOrientation:=aOrientation.ToQuaternion.Vector;
 PushConstants.CurrentOrientation:=fOrientation;

 if PushConstants.PreviousOrientation.DistanceTo(fOrientation)>0.1 then begin
  PushConstants.PreviousOrientation:=fOrientation;
 end;

 PushConstants.LightDirection:=TpvVector4.InlineableCreate(fScene3D.PrimaryLightDirection,0.0);

 PushConstants.ViewBaseIndex:=aViewBaseIndex;
 PushConstants.CountViews:=aCountViews;
 PushConstants.SkyBoxBrightnessFactor:=fScene3D.SkyBoxBrightnessFactor;
 PushConstants.WidthHeight:=(fWidth and $ffff) or (fHeight shl 16);

 if (fScene3D.SkyBoxMode=TpvScene3DEnvironmentMode.Texture) and assigned(fScene3D.SkyBoxTextureImage) then begin
  PushConstants.Mode:=0;
 end else begin
  case fScene3D.SkyBoxMode of
   TpvScene3DEnvironmentMode.Starlight:begin
    PushConstants.Mode:=1;
   end;
   TpvScene3DEnvironmentMode.TransparentColorKey:begin
    PushConstants.Mode:=2;
   end;
   else begin
    PushConstants.Mode:=0;
   end;
  end;
 end;

 PushConstants.CountAllViews:=aCountAllViews;
 PushConstants.FrameIndex:=fFrameIndex;

 PushConstants.SkyBoxIntensityFactor:=fScene3D.SkyBoxIntensityFactor;

 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,fVulkanPipeline.Handle);

 aCommandBuffer.CmdPushConstants(fVulkanPipelineLayout.Handle,
                                 TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_FRAGMENT_BIT),
                                 0,
                                 SizeOf(TpvScene3DRendererSkyBox.TPushConstants),
                                 @PushConstants);

 aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                      fVulkanPipelineLayout.Handle,
                                      0,
                                      1,
                                      @fVulkanDescriptorSets[aInFlightFrameIndex].Handle,
                                      0,
                                      nil);

 if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
  fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.Draw,'SkyBoxDraw');
 end;
 aCommandBuffer.CmdDraw(36,1,0,0);
 if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
  fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
 end;

 if fCached then begin
  fHistoryValid[aInFlightFrameIndex]:=true;
  inc(fFrameIndex);
 end;

 fScene3D.VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

end;

end.
