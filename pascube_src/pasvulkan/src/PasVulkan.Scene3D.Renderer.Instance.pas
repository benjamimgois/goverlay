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

{$undef UseSphereBasedCascadedShadowMaps}

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
     PasVulkan.Scene3D.Renderer.Globals,
     PasVulkan.Scene3D.Renderer.CameraPreset,
     PasVulkan.Scene3D.Renderer,
     PasVulkan.Scene3D.Renderer.Array2DImage,
     PasVulkan.Scene3D.Renderer.Image2D,
     PasVulkan.Scene3D.Renderer.Image3D,
     PasVulkan.Scene3D.Renderer.MipmappedArray2DImage,
     PasVulkan.Scene3D.Renderer.MipmappedArray3DImage,
     PasVulkan.Scene3D.Renderer.OrderIndependentTransparencyBuffer,
     PasVulkan.Scene3D.Renderer.OrderIndependentTransparencyImage,
     PasVulkan.Scene3D.Renderer.ImageBasedLighting.ReflectionProbeCubeMaps,
     PasVulkan.Scene3D.Renderer.Instance.ColorGrading;

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
             MaxMultiIndirectDrawCalls=65536; //1048576; // as worst case
             InitialCountSolidPrimitives=1 shl 10;
             MaxSolidPrimitives=1 shl 20;
             InitialCountSpaceLines=1 shl 10;
             MaxSpaceLines=1 shl 20;
       type { TInFlightFrameState }
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
            end;
            PFrustumClusterGridPushConstants=^TFrustumClusterGridPushConstants;
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
            TVulkanBuffers=array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
            { TPrepareDrawRenderInstanceFillTask }
            TPrepareDrawRenderInstanceFillTask=record
             FromIndex:TpvSizeInt;
             ToIndex:TpvSizeInt;
             FirstInstanceCommandIndex:TpvSizeInt;
             CountInstances:TpvSizeInt;
             FirstInstanceID:TpvUInt32;
             NodeIndex:TpvSizeInt;
             CountIndices:TpvSizeInt;
             FirstIndex:TpvSizeInt;
             BoundingSphereIndex:TpvUInt32;
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
              type { TCascade }
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
              fVoxels:Boolean;
             public
              constructor Create(const aRendererInstance:TpvScene3DRendererInstance;const aVolumeSize,aCountCascades:TpvSizeInt;const aVoxels:boolean); reintroduce;
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
      public
       fSetGlobalResourcesDone:TpvScene3D.TSetGlobalResourcesDone;
      private
       fViews:TpvScene3DRendererInstance.TViews;
      private
       fPotentiallyVisibleSetViewNodeIndices:array[0..MaxInFlightFrames-1] of TpvScene3D.TPotentiallyVisibleSet.TViewNodeIndices;
       fCountRealViews:array[0..MaxInFlightFrames-1] of TpvInt32;
      private
       fVulkanRenderSemaphores:array[0..MaxInFlightFrames-1] of TpvVulkanSemaphore;
      private
       fInFlightFrameCascadedRadianceHintVolumeImages:TInFlightFrameCascadedRadianceHintVolumeImages;
       fInFlightFrameCascadedRadianceHintVolumeSecondBounceImages:TInFlightFrameCascadedRadianceHintVolumeImages;
       fGlobalIlluminationRadianceHintsUniformBufferDataArray:TGlobalIlluminationRadianceHintsUniformBufferDataArray;
       fGlobalIlluminationRadianceHintsUniformBuffers:TGlobalIlluminationRadianceHintsUniformBuffers;
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
       fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffer:TpvVulkanBuffer;
       fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffer:TpvVulkanBuffer;
       fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages:TGlobalIlluminationCascadedVoxelConeTracingImages;
       fGlobalIlluminationCascadedVoxelConeTracingRadianceImages:TGlobalIlluminationCascadedVoxelConeTracingSideImages;
       fGlobalIlluminationCascadedVoxelConeTracingMaxGlobalFragmentCount:TpvUInt32;
       fGlobalIlluminationCascadedVoxelConeTracingMaxLocalFragmentCount:TpvUInt32;
       fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool:TpvVulkanDescriptorPool;
       fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets:TGlobalIlluminationCascadedVoxelConeTracingDescriptorSets;
       fGlobalIlluminationCascadedVoxelConeTracingDebugVisualization:LongBool;
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
      private
       fCountLockOrderIndependentTransparencyLayers:TpvInt32;
       fLockOrderIndependentTransparentUniformBuffer:TLockOrderIndependentTransparentUniformBuffer;
       fLockOrderIndependentTransparentUniformVulkanBuffer:TpvVulkanBuffer;
       fLockOrderIndependentTransparencyABufferBuffer:TpvScene3DRendererOrderIndependentTransparencyBuffer;
       fLockOrderIndependentTransparencyAuxImage:TpvScene3DRendererOrderIndependentTransparencyImage;
       fLockOrderIndependentTransparencySpinLockImage:TpvScene3DRendererOrderIndependentTransparencyImage;
      private
       fCountLoopOrderIndependentTransparencyLayers:TpvInt32;
       fLoopOrderIndependentTransparentUniformBuffer:TLoopOrderIndependentTransparentUniformBuffer;
       fLoopOrderIndependentTransparentUniformVulkanBuffer:TpvVulkanBuffer;
       fLoopOrderIndependentTransparencyABufferBuffer:TpvScene3DRendererOrderIndependentTransparencyBuffer;
       fLoopOrderIndependentTransparencyZBufferBuffer:TpvScene3DRendererOrderIndependentTransparencyBuffer;
       fLoopOrderIndependentTransparencySBufferBuffer:TpvScene3DRendererOrderIndependentTransparencyBuffer;
      private
       fApproximationOrderIndependentTransparentUniformBuffer:TApproximationOrderIndependentTransparentUniformBuffer;
       fApproximationOrderIndependentTransparentUniformVulkanBuffer:TpvVulkanBuffer;
      private
       fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImage:TpvScene3DRendererOrderIndependentTransparencyImage;
       fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImage:TpvScene3DRendererOrderIndependentTransparencyImage;
       fDeepAndFastApproximateOrderIndependentTransparencyAverageImage:TpvScene3DRendererOrderIndependentTransparencyImage;
       fDeepAndFastApproximateOrderIndependentTransparencyBucketImage:TpvScene3DRendererOrderIndependentTransparencyImage;
       fDeepAndFastApproximateOrderIndependentTransparencySpinLockImage:TpvScene3DRendererOrderIndependentTransparencyImage;
      private
       fCascadedShadowMapCullDepthArray2DImage:TpvScene3DRendererArray2DImage;
       fCascadedShadowMapCullDepthPyramidMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage;
       fCullDepthArray2DImage:TpvScene3DRendererArray2DImage;
       fCullDepthPyramidMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage;
//     fAmbientOcclusionDepthMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage;
       fCombinedDepthArray2DImage:TpvScene3DRendererArray2DImage;
       fDepthMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage;
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
      private
       fVulkanViews:array[0..MaxInFlightFrames-1] of TpvScene3D.TViewUniformBuffer;
       fVulkanViewUniformBuffers:TpvScene3D.TVulkanViewUniformBuffers;
      private
       fMeshCullPass0ComputeVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fMeshCullPass0ComputeVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fMeshCullPass0ComputeVulkanDescriptorSets:TPerInFlightFrameVulkanDescriptorSets;
       fMeshCullPass1ComputeVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fMeshCullPass1ComputeVulkanDescriptorPool:TpvVulkanDescriptorPool;
       fMeshCullPass1ComputeVulkanDescriptorSets:TPerInFlightFrameVulkanDescriptorSets;
       fMeshCullPassDescriptorGeneration:TpvUInt64;
       fMeshCullPassDescriptorGenerations:array[0..MaxInFlightFrames-1] of TpvUInt64;
       fViewBuffersDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fViewBuffersDescriptorPool:TpvVulkanDescriptorPool;
       fViewBuffersDescriptorSets:TPerInFlightFrameVulkanDescriptorSets;
      private
       fDebugTAAMode:TpvUInt32;
      private
       fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandDisocclusionOffsets:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandCounterBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers;
       fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBufferPartSizes:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBufferPartSizes;
       fPerInFlightFrameGPUCulledArray:TpvScene3D.TPerInFlightFrameGPUCulledArray;
       fPerInFlightFrameGPUCountObjectIndicesArray:TpvScene3D.TPerInFlightFrameGPUCountObjectIndicesArray;
       fPointerToPerInFlightFrameGPUCulledArray:TpvScene3D.PPerInFlightFrameGPUCulledArray;
       fDrawChoreographyBatchRangeFrameBuckets:TpvScene3D.TDrawChoreographyBatchRangeFrameBuckets;
       fDrawChoreographyBatchRangeFrameRenderPassBuckets:TpvScene3D.TDrawChoreographyBatchRangeFrameRenderPassBuckets;
      private
       fColorGradingSettings:TpvScene3DRendererInstanceColorGradingSettings;
       fPointerToColorGradingSettings:PpvScene3DRendererInstanceColorGradingSettings;
       fPerInFlightFrameColorGradingSettings:TpvScene3DRendererInstanceColorGradingSettingsArray;
       fPointerToPerInFlightFrameColorGradingSettings:PpvScene3DRendererInstanceColorGradingSettingsArray;
       fColorGradingSettingUniformBuffers:TColorGradingSettingUniformBuffers;
      private
       fSolidPrimitivePrimitiveDynamicArrays:TSolidPrimitivePrimitiveDynamicArrays;
       fSolidPrimitivePrimitiveBuffers:TSolidPrimitiveVulkanBuffers;
       fSolidPrimitiveIndirectDrawCommandBuffer:TpvVulkanBuffer;
       fSolidPrimitiveVertexBuffer:TpvVulkanBuffer;
       fSolidPrimitiveIndexBuffer:TpvVulkanBuffer;
      private
       fSpaceLinesPrimitiveDynamicArrays:TSpaceLinesPrimitiveDynamicArrays;
       fSpaceLinesPrimitiveBuffers:TSpaceLinesVulkanBuffers;
       fSpaceLinesIndirectDrawCommandBuffer:TpvVulkanBuffer;
       fSpaceLinesVertexBuffer:TpvVulkanBuffer;
       fSpaceLinesIndexBuffer:TpvVulkanBuffer;
      private
       fLensRainPostEffectActive:Boolean;
       fLensRainPostEffectFactor:TpvFloat;
       fLensRainPostEffectTime:TpvDouble;
      private
       function GetPixelAmountFactor:TpvDouble;
       procedure SetPixelAmountFactor(const aPixelAmountFactor:TpvDouble);
      private
       procedure CalculateSceneBounds(const aInFlightFrameIndex:TpvInt32);
       procedure CalculateCascadedShadowMaps(const aInFlightFrameIndex:TpvInt32);
       procedure UpdateGlobalIlluminationCascadedRadianceHints(const aInFlightFrameIndex:TpvInt32);
       procedure UploadGlobalIlluminationCascadedRadianceHints(const aInFlightFrameIndex:TpvInt32);
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
       procedure PrepareDraw(const aInFlightFrameIndex:TpvSizeInt;
                             const aRenderPass:TpvScene3DRendererRenderPass;
                             const aMaterialAlphaModes:TpvScene3D.TMaterial.TAlphaModes;
                             const aGPUCulling:boolean);
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
                             const aDisocclusions:boolean);
       procedure PrepareFrame(const aInFlightFrameIndex:TpvInt32;const aFrameCounter:TpvInt64);
       procedure UploadFrame(const aInFlightFrameIndex:TpvInt32);
       procedure ProcessAtmospheresForFrame(const aInFlightFrameIndex:TpvInt32;const aCommandBuffer:TpvVulkanCommandBuffer);
       procedure DrawFrame(const aSwapChainImageIndex,aInFlightFrameIndex:TpvInt32;const aFrameCounter:TpvInt64;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
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
       property InFlightFrameMustRenderGIMaps:TInFlightFrameMustRenderGIMaps read fInFlightFrameMustRenderGIMaps;
      public
       property InFlightFrameCascadedRadianceHintVolumeImages:TInFlightFrameCascadedRadianceHintVolumeImages read fInFlightFrameCascadedRadianceHintVolumeImages;
       property InFlightFrameCascadedRadianceHintSecondBounceVolumeImages:TInFlightFrameCascadedRadianceHintVolumeImages read fInFlightFrameCascadedRadianceHintVolumeSecondBounceImages;
       property GlobalIlluminationRadianceHintsUniformBufferDataArray:TGlobalIlluminationRadianceHintsUniformBufferDataArray read fGlobalIlluminationRadianceHintsUniformBufferDataArray;
       property GlobalIlluminationRadianceHintsUniformBuffers:TGlobalIlluminationRadianceHintsUniformBuffers read fGlobalIlluminationRadianceHintsUniformBuffers;
       property GlobalIlluminationRadianceHintsRSMUniformBufferDataArray:TGlobalIlluminationRadianceHintsRSMUniformBufferDataArray read fGlobalIlluminationRadianceHintsRSMUniformBufferDataArray;
       property GlobalIlluminationRadianceHintsRSMUniformBuffers:TGlobalIlluminationRadianceHintsRSMUniformBuffers read fGlobalIlluminationRadianceHintsRSMUniformBuffers;
       property GlobalIlluminationRadianceHintsDescriptorPool:TpvVulkanDescriptorPool read fGlobalIlluminationRadianceHintsDescriptorPool;
       property GlobalIlluminationRadianceHintsDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fGlobalIlluminationRadianceHintsDescriptorSetLayout;
       property GlobalIlluminationRadianceHintsDescriptorSets:TGlobalIlluminationRadianceHintsDescriptorSets read fGlobalIlluminationRadianceHintsDescriptorSets;
      public
       property GlobalIlluminationCascadedVoxelConeTracingCascadedVolumes:TCascadedVolumes read fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes;
       property GlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray:TGlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray read fGlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray;
       property GlobalIlluminationCascadedVoxelConeTracingUniformBuffers:TGlobalIlluminationCascadedVoxelConeTracingBuffers read fGlobalIlluminationCascadedVoxelConeTracingUniformBuffers;
       property GlobalIlluminationCascadedVoxelConeTracingContentDataBuffer:TpvVulkanBuffer read fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffer;
       property GlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffer:TpvVulkanBuffer read fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffer;
       property GlobalIlluminationCascadedVoxelConeTracingOcclusionImages:TGlobalIlluminationCascadedVoxelConeTracingImages read fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages;
       property GlobalIlluminationCascadedVoxelConeTracingRadianceImages:TGlobalIlluminationCascadedVoxelConeTracingSideImages read fGlobalIlluminationCascadedVoxelConeTracingRadianceImages;
       property GlobalIlluminationCascadedVoxelConeTracingMaxGlobalFragmentCount:TpvUInt32 read fGlobalIlluminationCascadedVoxelConeTracingMaxGlobalFragmentCount write fGlobalIlluminationCascadedVoxelConeTracingMaxGlobalFragmentCount;
       property GlobalIlluminationCascadedVoxelConeTracingMaxLocalFragmentCount:TpvUInt32 read fGlobalIlluminationCascadedVoxelConeTracingMaxLocalFragmentCount write fGlobalIlluminationCascadedVoxelConeTracingMaxLocalFragmentCount;
       property GlobalIlluminationCascadedVoxelConeTracingDescriptorPool:TpvVulkanDescriptorPool read fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool;
       property GlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout;
       property GlobalIlluminationCascadedVoxelConeTracingDescriptorSets:TGlobalIlluminationCascadedVoxelConeTracingDescriptorSets read fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets;
       property GlobalIlluminationCascadedVoxelConeTracingDebugVisualization:LongBool read fGlobalIlluminationCascadedVoxelConeTracingDebugVisualization write fGlobalIlluminationCascadedVoxelConeTracingDebugVisualization;
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
       property LockOrderIndependentTransparentUniformVulkanBuffer:TpvVulkanBuffer read fLockOrderIndependentTransparentUniformVulkanBuffer;
       property LockOrderIndependentTransparencyABufferBuffer:TpvScene3DRendererOrderIndependentTransparencyBuffer read fLockOrderIndependentTransparencyABufferBuffer;
       property LockOrderIndependentTransparencyAuxImage:TpvScene3DRendererOrderIndependentTransparencyImage read fLockOrderIndependentTransparencyAuxImage;
       property LockOrderIndependentTransparencySpinLockImage:TpvScene3DRendererOrderIndependentTransparencyImage read fLockOrderIndependentTransparencySpinLockImage;
      public
       property CountLoopOrderIndependentTransparencyLayers:TpvInt32 read fCountLoopOrderIndependentTransparencyLayers;
       property LoopOrderIndependentTransparentUniformBuffer:TLoopOrderIndependentTransparentUniformBuffer read fLoopOrderIndependentTransparentUniformBuffer;
       property LoopOrderIndependentTransparentUniformVulkanBuffer:TpvVulkanBuffer read fLoopOrderIndependentTransparentUniformVulkanBuffer;
       property LoopOrderIndependentTransparencyABufferBuffer:TpvScene3DRendererOrderIndependentTransparencyBuffer read fLoopOrderIndependentTransparencyABufferBuffer;
       property LoopOrderIndependentTransparencyZBufferBuffer:TpvScene3DRendererOrderIndependentTransparencyBuffer read fLoopOrderIndependentTransparencyZBufferBuffer;
       property LoopOrderIndependentTransparencySBufferBuffer:TpvScene3DRendererOrderIndependentTransparencyBuffer read fLoopOrderIndependentTransparencySBufferBuffer;
      public
       property ApproximationOrderIndependentTransparentUniformBuffer:TApproximationOrderIndependentTransparentUniformBuffer read fApproximationOrderIndependentTransparentUniformBuffer;
       property ApproximationOrderIndependentTransparentUniformVulkanBuffer:TpvVulkanBuffer read fApproximationOrderIndependentTransparentUniformVulkanBuffer;
      public
       property DeepAndFastApproximateOrderIndependentTransparencyFragmentCounterFragmentDepthsSampleMaskImage:TpvScene3DRendererOrderIndependentTransparencyImage read fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImage;
       property DeepAndFastApproximateOrderIndependentTransparencyAccumulationImage:TpvScene3DRendererOrderIndependentTransparencyImage read fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImage;
       property DeepAndFastApproximateOrderIndependentTransparencyAverageImage:TpvScene3DRendererOrderIndependentTransparencyImage read fDeepAndFastApproximateOrderIndependentTransparencyAverageImage;
       property DeepAndFastApproximateOrderIndependentTransparencyBucketImage:TpvScene3DRendererOrderIndependentTransparencyImage read fDeepAndFastApproximateOrderIndependentTransparencyBucketImage;
       property DeepAndFastApproximateOrderIndependentTransparencySpinLockImage:TpvScene3DRendererOrderIndependentTransparencyImage read fDeepAndFastApproximateOrderIndependentTransparencySpinLockImage;
      public
       property CascadedShadowMapCullDepthArray2DImage:TpvScene3DRendererArray2DImage read fCascadedShadowMapCullDepthArray2DImage;
       property CascadedShadowMapCullDepthPyramidMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage read fCascadedShadowMapCullDepthPyramidMipmappedArray2DImage;
       property CullDepthArray2DImage:TpvScene3DRendererArray2DImage read fCullDepthArray2DImage;
       property CullDepthPyramidMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage read fCullDepthPyramidMipmappedArray2DImage;
//     property AmbientOcclusionDepthMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage read fAmbientOcclusionDepthMipmappedArray2DImage;
       property CombinedDepthArray2DImage:TpvScene3DRendererArray2DImage read fCombinedDepthArray2DImage;
       property DepthMipmappedArray2DImage:TpvScene3DRendererMipmappedArray2DImage read fDepthMipmappedArray2DImage;
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
       property MeshCullPass1ComputeVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fMeshCullPass1ComputeVulkanDescriptorSetLayout;
       property MeshCullPass1ComputeVulkanDescriptorSets:TPerInFlightFrameVulkanDescriptorSets read fMeshCullPass1ComputeVulkanDescriptorSets;
       property ViewBuffersDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fViewBuffersDescriptorSetLayout;
       property ViewBuffersDescriptorSets:TPerInFlightFrameVulkanDescriptorSets read fViewBuffersDescriptorSets;
      public
       property DebugTAAMode:TpvUInt32 read fDebugTAAMode write fDebugTAAMode;
      public
       property SolidPrimitivePrimitiveDynamicArrays:TSolidPrimitivePrimitiveDynamicArrays read fSolidPrimitivePrimitiveDynamicArrays;
       property SolidPrimitivePrimitiveBuffers:TSolidPrimitiveVulkanBuffers read fSolidPrimitivePrimitiveBuffers;
       property SolidPrimitiveIndirectDrawCommandBuffer:TpvVulkanBuffer read fSolidPrimitiveIndirectDrawCommandBuffer;
       property SolidPrimitiveVertexBuffer:TpvVulkanBuffer read fSolidPrimitiveVertexBuffer;
       property SolidPrimitiveIndexBuffer:TpvVulkanBuffer read fSolidPrimitiveIndexBuffer;
      public
       property SpaceLinesPrimitiveDynamicArrays:TSpaceLinesPrimitiveDynamicArrays read fSpaceLinesPrimitiveDynamicArrays;
       property SpaceLinesPrimitiveBuffers:TSpaceLinesVulkanBuffers read fSpaceLinesPrimitiveBuffers;
       property SpaceLinesIndirectDrawCommandBuffer:TpvVulkanBuffer read fSpaceLinesIndirectDrawCommandBuffer;
       property SpaceLinesVertexBuffer:TpvVulkanBuffer read fSpaceLinesVertexBuffer;
       property SpaceLinesIndexBuffer:TpvVulkanBuffer read fSpaceLinesIndexBuffer;
      public
       property LensRainPostEffectActive:Boolean read fLensRainPostEffectActive write fLensRainPostEffectActive;
       property LensRainPostEffectFactor:TpvFloat read fLensRainPostEffectFactor write fLensRainPostEffectFactor;
       property LensRainPostEffectTime:TpvDouble read fLensRainPostEffectTime write fLensRainPostEffectTime;
      public
       property PerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays read fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays write fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays;
       property PerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues read fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes;
       property PerInFlightFrameGPUDrawIndexedIndirectCommandDisocclusionOffsets:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandSizeValues read fPerInFlightFrameGPUDrawIndexedIndirectCommandDisocclusionOffsets;
       property PerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers read fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers;
       property PerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers read fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers;
       property PerInFlightFrameGPUDrawIndexedIndirectCommandCounterBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers read fPerInFlightFrameGPUDrawIndexedIndirectCommandCounterBuffers;
       property PerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBuffers read fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers;
       property PerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBufferPartSizes:TpvScene3D.TPerInFlightFrameGPUDrawIndexedIndirectCommandBufferPartSizes read fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBufferPartSizes;
       property PerInFlightFrameGPUCulledArray:TpvScene3D.TPerInFlightFrameGPUCulledArray read fPerInFlightFrameGPUCulledArray;
       property PerInFlightFrameGPUCountObjectIndicesArray:TpvScene3D.TPerInFlightFrameGPUCountObjectIndicesArray read fPerInFlightFrameGPUCountObjectIndicesArray;
       property DrawChoreographyBatchRangeFrameBuckets:TpvScene3D.TDrawChoreographyBatchRangeFrameBuckets read fDrawChoreographyBatchRangeFrameBuckets write fDrawChoreographyBatchRangeFrameBuckets;
       property DrawChoreographyBatchRangeFrameRenderPassBuckets:TpvScene3D.TDrawChoreographyBatchRangeFrameRenderPassBuckets read fDrawChoreographyBatchRangeFrameRenderPassBuckets write fDrawChoreographyBatchRangeFrameRenderPassBuckets;
      public
       property ColorGradingSettings:PpvScene3DRendererInstanceColorGradingSettings read fPointerToColorGradingSettings;
       property PerInFlightFrameColorGradingSettings:PpvScene3DRendererInstanceColorGradingSettingsArray read fPointerToPerInFlightFrameColorGradingSettings;
       property ColorGradingSettingUniformBuffers:TColorGradingSettingUniformBuffers read fColorGradingSettingUniformBuffers;
      published
       property Scene3D:TpvScene3D read fScene3D;
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
      published
       property Left:TpvInt32 read fLeft write fLeft;
       property Top:TpvInt32 read fTop write fTop;
       property Width:TpvInt32 read fWidth write fWidth;
       property Height:TpvInt32 read fHeight write fHeight;
       property HUDWidth:TpvInt32 read fHUDWidth write fHUDWidth;
       property HUDHeight:TpvInt32 read fHUDHeight write fHUDHeight;
       property ScaledWidth:TpvInt32 read fScaledWidth;
       property ScaledHeight:TpvInt32 read fScaledHeight;
       property CountSurfaceViews:TpvInt32 read fCountSurfaceViews write fCountSurfaceViews;
       property SurfaceMultiviewMask:TpvUInt32 read fSurfaceMultiviewMask write fSurfaceMultiviewMask;
       property ZNear:TpvFloat read fZNear write fZNear;
       property ZFar:TpvFloat read fZFar write fZFar;
       property PixelAmountFactor:TpvDouble read GetPixelAmountFactor write SetPixelAmountFactor;
       property SizeFactor:TpvDouble read fSizeFactor write fSizeFactor;
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
     PasVulkan.Scene3D.Renderer.Passes.MeshCullPass0ComputePass,
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
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedRadianceHintsClearCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedRadianceHintsInjectCachedComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedRadianceHintsInjectSkyComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedRadianceHintsInjectRSMComputePass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedRadianceHintsInjectFinalizationCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationCascadedRadianceHintsBounceComputePass,
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
     PasVulkan.Scene3D.Renderer.Passes.AtmosphereRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.RainRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.ForwardResolveRenderPass,
     PasVulkan.Scene3D.Renderer.Passes.ForwardRenderMipMapComputePass,
     PasVulkan.Scene3D.Renderer.Passes.WaterWaitCustomPass,
     PasVulkan.Scene3D.Renderer.Passes.WaterRenderPass,
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
       fMeshCullPass0ComputePass:TpvScene3DRendererPassesMeshCullPass0ComputePass;
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
       fGlobalIlluminationCascadedRadianceHintsClearCustomPass:TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsClearCustomPass;
       fGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass:TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass;
       fGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass:TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass;
       fGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass:TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass;
       fGlobalIlluminationCascadedRadianceHintsInjectFinalizationCustomPass:TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectFinalizationCustomPass;
       fGlobalIlluminationCascadedRadianceHintsBounceComputePass:TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass;
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
       fAtmosphereRenderPass:TpvScene3DRendererPassesAtmosphereRenderPass;
       fRainRenderPass:TpvScene3DRendererPassesRainRenderPass;
       fForwardResolveRenderPass:TpvScene3DRendererPassesForwardResolveRenderPass;
       fWaterWaitCustomPass:TpvScene3DRendererPassesWaterWaitCustomPass;
       fWaterRenderPass:TpvScene3DRendererPassesWaterRenderPass;
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

constructor TpvScene3DRendererInstance.TCascadedVolumes.Create(const aRendererInstance:TpvScene3DRendererInstance;const aVolumeSize,aCountCascades:TpvSizeInt;const aVoxels:Boolean);
var CascadeIndex:TpvSizeInt;
begin

 inherited Create;

 fRendererInstance:=aRendererInstance;

 fVolumeSize:=aVolumeSize;

 fCountCascades:=aCountCascades;

 fVoxels:=aVoxels;

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

 if fVoxels then begin
  MaxAxisSize:=MaxAxisSize*1.25;
 end;

 MaximumCascadeCellSize:=Max(1e-6,MaxAxisSize/fVolumeSize);

 if fVoxels then begin
  MaximumCascadeCellSize:=Ceil(MaximumCascadeCellSize/(1 shl fCountCascades))*(1 shl fCountCascades);
 end else begin
  MaximumCascadeCellSize:=Ceil(MaximumCascadeCellSize);
 end;

 CellSize:=1;

 for CascadeIndex:=0 to fCountCascades-1 do begin

  Cascade:=fCascades[CascadeIndex];

  if fVoxels then begin
{  if CascadeIndex=(fCountCascades-1) then begin
    CellSize:=MaximumCascadeCellSize;
   end else}if CascadeIndex=0 then begin
    CellSize:=Min(0.125,MaximumCascadeCellSize);
   end else begin
    CellSize:=Min(CellSize*2.0,MaximumCascadeCellSize);//}
{  end else begin
    CellSize:=MaximumCascadeCellSize/Power(2.0,fCountCascades-(CascadeIndex+1));//}
   end;
  end else begin
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

{ if (CellSize and 1)<>0 then begin
   inc(CellSize);
  end;}

//CellSize:=0.5;

  if fVoxels then begin
   SnapSize:=CellSize*2.0;
  end else begin
   SnapSize:=CellSize;
  end;

  SnappedPosition:=(GridCenter/SnapSize).Round*SnapSize;

  GridSize:=TpvVector3.InlineableCreate(fVolumeSize*CellSize,fVolumeSize*CellSize,fVolumeSize*CellSize);

  BorderCells:=fCountCascades-CascadeIndex;

  ClampedSceneAABB.Max:=TpvVector3.InlineableCreate(SceneAABB.Max+(GridSize*0.5)).Max(SceneAABB.Min+(GridSize*0.5));
  ClampedSceneAABB.Min:=TpvVector3.InlineableCreate(SceneAABB.Min+(GridSize*0.5)).Min(ClampedSceneAABB.Max);

  SnappedPosition:=(SnappedPosition.Max(ClampedSceneAABB.Min)).Min(ClampedSceneAABB.Max);

  if fVoxels then begin
   AABB.Min:=SnappedPosition-(GridSize*0.5);
   AABB.Max:=AABB.Min+GridSize;
  end else begin
   AABB.Min:=TpvVector3.InlineableCreate((SnappedPosition-(GridSize*0.5))/SnapSize).Floor*SnapSize;
   AABB.Max:=AABB.Min+GridSize;
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
var InFlightFrameIndex:TpvSizeInt;
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

 fHUDCustomPassClass:=nil;

 fHUDCustomPassParent:=nil;

 fHUDComputePassClass:=nil;

 fHUDComputePassParent:=nil;

 fHUDRenderPassClass:=nil;

 fHUDRenderPassParent:=nil;

 fSizeFactor:=1.0;

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

 fSolidPrimitiveIndirectDrawCommandBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
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
                                                                  'fSolidPrimitiveIndirectDrawCommandBuffer');

 fSolidPrimitiveVertexBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
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
                                                     'fSolidPrimitiveVertexBuffer');

 fSolidPrimitiveIndexBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
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
                                                    'fSolidPrimitiveIndexBuffer');

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

 fSpaceLinesIndirectDrawCommandBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
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
                                                              'fSpaceLinesIndirectDrawCommandBuffer');

 fSpaceLinesVertexBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
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
                                                 'fSpaceLinesVertexBuffer');

 fSpaceLinesIndexBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
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
                                                'fSpaceLinesIndexBuffer');

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
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  fVulkanRenderSemaphores[InFlightFrameIndex]:=TpvVulkanSemaphore.Create(Renderer.VulkanDevice);
 end;

 FillChar(fCascadedShadowMapVulkanUniformBuffers,SizeOf(TCascadedShadowMapVulkanUniformBuffers),#0);

 FillChar(fInFlightFrameCascadedRadianceHintVolumeImages,SizeOf(TInFlightFrameCascadedRadianceHintVolumeImages),#0);

 FillChar(fInFlightFrameCascadedRadianceHintVolumeSecondBounceImages,SizeOf(TInFlightFrameCascadedRadianceHintVolumeImages),#0);

 FillChar(fGlobalIlluminationRadianceHintsUniformBuffers,SizeOf(TGlobalIlluminationRadianceHintsUniformBuffers),#0);

 FillChar(fGlobalIlluminationRadianceHintsRSMUniformBuffers,SizeOf(TGlobalIlluminationRadianceHintsRSMUniformBuffers),#0);

 FillChar(fGlobalIlluminationRadianceHintsEvents,SizeOf(fGlobalIlluminationRadianceHintsEvents),#0);

 fGlobalIlluminationRadianceHintsCascadedVolumes:=nil;

 FillChar(fGlobalIlluminationRadianceHintsDescriptorSets,SizeOf(TGlobalIlluminationRadianceHintsDescriptorSets),#0);

 fGlobalIlluminationRadianceHintsDescriptorPool:=nil;

 fGlobalIlluminationRadianceHintsDescriptorSetLayout:=nil;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  fGlobalIlluminationRadianceHintsFirsts[InFlightFrameIndex]:=true;
 end;

 fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes:=nil;

 FillChar(fGlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray,SizeOf(TGlobalIlluminationCascadedVoxelConeTracingUniformBufferDataArray),#0);

 FillChar(fGlobalIlluminationCascadedVoxelConeTracingUniformBuffers,SizeOf(TGlobalIlluminationCascadedVoxelConeTracingBuffers),#0);

 fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffer:=nil;

 fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffer:=nil;

 FillChar(fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages,SizeOf(TGlobalIlluminationCascadedVoxelConeTracingImages),#0);

 FillChar(fGlobalIlluminationCascadedVoxelConeTracingRadianceImages,SizeOf(TGlobalIlluminationCascadedVoxelConeTracingSideImages),#0);

 FillChar(fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets,SizeOf(TGlobalIlluminationCascadedVoxelConeTracingDescriptorSets),#0);

 fGlobalIlluminationCascadedVoxelConeTracingDebugVisualization:=false;

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

 case Renderer.TransparencyMode of
  TpvScene3DRendererTransparencyMode.SPINLOCKOIT,
  TpvScene3DRendererTransparencyMode.INTERLOCKOIT:begin
   fLockOrderIndependentTransparentUniformVulkanBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
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
                                                                               'TpvScene3DRendererInstance.fLockOrderIndependentTransparentUniformVulkanBuffer');
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparentUniformVulkanBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLockOrderIndependentTransparentUniformVulkanBuffer');
  end;
  TpvScene3DRendererTransparencyMode.LOOPOIT:begin
   fLoopOrderIndependentTransparentUniformVulkanBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
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
                                                                               'TpvScene3DRendererInstance.fLoopOrderIndependentTransparentUniformVulkanBuffer');
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fLoopOrderIndependentTransparentUniformVulkanBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLoopOrderIndependentTransparentUniformVulkanBuffer');
  end;
  TpvScene3DRendererTransparencyMode.WBOIT,
  TpvScene3DRendererTransparencyMode.MBOIT:begin
   fApproximationOrderIndependentTransparentUniformVulkanBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
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
                                                                                        'TpvScene3DRendererInstance.fApproximationOrderIndependentTransparentUniformVulkanBuffer');
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fApproximationOrderIndependentTransparentUniformVulkanBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fApproximationOrderIndependentTransparentUniformVulkanBuffer');
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
var InFlightFrameIndex,CascadeIndex,ImageIndex:TpvSizeInt;
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

 FreeAndNil(fSolidPrimitiveIndirectDrawCommandBuffer);

 FreeAndNil(fSolidPrimitiveVertexBuffer);

 FreeAndNil(fSolidPrimitiveIndexBuffer);

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fSpaceLinesPrimitiveDynamicArrays[InFlightFrameIndex]);
  FreeAndNil(fSpaceLinesPrimitiveBuffers[InFlightFrameIndex]);
 end;

 FreeAndNil(fSpaceLinesIndirectDrawCommandBuffer);

 FreeAndNil(fSpaceLinesVertexBuffer);

 FreeAndNil(fSpaceLinesIndexBuffer);

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  fViews[InFlightFrameIndex].Finalize;
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
  end;
 end;

 for InFlightFrameIndex:=0 to Renderer.CountInFlightFrames-1 do begin
  FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingEvents[InFlightFrameIndex]);
 end;

 FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffer);

 FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffer);

 FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingCascadedVolumes);

 FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool);

 FreeAndNil(fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout);

 FreeAndNil(fImageBasedLightingReflectionProbeCubeMaps);

 case Renderer.TransparencyMode of
  TpvScene3DRendererTransparencyMode.SPINLOCKOIT,
  TpvScene3DRendererTransparencyMode.INTERLOCKOIT:begin
   FreeAndNil(fLockOrderIndependentTransparentUniformVulkanBuffer);
  end;
  TpvScene3DRendererTransparencyMode.LOOPOIT:begin
   FreeAndNil(fLoopOrderIndependentTransparentUniformVulkanBuffer);
  end;
  TpvScene3DRendererTransparencyMode.WBOIT,
  TpvScene3DRendererTransparencyMode.MBOIT:begin
   FreeAndNil(fApproximationOrderIndependentTransparentUniformVulkanBuffer);
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

 inherited Destroy;
end;

procedure TpvScene3DRendererInstance.AfterConstruction;
begin
 inherited AfterConstruction;
 if assigned(fScene3D) and assigned(fScene3D.RendererInstanceLock) and assigned(fScene3D.RendererInstanceList) then begin
  fScene3D.RendererInstanceLock.Acquire;
  try
   fScene3D.RendererInstanceList.Add(self);
  finally
   fScene3D.RendererInstanceLock.Release;
  end;
 end;
end;

procedure TpvScene3DRendererInstance.BeforeDestruction;
begin
 if assigned(fScene3D) and assigned(fScene3D.RendererInstanceLock) and assigned(fScene3D.RendererInstanceList) then begin
  fScene3D.RendererInstanceLock.Acquire;
  try
   fScene3D.RendererInstanceList.RemoveWithoutFree(self);
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

procedure TpvScene3DRendererInstance.CheckSolidPrimitives(const aInFlightFrameIndex:TpvInt32);
var Size:TVkSize;
    CountSolidPrimitives:TpvSizeInt;
begin

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
 if fSolidPrimitiveVertexBuffer.Size<Size then begin
  Size:=((CountSolidPrimitives+((CountSolidPrimitives+1) shr 1))*4)*SizeOf(TSolidPrimitiveVertex);
  fScene3D.AddToFreeQueue(fSolidPrimitiveVertexBuffer); // Free old buffer delayed due to possible usage in the current moment
  fSolidPrimitiveVertexBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
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
                                                      'fSolidPrimitiveVertexBuffer');
 end;

 Size:=(CountSolidPrimitives*6)*SizeOf(TSolidPrimitiveIndex);
 if fSolidPrimitiveIndexBuffer.Size<Size then begin
  Size:=((CountSolidPrimitives+((CountSolidPrimitives+1) shr 1))*6)*SizeOf(TSolidPrimitiveIndex);
  fScene3D.AddToFreeQueue(fSolidPrimitiveIndexBuffer); // Free old buffer delayed due to possible usage in the current moment
  fSolidPrimitiveIndexBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
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
                                                     'fSolidPrimitiveIndexBuffer');
 end;

end;

procedure TpvScene3DRendererInstance.CheckSpaceLines(const aInFlightFrameIndex:TpvInt32);
var Size:TVkSize;
    CountSpaceLines:TpvSizeInt;
begin

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
 if fSpaceLinesVertexBuffer.Size<Size then begin
  Size:=((CountSpaceLines+((CountSpaceLines+1) shr 1))*4)*SizeOf(TSpaceLinesVertex);
  fScene3D.AddToFreeQueue(fSpaceLinesVertexBuffer); // Free old buffer delayed due to possible usage in the current moment
  fSpaceLinesVertexBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
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
                                                  'fSpaceLinesVertexBuffer');
 end;

 Size:=(CountSpaceLines*6)*SizeOf(TSpaceLinesIndex);
 if fSpaceLinesIndexBuffer.Size<Size then begin
  Size:=((CountSpaceLines+((CountSpaceLines+1) shr 1))*6)*SizeOf(TSpaceLinesIndex);
  fScene3D.AddToFreeQueue(fSpaceLinesIndexBuffer); // Free old buffer delayed due to possible usage in the current moment
  fSpaceLinesIndexBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
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
                                                 'fSpaceLineIndexBuffer');
 end;

