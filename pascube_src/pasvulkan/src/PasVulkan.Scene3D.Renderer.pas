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
unit PasVulkan.Scene3D.Renderer;
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

uses Classes,
     SysUtils,
     Math,
     PasMP,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Resources,
     PasVulkan.FrameGraph,
     PasVulkan.TimerQuery,
     PasVulkan.Collections,
     PasVulkan.CircularDoublyLinkedList,
     PasVulkan.VirtualReality,
     PasVulkan.Scene3D,
     PasVulkan.Scene3D.Renderer.Globals,
     PasVulkan.Scene3D.Renderer.SMAAData,
     PasVulkan.Scene3D.Renderer.EnvironmentCubeMap,
     PasVulkan.Scene3D.Renderer.MipmappedArray2DImage,
     PasVulkan.Scene3D.Renderer.ImageBasedLighting.EnvMapCubeMaps,
     PasVulkan.Scene3D.Renderer.ImageBasedLighting.SphericalHarmonics,
     PasVulkan.Scene3D.Renderer.Charlie.BRDF,
     PasVulkan.Scene3D.Renderer.GGX.BRDF,
     PasVulkan.Scene3D.Renderer.SheenE.BRDF,
     PasVulkan.Scene3D.Renderer.Lens.Color,
     PasVulkan.Scene3D.Renderer.Lens.Dirt,
     PasVulkan.Scene3D.Renderer.Lens.Star;

type TpvScene3DRenderer=class;

     TpvScene3DRendererBaseObject=class;

     TpvScene3DRendererBaseObjects=class(TpvObjectGenericList<TpvScene3DRendererBaseObject>);

     TpvScene3DRendererBaseObjectCircularDoublyLinkedListNode=class(TpvCircularDoublyLinkedListNode<TpvScene3DRendererBaseObject>);

     { TpvScene3DRendererBaseObject }
     TpvScene3DRendererBaseObject=class
      private
       fParent:TpvScene3DRendererBaseObject;
       fRenderer:TpvScene3DRenderer;
       fChildrenLock:TPasMPCriticalSection;
       fChildren:TpvScene3DRendererBaseObjectCircularDoublyLinkedListNode;
       fOwnCircularDoublyLinkedListNode:TpvScene3DRendererBaseObjectCircularDoublyLinkedListNode;
      public
       constructor Create(const aParent:TpvScene3DRendererBaseObject); reintroduce;
       destructor Destroy; override;
       procedure AfterConstruction; override;
       procedure BeforeDestruction; override;
      published
       property Parent:TpvScene3DRendererBaseObject read fParent;
       property Renderer:TpvScene3DRenderer read fRenderer;
     end;

     { TpvScene3DRenderer }
     TpvScene3DRenderer=class(TpvScene3DRendererBaseObject)
      public
       type TSphericalHarmonicsBufferData=record
             Coefs:array[0..8] of TpvVector4;
            end;
            PSphericalHarmonicsBufferData=^TSphericalHarmonicsBufferData;
            TSphericalHarmonicsMetaDataBufferData=TpvScene3DRendererImageBasedLightingSphericalHarmonics.TSphericalHarmonicsMetaDataBufferData;
            PSphericalHarmonicsMetaDataBufferData=^TSphericalHarmonicsMetaDataBufferData;
            TSurfaceMSAASampleLocations=array[0..255] of TpvVector2;
            PSurfaceMSAASampleLocations=^TSurfaceMSAASampleLocations;
      private
       fScene3D:TpvScene3D;
       fVulkanDevice:TpvVulkanDevice;
       fVulkanPipelineCache:TpvVulkanPipelineCache;
       fCountInFlightFrames:TpvSizeInt;
       fVelocityBufferNeeded:Boolean;
       fGPUCulling:Boolean;
       fGPUShadowCulling:Boolean;
       fEarlyDepthPrepassNeeded:Boolean;
       fWetnessMapActive:Boolean;
       fScreenSpaceAmbientOcclusion:Boolean;
       fAntialiasingMode:TpvScene3DRendererAntialiasingMode;
       fShadowMode:TpvScene3DRendererShadowMode;
       fTransparencyMode:TpvScene3DRendererTransparencyMode;
       fDepthOfFieldMode:TpvScene3DRendererDepthOfFieldMode;
       fLensMode:TpvScene3DRendererLensMode;
       fGlobalIlluminationMode:TpvScene3DRendererGlobalIlluminationMode;
       fToneMappingMode:TpvScene3DRendererToneMappingMode;
{      fMinLogLuminance:TpvFloat;
       fMaxLogLuminance:TpvFloat;}
       fMaxMSAA:TpvInt32;
       fMaxShadowMSAA:TpvInt32;
       fShadowMapSize:TpvInt32;
       fVirtualRealityHUDWidth:TpvInt32;
       fVirtualRealityHUDHeight:TpvInt32;
       fBufferDeviceAddress:boolean;
       fRaytracingActive:boolean;
       fMeshFragTypeName:TpvUTF8String;
       fMeshFragGlobalIlluminationTypeName:TpvUTF8String;
       fMeshFragShadowTypeName:TpvUTF8String;
//     fOptimizedNonAlphaFormat:TVkFormat;
       fOptimizedCubeMapFormat:TVkFormat;
       fFastSky:boolean;
       fFastAerialPerspective:boolean;
       fAtmosphereBlueNoise:boolean;
       fAtmosphereShadows:boolean;
       fUseDepthPrepass:boolean;
       fUseDemote:boolean;
       fUseNoDiscard:boolean;
       fUseOITAlphaTest:boolean;
       fShadowMapSampleCountFlagBits:TVkSampleCountFlagBits;
       fCountCascadedShadowMapMSAASamples:TpvSizeInt;
       fSurfaceSampleCountFlagBits:TVkSampleCountFlagBits;
       fCountSurfaceMSAASamples:TpvSizeInt;
       fSurfaceMSAASampleLocations:TSurfaceMSAASampleLocations;
       fSupersampleWaterWhenMSAA:Boolean;
       fAnimatedAtmosphereNoise:Boolean;
       fGlobalIlluminationCaching:Boolean;
       fGlobalIlluminationRadianceHintsSpread:TpvScalar;
       fGlobalIlluminationVoxelGridSize:TpvInt32;
       fGlobalIlluminationVoxelCountCascades:TpvInt32;
       fGlobalIlluminationVoxelCountBounces:TpvInt32;
      private
       fSkyBoxCubeMap:TpvScene3DRendererEnvironmentCubeMap;
       fEnvironmentCubeMap:TpvScene3DRendererEnvironmentCubeMap;
       fEnvironmentSphericalHarmonicsBuffer:TpvVulkanBuffer;
       fEnvironmentSphericalHarmonicsMetaDataBuffer:TpvVulkanBuffer;
       fEnvironmentSphericalHarmonics:TpvScene3DRendererImageBasedLightingSphericalHarmonics;
       fGGXBRDF:TpvScene3DRendererGGXBRDF;
       fCharlieBRDF:TpvScene3DRendererCharlieBRDF;
       fSheenEBRDF:TpvScene3DRendererSheenEBRDF;
       fLensColor:TpvScene3DRendererLensColor;
       fLensDirt:TpvScene3DRendererLensDirt;
       fLensStar:TpvScene3DRendererLensStar;
       fImageBasedLightingEnvMapCubeMaps:TpvScene3DRendererImageBasedLightingEnvMapCubeMaps;
       fShadowMapSampler:TpvVulkanSampler;
       fCheckShadowMapSampler:TpvVulkanSampler;
       fGeneralSampler:TpvVulkanSampler;
       fOrderIndependentTransparencySampler:TpvVulkanSampler;
       fMipMapMinFilterSampler:TpvVulkanSampler;
       fMipMapMaxFilterSampler:TpvVulkanSampler;
       fRepeatedSampler:TpvVulkanSampler;
       fMirrorRepeatedSampler:TpvVulkanSampler;
       fClampedSampler:TpvVulkanSampler;
       fClampedNearestSampler:TpvVulkanSampler;
       fAmbientOcclusionSampler:TpvVulkanSampler;
       fSMAAAreaTexture:TpvVulkanTexture;
       fSMAASearchTexture:TpvVulkanTexture;
       fEmptyAmbientOcclusionTexture:TpvVulkanTexture;
{      fLensColorTexture:TpvVulkanTexture;
       fLensDirtTexture:TpvVulkanTexture;
       fLensStarTexture:TpvVulkanTexture;}
       procedure SetGlobalIlluminationVoxelCountBounces(const aValue:TpvInt32);
       procedure SetGlobalIlluminationVoxelCountCascades(const aValue:TpvInt32);
       procedure SetGlobalIlluminationVoxelGridSize(const aValue:TpvInt32);
      public
       constructor Create(const aScene3D:TpvScene3D;const aVulkanDevice:TpvVulkanDevice=nil;const aVulkanPipelineCache:TpvVulkanPipelineCache=nil;const aCountInFlightFrames:TpvSizeInt=0); reintroduce;
       destructor Destroy; override;
       class procedure SetupVulkanDevice(const aVulkanDevice:TpvVulkanDevice); static;
       class function CheckBufferDeviceAddress(const aVulkanDevice:TpvVulkanDevice):boolean; static;
       procedure Prepare;
       procedure AcquirePersistentResources;
       procedure ReleasePersistentResources;
      published
       property Scene3D:TpvScene3D read fScene3D;
       property VulkanDevice:TpvVulkanDevice read fVulkanDevice;
       property VulkanPipelineCache:TpvVulkanPipelineCache read fVulkanPipelineCache;
       property CountInFlightFrames:TpvSizeInt read fCountInFlightFrames;
       property VelocityBufferNeeded:Boolean read fVelocityBufferNeeded;
       property GPUCulling:Boolean read fGPUCulling;
       property GPUShadowCulling:Boolean read fGPUShadowCulling;
       property EarlyDepthPrepassNeeded:Boolean read fEarlyDepthPrepassNeeded;
       property WetnessMapActive:Boolean read fWetnessMapActive write fWetnessMapActive;
       property ScreenSpaceAmbientOcclusion:Boolean read fScreenSpaceAmbientOcclusion write fScreenSpaceAmbientOcclusion;
       property AntialiasingMode:TpvScene3DRendererAntialiasingMode read fAntialiasingMode write fAntialiasingMode;
       property ShadowMode:TpvScene3DRendererShadowMode read fShadowMode write fShadowMode;
       property TransparencyMode:TpvScene3DRendererTransparencyMode read fTransparencyMode write fTransparencyMode;
       property DepthOfFieldMode:TpvScene3DRendererDepthOfFieldMode read fDepthOfFieldMode write fDepthOfFieldMode;
       property LensMode:TpvScene3DRendererLensMode read fLensMode write fLensMode;
       property GlobalIlluminationMode:TpvScene3DRendererGlobalIlluminationMode read fGlobalIlluminationMode write fGlobalIlluminationMode;
       property ToneMappingMode:TpvScene3DRendererToneMappingMode read fToneMappingMode write fToneMappingMode;
{      property MinLogLuminance:TpvFloat read fMinLogLuminance write fMinLogLuminance;
       property MaxLogLuminance:TpvFloat read fMaxLogLuminance write fMaxLogLuminance;}
       property MaxMSAA:TpvInt32 read fMaxMSAA write fMaxMSAA;
       property MaxShadowMSAA:TpvInt32 read fMaxShadowMSAA write fMaxShadowMSAA;
       property ShadowMapSize:TpvInt32 read fShadowMapSize write fShadowMapSize;
       property VirtualRealityHUDWidth:TpvInt32 read fVirtualRealityHUDWidth write fVirtualRealityHUDWidth;
       property VirtualRealityHUDHeight:TpvInt32 read fVirtualRealityHUDHeight write fVirtualRealityHUDHeight;
       property BufferDeviceAddress:boolean read fBufferDeviceAddress;
       property RaytracingActive:boolean read fRaytracingActive;
       property MeshFragTypeName:TpvUTF8String read fMeshFragTypeName;
       property MeshFragGlobalIlluminationTypeName:TpvUTF8String read fMeshFragGlobalIlluminationTypeName;
       property MeshFragShadowTypeName:TpvUTF8String read fMeshFragShadowTypeName;
