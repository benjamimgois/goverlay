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
unit PasVulkan.Scene3D.Renderer.Passes.PlanetWaterCausticsComputePass;
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
     PasVulkan.Scene3D.Planet;

type { TpvScene3DRendererPassesPlanetWaterCausticsComputePass }
     TpvScene3DRendererPassesPlanetWaterCausticsComputePass=class(TpvFrameGraph.TComputePass)
      private
       fInstance:TpvScene3DRendererInstance;
       fResourceColor:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceCascadedShadowMap:TpvFrameGraph.TPass.TUsedImageResource;
       fResourceSSAO:TpvFrameGraph.TPass.TUsedImageResource;
       fWaterCaustics:TpvScene3DPlanet.TWaterCaustics;
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

{ TpvScene3DRendererPassesPlanetWaterCausticsComputePass }

constructor TpvScene3DRendererPassesPlanetWaterCausticsComputePass.Create(const aFrameGraph:TpvFrameGraph;const aInstance:TpvScene3DRendererInstance);
begin
 inherited Create(aFrameGraph);

 fInstance:=aInstance;

 Name:='PlanetWaterCausticsComputePass';

 // Scene color forward rendering output (storage image for caustic additive writes)
 fResourceColor:=AddImageOutput('resourcetype_color_optimized_non_alpha',
                                'resource_forwardrendering_color',
                                VK_IMAGE_LAYOUT_GENERAL,
                                TpvFrameGraph.TLoadOp.Create(TpvFrameGraph.TLoadOp.TKind.Load),
                                []);

 // Cascaded shadow map input (read-only, for light direction and shadow sampling)
 fResourceCascadedShadowMap:=AddImageInput('resourcetype_cascadedshadowmap_data',
                                           'resource_cascadedshadowmap_data_final',
                                           VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                           []);

 // Ambient occlusion input (optional, only when SSAO is enabled)
 if fInstance.Renderer.ScreenSpaceAmbientOcclusion then begin

  fResourceSSAO:=AddImageInput('resourcetype_ambientocclusion_final',
                               'resource_ambientocclusion_data_final',
                               VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                               []);

 end else begin

  fResourceSSAO:=nil;

 end;

end;

destructor TpvScene3DRendererPassesPlanetWaterCausticsComputePass.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererPassesPlanetWaterCausticsComputePass.AcquirePersistentResources;
begin

 inherited AcquirePersistentResources;

 fWaterCaustics:=TpvScene3DPlanet.TWaterCaustics.Create(fInstance.Renderer,fInstance,fInstance.Scene3D);

end;

procedure TpvScene3DRendererPassesPlanetWaterCausticsComputePass.ReleasePersistentResources;
begin
 FreeAndNil(fWaterCaustics);
 inherited ReleasePersistentResources;
end;

procedure TpvScene3DRendererPassesPlanetWaterCausticsComputePass.AcquireVolatileResources;
var InFlightFrameIndex:TpvSizeInt;
    SceneColorImages:TpvVulkanImageDynamicArray;
    CascadedShadowMapViews:TpvVulkanImageViewDynamicArray;
    SSAOViews:TpvVulkanImageViewDynamicArray;
    SSAOLayout:TVkImageLayout;
begin

 inherited AcquireVolatileResources;

 SetLength(SceneColorImages,FrameGraph.CountInFlightFrames);
 SetLength(CascadedShadowMapViews,FrameGraph.CountInFlightFrames);
 SetLength(SSAOViews,FrameGraph.CountInFlightFrames);

 for InFlightFrameIndex:=0 to FrameGraph.CountInFlightFrames-1 do begin
  SceneColorImages[InFlightFrameIndex]:=fResourceColor.VulkanImages[InFlightFrameIndex];
  CascadedShadowMapViews[InFlightFrameIndex]:=fResourceCascadedShadowMap.VulkanImageViews[InFlightFrameIndex];
  if assigned(fResourceSSAO) then begin
   SSAOViews[InFlightFrameIndex]:=fResourceSSAO.VulkanImageViews[InFlightFrameIndex];
  end else begin
   SSAOViews[InFlightFrameIndex]:=fInstance.Renderer.EmptyAmbientOcclusionTexture.ImageView;
  end;
 end;

 if assigned(fResourceSSAO) then begin
  SSAOLayout:=fResourceSSAO.ResourceTransition.Layout;
 end else begin
  SSAOLayout:=TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
 end;

 fWaterCaustics.AllocateResources(SceneColorImages,
                                  TpvFrameGraph.TImageResourceType(fResourceColor.ResourceType).Format,
                                  CascadedShadowMapViews,
                                  fResourceCascadedShadowMap.ResourceTransition.Layout,
                                  SSAOViews,
                                  SSAOLayout,
                                  fInstance.CountSurfaceViews,
                                  fInstance.Width,
                                  fInstance.Height);
end;

procedure TpvScene3DRendererPassesPlanetWaterCausticsComputePass.ReleaseVolatileResources;
begin
 fWaterCaustics.ReleaseResources;
 inherited ReleaseVolatileResources;
end;

procedure TpvScene3DRendererPassesPlanetWaterCausticsComputePass.Update(const aUpdateInFlightFrameIndex,aUpdateFrameIndex:TpvSizeInt);
begin
 inherited Update(aUpdateInFlightFrameIndex,aUpdateFrameIndex);
end;

procedure TpvScene3DRendererPassesPlanetWaterCausticsComputePass.Execute(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex,aFrameIndex:TpvSizeInt);
begin

 inherited Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

 fWaterCaustics.Execute(aCommandBuffer,aInFlightFrameIndex,aFrameIndex);

end;

end.
