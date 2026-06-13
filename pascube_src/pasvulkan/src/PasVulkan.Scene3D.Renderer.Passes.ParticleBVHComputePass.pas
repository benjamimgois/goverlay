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
unit PasVulkan.Scene3D.Renderer.Passes.ParticleBVHComputePass;
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

type { TpvScene3DRendererPassesParticleBVHComputePass }
     // Builds a per-frame GPU LBVH over the particle emitters (particles are not in the hardware ray-tracing BLAS) so that
     // gi_ddgi_trace.comp can software-trace them into the DDGI probe irradiance. Pipeline: extract emitters from the billboard
     // vertex buffer -> world AABB -> Morton codes -> LSD radix sort -> Karras hierarchy -> bottom-up AABB refit. Runs before
     // the DDGI trace pass (explicit dependency). All buffers live on the renderer instance.
     TpvScene3DRendererPassesParticleBVHComputePass=class(TpvFrameGraph.TComputePass)
      public
       const Stages=8; // 0=emit 1=aabb 2=morton 3=radixHistogram 4=radixScan 5=radixScatter 6=hierarchy 7=refit
       type TPushConstants=packed record
             VertexBufferAddress:TVkDeviceAddress; // BDA of the particle vertex buffer (read as uvec2 in the shader)
             ParticleCount:TpvUInt32;
             Param:TpvUInt32;                       // radix pass index (0..3) for the radix stages, else 0
            end;
      private
       fInstance:TpvScene3DRendererInstance;
       fComputeShaderModules:array[0..Stages-1] of TpvVulkanShaderModule;
       fVulkanPipelineShaderStages:array[0..Stages-1] of TpvVulkanPipelineShaderStage;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fPipelineLayout:TpvVulkanPipelineLayout;
       fPipelines:array[0..Stages-1] of TpvVulkanComputePipeline;
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

const ShaderFileNames:array[0..TpvScene3DRendererPassesParticleBVHComputePass.Stages-1] of TpvUTF8String=
       (
        'particle_bvh_emit_comp.spv',
        'particle_bvh_aabb_comp.spv',
        'particle_bvh_morton_comp.spv',
        'particle_bvh_radix_histogram_comp.spv',
        'particle_bvh_radix_scan_comp.spv',
        'particle_bvh_radix_scatter_comp.spv',
        'particle_bvh_hierarchy_comp.spv',
        'particle_bvh_refit_comp.spv'
       );

{ TpvScene3DRendererPassesParticleBVHComputePass }

constructor TpvScene3DRendererPassesParticleBVHComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
 inherited Create(aFrameGraph);
 fInstance:=aInstance;
 Name:='ParticleBVHComputePass';
end;

destructor TpvScene3DRendererPassesParticleBVHComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesParticleBVHComputePass.AcquirePersistentResources;
var StageIndex:TpvSizeInt;
    Stream:TStream;
begin
 inherited AcquirePersistentResources;
 for StageIndex:=0 to Stages-1 do begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile(ShaderFileNames[StageIndex]);
  try
   fComputeShaderModules[StageIndex]:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
  fVulkanPipelineShaderStages[StageIndex]:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModules[StageIndex],'main');
 end;
end;

