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
unit PasVulkan.Scene3D.Renderer.Passes.MeshFilterComputePass;
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

type { TpvScene3DRendererPassesMeshFilterComputePass }
     TpvScene3DRendererPassesMeshFilterComputePass=class(TpvFrameGraph.TComputePass)
      public
       type TPushConstants=packed record
             CountRanges:TpvUInt32;
             TotalCommands:TpvUInt32;
             BatchRangeOffset:TpvUInt32;
             PrefixSumOffset:TpvUInt32;
             RenderPassMask:TpvUInt32;
             Flags:TpvUInt32;
             AlphaModeMask:TpvUInt32;
             MaxOutputCommands:TpvUInt32;
             OutputCommandSlotOffset:TpvUInt32; // K*N slot offset subtracted to get input source index
            end;
            PPushConstants=^TPushConstants;
            TMeshCullResetPushConstants=packed record
             CountRanges:TpvUInt32;
             MaxMultiIndirectDrawCalls:TpvUInt32;
             BatchRangeOffset:TpvUInt32;
             PrefixSumOffset:TpvUInt32;
             CullDispatchIndex:TpvUInt32;
            end;
            PMeshCullResetPushConstants=^TMeshCullResetPushConstants;
      private
       fInstance:TpvScene3DRendererInstance;
       fCullRenderPass:TpvScene3DRendererCullRenderPass;
       fComputeShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fPipelineLayout:TpvVulkanPipelineLayout;
       fPipeline:TpvVulkanComputePipeline;
      public
       constructor Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance;const aCullRenderPass:TpvScene3DRendererCullRenderPass); reintroduce;
       destructor Destroy; override;
       procedure AcquirePersistentResources; override;
       procedure ReleasePersistentResources; override;
       procedure AcquireVolatileResources; override;
       procedure ReleaseVolatileResources; override;
       procedure Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt); override;
       procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt); override;
     end;

implementation

{ TpvScene3DRendererPassesMeshFilterComputePass }

constructor TpvScene3DRendererPassesMeshFilterComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance;const aCullRenderPass:TpvScene3DRendererCullRenderPass);
begin
 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 fCullRenderPass:=aCullRenderPass;

 case fCullRenderPass of
  TpvScene3DRendererCullRenderPass.Voxelization:begin
   Name:='VoxelizationMeshFilterComputePass';
  end;
  TpvScene3DRendererCullRenderPass.ReflectionProbe:begin
   Name:='ReflectionProbeMeshFilterComputePass';
  end;
  TpvScene3DRendererCullRenderPass.TopDownSkyOcclusionMap:begin
   Name:='TopDownSkyOcclusionMapMeshFilterComputePass';
  end;
  TpvScene3DRendererCullRenderPass.ReflectiveShadowMap:begin
   Name:='ReflectiveShadowMapMeshFilterComputePass';
  end;
  else begin
   Name:='MeshFilterComputePass';
  end;
 end;

end;

destructor TpvScene3DRendererPassesMeshFilterComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesMeshFilterComputePass.AcquirePersistentResources;
var Stream:TStream;
begin

 inherited AcquirePersistentResources;

 if fInstance.Renderer.Scene3D.MeshShaders then begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_filter_ms_comp.spv');
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_filter_comp.spv');
 end;
 try
  fComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
  fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererPassesMeshFilterComputePass.fComputeShaderModule');
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModule,'main');

end;

procedure TpvScene3DRendererPassesMeshFilterComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStageCompute);
 FreeAndNil(fComputeShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesMeshFilterComputePass.AcquireVolatileResources;
begin

 inherited AcquireVolatileResources;

 fPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TpvScene3DRendererPassesMeshFilterComputePass.TPushConstants));
 fPipelineLayout.AddDescriptorSetLayout(fInstance.MeshFilterComputeVulkanDescriptorSetLayout);
 fPipelineLayout.AddDescriptorSetLayout(fInstance.Scene3D.GlobalVulkanDescriptorSetLayout);
 fPipelineLayout.Initialize;

 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fPipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DRendererPassesMeshFilterComputePass.fPipelineLayout');

 fPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                            fInstance.Renderer.VulkanPipelineCache,
                                            0,
                                            fVulkanPipelineShaderStageCompute,
                                            fPipelineLayout,
                                            nil,
                                            0);
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DRendererPassesMeshFilterComputePass.fPipeline');