//     property OptimizedNonAlphaFormat:TVkFormat read fOptimizedNonAlphaFormat;
       property OptimizedCubeMapFormat:TVkFormat read fOptimizedCubeMapFormat;
       property FastSky:boolean read fFastSky write fFastSky;
       property FastAerialPerspective:boolean read fFastAerialPerspective write fFastAerialPerspective;
       property AtmosphereBlueNoise:boolean read fAtmosphereBlueNoise write fAtmosphereBlueNoise;
       property AtmosphereShadows:boolean read fAtmosphereShadows write fAtmosphereShadows;
       property UseDepthPrepass:boolean read fUseDepthPrepass;
       property UseDemote:boolean read fUseDemote;
       property UseNoDiscard:boolean read fUseNoDiscard;
       property UseOITAlphaTest:boolean read fUseOITAlphaTest;
       property ShadowMapSampleCountFlagBits:TVkSampleCountFlagBits read fShadowMapSampleCountFlagBits;
       property CountCascadedShadowMapMSAASamples:TpvSizeInt read fCountCascadedShadowMapMSAASamples;
       property SurfaceSampleCountFlagBits:TVkSampleCountFlagBits read fSurfaceSampleCountFlagBits;
       property CountSurfaceMSAASamples:TpvSizeInt read fCountSurfaceMSAASamples;
       property SupersampleWaterWhenMSAA:Boolean read fSupersampleWaterWhenMSAA;
       property AnimatedAtmosphereNoise:Boolean read fAnimatedAtmosphereNoise write fAnimatedAtmosphereNoise;
       property GlobalIlluminationCaching:Boolean read fGlobalIlluminationCaching write fGlobalIlluminationCaching;
       property GlobalIlluminationRadianceHintsSpread:TpvScalar read fGlobalIlluminationRadianceHintsSpread write fGlobalIlluminationRadianceHintsSpread;
       property GlobalIlluminationVoxelGridSize:TpvInt32 read fGlobalIlluminationVoxelGridSize write SetGlobalIlluminationVoxelGridSize;
       property GlobalIlluminationVoxelCountCascades:TpvInt32 read fGlobalIlluminationVoxelCountCascades write SetGlobalIlluminationVoxelCountCascades;
       property GlobalIlluminationVoxelCountBounces:TpvInt32 read fGlobalIlluminationVoxelCountBounces write SetGlobalIlluminationVoxelCountBounces;
      published
       property SkyBoxCubeMap:TpvScene3DRendererEnvironmentCubeMap read fSkyBoxCubeMap;
       property EnvironmentCubeMap:TpvScene3DRendererEnvironmentCubeMap read fEnvironmentCubeMap;
       property EnvironmentSphericalHarmonicsBuffer:TpvVulkanBuffer read fEnvironmentSphericalHarmonicsBuffer;
       property EnvironmentSphericalHarmonicsMetaDataBuffer:TpvVulkanBuffer read fEnvironmentSphericalHarmonicsMetaDataBuffer;
       property GGXBRDF:TpvScene3DRendererGGXBRDF read fGGXBRDF;
       property CharlieBRDF:TpvScene3DRendererCharlieBRDF read fCharlieBRDF;
       property SheenEBRDF:TpvScene3DRendererSheenEBRDF read fSheenEBRDF;
       property LensColor:TpvScene3DRendererLensColor read fLensColor write fLensColor;
       property LensDirt:TpvScene3DRendererLensDirt read fLensDirt write fLensDirt;
       property LensStar:TpvScene3DRendererLensStar read fLensStar write fLensStar;
       property ImageBasedLightingEnvMapCubeMaps:TpvScene3DRendererImageBasedLightingEnvMapCubeMaps read fImageBasedLightingEnvMapCubeMaps;
       property ShadowMapSampler:TpvVulkanSampler read fShadowMapSampler;
       property CheckShadowMapSampler:TpvVulkanSampler read fCheckShadowMapSampler;
       property GeneralSampler:TpvVulkanSampler read fGeneralSampler;
       property OrderIndependentTransparencySampler:TpvVulkanSampler read fOrderIndependentTransparencySampler;
       property MipMapMinFilterSampler:TpvVulkanSampler read fMipMapMinFilterSampler;
       property MipMapMaxFilterSampler:TpvVulkanSampler read fMipMapMaxFilterSampler;
       property RepeatedSampler:TpvVulkanSampler read fRepeatedSampler;
       property MirrorRepeatedSampler:TpvVulkanSampler read fMirrorRepeatedSampler;
       property ClampedSampler:TpvVulkanSampler read fClampedSampler;
       property ClampedNearestSampler:TpvVulkanSampler read fClampedNearestSampler;
       property AmbientOcclusionSampler:TpvVulkanSampler read fAmbientOcclusionSampler;
       property SMAAAreaTexture:TpvVulkanTexture read fSMAAAreaTexture;
       property SMAASearchTexture:TpvVulkanTexture read fSMAASearchTexture;
       property EmptyAmbientOcclusionTexture:TpvVulkanTexture read fEmptyAmbientOcclusionTexture;
{      property LensColorTexture:TpvVulkanTexture read fLensColorTexture;
       property LensDirtTexture:TpvVulkanTexture read fLensDirtTexture;
       property LensStarTexture:TpvVulkanTexture read fLensStarTexture;}
      public
       property SurfaceMSAASampleLocations:TSurfaceMSAASampleLocations read fSurfaceMSAASampleLocations;
     end;

implementation

uses PasVulkan.Scene3D.Assets,
     PasVulkan.Scene3D.Renderer.Instance;

{ TpvScene3DRendererBaseObject }

constructor TpvScene3DRendererBaseObject.Create(const aParent:TpvScene3DRendererBaseObject);
begin
 inherited Create;

 fParent:=aParent;
 if assigned(fParent) then begin
  if fParent is TpvScene3DRenderer then begin
   fRenderer:=TpvScene3DRenderer(fParent);
  end else begin
   fRenderer:=fParent.fRenderer;
  end;
 end else begin
  fRenderer:=nil;
 end;

 if self is TpvScene3DRenderer then begin
  fRenderer:=TpvScene3DRenderer(self);
 end;

 fOwnCircularDoublyLinkedListNode:=TpvScene3DRendererBaseObjectCircularDoublyLinkedListNode.Create;
 fOwnCircularDoublyLinkedListNode.Value:=self;

 fChildrenLock:=TPasMPCriticalSection.Create;
 fChildren:=TpvScene3DRendererBaseObjectCircularDoublyLinkedListNode.Create;

end;

destructor TpvScene3DRendererBaseObject.Destroy;
var Child:TpvScene3DRendererBaseObject;
begin
 fChildrenLock.Acquire;
 try
  while fChildren.PopFromBack(Child) do begin
   FreeAndNil(Child);
  end;
 finally
  fChildrenLock.Release;
 end;
 FreeAndNil(fChildren);
 FreeAndNil(fChildrenLock);
 FreeAndNil(fOwnCircularDoublyLinkedListNode);
 inherited Destroy;
end;

procedure TpvScene3DRendererBaseObject.AfterConstruction;
begin
 inherited AfterConstruction;
 if assigned(fParent) then begin
  fParent.fChildrenLock.Acquire;
  try
   fParent.fChildren.Add(fOwnCircularDoublyLinkedListNode);
  finally
   fParent.fChildrenLock.Release;
  end;
 end;
end;

procedure TpvScene3DRendererBaseObject.BeforeDestruction;
begin
 if assigned(fParent) and not fOwnCircularDoublyLinkedListNode.IsEmpty then begin
  try
   fParent.fChildrenLock.Acquire;
   try
    if not fOwnCircularDoublyLinkedListNode.IsEmpty then begin
     fOwnCircularDoublyLinkedListNode.Remove;
    end;
   finally
    fParent.fChildrenLock.Release;
   end;
  finally
   fParent:=nil;
  end;
 end;
 inherited BeforeDestruction;
end;

{ TpvScene3DRenderer }

constructor TpvScene3DRenderer.Create(const aScene3D:TpvScene3D;const aVulkanDevice:TpvVulkanDevice;const aVulkanPipelineCache:TpvVulkanPipelineCache;const aCountInFlightFrames:TpvSizeInt);
//var InFlightFrameIndex:TpvSizeInt;
begin
 inherited Create(nil);

 fScene3D:=aScene3D;

 if assigned(aVulkanDevice) then begin
  fVulkanDevice:=aVulkanDevice;
 end else begin
  fVulkanDevice:=pvApplication.VulkanDevice;
 end;

 if assigned(aVulkanPipelineCache) then begin
  fVulkanPipelineCache:=aVulkanPipelineCache;
 end else begin
  fVulkanPipelineCache:=pvApplication.VulkanPipelineCache;
 end;

 if aCountInFlightFrames>0 then begin
  fCountInFlightFrames:=aCountInFlightFrames;
 end else begin
  fCountInFlightFrames:=pvApplication.CountInFlightFrames;
 end;

 fWetnessMapActive:=false;

 fScreenSpaceAmbientOcclusion:=true;

 fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.Auto;

 fShadowMode:=TpvScene3DRendererShadowMode.Auto;

 fTransparencyMode:=TpvScene3DRendererTransparencyMode.Auto;

 fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.Auto;

 fLensMode:=TpvScene3DRendererLensMode.Auto;

 fGlobalIlluminationMode:=TpvScene3DRendererGlobalIlluminationMode.Auto;

 fToneMappingMode:=TpvScene3DRendererToneMappingMode.Auto;

