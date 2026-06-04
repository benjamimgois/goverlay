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
unit PasVulkan.Scene3D.MeshCompute;
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
     PasMP,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Scene3D.Renderer.Globals;

type { TpvScene3DMeshCompute }
     TpvScene3DMeshCompute=class
      private
       fSceneInstance:TpvObject;
       fComputeShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fPipelineLayout:TpvVulkanPipelineLayout;
       fPipeline:TpvVulkanComputePipeline;
       fEvents:array[0..MaxInFlightFrames-1] of TpvVulkanEvent;
       fEventReady:array[0..MaxInFlightFrames-1] of boolean;
      public
       constructor Create(const aSceneInstance:TpvObject); reintroduce;
       destructor Destroy; override;
       procedure Reset;
       procedure Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex:TpvSizeInt;const aLabels:Boolean);
     end;

implementation

uses PasVulkan.Scene3D;

{ TpvScene3DMeshCompute }

constructor TpvScene3DMeshCompute.Create(const aSceneInstance:TpvObject);
var Index:TpvSizeInt;
    Stream:TStream;
begin

 inherited Create;

 fSceneInstance:=aSceneInstance;

 if TpvScene3D(fSceneInstance).RaytracingActive then begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_raytracing_comp.spv');
//Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_comp.spv');
 end else begin
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_comp.spv');
 end;
 try
  fComputeShaderModule:=TpvVulkanShaderModule.Create(TpvScene3D(fSceneInstance).VulkanDevice,Stream);
  TpvScene3D(fSceneInstance).VulkanDevice.DebugUtils.SetObjectName(fComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DMeshCompute.fComputeShaderModule');
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModule,'main');

 fPipelineLayout:=TpvVulkanPipelineLayout.Create(TpvScene3D(fSceneInstance).VulkanDevice);
 fPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TpvScene3D.TMeshComputeStagePushConstants));
 fPipelineLayout.AddDescriptorSetLayout(TpvScene3D(fSceneInstance).MeshComputeVulkanDescriptorSet0Layout);
 fPipelineLayout.AddDescriptorSetLayout(TpvScene3D(fSceneInstance).MeshComputeVulkanDescriptorSet1Layout);
 fPipelineLayout.Initialize;

 TpvScene3D(fSceneInstance).VulkanDevice.DebugUtils.SetObjectName(fPipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DMeshCompute.fPipelineLayout');

 fPipeline:=TpvVulkanComputePipeline.Create(TpvScene3D(fSceneInstance).VulkanDevice,
                                            TpvScene3D(fSceneInstance).VulkanPipelineCache,
                                            0,
                                            fVulkanPipelineShaderStageCompute,
                                            fPipelineLayout,
                                            nil,
                                            0);
 TpvScene3D(fSceneInstance).VulkanDevice.DebugUtils.SetObjectName(fPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DMeshCompute.fPipeline');

 for Index:=0 to TpvScene3D(fSceneInstance).CountInFlightFrames-1 do begin
  fEvents[Index]:=TpvVulkanEvent.Create(TpvScene3D(fSceneInstance).VulkanDevice);
  TpvScene3D(fSceneInstance).VulkanDevice.DebugUtils.SetObjectName(fEvents[Index].Handle,VK_OBJECT_TYPE_EVENT,'TpvScene3DMeshCompute.fEvents['+IntToStr(Index)+']');
  fEventReady[Index]:=false;
 end;

end;

destructor TpvScene3DMeshCompute.Destroy;
var Index:TpvSizeInt;
begin

 FreeAndNil(fPipeline);

 FreeAndNil(fPipelineLayout);

 for Index:=0 to TpvScene3D(fSceneInstance).CountInFlightFrames-1 do begin
  FreeAndNil(fEvents[Index]);
 end;

 FreeAndNil(fVulkanPipelineShaderStageCompute);

 FreeAndNil(fComputeShaderModule);

 inherited Destroy;

end;

procedure TpvScene3DMeshCompute.Reset;
var Index:TpvSizeInt;
begin
 for Index:=0 to TpvScene3D(fSceneInstance).CountInFlightFrames-1 do begin
  FreeAndNil(fEvents[Index]);
  fEvents[Index]:=TpvVulkanEvent.Create(TpvScene3D(fSceneInstance).VulkanDevice);
  TpvScene3D(fSceneInstance).VulkanDevice.DebugUtils.SetObjectName(fEvents[Index].Handle,VK_OBJECT_TYPE_EVENT,'TpvScene3DMeshCompute.fEvents['+IntToStr(Index)+']');
  fEventReady[Index]:=false;
 end;
end;

procedure TpvScene3DMeshCompute.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex:TpvSizeInt;const aLabels:Boolean);
var PreviousInFlightFrameIndex:TpvSizeInt;
    MemoryBarrier:TVkMemoryBarrier;
    FrameDoneMask:TPasMPUInt32;
begin

 FrameDoneMask:=TpvUInt32(1) shl aInFlightFrameIndex;

 if (TPasMPInterlocked.ExchangeBitwiseOr(TpvScene3D(fSceneInstance).fMeshComputeFrameDoneMask,FrameDoneMask) and FrameDoneMask)=0 then begin

  if aLabels then begin
   TpvScene3D(fSceneInstance).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'MeshCompute',[0.25,0.25,1.0,1.0]);
  end;

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipeline.Handle);
  TpvScene3D(fSceneInstance).UpdateCachedVertices(fPipeline,
                                                  aInFlightFrameIndex,
                                                  aCommandBuffer,
                                                  fPipelineLayout);
  if aInFlightFrameIndex=0 then begin
   PreviousInFlightFrameIndex:=TpvScene3D(fSceneInstance).CountInFlightFrames-1;
  end else begin
   PreviousInFlightFrameIndex:=aInFlightFrameIndex-1;
  end;

