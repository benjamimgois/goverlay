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
unit PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationSurfelComputePass;
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
     PasVulkan.Scene3D.Planet,
     PasVulkan.Scene3D.Renderer.Globals,
     PasVulkan.Scene3D.Renderer,
     PasVulkan.Scene3D.Renderer.Instance,
     PasVulkan.Scene3D.Renderer.IBLDescriptor;

const TpvScene3DRendererPassesGlobalIlluminationSurfelComputePassMaxPlanetTextures=32; // per-planet blend/grass map array size (set 2), indexed by planet object index

type { TpvScene3DRendererPassesGlobalIlluminationSurfelComputePass }
     // Single combined compute pass that runs the whole per-frame surfel GI update against the scene TLAS: clear the hash
     // grid + per-frame stats, (re)build the grid from the live surfels, spawn new surfels where the camera depth buffer
     // reveals insufficient coverage, trace + integrate radiance per surfel, and recycle stale surfels (rebuilding the
     // free list for the next frame). The five stages are separate compute pipelines sharing one pipeline layout,
     // separated by memory barriers. Runs AFTER the depth prepass (spawn reads the depth buffer) and BEFORE the shading
     // passes that sample the surfel field (they depend on this pass explicitly).
     TpvScene3DRendererPassesGlobalIlluminationSurfelComputePass=class(TpvFrameGraph.TComputePass)
      public
       type TPushConstants=record
             Params:TpvUInt32Vector4; // trace: x=frameIndex, y=raysPerSurfel; spawn: x=viewLayer, y=tileStride, z=frameIndex
             Misc:TpvVector4;         // trace: x=maxRayDistance, y=multiBounceStrength, z=hysteresis
             EmissiveGI:TpvVector4;   // trace: x=global GI emissive scale, y=global GI emissive max (z/w reserved); other dispatches ignore it
            end;
            PPushConstants=^TPushConstants;
            TSpawnView=record
             ViewMatrix:TpvMatrix4x4;
             ProjectionMatrix:TpvMatrix4x4;
             InverseViewMatrix:TpvMatrix4x4;
             InverseProjectionMatrix:TpvMatrix4x4;
            end;
            PSpawnView=^TSpawnView;
      private
       fInstance:TpvScene3DRendererInstance;
       fComputeShaderModuleClear:TpvVulkanShaderModule;
       fComputeShaderModuleGridBuild:TpvVulkanShaderModule;
       fComputeShaderModuleSpawn:TpvVulkanShaderModule;
       fComputeShaderModuleTrace:TpvVulkanShaderModule;
       fComputeShaderModuleRecycle:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageComputeClear:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageComputeGridBuild:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageComputeSpawn:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageComputeTrace:TpvVulkanPipelineShaderStage;
       fVulkanPipelineShaderStageComputeRecycle:TpvVulkanPipelineShaderStage;
       fResourceDepth:TpvFrameGraph.TPass.TUsedImageResource;
       fDescriptorPool:TpvVulkanDescriptorPool;
       fSurfelDescriptorSetLayout:TpvVulkanDescriptorSetLayout;            // set 1: UBO + 5 SSBOs + 6 env cubemaps
       fSurfelDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fSpawnDescriptorSetLayout:TpvVulkanDescriptorSetLayout;             // set 3: spawn view UBO + depth sampler
       fSpawnDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fSpawnViewBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanBuffer; // per in-flight spawn view matrices UBO
       fDepthImageViews:array[0..MaxInFlightFrames-1] of TpvVulkanImageView;
       fPlanetTexturesDescriptorSetLayout:TpvVulkanDescriptorSetLayout;    // set 2: per-planet blend/grass maps (bindless)
       fPlanetTexturesDescriptorPool:TpvVulkanDescriptorPool;
       fPlanetTexturesDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fBlendInfos:TVkDescriptorImageInfoArray;
       fGrassInfos:TVkDescriptorImageInfoArray;
       fIBLDescriptors:array[0..MaxInFlightFrames-1] of TpvScene3DRendererIBLDescriptor; // set 1 binding 6 (env A + env B) for sky-on-miss
       fPipelineLayout:TpvVulkanPipelineLayout;
       fPipelineClear:TpvVulkanComputePipeline;
       fPipelineGridBuild:TpvVulkanComputePipeline;
       fPipelineSpawn:TpvVulkanComputePipeline;
       fPipelineTrace:TpvVulkanComputePipeline;
       fPipelineRecycle:TpvVulkanComputePipeline;
       fCleared:boolean; // false until the persistent pool/stats/free-list have been zeroed once (they are not cleared on allocation)
      public
       constructor Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance); reintroduce;
       destructor Destroy; override;
       procedure AcquirePersistentResources; override;
       procedure ReleasePersistentResources; override;
       procedure AcquireVolatileResources; override;
       procedure ReleaseVolatileResources; override;
       procedure Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt); override;
       procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt); override;
      published
     end;