{fMinLogLuminance:=-8.0;

 fMaxLogLuminance:=6.0;}

 fMaxMSAA:=0;

 fMaxShadowMSAA:=0;

 fShadowMapSize:=0;

 fVirtualRealityHUDWidth:=2048;
 fVirtualRealityHUDHeight:=1152;

 fSupersampleWaterWhenMSAA:=true;

 fAnimatedAtmosphereNoise:=true;

 fGlobalIlluminationCaching:=true;

 fGlobalIlluminationRadianceHintsSpread:=-0.25;

 fGlobalIlluminationVoxelGridSize:=64;

 fGlobalIlluminationVoxelCountCascades:=8;

 fGlobalIlluminationVoxelCountBounces:=2;

 fFastSky:=true;
 fFastAerialPerspective:=true;
 fAtmosphereBlueNoise:=false;
 fAtmosphereShadows:=false;

end;

destructor TpvScene3DRenderer.Destroy;
//var InFlightFrameIndex:TpvSizeInt;
begin
 inherited Destroy;
end;

procedure TpvScene3DRenderer.SetGlobalIlluminationVoxelCountBounces(const aValue:TpvInt32);
begin
 fGlobalIlluminationVoxelCountBounces:=Min(Max(aValue,1),2);
end;

procedure TpvScene3DRenderer.SetGlobalIlluminationVoxelCountCascades(const aValue:TpvInt32);
begin
 fGlobalIlluminationVoxelCountCascades:=Min(Max(aValue,1),8);
end;

procedure TpvScene3DRenderer.SetGlobalIlluminationVoxelGridSize(const aValue:TpvInt32);
begin
 fGlobalIlluminationVoxelGridSize:=RoundUpToPowerOfTwo(Min(Max(aValue,16),256));
end;

class procedure TpvScene3DRenderer.SetupVulkanDevice(const aVulkanDevice:TpvVulkanDevice);
begin
 if aVulkanDevice.PhysicalDevice.Properties.limits.maxDrawIndexedIndexValue<TpvInt64($80000000) then begin
  raise EpvApplication.Create('Application','The value of maxDrawIndexedIndexValue is too low, must be at least 2147483648.',LOG_ERROR);
 end;
 if aVulkanDevice.PhysicalDevice.Features.multiDrawIndirect=VK_FALSE then begin
  raise EpvApplication.Create('Application','Support for multiDrawIndirect is needed',LOG_ERROR);
 end;
 if aVulkanDevice.PhysicalDevice.Properties.limits.maxDrawIndirectCount<TpvInt64($40000000) then begin
  raise EpvApplication.Create('Application','The value of maxDrawIndirectCount is too low, must be at least 1073741824.',LOG_ERROR);
 end;
 if aVulkanDevice.PhysicalDevice.Features.drawIndirectFirstInstance=VK_FALSE then begin
  raise EpvApplication.Create('Application','Support for drawIndirectFirstInstance is needed',LOG_ERROR);
 end;
 if aVulkanDevice.PhysicalDevice.Features.fullDrawIndexUint32=VK_FALSE then begin
  raise EpvApplication.Create('Application','Support for fullDrawIndexUint32 is needed',LOG_ERROR);
 end;
 if aVulkanDevice.PhysicalDevice.Features.multiViewport=VK_FALSE then begin
  raise EpvApplication.Create('Application','Support for multiViewport is needed',LOG_ERROR);
 end;
 if aVulkanDevice.PhysicalDevice.Features.sampleRateShading=VK_FALSE then begin
  raise EpvApplication.Create('Application','Support for sampleRateShading is needed',LOG_ERROR);
 end;
 if aVulkanDevice.PhysicalDevice.Features.samplerAnisotropy=VK_FALSE then begin
  raise EpvApplication.Create('Application','Support for samplerAnisotropy is needed',LOG_ERROR);
 end;
 if aVulkanDevice.PhysicalDevice.Features.shaderSampledImageArrayDynamicIndexing=VK_FALSE then begin
  raise EpvApplication.Create('Application','Support for shaderSampledImageArrayDynamicIndexing is needed',LOG_ERROR);
 end;
 if aVulkanDevice.PhysicalDevice.Features.shaderStorageBufferArrayDynamicIndexing=VK_FALSE then begin
  raise EpvApplication.Create('Application','Support for shaderStorageBufferArrayDynamicIndexing is needed',LOG_ERROR);
 end;
 if aVulkanDevice.PhysicalDevice.Features.shaderStorageImageArrayDynamicIndexing=VK_FALSE then begin
  raise EpvApplication.Create('Application','Support for shaderStorageImageArrayDynamicIndexing is needed',LOG_ERROR);
 end;
 if aVulkanDevice.PhysicalDevice.Features.shaderUniformBufferArrayDynamicIndexing=VK_FALSE then begin
  raise EpvApplication.Create('Application','Support for shaderUniformBufferArrayDynamicIndexing is needed',LOG_ERROR);
 end;
 if (((aVulkanDevice.Instance.APIVersion and VK_API_VERSION_WITHOUT_PATCH_MASK)<VK_API_VERSION_1_2) and
     (aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_DRAW_INDIRECT_COUNT_EXTENSION_NAME)<0)) or
    (((aVulkanDevice.Instance.APIVersion and VK_API_VERSION_WITHOUT_PATCH_MASK)>=VK_API_VERSION_1_2) and
     (aVulkanDevice.PhysicalDevice.Vulkan12Features.drawIndirectCount=VK_FALSE)) then begin
  raise EpvApplication.Create('Application','Support for drawIndirectCount is needed',LOG_ERROR);
 end;
 if (((aVulkanDevice.Instance.APIVersion and VK_API_VERSION_WITHOUT_PATCH_MASK)<VK_API_VERSION_1_2) and
     (aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_SAMPLER_FILTER_MINMAX_EXTENSION_NAME)<0)) or
    (((aVulkanDevice.Instance.APIVersion and VK_API_VERSION_WITHOUT_PATCH_MASK)>=VK_API_VERSION_1_2) and
     (aVulkanDevice.PhysicalDevice.Vulkan12Features.samplerFilterMinmax=VK_FALSE)) then begin
  raise EpvApplication.Create('Application','Support for samplerFilterMinmax is needed',LOG_ERROR);
 end;
 if aVulkanDevice.PhysicalDevice.SamplerFilterMinmaxPropertiesEXT.filterMinmaxImageComponentMapping=VK_FALSE then begin
  raise EpvApplication.Create('Application','Support for filterMinmaxImageComponentMapping is needed',LOG_ERROR);
 end;
 if (aVulkanDevice.PhysicalDevice.DescriptorIndexingFeaturesEXT.descriptorBindingPartiallyBound=VK_FALSE) or
    (aVulkanDevice.PhysicalDevice.DescriptorIndexingFeaturesEXT.runtimeDescriptorArray=VK_FALSE) or
    (aVulkanDevice.PhysicalDevice.DescriptorIndexingFeaturesEXT.shaderSampledImageArrayNonUniformIndexing=VK_FALSE) then begin
  raise EpvApplication.Create('Application','Support for VK_EXT_DESCRIPTOR_INDEXING (descriptorBindingPartiallyBound + runtimeDescriptorArray + shaderSampledImageArrayNonUniformIndexing) is needed',LOG_ERROR);
 end;
{if aVulkanDevice.PhysicalDevice.BufferDeviceAddressFeaturesKHR.bufferDeviceAddress=VK_FALSE then begin
  raise EpvApplication.Create('Application','Support for VK_KHR_buffer_device_address (bufferDeviceAddress) is needed',LOG_ERROR);
 end;}
 if (aVulkanDevice.Instance.APIVersion and VK_API_VERSION_WITHOUT_PATCH_MASK)<VK_API_VERSION_1_1 then begin
  if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_BIND_MEMORY_2_EXTENSION_NAME)>=0 then begin
   aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_BIND_MEMORY_2_EXTENSION_NAME);
  end else begin
   raise EpvApplication.Create('Application','Support for VK_KHR_BIND_MEMORY_2 is needed',LOG_ERROR);
  end;
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_16BIT_STORAGE_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_16BIT_STORAGE_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_IMAGE_FORMAT_LIST_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_IMAGE_FORMAT_LIST_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_MAINTENANCE1_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_MAINTENANCE1_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_MAINTENANCE2_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_MAINTENANCE2_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_MAINTENANCE3_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_MAINTENANCE3_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_POST_DEPTH_COVERAGE_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_EXT_POST_DEPTH_COVERAGE_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_FRAGMENT_SHADER_INTERLOCK_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_EXT_FRAGMENT_SHADER_INTERLOCK_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_SHADER_DEMOTE_TO_HELPER_INVOCATION_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_EXT_SHADER_DEMOTE_TO_HELPER_INVOCATION_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_DESCRIPTOR_INDEXING_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_EXT_DESCRIPTOR_INDEXING_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_BUFFER_DEVICE_ADDRESS_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_BUFFER_DEVICE_ADDRESS_EXTENSION_NAME);
 end;
{if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_SHADER_FLOAT_CONTROLS_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_SHADER_FLOAT_CONTROLS_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_SHADER_FLOAT16_INT8_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_SHADER_FLOAT16_INT8_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_8BIT_STORAGE_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_8BIT_STORAGE_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_16BIT_STORAGE_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_16BIT_STORAGE_EXTENSION_NAME);
 end;//}
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_HOST_QUERY_RESET_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_EXT_HOST_QUERY_RESET_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_ACCELERATION_STRUCTURE_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_ACCELERATION_STRUCTURE_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_RAY_TRACING_PIPELINE_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_RAY_TRACING_PIPELINE_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_RAY_QUERY_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_RAY_QUERY_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_RAY_TRACING_MAINTENANCE_1_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_RAY_TRACING_MAINTENANCE_1_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_PIPELINE_LIBRARY_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_PIPELINE_LIBRARY_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_DEFERRED_HOST_OPERATIONS_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_DEFERRED_HOST_OPERATIONS_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_FRAGMENT_SHADER_BARYCENTRIC_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_FRAGMENT_SHADER_BARYCENTRIC_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_MESH_SHADER_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_EXT_MESH_SHADER_EXTENSION_NAME);
 end;
 if ((aVulkanDevice.Instance.APIVersion and VK_API_VERSION_WITHOUT_PATCH_MASK)<VK_API_VERSION_1_2) and
    (aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_SPIRV_1_4_EXTENSION_NAME)>=0) then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_SPIRV_1_4_EXTENSION_NAME);
 end;
 if ((aVulkanDevice.Instance.APIVersion and VK_API_VERSION_WITHOUT_PATCH_MASK)<VK_API_VERSION_1_2) and
    (aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_DRAW_INDIRECT_COUNT_EXTENSION_NAME)>=0) then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_KHR_DRAW_INDIRECT_COUNT_EXTENSION_NAME);
 end;
 if ((aVulkanDevice.Instance.APIVersion and VK_API_VERSION_WITHOUT_PATCH_MASK)<VK_API_VERSION_1_2) and
    (aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_SAMPLER_FILTER_MINMAX_EXTENSION_NAME)>=0) then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_EXT_SAMPLER_FILTER_MINMAX_EXTENSION_NAME);
 end;
 if aVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_SAMPLE_LOCATIONS_EXTENSION_NAME)>=0 then begin
  aVulkanDevice.EnabledExtensionNames.Add(VK_EXT_SAMPLE_LOCATIONS_EXTENSION_NAME);
 end;