procedure TpvScene3DRendererPassesParticleBVHComputePass.ReleasePersistentResources;
var StageIndex:TpvSizeInt;
begin
 for StageIndex:=0 to Stages-1 do begin
  FreeAndNil(fVulkanPipelineShaderStages[StageIndex]);
  FreeAndNil(fComputeShaderModules[StageIndex]);
 end;
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesParticleBVHComputePass.AcquireVolatileResources;
var InFlightFrameIndex,BindingIndex,StageIndex:TpvInt32;
begin

 inherited AcquireVolatileResources;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,fInstance.Renderer.CountInFlightFrames*8);
 fVulkanDescriptorPool.Initialize;

 // Set 0 = the 8 particle-BVH buffers (see particle_bvh.glsl bindings 0..7).
 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 for BindingIndex:=0 to 7 do begin
  fVulkanDescriptorSetLayout.AddBinding(BindingIndex,VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),[]);
 end;
 fVulkanDescriptorSetLayout.Initialize;

 fPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants));
 fPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 fPipelineLayout.Initialize;

 for StageIndex:=0 to Stages-1 do begin
  fPipelines[StageIndex]:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,fInstance.Renderer.VulkanPipelineCache,0,fVulkanPipelineShaderStages[StageIndex],fPipelineLayout,nil,0);
 end;

 for InFlightFrameIndex:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  fVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,fVulkanDescriptorSetLayout);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.ParticleBVH.EmitterBuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.ParticleBVH.MortonABuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.ParticleBVH.MortonBBuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.ParticleBVH.RadixHistogramBuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.ParticleBVH.NodeBuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.ParticleBVH.ParentBuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(6,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.ParticleBVH.RefitCounterBuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(7,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fInstance.ParticleBVH.BoundsBuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false);
  fVulkanDescriptorSets[InFlightFrameIndex].Flush;
 end;

end;

procedure TpvScene3DRendererPassesParticleBVHComputePass.ReleaseVolatileResources;
var InFlightFrameIndex,StageIndex:TpvInt32;
begin
 for StageIndex:=0 to Stages-1 do begin
  FreeAndNil(fPipelines[StageIndex]);
 end;
 FreeAndNil(fPipelineLayout);
 for InFlightFrameIndex:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[InFlightFrameIndex]);
 end;
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanDescriptorPool);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesParticleBVHComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesParticleBVHComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var PushConstants:TPushConstants;
    ParticleCount,RadixPass:TpvUInt32;
    DescriptorSetHandle:TVkDescriptorSet;
    MemoryBarrier:TVkMemoryBarrier;
    VertexBufferBarrier:TVkBufferMemoryBarrier;

 procedure StageBarrier;
 begin
  // Conservative buffer-wide visibility between consecutive build stages (compute write -> compute read/write).
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,1,@MemoryBarrier,0,nil,0,nil);
 end;

 procedure RunStage(const aStageIndex:TpvSizeInt;const aGroupCountX:TpvUInt32;const aParam:TpvUInt32);
 begin
  PushConstants.Param:=aParam;
  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipelines[aStageIndex].Handle);
  aCommandBuffer.CmdPushConstants(fPipelineLayout.Handle,TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants),@PushConstants);
  aCommandBuffer.CmdDispatch(Max(1,aGroupCountX),1,1);
 end;

begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 // Alive particle count (= vertices / 3), clamped to the fixed capacity. No particles -> nothing to build (the trace skips it
 // via particleCount == 0); leave the stale BVH untouched.
 ParticleCount:=Min(TpvSizeInt(fInstance.Scene3D.CountInFlightFrameParticleVertices[aInFlightFrameIndex] div 3),TpvSizeInt(TpvScene3D.MaxParticles));
 if ParticleCount=0 then begin
  exit;
 end;

 PushConstants.VertexBufferAddress:=fInstance.Scene3D.ParticleVertexBuffers[aInFlightFrameIndex].DeviceAddress;
 PushConstants.ParticleCount:=ParticleCount;
 PushConstants.Param:=0;

 MemoryBarrier:=TVkMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                        TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT));

 // Make the (host/transfer) particle vertex upload visible to the emitter-extraction compute read (BDA).
 VertexBufferBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_HOST_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                    TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                    VK_QUEUE_FAMILY_IGNORED,VK_QUEUE_FAMILY_IGNORED,
                                                    fInstance.Scene3D.ParticleVertexBuffers[aInFlightFrameIndex].Handle,0,VK_WHOLE_SIZE);
 aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   0,0,nil,1,@VertexBufferBarrier,0,nil);

 DescriptorSetHandle:=fVulkanDescriptorSets[aInFlightFrameIndex].Handle;
 aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,fPipelineLayout.Handle,0,1,@DescriptorSetHandle,0,nil);

 // 1) Extract emitters (+ reset bounds), 2) reduce world AABB, 3) Morton codes (full capacity, sentinel padding).
 RunStage(0,(ParticleCount+255) shr 8,0);
 StageBarrier;

 RunStage(1,(ParticleCount+255) shr 8,0);
 StageBarrier;

 // count-adaptive: ceil(count/256) groups (Morton pads the last group's tail with sentinels); sort cost scales with particle count
 RunStage(2,(ParticleCount+255) shr 8,0);
 StageBarrier;

 // 4) LSD radix sort, 4 passes of 8 bits: histogram -> scan -> scatter, ping-pong A<->B (ends sorted in A).
 for RadixPass:=0 to 3 do begin

  // histogram
  RunStage(3,(ParticleCount+255) shr 8,RadixPass);
  StageBarrier;

  // scan (single invocation, serial)
  RunStage(4,1,RadixPass);
  StageBarrier;

  // scatter
  RunStage(5,(ParticleCount+255) shr 8,RadixPass);
  StageBarrier;

 end;

 // 5) Karras hierarchy (internal nodes + parent links + counter reset), 6) bottom-up AABB refit.
 RunStage(6,(ParticleCount+255) shr 8,0);
 StageBarrier;

 // bottom-up AABB refit
 RunStage(7,(ParticleCount+255) shr 8,0);
 StageBarrier;

 // Publish the finished node + emitter buffers to the DDGI trace pass (it reads them via its set-1 SSBO bindings).
 aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   0,1,@MemoryBarrier,0,nil,0,nil);

end;

end.
