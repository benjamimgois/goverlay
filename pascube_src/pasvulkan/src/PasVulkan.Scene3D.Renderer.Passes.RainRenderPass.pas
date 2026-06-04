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
unit PasVulkan.Scene3D.Renderer.Passes.RainRenderPass;
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
     PasVulkan.Scene3D.Atmosphere,
     PasVulkan.Scene3D.Renderer.Globals,
     PasVulkan.Scene3D.Renderer,
     PasVulkan.Scene3D.Renderer.Instance,
     PasVulkan.Scene3D.Renderer.SkyBox,
     PasVulkan.Scene3D.Planet;

type { TpvScene3DRendererPassesRainRenderPass }
     TpvScene3DRendererPassesRainRenderPass=class(TpvFrameGraph.TRenderPass)
      public
      private
       fInstance:TpvScene3DRendererInstance;
       fVulkanRenderPass:TpvVulkanRenderPass;
       fResourceDepth:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceOutput:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceVelocity:TpvFrameGraph.TPass.TUsedImageResource;
       fPlanetRainStreakRenderPass:TpvScene3DPlanet.TRainStreakRenderPass;
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

{ TpvScene3DRendererPassesRainRenderPass }

constructor TpvScene3DRendererPassesRainRenderPass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin

 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='RainRenderPass';

 MultiviewMask:=fInstance.SurfaceMultiviewMask;

 Queue:=aFrameGraph.UniversalQueue;

//SeparatePhysicalPass:=true;

//SeparateCommandBuffer:=true;

 Size:=TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,
                                       fInstance.SizeFactor,
                                       fInstance.SizeFactor,
                                       1.0,
                                       fInstance.CountSurfaceViews);

 if fInstance.Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin

  fResourceDepth:=AddImageDepthInput('resourcetype_depth',
                                     'resource_depth_data',
                                     VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL,
                                     [TpvFrameGraph.TResourceTransition.TFlag.Attachment,
                                      TpvFrameGraph.TResourceTransition.TFlag.ExplicitOutputAttachment]
                                    );

  fResourceOutput:=AddImageInput('resourcetype_color_optimized_non_alpha',
                                 'resource_forwardrendering_color',
                                 VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                 [TpvFrameGraph.TResourceTransition.TFlag.Attachment,
                                  TpvFrameGraph.TResourceTransition.TFlag.ExplicitOutputAttachment]
                                );

  if fInstance.Renderer.VelocityBufferNeeded then begin
   fResourceVelocity:=AddImageInput('resourcetype_velocity',
                                    'resource_velocity_data',
                                    VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                    [TpvFrameGraph.TResourceTransition.TFlag.Attachment,
                                     TpvFrameGraph.TResourceTransition.TFlag.ExplicitOutputAttachment]
                                   );
  end else begin
   fResourceVelocity:=nil;
  end;

 end else begin

  fResourceDepth:=AddImageDepthInput('resourcetype_msaa_depth',
                                     'resource_msaa_depth_data',
                                     VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL,
                                     [TpvFrameGraph.TResourceTransition.TFlag.Attachment,
                                     TpvFrameGraph.TResourceTransition.TFlag.ExplicitOutputAttachment]
                                    );

  fResourceOutput:=AddImageInput('resourcetype_msaa_color_optimized_non_alpha',
                                 'resource_forwardrendering_msaa_color',
                                 VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                 [TpvFrameGraph.TResourceTransition.TFlag.Attachment,
                                  TpvFrameGraph.TResourceTransition.TFlag.ExplicitOutputAttachment]
                                );

  fResourceVelocity:=nil;

 end;

//fInstance.LastOutputResource:=fResourceOutput;

end;

destructor TpvScene3DRendererPassesRainRenderPass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesRainRenderPass.AcquirePersistentResources;
begin

 inherited AcquirePersistentResources;

 fPlanetRainStreakRenderPass:=TpvScene3DPlanet.TRainStreakRenderPass.Create(fInstance.Renderer,
                                                                            fInstance,
                                                                            fInstance.Renderer.Scene3D);

end;

procedure TpvScene3DRendererPassesRainRenderPass.ReleasePersistentResources;
begin
 FreeAndNil(fPlanetRainStreakRenderPass);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesRainRenderPass.AcquireVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin
 inherited AcquireVolatileResources;

 fVulkanRenderPass:=VulkanRenderPass;

 fPlanetRainStreakRenderPass.AllocateResources(fVulkanRenderPass,
                                               fInstance.ScaledWidth,
                                               fInstance.ScaledHeight,
                                               fInstance.Renderer.SurfaceSampleCountFlagBits);

end;

procedure TpvScene3DRendererPassesRainRenderPass.ReleaseVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
begin

 fPlanetRainStreakRenderPass.ReleaseResources;

 fVulkanRenderPass:=nil;

 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesRainRenderPass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesRainRenderPass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
var InFlightFrameState:TpvScene3DRendererInstance.PInFlightFrameState;
begin
 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 InFlightFrameState:=@TpvScene3DRendererInstance(fInstance).InFlightFrameStates[aInFlightFrameIndex];

 fPlanetRainStreakRenderPass.Draw(aInFlightFrameIndex,
                                  aFrameIndex,
                                  TpvScene3DRendererRenderPass.View,
                                  InFlightFrameState^.FinalViewIndex,
                                  InFlightFrameState^.CountFinalViews,
                                  aCommandBuffer);

end;

end.