end;

procedure TpvScene3DRendererInstance.Prepare;
var AntialiasingFirstPass:TpvFrameGraph.TPass;
    AntialiasingLastPass:TpvFrameGraph.TPass;
    PreLastPass:TpvFrameGraph.TPass;
    LastPass:TpvFrameGraph.TPass;
    InFlightFrameIndex,CascadeIndex,ImageIndex,Index:TpvSizeInt;
    Format:TVkFormat;
    GlobalIlluminationRadianceHintsSHTextureDescriptorInfoArray:TVkDescriptorImageInfoArray;
    GlobalIlluminationVoxelConeTracingOcclusionTextureDescriptorInfoArray:TVkDescriptorImageInfoArray;
    GlobalIlluminationVoxelConeTracingRadianceTextureDescriptorInfoArray:TVkDescriptorImageInfoArray;
begin

 case Renderer.GlobalIlluminationMode of

  TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints:begin

   fGlobalIlluminationRadianceHintsCascadedVolumes:=TCascadedVolumes.Create(self,
                                                                            GlobalIlluminationRadiantHintVolumeSize,
                                                                            CountGlobalIlluminationRadiantHintCascades,
                                                                            false);

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
                                                                                       true);

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

   fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                        fGlobalIlluminationCascadedVoxelConeTracingMaxGlobalFragmentCount*(SizeOf(TpvUInt32)*8),
                                                                                        TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
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
                                                                                        'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffer');
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingContentDataBuffer');

   fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffer:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                            ((Renderer.GlobalIlluminationVoxelCountCascades*
                                                                                              (Renderer.GlobalIlluminationVoxelGridSize*
                                                                                               Renderer.GlobalIlluminationVoxelGridSize*
                                                                                               Renderer.GlobalIlluminationVoxelGridSize))+1)*(SizeOf(TpvUInt32)*2),
                                                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
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
                                                                                            'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffer');
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingContentMetaDataBuffer');

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
                                                                                                                                        'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingRadianceImages['+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+']');
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingRadianceImages[CascadeIndex,ImageIndex].VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingRadianceImages['+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+'].Image');
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingRadianceImages[CascadeIndex,ImageIndex].VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingRadianceImages['+IntToStr(CascadeIndex)+','+IntToStr(ImageIndex)+'].ImageView');

    end;

   end;

   fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool:=TpvVulkanDescriptorPool.Create(Renderer.VulkanDevice,
                                                                                             TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                                             Renderer.CountInFlightFrames);
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,Renderer.CountInFlightFrames);
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,Renderer.CountInFlightFrames*Renderer.GlobalIlluminationVoxelCountCascades*(6+1));
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool.Initialize;
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingDescriptorPool');

   fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(Renderer.VulkanDevice);
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout.AddBinding(0,
                                                                             VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                                                             1,
                                                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                                             []);
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout.AddBinding(1,
                                                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                                             Renderer.GlobalIlluminationVoxelCountCascades,
                                                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                                             []);
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout.AddBinding(2,
                                                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                                             Renderer.GlobalIlluminationVoxelCountCascades*6,
                                                                             TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) or TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                                             []);
   fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout.Initialize;
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingDescriptorSetLayout');

   GlobalIlluminationVoxelConeTracingOcclusionTextureDescriptorInfoArray:=nil;
   GlobalIlluminationVoxelConeTracingRadianceTextureDescriptorInfoArray:=nil;

   try

    SetLength(GlobalIlluminationVoxelConeTracingOcclusionTextureDescriptorInfoArray,Renderer.GlobalIlluminationVoxelCountCascades);
    SetLength(GlobalIlluminationVoxelConeTracingRadianceTextureDescriptorInfoArray,Renderer.GlobalIlluminationVoxelCountCascades*6);

    for CascadeIndex:=0 to Renderer.GlobalIlluminationVoxelCountCascades-1 do begin

     GlobalIlluminationVoxelConeTracingOcclusionTextureDescriptorInfoArray[CascadeIndex]:=TVkDescriptorImageInfo.Create(Renderer.ClampedSampler.Handle,
                                                                                                                        fGlobalIlluminationCascadedVoxelConeTracingOcclusionImages[CascadeIndex].VulkanImageView.Handle,
                                                                                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);


     for ImageIndex:=0 to 5 do begin

      GlobalIlluminationVoxelConeTracingRadianceTextureDescriptorInfoArray[(CascadeIndex*6)+ImageIndex]:=TVkDescriptorImageInfo.Create(Renderer.ClampedSampler.Handle,
                                                                                                                                       fGlobalIlluminationCascadedVoxelConeTracingRadianceImages[CascadeIndex,ImageIndex].VulkanImageView.Handle,
                                                                                                                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);


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
     fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets[InFlightFrameIndex].Flush;

     Renderer.VulkanDevice.DebugUtils.SetObjectName(fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TpvScene3DRendererInstance.fGlobalIlluminationCascadedVoxelConeTracingDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

    end;

   finally
    GlobalIlluminationVoxelConeTracingOcclusionTextureDescriptorInfoArray:=nil;
    GlobalIlluminationVoxelConeTracingRadianceTextureDescriptorInfoArray:=nil;
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
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT),
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

 fFrameGraph.AddImageResourceType('resourcetype_color_fullres_optimized_non_alpha',
                                  false,
                                  VK_FORMAT_R16G16B16A16_SFLOAT,//Renderer.OptimizedNonAlphaFormat,
                                  TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT),
                                  TpvFrameGraph.TImageType.Color,
                                  TpvFrameGraph.TImageSize.Create(TpvFrameGraph.TImageSize.TKind.SurfaceDependent,1.0,1.0,1.0,fCountSurfaceViews),
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
                                  1
                                 );

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
                                  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) or TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT),
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

 if Renderer.GPUCulling and Renderer.GPUShadowCulling then begin

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
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass);
   end;
{  if Renderer.EarlyDepthPrepassNeeded then begin
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
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fCascadedShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass);
   end;
{  if Renderer.EarlyDepthPrepassNeeded then begin
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

 if Renderer.GPUCulling then begin

  TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass:=TpvScene3DRendererPassesMeshCullPass0ComputePass.Create(fFrameGraph,self,TpvScene3DRendererCullRenderPass.FinalView);
  TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass0ComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
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

 end else begin

  TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass:=nil;

 end;

 if Renderer.EarlyDepthPrepassNeeded then begin

  TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass:=TpvScene3DRendererPassesDepthPrepassRenderPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
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
 TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridBuildComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridBuildComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass);
 end;
 if Renderer.EarlyDepthPrepassNeeded then begin
  TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridBuildComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
 end;

 TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridAssignComputePass:=TpvScene3DRendererPassesFrustumClusterGridAssignComputePass.Create(fFrameGraph,self);
 TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridAssignComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fFrustumClusterGridBuildComputePass);

 TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingFinalizationCustomPass:=nil;

 case Renderer.GlobalIlluminationMode of

  TpvScene3DRendererGlobalIlluminationMode.CascadedRadianceHints:begin

   TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass:=TpvScene3DRendererPassesTopDownSkyOcclusionMapRenderPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
{  TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
   end;}
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass);
   end;
   if Renderer.EarlyDepthPrepassNeeded then begin
    TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass);
    TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   end;

