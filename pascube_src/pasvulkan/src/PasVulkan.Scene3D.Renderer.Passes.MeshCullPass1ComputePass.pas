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
unit PasVulkan.Scene3D.Renderer.Passes.MeshCullPass1ComputePass;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}

// Debug instrumentation: uncomment to enable GPU atomic counters in mesh_cull.comp
// that count cull reasons per frame for the FinalView pass, read back and logged
// each frame. Shader SPV is already built with MESH_CULL_DEBUG_COUNTERS; toggling
// this define only controls the host-side buffer allocation, BDA wiring and log.
{.$define MeshCullDebugCounters}

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
     PasVulkan.Scene3D.Renderer.Instance;

type { TpvScene3DRendererPassesMeshCullPass1ComputePass }
     TpvScene3DRendererPassesMeshCullPass1ComputePass=class(TpvFrameGraph.TComputePass)
      public
       type TPushConstants=packed record
             LODLevelCurrentBDA:TVkDeviceAddress;
             LODLevelPreviousBDA:TVkDeviceAddress;
             ScratchBufferBDA:TVkDeviceAddress;
             MeshletVisibilityBDA:TVkDeviceAddress;
             CountRanges:TpvUInt32;
             TotalCommands:TpvUInt32;
             CountMeshObjectIDs:TpvUInt32;
             SkipCulling:TpvUInt32;
             BatchRangeOffset:TpvUInt32;
             PrefixSumOffset:TpvUInt32;
             VisibilityBufferOffset:TpvUInt32;
             TextureDepthIndex:TpvUInt32;
             BaseViewIndex:TpvUInt32;
             CountViews:TpvUInt32;
             RenderPassMask:TpvUInt32;
             RendererInstanceIndex:TpvUInt32;
             Flags:TpvUInt32;
             BatchRangeIndex:TpvInt32;
             MaxOutputCommands:TpvUInt32;
             MaxScratchEntries:TpvUInt32;
             MeshletVisibilityPartOffset:TpvUInt32;
             MaximumDistance:TpvFloat;
             AreaTooSmallThreshold:TpvFloat;
             AlphaModeMask:TpvUInt32;
             OutputCommandSlotOffset:TpvUInt32; // K*N slot offset subtracted to get input source index
{$ifdef MeshCullDebugCounters}
             DebugCountersBDAPad:TpvUInt32; // std140 8-byte alignment padding before uvec2 debugCountersBDA
             DebugCountersBDA:TVkDeviceAddress; // BDA to debug counters buffer (0 = disabled)
{$endif}
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
            TSortPushConstants=packed record
             ScratchBufferBDA:TVkDeviceAddress;
             ExpandRangeInfoBDA:TVkDeviceAddress;
             OutputCommandsBDA:TVkDeviceAddress;
             CountersBDA:TVkDeviceAddress;
            end;
            PSortPushConstants=^TSortPushConstants;
      private
       fInstance:TpvScene3DRendererInstance;
       fCullRenderPass:TpvScene3DRendererCullRenderPass;
       fComputeShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fPipelineLayout:TpvVulkanPipelineLayout;
       fPipeline:TpvVulkanComputePipeline;
       fMeshShaderComputeShaderModule:TpvVulkanShaderModule;
       fMeshShader:Boolean;
       fMeshShaderVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fMeshShaderPipeline:TpvVulkanComputePipeline;
       fSortComputeShaderModule:TpvVulkanShaderModule;
       fSortVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fSortPipelineLayout:TpvVulkanPipelineLayout;
       fSortPipeline:TpvVulkanComputePipeline;
       fPlanetCullPass:TpvScene3DPlanet.TCullPass;
{$ifdef MeshCullDebugCounters}
       fDebugCullCountersBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
       fLastDebugVisibleCounts:array[0..MaxInFlightFrames-1] of TpvUInt32;
{$endif}
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

{ TpvScene3DRendererPassesMeshCullPass1ComputePass }

constructor TpvScene3DRendererPassesMeshCullPass1ComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance;const aCullRenderPass:TpvScene3DRendererCullRenderPass);
begin
 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 fCullRenderPass:=aCullRenderPass;

 case fCullRenderPass of
  TpvScene3DRendererCullRenderPass.FinalView:begin
   Name:='FinalViewMeshCullPass1ComputePass';
  end;
  TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
   Name:='CascadedShadowMapMeshCullPass1ComputePass';
  end;
  else begin
   Name:='MeshCullPass1ComputePass';
  end;
 end;

end;

