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
unit PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass;
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

type { TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass }
     TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass=class(TpvFrameGraph.TComputePass)
      public
       type TPushConstants=record
             MipMapLevel:TpvInt32;
             CascadeIndex:TpvInt32;
            end;
      private
       fInstance:TpvScene3DRendererInstance;
       fComputeShaderModule:TpvVulkanShaderModule;
       fVulkanPipelineShaderStageCompute:TpvVulkanPipelineShaderStage;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1,0..15] of TpvVulkanDescriptorSet;
       fPipelineLayout:TpvVulkanPipelineLayout;
       fPipeline:TpvVulkanComputePipeline;
       //fFirst:Boolean;
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

{ TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass }

constructor TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='GlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass';

 //fFirst:=true;

end;

destructor TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass.AcquirePersistentResources;
var Stream:TStream;
    Format:string;
begin

 inherited AcquirePersistentResources;

 Stream:=pvScene3DShaderVirtualFileSystem.GetFile('gi_voxel_occlusion_mipmap_comp.spv');
 try
  fComputeShaderModule:=TpvVulkanShaderModule.Create(fInstance.Renderer.VulkanDevice,Stream);
 finally
  Stream.Free;
 end;

 fVulkanPipelineShaderStageCompute:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fComputeShaderModule,'main');

end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fVulkanPipelineShaderStageCompute);
 FreeAndNil(fComputeShaderModule);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass.AcquireVolatileResources;
var InFlightFrameIndex,MipMapIndex,Index,CascadeIndex:TpvInt32;
    SourceDescriptorImageInfos,DestinationDescriptorImageInfos:TVkDescriptorImageInfoArray;
