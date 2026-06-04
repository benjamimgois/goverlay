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
unit PasVulkan.Scene3D.Renderer.Passes.DeepAndFastApproximateOrderIndependentTransparencyClearCustomPass;
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

type { TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass }
     TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass=class(TpvFrameGraph.TCustomPass)
      private
       fInstance:TpvScene3DRendererInstance;
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

{ TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass }

constructor TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
 inherited Create(aFrameGraph);
 fInstance:=aInstance;
 Name:='DeepAndFastApproximateOrderIndependentTransparencyClearCustomPass';
end;

destructor TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass.AcquirePersistentResources;
begin
 inherited AcquirePersistentResources;
end;

procedure TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass.ReleasePersistentResources;
begin
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass.AcquireVolatileResources;
begin
 inherited AcquireVolatileResources;
end;

procedure TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass.ReleaseVolatileResources;
begin
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var ClearValue:TVkClearColorValue;
    ImageSubresourceRanges:array[0..2] of TVkImageSubresourceRange;
    //BufferMemoryBarrier:TVkBufferMemoryBarrier;
    ImageMemoryBarriers:array[0..5] of TVkImageMemoryBarrier;
    CountImageMemoryBarriers:TpvInt32;
begin
 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 ImageSubresourceRanges[0]:=TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                            0,
                                                            1,
                                                            0,
                                                            fInstance.CountSurfaceViews);

 ImageSubresourceRanges[1]:=TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                            0,
                                                            1,
                                                            0,
                                                            fInstance.CountSurfaceViews*2);

 ImageSubresourceRanges[2]:=TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                            0,
                                                            1,
                                                            0,
                                                            fInstance.CountSurfaceViews);

 if fInstance.ZFar<0.0 then begin
  ClearValue.uint32[0]:=0;
  ClearValue.uint32[1]:=0;
  ClearValue.uint32[2]:=0;
  ClearValue.uint32[3]:=0;
 end else begin
  ClearValue.uint32[0]:=0;
  ClearValue.uint32[1]:=$ffffffff;
  ClearValue.uint32[2]:=$ffffffff;
  ClearValue.uint32[3]:=0;
 end;
 aCommandBuffer.CmdClearColorImage(fInstance.DeepAndFastApproximateOrderIndependentTransparencyFragmentCounterFragmentDepthsSampleMaskImage.VulkanImage.Handle,
                                   VK_IMAGE_LAYOUT_GENERAL,
                                   @ClearValue,
                                   1,
                                   @ImageSubresourceRanges[0]);

 ClearValue.uint32[0]:=0;
 ClearValue.uint32[1]:=0;
 ClearValue.uint32[2]:=0;
 ClearValue.uint32[3]:=0;
 aCommandBuffer.CmdClearColorImage(fInstance.DeepAndFastApproximateOrderIndependentTransparencyAverageImage.VulkanImage.Handle,
                                   VK_IMAGE_LAYOUT_GENERAL,
                                   @ClearValue,
                                   1,
                                   @ImageSubresourceRanges[0]);

 ClearValue.uint32[0]:=0;
 ClearValue.uint32[1]:=0;
 ClearValue.uint32[2]:=0;
 ClearValue.float32[3]:=1.0;
 aCommandBuffer.CmdClearColorImage(fInstance.DeepAndFastApproximateOrderIndependentTransparencyAccumulationImage.VulkanImage.Handle,
                                   VK_IMAGE_LAYOUT_GENERAL,
                                   @ClearValue,
                                   1,
                                   @ImageSubresourceRanges[0]);

 ClearValue.uint32[0]:=0;
 ClearValue.uint32[1]:=0;
 ClearValue.uint32[2]:=0;
 ClearValue.uint32[3]:=0;
 aCommandBuffer.CmdClearColorImage(fInstance.DeepAndFastApproximateOrderIndependentTransparencyBucketImage.VulkanImage.Handle,
                                   VK_IMAGE_LAYOUT_GENERAL,
                                   @ClearValue,
                                   1,
                                   @ImageSubresourceRanges[1]);

 if fInstance.Renderer.TransparencyMode=TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT then begin
  ClearValue.uint32[0]:=0;
  ClearValue.uint32[1]:=0;
  ClearValue.uint32[2]:=0;
  ClearValue.uint32[3]:=0;
  aCommandBuffer.CmdClearColorImage(fInstance.DeepAndFastApproximateOrderIndependentTransparencySpinLockImage.VulkanImage.Handle,
                                    VK_IMAGE_LAYOUT_GENERAL,
                                    @ClearValue,
                                    1,
                                    @ImageSubresourceRanges[2]);
 end;

{BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                    TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                    VK_QUEUE_FAMILY_IGNORED,
                                                    VK_QUEUE_FAMILY_IGNORED,
                                                    fInstance.DeepAndFastApproximateOrderIndependentTransparencyABufferBuffers[aInFlightFrameIndex].VulkanBuffer.Handle,
                                                    0,
                                                    VK_WHOLE_SIZE);]}

 ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                      TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      fInstance.DeepAndFastApproximateOrderIndependentTransparencyFragmentCounterFragmentDepthsSampleMaskImage.VulkanImage.Handle,
                                                      ImageSubresourceRanges[0]);

 ImageMemoryBarriers[1]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                      TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      fInstance.DeepAndFastApproximateOrderIndependentTransparencyAccumulationImage.VulkanImage.Handle,
                                                      ImageSubresourceRanges[0]);

 ImageMemoryBarriers[2]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                      TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      fInstance.DeepAndFastApproximateOrderIndependentTransparencyAverageImage.VulkanImage.Handle,
                                                      ImageSubresourceRanges[0]);

 ImageMemoryBarriers[3]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                      TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                                      TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      fInstance.DeepAndFastApproximateOrderIndependentTransparencyBucketImage.VulkanImage.Handle,
                                                      ImageSubresourceRanges[1]);

 if fInstance.Renderer.TransparencyMode=TpvScene3DRendererTransparencyMode.SPINLOCKOIT then begin
  ImageMemoryBarriers[4]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                                       TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fInstance.DeepAndFastApproximateOrderIndependentTransparencySpinLockImage.VulkanImage.Handle,
                                                       ImageSubresourceRanges[2]);
  CountImageMemoryBarriers:=5;
 end else begin
  CountImageMemoryBarriers:=4;
 end;

 aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                   TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT),
                                   0,
                                   nil,
                                   0,//1,
                                   nil,//@BufferMemoryBarrier,
                                   CountImageMemoryBarriers,
                                   @ImageMemoryBarriers[0]);

end;

end.