end;

class function TpvScene3DRenderer.CheckBufferDeviceAddress(const aVulkanDevice:TpvVulkanDevice):boolean;
begin
 result:=assigned(aVulkanDevice) and
         ((aVulkanDevice.PhysicalDevice.BufferDeviceAddressFeaturesKHR.bufferDeviceAddress<>VK_FALSE){$ifndef Android}and
          (aVulkanDevice.PhysicalDevice.BufferDeviceAddressFeaturesKHR.bufferDeviceAddressCaptureReplay<>VK_FALSE){$endif}{and
          (aVulkanDevice.PhysicalDevice.Features.shaderInt64<>VK_FALSE)});
end;

procedure TpvScene3DRenderer.Prepare;
var Index:TpvSizeInt;
    SampleCounts:TVkSampleCountFlags;
    FormatProperties:TVkFormatProperties;
begin

 fVelocityBufferNeeded:=false;

 fGPUCulling:=true;

 fGPUShadowCulling:=not fScene3D.RaytracingActive;

 fEarlyDepthPrepassNeeded:=false;

 if fWetnessMapActive or fScreenSpaceAmbientOcclusion then begin
  fEarlyDepthPrepassNeeded:=true;
 end;

 if fShadowMapSize=0 then begin
  fShadowMapSize:=512;
 end;

 fShadowMapSize:=Max(16,fShadowMapSize);

 fBufferDeviceAddress:=fScene3D.UseBufferDeviceAddress;

 fRaytracingActive:=fScene3D.RaytracingActive;

 if fBufferDeviceAddress then begin
  if fRaytracingActive then begin
   fMeshFragTypeName:='matbufref_raytracing';
  end else begin
   fMeshFragTypeName:='matbufref';
  end;
 end else begin
  fMeshFragTypeName:='matssbo';
 end;

{FormatProperties:=fVulkanDevice.PhysicalDevice.GetFormatProperties(VK_FORMAT_B10G11R11_UFLOAT_PACK32);
 if (fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU) and
    ((FormatProperties.linearTilingFeatures and (TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                 TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                 TVkFormatFeatureFlags(VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT) or
                                                 TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                 TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT)))=(TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                                                                              TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                                                                              TVkFormatFeatureFlags(VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT) or
                                                                                                              TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                                                                              TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT))) and
    ((FormatProperties.optimalTilingFeatures and (TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                  TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                  TVkFormatFeatureFlags(VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT) or
                                                  TVkFormatFeatureFlags(VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT) or
                                                  TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                  TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT)))=(TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                                                                               TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                                                                               TVkFormatFeatureFlags(VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT) or
                                                                                                               TVkFormatFeatureFlags(VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT) or
                                                                                                               TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                                                                               TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT))) then begin
  fOptimizedNonAlphaFormat:=VK_FORMAT_B10G11R11_UFLOAT_PACK32;
 end else begin
  fOptimizedNonAlphaFormat:=VK_FORMAT_R16G16B16A16_SFLOAT;
 end;

 fOptimizedNonAlphaFormat:=VK_FORMAT_R16G16B16A16_SFLOAT;//}

{FormatProperties:=fVulkanDevice.PhysicalDevice.GetFormatProperties(VK_FORMAT_E5B9G9R9_UFLOAT_PACK32);
 if //(fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU) and
    ((FormatProperties.linearTilingFeatures and (TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                 TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                 TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                 TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT)))=(TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                                                                              TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                                                                              TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                                                                              TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT))) and
    ((FormatProperties.optimalTilingFeatures and (TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                  TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                  TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                  TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT)))=(TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                                                                               TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                                                                               TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                                                                               TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT))) then begin
  fOptimizedCubeMapFormat:=VK_FORMAT_E5B9G9R9_UFLOAT_PACK32;
 end else begin
  fOptimizedCubeMapFormat:=VK_FORMAT_R16G16B16A16_SFLOAT;
 end;}

 FormatProperties:=fVulkanDevice.PhysicalDevice.GetFormatProperties(VK_FORMAT_E5B9G9R9_UFLOAT_PACK32);
 if //(fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU) and
    ((FormatProperties.linearTilingFeatures and (TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                 TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                 TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                 TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT)))=(TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                                                                              TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                                                                              TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                                                                              TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT))) and
    ((FormatProperties.optimalTilingFeatures and (TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                  TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                  TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                  TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT)))=(TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                                                                               TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                                                                               TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                                                                               TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT))) then begin
  fOptimizedCubeMapFormat:=VK_FORMAT_E5B9G9R9_UFLOAT_PACK32;
 end else begin
  FormatProperties:=fVulkanDevice.PhysicalDevice.GetFormatProperties(VK_FORMAT_B10G11R11_UFLOAT_PACK32);
  if //(fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU) and
     ((FormatProperties.linearTilingFeatures and (TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                  TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                  TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                  TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT)))=(TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                                                                               TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                                                                               TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                                                                               TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT))) and
     ((FormatProperties.optimalTilingFeatures and (TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                   TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                   TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                   TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT)))=(TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or
                                                                                                                TVkFormatFeatureFlags(VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) or
                                                                                                                TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_DST_BIT) or
                                                                                                                TVkFormatFeatureFlags(VK_FORMAT_FEATURE_TRANSFER_SRC_BIT))) then begin
   fOptimizedCubeMapFormat:=VK_FORMAT_B10G11R11_UFLOAT_PACK32;
  end else begin
   fOptimizedCubeMapFormat:=VK_FORMAT_R16G16B16A16_SFLOAT;
  end;
 end;

//fOptimizedCubeMapFormat:=VK_FORMAT_B10G11R11_UFLOAT_PACK32;
//fOptimizedCubeMapFormat:=VK_FORMAT_E5B9G9R9_UFLOAT_PACK32;
//fOptimizedCubeMapFormat:=VK_FORMAT_R16G16B16A16_SFLOAT;
//fOptimizedCubeMapFormat:=VK_FORMAT_R32G32B32A32_SFLOAT;

 case TpvVulkanVendorID(fVulkanDevice.PhysicalDevice.Properties.vendorID) of
  TpvVulkanVendorID.ImgTec,
  TpvVulkanVendorID.ARM,
  TpvVulkanVendorID.Qualcomm,
  TpvVulkanVendorID.Vivante:begin
   // Tile-based GPUs => Use no depth prepass, as it can be counterproductive for those
   fUseDepthPrepass:=false;
  end;
  else begin
   // Immediate-based GPUs => Use depth prepass, as for which it can bring an advantage
   fUseDepthPrepass:=true;
  end;
 end;

 fUseDemote:=fVulkanDevice.ShaderDemoteToHelperInvocation;

 case TpvVulkanVendorID(fVulkanDevice.PhysicalDevice.Properties.vendorID) of
  TpvVulkanVendorID.Intel:begin
   // Workaround for Intel (i)GPUs, which've problems with discarding fragments in 2x2 fragment blocks at alpha-test usage
   fUseNoDiscard:=not fUseDemote;
   fUseOITAlphaTest:=true;
  end;
  else begin
   fUseNoDiscard:=false;
   fUseOITAlphaTest:=false;
  end;
 end;

 if fAntialiasingMode=TpvScene3DRendererAntialiasingMode.Auto then begin
  case TpvVulkanVendorID(fVulkanDevice.PhysicalDevice.Properties.vendorID) of
   TpvVulkanVendorID.AMD:begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
     fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.FXAA;
    end else begin
     fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.SMAA;
    end;
   end;
   TpvVulkanVendorID.NVIDIA:begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
     fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.FXAA;
    end else begin
     fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.SMAA;
    end;
   end;
   TpvVulkanVendorID.Intel:begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
     fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.FXAA;
    end else begin
     fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.SMAA;
    end;
   end;
   else begin
    fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.None;
   end;
  end;
//fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.TAA;
 end;

 case AntialiasingMode of
  TpvScene3DRendererAntialiasingMode.SMAAT2x,
  TpvScene3DRendererAntialiasingMode.TAA:begin
   fVelocityBufferNeeded:=true;
  end;
 end;

 SampleCounts:=fVulkanDevice.PhysicalDevice.Properties.limits.framebufferColorSampleCounts and
               fVulkanDevice.PhysicalDevice.Properties.limits.framebufferDepthSampleCounts and
               fVulkanDevice.PhysicalDevice.Properties.limits.framebufferStencilSampleCounts;

 if fMaxShadowMSAA=0 then begin
  case TpvVulkanVendorID(fVulkanDevice.PhysicalDevice.Properties.vendorID) of
   TpvVulkanVendorID.AMD:begin
    fMaxShadowMSAA:=1;
   end;
   TpvVulkanVendorID.NVIDIA:begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU then begin
     fMaxShadowMSAA:=8;
    end else begin
     fMaxShadowMSAA:=1;
    end;
   end;
   TpvVulkanVendorID.Intel:begin
    fMaxShadowMSAA:=1;
   end;
   else begin
    fMaxShadowMSAA:=1;
   end;
  end;
 end;

 if fMaxMSAA=0 then begin
  case TpvVulkanVendorID(fVulkanDevice.PhysicalDevice.Properties.vendorID) of
   TpvVulkanVendorID.AMD:begin
    fMaxMSAA:=2;
   end;
   TpvVulkanVendorID.NVIDIA:begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU then begin
     fMaxMSAA:=8;
    end else begin
     fMaxMSAA:=2;
    end;
   end;
   TpvVulkanVendorID.Intel:begin
    fMaxMSAA:=2;
   end;
   else begin
    fMaxMSAA:=2;
   end;
  end;
 end;

 if fShadowMode=TpvScene3DRendererShadowMode.Auto then begin
  fShadowMode:=TpvScene3DRendererShadowMode.PCF;
 end;

 if fShadowMode in [TpvScene3DRendererShadowMode.PCF,TpvScene3DRendererShadowMode.DPCF,TpvScene3DRendererShadowMode.PCSS] then begin
  fMeshFragShadowTypeName:='pcfpcss';
 end else begin
  fMeshFragShadowTypeName:='msm';
 end;

 if fShadowMode=TpvScene3DRendererShadowMode.MSM then begin
  if (fMaxShadowMSAA>=64) and ((SampleCounts and TVkSampleCountFlags(VK_SAMPLE_COUNT_64_BIT))<>0) then begin
   fShadowMapSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_64_BIT);
   fCountCascadedShadowMapMSAASamples:=64;
  end else if (fMaxShadowMSAA>=32) and ((SampleCounts and TVkSampleCountFlags(VK_SAMPLE_COUNT_32_BIT))<>0) then begin
   fShadowMapSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_32_BIT);
   fCountCascadedShadowMapMSAASamples:=32;
  end else if (fMaxShadowMSAA>=16) and ((SampleCounts and TVkSampleCountFlags(VK_SAMPLE_COUNT_16_BIT))<>0) then begin
   fShadowMapSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_16_BIT);
   fCountCascadedShadowMapMSAASamples:=16;
  end else if (fMaxShadowMSAA>=8) and ((SampleCounts and TVkSampleCountFlags(VK_SAMPLE_COUNT_8_BIT))<>0) then begin
   fShadowMapSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_8_BIT);
   fCountCascadedShadowMapMSAASamples:=8;
  end else if (fMaxShadowMSAA>=4) and ((SampleCounts and TVkSampleCountFlags(VK_SAMPLE_COUNT_4_BIT))<>0) then begin
   fShadowMapSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_4_BIT);
   fCountCascadedShadowMapMSAASamples:=4;
  end else if (fMaxShadowMSAA>=2) and ((SampleCounts and TVkSampleCountFlags(VK_SAMPLE_COUNT_2_BIT))<>0) then begin
   fShadowMapSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_2_BIT);
   fCountCascadedShadowMapMSAASamples:=2;
  end else begin
   fShadowMapSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT);
   fCountCascadedShadowMapMSAASamples:=1;
  end;
 end else begin
  fShadowMapSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT);
  fCountCascadedShadowMapMSAASamples:=1;
 end;

 if (fAntialiasingMode=TpvScene3DRendererAntialiasingMode.MSAA) or
    (fAntialiasingMode=TpvScene3DRendererAntialiasingMode.MSAASMAA) then begin
  if (fMaxMSAA>=64) and ((SampleCounts and TVkSampleCountFlags(VK_SAMPLE_COUNT_64_BIT))<>0) then begin
   fSurfaceSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_64_BIT);
   fCountSurfaceMSAASamples:=64;
  end else if (fMaxMSAA>=32) and ((SampleCounts and TVkSampleCountFlags(VK_SAMPLE_COUNT_32_BIT))<>0) then begin
   fSurfaceSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_32_BIT);
   fCountSurfaceMSAASamples:=32;
  end else if (fMaxMSAA>=16) and ((SampleCounts and TVkSampleCountFlags(VK_SAMPLE_COUNT_16_BIT))<>0) then begin
   fSurfaceSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_16_BIT);
   fCountSurfaceMSAASamples:=16;
  end else if (fMaxMSAA>=8) and ((SampleCounts and TVkSampleCountFlags(VK_SAMPLE_COUNT_8_BIT))<>0) then begin
   fSurfaceSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_8_BIT);
   fCountSurfaceMSAASamples:=8;
  end else if (fMaxMSAA>=4) and ((SampleCounts and TVkSampleCountFlags(VK_SAMPLE_COUNT_4_BIT))<>0) then begin
   fSurfaceSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_4_BIT);
   fCountSurfaceMSAASamples:=4;
  end else if (fMaxMSAA>=2) and ((SampleCounts and TVkSampleCountFlags(VK_SAMPLE_COUNT_2_BIT))<>0) then begin
   fSurfaceSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_2_BIT);
   fCountSurfaceMSAASamples:=2;
  end else begin
   fSurfaceSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT);
   fCountSurfaceMSAASamples:=1;
   fAntialiasingMode:=TpvScene3DRendererAntialiasingMode.FXAA;
  end;
 end else begin
  fSurfaceSampleCountFlagBits:=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT);
  fCountSurfaceMSAASamples:=1;
 end;

 case fSurfaceSampleCountFlagBits of 
  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT):begin
   fSurfaceMSAASampleLocations[0]:=TpvVector2.InlineableCreate(0.5,0.5);
  end;
  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_2_BIT):begin
   fSurfaceMSAASampleLocations[0]:=TpvVector2.InlineableCreate(0.75,0.75);
   fSurfaceMSAASampleLocations[1]:=TpvVector2.InlineableCreate(0.25,0.25);
  end; 
  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_4_BIT):begin
   fSurfaceMSAASampleLocations[0]:=TpvVector2.InlineableCreate(0.375,0.125);
   fSurfaceMSAASampleLocations[1]:=TpvVector2.InlineableCreate(0.875,0.375);
   fSurfaceMSAASampleLocations[2]:=TpvVector2.InlineableCreate(0.125,0.625);
   fSurfaceMSAASampleLocations[3]:=TpvVector2.InlineableCreate(0.625,0.875);
  end; 
  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_8_BIT):begin
   fSurfaceMSAASampleLocations[0]:=TpvVector2.InlineableCreate(0.5625,0.3125);
   fSurfaceMSAASampleLocations[1]:=TpvVector2.InlineableCreate(0.4375,0.6875);
   fSurfaceMSAASampleLocations[2]:=TpvVector2.InlineableCreate(0.8125,0.5625);
   fSurfaceMSAASampleLocations[3]:=TpvVector2.InlineableCreate(0.3125,0.1875);
   fSurfaceMSAASampleLocations[4]:=TpvVector2.InlineableCreate(0.1875,0.8125);
   fSurfaceMSAASampleLocations[5]:=TpvVector2.InlineableCreate(0.0625,0.4375);
   fSurfaceMSAASampleLocations[6]:=TpvVector2.InlineableCreate(0.6875,0.9375);
   fSurfaceMSAASampleLocations[7]:=TpvVector2.InlineableCreate(0.9375,0.0625);
  end;
  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_16_BIT):begin
   fSurfaceMSAASampleLocations[0]:=TpvVector2.InlineableCreate(0.5625,0.5625);
   fSurfaceMSAASampleLocations[1]:=TpvVector2.InlineableCreate(0.4375,0.3125);
   fSurfaceMSAASampleLocations[2]:=TpvVector2.InlineableCreate(0.3125,0.6250);
   fSurfaceMSAASampleLocations[3]:=TpvVector2.InlineableCreate(0.7500,0.4375);
   fSurfaceMSAASampleLocations[4]:=TpvVector2.InlineableCreate(0.1875,0.3750);
   fSurfaceMSAASampleLocations[5]:=TpvVector2.InlineableCreate(0.6250,0.8125);
   fSurfaceMSAASampleLocations[6]:=TpvVector2.InlineableCreate(0.8125,0.6875);
   fSurfaceMSAASampleLocations[7]:=TpvVector2.InlineableCreate(0.6875,0.1875);
   fSurfaceMSAASampleLocations[8]:=TpvVector2.InlineableCreate(0.3750,0.8750);
   fSurfaceMSAASampleLocations[9]:=TpvVector2.InlineableCreate(0.5000,0.0625);
   fSurfaceMSAASampleLocations[10]:=TpvVector2.InlineableCreate(0.2500,0.1250);
   fSurfaceMSAASampleLocations[11]:=TpvVector2.InlineableCreate(0.1250,0.7500);
   fSurfaceMSAASampleLocations[12]:=TpvVector2.InlineableCreate(0.0000,0.5000);
   fSurfaceMSAASampleLocations[13]:=TpvVector2.InlineableCreate(0.9375,0.2500);
   fSurfaceMSAASampleLocations[14]:=TpvVector2.InlineableCreate(0.8750,0.9375);
   fSurfaceMSAASampleLocations[15]:=TpvVector2.InlineableCreate(0.0625,0.0000);
  end; 
  else begin
   // Fallback to (0.5,0.5) sample location for all other sample counts, even if it is not the correct way to do it, because
   // from 32 samples on, the sample locations are not standardized anymore, so we cannot use the standard sample locations
   for Index:=0 to fCountSurfaceMSAASamples-1 do begin
    fSurfaceMSAASampleLocations[Index]:=TpvVector2.InlineableCreate(0.5,0.5);
   end; 
  end;  
 end; 

 if fTransparencyMode=TpvScene3DRendererTransparencyMode.Auto then begin
  case TpvVulkanVendorID(fVulkanDevice.PhysicalDevice.Properties.vendorID) of
   TpvVulkanVendorID.AMD:begin
    if (fSurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT)) and
       (fVulkanDevice.EnabledExtensionNames.IndexOf(VK_EXT_POST_DEPTH_COVERAGE_EXTENSION_NAME)>0) then begin
     // >= RDNA, since VK_EXT_post_depth_coverage exists just from RDNA on.
//   fTransparencyMode:=TpvScene3DRendererTransparencyMode.SPINLOCKOIT;
     fTransparencyMode:=TpvScene3DRendererTransparencyMode.MBOIT;
    end else begin
     if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
      fTransparencyMode:=TpvScene3DRendererTransparencyMode.WBOIT;
     end else begin
      fTransparencyMode:=TpvScene3DRendererTransparencyMode.LOOPOIT;
     end;
    end;
   end;
   TpvVulkanVendorID.NVIDIA:begin
(*  if fVulkanDevice.EnabledExtensionNames.IndexOf(VK_EXT_POST_DEPTH_COVERAGE_EXTENSION_NAME)>0 then begin
     if fVulkanDevice.FragmentShaderPixelInterlock and (fCountSurfaceMSAASamples=1) then begin
      fTransparencyMode:=TpvScene3DRendererTransparencyMode.INTERLOCKOIT;
{    end else if fVulkanDevice.FragmentShaderSampleInterlock and (fCountSurfaceMSAASamples<>1) then begin
      fTransparencyMode:=TpvScene3DRendererTransparencyMode.INTERLOCKOIT;}
     end else begin
      fTransparencyMode:=TpvScene3DRendererTransparencyMode.SPINLOCKOIT;
     end;
    end else*)begin
     if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
      fTransparencyMode:=TpvScene3DRendererTransparencyMode.WBOIT;
     end else begin
      fTransparencyMode:=TpvScene3DRendererTransparencyMode.MBOIT;
     end;
    end;
   end;
   TpvVulkanVendorID.Intel:begin
{   if (fSurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT)) and
       (fVulkanDevice.EnabledExtensionNames.IndexOf(VK_EXT_FRAGMENT_SHADER_INTERLOCK_EXTENSION_NAME)>0) and
       fVulkanDevice.PhysicalDevice.FragmentShaderPixelInterlock then begin
     fTransparencyMode:=TpvScene3DRendererTransparencyMode.INTERLOCKOIT;
    end else}begin
     if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
      fTransparencyMode:=TpvScene3DRendererTransparencyMode.WBOIT;
     end else begin
      fTransparencyMode:=TpvScene3DRendererTransparencyMode.MBOIT;
     end;
    end;
   end;
   else begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
     fTransparencyMode:=TpvScene3DRendererTransparencyMode.Direct;
    end else begin
     fTransparencyMode:=TpvScene3DRendererTransparencyMode.WBOIT;
    end;
   end;
  end;
 end;