begin

 inherited AcquireVolatileResources;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames*16);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,fInstance.Renderer.CountInFlightFrames*1*16);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fInstance.Renderer.CountInFlightFrames*Max(1,fInstance.Renderer.GlobalIlluminationVoxelCountCascades)*2*16);
 fVulkanDescriptorPool.Initialize;

 fVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(fInstance.Renderer.VulkanDevice);
 fVulkanDescriptorSetLayout.AddBinding(0,
                                       VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                       1,
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(1,
                                       VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                       Max(1,fInstance.Renderer.GlobalIlluminationVoxelCountCascades),
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.AddBinding(2,
                                       VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                       Max(1,fInstance.Renderer.GlobalIlluminationVoxelCountCascades),
                                       TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                       []);
 fVulkanDescriptorSetLayout.Initialize;

 fPipelineLayout:=TpvVulkanPipelineLayout.Create(fInstance.Renderer.VulkanDevice);
 fPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                      0,
                                      SizeOf(TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass.TPushConstants));
 fPipelineLayout.AddDescriptorSetLayout(fVulkanDescriptorSetLayout);
 fPipelineLayout.Initialize;

 fPipeline:=TpvVulkanComputePipeline.Create(fInstance.Renderer.VulkanDevice,
                                            fInstance.Renderer.VulkanPipelineCache,
                                            0,
                                            fVulkanPipelineShaderStageCompute,
                                            fPipelineLayout,
                                            nil,
                                            0);

 FillChar(fVulkanDescriptorSets,SizeOf(fVulkanDescriptorSets),#0);

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin

  for MipMapIndex:=1 to fInstance.GlobalIlluminationCascadedVoxelConeTracingOcclusionImages[0].MipMapLevels-1 do begin

   SourceDescriptorImageInfos:=nil;
   DestinationDescriptorImageInfos:=nil;
   try

    SetLength(SourceDescriptorImageInfos,fInstance.Renderer.GlobalIlluminationVoxelCountCascades);
    SetLength(DestinationDescriptorImageInfos,fInstance.Renderer.GlobalIlluminationVoxelCountCascades);
    Index:=0;
    for CascadeIndex:=0 to fInstance.Renderer.GlobalIlluminationVoxelCountCascades-1 do begin
     SourceDescriptorImageInfos[Index]:=TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                      fInstance.GlobalIlluminationCascadedVoxelConeTracingOcclusionImages[CascadeIndex].VulkanImageViews[MipMapIndex-1].Handle,
                                                                      VK_IMAGE_LAYOUT_GENERAL);
     DestinationDescriptorImageInfos[Index]:=TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                           fInstance.GlobalIlluminationCascadedVoxelConeTracingOcclusionImages[CascadeIndex].VulkanImageViews[MipMapIndex].Handle,
                                                                           VK_IMAGE_LAYOUT_GENERAL);
     inc(Index);
    end;

    fVulkanDescriptorSets[InFlightFrameIndex,MipMapIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                                                         fVulkanDescriptorSetLayout);
    fVulkanDescriptorSets[InFlightFrameIndex,MipMapIndex].WriteToDescriptorSet(0,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                               [],
                                                                               [fInstance.GlobalIlluminationCascadedVoxelConeTracingUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                               [],
                                                                               false
                                                                              );
    fVulkanDescriptorSets[InFlightFrameIndex,MipMapIndex].WriteToDescriptorSet(1,
                                                                               0,
                                                                               length(SourceDescriptorImageInfos),
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                               SourceDescriptorImageInfos,
                                                                               [],
                                                                               [],
                                                                               false
                                                                              );
    fVulkanDescriptorSets[InFlightFrameIndex,MipMapIndex].WriteToDescriptorSet(2,
                                                                               0,
                                                                               length(DestinationDescriptorImageInfos),
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                               DestinationDescriptorImageInfos,
                                                                               [],
                                                                               [],
                                                                               false
                                                                              );
    fVulkanDescriptorSets[InFlightFrameIndex,MipMapIndex].Flush;

   finally
    SourceDescriptorImageInfos:=nil;
    DestinationDescriptorImageInfos:=nil;
   end;

  end;

 end;

end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass.ReleaseVolatileResources;
var InFlightFrameIndex,MipMapIndex:TpvInt32;
begin
 FreeAndNil(fPipeline);
 FreeAndNil(fPipelineLayout);
 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  for MipMapIndex:=0 to 15 do begin
   FreeAndNil(fVulkanDescriptorSets[InFlightFrameIndex,MipMapIndex]);
  end;
 end;
 FreeAndNil(fVulkanDescriptorSetLayout);
 FreeAndNil(fVulkanDescriptorPool);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameIndex,MipMapIndex,Index,CascadeIndex,SideIndex:TpvInt32;
    BufferMemoryBarrier:TVkBufferMemoryBarrier;
    ImageMemoryBarriers:array[0..15] of TVkImageMemoryBarrier;
    InFlightFrameState:TpvScene3DRendererInstance.PInFlightFrameState;
    PushConstants:TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass.TPushConstants;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 InFlightFrameIndex:=aInFlightFrameIndex;

 InFlightFrameState:=@fInstance.InFlightFrameStates^[InFlightFrameIndex];

 BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_HOST_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_UNIFORM_READ_BIT),
                                                    TVkAccessFlags(VK_ACCESS_UNIFORM_READ_BIT),
                                                    VK_QUEUE_FAMILY_IGNORED,
                                                    VK_QUEUE_FAMILY_IGNORED,
                                                    fInstance.GlobalIlluminationCascadedVoxelConeTracingUniformBuffers[InFlightFrameIndex].Handle,
                                                    0,
                                                    VK_WHOLE_SIZE);

 aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   0,
                                   0,nil,
                                   1,@BufferMemoryBarrier,
                                   0,nil);

 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fPipeline.Handle);

 for MipMapIndex:=1 to fInstance.GlobalIlluminationCascadedVoxelConeTracingOcclusionImages[0].MipMapLevels-1 do begin

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       fPipelineLayout.Handle,
                                       0,
                                       1,
                                       @fVulkanDescriptorSets[InFlightFrameIndex,MipMapIndex].Handle,
                                       0,
                                       nil);

  PushConstants.MipMapLevel:=MipMapIndex;

  for CascadeIndex:=0 to fInstance.Renderer.GlobalIlluminationVoxelCountCascades-1 do begin

   PushConstants.CascadeIndex:=CascadeIndex;

   aCommandBuffer.CmdPushConstants(fPipelineLayout.Handle,
                                   TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                   0,
                                   SizeOf(TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass.TPushConstants),
                                   @PushConstants);

   aCommandBuffer.CmdDispatch(((fInstance.Renderer.GlobalIlluminationVoxelGridSize shr MipMapIndex)+7) shr 3,
                              ((fInstance.Renderer.GlobalIlluminationVoxelGridSize shr MipMapIndex)+7) shr 3,
                              ((fInstance.Renderer.GlobalIlluminationVoxelGridSize shr MipMapIndex)+7) shr 3);

  end;

  if (MipMapIndex+1)<fInstance.GlobalIlluminationCascadedVoxelConeTracingOcclusionImages[0].MipMapLevels then begin
   Index:=0;
   for CascadeIndex:=0 to fInstance.Renderer.GlobalIlluminationVoxelCountCascades-1 do begin
    ImageMemoryBarriers[Index]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                             TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                             VK_IMAGE_LAYOUT_GENERAL,
                                                             VK_IMAGE_LAYOUT_GENERAL,
                                                             VK_QUEUE_FAMILY_IGNORED,
                                                             VK_QUEUE_FAMILY_IGNORED,
                                                             fInstance.GlobalIlluminationCascadedVoxelConeTracingOcclusionImages[CascadeIndex].VulkanImage.Handle,
                                                             TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                             MipMapIndex,
                                                                                             1,
                                                                                             0,
                                                                                             1));
    inc(Index);
   end;
   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     FrameGraph.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                     0,
                                     0,nil,
                                     0,nil,
                                     fInstance.Renderer.GlobalIlluminationVoxelCountCascades,@ImageMemoryBarriers[0]);
  end;

 end;

