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
unit PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationDDGIStageComputePass;
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

type { TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass }
     // ONE DDGI probe BLEND/update stage as its own frame-graph compute pass. The technique-agnostic ProbeUpdate CORE
     // (RTXGI's ProbeBlendingCS analog) is split into one pass per shader stage — irradiance, visibility, border, and (when
     // GlobalIlluminationDDGIProbeRelocation is on) relocation + classification — so each shader gets its own GPU timer and
     // shows up as a separate per-pass entry in the F8 profiler overlay. The stages chain linearly through explicit frame
     // graph dependencies; every pass publishes its writes with a memory barrier so the next stage sees them, and the LAST
     // stage additionally publishes to the fragment shading stages and flips the shared firstFrames flag. All stages share
     // the same set-1 descriptor layout (UBO + irradiance[OCT] + visibility images) and push-constant layout — they differ
     // only in which shader/pipeline they bind and the dispatch dimensions. Ray-data / probe-data / SH-irradiance are BDA
     // buffers reached through the master push constant.
     TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass=class(TpvFrameGraph.TComputePass)
      public
       type TStage=
             (
              Irradiance,     // one thread per probe; integrates the random rays into the irradiance (SH buffer or OCT atlas)
              GlossyRadiance, // one workgroup per probe; integrates the rays into the octahedral GLOSSY prefiltered-radiance atlas (only when GlobalIlluminationDDGIGlossyRadiance)
              Visibility,     // one workgroup per probe; integrates hit distances into the octahedral mean/mean^2/sky atlas
              Border,         // one workgroup per probe; copies the octahedral guard bands
              Relocation,     // one thread per probe; RTXGI-style offset out of geometry (relocation only)
              Classification  // one thread per probe; marks probes mostly seeing backfaces INACTIVE (relocation only)
             );
            TPushConstants=record
             RandomRotation0:TpvVector4;         // mat3 column 0 in xyz - must match the trace's rotation (reconstructs the ray directions)
             RandomRotation1:TpvVector4;         // mat3 column 1 in xyz
             RandomRotation2:TpvVector4;         // mat3 column 2 in xyz
             Params:TpvUInt32Vector4;            // x = frameIndex, y = countCascades, z = probesPerCascade, w = raysPerProbe
             Blend:TpvVector4;                   // x = hysteresis, z = firstFrame (1 = ignore the uninitialized previous probe data); y/w unused here
             EmissiveGIParticleCount:TpvVector4; // unused by the update stages; present only to byte-match the shared gi_ddgi_pushconstants.glsl block
             ParticleBVH:TpvUInt32Vector4;       // unused by the update stages; present only to byte-match the shared gi_ddgi_pushconstants.glsl block
            end;
            PPushConstants=^TPushConstants;
      private
       fInstance:TpvScene3DRendererInstance;
       fStage:TStage;
       fFinalStage:boolean; // the last stage in the chain flips the shared firstFrames flag + publishes the probe writes to the fragment shading stages
       fComputeShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStage:TpvVulkanPipelineShaderStage;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fWarmupFrameCounts:array[0..MaxInFlightFrames-1] of TpvInt32; // per in-flight slot: frames since (re)init, for the convergence warmup hysteresis ramp (kept per-pass; stays in sync since every stage runs the same per-frame logic)
       fPipelineLayout:TpvVulkanPipelineLayout;
       fPipeline:TpvVulkanComputePipeline;
      public
       constructor Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance;const aStage:TStage;const aFinalStage:boolean); reintroduce;
       destructor Destroy; override;
       procedure AcquirePersistentResources; override;
       procedure ReleasePersistentResources; override;
       procedure AcquireVolatileResources; override;
       procedure ReleaseVolatileResources; override;
       procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt); override;
      published
     end;

implementation

{ TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass }

constructor TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance;const aStage:TStage;const aFinalStage:boolean);
begin
 inherited Create(aFrameGraph);
 fInstance:=aInstance;
 fStage:=aStage;
 fFinalStage:=aFinalStage;
 case fStage of
  TStage.Irradiance:begin
   Name:='GlobalIlluminationDDGIIrradianceUpdateComputePass';
  end;
  TStage.GlossyRadiance:begin
   Name:='GlobalIlluminationDDGIGlossyRadianceUpdateComputePass';
  end;
  TStage.Visibility:begin
   Name:='GlobalIlluminationDDGIVisibilityUpdateComputePass';
  end;
  TStage.Border:begin
   Name:='GlobalIlluminationDDGIBorderUpdateComputePass';
  end;
  TStage.Relocation:begin
   Name:='GlobalIlluminationDDGIRelocationComputePass';
  end;
  TStage.Classification:begin
   Name:='GlobalIlluminationDDGIClassificationComputePass';
  end;
  else begin
   Name:='GlobalIlluminationDDGIStageComputePass';
  end;
 end;