//fTransparencyMode:=TpvScene3DRendererTransparencyMode.LOOPOIT;

 if fDepthOfFieldMode=TpvScene3DRendererDepthOfFieldMode.Auto then begin
  case TpvVulkanVendorID(fVulkanDevice.PhysicalDevice.Properties.vendorID) of
   TpvVulkanVendorID.AMD:begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
     fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.FullResHexagon;
    end else begin
     fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.HalfResBruteforce;
    end;
   end;
   TpvVulkanVendorID.NVIDIA:begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
     fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.FullResHexagon;
    end else begin
     fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.HalfResBruteforce;
    end;
   end;
   TpvVulkanVendorID.Intel:begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
     fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.None;
    end else begin
     fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.FullResHexagon;
    end;
   end;
   else begin
    fDepthOfFieldMode:=TpvScene3DRendererDepthOfFieldMode.None;
   end;
  end;
 end;

 if fLensMode=TpvScene3DRendererLensMode.Auto then begin
  case TpvVulkanVendorID(fVulkanDevice.PhysicalDevice.Properties.vendorID) of
   TpvVulkanVendorID.AMD:begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
     fLensMode:=TpvScene3DRendererLensMode.DownUpsample;
    end else begin
     fLensMode:=TpvScene3DRendererLensMode.DownUpsample;
    end;
   end;
   TpvVulkanVendorID.NVIDIA:begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
     fLensMode:=TpvScene3DRendererLensMode.DownUpsample;
    end else begin
     fLensMode:=TpvScene3DRendererLensMode.DownUpsample;
    end;
   end;
   TpvVulkanVendorID.Intel:begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
     fLensMode:=TpvScene3DRendererLensMode.None;
    end else begin
     fLensMode:=TpvScene3DRendererLensMode.DownUpsample;
    end;
   end;
   else begin
    fLensMode:=TpvScene3DRendererLensMode.None;
   end;
  end;
 end;

 if fGlobalIlluminationMode=TpvScene3DRendererGlobalIlluminationMode.Auto then begin
  case TpvVulkanVendorID(fVulkanDevice.PhysicalDevice.Properties.vendorID) of
   TpvVulkanVendorID.AMD:begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
     fGlobalIlluminationMode:=TpvScene3DRendererGlobalIlluminationMode.StaticEnvironmentMap;
    end else begin
     fGlobalIlluminationMode:=TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints;
    end;
   end;
   TpvVulkanVendorID.NVIDIA:begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
     fGlobalIlluminationMode:=TpvScene3DRendererGlobalIlluminationMode.StaticEnvironmentMap;
    end else begin
     fGlobalIlluminationMode:=TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints;
    end;
   end;
   TpvVulkanVendorID.Intel:begin
    if fVulkanDevice.PhysicalDevice.Properties.deviceType=VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU then begin
     fGlobalIlluminationMode:=TpvScene3DRendererGlobalIlluminationMode.StaticEnvironmentMap;
    end else begin
     fGlobalIlluminationMode:=TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints;
    end;
   end;
   else begin
    fGlobalIlluminationMode:=TpvScene3DRendererGlobalIlluminationMode.StaticEnvironmentMap;
   end;
  end;
//fGlobalIlluminationMode:=TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing;
  fGlobalIlluminationMode:=TpvScene3DRendererGlobalIlluminationMode.StaticEnvironmentMap;
 end;

 case fGlobalIlluminationMode of
  TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints:begin
   fMeshFragGlobalIlluminationTypeName:='globalillumination_cascaded_radiance_hints_';
   fEarlyDepthPrepassNeeded:=true;
  end;
  TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing:begin
   fMeshFragGlobalIlluminationTypeName:='globalillumination_cascaded_voxel_cone_tracing_';
  end;
  else begin
   fMeshFragGlobalIlluminationTypeName:='';
  end;
 end;

 if fToneMappingMode=TpvScene3DRendererToneMappingMode.Auto then begin
  fToneMappingMode:=TpvScene3DRendererToneMappingMode.AGXRec2020Punchy;
 end;

end;

procedure TpvScene3DRenderer.AcquirePersistentResources;
var Stream:TStream;
    UniversalQueue:TpvVulkanQueue;
    UniversalCommandPool:TpvVulkanCommandPool;
    UniversalCommandBuffer:TpvVulkanCommandBuffer;
    UniversalFence:TpvVulkanFence;
    EmptyAmbientOcclusionTextureData:TpvUInt8DynamicArray;
    SkyBoxTexture,EnvironmentTexture:TpvVulkanTexture;
    IntensityFactor:TpvFloat;
    EnvMapIsSkyBox:Boolean;