implementation

const SurfelSpawnTileStride=4; // one spawn candidate per 4x4 pixel tile

{ TpvScene3DRendererPassesGlobalIlluminationSurfelComputePass }

constructor TpvScene3DRendererPassesGlobalIlluminationSurfelComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
 inherited Create(aFrameGraph);
 fInstance:=aInstance;
 Name:='GlobalIlluminationSurfelComputePass';
 // The spawn stage reconstructs world positions/normals from the camera depth buffer, so this pass depends on the depth
 // prepass output; the shading passes that read the surfel field depend on this pass in turn (set up in Instance.pas).
 if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
  fResourceDepth:=AddImageInput('resourcetype_depth','resource_depth_data',VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,[TpvFrameGraph.TResourceTransition.TFlag.Attachment]);
 end else begin
  fResourceDepth:=AddImageInput('resourcetype_msaa_depth','resource_msaa_depth_data',VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,[TpvFrameGraph.TResourceTransition.TFlag.Attachment]);
 end;
end;

destructor TpvScene3DRendererPassesGlobalIlluminationSurfelComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationSurfelComputePass.AcquirePersistentResources;
 function Load(const aName:string):TpvVulkanShaderModule;
 var Stream:TStream;
 begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile(aName);
  try
   result:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
 end;
begin
 inherited AcquirePersistentResources;
 fComputeShaderModuleClear:=Load('gi_surfel_clear_comp.spv');
 fComputeShaderModuleGridBuild:=Load('gi_surfel_grid_build_comp.spv');
 fComputeShaderModuleSpawn:=Load('gi_surfel_spawn_comp.spv');
 fComputeShaderModuleTrace:=Load('gi_surfel_trace_comp.spv');
 fComputeShaderModuleRecycle:=Load('gi_surfel_recycle_comp.spv');
 fVulkanPipelineShaderStageComputeClear:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModuleClear,'main');
 fVulkanPipelineShaderStageComputeGridBuild:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModuleGridBuild,'main');
 fVulkanPipelineShaderStageComputeSpawn:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModuleSpawn,'main');
 fVulkanPipelineShaderStageComputeTrace:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModuleTrace,'main');
 fVulkanPipelineShaderStageComputeRecycle:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModuleRecycle,'main');
end;

procedure TpvScene3DRendererPassesGlobalIlluminationSurfelComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStageComputeClear);
 FreeAndNil(fVulkanPipelineShaderStageComputeGridBuild);
 FreeAndNil(fVulkanPipelineShaderStageComputeSpawn);
 FreeAndNil(fVulkanPipelineShaderStageComputeTrace);
 FreeAndNil(fVulkanPipelineShaderStageComputeRecycle);
 FreeAndNil(fComputeShaderModuleClear);
 FreeAndNil(fComputeShaderModuleGridBuild);
 FreeAndNil(fComputeShaderModuleSpawn);
 FreeAndNil(fComputeShaderModuleTrace);
 FreeAndNil(fComputeShaderModuleRecycle);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationSurfelComputePass.AcquireVolatileResources;
