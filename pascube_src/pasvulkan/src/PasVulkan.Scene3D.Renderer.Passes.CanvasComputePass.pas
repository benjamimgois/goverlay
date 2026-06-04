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
unit PasVulkan.Scene3D.Renderer.Passes.CanvasComputePass;
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
     PasVulkan.Scene3D.Renderer.Instance,
     PasVulkan.Scene3D.Renderer.SkyBox;

type { TpvScene3DRendererPassesCanvasComputePass }
     TpvScene3DRendererPassesCanvasComputePass=class(TpvFrameGraph.TComputePass)
      public
       type TPushConstants=packed record
             ViewBaseIndex:TpvUInt32;
             CountViews:TpvUInt32;
             CountAllViews:TpvUInt32;
             CountPrimitives:TpvUInt32;
             ViewPortSize:TpvVector2;
            end;
            PPushConstants=^TPushConstants;
      private
       fInstance:TpvScene3DRendererInstance;
       fComputeShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fSolidPrimitivePrimitiveBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanBuffer; 
       fSolidPrimitiveVertexBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
       fSolidPrimitiveIndexBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
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
     end;

implementation

{ TpvScene3DRendererPassesCanvasComputePass }

constructor TpvScene3DRendererPassesCanvasComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='CanvasComputePass';

end;

destructor TpvScene3DRendererPassesCanvasComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesCanvasComputePass.AcquirePersistentResources;
var Stream:TStream;
begin

 inherited AcquirePersistentResources;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('solid_primitive_comp.spv');
 try
  fComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModule,'main');

end;