end;

procedure TpvScene3DRendererPassesMeshFilterComputePass.ReleaseVolatileResources;
begin
 FreeAndNil(fPipeline);
 FreeAndNil(fPipelineLayout);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesMeshFilterComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesMeshFilterComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var RenderPass:TpvScene3DRendererRenderPass;
    BufferMemoryBarriers:array[0..2] of TVkBufferMemoryBarrier;
    PushConstants:TpvScene3DRendererPassesMeshFilterComputePass.TPushConstants;
    ResetPushConstants:TMeshCullResetPushConstants;
    DescriptorSets:array[0..1] of TVkDescriptorSet;
    CountRanges,TotalCommands:TpvUInt32;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 case fCullRenderPass of
  TpvScene3DRendererCullRenderPass.Voxelization:begin
   RenderPass:=TpvScene3DRendererRenderPass.Voxelization;
  end;
  TpvScene3DRendererCullRenderPass.ReflectionProbe:begin
   RenderPass:=TpvScene3DRendererRenderPass.ReflectionProbe;
  end;
  TpvScene3DRendererCullRenderPass.TopDownSkyOcclusionMap:begin
   RenderPass:=TpvScene3DRendererRenderPass.TopDownSkyOcclusionMap;
  end;
  TpvScene3DRendererCullRenderPass.ReflectiveShadowMap:begin
   RenderPass:=TpvScene3DRendererRenderPass.ReflectiveShadowMap;
  end;
  else begin
   exit;
  end;
 end;

 begin

  fInstance.Renderer.VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3D.MeshFilter',[0.5,0.75,0.25,1.0]);

  // Barrier: host writes + previous indirect reads -> shader reads/writes
  BufferMemoryBarriers[0]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_HOST_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT),
                                                         TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.PerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  BufferMemoryBarriers[1]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT),
                                                         TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.GPUDrawIndexedIndirectCommandOutputBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  BufferMemoryBarriers[2]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT),
                                                         TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.GPUDrawIndexedIndirectCommandCounterBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT) or
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT) or
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    3,@BufferMemoryBarriers[0],
                                    0,nil);

  begin

   CountRanges:=fInstance.PerInFlightFrameMeshCullBatchRangeCounts[aInFlightFrameIndex,fCullRenderPass];
   TotalCommands:=fInstance.PerInFlightFrameMeshCullTotalCommands[aInFlightFrameIndex,fCullRenderPass];

   if (CountRanges>0) and (TotalCommands>0) then begin

    // Reset counters for the filter pass draw call indices
    aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fInstance.MeshCullReset.Pipeline.Handle);

    DescriptorSets[0]:=fInstance.MeshCullReset.VulkanDescriptorSets[aInFlightFrameIndex].Handle;

    aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                         fInstance.MeshCullReset.PipelineLayout.Handle,
                                         0,
                                         1,
                                         @DescriptorSets[0],
                                         0,
                                         nil);

    ResetPushConstants.CountRanges:=CountRanges;
    ResetPushConstants.MaxMultiIndirectDrawCalls:=TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls;
    ResetPushConstants.BatchRangeOffset:=fInstance.PerInFlightFrameMeshCullBatchRangeOffsets[aInFlightFrameIndex,fCullRenderPass];
    ResetPushConstants.PrefixSumOffset:=fInstance.PerInFlightFrameMeshCullPrefixSumOffsets[aInFlightFrameIndex,fCullRenderPass];
    ResetPushConstants.CullDispatchIndex:=TpvUInt32($ffffffff); // filter-only: no indirect dispatch entry to write
  //ResetPushConstants.CullDispatchIndex:=TpvUInt32(ord(fCullRenderPass));

    aCommandBuffer.CmdPushConstants(fInstance.MeshCullReset.PipelineLayout.Handle,
                                    TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                    0,
                                    SizeOf(ResetPushConstants),
                                    @ResetPushConstants);

    if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
     fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.Dispatch,'MeshFilterComputePass.ResetDispatch');
    end;
    aCommandBuffer.CmdDispatch((CountRanges+255) shr 8,1,1);
    if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
     fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
    end;

   end;

  end;

  // Barrier: counter reset -> filter dispatch
  BufferMemoryBarriers[0]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.GPUDrawIndexedIndirectCommandCounterBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    1,@BufferMemoryBarriers[0],
                                    0,nil);

  // Bind filter pipeline
  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipeline.Handle);

  DescriptorSets[0]:=fInstance.MeshFilterComputeVulkanDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[1]:=fInstance.Scene3D.GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle;
  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       fPipelineLayout.Handle,
                                       0,
                                       2,
                                       @DescriptorSets[0],
                                       0,
                                       nil);

  begin

   CountRanges:=fInstance.PerInFlightFrameMeshCullBatchRangeCounts[aInFlightFrameIndex,fCullRenderPass];
   TotalCommands:=fInstance.PerInFlightFrameMeshCullTotalCommands[aInFlightFrameIndex,fCullRenderPass];

   if (CountRanges>0) and (TotalCommands>0) then begin

    PushConstants.CountRanges:=CountRanges;
    PushConstants.TotalCommands:=TotalCommands;
    PushConstants.BatchRangeOffset:=fInstance.PerInFlightFrameMeshCullBatchRangeOffsets[aInFlightFrameIndex,fCullRenderPass];
    PushConstants.PrefixSumOffset:=fInstance.PerInFlightFrameMeshCullPrefixSumOffsets[aInFlightFrameIndex,fCullRenderPass];

    case fCullRenderPass of
     TpvScene3DRendererCullRenderPass.Voxelization:begin
      PushConstants.RenderPassMask:=TpvUInt32(1) shl TpvUInt32(ord(TpvScene3DRendererRenderPass.Voxelization));
      PushConstants.AlphaModeMask:=(TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Opaque))) or (TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Mask))) or (TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Blend)));
     end;
     TpvScene3DRendererCullRenderPass.ReflectionProbe:begin
      PushConstants.RenderPassMask:=TpvUInt32(1) shl TpvUInt32(ord(TpvScene3DRendererRenderPass.ReflectionProbe));
      PushConstants.AlphaModeMask:=(TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Opaque))) or (TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Mask))) or (TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Blend)));
     end;
     TpvScene3DRendererCullRenderPass.TopDownSkyOcclusionMap:begin
      PushConstants.RenderPassMask:=TpvUInt32(1) shl TpvUInt32(ord(TpvScene3DRendererRenderPass.TopDownSkyOcclusionMap));
      PushConstants.AlphaModeMask:=(TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Opaque))) or (TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Mask))); // Opaque+Mask only (no Blend)
     end;
     TpvScene3DRendererCullRenderPass.ReflectiveShadowMap:begin
      PushConstants.RenderPassMask:=TpvUInt32(1) shl TpvUInt32(ord(TpvScene3DRendererRenderPass.ReflectiveShadowMap));
      PushConstants.AlphaModeMask:=(TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Opaque))) or (TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Mask))) or (TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Blend)));
     end;
     else begin
      PushConstants.RenderPassMask:=$ffff;
      PushConstants.AlphaModeMask:=(TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Opaque))) or (TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Mask))) or (TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Blend)));
     end;
    end;

    PushConstants.Flags:=0;

    PushConstants.MaxOutputCommands:=fInstance.GPUDrawIndexedIndirectCommandOutputBufferSizes[aInFlightFrameIndex];

    PushConstants.OutputCommandSlotOffset:=fInstance.PerInFlightFrameGPUDrawIndexedIndirectCommandFilterOffsets[aInFlightFrameIndex];

    aCommandBuffer.CmdPushConstants(fPipelineLayout.Handle,
                                    TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                    0,
                                    SizeOf(TpvScene3DRendererPassesMeshFilterComputePass.TPushConstants),
                                    @PushConstants);

    if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
     fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.Dispatch,'MeshFilterComputePass.Dispatch');
    end;
    aCommandBuffer.CmdDispatch((TotalCommands+255) shr 8,1,1);
    if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
     fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
    end;

   end;

  end;

  // Barrier: filter dispatch -> indirect draw reads
  BufferMemoryBarriers[0]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.PerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  BufferMemoryBarriers[1]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.GPUDrawIndexedIndirectCommandOutputBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  BufferMemoryBarriers[2]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.GPUDrawIndexedIndirectCommandCounterBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT) or
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    3,@BufferMemoryBarriers[0],
                                    0,nil);

  fInstance.Renderer.VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

 end;

end;


end.
