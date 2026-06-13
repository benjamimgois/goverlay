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
unit PasVulkan.Scene3D.Renderer.Globals;
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
     PasJSON,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.VirtualReality,
     PasVulkan.VirtualFileSystem;

type TpvScene3DRendererAntialiasingMode=
      (
       Auto=0,
       None,
       DSAA,
       FXAA,
       SMAA,
       SMAAT2x,
       MSAA,
       MSAASMAA,
       TAA
      );

     PpvScene3DRendererAntialiasingMode=^TpvScene3DRendererAntialiasingMode;

     TpvScene3DRendererShadowMode=
      (
       Auto=0,
       None=1,
       PCF=2,
       DPCF=3,
       PCSS=4,
       MSM=5
      );

     PpvScene3DRendererShadowMode=^TpvScene3DRendererShadowMode;

     TpvScene3DRendererTransparencyMode=
      (
       Auto=0,
       Direct,
       SPINLOCKOIT,
       INTERLOCKOIT,
       LOOPOIT,
       WBOIT,
       MBOIT,
       SPINLOCKDFAOIT,
       INTERLOCKDFAOIT
      );

     PpvScene3DRendererTransparencyMode=^TpvScene3DRendererTransparencyMode;

     TpvScene3DRendererDepthOfFieldMode=
      (
       Auto=0,
       None,
       HalfResSeparateNearFar,
       HalfResBruteforce,
       FullResHexagon,
       FullResBruteforce
      );

     PpvScene3DRendererDepthOfFieldMode=^TpvScene3DRendererDepthOfFieldMode;

     TpvScene3DRendererLensMode=
      (
       Auto=0,
       None,
       DownUpsample
      );

     PpvScene3DRendererLensMode=^TpvScene3DRendererLensMode;

     TpvScene3DRendererResamplingMode=
      (
       Lanczos,
       EASU
      );

     PpvScene3DRendererResamplingMode=^TpvScene3DRendererResamplingMode;

     { TpvScene3DRendererResamplingModeHelper }

     TpvScene3DRendererResamplingModeHelper=record helper for TpvScene3DRendererResamplingMode
      function ToString:TpvUTF8String;
      procedure FromString(const aValue:TpvUTF8String);
     end;

     TpvScene3DRendererAIUpscaleMode=
      (
       None,
       Factor2X,
       Factor4X
      );

     PpvScene3DRendererAIUpscaleMode=^TpvScene3DRendererAIUpscaleMode;

     TpvScene3DRendererAIUpscaleQuality=
      (
       Low,
       Mid,
       High
      );

     PpvScene3DRendererAIUpscaleQuality=^TpvScene3DRendererAIUpscaleQuality;

     { TpvScene3DRendererAIUpscaleModeHelper }

     TpvScene3DRendererAIUpscaleModeHelper=record helper for TpvScene3DRendererAIUpscaleMode
      function ToString:TpvUTF8String;
      procedure FromString(const aValue:TpvUTF8String);
     end;

     { TpvScene3DRendererAIUpscaleQualityHelper }

     TpvScene3DRendererAIUpscaleQualityHelper=record helper for TpvScene3DRendererAIUpscaleQuality
      function ToString:TpvUTF8String;
      procedure FromString(const aValue:TpvUTF8String);
     end;

     TpvScene3DRendererGlobalIlluminationMode=
      (
       Auto=0,
       
       // No global illumination. Here in this case, it is just EnvironmentMap but with a empty black environment map, for to minimize the count
       // of the shader variants, and a cubemap lookup costs almost nothing these days.
       //None,
       
       // The simplest and fastest way to add global illumination to a scene is to use a static IBL environment map, for example from the sky. 
       EnvironmentMap,

       // A camera reflection probe is a cubemap that is updated every frame to reflect the scene around it. Nintendo seems to use this technique in some 
       // of their Nintendo Switch games. It may seem like the wrong approach at first glance, but apparently it still seems to work well, at least when 
       // used well in a targeted way.
       CameraReflectionProbe,

       // The idea of "Radiance hints" is based on reflective shadow maps (RSMs), where but instead of depth, the albedo color is stored in the RSMs. And
       // with cascaded radiance hints, the scene is split into multiple cascades, where each cascade has its own voxel-grid-like state. This technique is
       // very similar to cascaded shadow maps (CSMs), only that it is used for global illumination instead of shadows.
       CascadedRadianceHints,

       // At Voxel cone tracing, the scene is voxelized and then cone traced in an approximated way with help of mipmaps of the 3D voxel texture. This is 
       // a rather good technique, but it has some drawbacks, for example light leaking artifacts at thin walls. And with cascaded voxel cone tracing, the
       // scene is split into multiple cascades, where each cascade has its own voxel grid map. This technique is very similar to cascaded shadow maps (CSMs),
       // only that it is used for global illumination instead of shadows.
       CascadedVoxelConeTracing,

       // Dynamic Diffuse Global Illumination (DDGI, Majercik et al. 2019). A cascaded grid of light probes that are updated each frame by tracing rays
       // against the hardware ray tracing acceleration structure (TLAS). Each probe stores irradiance (either as spherical harmonics or as an octahedral
       // atlas, switchable via a shader define) plus an octahedral mean/mean-squared distance term for the Chebyshev visibility test, which is what
       // prevents the light leaking that cascaded radiance hints suffer from. The probe grid placement reuses the cascaded radiance hints snapping
       // infrastructure. Requires hardware ray tracing support (RaytracingActive).
       DynamicDiffuseGlobalIllumination,

       // Surfel-based global illumination (in the spirit of EA SEED's "Global Illumination Based on Surfels", Halen 2021). Surfels (oriented surface
       // elements) are spawned from the G-buffer where surfel coverage is insufficient, stored in a persistent GPU pool indexed by a world-space hash
       // grid, and each surfel accumulates irradiance (as spherical harmonics) over many frames by tracing a few rays per frame against the TLAS. During
       // shading the nearby surfels are gathered from the hash grid and blended. Requires hardware ray tracing support (RaytracingActive).
       SurfelGlobalIllumination

{
       // Possible further options on my todo list for the future:

       // And finally, the most accurate and most expensive way to add global illumination to a scene is to use hardware ray tracing for 1SPP path tracing
       // together with temporal denoising. This technique is extremely accurate, but also extremely expensive. But it is also the only way to get the most 
       // accurate global illumination. But sadly it needs hardware support for ray tracing, and this is currently only available on Nvidia RTX graphics cards,
       // newer AMD GPUs and Intel graphics cards. But maybe in the future, ray tracing will be more common and available on all graphics cards, and then it
       // will be the best way to add global illumination to a scene. But until then, it is only a nice to have feature for the future.
       PathTracingWithTemporalDenoising
      
       // I'll avoid Light Propagation Volumes (LPVs) because I do think that it is no more worth to implement it, because it is no real alternative to
       // radiance hints in my own opinion, when radiance hints is really good implemented once. And I'll also avoid Screen Space Global Illumination 
       // (SSGI) because it misses out-of-screen information.

      }
      );

     PpvScene3DRendererGlobalIlluminatonMode=^TpvScene3DRendererGlobalIlluminationMode;

     TpvScene3DRendererToneMappingMode=
      (
       Auto=0,
       Linear=1,
       Reinhard=2,
       Hejl=3,
       Hejl2015=4,
       ACESFilm=5,
       ACESFilm2=6,
       Uncharted2=7,
       Uchimura=8,
       Lottes=9,
       AMD=10,
       AGXRec709=11,
       AGXRec709Golden=12,
       AGXRec709Punchy=13,
       AGXRec2020=14,
       AGXRec2020Golden=15,
       AGXRec2020Punchy=16,
       KhronosPBRNeutral=17
      );
     PpvScene3DRendererToneMappingMode=^TpvScene3DRendererToneMappingMode;

     { TpvScene3DRendererToneMappingModeHelper }

     TpvScene3DRendererToneMappingModeHelper=record helper for TpvScene3DRendererToneMappingMode
      function ToString:TpvUTF8String;
      procedure FromString(const aValue:TpvUTF8String);
     end;

     TpvScene3DRendererCullRenderPass=
      (
       None=0,
       FinalView=1,
       CascadedShadowMap=2,
       Voxelization=3,
       ReflectionProbe=4,
       TopDownSkyOcclusionMap=5,
       ReflectiveShadowMap=6,
       First=1,
       Last=6
      );
     PpvScene3DRendererCullRenderPass=^TpvScene3DRendererCullRenderPass;

     TpvScene3DRendererCullRenderPasses=set of TpvScene3DRendererCullRenderPass;

     TpvScene3DRendererRenderPass=
      (
       None=0,
       View=1,
       CascadedShadowMap=2,
       ReflectionProbe=3,
       TopDownSkyOcclusionMap=4,
       ReflectiveShadowMap=5,
       Voxelization=6
      );
     PpvScene3DRendererRenderPass=^TpvScene3DRendererRenderPass;

     TpvScene3DRendererRenderPasses=set of TpvScene3DRendererRenderPass;

