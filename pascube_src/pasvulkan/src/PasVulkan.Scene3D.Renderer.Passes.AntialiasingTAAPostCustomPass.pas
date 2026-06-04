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
unit PasVulkan.Scene3D.Renderer.Passes.AntialiasingTAAPostCustomPass;
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

type { TpvScene3DRendererPassesAntialiasingTAAPostCustomPass }
     TpvScene3DRendererPassesAntialiasingTAAPostCustomPass=class(TpvFrameGraph.TCustomPass)
      private
       fInstance:TpvScene3DRendererInstance;
       fResourceColor:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceDepth:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceVelocity:TpvFrameGraph.TPass.TUsedImageResource;
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

{ TpvScene3DRendererPassesAntialiasingTAAPostCustomPass }

constructor TpvScene3DRendererPassesAntialiasingTAAPostCustomPass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
 inherited Create(aFrameGraph);
 fInstance:=aInstance;
 Name:='AntialiasingTAAPostCustomPass';

 fResourceColor:=AddImageInput('resourcetype_color_temporal_antialiasing',
                               'resource_temporal_antialiasing_color',
                               VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                               []
                              );

 fResourceDepth:=AddImageInput('resourcetype_depth',
                               'resource_depth_data',
                               VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                               []
                              );

 fResourceVelocity:=AddImageInput('resourcetype_velocity',
                                  'resource_velocity_data',
                                  VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                                  []
                                 );

end;

destructor TpvScene3DRendererPassesAntialiasingTAAPostCustomPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesAntialiasingTAAPostCustomPass.AcquirePersistentResources;
begin
 inherited AcquirePersistentResources;
end;

procedure TpvScene3DRendererPassesAntialiasingTAAPostCustomPass.ReleasePersistentResources;
begin
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesAntialiasingTAAPostCustomPass.AcquireVolatileResources;
begin
 inherited AcquireVolatileResources;
end;

procedure TpvScene3DRendererPassesAntialiasingTAAPostCustomPass.ReleaseVolatileResources;
begin
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesAntialiasingTAAPostCustomPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesAntialiasingTAAPostCustomPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var ImageMemoryBarriers:array[0..2] of TVkImageMemoryBarrier;
    ImageSubresourceRange:TVkImageSubresourceRange;
    ImageBlit:TVkImageBlit;