procedure TpvScene3DRendererPassesCanvasComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStageCompute);
 FreeAndNil(fComputeShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesCanvasComputePass.AcquireVolatileResources;
var InFlightFrameIndex:TpvInt32;
begin

 inherited AcquireVolatileResources;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames*5);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,fInstance.Renderer.CountInFlightFrames*4);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,fInstance.Renderer.CountInFlightFrames*1);
 fVulkanDescriptorPool.Initialize;

 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0, // SourcePrimitives
                                       VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(1, // DestinationVertices
                                       VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(2, // DestinationIndices
                                       VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(3, // DestinationDrawIndexedIndirectCommand
                                       VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(4, // Views
                                       VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.Initialize;

 fPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TPushConstants));
 fPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 fPipelineLayout.Initialize;

 fPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                            fInstance.Renderer.VulkanPipelineCache,
                                            0,
                                            fVulkanPipelineShaderStageCompute,
                                            fPipelineLayout,
                                            nil,
                                            0);

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  fSolidPrimitivePrimitiveBuffers[InFlightFrameIndex]:=fInstance.SolidPrimitivePrimitiveBuffers[InFlightFrameIndex];
  fSolidPrimitiveVertexBuffers[InFlightFrameIndex]:=fInstance.SolidPrimitiveVertexBuffer;
  fSolidPrimitiveIndexBuffers[InFlightFrameIndex]:=fInstance.SolidPrimitiveIndexBuffer;
  fVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                                           fVulkanDescriptorSetLayout);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                 [],
                                                                 [fInstance.SolidPrimitivePrimitiveBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                 [],
                                                                 [fInstance.SolidPrimitiveVertexBuffer.DescriptorBufferInfo],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                 [],
                                                                 [fInstance.SolidPrimitiveIndexBuffer.DescriptorBufferInfo],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                 [],
                                                                 [fInstance.SolidPrimitiveIndirectDrawCommandBuffer.DescriptorBufferInfo],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                 [],
                                                                 [fInstance.VulkanViewUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                 [],
                                                                 false);
  fVulkanDescriptorSets[InFlightFrameIndex].Flush;
 end;

end;

procedure TpvScene3DRendererPassesCanvasComputePass.ReleaseVolatileResources;
var InFlightFrameIndex:TpvInt32;
begin
 FreeAndNil(fPipeline);
 FreeAndNil(fPipelineLayout);
 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[InFlightFrameIndex]);
 end;
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanDescriptorPool);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesCanvasComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesCanvasComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameIndex:TpvInt32;
    BufferMemoryBarriers:array[0..3] of TVkBufferMemoryBarrier;
    PushConstants:TPushConstants;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 InFlightFrameIndex:=aInFlightFrameIndex;

 if fInstance.SolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex].Count>0 then begin

  // Check if the buffers have changed since last frame, for example if the buffers were resized.
  if (fSolidPrimitivePrimitiveBuffers[InFlightFrameIndex]<>fInstance.SolidPrimitivePrimitiveBuffers[InFlightFrameIndex]) or
     (fSolidPrimitiveVertexBuffers[InFlightFrameIndex]<>fInstance.SolidPrimitiveVertexBuffer) or
     (fSolidPrimitiveIndexBuffers[InFlightFrameIndex]<>fInstance.SolidPrimitiveIndexBuffer) then begin
   if fSolidPrimitivePrimitiveBuffers[InFlightFrameIndex]<>fInstance.SolidPrimitivePrimitiveBuffers[InFlightFrameIndex] then begin
    fSolidPrimitivePrimitiveBuffers[InFlightFrameIndex]:=fInstance.SolidPrimitivePrimitiveBuffers[InFlightFrameIndex];
    fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                   0,
                                                                   1,
                                                                   TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                   [],
                                                                   [fInstance.SolidPrimitivePrimitiveBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                   [],
                                                                   false
                                                                  );
   end;
   if fSolidPrimitiveVertexBuffers[InFlightFrameIndex]<>fInstance.SolidPrimitiveVertexBuffer then begin
    fSolidPrimitiveVertexBuffers[InFlightFrameIndex]:=fInstance.SolidPrimitiveVertexBuffer;
    fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                   0,
                                                                   1,
                                                                   TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                   [],
                                                                   [fInstance.SolidPrimitiveVertexBuffer.DescriptorBufferInfo],
                                                                   [],
                                                                   false
                                                                  );
   end;
   if fSolidPrimitiveIndexBuffers[InFlightFrameIndex]<>fInstance.SolidPrimitiveIndexBuffer then begin
    fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                   0,
                                                                   1,
                                                                   TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                   [],
                                                                   [fInstance.SolidPrimitiveIndexBuffer.DescriptorBufferInfo],
                                                                   [],
                                                                   false
                                                                  );
   end;
   fVulkanDescriptorSets[InFlightFrameIndex].Flush;
  end;

  PushConstants.ViewBaseIndex:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].FinalViewIndex;
  PushConstants.CountViews:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].CountFinalViews;
  PushConstants.CountAllViews:=fInstance.InFlightFrameStates^[aInFlightFrameIndex].CountViews;
  PushConstants.CountPrimitives:=fInstance.SolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex].Count;
  PushConstants.ViewPortSize:=TpvVector2.Create(fInstance.Width,fInstance.Height);

  BufferMemoryBarriers[0].sType:=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
  BufferMemoryBarriers[0].pNext:=nil;
  BufferMemoryBarriers[0].srcAccessMask:=TVkAccessFlags(VK_ACCESS_HOST_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_HOST_READ_BIT) or TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
  BufferMemoryBarriers[0].dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  BufferMemoryBarriers[0].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[0].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[0].buffer:=fInstance.SolidPrimitivePrimitiveBuffers[InFlightFrameIndex].Handle;
  BufferMemoryBarriers[0].offset:=0;
  BufferMemoryBarriers[0].size:=VK_WHOLE_SIZE;

  BufferMemoryBarriers[1].sType:=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
  BufferMemoryBarriers[1].pNext:=nil;
  BufferMemoryBarriers[1].srcAccessMask:=TVkAccessFlags(VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT);
  BufferMemoryBarriers[1].dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  BufferMemoryBarriers[1].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[1].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[1].buffer:=fInstance.SolidPrimitiveVertexBuffer.Handle;
  BufferMemoryBarriers[1].offset:=0;
  BufferMemoryBarriers[1].size:=VK_WHOLE_SIZE;

  BufferMemoryBarriers[2].sType:=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
  BufferMemoryBarriers[2].pNext:=nil;
  BufferMemoryBarriers[2].srcAccessMask:=TVkAccessFlags(VK_ACCESS_INDEX_READ_BIT);
  BufferMemoryBarriers[2].dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  BufferMemoryBarriers[2].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[2].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[2].buffer:=fInstance.SolidPrimitiveIndexBuffer.Handle;
  BufferMemoryBarriers[2].offset:=0;
  BufferMemoryBarriers[2].size:=VK_WHOLE_SIZE;

  BufferMemoryBarriers[3].sType:=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
  BufferMemoryBarriers[3].pNext:=nil;
  BufferMemoryBarriers[3].srcAccessMask:=TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT);
  BufferMemoryBarriers[3].dstAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
  BufferMemoryBarriers[3].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[3].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[3].buffer:=fInstance.SolidPrimitiveIndirectDrawCommandBuffer.Handle;
  BufferMemoryBarriers[3].offset:=0;
  BufferMemoryBarriers[3].size:=VK_WHOLE_SIZE;

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_INPUT_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                    TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT),
                                    0,nil,
                                    4,@BufferMemoryBarriers,
                                    0,nil);

  // Clear SolidPrimitiveIndirectDrawCommandBuffer and set the second uint32 to 1 (so three vkCmdFillBuffer calls are needed)
  aCommandBuffer.CmdFillBuffer(fInstance.SolidPrimitiveIndirectDrawCommandBuffer.Handle,
                               0,
                               SizeOf(TpvUInt32),
                               0);
  aCommandBuffer.CmdFillBuffer(fInstance.SolidPrimitiveIndirectDrawCommandBuffer.Handle,
                               SizeOf(TpvUInt32),
                               SizeOf(TpvUInt32),
                               1);
  aCommandBuffer.CmdFillBuffer(fInstance.SolidPrimitiveIndirectDrawCommandBuffer.Handle,
                               SizeOf(TpvUInt32)*2,
                               (SizeOf(TVkDrawIndexedIndirectCommand)+SizeOf(TpvUInt32))-(SizeOf(TpvUInt32)*2),
                               0);

  BufferMemoryBarriers[3].sType:=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
  BufferMemoryBarriers[3].pNext:=nil;
  BufferMemoryBarriers[3].srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
  BufferMemoryBarriers[3].dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  BufferMemoryBarriers[3].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[3].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[3].buffer:=fInstance.SolidPrimitiveIndirectDrawCommandBuffer.Handle;
  BufferMemoryBarriers[3].offset:=0;
  BufferMemoryBarriers[3].size:=VK_WHOLE_SIZE;

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT),
                                    0,nil,
                                    1,@BufferMemoryBarriers[3],
                                    0,nil);

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipeline.Handle);

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       fPipelineLayout.Handle,
                                       0,
                                       1,
                                       @fVulkanDescriptorSets[InFlightFrameIndex].Handle,
                                       0,
                                       nil);

  aCommandBuffer.CmdPushConstants(fPipelineLayout.Handle,
                                  TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TPushConstants),
                                  @PushConstants);

  aCommandBuffer.CmdDispatch((PushConstants.CountPrimitives+255) shr 8,1,1);

  BufferMemoryBarriers[0].sType:=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
  BufferMemoryBarriers[0].pNext:=nil;
  BufferMemoryBarriers[0].srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  BufferMemoryBarriers[0].dstAccessMask:=TVkAccessFlags(VK_ACCESS_HOST_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_HOST_READ_BIT) or TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
  BufferMemoryBarriers[0].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[0].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[0].buffer:=fInstance.SolidPrimitivePrimitiveBuffers[InFlightFrameIndex].Handle;
  BufferMemoryBarriers[0].offset:=0;
  BufferMemoryBarriers[0].size:=VK_WHOLE_SIZE;

  BufferMemoryBarriers[1].sType:=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
  BufferMemoryBarriers[1].pNext:=nil;
  BufferMemoryBarriers[1].srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  BufferMemoryBarriers[1].dstAccessMask:=TVkAccessFlags(VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT);
  BufferMemoryBarriers[1].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[1].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[1].buffer:=fInstance.SolidPrimitiveVertexBuffer.Handle;
  BufferMemoryBarriers[1].offset:=0;
  BufferMemoryBarriers[1].size:=VK_WHOLE_SIZE;

  BufferMemoryBarriers[2].sType:=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
  BufferMemoryBarriers[2].pNext:=nil;
  BufferMemoryBarriers[2].srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  BufferMemoryBarriers[2].dstAccessMask:=TVkAccessFlags(VK_ACCESS_INDEX_READ_BIT);
  BufferMemoryBarriers[2].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[2].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[2].buffer:=fInstance.SolidPrimitiveIndexBuffer.Handle;
  BufferMemoryBarriers[2].offset:=0;
  BufferMemoryBarriers[2].size:=VK_WHOLE_SIZE;

  BufferMemoryBarriers[3].sType:=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
  BufferMemoryBarriers[3].pNext:=nil;
  BufferMemoryBarriers[3].srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
  BufferMemoryBarriers[3].dstAccessMask:=TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT);
  BufferMemoryBarriers[3].srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[3].dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  BufferMemoryBarriers[3].buffer:=fInstance.SolidPrimitiveIndirectDrawCommandBuffer.Handle;
  BufferMemoryBarriers[3].offset:=0;
  BufferMemoryBarriers[3].size:=VK_WHOLE_SIZE;

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_INPUT_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT),
                                    TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT),
                                    0,nil,
                                    4,@BufferMemoryBarriers,
                                    0,nil);

 end;

end;

end.
