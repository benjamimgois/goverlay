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
unit PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationDDGITraceComputePass;
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

const TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePassMaxPlanetTextures=32; // per-planet blend/grass map array size (set 2), indexed by planet object index

type { TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePass }
     // DDGI ray-tracing PRODUCER pass: traces GI_DDGI_RAYS_PER_PROBE rays per probe against the scene TLAS (via the shared
     // gi_rt_gather.glsl layer) and writes the shaded radiance + distance into the ray-data image. It is the swappable
     // "trace technique" half of DDGI (RTXGI's ProbeTraceRGS analog); everything downstream depends only on the ray-data
     // image, not on how it was produced. The technique-agnostic blend lives in the separate ProbeUpdate compute pass.
     TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePass=class(TpvFrameGraph.TComputePass)
      public
       type TPushConstants=record
             RandomRotation0:TpvVector4;         // mat3 column 0 in xyz
             RandomRotation1:TpvVector4;         // mat3 column 1 in xyz
             RandomRotation2:TpvVector4;         // mat3 column 2 in xyz
             Params:TpvUInt32Vector4;            // x = frameIndex, y = countCascades, z = probesPerCascade, w = raysPerProbe
             Blend:TpvVector4;                   // y = multi-bounce feedback strength (0 on a slot's first frame); x/z unused by the trace (the update owns them)
             EmissiveGIParticleCount:TpvVector4; // x = global GI emissive scale, y = global GI emissive max, z = particle count — must match gi_ddgi_pushconstants.glsl
             ParticleBVH:TpvUInt32Vector4;       // particle LBVH device addresses: xy = emitter buffer (uvec2), zw = node buffer (uvec2); 0 when inactive
            end;
            PPushConstants=^TPushConstants;
      private
       fInstance:TpvScene3DRendererInstance;
       fComputeShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStage:TpvVulkanPipelineShaderStage;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fPlanetTexturesDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fPlanetTexturesDescriptorPool:TpvVulkanDescriptorPool;
       fPlanetTexturesDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fBlendInfos:TVkDescriptorImageInfoArray;
       fGrassInfos:TVkDescriptorImageInfoArray;
       fIBLDescriptors:array[0..MaxInFlightFrames-1] of TpvScene3DRendererIBLDescriptor; // set 1 binding 4 (6 env cubemaps) for sky-on-miss
       fPipelineLayout:TpvVulkanPipelineLayout;
       fPipeline:TpvVulkanComputePipeline;
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

{ TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePass }

constructor TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
 inherited Create(aFrameGraph);
 fInstance:=aInstance;
 Name:='GlobalIlluminationDDGITraceComputePass';
end;

destructor TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePass.AcquirePersistentResources;
var Stream:TStream;
begin
 inherited AcquirePersistentResources;
 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('gi_ddgi_trace_comp.spv');
 try
  fComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;
 fVulkanPipelineShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModule,'main');
end;