begin
 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                      TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL),
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      fInstance.TAAHistoryColorImages[aInFlightFrameIndex].VulkanImage.Handle,
                                                      TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                      0,
                                                                                      1,
                                                                                      0,
                                                                                      fInstance.CountSurfaceViews));

 ImageMemoryBarriers[1]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                                      TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT) or
                                                      TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                      TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL),
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      fInstance.TAAHistoryDepthImages[aInFlightFrameIndex].VulkanImage.Handle,
                                                      TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT),
                                                                                      0,
                                                                                      1,
                                                                                      0,
                                                                                      fInstance.CountSurfaceViews));

 ImageMemoryBarriers[2]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or
                                                      TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT) or
                                                      TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                      TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL),
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      fInstance.TAAHistoryVelocityImages[aInFlightFrameIndex].VulkanImage.Handle,
                                                      TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                      0,
                                                                                      1,
                                                                                      0,
                                                                                      fInstance.CountSurfaceViews));

 aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT),
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                   TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT),
                                   0,
                                   nil,
                                   0,
                                   nil,
                                   3,
                                   @ImageMemoryBarriers[0]);

 FillChar(ImageBlit,SizeOf(TVkImageBlit),#0);
 ImageBlit.srcSubresource:=TVkImageSubresourceLayers.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),0,0,1);
 ImageBlit.srcOffsets[0].x:=0;
 ImageBlit.srcOffsets[0].y:=0;
 ImageBlit.srcOffsets[0].z:=0;
 ImageBlit.srcOffsets[1].x:=fResourceColor.Width;
 ImageBlit.srcOffsets[1].y:=fResourceColor.Height;
 ImageBlit.srcOffsets[1].z:=1;
 ImageBlit.dstSubresource:=TVkImageSubresourceLayers.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),0,0,1);
 ImageBlit.dstOffsets[0].x:=0;
 ImageBlit.dstOffsets[0].y:=0;
 ImageBlit.dstOffsets[0].z:=0;
 ImageBlit.dstOffsets[1].x:=fInstance.TAAHistoryColorImages[aInFlightFrameIndex].Width;
 ImageBlit.dstOffsets[1].y:=fInstance.TAAHistoryColorImages[aInFlightFrameIndex].Height;
 ImageBlit.dstOffsets[1].z:=1;

 aCommandBuffer.CmdBlitImage(fResourceColor.VulkanImages[aInFlightFrameIndex].Handle,
                             TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL),
                             fInstance.TAAHistoryColorImages[aInFlightFrameIndex].VulkanImage.Handle,
                             TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL),
                             1,
                             @ImageBlit,
                             VK_FILTER_NEAREST);

 FillChar(ImageBlit,SizeOf(TVkImageBlit),#0);
 ImageBlit.srcSubresource:=TVkImageSubresourceLayers.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT),0,0,1);
 ImageBlit.srcOffsets[0].x:=0;
 ImageBlit.srcOffsets[0].y:=0;
 ImageBlit.srcOffsets[0].z:=0;
 ImageBlit.srcOffsets[1].x:=fResourceDepth.Width;
 ImageBlit.srcOffsets[1].y:=fResourceDepth.Height;
 ImageBlit.srcOffsets[1].z:=1;
 ImageBlit.dstSubresource:=TVkImageSubresourceLayers.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT),0,0,1);
 ImageBlit.dstOffsets[0].x:=0;
 ImageBlit.dstOffsets[0].y:=0;
 ImageBlit.dstOffsets[0].z:=0;
 ImageBlit.dstOffsets[1].x:=fInstance.TAAHistoryDepthImages[aInFlightFrameIndex].Width;
 ImageBlit.dstOffsets[1].y:=fInstance.TAAHistoryDepthImages[aInFlightFrameIndex].Height;
 ImageBlit.dstOffsets[1].z:=1;

 aCommandBuffer.CmdBlitImage(fResourceDepth.VulkanImages[aInFlightFrameIndex].Handle,
                             TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL),
                             fInstance.TAAHistoryDepthImages[aInFlightFrameIndex].VulkanImage.Handle,
                             TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL),
                             1,
                             @ImageBlit,
                             VK_FILTER_NEAREST);

 FillChar(ImageBlit,SizeOf(TVkImageBlit),#0);
 ImageBlit.srcSubresource:=TVkImageSubresourceLayers.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),0,0,1);
 ImageBlit.srcOffsets[0].x:=0;
 ImageBlit.srcOffsets[0].y:=0;
 ImageBlit.srcOffsets[0].z:=0;
 ImageBlit.srcOffsets[1].x:=fResourceColor.Width;
 ImageBlit.srcOffsets[1].y:=fResourceColor.Height;
 ImageBlit.srcOffsets[1].z:=1;
 ImageBlit.dstSubresource:=TVkImageSubresourceLayers.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),0,0,1);
 ImageBlit.dstOffsets[0].x:=0;
 ImageBlit.dstOffsets[0].y:=0;
 ImageBlit.dstOffsets[0].z:=0;
 ImageBlit.dstOffsets[1].x:=fInstance.TAAHistoryVelocityImages[aInFlightFrameIndex].Width;
 ImageBlit.dstOffsets[1].y:=fInstance.TAAHistoryVelocityImages[aInFlightFrameIndex].Height;
 ImageBlit.dstOffsets[1].z:=1;

 aCommandBuffer.CmdBlitImage(fResourceVelocity.VulkanImages[aInFlightFrameIndex].Handle,
                             TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL),
                             fInstance.TAAHistoryVelocityImages[aInFlightFrameIndex].VulkanImage.Handle,
                             TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL),
                             1,
                             @ImageBlit,
                             VK_FILTER_NEAREST);


 ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or
                                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or
                                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      fInstance.TAAHistoryColorImages[aInFlightFrameIndex].VulkanImage.Handle,
                                                      TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                      0,
                                                                                      1,
                                                                                      0,
                                                                                      fInstance.CountSurfaceViews));

 ImageMemoryBarriers[1]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                      TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      fInstance.TAAHistoryDepthImages[aInFlightFrameIndex].VulkanImage.Handle,
                                                      TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT),
                                                                                      0,
                                                                                      1,
                                                                                      0,
                                                                                      fInstance.CountSurfaceViews));

 ImageMemoryBarriers[2]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or
                                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or
                                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      fInstance.TAAHistoryVelocityImages[aInFlightFrameIndex].VulkanImage.Handle,
                                                      TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                      0,
                                                                                      1,
                                                                                      0,
                                                                                      fInstance.CountSurfaceViews));

 aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT),
                                   TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT),
                                   0,
                                   nil,
                                   0,
                                   nil,
                                   3,
                                   @ImageMemoryBarriers[0]);


 if fInstance.fTAAEventReady[aInFlightFrameIndex] then begin
  Assert(false);
 end;
 aCommandBuffer.CmdSetEvent(fInstance.fTAAEvents[aInFlightFrameIndex].Handle,
                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT){
                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_GRAPHICS_BIT) or
                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or
                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or
                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT) or
                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT)});
 fInstance.fTAAEventReady[aInFlightFrameIndex]:=true;

end;

end.