var InFlightFrameIndex:TpvInt32;
begin

 inherited AcquireVolatileResources;

 fCleared:=false;

 fDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                 TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                 fInstance.Renderer.CountInFlightFrames*2);
 fDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,fInstance.Renderer.CountInFlightFrames*2); // surfel UBO (set 1) + spawn view UBO (set 3)
 fDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,fInstance.Renderer.CountInFlightFrames*5); // pool, grid cells, grid counts, stats, free list
 fDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fInstance.Renderer.CountInFlightFrames*(6+1)); // 6 env cubemaps (set 1) + depth (set 3)
 fDescriptorPool.Initialize;

 // Set 1 = surfel resources (UBO + 5 SSBOs + 6 environment cubemaps for sky-on-miss).
 fSurfelDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fSurfelDescriptorSetLayout.AddBinding(0,VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
 fSurfelDescriptorSetLayout.AddBinding(1,VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
 fSurfelDescriptorSetLayout.AddBinding(2,VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
 fSurfelDescriptorSetLayout.AddBinding(3,VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
 fSurfelDescriptorSetLayout.AddBinding(4,VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
 fSurfelDescriptorSetLayout.AddBinding(5,VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
 fSurfelDescriptorSetLayout.AddBinding(6,VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,6,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
 fSurfelDescriptorSetLayout.Initialize;

 // Set 3 = spawn view UBO + camera depth buffer.
 fSpawnDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fSpawnDescriptorSetLayout.AddBinding(0,VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
 fSpawnDescriptorSetLayout.AddBinding(1,VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
 fSpawnDescriptorSetLayout.Initialize;

 // Set 2 = per-planet blend/grass maps (bindless, partially bound), indexed by planet object index (mirrors the DDGI pass).
 fPlanetTexturesDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice,0,true);
 fPlanetTexturesDescriptorSetLayout.AddBinding(0,VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,TpvScene3DRendererPassesGlobalIlluminationSurfelComputePassMaxPlanetTextures,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[],TVkDescriptorBindingFlags(VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT_EXT));
 fPlanetTexturesDescriptorSetLayout.AddBinding(1,VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,TpvScene3DRendererPassesGlobalIlluminationSurfelComputePassMaxPlanetTextures,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[],TVkDescriptorBindingFlags(VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT_EXT));
 fPlanetTexturesDescriptorSetLayout.Initialize;

 fPlanetTexturesDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                               TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                               fInstance.Renderer.CountInFlightFrames);
 fPlanetTexturesDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fInstance.Renderer.CountInFlightFrames*2*TpvScene3DRendererPassesGlobalIlluminationSurfelComputePassMaxPlanetTextures);
 fPlanetTexturesDescriptorPool.Initialize;

 fPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants));
 fPipelineLayout.AddDescriptorSetLayout(fInstance.Scene3D.GlobalVulkanDescriptorSetLayout); // set 0 = global scene (TLAS, lights, materials, textures)
 fPipelineLayout.AddDescriptorSetLayout(fSurfelDescriptorSetLayout);                        // set 1 = surfel resources + env maps
 fPipelineLayout.AddDescriptorSetLayout(fPlanetTexturesDescriptorSetLayout);                // set 2 = per-planet blend/grass maps
 fPipelineLayout.AddDescriptorSetLayout(fSpawnDescriptorSetLayout);                         // set 3 = spawn view + depth
 fPipelineLayout.Initialize;

 fPipelineClear:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,fInstance.Renderer.VulkanPipelineCache,0,fVulkanPipelineShaderStageComputeClear,fPipelineLayout,nil,0);
 fPipelineGridBuild:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,fInstance.Renderer.VulkanPipelineCache,0,fVulkanPipelineShaderStageComputeGridBuild,fPipelineLayout,nil,0);
 fPipelineSpawn:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,fInstance.Renderer.VulkanPipelineCache,0,fVulkanPipelineShaderStageComputeSpawn,fPipelineLayout,nil,0);
 fPipelineTrace:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,fInstance.Renderer.VulkanPipelineCache,0,fVulkanPipelineShaderStageComputeTrace,fPipelineLayout,nil,0);
 fPipelineRecycle:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,fInstance.Renderer.VulkanPipelineCache,0,fVulkanPipelineShaderStageComputeRecycle,fPipelineLayout,nil,0);

 for InFlightFrameIndex:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin

  fSpawnViewBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(fInstance.Renderer.VulkanDevice,
                                                               SizeOf(TSpawnView),
                                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                               [],
                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                               0,0,0,0,0,0,
                                                               [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                               0,
                                                               pvAllocationGroupIDScene3DStatic,
                                                               'TpvScene3DRendererPassesGlobalIlluminationSurfelComputePass.fSpawnViewBuffers['+IntToStr(InFlightFrameIndex)+']');

  fDepthImageViews[InFlightFrameIndex]:=TpvVulkanImageView.Create(fInstance.Renderer.VulkanDevice,
                                                                  fResourceDepth.VulkanImages[InFlightFrameIndex],
                                                                  TVkImageViewType(VK_IMAGE_VIEW_TYPE_2D_ARRAY),
                                                                  TpvFrameGraph.TImageResourceType(fResourceDepth.ResourceType).Format,
                                                                  VK_COMPONENT_SWIZZLE_IDENTITY,VK_COMPONENT_SWIZZLE_IDENTITY,VK_COMPONENT_SWIZZLE_IDENTITY,VK_COMPONENT_SWIZZLE_IDENTITY,
                                                                  TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT),
                                                                  0,1,0,fInstance.CountSurfaceViews);

  // Set 1
  fSurfelDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fDescriptorPool,fSurfelDescriptorSetLayout);
  fSurfelDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),[],[fInstance.GlobalIlluminationSurfelUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false);
  fSurfelDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.GlobalIlluminationSurfelPoolBuffer.DescriptorBufferInfo],[],false);
  fSurfelDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.GlobalIlluminationSurfelGridCellBuffer.DescriptorBufferInfo],[],false);
  fSurfelDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.GlobalIlluminationSurfelGridCellCountBuffer.DescriptorBufferInfo],[],false);
  fSurfelDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.GlobalIlluminationSurfelStatsBuffer.DescriptorBufferInfo],[],false);
  fSurfelDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.GlobalIlluminationSurfelFreeListBuffer.DescriptorBufferInfo],[],false);
  // Placeholder env-map write (overwritten by the IBL descriptor below), so the initial Flush has binding 6 fully written.
  fSurfelDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(6,0,6,TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                 [fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.GGXDescriptorImageInfo,
                                                                  fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.CharlieDescriptorImageInfo,
                                                                  fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.LambertianDescriptorImageInfo,
                                                                  fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.GGXDescriptorImageInfo,
                                                                  fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.CharlieDescriptorImageInfo,
                                                                  fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.LambertianDescriptorImageInfo],[],[],false);
  fSurfelDescriptorSets[InFlightFrameIndex].Flush;

  fIBLDescriptors[InFlightFrameIndex]:=TpvScene3DRendererIBLDescriptor.Create(fInstance.Renderer.VulkanDevice,fSurfelDescriptorSets[InFlightFrameIndex],6,fInstance.Renderer.ClampedSampler.Handle);
  fIBLDescriptors[InFlightFrameIndex].SetFrom(fInstance.Scene3D,fInstance,InFlightFrameIndex);
  fIBLDescriptors[InFlightFrameIndex].Update(true);

  // Set 3
  fSpawnDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fDescriptorPool,fSpawnDescriptorSetLayout);
  fSpawnDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),[],[fSpawnViewBuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false);
  fSpawnDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                               [TVkDescriptorImageInfo.Create(fInstance.Renderer.ClampedSampler.Handle,fDepthImageViews[InFlightFrameIndex].Handle,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],[],[],false);
  fSpawnDescriptorSets[InFlightFrameIndex].Flush;

  // Set 2 (created empty here, repopulated each frame in Update()).
  fPlanetTexturesDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fPlanetTexturesDescriptorPool,fPlanetTexturesDescriptorSetLayout);

 end;