const TpvScene3DRendererRenderPassFirst=TpvScene3DRendererRenderPass.View;

      TpvScene3DRendererRenderPassLast=TpvScene3DRendererRenderPass.Voxelization;

      TpvScene3DRendererAllRenderPasses:TpvScene3DRendererRenderPasses=
       [
        TpvScene3DRendererRenderPass.View,
        TpvScene3DRendererRenderPass.CascadedShadowMap,
        TpvScene3DRendererRenderPass.ReflectionProbe,
        TpvScene3DRendererRenderPass.TopDownSkyOcclusionMap,
        TpvScene3DRendererRenderPass.ReflectiveShadowMap,
        TpvScene3DRendererRenderPass.Voxelization
       ];

function pvScene3DRendererRenderPassesToMask(const aPasses:TpvScene3DRendererRenderPasses):TpvUInt32;

var pvScene3DShaderVirtualFileSystem:TpvVirtualFileSystem=nil;

implementation

uses PasVulkan.Scene3D.Assets;

{ TpvScene3DRendererToneMappingModeHelper }

function TpvScene3DRendererToneMappingModeHelper.ToString:TpvUTF8String;
begin
 case self of
  TpvScene3DRendererToneMappingMode.Auto:begin
   result:='auto';
  end;
  TpvScene3DRendererToneMappingMode.Linear:begin
   result:='linear';
  end;
  TpvScene3DRendererToneMappingMode.Reinhard:begin
   result:='reinhard';
  end;
  TpvScene3DRendererToneMappingMode.Hejl:begin
   result:='hejl';
  end;
  TpvScene3DRendererToneMappingMode.Hejl2015:begin
   result:='hejl2015';
  end;
  TpvScene3DRendererToneMappingMode.ACESFilm:begin
   result:='acesfilm';
  end;
  TpvScene3DRendererToneMappingMode.ACESFilm2:begin
   result:='acesfilm2';
  end;
  TpvScene3DRendererToneMappingMode.Uncharted2:begin
   result:='uncharted2';
  end;
  TpvScene3DRendererToneMappingMode.Uchimura:begin
   result:='uchimura';
  end;
  TpvScene3DRendererToneMappingMode.Lottes:begin
   result:='lottes';
  end;
  TpvScene3DRendererToneMappingMode.AMD:begin
   result:='amd';
  end;
  TpvScene3DRendererToneMappingMode.AGXRec709:begin
   result:='agxrec709';
  end;
  TpvScene3DRendererToneMappingMode.AGXRec709Golden:begin
   result:='agxrec709golden';
  end;
  TpvScene3DRendererToneMappingMode.AGXRec709Punchy:begin
   result:='agxrec709punchy';
  end;
  TpvScene3DRendererToneMappingMode.AGXRec2020:begin
   result:='agxrec2020';
  end;
  TpvScene3DRendererToneMappingMode.AGXRec2020Golden:begin
   result:='agxrec2020golden';
  end;
  TpvScene3DRendererToneMappingMode.AGXRec2020Punchy:begin
   result:='agxrec2020punchy';
  end;
  TpvScene3DRendererToneMappingMode.KhronosPBRNeutral:begin
   result:='khronospbrneutral';
  end;
  else begin
   result:='auto';
  end;
 end;
