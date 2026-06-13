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
unit PasVulkan.Scene3D.Renderer.Passes.EASURCASComputePass;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}

// EASU+RCAS (Edge-Adaptive Spatial Upsampling + Robust Contrast-Adaptive Sharpening)
// A two-pass compute shader upscaler inspired by AMD's FidelityFX Super Resolution 1.0.
//
// Pass 1 (EASU): Reads the scaled-resolution color input, detects edges via luminance
//                gradients, and shapes a directional Lanczos2 kernel that elongates
//                along edges. Writes to an intermediate full-resolution image.
//
// Pass 2 (RCAS): Reads the EASU output at full resolution and applies contrast-adaptive
//                sharpening using a 5-tap cross pattern. High-contrast edges get minimal
//                sharpening; low-contrast areas get more to recover detail. Writes the
//                final upsampled output.
//
// Both passes operate as compute shaders with 16x16 workgroups. MULTIVIEW support is
// handled via the Z dimension of the dispatch.

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

type { TpvScene3DRendererPassesEASURCASComputePass }
     TpvScene3DRendererPassesEASURCASComputePass=class(TpvFrameGraph.TComputePass)
      private
       type TRCASPushConstants=packed record
             Sharpness:TpvFloat;
            end;
      private
       fInstance:TpvScene3DRendererInstance;
       fResourceInput:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceOutput:TpvFrameGraph.TPass.TUsedImageResource;
      private
       // Shader modules
       fEASUShaderModule:TpvVulkanShaderModule;
       fRCASShaderModule:TpvVulkanShaderModule;
       // Pipeline shader stages
       fEASUShaderStage:TpvVulkanPipelineShaderStage;
       fRCASShaderStage:TpvVulkanPipelineShaderStage;
      private
       // EASU resources (pass 1: source -> intermediate)
       fEASUDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fEASUPipelineLayout:TpvVulkanPipelineLayout;
       fEASUPipeline:TpvVulkanComputePipeline;
       fEASUDescriptorPool:TpvVulkanDescriptorPool;
       fEASUInputImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
       fEASUOutputImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
       fEASUDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
      private
       // Intermediate full-resolution image (EASU output / RCAS input)
       fIntermediateImages:array[0..MaxInFlightFrames-1] of TpvVulkanImage;
       fIntermediateImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
       fIntermediateMemoryBlocks:array[0..MaxInFlightFrames-1] of TpvVulkanDeviceMemoryBlock;
       fIntermediateImageReady:array[0..MaxInFlightFrames-1] of Boolean;
      private
       // RCAS resources (pass 2: intermediate -> output)
       fRCASDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fRCASPipelineLayout:TpvVulkanPipelineLayout;
       fRCASPipeline:TpvVulkanComputePipeline;
       fRCASDescriptorPool:TpvVulkanDescriptorPool;
       fRCASOutputImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
       fRCASDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
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

{ TpvScene3DRendererPassesEASURCASComputePass }

constructor TpvScene3DRendererPassesEASURCASComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin

 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='EASURCASComputePass';

 fResourceInput:=AddImageInput(fInstance.LastOutputResource.ResourceType.Name,
                               fInstance.LastOutputResource.Resource.Name,
                               VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                               []
                              );

 fResourceOutput:=AddImageOutput('resourcetype_color_fullres_optimized_non_alpha',
                                 'resource_upsampled_color',
                                 VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                 TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.DontCare),
                                 []
                                );

 fInstance.LastOutputResource:=fResourceOutput;

end;

destructor TpvScene3DRendererPassesEASURCASComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesEASURCASComputePass.AcquirePersistentResources;
var Stream:TStream;
begin

 inherited AcquirePersistentResources;

 // Load EASU shader module
 if fInstance.CountSurfaceViews>1 then begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('resampling_easu_multiview_comp.spv');
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('resampling_easu_comp.spv');
 end;
 try
  fEASUShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fEASUShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'EASURCAS.EASUShader');

 // Load RCAS shader module
 if fInstance.CountSurfaceViews>1 then begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('resampling_rcas_multiview_comp.spv');
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('resampling_rcas_comp.spv');
 end;
 try
  fRCASShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fRCASShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'EASURCAS.RCASShader');

 // Create pipeline shader stages
 fEASUShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fEASUShaderModule,'main');
 fRCASShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fRCASShaderModule,'main');

end;