end;

destructor TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.AcquirePersistentResources;
var ShaderName:TpvUTF8String;
    Stream:TStream;
begin
 inherited AcquirePersistentResources;
 case fStage of
  TStage.Irradiance:begin
   ShaderName:='gi_ddgi_irradiance_update_comp.spv';
  end;
  TStage.GlossyRadiance:begin
   ShaderName:='gi_ddgi_glossy_update_comp.spv';
  end;
  TStage.Visibility:begin
   ShaderName:='gi_ddgi_visibility_update_comp.spv';
  end;
  TStage.Border:begin
   ShaderName:='gi_ddgi_border_update_comp.spv';
  end;
  TStage.Relocation:begin
   ShaderName:='gi_ddgi_relocation_comp.spv';
  end;
  TStage.Classification:begin
   ShaderName:='gi_ddgi_classification_comp.spv';
  end;
  else begin
   ShaderName:='';
  end;
 end;
 Stream:=pvScene3DShaderVirtualFileSystem.GetFile(ShaderName);
 try
  fComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  FreeAndNil(Stream);
 end;
 fVulkanPipelineShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModule,'main');
end;

procedure TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStage);
 FreeAndNil(fComputeShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.AcquireVolatileResources;
var InFlightFrameIndex:TpvInt32;
begin

 inherited AcquireVolatileResources;

 FillChar(fWarmupFrameCounts,SizeOf(fWarmupFrameCounts),#0); // every slot restarts the convergence warmup on (re)acquire

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,fInstance.Renderer.CountInFlightFrames); // binding 0 = ddgiData SSBO
 if TpvScene3DRendererInstance.GlobalIlluminationDDGIStorageOctahedral then begin
  fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fInstance.Renderer.CountInFlightFrames*3); // binding 2 = oct irradiance + binding 3 = visibility moments + binding 4 = visibility sky
 end else begin
  fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fInstance.Renderer.CountInFlightFrames*2); // binding 3 = visibility moments + binding 4 = visibility sky (SH irradiance is a BDA buffer via the master); ray-data + probe-data are BDA too
 end;
 if TpvScene3DRendererInstance.GlobalIlluminationDDGIGlossyRadiance then begin
  fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fInstance.Renderer.CountInFlightFrames); // binding 5 = glossy prefiltered-radiance atlas (only the glossy + border stages declare it)
 end;
 fVulkanDescriptorPool.Initialize;

 // Set 1 = DDGI resources used by the blend: UBO, irradiance (OCT only), visibility. Same shared layout the gi_ddgi_*.comp
 // shaders declare (set 1). Ray-data / probe-data / SH-irradiance are BDA buffers reached via the master push constant. The
 // relocation/classification stages only touch the UBO + the master (they declare neither image), but they share this
 // superset layout — extra layout bindings unused by a shader are valid.
 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0,VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]); // binding 0 = ddgiData SSBO (cascade globals + sub-buffer pointers)
 if TpvScene3DRendererInstance.GlobalIlluminationDDGIStorageOctahedral then begin
  fVulkanDescriptorSetLayout.AddBinding(2,VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]); // oct irradiance; SH irradiance is a BDA buffer via the master
 end;
 fVulkanDescriptorSetLayout.AddBinding(3,VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]); // visibility moments (RG32F)
 fVulkanDescriptorSetLayout.AddBinding(4,VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]); // visibility sky (R8); only the visibility/border stages declare it
 if TpvScene3DRendererInstance.GlobalIlluminationDDGIGlossyRadiance then begin
  fVulkanDescriptorSetLayout.AddBinding(5,VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]); // glossy prefiltered-radiance atlas; only the glossy + border stages declare it (superset layout, valid for the rest)
 end;
 fVulkanDescriptorSetLayout.Initialize;

 fPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants));
 // The update shaders address their resources at set 1 (shared layout with the trace shaders). Set 0 is unused here, so
 // the global scene set layout fills the slot and no descriptor set is bound there (the shaders never touch set 0).
 fPipelineLayout.AddDescriptorSetLayout(fInstance.Scene3D.GlobalVulkanDescriptorSetLayout); // set 0 = unused placeholder slot
 fPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);                        // set 1 = DDGI update resources
 fPipelineLayout.Initialize;

 fPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,fInstance.Renderer.VulkanPipelineCache,0,fVulkanPipelineShaderStage,fPipelineLayout,nil,0);

 for InFlightFrameIndex:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin

  fVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,fVulkanDescriptorSetLayout);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.GlobalIlluminationDDGIMasterBuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false); // binding 0 = ddgiData SSBO
  // binding 1 (ray-data) + SH irradiance are BDA buffers reached via the master push constant; binding 2 = oct irradiance only.
  if TpvScene3DRendererInstance.GlobalIlluminationDDGIStorageOctahedral then begin
   fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                  [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,fInstance.GlobalIlluminationDDGIIrradianceOctImages[InFlightFrameIndex].VulkanImageView.Handle,VK_IMAGE_LAYOUT_GENERAL)],[],[],false);
  end;
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                 [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,fInstance.GlobalIlluminationDDGIVisibilityMomentsImages[InFlightFrameIndex].VulkanImageView.Handle,VK_IMAGE_LAYOUT_GENERAL)],[],[],false); // binding 3 = visibility moments (RG32F)
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                 [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,fInstance.GlobalIlluminationDDGIVisibilitySkyImages[InFlightFrameIndex].VulkanImageView.Handle,VK_IMAGE_LAYOUT_GENERAL)],[],[],false); // binding 4 = visibility sky (R8)
  if TpvScene3DRendererInstance.GlobalIlluminationDDGIGlossyRadiance then begin
   fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                  [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,fInstance.GlobalIlluminationDDGIGlossyImages[InFlightFrameIndex].VulkanImageView.Handle,VK_IMAGE_LAYOUT_GENERAL)],[],[],false); // binding 5 = glossy prefiltered-radiance atlas
  end;
  fVulkanDescriptorSets[InFlightFrameIndex].Flush;

 end;