procedure TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStage);
 FreeAndNil(fComputeShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePass.AcquireVolatileResources;
var InFlightFrameIndex:TpvInt32;
begin

 inherited AcquireVolatileResources;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,fInstance.Renderer.CountInFlightFrames); // binding 0 = ddgiData SSBO
 if TpvScene3DRendererInstance.GlobalIlluminationDDGIStorageOctahedral then begin
  fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fInstance.Renderer.CountInFlightFrames*2); // binding 2 = oct irradiance read + binding 3 = visibility read
 end else begin
  fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fInstance.Renderer.CountInFlightFrames); // binding 3 = visibility read only (SH irradiance is a BDA buffer via the master)
 end;
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fInstance.Renderer.CountInFlightFrames*6);
 fVulkanDescriptorPool.Initialize;

 // Set 1 = DDGI resources used by the trace: UBO, irradiance (read for multi-bounce), visibility (read for multi-bounce),
 // 6 environment cubemaps (sky-on-miss). Ray-data is now a BDA buffer via the master push constant (binding 1 freed).
 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0,VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]); // binding 0 = ddgiData SSBO (cascade globals + sub-buffer pointers)
 if TpvScene3DRendererInstance.GlobalIlluminationDDGIStorageOctahedral then begin
  fVulkanDescriptorSetLayout.AddBinding(2,VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]); // oct irradiance read (multi-bounce); SH irradiance is a BDA buffer via the master
 end;
 fVulkanDescriptorSetLayout.AddBinding(3,VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
 fVulkanDescriptorSetLayout.AddBinding(4,VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,6,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
 // probe-data (formerly binding 5) is now reached via the master push constant (BDA buffer), no image binding.
 fVulkanDescriptorSetLayout.Initialize;

 // Set 2 = per-planet octahedral blend/grass maps (bindless, partially bound), indexed by planet object index.
 fPlanetTexturesDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice,0,true);
 fPlanetTexturesDescriptorSetLayout.AddBinding(0,VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePassMaxPlanetTextures,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[],TVkDescriptorBindingFlags(VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT_EXT));
 fPlanetTexturesDescriptorSetLayout.AddBinding(1,VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePassMaxPlanetTextures,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[],TVkDescriptorBindingFlags(VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT_EXT));
 fPlanetTexturesDescriptorSetLayout.Initialize;

 fPlanetTexturesDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                               TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                               fInstance.Renderer.CountInFlightFrames);
 fPlanetTexturesDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,fInstance.Renderer.CountInFlightFrames*2*TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePassMaxPlanetTextures);
 fPlanetTexturesDescriptorPool.Initialize;

 fPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants));
 fPipelineLayout.AddDescriptorSetLayout(fInstance.Scene3D.GlobalVulkanDescriptorSetLayout); // set 0 = global scene (TLAS, lights, materials, textures)
 fPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);                        // set 1 = DDGI trace resources
 fPipelineLayout.AddDescriptorSetLayout(fPlanetTexturesDescriptorSetLayout);                // set 2 = per-planet blend/grass maps
 fPipelineLayout.Initialize;

 fPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,fInstance.Renderer.VulkanPipelineCache,0,fVulkanPipelineShaderStage,fPipelineLayout,nil,0);

 for InFlightFrameIndex:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin

  fVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,fVulkanDescriptorSetLayout);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.GlobalIlluminationDDGIMasterBuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false); // binding 0 = ddgiData SSBO
  // Particle LBVH is reached by device address pushed in the push constants (BDA) — no descriptor binding here.
  // binding 1 (ray-data) + SH irradiance are BDA buffers reached via the master push constant; binding 2 = oct irradiance only.
  if TpvScene3DRendererInstance.GlobalIlluminationDDGIStorageOctahedral then begin
   fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                  [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,fInstance.GlobalIlluminationDDGIIrradianceOctImages[InFlightFrameIndex].VulkanImageView.Handle,VK_IMAGE_LAYOUT_GENERAL)],[],[],false);
  end;
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                 [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,fInstance.GlobalIlluminationDDGIVisibilityMomentsImages[InFlightFrameIndex].VulkanImageView.Handle,VK_IMAGE_LAYOUT_GENERAL)],[],[],false);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,0,6,TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                 [fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.GGXDescriptorImageInfo,
                                                                  fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.CharlieDescriptorImageInfo,
                                                                  fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.LambertianDescriptorImageInfo,
                                                                  fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.GGXDescriptorImageInfo,
                                                                  fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.CharlieDescriptorImageInfo,
                                                                  fInstance.Renderer.ImageBasedLightingEnvMapCubeMaps.LambertianDescriptorImageInfo],[],[],false);
  // probe-data (formerly binding 5) is now reached via the master push constant (BDA buffer), no descriptor write.
  fVulkanDescriptorSets[InFlightFrameIndex].Flush;

  fIBLDescriptors[InFlightFrameIndex]:=TpvScene3DRendererIBLDescriptor.Create(fInstance.Renderer.VulkanDevice,fVulkanDescriptorSets[InFlightFrameIndex],4,fInstance.Renderer.ClampedSampler.Handle);
  fIBLDescriptors[InFlightFrameIndex].SetFrom(fInstance.Scene3D,fInstance,InFlightFrameIndex);
  fIBLDescriptors[InFlightFrameIndex].Update(true);

  fPlanetTexturesDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fPlanetTexturesDescriptorPool,fPlanetTexturesDescriptorSetLayout);

 end;

end;