procedure TpvScene3DRendererPassesEASURCASComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fRCASShaderStage);
 FreeAndNil(fEASUShaderStage);
 FreeAndNil(fRCASShaderModule);
 FreeAndNil(fEASUShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesEASURCASComputePass.AcquireVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
    FullWidth,FullHeight:TpvInt32;
    CountViews:TpvInt32;
    ImageViewType:TVkImageViewType;
    MemoryRequirements:TVkMemoryRequirements;
begin

 inherited AcquireVolatileResources;

 FullWidth:=fInstance.Width;
 FullHeight:=fInstance.Height;
 CountViews:=fInstance.CountSurfaceViews;

 if CountViews>1 then begin
  ImageViewType:=VK_IMAGE_VIEW_TYPE_2D_ARRAY;
 end else begin
  ImageViewType:=VK_IMAGE_VIEW_TYPE_2D;
 end;

 ///////////////////////////////////////////
 // EASU descriptor set layout            //
 // binding 0 = combined image sampler    //
 // binding 1 = storage image (write)     //
 ///////////////////////////////////////////

 fEASUDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fEASUDescriptorSetLayout.AddBinding(0,
                                     VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                     1,
                                     TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                     []);
 fEASUDescriptorSetLayout.AddBinding(1,
                                     VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                     1,
                                     TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                     []);
 fEASUDescriptorSetLayout.Initialize;

 // EASU pipeline layout (no push constants needed)
 fEASUPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fEASUPipelineLayout.AddDescriptorSetLayout(fEASUDescriptorSetLayout);
 fEASUPipelineLayout.Initialize;

 // EASU compute pipeline
 fEASUPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                fInstance.Renderer.VulkanPipelineCache,
                                                0,
                                                fEASUShaderStage,
                                                fEASUPipelineLayout,
                                                nil,
                                                0);
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fEASUPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'EASURCAS.EASUPipeline');

 ///////////////////////////////////////////
 // RCAS descriptor set layout            //
 // binding 0 = combined image sampler    //
 // binding 1 = storage image (write)     //
 ///////////////////////////////////////////

 fRCASDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fRCASDescriptorSetLayout.AddBinding(0,
                                     VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                     1,
                                     TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                     []);
 fRCASDescriptorSetLayout.AddBinding(1,
                                     VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                     1,
                                     TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                     []);
 fRCASDescriptorSetLayout.Initialize;

 // RCAS pipeline layout (with push constants for sharpness)
 fRCASPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fRCASPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TRCASPushConstants));
 fRCASPipelineLayout.AddDescriptorSetLayout(fRCASDescriptorSetLayout);
 fRCASPipelineLayout.Initialize;

 // RCAS compute pipeline
 fRCASPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                fInstance.Renderer.VulkanPipelineCache,
                                                0,
                                                fRCASShaderStage,
                                                fRCASPipelineLayout,
                                                nil,
                                                0);
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fRCASPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'EASURCAS.RCASPipeline');

 ///////////////////////////////////////////
 // Intermediate images (EASU output)     //
 ///////////////////////////////////////////

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin

  // Create intermediate image at full resolution
  fIntermediateImages[InFlightFrameIndex]:=TpvVulkanImage.Create(fInstance.Renderer.VulkanDevice,
                                                                 0,
                                                                 VK_IMAGE_TYPE_2D,
                                                                 VK_FORMAT_R16G16B16A16_SFLOAT,
                                                                 FullWidth,
                                                                 FullHeight,
                                                                 1,
                                                                 1,
                                                                 CountViews,
                                                                 VK_SAMPLE_COUNT_1_BIT,
                                                                 VK_IMAGE_TILING_OPTIMAL,
                                                                 TVkImageUsageFlags(VK_IMAGE_USAGE_STORAGE_BIT) or
                                                                 TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                                                 VK_SHARING_MODE_EXCLUSIVE,
                                                                 0,
                                                                 nil,
                                                                 VK_IMAGE_LAYOUT_UNDEFINED);
  fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fIntermediateImages[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_IMAGE,'EASURCAS.Intermediate['+IntToStr(InFlightFrameIndex)+']');

  // Allocate and bind memory
  fInstance.Renderer.VulkanDevice.Commands.GetImageMemoryRequirements(fInstance.Renderer.VulkanDevice.Handle,
                                                                     fIntermediateImages[InFlightFrameIndex].Handle,
                                                                     @MemoryRequirements);

  fIntermediateMemoryBlocks[InFlightFrameIndex]:=fInstance.Renderer.VulkanDevice.MemoryManager.AllocateMemoryBlock([],
                                                                                                                  MemoryRequirements.size,
                                                                                                                  MemoryRequirements.alignment,
                                                                                                                  MemoryRequirements.memoryTypeBits,
                                                                                                                  TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                                  0,
                                                                                                                  0,
                                                                                                                  0,
                                                                                                                  0,
                                                                                                                  0,
                                                                                                                  0,
                                                                                                                  0,
                                                                                                                  TpvVulkanDeviceMemoryAllocationType.ImageOptimal,
                                                                                                                  nil,
                                                                                                                  pvAllocationGroupIDScene3DDynamic,
                                                                                                                  'EASURCAS.IntermediateMemory['+IntToStr(InFlightFrameIndex)+']');

  VulkanCheckResult(fInstance.Renderer.VulkanDevice.Commands.BindImageMemory(fInstance.Renderer.VulkanDevice.Handle,
                                                                            fIntermediateImages[InFlightFrameIndex].Handle,
                                                                            fIntermediateMemoryBlocks[InFlightFrameIndex].MemoryChunk.Handle,
                                                                            fIntermediateMemoryBlocks[InFlightFrameIndex].Offset));

  // Create image view for the intermediate image
  fIntermediateImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(fInstance.Renderer.VulkanDevice,
                                                                        fIntermediateImages[InFlightFrameIndex],
                                                                        ImageViewType,
                                                                        VK_FORMAT_R16G16B16A16_SFLOAT,
                                                                        VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                        VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                        VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                        VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                        TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                        0,
                                                                        1,
                                                                        0,
                                                                        CountViews
                                                                       );
  fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fIntermediateImageViews[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'EASURCAS.IntermediateView['+IntToStr(InFlightFrameIndex)+']');

 end;

 ///////////////////////////////////////////
 // Descriptor pools and sets             //
 ///////////////////////////////////////////

 // EASU descriptor pool
 fEASUDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                     TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                     FrameGraph.CountInFlightFrames);
 fEASUDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,FrameGraph.CountInFlightFrames);
 fEASUDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,FrameGraph.CountInFlightFrames);
 fEASUDescriptorPool.Initialize;

 // RCAS descriptor pool
 fRCASDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                     TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                     FrameGraph.CountInFlightFrames);
 fRCASDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,FrameGraph.CountInFlightFrames);
 fRCASDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,FrameGraph.CountInFlightFrames);
 fRCASDescriptorPool.Initialize;

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin

  // EASU input image view (from the scaled-resolution color)
  fEASUInputImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(fInstance.Renderer.VulkanDevice,
                                                                      fResourceInput.VulkanImages[InFlightFrameIndex],
                                                                      ImageViewType,
                                                                      TpvFrameGraph.TImageResourceType(fResourceInput.ResourceType).Format,
                                                                      VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                      VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                      VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                      VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                      TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                      0,
                                                                      1,
                                                                      0,
                                                                      CountViews
                                                                     );

  // EASU output = intermediate image (already created above as storage image view)
  fEASUOutputImageViews[InFlightFrameIndex]:=fIntermediateImageViews[InFlightFrameIndex]; // Reuse the same view

  // EASU descriptor set: binding 0 = source sampler, binding 1 = intermediate storage image
  fEASUDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fEASUDescriptorPool,
                                                                        fEASUDescriptorSetLayout);
  fEASUDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                               0,
                                                               1,
                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                               [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,
                                                                                              fEASUInputImageViews[InFlightFrameIndex].Handle,
                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                               [],
                                                               [],
                                                               false
                                                              );
  fEASUDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                               0,
                                                               1,
                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                               [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                              fIntermediateImageViews[InFlightFrameIndex].Handle,
                                                                                              VK_IMAGE_LAYOUT_GENERAL)],
                                                               [],
                                                               [],
                                                               false
                                                              );
  fEASUDescriptorSets[InFlightFrameIndex].Flush;

  // RCAS output image view (final output)
  fRCASOutputImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(fInstance.Renderer.VulkanDevice,
                                                                       fResourceOutput.VulkanImages[InFlightFrameIndex],
                                                                       ImageViewType,
                                                                       TpvFrameGraph.TImageResourceType(fResourceOutput.ResourceType).Format,
                                                                       VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                       VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                       VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                       VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                       TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                       0,
                                                                       1,
                                                                       0,
                                                                       CountViews
                                                                      );

  // RCAS descriptor set: binding 0 = intermediate sampler, binding 1 = output storage image
  fRCASDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fRCASDescriptorPool,
                                                                        fRCASDescriptorSetLayout);
  fRCASDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                               0,
                                                               1,
                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                               [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedNearestSampler.Handle,
                                                                                              fIntermediateImageViews[InFlightFrameIndex].Handle,
                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                               [],
                                                               [],
                                                               false
                                                              );
  fRCASDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                               0,
                                                               1,
                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                               [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                              fRCASOutputImageViews[InFlightFrameIndex].Handle,
                                                                                              VK_IMAGE_LAYOUT_GENERAL)],
                                                               [],
                                                               [],
                                                               false
                                                              );
  fRCASDescriptorSets[InFlightFrameIndex].Flush;

 end;