end;

procedure TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.ReleaseVolatileResources;
var InFlightFrameIndex:TpvInt32;
begin
 FreeAndNil(fPipeline);
 FreeAndNil(fPipelineLayout);
 for InFlightFrameIndex:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[InFlightFrameIndex]);
 end;
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanDescriptorPool);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
const TotalProbes=TpvScene3DRendererInstance.CountGlobalIlluminationDDGICascades*TpvScene3DRendererInstance.GlobalIlluminationDDGIProbesPerCascade;
      // Convergence warmup: for a slot's first WarmupFrames updates, ramp the temporal hysteresis from WarmupStartHysteresis
      // up to SteadyHysteresis, so freshly (re)initialized probes settle in a few frames instead of ~100 (less startup flicker).
      WarmupFrames=16;
      WarmupStartHysteresis=0.7;
      SteadyHysteresis=0.97;
var PushConstants:TPushConstants;
    DescriptorSet:TVkDescriptorSet;
    Quaternion:TpvQuaternion;
    RotationMatrix:TpvMatrix3x3;
    MemoryBarrier:TVkMemoryBarrier;
    WarmupT,Hysteresis:TpvFloat;
    IsFirstFrame:boolean;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 IsFirstFrame:=fInstance.GlobalIlluminationDDGIFirstFrames[aInFlightFrameIndex];

 // Reconstruct the same per-frame rotation the trace used, so the directions the blend weights against match the traced
 // rays (deterministic from the frame index).
 Quaternion:=TpvQuaternion.CreateFromAngleAxis((aFrameIndex*2.39996323)+0.5,TpvVector3.InlineableCreate(0.5774,0.5774,0.5774).Normalize);
 RotationMatrix:=TpvMatrix3x3.CreateFromQuaternion(Quaternion);
 PushConstants.RandomRotation0:=TpvVector4.InlineableCreate(RotationMatrix.RawComponents[0,0],RotationMatrix.RawComponents[0,1],RotationMatrix.RawComponents[0,2],0.0);
 PushConstants.RandomRotation1:=TpvVector4.InlineableCreate(RotationMatrix.RawComponents[1,0],RotationMatrix.RawComponents[1,1],RotationMatrix.RawComponents[1,2],0.0);
 PushConstants.RandomRotation2:=TpvVector4.InlineableCreate(RotationMatrix.RawComponents[2,0],RotationMatrix.RawComponents[2,1],RotationMatrix.RawComponents[2,2],0.0);
 PushConstants.Params.x:=TpvUInt32(aFrameIndex);
 PushConstants.Params.y:=TpvScene3DRendererInstance.CountGlobalIlluminationDDGICascades;
 PushConstants.Params.z:=TpvScene3DRendererInstance.GlobalIlluminationDDGIProbesPerCascade;
 PushConstants.Params.w:=TpvScene3DRendererInstance.GlobalIlluminationDDGIRaysPerProbe;
 // x = temporal hysteresis; z = firstFrame flag (this slot's probe data is still uninitialized -> discard the previous data
 // in the temporal blend this frame). Shared first-frame state with the trace pass; flipped false by the final stage below.
 if IsFirstFrame then begin
  // First frame of this slot: take the raw value (z=1, hysteresis irrelevant).
  PushConstants.Blend:=TpvVector4.InlineableCreate(SteadyHysteresis,0.0,1.0,0.0);
 end else begin
  // Warmup ramp: low hysteresis right after init (probes converge fast) easing up to the steady value over WarmupFrames.
  WarmupT:=Min(fWarmupFrameCounts[aInFlightFrameIndex]/WarmupFrames,1.0);
  Hysteresis:=(WarmupStartHysteresis*(1.0-WarmupT))+(SteadyHysteresis*WarmupT);
  PushConstants.Blend:=TpvVector4.InlineableCreate(Hysteresis,1.0,0.0,0.0);
 end;

 // The ray-data was published by the trace pass and each previous stage by its barrier below (+ the frame-graph ordering).
 DescriptorSet:=fVulkanDescriptorSets[aInFlightFrameIndex].Handle;
 aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,fPipelineLayout.Handle,1,1,@DescriptorSet,0,nil); // bind set 1 only (set 0 unused)
 aCommandBuffer.CmdPushConstants(fPipelineLayout.Handle,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants),@PushConstants);
 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipeline.Handle);

 // Workgroup model per stage:
 //  - one workgroup per probe (octahedral tile, local_size = OCT x OCT, gl_WorkGroupID.x = probe): glossy / visibility / border,
 //    AND the irradiance stage in OCTAHEDRAL storage mode (gi_ddgi_irradiance_update.comp's OCT path is per-texel-per-probe).
 //  - one thread per probe (local_size_x = 64, gl_GlobalInvocationID.x = probe): irradiance in SH storage mode, relocation,
 //    classification.
 // The irradiance stage thus depends on the storage mode -> NOT a fixed stage set (the SH dispatch starved the OCT path before).
 if (fStage in [TStage.GlossyRadiance,TStage.Visibility,TStage.Border]) or
    (TpvScene3DRendererInstance.GlobalIlluminationDDGIStorageOctahedral and (fStage=TStage.Irradiance)) then begin
  aCommandBuffer.CmdDispatch(TotalProbes,1,1);
 end else begin
  aCommandBuffer.CmdDispatch((TotalProbes+63) shr 6,1,1);
 end;

 if fFinalStage then begin
  // Last stage in the chain: publish the probe writes to every later shader stage that samples them (mesh/planet fragment
  // shaders).
  MemoryBarrier:=TVkMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                         TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT));
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    FrameGraph.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                    0,1,@MemoryBarrier,0,nil,0,nil);
 end else begin
  // Inter-stage publish: make this stage's writes visible to the next stage (read-modify-write covered) in the same queue.
  MemoryBarrier:=TVkMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                         TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT));
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,1,@MemoryBarrier,0,nil,0,nil);
 end;

 // Advance this stage's private warmup counter (every stage runs the identical per-frame logic, so the counters stay in
 // sync; the value is only read for the hysteresis ramp above). Reset on a slot's first frame, then increment (capped).
 if IsFirstFrame then begin
  fWarmupFrameCounts[aInFlightFrameIndex]:=0;
 end;
 if fWarmupFrameCounts[aInFlightFrameIndex]<WarmupFrames then begin
  inc(fWarmupFrameCounts[aInFlightFrameIndex]);
 end;

 // This slot's probe data has now been written once -> subsequent frames blend against it normally. Only the final stage
 // flips it (so every stage this frame saw the pre-flip value); the trace pass ran before all of them this frame.
 if fFinalStage then begin
  fInstance.GlobalIlluminationDDGIFirstFrames[aInFlightFrameIndex]:=false;
 end;

end;

end.