end;

procedure TpvScene3DRendererToneMappingModeHelper.FromString(const aValue:TpvUTF8String);
var Value:TpvUTF8String;
begin
 Value:=LowerCase(Trim(aValue));
 if Value='auto' then begin
  self:=TpvScene3DRendererToneMappingMode.Auto;
 end else if Value='linear' then begin
  self:=TpvScene3DRendererToneMappingMode.Linear;
 end else if Value='reinhard' then begin
  self:=TpvScene3DRendererToneMappingMode.Reinhard;
 end else if Value='hejl' then begin
  self:=TpvScene3DRendererToneMappingMode.Hejl;
 end else if Value='hejl2015' then begin
  self:=TpvScene3DRendererToneMappingMode.Hejl2015;
 end else if Value='acesfilm' then begin
  self:=TpvScene3DRendererToneMappingMode.ACESFilm;
 end else if Value='acesfilm2' then begin
  self:=TpvScene3DRendererToneMappingMode.ACESFilm2;
 end else if Value='uncharted2' then begin
  self:=TpvScene3DRendererToneMappingMode.Uncharted2;
 end else if Value='uchimura' then begin
  self:=TpvScene3DRendererToneMappingMode.Uchimura;
 end else if Value='lottes' then begin
  self:=TpvScene3DRendererToneMappingMode.Lottes;
 end else if Value='amd' then begin
  self:=TpvScene3DRendererToneMappingMode.AMD;
 end else if Value='agxrec709' then begin
  self:=TpvScene3DRendererToneMappingMode.AGXRec709;
 end else if Value='agxrec709golden' then begin
  self:=TpvScene3DRendererToneMappingMode.AGXRec709Golden;
 end else if Value='agxrec709punchy' then begin
  self:=TpvScene3DRendererToneMappingMode.AGXRec709Punchy;
 end else if Value='agxrec2020' then begin
  self:=TpvScene3DRendererToneMappingMode.AGXRec2020;
 end else if Value='agxrec2020golden' then begin
  self:=TpvScene3DRendererToneMappingMode.AGXRec2020Golden;
 end else if Value='agxrec2020punchy' then begin
  self:=TpvScene3DRendererToneMappingMode.AGXRec2020Punchy;
 end else if Value='khronospbrneutral' then begin
  self:=TpvScene3DRendererToneMappingMode.KhronosPBRNeutral;
 end else begin
  self:=TpvScene3DRendererToneMappingMode.Auto;
 end;
