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
unit PasVulkan.Scene3D.Atmosphere;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

uses SysUtils,
     Classes,
     Math,
     Vulkan,
     POCA,
     PUCU,
     PasMP,
     PasJSON,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Math.Double,
     PasVulkan.Application,
     PasVulkan.Framework,
     PasVulkan.Collections,
     PasVulkan.Scene3D.Renderer.Image2D,
     PasVulkan.Scene3D.Renderer.Array2DImage,
     PasVulkan.Scene3D.Renderer.ImageCubeMap,
     PasVulkan.Scene3D.Renderer.MipmapImageCubeMap,
     PasVulkan.Scene3D.Renderer.MipmapImage3D,
     PasVulkan.Scene3D.Renderer.CubeMapMipMapGenerator,
     PasVulkan.Scene3D.Renderer.CubeMapIBLFilter;

type TpvScene3DAtmosphere=class;

     TpvScene3DAtmospheres=class;

     { TpvScene3DAtmosphereGlobals }
     TpvScene3DAtmosphereGlobals=class
      public
       type TTransmittanceLUTPushConstants=packed record
             BaseViewIndex:TpvInt32;
             CountViews:TpvInt32;
             Dummy0:TpvInt32;
             Dummy1:TpvInt32;
            end;
            PTransmittanceLUTPushConstants=^TTransmittanceLUTPushConstants;
            TMultiScatteringLUTPushConstants=packed record
             BaseViewIndex:TpvInt32;
             CountViews:TpvInt32;
             MultipleScatteringFactor:TpvFloat;
             FrameIndex:TpvUInt32;
            end;
            PMultiScatteringLUTPushConstants=^TMultiScatteringLUTPushConstants;
            TSkyLuminanceLUTPushConstants=packed record
             BaseViewIndex:TpvInt32;
             CountViews:TpvInt32;
             FrameIndex:TpvUInt32;
            end;
            PSkyLuminanceLUTPushConstants=^TSkyLuminanceLUTPushConstants;
            TSkyViewLUTPushConstants=packed record
             BaseViewIndex:TpvInt32;
             CountViews:TpvInt32;
             FrameIndex:TpvUInt32;
             Dummy1:TpvInt32;
            end;
            PSkyViewLUTPushConstants=^TSkyViewLUTPushConstants;
            TCameraVolumePushConstants=packed record
             BaseViewIndex:TpvInt32;
             CountViews:TpvInt32;
             FrameIndex:TpvUInt32;
             Dummy1:TpvInt32;
            end;
            TCubeMapPushConstants=packed record
             CameraPosition:TpvVector4; // w = unused, for alignment
             UpVector:TpvVector4; // w = unused, for alignment
            end;
            PCubeMapPushConstants=^TCubeMapPushConstants;
            TCloudRaymarchingPushConstants=packed record
             BaseViewIndex:TpvInt32;
             CountViews:TpvInt32;
             FrameIndex:TpvUInt32;
             Flags:TpvUInt32;
             CountSamples:TpvUInt32;
            end;
            PCloudRaymarchingPushConstants=^TCloudRaymarchingPushConstants;
            TRaymarchingPushConstants=packed record
             BaseViewIndex:TpvInt32;
             CountViews:TpvInt32;
             FrameIndex:TpvUInt32;
             Flags:TpvUInt32;
             CountSamples:TpvUInt32;
            end;
            PRaymarchingPushConstants=^TRaymarchingPushConstants;
            TCloudWeatherMapPushConstants=packed record
             CoverageRotation:TpvVector4;
             TypeRotation:TpvVector4;
             WetnessRotation:TpvVector4;
             TopRotation:TpvVector4;
             CoveragePerlinWorleyDifference:TpvFloat;
             TotalSize:TpvFloat;
             WorleySeed:TpvFloat;
            end;
            PCloudWeatherMapPushConstants=^TCloudWeatherMapPushConstants;
            TDirectionalMapTextureInitializationPushConstants=record
             Value:TpvVector4;
            end;
            PDirectionalMapTextureInitializationPushConstants=^TDirectionalMapTextureInitializationPushConstants;
      private
       fScene3D:TObject;
       fAtmospheres:TpvScene3DAtmospheres;
       fTransmittanceLUTPassDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fMultiScatteringLUTPassDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fSkyLuminanceLUTPassDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fSkyViewLUTPassDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fCameraVolumePassDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fCubeMapPassDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fCloudRaymarchingPassDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fRaymarchingPassDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fGlobalVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fWeatherMapTextureDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fDirectionalMapTextureInitializationDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fDirectionalMapTextureTransferDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fDirectionalMapTextureScanDescriptorSetLayout:TpvVulkanDescriptorSetLayout;
       fTransmittanceLUTComputeShaderModule:TpvVulkanShaderModule;
       fTransmittanceLUTComputeShaderStage:TpvVulkanPipelineShaderStage;
       fTransmittanceLUTComputePipelineLayout:TpvVulkanPipelineLayout;
       fTransmittanceLUTComputePipeline:TpvVulkanComputePipeline;
       fMultiScatteringLUTComputeShaderModule:TpvVulkanShaderModule;
       fMultiScatteringLUTComputeShaderStage:TpvVulkanPipelineShaderStage;
       fMultiScatteringLUTComputePipelineLayout:TpvVulkanPipelineLayout;
       fMultiScatteringLUTComputePipeline:TpvVulkanComputePipeline;
       fSkyLuminanceLUTComputeShaderModule:TpvVulkanShaderModule;
       fSkyLuminanceLUTComputeShaderStage:TpvVulkanPipelineShaderStage;
       fSkyLuminanceLUTComputePipelineLayout:TpvVulkanPipelineLayout;
       fSkyLuminanceLUTComputePipeline:TpvVulkanComputePipeline; 
       fSkyViewLUTComputeShaderModule:TpvVulkanShaderModule;
       fSkyViewLUTComputeShaderStage:TpvVulkanPipelineShaderStage;
       fSkyViewLUTComputePipelineLayout:TpvVulkanPipelineLayout;
       fSkyViewLUTComputePipeline:TpvVulkanComputePipeline;
       fCameraVolumeComputeShaderModule:TpvVulkanShaderModule;
       fCameraVolumeComputeShaderStage:TpvVulkanPipelineShaderStage;
       fCameraVolumeComputePipelineLayout:TpvVulkanPipelineLayout;
       fCameraVolumeComputePipeline:TpvVulkanComputePipeline;
       fCubeMapComputeShaderModule:TpvVulkanShaderModule;
       fCubeMapComputeShaderStage:TpvVulkanPipelineShaderStage;
       fCubeMapComputePipelineLayout:TpvVulkanPipelineLayout;
       fCubeMapComputePipeline:TpvVulkanComputePipeline;
       fCloudRaymarchingPipelineLayout:TpvVulkanPipelineLayout;
       fRaymarchingPipelineLayout:TpvVulkanPipelineLayout;
       fCloudWeatherMapComputeShaderModule:TpvVulkanShaderModule;
       fCloudWeatherMapComputeShaderStage:TpvVulkanPipelineShaderStage;
       fCloudWeatherMapComputePipelineLayout:TpvVulkanPipelineLayout;
       fCloudWeatherMapComputePipeline:TpvVulkanComputePipeline;
       fCloudCurlTexture:TpvScene3DRendererMipmapImage3D;
       fCloudDetailTexture:TpvScene3DRendererMipmapImage3D;
       fCloudShapeTexture:TpvScene3DRendererMipmapImage3D;
       fDirectionalMapTextureInitializationComputeShaderModule:TpvVulkanShaderModule;
       fDirectionalMapTextureInitializationComputeShaderStage:TpvVulkanPipelineShaderStage;
       fDirectionalMapTextureInitializationComputePipelineLayout:TpvVulkanPipelineLayout;
       fDirectionalMapTextureInitializationComputePipeline:TpvVulkanComputePipeline;
       fDirectionalMapTextureTransferComputeR8UNormShaderModule:TpvVulkanShaderModule;
       fDirectionalMapTextureTransferComputeR8UNormShaderStage:TpvVulkanPipelineShaderStage;
       fDirectionalMapTextureTransferComputeR8SNormShaderModule:TpvVulkanShaderModule;
       fDirectionalMapTextureTransferComputeR8SNormShaderStage:TpvVulkanPipelineShaderStage;
       fDirectionalMapTextureTransferComputePipelineLayout:TpvVulkanPipelineLayout;
       fDirectionalMapTextureTransferComputeR8UNormPipeline:TpvVulkanComputePipeline;
       fDirectionalMapTextureTransferComputeR8SNormPipeline:TpvVulkanComputePipeline;
       fDirectionalMapTextureScanComputeShaderModule:TpvVulkanShaderModule;
       fDirectionalMapTextureScanComputeShaderStage:TpvVulkanPipelineShaderStage;
       fDirectionalMapTextureScanComputePipelineLayout:TpvVulkanPipelineLayout;
       fDirectionalMapTextureScanComputePipeline:TpvVulkanComputePipeline;       
      public
       constructor Create(const aScene3D:TObject);
       destructor Destroy; override;
       procedure AllocateResources;
       procedure DeallocateResources;
      published
       property Scene3D:TObject read fScene3D;
       property Atmospheres:TpvScene3DAtmospheres read fAtmospheres;
      public
       property TransmittanceLUTPassDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fTransmittanceLUTPassDescriptorSetLayout;
       property MultiScatteringLUTPassDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fMultiScatteringLUTPassDescriptorSetLayout;
       property SkyLuminanceLUTPassDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fSkyLuminanceLUTPassDescriptorSetLayout;
       property SkyViewLUTPassDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fSkyViewLUTPassDescriptorSetLayout;
       property CameraVolumePassDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fCameraVolumePassDescriptorSetLayout;
       property CubeMapPassDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fCubeMapPassDescriptorSetLayout;
       property CloudRaymarchingPassDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fCloudRaymarchingPassDescriptorSetLayout;
       property RaymarchingPassDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fRaymarchingPassDescriptorSetLayout;
       property GlobalVulkanDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fGlobalVulkanDescriptorSetLayout;
       property WeatherMapTextureDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fWeatherMapTextureDescriptorSetLayout;
       property DirectionalMapTextureInitializationDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fDirectionalMapTextureInitializationDescriptorSetLayout;
       property DirectionalMapTextureTransferDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fDirectionalMapTextureTransferDescriptorSetLayout;
       property DirectionalMapTextureScanDescriptorSetLayout:TpvVulkanDescriptorSetLayout read fDirectionalMapTextureScanDescriptorSetLayout;
       property CloudRaymarchingPipelineLayout:TpvVulkanPipelineLayout read fCloudRaymarchingPipelineLayout;
       property RaymarchingPipelineLayout:TpvVulkanPipelineLayout read fRaymarchingPipelineLayout;
     end;

     { TpvScene3DAtmosphere }
     TpvScene3DAtmosphere=class
      public
       const TRANSMITTANCE_TEXTURE_WIDTH=256;
             TRANSMITTANCE_TEXTURE_HEIGHT=64;
             SCATTERING_TEXTURE_R_SIZE=32;
             SCATTERING_TEXTURE_MU_SIZE=128;
             SCATTERING_TEXTURE_MU_S_SIZE=32;
             SCATTERING_TEXTURE_NU_SIZE=8;
             SCATTERING_TEXTURE_WIDTH=SCATTERING_TEXTURE_NU_SIZE*SCATTERING_TEXTURE_MU_S_SIZE;
             SCATTERING_TEXTURE_HEIGHT=SCATTERING_TEXTURE_MU_SIZE;
             SCATTERING_TEXTURE_DEPTH=SCATTERING_TEXTURE_R_SIZE;             
             IRRADIANCE_TEXTURE_WIDTH=64;
             IRRADIANCE_TEXTURE_HEIGHT=16;
             SkyViewLUTTextureWidth=256;
             SkyViewLUTTextureHeight=128;
             CameraVolumeTextureWidth=32;
             CameraVolumeTextureHeight=32;
             CameraVolumeTextureDepth=32;
             CubeMapTextureSize=32;
             MultiScatteringLUTRes=32;
             SkyLuminanceLUTRes=8;
             ScatteringOrders=4;
       type { TDensityProfileLayer }
            TDensityProfileLayer=packed record
             public
              Width:TpvFloat;
              ExpTerm:TpvFloat;
              ExpScale:TpvFloat;
              LinearTerm:TpvFloat;
              ConstantTerm:TpvFloat;
              Unused0:TpvFloat;
              Unused1:TpvFloat;
              Unused2:TpvFloat;
              constructor Create(const aWidth,aExpTerm,aExpScale,aLinearTerm,aConstantTerm:TpvFloat);
            end;
            PDensityProfileLayer=^TDensityProfileLayer;
            { TDensityProfile }
            TDensityProfile=packed record
             public
             Layers:array[0..1] of TDensityProfileLayer;
            end;
            { TAtmosphereCullingParameters }
            TAtmosphereCullingParameters=packed record
             public
              procedure CalculateBoundingSphere;
             public
              InnerFadeDistance:TpvFloat;
              OuterFadeDistance:TpvFloat;
              CountFaces:TpvUInt32;             
              Mode:TpvUInt32;
              InversedTransform:TpvMatrix4x4;
              BoundingSphere:TpvVector4;
              case TpvInt32 of
               0:(
                FacePlanes:array[0..31] of TpvVector4;
               );
               1:(
                Center:TpvVector4;
                HalfExtents:TpvVector4;
               );
               2:(
                CenterRadius:TpvVector4;
               );
            end;
            PAtmosphereCullingParameters=^TAtmosphereCullingParameters;            
            { TVolumetricCloudLayerLow }
            TVolumetricCloudLayerLow=packed record
             public
          
              Orientation:TpvQuaternion;

              StartHeight:TpvFloat;
              EndHeight:TpvFloat;
              PositionScale:TpvFloat;
              ShapeNoiseScale:TpvFloat;
          
              DetailNoiseScale:TpvFloat;
              CurlScale:TpvFloat;
              AdvanceCurlScale:TpvFloat;
              AdvanceCurlAmplitude:TpvFloat;
          
              HeightGradients:array[0..2] of TpvVector4; // mat3x4
              AnvilDeformations:array[0..2] of TpvVector4; // mat3x4 unused for now
          
              procedure Initialize;
              procedure LoadFromJSON(const aJSON:TPasJSONItem);
              procedure LoadFromJSONStream(const aStream:TStream);
              procedure LoadFromJSONFile(const aFileName:string);
              function SaveToJSON:TPasJSONItemObject;
              procedure SaveToJSONStream(const aStream:TStream);
              procedure SaveToJSONFile(const aFileName:string);
            end;
            PVolumetricCloudLayerLow=^TVolumetricCloudLayerLow;
            { TVolumetricCloudLayerHigh }
            TVolumetricCloudLayerHigh=packed record
             public

              Orientation:TpvQuaternion;
          
              StartHeight:TpvFloat;
              EndHeight:TpvFloat;
              PositionScale:TpvFloat;
              Density:TpvFloat;
          
              CoverMin:TpvFloat;
              CoverMax:TpvFloat;
              FadeMin:TpvFloat;
              FadeMax:TpvFloat;
          
              Speed:TpvFloat;
              Padding0:TpvFloat;
              Padding1:TpvFloat;
              Padding2:TpvFloat;
          
              RotationBase:TpvVector4;
          
              RotationOctave1:TpvVector4;
          
              RotationOctave2:TpvVector4;
          
              RotationOctave3:TpvVector4;
          
              OctaveScales:TpvVector4;
          
              OctaveFactors:TpvVector4;
          
              procedure Initialize;
              procedure LoadFromJSON(const aJSON:TPasJSONItem);
              procedure LoadFromJSONStream(const aStream:TStream);
              procedure LoadFromJSONFile(const aFileName:string);
              function SaveToJSON:TPasJSONItemObject;
              procedure SaveToJSONStream(const aStream:TStream);
              procedure SaveToJSONFile(const aFileName:string);

            end;
            PVolumetricCloudLayerHigh=^TVolumetricCloudLayerHigh;
            { TVolumetricCloudParameters }
            TVolumetricCloudParameters=packed record
             public
          
              DryCoverageTypeWetnessTopFactors:TpvVector4; // x = Coverage, y = Type, z = Wetness, w = Top
          
              DryCoverageTypeWetnessTopOffsets:TpvVector4; // x = Coverage, y = Type, z = Wetness, w = Top

              WetCoverageTypeWetnessTopFactors:TpvVector4; // x = Coverage, y = Type, z = Wetness, w = Top
          
              WetCoverageTypeWetnessTopOffsets:TpvVector4; // x = Coverage, y = Type, z = Wetness, w = Top
          
              Scattering:TpvVector4; // w = unused
          
              Absorption:TpvVector4; // w = unused
          
              LightingDensity:TpvFloat;
              ShadowDensity:TpvFloat;
              ViewDensity:TpvFloat;
              DensityScale:TpvFloat;
          
              Scale:TpvFloat;
              ForwardScatteringG:TpvFloat;
              BackwardScatteringG:TpvFloat;
              ShadowRayLength:TpvFloat;
          
              DensityAlongConeLength:TpvFloat;
              DensityAlongConeLengthFarMultiplier:TpvFloat;
              RayMinSteps:TpvUInt32;
              RayMaxSteps:TpvUInt32;

              OuterSpaceRayMinSteps:TpvUInt32;
              OuterSpaceRayMaxSteps:TpvUInt32;

              DirectScatteringIntensity:TpvFloat;
              IndirectScatteringIntensity:TpvFloat;

              AmbientLightIntensity:TpvFloat;
              WetnessDensityFactor:TpvFloat;
              WetnessLuminanceFactor:TpvFloat;
              Padding0:TpvFloat;

              LayerLow:TVolumetricCloudLayerLow;
          
              LayerHigh:TVolumetricCloudLayerHigh;

              procedure Initialize;
              procedure LoadFromJSON(const aJSON:TPasJSONItem);
              procedure LoadFromJSONStream(const aStream:TStream);
              procedure LoadFromJSONFile(const aFileName:string);
              function SaveToJSON:TPasJSONItemObject;
              procedure SaveToJSONStream(const aStream:TStream);
              procedure SaveToJSONFile(const aFileName:string);

            end;
            PVolumetricCloudParameters=^TVolumetricCloudParameters;
            { TAtmosphereParameters }
            TAtmosphereParameters=packed record             
             public
              Transform:TpvMatrix4x4D; // Transform of the atmosphere for the case that the atmosphere is not centered at the origin (e.g. multiple planets)
              RayleighDensity:TDensityProfile;
              MieDensity:TDensityProfile;
              AbsorptionDensity:TDensityProfile;
              Center:TpvVector4; // w is unused, for alignment
              SunDirection:TpvVector4; // w is unused, for alignment
              SolarIrradiance:TpvVector4; // w is unused, for alignment
              RayleighScattering:TpvVector4; // w is unused, for alignment
              MieScattering:TpvVector4; // w is unused, for alignment
              MieExtinction:TpvVector4; // w is unused, for alignment
              AbsorptionExtinction:TpvVector4; // w is unused, for alignment
              GroundAlbedo:TpvVector4; // w is unused, for alignment
              FadeFactor:TpvFloat;
              Intensity:TpvFloat;
              MiePhaseFunctionG:TpvFloat;
              SunAngularRadius:TpvFloat;
              BottomRadius:TpvFloat;
              TopRadius:TpvFloat;
              MuSMin:TpvFloat;
              RaymarchingMinSteps:TpvInt32;
              RaymarchingMaxSteps:TpvInt32;
              MaxShadowDistance:TpvFloat;
              RainAtmosphereCubeMapLuminanceFactor:TpvFloat;
              AtmosphereCullingParameters:TAtmosphereCullingParameters;
              VolumetricClouds:TVolumetricCloudParameters;
              procedure InitializeEarthAtmosphere(const aEarthBottomRadius:TpvFloat=6360.0;
                                                  const aEarthTopRadius:TpvFloat=6460.0;
                                                  const aEarthRayleighScaleHeight:TpvFloat=8.0;
                                                  const aEarthMieScaleHeight:TpvFloat=1.2);
              procedure LoadFromJSON(const aJSON:TPasJSONItem);
              procedure LoadFromJSONStream(const aStream:TStream);
              procedure LoadFromJSONFile(const aFileName:string);
              function SaveToJSON:TPasJSONItemObject;
              procedure SaveToJSONStream(const aStream:TStream);
              procedure SaveToJSONFile(const aFileName:string);
              procedure LoadFromPOCA(const aPOCACode:TpvUTF8String);
              procedure LoadFromPOCAStream(const aStream:TStream);
              procedure LoadFromPOCAFile(const aFileName:string);
            end;
            PAtmosphereParameters=^TAtmosphereParameters;
            { TGPUVolumetricCloudLayerLow }
            TGPUVolumetricCloudLayerLow=packed record
             public

              Orientation:TpvQuaternion;

              StartHeight:TpvFloat;
              EndHeight:TpvFloat;
              PositionScale:TpvFloat;
              ShapeNoiseScale:TpvFloat;
             
              DetailNoiseScale:TpvFloat;
              CurlScale:TpvFloat;
              AdvanceCurlScale:TpvFloat;
              AdvanceCurlAmplitude:TpvFloat;
             
              HeightGradients:array[0..2] of TpvVector4; // mat3x4
              
              AnvilDeformations:array[0..2] of TpvVector4; // mat3x4 unused for now

              procedure Assign(const aVolumetricCloudLayerLow:TVolumetricCloudLayerLow);
            end;
            PGPUVolumetricCloudLayerLow=^TGPUVolumetricCloudLayerLow;
            { TGPUVolumetricCloudLayerHigh }
            TGPUVolumetricCloudLayerHigh=packed record
             public
              
              Orientation:TpvQuaternion;

              StartHeight:TpvFloat;
              EndHeight:TpvFloat;              
              PositionScale:TpvFloat;
              Density:TpvFloat;

              CoverMin:TpvFloat;
              CoverMax:TpvFloat;
              FadeMin:TpvFloat;
              FadeMax:TpvFloat;
              
              Speed:TpvFloat;
              Padding0:TpvFloat;
              Padding1:TpvFloat;
              Padding2:TpvFloat;

              RotationBase:TpvVector4;
              
              RotationOctave1:TpvVector4;
              
              RotationOctave2:TpvVector4;
              
              RotationOctave3:TpvVector4;
              
              OctaveScales:TpvVector4;
              
              OctaveFactors:TpvVector4;
              
              procedure Assign(const aVolumetricCloudLayerHigh:TVolumetricCloudLayerHigh);
            end;
            PGPUVolumetricCloudLayerHigh=^TGPUVolumetricCloudLayerHigh;
            { TGPUVolumetricCloudParameters }
            TGPUVolumetricCloudParameters=packed record
             public
             
              DryCoverageTypeWetnessTopFactors:TpvVector4; // x = Coverage, y = Type, z = Wetness, w = Top
             
              DryCoverageTypeWetnessTopOffsets:TpvVector4; // x = Coverage, y = Type, z = Wetness, w = Top
             
              WetCoverageTypeWetnessTopFactors:TpvVector4; // x = Coverage, y = Type, z = Wetness, w = Top
             
              WetCoverageTypeWetnessTopOffsets:TpvVector4; // x = Coverage, y = Type, z = Wetness, w = Top
             
              Scattering:TpvVector4; // w = unused
             
              Absorption:TpvVector4; // w = unused
             
              LightingDensity:TpvFloat;
              ShadowDensity:TpvFloat;
              ViewDensity:TpvFloat;
              DensityScale:TpvFloat;
             
              Scale:TpvFloat;
              ForwardScatteringG:TpvFloat;
              BackwardScatteringG:TpvFloat;
              ShadowRayLength:TpvFloat;
             
              DensityAlongConeLength:TpvFloat;
              DensityAlongConeLengthFarMultiplier:TpvFloat;
              RayMinSteps:TpvUInt32;
              RayMaxSteps:TpvUInt32;
             
              OuterSpaceRayMinSteps:TpvUInt32;
              OuterSpaceRayMaxSteps:TpvUInt32;
              DirectScatteringIntensity:TpvFloat;
              IndirectScatteringIntensity:TpvFloat;

              AmbientLightIntensity:TpvFloat;
              WetnessDensityFactor:TpvFloat;
              WetnessLuminanceFactor:TpvFloat;
              Padding0:TpvFloat;

              LayerLow:TGPUVolumetricCloudLayerLow;
              LayerHigh:TGPUVolumetricCloudLayerHigh;
             
              procedure Assign(const aVolumetricCloudParameters:TVolumetricCloudParameters);
            end;
            { TGPUAtmosphereCullingParameters }
            TGPUAtmosphereCullingParameters=packed record
             public
              procedure Assign(const aAtmosphereCullingParameters:TAtmosphereCullingParameters);
             public
              InnerFadeDistance:TpvFloat;
              OuterFadeDistance:TpvFloat;
              CountFaces:TpvUInt32;
              Mode:TpvUInt32;
              InversedTransform:TpvMatrix4x4;
              BoundingSphere:TpvVector4;
              case TpvInt32 of
               0:(
                FacePlanes:array[0..31] of TpvVector4;
               );
               1:(
                Center:TpvVector4;
                HalfExtents:TpvVector4;
               );
               2:(
                CenterRadius:TpvVector4;
               );
            end;
            { TGPUAtmosphereParameters }
            TGPUAtmosphereParameters=packed record
             public

              Transform:TpvMatrix4x4; // Transform of the atmosphere for the case that the atmosphere is not centered at the origin (e.g. multiple planets)

              InverseTransform:TpvMatrix4x4; // Transform of the atmosphere for the case that the atmosphere is not centered at the origin (e.g. multiple planets)

              OriginTransform:TpvMatrix4x4;

              InverseOriginTransform:TpvMatrix4x4;

              RayleighScattering:TpvVector4; // w = Mu_S_min

              MieScattering:TpvVector4; // w = sun direction X

              MieExtinction:TpvVector4; // w = sun direction Y

              MieAbsorption:TpvVector4; // w = sun direction Z

              AbsorptionExtinction:TpvVector4; // w = Fade factor, 0.0 = no atmosphere, 1.0 = full atmosphere

              GroundAlbedo:TpvVector4; // w = intensity

              SolarIrradiance:TpvVector4; // w = intensity

              BottomRadius:TpvFloat;
              TopRadius:TpvFloat;
              RayleighDensityExpScale:TpvFloat;
              MieDensityExpScale:TpvFloat;

              MiePhaseG:TpvFloat;
              AbsorptionDensity0LayerWidth:TpvFloat;
              AbsorptionDensity0ConstantTerm:TpvFloat;
              AbsorptionDensity0LinearTerm:TpvFloat;

              AbsorptionDensity1ConstantTerm:TpvFloat;
              AbsorptionDensity1LinearTerm:TpvFloat;              
              RaymarchingMinSteps:TpvInt32;
              RaymarchingMaxSteps:TpvInt32;

              MaxShadowDistance:TpvFloat;
              Flags:TpvUInt32;
              RainAtmosphereCubeMapLuminanceFactor:TpvFloat;
              Unused1:TpvInt32;

              AtmosphereCullingParameters:TGPUAtmosphereCullingParameters;

              VolumetricClouds:TGPUVolumetricCloudParameters;

              procedure Assign(const aAtmosphereParameters:TAtmosphereParameters;const aScene3D:TObject;const aInFlightFrameIndex:TpvSizeInt);
            end;
            PGPUAtmosphereParameters=^TGPUAtmosphereParameters;
            { TRendererInstance }
            TRendererInstance=class
             public
              type { TKey }
                   TKey=record
                    public
                     fRendererInstance:TObject;
                    public
                     constructor Create(const aRendererInstance:TObject);
                   end;
                   PKey=^TKey;
             private
              fAtmosphere:TpvScene3DAtmosphere;
              fRendererInstance:TObject;
              fKey:TKey;
              fTransmittanceTexture:TpvScene3DRendererImage2D;
              fMultiScatteringTexture:TpvScene3DRendererImage2D;
              fSkyLuminanceLUTTexture:TpvScene3DRendererImageCubeMap;
              fSkyViewLUTTexture:TpvScene3DRendererArray2DImage;
              fCameraVolumeTexture:TpvScene3DRendererArray2DImage;
              fSkyViewLUTTextureImageLayout:TVkImageLayout;
              fCameraVolumeTextureImageLayout:TVkImageLayout;
              fCubeMapTexture:TpvScene3DRendererMipmapImageCubeMap;
              fGGXCubeMapTexture:TpvScene3DRendererMipmapImageCubeMap;
              fCharlieCubeMapTexture:TpvScene3DRendererMipmapImageCubeMap;
              fLambertianCubeMapTexture:TpvScene3DRendererMipmapImageCubeMap;
              fTransmittanceLUTPassDescriptorPool:TpvVulkanDescriptorPool;
              fTransmittanceLUTPassDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
              fMultiScatteringLUTPassDescriptorPool:TpvVulkanDescriptorPool;
              fMultiScatteringLUTPassDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
              fSkyLuminanceLUTPassDescriptorPool:TpvVulkanDescriptorPool;
              fSkyLuminanceLUTPassDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
              fSkyViewLUTPassDescriptorPool:TpvVulkanDescriptorPool;
              fSkyViewLUTPassDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
              fCameraVolumePassDescriptorPool:TpvVulkanDescriptorPool;
              fCameraVolumePassDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
              fCubeMapPassDescriptorPool:TpvVulkanDescriptorPool;
              fCubeMapPassDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
              fCloudRaymarchingPassDescriptorPool:TpvVulkanDescriptorPool;
              fCloudRaymarchingPassDepthImageViews:array[0..MaxInFlightFrames-1] of TVkImageView;
              fCloudRaymarchingPassCascadedShadowMapImageViews:array[0..MaxInFlightFrames-1] of TVkImageView;
              fCloudRaymarchingPassDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
              fCloudRaymarchingPassDescriptorSetFirsts:array[0..MaxInFlightFrames-1] of boolean;
              fRaymarchingPassDescriptorPool:TpvVulkanDescriptorPool;
              fRaymarchingPassDepthImageViews:array[0..MaxInFlightFrames-1] of TVkImageView;
              fRaymarchingPassCascadedShadowMapImageViews:array[0..MaxInFlightFrames-1] of TVkImageView;
              fRaymarchingPassCloudsInscatteringImageViews:array[0..MaxInFlightFrames-1] of TVkImageView;
              fRaymarchingPassCloudsTransmittanceImageViews:array[0..MaxInFlightFrames-1] of TVkImageView;
              fRaymarchingPassCloudsDepthImageViews:array[0..MaxInFlightFrames-1] of TVkImageView;
              fRaymarchingPassDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
              fRaymarchingPassDescriptorSetFirsts:array[0..MaxInFlightFrames-1] of boolean;
              fGlobalDescriptorPool:TpvVulkanDescriptorPool;
              fGlobalDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
              fCubeMapMipMapGenerator:TpvScene3DRendererCubeMapMipMapGenerator;
              fGGXCubeMapIBLFilter:TpvScene3DRendererCubeMapIBLFilter;
              fCharlieCubeMapIBLFilter:TpvScene3DRendererCubeMapIBLFilter;
              fLambertianCubeMapIBLFilter:TpvScene3DRendererCubeMapIBLFilter;
             public
              constructor Create(const aAtmosphere:TpvScene3DAtmosphere;const aRendererInstance:TObject);
              destructor Destroy; override;
              procedure AfterConstruction; override;
              procedure BeforeDestruction; override;
              procedure SetCloudsImageViews(const aInFlightFrameIndex:TpvSizeInt;
                                            const aDepthImageView:TVkImageView;
                                            const aCascadedShadowMapImageView:TVkImageView);
              procedure SetImageViews(const aInFlightFrameIndex:TpvSizeInt;
                                      const aDepthImageView:TVkImageView;
                                      const aCascadedShadowMapImageView:TVkImageView;
                                      const aCloudsInscatteringImageView:TVkImageView;
                                      const aCloudsTransmittanceImageView:TVkImageView;
                                      const aCloudsDepthImageView:TVkImageView);
              procedure Setup(const aRenderPass:TpvVulkanRenderPass;
                              const aRenderPassSubpassIndex:TpvSizeInt;
                              const aSampleCount:TVkSampleCountFlagBits;
                              const aWidth:TpvSizeInt;
                              const aHeight:TpvSizeInt);
              procedure ReleaseGraphicsPipeline;
              procedure Execute(const aInFlightFrameIndex:TpvSizeInt;
                                const aCommandBuffer:TpvVulkanCommandBuffer);
              procedure DrawClouds(const aInFlightFrameIndex:TpvSizeInt;
                                   const aCommandBuffer:TpvVulkanCommandBuffer;
                                   const aDepthImageView:TVkImageView;
                                   const aCascadedShadowMapImageView:TVkImageView);
              procedure Draw(const aInFlightFrameIndex:TpvSizeInt;
                             const aCommandBuffer:TpvVulkanCommandBuffer;
                             const aDepthImageView:TVkImageView;
                             const aCascadedShadowMapImageView:TVkImageView;
                             const aCloudsInscatteringImageView:TVkImageView;
                             const aCloudsTransmittanceImageView:TVkImageView;
                             const aCloudsDepthImageView:TVkImageView;
                             var aPushConstants:TpvScene3DAtmosphereGlobals.TRaymarchingPushConstants);
             published
              property Atmosphere:TpvScene3DAtmosphere read fAtmosphere;
              property RendererInstance:TObject read fRendererInstance;
              property TransmittanceTexture:TpvScene3DRendererImage2D read fTransmittanceTexture;
              property MultiScatteringTexture:TpvScene3DRendererImage2D read fMultiScatteringTexture;
              property SkyLuminanceLUTTexture:TpvScene3DRendererImageCubeMap read fSkyLuminanceLUTTexture;
              property SkyViewLUTTexture:TpvScene3DRendererArray2DImage read fSkyViewLUTTexture;
              property CameraVolumeTexture:TpvScene3DRendererArray2DImage read fCameraVolumeTexture; 
              property CubeMapTexture:TpvScene3DRendererMipmapImageCubeMap read fCubeMapTexture;
              property GGXCubeMapTexture:TpvScene3DRendererMipmapImageCubeMap read fGGXCubeMapTexture;
              property CharlieCubeMapTexture:TpvScene3DRendererMipmapImageCubeMap read fCharlieCubeMapTexture;
              property LambertianCubeMapTexture:TpvScene3DRendererMipmapImageCubeMap read fLambertianCubeMapTexture;
            end;
            { TRendererInstances }
            TRendererInstances=TpvObjectGenericList<TRendererInstance>;
            { TRendererInstanceHashMap }
            TRendererInstanceHashMap=TpvHashMap<TRendererInstance.TKey,TRendererInstance>;
            { TDirectionalMap }
            TDirectionalMap=class
             private
              const Precipitation=0;
                    Atmosphere=1;
                    Names:array[0..1] of TpvUTF8String=('Precipitation','Atmosphere');
             private
              fScene3D:TObject;
              fAtmosphere:TpvScene3DAtmosphere;
              fType:TpvUInt32;
              fName:TpvUTF8String;
              fTexture:TpvScene3DRendererImageCubeMap;
              fTextureInitializationDescriptorPool:TpvVulkanDescriptorPool;
              fTextureInitializationDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
              fTextureTransferDescriptorPool:TpvVulkanDescriptorPool;
              fTextureTransferDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
              fTextureScanDescriptorPool:TpvVulkanDescriptorPool;
              fTextureScanDescriptorSet:TpvVulkanDescriptorSet;
              fTextureGeneration:TpvUInt64;
              fTextureLastGeneration:TpvUInt64;
              fTextureSourceImage:TpvScene3DRendererImage2D;
             public
              constructor Create(const aScene3D:TObject;const aAtmosphere:TpvScene3DAtmosphere;const aType:TpvUInt32); reintroduce;
              destructor Destroy; override;
              procedure AfterConstruction; override;
              procedure BeforeDestruction; override;
              procedure AcquireResources;
              procedure ReleaseResources;
              procedure Update(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex:TpvSizeInt;const aQueueFamilyIndex:TpvInt32=-1);
             public
              property TextureSourceImage:TpvScene3DRendererImage2D read fTextureSourceImage write fTextureSourceImage;
              property TextureGeneration:TpvUInt64 read fTextureGeneration write fTextureGeneration;
              property TextureLastGeneration:TpvUInt64 read fTextureLastGeneration write fTextureLastGeneration;
            end;
      private
       fScene3D:TObject;
       fAtmosphereParameters:TAtmosphereParameters;
       fPointerToAtmosphereParameters:PAtmosphereParameters;
       fGPUAtmosphereParameters:array[0..MaxInFlightFrames-1] of TGPUAtmosphereParameters;
       fAtmosphereParametersBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
       fAtmosphereMapMinMaxBuffer:TpvVulkanBuffer;
       fWeatherMapTexture:TpvScene3DRendererImageCubeMap;
       fWeatherMapTextureDescriptorPool:TpvVulkanDescriptorPool;
       fWeatherMapTextureDescriptorSets:array[0..MaxInFlightFrames-1] of TpvVulkanDescriptorSet;
       fWeatherMapTextureGeneration:TpvUInt64;
       fWeatherMapTextureLastGeneration:TpvUInt64;
       fCloudWeatherMapPushConstants:TpvScene3DAtmosphereGlobals.TCloudWeatherMapPushConstants;
       fPrecipitationMap:TDirectionalMap;
       fAtmosphereMap:TDirectionalMap;
       fUsePrecipitationMap:TPasMPBool32;
       fUseAtmosphereMap:TPasMPBool32;
       fRendererInstances:TRendererInstances;
       fRendererInstanceHashMap:TRendererInstanceHashMap;
       fRendererInstanceListLock:TPasMPSlimReaderWriterLock;
       fToDestroy:boolean;
       fReleaseFrameCounter:TpvInt32;
       fReady:TPasMPBool32;
       fUploaded:LongBool;
       fVisible:Boolean;
       fInFlightFrameVisible:array[0..MaxInFlightFrames-1] of boolean;
      public
       constructor Create(const aScene3D:TObject);
       destructor Destroy; override;
       procedure AfterConstruction; override;
       procedure BeforeDestruction; override;
       procedure Release;
       function HandleRelease:boolean;
       procedure Upload;
       procedure Unload;
       procedure Update(const aInFlightFrameIndex:TpvSizeInt);
       procedure UploadFrame(const aInFlightFrameIndex:TpvSizeInt;
                             const aTransferQueue:TpvVulkanQueue;
                             const aTransferCommandBuffer:TpvVulkanCommandBuffer;
                             const aTransferFence:TpvVulkanFence);
       function IsInFlightFrameVisible(const aInFlightFrameIndex:TpvSizeInt):Boolean;
       function GetRenderInstance(const aRendererInstance:TObject):TpvScene3DAtmosphere.TRendererInstance;
       procedure ProcessSimulation(const aCommandBuffer:TpvVulkanCommandBuffer;
                                   const aInFlightFrameIndex:TpvSizeInt;
                                   const aQueueFamilyIndex:TpvInt32=-1);
       procedure Execute(const aInFlightFrameIndex:TpvSizeInt;
                         const aCommandBuffer:TpvVulkanCommandBuffer;
                         const aRendererInstance:TObject);
       procedure DrawClouds(const aInFlightFrameIndex:TpvSizeInt;
                            const aCommandBuffer:TpvVulkanCommandBuffer;
                            const aDepthImageView:TVkImageView;
                            const aCascadedShadowMapImageView:TVkImageView;
                            const aRendererInstance:TObject);
       procedure Draw(const aInFlightFrameIndex:TpvSizeInt;
                      const aCommandBuffer:TpvVulkanCommandBuffer;
                      const aDepthImageView:TVkImageView;
                      const aCascadedShadowMapImageView:TVkImageView;
                      const aCloudsInscatteringImageView:TVkImageView;
                      const aCloudsTransmittanceImageView:TVkImageView;
                      const aCloudsDepthImageView:TVkImageView;
                      const aRendererInstance:TObject;
                      var aPushConstants:TpvScene3DAtmosphereGlobals.TRaymarchingPushConstants);
      public
       property AtmosphereParameters:PAtmosphereParameters read fPointerToAtmosphereParameters;
       property PrecipitationMap:TDirectionalMap read fPrecipitationMap;
       property AtmosphereMap:TDirectionalMap read fAtmosphereMap;
       property UsePrecipitationMap:TPasMPBool32 read fUsePrecipitationMap write fUsePrecipitationMap;
       property UseAtmosphereMap:TPasMPBool32 read fUseAtmosphereMap write fUseAtmosphereMap;
       property Ready:TPasMPBool32 read fReady;
       property Uploaded:LongBool read fUploaded;
       property Visible:Boolean read fVisible;
     end; 

     { TpvScene3DAtmospheres }
     TpvScene3DAtmospheres=class(TpvObjectGenericList<TpvScene3DAtmosphere>)
      private
       fScene3D:TObject;
       fLock:TPasMPMultipleReaderSingleWriterLock;
      public
       constructor Create(const aScene3D:TObject); reintroduce;
       destructor Destroy; override;
       procedure ProcessReleases;
       procedure DrawClouds(const aInFlightFrameIndex:TpvSizeInt;
                            const aCommandBuffer:TpvVulkanCommandBuffer;
                            const aDepthImageView:TVkImageView;
                            const aCascadedShadowMapImageView:TVkImageView;
                            const aRendererInstance:TObject);
       procedure Draw(const aInFlightFrameIndex:TpvSizeInt;
                      const aCommandBuffer:TpvVulkanCommandBuffer;
                      const aDepthImageView:TVkImageView;
                      const aCascadedShadowMapImageView:TVkImageView;
                      const aCloudsInscatteringImageView:TVkImageView;
                      const aCloudsTransmittanceImageView:TVkImageView;
                      const aCloudsDepthImageView:TVkImageView;
                      const aRendererInstance:TObject;
                      var aPushConstants:TpvScene3DAtmosphereGlobals.TRaymarchingPushConstants);
      published
       property Scene3D:TObject read fScene3D;
       property Lock:TPasMPMultipleReaderSingleWriterLock read fLock;
     end;

     { TpvScene3DAtmosphereRendererInstance }
     TpvScene3DAtmosphereRendererInstance=class
      public
       // The passes are for all frustum visible atmospheres in the scene in a row for a renderer instance
       type TTransmittanceLUTPass=class 
             private
              fAtmosphereRendererInstance:TpvScene3DAtmosphereRendererInstance;
              fPipeline:TpvVulkanComputePipeline;
             public
              constructor Create(const aAtmosphereRendererInstance:TpvScene3DAtmosphereRendererInstance);
              destructor Destroy; override;
              procedure AfterConstruction; override;
              procedure BeforeDestruction; override;
              procedure Execute(const aVulkanCommandBuffer:TpvVulkanCommandBuffer);
            end; 
      private
       fScene3D:TObject;
       fRenderer:TObject;
       fRendererInstance:TObject;
       fVulkanComputeQueue:TpvVulkanQueue;
       fVulkanComputeCommandPool:TpvVulkanCommandPool;
       fVulkanComputeCommandBuffer:TpvVulkanCommandBuffer;       
      public
       constructor Create(const aScene3D,aRenderer,aRendererInstance:TObject);
       destructor Destroy; override;
       procedure AfterConstruction; override;
       procedure BeforeDestruction; override;
       procedure AllocateResources;
       procedure DeallocateResources;
      published
     end;