destructor TpvScene3DRendererPassesMeshCullPass1ComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesMeshCullPass1ComputePass.AcquirePersistentResources;
var Stream:TStream;
begin

 inherited AcquirePersistentResources;

 fMeshShader:=fInstance.Scene3D.MeshShaders;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_cull_pass1_comp.spv');
 try
  fComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
  fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererPassesMeshCullPass1ComputePass.fComputeShaderModule');
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModule,'main');

 if fMeshShader then begin
  if fInstance.Renderer.UseMeshletExpand then begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_cull_meshshader_expand_pass1_comp.spv');
  end else begin
   Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_cull_meshshader_pass1_comp.spv');
  end;
  try
   fMeshShaderComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
   fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshShaderComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererPassesMeshCullPass1ComputePass.fMeshShaderComputeShaderModule');
  finally
   Stream.Free;
  end;
  fMeshShaderVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fMeshShaderComputeShaderModule,'main');
 end else begin
  fMeshShaderComputeShaderModule:=nil;
  fMeshShaderVulkanPipelineShaderStageCompute:=nil;
 end;

 if fInstance.Renderer.UseMeshletExpand then begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_cull_sort_comp.spv');
  try
   fSortComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
   fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fSortComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererPassesMeshCullPass1ComputePass.fSortComputeShaderModule');
  finally
   Stream.Free;
  end;
  fSortVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fSortComputeShaderModule,'main');
 end else begin
  fSortComputeShaderModule:=nil;
  fSortVulkanPipelineShaderStageCompute:=nil;
 end;

 fPlanetCullPass:=TpvScene3DPlanet.TCullPass.Create(fInstance.Renderer,
                                                    fInstance,
                                                    fInstance.Renderer.Scene3D,
                                                    fCullRenderPass,
                                                    1);

end;

procedure TpvScene3DRendererPassesMeshCullPass1ComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fPlanetCullPass);
 FreeAndNil(fSortVulkanPipelineShaderStageCompute);
 FreeAndNil(fSortComputeShaderModule);
 FreeAndNil(fMeshShaderVulkanPipelineShaderStageCompute);
 FreeAndNil(fMeshShaderComputeShaderModule);
 FreeAndNil(fVulkanPipelineShaderStageCompute);
 FreeAndNil(fComputeShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesMeshCullPass1ComputePass.AcquireVolatileResources;
var Index:TpvSizeInt;
begin

 inherited AcquireVolatileResources;

{$ifdef MeshCullDebugCounters}
 if fCullRenderPass=TpvScene3DRendererCullRenderPass.FinalView then begin
  for Index:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
   fDebugCullCountersBuffers[Index]:=TpvVulkanBuffer.Create(fInstance.Renderer.VulkanDevice,
                                                            64,
                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or
                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or
                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                            TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                            [],
                                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                            [TpvVulkanBufferFlag.BufferDeviceAddress,TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                            0,
                                                            pvAllocationGroupIDScene3DDynamic,
                                                            '3DRendererInstance.MeshCullPass1DebugCountersBuffer'
                                                           );
   fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fDebugCullCountersBuffers[Index].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.MeshCullPass1DebugCountersBuffer');
   fLastDebugVisibleCounts[Index]:=High(TpvUInt32);
  end;
 end;
{$endif}

 fPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TpvScene3DRendererPassesMeshCullPass1ComputePass.TPushConstants));
 fPipelineLayout.AddDescriptorSetLayout(fInstance.MeshCullPass1ComputeVulkanDescriptorSetLayout);
 fPipelineLayout.AddDescriptorSetLayout(fInstance.Scene3D.GlobalVulkanDescriptorSetLayout);
 fPipelineLayout.AddDescriptorSetLayout(fInstance.Scene3D.GlobalBoundingSphereVulkanDescriptorSetLayout);
 fPipelineLayout.Initialize;

 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fPipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DRendererPassesMeshCullPass1ComputePass.fPipelineLayout');

 fPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                            fInstance.Renderer.VulkanPipelineCache,
                                            0,
                                            fVulkanPipelineShaderStageCompute,
                                            fPipelineLayout,
                                            nil,
                                            0);
 fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DRendererPassesMeshCullPass1ComputePass.fPipeline');

 if assigned(fMeshShaderVulkanPipelineShaderStageCompute) then begin
  fMeshShaderPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                       fInstance.Renderer.VulkanPipelineCache,
                                                       0,
                                                       fMeshShaderVulkanPipelineShaderStageCompute,
                                                       fPipelineLayout,
                                                       nil,
                                                       0);
  fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshShaderPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DRendererPassesMeshCullPass1ComputePass.fMeshShaderPipeline');
 end else begin
  fMeshShaderPipeline:=nil;
 end;

 if assigned(fSortVulkanPipelineShaderStageCompute) then begin
  fSortPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
  fSortPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TpvScene3DRendererPassesMeshCullPass1ComputePass.TSortPushConstants));
  fSortPipelineLayout.Initialize;
  fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fSortPipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DRendererPassesMeshCullPass1ComputePass.fSortPipelineLayout');
  fSortPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                                  fInstance.Renderer.VulkanPipelineCache,
                                                  0,
                                                  fSortVulkanPipelineShaderStageCompute,
                                                  fSortPipelineLayout,
                                                  nil,
                                                  0);
  fInstance.Renderer.VulkanDevice.DebugUtils.SetObjectName(fSortPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DRendererPassesMeshCullPass1ComputePass.fSortPipeline');
 end else begin
  fSortPipelineLayout:=nil;
  fSortPipeline:=nil;
 end;

 fPlanetCullPass.AllocateResources;

end;

procedure TpvScene3DRendererPassesMeshCullPass1ComputePass.ReleaseVolatileResources;
var Index:TpvSizeInt;
begin
 fPlanetCullPass.ReleaseResources;
 FreeAndNil(fSortPipeline);
 FreeAndNil(fSortPipelineLayout);
 FreeAndNil(fMeshShaderPipeline);
 FreeAndNil(fPipeline);
 FreeAndNil(fPipelineLayout);
{$ifdef MeshCullDebugCounters}
 for Index:=0 to fInstance.Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fDebugCullCountersBuffers[Index]);
 end;
{$endif}
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesMeshCullPass1ComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesMeshCullPass1ComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var RenderPass:TpvScene3DRendererRenderPass;
    PreviousInFlightFrameIndex,
    Part:TpvSizeInt;
    BufferMemoryBarriers:array[0..5] of TVkBufferMemoryBarrier;
    PushConstants:TpvScene3DRendererPassesMeshCullPass1ComputePass.TPushConstants;
    ResetPushConstants:TMeshCullResetPushConstants;
    SortPushConstants:TpvScene3DRendererPassesMeshCullPass1ComputePass.TSortPushConstants;
    DescriptorSets:array[0..3] of TVkDescriptorSet;
    CountRanges,TotalCommands:TpvUInt32;
    RangeIndex,BatchRangeOffset,RangeCountCommands:TpvUInt32;
    PyramidImageMemoryBarrier:TVkImageMemoryBarrier;
{$ifdef MeshCullDebugCounters}
    DebugCountersPtr:PpvUInt32;
    DebugVisible:TpvUInt32;
{$endif}
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