end;

{ TpvScene3DRendererResamplingModeHelper }

function TpvScene3DRendererResamplingModeHelper.ToString:TpvUTF8String;
begin
 case self of
  TpvScene3DRendererResamplingMode.Lanczos:begin
   result:='lanczos';
  end;
  TpvScene3DRendererResamplingMode.EASU:begin
   result:='easu';
  end;
  else begin
   result:='lanczos';
  end;
 end;
end;

procedure TpvScene3DRendererResamplingModeHelper.FromString(const aValue:TpvUTF8String);
var Value:TpvUTF8String;
begin
 Value:=LowerCase(Trim(aValue));
 if (Value='lanczos') or (Value='default') then begin
  self:=TpvScene3DRendererResamplingMode.Lanczos;
 end else if (Value='easu') or (Value='fsr1') or (Value='fsr') then begin
  self:=TpvScene3DRendererResamplingMode.EASU;
 end else begin
  self:=TpvScene3DRendererResamplingMode.Lanczos;
 end;
end;

{ TpvScene3DRendererAIUpscaleModeHelper }

function TpvScene3DRendererAIUpscaleModeHelper.ToString:TpvUTF8String;
begin
 case self of
  TpvScene3DRendererAIUpscaleMode.None:begin
   result:='none';
  end;
  TpvScene3DRendererAIUpscaleMode.Factor2X:begin
   result:='factor2x';
  end;
  TpvScene3DRendererAIUpscaleMode.Factor4X:begin
   result:='factor4x';
  end;
  else begin
   result:='none';
  end;
 end;
end;

procedure TpvScene3DRendererAIUpscaleModeHelper.FromString(const aValue:TpvUTF8String);
var Value:TpvUTF8String;
begin
 Value:=LowerCase(Trim(aValue));
 if (Value='none') or (Value='off') or (Value='disabled') then begin
  self:=TpvScene3DRendererAIUpscaleMode.None;
 end else if (Value='factor2x') or (Value='2x') then begin
  self:=TpvScene3DRendererAIUpscaleMode.Factor2X;
 end else if (Value='factor4x') or (Value='4x') then begin
  self:=TpvScene3DRendererAIUpscaleMode.Factor4X;
 end else begin
  self:=TpvScene3DRendererAIUpscaleMode.None;
 end;
end;

{ TpvScene3DRendererAIUpscaleQualityHelper }

function TpvScene3DRendererAIUpscaleQualityHelper.ToString:TpvUTF8String;
begin
 case self of
  TpvScene3DRendererAIUpscaleQuality.Low:begin
   result:='low';
  end;
  TpvScene3DRendererAIUpscaleQuality.Mid:begin
   result:='mid';
  end;
  TpvScene3DRendererAIUpscaleQuality.High:begin
   result:='high';
  end;
  else begin
   result:='low';
  end;
 end;
end;