procedure TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePass.ReleaseVolatileResources;
var InFlightFrameIndex:TpvInt32;
begin
 FreeAndNil(fPipeline);
 FreeAndNil(fPipelineLayout);
 for InFlightFrameIndex:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fIBLDescriptors[InFlightFrameIndex]);
  FreeAndNil(fVulkanDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fPlanetTexturesDescriptorSets[InFlightFrameIndex]);
 end;
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanDescriptorPool);
 FreeAndNil(fPlanetTexturesDescriptorSetLayout);
 FreeAndNil(fPlanetTexturesDescriptorPool);
 fBlendInfos:=nil;
 fGrassInfos:=nil;
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
var Planets:TpvScene3DPlanets;
    Planet:TpvScene3DPlanet;
    PlanetIndex,Count,Capacity:TpvSizeInt;
    Sampler:TpvVulkanSampler;
    Data:TpvScene3DPlanet.TData;
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);

 if assigned(fIBLDescriptors[aUpdateInFlightFrameIndex]) then begin
  fIBLDescriptors[aUpdateInFlightFrameIndex].SetFrom(fInstance.Scene3D,fInstance,aUpdateInFlightFrameIndex);
  fIBLDescriptors[aUpdateInFlightFrameIndex].Update(true);
 end;

 if not assigned(fPlanetTexturesDescriptorSets[aUpdateInFlightFrameIndex]) then begin
  exit;
 end;

 Sampler:=fInstance.Scene3D.GeneralComputeSampler;

 Count:=0;
 Planets:=TpvScene3DPlanets(fInstance.Scene3D.Planets);
 Planets.Lock.AcquireRead;
 try
  for PlanetIndex:=0 to Min(Planets.Count,TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePassMaxPlanetTextures)-1 do begin
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