implementation

uses PasVulkan.Scene3D,
     PasVulkan.Scene3D.Assets,
     PasVulkan.Scene3D.Renderer,
     PasVulkan.Scene3D.Renderer.Globals,
     PasVulkan.Scene3D.Renderer.Instance,
     PasVulkan.JSON;

{ TpvScene3DAtmosphere.TDensityProfileLayer }

constructor TpvScene3DAtmosphere.TDensityProfileLayer.Create(const aWidth,aExpTerm,aExpScale,aLinearTerm,aConstantTerm:TpvFloat);
begin
 Width:=aWidth;
 ExpTerm:=aExpTerm;
 ExpScale:=aExpScale;
 LinearTerm:=aLinearTerm;
 ConstantTerm:=aConstantTerm;
end;

{ TpvScene3DAtmosphere.TAtmosphereCullingParameters }

procedure TpvScene3DAtmosphere.TAtmosphereCullingParameters.CalculateBoundingSphere;
var FaceIndex:TpvSizeInt;
    s:TpvSphere;
    cx,cy,cz:TpvDouble;
    p:PpvVector4;
begin
 case Mode and $f of
  1:begin
   s.Center:=CenterRadius.xyz;
   s.Radius:=CenterRadius.w;
  end;
  2:begin
   s:=TpvSphere.CreateFromAABB(TpvAABB.Create(Center.xyz-HalfExtents.xyz,Center.xyz+HalfExtents.xyz));
  end;
  3:begin
   if CountFaces>0 then begin
    cx:=0.0;
    cy:=0.0;
    cz:=0.0;
    for FaceIndex:=0 to TpvSizeInt(CountFaces)-1 do begin
     p:=@FacePlanes[FaceIndex];
     cx:=cx+(p^.x*(-p^.w));
     cy:=cy+(p^.y*(-p^.w));
     cz:=cz+(p^.z*(-p^.w));
    end;
    s.Center:=TpvVector3.InlineableCreate(cx/CountFaces,cy/CountFaces,cz/CountFaces);
    s.Radius:=0.0;
    for FaceIndex:=0 to TpvSizeInt(CountFaces)-1 do begin
     p:=@FacePlanes[FaceIndex];
     s.Radius:=Max(s.Radius,(s.Center-(p^.xyz*(-p^.w))).Length);
    end;
    s.Radius:=s.Radius*2.0;
   end else begin
    s.Center:=TpvVector3.Origin;
    s.Radius:=0.0;
   end;
  end;
 end;
 BoundingSphere.xyz:=s.Center;
 BoundingSphere.w:=s.Radius+(OuterFadeDistance*2.0);
end;

{ TpvScene3DAtmosphere.TVolumetricCloudLayerLow }

procedure TpvScene3DAtmosphere.TVolumetricCloudLayerLow.Initialize;
begin
 Orientation:=TpvQuaternion.Identity;
 StartHeight:=6380.0;
 EndHeight:=6400.0;
 PositionScale:=0.0005;
 ShapeNoiseScale:=1.0;
 DetailNoiseScale:=1.0;
 CurlScale:=1.0;
 AdvanceCurlScale:=0.25;
 AdvanceCurlAmplitude:=0.25;
 HeightGradients[0]:=TpvVector4.InlineableCreate(0.0200,0.0500,0.0900,0.1100);  // Stratus
 HeightGradients[1]:=TpvVector4.InlineableCreate(0.0199,0.2000,0.4800,0.6250);  // Cumulus
 HeightGradients[2]:=TpvVector4.InlineableCreate(0.0100,0.0625,0.7500,1.0000); // Cumulonimbus
 AnvilDeformations[0]:=TpvVector4.InlineableCreate(0.0,1.0,1.0,1.0);
 AnvilDeformations[1]:=TpvVector4.InlineableCreate(0.0,1.0,1.0,1.0);
 AnvilDeformations[2]:=TpvVector4.InlineableCreate(0.0,1.0,1.0,1.0);
end;

procedure TpvScene3DAtmosphere.TVolumetricCloudLayerLow.LoadFromJSON(const aJSON:TPasJSONItem);
var JSONRootObject:TPasJSONItemObject;
    JSONArray:TPasJSONItemArray;
    JSONItem:TPasJSONItem;
    Index:TpvSizeInt;
begin

 if assigned(aJSON) and (aJSON is TPasJSONItemObject) then begin
  
  JSONRootObject:=TPasJSONItemObject(aJSON);
  
  Orientation.Vector:=JSONToVector4(JSONRootObject.Properties['orientation'],Orientation.Vector);
  StartHeight:=TPasJSON.GetNumber(JSONRootObject.Properties['startheight'],StartHeight);
  EndHeight:=TPasJSON.GetNumber(JSONRootObject.Properties['endheight'],EndHeight);
  PositionScale:=TPasJSON.GetNumber(JSONRootObject.Properties['positionscale'],PositionScale);
  ShapeNoiseScale:=TPasJSON.GetNumber(JSONRootObject.Properties['shapenoisescale'],ShapeNoiseScale);
  DetailNoiseScale:=TPasJSON.GetNumber(JSONRootObject.Properties['detailnoisescale'],DetailNoiseScale);
  CurlScale:=TPasJSON.GetNumber(JSONRootObject.Properties['curlscale'],CurlScale);
  AdvanceCurlScale:=TPasJSON.GetNumber(JSONRootObject.Properties['advancecurlscale'],AdvanceCurlScale);
  AdvanceCurlAmplitude:=TPasJSON.GetNumber(JSONRootObject.Properties['advancecurlamplitude'],AdvanceCurlAmplitude);
  
  JSONItem:=JSONRootObject.Properties['heightgradients'];
  if assigned(JSONItem) and (JSONItem is TPasJSONItemArray) then begin
   JSONArray:=TPasJSONItemArray(JSONItem);
   for Index:=0 to Min(JSONArray.Count,3)-1 do begin
    HeightGradients[Index]:=JSONToVector4(JSONArray.Items[Index],HeightGradients[Index]);
   end;
  end;

  JSONItem:=JSONRootObject.Properties['anvildeformations'];
  if assigned(JSONItem) and (JSONItem is TPasJSONItemArray) then begin
   JSONArray:=TPasJSONItemArray(JSONItem);
   for Index:=0 to Min(JSONArray.Count,3)-1 do begin
    AnvilDeformations[Index]:=JSONToVector4(JSONArray.Items[Index],AnvilDeformations[Index]);
   end;
  end;
  
 end;
 
end;

procedure TpvScene3DAtmosphere.TVolumetricCloudLayerLow.LoadFromJSONStream(const aStream:TStream);
var JSON:TPasJSONItem;
begin
 JSON:=TPasJSON.Parse(aStream);
 if assigned(JSON) then begin
  try
   LoadFromJSON(JSON);
  finally
   FreeAndNil(JSON);
  end;
 end;
end;

procedure TpvScene3DAtmosphere.TVolumetricCloudLayerLow.LoadFromJSONFile(const aFileName:string);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  Stream.LoadFromFile(aFileName);
  Stream.Seek(0,soBeginning);
  LoadFromJSONStream(Stream);
 finally
  Stream.Free;
 end;
end;

function TpvScene3DAtmosphere.TVolumetricCloudLayerLow.SaveToJSON:TPasJSONItemObject;
var JSONArray:TPasJSONItemArray;
    Index:TpvInt32;
begin

 result:=TPasJSONItemObject.Create;
 result.Add('orientation',Vector4ToJSON(Orientation.Vector));
 result.Add('startheight',TPasJSONItemNumber.Create(StartHeight));
 result.Add('endheight',TPasJSONItemNumber.Create(EndHeight));
 result.Add('positionscale',TPasJSONItemNumber.Create(PositionScale));
 result.Add('shapenoisescale',TPasJSONItemNumber.Create(ShapeNoiseScale));
 result.Add('detailnoisescale',TPasJSONItemNumber.Create(DetailNoiseScale));
 result.Add('curlscale',TPasJSONItemNumber.Create(CurlScale));
 result.Add('advancecurlscale',TPasJSONItemNumber.Create(AdvanceCurlScale));
 result.Add('advancecurlamplitude',TPasJSONItemNumber.Create(AdvanceCurlAmplitude));

 JSONArray:=TPasJSONItemArray.Create;
 try
  for Index:=0 to 2 do begin
   JSONArray.Add(Vector4ToJSON(HeightGradients[Index]));
  end;
 finally
  result.Add('heightgradients',JSONArray);
 end;

 JSONArray:=TPasJSONItemArray.Create;
 try
  for Index:=0 to 2 do begin
   JSONArray.Add(Vector4ToJSON(AnvilDeformations[Index]));
  end;
 finally
  result.Add('anvildeformations',JSONArray);
 end;

end;

procedure TpvScene3DAtmosphere.TVolumetricCloudLayerLow.SaveToJSONStream(const aStream:TStream);
var JSON:TPasJSONItem;
begin
 JSON:=SaveToJSON;
 if assigned(JSON) then begin
  try
   TPasJSON.StringifyToStream(aStream,JSON,true);
  finally
   FreeAndNil(JSON);
  end;
 end;
end;

procedure TpvScene3DAtmosphere.TVolumetricCloudLayerLow.SaveToJSONFile(const aFileName:string);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  SaveToJSONStream(Stream);
  Stream.Seek(0,soBeginning);
  Stream.SaveToFile(aFileName);
 finally
  Stream.Free;
 end;
end;

{ TpvScene3DAtmosphere.TVolumetricCloudLayerHigh }

procedure TpvScene3DAtmosphere.TVolumetricCloudLayerHigh.Initialize;
begin
 Orientation:=TpvQuaternion.Identity;
 StartHeight:=6420.0;
 EndHeight:=6440.0;
 PositionScale:=0.1;
 Density:=0.015625;
 CoverMin:=0.5;
 CoverMax:=0.7;
 FadeMin:=0.01;
 FadeMax:=0.01;
 Speed:=0.0;
 RotationBase:=TpvVector4.InlineableCreate(-1.0,0.0,1.0,1.0);
 RotationOctave1:=TpvVector4.InlineableCreate(-1.0,0.0,1.0,0.125);
 RotationOctave2:=TpvVector4.InlineableCreate(-1.0,0.0,1.0,-0.125);
 RotationOctave3:=TpvVector4.InlineableCreate(-1.0,0.0,1.0,0.0625);
 OctaveScales:=TpvVector4.InlineableCreate(1.0,2.0,7.0,16.0);
 OctaveFactors:=TpvVector4.InlineableCreate(0.5,0.25,0.125,0.0625);
end;

procedure TpvScene3DAtmosphere.TVolumetricCloudLayerHigh.LoadFromJSON(const aJSON:TPasJSONItem);
var JSONRootObject:TPasJSONItemObject;
begin
 if assigned(aJSON) and (aJSON is TPasJSONItemObject) then begin
  JSONRootObject:=TPasJSONItemObject(aJSON);
  Orientation.Vector:=JSONToVector4(JSONRootObject.Properties['orientation'],Orientation.Vector);
  StartHeight:=TPasJSON.GetNumber(JSONRootObject.Properties['startheight'],StartHeight);
  EndHeight:=TPasJSON.GetNumber(JSONRootObject.Properties['endheight'],EndHeight);
  PositionScale:=TPasJSON.GetNumber(JSONRootObject.Properties['positionscale'],PositionScale);
  Density:=TPasJSON.GetNumber(JSONRootObject.Properties['density'],Density);
  CoverMin:=TPasJSON.GetNumber(JSONRootObject.Properties['covermin'],CoverMin);
  CoverMax:=TPasJSON.GetNumber(JSONRootObject.Properties['covermax'],CoverMax);
  FadeMin:=TPasJSON.GetNumber(JSONRootObject.Properties['fademin'],FadeMin);
  FadeMax:=TPasJSON.GetNumber(JSONRootObject.Properties['fademax'],FadeMax);
  Speed:=TPasJSON.GetNumber(JSONRootObject.Properties['speed'],Speed);
  RotationBase:=JSONToVector4(JSONRootObject.Properties['rotationbase'],RotationBase);
  RotationOctave1:=JSONToVector4(JSONRootObject.Properties['rotationoctave1'],RotationOctave1);
  RotationOctave2:=JSONToVector4(JSONRootObject.Properties['rotationoctave2'],RotationOctave2);
  RotationOctave3:=JSONToVector4(JSONRootObject.Properties['rotationoctave3'],RotationOctave3);
  OctaveScales:=JSONToVector4(JSONRootObject.Properties['octavescales'],OctaveScales);
  OctaveFactors:=JSONToVector4(JSONRootObject.Properties['octavefactors'],OctaveFactors);
 end;
end;

procedure TpvScene3DAtmosphere.TVolumetricCloudLayerHigh.LoadFromJSONStream(const aStream:TStream);
var JSON:TPasJSONItem;
begin
 JSON:=TPasJSON.Parse(aStream);
 if assigned(JSON) then begin
  try
   LoadFromJSON(JSON);
  finally
   FreeAndNil(JSON);
  end;
 end;
end;

procedure TpvScene3DAtmosphere.TVolumetricCloudLayerHigh.LoadFromJSONFile(const aFileName:string);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  Stream.LoadFromFile(aFileName);
  Stream.Seek(0,soBeginning);
  LoadFromJSONStream(Stream);
 finally
  Stream.Free;
 end;
end;

function TpvScene3DAtmosphere.TVolumetricCloudLayerHigh.SaveToJSON:TPasJSONItemObject;
begin
 result:=TPasJSONItemObject.Create;
 result.Add('orientation',Vector4ToJSON(Orientation.Vector));
 result.Add('startheight',TPasJSONItemNumber.Create(StartHeight));
 result.Add('endheight',TPasJSONItemNumber.Create(EndHeight));
 result.Add('positionscale',TPasJSONItemNumber.Create(PositionScale));
 result.Add('density',TPasJSONItemNumber.Create(Density));
 result.Add('covermin',TPasJSONItemNumber.Create(CoverMin));
 result.Add('covermax',TPasJSONItemNumber.Create(CoverMax));
 result.Add('fademin',TPasJSONItemNumber.Create(FadeMin));
 result.Add('fademax',TPasJSONItemNumber.Create(FadeMax));
 result.Add('speed',TPasJSONItemNumber.Create(Speed));
 result.Add('rotationbase',Vector4ToJSON(RotationBase));
 result.Add('rotationoctave1',Vector4ToJSON(RotationOctave1));
 result.Add('rotationoctave2',Vector4ToJSON(RotationOctave2));
 result.Add('rotationoctave3',Vector4ToJSON(RotationOctave3));
 result.Add('octavescales',Vector4ToJSON(OctaveScales));
 result.Add('octavefactors',Vector4ToJSON(OctaveFactors));
end;

procedure TpvScene3DAtmosphere.TVolumetricCloudLayerHigh.SaveToJSONStream(const aStream:TStream);
var JSON:TPasJSONItem;
begin
 JSON:=SaveToJSON;
 if assigned(JSON) then begin
  try
   TPasJSON.StringifyToStream(aStream,JSON,true);
  finally
   FreeAndNil(JSON);
  end;
 end;
end;

procedure TpvScene3DAtmosphere.TVolumetricCloudLayerHigh.SaveToJSONFile(const aFileName:string);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  SaveToJSONStream(Stream);
  Stream.Seek(0,soBeginning);
  Stream.SaveToFile(aFileName);
 finally
  Stream.Free;
 end;
end;

{ TpvScene3DAtmosphere.TVolumetricCloudParameters }

procedure TpvScene3DAtmosphere.TVolumetricCloudParameters.Initialize;
begin
 DryCoverageTypeWetnessTopFactors:=TpvVector4.InlineableCreate(1.0,1.0,1.0,1.0);
 DryCoverageTypeWetnessTopOffsets:=TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0);
 WetCoverageTypeWetnessTopFactors:=TpvVector4.InlineableCreate(1.0,1.0,1.0,1.0);
 WetCoverageTypeWetnessTopOffsets:=TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0);
 Scattering:=TpvVector4.InlineableCreate(1.0,1.0,1.0,0.0);
 Absorption:=TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0);
 LightingDensity:=1.0;
 ShadowDensity:=1.0;
 ViewDensity:=1.0;
 DensityScale:=1.0;
 Scale:=1.0;
 ForwardScatteringG:=0.5;
 BackwardScatteringG:=-0.8;
 ShadowRayLength:=1.0;
 DensityAlongConeLength:=1.0;
 DensityAlongConeLengthFarMultiplier:=3.0;
 RayMinSteps:=64;
 RayMaxSteps:=128;
 OuterSpaceRayMinSteps:=64;
 OuterSpaceRayMaxSteps:=256;
 DirectScatteringIntensity:=1.0;
 IndirectScatteringIntensity:=1.0;
 AmbientLightIntensity:=1.0;
 WetnessDensityFactor:=2.0;
 WetnessLuminanceFactor:=0.25;
 LayerLow.Initialize;
 LayerHigh.Initialize;
end;

