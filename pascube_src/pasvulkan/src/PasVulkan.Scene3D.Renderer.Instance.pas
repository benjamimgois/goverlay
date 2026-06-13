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
unit PasVulkan.Scene3D.Renderer.Instance;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}
{$ifdef PasVulkanRangeChecks}
 {$rangechecks on}
{$endif}

{$undef UseSphereBasedCascadedShadowMaps}

{-$define FrameTextFileDebug}

interface

uses Classes,
     SysUtils,
     Math,
     PasMP,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Math.Double,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Resources,
     PasVulkan.FrameGraph,
     PasVulkan.TimerQuery,
     PasVulkan.Collections,
     PasVulkan.CircularDoublyLinkedList,
     PasVulkan.VirtualReality,
     PasVulkan.PasMP,
     PasVulkan.Scene3D,
     PasVulkan.Scene3D.Globals,
     PasVulkan.Scene3D.Renderer.Globals,
     PasVulkan.Scene3D.Renderer.CameraPreset,
     PasVulkan.Scene3D.Renderer,
     PasVulkan.Scene3D.Renderer.ParticleBVH,
     PasVulkan.Scene3D.Renderer.Array2DImage,
     PasVulkan.Scene3D.Renderer.Image2D,
     PasVulkan.Scene3D.Renderer.Image3D,
     PasVulkan.Scene3D.Renderer.MipmappedArray2DImage,
     PasVulkan.Scene3D.Renderer.MipmappedArray3DImage,
     PasVulkan.Scene3D.Renderer.OrderIndependentTransparencyBuffer,
     PasVulkan.Scene3D.Renderer.OrderIndependentTransparencyImage,
     PasVulkan.Scene3D.Renderer.ImageBasedLighting.ReflectionProbeCubeMaps,
     PasVulkan.Scene3D.Renderer.Instance.ColorGrading,
     PasVulkan.Scene3D.Renderer.MeshCullReset;

type { TpvScene3DRendererInstance }
     TpvScene3DRendererInstance=class(TpvScene3DRendererBaseObject)
      public
       const CountCascadedShadowMapCascades=4;
             CountOrderIndependentTransparencyLayers=8;
             CountGlobalIlluminationRadiantHintCascades=4;
             CountGlobalIlluminationRadiantHintSHImages=7;
             CountGlobalIlluminationRadiantHintVolumeImages=CountGlobalIlluminationRadiantHintSHImages+1;
             GlobalIlluminationRadiantHintVolumeSize=32;
             GlobalIlluminationRadiantHintVolumeDataSize=(GlobalIlluminationRadiantHintVolumeSize*
                                                          GlobalIlluminationRadiantHintVolumeSize*
                                                          GlobalIlluminationRadiantHintVolumeSize)*
                                                         GlobalIlluminationRadiantHintVolumeSize;
             // DDGI (dynamic diffuse global illumination) probe field. Must match the GI_DDGI_* defines in
             // global_illumination_ddgi.glsl. Irradiance default storage = L2 spherical harmonics (7 RGBA16F 3D images).
             CountGlobalIlluminationDDGICascades=4;
             GlobalIlluminationDDGIProbeCountX=16;
             GlobalIlluminationDDGIProbeCountY=16;
             GlobalIlluminationDDGIProbeCountZ=16;
             GlobalIlluminationDDGIProbesPerCascade=GlobalIlluminationDDGIProbeCountX*GlobalIlluminationDDGIProbeCountY*GlobalIlluminationDDGIProbeCountZ;
             GlobalIlluminationDDGIRaysPerProbe=128;
             {$define GI_DDGI_OCT_ALIGNED_BORDER_NPOT_SIZES} // mirror of the GLSL define (global_illumination_ddgi.glsl); comment out for the legacy 8/16 interior
             {$ifdef GI_DDGI_OCT_ALIGNED_BORDER_NPOT_SIZES}
             GlobalIlluminationDDGIIrradianceOctSize=6;
             GlobalIlluminationDDGIVisibilityOctSize=14;
             {$else}
             GlobalIlluminationDDGIIrradianceOctSize=8;
             GlobalIlluminationDDGIVisibilityOctSize=16;
             {$endif}
             GlobalIlluminationDDGIIrradianceOctFull=GlobalIlluminationDDGIIrradianceOctSize+2;
             GlobalIlluminationDDGIVisibilityOctFull=GlobalIlluminationDDGIVisibilityOctSize+2;
             // Irradiance storage mode: 0 = octahedral atlas (1 RGBA16F 2D image), 1 = L1 spherical harmonics
             // (3 RGBA16F 3D images), 2 = L2 spherical harmonics (7 RGBA16F 3D images). Compile-time choice; MUST match the
             // GI_DDGI_STORAGE (= DDGI_STORAGE in compileshaders.sh) the DDGI compute shaders AND the globalillumination_ddgi
             // mesh fragment variant are built with, otherwise the descriptor image counts / view types mismatch.
             GlobalIlluminationDDGIStorageMode=0;
             GlobalIlluminationDDGIStorageOctahedral=(GlobalIlluminationDDGIStorageMode=0);
             // SH image count: L2 = 7, L1 = 3 (and 3 as the unused placeholder size for the octahedral mode).
             GlobalIlluminationDDGISHImageCount=(7*Ord(GlobalIlluminationDDGIStorageMode=2))+(3*Ord(GlobalIlluminationDDGIStorageMode<>2));
             GlobalIlluminationDDGIIrradianceImageCount=(GlobalIlluminationDDGISHImageCount*(1-Ord(GlobalIlluminationDDGIStorageOctahedral)))+(1*Ord(GlobalIlluminationDDGIStorageOctahedral));
             GlobalIlluminationDDGIIrradianceAtlasWidth=GlobalIlluminationDDGIProbeCountX*GlobalIlluminationDDGIIrradianceOctFull;
             GlobalIlluminationDDGIIrradianceAtlasHeight=GlobalIlluminationDDGIProbeCountY*GlobalIlluminationDDGIProbeCountZ*CountGlobalIlluminationDDGICascades*GlobalIlluminationDDGIIrradianceOctFull;
             GlobalIlluminationDDGIVisibilityAtlasWidth=GlobalIlluminationDDGIProbeCountX*GlobalIlluminationDDGIVisibilityOctFull;
             GlobalIlluminationDDGIVisibilityAtlasHeight=GlobalIlluminationDDGIProbeCountY*GlobalIlluminationDDGIProbeCountZ*CountGlobalIlluminationDDGICascades*GlobalIlluminationDDGIVisibilityOctFull;
             // Glossy prefiltered-radiance octahedral atlas; same tiling as the visibility atlas (14/16 + guard band).
             {$ifdef GI_DDGI_OCT_ALIGNED_BORDER_NPOT_SIZES}
             GlobalIlluminationDDGIGlossyOctSize=14;
             {$else}
             GlobalIlluminationDDGIGlossyOctSize=16;
             {$endif}
             GlobalIlluminationDDGIGlossyOctFull=GlobalIlluminationDDGIGlossyOctSize+2;
             GlobalIlluminationDDGIGlossyAtlasWidth=GlobalIlluminationDDGIProbeCountX*GlobalIlluminationDDGIGlossyOctFull;
             GlobalIlluminationDDGIGlossyAtlasHeight=GlobalIlluminationDDGIProbeCountY*GlobalIlluminationDDGIProbeCountZ*CountGlobalIlluminationDDGICascades*GlobalIlluminationDDGIGlossyOctFull;
             // RTXGI-style probe relocation + classification. MUST match GI_DDGI_PROBE_RELOCATION (= DDGI_PROBE_RELOCATION in
             // compileshaders.sh) the DDGI shaders are built with. When true: the trace traces fixed relocation rays, the
             // relocation + classification compute passes run, a per-probe probe-data 3D image (xyz = relocation offset, w =
             // active state) is allocated, and the compute set (binding 5) + shading set (binding 3) carry it. When false none
             // of that exists (plain DDGI), and the binding counts match the relocation-off shader variants.
             GlobalIlluminationDDGIProbeRelocation=true;
             // Glossy prefiltered-radiance octahedral atlas, opt-in. When true: an extra RGBA16F octahedral atlas
             // (prefiltered RADIANCE, not cosine-convolved) is allocated, updated by the GlossyRadiance stage (chained
             // Irradiance -> GlossyRadiance -> Visibility), border-copied, and sampled at compute set 1 binding 5 / shading
             // set binding 5 for glossy reflections. MUST match GI_DDGI_GLOSSY_RADIANCE in compileshaders.sh (this RGBA16F
             // first iteration also needs -DGI_DDGI_GLOSSY_RGBA16F there; the RGB9E5 variant is a later memory optimization).
             // Default false (no atlas, no stage, no extra binding; the broad glossy in the frag shaders still applies).
             GlobalIlluminationDDGIGlossyRadiance=true;
             // VESTIGIAL: the per-probe convergence warmup is now ALWAYS on (per-probe age lives in its own BDA buffer, the
             // shaders no longer gate it, and the per-stage compute barrier covers the irradiance<->visibility ordering). This
             // const is referenced only by the DORMANT combined ProbeUpdate pass (kept for reference); the active per-stage
             // path ignores it. Kept so that file still compiles — safe to drop together with that pass.
             GlobalIlluminationDDGIProbeAgeWarmup=true;
             // Surfel-based global illumination. Must match the GI_SURFEL_* defines in global_illumination_surfel.glsl
             // (and SURFEL_STORAGE in compileshaders.sh). The persistent surfel pool is indexed by a world-space hash grid.
             GlobalIlluminationSurfelMaxCount=65536;                 // surfel pool capacity
             GlobalIlluminationSurfelHashCellCount=131072;           // hash buckets; MUST be a power of two (>= ~2x the pool)
             GlobalIlluminationSurfelMaxPerCell=32;                  // surfel index slots stored per hash cell
             GlobalIlluminationSurfelRaysPerSurfel=32;               // rays traced per surfel per frame (<= GI_SURFEL_RAYS_PER_SURFEL)
             // Radiance storage: 0 = octahedral atlas (per surfel), 1 = L1 SH (default), 2 = L2 SH. MUST match SURFEL_STORAGE.
             GlobalIlluminationSurfelStorageMode=2;
             GlobalIlluminationSurfelOctSize=4;                      // octahedral atlas edge (only used when storage mode = 0)
             GlobalIlluminationSurfelStorageIsSH=(GlobalIlluminationSurfelStorageMode<>0);
             // Per-surfel payload size in uvec2 units: L1 = 3, L2 = 7, OCT = N*N (one uvec2 per RGB texel).
             GlobalIlluminationSurfelPayloadUVec2Count=(7*Ord(GlobalIlluminationSurfelStorageMode=2))+
                                                       (3*Ord(GlobalIlluminationSurfelStorageMode=1))+
                                                       ((GlobalIlluminationSurfelOctSize*GlobalIlluminationSurfelOctSize)*Ord(GlobalIlluminationSurfelStorageMode=0));
             // Per-surfel radial depth atlas (occlusion): GI_SURFEL_DEPTH_OCT_SIZE² uint texels (half-packed mean/mean² of hit
             // distance per direction). MUST match GI_SURFEL_DEPTH_OCT_SIZE in global_illumination_surfel.glsl.
             GlobalIlluminationSurfelDepthOctSize=4;
             GlobalIlluminationSurfelDepthTexels=GlobalIlluminationSurfelDepthOctSize*GlobalIlluminationSurfelDepthOctSize;
             // GLSL std430 Surfel stride: positionRadius(16) + normalCount(16) + payload(count*8) + lastFrame/flags(8) +
             // skyVisibility(4) + depth(DepthTexels*4) = 44 + payload + depth, rounded up to the 16-byte struct alignment.
             GlobalIlluminationSurfelRecordSize=((44+(GlobalIlluminationSurfelPayloadUVec2Count*8)+(GlobalIlluminationSurfelDepthTexels*4)+15) div 16)*16;
             MaxMultiIndirectDrawCalls=65536; //1048576; // as worst case
             InitialCountSolidPrimitives=1 shl 10;
             MaxSolidPrimitives=1 shl 20;
             InitialCountSpaceLines=1 shl 10;
             MaxSpaceLines=1 shl 20;
       type TRaytracingFlag=
             (
              SoftShadows,
              SphereSolidAngleSampling,
              EarlyOutSampling
             );
            TRaytracingFlags=set of TRaytracingFlag;
            { TInFlightFrameState }
            TInFlightFrameState=record

             Ready:TPasMPBool32;

             CountViews:TpvSizeInt;

             FinalViewIndex:TpvSizeInt;
             FinalUnjitteredViewIndex:TpvSizeInt;
             CountFinalViews:TpvSizeInt;

             HUDViewIndex:TpvSizeInt;
             CountHUDViews:TpvSizeInt;

             ReflectionProbeViewIndex:TpvSizeInt;
             CountReflectionProbeViews:TpvSizeInt;

             TopDownSkyOcclusionMapViewIndex:TpvSizeInt;
             CountTopDownSkyOcclusionMapViews:TpvSizeInt;

             ReflectiveShadowMapViewIndex:TpvSizeInt;
             CountReflectiveShadowMapViews:TpvSizeInt;

             CloudsShadowMapViewIndex:TpvSizeInt;
             CountCloudsShadowMapViews:TpvSizeInt;

             CascadedShadowMapViewIndex:TpvSizeInt;
             CountCascadedShadowMapViews:TpvSizeInt;

             TopDownSkyOcclusionMapViewProjectionMatrix:TpvMatrix4x4;
             ReflectiveShadowMapMatrix:TpvMatrix4x4;
             CloudsShadowMapMatrix:TpvMatrix4x4;
             MainViewMatrix:TpvMatrix4x4;
             MainInverseViewMatrix:TpvMatrix4x4;
             MainViewProjectionMatrix:TpvMatrix4x4;
             MainCameraPosition:TpvVector3;

             ReflectiveShadowMapLightDirection:TpvVector3;
             ReflectiveShadowMapScale:TpvVector3;
             ReflectiveShadowMapExtents:TpvVector3;

             CloudsShadowMapLightDirection:TpvVector3;

             ZNear:TpvFloat;
             ZFar:TpvFloat;

             RealZNear:TpvFloat;
             RealZFar:TpvFloat;

             AdjustedZNear:TpvFloat;
             AdjustedZFar:TpvFloat;

             DoNeedRefitNearFarPlanes:Boolean;

             Jitter:TpvVector4;

             SkyBoxOrientation:TpvMatrix4x4;

             CameraReset:Boolean;

             SceneWorldSpaceBoundingBox:TpvAABB;

             SceneWorldSpaceSphere:TpvSphere;

            end;
            PInFlightFrameState=^TInFlightFrameState;
            TInFlightFrameStates=array[0..MaxInFlightFrames+1] of TInFlightFrameState;
            PInFlightFrameStates=^TInFlightFrameStates;
            TFrustumClusterGridPushConstants=packed record
             public
              TileSizeX:TpvUInt32;
              TileSizeY:TpvUInt32;
              ZNear:TpvFloat;
              ZFar:TpvFloat;
              ////
              ViewRect:TpvVector4;
              ////
              CountLights:TpvUInt32;
              ViewIndex:TpvUInt32;
              Size:TpvUInt32;
              OffsetedViewIndex:TpvUInt32;
              ////
              ClusterSizeX:TpvUInt32;
              ClusterSizeY:TpvUInt32;
              ClusterSizeZ:TpvUInt32;
              Reversed0:TpvUInt32;
              //
              ZScale:TpvFloat;
              ZBias:TpvFloat;
              ZMax:TpvFloat;
              Reversed1:TpvUInt32;
              //
              CountDecals:TpvUInt32;
              DecalReserved0:TpvUInt32;
              DecalReserved1:TpvUInt32;
              DecalReserved2:TpvUInt32;
            end;
            PFrustumClusterGridPushConstants=^TFrustumClusterGridPushConstants;
            TMeshCullUInt32PerCullRenderPassArray=array[0..MaxInFlightFrames-1,TpvScene3DRendererCullRenderPass] of TpvUInt32;
            { TCascadedShadowMap }
            TCascadedShadowMap=record
             public
              View:TpvScene3D.TView;
              CombinedMatrix:TpvMatrix4x4;
              SplitDepths:TpvVector2;
              Scales:TpvVector2;
            end;
            { TLockOrderIndependentTransparentViewPort }
            TLockOrderIndependentTransparentViewPort=packed record
             x:TpvInt32;
             y:TpvInt32;
             z:TpvInt32;
             w:TpvInt32;
            end;
            { TLockOrderIndependentTransparentUniformBuffer }
            TLockOrderIndependentTransparentUniformBuffer=packed record
             ViewPort:TLockOrderIndependentTransparentViewPort;
            end;
            { TLoopOrderIndependentTransparentViewPort }
            TLoopOrderIndependentTransparentViewPort=packed record
             x:TpvInt32;
             y:TpvInt32;
             z:TpvInt32;
             w:TpvInt32;
            end;
            { TLoopOrderIndependentTransparentUniformBuffer }
            TLoopOrderIndependentTransparentUniformBuffer=packed record
             ViewPort:TLoopOrderIndependentTransparentViewPort;
            end;
            { TApproximationOrderIndependentTransparentUniformBuffer }
            TApproximationOrderIndependentTransparentUniformBuffer=packed record
             ZNearZFar:TpvVector4;
            end;
            { TDebugMeshletSpherePushConstants }
            TDebugMeshletSpherePushConstants=packed record
             TotalPairCount:TpvUInt32;
             MaxOutputVertices:TpvUInt32;
             SphereBDA:TVkDeviceAddress;
             OutputBDA:TVkDeviceAddress;
             PairsBDA:TVkDeviceAddress;
             MatrixPairBDA:TVkDeviceAddress;
            end;
            PCascadedShadowMap=^TCascadedShadowMap;
            TCascadedShadowMaps=array[0..CountCascadedShadowMapCascades-1] of TCascadedShadowMap;
            PCascadedShadowMaps=^TCascadedShadowMaps;
            TInFlightFrameCascadedShadowMaps=array[0..MaxInFlightFrames-1] of TCascadedShadowMaps;
            TCascadedShadowMapUniformBuffer=packed record
             Matrices:array[0..CountCascadedShadowMapCascades-1] of TpvMatrix4x4;
             SplitDepthsScales:array[0..CountCascadedShadowMapCascades-1] of TpvVector4;
             ConstantBiasNormalBiasSlopeBiasClamp:array[0..CountCascadedShadowMapCascades-1] of TpvVector4;
             MetaData:array[0..3] of TpvUInt32;
            end;
            PCascadedShadowMapUniformBuffer=^TCascadedShadowMapUniformBuffer;
            TCascadedShadowMapUniformBuffers=array[0..MaxInFlightFrames-1] of TCascadedShadowMapUniformBuffer;
            TCascadedShadowMapVulkanUniformBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
            TCloudsShadowMapData=packed record
             PlanetCenter:TpvVector4; // xyz = planet center world position, w = unused (16 bytes)
             Params:TpvVector4;       // x=enabled (1.0), y=sunAngularRadius, zw=unused (16 bytes)
             LightDir:TpvVector4;     // xyz=sun direction world space, w=unused (16 bytes)
            end;                      // Total: 48 bytes
            PCloudsShadowMapData=^TCloudsShadowMapData;
            TCloudsShadowMapVulkanBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
            TVulkanBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
            { TPrepareDrawRenderInstanceFillTask }
            TPrepareDrawRenderInstanceFillTask=record
             FromIndex:TpvSizeInt;
             ToIndex:TpvSizeInt;
             FirstInstanceCommandIndex:TpvSizeInt;
             CountInstances:TpvSizeInt;
             NodeIndex:TpvSizeInt;
             CountIndices:TpvSizeInt;
             FirstIndex:TpvSizeInt;
             BoundingSphereIndex:TpvUInt32;
             LODInfoIndex:TpvUInt32;
             CommandFlags:TpvUInt32;
             GroupInstance:TObject; // TpvScene3D.TGroup.TInstance
            end;
            PPrepareDrawRenderInstanceFillTask=^TPrepareDrawRenderInstanceFillTask;
            TPrepareDrawRenderInstanceFillTasks=TpvDynamicArray<TPrepareDrawRenderInstanceFillTask>;
            TArray2DImages=array[0..MaxInFlightFrames-1] of TpvScene3DRendererArray2DImage;
            TMipmappedArray2DImages=array[0..MaxInFlightFrames-1] of TpvScene3DRendererMipmappedArray2DImage;
            TOrderIndependentTransparencyBuffers=array[0..MaxInFlightFrames-1] of TpvScene3DRendererOrderIndependentTransparencyBuffer;
            TOrderIndependentTransparencyImages=array[0..MaxInFlightFrames-1] of TpvScene3DRendererOrderIndependentTransparencyImage;
            TLuminanceVulkanBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
            TLuminanceBuffer=packed record
             HistogramLuminance:TpvFloat;
             LuminanceFactor:TpvFloat;
            end;
            PLuminanceBuffer=^TLuminanceBuffer;
            TLuminancePushConstants=packed record
             MinMaxLuminanceFactorExponent:TpvVector4;
             MinLogLuminance:TpvFloat;
             LogLuminanceRange:TpvFloat;
             InverseLogLuminanceRange:TpvFloat;
             TimeCoefficient:TpvFloat;
             MinLuminance:TpvFloat;
             MaxLuminance:TpvFloat;
             ManualLMax:TpvFloat;
             CountPixels:TpvUInt32;
            end;
            PLuminancePushConstants=^TLuminancePushConstants;
            TIntVector4=record
             x,y,z,w:TpvInt32;
            end;
            PIntVector4=^TIntVector4;
            TGlobalIlluminationRadianceHintsUniformBufferData=record
             AABBMin:array[0..CountGlobalIlluminationRadiantHintCascades-1] of TpvVector4;
             AABBMax:array[0..CountGlobalIlluminationRadiantHintCascades-1] of TpvVector4;
             AABBScale:array[0..CountGlobalIlluminationRadiantHintCascades-1] of TpvVector4;
             AABBCellSizes:array[0..CountGlobalIlluminationRadiantHintCascades-1] of TpvVector4;
             AABBSnappedCenter:array[0..CountGlobalIlluminationRadiantHintCascades-1] of TpvVector4;
             AABBCenter:array[0..CountGlobalIlluminationRadiantHintCascades-1] of TpvVector4;
             AABBFadeStart:array[0..CountGlobalIlluminationRadiantHintCascades-1] of TpvVector4;
             AABBFadeEnd:array[0..CountGlobalIlluminationRadiantHintCascades-1] of TpvVector4;
             AABBDeltas:array[0..CountGlobalIlluminationRadiantHintCascades-1] of TIntVector4;
            end;
            PGlobalIlluminationRadianceHintsUniformBufferData=^TGlobalIlluminationRadianceHintsUniformBufferData;
            TGlobalIlluminationRadianceHintsUniformBufferDataArray=array[0..MaxInFlightFrames-1] of TGlobalIlluminationRadianceHintsUniformBufferData;
            PGlobalIlluminationRadianceHintsUniformBufferDataArray=^TGlobalIlluminationRadianceHintsUniformBufferDataArray;

            // DDGI probe field uniform data; layout must match uboGlobalIlluminationDDGIData in global_illumination_ddgi.glsl.
            TGlobalIlluminationDDGIUniformBufferData=record
             AABBMin:array[0..CountGlobalIlluminationDDGICascades-1] of TpvVector4;
             AABBMax:array[0..CountGlobalIlluminationDDGICascades-1] of TpvVector4;
             AABBScale:array[0..CountGlobalIlluminationDDGICascades-1] of TpvVector4;
             CellSizes:array[0..CountGlobalIlluminationDDGICascades-1] of TpvVector4;     // w = max probe ray distance
             AABBCenter:array[0..CountGlobalIlluminationDDGICascades-1] of TpvVector4;
             AABBFadeStart:array[0..CountGlobalIlluminationDDGICascades-1] of TpvVector4;
             AABBFadeEnd:array[0..CountGlobalIlluminationDDGICascades-1] of TpvVector4;
             ProbeScroll:array[0..CountGlobalIlluminationDDGICascades-1] of TIntVector4;      // xyz = base cell floor(AABBMin/cellSize) this frame, w = scrolling enabled
             ProbeScrollPrev:array[0..CountGlobalIlluminationDDGICascades-1] of TIntVector4;  // xyz = base cell at the previous update of this in-flight slot (toroidal re-init)
            end;
            PGlobalIlluminationDDGIUniformBufferData=^TGlobalIlluminationDDGIUniformBufferData;
            TGlobalIlluminationDDGIUniformBufferDataArray=array[0..MaxInFlightFrames-1] of TGlobalIlluminationDDGIUniformBufferData;
            TGlobalIlluminationDDGIUniformBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
            TGlobalIlluminationDDGIImage2Ds=array[0..MaxInFlightFrames-1] of TpvScene3DRendererImage2D;
            TGlobalIlluminationDDGIImage3Ds=array[0..MaxInFlightFrames-1] of TpvScene3DRendererImage3D; // one RGBA16F 3D image per in-flight frame (probe relocation data)
            TGlobalIlluminationDDGIBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer; // per-in-flight BDA storage buffers (ray-data, master, ...)
            // BDA master: device-address pointers to the point-access DDGI sub-buffers; layout must match DDGIMaster in
            // gi_ddgi_master.glsl. Pointers are 0 until their migration phase enables them (ray-data = phase 1).
            TGlobalIlluminationDDGIMasterData=packed record
             RayData:TVkDeviceAddress;       // -> ray-data buffer
             ProbeData:TVkDeviceAddress;     // -> probe-data buffer (0 when relocation off)
             IrradianceSH:TVkDeviceAddress;  // -> SH-irradiance buffer (0 in octahedral storage mode)
             Age:TVkDeviceAddress;           // -> per-probe convergence age buffer (uint per probe)
            end;
            PGlobalIlluminationDDGIMasterData=^TGlobalIlluminationDDGIMasterData;
            TGlobalIlluminationDDGIDescriptorSets=array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
            // Surfel GI: the UBO (per in-flight frame, CPU-written) mirrors the SurfelUniforms std140 layout in the shader.
            // The pool / grid / stats / free-list are single persistent GPU-only SSBOs (the surfel state accumulates across
            // frames; within one queue the GPU executes frame N fully before N+1, so no per-in-flight duplication is needed).
            TGlobalIlluminationSurfelUniformBufferData=record
             CameraPositionCellSize:TpvVector4; // xyz = camera world position, w = base hash cell size
             CountsFrame:TpvUInt32Vector4;      // x = maxSurfels, y = hashCellCount, z = maxPerCell, w = frameIndex
             Params:TpvVector4;                 // x = surfel radius, y = hysteresis, z = recycle frame age, w = spawn coverage threshold
            end;
            PGlobalIlluminationSurfelUniformBufferData=^TGlobalIlluminationSurfelUniformBufferData;
            TGlobalIlluminationSurfelUniformBufferDataArray=array[0..MaxInFlightFrames-1] of TGlobalIlluminationSurfelUniformBufferData;
            TGlobalIlluminationSurfelUniformBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
            TGlobalIlluminationSurfelDescriptorSets=array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
            TGlobalIlluminationRadianceHintsRSMUniformBufferData=record
             WorldToReflectiveShadowMapMatrix:TpvMatrix4x4;
             ReflectiveShadowMapToWorldMatrix:TpvMatrix4x4;
             ModelViewProjectionMatrix:TpvMatrix4x4;
             SpreadExtents:array[0..3] of TpvVector4;
             LightDirection:TpvVector4;
             LightPosition:TpvVector4;
             ScaleFactors:TpvVector4;
             CountSamples:TpvInt32;
             CountOcclusionSamples:TpvInt32;
             Unused0:TpvInt32;
             Unused1:TpvInt32;
            end;
            PGlobalIlluminationRadianceHintsRSMUniformBufferData=^TGlobalIlluminationRadianceHintsRSMUniformBufferData;
            TGlobalIlluminationRadianceHintsRSMUniformBufferDataArray=array[0..MaxInFlightFrames-1] of TGlobalIlluminationRadianceHintsRSMUniformBufferData;
            PGlobalIlluminationRadianceHintsRSMUniformBufferDataArray=^TGlobalIlluminationRadianceHintsRSMUniformBufferDataArray;
            { TGlobalIlluminationCascadedVoxelConeTracingUniformBufferData }
            TGlobalIlluminationCascadedVoxelConeTracingUniformBufferData=packed record
             WorldToCascadeClipSpaceMatrices:array[0..7] of TpvMatrix4x4;
             WorldToCascadeNormalizedMatrices:array[0..7] of TpvMatrix4x4;
             WorldToCascadeGridMatrices:array[0..7] of TpvMatrix4x4;
             CascadeGridToWorldMatrices:array[0..7] of TpvMatrix4x4;
             CascadeAvoidAABBGridMin:array[0..7,0..3] of TpvInt32;
             CascadeAvoidAABBGridMax:array[0..7,0..3] of TpvInt32;
             CascadeAABBMin:array[0..7] of TpvVector4;
             CascadeAABBMax:array[0..7] of TpvVector4;
             CascadeAABBFadeStart:array[0..7] of TpvVector4;
             CascadeAABBFadeEnd:array[0..7] of TpvVector4;
             CascadeCenterHalfExtents:array[0..7] of TpvVector4;
             WorldToCascadeScales:array[0..7] of TpvFloat;
             CascadeToWorldScales:array[0..7] of TpvFloat;
             CascadeCellSizes:array[0..7] of TpvFloat;
             OneOverGridSizes:array[0..7] of TpvFloat;
             GridSizes:array[0..7] of TpvUInt32;
             DataOffsets:array[0..7] of TpvUInt32;
             CountCascades:TpvUInt32;
             HardwareConservativeRasterization:TpvUInt32;
             MaxGlobalFragmentCount:TpvUInt32;
             MaxLocalFragmentCount:TpvUInt32;
             EmissiveGIScale:TpvFloat; // global GI emissive master regulator: scale (mirrors voxelgriddata_uniforms.glsl)
             EmissiveGIMax:TpvFloat;   // global GI emissive master regulator: absolute cap
            end;
            PGlobalIlluminationCascadedVoxelConeTracingUniformBufferData=^TGlobalIlluminationCascadedVoxelConeTracingUniformBufferData;
            TGlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray=array[0..MaxInFlightFrames-1] of TGlobalIlluminationCascadedVoxelConeTracingUniformBufferData;
            PGlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray=^TGlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray;
            TGlobalIlluminationCascadedVoxelConeTracingBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
            TGlobalIlluminationCascadedVoxelConeTracingSideImages=array[0..7,0..5] of TpvScene3DRendererMipmappedArray3DImage;
            TGlobalIlluminationCascadedVoxelConeTracingImages=array[0..7] of TpvScene3DRendererMipmappedArray3DImage;
            TGlobalIlluminationCascadedVoxelConeTracingAtomicImages=array[0..7] of TpvScene3DRendererImage3D;
            { TMeshFragmentSpecializationConstants }
            TMeshFragmentSpecializationConstants=record
             public
              UseReversedZ:TVkBool32;
              procedure SetPipelineShaderStage(const aVulkanPipelineShaderStage:TpvVulkanPipelineShaderStage);
            end;
            { TCascadedShadowMapBuilder }
            TCascadedShadowMapBuilder=class
             public
              const CascadeNearPlaneOffset=-512.0;
                    CascadeFarPlaneOffset=512.0;
                    FrustumCorners:array[0..7] of TpvVector3=
                     (
                      (x:-1.0;y:-1.0;z:0.0),
                      (x:1.0;y:-1.0;z:0.0),
                      (x:-1.0;y:1.0;z:0.0),
                      (x:1.0;y:1.0;z:0.0),
                      (x:-1.0;y:-1.0;z:1.0),
                      (x:1.0;y:-1.0;z:1.0),
                      (x:-1.0;y:1.0;z:1.0),
                      (x:1.0;y:1.0;z:1.0)
                     );
             private
              fInstance:TpvScene3DRendererInstance;
              fLightForwardVector:TpvVector3;
              fLightSideVector:TpvVector3;
              fLightUpVector:TpvVector3;
              fFrustumCenter:TpvVector3;
              fOrigin:TpvVector3;
              fShadowOrigin:TpvVector2;
              fRoundedOrigin:TpvVector2;
              fRoundOffset:TpvVector2;
              fViewMatrix:TpvMatrix4x4;
              fProjectionMatrix:TpvMatrix4x4;
              fLightViewMatrix:TpvMatrix4x4;
              fTemporaryMatrix:TpvMatrix4x4;
              fLightProjectionMatrix:TpvMatrix4x4;
              fLightViewProjectionMatrix:TpvMatrix4x4;
              fInverseLightViewProjectionMatrix:TpvMatrix4x4;
              fInverseViewProjectionMatrices:array[0..7] of TpvMatrix4x4;
              fWorldSpaceFrustumCorners:array[0..7,0..7] of TpvVector3;
              fTemporaryFrustumCorners:array[0..7,0..7] of TpvVector3;
              fFrustumAABB:TpvAABB;
              fLightSpaceWorldAABB:TpvAABB;
             protected
              procedure SnapLightFrustum(var aScale,aOffset:TpvVector2;const aMatrix:TpvMatrix4x4;const aWorldOrigin:TpvVector3;const aShadowMapResolution:TpvVector2);
             public
              constructor Create(const aInstance:TpvScene3DRendererInstance); reintroduce;
              destructor Destroy; override;
              procedure Calculate(const aInFlightFrameIndex:TpvInt32);
            end;
            { TCascadedVolumes }
            TCascadedVolumes=class
             public
              type TCascadeVolumeKind=
                    (
                     General,
                     VoxelConeTracing,
                     CascadedRadianceHints,
                     DynamicDiffuseGlobalIllumination
                    );
                   { TCascade }
                   TCascade=class
                    private
                     fCascadedVolumes:TCascadedVolumes;
                     fAABB:TpvAABB;
                     fCellSize:TpvScalar;
                     fSnapSize:TpvScalar;
                     fOffset:TpvVector3;
                     fBorderCells:TpvInt32;
                     fDelta:TIntVector4;
                     fLastAABB:TpvAABB;
                     fLastOffset:TpvVector3;
                    public
                     constructor Create(const aCascadedVolumes:TCascadedVolumes); reintroduce;
                     destructor Destroy; override;
                   end;
                   TCascades=TpvObjectGenericList<TCascade>;
             private
              fRendererInstance:TpvScene3DRendererInstance;
              fVolumeSize:TpvSizeInt;
              fCountCascades:TpvSizeInt;
              fCascades:TCascades;
              fFirst:Boolean;
              fCascadeVolumeKind:TCascadeVolumeKind;
             public
              constructor Create(const aRendererInstance:TpvScene3DRendererInstance;const aVolumeSize,aCountCascades:TpvSizeInt;const aCascadeVolumeKind:TCascadeVolumeKind); reintroduce;
              destructor Destroy; override;
              procedure Reset;
              procedure Update(const aInFlightFrameIndex:TpvSizeInt);
             published
              property VolumeSize:TpvSizeInt read fVolumeSize;
              property Cascades:TCascades read fCascades;
            end;
            { THUDCustomPass }
            THUDCustomPass=class(TpvFrameGraph.TCustomPass)
             protected
              fRendererInstance:TpvScene3DRendererInstance;
              fParent:TObject;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;const aRendererInstance:TpvScene3DRendererInstance;const aParent:TObject); reintroduce; virtual;
            end;
            THUDCustomPassClass=class of THUDCustomPass;
            { THUDComputePass }
            THUDComputePass=class(TpvFrameGraph.TComputePass)
             protected
              fRendererInstance:TpvScene3DRendererInstance;
              fParent:TObject;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;const aRendererInstance:TpvScene3DRendererInstance;const aParent:TObject); reintroduce; virtual;
            end;
            THUDComputePassClass=class of THUDComputePass;
            { THUDRenderPass }
            THUDRenderPass=class(TpvFrameGraph.TRenderPass)
             protected
              fRendererInstance:TpvScene3DRendererInstance;
              fParent:TObject;
             public
              constructor Create(const aFrameGraph:TpvFrameGraph;const aRendererInstance:TpvScene3DRendererInstance;const aParent:TObject); reintroduce; virtual;
            end;
            THUDRenderPassClass=class of THUDRenderPass;
            TInFlightFrameMustRenderGIMaps=array[0..MaxInFlightFrames-1] of LongBool;
            TCascadedRadianceHintVolumeImages=array[0..CountGlobalIlluminationRadiantHintCascades-1,0..CountGlobalIlluminationRadiantHintVolumeImages-1] of TpvScene3DRendererImage3D;
            TInFlightFrameCascadedRadianceHintVolumeImages=array[0..MaxInFlightFrames-1] of TCascadedRadianceHintVolumeImages;
            PInFlightFrameCascadedRadianceHintVolumeImages=^TInFlightFrameCascadedRadianceHintVolumeImages;
            TGlobalIlluminationRadianceHintsUniformBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
            TGlobalIlluminationRadianceHintsDescriptorSets=array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
            TGlobalIlluminationRadianceHintsRSMUniformBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
            TGlobalIlluminationCascadedVoxelConeTracingDescriptorSets=array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
            TViews=array[0..MaxInFlightFrames-1] of TpvScene3D.TViews;
            TPerInFlightFrameVulkanDescriptorSets=array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
            TColorGradingSettingUniformBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
            { TSolidPrimitiveVertex }
            TSolidPrimitiveVertex=packed record
             public
              const PrimitiveTopologyPoint=0;
                    PrimitiveTopologyPointWireframe=1;
                    PrimitiveTopologyLine=2;
                    PrimitiveTopologyTriangle=3;
                    PrimitiveTopologyTriangleWireframe=4;
                    PrimitiveTopologyQuad=5;
                    PrimitiveTopologyQuadWireframe=6;
             public
              // uvec4-wise structure ordering so that the shaders can access it uvec4-wise
              case boolean of
               false:(

                Position:TpvVector2;                  //   8    8
                Offset0:TpvVector2;                   // + 8 = 16

                Position0:TpvVector3;                 // +12 = 28
                PrimitiveTopology:TpvUInt32;          // + 4 = 32

                Position1:TpvVector3;                 // +12 = 44
                LineThicknessorPointSize:TpvFloat;    // + 4 = 48

                Position2:TpvVector3;                 // +12 = 60
                InnerRadius:TpvFloat;                 // + 4 = 64

                Position3:TpvVector3;                 // +12 = 76
                Unused2:TpvUInt32;                    // + 4 = 80

                Offset1:TpvVector2;                   // + 8 = 88
                Offset2:TpvVector2;                   // + 8 = 96

                Offset3:TpvVector2;                   // + 8 = 104
                Unused:TpvVector2;                    // + 8 = 112

                Color:TpvVector4;                     // +16 = 128

               );                                     //  ==   ==
               true:(                                 //  128  128 per vertex
                Padding:array[0..127] of TpvUInt8;
               );
            end;
            PSolidPrimitiveVertex=^TSolidPrimitiveVertex;
            TSolidPrimitiveVertices=array of TSolidPrimitiveVertex;
            TSolidPrimitiveVertexDynamicArray=class(TpvDynamicArrayList<TSolidPrimitiveVertex>)
            end;
            TSolidPrimitiveVertexDynamicArrays=array[0..MaxInFlightFrames-1] of TSolidPrimitiveVertexDynamicArray;
            // For solid primitives, the primitive structure is just the same as the vertex structure for simplicity
            TSolidPrimitivePrimitive=TSolidPrimitiveVertex;
            PSolidPrimitivePrimitive=^TSolidPrimitivePrimitive;
            TSolidPrimitivePrimitives=TSolidPrimitiveVertices;
            TSolidPrimitivePrimitiveDynamicArray=TSolidPrimitiveVertexDynamicArray;
            TSolidPrimitivePrimitiveDynamicArrays=TSolidPrimitiveVertexDynamicArrays;
            TSolidPrimitiveIndex=TpvUInt32;
            PSolidPrimitiveIndex=^TSolidPrimitiveIndex;
            TSolidPrimitiveIndices=array of TSolidPrimitiveIndex;
            TSolidPrimitiveIndexDynamicArray=class(TpvDynamicArrayList<TSolidPrimitiveIndex>)
            end;
            TSolidPrimitiveIndexDynamicArrays=array[0..MaxInFlightFrames-1] of TSolidPrimitiveIndexDynamicArray;
            TSolidPrimitiveVulkanBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
            { TSpaceLinesVertex }
            TSpaceLinesVertex=packed record
             public
              // uvec4-wise structure ordering so that the shaders can access it uvec4-wise
              case boolean of
               false:(

                Position:TpvVector3;                  //  12   12
                LineThickness:TpvFloat;               // + 4 = 16

                Position0:TpvVector3;                 // +12 = 28
                ZMin:TpvFloat;                        // + 4 = 32

                Position1:TpvVector3;                 // +12 = 44
                ZMax:TpvFloat;                        // + 4 = 48

                Color:TpvVector4;                     // +16 = 64

               );                                     //  ==   ==
               true:(                                 //  64  64 per vertex
                Padding:array[0..63] of TpvUInt8;
               );
            end;
            PSpaceLinesVertex=^TSpaceLinesVertex;
            TSpaceLinesVertices=array of TSpaceLinesVertex;
            TSpaceLinesVertexDynamicArray=class(TpvDynamicArrayList<TSpaceLinesVertex>)
            end;
            TSpaceLinesVertexDynamicArrays=array[0..MaxInFlightFrames-1] of TSpaceLinesVertexDynamicArray;
            // For space lines, the primitive structure is just the same as the vertex structure for simplicity
            TSpaceLinesPrimitive=TSpaceLinesVertex;
            PSpaceLinesPrimitive=^TSpaceLinesPrimitive;
            TSpaceLinesPrimitives=TSpaceLinesVertices;
            TSpaceLinesPrimitiveDynamicArray=TSpaceLinesVertexDynamicArray;
            TSpaceLinesPrimitiveDynamicArrays=TSpaceLinesVertexDynamicArrays;
            TSpaceLinesIndex=TpvUInt32;
            PSpaceLinesIndex=^TSpaceLinesIndex;
            TSpaceLinesIndices=array of TSpaceLinesIndex;
            TSpaceLinesIndexDynamicArray=class(TpvDynamicArrayList<TSpaceLinesIndex>)
            end;
            TSpaceLinesIndexDynamicArrays=array[0..MaxInFlightFrames-1] of TSpaceLinesIndexDynamicArray;
            TSpaceLinesVulkanBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
            TInFlightFrameSemaphores=array[0..MaxInFlightFrames-1] of TpvVulkanSemaphore;
      private
       fScene3D:TpvScene3D;
       fRendererInstanceIndex:TpvSizeInt;
       fID:TpvUInt32;
       fFrameGraph:TpvFrameGraph;
       fVirtualReality:TpvVirtualReality;
       fExternalImageFormat:TVkFormat;
       fExternalOutputImageData:TpvFrameGraph.TExternalImageData;
       fHasExternalOutputImage:boolean;
       fReflectionProbeWidth:TpvInt32;
       fReflectionProbeHeight:TpvInt32;
       fTopDownSkyOcclusionMapWidth:TpvInt32;
       fTopDownSkyOcclusionMapHeight:TpvInt32;
       fReflectiveShadowMapWidth:TpvInt32;
       fReflectiveShadowMapHeight:TpvInt32;
       fCascadedShadowMapWidth:TpvInt32;
       fCascadedShadowMapHeight:TpvInt32;
       fCascadedShadowMapCenter:TpvVector3D;
       fCascadedShadowMapRadius:TpvDouble;
       fShadowMaximumDistance:TpvFloat;
       fShadowAreaTooSmallThreshold:TpvFloat;
       fFinalViewMaximumDistance:TpvFloat;
       fFinalViewAreaTooSmallThreshold:TpvFloat;
       fCountSurfaceViews:TpvInt32;
       fSurfaceMultiviewMask:TpvUInt32;
       fLeft:TpvInt32;
       fTop:TpvInt32;
       fWidth:TpvInt32;
       fHeight:TpvInt32;
       fHUDWidth:TpvInt32;
       fHUDHeight:TpvInt32;
       fScaledWidth:TpvInt32;
       fScaledHeight:TpvInt32;
       fRawRaytracingFlags:TpvUInt32;
       fRaytracingSoftShadowSampleCount:TpvUInt32;
       fRaytracingFlags:TRaytracingFlags;
       fFrustumClusterGridSizeX:TpvInt32;
       fFrustumClusterGridSizeY:TpvInt32;
       fFrustumClusterGridSizeZ:TpvInt32;
       fFrustumClusterGridTileSizeX:TpvInt32;
       fFrustumClusterGridTileSizeY:TpvInt32;
       fFrustumClusterGridCountTotalViews:TpvInt32;
       fZNear:TpvFloat;
       fZFar:TpvFloat;
       fCameraViewMatrices:array[0..MaxInFlightFrames-1] of TpvMatrix4x4D;
       fInFlightFrameStates:TInFlightFrameStates;
       fPointerToInFlightFrameStates:PInFlightFrameStates;
       fMeshFragmentSpecializationConstants:TMeshFragmentSpecializationConstants;
       fCameraPresets:array[0..MaxInFlightFrames-1] of TpvScene3DRendererCameraPreset;
       fCameraPreset:TpvScene3DRendererCameraPreset;
       fUseDebugBlit:boolean;
       fWaterExternalWaitingOnSemaphore:TpvFrameGraph.TExternalWaitingOnSemaphore;
       fAtmosphereExternalWaitingOnSemaphore:TpvFrameGraph.TExternalWaitingOnSemaphore;
       fWaterSimulationSemaphores:TInFlightFrameSemaphores;
       fAtmospherePrecipitationSimulationSemaphores:TInFlightFrameSemaphores;
      private
       fMeshStagePushConstants:TpvScene3D.TMeshStagePushConstantArray;
       fDrawChoreographyBatchItemFrameBuckets:TpvScene3D.TDrawChoreographyBatchItemFrameBuckets;
       fPrepareDrawRenderInstanceFillTasks:TPrepareDrawRenderInstanceFillTasks;
       fPrepareDrawRenderInstanceFillTasksInFlightFrameIndex:TpvSizeInt;
       fCachedDrawDataGeneration:array[0..MaxInFlightFrames-1] of TPasMPUInt64;
       fSnapshotDrawDataGeneration:array[0..MaxInFlightFrames-1] of TPasMPUInt64;
      public
       fSetGlobalResourcesDone:TpvScene3D.TSetGlobalResourcesDone;
      private
       fViews:TpvScene3DRendererInstance.TViews;
      private
       fLastUploadedViews:TpvScene3DRendererInstance.TViews;
      private
       fCountRealViews:array[0..MaxInFlightFrames-1] of TpvInt32;
      private
       fVulkanRenderSemaphores:array[0..MaxInFlightFrames-1] of TpvVulkanSemaphore;
      private
       fParticleBVH:TpvScene3DRendererParticleBVH;
      private
       fInFlightFrameCascadedRadianceHintVolumeImages:TInFlightFrameCascadedRadianceHintVolumeImages;
       fInFlightFrameCascadedRadianceHintVolumeSecondBounceImages:TInFlightFrameCascadedRadianceHintVolumeImages;
       fGlobalIlluminationRadianceHintsUniformBufferDataArray:TGlobalIlluminationRadianceHintsUniformBufferDataArray;
       fGlobalIlluminationRadianceHintsUniformBuffers:TGlobalIlluminationRadianceHintsUniformBuffers;
       fGlobalIlluminationDDGICascadedVolumes:TCascadedVolumes;
       fGlobalIlluminationDDGIProbeBaseCells:array[0..MaxInFlightFrames-1,0..CountGlobalIlluminationDDGICascades-1] of TpvVector3; // per in-flight slot per cascade: rounded baseCell of the previous update, for toroidal scroll re-init
       fGlobalIlluminationDDGIUniformBufferDataArray:TGlobalIlluminationDDGIUniformBufferDataArray;
       // (the separate DDGI globals UBO buffer is gone — globals + sub-buffer pointers now share one SSBO: fGlobalIlluminationDDGIMasterBuffers)
       fGlobalIlluminationDDGIIrradianceSHBuffers:TGlobalIlluminationDDGIBuffers;              // SH storage: BDA buffer (DDGI_SH_IMAGE_COUNT packed vec4 per probe) per frame
       fGlobalIlluminationDDGIIrradianceOctImages:TGlobalIlluminationDDGIImage2Ds;             // octahedral storage: 1 RGBA16F 2D atlas per frame
       fGlobalIlluminationDDGIVisibilityMomentsImages:TGlobalIlluminationDDGIImage2Ds;          // visibility MOMENTS atlas (RG32F): x = mean dist, y = mean dist^2
       fGlobalIlluminationDDGIVisibilitySkyImages:TGlobalIlluminationDDGIImage2Ds;              // visibility SKY atlas (R8): x = sky visibility (0..1)
       fGlobalIlluminationDDGIGlossyImages:TGlobalIlluminationDDGIImage2Ds;                     // glossy prefiltered-radiance atlas (RGBA16F; only when GlobalIlluminationDDGIGlossyRadiance)
       fGlobalIlluminationDDGIRayDataBuffers:TGlobalIlluminationDDGIBuffers;                    // BDA storage buffer (rgb = radiance, a = distance), per in-flight frame
       fGlobalIlluminationDDGIMasterBuffers:TGlobalIlluminationDDGIBuffers;                     // unified DDGI data SSBO (`ddgiData`): cascade globals + BDA sub-buffer pointers, per in-flight frame (BAR, binding 0)
       fGlobalIlluminationDDGIProbeDataBuffers:TGlobalIlluminationDDGIBuffers;                  // relocation only: BDA buffer, vec4 per probe (xyz = offset, w = active state)
       fGlobalIlluminationDDGIAgeBuffers:TGlobalIlluminationDDGIBuffers;                        // BDA buffer, uint per probe (per-probe convergence age, written by visibility / read by irradiance)
       fGlobalIlluminationDDGIDescriptorPool:TpvVulkanDescriptorPool;
       fGlobalIlluminationDDGIDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fGlobalIlluminationDDGIDescriptorSets:TGlobalIlluminationDDGIDescriptorSets;
       fGlobalIlluminationDDGIFirstFrames:array[0..MaxInFlightFrames-1] of boolean; // per in-flight slot: true until that slot's probe images were written once (not cleared on alloc); shared by the trace + probe-update passes
       // Surfel GI resources. UBO per in-flight frame; the pool/grid/stats/free-list are single persistent SSBOs.
       fGlobalIlluminationSurfelUniformBufferDataArray:TGlobalIlluminationSurfelUniformBufferDataArray;
       fGlobalIlluminationSurfelUniformBuffers:TGlobalIlluminationSurfelUniformBuffers;
       fGlobalIlluminationSurfelPoolBuffer:TpvVulkanBuffer;          // GI_SURFEL_MAX_COUNT * GlobalIlluminationSurfelRecordSize
       fGlobalIlluminationSurfelGridCellBuffer:TpvVulkanBuffer;      // hashCellCount * maxPerCell * uint
       fGlobalIlluminationSurfelGridCellCountBuffer:TpvVulkanBuffer; // hashCellCount * uint
       fGlobalIlluminationSurfelStatsBuffer:TpvVulkanBuffer;         // 4 * uint (spawn cursor, alive count, free counts[2])
       fGlobalIlluminationSurfelFreeListBuffer:TpvVulkanBuffer;      // 2 * GI_SURFEL_MAX_COUNT * uint (parity banks)
       fGlobalIlluminationSurfelDescriptorPool:TpvVulkanDescriptorPool;
       fGlobalIlluminationSurfelDescriptorSetLayout:TpvVulkanDescriptorSetLayout;   // shading-side (set 2 mesh / set 4 planet): UBO + pool + grid cells + grid counts
       fGlobalIlluminationSurfelDescriptorSets:TGlobalIlluminationSurfelDescriptorSets;
       fGlobalIlluminationRadianceHintsRSMUniformBufferDataArray:TGlobalIlluminationRadianceHintsRSMUniformBufferDataArray;
       fGlobalIlluminationRadianceHintsRSMUniformBuffers:TGlobalIlluminationRadianceHintsRSMUniformBuffers;
       fGlobalIlluminationRadianceHintsCascadedVolumes:TCascadedVolumes;
       fGlobalIlluminationRadianceHintsDescriptorPool:TpvVulkanDescriptorPool;
       fGlobalIlluminationRadianceHintsDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fGlobalIlluminationRadianceHintsDescriptorSets:TGlobalIlluminationRadianceHintsDescriptorSets;
       fGlobalIlluminationRadianceHintsFirsts:array[0..MaxInFlightFrames-1] of LongBool;
      public
       fGlobalIlluminationRadianceHintsEvents:array[0..MaxInFlightFrames-1] of TpvVulkanEvent;
       fGlobalIlluminationRadianceHintsEventReady:array[0..MaxInFlightFrames-1] of boolean;
      private
       fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes:TCascadedVolumes;
       fGlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray:TGlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray;
       fGlobalIlluminationCascadedVoxelConeTracingUniformBuffers:TGlobalIlluminationCascadedVoxelConeTracingBuffers;
       fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffers:TpvVulkanInFlightFrameBuffers;
       fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers:TpvVulkanInFlightFrameBuffers;
       fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages:TGlobalIlluminationCascadedVoxelConeTracingImages;
       fGlobalIlluminationCascadedVoxelConeTracingRadianceImages:TGlobalIlluminationCascadedVoxelConeTracingSideImages;
       // Dedicated visualization volume (×6 anisotropic sides per cascade): unlit base colour + emission, filled by the radiance
       // transfer compute only while the debug visualization is active. Dual-view (R32_UINT storage / E5B9G9R9 sample) so it stays
       // RenderDoc-inspectable. Read by the voxel mesh/vertex visualizations instead of the lit radiance images.
       fGlobalIlluminationCascadedVoxelConeTracingVisualizationImages:TGlobalIlluminationCascadedVoxelConeTracingSideImages;
       fGlobalIlluminationCascadedVoxelConeTracingMaxGlobalFragmentCount:TpvUInt32;
       fGlobalIlluminationCascadedVoxelConeTracingMaxLocalFragmentCount:TpvUInt32;
       fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool:TpvVulkanDescriptorPool;
       fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets:TGlobalIlluminationCascadedVoxelConeTracingDescriptorSets;
       fGlobalIlluminationCascadedVoxelConeTracingDebugVisualization:LongBool;
       fDrawMeshletDebugColors:boolean;
      public
       fGlobalIlluminationCascadedVoxelConeTracingEvents:array[0..MaxInFlightFrames-1] of TpvVulkanEvent;
       fGlobalIlluminationCascadedVoxelConeTracingEventReady:array[0..MaxInFlightFrames-1] of boolean;
       fGlobalIlluminationCascadedVoxelConeTracingFirst:array[0..MaxInFlightFrames-1] of boolean;
      private
       fInFlightFrameMustRenderGIMaps:TInFlightFrameMustRenderGIMaps;
      private
       fNearestFarthestDepthVulkanBuffers:TVulkanBuffers;
       fDepthOfFieldAutoFocusVulkanBuffers:TVulkanBuffers;
       fDepthOfFieldBokenShapeTapVulkanBuffers:TVulkanBuffers;
      private
       fFrustumClusterGridPushConstants:TpvScene3DRendererInstance.TFrustumClusterGridPushConstants;
       fFrustumClusterGridGlobalsVulkanBuffers:TVulkanBuffers;
       fFrustumClusterGridAABBVulkanBuffers:TVulkanBuffers;
       fFrustumClusterGridIndexListCounterVulkanBuffers:TVulkanBuffers;
       fFrustumClusterGridIndexListVulkanBuffers:TVulkanBuffers;
       fFrustumClusterGridDataVulkanBuffers:TVulkanBuffers;
      private
       fInFlightFrameCascadedShadowMaps:TInFlightFrameCascadedShadowMaps;
       fCascadedShadowMapUniformBuffers:TCascadedShadowMapUniformBuffers;
       fCascadedShadowMapVulkanUniformBuffers:TCascadedShadowMapVulkanUniformBuffers;
       fCloudsShadowMapVulkanBuffers:TCloudsShadowMapVulkanBuffers;
      private
       fCountLockOrderIndependentTransparencyLayers:TpvInt32;
       fLockOrderIndependentTransparentUniformBuffer:TLockOrderIndependentTransparentUniformBuffer;
       fLockOrderIndependentTransparentUniformVulkanBuffers:TpvVulkanInFlightFrameBuffers;
       fLockOrderIndependentTransparencyABufferBuffers:TOrderIndependentTransparencyBuffers;
       fLockOrderIndependentTransparencyAuxImages:TOrderIndependentTransparencyImages;
       fLockOrderIndependentTransparencySpinLockImages:TOrderIndependentTransparencyImages;
      private
       fCountLoopOrderIndependentTransparencyLayers:TpvInt32;
       fLoopOrderIndependentTransparentUniformBuffer:TLoopOrderIndependentTransparentUniformBuffer;
       fLoopOrderIndependentTransparentUniformVulkanBuffers:TpvVulkanInFlightFrameBuffers;
       fLoopOrderIndependentTransparencyABufferBuffers:TOrderIndependentTransparencyBuffers;
       fLoopOrderIndependentTransparencyZBufferBuffers:TOrderIndependentTransparencyBuffers;
       fLoopOrderIndependentTransparencySBufferBuffers:TOrderIndependentTransparencyBuffers;
      private
       fApproximationOrderIndependentTransparentUniformBuffer:TApproximationOrderIndependentTransparentUniformBuffer;
       fApproximationOrderIndependentTransparentUniformVulkanBuffers:TpvVulkanInFlightFrameBuffers;
      private
       fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImages:TOrderIndependentTransparencyImages;
       fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImages:TOrderIndependentTransparencyImages;
       fDeepAndFastApproximateOrderIndependentTransparencyAverageImages:TOrderIndependentTransparencyImages;
       fDeepAndFastApproximateOrderIndependentTransparencyBucketImages:TOrderIndependentTransparencyImages;
       fDeepAndFastApproximateOrderIndependentTransparencySpinLockImages:TOrderIndependentTransparencyImages;
      private
       fCascadedShadowMapCullDepthArray2DImage:TpvScene3DRendererArray2DImage;
       fCascadedShadowMapCullDepthPyramidMipmappedArray2DImages:TMipmappedArray2DImages;
       fCullDepthArray2DImage:TpvScene3DRendererArray2DImage;
       fCullDepthPyramidMipmappedArray2DImages:TMipmappedArray2DImages;
//     fAmbientOcclusionDepthMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage;
       fCombinedDepthArray2DImages:TArray2DImages;
       fDepthMipmappedArray2DImages:TMipmappedArray2DImages;
       fSceneMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage;
       fFullResSceneMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage;
       fHUDMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage;
      private
       fLuminanceHistogramVulkanBuffers:TLuminanceVulkanBuffers;
       fLuminanceVulkanBuffers:TLuminanceVulkanBuffers;
      private
       fMinimumLuminance:TpvScalar;
       fMaximumLuminance:TpvScalar;
       fLuminanceFactor:TpvScalar;
       fLuminanceExponent:TpvScalar;
      public
       fLuminancePushConstants:TLuminancePushConstants;
       fLuminanceEvents:array[0..MaxInFlightFrames-1] of TpvVulkanEvent;
       fLuminanceEventReady:array[0..MaxInFlightFrames-1] of boolean;
      private
       fLensFactor:TpvScalar;
       fBloomFactor:TpvScalar;
       fLensflareFactor:TpvScalar;
       fLensNormalization:boolean;
      private
       fTAAHistoryColorImages:TArray2DImages;
       fTAAHistoryDepthImages:TArray2DImages;
       fTAAHistoryVelocityImages:TArray2DImages;
      public
       fTAAEvents:array[0..MaxInFlightFrames-1] of TpvVulkanEvent;
       fTAAEventReady:array[0..MaxInFlightFrames-1] of boolean;
      private
       fImageBasedLightingReflectionProbeCubeMaps:TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps;
      private
       fPasses:TObject;
      private
       fLastOutputResource:TpvFrameGraph.TPass.TUsedImageResource;
      private
       fCascadedShadowMapBuilder:TCascadedShadowMapBuilder;
      private
       fHUDSize:TpvFrameGraph.TImageSize;
       fHUDCustomPassClass:THUDCustomPassClass;
       fHUDCustomPassParent:TObject;
       fHUDComputePassClass:THUDComputePassClass;
       fHUDComputePassParent:TObject;
       fHUDRenderPassClass:THUDRenderPassClass;
       fHUDRenderPassParent:TObject;
      private
       fSizeFactor:TpvDouble;
       fPostProcessingAtScaledResolution:Boolean;
      private
       fVulkanViews:array[0..MaxInFlightFrames-1] of TpvScene3D.TViewUniformBuffer;
       fVulkanViewUniformBuffers:TpvScene3D.TVulkanViewUniformBuffers;
      private
       fMeshCullPass0ComputeVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fMeshCullPass0ComputeVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fMeshCullPass0ComputeVulkanDescriptorSets:TPerInFlightFrameVulkanDescriptorSets;
       fMeshFilterComputeVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fMeshFilterComputeVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fMeshFilterComputeVulkanDescriptorSets:TPerInFlightFrameVulkanDescriptorSets;
       fMeshCullPass1ComputeVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fMeshCullPass1ComputeVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fMeshCullPass1ComputeVulkanDescriptorSets:TPerInFlightFrameVulkanDescriptorSets;
       fMeshCullPassDescriptorGeneration:TpvUInt64;
       fMeshCullPassDescriptorGenerations:array[0..MaxInFlightFrames-1] of TpvUInt64;
       fMeshCullReset:TpvScene3DRendererMeshCullReset;
       fViewBuffersDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fViewBuffersDescriptorPool:TpvVulkanDescriptorPool;
       fViewBuffersDescriptorSets:TPerInFlightFrameVulkanDescriptorSets;
      private
       fDebugTAAMode:TpvUInt32;
      private
       fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues;
       fMeshShaderOutputBufferSizes:TpvVulkanInFlightFrameSizeInts; // Grow-only output buffer size for mesh shader path
       fGPUDrawIndexedIndirectCommandOutputBufferSizes:TpvVulkanInFlightFrameSizeInts; // Grow-only output buffer capacity tracking
       fPerInFlightFrameGPUDrawIndexedIndirectCommandDisocclusionOffsets:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandOITPromotionOffsets:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandOITDisocclusionOffsets:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues;
       fUseSeparateCommandBufferSlots:Boolean;
       fPassGroupCounterSlotBase:array[TpvScene3DRendererCullRenderPass] of TpvSizeInt;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandCSMOffsets:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandCSMDisocclusionOffsets:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandFilterOffsets:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers;
       fSelectionListDrawIndexedIndirectCommandBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers;      // object-selection outline: selected-only indirect draw list (built by SelectionListComputePass)
       fSelectionListDrawIndexedIndirectCommandCountBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers; // ... and its count (1x uint, cleared each frame, drawn via vkCmdDrawIndexedIndirectCount)
       fGPUDrawIndexedIndirectCommandOutputBuffers:TpvVulkanInFlightFrameBuffers;
       fGPUDrawIndexedIndirectCommandCounterBuffers:TpvVulkanInFlightFrameBuffers;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBufferPartSizes:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBufferPartSizes;
       fPerInFlightFrameGPUCountMeshObjectIDsArray:TpvScene3D.TPerInFlightFrameGPUCountMeshObjectIDsArray;
       fMeshCullScratchBuffers:TpvVulkanInFlightFrameBuffers;
       fPerInFlightFrameExpandRangeInfoBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers;
       fMeshCullMaxScratchEntries:TpvVulkanInFlightFrameSizeInts;
       fPerInFlightFrameMeshletVisibilityBuffers:TpvScene3D.TPerInFlightFrameMeshletVisibilityBuffersPerCullRenderPass;
       fPerInFlightFrameMeshletVisibilityBufferPartSizes:TpvScene3D.TPerInFlightFrameMeshletVisibilityBufferPartSizesPerCullRenderPass;
      private
       fKeepPass0ForRendering:Boolean;
       fKeepPass0InPass1:Boolean;
       fSelectionOutlineThickness:TpvFloat;
       fDebugDDGIProbes:Boolean;
       fDebugDrawMeshletBoundingSpheres:Boolean;
       fDebugMeshletSphereLineBuffers:TpvVulkanInFlightFrameBuffers;
       fDebugMeshletSphereComputeShaderModule:TpvVulkanShaderModule;
       fDebugMeshletSphereComputePipelineLayout:TpvVulkanPipelineLayout;
       fDebugMeshletSphereComputePipeline:TpvVulkanComputePipeline;
       fDebugMeshletSphereVertexShaderModule:TpvVulkanShaderModule;
       fDebugMeshletSphereFragmentShaderModule:TpvVulkanShaderModule;
       fDrawChoreographyBatchRangeFrameBuckets:TpvScene3D.TDrawChoreographyBatchRangeFrameBuckets;
       fDrawChoreographyBatchRangeFrameRenderPassBuckets:TpvScene3D.TDrawChoreographyBatchRangeFrameRenderPassBuckets;
       fPerInFlightFrameMeshCullBatchRangeBuffers:TpvVulkanInFlightFrameBuffers;
       fPerInFlightFrameMeshCullPrefixSumBuffers:TpvVulkanInFlightFrameBuffers;
       fMeshCullIndirectDispatchBuffers:TpvVulkanInFlightFrameBuffers;
       fPerInFlightFrameMeshCullBatchRangeCounts:TMeshCullUInt32PerCullRenderPassArray;
       fPerInFlightFrameMeshCullTotalCommands:TMeshCullUInt32PerCullRenderPassArray;
       fPerInFlightFrameMeshCullBatchRangeOffsets:TMeshCullUInt32PerCullRenderPassArray;
       fPerInFlightFrameMeshCullPrefixSumOffsets:TMeshCullUInt32PerCullRenderPassArray;
      public
       fLODLevelBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers;
      private
       fColorGradingSettings:TpvScene3DRendererInstanceColorGradingSettings;
       fPointerToColorGradingSettings:PpvScene3DRendererInstanceColorGradingSettings;
       fPerInFlightFrameColorGradingSettings:TpvScene3DRendererInstanceColorGradingSettingsArray;
       fPointerToPerInFlightFrameColorGradingSettings:PpvScene3DRendererInstanceColorGradingSettingsArray;
       fColorGradingSettingUniformBuffers:TColorGradingSettingUniformBuffers;
      private
       fSolidPrimitivePrimitiveDynamicArrays:TSolidPrimitivePrimitiveDynamicArrays;
       fSolidPrimitivePrimitiveBuffers:TSolidPrimitiveVulkanBuffers;
       fSolidPrimitiveIndirectDrawCommandBuffers:TpvVulkanInFlightFrameBuffers;
       fSolidPrimitiveVertexBuffers:TpvVulkanInFlightFrameBuffers;
       fSolidPrimitiveIndexBuffers:TpvVulkanInFlightFrameBuffers;
      private
       fSpaceLinesPrimitiveDynamicArrays:TSpaceLinesPrimitiveDynamicArrays;
       fSpaceLinesPrimitiveBuffers:TSpaceLinesVulkanBuffers;
       fSpaceLinesIndirectDrawCommandBuffers:TpvVulkanInFlightFrameBuffers;
       fSpaceLinesVertexBuffers:TpvVulkanInFlightFrameBuffers;
       fSpaceLinesIndexBuffers:TpvVulkanInFlightFrameBuffers;
      private
       fLensRainPostEffectActive:Boolean;
       fLensRainPostEffectFactor:TpvFloat;
       fLensRainPostEffectTime:TpvDouble;
      private
       fGPUBatchRanges:TpvScene3D.TGPUBatchRanges;
       fExpandRangeInfos:TpvScene3D.TGPUExpandRangeInfos;
       fPrefixSums:TpvUInt32DynamicArray;
      private
       function GetPixelAmountFactor:TpvDouble;
       procedure SetPixelAmountFactor(const aPixelAmountFactor:TpvDouble);
       procedure SetRaytracingFlags(const aRaytracingFlags:TRaytracingFlags);
      private
       procedure CalculateSceneBounds(const aInFlightFrameIndex:TpvInt32);
       procedure CalculateCascadedShadowMaps(const aInFlightFrameIndex:TpvInt32);
       procedure UpdateGlobalIlluminationCascadedRadianceHints(const aInFlightFrameIndex:TpvInt32);
       procedure UploadGlobalIlluminationCascadedRadianceHints(const aInFlightFrameIndex:TpvInt32);
       procedure UpdateGlobalIlluminationDDGI(const aInFlightFrameIndex:TpvInt32);
       procedure UploadGlobalIlluminationDDGI(const aInFlightFrameIndex:TpvInt32);
       procedure UpdateGlobalIlluminationCascadedVoxelConeTracing(const aInFlightFrameIndex:TpvInt32);
       procedure UploadGlobalIlluminationCascadedVoxelConeTracing(const aInFlightFrameIndex:TpvInt32);
       procedure AddCameraReflectionProbeViews(const aInFlightFrameIndex:TpvInt32);
       procedure AddTopDownSkyOcclusionMapView(const aInFlightFrameIndex:TpvInt32);
       procedure AddReflectiveShadowMapView(const aInFlightFrameIndex:TpvInt32);
       procedure AddCloudsShadowMapView(const aInFlightFrameIndex:TpvInt32);
      private
       function GetCameraPreset(const aInFlightFrameIndex:TpvInt32):TpvScene3DRendererCameraPreset; inline;
      private
       function GetCameraViewMatrix(const aInFlightFrameIndex:TpvInt32):TpvMatrix4x4D; inline;
       procedure SetCameraViewMatrix(const aInFlightFrameIndex:TpvInt32;const aCameraViewMatrix:TpvMatrix4x4D); inline;
      private
       procedure PrepareDrawRenderInstanceFillTasksParallelForJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
      public
       constructor Create(const aParent:TpvScene3DRendererBaseObject;const aVirtualReality:TpvVirtualReality=nil;const aExternalImageFormat:TVkFormat=VK_FORMAT_UNDEFINED); reintroduce;
       destructor Destroy; override;
       procedure AfterConstruction; override;
       procedure BeforeDestruction; override;
       procedure CheckSolidPrimitives(const aInFlightFrameIndex:TpvInt32);
       procedure CheckSpaceLines(const aInFlightFrameIndex:TpvInt32);
       procedure Prepare;
       procedure AcquirePersistentResources;
       procedure ReleasePersistentResources;
       procedure AcquireVolatileResources;
       procedure ReleaseVolatileResources;
       procedure ClearSpaceLines(const aInFlightFrameIndex:TpvSizeInt);
       function AddSpaceLine(const aInFlightFrameIndex:TpvSizeInt;const aStartPosition,aEndPosition:TpvVector3;const aColor:TpvVector4;const aSize:TpvScalar;const aZMin:TpvScalar=0.0;const aZMax:TpvScalar=Infinity):Boolean;
       procedure ClearSolid(const aInFlightFrameIndex:TpvSizeInt);
       function AddSolidPoint2D(const aInFlightFrameIndex:TpvSizeInt;const aPosition:TpvVector2;const aColor:TpvVector4;const aSize:TpvScalar;const aPositionOffset:TpvVector2;const aLineWidth:TpvScalar):Boolean;
       function AddSolidLine2D(const aInFlightFrameIndex:TpvSizeInt;const aStartPosition,aEndPosition:TpvVector2;const aColor:TpvVector4;const aSize:TpvScalar;const aStartPositionOffset,aEndPositionOffset:TpvVector2):Boolean;
       function AddSolidTriangle2D(const aInFlightFrameIndex:TpvSizeInt;const aPosition0,aPosition1,aPosition2:TpvVector2;const aColor:TpvVector4;const aPosition0Offset,aPosition1Offset,aPosition2Offset:TpvVector2;const aLineWidth:TpvScalar=0.0):Boolean;
       function AddSolidQuad2D(const aInFlightFrameIndex:TpvSizeInt;const aPosition0,aPosition1,aPosition2,aPosition3:TpvVector2;const aColor:TpvVector4;const aPosition0Offset,aPosition1Offset,aPosition2Offset,aPosition3Offset:TpvVector2;const aLineWidth:TpvScalar=0.0):Boolean;
       function AddSolidPoint3D(const aInFlightFrameIndex:TpvSizeInt;const aPosition:TpvVector3;const aColor:TpvVector4;const aSize:TpvScalar;const aPositionOffset:TpvVector2;const aLineWidth:TpvScalar):Boolean;
       function AddSolidLine3D(const aInFlightFrameIndex:TpvSizeInt;const aStartPosition,aEndPosition:TpvVector3;const aColor:TpvVector4;const aSize:TpvScalar;const aStartPositionOffset,aEndPositionOffset:TpvVector2):Boolean;
       function AddSolidTriangle3D(const aInFlightFrameIndex:TpvSizeInt;const aPosition0,aPosition1,aPosition2:TpvVector3;const aColor:TpvVector4;const aPosition0Offset,aPosition1Offset,aPosition2Offset:TpvVector2;const aLineWidth:TpvScalar=0.0):Boolean;
       function AddSolidQuad3D(const aInFlightFrameIndex:TpvSizeInt;const aPosition0,aPosition1,aPosition2,aPosition3:TpvVector3;const aColor:TpvVector4;const aPosition0Offset,aPosition1Offset,aPosition2Offset,aPosition3Offset:TpvVector2;const aLineWidth:TpvScalar=0.0):Boolean;
       procedure Update(const aInFlightFrameIndex:TpvInt32;const aFrameCounter:TpvInt64);
       procedure ResetFrame(const aInFlightFrameIndex:TpvInt32);
       function AddView(const aInFlightFrameIndex:TpvInt32;const aView:TpvScene3D.TView):TpvInt32;
       function AddViews(const aInFlightFrameIndex:TpvInt32;const aViews:array of TpvScene3D.TView):TpvInt32;
       function GetJitterOffset(const aFrameCounter:TpvInt64):TpvVector2;
       function AddTemporalAntialiasingJitter(const aProjectionMatrix:TpvMatrix4x4;const aFrameCounter:TpvInt64):TpvMatrix4x4;
       function NeedsDrawDataRebuild(const aInFlightFrameIndex:TpvSizeInt):boolean;
       procedure PrepareDraw(const aInFlightFrameIndex:TpvSizeInt;
                             const aRenderPass:TpvScene3DRendererRenderPass);
       procedure ExecuteDraw(const aPreviousInFlightFrameIndex:TpvSizeInt;
                             const aInFlightFrameIndex:TpvSizeInt;
                             const aRenderPass:TpvScene3DRendererRenderPass;
                             const aViewBaseIndex:TpvSizeInt;
                             const aCountViews:TpvSizeInt;
                             const aFrameIndex:TpvSizeInt;
                             const aMaterialAlphaModes:TpvScene3D.TMaterial.TAlphaModes;
                             const aGraphicsPipelines:TpvScene3D.TGraphicsPipelines;
                             const aCommandBuffer:TpvVulkanCommandBuffer;
                             const aPipelineLayout:TpvVulkanPipelineLayout;
                             const aOnSetRenderPassResources:TpvScene3D.TOnSetRenderPassResources;
                             const aJitter:PpvVector4;
                             const aDisocclusions:boolean;
                             const aOITPromotion:boolean=false;
                             const aMeshShaderGraphicsPipelines:TpvScene3D.PGraphicsPipelines=nil);
       procedure PrepareFrame(const aInFlightFrameIndex:TpvInt32;const aFrameCounter:TpvInt64);
       procedure UploadFrame(const aInFlightFrameIndex:TpvInt32);
       procedure ProcessAtmospheresForFrame(const aInFlightFrameIndex:TpvInt32;const aCommandBuffer:TpvVulkanCommandBuffer);
       procedure DrawFrame(const aSwapChainImageIndex,aInFlightFrameIndex:TpvInt32;const aFrameCounter:TpvInt64;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
       procedure DispatchDebugMeshletSpheres(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex:TpvSizeInt);
       // Debug: read back the cascaded voxel-cone-tracing content data + meta-data buffers (GPU) and write a human-readable dump
       // (header + decoded non-empty cells, FP16 and RGB9E5 interpretations, plus raw hex) for offline investigation.
       procedure DumpVoxelConeTracingContent(const aInFlightFrameIndex:TpvSizeInt;const aFileName:TpvUTF8String);
      public
       procedure InitializeSolidPrimitiveGraphicsPipeline(const aPipeline:TpvVulkanGraphicsPipeline);
       procedure DrawSolidPrimitives(const aRendererInstance:TObject;
                                     const aGraphicsPipeline:TpvVulkanGraphicsPipeline;
                                     const aPreviousInFlightFrameIndex:TpvSizeInt;
                                     const aInFlightFrameIndex:TpvSizeInt;
                                     const aRenderPass:TpvScene3DRendererRenderPass;
                                     const aViewBaseIndex:TpvSizeInt;
                                     const aCountViews:TpvSizeInt;
                                     const aFrameIndex:TpvSizeInt;
                                     const aCommandBuffer:TpvVulkanCommandBuffer;
                                     const aPipelineLayout:TpvVulkanPipelineLayout;
                                     const aOnSetRenderPassResources:TpvScene3D.TOnSetRenderPassResources);
      public
       procedure InitializeSpaceLinesGraphicsPipeline(const aPipeline:TpvVulkanGraphicsPipeline);
       procedure DrawSpaceLines(const aRendererInstance:TObject;
                                const aGraphicsPipeline:TpvVulkanGraphicsPipeline;
                                const aPreviousInFlightFrameIndex:TpvSizeInt;
                                const aInFlightFrameIndex:TpvSizeInt;
                                const aRenderPass:TpvScene3DRendererRenderPass;
                                const aViewBaseIndex:TpvSizeInt;
                                const aCountViews:TpvSizeInt;
                                const aFrameIndex:TpvSizeInt;
                                const aCommandBuffer:TpvVulkanCommandBuffer;
                                const aPipelineLayout:TpvVulkanPipelineLayout;
                                const aOnSetRenderPassResources:TpvScene3D.TOnSetRenderPassResources);
      public
       property VulkanViewUniformBuffers:TpvScene3D.TVulkanViewUniformBuffers read fVulkanViewUniformBuffers;
      public
       property MeshStagePushConstants:TpvScene3D.TMeshStagePushConstantArray read fMeshStagePushConstants write fMeshStagePushConstants;
       property DrawChoreographyBatchItemFrameBuckets:TpvScene3D.TDrawChoreographyBatchItemFrameBuckets read fDrawChoreographyBatchItemFrameBuckets write fDrawChoreographyBatchItemFrameBuckets;
      public
       property CameraViewMatrices[const aInFlightFrameIndex:TpvInt32]:TpvMatrix4x4D read GetCameraViewMatrix write SetCameraViewMatrix;
       property InFlightFrameStates:PInFlightFrameStates read fPointerToInFlightFrameStates;
       property Views:TpvScene3DRendererInstance.TViews read fViews;
       property MeshFragmentSpecializationConstants:TMeshFragmentSpecializationConstants read fMeshFragmentSpecializationConstants;
      public
       property CameraPresets[const aInFlightFrameIndex:TpvInt32]:TpvScene3DRendererCameraPreset read GetCameraPreset;
      published
       property CameraPreset:TpvScene3DRendererCameraPreset read fCameraPreset;
      public
       property ParticleBVH:TpvScene3DRendererParticleBVH read fParticleBVH;
      public
       property InFlightFrameMustRenderGIMaps:TInFlightFrameMustRenderGIMaps read fInFlightFrameMustRenderGIMaps;
      public
       property InFlightFrameCascadedRadianceHintVolumeImages:TInFlightFrameCascadedRadianceHintVolumeImages read fInFlightFrameCascadedRadianceHintVolumeImages;
       property InFlightFrameCascadedRadianceHintSecondBounceVolumeImages:TInFlightFrameCascadedRadianceHintVolumeImages read fInFlightFrameCascadedRadianceHintVolumeSecondBounceImages;
       property GlobalIlluminationRadianceHintsUniformBufferDataArray:TGlobalIlluminationRadianceHintsUniformBufferDataArray read fGlobalIlluminationRadianceHintsUniformBufferDataArray;
       property GlobalIlluminationRadianceHintsUniformBuffers:TGlobalIlluminationRadianceHintsUniformBuffers read fGlobalIlluminationRadianceHintsUniformBuffers;
       property GlobalIlluminationDDGIIrradianceSHBuffers:TGlobalIlluminationDDGIBuffers read fGlobalIlluminationDDGIIrradianceSHBuffers;
       property GlobalIlluminationDDGIIrradianceOctImages:TGlobalIlluminationDDGIImage2Ds read fGlobalIlluminationDDGIIrradianceOctImages;
       property GlobalIlluminationDDGIVisibilityMomentsImages:TGlobalIlluminationDDGIImage2Ds read fGlobalIlluminationDDGIVisibilityMomentsImages;
       property GlobalIlluminationDDGIVisibilitySkyImages:TGlobalIlluminationDDGIImage2Ds read fGlobalIlluminationDDGIVisibilitySkyImages;
       property GlobalIlluminationDDGIGlossyImages:TGlobalIlluminationDDGIImage2Ds read fGlobalIlluminationDDGIGlossyImages;
       property GlobalIlluminationDDGIRayDataBuffers:TGlobalIlluminationDDGIBuffers read fGlobalIlluminationDDGIRayDataBuffers;
       property GlobalIlluminationDDGIMasterBuffers:TGlobalIlluminationDDGIBuffers read fGlobalIlluminationDDGIMasterBuffers;
       property GlobalIlluminationDDGIProbeDataBuffers:TGlobalIlluminationDDGIBuffers read fGlobalIlluminationDDGIProbeDataBuffers;
       property GlobalIlluminationDDGIAgeBuffers:TGlobalIlluminationDDGIBuffers read fGlobalIlluminationDDGIAgeBuffers;
       property GlobalIlluminationDDGIDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fGlobalIlluminationDDGIDescriptorSetLayout;
       property GlobalIlluminationDDGIDescriptorSets:TGlobalIlluminationDDGIDescriptorSets read fGlobalIlluminationDDGIDescriptorSets;
       function GetGlobalIlluminationDDGIFirstFrame(const aInFlightFrameIndex:TpvSizeInt):boolean;
       procedure SetGlobalIlluminationDDGIFirstFrame(const aInFlightFrameIndex:TpvSizeInt;const aValue:boolean);
       // Shared first-frame state between the DDGI trace + probe-update passes (the update flips it false after writing).
       property GlobalIlluminationDDGIFirstFrames[const aInFlightFrameIndex:TpvSizeInt]:boolean read GetGlobalIlluminationDDGIFirstFrame write SetGlobalIlluminationDDGIFirstFrame;
       property GlobalIlluminationSurfelUniformBuffers:TGlobalIlluminationSurfelUniformBuffers read fGlobalIlluminationSurfelUniformBuffers;
       property GlobalIlluminationSurfelPoolBuffer:TpvVulkanBuffer read fGlobalIlluminationSurfelPoolBuffer;
       property GlobalIlluminationSurfelGridCellBuffer:TpvVulkanBuffer read fGlobalIlluminationSurfelGridCellBuffer;
       property GlobalIlluminationSurfelGridCellCountBuffer:TpvVulkanBuffer read fGlobalIlluminationSurfelGridCellCountBuffer;
       property GlobalIlluminationSurfelStatsBuffer:TpvVulkanBuffer read fGlobalIlluminationSurfelStatsBuffer;
       property GlobalIlluminationSurfelFreeListBuffer:TpvVulkanBuffer read fGlobalIlluminationSurfelFreeListBuffer;
       property GlobalIlluminationSurfelDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fGlobalIlluminationSurfelDescriptorSetLayout;
       property GlobalIlluminationSurfelDescriptorSets:TGlobalIlluminationSurfelDescriptorSets read fGlobalIlluminationSurfelDescriptorSets;
       property GlobalIlluminationRadianceHintsRSMUniformBufferDataArray:TGlobalIlluminationRadianceHintsRSMUniformBufferDataArray read fGlobalIlluminationRadianceHintsRSMUniformBufferDataArray;
       property GlobalIlluminationRadianceHintsRSMUniformBuffers:TGlobalIlluminationRadianceHintsRSMUniformBuffers read fGlobalIlluminationRadianceHintsRSMUniformBuffers;
       property GlobalIlluminationRadianceHintsDescriptorPool:TpvVulkanDescriptorPool read fGlobalIlluminationRadianceHintsDescriptorPool;
       property GlobalIlluminationRadianceHintsDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fGlobalIlluminationRadianceHintsDescriptorSetLayout;
       property GlobalIlluminationRadianceHintsDescriptorSets:TGlobalIlluminationRadianceHintsDescriptorSets read fGlobalIlluminationRadianceHintsDescriptorSets;
      public
       property GlobalIlluminationCascadedVoxelConeTracingCascadedVolumes:TCascadedVolumes read fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes;
       property GlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray:TGlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray read fGlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray;
       property GlobalIlluminationCascadedVoxelConeTracingUniformBuffers:TGlobalIlluminationCascadedVoxelConeTracingBuffers read fGlobalIlluminationCascadedVoxelConeTracingUniformBuffers;
       property GlobalIlluminationCascadedVoxelConeTracingContentDataBuffers:TpvVulkanInFlightFrameBuffers read fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffers;
       property GlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers:TpvVulkanInFlightFrameBuffers read fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers;
       property GlobalIlluminationCascadedVoxelConeTracingOcclusionImages:TGlobalIlluminationCascadedVoxelConeTracingImages read fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages;
       property GlobalIlluminationCascadedVoxelConeTracingRadianceImages:TGlobalIlluminationCascadedVoxelConeTracingSideImages read fGlobalIlluminationCascadedVoxelConeTracingRadianceImages;
       property GlobalIlluminationCascadedVoxelConeTracingVisualizationImages:TGlobalIlluminationCascadedVoxelConeTracingSideImages read fGlobalIlluminationCascadedVoxelConeTracingVisualizationImages;
       property GlobalIlluminationCascadedVoxelConeTracingMaxGlobalFragmentCount:TpvUInt32 read fGlobalIlluminationCascadedVoxelConeTracingMaxGlobalFragmentCount write fGlobalIlluminationCascadedVoxelConeTracingMaxGlobalFragmentCount;
       property GlobalIlluminationCascadedVoxelConeTracingMaxLocalFragmentCount:TpvUInt32 read fGlobalIlluminationCascadedVoxelConeTracingMaxLocalFragmentCount write fGlobalIlluminationCascadedVoxelConeTracingMaxLocalFragmentCount;
       property GlobalIlluminationCascadedVoxelConeTracingDescriptorPool:TpvVulkanDescriptorPool read fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool;
       property GlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout;
       property GlobalIlluminationCascadedVoxelConeTracingDescriptorSets:TGlobalIlluminationCascadedVoxelConeTracingDescriptorSets read fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets;
       property GlobalIlluminationCascadedVoxelConeTracingDebugVisualization:LongBool read fGlobalIlluminationCascadedVoxelConeTracingDebugVisualization write fGlobalIlluminationCascadedVoxelConeTracingDebugVisualization;
       property DrawMeshletDebugColors:boolean read fDrawMeshletDebugColors write fDrawMeshletDebugColors;
      public
       property NearestFarthestDepthVulkanBuffers:TVulkanBuffers read fNearestFarthestDepthVulkanBuffers;
       property DepthOfFieldAutoFocusVulkanBuffers:TVulkanBuffers read fDepthOfFieldAutoFocusVulkanBuffers;
       property DepthOfFieldBokenShapeTapVulkanBuffers:TVulkanBuffers read fDepthOfFieldBokenShapeTapVulkanBuffers;
      public
       property FrustumClusterGridSizeX:TpvInt32 read fFrustumClusterGridSizeX;
       property FrustumClusterGridSizeY:TpvInt32 read fFrustumClusterGridSizeY;
       property FrustumClusterGridSizeZ:TpvInt32 read fFrustumClusterGridSizeZ;
       property FrustumClusterGridTileSizeX:TpvInt32 read fFrustumClusterGridTileSizeX;
       property FrustumClusterGridTileSizeY:TpvInt32 read fFrustumClusterGridTileSizeY;
       property FrustumClusterGridCountTotalViews:TpvInt32 read fFrustumClusterGridCountTotalViews;
       property FrustumClusterGridPushConstants:TpvScene3DRendererInstance.TFrustumClusterGridPushConstants read fFrustumClusterGridPushConstants;
       property FrustumClusterGridGlobalsVulkanBuffers:TVulkanBuffers read fFrustumClusterGridGlobalsVulkanBuffers;
       property FrustumClusterGridAABBVulkanBuffers:TVulkanBuffers read fFrustumClusterGridAABBVulkanBuffers;
       property FrustumClusterGridIndexListCounterVulkanBuffers:TVulkanBuffers read fFrustumClusterGridIndexListCounterVulkanBuffers;
       property FrustumClusterGridIndexListVulkanBuffers:TVulkanBuffers read fFrustumClusterGridIndexListVulkanBuffers;
       property FrustumClusterGridDataVulkanBuffers:TVulkanBuffers read fFrustumClusterGridDataVulkanBuffers;
      public
       property CascadedShadowMapUniformBuffers:TCascadedShadowMapUniformBuffers read fCascadedShadowMapUniformBuffers;
       property CascadedShadowMapVulkanUniformBuffers:TCascadedShadowMapVulkanUniformBuffers read fCascadedShadowMapVulkanUniformBuffers;
      public
       property CountLockOrderIndependentTransparencyLayers:TpvInt32 read fCountLockOrderIndependentTransparencyLayers;
       property LockOrderIndependentTransparentUniformBuffer:TLockOrderIndependentTransparentUniformBuffer read fLockOrderIndependentTransparentUniformBuffer;
       property LockOrderIndependentTransparentUniformVulkanBuffers:TpvVulkanInFlightFrameBuffers read fLockOrderIndependentTransparentUniformVulkanBuffers;
       property LockOrderIndependentTransparencyABufferBuffers:TOrderIndependentTransparencyBuffers read fLockOrderIndependentTransparencyABufferBuffers;
       property LockOrderIndependentTransparencyAuxImages:TOrderIndependentTransparencyImages read fLockOrderIndependentTransparencyAuxImages;
       property LockOrderIndependentTransparencySpinLockImages:TOrderIndependentTransparencyImages read fLockOrderIndependentTransparencySpinLockImages;
      public
       property CountLoopOrderIndependentTransparencyLayers:TpvInt32 read fCountLoopOrderIndependentTransparencyLayers;
       property LoopOrderIndependentTransparentUniformBuffer:TLoopOrderIndependentTransparentUniformBuffer read fLoopOrderIndependentTransparentUniformBuffer;
       property LoopOrderIndependentTransparentUniformVulkanBuffers:TpvVulkanInFlightFrameBuffers read fLoopOrderIndependentTransparentUniformVulkanBuffers;
       property LoopOrderIndependentTransparencyABufferBuffers:TOrderIndependentTransparencyBuffers read fLoopOrderIndependentTransparencyABufferBuffers;
       property LoopOrderIndependentTransparencyZBufferBuffers:TOrderIndependentTransparencyBuffers read fLoopOrderIndependentTransparencyZBufferBuffers;
       property LoopOrderIndependentTransparencySBufferBuffers:TOrderIndependentTransparencyBuffers read fLoopOrderIndependentTransparencySBufferBuffers;
      public
       property ApproximationOrderIndependentTransparentUniformBuffer:TApproximationOrderIndependentTransparentUniformBuffer read fApproximationOrderIndependentTransparentUniformBuffer;
       property ApproximationOrderIndependentTransparentUniformVulkanBuffers:TpvVulkanInFlightFrameBuffers read fApproximationOrderIndependentTransparentUniformVulkanBuffers;
      public
       property DeepAndFastApproximateOrderIndependentTransparencyFragmentCounterFragmentDepthsSampleMaskImages:TOrderIndependentTransparencyImages read fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImages;
       property DeepAndFastApproximateOrderIndependentTransparencyAccumulationImages:TOrderIndependentTransparencyImages read fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImages;
       property DeepAndFastApproximateOrderIndependentTransparencyAverageImages:TOrderIndependentTransparencyImages read fDeepAndFastApproximateOrderIndependentTransparencyAverageImages;
       property DeepAndFastApproximateOrderIndependentTransparencyBucketImages:TOrderIndependentTransparencyImages read fDeepAndFastApproximateOrderIndependentTransparencyBucketImages;
       property DeepAndFastApproximateOrderIndependentTransparencySpinLockImages:TOrderIndependentTransparencyImages read fDeepAndFastApproximateOrderIndependentTransparencySpinLockImages;
      public
       property CascadedShadowMapCullDepthArray2DImage:TpvScene3DRendererArray2DImage read fCascadedShadowMapCullDepthArray2DImage;
       property CascadedShadowMapCullDepthPyramidMipmappedArray2DImages:TMipmappedArray2DImages read fCascadedShadowMapCullDepthPyramidMipmappedArray2DImages;
       property CullDepthArray2DImage:TpvScene3DRendererArray2DImage read fCullDepthArray2DImage;
       property CullDepthPyramidMipmappedArray2DImages:TMipmappedArray2DImages read fCullDepthPyramidMipmappedArray2DImages;
//     property AmbientOcclusionDepthMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage read fAmbientOcclusionDepthMipmappedArray2DImage;
       property CombinedDepthArray2DImages:TArray2DImages read fCombinedDepthArray2DImages;
       property DepthMipmappedArray2DImages:TMipmappedArray2DImages read fDepthMipmappedArray2DImages;
       property SceneMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage read fSceneMipmappedArray2DImage;
       property FullResSceneMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage read fFullResSceneMipmappedArray2DImage;
       property HUDMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage read fHUDMipmappedArray2DImage;
      public
       property LuminanceHistogramVulkanBuffers:TLuminanceVulkanBuffers read fLuminanceHistogramVulkanBuffers;
       property LuminanceVulkanBuffers:TLuminanceVulkanBuffers read fLuminanceVulkanBuffers;
       property MinimumLuminance:TpvScalar read fMinimumLuminance write fMinimumLuminance;
       property MaximumLuminance:TpvScalar read fMaximumLuminance write fMaximumLuminance;
       property LuminanceFactor:TpvScalar read fLuminanceFactor write fLuminanceFactor;
       property LuminanceExponent:TpvScalar read fLuminanceExponent write fLuminanceExponent;
      public
       property LensFactor:TpvScalar read fLensFactor write fLensFactor;
       property BloomFactor:TpvScalar read fBloomFactor write fBloomFactor;
       property LensflareFactor:TpvScalar read fLensflareFactor write fLensflareFactor;
       property LensNormalization:boolean read fLensNormalization write fLensNormalization;
      public
       property TAAHistoryColorImages:TArray2DImages read fTAAHistoryColorImages;
       property TAAHistoryDepthImages:TArray2DImages read fTAAHistoryDepthImages;
       property TAAHistoryVelocityImages:TArray2DImages read fTAAHistoryVelocityImages;
      public
       property LastOutputResource:TpvFrameGraph.TPass.TUsedImageResource read fLastOutputResource write fLastOutputResource;
       property HUDSize:TpvFrameGraph.TImageSize read fHUDSize;
       property HUDCustomPassClass:THUDCustomPassClass read fHUDCustomPassClass write fHUDCustomPassClass;
       property HUDCustomPassParent:TObject read fHUDCustomPassParent write fHUDCustomPassParent;
       property HUDComputePassClass:THUDComputePassClass read fHUDComputePassClass write fHUDComputePassClass;
       property HUDComputePassParent:TObject read fHUDComputePassParent write fHUDComputePassParent;
       property HUDRenderPassClass:THUDRenderPassClass read fHUDRenderPassClass write fHUDRenderPassClass;
       property HUDRenderPassParent:TObject read fHUDRenderPassParent write fHUDRenderPassParent;
      public
       property ImageBasedLightingReflectionProbeCubeMaps:TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps read fImageBasedLightingReflectionProbeCubeMaps;
      public
       property MeshCullPass0ComputeVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fMeshCullPass0ComputeVulkanDescriptorSetLayout;
       property MeshCullPass0ComputeVulkanDescriptorSets:TPerInFlightFrameVulkanDescriptorSets read fMeshCullPass0ComputeVulkanDescriptorSets;
       property MeshFilterComputeVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fMeshFilterComputeVulkanDescriptorSetLayout;
       property MeshFilterComputeVulkanDescriptorSets:TPerInFlightFrameVulkanDescriptorSets read fMeshFilterComputeVulkanDescriptorSets;
       property MeshCullPass1ComputeVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fMeshCullPass1ComputeVulkanDescriptorSetLayout;
       property MeshCullPass1ComputeVulkanDescriptorSets:TPerInFlightFrameVulkanDescriptorSets read fMeshCullPass1ComputeVulkanDescriptorSets;
       property MeshCullReset:TpvScene3DRendererMeshCullReset read fMeshCullReset;
       property PerInFlightFrameMeshCullBatchRangeCounts:TMeshCullUInt32PerCullRenderPassArray read fPerInFlightFrameMeshCullBatchRangeCounts;
       property PerInFlightFrameMeshCullTotalCommands:TMeshCullUInt32PerCullRenderPassArray read fPerInFlightFrameMeshCullTotalCommands;
       property PerInFlightFrameMeshCullBatchRangeOffsets:TMeshCullUInt32PerCullRenderPassArray read fPerInFlightFrameMeshCullBatchRangeOffsets;
       property GPUBatchRanges:TpvScene3D.TGPUBatchRanges read fGPUBatchRanges;
       property PerInFlightFrameMeshCullPrefixSumOffsets:TMeshCullUInt32PerCullRenderPassArray read fPerInFlightFrameMeshCullPrefixSumOffsets;
       property MeshCullIndirectDispatchBuffers:TpvVulkanInFlightFrameBuffers read fMeshCullIndirectDispatchBuffers;
       property LODLevelBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers read fLODLevelBuffers;
       property ViewBuffersDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fViewBuffersDescriptorSetLayout;
       property ViewBuffersDescriptorSets:TPerInFlightFrameVulkanDescriptorSets read fViewBuffersDescriptorSets;
      public
       property DebugTAAMode:TpvUInt32 read fDebugTAAMode write fDebugTAAMode;
       // Mesh-cull PASS1 "depth present, color missing" flicker controls (mesh_cull.comp,
       // FLAG_KEEP_PASS0_FOR_RENDERING / FLAG_KEEP_PASS0_IN_PASS1). KeepPass0ForRendering (Variante a)
       // is a cheap correctness net against 1-frame staleness races and defaults ON; KeepPass0InPass1
       // is DIAGNOSTIC ONLY (breaks occlusion culling) and defaults OFF.
       property KeepPass0ForRendering:Boolean read fKeepPass0ForRendering write fKeepPass0ForRendering;
       property KeepPass0InPass1:Boolean read fKeepPass0InPass1 write fKeepPass0InPass1;
       // Object-selection outline thickness in REFERENCE pixels (tuned at 1080p render height). The outline
       // build pass scales this by (renderHeight/1080) and clamps it, so the on-screen outline stays a constant
       // fraction of the screen across render resolutions and AI/EASU upscaling (the buffer is built at render
       // resolution and upscaled at compose time). Default 3.0. See SelectionOutlineBuildRenderPass.
       property SelectionOutlineThickness:TpvFloat read fSelectionOutlineThickness write fSelectionOutlineThickness;
       // Debug: draw every DDGI probe as an octahedral sphere coloured by its live-sampled directional irradiance (ForwardRenderPass).
       property DebugDDGIProbes:Boolean read fDebugDDGIProbes write fDebugDDGIProbes;
       property DebugDrawMeshletBoundingSpheres:Boolean read fDebugDrawMeshletBoundingSpheres write fDebugDrawMeshletBoundingSpheres;
       property DebugMeshletSphereLineBuffers:TpvVulkanInFlightFrameBuffers read fDebugMeshletSphereLineBuffers;
      public
       property SolidPrimitivePrimitiveDynamicArrays:TSolidPrimitivePrimitiveDynamicArrays read fSolidPrimitivePrimitiveDynamicArrays;
       property SolidPrimitivePrimitiveBuffers:TSolidPrimitiveVulkanBuffers read fSolidPrimitivePrimitiveBuffers;
       property SolidPrimitiveIndirectDrawCommandBuffers:TpvVulkanInFlightFrameBuffers read fSolidPrimitiveIndirectDrawCommandBuffers;
       property SolidPrimitiveVertexBuffers:TpvVulkanInFlightFrameBuffers read fSolidPrimitiveVertexBuffers;
       property SolidPrimitiveIndexBuffers:TpvVulkanInFlightFrameBuffers read fSolidPrimitiveIndexBuffers;
      public
       property SpaceLinesPrimitiveDynamicArrays:TSpaceLinesPrimitiveDynamicArrays read fSpaceLinesPrimitiveDynamicArrays;
       property SpaceLinesPrimitiveBuffers:TSpaceLinesVulkanBuffers read fSpaceLinesPrimitiveBuffers;
       property SpaceLinesIndirectDrawCommandBuffers:TpvVulkanInFlightFrameBuffers read fSpaceLinesIndirectDrawCommandBuffers;
       property SpaceLinesVertexBuffers:TpvVulkanInFlightFrameBuffers read fSpaceLinesVertexBuffers;
       property SpaceLinesIndexBuffers:TpvVulkanInFlightFrameBuffers read fSpaceLinesIndexBuffers;
      public
       property LensRainPostEffectActive:Boolean read fLensRainPostEffectActive write fLensRainPostEffectActive;
       property LensRainPostEffectFactor:TpvFloat read fLensRainPostEffectFactor write fLensRainPostEffectFactor;
       property LensRainPostEffectTime:TpvDouble read fLensRainPostEffectTime write fLensRainPostEffectTime;
      public
       property PerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays read fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays write fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays;
       property PerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues read fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes;
       property MeshShaderOutputBufferSizes:TpvVulkanInFlightFrameSizeInts read fMeshShaderOutputBufferSizes;
       property GPUDrawIndexedIndirectCommandOutputBufferSizes:TpvVulkanInFlightFrameSizeInts read fGPUDrawIndexedIndirectCommandOutputBufferSizes;
       property PerInFlightFrameGPUDrawIndexedIndirectCommandDisocclusionOffsets:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues read fPerInFlightFrameGPUDrawIndexedIndirectCommandDisocclusionOffsets;
       property PerInFlightFrameGPUDrawIndexedIndirectCommandCSMOffsets:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues read fPerInFlightFrameGPUDrawIndexedIndirectCommandCSMOffsets;
       property PerInFlightFrameGPUDrawIndexedIndirectCommandFilterOffsets:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues read fPerInFlightFrameGPUDrawIndexedIndirectCommandFilterOffsets;
       property PerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers read fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers;
       property SelectionListDrawIndexedIndirectCommandBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers read fSelectionListDrawIndexedIndirectCommandBuffers;
       property SelectionListDrawIndexedIndirectCommandCountBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers read fSelectionListDrawIndexedIndirectCommandCountBuffers;
       property GPUDrawIndexedIndirectCommandOutputBuffers:TpvVulkanInFlightFrameBuffers read fGPUDrawIndexedIndirectCommandOutputBuffers;
       property GPUDrawIndexedIndirectCommandCounterBuffers:TpvVulkanInFlightFrameBuffers read fGPUDrawIndexedIndirectCommandCounterBuffers;
       property PerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers read fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers;
       property PerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBufferPartSizes:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBufferPartSizes read fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBufferPartSizes;
       property PerInFlightFrameGPUCountMeshObjectIDsArray:TpvScene3D.TPerInFlightFrameGPUCountMeshObjectIDsArray read fPerInFlightFrameGPUCountMeshObjectIDsArray;
       property MeshCullScratchBuffers:TpvVulkanInFlightFrameBuffers read fMeshCullScratchBuffers;
       property PerInFlightFrameExpandRangeInfoBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers read fPerInFlightFrameExpandRangeInfoBuffers;
       property MeshCullMaxScratchEntries:TpvVulkanInFlightFrameSizeInts read fMeshCullMaxScratchEntries;
       property PerInFlightFrameMeshletVisibilityBuffers:TpvScene3D.TPerInFlightFrameMeshletVisibilityBuffersPerCullRenderPass read fPerInFlightFrameMeshletVisibilityBuffers;
       property PerInFlightFrameMeshletVisibilityBufferPartSizes:TpvScene3D.TPerInFlightFrameMeshletVisibilityBufferPartSizesPerCullRenderPass read fPerInFlightFrameMeshletVisibilityBufferPartSizes;
       property DrawChoreographyBatchRangeFrameBuckets:TpvScene3D.TDrawChoreographyBatchRangeFrameBuckets read fDrawChoreographyBatchRangeFrameBuckets write fDrawChoreographyBatchRangeFrameBuckets;
       property DrawChoreographyBatchRangeFrameRenderPassBuckets:TpvScene3D.TDrawChoreographyBatchRangeFrameRenderPassBuckets read fDrawChoreographyBatchRangeFrameRenderPassBuckets write fDrawChoreographyBatchRangeFrameRenderPassBuckets;
      public
       property ColorGradingSettings:PpvScene3DRendererInstanceColorGradingSettings read fPointerToColorGradingSettings;
       property PerInFlightFrameColorGradingSettings:PpvScene3DRendererInstanceColorGradingSettingsArray read fPointerToPerInFlightFrameColorGradingSettings;
       property ColorGradingSettingUniformBuffers:TColorGradingSettingUniformBuffers read fColorGradingSettingUniformBuffers;
      published
       property Scene3D:TpvScene3D read fScene3D;
       property RendererInstanceIndex:TpvSizeInt read fRendererInstanceIndex;
       property ID:TpvUInt32 read fID;
       property FrameGraph:TpvFrameGraph read fFrameGraph;
       property VirtualReality:TpvVirtualReality read fVirtualReality;
       property ExternalImageFormat:TVkFormat read fExternalImageFormat write fExternalImageFormat;
       property ExternalOutputImageData:TpvFrameGraph.TExternalImageData read fExternalOutputImageData;
       property HasExternalOutputImage:boolean read fHasExternalOutputImage;
       property ReflectionProbeWidth:TpvInt32 read fReflectionProbeWidth write fReflectionProbeWidth;
       property ReflectionProbeHeight:TpvInt32 read fReflectionProbeHeight write fReflectionProbeHeight;
       property TopDownSkyOcclusionMapWidth:TpvInt32 read fTopDownSkyOcclusionMapWidth write fTopDownSkyOcclusionMapWidth;
       property TopDownSkyOcclusionMapHeight:TpvInt32 read fTopDownSkyOcclusionMapHeight write fTopDownSkyOcclusionMapHeight;
       property ReflectiveShadowMapWidth:TpvInt32 read fReflectiveShadowMapWidth write fReflectiveShadowMapWidth;
       property ReflectiveShadowMapHeight:TpvInt32 read fReflectiveShadowMapHeight write fReflectiveShadowMapHeight;
       property CascadedShadowMapWidth:TpvInt32 read fCascadedShadowMapWidth write fCascadedShadowMapWidth;
       property CascadedShadowMapHeight:TpvInt32 read fCascadedShadowMapHeight write fCascadedShadowMapHeight;
      public
       property CascadedShadowMapCenter:TpvVector3D read fCascadedShadowMapCenter write fCascadedShadowMapCenter;
       property CascadedShadowMapRadius:TpvDouble read fCascadedShadowMapRadius write fCascadedShadowMapRadius;
       property ShadowMaximumDistance:TpvFloat read fShadowMaximumDistance write fShadowMaximumDistance;
       property ShadowAreaTooSmallThreshold:TpvFloat read fShadowAreaTooSmallThreshold write fShadowAreaTooSmallThreshold;
       property FinalViewMaximumDistance:TpvFloat read fFinalViewMaximumDistance write fFinalViewMaximumDistance;
       property FinalViewAreaTooSmallThreshold:TpvFloat read fFinalViewAreaTooSmallThreshold write fFinalViewAreaTooSmallThreshold;
      published
       property Left:TpvInt32 read fLeft write fLeft;
       property Top:TpvInt32 read fTop write fTop;
       property Width:TpvInt32 read fWidth write fWidth;
       property Height:TpvInt32 read fHeight write fHeight;
       property HUDWidth:TpvInt32 read fHUDWidth write fHUDWidth;
       property HUDHeight:TpvInt32 read fHUDHeight write fHUDHeight;
       property ScaledWidth:TpvInt32 read fScaledWidth;
       property ScaledHeight:TpvInt32 read fScaledHeight;
       property RawRaytracingFlags:TpvUInt32 read fRawRaytracingFlags;
       property RaytracingSoftShadowSampleCount:TpvUInt32 read fRaytracingSoftShadowSampleCount write fRaytracingSoftShadowSampleCount;
       property RaytracingFlags:TRaytracingFlags read fRaytracingFlags write SetRaytracingFlags;
       property CountSurfaceViews:TpvInt32 read fCountSurfaceViews write fCountSurfaceViews;
       property SurfaceMultiviewMask:TpvUInt32 read fSurfaceMultiviewMask write fSurfaceMultiviewMask;
       property ZNear:TpvFloat read fZNear write fZNear;
       property ZFar:TpvFloat read fZFar write fZFar;
       property PixelAmountFactor:TpvDouble read GetPixelAmountFactor write SetPixelAmountFactor;
       property SizeFactor:TpvDouble read fSizeFactor write fSizeFactor;
       property PostProcessingAtScaledResolution:Boolean read fPostProcessingAtScaledResolution write fPostProcessingAtScaledResolution;
       property UseDebugBlit:boolean read fUseDebugBlit write fUseDebugBlit;
      public
       property WaterSimulationSemaphores:TInFlightFrameSemaphores read fWaterSimulationSemaphores;
       property AtmospherePrecipitationSimulationSemaphores:TInFlightFrameSemaphores read fAtmospherePrecipitationSimulationSemaphores;
     end;

implementation

uses PasVulkan.Scene3D.Atmosphere,
    {PasVulkan.Scene3D.Renderer.Passes.DataTransferPass,
     PasVulkan.Scene3D.Renderer.Passes.MeshComputePass,
     PasVulkan.Scene3D.Renderer.Passes.RaytracingBuildUpdatePass,}
     PasVulkan.Scene3D.Renderer.Passes.AtmospherePrecipitationWaitCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.AtmosphereProcessCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.MeshFilterComputePass,
     PasVulkan.Scene3D.Renderer.Passes.MeshCullPass0ComputePass,
     PasVulkan.Scene3D.Renderer.Passes.SelectionListComputePass,
     PasVulkan.Scene3D.Renderer.Passes.SelectionMaskRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.SelectionOutlineBuildRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.SelectionOutlineFXAAComposeRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.CullDepthRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.CullDepthResolveComputePass,
     PasVulkan.Scene3D.Renderer.Passes.CullDepthPyramidComputePass,
     PasVulkan.Scene3D.Renderer.Passes.MeshCullPass1ComputePass,
     PasVulkan.Scene3D.Renderer.Passes.CascadedShadowMapRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.CascadedShadowMapResolveRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.CascadedShadowMapBlurRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.DepthPrepassRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.DepthMipMapComputePass,
     PasVulkan.Scene3D.Renderer.Passes.DepthOfFieldAutoFocusComputePass,
     PasVulkan.Scene3D.Renderer.Passes.FrustumClusterGridBuildComputePass,
     PasVulkan.Scene3D.Renderer.Passes.FrustumClusterGridAssignComputePass,
     PasVulkan.Scene3D.Renderer.Passes.TopDownSkyOcclusionMapRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.TopDownSkyOcclusionMapResolveRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.TopDownSkyOcclusionMapBlurRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.ReflectiveShadowMapRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.ParticleBVHComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedRadianceHintsClearCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedRadianceHintsInjectCachedComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedRadianceHintsInjectSkyComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedRadianceHintsInjectRSMComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedRadianceHintsInjectFinalizationCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedRadianceHintsBounceComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationDDGITraceComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationDDGIStageComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationSurfelComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedVoxelConeTracingOcclusionTransferComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedVoxelConeTracingRadianceTransferComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedVoxelConeTracingRadianceMipMapComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedVoxelConeTracingFinalizationCustomPass,
//   PasVulkan.Scene3D.Renderer.Passes.AmbientOcclusionDepthMipMapComputePass,
     PasVulkan.Scene3D.Renderer.Passes.AmbientOcclusionRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.AmbientOcclusionBlurRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.ReflectionProbeRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.ReflectionProbeMipMapComputePass,
     PasVulkan.Scene3D.Renderer.Passes.ReflectionProbeComputePass,
//   PasVulkan.Scene3D.Renderer.Passes.PlanetWaterPrepassComputePass,
     PasVulkan.Scene3D.Renderer.Passes.WetnessMapComputePass,
     PasVulkan.Scene3D.Renderer.Passes.ForwardComputePass,
     PasVulkan.Scene3D.Renderer.Passes.ForwardRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.AtmosphereCloudRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.AtmosphereCloudShadowRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.AtmosphereRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.RainRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.ForwardResolveRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.ForwardRenderMipMapComputePass,
     PasVulkan.Scene3D.Renderer.Passes.WaterWaitCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.WaterRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.PlanetWaterCausticsComputePass,
     PasVulkan.Scene3D.Renderer.Passes.DirectTransparencyRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.DirectTransparencyResolveRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.LockOrderIndependentTransparencyClearCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.LockOrderIndependentTransparencyRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.LockOrderIndependentTransparencyBarrierCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.LockOrderIndependentTransparencyResolveRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.LoopOrderIndependentTransparencyClearCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.LoopOrderIndependentTransparencyPass1RenderPass,
     PasVulkan.Scene3D.Renderer.Passes.LoopOrderIndependentTransparencyPass1BarrierCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.LoopOrderIndependentTransparencyPass2RenderPass,
     PasVulkan.Scene3D.Renderer.Passes.LoopOrderIndependentTransparencyPass2BarrierCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.LoopOrderIndependentTransparencyResolveRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.MomentBasedOrderIndependentTransparencyAbsorbanceRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.MomentBasedOrderIndependentTransparencyTransmittanceRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.MomentBasedOrderIndependentTransparencyResolveRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.WeightBlendedOrderIndependentTransparencyRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.WeightBlendedOrderIndependentTransparencyResolveRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.DeepAndFastApproximateOrderIndependentTransparencyClearCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.DeepAndFastApproximateOrderIndependentTransparencyRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.DeepAndFastApproximateOrderIndependentTransparencyResolveRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.OrderIndependentTransparencyResolveRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.LuminanceHistogramComputePass,
     PasVulkan.Scene3D.Renderer.Passes.LuminanceAverageComputePass,
     PasVulkan.Scene3D.Renderer.Passes.LuminanceAdaptationRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.AntialiasingNoneRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.AntialiasingDSAARenderPass,
     PasVulkan.Scene3D.Renderer.Passes.AntialiasingFXAARenderPass,
     PasVulkan.Scene3D.Renderer.Passes.AntialiasingSMAAT2xPreCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.AntialiasingSMAAT2xTemporalResolveRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.AntialiasingSMAAT2xPostCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.AntialiasingSMAAEdgesRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.AntialiasingSMAAWeightsRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.AntialiasingSMAABlendRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.AntialiasingTAAPreCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.AntialiasingTAARenderPass,
     PasVulkan.Scene3D.Renderer.Passes.AntialiasingTAAPostCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.DepthOfFieldPrepareRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.DepthOfFieldBokehComputePass,
     PasVulkan.Scene3D.Renderer.Passes.DepthOfFieldPrefilterRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.DepthOfFieldBlurRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.DepthOfFieldBruteforceRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.DepthOfFieldPostBlurRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.DepthOfFieldCombineRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.DepthOfFieldGatherPass1RenderPass,
     PasVulkan.Scene3D.Renderer.Passes.DepthOfFieldGatherPass2RenderPass,
     PasVulkan.Scene3D.Renderer.Passes.DepthOfFieldResolveRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.ResamplingRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.EASURCASComputePass,
     PasVulkan.Scene3D.Renderer.Passes.CNNUpscalerComputePass,
     PasVulkan.Scene3D.Renderer.Passes.LensDownsampleComputePass,
     PasVulkan.Scene3D.Renderer.Passes.LensUpsampleComputePass,
     PasVulkan.Scene3D.Renderer.Passes.LensResolveRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.LensRainRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.TonemappingRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.CanvasComputePass,
     PasVulkan.Scene3D.Renderer.Passes.CanvasRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.HUDMipMapCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.ContentProjectionRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.AtmospherePrecipitationReleaseCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.WaterReleaseCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.DebugBlitRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.FrameBufferBlitRenderPass;

type TpvScene3DRendererInstancePasses=class
      private
{      fDataTransferPass:TpvScene3DRendererPassesDataTransferPass;
       fMeshComputePass:TpvScene3DRendererPassesMeshComputePass;
       fRaytracingBuildUpdatePass:TpvScene3DRendererPassesRaytracingBuildUpdatePass;}
       fAtmospherePrecipitationWaitCustomPass:TpvScene3DRendererPassesAtmospherePrecipitationWaitCustomPass;
       fAtmosphereProcessCustomPass:TpvScene3DRendererPassesAtmosphereProcessCustomPass;
       fCascadedShadowMapMeshCullPass0ComputePass:TpvScene3DRendererPassesMeshCullPass0ComputePass;
       fCascadedShadowMapCullDepthRenderPass:TpvScene3DRendererPassesCullDepthRenderPass;
       fCascadedShadowMapCullDepthResolveComputePass:TpvScene3DRendererPassesCullDepthResolveComputePass;
       fCascadedShadowMapCullDepthPyramidComputePass:TpvScene3DRendererPassesCullDepthPyramidComputePass;
       fCascadedShadowMapMeshCullPass1ComputePass:TpvScene3DRendererPassesMeshCullPass1ComputePass;
       fCascadedShadowMapRenderPass:TpvScene3DRendererPassesCascadedShadowMapRenderPass;
       fCascadedShadowMapResolveRenderPass:TpvScene3DRendererPassesCascadedShadowMapResolveRenderPass;
       fCascadedShadowMapBlurRenderPasses:array[0..1] of TpvScene3DRendererPassesCascadedShadowMapBlurRenderPass;
       fVoxelizationMeshFilterComputePass:TpvScene3DRendererPassesMeshFilterComputePass;
       fReflectionProbeMeshFilterComputePass:TpvScene3DRendererPassesMeshFilterComputePass;
       fTopDownSkyOcclusionMapMeshFilterComputePass:TpvScene3DRendererPassesMeshFilterComputePass;
       fReflectiveShadowMapMeshFilterComputePass:TpvScene3DRendererPassesMeshFilterComputePass;
       fMeshCullPass0ComputePass:TpvScene3DRendererPassesMeshCullPass0ComputePass;
       fSelectionListComputePass:TpvScene3DRendererPassesSelectionListComputePass; // object-selection outline: builds the selected-only indirect draw list
       fSelectionMaskRenderPass:TpvScene3DRendererPassesSelectionMaskRenderPass;   // object-selection outline: rasterizes the selection list into the RG32UI mask
       fSelectionOutlineBuildRenderPass:TpvScene3DRendererPassesSelectionOutlineBuildRenderPass; // object-selection outline: builds the isolated premultiplied outline buffer from the mask
       fSelectionOutlineFXAAComposeRenderPass:TpvScene3DRendererPassesSelectionOutlineFXAAComposeRenderPass; // object-selection outline: FXAA the outline buffer + composite over the scene (under the UI)
       fCullDepthRenderPass:TpvScene3DRendererPassesCullDepthRenderPass;
       fCullDepthResolveComputePass:TpvScene3DRendererPassesCullDepthResolveComputePass;
       fCullDepthPyramidComputePass:TpvScene3DRendererPassesCullDepthPyramidComputePass;
       fMeshCullPass1ComputePass:TpvScene3DRendererPassesMeshCullPass1ComputePass;
       fDepthPrepassRenderPass:TpvScene3DRendererPassesDepthPrepassRenderPass;
       fDepthMipMapComputePass:TpvScene3DRendererPassesDepthMipMapComputePass;
       fDepthOfFieldAutoFocusComputePass:TpvScene3DRendererPassesDepthOfFieldAutoFocusComputePass;
       fFrustumClusterGridBuildComputePass:TpvScene3DRendererPassesFrustumClusterGridBuildComputePass;
       fFrustumClusterGridAssignComputePass:TpvScene3DRendererPassesFrustumClusterGridAssignComputePass;
       fTopDownSkyOcclusionMapRenderPass:TpvScene3DRendererPassesTopDownSkyOcclusionMapRenderPass;
       fTopDownSkyOcclusionMapResolveRenderPass:TpvScene3DRendererPassesTopDownSkyOcclusionMapResolveRenderPass;
       fTopDownSkyOcclusionMapBlurRenderPasses:array[0..1] of TpvScene3DRendererPassesTopDownSkyOcclusionMapBlurRenderPass;
       fReflectiveShadowMapRenderPass:TpvScene3DRendererPassesReflectiveShadowMapRenderPass;
       fParticleBVHComputePass:TpvScene3DRendererPassesParticleBVHComputePass;
       fGlobalIlluminationCascadedRadianceHintsClearCustomPass:TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsClearCustomPass;
       fGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass:TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass;
       fGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass:TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass;
       fGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass:TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass;
       fGlobalIlluminationCascadedRadianceHintsInjectFinalizationCustomPass:TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectFinalizationCustomPass;
       fGlobalIlluminationCascadedRadianceHintsBounceComputePass:TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass;
       fGlobalIlluminationDDGITraceComputePass:TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePass;
       fGlobalIlluminationDDGIIrradianceUpdateComputePass:TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass;
       fGlobalIlluminationDDGIGlossyRadianceUpdateComputePass:TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass; // glossy atlas (only when GlobalIlluminationDDGIGlossyRadiance)
       fGlobalIlluminationDDGIVisibilityUpdateComputePass:TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass;
       fGlobalIlluminationDDGIBorderUpdateComputePass:TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass;
       fGlobalIlluminationDDGIRelocationComputePass:TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass;       // relocation only
       fGlobalIlluminationDDGIClassificationComputePass:TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass;   // relocation only
       fGlobalIlluminationSurfelComputePass:TpvScene3DRendererPassesGlobalIlluminationSurfelComputePass;
       fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass:TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass;
       fGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass:TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass;
       fGlobalIlluminationCascadedVoxelConeTracingOcclusionTransferComputePass:TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionTransferComputePass;
       fGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass:TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass;
       fGlobalIlluminationCascadedVoxelConeTracingRadianceTransferComputePass:TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingRadianceTransferComputePass;
       fGlobalIlluminationCascadedVoxelConeTracingRadianceMipMapComputePass:TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingRadianceMipMapComputePass;
       fGlobalIlluminationCascadedVoxelConeTracingFinalizationCustomPass:TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingFinalizationCustomPass;
//     fAmbientOcclusionDepthMipMapComputePass:TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass;
       fAmbientOcclusionRenderPass:TpvScene3DRendererPassesAmbientOcclusionRenderPass;
       fAmbientOcclusionBlurRenderPasses:array[0..1] of TpvScene3DRendererPassesAmbientOcclusionBlurRenderPass;
       fReflectionProbeRenderPass:TpvScene3DRendererPassesReflectionProbeRenderPass;
       fReflectionProbeMipMapComputePass:TpvScene3DRendererPassesReflectionProbeMipMapComputePass;
       fReflectionProbeComputePassGGX:TpvScene3DRendererPassesReflectionProbeComputePass;
       fReflectionProbeComputePassCharlie:TpvScene3DRendererPassesReflectionProbeComputePass;
       fReflectionProbeComputePassLambertian:TpvScene3DRendererPassesReflectionProbeComputePass;
//     fPlanetWaterPrepassComputePass:TpvScene3DRendererPassesPlanetWaterPrepassComputePass;
       fWetnessMapComputePass:TpvScene3DRendererPassesWetnessMapComputePass;
       fForwardComputePass:TpvScene3DRendererPassesForwardComputePass;
       fForwardRenderPass:TpvScene3DRendererPassesForwardRenderPass;
       fAtmosphereCloudRenderPass:TpvScene3DRendererPassesAtmosphereCloudRenderPass;
       fAtmosphereCloudShadowRenderPass:TpvScene3DRendererPassesAtmosphereCloudShadowRenderPass;
       fAtmosphereRenderPass:TpvScene3DRendererPassesAtmosphereRenderPass;
       fRainRenderPass:TpvScene3DRendererPassesRainRenderPass;
       fForwardResolveRenderPass:TpvScene3DRendererPassesForwardResolveRenderPass;
       fWaterWaitCustomPass:TpvScene3DRendererPassesWaterWaitCustomPass;
       fWaterRenderPass:TpvScene3DRendererPassesWaterRenderPass;
       fPlanetWaterCausticsComputePass:TpvScene3DRendererPassesPlanetWaterCausticsComputePass;
       fForwardRenderMipMapComputePass:TpvScene3DRendererPassesForwardRenderMipMapComputePass;
       fDirectTransparencyRenderPass:TpvScene3DRendererPassesDirectTransparencyRenderPass;
       fDirectTransparencyResolveRenderPass:TpvScene3DRendererPassesDirectTransparencyResolveRenderPass;
       fLockOrderIndependentTransparencyClearCustomPass:TpvScene3DRendererPassesLockOrderIndependentTransparencyClearCustomPass;
       fLockOrderIndependentTransparencyRenderPass:TpvScene3DRendererPassesLockOrderIndependentTransparencyRenderPass;
       fLockOrderIndependentTransparencyBarrierCustomPass:TpvScene3DRendererPassesLockOrderIndependentTransparencyBarrierCustomPass;
       fLockOrderIndependentTransparencyResolveRenderPass:TpvScene3DRendererPassesLockOrderIndependentTransparencyResolveRenderPass;
       fLoopOrderIndependentTransparencyClearCustomPass:TpvScene3DRendererPassesLoopOrderIndependentTransparencyClearCustomPass;
       fLoopOrderIndependentTransparencyPass1RenderPass:TpvScene3DRendererPassesLoopOrderIndependentTransparencyPass1RenderPass;
       fLoopOrderIndependentTransparencyPass1BarrierCustomPass:TpvScene3DRendererPassesLoopOrderIndependentTransparencyPass1BarrierCustomPass;
       fLoopOrderIndependentTransparencyPass2RenderPass:TpvScene3DRendererPassesLoopOrderIndependentTransparencyPass2RenderPass;
       fLoopOrderIndependentTransparencyPass2BarrierCustomPass:TpvScene3DRendererPassesLoopOrderIndependentTransparencyPass2BarrierCustomPass;
       fLoopOrderIndependentTransparencyResolveRenderPass:TpvScene3DRendererPassesLoopOrderIndependentTransparencyResolveRenderPass;
       fWeightBlendedOrderIndependentTransparencyRenderPass:TpvScene3DRendererPassesWeightBlendedOrderIndependentTransparencyRenderPass;
       fWeightBlendedOrderIndependentTransparencyResolveRenderPass:TpvScene3DRendererPassesWeightBlendedOrderIndependentTransparencyResolveRenderPass;
       fMomentBasedOrderIndependentTransparencyAbsorbanceRenderPass:TpvScene3DRendererPassesMomentBasedOrderIndependentTransparencyAbsorbanceRenderPass;
       fMomentBasedOrderIndependentTransparencyTransmittanceRenderPass:TpvScene3DRendererPassesMomentBasedOrderIndependentTransparencyTransmittanceRenderPass;
       fMomentBasedOrderIndependentTransparencyResolveRenderPass:TpvScene3DRendererPassesMomentBasedOrderIndependentTransparencyResolveRenderPass;
       fDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass:TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass;
       fDeepAndFastApproximateOrderIndependentTransparencyRenderPass:TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyRenderPass;
       fDeepAndFastApproximateOrderIndependentTransparencyResolveRenderPass:TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyResolveRenderPass;
       fOrderIndependentTransparencyResolveRenderPass:TpvScene3DRendererPassesOrderIndependentTransparencyResolveRenderPass;
       fLuminanceHistogramComputePass:TpvScene3DRendererPassesLuminanceHistogramComputePass;
       fLuminanceAverageComputePass:TpvScene3DRendererPassesLuminanceAverageComputePass;
       fLuminanceAdaptationRenderPass:TpvScene3DRendererPassesLuminanceAdaptationRenderPass;
       fAntialiasingNoneRenderPass:TpvScene3DRendererPassesAntialiasingNoneRenderPass;
       fAntialiasingDSAARenderPass:TpvScene3DRendererPassesAntialiasingDSAARenderPass;
       fAntialiasingFXAARenderPass:TpvScene3DRendererPassesAntialiasingFXAARenderPass;
       fAntialiasingSMAAT2xPreCustomPass:TpvScene3DRendererPassesAntialiasingSMAAT2xPreCustomPass;
       fAntialiasingSMAAT2xTemporalResolveRenderPass:TpvScene3DRendererPassesAntialiasingSMAAT2xTemporalResolveRenderPass;
       fAntialiasingSMAAT2xPostCustomPass:TpvScene3DRendererPassesAntialiasingSMAAT2xPostCustomPass;
       fAntialiasingSMAAEdgesRenderPass:TpvScene3DRendererPassesAntialiasingSMAAEdgesRenderPass;
       fAntialiasingSMAAWeightsRenderPass:TpvScene3DRendererPassesAntialiasingSMAAWeightsRenderPass;
       fAntialiasingSMAABlendRenderPass:TpvScene3DRendererPassesAntialiasingSMAABlendRenderPass;
       fAntialiasingTAAPreCustomPass:TpvScene3DRendererPassesAntialiasingTAAPreCustomPass;
       fAntialiasingTAARenderPass:TpvScene3DRendererPassesAntialiasingTAARenderPass;
       fAntialiasingTAAPostCustomPass:TpvScene3DRendererPassesAntialiasingTAAPostCustomPass;
       fDepthOfFieldPrepareRenderPass:TpvScene3DRendererPassesDepthOfFieldPrepareRenderPass;
       fDepthOfFieldBokehComputePass:TpvScene3DRendererPassesDepthOfFieldBokehComputePass;
       fDepthOfFieldPrefilterRenderPass:TpvScene3DRendererPassesDepthOfFieldPrefilterRenderPass;
       fDepthOfFieldBlurRenderPass:TpvScene3DRendererPassesDepthOfFieldBlurRenderPass;
       fDepthOfFieldBruteforceRenderPass:TpvScene3DRendererPassesDepthOfFieldBruteforceRenderPass;
       fDepthOfFieldPostBlurRenderPass:TpvScene3DRendererPassesDepthOfFieldPostBlurRenderPass;
       fDepthOfFieldCombineRenderPass:TpvScene3DRendererPassesDepthOfFieldCombineRenderPass;
       fDepthOfFieldGatherPass1RenderPass:TpvScene3DRendererPassesDepthOfFieldGatherPass1RenderPass;
       fDepthOfFieldGatherPass2RenderPass:TpvScene3DRendererPassesDepthOfFieldGatherPass2RenderPass;
       fDepthOfFieldResolveRenderPass:TpvScene3DRendererPassesDepthOfFieldResolveRenderPass;
       fResamplingRenderPass:TpvScene3DRendererPassesResamplingRenderPass;
       fEASURCASComputePass:TpvScene3DRendererPassesEASURCASComputePass;
       fCNNUpscalerComputePass:TpvScene3DRendererPassesCNNUpscalerComputePass;
       fLensDownsampleComputePass:TpvScene3DRendererPassesLensDownsampleComputePass;
       fLensUpsampleComputePass:TpvScene3DRendererPassesLensUpsampleComputePass;
       fLensResolveRenderPass:TpvScene3DRendererPassesLensResolveRenderPass;
       fLensRainRenderPass:TpvScene3DRendererPassesLensRainRenderPass;
       fTonemappingRenderPass:TpvScene3DRendererPassesTonemappingRenderPass;
       fCanvasComputePass:TpvScene3DRendererPassesCanvasComputePass;
       fCanvasRenderPass:TpvScene3DRendererPassesCanvasRenderPass;
       fHUDCustomPass:TpvScene3DRendererInstance.THUDCustomPass;
       fHUDComputePass:TpvScene3DRendererInstance.THUDComputePass;
       fHUDRenderPass:TpvScene3DRendererInstance.THUDRenderPass;
       fHUDMipMapCustomPass:TpvScene3DRendererPassesHUDMipMapCustomPass;
       fContentProjectionRenderPass:TpvScene3DRendererPassesContentProjectionRenderPass;
       fAtmospherePrecipitationReleaseCustomPass:TpvScene3DRendererPassesAtmospherePrecipitationReleaseCustomPass;
       fWaterReleaseCustomPass:TpvScene3DRendererPassesWaterReleaseCustomPass;
       fDebugBlitRenderPass:TpvScene3DRendererPassesDebugBlitRenderPass;
       fFrameBufferBlitRenderPass:TpvScene3DRendererPassesFrameBufferBlitRenderPass;
     end;

const CountJitterOffsets=32;
      JitterOffsetMask=CountJitterOffsets-1;

var JitterOffsets:array[0..CountJitterOffsets-1] of TpvVector2;

{$ifdef FrameTextFileDebug}
var DebugDrawInfoDumpCounter:TpvInt32=0;
    DebugAutoDumpFrameCounter:TpvInt32=0;
    DebugAutoDumpDone:boolean=false;
{$endif}

{ TpvScene3DRendererInstance.TMeshFragmentSpecializationConstants }

procedure TpvScene3DRendererInstance.TMeshFragmentSpecializationConstants.SetPipelineShaderStage(const aVulkanPipelineShaderStage:TpvVulkanPipelineShaderStage);
begin
{aVulkanPipelineShaderStage.AddSpecializationMapEntry(0,TVkPtrUInt(pointer(@UseReversedZ))-TVkPtrUInt(pointer(@self)),SizeOf(TVkBool32));
 aVulkanPipelineShaderStage.AddSpecializationDataFromMemory(@self,SizeOf(TpvScene3DRendererInstance.TMeshFragmentSpecializationConstants),true);//}
end;

{ TpvScene3DRendererInstance.TCascadedShadowMapBuilder }

constructor TpvScene3DRendererInstance.TCascadedShadowMapBuilder.Create(const aInstance:TpvScene3DRendererInstance);
begin
 inherited Create;
 fInstance:=aInstance;
end;

destructor TpvScene3DRendererInstance.TCascadedShadowMapBuilder.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DRendererInstance.TCascadedShadowMapBuilder.SnapLightFrustum(var aScale,aOffset:TpvVector2;const aMatrix:TpvMatrix4x4;const aWorldOrigin:TpvVector3;const aShadowMapResolution:TpvVector2);
var Resolution,LightSpaceOrigin:TpvVector2;
begin
 Resolution:=aShadowMapResolution*2.0;
 aOffset:=aOffset-TpvVector2.InlineableCreate(Modulo(aOffset.x,Resolution.x),Modulo(aOffset.y,Resolution.y));
 LightSpaceOrigin:=aMatrix.MulHomogen(aWorldOrigin).xy*aScale;
 aOffset:=aOffset-TpvVector2.InlineableCreate(Modulo(LightSpaceOrigin.x,Resolution.x),Modulo(LightSpaceOrigin.y,Resolution.y));
end;

procedure TpvScene3DRendererInstance.TCascadedShadowMapBuilder.Calculate(const aInFlightFrameIndex:TpvInt32);
var CascadedShadowMapIndex,Index,ViewIndex:TpvSizeInt;
    CascadedShadowMaps:PCascadedShadowMaps;
    CascadedShadowMap:PCascadedShadowMap;
    CascadedShadowMapSplitLambda,
    CascadedShadowMapSplitOverlap,
    MinZ,MaxZ,
    Ratio,SplitValue,UniformSplitValue,LogSplitValue,
    FadeStartValue,LastValue,Value,TexelSizeAtOneMeter,
    zNear,zFar,RealZNear,RealZFar:TpvDouble;
    DoNeedRefitNearFarPlanes:boolean;
    InFlightFrameState:PInFlightFrameState;
    Renderer:TpvScene3DRenderer;
    FrustumCenterX,FrustumCenterY,FrustumCenterZ:TpvDouble;
    FrustumRadius:TpvScalar;
    fLightSpaceWorldAABB:TpvAABB;
begin

 Renderer:=fInstance.Renderer;

 InFlightFrameState:=@fInstance.fInFlightFrameStates[aInFlightFrameIndex];

 if IsInfinite(fInstance.fCascadedShadowMapRadius) then begin
  MaxZ:=fInstance.fCascadedShadowMapRadius;
 end else begin
  MaxZ:=fInstance.fCascadedShadowMapCenter.Length+fInstance.fCascadedShadowMapRadius;
 end;

 zNear:=InFlightFrameState^.AdjustedZNear;
 zFar:=Min(MaxZ,InFlightFrameState^.AdjustedZFar);

 RealZNear:=InFlightFrameState^.RealZNear;
 RealZFar:=Min(MaxZ,InFlightFrameState^.RealZFar);

 DoNeedRefitNearFarPlanes:=InFlightFrameState^.DoNeedRefitNearFarPlanes;

 CascadedShadowMapSplitLambda:=0.95;

 CascadedShadowMapSplitOverlap:=0.1;

 CascadedShadowMaps:=@fInstance.fInFlightFrameCascadedShadowMaps[aInFlightFrameIndex];

 CascadedShadowMaps^[0].SplitDepths.x:=Min(zNear,RealZNear);
 Ratio:=zFar/zNear;
 LastValue:=0.0;
 for CascadedShadowMapIndex:=1 to CountCascadedShadowMapCascades-1 do begin
  SplitValue:=CascadedShadowMapIndex/CountCascadedShadowMapCascades;
  UniformSplitValue:=((1.0-SplitValue)*zNear)+(SplitValue*zFar);
  LogSplitValue:=zNear*power(Ratio,SplitValue);
  Value:=((1.0-CascadedShadowMapSplitLambda)*UniformSplitValue)+(CascadedShadowMapSplitLambda*LogSplitValue);
  FadeStartValue:=Min(Max((Value*(1.0-CascadedShadowMapSplitOverlap))+(LastValue*CascadedShadowMapSplitOverlap),Min(zNear,RealZNear)),Max(zFar,RealZFar));
  LastValue:=Value;
  CascadedShadowMaps^[CascadedShadowMapIndex].SplitDepths.x:=Min(Max(FadeStartValue,Min(zNear,RealZNear)),Max(zFar,RealZFar));
  CascadedShadowMaps^[CascadedShadowMapIndex-1].SplitDepths.y:=Min(Max(Value,Min(zNear,RealZNear)),Max(zFar,RealZFar));
 end;
 CascadedShadowMaps^[CountCascadedShadowMapCascades-1].SplitDepths.y:=Max(ZFar,RealZFar);

 for ViewIndex:=0 to fInstance.fCountRealViews[aInFlightFrameIndex]-1 do begin
  fProjectionMatrix:=fInstance.fViews[aInFlightFrameIndex].Items[ViewIndex].ProjectionMatrix;
  if DoNeedRefitNearFarPlanes then begin
   fProjectionMatrix[2,2]:=RealZFar/(RealZNear-RealZFar);
   fProjectionMatrix[3,2]:=(-(RealZNear*RealZFar))/(RealZFar-RealZNear);
  end;
  fInverseViewProjectionMatrices[ViewIndex]:=(fInstance.fViews[aInFlightFrameIndex].Items[ViewIndex].ViewMatrix*fProjectionMatrix).Inverse;
 end;

 fLightForwardVector:=-Renderer.Scene3D.PrimaryShadowMapLightDirection.xyz.Normalize;
//fLightForwardVector:=-Renderer.EnvironmentCubeMap.LightDirection.xyz.Normalize;
 fLightSideVector:=fLightForwardVector.Perpendicular;
{fLightSideVector:=TpvVector3.InlineableCreate(-fViews.Items[0].ViewMatrix.RawComponents[0,2],
                                               -fViews.Items[0].ViewMatrix.RawComponents[1,2],
                                               -fViews.Items[0].ViewMatrix.RawComponents[2,2]).Normalize;
 if abs(fLightForwardVector.Dot(fLightSideVector))>0.5 then begin
  if abs(fLightForwardVector.Dot(TpvVector3.YAxis))<0.9 then begin
   fLightSideVector:=TpvVector3.YAxis;
  end else begin
   fLightSideVector:=TpvVector3.ZAxis;
  end;
 end;}
 fLightUpVector:=(fLightForwardVector.Cross(fLightSideVector)).Normalize;
 fLightSideVector:=(fLightUpVector.Cross(fLightForwardVector)).Normalize;
 fLightViewMatrix.RawComponents[0,0]:=fLightSideVector.x;
 fLightViewMatrix.RawComponents[0,1]:=fLightUpVector.x;
 fLightViewMatrix.RawComponents[0,2]:=fLightForwardVector.x;
 fLightViewMatrix.RawComponents[0,3]:=0.0;
 fLightViewMatrix.RawComponents[1,0]:=fLightSideVector.y;
 fLightViewMatrix.RawComponents[1,1]:=fLightUpVector.y;
 fLightViewMatrix.RawComponents[1,2]:=fLightForwardVector.y;
 fLightViewMatrix.RawComponents[1,3]:=0.0;
 fLightViewMatrix.RawComponents[2,0]:=fLightSideVector.z;
 fLightViewMatrix.RawComponents[2,1]:=fLightUpVector.z;
 fLightViewMatrix.RawComponents[2,2]:=fLightForwardVector.z;
 fLightViewMatrix.RawComponents[2,3]:=0.0;
 fLightViewMatrix.RawComponents[3,0]:=0.0;
 fLightViewMatrix.RawComponents[3,1]:=0.0;
 fLightViewMatrix.RawComponents[3,2]:=0.0;
 fLightViewMatrix.RawComponents[3,3]:=1.0;

 for ViewIndex:=0 to fInstance.fCountRealViews[aInFlightFrameIndex]-1 do begin
  for Index:=0 to 7 do begin
   fWorldSpaceFrustumCorners[ViewIndex,Index]:=fInverseViewProjectionMatrices[ViewIndex].MulHomogen(TpvVector4.InlineableCreate(FrustumCorners[Index],1.0)).xyz;
  end;
 end;

 for CascadedShadowMapIndex:=0 to CountCascadedShadowMapCascades-1 do begin

  CascadedShadowMap:=@CascadedShadowMaps^[CascadedShadowMapIndex];

  MinZ:=CascadedShadowMap^.SplitDepths.x;
  MaxZ:=CascadedShadowMap^.SplitDepths.y;

  for ViewIndex:=0 to fInstance.fCountRealViews[aInFlightFrameIndex]-1 do begin
   for Index:=0 to 3 do begin
    fTemporaryFrustumCorners[ViewIndex,Index]:=fWorldSpaceFrustumCorners[ViewIndex,Index].Lerp(fWorldSpaceFrustumCorners[ViewIndex,Index+4],(MinZ-RealZNear)/(RealZFar-RealZNear));
    fTemporaryFrustumCorners[ViewIndex,Index+4]:=fWorldSpaceFrustumCorners[ViewIndex,Index].Lerp(fWorldSpaceFrustumCorners[ViewIndex,Index+4],(MaxZ-RealZNear)/(RealZFar-RealZNear));
   end;
  end;

  FrustumCenterX:=0.0;
  FrustumCenterY:=0.0;
  FrustumCenterZ:=0.0;
  for ViewIndex:=0 to fInstance.fCountRealViews[aInFlightFrameIndex]-1 do begin
   for Index:=0 to 7 do begin
    FrustumCenterX:=FrustumCenterX+fTemporaryFrustumCorners[ViewIndex,Index].x;
    FrustumCenterY:=FrustumCenterY+fTemporaryFrustumCorners[ViewIndex,Index].y;
    FrustumCenterZ:=FrustumCenterZ+fTemporaryFrustumCorners[ViewIndex,Index].z;
   end;
  end;
  fFrustumCenter.x:=FrustumCenterX/(8.0*fInstance.fCountRealViews[aInFlightFrameIndex]);
  fFrustumCenter.y:=FrustumCenterY/(8.0*fInstance.fCountRealViews[aInFlightFrameIndex]);
  fFrustumCenter.z:=FrustumCenterZ/(8.0*fInstance.fCountRealViews[aInFlightFrameIndex]);

  FrustumRadius:=0.0;
  for ViewIndex:=0 to fInstance.fCountRealViews[aInFlightFrameIndex]-1 do begin
   for Index:=0 to 7 do begin
    FrustumRadius:=Max(FrustumRadius,fTemporaryFrustumCorners[ViewIndex,Index].DistanceTo(fFrustumCenter));
   end;
  end;
  FrustumRadius:=ceil(FrustumRadius*16.0)/16.0;

  fFrustumAABB.Min:=TpvVector3.InlineableCreate(-FrustumRadius,-FrustumRadius,-FrustumRadius);
  fFrustumAABB.Max:=TpvVector3.InlineableCreate(FrustumRadius,FrustumRadius,FrustumRadius);

  fOrigin:=fFrustumCenter-(fLightForwardVector*fFrustumAABB.Min.z);
  fLightViewMatrix.RawComponents[3,0]:=-fLightSideVector.Dot(fOrigin);
  fLightViewMatrix.RawComponents[3,1]:=-fLightUpVector.Dot(fOrigin);
  fLightViewMatrix.RawComponents[3,2]:=-fLightForwardVector.Dot(fOrigin);

  fLightSpaceWorldAABB:=InFlightFrameState^.SceneWorldSpaceBoundingBox.HomogenTransform(fLightViewMatrix);

  fFrustumAABB.Min.x:=Math.Max(fFrustumAABB.Min.x,fLightSpaceWorldAABB.Min.x);
  fFrustumAABB.Min.y:=Math.Max(fFrustumAABB.Min.y,fLightSpaceWorldAABB.Min.y);
  fFrustumAABB.Max.x:=Math.Min(fFrustumAABB.Max.x,fLightSpaceWorldAABB.Max.x);
  fFrustumAABB.Max.y:=Math.Min(fFrustumAABB.Max.y,fLightSpaceWorldAABB.Max.y);

  fLightProjectionMatrix:=TpvMatrix4x4.CreateOrthoRightHandedZeroToOne(fFrustumAABB.Min.x,
                                                                       fFrustumAABB.Max.x,
                                                                       fFrustumAABB.Min.y,
                                                                       fFrustumAABB.Max.y,
                                                                       CascadeNearPlaneOffset,
                                                                       (fFrustumAABB.Max.z-fFrustumAABB.Min.z)+CascadeFarPlaneOffset);

  fLightViewProjectionMatrix:=fLightViewMatrix*fLightProjectionMatrix;

//fShadowOrigin:=(fLightViewProjectionMatrix.MulHomogen(TpvVector3.Origin)).xy*TpvVector2.InlineableCreate(fInstance.CascadedShadowMapWidth*0.5,fInstance.CascadedShadowMapHeight*0.5);
  fShadowOrigin:=(fLightViewProjectionMatrix*TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0)).xy*TpvVector2.InlineableCreate(fInstance.fCascadedShadowMapWidth*0.5,fInstance.fCascadedShadowMapHeight*0.5);
  fRoundedOrigin.x:=round(fShadowOrigin.x);
  fRoundedOrigin.y:=round(fShadowOrigin.y);
  fRoundOffset:=(fRoundedOrigin-fShadowOrigin)*TpvVector2.InlineableCreate(2.0/fInstance.fCascadedShadowMapWidth,2.0/fInstance.fCascadedShadowMapHeight);
  fLightProjectionMatrix[3,0]:=fLightProjectionMatrix[3,0]+fRoundOffset.x;
  fLightProjectionMatrix[3,1]:=fLightProjectionMatrix[3,1]+fRoundOffset.y;

  fLightViewProjectionMatrix:=fLightViewMatrix*fLightProjectionMatrix;

  if IsNaN(fLightViewProjectionMatrix.m00) then begin
   CascadedShadowMap^.View.ProjectionMatrix:=fLightProjectionMatrix;
  end;

  CascadedShadowMap^.View.ViewMatrix:=fLightViewMatrix;
  CascadedShadowMap^.View.ProjectionMatrix:=fLightProjectionMatrix;
  CascadedShadowMap^.View.InverseViewMatrix:=fLightViewMatrix.Inverse;
  CascadedShadowMap^.View.InverseProjectionMatrix:=fLightProjectionMatrix.Inverse;
  CascadedShadowMap^.CombinedMatrix:=fLightViewProjectionMatrix;

  fInverseLightViewProjectionMatrix:=fLightViewProjectionMatrix.Inverse;

  TexelSizeAtOneMeter:=Max(TpvVector3.InlineableCreate(fInverseLightViewProjectionMatrix[0,0],fInverseLightViewProjectionMatrix[0,1],fInverseLightViewProjectionMatrix[0,2]).Length/fInstance.CascadedShadowMapWidth,
                           TpvVector3.InlineableCreate(fInverseLightViewProjectionMatrix[1,0],fInverseLightViewProjectionMatrix[1,1],fInverseLightViewProjectionMatrix[1,2]).Length/fInstance.CascadedShadowMapHeight);

  CascadedShadowMap^.Scales.x:=TexelSizeAtOneMeter;
  CascadedShadowMap^.Scales.y:=Max(4.0,(1.0*0.02)/TexelSizeAtOneMeter);

  fInstance.fCascadedShadowMapUniformBuffers[aInFlightFrameIndex].Matrices[CascadedShadowMapIndex]:=fLightViewProjectionMatrix;
  fInstance.fCascadedShadowMapUniformBuffers[aInFlightFrameIndex].SplitDepthsScales[CascadedShadowMapIndex]:=TpvVector4.Create(CascadedShadowMap^.SplitDepths,CascadedShadowMap^.Scales.x,CascadedShadowMap^.Scales.y);
  fInstance.fCascadedShadowMapUniformBuffers[aInFlightFrameIndex].ConstantBiasNormalBiasSlopeBiasClamp[CascadedShadowMapIndex]:=TpvVector4.Create(1e-3,1.0*TexelSizeAtOneMeter,5.0*TexelSizeAtOneMeter,0.0);

 end;

 fInstance.fCascadedShadowMapUniformBuffers[aInFlightFrameIndex].MetaData[0]:=TpvUInt32(Renderer.ShadowMode);
 fInstance.fCascadedShadowMapUniformBuffers[aInFlightFrameIndex].MetaData[1]:=0;
 fInstance.fCascadedShadowMapUniformBuffers[aInFlightFrameIndex].MetaData[2]:=0;
 fInstance.fCascadedShadowMapUniformBuffers[aInFlightFrameIndex].MetaData[3]:=0;

 InFlightFrameState^.CascadedShadowMapViewIndex:={Renderer.Scene3D}fInstance.AddView(aInFlightFrameIndex,CascadedShadowMaps^[0].View);
 for CascadedShadowMapIndex:=1 to CountCascadedShadowMapCascades-1 do begin
  {Renderer.Scene3D}fInstance.AddView(aInFlightFrameIndex,CascadedShadowMaps^[CascadedShadowMapIndex].View);
 end;

 InFlightFrameState^.CountCascadedShadowMapViews:=CountCascadedShadowMapCascades;

end;

{ TpvScene3DRendererInstance.TCascadedVolumes.TCascade }

constructor TpvScene3DRendererInstance.TCascadedVolumes.TCascade.Create(const aCascadedVolumes:TCascadedVolumes);
begin
 inherited Create;
 fCascadedVolumes:=aCascadedVolumes;
end;

destructor TpvScene3DRendererInstance.TCascadedVolumes.TCascade.Destroy;
begin
 inherited Destroy;
end;

{ TpvScene3DRendererInstance.TCascadedVolumes }

constructor TpvScene3DRendererInstance.TCascadedVolumes.Create(const aRendererInstance:TpvScene3DRendererInstance;const aVolumeSize,aCountCascades:TpvSizeInt;const aCascadeVolumeKind:TCascadeVolumeKind);
var CascadeIndex:TpvSizeInt;
begin

 inherited Create;

 fRendererInstance:=aRendererInstance;

 fVolumeSize:=aVolumeSize;

 fCountCascades:=aCountCascades;

 fCascadeVolumeKind:=aCascadeVolumeKind;

 fCascades:=TpvScene3DRendererInstance.TCascadedVolumes.TCascades.Create(true);
 for CascadeIndex:=0 to fCountCascades-1 do begin
  fCascades.Add(TpvScene3DRendererInstance.TCascadedVolumes.TCascade.Create(self));
 end;

 fFirst:=true;

end;

destructor TpvScene3DRendererInstance.TCascadedVolumes.Destroy;
begin
 FreeAndNil(fCascades);
 inherited Destroy;
end;

procedure TpvScene3DRendererInstance.TCascadedVolumes.Reset;
begin
 fFirst:=true;
end;

procedure TpvScene3DRendererInstance.TCascadedVolumes.Update(const aInFlightFrameIndex:TpvSizeInt);
 procedure ComputeGridExtents(out aAABB:TpvAABB;
                              const aPosition:TpvVector3;
                              const aDirection:TpvVector3;
                              const aGridSize:TpvVector3;
                              const aTotalCells:TpvInt32;
                              const aBufferCells:TpvInt32);
 var HalfCells:TpvInt32;
     MaxCell:TpvVector3;
 begin
  HalfCells:=aTotalCells shr 1;
  MaxCell:=Clamp(TpvVector3.InlineableCreate(HalfCells)-
                 TpvVector3.InlineableCreate(aDirection*(aBufferCells-HalfCells)).Truncate,
                 TpvVector3.InlineableCreate(aBufferCells),
                 TpvVector3.InlineableCreate(aTotalCells-aBufferCells));
  aAABB.Max:=aPosition+(MaxCell*(aGridSize/aTotalCells));
  aAABB.Min:=aAABB.Max-aGridSize;
 end;//}
var CascadeIndex,BorderCells:TpvSizeInt;
    CellSize,MaximumCascadeCellSize:TpvDouble;
    SnapSize,MaxAxisSize:TpvDouble;
    InFlightFrameState:PInFlightFrameState;
    ViewPosition:TpvVector3;
    ViewDirection:TpvVector3;
    GridCenter:TpvVector3;
    SnappedPosition:TpvVector3;
    GridSize:TpvVector3;
//  ClampDelta:TpvVector3;
    SceneAABB:TpvAABB;
    ClampedSceneAABB:TpvAABB;
    AABB:TpvAABB;
    Cascade:TpvScene3DRendererInstance.TCascadedVolumes.TCascade;
    m:TpvMatrix4x4;
begin

 InFlightFrameState:=@fRendererInstance.fInFlightFrameStates[aInFlightFrameIndex];

 m:=InFlightFrameState^.MainInverseViewMatrix;

 ViewPosition:=TpvVector3.InlineableCreate(m.RawComponents[3,0],
                                           m.RawComponents[3,1],
                                           m.RawComponents[3,2])/m.RawComponents[3,3];

// ViewPosition:=TpvVector3.Null;

 ViewDirection:=TpvVector3.InlineableCreate(-m.RawComponents[2,0],
                                            -m.RawComponents[2,1],
                                            -m.RawComponents[2,2]).Normalize;//}

 SceneAABB:=fRendererInstance.Renderer.Scene3D.InFlightFrameBoundingBoxes[aInFlightFrameIndex];

 GridCenter:=ViewPosition;//+(ViewDirection/Max(Max(abs(ViewDirection.x),abs(ViewDirection.y)),abs(ViewDirection.z)));

 GridCenter:=(GridCenter.Max(SceneAABB.Min)).Min(SceneAABB.Max);

 SceneAABB.Min:=SceneAABB.Min.Floor;
 SceneAABB.Max:=SceneAABB.Max.Ceil;

 MaxAxisSize:=Max(Max(SceneAABB.Max.x-SceneAABB.Min.x,
                      SceneAABB.Max.y-SceneAABB.Min.y),
                  SceneAABB.Max.z-SceneAABB.Min.z);

 case fCascadeVolumeKind of
  TCascadeVolumeKind.VoxelConeTracing:begin
   MaxAxisSize:=MaxAxisSize*1.25;
  end;
  else begin
  end;
 end;

 MaximumCascadeCellSize:=Max(1e-6,MaxAxisSize/fVolumeSize);

 case fCascadeVolumeKind of
  TCascadeVolumeKind.VoxelConeTracing:begin
   MaximumCascadeCellSize:=Ceil(MaximumCascadeCellSize/(1 shl fCountCascades))*(1 shl fCountCascades);
  end;
  TCascadeVolumeKind.DynamicDiffuseGlobalIllumination:begin
   MaximumCascadeCellSize:=Ceil(MaximumCascadeCellSize/(1 shl fCountCascades))*(1 shl fCountCascades);
  end;
  else begin
   MaximumCascadeCellSize:=Ceil(MaximumCascadeCellSize);
  end;
 end;

 CellSize:=1;

 for CascadeIndex:=0 to fCountCascades-1 do begin

  Cascade:=fCascades[CascadeIndex];

  case fCascadeVolumeKind of
   TCascadeVolumeKind.VoxelConeTracing:begin
{   if CascadeIndex=(fCountCascades-1) then begin
     CellSize:=MaximumCascadeCellSize;
    end else}if CascadeIndex=0 then begin
     CellSize:=Min(0.125,MaximumCascadeCellSize);
    end else begin
     CellSize:=Min(CellSize*2.0,MaximumCascadeCellSize);//}
 {  end else begin
     CellSize:=MaximumCascadeCellSize/Power(2.0,fCountCascades-(CascadeIndex+1));//}
    end;
   end;
   TCascadeVolumeKind.DynamicDiffuseGlobalIllumination:begin
    if CascadeIndex=(fCountCascades-1) then begin
     CellSize:=MaximumCascadeCellSize;//}
    end else if CascadeIndex=0 then begin
     CellSize:=Min(1.0,MaximumCascadeCellSize);
    end else begin
     CellSize:=Min(CellSize*4.0,MaximumCascadeCellSize);//}
 {  end else begin
     CellSize:=MaximumCascadeCellSize/Power(2.0,fCountCascades-(CascadeIndex+1));//}
    end;
   end;
   else begin
    if CascadeIndex=(fCountCascades-1) then begin
     CellSize:=MaximumCascadeCellSize;
    end else if CascadeIndex=0 then begin
     CellSize:=Min(1.0,MaximumCascadeCellSize);
    end else begin
     CellSize:=Min(CellSize*4.0,MaximumCascadeCellSize);
    end;//}
  { end else if CascadeIndex=0 then begin
     CellSize:=1;
    end else begin
     CellSize:=Ceil(Min(Max(round(MaximumCascadeCellSize*Power((CascadeIndex+1)/fCountCascades,1.0)),1.0),MaximumCascadeCellSize));
    end; //}
   end;
  end;

{ if (CellSize and 1)<>0 then begin
   inc(CellSize);
  end;}

//CellSize:=0.5;

  case fCascadeVolumeKind of
   TCascadeVolumeKind.VoxelConeTracing:begin
    SnapSize:=CellSize*2.0;
   end;
   TCascadeVolumeKind.DynamicDiffuseGlobalIllumination:begin
    SnapSize:=CellSize*2.0;
   end;
   else begin
    SnapSize:=CellSize;
   end;
  end;

  SnappedPosition:=(GridCenter/SnapSize).Round*SnapSize;

  GridSize:=TpvVector3.InlineableCreate(fVolumeSize*CellSize,fVolumeSize*CellSize,fVolumeSize*CellSize);

  BorderCells:=fCountCascades-CascadeIndex;

  ClampedSceneAABB.Max:=TpvVector3.InlineableCreate(SceneAABB.Max+(GridSize*0.5)).Max(SceneAABB.Min+(GridSize*0.5));
  ClampedSceneAABB.Min:=TpvVector3.InlineableCreate(SceneAABB.Min+(GridSize*0.5)).Min(ClampedSceneAABB.Max);

  SnappedPosition:=(SnappedPosition.Max(ClampedSceneAABB.Min)).Min(ClampedSceneAABB.Max);

  case fCascadeVolumeKind of
   TCascadeVolumeKind.VoxelConeTracing:begin
    AABB.Min:=SnappedPosition-(GridSize*0.5);
    AABB.Max:=AABB.Min+GridSize;
   end;
   TCascadeVolumeKind.DynamicDiffuseGlobalIllumination:begin
    AABB.Min:=SnappedPosition-(GridSize*0.5);
    AABB.Max:=AABB.Min+GridSize;
   end;
   else begin
    AABB.Min:=TpvVector3.InlineableCreate((SnappedPosition-(GridSize*0.5))/SnapSize).Floor*SnapSize;
    AABB.Max:=AABB.Min+GridSize;
   end;
  end;

//ComputeGridExtents(AABB,SnappedPosition,ViewDirection,GridSize,fVolumeSize,BorderCells);

//write(AABB.Min.x:6:4,' ',AABB.Min.y:6:4,' ',AABB.Min.z:6:4,' ',(AABB.Max.x-AABB.Min.x):6:4,' ',(AABB.Max.y-AABB.Min.y):6:4,' ',(AABB.Max.z-AABB.Min.z):6:4,' ');

  Cascade.fAABB:=AABB;
  Cascade.fCellSize:=CellSize;
  Cascade.fSnapSize:=SnapSize;
  Cascade.fOffset:=GridCenter-SnappedPosition;
  Cascade.fBorderCells:=BorderCells;

  if fFirst then begin
   Cascade.fDelta.x:=1000;
   Cascade.fDelta.y:=1000;
   Cascade.fDelta.z:=1000;
   Cascade.fDelta.w:=-1;
  end else begin
   Cascade.fDelta.x:=trunc(floor((Cascade.fAABB.Min.x-Cascade.fLastAABB.Min.x)/CellSize));
   Cascade.fDelta.y:=trunc(floor((Cascade.fAABB.Min.y-Cascade.fLastAABB.Min.y)/CellSize));
   Cascade.fDelta.z:=trunc(floor((Cascade.fAABB.Min.z-Cascade.fLastAABB.Min.z)/CellSize));
   if (Cascade.fDelta.x<>0) or (Cascade.fDelta.y<>0) or (Cascade.fDelta.z<>0) then begin
    Cascade.fDelta.w:=1;
   end else begin
    Cascade.fDelta.w:=0;
   end;
  end;

  Cascade.fLastAABB:=Cascade.fAABB;
  Cascade.fLastOffset:=Cascade.fOffset;

 end;

//writeln;

 fFirst:=false;

end;

{ TpvScene3DRendererInstance.THUDCustomPass }

constructor TpvScene3DRendererInstance.THUDCustomPass.Create(const aFrameGraph:TpvFrameGraph;const aRendererInstance:TpvScene3DRendererInstance;const aParent:TObject);
begin
 inherited Create(aFrameGraph);
 fRendererInstance:=aRendererInstance;
 fParent:=aParent;
end;

{ TpvScene3DRendererInstance.THUDComputePass }

constructor TpvScene3DRendererInstance.THUDComputePass.Create(const aFrameGraph:TpvFrameGraph;const aRendererInstance:TpvScene3DRendererInstance;const aParent:TObject);
begin
 inherited Create(aFrameGraph);
 fRendererInstance:=aRendererInstance;
 fParent:=aParent;
end;

{ TpvScene3DRendererInstance.THUDRenderPass }

constructor TpvScene3DRendererInstance.THUDRenderPass.Create(const aFrameGraph:TpvFrameGraph;const aRendererInstance:TpvScene3DRendererInstance;const aParent:TObject);
begin
 inherited Create(aFrameGraph);
 fRendererInstance:=aRendererInstance;
 fParent:=aParent;
end;

{ TpvScene3DRendererInstance }

constructor TpvScene3DRendererInstance.Create(const aParent:TpvScene3DRendererBaseObject;const aVirtualReality:TpvVirtualReality;const aExternalImageFormat:TVkFormat);
var InFlightFrameIndex,PerInFlightFrameBufferIndex:TpvSizeInt;
    RenderPass:TpvScene3DRendererRenderPass;
    MaterialAlphaMode:TpvScene3D.TMaterial.TAlphaMode;
    PrimitiveTopology:TpvScene3D.TPrimitiveTopology;
    FaceCullingMode:TpvScene3D.TFaceCullingMode;
begin
 inherited Create(aParent);

 fScene3D:=Renderer.Scene3D;

 fID:=fScene3D.RendererInstanceIDManager.AllocateID;
 if fID=0 then begin
  raise EpvScene3D.Create('Invalid renderer instance ID');
 end else if fID>TpvScene3D.MaxRendererInstances then begin
  raise EpvScene3D.Create('Too many renderer instances for the same TpvScene3D');
 end;
 dec(fID);

 fPasses:=TpvScene3DRendererInstancePasses.Create;

 fExternalImageFormat:=aExternalImageFormat;

 if assigned(aVirtualReality) then begin
  fVirtualReality:=aVirtualReality;
 end else begin
  fVirtualReality:=fScene3D.VirtualReality;
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  fCameraPresets[InFlightFrameIndex]:=TpvScene3DRendererCameraPreset.Create;
 end;

 fCameraPreset:=TpvScene3DRendererCameraPreset.Create;

 fUseDebugBlit:=false;

 fDebugTAAMode:=0;

 // Mesh-cull PASS1 flicker controls: Variante (a) net ON by default, the culling-breaking diagnostic OFF.
 fKeepPass0ForRendering:=true;
 fKeepPass0InPass1:=false;

 // Object-selection outline thickness in reference pixels (at 1080p render height); resolution-scaled in the build pass.
 fSelectionOutlineThickness:=3.0;

 fDebugDDGIProbes:=false;

 fDebugDrawMeshletBoundingSpheres:=false;

 fRawRaytracingFlags:=0;
 fRaytracingSoftShadowSampleCount:=8;
 fRaytracingFlags:=[];

 fFrustumClusterGridSizeX:=16;
 fFrustumClusterGridSizeY:=16;
 fFrustumClusterGridSizeZ:=16;

 fLensRainPostEffectActive:=false;
 fLensRainPostEffectFactor:=0.0;
 fLensRainPostEffectTime:=0.0;

 if assigned(fVirtualReality) then begin

  for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
   fCameraPresets[InFlightFrameIndex].FieldOfView:=fVirtualReality.FOV;
  end;

  fCameraPreset.FieldOfView:=fVirtualReality.FOV;

  fZNear:=fVirtualReality.ZNear;

  fZFar:=fVirtualReality.ZFar;

  fCountSurfaceViews:=fVirtualReality.CountImages;

  fSurfaceMultiviewMask:=fVirtualReality.MultiviewMask;

 end else begin

  for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
   fCameraPresets[InFlightFrameIndex].FieldOfView:=53.13010235415598;
  end;

  fCameraPreset.FieldOfView:=53.13010235415598;

  fZNear:=-0.01;

  fZFar:=-Infinity;

  fCountSurfaceViews:=1;

  fSurfaceMultiviewMask:=1 shl 0;

 end;

 fGPUBatchRanges:=nil;
 fExpandRangeInfos:=nil;
 fPrefixSums:=nil;

 fUseSeparateCommandBufferSlots:=false;
 FillChar(fPassGroupCounterSlotBase,SizeOf(fPassGroupCounterSlotBase),#0);
 if fUseSeparateCommandBufferSlots then begin
  fPassGroupCounterSlotBase[TpvScene3DRendererCullRenderPass.CascadedShadowMap]:=TpvSizeInt(MaxMultiIndirectDrawCalls)*4;
  fPassGroupCounterSlotBase[TpvScene3DRendererCullRenderPass.Voxelization]:=TpvSizeInt(MaxMultiIndirectDrawCalls)*6;
  fPassGroupCounterSlotBase[TpvScene3DRendererCullRenderPass.ReflectionProbe]:=TpvSizeInt(MaxMultiIndirectDrawCalls)*6;
  fPassGroupCounterSlotBase[TpvScene3DRendererCullRenderPass.TopDownSkyOcclusionMap]:=TpvSizeInt(MaxMultiIndirectDrawCalls)*6;
  fPassGroupCounterSlotBase[TpvScene3DRendererCullRenderPass.ReflectiveShadowMap]:=TpvSizeInt(MaxMultiIndirectDrawCalls)*6;
 end;

 fHUDCustomPassClass:=nil;

 fHUDCustomPassParent:=nil;

 fHUDComputePassClass:=nil;

 fHUDComputePassParent:=nil;

 fHUDRenderPassClass:=nil;

 fHUDRenderPassParent:=nil;

 fSizeFactor:=1.0;

 fPostProcessingAtScaledResolution:=true;

 fReflectionProbeWidth:=256;

 fReflectionProbeHeight:=256;

 fTopDownSkyOcclusionMapWidth:=256;

 fTopDownSkyOcclusionMapHeight:=256;

 fReflectiveShadowMapWidth:=2048;

 fReflectiveShadowMapHeight:=2048;

 if Renderer.ShadowMode=TpvScene3DRendererShadowMode.None then begin

  fCascadedShadowMapWidth:=64;

  fCascadedShadowMapHeight:=64;

 end else begin

  fCascadedShadowMapWidth:=Renderer.ShadowMapSize;

  fCascadedShadowMapHeight:=Renderer.ShadowMapSize;

 end;

 fCascadedShadowMapCenter:=TpvVector3.Null;

 fCascadedShadowMapRadius:=Infinity;

 fShadowMaximumDistance:=-1.0;
 fShadowAreaTooSmallThreshold:=-1.0;
 fFinalViewMaximumDistance:=-1.0;
 fFinalViewAreaTooSmallThreshold:=-1.0;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  fCameraViewMatrices[InFlightFrameIndex]:=TpvMatrix4x4.Identity;
 end;

 fPointerToInFlightFrameStates:=@fInFlightFrameStates;

 fMinimumLuminance:=0.0;
 fMaximumLuminance:=16777216.0;
 fLuminanceFactor:=1.0;
 fLuminanceExponent:=1.0;

 fLensFactor:=0.4;
 fBloomFactor:=0.9;
 fLensflareFactor:=0.1;
 fLensNormalization:=true;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin

  fSolidPrimitivePrimitiveDynamicArrays[InFlightFrameIndex]:=TSolidPrimitivePrimitiveDynamicArray.Create;

  fSolidPrimitivePrimitiveBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                              SizeOf(TSolidPrimitivePrimitive)*InitialCountSolidPrimitives,
                                                                              TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT),
                                                                              TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                              [],
                                                                              0,
                                                                              TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                              0,
                                                                              0,
                                                                              'fSolidPrimitivePrimitiveBuffers['+IntToStr(InFlightFrameIndex)+']');

 end;

 for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin
  fSolidPrimitiveIndirectDrawCommandBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                 RoundDownToPowerOfTwo(SizeOf(TVkDrawIndexedIndirectCommand)+16),
                                                                                                 TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                                 TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                 [],
                                                                                                 0,
                                                                                                 TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                 0,
                                                                                                 0,
                                                                                                 0,
                                                                                                 0,
                                                                                                 0,
                                                                                                 0,
                                                                                                 [],
                                                                                                 0,
                                                                                                 0,
                                                                                                 'fSolidPrimitiveIndirectDrawCommandBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');

  fSolidPrimitiveVertexBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                    SizeOf(TSolidPrimitiveVertex)*InitialCountSolidPrimitives*4,
                                                                                    TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                    TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                    [],
                                                                                    0,
                                                                                    TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                    0,
                                                                                    0,
                                                                                    0,
                                                                                    0,
                                                                                    0,
                                                                                    0,
                                                                                    [],
                                                                                    0,
                                                                                    0,
                                                                                    'fSolidPrimitiveVertexBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');

  fSolidPrimitiveIndexBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                   SizeOf(TSolidPrimitiveIndex)*InitialCountSolidPrimitives*6,
                                                                                   TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                   TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                   [],
                                                                                   0,
                                                                                   TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                   0,
                                                                                   0,
                                                                                   0,
                                                                                   0,
                                                                                   0,
                                                                                   0,
                                                                                   [],
                                                                                   0,
                                                                                   0,
                                                                                   'fSolidPrimitiveIndexBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');

 end;

 if not fScene3D.UsePerInFlightFrameResources then begin
  for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
   fSolidPrimitiveIndirectDrawCommandBuffers[PerInFlightFrameBufferIndex]:=fSolidPrimitiveIndirectDrawCommandBuffers[0];
   fSolidPrimitiveVertexBuffers[PerInFlightFrameBufferIndex]:=fSolidPrimitiveVertexBuffers[0];
   fSolidPrimitiveIndexBuffers[PerInFlightFrameBufferIndex]:=fSolidPrimitiveIndexBuffers[0];
  end;
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin

  fSpaceLinesPrimitiveDynamicArrays[InFlightFrameIndex]:=TSpaceLinesPrimitiveDynamicArray.Create;

  fSpaceLinesPrimitiveBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                          SizeOf(TSpaceLinesPrimitive)*InitialCountSpaceLines,
                                                                          TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT),
                                                                          TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                          [],
                                                                          0,
                                                                          TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                          0,
                                                                          0,
                                                                          'fSpaceLinesPrimitiveBuffers['+IntToStr(InFlightFrameIndex)+']');

 end;

 for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin
  fSpaceLinesIndirectDrawCommandBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                             RoundDownToPowerOfTwo(SizeOf(TVkDrawIndexedIndirectCommand)+16),
                                                                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                             TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                             [],
                                                                                             0,
                                                                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                             0,
                                                                                             0,
                                                                                             0,
                                                                                             0,
                                                                                             0,
                                                                                             0,
                                                                                             [],
                                                                                             0,
                                                                                             0,
                                                                                             'fSpaceLinesIndirectDrawCommandBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');

  fSpaceLinesVertexBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                SizeOf(TSpaceLinesVertex)*InitialCountSpaceLines*4,
                                                                                TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                [],
                                                                                0,
                                                                                TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                [],
                                                                                0,
                                                                                0,
                                                                                'fSpaceLinesVertexBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');

  fSpaceLinesIndexBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                               SizeOf(TSpaceLinesIndex)*InitialCountSpaceLines*6,
                                                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                               [],
                                                                               0,
                                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                               0,
                                                                               0,
                                                                               0,
                                                                               0,
                                                                               0,
                                                                               0,
                                                                               [],
                                                                               0,
                                                                               0,
                                                                               'fSpaceLinesIndexBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');

 end;

 if not fScene3D.UsePerInFlightFrameResources then begin
  for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
   fSpaceLinesIndirectDrawCommandBuffers[PerInFlightFrameBufferIndex]:=fSpaceLinesIndirectDrawCommandBuffers[0];
   fSpaceLinesVertexBuffers[PerInFlightFrameBufferIndex]:=fSpaceLinesVertexBuffers[0];
   fSpaceLinesIndexBuffers[PerInFlightFrameBufferIndex]:=fSpaceLinesIndexBuffers[0];
  end;
 end;

 fFrameGraph:=TpvFrameGraph.Create(Renderer.VulkanDevice,Renderer.CountInFlightFrames);

 fFrameGraph.CanDoParallelProcessing:=false;

 fFrameGraph.SurfaceIsSwapchain:=(fExternalImageFormat=VK_FORMAT_UNDEFINED) and not assigned(fVirtualReality);

 if fFrameGraph.SurfaceIsSwapchain then begin
  fExternalOutputImageData:=nil;
 end else begin
  fExternalOutputImageData:=TpvFrameGraph.TExternalImageData.Create(fFrameGraph);
 end;

 fHasExternalOutputImage:=(fExternalImageFormat<>VK_FORMAT_UNDEFINED) and not assigned(fVirtualReality);

 fFrameGraph.DefaultResourceInstanceType:=TpvFrameGraph.TResourceInstanceType.SingleInstance;

 fColorGradingSettings:=DefaultColorGradingSettings;

 fPointerToColorGradingSettings:=@fColorGradingSettings;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  fPerInFlightFrameColorGradingSettings[InFlightFrameIndex]:=DefaultColorGradingSettings;
 end;

 fPointerToPerInFlightFrameColorGradingSettings:=@fPerInFlightFrameColorGradingSettings;

 FillChar(fInFlightFrameStates,SizeOf(TInFlightFrameStates),#0);

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  fViews[InFlightFrameIndex].Initialize;
  fLastUploadedViews[InFlightFrameIndex].Initialize;
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  fVulkanRenderSemaphores[InFlightFrameIndex]:=TpvVulkanSemaphore.Create(Renderer.VulkanDevice);
 end;

 FillChar(fCascadedShadowMapVulkanUniformBuffers,SizeOf(TCascadedShadowMapVulkanUniformBuffers),#0);

 FillChar(fCloudsShadowMapVulkanBuffers,SizeOf(TCloudsShadowMapVulkanBuffers),#0);

 FillChar(fInFlightFrameCascadedRadianceHintVolumeImages,SizeOf(TInFlightFrameCascadedRadianceHintVolumeImages),#0);

 FillChar(fInFlightFrameCascadedRadianceHintVolumeSecondBounceImages,SizeOf(TInFlightFrameCascadedRadianceHintVolumeImages),#0);

 FillChar(fGlobalIlluminationRadianceHintsUniformBuffers,SizeOf(TGlobalIlluminationRadianceHintsUniformBuffers),#0);

 FillChar(fGlobalIlluminationRadianceHintsRSMUniformBuffers,SizeOf(TGlobalIlluminationRadianceHintsRSMUniformBuffers),#0);

 FillChar(fGlobalIlluminationRadianceHintsEvents,SizeOf(fGlobalIlluminationRadianceHintsEvents),#0);

 fParticleBVH:=nil;

 fGlobalIlluminationRadianceHintsCascadedVolumes:=nil;

 FillChar(fGlobalIlluminationRadianceHintsDescriptorSets,SizeOf(TGlobalIlluminationRadianceHintsDescriptorSets),#0);

 FillChar(fGlobalIlluminationDDGIProbeBaseCells,SizeOf(fGlobalIlluminationDDGIProbeBaseCells),#0);

 fGlobalIlluminationDDGICascadedVolumes:=nil;
 FillChar(fGlobalIlluminationDDGIIrradianceSHBuffers,SizeOf(TGlobalIlluminationDDGIBuffers),#0);
 FillChar(fGlobalIlluminationDDGIIrradianceOctImages,SizeOf(TGlobalIlluminationDDGIImage2Ds),#0);
 FillChar(fGlobalIlluminationDDGIVisibilityMomentsImages,SizeOf(TGlobalIlluminationDDGIImage2Ds),#0);
 FillChar(fGlobalIlluminationDDGIVisibilitySkyImages,SizeOf(TGlobalIlluminationDDGIImage2Ds),#0);
 FillChar(fGlobalIlluminationDDGIGlossyImages,SizeOf(TGlobalIlluminationDDGIImage2Ds),#0);
 FillChar(fGlobalIlluminationDDGIRayDataBuffers,SizeOf(TGlobalIlluminationDDGIBuffers),#0);
 FillChar(fGlobalIlluminationDDGIMasterBuffers,SizeOf(TGlobalIlluminationDDGIBuffers),#0);
 FillChar(fGlobalIlluminationDDGIProbeDataBuffers,SizeOf(TGlobalIlluminationDDGIBuffers),#0);
 FillChar(fGlobalIlluminationDDGIAgeBuffers,SizeOf(TGlobalIlluminationDDGIBuffers),#0);
 fGlobalIlluminationDDGIDescriptorPool:=nil;
 fGlobalIlluminationDDGIDescriptorSetLayout:=nil;
 FillChar(fGlobalIlluminationDDGIDescriptorSets,SizeOf(TGlobalIlluminationDDGIDescriptorSets),#0);

 FillChar(fGlobalIlluminationSurfelUniformBuffers,SizeOf(TGlobalIlluminationSurfelUniformBuffers),#0);
 fGlobalIlluminationSurfelPoolBuffer:=nil;
 fGlobalIlluminationSurfelGridCellBuffer:=nil;
 fGlobalIlluminationSurfelGridCellCountBuffer:=nil;
 fGlobalIlluminationSurfelStatsBuffer:=nil;
 fGlobalIlluminationSurfelFreeListBuffer:=nil;
 fGlobalIlluminationSurfelDescriptorPool:=nil;
 fGlobalIlluminationSurfelDescriptorSetLayout:=nil;
 FillChar(fGlobalIlluminationSurfelDescriptorSets,SizeOf(TGlobalIlluminationSurfelDescriptorSets),#0);

 fGlobalIlluminationRadianceHintsDescriptorPool:=nil;

 fGlobalIlluminationRadianceHintsDescriptorSetLayout:=nil;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  fGlobalIlluminationRadianceHintsFirsts[InFlightFrameIndex]:=true;
 end;

 fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes:=nil;

 FillChar(fGlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray,SizeOf(TGlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray),#0);

 FillChar(fGlobalIlluminationCascadedVoxelConeTracingUniformBuffers,SizeOf(TGlobalIlluminationCascadedVoxelConeTracingBuffers),#0);

 FillChar(fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffers,SizeOf(TpvVulkanInFlightFrameBuffers),#0);

 FillChar(fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers,SizeOf(TpvVulkanInFlightFrameBuffers),#0);

 FillChar(fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages,SizeOf(TGlobalIlluminationCascadedVoxelConeTracingImages),#0);

 FillChar(fGlobalIlluminationCascadedVoxelConeTracingRadianceImages,SizeOf(TGlobalIlluminationCascadedVoxelConeTracingSideImages),#0);
 FillChar(fGlobalIlluminationCascadedVoxelConeTracingVisualizationImages,SizeOf(TGlobalIlluminationCascadedVoxelConeTracingSideImages),#0);

 FillChar(fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets,SizeOf(TGlobalIlluminationCascadedVoxelConeTracingDescriptorSets),#0);

 fGlobalIlluminationCascadedVoxelConeTracingDebugVisualization:=false;

 fDrawMeshletDebugColors:=false;

 fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool:=nil;
 fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout:=nil;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  fCascadedShadowMapVulkanUniformBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                     SizeOf(TCascadedShadowMapUniformBuffer),
                                                                                     TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                                                     TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                     [],
                                                                                     TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                     TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                     0,
                                                                                     0,
                                                                                     0,
                                                                                     0,
                                                                                     0,
                                                                                     0,
                                                                                     [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                                     0,
                                                                                     pvAllocationGroupIDScene3DStatic,
                                                                                     'TpvScene3DRendererInstance.fCascadedShadowMapVulkanUniformBuffers['+IntToStr(InFlightFrameIndex)+']');
  Renderer.VulkanDevice.DebugUtils.SetObjectName(fCascadedShadowMapVulkanUniformBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fCascadedShadowMapVulkanUniformBuffers['+IntToStr(InFlightFrameIndex)+']');
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  fCloudsShadowMapVulkanBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                            SizeOf(TCloudsShadowMapData),
                                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or
                                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or
                                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT_KHR),
                                                                            TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                            [],
                                                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                            0,
                                                                            pvAllocationGroupIDScene3DStatic,
                                                                            'TpvScene3DRendererInstance.fCloudsShadowMapVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');
  Renderer.VulkanDevice.DebugUtils.SetObjectName(fCloudsShadowMapVulkanBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fCloudsShadowMapVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');
 end;

 case Renderer.TransparencyMode of
  TpvScene3DRendererTransparencyMode.SPINLOCKOIT,
  TpvScene3DRendererTransparencyMode.INTERLOCKOIT:begin
   for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin
    fLockOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                              SizeOf(TLockOrderIndependentTransparentUniformBuffer),
                                                                                                              TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                                                                              TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                              [],
                                                                                                              TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                              0,
                                                                                                              0,
                                                                                                              TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                              0,
                                                                                                              0,
                                                                                                              0,
                                                                                                              0,
                                                                                                              [],
                                                                                                              0,
                                                                                                              pvAllocationGroupIDScene3DStatic,
                                                                                                              'TpvScene3DRendererInstance.fLockOrderIndependentTransparentUniformVulkanBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLockOrderIndependentTransparentUniformVulkanBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');
   end;
   if not fScene3D.UsePerInFlightFrameResources then begin
    for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
     fLockOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex]:=fLockOrderIndependentTransparentUniformVulkanBuffers[0];
    end;
   end;
  end;
  TpvScene3DRendererTransparencyMode.LOOPOIT:begin
   for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin
    fLoopOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                              SizeOf(TLoopOrderIndependentTransparentUniformBuffer),
                                                                                                              TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                                                                              TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                              [],
                                                                                                              TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                              0,
                                                                                                              0,
                                                                                                              TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                              0,
                                                                                                              0,
                                                                                                              0,
                                                                                                              0,
                                                                                                              [],
                                                                                                              0,
                                                                                                              pvAllocationGroupIDScene3DStatic,
                                                                                                              'TpvScene3DRendererInstance.fLoopOrderIndependentTransparentUniformVulkanBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fLoopOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLoopOrderIndependentTransparentUniformVulkanBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');
   end;
   if not fScene3D.UsePerInFlightFrameResources then begin
    for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
     fLoopOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex]:=fLoopOrderIndependentTransparentUniformVulkanBuffers[0];
    end;
   end;
  end;
  TpvScene3DRendererTransparencyMode.WBOIT,
  TpvScene3DRendererTransparencyMode.MBOIT:begin
   for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin
    fApproximationOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                                       SizeOf(TApproximationOrderIndependentTransparentUniformBuffer),
                                                                                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                                                                                       TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                                       [],
                                                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                                       0,
                                                                                                                       0,
                                                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                                       0,
                                                                                                                       0,
                                                                                                                       0,
                                                                                                                       0,
                                                                                                                       [],
                                                                                                                       0,
                                                                                                                       pvAllocationGroupIDScene3DStatic,
                                                                                                                       'TpvScene3DRendererInstance.fApproximationOrderIndependentTransparentUniformVulkanBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fApproximationOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fApproximationOrderIndependentTransparentUniformVulkanBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');
   end;
   if not fScene3D.UsePerInFlightFrameResources then begin
    for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
     fApproximationOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex]:=fApproximationOrderIndependentTransparentUniformVulkanBuffers[0];
    end;
   end;
  end;
  else begin
  end;
 end;

 case fScene3D.BufferStreamingMode of

  TpvScene3D.TBufferStreamingMode.Direct:begin

   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
    fVulkanViewUniformBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                          SizeOf(TpvScene3D.TViewUniformBuffer),
                                                                          TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                                          TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                          [],
                                                                          TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                          TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          [TpvVulkanBufferFlag.PersistentMapped],
                                                                          0,
                                                                          pvAllocationGroupIDScene3DStatic,
                                                                          'TpvScene3DRendererInstance.fVulkanViewUniformBuffers['+IntToStr(InFlightFrameIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fVulkanViewUniformBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fVulkanViewUniformBuffers['+IntToStr(InFlightFrameIndex)+']');
   end;

  end;

  TpvScene3D.TBufferStreamingMode.Staging:begin

   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
    fVulkanViewUniformBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                          SizeOf(TpvScene3D.TViewUniformBuffer),
                                                                          TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                                          TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                          [],
                                                                          TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                          0,
                                                                          0,
                                                                          TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          [],
                                                                          0,
                                                                          pvAllocationGroupIDScene3DStatic,
                                                                          'TpvScene3DRendererInstance.fVulkanViewUniformBuffers['+IntToStr(InFlightFrameIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fVulkanViewUniformBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fVulkanViewUniformBuffers['+IntToStr(InFlightFrameIndex)+']');
   end;

  end;

  else begin
   Assert(false);
  end;

 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  fColorGradingSettingUniformBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                 SizeOf(TpvScene3DRendererInstanceColorGradingSettings),
                                                                                 TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                                                 TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                 [],
                                                                                 TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                 TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                 0,
                                                                                 0,
                                                                                 0,
                                                                                 0,
                                                                                 0,
                                                                                 0,
                                                                                 [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                                 0,
                                                                                 pvAllocationGroupIDScene3DStatic,
                                                                                 'TpvScene3DRendererInstance.fColorGradingSettingUniformBuffers['+IntToStr(InFlightFrameIndex)+']');
  Renderer.VulkanDevice.DebugUtils.SetObjectName(fColorGradingSettingUniformBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fColorGradingSettingUniformBuffers['+IntToStr(InFlightFrameIndex)+']');
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  for RenderPass:=TpvScene3DRendererRenderPassFirst to TpvScene3DRendererRenderPassLast do begin
   for MaterialAlphaMode:=Low(TpvScene3D.TMaterial.TAlphaMode) to High(TpvScene3D.TMaterial.TAlphaMode) do begin
    for PrimitiveTopology:=Low(TpvScene3D.TPrimitiveTopology) to high(TpvScene3D.TPrimitiveTopology) do begin
     for FaceCullingMode:=Low(TpvScene3D.TFaceCullingMode) to high(TpvScene3D.TFaceCullingMode) do begin
      fDrawChoreographyBatchItemFrameBuckets[InFlightFrameIndex,RenderPass,MaterialAlphaMode,PrimitiveTopology,FaceCullingMode]:=TpvScene3D.TDrawChoreographyBatchItems.Create(false);
     end;
    end;
   end;
  end;
 end;

 fPrepareDrawRenderInstanceFillTasks.Initialize;

 for InFlightFrameIndex:=0 to MaxInFlightFrames-1 do begin
  fCachedDrawDataGeneration[InFlightFrameIndex]:=High(TPasMPUInt64);
  fSnapshotDrawDataGeneration[InFlightFrameIndex]:=High(TPasMPUInt64);
 end;

 fLeft:=0;
 fTop:=0;
 fWidth:=1024;
 fHeight:=768;

 fMeshFragmentSpecializationConstants.UseReversedZ:=IfThen(fZFar<0.0,VK_TRUE,VK_FALSE);

 fCascadedShadowMapBuilder:=TCascadedShadowMapBuilder.Create(self);

 fImageBasedLightingReflectionProbeCubeMaps:=nil;

 fWaterExternalWaitingOnSemaphore:=nil;

 fAtmosphereExternalWaitingOnSemaphore:=nil;

 FillChar(fWaterSimulationSemaphores,SizeOf(TInFlightFrameSemaphores),#0);

 if fScene3D.PlanetWaterSimulationUseParallelQueue then begin
  for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
   fWaterSimulationSemaphores[InFlightFrameIndex]:=TpvVulkanSemaphore.Create(Renderer.VulkanDevice,TVkSemaphoreCreateFlags(0));
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fWaterSimulationSemaphores[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_SEMAPHORE,'TpvScene3DRendererInstance.fWaterSimulationSemaphores['+IntToStr(InFlightFrameIndex)+']');
  end;
 end;

 FillChar(fAtmospherePrecipitationSimulationSemaphores,SizeOf(TInFlightFrameSemaphores),#0);

 if fScene3D.PlanetAtmospherePrecipitationSimulationUseParallelQueue then begin
  for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
   fAtmospherePrecipitationSimulationSemaphores[InFlightFrameIndex]:=TpvVulkanSemaphore.Create(Renderer.VulkanDevice,TVkSemaphoreCreateFlags(0));
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fAtmospherePrecipitationSimulationSemaphores[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_SEMAPHORE,'TpvScene3DRendererInstance.fAtmospherePrecipitationSimulationSemaphores['+IntToStr(InFlightFrameIndex)+']');
  end;
 end;

end;

destructor TpvScene3DRendererInstance.Destroy;
var InFlightFrameIndex,CascadeIndex,ImageIndex,PerInFlightFrameBufferIndex:TpvSizeInt;
    RenderPass:TpvScene3DRendererRenderPass;
    MaterialAlphaMode:TpvScene3D.TMaterial.TAlphaMode;
    PrimitiveTopology:TpvScene3D.TPrimitiveTopology;
    FaceCullingMode:TpvScene3D.TFaceCullingMode;
begin

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fWaterSimulationSemaphores[InFlightFrameIndex]);
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fAtmospherePrecipitationSimulationSemaphores[InFlightFrameIndex]);
 end;

 FreeAndNil(fWaterExternalWaitingOnSemaphore);

 FreeAndNil(fAtmosphereExternalWaitingOnSemaphore);

 FreeAndNil(fFrameGraph);

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fSolidPrimitivePrimitiveDynamicArrays[InFlightFrameIndex]);
  FreeAndNil(fSolidPrimitivePrimitiveBuffers[InFlightFrameIndex]);
 end;

 if fScene3D.UsePerInFlightFrameResources then begin
  for PerInFlightFrameBufferIndex:=0 to MaxInFlightFrames-1 do begin
   FreeAndNil(fSolidPrimitiveIndirectDrawCommandBuffers[PerInFlightFrameBufferIndex]);
   FreeAndNil(fSolidPrimitiveVertexBuffers[PerInFlightFrameBufferIndex]);
   FreeAndNil(fSolidPrimitiveIndexBuffers[PerInFlightFrameBufferIndex]);
  end;
 end else begin
  FreeAndNil(fSolidPrimitiveIndirectDrawCommandBuffers[0]);
  FreeAndNil(fSolidPrimitiveVertexBuffers[0]);
  FreeAndNil(fSolidPrimitiveIndexBuffers[0]);
  for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
   fSolidPrimitiveIndirectDrawCommandBuffers[PerInFlightFrameBufferIndex]:=nil;
   fSolidPrimitiveVertexBuffers[PerInFlightFrameBufferIndex]:=nil;
   fSolidPrimitiveIndexBuffers[PerInFlightFrameBufferIndex]:=nil;
  end;
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fSpaceLinesPrimitiveDynamicArrays[InFlightFrameIndex]);
  FreeAndNil(fSpaceLinesPrimitiveBuffers[InFlightFrameIndex]);
 end;

 if fScene3D.UsePerInFlightFrameResources then begin
  for PerInFlightFrameBufferIndex:=0 to MaxInFlightFrames-1 do begin
   FreeAndNil(fSpaceLinesIndirectDrawCommandBuffers[PerInFlightFrameBufferIndex]);
   FreeAndNil(fSpaceLinesVertexBuffers[PerInFlightFrameBufferIndex]);
   FreeAndNil(fSpaceLinesIndexBuffers[PerInFlightFrameBufferIndex]);
  end;
 end else begin
  FreeAndNil(fSpaceLinesIndirectDrawCommandBuffers[0]);
  FreeAndNil(fSpaceLinesVertexBuffers[0]);
  FreeAndNil(fSpaceLinesIndexBuffers[0]);
  for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
   fSpaceLinesIndirectDrawCommandBuffers[PerInFlightFrameBufferIndex]:=nil;
   fSpaceLinesVertexBuffers[PerInFlightFrameBufferIndex]:=nil;
   fSpaceLinesIndexBuffers[PerInFlightFrameBufferIndex]:=nil;
  end;
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  fViews[InFlightFrameIndex].Finalize;
  fLastUploadedViews[InFlightFrameIndex].Finalize;
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fVulkanViewUniformBuffers[InFlightFrameIndex]);
 end;

 FreeAndNil(fCascadedShadowMapBuilder);

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fColorGradingSettingUniformBuffers[InFlightFrameIndex]);
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fVulkanRenderSemaphores[InFlightFrameIndex]);
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fCascadedShadowMapVulkanUniformBuffers[InFlightFrameIndex]);
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fCloudsShadowMapVulkanBuffers[InFlightFrameIndex]);
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  for CascadeIndex:=0 to CountGlobalIlluminationRadiantHintCascades-1 do begin
   for ImageIndex:=0 to CountGlobalIlluminationRadiantHintVolumeImages-1 do begin
    FreeAndNil(fInFlightFrameCascadedRadianceHintVolumeImages[InFlightFrameIndex,CascadeIndex,ImageIndex]);
    FreeAndNil(fInFlightFrameCascadedRadianceHintVolumeSecondBounceImages[InFlightFrameIndex,CascadeIndex,ImageIndex]);
   end;
  end;
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fGlobalIlluminationRadianceHintsDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fGlobalIlluminationRadianceHintsUniformBuffers[InFlightFrameIndex]);
  FreeAndNil(fGlobalIlluminationRadianceHintsRSMUniformBuffers[InFlightFrameIndex]);
  FreeAndNil(fGlobalIlluminationRadianceHintsEvents[InFlightFrameIndex]);
 end;

 FreeAndNil(fGlobalIlluminationRadianceHintsDescriptorSetLayout);

 FreeAndNil(fGlobalIlluminationRadianceHintsDescriptorPool);

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fGlobalIlluminationDDGIIrradianceSHBuffers[InFlightFrameIndex]);
  FreeAndNil(fGlobalIlluminationDDGIIrradianceOctImages[InFlightFrameIndex]);
  FreeAndNil(fGlobalIlluminationDDGIVisibilityMomentsImages[InFlightFrameIndex]);
  FreeAndNil(fGlobalIlluminationDDGIVisibilitySkyImages[InFlightFrameIndex]);
  FreeAndNil(fGlobalIlluminationDDGIGlossyImages[InFlightFrameIndex]);
  FreeAndNil(fGlobalIlluminationDDGIRayDataBuffers[InFlightFrameIndex]);
  FreeAndNil(fGlobalIlluminationDDGIMasterBuffers[InFlightFrameIndex]);
  FreeAndNil(fGlobalIlluminationDDGIProbeDataBuffers[InFlightFrameIndex]);
  FreeAndNil(fGlobalIlluminationDDGIAgeBuffers[InFlightFrameIndex]);
  FreeAndNil(fGlobalIlluminationDDGIDescriptorSets[InFlightFrameIndex]);
 end;
 FreeAndNil(fGlobalIlluminationDDGIDescriptorSetLayout);
 FreeAndNil(fGlobalIlluminationDDGIDescriptorPool);
 FreeAndNil(fGlobalIlluminationDDGICascadedVolumes);

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fGlobalIlluminationSurfelDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fGlobalIlluminationSurfelUniformBuffers[InFlightFrameIndex]);
 end;
 FreeAndNil(fGlobalIlluminationSurfelDescriptorSetLayout);
 FreeAndNil(fGlobalIlluminationSurfelDescriptorPool);
 FreeAndNil(fGlobalIlluminationSurfelPoolBuffer);
 FreeAndNil(fGlobalIlluminationSurfelGridCellBuffer);
 FreeAndNil(fGlobalIlluminationSurfelGridCellCountBuffer);
 FreeAndNil(fGlobalIlluminationSurfelStatsBuffer);
 FreeAndNil(fGlobalIlluminationSurfelFreeListBuffer);

 FreeAndNil(fGlobalIlluminationRadianceHintsCascadedVolumes);

 FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes);

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingUniformBuffers[InFlightFrameIndex]);
 end;

 for CascadeIndex:=0 to 7 do begin
//FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingAtomicImages[CascadeIndex]);
  FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages[CascadeIndex]);
  for ImageIndex:=0 to 5 do begin
   FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingRadianceImages[CascadeIndex,ImageIndex]);
   FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingVisualizationImages[CascadeIndex,ImageIndex]);
  end;
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingEvents[InFlightFrameIndex]);
 end;

 if fScene3D.UsePerInFlightFrameResources then begin
  for PerInFlightFrameBufferIndex:=0 to MaxInFlightFrames-1 do begin
   FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffers[PerInFlightFrameBufferIndex]);
   FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers[PerInFlightFrameBufferIndex]);
  end;
 end else begin
  FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffers[0]);
  FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers[0]);
  for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
   fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffers[PerInFlightFrameBufferIndex]:=nil;
   fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers[PerInFlightFrameBufferIndex]:=nil;
  end;
 end;

 FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes);

 FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool);

 FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout);

 FreeAndNil(fParticleBVH);

 FreeAndNil(fImageBasedLightingReflectionProbeCubeMaps);

 case Renderer.TransparencyMode of
  TpvScene3DRendererTransparencyMode.SPINLOCKOIT,
  TpvScene3DRendererTransparencyMode.INTERLOCKOIT:begin
   if fScene3D.UsePerInFlightFrameResources then begin
    for PerInFlightFrameBufferIndex:=0 to MaxInFlightFrames-1 do begin
     FreeAndNil(fLockOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex]);
    end;
   end else begin
    FreeAndNil(fLockOrderIndependentTransparentUniformVulkanBuffers[0]);
    for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
     fLockOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex]:=nil;
    end;
   end;
  end;
  TpvScene3DRendererTransparencyMode.LOOPOIT:begin
   if fScene3D.UsePerInFlightFrameResources then begin
    for PerInFlightFrameBufferIndex:=0 to MaxInFlightFrames-1 do begin
     FreeAndNil(fLoopOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex]);
    end;
   end else begin
    FreeAndNil(fLoopOrderIndependentTransparentUniformVulkanBuffers[0]);
    for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
     fLoopOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex]:=nil;
    end;
   end;
  end;
  TpvScene3DRendererTransparencyMode.WBOIT,
  TpvScene3DRendererTransparencyMode.MBOIT:begin
   if fScene3D.UsePerInFlightFrameResources then begin
    for PerInFlightFrameBufferIndex:=0 to MaxInFlightFrames-1 do begin
     FreeAndNil(fApproximationOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex]);
    end;
   end else begin
    FreeAndNil(fApproximationOrderIndependentTransparentUniformVulkanBuffers[0]);
    for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
     fApproximationOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex]:=nil;
    end;
   end;
  end;
  else begin
  end;
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  for RenderPass:=TpvScene3DRendererRenderPassFirst to TpvScene3DRendererRenderPassLast do begin
   for MaterialAlphaMode:=Low(TpvScene3D.TMaterial.TAlphaMode) to High(TpvScene3D.TMaterial.TAlphaMode) do begin
    for PrimitiveTopology:=Low(TpvScene3D.TPrimitiveTopology) to high(TpvScene3D.TPrimitiveTopology) do begin
     for FaceCullingMode:=Low(TpvScene3D.TFaceCullingMode) to high(TpvScene3D.TFaceCullingMode) do begin
      FreeAndNil(fDrawChoreographyBatchItemFrameBuckets[InFlightFrameIndex,RenderPass,MaterialAlphaMode,PrimitiveTopology,FaceCullingMode]);
     end;
    end;
   end;
  end;
 end;

 fPrepareDrawRenderInstanceFillTasks.Finalize;

 FreeAndNil(fPasses);

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fCameraPresets[InFlightFrameIndex]);
 end;

 FreeAndNil(fCameraPreset);

 fScene3D.RendererInstanceIDManager.FreeID(fID+1);

 fGPUBatchRanges:=nil;
 fExpandRangeInfos:=nil;
 fPrefixSums:=nil;

 inherited Destroy;

end;

procedure TpvScene3DRendererInstance.AfterConstruction;
begin
 inherited AfterConstruction;
 if assigned(fScene3D) and assigned(fScene3D.RendererInstanceLock) and assigned(fScene3D.RendererInstanceList) then begin
  fScene3D.RendererInstanceLock.Acquire;
  try
   fRendererInstanceIndex:=fScene3D.RendererInstanceList.Count;
   fScene3D.RendererInstanceList.Add(self);
  finally
   fScene3D.RendererInstanceLock.Release;
  end;
 end;
end;

procedure TpvScene3DRendererInstance.BeforeDestruction;
var OtherIndex:TpvSizeInt;
    OtherInstance:TpvScene3DRendererInstance;
begin
 if assigned(fScene3D) and assigned(fScene3D.RendererInstanceLock) and assigned(fScene3D.RendererInstanceList) then begin
  fScene3D.RendererInstanceLock.Acquire;
  try
   fScene3D.RendererInstanceList.RemoveWithoutFree(self);
   for OtherIndex:=0 to fScene3D.RendererInstanceList.Count-1 do begin
    OtherInstance:=TpvScene3DRendererInstance(fScene3D.RendererInstanceList.Items[OtherIndex]);
    OtherInstance.fRendererInstanceIndex:=OtherIndex;
   end;
  finally
   fScene3D.RendererInstanceLock.Release;
  end;
 end;
 inherited BeforeDestruction;
end;

function TpvScene3DRendererInstance.GetPixelAmountFactor:TpvDouble;
begin
 result:=sqr(fSizeFactor);
end;

procedure TpvScene3DRendererInstance.SetPixelAmountFactor(const aPixelAmountFactor:TpvDouble);
begin
 fSizeFactor:=sqrt(aPixelAmountFactor);
end;

procedure TpvScene3DRendererInstance.SetRaytracingFlags(const aRaytracingFlags:TRaytracingFlags);
begin
 if fRaytracingFlags<>aRaytracingFlags then begin
  fRaytracingFlags:=aRaytracingFlags;
 end;
end;

procedure TpvScene3DRendererInstance.CheckSolidPrimitives(const aInFlightFrameIndex:TpvInt32);
var Size:TVkSize;
    CountSolidPrimitives,PerInFlightFrameBufferIndex:TpvSizeInt;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 if fScene3D.UsePerInFlightFrameResources then begin
  PerInFlightFrameBufferIndex:=aInFlightFrameIndex;
 end else begin
  PerInFlightFrameBufferIndex:=0;
 end;

 CountSolidPrimitives:=Min(TVkSize(fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex].Count),TVkSize(MaxSolidPrimitives));

 Size:=CountSolidPrimitives*SizeOf(TSolidPrimitivePrimitive);
 if fSolidPrimitivePrimitiveBuffers[aInFlightFrameIndex].Size<Size then begin
  Size:=(CountSolidPrimitives+((CountSolidPrimitives+1) shr 1))*SizeOf(TSolidPrimitivePrimitive);
  fScene3D.AddToFreeQueue(fSolidPrimitivePrimitiveBuffers[aInFlightFrameIndex]); // Free old buffer delayed due to possible usage in the current moment
  fSolidPrimitivePrimitiveBuffers[aInFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                               Size,
                                                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT),
                                                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                               [],
                                                                               0,
                                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                               0,
                                                                               0,
                                                                               0,
                                                                               0,
                                                                               0,
                                                                               0,
                                                                               [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                               0,
                                                                               0,
                                                                               'fSolidPrimitivePrimitiveBuffers['+IntToStr(aInFlightFrameIndex)+']');

 end;

 Size:=(CountSolidPrimitives*4)*SizeOf(TSolidPrimitiveVertex);
 if fSolidPrimitiveVertexBuffers[PerInFlightFrameBufferIndex].Size<Size then begin
  Size:=((CountSolidPrimitives+((CountSolidPrimitives+1) shr 1))*4)*SizeOf(TSolidPrimitiveVertex);
  fScene3D.AddToFreeQueue(fSolidPrimitiveVertexBuffers[PerInFlightFrameBufferIndex]); // Free old buffer delayed due to possible usage in the current moment
  fSolidPrimitiveVertexBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                    Size,
                                                                                    TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                    TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                    [],
                                                                                    0,
                                                                                    TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                    0,
                                                                                    0,
                                                                                    0,
                                                                                    0,
                                                                                    0,
                                                                                    0,
                                                                                    [],
                                                                                    0,
                                                                                    0,
                                                                                    'fSolidPrimitiveVertexBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');
 end;

 Size:=(CountSolidPrimitives*6)*SizeOf(TSolidPrimitiveIndex);
 if fSolidPrimitiveIndexBuffers[PerInFlightFrameBufferIndex].Size<Size then begin
  Size:=((CountSolidPrimitives+((CountSolidPrimitives+1) shr 1))*6)*SizeOf(TSolidPrimitiveIndex);
  fScene3D.AddToFreeQueue(fSolidPrimitiveIndexBuffers[PerInFlightFrameBufferIndex]); // Free old buffer delayed due to possible usage in the current moment
  fSolidPrimitiveIndexBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                           Size,
                                                                           TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                           TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                           [],
                                                                           0,
                                                                           TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                           0,
                                                                           0,
                                                                           0,
                                                                           0,
                                                                           0,
                                                                           0,
                                                                           [],
                                                                           0,
                                                                           0,
                                                                           'fSolidPrimitiveIndexBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');
 end;

 if not fScene3D.UsePerInFlightFrameResources then begin
  for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
   fSolidPrimitiveVertexBuffers[PerInFlightFrameBufferIndex]:=fSolidPrimitiveVertexBuffers[0];
   fSolidPrimitiveIndexBuffers[PerInFlightFrameBufferIndex]:=fSolidPrimitiveIndexBuffers[0];
  end;
 end;

end;

procedure TpvScene3DRendererInstance.CheckSpaceLines(const aInFlightFrameIndex:TpvInt32);
var Size:TVkSize;
    CountSpaceLines,PerInFlightFrameBufferIndex:TpvSizeInt;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 if fScene3D.UsePerInFlightFrameResources then begin
  PerInFlightFrameBufferIndex:=aInFlightFrameIndex;
 end else begin
  PerInFlightFrameBufferIndex:=0;
 end;

 CountSpaceLines:=Min(TVkSize(fSpaceLinesPrimitiveDynamicArrays[aInFlightFrameIndex].Count),TVkSize(MaxSpaceLines));

 Size:=CountSpaceLines*SizeOf(TSpaceLinesPrimitive);
 if fSpaceLinesPrimitiveBuffers[aInFlightFrameIndex].Size<Size then begin
  Size:=(CountSpaceLines+((CountSpaceLines+1) shr 1))*SizeOf(TSpaceLinesPrimitive);
  fScene3D.AddToFreeQueue(fSpaceLinesPrimitiveBuffers[aInFlightFrameIndex]); // Free old buffer delayed due to possible usage in the current moment
  fSpaceLinesPrimitiveBuffers[aInFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                           Size,
                                                                           TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT),
                                                                           TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                           [],
                                                                           0,
                                                                           TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                           0,
                                                                           0,
                                                                           0,
                                                                           0,
                                                                           0,
                                                                           0,
                                                                           [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                           0,
                                                                           0,
                                                                           'fSpaceLinePrimitiveBuffers['+IntToStr(aInFlightFrameIndex)+']');

 end;

 Size:=(CountSpaceLines*4)*SizeOf(TSpaceLinesVertex);
 if fSpaceLinesVertexBuffers[PerInFlightFrameBufferIndex].Size<Size then begin
  Size:=((CountSpaceLines+((CountSpaceLines+1) shr 1))*4)*SizeOf(TSpaceLinesVertex);
  fScene3D.AddToFreeQueue(fSpaceLinesVertexBuffers[PerInFlightFrameBufferIndex]); // Free old buffer delayed due to possible usage in the current moment
  fSpaceLinesVertexBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                Size,
                                                                                TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                [],
                                                                                0,
                                                                                TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                [],
                                                                                0,
                                                                                0,
                                                                                'fSpaceLinesVertexBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');
 end;

 Size:=(CountSpaceLines*6)*SizeOf(TSpaceLinesIndex);
 if fSpaceLinesIndexBuffers[PerInFlightFrameBufferIndex].Size<Size then begin
  Size:=((CountSpaceLines+((CountSpaceLines+1) shr 1))*6)*SizeOf(TSpaceLinesIndex);
  fScene3D.AddToFreeQueue(fSpaceLinesIndexBuffers[PerInFlightFrameBufferIndex]); // Free old buffer delayed due to possible usage in the current moment
  fSpaceLinesIndexBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                               Size,
                                                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                               [],
                                                                               0,
                                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                               0,
                                                                               0,
                                                                               0,
                                                                               0,
                                                                               0,
                                                                               0,
                                                                               [],
                                                                               0,
                                                                               0,
                                                                               'fSpaceLinesIndexBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');
 end;

 if not fScene3D.UsePerInFlightFrameResources then begin
  for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
   fSpaceLinesVertexBuffers[PerInFlightFrameBufferIndex]:=fSpaceLinesVertexBuffers[0];
   fSpaceLinesIndexBuffers[PerInFlightFrameBufferIndex]:=fSpaceLinesIndexBuffers[0];
  end;
 end;

end;

procedure TpvScene3DRendererInstance.Prepare;
var PerInFlightFrameBufferIndex:TpvSizeInt;
    AntialiasingFirstPass:TpvFrameGraph.TPass;
    AntialiasingLastPass:TpvFrameGraph.TPass;
    PreLastPass:TpvFrameGraph.TPass;
    LastPass:TpvFrameGraph.TPass;
    InFlightFrameIndex,CascadeIndex,ImageIndex,Index:TpvSizeInt;
    Format:TVkFormat;
    GlobalIlluminationRadianceHintsSHTextureDescriptorInfoArray:TVkDescriptorImageInfoArray;
    GlobalIlluminationVoxelConeTracingOcclusionTextureDescriptorInfoArray:TVkDescriptorImageInfoArray;
    GlobalIlluminationVoxelConeTracingRadianceTextureDescriptorInfoArray:TVkDescriptorImageInfoArray;
    GlobalIlluminationVoxelConeTracingVisualizationTextureDescriptorInfoArray:TVkDescriptorImageInfoArray;
    GlobalIlluminationDDGIMasterData:TGlobalIlluminationDDGIMasterData;
    DDGIClearCommandPool:TpvVulkanCommandPool;
    DDGIClearCommandBuffer:TpvVulkanCommandBuffer;
    DDGIClearFence:TpvVulkanFence;
    DDGIClearColorValue:TVkClearColorValue;
    DDGIClearImageRange:TVkImageSubresourceRange;
begin

 // If AI upscaling is enabled, enforce the size factor from the upscale mode.
 case Renderer.AIUpscaleMode of
  TpvScene3DRendererAIUpscaleMode.Factor2X:begin
   fSizeFactor:=0.5;
  end;
  TpvScene3DRendererAIUpscaleMode.Factor4X:begin
   fSizeFactor:=0.25;
  end;
  else begin
  end;
 end;

 // Particle BVH (self-contained subsystem; created once, allocates its per-frame buffers when a consumer is active).
 if (not assigned(fParticleBVH)) and TpvScene3DRendererParticleBVH.MustBeCreated(Renderer) then begin
  fParticleBVH:=TpvScene3DRendererParticleBVH.Create(Renderer);
 end;
 if assigned(fParticleBVH) then begin
  fParticleBVH.AcquireVolatileResources;
 end;

 case Renderer.GlobalIlluminationMode of

  TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints:begin

   fGlobalIlluminationRadianceHintsCascadedVolumes:=TCascadedVolumes.Create(self,
                                                                            GlobalIlluminationRadiantHintVolumeSize,
                                                                            CountGlobalIlluminationRadiantHintCascades,
                                                                            TCascadedVolumes.TCascadeVolumeKind.CascadedRadianceHints);

   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin

    fGlobalIlluminationRadianceHintsUniformBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                               SizeOf(TGlobalIlluminationRadianceHintsUniformBufferData),
                                                                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                               [],
                                                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                               0,
                                                                                               0,
                                                                                               0,
                                                                                               0,
                                                                                               0,
                                                                                               0,
                                                                                               [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                                               0,
                                                                                               pvAllocationGroupIDScene3DStatic,
                                                                                               'TpvScene3DRendererInstance.fGlobalIlluminationRadianceHintsUniformBuffers['+IntToStr(InFlightFrameIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationRadianceHintsUniformBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fGlobalIlluminationRadianceHintsUniformBuffers['+IntToStr(InFlightFrameIndex)+']');

    fGlobalIlluminationRadianceHintsRSMUniformBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                  SizeOf(TGlobalIlluminationRadianceHintsRSMUniformBufferData),
                                                                                                  TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                                                                  TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                  [],
                                                                                                  TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                  TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                                  0,
                                                                                                  0,
                                                                                                  0,
                                                                                                  0,
                                                                                                  0,
                                                                                                  0,
                                                                                                  [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                                                  0,
                                                                                                  pvAllocationGroupIDScene3DStatic,
                                                                                                  'TpvScene3DRendererInstance.fGlobalIlluminationRadianceHintsRSMUniformBuffers['+IntToStr(InFlightFrameIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationRadianceHintsRSMUniformBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fGlobalIlluminationRadianceHintsRSMUniformBuffers['+IntToStr(InFlightFrameIndex)+']');

    fGlobalIlluminationRadianceHintsEvents[InFlightFrameIndex]:=TpvVulkanEvent.Create(Renderer.VulkanDevice);
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationRadianceHintsEvents[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_EVENT,'TpvScene3DRendererInstance.fGlobalIlluminationRadianceHintsEvents['+IntToStr(InFlightFrameIndex)+']');

    fGlobalIlluminationRadianceHintsEventReady[InFlightFrameIndex]:=false;

   end;

   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
    for CascadeIndex:=0 to CountGlobalIlluminationRadiantHintCascades-1 do begin
     for ImageIndex:=0 to CountGlobalIlluminationRadiantHintVolumeImages-1 do begin
      if (ImageIndex+1)<CountGlobalIlluminationRadiantHintVolumeImages then begin
       Format:=VK_FORMAT_R16G16B16A16_SFLOAT;
      end else begin
       Format:=VK_FORMAT_R32G32B32A32_SFLOAT;
      end;
      fInFlightFrameCascadedRadianceHintVolumeImages[InFlightFrameIndex,CascadeIndex,ImageIndex]:=TpvScene3DRendererImage3D.Create(fScene3D.VulkanDevice,
                                                                                                                                   GlobalIlluminationRadiantHintVolumeSize,
                                                                                                                                   GlobalIlluminationRadiantHintVolumeSize,
                                                                                                                                   GlobalIlluminationRadiantHintVolumeSize,
                                                                                                                                   Format,
                                                                                                                                   VK_SAMPLE_COUNT_1_BIT,
                                                                                                                                   VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                                                                                                   pvAllocationGroupIDScene3DStatic,
                                                                                                                                   'TpvScene3DRendererInstance.fInFlightFrameCascadedRadianceHintVolumeImages['+IntToStr(InFlightFrameIndex)+','+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+']');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fInFlightFrameCascadedRadianceHintVolumeImages[InFlightFrameIndex,CascadeIndex,ImageIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fInFlightFrameCascadedRadianceHintVolumeImages['+IntToStr(InFlightFrameIndex)+','+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+'].Image');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fInFlightFrameCascadedRadianceHintVolumeImages[InFlightFrameIndex,CascadeIndex,ImageIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fInFlightFrameCascadedRadianceHintVolumeImages['+IntToStr(InFlightFrameIndex)+','+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+'].ImageView');
      fInFlightFrameCascadedRadianceHintVolumeSecondBounceImages[InFlightFrameIndex,CascadeIndex,ImageIndex]:=TpvScene3DRendererImage3D.Create(fScene3D.VulkanDevice,
                                                                                                                                               GlobalIlluminationRadiantHintVolumeSize,
                                                                                                                                               GlobalIlluminationRadiantHintVolumeSize,
                                                                                                                                               GlobalIlluminationRadiantHintVolumeSize,
                                                                                                                                               Format,
                                                                                                                                               VK_SAMPLE_COUNT_1_BIT,
                                                                                                                                               VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                                                                                                               pvAllocationGroupIDScene3DStatic,
                                                                                                                                               'TpvScene3DRendererInstance.fInFlightFrameCascadedRadianceHintVolumeSecondBounceImages['+IntToStr(InFlightFrameIndex)+','+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+']');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fInFlightFrameCascadedRadianceHintVolumeSecondBounceImages[InFlightFrameIndex,CascadeIndex,ImageIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fInFlightFrameCascadedRadianceHintVolumeSecondBounceImages['+IntToStr(InFlightFrameIndex)+','+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+'].Image');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fInFlightFrameCascadedRadianceHintVolumeSecondBounceImages[InFlightFrameIndex,CascadeIndex,ImageIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fInFlightFrameCascadedRadianceHintVolumeSecondBounceImages['+IntToStr(InFlightFrameIndex)+','+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+'].ImageView');
     end;
    end;
   end;

   fGlobalIlluminationRadianceHintsDescriptorPool:=TpvVulkanDescriptorPool.Create(Renderer.VulkanDevice,
                                                                                  TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                                  Renderer.CountInFlightFrames);
   fGlobalIlluminationRadianceHintsDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,Renderer.CountInFlightFrames);
   fGlobalIlluminationRadianceHintsDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,Renderer.CountInFlightFrames*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintVolumeImages);
   fGlobalIlluminationRadianceHintsDescriptorPool.Initialize;
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationRadianceHintsDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DRendererInstance.fGlobalIlluminationRadianceHintsDescriptorPool');

   fGlobalIlluminationRadianceHintsDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(Renderer.VulkanDevice);
   fGlobalIlluminationRadianceHintsDescriptorSetLayout.AddBinding(0,
                                                                  VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                                                  1,
                                                                  TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                                  []);
   fGlobalIlluminationRadianceHintsDescriptorSetLayout.AddBinding(1,
                                                                  VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                                  TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintSHImages,
                                                                  TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                                  []);
   fGlobalIlluminationRadianceHintsDescriptorSetLayout.Initialize;
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationRadianceHintsDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DRendererInstance.fGlobalIlluminationRadianceHintsDescriptorSetLayout');

   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin

    GlobalIlluminationRadianceHintsSHTextureDescriptorInfoArray:=nil;
    try

     SetLength(GlobalIlluminationRadianceHintsSHTextureDescriptorInfoArray,TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintCascades*TpvScene3DRendererInstance.CountGlobalIlluminationRadiantHintSHImages);
     Index:=0;
     for CascadeIndex:=0 to CountGlobalIlluminationRadiantHintCascades-1 do begin
      for ImageIndex:=0 to CountGlobalIlluminationRadiantHintSHImages-1 do begin
       GlobalIlluminationRadianceHintsSHTextureDescriptorInfoArray[Index]:=TVkDescriptorImageInfo.Create(Renderer.ClampedSampler.Handle,
//     fInFlightFrameCascadedRadianceHintVolumeImages[InFlightFrameIndex,CascadeIndex,ImageIndex].VulkanImageView.Handle,
//
       fInFlightFrameCascadedRadianceHintVolumeSecondBounceImages[InFlightFrameIndex,CascadeIndex,ImageIndex].VulkanImageView.Handle,
                                                                                                         VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
       inc(Index);
      end;
     end;

     fGlobalIlluminationRadianceHintsDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fGlobalIlluminationRadianceHintsDescriptorPool,
                                                                                                       fGlobalIlluminationRadianceHintsDescriptorSetLayout);
     fGlobalIlluminationRadianceHintsDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                                             0,
                                                                                             1,
                                                                                             TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                                             [],
                                                                                             [fGlobalIlluminationRadianceHintsUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                             [],
                                                                                             false
                                                                                            );
     fGlobalIlluminationRadianceHintsDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                                             0,
                                                                                             length(GlobalIlluminationRadianceHintsSHTextureDescriptorInfoArray),
                                                                                             TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                             GlobalIlluminationRadianceHintsSHTextureDescriptorInfoArray,
                                                                                             [],
                                                                                             [],
                                                                                             false
                                                                                            );
     fGlobalIlluminationRadianceHintsDescriptorSets[InFlightFrameIndex].Flush;
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationRadianceHintsDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TpvScene3DRendererInstance.fGlobalIlluminationRadianceHintsDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

    finally
     GlobalIlluminationRadianceHintsSHTextureDescriptorInfoArray:=nil;
    end;

   end;

  end;

  TpvScene3DRendererGlobalIlluminationMode.DynamicDiffuseGlobalIllumination:begin

   // The probe images are not cleared on allocation, so mark every in-flight slot "first frame" until it has been written
   // once (the trace pass then skips multi-bounce + the probe-update pass discards the uninitialized previous data, and
   // flips this false). Shared by both DDGI compute passes.
   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
    fGlobalIlluminationDDGIFirstFrames[InFlightFrameIndex]:=true;
   end;

   // Reuse the cascaded-volume snapping (used by radiance hints) for the probe grid placement: probe (0..N-1) spans the
   // cascade AABB, so the "volume size" passed here is the per-axis probe count.
   fGlobalIlluminationDDGICascadedVolumes:=TCascadedVolumes.Create(self,
                                                                   GlobalIlluminationDDGIProbeCountX,
                                                                   CountGlobalIlluminationDDGICascades,
                                                                   TCascadedVolumes.TCascadeVolumeKind.DynamicDiffuseGlobalIllumination);

   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin

    // The cascade globals (formerly a separate UBO buffer) now live at offset 0 of the DDGI data buffer (fGlobalIllumination
    // DDGIMasterBuffers), followed by the BDA sub-buffer pointers — one std430 SSBO `ddgiData` (gi_ddgi_data.glsl). Created
    // further below (after the sub-buffers exist), so nothing to allocate here any more.

    if GlobalIlluminationDDGIStorageOctahedral then begin
     // Octahedral irradiance: a single RGBA16F 2D atlas (probe tiles with guard bands).
     fGlobalIlluminationDDGIIrradianceOctImages[InFlightFrameIndex]:=TpvScene3DRendererImage2D.Create(fScene3D.VulkanDevice,
                                                                                                      GlobalIlluminationDDGIIrradianceAtlasWidth,
                                                                                                      GlobalIlluminationDDGIIrradianceAtlasHeight,
                                                                                                      VK_FORMAT_R16G16B16A16_SFLOAT,
                                                                                                      true,
                                                                                                      VK_SAMPLE_COUNT_1_BIT,
                                                                                                      VK_IMAGE_LAYOUT_GENERAL,
                                                                                                      VK_SHARING_MODE_EXCLUSIVE,
                                                                                                      nil,
                                                                                                      pvAllocationGroupIDScene3DStatic,
                                                                                                      'TpvScene3DRendererInstance.fGlobalIlluminationDDGIIrradianceOctImages['+IntToStr(InFlightFrameIndex)+']');
    end else begin
     // Spherical harmonics irradiance: a BDA storage buffer, DDGI_SH_IMAGE_COUNT packed RGBA16F-equivalent vec4 per probe
     // (L1 = 3, L2 = 7), reached via the master. Device-local, fully overwritten by the irradiance update (no initial clear).
     fGlobalIlluminationDDGIIrradianceSHBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                            TpvSizeInt(CountGlobalIlluminationDDGICascades)*TpvSizeInt(GlobalIlluminationDDGIProbesPerCascade)*TpvSizeInt(GlobalIlluminationDDGISHImageCount)*SizeOf(TpvVector4),
                                                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                            TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                            [],
                                                                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                            0,0,0,0,0,0,0,
                                                                                            [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                            0,
                                                                                            pvAllocationGroupIDScene3DStatic,
                                                                                            'TpvScene3DRendererInstance.fGlobalIlluminationDDGIIrradianceSHBuffers['+IntToStr(InFlightFrameIndex)+']');
    end;

    // Visibility split: distance MOMENTS (mean, mean^2) in an RG32F atlas (F32 precision for the Chebyshev test — fp16 was
    // dithering it), and the SKY visibility separately in an R8 atlas (only needs 0..1). The per-probe age moved to its own
    // BDA buffer, so neither image carries it any more. Both bilinear-sampled in shading, so they stay sampled images.
    fGlobalIlluminationDDGIVisibilityMomentsImages[InFlightFrameIndex]:=TpvScene3DRendererImage2D.Create(fScene3D.VulkanDevice,
                                                                                                  GlobalIlluminationDDGIProbeCountX*GlobalIlluminationDDGIVisibilityOctFull,
                                                                                                  GlobalIlluminationDDGIProbeCountY*GlobalIlluminationDDGIProbeCountZ*CountGlobalIlluminationDDGICascades*GlobalIlluminationDDGIVisibilityOctFull,
                                                                                                  VK_FORMAT_R32G32_SFLOAT, // x = mean dist, y = mean dist^2
                                                                                                  true,
                                                                                                  VK_SAMPLE_COUNT_1_BIT,
                                                                                                  VK_IMAGE_LAYOUT_GENERAL,
                                                                                                  VK_SHARING_MODE_EXCLUSIVE,
                                                                                                  nil,
                                                                                                  pvAllocationGroupIDScene3DStatic,
                                                                                                  'TpvScene3DRendererInstance.fGlobalIlluminationDDGIVisibilityMomentsImages['+IntToStr(InFlightFrameIndex)+']');

    fGlobalIlluminationDDGIVisibilitySkyImages[InFlightFrameIndex]:=TpvScene3DRendererImage2D.Create(fScene3D.VulkanDevice,
                                                                                                     GlobalIlluminationDDGIProbeCountX*GlobalIlluminationDDGIVisibilityOctFull,
                                                                                                     GlobalIlluminationDDGIProbeCountY*GlobalIlluminationDDGIProbeCountZ*CountGlobalIlluminationDDGICascades*GlobalIlluminationDDGIVisibilityOctFull,
                                                                                                     VK_FORMAT_R8_UNORM, // x = sky visibility (0..1)
                                                                                                     true,
                                                                                                     VK_SAMPLE_COUNT_1_BIT,
                                                                                                     VK_IMAGE_LAYOUT_GENERAL,
                                                                                                     VK_SHARING_MODE_EXCLUSIVE,
                                                                                                     nil,
                                                                                                     pvAllocationGroupIDScene3DStatic,
                                                                                                     'TpvScene3DRendererInstance.fGlobalIlluminationDDGIVisibilitySkyImages['+IntToStr(InFlightFrameIndex)+']');

    // Glossy prefiltered-radiance octahedral atlas, opt-in. RGBA16F (hardware-bilinear-filtered,
    // single view via TpvScene3DRendererImage2D like the irradiance octahedral atlas). Only allocated when the toggle is on.
    if GlobalIlluminationDDGIGlossyRadiance then begin
     fGlobalIlluminationDDGIGlossyImages[InFlightFrameIndex]:=TpvScene3DRendererImage2D.Create(fScene3D.VulkanDevice,
                                                                                               GlobalIlluminationDDGIProbeCountX*GlobalIlluminationDDGIGlossyOctFull,
                                                                                               GlobalIlluminationDDGIProbeCountY*GlobalIlluminationDDGIProbeCountZ*CountGlobalIlluminationDDGICascades*GlobalIlluminationDDGIGlossyOctFull,
                                                                                               VK_FORMAT_R16G16B16A16_SFLOAT, // prefiltered radiance (RGB)
                                                                                               true,
                                                                                               VK_SAMPLE_COUNT_1_BIT,
                                                                                               VK_IMAGE_LAYOUT_GENERAL,
                                                                                               VK_SHARING_MODE_EXCLUSIVE,
                                                                                               nil,
                                                                                               pvAllocationGroupIDScene3DStatic,
                                                                                               'TpvScene3DRendererInstance.fGlobalIlluminationDDGIGlossyImages['+IntToStr(InFlightFrameIndex)+']');
    end;

    // Ray-data is now a BDA storage buffer (vec4 per (probe,ray): rgb = radiance, a = distance). Device-local, full
    // precision, no image-format cap; written by the trace, read by the update/relocation/classification passes via the
    // DDGI master buffer (gi_ddgi_master.glsl). Fully rewritten every frame, so no initial clear is needed.
    fGlobalIlluminationDDGIRayDataBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                      TpvSizeInt(CountGlobalIlluminationDDGICascades)*TpvSizeInt(GlobalIlluminationDDGIProbesPerCascade)*TpvSizeInt(GlobalIlluminationDDGIRaysPerProbe)*SizeOf(TpvVector4),
                                                                                      TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                      TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                      [],
                                                                                      TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                      0,0,0,0,0,0,0,
                                                                                      [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                      0,
                                                                                      pvAllocationGroupIDScene3DStatic,
                                                                                      'TpvScene3DRendererInstance.fGlobalIlluminationDDGIRayDataBuffers['+IntToStr(InFlightFrameIndex)+']');

    // DDGI data buffer: ONE std430 SSBO holding the cascade globals (offset 0, CPU-written each frame) followed by the BDA
    // sub-buffer pointers (offset SizeOf(globals), written once below) — the unified `ddgiData` block (gi_ddgi_data.glsl),
    // bound at the DDGI set's binding 0 in both the compute passes and the fragment consumers (replaces the old globals UBO
    // AND the old master pointer buffer). BAR: device-local (fast SSBO reads by every DDGI invocation / fragment) AND
    // host-visible (CPU fills the pointers via UpdateData; the per-frame globals are staged into offset 0). No device-address
    // needed for the block itself any more (only the sub-buffers it points to are BDA).
    fGlobalIlluminationDDGIMasterBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                     SizeOf(TGlobalIlluminationDDGIUniformBufferData)+SizeOf(TGlobalIlluminationDDGIMasterData),
                                                                                     TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                     TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                     [],
                                                                                     TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                     TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                     0,0,0,0,0,0,
                                                                                     [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                                     0,
                                                                                     pvAllocationGroupIDScene3DStatic,
                                                                                     'TpvScene3DRendererInstance.fGlobalIlluminationDDGIMasterBuffers['+IntToStr(InFlightFrameIndex)+']');
    // Probe relocation data: a BDA storage buffer, vec4 per probe (xyz = relocation offset, w = active state). Written by the
    // relocation/classification passes, read by the trace + the shading consumers via the master. Allocated only when probe
    // relocation is on (full F32 precision; the world-space offset would dither in fp16).
    if GlobalIlluminationDDGIProbeRelocation then begin
     fGlobalIlluminationDDGIProbeDataBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                         TpvSizeInt(CountGlobalIlluminationDDGICascades)*TpvSizeInt(GlobalIlluminationDDGIProbesPerCascade)*SizeOf(TpvVector4),
                                                                                         TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                         TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                         [],
                                                                                         TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                         0,0,0,0,0,0,0,
                                                                                         [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                         0,
                                                                                         pvAllocationGroupIDScene3DStatic,
                                                                                         'TpvScene3DRendererInstance.fGlobalIlluminationDDGIProbeDataBuffers['+IntToStr(InFlightFrameIndex)+']');
    end;

    // Per-probe convergence age: a tiny BDA storage buffer, one uint per probe (frames since (re)init). Written by the
    // visibility update (one thread per probe), read by the irradiance update for the warmup hysteresis ramp; never sampled.
    // Always allocated (the per-probe warmup is no longer compile-time gated). Not cleared: on a probe's first frame the age
    // is reset, so the uninitialized value is never used.
    fGlobalIlluminationDDGIAgeBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                  TpvSizeInt(CountGlobalIlluminationDDGICascades)*TpvSizeInt(GlobalIlluminationDDGIProbesPerCascade)*SizeOf(TpvUInt32),
                                                                                  TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                  TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                  [],
                                                                                  TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                  0,0,0,0,0,0,0,
                                                                                  [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                  0,
                                                                                  pvAllocationGroupIDScene3DStatic,
                                                                                  'TpvScene3DRendererInstance.fGlobalIlluminationDDGIAgeBuffers['+IntToStr(InFlightFrameIndex)+']');

    // Fill the master pointers now that all of this slot's sub-buffers exist. probe-data = 0 when relocation is off; the
    // The SH-irradiance pointer is set only in SH storage mode (the octahedral mode keeps its sampled image instead).
    FillChar(GlobalIlluminationDDGIMasterData,SizeOf(GlobalIlluminationDDGIMasterData),#0);
    GlobalIlluminationDDGIMasterData.RayData:=fGlobalIlluminationDDGIRayDataBuffers[InFlightFrameIndex].DeviceAddress;
    if GlobalIlluminationDDGIProbeRelocation then begin
     GlobalIlluminationDDGIMasterData.ProbeData:=fGlobalIlluminationDDGIProbeDataBuffers[InFlightFrameIndex].DeviceAddress;
    end;
    if not GlobalIlluminationDDGIStorageOctahedral then begin
     GlobalIlluminationDDGIMasterData.IrradianceSH:=fGlobalIlluminationDDGIIrradianceSHBuffers[InFlightFrameIndex].DeviceAddress;
    end;
    GlobalIlluminationDDGIMasterData.Age:=fGlobalIlluminationDDGIAgeBuffers[InFlightFrameIndex].DeviceAddress;
    // Pointers go AFTER the cascade globals (which the per-frame UploadGlobalIlluminationDDGI stages into offset 0). Written
    // once here (the sub-buffer addresses are stable for the slot's lifetime).
    fGlobalIlluminationDDGIMasterBuffers[InFlightFrameIndex].UpdateData(GlobalIlluminationDDGIMasterData,SizeOf(TGlobalIlluminationDDGIUniformBufferData),SizeOf(GlobalIlluminationDDGIMasterData));

   end;

   // Defense-in-depth: the probe images/buffers are not zeroed by the allocator (the per-slot first-frame guard + the NaN-safe
   // discard in the update shaders are the actual protection). Explicitly clear every freshly allocated DDGI image/buffer once
   // here, so VRAM reused from a prior session can never feed NaN/Inf garbage in for even a frame. The master buffer is excluded
   // on purpose: it holds the BDA sub-buffer pointers + cascade globals that were just written above.
   DDGIClearCommandPool:=TpvVulkanCommandPool.Create(Renderer.VulkanDevice,
                                                     Renderer.VulkanDevice.UniversalQueueFamilyIndex,
                                                     TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
   try
    DDGIClearCommandBuffer:=TpvVulkanCommandBuffer.Create(DDGIClearCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
    try
     DDGIClearFence:=TpvVulkanFence.Create(Renderer.VulkanDevice);
     try
      DDGIClearCommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT));
      FillChar(DDGIClearColorValue,SizeOf(DDGIClearColorValue),#0);
      DDGIClearImageRange:=TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),0,VK_REMAINING_MIP_LEVELS,0,VK_REMAINING_ARRAY_LAYERS);
      for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
       // Images live in VK_IMAGE_LAYOUT_GENERAL (clearable in place).
       if assigned(fGlobalIlluminationDDGIIrradianceOctImages[InFlightFrameIndex]) then begin
        DDGIClearCommandBuffer.CmdClearColorImage(fGlobalIlluminationDDGIIrradianceOctImages[InFlightFrameIndex].VulkanImage.Handle,VK_IMAGE_LAYOUT_GENERAL,@DDGIClearColorValue,1,@DDGIClearImageRange);
       end;
       if assigned(fGlobalIlluminationDDGIVisibilityMomentsImages[InFlightFrameIndex]) then begin
        DDGIClearCommandBuffer.CmdClearColorImage(fGlobalIlluminationDDGIVisibilityMomentsImages[InFlightFrameIndex].VulkanImage.Handle,VK_IMAGE_LAYOUT_GENERAL,@DDGIClearColorValue,1,@DDGIClearImageRange);
       end;
       if assigned(fGlobalIlluminationDDGIVisibilitySkyImages[InFlightFrameIndex]) then begin
        DDGIClearCommandBuffer.CmdClearColorImage(fGlobalIlluminationDDGIVisibilitySkyImages[InFlightFrameIndex].VulkanImage.Handle,VK_IMAGE_LAYOUT_GENERAL,@DDGIClearColorValue,1,@DDGIClearImageRange);
       end;
       if assigned(fGlobalIlluminationDDGIGlossyImages[InFlightFrameIndex]) then begin
        DDGIClearCommandBuffer.CmdClearColorImage(fGlobalIlluminationDDGIGlossyImages[InFlightFrameIndex].VulkanImage.Handle,VK_IMAGE_LAYOUT_GENERAL,@DDGIClearColorValue,1,@DDGIClearImageRange);
       end;
       // Storage buffers (all created with TRANSFER_DST). The master buffer is intentionally NOT filled here.
       if assigned(fGlobalIlluminationDDGIIrradianceSHBuffers[InFlightFrameIndex]) then begin
        DDGIClearCommandBuffer.CmdFillBuffer(fGlobalIlluminationDDGIIrradianceSHBuffers[InFlightFrameIndex].Handle,0,VK_WHOLE_SIZE,0);
       end;
       if assigned(fGlobalIlluminationDDGIRayDataBuffers[InFlightFrameIndex]) then begin
        DDGIClearCommandBuffer.CmdFillBuffer(fGlobalIlluminationDDGIRayDataBuffers[InFlightFrameIndex].Handle,0,VK_WHOLE_SIZE,0);
       end;
       if assigned(fGlobalIlluminationDDGIProbeDataBuffers[InFlightFrameIndex]) then begin
        DDGIClearCommandBuffer.CmdFillBuffer(fGlobalIlluminationDDGIProbeDataBuffers[InFlightFrameIndex].Handle,0,VK_WHOLE_SIZE,0);
       end;
       if assigned(fGlobalIlluminationDDGIAgeBuffers[InFlightFrameIndex]) then begin
        DDGIClearCommandBuffer.CmdFillBuffer(fGlobalIlluminationDDGIAgeBuffers[InFlightFrameIndex].Handle,0,VK_WHOLE_SIZE,0);
       end;
      end;
      DDGIClearCommandBuffer.EndRecording;
      DDGIClearCommandBuffer.Execute(Renderer.VulkanDevice.UniversalQueue,0,nil,nil,DDGIClearFence,true);
     finally
      FreeAndNil(DDGIClearFence);
     end;
    finally
     FreeAndNil(DDGIClearCommandBuffer);
    end;
   finally
    FreeAndNil(DDGIClearCommandPool);
   end;

   // Set 2 descriptor for the mesh fragment shader (sampled probe data): UBO + irradiance SH (3 sampler3D) + visibility.
   fGlobalIlluminationDDGIDescriptorPool:=TpvVulkanDescriptorPool.Create(Renderer.VulkanDevice,
                                                                         TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                         Renderer.CountInFlightFrames);
   fGlobalIlluminationDDGIDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,Renderer.CountInFlightFrames); // binding 0 = ddgiData SSBO (cascade globals + sub-buffer pointers)
   if GlobalIlluminationDDGIStorageOctahedral then begin
    fGlobalIlluminationDDGIDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,Renderer.CountInFlightFrames*3); // binding 1 = oct irradiance + binding 2 = visibility moments + binding 4 = visibility sky
   end else begin
    fGlobalIlluminationDDGIDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,Renderer.CountInFlightFrames*2); // binding 2 = visibility moments + binding 4 = visibility sky (SH irradiance is a BDA buffer via the master)
   end;
   if GlobalIlluminationDDGIGlossyRadiance then begin
    fGlobalIlluminationDDGIDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,Renderer.CountInFlightFrames); // binding 5 = glossy prefiltered-radiance atlas
   end;
   fGlobalIlluminationDDGIDescriptorPool.Initialize;

   // Binding 0 = ddgiData SSBO (cascade globals + the BDA sub-buffer pointers — probe-data + SH-irradiance + ...); binding 2 =
   // octahedral visibility moments (bilinear); binding 4 = visibility sky (bilinear). Binding 1 = octahedral irradiance atlas
   // (bilinear) ONLY in OCT storage mode (SH irradiance is a sub-buffer reached via ddgiData). Matches the `ddgiData` SSBO in
   // gi_ddgi_data.glsl (binding 3, the old master pointer UBO, is gone — folded into binding 0).
   fGlobalIlluminationDDGIDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(Renderer.VulkanDevice);
   // binding 0 = ddgiData SSBO. VERTEX/FRAGMENT always; TASK/MESH only when mesh shaders are supported (else the stage bits
   // would reference an unsupported feature -> validation error). The gi_ddgi_probe_debug.{vert | task+mesh} debug overlay reads
   // the cascade globals here for probe placement + frustum cull; production shading reads it in FRAGMENT.
   if Renderer.Scene3D.MeshShaderSupport then begin
    fGlobalIlluminationDDGIDescriptorSetLayout.AddBinding(0,VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_TASK_BIT_EXT) or TVkShaderStageFlags(VK_SHADER_STAGE_MESH_BIT_EXT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]);
   end else begin
    fGlobalIlluminationDDGIDescriptorSetLayout.AddBinding(0,VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]);
   end;
   if GlobalIlluminationDDGIStorageOctahedral then begin
    fGlobalIlluminationDDGIDescriptorSetLayout.AddBinding(1,VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,1,TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]);
   end;
   fGlobalIlluminationDDGIDescriptorSetLayout.AddBinding(2,VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,1,TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]); // binding 2 = visibility moments (RG32F)
   fGlobalIlluminationDDGIDescriptorSetLayout.AddBinding(4,VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,1,TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]); // binding 4 = visibility sky (R8)
   if GlobalIlluminationDDGIGlossyRadiance then begin
    fGlobalIlluminationDDGIDescriptorSetLayout.AddBinding(5,VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,1,TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]); // binding 5 = glossy prefiltered-radiance atlas
   end;
   fGlobalIlluminationDDGIDescriptorSetLayout.Initialize;

   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
    fGlobalIlluminationDDGIDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fGlobalIlluminationDDGIDescriptorPool,fGlobalIlluminationDDGIDescriptorSetLayout);
    fGlobalIlluminationDDGIDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fGlobalIlluminationDDGIMasterBuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false); // binding 0 = ddgiData SSBO (globals + sub-buffer pointers)
    if GlobalIlluminationDDGIStorageOctahedral then begin
     fGlobalIlluminationDDGIDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                    [TVkDescriptorImageInfo.Create(Renderer.ClampedSampler.Handle,fGlobalIlluminationDDGIIrradianceOctImages[InFlightFrameIndex].VulkanImageView.Handle,VK_IMAGE_LAYOUT_GENERAL)],[],[],false);
    end;
    fGlobalIlluminationDDGIDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                   [TVkDescriptorImageInfo.Create(Renderer.ClampedSampler.Handle,fGlobalIlluminationDDGIVisibilityMomentsImages[InFlightFrameIndex].VulkanImageView.Handle,VK_IMAGE_LAYOUT_GENERAL)],[],[],false); // binding 2 = visibility moments
    fGlobalIlluminationDDGIDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                   [TVkDescriptorImageInfo.Create(Renderer.ClampedSampler.Handle,fGlobalIlluminationDDGIVisibilitySkyImages[InFlightFrameIndex].VulkanImageView.Handle,VK_IMAGE_LAYOUT_GENERAL)],[],[],false); // binding 4 = visibility sky
    if GlobalIlluminationDDGIGlossyRadiance then begin
     fGlobalIlluminationDDGIDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                    [TVkDescriptorImageInfo.Create(Renderer.ClampedSampler.Handle,fGlobalIlluminationDDGIGlossyImages[InFlightFrameIndex].VulkanImageView.Handle,VK_IMAGE_LAYOUT_GENERAL)],[],[],false); // binding 5 = glossy prefiltered-radiance atlas (RGBA16F, hardware bilinear)
    end;
    fGlobalIlluminationDDGIDescriptorSets[InFlightFrameIndex].Flush;
   end;

  end;

  TpvScene3DRendererGlobalIlluminationMode.SurfelGlobalIllumination:begin

   // Persistent (single, GPU-only) surfel pool / hash grid / stats / free-list SSBOs. The surfel state accumulates across
   // frames; within one queue the GPU executes frame N fully before N+1, so no per-in-flight duplication is needed. They
   // are zeroed once on the compute pass' first frame (vkCmdFillBuffer). All are device-local with TRANSFER_DST for that.
   fGlobalIlluminationSurfelPoolBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                              TpvSizeInt(GlobalIlluminationSurfelMaxCount)*TpvSizeInt(GlobalIlluminationSurfelRecordSize),
                                                              TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT),
                                                              TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                              [],
                                                              TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                              0,0,0,0,0,0,0,
                                                              [],
                                                              0,
                                                              pvAllocationGroupIDScene3DStatic,
                                                              'TpvScene3DRendererInstance.fGlobalIlluminationSurfelPoolBuffer');

   fGlobalIlluminationSurfelGridCellBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                  TpvSizeInt(GlobalIlluminationSurfelHashCellCount)*TpvSizeInt(GlobalIlluminationSurfelMaxPerCell)*SizeOf(TpvUInt32),
                                                                  TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT),
                                                                  TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                  [],
                                                                  TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                  0,0,0,0,0,0,0,
                                                                  [],
                                                                  0,
                                                                  pvAllocationGroupIDScene3DStatic,
                                                                  'TpvScene3DRendererInstance.fGlobalIlluminationSurfelGridCellBuffer');

   fGlobalIlluminationSurfelGridCellCountBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                       TpvSizeInt(GlobalIlluminationSurfelHashCellCount)*SizeOf(TpvUInt32),
                                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT),
                                                                       TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                       [],
                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                       0,0,0,0,0,0,0,
                                                                       [],
                                                                       0,
                                                                       pvAllocationGroupIDScene3DStatic,
                                                                       'TpvScene3DRendererInstance.fGlobalIlluminationSurfelGridCellCountBuffer');

   fGlobalIlluminationSurfelStatsBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                               4*SizeOf(TpvUInt32), // spawn cursor, alive count, free count bank 0, free count bank 1
                                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT),
                                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                               [],
                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                               0,0,0,0,0,0,0,
                                                               [],
                                                               0,
                                                               pvAllocationGroupIDScene3DStatic,
                                                               'TpvScene3DRendererInstance.fGlobalIlluminationSurfelStatsBuffer');

   fGlobalIlluminationSurfelFreeListBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                  TpvSizeInt(2)*TpvSizeInt(GlobalIlluminationSurfelMaxCount)*SizeOf(TpvUInt32),
                                                                  TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT),
                                                                  TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                  [],
                                                                  TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                  0,0,0,0,0,0,0,
                                                                  [],
                                                                  0,
                                                                  pvAllocationGroupIDScene3DStatic,
                                                                  'TpvScene3DRendererInstance.fGlobalIlluminationSurfelFreeListBuffer');

   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
    fGlobalIlluminationSurfelUniformBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                       SizeOf(TGlobalIlluminationSurfelUniformBufferData),
                                                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                                                       TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                       [],
                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                       0,0,0,0,0,0,
                                                                                       [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                                       0,
                                                                                       pvAllocationGroupIDScene3DStatic,
                                                                                       'TpvScene3DRendererInstance.fGlobalIlluminationSurfelUniformBuffers['+IntToStr(InFlightFrameIndex)+']');
   end;

   // Shading-side descriptor (set 2 in mesh.frag / set 4 in the planet shaders): UBO + pool + grid cells + grid counts.
   fGlobalIlluminationSurfelDescriptorPool:=TpvVulkanDescriptorPool.Create(Renderer.VulkanDevice,
                                                                          TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                          Renderer.CountInFlightFrames);
   fGlobalIlluminationSurfelDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,Renderer.CountInFlightFrames);
   fGlobalIlluminationSurfelDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,Renderer.CountInFlightFrames*3);
   fGlobalIlluminationSurfelDescriptorPool.Initialize;

   fGlobalIlluminationSurfelDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(Renderer.VulkanDevice);
   fGlobalIlluminationSurfelDescriptorSetLayout.AddBinding(0,VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]);
   fGlobalIlluminationSurfelDescriptorSetLayout.AddBinding(1,VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]);
   fGlobalIlluminationSurfelDescriptorSetLayout.AddBinding(2,VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]);
   fGlobalIlluminationSurfelDescriptorSetLayout.AddBinding(3,VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1,TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),[]);
   fGlobalIlluminationSurfelDescriptorSetLayout.Initialize;

   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
    fGlobalIlluminationSurfelDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fGlobalIlluminationSurfelDescriptorPool,fGlobalIlluminationSurfelDescriptorSetLayout);
    fGlobalIlluminationSurfelDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),[],[fGlobalIlluminationSurfelUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],[],false);
    fGlobalIlluminationSurfelDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fGlobalIlluminationSurfelPoolBuffer.DescriptorBufferInfo],[],false);
    fGlobalIlluminationSurfelDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fGlobalIlluminationSurfelGridCellBuffer.DescriptorBufferInfo],[],false);
    fGlobalIlluminationSurfelDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,0,1,TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),[],[fGlobalIlluminationSurfelGridCellCountBuffer.DescriptorBufferInfo],[],false);
    fGlobalIlluminationSurfelDescriptorSets[InFlightFrameIndex].Flush;
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationSurfelDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TpvScene3DRendererInstance.fGlobalIlluminationSurfelDescriptorSets['+IntToStr(InFlightFrameIndex)+']');
   end;

  end;

  TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing:begin

   fGlobalIlluminationCascadedVoxelConeTracingMaxGlobalFragmentCount:=((((Renderer.GlobalIlluminationVoxelGridSize*
                                                                          Renderer.GlobalIlluminationVoxelGridSize*
                                                                          Renderer.GlobalIlluminationVoxelGridSize)*
                                                                         Renderer.GlobalIlluminationVoxelCountCascades)*
                                                                        64) div (Renderer.GlobalIlluminationVoxelGridSize+(Renderer.GlobalIlluminationVoxelGridSize and 1)));


   fGlobalIlluminationCascadedVoxelConeTracingMaxLocalFragmentCount:=16;

   fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes:=TCascadedVolumes.Create(self,
                                                                                       Renderer.GlobalIlluminationVoxelGridSize,
                                                                                       Renderer.GlobalIlluminationVoxelCountCascades,
                                                                                       TCascadedVolumes.TCascadeVolumeKind.VoxelConeTracing);

   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin

    fGlobalIlluminationCascadedVoxelConeTracingUniformBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                       SizeOf(TGlobalIlluminationCascadedVoxelConeTracingUniformBufferData),
                                                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                                                       TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                       [],
                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       [TpvVulkanBufferFlag.PersistentMappedIfPossible],
                                                                                       0,
                                                                                       pvAllocationGroupIDScene3DStatic,
                                                                                       'TpvScene3DRendererInstance.fGlobalIlluminationRadianceHintsRSMUniformBuffers['+IntToStr(InFlightFrameIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingUniformBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fGlobalIlluminationRadianceHintsRSMUniformBuffers['+IntToStr(InFlightFrameIndex)+']');

   end;

   for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin
    fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                                       fGlobalIlluminationCascadedVoxelConeTracingMaxGlobalFragmentCount*(SizeOf(TpvUInt32)*8),
                                                                                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_SRC_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                                                       TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                                       [],
                                                                                                                       0,
                                                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                                       0,
                                                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                                       0,
                                                                                                                       0,
                                                                                                                       0,
                                                                                                                       0,
                                                                                                                       [],
                                                                                                                       0,
                                                                                                                       pvAllocationGroupIDScene3DStatic,
                                                                                                                       'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');

    fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                                           ((Renderer.GlobalIlluminationVoxelCountCascades*
                                                                                                                             (Renderer.GlobalIlluminationVoxelGridSize*
                                                                                                                              Renderer.GlobalIlluminationVoxelGridSize*
                                                                                                                              Renderer.GlobalIlluminationVoxelGridSize))+1)*(SizeOf(TpvUInt32)*2),
                                                                                                                           TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_SRC_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                                                           TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                                           [],
                                                                                                                           0,
                                                                                                                           TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                                           0,
                                                                                                                           TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                                           0,
                                                                                                                           0,
                                                                                                                           0,
                                                                                                                           0,
                                                                                                                           [],
                                                                                                                           0,
                                                                                                                           pvAllocationGroupIDScene3DStatic,
                                                                                                                           'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');
   end;

   if not fScene3D.UsePerInFlightFrameResources then begin
    for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
     fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffers[PerInFlightFrameBufferIndex]:=fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffers[0];
     fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers[PerInFlightFrameBufferIndex]:=fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers[0];
    end;
   end;

   for CascadeIndex:=0 to Renderer.GlobalIlluminationVoxelCountCascades-1 do begin

{   fGlobalIlluminationCascadedVoxelConeTracingAtomicImages[CascadeIndex]:=TpvScene3DRendererImage3D.Create(Renderer.GlobalIlluminationVoxelGridSize*6,
                                                                                                            Renderer.GlobalIlluminationVoxelGridSize,
                                                                                                            Renderer.GlobalIlluminationVoxelGridSize*5,
                                                                                                            VK_FORMAT_R32_UINT,
                                                                                                            TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                                                                                            TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                                                                                            pvAllocationGroupIDScene3DStatic,
                                                                                                            'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingAtomicImages['+IntToStr(CascadeIndex)+']');//}

    fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages[CascadeIndex]:=TpvScene3DRendererMipmappedArray3DImage.Create(fScene3D.VulkanDevice,
                                                                                                                             Renderer.GlobalIlluminationVoxelGridSize,
                                                                                                                             Renderer.GlobalIlluminationVoxelGridSize,
                                                                                                                             Renderer.GlobalIlluminationVoxelGridSize,
                                                                                                                             VK_FORMAT_R8_UNORM,
                                                                                                                             true,
                                                                                                                             TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                                                                                                             TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                                                                                                             pvAllocationGroupIDScene3DStatic,
                                                                                                                             VK_FORMAT_UNDEFINED,
                                                                                                                             'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages['+IntToStr(CascadeIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages[CascadeIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages['+IntToStr(CascadeIndex)+'].Image');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages[CascadeIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages['+IntToStr(CascadeIndex)+'].ImageView');

    for ImageIndex:=0 to 5 do begin

     fGlobalIlluminationCascadedVoxelConeTracingRadianceImages[CascadeIndex,ImageIndex]:=TpvScene3DRendererMipmappedArray3DImage.Create(fScene3D.VulkanDevice,
                                                                                                                                        Renderer.GlobalIlluminationVoxelGridSize,
                                                                                                                                        Renderer.GlobalIlluminationVoxelGridSize,
                                                                                                                                        Renderer.GlobalIlluminationVoxelGridSize,
                                                                                                                                        VK_FORMAT_R16G16B16A16_SFLOAT,
                                                                                                                                        true,
                                                                                                                                        TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                                                                                                                        TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                                                                                                                        pvAllocationGroupIDScene3DStatic,
                                                                                                                                        VK_FORMAT_UNDEFINED,
                                                                                                                                        'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingRadianceImages['+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+']');
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingRadianceImages[CascadeIndex,ImageIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingRadianceImages['+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+'].Image');
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingRadianceImages[CascadeIndex,ImageIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingRadianceImages['+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+'].ImageView');

     // Visualization volume: R32_UINT storage (transfer compute writes encodeRGB9E5 of unlit base+emission) aliased by an
     // E5B9G9R9 sample view (hardware-decoded, RenderDoc-friendly) read by the voxel visualizations. Only filled while the
     // debug visualization is active.
     fGlobalIlluminationCascadedVoxelConeTracingVisualizationImages[CascadeIndex,ImageIndex]:=TpvScene3DRendererMipmappedArray3DImage.Create(fScene3D.VulkanDevice,
                                                                                                                                            Renderer.GlobalIlluminationVoxelGridSize,
                                                                                                                                            Renderer.GlobalIlluminationVoxelGridSize,
                                                                                                                                            Renderer.GlobalIlluminationVoxelGridSize,
                                                                                                                                            VK_FORMAT_R32_UINT,
                                                                                                                                            true,
                                                                                                                                            TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                                                                                                                            TVkImageLayout(VK_IMAGE_LAYOUT_GENERAL),
                                                                                                                                            pvAllocationGroupIDScene3DStatic,
                                                                                                                                            VK_FORMAT_E5B9G9R9_UFLOAT_PACK32,
                                                                                                                                            'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingVisualizationImages['+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+']');
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingVisualizationImages[CascadeIndex,ImageIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingVisualizationImages['+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+'].Image');
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingVisualizationImages[CascadeIndex,ImageIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingVisualizationImages['+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+'].ImageView');

    end;

   end;

   fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool:=TpvVulkanDescriptorPool.Create(Renderer.VulkanDevice,
                                                                                             TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                                             Renderer.CountInFlightFrames);
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,Renderer.CountInFlightFrames);
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,Renderer.CountInFlightFrames*Renderer.GlobalIlluminationVoxelCountCascades*(6+6+1));
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool.Initialize;
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool');

   // MESH_BIT (gated on MeshShaderSupport, else the stage bit would reference an unsupported feature -> validation error) lets the
   // mesh-shader voxel visualization (voxel_mesh_visualization.mesh) read VoxelGridData + the radiance samplers from the MESH stage.
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(Renderer.VulkanDevice);
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout.AddBinding(0,
                                                                             VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                                                             1,
                                                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT) or TVkShaderStageFlags(IfThen(Renderer.Scene3D.MeshShaderSupport,TpvInt64(VK_SHADER_STAGE_MESH_BIT_EXT),TpvInt64(0))),
                                                                             []);
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout.AddBinding(1,
                                                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                                             Renderer.GlobalIlluminationVoxelCountCascades,
                                                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT) or TVkShaderStageFlags(IfThen(Renderer.Scene3D.MeshShaderSupport,TpvInt64(VK_SHADER_STAGE_MESH_BIT_EXT),TpvInt64(0))),
                                                                             []);
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout.AddBinding(2,
                                                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                                             Renderer.GlobalIlluminationVoxelCountCascades*6,
                                                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT) or TVkShaderStageFlags(IfThen(Renderer.Scene3D.MeshShaderSupport,TpvInt64(VK_SHADER_STAGE_MESH_BIT_EXT),TpvInt64(0))),
                                                                             []);
   // Binding 3: the unlit base+emission visualization volume (E5B9G9R9 sample view), read only by the voxel visualizations
   // (vertex/mesh path). The forward/transparency cone-tracing shaders never declare this binding, so widening the shared layout
   // is harmless to them.
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout.AddBinding(3,
                                                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                                             Renderer.GlobalIlluminationVoxelCountCascades*6,
                                                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT) or TVkShaderStageFlags(IfThen(Renderer.Scene3D.MeshShaderSupport,TpvInt64(VK_SHADER_STAGE_MESH_BIT_EXT),TpvInt64(0))),
                                                                             []);
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout.Initialize;
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout');

   GlobalIlluminationVoxelConeTracingOcclusionTextureDescriptorInfoArray:=nil;
   GlobalIlluminationVoxelConeTracingRadianceTextureDescriptorInfoArray:=nil;
   GlobalIlluminationVoxelConeTracingVisualizationTextureDescriptorInfoArray:=nil;

   try

    SetLength(GlobalIlluminationVoxelConeTracingOcclusionTextureDescriptorInfoArray,Renderer.GlobalIlluminationVoxelCountCascades);
    SetLength(GlobalIlluminationVoxelConeTracingRadianceTextureDescriptorInfoArray,Renderer.GlobalIlluminationVoxelCountCascades*6);
    SetLength(GlobalIlluminationVoxelConeTracingVisualizationTextureDescriptorInfoArray,Renderer.GlobalIlluminationVoxelCountCascades*6);

    for CascadeIndex:=0 to Renderer.GlobalIlluminationVoxelCountCascades-1 do begin

     GlobalIlluminationVoxelConeTracingOcclusionTextureDescriptorInfoArray[CascadeIndex]:=TVkDescriptorImageInfo.Create(Renderer.ClampedSampler.Handle,
                                                                                                                        fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages[CascadeIndex].VulkanImageView.Handle,
                                                                                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);


     for ImageIndex:=0 to 5 do begin

      GlobalIlluminationVoxelConeTracingRadianceTextureDescriptorInfoArray[(CascadeIndex*6)+ImageIndex]:=TVkDescriptorImageInfo.Create(Renderer.ClampedSampler.Handle,
                                                                                                                                       fGlobalIlluminationCascadedVoxelConeTracingRadianceImages[CascadeIndex,ImageIndex].VulkanImageView.Handle,
                                                                                                                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);

      // E5B9G9R9 sample view, kept in GENERAL (the transfer compute writes it via the R32_UINT view and never transitions it).
      GlobalIlluminationVoxelConeTracingVisualizationTextureDescriptorInfoArray[(CascadeIndex*6)+ImageIndex]:=TVkDescriptorImageInfo.Create(Renderer.ClampedSampler.Handle,
                                                                                                                                            fGlobalIlluminationCascadedVoxelConeTracingVisualizationImages[CascadeIndex,ImageIndex].VulkanOtherImageView.Handle,
                                                                                                                                            VK_IMAGE_LAYOUT_GENERAL);


     end;

    end;

    for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin

     fGlobalIlluminationCascadedVoxelConeTracingEvents[InFlightFrameIndex]:=TpvVulkanEvent.Create(Renderer.VulkanDevice);

     Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingEvents[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_EVENT,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingEvents['+IntToStr(InFlightFrameIndex)+']');

     fGlobalIlluminationCascadedVoxelConeTracingEventReady[InFlightFrameIndex]:=false;

     fGlobalIlluminationCascadedVoxelConeTracingFirst[InFlightFrameIndex]:=true;

     fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool,
                                                                                                                  fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout);
     fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                                                        0,
                                                                                                        1,
                                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                                                        [],
                                                                                                        [fGlobalIlluminationCascadedVoxelConeTracingUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                                        [],
                                                                                                        false
                                                                                                       );
     fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                                                        0,
                                                                                                        Renderer.GlobalIlluminationVoxelCountCascades,
                                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                                        GlobalIlluminationVoxelConeTracingOcclusionTextureDescriptorInfoArray,
                                                                                                        [],
                                                                                                        [],
                                                                                                        false
                                                                                                       );
     fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                                                        0,
                                                                                                        Renderer.GlobalIlluminationVoxelCountCascades*6,
                                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                                        GlobalIlluminationVoxelConeTracingRadianceTextureDescriptorInfoArray,
                                                                                                        [],
                                                                                                        [],
                                                                                                        false
                                                                                                       );
     fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                                                        0,
                                                                                                        Renderer.GlobalIlluminationVoxelCountCascades*6,
                                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                                        GlobalIlluminationVoxelConeTracingVisualizationTextureDescriptorInfoArray,
                                                                                                        [],
                                                                                                        [],
                                                                                                        false
                                                                                                       );
     fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets[InFlightFrameIndex].Flush;

     Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

    end;

   finally
    GlobalIlluminationVoxelConeTracingOcclusionTextureDescriptorInfoArray:=nil;
    GlobalIlluminationVoxelConeTracingRadianceTextureDescriptorInfoArray:=nil;
    GlobalIlluminationVoxelConeTracingVisualizationTextureDescriptorInfoArray:=nil;
   end;

  end;

  else begin
  end;

 end;

 if assigned(fVirtualReality) then begin

  fFrameGraph.AddImageResourceType('resourcetype_output_color',
                                   true,
                                   fVirtualReality.ImageFormat,
                                   TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                   TpvFrameGraph.TImageType.Color,
                                   TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,1.0,1.0,1.0,fCountSurfaceViews),
                                   TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT),
                                   1
                                  );

  fHUDSize:=TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,Renderer.VirtualRealityHUDWidth,Renderer.VirtualRealityHUDHeight);

 end else begin

  fFrameGraph.AddImageResourceType('resourcetype_output_color',
                                   true,
                                   TVkFormat(VK_FORMAT_UNDEFINED),
                                   TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                   TpvFrameGraph.TImageType.Surface,
                                   TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,1.0,1.0,1.0,fCountSurfaceViews),
                                   TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT),
                                   1
                                  );

  fHUDSize:=TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,1.0,1.0);

 end;

 fFrameGraph.AddImageResourceType('resourcetype_hud_color',
                                  false,
                                  VK_FORMAT_R8G8B8A8_SRGB,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  fHUDSize,
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_hud_depth',
                                  false,
                                  VK_FORMAT_D32_SFLOAT{pvApplication.VulkanDepthImageFormat},
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.From(VK_FORMAT_D32_SFLOAT{pvApplication.VulkanDepthImageFormat}),
                                  fHUDSize,
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 // Object-selection outline (branch objectselectiontry1): the selection mask (objectID + depth) + its own depth buffer, at
 // scene resolution. Non-MSAA. RG32UI so the JFA/compose can read the id + the frontmost-selected fragment depth.
 fFrameGraph.AddImageResourceType('resourcetype_selection_mask',
                                  false,
                                  VK_FORMAT_R32G32_UINT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_selection_mask_depth',
                                  false,
                                  VK_FORMAT_D32_SFLOAT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.From(VK_FORMAT_D32_SFLOAT),
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 // Object-selection outline: the ISOLATED premultiplied outline buffer (built from the mask, then FXAA'd + composited).
 fFrameGraph.AddImageResourceType('resourcetype_selection_outline_buffer',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_msaa_color',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,
                                  Renderer.SurfaceSampleCountFlagBits,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_msaa_wetnessmap',
                                  false,
                                  VK_FORMAT_R8G8B8A8_UINT,
                                  Renderer.SurfaceSampleCountFlagBits,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_STORAGE_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_msaa_color_optimized_non_alpha',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,//Renderer.OptimizedNonAlphaFormat,
                                  Renderer.SurfaceSampleCountFlagBits,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_msaa_inscattering',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,
                                  Renderer.SurfaceSampleCountFlagBits,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_msaa_transmittance',
                                  false,
                                  VK_FORMAT_R8G8B8A8_UNORM,
                                  Renderer.SurfaceSampleCountFlagBits,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_msaa_lineardepth',
                                  false,
                                  VK_FORMAT_R32_SFLOAT,
                                  Renderer.SurfaceSampleCountFlagBits,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_msaa_depth',
                                  false,
                                  VK_FORMAT_D32_SFLOAT{pvApplication.VulkanDepthImageFormat},
                                  Renderer.SurfaceSampleCountFlagBits,
                                  TpvFrameGraph.TImageType.From(VK_FORMAT_D32_SFLOAT{pvApplication.VulkanDepthImageFormat}),
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_msaa_predepth',
                                  false,
                                  VK_FORMAT_R32_SFLOAT,
                                  Renderer.SurfaceSampleCountFlagBits,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_msaa_velocity',
                                  false,
                                  VK_FORMAT_R16G16_SFLOAT,
                                  Renderer.SurfaceSampleCountFlagBits,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_msaa_normals',
                                  false,
                                  VK_FORMAT_A2B10G10R10_UNORM_PACK32,
                                  Renderer.SurfaceSampleCountFlagBits,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_reflectionprobe_color',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,
                                  VK_SAMPLE_COUNT_1_BIT,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,ReflectionProbeWidth,ReflectionProbeHeight,1.0,6),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_reflectionprobe_optimized_non_alpha',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,//Renderer.OptimizedNonAlphaFormat,
                                  VK_SAMPLE_COUNT_1_BIT,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,ReflectionProbeWidth,ReflectionProbeHeight,1.0,6),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_reflectionprobe_depth',
                                  false,
                                  VK_FORMAT_D32_SFLOAT{pvApplication.VulkanDepthImageFormat},
                                  VK_SAMPLE_COUNT_1_BIT,
                                  TpvFrameGraph.TImageType.From(VK_FORMAT_D32_SFLOAT{pvApplication.VulkanDepthImageFormat}),
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,ReflectionProbeWidth,ReflectionProbeHeight,1.0,6),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_reflectiveshadowmap_color',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,//Renderer.OptimizedNonAlphaFormat,
                                  VK_SAMPLE_COUNT_1_BIT,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,fReflectiveShadowMapWidth,fReflectiveShadowMapHeight,1.0,0),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_reflectiveshadowmap_normalused',
                                  false,
                                  VK_FORMAT_A2B10G10R10_UNORM_PACK32,
                                  VK_SAMPLE_COUNT_1_BIT,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,fReflectiveShadowMapWidth,fReflectiveShadowMapHeight,1.0,0),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_reflectiveshadowmap_depth',
                                  false,
                                  VK_FORMAT_D32_SFLOAT{pvApplication.VulkanDepthImageFormat},
                                  VK_SAMPLE_COUNT_1_BIT,
                                  TpvFrameGraph.TImageType.From(VK_FORMAT_D32_SFLOAT{pvApplication.VulkanDepthImageFormat}),
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,fReflectiveShadowMapWidth,fReflectiveShadowMapHeight,1.0,0),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_topdownskyocclusionmap_depth',
                                  false,
                                  VK_FORMAT_D32_SFLOAT{pvApplication.VulkanDepthImageFormat},
                                  VK_SAMPLE_COUNT_1_BIT,
                                  TpvFrameGraph.TImageType.From(VK_FORMAT_D32_SFLOAT{pvApplication.VulkanDepthImageFormat}),
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,fTopDownSkyOcclusionMapWidth,fTopDownSkyOcclusionMapHeight,1.0,0),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_topdownskyocclusionmap_data',
                                  false,
                                  VK_FORMAT_R32_SFLOAT,
                                  VK_SAMPLE_COUNT_1_BIT,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,fTopDownSkyOcclusionMapWidth,fTopDownSkyOcclusionMapHeight,1.0,0),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_mboit_data',
                                  false,
                                  VK_FORMAT_R32G32B32A32_SFLOAT,
                                  Renderer.SurfaceSampleCountFlagBits,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_wboit_accumulation',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,
                                  Renderer.SurfaceSampleCountFlagBits,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_wboit_revealage',
                                  false,
                                  VK_FORMAT_R32_SFLOAT,
                                  Renderer.SurfaceSampleCountFlagBits,
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_color_optimized_non_alpha',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,//Renderer.OptimizedNonAlphaFormat,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_STORAGE_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_inscattering',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_transmittance',
                                  false,
                                  VK_FORMAT_R8G8B8A8_UNORM,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_lineardepth',
                                  false,
                                  VK_FORMAT_R32_SFLOAT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_voxelization',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,//Renderer.OptimizedNonAlphaFormat,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,Renderer.GlobalIlluminationVoxelGridSize,Renderer.GlobalIlluminationVoxelGridSize,1.0,0),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_clouds_shadowmap',
                                  false,
                                  VK_FORMAT_R32G32_SFLOAT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,Renderer.CloudsShadowMapSize,Renderer.CloudsShadowMapSize,1.0,1),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 case Renderer.AntialiasingMode of
  TpvScene3DRendererAntialiasingMode.SMAAT2x:begin
   fFrameGraph.AddImageResourceType('resourcetype_color_temporal_antialiasing',
                                    false,
                                    VK_FORMAT_R16G16B16A16_SFLOAT,
                                    TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                    TpvFrameGraph.TImageType.Color,
                                    TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                    TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT),
                                    1
                                   );
  end;
  else begin
   fFrameGraph.AddImageResourceType('resourcetype_color_temporal_antialiasing',
                                    false,
                                    VK_FORMAT_R16G16B16A16_SFLOAT,//Renderer.OptimizedNonAlphaFormat,
                                    TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                    TpvFrameGraph.TImageType.Color,
                                    TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                    TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT),
                                    1
                                   );
  end;
 end;

 if (Renderer.AIUpscaleMode<>TpvScene3DRendererAIUpscaleMode.None) or (Renderer.ResamplingMode=TpvScene3DRendererResamplingMode.EASU) then begin
  fFrameGraph.AddImageResourceType('resourcetype_color_fullres_optimized_non_alpha',
                                   false,
                                   VK_FORMAT_R16G16B16A16_SFLOAT,//Renderer.OptimizedNonAlphaFormat,
                                   TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                   TpvFrameGraph.TImageType.Color,
                                   TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,1.0,1.0,1.0,fCountSurfaceViews),
                                   TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_STORAGE_BIT),
                                   1
                                  );
 end else begin
  fFrameGraph.AddImageResourceType('resourcetype_color_fullres_optimized_non_alpha',
                                   false,
                                   VK_FORMAT_R16G16B16A16_SFLOAT,//Renderer.OptimizedNonAlphaFormat,
                                   TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                   TpvFrameGraph.TImageType.Color,
                                   TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,1.0,1.0,1.0,fCountSurfaceViews),
                                   TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                   1
                                  );
 end;

 fFrameGraph.AddImageResourceType('resourcetype_color_tonemapping',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,//VK_FORMAT_R8G8B8A8_SRGB,//TVkFormat(TpvInt32(IfThen(Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),TpvInt32(VK_FORMAT_R8G8B8A8_SRGB),TpvInt32(VK_FORMAT_R8G8B8A8_UNORM)))),
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,1.0,1.0,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1,
                                  VK_IMAGE_LAYOUT_UNDEFINED,
                                  VK_IMAGE_LAYOUT_UNDEFINED{,
                                  VK_FORMAT_R8G8B8A8_UNORM}
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_color_output',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,//VK_FORMAT_R8G8B8A8_SRGB,//TVkFormat(TpvInt32(IfThen(Renderer.SurfaceSampleCountFlagBits=TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),TpvInt32(VK_FORMAT_R8G8B8A8_SRGB),TpvInt32(VK_FORMAT_R8G8B8A8_UNORM)))),
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,1.0,1.0,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1,
                                  VK_IMAGE_LAYOUT_UNDEFINED,
                                  VK_IMAGE_LAYOUT_UNDEFINED{,
                                  VK_FORMAT_R8G8B8A8_UNORM}
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_dithering_color',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,//VK_FORMAT_R8G8B8A8_SRGB,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,1.0,1.0,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_hud_output_color',
                                  false,
                                  VK_FORMAT_R8G8B8A8_SRGB,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,1.0,1.0,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_color',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_STORAGE_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_wetnessmap',
                                  false,
                                  VK_FORMAT_R8G8B8A8_UINT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_STORAGE_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_color_fullres',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,1.0,1.0,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_color_halfres',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor*0.5,fSizeFactor*0.5,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

{fFrameGraph.AddImageResourceType('resourcetype_color_posteffect',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_color_posteffect_halfres',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor*0.5,fSizeFactor*0.5,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );}

 case Renderer.AntialiasingMode of
  TpvScene3DRendererAntialiasingMode.SMAAT2x:begin
   fFrameGraph.AddImageResourceType('resourcetype_color_antialiasing',
                                    false,
                                    VK_FORMAT_R16G16B16A16_SFLOAT,
                                    TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                    TpvFrameGraph.TImageType.Color,
                                    TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                    TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT),
                                    1
                                   );
  end;
  else begin
   fFrameGraph.AddImageResourceType('resourcetype_color_antialiasing',
                                    false,
                                    VK_FORMAT_R16G16B16A16_SFLOAT,//Renderer.OptimizedNonAlphaFormat,
                                    TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                    TpvFrameGraph.TImageType.Color,
                                    TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                    TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                    1
                                   );
  end;
 end;

 fFrameGraph.AddImageResourceType('resourcetype_depth',
                                  false,
                                  VK_FORMAT_D32_SFLOAT{pvApplication.VulkanDepthImageFormat},
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.From(VK_FORMAT_D32_SFLOAT{pvApplication.VulkanDepthImageFormat}),
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or (IfThen(Renderer.AntialiasingMode=TpvScene3DRendererAntialiasingMode.TAA,TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT),0)),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_predepth',
                                  false,
                                  VK_FORMAT_R32_SFLOAT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_velocity',
                                  false,
                                  VK_FORMAT_R16G16_SFLOAT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_normals',
                                  false,
                                  VK_FORMAT_A2B10G10R10_UNORM_PACK32,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_ambientocclusion',
                                  false,
                                  VK_FORMAT_R32G32_SFLOAT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_ambientocclusion_final',
                                  false,
                                  VK_FORMAT_R8_UNORM,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );
 case Renderer.ShadowMode of

  TpvScene3DRendererShadowMode.MSM:begin

   fFrameGraph.AddImageResourceType('resourcetype_cascadedshadowmap_msaa_data',
                                    false,
                                    VK_FORMAT_R16G16B16A16_UNORM,
  //                                VK_FORMAT_R32G32B32A32_SFLOAT,
                                    Renderer.ShadowMapSampleCountFlagBits,
                                    TpvFrameGraph.TImageType.Color,
                                    TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,fCascadedShadowMapWidth,fCascadedShadowMapHeight,1.0,CountCascadedShadowMapCascades),
                                    TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                    1
                                   );

   fFrameGraph.AddImageResourceType('resourcetype_cascadedshadowmap_msaa_depth',
                                    false,
                                    VK_FORMAT_D32_SFLOAT,
                                    Renderer.ShadowMapSampleCountFlagBits,
                                    TpvFrameGraph.TImageType.From(VK_FORMAT_D32_SFLOAT),
                                    TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,fCascadedShadowMapWidth,fCascadedShadowMapHeight,1.0,CountCascadedShadowMapCascades),
                                    TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                    1
                                   );

   fFrameGraph.AddImageResourceType('resourcetype_cascadedshadowmap_data',
                                    false,
                                    VK_FORMAT_R16G16B16A16_UNORM,
  //                                VK_FORMAT_R32G32B32A32_SFLOAT,
                                    TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                    TpvFrameGraph.TImageType.Color,
                                    TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,fCascadedShadowMapWidth,fCascadedShadowMapHeight,1.0,CountCascadedShadowMapCascades),
                                    TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                    1
                                   );

   fFrameGraph.AddImageResourceType('resourcetype_cascadedshadowmap_depth',
                                    false,
                                    VK_FORMAT_D32_SFLOAT,
                                    TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                    TpvFrameGraph.TImageType.From(VK_FORMAT_D32_SFLOAT),
                                    TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,fCascadedShadowMapWidth,fCascadedShadowMapHeight,1.0,CountCascadedShadowMapCascades),
                                    TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                    1
                                   );

  end;

  else begin

   fFrameGraph.AddImageResourceType('resourcetype_cascadedshadowmap_data',
                                    false,
                                    VK_FORMAT_D32_SFLOAT,
                                    TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                    TpvFrameGraph.TImageType.From(VK_FORMAT_D32_SFLOAT),
                                    TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.Absolute,fCascadedShadowMapWidth,fCascadedShadowMapHeight,1.0,CountCascadedShadowMapCascades),
                                    TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                    1
                                   );

  end;

 end;

 fFrameGraph.AddImageResourceType('resourcetype_smaa_edges',
                                  false,
                                  VK_FORMAT_R8G8_UNORM,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

 fFrameGraph.AddImageResourceType('resourcetype_smaa_weights',
                                  false,
                                  VK_FORMAT_R8G8B8A8_UNORM,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

{fFrameGraph.AddImageResourceType('resourcetype_depthoffield',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,fSizeFactor,fSizeFactor,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );}

{TpvScene3DRendererInstancePasses(fPasses).fDataTransferPass:=TpvScene3DRendererPassesDataTransferPass.Create(fFrameGraph,self);

 TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass:=TpvScene3DRendererPassesMeshComputePass.Create(fFrameGraph,self);
 TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDataTransferPass);

 if Renderer.Scene3D.RaytracingActive then begin

  TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass:=TpvScene3DRendererPassesRaytracingBuildUpdatePass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);

 end else begin

  TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass:=nil;

 end;}

 if not Renderer.RaytracingActive then begin

  TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass0ComputePass:=TpvScene3DRendererPassesMeshCullPass0ComputePass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.CascadedShadowMap);
{ TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
  end;}

  TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthRenderPass:=TpvScene3DRendererPassesCullDepthRenderPass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.CascadedShadowMap);
//TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
  TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass0ComputePass);

  if (Renderer.ShadowMode=TpvScene3DRendererShadowMode.MSM) and (Renderer.ShadowMapSampleCountFlagBits<>TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT)) then begin
   TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthResolveComputePass:=TpvScene3DRendererPassesCullDepthResolveComputePass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.CascadedShadowMap);
   TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthResolveComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass0ComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthResolveComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthRenderPass);
  end else begin
   TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthResolveComputePass:=nil;
  end;

  TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthPyramidComputePass:=TpvScene3DRendererPassesCullDepthPyramidComputePass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.CascadedShadowMap);
  TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthPyramidComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass0ComputePass);
  TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthPyramidComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthRenderPass);
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthResolveComputePass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthPyramidComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthResolveComputePass);
  end;

  TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass1ComputePass:=TpvScene3DRendererPassesMeshCullPass1ComputePass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.CascadedShadowMap);
  TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass1ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass0ComputePass);
  TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass1ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapCullDepthPyramidComputePass);

 end else begin

  TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass1ComputePass:=nil;

 end;

 case Renderer.ShadowMode of

  TpvScene3DRendererShadowMode.None,
  TpvScene3DRendererShadowMode.PCF,TpvScene3DRendererShadowMode.DPCF,TpvScene3DRendererShadowMode.PCSS:begin

   TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass:=TpvScene3DRendererPassesCascadedShadowMapRenderPass.Create(fFrameGraph,self);
{  TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
   end;}
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass1ComputePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass1ComputePass);
   end;
{  begin
    TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass);
    TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   end;}

  end;

  TpvScene3DRendererShadowMode.MSM:begin

   TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass:=TpvScene3DRendererPassesCascadedShadowMapRenderPass.Create(fFrameGraph,self);
{  TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
   end;}
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass1ComputePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapMeshCullPass1ComputePass);
   end;
{  begin
    TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass);
    TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   end;}

   TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapResolveRenderPass:=TpvScene3DRendererPassesCascadedShadowMapResolveRenderPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapResolveRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass);

   TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapBlurRenderPasses[0]:=TpvScene3DRendererPassesCascadedShadowMapBlurRenderPass.Create(fFrameGraph,self,true);

   TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapBlurRenderPasses[1]:=TpvScene3DRendererPassesCascadedShadowMapBlurRenderPass.Create(fFrameGraph,self,false);

  end;

  else begin

   Assert(false);

  end;

 end;

 if fScene3D.EnableAtmosphere then begin

  TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationWaitCustomPass:=TpvScene3DRendererPassesAtmospherePrecipitationWaitCustomPass.Create(fFrameGraph,self);
  if fScene3D.PlanetAtmospherePrecipitationSimulationUseParallelQueue then begin
   FreeAndNil(fAtmosphereExternalWaitingOnSemaphore);
   fAtmosphereExternalWaitingOnSemaphore:=TpvFrameGraph.TExternalWaitingOnSemaphore.Create(fFrameGraph);
   try
    for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
     fAtmosphereExternalWaitingOnSemaphore.InFlightFrameSemaphores[InFlightFrameIndex]:=fAtmospherePrecipitationSimulationSemaphores[InFlightFrameIndex];
    end;
   finally
    TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationWaitCustomPass.AddExternalWaitingOnSemaphore(fAtmosphereExternalWaitingOnSemaphore,TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT));
   end;
  end else begin
   fAtmosphereExternalWaitingOnSemaphore:=nil;
  end;

  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass:=TpvScene3DRendererPassesAtmosphereProcessCustomPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationWaitCustomPass);
  case Renderer.ShadowMode of
   TpvScene3DRendererShadowMode.None,
   TpvScene3DRendererShadowMode.PCF,TpvScene3DRendererShadowMode.DPCF,TpvScene3DRendererShadowMode.PCSS:begin
    TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass);
   end;
   TpvScene3DRendererShadowMode.MSM:begin
    TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapBlurRenderPasses[1]);
   end;
   else begin
   end;
  end;

 end else begin

  TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationWaitCustomPass:=nil;
  fAtmosphereExternalWaitingOnSemaphore:=nil;
  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass:=nil;

 end;

 begin

  TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass:=TpvScene3DRendererPassesMeshCullPass0ComputePass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.FinalView);
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
  end;
{ TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
  end;}
  case Renderer.ShadowMode of
   TpvScene3DRendererShadowMode.None,
   TpvScene3DRendererShadowMode.PCF,TpvScene3DRendererShadowMode.DPCF,TpvScene3DRendererShadowMode.PCSS:begin
    TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass);
   end;
   TpvScene3DRendererShadowMode.MSM:begin
    TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapBlurRenderPasses[1]);
   end;
   else begin
   end;
  end;

  // Object-selection outline: build the selected-only indirect draw list from the (pre-occlusion) input commands. Ordered
  // after the FinalView mesh cull so the per-frame input command upload is established; the selection mask pass (later) will
  // depend on this. Always created (selection works in any renderer mode).
  TpvScene3DRendererInstancePasses(fPasses).fSelectionListComputePass:=TpvScene3DRendererPassesSelectionListComputePass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fSelectionListComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass);

  // Selection mask: rasterizes the selection list (RG32UI id+depth, own depth buffer). Depends on the list build. Its output
  // is consumed by the (future) selection JFA/compose pass, which is what pulls this + the list-build into the frame graph.
  TpvScene3DRendererInstancePasses(fPasses).fSelectionMaskRenderPass:=TpvScene3DRendererPassesSelectionMaskRenderPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fSelectionMaskRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fSelectionListComputePass);

  TpvScene3DRendererInstancePasses(fPasses).fCullDepthRenderPass:=TpvScene3DRendererPassesCullDepthRenderPass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.FinalView);
//TpvScene3DRendererInstancePasses(fPasses).fCullDepthRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
  TpvScene3DRendererInstancePasses(fPasses).fCullDepthRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass);

  if Renderer.SurfaceSampleCountFlagBits<>TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
   TpvScene3DRendererInstancePasses(fPasses).fCullDepthResolveComputePass:=TpvScene3DRendererPassesCullDepthResolveComputePass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.FinalView);
   TpvScene3DRendererInstancePasses(fPasses).fCullDepthResolveComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fCullDepthResolveComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCullDepthRenderPass);
  end;

  TpvScene3DRendererInstancePasses(fPasses).fCullDepthPyramidComputePass:=TpvScene3DRendererPassesCullDepthPyramidComputePass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.FinalView);
  TpvScene3DRendererInstancePasses(fPasses).fCullDepthPyramidComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass);
  TpvScene3DRendererInstancePasses(fPasses).fCullDepthPyramidComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCullDepthRenderPass);
  if Renderer.SurfaceSampleCountFlagBits<>TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
   TpvScene3DRendererInstancePasses(fPasses).fCullDepthPyramidComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCullDepthResolveComputePass);
  end;

  TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass:=TpvScene3DRendererPassesMeshCullPass1ComputePass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.FinalView);
  TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCullDepthPyramidComputePass);

  // RICHTUNG-2 ORDERING DIAGNOSTIC / candidate fix: keep the object-selection passes OUT of the
  // cull -> CullDepth -> Hi-Z pyramid -> MeshCullPass1 region. The selection list/mask passes only
  // declared a dependency on MeshCullPass0 (above), so the frame graph was free to topologically
  // interleave the selection-list compute and (especially) the selection MASK render pass into the
  // middle of the single-queue cull/Hi-Z command stream -> perturbing pass batching / transient
  // resource aliasing / barrier placement and exposing the 1-frame "depth present, color missing"
  // flicker (it reproduces with parallel queues OFF once the selection passes exist). Forcing the
  // selection chain to start only after MeshCullPass1 removes that interleaving. The selection list
  // reads the pre-occlusion INPUT commands, which are ready well before Pass1, so this is legal.
  // A/B-test by toggling the define ({.$define} = off, {$define} = on).
  // RESULT (tested): with this ON the flicker STILL occurs -> it is NOT the GPU pass
  // interleaving/placement of the selection passes. Left here OFF as a documented experiment.
  {.$define SELECTION_PASSES_AFTER_CULL_CHAIN}
  {$ifdef SELECTION_PASSES_AFTER_CULL_CHAIN}
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fSelectionListComputePass) and
     assigned(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fSelectionListComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass);
  end;
  {$endif}

 end;

 begin

  TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass:=TpvScene3DRendererPassesDepthPrepassRenderPass.Create(fFrameGraph,self);
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
  end;
{ TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
  end;}
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass);
  end;

  TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass:=TpvScene3DRendererPassesDepthMipMapComputePass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass);

 end;

 TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridBuildComputePass:=TpvScene3DRendererPassesFrustumClusterGridBuildComputePass.Create(fFrameGraph,self);
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridBuildComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
 end;
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridBuildComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass);
 end;
 TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridBuildComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);

 TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridAssignComputePass:=TpvScene3DRendererPassesFrustumClusterGridAssignComputePass.Create(fFrameGraph,self);
 TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridAssignComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridBuildComputePass);

 TpvScene3DRendererInstancePasses(fPasses).fParticleBVHComputePass:=nil;
 TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingFinalizationCustomPass:=nil;
 TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGITraceComputePass:=nil;
 TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIIrradianceUpdateComputePass:=nil;
 TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIGlossyRadianceUpdateComputePass:=nil;
 TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIVisibilityUpdateComputePass:=nil;
 TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIBorderUpdateComputePass:=nil;
 TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIRelocationComputePass:=nil;
 TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIClassificationComputePass:=nil;
 TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationSurfelComputePass:=nil;

 // Particle BVH build pass (technique-neutral): created before all GI passes; the consuming GI pass (the DDGI trace) takes an
 // explicit dependency on it where it is created, so it is both kept alive and ordered before the consumer.
 if assigned(fParticleBVH) and fParticleBVH.Active then begin
  TpvScene3DRendererInstancePasses(fPasses).fParticleBVHComputePass:=TpvScene3DRendererPassesParticleBVHComputePass.Create(fFrameGraph,self);
 end;

 case Renderer.GlobalIlluminationMode of

  TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints:begin

   TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapMeshFilterComputePass:=TpvScene3DRendererPassesMeshFilterComputePass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.TopDownSkyOcclusionMap);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapMeshFilterComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
   end;
   case Renderer.ShadowMode of
    TpvScene3DRendererShadowMode.None,
    TpvScene3DRendererShadowMode.PCF,TpvScene3DRendererShadowMode.DPCF,TpvScene3DRendererShadowMode.PCSS:begin
     TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapMeshFilterComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass);
    end;
    TpvScene3DRendererShadowMode.MSM:begin
     TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapMeshFilterComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapBlurRenderPasses[1]);
    end;
    else begin
    end;
   end;

   TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass:=TpvScene3DRendererPassesTopDownSkyOcclusionMapRenderPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapMeshFilterComputePass);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
   end;
{  TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
   end;}
   TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass);

{  TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapResolveRenderPass:=TpvScene3DRendererPassesTopDownSkyOcclusionMapResolveRenderPass.Create(fFrameGraph,self);

   TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapBlurRenderPasses[0]:=TpvScene3DRendererPassesTopDownSkyOcclusionMapBlurRenderPass.Create(fFrameGraph,self,true);

   TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapBlurRenderPasses[1]:=TpvScene3DRendererPassesTopDownSkyOcclusionMapBlurRenderPass.Create(fFrameGraph,self,false);}

   TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapMeshFilterComputePass:=TpvScene3DRendererPassesMeshFilterComputePass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.ReflectiveShadowMap);
   TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapMeshFilterComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass);
   case Renderer.ShadowMode of
    TpvScene3DRendererShadowMode.None,
    TpvScene3DRendererShadowMode.PCF,TpvScene3DRendererShadowMode.DPCF,TpvScene3DRendererShadowMode.PCSS:begin
     TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapMeshFilterComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass);
    end;
    TpvScene3DRendererShadowMode.MSM:begin
     TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapMeshFilterComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapBlurRenderPasses[1]);
    end;
    else begin
    end;
   end;

   TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass:=TpvScene3DRendererPassesReflectiveShadowMapRenderPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapMeshFilterComputePass);
{  TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
   end;}
   TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass); //TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapBlurRenderPasses[1]);
   TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsClearCustomPass:=TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsClearCustomPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass:=TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsClearCustomPass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass:=TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass:=TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectFinalizationCustomPass:=TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectFinalizationCustomPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectFinalizationCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsBounceComputePass:=TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsBounceComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectFinalizationCustomPass);

  end;

  TpvScene3DRendererGlobalIlluminationMode.DynamicDiffuseGlobalIllumination:begin

   // DDGI is split into a swappable ray-tracing PRODUCER pass (writes the ray-data) and the technique-agnostic probe
   // BLEND/update CORE pass (irradiance/visibility/border), coupled only through the shared ray-data + probe images.
   // It needs the ray tracing acceleration structure (built outside the frame graph in TpvScene3D.UpdateCache) + the
   // light buffers; visibility for the gather shading is resolved with ray-traced shadow rays, so no shadow map dependency
   // is required. The main mesh culling/rendering is made to depend on the update pass further below.
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGITraceComputePass:=TpvScene3DRendererPassesGlobalIlluminationDDGITraceComputePass.Create(fFrameGraph,self);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fParticleBVHComputePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGITraceComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fParticleBVHComputePass);
   end;
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGITraceComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
   end;
   // The technique-agnostic probe BLEND/update CORE is split into one frame-graph pass per compute stage so each shader gets
   // its own GPU timer (separate profiler per-pass timing). They chain linearly; the last stage (classification when relocation
   // is on, else border) flips the shared firstFrames flag + publishes the probe writes to the fragment shading stages.
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIIrradianceUpdateComputePass:=TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.Create(fFrameGraph,self,TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.TStage.Irradiance,false);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIIrradianceUpdateComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGITraceComputePass);
   // Glossy radiance stage (opt-in): chained Irradiance -> GlossyRadiance -> Visibility (it reads the per-probe age the
   // visibility stage writes, like irradiance, so it must run before visibility). When off, Visibility depends on Irradiance.
   if TpvScene3DRendererInstance.GlobalIlluminationDDGIGlossyRadiance then begin
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIGlossyRadianceUpdateComputePass:=TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.Create(fFrameGraph,self,TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.TStage.GlossyRadiance,false);
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIGlossyRadianceUpdateComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIIrradianceUpdateComputePass);
   end;
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIVisibilityUpdateComputePass:=TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.Create(fFrameGraph,self,TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.TStage.Visibility,false);
   if TpvScene3DRendererInstance.GlobalIlluminationDDGIGlossyRadiance then begin
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIVisibilityUpdateComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIGlossyRadianceUpdateComputePass);
   end else begin
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIVisibilityUpdateComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIIrradianceUpdateComputePass);
   end;
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIBorderUpdateComputePass:=TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.Create(fFrameGraph,self,TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.TStage.Border,not TpvScene3DRendererInstance.GlobalIlluminationDDGIProbeRelocation);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIBorderUpdateComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIVisibilityUpdateComputePass);
   if TpvScene3DRendererInstance.GlobalIlluminationDDGIProbeRelocation then begin
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIRelocationComputePass:=TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.Create(fFrameGraph,self,TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.TStage.Relocation,false);
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIRelocationComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIBorderUpdateComputePass);
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIClassificationComputePass:=TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.Create(fFrameGraph,self,TpvScene3DRendererPassesGlobalIlluminationDDGIStageComputePass.TStage.Classification,true);
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIClassificationComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIRelocationComputePass);
    TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIClassificationComputePass);
   end else begin
    TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIBorderUpdateComputePass);
   end;

  end;

  TpvScene3DRendererGlobalIlluminationMode.SurfelGlobalIllumination:begin

   // Unlike DDGI, the surfel pass spawns from the camera depth buffer, so it runs AFTER the depth prepass (that ordering
   // comes automatically from its 'resourcetype_depth' image input) and BEFORE the shading passes (which depend on it,
   // set up further below). It must NOT be forced before mesh culling.
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationSurfelComputePass:=TpvScene3DRendererPassesGlobalIlluminationSurfelComputePass.Create(fFrameGraph,self);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationSurfelComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
   end;

  end;

  TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing:begin

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass:=TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.Create(fFrameGraph,self);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
   end;
{  TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
   end;}

   if Renderer.Scene3D.MeshShaders then begin
    // The whole VCT voxelization chain runs AFTER the cascaded shadow map but BEFORE the final-view mesh cull (the final-view
    // cull + everything after it take an explicit dependency on the VCT finalization pass below). It must NOT depend on the
    // final-view cull / depth (MeshCullPass1 / DepthPrepass / DepthMipMap): doing so forced it to run between the depth prepass
    // and the forward pass, where its voxelization mesh-cull overwrote the shared draw-command region the forward pass still needs.
    case Renderer.ShadowMode of
     TpvScene3DRendererShadowMode.None,
     TpvScene3DRendererShadowMode.PCF,TpvScene3DRendererShadowMode.DPCF,TpvScene3DRendererShadowMode.PCSS:begin
      TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass);
     end;
     TpvScene3DRendererShadowMode.MSM:begin
      TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapBlurRenderPasses[1]);
     end;
     else begin
     end;
    end;
   end else begin
    if assigned(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass) then begin
     TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass);
    end;
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass);
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   end;

   TpvScene3DRendererInstancePasses(fPasses).fVoxelizationMeshFilterComputePass:=TpvScene3DRendererPassesMeshFilterComputePass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.Voxelization);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fVoxelizationMeshFilterComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
   end;
   case Renderer.ShadowMode of
    TpvScene3DRendererShadowMode.None,
    TpvScene3DRendererShadowMode.PCF,TpvScene3DRendererShadowMode.DPCF,TpvScene3DRendererShadowMode.PCSS:begin
     TpvScene3DRendererInstancePasses(fPasses).fVoxelizationMeshFilterComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass);
    end;
    TpvScene3DRendererShadowMode.MSM:begin
     TpvScene3DRendererInstancePasses(fPasses).fVoxelizationMeshFilterComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapBlurRenderPasses[1]);
    end;
    else begin
    end;
   end;

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass:=TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fVoxelizationMeshFilterComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass);
// TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass); // Would create a cyclic frame graph dependency: MetaVoxelization depends (via MetaClear) on DepthPrepass/DepthMipMap/MeshCullPass1, which in turn depend on MeshCullPass0; the voxelization already runs after the final-view cull through that chain.

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingOcclusionTransferComputePass:=TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionTransferComputePass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingOcclusionTransferComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass:=TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingOcclusionTransferComputePass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingRadianceTransferComputePass:=TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingRadianceTransferComputePass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingRadianceTransferComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingOcclusionMipMapComputePass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingRadianceMipMapComputePass:=TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingRadianceMipMapComputePass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingRadianceMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingRadianceTransferComputePass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingFinalizationCustomPass:=TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingFinalizationCustomPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingFinalizationCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingRadianceMipMapComputePass);

   // Run the entire VCT chain BEFORE the final-view mesh cull: the final-view cull (and thus cull-depth, mesh-cull-pass1, depth
   // prepass, depth mipmap, forward — everything downstream of it) now depends on the VCT finalization pass, so the voxelization
   // mesh-cull no longer overwrites the shared draw-command region the forward pass reads. No cycle: the VCT chain above depends
   // only on the cascaded shadow map / atmosphere, not on the final-view cull.
   if Renderer.Scene3D.MeshShaders and assigned(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingRadianceMipMapComputePass);
   end;

  end;

  else begin
   TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass:=nil;
  end;

 end;

 if Renderer.ScreenSpaceAmbientOcclusion then begin

 {TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionDepthMipMapComputePass:=TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass.Create(fFrameGraph,self);
  begin
   TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionDepthMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass);
  end;//}

  TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionRenderPass:=TpvScene3DRendererPassesAmbientOcclusionRenderPass.Create(fFrameGraph,self);
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
  end;
//TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionDepthMipMapComputePass);
  TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
{ if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
  end;}

  TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionBlurRenderPasses[0]:=TpvScene3DRendererPassesAmbientOcclusionBlurRenderPass.Create(fFrameGraph,self,true);

  TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionBlurRenderPasses[1]:=TpvScene3DRendererPassesAmbientOcclusionBlurRenderPass.Create(fFrameGraph,self,false);

 end;

 case Renderer.GlobalIlluminationMode of

  TpvScene3DRendererGlobalIlluminationMode.CameraReflectionProbe:begin

   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeMeshFilterComputePass:=TpvScene3DRendererPassesMeshFilterComputePass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.ReflectionProbe);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeMeshFilterComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
   end;
   case Renderer.ShadowMode of
    TpvScene3DRendererShadowMode.None,
    TpvScene3DRendererShadowMode.PCF,TpvScene3DRendererShadowMode.DPCF,TpvScene3DRendererShadowMode.PCSS:begin
     TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeMeshFilterComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass);
    end;
    TpvScene3DRendererShadowMode.MSM:begin
     TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeMeshFilterComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapBlurRenderPasses[1]);
    end;
    else begin
    end;
   end;

   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass:=TpvScene3DRendererPassesReflectionProbeRenderPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeMeshFilterComputePass);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
   end;
   case Renderer.ShadowMode of
    TpvScene3DRendererShadowMode.None,
    TpvScene3DRendererShadowMode.PCF,TpvScene3DRendererShadowMode.DPCF,TpvScene3DRendererShadowMode.PCSS:begin
     TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass);
    end;
    TpvScene3DRendererShadowMode.MSM:begin
     TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapBlurRenderPasses[1]);
    end;
    else begin
    end;
   end;
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridAssignComputePass);
{  TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
   end;}
   // Coupling the reflection probe to the FINAL-VIEW HiZ cull cycles the frame graph: ReflectionProbe->MeshCullPass1 plus
   // MeshCullPass0->ReflectionProbe closes against MeshCullPass1->CullDepthPyramid->CullDepth->MeshCullPass0 (same trap as the
   // line ~5380 comment). The probe has its OWN cull (fReflectionProbeMeshFilterComputePass, above) and the forward pass already
   // orders after it via the ReflectionProbeCompute* chain, so the main-view cull couplings are not needed -> commented out.
{  if assigned(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass);
   end;
   TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass);}

   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeMipMapComputePass:=TpvScene3DRendererPassesReflectionProbeMipMapComputePass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass);

   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassGGX:=TpvScene3DRendererPassesReflectionProbeComputePass.Create(fFrameGraph,self,0);
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassGGX.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeMipMapComputePass);

   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassCharlie:=TpvScene3DRendererPassesReflectionProbeComputePass.Create(fFrameGraph,self,1);
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassCharlie.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeMipMapComputePass);

   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassLambertian:=TpvScene3DRendererPassesReflectionProbeComputePass.Create(fFrameGraph,self,2);
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassLambertian.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeMipMapComputePass);

  end;

  else begin
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeMeshFilterComputePass:=nil;
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass:=nil;
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassGGX:=nil;
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassCharlie:=nil;
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassLambertian:=nil;
  end;

 end;

 if Renderer.WetnessMapActive then begin
  TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass:=TpvScene3DRendererPassesWetnessMapComputePass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass);
  TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
 end else begin
  TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass:=nil;
 end;

 TpvScene3DRendererInstancePasses(fPasses).fForwardComputePass:=TpvScene3DRendererPassesForwardComputePass.Create(fFrameGraph,self);
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass);
 end;

 TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass:=TpvScene3DRendererPassesForwardRenderPass.Create(fFrameGraph,self);
 TpvScene3DRendererInstancePasses(fPasses).fForwardComputePass.ForwardRenderPass:=TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass;
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass);
 end;
 TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardComputePass);
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
 end;
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudShadowRenderPass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudShadowRenderPass);
 end;
{TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
 end;}
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassGGX);
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassCharlie);
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassLambertian);
 end;
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass);
 end;
 case Renderer.GlobalIlluminationMode of
  TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints:begin
   TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsBounceComputePass);
  end;
  TpvScene3DRendererGlobalIlluminationMode.DynamicDiffuseGlobalIllumination:begin
   // depend on the last DDGI update stage (it owns the final publish barrier to the fragment shading stages)
   if TpvScene3DRendererInstance.GlobalIlluminationDDGIProbeRelocation then begin
    TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIClassificationComputePass);
   end else begin
    TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationDDGIBorderUpdateComputePass);
   end;
  end;
  TpvScene3DRendererGlobalIlluminationMode.SurfelGlobalIllumination:begin
   TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationSurfelComputePass);
  end;
  TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing:begin
   TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingRadianceMipMapComputePass);
  end;
  else begin
  end;
 end;
 case Renderer.ShadowMode of
  TpvScene3DRendererShadowMode.None,
  TpvScene3DRendererShadowMode.PCF,TpvScene3DRendererShadowMode.DPCF,TpvScene3DRendererShadowMode.PCSS:begin
   TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass);
  end;
  TpvScene3DRendererShadowMode.MSM:begin
   TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapBlurRenderPasses[1]);
  end;
  else begin
  end;
 end;
 TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridAssignComputePass);
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass);
 end;
 TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
 if Renderer.ScreenSpaceAmbientOcclusion then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionBlurRenderPasses[1]);
 end;

 if fScene3D.EnableAtmosphere then begin

  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudShadowRenderPass:=TpvScene3DRendererPassesAtmosphereCloudShadowRenderPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudShadowRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
  // No dependency on the camera CullDepthRenderPass: the clouds shadow map is a view-independent top-down (octahedral) render
  // and never samples the camera depth (the depth sampling in atmosphere_clouds_raymarch.frag is #if'd out for CLOUDS_SHADOWMAP).
  // Coupling it to the camera depth was a leftover from the shared cloud-render path and closed a frame-graph cycle when a GI
  // mode that reads the clouds shadow map (e.g. cascaded radiance hints' RSM) forces the mesh cull after that GI source:
  // MeshCull0 -> RSM -> (reads clouds shadow map) CloudShadow -> CullDepth -> MeshCull0. Decoupled here + in the pass itself.

  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudRenderPass:=TpvScene3DRendererPassesAtmosphereCloudRenderPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass);
  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
  // Ensure AtmosphereCloudRenderPass waits for atmosphere simulation to complete
  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);

  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass:=TpvScene3DRendererPassesAtmosphereRenderPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass);
  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudRenderPass);
  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
  // Ensure AtmosphereRenderPass waits for atmosphere simulation to complete
  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationWaitCustomPass);

  // Rain requires Atmosphere, so only enable if both are true
  if fScene3D.EnableRain then begin
   TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass:=TpvScene3DRendererPassesRainRenderPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass);
   TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass);
   TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudRenderPass);
  end else begin
   TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass:=nil;
  end;

 end else begin

  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudRenderPass:=nil;
  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudShadowRenderPass:=nil;
  TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass:=nil;
  TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass:=nil;

 end;

 if Renderer.SurfaceSampleCountFlagBits<>TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardResolveRenderPass:=TpvScene3DRendererPassesForwardResolveRenderPass.Create(fFrameGraph,self);
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fForwardResolveRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass);
  end;
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fForwardResolveRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass);
  end;
 end;

 TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass:=TpvScene3DRendererPassesForwardRenderMipMapComputePass.Create(fFrameGraph,self);
 TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass);
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass);
 end;
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass);
 end;
 if Renderer.SurfaceSampleCountFlagBits<>TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardResolveRenderPass);
 end;

{TpvScene3DRendererInstancePasses(fPasses).fPlanetWaterPrepassComputePass:=TpvScene3DRendererPassesPlanetWaterPrepassComputePass.Create(fFrameGraph,self);
TpvScene3DRendererInstancePasses(fPasses).fPlanetWaterPrepassComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);}

 if fScene3D.EnableWater then begin

  TpvScene3DRendererInstancePasses(fPasses).fWaterWaitCustomPass:=TpvScene3DRendererPassesWaterWaitCustomPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fWaterWaitCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
  if fScene3D.PlanetWaterSimulationUseParallelQueue then begin
   FreeAndNil(fWaterExternalWaitingOnSemaphore);
   fWaterExternalWaitingOnSemaphore:=TpvFrameGraph.TExternalWaitingOnSemaphore.Create(fFrameGraph);
   try
    for InFlightFrameIndex:=0 to fFrameGraph.CountInFlightFrames-1 do begin
     fWaterExternalWaitingOnSemaphore.InFlightFrameSemaphores[InFlightFrameIndex]:=fWaterSimulationSemaphores[InFlightFrameIndex];
    end;
   finally
 // TpvScene3DRendererInstancePasses(fPasses).fWaterWaitCustomPass.AddExternalWaitingOnSemaphore(fWaterExternalWaitingOnSemaphore,TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TESSELLATION_CONTROL_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TESSELLATION_EVALUATION_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT));
    TpvScene3DRendererInstancePasses(fPasses).fWaterWaitCustomPass.AddExternalWaitingOnSemaphore(fWaterExternalWaitingOnSemaphore,TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT));
   end;
  end else begin
   fWaterExternalWaitingOnSemaphore:=nil;
  end;

  TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass:=TpvScene3DRendererPassesWaterRenderPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
  TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterWaitCustomPass);

  TpvScene3DRendererInstancePasses(fPasses).fPlanetWaterCausticsComputePass:=TpvScene3DRendererPassesPlanetWaterCausticsComputePass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fPlanetWaterCausticsComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
  TpvScene3DRendererInstancePasses(fPasses).fPlanetWaterCausticsComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass);
  TpvScene3DRendererInstancePasses(fPasses).fPlanetWaterCausticsComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterWaitCustomPass);
  TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fPlanetWaterCausticsComputePass);

 end else begin

  TpvScene3DRendererInstancePasses(fPasses).fWaterWaitCustomPass:=nil;
  fWaterExternalWaitingOnSemaphore:=nil;
  TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass:=nil;
  TpvScene3DRendererInstancePasses(fPasses).fPlanetWaterCausticsComputePass:=nil;

 end;

 PreLastPass:=nil;
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass) then begin
  LastPass:=TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass;
 end else begin
  LastPass:=TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass;
 end;

 case Renderer.TransparencyMode of

  TpvScene3DRendererTransparencyMode.Direct:begin

   TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyRenderPass:=TpvScene3DRendererPassesDirectTransparencyRenderPass.Create(fFrameGraph,self);
// TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass);
   end;

   PreLastPass:=TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyRenderPass;

   TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyResolveRenderPass:=TpvScene3DRendererPassesDirectTransparencyResolveRenderPass.Create(fFrameGraph,self);

   LastPass:=TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyResolveRenderPass;

  end;

  TpvScene3DRendererTransparencyMode.SPINLOCKOIT,
  TpvScene3DRendererTransparencyMode.INTERLOCKOIT:begin

   TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyClearCustomPass:=TpvScene3DRendererPassesLockOrderIndependentTransparencyClearCustomPass.Create(fFrameGraph,self);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass);
   end;

   TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyRenderPass:=TpvScene3DRendererPassesLockOrderIndependentTransparencyRenderPass.Create(fFrameGraph,self);
// TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyClearCustomPass);
   TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass);

   TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyBarrierCustomPass:=TpvScene3DRendererPassesLockOrderIndependentTransparencyBarrierCustomPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyBarrierCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyRenderPass);

   PreLastPass:=TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyBarrierCustomPass;

   TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyResolveRenderPass:=TpvScene3DRendererPassesLockOrderIndependentTransparencyResolveRenderPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyResolveRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyBarrierCustomPass);

   LastPass:=TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyResolveRenderPass;

  end;

  TpvScene3DRendererTransparencyMode.LOOPOIT:begin

   TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyClearCustomPass:=TpvScene3DRendererPassesLoopOrderIndependentTransparencyClearCustomPass.Create(fFrameGraph,self);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass);
   end;

   TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass1RenderPass:=TpvScene3DRendererPassesLoopOrderIndependentTransparencyPass1RenderPass.Create(fFrameGraph,self);
// TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass1RenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass1RenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyClearCustomPass);
   TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass1RenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass1RenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass);

   TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass1BarrierCustomPass:=TpvScene3DRendererPassesLoopOrderIndependentTransparencyPass1BarrierCustomPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass1BarrierCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass1RenderPass);

   TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass2RenderPass:=TpvScene3DRendererPassesLoopOrderIndependentTransparencyPass2RenderPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass2RenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass1BarrierCustomPass);

   TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass2BarrierCustomPass:=TpvScene3DRendererPassesLoopOrderIndependentTransparencyPass2BarrierCustomPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass2BarrierCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass2RenderPass);

   PreLastPass:=TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass2BarrierCustomPass;

   TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyResolveRenderPass:=TpvScene3DRendererPassesLoopOrderIndependentTransparencyResolveRenderPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyResolveRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyPass2BarrierCustomPass);

   LastPass:=TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyResolveRenderPass;

  end;

  TpvScene3DRendererTransparencyMode.WBOIT:begin

   TpvScene3DRendererInstancePasses(fPasses).fWeightBlendedOrderIndependentTransparencyRenderPass:=TpvScene3DRendererPassesWeightBlendedOrderIndependentTransparencyRenderPass.Create(fFrameGraph,self);
// TpvScene3DRendererInstancePasses(fPasses).fWeightBlendedOrderIndependentTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fWeightBlendedOrderIndependentTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fWeightBlendedOrderIndependentTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fWeightBlendedOrderIndependentTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass);
   end;

   PreLastPass:=TpvScene3DRendererInstancePasses(fPasses).fWeightBlendedOrderIndependentTransparencyRenderPass;

   TpvScene3DRendererInstancePasses(fPasses).fWeightBlendedOrderIndependentTransparencyResolveRenderPass:=TpvScene3DRendererPassesWeightBlendedOrderIndependentTransparencyResolveRenderPass.Create(fFrameGraph,self);

   LastPass:=TpvScene3DRendererInstancePasses(fPasses).fWeightBlendedOrderIndependentTransparencyResolveRenderPass;

  end;

  TpvScene3DRendererTransparencyMode.MBOIT:begin

   TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyAbsorbanceRenderPass:=TpvScene3DRendererPassesMomentBasedOrderIndependentTransparencyAbsorbanceRenderPass.Create(fFrameGraph,self);
// TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyAbsorbanceRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyAbsorbanceRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyAbsorbanceRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyAbsorbanceRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass);
   end;

   TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyTransmittanceRenderPass:=TpvScene3DRendererPassesMomentBasedOrderIndependentTransparencyTransmittanceRenderPass.Create(fFrameGraph,self);

   PreLastPass:=TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyTransmittanceRenderPass;

   TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyResolveRenderPass:=TpvScene3DRendererPassesMomentBasedOrderIndependentTransparencyResolveRenderPass.Create(fFrameGraph,self);

   LastPass:=TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyResolveRenderPass;

  end;

  TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT,
  TpvScene3DRendererTransparencyMode.INTERLOCKDFAOIT:begin

   TpvScene3DRendererInstancePasses(fPasses).fDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass:=TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass.Create(fFrameGraph,self);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass);
   end;

   TpvScene3DRendererInstancePasses(fPasses).fDeepAndFastApproximateOrderIndependentTransparencyRenderPass:=TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyRenderPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fDeepAndFastApproximateOrderIndependentTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass);
// TpvScene3DRendererInstancePasses(fPasses).fDeepAndFastApproximateOrderIndependentTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fDeepAndFastApproximateOrderIndependentTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fDeepAndFastApproximateOrderIndependentTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass);

   PreLastPass:=TpvScene3DRendererInstancePasses(fPasses).fDeepAndFastApproximateOrderIndependentTransparencyRenderPass;

   TpvScene3DRendererInstancePasses(fPasses).fDeepAndFastApproximateOrderIndependentTransparencyResolveRenderPass:=TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyResolveRenderPass.Create(fFrameGraph,self);

   LastPass:=TpvScene3DRendererInstancePasses(fPasses).fDeepAndFastApproximateOrderIndependentTransparencyResolveRenderPass;

  end

  else begin
   Assert(false);
  end;

 end;

 if //(not Renderer.Scene3D.MeshShaders) and
    assigned(PreLastPass) and
    assigned(LastPass) and
    assigned(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingFinalizationCustomPass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingFinalizationCustomPass.AddExplicitPassDependency(PreLastPass);
  LastPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingFinalizationCustomPass);
 end;

 if assigned(LastOutputResource) and
    (LastOutputResource.Resource.Name='resource_combinedopaquetransparency_final_msaa_color') then begin
  TpvScene3DRendererInstancePasses(fPasses).fOrderIndependentTransparencyResolveRenderPass:=TpvScene3DRendererPassesOrderIndependentTransparencyResolveRenderPass.Create(fFrameGraph,self);
 end;

 AntialiasingFirstPass:=nil;
 AntialiasingLastPass:=nil;

 begin

  TpvScene3DRendererInstancePasses(fPasses).fLuminanceHistogramComputePass:=TpvScene3DRendererPassesLuminanceHistogramComputePass.Create(fFrameGraph,self);

  TpvScene3DRendererInstancePasses(fPasses).fLuminanceAverageComputePass:=TpvScene3DRendererPassesLuminanceAverageComputePass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fLuminanceAverageComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLuminanceHistogramComputePass);

  TpvScene3DRendererInstancePasses(fPasses).fLuminanceAdaptationRenderPass:=TpvScene3DRendererPassesLuminanceAdaptationRenderPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fLuminanceAdaptationRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLuminanceAverageComputePass);

 end;

(**)
 case Renderer.AntialiasingMode of

  TpvScene3DRendererAntialiasingMode.DSAA:begin
   TpvScene3DRendererInstancePasses(fPasses).fAntialiasingDSAARenderPass:=TpvScene3DRendererPassesAntialiasingDSAARenderPass.Create(fFrameGraph,self);
   AntialiasingFirstPass:=TpvScene3DRendererInstancePasses(fPasses).fAntialiasingDSAARenderPass;
   AntialiasingLastPass:=TpvScene3DRendererInstancePasses(fPasses).fAntialiasingDSAARenderPass;
  end;

  TpvScene3DRendererAntialiasingMode.FXAA:begin
   TpvScene3DRendererInstancePasses(fPasses).fAntialiasingFXAARenderPass:=TpvScene3DRendererPassesAntialiasingFXAARenderPass.Create(fFrameGraph,self);
   AntialiasingFirstPass:=TpvScene3DRendererInstancePasses(fPasses).fAntialiasingFXAARenderPass;
   AntialiasingLastPass:=TpvScene3DRendererInstancePasses(fPasses).fAntialiasingFXAARenderPass;
  end;

  TpvScene3DRendererAntialiasingMode.SMAA,
  TpvScene3DRendererAntialiasingMode.SMAAT2x,
  TpvScene3DRendererAntialiasingMode.MSAASMAA:begin

   case Renderer.AntialiasingMode of

    TpvScene3DRendererAntialiasingMode.SMAAT2x:begin

     TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAEdgesRenderPass:=TpvScene3DRendererPassesAntialiasingSMAAEdgesRenderPass.Create(fFrameGraph,self);

     TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAWeightsRenderPass:=TpvScene3DRendererPassesAntialiasingSMAAWeightsRenderPass.Create(fFrameGraph,self);

     TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAABlendRenderPass:=TpvScene3DRendererPassesAntialiasingSMAABlendRenderPass.Create(fFrameGraph,self);

     TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAT2xPreCustomPass:=TpvScene3DRendererPassesAntialiasingSMAAT2xPreCustomPass.Create(fFrameGraph,self);
     TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAT2xPreCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAABlendRenderPass);

     TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAT2xTemporalResolveRenderPass:=TpvScene3DRendererPassesAntialiasingSMAAT2xTemporalResolveRenderPass.Create(fFrameGraph,self);
     TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAT2xTemporalResolveRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAT2xPreCustomPass);

     TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAT2xPostCustomPass:=TpvScene3DRendererPassesAntialiasingSMAAT2xPostCustomPass.Create(fFrameGraph,self);
     TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAT2xPostCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAT2xTemporalResolveRenderPass);

     AntialiasingFirstPass:=TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAEdgesRenderPass;
     AntialiasingLastPass:=TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAT2xPostCustomPass;

    end;

    else begin

     TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAEdgesRenderPass:=TpvScene3DRendererPassesAntialiasingSMAAEdgesRenderPass.Create(fFrameGraph,self);
     TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAWeightsRenderPass:=TpvScene3DRendererPassesAntialiasingSMAAWeightsRenderPass.Create(fFrameGraph,self);
     TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAABlendRenderPass:=TpvScene3DRendererPassesAntialiasingSMAABlendRenderPass.Create(fFrameGraph,self);
     AntialiasingFirstPass:=TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAAEdgesRenderPass;
     AntialiasingLastPass:=TpvScene3DRendererInstancePasses(fPasses).fAntialiasingSMAABlendRenderPass;

    end;

   end;

  end;

  TpvScene3DRendererAntialiasingMode.TAA:begin

   TpvScene3DRendererInstancePasses(fPasses).fAntialiasingTAAPreCustomPass:=TpvScene3DRendererPassesAntialiasingTAAPreCustomPass.Create(fFrameGraph,self);
   AntialiasingFirstPass:=TpvScene3DRendererInstancePasses(fPasses).fAntialiasingTAAPreCustomPass;

   TpvScene3DRendererInstancePasses(fPasses).fAntialiasingTAARenderPass:=TpvScene3DRendererPassesAntialiasingTAARenderPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fAntialiasingTAARenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAntialiasingTAAPreCustomPass);
   TpvScene3DRendererInstancePasses(fPasses).fAntialiasingTAARenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLuminanceAdaptationRenderPass);

   TpvScene3DRendererInstancePasses(fPasses).fAntialiasingTAAPostCustomPass:=TpvScene3DRendererPassesAntialiasingTAAPostCustomPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fAntialiasingTAAPostCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAntialiasingTAARenderPass);
   AntialiasingLastPass:=TpvScene3DRendererInstancePasses(fPasses).fAntialiasingTAAPostCustomPass;

  end;

  else begin
{  TpvScene3DRendererInstancePasses(fPasses).fAntialiasingNoneRenderPass:=TpvScene3DRendererPassesAntialiasingNoneRenderPass.Create(fFrameGraph,self);
   AntialiasingFirstPass:=TpvScene3DRendererInstancePasses(fPasses).fAntialiasingNoneRenderPass;
   AntialiasingLastPass:=TpvScene3DRendererInstancePasses(fPasses).fAntialiasingNoneRenderPass;}
  end;

 end;//*)

 if assigned(AntialiasingFirstPass) then begin
  case Renderer.TransparencyMode of
   TpvScene3DRendererTransparencyMode.Direct:begin
    AntialiasingFirstPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyResolveRenderPass);
   end;
   TpvScene3DRendererTransparencyMode.SPINLOCKOIT,
   TpvScene3DRendererTransparencyMode.INTERLOCKOIT:begin
    AntialiasingFirstPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyResolveRenderPass);
   end;
   TpvScene3DRendererTransparencyMode.LOOPOIT:begin
    AntialiasingFirstPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyResolveRenderPass);
   end;
   TpvScene3DRendererTransparencyMode.WBOIT:begin
    AntialiasingFirstPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWeightBlendedOrderIndependentTransparencyResolveRenderPass);
   end;
   TpvScene3DRendererTransparencyMode.MBOIT:begin
    AntialiasingFirstPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyResolveRenderPass);
   end;
   TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT,
   TpvScene3DRendererTransparencyMode.INTERLOCKDFAOIT:begin
    AntialiasingFirstPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDeepAndFastApproximateOrderIndependentTransparencyResolveRenderPass);
   end;
   else begin
    AntialiasingFirstPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass);
   end;
  end;
 end;

(**)
 if (Renderer.DepthOfFieldMode<>TpvScene3DRendererDepthOfFieldMode.None) and not assigned(VirtualReality) then begin

  TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldAutoFocusComputePass:=TpvScene3DRendererPassesDepthOfFieldAutoFocusComputePass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldAutoFocusComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);

  TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldPrepareRenderPass:=TpvScene3DRendererPassesDepthOfFieldPrepareRenderPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldPrepareRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldAutoFocusComputePass);

  case Renderer.DepthOfFieldMode of

   TpvScene3DRendererDepthOfFieldMode.HalfResSeparateNearFar,
   TpvScene3DRendererDepthOfFieldMode.HalfResBruteforce:begin

    TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldBokehComputePass:=TpvScene3DRendererPassesDepthOfFieldBokehComputePass.Create(fFrameGraph,self);

    TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldPrefilterRenderPass:=TpvScene3DRendererPassesDepthOfFieldPrefilterRenderPass.Create(fFrameGraph,self);

    TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldBlurRenderPass:=TpvScene3DRendererPassesDepthOfFieldBlurRenderPass.Create(fFrameGraph,self);
    TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldBlurRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldBokehComputePass);

    TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldPostBlurRenderPass:=TpvScene3DRendererPassesDepthOfFieldPostBlurRenderPass.Create(fFrameGraph,self);

    TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldCombineRenderPass:=TpvScene3DRendererPassesDepthOfFieldCombineRenderPass.Create(fFrameGraph,self);

   end;

   TpvScene3DRendererDepthOfFieldMode.FullResBruteforce:begin

    TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldBokehComputePass:=TpvScene3DRendererPassesDepthOfFieldBokehComputePass.Create(fFrameGraph,self);

    TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldBruteforceRenderPass:=TpvScene3DRendererPassesDepthOfFieldBruteforceRenderPass.Create(fFrameGraph,self);
    TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldBruteforceRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldBokehComputePass);

   end;

   else {TpvScene3DRendererDepthOfFieldMode.FullResHexagon:}begin

    TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldGatherPass1RenderPass:=TpvScene3DRendererPassesDepthOfFieldGatherPass1RenderPass.Create(fFrameGraph,self);

    TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldGatherPass2RenderPass:=TpvScene3DRendererPassesDepthOfFieldGatherPass2RenderPass.Create(fFrameGraph,self);

   end;

  end;

  TpvScene3DRendererInstancePasses(fPasses).fDepthOfFieldResolveRenderPass:=TpvScene3DRendererPassesDepthOfFieldResolveRenderPass.Create(fFrameGraph,self);

 end; //*)

 if not (fPostProcessingAtScaledResolution or SameValue(fSizeFactor,1.0)) then begin
  // Resampling BEFORE Lens passes
  if Renderer.AIUpscaleMode<>TpvScene3DRendererAIUpscaleMode.None then begin
   TpvScene3DRendererInstancePasses(fPasses).fCNNUpscalerComputePass:=TpvScene3DRendererPassesCNNUpscalerComputePass.Create(fFrameGraph,self);
  end else begin
   case Renderer.ResamplingMode of
    TpvScene3DRendererResamplingMode.EASU:begin
     TpvScene3DRendererInstancePasses(fPasses).fEASURCASComputePass:=TpvScene3DRendererPassesEASURCASComputePass.Create(fFrameGraph,self);
    end;
    else begin
     TpvScene3DRendererInstancePasses(fPasses).fResamplingRenderPass:=TpvScene3DRendererPassesResamplingRenderPass.Create(fFrameGraph,self);
    end;
   end;
  end;
 end;

 if not assigned(VirtualReality) then begin

  case Renderer.LensMode of

   TpvScene3DRendererLensMode.DownUpsample:begin

    TpvScene3DRendererInstancePasses(fPasses).fLensDownsampleComputePass:=TpvScene3DRendererPassesLensDownsampleComputePass.Create(fFrameGraph,self);

    TpvScene3DRendererInstancePasses(fPasses).fLensUpsampleComputePass:=TpvScene3DRendererPassesLensUpsampleComputePass.Create(fFrameGraph,self);
    TpvScene3DRendererInstancePasses(fPasses).fLensUpsampleComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLensDownsampleComputePass);

    TpvScene3DRendererInstancePasses(fPasses).fLensResolveRenderPass:=TpvScene3DRendererPassesLensResolveRenderPass.Create(fFrameGraph,self);
    TpvScene3DRendererInstancePasses(fPasses).fLensResolveRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLensUpsampleComputePass);

   end;

   else begin
   end;

  end;

 end;

 if fLensRainPostEffectActive then begin
  TpvScene3DRendererInstancePasses(fPasses).fLensRainRenderPass:=TpvScene3DRendererPassesLensRainRenderPass.Create(fFrameGraph,self);
 end else begin
  TpvScene3DRendererInstancePasses(fPasses).fLensRainRenderPass:=nil;
 end;

 if fPostProcessingAtScaledResolution and not SameValue(fSizeFactor,1.0) then begin
  // Resampling AFTER Lens passes
  if Renderer.AIUpscaleMode<>TpvScene3DRendererAIUpscaleMode.None then begin
   TpvScene3DRendererInstancePasses(fPasses).fCNNUpscalerComputePass:=TpvScene3DRendererPassesCNNUpscalerComputePass.Create(fFrameGraph,self);
  end else begin
   case Renderer.ResamplingMode of
    TpvScene3DRendererResamplingMode.EASU:begin
     TpvScene3DRendererInstancePasses(fPasses).fEASURCASComputePass:=TpvScene3DRendererPassesEASURCASComputePass.Create(fFrameGraph,self);
    end;
    else begin
     TpvScene3DRendererInstancePasses(fPasses).fResamplingRenderPass:=TpvScene3DRendererPassesResamplingRenderPass.Create(fFrameGraph,self);
    end;
   end;
  end;
 end;

 TpvScene3DRendererInstancePasses(fPasses).fTonemappingRenderPass:=TpvScene3DRendererPassesTonemappingRenderPass.Create(fFrameGraph,self);
 TpvScene3DRendererInstancePasses(fPasses).fTonemappingRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLuminanceAverageComputePass);

 if assigned(AntialiasingLastPass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fTonemappingRenderPass.AddExplicitPassDependency(AntialiasingLastPass);
 end;

 // Object-selection outline, step 1 — BUILD: reads only the selection mask, writes the isolated premultiplied outline buffer
 // (does NOT touch LastOutputResource). Consuming the mask is what pulls the whole selection chain (list -> mask -> here) in.
 TpvScene3DRendererInstancePasses(fPasses).fSelectionOutlineBuildRenderPass:=TpvScene3DRendererPassesSelectionOutlineBuildRenderPass.Create(fFrameGraph,self);
 TpvScene3DRendererInstancePasses(fPasses).fSelectionOutlineBuildRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fSelectionMaskRenderPass);

 // Object-selection outline, step 2 — FXAA + COMPOSITE: anti-aliases the outline buffer in isolation, composites it over the
 // scene (= LastOutputResource, still the tonemapping output here) and updates LastOutputResource -> the canvas/UI (read below
 // from LastOutputResource) sits ON TOP of the outline.
 TpvScene3DRendererInstancePasses(fPasses).fSelectionOutlineFXAAComposeRenderPass:=TpvScene3DRendererPassesSelectionOutlineFXAAComposeRenderPass.Create(fFrameGraph,self);
 TpvScene3DRendererInstancePasses(fPasses).fSelectionOutlineFXAAComposeRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fSelectionOutlineBuildRenderPass);
 TpvScene3DRendererInstancePasses(fPasses).fSelectionOutlineFXAAComposeRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fTonemappingRenderPass);

 TpvScene3DRendererInstancePasses(fPasses).fCanvasComputePass:=TpvScene3DRendererPassesCanvasComputePass.Create(fFrameGraph,self);

 TpvScene3DRendererInstancePasses(fPasses).fCanvasRenderPass:=TpvScene3DRendererPassesCanvasRenderPass.Create(fFrameGraph,self);
 TpvScene3DRendererInstancePasses(fPasses).fCanvasRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCanvasComputePass);
 TpvScene3DRendererInstancePasses(fPasses).fCanvasRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fTonemappingRenderPass);

 if assigned(fHUDCustomPassClass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fHUDCustomPass:=fHUDCustomPassClass.Create(fFrameGraph,self,fHUDCustomPassParent);
  TpvScene3DRendererInstancePasses(fPasses).fHUDCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fTonemappingRenderPass);
  TpvScene3DRendererInstancePasses(fPasses).fHUDCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCanvasRenderPass);
 end else begin
  TpvScene3DRendererInstancePasses(fPasses).fHUDCustomPass:=nil;
 end;

 if assigned(fHUDComputePassClass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fHUDComputePass:=fHUDComputePassClass.Create(fFrameGraph,self,fHUDComputePassParent);
  TpvScene3DRendererInstancePasses(fPasses).fHUDComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fTonemappingRenderPass);
  TpvScene3DRendererInstancePasses(fPasses).fHUDComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCanvasRenderPass);
 end else begin
  TpvScene3DRendererInstancePasses(fPasses).fHUDComputePass:=nil;
 end;

 if assigned(fHUDRenderPassClass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fHUDRenderPass:=fHUDRenderPassClass.Create(fFrameGraph,self,fHUDRenderPassParent);
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fHUDCustomPass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fHUDRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fHUDCustomPass);
  end;
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fHUDComputePass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fHUDRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fHUDComputePass);
  end;
  TpvScene3DRendererInstancePasses(fPasses).fHUDRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fTonemappingRenderPass);
  TpvScene3DRendererInstancePasses(fPasses).fHUDRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCanvasRenderPass);

  TpvScene3DRendererInstancePasses(fPasses).fHUDMipMapCustomPass:=TpvScene3DRendererPassesHUDMipMapCustomPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fHUDMipMapCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fHUDRenderPass);

  TpvScene3DRendererInstancePasses(fPasses).fContentProjectionRenderPass:=TpvScene3DRendererPassesContentProjectionRenderPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fContentProjectionRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fHUDMipMapCustomPass);

 end else begin

  TpvScene3DRendererInstancePasses(fPasses).fHUDRenderPass:=nil;

  TpvScene3DRendererInstancePasses(fPasses).fHUDMipMapCustomPass:=nil;

  TpvScene3DRendererInstancePasses(fPasses).fContentProjectionRenderPass:=nil;

 end;

 if fScene3D.EnableAtmosphere then begin
  TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass:=TpvScene3DRendererPassesAtmospherePrecipitationReleaseCustomPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass);
  TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudRenderPass);
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass);
  end;
 end else begin
  TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass:=nil;
 end;

 if fScene3D.EnableWater then begin
  TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass:=TpvScene3DRendererPassesWaterReleaseCustomPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass);
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass);
  end;
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fHUDCustomPass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fHUDCustomPass);
  end;
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fHUDComputePass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fHUDComputePass);
  end;
  if assigned(fHUDRenderPassClass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fHUDRenderPass);
   TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fContentProjectionRenderPass);
  end;
  TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCanvasRenderPass);
 end else begin
  TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass:=nil;
 end;

 if fUseDebugBlit then begin

  TpvScene3DRendererInstancePasses(fPasses).fDebugBlitRenderPass:=TpvScene3DRendererPassesDebugBlitRenderPass.Create(fFrameGraph,self);
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fHUDCustomPass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fDebugBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fHUDCustomPass);
  end;
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fHUDComputePass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fDebugBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fHUDComputePass);
  end;
  if assigned(fHUDRenderPassClass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fDebugBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fHUDRenderPass);
   TpvScene3DRendererInstancePasses(fPasses).fDebugBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fContentProjectionRenderPass);
  end;
  TpvScene3DRendererInstancePasses(fPasses).fDebugBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCanvasRenderPass);
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fDebugBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass);
  end;
  if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fDebugBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass);
  end;

  fFrameGraph.RootPass:=TpvScene3DRendererInstancePasses(fPasses).fDebugBlitRenderPass;

 end;

 TpvScene3DRendererInstancePasses(fPasses).fFrameBufferBlitRenderPass:=TpvScene3DRendererPassesFrameBufferBlitRenderPass.Create(fFrameGraph,self,true);
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fHUDCustomPass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fFrameBufferBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fHUDCustomPass);
 end;
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fHUDComputePass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fFrameBufferBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fHUDComputePass);
 end;
 if assigned(fHUDRenderPassClass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fFrameBufferBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fHUDRenderPass);
  TpvScene3DRendererInstancePasses(fPasses).fFrameBufferBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fContentProjectionRenderPass);
 end;
 TpvScene3DRendererInstancePasses(fPasses).fFrameBufferBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fCanvasRenderPass);
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fFrameBufferBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass);
 end;
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fFrameBufferBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass);
 end;

 fFrameGraph.RootPass:=TpvScene3DRendererInstancePasses(fPasses).fFrameBufferBlitRenderPass;

 fFrameGraph.DoWaitOnSemaphore:=true;

 fFrameGraph.DoSignalSemaphore:=true;

 fFrameGraph.Compile;

end;

procedure TpvScene3DRendererInstance.AcquirePersistentResources;
var InFlightFrameIndex,PerInFlightFrameBufferIndex:TpvSizeInt;
    Stream:TStream;
    RenderPass:TpvScene3DRendererRenderPass;
    CullRenderPass:TpvScene3DRendererCullRenderPass;
begin

 // 16MB minimum for mesh shader output = 524288 slots of 32 bytes each

 for PerInFlightFrameBufferIndex:=0 to MaxInFlightFrames-1 do begin
  fMeshShaderOutputBufferSizes[PerInFlightFrameBufferIndex]:=524288;
 end;

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin

  fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[InFlightFrameIndex]:=65536;

  fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[InFlightFrameIndex].Initialize;
  fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[InFlightFrameIndex].Resize(fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[InFlightFrameIndex]);
  fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[InFlightFrameIndex].Count:=0;

 end;

 if assigned(Renderer.VulkanDevice) then begin

  fViewBuffersDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(Renderer.VulkanDevice);
  fViewBuffersDescriptorSetLayout.AddBinding(0,
                                             VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT) or
                                             TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                             []);
  fViewBuffersDescriptorSetLayout.Initialize;
  Renderer.VulkanDevice.DebugUtils.SetObjectName(fViewBuffersDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DRendererInstance.fViewBuffersDescriptorSetLayout');

  begin

   if (Renderer.ShadowMode=TpvScene3DRendererShadowMode.MSM) and (Renderer.ShadowMapSampleCountFlagBits<>TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT)) then begin
    fCascadedShadowMapCullDepthArray2DImage:=TpvScene3DRendererArray2DImage.Create(fScene3D.VulkanDevice,fCascadedShadowMapWidth,fCascadedShadowMapHeight,CountCascadedShadowMapCascades,VK_FORMAT_R32_SFLOAT,VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,true,pvAllocationGroupIDScene3DStatic,VK_FORMAT_UNDEFINED,VK_SHARING_MODE_EXCLUSIVE,nil,'TpvScene3DRendererInstance.fCascadedShadowMapCullDepthArray2DImage');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fCascadedShadowMapCullDepthArray2DImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fCascadedShadowMapCullDepthArray2DImage.Image');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fCascadedShadowMapCullDepthArray2DImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fCascadedShadowMapCullDepthArray2DImage.ImageView');
   end else begin
    fCascadedShadowMapCullDepthArray2DImage:=nil;
   end;

   for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin
    fCascadedShadowMapCullDepthPyramidMipmappedArray2DImages[InFlightFrameIndex]:=TpvScene3DRendererMipmappedArray2DImage.Create(fScene3D.VulkanDevice,Max(1,RoundDownToPowerOfTwo(fCascadedShadowMapWidth)),Max(1,RoundDownToPowerOfTwo(fCascadedShadowMapHeight)),CountCascadedShadowMapCascades,VK_FORMAT_R32_SFLOAT,VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,pvAllocationGroupIDScene3DStatic,'TpvScene3DRendererInstance.fCascadedShadowMapCullDepthPyramidMipmappedArray2DImages['+IntToStr(InFlightFrameIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fCascadedShadowMapCullDepthPyramidMipmappedArray2DImages[InFlightFrameIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fCascadedShadowMapCullDepthPyramidMipmappedArray2DImages['+IntToStr(InFlightFrameIndex)+'].Image');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fCascadedShadowMapCullDepthPyramidMipmappedArray2DImages[InFlightFrameIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fCascadedShadowMapCullDepthPyramidMipmappedArray2DImages['+IntToStr(InFlightFrameIndex)+'].ImageView');
   end;

  end;

  for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin

   case fScene3D.BufferStreamingMode of

    TpvScene3D.TBufferStreamingMode.Direct:begin

     fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                      IfThen(Renderer.Scene3D.MeshShaders,Max(1,Max(fMeshShaderOutputBufferSizes[PerInFlightFrameBufferIndex],fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[0]))*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand),Max(1,fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[0])*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand)),
                                                                                                      TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                                      TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                      [],
                                                                                                      TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                      0,
                                                                                                      0,
                                                                                                      TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                      0,
                                                                                                      0,
                                                                                                      0,
                                                                                                      0,
                                                                                                      [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                                      0,
                                                                                                      pvAllocationGroupIDScene3DDynamic,
                                                                                                      '3DRendererInstance.CmdOutputBuffer'
                                                                                                     );
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CmdOutputBuffer');

    end;

    TpvScene3D.TBufferStreamingMode.Staging:begin

     fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                      IfThen(Renderer.Scene3D.MeshShaders,Max(1,Max(fMeshShaderOutputBufferSizes[PerInFlightFrameBufferIndex],fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[0]))*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand),Max(1,fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[0])*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand)),
                                                                                                      TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                                      TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                      [],
                                                                                                      TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                      0,
                                                                                                      0,
                                                                                                      TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                      0,
                                                                                                      0,
                                                                                                      0,
                                                                                                      0,
                                                                                                      [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                                      0,
                                                                                                      pvAllocationGroupIDScene3DDynamic,
                                                                                                      '3DRendererInstance.CmdOutputBuffer'
                                                                                                     );
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CmdOutputBuffer');

    end;

    else begin
     Assert(false);
    end;

   end;

   // Track output buffer capacity
   if Renderer.Scene3D.MeshShaders then begin
    fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex]:=Max(fMeshShaderOutputBufferSizes[PerInFlightFrameBufferIndex],fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[0]);
   end else begin
    fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex]:=fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[0];
   end;

   // Scratch buffer for MESHLET_EXPAND sort: header (16 bytes) + 48 bytes per entry
   fMeshCullMaxScratchEntries[PerInFlightFrameBufferIndex]:=Max(1,fMeshShaderOutputBufferSizes[PerInFlightFrameBufferIndex]);
   fMeshCullScratchBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                16+(48*TpvInt64(fMeshCullMaxScratchEntries[PerInFlightFrameBufferIndex])),
                                                                                TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                [],
                                                                                TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                0,
                                                                                0,
                                                                                TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                0,
                                                                                pvAllocationGroupIDScene3DDynamic,
                                                                                '3DRendererInstance.ScratchBuffer'
                                                                               );
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshCullScratchBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.ScratchBuffer');

   fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                     (MaxMultiIndirectDrawCalls*TpvSizeInt(IfThen(fUseSeparateCommandBufferSlots,7,4)))*SizeOf(TVkUInt32),
                                                                                                     TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                                     TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                     [],
                                                                                                     TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                     0,
                                                                                                     0,
                                                                                                     TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                     0,
                                                                                                     0,
                                                                                                     0,
                                                                                                     0,
                                                                                                     [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                                     0,
                                                                                                     pvAllocationGroupIDScene3DDynamic,
                                                                                                     '3DRendererInstance.CounterBuffer'
                                                                                                    );
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CounterBuffer');

   fMeshCullIndirectDispatchBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                         2*SizeOf(TVkDispatchIndirectCommand),
                                                                                         TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                         TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                         [],
                                                                                         TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                         TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                         0,
                                                                                         0,
                                                                                         0,
                                                                                         0,
                                                                                         0,
                                                                                         0,
                                                                                         [TpvVulkanBufferFlag.PersistentMapped],
                                                                                         0,
                                                                                         pvAllocationGroupIDScene3DDynamic,
                                                                                         '3DRendererInstance.IndirectDispatchBuffer'
                                                                                        );
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshCullIndirectDispatchBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.IndirectDispatchBuffer');

  end;

  // If not using per in-flight frame buffers, then duplicate the first buffer for all in-flight frames to save memory and resource creation time
  if not fScene3D.UsePerInFlightFrameResources then begin
   for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
    fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex]:=fGPUDrawIndexedIndirectCommandOutputBuffers[0];
    fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex]:=fGPUDrawIndexedIndirectCommandOutputBufferSizes[0];
    fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex]:=fGPUDrawIndexedIndirectCommandCounterBuffers[0];
    fMeshCullScratchBuffers[PerInFlightFrameBufferIndex]:=fMeshCullScratchBuffers[0];
    fMeshCullMaxScratchEntries[PerInFlightFrameBufferIndex]:=fMeshCullMaxScratchEntries[0];
    fMeshCullIndirectDispatchBuffers[PerInFlightFrameBufferIndex]:=fMeshCullIndirectDispatchBuffers[0];
   end;
  end;


  for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin

   case fScene3D.BufferStreamingMode of

    TpvScene3D.TBufferStreamingMode.Direct:begin

     fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                            Max(1,fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[InFlightFrameIndex])*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand),
                                                                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                                            TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                            [],
                                                                                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                                            0,
                                                                                                            0,
                                                                                                            0,
                                                                                                            0,
                                                                                                            0,
                                                                                                            0,
                                                                                                            [TpvVulkanBufferFlag.PersistentMapped],
                                                                                                            0,
                                                                                                            pvAllocationGroupIDScene3DDynamic,
                                                                                                            '3DRendererInstance.CmdInputBuffers['+IntToStr(InFlightFrameIndex)+']'
                                                                                                           );
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CmdInputBuffers['+IntToStr(InFlightFrameIndex)+']');
    end;

    TpvScene3D.TBufferStreamingMode.Staging:begin

     fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                            Max(1,fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[InFlightFrameIndex])*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand),
                                                                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                                            TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                            [],
                                                                                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                            0,
                                                                                                            0,
                                                                                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                            0,
                                                                                                            0,
                                                                                                            0,
                                                                                                            0,
                                                                                                            [],
                                                                                                            0,
                                                                                                            pvAllocationGroupIDScene3DDynamic,
                                                                                                            '3DRendererInstance.CmdInputBuffers['+IntToStr(InFlightFrameIndex)+']'
                                                                                                           );
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CmdInputBuffers['+IntToStr(InFlightFrameIndex)+']');
    end;

    else begin
     Assert(false);
    end;

   end;

   fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBufferPartSizes[InFlightFrameIndex]:=65536;

   fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                               131072*SizeOf(TpvUInt32),
                                                                                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                               [],
                                                                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                               0,
                                                                                                               0,
                                                                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                                               0,
                                                                                                               0,
                                                                                                               0,
                                                                                                               0,
                                                                                                               [],
                                                                                                               0,
                                                                                                               pvAllocationGroupIDScene3DDynamic,
                                                                                                               '3DRendererInstance.VisibilityBuffers['+IntToStr(InFlightFrameIndex)+']'
                                                                                                              );
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.VisibilityBuffers['+IntToStr(InFlightFrameIndex)+']');

   // Object-selection outline: the selected-only indirect draw list (built by SelectionListComputePass, drawn by the mask
   // pass via vkCmdDrawIndexedIndirectCount, stride 32) + its count (cleared each frame). GPU-only (device-local).
   fSelectionListDrawIndexedIndirectCommandBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                               Max(1,fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[InFlightFrameIndex])*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand),
                                                                                               TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT), // BDA: mesh.task reads the per-draw command via MeshDrawCommandsBDA
                                                                                               TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),[],
                                                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),0,0,
                                                                                               TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),0,0,0,0,[TpvVulkanBufferFlag.BufferDeviceAddress],0,
                                                                                               pvAllocationGroupIDScene3DDynamic,
                                                                                               '3DRendererInstance.SelectionListCommandBuffers['+IntToStr(InFlightFrameIndex)+']');
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fSelectionListDrawIndexedIndirectCommandBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.SelectionListCommandBuffers['+IntToStr(InFlightFrameIndex)+']');

   fSelectionListDrawIndexedIndirectCommandCountBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                    SizeOf(TpvUInt32),
                                                                                                    TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                                    TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),[],
                                                                                                    TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),0,0,
                                                                                                    TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),0,0,0,0,[],0,
                                                                                                    pvAllocationGroupIDScene3DDynamic,
                                                                                                    '3DRendererInstance.SelectionListCommandCountBuffers['+IntToStr(InFlightFrameIndex)+']');
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fSelectionListDrawIndexedIndirectCommandCountBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.SelectionListCommandCountBuffers['+IntToStr(InFlightFrameIndex)+']');

   fPerInFlightFrameMeshCullBatchRangeBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                          MaxMultiIndirectDrawCalls*SizeOf(TpvScene3D.TGPUBatchRange),
                                                                                          TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                          TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                          [],
                                                                                          TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                          TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                          0,
                                                                                          0,
                                                                                          0,
                                                                                          0,
                                                                                          0,
                                                                                          0,
                                                                                          [TpvVulkanBufferFlag.PersistentMapped],
                                                                                          0,
                                                                                          pvAllocationGroupIDScene3DDynamic,
                                                                                          '3DRendererInstance.BatchRangeBuffers['+IntToStr(InFlightFrameIndex)+']'
                                                                                         );
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameMeshCullBatchRangeBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.BatchRangeBuffers['+IntToStr(InFlightFrameIndex)+']');

   fPerInFlightFrameMeshCullPrefixSumBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                         (MaxMultiIndirectDrawCalls+1)*SizeOf(TpvUInt32),
                                                                                         TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                         TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                         [],
                                                                                         TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                         TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                         0,
                                                                                         0,
                                                                                         0,
                                                                                         0,
                                                                                         0,
                                                                                         0,
                                                                                         [TpvVulkanBufferFlag.PersistentMapped],
                                                                                         0,
                                                                                         pvAllocationGroupIDScene3DDynamic,
                                                                                         '3DRendererInstance.PrefixSumBuffers['+IntToStr(InFlightFrameIndex)+']'
                                                                                        );
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameMeshCullPrefixSumBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.PrefixSumBuffers['+IntToStr(InFlightFrameIndex)+']');

   // ExpandRangeInfo buffer: {outputBase,outputCapacity} per counter index (4 sections × MaxMultiIndirectDrawCalls)
   fPerInFlightFrameExpandRangeInfoBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                       (MaxMultiIndirectDrawCalls*TpvSizeInt(IfThen(fUseSeparateCommandBufferSlots,7,4)))*SizeOf(TpvScene3D.TGPUExpandRangeInfo),
                                                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                       TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                       [],
                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       [TpvVulkanBufferFlag.PersistentMapped,TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                       0,
                                                                                       pvAllocationGroupIDScene3DDynamic,
                                                                                       '3DRendererInstance.ExpandRangeInfoBuffers['+IntToStr(InFlightFrameIndex)+']'
                                                                                      );
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameExpandRangeInfoBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.ExpandRangeInfoBuffers['+IntToStr(InFlightFrameIndex)+']');

   // Meshlet visibility bitmap: 1 bit per allocated meshlet slot, one buffer per IFF per CullRenderPass
   // Only culling passes (FinalView, CascadedShadowMap) need meshlet visibility, filter-only passes do not
   for CullRenderPass:=TpvScene3DRendererCullRenderPass.FinalView to TpvScene3DRendererCullRenderPass.CascadedShadowMap do begin
    fPerInFlightFrameMeshletVisibilityBufferPartSizes[InFlightFrameIndex,CullRenderPass]:=65536;
    fPerInFlightFrameMeshletVisibilityBuffers[InFlightFrameIndex,CullRenderPass]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                         65536*SizeOf(TpvUInt32),
                                                                                                         TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                                         TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                         [],
                                                                                                         TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                         0,
                                                                                                         0,
                                                                                                         TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                         0,
                                                                                                         0,
                                                                                                         0,
                                                                                                         0,
                                                                                                         [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                                         0,
                                                                                                         pvAllocationGroupIDScene3DDynamic,
                                                                                                         '3DRendererInstance.MeshletVisibilityBuffers['+IntToStr(InFlightFrameIndex)+','+IntToStr(Ord(CullRenderPass))+']'
                                                                                                        );
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameMeshletVisibilityBuffers[InFlightFrameIndex,CullRenderPass].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.MeshletVisibilityBuffers['+IntToStr(InFlightFrameIndex)+','+IntToStr(Ord(CullRenderPass))+']');
   end;
  end;

 end;



 FillChar(fPerInFlightFrameGPUCountMeshObjectIDsArray,SizeOf(TpvScene3D.TPerInFlightFrameGPUCountMeshObjectIDsArray),#0);

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin
  fDrawChoreographyBatchRangeFrameBuckets[InFlightFrameIndex].Initialize;
  for RenderPass:=TpvScene3DRendererRenderPassFirst to TpvScene3DRendererRenderPassLast do begin
   fDrawChoreographyBatchRangeFrameRenderPassBuckets[InFlightFrameIndex,RenderPass].Initialize;
  end;
 end;

 fMeshCullPass0ComputeVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(Renderer.VulkanDevice);
 fMeshCullPass0ComputeVulkanDescriptorSetLayout.AddBinding(0,
                                                           VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                                           1,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);
 fMeshCullPass0ComputeVulkanDescriptorSetLayout.AddBinding(1,
                                                           VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                           1,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);
 fMeshCullPass0ComputeVulkanDescriptorSetLayout.AddBinding(2,
                                                           VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                           1,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);
 fMeshCullPass0ComputeVulkanDescriptorSetLayout.AddBinding(3,
                                                           VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                           1,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);
 fMeshCullPass0ComputeVulkanDescriptorSetLayout.AddBinding(4,
                                                           VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                           1,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);
 fMeshCullPass0ComputeVulkanDescriptorSetLayout.AddBinding(5,
                                                           VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                           1,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);
 fMeshCullPass0ComputeVulkanDescriptorSetLayout.AddBinding(6,
                                                           VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                           1,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);
 fMeshCullPass0ComputeVulkanDescriptorSetLayout.Initialize;
 Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshCullPass0ComputeVulkanDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DRendererInstance.fMeshCullPass0ComputeVulkanDescriptorSetLayout');

 fMeshCullPass0ComputeVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(Renderer.VulkanDevice,
                                                                                TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                                Renderer.CountInFlightFrames);
 fMeshCullPass0ComputeVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,Renderer.CountInFlightFrames*1);
 fMeshCullPass0ComputeVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,Renderer.CountInFlightFrames*6);
 fMeshCullPass0ComputeVulkanDescriptorPool.Initialize;
 Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshCullPass0ComputeVulkanDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DRendererInstance.fMeshCullPass0ComputeVulkanDescriptorPool');

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin

  if fScene3D.UsePerInFlightFrameResources then begin
   PerInFlightFrameBufferIndex:=InFlightFrameIndex;
  end else begin
   PerInFlightFrameBufferIndex:=0;
  end;

  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fMeshCullPass0ComputeVulkanDescriptorPool,fMeshCullPass0ComputeVulkanDescriptorSetLayout);
  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                                     [],
                                                                                     [fVulkanViewUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[(InFlightFrameIndex+(fScene3D.CountInFlightFrames-1)) mod fScene3D.CountInFlightFrames].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameMeshCullBatchRangeBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                     );
  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(6,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameMeshCullPrefixSumBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                     );
  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].Flush;
  Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TpvScene3DRendererInstance.fMeshCullPass0ComputeVulkanDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

 end;

 // MeshFilter descriptor set layout: 5 STORAGE_BUFFER bindings (contiguous 0-4)
 fMeshFilterComputeVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(Renderer.VulkanDevice);
 fMeshFilterComputeVulkanDescriptorSetLayout.AddBinding(0,
                                                         VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                         1,
                                                         TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                         []);
 fMeshFilterComputeVulkanDescriptorSetLayout.AddBinding(1,
                                                         VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                         1,
                                                         TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                         []);
 fMeshFilterComputeVulkanDescriptorSetLayout.AddBinding(2,
                                                         VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                         1,
                                                         TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                         []);
 fMeshFilterComputeVulkanDescriptorSetLayout.AddBinding(3,
                                                         VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                         1,
                                                         TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                         []);
 fMeshFilterComputeVulkanDescriptorSetLayout.AddBinding(4,
                                                         VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                         1,
                                                         TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                         []);
 fMeshFilterComputeVulkanDescriptorSetLayout.Initialize;
 Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshFilterComputeVulkanDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DRendererInstance.fMeshFilterComputeVulkanDescriptorSetLayout');

 fMeshFilterComputeVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(Renderer.VulkanDevice,
                                                                        TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                        Renderer.CountInFlightFrames);
 fMeshFilterComputeVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,Renderer.CountInFlightFrames*5);
 fMeshFilterComputeVulkanDescriptorPool.Initialize;
 Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshFilterComputeVulkanDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DRendererInstance.fMeshFilterComputeVulkanDescriptorPool');

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin

  if fScene3D.UsePerInFlightFrameResources then begin
   PerInFlightFrameBufferIndex:=InFlightFrameIndex;
  end else begin
   PerInFlightFrameBufferIndex:=0;
  end;

  fMeshFilterComputeVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fMeshFilterComputeVulkanDescriptorPool,fMeshFilterComputeVulkanDescriptorSetLayout);
  fMeshFilterComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                                  0,
                                                                                  1,
                                                                                  TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                  [],
                                                                                  [fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                  [],
                                                                                  false
                                                                                 );
  fMeshFilterComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                                  0,
                                                                                  1,
                                                                                  TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                  [],
                                                                                  [fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].DescriptorBufferInfo],
                                                                                  [],
                                                                                  false
                                                                                 );
  fMeshFilterComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                                  0,
                                                                                  1,
                                                                                  TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                  [],
                                                                                  [fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].DescriptorBufferInfo],
                                                                                  [],
                                                                                  false
                                                                                 );
  fMeshFilterComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                                  0,
                                                                                  1,
                                                                                  TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                  [],
                                                                                  [fPerInFlightFrameMeshCullBatchRangeBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                  [],
                                                                                  false
                                                                                 );
  fMeshFilterComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,
                                                                                  0,
                                                                                  1,
                                                                                  TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                  [],
                                                                                  [fPerInFlightFrameMeshCullPrefixSumBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                  [],
                                                                                  false
                                                                                 );
  fMeshFilterComputeVulkanDescriptorSets[InFlightFrameIndex].Flush;
  Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshFilterComputeVulkanDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TpvScene3DRendererInstance.fMeshFilterComputeVulkanDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

 end;

 fFrameGraph.AcquirePersistentResources;

 begin

  // Reset shader infrastructure
  fMeshCullReset:=TpvScene3DRendererMeshCullReset.Create(Renderer.VulkanDevice,Renderer.VulkanPipelineCache,fScene3D.CountInFlightFrames);
  fMeshCullReset.AcquireResources(fPerInFlightFrameMeshCullBatchRangeBuffers,fGPUDrawIndexedIndirectCommandCounterBuffers,fPerInFlightFrameMeshCullPrefixSumBuffers,fMeshCullIndirectDispatchBuffers);

 end;

 if Renderer.GlobalIlluminationMode=TpvScene3DRendererGlobalIlluminationMode.CameraReflectionProbe then begin
  fImageBasedLightingReflectionProbeCubeMaps:=TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.Create(Renderer.VulkanDevice,
                                                                                                                 Renderer.RepeatedSampler,
                                                                                                                 Max(16,fReflectionProbeWidth),
                                                                                                                 Max(16,fReflectionProbeHeight),
                                                                                                                 Renderer.CountInFlightFrames);
 end else begin
  fImageBasedLightingReflectionProbeCubeMaps:=nil;
 end;

 // Debug meshlet bounding sphere visualization compute pipeline
 if Renderer.Scene3D.MeshShaders then begin

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('mesh_debug_draw_spheres_comp.spv');
  try
   fDebugMeshletSphereComputeShaderModule:=TpvVulkanShaderModule.Create(Renderer.VulkanDevice,Stream);
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fDebugMeshletSphereComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererInstance.fDebugMeshletSphereComputeShaderModule');
  finally
   Stream.Free;
  end;

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('debug_lines_vert.spv');
  try
   fDebugMeshletSphereVertexShaderModule:=TpvVulkanShaderModule.Create(Renderer.VulkanDevice,Stream);
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fDebugMeshletSphereVertexShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererInstance.fDebugMeshletSphereVertexShaderModule');
  finally
   Stream.Free;
  end;

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('debug_lines_frag.spv');
  try
   fDebugMeshletSphereFragmentShaderModule:=TpvVulkanShaderModule.Create(Renderer.VulkanDevice,Stream);
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fDebugMeshletSphereFragmentShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DRendererInstance.fDebugMeshletSphereFragmentShaderModule');
  finally
   Stream.Free;
  end;

  fDebugMeshletSphereComputePipelineLayout:=TpvVulkanPipelineLayout.Create(Renderer.VulkanDevice);
  fDebugMeshletSphereComputePipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TDebugMeshletSpherePushConstants));
  fDebugMeshletSphereComputePipelineLayout.Initialize;
  Renderer.VulkanDevice.DebugUtils.SetObjectName(fDebugMeshletSphereComputePipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DRendererInstance.fDebugMeshletSphereComputePipelineLayout');

  fDebugMeshletSphereComputePipeline:=TpvVulkanComputePipeline.Create(Renderer.VulkanDevice,
                                                                       Renderer.VulkanPipelineCache,
                                                                       0,
                                                                       TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fDebugMeshletSphereComputeShaderModule,'main'),
                                                                       fDebugMeshletSphereComputePipelineLayout,
                                                                       nil,
                                                                       0);
  Renderer.VulkanDevice.DebugUtils.SetObjectName(fDebugMeshletSphereComputePipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DRendererInstance.fDebugMeshletSphereComputePipeline');

  // Create debug line buffer (indirect draw header + vertex data)
  // Max 65536 spheres × 96 vertices × 16 bytes + 16 bytes header
  for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin
   fDebugMeshletSphereLineBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                       SizeOf(TVkDrawIndirectCommand)+(65536*96*4*SizeOf(TpvUInt32)),
                                                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                       TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                       [],
                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                       0,
                                                                                       pvAllocationGroupIDScene3DDynamic,
                                                                                       '3DRendererInstance.DebugMeshletSphereLineBuffer'
                                                                                      );
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fDebugMeshletSphereLineBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.DebugMeshletSphereLineBuffer');
  end;

  if not fScene3D.UsePerInFlightFrameResources then begin
   for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
    fDebugMeshletSphereLineBuffers[PerInFlightFrameBufferIndex]:=fDebugMeshletSphereLineBuffers[0];
   end;
  end;

 end else begin
  fDebugMeshletSphereComputeShaderModule:=nil;
  fDebugMeshletSphereVertexShaderModule:=nil;
  fDebugMeshletSphereFragmentShaderModule:=nil;
  fDebugMeshletSphereComputePipelineLayout:=nil;
  fDebugMeshletSphereComputePipeline:=nil;
  for PerInFlightFrameBufferIndex:=0 to MaxInFlightFrames-1 do begin
   fDebugMeshletSphereLineBuffers[PerInFlightFrameBufferIndex]:=nil;
  end;
 end;

end;

procedure TpvScene3DRendererInstance.ReleasePersistentResources;
var InFlightFrameIndex,PerInFlightFrameBufferIndex:TpvSizeInt;
    RenderPass:TpvScene3DRendererRenderPass;
    CullRenderPass:TpvScene3DRendererCullRenderPass;
begin

 fFrameGraph.ReleasePersistentResources;

 FreeAndNil(fImageBasedLightingReflectionProbeCubeMaps);

 if fScene3D.UsePerInFlightFrameResources then begin
  for PerInFlightFrameBufferIndex:=0 to MaxInFlightFrames-1 do begin
   FreeAndNil(fDebugMeshletSphereLineBuffers[PerInFlightFrameBufferIndex]);
  end;
 end else begin
  FreeAndNil(fDebugMeshletSphereLineBuffers[0]);
  for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
   fDebugMeshletSphereLineBuffers[PerInFlightFrameBufferIndex]:=nil;
  end;
 end;
 FreeAndNil(fDebugMeshletSphereComputePipeline);
 FreeAndNil(fDebugMeshletSphereComputePipelineLayout);
 FreeAndNil(fDebugMeshletSphereFragmentShaderModule);
 FreeAndNil(fDebugMeshletSphereVertexShaderModule);
 FreeAndNil(fDebugMeshletSphereComputeShaderModule);

 // Nil out duplicate pointers first to avoid double-free in single-buffer mode
 if fScene3D.UsePerInFlightFrameResources then begin
  for PerInFlightFrameBufferIndex:=0 to MaxInFlightFrames-1 do begin
   FreeAndNil(fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex]);
   FreeAndNil(fMeshCullScratchBuffers[PerInFlightFrameBufferIndex]);
   FreeAndNil(fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex]);
   FreeAndNil(fMeshCullIndirectDispatchBuffers[PerInFlightFrameBufferIndex]);
  end;
 end else begin
  FreeAndNil(fGPUDrawIndexedIndirectCommandOutputBuffers[0]);
  FreeAndNil(fMeshCullScratchBuffers[0]);
  FreeAndNil(fGPUDrawIndexedIndirectCommandCounterBuffers[0]);
  FreeAndNil(fMeshCullIndirectDispatchBuffers[0]);
  for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
   fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex]:=nil;
   fMeshCullScratchBuffers[PerInFlightFrameBufferIndex]:=nil;
   fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex]:=nil;
   fMeshCullIndirectDispatchBuffers[PerInFlightFrameBufferIndex]:=nil;
  end;
 end;

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin

  fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[InFlightFrameIndex].Finalize;
  FreeAndNil(fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[InFlightFrameIndex]);
  FreeAndNil(fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[InFlightFrameIndex]);
  FreeAndNil(fSelectionListDrawIndexedIndirectCommandBuffers[InFlightFrameIndex]);
  FreeAndNil(fSelectionListDrawIndexedIndirectCommandCountBuffers[InFlightFrameIndex]);
  FreeAndNil(fPerInFlightFrameMeshCullBatchRangeBuffers[InFlightFrameIndex]);
  FreeAndNil(fPerInFlightFrameMeshCullPrefixSumBuffers[InFlightFrameIndex]);
  FreeAndNil(fPerInFlightFrameExpandRangeInfoBuffers[InFlightFrameIndex]);
  for CullRenderPass:=TpvScene3DRendererCullRenderPass.FinalView to TpvScene3DRendererCullRenderPass.CascadedShadowMap do begin
   FreeAndNil(fPerInFlightFrameMeshletVisibilityBuffers[InFlightFrameIndex,CullRenderPass]);
  end;
  FreeAndNil(fLODLevelBuffers[InFlightFrameIndex]);

  fDrawChoreographyBatchRangeFrameBuckets[InFlightFrameIndex].Finalize;

  for RenderPass:=TpvScene3DRendererRenderPassFirst to TpvScene3DRendererRenderPassLast do begin
   fDrawChoreographyBatchRangeFrameRenderPassBuckets[InFlightFrameIndex,RenderPass].Finalize;
  end;

 end;

  begin

   FreeAndNil(fCascadedShadowMapCullDepthArray2DImage);

   for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin
    FreeAndNil(fCascadedShadowMapCullDepthPyramidMipmappedArray2DImages[InFlightFrameIndex]);
   end;

  end;

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin
  FreeAndNil(fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex]);
 end;
 FreeAndNil(fMeshCullPass0ComputeVulkanDescriptorPool);
 FreeAndNil(fMeshCullPass0ComputeVulkanDescriptorSetLayout);

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin
  FreeAndNil(fMeshFilterComputeVulkanDescriptorSets[InFlightFrameIndex]);
 end;
 FreeAndNil(fMeshFilterComputeVulkanDescriptorPool);
 FreeAndNil(fMeshFilterComputeVulkanDescriptorSetLayout);

 FreeAndNil(fViewBuffersDescriptorSetLayout);

 FreeAndNil(fMeshCullReset);

end;

procedure TpvScene3DRendererInstance.AcquireVolatileResources;
const NaNVector4:TpvVector4=(x:NaN;y:NaN;z:NaN;w:NaN);
var InFlightFrameIndex,Index,PerInFlightFrameBufferIndex:TpvSizeInt;
    UniversalQueue:TpvVulkanQueue;
    UniversalCommandPool:TpvVulkanCommandPool;
    UniversalCommandBuffer:TpvVulkanCommandBuffer;
    UniversalFence:TpvVulkanFence;
    LuminanceBuffer:TLuminanceBuffer;
begin

 if assigned(fVirtualReality) then begin

  fWidth:=fVirtualReality.Width;

  fHeight:=fVirtualReality.Height;

  fHUDWidth:=Renderer.VirtualRealityHUDWidth;
  fHUDHeight:=Renderer.VirtualRealityHUDHeight;

 end else if fHasExternalOutputImage then begin

  // Nothing

 end else begin

  fWidth:=pvApplication.VulkanSwapChain.Width;

  fHeight:=pvApplication.VulkanSwapChain.Height;

  fHUDWidth:=fWidth;
  fHUDHeight:=fHeight;

 end;

 fScaledWidth:=Max(1,round(fSizeFactor*fWidth));
 fScaledHeight:=Max(1,round(fSizeFactor*fHeight));

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  fCameraPresets[InFlightFrameIndex].MaxCoC:=((fCameraPresets[InFlightFrameIndex].BlurKernelSize*4.0)+6.0)/fScaledHeight;
 end;

//fCameraPreset.MaxCoC:=((fCameraPresets[InFlightFrameIndex].BlurKernelSize*4.0)+6.0)/fScaledHeight;

 FillChar(fInFlightFrameStates,SizeOf(TInFlightFrameStates),#0);

 fFrameGraph.SetSwapChain(pvApplication.VulkanSwapChain,
                          pvApplication.VulkanDepthImageFormat);

 if assigned(fVirtualReality) then begin

  fFrameGraph.SurfaceWidth:=fWidth;
  fFrameGraph.SurfaceHeight:=fHeight;

  fExternalOutputImageData.VulkanImages.Clear;
  for Index:=0 to fVirtualReality.VulkanImages.Count-1 do begin
   fExternalOutputImageData.VulkanImages.Add(fVirtualReality.VulkanImages[Index]);
  end;

  (fFrameGraph.ResourceTypeByName['resourcetype_output_color'] as TpvFrameGraph.TImageResourceType).Format:=fVirtualReality.ImageFormat;

 end else if fHasExternalOutputImage then begin

  (fFrameGraph.ResourceTypeByName['resourcetype_output_color'] as TpvFrameGraph.TImageResourceType).Format:=fExternalImageFormat;

 end;

 UniversalQueue:=Renderer.VulkanDevice.UniversalQueue;
 try

  UniversalCommandPool:=TpvVulkanCommandPool.Create(Renderer.VulkanDevice,
                                                    Renderer.VulkanDevice.UniversalQueueFamilyIndex,
                                                    TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
  try

   UniversalCommandBuffer:=TpvVulkanCommandBuffer.Create(UniversalCommandPool,
                                                         VK_COMMAND_BUFFER_LEVEL_PRIMARY);
   try

    UniversalFence:=TpvVulkanFence.Create(Renderer.VulkanDevice);
    try

     for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin

      fNearestFarthestDepthVulkanBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                     SizeOf(TpvVector4),
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
                                                                                     'TpvScene3DRendererInstance.fNearestFarthestDepthVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fNearestFarthestDepthVulkanBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fNearestFarthestDepthVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');

      fDepthOfFieldAutoFocusVulkanBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                      SizeOf(TpvVector4),
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
                                                                                      'TpvScene3DRendererInstance.fDepthOfFieldAutoFocusVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fDepthOfFieldAutoFocusVulkanBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fDepthOfFieldAutoFocusVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');

      fDepthOfFieldBokenShapeTapVulkanBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                          (SizeOf(TpvVector2)*4096)+SizeOf(TpvVector4),
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
                                                                                          'TpvScene3DRendererInstance.fDepthOfFieldBokenShapeTapVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fDepthOfFieldBokenShapeTapVulkanBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fDepthOfFieldBokenShapeTapVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');

     end;

     for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
      Renderer.VulkanDevice.MemoryStaging.Upload(Renderer.VulkanDevice.UniversalQueue,
                                                 UniversalCommandBuffer,
                                                 UniversalFence,
                                                 NaNVector4,
                                                 fDepthOfFieldAutoFocusVulkanBuffers[InFlightFrameIndex],
                                                 0,
                                                 SizeOf(TpvVector4));
     end;

     fFrustumClusterGridTileSizeX:=(fScaledWidth+(fFrustumClusterGridSizeX-1)) div fFrustumClusterGridSizeX;
     fFrustumClusterGridTileSizeY:=(fScaledHeight+(fFrustumClusterGridSizeY-1)) div fFrustumClusterGridSizeY;

     fFrustumClusterGridCountTotalViews:=fCountSurfaceViews; // +6 for local light and reflection probe cubemap

     if Renderer.GlobalIlluminationMode=TpvScene3DRendererGlobalIlluminationMode.CameraReflectionProbe then begin
      inc(fFrustumClusterGridCountTotalViews,6); // +6 for local light and reflection probe cubemap
     end;

     for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin

      fFrustumClusterGridGlobalsVulkanBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                          SizeOf(TFrustumClusterGridPushConstants),
                                                                                          TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT),
                                                                                          TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                          [],
                                                                                          TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                          TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                          0,
                                                                                          0,
                                                                                          0,
                                                                                          0,
                                                                                          0,
                                                                                          0,
                                                                                          [TpvVulkanBufferFlag.PersistentMapped],
                                                                                          0,
                                                                                          pvAllocationGroupIDScene3DStatic,
                                                                                          'TpvScene3DRendererInstance.fFrustumClusterGridGlobalsVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fFrustumClusterGridGlobalsVulkanBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fFrustumClusterGridGlobalsVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');

      fFrustumClusterGridAABBVulkanBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                       fFrustumClusterGridSizeX*fFrustumClusterGridSizeY*fFrustumClusterGridSizeZ*SizeOf(TpvVector4)*4*fFrustumClusterGridCountTotalViews,
                                                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
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
                                                                                       'TpvScene3DRendererInstance.fFrustumClusterGridAABBVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fFrustumClusterGridAABBVulkanBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fFrustumClusterGridAABBVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');

      fFrustumClusterGridIndexListCounterVulkanBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                   SizeOf(TpvUInt32),
                                                                                                   TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
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
                                                                                                   'TpvScene3DRendererInstance.fFrustumClusterGridIndexListCounterVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fFrustumClusterGridIndexListCounterVulkanBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fFrustumClusterGridIndexListCounterVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');

      fFrustumClusterGridIndexListVulkanBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                            fFrustumClusterGridSizeX*fFrustumClusterGridSizeY*fFrustumClusterGridSizeZ*SizeOf(TpvUInt32)*128*fFrustumClusterGridCountTotalViews,
                                                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
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
                                                                                            'TpvScene3DRendererInstance.fFrustumClusterGridIndexListVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fFrustumClusterGridIndexListVulkanBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fFrustumClusterGridIndexListVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');

      fFrustumClusterGridDataVulkanBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                       fFrustumClusterGridSizeX*fFrustumClusterGridSizeY*fFrustumClusterGridSizeZ*SizeOf(TpvUInt32)*4*fFrustumClusterGridCountTotalViews,
                                                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
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
                                                                                       'TpvScene3DRendererInstance.fFrustumClusterGridDataVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fFrustumClusterGridDataVulkanBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fFrustumClusterGridDataVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');

     end;

     begin

      if Renderer.SurfaceSampleCountFlagBits<>TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
       fCullDepthArray2DImage:=TpvScene3DRendererArray2DImage.Create(fScene3D.VulkanDevice,fScaledWidth,fScaledHeight,fCountSurfaceViews,VK_FORMAT_R32_SFLOAT,VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,true,pvAllocationGroupIDScene3DSurface,VK_FORMAT_UNDEFINED,VK_SHARING_MODE_EXCLUSIVE,nil,'TpvScene3DRendererInstance.fCullDepthArray2DImage');
       Renderer.VulkanDevice.DebugUtils.SetObjectName(fCullDepthArray2DImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fCullDepthArray2DImage.Image');
       Renderer.VulkanDevice.DebugUtils.SetObjectName(fCullDepthArray2DImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fCullDepthArray2DImage.ImageView');
      end else begin
       fCullDepthArray2DImage:=nil;
      end;

      for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin
       fCullDepthPyramidMipmappedArray2DImages[InFlightFrameIndex]:=TpvScene3DRendererMipmappedArray2DImage.Create(fScene3D.VulkanDevice,Max(1,RoundDownToPowerOfTwo(fScaledWidth)),Max(1,RoundDownToPowerOfTwo(fScaledHeight)),fCountSurfaceViews,VK_FORMAT_R32_SFLOAT,VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,pvAllocationGroupIDScene3DSurface,'TpvScene3DRendererInstance.fCullDepthPyramidMipmappedArray2DImages['+IntToStr(InFlightFrameIndex)+']');
       Renderer.VulkanDevice.DebugUtils.SetObjectName(fCullDepthPyramidMipmappedArray2DImages[InFlightFrameIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fCullDepthPyramidMipmappedArray2DImages['+IntToStr(InFlightFrameIndex)+'].Image');
       Renderer.VulkanDevice.DebugUtils.SetObjectName(fCullDepthPyramidMipmappedArray2DImages[InFlightFrameIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fCullDepthPyramidMipmappedArray2DImages['+IntToStr(InFlightFrameIndex)+'].ImageView');
      end;

{     fAmbientOcclusionDepthMipmappedArray2DImage:=TpvScene3DRendererMipmappedArray2DImage.Create(fScene3D.VulkanDevice,fScaledWidth,fScaledHeight,fCountSurfaceViews,VK_FORMAT_R32_SFLOAT,VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,pvAllocationGroupIDScene3DSurface,'TpvScene3DRendererInstance.fAmbientOcclusionDepthMipmappedArray2DImage');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fAmbientOcclusionDepthMipmappedArray2DImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fAmbientOcclusionDepthMipmappedArray2DImage.Image');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fAmbientOcclusionDepthMipmappedArray2DImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fAmbientOcclusionDepthMipmappedArray2DImage.ImageView');}

      for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin
       fCombinedDepthArray2DImages[InFlightFrameIndex]:=TpvScene3DRendererArray2DImage.Create(fScene3D.VulkanDevice,fScaledWidth,fScaledHeight,fCountSurfaceViews,VK_FORMAT_R32_SFLOAT,VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,true,pvAllocationGroupIDScene3DSurface,VK_FORMAT_UNDEFINED,VK_SHARING_MODE_EXCLUSIVE,nil,'TpvScene3DRendererInstance.fCombinedDepthArray2DImages['+IntToStr(InFlightFrameIndex)+']');
       Renderer.VulkanDevice.DebugUtils.SetObjectName(fCombinedDepthArray2DImages[InFlightFrameIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fCombinedDepthArray2DImages['+IntToStr(InFlightFrameIndex)+'].Image');
       Renderer.VulkanDevice.DebugUtils.SetObjectName(fCombinedDepthArray2DImages[InFlightFrameIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fCombinedDepthArray2DImages['+IntToStr(InFlightFrameIndex)+'].ImageView');

       fDepthMipmappedArray2DImages[InFlightFrameIndex]:=TpvScene3DRendererMipmappedArray2DImage.Create(fScene3D.VulkanDevice,fScaledWidth,fScaledHeight,fCountSurfaceViews,VK_FORMAT_R32_SFLOAT,VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,pvAllocationGroupIDScene3DSurface,'TpvScene3DRendererInstance.fDepthMipmappedArray2DImages['+IntToStr(InFlightFrameIndex)+']');
       Renderer.VulkanDevice.DebugUtils.SetObjectName(fDepthMipmappedArray2DImages[InFlightFrameIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fDepthMipmappedArray2DImages['+IntToStr(InFlightFrameIndex)+'].Image');
       Renderer.VulkanDevice.DebugUtils.SetObjectName(fDepthMipmappedArray2DImages[InFlightFrameIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fDepthMipmappedArray2DImages['+IntToStr(InFlightFrameIndex)+'].ImageView');
      end;

      fSceneMipmappedArray2DImage:=TpvScene3DRendererMipmappedArray2DImage.Create(fScene3D.VulkanDevice,fScaledWidth,fScaledHeight,fCountSurfaceViews,VK_FORMAT_R16G16B16A16_SFLOAT{Renderer.OptimizedNonAlphaFormat},VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,pvAllocationGroupIDScene3DSurface,'TpvScene3DRendererInstance.fSceneMipmappedArray2DImage');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fSceneMipmappedArray2DImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fSceneMipmappedArray2DImage.Image');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fSceneMipmappedArray2DImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fSceneMipmappedArray2DImage.ImageView');

      if SameValue(fSizeFactor,1.0) or fPostProcessingAtScaledResolution then begin
       fFullResSceneMipmappedArray2DImage:=fSceneMipmappedArray2DImage;
      end else begin
       fFullResSceneMipmappedArray2DImage:=TpvScene3DRendererMipmappedArray2DImage.Create(fScene3D.VulkanDevice,fWidth,fHeight,fCountSurfaceViews,VK_FORMAT_R16G16B16A16_SFLOAT{Renderer.OptimizedNonAlphaFormat},VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,pvAllocationGroupIDScene3DSurface,'TpvScene3DRendererInstance.fFullResSceneMipmappedArray2DImage');
      end;
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fFullResSceneMipmappedArray2DImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fFullResSceneMipmappedArray2DImage.Image');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fFullResSceneMipmappedArray2DImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fFullResSceneMipmappedArray2DImage.ImageView');

      if assigned(fHUDRenderPassClass) then begin
       fHUDMipmappedArray2DImage:=TpvScene3DRendererMipmappedArray2DImage.Create(fScene3D.VulkanDevice,fHUDWidth,fHUDHeight,1,VK_FORMAT_R8G8B8A8_SRGB,VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,pvAllocationGroupIDScene3DSurface,'TpvScene3DRendererInstance.fHUDMipmappedArray2DImage');
       Renderer.VulkanDevice.DebugUtils.SetObjectName(fHUDMipmappedArray2DImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fHUDMipmappedArray2DImage.Image');
       Renderer.VulkanDevice.DebugUtils.SetObjectName(fHUDMipmappedArray2DImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fHUDMipmappedArray2DImage.ImageView');
      end else begin
       fHUDMipmappedArray2DImage:=nil;
      end;

     end;

     case Renderer.TransparencyMode of

      TpvScene3DRendererTransparencyMode.SPINLOCKOIT,
      TpvScene3DRendererTransparencyMode.INTERLOCKOIT:begin

       fCountLockOrderIndependentTransparencyLayers:=CountOrderIndependentTransparencyLayers;//Min(Max(CountOrderIndependentTransparencyLayers,fCountSurfaceMSAASamples),16);

       fLockOrderIndependentTransparentUniformBuffer.ViewPort.x:=fScaledWidth;
       fLockOrderIndependentTransparentUniformBuffer.ViewPort.y:=fScaledHeight;
       fLockOrderIndependentTransparentUniformBuffer.ViewPort.z:=fLockOrderIndependentTransparentUniformBuffer.ViewPort.x*fLockOrderIndependentTransparentUniformBuffer.ViewPort.y;
       fLockOrderIndependentTransparentUniformBuffer.ViewPort.w:=(fCountLockOrderIndependentTransparencyLayers and $ffff) or ((Renderer.CountSurfaceMSAASamples and $ffff) shl 16);

       for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin
        fLockOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex].UploadData(Renderer.VulkanDevice.UniversalQueue,
                                                                                                     UniversalCommandBuffer,
                                                                                                     UniversalFence,
                                                                                                     fLockOrderIndependentTransparentUniformBuffer,
                                                                                                     0,
                                                                                                     SizeOf(TLockOrderIndependentTransparentUniformBuffer));
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLockOrderIndependentTransparentUniformVulkanBuffers['+IntToStr(PerInFlightFrameBufferIndex)+']');
       end;

       for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin

        fLockOrderIndependentTransparencyABufferBuffers[PerInFlightFrameBufferIndex]:=TpvScene3DRendererOrderIndependentTransparencyBuffer.Create(fScene3D.VulkanDevice,
                                                                                                                                                  fScaledWidth*fScaledHeight*fCountLockOrderIndependentTransparencyLayers*Max(1,fCountSurfaceViews)*(SizeOf(UInt32)*8{4}),
                                                                                                                                                  VK_FORMAT_R32G32B32A32_UINT,
                                                                                                                                                  TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT));
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparencyABufferBuffers[PerInFlightFrameBufferIndex].VulkanBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLockOrderIndependentTransparencyABufferBuffers['+IntToStr(PerInFlightFrameBufferIndex)+'].Buffer');
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparencyABufferBuffers[PerInFlightFrameBufferIndex].VulkanBufferView.Handle,VK_OBJECT_TYPE_BUFFER_VIEW,'TpvScene3DRendererInstance.fLockOrderIndependentTransparencyABufferBuffers['+IntToStr(PerInFlightFrameBufferIndex)+'].BufferView');
       end;

       for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin
        fLockOrderIndependentTransparencyAuxImages[PerInFlightFrameBufferIndex]:=TpvScene3DRendererOrderIndependentTransparencyImage.Create(fScene3D.VulkanDevice,
                                                                                                                                            fScaledWidth,
                                                                                                                                            fScaledHeight,
                                                                                                                                            fCountSurfaceViews,
                                                                                                                                            Renderer.OrderIndependentTransparencySampler,
                                                                                                                                            VK_FORMAT_R32_UINT,
                                                                                                                                            VK_SAMPLE_COUNT_1_BIT);
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparencyAuxImages[PerInFlightFrameBufferIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fLockOrderIndependentTransparencyAuxImages['+IntToStr(PerInFlightFrameBufferIndex)+'].Image');
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparencyAuxImages[PerInFlightFrameBufferIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fLockOrderIndependentTransparencyAuxImages['+IntToStr(PerInFlightFrameBufferIndex)+'].ImageView');
        if Renderer.TransparencyMode=TpvScene3DRendererTransparencyMode.SPINLOCKOIT then begin
         fLockOrderIndependentTransparencySpinLockImages[PerInFlightFrameBufferIndex]:=TpvScene3DRendererOrderIndependentTransparencyImage.Create(fScene3D.VulkanDevice,
                                                                                                                                                  fScaledWidth,
                                                                                                                                                  fScaledHeight,
                                                                                                                                                  fCountSurfaceViews,
                                                                                                                                                  Renderer.OrderIndependentTransparencySampler,
                                                                                                                                                  VK_FORMAT_R32_UINT,
                                                                                                                                                  VK_SAMPLE_COUNT_1_BIT);
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparencySpinLockImages[PerInFlightFrameBufferIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fLockOrderIndependentTransparencySpinLockImages['+IntToStr(PerInFlightFrameBufferIndex)+'].Image');
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparencySpinLockImages[PerInFlightFrameBufferIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fLockOrderIndependentTransparencySpinLockImages['+IntToStr(PerInFlightFrameBufferIndex)+'].ImageView');
        end;
       end;

       if not fScene3D.UsePerInFlightFrameResources then begin
        for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
         fLockOrderIndependentTransparencyABufferBuffers[PerInFlightFrameBufferIndex]:=fLockOrderIndependentTransparencyABufferBuffers[0];
         fLockOrderIndependentTransparencyAuxImages[PerInFlightFrameBufferIndex]:=fLockOrderIndependentTransparencyAuxImages[0];
         fLockOrderIndependentTransparencySpinLockImages[PerInFlightFrameBufferIndex]:=fLockOrderIndependentTransparencySpinLockImages[0];
        end;
       end;

      end;

      TpvScene3DRendererTransparencyMode.LOOPOIT:begin

       fCountLoopOrderIndependentTransparencyLayers:=CountOrderIndependentTransparencyLayers;//Min(Max(CountOrderIndependentTransparencyLayers,fCountSurfaceMSAASamples),16);

       fLoopOrderIndependentTransparentUniformBuffer.ViewPort.x:=fScaledWidth;
       fLoopOrderIndependentTransparentUniformBuffer.ViewPort.y:=fScaledHeight;
       fLoopOrderIndependentTransparentUniformBuffer.ViewPort.z:=fLoopOrderIndependentTransparentUniformBuffer.ViewPort.x*fLoopOrderIndependentTransparentUniformBuffer.ViewPort.y;
       fLoopOrderIndependentTransparentUniformBuffer.ViewPort.w:=(fCountLoopOrderIndependentTransparencyLayers and $ffff) or ((Renderer.CountSurfaceMSAASamples and $ffff) shl 16);

       for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin
        fLoopOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex].UploadData(Renderer.VulkanDevice.UniversalQueue,
                                                                                                     UniversalCommandBuffer,
                                                                                                     UniversalFence,
                                                                                                     fLoopOrderIndependentTransparentUniformBuffer,
                                                                                                     0,
                                                                                                     SizeOf(TLoopOrderIndependentTransparentUniformBuffer));
       end;

       for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin

        fLoopOrderIndependentTransparencyABufferBuffers[PerInFlightFrameBufferIndex]:=TpvScene3DRendererOrderIndependentTransparencyBuffer.Create(fScene3D.VulkanDevice,
                                                                                                                                                  fScaledWidth*fScaledHeight*fCountLoopOrderIndependentTransparencyLayers*fCountSurfaceViews*(SizeOf(UInt32)*2),
                                                                                                                                                  VK_FORMAT_R32G32_UINT,
                                                                                                                                                  TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT));
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLoopOrderIndependentTransparencyABufferBuffers[PerInFlightFrameBufferIndex].VulkanBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLoopOrderIndependentTransparencyABufferBuffers['+IntToStr(PerInFlightFrameBufferIndex)+'].Buffer');
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLoopOrderIndependentTransparencyABufferBuffers[PerInFlightFrameBufferIndex].VulkanBufferView.Handle,VK_OBJECT_TYPE_BUFFER_VIEW,'TpvScene3DRendererInstance.fLoopOrderIndependentTransparencyABufferBuffers['+IntToStr(PerInFlightFrameBufferIndex)+'].BufferView');

        fLoopOrderIndependentTransparencyZBufferBuffers[PerInFlightFrameBufferIndex]:=TpvScene3DRendererOrderIndependentTransparencyBuffer.Create(fScene3D.VulkanDevice,
                                                                                                                                                  fScaledWidth*fScaledHeight*fCountLoopOrderIndependentTransparencyLayers*fCountSurfaceViews*(SizeOf(UInt32)*1),
                                                                                                                                                  VK_FORMAT_R32_UINT,
                                                                                                                                                  TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT));
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLoopOrderIndependentTransparencyZBufferBuffers[PerInFlightFrameBufferIndex].VulkanBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLoopOrderIndependentTransparencyZBufferBuffers['+IntToStr(PerInFlightFrameBufferIndex)+'].Buffer');
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLoopOrderIndependentTransparencyZBufferBuffers[PerInFlightFrameBufferIndex].VulkanBufferView.Handle,VK_OBJECT_TYPE_BUFFER_VIEW,'TpvScene3DRendererInstance.fLoopOrderIndependentTransparencyZBufferBuffers['+IntToStr(PerInFlightFrameBufferIndex)+'].BufferView');

        if Renderer.SurfaceSampleCountFlagBits<>TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
         fLoopOrderIndependentTransparencySBufferBuffers[PerInFlightFrameBufferIndex]:=TpvScene3DRendererOrderIndependentTransparencyBuffer.Create(fScene3D.VulkanDevice,
                                                                                                                                                   fScaledWidth*fScaledHeight*fCountLoopOrderIndependentTransparencyLayers*fCountSurfaceViews*(SizeOf(UInt32)*1),
                                                                                                                                                   VK_FORMAT_R32_UINT,
                                                                                                                                                   TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT));
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fLoopOrderIndependentTransparencySBufferBuffers[PerInFlightFrameBufferIndex].VulkanBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLoopOrderIndependentTransparencySBufferBuffers['+IntToStr(PerInFlightFrameBufferIndex)+'].Buffer');
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fLoopOrderIndependentTransparencySBufferBuffers[PerInFlightFrameBufferIndex].VulkanBufferView.Handle,VK_OBJECT_TYPE_BUFFER_VIEW,'TpvScene3DRendererInstance.fLoopOrderIndependentTransparencySBufferBuffers['+IntToStr(PerInFlightFrameBufferIndex)+'].BufferView');
        end else begin
         fLoopOrderIndependentTransparencySBufferBuffers[PerInFlightFrameBufferIndex]:=nil;
        end;

       end;

       if not fScene3D.UsePerInFlightFrameResources then begin
        for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
         fLoopOrderIndependentTransparencyABufferBuffers[PerInFlightFrameBufferIndex]:=fLoopOrderIndependentTransparencyABufferBuffers[0];
         fLoopOrderIndependentTransparencyZBufferBuffers[PerInFlightFrameBufferIndex]:=fLoopOrderIndependentTransparencyZBufferBuffers[0];
         fLoopOrderIndependentTransparencySBufferBuffers[PerInFlightFrameBufferIndex]:=fLoopOrderIndependentTransparencySBufferBuffers[0];
        end;
       end;

      end;

      TpvScene3DRendererTransparencyMode.MBOIT,
      TpvScene3DRendererTransparencyMode.WBOIT:begin

       fApproximationOrderIndependentTransparentUniformBuffer.ZNearZFar.x:=abs(fZNear);
       fApproximationOrderIndependentTransparentUniformBuffer.ZNearZFar.y:=IfThen(IsInfinite(fZFar),4096.0,abs(fZFar));
       fApproximationOrderIndependentTransparentUniformBuffer.ZNearZFar.z:=ln(fApproximationOrderIndependentTransparentUniformBuffer.ZNearZFar.x);
       fApproximationOrderIndependentTransparentUniformBuffer.ZNearZFar.w:=ln(fApproximationOrderIndependentTransparentUniformBuffer.ZNearZFar.y);

       for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin
        fApproximationOrderIndependentTransparentUniformVulkanBuffers[PerInFlightFrameBufferIndex].UploadData(Renderer.VulkanDevice.UniversalQueue,
                                                                                                              UniversalCommandBuffer,
                                                                                                              UniversalFence,
                                                                                                              fApproximationOrderIndependentTransparentUniformBuffer,
                                                                                                              0,
                                                                                                              SizeOf(TApproximationOrderIndependentTransparentUniformBuffer));
       end;

      end;

      TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT,
      TpvScene3DRendererTransparencyMode.INTERLOCKDFAOIT:begin

       begin

        for PerInFlightFrameBufferIndex:=0 to fScene3D.CountPerInFlightFrameResources-1 do begin

         fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImages[PerInFlightFrameBufferIndex]:=TpvScene3DRendererOrderIndependentTransparencyImage.Create(fScene3D.VulkanDevice,
                                                                                                                                                                          fScaledWidth,
                                                                                                                                                                          fScaledHeight,
                                                                                                                                                                          fCountSurfaceViews,
                                                                                                                                                                          Renderer.OrderIndependentTransparencySampler,
                                                                                                                                                                          VK_FORMAT_R32G32B32A32_UINT,
                                                                                                                                                                          Renderer.SurfaceSampleCountFlagBits);
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImages[PerInFlightFrameBufferIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImages['+IntToStr(PerInFlightFrameBufferIndex)+'].Image');
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImages[PerInFlightFrameBufferIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImages['+IntToStr(PerInFlightFrameBufferIndex)+'].ImageView');

         fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImages[PerInFlightFrameBufferIndex]:=TpvScene3DRendererOrderIndependentTransparencyImage.Create(fScene3D.VulkanDevice,
                                                                                                                                                                       fScaledWidth,
                                                                                                                                                                       fScaledHeight,
                                                                                                                                                                       fCountSurfaceViews,
                                                                                                                                                                       Renderer.OrderIndependentTransparencySampler,
                                                                                                                                                                       VK_FORMAT_R16G16B16A16_SFLOAT,
                                                                                                                                                                       Renderer.SurfaceSampleCountFlagBits);
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImages[PerInFlightFrameBufferIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImages['+IntToStr(PerInFlightFrameBufferIndex)+'].Image');
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImages[PerInFlightFrameBufferIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImages['+IntToStr(PerInFlightFrameBufferIndex)+'].ImageView');

         fDeepAndFastApproximateOrderIndependentTransparencyAverageImages[PerInFlightFrameBufferIndex]:=TpvScene3DRendererOrderIndependentTransparencyImage.Create(fScene3D.VulkanDevice,
                                                                                                                                                                   fScaledWidth,
                                                                                                                                                                   fScaledHeight,
                                                                                                                                                                   fCountSurfaceViews,
                                                                                                                                                                   Renderer.OrderIndependentTransparencySampler,
                                                                                                                                                                   VK_FORMAT_R16G16B16A16_SFLOAT,
                                                                                                                                                                   Renderer.SurfaceSampleCountFlagBits);
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyAverageImages[PerInFlightFrameBufferIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyAverageImages['+IntToStr(PerInFlightFrameBufferIndex)+'].Image');
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyAverageImages[PerInFlightFrameBufferIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyAverageImages['+IntToStr(PerInFlightFrameBufferIndex)+'].ImageView');

         fDeepAndFastApproximateOrderIndependentTransparencyBucketImages[PerInFlightFrameBufferIndex]:=TpvScene3DRendererOrderIndependentTransparencyImage.Create(fScene3D.VulkanDevice,
                                                                                                                                                                  fScaledWidth,
                                                                                                                                                                  fScaledHeight,
                                                                                                                                                                  fCountSurfaceViews*2,
                                                                                                                                                                  Renderer.OrderIndependentTransparencySampler,
                                                                                                                                                                  VK_FORMAT_R16G16B16A16_SFLOAT,
                                                                                                                                                                  Renderer.SurfaceSampleCountFlagBits);
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyBucketImages[PerInFlightFrameBufferIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyBucketImages['+IntToStr(PerInFlightFrameBufferIndex)+'].Image');
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyBucketImages[PerInFlightFrameBufferIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyBucketImages['+IntToStr(PerInFlightFrameBufferIndex)+'].ImageView');

         if Renderer.TransparencyMode=TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT then begin
          fDeepAndFastApproximateOrderIndependentTransparencySpinLockImages[PerInFlightFrameBufferIndex]:=TpvScene3DRendererOrderIndependentTransparencyImage.Create(fScene3D.VulkanDevice,
                                                                                                                                                                    fScaledWidth,
                                                                                                                                                                    fScaledHeight,
                                                                                                                                                                    fCountSurfaceViews,
                                                                                                                                                                    Renderer.OrderIndependentTransparencySampler,
                                                                                                                                                                    VK_FORMAT_R32_UINT,
                                                                                                                                                                    VK_SAMPLE_COUNT_1_BIT);
          Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencySpinLockImages[PerInFlightFrameBufferIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencySpinLockImages['+IntToStr(PerInFlightFrameBufferIndex)+'].Image');
          Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencySpinLockImages[PerInFlightFrameBufferIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencySpinLockImages['+IntToStr(PerInFlightFrameBufferIndex)+'].ImageView');
         end;

        end;

        if not fScene3D.UsePerInFlightFrameResources then begin
         for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
          fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImages[PerInFlightFrameBufferIndex]:=fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImages[0];
          fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImages[PerInFlightFrameBufferIndex]:=fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImages[0];
          fDeepAndFastApproximateOrderIndependentTransparencyAverageImages[PerInFlightFrameBufferIndex]:=fDeepAndFastApproximateOrderIndependentTransparencyAverageImages[0];
          fDeepAndFastApproximateOrderIndependentTransparencyBucketImages[PerInFlightFrameBufferIndex]:=fDeepAndFastApproximateOrderIndependentTransparencyBucketImages[0];
          fDeepAndFastApproximateOrderIndependentTransparencySpinLockImages[PerInFlightFrameBufferIndex]:=fDeepAndFastApproximateOrderIndependentTransparencySpinLockImages[0];
         end;
        end;

       end;
      end;

      else begin
      end;

     end;

     for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin

      fLuminanceHistogramVulkanBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                   SizeOf(TpvUInt32)*256,
                                                                                   TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
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
                                                                                   'TpvScene3DRendererInstance.fLuminanceHistogramVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fLuminanceHistogramVulkanBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLuminanceHistogramVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');
      fLuminanceHistogramVulkanBuffers[InFlightFrameIndex].ClearData(Renderer.VulkanDevice.UniversalQueue,
                                                                     UniversalCommandBuffer,
                                                                     UniversalFence,
                                                                     0,
                                                                     SizeOf(TpvUInt32)*256,
                                                                     TpvVulkanBufferUseTemporaryStagingBufferMode.Automatic);

      fLuminanceVulkanBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                          SizeOf(TLuminanceBuffer),
                                                                          TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
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
                                                                          'TpvScene3DRendererInstance.fLuminanceVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fLuminanceVulkanBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLuminanceVulkanBuffers['+IntToStr(InFlightFrameIndex)+']');
      LuminanceBuffer.HistogramLuminance:=1.0/9.6;
      LuminanceBuffer.LuminanceFactor:=1.0;
      Renderer.VulkanDevice.MemoryStaging.Upload(Renderer.VulkanDevice.UniversalQueue,
                                                 UniversalCommandBuffer,
                                                 UniversalFence,
                                                 LuminanceBuffer,
                                                 fLuminanceVulkanBuffers[InFlightFrameIndex],
                                                 0,
                                                 SizeOf(TLuminanceBuffer));

      fLuminanceEvents[InFlightFrameIndex]:=TpvVulkanEvent.Create(Renderer.VulkanDevice);
      fLuminanceEventReady[InFlightFrameIndex]:=false;
     end;

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

 case Renderer.AntialiasingMode of

  TpvScene3DRendererAntialiasingMode.SMAAT2x:begin

   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin

    fTAAHistoryColorImages[InFlightFrameIndex]:=TpvScene3DRendererArray2DImage.Create(fScene3D.VulkanDevice,
                                                                                      fScaledWidth,
                                                                                      fScaledHeight,
                                                                                      fCountSurfaceViews,
                                                                                      VK_FORMAT_R16G16B16A16_SFLOAT,
                                                                                      TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                                                                      VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                                                      false,
                                                                                      pvAllocationGroupIDScene3DSurface,
                                                                                      VK_FORMAT_UNDEFINED,
                                                                                      VK_SHARING_MODE_EXCLUSIVE,
                                                                                      nil,
                                                                                      'TpvScene3DRendererInstance.fTAAHistoryColorImages['+IntToStr(InFlightFrameIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fTAAHistoryColorImages[InFlightFrameIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fTAAHistoryColorImages['+IntToStr(InFlightFrameIndex)+'].Image');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fTAAHistoryColorImages[InFlightFrameIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fTAAHistoryColorImages['+IntToStr(InFlightFrameIndex)+'].ImageView');

    fTAAEvents[InFlightFrameIndex]:=TpvVulkanEvent.Create(Renderer.VulkanDevice);
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fTAAEvents[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_EVENT,'TpvScene3DRendererInstance.fTAAEvents['+IntToStr(InFlightFrameIndex)+']');

    fTAAEventReady[InFlightFrameIndex]:=false;

   end;

  end;

  TpvScene3DRendererAntialiasingMode.TAA:begin

   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin

    fTAAHistoryColorImages[InFlightFrameIndex]:=TpvScene3DRendererArray2DImage.Create(fScene3D.VulkanDevice,
                                                                                      fScaledWidth,
                                                                                      fScaledHeight,
                                                                                      fCountSurfaceViews,
                                                                                      VK_FORMAT_R16G16B16A16_SFLOAT{Renderer.OptimizedNonAlphaFormat},
                                                                                      TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                                                                      VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                                                      false,
                                                                                      pvAllocationGroupIDScene3DSurface,
                                                                                      VK_FORMAT_UNDEFINED,
                                                                                      VK_SHARING_MODE_EXCLUSIVE,
                                                                                      nil,
                                                                                      'TpvScene3DRendererInstance.fTAAHistoryColorImages['+IntToStr(InFlightFrameIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fTAAHistoryColorImages[InFlightFrameIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fTAAHistoryColorImages['+IntToStr(InFlightFrameIndex)+'].Image');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fTAAHistoryColorImages[InFlightFrameIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fTAAHistoryColorImages['+IntToStr(InFlightFrameIndex)+'].ImageView');

    fTAAHistoryDepthImages[InFlightFrameIndex]:=TpvScene3DRendererArray2DImage.Create(fScene3D.VulkanDevice,
                                                                                      fScaledWidth,
                                                                                      fScaledHeight,
                                                                                      fCountSurfaceViews,
                                                                                      VK_FORMAT_D32_SFLOAT,
                                                                                      TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                                                                      VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                                                      false,
                                                                                      pvAllocationGroupIDScene3DSurface,
                                                                                      VK_FORMAT_UNDEFINED,
                                                                                      VK_SHARING_MODE_EXCLUSIVE,
                                                                                      nil,
                                                                                      'TpvScene3DRendererInstance.fTAAHistoryDepthImages['+IntToStr(InFlightFrameIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fTAAHistoryDepthImages[InFlightFrameIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fTAAHistoryDepthImages['+IntToStr(InFlightFrameIndex)+'].Image');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fTAAHistoryDepthImages[InFlightFrameIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fTAAHistoryDepthImages['+IntToStr(InFlightFrameIndex)+'].ImageView');

    fTAAHistoryVelocityImages[InFlightFrameIndex]:=TpvScene3DRendererArray2DImage.Create(fScene3D.VulkanDevice,
                                                                                         fScaledWidth,
                                                                                         fScaledHeight,
                                                                                         fCountSurfaceViews,
                                                                                         VK_FORMAT_R16G16_SFLOAT,
                                                                                         TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                                                                         VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                                                         false,
                                                                                         pvAllocationGroupIDScene3DSurface,
                                                                                         VK_FORMAT_UNDEFINED,
                                                                                         VK_SHARING_MODE_EXCLUSIVE,
                                                                                         nil,
                                                                                         'TpvScene3DRendererInstance.fTAAHistoryVelocityImages['+IntToStr(InFlightFrameIndex)+']');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fTAAHistoryVelocityImages[InFlightFrameIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fTAAHistoryVelocityImages['+IntToStr(InFlightFrameIndex)+'].Image');
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fTAAHistoryVelocityImages[InFlightFrameIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fTAAHistoryVelocityImages['+IntToStr(InFlightFrameIndex)+'].ImageView');

    fTAAEvents[InFlightFrameIndex]:=TpvVulkanEvent.Create(Renderer.VulkanDevice);
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fTAAEvents[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_EVENT,'TpvScene3DRendererInstance.fTAAEvents['+IntToStr(InFlightFrameIndex)+']');

    fTAAEventReady[InFlightFrameIndex]:=false;

   end;

  end;

 end;

 fMeshCullPass1ComputeVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(Renderer.VulkanDevice);
 fMeshCullPass1ComputeVulkanDescriptorSetLayout.AddBinding(0,
                                                           VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                                           1,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);
 fMeshCullPass1ComputeVulkanDescriptorSetLayout.AddBinding(1,
                                                           VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                           1,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);
 fMeshCullPass1ComputeVulkanDescriptorSetLayout.AddBinding(2,
                                                           VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                           1,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);
 fMeshCullPass1ComputeVulkanDescriptorSetLayout.AddBinding(3,
                                                           VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                           1,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);
 fMeshCullPass1ComputeVulkanDescriptorSetLayout.AddBinding(4,
                                                           VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                           1,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);
 fMeshCullPass1ComputeVulkanDescriptorSetLayout.AddBinding(5,
                                                           VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                           2,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);
  fMeshCullPass1ComputeVulkanDescriptorSetLayout.AddBinding(6,
                                                            VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                            1,
                                                            TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                            []);
  fMeshCullPass1ComputeVulkanDescriptorSetLayout.AddBinding(7,
                                                            VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                            1,
                                                            TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                            []);
 fMeshCullPass1ComputeVulkanDescriptorSetLayout.Initialize;
 Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshCullPass1ComputeVulkanDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DRendererInstance.fMeshCullPass1ComputeVulkanDescriptorSetLayout');

 fMeshCullPass1ComputeVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(Renderer.VulkanDevice,
                                                                                TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                                Renderer.CountInFlightFrames);
 fMeshCullPass1ComputeVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,Renderer.CountInFlightFrames);
 fMeshCullPass1ComputeVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,Renderer.CountInFlightFrames*6);
 fMeshCullPass1ComputeVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,Renderer.CountInFlightFrames*2);
 fMeshCullPass1ComputeVulkanDescriptorPool.Initialize;
 Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshCullPass1ComputeVulkanDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DRendererInstance.fMeshCullPass1ComputeVulkanDescriptorPool');

 fMeshCullPassDescriptorGeneration:=0;

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin

  if fScene3D.UsePerInFlightFrameResources then begin
   PerInFlightFrameBufferIndex:=InFlightFrameIndex;
  end else begin
   PerInFlightFrameBufferIndex:=0;
  end;

  fMeshCullPassDescriptorGenerations[InFlightFrameIndex]:=0;

  fMeshCullPass1ComputeVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fMeshCullPass1ComputeVulkanDescriptorPool,fMeshCullPass1ComputeVulkanDescriptorSetLayout);
  fMeshCullPass1ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                                     [],
                                                                                     [fVulkanViewUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass1ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass1ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass1ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass1ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  if fZNear<0.0 then begin
   fMeshCullPass1ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,
                                                                                      0,
                                                                                      2,
                                                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                      [TVkDescriptorImageInfo.Create(Renderer.MipMapMinFilterSampler.Handle,
                                                                                                                     fCullDepthPyramidMipmappedArray2DImages[InFlightFrameIndex].VulkanArrayImageView.Handle,
                                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                                                       TVkDescriptorImageInfo.Create(Renderer.MipMapMaxFilterSampler.Handle,
                                                                                                                     fCascadedShadowMapCullDepthPyramidMipmappedArray2DImages[InFlightFrameIndex].VulkanArrayImageView.Handle,
                                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                                      [],
                                                                                      [],
                                                                                      false
                                                                                     );
  end else begin
   fMeshCullPass1ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,
                                                                                      0,
                                                                                      2,
                                                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                      [TVkDescriptorImageInfo.Create(Renderer.MipMapMaxFilterSampler.Handle,
                                                                                                                     fCullDepthPyramidMipmappedArray2DImages[InFlightFrameIndex].VulkanArrayImageView.Handle,
                                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                                                       TVkDescriptorImageInfo.Create(Renderer.MipMapMaxFilterSampler.Handle,
                                                                                                                     fCascadedShadowMapCullDepthPyramidMipmappedArray2DImages[InFlightFrameIndex].VulkanArrayImageView.Handle,
                                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                                      [],
                                                                                      [],
                                                                                      false
                                                                                     );
  end;
  fMeshCullPass1ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(6,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameMeshCullBatchRangeBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass1ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(7,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameMeshCullPrefixSumBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass1ComputeVulkanDescriptorSets[InFlightFrameIndex].Flush;
  Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshCullPass1ComputeVulkanDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TpvScene3DRendererInstance.fMeshCullPass1ComputeVulkanDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

 end;

 fViewBuffersDescriptorPool:=TpvVulkanDescriptorPool.Create(Renderer.VulkanDevice,
                                                              TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                              Renderer.CountInFlightFrames);
 fViewBuffersDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,Renderer.CountInFlightFrames);
 fViewBuffersDescriptorPool.Initialize;
 Renderer.VulkanDevice.DebugUtils.SetObjectName(fViewBuffersDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DRendererInstance.fViewBuffersDescriptorPool');

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin

  fViewBuffersDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fViewBuffersDescriptorPool,fViewBuffersDescriptorSetLayout);
  fViewBuffersDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                      0,
                                                                      1,
                                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                      [],
                                                                      [fVulkanViewUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                      [],
                                                                      false
                                                                     );
  fViewBuffersDescriptorSets[InFlightFrameIndex].Flush;
  Renderer.VulkanDevice.DebugUtils.SetObjectName(fViewBuffersDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TpvScene3DRendererInstance.fViewBuffersDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

 end;

 fFrameGraph.AcquireVolatileResources;

end;

procedure TpvScene3DRendererInstance.ReleaseVolatileResources;
var InFlightFrameIndex,PerInFlightFrameBufferIndex:TpvSizeInt;
begin

 fFrameGraph.ReleaseVolatileResources;

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin
  FreeAndNil(fMeshCullPass1ComputeVulkanDescriptorSets[InFlightFrameIndex]);
 end;
 FreeAndNil(fMeshCullPass1ComputeVulkanDescriptorPool);
 FreeAndNil(fMeshCullPass1ComputeVulkanDescriptorSetLayout);

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin
  FreeAndNil(fViewBuffersDescriptorSets[InFlightFrameIndex]);
 end;
 FreeAndNil(fViewBuffersDescriptorPool);

 case Renderer.AntialiasingMode of

  TpvScene3DRendererAntialiasingMode.SMAAT2x:begin
   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
    FreeAndNil(fTAAHistoryColorImages[InFlightFrameIndex]);
    FreeAndNil(fTAAEvents[InFlightFrameIndex]);
   end;
  end;

  TpvScene3DRendererAntialiasingMode.TAA:begin
   for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
    FreeAndNil(fTAAHistoryColorImages[InFlightFrameIndex]);
    FreeAndNil(fTAAHistoryDepthImages[InFlightFrameIndex]);
    FreeAndNil(fTAAHistoryVelocityImages[InFlightFrameIndex]);
    FreeAndNil(fTAAEvents[InFlightFrameIndex]);
   end;
  end;

 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fLuminanceHistogramVulkanBuffers[InFlightFrameIndex]);
  FreeAndNil(fLuminanceVulkanBuffers[InFlightFrameIndex]);
  FreeAndNil(fLuminanceEvents[InFlightFrameIndex]);
 end;

 if assigned(fExternalOutputImageData) then begin
  fExternalOutputImageData.VulkanImages.Clear;
 end;

 begin
  FreeAndNil(fCullDepthArray2DImage);
  for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin
   FreeAndNil(fCullDepthPyramidMipmappedArray2DImages[InFlightFrameIndex]);
  end;
  for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin
   FreeAndNil(fCombinedDepthArray2DImages[InFlightFrameIndex]);
   FreeAndNil(fDepthMipmappedArray2DImages[InFlightFrameIndex]);
  end;
//FreeAndNil(fAmbientOcclusionDepthMipmappedArray2DImage);
  if fSceneMipmappedArray2DImage=fFullResSceneMipmappedArray2DImage then begin
   FreeAndNil(fSceneMipmappedArray2DImage);
   fFullResSceneMipmappedArray2DImage:=nil;
  end else begin
   FreeAndNil(fSceneMipmappedArray2DImage);
   FreeAndNil(fFullResSceneMipmappedArray2DImage);
  end;
  FreeAndNil(fHUDMipmappedArray2DImage);
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fNearestFarthestDepthVulkanBuffers[InFlightFrameIndex]);
  FreeAndNil(fDepthOfFieldAutoFocusVulkanBuffers[InFlightFrameIndex]);
  FreeAndNil(fDepthOfFieldBokenShapeTapVulkanBuffers[InFlightFrameIndex]);
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fFrustumClusterGridGlobalsVulkanBuffers[InFlightFrameIndex]);
  FreeAndNil(fFrustumClusterGridAABBVulkanBuffers[InFlightFrameIndex]);
  FreeAndNil(fFrustumClusterGridIndexListCounterVulkanBuffers[InFlightFrameIndex]);
  FreeAndNil(fFrustumClusterGridIndexListVulkanBuffers[InFlightFrameIndex]);
  FreeAndNil(fFrustumClusterGridDataVulkanBuffers[InFlightFrameIndex]);
 end;

 case Renderer.TransparencyMode of

  TpvScene3DRendererTransparencyMode.SPINLOCKOIT,
  TpvScene3DRendererTransparencyMode.INTERLOCKOIT:begin
   if fScene3D.UsePerInFlightFrameResources then begin
    for PerInFlightFrameBufferIndex:=0 to MaxInFlightFrames-1 do begin
     FreeAndNil(fLockOrderIndependentTransparencyABufferBuffers[PerInFlightFrameBufferIndex]);
     FreeAndNil(fLockOrderIndependentTransparencyAuxImages[PerInFlightFrameBufferIndex]);
     if Renderer.TransparencyMode=TpvScene3DRendererTransparencyMode.SPINLOCKOIT then begin
      FreeAndNil(fLockOrderIndependentTransparencySpinLockImages[PerInFlightFrameBufferIndex]);
     end;
    end;
   end else begin
    FreeAndNil(fLockOrderIndependentTransparencyABufferBuffers[0]);
    FreeAndNil(fLockOrderIndependentTransparencyAuxImages[0]);
    if Renderer.TransparencyMode=TpvScene3DRendererTransparencyMode.SPINLOCKOIT then begin
     FreeAndNil(fLockOrderIndependentTransparencySpinLockImages[0]);
    end;
    for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
     fLockOrderIndependentTransparencyABufferBuffers[PerInFlightFrameBufferIndex]:=nil;
     fLockOrderIndependentTransparencyAuxImages[PerInFlightFrameBufferIndex]:=nil;
     fLockOrderIndependentTransparencySpinLockImages[PerInFlightFrameBufferIndex]:=nil;
    end;
   end;
  end;

  TpvScene3DRendererTransparencyMode.LOOPOIT:begin
   if fScene3D.UsePerInFlightFrameResources then begin
    for PerInFlightFrameBufferIndex:=0 to MaxInFlightFrames-1 do begin
     FreeAndNil(fLoopOrderIndependentTransparencyABufferBuffers[PerInFlightFrameBufferIndex]);
     FreeAndNil(fLoopOrderIndependentTransparencyZBufferBuffers[PerInFlightFrameBufferIndex]);
     FreeAndNil(fLoopOrderIndependentTransparencySBufferBuffers[PerInFlightFrameBufferIndex]);
    end;
   end else begin
    FreeAndNil(fLoopOrderIndependentTransparencyABufferBuffers[0]);
    FreeAndNil(fLoopOrderIndependentTransparencyZBufferBuffers[0]);
    FreeAndNil(fLoopOrderIndependentTransparencySBufferBuffers[0]);
    for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
     fLoopOrderIndependentTransparencyABufferBuffers[PerInFlightFrameBufferIndex]:=nil;
     fLoopOrderIndependentTransparencyZBufferBuffers[PerInFlightFrameBufferIndex]:=nil;
     fLoopOrderIndependentTransparencySBufferBuffers[PerInFlightFrameBufferIndex]:=nil;
    end;
   end;
  end;

  TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT,
  TpvScene3DRendererTransparencyMode.INTERLOCKDFAOIT:begin
   if fScene3D.UsePerInFlightFrameResources then begin
    for PerInFlightFrameBufferIndex:=0 to MaxInFlightFrames-1 do begin
     FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImages[PerInFlightFrameBufferIndex]);
     FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImages[PerInFlightFrameBufferIndex]);
     FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencyAverageImages[PerInFlightFrameBufferIndex]);
     FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencyBucketImages[PerInFlightFrameBufferIndex]);
     if Renderer.TransparencyMode=TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT then begin
      FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencySpinLockImages[PerInFlightFrameBufferIndex]);
     end;
    end;
   end else begin
    FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImages[0]);
    FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImages[0]);
    FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencyAverageImages[0]);
    FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencyBucketImages[0]);
    if Renderer.TransparencyMode=TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT then begin
     FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencySpinLockImages[0]);
    end;
    for PerInFlightFrameBufferIndex:=1 to MaxInFlightFrames-1 do begin
     fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImages[PerInFlightFrameBufferIndex]:=nil;
     fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImages[PerInFlightFrameBufferIndex]:=nil;
     fDeepAndFastApproximateOrderIndependentTransparencyAverageImages[PerInFlightFrameBufferIndex]:=nil;
     fDeepAndFastApproximateOrderIndependentTransparencyBucketImages[PerInFlightFrameBufferIndex]:=nil;
     fDeepAndFastApproximateOrderIndependentTransparencySpinLockImages[PerInFlightFrameBufferIndex]:=nil;
    end;
   end;
  end;

  else begin
  end;

 end;

end;

procedure TpvScene3DRendererInstance.ClearSpaceLines(const aInFlightFrameIndex:TpvSizeInt);
begin
 if aInFlightFrameIndex<0 then begin
  exit;
 end;
 fSpaceLinesPrimitiveDynamicArrays[aInFlightFrameIndex].ClearNoFree;
end;

function TpvScene3DRendererInstance.AddSpaceLine(const aInFlightFrameIndex:TpvSizeInt;const aStartPosition,aEndPosition:TpvVector3;const aColor:TpvVector4;const aSize:TpvScalar;const aZMin:TpvScalar=0.0;const aZMax:TpvScalar=Infinity):Boolean;
var Primitive:PSpaceLinesPrimitive;
    PrimitiveItems:TSpaceLinesPrimitiveDynamicArray;
begin
 if aInFlightFrameIndex<0 then begin
  result:=false;
  exit;
 end;
 PrimitiveItems:=fSpaceLinesPrimitiveDynamicArrays[aInFlightFrameIndex];
 if assigned(PrimitiveItems) and (PrimitiveItems.Count<MaxSpaceLines) then begin
  Primitive:=pointer(PrimitiveItems.AddNew);
  Primitive^.Position:=TpvVector3.Null;
  Primitive^.LineThickness:=aSize;
  Primitive^.Position0:=aStartPosition;
  Primitive^.ZMin:=aZMin;
  Primitive^.Position1:=aEndPosition;
  Primitive^.ZMax:=aZMax;
  Primitive^.Color:=aColor;
  result:=true;
 end else begin
  result:=false;
 end;
end;

procedure TpvScene3DRendererInstance.ClearSolid(const aInFlightFrameIndex:TpvSizeInt);
begin
 if aInFlightFrameIndex<0 then begin
  exit;
 end;
 fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex].ClearNoFree;
end;

function TpvScene3DRendererInstance.AddSolidPoint2D(const aInFlightFrameIndex:TpvSizeInt;const aPosition:TpvVector2;const aColor:TpvVector4;const aSize:TpvScalar;const aPositionOffset:TpvVector2;const aLineWidth:TpvScalar):Boolean;
var Primitive:PSolidPrimitivePrimitive;
    PrimitiveItems:TSolidPrimitivePrimitiveDynamicArray;
begin
 if aInFlightFrameIndex<0 then begin
  result:=false;
  exit;
 end;
 PrimitiveItems:=fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex];
 if assigned(PrimitiveItems) and (PrimitiveItems.Count<MaxSolidPrimitives) then begin
  Primitive:=pointer(PrimitiveItems.AddNew);
  Primitive^.Position:=TpvVector2.Null;
  Primitive^.Position0:=TpvVector3.InlineableCreate(aPosition,0.0);
  Primitive^.Offset0:=aPositionOffset;
  Primitive^.Color:=aColor;
  if aLineWidth>0.0 then begin
   Primitive^.PrimitiveTopology:=TSolidPrimitivePrimitive.PrimitiveTopologyPointWireframe or 8;
   Primitive^.LineThicknessOrPointSize:=aSize+(aLineWidth*0.5);
   Primitive^.InnerRadius:=aSize-(aLineWidth*0.5);
  end else begin
   Primitive^.PrimitiveTopology:=TSolidPrimitivePrimitive.PrimitiveTopologyPoint or 8;
   Primitive^.LineThicknessOrPointSize:=aSize;
   Primitive^.InnerRadius:=aSize;
  end;
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TpvScene3DRendererInstance.AddSolidLine2D(const aInFlightFrameIndex:TpvSizeInt;const aStartPosition,aEndPosition:TpvVector2;const aColor:TpvVector4;const aSize:TpvScalar;const aStartPositionOffset,aEndPositionOffset:TpvVector2):Boolean;
var Primitive:PSolidPrimitivePrimitive;
    PrimitiveItems:TSolidPrimitivePrimitiveDynamicArray;
begin
 if aInFlightFrameIndex<0 then begin
  result:=false;
  exit;
 end;
 PrimitiveItems:=fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex];
 if assigned(PrimitiveItems) and (PrimitiveItems.Count<MaxSolidPrimitives) then begin
  Primitive:=pointer(PrimitiveItems.AddNew);
  Primitive^.Position:=TpvVector2.Null;
  Primitive^.Position0:=TpvVector3.InlineableCreate(aStartPosition,0.0);
  Primitive^.Offset0:=aStartPositionOffset;
  Primitive^.Position1:=TpvVector3.InlineableCreate(aEndPosition,0.0);
  Primitive^.Offset1:=aEndPositionOffset;
  Primitive^.Color:=aColor;
  Primitive^.PrimitiveTopology:=TSolidPrimitivePrimitive.PrimitiveTopologyLine or 8;
  Primitive^.LineThicknessOrPointSize:=aSize;
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TpvScene3DRendererInstance.AddSolidTriangle2D(const aInFlightFrameIndex:TpvSizeInt;const aPosition0,aPosition1,aPosition2:TpvVector2;const aColor:TpvVector4;const aPosition0Offset,aPosition1Offset,aPosition2Offset:TpvVector2;const aLineWidth:TpvScalar=0.0):Boolean;
var Primitive:PSolidPrimitivePrimitive;
    PrimitiveItems:TSolidPrimitivePrimitiveDynamicArray;
begin
 if aInFlightFrameIndex<0 then begin
  result:=false;
  exit;
 end;
 PrimitiveItems:=fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex];
 if assigned(PrimitiveItems) and (PrimitiveItems.Count<MaxSolidPrimitives) then begin
  Primitive:=pointer(PrimitiveItems.AddNew);
  Primitive^.Position:=TpvVector2.Null;
  Primitive^.Position0:=TpvVector3.InlineableCreate(aPosition0,0.0);
  Primitive^.Offset0:=aPosition0Offset;
  Primitive^.Position1:=TpvVector3.InlineableCreate(aPosition1,0.0);
  Primitive^.Offset1:=aPosition1Offset;
  Primitive^.Position2:=TpvVector3.InlineableCreate(aPosition2,0.0);
  Primitive^.Offset2:=aPosition2Offset;
  Primitive^.Color:=aColor;
  if aLineWidth>0.0 then begin
   Primitive^.PrimitiveTopology:=TSolidPrimitivePrimitive.PrimitiveTopologyTriangleWireframe or 8;
  end else begin
   Primitive^.PrimitiveTopology:=TSolidPrimitivePrimitive.PrimitiveTopologyTriangle or 8;
  end;
  Primitive^.LineThicknessOrPointSize:=aLineWidth;
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TpvScene3DRendererInstance.AddSolidQuad2D(const aInFlightFrameIndex:TpvSizeInt;const aPosition0,aPosition1,aPosition2,aPosition3:TpvVector2;const aColor:TpvVector4;const aPosition0Offset,aPosition1Offset,aPosition2Offset,aPosition3Offset:TpvVector2;const aLineWidth:TpvScalar=0.0):Boolean;
var Primitive:PSolidPrimitivePrimitive;
    PrimitiveItems:TSolidPrimitivePrimitiveDynamicArray;
begin
 if aInFlightFrameIndex<0 then begin
  result:=false;
  exit;
 end;
 PrimitiveItems:=fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex];
 if assigned(PrimitiveItems) and (PrimitiveItems.Count<MaxSolidPrimitives) then begin
  Primitive:=pointer(PrimitiveItems.AddNew);
  Primitive^.Position:=TpvVector2.Null;
  Primitive^.Position0:=TpvVector3.InlineableCreate(aPosition0,0.0);
  Primitive^.Offset0:=aPosition0Offset;
  Primitive^.Position1:=TpvVector3.InlineableCreate(aPosition1,0.0);
  Primitive^.Offset1:=aPosition1Offset;
  Primitive^.Position2:=TpvVector3.InlineableCreate(aPosition2,0.0);
  Primitive^.Offset2:=aPosition2Offset;
  Primitive^.Position3:=TpvVector3.InlineableCreate(aPosition3,0.0);
  Primitive^.Offset3:=aPosition2Offset;
  Primitive^.Color:=aColor;
  if aLineWidth>0.0 then begin
   Primitive^.PrimitiveTopology:=TSolidPrimitivePrimitive.PrimitiveTopologyQuadWireframe or 8;
  end else begin
   Primitive^.PrimitiveTopology:=TSolidPrimitivePrimitive.PrimitiveTopologyQuad or 8;
  end;
  Primitive^.LineThicknessOrPointSize:=aLineWidth;
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TpvScene3DRendererInstance.AddSolidPoint3D(const aInFlightFrameIndex:TpvSizeInt;const aPosition:TpvVector3;const aColor:TpvVector4;const aSize:TpvScalar;const aPositionOffset:TpvVector2;const aLineWidth:TpvScalar):Boolean;
var Primitive:PSolidPrimitivePrimitive;
    PrimitiveItems:TSolidPrimitivePrimitiveDynamicArray;
begin
 if aInFlightFrameIndex<0 then begin
  result:=false;
  exit;
 end;
 PrimitiveItems:=fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex];
 if assigned(PrimitiveItems) and (PrimitiveItems.Count<MaxSolidPrimitives) then begin
  Primitive:=pointer(PrimitiveItems.AddNew);
  Primitive^.Position:=TpvVector2.Null;
  Primitive^.Position0:=aPosition;
  Primitive^.Offset0:=aPositionOffset;
  Primitive^.Color:=aColor;
  if aLineWidth>0.0 then begin
   Primitive^.PrimitiveTopology:=TSolidPrimitivePrimitive.PrimitiveTopologyPointWireframe;
   Primitive^.LineThicknessOrPointSize:=aSize+(aLineWidth*0.5);
   Primitive^.InnerRadius:=aSize-(aLineWidth*0.5);
  end else begin
   Primitive^.PrimitiveTopology:=TSolidPrimitivePrimitive.PrimitiveTopologyPoint;
   Primitive^.LineThicknessOrPointSize:=aSize;
   Primitive^.InnerRadius:=aSize;
  end;
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TpvScene3DRendererInstance.AddSolidLine3D(const aInFlightFrameIndex:TpvSizeInt;const aStartPosition,aEndPosition:TpvVector3;const aColor:TpvVector4;const aSize:TpvScalar;const aStartPositionOffset,aEndPositionOffset:TpvVector2):Boolean;
var Primitive:PSolidPrimitivePrimitive;
    PrimitiveItems:TSolidPrimitivePrimitiveDynamicArray;
begin
 if aInFlightFrameIndex<0 then begin
  result:=false;
  exit;
 end;
 PrimitiveItems:=fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex];
 if assigned(PrimitiveItems) and (PrimitiveItems.Count<MaxSolidPrimitives) then begin
  Primitive:=pointer(PrimitiveItems.AddNew);
  Primitive^.Position:=TpvVector2.Null;
  Primitive^.Position0:=aStartPosition;
  Primitive^.Offset0:=aStartPositionOffset;
  Primitive^.Position1:=aEndPosition;
  Primitive^.Offset1:=aEndPositionOffset;
  Primitive^.Color:=aColor;
  Primitive^.PrimitiveTopology:=TSolidPrimitivePrimitive.PrimitiveTopologyLine;
  Primitive^.LineThicknessOrPointSize:=aSize;
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TpvScene3DRendererInstance.AddSolidTriangle3D(const aInFlightFrameIndex:TpvSizeInt;const aPosition0,aPosition1,aPosition2:TpvVector3;const aColor:TpvVector4;const aPosition0Offset,aPosition1Offset,aPosition2Offset:TpvVector2;const aLineWidth:TpvScalar=0.0):Boolean;
var Primitive:PSolidPrimitivePrimitive;
    PrimitiveItems:TSolidPrimitivePrimitiveDynamicArray;
begin
 if aInFlightFrameIndex<0 then begin
  result:=false;
  exit;
 end;
 PrimitiveItems:=fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex];
 if assigned(PrimitiveItems) and (PrimitiveItems.Count<MaxSolidPrimitives) then begin
  Primitive:=pointer(PrimitiveItems.AddNew);
  Primitive^.Position:=TpvVector2.Null;
  Primitive^.Position0:=aPosition0;
  Primitive^.Offset0:=aPosition0Offset;
  Primitive^.Position1:=aPosition1;
  Primitive^.Offset1:=aPosition1Offset;
  Primitive^.Position2:=aPosition2;
  Primitive^.Offset2:=aPosition2Offset;
  Primitive^.Color:=aColor;
  if aLineWidth>0.0 then begin
   Primitive^.PrimitiveTopology:=TSolidPrimitivePrimitive.PrimitiveTopologyTriangleWireframe;
  end else begin
   Primitive^.PrimitiveTopology:=TSolidPrimitivePrimitive.PrimitiveTopologyTriangle;
  end;
  Primitive^.LineThicknessOrPointSize:=aLineWidth;
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TpvScene3DRendererInstance.AddSolidQuad3D(const aInFlightFrameIndex:TpvSizeInt;const aPosition0,aPosition1,aPosition2,aPosition3:TpvVector3;const aColor:TpvVector4;const aPosition0Offset,aPosition1Offset,aPosition2Offset,aPosition3Offset:TpvVector2;const aLineWidth:TpvScalar=0.0):Boolean;
var Primitive:PSolidPrimitivePrimitive;
    PrimitiveItems:TSolidPrimitivePrimitiveDynamicArray;
begin
 if aInFlightFrameIndex<0 then begin
  result:=false;
  exit;
 end;
 PrimitiveItems:=fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex];
 if assigned(PrimitiveItems) and (PrimitiveItems.Count<MaxSolidPrimitives) then begin
  Primitive:=pointer(PrimitiveItems.AddNew);
  Primitive^.Position:=TpvVector2.Null;
  Primitive^.Position0:=aPosition0;
  Primitive^.Offset0:=aPosition0Offset;
  Primitive^.Position1:=aPosition1;
  Primitive^.Offset1:=aPosition1Offset;
  Primitive^.Position2:=aPosition2;
  Primitive^.Offset2:=aPosition2Offset;
  Primitive^.Position3:=aPosition3;
  Primitive^.Offset3:=aPosition3Offset;
  Primitive^.Color:=aColor;
  if aLineWidth>0.0 then begin
   Primitive^.PrimitiveTopology:=TSolidPrimitivePrimitive.PrimitiveTopologyQuadWireframe;
  end else begin
   Primitive^.PrimitiveTopology:=TSolidPrimitivePrimitive.PrimitiveTopologyQuad;
  end;
  Primitive^.LineThicknessOrPointSize:=aLineWidth;
  result:=true;
 end else begin
  result:=false;
 end;
end;

procedure TpvScene3DRendererInstance.Update(const aInFlightFrameIndex:TpvInt32;const aFrameCounter:TpvInt64);
begin
 fFrameGraph.Update(aInFlightFrameIndex,aFrameCounter);
end;

function TpvScene3DRendererInstance.GetCameraPreset(const aInFlightFrameIndex:TpvInt32):TpvScene3DRendererCameraPreset;
begin
 result:=fCameraPresets[aInFlightFrameIndex];
end;

function TpvScene3DRendererInstance.GetCameraViewMatrix(const aInFlightFrameIndex:TpvInt32):TpvMatrix4x4D;
begin
 result:=fCameraViewMatrices[aInFlightFrameIndex];
end;

procedure TpvScene3DRendererInstance.SetCameraViewMatrix(const aInFlightFrameIndex:TpvInt32;const aCameraViewMatrix:TpvMatrix4x4D);
begin
 fCameraViewMatrices[aInFlightFrameIndex]:=aCameraViewMatrix;
end;

procedure TpvScene3DRendererInstance.ResetFrame(const aInFlightFrameIndex:TpvInt32);
var RenderPass:TpvScene3DRendererRenderPass;
begin

 fViews[aInFlightFrameIndex].Count:=0;

 fCountRealViews[aInFlightFrameIndex]:=0;

 fSnapshotDrawDataGeneration[aInFlightFrameIndex]:=fScene3D.DrawDataGeneration;

 if fCachedDrawDataGeneration[aInFlightFrameIndex]<>fSnapshotDrawDataGeneration[aInFlightFrameIndex] then begin

  //WriteLn('[DEBUG] ResetFrame IFF=',aInFlightFrameIndex,' REBUILD (cached=',fCachedDrawDataGeneration[aInFlightFrameIndex],' scene=',fSnapshotDrawDataGeneration[aInFlightFrameIndex],')');

  fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count:=0;

  fDrawChoreographyBatchRangeFrameBuckets[aInFlightFrameIndex].Count:=0;

  for RenderPass:=TpvScene3DRendererRenderPassFirst to TpvScene3DRendererRenderPassLast do begin
   fDrawChoreographyBatchRangeFrameRenderPassBuckets[aInFlightFrameIndex,RenderPass].Count:=0;
  end;

 end else begin
  //WriteLn('[DEBUG] ResetFrame IFF=',aInFlightFrameIndex,' CACHED (gen=',fCachedDrawDataGeneration[aInFlightFrameIndex],')');
 end;

end;

function TpvScene3DRendererInstance.AddView(const aInFlightFrameIndex:TpvInt32;const aView:TpvScene3D.TView):TpvInt32;
begin
 result:=fViews[aInFlightFrameIndex].Add(aView);
end;

function TpvScene3DRendererInstance.AddViews(const aInFlightFrameIndex:TpvInt32;const aViews:array of TpvScene3D.TView):TpvInt32;
begin
 result:=fViews[aInFlightFrameIndex].Add(aViews);
end;

procedure TpvScene3DRendererInstance.CalculateSceneBounds(const aInFlightFrameIndex:TpvInt32);
var Index:TpvSizeInt;
    LocalZNear,LocalZFar,RealZNear,RealZFar,Value:TpvScalar;
    DoNeedRefitNearFarPlanes:boolean;
    InFlightFrameState:PInFlightFrameState;
    ViewMatrix:TpvMatrix4x4;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 InFlightFrameState:=@fInFlightFrameStates[aInFlightFrameIndex];

 InFlightFrameState^.SceneWorldSpaceBoundingBox:=fScene3D.InFlightFrameBoundingBoxes[aInFlightFrameIndex];

 InFlightFrameState^.SceneWorldSpaceSphere:=TpvSphere.CreateFromAABB(InFlightFrameState^.SceneWorldSpaceBoundingBox);

 if IsInfinite(fZFar) then begin
  RealZNear:=0.1;
  RealZFar:=16.0;
  for Index:=0 to fCountRealViews[aInFlightFrameIndex]-1 do begin
   ViewMatrix:=fViews[aInFlightFrameIndex].Items[Index].ViewMatrix.SimpleInverse;
   if InFlightFrameState^.SceneWorldSpaceSphere.Contains(ViewMatrix.Translation.xyz) then begin
    if InFlightFrameState^.SceneWorldSpaceSphere.RayIntersection(ViewMatrix.Translation.xyz,-ViewMatrix.Forwards.xyz,Value) then begin
     Value:=Value*2.0;
    end else begin
     Value:=InFlightFrameState^.SceneWorldSpaceSphere.Radius;
    end;
   end else begin
    Value:=InFlightFrameState^.SceneWorldSpaceSphere.Center.DistanceTo(ViewMatrix.Translation.xyz)+InFlightFrameState^.SceneWorldSpaceSphere.Radius;
   end;
   RealZFar:=Max(RealZFar,Value);
  end;
{ RealZNear:=0.1;
  RealZFar:=1024.0;}
  LocalZNear:=RealZNear;
  LocalZFar:=RealZFar;
  DoNeedRefitNearFarPlanes:=true;
 end else begin
  LocalZNear:=abs(fZNear);
  LocalZFar:=abs(fZFar);
  RealZNear:=LocalZNear;
  RealZFar:=LocalZFar;
  DoNeedRefitNearFarPlanes:=fZFar<0.0;
 end;

 InFlightFrameState^.ZNear:=Min(RealZNear,1e-4);
 InFlightFrameState^.ZFar:=RealZFar;

 InFlightFrameState^.DoNeedRefitNearFarPlanes:=DoNeedRefitNearFarPlanes;

 InFlightFrameState^.AdjustedZNear:=LocalZNear;
 InFlightFrameState^.AdjustedZFar:=LocalZFar;

 InFlightFrameState^.RealZNear:=RealZNear;
 InFlightFrameState^.RealZFar:=RealZFar;

end;

procedure TpvScene3DRendererInstance.CalculateCascadedShadowMaps(const aInFlightFrameIndex:TpvInt32);
begin
 fCascadedShadowMapBuilder.Calculate(aInFlightFrameIndex);
end;

function TpvScene3DRendererInstance.GetJitterOffset(const aFrameCounter:TpvInt64):TpvVector2;
const SMAAT2xOffsets:array[0..1] of TpvVector2=
       (
        (x:0.25;y:0.25),
        (x:-0.25;y:-0.25)
       );
begin
 case Renderer.AntialiasingMode of
  TpvScene3DRendererAntialiasingMode.SMAAT2x:begin
   if aFrameCounter>=0 then begin
    result:=SMAAT2xOffsets[aFrameCounter and 1]/TpvVector2.InlineableCreate(fScaledWidth,fScaledHeight);
   end else begin
    result.x:=0.0;
    result.y:=0.0;
   end;
  end;
  TpvScene3DRendererAntialiasingMode.TAA:begin
   if aFrameCounter>=0 then begin
    result:=((JitterOffsets[aFrameCounter and JitterOffsetMask]-TpvVector2.InlineableCreate(0.5,0.5))*2.0)/TpvVector2.InlineableCreate(fScaledWidth,fScaledHeight);
   end else begin
    result.x:=0.0;
    result.y:=0.0;
   end;
  end;
  else begin
   result.x:=0.0;
   result.y:=0.0;
  end;
 end;
end;

function TpvScene3DRendererInstance.AddTemporalAntialiasingJitter(const aProjectionMatrix:TpvMatrix4x4;const aFrameCounter:TpvInt64):TpvMatrix4x4;
var Offset:TpvVector2;
begin
 result:=aProjectionMatrix;
 case Renderer.AntialiasingMode of
  TpvScene3DRendererAntialiasingMode.SMAAT2x,
  TpvScene3DRendererAntialiasingMode.TAA:begin
   Offset:=GetJitterOffset(aFrameCounter);
   result:=result*TpvMatrix4x4.CreateTranslation(Offset.x,Offset.y);
{  result.RawComponents[2,0]:=Offset.x*result.RawComponents[2,3];
   result.RawComponents[2,1]:=Offset.y*result.RawComponents[2,3];}
  end;
 end;
end;

procedure TpvScene3DRendererInstance.UpdateGlobalIlluminationCascadedRadianceHints(const aInFlightFrameIndex:TpvInt32);
var CascadeIndex:TpvSizeInt;
    InFlightFrameState:TpvScene3DRendererInstance.PInFlightFrameState;
    GlobalIlluminationRadianceHintsUniformBufferData:PGlobalIlluminationRadianceHintsUniformBufferData;
    GlobalIlluminationRadianceHintsRSMUniformBufferData:PGlobalIlluminationRadianceHintsRSMUniformBufferData;
    CascadedVolumeCascade:TpvScene3DRendererInstance.TCascadedVolumes.TCascade;
    s:TpvScalar;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 InFlightFrameState:=@fInFlightFrameStates[aInFlightFrameIndex];

 fGlobalIlluminationRadianceHintsCascadedVolumes.Update(aInFlightFrameIndex);

 begin

  GlobalIlluminationRadianceHintsUniformBufferData:=@fGlobalIlluminationRadianceHintsUniformBufferDataArray[aInFlightFrameIndex];

  fInFlightFrameMustRenderGIMaps[aInFlightFrameIndex]:=not Renderer.GlobalIlluminationCaching;

  for CascadeIndex:=0 to CountGlobalIlluminationRadiantHintCascades-1 do begin

   CascadedVolumeCascade:=fGlobalIlluminationRadianceHintsCascadedVolumes.Cascades[CascadeIndex];

   s:=fGlobalIlluminationRadianceHintsCascadedVolumes.Cascades[Min(Max(CascadeIndex+1,0),CountGlobalIlluminationRadiantHintCascades-1)].fCellSize*2.0;

   GlobalIlluminationRadianceHintsUniformBufferData^.AABBMin[CascadeIndex]:=TpvVector4.InlineableCreate(CascadedVolumeCascade.fAABB.Min,0.0);
   GlobalIlluminationRadianceHintsUniformBufferData^.AABBMax[CascadeIndex]:=TpvVector4.InlineableCreate(CascadedVolumeCascade.fAABB.Max,0.0);
   GlobalIlluminationRadianceHintsUniformBufferData^.AABBScale[CascadeIndex]:=TpvVector4.InlineableCreate(TpvVector3.InlineableCreate(1.0,1.0,1.0)/(CascadedVolumeCascade.fAABB.Max-CascadedVolumeCascade.fAABB.Min),0.0);
   GlobalIlluminationRadianceHintsUniformBufferData^.AABBCellSizes[CascadeIndex]:=TpvVector4.InlineableCreate(CascadedVolumeCascade.fCellSize,CascadedVolumeCascade.fCellSize,CascadedVolumeCascade.fCellSize,0.0);
   GlobalIlluminationRadianceHintsUniformBufferData^.AABBSnappedCenter[CascadeIndex]:=TpvVector4.InlineableCreate((CascadedVolumeCascade.fAABB.Min+CascadedVolumeCascade.fAABB.Max)*0.5,0.0);
   GlobalIlluminationRadianceHintsUniformBufferData^.AABBFadeStart[CascadeIndex]:=TpvVector4.InlineableCreate(((CascadedVolumeCascade.fAABB.Max-CascadedVolumeCascade.fAABB.Min)*0.5)-(CascadedVolumeCascade.fSnapSize+TpvVector3.InlineableCreate(s,s,s)),0.0);
   GlobalIlluminationRadianceHintsUniformBufferData^.AABBFadeEnd[CascadeIndex]:=TpvVector4.InlineableCreate(((CascadedVolumeCascade.fAABB.Max-CascadedVolumeCascade.fAABB.Min)*0.5)-CascadedVolumeCascade.fSnapSize,0.0);
   GlobalIlluminationRadianceHintsUniformBufferData^.AABBCenter[CascadeIndex]:=TpvVector4.InlineableCreate(((CascadedVolumeCascade.fAABB.Min+CascadedVolumeCascade.fAABB.Max)*0.5)+CascadedVolumeCascade.fOffset,0.0);
   GlobalIlluminationRadianceHintsUniformBufferData^.AABBDeltas[CascadeIndex].x:=CascadedVolumeCascade.fDelta.x;
   GlobalIlluminationRadianceHintsUniformBufferData^.AABBDeltas[CascadeIndex].y:=CascadedVolumeCascade.fDelta.y;
   GlobalIlluminationRadianceHintsUniformBufferData^.AABBDeltas[CascadeIndex].z:=CascadedVolumeCascade.fDelta.z;
   if Renderer.GlobalIlluminationCaching then begin
    if fGlobalIlluminationRadianceHintsFirsts[aInFlightFrameIndex] then begin
     GlobalIlluminationRadianceHintsUniformBufferData^.AABBDeltas[CascadeIndex].w:=-1;
     fInFlightFrameMustRenderGIMaps[aInFlightFrameIndex]:=true;
    end else begin
     GlobalIlluminationRadianceHintsUniformBufferData^.AABBDeltas[CascadeIndex].w:=CascadedVolumeCascade.fDelta.w;
     if GlobalIlluminationRadianceHintsUniformBufferData^.AABBDeltas[CascadeIndex].w<>0 then begin
      fInFlightFrameMustRenderGIMaps[aInFlightFrameIndex]:=true;
     end;
    end;
   end else begin
    GlobalIlluminationRadianceHintsUniformBufferData^.AABBDeltas[CascadeIndex].w:=-1;
   end;

  end;

 end;

 begin

  GlobalIlluminationRadianceHintsRSMUniformBufferData:=@fGlobalIlluminationRadianceHintsRSMUniformBufferDataArray[aInFlightFrameIndex];

  GlobalIlluminationRadianceHintsRSMUniformBufferData^.WorldToReflectiveShadowMapMatrix:=InFlightFrameState^.ReflectiveShadowMapMatrix;
  GlobalIlluminationRadianceHintsRSMUniformBufferData^.ReflectiveShadowMapToWorldMatrix:=InFlightFrameState^.ReflectiveShadowMapMatrix.Inverse;
  GlobalIlluminationRadianceHintsRSMUniformBufferData^.ModelViewProjectionMatrix:=InFlightFrameState^.MainViewProjectionMatrix;
  GlobalIlluminationRadianceHintsRSMUniformBufferData^.LightDirection:=TpvVector4.InlineableCreate(InFlightFrameState^.ReflectiveShadowMapLightDirection,0.0);
  GlobalIlluminationRadianceHintsRSMUniformBufferData^.LightPosition:=GlobalIlluminationRadianceHintsRSMUniformBufferData^.LightDirection*(-16777216.0);
  GlobalIlluminationRadianceHintsRSMUniformBufferData^.CountSamples:=32;
  GlobalIlluminationRadianceHintsRSMUniformBufferData^.CountOcclusionSamples:=4;
  for CascadeIndex:=0 to 3 do begin
   CascadedVolumeCascade:=fGlobalIlluminationRadianceHintsCascadedVolumes.Cascades[CascadeIndex];
   if Renderer.GlobalIlluminationRadianceHintsSpread<0.0 then begin
    GlobalIlluminationRadianceHintsRSMUniformBufferData^.SpreadExtents[CascadeIndex]:=TpvVector4.InlineableCreate(Min((-Renderer.GlobalIlluminationRadianceHintsSpread)*InFlightFrameState^.ReflectiveShadowMapScale.x,1.0),
                                                                                                                  Min((-Renderer.GlobalIlluminationRadianceHintsSpread)*InFlightFrameState^.ReflectiveShadowMapScale.y,1.0),
                                                                                                                  InFlightFrameState^.ReflectiveShadowMapExtents.x,
                                                                                                                  InFlightFrameState^.ReflectiveShadowMapExtents.y);
   end else begin
    GlobalIlluminationRadianceHintsRSMUniformBufferData^.SpreadExtents[CascadeIndex]:=TpvVector4.InlineableCreate(Min(Renderer.GlobalIlluminationRadianceHintsSpread*CascadedVolumeCascade.fCellSize*fGlobalIlluminationRadianceHintsCascadedVolumes.fVolumeSize*InFlightFrameState^.ReflectiveShadowMapScale.x,1.0),
                                                                                                                  Min(Renderer.GlobalIlluminationRadianceHintsSpread*CascadedVolumeCascade.fCellSize*fGlobalIlluminationRadianceHintsCascadedVolumes.fVolumeSize*InFlightFrameState^.ReflectiveShadowMapScale.y,1.0),
                                                                                                                  InFlightFrameState^.ReflectiveShadowMapExtents.x,
                                                                                                                  InFlightFrameState^.ReflectiveShadowMapExtents.y);
   end;
// s:=sqr(InFlightFrameState^.ReflectiveShadowMapExtents.Length*0.5)/(fReflectiveShadowMapWidth*fReflectiveShadowMapHeight);
   s:=((1.0)*
       (GlobalIlluminationRadianceHintsRSMUniformBufferData^.SpreadExtents[CascadeIndex].x*
        GlobalIlluminationRadianceHintsRSMUniformBufferData^.SpreadExtents[CascadeIndex].y*
        GlobalIlluminationRadianceHintsRSMUniformBufferData^.SpreadExtents[CascadeIndex].z*
        GlobalIlluminationRadianceHintsRSMUniformBufferData^.SpreadExtents[CascadeIndex].w))/
      GlobalIlluminationRadianceHintsRSMUniformBufferData^.CountSamples;
   GlobalIlluminationRadianceHintsRSMUniformBufferData^.ScaleFactors.RawComponents[CascadeIndex]:=s;
// GlobalIlluminationRadianceHintsRSMUniformBufferData^.ScaleFactors.RawComponents[CascadeIndex]:=(1.0*(InFlightFrameState^.ReflectiveShadowMapExtents.x*InFlightFrameState^.ReflectiveShadowMapExtents.y))/GlobalIlluminationRadianceHintsRSMUniformBufferData^.CountSamples;
//   GlobalIlluminationRadianceHintsRSMUniformBufferData^.ScaleFactors.RawComponents[CascadeIndex]:=(fReflectiveShadowMapWidth*fReflectiveShadowMapHeight)/(CascadedVolumeCascade.fCellSize*CascadedVolumeCascade.fCellSize*GlobalIlluminationRadianceHintsRSMUniformBufferData^.CountSamples);
// GlobalIlluminationRadianceHintsRSMUniformBufferData^.ScaleFactors.RawComponents[CascadeIndex]:=(4.0*(InFlightFrameState^.ReflectiveShadowMapExtents.x*InFlightFrameState^.ReflectiveShadowMapExtents.y))/(CascadedVolumeCascade.fCellSize*CascadedVolumeCascade.fCellSize*GlobalIlluminationRadianceHintsRSMUniformBufferData^.CountSamples);
  end;

 end;

 if Renderer.GlobalIlluminationCaching then begin
  fGlobalIlluminationRadianceHintsFirsts[aInFlightFrameIndex]:=false;
 end;

end;

procedure TpvScene3DRendererInstance.UpdateGlobalIlluminationDDGI(const aInFlightFrameIndex:TpvInt32);
var CascadeIndex:TpvSizeInt;
    DDGIData:PGlobalIlluminationDDGIUniformBufferData;
    Cascade:TpvScene3DRendererInstance.TCascadedVolumes.TCascade;
    Extent:TpvVector3;
    s:TpvScalar;
    BaseCell,PrevBaseCell:TpvVector3;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 fGlobalIlluminationDDGICascadedVolumes.Update(aInFlightFrameIndex);

 DDGIData:=@fGlobalIlluminationDDGIUniformBufferDataArray[aInFlightFrameIndex];

 for CascadeIndex:=0 to CountGlobalIlluminationDDGICascades-1 do begin
  Cascade:=fGlobalIlluminationDDGICascadedVolumes.Cascades[CascadeIndex];
  Extent:=Cascade.fAABB.Max-Cascade.fAABB.Min;
  s:=fGlobalIlluminationDDGICascadedVolumes.Cascades[Min(Max(CascadeIndex+1,0),CountGlobalIlluminationDDGICascades-1)].fCellSize*2.0;
  DDGIData^.AABBMin[CascadeIndex]:=TpvVector4.InlineableCreate(Cascade.fAABB.Min,0.0);
  DDGIData^.AABBMax[CascadeIndex]:=TpvVector4.InlineableCreate(Cascade.fAABB.Max,0.0);
  DDGIData^.AABBScale[CascadeIndex]:=TpvVector4.InlineableCreate(TpvVector3.InlineableCreate(1.0,1.0,1.0)/Extent,0.0);
  // CellSizes.w = maximum probe ray distance: the cascade diagonal so probes can see geometry across the whole cascade.
  DDGIData^.CellSizes[CascadeIndex]:=TpvVector4.InlineableCreate(Cascade.fCellSize,Cascade.fCellSize,Cascade.fCellSize,Extent.Length);
  DDGIData^.AABBCenter[CascadeIndex]:=TpvVector4.InlineableCreate(((Cascade.fAABB.Min+Cascade.fAABB.Max)*0.5)+Cascade.fOffset,0.0);
  DDGIData^.AABBFadeStart[CascadeIndex]:=TpvVector4.InlineableCreate((Extent*0.5)-(Cascade.fSnapSize+TpvVector3.InlineableCreate(s,s,s)),0.0);
  DDGIData^.AABBFadeEnd[CascadeIndex]:=TpvVector4.InlineableCreate((Extent*0.5)-Cascade.fSnapSize,0.0);
  // Toroidal scroll base cell: AABBMin is snapped to whole cellSize increments, so floor(AABBMin/cellSize) is the integer
  // world-cell offset of the cascade min corner. The shader maps logical<->physical probe slots by this (mod probeCount),
  // keeping a world-fixed probe's history on the same texel as the volume scrolls; the previous value (per in-flight slot)
  // lets the shader re-initialize probes that just scrolled in.
  BaseCell:=(Cascade.fAABB.Min/Cascade.fCellSize).Round;
  PrevBaseCell:=fGlobalIlluminationDDGIProbeBaseCells[aInFlightFrameIndex,CascadeIndex];
  DDGIData^.ProbeScroll[CascadeIndex].x:=Trunc(BaseCell.x);
  DDGIData^.ProbeScroll[CascadeIndex].y:=Trunc(BaseCell.y);
  DDGIData^.ProbeScroll[CascadeIndex].z:=Trunc(BaseCell.z);
  DDGIData^.ProbeScroll[CascadeIndex].w:=1; // scrolling enabled
  DDGIData^.ProbeScrollPrev[CascadeIndex].x:=Trunc(PrevBaseCell.x);
  DDGIData^.ProbeScrollPrev[CascadeIndex].y:=Trunc(PrevBaseCell.y);
  DDGIData^.ProbeScrollPrev[CascadeIndex].z:=Trunc(PrevBaseCell.z);
  DDGIData^.ProbeScrollPrev[CascadeIndex].w:=0;
  fGlobalIlluminationDDGIProbeBaseCells[aInFlightFrameIndex,CascadeIndex]:=BaseCell;
 end;

end;

procedure TpvScene3DRendererInstance.UploadGlobalIlluminationDDGI(const aInFlightFrameIndex:TpvInt32);
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                            fScene3D.VulkanStagingCommandBuffer,
                                            fScene3D.VulkanStagingFence,
                                            fGlobalIlluminationDDGIUniformBufferDataArray[aInFlightFrameIndex],
                                            fGlobalIlluminationDDGIMasterBuffers[aInFlightFrameIndex], // cascade globals live at offset 0 of the unified ddgiData buffer (the sub-buffer pointers, written once, sit after them)
                                            0,
                                            SizeOf(TGlobalIlluminationDDGIUniformBufferData));

end;

function TpvScene3DRendererInstance.GetGlobalIlluminationDDGIFirstFrame(const aInFlightFrameIndex:TpvSizeInt):boolean;
begin
 result:=fGlobalIlluminationDDGIFirstFrames[aInFlightFrameIndex];
end;

procedure TpvScene3DRendererInstance.SetGlobalIlluminationDDGIFirstFrame(const aInFlightFrameIndex:TpvSizeInt;const aValue:boolean);
begin
 fGlobalIlluminationDDGIFirstFrames[aInFlightFrameIndex]:=aValue;
end;

procedure TpvScene3DRendererInstance.UploadGlobalIlluminationCascadedRadianceHints(const aInFlightFrameIndex:TpvInt32);
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

{if fGlobalIlluminationRadianceHintsFirsts[aInFlightFrameIndex] then}begin
  Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                             fScene3D.VulkanStagingCommandBuffer,
                                             fScene3D.VulkanStagingFence,
                                             fGlobalIlluminationRadianceHintsUniformBufferDataArray[aInFlightFrameIndex],
                                             fGlobalIlluminationRadianceHintsUniformBuffers[aInFlightFrameIndex],
                                             0,
                                             SizeOf(TGlobalIlluminationRadianceHintsUniformBufferData));
 end;

{if fGlobalIlluminationRadianceHintsFirsts[aInFlightFrameIndex] then}begin
  Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                             fScene3D.VulkanStagingCommandBuffer,
                                             fScene3D.VulkanStagingFence,
                                             fGlobalIlluminationRadianceHintsRSMUniformBufferDataArray[aInFlightFrameIndex],
                                             fGlobalIlluminationRadianceHintsRSMUniformBuffers[aInFlightFrameIndex],
                                             0,
                                             SizeOf(TGlobalIlluminationRadianceHintsRSMUniformBufferData));
 end;
end;

procedure TpvScene3DRendererInstance.UpdateGlobalIlluminationCascadedVoxelConeTracing(const aInFlightFrameIndex:TpvInt32);
begin
 fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.Update(aInFlightFrameIndex);
end;

procedure TpvScene3DRendererInstance.UploadGlobalIlluminationCascadedVoxelConeTracing(const aInFlightFrameIndex:TpvInt32);
var CascadeIndex:TpvSizeInt;
    InFlightFrameState:TpvScene3DRendererInstance.PInFlightFrameState;
    GlobalIlluminationCascadedVoxelConeTracingUniformBufferData:PGlobalIlluminationCascadedVoxelConeTracingUniformBufferData;
    CascadedVolumeCascade:TpvScene3DRendererInstance.TCascadedVolumes.TCascade;
    VolumeDimensionSize,s:TpvScalar;
    DataOffset:TpvUInt32;
    AABB:TpvAABB;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 InFlightFrameState:=@fInFlightFrameStates[aInFlightFrameIndex];

 GlobalIlluminationCascadedVoxelConeTracingUniformBufferData:=@fGlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray[aInFlightFrameIndex];

 DataOffset:=0;

 for CascadeIndex:=0 to fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fCountCascades-1 do begin
  CascadedVolumeCascade:=fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.Cascades[CascadeIndex];
  VolumeDimensionSize:=CascadedVolumeCascade.fCellSize*fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize;
{ GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.WorldToCascadeClipSpaceMatrices[CascadeIndex]:=TpvMatrix4x4.Create(fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize/VolumeDimensionSize,0.0,0.0,0.0,
                                                                                                                                  0.0,fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize/VolumeDimensionSize,0.0,0.0,
                                                                                                                                  0.0,0.0,fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize/VolumeDimensionSize,0.0,
                                                                                                                                  -(CascadedVolumeCascade.fAABB.Min.x*(fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize/VolumeDimensionSize)),-(CascadedVolumeCascade.fAABB.Min.y*(fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize/VolumeDimensionSize)),-(CascadedVolumeCascade.fAABB.Min.z*(fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize/VolumeDimensionSize)),1.0);}
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.WorldToCascadeClipSpaceMatrices[CascadeIndex]:=TpvMatrix4x4.Create(2.0/VolumeDimensionSize,0.0,0.0,0.0,
                                                                                                                                  0.0,2.0/VolumeDimensionSize,0.0,0.0,
                                                                                                                                  0.0,0.0,2.0/VolumeDimensionSize,0.0,
                                                                                                                                  -(1.0+(CascadedVolumeCascade.fAABB.Min.x*(2.0/VolumeDimensionSize))),
                                                                                                                                  -(1.0+(CascadedVolumeCascade.fAABB.Min.y*(2.0/VolumeDimensionSize))),
                                                                                                                                  -(1.0+(CascadedVolumeCascade.fAABB.Min.z*(2.0/VolumeDimensionSize))),
                                                                                                                                  1.0);
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.WorldToCascadeNormalizedMatrices[CascadeIndex]:=TpvMatrix4x4.Create(1.0/VolumeDimensionSize,0.0,0.0,0.0,
                                                                                                                                   0.0,1.0/VolumeDimensionSize,0.0,0.0,
                                                                                                                                   0.0,0.0,1.0/VolumeDimensionSize,0.0,
                                                                                                                                   -(CascadedVolumeCascade.fAABB.Min.x/VolumeDimensionSize),
                                                                                                                                   -(CascadedVolumeCascade.fAABB.Min.y/VolumeDimensionSize),
                                                                                                                                   -(CascadedVolumeCascade.fAABB.Min.z/VolumeDimensionSize),
                                                                                                                                   1.0);
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.WorldToCascadeGridMatrices[CascadeIndex]:=TpvMatrix4x4.Create(fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize/VolumeDimensionSize,0.0,0.0,0.0,
                                                                                                                             0.0,fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize/VolumeDimensionSize,0.0,0.0,
                                                                                                                             0.0,0.0,fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize/VolumeDimensionSize,0.0,
                                                                                                                             -(CascadedVolumeCascade.fAABB.Min.x*(fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize/VolumeDimensionSize)),
                                                                                                                             -(CascadedVolumeCascade.fAABB.Min.y*(fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize/VolumeDimensionSize)),
                                                                                                                             -(CascadedVolumeCascade.fAABB.Min.z*(fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize/VolumeDimensionSize)),
                                                                                                                             1.0);
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeGridToWorldMatrices[CascadeIndex]:=TpvMatrix4x4.Create(VolumeDimensionSize/fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize,0.0,0.0,0.0,
                                                                                                                             0.0,VolumeDimensionSize/fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize,0.0,0.0,
                                                                                                                             0.0,0.0,VolumeDimensionSize/fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize,0.0,
                                                                                                                             CascadedVolumeCascade.fAABB.Min.x,
                                                                                                                             CascadedVolumeCascade.fAABB.Min.y,
                                                                                                                             CascadedVolumeCascade.fAABB.Min.z,
                                                                                                                             1.0);
  if CascadeIndex>0 then begin
   AABB:=fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.Cascades[CascadeIndex-1].fAABB;
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMin[CascadeIndex,0]:=floor((AABB.Min.x-CascadedVolumeCascade.fAABB.Min.x)/CascadedVolumeCascade.fCellSize);
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMin[CascadeIndex,1]:=floor((AABB.Min.y-CascadedVolumeCascade.fAABB.Min.y)/CascadedVolumeCascade.fCellSize);
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMin[CascadeIndex,2]:=floor((AABB.Min.z-CascadedVolumeCascade.fAABB.Min.z)/CascadedVolumeCascade.fCellSize);
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMin[CascadeIndex,3]:=0;
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMax[CascadeIndex,0]:=ceil((AABB.Max.x-CascadedVolumeCascade.fAABB.Min.x)/CascadedVolumeCascade.fCellSize);
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMax[CascadeIndex,1]:=ceil((AABB.Max.y-CascadedVolumeCascade.fAABB.Min.y)/CascadedVolumeCascade.fCellSize);
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMax[CascadeIndex,2]:=ceil((AABB.Max.z-CascadedVolumeCascade.fAABB.Min.z)/CascadedVolumeCascade.fCellSize);
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMax[CascadeIndex,3]:=0;
  end else begin
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMin[CascadeIndex,0]:=$7fffffff;
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMin[CascadeIndex,1]:=$7fffffff;
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMin[CascadeIndex,2]:=$7fffffff;
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMin[CascadeIndex,3]:=0;
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMax[CascadeIndex,0]:=-$80000000;
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMax[CascadeIndex,1]:=-$80000000;
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMax[CascadeIndex,2]:=-$80000000;
   GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAvoidAABBGridMax[CascadeIndex,3]:=0;
  end;
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAABBMin[CascadeIndex]:=TpvVector4.InlineableCreate(CascadedVolumeCascade.fAABB.Min,0.0);
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAABBMax[CascadeIndex]:=TpvVector4.InlineableCreate(CascadedVolumeCascade.fAABB.Max,0.0);
  s:=fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.Cascades[Min(Max(CascadeIndex+1,0),fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fCountCascades-1)].fCellSize*2.0;
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAABBFadeStart[CascadeIndex]:=TpvVector4.InlineableCreate(((CascadedVolumeCascade.fAABB.Max-CascadedVolumeCascade.fAABB.Min)*0.5)-(CascadedVolumeCascade.fSnapSize+TpvVector3.InlineableCreate(s,s,s)),0.0);
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeAABBFadeEnd[CascadeIndex]:=TpvVector4.InlineableCreate(((CascadedVolumeCascade.fAABB.Max-CascadedVolumeCascade.fAABB.Min)*0.5)-CascadedVolumeCascade.fSnapSize,0.0);
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeCenterHalfExtents[CascadeIndex]:=TpvVector4.InlineableCreate((CascadedVolumeCascade.fAABB.Min+CascadedVolumeCascade.fAABB.Max)*0.5,VolumeDimensionSize*0.5);
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.WorldToCascadeScales[CascadeIndex]:=1.0/VolumeDimensionSize;
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeToWorldScales[CascadeIndex]:=VolumeDimensionSize;
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CascadeCellSizes[CascadeIndex]:=CascadedVolumeCascade.fCellSize;
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.OneOverGridSizes[CascadeIndex]:=1.0/fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize;
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.GridSizes[CascadeIndex]:=fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize;
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.DataOffsets[CascadeIndex]:=DataOffset;
  inc(DataOffset,fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize*
                 fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize*
                 fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fVolumeSize);
 end;


 GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.CountCascades:=fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes.fCountCascades;

 if assigned(Renderer.VulkanDevice.PhysicalDevice.ConservativeRasterizationPropertiesEXT.pNext) then begin
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.HardwareConservativeRasterization:=VK_TRUE;
 end else begin
  GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.HardwareConservativeRasterization:=VK_FALSE;
 end;

 GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.MaxGlobalFragmentCount:=fGlobalIlluminationCascadedVoxelConeTracingMaxGlobalFragmentCount;

 GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.MaxLocalFragmentCount:=fGlobalIlluminationCascadedVoxelConeTracingMaxLocalFragmentCount;

 // Global GI emissive master regulators (renderer-wide); the voxelization fragment clamps emission to min(emission*matFactor*scale, matMax, max).
 GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.EmissiveGIScale:=Renderer.GlobalIlluminationEmissiveScale;
 GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^.EmissiveGIMax:=Renderer.GlobalIlluminationEmissiveMaximum;

 Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                            fScene3D.VulkanStagingCommandBuffer,
                                            fScene3D.VulkanStagingFence,
                                            GlobalIlluminationCascadedVoxelConeTracingUniformBufferData^,
                                            fGlobalIlluminationCascadedVoxelConeTracingUniformBuffers[aInFlightFrameIndex],
                                            0,
                                            SizeOf(TGlobalIlluminationCascadedVoxelConeTracingUniformBufferData));

end;

procedure TpvScene3DRendererInstance.AddCameraReflectionProbeViews(const aInFlightFrameIndex:TpvInt32);
const CubeMapMatrices:array[0..5] of TpvMatrix4x4=
       (
        (RawComponents:((0.0,0.0,-1.0,0.0),(0.0,1.0,0.0,0.0),(1.0,0.0,0.0,0.0),(0.0,0.0,0.0,1.0))),    // pos x
        (RawComponents:((0.0,0.0,1.0,0.0),(0.0,1.0,0.0,0.0),(-1.0,0.0,0.0,0.0),(0.0,0.0,0.0,1.0))),    // neg x
        (RawComponents:((-1.0,0.0,0.0,0.0),(0.0,0.0,-1.0,0.0),(0.0,-1.0,0.0,0.0),(0.0,0.0,0.0,1.0))),  // pos y
        (RawComponents:((-1.0,0.0,0.0,0.0),(0.0,0.0,1.0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,0.0,1.0))),    // neg y
        (RawComponents:((-1.0,0.0,0.0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,-1.0,0.0),(0.0,0.0,0.0,1.0))),   // pos z
        (RawComponents:((1.0,0.0,0.0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,1.0,0.0),(0.0,0.0,0.0,1.0)))      // neg z
       );//}
{       (
        (RawComponents:((0.0,0.0,-1.0,0.0),(0.0,-1.0,0.0,0.0),(-1.0,0.0,0.0,0.0),(0.0,0.0,0.0,1.0))),  // pos x
        (RawComponents:((0.0,0.0,1.0,0.0),(0.0,-1.0,0.0,0.0),(1.0,0.0,0.0,0.0),(0.0,0.0,0.0,1.0))),    // neg x
        (RawComponents:((1.0,0.0,0.0,0.0),(0.0,0.0,-1.0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,0.0,1.0))),    // pos y
        (RawComponents:((1.0,0.0,0.0,0.0),(0.0,0.0,1.0,0.0),(0.0,-1.0,0.0,0.0),(0.0,0.0,0.0,1.0))),    // neg y
        (RawComponents:((1.0,0.0,0.0,0.0),(0.0,-1.0,0.0,0.0),(0.0,0.0,-1.0,0.0),(0.0,0.0,0.0,1.0))),   // pos z
        (RawComponents:((-1.0,0.0,0.0,0.0),(0.0,-1.0,0.0,0.0),(0.0,0.0,1.0,0.0),(0.0,0.0,0.0,1.0)))    // neg z
       );//}
      CubeMapDirections:array[0..5,0..1] of TpvVector3=
       (
        ((x:1.0;y:0.0;z:0.0),(x:0.0;y:1.0;z:0.0)),  // pos x
        ((x:-1.0;y:0.0;z:0.0),(x:0.0;y:1.0;z:0.0)), // neg x
        ((x:0.0;y:1.0;z:0.0),(x:0.0;y:0.0;z:-1.0)), // pos y
        ((x:0.0;y:-1.0;z:0.0),(x:0.0;y:0.0;z:1.0)), // neg y
        ((x:0.0;y:0.0;z:1.0),(x:0.0;y:1.0;z:0.0)),  // pos z
        ((x:0.0;y:0.0;z:-1.0),(x:0.0;y:1.0;z:0.0))  // neg z
       );
var Index:TpvSizeInt;
    InFlightFrameState:PInFlightFrameState;
    CameraPositon:TpvVector3;
    View:TpvScene3D.TView;
    zNear,zFar:TpvScalar;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 InFlightFrameState:=@fInFlightFrameStates[aInFlightFrameIndex];

//CameraPositon:=-fViews.Items[InFlightFrameState^.FinalViewIndex].ViewMatrix.Translation.xyz;

 CameraPositon:=TpvMatrix4x4(TpvScene3D(fScene3D).TransformOrigin(fCameraViewMatrices[aInFlightFrameIndex],aInFlightFrameIndex,true)).SimpleInverse.Translation.xyz;

 zNear:=abs(fZNear);
 zFar:=IfThen(IsInfinite(fZFar),1024.0,abs(fZFar));

 View.ProjectionMatrix.RawComponents[0,0]:=-1.0;
 View.ProjectionMatrix.RawComponents[0,1]:=0.0;
 View.ProjectionMatrix.RawComponents[0,2]:=0.0;
 View.ProjectionMatrix.RawComponents[0,3]:=0.0;

 View.ProjectionMatrix.RawComponents[1,0]:=0.0;
 View.ProjectionMatrix.RawComponents[1,1]:=-1.0; // Flipped Y
 View.ProjectionMatrix.RawComponents[1,2]:=0.0;
 View.ProjectionMatrix.RawComponents[1,3]:=0.0;

 if fZFar>0.0 then begin

  View.ProjectionMatrix.RawComponents[2,0]:=0.0;
  View.ProjectionMatrix.RawComponents[2,1]:=0.0;
  View.ProjectionMatrix.RawComponents[2,2]:=zFar/(zNear-zFar);
  View.ProjectionMatrix.RawComponents[2,3]:=-1.0;

  View.ProjectionMatrix.RawComponents[3,0]:=0.0;
  View.ProjectionMatrix.RawComponents[3,1]:=0.0;
  View.ProjectionMatrix.RawComponents[3,2]:=(-(zNear*zFar))/(zFar-zNear);
  View.ProjectionMatrix.RawComponents[3,3]:=0.0;
{ View.ProjectionMatrix:=TpvMatrix4x4.CreateHorizontalFOVPerspectiveRightHandedZeroToOne(90.0,
                                                                                         1.0,
                                                                                         abs(fZNear),
                                                                                         IfThen(IsInfinite(fZFar),1024.0,abs(fZFar)));//}
 end else begin

  View.ProjectionMatrix.RawComponents[2,0]:=0.0;
  View.ProjectionMatrix.RawComponents[2,1]:=0.0;
  View.ProjectionMatrix.RawComponents[2,2]:=zNear/(zFar-zNear);
  View.ProjectionMatrix.RawComponents[2,3]:=-1.0;

  View.ProjectionMatrix.RawComponents[3,0]:=0.0;
  View.ProjectionMatrix.RawComponents[3,1]:=0.0;
  View.ProjectionMatrix.RawComponents[3,2]:=(zNear*zFar)/(zFar-zNear);
  View.ProjectionMatrix.RawComponents[3,3]:=0.0;

{  View.ProjectionMatrix:=TpvMatrix4x4.CreateHorizontalFOVPerspectiveRightHandedOneToZero(90.0,
                                                                                          1.0,
                                                                                          abs(fZNear),
                                                                                          IfThen(IsInfinite(fZFar),1024.0,abs(fZFar)));//}
 end;
 if fZFar<0.0 then begin
  if IsInfinite(fZFar) then begin
   // Convert to reversed infinite Z
   View.ProjectionMatrix.RawComponents[2,2]:=0.0;
   View.ProjectionMatrix.RawComponents[2,3]:=-1.0;
   View.ProjectionMatrix.RawComponents[3,2]:=abs(fZNear);
  end else begin
   // Convert to reversed non-infinite Z
   View.ProjectionMatrix.RawComponents[2,2]:=abs(fZNear)/(abs(fZFar)-abs(fZNear));
   View.ProjectionMatrix.RawComponents[2,3]:=-1.0;
   View.ProjectionMatrix.RawComponents[3,2]:=(abs(fZNear)*abs(fZFar))/(abs(fZFar)-abs(fZNear));
  end;
 end;
//View.ProjectionMatrix:=View.ProjectionMatrix*TpvMatrix4x4.FlipYClipSpace;
 View.InverseProjectionMatrix:=View.ProjectionMatrix.Inverse;

 for Index:=0 to 5 do begin
  View.ViewMatrix:=TpvMatrix4x4.CreateTranslated(CubeMapMatrices[Index],-CameraPositon);
{  View.ViewMatrix:=TpvMatrix4x4.CreateLookAt(CameraPositon,
                                             CameraPositon+CubeMapDirections[Index,0],
                                             CubeMapDirections[Index,1]);//}
  View.InverseViewMatrix:=View.ViewMatrix.Inverse;
  if Index=0 then begin
   InFlightFrameState^.ReflectionProbeViewIndex:=fViews[aInFlightFrameIndex].Add(View);
  end else begin
   fViews[aInFlightFrameIndex].Add(View);
  end;
 end;

 InFlightFrameState^.CountReflectionProbeViews:=6;

end;

procedure TpvScene3DRendererInstance.AddTopDownSkyOcclusionMapView(const aInFlightFrameIndex:TpvInt32);
var Index:TpvSizeInt;
    InFlightFrameState:PInFlightFrameState;
    Origin,
    TopDownForwardVector,
    TopDownSideVector,
    TopDownUpVector:TpvVector3;
    View:TpvScene3D.TView;
    zNear,zFar:TpvScalar;
    BoundingBox:TpvAABB;
    TopDownViewMatrix,
    TopDownProjectionMatrix,
    TopDownViewProjectionMatrix:TpvMatrix4x4;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 InFlightFrameState:=@fInFlightFrameStates[aInFlightFrameIndex];

 BoundingBox:=fScene3D.InFlightFrameBoundingBoxes[aInFlightFrameIndex];

 BoundingBox.Min.x:=floor(BoundingBox.Min.x/16.0)*16.0;
 BoundingBox.Min.y:=floor(BoundingBox.Min.y/16.0)*16.0;
 BoundingBox.Min.z:=floor(BoundingBox.Min.z/16.0)*16.0;

 BoundingBox.Max.x:=ceil(BoundingBox.Max.x/16.0)*16.0;
 BoundingBox.Max.y:=ceil(BoundingBox.Max.y/16.0)*16.0;
 BoundingBox.Max.z:=ceil(BoundingBox.Max.z/16.0)*16.0;

 Origin:=(BoundingBox.Min+BoundingBox.Max)*0.5;

 TopDownForwardVector:=TpvVector3.InlineableCreate(0.0,-1.0,0.0);
//TopDownForwardVector:=-Renderer.EnvironmentCubeMap.LightDirection.xyz.Normalize;
 TopDownSideVector:=TopDownForwardVector.Perpendicular;
{TopDownSideVector:=TpvVector3.InlineableCreate(-fViews.Items[0].ViewMatrix.RawComponents[0,2],
                                              -fViews.Items[0].ViewMatrix.RawComponents[1,2],
                                              -fViews.Items[0].ViewMatrix.RawComponents[2,2]).Normalize;
 if abs(TopDownForwardVector.Dot(TopDownSideVector))>0.5 then begin
  if abs(TopDownForwardVector.Dot(TpvVector3.YAxis))<0.9 then begin
   TopDownSideVector:=TpvVector3.YAxis;
  end else begin
   TopDownSideVector:=TpvVector3.ZAxis;
  end;
 end;}
 TopDownUpVector:=(TopDownForwardVector.Cross(TopDownSideVector)).Normalize;
 TopDownSideVector:=(TopDownUpVector.Cross(TopDownForwardVector)).Normalize;
 TopDownViewMatrix.RawComponents[0,0]:=TopDownSideVector.x;
 TopDownViewMatrix.RawComponents[0,1]:=TopDownUpVector.x;
 TopDownViewMatrix.RawComponents[0,2]:=TopDownForwardVector.x;
 TopDownViewMatrix.RawComponents[0,3]:=0.0;
 TopDownViewMatrix.RawComponents[1,0]:=TopDownSideVector.y;
 TopDownViewMatrix.RawComponents[1,1]:=TopDownUpVector.y;
 TopDownViewMatrix.RawComponents[1,2]:=TopDownForwardVector.y;
 TopDownViewMatrix.RawComponents[1,3]:=0.0;
 TopDownViewMatrix.RawComponents[2,0]:=TopDownSideVector.z;
 TopDownViewMatrix.RawComponents[2,1]:=TopDownUpVector.z;
 TopDownViewMatrix.RawComponents[2,2]:=TopDownForwardVector.z;
 TopDownViewMatrix.RawComponents[2,3]:=0.0;
 TopDownViewMatrix.RawComponents[3,0]:=-TopDownSideVector.Dot(Origin);
 TopDownViewMatrix.RawComponents[3,1]:=-TopDownUpVector.Dot(Origin);
 TopDownViewMatrix.RawComponents[3,2]:=-TopDownForwardVector.Dot(Origin);
 TopDownViewMatrix.RawComponents[3,3]:=1.0;

 BoundingBox:=BoundingBox.Transform(TopDownViewMatrix);

 TopDownProjectionMatrix:=TpvMatrix4x4.CreateOrthoRightHandedZeroToOne(BoundingBox.Min.x,
                                                                       BoundingBox.Max.x,
                                                                       BoundingBox.Min.y,
                                                                       BoundingBox.Max.y,
                                                                       BoundingBox.Min.z,
                                                                       BoundingBox.Max.z);

 TopDownViewProjectionMatrix:=TopDownViewMatrix*TopDownProjectionMatrix;

 View.ProjectionMatrix:=TopDownProjectionMatrix;
 View.InverseProjectionMatrix:=View.ProjectionMatrix.Inverse;

 View.ViewMatrix:=TopDownViewMatrix;
 View.InverseViewMatrix:=View.ViewMatrix.Inverse;

 InFlightFrameState^.TopDownSkyOcclusionMapViewProjectionMatrix:=TopDownViewProjectionMatrix;

 InFlightFrameState^.TopDownSkyOcclusionMapViewIndex:=fViews[aInFlightFrameIndex].Add(View);
 InFlightFrameState^.CountTopDownSkyOcclusionMapViews:=1;

end;

procedure TpvScene3DRendererInstance.AddReflectiveShadowMapView(const aInFlightFrameIndex:TpvInt32);
var Index:TpvSizeInt;
    InFlightFrameState:PInFlightFrameState;
    Origin,
    LightForwardVector,
    LightSideVector,
    LightUpVector,
    Extents,
    Scale:TpvVector3;
    View:TpvScene3D.TView;
    zNear,zFar,f:TpvScalar;
    BoundingBox:TpvAABB;
    LightViewMatrix,
    LightProjectionMatrix,
    LightViewProjectionMatrix:TpvMatrix4x4;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 InFlightFrameState:=@fInFlightFrameStates[aInFlightFrameIndex];

 BoundingBox:=fScene3D.InFlightFrameBoundingBoxes[aInFlightFrameIndex];

 BoundingBox.Min.x:=floor(BoundingBox.Min.x/1.0)*1.0;
 BoundingBox.Min.y:=floor(BoundingBox.Min.y/1.0)*1.0;
 BoundingBox.Min.z:=floor(BoundingBox.Min.z/1.0)*1.0;

 BoundingBox.Max.x:=ceil(BoundingBox.Max.x/1.0)*1.0;
 BoundingBox.Max.y:=ceil(BoundingBox.Max.y/1.0)*1.0;
 BoundingBox.Max.z:=ceil(BoundingBox.Max.z/1.0)*1.0;

 Origin:=(BoundingBox.Min+BoundingBox.Max)*0.5;

 LightForwardVector:=-fScene3D.PrimaryShadowMapLightDirections[aInFlightFrameIndex].xyz.Normalize;
//LightForwardVector:=-Renderer.EnvironmentCubeMap.LightDirection.xyz.Normalize;
 LightSideVector:=LightForwardVector.Perpendicular;
{LightSideVector:=TpvVector3.InlineableCreate(-fViews.Items[0].ViewMatrix.RawComponents[0,2],
                                              -fViews.Items[0].ViewMatrix.RawComponents[1,2],
                                              -fViews.Items[0].ViewMatrix.RawComponents[2,2]).Normalize;
 if abs(LightForwardVector.Dot(LightSideVector))>0.5 then begin
  if abs(LightForwardVector.Dot(TpvVector3.YAxis))<0.9 then begin
   LightSideVector:=TpvVector3.YAxis;
  end else begin
   LightSideVector:=TpvVector3.ZAxis;
  end;
 end;}
 LightUpVector:=(LightForwardVector.Cross(LightSideVector)).Normalize;
 LightSideVector:=(LightUpVector.Cross(LightForwardVector)).Normalize;
 LightViewMatrix.RawComponents[0,0]:=LightSideVector.x;
 LightViewMatrix.RawComponents[0,1]:=LightUpVector.x;
 LightViewMatrix.RawComponents[0,2]:=LightForwardVector.x;
 LightViewMatrix.RawComponents[0,3]:=0.0;
 LightViewMatrix.RawComponents[1,0]:=LightSideVector.y;
 LightViewMatrix.RawComponents[1,1]:=LightUpVector.y;
 LightViewMatrix.RawComponents[1,2]:=LightForwardVector.y;
 LightViewMatrix.RawComponents[1,3]:=0.0;
 LightViewMatrix.RawComponents[2,0]:=LightSideVector.z;
 LightViewMatrix.RawComponents[2,1]:=LightUpVector.z;
 LightViewMatrix.RawComponents[2,2]:=LightForwardVector.z;
 LightViewMatrix.RawComponents[2,3]:=0.0;
 LightViewMatrix.RawComponents[3,0]:=-LightSideVector.Dot(Origin);
 LightViewMatrix.RawComponents[3,1]:=-LightUpVector.Dot(Origin);
 LightViewMatrix.RawComponents[3,2]:=-LightForwardVector.Dot(Origin);
 LightViewMatrix.RawComponents[3,3]:=1.0;

 BoundingBox:=BoundingBox.Transform(LightViewMatrix);

{f:=4.0;

 BoundingBox.Min:=BoundingBox.Min*f;

 BoundingBox.Max:=BoundingBox.Max*f;}

 LightProjectionMatrix:=TpvMatrix4x4.CreateOrthoRightHandedZeroToOne(BoundingBox.Min.x,
                                                                     BoundingBox.Max.x,
                                                                     BoundingBox.Min.y,
                                                                     BoundingBox.Max.y,
                                                                     BoundingBox.Min.z,
                                                                     BoundingBox.Max.z);

 Extents:=BoundingBox.Max-BoundingBox.Min;

 Scale:=TpvVector3.InlineableCreate(1.0,1.0,1.0)/Extents;

 LightViewProjectionMatrix:=LightViewMatrix*LightProjectionMatrix;

 View.ProjectionMatrix:=LightProjectionMatrix;
 View.InverseProjectionMatrix:=View.ProjectionMatrix.Inverse;

 View.ViewMatrix:=LightViewMatrix;
 View.InverseViewMatrix:=View.ViewMatrix.Inverse;

 InFlightFrameState^.ReflectiveShadowMapMatrix:=LightViewProjectionMatrix;
 InFlightFrameState^.ReflectiveShadowMapLightDirection:=fScene3D.PrimaryShadowMapLightDirections[aInFlightFrameIndex].xyz.Normalize;
 InFlightFrameState^.ReflectiveShadowMapScale:=Scale;
 InFlightFrameState^.ReflectiveShadowMapExtents:=Extents;

 InFlightFrameState^.ReflectiveShadowMapViewIndex:=fViews[aInFlightFrameIndex].Add(View);
 InFlightFrameState^.CountReflectiveShadowMapViews:=1;

end;

procedure TpvScene3DRendererInstance.AddCloudsShadowMapView(const aInFlightFrameIndex:TpvInt32);
var InFlightFrameState:PInFlightFrameState;
    Atmosphere:TpvScene3DAtmosphere;
    CloudsShadowMapData:TCloudsShadowMapData;
    OK:boolean;
    PlanetCenterRenderSpace:TpvVector3;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 InFlightFrameState:=@fInFlightFrameStates[aInFlightFrameIndex];

 OK:=false;

 TpvScene3DAtmospheres(fScene3D.Atmospheres).Lock.AcquireRead;
 try
  if TpvScene3DAtmospheres(fScene3D.Atmospheres).Count>0 then begin
   Atmosphere:=TpvScene3DAtmospheres(fScene3D.Atmospheres).Items[0];
   OK:=true;
  end;
 finally
  TpvScene3DAtmospheres(fScene3D.Atmospheres).Lock.ReleaseRead;
 end;

 if OK then begin

  InFlightFrameState^.CloudsShadowMapLightDirection:=fScene3D.PrimaryShadowMapLightDirections[aInFlightFrameIndex].xyz.Normalize;
  InFlightFrameState^.CloudsShadowMapViewIndex:=0;
  InFlightFrameState^.CountCloudsShadowMapViews:=1;

  if assigned(fCloudsShadowMapVulkanBuffers[aInFlightFrameIndex]) then begin
   // The cloud shadow map (and its octahedral lookup directions) lives in absolute planet-local space, but the
   // world positions fed into the lookup (inWorldSpacePosition in lighting.glsl, worldSpaceP in atmosphere_common.glsl)
   // are in origin-offset render space (the engine uses floating origin offsetting for very large distances, e.g.
   // when the camera/ship is far out in space). Therefore the planet center must be transformed into the same
   // origin-offset render space here, otherwise the shadow attenuation breaks once the origin offset is non-zero
   // (planet shadows vanish and distant space objects wrongly fall inside the cloud shell and receive shadows).
   PlanetCenterRenderSpace:=fScene3D.InverseOriginTransforms[aInFlightFrameIndex].MulHomogen(Atmosphere.AtmosphereParameters.Center.xyz);
   CloudsShadowMapData.PlanetCenter:=TpvVector4.InlineableCreate(PlanetCenterRenderSpace,0.0);
   CloudsShadowMapData.Params:=TpvVector4.InlineableCreate(1.0,Atmosphere.AtmosphereParameters.SunAngularRadius,Atmosphere.AtmosphereParameters.VolumetricClouds.LayerLow.StartHeight,0.0);
   CloudsShadowMapData.LightDir:=TpvVector4.InlineableCreate(InFlightFrameState^.CloudsShadowMapLightDirection.x,
                                                             InFlightFrameState^.CloudsShadowMapLightDirection.y,
                                                             InFlightFrameState^.CloudsShadowMapLightDirection.z,
                                                             0.0);
   fCloudsShadowMapVulkanBuffers[aInFlightFrameIndex].UpdateData(CloudsShadowMapData,0,SizeOf(TCloudsShadowMapData));
   fScene3D.SetCloudsShadowMapDeviceAddress(aInFlightFrameIndex,fCloudsShadowMapVulkanBuffers[aInFlightFrameIndex].DeviceAddress);
  end;

 end else begin

  InFlightFrameState^.CloudsShadowMapViewIndex:=0;
  InFlightFrameState^.CountCloudsShadowMapViews:=0;

  if assigned(fCloudsShadowMapVulkanBuffers[aInFlightFrameIndex]) then begin
   FillChar(CloudsShadowMapData,SizeOf(TCloudsShadowMapData),#0);
   fCloudsShadowMapVulkanBuffers[aInFlightFrameIndex].UpdateData(CloudsShadowMapData,0,SizeOf(TCloudsShadowMapData));
  end;
  fScene3D.SetCloudsShadowMapDeviceAddress(aInFlightFrameIndex,0);

 end;

end;

procedure TpvScene3DRendererInstance.PrepareDrawRenderInstanceFillTasksParallelForJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var TaskIndex,CountTasks,Index,Remain,ToDo,
    LowIndex,HighIndex,MidIndex,
    OffsetedIndex,InstanceIndex,FirstInstanceCommandIndex,CountIndices,
    FirstIndex,NodeIndex,BoundingSphereIndex,
    CountRenderInstances,RealToDo:TPasMPNativeInt;
    Task:PPrepareDrawRenderInstanceFillTask;
    GPUDrawIndexedIndirectCommand:TpvScene3D.PGPUDrawIndexedIndirectCommand;
    GPUDrawIndexedIndirectCommandDynamicArray:TpvScene3D.PGPUDrawIndexedIndirectCommandDynamicArray;
    GroupInstance:TpvScene3D.TGroup.TInstance;
//  GroupInstanceRenderInstance:TpvScene3D.TGroup.TInstance.TRenderInstance;
    PerInFlightFrameRenderInstances:TpvScene3D.TGroup.TInstance.PPerInFlightFrameRenderInstanceDynamicArray;
begin

 if aFromIndex<=aToIndex then begin

  CountTasks:=fPrepareDrawRenderInstanceFillTasks.Count;
  if CountTasks>0 then begin

   GPUDrawIndexedIndirectCommandDynamicArray:=@fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[fPrepareDrawRenderInstanceFillTasksInFlightFrameIndex];

   Index:=aFromIndex;

   Remain:=(aToIndex-aFromIndex)+1;

   TaskIndex:=0;

   LowIndex:=0;
   HighIndex:=CountTasks-1;
   while LowIndex<=HighIndex do begin
    MidIndex:=LowIndex+((HighIndex-LowIndex) shr 1);
    Task:=@fPrepareDrawRenderInstanceFillTasks.ItemArray[MidIndex];
    if Index<Task^.FromIndex then begin
     HighIndex:=MidIndex-1;
    end else if Index>Task^.ToIndex then begin
     LowIndex:=MidIndex+1;
    end else begin
     TaskIndex:=MidIndex;
     break;
    end;
   end;

   Task:=@fPrepareDrawRenderInstanceFillTasks.ItemArray[TaskIndex];

   while Index<=aToIndex do begin

    ToDo:=0;
    while TaskIndex<CountTasks do begin
     Task:=@fPrepareDrawRenderInstanceFillTasks.ItemArray[TaskIndex];
     if (Task^.FromIndex<=Index) and (Index<=Task^.ToIndex) then begin
      ToDo:=Min(Remain,(Min(Task^.ToIndex,aToIndex)-Index)+1);
      break;
     end else begin
      inc(TaskIndex);
     end;
    end;

    if ToDo>0 then begin

     OffsetedIndex:=Index-Task^.FromIndex;

     FirstInstanceCommandIndex:=Task^.FirstInstanceCommandIndex;
     CountIndices:=Task^.CountIndices;
     FirstIndex:=Task^.FirstIndex;
     NodeIndex:=Task^.NodeIndex;
     BoundingSphereIndex:=Task^.BoundingSphereIndex;

     GroupInstance:=TpvScene3D.TGroup.TInstance(Task^.GroupInstance);

     PerInFlightFrameRenderInstances:=@GroupInstance.PerInFlightFrameRenderInstances^[fPrepareDrawRenderInstanceFillTasksInFlightFrameIndex];

     CountRenderInstances:=PerInFlightFrameRenderInstances^.Count;

     RealToDo:=Min(ToDo,CountRenderInstances);

     if RealToDo>0 then begin
      for InstanceIndex:=OffsetedIndex to (OffsetedIndex+RealToDo)-1 do begin
       GPUDrawIndexedIndirectCommand:=@GPUDrawIndexedIndirectCommandDynamicArray^.ItemArray[FirstInstanceCommandIndex+InstanceIndex];
       GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.indexCount:=CountIndices;
       GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.instanceCount:=1;
       GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.firstIndex:=FirstIndex;
       GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.vertexOffset:=0;
       GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.firstInstance:=TpvScene3D.TGroup.TInstance.TRenderInstance(PerInFlightFrameRenderInstances^.Items[InstanceIndex].RenderInstance).NodeMeshObjectIDs[NodeIndex];
       GPUDrawIndexedIndirectCommand^.BoundingSphereIndex:=BoundingSphereIndex;
       GPUDrawIndexedIndirectCommand^.LODInfoIndex:=Task^.LODInfoIndex;
       GPUDrawIndexedIndirectCommand^.Flags:=Task^.CommandFlags;
      end;
     end;

     if RealToDo<ToDo then begin
      for InstanceIndex:=OffsetedIndex+RealToDo to (OffsetedIndex+ToDo)-1 do begin
       GPUDrawIndexedIndirectCommand:=@GPUDrawIndexedIndirectCommandDynamicArray^.ItemArray[FirstInstanceCommandIndex+InstanceIndex];
       GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.indexCount:=0;
       GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.instanceCount:=0;
       GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.firstIndex:=0;
       GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.vertexOffset:=0;
       GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.firstInstance:=0;
       GPUDrawIndexedIndirectCommand^.BoundingSphereIndex:=0;
       GPUDrawIndexedIndirectCommand^.LODInfoIndex:=TpvUInt32($ffffffff);
       GPUDrawIndexedIndirectCommand^.Flags:=0;
      end;
     end;

     inc(Index,ToDo);
     dec(Remain,ToDo);

    end else begin

     break;

    end;

   end;

  end;

 end;

end;

function TpvScene3DRendererInstance.NeedsDrawDataRebuild(const aInFlightFrameIndex:TpvSizeInt):boolean;
begin
 if aInFlightFrameIndex<0 then begin
  result:=false;
 end else begin
  result:=fCachedDrawDataGeneration[aInFlightFrameIndex]<>fSnapshotDrawDataGeneration[aInFlightFrameIndex];
 end;
end;

procedure TpvScene3DRendererInstance.PrepareDraw(const aInFlightFrameIndex:TpvSizeInt;
                                                 const aRenderPass:TpvScene3DRendererRenderPass);
var DrawChoreographyBatchItemIndex,DrawChoreographyBatchRangeIndex,InstanceIndex,NodeIndex,
    CountInstances,FirstCommand,CountCommands,FirstInstanceCommandIndex,Count,
    TotalCount,TaskIndex,CountTotalRenderInstances:TpvSizeInt;
    MaterialAlphaMode:TpvScene3D.TMaterial.TAlphaMode;
    PrimitiveTopology:TpvScene3D.TPrimitiveTopology;
    FaceCullingMode:TpvScene3D.TFaceCullingMode;
    DrawChoreographyBatchItems:TpvScene3D.TDrawChoreographyBatchItems;
    DrawChoreographyBatchItem:TpvScene3D.TDrawChoreographyBatchItem;
    GPUDrawIndexedIndirectCommandDynamicArray:TpvScene3D.PGPUDrawIndexedIndirectCommandDynamicArray;
    DrawChoreographyBatchRangeDynamicArray:TpvScene3D.PDrawChoreographyBatchRangeDynamicArray;
    DrawChoreographyBatchRangeIndexDynamicArray:TpvScene3D.PDrawChoreographyBatchRangeIndexDynamicArray;
    DrawChoreographyBatchRangeItem:TpvScene3D.PDrawChoreographyBatchRange;
    GPUDrawIndexedIndirectCommand:TpvScene3D.PGPUDrawIndexedIndirectCommand;
    GroupInstance:TpvScene3D.TGroup.TInstance;
    BoundingSphereIndex:TpvUInt32;
    Task:PPrepareDrawRenderInstanceFillTask;
{$ifdef FrameTextFileDebug}
    DebugFile:TextFile;
    DebugCmdIndex:TpvSizeInt;
    DebugCmd:TpvScene3D.PGPUDrawIndexedIndirectCommand;
    DebugDrawInfo:TpvScene3D.PGPUDrawInfo;
    DebugDrawInfoArray:TpvScene3D.PGlobalVulkanDrawInfoDynamicArray;
    DebugBatchRange:TpvScene3D.PDrawChoreographyBatchRange;
    DebugFile2:TextFile;
    DebugFile2Open:boolean;
{$endif}
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

{$ifdef FrameTextFileDebug}
 // Auto one-shot draw-command dump on an early View-pass frame (no keypress needed -- the F1
 // keybind path is fragile: Ctrl+Alt+F1 = Linux VT switch, other F1 handlers may consume it, and
 // it needs a Pascal rebuild). The obj->identity mapping is frame-stable, so an early frame's
 // command list suffices to attribute the HIZDROP obj IDs. Writes drawinfo_dump_iff*_rp*_n*.txt
 // (+ drawbatch_dump_*) to the CWD (the bin/ dir, next to outx*.txt).
 if (not DebugAutoDumpDone) and (aRenderPass=TpvScene3DRendererRenderPass.View) then begin
  inc(DebugAutoDumpFrameCounter);
  if DebugAutoDumpFrameCounter>=2 then begin
   fScene3D.DebugDumpDrawInfo:=true;
   DebugAutoDumpDone:=true;
  end;
 end;
{$endif}

 if fCachedDrawDataGeneration[aInFlightFrameIndex]<>fSnapshotDrawDataGeneration[aInFlightFrameIndex] then begin

  //WriteLn('[DEBUG] PrepareDraw IFF=',aInFlightFrameIndex,' RenderPass=',ord(aRenderPass),' REBUILD');

  fPrepareDrawRenderInstanceFillTasksInFlightFrameIndex:=aInFlightFrameIndex;

  GPUDrawIndexedIndirectCommandDynamicArray:=@fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex];

  DrawChoreographyBatchRangeDynamicArray:=@fDrawChoreographyBatchRangeFrameBuckets[aInFlightFrameIndex];

  DrawChoreographyBatchRangeIndexDynamicArray:=@fDrawChoreographyBatchRangeFrameRenderPassBuckets[aInFlightFrameIndex,aRenderPass];

  fPrepareDrawRenderInstanceFillTasks.Count:=0;

  Count:=0;

  TotalCount:=0;

  CountTotalRenderInstances:=0;

{$ifdef FrameTextFileDebug}
  // DEBUG: Open batch item context file if triggered
  DebugFile2Open:=false;
  if fScene3D.DebugDumpDrawInfo then begin
   DebugFile2Open:=true;
   inc(DebugDrawInfoDumpCounter);
   AssignFile(DebugFile2,'drawbatch_dump_iff'+IntToStr(aInFlightFrameIndex)+'_rp'+IntToStr(ord(aRenderPass))+'_n'+IntToStr(DebugDrawInfoDumpCounter)+'.txt');
   Rewrite(DebugFile2);
   WriteLn(DebugFile2,'=== DrawChoreographyBatchItem Context Dump ===');
   WriteLn(DebugFile2,'InFlightFrame=',aInFlightFrameIndex,' RenderPass=',ord(aRenderPass));
   WriteLn(DebugFile2,'');
  end;
{$endif}

  for MaterialAlphaMode:=Low(TpvScene3D.TMaterial.TAlphaMode) to High(TpvScene3D.TMaterial.TAlphaMode) do begin

   for PrimitiveTopology:=Low(TpvScene3D.TPrimitiveTopology) to High(TpvScene3D.TPrimitiveTopology) do begin

    for FaceCullingMode:=Low(TpvScene3D.TFaceCullingMode) to High(TpvScene3D.TFaceCullingMode) do begin

     DrawChoreographyBatchItems:=fDrawChoreographyBatchItemFrameBuckets[aInFlightFrameIndex,
                                                                        aRenderPass,
                                                                        MaterialAlphaMode,
                                                                        PrimitiveTopology,
                                                                        FaceCullingMode];

     if DrawChoreographyBatchItems.Count>0 then begin

      FirstCommand:=GPUDrawIndexedIndirectCommandDynamicArray^.Count;

      for DrawChoreographyBatchItemIndex:=0 to DrawChoreographyBatchItems.Count-1 do begin

       DrawChoreographyBatchItem:=DrawChoreographyBatchItems[DrawChoreographyBatchItemIndex];
       if (DrawChoreographyBatchItem.CountIndices>0) and assigned(DrawChoreographyBatchItem.Node) then begin

        inc(Count);

        CountInstances:=TpvScene3D.TGroup.TInstance(DrawChoreographyBatchItem.GroupInstance).fVulkanPerInFlightFrameInstancesCounts[aInFlightFrameIndex,fID];

{$ifdef FrameTextFileDebug}
        // DEBUG: Dump batch item context
        if DebugFile2Open then begin
         WriteLn(DebugFile2,'BatchItem[',Count-1,'] Group="',DrawChoreographyBatchItem.Group.Name,
                 '" Material="',DrawChoreographyBatchItem.Material.Name,
                 '" NodeIdx=',TpvScene3D.TGroup.TNode(DrawChoreographyBatchItem.Node).Index,
                 ' AlphaMode=',ord(DrawChoreographyBatchItem.AlphaMode),
                 ' MeshObjID=',DrawChoreographyBatchItem.MeshObjectID,
                 ' StartIdx=',DrawChoreographyBatchItem.StartIndex,
                 ' CountIdx=',DrawChoreographyBatchItem.CountIndices,
                 ' LODInfoIdx=',DrawChoreographyBatchItem.LODInfoIndex,
                 ' UseRI=',TpvScene3D.TGroup.TInstance(DrawChoreographyBatchItem.GroupInstance).UseRenderInstances,
                 ' CountInstances=',CountInstances,
                 ' CmdArrayPos=',GPUDrawIndexedIndirectCommandDynamicArray^.Count);
        end;
{$endif}

        if CountInstances>0 then begin

         NodeIndex:=TpvScene3D.TGroup.TNode(DrawChoreographyBatchItem.Node).Index;

         BoundingSphereIndex:=TpvScene3D.TGroup.TInstance(DrawChoreographyBatchItem.GroupInstance).Nodes[NodeIndex].BoundingSphereIndex;

         if TpvScene3D.TGroup.TInstance(DrawChoreographyBatchItem.GroupInstance).UseRenderInstances then begin

          GroupInstance:=TpvScene3D.TGroup.TInstance(DrawChoreographyBatchItem.GroupInstance);

          FirstInstanceCommandIndex:=GPUDrawIndexedIndirectCommandDynamicArray^.Count;
          GPUDrawIndexedIndirectCommandDynamicArray^.SetCount(FirstInstanceCommandIndex+CountInstances);

          // Record task for parallel fill
          TaskIndex:=fPrepareDrawRenderInstanceFillTasks.AddNewIndex;
          Task:=@fPrepareDrawRenderInstanceFillTasks.ItemArray[TaskIndex];
          Task^.FromIndex:=CountTotalRenderInstances;
          Task^.ToIndex:=(CountTotalRenderInstances+CountInstances)-1;
          Task^.FirstInstanceCommandIndex:=FirstInstanceCommandIndex;
          Task^.CountInstances:=CountInstances;
          Task^.NodeIndex:=NodeIndex;
          Task^.CountIndices:=DrawChoreographyBatchItem.CountIndices;
          Task^.FirstIndex:=DrawChoreographyBatchItem.StartIndex;
          Task^.BoundingSphereIndex:=BoundingSphereIndex;
          Task^.LODInfoIndex:=DrawChoreographyBatchItem.LODInfoIndex;
          Task^.CommandFlags:=0;
          if DrawChoreographyBatchItem.Material.Data^.CastingShadows then begin
           Task^.CommandFlags:=Task^.CommandFlags or TpvScene3D.DrawCmdFlagMaterialCastsShadow;
          end;
          Task^.GroupInstance:=GroupInstance;

          inc(CountTotalRenderInstances,CountInstances);

         end else begin

          GPUDrawIndexedIndirectCommand:=Pointer(GPUDrawIndexedIndirectCommandDynamicArray^.AddNew);
          GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.indexCount:=DrawChoreographyBatchItem.CountIndices;
          GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.instanceCount:=1;
          GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.firstIndex:=DrawChoreographyBatchItem.StartIndex;
          GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.vertexOffset:=0;
          GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.firstInstance:=DrawChoreographyBatchItem.MeshObjectID;
          GPUDrawIndexedIndirectCommand^.BoundingSphereIndex:=BoundingSphereIndex;
          GPUDrawIndexedIndirectCommand^.LODInfoIndex:=DrawChoreographyBatchItem.LODInfoIndex;
          GPUDrawIndexedIndirectCommand^.Flags:=0;
          if DrawChoreographyBatchItem.Material.Data^.CastingShadows then begin
           GPUDrawIndexedIndirectCommand^.Flags:=GPUDrawIndexedIndirectCommand^.Flags or TpvScene3D.DrawCmdFlagMaterialCastsShadow;
          end;
 //       GPUDrawIndexedIndirectCommand^.InstanceDataIndex:=0;

         end;

        end;

       end;

      end;

      CountCommands:=GPUDrawIndexedIndirectCommandDynamicArray^.Count-FirstCommand;

      if CountCommands>0 then begin

       inc(TotalCount,CountCommands);

       DrawChoreographyBatchRangeIndex:=DrawChoreographyBatchRangeDynamicArray^.AddNewIndex;
       try
        DrawChoreographyBatchRangeItem:=@DrawChoreographyBatchRangeDynamicArray.Items[DrawChoreographyBatchRangeIndex];
        DrawChoreographyBatchRangeItem^.AlphaMode:=MaterialAlphaMode;
        DrawChoreographyBatchRangeItem^.PrimitiveTopology:=PrimitiveTopology;
        DrawChoreographyBatchRangeItem^.FaceCullingMode:=FaceCullingMode;
        DrawChoreographyBatchRangeItem^.DrawCallIndex:=DrawChoreographyBatchRangeIndex;
        DrawChoreographyBatchRangeItem^.FirstCommand:=FirstCommand;
        DrawChoreographyBatchRangeItem^.CountCommands:=CountCommands;
       finally
        DrawChoreographyBatchRangeIndexDynamicArray^.Add(DrawChoreographyBatchRangeIndex);
       end;

      end;

     end;

    end;

   end;

  end;

  // Close debug batch item file
{$ifdef FrameTextFileDebug}
  if DebugFile2Open then begin
   CloseFile(DebugFile2);
  end;
{$endif}

  // Fill render instance tasks
  if CountTotalRenderInstances>0 then begin
   if CountTotalRenderInstances>128 then begin
    fScene3D.PasMPInstance.Invoke(
     fScene3D.PasMPInstance.ParallelFor(
      nil,
      0,
      CountTotalRenderInstances-1,
      PrepareDrawRenderInstanceFillTasksParallelForJobFunction,
      -4,
      PasMPDefaultDepth,
      nil,
      0,
      PasMPAreaMaskUpdate,
      PasMPAreaMaskRender,
      false,
      PasMPAffinityMaskUpdateAllowMask,
      PasMPAffinityMaskUpdateAvoidMask
     )
    );
   end else begin
    PrepareDrawRenderInstanceFillTasksParallelForJobFunction(nil,0,nil,0,CountTotalRenderInstances-1);
   end;
  end;

  //writeln('PrepareDraw Count: ',Count,' - Total Count: ',TotalCount);

{$ifdef FrameTextFileDebug}
  // DEBUG DUMP: Write all commands + DrawInfo to text file when triggered
  if fScene3D.DebugDumpDrawInfo then begin
   AssignFile(DebugFile,'drawinfo_dump_iff'+IntToStr(aInFlightFrameIndex)+'_rp'+IntToStr(ord(aRenderPass))+'_n'+IntToStr(DebugDrawInfoDumpCounter)+'.txt');
   Rewrite(DebugFile);
   WriteLn(DebugFile,'=== PrepareDraw Dump ===');
   WriteLn(DebugFile,'InFlightFrame=',aInFlightFrameIndex,' RenderPass=',ord(aRenderPass));
   WriteLn(DebugFile,'TotalCommands=',GPUDrawIndexedIndirectCommandDynamicArray^.Count,' TotalBatchRanges=',DrawChoreographyBatchRangeIndexDynamicArray^.Count);
   WriteLn(DebugFile,'');
   // Dump batch ranges
   WriteLn(DebugFile,'--- BatchRanges ---');
   for DebugCmdIndex:=0 to DrawChoreographyBatchRangeIndexDynamicArray^.Count-1 do begin
    DebugBatchRange:=@DrawChoreographyBatchRangeDynamicArray^.ItemArray[DrawChoreographyBatchRangeIndexDynamicArray^.ItemArray[DebugCmdIndex]];
    WriteLn(DebugFile,'  Range[',DebugCmdIndex,'] AlphaMode=',ord(DebugBatchRange^.AlphaMode),
            ' PrimTopo=',ord(DebugBatchRange^.PrimitiveTopology),
            ' FaceCull=',ord(DebugBatchRange^.FaceCullingMode),
            ' DrawCallIdx=',DebugBatchRange^.DrawCallIndex,
            ' FirstCmd=',DebugBatchRange^.FirstCommand,
            ' CountCmds=',DebugBatchRange^.CountCommands);
   end;
   WriteLn(DebugFile,'');
   // Dump all commands + DrawInfo lookup
   WriteLn(DebugFile,'--- Commands ---');
   DebugDrawInfoArray:=@fScene3D.GlobalVulkanDrawInfoDynamicArrays[aInFlightFrameIndex];
   for DebugCmdIndex:=0 to GPUDrawIndexedIndirectCommandDynamicArray^.Count-1 do begin
    DebugCmd:=@GPUDrawIndexedIndirectCommandDynamicArray^.ItemArray[DebugCmdIndex];
    WriteLn(DebugFile,'  Cmd[',DebugCmdIndex,'] firstIndex=',DebugCmd^.DrawIndexedIndirectCommand.firstIndex,
            ' indexCount=',DebugCmd^.DrawIndexedIndirectCommand.indexCount,
            ' vertexOffset=',DebugCmd^.DrawIndexedIndirectCommand.vertexOffset,
            ' firstInstance(MeshObjID)=',DebugCmd^.DrawIndexedIndirectCommand.firstInstance,
            ' instanceCount=',DebugCmd^.DrawIndexedIndirectCommand.instanceCount,
            ' BoundingSphereIdx=',DebugCmd^.BoundingSphereIndex,
            ' LODInfoIdx=',DebugCmd^.LODInfoIndex,
            ' Flags=',DebugCmd^.Flags);
    // DrawInfo lookup by MeshObjectID (=firstInstance)
    if (DebugCmd^.DrawIndexedIndirectCommand.firstInstance>0) and
       (TpvSizeInt(DebugCmd^.DrawIndexedIndirectCommand.firstInstance)<DebugDrawInfoArray^.Count) then begin
     DebugDrawInfo:=@DebugDrawInfoArray^.ItemArray[DebugCmd^.DrawIndexedIndirectCommand.firstInstance];
     WriteLn(DebugFile,'    DrawInfo: MatrixID=',DebugDrawInfo^.MatrixID,
             ' InstDataIdx=',DebugDrawInfo^.InstanceDataIndex,
             ' MeshObjID=',DebugDrawInfo^.MeshObjectID,
             ' Flags(RPMask)=',DebugDrawInfo^.Flags,
             ' NodeMatricesIdx=',DebugDrawInfo^.NodeMatricesIndex);
    end else begin
     WriteLn(DebugFile,'    DrawInfo: N/A (MeshObjID=',DebugCmd^.DrawIndexedIndirectCommand.firstInstance,' out of range ',DebugDrawInfoArray^.Count,')');
    end;
   end;
   CloseFile(DebugFile);
   WriteLn('[DEBUG] Dumped ',GPUDrawIndexedIndirectCommandDynamicArray^.Count,' commands to drawinfo_dump_iff',aInFlightFrameIndex,'_rp',ord(aRenderPass),'_n',DebugDrawInfoDumpCounter,'.txt');
   // Reset trigger after last RenderPass dump
   fScene3D.DebugDumpDrawInfo:=false;
  end;
{$endif}

 end;

end;

procedure TpvScene3DRendererInstance.ExecuteDraw(const aPreviousInFlightFrameIndex:TpvSizeInt;
                                                 const aInFlightFrameIndex:TpvSizeInt;
                                                 const aRenderPass:TpvScene3DRendererRenderPass;
                                                 const aViewBaseIndex:TpvSizeInt;
                                                 const aCountViews:TpvSizeInt;
                                                 const aFrameIndex:TpvSizeInt;
                                                 const aMaterialAlphaModes:TpvScene3D.TMaterial.TAlphaModes;
                                                 const aGraphicsPipelines:TpvScene3D.TGraphicsPipelines;
                                                 const aCommandBuffer:TpvVulkanCommandBuffer;
                                                 const aPipelineLayout:TpvVulkanPipelineLayout;
                                                 const aOnSetRenderPassResources:TpvScene3D.TOnSetRenderPassResources;
                                                 const aJitter:PpvVector4;
                                                 const aDisocclusions:boolean;
                                                 const aOITPromotion:boolean;
                                                 const aMeshShaderGraphicsPipelines:TpvScene3D.PGraphicsPipelines);
var DrawChoreographyBatchRangeIndex,PerInFlightFrameBufferIndex:TpvSizeInt;
    Pipeline,NewPipeline:TpvVulkanPipeline;
    First,GPUCulling,UseMeshShaderDraw,UseMeshShaderForRange:boolean;
    MeshStagePushConstants:TpvScene3D.PMeshStagePushConstants;
    DrawChoreographyBatchRangeDynamicArray:TpvScene3D.PDrawChoreographyBatchRangeDynamicArray;
    DrawChoreographyBatchRangeIndexDynamicArray:TpvScene3D.PDrawChoreographyBatchRangeIndexDynamicArray;
    DrawChoreographyBatchRange:TpvScene3D.PDrawChoreographyBatchRange;
    vkCmdDrawIndexedIndirectCount:TvkCmdDrawIndexedIndirectCount;
    vkCmdDrawMeshTasksIndirectCountEXT:TvkCmdDrawMeshTasksIndirectCountEXT;
    OutputBufferDeviceAddress,AdjustedBDA:TVkDeviceAddress;
    MeshShaderPushConstantStageFlags:TVkShaderStageFlags;
    MaxOutputCommands:TpvSizeInt;
    CullRenderPassCounterSlotBase,CullRenderPassOutputCommandBase,CullRenderPassDisocclusionOutputCommandBase:TpvSizeInt;
    Time:TpvDouble;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 if fScene3D.UsePerInFlightFrameResources then begin
  PerInFlightFrameBufferIndex:=aInFlightFrameIndex;
 end else begin
  PerInFlightFrameBufferIndex:=0;
 end;

 if (aViewBaseIndex>=0) and (aCountViews>0) then begin

  Time:=fScene3D.SceneTimes^[aInFlightFrameIndex];

  MeshStagePushConstants:=@fMeshStagePushConstants[aRenderPass];
  MeshStagePushConstants^.ViewBaseIndex:=aViewBaseIndex;
  MeshStagePushConstants^.CountViews:=aCountViews;
  MeshStagePushConstants^.CountAllViews:=fViews[aInFlightFrameIndex].Count;
  MeshStagePushConstants^.FrameIndex:=aFrameIndex;
  if assigned(aJitter) and (Renderer.AntialiasingMode<>TpvScene3DRendererAntialiasingMode.SMAAT2x) then begin
   MeshStagePushConstants^.Jitter:=aJitter^;
  end else begin
   MeshStagePushConstants^.Jitter:=TpvVector4.Null;
  end;
  MeshStagePushConstants^.TimeSeconds:=floor(Time);
  MeshStagePushConstants^.TimeFractionalSecond:=frac(Time);
  MeshStagePushConstants^.Width:=fScaledWidth;
  MeshStagePushConstants^.Height:=fScaledHeight;
  MeshStagePushConstants^.RaytracingFlags:=fRawRaytracingFlags;
  MeshStagePushConstants^.DrawFlags:=0;
  if fDrawMeshletDebugColors then begin
   MeshStagePushConstants^.DrawFlags:=MeshStagePushConstants^.DrawFlags or 1;
  end;
  if Renderer.UseMeshletCulling and not (aRenderPass in [TpvScene3DRendererRenderPass.ReflectiveShadowMap,TpvScene3DRendererRenderPass.Voxelization,TpvScene3DRendererRenderPass.TopDownSkyOcclusionMap,TpvScene3DRendererRenderPass.ReflectionProbe]) then begin
   MeshStagePushConstants^.DrawFlags:=MeshStagePushConstants^.DrawFlags or (TpvUInt32(1) shl 3); // FLAG_MESHLET_CULLING_ENABLED
  end;
  if fZFar<0.0 then begin
   MeshStagePushConstants^.DrawFlags:=MeshStagePushConstants^.DrawFlags or (TpvUInt32(1) shl 4); // FLAG_REVERSED_Z
  end;
  MeshStagePushConstants^.TextureDepthIndex:=0;
  case aRenderPass of
   TpvScene3DRendererRenderPass.View:begin
    MeshStagePushConstants^.MaximumDistance:=fFinalViewMaximumDistance;
    MeshStagePushConstants^.AreaTooSmallThreshold:=fFinalViewAreaTooSmallThreshold;
   end;
   TpvScene3DRendererRenderPass.CascadedShadowMap:begin
    MeshStagePushConstants^.MaximumDistance:=fShadowMaximumDistance;
    MeshStagePushConstants^.AreaTooSmallThreshold:=fShadowAreaTooSmallThreshold;
   end;
   else begin
    MeshStagePushConstants^.MaximumDistance:=-1.0;
    MeshStagePushConstants^.AreaTooSmallThreshold:=-1.0;
   end;
  end;

  fSetGlobalResourcesDone[aRenderPass]:=false;

  Pipeline:=nil;

  First:=true;

  GPUCulling:=true;

  case aRenderPass of
   TpvScene3DRendererRenderPass.CascadedShadowMap:begin
    CullRenderPassCounterSlotBase:=fPassGroupCounterSlotBase[TpvScene3DRendererCullRenderPass.CascadedShadowMap];
    CullRenderPassOutputCommandBase:=fPerInFlightFrameGPUDrawIndexedIndirectCommandCSMOffsets[aInFlightFrameIndex];
    CullRenderPassDisocclusionOutputCommandBase:=fPerInFlightFrameGPUDrawIndexedIndirectCommandCSMDisocclusionOffsets[aInFlightFrameIndex];
   end;
   TpvScene3DRendererRenderPass.Voxelization,
   TpvScene3DRendererRenderPass.ReflectionProbe,
   TpvScene3DRendererRenderPass.TopDownSkyOcclusionMap,
   TpvScene3DRendererRenderPass.ReflectiveShadowMap:begin
    CullRenderPassCounterSlotBase:=fPassGroupCounterSlotBase[TpvScene3DRendererCullRenderPass.Voxelization];
    CullRenderPassOutputCommandBase:=fPerInFlightFrameGPUDrawIndexedIndirectCommandFilterOffsets[aInFlightFrameIndex];
    CullRenderPassDisocclusionOutputCommandBase:=0;
   end;
   else begin
    CullRenderPassCounterSlotBase:=0;
    CullRenderPassOutputCommandBase:=0;
    CullRenderPassDisocclusionOutputCommandBase:=fPerInFlightFrameGPUDrawIndexedIndirectCommandDisocclusionOffsets[aInFlightFrameIndex];
   end;
  end;

  if GPUCulling then begin
   if assigned(Renderer.VulkanDevice.Commands.Commands.CmdDrawIndexedIndirectCount) then begin
    vkCmdDrawIndexedIndirectCount:=Renderer.VulkanDevice.Commands.Commands.CmdDrawIndexedIndirectCount;
   end else if assigned(Renderer.VulkanDevice.Commands.Commands.CmdDrawIndexedIndirectCountKHR) then begin
    vkCmdDrawIndexedIndirectCount:=addr(Renderer.VulkanDevice.Commands.Commands.CmdDrawIndexedIndirectCountKHR);
   end else begin
    vkCmdDrawIndexedIndirectCount:=nil;
   end;
  end else begin
   vkCmdDrawIndexedIndirectCount:=nil;
  end;

  if GPUCulling and
     Renderer.Scene3D.MeshShaders and
     assigned(aMeshShaderGraphicsPipelines) and
     assigned(Renderer.VulkanDevice.Commands.Commands.CmdDrawMeshTasksIndirectCountEXT) then begin
   vkCmdDrawMeshTasksIndirectCountEXT:=Renderer.VulkanDevice.Commands.Commands.CmdDrawMeshTasksIndirectCountEXT;
   OutputBufferDeviceAddress:=fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].DeviceAddress;
   MeshStagePushConstants^.MeshDrawCommandsBDA:=OutputBufferDeviceAddress;
   MeshShaderPushConstantStageFlags:=TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or
                                     TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT) or
                                     TVkShaderStageFlags(VK_SHADER_STAGE_TASK_BIT_EXT) or
                                     TVkShaderStageFlags(VK_SHADER_STAGE_MESH_BIT_EXT);
   UseMeshShaderDraw:=true;
   MaxOutputCommands:=fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex];
  end else begin
   vkCmdDrawMeshTasksIndirectCountEXT:=nil;
   OutputBufferDeviceAddress:=0;
   MeshStagePushConstants^.MeshDrawCommandsBDA:=0;
   MeshShaderPushConstantStageFlags:=0;
   UseMeshShaderDraw:=false;
   MaxOutputCommands:=0;
  end;

  DrawChoreographyBatchRangeDynamicArray:=@fDrawChoreographyBatchRangeFrameBuckets[aInFlightFrameIndex];

  DrawChoreographyBatchRangeIndexDynamicArray:=@fDrawChoreographyBatchRangeFrameRenderPassBuckets[aInFlightFrameIndex,aRenderPass];

{$ifdef MeshShaderDebug}
  WriteLn('[DEBUG-MS] ExecuteDraw IFF=',aInFlightFrameIndex,' RP=',ord(aRenderPass),' Ranges=',DrawChoreographyBatchRangeIndexDynamicArray^.Count,' UseMeshShader=',UseMeshShaderDraw,' GPUCull=',GPUCulling,' Disoccl=',aDisocclusions,' OIT=',aOITPromotion);
{$endif}

  for DrawChoreographyBatchRangeIndex:=0 to DrawChoreographyBatchRangeIndexDynamicArray^.Count-1 do begin

   DrawChoreographyBatchRange:=@DrawChoreographyBatchRangeDynamicArray^.Items[DrawChoreographyBatchRangeIndexDynamicArray^.Items[DrawChoreographyBatchRangeIndex]];

   if (DrawChoreographyBatchRange^.CountCommands>0) and
      (DrawChoreographyBatchRange.AlphaMode in aMaterialAlphaModes) then begin

{$ifdef MeshShaderDebug}
     WriteLn('[DEBUG-MS] ExecuteDraw Range[',DrawChoreographyBatchRangeIndex,'] RP=',ord(aRenderPass),' AlphaMode=',ord(DrawChoreographyBatchRange^.AlphaMode),' Cmds=',DrawChoreographyBatchRange^.CountCommands,' UseMeshShader=',UseMeshShaderDraw);
{$endif}

    UseMeshShaderForRange:=UseMeshShaderDraw;
    if UseMeshShaderDraw then begin
     NewPipeline:=aMeshShaderGraphicsPipelines^[DrawChoreographyBatchRange^.PrimitiveTopology,
                                                 DrawChoreographyBatchRange^.FaceCullingMode];
     if not assigned(NewPipeline) then begin
      // The mesh-shader pipelines are triangle-only (meshlets can only express triangles). For non-triangle topologies
      // (glTF POINTS/LINES) fall back to the vertex pipeline for this range so they keep rendering instead of being skipped.
      NewPipeline:=aGraphicsPipelines[DrawChoreographyBatchRange^.PrimitiveTopology,
                                      DrawChoreographyBatchRange^.FaceCullingMode];
      UseMeshShaderForRange:=false;
     end;
    end else begin
     NewPipeline:=aGraphicsPipelines[DrawChoreographyBatchRange^.PrimitiveTopology,
                                     DrawChoreographyBatchRange^.FaceCullingMode];
    end;
    if not assigned(NewPipeline) then begin
{$ifdef MeshShaderDebug}
     WriteLn('[DEBUG-MS] SKIP: Pipeline nil for Topo=',ord(DrawChoreographyBatchRange^.PrimitiveTopology),' CullMode=',ord(DrawChoreographyBatchRange^.FaceCullingMode));
{$endif}
     continue;
    end;

    if Pipeline<>NewPipeline then begin
     Pipeline:=NewPipeline;
     if assigned(Pipeline) then begin
      aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,Pipeline.Handle);
     end;
    end;

    if assigned(Pipeline) then begin

     if First then begin

      First:=false;

      fScene3D.SetGlobalResources(aCommandBuffer,aPipelineLayout,self,aRenderPass,aPreviousInFlightFrameIndex,aInFlightFrameIndex);

      if assigned(aOnSetRenderPassResources) then begin
       aOnSetRenderPassResources(aCommandBuffer,aPipelineLayout,self,aRenderPass,aPreviousInFlightFrameIndex,aInFlightFrameIndex);
      end;

     end;

     if UseMeshShaderForRange then begin

      if aDisocclusions then begin

       if aOITPromotion then begin

        if Renderer.UseMeshletExpand then begin
         AdjustedBDA:=OutputBufferDeviceAddress+(TVkDeviceSize(fExpandRangeInfos[(TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls*3)+DrawChoreographyBatchRange^.DrawCallIndex].OutputBase)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         MeshStagePushConstants^.MeshDrawCommandsBDA:=AdjustedBDA;
         aCommandBuffer.CmdPushConstants(aPipelineLayout.Handle,MeshShaderPushConstantStageFlags,0,SizeOf(TpvScene3D.TMeshStagePushConstants),MeshStagePushConstants);
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirectCount,'MeshShaderDrawOITPromotionDisocclusion');
         end;
         vkCmdDrawMeshTasksIndirectCountEXT(aCommandBuffer.Handle,
                                            fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,
                                            TVkDeviceSize(fExpandRangeInfos[(TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls*3)+DrawChoreographyBatchRange^.DrawCallIndex].OutputBase)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand),
                                            fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].Handle,
                                            ((TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls*3)+DrawChoreographyBatchRange^.DrawCallIndex)*SizeOf(TpvUInt32),
                                            fExpandRangeInfos[(TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls*3)+DrawChoreographyBatchRange^.DrawCallIndex].OutputCapacity,
                                            SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
         end;
        end else begin
         AdjustedBDA:=OutputBufferDeviceAddress+(TVkDeviceSize(fPerInFlightFrameGPUDrawIndexedIndirectCommandOITDisocclusionOffsets[aInFlightFrameIndex]+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         MeshStagePushConstants^.MeshDrawCommandsBDA:=AdjustedBDA;
         aCommandBuffer.CmdPushConstants(aPipelineLayout.Handle,MeshShaderPushConstantStageFlags,0,SizeOf(TpvScene3D.TMeshStagePushConstants),MeshStagePushConstants);
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirectCount,'MeshShaderDrawOITPromotionDisocclusion');
         end;
         vkCmdDrawMeshTasksIndirectCountEXT(aCommandBuffer.Handle,
                                            fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,
                                            (fPerInFlightFrameGPUDrawIndexedIndirectCommandOITDisocclusionOffsets[aInFlightFrameIndex]+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand),
                                            fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].Handle,
                                            ((TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls*3)+DrawChoreographyBatchRange^.DrawCallIndex)*SizeOf(TpvUInt32),
                                            DrawChoreographyBatchRange^.CountCommands,
                                            SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
         end;
        end;

       end else begin

        if Renderer.UseMeshletExpand then begin
         AdjustedBDA:=OutputBufferDeviceAddress+(TVkDeviceSize(fExpandRangeInfos[CullRenderPassCounterSlotBase+TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls+DrawChoreographyBatchRange^.DrawCallIndex].OutputBase)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         MeshStagePushConstants^.MeshDrawCommandsBDA:=AdjustedBDA;
         aCommandBuffer.CmdPushConstants(aPipelineLayout.Handle,MeshShaderPushConstantStageFlags,0,SizeOf(TpvScene3D.TMeshStagePushConstants),MeshStagePushConstants);
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirectCount,'MeshShaderDrawDisocclusion');
         end;
         vkCmdDrawMeshTasksIndirectCountEXT(aCommandBuffer.Handle,
                                            fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,
                                            TVkDeviceSize(fExpandRangeInfos[CullRenderPassCounterSlotBase+TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls+DrawChoreographyBatchRange^.DrawCallIndex].OutputBase)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand),
                                            fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].Handle,
                                            (CullRenderPassCounterSlotBase+TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls+DrawChoreographyBatchRange^.DrawCallIndex)*SizeOf(TpvUInt32),
                                            fExpandRangeInfos[CullRenderPassCounterSlotBase+TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls+DrawChoreographyBatchRange^.DrawCallIndex].OutputCapacity,
                                            SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
         end;
        end else begin
         AdjustedBDA:=OutputBufferDeviceAddress+(TVkDeviceSize(CullRenderPassDisocclusionOutputCommandBase+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         MeshStagePushConstants^.MeshDrawCommandsBDA:=AdjustedBDA;
         aCommandBuffer.CmdPushConstants(aPipelineLayout.Handle,MeshShaderPushConstantStageFlags,0,SizeOf(TpvScene3D.TMeshStagePushConstants),MeshStagePushConstants);
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirectCount,'MeshShaderDrawDisocclusion');
         end;
         vkCmdDrawMeshTasksIndirectCountEXT(aCommandBuffer.Handle,
                                            fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,
                                            (CullRenderPassDisocclusionOutputCommandBase+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand),
                                            fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].Handle,
                                            (CullRenderPassCounterSlotBase+TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls+DrawChoreographyBatchRange^.DrawCallIndex)*SizeOf(TpvUInt32),
                                            DrawChoreographyBatchRange^.CountCommands,
                                            SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
         end;
        end;

       end;

      end else begin

       if aOITPromotion then begin

        if Renderer.UseMeshletExpand then begin
         AdjustedBDA:=OutputBufferDeviceAddress+(TVkDeviceSize(fExpandRangeInfos[(TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls*2)+DrawChoreographyBatchRange^.DrawCallIndex].OutputBase)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         MeshStagePushConstants^.MeshDrawCommandsBDA:=AdjustedBDA;
         aCommandBuffer.CmdPushConstants(aPipelineLayout.Handle,MeshShaderPushConstantStageFlags,0,SizeOf(TpvScene3D.TMeshStagePushConstants),MeshStagePushConstants);
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirectCount,'MeshShaderDrawOITPromotion');
         end;
         vkCmdDrawMeshTasksIndirectCountEXT(aCommandBuffer.Handle,
                                            fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,
                                            TVkDeviceSize(fExpandRangeInfos[(TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls*2)+DrawChoreographyBatchRange^.DrawCallIndex].OutputBase)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand),
                                            fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].Handle,
                                            ((TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls*2)+DrawChoreographyBatchRange^.DrawCallIndex)*SizeOf(TpvUInt32),
                                            fExpandRangeInfos[(TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls*2)+DrawChoreographyBatchRange^.DrawCallIndex].OutputCapacity,
                                            SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
         end;
        end else begin
         AdjustedBDA:=OutputBufferDeviceAddress+(TVkDeviceSize(fPerInFlightFrameGPUDrawIndexedIndirectCommandOITPromotionOffsets[aInFlightFrameIndex]+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         MeshStagePushConstants^.MeshDrawCommandsBDA:=AdjustedBDA;
         aCommandBuffer.CmdPushConstants(aPipelineLayout.Handle,MeshShaderPushConstantStageFlags,0,SizeOf(TpvScene3D.TMeshStagePushConstants),MeshStagePushConstants);
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirectCount,'MeshShaderDrawOITPromotion');
         end;
         vkCmdDrawMeshTasksIndirectCountEXT(aCommandBuffer.Handle,
                                            fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,
                                            (fPerInFlightFrameGPUDrawIndexedIndirectCommandOITPromotionOffsets[aInFlightFrameIndex]+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand),
                                            fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].Handle,
                                            ((TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls*2)+DrawChoreographyBatchRange^.DrawCallIndex)*SizeOf(TpvUInt32),
                                            DrawChoreographyBatchRange^.CountCommands,
                                            SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
         end;
        end;

       end else begin

        if Renderer.UseMeshletExpand and not (aRenderPass in [TpvScene3DRendererRenderPass.ReflectiveShadowMap,TpvScene3DRendererRenderPass.Voxelization,TpvScene3DRendererRenderPass.TopDownSkyOcclusionMap,TpvScene3DRendererRenderPass.ReflectionProbe]) then begin
         AdjustedBDA:=OutputBufferDeviceAddress+(TVkDeviceSize(fExpandRangeInfos[CullRenderPassCounterSlotBase+DrawChoreographyBatchRange^.DrawCallIndex].OutputBase)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         MeshStagePushConstants^.MeshDrawCommandsBDA:=AdjustedBDA;
         aCommandBuffer.CmdPushConstants(aPipelineLayout.Handle,MeshShaderPushConstantStageFlags,0,SizeOf(TpvScene3D.TMeshStagePushConstants),MeshStagePushConstants);
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirectCount,'MeshShaderDraw');
         end;
         vkCmdDrawMeshTasksIndirectCountEXT(aCommandBuffer.Handle,
                                            fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,
                                            TVkDeviceSize(fExpandRangeInfos[CullRenderPassCounterSlotBase+DrawChoreographyBatchRange^.DrawCallIndex].OutputBase)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand),
                                            fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].Handle,
                                            (CullRenderPassCounterSlotBase+DrawChoreographyBatchRange^.DrawCallIndex)*SizeOf(TpvUInt32),
                                            fExpandRangeInfos[CullRenderPassCounterSlotBase+DrawChoreographyBatchRange^.DrawCallIndex].OutputCapacity,
                                            SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
         end;
        end else begin
         AdjustedBDA:=OutputBufferDeviceAddress+(TVkDeviceSize(CullRenderPassOutputCommandBase+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         MeshStagePushConstants^.MeshDrawCommandsBDA:=AdjustedBDA;
         aCommandBuffer.CmdPushConstants(aPipelineLayout.Handle,MeshShaderPushConstantStageFlags,0,SizeOf(TpvScene3D.TMeshStagePushConstants),MeshStagePushConstants);
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirectCount,'MeshShaderDraw');
         end;
         vkCmdDrawMeshTasksIndirectCountEXT(aCommandBuffer.Handle,
                                            fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,
                                            TpvSizeInt(CullRenderPassOutputCommandBase+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand),
                                            fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].Handle,
                                            (CullRenderPassCounterSlotBase+DrawChoreographyBatchRange^.DrawCallIndex)*SizeOf(TpvUInt32),
                                            DrawChoreographyBatchRange^.CountCommands,
                                            SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand));
         if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
          fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
         end;
        end;

       end;

      end;

     end else if UseMeshShaderDraw then begin

      // Non-triangle (POINTS/LINES) fallback while the mesh-shader path is active: the mesh-cull output holds mesh-task
      // commands (triangle meshlets only), so draw this range's indexed commands straight from the uncull­ed input buffer
      // with the vertex pipeline instead. BDA is unused by the vertex stage; push the stage params so ViewBaseIndex etc. are set.
      MeshStagePushConstants^.MeshDrawCommandsBDA:=0;
      aCommandBuffer.CmdPushConstants(aPipelineLayout.Handle,MeshShaderPushConstantStageFlags,0,SizeOf(TpvScene3D.TMeshStagePushConstants),MeshStagePushConstants);
      if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
       fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirect,'MeshDrawNonTriangleFallback');
      end;
      aCommandBuffer.CmdDrawIndexedIndirect(fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex].Handle,
                                            ((CullRenderPassOutputCommandBase+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand))+TpvPtrUInt(Pointer(@TpvScene3D.PGPUDrawIndexedIndirectCommand(nil)^.DrawIndexedIndirectCommand)),
                                            DrawChoreographyBatchRange^.CountCommands,
                                            SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand));
      if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
       fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
      end;

     end else if assigned(vkCmdDrawIndexedIndirectCount) then begin

      if aDisocclusions then begin

       if aOITPromotion then begin

        if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
         fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirectCount,'MeshDrawOITPromotionDisocclusion');
        end;
        vkCmdDrawIndexedIndirectCount(aCommandBuffer.Handle,
                                      fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,
                                      ((fPerInFlightFrameGPUDrawIndexedIndirectCommandOITDisocclusionOffsets[aInFlightFrameIndex]+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand))+TpvPtrUInt(Pointer(@TpvScene3D.PGPUDrawIndexedIndirectCommand(nil)^.DrawIndexedIndirectCommand)),
                                      fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].Handle,
                                      ((TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls*3)+DrawChoreographyBatchRange^.DrawCallIndex)*SizeOf(TpvUInt32),
                                      DrawChoreographyBatchRange^.CountCommands,
                                      SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand));
        if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
         fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
        end;

       end else begin

        if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
         fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirectCount,'MeshDrawDisocclusion');
        end;
        vkCmdDrawIndexedIndirectCount(aCommandBuffer.Handle,
                                      fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,
                                      ((CullRenderPassDisocclusionOutputCommandBase+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand))+TpvPtrUInt(Pointer(@TpvScene3D.PGPUDrawIndexedIndirectCommand(nil)^.DrawIndexedIndirectCommand)),
                                      fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].Handle,
                                      (CullRenderPassCounterSlotBase+TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls+DrawChoreographyBatchRange^.DrawCallIndex)*SizeOf(TpvUInt32),
                                      DrawChoreographyBatchRange^.CountCommands,
                                      SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand));
        if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
         fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
        end;

       end;

      end else begin

       if aOITPromotion then begin

        if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
         fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirectCount,'MeshDrawOITPromotion');
        end;
        vkCmdDrawIndexedIndirectCount(aCommandBuffer.Handle,
                                      fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,
                                      ((fPerInFlightFrameGPUDrawIndexedIndirectCommandOITPromotionOffsets[aInFlightFrameIndex]+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand))+TpvPtrUInt(Pointer(@TpvScene3D.PGPUDrawIndexedIndirectCommand(nil)^.DrawIndexedIndirectCommand)),
                                      fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].Handle,
                                      ((TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls*2)+DrawChoreographyBatchRange^.DrawCallIndex)*SizeOf(TpvUInt32),
                                      DrawChoreographyBatchRange^.CountCommands,
                                      SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand));
        if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
         fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
        end;

       end else begin

        if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
         fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirectCount,'MeshDraw');
        end;
        vkCmdDrawIndexedIndirectCount(aCommandBuffer.Handle,
                                      fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,
                                      ((CullRenderPassOutputCommandBase+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand))+TpvPtrUInt(Pointer(@TpvScene3D.PGPUDrawIndexedIndirectCommand(nil)^.DrawIndexedIndirectCommand)),
                                      fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].Handle,
                                      (CullRenderPassCounterSlotBase+DrawChoreographyBatchRange^.DrawCallIndex)*SizeOf(TpvUInt32),
                                      DrawChoreographyBatchRange^.CountCommands,
                                      SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand));
        if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
         fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
        end;

       end;

      end;

     end else begin

      if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
       fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirect,'MeshDrawFallback');
      end;
      aCommandBuffer.CmdDrawIndexedIndirect(fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex].Handle,
                                            ((CullRenderPassOutputCommandBase+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand))+TpvPtrUInt(Pointer(@TpvScene3D.PGPUDrawIndexedIndirectCommand(nil)^.DrawIndexedIndirectCommand)),
                                            DrawChoreographyBatchRange^.CountCommands,
                                            SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand));
      if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
       fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
      end;
     end;

    end;

   end;

  end;

 end;

end;

procedure TpvScene3DRendererInstance.PrepareFrame(const aInFlightFrameIndex:TpvInt32;const aFrameCounter:TpvInt64);
var Index:TpvSizeInt;
    InFlightFrameState:PInFlightFrameState;
    ViewLeft,ViewRight:TpvScene3D.TView;
    RenderPass:TpvScene3DRendererRenderPass;
    ViewMatrix,LeftProjectionMatrix,RightProjectionMatrix:TpvMatrix4x4;
    FieldOfView:TpvFloat;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 fPerInFlightFrameColorGradingSettings[aInFlightFrameIndex]:=fColorGradingSettings;

 fCameraPresets[aInFlightFrameIndex].Assign(fCameraPreset);

 InFlightFrameState:=@fInFlightFrameStates[aInFlightFrameIndex];

 InFlightFrameState^.CameraReset:=fCameraPresets[aInFlightFrameIndex].Reset;

 FieldOfView:=fCameraPresets[aInFlightFrameIndex].FieldOfView;

 if fViews[aInFlightFrameIndex].Count=0 then begin

  ViewMatrix:=TpvMatrix4x4(TpvScene3D(fScene3D).TransformOrigin(fCameraViewMatrices[aInFlightFrameIndex],aInFlightFrameIndex,true));

  if assigned(fVirtualReality) then begin

   ViewLeft.ViewMatrix:=ViewMatrix*fVirtualReality.GetPositionMatrix(0);
   LeftProjectionMatrix:=fVirtualReality.GetProjectionMatrix(0);
   ViewLeft.ProjectionMatrix:=AddTemporalAntialiasingJitter(LeftProjectionMatrix,aFrameCounter);
   ViewLeft.InverseViewMatrix:=ViewLeft.ViewMatrix.Inverse;
   ViewLeft.InverseProjectionMatrix:=ViewLeft.ProjectionMatrix.Inverse;

   ViewRight.ViewMatrix:=ViewMatrix*fVirtualReality.GetPositionMatrix(1);
   RightProjectionMatrix:=fVirtualReality.GetProjectionMatrix(1);
   ViewRight.ProjectionMatrix:=AddTemporalAntialiasingJitter(RightProjectionMatrix,aFrameCounter);
   ViewRight.InverseViewMatrix:=ViewRight.ViewMatrix.Inverse;
   ViewRight.InverseProjectionMatrix:=ViewRight.ProjectionMatrix.Inverse;

   InFlightFrameState^.FinalViewIndex:=fViews[aInFlightFrameIndex].Add([ViewLeft,ViewRight]);

   fCountRealViews[aInFlightFrameIndex]:=fViews[aInFlightFrameIndex].Count;
   InFlightFrameState^.CountFinalViews:=2;

   ViewLeft.ViewMatrix:=fVirtualReality.GetPositionMatrix(0);
   ViewLeft.ProjectionMatrix:=AddTemporalAntialiasingJitter(fVirtualReality.GetProjectionMatrix(0),aFrameCounter);
   ViewLeft.InverseViewMatrix:=ViewLeft.ViewMatrix.Inverse;
   ViewLeft.InverseProjectionMatrix:=ViewLeft.ProjectionMatrix.Inverse;

   ViewRight.ViewMatrix:=fVirtualReality.GetPositionMatrix(1);
   ViewRight.ProjectionMatrix:=AddTemporalAntialiasingJitter(fVirtualReality.GetProjectionMatrix(1),aFrameCounter);
   ViewRight.InverseViewMatrix:=ViewRight.ViewMatrix.Inverse;
   ViewRight.InverseProjectionMatrix:=ViewRight.ProjectionMatrix.Inverse;

   InFlightFrameState^.HUDViewIndex:=fViews[aInFlightFrameIndex].Add([ViewLeft,ViewRight]);
   InFlightFrameState^.CountHUDViews:=2;

   ViewLeft:=fViews[aInFlightFrameIndex].Items[InFlightFrameState^.FinalViewIndex];
   InFlightFrameState^.MainViewMatrix:=ViewLeft.ViewMatrix;
   InFlightFrameState^.MainInverseViewMatrix:=ViewLeft.ViewMatrix.Inverse;
   InFlightFrameState^.MainCameraPosition:=InFlightFrameState^.MainInverseViewMatrix.Translation.xyz;

   InFlightFrameState^.MainViewProjectionMatrix:=ViewLeft.ViewMatrix*ViewLeft.ProjectionMatrix;

   ViewLeft:=fViews[aInFlightFrameIndex].Items[InFlightFrameState^.FinalViewIndex];
   ViewRight:=fViews[aInFlightFrameIndex].Items[InFlightFrameState^.FinalViewIndex+1];
   ViewLeft.ProjectionMatrix:=LeftProjectionMatrix;
   ViewRight.ProjectionMatrix:=RightProjectionMatrix;
   ViewLeft.InverseProjectionMatrix:=ViewLeft.ProjectionMatrix.Inverse;
   ViewRight.InverseProjectionMatrix:=ViewRight.ProjectionMatrix.Inverse;
   InFlightFrameState^.FinalUnjitteredViewIndex:=fViews[aInFlightFrameIndex].Add([ViewLeft,ViewRight]);

  end else begin

   ViewLeft.ViewMatrix:=ViewMatrix;

   if FieldOfView>0.0 then begin
    // > 0.0 = Horizontal FOV
    if fZFar>0.0 then begin
     ViewLeft.ProjectionMatrix:=TpvMatrix4x4.CreateHorizontalFOVPerspectiveRightHandedZeroToOne(FieldOfView,
                                                                                                fScaledWidth/fScaledHeight,
                                                                                                abs(fZNear),
                                                                                                IfThen(IsInfinite(fZFar),1024.0,abs(fZFar)));
    end else begin
     ViewLeft.ProjectionMatrix:=TpvMatrix4x4.CreateHorizontalFOVPerspectiveRightHandedOneToZero(FieldOfView,
                                                                                                fScaledWidth/fScaledHeight,
                                                                                                abs(fZNear),
                                                                                                IfThen(IsInfinite(fZFar),1024.0,abs(fZFar)));
    end;
   end else begin
    // < 0.0 = Vertical FOV
    if fZFar>0.0 then begin
     ViewLeft.ProjectionMatrix:=TpvMatrix4x4.CreatePerspectiveRightHandedZeroToOne(-FieldOfView,
                                                                                   fScaledWidth/fScaledHeight,
                                                                                   abs(fZNear),
                                                                                   IfThen(IsInfinite(fZFar),1024.0,abs(fZFar)));
    end else begin
     ViewLeft.ProjectionMatrix:=TpvMatrix4x4.CreatePerspectiveRightHandedOneToZero(-FieldOfView,
                                                                                   fScaledWidth/fScaledHeight,
                                                                                   abs(fZNear),
                                                                                   IfThen(IsInfinite(fZFar),1024.0,abs(fZFar)));
    end;
   end;
   if fZFar<0.0 then begin
    if IsInfinite(fZFar) then begin
     // Convert to reversed infinite Z
     ViewLeft.ProjectionMatrix.RawComponents[2,2]:=0.0;
     ViewLeft.ProjectionMatrix.RawComponents[2,3]:=-1.0;
     ViewLeft.ProjectionMatrix.RawComponents[3,2]:=abs(fZNear);
    end else begin
     // Convert to reversed non-infinite Z
     ViewLeft.ProjectionMatrix.RawComponents[2,2]:=abs(fZNear)/(abs(fZFar)-abs(fZNear));
     ViewLeft.ProjectionMatrix.RawComponents[2,3]:=-1.0;
     ViewLeft.ProjectionMatrix.RawComponents[3,2]:=(abs(fZNear)*abs(fZFar))/(abs(fZFar)-abs(fZNear));
    end;
   end;
   LeftProjectionMatrix:=ViewLeft.ProjectionMatrix*TpvMatrix4x4.FlipYClipSpace;
   ViewLeft.ProjectionMatrix:=AddTemporalAntialiasingJitter(LeftProjectionMatrix,aFrameCounter);
   ViewLeft.InverseViewMatrix:=ViewLeft.ViewMatrix.Inverse;
   ViewLeft.InverseProjectionMatrix:=ViewLeft.ProjectionMatrix.Inverse;

   InFlightFrameState^.FinalViewIndex:=fViews[aInFlightFrameIndex].Add(ViewLeft);

   InFlightFrameState^.MainViewMatrix:=ViewLeft.ViewMatrix;
   InFlightFrameState^.MainInverseViewMatrix:=ViewLeft.ViewMatrix.Inverse;
   InFlightFrameState^.MainCameraPosition:=InFlightFrameState^.MainInverseViewMatrix.Translation.xyz;

   InFlightFrameState^.MainViewProjectionMatrix:=ViewLeft.ViewMatrix*ViewLeft.ProjectionMatrix;

   fCountRealViews[aInFlightFrameIndex]:=fViews[aInFlightFrameIndex].Count;
   InFlightFrameState^.CountFinalViews:=1;

   ViewLeft.ViewMatrix:=TpvMatrix4x4.Identity;
   ViewLeft.ProjectionMatrix:=AddTemporalAntialiasingJitter(ViewLeft.ProjectionMatrix*TpvMatrix4x4.FlipYClipSpace,aFrameCounter);
   ViewLeft.InverseViewMatrix:=ViewLeft.ViewMatrix.Inverse;
   ViewLeft.InverseProjectionMatrix:=ViewLeft.ProjectionMatrix.Inverse;

   InFlightFrameState^.HUDViewIndex:=fViews[aInFlightFrameIndex].Add(ViewLeft);
   InFlightFrameState^.CountHUDViews:=1;

   ViewLeft:=fViews[aInFlightFrameIndex].Items[InFlightFrameState^.FinalViewIndex];
   ViewLeft.ProjectionMatrix:=LeftProjectionMatrix;
   ViewLeft.InverseProjectionMatrix:=ViewLeft.ProjectionMatrix.Inverse;
   InFlightFrameState^.FinalUnjitteredViewIndex:=fViews[aInFlightFrameIndex].Add(ViewLeft);

  end;

 end else begin

  InFlightFrameState^.FinalViewIndex:=0;
  InFlightFrameState^.CountFinalViews:=1;

  InFlightFrameState^.HUDViewIndex:=0;
  InFlightFrameState^.CountHUDViews:=1;

 end;

 CalculateSceneBounds(aInFlightFrameIndex);

 if Renderer.GlobalIlluminationMode=TpvScene3DRendererGlobalIlluminationMode.CameraReflectionProbe then begin
  AddCameraReflectionProbeViews(aInFlightFrameIndex);
 end else begin
  InFlightFrameState^.ReflectionProbeViewIndex:=-1;
  InFlightFrameState^.CountReflectionProbeViews:=0;
 end;

 if Renderer.GlobalIlluminationMode=TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints then begin

  AddTopDownSkyOcclusionMapView(aInFlightFrameIndex);

  AddReflectiveShadowMapView(aInFlightFrameIndex);

 end else begin

  InFlightFrameState^.TopDownSkyOcclusionMapViewIndex:=-1;
  InFlightFrameState^.CountTopDownSkyOcclusionMapViews:=0;

  InFlightFrameState^.ReflectiveShadowMapViewIndex:=-1;
  InFlightFrameState^.CountReflectiveShadowMapViews:=0;

 end;

 if (Renderer.ShadowMode<>TpvScene3DRendererShadowMode.None) and not Renderer.Scene3D.RaytracingActive then begin
  CalculateCascadedShadowMaps(aInFlightFrameIndex);
 end else begin
  InFlightFrameState^.CascadedShadowMapViewIndex:=-1;
  InFlightFrameState^.CountCascadedShadowMapViews:=0;
 end;

 if assigned(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudShadowRenderPass) then begin
  AddCloudsShadowMapView(aInFlightFrameIndex);
 end else begin
  InFlightFrameState^.CloudsShadowMapViewIndex:=-1;
  InFlightFrameState^.CountCloudsShadowMapViews:=0;
  fScene3D.SetCloudsShadowMapDeviceAddress(aInFlightFrameIndex,0);
 end;

 InFlightFrameState^.CountViews:=fViews[aInFlightFrameIndex].Count;

{if Renderer.AntialiasingMode=TpvScene3DRendererAntialiasingMode.SMAAT2x then begin
  InFlightFrameState^.Jitter:=TpvVector4.Null;
 end else}begin
  InFlightFrameState^.Jitter.xy:=GetJitterOffset(aFrameCounter);
  InFlightFrameState^.Jitter.zw:=GetJitterOffset(aFrameCounter-1);
 end;

 InFlightFrameState^.SkyBoxOrientation:=TpvMatrix4x4(TpvScene3D(fScene3D).TransformOrigin(fScene3D.SkyBoxOrientation,aInFlightFrameIndex,true));

 case Renderer.GlobalIlluminationMode of

  TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints:begin
   UpdateGlobalIlluminationCascadedRadianceHints(aInFlightFrameIndex);
  end;

  TpvScene3DRendererGlobalIlluminationMode.DynamicDiffuseGlobalIllumination:begin
   UpdateGlobalIlluminationDDGI(aInFlightFrameIndex);
  end;

  TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing:begin
   UpdateGlobalIlluminationCascadedVoxelConeTracing(aInFlightFrameIndex);
  end;

  else begin
  end;

 end;


 // Single unified Prepare for all mesh instances (G.5)
 if InFlightFrameState^.CountFinalViews>0 then begin
  fScene3D.Prepare(aInFlightFrameIndex,
                   self,
                   TpvScene3DRendererRenderPass.View,
                   fViews[aInFlightFrameIndex],
                   InFlightFrameState^.FinalViewIndex,
                   InFlightFrameState^.CountFinalViews,
                   fScaledWidth,
                   fScaledHeight,
                   true);
 end;

 // Replicate View BatchRangeIndices and set GPUCulled for all other RenderPasses
 if fCachedDrawDataGeneration[aInFlightFrameIndex]<>fSnapshotDrawDataGeneration[aInFlightFrameIndex] then begin
  for RenderPass:=TpvScene3DRendererRenderPassFirst to TpvScene3DRendererRenderPassLast do begin
   if RenderPass<>TpvScene3DRendererRenderPass.View then begin
    fDrawChoreographyBatchRangeFrameRenderPassBuckets[aInFlightFrameIndex,RenderPass].Assign(
     fDrawChoreographyBatchRangeFrameRenderPassBuckets[aInFlightFrameIndex,TpvScene3DRendererRenderPass.View]);
   end;
  end;
 end;


 // Planet.Prepare per active RenderPass (separate rendering system)
 if InFlightFrameState^.CountFinalViews>0 then begin
  fScene3D.PreparePlanets(aInFlightFrameIndex,self,TpvScene3DRendererRenderPass.View,fScaledWidth,fScaledHeight,true);
  if Renderer.GlobalIlluminationMode=TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing then begin
   fScene3D.PreparePlanets(aInFlightFrameIndex,self,TpvScene3DRendererRenderPass.Voxelization,Renderer.GlobalIlluminationVoxelGridSize,Renderer.GlobalIlluminationVoxelGridSize,false);
  end;
 end;
 if InFlightFrameState^.CountReflectionProbeViews>0 then begin
  fScene3D.PreparePlanets(aInFlightFrameIndex,self,TpvScene3DRendererRenderPass.ReflectionProbe,fReflectionProbeWidth,fReflectionProbeHeight,false);
 end;
 if InFlightFrameState^.CountTopDownSkyOcclusionMapViews>0 then begin
  fScene3D.PreparePlanets(aInFlightFrameIndex,self,TpvScene3DRendererRenderPass.TopDownSkyOcclusionMap,fTopDownSkyOcclusionMapWidth,fTopDownSkyOcclusionMapHeight,false);
 end;
 if InFlightFrameState^.CountReflectiveShadowMapViews>0 then begin
  fScene3D.PreparePlanets(aInFlightFrameIndex,self,TpvScene3DRendererRenderPass.ReflectiveShadowMap,fReflectiveShadowMapWidth,fReflectiveShadowMapHeight,false);
 end;
 if InFlightFrameState^.CountCascadedShadowMapViews>0 then begin
  fScene3D.PreparePlanets(aInFlightFrameIndex,self,TpvScene3DRendererRenderPass.CascadedShadowMap,fCascadedShadowMapWidth,fCascadedShadowMapHeight,false);
 end;

 TPasMPInterlocked.Write(InFlightFrameState^.Ready,true);

end;

procedure TpvScene3DRendererInstance.UploadFrame(const aInFlightFrameIndex:TpvInt32);
var PreviousInFlightFrameIndex,NextInFlightFrameIndex,Index,CountViews,Count,
    PerInFlightFrameBufferIndex:TpvSizeInt;
    RenderPass:TpvScene3DRendererRenderPass;
    DoNeedUpdateDescriptors:boolean;
    BatchRangeGlobalOffset:TpvUInt32;
    PrefixSumGlobalOffset:TpvUInt32;
    CullRenderPass:TpvScene3DRendererCullRenderPass;
    DrawChoreographyBatchRangeDynamicArray:TpvScene3D.PDrawChoreographyBatchRangeDynamicArray;
    DrawChoreographyBatchRangeIndexDynamicArray:TpvScene3D.PDrawChoreographyBatchRangeIndexDynamicArray;
    DrawChoreographyBatchRange:TpvScene3D.PDrawChoreographyBatchRange;
    RangeIndex:TpvSizeInt;
    RunningSum:TpvUInt32;
    GPUBatchRange:TpvScene3D.PGPUBatchRange;
    MeshShaderOutputNeeded:TpvSizeInt;
    OutputNeeded:TpvSizeInt;
    ExpandRangeInfoTotalWeight:TpvSizeInt;
    ExpandRangeInfoMaxOutputCommands:TpvSizeInt;
    ExpandRangeInfoRunningBase:TpvUInt32;
    ExpandRangeInfoIndex:TpvSizeInt;
    ExpandRangeInfoTotalSize:TpvSizeInt;
    MeshletVisibilityAllocCapacity:TpvSizeInt;
    MeshletVisibilityPartSize:TpvInt64;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 PreviousInFlightFrameIndex:=aInFlightFrameIndex-1;
 if PreviousInFlightFrameIndex<0 then begin
  inc(PreviousInFlightFrameIndex,Renderer.CountInFlightFrames);
 end;

 NextInFlightFrameIndex:=aInFlightFrameIndex+1;
 if NextInFlightFrameIndex>=Renderer.CountInFlightFrames then begin
  dec(NextInFlightFrameIndex,Renderer.CountInFlightFrames);
 end;

 if fScene3D.UsePerInFlightFrameResources then begin
  PerInFlightFrameBufferIndex:=aInFlightFrameIndex;
 end else begin
  PerInFlightFrameBufferIndex:=0;
 end;

 if fViews[aInFlightFrameIndex].Count>0 then begin
  Move(fViews[aInFlightFrameIndex].Items[0],
       fVulkanViews[aInFlightFrameIndex].Items[0],
       fViews[aInFlightFrameIndex].Count*SizeOf(TpvScene3D.TView));
  CountViews:=fViews[aInFlightFrameIndex].Count;
  if fLastUploadedViews[aInFlightFrameIndex].Count=0 then begin
   Move(fViews[aInFlightFrameIndex].Items[0],
        fVulkanViews[aInFlightFrameIndex].Items[CountViews],
        fViews[aInFlightFrameIndex].Count*SizeOf(TpvScene3D.TView));
   inc(CountViews,fViews[aInFlightFrameIndex].Count);
  end else begin
   Move(fLastUploadedViews[aInFlightFrameIndex].Items[0],
        fVulkanViews[aInFlightFrameIndex].Items[CountViews],
        fLastUploadedViews[aInFlightFrameIndex].Count*SizeOf(TpvScene3D.TView));
   inc(CountViews,fLastUploadedViews[aInFlightFrameIndex].Count);
  end;
  if assigned(fVulkanViewUniformBuffers[aInFlightFrameIndex]) then begin
   case fScene3D.BufferStreamingMode of
    TpvScene3D.TBufferStreamingMode.Direct:begin
     fVulkanViewUniformBuffers[aInFlightFrameIndex].UpdateData(fVulkanViews[aInFlightFrameIndex].Items[0],
                                                                     0,
                                                                     CountViews*SizeOf(TpvScene3D.TView),
                                                                     false //FlushUpdateData
                                                                    );
    end;
    TpvScene3D.TBufferStreamingMode.Staging:begin
     Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                                fScene3D.VulkanStagingCommandBuffer,
                                                fScene3D.VulkanStagingFence,
                                                fVulkanViews[aInFlightFrameIndex].Items[0],
                                                fVulkanViewUniformBuffers[aInFlightFrameIndex],
                                                0,
                                                CountViews*SizeOf(TpvScene3D.TView));
    end;
    else begin
     Assert(false);
    end;
   end;
  end;
  fLastUploadedViews[PreviousInFlightFrameIndex].Assign(fViews[aInFlightFrameIndex]);
 end;

 Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                            fScene3D.VulkanStagingCommandBuffer,
                                            fScene3D.VulkanStagingFence,
                                            fPerInFlightFrameColorGradingSettings[aInFlightFrameIndex],
                                            fColorGradingSettingUniformBuffers[aInFlightFrameIndex],
                                            0,
                                            SizeOf(TpvScene3DRendererInstanceColorGradingSettings));

 Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                            fScene3D.VulkanStagingCommandBuffer,
                                            fScene3D.VulkanStagingFence,
                                            fCascadedShadowMapUniformBuffers[aInFlightFrameIndex],
                                            fCascadedShadowMapVulkanUniformBuffers[aInFlightFrameIndex],
                                            0,
                                            SizeOf(TCascadedShadowMapUniformBuffer));

 if fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex].Count>0 then begin

  CheckSolidPrimitives(aInFlightFrameIndex);

  Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                             fScene3D.VulkanStagingCommandBuffer,
                                             fScene3D.VulkanStagingFence,
                                             fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex].ItemArray[0],
                                             fSolidPrimitivePrimitiveBuffers[aInFlightFrameIndex],
                                             0,
                                             fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex].Count*SizeOf(TSolidPrimitivePrimitive));

 end;

 if fSpaceLinesPrimitiveDynamicArrays[aInFlightFrameIndex].Count>0 then begin

  CheckSpaceLines(aInFlightFrameIndex);

  Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                             fScene3D.VulkanStagingCommandBuffer,
                                             fScene3D.VulkanStagingFence,
                                             fSpaceLinesPrimitiveDynamicArrays[aInFlightFrameIndex].ItemArray[0],
                                             fSpaceLinesPrimitiveBuffers[aInFlightFrameIndex],
                                             0,
                                             fSpaceLinesPrimitiveDynamicArrays[aInFlightFrameIndex].Count*SizeOf(TSpaceLinesPrimitive));

 end;

 case Renderer.GlobalIlluminationMode of

  TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints:begin
   UploadGlobalIlluminationCascadedRadianceHints(aInFlightFrameIndex);
  end;

  TpvScene3DRendererGlobalIlluminationMode.DynamicDiffuseGlobalIllumination:begin
   UploadGlobalIlluminationDDGI(aInFlightFrameIndex);
  end;

  TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing:begin
   UploadGlobalIlluminationCascadedVoxelConeTracing(aInFlightFrameIndex);
  end;

  else begin
  end;

 end;


 begin

  DoNeedUpdateDescriptors:=false;

  fPerInFlightFrameGPUCountMeshObjectIDsArray[aInFlightFrameIndex]:=Max(0,fScene3D.MaxMeshObjectID+1);

  if fUseSeparateCommandBufferSlots then begin
   Count:=fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count*7;
  end else begin
   Count:=fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count shl 2;
  end;

  // Slot layout (N = command count per pass):
  // Group 0 - FinalView:            Main=0*N  Disocclusion=1*N  OIT=2*N  OIT+Disocclusion=3*N
  // Group 1 - CSM:                  Main=4*N  Disocclusion=5*N
  // Group 2 - Vox/ReflProbe/TopDown/RSM (never simultaneous, Opaque+Mask only): Main=6*N
  fPerInFlightFrameGPUDrawIndexedIndirectCommandDisocclusionOffsets[aInFlightFrameIndex]:=fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count;         // 1*N
  fPerInFlightFrameGPUDrawIndexedIndirectCommandOITPromotionOffsets[aInFlightFrameIndex]:=fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count*2;       // 2*N
  fPerInFlightFrameGPUDrawIndexedIndirectCommandOITDisocclusionOffsets[aInFlightFrameIndex]:=fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count*3;    // 3*N
  if fUseSeparateCommandBufferSlots then begin
   fPerInFlightFrameGPUDrawIndexedIndirectCommandCSMOffsets[aInFlightFrameIndex]:=fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count*4;               // 4*N
   fPerInFlightFrameGPUDrawIndexedIndirectCommandCSMDisocclusionOffsets[aInFlightFrameIndex]:=fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count*5;   // 5*N
   fPerInFlightFrameGPUDrawIndexedIndirectCommandFilterOffsets[aInFlightFrameIndex]:=fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count*6;          // 6*N
  end else begin
   fPerInFlightFrameGPUDrawIndexedIndirectCommandCSMOffsets[aInFlightFrameIndex]:=0;
   fPerInFlightFrameGPUDrawIndexedIndirectCommandCSMDisocclusionOffsets[aInFlightFrameIndex]:=fPerInFlightFrameGPUDrawIndexedIndirectCommandDisocclusionOffsets[aInFlightFrameIndex];
   fPerInFlightFrameGPUDrawIndexedIndirectCommandFilterOffsets[aInFlightFrameIndex]:=0;
  end;

  if fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex]<Count then begin

   fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex]:=Count+((Count+1) shr 1);

   fScene3D.AddToFreeQueue(fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex],1);

   // Grow-only output buffer size tracking
   if Renderer.Scene3D.MeshShaders then begin
    OutputNeeded:=Max(fMeshShaderOutputBufferSizes[aInFlightFrameIndex],fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex]);
   end else begin
    OutputNeeded:=fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex];
   end;
   if fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex]<OutputNeeded then begin
    fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex]:=OutputNeeded;
    fScene3D.WaitOnceOnPreviousFrame;
    FreeAndNil(fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex]);
   end;

   case fScene3D.BufferStreamingMode of

    TpvScene3D.TBufferStreamingMode.Direct:begin

     fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                             Max(1,fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex])*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand),
                                                                                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                                             TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                             [],
                                                                                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                                             0,
                                                                                                             0,
                                                                                                             0,
                                                                                                             0,
                                                                                                             0,
                                                                                                             0,
                                                                                                             [TpvVulkanBufferFlag.PersistentMapped],
                                                                                                             0,
                                                                                                             pvAllocationGroupIDScene3DDynamic,
                                                                                                             '3DRendererInstance.CmdInputBuffers['+IntToStr(aInFlightFrameIndex)+']'
                                                                                                            );
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CmdInputBuffers['+IntToStr(aInFlightFrameIndex)+']');

     if not assigned(fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex]) then begin
      fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                       IfThen(Renderer.Scene3D.MeshShaders,Max(1,fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex])*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand),Max(1,fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex])*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand)),
                                                                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                                       TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                       [],
                                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                       0,
                                                                                                       0,
                                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                       0,
                                                                                                       0,
                                                                                                       0,
                                                                                                       0,
                                                                                                       [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                                       0,
                                                                                                       pvAllocationGroupIDScene3DDynamic,
                                                                                                       '3DRendererInstance.CmdOutputBuffer'
                                                                                                      );
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CmdOutputBuffer');
     end;

    end;

    TpvScene3D.TBufferStreamingMode.Staging:begin

     fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                             Max(1,fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex])*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand),
                                                                                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                                             TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                             [],
                                                                                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                             0,
                                                                                                             0,
                                                                                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                             0,
                                                                                                             0,
                                                                                                             0,
                                                                                                             0,
                                                                                                             [],
                                                                                                             0,
                                                                                                             pvAllocationGroupIDScene3DDynamic,
                                                                                                             '3DRendererInstance.CmdInputBuffers['+IntToStr(aInFlightFrameIndex)+']'
                                                                                                            );
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CmdInputBuffers['+IntToStr(aInFlightFrameIndex)+']');

     if not assigned(fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex]) then begin
      fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                       IfThen(Renderer.Scene3D.MeshShaders,Max(1,fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex])*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand),Max(1,fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex])*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand)),
                                                                                                       TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                                       TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                       [],
                                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                       0,
                                                                                                       0,
                                                                                                       TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                       0,
                                                                                                       0,
                                                                                                       0,
                                                                                                       0,
                                                                                                       [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                                       0,
                                                                                                       pvAllocationGroupIDScene3DDynamic,
                                                                                                       '3DRendererInstance.CmdOutputBuffer'
                                                                                                      );
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CmdOutputBuffer');
     end;

    end;

    else begin
     Assert(false);
    end;

   end;

   DoNeedUpdateDescriptors:=true;

   // Replicate pointer and output buffer sizes to all slots in single-buffer mode
   if not fScene3D.UsePerInFlightFrameResources then begin
    for Index:=1 to MaxInFlightFrames-1 do begin
     fGPUDrawIndexedIndirectCommandOutputBuffers[Index]:=fGPUDrawIndexedIndirectCommandOutputBuffers[0];
     fGPUDrawIndexedIndirectCommandOutputBufferSizes[Index]:=fGPUDrawIndexedIndirectCommandOutputBufferSizes[0];
    end;
   end;

  end;

  // Grow-only mesh shader output buffer resize based on TotalActiveMeshletCount
  if Renderer.Scene3D.MeshShaders then begin

   MeshShaderOutputNeeded:=Max(fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex],fScene3D.TotalActiveMeshletCount*IfThen(Renderer.UseMeshletExpand,4,1));

   if fMeshShaderOutputBufferSizes[aInFlightFrameIndex]<MeshShaderOutputNeeded then begin

    fMeshShaderOutputBufferSizes[aInFlightFrameIndex]:=MeshShaderOutputNeeded+((MeshShaderOutputNeeded+1) shr 1);

    // Grow-only output buffer size tracking
    OutputNeeded:=Max(fMeshShaderOutputBufferSizes[aInFlightFrameIndex],fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex]);
    if fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex]<OutputNeeded then begin
     fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex]:=OutputNeeded;

     fScene3D.WaitOnceOnPreviousFrame;

     FreeAndNil(fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex]);

     case fScene3D.BufferStreamingMode of
      TpvScene3D.TBufferStreamingMode.Direct:begin
       fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                        Max(1,fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex])*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand),
                                                                                                        TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                                        TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                        [],
                                                                                                        TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                        0,
                                                                                                        0,
                                                                                                        TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                        0,
                                                                                                        0,
                                                                                                        0,
                                                                                                        0,
                                                                                                        [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                                        0,
                                                                                                        pvAllocationGroupIDScene3DDynamic,
                                                                                                        '3DRendererInstance.CmdOutputBuffer'
                                                                                                       );
       Renderer.VulkanDevice.DebugUtils.SetObjectName(fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CmdOutputBuffer');
      end;
      TpvScene3D.TBufferStreamingMode.Staging:begin
       fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                        Max(1,fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex])*SizeOf(TpvScene3D.TGPUDrawMeshTasksIndirectCommand),
                                                                                                        TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                                        TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                        [],
                                                                                                        TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                        0,
                                                                                                        0,
                                                                                                        TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                        0,
                                                                                                        0,
                                                                                                        0,
                                                                                                        0,
                                                                                                        [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                                        0,
                                                                                                        pvAllocationGroupIDScene3DDynamic,
                                                                                                        '3DRendererInstance.CmdOutputBuffer'
                                                                                                       );
       Renderer.VulkanDevice.DebugUtils.SetObjectName(fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CmdOutputBuffer');
      end;
      else begin
       Assert(false);
      end;
     end;
     DoNeedUpdateDescriptors:=true;

     // Replicate pointer and output buffer sizes to all slots in single-buffer mode
     if not fScene3D.UsePerInFlightFrameResources then begin
      for Index:=1 to MaxInFlightFrames-1 do begin
       fGPUDrawIndexedIndirectCommandOutputBuffers[Index]:=fGPUDrawIndexedIndirectCommandOutputBuffers[0];
       fGPUDrawIndexedIndirectCommandOutputBufferSizes[Index]:=fGPUDrawIndexedIndirectCommandOutputBufferSizes[0];
      end;
     end;

    end;

    // Sync mesh shader output buffer sizes in single-buffer mode
    if not fScene3D.UsePerInFlightFrameResources then begin
     for Index:=0 to MaxInFlightFrames-1 do begin
      fMeshShaderOutputBufferSizes[Index]:=Max(fMeshShaderOutputBufferSizes[Index],fMeshShaderOutputBufferSizes[aInFlightFrameIndex]);
     end;
    end;

   end;

   // Grow-only scratch buffer resize (must be at least as large as output buffer)
   if Renderer.UseMeshletExpand and (fMeshCullMaxScratchEntries[PerInFlightFrameBufferIndex]<fMeshShaderOutputBufferSizes[aInFlightFrameIndex]) then begin
    fMeshCullMaxScratchEntries[PerInFlightFrameBufferIndex]:=fMeshShaderOutputBufferSizes[aInFlightFrameIndex];
    fScene3D.WaitOnceOnPreviousFrame;
    FreeAndNil(fMeshCullScratchBuffers[PerInFlightFrameBufferIndex]);
    fMeshCullScratchBuffers[PerInFlightFrameBufferIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                 16+(48*TpvInt64(fMeshCullMaxScratchEntries[PerInFlightFrameBufferIndex])),
                                                                                 TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                 TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                 [],
                                                                                 TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                 0,
                                                                                 0,
                                                                                 TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                 0,
                                                                                 0,
                                                                                 0,
                                                                                 0,
                                                                                 [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                 0,
                                                                                 pvAllocationGroupIDScene3DDynamic,
                                                                                 '3DRendererInstance.ScratchBuffer'
                                                                                );
    Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshCullScratchBuffers[PerInFlightFrameBufferIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.ScratchBuffer');

    // Replicate pointer and value to all slots in single-buffer mode
    if not fScene3D.UsePerInFlightFrameResources then begin
     for Index:=1 to MaxInFlightFrames-1 do begin
      fMeshCullScratchBuffers[Index]:=fMeshCullScratchBuffers[0];
      fMeshCullMaxScratchEntries[Index]:=fMeshCullMaxScratchEntries[0];
     end;
    end;

   end;

  end;

  if (not assigned(fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[aInFlightFrameIndex]) or
     (fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[aInFlightFrameIndex].Size<=((fScene3D.MaxMeshObjectID+32) shr 5)*(2*SizeOf(TpvUInt32)))) then begin

   fScene3D.AddToFreeQueue(fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[aInFlightFrameIndex],2);

   fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBufferPartSizes[aInFlightFrameIndex]:=(fScene3D.MaxMeshObjectID+32) shr 5;

   fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[aInFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                                ((fScene3D.MaxMeshObjectID+32) shr 5)*(2*SizeOf(TpvUInt32)),
                                                                                                                TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
                                                                                                                TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                                [],
                                                                                                                TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                                0,
                                                                                                                0,
                                                                                                                TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                                                                                                0,
                                                                                                                0,
                                                                                                                0,
                                                                                                                0,
                                                                                                                [],
                                                                                                                0,
                                                                                                                pvAllocationGroupIDScene3DDynamic,
                                                                                                                '3DRendererInstance.VisibilityBuffers['+IntToStr(aInFlightFrameIndex)+']'
                                                                                                               );
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[aInFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.VisibilityBuffers['+IntToStr(aInFlightFrameIndex)+']');

   DoNeedUpdateDescriptors:=true;

  end;

  begin
   // Meshlet visibility buffer resize: grow when allocator capacity exceeds current buffer
   MeshletVisibilityAllocCapacity:=fScene3D.VulkanMeshletVisibilityBufferRangeAllocator.Capacity;
   MeshletVisibilityPartSize:=TpvInt64((MeshletVisibilityAllocCapacity+31) shr 5);
   if MeshletVisibilityPartSize<1 then begin
    MeshletVisibilityPartSize:=1;
   end;
   for CullRenderPass:=TpvScene3DRendererCullRenderPass.FinalView to TpvScene3DRendererCullRenderPass.CascadedShadowMap do begin
    if (not assigned(fPerInFlightFrameMeshletVisibilityBuffers[aInFlightFrameIndex,CullRenderPass])) or
       (fPerInFlightFrameMeshletVisibilityBufferPartSizes[aInFlightFrameIndex,CullRenderPass]<MeshletVisibilityPartSize) then begin
     fScene3D.AddToFreeQueue(fPerInFlightFrameMeshletVisibilityBuffers[aInFlightFrameIndex,CullRenderPass],1);
     fPerInFlightFrameMeshletVisibilityBufferPartSizes[aInFlightFrameIndex,CullRenderPass]:=MeshletVisibilityPartSize;
     fPerInFlightFrameMeshletVisibilityBuffers[aInFlightFrameIndex,CullRenderPass]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                           MeshletVisibilityPartSize*SizeOf(TpvUInt32),
                                                                                                           TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT),
                                                                                                           TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                                                           [],
                                                                                                           TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                                                                           0,
                                                                                                           0,
                                                                                                           TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),
                                                                                                           0,
                                                                                                           0,
                                                                                                           0,
                                                                                                           0,
                                                                                                           [TpvVulkanBufferFlag.BufferDeviceAddress],
                                                                                                           0,
                                                                                                           pvAllocationGroupIDScene3DDynamic,
                                                                                                           '3DRendererInstance.MeshletVisibilityBuffers['+IntToStr(aInFlightFrameIndex)+','+IntToStr(Ord(CullRenderPass))+']'
                                                                                                          );
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameMeshletVisibilityBuffers[aInFlightFrameIndex,CullRenderPass].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.MeshletVisibilityBuffers['+IntToStr(aInFlightFrameIndex)+','+IntToStr(Ord(CullRenderPass))+']');
    end;
   end;
  end;

  if DoNeedUpdateDescriptors then begin
   inc(fMeshCullPassDescriptorGeneration);
  end;

  if fMeshCullPassDescriptorGenerations[aInFlightFrameIndex]<>fMeshCullPassDescriptorGeneration then begin

   fMeshCullPassDescriptorGenerations[aInFlightFrameIndex]:=fMeshCullPassDescriptorGeneration;

   begin

    fMeshCullPass0ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(0,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                                        [],
                                                                                        [fVulkanViewUniformBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass0ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(1,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass0ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(2,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[PreviousInFlightFrameIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        true
                                                                                       );
    fMeshCullPass0ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(3,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass0ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(4,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass0ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(5,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fPerInFlightFrameMeshCullBatchRangeBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass0ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(6,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fPerInFlightFrameMeshCullPrefixSumBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass0ComputeVulkanDescriptorSets[aInFlightFrameIndex].Flush;
   end;

   begin

    fMeshCullPass1ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(1,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass1ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(2,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass1ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(3,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass1ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(4,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass1ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(6,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fPerInFlightFrameMeshCullBatchRangeBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass1ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(7,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fPerInFlightFrameMeshCullPrefixSumBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass1ComputeVulkanDescriptorSets[aInFlightFrameIndex].Flush;
   end;

   begin

    fMeshFilterComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(0,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
    fMeshFilterComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(1,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fGPUDrawIndexedIndirectCommandOutputBuffers[PerInFlightFrameBufferIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
    fMeshFilterComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(2,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fGPUDrawIndexedIndirectCommandCounterBuffers[PerInFlightFrameBufferIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
    fMeshFilterComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(3,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameMeshCullBatchRangeBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
    fMeshFilterComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(4,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameMeshCullPrefixSumBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
    fMeshFilterComputeVulkanDescriptorSets[aInFlightFrameIndex].Flush;

   end;

  end;

  if fCachedDrawDataGeneration[aInFlightFrameIndex]<>fSnapshotDrawDataGeneration[aInFlightFrameIndex] then begin

   //WriteLn('[DEBUG] UploadFrame IFF=',aInFlightFrameIndex,' UPLOAD cmds=',fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count,' bufSize=',fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex]);

   if fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count>0 then begin

    Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                               fScene3D.VulkanStagingCommandBuffer,
                                               fScene3D.VulkanStagingFence,
                                               fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Items[0],
                                               fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex],
                                               0,
                                               fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand));

   end;

   fCachedDrawDataGeneration[aInFlightFrameIndex]:=fSnapshotDrawDataGeneration[aInFlightFrameIndex];

  end else begin
   //WriteLn('[DEBUG] UploadFrame IFF=',aInFlightFrameIndex,' CACHED cmds=',fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count,' bufSize=',fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex]);
  end;

 end;


 // Upload GPU batch ranges and prefix sums for mega-dispatch
 begin
  if length(fGPUBatchRanges)<MaxMultiIndirectDrawCalls then begin
   SetLength(fGPUBatchRanges,MaxMultiIndirectDrawCalls*2);
  end;
  if length(fPrefixSums)<(MaxMultiIndirectDrawCalls+1) then begin
   SetLength(fPrefixSums,(MaxMultiIndirectDrawCalls+1)*2);
  end;
  ExpandRangeInfoTotalSize:=MaxMultiIndirectDrawCalls*TpvSizeInt(IfThen(fUseSeparateCommandBufferSlots,7,4));
  if length(fExpandRangeInfos)<ExpandRangeInfoTotalSize then begin
   SetLength(fExpandRangeInfos,ExpandRangeInfoTotalSize);
  end;
  FillChar(fExpandRangeInfos[0],ExpandRangeInfoTotalSize*SizeOf(TpvScene3D.TGPUExpandRangeInfo),0);
  ExpandRangeInfoTotalWeight:=0;
  begin
   BatchRangeGlobalOffset:=0;
   PrefixSumGlobalOffset:=0;
   DrawChoreographyBatchRangeDynamicArray:=@fDrawChoreographyBatchRangeFrameBuckets[aInFlightFrameIndex];
   for CullRenderPass:=Low(TpvScene3DRendererCullRenderPass) to High(TpvScene3DRendererCullRenderPass) do begin
    case CullRenderPass of
     TpvScene3DRendererCullRenderPass.FinalView:begin
      RenderPass:=TpvScene3DRendererRenderPass.View;
     end;
     TpvScene3DRendererCullRenderPass.CascadedShadowMap:begin
      RenderPass:=TpvScene3DRendererRenderPass.CascadedShadowMap;
     end;
     TpvScene3DRendererCullRenderPass.Voxelization:begin
      RenderPass:=TpvScene3DRendererRenderPass.Voxelization;
     end;
     TpvScene3DRendererCullRenderPass.ReflectionProbe:begin
      RenderPass:=TpvScene3DRendererRenderPass.ReflectionProbe;
     end;
     TpvScene3DRendererCullRenderPass.TopDownSkyOcclusionMap:begin
      RenderPass:=TpvScene3DRendererRenderPass.TopDownSkyOcclusionMap;
     end;
     TpvScene3DRendererCullRenderPass.ReflectiveShadowMap:begin
      RenderPass:=TpvScene3DRendererRenderPass.ReflectiveShadowMap;
     end;
     else begin
      continue;
     end;
    end;
    fPerInFlightFrameMeshCullBatchRangeOffsets[aInFlightFrameIndex,CullRenderPass]:=BatchRangeGlobalOffset;
    fPerInFlightFrameMeshCullPrefixSumOffsets[aInFlightFrameIndex,CullRenderPass]:=PrefixSumGlobalOffset;
    DrawChoreographyBatchRangeIndexDynamicArray:=@fDrawChoreographyBatchRangeFrameRenderPassBuckets[aInFlightFrameIndex,RenderPass];
    //WriteLn('[DEBUG] UploadFrame IFF=',aInFlightFrameIndex,' CullPass=',ord(CullRenderPass),' RangeCount=',DrawChoreographyBatchRangeIndexDynamicArray^.Count);
    if DrawChoreographyBatchRangeIndexDynamicArray^.Count>0 then begin
     RunningSum:=0;
     for RangeIndex:=0 to DrawChoreographyBatchRangeIndexDynamicArray^.Count-1 do begin
      DrawChoreographyBatchRange:=@DrawChoreographyBatchRangeDynamicArray^.Items[DrawChoreographyBatchRangeIndexDynamicArray^.Items[RangeIndex]];
      GPUBatchRange:=@fGPUBatchRanges[BatchRangeGlobalOffset+RangeIndex];
      GPUBatchRange^.CountCommands:=DrawChoreographyBatchRange^.CountCommands;
      GPUBatchRange^.DrawCallIndex:=TpvUInt32(fPassGroupCounterSlotBase[CullRenderPass])+DrawChoreographyBatchRange^.DrawCallIndex;
      GPUBatchRange^.AlphaMode:=TpvUInt32(DrawChoreographyBatchRange^.AlphaMode);
      if CullRenderPass in [TpvScene3DRendererCullRenderPass.FinalView,
                             TpvScene3DRendererCullRenderPass.CascadedShadowMap] then begin
       // Full cull passes: disocclusion + OIT + meshlet expand
       if CullRenderPass=TpvScene3DRendererCullRenderPass.CascadedShadowMap then begin
        GPUBatchRange^.BaseCommandIndex:=fPerInFlightFrameGPUDrawIndexedIndirectCommandCSMOffsets[aInFlightFrameIndex]+DrawChoreographyBatchRange^.FirstCommand;
        GPUBatchRange^.BaseCommandIndexForDisocclusions:=fPerInFlightFrameGPUDrawIndexedIndirectCommandCSMDisocclusionOffsets[aInFlightFrameIndex]+DrawChoreographyBatchRange^.FirstCommand;
       end else begin
        GPUBatchRange^.BaseCommandIndex:=DrawChoreographyBatchRange^.FirstCommand;
        GPUBatchRange^.BaseCommandIndexForDisocclusions:=fPerInFlightFrameGPUDrawIndexedIndirectCommandDisocclusionOffsets[aInFlightFrameIndex]+DrawChoreographyBatchRange^.FirstCommand;
       end;
       GPUBatchRange^.DrawCallIndexForDisocclusions:=TpvUInt32(MaxMultiIndirectDrawCalls+fPassGroupCounterSlotBase[CullRenderPass])+DrawChoreographyBatchRange^.DrawCallIndex;
       if (CullRenderPass=TpvScene3DRendererCullRenderPass.FinalView) and
          (DrawChoreographyBatchRange^.AlphaMode in [TpvScene3D.TMaterial.TAlphaMode.Opaque,TpvScene3D.TMaterial.TAlphaMode.Mask]) then begin
        GPUBatchRange^.OITDrawCallIndex:=(MaxMultiIndirectDrawCalls shl 1)+DrawChoreographyBatchRange^.DrawCallIndex;
        GPUBatchRange^.OITBaseCommandIndex:=fPerInFlightFrameGPUDrawIndexedIndirectCommandOITPromotionOffsets[aInFlightFrameIndex]+DrawChoreographyBatchRange^.FirstCommand;
       end else begin
        GPUBatchRange^.OITDrawCallIndex:=TpvUInt32($ffffffff);
        GPUBatchRange^.OITBaseCommandIndex:=0;
       end;
       // Accumulate ExpandRangeInfo weights for meshlet expand sort
       if Renderer.UseMeshletExpand then begin
        // Normal
        fExpandRangeInfos[fPassGroupCounterSlotBase[CullRenderPass]+DrawChoreographyBatchRange^.DrawCallIndex].OutputCapacity:=DrawChoreographyBatchRange^.CountCommands;
        inc(ExpandRangeInfoTotalWeight,DrawChoreographyBatchRange^.CountCommands);
        // Disocclusion
        fExpandRangeInfos[fPassGroupCounterSlotBase[CullRenderPass]+MaxMultiIndirectDrawCalls+DrawChoreographyBatchRange^.DrawCallIndex].OutputCapacity:=DrawChoreographyBatchRange^.CountCommands;
        inc(ExpandRangeInfoTotalWeight,DrawChoreographyBatchRange^.CountCommands);
        // OIT + OIT disocclusion
        if GPUBatchRange^.OITDrawCallIndex<>TpvUInt32($ffffffff) then begin
         fExpandRangeInfos[GPUBatchRange^.OITDrawCallIndex].OutputCapacity:=DrawChoreographyBatchRange^.CountCommands;
         inc(ExpandRangeInfoTotalWeight,DrawChoreographyBatchRange^.CountCommands);
         fExpandRangeInfos[(MaxMultiIndirectDrawCalls*3)+DrawChoreographyBatchRange^.DrawCallIndex].OutputCapacity:=DrawChoreographyBatchRange^.CountCommands;
         inc(ExpandRangeInfoTotalWeight,DrawChoreographyBatchRange^.CountCommands);
        end;
       end;
      end else begin
       // Filter-only passes: no disocclusion, no OIT, no meshlet expand
       GPUBatchRange^.BaseCommandIndex:=fPerInFlightFrameGPUDrawIndexedIndirectCommandFilterOffsets[aInFlightFrameIndex]+DrawChoreographyBatchRange^.FirstCommand;
       GPUBatchRange^.BaseCommandIndexForDisocclusions:=0;
       GPUBatchRange^.DrawCallIndexForDisocclusions:=TpvUInt32($ffffffff);
       GPUBatchRange^.OITDrawCallIndex:=TpvUInt32($ffffffff);
       GPUBatchRange^.OITBaseCommandIndex:=0;
      end;
      fPrefixSums[PrefixSumGlobalOffset+RangeIndex]:=RunningSum;
      RunningSum:=RunningSum+DrawChoreographyBatchRange^.CountCommands;
     end;
     fPrefixSums[PrefixSumGlobalOffset+DrawChoreographyBatchRangeIndexDynamicArray^.Count]:=RunningSum;
     fPerInFlightFrameMeshCullBatchRangeCounts[aInFlightFrameIndex,CullRenderPass]:=DrawChoreographyBatchRangeIndexDynamicArray^.Count;
     fPerInFlightFrameMeshCullTotalCommands[aInFlightFrameIndex,CullRenderPass]:=RunningSum;
     BatchRangeGlobalOffset:=BatchRangeGlobalOffset+TpvUInt32(DrawChoreographyBatchRangeIndexDynamicArray^.Count);
     PrefixSumGlobalOffset:=PrefixSumGlobalOffset+TpvUInt32(DrawChoreographyBatchRangeIndexDynamicArray^.Count)+1;
    end else begin
     fPerInFlightFrameMeshCullBatchRangeCounts[aInFlightFrameIndex,CullRenderPass]:=0;
     fPerInFlightFrameMeshCullTotalCommands[aInFlightFrameIndex,CullRenderPass]:=0;
    end;
   end;
   if BatchRangeGlobalOffset>0 then begin
    Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                               fScene3D.VulkanStagingCommandBuffer,
                                               fScene3D.VulkanStagingFence,
                                               fGPUBatchRanges[0],
                                               fPerInFlightFrameMeshCullBatchRangeBuffers[aInFlightFrameIndex],
                                               0,
                                               BatchRangeGlobalOffset*SizeOf(TpvScene3D.TGPUBatchRange));
   end;
   if PrefixSumGlobalOffset>0 then begin
    Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                               fScene3D.VulkanStagingCommandBuffer,
                                               fScene3D.VulkanStagingFence,
                                               fPrefixSums[0],
                                               fPerInFlightFrameMeshCullPrefixSumBuffers[aInFlightFrameIndex],
                                               0,
                                               PrefixSumGlobalOffset*SizeOf(TpvUInt32));
   end;
   // Scale ExpandRangeInfo capacities and compute prefix sum for outputBase
   if Renderer.UseMeshletExpand then begin
    ExpandRangeInfoMaxOutputCommands:=fGPUDrawIndexedIndirectCommandOutputBufferSizes[PerInFlightFrameBufferIndex];
    ExpandRangeInfoRunningBase:=0;
    for ExpandRangeInfoIndex:=0 to ExpandRangeInfoTotalSize-1 do begin
     if (ExpandRangeInfoTotalWeight>0) and (fExpandRangeInfos[ExpandRangeInfoIndex].OutputCapacity>0) then begin
      fExpandRangeInfos[ExpandRangeInfoIndex].OutputCapacity:=Max(1,(TpvInt64(fExpandRangeInfos[ExpandRangeInfoIndex].OutputCapacity)*ExpandRangeInfoMaxOutputCommands) div ExpandRangeInfoTotalWeight);
     end;
     fExpandRangeInfos[ExpandRangeInfoIndex].OutputBase:=ExpandRangeInfoRunningBase;
     inc(ExpandRangeInfoRunningBase,fExpandRangeInfos[ExpandRangeInfoIndex].OutputCapacity);
    end;
    Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                               fScene3D.VulkanStagingCommandBuffer,
                                               fScene3D.VulkanStagingFence,
                                               fExpandRangeInfos[0],
                                               fPerInFlightFrameExpandRangeInfoBuffers[aInFlightFrameIndex],
                                               0,
                                               ExpandRangeInfoTotalSize*SizeOf(TpvScene3D.TGPUExpandRangeInfo));
   end;
  end;
 end;

end;

procedure TpvScene3DRendererInstance.ProcessAtmospheresForFrame(const aInFlightFrameIndex:TpvInt32;const aCommandBuffer:TpvVulkanCommandBuffer);
var AtmosphereIndex:TpvSizeInt;
    Atmosphere:TpvScene3DAtmosphere;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 TpvScene3DAtmospheres(fScene3D.Atmospheres).Lock.AcquireRead;
 try

  if TpvScene3DAtmospheres(fScene3D.Atmospheres).Count>0 then begin

   for AtmosphereIndex:=0 to TpvScene3DAtmospheres(fScene3D.Atmospheres).Count-1 do begin
    Atmosphere:=TpvScene3DAtmospheres(fScene3D.Atmospheres).Items[AtmosphereIndex];
    if assigned(Atmosphere) then begin
     Atmosphere.Execute(aInFlightFrameIndex,aCommandBuffer,self);
    end;
   end;

  end;

 finally
  TpvScene3DAtmospheres(fScene3D.Atmospheres).Lock.ReleaseRead;
 end;

end;

procedure TpvScene3DRendererInstance.DispatchDebugMeshletSpheres(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex:TpvSizeInt);
var PerInFlightFrameIndex:TpvSizeInt;
    PushConstants:TDebugMeshletSpherePushConstants;
    PairCount:TpvUInt32;
    SphereBuffer:TpvVulkanBuffer;
    PairsBuffer:TpvVulkanBuffer;
    LineBuffer:TpvVulkanBuffer;
    BufferMemoryBarrier:TVkBufferMemoryBarrier;
    InitData:array[0..3] of TpvUInt32;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 if (not fDebugDrawMeshletBoundingSpheres) or
    (not Renderer.Scene3D.MeshShaders) or
    (not assigned(fDebugMeshletSphereComputePipeline)) then begin
  {$ifdef MeshShaderDebug}
  WriteLn('[DBG-DISPATCH] Exit1: flag=',fDebugDrawMeshletBoundingSpheres,' meshShader=',Renderer.Scene3D.MeshShaders,' pipeline=',assigned(fDebugMeshletSphereComputePipeline));
  {$endif}
  exit;
 end;

 if fScene3D.UsePerInFlightFrameResources then begin
  PerInFlightFrameIndex:=aInFlightFrameIndex;
 end else begin
  PerInFlightFrameIndex:=0;
 end;

 LineBuffer:=fDebugMeshletSphereLineBuffers[PerInFlightFrameIndex];
 if not assigned(LineBuffer) then begin
  exit;
 end;

 SphereBuffer:=fScene3D.GlobalMeshletBoundingSphereBuffers[PerInFlightFrameIndex];
 if not assigned(SphereBuffer) then begin
  exit;
 end;

 PairCount:=Min(TpvUInt32(fScene3D.DebugMeshletSpherePairCount),65536);
 {$ifdef MeshShaderDebug}
 WriteLn('[DBG-DISPATCH] PairCount=',PairCount,' RawPairCount=',fScene3D.DebugMeshletSpherePairCount);
 {$endif}
 if PairCount=0 then begin
  {$ifdef MeshShaderDebug}
  WriteLn('[DBG-DISPATCH] Exit: PairCount=0');
  {$endif}
  exit;
 end;

 PairsBuffer:=fScene3D.DebugMeshletSpherePairsBuffer;
 if not assigned(PairsBuffer) then begin
  exit;
 end;

 Renderer.VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'DebugMeshletSpheres',[1.0,0.5,0.0,1.0]);

 // Clear indirect draw command header: vertexCount=0, instanceCount=1, firstVertex=0, firstInstance=0
 aCommandBuffer.CmdFillBuffer(LineBuffer.Handle,0,SizeOf(TVkDrawIndirectCommand),0);
 InitData[0]:=0;
 InitData[1]:=1;
 InitData[2]:=0;
 InitData[3]:=0;
 aCommandBuffer.CmdUpdateBuffer(LineBuffer.Handle,0,SizeOf(TVkDrawIndirectCommand),@InitData[0]);

 // Barrier: transfer → compute
 FillChar(BufferMemoryBarrier,SizeOf(TVkBufferMemoryBarrier),#0);
 BufferMemoryBarrier.sType:=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
 BufferMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
 BufferMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
 BufferMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 BufferMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
 BufferMemoryBarrier.buffer:=LineBuffer.Handle;
 BufferMemoryBarrier.offset:=0;
 BufferMemoryBarrier.size:=VK_WHOLE_SIZE;
 aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    1,@BufferMemoryBarrier,
                                    0,nil);

 // Bind compute pipeline and push constants
 aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,fDebugMeshletSphereComputePipeline.Handle);

 PushConstants.TotalPairCount:=PairCount;
 PushConstants.MaxOutputVertices:=PairCount*96;
 PushConstants.SphereBDA:=SphereBuffer.DeviceAddress;
 PushConstants.OutputBDA:=LineBuffer.DeviceAddress;
 PushConstants.PairsBDA:=PairsBuffer.DeviceAddress;
 PushConstants.MatrixPairBDA:=fScene3D.GlobalVulkanMatrixPairBuffers[PerInFlightFrameIndex].DeviceAddress;

 aCommandBuffer.CmdPushConstants(fDebugMeshletSphereComputePipelineLayout.Handle,
                                  TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TDebugMeshletSpherePushConstants),
                                  @PushConstants);

 // Dispatch: one workgroup per pair
 {$ifdef MeshShaderDebug}
 WriteLn('[DBG-DISPATCH] Dispatching pairs=',PairCount,' SphereBDA=',PushConstants.SphereBDA,' OutputBDA=',PushConstants.OutputBDA,' PairsBDA=',PushConstants.PairsBDA);
 {$endif}
 aCommandBuffer.CmdDispatch(PairCount,1,1);

 // Barrier: compute → vertex input + indirect draw
 BufferMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT);
 BufferMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
 aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT),
                                    0,
                                    0,nil,
                                    1,@BufferMemoryBarrier,
                                    0,nil);

 Renderer.VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

end;

procedure TpvScene3DRendererInstance.DumpVoxelConeTracingContent(const aInFlightFrameIndex:TpvSizeInt;const aFileName:TpvUTF8String);
var ContentDataBuffer,MetaDataBuffer:TpvVulkanBuffer;
    ContentDataSize,MetaDataSize:TVkDeviceSize;
    ContentData,MetaData:TBytes;
    UsedFragments,GridSize,CountCascades,MaxFragments:TpvUInt32;
    InfoText:TStringList;
    Stream:TFileStream;
begin

 if (Renderer.GlobalIlluminationMode<>TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing) or
    (aInFlightFrameIndex<0) or (aInFlightFrameIndex>=Renderer.CountInFlightFrames) then begin
  pvApplication.Log(LOG_INFO,'TpvScene3DRendererInstance.DumpVoxelConeTracingContent','Not in CascadedVoxelConeTracing mode or invalid in-flight frame index -> nothing dumped');
  exit;
 end;

 ContentDataBuffer:=fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffers[aInFlightFrameIndex];
 MetaDataBuffer:=fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffers[aInFlightFrameIndex];
 if (not assigned(ContentDataBuffer)) or (not assigned(MetaDataBuffer)) then begin
  pvApplication.Log(LOG_INFO,'TpvScene3DRendererInstance.DumpVoxelConeTracingContent','Voxel content buffers not allocated -> nothing dumped');
  exit;
 end;

 MaxFragments:=fGlobalIlluminationCascadedVoxelConeTracingMaxGlobalFragmentCount;
 GridSize:=Renderer.GlobalIlluminationVoxelGridSize;
 CountCascades:=Renderer.GlobalIlluminationVoxelCountCascades;

 ContentDataSize:=TVkDeviceSize(MaxFragments)*TVkDeviceSize(SizeOf(TpvUInt32)*8); // stride 2 uvec4 (32 bytes) per cell
 MetaDataSize:=((TVkDeviceSize(CountCascades)*(TVkDeviceSize(GridSize)*GridSize*GridSize))+1)*TVkDeviceSize(SizeOf(TpvUInt32)*2);

 // Debug-only read-back: a full device idle is fine here (hotkey-triggered), then stage-download both buffers to host memory.
 Renderer.VulkanDevice.WaitIdle;

 ContentData:=nil;
 MetaData:=nil;
 InfoText:=TStringList.Create;
 try

  SetLength(ContentData,TpvSizeInt(ContentDataSize));
  SetLength(MetaData,TpvSizeInt(MetaDataSize));

  Renderer.VulkanDevice.MemoryStaging.Download(fScene3D.VulkanStagingQueue,
                                               fScene3D.VulkanStagingCommandBuffer,
                                               fScene3D.VulkanStagingFence,
                                               ContentDataBuffer,
                                               0,
                                               ContentData[0],
                                               ContentDataSize);

  Renderer.VulkanDevice.MemoryStaging.Download(fScene3D.VulkanStagingQueue,
                                               fScene3D.VulkanStagingCommandBuffer,
                                               fScene3D.VulkanStagingFence,
                                               MetaDataBuffer,
                                               0,
                                               MetaData[0],
                                               MetaDataSize);

  // data[0] of the meta-data buffer is the global fragment allocation counter (number of used content cells this frame).
  UsedFragments:=PpvUInt32(@MetaData[0])^;

  InfoText.Add('PasVulkan cascaded voxel-cone-tracing content dump');
  InfoText.Add('inFlightFrameIndex='+IntToStr(aInFlightFrameIndex));
  InfoText.Add('gridSize='+IntToStr(GridSize));
  InfoText.Add('countCascades='+IntToStr(CountCascades));
  InfoText.Add('maxGlobalFragmentCount='+IntToStr(MaxFragments));
  InfoText.Add('usedFragmentCount='+IntToStr(UsedFragments));
  InfoText.Add('contentDataBytes='+IntToStr(ContentDataSize)+' (stride 2 uvec4 = 32 bytes per cell)');
  InfoText.Add('metaDataBytes='+IntToStr(MetaDataSize)+' (data[0]=global counter, then 2 uint per volume: +2=localCount, +3=headCellIndex 1-based)');
  InfoText.Add('contentLayout(FP16): cell c -> 8 uint at c*8; uvec4 f0=(next, packHalf2x16(base.rg), packHalf2x16(base.b,em.r), packHalf2x16(em.gb)), uvec4 f1=(packSnorm2x16(base.a,nrm.x), packSnorm2x16(nrm.yz), 0, 0)');
  InfoText.Add('contentLayout(RGB9E5): cell c -> 4 uint at c*4; uvec4=(next, encodeRGB9E5(base), encodeRGB9E5(em), (base.a 8bit)|(octNormal 12+12bit))');

  Stream:=TFileStream.Create(String(aFileName)+'_info.txt',fmCreate);
  try
   InfoText.SaveToStream(Stream);
  finally
   FreeAndNil(Stream);
  end;

  Stream:=TFileStream.Create(String(aFileName)+'_content.bin',fmCreate);
  try
   if length(ContentData)>0 then begin
    Stream.WriteBuffer(ContentData[0],length(ContentData));
   end;
  finally
   FreeAndNil(Stream);
  end;

  Stream:=TFileStream.Create(String(aFileName)+'_meta.bin',fmCreate);
  try
   if length(MetaData)>0 then begin
    Stream.WriteBuffer(MetaData[0],length(MetaData));
   end;
  finally
   FreeAndNil(Stream);
  end;

  pvApplication.Log(LOG_INFO,'TpvScene3DRendererInstance.DumpVoxelConeTracingContent','Dumped '+IntToStr(UsedFragments)+'/'+IntToStr(MaxFragments)+' voxel content fragments to '+String(aFileName)+'_{info.txt,content.bin,meta.bin}');

 finally
  ContentData:=nil;
  MetaData:=nil;
  FreeAndNil(InfoText);
 end;

end;

procedure TpvScene3DRendererInstance.DrawFrame(const aSwapChainImageIndex,aInFlightFrameIndex:TpvInt32;const aFrameCounter:TpvInt64;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
const MinDeltaTime=1.0/480.0; // 480 Hz
      MaxDeltaTime=1.0/1.0; // 1 Hz
      LN2=0.6931471805599453;
var t:TpvDouble;
    CameraPreset:TpvScene3DRendererCameraPreset;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 CameraPreset:=CameraPresets[aInFlightFrameIndex];

 fRawRaytracingFlags:=(TpvUInt32(Min(Max(fRaytracingSoftShadowSampleCount,4),64)-4) and $3f) shl (32-6);
 if TRaytracingFlag.SoftShadows in fRaytracingFlags then begin
  fRawRaytracingFlags:=fRawRaytracingFlags or (TpvUInt32(1) shl 0);
 end;
 if TRaytracingFlag.SphereSolidAngleSampling in fRaytracingFlags then begin
  fRawRaytracingFlags:=fRawRaytracingFlags or (TpvUInt32(1) shl 1);
 end;
 if TRaytracingFlag.EarlyOutSampling in fRaytracingFlags then begin
  fRawRaytracingFlags:=fRawRaytracingFlags or (TpvUInt32(1) shl 2);
 end;

 FillChar(fFrustumClusterGridPushConstants,SizeOf(TpvScene3DRendererInstance.TFrustumClusterGridPushConstants),#0);
 fFrustumClusterGridPushConstants.TileSizeX:=fFrustumClusterGridTileSizeX;
 fFrustumClusterGridPushConstants.TileSizeY:=fFrustumClusterGridTileSizeY;
 fFrustumClusterGridPushConstants.ZNear:=InFlightFrameStates[aInFlightFrameIndex].ZNear;
 fFrustumClusterGridPushConstants.ZFar:=Min(InFlightFrameStates[aInFlightFrameIndex].ZFar,1024.0);
 fFrustumClusterGridPushConstants.ViewRect:=TpvVector4.InlineableCreate(0.0,0.0,fScaledWidth,fScaledHeight);
 fFrustumClusterGridPushConstants.CountLights:=fScene3D.LightBuffers[aInFlightFrameIndex].LightItems.Count;
 fFrustumClusterGridPushConstants.Size:=fFrustumClusterGridSizeX*fFrustumClusterGridSizeY*fFrustumClusterGridSizeZ;
 fFrustumClusterGridPushConstants.OffsetedViewIndex:=fInFlightFrameStates[aInFlightFrameIndex].FinalViewIndex;
 fFrustumClusterGridPushConstants.ClusterSizeX:=fFrustumClusterGridSizeX;
 fFrustumClusterGridPushConstants.ClusterSizeY:=fFrustumClusterGridSizeY;
 fFrustumClusterGridPushConstants.ClusterSizeZ:=fFrustumClusterGridSizeZ;
 fFrustumClusterGridPushConstants.ZScale:=fFrustumClusterGridSizeZ/Log2(fFrustumClusterGridPushConstants.ZFar/fFrustumClusterGridPushConstants.ZNear);
 fFrustumClusterGridPushConstants.ZBias:=-((fFrustumClusterGridSizeZ*Log2(fFrustumClusterGridPushConstants.ZNear))/Log2(fFrustumClusterGridPushConstants.ZFar/fFrustumClusterGridPushConstants.ZNear));
 fFrustumClusterGridPushConstants.ZMax:=fFrustumClusterGridSizeZ-1;
 fFrustumClusterGridPushConstants.CountDecals:=fScene3D.DecalBuffers[aInFlightFrameIndex].DecalItems.Count;

 Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                            fScene3D.VulkanStagingCommandBuffer,
                                            fScene3D.VulkanStagingFence,
                                            fFrustumClusterGridPushConstants,
                                            fFrustumClusterGridGlobalsVulkanBuffers[aInFlightFrameIndex],
                                            0,
                                            SizeOf(TpvScene3DRendererInstance.TFrustumClusterGridPushConstants));

 fLuminancePushConstants.MinMaxLuminanceFactorExponent.x:=fMinimumLuminance;
 fLuminancePushConstants.MinMaxLuminanceFactorExponent.y:=fMaximumLuminance;
 fLuminancePushConstants.MinMaxLuminanceFactorExponent.z:=fLuminanceFactor;
 fLuminancePushConstants.MinMaxLuminanceFactorExponent.w:=fLuminanceExponent;
 fLuminancePushConstants.MinLogLuminance:=CameraPreset.MinLogLuminance;
 fLuminancePushConstants.LogLuminanceRange:=CameraPreset.MaxLogLuminance-CameraPreset.MinLogLuminance;
 fLuminancePushConstants.InverseLogLuminanceRange:=1.0/fLuminancePushConstants.LogLuminanceRange;
 t:=pvApplication.DeltaTime;
 if t<=MinDeltaTime then begin
  t:=MinDeltaTime;
 end else if t>=MaxDeltaTime then begin
  t:=MaxDeltaTime;
 end;
 fLuminancePushConstants.TimeCoefficient:=Clamp(1.0-exp(t*(-TwoPI)),0.025,1.0);
 fLuminancePushConstants.MinLuminance:=exp(LN2*CameraPreset.MinLogLuminance);
 fLuminancePushConstants.MaxLuminance:=exp(LN2*CameraPreset.MaxLogLuminance);
 case CameraPreset.ExposureMode of
  TpvScene3DRendererCameraPreset.TExposureMode.Camera:begin
   CameraPreset.UpdateExposure;
   fLuminancePushConstants.ManualLMax:=CameraPreset.Exposure.LMax;
  end;
  TpvScene3DRendererCameraPreset.TExposureMode.Manual:begin
   fLuminancePushConstants.ManualLMax:=CameraPreset.Exposure.LMax;
  end;
  else{TpvScene3DRendererCameraPreset.TExposureMode.Auto:}begin
   fLuminancePushConstants.ManualLMax:=-1.0;
  end;
 end;
 fLuminancePushConstants.CountPixels:=fScaledWidth*fScaledHeight*fCountSurfaceViews;

 case Renderer.GlobalIlluminationMode of

  TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints:begin

{  TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass.Enabled:=fInFlightFrameMustRenderGIMaps[aInFlightFrameIndex];

   TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass.Enabled:=fInFlightFrameMustRenderGIMaps[aInFlightFrameIndex];}

  end;

  else begin
  end;

 end;

 fFrameGraph.Draw(aSwapChainImageIndex,
                  aInFlightFrameIndex,
                  aFrameCounter,
                  aWaitSemaphore,
                  fVulkanRenderSemaphores[aInFlightFrameIndex],
                  aWaitFence);

 aWaitSemaphore:=fVulkanRenderSemaphores[aInFlightFrameIndex];

 TPasMPInterlocked.Write(fInFlightFrameStates[aInFlightFrameIndex].Ready,false);

end;

procedure TpvScene3DRendererInstance.InitializeSpaceLinesGraphicsPipeline(const aPipeline:TpvVulkanGraphicsPipeline);
begin
 aPipeline.VertexInputState.AddVertexInputBindingDescription(0,SizeOf(TSpaceLinesVertex),VK_VERTEX_INPUT_RATE_VERTEX);
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(0,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PSpaceLinesVertex(nil)^.Position)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(1,0,VK_FORMAT_R32_SFLOAT,TVkPtrUInt(pointer(@PSpaceLinesVertex(nil)^.LineThickness)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(2,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PSpaceLinesVertex(nil)^.Position0)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(3,0,VK_FORMAT_R32_SFLOAT,TVkPtrUInt(pointer(@PSpaceLinesVertex(nil)^.ZMin)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(4,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PSpaceLinesVertex(nil)^.Position1)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(5,0,VK_FORMAT_R32_SFLOAT,TVkPtrUInt(pointer(@PSpaceLinesVertex(nil)^.ZMax)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(6,0,VK_FORMAT_R32G32B32A32_SFLOAT,TVkPtrUInt(pointer(@PSpaceLinesVertex(nil)^.Color)));
end;

procedure TpvScene3DRendererInstance.DrawSpaceLines(const aRendererInstance:TObject;
                                                    const aGraphicsPipeline:TpvVulkanGraphicsPipeline;
                                                    const aPreviousInFlightFrameIndex:TpvSizeInt;
                                                    const aInFlightFrameIndex:TpvSizeInt;
                                                    const aRenderPass:TpvScene3DRendererRenderPass;
                                                    const aViewBaseIndex:TpvSizeInt;
                                                    const aCountViews:TpvSizeInt;
                                                    const aFrameIndex:TpvSizeInt;
                                                    const aCommandBuffer:TpvVulkanCommandBuffer;
                                                    const aPipelineLayout:TpvVulkanPipelineLayout;
                                                    const aOnSetRenderPassResources:TpvScene3D.TOnSetRenderPassResources);
const Offsets:TVkDeviceSize=0;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 if (aViewBaseIndex>=0) and (aCountViews>0) and (fSpaceLinesPrimitiveDynamicArrays[aInFlightFrameIndex].Count>0) then begin

//fScene3D.SetGlobalResources(aCommandBuffer,aPipelineLayout,aRendererInstance,aRenderPass,aPreviousInFlightFrameIndex,aInFlightFrameIndex);

  if assigned(aOnSetRenderPassResources) then begin
   aOnSetRenderPassResources(aCommandBuffer,aPipelineLayout,aRendererInstance,aRenderPass,aPreviousInFlightFrameIndex,aInFlightFrameIndex);
  end;

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,aGraphicsPipeline.Handle);

  aCommandBuffer.CmdBindVertexBuffers(0,1,@fSpaceLinesVertexBuffers[aInFlightFrameIndex].Handle,@Offsets);

  aCommandBuffer.CmdBindIndexBuffer(fSpaceLinesIndexBuffers[aInFlightFrameIndex].Handle,0,VK_INDEX_TYPE_UINT32);

  if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
   fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirect,'SpaceLinesDraw');
  end;
  aCommandBuffer.CmdDrawIndexedIndirect(fSpaceLinesIndirectDrawCommandBuffers[aInFlightFrameIndex].Handle,0,1,SizeOf(TVkDrawIndexedIndirectCommand));
  if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
   fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
  end;

 end;

end;

procedure TpvScene3DRendererInstance.InitializeSolidPrimitiveGraphicsPipeline(const aPipeline:TpvVulkanGraphicsPipeline);
begin
 aPipeline.VertexInputState.AddVertexInputBindingDescription(0,SizeOf(TSolidPrimitiveVertex),VK_VERTEX_INPUT_RATE_VERTEX);
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(0,0,VK_FORMAT_R32G32_SFLOAT,TVkPtrUInt(pointer(@PSolidPrimitiveVertex(nil)^.Position)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(1,0,VK_FORMAT_R32G32_SFLOAT,TVkPtrUInt(pointer(@PSolidPrimitiveVertex(nil)^.Offset0)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(2,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PSolidPrimitiveVertex(nil)^.Position0)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(3,0,VK_FORMAT_R32_UINT,TVkPtrUInt(pointer(@PSolidPrimitiveVertex(nil)^.PrimitiveTopology)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(4,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PSolidPrimitiveVertex(nil)^.Position1)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(5,0,VK_FORMAT_R32_SFLOAT,TVkPtrUInt(pointer(@PSolidPrimitiveVertex(nil)^.LineThicknessorPointSize)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(6,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PSolidPrimitiveVertex(nil)^.Position2)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(7,0,VK_FORMAT_R32_SFLOAT,TVkPtrUInt(pointer(@PSolidPrimitiveVertex(nil)^.InnerRadius)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(8,0,VK_FORMAT_R32G32B32_SFLOAT,TVkPtrUInt(pointer(@PSolidPrimitiveVertex(nil)^.Position3)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(9,0,VK_FORMAT_R32G32_SFLOAT,TVkPtrUInt(pointer(@PSolidPrimitiveVertex(nil)^.Offset1)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(10,0,VK_FORMAT_R32G32_SFLOAT,TVkPtrUInt(pointer(@PSolidPrimitiveVertex(nil)^.Offset2)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(11,0,VK_FORMAT_R32G32_SFLOAT,TVkPtrUInt(pointer(@PSolidPrimitiveVertex(nil)^.Offset3)));
 aPipeline.VertexInputState.AddVertexInputAttributeDescription(12,0,VK_FORMAT_R32G32B32A32_SFLOAT,TVkPtrUInt(pointer(@PSolidPrimitiveVertex(nil)^.Color)));
end;

procedure TpvScene3DRendererInstance.DrawSolidPrimitives(const aRendererInstance:TObject;
                                                         const aGraphicsPipeline:TpvVulkanGraphicsPipeline;
                                                         const aPreviousInFlightFrameIndex:TpvSizeInt;
                                                         const aInFlightFrameIndex:TpvSizeInt;
                                                         const aRenderPass:TpvScene3DRendererRenderPass;
                                                         const aViewBaseIndex:TpvSizeInt;
                                                         const aCountViews:TpvSizeInt;
                                                         const aFrameIndex:TpvSizeInt;
                                                         const aCommandBuffer:TpvVulkanCommandBuffer;
                                                         const aPipelineLayout:TpvVulkanPipelineLayout;
                                                         const aOnSetRenderPassResources:TpvScene3D.TOnSetRenderPassResources);
const Offsets:TVkDeviceSize=0;
begin

 if aInFlightFrameIndex<0 then begin
  exit;
 end;

 if (aViewBaseIndex>=0) and (aCountViews>0) and (fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex].Count>0) then begin

//fScene3D.SetGlobalResources(aCommandBuffer,aPipelineLayout,aRendererInstance,aRenderPass,aPreviousInFlightFrameIndex,aInFlightFrameIndex);

  if assigned(aOnSetRenderPassResources) then begin
   aOnSetRenderPassResources(aCommandBuffer,aPipelineLayout,aRendererInstance,aRenderPass,aPreviousInFlightFrameIndex,aInFlightFrameIndex);
  end;

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,aGraphicsPipeline.Handle);

  aCommandBuffer.CmdBindVertexBuffers(0,1,@fSolidPrimitiveVertexBuffers[aInFlightFrameIndex].Handle,@Offsets);

  aCommandBuffer.CmdBindIndexBuffer(fSolidPrimitiveIndexBuffers[aInFlightFrameIndex].Handle,0,VK_INDEX_TYPE_UINT32);

  if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
   fScene3D.VulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.DrawIndexedIndirect,'SolidPrimitivesDraw');
  end;
  aCommandBuffer.CmdDrawIndexedIndirect(fSolidPrimitiveIndirectDrawCommandBuffers[aInFlightFrameIndex].Handle,0,1,SizeOf(TVkDrawIndexedIndirectCommand));
  if assigned(fScene3D.VulkanDevice.BreadcrumbBuffer) then begin
   fScene3D.VulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
  end;

 end;

end;

// R² sequence as 2D variant - https://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/
function Get2DR2Sequence(const aIndex:TpvInt32):TpvVector2;
const g=TpvDouble(1.32471795724474602596); // The plastic constant, the 2D version of the golden ratio
      a1=TpvDouble(1.0/g);
      a2=TpvDouble(1.0/(g*g));
var x,y:TpvDouble;
begin
 x:=frac((a1*aIndex)+0.5);
 y:=frac((a2*aIndex)+0.5);
 result:=TpvVector2.InlineableCreate(x,y);
end;

procedure InitializeJitterOffsets;
var Index:TpvSizeInt;
begin
 for Index:=0 to CountJitterOffsets-1 do begin
//JitterOffsets[Index]:=TpvVector2.InlineableCreate(GetHaltonSequence(Index+1,2),GetHaltonSequence(Index+1,3));
  JitterOffsets[Index]:=Get2DR2Sequence(Index);
 end;
end;

initialization
 InitializeJitterOffsets;
end.