end;

procedure TpvScene3DRendererPassesEASURCASComputePass.ReleaseVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin

 for InFlightFrameIndex:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fRCASDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fRCASOutputImageViews[InFlightFrameIndex]);
  FreeAndNil(fEASUDescriptorSets[InFlightFrameIndex]);
  // Don't free fEASUOutputImageViews - they alias fIntermediateImageViews
  FreeAndNil(fEASUInputImageViews[InFlightFrameIndex]);
  FreeAndNil(fIntermediateImageViews[InFlightFrameIndex]);
  FreeAndNil(fIntermediateImages[InFlightFrameIndex]);
  if assigned(fIntermediateMemoryBlocks[InFlightFrameIndex]) then begin
   fIntermediateMemoryBlocks[InFlightFrameIndex].Free;
   fIntermediateMemoryBlocks[InFlightFrameIndex]:=nil;
  end;
 end;

 FreeAndNil(fRCASDescriptorPool);
 FreeAndNil(fEASUDescriptorPool);

 FreeAndNil(fRCASPipeline);
 FreeAndNil(fRCASPipelineLayout);
 FreeAndNil(fRCASDescriptorSetLayout);

 FreeAndNil(fEASUPipeline);
 FreeAndNil(fEASUPipelineLayout);
 FreeAndNil(fEASUDescriptorSetLayout);

 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesEASURCASComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesEASURCASComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var FullWidth,FullHeight:TpvInt32;
    CountViews:TpvInt32;
    RCASPushConstants:TRCASPushConstants;
    ImageMemoryBarrier:TVkImageMemoryBarrier;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 FullWidth:=fInstance.Width;
 FullHeight:=fInstance.Height;
 CountViews:=fInstance.CountSurfaceViews;

 ///////////////////////////////////////////
 // Step 0: Transition intermediate image //
 //         from UNDEFINED to GENERAL     //
 ///////////////////////////////////////////

 begin

  FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarrier.srcAccessMask:=0;
  ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_UNDEFINED;
  ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_GENERAL;
  ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.image:=fIntermediateImages[aInFlightFrameIndex].Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=1;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=CountViews;
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarrier);
 end;

 ///////////////////////////////////////////
 // Step 1: EASU (upsampling)             //
 //   Source -> Intermediate (full res)   //
 ///////////////////////////////////////////

 begin

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fEASUPipeline.Handle);

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       fEASUPipelineLayout.Handle,
                                       0,
                                       1,
                                       @fEASUDescriptorSets[aInFlightFrameIndex].Handle,
                                       0,
                                       nil);

  if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
   fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.Dispatch,'EASU');
  end;
  aCommandBuffer.CmdDispatch(Max(1,(FullWidth+15) shr 4),
                             Max(1,(FullHeight+15) shr 4),
                             CountViews);
  if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
   fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
  end;

 end;

 ///////////////////////////////////////////
 // Barrier: EASU write -> RCAS read     //
 // Transition intermediate: GENERAL ->  //
 //   SHADER_READ_ONLY_OPTIMAL           //
 ///////////////////////////////////////////

 begin

  FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
  ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.image:=fIntermediateImages[aInFlightFrameIndex].Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=1;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=CountViews;
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarrier);

 end;

 ///////////////////////////////////////////
 // Transition output image: current ->  //
 //   GENERAL for storage image write    //
 ///////////////////////////////////////////

 begin

  FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarrier.srcAccessMask:=0;
  ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_GENERAL;
  ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.image:=fResourceOutput.VulkanImages[aInFlightFrameIndex].Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=1;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=CountViews;
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarrier);
 end;

 ///////////////////////////////////////////
 // Step 2: RCAS (sharpening)             //
 //   Intermediate -> Output (full res)   //
 ///////////////////////////////////////////

 begin

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fRCASPipeline.Handle);

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       fRCASPipelineLayout.Handle,
                                       0,
                                       1,
                                       @fRCASDescriptorSets[aInFlightFrameIndex].Handle,
                                       0,
                                       nil);

  // Push RCAS sharpness constant, pre-computed as exp2(-stops) for the shader.
  // RCASSharpness is in stops: 0 = max sharpening, higher = less sharp.
  RCASPushConstants.Sharpness:=Exp2(-fInstance.Renderer.RCASSharpness);

  aCommandBuffer.CmdPushConstants(fRCASPipelineLayout.Handle,
                                  TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TRCASPushConstants),
                                  @RCASPushConstants);

  if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
   fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.Dispatch,'RCAS');
  end;
  aCommandBuffer.CmdDispatch(Max(1,(FullWidth+15) shr 4),
                             Max(1,(FullHeight+15) shr 4),
                             CountViews);
  if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
   fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
  end;

 end;

 ///////////////////////////////////////////
 // Transition output image back:        //
 //   GENERAL -> SHADER_READ_ONLY_OPTIMAL//
 ///////////////////////////////////////////

 begin

  FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_GENERAL;
  ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.image:=fResourceOutput.VulkanImages[aInFlightFrameIndex].Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=1;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=CountViews;
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarrier);

 end;

end;

end.