{$ifdef MeshCullDebugCounters}
 if (fCullRenderPass=TpvScene3DRendererCullRenderPass.FinalView) and assigned(fDebugCullCountersBuffers[aInFlightFrameIndex]) then begin
  // Read back previous frame's counters (CPU-safe: fence for this IFF has been waited on)
  DebugCountersPtr:=PpvUInt32(fDebugCullCountersBuffers[aInFlightFrameIndex].Memory.MapMemory);
  if assigned(DebugCountersPtr) then begin
   try
    fDebugCullCountersBuffers[aInFlightFrameIndex].Memory.InvalidateMappedMemory;
    DebugVisible:=PpvUInt32(TpvPtrUInt(DebugCountersPtr)+(8*SizeOf(TpvUInt32)))^;
    if (fLastDebugVisibleCounts[aInFlightFrameIndex]<>High(TpvUInt32)) and
       (DebugVisible<>fLastDebugVisibleCounts[aInFlightFrameIndex]) then begin
     pvApplication.Log(LOG_DEBUG,'MeshCullPass1/FinalView',
      Format('IFF=%d prevVis=%u newVis=%u total=%u rpMask=%u alpha=%u shadow=%u dist=%u frust=%u area=%u hiZ=%u prevVisSkip=%u (meshlet tot=%u frust=%u area=%u hiZ=%u vis=%u)',
             [aInFlightFrameIndex,fLastDebugVisibleCounts[aInFlightFrameIndex],DebugVisible,
              PpvUInt32(TpvPtrUInt(DebugCountersPtr)+( 0*SizeOf(TpvUInt32)))^,
              PpvUInt32(TpvPtrUInt(DebugCountersPtr)+( 1*SizeOf(TpvUInt32)))^,
              PpvUInt32(TpvPtrUInt(DebugCountersPtr)+( 2*SizeOf(TpvUInt32)))^,
              PpvUInt32(TpvPtrUInt(DebugCountersPtr)+( 3*SizeOf(TpvUInt32)))^,
              PpvUInt32(TpvPtrUInt(DebugCountersPtr)+( 4*SizeOf(TpvUInt32)))^,
              PpvUInt32(TpvPtrUInt(DebugCountersPtr)+( 5*SizeOf(TpvUInt32)))^,
              PpvUInt32(TpvPtrUInt(DebugCountersPtr)+( 6*SizeOf(TpvUInt32)))^,
              PpvUInt32(TpvPtrUInt(DebugCountersPtr)+( 7*SizeOf(TpvUInt32)))^,
              PpvUInt32(TpvPtrUInt(DebugCountersPtr)+( 9*SizeOf(TpvUInt32)))^,
              PpvUInt32(TpvPtrUInt(DebugCountersPtr)+(11*SizeOf(TpvUInt32)))^,
              PpvUInt32(TpvPtrUInt(DebugCountersPtr)+(12*SizeOf(TpvUInt32)))^,
              PpvUInt32(TpvPtrUInt(DebugCountersPtr)+(13*SizeOf(TpvUInt32)))^,
              PpvUInt32(TpvPtrUInt(DebugCountersPtr)+(14*SizeOf(TpvUInt32)))^,
              PpvUInt32(TpvPtrUInt(DebugCountersPtr)+(15*SizeOf(TpvUInt32)))^]));
    end;
    fLastDebugVisibleCounts[aInFlightFrameIndex]:=DebugVisible;
   finally
    fDebugCullCountersBuffers[aInFlightFrameIndex].Memory.UnmapMemory;
   end;
  end;
  // Clear counters for this frame
  aCommandBuffer.CmdFillBuffer(fDebugCullCountersBuffers[aInFlightFrameIndex].Handle,0,64,0);
  FillChar(BufferMemoryBarriers[0],SizeOf(TVkBufferMemoryBarrier),#0);
  BufferMemoryBarriers[0].sType:=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
  BufferMemoryBarriers[0].srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
  BufferMemoryBarriers[0].dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  BufferMemoryBarriers[0].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[0].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[0].buffer:=fDebugCullCountersBuffers[aInFlightFrameIndex].Handle;
  BufferMemoryBarriers[0].offset:=0;
  BufferMemoryBarriers[0].size:=64;
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,0,nil,1,@BufferMemoryBarriers[0],0,nil);
 end;
{$endif}

 PreviousInFlightFrameIndex:=FrameGraph.DrawPreviousInFlightFrameIndex;

 case fCullRenderPass of
  TpvScene3DRendererCullRenderPass.FinalView:begin
   RenderPass:=TpvScene3DRendererRenderPass.View;
   Part:=0;
  end;
  TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
   RenderPass:=TpvScene3DRendererRenderPass.CascadedShadowMap;
   Part:=1;
  end;
  else begin
   exit;
  end;
 end;

 // Explicit inter-pass barrier for the HiZ CullDepthPyramid image (not a framegraph
 // resource, so the framegraph does not emit automatic barriers between
 // CullDepthPyramidComputePass and this pass). Covers cross-queue / cross-frame
 // overlap cases when ParallelQueues is enabled.
 begin
  FillChar(PyramidImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
  PyramidImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  PyramidImageMemoryBarrier.pNext:=nil;
  PyramidImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  PyramidImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  PyramidImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  PyramidImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
  PyramidImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  PyramidImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  case fCullRenderPass of
   TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
    PyramidImageMemoryBarrier.image:=fInstance.CascadedShadowMapCullDepthPyramidMipmappedArray2DImages[aInFlightFrameIndex].VulkanImage.Handle;
    PyramidImageMemoryBarrier.subresourceRange.levelCount:=fInstance.CascadedShadowMapCullDepthPyramidMipmappedArray2DImages[aInFlightFrameIndex].MipMapLevels;
    PyramidImageMemoryBarrier.subresourceRange.layerCount:=TpvScene3DRendererInstance.CountCascadedShadowMapCascades;
   end;
   else begin
    PyramidImageMemoryBarrier.image:=fInstance.CullDepthPyramidMipmappedArray2DImages[aInFlightFrameIndex].VulkanImage.Handle;
    PyramidImageMemoryBarrier.subresourceRange.levelCount:=fInstance.CullDepthPyramidMipmappedArray2DImages[aInFlightFrameIndex].MipMapLevels;
    PyramidImageMemoryBarrier.subresourceRange.layerCount:=fInstance.CountSurfaceViews;
   end;
  end;
  PyramidImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  PyramidImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  PyramidImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@PyramidImageMemoryBarrier);
 end;

 begin

  fPlanetCullPass.Execute(aCommandBuffer,aInFlightFrameIndex);

  fInstance.Renderer.VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3D.Mesh',[0.5,0.25,0.75,1.0]);

  BufferMemoryBarriers[0]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.PerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  BufferMemoryBarriers[1]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.PerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  BufferMemoryBarriers[2]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                         TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.GPUDrawIndexedIndirectCommandOutputBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  BufferMemoryBarriers[3]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                         TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.GPUDrawIndexedIndirectCommandCounterBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT) or
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or
                                    TVkPipelineStageFlags(IfThen(fMeshShader,
                                                                 TVkFlags(VK_PIPELINE_STAGE_TASK_SHADER_BIT_EXT) or
                                                                 TVkFlags(VK_PIPELINE_STAGE_MESH_SHADER_BIT_EXT),
                                                                 0)),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                    0,
                                    0,nil,
                                    4,@BufferMemoryBarriers[0],
                                    0,nil);

  begin

   CountRanges:=fInstance.PerInFlightFrameMeshCullBatchRangeCounts[aInFlightFrameIndex,fCullRenderPass];
   TotalCommands:=fInstance.PerInFlightFrameMeshCullTotalCommands[aInFlightFrameIndex,fCullRenderPass];

   if (CountRanges>0) and (TotalCommands>0) then begin

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
    ResetPushConstants.CullDispatchIndex:=TpvUInt32(Part);

    aCommandBuffer.CmdPushConstants(fInstance.MeshCullReset.PipelineLayout.Handle,
                                    TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                    0,
                                    SizeOf(ResetPushConstants),
                                    @ResetPushConstants);

    if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
     fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.Dispatch,'MeshCullPass1ComputePass.ResetDispatch');
    end;
    aCommandBuffer.CmdDispatch((CountRanges+255) shr 8,1,1);
    if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
     fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
    end;

   end;

  end;

  if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
   fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.FillBuffer,'MeshCullPass1ComputePass.FillVisibility');
  end;
  aCommandBuffer.CmdFillBuffer(fInstance.PerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[aInFlightFrameIndex].Handle,
                               fInstance.PerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBufferPartSizes[aInFlightFrameIndex]*TpvUInt32(Part)*SizeOf(TVkUInt32),
                               fInstance.PerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBufferPartSizes[aInFlightFrameIndex]*SizeOf(TVkUInt32),
                               0);
  if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
   fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
  end;

  if fInstance.Renderer.UseMeshletExpand and assigned(fSortPipeline) then begin
   // Barrier: previous pass's compute write on ScratchBuffer -> this pass's FillBuffer
   // (Without this, a WAW hazard exists between mesh_cull passes that share the scratch buffer.)
   BufferMemoryBarriers[0]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                          TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                          VK_QUEUE_FAMILY_IGNORED,
                                                          VK_QUEUE_FAMILY_IGNORED,
                                                          fInstance.MeshCullScratchBuffers[aInFlightFrameIndex].Handle,
                                                          0,
                                                          VK_WHOLE_SIZE);
   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                     0,
                                     0,nil,
                                     1,@BufferMemoryBarriers[0],
                                     0,nil);
   aCommandBuffer.CmdFillBuffer(fInstance.MeshCullScratchBuffers[aInFlightFrameIndex].Handle,0,4,0);
  end;

  // Clear current-frame part of meshlet visibility bitmap for this cull render pass
  if assigned(fInstance.PerInFlightFrameMeshletVisibilityBuffers[aInFlightFrameIndex,fCullRenderPass]) then begin
   aCommandBuffer.CmdFillBuffer(fInstance.PerInFlightFrameMeshletVisibilityBuffers[aInFlightFrameIndex,fCullRenderPass].Handle,
                                0,
                                fInstance.PerInFlightFrameMeshletVisibilityBufferPartSizes[aInFlightFrameIndex,fCullRenderPass]*SizeOf(TVkUInt32),
                                0);
  end;

  BufferMemoryBarriers[0]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                         TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.PerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  BufferMemoryBarriers[1]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.GPUDrawIndexedIndirectCommandCounterBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  BufferMemoryBarriers[2]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.MeshCullIndirectDispatchBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  if fInstance.Renderer.UseMeshletExpand and assigned(fSortPipeline) then begin
   BufferMemoryBarriers[3]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                          TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                          VK_QUEUE_FAMILY_IGNORED,
                                                          VK_QUEUE_FAMILY_IGNORED,
                                                          fInstance.MeshCullScratchBuffers[aInFlightFrameIndex].Handle,
                                                          0,
                                                          VK_WHOLE_SIZE);
   if assigned(fInstance.PerInFlightFrameMeshletVisibilityBuffers[aInFlightFrameIndex,fCullRenderPass]) then begin
    BufferMemoryBarriers[4]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                            TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                            VK_QUEUE_FAMILY_IGNORED,
                                                            VK_QUEUE_FAMILY_IGNORED,
                                                            fInstance.PerInFlightFrameMeshletVisibilityBuffers[aInFlightFrameIndex,fCullRenderPass].Handle,
                                                            0,
                                                            VK_WHOLE_SIZE);
    aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT) or
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT),
                                      0,
                                      0,nil,
                                      5,@BufferMemoryBarriers[0],
                                      0,nil);
   end else begin
    aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT) or
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT),
                                      0,
                                      0,nil,
                                      4,@BufferMemoryBarriers[0],
                                      0,nil);
   end;
  end else begin
   if assigned(fInstance.PerInFlightFrameMeshletVisibilityBuffers[aInFlightFrameIndex,fCullRenderPass]) then begin
    BufferMemoryBarriers[3]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                            TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                            VK_QUEUE_FAMILY_IGNORED,
                                                            VK_QUEUE_FAMILY_IGNORED,
                                                            fInstance.PerInFlightFrameMeshletVisibilityBuffers[aInFlightFrameIndex,fCullRenderPass].Handle,
                                                            0,
                                                            VK_WHOLE_SIZE);
    aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT) or
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT),
                                      0,
                                      0,nil,
                                      4,@BufferMemoryBarriers[0],
                                      0,nil);
   end else begin
    aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT) or
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT),
                                      0,
                                      0,nil,
                                      3,@BufferMemoryBarriers[0],
                                      0,nil);
   end;
  end;

  if fInstance.Renderer.Scene3D.MeshShaders and assigned(fMeshShaderPipeline) then begin
   aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fMeshShaderPipeline.Handle);
  end else begin
   aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipeline.Handle);
  end;

  DescriptorSets[0]:=fInstance.MeshCullPass1ComputeVulkanDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[1]:=fInstance.Scene3D.GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[2]:=fInstance.Scene3D.GlobalBoundingSphereVulkanDescriptorSets[aInFlightFrameIndex].Handle;
  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       fPipelineLayout.Handle,
                                       0,
                                       3,
                                       @DescriptorSets[0],
                                       0,
                                       nil);

  begin

   CountRanges:=fInstance.PerInFlightFrameMeshCullBatchRangeCounts[aInFlightFrameIndex,fCullRenderPass];
   TotalCommands:=fInstance.PerInFlightFrameMeshCullTotalCommands[aInFlightFrameIndex,fCullRenderPass];

   if (CountRanges>0) and (TotalCommands>0) then begin

    PushConstants.CountRanges:=CountRanges;
    PushConstants.TotalCommands:=TotalCommands;
    PushConstants.CountMeshObjectIDs:=fInstance.PerInFlightFrameGPUCountMeshObjectIDsArray[aInFlightFrameIndex];
    PushConstants.SkipCulling:=0;
    PushConstants.BatchRangeOffset:=fInstance.PerInFlightFrameMeshCullBatchRangeOffsets[aInFlightFrameIndex,fCullRenderPass];
    PushConstants.PrefixSumOffset:=fInstance.PerInFlightFrameMeshCullPrefixSumOffsets[aInFlightFrameIndex,fCullRenderPass];
    PushConstants.VisibilityBufferOffset:=fInstance.PerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBufferPartSizes[aInFlightFrameIndex]*TpvUInt32(Part);
    PushConstants.TextureDepthIndex:=Part;
    case fCullRenderPass of
     TpvScene3DRendererCullRenderPass.FinalView:begin
      PushConstants.BaseViewIndex:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].FinalViewIndex;
      PushConstants.CountViews:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].CountFinalViews;
      PushConstants.RenderPassMask:=TpvUInt32(1) shl TpvUInt32(ord(TpvScene3DRendererRenderPass.View));
      PushConstants.AlphaModeMask:=(TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Opaque))) or (TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Mask))) or (TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Blend))); // Opaque+Mask+Blend
     end;
     TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
      PushConstants.BaseViewIndex:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].CascadedShadowMapViewIndex;
      PushConstants.CountViews:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].CountCascadedShadowMapViews;
      PushConstants.RenderPassMask:=TpvUInt32(1) shl TpvUInt32(ord(TpvScene3DRendererRenderPass.CascadedShadowMap));
      PushConstants.AlphaModeMask:=(TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Opaque))) or (TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Mask))); // Opaque+Mask only
     end;
     else begin
      Assert(false);
      PushConstants.RenderPassMask:=$ffff;
      PushConstants.AlphaModeMask:=(TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Opaque))) or (TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Mask))) or (TpvUInt32(1) shl TpvUInt32(ord(TpvScene3D.TMaterial.TAlphaMode.Blend)));
     end;
    end;

    PushConstants.RendererInstanceIndex:=TpvUInt32(fInstance.RendererInstanceIndex);
    PushConstants.Flags:=0;
    if fInstance.Scene3D.GPULODEnabled then begin
     case fCullRenderPass of
      TpvScene3DRendererCullRenderPass.FinalView:begin
       PushConstants.Flags:=PushConstants.Flags or TpvUInt32(1 shl 0); // FLAG_LOD_ENABLED
      end;
      else begin
       // LOD selection only for final view pass for now
      end;
     end;
     if not fInstance.Scene3D.LODTransformAllLevels then begin
      PushConstants.Flags:=PushConstants.Flags or TpvUInt32(1 shl 1); // FLAG_LOD_TEMPORAL
     end;
     if fInstance.Scene3D.LODFrameCounter<fInstance.Scene3D.CountInFlightFrames then begin
      PushConstants.Flags:=PushConstants.Flags or TpvUInt32(1 shl 2); // FLAG_LOD_RESET_FRAME
     end;
     if assigned(fInstance.LODLevelBuffers[aInFlightFrameIndex]) then begin
      PushConstants.LODLevelCurrentBDA:=fInstance.LODLevelBuffers[aInFlightFrameIndex].DeviceAddress;
     end else begin
      PushConstants.LODLevelCurrentBDA:=0;
     end;
     if assigned(fInstance.LODLevelBuffers[PreviousInFlightFrameIndex]) then begin
      PushConstants.LODLevelPreviousBDA:=fInstance.LODLevelBuffers[PreviousInFlightFrameIndex].DeviceAddress;
     end else begin
      PushConstants.LODLevelPreviousBDA:=0;
     end;
    end else begin 
     PushConstants.LODLevelCurrentBDA:=0;
     PushConstants.LODLevelPreviousBDA:=0;
    end;

    if fInstance.Renderer.UseMeshletCulling and assigned(fMeshShaderPipeline) then begin
     PushConstants.Flags:=PushConstants.Flags or TpvUInt32(1 shl 3); // FLAG_MESHLET_CULLING_ENABLED
    end;

    if fCullRenderPass=TpvScene3DRendererCullRenderPass.CascadedShadowMap then begin
     PushConstants.Flags:=PushConstants.Flags or TpvUInt32(1 shl 4); // FLAG_SHADOW_PASS
    end;

    if fInstance.KeepPass0ForRendering then begin
     PushConstants.Flags:=PushConstants.Flags or TpvUInt32(1 shl 5); // FLAG_KEEP_PASS0_FOR_RENDERING (Variante a net, default on)
    end;

    if fInstance.KeepPass0InPass1 then begin
     PushConstants.Flags:=PushConstants.Flags or TpvUInt32(1 shl 6); // FLAG_KEEP_PASS0_IN_PASS1 (diagnostic, breaks culling, default off)
    end;

    PushConstants.MaxOutputCommands:=fInstance.GPUDrawIndexedIndirectCommandOutputBufferSizes[aInFlightFrameIndex];

    if fInstance.Renderer.UseMeshletExpand then begin
     PushConstants.ScratchBufferBDA:=fInstance.MeshCullScratchBuffers[aInFlightFrameIndex].DeviceAddress;
     PushConstants.MaxScratchEntries:=fInstance.MeshCullMaxScratchEntries[aInFlightFrameIndex];
    end else begin
     PushConstants.ScratchBufferBDA:=0;
     PushConstants.MaxScratchEntries:=0;
    end;

    if assigned(fInstance.PerInFlightFrameMeshletVisibilityBuffers[aInFlightFrameIndex,fCullRenderPass]) then begin
     PushConstants.MeshletVisibilityBDA:=fInstance.PerInFlightFrameMeshletVisibilityBuffers[aInFlightFrameIndex,fCullRenderPass].DeviceAddress;
     PushConstants.MeshletVisibilityPartOffset:=0;
    end else begin
     PushConstants.MeshletVisibilityBDA:=0;
     PushConstants.MeshletVisibilityPartOffset:=0;
    end;