{  TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapResolveRenderPass:=TpvScene3DRendererPassesTopDownSkyOcclusionMapResolveRenderPass.Create(fFrameGraph,self);

   TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapBlurRenderPasses[0]:=TpvScene3DRendererPassesTopDownSkyOcclusionMapBlurRenderPass.Create(fFrameGraph,self,true);

   TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapBlurRenderPasses[1]:=TpvScene3DRendererPassesTopDownSkyOcclusionMapBlurRenderPass.Create(fFrameGraph,self,false);}

   TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass:=TpvScene3DRendererPassesReflectiveShadowMapRenderPass.Create(fFrameGraph,self);
{  TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
   end;}
   TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass); //TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapBlurRenderPasses[1]);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsClearCustomPass:=TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsClearCustomPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass:=TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsClearCustomPass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass:=TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fTopDownSkyOcclusionMapRenderPass);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass);
   if Renderer.EarlyDepthPrepassNeeded then begin
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   end;
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass:=TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass);
   if Renderer.EarlyDepthPrepassNeeded then begin
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   end;
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectCachedComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectSkyComputePass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectFinalizationCustomPass:=TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsInjectFinalizationCustomPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectFinalizationCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectRSMComputePass);

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsBounceComputePass:=TpvScene3DRendererPassesGlobalIlluminationCascadedRadianceHintsBounceComputePass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsBounceComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedRadianceHintsInjectFinalizationCustomPass);

  end;

  TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing:begin

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass:=TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
{  TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
   end;}
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass);
   end;
   if Renderer.EarlyDepthPrepassNeeded then begin
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass);
    TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   end;

   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass:=TpvScene3DRendererPassesGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaVoxelizationRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fGlobalIlluminationCascadedVoxelConeTracingMetaClearCustomPass);

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

  end;

  else begin
   TpvScene3DRendererInstancePasses(fPasses).fReflectiveShadowMapRenderPass:=nil;
  end;

 end;

 if Renderer.ScreenSpaceAmbientOcclusion then begin

 {TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionDepthMipMapComputePass:=TpvScene3DRendererPassesAmbientOcclusionDepthMipMapComputePass.Create(fFrameGraph,self);
  if Renderer.EarlyDepthPrepassNeeded then begin
   TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionDepthMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass);
  end;//}

  TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionRenderPass:=TpvScene3DRendererPassesAmbientOcclusionRenderPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
//TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionDepthMipMapComputePass);
  if Renderer.EarlyDepthPrepassNeeded then begin
   TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
  end;
{ if assigned(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass) then begin
   TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRaytracingBuildUpdatePass);
  end;}

  TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionBlurRenderPasses[0]:=TpvScene3DRendererPassesAmbientOcclusionBlurRenderPass.Create(fFrameGraph,self,true);

  TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionBlurRenderPasses[1]:=TpvScene3DRendererPassesAmbientOcclusionBlurRenderPass.Create(fFrameGraph,self,false);

 end;

 case Renderer.GlobalIlluminationMode of

  TpvScene3DRendererGlobalIlluminationMode.CameraReflectionProbe:begin

   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass:=TpvScene3DRendererPassesReflectionProbeRenderPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
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
   if assigned(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass) then begin
    TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshCullPass1ComputePass);
   end;

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
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeRenderPass:=nil;
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassGGX:=nil;
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassCharlie:=nil;
   TpvScene3DRendererInstancePasses(fPasses).fReflectionProbeComputePassLambertian:=nil;
  end;

 end;

 if Renderer.WetnessMapActive then begin
  TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass:=TpvScene3DRendererPassesWetnessMapComputePass.Create(fFrameGraph,self);
  if Renderer.EarlyDepthPrepassNeeded then begin
   TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthPrepassRenderPass);
   TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
  end;
 end else begin
  TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass:=nil;
 end;

 TpvScene3DRendererInstancePasses(fPasses).fForwardComputePass:=TpvScene3DRendererPassesForwardComputePass.Create(fFrameGraph,self);
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass);
 end;

 TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass:=TpvScene3DRendererPassesForwardRenderPass.Create(fFrameGraph,self);
 if assigned(TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWetnessMapComputePass);
 end;
 TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardComputePass);
 TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereProcessCustomPass);
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
 if Renderer.EarlyDepthPrepassNeeded then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
 end;
 if Renderer.ScreenSpaceAmbientOcclusion then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAmbientOcclusionBlurRenderPasses[1]);
 end;

 if not Renderer.EarlyDepthPrepassNeeded then begin
  TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass:=TpvScene3DRendererPassesDepthMipMapComputePass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass);
 end;

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

 TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass:=TpvScene3DRendererPassesRainRenderPass.Create(fFrameGraph,self);
 TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass);
 TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass);
 TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudRenderPass);

 if Renderer.SurfaceSampleCountFlagBits<>TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardResolveRenderPass:=TpvScene3DRendererPassesForwardResolveRenderPass.Create(fFrameGraph,self);
  TpvScene3DRendererInstancePasses(fPasses).fForwardResolveRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass);
  TpvScene3DRendererInstancePasses(fPasses).fForwardResolveRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass);
 end;

 TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass:=TpvScene3DRendererPassesForwardRenderMipMapComputePass.Create(fFrameGraph,self);
 TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderPass);
 TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass);
 TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass);
 if Renderer.SurfaceSampleCountFlagBits<>TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
  TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardResolveRenderPass);
 end;

{TpvScene3DRendererInstancePasses(fPasses).fPlanetWaterPrepassComputePass:=TpvScene3DRendererPassesPlanetWaterPrepassComputePass.Create(fFrameGraph,self);
TpvScene3DRendererInstancePasses(fPasses).fPlanetWaterPrepassComputePass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);}

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

 PreLastPass:=nil;
 LastPass:=TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass;

 case Renderer.TransparencyMode of

  TpvScene3DRendererTransparencyMode.Direct:begin

   TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyRenderPass:=TpvScene3DRendererPassesDirectTransparencyRenderPass.Create(fFrameGraph,self);
// TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass);

   PreLastPass:=TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyRenderPass;

   TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyResolveRenderPass:=TpvScene3DRendererPassesDirectTransparencyResolveRenderPass.Create(fFrameGraph,self);

   LastPass:=TpvScene3DRendererInstancePasses(fPasses).fDirectTransparencyResolveRenderPass;

  end;

  TpvScene3DRendererTransparencyMode.SPINLOCKOIT,
  TpvScene3DRendererTransparencyMode.INTERLOCKOIT:begin

   TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyClearCustomPass:=TpvScene3DRendererPassesLockOrderIndependentTransparencyClearCustomPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fLockOrderIndependentTransparencyClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass);

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
   TpvScene3DRendererInstancePasses(fPasses).fLoopOrderIndependentTransparencyClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass);

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
   TpvScene3DRendererInstancePasses(fPasses).fWeightBlendedOrderIndependentTransparencyRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass);

   PreLastPass:=TpvScene3DRendererInstancePasses(fPasses).fWeightBlendedOrderIndependentTransparencyRenderPass;

   TpvScene3DRendererInstancePasses(fPasses).fWeightBlendedOrderIndependentTransparencyResolveRenderPass:=TpvScene3DRendererPassesWeightBlendedOrderIndependentTransparencyResolveRenderPass.Create(fFrameGraph,self);

   LastPass:=TpvScene3DRendererInstancePasses(fPasses).fWeightBlendedOrderIndependentTransparencyResolveRenderPass;

  end;

  TpvScene3DRendererTransparencyMode.MBOIT:begin

   TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyAbsorbanceRenderPass:=TpvScene3DRendererPassesMomentBasedOrderIndependentTransparencyAbsorbanceRenderPass.Create(fFrameGraph,self);
// TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyAbsorbanceRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fMeshComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyAbsorbanceRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fDepthMipMapComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyAbsorbanceRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fForwardRenderMipMapComputePass);
   TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyAbsorbanceRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass);

   TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyTransmittanceRenderPass:=TpvScene3DRendererPassesMomentBasedOrderIndependentTransparencyTransmittanceRenderPass.Create(fFrameGraph,self);

   PreLastPass:=TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyTransmittanceRenderPass;

   TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyResolveRenderPass:=TpvScene3DRendererPassesMomentBasedOrderIndependentTransparencyResolveRenderPass.Create(fFrameGraph,self);

   LastPass:=TpvScene3DRendererInstancePasses(fPasses).fMomentBasedOrderIndependentTransparencyResolveRenderPass;

  end;

  TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT,
  TpvScene3DRendererTransparencyMode.INTERLOCKDFAOIT:begin

   TpvScene3DRendererInstancePasses(fPasses).fDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass:=TpvScene3DRendererPassesDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass.Create(fFrameGraph,self);
   TpvScene3DRendererInstancePasses(fPasses).fDeepAndFastApproximateOrderIndependentTransparencyClearCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass);

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

 if assigned(PreLastPass) and
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

 if not SameValue(fSizeFactor,1.0) then begin
  TpvScene3DRendererInstancePasses(fPasses).fResamplingRenderPass:=TpvScene3DRendererPassesResamplingRenderPass.Create(fFrameGraph,self);
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

 TpvScene3DRendererInstancePasses(fPasses).fTonemappingRenderPass:=TpvScene3DRendererPassesTonemappingRenderPass.Create(fFrameGraph,self);
 TpvScene3DRendererInstancePasses(fPasses).fTonemappingRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fLuminanceAverageComputePass);

 if assigned(AntialiasingLastPass) then begin
  TpvScene3DRendererInstancePasses(fPasses).fTonemappingRenderPass.AddExplicitPassDependency(AntialiasingLastPass);
 end;

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

 TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass:=TpvScene3DRendererPassesAtmospherePrecipitationReleaseCustomPass.Create(fFrameGraph,self);
 TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereRenderPass);
 TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmosphereCloudRenderPass);
 TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fRainRenderPass);

 TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass:=TpvScene3DRendererPassesWaterReleaseCustomPass.Create(fFrameGraph,self);
 TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterRenderPass);
 TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fAtmospherePrecipitationReleaseCustomPass);
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
  TpvScene3DRendererInstancePasses(fPasses).fDebugBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass);

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
 TpvScene3DRendererInstancePasses(fPasses).fFrameBufferBlitRenderPass.AddExplicitPassDependency(TpvScene3DRendererInstancePasses(fPasses).fWaterReleaseCustomPass);

 fFrameGraph.RootPass:=TpvScene3DRendererInstancePasses(fPasses).fFrameBufferBlitRenderPass;

 fFrameGraph.DoWaitOnSemaphore:=true;

 fFrameGraph.DoSignalSemaphore:=true;

 fFrameGraph.Compile;

end;

procedure TpvScene3DRendererInstance.AcquirePersistentResources;
var InFlightFrameIndex:TpvSizeInt;
    RenderPass:TpvScene3DRendererRenderPass;