procedure TpvScene3DAtmosphere.TVolumetricCloudParameters.LoadFromJSON(const aJSON:TPasJSONItem);
var JSONRootObject:TPasJSONItemObject;
begin
 if assigned(aJSON) and (aJSON is TPasJSONItemObject) then begin
  JSONRootObject:=TPasJSONItemObject(aJSON);
  DryCoverageTypeWetnessTopFactors:=JSONToVector4(JSONRootObject.Properties['drycoveragetypewetnesstopfactors'],JSONToVector4(JSONRootObject.Properties['coveragetypewetnesstopfactors'],DryCoverageTypeWetnessTopFactors));
  DryCoverageTypeWetnessTopOffsets:=JSONToVector4(JSONRootObject.Properties['drycoveragetypewetnesstopoffsets'],JSONToVector4(JSONRootObject.Properties['coveragetypewetnesstopoffsets'],DryCoverageTypeWetnessTopOffsets));
  WetCoverageTypeWetnessTopFactors:=JSONToVector4(JSONRootObject.Properties['wetcoveragetypewetnesstopfactors'],JSONToVector4(JSONRootObject.Properties['coveragetypewetnesstopfactors'],WetCoverageTypeWetnessTopFactors));
  WetCoverageTypeWetnessTopOffsets:=JSONToVector4(JSONRootObject.Properties['wetcoveragetypewetnesstopoffsets'],JSONToVector4(JSONRootObject.Properties['coveragetypewetnesstopoffsets'],WetCoverageTypeWetnessTopOffsets));
  Scattering.xyz:=JSONToVector3(JSONRootObject.Properties['scattering'],Scattering.xyz);
  Absorption.xyz:=JSONToVector3(JSONRootObject.Properties['absorption'],Absorption.xyz);
  LightingDensity:=TPasJSON.GetNumber(JSONRootObject.Properties['lightingdensity'],LightingDensity);
  ShadowDensity:=TPasJSON.GetNumber(JSONRootObject.Properties['shadowdensity'],ShadowDensity);
  ViewDensity:=TPasJSON.GetNumber(JSONRootObject.Properties['viewdensity'],ViewDensity);
  DensityScale:=TPasJSON.GetNumber(JSONRootObject.Properties['densityscale'],DensityScale);
  Scale:=TPasJSON.GetNumber(JSONRootObject.Properties['scale'],Scale);
  ForwardScatteringG:=TPasJSON.GetNumber(JSONRootObject.Properties['forwardscatteringg'],ForwardScatteringG);
  BackwardScatteringG:=TPasJSON.GetNumber(JSONRootObject.Properties['backwardscatteringg'],BackwardScatteringG);
  ShadowRayLength:=TPasJSON.GetNumber(JSONRootObject.Properties['shadowraylength'],ShadowRayLength);
  DensityAlongConeLength:=TPasJSON.GetNumber(JSONRootObject.Properties['densityalongconelength'],DensityAlongConeLength);
  DensityAlongConeLengthFarMultiplier:=TPasJSON.GetNumber(JSONRootObject.Properties['densityalongconelengthfarmultiplier'],DensityAlongConeLengthFarMultiplier);
  RayMinSteps:=TPasJSON.GetInt64(JSONRootObject.Properties['rayminsteps'],RayMinSteps);
  RayMaxSteps:=TPasJSON.GetInt64(JSONRootObject.Properties['raymaxsteps'],RayMaxSteps);
  OuterSpaceRayMinSteps:=TPasJSON.GetInt64(JSONRootObject.Properties['outerspacerayminsteps'],OuterSpaceRayMinSteps);
  OuterSpaceRayMaxSteps:=TPasJSON.GetInt64(JSONRootObject.Properties['outerspaceraymaxsteps'],OuterSpaceRayMaxSteps);
  DirectScatteringIntensity:=TPasJSON.GetNumber(JSONRootObject.Properties['directscatteringintensity'],DirectScatteringIntensity);
  IndirectScatteringIntensity:=TPasJSON.GetNumber(JSONRootObject.Properties['indirectscatteringintensity'],IndirectScatteringIntensity);
  AmbientLightIntensity:=TPasJSON.GetNumber(JSONRootObject.Properties['ambientlightintensity'],AmbientLightIntensity);
  WetnessDensityFactor:=TPasJSON.GetNumber(JSONRootObject.Properties['wetnessdensityfactor'],WetnessDensityFactor);
  WetnessLuminanceFactor:=TPasJSON.GetNumber(JSONRootObject.Properties['wetnessluminancefactor'],WetnessLuminanceFactor);
  LayerLow.LoadFromJSON(JSONRootObject.Properties['layerlow']);
  LayerHigh.LoadFromJSON(JSONRootObject.Properties['layerhigh']);
 end;
end;

procedure TpvScene3DAtmosphere.TVolumetricCloudParameters.LoadFromJSONStream(const aStream:TStream);
var JSON:TPasJSONItem;
begin
 JSON:=TPasJSON.Parse(aStream);
 if assigned(JSON) then begin
  try
   LoadFromJSON(JSON);
  finally
   FreeAndNil(JSON);
  end;
 end;
end;

procedure TpvScene3DAtmosphere.TVolumetricCloudParameters.LoadFromJSONFile(const aFileName:string);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  Stream.LoadFromFile(aFileName);
  Stream.Seek(0,soBeginning);
  LoadFromJSONStream(Stream);
 finally
  Stream.Free;
 end;
end;

function TpvScene3DAtmosphere.TVolumetricCloudParameters.SaveToJSON:TPasJSONItemObject;
begin
 result:=TPasJSONItemObject.Create;
 result.Add('drycoveragetypewetnesstopfactors',Vector4ToJSON(DryCoverageTypeWetnessTopFactors));
 result.Add('drycoveragetypewetnesstopoffsets',Vector4ToJSON(DryCoverageTypeWetnessTopOffsets));
 result.Add('wetcoveragetypewetnesstopfactors',Vector4ToJSON(WetCoverageTypeWetnessTopFactors));
 result.Add('wetcoveragetypewetnesstopoffsets',Vector4ToJSON(WetCoverageTypeWetnessTopOffsets));
 result.Add('scattering',Vector3ToJSON(Scattering.xyz));
 result.Add('absorption',Vector3ToJSON(Absorption.xyz));
 result.Add('lightingdensity',TPasJSONItemNumber.Create(LightingDensity));
 result.Add('shadowdensity',TPasJSONItemNumber.Create(ShadowDensity));
 result.Add('viewdensity',TPasJSONItemNumber.Create(ViewDensity));
 result.Add('densityscale',TPasJSONItemNumber.Create(DensityScale));
 result.Add('scale',TPasJSONItemNumber.Create(Scale));
 result.Add('forwardscatteringg',TPasJSONItemNumber.Create(ForwardScatteringG));
 result.Add('backwardscatteringg',TPasJSONItemNumber.Create(BackwardScatteringG));
 result.Add('shadowraylength',TPasJSONItemNumber.Create(ShadowRayLength));
 result.Add('densityalongconelength',TPasJSONItemNumber.Create(DensityAlongConeLength));
 result.Add('densityalongconelengthfarmultiplier',TPasJSONItemNumber.Create(DensityAlongConeLengthFarMultiplier));
 result.Add('rayminsteps',TPasJSONItemNumber.Create(RayMinSteps));
 result.Add('raymaxsteps',TPasJSONItemNumber.Create(RayMaxSteps));
 result.Add('outerspacerayminsteps',TPasJSONItemNumber.Create(OuterSpaceRayMinSteps));
 result.Add('outerspaceraymaxsteps',TPasJSONItemNumber.Create(OuterSpaceRayMaxSteps));
 result.Add('directscatteringintensity',TPasJSONItemNumber.Create(DirectScatteringIntensity));
 result.Add('indirectscatteringintensity',TPasJSONItemNumber.Create(IndirectScatteringIntensity));
 result.Add('ambientlightintensity',TPasJSONItemNumber.Create(AmbientLightIntensity));
 result.Add('wetnessdensityfactor',TPasJSONItemNumber.Create(WetnessDensityFactor));
 result.Add('wetnessluminancefactor',TPasJSONItemNumber.Create(WetnessLuminanceFactor));
 result.Add('layerlow',LayerLow.SaveToJSON);
 result.Add('layerhigh',LayerHigh.SaveToJSON);
end;

procedure TpvScene3DAtmosphere.TVolumetricCloudParameters.SaveToJSONStream(const aStream:TStream);
var JSON:TPasJSONItem;
begin
 JSON:=SaveToJSON;
 if assigned(JSON) then begin
  try
   TPasJSON.StringifyToStream(aStream,JSON,true);
  finally
   FreeAndNil(JSON);
  end;
 end;
end;

procedure TpvScene3DAtmosphere.TVolumetricCloudParameters.SaveToJSONFile(const aFileName:string);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  SaveToJSONStream(Stream);
  Stream.Seek(0,soBeginning);
  Stream.SaveToFile(aFileName);
 finally
  Stream.Free;
 end;
end;

{ TpvScene3DAtmosphere.TAtmosphereParameters }

procedure TpvScene3DAtmosphere.TAtmosphereParameters.InitializeEarthAtmosphere(const aEarthBottomRadius:TpvFloat;
                                                                               const aEarthTopRadius:TpvFloat;
                                                                               const aEarthRayleighScaleHeight:TpvFloat;
                                                                               const aEarthMieScaleHeight:TpvFloat);
begin
 
 // Transform
 Transform:=TpvMatrix4x4.Identity;

 // Center
 Center:=TpvVector4.Origin;

 // Sun direction
 SunDirection:=TpvVector4.InlineableCreate(0.0,0.90045,0.43497,0.0).Normalize;

 // Sun
 SolarIrradiance:=TpvVector4.InlineableCreate(1.0,1.0,1.0,1.0);
 SunAngularRadius:=0.004675;

 // Planet
 BottomRadius:=aEarthBottomRadius;
 TopRadius:=aEarthTopRadius;
 GroundAlbedo:=TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0);

 // Fade factor
 FadeFactor:=1.0;

 // Intensity 
 Intensity:=1.0;

 // Rayleigh scattering
 RayleighDensity.Layers[0]:=TDensityProfileLayer.Create(0.0,0.0,0.0,0.0,0.0);
 RayleighDensity.Layers[1]:=TDensityProfileLayer.Create(0.0,1.0,-1.0/aEarthRayleighScaleHeight,0.0,0.0);
 RayleighScattering:=TpvVector4.InlineableCreate(0.005802,0.013558,0.033100,0.0);

 // Mie scattering
 MieDensity.Layers[0]:=TDensityProfileLayer.Create(0.0,0.0,0.0,0.0,0.0);
 MieDensity.Layers[1]:=TDensityProfileLayer.Create(0.0,1.0,-1.0/aEarthMieScaleHeight,0.0,0.0);
 MieScattering:=TpvVector4.InlineableCreate(0.003996,0.003996,0.003996,0.0);
 MieExtinction:=TpvVector4.InlineableCreate(0.004440,0.004440,0.004440,0.0);
 MiePhaseFunctionG:=0.8;

 // Absorption extinction / Ozone layer
 AbsorptionDensity.Layers[0]:=TDensityProfileLayer.Create(25.0,0.0,0.0,1.0/15.0,-2.0/3.0);
 AbsorptionDensity.Layers[1]:=TDensityProfileLayer.Create(0.0,0.0,0.0,-1.0/15.0,8.0/3.0);
 AbsorptionExtinction:=TpvVector4.InlineableCreate(0.000650,0.001881,0.000085,0.0);

 // MuSMin
 MuSMin:=cos(PI*120.0/180.0);

 // Raymarching min/max steps
 RaymarchingMinSteps:=4;
 RaymarchingMaxSteps:=14;

 // Maximal shadow distance, none for now
 MaxShadowDistance:=0.0;

 // Rain atmosphere cubeMap luminance factor for darkening the atmosphere where rain is present, for indirect lighting
 RainAtmosphereCubeMapLuminanceFactor:=0.1;  

 // Atmosphere culling
 FillChar(AtmosphereCullingParameters,SizeOf(TAtmosphereCullingParameters),#0);

 // Volumetric clouds
 VolumetricClouds.Initialize;

end;

procedure TpvScene3DAtmosphere.TAtmosphereParameters.LoadFromJSON(const aJSON:TPasJSONItem);
var JSONRootObject:TPasJSONItemObject;
    JSON:TPasJSONItem;
    Factor:TpvFloat;
 procedure LoadDensityProfileLayer(const aJSON:TPasJSONItem;var aLayer:TDensityProfileLayer);
 var JSONLayer:TPasJSONItemObject;
 begin
  if assigned(aJSON) and (aJSON is TPasJSONItemObject) then begin
   JSONLayer:=TPasJSONItemObject(aJSON);
   aLayer.Width:=TPasJSON.GetNumber(JSONLayer.Properties['width'],aLayer.Width);
   aLayer.ExpTerm:=TPasJSON.GetNumber(JSONLayer.Properties['expterm'],aLayer.ExpTerm);
   aLayer.ExpScale:=TPasJSON.GetNumber(JSONLayer.Properties['expscale'],aLayer.ExpScale);
   aLayer.LinearTerm:=TPasJSON.GetNumber(JSONLayer.Properties['linearterm'],aLayer.LinearTerm);
   aLayer.ConstantTerm:=TPasJSON.GetNumber(JSONLayer.Properties['constantterm'],aLayer.ConstantTerm);
  end;  
 end;
 procedure LoadRaymarching(const aJSON:TPasJSONItem);
 var JSONObject:TPasJSONItemObject;
 begin
  if assigned(aJSON) and (aJSON is TPasJSONItemObject) then begin
   JSONObject:=TPasJSONItemObject(aJSON);
   RaymarchingMinSteps:=Min(Max(TPasJSON.GetInt64(JSONObject.Properties['minsteps'],RaymarchingMinSteps),1),256);
   RaymarchingMaxSteps:=Min(Max(TPasJSON.GetInt64(JSONObject.Properties['maxsteps'],RaymarchingMaxSteps),1),256);
  end;
 end; 
begin
 
 if assigned(aJSON) and (aJSON is TPasJSONItemObject) then begin
  
  JSONRootObject:=TPasJSONItemObject(aJSON);

  Transform:=JSONToMatrix4x4(JSONRootObject.Properties['transform'],Transform);

  Factor:=TPasJSON.GetNumber(JSONRootObject.Properties['scatteringcoefficientscale'],1.0);

  SolarIrradiance:=JSONToVector4(JSONRootObject.Properties['solarirradiance'],SolarIrradiance);
  SunAngularRadius:=TPasJSON.GetNumber(JSONRootObject.Properties['sunangularradius'],SunAngularRadius);
  
  BottomRadius:=TPasJSON.GetNumber(JSONRootObject.Properties['bottomradius'],BottomRadius);
  TopRadius:=TPasJSON.GetNumber(JSONRootObject.Properties['topradius'],TopRadius);
  GroundAlbedo.xyz:=JSONToVector3(JSONRootObject.Properties['groundalbedo'],GroundAlbedo.xyz);

  FadeFactor:=TPasJSON.GetNumber(JSONRootObject.Properties['fadefactor'],FadeFactor);
  
  Intensity:=TPasJSON.GetNumber(JSONRootObject.Properties['intensity'],Intensity);

  LoadDensityProfileLayer(JSONRootObject.Properties['rayleighdensity0'],RayleighDensity.Layers[0]);
  LoadDensityProfileLayer(JSONRootObject.Properties['rayleighdensity1'],RayleighDensity.Layers[1]);
  RayleighScattering.xyz:=JSONToVector3(JSONRootObject.Properties['rayleighscattering'],RayleighScattering.xyz/Factor)*Factor;
  
  LoadDensityProfileLayer(JSONRootObject.Properties['miedensity0'],MieDensity.Layers[0]);
  LoadDensityProfileLayer(JSONRootObject.Properties['miedensity1'],MieDensity.Layers[1]);
  MieScattering.xyz:=JSONToVector3(JSONRootObject.Properties['miescattering'],MieScattering.xyz/Factor)*Factor;
  MieExtinction.xyz:=JSONToVector3(JSONRootObject.Properties['mieextinction'],MieExtinction.xyz/Factor)*Factor;
  MiePhaseFunctionG:=TPasJSON.GetNumber(JSONRootObject.Properties['miephasefunctiong'],MiePhaseFunctionG);

  LoadDensityProfileLayer(JSONRootObject.Properties['absorptiondensity0'],AbsorptionDensity.Layers[0]);
  LoadDensityProfileLayer(JSONRootObject.Properties['absorptiondensity1'],AbsorptionDensity.Layers[1]);
  AbsorptionExtinction.xyz:=JSONToVector3(JSONRootObject.Properties['absorptionextinction'],AbsorptionExtinction.xyz/Factor)*Factor;

  //SunDirection.xyz:=JSONToVector3(JSONRootObject.Properties['sundirection'],SunDirection.xyz);

  //MuSMin:=TPasJSON.GetNumber(JSONRootObject.Properties['musmin'],MuSMin);

  MaxShadowDistance:=TPasJSON.GetNumber(JSONRootObject.Properties['maxshadowdistance'],MaxShadowDistance);

  RainAtmosphereCubeMapLuminanceFactor:=TPasJSON.GetNumber(JSONRootObject.Properties['rainatmospherecubemapluminancefactor'],RainAtmosphereCubeMapLuminanceFactor);

  LoadRaymarching(JSONRootObject.Properties['raymarching']);

  VolumetricClouds.LoadFromJSON(JSONRootObject.Properties['volumetricclouds']);

 end;

end;

procedure TpvScene3DAtmosphere.TAtmosphereParameters.LoadFromJSONStream(const aStream:TStream);
var JSON:TPasJSONItem;
begin
 JSON:=TPasJSON.Parse(aStream);
 if assigned(JSON) then begin
  try
   LoadFromJSON(JSON);
  finally
   FreeAndNil(JSON);
  end;
 end;
end;

procedure TpvScene3DAtmosphere.TAtmosphereParameters.LoadFromJSONFile(const aFileName:string);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  Stream.LoadFromFile(aFileName);
  LoadFromJSONStream(Stream);
 finally
  FreeAndNil(Stream);
 end;
end;

function TpvScene3DAtmosphere.TAtmosphereParameters.SaveToJSON:TPasJSONItemObject;
 function SaveDensityLayer(const aLayer:TDensityProfileLayer):TPasJSONItemObject;
 begin
  result:=TPasJSONItemObject.Create;
  result.Add('width',TPasJSONItemNumber.Create(aLayer.Width));
  result.Add('expterm',TPasJSONItemNumber.Create(aLayer.ExpTerm));
  result.Add('expscale',TPasJSONItemNumber.Create(aLayer.ExpScale));
  result.Add('linearterm',TPasJSONItemNumber.Create(aLayer.LinearTerm));
  result.Add('constantterm',TPasJSONItemNumber.Create(aLayer.ConstantTerm));
 end;
 function SaveRaymarching:TPasJSONItemObject;
 begin
  result:=TPasJSONItemObject.Create;
  result.Add('minsteps',TPasJSONItemNumber.Create(RaymarchingMinSteps));
  result.Add('maxsteps',TPasJSONItemNumber.Create(RaymarchingMaxSteps));
 end;
begin
 result:=TPasJSONItemObject.Create;
 result.Add('transform',Matrix4x4ToJSON(Transform));
 result.Add('scatteringcoefficientscale',TPasJSONItemNumber.Create(1.0));
 result.Add('solarirradiance',Vector4ToJSON(SolarIrradiance));
 result.Add('sunangularradius',TPasJSONItemNumber.Create(SunAngularRadius));
 result.Add('bottomradius',TPasJSONItemNumber.Create(BottomRadius));
 result.Add('topradius',TPasJSONItemNumber.Create(TopRadius));
 result.Add('groundalbedo',Vector3ToJSON(GroundAlbedo.xyz));
 result.Add('fadefactor',TPasJSONItemNumber.Create(FadeFactor));
 result.Add('intensity',TPasJSONItemNumber.Create(Intensity));
 result.Add('rayleighdensity0',SaveDensityLayer(RayleighDensity.Layers[0]));
 result.Add('rayleighdensity1',SaveDensityLayer(RayleighDensity.Layers[1]));
 result.Add('rayleighscattering',Vector3ToJSON(RayleighScattering.xyz));
 result.Add('miedensity0',SaveDensityLayer(MieDensity.Layers[0]));
 result.Add('miedensity1',SaveDensityLayer(MieDensity.Layers[1]));
 result.Add('miescattering',Vector3ToJSON(MieScattering.xyz));
 result.Add('mieextinction',Vector3ToJSON(MieExtinction.xyz));
 result.Add('miephasefunctiong',TPasJSONItemNumber.Create(MiePhaseFunctionG));
 result.Add('absorptiondensity0',SaveDensityLayer(AbsorptionDensity.Layers[0]));
 result.Add('absorptiondensity1',SaveDensityLayer(AbsorptionDensity.Layers[1]));
 result.Add('absorptionextinction',Vector3ToJSON(AbsorptionExtinction.xyz));
 //result.Add('sundirection',Vector3ToJSON(SunDirection.xyz));
 //result.Add('musmin',TPasJSONItemNumber.Create(MuSMin));
 result.Add('maxshadowdistance',TPasJSONItemNumber.Create(MaxShadowDistance));
 result.Add('rainatmospherecubemapluminancefactor',TPasJSONItemNumber.Create(RainAtmosphereCubeMapLuminanceFactor));
 result.Add('raymarching',SaveRaymarching);
 result.Add('volumetricclouds',VolumetricClouds.SaveToJSON);
end;

procedure TpvScene3DAtmosphere.TAtmosphereParameters.SaveToJSONStream(const aStream:TStream);
var JSON:TPasJSONItem;
begin
 JSON:=SaveToJSON;
 if assigned(JSON) then begin
  try
   TPasJSON.StringifyToStream(aStream,JSON,true);
  finally
   FreeAndNil(JSON);
  end;
 end;
end;

procedure TpvScene3DAtmosphere.TAtmosphereParameters.SaveToJSONFile(const aFileName:string);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  SaveToJSONStream(Stream);
  Stream.SaveToFile(aFileName);
 finally
  FreeAndNil(Stream);
 end;
end;

function TpvScene3DAtmosphere_TAtmosphereParameters_POCASetAtmosphere(Context:PPOCAContext;const This:TPOCAValue;const Arguments:PPOCAValues;const CountArguments:longint;const UserData:pointer):TPOCAValue;
var JSONString:TpvUTF8String;
    JSON:TPasJSONItem;
begin
 if CountArguments>0 then begin
  JSONString:=POCAStringDump(Context,Arguments^[0]);
  JSON:=TPasJSON.Parse(JSONString);
  if assigned(JSON) then begin
   try
    TpvScene3DAtmosphere.PAtmosphereParameters(UserData)^.LoadFromJSON(JSON);
   finally
    FreeAndNil(JSON);
   end;
  end;
 end;
 result:=POCAValueNull;
end;

procedure TpvScene3DAtmosphere.TAtmosphereParameters.LoadFromPOCA(const aPOCACode:TpvUTF8String);
var POCAInstance:PPOCAInstance;
    POCAContext:PPOCAContext;
    POCACode:TPOCAValue;
    Code:TpvUTF8String;
begin
 if length(aPOCACode)>0 then begin
  Code:=PUCUUTF8Trim(PUCUUTF8Correct(aPOCACode));
  if length(Code)>0 then begin
   POCAInstance:=POCAInstanceCreate;
   try
    POCAContext:=POCAContextCreate(POCAInstance);
    try
     try
      POCAAddNativeFunction(POCAContext,POCAInstance.Globals.Namespace,'setAtmosphere',@TpvScene3DAtmosphere_TAtmosphereParameters_POCASetAtmosphere,nil,@self);
      POCACode:=POCACompile(POCAInstance,POCAContext,Code,'<CODE>');
      POCACall(POCAContext,POCACode,nil,0,POCAValueNull,POCAInstance^.Globals.Namespace);
     except
      on e:EPOCASyntaxError do begin
       // Ignore
      end;
      on e:EPOCARuntimeError do begin
       // Ignore
      end;
      on e:EPOCAScriptError do begin
       // Ignore
      end;
      on e:Exception do begin
       raise;
      end;
     end;
    finally
     POCAContextDestroy(POCAContext);
    end;
   finally
    POCAInstanceDestroy(POCAInstance);
   end;
  end;
 end;
end;

procedure TpvScene3DAtmosphere.TAtmosphereParameters.LoadFromPOCAStream(const aStream:TStream);
var POCACode:TpvUTF8String;
begin
 if assigned(aStream) and (aStream.Size>0) then begin
  POCACode:='';
  try
   SetLength(POCACode,aStream.Size);
   aStream.Seek(0,soBeginning);
   aStream.ReadBuffer(POCACode[1],aStream.Size);
   LoadFromPOCA(POCACode);
  finally
   POCACode:='';
  end;
 end; 
end;

procedure TpvScene3DAtmosphere.TAtmosphereParameters.LoadFromPOCAFile(const aFileName:string);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  Stream.LoadFromFile(aFileName);
  LoadFromPOCAStream(Stream);
 finally
  FreeAndNil(Stream);
 end;
end;

{ TpvScene3DAtmosphere.TGPUVolumetricCloudLayerLow }

procedure TpvScene3DAtmosphere.TGPUVolumetricCloudLayerLow.Assign(const aVolumetricCloudLayerLow:TVolumetricCloudLayerLow);
begin

 Orientation:=aVolumetricCloudLayerLow.Orientation;
 
 StartHeight:=aVolumetricCloudLayerLow.StartHeight;
 EndHeight:=aVolumetricCloudLayerLow.EndHeight;

 PositionScale:=aVolumetricCloudLayerLow.PositionScale;

 ShapeNoiseScale:=aVolumetricCloudLayerLow.ShapeNoiseScale;
 DetailNoiseScale:=aVolumetricCloudLayerLow.DetailNoiseScale;
 CurlScale:=aVolumetricCloudLayerLow.CurlScale;

 AdvanceCurlScale:=aVolumetricCloudLayerLow.AdvanceCurlScale;
 AdvanceCurlAmplitude:=aVolumetricCloudLayerLow.AdvanceCurlAmplitude;

 HeightGradients[0]:=aVolumetricCloudLayerLow.HeightGradients[0];
 HeightGradients[1]:=aVolumetricCloudLayerLow.HeightGradients[1];
 HeightGradients[2]:=aVolumetricCloudLayerLow.HeightGradients[2];

 AnvilDeformations[0]:=aVolumetricCloudLayerLow.AnvilDeformations[0];
 AnvilDeformations[1]:=aVolumetricCloudLayerLow.AnvilDeformations[1]; 
 AnvilDeformations[2]:=aVolumetricCloudLayerLow.AnvilDeformations[2];

end;

{ TpvScene3DAtmosphere.TGPUVolumetricCloudLayerHigh }

procedure TpvScene3DAtmosphere.TGPUVolumetricCloudLayerHigh.Assign(const aVolumetricCloudLayerHigh:TVolumetricCloudLayerHigh);
begin
 
 Orientation:=aVolumetricCloudLayerHigh.Orientation;

 StartHeight:=aVolumetricCloudLayerHigh.StartHeight;
 EndHeight:=aVolumetricCloudLayerHigh.EndHeight;
 
 PositionScale:=aVolumetricCloudLayerHigh.PositionScale;
 
 Density:=aVolumetricCloudLayerHigh.Density;
 
 CoverMin:=aVolumetricCloudLayerHigh.CoverMin;
 CoverMax:=aVolumetricCloudLayerHigh.CoverMax;
 
 FadeMin:=aVolumetricCloudLayerHigh.FadeMin;
 FadeMax:=aVolumetricCloudLayerHigh.FadeMax;
 
 Speed:=aVolumetricCloudLayerHigh.Speed;
 
 RotationBase:=aVolumetricCloudLayerHigh.RotationBase;
 RotationOctave1:=aVolumetricCloudLayerHigh.RotationOctave1;
 RotationOctave2:=aVolumetricCloudLayerHigh.RotationOctave2;
 RotationOctave3:=aVolumetricCloudLayerHigh.RotationOctave3;
 
 OctaveScales:=aVolumetricCloudLayerHigh.OctaveScales;
 OctaveFactors:=aVolumetricCloudLayerHigh.OctaveFactors;

end;

{ TpvScene3DAtmosphere.TGPUVolumetricCloudParameters }

procedure TpvScene3DAtmosphere.TGPUVolumetricCloudParameters.Assign(const aVolumetricCloudParameters:TVolumetricCloudParameters);
begin
 
 DryCoverageTypeWetnessTopFactors:=aVolumetricCloudParameters.DryCoverageTypeWetnessTopFactors; 
 DryCoverageTypeWetnessTopOffsets:=aVolumetricCloudParameters.DryCoverageTypeWetnessTopOffsets;
 
 WetCoverageTypeWetnessTopFactors:=aVolumetricCloudParameters.WetCoverageTypeWetnessTopFactors; 
 WetCoverageTypeWetnessTopOffsets:=aVolumetricCloudParameters.WetCoverageTypeWetnessTopOffsets;
 
 Scattering:=aVolumetricCloudParameters.Scattering; 
 Absorption:=aVolumetricCloudParameters.Absorption;
 
 LightingDensity:=aVolumetricCloudParameters.LightingDensity; 
 ShadowDensity:=aVolumetricCloudParameters.ShadowDensity;
 ViewDensity:=aVolumetricCloudParameters.ViewDensity;
 
 DensityScale:=aVolumetricCloudParameters.DensityScale;

 Scale:=aVolumetricCloudParameters.Scale;

 ForwardScatteringG:=aVolumetricCloudParameters.ForwardScatteringG;
 BackwardScatteringG:=aVolumetricCloudParameters.BackwardScatteringG;
 
 ShadowRayLength:=aVolumetricCloudParameters.ShadowRayLength;
 
 DensityAlongConeLength:=aVolumetricCloudParameters.DensityAlongConeLength;
 DensityAlongConeLengthFarMultiplier:=aVolumetricCloudParameters.DensityAlongConeLengthFarMultiplier;

 RayMinSteps:=aVolumetricCloudParameters.RayMinSteps;
 RayMaxSteps:=aVolumetricCloudParameters.RayMaxSteps;

 OuterSpaceRayMinSteps:=aVolumetricCloudParameters.OuterSpaceRayMinSteps;
 OuterSpaceRayMaxSteps:=aVolumetricCloudParameters.OuterSpaceRayMaxSteps;

 DirectScatteringIntensity:=aVolumetricCloudParameters.DirectScatteringIntensity;
 IndirectScatteringIntensity:=aVolumetricCloudParameters.IndirectScatteringIntensity;
 AmbientLightIntensity:=aVolumetricCloudParameters.AmbientLightIntensity;
 
 WetnessDensityFactor:=aVolumetricCloudParameters.WetnessDensityFactor;
 WetnessLuminanceFactor:=aVolumetricCloudParameters.WetnessLuminanceFactor; 

 LayerLow.Assign(aVolumetricCloudParameters.LayerLow); 
 LayerHigh.Assign(aVolumetricCloudParameters.LayerHigh);

end;

{ TpvScene3DAtmosphere.TGPUAtmosphereCullingParameters }

procedure TpvScene3DAtmosphere.TGPUAtmosphereCullingParameters.Assign(const aAtmosphereCullingParameters:TAtmosphereCullingParameters);
var FaceIndex:TpvSizeInt; 
begin
 aAtmosphereCullingParameters.CalculateBoundingSphere;
 InnerFadeDistance:=aAtmosphereCullingParameters.InnerFadeDistance;
 OuterFadeDistance:=aAtmosphereCullingParameters.OuterFadeDistance;
 CountFaces:=aAtmosphereCullingParameters.CountFaces;
 Mode:=aAtmosphereCullingParameters.Mode;
 InversedTransform:=aAtmosphereCullingParameters.InversedTransform;
 BoundingSphere:=aAtmosphereCullingParameters.BoundingSphere;
 case Mode and $f of
  1:begin
   CenterRadius:=aAtmosphereCullingParameters.CenterRadius;
  end;
  2:begin
   Center:=aAtmosphereCullingParameters.Center;
   HalfExtents:=aAtmosphereCullingParameters.HalfExtents;
  end;
  3:begin
   for FaceIndex:=0 to Min(TpvSizeInt(CountFaces),32)-1 do begin
    FacePlanes[FaceIndex]:=aAtmosphereCullingParameters.FacePlanes[FaceIndex];
   end;
  end;
 end;
end;

{ TpvScene3DAtmosphere.TGPUAtmosphereParameters }

procedure TpvScene3DAtmosphere.TGPUAtmosphereParameters.Assign(const aAtmosphereParameters:TAtmosphereParameters;const aScene3D:TObject;const aInFlightFrameIndex:TpvSizeInt);
var SunDirection:TpvVector3D;
begin

 SunDirection:=TpvScene3D(aScene3D).TransformDirection(TpvVector3D.Create(aAtmosphereParameters.SunDirection.xyz),aInFlightFrameIndex,false);

 Transform:=TpvScene3D(aScene3D).TransformOrigin(aAtmosphereParameters.Transform,aInFlightFrameIndex,false);
 InverseTransform:=Transform.Inverse;

 OriginTransform:=TpvScene3D(aScene3D).OriginTransforms[aInFlightFrameIndex];
 InverseOriginTransform:=TpvScene3D(aScene3D).InverseOriginTransforms[aInFlightFrameIndex];

 SolarIrradiance:=aAtmosphereParameters.SolarIrradiance;

 BottomRadius:=aAtmosphereParameters.BottomRadius;
 TopRadius:=aAtmosphereParameters.TopRadius;
 RayleighDensityExpScale:=aAtmosphereParameters.RayleighDensity.Layers[1].ExpScale;
 RayleighScattering:=TpvVector4.InlineableCreate(aAtmosphereParameters.RayleighScattering.xyz,aAtmosphereParameters.MuSMin);

 MieDensityExpScale:=aAtmosphereParameters.MieDensity.Layers[1].ExpScale;
 MieScattering:=TpvVector4.InlineableCreate(aAtmosphereParameters.MieScattering.xyz,SunDirection.x);
 MieExtinction:=TpvVector4.InlineableCreate(aAtmosphereParameters.MieExtinction.xyz,SunDirection.y);
 MieAbsorption:=TpvVector4.InlineableCreate(aAtmosphereParameters.AbsorptionExtinction.xyz,SunDirection.z);
 MiePhaseG:=aAtmosphereParameters.MiePhaseFunctionG;

 AbsorptionDensity0LayerWidth:=aAtmosphereParameters.AbsorptionDensity.Layers[0].Width;
 AbsorptionDensity0ConstantTerm:=aAtmosphereParameters.AbsorptionDensity.Layers[0].ConstantTerm;
 AbsorptionDensity0LinearTerm:=aAtmosphereParameters.AbsorptionDensity.Layers[0].LinearTerm;
 AbsorptionDensity1ConstantTerm:=aAtmosphereParameters.AbsorptionDensity.Layers[1].ConstantTerm;
 AbsorptionDensity1LinearTerm:=aAtmosphereParameters.AbsorptionDensity.Layers[1].LinearTerm;
 AbsorptionExtinction:=TpvVector4.InlineableCreate(aAtmosphereParameters.AbsorptionExtinction.xyz,aAtmosphereParameters.FadeFactor);

 GroundAlbedo:=TpvVector4.InlineableCreate(aAtmosphereParameters.GroundAlbedo.xyz,aAtmosphereParameters.Intensity);

 RaymarchingMinSteps:=aAtmosphereParameters.RaymarchingMinSteps;
 RaymarchingMaxSteps:=aAtmosphereParameters.RaymarchingMaxSteps;

 MaxShadowDistance:=aAtmosphereParameters.MaxShadowDistance;

 RainAtmosphereCubeMapLuminanceFactor:=aAtmosphereParameters.RainAtmosphereCubeMapLuminanceFactor;

 Flags:=0;

 AtmosphereCullingParameters.Assign(aAtmosphereParameters.AtmosphereCullingParameters);

 VolumetricClouds.Assign(aAtmosphereParameters.VolumetricClouds);

end;

{ TpvScene3DAtmosphere.TRendererInstance.TKey }

constructor TpvScene3DAtmosphere.TRendererInstance.TKey.Create(const aRendererInstance:TObject);
begin
 fRendererInstance:=aRendererInstance;
end;

{ TpvScene3DAtmosphere.TRendererInstance }

constructor TpvScene3DAtmosphere.TRendererInstance.Create(const aAtmosphere:TpvScene3DAtmosphere;const aRendererInstance:TObject);
var InFlightFrameIndex:TpvSizeInt;
begin

 inherited Create;

 fAtmosphere:=aAtmosphere;

 fRendererInstance:=aRendererInstance;

 fKey:=TKey.Create(fRendererInstance);

 fTransmittanceTexture:=TpvScene3DRendererImage2D.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                         TRANSMITTANCE_TEXTURE_WIDTH,
                                                         TRANSMITTANCE_TEXTURE_HEIGHT,
                                                         VK_FORMAT_R32G32B32A32_SFLOAT,
                                                         true,
                                                         VK_SAMPLE_COUNT_1_BIT,
                                                         VK_IMAGE_LAYOUT_GENERAL,
                                                         VK_SHARING_MODE_EXCLUSIVE,
                                                         nil,
                                                         0,
                                                         'TpScene3DAtmosphere.TRendererInstance.TransmittanceTexture');
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fTransmittanceTexture.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'TransmittanceTexture');
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fTransmittanceTexture.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'TransmittanceTexture');

 fMultiScatteringTexture:=TpvScene3DRendererImage2D.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                           MultiScatteringLUTRes,
                                                           MultiScatteringLUTRes,
                                                           VK_FORMAT_R32G32B32A32_SFLOAT,
                                                           true,
                                                           VK_SAMPLE_COUNT_1_BIT,
                                                           VK_IMAGE_LAYOUT_GENERAL,
                                                           VK_SHARING_MODE_EXCLUSIVE,
                                                           [],
                                                           0,
                                                           'TpScene3DAtmosphere.TRendererInstance.MultiScatteringTexture');
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fMultiScatteringTexture.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'MultiScatteringTexture');
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fMultiScatteringTexture.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'MultiScatteringTexture');

 fSkyLuminanceLUTTexture:=TpvScene3DRendererImageCubeMap.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                                SkyLuminanceLUTRes,
                                                                SkyLuminanceLUTRes,
                                                                VK_FORMAT_R32G32B32A32_SFLOAT,
                                                                true,
                                                                VK_SAMPLE_COUNT_1_BIT,
                                                                VK_IMAGE_LAYOUT_GENERAL,
                                                                VK_SHARING_MODE_EXCLUSIVE,
                                                                [],
                                                                0,
                                                                'TpScene3DAtmosphere.TRendererInstance.SkyLuminanceLUTTexture');

 fSkyViewLUTTexture:=TpvScene3DRendererArray2DImage.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                           SkyViewLUTTextureWidth,
                                                           SkyViewLUTTextureHeight, 
                                                           TpvScene3DRendererInstance(aRendererInstance).CountSurfaceViews*2,
                                                           VK_FORMAT_R32G32B32A32_SFLOAT,
                                                           VK_SAMPLE_COUNT_1_BIT,
                                                           VK_IMAGE_LAYOUT_GENERAL,
                                                           true,
                                                           0,
                                                           VK_FORMAT_UNDEFINED,
                                                           VK_SHARING_MODE_EXCLUSIVE,
                                                           nil,
                                                           'TpScene3DAtmosphere.SkyViewLUTTexture');           
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyViewLUTTexture.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'SkyViewLUTTexture');
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyViewLUTTexture.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'SkyViewLUTTexture');
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyViewLUTTexture.VulkanArrayImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'SkyViewLUTTexture');
 if assigned(fSkyViewLUTTexture.VulkanOtherArrayImageView) then begin
  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyViewLUTTexture.VulkanOtherArrayImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'SkyViewLUTTexture');
 end;

 fSkyViewLUTTextureImageLayout:=VK_IMAGE_LAYOUT_GENERAL;

 fCameraVolumeTexture:=TpvScene3DRendererArray2DImage.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                             CameraVolumeTextureWidth,
                                                             CameraVolumeTextureHeight,
                                                             CameraVolumeTextureDepth*TpvScene3DRendererInstance(aRendererInstance).CountSurfaceViews*2,
                                                             VK_FORMAT_R32G32B32A32_SFLOAT,
                                                             VK_SAMPLE_COUNT_1_BIT,
                                                             VK_IMAGE_LAYOUT_GENERAL,
                                                             true,
                                                             0,
                                                             VK_FORMAT_UNDEFINED,
                                                             VK_SHARING_MODE_EXCLUSIVE,
                                                             nil,
                                                             'TpScene3DAtmosphere.CameraVolumeTexture');
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCameraVolumeTexture.VulkanImage.Handle,VK_OBJECT_TYPE_IMAGE,'CameraVolumeTexture');
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCameraVolumeTexture.VulkanImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'CameraVolumeTexture');
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCameraVolumeTexture.VulkanArrayImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'CameraVolumeTexture');
 if assigned(fCameraVolumeTexture.VulkanOtherArrayImageView) then begin
  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCameraVolumeTexture.VulkanOtherArrayImageView.Handle,VK_OBJECT_TYPE_IMAGE_VIEW,'CameraVolumeTexture');
 end;                                                            

 fCameraVolumeTextureImageLayout:=VK_IMAGE_LAYOUT_GENERAL;

 fCubeMapTexture:=TpvScene3DRendererMipmapImageCubeMap.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                              CubeMapTextureSize,
                                                              CubeMapTextureSize,
                                                              VK_FORMAT_R16G16B16A16_SFLOAT,
                                                              true,                                                              
                                                              VK_SAMPLE_COUNT_1_BIT,                                                              
                                                              VK_IMAGE_LAYOUT_GENERAL,
                                                              TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                              nil,
                                                              0,
                                                              'TpScene3DAtmosphere.CubeMapTexture');

 fGGXCubeMapTexture:=TpvScene3DRendererMipmapImageCubeMap.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                                 CubeMapTextureSize,
                                                                 CubeMapTextureSize,
                                                                 VK_FORMAT_R16G16B16A16_SFLOAT,
                                                                 true,                                                              
                                                                 VK_SAMPLE_COUNT_1_BIT,                                                              
                                                                 VK_IMAGE_LAYOUT_GENERAL,
                                                                 TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                 nil,
                                                                 0,
                                                                 'TpScene3DAtmosphere.GGXCubeMapTexture');

 fCharlieCubeMapTexture:=TpvScene3DRendererMipmapImageCubeMap.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                                     CubeMapTextureSize,
                                                                     CubeMapTextureSize,
                                                                     VK_FORMAT_R16G16B16A16_SFLOAT,
                                                                     true,                                                              
                                                                     VK_SAMPLE_COUNT_1_BIT,                                                              
                                                                     VK_IMAGE_LAYOUT_GENERAL,
                                                                     TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                     nil,
                                                                     0,
                                                                     'TpScene3DAtmosphere.CharlieCubeMapTexture');

 fLambertianCubeMapTexture:=TpvScene3DRendererMipmapImageCubeMap.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                                        CubeMapTextureSize,
                                                                        CubeMapTextureSize,
                                                                        VK_FORMAT_R16G16B16A16_SFLOAT,
                                                                        true,                                                              
                                                                        VK_SAMPLE_COUNT_1_BIT,                                                              
                                                                        VK_IMAGE_LAYOUT_GENERAL,
                                                                        TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                                        nil,
                                                                        0,
                                                                        'TpScene3DAtmosphere.LambertianCubeMapTexture');

 fTransmittanceLUTPassDescriptorPool:=TpvVulkanDescriptorPool.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                                     TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT) or
                                                                     TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_UPDATE_AFTER_BIND_BIT_EXT),
                                                                     TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fTransmittanceLUTPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fTransmittanceLUTPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fTransmittanceLUTPassDescriptorPool.Initialize;
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fTransmittanceLUTPassDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TransmittanceLUTPassDescriptorPool');

 for InFlightFrameIndex:=0 to TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames-1 do begin

  fTransmittanceLUTPassDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fTransmittanceLUTPassDescriptorPool,
                                                                                           TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).fTransmittanceLUTPassDescriptorSetLayout);

  fTransmittanceLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                               [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                              fTransmittanceTexture.VulkanImageView.Handle,
                                                                                                              VK_IMAGE_LAYOUT_GENERAL)],
                                                                               [],
                                                                               [],
                                                                               false);

  fTransmittanceLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                               [],
                                                                               [fAtmosphere.fAtmosphereParametersBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                               [],
                                                                               false);                                                             

  fTransmittanceLUTPassDescriptorSets[InFlightFrameIndex].Flush;

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fTransmittanceLUTPassDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TransmittanceLUTPassDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

 end; 

 fMultiScatteringLUTPassDescriptorPool:=TpvVulkanDescriptorPool.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                                      TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT) or
                                                                      TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_UPDATE_AFTER_BIND_BIT_EXT),
                                                                      TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fMultiScatteringLUTPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fMultiScatteringLUTPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*2);
 fMultiScatteringLUTPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fMultiScatteringLUTPassDescriptorPool.Initialize;
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fMultiScatteringLUTPassDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'MultiScatteringLUTPassDescriptorPool');

 for InFlightFrameIndex:=0 to TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames-1 do begin

  fMultiScatteringLUTPassDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fMultiScatteringLUTPassDescriptorPool,
                                                                                           TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).fMultiScatteringLUTPassDescriptorSetLayout);

  fMultiScatteringLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                                 0,
                                                                                 1,
                                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                                 [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                                fMultiScatteringTexture.VulkanImageView.Handle,
                                                                                                                VK_IMAGE_LAYOUT_GENERAL)],
                                                                                 [],
                                                                                 [],
                                                                                 false);

  fMultiScatteringLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                                 0,
                                                                                 1,
                                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                 [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                                fTransmittanceTexture.VulkanImageView.Handle,
                                                                                                                VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                                 [],
                                                                                 [],
                                                                                 false);

  fMultiScatteringLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                                 0,
                                                                                 1,
                                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                                 [],
                                                                                 [fAtmosphere.fAtmosphereParametersBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                                 [],
                                                                                 false);     

  fMultiScatteringLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                                 0,
                                                                                 1,
                                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                 [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.RepeatedSampler.Handle,
                                                                                                                TpvScene3D(fAtmosphere.fScene3D).BlueNoise2DTexture.ImageView.Handle,
                                                                                                                VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                                 [],
                                                                                 [],
                                                                                 false);                                                                                                                                          

  fMultiScatteringLUTPassDescriptorSets[InFlightFrameIndex].Flush;

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fMultiScatteringLUTPassDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'MultiScatteringLUTPassDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

 end;

 fSkyLuminanceLUTPassDescriptorPool:=TpvVulkanDescriptorPool.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                                 TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT) or
                                                                 TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_UPDATE_AFTER_BIND_BIT_EXT),
                                                                 TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fSkyLuminanceLUTPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fSkyLuminanceLUTPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*3);                                                                
 fSkyLuminanceLUTPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fSkyLuminanceLUTPassDescriptorPool.Initialize;

 for InFlightFrameIndex:=0 to TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames-1 do begin

  fSkyLuminanceLUTPassDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fSkyLuminanceLUTPassDescriptorPool,
                                                                                         TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).fSkyLuminanceLUTPassDescriptorSetLayout);

  fSkyLuminanceLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                              0,
                                                                              1,
                                                                              TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                              [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                             fSkyLuminanceLUTTexture.VulkanImageView.Handle,
                                                                                                             VK_IMAGE_LAYOUT_GENERAL)],
                                                                              [],
                                                                              [],
                                                                              false);

  fSkyLuminanceLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                              0,
                                                                              1,
                                                                              TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                              [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                             fTransmittanceTexture.VulkanImageView.Handle,
                                                                                                             VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                              [],
                                                                              [],
                                                                              false);

  fSkyLuminanceLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                              0,
                                                                              1,
                                                                              TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                              [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                             fMultiScatteringTexture.VulkanImageView.Handle,
                                                                                                             VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                              [],
                                                                              [],
                                                                              false);

  fSkyLuminanceLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                              0,
                                                                              1,
                                                                              TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                              [],
                                                                              [fAtmosphere.fAtmosphereParametersBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                              [],
                                                                              false);                                                             

  fSkyLuminanceLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,
                                                                              0,
                                                                              1,
                                                                              TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                              [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.RepeatedSampler.Handle,
                                                                                                             TpvScene3D(fAtmosphere.fScene3D).BlueNoise2DTexture.ImageView.Handle,
                                                                                                             VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                              [],
                                                                              [],
                                                                              false);

  fSkyLuminanceLUTPassDescriptorSets[InFlightFrameIndex].Flush;

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyLuminanceLUTPassDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'SkyLuminanceLUTPassDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

 end;

 fSkyViewLUTPassDescriptorPool:=TpvVulkanDescriptorPool.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                              TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT) or
                                                              TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_UPDATE_AFTER_BIND_BIT_EXT),
                                                              TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fSkyViewLUTPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fSkyViewLUTPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*4);
 fSkyViewLUTPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fSkyViewLUTPassDescriptorPool.Initialize;
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyViewLUTPassDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'SkyViewLUTPassDescriptorPool');

 for InFlightFrameIndex:=0 to TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames-1 do begin

  fSkyViewLUTPassDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fSkyViewLUTPassDescriptorPool,
                                                                                   TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).fSkyViewLUTPassDescriptorSetLayout);

  fSkyViewLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                         0,
                                                                         1,
                                                                         TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                         [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                        fSkyViewLUTTexture.VulkanArrayImageView.Handle,
                                                                                                        VK_IMAGE_LAYOUT_GENERAL)],
                                                                         [],
                                                                         [],
                                                                         false);

  fSkyViewLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                         0,
                                                                         1,
                                                                         TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                         [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                        fTransmittanceTexture.VulkanImageView.Handle,
                                                                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                         [],
                                                                         [],
                                                                         false);

  fSkyViewLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                         0,
                                                                         1,
                                                                         TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                         [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                        fMultiScatteringTexture.VulkanImageView.Handle,
                                                                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                         [],
                                                                         [],
                                                                         false);

  fSkyViewLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                         0,
                                                                         1,
                                                                         TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                         [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                        fAtmosphere.fAtmosphereMap.fTexture.VulkanImageView.Handle,
                                                                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                         [],
                                                                         [],
                                                                         false);

  fSkyViewLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,
                                                                         0,
                                                                         1,
                                                                         TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                         [],
                                                                         [fAtmosphere.fAtmosphereParametersBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                         [],
                                                                         false);                                                             

  fSkyViewLUTPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,
                                                                         0,
                                                                         1,
                                                                         TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                         [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.RepeatedSampler.Handle,
                                                                                                        TpvScene3D(fAtmosphere.fScene3D).BlueNoise2DTexture.ImageView.Handle,
                                                                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                         [],
                                                                         [],
                                                                         false);

  fSkyViewLUTPassDescriptorSets[InFlightFrameIndex].Flush;

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyViewLUTPassDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'SkyViewLUTPassDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

 end; 
 
 fCameraVolumePassDescriptorPool:=TpvVulkanDescriptorPool.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                               TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT) or
                                                               TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_UPDATE_AFTER_BIND_BIT_EXT),
                                                               TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fCameraVolumePassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fCameraVolumePassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*4);
 fCameraVolumePassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fCameraVolumePassDescriptorPool.Initialize;
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCameraVolumePassDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'CameraVolumePassDescriptorPool');

 for InFlightFrameIndex:=0 to TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames-1 do begin

  fCameraVolumePassDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fCameraVolumePassDescriptorPool,
                                                                                      TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).fCameraVolumePassDescriptorSetLayout);

  fCameraVolumePassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                           0,
                                                                           1,
                                                                           TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                           [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                          fCameraVolumeTexture.VulkanArrayImageView.Handle,
                                                                                                          VK_IMAGE_LAYOUT_GENERAL)],
                                                                           [],
                                                                           [],
                                                                           false);

  fCameraVolumePassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                           0,
                                                                           1,
                                                                           TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                           [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                          fTransmittanceTexture.VulkanImageView.Handle,
                                                                                                          VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                           [],
                                                                           [],
                                                                           false);

  fCameraVolumePassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                           0,
                                                                           1,
                                                                           TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                           [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                          fMultiScatteringTexture.VulkanImageView.Handle,
                                                                                                          VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                           [],
                                                                           [],
                                                                           false);

  fCameraVolumePassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                           0,
                                                                           1,
                                                                           TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                           [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                          fAtmosphere.fAtmosphereMap.fTexture.VulkanImageView.Handle,
                                                                                                          VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                           [],
                                                                           [],
                                                                           false);

  fCameraVolumePassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,
                                                                           0,
                                                                           1,
                                                                           TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                           [],
                                                                           [fAtmosphere.fAtmosphereParametersBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                           [],
                                                                           false);                                                             

  fCameraVolumePassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,
                                                                           0,
                                                                           1,
                                                                           TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                           [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.RepeatedSampler.Handle,
                                                                                                          TpvScene3D(fAtmosphere.fScene3D).BlueNoise2DTexture.ImageView.Handle,
                                                                                                          VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                           [],
                                                                           [],
                                                                           false);

  fCameraVolumePassDescriptorSets[InFlightFrameIndex].Flush;

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCameraVolumePassDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'CameraVolumePassDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

 end; 

 fCubeMapPassDescriptorPool:=TpvVulkanDescriptorPool.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                            TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT) or
                                                            TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_UPDATE_AFTER_BIND_BIT_EXT),
                                                            TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fCubeMapPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fCubeMapPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*5);
 fCubeMapPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fCubeMapPassDescriptorPool.Initialize;
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCubeMapPassDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'CubeMapPassDescriptorPool');

 for InFlightFrameIndex:=0 to TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames-1 do begin

  fCubeMapPassDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fCubeMapPassDescriptorPool,
                                                                                TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).fCubeMapPassDescriptorSetLayout);

  fCubeMapPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                      0,
                                                                      1,
                                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                      [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                     fCubeMapTexture.VulkanImageViews[0].Handle,
                                                                                                     VK_IMAGE_LAYOUT_GENERAL)],
                                                                      [],
                                                                      [],
                                                                      false);

  fCubeMapPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                      0,
                                                                      1,
                                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                      [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                     fTransmittanceTexture.VulkanImageView.Handle,
                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                      [],
                                                                      [],
                                                                      false);

  fCubeMapPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                      0,
                                                                      1,
                                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                      [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                     fMultiScatteringTexture.VulkanImageView.Handle,
                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                      [],
                                                                      [],
                                                                      false);

  fCubeMapPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                      0,
                                                                      1,
                                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                      [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                     fSkyLuminanceLUTTexture.VulkanImageView.Handle,
                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                      [],
                                                                      [],
                                                                      false);

  fCubeMapPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,
                                                                      0,
                                                                      1,
                                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                      [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                     fAtmosphere.fAtmosphereMap.fTexture.VulkanImageView.Handle,
                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                      [],
                                                                      [],
                                                                      false);

  fCubeMapPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,
                                                                      0,
                                                                      1,
                                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                      [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                     fAtmosphere.fPrecipitationMap.fTexture.VulkanImageView.Handle,
                                                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                      [],
                                                                      [],
                                                                      false);

  fCubeMapPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(6,
                                                                      0,
                                                                      1,
                                                                      TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                      [],
                                                                      [fAtmosphere.fAtmosphereParametersBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                      [],
                                                                      false);                                                             

  fCubeMapPassDescriptorSets[InFlightFrameIndex].Flush;

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCubeMapPassDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'CubeMapPassDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

 end;

 fCloudRaymarchingPassDescriptorPool:=TpvVulkanDescriptorPool.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                                    TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT) or
                                                                    TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_UPDATE_AFTER_BIND_BIT_EXT),
                                                                    TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fCloudRaymarchingPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fCloudRaymarchingPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*11);
 fCloudRaymarchingPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*2);
 fCloudRaymarchingPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*2);
 fCloudRaymarchingPassDescriptorPool.Initialize;
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCloudRaymarchingPassDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'CloudRaymarchingPassDescriptorPool');

 for InFlightFrameIndex:=0 to TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames-1 do begin

  fCloudRaymarchingPassDepthImageViews[InFlightFrameIndex]:=VK_NULL_HANDLE;

  fCloudRaymarchingPassCascadedShadowMapImageViews[InFlightFrameIndex]:=VK_NULL_HANDLE;
  
  fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fCloudRaymarchingPassDescriptorPool,
                                                                                         TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).fCloudRaymarchingPassDescriptorSetLayout);

  // Depth texture
 {fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_SAMPLED_IMAGE),
                                                                               [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                              VK_NULL_HANDLE, // will be replaced with the actual depth texture attachment
                                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                               [],
                                                                               [],
                                                                               false);}

  // Atmosphere parameters
  fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