{$ifdef MeshCullDebugCounters}
    PushConstants.DebugCountersBDAPad:=0;
    PushConstants.DebugCountersBDA:=0;
    if (fCullRenderPass=TpvScene3DRendererCullRenderPass.FinalView) and assigned(fDebugCullCountersBuffers[aInFlightFrameIndex]) then begin
     PushConstants.DebugCountersBDA:=fDebugCullCountersBuffers[aInFlightFrameIndex].DeviceAddress;
    end;
{$endif}

    case fCullRenderPass of
     TpvScene3DRendererCullRenderPass.FinalView:begin
      PushConstants.MaximumDistance:=fInstance.FinalViewMaximumDistance;
      PushConstants.AreaTooSmallThreshold:=fInstance.FinalViewAreaTooSmallThreshold;
     end;
     TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
      PushConstants.MaximumDistance:=fInstance.ShadowMaximumDistance;
      PushConstants.AreaTooSmallThreshold:=fInstance.ShadowAreaTooSmallThreshold;
     end;
     else begin
      PushConstants.MaximumDistance:=-1.0;
      PushConstants.AreaTooSmallThreshold:=-1.0;
     end;
    end;

    if Part=0 then begin
     PushConstants.OutputCommandSlotOffset:=0;
    end else begin
     PushConstants.OutputCommandSlotOffset:=fInstance.PerInFlightFrameGPUDrawIndexedIndirectCommandCSMOffsets[aInFlightFrameIndex];
    end;

    if fInstance.Scene3D.UseMegaDispatch then begin

     PushConstants.BatchRangeIndex:=-1;

     aCommandBuffer.CmdPushConstants(fPipelineLayout.Handle,
                                     TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                     0,
                                     SizeOf(TpvScene3DRendererPassesMeshCullPass1ComputePass.TPushConstants),
                                     @PushConstants);

     if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
      fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.Dispatch,'MeshCullPass1ComputePass.Dispatch');
     end;
     aCommandBuffer.CmdDispatchIndirect(fInstance.MeshCullIndirectDispatchBuffers[aInFlightFrameIndex].Handle,
                                        TpvUInt32(Part)*SizeOf(TVkDispatchIndirectCommand));
     if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
      fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
     end;

    end else begin

     BatchRangeOffset:=fInstance.PerInFlightFrameMeshCullBatchRangeOffsets[aInFlightFrameIndex,fCullRenderPass];

     for RangeIndex:=0 to CountRanges-1 do begin

      RangeCountCommands:=fInstance.GPUBatchRanges[BatchRangeOffset+RangeIndex].CountCommands;

      PushConstants.BatchRangeIndex:=TpvInt32(RangeIndex);

      aCommandBuffer.CmdPushConstants(fPipelineLayout.Handle,
                                      TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                      0,
                                      SizeOf(TpvScene3DRendererPassesMeshCullPass1ComputePass.TPushConstants),
                                      @PushConstants);

      if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
       fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.Dispatch,'MeshCullPass1ComputePass.Dispatch');
      end;
      aCommandBuffer.CmdDispatch((RangeCountCommands+255) shr 8,1,1);
      if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
       fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
      end;

     end;

    end;

   end;

  end;

  // Sort dispatch for MESHLET_EXPAND: scatter scratch entries to per-range output positions
  if fInstance.Renderer.UseMeshletExpand and assigned(fSortPipeline) then begin

   // Barrier: mesh_cull scratch writes -> sort shader reads
   BufferMemoryBarriers[0]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                          TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                          VK_QUEUE_FAMILY_IGNORED,
                                                          VK_QUEUE_FAMILY_IGNORED,
                                                          fInstance.MeshCullScratchBuffers[aInFlightFrameIndex].Handle,
                                                          0,
                                                          VK_WHOLE_SIZE);
   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     0,
                                     0,nil,
                                     1,@BufferMemoryBarriers[0],
                                     0,nil);

   aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fSortPipeline.Handle);

   SortPushConstants.ScratchBufferBDA:=fInstance.MeshCullScratchBuffers[aInFlightFrameIndex].DeviceAddress;
   SortPushConstants.ExpandRangeInfoBDA:=fInstance.PerInFlightFrameExpandRangeInfoBuffers[aInFlightFrameIndex].DeviceAddress;
   SortPushConstants.OutputCommandsBDA:=fInstance.GPUDrawIndexedIndirectCommandOutputBuffers[aInFlightFrameIndex].DeviceAddress;
   SortPushConstants.CountersBDA:=fInstance.GPUDrawIndexedIndirectCommandCounterBuffers[aInFlightFrameIndex].DeviceAddress;

   aCommandBuffer.CmdPushConstants(fSortPipelineLayout.Handle,
                                   TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                   0,
                                   SizeOf(SortPushConstants),
                                   @SortPushConstants);

   if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
    fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.Dispatch,'MeshCullPass1ComputePass.SortDispatch');
   end;
   aCommandBuffer.CmdDispatch((fInstance.MeshCullMaxScratchEntries[aInFlightFrameIndex]+255) shr 8,1,1);
   if assigned(fInstance.Renderer.VulkanDevice.BreadcrumbBuffer) then begin
    fInstance.Renderer.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
   end;

  end;

  BufferMemoryBarriers[0]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.PerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  BufferMemoryBarriers[1]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.PerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  BufferMemoryBarriers[2]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.GPUDrawIndexedIndirectCommandOutputBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  BufferMemoryBarriers[3]:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         VK_QUEUE_FAMILY_IGNORED,
                                                         fInstance.GPUDrawIndexedIndirectCommandCounterBuffers[aInFlightFrameIndex].Handle,
                                                         0,
                                                         VK_WHOLE_SIZE);

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT) or
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or
                                    TVkPipelineStageFlags(IfThen(fMeshShader,
                                                                 TVkFlags(VK_PIPELINE_STAGE_TASK_SHADER_BIT_EXT) or
                                                                 TVkFlags(VK_PIPELINE_STAGE_MESH_SHADER_BIT_EXT),
                                                                 0)),
                                    0,
                                    0,nil,
                                    4,@BufferMemoryBarriers[0],
                                    0,nil);

  fInstance.Renderer.VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

 end;

end;

end.