begin

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

   fCascadedShadowMapCullDepthPyramidMipmappedArray2DImage:=TpvScene3DRendererMipmappedArray2DImage.Create(fScene3D.VulkanDevice,Max(1,RoundDownToPowerOfTwo(fCascadedShadowMapWidth)),Max(1,RoundDownToPowerOfTwo(fCascadedShadowMapHeight)),CountCascadedShadowMapCascades,VK_FORMAT_R32_SFLOAT,VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,pvAllocationGroupIDScene3DStatic,'TpvScene3DRendererInstance.fCascadedShadowMapCullDepthPyramidMipmappedArray2DImage');
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fCascadedShadowMapCullDepthPyramidMipmappedArray2DImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fCascadedShadowMapCullDepthPyramidMipmappedArray2DImage.Image');
   Renderer.VulkanDevice.DebugUtils.SetObjectName(fCascadedShadowMapCullDepthPyramidMipmappedArray2DImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fCascadedShadowMapCullDepthPyramidMipmappedArray2DImage.ImageView');

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

     fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                             Max(1,fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[InFlightFrameIndex])*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand),
                                                                                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
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
                                                                                                             '3DRendererInstance.CmdOutputBuffers['+IntToStr(InFlightFrameIndex)+']'
                                                                                                            );
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CmdOutputBuffers['+IntToStr(InFlightFrameIndex)+']');

     fPerInFlightFrameGPUDrawIndexedIndirectCommandCounterBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                              (MaxMultiIndirectDrawCalls shl 1)*SizeOf(TVkUInt32),
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
                                                                                                              '3DRendererInstance.CounterBuffers['+IntToStr(InFlightFrameIndex)+']'
                                                                                                             );
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameGPUDrawIndexedIndirectCommandCounterBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CounterBuffers['+IntToStr(InFlightFrameIndex)+']');

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

     fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                             Max(1,fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[InFlightFrameIndex])*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand),
                                                                                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
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
                                                                                                             '3DRendererInstance.CmdOutputBuffers['+IntToStr(InFlightFrameIndex)+']'
                                                                                                            );
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CmdOutputBuffers['+IntToStr(InFlightFrameIndex)+']');

     fPerInFlightFrameGPUDrawIndexedIndirectCommandCounterBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                              (MaxMultiIndirectDrawCalls shl 1)*SizeOf(TVkUInt32),
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
                                                                                                              '3DRendererInstance.CounterBuffers['+IntToStr(InFlightFrameIndex)+']'
                                                                                                             );
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameGPUDrawIndexedIndirectCommandCounterBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CounterBuffers['+IntToStr(InFlightFrameIndex)+']');

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

  end;

 end;

 FillChar(fPerInFlightFrameGPUCulledArray,SizeOf(TpvScene3D.TPerInFlightFrameGPUCulledArray),#0);

 fPointerToPerInFlightFrameGPUCulledArray:=@fPerInFlightFrameGPUCulledArray;

 FillChar(fPerInFlightFrameGPUCountObjectIndicesArray,SizeOf(TpvScene3D.TPerInFlightFrameGPUCountObjectIndicesArray),#0);

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin
  fDrawChoreographyBatchRangeFrameBuckets[InFlightFrameIndex].Initialize;
  for RenderPass:=TpvScene3DRendererRenderPassFirst to TpvScene3DRendererRenderPassLast do begin
   fDrawChoreographyBatchRangeFrameRenderPassBuckets[InFlightFrameIndex,RenderPass].Initialize;
  end;
 end;

 fMeshCullPass0ComputeVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(Renderer.VulkanDevice);
 fMeshCullPass0ComputeVulkanDescriptorSetLayout.AddBinding(0,
                                                           VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
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
 fMeshCullPass0ComputeVulkanDescriptorSetLayout.Initialize;
 Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshCullPass0ComputeVulkanDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DRendererInstance.fMeshCullPass0ComputeVulkanDescriptorSetLayout');

 fMeshCullPass0ComputeVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(Renderer.VulkanDevice,
                                                                                TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                                Renderer.CountInFlightFrames);
 fMeshCullPass0ComputeVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,Renderer.CountInFlightFrames*4);
 fMeshCullPass0ComputeVulkanDescriptorPool.Initialize;
 Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshCullPass0ComputeVulkanDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DRendererInstance.fMeshCullPass0ComputeVulkanDescriptorPool');

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin

  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fMeshCullPass0ComputeVulkanDescriptorPool,fMeshCullPass0ComputeVulkanDescriptorSetLayout);
  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[(InFlightFrameIndex+(fScene3D.CountInFlightFrames-1)) mod fScene3D.CountInFlightFrames].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameGPUDrawIndexedIndirectCommandCounterBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].Flush;
  Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TpvScene3DRendererInstance.fMeshCullPass0ComputeVulkanDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

 end;

 fFrameGraph.AcquirePersistentResources;

 if Renderer.GlobalIlluminationMode=TpvScene3DRendererGlobalIlluminationMode.CameraReflectionProbe then begin
  fImageBasedLightingReflectionProbeCubeMaps:=TpvScene3DRendererImageBasedLightingReflectionProbeCubeMaps.Create(Renderer.VulkanDevice,
                                                                                                                 Renderer.RepeatedSampler,
                                                                                                                 Max(16,fReflectionProbeWidth),
                                                                                                                 Max(16,fReflectionProbeHeight),
                                                                                                                 Renderer.CountInFlightFrames);
 end else begin
  fImageBasedLightingReflectionProbeCubeMaps:=nil;
 end;

end;

procedure TpvScene3DRendererInstance.ReleasePersistentResources;
var InFlightFrameIndex:TpvSizeInt;
    RenderPass:TpvScene3DRendererRenderPass;
begin

 fFrameGraph.ReleasePersistentResources;

 FreeAndNil(fImageBasedLightingReflectionProbeCubeMaps);

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin

  fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[InFlightFrameIndex].Finalize;
  FreeAndNil(fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[InFlightFrameIndex]);
  FreeAndNil(fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[InFlightFrameIndex]);
  FreeAndNil(fPerInFlightFrameGPUDrawIndexedIndirectCommandCounterBuffers[InFlightFrameIndex]);
  FreeAndNil(fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[InFlightFrameIndex]);

  fDrawChoreographyBatchRangeFrameBuckets[InFlightFrameIndex].Finalize;

  for RenderPass:=TpvScene3DRendererRenderPassFirst to TpvScene3DRendererRenderPassLast do begin
   fDrawChoreographyBatchRangeFrameRenderPassBuckets[InFlightFrameIndex,RenderPass].Finalize;
  end;

 end;

  begin

   FreeAndNil(fCascadedShadowMapCullDepthArray2DImage);

   FreeAndNil(fCascadedShadowMapCullDepthPyramidMipmappedArray2DImage);

  end;

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin
  FreeAndNil(fMeshCullPass0ComputeVulkanDescriptorSets[InFlightFrameIndex]);
 end;
 FreeAndNil(fMeshCullPass0ComputeVulkanDescriptorPool);
 FreeAndNil(fMeshCullPass0ComputeVulkanDescriptorSetLayout);

 FreeAndNil(fViewBuffersDescriptorSetLayout);

end;

procedure TpvScene3DRendererInstance.AcquireVolatileResources;
const NaNVector4:TpvVector4=(x:NaN;y:NaN;z:NaN;w:NaN);
var InFlightFrameIndex,Index:TpvSizeInt;
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

      fCullDepthPyramidMipmappedArray2DImage:=TpvScene3DRendererMipmappedArray2DImage.Create(fScene3D.VulkanDevice,Max(1,RoundDownToPowerOfTwo(fScaledWidth)),Max(1,RoundDownToPowerOfTwo(fScaledHeight)),fCountSurfaceViews,VK_FORMAT_R32_SFLOAT,VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,pvAllocationGroupIDScene3DSurface,'TpvScene3DRendererInstance.fCullDepthPyramidMipmappedArray2DImage');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fCullDepthPyramidMipmappedArray2DImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fCullDepthPyramidMipmappedArray2DImage.Image');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fCullDepthPyramidMipmappedArray2DImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fCullDepthPyramidMipmappedArray2DImage.ImageView');