{begin

  Index:=0;
  for CascadeIndex:=0 to fInstance.Renderer.GlobalIlluminationVoxelCountCascades-1 do begin
   ImageMemoryBarriers[Index]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                            TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                            VK_IMAGE_LAYOUT_GENERAL,
                                                            VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                            VK_QUEUE_FAMILY_IGNORED,
                                                            VK_QUEUE_FAMILY_IGNORED,
                                                            fInstance.GlobalIlluminationCascadedVoxelConeTracingOcclusionImages[CascadeIndex].VulkanImage.Handle,
                                                            TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                            0,
                                                                                            fInstance.GlobalIlluminationCascadedVoxelConeTracingOcclusionImages[CascadeIndex].MipMapLevels,
                                                                                            0,
                                                                                            1));
   inc(Index);
  end;

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    FrameGraph.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                    0,
                                    0,nil,
                                    0,nil,
                                    fInstance.Renderer.GlobalIlluminationVoxelCountCascades,@ImageMemoryBarriers[0]);

 end;}

 Index:=0;
 for CascadeIndex:=0 to fInstance.Renderer.GlobalIlluminationVoxelCountCascades-1 do begin
  ImageMemoryBarriers[Index]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                           TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                           VK_IMAGE_LAYOUT_GENERAL,
                                                           VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                           VK_QUEUE_FAMILY_IGNORED,
                                                           VK_QUEUE_FAMILY_IGNORED,
                                                           fInstance.GlobalIlluminationCascadedVoxelConeTracingOcclusionImages[CascadeIndex].VulkanImage.Handle,
                                                           TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                           0,
                                                                                           fInstance.GlobalIlluminationCascadedVoxelConeTracingOcclusionImages[CascadeIndex].MipMapLevels,
                                                                                           0,
                                                                                           1));
  inc(Index);
 end;
 aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                   FrameGraph.VulkanDevice.PhysicalDevice.PipelineStageAllShaderBits,
                                   0,
                                   0,nil,
                                   0,nil,
                                   fInstance.Renderer.GlobalIlluminationVoxelCountCascades,@ImageMemoryBarriers[0]);


end;

end.