//                                                                             TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                               [],
                                                                               [fAtmosphere.fAtmosphereParametersBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                               [],
                                                                               false);

  // Blue noise 
  fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                               [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.RepeatedSampler.Handle,
                                                                                                              TpvScene3D(fAtmosphere.fScene3D).BlueNoise2DTexture.ImageView.Handle,
                                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                               [],
                                                                               [],
                                                                               false);

  // Sky luminance
  fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                               [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                              fSkyLuminanceLUTTexture.VulkanImageView.Handle,
                                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                               [],
                                                                               [],
                                                                               false);

  // Transmittance LUT
  fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                               [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                              fTransmittanceTexture.VulkanImageView.Handle,
                                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                               [],
                                                                               [],
                                                                               false);

  // Shape noise
  fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                               [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.MirrorRepeatedSampler.Handle,
                                                                                                              TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).fCloudShapeTexture.VulkanImageView.Handle,
                                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                               [],
                                                                               [],
                                                                               false);

  // Detail noise
  fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(6,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                               [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.MirrorRepeatedSampler.Handle,
                                                                                                              TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).fCloudDetailTexture.VulkanImageView.Handle,
                                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                               [],
                                                                               [],
                                                                               false);

  // Curl noise
  fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(7,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                               [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.MirrorRepeatedSampler.Handle,
                                                                                                              TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).fCloudCurlTexture.VulkanImageView.Handle,
                                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                               [],
                                                                               [],
                                                                               false);

  // Sky luminance LUT
  fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(8,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                               [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                              fSkyLuminanceLUTTexture.VulkanImageView.Handle,
                                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                               [],
                                                                               [],
                                                                               false);

  // Weather map
  fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(9,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                               [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                              fAtmosphere.fWeatherMapTexture.VulkanImageView.Handle,
                                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                               [],
                                                                               [],
                                                                               false);

  // Precipitation map
  fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(10,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                               [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                              fAtmosphere.fPrecipitationMap.fTexture.VulkanImageView.Handle,
                                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                               [],
                                                                               [],
                                                                               false);

  // Atmosphere map
  fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(11,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                               [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                              fAtmosphere.fAtmosphereMap.fTexture.VulkanImageView.Handle,
                                                                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                               [],
                                                                               [],
                                                                               false);

  // Atmosphere map min/max buffer
  fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(12,
                                                                               0,
                                                                               1,
                                                                               TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                               [],
                                                                               [fAtmosphere.fAtmosphereMapMinMaxBuffer.DescriptorBufferInfo],
                                                                               [],
                                                                               false);                                                                               

  //fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].Flush; // Not needed, because the descriptor set will be flushed when it is bound

  fCloudRaymarchingPassDescriptorSetFirsts[InFlightFrameIndex]:=true; // Will be set to false after the first flush, so that the further descriptor set updates will be updated directly instead of creating new descriptor sets

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'CloudRaymarchingPassDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

 end;

 fRaymarchingPassDescriptorPool:=TpvVulkanDescriptorPool.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                               TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT) or
                                                               TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_UPDATE_AFTER_BIND_BIT_EXT),
                                                               TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fRaymarchingPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*4);
 fRaymarchingPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*7);
 fRaymarchingPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*2);
 fRaymarchingPassDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fRaymarchingPassDescriptorPool.Initialize;
 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fRaymarchingPassDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'RaymarchingPassDescriptorPool');

 for InFlightFrameIndex:=0 to TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames-1 do begin

  fRaymarchingPassDepthImageViews[InFlightFrameIndex]:=VK_NULL_HANDLE;

  fRaymarchingPassCascadedShadowMapImageViews[InFlightFrameIndex]:=VK_NULL_HANDLE;

  fRaymarchingPassCloudsInscatteringImageViews[InFlightFrameIndex]:=VK_NULL_HANDLE;

  fRaymarchingPassCloudsTransmittanceImageViews[InFlightFrameIndex]:=VK_NULL_HANDLE;

  fRaymarchingPassCloudsDepthImageViews[InFlightFrameIndex]:=VK_NULL_HANDLE;

  fRaymarchingPassDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fRaymarchingPassDescriptorPool,
                                                                                    TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).fRaymarchingPassDescriptorSetLayout);

{ fRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE),
                                                                          [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                         VK_NULL_HANDLE, //fCameraVolumeTexture.VulkanArrayImageView.Handle, // Dummy, will be replaced with the actual depth texture attachment
                                                                                                         VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                          [],
                                                                          [],
                                                                          false);}

  fRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(1,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                          [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                         fTransmittanceTexture.VulkanImageView.Handle,
                                                                                                         VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                          [],
                                                                          [],
                                                                          false);

  fRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(2,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                          [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                         fMultiScatteringTexture.VulkanImageView.Handle,
                                                                                                         VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                          [],
                                                                          [],
                                                                          false);

  fRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(3,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                          [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                         fSkyViewLUTTexture.VulkanArrayImageView.Handle,
                                                                                                         VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                          [],
                                                                          [],
                                                                          false);

  fRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(4,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                          [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                         fCameraVolumeTexture.VulkanArrayImageView.Handle,
                                                                                                         VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                          [],
                                                                          [],
                                                                          false);

  fRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(5,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                          [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.ClampedSampler.Handle,
                                                                                                         fAtmosphere.fAtmosphereMap.fTexture.VulkanImageView.Handle,
                                                                                                         VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                          [],
                                                                          [],
                                                                          false);

  fRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(6,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                          [TVkDescriptorImageInfo.Create(TpvScene3DRenderer(fRendererInstance).Renderer.RepeatedSampler.Handle,
                                                                                                         TpvScene3D(fAtmosphere.fScene3D).BlueNoise2DTexture.ImageView.Handle,
                                                                                                         VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                          [],
                                                                          [],
                                                                          false);

  fRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(7,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                          [],
                                                                          [fAtmosphere.fAtmosphereMapMinMaxBuffer.DescriptorBufferInfo],
                                                                          [],
                                                                          false);

  fRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(8,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                                          [],
                                                                          [fAtmosphere.fAtmosphereParametersBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                          [],
                                                                          false);

  fRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(9,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                          [],
                                                                          [TpvScene3DRendererInstance(fRendererInstance).CascadedShadowMapVulkanUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                          [],
                                                                          false);

{ fRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(10,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                          [TpvScene3DRendererInstance(fRendererInstance).CascadedShadowMapVulkanUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                          [],
                                                                          [],
                                                                          false);}

 {fRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(11,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE),
                                                                          [...],
                                                                          [],
                                                                          [],
                                                                          false);}

 {fRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(12,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE),
                                                                          [...],
                                                                          [],
                                                                          [],
                                                                          false);}

 {fRaymarchingPassDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(13,
                                                                          0,
                                                                          1,
                                                                          TVkDescriptorType(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE),
                                                                          [...],
                                                                          [],
                                                                          [],
                                                                          false);}

//fRaymarchingPassDescriptorSets[InFlightFrameIndex].Flush; // Will be flushed later

  fRaymarchingPassDescriptorSetFirsts[InFlightFrameIndex]:=true; // Will be set to false after the first flush, so that the further descriptor set updates will be updated directly instead of creating new descriptor sets

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fRaymarchingPassDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'RaymarchingPassDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

 end;

 fGlobalDescriptorPool:=TpvVulkanDescriptorPool.Create(TpvScene3D(fAtmosphere.fScene3D).VulkanDevice,
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT) or
                                                       TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_UPDATE_AFTER_BIND_BIT_EXT),
                                                       TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fGlobalDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames*1);
 fGlobalDescriptorPool.Initialize;

 for InFlightFrameIndex:=0 to TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames-1 do begin

  fGlobalDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fGlobalDescriptorPool,
                                                                           TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).fGlobalVulkanDescriptorSetLayout);

  fGlobalDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                 0,
                                                                 1,
                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER),
                                                                 [],
                                                                 [TpvScene3DRendererInstance(fRendererInstance).VulkanViewUniformBuffers[InFlightFrameIndex].DescriptorBufferInfo],
                                                                 [],
                                                                 false);

  fGlobalDescriptorSets[InFlightFrameIndex].Flush;

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.SetObjectName(fGlobalDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'GlobalDescriptorSets['+IntToStr(InFlightFrameIndex)+']');

 end;

 fCubeMapMipMapGenerator:=TpvScene3DRendererCubeMapMipMapGenerator.Create(TpvScene3D(fAtmosphere.fScene3D),fCubeMapTexture);
 fCubeMapMipMapGenerator.AcquirePersistentResources;
 fCubeMapMipMapGenerator.AcquireVolatileResources;

 fGGXCubeMapIBLFilter:=TpvScene3DRendererCubeMapIBLFilter.Create(TpvScene3D(fAtmosphere.fScene3D),TpvScene3DRendererInstance(fRendererInstance).Renderer,fCubeMapTexture,fGGXCubeMapTexture,TpvScene3DRendererCubeMapIBLFilter.GGX);
 fGGXCubeMapIBLFilter.AcquirePersistentResources;
 fGGXCubeMapIBLFilter.AcquireVolatileResources;

 fCharlieCubeMapIBLFilter:=TpvScene3DRendererCubeMapIBLFilter.Create(TpvScene3D(fAtmosphere.fScene3D),TpvScene3DRendererInstance(fRendererInstance).Renderer,fCubeMapTexture,fCharlieCubeMapTexture,TpvScene3DRendererCubeMapIBLFilter.Charlie);
 fCharlieCubeMapIBLFilter.AcquirePersistentResources;
 fCharlieCubeMapIBLFilter.AcquireVolatileResources;

 fLambertianCubeMapIBLFilter:=TpvScene3DRendererCubeMapIBLFilter.Create(TpvScene3D(fAtmosphere.fScene3D),TpvScene3DRendererInstance(fRendererInstance).Renderer,fCubeMapTexture,fLambertianCubeMapTexture,TpvScene3DRendererCubeMapIBLFilter.Lambertian);
 fLambertianCubeMapIBLFilter.AcquirePersistentResources;
 fLambertianCubeMapIBLFilter.AcquireVolatileResources;
 
end;

destructor TpvScene3DAtmosphere.TRendererInstance.Destroy;
var InFlightFrameIndex:TpvSizeInt;
begin

 fLambertianCubeMapIBLFilter.ReleaseVolatileResources;
 fLambertianCubeMapIBLFilter.ReleasePersistentResources;
 FreeAndNil(fLambertianCubeMapIBLFilter);

 fCharlieCubeMapIBLFilter.ReleaseVolatileResources;
 fCharlieCubeMapIBLFilter.ReleasePersistentResources;
 FreeAndNil(fCharlieCubeMapIBLFilter);

 fGGXCubeMapIBLFilter.ReleaseVolatileResources;
 fGGXCubeMapIBLFilter.ReleasePersistentResources;
 FreeAndNil(fGGXCubeMapIBLFilter);

 fCubeMapMipMapGenerator.ReleaseVolatileResources;
 fCubeMapMipMapGenerator.ReleasePersistentResources;
 FreeAndNil(fCubeMapMipMapGenerator);

 for InFlightFrameIndex:=0 to TpvScene3D(fAtmosphere.fScene3D).CountInFlightFrames-1 do begin
  FreeAndNil(fTransmittanceLUTPassDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fMultiScatteringLUTPassDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fSkyLuminanceLUTPassDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fSkyViewLUTPassDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fCubeMapPassDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fCameraVolumePassDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fCloudRaymarchingPassDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fRaymarchingPassDescriptorSets[InFlightFrameIndex]);
  FreeAndNil(fGlobalDescriptorSets[InFlightFrameIndex]);
 end;

 FreeAndNil(fTransmittanceLUTPassDescriptorPool);
 FreeAndNil(fMultiScatteringLUTPassDescriptorPool);
 FreeAndNil(fSkyLuminanceLUTPassDescriptorPool);
 FreeAndNil(fSkyViewLUTPassDescriptorPool);
 FreeAndNil(fCubeMapPassDescriptorPool);
 FreeAndNil(fCameraVolumePassDescriptorPool);
 FreeAndNil(fCloudRaymarchingPassDescriptorPool);
 FreeAndNil(fRaymarchingPassDescriptorPool);
 FreeAndNil(fGlobalDescriptorPool);

 FreeAndNil(fCubeMapTexture);
 FreeAndNil(fGGXCubeMapTexture);
 FreeAndNil(fCharlieCubeMapTexture);
 FreeAndNil(fLambertianCubeMapTexture);

 FreeAndNil(fTransmittanceTexture);
 FreeAndNil(fMultiScatteringTexture);
 FreeAndNil(fSkyLuminanceLUTTexture);
 FreeAndNil(fSkyViewLUTTexture);
 FreeAndNil(fCameraVolumeTexture);

 inherited Destroy;

end;

procedure TpvScene3DAtmosphere.TRendererInstance.AfterConstruction;
begin
 inherited AfterConstruction;
 if assigned(fAtmosphere) and assigned(fAtmosphere.fRendererInstanceListLock) then begin
  fAtmosphere.fRendererInstanceListLock.Acquire;
  try
   fAtmosphere.fRendererInstances.Add(self);
   fAtmosphere.fRendererInstanceHashMap.Add(fKey,self);
  finally
   fAtmosphere.fRendererInstanceListLock.Release;
  end;
 end;
end;

procedure TpvScene3DAtmosphere.TRendererInstance.BeforeDestruction;
begin
 if assigned(fAtmosphere) and assigned(fAtmosphere.fRendererInstanceListLock) then begin
  fAtmosphere.fRendererInstanceListLock.Acquire;
  try
   fAtmosphere.fRendererInstanceHashMap.Delete(fKey);
   fAtmosphere.fRendererInstances.RemoveWithoutFree(self);
  finally
   fAtmosphere.fRendererInstanceListLock.Release;
  end;
 end;
 inherited BeforeDestruction;
end;

procedure TpvScene3DAtmosphere.TRendererInstance.SetCloudsImageViews(const aInFlightFrameIndex:TpvSizeInt;
                                                                     const aDepthImageView:TVkImageView;
                                                                     const aCascadedShadowMapImageView:TVkImageView);
begin

 if (fCloudRaymarchingPassDepthImageViews[aInFlightFrameIndex]<>aDepthImageView) or
    (fCloudRaymarchingPassCascadedShadowMapImageViews[aInFlightFrameIndex]<>aCascadedShadowMapImageView) then begin

  if fCloudRaymarchingPassDepthImageViews[aInFlightFrameIndex]<>aDepthImageView then begin

   fCloudRaymarchingPassDepthImageViews[aInFlightFrameIndex]:=aDepthImageView;

   fCloudRaymarchingPassDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(0,
                                                                                 0,
                                                                                 1,
                                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE),
                                                                                 [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                                aDepthImageView,
                                                                                                                VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                                 [],
                                                                                 [],
                                                                                 not fCloudRaymarchingPassDescriptorSetFirsts[aInFlightFrameIndex]);

  end;

  if fCloudRaymarchingPassCascadedShadowMapImageViews[aInFlightFrameIndex]<>aCascadedShadowMapImageView then begin

   fCloudRaymarchingPassCascadedShadowMapImageViews[aInFlightFrameIndex]:=aCascadedShadowMapImageView;

{  fCloudRaymarchingPassDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(11,
                                                                                 0,
                                                                                 1,
                                                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                                 [TVkDescriptorImageInfo.Create(TpvScene3DRendererInstance(fRendererInstance).Renderer.ShadowMapSampler.Handle,
                                                                                                                aCascadedShadowMapImageView,
                                                                                                                VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                                 [],
                                                                                 [],
                                                                                 not fCloudRaymarchingPassDescriptorSetFirsts[aInFlightFrameIndex]);}
  end;

  if fCloudRaymarchingPassDescriptorSetFirsts[aInFlightFrameIndex] then begin
   fCloudRaymarchingPassDescriptorSets[aInFlightFrameIndex].Flush;
  end;

  fCloudRaymarchingPassDescriptorSetFirsts[aInFlightFrameIndex]:=false;

 end;

end;

procedure TpvScene3DAtmosphere.TRendererInstance.SetImageViews(const aInFlightFrameIndex:TpvSizeInt;
                                                               const aDepthImageView:TVkImageView;
                                                               const aCascadedShadowMapImageView:TVkImageView;
                                                               const aCloudsInscatteringImageView:TVkImageView;
                                                               const aCloudsTransmittanceImageView:TVkImageView;
                                                               const aCloudsDepthImageView:TVkImageView);
begin

 if (fRaymarchingPassDepthImageViews[aInFlightFrameIndex]<>aDepthImageView) or
    (fRaymarchingPassCascadedShadowMapImageViews[aInFlightFrameIndex]<>aCascadedShadowMapImageView) or
    (fRaymarchingPassCloudsInscatteringImageViews[aInFlightFrameIndex]<>aCloudsInscatteringImageView) or
    (fRaymarchingPassCloudsTransmittanceImageViews[aInFlightFrameIndex]<>aCloudsTransmittanceImageView) or
    (fRaymarchingPassCloudsDepthImageViews[aInFlightFrameIndex]<>aCloudsDepthImageView) then begin

  if fRaymarchingPassDepthImageViews[aInFlightFrameIndex]<>aDepthImageView then begin

   fRaymarchingPassDepthImageViews[aInFlightFrameIndex]:=aDepthImageView;

   fRaymarchingPassDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(0,
                                                                            0,
                                                                            1,
                                                                            TVkDescriptorType(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE),
                                                                            [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                           aDepthImageView,
                                                                                                           VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                            [],
                                                                            [],
                                                                            not fRaymarchingPassDescriptorSetFirsts[aInFlightFrameIndex]);

  end;

  if fRaymarchingPassCascadedShadowMapImageViews[aInFlightFrameIndex]<>aCascadedShadowMapImageView then begin

   fRaymarchingPassCascadedShadowMapImageViews[aInFlightFrameIndex]:=aCascadedShadowMapImageView;

   fRaymarchingPassDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(10,
                                                                            0,
                                                                            1,
                                                                            TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                                            [TVkDescriptorImageInfo.Create(TpvScene3DRendererInstance(fRendererInstance).Renderer.ShadowMapSampler.Handle,
                                                                                                           aCascadedShadowMapImageView,
                                                                                                           VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                            [],
                                                                            [],
                                                                            not fRaymarchingPassDescriptorSetFirsts[aInFlightFrameIndex]);

  end;

  if fRaymarchingPassCloudsInscatteringImageViews[aInFlightFrameIndex]<>aCloudsInscatteringImageView then begin

   fRaymarchingPassCloudsInscatteringImageViews[aInFlightFrameIndex]:=aCloudsInscatteringImageView;

   fRaymarchingPassDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(11,
                                                                            0,
                                                                            1,
                                                                            TVkDescriptorType(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE),
                                                                            [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                           aCloudsInscatteringImageView,
                                                                                                           VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                            [],
                                                                            [],
                                                                            not fRaymarchingPassDescriptorSetFirsts[aInFlightFrameIndex]);

  end;

  if fRaymarchingPassCloudsTransmittanceImageViews[aInFlightFrameIndex]<>aCloudsTransmittanceImageView then begin

   fRaymarchingPassCloudsTransmittanceImageViews[aInFlightFrameIndex]:=aCloudsTransmittanceImageView;

   fRaymarchingPassDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(12,
                                                                            0,
                                                                            1,
                                                                            TVkDescriptorType(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE),
                                                                            [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                           aCloudsTransmittanceImageView,
                                                                                                           VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                            [],
                                                                            [],
                                                                            not fRaymarchingPassDescriptorSetFirsts[aInFlightFrameIndex]);

  end;

  if fRaymarchingPassCloudsDepthImageViews[aInFlightFrameIndex]<>aCloudsDepthImageView then begin

   fRaymarchingPassCloudsDepthImageViews[aInFlightFrameIndex]:=aCloudsDepthImageView;

   fRaymarchingPassDescriptorSets[aInFlightFrameIndex].WriteToDescriptorSet(13,
                                                                            0,
                                                                            1,
                                                                            TVkDescriptorType(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE),
                                                                            [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                           aCloudsDepthImageView,
                                                                                                           VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                                            [],
                                                                            [],
                                                                            not fRaymarchingPassDescriptorSetFirsts[aInFlightFrameIndex]);

  end;

  if fRaymarchingPassDescriptorSetFirsts[aInFlightFrameIndex] then begin 
   fRaymarchingPassDescriptorSets[aInFlightFrameIndex].Flush;
  end;

  fRaymarchingPassDescriptorSetFirsts[aInFlightFrameIndex]:=false;

 end;

end;

procedure TpvScene3DAtmosphere.TRendererInstance.Setup(const aRenderPass:TpvVulkanRenderPass;
                                                       const aRenderPassSubpassIndex:TpvSizeInt;
                                                       const aSampleCount:TVkSampleCountFlagBits;
                                                       const aWidth:TpvSizeInt;
                                                       const aHeight:TpvSizeInt);
begin
end;

procedure TpvScene3DAtmosphere.TRendererInstance.ReleaseGraphicsPipeline;
begin
end;

procedure TpvScene3DAtmosphere.TRendererInstance.Execute(const aInFlightFrameIndex:TpvSizeInt;
                                                         const aCommandBuffer:TpvVulkanCommandBuffer);
var BaseViewIndex,UnjitteredBaseViewIndex,CountViews:TpvSizeInt;
    InFlightFrameState:TpvScene3DRendererInstance.PInFlightFrameState;
    AtmosphereGlobals:TpvScene3DAtmosphereGlobals;
    //ImageSubresourceRange:TVkImageSubresourceRange;
    ImageMemoryBarriers:array[0..3] of TVkImageMemoryBarrier;
    TransmittanceLUTPushConstants:TpvScene3DAtmosphereGlobals.TTransmittanceLUTPushConstants;
    MultiScatteringLUTPushConstants:TpvScene3DAtmosphereGlobals.TMultiScatteringLUTPushConstants;
    SkyLuminanceLUTPushConstants:TpvScene3DAtmosphereGlobals.TSkyLuminanceLUTPushConstants;
    SkyViewLUTPushConstants:TpvScene3DAtmosphereGlobals.TSkyViewLUTPushConstants;
    CameraVolumePushConstants:TpvScene3DAtmosphereGlobals.TCameraVolumePushConstants;
    CubeMapPushConstants:TpvScene3DAtmosphereGlobals.TCubeMapPushConstants;
    DescriptorSets:array[0..2] of TVkDescriptorSet;
begin

 AtmosphereGlobals:=TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals);

 InFlightFrameState:=@TpvScene3DRendererInstance(fRendererInstance).InFlightFrameStates[aInFlightFrameIndex];

 BaseViewIndex:=InFlightFrameState^.FinalViewIndex;
 UnjitteredBaseViewIndex:=InFlightFrameState^.FinalUnjitteredViewIndex;
 CountViews:=InFlightFrameState^.CountFinalViews;

 begin

  // Transmittance LUT

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.TransmittanceLUT',[1.0,0.0,0.0,1.0]);

  ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(0,
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       VK_IMAGE_LAYOUT_UNDEFINED,
                                                       VK_IMAGE_LAYOUT_GENERAL,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fTransmittanceTexture.VulkanImage.Handle,
                                                       TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       1));

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);
  
  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,AtmosphereGlobals.fTransmittanceLUTComputePipeline.Handle);

  DescriptorSets[0]:=TpvScene3D(fAtmosphere.fScene3D).GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[1]:=fGlobalDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[2]:=fTransmittanceLUTPassDescriptorSets[aInFlightFrameIndex].Handle;

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       AtmosphereGlobals.fTransmittanceLUTComputePipelineLayout.Handle,
                                       0,
                                       3,
                                       @DescriptorSets[0],
                                       0,
                                       nil);

  TransmittanceLUTPushConstants.BaseViewIndex:=UnjitteredBaseViewIndex;
  TransmittanceLUTPushConstants.CountViews:=CountViews;
  TransmittanceLUTPushConstants.Dummy0:=1;
  TransmittanceLUTPushConstants.Dummy1:=1;

  aCommandBuffer.CmdPushConstants(AtmosphereGlobals.fTransmittanceLUTComputePipelineLayout.Handle,
                                  TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TpvScene3DAtmosphereGlobals.TTransmittanceLUTPushConstants),
                                  @TransmittanceLUTPushConstants);

  aCommandBuffer.CmdDispatch((fTransmittanceTexture.Width+15) shr 4,
                             (fTransmittanceTexture.Height+15) shr 4,
                             1);


  ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                       VK_IMAGE_LAYOUT_GENERAL,
                                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fTransmittanceTexture.VulkanImage.Handle,
                                                       TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       1));

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

 end;

 begin

  // Multi scattering LUT

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.MultiScatteringLUT',[0.0,1.0,0.0,1.0]);

  ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(0,
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       VK_IMAGE_LAYOUT_UNDEFINED,
                                                       VK_IMAGE_LAYOUT_GENERAL,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fMultiScatteringTexture.VulkanImage.Handle,
                                                       TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       1{TpvScene3DRendererInstance(fRendererInstance).CountSurfaceViews}));

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);      

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,AtmosphereGlobals.fMultiScatteringLUTComputePipeline.Handle);

  DescriptorSets[0]:=TpvScene3D(fAtmosphere.fScene3D).GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[1]:=fGlobalDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[2]:=fMultiScatteringLUTPassDescriptorSets[aInFlightFrameIndex].Handle;

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       AtmosphereGlobals.fMultiScatteringLUTComputePipelineLayout.Handle,
                                       0,
                                       3,
                                       @DescriptorSets[0],
                                       0,
                                       nil);

  MultiScatteringLUTPushConstants.BaseViewIndex:=UnjitteredBaseViewIndex;
  MultiScatteringLUTPushConstants.CountViews:=CountViews;
  MultiScatteringLUTPushConstants.MultipleScatteringFactor:=1;
  MultiScatteringLUTPushConstants.FrameIndex:=pvApplication.DrawFrameCounter;

  aCommandBuffer.CmdPushConstants(AtmosphereGlobals.fMultiScatteringLUTComputePipelineLayout.Handle,
                                  TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TpvScene3DAtmosphereGlobals.TMultiScatteringLUTPushConstants),
                                  @MultiScatteringLUTPushConstants);

  aCommandBuffer.CmdDispatch(fMultiScatteringTexture.Width,
                             fMultiScatteringTexture.Height,
                             TpvScene3DRendererInstance(fRendererInstance).CountSurfaceViews);   

  ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                       VK_IMAGE_LAYOUT_GENERAL,
                                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fMultiScatteringTexture.VulkanImage.Handle,
                                                       TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       1{TpvScene3DRendererInstance(fRendererInstance).CountSurfaceViews}));

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);      

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

 end; 

 begin

  // Sky luminance LUT

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.SkyLuminanceLUT',[1.0,0.8,0.4,1.0]);

  ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(0,
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       VK_IMAGE_LAYOUT_UNDEFINED,
                                                       VK_IMAGE_LAYOUT_GENERAL,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fSkyLuminanceLUTTexture.VulkanImage.Handle,
                                                       TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       6));

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);   

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,AtmosphereGlobals.fSkyLuminanceLUTComputePipeline.Handle);

  DescriptorSets[0]:=TpvScene3D(fAtmosphere.fScene3D).GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[1]:=fGlobalDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[2]:=fSkyLuminanceLUTPassDescriptorSets[aInFlightFrameIndex].Handle;

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       AtmosphereGlobals.fSkyLuminanceLUTComputePipelineLayout.Handle,
                                       0,
                                       3,
                                       @DescriptorSets[0],
                                       0,
                                       nil);

  SkyLuminanceLUTPushConstants.BaseViewIndex:=UnjitteredBaseViewIndex;
  SkyLuminanceLUTPushConstants.CountViews:=CountViews;
  SkyLuminanceLUTPushConstants.FrameIndex:=pvApplication.DrawFrameCounter;
 
  aCommandBuffer.CmdPushConstants(AtmosphereGlobals.fSkyLuminanceLUTComputePipelineLayout.Handle,
                                  TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TpvScene3DAtmosphereGlobals.TSkyLuminanceLUTPushConstants),
                                  @SkyLuminanceLUTPushConstants);    

  aCommandBuffer.CmdDispatch(fSkyLuminanceLUTTexture.Width, 
                             fSkyLuminanceLUTTexture.Height,
                             6);    

  ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                       VK_IMAGE_LAYOUT_GENERAL,
                                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fSkyLuminanceLUTTexture.VulkanImage.Handle,
                                                       TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       6));

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);       

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

 end;
                                  

 if TpvScene3DRenderer(TpvScene3DRendererInstance(fRendererInstance).Renderer).FastSky then begin

  // Sky view LUT

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.SkyViewLUT',[0.0,0.0,1.0,1.0]);

  ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(0,
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       VK_IMAGE_LAYOUT_UNDEFINED,
                                                       VK_IMAGE_LAYOUT_GENERAL,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fSkyViewLUTTexture.VulkanImage.Handle,
                                                       TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       fSkyViewLUTTexture.Layers));

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);      

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,AtmosphereGlobals.fSkyViewLUTComputePipeline.Handle);

  DescriptorSets[0]:=TpvScene3D(fAtmosphere.fScene3D).GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[1]:=fGlobalDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[2]:=fSkyViewLUTPassDescriptorSets[aInFlightFrameIndex].Handle;

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       AtmosphereGlobals.fSkyViewLUTComputePipelineLayout.Handle,
                                       0,
                                       3,
                                       @DescriptorSets[0],
                                       0,
                                       nil);

  SkyViewLUTPushConstants.BaseViewIndex:=UnjitteredBaseViewIndex;
  SkyViewLUTPushConstants.CountViews:=CountViews;
  SkyViewLUTPushConstants.FrameIndex:=pvApplication.DrawFrameCounter;
  SkyViewLUTPushConstants.Dummy1:=0;

  aCommandBuffer.CmdPushConstants(AtmosphereGlobals.fSkyViewLUTComputePipelineLayout.Handle,
                                  TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TpvScene3DAtmosphereGlobals.TSkyViewLUTPushConstants),
                                  @SkyViewLUTPushConstants);

  aCommandBuffer.CmdDispatch((fSkyViewLUTTexture.Width+15) shr 4,
                             (fSkyViewLUTTexture.Height+15) shr 4,
                             TpvScene3DRendererInstance(fRendererInstance).CountSurfaceViews);    

  ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                       VK_IMAGE_LAYOUT_GENERAL,
                                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fSkyViewLUTTexture.VulkanImage.Handle,
                                                       TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       fSkyViewLUTTexture.Layers));

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

  fSkyViewLUTTextureImageLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;

 end else if fSkyViewLUTTextureImageLayout<>VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL then begin

  // Sky view LUT

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.SkyViewLUT',[0.0,0.0,1.0,1.0]);

  ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(0,
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                       VK_IMAGE_LAYOUT_UNDEFINED,
                                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fSkyViewLUTTexture.VulkanImage.Handle,
                                                       TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       fSkyViewLUTTexture.Layers));

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

  fSkyViewLUTTextureImageLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;

 end;

 if TpvScene3DRenderer(TpvScene3DRendererInstance(fRendererInstance).Renderer).FastAerialPerspective then begin

  // Camera volume

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.CameraVolume',[1.0,1.0,0.0,1.0]);

  ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(0,
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       VK_IMAGE_LAYOUT_UNDEFINED,
                                                       VK_IMAGE_LAYOUT_GENERAL,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fCameraVolumeTexture.VulkanImage.Handle,
                                                       TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       fCameraVolumeTexture.Layers));

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);      

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,AtmosphereGlobals.fCameraVolumeComputePipeline.Handle);

  DescriptorSets[0]:=TpvScene3D(fAtmosphere.fScene3D).GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[1]:=fGlobalDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[2]:=fCameraVolumePassDescriptorSets[aInFlightFrameIndex].Handle;

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       AtmosphereGlobals.fCameraVolumeComputePipelineLayout.Handle,
                                       0,
                                       3,
                                       @DescriptorSets[0],
                                       0,
                                       nil);

  CameraVolumePushConstants.BaseViewIndex:=UnjitteredBaseViewIndex;
  CameraVolumePushConstants.CountViews:=CountViews;
  CameraVolumePushConstants.FrameIndex:=pvApplication.DrawFrameCounter;
  CameraVolumePushConstants.Dummy1:=0;

  aCommandBuffer.CmdPushConstants(AtmosphereGlobals.fCameraVolumeComputePipelineLayout.Handle,
                                  TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TpvScene3DAtmosphereGlobals.TCameraVolumePushConstants),
                                  @CameraVolumePushConstants);

  aCommandBuffer.CmdDispatch((fCameraVolumeTexture.Width+15) shr 4,
                             (fCameraVolumeTexture.Height+15) shr 4,
                             fCameraVolumeTexture.Layers); // includes CountSurfaceViews already    

  ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                       VK_IMAGE_LAYOUT_GENERAL,
                                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fCameraVolumeTexture.VulkanImage.Handle,
                                                       TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       fCameraVolumeTexture.Layers));

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

  fCameraVolumeTextureImageLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;

 end else if fCameraVolumeTextureImageLayout<>VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL then begin

  // Camera volume

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.CameraVolume',[1.0,1.0,0.0,1.0]);

  ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(0,
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                       VK_IMAGE_LAYOUT_UNDEFINED,
                                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fCameraVolumeTexture.VulkanImage.Handle,
                                                       TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       fCameraVolumeTexture.Layers));

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

  fCameraVolumeTextureImageLayout:=VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;

 end;

 begin

  // Cube map pass

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.CubeMapPass',[1.0,0.0,1.0,1.0]);

  ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(0,
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       VK_IMAGE_LAYOUT_UNDEFINED,
                                                       VK_IMAGE_LAYOUT_GENERAL,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fCubeMapTexture.VulkanImage.Handle,
                                                       TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       6));

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);

  aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,AtmosphereGlobals.fCubeMapComputePipeline.Handle);

  DescriptorSets[0]:=TpvScene3D(fAtmosphere.fScene3D).GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[1]:=fGlobalDescriptorSets[aInFlightFrameIndex].Handle;
  DescriptorSets[2]:=fCubeMapPassDescriptorSets[aInFlightFrameIndex].Handle;

  aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                       AtmosphereGlobals.fCubeMapComputePipelineLayout.Handle,
                                       0,
                                       3,
                                       @DescriptorSets[0],
                                       0,
                                       nil);

  CubeMapPushConstants.CameraPosition:=TpvVector4.InlineableCreate(TpvScene3DRendererInstance(fRendererInstance).InFlightFrameStates^[aInFlightFrameIndex].MainCameraPosition,1.0);
  CubeMapPushConstants.UpVector:=TpvVector4.AllAxis;

  aCommandBuffer.CmdPushConstants(AtmosphereGlobals.fCubeMapComputePipelineLayout.Handle,
                                  TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                  0,
                                  SizeOf(TpvScene3DAtmosphereGlobals.TCubeMapPushConstants),
                                  @CubeMapPushConstants);

  aCommandBuffer.CmdDispatch((fCubeMapTexture.Width+15) shr 4,
                             (fCubeMapTexture.Height+15) shr 4,
                             6);

  ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                       VK_IMAGE_LAYOUT_GENERAL,
                                                       VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fCubeMapTexture.VulkanImage.Handle,
                                                       TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       6));

  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    0,
                                    0,nil,
                                    0,nil,
                                    1,@ImageMemoryBarriers[0]);  

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

 end;

 begin

  // Cube map mip map generation pass

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.CubeMapMipMapPass',[1.0,0.5,0.75,1.0]);

  fCubeMapMipMapGenerator.Execute(aCommandBuffer);

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

 end;

 begin
  
  // GGX cube map IBL filter pass 

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.GGXCubeMapIBLFilterPass',[0.5,1.0,0.75,1.0]);

  fGGXCubeMapIBLFilter.Execute(aCommandBuffer);

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

 end;

 begin

  // Charlie cube map IBL filter pass 

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.CharlieCubeMapIBLFilterPass',[0.5,0.75,1.0,1.0]);

  fCharlieCubeMapIBLFilter.Execute(aCommandBuffer);

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

 end;

 begin

  // Lambertian cube map IBL filter pass 

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.LambertianCubeMapIBLFilterPass',[0.75,1.0,0.5,1.0]);

  fLambertianCubeMapIBLFilter.Execute(aCommandBuffer);

  TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

 end;

end;

procedure TpvScene3DAtmosphere.TRendererInstance.DrawClouds(const aInFlightFrameIndex:TpvSizeInt;
                                                            const aCommandBuffer:TpvVulkanCommandBuffer;
                                                            const aDepthImageView:TVkImageView;
                                                            const aCascadedShadowMapImageView:TVkImageView);
var DescriptorSets:array[0..2] of TVkDescriptorSet;
begin

 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'Atmosphere.Clouds.Draw',[1.0,0.0,0.0,1.0]);

 SetCloudsImageViews(aInFlightFrameIndex,aDepthImageView,aCascadedShadowMapImageView);

 DescriptorSets[0]:=TpvScene3D(fAtmosphere.fScene3D).GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle;
 DescriptorSets[1]:=fGlobalDescriptorSets[aInFlightFrameIndex].Handle;
 DescriptorSets[2]:=fCloudRaymarchingPassDescriptorSets[aInFlightFrameIndex].Handle;

 aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                      TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).fCloudRaymarchingPipelineLayout.Handle,
                                      0,
                                      3,
                                      @DescriptorSets,
                                      0,
                                      nil);

 aCommandBuffer.CmdDraw(3,1,0,0);

 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

end;

procedure TpvScene3DAtmosphere.TRendererInstance.Draw(const aInFlightFrameIndex:TpvSizeInt;
                                                      const aCommandBuffer:TpvVulkanCommandBuffer;
                                                      const aDepthImageView:TVkImageView;
                                                      const aCascadedShadowMapImageView:TVkImageView;
                                                      const aCloudsInscatteringImageView:TVkImageView;
                                                      const aCloudsTransmittanceImageView:TVkImageView;
                                                      const aCloudsDepthImageView:TVkImageView;
                                                      var aPushConstants:TpvScene3DAtmosphereGlobals.TRaymarchingPushConstants);