{     fAmbientOcclusionDepthMipmappedArray2DImage:=TpvScene3DRendererMipmappedArray2DImage.Create(fScene3D.VulkanDevice,fScaledWidth,fScaledHeight,fCountSurfaceViews,VK_FORMAT_R32_SFLOAT,VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,pvAllocationGroupIDScene3DSurface,'TpvScene3DRendererInstance.fAmbientOcclusionDepthMipmappedArray2DImage');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fAmbientOcclusionDepthMipmappedArray2DImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fAmbientOcclusionDepthMipmappedArray2DImage.Image');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fAmbientOcclusionDepthMipmappedArray2DImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fAmbientOcclusionDepthMipmappedArray2DImage.ImageView');}

      fCombinedDepthArray2DImage:=TpvScene3DRendererArray2DImage.Create(fScene3D.VulkanDevice,fScaledWidth,fScaledHeight,fCountSurfaceViews,VK_FORMAT_R32_SFLOAT,VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,true,pvAllocationGroupIDScene3DSurface,VK_FORMAT_UNDEFINED,VK_SHARING_MODE_EXCLUSIVE,nil,'TpvScene3DRendererInstance.fCombinedDepthArray2DImage');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fCombinedDepthArray2DImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fCombinedDepthArray2DImage.Image');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fCombinedDepthArray2DImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fCombinedDepthArray2DImage.ImageView');

      fDepthMipmappedArray2DImage:=TpvScene3DRendererMipmappedArray2DImage.Create(fScene3D.VulkanDevice,fScaledWidth,fScaledHeight,fCountSurfaceViews,VK_FORMAT_R32_SFLOAT,VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,pvAllocationGroupIDScene3DSurface,'TpvScene3DRendererInstance.fDepthMipmappedArray2DImage');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fDepthMipmappedArray2DImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fDepthMipmappedArray2DImage.Image');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fDepthMipmappedArray2DImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fDepthMipmappedArray2DImage.ImageView');

      fSceneMipmappedArray2DImage:=TpvScene3DRendererMipmappedArray2DImage.Create(fScene3D.VulkanDevice,fScaledWidth,fScaledHeight,fCountSurfaceViews,VK_FORMAT_R16G16B16A16_SFLOAT{Renderer.OptimizedNonAlphaFormat},VK_SAMPLE_COUNT_1_BIT,VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,pvAllocationGroupIDScene3DSurface,'TpvScene3DRendererInstance.fSceneMipmappedArray2DImage');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fSceneMipmappedArray2DImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fSceneMipmappedArray2DImage.Image');
      Renderer.VulkanDevice.DebugUtils.SetObjectName(fSceneMipmappedArray2DImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fSceneMipmappedArray2DImage.ImageView');

      if SameValue(fSizeFactor,1.0) then begin
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

       fLockOrderIndependentTransparentUniformVulkanBuffer.UploadData(Renderer.VulkanDevice.UniversalQueue,
                                                                      UniversalCommandBuffer,
                                                                      UniversalFence,
                                                                      fLockOrderIndependentTransparentUniformBuffer,
                                                                      0,
                                                                      SizeOf(TLockOrderIndependentTransparentUniformBuffer));
       Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparentUniformVulkanBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLockOrderIndependentTransparentUniformVulkanBuffer');

       begin

        fLockOrderIndependentTransparencyABufferBuffer:=TpvScene3DRendererOrderIndependentTransparencyBuffer.Create(fScene3D.VulkanDevice,
                                                                                                                    fScaledWidth*fScaledHeight*fCountLockOrderIndependentTransparencyLayers*Max(1,fCountSurfaceViews)*(SizeOf(UInt32)*8{4}),
                                                                                                                    VK_FORMAT_R32G32B32A32_UINT,
                                                                                                                    TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT));
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparencyABufferBuffer.VulkanBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLockOrderIndependentTransparencyABufferBuffer.Buffer');
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparencyABufferBuffer.VulkanBufferView.Handle,VK_OBJECT_TYPE_BUFFER_VIEW,'TpvScene3DRendererInstance.fLockOrderIndependentTransparencyABufferBuffer.BufferView');

        fLockOrderIndependentTransparencyAuxImage:=TpvScene3DRendererOrderIndependentTransparencyImage.Create(fScene3D.VulkanDevice,
                                                                                                              fScaledWidth,
                                                                                                              fScaledHeight,
                                                                                                              fCountSurfaceViews,
                                                                                                              Renderer.OrderIndependentTransparencySampler,
                                                                                                              VK_FORMAT_R32_UINT,
                                                                                                              VK_SAMPLE_COUNT_1_BIT);
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparencyAuxImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fLockOrderIndependentTransparencyAuxImage.Image');
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparencyAuxImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fLockOrderIndependentTransparencyAuxImage.ImageView');

        if Renderer.TransparencyMode=TpvScene3DRendererTransparencyMode.SPINLOCKOIT then begin
         fLockOrderIndependentTransparencySpinLockImage:=TpvScene3DRendererOrderIndependentTransparencyImage.Create(fScene3D.VulkanDevice,
                                                                                                                    fScaledWidth,
                                                                                                                    fScaledHeight,
                                                                                                                    fCountSurfaceViews,
                                                                                                                    Renderer.OrderIndependentTransparencySampler,
                                                                                                                    VK_FORMAT_R32_UINT,
                                                                                                                    VK_SAMPLE_COUNT_1_BIT);
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparencySpinLockImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fLockOrderIndependentTransparencySpinLockImage.Image');
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fLockOrderIndependentTransparencySpinLockImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fLockOrderIndependentTransparencySpinLockImage.ImageView');
        end;

       end;

      end;

      TpvScene3DRendererTransparencyMode.LOOPOIT:begin

       fCountLoopOrderIndependentTransparencyLayers:=CountOrderIndependentTransparencyLayers;//Min(Max(CountOrderIndependentTransparencyLayers,fCountSurfaceMSAASamples),16);

       fLoopOrderIndependentTransparentUniformBuffer.ViewPort.x:=fScaledWidth;
       fLoopOrderIndependentTransparentUniformBuffer.ViewPort.y:=fScaledHeight;
       fLoopOrderIndependentTransparentUniformBuffer.ViewPort.z:=fLoopOrderIndependentTransparentUniformBuffer.ViewPort.x*fLoopOrderIndependentTransparentUniformBuffer.ViewPort.y;
       fLoopOrderIndependentTransparentUniformBuffer.ViewPort.w:=(fCountLoopOrderIndependentTransparencyLayers and $ffff) or ((Renderer.CountSurfaceMSAASamples and $ffff) shl 16);

       fLoopOrderIndependentTransparentUniformVulkanBuffer.UploadData(Renderer.VulkanDevice.UniversalQueue,
                                                                      UniversalCommandBuffer,
                                                                      UniversalFence,
                                                                      fLoopOrderIndependentTransparentUniformBuffer,
                                                                      0,
                                                                      SizeOf(TLoopOrderIndependentTransparentUniformBuffer));

       begin

        fLoopOrderIndependentTransparencyABufferBuffer:=TpvScene3DRendererOrderIndependentTransparencyBuffer.Create(fScene3D.VulkanDevice,
                                                                                                                    fScaledWidth*fScaledHeight*fCountLoopOrderIndependentTransparencyLayers*fCountSurfaceViews*(SizeOf(UInt32)*2),
                                                                                                                    VK_FORMAT_R32G32_UINT,
                                                                                                                    TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT));
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLoopOrderIndependentTransparencyABufferBuffer.VulkanBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLoopOrderIndependentTransparencyABufferBuffer.Buffer');
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLoopOrderIndependentTransparencyABufferBuffer.VulkanBufferView.Handle,VK_OBJECT_TYPE_BUFFER_VIEW,'TpvScene3DRendererInstance.fLoopOrderIndependentTransparencyABufferBuffer.BufferView');

        fLoopOrderIndependentTransparencyZBufferBuffer:=TpvScene3DRendererOrderIndependentTransparencyBuffer.Create(fScene3D.VulkanDevice,
                                                                                                                    fScaledWidth*fScaledHeight*fCountLoopOrderIndependentTransparencyLayers*fCountSurfaceViews*(SizeOf(UInt32)*1),
                                                                                                                    VK_FORMAT_R32_UINT,
                                                                                                                    TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT));
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLoopOrderIndependentTransparencyZBufferBuffer.VulkanBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLoopOrderIndependentTransparencyZBufferBuffer.Buffer');
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fLoopOrderIndependentTransparencyZBufferBuffer.VulkanBufferView.Handle,VK_OBJECT_TYPE_BUFFER_VIEW,'TpvScene3DRendererInstance.fLoopOrderIndependentTransparencyZBufferBuffer.BufferView');

        if Renderer.SurfaceSampleCountFlagBits<>TVkSampleCountFlagBits(VK_SAMPLE_COUNT_1_BIT) then begin
         fLoopOrderIndependentTransparencySBufferBuffer:=TpvScene3DRendererOrderIndependentTransparencyBuffer.Create(fScene3D.VulkanDevice,
                                                                                                                     fScaledWidth*fScaledHeight*fCountLoopOrderIndependentTransparencyLayers*fCountSurfaceViews*(SizeOf(UInt32)*1),
                                                                                                                     VK_FORMAT_R32_UINT,
                                                                                                                     TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT));
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fLoopOrderIndependentTransparencySBufferBuffer.VulkanBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DRendererInstance.fLoopOrderIndependentTransparencySBufferBuffer.Buffer');
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fLoopOrderIndependentTransparencySBufferBuffer.VulkanBufferView.Handle,VK_OBJECT_TYPE_BUFFER_VIEW,'TpvScene3DRendererInstance.fLoopOrderIndependentTransparencySBufferBuffer.BufferView');
        end else begin
         fLoopOrderIndependentTransparencySBufferBuffer:=nil;
        end;

       end;

      end;

      TpvScene3DRendererTransparencyMode.MBOIT,
      TpvScene3DRendererTransparencyMode.WBOIT:begin

       fApproximationOrderIndependentTransparentUniformBuffer.ZNearZFar.x:=abs(fZNear);
       fApproximationOrderIndependentTransparentUniformBuffer.ZNearZFar.y:=IfThen(IsInfinite(fZFar),4096.0,abs(fZFar));
       fApproximationOrderIndependentTransparentUniformBuffer.ZNearZFar.z:=ln(fApproximationOrderIndependentTransparentUniformBuffer.ZNearZFar.x);
       fApproximationOrderIndependentTransparentUniformBuffer.ZNearZFar.w:=ln(fApproximationOrderIndependentTransparentUniformBuffer.ZNearZFar.y);

       fApproximationOrderIndependentTransparentUniformVulkanBuffer.UploadData(Renderer.VulkanDevice.UniversalQueue,
                                                                               UniversalCommandBuffer,
                                                                               UniversalFence,
                                                                               fApproximationOrderIndependentTransparentUniformBuffer,
                                                                               0,
                                                                               SizeOf(TApproximationOrderIndependentTransparentUniformBuffer));

      end;

      TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT,
      TpvScene3DRendererTransparencyMode.INTERLOCKDFAOIT:begin

       begin

        fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImage:=TpvScene3DRendererOrderIndependentTransparencyImage.Create(fScene3D.VulkanDevice,
                                                                                                                                            fScaledWidth,
                                                                                                                                            fScaledHeight,
                                                                                                                                            fCountSurfaceViews,
                                                                                                                                            Renderer.OrderIndependentTransparencySampler,
                                                                                                                                            VK_FORMAT_R32G32B32A32_UINT,
                                                                                                                                            Renderer.SurfaceSampleCountFlagBits);
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImages.Image');
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImages.ImageView');

        fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImage:=TpvScene3DRendererOrderIndependentTransparencyImage.Create(fScene3D.VulkanDevice,
                                                                                                                                         fScaledWidth,
                                                                                                                                         fScaledHeight,
                                                                                                                                         fCountSurfaceViews,
                                                                                                                                         Renderer.OrderIndependentTransparencySampler,
                                                                                                                                         VK_FORMAT_R16G16B16A16_SFLOAT,
                                                                                                                                         Renderer.SurfaceSampleCountFlagBits);
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImages.Image');
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImages.ImageView');

        fDeepAndFastApproximateOrderIndependentTransparencyAverageImage:=TpvScene3DRendererOrderIndependentTransparencyImage.Create(fScene3D.VulkanDevice,
                                                                                                                                    fScaledWidth,
                                                                                                                                    fScaledHeight,
                                                                                                                                    fCountSurfaceViews,
                                                                                                                                    Renderer.OrderIndependentTransparencySampler,
                                                                                                                                    VK_FORMAT_R16G16B16A16_SFLOAT,
                                                                                                                                    Renderer.SurfaceSampleCountFlagBits);
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyAverageImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyAverageImages.Image');
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyAverageImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyAverageImages.ImageView');

        fDeepAndFastApproximateOrderIndependentTransparencyBucketImage:=TpvScene3DRendererOrderIndependentTransparencyImage.Create(fScene3D.VulkanDevice,
                                                                                                                                   fScaledWidth,
                                                                                                                                   fScaledHeight,
                                                                                                                                   fCountSurfaceViews*2,
                                                                                                                                   Renderer.OrderIndependentTransparencySampler,
                                                                                                                                   VK_FORMAT_R16G16B16A16_SFLOAT,
                                                                                                                                   Renderer.SurfaceSampleCountFlagBits);
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyBucketImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyBucketImages.Image');
        Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencyBucketImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencyBucketImages.ImageView');

        if Renderer.TransparencyMode=TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT then begin
         fDeepAndFastApproximateOrderIndependentTransparencySpinLockImage:=TpvScene3DRendererOrderIndependentTransparencyImage.Create(fScene3D.VulkanDevice,
                                                                                                                                      fScaledWidth,
                                                                                                                                      fScaledHeight,
                                                                                                                                      fCountSurfaceViews,
                                                                                                                                      Renderer.OrderIndependentTransparencySampler,
                                                                                                                                      VK_FORMAT_R32_UINT,
                                                                                                                                      VK_SAMPLE_COUNT_1_BIT);
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencySpinLockImage.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencySpinLockImages.Image');
         Renderer.VulkanDevice.DebugUtils.SetObjectName(fDeepAndFastApproximateOrderIndependentTransparencySpinLockImage.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TpvScene3DRendererInstance.fDeepAndFastApproximateOrderIndependentTransparencySpinLockImages.ImageView');
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
 fMeshCullPass1ComputeVulkanDescriptorSetLayout.Initialize;
 Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshCullPass1ComputeVulkanDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DRendererInstance.fMeshCullPass1ComputeVulkanDescriptorSetLayout');

 fMeshCullPass1ComputeVulkanDescriptorPool:=TpvVulkanDescriptorPool.Create(Renderer.VulkanDevice,
                                                                                TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                                Renderer.CountInFlightFrames);
 fMeshCullPass1ComputeVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,Renderer.CountInFlightFrames);
 fMeshCullPass1ComputeVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,Renderer.CountInFlightFrames*4);
 fMeshCullPass1ComputeVulkanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,Renderer.CountInFlightFrames*2);
 fMeshCullPass1ComputeVulkanDescriptorPool.Initialize;
 Renderer.VulkanDevice.DebugUtils.SetObjectName(fMeshCullPass1ComputeVulkanDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DRendererInstance.fMeshCullPass1ComputeVulkanDescriptorPool');

 fMeshCullPassDescriptorGeneration:=0;

 for InFlightFrameIndex:=0 to fScene3D.CountInFlightFrames-1 do begin

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
                                                                                     [fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                     [],
                                                                                     false
                                                                                    );
  fMeshCullPass1ComputeVulkanDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                                     0,
                                                                                     1,
                                                                                     TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                     [],
                                                                                     [fPerInFlightFrameGPUDrawIndexedIndirectCommandCounterBuffers[InFlightFrameIndex].DescriptorBufferInfo],
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
                                                                                                                     fCullDepthPyramidMipmappedArray2DImage.VulkanArrayImageView.Handle,
                                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                                                       TVkDescriptorImageInfo.Create(Renderer.MipMapMaxFilterSampler.Handle,
                                                                                                                     fCascadedShadowMapCullDepthPyramidMipmappedArray2DImage.VulkanArrayImageView.Handle,
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
                                                                                                                     fCullDepthPyramidMipmappedArray2DImage.VulkanArrayImageView.Handle,
                                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
                                                                                       TVkDescriptorImageInfo.Create(Renderer.MipMapMaxFilterSampler.Handle,
                                                                                                                     fCascadedShadowMapCullDepthPyramidMipmappedArray2DImage.VulkanArrayImageView.Handle,
                                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                                      [],
                                                                                      [],
                                                                                      false
                                                                                     );
  end;
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
var InFlightFrameIndex:TpvSizeInt;
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
  FreeAndNil(fCullDepthPyramidMipmappedArray2DImage);
  FreeAndNil(fCombinedDepthArray2DImage);
  FreeAndNil(fDepthMipmappedArray2DImage);
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
   FreeAndNil(fLockOrderIndependentTransparencyABufferBuffer);
   FreeAndNil(fLockOrderIndependentTransparencyAuxImage);
   if Renderer.TransparencyMode=TpvScene3DRendererTransparencyMode.SPINLOCKOIT then begin
    FreeAndNil(fLockOrderIndependentTransparencySpinLockImage);
   end;
  end;

  TpvScene3DRendererTransparencyMode.LOOPOIT:begin
   FreeAndNil(fLoopOrderIndependentTransparencyABufferBuffer);
   FreeAndNil(fLoopOrderIndependentTransparencyZBufferBuffer);
   FreeAndNil(fLoopOrderIndependentTransparencySBufferBuffer);
  end;

  TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT,
  TpvScene3DRendererTransparencyMode.INTERLOCKDFAOIT:begin
   FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencyFragmentCounterImage);
   FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencyAccumulationImage);
   FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencyAverageImage);
   FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencyBucketImage);
   if Renderer.TransparencyMode=TpvScene3DRendererTransparencyMode.SPINLOCKDFAOIT then begin
    FreeAndNil(fDeepAndFastApproximateOrderIndependentTransparencySpinLockImage);
   end;
  end;

  else begin
  end;

 end;

end;

procedure TpvScene3DRendererInstance.ClearSpaceLines(const aInFlightFrameIndex:TpvSizeInt);
begin
 fSpaceLinesPrimitiveDynamicArrays[aInFlightFrameIndex].ClearNoFree;
end;

function TpvScene3DRendererInstance.AddSpaceLine(const aInFlightFrameIndex:TpvSizeInt;const aStartPosition,aEndPosition:TpvVector3;const aColor:TpvVector4;const aSize:TpvScalar;const aZMin:TpvScalar=0.0;const aZMax:TpvScalar=Infinity):Boolean;
var Primitive:PSpaceLinesPrimitive;
    PrimitiveItems:TSpaceLinesPrimitiveDynamicArray;
begin
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
 fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex].ClearNoFree;
end;

function TpvScene3DRendererInstance.AddSolidPoint2D(const aInFlightFrameIndex:TpvSizeInt;const aPosition:TpvVector2;const aColor:TpvVector4;const aSize:TpvScalar;const aPositionOffset:TpvVector2;const aLineWidth:TpvScalar):Boolean;
var Primitive:PSolidPrimitivePrimitive;
    PrimitiveItems:TSolidPrimitivePrimitiveDynamicArray;
begin
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

 fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count:=0;

 fDrawChoreographyBatchRangeFrameBuckets[aInFlightFrameIndex].Count:=0;

 for RenderPass:=TpvScene3DRendererRenderPassFirst to TpvScene3DRendererRenderPassLast do begin
  fDrawChoreographyBatchRangeFrameRenderPassBuckets[aInFlightFrameIndex,RenderPass].Count:=0;
  fPerInFlightFrameGPUCulledArray[aInFlightFrameIndex,RenderPass]:=false;
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

procedure TpvScene3DRendererInstance.UploadGlobalIlluminationCascadedRadianceHints(const aInFlightFrameIndex:TpvInt32);
begin

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
    AtmosphereSphere:TpvSphere;
    Atmosphere:TpvScene3DAtmosphere;
    OK:boolean;
begin

 InFlightFrameState:=@fInFlightFrameStates[aInFlightFrameIndex];

 BoundingBox:=fScene3D.InFlightFrameBoundingBoxes[aInFlightFrameIndex];

 OK:=false;

 TpvScene3DAtmospheres(fScene3D.Atmospheres).Lock.AcquireRead;
 try
  if TpvScene3DAtmospheres(fScene3D.Atmospheres).Count>0 then begin
   Atmosphere:=TpvScene3DAtmospheres(fScene3D.Atmospheres).Items[0];
   AtmosphereSphere:=TpvSphere.Create(Atmosphere.AtmosphereParameters.Center.xyz,Max(Atmosphere.AtmosphereParameters.TopRadius,Max(Atmosphere.AtmosphereParameters.VolumetricClouds.LayerLow.EndHeight,Atmosphere.AtmosphereParameters.VolumetricClouds.LayerHigh.EndHeight)));
   BoundingBox:=AtmosphereSphere.ToAABB;
   OK:=true;
  end;
 finally
  TpvScene3DAtmospheres(fScene3D.Atmospheres).Lock.ReleaseRead;
 end;

 if OK then begin

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

  InFlightFrameState^.CloudsShadowMapMatrix:=LightViewProjectionMatrix;
  InFlightFrameState^.CloudsShadowMapLightDirection:=fScene3D.PrimaryShadowMapLightDirections[aInFlightFrameIndex].xyz.Normalize;

  InFlightFrameState^.CloudsShadowMapViewIndex:=fViews[aInFlightFrameIndex].Add(View);
  InFlightFrameState^.CountCloudsShadowMapViews:=1;

 end else begin

  InFlightFrameState^.CloudsShadowMapViewIndex:=0;
  InFlightFrameState^.CountCloudsShadowMapViews:=0;

 end;