begin

 case fShadowMode of

  TpvScene3DRendererShadowMode.MSM:begin

   fShadowMapSampler:=TpvVulkanSampler.Create(fVulkanDevice,
                                              TVkFilter.VK_FILTER_LINEAR,
                                              TVkFilter.VK_FILTER_LINEAR,
                                              TVkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR,
                                              VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                              VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                              VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                              0.0,
                                              false,
                                              0.0,
                                              false,
                                              VK_COMPARE_OP_ALWAYS,
                                              0.0,
                                              0.0,
                                              VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE,
                                              false);

   fVulkanDevice.DebugUtils.SetObjectName(fShadowMapSampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRenderer.fShadowMapSampler');

  end;

  TpvScene3DRendererShadowMode.PCF:begin

   fShadowMapSampler:=TpvVulkanSampler.Create(fVulkanDevice,
                                              TVkFilter.VK_FILTER_LINEAR,
                                              TVkFilter.VK_FILTER_LINEAR,
                                              TVkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_NEAREST,
                                              VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                              VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                              VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                              0.0,
                                              false,
                                              0.0,
                                              true,
                                              VK_COMPARE_OP_GREATER,
                                              0.0,
                                              0.0,
                                              VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE,
                                              false);

   fVulkanDevice.DebugUtils.SetObjectName(fShadowMapSampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRenderer.fShadowMapSampler');

  end;

  else begin

   fShadowMapSampler:=TpvVulkanSampler.Create(fVulkanDevice,
                                              TVkFilter.VK_FILTER_NEAREST,
                                              TVkFilter.VK_FILTER_NEAREST,
                                              TVkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_NEAREST,
                                              VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                              VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                              VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                              0.0,
                                              false,
                                              0.0,
                                              false,
                                              VK_COMPARE_OP_ALWAYS,
                                              0.0,
                                              0.0,
                                              VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE,
                                              false);

   fVulkanDevice.DebugUtils.SetObjectName(fShadowMapSampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRenderer.fShadowMapSampler');

  end;

 end;

 fCheckShadowMapSampler:=TpvVulkanSampler.Create(fVulkanDevice,
                                                 TVkFilter.VK_FILTER_LINEAR,
                                                 TVkFilter.VK_FILTER_LINEAR,
                                                 TVkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_NEAREST,
                                                 VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                 VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                 VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                 0.0,
                                                 false,
                                                 0.0,
                                                 true,
                                                 VK_COMPARE_OP_GREATER,
                                                 0.0,
                                                 0.0,
                                                 VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE,
                                                 false);
 fVulkanDevice.DebugUtils.SetObjectName(fCheckShadowMapSampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRenderer.fCheckShadowMapSampler');

 fGeneralSampler:=TpvVulkanSampler.Create(fVulkanDevice,
                                          TVkFilter.VK_FILTER_LINEAR,
                                          TVkFilter.VK_FILTER_LINEAR,
                                          TVkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR,
                                          VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                          VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                          VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
                                          0.0,
                                          fVulkanDevice.PhysicalDevice.Properties.limits.maxSamplerAnisotropy>1.0,
                                          Max(1.0,fVulkanDevice.PhysicalDevice.Properties.limits.maxSamplerAnisotropy),
                                          false,
                                          VK_COMPARE_OP_ALWAYS,
                                          0.0,
                                          65536.0,
                                          VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK,
                                          false);
 fVulkanDevice.DebugUtils.SetObjectName(fGeneralSampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRenderer.fGeneralSampler');

 fOrderIndependentTransparencySampler:=TpvVulkanSampler.Create(VulkanDevice,
                                                               TVkFilter(VK_FILTER_LINEAR),
                                                               TVkFilter(VK_FILTER_LINEAR),
                                                               TVkSamplerMipmapMode(VK_SAMPLER_MIPMAP_MODE_LINEAR),
                                                               TVkSamplerAddressMode(VK_SAMPLER_ADDRESS_MODE_REPEAT),
                                                               TVkSamplerAddressMode(VK_SAMPLER_ADDRESS_MODE_REPEAT),
                                                               TVkSamplerAddressMode(VK_SAMPLER_ADDRESS_MODE_REPEAT),
                                                               0.0,
                                                               false,
                                                               1.0,
                                                               false,
                                                               TVkCompareOp(VK_COMPARE_OP_NEVER),
                                                               0.0,
                                                               1,
                                                               TVkBorderColor(VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK),
                                                               false);
 fVulkanDevice.DebugUtils.SetObjectName(fOrderIndependentTransparencySampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRenderer.fOrderIndependentTransparencySampler');

 fMipMapMinFilterSampler:=TpvVulkanSampler.Create(fVulkanDevice,
                                                  TVkFilter.VK_FILTER_LINEAR,
                                                  TVkFilter.VK_FILTER_LINEAR,
                                                  TVkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR,
                                                  VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                  VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                  VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                  0.0,
                                                  false,
                                                  1.0,
                                                  false,
                                                  VK_COMPARE_OP_ALWAYS,
                                                  0.0,
                                                  65536.0,
                                                  VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK,
                                                  false,
                                                  TVkSamplerReductionMode.VK_SAMPLER_REDUCTION_MODE_MIN_EXT);
 fVulkanDevice.DebugUtils.SetObjectName(fMipMapMinFilterSampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRenderer.fMipMapMinFilterSampler');

 fMipMapMaxFilterSampler:=TpvVulkanSampler.Create(fVulkanDevice,
                                                  TVkFilter.VK_FILTER_LINEAR,
                                                  TVkFilter.VK_FILTER_LINEAR,
                                                  TVkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR,
                                                  VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                  VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                  VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                  0.0,
                                                  false,
                                                  1.0,
                                                  false,
                                                  VK_COMPARE_OP_ALWAYS,
                                                  0.0,
                                                  65536.0,
                                                  VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK,
                                                  false,
                                                  TVkSamplerReductionMode.VK_SAMPLER_REDUCTION_MODE_MAX_EXT);
 fVulkanDevice.DebugUtils.SetObjectName(fMipMapMaxFilterSampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRenderer.fMipMapMaxFilterSampler');

 fRepeatedSampler:=TpvVulkanSampler.Create(fVulkanDevice,
                                           TVkFilter.VK_FILTER_LINEAR,
                                           TVkFilter.VK_FILTER_LINEAR,
                                           TVkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR,
                                           VK_SAMPLER_ADDRESS_MODE_REPEAT,
                                           VK_SAMPLER_ADDRESS_MODE_REPEAT,
                                           VK_SAMPLER_ADDRESS_MODE_REPEAT,
                                           0.0,
                                           false,
                                           1.0,
                                           false,
                                           VK_COMPARE_OP_ALWAYS,
                                           0.0,
                                           1000.0,
                                           VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK,
                                           false);
  fVulkanDevice.DebugUtils.SetObjectName(fRepeatedSampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRenderer.fRepeatedSampler');

  fMirrorRepeatedSampler:=TpvVulkanSampler.Create(fVulkanDevice,
                                                  TVkFilter.VK_FILTER_LINEAR,
                                                  TVkFilter.VK_FILTER_LINEAR,
                                                  TVkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR,
                                                  VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT,
                                                  VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT,
                                                  VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT,
                                                  0.0,
                                                  false,
                                                  1.0,
                                                  false,
                                                  VK_COMPARE_OP_ALWAYS,
                                                  0.0,
                                                  1000.0,
                                                  VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK,
                                                  false);
  fVulkanDevice.DebugUtils.SetObjectName(fMirrorRepeatedSampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRenderer.fMirrorRepeatedSampler');

  fClampedSampler:=TpvVulkanSampler.Create(fVulkanDevice,
                                          TVkFilter.VK_FILTER_LINEAR,
                                          TVkFilter.VK_FILTER_LINEAR,
                                          TVkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR,
                                          VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                          VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                          VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                          0.0,
                                          fVulkanDevice.PhysicalDevice.Properties.limits.maxSamplerAnisotropy>1.0,
                                          Max(1.0,fVulkanDevice.PhysicalDevice.Properties.limits.maxSamplerAnisotropy),
                                          false,
                                          VK_COMPARE_OP_ALWAYS,
                                          0.0,
                                          65536.0,
                                          VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK,
                                          false);
 fVulkanDevice.DebugUtils.SetObjectName(fClampedSampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRenderer.fClampedSampler');

 fClampedNearestSampler:=TpvVulkanSampler.Create(fVulkanDevice,
                                                 TVkFilter.VK_FILTER_NEAREST,
                                                 TVkFilter.VK_FILTER_NEAREST,
                                                 TVkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_NEAREST,
                                                 VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                 VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                 VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                 0.0,
                                                 false,
                                                 1.0,
                                                 false,
                                                 VK_COMPARE_OP_ALWAYS,
                                                 0.0,
                                                 65536.0,
                                                 VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK,
                                                 false);
 fVulkanDevice.DebugUtils.SetObjectName(fClampedNearestSampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRenderer.fClampedNearestSampler');

 fAmbientOcclusionSampler:=TpvVulkanSampler.Create(fVulkanDevice,
                                       TVkFilter.VK_FILTER_LINEAR,
                                       TVkFilter.VK_FILTER_LINEAR,
                                       TVkSamplerMipmapMode.VK_SAMPLER_MIPMAP_MODE_LINEAR,
                                       VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                       VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                       VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                       0.0,
                                       false,
                                       0.0,
                                       false,
                                       VK_COMPARE_OP_ALWAYS,
                                       0.0,
                                       0.0,
                                       VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE,
                                       false);
 fVulkanDevice.DebugUtils.SetObjectName(fAmbientOcclusionSampler.Handle,VK_OBJECT_TYPE_SAMPLER,'TpvScene3DRenderer.fAmbientOcclusionSampler');

 if assigned(fScene3D) and assigned(fScene3D.EnvironmentTextureImage) then begin
  fScene3D.EnvironmentTextureImage.Upload;
  EnvironmentTexture:=fScene3D.EnvironmentTextureImage.Texture;
 end else begin
  EnvironmentTexture:=nil;
 end;

 EnvMapIsSkyBox:=(fScene3D.SkyBoxTextureImage=fScene3D.EnvironmentTextureImage) and
                 (fScene3D.SkyBoxMode=fScene3D.EnvironmentMode) and
                 SameValue(fScene3D.SkyBoxIntensityFactor,fScene3D.EnvironmentIntensityFactor);

 fEnvironmentCubeMap:=TpvScene3DRendererEnvironmentCubeMap.Create(fVulkanDevice,fVulkanPipelineCache,fGeneralSampler,fScene3D.PrimaryLightDirection,fScene3D.EnvironmentIntensityFactor,not EnvMapIsSkyBox,fOptimizedCubeMapFormat,EnvironmentTexture,fScene3D.EnvironmentMode,'TpvScene3DRenderer.fEnvironmentCubeMap');
 fVulkanDevice.DebugUtils.SetObjectName(fEnvironmentCubeMap.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRenderer.fEnvironmentCubeMap.Image');
 fVulkanDevice.DebugUtils.SetObjectName(fEnvironmentCubeMap.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRenderer.fEnvironmentCubeMap.ImageView');

 if EnvMapIsSkyBox then begin

  fSkyBoxCubeMap:=fEnvironmentCubeMap;

 end else begin

  if assigned(fScene3D) and assigned(fScene3D.SkyBoxTextureImage) then begin
   fScene3D.SkyBoxTextureImage.Upload;
   SkyBoxTexture:=fScene3D.SkyBoxTextureImage.Texture;
   IntensityFactor:=fScene3D.SkyBoxIntensityFactor;
  end else if assigned(fScene3D) and assigned(fScene3D.EnvironmentTextureImage) then begin
   SkyBoxTexture:=fScene3D.EnvironmentTextureImage.Texture;
   IntensityFactor:=fScene3D.EnvironmentIntensityFactor;
  end else begin
   SkyBoxTexture:=nil;
   IntensityFactor:=fScene3D.SkyBoxIntensityFactor;
  end;

  fSkyBoxCubeMap:=TpvScene3DRendererEnvironmentCubeMap.Create(fVulkanDevice,fVulkanPipelineCache,fGeneralSampler,fScene3D.PrimaryLightDirection,IntensityFactor,false,fOptimizedCubeMapFormat,SkyBoxTexture,fScene3D.SkyBoxMode,'TpvScene3DRenderer.fSkyBoxCubeMap');
  fVulkanDevice.DebugUtils.SetObjectName(fSkyBoxCubeMap.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRenderer.fSkyBoxCubeMap.Image');
  fVulkanDevice.DebugUtils.SetObjectName(fSkyBoxCubeMap.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRenderer.fSkyBoxCubeMap.ImageView');

  if assigned(fScene3D) and assigned(fScene3D.SkyBoxTextureImage) then begin
   fScene3D.SkyBoxTextureImage.Unload;
  end;

 end;

 if assigned(fScene3D) and assigned(fScene3D.EnvironmentTextureImage) then begin
  fScene3D.EnvironmentTextureImage.Unload;
 end;

 fEnvironmentSphericalHarmonicsBuffer:=TpvVulkanBuffer.Create(fVulkanDevice,
                                                              SizeOf(TSphericalHarmonicsBufferData),
                                                              TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT),
                                                              TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                              [],
                                                              TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                              0,
                                                              0,
                                                              TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              [],
                                                              0,
                                                              pvAllocationGroupIDScene3DStatic,
                                                              'TpvScene3DRenderer.fSkySphericalHarmonicsBuffer'
                                                             );
 fVulkanDevice.DebugUtils.SetObjectName(fEnvironmentSphericalHarmonicsBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRenderer.fSkySphericalHarmonicsBuffer');

 fEnvironmentSphericalHarmonicsMetaDataBuffer:=TpvVulkanBuffer.Create(fVulkanDevice,
                                                                      SizeOf(TSphericalHarmonicsMetaDataBufferData),
                                                                      TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_SRC_BIT),
                                                                      TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                      [],
                                                                      TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                      0,
                                                                      0,
                                                                      TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      [],
                                                                      0,
                                                                      pvAllocationGroupIDScene3DStatic,
                                                                      'TpvScene3DRenderer.fSkySphericalHarmonicsMetaDataBuffer'
                                                                     );
 fVulkanDevice.DebugUtils.SetObjectName(fEnvironmentSphericalHarmonicsMetaDataBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRenderer.fSkySphericalHarmonicsMetaDataBuffer');

 fEnvironmentSphericalHarmonics:=TpvScene3DRendererImageBasedLightingSphericalHarmonics.Create(fVulkanDevice,fVulkanPipelineCache,fEnvironmentCubeMap.DescriptorImageInfo,fEnvironmentSphericalHarmonicsBuffer,fEnvironmentSphericalHarmonicsMetaDataBuffer,fEnvironmentCubeMap.Width,fEnvironmentCubeMap.Height,true);

 fGGXBRDF:=TpvScene3DRendererGGXBRDF.Create(fVulkanDevice,fVulkanPipelineCache,fGeneralSampler);
 fVulkanDevice.DebugUtils.SetObjectName(fGGXBRDF.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRenderer.fGGXBRDF.Image');
 fVulkanDevice.DebugUtils.SetObjectName(fGGXBRDF.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRenderer.fGGXBRDF.ImageView');

 fCharlieBRDF:=TpvScene3DRendererCharlieBRDF.Create(fVulkanDevice,fVulkanPipelineCache,fGeneralSampler);
 fVulkanDevice.DebugUtils.SetObjectName(fCharlieBRDF.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRenderer.fCharlieBRDF.Image');
 fVulkanDevice.DebugUtils.SetObjectName(fCharlieBRDF.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRenderer.fCharlieBRDF.ImageView');

 fSheenEBRDF:=TpvScene3DRendererSheenEBRDF.Create(fVulkanDevice,fVulkanPipelineCache,fGeneralSampler);
 fVulkanDevice.DebugUtils.SetObjectName(fSheenEBRDF.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRenderer.fSheenEBRDF.Image');
 fVulkanDevice.DebugUtils.SetObjectName(fSheenEBRDF.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRenderer.fSheenEBRDF.ImageView');

 fLensColor:=TpvScene3DRendererLensColor.Create(fVulkanDevice,fVulkanPipelineCache,fGeneralSampler);
 fVulkanDevice.DebugUtils.SetObjectName(fLensColor.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRenderer.fLensColor.Image');
 fVulkanDevice.DebugUtils.SetObjectName(fLensColor.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRenderer.fLensColor.ImageView');

 fLensDirt:=TpvScene3DRendererLensDirt.Create(fVulkanDevice,fVulkanPipelineCache,fGeneralSampler);
 fVulkanDevice.DebugUtils.SetObjectName(fLensDirt.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRenderer.fLensDirt.Image');
 fVulkanDevice.DebugUtils.SetObjectName(fLensDirt.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRenderer.fLensDirt.ImageView');

 fLensStar:=TpvScene3DRendererLensStar.Create(fVulkanDevice,fVulkanPipelineCache,fGeneralSampler);
 fVulkanDevice.DebugUtils.SetObjectName(fLensStar.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRenderer.fLensStar.Image');
 fVulkanDevice.DebugUtils.SetObjectName(fLensStar.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRenderer.fLensStar.ImageView');

 fImageBasedLightingEnvMapCubeMaps:=TpvScene3DRendererImageBasedLightingEnvMapCubeMaps.Create(fVulkanDevice,fVulkanPipelineCache,fRepeatedSampler,fEnvironmentCubeMap.DescriptorImageInfo,fOptimizedCubeMapFormat);

 UniversalQueue:=fVulkanDevice.UniversalQueue;
 try

  UniversalCommandPool:=TpvVulkanCommandPool.Create(fVulkanDevice,
                                                    fVulkanDevice.UniversalQueueFamilyIndex,
                                                    TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
  try

   UniversalCommandBuffer:=TpvVulkanCommandBuffer.Create(UniversalCommandPool,
                                                         VK_COMMAND_BUFFER_LEVEL_PRIMARY);
   try

    UniversalFence:=TpvVulkanFence.Create(fVulkanDevice);
    try

     case fAntialiasingMode of

      TpvScene3DRendererAntialiasingMode.SMAA,
      TpvScene3DRendererAntialiasingMode.SMAAT2x,
      TpvScene3DRendererAntialiasingMode.MSAASMAA:begin

       fSMAAAreaTexture:=TpvVulkanTexture.CreateFromMemory(fVulkanDevice,
                                                           UniversalQueue,
                                                           UniversalCommandBuffer,
                                                           UniversalFence,
                                                           UniversalQueue,
                                                           UniversalCommandBuffer,
                                                           UniversalFence,
                                                           VK_FORMAT_R8G8_UNORM,
                                                           VK_SAMPLE_COUNT_1_BIT,
                                                           PasVulkan.Scene3D.Renderer.SMAAData.AREATEX_WIDTH,
                                                           PasVulkan.Scene3D.Renderer.SMAAData.AREATEX_HEIGHT,
                                                           0,
                                                           0,
                                                           1,
                                                           0,
                                                           [TpvVulkanTextureUsageFlag.General,
                                                            TpvVulkanTextureUsageFlag.TransferDst,
                                                            TpvVulkanTextureUsageFlag.TransferSrc,
                                                            TpvVulkanTextureUsageFlag.Sampled],
                                                           @PasVulkan.Scene3D.Renderer.SMAAData.AreaTexBytes[0],
                                                           PasVulkan.Scene3D.Renderer.SMAAData.AREATEX_SIZE,
                                                           false,
                                                           false,
                                                           0,
                                                           true,
                                                           false,
                                                           false,
                                                           0,
                                                           'TpvScene3DRenderer.SMAAAreaTexture'
                                                          );
       fVulkanDevice.DebugUtils.SetObjectName(fSMAAAreaTexture.Image.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRenderer.fSMAAAreaTexture.Image');
       fVulkanDevice.DebugUtils.SetObjectName(fSMAAAreaTexture.ImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRenderer.fSMAAAreaTexture.ImageView');

       fSMAASearchTexture:=TpvVulkanTexture.CreateFromMemory(fVulkanDevice,
                                                             UniversalQueue,
                                                             UniversalCommandBuffer,
                                                             UniversalFence,
                                                             UniversalQueue,
                                                             UniversalCommandBuffer,
                                                             UniversalFence,
                                                             VK_FORMAT_R8_UNORM,
                                                             VK_SAMPLE_COUNT_1_BIT,
                                                             PasVulkan.Scene3D.Renderer.SMAAData.SEARCHTEX_WIDTH,
                                                             PasVulkan.Scene3D.Renderer.SMAAData.SEARCHTEX_HEIGHT,
                                                             0,
                                                             0,
                                                             1,
                                                             0,
                                                             [TpvVulkanTextureUsageFlag.General,
                                                              TpvVulkanTextureUsageFlag.TransferDst,
                                                              TpvVulkanTextureUsageFlag.TransferSrc,
                                                              TpvVulkanTextureUsageFlag.Sampled],
                                                             @PasVulkan.Scene3D.Renderer.SMAAData.SearchTexBytes[0],
                                                             PasVulkan.Scene3D.Renderer.SMAAData.SEARCHTEX_SIZE,
                                                             false,
                                                             false,
                                                             0,
                                                             true,
                                                             false,
                                                             false,
                                                             0,
                                                             'TpvScene3DRenderer.SMAASearchTexture');
       fVulkanDevice.DebugUtils.SetObjectName(fSMAASearchTexture.Image.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRenderer.fSMAASearchTexture.Image');
       fVulkanDevice.DebugUtils.SetObjectName(fSMAASearchTexture.ImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRenderer.fSMAASearchTexture.ImageView');

      end;
      else begin
      end;
     end;

     EmptyAmbientOcclusionTextureData:=nil;
     try
      SetLength(EmptyAmbientOcclusionTextureData,64*64*6);
      FillChar(EmptyAmbientOcclusionTextureData[0],length(EmptyAmbientOcclusionTextureData)*SizeOf(TpvUInt8),#$ff);
      fEmptyAmbientOcclusionTexture:=TpvVulkanTexture.CreateFromMemory(fVulkanDevice,
                                                                       UniversalQueue,
                                                                       UniversalCommandBuffer,
                                                                       UniversalFence,
                                                                       UniversalQueue,
                                                                       UniversalCommandBuffer,
                                                                       UniversalFence,
                                                                       VK_FORMAT_R8_UNORM,
                                                                       VK_SAMPLE_COUNT_1_BIT,
                                                                       64,
                                                                       64,
                                                                       0,
                                                                       6,
                                                                       1,
                                                                       0,
                                                                       [TpvVulkanTextureUsageFlag.General,
                                                                        TpvVulkanTextureUsageFlag.TransferDst,
                                                                        TpvVulkanTextureUsageFlag.TransferSrc,
                                                                        TpvVulkanTextureUsageFlag.Sampled],
                                                                       @EmptyAmbientOcclusionTextureData[0],
                                                                       length(EmptyAmbientOcclusionTextureData)*SizeOf(TpvUInt8),
                                                                       false,
                                                                       false,
                                                                       0,
                                                                       true,
                                                                       false,
                                                                       false,
                                                                       0,
                                                                       'TpvScene3DRenderer.fEmptyAmbientOcclusionTexture');
      fVulkanDevice.DebugUtils.SetObjectName(fEmptyAmbientOcclusionTexture.Image.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRenderer.fEmptyAmbientOcclusionTexture.Image');
      fVulkanDevice.DebugUtils.SetObjectName(fEmptyAmbientOcclusionTexture.ImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRenderer.fEmptyAmbientOcclusionTexture.ImageView');
     finally
      EmptyAmbientOcclusionTextureData:=nil;
     end;

{    case fLensMode of

      TpvScene3DRendererLensMode.DownUpsample:begin

       Stream:=TMemoryStream.Create;
       try
        Stream.Write(Scene3DLensColorData,Scene3DLensColorDataSize);
        Stream.Seek(0,soBeginning);
        fLensColorTexture:=TpvVulkanTexture.CreateFromImage(fVulkanDevice,
                                                            UniversalQueue,
                                                            UniversalCommandBuffer,
                                                            UniversalFence,
                                                            UniversalQueue,
                                                            UniversalCommandBuffer,
                                                            UniversalFence,
                                                            Stream,
                                                            false,
                                                            true,
                                                            false);
        fLensColorTexture.WrapModeU:=TpvVulkanTextureWrapMode.ClampToEdge;
        fLensColorTexture.WrapModeV:=TpvVulkanTextureWrapMode.ClampToEdge;
        fLensColorTexture.WrapModeW:=TpvVulkanTextureWrapMode.ClampToEdge;
        fLensColorTexture.UpdateSampler;
       finally
        FreeAndNil(Stream);
       end;

       Stream:=TMemoryStream.Create;
       try
        Stream.Write(Scene3DLensDirtData,Scene3DLensDirtDataSize);
        Stream.Seek(0,soBeginning);
        fLensDirtTexture:=TpvVulkanTexture.CreateFromImage(fVulkanDevice,
                                                           UniversalQueue,
                                                           UniversalCommandBuffer,
                                                           UniversalFence,
                                                           UniversalQueue,
                                                           UniversalCommandBuffer,
                                                           UniversalFence,
                                                           Stream,
                                                           false,
                                                           true,
                                                           false);
        fLensDirtTexture.WrapModeU:=TpvVulkanTextureWrapMode.ClampToEdge;
        fLensDirtTexture.WrapModeV:=TpvVulkanTextureWrapMode.ClampToEdge;
        fLensDirtTexture.WrapModeW:=TpvVulkanTextureWrapMode.ClampToEdge;
        fLensDirtTexture.UpdateSampler;
       finally
        FreeAndNil(Stream);
       end;

       Stream:=TMemoryStream.Create;
       try
        Stream.Write(Scene3DLensStarData,Scene3DLensStarDataSize);
        Stream.Seek(0,soBeginning);
        fLensStarTexture:=TpvVulkanTexture.CreateFromImage(fVulkanDevice,
                                                           UniversalQueue,
                                                           UniversalCommandBuffer,
                                                           UniversalFence,
                                                           UniversalQueue,
                                                           UniversalCommandBuffer,
                                                           UniversalFence,
                                                           Stream,
                                                           false,
                                                           true,
                                                           false);
        fLensStarTexture.WrapModeU:=TpvVulkanTextureWrapMode.ClampToEdge;
        fLensStarTexture.WrapModeV:=TpvVulkanTextureWrapMode.ClampToEdge;
        fLensStarTexture.WrapModeW:=TpvVulkanTextureWrapMode.ClampToEdge;
        fLensStarTexture.UpdateSampler;
       finally
        FreeAndNil(Stream);
       end;

      end;

      else begin
      end;

     end;//}

    finally
     FreeAndNil(UniversalFence);
    end;

   finally
    FreeAndNil(UniversalCommandBuffer);
   end;

  finally
   FreeAndNil(UniversalCommandPool);
  end;

 finally
  UniversalQueue:=nil;
 end;

end;

procedure TpvScene3DRenderer.ReleasePersistentResources;
begin

 FreeAndNil(fShadowMapSampler);

 FreeAndNil(fCheckShadowMapSampler);

 FreeAndNil(fAmbientOcclusionSampler);

 FreeAndNil(fClampedNearestSampler);

 FreeAndNil(fClampedSampler);

 FreeAndNil(fMirrorRepeatedSampler);

 FreeAndNil(fRepeatedSampler);

 FreeAndNil(fMipMapMaxFilterSampler);

 FreeAndNil(fMipMapMinFilterSampler);

 FreeAndNil(fOrderIndependentTransparencySampler);

 FreeAndNil(fGeneralSampler);

 FreeAndNil(fSMAAAreaTexture);
 FreeAndNil(fSMAASearchTexture);

 FreeAndNil(fEmptyAmbientOcclusionTexture);

{FreeAndNil(fLensColorTexture);
 FreeAndNil(fLensDirtTexture);
 FreeAndNil(fLensStarTexture);}

 FreeAndNil(fLensColor);

 FreeAndNil(fLensDirt);

 FreeAndNil(fLensStar);

 FreeAndNil(fCharlieBRDF);

 FreeAndNil(fGGXBRDF);

 FreeAndNil(fSheenEBRDF);

 FreeAndNil(fImageBasedLightingEnvMapCubeMaps);

 FreeAndNil(fEnvironmentSphericalHarmonics);

 FreeAndNil(fEnvironmentSphericalHarmonicsBuffer);

 FreeAndNil(fEnvironmentSphericalHarmonicsMetaDataBuffer);

 if assigned(fSkyBoxCubeMap) and (fSkyBoxCubeMap<>fEnvironmentCubeMap) then begin
  FreeAndNil(fSkyBoxCubeMap);
 end else begin
  fSkyBoxCubeMap:=nil;
 end;

 FreeAndNil(fEnvironmentCubeMap);

end;

end.