var DescriptorSets:array[0..2] of TVkDescriptorSet;
begin

 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'Atmosphere.Draw',[1.0,0.0,0.0,1.0]);

 SetImageViews(aInFlightFrameIndex,aDepthImageView,aCascadedShadowMapImageView,aCloudsInscatteringImageView,aCloudsTransmittanceImageView,aCloudsDepthImageView);

 aCommandBuffer.CmdPushConstants(TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).RaymarchingPipelineLayout.Handle,
                                 TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_FRAGMENT_BIT),
                                 0,
                                 SizeOf(TpvScene3DAtmosphereGlobals.TRaymarchingPushConstants),
                                 @aPushConstants);

 DescriptorSets[0]:=TpvScene3D(fAtmosphere.fScene3D).GlobalVulkanDescriptorSets[aInFlightFrameIndex].Handle;
 DescriptorSets[1]:=fGlobalDescriptorSets[aInFlightFrameIndex].Handle;
 DescriptorSets[2]:=fRaymarchingPassDescriptorSets[aInFlightFrameIndex].Handle;

 aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                      TpvScene3DAtmosphereGlobals(TpvScene3D(fAtmosphere.fScene3D).AtmosphereGlobals).fRaymarchingPipelineLayout.Handle,
                                      0,
                                      3,
                                      @DescriptorSets,
                                      0,
                                      nil);

 aCommandBuffer.CmdDraw(3,1,0,0);

 TpvScene3D(fAtmosphere.fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

end;

{ TpvScene3DAtmosphere.TDirectionalMap }

constructor TpvScene3DAtmosphere.TDirectionalMap.Create(const aScene3D:TObject;const aAtmosphere:TpvScene3DAtmosphere;const aType:TpvUInt32);
var Index:TpvSizeInt;
begin

 inherited Create;

 fScene3D:=aScene3D;

 fAtmosphere:=aAtmosphere;

 fType:=aType;

 fName:=TpvScene3DAtmosphere.TDirectionalMap.Names[fType];

 fTexture:=nil;

 fTextureInitializationDescriptorPool:=nil;
 fTextureTransferDescriptorPool:=nil;
 fTextureScanDescriptorPool:=nil;

 for Index:=0 to MaxInFlightFrames-1 do begin
  fTextureInitializationDescriptorSets[Index]:=nil;
  fTextureTransferDescriptorSets[Index]:=nil;
 end;

 fTextureScanDescriptorSet:=nil;

 fTextureSourceImage:=nil;

 fTextureGeneration:=0;
 fTextureLastGeneration:=High(TpvUInt64);

end;

destructor TpvScene3DAtmosphere.TDirectionalMap.Destroy;
begin
 ReleaseResources;
 FreeAndNil(fTextureInitializationDescriptorPool);
 FreeAndNil(fTextureTransferDescriptorPool);
 FreeAndNil(fTexture);
 inherited Destroy;
end;

procedure TpvScene3DAtmosphere.TDirectionalMap.AfterConstruction;
begin
 inherited AfterConstruction;
end;

procedure TpvScene3DAtmosphere.TDirectionalMap.BeforeDestruction;
begin
 inherited BeforeDestruction;
end;

procedure TpvScene3DAtmosphere.TDirectionalMap.AcquireResources;
var Index:TpvSizeInt;
    Size:TpvInt32;
begin

 if assigned(fTextureSourceImage) then begin
  Size:=RoundUpToPowerOfTwo(Max(16,Round(Sqrt((fTextureSourceImage.Width*fTextureSourceImage.Height)/6.0))));
 end else begin
  Size:=8;
 end; 

 fTexture:=TpvScene3DRendererImageCubeMap.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                 Size,
                                                 Size,
                                                 TVkFormat(IfThen(fType=TDirectionalMap.Precipitation,TVkInt32(VK_FORMAT_R8_SNORM),TVkInt32(VK_FORMAT_R8_UNORM))),
                                                 true,
                                                 VK_SAMPLE_COUNT_1_BIT,
                                                 VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                 VK_SHARING_MODE_EXCLUSIVE,
                                                 nil,
                                                 0,
                                                 'TpvScene3DAtmosphere.TDirectionalMap["'+fName+'"]');

 fTextureGeneration:=0;
 fTextureLastGeneration:=High(TpvUInt64);

 fTextureInitializationDescriptorPool:=TpvVulkanDescriptorPool.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                                      TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                      TpvScene3D(fScene3D).CountInFlightFrames*2);
 fTextureInitializationDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,TpvScene3D(fScene3D).CountInFlightFrames);
 fTextureInitializationDescriptorPool.Initialize;
 TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fTextureInitializationDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DAtmosphere.TDirectionalMap["'+fName+'"].fTextureInitializationDescriptorPool');

 if assigned(fTextureSourceImage) then begin

  fTextureTransferDescriptorPool:=TpvVulkanDescriptorPool.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                                 TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                 TpvScene3D(fScene3D).CountInFlightFrames*2);
  fTextureTransferDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,TpvScene3D(fScene3D).CountInFlightFrames);
  fTextureTransferDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,TpvScene3D(fScene3D).CountInFlightFrames);
  fTextureTransferDescriptorPool.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fTextureTransferDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DAtmosphere.TDirectionalMap["'+fName+'"].fTextureTransferDescriptorPool');

 end;

 for Index:=0 to TpvScene3D(fScene3D).CountInFlightFrames-1 do begin

  fTextureInitializationDescriptorSets[Index]:=TpvVulkanDescriptorSet.Create(fTextureInitializationDescriptorPool,
                                                                              TpvScene3DAtmosphereGlobals(TpvScene3D(fScene3D).AtmosphereGlobals).fDirectionalMapTextureInitializationDescriptorSetLayout);

  fTextureInitializationDescriptorSets[Index].WriteToDescriptorSet(0,
                                                                   0,
                                                                   1,
                                                                   TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                   [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                  fTexture.VulkanImageView.Handle,
                                                                                                  VK_IMAGE_LAYOUT_GENERAL)],
                                                                   [],
                                                                   [],
                                                                   false);

  fTextureInitializationDescriptorSets[Index].Flush;

  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fTextureInitializationDescriptorSets[Index].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TpvScene3DAtmosphere.TDirectionalMap["'+fName+'"].fTextureInitializationDescriptorSets['+IntToStr(Index)+']');

  if assigned(fTextureSourceImage) then begin

   fTextureTransferDescriptorSets[Index]:=TpvVulkanDescriptorSet.Create(fTextureTransferDescriptorPool,
                                                                         TpvScene3DAtmosphereGlobals(TpvScene3D(fScene3D).AtmosphereGlobals).fDirectionalMapTextureTransferDescriptorSetLayout);

   fTextureTransferDescriptorSets[Index].WriteToDescriptorSet(0,
                                                              0,
                                                              1,
                                                              TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                              [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                             fTexture.VulkanImageView.Handle,
                                                                                             VK_IMAGE_LAYOUT_GENERAL)],
                                                              [],
                                                              [],
                                                              false);

   fTextureTransferDescriptorSets[Index].WriteToDescriptorSet(1,
                                                              0,
                                                              1,
                                                              TVkDescriptorType(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                                              [TVkDescriptorImageInfo.Create(TpvScene3D(fScene3D).GeneralComputeSampler.Handle,
                                                                                             fTextureSourceImage.VulkanImageView.Handle,
                                                                                             VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                              [],
                                                              [],
                                                              false);

   fTextureTransferDescriptorSets[Index].Flush;

   TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fTextureTransferDescriptorSets[Index].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TpvScene3DAtmosphere.TDirectionalMap["'+fName+'"].fTextureTransferDescriptorSets['+IntToStr(Index)+']');

  end;

 end;

 if assigned(fTextureSourceImage) then begin
   
  fTextureScanDescriptorPool:=TpvVulkanDescriptorPool.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                             TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                             2);          
  fTextureScanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,1);
  fTextureScanDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,1);
  fTextureScanDescriptorPool.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fTextureScanDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'TpvScene3DAtmosphere.TDirectionalMap["'+fName+'"].fTextureScanDescriptorPool');

  fTextureScanDescriptorSet:=TpvVulkanDescriptorSet.Create(fTextureScanDescriptorPool,
                                                           TpvScene3DAtmosphereGlobals(TpvScene3D(fScene3D).AtmosphereGlobals).fDirectionalMapTextureScanDescriptorSetLayout);
  
  fTextureScanDescriptorSet.WriteToDescriptorSet(0,
                                                 0,
                                                 1,
                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE),
                                                 [TVkDescriptorImageInfo.Create(TpvScene3D(fScene3D).GeneralComputeSampler.Handle,
                                                                                fTextureSourceImage.VulkanImageView.Handle,
                                                                                VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)],
                                                 [],
                                                 [],
                                                 false);
  fTextureScanDescriptorSet.WriteToDescriptorSet(1,
                                                 0,
                                                 1,
                                                 TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_BUFFER),
                                                 [],
                                                 [fAtmosphere.fAtmosphereMapMinMaxBuffer.DescriptorBufferInfo],
                                                 [],         
                                                 false);
  fTextureScanDescriptorSet.Flush;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fTextureScanDescriptorSet.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'TpvScene3DAtmosphere.TDirectionalMap["'+fName+'"].fTextureScanDescriptorSet');

 end;

end;

procedure TpvScene3DAtmosphere.TDirectionalMap.ReleaseResources;
var Index:TpvSizeInt;
begin
 
 for Index:=0 to MaxInFlightFrames-1 do begin
  FreeAndNil(fTextureTransferDescriptorSets[Index]);
  FreeAndNil(fTextureInitializationDescriptorSets[Index]);
 end;

 FreeAndNil(fTextureScanDescriptorSet);

 FreeAndNil(fTextureScanDescriptorPool);

 FreeAndNil(fTextureTransferDescriptorPool);
 FreeAndNil(fTextureInitializationDescriptorPool);

 FreeAndNil(fTexture);

 fTextureSourceImage:=nil;

end;

procedure TpvScene3DAtmosphere.TDirectionalMap.Update(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex:TpvSizeInt;const aQueueFamilyIndex:TpvInt32=-1);
const FloatOne:TpvFloat=1.0;
var ImageMemoryBarriers:array[0..1] of TVkImageMemoryBarrier;
    BufferMemoryBarrier:TVkBufferMemoryBarrier;
    DirectionalMapTextureInitializationPushConstants:TpvScene3DAtmosphereGlobals.TDirectionalMapTextureInitializationPushConstants;
    SourcePipelineStageFlags,DestPipelineStageFlags:TVkPipelineStageFlags;
begin

 // Calculate appropriate pipeline stages based on queue family
 if (aQueueFamilyIndex>=0) and (aQueueFamilyIndex=TpvScene3D(fScene3D).VulkanDevice.ComputeQueueFamilyIndex) and 
    (TpvScene3D(fScene3D).VulkanDevice.UniversalQueueFamilyIndex<>TpvScene3D(fScene3D).VulkanDevice.ComputeQueueFamilyIndex) then begin
   // We're on a compute-only queue, use only compute pipeline stages
   SourcePipelineStageFlags:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT);
   DestPipelineStageFlags:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT);
 end else begin
   // We're on the universal queue or default, can use graphics+compute pipeline stages  
   SourcePipelineStageFlags:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT);
   DestPipelineStageFlags:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT);
 end;

 // Two code paths, if a source image is assigned or not.
 // If a source image is assigned, we need to transfer the data from the source image to the target image.
 // If no source image is assigned, we just need to initialize the target image.  

 if fTextureLastGeneration<>fTextureGeneration then begin

  fTextureLastGeneration:=fTextureGeneration;

  if assigned(fTextureSourceImage) then begin

   TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.TDirectionalMap.Update',[0.0,1.0,0.0,1.0]);

   if fType=TDirectionalMap.Atmosphere then begin

    // Set atmosphere map min/max buffer to $ffffffff and $00000000 values, for atomic min/max operations later
    // This is done to ensure that the min/max values are initialized to the maximum and minimum possible values 

    TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.TDirectionalMap.Update.ClearAtmosphereMapMinMaxBuffer',[0.25,1.0,0.0,1.0]);

    BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT) or TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                       TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fAtmosphere.fAtmosphereMapMinMaxBuffer.Handle,
                                                       0,
                                                       fAtmosphere.fAtmosphereMapMinMaxBuffer.Size);

    aCommandBuffer.CmdPipelineBarrier(SourcePipelineStageFlags,
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                      0,
                                      0,nil,
                                      1,@BufferMemoryBarrier,
                                      0,nil);

    aCommandBuffer.CmdFillBuffer(fAtmosphere.fAtmosphereMapMinMaxBuffer.Handle,
                                 0,
                                 SizeOf(TpvUInt32),
                                 TpvUInt32($ffffffff));
                                 
    aCommandBuffer.CmdFillBuffer(fAtmosphere.fAtmosphereMapMinMaxBuffer.Handle,
                                 SizeOf(TpvUInt32),
                                 SizeOf(TpvUInt32),
                                 TpvUInt32($00000000));                             

    BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fAtmosphere.fAtmosphereMapMinMaxBuffer.Handle,
                                                       0,
                                                       fAtmosphere.fAtmosphereMapMinMaxBuffer.Size);

    aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                      DestPipelineStageFlags,
                                      0,
                                      0,nil,
                                      1,@BufferMemoryBarrier,
                                      0,nil);

    TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

   end;

   TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.TDirectionalMap.Update.Barrier0',[0.0,0.5,1.0,1.0]);

   ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(0,
                                                        TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                        VK_IMAGE_LAYOUT_UNDEFINED,
                                                        VK_IMAGE_LAYOUT_GENERAL,
                                                        VK_QUEUE_FAMILY_IGNORED,
                                                        VK_QUEUE_FAMILY_IGNORED,
                                                        fTexture.VulkanImage.Handle,
                                                        TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                        0,
                                                                                        1,
                                                                                        0,
                                                                                        6));

   ImageMemoryBarriers[1]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                        TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                        VK_QUEUE_FAMILY_IGNORED,
                                                        VK_QUEUE_FAMILY_IGNORED,
                                                        fTextureSourceImage.VulkanImage.Handle,
                                                        TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                        0,
                                                                                        1,
                                                                                        0,
                                                                                        1));                                                                                     

   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     0,
                                     0,nil,
                                     0,nil,
                                     2,@ImageMemoryBarriers[0]);

   TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

   //////////////////////////////////////////////////
   
   TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.TDirectionalMap.Update.TextureScan',[0.0,0.75,1.0,1.0]);

   aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,TpvScene3DAtmosphereGlobals(TpvScene3D(fScene3D).AtmosphereGlobals).fDirectionalMapTextureScanComputePipeline.Handle);

   aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                        TpvScene3DAtmosphereGlobals(TpvScene3D(fScene3D).AtmosphereGlobals).fDirectionalMapTextureScanComputePipelineLayout.Handle,
                                        0,
                                        1,@fTextureScanDescriptorSet.Handle,
                                        0,nil);

   aCommandBuffer.CmdDispatch((fTextureSourceImage.Width+15) shr 4,
                              (fTextureSourceImage.Height+15) shr 4,
                              1);

   BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                      TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      fAtmosphere.fAtmosphereMapMinMaxBuffer.Handle,
                                                      0,
                                                      fAtmosphere.fAtmosphereMapMinMaxBuffer.Size); 

   TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);                          

   //////////////////////////////////////////////////

   TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.TDirectionalMap.Update.TextureTransfer',[0.0,1.0,0.5,1.0]);

   if fType=TDirectionalMap.Atmosphere then begin
    aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,TpvScene3DAtmosphereGlobals(TpvScene3D(fScene3D).AtmosphereGlobals).fDirectionalMapTextureTransferComputeR8UNormPipeline.Handle);
   end else begin
    aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,TpvScene3DAtmosphereGlobals(TpvScene3D(fScene3D).AtmosphereGlobals).fDirectionalMapTextureTransferComputeR8SNormPipeline.Handle);
   end;

   aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                        TpvScene3DAtmosphereGlobals(TpvScene3D(fScene3D).AtmosphereGlobals).fDirectionalMapTextureTransferComputePipelineLayout.Handle,
                                        0,
                                        1,@fTextureTransferDescriptorSets[aInFlightFrameIndex].Handle,
                                        0,nil);

   aCommandBuffer.CmdDispatch((fTexture.Width+15) shr 4,
                              (fTexture.Height+15) shr 4,
                              6);

   ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                        TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                        VK_IMAGE_LAYOUT_GENERAL,
                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                        VK_QUEUE_FAMILY_IGNORED,
                                                        VK_QUEUE_FAMILY_IGNORED,
                                                        fTexture.VulkanImage.Handle,
                                                        TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                        0,
                                                                                        1,
                                                                                        0,
                                                                                        6));

   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     DestPipelineStageFlags,
                                     0,
                                     0,nil,
                                     1,@BufferMemoryBarrier,
                                     1,@ImageMemoryBarriers[0]);         

   TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

   TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

  end else begin

   TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.TDirectionalMap.Update',[0.0,1.0,0.0,1.0]);

   if fType=TDirectionalMap.Atmosphere then begin
   
    // Set atmosphere map min/max buffer to one float values

    TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.TDirectionalMap.Update.ClearAtmosphereMapMinMaxBuffer',[0.25,1.0,0.0,1.0]);

    BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT) or TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                       TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fAtmosphere.fAtmosphereMapMinMaxBuffer.Handle,
                                                       0,
                                                       fAtmosphere.fAtmosphereMapMinMaxBuffer.Size);

    aCommandBuffer.CmdPipelineBarrier(SourcePipelineStageFlags,
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                      0,
                                      0,nil,
                                      1,@BufferMemoryBarrier,
                                      0,nil);

    aCommandBuffer.CmdFillBuffer(fAtmosphere.fAtmosphereMapMinMaxBuffer.Handle,
                                 0,
                                 fAtmosphere.fAtmosphereMapMinMaxBuffer.Size,
                                 PpvUInt32(pointer(@FloatOne))^);

    BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT),
                                                       TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       VK_QUEUE_FAMILY_IGNORED,
                                                       fAtmosphere.fAtmosphereMapMinMaxBuffer.Handle,
                                                       0,
                                                       fAtmosphere.fAtmosphereMapMinMaxBuffer.Size);

    aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                      DestPipelineStageFlags,
                                      0,
                                      0,nil,
                                      1,@BufferMemoryBarrier,
                                      0,nil);

    TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

   end;

   TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'TpvScene3DAtmosphere.TDirectionalMap.Update.Initialization',[0.0,0.5,1.0,1.0]);

   ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(0,
                                                        TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                        VK_IMAGE_LAYOUT_UNDEFINED,
                                                        VK_IMAGE_LAYOUT_GENERAL,
                                                        VK_QUEUE_FAMILY_IGNORED,
                                                        VK_QUEUE_FAMILY_IGNORED,
                                                        fTexture.VulkanImage.Handle,
                                                        TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                        0,
                                                                                        1,
                                                                                        0,
                                                                                        6));

   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     0,
                                     0,nil,
                                     0,nil,
                                     1,@ImageMemoryBarriers[0]);

   aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,TpvScene3DAtmosphereGlobals(TpvScene3D(fScene3D).AtmosphereGlobals).fDirectionalMapTextureInitializationComputePipeline.Handle);

   if fType=TDirectionalMap.Precipitation then begin
    DirectionalMapTextureInitializationPushConstants.Value:=TpvVector4.InlineableCreate(0.0,0.0,0.0,0.0);
   end else begin
    DirectionalMapTextureInitializationPushConstants.Value:=TpvVector4.InlineableCreate(1.0,1.0,1.0,1.0);
   end;

   aCommandBuffer.CmdPushConstants(TpvScene3DAtmosphereGlobals(TpvScene3D(fScene3D).AtmosphereGlobals).fDirectionalMapTextureInitializationComputePipelineLayout.Handle,
                                   TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                   0,
                                   SizeOf(TpvScene3DAtmosphereGlobals.TDirectionalMapTextureInitializationPushConstants),
                                   @DirectionalMapTextureInitializationPushConstants);

   aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                        TpvScene3DAtmosphereGlobals(TpvScene3D(fScene3D).AtmosphereGlobals).fDirectionalMapTextureInitializationComputePipelineLayout.Handle,
                                        0,
                                        1,@fTextureInitializationDescriptorSets[aInFlightFrameIndex].Handle,
                                        0,nil);

   aCommandBuffer.CmdDispatch((fTexture.Width+15) shr 4,
                              (fTexture.Height+15) shr 4,
                              6);

   ImageMemoryBarriers[0]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                        TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                        VK_IMAGE_LAYOUT_GENERAL,
                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                        VK_QUEUE_FAMILY_IGNORED,
                                                        VK_QUEUE_FAMILY_IGNORED,
                                                        fTexture.VulkanImage.Handle,
                                                        TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                        0,
                                                                                        1,
                                                                                        0,
                                                                                        6));

   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     DestPipelineStageFlags,
                                     0,
                                     0,nil,
                                     0,nil,
                                     1,@ImageMemoryBarriers[0]);     

   TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

   TpvScene3D(fScene3D).VulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

  end;

 end;

 // Add memory barrier to ensure atmosphere map min/max buffer writes are visible to atmosphere rendering
 if (fType=TDirectionalMap.Atmosphere) and assigned(fAtmosphere.fAtmosphereMapMinMaxBuffer) then begin
  BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                     TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                     VK_QUEUE_FAMILY_IGNORED,
                                                     VK_QUEUE_FAMILY_IGNORED,
                                                     fAtmosphere.fAtmosphereMapMinMaxBuffer.Handle,
                                                     0,
                                                     fAtmosphere.fAtmosphereMapMinMaxBuffer.Size);
  aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                    TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                    0,
                                    0,nil,
                                    1,@BufferMemoryBarrier,
                                    0,nil);
 end;

end;

{ TpvScene3DAtmosphere }

constructor TpvScene3DAtmosphere.Create(const aScene3D:TObject);
begin
 
 inherited Create;

 fScene3D:=aScene3D;
 
 fAtmosphereParameters.InitializeEarthAtmosphere;
 fPointerToAtmosphereParameters:=@fAtmosphereParameters;
 
 FillChar(fAtmosphereParametersBuffers,SizeOf(fAtmosphereParametersBuffers),#0);

 if assigned(TpvScene3D(fScene3D).VulkanDevice) then begin

  fAtmosphereMapMinMaxBuffer:=TpvVulkanBuffer.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                     SizeOf(TpvFloat)*2, // 2 floats for min and max
                                                     TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or
                                                     TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or
                                                     TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT) or
                                                     TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT_KHR),
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
                                                     [TpvVulkanBufferFlag.PreferDedicatedAllocation],
                                                     0,
                                                     pvAllocationGroupIDScene3DDynamic);
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fAtmosphereMapMinMaxBuffer.Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DAtmosphere.fAtmosphereMapMinMaxBuffer');

 end else begin

  fAtmosphereMapMinMaxBuffer:=nil;

 end;


 fRendererInstances:=TRendererInstances.Create(true);
 fRendererInstanceHashMap:=TRendererInstanceHashMap.Create(nil);
 fRendererInstanceListLock:=TPasMPSlimReaderWriterLock.Create;
 
 fUploaded:=false;

 fVisible:=true;

 FillChar(fInFlightFrameVisible,SizeOf(fInFlightFrameVisible),#0);

 fPrecipitationMap:=TDirectionalMap.Create(fScene3D,self,TDirectionalMap.Precipitation);

 fAtmosphereMap:=TDirectionalMap.Create(fScene3D,self,TDirectionalMap.Atmosphere);

 fUsePrecipitationMap:=true;

 fUseAtmosphereMap:=true;

 fReady:=true;

end;

destructor TpvScene3DAtmosphere.Destroy;
begin

 Unload;

 FreeAndNil(fAtmosphereMap);

 FreeAndNil(fPrecipitationMap);

 FreeAndNil(fAtmosphereMapMinMaxBuffer);

 while fRendererInstances.Count>0 do begin
  fRendererInstances.Items[fRendererInstances.Count-1].Free;
 end;
 FreeAndNil(fRendererInstances);

 FreeAndNil(fRendererInstanceHashMap);

 FreeAndNil(fRendererInstanceListLock);

 inherited Destroy;

end;

procedure TpvScene3DAtmosphere.AfterConstruction;
begin
 inherited AfterConstruction;
 if assigned(fScene3D) then begin
  TpvScene3DAtmospheres(TpvScene3D(fScene3D).Atmospheres).Lock.AcquireWrite;
  try
   TpvScene3DAtmospheres(TpvScene3D(fScene3D).Atmospheres).Add(self);
  finally
   TpvScene3DAtmospheres(TpvScene3D(fScene3D).Atmospheres).Lock.ReleaseWrite;
  end;
 end;
end;

procedure TpvScene3DAtmosphere.BeforeDestruction;
var Index:TpvSizeInt;
begin
 if assigned(fScene3D) and assigned(TpvScene3D(fScene3D).Atmospheres) then begin
  TpvScene3DAtmospheres(TpvScene3D(fScene3D).Atmospheres).Lock.AcquireWrite;
  try
   Index:=TpvScene3DAtmospheres(TpvScene3D(fScene3D).Atmospheres).IndexOf(self);
   if Index>=0 then begin
    TpvScene3DAtmospheres(TpvScene3D(fScene3D).Atmospheres).Extract(Index); // not delete or remove, since we don't want to free ourself here already.
   end;
  finally
   TpvScene3DAtmospheres(TpvScene3D(fScene3D).Atmospheres).Lock.ReleaseWrite;
  end;
 end;
 inherited BeforeDestruction;
end;

procedure TpvScene3DAtmosphere.Release;
begin
 if fReleaseFrameCounter<0 then begin
  fReleaseFrameCounter:=TpvScene3D(fScene3D).CountInFlightFrames;
  fReady:=false;
 end;
end;

function TpvScene3DAtmosphere.HandleRelease:boolean;
begin
 if fReleaseFrameCounter>0 then begin
  result:=TPasMPInterlocked.Decrement(fReleaseFrameCounter)=0;
  if result then begin
   Free;
  end;
 end else begin
  result:=false;
 end;
end;

procedure TpvScene3DAtmosphere.Upload;
var InFlightFrameIndex,Index:TpvSizeInt;
begin
 
 if assigned(TpvScene3D(fScene3D).VulkanDevice) and not fUploaded then begin

  fPrecipitationMap.AcquireResources;

  fAtmosphereMap.AcquireResources;
 
  for InFlightFrameIndex:=0 to TpvScene3D(fScene3D).CountInFlightFrames-1 do begin

   fAtmosphereParametersBuffers[InFlightFrameIndex]:=TpvVulkanBuffer.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                                            SizeOf(TGPUAtmosphereParameters),
                                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or
                                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) or
                                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT) or
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
                                                                            [TpvVulkanBufferFlag.PersistentMappedIfPossible,TpvVulkanBufferFlag.OwnSingleMemoryChunk,TpvVulkanBufferFlag.DedicatedAllocation],
                                                                            0,
                                                                            pvAllocationGroupIDScene3DDynamic);
   TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fAtmosphereParametersBuffers[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_BUFFER,'TpvScene3DAtmosphere.fAtmosphereParametersBuffers['+IntToStr(InFlightFrameIndex)+']');
 
  end;

  fWeatherMapTexture:=TpvScene3DRendererImageCubeMap.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                            1024,
                                                            1024,
                                                            VK_FORMAT_R8G8B8A8_UNORM,
                                                            true,
                                                            VK_SAMPLE_COUNT_1_BIT,
                                                            VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                            VK_SHARING_MODE_EXCLUSIVE,
                                                            nil,
                                                            0,
                                                            'TpvScene3DAtmosphere.fWeatherMapTexture');

  fWeatherMapTextureDescriptorPool:=TpvVulkanDescriptorPool.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                                   TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                                   TpvScene3D(fScene3D).CountInFlightFrames*2);
  fWeatherMapTextureDescriptorPool.AddDescriptorPoolSize(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,TpvScene3D(fScene3D).CountInFlightFrames*2);
  fWeatherMapTextureDescriptorPool.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fWeatherMapTextureDescriptorPool.Handle,VK_OBJECT_TYPE_DESCRIPTOR_POOL,'WeatherMapTextureDescriptorPool');

  begin

   for InFlightFrameIndex:=0 to TpvScene3D(fScene3D).CountInFlightFrames-1 do begin

    fWeatherMapTextureDescriptorSets[InFlightFrameIndex]:=TpvVulkanDescriptorSet.Create(fWeatherMapTextureDescriptorPool,
                                                                                        TpvScene3DAtmosphereGlobals(TpvScene3D(fScene3D).AtmosphereGlobals).fWeatherMapTextureDescriptorSetLayout);

    fWeatherMapTextureDescriptorSets[InFlightFrameIndex].WriteToDescriptorSet(0,
                                                                              0,
                                                                              1,
                                                                              TVkDescriptorType(VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                                                              [TVkDescriptorImageInfo.Create(VK_NULL_HANDLE,
                                                                                                             fWeatherMapTexture.VulkanImageView.Handle,
                                                                                                             VK_IMAGE_LAYOUT_GENERAL)],
                                                                              [],
                                                                              [],
                                                                              false);

    fWeatherMapTextureDescriptorSets[InFlightFrameIndex].Flush;

    TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fWeatherMapTextureDescriptorSets[InFlightFrameIndex].Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET,'WeatherMapTextureDescriptorSets['+IntToStr(Index)+']['+IntToStr(InFlightFrameIndex)+']');

   end;

   fWeatherMapTextureGeneration:=1;

   fWeatherMapTextureLastGeneration:=0;

   FillChar(fCloudWeatherMapPushConstants,SizeOf(TpvScene3DAtmosphereGlobals.TCloudWeatherMapPushConstants),#0);

  end;

  fUploaded:=true;
 
 end;

end;

procedure TpvScene3DAtmosphere.Unload;
var InFlightFrameIndex,Index:TpvSizeInt;
begin
 if fUploaded then begin
  for InFlightFrameIndex:=0 to TpvScene3D(fScene3D).CountInFlightFrames-1 do begin
   FreeAndNil(fAtmosphereParametersBuffers[InFlightFrameIndex]);
  end;
  for InFlightFrameIndex:=0 to TpvScene3D(fScene3D).CountInFlightFrames-1 do begin
   FreeAndNil(fWeatherMapTextureDescriptorSets[InFlightFrameIndex]);
  end;
  FreeAndNil(fWeatherMapTextureDescriptorPool);
  FreeAndNil(fWeatherMapTexture);
  fAtmosphereMap.ReleaseResources;
  fPrecipitationMap.ReleaseResources;
  fUploaded:=false;
 end;
end;

procedure TpvScene3DAtmosphere.Update(const aInFlightFrameIndex:TpvSizeInt);
var IsVisible:boolean;
begin

 IsVisible:=fReady;

 if IsVisible then begin

  fGPUAtmosphereParameters[aInFlightFrameIndex].Assign(fAtmosphereParameters,fScene3D,aInFlightFrameIndex);

  fGPUAtmosphereParameters[aInFlightFrameIndex].Flags:=IfThen(assigned(fPrecipitationMap.fTextureSourceImage) and fUsePrecipitationMap,1 shl 0,0) or
                                                       IfThen(assigned(fAtmosphereMap.fTextureSourceImage) and fUseAtmosphereMap,1 shl 1,0);

{ fGPUAtmosphereParameters[aInFlightFrameIndex].Transform:=fGPUAtmosphereParameters[aInFlightFrameIndex].Transform;
  fGPUAtmosphereParameters[aInFlightFrameIndex].InverseTransform:=fGPUAtmosphereParameters[aInFlightFrameIndex].Transform.Inverse;}

  IsVisible:=fGPUAtmosphereParameters[aInFlightFrameIndex].AbsorptionExtinction.w>1e-7;

 end;

 fInFlightFrameVisible[aInFlightFrameIndex]:=IsVisible;

end;

procedure TpvScene3DAtmosphere.UploadFrame(const aInFlightFrameIndex:TpvSizeInt;
                                           const aTransferQueue:TpvVulkanQueue;
                                           const aTransferCommandBuffer:TpvVulkanCommandBuffer;
                                           const aTransferFence:TpvVulkanFence);
begin

 if fUploaded and fInFlightFrameVisible[aInFlightFrameIndex] then begin

  if assigned(fAtmosphereParametersBuffers[aInFlightFrameIndex]) then begin

   TpvScene3D(fScene3D).VulkanDevice.MemoryStaging.Upload(aTransferQueue,
                                                          aTransferCommandBuffer,
                                                          aTransferFence,
                                                          fGPUAtmosphereParameters[aInFlightFrameIndex],
                                                          fAtmosphereParametersBuffers[aInFlightFrameIndex],
                                                          0,
                                                          SizeOf(TGPUAtmosphereParameters));

  end;

 end;

end;

function TpvScene3DAtmosphere.IsInFlightFrameVisible(const aInFlightFrameIndex:TpvSizeInt):Boolean;
begin
 result:=fInFlightFrameVisible[aInFlightFrameIndex];
end;

function TpvScene3DAtmosphere.GetRenderInstance(const aRendererInstance:TObject):TpvScene3DAtmosphere.TRendererInstance;
var AtmosphereRendererInstanceKey:TpvScene3DAtmosphere.TRendererInstance.TKey;
begin
 AtmosphereRendererInstanceKey:=TpvScene3DAtmosphere.TRendererInstance.TKey.Create(aRendererInstance);
 result:=fRendererInstanceHashMap[AtmosphereRendererInstanceKey];
 if not assigned(result) then begin
  result:=TpvScene3DAtmosphere.TRendererInstance.Create(self,aRendererInstance);
 end;
end;

procedure TpvScene3DAtmosphere.ProcessSimulation(const aCommandBuffer:TpvVulkanCommandBuffer;
                                                 const aInFlightFrameIndex:TpvSizeInt;
                                                 const aQueueFamilyIndex:TpvInt32=-1);
var Index:TpvSizeInt;
    AtmosphereGlobals:TpvScene3DAtmosphereGlobals;
    PushConstants:TpvScene3DAtmosphereGlobals.TCloudWeatherMapPushConstants;
    ImageMemoryBarrier:TVkImageMemoryBarrier;
    BufferMemoryBarrier:TVkBufferMemoryBarrier;
    ImageMemoryBarriers:array[0..2] of TVkImageMemoryBarrier;
    ImageBarrierCount,BufferBarrierCount:TpvUInt32;
    SourcePipelineStageFlags,DestPipelineStageFlags:TVkPipelineStageFlags;
begin

 // Calculate appropriate pipeline stages based on queue family
 if (aQueueFamilyIndex>=0) and (aQueueFamilyIndex=TpvScene3D(fScene3D).VulkanDevice.ComputeQueueFamilyIndex) and 
    (TpvScene3D(fScene3D).VulkanDevice.UniversalQueueFamilyIndex<>TpvScene3D(fScene3D).VulkanDevice.ComputeQueueFamilyIndex) then begin
   // We're on a compute-only queue, use only compute pipeline stages
   SourcePipelineStageFlags:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT);
   DestPipelineStageFlags:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT);
 end else begin
   // We're on the universal queue or default, can use graphics+compute pipeline stages  
   SourcePipelineStageFlags:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT);
   DestPipelineStageFlags:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT);
 end;

 if fInFlightFrameVisible[aInFlightFrameIndex] then begin

  fAtmosphereMap.Update(aCommandBuffer,aInFlightFrameIndex,aQueueFamilyIndex);

  fPrecipitationMap.Update(aCommandBuffer,aInFlightFrameIndex,aQueueFamilyIndex);

  begin

   FillChar(PushConstants,SizeOf(TpvScene3DAtmosphereGlobals.TCloudWeatherMapPushConstants),#0);
   PushConstants.CoverageRotation:=TpvVector4.InlineableCreate(1.0,0.0,0.0,1.0*(PI*0.25));
   PushConstants.TypeRotation:=TpvVector4.InlineableCreate(1.0,0.0,0.0,1.0*(PI*0.125));
   PushConstants.WetnessRotation:=TpvVector4.InlineableCreate(1.0,0.0,0.0,1.0*(PI*0.5));
   PushConstants.TopRotation:=TpvVector4.InlineableCreate(1.0,0.0,0.0,1.0*(PI*0.75));
   PushConstants.CoveragePerlinWorleyDifference:=0.5;
   PushConstants.TotalSize:=4.0;
   PushConstants.WorleySeed:=10.0;

   if (fWeatherMapTextureLastGeneration=fWeatherMapTextureGeneration) and not CompareMem(@PushConstants,@fCloudWeatherMapPushConstants,SizeOf(TpvScene3DAtmosphereGlobals.TCloudWeatherMapPushConstants)) then begin
    inc(fWeatherMapTextureGeneration);
   end;

   fCloudWeatherMapPushConstants:=PushConstants;

   if fWeatherMapTextureLastGeneration<>fWeatherMapTextureGeneration then begin

    fWeatherMapTextureLastGeneration:=fWeatherMapTextureGeneration;

    AtmosphereGlobals:=TpvScene3DAtmosphereGlobals(TpvScene3D(fScene3D).AtmosphereGlobals);

    ImageMemoryBarrier:=TVkImageMemoryBarrier.Create(0,
                                                     TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                     VK_IMAGE_LAYOUT_UNDEFINED,
                                                     VK_IMAGE_LAYOUT_GENERAL,
                                                     VK_QUEUE_FAMILY_IGNORED,
                                                     VK_QUEUE_FAMILY_IGNORED,
                                                     fWeatherMapTexture.VulkanImage.Handle,
                                                     TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                     0,
                                                                                     1,
                                                                                     0,
                                                                                     6));

    aCommandBuffer.CmdPipelineBarrier(SourcePipelineStageFlags,
                                      TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                      0,
                                      0,nil,
                                      0,nil,
                                      1,@ImageMemoryBarrier);

    aCommandBuffer.CmdBindPipeline(VK_PIPELINE_BIND_POINT_COMPUTE,AtmosphereGlobals.fCloudWeatherMapComputePipeline.Handle);

    aCommandBuffer.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_COMPUTE,
                                         AtmosphereGlobals.fCloudWeatherMapComputePipelineLayout.Handle,
                                         0,
                                         1,
                                         @fWeatherMapTextureDescriptorSets[aInFlightFrameIndex].Handle,
                                         0,
                                         nil);

    aCommandBuffer.CmdPushConstants(AtmosphereGlobals.fCloudWeatherMapComputePipelineLayout.Handle,
                                    TVkShaderStageFlags(TVkShaderStageFlagBits.VK_SHADER_STAGE_COMPUTE_BIT),
                                    0,
                                    SizeOf(TpvScene3DAtmosphereGlobals.TCloudWeatherMapPushConstants),
                                    @PushConstants);

    aCommandBuffer.CmdDispatch((fWeatherMapTexture.Width+15) shr 4,
                               (fWeatherMapTexture.Height+15) shr 4,
                               6);

    ImageMemoryBarrier:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                     TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                     VK_IMAGE_LAYOUT_GENERAL,
                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                     VK_QUEUE_FAMILY_IGNORED,
                                                     VK_QUEUE_FAMILY_IGNORED,
                                                     fWeatherMapTexture.VulkanImage.Handle,
                                                     TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                     0,
                                                                                     1,
                                                                                     0,
                                                                                     6));

    aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                      SourcePipelineStageFlags,
                                      0,
                                      0,nil,
                                      0,nil,
                                      1,@ImageMemoryBarrier);

   end;

  end;

  // Add explicit memory barriers for all atmosphere buffers and images
  // to ensure compute shader writes are visible before subsequent operations
  
  // Collect all image memory barriers
  ImageBarrierCount:=0;
  BufferBarrierCount:=0;
  
  // Memory barrier for atmosphere map texture
  if assigned(fAtmosphereMap) and assigned(fAtmosphereMap.fTexture) then begin
   ImageMemoryBarriers[ImageBarrierCount]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                                        TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                                        VK_QUEUE_FAMILY_IGNORED,
                                                                        VK_QUEUE_FAMILY_IGNORED,
                                                                        fAtmosphereMap.fTexture.VulkanImage.Handle,
                                                                        TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                                        0,
                                                                                                        1,
                                                                                                        0,
                                                                                                        6));
   inc(ImageBarrierCount);
  end;
  
  // Memory barrier for precipitation map texture  
  if assigned(fPrecipitationMap) and assigned(fPrecipitationMap.fTexture) then begin
   ImageMemoryBarriers[ImageBarrierCount]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                                        TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                                        VK_QUEUE_FAMILY_IGNORED,
                                                                        VK_QUEUE_FAMILY_IGNORED,
                                                                        fPrecipitationMap.fTexture.VulkanImage.Handle,
                                                                        TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                                        0,
                                                                                                        1,
                                                                                                        0,
                                                                                                        6));
   inc(ImageBarrierCount);
  end;

  // Memory barrier for weather map texture
  if assigned(fWeatherMapTexture) then begin
   ImageMemoryBarriers[ImageBarrierCount]:=TVkImageMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT),
                                                                        TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                                        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                                        VK_QUEUE_FAMILY_IGNORED,
                                                                        VK_QUEUE_FAMILY_IGNORED,
                                                                        fWeatherMapTexture.VulkanImage.Handle,
                                                                        TVkImageSubresourceRange.Create(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                                                                        0,
                                                                                                        1,
                                                                                                        0,
                                                                                                        6));
   inc(ImageBarrierCount);
  end;

  // Memory barrier for atmosphere map min/max buffer
  if assigned(fAtmosphereMapMinMaxBuffer) then begin
   BufferMemoryBarrier:=TVkBufferMemoryBarrier.Create(TVkAccessFlags(VK_ACCESS_SHADER_WRITE_BIT),
                                                      TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT) or TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      VK_QUEUE_FAMILY_IGNORED,
                                                      fAtmosphereMapMinMaxBuffer.Handle,
                                                      0,
                                                      fAtmosphereMapMinMaxBuffer.Size);
   BufferBarrierCount:=1;
  end;

  // Single pipeline barrier call for all barriers
  if (ImageBarrierCount>0) or (BufferBarrierCount>0) then begin
   aCommandBuffer.CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT),
                                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT),
                                     0,
                                     0,nil,
                                     BufferBarrierCount,@BufferMemoryBarrier,
                                     ImageBarrierCount,@ImageMemoryBarriers[0]);
  end;

 end;