end;

procedure TpvScene3DRendererInstance.PrepareDrawRenderInstanceFillTasksParallelForJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var TaskIndex,CountTasks,Index,Remain,ToDo,
    LowIndex,HighIndex,MidIndex,
    OffsetedIndex,InstanceIndex,FirstInstanceCommandIndex,CountIndices,
    FirstIndex,FirstInstanceID,NodeIndex,BoundingSphereIndex:TPasMPNativeInt;
    Task:PPrepareDrawRenderInstanceFillTask;
    GPUDrawIndexedIndirectCommand:TpvScene3D.PGPUDrawIndexedIndirectCommand;
    GPUDrawIndexedIndirectCommandDynamicArray:TpvScene3D.PGPUDrawIndexedIndirectCommandDynamicArray;
    GlobalRenderInstanceCullDataDynamicArray:TpvScene3D.PGlobalRenderInstanceCullDataDynamicArray;
//  GlobalVulkanInstanceDataIndexDynamicArray:TpvScene3D.PGlobalVulkanInstanceDataIndexDynamicArray;
begin

 if aFromIndex<=aToIndex then begin

  CountTasks:=fPrepareDrawRenderInstanceFillTasks.Count;
  if CountTasks>0 then begin

   GPUDrawIndexedIndirectCommandDynamicArray:=@fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[fPrepareDrawRenderInstanceFillTasksInFlightFrameIndex];
   GlobalRenderInstanceCullDataDynamicArray:=@fScene3D.GlobalRenderInstanceCullDataDynamicArrays[fPrepareDrawRenderInstanceFillTasksInFlightFrameIndex];
 //GlobalVulkanInstanceDataIndexDynamicArray:=@fScene3D.GlobalVulkanGPUInstanceDataIndexDynamicArrays[fPrepareDrawRenderInstanceFillTasksInFlightFrameIndex];

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
     FirstInstanceID:=Task^.FirstInstanceID;
     NodeIndex:=Task^.NodeIndex;
     BoundingSphereIndex:=Task^.BoundingSphereIndex;

     for InstanceIndex:=OffsetedIndex to (OffsetedIndex+ToDo)-1 do begin
      GPUDrawIndexedIndirectCommand:=@GPUDrawIndexedIndirectCommandDynamicArray^.ItemArray[FirstInstanceCommandIndex+InstanceIndex];
      GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.indexCount:=CountIndices;
      GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.instanceCount:=1;
      GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.firstIndex:=FirstIndex;
      GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.vertexOffset:=0;
      GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.firstInstance:=FirstInstanceID+InstanceIndex;
      GPUDrawIndexedIndirectCommand^.ObjectIndex:=TpvScene3D.TGroup.TInstance.TRenderInstance(GlobalRenderInstanceCullDataDynamicArray^.ItemArray[FirstInstanceID+InstanceIndex].RenderInstance).NodeCullObjectIDs[NodeIndex];
      GPUDrawIndexedIndirectCommand^.BoundingSphereIndex:=BoundingSphereIndex;
      GPUDrawIndexedIndirectCommand^.Flags:=0;
    //GPUDrawIndexedIndirectCommand^.InstanceDataIndex:=GlobalVulkanInstanceDataIndexDynamicArray^.ItemArray[FirstInstanceID+InstanceIndex];
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

procedure TpvScene3DRendererInstance.PrepareDraw(const aInFlightFrameIndex:TpvSizeInt;
                                                 const aRenderPass:TpvScene3DRendererRenderPass;
                                                 const aMaterialAlphaModes:TpvScene3D.TMaterial.TAlphaModes;
                                                 const aGPUCulling:boolean);
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
//  GlobalVulkanInstanceMatrixDynamicArray:TpvScene3D.PGlobalVulkanInstanceMatrixDynamicArray;
    GlobalVulkanInstanceDataIndexDynamicArray:TpvScene3D.PGlobalVulkanInstanceDataIndexDynamicArray;
    GlobalRenderInstanceCullDataDynamicArray:TpvScene3D.PGlobalRenderInstanceCullDataDynamicArray;
//  GlobalRenderInstanceCullData:TpvScene3D.PCullData;
//  RenderInstance:TpvScene3D.TGroup.TInstance.TRenderInstance;
    GroupInstance:TpvScene3D.TGroup.TInstance;
    FirstInstanceID:TpvUInt32;
    BoundingSphereIndex:TpvUInt32;
    Task:PPrepareDrawRenderInstanceFillTask;
begin

 fPerInFlightFrameGPUCulledArray[aInFlightFrameIndex,aRenderPass]:=aGPUCulling;

 fPrepareDrawRenderInstanceFillTasksInFlightFrameIndex:=aInFlightFrameIndex;

//GlobalVulkanInstanceMatrixDynamicArray:=@fScene3D.GlobalVulkanInstanceMatrixDynamicArrays[aInFlightFrameIndex];

 GlobalVulkanInstanceDataIndexDynamicArray:=@fScene3D.GlobalVulkanGPUInstanceDataIndexDynamicArrays[aInFlightFrameIndex];

 GlobalRenderInstanceCullDataDynamicArray:=@fScene3D.GlobalRenderInstanceCullDataDynamicArrays[aInFlightFrameIndex];

 GPUDrawIndexedIndirectCommandDynamicArray:=@fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex];

 DrawChoreographyBatchRangeDynamicArray:=@fDrawChoreographyBatchRangeFrameBuckets[aInFlightFrameIndex];

 DrawChoreographyBatchRangeIndexDynamicArray:=@fDrawChoreographyBatchRangeFrameRenderPassBuckets[aInFlightFrameIndex,aRenderPass];

 fPrepareDrawRenderInstanceFillTasks.Count:=0;

 Count:=0;

 TotalCount:=0;

 CountTotalRenderInstances:=0;

 for MaterialAlphaMode in aMaterialAlphaModes do begin

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

       CountInstances:=TpvScene3D.TGroup.TInstance(DrawChoreographyBatchItem.GroupInstance).fVulkanPerInFlightFrameInstancesCounts[aInFlightFrameIndex,fID,aRenderPass];
       if CountInstances>0 then begin

        NodeIndex:=TpvScene3D.TGroup.TNode(DrawChoreographyBatchItem.Node).Index;

        BoundingSphereIndex:=TpvScene3D.TGroup.TInstance(DrawChoreographyBatchItem.GroupInstance).Nodes[NodeIndex].BoundingSphereIndex;

        if TpvScene3D.TGroup.TInstance(DrawChoreographyBatchItem.GroupInstance).UseRenderInstances then begin

         GroupInstance:=TpvScene3D.TGroup.TInstance(DrawChoreographyBatchItem.GroupInstance);
         FirstInstanceID:=GroupInstance.fVulkanPerInFlightFrameFirstInstances[aInFlightFrameIndex,fID,aRenderPass];

         FirstInstanceCommandIndex:=GPUDrawIndexedIndirectCommandDynamicArray^.Count;
         GPUDrawIndexedIndirectCommandDynamicArray^.SetCount(FirstInstanceCommandIndex+CountInstances);

         // Record task for parallel fill
         TaskIndex:=fPrepareDrawRenderInstanceFillTasks.AddNewIndex;
         Task:=@fPrepareDrawRenderInstanceFillTasks.ItemArray[TaskIndex];
         Task^.FromIndex:=CountTotalRenderInstances;
         Task^.ToIndex:=(CountTotalRenderInstances+CountInstances)-1;
         Task^.FirstInstanceCommandIndex:=FirstInstanceCommandIndex;
         Task^.CountInstances:=CountInstances;
         Task^.FirstInstanceID:=FirstInstanceID;
         Task^.NodeIndex:=NodeIndex;
         Task^.CountIndices:=DrawChoreographyBatchItem.CountIndices;
         Task^.FirstIndex:=DrawChoreographyBatchItem.StartIndex;
         Task^.BoundingSphereIndex:=BoundingSphereIndex;
         Task^.GroupInstance:=GroupInstance;

         inc(CountTotalRenderInstances,CountInstances);

        end else begin

         GPUDrawIndexedIndirectCommand:=Pointer(GPUDrawIndexedIndirectCommandDynamicArray^.AddNew);
         GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.indexCount:=DrawChoreographyBatchItem.CountIndices;
         GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.instanceCount:=1;
         GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.firstIndex:=DrawChoreographyBatchItem.StartIndex;
         GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.vertexOffset:=0;
         GPUDrawIndexedIndirectCommand^.DrawIndexedIndirectCommand.firstInstance:=0;
         GPUDrawIndexedIndirectCommand^.ObjectIndex:=DrawChoreographyBatchItem.ObjectIndex;
         GPUDrawIndexedIndirectCommand^.BoundingSphereIndex:=BoundingSphereIndex;
         GPUDrawIndexedIndirectCommand^.Flags:=0;
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
                                                 const aDisocclusions:boolean);
var DrawChoreographyBatchRangeIndex:TpvSizeInt;
    Pipeline,NewPipeline:TpvVulkanPipeline;
    First,GPUCulling:boolean;
    MeshStagePushConstants:TpvScene3D.PMeshStagePushConstants;
    DrawChoreographyBatchRangeDynamicArray:TpvScene3D.PDrawChoreographyBatchRangeDynamicArray;
    DrawChoreographyBatchRangeIndexDynamicArray:TpvScene3D.PDrawChoreographyBatchRangeIndexDynamicArray;
    DrawChoreographyBatchRange:TpvScene3D.PDrawChoreographyBatchRange;
    vkCmdDrawIndexedIndirectCount:TvkCmdDrawIndexedIndirectCount;
    Time:TpvDouble;
begin

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
  
  fSetGlobalResourcesDone[aRenderPass]:=false;

  Pipeline:=nil;

  First:=true;

  GPUCulling:=fPerInFlightFrameGPUCulledArray[aInFlightFrameIndex,aRenderPass];

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

  DrawChoreographyBatchRangeDynamicArray:=@fDrawChoreographyBatchRangeFrameBuckets[aInFlightFrameIndex];

  DrawChoreographyBatchRangeIndexDynamicArray:=@fDrawChoreographyBatchRangeFrameRenderPassBuckets[aInFlightFrameIndex,aRenderPass];

  for DrawChoreographyBatchRangeIndex:=0 to DrawChoreographyBatchRangeIndexDynamicArray^.Count-1 do begin

   DrawChoreographyBatchRange:=@DrawChoreographyBatchRangeDynamicArray^.Items[DrawChoreographyBatchRangeIndexDynamicArray^.Items[DrawChoreographyBatchRangeIndex]];

   if (DrawChoreographyBatchRange^.CountCommands>0) and
      (DrawChoreographyBatchRange.AlphaMode in aMaterialAlphaModes) then begin

    NewPipeline:=aGraphicsPipelines[DrawChoreographyBatchRange^.PrimitiveTopology,
                                    DrawChoreographyBatchRange^.FaceCullingMode];

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

     if assigned(vkCmdDrawIndexedIndirectCount) then begin

      if aDisocclusions then begin

       vkCmdDrawIndexedIndirectCount(aCommandBuffer.Handle,
                                     fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[aInFlightFrameIndex].Handle,
                                     ((fPerInFlightFrameGPUDrawIndexedIndirectCommandDisocclusionOffsets[aInFlightFrameIndex]+DrawChoreographyBatchRange^.FirstCommand)*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand))+TpvPtrUInt(Pointer(@TpvScene3D.PGPUDrawIndexedIndirectCommand(nil)^.DrawIndexedIndirectCommand)),
                                     fPerInFlightFrameGPUDrawIndexedIndirectCommandCounterBuffers[aInFlightFrameIndex].Handle,
                                     (TpvScene3DRendererInstance.MaxMultiIndirectDrawCalls+DrawChoreographyBatchRange^.DrawCallIndex)*SizeOf(TpvUInt32),
                                     DrawChoreographyBatchRange^.CountCommands,
                                     SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand));

      end else begin

       vkCmdDrawIndexedIndirectCount(aCommandBuffer.Handle,
                                     fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[aInFlightFrameIndex].Handle,
                                     (DrawChoreographyBatchRange^.FirstCommand*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand))+TpvPtrUInt(Pointer(@TpvScene3D.PGPUDrawIndexedIndirectCommand(nil)^.DrawIndexedIndirectCommand)),
                                     fPerInFlightFrameGPUDrawIndexedIndirectCommandCounterBuffers[aInFlightFrameIndex].Handle,
                                     DrawChoreographyBatchRange^.DrawCallIndex*SizeOf(TpvUInt32),
                                     DrawChoreographyBatchRange^.CountCommands,
                                     SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand));

      end;

     end else begin

      aCommandBuffer.CmdDrawIndexedIndirect(fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex].Handle,
                                            (DrawChoreographyBatchRange^.FirstCommand*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand))+TpvPtrUInt(Pointer(@TpvScene3D.PGPUDrawIndexedIndirectCommand(nil)^.DrawIndexedIndirectCommand)),
                                            DrawChoreographyBatchRange^.CountCommands,
                                            SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand));
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
    ViewMatrix,LeftProjectionMatrix,RightProjectionMatrix:TpvMatrix4x4;
    FieldOfView:TpvFloat;
