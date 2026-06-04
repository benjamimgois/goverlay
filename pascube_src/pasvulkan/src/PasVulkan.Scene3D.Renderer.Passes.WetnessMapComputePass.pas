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
unit PasVulkan.Scene3D.Renderer.Passes.WetnessMapComputePass;
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
     PasVulkan.Scene3D.Renderer.SkyBox;

type { TpvScene3DRendererPassesWetnessMapComputePass }
     TpvScene3DRendererPassesWetnessMapComputePass=class(TpvFrameGraph.TComputePass)
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
       fResourceDepth:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceWetnessMap:TpvFrameGraph.TPass.TUsedImageResource;
       fVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fVulkanDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fWetnessMapComputePass:TpvScene3DPlanet.TWetnessMapComputePass;
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

{ TpvScene3DRendererPassesWetnessMapComputePass }

constructor TpvScene3DRendererPassesWetnessMapComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='WetnessMapComputePass';

 if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin

  fResourceDepth:=AddImageDepthInput('resourcetype_depth',
                                     'resource_depth_data',
                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                     []
                                    );

  fResourceWetnessMap:=AddImageOutput('resourcetype_wetnessmap',
                                      'resource_wetnessmap',
                                      VK_IMAGE_LAYOUT_GENERAL,
                                      TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                                   TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0)),
                                      []
                                     );

 end else begin

  fResourceDepth:=AddImageDepthInput('resourcetype_msaa_depth',
                                     'resource_msaa_depth_data',
                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                     []
                                    );

  fResourceWetnessMap:=AddImageOutput('resourcetype_msaa_wetnessmap',
                                      'resource_msaa_wetnessmap',
                                      VK_IMAGE_LAYOUT_GENERAL,
                                      TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Clear,
                                                                   TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0)),
                                      []
                                     );

 end;
 
end;

destructor TpvScene3DRendererPassesWetnessMapComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesWetnessMapComputePass.AcquirePersistentResources;
begin

 inherited AcquirePersistentResources;

 fWetnessMapComputePass:=TpvScene3DPlanet.TWetnessMapComputePass.Create(fInstance.Renderer,fInstance,fInstance.Renderer.Scene3D);

end;

procedure TpvScene3DRendererPassesWetnessMapComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fWetnessMapComputePass);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesWetnessMapComputePass.AcquireVolatileResources;
var InFlightFrameIndex:TpvInt32;
begin

 inherited AcquireVolatileResources;

 fVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(fInstance.Renderer.VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                       fInstance.Renderer.CountInFlightFrames*2);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,fInstance.Renderer.CountInFlightFrames*1);
 fVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,fInstance.Renderer.CountInFlightFrames*1);
 fVulkanDescriptorPool.Initialize;

 fVulkanDescriptorSetLayout:=fInstance.Renderer.Scene3D.WetnessMapDescriptorSetLayout;

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  fVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                                           fVulkanDescriptorSetLayout);
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                 [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                fResourceWetnessMap.VulkanImageViews[InFlightFrameIndex].Handle,
                                                                                                fResourceWetnessMap.ResourceTransition.Layout)],
                                                                 [],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE),
                                                                 [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                fResourceDepth.VulkanImageViews[InFlightFrameIndex].Handle,
                                                                                                fResourceDepth.ResourceTransition.Layout)],
                                                                 [],
                                                                 [],
                                                                 false
                                                                );
  fVulkanDescriptorSets[InFlightFrameIndex].Flush;

 end;

 fWetnessMapComputePass.AllocateResources;

end;

procedure TpvScene3DRendererPassesWetnessMapComputePass.ReleaseVolatileResources;
var InFlightFrameIndex:TpvInt32;
begin
 fWetnessMapComputePass.ReleaseResources;
 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  FreeAndNil(fVulkanDescriptorSets[InFlightFrameIndex]);
 end;
 fVulkanDescriptorSetLayout:=nil;
 FreeAndNil(fVulkanDescriptorPool);
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesWetnessMapComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesWetnessMapComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameIndex,CountImageMemoryBarriers:TpvInt32;
    BufferMemoryBarriers:array[0..3] of TVkBufferMemoryBarrier;
    ImageMemoryBarriers:array[0..3] of TVkImageMemoryBarrier;
    PushConstants:TPushConstants;
    ClearValues:array[0..0] of TVkClearValue;
    ImageSubresourceRange:TVkImageSubresourceRange;
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 InFlightFrameIndex:=aInFlightFrameIndex;

 ImageSubresourceRange:=TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                        0,
                                                        1,
                                                        0,
                                                        Max(1,fInstance.CountSurfaceViews));

 // Image layout transition for the wetness map for clear operation
 begin

  CountImageMemoryBarriers:=0;

  ImageMemoryBarriers[CountImageMemoryBarriers]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                                              TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                                              fResourceWetnessMap.ResourceTransition.Layout,
                                                                              VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, // for the clear operation
                                                                              VK_QUEUE_FAMILY_IGNORED,
                                                                              VK_QUEUE_FAMILY_IGNORED,
                                                                              fResourceWetnessMap.VulkanImages[InFlightFrameIndex].Handle,
                                                                              ImageSubresourceRange);
  inc(CountImageMemoryBarriers);

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                    TVkDependencyFlags(0),
                                    0,nil,
                                    0,nil,
                                    CountImageMemoryBarriers,@ImageMemoryBarriers);

 end;

 // Clear the wetness map
 begin

  ClearValues[0].color.float32[0]:=0.0;
  ClearValues[0].color.float32[1]:=0.0;
  ClearValues[0].color.float32[2]:=0.0;
  ClearValues[0].color.float32[3]:=0.0;

  aCommandBuffer.CmdClearColorImage(fResourceWetnessMap.VulkanImages[InFlightFrameIndex].Handle,
                                    VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                                    @ClearValues[0],
                                    1,
                                    @ImageSubresourceRange);

 end;

 // Image layout transition for the wetness map for compute shader usage
 begin

  CountImageMemoryBarriers:=0;

  ImageMemoryBarriers[CountImageMemoryBarriers]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                                              TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                                              VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                                                                              fResourceWetnessMap.ResourceTransition.Layout,
                                                                              VK_QUEUE_FAMILY_IGNORED,
                                                                              VK_QUEUE_FAMILY_IGNORED,
                                                                              fResourceWetnessMap.VulkanImages[InFlightFrameIndex].Handle,
                                                                              ImageSubresourceRange);
  inc(CountImageMemoryBarriers);

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                    TVkDependencyFlags(0),
                                    0,nil,
                                    0,nil,
                                    CountImageMemoryBarriers,@ImageMemoryBarriers);

 end;

 fWetnessMapComputePass.Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex,fResourceWetnessMap.VulkanImages[InFlightFrameIndex].Handle,fVulkanDescriptorSets[InFlightFrameIndex].Handle);

end;

end.