end;

procedure TpvScene3DAtmosphere.Execute(const aInFlightFrameIndex:TpvSizeInt;
                                       const aCommandBuffer:TpvVulkanCommandBuffer;
                                       const aRendererInstance:TObject);
var AtmosphereRendererInstance:TpvScene3DAtmosphere.TRendererInstance;
begin

 if fInFlightFrameVisible[aInFlightFrameIndex] then begin

  AtmosphereRendererInstance:=GetRenderInstance(aRendererInstance);

  if assigned(AtmosphereRendererInstance) then begin
   AtmosphereRendererInstance.Execute(aInFlightFrameIndex,aCommandBuffer);
  end;
   
 end;

end;

procedure TpvScene3DAtmosphere.DrawClouds(const aInFlightFrameIndex:TpvSizeInt;
                                          const aCommandBuffer:TpvVulkanCommandBuffer;
                                          const aDepthImageView:TVkImageView;
                                          const aCascadedShadowMapImageView:TVkImageView;
                                          const aRendererInstance:TObject);
var AtmosphereRendererInstance:TpvScene3DAtmosphere.TRendererInstance;
begin

 if fInFlightFrameVisible[aInFlightFrameIndex] then begin

  AtmosphereRendererInstance:=GetRenderInstance(aRendererInstance);

  if assigned(AtmosphereRendererInstance) then begin
   AtmosphereRendererInstance.DrawClouds(aInFlightFrameIndex,aCommandBuffer,aDepthImageView,aCascadedShadowMapImageView);
  end;

 end;

end;

procedure TpvScene3DAtmosphere.Draw(const aInFlightFrameIndex:TpvSizeInt;
                                    const aCommandBuffer:TpvVulkanCommandBuffer;
                                    const aDepthImageView:TVkImageView;
                                    const aCascadedShadowMapImageView:TVkImageView;
                                    const aCloudsInscatteringImageView:TVkImageView;
                                    const aCloudsTransmittanceImageView:TVkImageView;
                                    const aCloudsDepthImageView:TVkImageView;
                                    const aRendererInstance:TObject;
                                    var aPushConstants:TpvScene3DAtmosphereGlobals.TRaymarchingPushConstants);
var AtmosphereRendererInstance:TpvScene3DAtmosphere.TRendererInstance;
begin

 if fInFlightFrameVisible[aInFlightFrameIndex] then begin

  AtmosphereRendererInstance:=GetRenderInstance(aRendererInstance);

  if assigned(AtmosphereRendererInstance) then begin
   AtmosphereRendererInstance.Draw(aInFlightFrameIndex,aCommandBuffer,aDepthImageView,aCascadedShadowMapImageView,aCloudsInscatteringImageView,aCloudsTransmittanceImageView,aCloudsDepthImageView,aPushConstants);
  end;

 end;

end;

{ TpvScene3DAtmospheres }

constructor TpvScene3DAtmospheres.Create(const aScene3D:TObject);
begin
 inherited Create(true);
 fScene3D:=aScene3D;
 fLock:=TPasMPMultipleReaderSingleWriterLock.Create;
end;

destructor TpvScene3DAtmospheres.Destroy;
begin
 FreeAndNil(fLock);
 inherited Destroy;
end;

procedure TpvScene3DAtmospheres.ProcessReleases;
var Index:TpvInt32;
    Atmosphere:TpvScene3DAtmosphere;
begin
 // Going backwards through the list, because we will remove items from the list
 fLock.AcquireRead;
 try
  Index:=Count;
  while Index>0 do begin
   dec(Index);
   Atmosphere:=Items[Index];
   if assigned(Atmosphere) then begin
    fLock.ReleaseRead;
    try
     Atmosphere.HandleRelease;
    finally
     fLock.AcquireRead;
    end;
   end;
  end;
 finally
  fLock.ReleaseRead;
 end; 
end;

procedure TpvScene3DAtmospheres.DrawClouds(const aInFlightFrameIndex:TpvSizeInt;
                                           const aCommandBuffer:TpvVulkanCommandBuffer;
                                           const aDepthImageView:TVkImageView;
                                           const aCascadedShadowMapImageView:TVkImageView;
                                           const aRendererInstance:TObject);
var Index:TpvSizeInt;
    Atmosphere:TpvScene3DAtmosphere;
begin
 fLock.AcquireRead;
 try

  if Count>0 then begin

   for Index:=0 to Count-1 do begin
    Atmosphere:=Items[Index];
    if assigned(Atmosphere) then begin
     Atmosphere.DrawClouds(aInFlightFrameIndex,aCommandBuffer,aDepthImageView,aCascadedShadowMapImageView,aRendererInstance);
    end;
   end;

  end;

 finally
  fLock.ReleaseRead;
 end;
end;

procedure TpvScene3DAtmospheres.Draw(const aInFlightFrameIndex:TpvSizeInt;
                                     const aCommandBuffer:TpvVulkanCommandBuffer;
                                     const aDepthImageView:TVkImageView;
                                     const aCascadedShadowMapImageView:TVkImageView;
                                     const aCloudsInscatteringImageView:TVkImageView;
                                     const aCloudsTransmittanceImageView:TVkImageView;
                                     const aCloudsDepthImageView:TVkImageView;
                                     const aRendererInstance:TObject;
                                     var aPushConstants:TpvScene3DAtmosphereGlobals.TRaymarchingPushConstants);
var Index:TpvSizeInt;
    Atmosphere:TpvScene3DAtmosphere;
begin
 fLock.AcquireRead;
 try

  if Count>0 then begin

   for Index:=0 to Count-1 do begin
    Atmosphere:=Items[Index];
    if assigned(Atmosphere) then begin
     Atmosphere.Draw(aInFlightFrameIndex,aCommandBuffer,aDepthImageView,aCascadedShadowMapImageView,aCloudsInscatteringImageView,aCloudsTransmittanceImageView,aCloudsDepthImageView,aRendererInstance,aPushConstants);
    end;
   end;

  end;

 finally
  fLock.ReleaseRead;
 end;
end;

{ TpvScene3DAtmosphereGlobals }

constructor TpvScene3DAtmosphereGlobals.Create(const aScene3D:TObject);
begin
 inherited Create;
 fScene3D:=aScene3D;
 fAtmospheres:=TpvScene3DAtmospheres(TpvScene3D(fScene3D).Atmospheres);
 fTransmittanceLUTPassDescriptorSetLayout:=nil;
 fMultiScatteringLUTPassDescriptorSetLayout:=nil;
 fSkyLuminanceLUTPassDescriptorSetLayout:=nil;
 fSkyViewLUTPassDescriptorSetLayout:=nil;
 fCameraVolumePassDescriptorSetLayout:=nil;
 fCubeMapPassDescriptorSetLayout:=nil;
 fCloudRaymarchingPassDescriptorSetLayout:=nil;
 fRaymarchingPassDescriptorSetLayout:=nil;
 fGlobalVulkanDescriptorSetLayout:=nil;
 fWeatherMapTextureDescriptorSetLayout:=nil;
 fDirectionalMapTextureInitializationDescriptorSetLayout:=nil;
 fDirectionalMapTextureTransferDescriptorSetLayout:=nil;
 fDirectionalMapTextureScanDescriptorSetLayout:=nil;
end;

destructor TpvScene3DAtmosphereGlobals.Destroy;
begin
 DeallocateResources;
 inherited Destroy;
end;

procedure TpvScene3DAtmosphereGlobals.AllocateResources;
var Stream:TStream;
    Queue:TpvVulkanQueue;
    CommandPool:TpvVulkanCommandPool;
    CommandBuffer:TpvVulkanCommandBuffer;
    Fence:TpvVulkanFence;
    FormatVariant:TpvUTF8String;
begin

 // Transmittance LUT pass descriptor set layout
 begin

  fTransmittanceLUTPassDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(TpvScene3D(fScene3D).VulkanDevice);

  // Destination texture
  fTransmittanceLUTPassDescriptorSetLayout.AddBinding(0,
                                                      VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                      []);

  // Atmosphere parameters
  fTransmittanceLUTPassDescriptorSetLayout.AddBinding(1,
                                                      VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                      []);

  fTransmittanceLUTPassDescriptorSetLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fTransmittanceLUTPassDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DAtmosphereGlobals.fTransmittanceLUTPassDescriptorSetLayout');

 end;

 // Multi scattering LUT pass descriptor set layout
 begin

  fMultiScatteringLUTPassDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(TpvScene3D(fScene3D).VulkanDevice);

  // Destination texture
  fMultiScatteringLUTPassDescriptorSetLayout.AddBinding(0,
                                                        VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                                        1,
                                                        TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                        []);

  // Transmittance LUT texture (previous)
  fMultiScatteringLUTPassDescriptorSetLayout.AddBinding(1,
                                                        VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                        1,
                                                        TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                        []);

  // Atmosphere parameters
  fMultiScatteringLUTPassDescriptorSetLayout.AddBinding(2,
                                                        VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                        1,
                                                        TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                        []);

  // Blue noise texture
  fMultiScatteringLUTPassDescriptorSetLayout.AddBinding(3,
                                                        VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                        1,
                                                        TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                        []);

  fMultiScatteringLUTPassDescriptorSetLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fMultiScatteringLUTPassDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DAtmosphereGlobals.fMultiScatteringLUTPassDescriptorSetLayout');

 end;

 // Sky luminance LUT pass descriptor set layout
 begin

  fSkyLuminanceLUTPassDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(TpvScene3D(fScene3D).VulkanDevice);

  // Destination texture
  fSkyLuminanceLUTPassDescriptorSetLayout.AddBinding(0,
                                                     VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                                     1,
                                                     TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                     []);

  // Transmittance LUT texture
  fSkyLuminanceLUTPassDescriptorSetLayout.AddBinding(1,
                                                     VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                     1,
                                                     TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                     []);

  // Multi scattering LUT texture
  fSkyLuminanceLUTPassDescriptorSetLayout.AddBinding(2,
                                                     VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                     1,
                                                     TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                     []);

  // Atmosphere parameters
  fSkyLuminanceLUTPassDescriptorSetLayout.AddBinding(3,
                                                     VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                     1,
                                                     TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                     []);

  // Blue noise texture
  fSkyLuminanceLUTPassDescriptorSetLayout.AddBinding(4,
                                                     VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                     1,
                                                     TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                     []);

  fSkyLuminanceLUTPassDescriptorSetLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyLuminanceLUTPassDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DAtmosphereGlobals.fSkyLuminanceLUTPassDescriptorSetLayout');

 end;

 // Sky view LUT pass descriptor set layout
 begin

  fSkyViewLUTPassDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(TpvScene3D(fScene3D).VulkanDevice);

  // Destination texture
  fSkyViewLUTPassDescriptorSetLayout.AddBinding(0,
                                                VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                                1,
                                                TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                []);

  // Transmittance LUT texture 
  fSkyViewLUTPassDescriptorSetLayout.AddBinding(1,
                                                VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                1,
                                                TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                []);

  // Multi scattering LUT texture
  fSkyViewLUTPassDescriptorSetLayout.AddBinding(2,
                                                VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                1,
                                                TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                []);

  // Atmosphere map texture
  fSkyViewLUTPassDescriptorSetLayout.AddBinding(3,
                                                VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                1,
                                                TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                []);

  // Atmosphere parameters
  fSkyViewLUTPassDescriptorSetLayout.AddBinding(4,
                                                VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                1,
                                                TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                []);

  // Blue noise texture 
  fSkyViewLUTPassDescriptorSetLayout.AddBinding(5,
                                                VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                1,
                                                TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                []);

  fSkyViewLUTPassDescriptorSetLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyViewLUTPassDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DAtmosphereGlobals.fSkyViewLUTPassDescriptorSetLayout');

 end;

 // Camera volume pass descriptor set layout
 begin

  fCameraVolumePassDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(TpvScene3D(fScene3D).VulkanDevice);

  // Destination texture
  fCameraVolumePassDescriptorSetLayout.AddBinding(0,
                                                  VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                                  1,
                                                  TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                  []);

  // Transmittance LUT texture (previous)
  fCameraVolumePassDescriptorSetLayout.AddBinding(1,
                                                  VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                  1,
                                                  TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                  []);

  // Multi scattering LUT texture (previous)
  fCameraVolumePassDescriptorSetLayout.AddBinding(2,
                                                  VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                  1,
                                                  TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                  []);

  // Atmosphere map texture
  fCameraVolumePassDescriptorSetLayout.AddBinding(3,
                                                  VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                  1,
                                                  TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                  []);

  // Atmosphere parameters
  fCameraVolumePassDescriptorSetLayout.AddBinding(4,
                                                  VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                  1,
                                                  TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                  []);

  // Blue noise texture 
  fCameraVolumePassDescriptorSetLayout.AddBinding(5,
                                                  VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                  1,
                                                  TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                  []);

  fCameraVolumePassDescriptorSetLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCameraVolumePassDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DAtmosphereGlobals.fCameraVolumePassDescriptorSetLayout');

 end;

 // Cube map pass descriptor set layout
 begin

  fCubeMapPassDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(TpvScene3D(fScene3D).VulkanDevice);

  // Destination texture
  fCubeMapPassDescriptorSetLayout.AddBinding(0,
                                             VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                             []);

  // Transmittance LUT texture
  fCubeMapPassDescriptorSetLayout.AddBinding(1,
                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                             []);

  // Multi scattering LUT texture
  fCubeMapPassDescriptorSetLayout.AddBinding(2,
                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                             []);

  // Sky luminance LUT texture
  fCubeMapPassDescriptorSetLayout.AddBinding(3,
                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                             []);

  // Atmosphere map texture
  fCubeMapPassDescriptorSetLayout.AddBinding(4,
                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                             []);

  // Precipitation map texture
  fCubeMapPassDescriptorSetLayout.AddBinding(5,
                                             VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                             []);

  // Atmosphere parameters
  fCubeMapPassDescriptorSetLayout.AddBinding(6,
                                             VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                             1,
                                             TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                             []);

  fCubeMapPassDescriptorSetLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCubeMapPassDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DAtmosphereGlobals.fCubeMapPassDescriptorSetLayout');

 end;

 // Cloud raymarching pass descriptor set layout
 begin

  fCloudRaymarchingPassDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(TpvScene3D(fScene3D).VulkanDevice);

  // Depth texture
  fCloudRaymarchingPassDescriptorSetLayout.AddBinding(0,
                                                      VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                      []);

  // Atmosphere parameters
  fCloudRaymarchingPassDescriptorSetLayout.AddBinding(1,
                                                      //VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                      VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                      []);

  // Blue noise texture
  fCloudRaymarchingPassDescriptorSetLayout.AddBinding(2,
                                                      VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                      []);

  // Sky luminance LUT texture
  fCloudRaymarchingPassDescriptorSetLayout.AddBinding(3,
                                                      VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                      []);

  // Transmittance LUT texture
  fCloudRaymarchingPassDescriptorSetLayout.AddBinding(4,
                                                      VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                      []);  

  // Shape noise texture
  fCloudRaymarchingPassDescriptorSetLayout.AddBinding(5,
                                                      VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                      []);

  // Detail noise texture
  fCloudRaymarchingPassDescriptorSetLayout.AddBinding(6,
                                                      VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                      []);

  // Curl noise texture
  fCloudRaymarchingPassDescriptorSetLayout.AddBinding(7,
                                                      VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                      []);

  // Sky luminance LUT texture
  fCloudRaymarchingPassDescriptorSetLayout.AddBinding(8,
                                                      VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                      []);

  // Weather map texture
  fCloudRaymarchingPassDescriptorSetLayout.AddBinding(9,
                                                      VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                      []);

  // Precipitation map texture
  fCloudRaymarchingPassDescriptorSetLayout.AddBinding(10,
                                                      VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                      []);

  // Atmosphere map texture
  fCloudRaymarchingPassDescriptorSetLayout.AddBinding(11,
                                                      VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                      []);

  // Atmosphere map min max buffer
  fCloudRaymarchingPassDescriptorSetLayout.AddBinding(12,
                                                      VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                      1,
                                                      TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                      []);

  fCloudRaymarchingPassDescriptorSetLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCloudRaymarchingPassDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DAtmosphereGlobals.fCloudRaymarchingPassDescriptorSetLayout');

 end;

 // Raymarching pass descriptor set layout
 begin
  
  fRaymarchingPassDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(TpvScene3D(fScene3D).VulkanDevice);

  // Subpass depth
  fRaymarchingPassDescriptorSetLayout.AddBinding(0,
                                                 VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);

  // Transmittance LUT texture
  fRaymarchingPassDescriptorSetLayout.AddBinding(1,
                                                 VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);

  // Multi scattering LUT texture
  fRaymarchingPassDescriptorSetLayout.AddBinding(2,
                                                 VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);

  // Sky view LUT texture
  fRaymarchingPassDescriptorSetLayout.AddBinding(3,
                                                 VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);
  // Atmosphere map texture
  fRaymarchingPassDescriptorSetLayout.AddBinding(4,
                                                 VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);

  // Camera volume texture
  fRaymarchingPassDescriptorSetLayout.AddBinding(5,
                                                 VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);

  // Blue noise texture
  fRaymarchingPassDescriptorSetLayout.AddBinding(6,
                                                 VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);

  // Atmosphere map min max buffer
  fRaymarchingPassDescriptorSetLayout.AddBinding(7,
                                                 VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);

  // Atmosphere parameters
  fRaymarchingPassDescriptorSetLayout.AddBinding(8,
                                                 VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);

  // Cascaded shadow map UBO
  fRaymarchingPassDescriptorSetLayout.AddBinding(9,
                                                 VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);

  // Cascaded shadow map textures
  fRaymarchingPassDescriptorSetLayout.AddBinding(10,
                                                 VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);

  // Clouds inscattering texture
  fRaymarchingPassDescriptorSetLayout.AddBinding(11,
                                                 VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []); 

  // Clouds transmittance texture
  fRaymarchingPassDescriptorSetLayout.AddBinding(12,
                                                 VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);

  // Clouds depth texture
  fRaymarchingPassDescriptorSetLayout.AddBinding(13,
                                                 VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,
                                                 1,
                                                 TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                                 []);

  fRaymarchingPassDescriptorSetLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fRaymarchingPassDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DAtmosphereGlobals.fRaymarchingPassDescriptorSetLayout');

 end; 

 // Global Vulkan descriptor set layout
 begin

  fGlobalVulkanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(TpvScene3D(fScene3D).VulkanDevice);

  // Views
  fGlobalVulkanDescriptorSetLayout.AddBinding(0,
                                              VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                              1,
                                              TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT) or
                                              TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),
                                              []);

  fGlobalVulkanDescriptorSetLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fGlobalVulkanDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DAtmosphereGlobals.fGlobalVulkanDescriptorSetLayout');

 end;

 begin

  // Weather map texture descriptor set layout
  
  fWeatherMapTextureDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(TpvScene3D(fScene3D).VulkanDevice);

  // Weather map texture
  fWeatherMapTextureDescriptorSetLayout.AddBinding(0,
                                                   VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                                   1,
                                                   TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                   []);

  fWeatherMapTextureDescriptorSetLayout.Initialize;

  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fWeatherMapTextureDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DAtmosphereGlobals.fWeatherMapTextureDescriptorSetLayout');

 end;

 begin
  
  // Directional map texture initialization descriptor set layout

  fDirectionalMapTextureInitializationDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(TpvScene3D(fScene3D).VulkanDevice);

  // Directional map texture
  fDirectionalMapTextureInitializationDescriptorSetLayout.AddBinding(0,
                                                                     VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                                                     1,
                                                                     TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                                     []);

  fDirectionalMapTextureInitializationDescriptorSetLayout.Initialize;

  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fDirectionalMapTextureInitializationDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DAtmosphereGlobals.fDirectionalMapTextureInitializationDescriptorSetLayout');

 end; 

 begin

  // Directional map texture transfer descriptor set layout

  fDirectionalMapTextureTransferDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(TpvScene3D(fScene3D).VulkanDevice);

  // Directional map texture
  fDirectionalMapTextureTransferDescriptorSetLayout.AddBinding(0,
                                                               VK_DESCRIPTOR_TYPE_STORAGE_IMAGE,
                                                               1,
                                                               TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                               []);

  // Source texture
  fDirectionalMapTextureTransferDescriptorSetLayout.AddBinding(1,
                                                               VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                               1,
                                                               TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                               []);                                                             

  fDirectionalMapTextureTransferDescriptorSetLayout.Initialize;

  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fDirectionalMapTextureTransferDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DAtmosphereGlobals.fDirectionalMapTextureTransferDescriptorSetLayout');

 end;

 begin
   
  // Directional map texture scan descriptor set layout

  fDirectionalMapTextureScanDescriptorSetLayout:=TpvVulkanDescriptorSetLayout.Create(TpvScene3D(fScene3D).VulkanDevice);

  // Directional map texture
  fDirectionalMapTextureScanDescriptorSetLayout.AddBinding(0,
                                                           VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,
                                                           1,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);

  // Min/max buffer
  fDirectionalMapTextureScanDescriptorSetLayout.AddBinding(1,
                                                           VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                                           1,
                                                           TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),
                                                           []);      

  fDirectionalMapTextureScanDescriptorSetLayout.Initialize;

  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fDirectionalMapTextureScanDescriptorSetLayout.Handle,VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT,'TpvScene3DAtmosphereGlobals.fDirectionalMapTextureScanDescriptorSetLayout');  

 end;

 begin

  // Transmittance LUT compute pipeline

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('atmosphere_transmittancelut_comp.spv');
  try
   fTransmittanceLUTComputeShaderModule:=TpvVulkanShaderModule.Create(TpvScene3D(fScene3D).VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fTransmittanceLUTComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DAtmosphereGlobals.fTransmittanceLUTComputeShaderModule');

  fTransmittanceLUTComputeShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fTransmittanceLUTComputeShaderModule,'main');

  fTransmittanceLUTComputePipelineLayout:=TpvVulkanPipelineLayout.Create(TpvScene3D(fScene3D).VulkanDevice);
  fTransmittanceLUTComputePipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TTransmittanceLUTPushConstants));
  fTransmittanceLUTComputePipelineLayout.AddDescriptorSetLayout(TpvScene3D(fScene3D).GlobalVulkanDescriptorSetLayout);
  fTransmittanceLUTComputePipelineLayout.AddDescriptorSetLayout(fGlobalVulkanDescriptorSetLayout);
  fTransmittanceLUTComputePipelineLayout.AddDescriptorSetLayout(fTransmittanceLUTPassDescriptorSetLayout);
  fTransmittanceLUTComputePipelineLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fTransmittanceLUTComputePipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DAtmosphereGlobals.fTransmittanceLUTComputePipelineLayout');

  fTransmittanceLUTComputePipeline:=TpvVulkanComputePipeline.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                                    TpvScene3D(fScene3D).VulkanPipelineCache,
                                                                    0,
                                                                    fTransmittanceLUTComputeShaderStage,
                                                                    fTransmittanceLUTComputePipelineLayout,
                                                                    nil,
                                                                    0);
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fTransmittanceLUTComputePipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DAtmosphereGlobals.fTransmittanceLUTComputePipeline'); 
 
 end;

 begin

  // Multi scattering LUT compute pipeline

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('atmosphere_multiscattering_comp.spv');
  try
   fMultiScatteringLUTComputeShaderModule:=TpvVulkanShaderModule.Create(TpvScene3D(fScene3D).VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fMultiScatteringLUTComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DAtmosphereGlobals.fMultiScatteringLUTComputeShaderModule');

  fMultiScatteringLUTComputeShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fMultiScatteringLUTComputeShaderModule,'main');

  fMultiScatteringLUTComputePipelineLayout:=TpvVulkanPipelineLayout.Create(TpvScene3D(fScene3D).VulkanDevice);
  fMultiScatteringLUTComputePipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TMultiScatteringLUTPushConstants));
  fMultiScatteringLUTComputePipelineLayout.AddDescriptorSetLayout(TpvScene3D(fScene3D).GlobalVulkanDescriptorSetLayout);
  fMultiScatteringLUTComputePipelineLayout.AddDescriptorSetLayout(fGlobalVulkanDescriptorSetLayout);
  fMultiScatteringLUTComputePipelineLayout.AddDescriptorSetLayout(fMultiScatteringLUTPassDescriptorSetLayout);
  fMultiScatteringLUTComputePipelineLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fMultiScatteringLUTComputePipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DAtmosphereGlobals.fMultiScatteringLUTComputePipelineLayout');

  fMultiScatteringLUTComputePipeline:=TpvVulkanComputePipeline.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                                      TpvScene3D(fScene3D).VulkanPipelineCache,
                                                                      0,
                                                                      fMultiScatteringLUTComputeShaderStage,
                                                                      fMultiScatteringLUTComputePipelineLayout,
                                                                      nil,  
                                                                      0);
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fMultiScatteringLUTComputePipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DAtmosphereGlobals.fMultiScatteringLUTComputePipeline');

 end;

 begin
   
  // Sky luminance LUT compute pipeline

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('atmosphere_skyluminancelut_comp.spv');
  try
   fSkyLuminanceLUTComputeShaderModule:=TpvVulkanShaderModule.Create(TpvScene3D(fScene3D).VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
  
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyLuminanceLUTComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DAtmosphereGlobals.fSkyLuminanceLUTComputeShaderModule');

  fSkyLuminanceLUTComputeShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fSkyLuminanceLUTComputeShaderModule,'main');

  fSkyLuminanceLUTComputePipelineLayout:=TpvVulkanPipelineLayout.Create(TpvScene3D(fScene3D).VulkanDevice);
  fSkyLuminanceLUTComputePipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TSkyLuminanceLUTPushConstants));
  fSkyLuminanceLUTComputePipelineLayout.AddDescriptorSetLayout(TpvScene3D(fScene3D).GlobalVulkanDescriptorSetLayout);
  fSkyLuminanceLUTComputePipelineLayout.AddDescriptorSetLayout(fGlobalVulkanDescriptorSetLayout);
  fSkyLuminanceLUTComputePipelineLayout.AddDescriptorSetLayout(fSkyLuminanceLUTPassDescriptorSetLayout);
  fSkyLuminanceLUTComputePipelineLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyLuminanceLUTComputePipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DAtmosphereGlobals.fSkyLuminanceLUTComputePipelineLayout');

  fSkyLuminanceLUTComputePipeline:=TpvVulkanComputePipeline.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                                   TpvScene3D(fScene3D).VulkanPipelineCache,
                                                                   0,
                                                                   fSkyLuminanceLUTComputeShaderStage,
                                                                   fSkyLuminanceLUTComputePipelineLayout,
                                                                   nil,
                                                                   0);
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyLuminanceLUTComputePipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DAtmosphereGlobals.fSkyLuminanceLUTComputePipeline');

 end;

 begin

  // Sky view LUT compute pipeline

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('atmosphere_skyviewlut_comp.spv');
  try
   fSkyViewLUTComputeShaderModule:=TpvVulkanShaderModule.Create(TpvScene3D(fScene3D).VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyViewLUTComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DAtmosphereGlobals.fSkyViewLUTComputeShaderModule');

  fSkyViewLUTComputeShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fSkyViewLUTComputeShaderModule,'main');

  fSkyViewLUTComputePipelineLayout:=TpvVulkanPipelineLayout.Create(TpvScene3D(fScene3D).VulkanDevice);
  fSkyViewLUTComputePipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TSkyViewLUTPushConstants));
  fSkyViewLUTComputePipelineLayout.AddDescriptorSetLayout(TpvScene3D(fScene3D).GlobalVulkanDescriptorSetLayout);
  fSkyViewLUTComputePipelineLayout.AddDescriptorSetLayout(fGlobalVulkanDescriptorSetLayout);
  fSkyViewLUTComputePipelineLayout.AddDescriptorSetLayout(fSkyViewLUTPassDescriptorSetLayout);
  fSkyViewLUTComputePipelineLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyViewLUTComputePipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DAtmosphereGlobals.fSkyViewLUTComputePipelineLayout');

  fSkyViewLUTComputePipeline:=TpvVulkanComputePipeline.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                              TpvScene3D(fScene3D).VulkanPipelineCache,
                                                              0,
                                                              fSkyViewLUTComputeShaderStage,
                                                              fSkyViewLUTComputePipelineLayout,
                                                              nil,
                                                              0);
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fSkyViewLUTComputePipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DAtmosphereGlobals.fSkyViewLUTComputePipeline');                                                            

 end;

 begin

  // Camera volume compute pipeline

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('atmosphere_cameravolume_comp.spv');
  try
   fCameraVolumeComputeShaderModule:=TpvVulkanShaderModule.Create(TpvScene3D(fScene3D).VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCameraVolumeComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DAtmosphereGlobals.fCameraVolumeComputeShaderModule');

  fCameraVolumeComputeShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fCameraVolumeComputeShaderModule,'main');
  
  fCameraVolumeComputePipelineLayout:=TpvVulkanPipelineLayout.Create(TpvScene3D(fScene3D).VulkanDevice);
  fCameraVolumeComputePipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TCameraVolumePushConstants));
  fCameraVolumeComputePipelineLayout.AddDescriptorSetLayout(TpvScene3D(fScene3D).GlobalVulkanDescriptorSetLayout);
  fCameraVolumeComputePipelineLayout.AddDescriptorSetLayout(fGlobalVulkanDescriptorSetLayout);
  fCameraVolumeComputePipelineLayout.AddDescriptorSetLayout(fCameraVolumePassDescriptorSetLayout);
  fCameraVolumeComputePipelineLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCameraVolumeComputePipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DAtmosphereGlobals.fCameraVolumeComputePipelineLayout');

  fCameraVolumeComputePipeline:=TpvVulkanComputePipeline.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                                TpvScene3D(fScene3D).VulkanPipelineCache,
                                                                0,
                                                                fCameraVolumeComputeShaderStage,
                                                                fCameraVolumeComputePipelineLayout,
                                                                nil,
                                                                0);
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCameraVolumeComputePipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DAtmosphereGlobals.fCameraVolumeComputePipeline');

 end;

 begin

  // Cube map compute pipeline