begin

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

  TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing:begin
   UpdateGlobalIlluminationCascadedVoxelConeTracing(aInFlightFrameIndex);
  end;

  else begin
  end;

 end;

 for Index:=0 to fViews[aInFlightFrameIndex].Count-1 do begin
  fPotentiallyVisibleSetViewNodeIndices[aInFlightFrameIndex,Index]:=fScene3D.PotentiallyVisibleSet.GetNodeIndexByPosition(fViews[aInFlightFrameIndex].Items[Index].InverseViewMatrix.Translation.xyz);
 end;

 // Final viewport(s) (and voxelization viewport)
 if InFlightFrameState^.CountFinalViews>0 then begin

  fScene3D.Prepare(aInFlightFrameIndex,
                   self,
                   TpvScene3DRendererRenderPass.View,
                   fViews[aInFlightFrameIndex],
                   fPotentiallyVisibleSetViewNodeIndices[aInFlightFrameIndex],
                   InFlightFrameState^.FinalViewIndex,
                   InFlightFrameState^.CountFinalViews,
                   fScaledWidth,
                   fScaledHeight,
                   true,
                   [TpvScene3D.TMaterial.TAlphaMode.Opaque,TpvScene3D.TMaterial.TAlphaMode.Mask,TpvScene3D.TMaterial.TAlphaMode.Blend],
                   true,
                   true,
                   Renderer.GPUCulling);

  if Renderer.GlobalIlluminationMode=TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing then begin
   fScene3D.Prepare(aInFlightFrameIndex,
                    self,
                    TpvScene3DRendererRenderPass.Voxelization,
                    fViews[aInFlightFrameIndex],
                    fPotentiallyVisibleSetViewNodeIndices[aInFlightFrameIndex],
                    InFlightFrameState^.FinalViewIndex,
                    Min(InFlightFrameState^.CountFinalViews,1),
                    Renderer.GlobalIlluminationVoxelGridSize,
                    Renderer.GlobalIlluminationVoxelGridSize,
                    false,
                    [TpvScene3D.TMaterial.TAlphaMode.Opaque,TpvScene3D.TMaterial.TAlphaMode.Mask,TpvScene3D.TMaterial.TAlphaMode.Blend],
                    false,
                    false,
                    false);
  end;

 end;

 // Reflection probe viewport(s)
 if InFlightFrameState^.CountReflectionProbeViews>0 then begin
  fScene3D.Prepare(aInFlightFrameIndex,
                   self,
                   TpvScene3DRendererRenderPass.ReflectionProbe,
                   fViews[aInFlightFrameIndex],
                   fPotentiallyVisibleSetViewNodeIndices[aInFlightFrameIndex],
                   InFlightFrameState^.ReflectionProbeViewIndex,
                   InFlightFrameState^.CountReflectionProbeViews,
                   fReflectionProbeWidth,
                   fReflectionProbeHeight,
                   false,
                   [TpvScene3D.TMaterial.TAlphaMode.Opaque,TpvScene3D.TMaterial.TAlphaMode.Mask,TpvScene3D.TMaterial.TAlphaMode.Blend],
                   false,
                   false,
                   false);
 end;

 // Reflection probe viewport(s)
 if InFlightFrameState^.CountTopDownSkyOcclusionMapViews>0 then begin
  fScene3D.Prepare(aInFlightFrameIndex,
                   self,
                   TpvScene3DRendererRenderPass.TopDownSkyOcclusionMap,
                   fViews[aInFlightFrameIndex],
                   fPotentiallyVisibleSetViewNodeIndices[aInFlightFrameIndex],
                   InFlightFrameState^.TopDownSkyOcclusionMapViewIndex,
                   InFlightFrameState^.CountTopDownSkyOcclusionMapViews,
                   fTopDownSkyOcclusionMapWidth,
                   fTopDownSkyOcclusionMapHeight,
                   false,
                   [TpvScene3D.TMaterial.TAlphaMode.Opaque,TpvScene3D.TMaterial.TAlphaMode.Mask],
                   false,
                   false,
                   false);
 end;

 // Reflective shadow map viewport(s)
 if InFlightFrameState^.CountReflectiveShadowMapViews>0 then begin
  fScene3D.Prepare(aInFlightFrameIndex,
                   self,
                   TpvScene3DRendererRenderPass.ReflectiveShadowMap,
                   fViews[aInFlightFrameIndex],
                   fPotentiallyVisibleSetViewNodeIndices[aInFlightFrameIndex],
                   InFlightFrameState^.ReflectiveShadowMapViewIndex,
                   InFlightFrameState^.CountReflectiveShadowMapViews,
                   fReflectiveShadowMapWidth,
                   fReflectiveShadowMapHeight,
                   false,
                   [TpvScene3D.TMaterial.TAlphaMode.Opaque,TpvScene3D.TMaterial.TAlphaMode.Mask,TpvScene3D.TMaterial.TAlphaMode.Blend],
                   false,
                   false,
                   false);
 end;

 if InFlightFrameState^.CountCascadedShadowMapViews>0 then begin
  // Cascaded shadow map viewport(s)
  fScene3D.Prepare(aInFlightFrameIndex,
                   self,
                   TpvScene3DRendererRenderPass.CascadedShadowMap,
                   fViews[aInFlightFrameIndex],
                   fPotentiallyVisibleSetViewNodeIndices[aInFlightFrameIndex],
                   InFlightFrameState^.CascadedShadowMapViewIndex,
                   InFlightFrameState^.CountCascadedShadowMapViews,
                   fCascadedShadowMapWidth,
                   fCascadedShadowMapHeight,
                   false,
                   [TpvScene3D.TMaterial.TAlphaMode.Opaque,TpvScene3D.TMaterial.TAlphaMode.Mask],
                   true,
                   true,
                   Renderer.GPUCulling and Renderer.GPUShadowCulling,
                   true);
 end;

 TPasMPInterlocked.Write(InFlightFrameState^.Ready,true);

end;

procedure TpvScene3DRendererInstance.UploadFrame(const aInFlightFrameIndex:TpvInt32);
var PreviousInFlightFrameIndex,NextInFlightFrameIndex,Index,CountViews,Count:TpvSizeInt;
//  RenderPass:TpvScene3DRendererRenderPass;
    DoNeedUpdateDescriptors:boolean;
begin

 PreviousInFlightFrameIndex:=aInFlightFrameIndex-1;
 if PreviousInFlightFrameIndex<0 then begin
  inc(PreviousInFlightFrameIndex,Renderer.CountInFlightFrames);
 end;

 NextInFlightFrameIndex:=aInFlightFrameIndex+1;
 if NextInFlightFrameIndex>=Renderer.CountInFlightFrames then begin
  dec(NextInFlightFrameIndex,Renderer.CountInFlightFrames);
 end;

 if fViews[aInFlightFrameIndex].Count>0 then begin
  Move(fViews[aInFlightFrameIndex].Items[0],
       fVulkanViews[aInFlightFrameIndex].Items[0],
       fViews[aInFlightFrameIndex].Count*SizeOf(TpvScene3D.TView));
  CountViews:=fViews[aInFlightFrameIndex].Count;
  if fViews[PreviousInFlightFrameIndex].Count=0 then begin
   Move(fViews[aInFlightFrameIndex].Items[0],
        fVulkanViews[aInFlightFrameIndex].Items[CountViews],
        fViews[aInFlightFrameIndex].Count*SizeOf(TpvScene3D.TView));
   inc(CountViews,fViews[aInFlightFrameIndex].Count);
  end else begin
   Move(fViews[PreviousInFlightFrameIndex].Items[0],
        fVulkanViews[aInFlightFrameIndex].Items[CountViews],
        fViews[PreviousInFlightFrameIndex].Count*SizeOf(TpvScene3D.TView));
   inc(CountViews,fViews[PreviousInFlightFrameIndex].Count);
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

  TpvScene3DRendererGlobalIlluminationMode.CascadedVoxelConeTracing:begin
   UploadGlobalIlluminationCascadedVoxelConeTracing(aInFlightFrameIndex);
  end;

  else begin
  end;

 end;


 begin

  DoNeedUpdateDescriptors:=false;

  fPerInFlightFrameGPUCountObjectIndicesArray[aInFlightFrameIndex]:=Max(0,fScene3D.MaxCullObjectID+1);

  Count:=fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count shl 1;

  fPerInFlightFrameGPUDrawIndexedIndirectCommandDisocclusionOffsets[aInFlightFrameIndex]:=fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count;

  if fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex]<Count then begin

   fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex]:=Count+((Count+1) shr 1);

   fScene3D.AddToFreeQueue(fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex],1);
   fScene3D.AddToFreeQueue(fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[aInFlightFrameIndex],1);

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

     fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[aInFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                              Max(1,fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex])*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand),
                                                                                                              TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
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
                                                                                                              '3DRendererInstance.CmdOutputBuffers['+IntToStr(aInFlightFrameIndex)+']'
                                                                                                             );
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[aInFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CmdOutputBuffers['+IntToStr(aInFlightFrameIndex)+']');

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

     fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[aInFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                              Max(1,fPerInFlightFrameGPUDrawIndexedIndirectCommandBufferSizes[aInFlightFrameIndex])*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand),
                                                                                                              TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT),
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
                                                                                                              '3DRendererInstance.CmdOutputBuffers['+IntToStr(aInFlightFrameIndex)+']'
                                                                                                             );
     Renderer.VulkanDevice.DebugUtils.SetObjectName(fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[aInFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'3DRendererInstance.CmdOutputBuffers['+IntToStr(aInFlightFrameIndex)+']');

    end;

    else begin
     Assert(false);
    end;

   end;

   DoNeedUpdateDescriptors:=true;

  end;

  if (not assigned(fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[aInFlightFrameIndex]) or
     (fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[aInFlightFrameIndex].Size<=((fScene3D.MaxCullObjectID+32) shr 5)*(2*SizeOf(TpvUInt32)))) then begin

   fScene3D.AddToFreeQueue(fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[aInFlightFrameIndex],2);

   fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBufferPartSizes[aInFlightFrameIndex]:=(fScene3D.MaxCullObjectID+32) shr 5;

   fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[aInFlightFrameIndex]:=TpvVulkanBuffer.Create(Renderer.VulkanDevice,
                                                                                                                ((fScene3D.MaxCullObjectID+32) shr 5)*(2*SizeOf(TpvUInt32)),
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

  if DoNeedUpdateDescriptors then begin
   inc(fMeshCullPassDescriptorGeneration);
  end;

  if fMeshCullPassDescriptorGenerations[aInFlightFrameIndex]<>fMeshCullPassDescriptorGeneration then begin

   fMeshCullPassDescriptorGenerations[aInFlightFrameIndex]:=fMeshCullPassDescriptorGeneration;

   begin

    fMeshCullPass0ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(0,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass0ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(1,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fPerInFlightFrameGPUDrawIndexedIndirectCommandVisibilityBuffers[PreviousInFlightFrameIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        true
                                                                                       );
    fMeshCullPass0ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(2,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass0ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(3,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fPerInFlightFrameGPUDrawIndexedIndirectCommandCounterBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
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
                                                                                        [fPerInFlightFrameGPUDrawIndexedIndirectCommandOutputBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
                                                                                        [],
                                                                                        false
                                                                                       );
    fMeshCullPass1ComputeVulkanDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(3,
                                                                                        0,
                                                                                        1,
                                                                                        TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                        [],
                                                                                        [fPerInFlightFrameGPUDrawIndexedIndirectCommandCounterBuffers[aInFlightFrameIndex].DescriptorBufferInfo],
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
    fMeshCullPass1ComputeVulkanDescriptorSets[aInFlightFrameIndex].Flush;
   end;

  end;

  if fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count>0 then begin

   Renderer.VulkanDevice.MemoryStaging.Upload(fScene3D.VulkanStagingQueue,
                                              fScene3D.VulkanStagingCommandBuffer,
                                              fScene3D.VulkanStagingFence,
                                              fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Items[0],
                                              fPerInFlightFrameGPUDrawIndexedIndirectCommandInputBuffers[aInFlightFrameIndex],
                                              0,
                                              fPerInFlightFrameGPUDrawIndexedIndirectCommandDynamicArrays[aInFlightFrameIndex].Count*SizeOf(TpvScene3D.TGPUDrawIndexedIndirectCommand));

  end;

 end;

{for RenderPass:=TpvScene3DRendererRenderPassFirst to TpvScene3DRendererRenderPassLast do begin
  if fPerInFlightFrameGPUCulledArray[aInFlightFrameIndex,RenderPass] then begin
  end;
 end; }

end;

procedure TpvScene3DRendererInstance.ProcessAtmospheresForFrame(const aInFlightFrameIndex:TpvInt32;const aCommandBuffer:TpvVulkanCommandBuffer);
var AtmosphereIndex:TpvSizeInt;
    Atmosphere:TpvScene3DAtmosphere;
begin

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

procedure TpvScene3DRendererInstance.DrawFrame(const aSwapChainImageIndex,aInFlightFrameIndex:TpvInt32;const aFrameCounter:TpvInt64;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
const MinDeltaTime=1.0/480.0; // 480 Hz
      MaxDeltaTime=1.0/1.0; // 1 Hz
      LN2=0.6931471805599453;
var t:TpvDouble;
    CameraPreset:TpvScene3DRendererCameraPreset;
begin

 CameraPreset:=CameraPresets[aInFlightFrameIndex];

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

 if (aViewBaseIndex>=0) and (aCountViews>0) and (fSpaceLinesPrimitiveDynamicArrays[aInFlightFrameIndex].Count>0) then begin

//fScene3D.SetGlobalResources(aCommandBuffer,aPipelineLayout,aRendererInstance,aRenderPass,aPreviousInFlightFrameIndex,aInFlightFrameIndex);

  if assigned(aOnSetRenderPassResources) then begin
   aOnSetRenderPassResources(aCommandBuffer,aPipelineLayout,aRendererInstance,aRenderPass,aPreviousInFlightFrameIndex,aInFlightFrameIndex);
  end;

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,aGraphicsPipeline.Handle);

  aCommandBuffer.CmdBindVertexBuffers(0,1,@fSpaceLinesVertexBuffer.Handle,@Offsets);

  aCommandBuffer.CmdBindIndexBuffer(fSpaceLinesIndexBuffer.Handle,0,VK_INDEX_TYPE_UINT32);

  aCommandBuffer.CmdDrawIndexedIndirect(fSpaceLinesIndirectDrawCommandBuffer.Handle,0,1,SizeOf(TVkDrawIndexedIndirectCommand));

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

 if (aViewBaseIndex>=0) and (aCountViews>0) and (fSolidPrimitivePrimitiveDynamicArrays[aInFlightFrameIndex].Count>0) then begin

//fScene3D.SetGlobalResources(aCommandBuffer,aPipelineLayout,aRendererInstance,aRenderPass,aPreviousInFlightFrameIndex,aInFlightFrameIndex);

  if assigned(aOnSetRenderPassResources) then begin
   aOnSetRenderPassResources(aCommandBuffer,aPipelineLayout,aRendererInstance,aRenderPass,aPreviousInFlightFrameIndex,aInFlightFrameIndex);
  end;

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,aGraphicsPipeline.Handle);

  aCommandBuffer.CmdBindVertexBuffers(0,1,@fSolidPrimitiveVertexBuffer.Handle,@Offsets);

  aCommandBuffer.CmdBindIndexBuffer(fSolidPrimitiveIndexBuffer.Handle,0,VK_INDEX_TYPE_UINT32);

  aCommandBuffer.CmdDrawIndexedIndirect(fSolidPrimitiveIndirectDrawCommandBuffer.Handle,0,1,SizeOf(TVkDrawIndexedIndirectCommand));

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