procedure TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
const TotalProbes=TpvScene3DRendererInstance.CountGlobalIlluminationDDGICascades*TpvScene3DRendererInstance.GlobalIlluminationDDGIProbesPerCascade;
var PushConstants:TPushConstants;
    DescriptorSets:array[0..2] of TVkDescriptorSet;
    Quaternion:TpvQuaternion;
    RotationMatrix:TpvMatrix3x3;
    BufferMemoryBarrier:TVkBufferMemoryBarrier;
    FinalMemoryBarrier:TVkMemoryBarrier;
    ParticleEmitterAddress,ParticleNodeAddress:TVkDeviceAddress;
    ParticleCount:TpvUInt32;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 // A new pseudo-random rotation per frame so the spherical-Fibonacci ray set covers the whole sphere over several frames.
 // Deterministic from the frame index so the trace and the probe-update pass agree on it (both reconstruct directions).
 Quaternion:=TpvQuaternion.CreateFromAngleAxis((aFrameIndex*2.39996323)+0.5,TpvVector3.InlineableCreate(0.5774,0.5774,0.5774).Normalize);
 RotationMatrix:=TpvMatrix3x3.CreateFromQuaternion(Quaternion);

 PushConstants.RandomRotation0:=TpvVector4.InlineableCreate(RotationMatrix.RawComponents[0,0],RotationMatrix.RawComponents[0,1],RotationMatrix.RawComponents[0,2],0.0);
 PushConstants.RandomRotation1:=TpvVector4.InlineableCreate(RotationMatrix.RawComponents[1,0],RotationMatrix.RawComponents[1,1],RotationMatrix.RawComponents[1,2],0.0);
 PushConstants.RandomRotation2:=TpvVector4.InlineableCreate(RotationMatrix.RawComponents[2,0],RotationMatrix.RawComponents[2,1],RotationMatrix.RawComponents[2,2],0.0);

 PushConstants.Params.x:=TpvUInt32(aFrameIndex);
 PushConstants.Params.y:=TpvScene3DRendererInstance.CountGlobalIlluminationDDGICascades;
 PushConstants.Params.z:=TpvScene3DRendererInstance.GlobalIlluminationDDGIProbesPerCascade;
 PushConstants.Params.w:=TpvScene3DRendererInstance.GlobalIlluminationDDGIRaysPerProbe;

 // Multi-bounce feedback strength: 0 on this slot's first frame (the previous probe field is uninitialized garbage), else
 // full. The first-frame state is shared with the probe-update pass (which flips it false after writing the probes).
 if fInstance.GlobalIlluminationDDGIFirstFrames[aInFlightFrameIndex] then begin
  PushConstants.Blend:=TpvVector4.InlineableCreate(0.97,0.0,1.0,0.0);
 end else begin
  PushConstants.Blend:=TpvVector4.InlineableCreate(0.97,1.0,0.0,0.0);
 end;

 // Particle LBVH (technique-neutral subsystem, reached by device address): alive count + emitter/node buffer addresses. Zero
 // when inactive or the buffers don't exist for this slot, so the shader's particleCount==0 guard disables the injection.
 ParticleEmitterAddress:=0;
 ParticleNodeAddress:=0;
 ParticleCount:=0;
 if assigned(fInstance.ParticleBVH) and fInstance.ParticleBVH.Active and assigned(fInstance.ParticleBVH.NodeBuffers[aInFlightFrameIndex]) and assigned(fInstance.ParticleBVH.EmitterBuffers[aInFlightFrameIndex]) then begin
  ParticleEmitterAddress:=fInstance.ParticleBVH.EmitterBuffers[aInFlightFrameIndex].DeviceAddress;
  ParticleNodeAddress:=fInstance.ParticleBVH.NodeBuffers[aInFlightFrameIndex].DeviceAddress;
  ParticleCount:=Min(TpvSizeInt(fInstance.Scene3D.CountInFlightFrameParticleVertices[aInFlightFrameIndex] div 3),TpvSizeInt(TpvScene3D.MaxParticles));
 end;

 // Global GI emissive master regulators (renderer-wide); the gather clamps emission to min(emission*matFactor*x, matMax, y).

 // EmissiveGIParticleCount.z carries the alive particle count (exactly representable as float since it is <= MaxParticles = 65536).
 PushConstants.EmissiveGIParticleCount:=TpvVector4.InlineableCreate(fInstance.Renderer.GlobalIlluminationEmissiveScale,
                                                       fInstance.Renderer.GlobalIlluminationEmissiveMaximum,
                                                       ParticleCount,
                                                       0.0);

 PushConstants.ParticleBVH.x:=TpvUInt32(ParticleEmitterAddress and TpvUInt64($ffffffff));
 PushConstants.ParticleBVH.y:=TpvUInt32(ParticleEmitterAddress shr 32);
 PushConstants.ParticleBVH.z:=TpvUInt32(ParticleNodeAddress and TpvUInt64($ffffffff));
 PushConstants.ParticleBVH.w:=TpvUInt32(ParticleNodeAddress shr 32);

 // Make the host/transfer write of the ddgiData buffer's per-frame cascade globals visible to the compute shader (SSBO read).
 BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_HOST_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                    TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                    VK_QUEUE_FAMILY_IGNORED,VK_QUEUE_FAMILY_IGNORED,
                                                    fInstance.GlobalIlluminationDDGIMasterBuffers[aInFlightFrameIndex].Handle,0,VK_WHOLE_SIZE);
 aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   0,0,nil,1,@BufferMemoryBarrier,0,nil);

 DescriptorSets[0]:=fInstance.Scene3D.GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle;
 DescriptorSets[1]:=fVulkanDescriptorSets[aInFlightFrameIndex].Handle;
 DescriptorSets[2]:=fPlanetTexturesDescriptorSets[aInFlightFrameIndex].Handle;
 aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,fPipelineLayout.Handle,0,3,@DescriptorSets[0],0,nil);
 aCommandBuffer.CmdPushConstants(fPipelineLayout.Handle,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants),@PushConstants);

 // Trace: one thread per (ray, probe). local_size_x = 32.
 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipeline.Handle);
 aCommandBuffer.CmdDispatch((TpvScene3DRendererInstance.GlobalIlluminationDDGIRaysPerProbe+31) shr 5,TotalProbes,1);

 // Publish the ray-data writes to the probe-update pass (it reads the ray-data image). The frame graph orders the passes;
 // this memory barrier makes the writes visible (both passes keep the image in VK_IMAGE_LAYOUT_GENERAL).
 FinalMemoryBarrier:=TVkMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                             TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT));
 aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   0,1,@FinalMemoryBarrier,0,nil,0,nil);

end;

end.