{ case aImageFormat of
   VK_FORMAT_B10G11R11_UFLOAT_PACK32:begin
    FormatVariant:='r11g11b10f';
   end;
   VK_FORMAT_R16G16B16A16_SFLOAT:begin
    FormatVariant:='rgba16f';
   end;
   VK_FORMAT_R32G32B32A32_SFLOAT:begin
    FormatVariant:='rgba32f';
   end;
   VK_FORMAT_E5B9G9R9_UFLOAT_PACK32:begin
    FormatVariant:='rgb9e5';
   end;
   VK_FORMAT_R8G8B8A8_UNORM,
   VK_FORMAT_B8G8R8A8_UNORM:begin
    FormatVariant:='rgba8';
   end;
   else begin
    Assert(false); // Unsupported format
    FormatVariant:='';
   end;
  end;}

  //VK_FORMAT_R16G16B16A16_SFLOAT
  FormatVariant:='rgba16f';

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('atmosphere_cubemap_'+FormatVariant+'_comp.spv');
  try
   fCubeMapComputeShaderModule:=TpvVulkanShaderModule.Create(TpvScene3D(fScene3D).VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCubeMapComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DAtmosphereGlobals.fCubeMapComputeShaderModule'); 

  fCubeMapComputeShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fCubeMapComputeShaderModule,'main');

  fCubeMapComputePipelineLayout:=TpvVulkanPipelineLayout.Create(TpvScene3D(fScene3D).VulkanDevice);
  fCubeMapComputePipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TCubeMapPushConstants));
  fCubeMapComputePipelineLayout.AddDescriptorSetLayout(TpvScene3D(fScene3D).GlobalVulkanDescriptorSetLayout);
  fCubeMapComputePipelineLayout.AddDescriptorSetLayout(fGlobalVulkanDescriptorSetLayout);
  fCubeMapComputePipelineLayout.AddDescriptorSetLayout(fCubeMapPassDescriptorSetLayout);
  fCubeMapComputePipelineLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCubeMapComputePipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DAtmosphereGlobals.fCubeMapComputePipelineLayout');

  fCubeMapComputePipeline:=TpvVulkanComputePipeline.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                           TpvScene3D(fScene3D).VulkanPipelineCache,
                                                           0,
                                                           fCubeMapComputeShaderStage,
                                                           fCubeMapComputePipelineLayout,
                                                           nil,                                                           
                                                           0);
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCubeMapComputePipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DAtmosphereGlobals.fCubeMapComputePipeline');                                                         

 end;

 begin

  // Cloud raymarching compute pipeline

  fCloudRaymarchingPipelineLayout:=TpvVulkanPipelineLayout.Create(TpvScene3D(fScene3D).VulkanDevice);
  fCloudRaymarchingPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),0,SizeOf(TCloudRaymarchingPushConstants));
  fCloudRaymarchingPipelineLayout.AddDescriptorSetLayout(TpvScene3D(fScene3D).GlobalVulkanDescriptorSetLayout);
  fCloudRaymarchingPipelineLayout.AddDescriptorSetLayout(fGlobalVulkanDescriptorSetLayout);
  fCloudRaymarchingPipelineLayout.AddDescriptorSetLayout(fCloudRaymarchingPassDescriptorSetLayout);
  fCloudRaymarchingPipelineLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCloudRaymarchingPipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DAtmosphereGlobals.fCloudRaymarchingPipelineLayout');

 end;

 begin
   
  // Raymarching graphics pipeline

  fRaymarchingPipelineLayout:=TpvVulkanPipelineLayout.Create(TpvScene3D(fScene3D).VulkanDevice);
  fRaymarchingPipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT),0,SizeOf(TRaymarchingPushConstants));
  fRaymarchingPipelineLayout.AddDescriptorSetLayout(TpvScene3D(fScene3D).GlobalVulkanDescriptorSetLayout);
  fRaymarchingPipelineLayout.AddDescriptorSetLayout(fGlobalVulkanDescriptorSetLayout);
  fRaymarchingPipelineLayout.AddDescriptorSetLayout(fRaymarchingPassDescriptorSetLayout);
  fRaymarchingPipelineLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fRaymarchingPipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DAtmosphereGlobals.fRaymarchingPipelineLayout');

 end;

 begin

  // Cloud weather map compute pipeline
 
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('atmosphere_clouds_weathermap_comp.spv');
  try
   fCloudWeatherMapComputeShaderModule:=TpvVulkanShaderModule.Create(TpvScene3D(fScene3D).VulkanDevice,Stream);
  finally
   Stream.Free;
  end;

  fCloudWeatherMapComputeShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fCloudWeatherMapComputeShaderModule,'main');
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCloudWeatherMapComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DAtmosphereGlobals.fCloudWeatherMapComputeShaderModule');

  fCloudWeatherMapComputePipelineLayout:=TpvVulkanPipelineLayout.Create(TpvScene3D(fScene3D).VulkanDevice);
  fCloudWeatherMapComputePipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TCloudWeatherMapPushConstants));
  fCloudWeatherMapComputePipelineLayout.AddDescriptorSetLayout(fWeatherMapTextureDescriptorSetLayout);
  fCloudWeatherMapComputePipelineLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCloudWeatherMapComputePipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DAtmosphereGlobals.fCloudWeatherMapComputePipelineLayout');

  fCloudWeatherMapComputePipeline:=TpvVulkanComputePipeline.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                                   TpvScene3D(fScene3D).VulkanPipelineCache,
                                                                   0,
                                                                   fCloudWeatherMapComputeShaderStage,
                                                                   fCloudWeatherMapComputePipelineLayout,
                                                                   nil,
                                                                   0);
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fCloudWeatherMapComputePipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DAtmosphereGlobals.fCloudWeatherMapComputePipeline');

 end;

 begin

  // Allocate resources for cloud textures

  fCloudCurlTexture:=TpvScene3DRendererMipmapImage3D.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                            128,
                                                            128,
                                                            128,
                                                            VK_FORMAT_R8G8B8A8_UNORM,
                                                            true,
                                                            VK_SAMPLE_COUNT_1_BIT,
                                                            VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                            VK_SHARING_MODE_EXCLUSIVE,
                                                            [],
                                                            0,
                                                            'TpvScene3DAtmosphereGlobals.fCloudCurlTexture');

  fCloudDetailTexture:=TpvScene3DRendererMipmapImage3D.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                              32,
                                                              32,
                                                              32,
                                                              VK_FORMAT_R8G8B8A8_UNORM,
                                                              true,
                                                              VK_SAMPLE_COUNT_1_BIT,
                                                              VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                              VK_SHARING_MODE_EXCLUSIVE,
                                                              [],
                                                              0,
                                                              'TpvScene3DAtmosphereGlobals.fCloudDetailTexture');

  fCloudShapeTexture:=TpvScene3DRendererMipmapImage3D.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                             64,
                                                             64,
                                                             64,
                                                             VK_FORMAT_R8G8B8A8_UNORM,
                                                             true,
                                                             VK_SAMPLE_COUNT_1_BIT,
                                                             VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                             VK_SHARING_MODE_EXCLUSIVE,
                                                             [],
                                                             0,
                                                             'TpvScene3DAtmosphereGlobals.fCloudShapeTexture');

  Queue:=TpvScene3D(fScene3D).VulkanDevice.UniversalQueue;

  CommandPool:=TpvVulkanCommandPool.Create(TpvScene3D(fScene3D).VulkanDevice,
                                           TpvScene3D(fScene3D).VulkanDevice.UniversalQueueFamilyIndex,
                                           TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
  try                                         

   CommandBuffer:=TpvVulkanCommandBuffer.Create(CommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
   try
  
    Fence:=TpvVulkanFence.Create(TpvScene3D(fScene3D).VulkanDevice);                                                           
    try

     fCloudCurlTexture.Generate(Queue,
                                CommandBuffer,
                                Fence,
                                'atmosphere_clouds_noise_curl_comp.spv',
                                8,
                                8,
                                8);

     fCloudDetailTexture.Generate(Queue,
                                  CommandBuffer,
                                  Fence,
                                  'atmosphere_clouds_noise_detail_comp.spv',
                                  8,
                                  8,
                                  8);

     fCloudShapeTexture.Generate(Queue,
                                 CommandBuffer,
                                 Fence,
                                 'atmosphere_clouds_noise_shape_comp.spv',
                                 8,
                                 8,
                                 8);      

     fCloudCurlTexture.GenerateMipMaps(Queue,
                                       CommandBuffer,
                                       Fence);

     fCloudDetailTexture.GenerateMipMaps(Queue,
                                         CommandBuffer,
                                         Fence);

     fCloudShapeTexture.GenerateMipMaps(Queue,
                                        CommandBuffer,
                                        Fence);  

    finally
     FreeAndNil(Fence);
    end;

   finally
    FreeAndNil(CommandBuffer);
   end;

  finally 
   FreeAndNil(CommandPool);
  end;

 end;

 begin

  // Directional map texture initialization compute pipeline
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cubemap_initialization_r8_comp.spv');
  try
   fDirectionalMapTextureInitializationComputeShaderModule:=TpvVulkanShaderModule.Create(TpvScene3D(fScene3D).VulkanDevice,Stream);
  finally
   Stream.Free;
  end;

  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fDirectionalMapTextureInitializationComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DAtmosphereGlobals.fDirectionalMapTextureInitializationShaderModule');
  
  fDirectionalMapTextureInitializationComputeShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fDirectionalMapTextureInitializationComputeShaderModule,'main');

  fDirectionalMapTextureInitializationComputePipelineLayout:=TpvVulkanPipelineLayout.Create(TpvScene3D(fScene3D).VulkanDevice);
  fDirectionalMapTextureInitializationComputePipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TDirectionalMapTextureInitializationPushConstants));
  fDirectionalMapTextureInitializationComputePipelineLayout.AddDescriptorSetLayout(fDirectionalMapTextureInitializationDescriptorSetLayout);
  fDirectionalMapTextureInitializationComputePipelineLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fDirectionalMapTextureInitializationComputePipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DAtmosphereGlobals.fDirectionalMapTextureInitializationPipelineLayout');

  fDirectionalMapTextureInitializationComputePipeline:=TpvVulkanComputePipeline.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                                                TpvScene3D(fScene3D).VulkanPipelineCache,
                                                                                0,
                                                                                fDirectionalMapTextureInitializationComputeShaderStage,
                                                                                fDirectionalMapTextureInitializationComputePipelineLayout,
                                                                                nil,
                                                                                0);
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fDirectionalMapTextureInitializationComputePipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DAtmosphereGlobals.fDirectionalMapTextureInitializationPipeline');
 
 end;

 begin

  // Directional map texture transfer compute pipeline
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cubemap_octahedralmap_planet_r8_comp.spv');
  try
   fDirectionalMapTextureTransferComputeR8UNormShaderModule:=TpvVulkanShaderModule.Create(TpvScene3D(fScene3D).VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fDirectionalMapTextureTransferComputeR8UNormShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DAtmosphereGlobals.fDirectionalMapTextureTransferR8UNormShaderModule');

  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('cubemap_octahedralmap_planet_r8_snorm_comp.spv');
  try
   fDirectionalMapTextureTransferComputeR8SNormShaderModule:=TpvVulkanShaderModule.Create(TpvScene3D(fScene3D).VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fDirectionalMapTextureTransferComputeR8SNormShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DAtmosphereGlobals.fDirectionalMapTextureTransferR8SNormShaderModule');

  fDirectionalMapTextureTransferComputeR8UNormShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fDirectionalMapTextureTransferComputeR8UNormShaderModule,'main');
  fDirectionalMapTextureTransferComputeR8SNormShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fDirectionalMapTextureTransferComputeR8SNormShaderModule,'main');

  fDirectionalMapTextureTransferComputePipelineLayout:=TpvVulkanPipelineLayout.Create(TpvScene3D(fScene3D).VulkanDevice);
  fDirectionalMapTextureTransferComputePipelineLayout.AddDescriptorSetLayout(fDirectionalMapTextureTransferDescriptorSetLayout);
  fDirectionalMapTextureTransferComputePipelineLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fDirectionalMapTextureTransferComputePipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DAtmosphereGlobals.fDirectionalMapTextureTransferPipelineLayout');

  fDirectionalMapTextureTransferComputeR8UNormPipeline:=TpvVulkanComputePipeline.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                                                        TpvScene3D(fScene3D).VulkanPipelineCache,
                                                                                        0,
                                                                                        fDirectionalMapTextureTransferComputeR8UNormShaderStage,
                                                                                        fDirectionalMapTextureTransferComputePipelineLayout,
                                                                                        nil,
                                                                                        0);
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fDirectionalMapTextureTransferComputeR8UNormPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DAtmosphereGlobals.fDirectionalMapTextureTransferR8UNormPipeline');

  fDirectionalMapTextureTransferComputeR8SNormPipeline:=TpvVulkanComputePipeline.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                                                        TpvScene3D(fScene3D).VulkanPipelineCache,
                                                                                        0,
                                                                                        fDirectionalMapTextureTransferComputeR8SNormShaderStage,
                                                                                        fDirectionalMapTextureTransferComputePipelineLayout,
                                                                                        nil,
                                                                                        0);
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fDirectionalMapTextureTransferComputeR8SNormPipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DAtmosphereGlobals.fDirectionalMapTextureTransferR8SNormPipeline');

 end;

 begin
   
  // Directional map texture scan compute pipeline
  Stream:=pvScene3DShaderVirtualFileSystem.GetFile('atmosphere_map_scan_comp.spv');
  try
   fDirectionalMapTextureScanComputeShaderModule:=TpvVulkanShaderModule.Create(TpvScene3D(fScene3D).VulkanDevice,Stream);
  finally
   Stream.Free;
  end;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fDirectionalMapTextureScanComputeShaderModule.Handle,VK_OBJECT_TYPE_SHADER_MODULE,'TpvScene3DAtmosphereGlobals.fDirectionalMapTextureScanShaderModule');

  fDirectionalMapTextureScanComputeShaderStage:=TpvVulkanPipelineShaderStage.Create(VK_SHADER_STAGE_COMPUTE_BIT,fDirectionalMapTextureScanComputeShaderModule,'main');

  fDirectionalMapTextureScanComputePipelineLayout:=TpvVulkanPipelineLayout.Create(TpvScene3D(fScene3D).VulkanDevice);
//fDirectionalMapTextureScanComputePipelineLayout.AddPushConstantRange(TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT),0,SizeOf(TDirectionalMapTextureScanPushConstants));
  fDirectionalMapTextureScanComputePipelineLayout.AddDescriptorSetLayout(fDirectionalMapTextureScanDescriptorSetLayout);
  fDirectionalMapTextureScanComputePipelineLayout.Initialize;
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fDirectionalMapTextureScanComputePipelineLayout.Handle,VK_OBJECT_TYPE_PIPELINE_LAYOUT,'TpvScene3DAtmosphereGlobals.fDirectionalMapTextureScanPipelineLayout');

  fDirectionalMapTextureScanComputePipeline:=TpvVulkanComputePipeline.Create(TpvScene3D(fScene3D).VulkanDevice,
                                                                             TpvScene3D(fScene3D).VulkanPipelineCache,
                                                                             0,
                                                                             fDirectionalMapTextureScanComputeShaderStage,
                                                                             fDirectionalMapTextureScanComputePipelineLayout,
                                                                             nil,
                                                                             0);
  TpvScene3D(fScene3D).VulkanDevice.DebugUtils.SetObjectName(fDirectionalMapTextureScanComputePipeline.Handle,VK_OBJECT_TYPE_PIPELINE,'TpvScene3DAtmosphereGlobals.fDirectionalMapTextureScanPipeline');

 end;

end;

procedure TpvScene3DAtmosphereGlobals.DeallocateResources;
begin

 FreeAndNil(fCloudCurlTexture);
 FreeAndNil(fCloudDetailTexture);
 FreeAndNil(fCloudShapeTexture);
  
 FreeAndNil(fTransmittanceLUTComputePipeline);
 FreeAndNil(fTransmittanceLUTComputePipelineLayout);
 FreeAndNil(fTransmittanceLUTComputeShaderStage);
 FreeAndNil(fTransmittanceLUTComputeShaderModule);
 
 FreeAndNil(fMultiScatteringLUTComputePipeline);
 FreeAndNil(fMultiScatteringLUTComputePipelineLayout);
 FreeAndNil(fMultiScatteringLUTComputeShaderStage);
 FreeAndNil(fMultiScatteringLUTComputeShaderModule);
 
 FreeAndNil(fSkyViewLUTComputePipeline);
 FreeAndNil(fSkyViewLUTComputePipelineLayout);
 FreeAndNil(fSkyViewLUTComputeShaderStage);
 FreeAndNil(fSkyViewLUTComputeShaderModule);

 FreeAndNil(fSkyLuminanceLUTComputePipeline);
 FreeAndNil(fSkyLuminanceLUTComputePipelineLayout);
 FreeAndNil(fSkyLuminanceLUTComputeShaderStage);
 FreeAndNil(fSkyLuminanceLUTComputeShaderModule);
  
 FreeAndNil(fCameraVolumeComputePipeline);
 FreeAndNil(fCameraVolumeComputePipelineLayout);
 FreeAndNil(fCameraVolumeComputeShaderStage);
 FreeAndNil(fCameraVolumeComputeShaderModule);

 FreeAndNil(fCubeMapComputePipeline);
 FreeAndNil(fCubeMapComputePipelineLayout);
 FreeAndNil(fCubeMapComputeShaderStage);
 FreeAndNil(fCubeMapComputeShaderModule);
 
 FreeAndNil(fRaymarchingPipelineLayout);

 FreeAndNil(fCloudRaymarchingPipelineLayout);

 FreeAndNil(fCloudWeatherMapComputePipeline);
 FreeAndNil(fCloudWeatherMapComputePipelineLayout);
 FreeAndNil(fCloudWeatherMapComputeShaderStage);
 FreeAndNil(fCloudWeatherMapComputeShaderModule);

 FreeAndNil(fDirectionalMapTextureInitializationComputePipeline);
 FreeAndNil(fDirectionalMapTextureInitializationComputePipelineLayout);
 FreeAndNil(fDirectionalMapTextureInitializationComputeShaderStage);
 FreeAndNil(fDirectionalMapTextureInitializationComputeShaderModule);

 FreeAndNil(fDirectionalMapTextureTransferComputeR8UNormPipeline);
 FreeAndNil(fDirectionalMapTextureTransferComputeR8SNormPipeline);
 FreeAndNil(fDirectionalMapTextureTransferComputePipelineLayout);
 FreeAndNil(fDirectionalMapTextureTransferComputeR8UNormShaderStage);
 FreeAndNil(fDirectionalMapTextureTransferComputeR8SNormShaderStage);
 FreeAndNil(fDirectionalMapTextureTransferComputeR8UNormShaderModule);
 FreeAndNil(fDirectionalMapTextureTransferComputeR8SNormShaderModule);

 FreeAndNil(fDirectionalMapTextureScanComputePipeline);
 FreeAndNil(fDirectionalMapTextureScanComputePipelineLayout);
 FreeAndNil(fDirectionalMapTextureScanComputeShaderStage);
 FreeAndNil(fDirectionalMapTextureScanComputeShaderModule);

 FreeAndNil(fDirectionalMapTextureScanDescriptorSetLayout);
 FreeAndNil(fDirectionalMapTextureTransferDescriptorSetLayout);
 FreeAndNil(fDirectionalMapTextureInitializationDescriptorSetLayout);
 FreeAndNil(fWeatherMapTextureDescriptorSetLayout);
 FreeAndNil(fGlobalVulkanDescriptorSetLayout);
 FreeAndNil(fRaymarchingPassDescriptorSetLayout);
 FreeAndNil(fCloudRaymarchingPassDescriptorSetLayout);
 FreeAndNil(fCubeMapPassDescriptorSetLayout);
 FreeAndNil(fCameraVolumePassDescriptorSetLayout);
 FreeAndNil(fSkyViewLUTPassDescriptorSetLayout);
 FreeAndNil(fSkyLuminanceLUTPassDescriptorSetLayout);
 FreeAndNil(fMultiScatteringLUTPassDescriptorSetLayout);
 FreeAndNil(fTransmittanceLUTPassDescriptorSetLayout); 

end;

{ TpvScene3DAtmosphereRendererInstance.TTransmittanceLUTPass }

constructor TpvScene3DAtmosphereRendererInstance.TTransmittanceLUTPass.Create(const aAtmosphereRendererInstance:TpvScene3DAtmosphereRendererInstance);
begin

 inherited Create;

 fAtmosphereRendererInstance:=aAtmosphereRendererInstance;
 
 fPipeline:=nil;

end;

destructor TpvScene3DAtmosphereRendererInstance.TTransmittanceLUTPass.Destroy;
begin
 FreeAndNil(fPipeline);
 inherited Destroy;
end;

procedure TpvScene3DAtmosphereRendererInstance.TTransmittanceLUTPass.AfterConstruction;
begin
 inherited AfterConstruction;
end;

procedure TpvScene3DAtmosphereRendererInstance.TTransmittanceLUTPass.BeforeDestruction;
begin
 inherited BeforeDestruction;
end;

procedure TpvScene3DAtmosphereRendererInstance.TTransmittanceLUTPass.Execute(const aVulkanCommandBuffer:TpvVulkanCommandBuffer);
begin  
end;

{ TpvScene3DAtmosphereRendererInstance }

constructor TpvScene3DAtmosphereRendererInstance.Create(const aScene3D,aRenderer,aRendererInstance:TObject);
begin
 inherited Create;
 fScene3D:=aScene3D;
 fRenderer:=aRenderer;
 fRendererInstance:=aRendererInstance;
end;

destructor TpvScene3DAtmosphereRendererInstance.Destroy;
begin
 inherited Destroy;
end;

procedure TpvScene3DAtmosphereRendererInstance.AfterConstruction;
begin
 inherited AfterConstruction;
end;

procedure TpvScene3DAtmosphereRendererInstance.BeforeDestruction;
begin
 inherited BeforeDestruction;
end;

procedure TpvScene3DAtmosphereRendererInstance.AllocateResources;
begin
end;

procedure TpvScene3DAtmosphereRendererInstance.DeallocateResources;
begin
end;

end.