end;

procedure TpvScene3DRendererPassesGlobalIlluminationSurfelComputePass.ReleaseVolatileResources;
var InFlightFrameIndex:TpvInt32;
begin
 FreeAndNil(fPipelineClear);
 FreeAndNil(fPipelineGridBuild);
 FreeAndNil(fPipelineSpawn);
 FreeAndNil(fPipelineTrace);
 FreeAndNil(fPipelineRecycle);
 FreeAndNil(fPipelineLayout);
 for InFlightFrameIndex:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fIBLDescriptors[InFlightFrameIndex]);
  FreeAndNil(fSurfelDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fSpawnDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fPlanetTexturesDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fSpawnViewBuffers[InFlightFrameIndex]);
  FreeAndNil(fDepthImageViews[InFlightFrameIndex]);
 end;
 FreeAndNil(fSurfelDescriptorSetLayout);
 FreeAndNil(fSpawnDescriptorSetLayout);
 FreeAndNil(fPlanetTexturesDescriptorSetLayout);
 FreeAndNil(fDescriptorPool);
 FreeAndNil(fPlanetTexturesDescriptorPool);
 fBlendInfos:=nil;
 fGrassInfos:=nil;
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationSurfelComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
var Planets:TpvScene3DPlanets;
    Planet:TpvScene3DPlanet;
    PlanetIndex,Count,Capacity:TpvSizeInt;
    Sampler:TpvVulkanSampler;
    Data:TpvScene3DPlanet.TData;
    SpawnView:TSpawnView;
    InFlightFrameState:TpvScene3DRendererInstance.PInFlightFrameState;
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);

 // Refresh the sky-on-miss environment cubemaps for this in-flight frame.
 if assigned(fIBLDescriptors[aUpdateInFlightFrameIndex]) then begin
  fIBLDescriptors[aUpdateInFlightFrameIndex].SetFrom(fInstance.Scene3D,fInstance,aUpdateInFlightFrameIndex);
  fIBLDescriptors[aUpdateInFlightFrameIndex].Update(true);
 end;

 // Spawn view matrices for the primary view (the spawn stage reconstructs world pos/normal from this view's depth). The
 // projection matrix is recovered from MainViewProjectionMatrix = MainViewMatrix * ProjectionMatrix.
 InFlightFrameState:=@fInstance.InFlightFrameStates^[aUpdateInFlightFrameIndex];
 SpawnView.ViewMatrix:=InFlightFrameState^.MainViewMatrix;
 SpawnView.InverseViewMatrix:=InFlightFrameState^.MainInverseViewMatrix;
 SpawnView.ProjectionMatrix:=InFlightFrameState^.MainInverseViewMatrix*InFlightFrameState^.MainViewProjectionMatrix;
 SpawnView.InverseProjectionMatrix:=SpawnView.ProjectionMatrix.Inverse;
 if assigned(fSpawnViewBuffers[aUpdateInFlightFrameIndex]) then begin
  fSpawnViewBuffers[aUpdateInFlightFrameIndex].UpdateData(SpawnView,0,SizeOf(TSpawnView));
 end;

 // Per-planet blend/grass maps (slot index = planet list index = planet object index), mirroring the DDGI pass.
 if not assigned(fPlanetTexturesDescriptorSets[aUpdateInFlightFrameIndex]) then begin
  exit;
 end;
 Sampler:=fInstance.Scene3D.GeneralComputeSampler;
 Count:=0;
 Planets:=TpvScene3DPlanets(fInstance.Scene3D.Planets);
 Planets.Lock.AcquireRead;
 try
  for PlanetIndex:=0 to Min(Planets.Count,TpvScene3DRendererPassesGlobalIlluminationSurfelComputePassMaxPlanetTextures)-1 do begin
   Planet:=Planets.Items[PlanetIndex];
   Data:=Planet.InFlightFrameDataList[aUpdateInFlightFrameIndex];
   if Planet.Ready and assigned(Data) and assigned(Data.BlendMapImage) and assigned(Data.GrassMapImage) then begin
    if length(fBlendInfos)<=Count then begin
     Capacity:=RoundUpToPowerOfTwoSizeUInt(Count+1);
     SetLength(fBlendInfos,Capacity);
     SetLength(fGrassInfos,Capacity);
    end;
    fBlendInfos[Count]:=TVkDescriptorImageInfo.Create(Sampler.Handle,Data.BlendMapImage.VulkanArrayImageView.Handle,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
    fGrassInfos[Count]:=TVkDescriptorImageInfo.Create(Sampler.Handle,Data.GrassMapImage.VulkanImageView.Handle,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
    inc(Count);
   end else begin
    break;
   end;
  end;
 finally
  Planets.Lock.ReleaseRead;
 end;
 if Count>0 then begin
  fPlanetTexturesDescriptorSets[aUpdateInFlightFrameIndex].WriteToDescriptorSet(0,0,Count,TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),fBlendInfos,[],[],false);
  fPlanetTexturesDescriptorSets[aUpdateInFlightFrameIndex].WriteToDescriptorSet(1,0,Count,TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),fGrassInfos,[],[],false);
  fPlanetTexturesDescriptorSets[aUpdateInFlightFrameIndex].Flush;
 end;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationSurfelComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var PushConstants:TPushConstants;
    UniformBufferData:TpvScene3DRendererInstance.TGlobalIlluminationSurfelUniformBufferData;
    DescriptorSets:array[0..3] of TVkDescriptorSet;
    SpawnGroupsX,SpawnGroupsY:TpvInt32;
 procedure FullMemoryBarrier;
 var MemoryBarrier:TVkMemoryBarrier;
 begin
  MemoryBarrier:=TVkMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                         TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT));
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,1,@MemoryBarrier,0,nil,0,nil);
 end;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 // Fill the per-frame surfel uniform buffer (static config + frame index; the frame index drives the parity free-list
 // bank and the recycle age). Done here because the global frame index is available in Execute.
 UniformBufferData.CameraPositionCellSize:=TpvVector4.InlineableCreate(0.0,0.0,0.0,2.0);    // w = base hash cell size (m); >= surfel radius so a single-cell gather covers a point
 UniformBufferData.CountsFrame.x:=TpvScene3DRendererInstance.GlobalIlluminationSurfelMaxCount;
 UniformBufferData.CountsFrame.y:=TpvScene3DRendererInstance.GlobalIlluminationSurfelHashCellCount;
 UniformBufferData.CountsFrame.z:=TpvScene3DRendererInstance.GlobalIlluminationSurfelMaxPerCell;
 UniformBufferData.CountsFrame.w:=TpvUInt32(aFrameIndex);
 UniformBufferData.Params:=TpvVector4.InlineableCreate(1.0,0.95,256.0,1.0);                  // radius, hysteresis, recycle frame age, spawn coverage threshold
 fInstance.GlobalIlluminationSurfelUniformBuffers[aInFlightFrameIndex].UpdateData(UniformBufferData,0,SizeOf(TpvScene3DRendererInstance.TGlobalIlluminationSurfelUniformBufferData));

 // One-time zero of the persistent pool / stats / free-list (not cleared on allocation). After this, the per-frame clear
 // stage maintains the grid counts + spawn cursor + write-bank free count, and recycle rebuilds the free list.
 if not fCleared then begin
  fCleared:=true;
  aCommandBuffer.CmdFillBuffer(fInstance.GlobalIlluminationSurfelPoolBuffer.Handle,0,VK_WHOLE_SIZE,0);
  aCommandBuffer.CmdFillBuffer(fInstance.GlobalIlluminationSurfelStatsBuffer.Handle,0,VK_WHOLE_SIZE,0);
  aCommandBuffer.CmdFillBuffer(fInstance.GlobalIlluminationSurfelFreeListBuffer.Handle,0,VK_WHOLE_SIZE,0);
  aCommandBuffer.CmdFillBuffer(fInstance.GlobalIlluminationSurfelGridCellCountBuffer.Handle,0,VK_WHOLE_SIZE,0);
  FullMemoryBarrier; // transfer write -> shader read/write (the compute stages below read these buffers)
 end;

 DescriptorSets[0]:=fInstance.Scene3D.GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle;
 DescriptorSets[1]:=fSurfelDescriptorSets[aInFlightFrameIndex].Handle;
 DescriptorSets[2]:=fPlanetTexturesDescriptorSets[aInFlightFrameIndex].Handle;
 DescriptorSets[3]:=fSpawnDescriptorSets[aInFlightFrameIndex].Handle;
 aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,fPipelineLayout.Handle,0,4,@DescriptorSets[0],0,nil);

 // 1) Clear hash grid counts + per-frame stats (one thread per hash cell).
 PushConstants.Params.x:=TpvUInt32(aFrameIndex);
 PushConstants.Params.y:=0;
 PushConstants.Params.z:=0;
 PushConstants.Params.w:=0;
 PushConstants.Misc:=TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0);
 aCommandBuffer.CmdPushConstants(fPipelineLayout.Handle,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants),@PushConstants);
 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipelineClear.Handle);
 aCommandBuffer.CmdDispatch((TpvScene3DRendererInstance.GlobalIlluminationSurfelHashCellCount+255) shr 8,1,1);
 FullMemoryBarrier;

 // 2) Build the hash grid from the live surfels (one thread per surfel slot).
 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipelineGridBuild.Handle);
 aCommandBuffer.CmdDispatch((TpvScene3DRendererInstance.GlobalIlluminationSurfelMaxCount+255) shr 8,1,1);
 FullMemoryBarrier;

 // 3) Spawn new surfels in under-covered screen tiles (one thread per tile of the primary view's depth buffer).
 PushConstants.Params.x:=0;                                  // view layer 0
 PushConstants.Params.y:=TpvUInt32(SurfelSpawnTileStride);   // tile stride
 PushConstants.Params.z:=TpvUInt32(aFrameIndex);             // frame index
 PushConstants.Params.w:=0;
 aCommandBuffer.CmdPushConstants(fPipelineLayout.Handle,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants),@PushConstants);
 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipelineSpawn.Handle);
 SpawnGroupsX:=((((fInstance.ScaledWidth+(SurfelSpawnTileStride-1)) div SurfelSpawnTileStride)+7) shr 3);
 SpawnGroupsY:=((((fInstance.ScaledHeight+(SurfelSpawnTileStride-1)) div SurfelSpawnTileStride)+7) shr 3);
 aCommandBuffer.CmdDispatch(Max(1,SpawnGroupsX),Max(1,SpawnGroupsY),1);
 FullMemoryBarrier;

 // 4) Trace + integrate radiance per surfel (one thread per surfel slot).
 PushConstants.Params.x:=TpvUInt32(aFrameIndex);
 PushConstants.Params.y:=TpvScene3DRendererInstance.GlobalIlluminationSurfelRaysPerSurfel;
 PushConstants.Params.z:=0;
 PushConstants.Params.w:=0;
 PushConstants.Misc:=TpvVector4.InlineableCreate(1e6,0.5,0.95,0.0); // max ray distance, multi-bounce strength (0.5: full 1.0 feedback ~= direct/(1-albedo) washes out bright/high-albedo scenes), hysteresis
 // Global GI emissive master regulators (renderer-wide); the gather clamps emission to min(emission*matFactor*x, matMax, y).
 PushConstants.EmissiveGI:=TpvVector4.InlineableCreate(fInstance.Renderer.GlobalIlluminationEmissiveScale,fInstance.Renderer.GlobalIlluminationEmissiveMaximum,0.0,0.0);
 aCommandBuffer.CmdPushConstants(fPipelineLayout.Handle,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants),@PushConstants);
 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipelineTrace.Handle);
 aCommandBuffer.CmdDispatch((TpvScene3DRendererInstance.GlobalIlluminationSurfelMaxCount+63) shr 6,1,1);
 FullMemoryBarrier;

 // 5) Recycle stale surfels + rebuild the free list for the next frame (one thread per surfel slot).
 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipelineRecycle.Handle);
 aCommandBuffer.CmdDispatch((TpvScene3DRendererInstance.GlobalIlluminationSurfelMaxCount+255) shr 8,1,1);

 // Publish the surfel field writes to the later shading stages (mesh/planet fragment shaders sample the pool + grid).
 FullMemoryBarrier;

end;

end.