procedure TpvScene3DRendererAIUpscaleQualityHelper.FromString(const aValue:TpvUTF8String);
var Value:TpvUTF8String;
begin
 Value:=LowerCase(Trim(aValue));
 if (Value='low') or (Value='lo') then begin
  self:=TpvScene3DRendererAIUpscaleQuality.Low;
 end else if (Value='mid') or (Value='medium') then begin
  self:=TpvScene3DRendererAIUpscaleQuality.Mid;
 end else if (Value='high') or (Value='hi') then begin
  self:=TpvScene3DRendererAIUpscaleQuality.High;
 end else begin
  self:=TpvScene3DRendererAIUpscaleQuality.Low;
 end;
end;

function pvScene3DRendererRenderPassesToMask(const aPasses:TpvScene3DRendererRenderPasses):TpvUInt32;
//var RenderPass:TpvScene3DRendererRenderPass;
begin
{result:=0;
 for RenderPass:=Low(TpvScene3DRendererRenderPass) to High(TpvScene3DRendererRenderPass) do begin
  if RenderPass in aPasses then begin
   result:=result or (TpvUInt32(1) shl TpvUInt32(ord(RenderPass)));
  end;
 end;}
 result:=TpvUInt32(ord(TpvScene3DRendererRenderPass.View in aPasses) and 1) shl TpvUInt32(ord(TpvScene3DRendererRenderPass.View)) or
         TpvUInt32(ord(TpvScene3DRendererRenderPass.CascadedShadowMap in aPasses) and 1) shl TpvUInt32(ord(TpvScene3DRendererRenderPass.CascadedShadowMap)) or
         TpvUInt32(ord(TpvScene3DRendererRenderPass.ReflectionProbe in aPasses) and 1) shl TpvUInt32(ord(TpvScene3DRendererRenderPass.ReflectionProbe)) or
         TpvUInt32(ord(TpvScene3DRendererRenderPass.TopDownSkyOcclusionMap in aPasses) and 1) shl TpvUInt32(ord(TpvScene3DRendererRenderPass.TopDownSkyOcclusionMap)) or
         TpvUInt32(ord(TpvScene3DRendererRenderPass.ReflectiveShadowMap in aPasses) and 1) shl TpvUInt32(ord(TpvScene3DRendererRenderPass.ReflectiveShadowMap)) or
         TpvUInt32(ord(TpvScene3DRendererRenderPass.Voxelization in aPasses) and 1) shl TpvUInt32(ord(TpvScene3DRendererRenderPass.Voxelization));
end;

initialization
{$if declared(get_pasvulkan_scene3dshaders_spk_data) and declared(get_pasvulkan_scene3dshaders_spk_size)}
 pvScene3DShaderVirtualFileSystem:=TpvVirtualFileSystem.Create(get_pasvulkan_scene3dshaders_spk_data,get_pasvulkan_scene3dshaders_spk_size,{$ifdef Windows}'d:\GitHub\pasvulkan\src\assets\shaders\scene3d\scene3dshaders.spk'{$else}'/home/bero/Projects/GitHub/pasvulkan/src/assets/shaders/scene3d/scene3dshaders.spk'{$endif},true);
{$elseif declared(get_pasvulkan_scene3dshaders_zip_data) and declared(get_pasvulkan_scene3dshaders_zip_size)}
 pvScene3DShaderVirtualFileSystem:=TpvVirtualFileSystem.Create(get_pasvulkan_scene3dshaders_zip_data,get_pasvulkan_scene3dshaders_zip_size,{$ifdef Windows}'d:\GitHub\pasvulkan\src\assets\shaders\scene3d\scene3dshaders.zip'{$else}'/home/bero/Projects/GitHub/pasvulkan/src/assets/shaders/scene3d/scene3dshaders.zip'{$endif},true);
{$else}
 pvScene3DShaderVirtualFileSystem:=TpvVirtualFileSystem.Create(@PasVulkan.Scene3D.Assets.Scene3DSPIRVShadersData[0],PasVulkan.Scene3D.Assets.Scene3DSPIRVShadersDataSize,{$ifdef Windows}'d:\GitHub\pasvulkan\src\assets\shaders\scene3d\scene3dshaders.zip'{$else}'/home/bero/Projects/GitHub/pasvulkan/src/assets/shaders/scene3d/scene3dshaders.zip'{$endif});
{$ifend}
finalization
 FreeAndNil(pvScene3DShaderVirtualFileSystem);
end.