{ if fEventReady[aInFlightFrameIndex] then begin
   Assert(false);
  end;}
  aCommandBuffer.CmdSetEvent(fEvents[aInFlightFrameIndex].Handle,
                             TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT){
                             TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_INPUT_BIT) or
                             TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or
                             TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT)});
  fEventReady[aInFlightFrameIndex]:=true;

  if (aInFlightFrameIndex<>PreviousInFlightFrameIndex) and fEventReady[PreviousInFlightFrameIndex] then begin
   fEventReady[PreviousInFlightFrameIndex]:=false;
   FillChar(MemoryBarrier,SizeOf(TVkMemoryBarrier),#0);
   MemoryBarrier.sType:=VK_STRUCTURE_TYPE_MEMORY_BARRIER;
   MemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
   MemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT) or IfThen(TpvScene3D(fSceneInstance).RaytracingActive,TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR) or TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR),0);
   aCommandBuffer.CmdWaitEvents(1,
                                @fEvents[PreviousInFlightFrameIndex].Handle,
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT){
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_INPUT_BIT) or
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT)},
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT){
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_INPUT_BIT) or
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT)},
                                1,@MemoryBarrier,
                                0,nil,
                                0,nil);
   aCommandBuffer.CmdResetEvent(fEvents[PreviousInFlightFrameIndex].Handle,
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT){
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_INPUT_BIT) or
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT)});
  end else begin
   FillChar(MemoryBarrier,SizeOf(TVkMemoryBarrier),#0);
   MemoryBarrier.sType:=VK_STRUCTURE_TYPE_MEMORY_BARRIER;
   MemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
   MemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT) or IfThen(TpvScene3D(fSceneInstance).RaytracingActive,TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR) or TVkAccessFlags(VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR),0);
   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_INPUT_BIT) or
                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or
                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or
                                     IfThen(TpvScene3D(fSceneInstance).RaytracingActive,TVkPipelineStageFlags(VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR),0),
                                     0,
                                     1,@MemoryBarrier,
                                     0,nil,
                                     0,nil);
  end;

  if aLabels then begin
   TpvScene3D(fSceneInstance).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);
  end;

 end;

end;

end.
