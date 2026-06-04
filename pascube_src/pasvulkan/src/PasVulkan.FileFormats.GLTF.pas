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
unit PasVulkan.FileFormats.GLTF;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

{$scopedenums on}

interface

uses SysUtils,Classes,Math,PasJSON,PasVulkan.Types,PasVulkan.Math,PasVulkan.Collections,
     PasGLTF;

// IMPORTANT:
// 
// This is a very simple and minimalistic GLTF loader for converting and prebaking purposes to custom formats and 
// thus also not with all features.
//
// For a full GLTF loader, see the stuff in PasVulkan.Scene3D.pas here in the PasVulkan project.
//

type EpvGLTF=class(Exception);

     TpvGLTF=class
      public
       type TGetURI=function(const aURI:TPasGLTFUTF8String):TStream of object;
            TVector3Sum=record
             x,y,z,FactorSum:TPasGLTFDouble;
            end;
            PVector3Sum=^TVector3Sum;
            TVector4Sum=record
             x,y,z,w,FactorSum:TPasGLTFDouble;
            end;
            PVector4Sum=^TVector4Sum;
            TBoundingBox=record
             case boolean of
              false:(
               Min:TPasGLTF.TVector3;
               Max:TPasGLTF.TVector3;
              );
              true:(
               MinMax:array[0..1] of TPasGLTF.TVector3;
              );
            end;
            PBoundingBox=^TBoundingBox;
            TScene=record
             Name:TPasGLTFUTF8String;
             Nodes:TPasGLTFSizeUIntDynamicArray;
            end;
            PScene=^TScene;
            TScenes=array of TScene;
            TVertex=packed record
             Position:TPasGLTF.TVector3;
             VertexIndex:TPasGLTFUInt32;
             Normal:TPasGLTF.TVector3;
             Tangent:TPasGLTF.TVector4;
             TexCoord0:TPasGLTF.TVector2;
             TexCoord1:TPasGLTF.TVector2;
             Color0:TPasGLTF.TVector4;
             Joints0:TPasGLTF.TUInt32Vector4;
             Joints1:TPasGLTF.TUInt32Vector4;
             Weights0:TPasGLTF.TVector4;
             Weights1:TPasGLTF.TVector4;
            end;
            PVertex=^TVertex;
            TVertices=array of TVertex;
            { TBakedMesh }
            TBakedMesh=class
             public
              type { TTriangle }
                   TTriangle=record
                    public
                     type TTriangleFlag=
                           (
                            DoubleSided,
                            Opaque,
                            Transparent,
                            Static,
                            Animated
                           );
                          PTriangleFlag=^TTriangleFlag;
                          TTriangleFlags=set of TTriangleFlag;
                          PTriangleFlags=^TTriangleFlags;
                    public
                     Positions:array[0..2] of TpvVector3;
                     Normals:array[0..2] of TpvVector3;
                     Normal:TpvVector3;
                     Flags:TTriangleFlags;
                     MetaFlags:UInt32;
                    public
                     class function Create:TpvGLTF.TBakedMesh.TTriangle; static;
                     procedure Assign(const aFrom:TpvGLTF.TBakedMesh.TTriangle);
                     function RayIntersection(const aRayOrigin,aRayDirection:TpvVector3;var aTime,aU,aV:TpvScalar):boolean;
                   end;
                   PTriangle=^TTriangle;
                   TTriangles=class(TpvDynamicArrayList<TpvGLTF.TBakedMesh.TTriangle>)
                   end;
             private
              fTriangles:TpvGLTF.TBakedMesh.TTriangles;
             public
              constructor Create; reintroduce;
              destructor Destroy; override;
              procedure Combine(const aWith:TBakedMesh);
             published
              property Triangles:TTriangles read fTriangles;
            end;
            { TBakedVertexIndexedMesh }
            TBakedVertexIndexedMesh=class
             public
              type TVertices=TpvDynamicArrayList<TpvGLTF.TVertex>;
                   TIndex=TpvUInt32;
                   PIndex=^TIndex;
                   TIndices=TpvDynamicArrayList<TpvGLTF.TBakedVertexIndexedMesh.TIndex>;
                   TVertexRemapHashMap=TpvHashMap<TpvUInt64,TpvSizeInt>;
             private
              fVertices:TVertices;
              fIndices:TIndices;
              fMaterials:TIndices;
              fVertexRemapHashMap:TVertexRemapHashMap;
             public
              constructor Create; reintroduce;
              destructor Destroy; override;
              procedure Clear;
              function ExistOriginalVertexIndex(const aVertexIndex,aMaterial:TpvUInt32):boolean;
              function AddOriginalVertexIndex(const aVertexIndex:TpvUInt32;const aVertex:TpvGLTF.TVertex;const aMaterial:TpvUInt32=0;const aAddIndex:boolean=true):TpvUInt32;
              procedure Finish;
             published
              property Vertices:TVertices read fVertices;
              property Indices:TIndices read fIndices;
              property Materials:TIndices read fMaterials;
              property VertexRemapHashMap:TVertexRemapHashMap read fVertexRemapHashMap;              
            end;
            { TInstance }
            TInstance=class
             public
              type { TAnimation }
                   TAnimation=class
                    private
                     fFactor:TPasGLTFFloat;
                     fTime:TPasGLTFFloat;
                    public
                     constructor Create; reintroduce;
                     destructor Destroy; override;
                    published
                     property Factor:TPasGLTFFloat read fFactor write fFactor;
                     property Time:TPasGLTFFloat read fTime write fTime;
                   end;
                   TAnimations=array of TAnimation;
                   TNode=record
                    public
                     type TOverwriteFlag=
                           (
                            Defaults,
                            Translation,
                            Rotation,
                            Scale,
                            Weights
                           );
                          TOverwriteFlags=set of TOverwriteFlag;
                          TOverwrite=record
                           public
                            Flags:TOverwriteFlags;
                            Translation:TPasGLTF.TVector3;
                            Rotation:TPasGLTF.TVector4;
                            Scale:TPasGLTF.TVector3;
                            Weights:TPasGLTFFloatDynamicArray;
                            Factor:TPasGLTFFloat;
                          end;
                          POverwrite=^TOverwrite;
                          TOverwrites=array of TOverwrite;
                    public
                     Overwrites:TOverwrites;
                     CountOverwrites:TPasGLTFSizeInt;
                     OverwriteFlags:TOverwriteFlags;
                     OverwriteTranslation:TPasGLTF.TVector3;
                     OverwriteRotation:TPasGLTF.TVector4;
                     OverwriteScale:TPasGLTF.TVector3;
                     OverwriteWeights:TPasGLTFFloatDynamicArray;
                     OverwriteWeightsSum:TPasGLTFDoubleDynamicArray;
                     WorkWeights:TPasGLTFFloatDynamicArray;
                     WorkMatrix:TPasGLTF.TMatrix4x4;
                   end;
                   PNode=^TNode;
                   TNodes=array of TNode;
                   TSkin=record
                    Used:boolean;
                   end;
                   PSkin=^TSkin;
                   TSkins=array of TSkin;
                   TNodeIndices=array of TPasGLTFSizeInt;
                   TOnNodeMatrix=procedure(const aInstance:TInstance;aNode,InstanceNode:pointer;var Matrix:TPasGLTF.TMatrix4x4) of object;
             private
              fParent:TpvGLTF;
              fScene:TPasGLTFSizeInt;
              fAnimations:TAnimations;
              fAnimation:TPasGLTFSizeInt;
              fAnimationTime:TPasGLTFFloat;
              fNodes:TNodes;
              fSkins:TSkins;
              fLightNodes:TNodeIndices;
              fLightShadowMapMatrices:TPasGLTF.TMatrix4x4DynamicArray;
              fLightShadowMapZFarValues:TPasGLTFFloatDynamicArray;
              fDynamicBoundingBox:TBoundingBox;
              fWorstCaseStaticBoundingBox:TBoundingBox;
              fUserData:pointer;
              fOnNodeMatrixPre:TOnNodeMatrix;
              fOnNodeMatrixPost:TOnNodeMatrix;
              function GetAutomation(const aIndex:TPasGLTFSizeInt):TAnimation;
              procedure SetAnimation(const aAnimation:TPasGLTFSizeInt);
              procedure SetScene(const aScene:TPasGLTFSizeInt);
              function GetScene:TpvGLTF.PScene;
             public
              constructor Create(const aParent:TpvGLTF); reintroduce;
              destructor Destroy; override;
              procedure Update;
              procedure UpdateDynamicBoundingBox(const aHighQuality:boolean=false);
              procedure UpdateWorstCaseStaticBoundingBox;
              procedure Upload;
              function GetCamera(const aNodeIndex:TPasGLTFSizeInt;
                                 out aViewMatrix:TPasGLTF.TMatrix4x4;
                                 out aProjectionMatrix:TPasGLTF.TMatrix4x4;
                                 const aReversedZWithInfiniteFarPlane:boolean=false):boolean;
              function GetBakedMesh(const aRelative:boolean=false;
                                    const aWithDynamicMeshs:boolean=false;
                                    const aRootNodeIndex:TpvSizeInt=-1;
                                    const aMaterialAlphaModes:TPasGLTF.TMaterial.TAlphaModes=[TPasGLTF.TMaterial.TAlphaMode.Opaque,TPasGLTF.TMaterial.TAlphaMode.Blend,TPasGLTF.TMaterial.TAlphaMode.Mask]):TpvGLTF.TBakedMesh;
              function GetBakedVertexIndexedMesh(const aRelative:boolean=false;
                                                 const aWithDynamicMeshs:boolean=false;
                                                 const aRootNodeIndex:TpvSizeInt=-1;
                                                 const aMaterialAlphaModes:TPasGLTF.TMaterial.TAlphaModes=[TPasGLTF.TMaterial.TAlphaMode.Opaque,TPasGLTF.TMaterial.TAlphaMode.Blend,TPasGLTF.TMaterial.TAlphaMode.Mask]):TpvGLTF.TBakedVertexIndexedMesh;
              function GetJointPoints:TPasGLTF.TVector3DynamicArray;
              function GetJointMatrices:TPasGLTF.TMatrix4x4DynamicArray;
              property Scene:TPasGLTFSizeInt read fScene write SetScene;
              property Animation:TPasGLTFSizeInt read fAnimation write SetAnimation;
              property AnimationTime:TPasGLTFFloat read fAnimationTime write fAnimationTime;
              property Nodes:TNodes read fNodes;
              property Skins:TSkins read fSkins;
              property DynamicBoundingBox:TBoundingBox read fDynamicBoundingBox;
              property WorstCaseStaticBoundingBox:TBoundingBox read fWorstCaseStaticBoundingBox;
              property UserData:pointer read fUserData write fUserData;
              property Animations[const aIndex:TPasGLTFSizeInt]:TAnimation read GetAutomation;
             published
              property Parent:TpvGLTF read fParent;
              property OnNodeMatrixPre:TOnNodeMatrix read fOnNodeMatrixPre write fOnNodeMatrixPre;
              property OnNodeMatrixPost:TOnNodeMatrix read fOnNodeMatrixPost write fOnNodeMatrixPost;
            end;
            TAnimation=record
             public
              type TChannel=record
                    public
                     type TTarget=
                           (
                            Translation,
                            Rotation,
                            Scale,
                            Weights
                           );
                          TInterpolation=
                           (
                            Linear,
                            Step,
                            CubicSpline
                           );
                    public
                     Name:TPasGLTFUTF8String;
                     Node:TPasGLTFSizeInt;
                     Target:TTarget;
                     Interpolation:TInterpolation;
                     InputTimeArray:TPasGLTFFloatDynamicArray;
                     OutputScalarArray:TPasGLTFFloatDynamicArray;
                     OutputVector3Array:TPasGLTF.TVector3DynamicArray;
                     OutputVector4Array:TPasGLTF.TVector4DynamicArray;
                     Last:TPasGLTFSizeInt;
                   end;
                   PChannel=^TChannel;
                   TChannels=array of TChannel;
             public
              Channels:TChannels;
              Name:TPasGLTFUTF8String;
            end;
            PAnimation=^TAnimation;
            TAnimations=array of TAnimation;
            TVertexAttributeBindingLocations=class
             public
              const Position=0;
                    Normal=1;
                    Tangent=2;
                    TexCoord0=3;
                    TexCoord1=4;
                    Color0=5;
                    Joints0=6;
                    Joints1=7;
                    Weights0=8;
                    Weights1=9;
                    VertexIndex=10;
            end;
            TMaterial=record
             public
              type TTextureTransform=record
                    Active:boolean;
                    Offset:TPasGLTF.TVector2;
                    Rotation:TPasGLTFFloat;
                    Scale:TPasGLTF.TVector2;
                   end;
                   PTextureTransform=^TTextureTransform;
                   TTexture=record
                    Index:TPasGLTFSizeInt;
                    TexCoord:TPasGLTFSizeInt;
                    TextureTransform:TTextureTransform;
                   end;
                   PTexture=^TTexture;
                   TPBRMetallicRoughness=record
                    BaseColorFactor:TPasGLTF.TVector4;
                    BaseColorTexture:TTexture;
                    RoughnessFactor:TPasGLTFFloat;
                    MetallicFactor:TPasGLTFFloat;
                    MetallicRoughnessTexture:TTexture;
                   end;
                   TPBRSpecularGlossiness=record
                    DiffuseFactor:TPasGLTF.TVector4;
                    DiffuseTexture:TTexture;
                    GlossinessFactor:TPasGLTFFloat;
                    SpecularFactor:TPasGLTF.TVector3;
                    SpecularGlossinessTexture:TTexture;
                   end;
                   PPBRSpecularGlossiness=^TPBRSpecularGlossiness;
                   TPBRSheen=record
                    Active:boolean;
                    IntensityFactor:TPasGLTFFloat;
                    ColorFactor:TPasGLTF.TVector3;
                    ColorIntensityTexture:TTexture;
                   end;
                   PPBRSheen=^TPBRSheen;
                   TPBRClearCoat=record
                    Active:boolean;
                    Factor:TPasGLTFFloat;
                    Texture:TTexture;
                    RoughnessFactor:TPasGLTFFloat;
                    RoughnessTexture:TTexture;
                    NormalTexture:TTexture;
                   end;
                   PPBRClearCoat=^TPBRClearCoat;
                   TUniformBufferObjectData=packed record
                    case boolean of
                     false:(
                      BaseColorFactor:TPasGLTF.TVector4;
                      SpecularFactor:TPasGLTF.TVector4; // actually TVector3, but for easier and more convenient alignment reasons a TVector4
                      EmissiveFactor:TPasGLTF.TVector4; // actually TVector3, but for easier and more convenient alignment reasons a TVector4
                      MetallicRoughnessNormalScaleOcclusionStrengthFactor:TPasGLTF.TVector4;
                      SheenColorFactorSheenIntensityFactor:TPasGLTF.TVector4;
                      ClearcoatFactorClearcoatRoughnessFactor:TPasGLTF.TVector4;
                      // uvec4 AlphaCutOffFlags begin
                       AlphaCutOff:TPasGLTFFloat; // for with uintBitsToFloat on GLSL code side
                       Flags:TPasGLTFUInt32;
                       Textures0:TPasGLTFUInt32;
                       Textures1:TPasGLTFUInt32;
                      // uvec4 uAlphaCutOffFlags end
                      TextureTransforms:array[0..15] of TPasGLTF.TMatrix4x4;
{$if defined(PasGLTFBindlessTextures)}
                      TextureHandles:array[0..15] of TPasGLTFUInt64; // uvec4[8] due to std140 UBO alignment
{$elseif defined(PasGLTFIndicatedTextures) and not defined(PasGLTFBindlessTextures)}
                      TextureIndices:array[0..15] of TPasGLTFInt32; // ivec4[4] due to std140 UBO alignment
{$ifend}
                     );
                     true:(
                      Alignment:array[1..2048] of UInt8;
                     );
                   end;
                   PUniformBufferObjectData=^TUniformBufferObjectData;
                   TShadingModel=
                    (
                     PBRMetallicRoughness,
                     PBRSpecularGlossiness,
                     Unlit
                    );
             public
              Name:TPasGLTFUTF8String;
              ShadingModel:TShadingModel;
              AlphaCutOff:TPasGLTFFloat;
              AlphaMode:TPasGLTF.TMaterial.TAlphaMode;
              DoubleSided:boolean;
              NormalTexture:TTexture;
              NormalTextureScale:TPasGLTFFloat;
              OcclusionTexture:TTexture;
              OcclusionTextureStrength:TPasGLTFFloat;
              EmissiveFactor:TPasGLTF.TVector4;
              EmissiveTexture:TTexture;
              PBRMetallicRoughness:TPBRMetallicRoughness;
              PBRSpecularGlossiness:TPBRSpecularGlossiness;
              PBRSheen:TPBRSheen;
              PBRClearCoat:TPBRClearCoat;
              UniformBufferObjectData:TUniformBufferObjectData;
              UniformBufferObjectIndex:TPasGLTFSizeInt;
              UniformBufferObjectOffset:TPasGLTFSizeInt;
            end;
            PMaterial=^TMaterial;
            TMaterials=array of TMaterial;
            TMesh=record
             public
              type TPrimitive=record
                    public
                     type TTarget=record
                           public
                            type TTargetVertex=record
                                  Position:TPasGLTF.TVector3;
                                  Normal:TPasGLTF.TVector3;
                                  Tangent:TPasGLTF.TVector3;
                                 end;
                                 PTargetVertex=^TTargetVertex;
                                 TTargetVertices=array of TTargetVertex;
                           public
                            Vertices:TTargetVertices;
                          end;
                          PTarget=^TTarget;
                          TTargets=array of TTarget;
                    public
                     PrimitiveMode:TPasGLTFInt32;
                     Material:TPasGLTFSizeInt;
                     Vertices:TVertices;
                     Indices:TPasGLTFUInt32DynamicArray;
                     Targets:TTargets;
                     StartBufferVertexOffset:TPasGLTFSizeUInt;
                     StartBufferIndexOffset:TPasGLTFSizeUInt;
                     CountVertices:TPasGLTFSizeUInt;
                     CountIndices:TPasGLTFSizeUInt;
                     MorphTargetVertexShaderStorageBufferObjectIndex:TPasGLTFSizeInt;
                     MorphTargetVertexShaderStorageBufferObjectOffset:TPasGLTFSizeUInt;
                     MorphTargetVertexShaderStorageBufferObjectByteOffset:TPasGLTFSizeUInt;
                     MorphTargetVertexShaderStorageBufferObjectByteSize:TPasGLTFSizeUInt;
                   end;
                   PPrimitive=^TPrimitive;
                   TPrimitives=array of TPrimitive;
             public
              Name:TPasGLTFUTF8String;
              Primitives:TPrimitives;
              BoundingBox:TBoundingBox;
              Weights:TPasGLTFFloatDynamicArray;
//            JointWeights:TPasGLTFFloatDynamicArray;
            end;
            PMesh=^TMesh;
            TMeshes=array of TMesh;
            TSkin=record
             Name:TPasGLTFUTF8String;
             Skeleton:TPasGLTFSizeInt;
             InverseBindMatrices:TPasGLTF.TMatrix4x4DynamicArray;
             Matrices:TPasGLTF.TMatrix4x4DynamicArray;
             Joints:TPasGLTFSizeIntDynamicArray;
             SkinShaderStorageBufferObjectIndex:TPasGLTFSizeInt;
             SkinShaderStorageBufferObjectOffset:TPasGLTFSizeUInt;
             SkinShaderStorageBufferObjectByteOffset:TPasGLTFSizeUInt;
             SkinShaderStorageBufferObjectByteSize:TPasGLTFSizeUInt;
            end;
            PSkin=^TSkin;
            TSkins=array of TSkin;
            TCamera=record
             public
              Name:TPasGLTFUTF8String;
              Type_:TPasGLTF.TCamera.TType;
              AspectRatio:TPasGLTFFloat;
              YFov:TPasGLTFFloat;
              XMag:TPasGLTFFloat;
              YMag:TPasGLTFFloat;
              ZNear:TPasGLTFFloat;
              ZFar:TPasGLTFFloat;
            end;
            PCamera=^TCamera;
            TCameras=array of TCamera;
            TNode=record
             public
              type TOverwriteFlag=
                    (
                     Translation,
                     Rotation,
                     Scale,
                     Weights
                    );
                   TOverwriteFlags=set of TOverwriteFlag;
                   TMeshPrimitiveMetaData=record
                    ShaderStorageBufferObjectIndex:TPasGLTFSizeInt;
                    ShaderStorageBufferObjectOffset:TPasGLTFSizeUInt;
                    ShaderStorageBufferObjectByteOffset:TPasGLTFSizeUInt;
                    ShaderStorageBufferObjectByteSize:TPasGLTFSizeUInt;
                   end;
                   PMeshPrimitiveMetaData=^TMeshPrimitiveMetaData;
                   TMeshPrimitiveMetaDataArray=array of TMeshPrimitiveMetaData;
             public
              Name:TPasGLTFUTF8String;
              Children:TPasGLTFSizeUIntDynamicArray;
              Weights:TPasGLTFFloatDynamicArray;
              Mesh:TPasGLTFSizeInt;
              Camera:TPasGLTFSizeInt;
              Skin:TPasGLTFSizeInt;
              Joint:TPasGLTFSizeInt;
              Light:TPasGLTFSizeInt;
              Matrix:TPasGLTF.TMatrix4x4;
              Translation:TPasGLTF.TVector3;
              Rotation:TPasGLTF.TVector4;
              Scale:TPasGLTF.TVector3;
              MeshPrimitiveMetaDataArray:TMeshPrimitiveMetaDataArray;
            end;
            PNode=^TNode;
            TNodes=array of TNode;
            TImage=record
             Name:TPasGLTFUTF8String;
             URI:TPasGLTFUTF8String;
             MIMEType:TPasGLTFUTF8String;
             Data:TBytes;
            end;
            PImage=^TImage;
            TImages=array of TImage;
            TSampler=record
             Name:TPasGLTFUTF8String;
             MagFilter:TPasGLTF.TSampler.TMagFilter;
             MinFilter:TPasGLTF.TSampler.TMinFilter;
             WrapS:TPasGLTF.TSampler.TWrappingMode;
             WrapT:TPasGLTF.TSampler.TWrappingMode;
            end;
            PSampler=^TSampler;
            TSamplers=array of TSampler;
            TTexture=record
             Name:TPasGLTFUTF8String;
             Image:TPasGLTFSizeInt;
             Sampler:TPasGLTFSizeInt;
            end;
            PTexture=^TTexture;
            TTextures=array of TTexture;
            TJoint=record
             public
              type TChildren=array of TPasGLTFSizeInt;
             public
              Parent:TPasGLTFSizeInt;
              Node:TPasGLTFSizeInt;
              Children:TChildren;
              CountChildren:TPasGLTFSizeInt;
            end;
            PJoint=^TJoint;
            TJoints=array of TJoint;
            TJointVertices=array of TPasGLTF.TVector3;
            TSkinShaderStorageBufferObject=record
             Count:TPasGLTFSizeInt;
             Size:TPasGLTFSizeInt;
             Skins:TPasGLTFSizeIntDynamicArray;
             CountSkins:TPasGLTFSizeInt;
            end;
            PSkinShaderStorageBufferObject=^TSkinShaderStorageBufferObject;
            TSkinShaderStorageBufferObjects=array of TSkinShaderStorageBufferObject;
            TMorphTargetVertex=packed record
             Position:TPasGLTF.TVector4;
             Normal:TPasGLTF.TVector4;
             Tangent:TPasGLTF.TVector4;
             Reversed:TPasGLTF.TVector4; // just for alignment of 64 bytes for now
            end;
            PMorphTargetVertex=^TMorphTargetVertex;
            TMorphTargetVertexDynamicArray=array of TMorphTargetVertex;
            TMorphTargetVertexShaderStorageBufferObject=record
             Count:TPasGLTFSizeInt;
             Size:TPasGLTFSizeInt;
             Data:TBytes;
            end;
            PMorphTargetVertexShaderStorageBufferObject=^TMorphTargetVertexShaderStorageBufferObject;
            TMorphTargetVertexShaderStorageBufferObjects=array of TMorphTargetVertexShaderStorageBufferObject;
            TFrameGlobalsUniformBufferObjectData=packed record
             InverseViewMatrix:TPasGLTF.TMatrix4x4;
             ModelMatrix:TPasGLTF.TMatrix4x4;
             ViewProjectionMatrix:TPasGLTF.TMatrix4x4;
             NormalMatrix:TPasGLTF.TMatrix4x4;
            end;
            PFrameGlobalsUniformBufferObjectData=^TFrameGlobalsUniformBufferObjectData;
            TMaterialUniformBufferObject=record
             Size:TPasGLTFSizeInt;
             Materials:TPasGLTFSizeIntDynamicArray;
             Count:TPasGLTFSizeInt;
            end;
            PMaterialUniformBufferObject=^TMaterialUniformBufferObject;
            TMaterialUniformBufferObjects=array of TMaterialUniformBufferObject;
            TNodeMeshPrimitiveShaderStorageBufferObjectDataItem=packed record
             Matrix:TPasGLTF.TMatrix4x4;
             // uvec4 MetaData; begin
              Reversed:TPasGLTFUInt32;
              JointOffset:TPasGLTFUInt32;
              CountVertices:TPasGLTFUInt32;
              CountMorphTargets:TPasGLTFUInt32;
             // uvec4 MetaData; end
             MorphTargetWeights:array[0..0] of TPasGLTFFloat;
            end;
            PNodeMeshPrimitiveShaderStorageBufferObjectDataItem=^TNodeMeshPrimitiveShaderStorageBufferObjectDataItem;
            TNodeMeshPrimitiveShaderStorageBufferObjectDataItems=array of TNodeMeshPrimitiveShaderStorageBufferObjectDataItem;
            TNodeMeshPrimitiveShaderStorageBufferObjectItem=record
             Node:TPasGLTFSizeInt;
             Mesh:TPasGLTFSizeInt;
             Primitive:TPasGLTFSizeInt;
            end;
            PNodeMeshPrimitiveShaderStorageBufferObjectItem=^TNodeMeshPrimitiveShaderStorageBufferObjectItem;
            TNodeMeshPrimitiveShaderStorageBufferObjectItems=array of TNodeMeshPrimitiveShaderStorageBufferObjectItem;
            TNodeMeshPrimitiveShaderStorageBufferObject=record
             Size:TPasGLTFSizeInt;
             Items:TNodeMeshPrimitiveShaderStorageBufferObjectItems;
             Count:TPasGLTFSizeInt;
            end;
            PNodeMeshPrimitiveShaderStorageBufferObject=^TNodeMeshPrimitiveShaderStorageBufferObject;
            TNodeMeshPrimitiveShaderStorageBufferObjects=array of TNodeMeshPrimitiveShaderStorageBufferObject;
            TLightDataType=class
             public
              const None=0;
                    Directional=1;
                    Point=2;
                    Spot=3;
            end;
            TLightShaderStorageBufferObjectDataItem=packed record
             // uvec4 MetaData; begin
              Type_:TPasGLTFUInt32;
              ShadowMapIndex:TPasGLTFUInt32;
{             InnerConeCosinus:TPasGLTFFloat;
              OuterConeCosinus:TPasGLTFFloat;}
              LightAngleScale:TPasGLTFFloat;
              LightAngleOffset:TPasGLTFFloat;
             // uvec4 MetaData; end
             ColorIntensity:TPasGLTF.TVector4; // XYZ = Color RGB, W = Intensity
             PositionRange:TPasGLTF.TVector4; // XYZ = Position, W = Range
             DirectionZFar:TPasGLTF.TVector4; // XYZ = Direction, W = Unused
             ShadowMapMatrix:TPasGLTF.TMatrix4x4;
            end;
            PLightShaderStorageBufferObjectDataItem=^TLightShaderStorageBufferObjectDataItem;
            TLightShaderStorageBufferObjectData=packed record
             // uvec4 MetaData; begin
              Count:TPasGLTFUInt32;
              Reserved:array[0..2] of TPasGLTFUInt32;
             // uvec4 MetaData; end
             Lights:array[0..0] of TLightShaderStorageBufferObjectDataItem;
            end;
            PLightShaderStorageBufferObjectData=^TLightShaderStorageBufferObjectData;
            TLightShaderStorageBufferObject=record
             Size:TPasGLTFSizeInt;
             Data:PLightShaderStorageBufferObjectData;
            end;
            TLight=record
             public
              Name:TPasGLTFUTF8String;
              Type_:TPasGLTFUInt32;
              Node:TPasGLTFInt32;
              ShadowMapIndex:TPasGLTFInt32;
              Intensity:TPasGLTFFloat;
              Range:TPasGLTFFloat;
              InnerConeAngle:TPasGLTFFloat;
              OuterConeAngle:TPasGLTFFloat;
              Direction:TPasGLTF.TVector3;
              Color:TPasGLTF.TVector3;
              CastShadows:boolean;
            end;
            PLight=^TLight;
            TLights=array of TLight;
            TNodeNameHashMap=TPasGLTFUTF8StringHashMap<TPasGLTFSizeInt>;
       const EmptyBoundingBox:TBoundingBox=(Min:(Infinity,Infinity,Infinity);Max:(NegInfinity,NegInfinity,NegInfinity));
      private
       fReady:boolean;
       fUploaded:boolean;
       fLights:TLights;
       fAnimations:TAnimations;
       fMaterials:TMaterials;
       fMeshes:TMeshes;
       fSkins:TSkins;
       fCameras:TCameras;
       fNodes:TNodes;
       fImages:TImages;
       fSamplers:TSamplers;
       fTextures:TTextures;
       fJoints:TJoints;
       fScenes:TScenes;
       fScene:TPasGLTFSizeInt;
       fJointVertices:TJointVertices;
       fNodeNameHashMap:TNodeNameHashMap;
       fSkinShaderStorageBufferObjects:TSkinShaderStorageBufferObjects;
       fMorphTargetVertexShaderStorageBufferObjects:TMorphTargetVertexShaderStorageBufferObjects;
       fNodeMeshPrimitiveShaderStorageBufferObjects:TNodeMeshPrimitiveShaderStorageBufferObjects;
       fMaterialUniformBufferObjects:TMaterialUniformBufferObjects;
       fLightShaderStorageBufferObject:TLightShaderStorageBufferObject;
       fStaticBoundingBox:TBoundingBox;
       fCountNormalShadowMaps:TPasGLTFInt32;
       fCountCubeMapShadowMaps:TPasGLTFInt32;
       fRootPath:String;
       fGetURI:TGetURI;
       function DefaultGetURI(const aURI:TPasGLTFUTF8String):TStream;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Clear;
       procedure LoadFromDocument(const aDocument:TPasGLTF.TDocument);
       procedure LoadFromStream(const aStream:TStream);
       procedure LoadFromFile(const aFileName:String);
       function AddDirectionalLight(const aDirectionX,aDirectionY,aDirectionZ,aColorX,aColorY,aColorZ:TPasGLTFFloat):TPasGLTFSizeInt;
       procedure Upload;
       procedure Unload;
       function GetAnimationBeginTime(const aAnimation:TPasGLTFSizeInt):TPasGLTFDouble;
       function GetAnimationEndTime(const aAnimation:TPasGLTFSizeInt):TPasGLTFDouble;
       function GetAnimationTimes(const aAnimation:TPasGLTFSizeInt):TPasGLTFDoubleDynamicArray;
       function GetNodeIndex(const aNodeName:TPasGLTFUTF8String):TPasGLTFSizeInt;
       function AcquireInstance:TpvGLTF.TInstance;
      public
       property StaticBoundingBox:TBoundingBox read fStaticBoundingBox;
       property Lights:TLights read fLights;
       property Animations:TAnimations read fAnimations;
       property Materials:TMaterials read fMaterials;
       property Meshes:TMeshes read fMeshes;
       property Skins:TSkins read fSkins;
       property Cameras:TCameras read fCameras;
       property Nodes:TNodes read fNodes;
       property Images:TImages read fImages;
       property Samplers:TSamplers read fSamplers;
       property Textures:TTextures read fTextures;
       property Joints:TJoints read fJoints;
       property Scenes:TScenes read fScenes;
       property Scene:TPasGLTFSizeInt read fScene;
      published
       property GetURI:TGetURI read fGetURI write fGetURI;
       property RootPath:String read fRootPath write fRootPath;
     end;

const Epsilon=1e-8;

{$ifdef fpcgl}
      GL_TEXTURE_MAX_ANISOTROPY=$84fe;

      GL_MAX_TEXTURE_MAX_ANISOTROPY=$84ff;

      GL_SHADER_STORAGE_BUFFER=$90d2;

      GL_MAX_SHADER_STORAGE_BLOCK_SIZE=$90de;

      GL_SHADER_STORAGE_BUFFER_OFFSET_ALIGNMENT=$90df;

      GL_NEGATIVE_ONE_TO_ONE=$935e;

      GL_ZERO_TO_ONE=$935f;

      GL_R32F=$822e;

      GL_DEPTH_COMPONENT32F=$8cac;

      GL_TEXTURE_CUBE_MAP_ARRAY=$9009;

type TglClipControl=procedure(origin:GLenum;depth:GLenum); {$if defined(Windows) or defined(Win32) or defined(Win64)}stdcall;{$else}cdecl;{$ifend}
     TglGetTextureHandleARB=function(texture:GLuint):GLUInt64; {$if defined(Windows) or defined(Win32) or defined(Win64)}stdcall;{$else}cdecl;{$ifend}
     TglMakeTextureHandleResidentARB=procedure(handle:GLuint64); {$if defined(Windows) or defined(Win32) or defined(Win64)}stdcall;{$else}cdecl;{$ifend}
     TglMakeTextureHandleNonResidentARB=procedure(handle:GLuint64); {$if defined(Windows) or defined(Win32) or defined(Win64)}stdcall;{$else}cdecl;{$ifend}

var glClipControl:TglClipControl=nil;
    glGetTextureHandleARB:TglGetTextureHandleARB=nil;
    glMakeTextureHandleResidentARB:TglMakeTextureHandleResidentARB=nil;
    glMakeTextureHandleNonResidentARB:TglMakeTextureHandleNonResidentARB=nil;
{$endif}

implementation

const GL_POINTS=0;
      GL_LINES=1;
      GL_LINE_LOOP=2;
      GL_LINE_STRIP=3;
      GL_TRIANGLES=4;
      GL_TRIANGLE_STRIP=5;
      GL_TRIANGLE_FAN=6;

type TVector2=TPasGLTF.TVector2;
     PVector2=^TVector2;

     TVector3=TPasGLTF.TVector3;
     PVector3=^TVector3;

     TVector4=TPasGLTF.TVector4;
     PVector4=^TVector4;

     TMatrix=TPasGLTF.TMatrix4x4;
     PMatrix=^TMatrix;

const EmptyMaterialUniformBufferObjectData:TpvGLTF.TMaterial.TUniformBufferObjectData=
       (
        BaseColorFactor:(1.0,1.0,1.0,1.0);
        SpecularFactor:(1.0,1.0,1.0,0.0);
        EmissiveFactor:(0.0,0.0,0.0,0.0);
        MetallicRoughnessNormalScaleOcclusionStrengthFactor:(1.0,1.0,1.0,1.0);
        SheenColorFactorSheenIntensityFactor:(1.0,1.0,1.0,1.0);
        ClearcoatFactorClearcoatRoughnessFactor:(0.0,0.0,1.0,1.0);
        AlphaCutOff:1.0;
        Flags:0;
        Textures0:$ffffffff;
        Textures1:$ffffffff;
        TextureTransforms:(
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0),
         (1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0)
        );
{$if defined(PasGLTFBindlessTextures)}
        TextureHandles:(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
{$elseif defined(PasGLTFIndicatedTextures) and not defined(PasGLTFBindlessTextures)}
        TextureIndices:(-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1);
{$ifend}
       );

function CompareFloats(const a,b:TPasGLTFFloat):TPasGLTFInt32;
begin
 if a<b then begin
  result:=-1;
 end else if a>b then begin
  result:=1;
 end else begin
  result:=0;
 end;
end;

function Vector2Add(const a,b:TVector2):TVector2;
begin
 result[0]:=a[0]+b[0];
 result[1]:=a[1]+b[1];
end;

function Vector2Sub(const a,b:TVector2):TVector2;
begin
 result[0]:=a[0]-b[0];
 result[1]:=a[1]-b[1];
end;

function Vector3(const aX,aY,aZ:TPasGLTFFloat):TVector3;
begin
 result[0]:=aX;
 result[1]:=aY;
 result[2]:=aZ;
end;

function Vector3Add(const a,b:TVector3):TVector3;
begin
 result[0]:=a[0]+b[0];
 result[1]:=a[1]+b[1];
 result[2]:=a[2]+b[2];
end;

function Vector3Sub(const a,b:TVector3):TVector3;
begin
 result[0]:=a[0]-b[0];
 result[1]:=a[1]-b[1];
 result[2]:=a[2]-b[2];
end;

function Vector3Cross(const a,b:TVector3):TVector3;
begin
 result[0]:=(a[1]*b[2])-(a[2]*b[1]);
 result[1]:=(a[2]*b[0])-(a[0]*b[2]);
 result[2]:=(a[0]*b[1])-(a[1]*b[0]);
end;

function Vector3Dot(const a,b:TVector3):TPasGLTFFloat;
begin
 result:=(a[0]*b[0])+(a[1]*b[1])+(a[2]*b[2]);
end;

function Vector3Normalize(const aVector:TVector3):TVector3;
var l:TPasGLTFFloat;
begin
 l:=sqrt(sqr(aVector[0])+sqr(aVector[1])+sqr(aVector[2]));
 if abs(l)>Epsilon then begin
  result[0]:=aVector[0]/l;
  result[1]:=aVector[1]/l;
  result[2]:=aVector[2]/l;
 end else begin
  result[0]:=0.0;
  result[1]:=0.0;
  result[2]:=0.0;
 end;
end;

function Vector3Neg(const aVector:TVector3):TVector3;
begin
 result[0]:=-aVector[0];
 result[1]:=-aVector[1];
 result[2]:=-aVector[2];
end;

function Vector3Scale(const aVector:TVector3;const aFactor:TPasGLTFFloat):TVector3;
begin
 result[0]:=aVector[0]*aFactor;
 result[1]:=aVector[1]*aFactor;
 result[2]:=aVector[2]*aFactor;
end;

function Vector3ScalarMul(const aVector:TVector3;const aFactor:TPasGLTFFloat):TVector3;
begin
 result[0]:=aVector[0]*aFactor;
 result[1]:=aVector[1]*aFactor;
 result[2]:=aVector[2]*aFactor;
end;

function Vector3MatrixMul(const m:TPasGLTF.TMatrix4x4;const v:TVector3):TVector3;
begin
 result[0]:=(m[0]*v[0])+(m[4]*v[1])+(m[8]*v[2])+m[12];
 result[1]:=(m[1]*v[0])+(m[5]*v[1])+(m[9]*v[2])+m[13];
 result[2]:=(m[2]*v[0])+(m[6]*v[1])+(m[10]*v[2])+m[14];
end;

function Vector3MatrixMulHomogen(const m:TPasGLTF.TMatrix4x4;const v:TVector3):TVector3;
var result_w:single;
begin
 result[0]:=(m[0]*v[0])+(m[4]*v[1])+(m[8]*v[2])+m[12];
 result[1]:=(m[1]*v[0])+(m[5]*v[1])+(m[9]*v[2])+m[13];
 result[2]:=(m[2]*v[0])+(m[6]*v[1])+(m[10]*v[2])+m[14];
 result_w:=(m[3]*v[0])+(m[7]*v[1])+(m[11]*v[2])+m[15];
 result[0]:=result[0]/result_w;
 result[1]:=result[1]/result_w;
 result[2]:=result[2]/result_w;
end;

function Vector4(const aX,aY,aZ,aW:TPasGLTFFloat):TVector4;
begin
 result[0]:=aX;
 result[1]:=aY;
 result[2]:=aZ;
 result[3]:=aW;
end;

function Vector4Dot(const a,b:TVector4):TPasGLTFFloat;
begin
 result:=(a[0]*b[0])+(a[1]*b[1])+(a[2]*b[2])+(a[3]*b[3]);
end;

function Vector4Neg(const aVector:TVector4):TVector4;
begin
 result[0]:=-aVector[0];
 result[1]:=-aVector[1];
 result[2]:=-aVector[2];
 result[3]:=-aVector[3];
end;

function Vector4Normalize(const aVector:TVector4):TVector4;
var l:TPasGLTFFloat;
begin
 l:=sqrt(sqr(aVector[0])+sqr(aVector[1])+sqr(aVector[2])+sqr(aVector[3]));
 if abs(l)>Epsilon then begin
  result[0]:=aVector[0]/l;
  result[1]:=aVector[1]/l;
  result[2]:=aVector[2]/l;
  result[3]:=aVector[3]/l;
 end else begin
  result[0]:=0.0;
  result[1]:=0.0;
  result[2]:=0.0;
  result[3]:=0.0;
 end;
end;

function Vector4MatrixMul(const m:TPasGLTF.TMatrix4x4;const v:TVector4):TVector4;
begin
 result[0]:=(m[0]*v[0])+(m[4]*v[1])+(m[8]*v[2])+(m[12]*v[3]);
 result[1]:=(m[1]*v[0])+(m[5]*v[1])+(m[9]*v[2])+(m[13]*v[3]);
 result[2]:=(m[2]*v[0])+(m[6]*v[1])+(m[10]*v[2])+(m[14]*v[3]);
 result[3]:=(m[3]*v[0])+(m[7]*v[1])+(m[11]*v[2])+(m[15]*v[3]);
end;

function QuaternionMul(const q1,q2:TVector4):TVector4;
begin
 result[0]:=((q1[3]*q2[0])+(q1[0]*q2[3])+(q1[1]*q2[2]))-(q1[2]*q2[1]);
 result[1]:=((q1[3]*q2[1])+(q1[1]*q2[3])+(q1[2]*q2[0]))-(q1[0]*q2[2]);
 result[2]:=((q1[3]*q2[2])+(q1[2]*q2[3])+(q1[0]*q2[1]))-(q1[1]*q2[0]);
 result[3]:=(q1[3]*q2[3])-((q1[0]*q2[0])+(q1[1]*q2[1])+(q1[2]*q2[2]));
end;

function QuaternionConjugate(const AQuaternion:TVector4):TVector4;
begin
 result[0]:=-AQuaternion[0];
 result[1]:=-AQuaternion[1];
 result[2]:=-AQuaternion[2];
 result[3]:=AQuaternion[3];
end;

function QuaternionInverse(const AQuaternion:TVector4):TVector4;var Normal:TPasGLTFFloat;
begin
 Normal:=sqrt(sqr(AQuaternion[0])+sqr(AQuaternion[1])+sqr(AQuaternion[2])+sqr(AQuaternion[3]));
 if abs(Normal)>1e-18 then begin
  Normal:=1.0/Normal;
 end;
 result[0]:=-(AQuaternion[0]*Normal);
 result[1]:=-(AQuaternion[1]*Normal);
 result[2]:=-(AQuaternion[2]*Normal);
 result[3]:=(AQuaternion[3]*Normal);
end;

function QuaternionAdd(const q1,q2:TVector4):TVector4;
begin
 result[0]:=q1[0]+q2[0];
 result[1]:=q1[1]+q2[1];
 result[2]:=q1[2]+q2[2];
 result[3]:=q1[3]+q2[3];
end;

function QuaternionSub(const q1,q2:TVector4):TVector4;
begin
 result[0]:=q1[0]-q2[0];
 result[1]:=q1[1]-q2[1];
 result[2]:=q1[2]-q2[2];
 result[3]:=q1[3]-q2[3];
end;

function QuaternionScalarMul(const q:TVector4;const s:TPasGLTFFloat):TVector4;
begin
 result[0]:=q[0]*s;
 result[1]:=q[1]*s;
 result[2]:=q[2]*s;
 result[3]:=q[3]*s;
end;

function QuaternionSlerp(const q1,q2:TVector4;const t:TPasGLTFFloat):TVector4;
const EPSILON=1e-12;
var Omega,co,so,s0,s1,s2:TPasGLTFFloat;
begin
 co:=(q1[0]*q2[0])+(q1[1]*q2[1])+(q1[2]*q2[2])+(q1[3]*q2[3]);
 if co<0.0 then begin
  co:=-co;
  s2:=-1.0;
 end else begin
  s2:=1.0;
 end;
 if (1.0-co)>EPSILON then begin
  Omega:=ArcCos(co);
  so:=sin(Omega);
  s0:=sin((1.0-t)*Omega)/so;
  s1:=sin(t*Omega)/so;
 end else begin
  s0:=1.0-t;
  s1:=t;
 end;
 result[0]:=(s0*q1[0])+(s1*(s2*q2[0]));
 result[1]:=(s0*q1[1])+(s1*(s2*q2[1]));
 result[2]:=(s0*q1[2])+(s1*(s2*q2[2]));
 result[3]:=(s0*q1[3])+(s1*(s2*q2[3]));
end;

function QuaternionUnflippedSlerp(const q1,q2:TVector4;const t:TPasGLTFFloat):TVector4; {$ifdef caninline}inline;{$endif}
var Omega,co,so,s0,s1:TPasGLTFFloat;
begin
 co:=(q1[0]*q2[0])+(q1[1]*q2[1])+(q1[2]*q2[2])+(q1[3]*q2[3]);
 if (1.0-co)>1e-8 then begin
  Omega:=ArcCos(co);
  so:=sin(Omega);
  s0:=sin((1.0-t)*Omega)/so;
  s1:=sin(t*Omega)/so;
 end else begin
  s0:=1.0-t;
  s1:=t;
 end;
 result[0]:=(s0*q1[0])+(s1*q2[0]);
 result[1]:=(s0*q1[1])+(s1*q2[1]);
 result[2]:=(s0*q1[2])+(s1*q2[2]);
 result[3]:=(s0*q1[3])+(s1*q2[3]);
end;

function QuaternionLog(const AQuaternion:TVector4):TVector4;
var Theta,SinTheta,Coefficent:TPasGLTFFloat;
begin
 result[0]:=AQuaternion[0];
 result[1]:=AQuaternion[1];
 result[2]:=AQuaternion[2];
 result[3]:=0.0;
 if abs(AQuaternion[3])<1.0 then begin
  Theta:=ArcCos(AQuaternion[3]);
  SinTheta:=sin(Theta);
  if abs(SinTheta)>1e-6 then begin
   Coefficent:=Theta/SinTheta;
   result[0]:=result[0]*Coefficent;
   result[1]:=result[1]*Coefficent;
   result[2]:=result[2]*Coefficent;
  end;
 end;
end;

function QuaternionExp(const AQuaternion:TVector4):TVector4;
var Angle,Sinus,Coefficent:TPasGLTFFloat;
begin
 Angle:=sqrt(sqr(AQuaternion[0])+sqr(AQuaternion[1])+sqr(AQuaternion[2]));
 Sinus:=sin(Angle);
 result[3]:=cos(Angle);
 if abs(Sinus)>1e-6 then begin
  Coefficent:=Sinus/Angle;
  result[0]:=AQuaternion[0]*Coefficent;
  result[1]:=AQuaternion[1]*Coefficent;
  result[2]:=AQuaternion[2]*Coefficent;
 end else begin
  result[0]:=AQuaternion[0];
  result[1]:=AQuaternion[1];
  result[2]:=AQuaternion[2];
 end;
end;

function QuaternionKochanekBartelsSplineInterpolate(const t,t0,t1,t2,t3:TPasGLTFFloat;q0,q1,q2,q3:TVector4;const Tension1,Continuity1,Bias1,Tension2,Continuity2,Bias2:TPasGLTFFloat):TVector4;
var qLog10,qLog21,qLog32,qTOut,qTIn:TVector4;
    AdjustMulOneMinusTensionMulHalf:TPasGLTFFloat;
begin
 if Vector4Dot(q0,q1)<0.0 then begin
  q1:=Vector4Neg(q1);
 end;
 if Vector4Dot(q1,q2)<0.0 then begin
  q2:=Vector4Neg(q2);
 end;
 if Vector4Dot(q2,q3)<0.0 then begin
  q3:=Vector4Neg(q3);
 end;
 qLog10:=QuaternionLog(QuaternionMul(QuaternionConjugate(q0),q1));
 qLog21:=QuaternionLog(QuaternionMul(QuaternionConjugate(q1),q2));
 qLog32:=QuaternionLog(QuaternionMul(QuaternionConjugate(q2),q3));
 AdjustMulOneMinusTensionMulHalf:=((((t2-t1)/(t2-t0)){*2.0})*(1.0-Tension1)){*0.5};
 qTOut:=QuaternionAdd(QuaternionScalarMul(qLog10,AdjustMulOneMinusTensionMulHalf*(1.0+Continuity1)*(1.0+Bias1)),
                      QuaternionScalarMul(qLog21,AdjustMulOneMinusTensionMulHalf*(1.0-Continuity1)*(1.0-Bias1)));
 AdjustMulOneMinusTensionMulHalf:=((((t2-t1)/(t3-t1)){*2.0})*(1.0-Tension2)){*0.5};
 qTIn:=QuaternionAdd(QuaternionScalarMul(qLog21,AdjustMulOneMinusTensionMulHalf*(1.0-Continuity2)*(1.0+Bias2)),
                     QuaternionScalarMul(qLog32,AdjustMulOneMinusTensionMulHalf*(1.0+Continuity2)*(1.0-Bias2)));
 result:=QuaternionUnflippedSlerp(QuaternionUnflippedSlerp(q1,q2,t),
                                  QuaternionUnflippedSlerp(QuaternionMul(q1,QuaternionExp(QuaternionScalarMul(QuaternionSub(qTOut,qLog21),0.5))),
                                                           QuaternionMul(q2,QuaternionExp(QuaternionScalarMul(QuaternionSub(qLog21,qTIn),0.5))),
                                                           t),
                                  2.0*(t*(1.0-t)));
end;

function MatrixFrom2DRotation(const aRotation:TPasGLTFFloat):TMatrix;
var Sinus,Cosinus:TPasGLTFFloat;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(aRotation,Sinus,Cosinus);
 result[0]:=Cosinus;
 result[1]:=Sinus;
 result[2]:=0.0;
 result[3]:=0.0;
 result[4]:=-Sinus;
 result[5]:=Cosinus;
 result[6]:=0.0;
 result[7]:=0.0;
 result[8]:=0.0;
 result[9]:=0.0;
 result[10]:=1.0;
 result[11]:=0.0;
 result[12]:=0.0;
 result[13]:=0.0;
 result[14]:=0.0;
 result[15]:=1.0;
end;

function MatrixFromRotation(const aRotation:TVector4):TMatrix;
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2,l:TPasGLTFFloat;
    Rotation:TPasGLTF.TVector4;
begin
 l:=sqrt(sqr(aRotation[0])+sqr(aRotation[1])+sqr(aRotation[2])+sqr(aRotation[3]));
 Rotation[0]:=aRotation[0]/l;
 Rotation[1]:=aRotation[1]/l;
 Rotation[2]:=aRotation[2]/l;
 Rotation[3]:=aRotation[3]/l;
 qx2:=Rotation[0]+Rotation[0];
 qy2:=Rotation[1]+Rotation[1];
 qz2:=Rotation[2]+Rotation[2];
 qxqx2:=Rotation[0]*qx2;
 qxqy2:=Rotation[0]*qy2;
 qxqz2:=Rotation[0]*qz2;
 qxqw2:=Rotation[3]*qx2;
 qyqy2:=Rotation[1]*qy2;
 qyqz2:=Rotation[1]*qz2;
 qyqw2:=Rotation[3]*qy2;
 qzqz2:=Rotation[2]*qz2;
 qzqw2:=Rotation[3]*qz2;
 result[0]:=1.0-(qyqy2+qzqz2);
 result[1]:=qxqy2+qzqw2;
 result[2]:=qxqz2-qyqw2;
 result[3]:=0.0;
 result[4]:=qxqy2-qzqw2;
 result[5]:=1.0-(qxqx2+qzqz2);
 result[6]:=qyqz2+qxqw2;
 result[7]:=0.0;
 result[8]:=qxqz2+qyqw2;
 result[9]:=qyqz2-qxqw2;
 result[10]:=1.0-(qxqx2+qyqy2);
 result[11]:=0.0;
 result[12]:=0.0;
 result[13]:=0.0;
 result[14]:=0.0;
 result[15]:=1.0;
end;

function MatrixFromScale(const aScale:TVector3):TMatrix;
begin
 result[0]:=aScale[0];
 result[1]:=0.0;
 result[2]:=0.0;
 result[3]:=0.0;
 result[4]:=0.0;
 result[5]:=aScale[1];
 result[6]:=0.0;
 result[7]:=0.0;
 result[8]:=0.0;
 result[9]:=0.0;
 result[10]:=aScale[2];
 result[11]:=0.0;
 result[12]:=0.0;
 result[13]:=0.0;
 result[14]:=0.0;
 result[15]:=1.0;
end;

function MatrixFromTranslation(const aTranslation:TVector3):TMatrix;
begin
 result[0]:=1.0;
 result[1]:=0.0;
 result[2]:=0.0;
 result[3]:=0.0;
 result[4]:=0.0;
 result[5]:=1.0;
 result[6]:=0.0;
 result[7]:=0.0;
 result[8]:=0.0;
 result[9]:=0.0;
 result[10]:=1.0;
 result[11]:=0.0;
 result[12]:=aTranslation[0];
 result[13]:=aTranslation[1];
 result[14]:=aTranslation[2];
 result[15]:=1.0;
end;

function MatrixMul(const a,b:TMatrix):TMatrix;
begin
 result[0]:=(a[0]*b[0])+(a[1]*b[4])+(a[2]*b[8])+(a[3]*b[12]);
 result[1]:=(a[0]*b[1])+(a[1]*b[5])+(a[2]*b[9])+(a[3]*b[13]);
 result[2]:=(a[0]*b[2])+(a[1]*b[6])+(a[2]*b[10])+(a[3]*b[14]);
 result[3]:=(a[0]*b[3])+(a[1]*b[7])+(a[2]*b[11])+(a[3]*b[15]);
 result[4]:=(a[4]*b[0])+(a[5]*b[4])+(a[6]*b[8])+(a[7]*b[12]);
 result[5]:=(a[4]*b[1])+(a[5]*b[5])+(a[6]*b[9])+(a[7]*b[13]);
 result[6]:=(a[4]*b[2])+(a[5]*b[6])+(a[6]*b[10])+(a[7]*b[14]);
 result[7]:=(a[4]*b[3])+(a[5]*b[7])+(a[6]*b[11])+(a[7]*b[15]);
 result[8]:=(a[8]*b[0])+(a[9]*b[4])+(a[10]*b[8])+(a[11]*b[12]);
 result[9]:=(a[8]*b[1])+(a[9]*b[5])+(a[10]*b[9])+(a[11]*b[13]);
 result[10]:=(a[8]*b[2])+(a[9]*b[6])+(a[10]*b[10])+(a[11]*b[14]);
 result[11]:=(a[8]*b[3])+(a[9]*b[7])+(a[10]*b[11])+(a[11]*b[15]);
 result[12]:=(a[12]*b[0])+(a[13]*b[4])+(a[14]*b[8])+(a[15]*b[12]);
 result[13]:=(a[12]*b[1])+(a[13]*b[5])+(a[14]*b[9])+(a[15]*b[13]);
 result[14]:=(a[12]*b[2])+(a[13]*b[6])+(a[14]*b[10])+(a[15]*b[14]);
 result[15]:=(a[12]*b[3])+(a[13]*b[7])+(a[14]*b[11])+(a[15]*b[15]);
end;

function MatrixInverse(const ma:TPasGLTF.TMatrix4x4):TPasGLTF.TMatrix4x4;
var Temporary:array[0..15] of TPasGLTFFloat;
    Det:TPasGLTFFloat;
begin
 Temporary[0]:=(((ma[5]*ma[10]*ma[15])-(ma[5]*ma[11]*ma[14]))-(ma[9]*ma[6]*ma[15])+(ma[9]*ma[7]*ma[14])+(ma[13]*ma[6]*ma[11]))-(ma[13]*ma[7]*ma[10]);
 Temporary[4]:=((((-(ma[4]*ma[10]*ma[15]))+(ma[4]*ma[11]*ma[14])+(ma[8]*ma[6]*ma[15]))-(ma[8]*ma[7]*ma[14]))-(ma[12]*ma[6]*ma[11]))+(ma[12]*ma[7]*ma[10]);
 Temporary[8]:=((((ma[4]*ma[9]*ma[15])-(ma[4]*ma[11]*ma[13]))-(ma[8]*ma[5]*ma[15]))+(ma[8]*ma[7]*ma[13])+(ma[12]*ma[5]*ma[11]))-(ma[12]*ma[7]*ma[9]);
 Temporary[12]:=((((-(ma[4]*ma[9]*ma[14]))+(ma[4]*ma[10]*ma[13])+(ma[8]*ma[5]*ma[14]))-(ma[8]*ma[6]*ma[13]))-(ma[12]*ma[5]*ma[10]))+(ma[12]*ma[6]*ma[9]);
 Temporary[1]:=((((-(ma[1]*ma[10]*ma[15]))+(ma[1]*ma[11]*ma[14])+(ma[9]*ma[2]*ma[15]))-(ma[9]*ma[3]*ma[14]))-(ma[13]*ma[2]*ma[11]))+(ma[13]*ma[3]*ma[10]);
 Temporary[5]:=(((ma[0]*ma[10]*ma[15])-(ma[0]*ma[11]*ma[14]))-(ma[8]*ma[2]*ma[15])+(ma[8]*ma[3]*ma[14])+(ma[12]*ma[2]*ma[11]))-(ma[12]*ma[3]*ma[10]);
 Temporary[9]:=((((-(ma[0]*ma[9]*ma[15]))+(ma[0]*ma[11]*ma[13])+(ma[8]*ma[1]*ma[15]))-(ma[8]*ma[3]*ma[13]))-(ma[12]*ma[1]*ma[11]))+(ma[12]*ma[3]*ma[9]);
 Temporary[13]:=((((ma[0]*ma[9]*ma[14])-(ma[0]*ma[10]*ma[13]))-(ma[8]*ma[1]*ma[14]))+(ma[8]*ma[2]*ma[13])+(ma[12]*ma[1]*ma[10]))-(ma[12]*ma[2]*ma[9]);
 Temporary[2]:=((((ma[1]*ma[6]*ma[15])-(ma[1]*ma[7]*ma[14]))-(ma[5]*ma[2]*ma[15]))+(ma[5]*ma[3]*ma[14])+(ma[13]*ma[2]*ma[7]))-(ma[13]*ma[3]*ma[6]);
 Temporary[6]:=((((-(ma[0]*ma[6]*ma[15]))+(ma[0]*ma[7]*ma[14])+(ma[4]*ma[2]*ma[15]))-(ma[4]*ma[3]*ma[14]))-(ma[12]*ma[2]*ma[7]))+(ma[12]*ma[3]*ma[6]);
 Temporary[10]:=((((ma[0]*ma[5]*ma[15])-(ma[0]*ma[7]*ma[13]))-(ma[4]*ma[1]*ma[15]))+(ma[4]*ma[3]*ma[13])+(ma[12]*ma[1]*ma[7]))-(ma[12]*ma[3]*ma[5]);
 Temporary[14]:=((((-(ma[0]*ma[5]*ma[14]))+(ma[0]*ma[6]*ma[13])+(ma[4]*ma[1]*ma[14]))-(ma[4]*ma[2]*ma[13]))-(ma[12]*ma[1]*ma[6]))+(ma[12]*ma[2]*ma[5]);
 Temporary[3]:=((((-(ma[1]*ma[6]*ma[11]))+(ma[1]*ma[7]*ma[10])+(ma[5]*ma[2]*ma[11]))-(ma[5]*ma[3]*ma[10]))-(ma[9]*ma[2]*ma[7]))+(ma[9]*ma[3]*ma[6]);
 Temporary[7]:=((((ma[0]*ma[6]*ma[11])-(ma[0]*ma[7]*ma[10]))-(ma[4]*ma[2]*ma[11]))+(ma[4]*ma[3]*ma[10])+(ma[8]*ma[2]*ma[7]))-(ma[8]*ma[3]*ma[6]);
 Temporary[11]:=((((-(ma[0]*ma[5]*ma[11]))+(ma[0]*ma[7]*ma[9])+(ma[4]*ma[1]*ma[11]))-(ma[4]*ma[3]*ma[9]))-(ma[8]*ma[1]*ma[7]))+(ma[8]*ma[3]*ma[5]);
 Temporary[15]:=((((ma[0]*ma[5]*ma[10])-(ma[0]*ma[6]*ma[9]))-(ma[4]*ma[1]*ma[10]))+(ma[4]*ma[2]*ma[9])+(ma[8]*ma[1]*ma[6]))-(ma[8]*ma[2]*ma[5]);
 Det:=(ma[0]*Temporary[0])+(ma[1]*Temporary[4])+(ma[2]*Temporary[8])+(ma[3]*Temporary[12]);
 if abs(Det)<>0.0 then begin
  Det:=1.0/Det;
  result[0]:=Temporary[0]*Det;
  result[1]:=Temporary[1]*Det;
  result[2]:=Temporary[2]*Det;
  result[3]:=Temporary[3]*Det;
  result[4]:=Temporary[4]*Det;
  result[5]:=Temporary[5]*Det;
  result[6]:=Temporary[6]*Det;
  result[7]:=Temporary[7]*Det;
  result[8]:=Temporary[8]*Det;
  result[9]:=Temporary[9]*Det;
  result[10]:=Temporary[10]*Det;
  result[11]:=Temporary[11]*Det;
  result[12]:=Temporary[12]*Det;
  result[13]:=Temporary[13]*Det;
  result[14]:=Temporary[14]*Det;
  result[15]:=Temporary[15]*Det;
 end else begin
  result:=ma;
 end;
end;

function MatrixTranspose(const ma:TPasGLTF.TMatrix4x4):TPasGLTF.TMatrix4x4;
begin
 result[0]:=ma[0];
 result[1]:=ma[4];
 result[2]:=ma[8];
 result[3]:=ma[12];
 result[4]:=ma[1];
 result[5]:=ma[5];
 result[6]:=ma[9];
 result[7]:=ma[13];
 result[8]:=ma[2];
 result[9]:=ma[6];
 result[10]:=ma[10];
 result[11]:=ma[14];
 result[12]:=ma[3];
 result[13]:=ma[7];
 result[14]:=ma[11];
 result[15]:=ma[15];
end;

function MatrixScale(const a:TPasGLTF.TMatrix4x4;const s:TPasGLTFFloat):TPasGLTF.TMatrix4x4;
begin
 result[0]:=a[0]*s;
 result[1]:=a[1]*s;
 result[2]:=a[2]*s;
 result[3]:=a[3]*s;
 result[4]:=a[4]*s;
 result[5]:=a[5]*s;
 result[6]:=a[6]*s;
 result[7]:=a[7]*s;
 result[8]:=a[8]*s;
 result[9]:=a[9]*s;
 result[10]:=a[10]*s;
 result[11]:=a[11]*s;
 result[12]:=a[12]*s;
 result[13]:=a[13]*s;
 result[14]:=a[14]*s;
 result[15]:=a[15]*s;
end;

function MatrixAdd(const a,b:TPasGLTF.TMatrix4x4):TPasGLTF.TMatrix4x4;
begin
 result[0]:=a[0]+b[0];
 result[1]:=a[1]+b[1];
 result[2]:=a[2]+b[2];
 result[3]:=a[3]+b[3];
 result[4]:=a[4]+b[4];
 result[5]:=a[5]+b[5];
 result[6]:=a[6]+b[6];
 result[7]:=a[7]+b[7];
 result[8]:=a[8]+b[8];
 result[9]:=a[9]+b[9];
 result[10]:=a[10]+b[10];
 result[11]:=a[11]+b[11];
 result[12]:=a[12]+b[12];
 result[13]:=a[13]+b[13];
 result[14]:=a[14]+b[14];
 result[15]:=a[15]+b[15];
end;

function MatrixLookAt(const Eye,Center,Up:TVector3):TPasGLTF.TMatrix4x4;
var RightVector,UpVector,ForwardVector:TVector3;
begin
 ForwardVector:=Vector3Normalize(Vector3Sub(Eye,Center));
 RightVector:=Vector3Normalize(Vector3Cross(Up,ForwardVector));
 UpVector:=Vector3Normalize(Vector3Cross(ForwardVector,RightVector));
 result[0]:=RightVector[0];
 result[4]:=RightVector[1];
 result[8]:=RightVector[2];
 result[12]:=-((RightVector[0]*Eye[0])+(RightVector[1]*Eye[1])+(RightVector[2]*Eye[2]));
 result[1]:=UpVector[0];
 result[5]:=UpVector[1];
 result[9]:=UpVector[2];
 result[13]:=-((UpVector[0]*Eye[0])+(UpVector[1]*Eye[1])+(UpVector[2]*Eye[2]));
 result[2]:=ForwardVector[0];
 result[6]:=ForwardVector[1];
 result[10]:=ForwardVector[2];
 result[14]:=-((ForwardVector[0]*Eye[0])+(ForwardVector[1]*Eye[1])+(ForwardVector[2]*Eye[2]));
 result[3]:=0.0;
 result[7]:=0.0;
 result[11]:=0.0;
 result[15]:=1.0;
end;

type TAABB=record
      Min:TPasGLTF.TVector3;
      Max:TPasGLTF.TVector3;
     end;

function AABBCombine(const AABB,WithAABB:TAABB):TAABB;
begin
 result.Min[0]:=Min(AABB.Min[0],WithAABB.Min[0]);
 result.Min[1]:=Min(AABB.Min[1],WithAABB.Min[1]);
 result.Min[2]:=Min(AABB.Min[2],WithAABB.Min[2]);
 result.Max[0]:=Max(AABB.Max[0],WithAABB.Max[0]);
 result.Max[1]:=Max(AABB.Max[1],WithAABB.Max[1]);
 result.Max[2]:=Max(AABB.Max[2],WithAABB.Max[2]);
end;

function AABBCombineVector3(const AABB:TAABB;v:TVector3):TAABB;
begin
 result.Min[0]:=Min(AABB.Min[0],v[0]);
 result.Min[1]:=Min(AABB.Min[1],v[1]);
 result.Min[2]:=Min(AABB.Min[2],v[2]);
 result.Max[0]:=Max(AABB.Max[0],v[0]);
 result.Max[1]:=Max(AABB.Max[1],v[1]);
 result.Max[2]:=Max(AABB.Max[2],v[2]);
end;

function AABBTransform(const DstAABB:TAABB;const Transform:TPasGLTF.TMatrix4x4):TAABB;
var i,j,k:TPasGLTFSizeInt;
    a,b:TPasGLTFFloat;
begin
 result.Min:=Vector3(Transform[12],Transform[13],Transform[14]);
 result.Max:=result.Min;
 for i:=0 to 2 do begin
  for j:=0 to 2 do begin
   k:=(j shl 2) or i;
   a:=Transform[k]*DstAABB.Min[j];
   b:=Transform[k]*DstAABB.Max[j];
   if a<b then begin
    result.Min[i]:=result.Min[i]+a;
    result.Max[i]:=result.Max[i]+b;
   end else begin
    result.Min[i]:=result.Min[i]+b;
    result.Max[i]:=result.Max[i]+a;
   end;
  end;
 end;
end;

{ TpvGLTF.TBakedMesh.TTriangle }

class function TpvGLTF.TBakedMesh.TTriangle.Create:TpvGLTF.TBakedMesh.TTriangle;
begin
 FillChar(result,SizeOf(TpvGLTF.TBakedMesh.TTriangle),#0);
end;

procedure TpvGLTF.TBakedMesh.TTriangle.Assign(const aFrom:TpvGLTF.TBakedMesh.TTriangle);
begin
 Positions:=aFrom.Positions;
 Normals:=aFrom.Normals;
 Normal:=aFrom.Normal;
 Flags:=aFrom.Flags;
 MetaFlags:=aFrom.MetaFlags;
end;

function TpvGLTF.TBakedMesh.TTriangle.RayIntersection(const aRayOrigin,aRayDirection:TpvVector3;var aTime,aU,aV:TpvScalar):boolean;
const EPSILON=1e-7;
var e0,e1,p,t,q:TpvVector3;
    Determinant,InverseDeterminant:TpvScalar;
begin
 result:=false;

 e0.x:=Positions[1].x-Positions[0].x;
 e0.y:=Positions[1].y-Positions[0].y;
 e0.z:=Positions[1].z-Positions[0].z;
 e1.x:=Positions[2].x-Positions[0].x;
 e1.y:=Positions[2].y-Positions[0].y;
 e1.z:=Positions[2].z-Positions[0].z;

 p.x:=(aRayDirection.y*e1.z)-(aRayDirection.z*e1.y);
 p.y:=(aRayDirection.z*e1.x)-(aRayDirection.x*e1.z);
 p.z:=(aRayDirection.x*e1.y)-(aRayDirection.y*e1.x);

 Determinant:=(e0.x*p.x)+(e0.y*p.y)+(e0.z*p.z);
 if Determinant<EPSILON then begin
  exit;
 end;

 InverseDeterminant:=1.0/Determinant;

 t.x:=aRayOrigin.x-Positions[0].x;
 t.y:=aRayOrigin.y-Positions[0].y;
 t.z:=aRayOrigin.z-Positions[0].z;

 aU:=((t.x*p.x)+(t.y*p.y)+(t.z*p.z))*InverseDeterminant;
 if (aU<0.0) or (aU>1.0) then begin
  exit;
 end;

 q.x:=(t.y*e0.z)-(t.z*e0.y);
 q.y:=(t.z*e0.x)-(t.x*e0.z);
 q.z:=(t.x*e0.y)-(t.y*e0.x);

 aV:=((aRayDirection.x*q.x)+(aRayDirection.y*q.y)+(aRayDirection.z*q.z))*InverseDeterminant;
 if (aV<0.0) or ((aU+aV)>1.0) then begin
  exit;
 end;

 aTime:=((e1.x*q.x)+(e1.y*q.y)+(e1.z*q.z))*InverseDeterminant;

 result:=true;
end;

{ TpvGLTF.TBakedMesh }

constructor TpvGLTF.TBakedMesh.Create;
begin
 inherited Create;
 fTriangles:=TpvGLTF.TBakedMesh.TTriangles.Create;
end;

destructor TpvGLTF.TBakedMesh.Destroy;
begin
 FreeAndNil(fTriangles);
 inherited Destroy;
end;

procedure TpvGLTF.TBakedMesh.Combine(const aWith:TBakedMesh);
begin
 fTriangles.Add(aWith.fTriangles);
end;

{ TpvGLTF. TBakedVertexIndexedMesh }

constructor TpvGLTF.TBakedVertexIndexedMesh.Create; 
begin
 inherited Create;
 fVertices:=TVertices.Create;
 fIndices:=TIndices.Create;
 fMaterials:=TIndices.Create;
 fVertexRemapHashMap:=TVertexRemapHashMap.Create(-1);
end;

destructor TpvGLTF.TBakedVertexIndexedMesh.Destroy;
begin
 FreeAndNil(fVertices);
 FreeAndNil(fIndices);
 FreeAndNil(fMaterials);
 FreeAndNil(fVertexRemapHashMap);
 inherited Destroy;
end;

procedure TpvGLTF.TBakedVertexIndexedMesh.Clear;
begin
 fVertices.Clear;
 fIndices.Clear;
 fMaterials.Clear;
 fVertexRemapHashMap.Clear;
end;

function TpvGLTF.TBakedVertexIndexedMesh.ExistOriginalVertexIndex(const aVertexIndex,aMaterial:TpvUInt32):boolean;
begin
 result:=fVertexRemapHashMap.ExistKey(TpvUInt64(aVertexIndex) or (TpvUInt64(aMaterial) shl 32));
end;

function TpvGLTF.TBakedVertexIndexedMesh.AddOriginalVertexIndex(const aVertexIndex:TpvUInt32;const aVertex:TpvGLTF.TVertex;const aMaterial:TpvUInt32;const aAddIndex:boolean):TpvUInt32;
var RemappedVertexIndex:TpvSizeInt;
begin
 RemappedVertexIndex:=fVertexRemapHashMap[TpvUInt64(aVertexIndex) or (TpvUInt64(aMaterial) shl 32)];
 if RemappedVertexIndex<0 then begin
  fVertexRemapHashMap[TpvUInt64(aVertexIndex) or (TpvUInt64(aMaterial) shl 32)]:=RemappedVertexIndex;
  RemappedVertexIndex:=fVertices.Add(aVertex);
  fMaterials.Add(aMaterial);
 end;
 if aAddIndex then begin
  fIndices.Add(RemappedVertexIndex);
 end;
 result:=RemappedVertexIndex;
end;

procedure TpvGLTF.TBakedVertexIndexedMesh.Finish;
begin
 fVertices.Finish; // Finalize the array size
 fMaterials.Finish; // Finalize the array size
 fIndices.Finish; // Finalize the array size
 fVertexRemapHashMap.Clear; // Because no more needed
end;

{ TpvGLTF }

constructor TpvGLTF.Create;
begin
 inherited Create;
 fGetURI:=DefaultGetURI;
 fRootPath:='';
 fReady:=false;
 fUploaded:=false;
 fLights:=nil;
 fAnimations:=nil;
 fMaterials:=nil;
 fMeshes:=nil;
 fSkins:=nil;
 fCameras:=nil;
 fNodes:=nil;
 fImages:=nil;
 fSamplers:=nil;
 fTextures:=nil;
 fJoints:=nil;
 fScenes:=nil;
 fScene:=-1;
 fJointVertices:=nil;
 fNodeNameHashMap:=TNodeNameHashMap.Create(-1);
 fSkinShaderStorageBufferObjects:=nil;
 fMorphTargetVertexShaderStorageBufferObjects:=nil;
 fNodeMeshPrimitiveShaderStorageBufferObjects:=nil;
 fMaterialUniformBufferObjects:=nil;
 FillChar(fLightShaderStorageBufferObject,SizeOf(TLightShaderStorageBufferObject),#0);
end;

destructor TpvGLTF.Destroy;
begin
 Unload;
 Clear;
 FreeAndNil(fNodeNameHashMap);
 inherited Destroy;
end;

procedure TpvGLTF.Clear;
begin
 if fReady then begin
  fReady:=false;
  fLights:=nil;
  fAnimations:=nil;
  fMaterials:=nil;
  fMeshes:=nil;
  fSkins:=nil;
  fCameras:=nil;
  fNodes:=nil;
  fImages:=nil;
  fSamplers:=nil;
  fTextures:=nil;
  fJoints:=nil;
  fScenes:=nil;
  fJointVertices:=nil;
  fSkinShaderStorageBufferObjects:=nil;
  fMorphTargetVertexShaderStorageBufferObjects:=nil;
  fNodeMeshPrimitiveShaderStorageBufferObjects:=nil;
  fMaterialUniformBufferObjects:=nil;
  if assigned(fLightShaderStorageBufferObject.Data) then begin
   FreeMem(fLightShaderStorageBufferObject.Data);
  end;
  FillChar(fLightShaderStorageBufferObject,SizeOf(TLightShaderStorageBufferObject),#0);
  fNodeNameHashMap.Clear;
 end;
end;

function TpvGLTF.DefaultGetURI(const aURI:TPasGLTFUTF8String):TStream;
var FileName:String;
begin
 FileName:=ExpandFileName(IncludeTrailingPathDelimiter(fRootPath)+String(TPasGLTF.ResolveURIToPath(aURI)));
 result:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite);
end;

procedure TpvGLTF.LoadFromDocument(const aDocument:TPasGLTF.TDocument);
var HasLights:boolean;
 procedure LoadLights;
 var Index:TPasGLTFSizeInt;
     ExtensionObject:TPasJSONItemObject;
     KHRLightsPunctualItem,LightsItem,LightItem,ColorItem,SpotItem:TPasJSONItem;
     KHRLightsPunctualObject,LightObject,SpotObject:TPasJSONItemObject;
     LightsArray,ColorArray:TPasJSONItemArray;
     Light:PLight;
     TypeString:TPasJSONUTF8String;
 begin
  fCountNormalShadowMaps:=0;
  fCountCubeMapShadowMaps:=0;
  if HasLights then begin
   ExtensionObject:=aDocument.Extensions;
   if assigned(ExtensionObject) then begin
    KHRLightsPunctualItem:=ExtensionObject.Properties['KHR_lights_punctual'];
    if assigned(KHRLightsPunctualItem) and (KHRLightsPunctualItem is TPasJSONItemObject) then begin
     KHRLightsPunctualObject:=TPasJSONItemObject(KHRLightsPunctualItem);
     LightsItem:=KHRLightsPunctualObject.Properties['lights'];
     if assigned(LightsItem) and (LightsItem is TPasJSONItemArray) then begin
      LightsArray:=TPasJSONItemArray(LightsItem);
      SetLength(fLights,LightsArray.Count);
      for Index:=0 to LightsArray.Count-1 do begin
       LightItem:=LightsArray.Items[Index];
       if assigned(LightItem) and (LightItem is TPasJSONItemObject) then begin
        LightObject:=TPasJSONItemObject(LightItem);
        Light:=@fLights[Index];
        Light^.Name:='';
        Light^.Node:=-1;
        Light^.Type_:=TLightDataType.None;
        Light^.ShadowMapIndex:=-1;
        Light^.Intensity:=1.0;
        Light^.Range:=0.0;
        Light^.InnerConeAngle:=0.0;
        Light^.OuterConeAngle:=pi*0.25;
        Light^.Color[0]:=1.0;
        Light^.Color[1]:=1.0;
        Light^.Color[2]:=1.0;
        Light^.CastShadows:=false;
        if assigned(LightItem) and (LightItem is TPasJSONItemObject) then begin
         LightObject:=TPasJSONItemObject(LightItem);
         Light^.Name:=TPasJSON.GetString(LightObject.Properties['name'],'');
         TypeString:=TPasJSON.GetString(LightObject.Properties['type'],'');
         if pos('_noshadows',String(Light^.Name))>0 then begin
          Light^.CastShadows:=false;
         end else begin
          Light^.CastShadows:=TPasJSON.GetBoolean(LightObject.Properties['castShadows'],true);
         end;
         if TypeString='directional' then begin
          Light^.Type_:=TLightDataType.Directional;
          if Light^.CastShadows then begin
           Light^.ShadowMapIndex:=fCountNormalShadowMaps;
           inc(fCountNormalShadowMaps);
          end;
         end else if TypeString='point' then begin
          Light^.Type_:=TLightDataType.Point;
          if Light^.CastShadows then begin
           Light^.ShadowMapIndex:=fCountCubeMapShadowMaps;
           inc(fCountCubeMapShadowMaps);
          end;
         end else if TypeString='spot' then begin
          Light^.Type_:=TLightDataType.Spot;
          if Light^.CastShadows then begin
           Light^.ShadowMapIndex:=fCountNormalShadowMaps;
           inc(fCountNormalShadowMaps);
          end;
         end else begin
          Light^.Type_:=TLightDataType.None;
          if Light^.CastShadows then begin
           Light^.ShadowMapIndex:=fCountNormalShadowMaps;
           inc(fCountNormalShadowMaps);
          end;
         end;
         Light^.Intensity:=TPasJSON.GetNumber(LightObject.Properties['intensity'],Light^.Intensity);
         Light^.Range:=TPasJSON.GetNumber(LightObject.Properties['range'],Light^.Range);
         SpotItem:=LightObject.Properties['spot'];
         if assigned(SpotItem) and (SpotItem is TPasJSONItemObject) then begin
          SpotObject:=TPasJSONItemObject(SpotItem);
          Light^.InnerConeAngle:=TPasJSON.GetNumber(SpotObject.Properties['innerConeAngle'],Light^.InnerConeAngle);
          Light^.OuterConeAngle:=TPasJSON.GetNumber(SpotObject.Properties['outerConeAngle'],Light^.OuterConeAngle);
         end;
         ColorItem:=LightObject.Properties['color'];
         if assigned(ColorItem) and (ColorItem is TPasJSONItemArray) then begin
          ColorArray:=TPasJSONItemArray(ColorItem);
          if ColorArray.Count>0 then begin
           Light^.Color[0]:=TPasJSON.GetNumber(ColorArray.Items[0],Light^.Color[0]);
          end;
          if ColorArray.Count>1 then begin
           Light^.Color[1]:=TPasJSON.GetNumber(ColorArray.Items[1],Light^.Color[1]);
          end;
          if ColorArray.Count>2 then begin
           Light^.Color[2]:=TPasJSON.GetNumber(ColorArray.Items[2],Light^.Color[2]);
          end;
         end;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 procedure LoadAnimations;
 var Index,ChannelIndex,ValueIndex:TPasGLTFSizeInt;
     SourceAnimation:TPasGLTF.TAnimation;
     DestinationAnimation:PAnimation;
     SourceAnimationChannel:TPasGLTF.TAnimation.TChannel;
     SourceAnimationSampler:TPasGLTF.TAnimation.TSampler;
     DestinationAnimationChannel:TAnimation.PChannel;
 begin

  SetLength(fAnimations,aDocument.Animations.Count);

  for Index:=0 to aDocument.Animations.Count-1 do begin

   SourceAnimation:=aDocument.Animations.Items[Index];

   DestinationAnimation:=@fAnimations[Index];

   DestinationAnimation^.Name:=SourceAnimation.Name;

   SetLength(DestinationAnimation^.Channels,SourceAnimation.Channels.Count);

   for ChannelIndex:=0 to SourceAnimation.Channels.Count-1 do begin

    SourceAnimationChannel:=SourceAnimation.Channels[ChannelIndex];

    DestinationAnimationChannel:=@DestinationAnimation^.Channels[ChannelIndex];

    DestinationAnimationChannel^.Last:=-1;

    DestinationAnimationChannel^.Node:=SourceAnimationChannel.Target.Node;

    if SourceAnimationChannel.Target.Path='translation' then begin
     DestinationAnimationChannel^.Target:=TAnimation.TChannel.TTarget.Translation;
    end else if SourceAnimationChannel.Target.Path='rotation' then begin
     DestinationAnimationChannel^.Target:=TAnimation.TChannel.TTarget.Rotation;
    end else if SourceAnimationChannel.Target.Path='scale' then begin
     DestinationAnimationChannel^.Target:=TAnimation.TChannel.TTarget.Scale;
    end else if SourceAnimationChannel.Target.Path='weights' then begin
     DestinationAnimationChannel^.Target:=TAnimation.TChannel.TTarget.Weights;
    end else begin
     raise EpvGLTF.Create('Non-supported animation channel target path "'+String(SourceAnimationChannel.Target.Path)+'"');
    end;

    if (SourceAnimationChannel.Sampler>=0) and (SourceAnimationChannel.Sampler<SourceAnimation.Samplers.Count) then begin
     SourceAnimationSampler:=SourceAnimation.Samplers[SourceAnimationChannel.Sampler];
     case SourceAnimationSampler.Interpolation of
      TPasGLTF.TAnimation.TSampler.TType.Linear:begin
       DestinationAnimationChannel^.Interpolation:=TAnimation.TChannel.TInterpolation.Linear;
      end;
      TPasGLTF.TAnimation.TSampler.TType.Step:begin
       DestinationAnimationChannel^.Interpolation:=TAnimation.TChannel.TInterpolation.Step;
      end;
      TPasGLTF.TAnimation.TSampler.TType.CubicSpline:begin
       DestinationAnimationChannel^.Interpolation:=TAnimation.TChannel.TInterpolation.CubicSpline;
      end;
      else begin
       raise EpvGLTF.Create('Non-supported animation sampler interpolation method type');
      end;
     end;
     DestinationAnimationChannel^.InputTimeArray:=aDocument.Accessors[SourceAnimationSampler.Input].DecodeAsFloatArray(false);
     case DestinationAnimationChannel^.Target of
      TAnimation.TChannel.TTarget.Translation,
      TAnimation.TChannel.TTarget.Scale:begin
       DestinationAnimationChannel^.OutputVector3Array:=aDocument.Accessors[SourceAnimationSampler.Output].DecodeAsVector3Array(false);
      end;
      TAnimation.TChannel.TTarget.Rotation:begin
       DestinationAnimationChannel^.OutputVector4Array:=aDocument.Accessors[SourceAnimationSampler.Output].DecodeAsVector4Array(false);
       for ValueIndex:=0 to length(DestinationAnimationChannel^.OutputVector4Array)-1 do begin
        DestinationAnimationChannel^.OutputVector4Array[ValueIndex]:=Vector4Normalize(DestinationAnimationChannel^.OutputVector4Array[ValueIndex]);
       end;
      end;
      TAnimation.TChannel.TTarget.Weights:begin
       DestinationAnimationChannel^.OutputScalarArray:=aDocument.Accessors[SourceAnimationSampler.Output].DecodeAsFloatArray(false);
      end;
     end;
    end else begin
     raise EpvGLTF.Create('Non-existent sampler');
    end;

   end;

  end;

 end;
 procedure LoadMaterials;
  procedure LoadTextureTransform(const aExtensionsItem:TPasJSONItem;var aTexture:TMaterial.TTexture);
  var JSONItem:TPasJSONItem;
      JSONObject:TPasJSONItemObject;
  begin
   aTexture.TextureTransform.Active:=false;
   aTexture.TextureTransform.Offset[0]:=0.0;
   aTexture.TextureTransform.Offset[1]:=0.0;
   aTexture.TextureTransform.Rotation:=0.0;
   aTexture.TextureTransform.Scale[0]:=1.0;
   aTexture.TextureTransform.Scale[1]:=1.0;
   if assigned(aExtensionsItem) and (aExtensionsItem is TPasJSONItemObject) then begin
    JSONItem:=TPasJSONItemObject(aExtensionsItem).Properties['KHR_texture_transform'];
    if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
     JSONObject:=TPasJSONItemObject(JSONItem);
     aTexture.TextureTransform.Active:=true;
     aTexture.TexCoord:=TPasJSON.GetInt64(JSONObject.Properties['texCoord'],aTexture.TexCoord);
     JSONItem:=JSONObject.Properties['offset'];
     if assigned(JSONItem) and (JSONItem is TPasJSONItemArray) and (TPasJSONItemArray(JSONItem).Count=2) then begin
      aTexture.TextureTransform.Offset[0]:=TPasJSON.GetNumber(TPasJSONItemArray(JSONItem).Items[0],aTexture.TextureTransform.Offset[0]);
      aTexture.TextureTransform.Offset[1]:=TPasJSON.GetNumber(TPasJSONItemArray(JSONItem).Items[1],aTexture.TextureTransform.Offset[1]);
     end;
     aTexture.TextureTransform.Rotation:=TPasJSON.GetNumber(JSONObject.Properties['rotation'],aTexture.TextureTransform.Rotation);
     JSONItem:=JSONObject.Properties['scale'];
     if assigned(JSONItem) and (JSONItem is TPasJSONItemArray) and (TPasJSONItemArray(JSONItem).Count=2) then begin
      aTexture.TextureTransform.Scale[0]:=TPasJSON.GetNumber(TPasJSONItemArray(JSONItem).Items[0],aTexture.TextureTransform.Scale[0]);
      aTexture.TextureTransform.Scale[1]:=TPasJSON.GetNumber(TPasJSONItemArray(JSONItem).Items[1],aTexture.TextureTransform.Scale[1]);
     end;
    end;
   end;
  end;
  function ConvertTextureTransformToMatrix(const aTextureTransform:TMaterial.TTextureTransform):TPasGLTF.TMatrix4x4;
  begin
   if aTextureTransform.Active then begin
    result:=MatrixMul(MatrixMul(MatrixFrom2DRotation(-aTextureTransform.Rotation),
                                MatrixFromScale(Vector3(aTextureTransform.Scale[0],aTextureTransform.Scale[1],1.0))),
                      MatrixFromTranslation(Vector3(aTextureTransform.Offset[0],aTextureTransform.Offset[1],0.0)));
   end else begin
    result:=TPasGLTF.TDefaults.IdentityMatrix4x4;
   end;
  end;
 var Index:TPasGLTFSizeInt;
     SourceMaterial:TPasGLTF.TMaterial;
     DestinationMaterial:PMaterial;
     JSONItem:TPasJSONItem;
     JSONObject:TPasJSONItemObject;
     UniformBufferObjectData:TMaterial.PUniformBufferObjectData;
 begin

  SetLength(fMaterials,aDocument.Materials.Count);

  for Index:=0 to aDocument.Materials.Count-1 do begin

   SourceMaterial:=aDocument.Materials.Items[Index];

   DestinationMaterial:=@fMaterials[Index];

   begin
    DestinationMaterial^.Name:=SourceMaterial.Name;
    DestinationMaterial^.AlphaCutOff:=SourceMaterial.AlphaCutOff;
    DestinationMaterial^.AlphaMode:=SourceMaterial.AlphaMode;
    DestinationMaterial^.DoubleSided:=SourceMaterial.DoubleSided;
    DestinationMaterial^.EmissiveFactor[0]:=SourceMaterial.EmissiveFactor[0];
    DestinationMaterial^.EmissiveFactor[1]:=SourceMaterial.EmissiveFactor[1];
    DestinationMaterial^.EmissiveFactor[2]:=SourceMaterial.EmissiveFactor[2];
    DestinationMaterial^.EmissiveFactor[3]:=1.0;
    DestinationMaterial^.EmissiveTexture.Index:=SourceMaterial.EmissiveTexture.Index;
    DestinationMaterial^.EmissiveTexture.TexCoord:=SourceMaterial.EmissiveTexture.TexCoord;
    LoadTextureTransform(SourceMaterial.EmissiveTexture.Extensions,DestinationMaterial^.EmissiveTexture);
    DestinationMaterial^.NormalTexture.Index:=SourceMaterial.NormalTexture.Index;
    DestinationMaterial^.NormalTexture.TexCoord:=SourceMaterial.NormalTexture.TexCoord;
    DestinationMaterial^.NormalTextureScale:=SourceMaterial.NormalTexture.Scale;
    LoadTextureTransform(SourceMaterial.NormalTexture.Extensions,DestinationMaterial^.NormalTexture);
    DestinationMaterial^.OcclusionTexture.Index:=SourceMaterial.OcclusionTexture.Index;
    DestinationMaterial^.OcclusionTexture.TexCoord:=SourceMaterial.OcclusionTexture.TexCoord;
    DestinationMaterial^.OcclusionTextureStrength:=SourceMaterial.OcclusionTexture.Strength;
    LoadTextureTransform(SourceMaterial.OcclusionTexture.Extensions,DestinationMaterial^.OcclusionTexture);
   end;

   begin
    DestinationMaterial^.PBRMetallicRoughness.BaseColorFactor:=SourceMaterial.PBRMetallicRoughness.BaseColorFactor;
    DestinationMaterial^.PBRMetallicRoughness.BaseColorTexture.Index:=SourceMaterial.PBRMetallicRoughness.BaseColorTexture.Index;
    DestinationMaterial^.PBRMetallicRoughness.BaseColorTexture.TexCoord:=SourceMaterial.PBRMetallicRoughness.BaseColorTexture.TexCoord;
    LoadTextureTransform(SourceMaterial.PBRMetallicRoughness.BaseColorTexture.Extensions,DestinationMaterial^.PBRMetallicRoughness.BaseColorTexture);
    DestinationMaterial^.PBRMetallicRoughness.RoughnessFactor:=SourceMaterial.PBRMetallicRoughness.RoughnessFactor;
    DestinationMaterial^.PBRMetallicRoughness.MetallicFactor:=SourceMaterial.PBRMetallicRoughness.MetallicFactor;
    DestinationMaterial^.PBRMetallicRoughness.MetallicRoughnessTexture.Index:=SourceMaterial.PBRMetallicRoughness.MetallicRoughnessTexture.Index;
    DestinationMaterial^.PBRMetallicRoughness.MetallicRoughnessTexture.TexCoord:=SourceMaterial.PBRMetallicRoughness.MetallicRoughnessTexture.TexCoord;
    LoadTextureTransform(SourceMaterial.PBRMetallicRoughness.MetallicRoughnessTexture.Extensions,DestinationMaterial^.PBRMetallicRoughness.MetallicRoughnessTexture);
   end;

   JSONItem:=SourceMaterial.Extensions.Properties['KHR_materials_unlit'];
   if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
    DestinationMaterial.ShadingModel:=TMaterial.TShadingModel.Unlit;
   end else begin
    JSONItem:=SourceMaterial.Extensions.Properties['KHR_materials_pbrSpecularGlossiness'];
    if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
     JSONObject:=TPasJSONItemObject(JSONItem);
     DestinationMaterial.ShadingModel:=TMaterial.TShadingModel.PBRSpecularGlossiness;
     DestinationMaterial^.PBRSpecularGlossiness.DiffuseFactor:=TPasGLTF.TDefaults.IdentityVector4;
     DestinationMaterial^.PBRSpecularGlossiness.DiffuseTexture.Index:=-1;
     DestinationMaterial^.PBRSpecularGlossiness.DiffuseTexture.TexCoord:=0;
     DestinationMaterial^.PBRSpecularGlossiness.GlossinessFactor:=TPasGLTF.TDefaults.IdentityScalar;
     DestinationMaterial^.PBRSpecularGlossiness.SpecularFactor:=TPasGLTF.TDefaults.IdentityVector3;
     DestinationMaterial^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index:=-1;
     DestinationMaterial^.PBRSpecularGlossiness.SpecularGlossinessTexture.TexCoord:=0;
     begin
      JSONItem:=JSONObject.Properties['diffuseFactor'];
      if assigned(JSONItem) and (JSONItem is TPasJSONItemArray) and (TPasJSONItemArray(JSONItem).Count=4) then begin
       DestinationMaterial^.PBRSpecularGlossiness.DiffuseFactor[0]:=TPasJSON.GetNumber(TPasJSONItemArray(JSONItem).Items[0],DestinationMaterial^.PBRSpecularGlossiness.DiffuseFactor[0]);
       DestinationMaterial^.PBRSpecularGlossiness.DiffuseFactor[1]:=TPasJSON.GetNumber(TPasJSONItemArray(JSONItem).Items[1],DestinationMaterial^.PBRSpecularGlossiness.DiffuseFactor[1]);
       DestinationMaterial^.PBRSpecularGlossiness.DiffuseFactor[2]:=TPasJSON.GetNumber(TPasJSONItemArray(JSONItem).Items[2],DestinationMaterial^.PBRSpecularGlossiness.DiffuseFactor[2]);
       DestinationMaterial^.PBRSpecularGlossiness.DiffuseFactor[3]:=TPasJSON.GetNumber(TPasJSONItemArray(JSONItem).Items[3],DestinationMaterial^.PBRSpecularGlossiness.DiffuseFactor[3]);
      end;
      JSONItem:=JSONObject.Properties['diffuseTexture'];
      if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
       DestinationMaterial^.PBRSpecularGlossiness.DiffuseTexture.Index:=TPasJSON.GetInt64(TPasJSONItemObject(JSONItem).Properties['index'],DestinationMaterial^.PBRSpecularGlossiness.DiffuseTexture.Index);
       DestinationMaterial^.PBRSpecularGlossiness.DiffuseTexture.TexCoord:=TPasJSON.GetInt64(TPasJSONItemObject(JSONItem).Properties['texCoord'],DestinationMaterial^.PBRSpecularGlossiness.DiffuseTexture.TexCoord);
       LoadTextureTransform(TPasJSONItemObject(JSONItem).Properties['extensions'],DestinationMaterial^.PBRSpecularGlossiness.DiffuseTexture);
      end;
      DestinationMaterial^.PBRSpecularGlossiness.GlossinessFactor:=TPasJSON.GetNumber(JSONObject.Properties['glossinessFactor'],DestinationMaterial^.PBRSpecularGlossiness.GlossinessFactor);
      JSONItem:=JSONObject.Properties['specularFactor'];
      if assigned(JSONItem) and (JSONItem is TPasJSONItemArray) and (TPasJSONItemArray(JSONItem).Count=3) then begin
       DestinationMaterial^.PBRSpecularGlossiness.SpecularFactor[0]:=TPasJSON.GetNumber(TPasJSONItemArray(JSONItem).Items[0],DestinationMaterial^.PBRSpecularGlossiness.SpecularFactor[0]);
       DestinationMaterial^.PBRSpecularGlossiness.SpecularFactor[1]:=TPasJSON.GetNumber(TPasJSONItemArray(JSONItem).Items[1],DestinationMaterial^.PBRSpecularGlossiness.SpecularFactor[1]);
       DestinationMaterial^.PBRSpecularGlossiness.SpecularFactor[2]:=TPasJSON.GetNumber(TPasJSONItemArray(JSONItem).Items[2],DestinationMaterial^.PBRSpecularGlossiness.SpecularFactor[2]);
      end;
      JSONItem:=JSONObject.Properties['specularGlossinessTexture'];
      if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
       DestinationMaterial^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index:=TPasJSON.GetInt64(TPasJSONItemObject(JSONItem).Properties['index'],DestinationMaterial^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index);
       DestinationMaterial^.PBRSpecularGlossiness.SpecularGlossinessTexture.TexCoord:=TPasJSON.GetInt64(TPasJSONItemObject(JSONItem).Properties['texCoord'],DestinationMaterial^.PBRSpecularGlossiness.SpecularGlossinessTexture.TexCoord);
       LoadTextureTransform(TPasJSONItemObject(JSONItem).Properties['extensions'],DestinationMaterial^.PBRSpecularGlossiness.SpecularGlossinessTexture);
      end;
     end;
    end else begin
     DestinationMaterial.ShadingModel:=TMaterial.TShadingModel.PBRMetallicRoughness;
    end;
   end;

   begin
    DestinationMaterial^.PBRSheen.Active:=false;
    DestinationMaterial^.PBRSheen.IntensityFactor:=1.0;
    DestinationMaterial^.PBRSheen.ColorFactor[0]:=1.0;
    DestinationMaterial^.PBRSheen.ColorFactor[1]:=1.0;
    DestinationMaterial^.PBRSheen.ColorFactor[2]:=1.0;
    DestinationMaterial^.PBRSheen.ColorIntensityTexture.Index:=-1;
    DestinationMaterial^.PBRSheen.ColorIntensityTexture.TexCoord:=0;
    JSONItem:=SourceMaterial.Extensions.Properties['KHR_materials_sheen'];
    if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
     JSONObject:=TPasJSONItemObject(JSONItem);
     DestinationMaterial^.PBRSheen.Active:=true;
     DestinationMaterial^.PBRSheen.IntensityFactor:=TPasJSON.GetNumber(JSONObject.Properties['intensityFactor'],TPasJSON.GetNumber(JSONObject.Properties['sheenFactor'],1.0));
     JSONItem:=JSONObject.Properties['colorFactor'];
     if not assigned(JSONItem) then begin
      JSONItem:=JSONObject.Properties['sheenColor'];
     end;
     if assigned(JSONItem) and (JSONItem is TPasJSONItemArray) and (TPasJSONItemArray(JSONItem).Count=3) then begin
      DestinationMaterial^.PBRSheen.ColorFactor[0]:=TPasJSON.GetNumber(TPasJSONItemArray(JSONItem).Items[0],1.0);
      DestinationMaterial^.PBRSheen.ColorFactor[1]:=TPasJSON.GetNumber(TPasJSONItemArray(JSONItem).Items[1],1.0);
      DestinationMaterial^.PBRSheen.ColorFactor[2]:=TPasJSON.GetNumber(TPasJSONItemArray(JSONItem).Items[2],1.0);
     end;
     JSONItem:=JSONObject.Properties['colorIntensityTexture'];
     if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
      DestinationMaterial^.PBRSheen.ColorIntensityTexture.Index:=TPasJSON.GetInt64(TPasJSONItemObject(JSONItem).Properties['index'],-1);
      DestinationMaterial^.PBRSheen.ColorIntensityTexture.TexCoord:=TPasJSON.GetInt64(TPasJSONItemObject(JSONItem).Properties['texCoord'],0);
      LoadTextureTransform(TPasJSONItemObject(JSONItem).Properties['extensions'],DestinationMaterial^.PBRSheen.ColorIntensityTexture);
     end;
    end;
   end;

   begin
    DestinationMaterial^.PBRClearCoat.Active:=false;
    DestinationMaterial^.PBRClearCoat.Factor:=0.0;
    DestinationMaterial^.PBRClearCoat.Texture.Index:=-1;
    DestinationMaterial^.PBRClearCoat.Texture.TexCoord:=0;
    DestinationMaterial^.PBRClearCoat.RoughnessFactor:=0.0;
    DestinationMaterial^.PBRClearCoat.RoughnessTexture.Index:=-1;
    DestinationMaterial^.PBRClearCoat.RoughnessTexture.TexCoord:=0;
    DestinationMaterial^.PBRClearCoat.NormalTexture.Index:=-1;
    DestinationMaterial^.PBRClearCoat.NormalTexture.TexCoord:=0;
    JSONItem:=SourceMaterial.Extensions.Properties['KHR_materials_clearcoat'];
    if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
     JSONObject:=TPasJSONItemObject(JSONItem);
     DestinationMaterial^.PBRClearCoat.Active:=true;
     DestinationMaterial^.PBRClearCoat.Factor:=TPasJSON.GetNumber(JSONObject.Properties['intensityFactor'],TPasJSON.GetNumber(JSONObject.Properties['clearcoatFactor'],DestinationMaterial^.PBRClearCoat.Factor));
     JSONItem:=JSONObject.Properties['clearcoatTexture'];
     if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
      DestinationMaterial^.PBRClearCoat.Texture.Index:=TPasJSON.GetInt64(TPasJSONItemObject(JSONItem).Properties['index'],-1);
      DestinationMaterial^.PBRClearCoat.Texture.TexCoord:=TPasJSON.GetInt64(TPasJSONItemObject(JSONItem).Properties['texCoord'],0);
      LoadTextureTransform(TPasJSONItemObject(JSONItem).Properties['extensions'],DestinationMaterial^.PBRClearCoat.Texture);
     end;
     DestinationMaterial^.PBRClearCoat.RoughnessFactor:=TPasJSON.GetNumber(JSONObject.Properties['intensityFactor'],TPasJSON.GetNumber(JSONObject.Properties['clearcoatRoughnessFactor'],DestinationMaterial^.PBRClearCoat.RoughnessFactor));
     JSONItem:=JSONObject.Properties['clearcoatRoughnessTexture'];
     if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
      DestinationMaterial^.PBRClearCoat.RoughnessTexture.Index:=TPasJSON.GetInt64(TPasJSONItemObject(JSONItem).Properties['index'],-1);
      DestinationMaterial^.PBRClearCoat.RoughnessTexture.TexCoord:=TPasJSON.GetInt64(TPasJSONItemObject(JSONItem).Properties['texCoord'],0);
      LoadTextureTransform(TPasJSONItemObject(JSONItem).Properties['extensions'],DestinationMaterial^.PBRClearCoat.RoughnessTexture);
     end;
     JSONItem:=JSONObject.Properties['clearcoatNormalTexture'];
     if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
      DestinationMaterial^.PBRClearCoat.NormalTexture.Index:=TPasJSON.GetInt64(TPasJSONItemObject(JSONItem).Properties['index'],-1);
      DestinationMaterial^.PBRClearCoat.NormalTexture.TexCoord:=TPasJSON.GetInt64(TPasJSONItemObject(JSONItem).Properties['texCoord'],0);
      LoadTextureTransform(TPasJSONItemObject(JSONItem).Properties['extensions'],DestinationMaterial^.PBRClearCoat.NormalTexture);
     end;
    end;
   end;

   JSONItem:=SourceMaterial.Extensions.Properties['KHR_materials_emissive_strength'];
   if assigned(JSONItem) and (JSONItem is TPasJSONItemObject) then begin
    JSONObject:=TPasJSONItemObject(JSONItem);
    DestinationMaterial^.EmissiveFactor[3]:=TPasJSON.GetNumber(JSONObject.Properties['emissiveStrength'],1.0);
   end;

   begin
    UniformBufferObjectData:=@DestinationMaterial^.UniformBufferObjectData;
    UniformBufferObjectData^.Flags:=0;
    case SourceMaterial.AlphaMode of
     TPasGLTF.TMaterial.TAlphaMode.Opaque:begin
      UniformBufferObjectData^.AlphaCutOff:=0.0;
     end;
     TPasGLTF.TMaterial.TAlphaMode.Mask:begin
      UniformBufferObjectData^.AlphaCutOff:=SourceMaterial.AlphaCutOff;
     end;
     TPasGLTF.TMaterial.TAlphaMode.Blend:begin
      UniformBufferObjectData^.AlphaCutOff:=0.0;
      UniformBufferObjectData^.Flags:=UniformBufferObjectData^.Flags or (1 shl 4);
     end;
     else begin
      Assert(false);
     end;
    end;
    if SourceMaterial.DoubleSided then begin
     UniformBufferObjectData^.Flags:=UniformBufferObjectData^.Flags or (1 shl 5);
    end;
    UniformBufferObjectData^.Textures0:=$ffffffff;
    UniformBufferObjectData^.Textures1:=$ffffffff;
    UniformBufferObjectData^.TextureTransforms:=EmptyMaterialUniformBufferObjectData.TextureTransforms;
    case DestinationMaterial^.ShadingModel of
     TMaterial.TShadingModel.PBRMetallicRoughness:begin
      UniformBufferObjectData^.Flags:=UniformBufferObjectData^.Flags or ((0 and $f) shl 0);
      if (SourceMaterial.PBRMetallicRoughness.BaseColorTexture.Index>=0) and (SourceMaterial.PBRMetallicRoughness.BaseColorTexture.Index<length(fTextures)) then begin
       UniformBufferObjectData^.Textures0:=(UniformBufferObjectData^.Textures0 and not ($f shl (0 shl 2))) or ((SourceMaterial.PBRMetallicRoughness.BaseColorTexture.TexCoord and $f) shl (0 shl 2));
       UniformBufferObjectData^.TextureTransforms[0]:=ConvertTextureTransformToMatrix(DestinationMaterial^.PBRMetallicRoughness.BaseColorTexture.TextureTransform);
      end;
      if (SourceMaterial.PBRMetallicRoughness.MetallicRoughnessTexture.Index>=0) and (SourceMaterial.PBRMetallicRoughness.MetallicRoughnessTexture.Index<length(fTextures)) then begin
       UniformBufferObjectData^.Textures0:=(UniformBufferObjectData^.Textures0 and not ($f shl (1 shl 2))) or ((SourceMaterial.PBRMetallicRoughness.MetallicRoughnessTexture.TexCoord and $f) shl (1 shl 2));
       UniformBufferObjectData^.TextureTransforms[1]:=ConvertTextureTransformToMatrix(DestinationMaterial^.PBRMetallicRoughness.MetallicRoughnessTexture.TextureTransform);
      end;
      UniformBufferObjectData^.BaseColorFactor:=SourceMaterial.PBRMetallicRoughness.BaseColorFactor;
      UniformBufferObjectData^.MetallicRoughnessNormalScaleOcclusionStrengthFactor[0]:=SourceMaterial.PBRMetallicRoughness.MetallicFactor;
      UniformBufferObjectData^.MetallicRoughnessNormalScaleOcclusionStrengthFactor[1]:=SourceMaterial.PBRMetallicRoughness.RoughnessFactor;
      UniformBufferObjectData^.MetallicRoughnessNormalScaleOcclusionStrengthFactor[2]:=SourceMaterial.NormalTexture.Scale;
      UniformBufferObjectData^.MetallicRoughnessNormalScaleOcclusionStrengthFactor[3]:=SourceMaterial.OcclusionTexture.Strength;
     end;
     TMaterial.TShadingModel.PBRSpecularGlossiness:begin
      UniformBufferObjectData^.Flags:=UniformBufferObjectData^.Flags or ((1 and $f) shl 0);
      if (DestinationMaterial^.PBRSpecularGlossiness.DiffuseTexture.Index>=0) and (DestinationMaterial^.PBRSpecularGlossiness.DiffuseTexture.Index<length(fTextures)) then begin
       UniformBufferObjectData^.Textures0:=(UniformBufferObjectData^.Textures0 and not ($f shl (0 shl 2))) or ((DestinationMaterial^.PBRSpecularGlossiness.DiffuseTexture.TexCoord and $f) shl (0 shl 2));
       UniformBufferObjectData^.TextureTransforms[0]:=ConvertTextureTransformToMatrix(DestinationMaterial^.PBRSpecularGlossiness.DiffuseTexture.TextureTransform);
      end;
      if (DestinationMaterial^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index>=0) and (DestinationMaterial^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index<length(fTextures)) then begin
       UniformBufferObjectData^.Textures0:=(UniformBufferObjectData^.Textures0 and not ($f shl (1 shl 2))) or ((DestinationMaterial^.PBRSpecularGlossiness.SpecularGlossinessTexture.TexCoord and $f) shl (1 shl 2));
       UniformBufferObjectData^.TextureTransforms[1]:=ConvertTextureTransformToMatrix(DestinationMaterial^.PBRSpecularGlossiness.SpecularGlossinessTexture.TextureTransform);
      end;
      UniformBufferObjectData^.BaseColorFactor:=DestinationMaterial^.PBRSpecularGlossiness.DiffuseFactor;
      UniformBufferObjectData^.MetallicRoughnessNormalScaleOcclusionStrengthFactor[0]:=1.0;
      UniformBufferObjectData^.MetallicRoughnessNormalScaleOcclusionStrengthFactor[1]:=DestinationMaterial^.PBRSpecularGlossiness.GlossinessFactor;
      UniformBufferObjectData^.MetallicRoughnessNormalScaleOcclusionStrengthFactor[2]:=SourceMaterial.NormalTexture.Scale;
      UniformBufferObjectData^.MetallicRoughnessNormalScaleOcclusionStrengthFactor[3]:=SourceMaterial.OcclusionTexture.Strength;
      UniformBufferObjectData^.SpecularFactor[0]:=DestinationMaterial^.PBRSpecularGlossiness.SpecularFactor[0];
      UniformBufferObjectData^.SpecularFactor[1]:=DestinationMaterial^.PBRSpecularGlossiness.SpecularFactor[1];
      UniformBufferObjectData^.SpecularFactor[2]:=DestinationMaterial^.PBRSpecularGlossiness.SpecularFactor[2];
      UniformBufferObjectData^.SpecularFactor[3]:=0.0;
     end;
     TMaterial.TShadingModel.Unlit:begin
      UniformBufferObjectData^.Flags:=UniformBufferObjectData^.Flags or ((2 and $f) shl 0);
      if (SourceMaterial.PBRMetallicRoughness.BaseColorTexture.Index>=0) and (SourceMaterial.PBRMetallicRoughness.BaseColorTexture.Index<length(fTextures)) then begin
       UniformBufferObjectData^.Textures0:=(UniformBufferObjectData^.Textures0 and not ($f shl (0 shl 2))) or ((SourceMaterial.PBRMetallicRoughness.BaseColorTexture.TexCoord and $f) shl (0 shl 2));
       UniformBufferObjectData^.TextureTransforms[0]:=ConvertTextureTransformToMatrix(DestinationMaterial^.PBRMetallicRoughness.BaseColorTexture.TextureTransform);
      end;
      UniformBufferObjectData^.BaseColorFactor:=SourceMaterial.PBRMetallicRoughness.BaseColorFactor;
     end;
     else begin
      Assert(false);
     end;
    end;
    if (SourceMaterial.NormalTexture.Index>=0) and (SourceMaterial.NormalTexture.Index<length(fTextures)) then begin
     UniformBufferObjectData^.Textures0:=(UniformBufferObjectData^.Textures0 and not ($f shl (2 shl 2))) or ((SourceMaterial.NormalTexture.TexCoord and $f) shl (2 shl 2));
     UniformBufferObjectData^.TextureTransforms[2]:=ConvertTextureTransformToMatrix(DestinationMaterial^.NormalTexture.TextureTransform);
    end;
    if (SourceMaterial.OcclusionTexture.Index>=0) and (SourceMaterial.OcclusionTexture.Index<length(fTextures)) then begin
     UniformBufferObjectData^.Textures0:=(UniformBufferObjectData^.Textures0 and not ($f shl (3 shl 2))) or ((SourceMaterial.OcclusionTexture.TexCoord and $f) shl (3 shl 2));
     UniformBufferObjectData^.TextureTransforms[3]:=ConvertTextureTransformToMatrix(DestinationMaterial^.OcclusionTexture.TextureTransform);
    end;
    if (SourceMaterial.EmissiveTexture.Index>=0) and (SourceMaterial.EmissiveTexture.Index<length(fTextures)) then begin
     UniformBufferObjectData^.Textures0:=(UniformBufferObjectData^.Textures0 and not ($f shl (4 shl 2))) or ((SourceMaterial.EmissiveTexture.TexCoord and $f) shl (4 shl 2));
     UniformBufferObjectData^.TextureTransforms[4]:=ConvertTextureTransformToMatrix(DestinationMaterial^.EmissiveTexture.TextureTransform);
    end;
    UniformBufferObjectData^.EmissiveFactor[0]:=DestinationMaterial^.EmissiveFactor[0];
    UniformBufferObjectData^.EmissiveFactor[1]:=DestinationMaterial^.EmissiveFactor[1];
    UniformBufferObjectData^.EmissiveFactor[2]:=DestinationMaterial^.EmissiveFactor[2];
    UniformBufferObjectData^.EmissiveFactor[3]:=DestinationMaterial^.EmissiveFactor[3];

    if DestinationMaterial^.PBRSheen.Active then begin
     UniformBufferObjectData^.Flags:=UniformBufferObjectData^.Flags or (1 shl 6);
     UniformBufferObjectData^.SheenColorFactorSheenIntensityFactor[0]:=DestinationMaterial^.PBRSheen.ColorFactor[0];
     UniformBufferObjectData^.SheenColorFactorSheenIntensityFactor[1]:=DestinationMaterial^.PBRSheen.ColorFactor[1];
     UniformBufferObjectData^.SheenColorFactorSheenIntensityFactor[2]:=DestinationMaterial^.PBRSheen.ColorFactor[2];
     UniformBufferObjectData^.SheenColorFactorSheenIntensityFactor[3]:=DestinationMaterial^.PBRSheen.IntensityFactor;
     if (DestinationMaterial^.PBRSheen.ColorIntensityTexture.Index>=0) and (DestinationMaterial^.PBRSheen.ColorIntensityTexture.Index<length(fTextures)) then begin
      UniformBufferObjectData^.Textures0:=(UniformBufferObjectData^.Textures0 and not ($f shl (5 shl 2))) or ((DestinationMaterial^.PBRSheen.ColorIntensityTexture.TexCoord and $f) shl (5 shl 2));
      UniformBufferObjectData^.TextureTransforms[5]:=ConvertTextureTransformToMatrix(DestinationMaterial^.PBRSheen.ColorIntensityTexture.TextureTransform);
     end;
    end;

    if DestinationMaterial^.PBRClearCoat.Active then begin
     UniformBufferObjectData^.Flags:=UniformBufferObjectData^.Flags or (1 shl 7);
     UniformBufferObjectData^.ClearcoatFactorClearcoatRoughnessFactor[0]:=DestinationMaterial^.PBRClearCoat.Factor;
     UniformBufferObjectData^.ClearcoatFactorClearcoatRoughnessFactor[1]:=DestinationMaterial^.PBRClearCoat.RoughnessFactor;
     if (DestinationMaterial^.PBRClearCoat.Texture.Index>=0) and (DestinationMaterial^.PBRClearCoat.Texture.Index<length(fTextures)) then begin
      UniformBufferObjectData^.Textures0:=(UniformBufferObjectData^.Textures0 and not ($f shl (6 shl 2))) or ((DestinationMaterial^.PBRClearCoat.Texture.TexCoord and $f) shl (6 shl 2));
      UniformBufferObjectData^.TextureTransforms[6]:=ConvertTextureTransformToMatrix(DestinationMaterial^.PBRClearCoat.Texture.TextureTransform);
     end;
     if (DestinationMaterial^.PBRClearCoat.RoughnessTexture.Index>=0) and (DestinationMaterial^.PBRClearCoat.RoughnessTexture.Index<length(fTextures)) then begin
      UniformBufferObjectData^.Textures0:=(UniformBufferObjectData^.Textures0 and not ($f shl (7 shl 2))) or ((DestinationMaterial^.PBRClearCoat.RoughnessTexture.TexCoord and $f) shl (7 shl 2));
      UniformBufferObjectData^.TextureTransforms[7]:=ConvertTextureTransformToMatrix(DestinationMaterial^.PBRClearCoat.RoughnessTexture.TextureTransform);
     end;
     if (DestinationMaterial^.PBRClearCoat.NormalTexture.Index>=0) and (DestinationMaterial^.PBRClearCoat.NormalTexture.Index<length(fTextures)) then begin
      UniformBufferObjectData^.Textures1:=(UniformBufferObjectData^.Textures1 and not ($f shl (0 shl 2))) or ((DestinationMaterial^.PBRClearCoat.NormalTexture.TexCoord and $f) shl (0 shl 2));
      UniformBufferObjectData^.TextureTransforms[8]:=ConvertTextureTransformToMatrix(DestinationMaterial^.PBRClearCoat.NormalTexture.TextureTransform);
     end;
    end;

   end;

  end;

 end;
 procedure LoadMeshes;
 var Index,
     PrimitiveIndex,
     AccessorIndex,
     IndexIndex,
     VertexIndex,
     TargetIndex,
     WeightIndex,
     JointIndex,
     OtherJointIndex,
     OldCount,
     MaxCountTargets:TPasGLTFSizeInt;
     SourceMesh:TPasGLTF.TMesh;
     SourceMeshPrimitive:TPasGLTF.TMesh.TPrimitive;
     SourceMeshPrimitiveTarget:TPasGLTF.TAttributes;
     DestinationMesh:PMesh;
     DestinationMeshPrimitive:TMesh.PPrimitive;
     DestinationMeshPrimitiveTarget:TMesh.TPrimitive.PTarget;
     DestinationMeshPrimitiveTargetVertex:TMesh.TPrimitive.TTarget.PTargetVertex;
     TemporaryPositions,
     TemporaryNormals,
     TemporaryBitangents,
     TemporaryTargetTangents:TPasGLTF.TVector3DynamicArray;
     TemporaryTangents,
     TemporaryColor0,
     TemporaryWeights0,
     TemporaryWeights1:TPasGLTF.TVector4DynamicArray;
     TemporaryJoints0,
     TemporaryJoints1:TPasGLTF.TUInt32Vector4DynamicArray;
     TemporaryTexCoord0,
     TemporaryTexCoord1:TPasGLTF.TVector2DynamicArray;
     TemporaryIndices,
     TemporaryTriangleIndices:TPasGLTFUInt32DynamicArray;
     Normal,Tangent,Bitangent,p1p0,p2p0:TVector3;
     p0,p1,p2:PVector3;
     t1t0,t2t0:TVector2;
     t0,t1,t2:PVector2;
     Vertex:PVertex;
     Area:TPasGLTFFloat;
     DoNeedCalculateTangents:boolean;
 begin

  SetLength(fMeshes,aDocument.Meshes.Count);

  for Index:=0 to aDocument.Meshes.Count-1 do begin

   SourceMesh:=aDocument.Meshes.Items[Index];

   DestinationMesh:=@fMeshes[Index];

   DestinationMesh^.Name:=SourceMesh.Name;

   SetLength(DestinationMesh^.Primitives,SourceMesh.Primitives.Count);

   DestinationMesh^.BoundingBox:=EmptyBoundingBox;

//DestinationMesh^.JointWeights:=nil;

   MaxCountTargets:=0;

   for PrimitiveIndex:=0 to SourceMesh.Primitives.Count-1 do begin

    SourceMeshPrimitive:=SourceMesh.Primitives.Items[PrimitiveIndex];

    DestinationMeshPrimitive:=@DestinationMesh^.Primitives[PrimitiveIndex];

    DestinationMeshPrimitive^.Material:=SourceMeshPrimitive.Material;

    begin
     // Load accessor data
     begin
      AccessorIndex:=SourceMeshPrimitive.Attributes['POSITION'];
      if AccessorIndex>=0 then begin
       TemporaryPositions:=aDocument.Accessors[AccessorIndex].DecodeAsVector3Array(true);
       for VertexIndex:=0 to length(TemporaryPositions)-1 do begin
        DestinationMesh^.BoundingBox.Min[0]:=Min(DestinationMesh^.BoundingBox.Min[0],TemporaryPositions[VertexIndex,0]);
        DestinationMesh^.BoundingBox.Min[1]:=Min(DestinationMesh^.BoundingBox.Min[1],TemporaryPositions[VertexIndex,1]);
        DestinationMesh^.BoundingBox.Min[2]:=Min(DestinationMesh^.BoundingBox.Min[2],TemporaryPositions[VertexIndex,2]);
        DestinationMesh^.BoundingBox.Max[0]:=Max(DestinationMesh^.BoundingBox.Max[0],TemporaryPositions[VertexIndex,0]);
        DestinationMesh^.BoundingBox.Max[1]:=Max(DestinationMesh^.BoundingBox.Max[1],TemporaryPositions[VertexIndex,1]);
        DestinationMesh^.BoundingBox.Max[2]:=Max(DestinationMesh^.BoundingBox.Max[2],TemporaryPositions[VertexIndex,2]);
       end;
      end else begin
       raise EpvGLTF.Create('Missing position data');
      end;
     end;
     begin
      AccessorIndex:=SourceMeshPrimitive.Attributes['NORMAL'];
      if AccessorIndex>=0 then begin
       TemporaryNormals:=aDocument.Accessors[AccessorIndex].DecodeAsVector3Array(true);
      end else begin
       TemporaryNormals:=nil;
      end;
     end;
     begin
      AccessorIndex:=SourceMeshPrimitive.Attributes['TANGENT'];
      if AccessorIndex>=0 then begin
       TemporaryTangents:=aDocument.Accessors[AccessorIndex].DecodeAsVector4Array(true);
      end else begin
       TemporaryTangents:=nil;
      end;
     end;
     begin
      AccessorIndex:=SourceMeshPrimitive.Attributes['TEXCOORD_0'];
      if AccessorIndex>=0 then begin
       TemporaryTexCoord0:=aDocument.Accessors[AccessorIndex].DecodeAsVector2Array(true);
      end else begin
       TemporaryTexCoord0:=nil;
      end;
     end;
     begin
      AccessorIndex:=SourceMeshPrimitive.Attributes['TEXCOORD_1'];
      if AccessorIndex>=0 then begin
       TemporaryTexCoord1:=aDocument.Accessors[AccessorIndex].DecodeAsVector2Array(true);
      end else begin
       TemporaryTexCoord1:=nil;
      end;
     end;
     begin
      AccessorIndex:=SourceMeshPrimitive.Attributes['COLOR_0'];
      if AccessorIndex>=0 then begin
       TemporaryColor0:=aDocument.Accessors[AccessorIndex].DecodeAsColorArray(true);
      end else begin
       TemporaryColor0:=nil;
      end;
     end;
     begin
      AccessorIndex:=SourceMeshPrimitive.Attributes['JOINTS_0'];
      if AccessorIndex>=0 then begin
       TemporaryJoints0:=aDocument.Accessors[AccessorIndex].DecodeAsUInt32Vector4Array(true);
      end else begin
       TemporaryJoints0:=nil;
      end;
     end;
     begin
      AccessorIndex:=SourceMeshPrimitive.Attributes['JOINTS_1'];
      if AccessorIndex>=0 then begin
       TemporaryJoints1:=aDocument.Accessors[AccessorIndex].DecodeAsUInt32Vector4Array(true);
      end else begin
       TemporaryJoints1:=nil;
      end;
     end;
     begin
      AccessorIndex:=SourceMeshPrimitive.Attributes['WEIGHTS_0'];
      if AccessorIndex>=0 then begin
       TemporaryWeights0:=aDocument.Accessors[AccessorIndex].DecodeAsVector4Array(true);
      end else begin
       TemporaryWeights0:=nil;
      end;
     end;
     begin
      AccessorIndex:=SourceMeshPrimitive.Attributes['WEIGHTS_1'];
      if AccessorIndex>=0 then begin
       TemporaryWeights1:=aDocument.Accessors[AccessorIndex].DecodeAsVector4Array(true);
      end else begin
       TemporaryWeights1:=nil;
      end;
     end;
    end;

    begin
     // load or generate vertex indices
     if SourceMeshPrimitive.Indices>=0 then begin
      TemporaryIndices:=aDocument.Accessors[SourceMeshPrimitive.Indices].DecodeAsUInt32Array(false);
     end else begin
      SetLength(TemporaryIndices,length(TemporaryPositions));
      for IndexIndex:=0 to length(TemporaryIndices)-1 do begin
       TemporaryIndices[IndexIndex]:=IndexIndex;
      end;
     end;
     case SourceMeshPrimitive.Mode of
      TPasGLTF.TMesh.TPrimitive.TMode.Triangles:begin
       TemporaryTriangleIndices:=TemporaryIndices;
      end;
      TPasGLTF.TMesh.TPrimitive.TMode.TriangleStrip:begin
       TemporaryTriangleIndices:=nil;
       SetLength(TemporaryTriangleIndices,(length(TemporaryIndices)-2)*3);
       for IndexIndex:=0 to length(TemporaryIndices)-3 do begin
        if (IndexIndex and 1)<>0 then begin
         TemporaryTriangleIndices[(IndexIndex*3)+0]:=TemporaryIndices[IndexIndex+0];
         TemporaryTriangleIndices[(IndexIndex*3)+1]:=TemporaryIndices[IndexIndex+1];
         TemporaryTriangleIndices[(IndexIndex*3)+2]:=TemporaryIndices[IndexIndex+2];
        end else begin
         TemporaryTriangleIndices[(IndexIndex*3)+0]:=TemporaryIndices[IndexIndex+0];
         TemporaryTriangleIndices[(IndexIndex*3)+1]:=TemporaryIndices[IndexIndex+2];
         TemporaryTriangleIndices[(IndexIndex*3)+2]:=TemporaryIndices[IndexIndex+1];
        end;
       end;
      end;
      TPasGLTF.TMesh.TPrimitive.TMode.TriangleFan:begin
       TemporaryTriangleIndices:=nil;
       SetLength(TemporaryTriangleIndices,(length(TemporaryIndices)-2)*3);
       for IndexIndex:=2 to length(TemporaryIndices)-1 do begin
        TemporaryTriangleIndices[((IndexIndex-1)*3)+0]:=TemporaryIndices[0];
        TemporaryTriangleIndices[((IndexIndex-1)*3)+1]:=TemporaryIndices[IndexIndex-1];
        TemporaryTriangleIndices[((IndexIndex-1)*3)+2]:=TemporaryIndices[IndexIndex];
       end;
      end;
      else begin
       TemporaryTriangleIndices:=nil;
      end;
     end;
    end;

    begin
     // Generate missing data
     if length(TemporaryNormals)<>length(TemporaryPositions) then begin
      SetLength(TemporaryNormals,length(TemporaryPositions));
      for VertexIndex:=0 to length(TemporaryNormals)-1 do begin
       TemporaryNormals[VertexIndex]:=TPasGLTF.TDefaults.NullVector3;
      end;
      if length(TemporaryTriangleIndices)>0 then begin
       IndexIndex:=0;
       while (IndexIndex+2)<length(TemporaryTriangleIndices) do begin
        p0:=@TemporaryPositions[TemporaryTriangleIndices[IndexIndex+0]];
        p1:=@TemporaryPositions[TemporaryTriangleIndices[IndexIndex+1]];
        p2:=@TemporaryPositions[TemporaryTriangleIndices[IndexIndex+2]];
        Normal:=Vector3Cross(Vector3Sub(p1^,p0^),Vector3Sub(p2^,p0^)); // non-normalized weighted normal
        TemporaryNormals[TemporaryTriangleIndices[IndexIndex+0]]:=Vector3Add(TemporaryNormals[TemporaryTriangleIndices[IndexIndex+0]],Normal);
        TemporaryNormals[TemporaryTriangleIndices[IndexIndex+1]]:=Vector3Add(TemporaryNormals[TemporaryTriangleIndices[IndexIndex+1]],Normal);
        TemporaryNormals[TemporaryTriangleIndices[IndexIndex+2]]:=Vector3Add(TemporaryNormals[TemporaryTriangleIndices[IndexIndex+2]],Normal);
        inc(IndexIndex,3);
       end;
       for VertexIndex:=0 to length(TemporaryNormals)-1 do begin
        TemporaryNormals[VertexIndex]:=Vector3Normalize(TemporaryNormals[VertexIndex]);
       end;
      end;
     end;
     if length(TemporaryTexCoord0)<>length(TemporaryPositions) then begin
      SetLength(TemporaryTexCoord0,length(TemporaryPositions));
      for VertexIndex:=0 to length(TemporaryNormals)-1 do begin
       TemporaryTexCoord0[VertexIndex]:=PVector2(@TPasGLTF.TDefaults.NullVector3)^;
      end;
     end;
     if length(TemporaryTangents)<>length(TemporaryPositions) then begin
      SetLength(TemporaryTangents,length(TemporaryPositions));
      SetLength(TemporaryBitangents,length(TemporaryPositions));
      for VertexIndex:=0 to length(TemporaryTangents)-1 do begin
       PVector3(@TemporaryTangents[VertexIndex])^:=TPasGLTF.TDefaults.NullVector3;
       TemporaryBitangents[VertexIndex]:=TPasGLTF.TDefaults.NullVector3;
      end;
      if length(TemporaryTriangleIndices)>0 then begin
       IndexIndex:=0;
       while (IndexIndex+2)<length(TemporaryTriangleIndices) do begin
        p0:=@TemporaryPositions[TemporaryTriangleIndices[IndexIndex+0]];
        p1:=@TemporaryPositions[TemporaryTriangleIndices[IndexIndex+1]];
        p2:=@TemporaryPositions[TemporaryTriangleIndices[IndexIndex+2]];
        t0:=@TemporaryTexCoord0[TemporaryTriangleIndices[IndexIndex+0]];
        t1:=@TemporaryTexCoord0[TemporaryTriangleIndices[IndexIndex+1]];
        t2:=@TemporaryTexCoord0[TemporaryTriangleIndices[IndexIndex+2]];
        p1p0:=Vector3Sub(p1^,p0^);
        p2p0:=Vector3Sub(p2^,p0^);
        t1t0:=Vector2Sub(t1^,t0^);
        t2t0:=Vector2Sub(t2^,t0^);
        Normal:=Vector3Normalize(Vector3Cross(p1p0,p2p0));
        if Vector3Dot(TemporaryNormals[TemporaryTriangleIndices[IndexIndex+0]],Normal)<0.0 then begin
         Normal:=Vector3Neg(Normal);
        end;
{$if true}
        Area:=(t2t0[0]*t1t0[1])-(t1t0[0]*t2t0[1]);
        if IsZero(Area) then begin
         Tangent[0]:=0.0;
         Tangent[1]:=1.0;
         Tangent[2]:=0.0;
         Bitangent[0]:=1.0;
         Bitangent[1]:=0.0;
         Bitangent[2]:=0.0;
        end else begin
         Tangent[0]:=((t1t0[1]*p2p0[0])-(t2t0[1]*p1p0[0]))/Area;
         Tangent[1]:=((t1t0[1]*p2p0[1])-(t2t0[1]*p1p0[1]))/Area;
         Tangent[2]:=((t1t0[1]*p2p0[2])-(t2t0[1]*p1p0[2]))/Area;
         Bitangent[0]:=((t1t0[0]*p2p0[0])-(t2t0[0]*p1p0[0]))/Area;
         Bitangent[1]:=((t1t0[0]*p2p0[1])-(t2t0[0]*p1p0[1]))/Area;
         Bitangent[2]:=((t1t0[0]*p2p0[2])-(t2t0[0]*p1p0[2]))/Area;
        end;
        if Vector3Dot(Vector3Cross(Tangent,Bitangent),Normal)<0.0 then begin
         Tangent:=Vector3Neg(Tangent);
         Bitangent:=Vector3Neg(Bitangent);
        end;
{$else}
        Tangent[0]:=(t1t0[1]*p2p0[0])-(t2t0[1]*p1p0[0]);
        Tangent[1]:=(t1t0[1]*p2p0[1])-(t2t0[1]*p1p0[1]);
        Tangent[2]:=(t1t0[1]*p2p0[2])-(t2t0[1]*p1p0[2]);
        Bitangent[0]:=(t1t0[0]*p2p0[0])-(t2t0[0]*p1p0[0]);
        Bitangent[1]:=(t1t0[0]*p2p0[1])-(t2t0[0]*p1p0[1]);
        Bitangent[2]:=(t1t0[0]*p2p0[2])-(t2t0[0]*p1p0[2]);
        if Vector3Dot(Vector3Cross(Tangent,Bitangent),Normal)<0.0 then begin
         Tangent:=Vector3Neg(Tangent);
         Bitangent:=Vector3Neg(Bitangent);
        end;
{$ifend}
        PVector3(@TemporaryTangents[TemporaryTriangleIndices[IndexIndex+0]])^:=Vector3Add(PVector3(@TemporaryTangents[TemporaryTriangleIndices[IndexIndex+0]])^,Tangent);
        PVector3(@TemporaryTangents[TemporaryTriangleIndices[IndexIndex+1]])^:=Vector3Add(PVector3(@TemporaryTangents[TemporaryTriangleIndices[IndexIndex+1]])^,Tangent);
        PVector3(@TemporaryTangents[TemporaryTriangleIndices[IndexIndex+2]])^:=Vector3Add(PVector3(@TemporaryTangents[TemporaryTriangleIndices[IndexIndex+2]])^,Tangent);
        TemporaryBitangents[TemporaryTriangleIndices[IndexIndex+0]]:=Vector3Add(TemporaryBitangents[TemporaryTriangleIndices[IndexIndex+0]],Bitangent);
        TemporaryBitangents[TemporaryTriangleIndices[IndexIndex+1]]:=Vector3Add(TemporaryBitangents[TemporaryTriangleIndices[IndexIndex+1]],Bitangent);
        TemporaryBitangents[TemporaryTriangleIndices[IndexIndex+2]]:=Vector3Add(TemporaryBitangents[TemporaryTriangleIndices[IndexIndex+2]],Bitangent);
        inc(IndexIndex,3);
       end;
       for VertexIndex:=0 to length(TemporaryTangents)-1 do begin
        Normal:=TemporaryNormals[VertexIndex];
        Tangent:=Vector3Normalize(PVector3(@TemporaryTangents[VertexIndex])^);
        Tangent:=Vector3Normalize(Vector3Sub(Tangent,Vector3Scale(Normal,Vector3Dot(Tangent,Normal))));
        Bitangent:=Vector3Normalize(TemporaryBitangents[VertexIndex]);
        Bitangent:=Vector3Normalize(Vector3Sub(Bitangent,Vector3Scale(Normal,Vector3Dot(Bitangent,Normal))));
        PVector3(@TemporaryTangents[VertexIndex])^:=Tangent;
        if Vector3Dot(Vector3Cross(TemporaryNormals[VertexIndex],Tangent),Bitangent)<0.0 then begin
         TemporaryTangents[VertexIndex,3]:=-1.0;
        end else begin
         TemporaryTangents[VertexIndex,3]:=1.0;
        end;
       end;
      end;
     end;
    end;

    begin
     // Primitive mode
     case SourceMeshPrimitive.Mode of
      TPasGLTF.TMesh.TPrimitive.TMode.Points:begin
       DestinationMeshPrimitive^.PrimitiveMode:=GL_POINTS;
      end;
      TPasGLTF.TMesh.TPrimitive.TMode.Lines:begin
       DestinationMeshPrimitive^.PrimitiveMode:=GL_LINES;
      end;
      TPasGLTF.TMesh.TPrimitive.TMode.LineLoop:begin
       DestinationMeshPrimitive^.PrimitiveMode:=GL_LINE_LOOP;
      end;
      TPasGLTF.TMesh.TPrimitive.TMode.LineStrip:begin
       DestinationMeshPrimitive^.PrimitiveMode:=GL_LINE_STRIP;
      end;
      TPasGLTF.TMesh.TPrimitive.TMode.Triangles:begin
       DestinationMeshPrimitive^.PrimitiveMode:=GL_TRIANGLES;
      end;
      TPasGLTF.TMesh.TPrimitive.TMode.TriangleStrip:begin
       DestinationMeshPrimitive^.PrimitiveMode:=GL_TRIANGLE_STRIP;
      end;
      TPasGLTF.TMesh.TPrimitive.TMode.TriangleFan:begin
       DestinationMeshPrimitive^.PrimitiveMode:=GL_TRIANGLE_FAN;
      end;
      else begin
       raise EpvGLTF.Create('Invalid primitive mode');
      end;
     end;
    end;

    begin
     // Generate vertex array buffer
     SetLength(DestinationMeshPrimitive^.Vertices,length(TemporaryPositions));
     for VertexIndex:=0 to length(TemporaryPositions)-1 do begin
      Vertex:=@DestinationMeshPrimitive^.Vertices[VertexIndex];
      FillChar(Vertex^,SizeOf(TVertex),#0);
      Vertex^.Position:=TemporaryPositions[VertexIndex];
      if VertexIndex<length(TemporaryNormals) then begin
       Vertex^.Normal:=TemporaryNormals[VertexIndex];
      end;
      if VertexIndex<length(TemporaryTangents) then begin
       Vertex^.Tangent:=TemporaryTangents[VertexIndex];
      end;
      if VertexIndex<length(TemporaryTexCoord0) then begin
       Vertex^.TexCoord0:=TemporaryTexCoord0[VertexIndex];
      end;
      if VertexIndex<length(TemporaryTexCoord1) then begin
       Vertex^.TexCoord1:=TemporaryTexCoord1[VertexIndex];
      end;
      if VertexIndex<length(TemporaryColor0) then begin
       Vertex^.Color0:=TemporaryColor0[VertexIndex];
      end else begin
       Vertex^.Color0:=TPasGLTF.TDefaults.IdentityVector4;
      end;
      if VertexIndex<length(TemporaryJoints0) then begin
       Vertex^.Joints0:=TemporaryJoints0[VertexIndex];
      end;
      if VertexIndex<length(TemporaryJoints1) then begin
       Vertex^.Joints1:=TemporaryJoints1[VertexIndex];
      end;
      if VertexIndex<length(TemporaryWeights0) then begin
       Vertex^.Weights0:=TemporaryWeights0[VertexIndex];
      end;
      if VertexIndex<length(TemporaryWeights1) then begin
       Vertex^.Weights1:=TemporaryWeights1[VertexIndex];
      end;
      Vertex^.VertexIndex:=VertexIndex;
{     for WeightIndex:=0 to 3 do begin
       if Vertex^.Weights0[WeightIndex]>0 then begin
        JointIndex:=Vertex^.Joints0[WeightIndex];
        OldCount:=length(DestinationMesh^.JointWeights);
        if OldCount<=JointIndex then begin
         SetLength(DestinationMesh^.JointWeights,(JointIndex+1)*2);
         for OtherJointIndex:=OldCount to length(DestinationMesh^.JointWeights)-1 do begin
          DestinationMesh^.JointWeights[OtherJointIndex]:=0.0;
         end;
        end;
        DestinationMesh^.JointWeights[JointIndex]:=Max(DestinationMesh^.JointWeights[JointIndex],Vertex^.Weights0[WeightIndex]);
       end;
       if Vertex^.Weights1[WeightIndex]>0 then begin
        JointIndex:=Vertex^.Joints1[WeightIndex];
        OldCount:=length(DestinationMesh^.JointWeights);
        if OldCount<=JointIndex then begin
         SetLength(DestinationMesh^.JointWeights,(JointIndex+1)*2);
         for OtherJointIndex:=OldCount to length(DestinationMesh^.JointWeights)-1 do begin
          DestinationMesh^.JointWeights[OtherJointIndex]:=0.0;
         end;
        end;
        DestinationMesh^.JointWeights[JointIndex]:=Max(DestinationMesh^.JointWeights[JointIndex],Vertex^.Weights1[WeightIndex]);
       end;
      end;}
     end;
    end;

    begin
     // Generate vertex index array buffer
     DestinationMeshPrimitive^.Indices:=copy(TemporaryIndices);
    end;

    begin

     // Load morph target data

     SetLength(DestinationMeshPrimitive^.Targets,SourceMeshPrimitive.Targets.Count);

     MaxCountTargets:=Max(MaxCountTargets,length(DestinationMeshPrimitive^.Targets));

     for TargetIndex:=0 to length(DestinationMeshPrimitive^.Targets)-1 do begin

      SourceMeshPrimitiveTarget:=SourceMeshPrimitive.Targets[TargetIndex];

      DestinationMeshPrimitiveTarget:=@DestinationMeshPrimitive^.Targets[TargetIndex];

      AccessorIndex:=SourceMeshPrimitiveTarget['POSITION'];
      if AccessorIndex>=0 then begin
       TemporaryPositions:=aDocument.Accessors[AccessorIndex].DecodeAsVector3Array(true);
       if length(TemporaryPositions)<>length(DestinationMeshPrimitive^.Vertices) then begin
        raise EpvGLTF.Create('Vertex count mismatch');
       end;
      end else begin
       SetLength(TemporaryPositions,length(DestinationMeshPrimitive^.Vertices));
       for VertexIndex:=0 to length(TemporaryPositions)-1 do begin
        TemporaryPositions[VertexIndex]:=TPasGLTF.TDefaults.NullVector3;
       end;
      end;

      AccessorIndex:=SourceMeshPrimitiveTarget['NORMAL'];
      if AccessorIndex>=0 then begin
       TemporaryNormals:=aDocument.Accessors[AccessorIndex].DecodeAsVector3Array(true);
       if length(TemporaryNormals)<>length(DestinationMeshPrimitive^.Vertices) then begin
        raise EpvGLTF.Create('Vertex count mismatch');
       end;
      end else begin
       SetLength(TemporaryNormals,length(DestinationMeshPrimitive^.Vertices));
       for VertexIndex:=0 to length(TemporaryNormals)-1 do begin
        TemporaryNormals[VertexIndex]:=TPasGLTF.TDefaults.NullVector3;
       end;
      end;

      AccessorIndex:=SourceMeshPrimitiveTarget['TANGENT'];
      if AccessorIndex>=0 then begin
       TemporaryTargetTangents:=aDocument.Accessors[AccessorIndex].DecodeAsVector3Array(true);
       if length(TemporaryTargetTangents)<>length(DestinationMeshPrimitive^.Vertices) then begin
        raise EpvGLTF.Create('Vertex count mismatch');
       end;
       DoNeedCalculateTangents:=false;
      end else begin
       SetLength(TemporaryTargetTangents,length(DestinationMeshPrimitive^.Vertices));
       for VertexIndex:=0 to length(TemporaryTargetTangents)-1 do begin
        TemporaryTargetTangents[VertexIndex]:=TPasGLTF.TDefaults.NullVector3;
       end;
       DoNeedCalculateTangents:=true;
      end;

      // Construct morph target vertex array
      SetLength(DestinationMeshPrimitiveTarget^.Vertices,length(DestinationMeshPrimitive^.Vertices));
      for VertexIndex:=0 to length(DestinationMeshPrimitiveTarget^.Vertices)-1 do begin
       DestinationMeshPrimitiveTargetVertex:=@DestinationMeshPrimitiveTarget^.Vertices[VertexIndex];
       DestinationMeshPrimitiveTargetVertex^.Position:=TemporaryPositions[VertexIndex];
       DestinationMeshPrimitiveTargetVertex^.Normal:=TemporaryNormals[VertexIndex];
       DestinationMeshPrimitiveTargetVertex^.Tangent:=TemporaryTargetTangents[VertexIndex];
      end;

      if DoNeedCalculateTangents then begin
       SetLength(TemporaryTangents,length(TemporaryPositions));
       SetLength(TemporaryBitangents,length(TemporaryPositions));
       for VertexIndex:=0 to length(TemporaryTangents)-1 do begin
        PVector3(@TemporaryTangents[VertexIndex])^:=TPasGLTF.TDefaults.NullVector3;
        TemporaryBitangents[VertexIndex]:=TPasGLTF.TDefaults.NullVector3;
       end;
       if length(TemporaryTriangleIndices)>0 then begin
        for VertexIndex:=0 to length(TemporaryTangents)-1 do begin
         DestinationMeshPrimitiveTargetVertex:=@DestinationMeshPrimitiveTarget^.Vertices[VertexIndex];
         TemporaryPositions[VertexIndex,0]:=DestinationMeshPrimitive^.Vertices[VertexIndex].Position[0]+DestinationMeshPrimitiveTargetVertex^.Position[0];
         TemporaryPositions[VertexIndex,1]:=DestinationMeshPrimitive^.Vertices[VertexIndex].Position[1]+DestinationMeshPrimitiveTargetVertex^.Position[1];
         TemporaryPositions[VertexIndex,2]:=DestinationMeshPrimitive^.Vertices[VertexIndex].Position[2]+DestinationMeshPrimitiveTargetVertex^.Position[2];
         TemporaryNormals[VertexIndex,0]:=DestinationMeshPrimitive^.Vertices[VertexIndex].Normal[0]+DestinationMeshPrimitiveTargetVertex^.Normal[0];
         TemporaryNormals[VertexIndex,1]:=DestinationMeshPrimitive^.Vertices[VertexIndex].Normal[1]+DestinationMeshPrimitiveTargetVertex^.Normal[1];
         TemporaryNormals[VertexIndex,2]:=DestinationMeshPrimitive^.Vertices[VertexIndex].Normal[2]+DestinationMeshPrimitiveTargetVertex^.Normal[2];
        end;
        IndexIndex:=0;
        while (IndexIndex+2)<length(TemporaryTriangleIndices) do begin
         p0:=@TemporaryPositions[TemporaryTriangleIndices[IndexIndex+0]];
         p1:=@TemporaryPositions[TemporaryTriangleIndices[IndexIndex+1]];
         p2:=@TemporaryPositions[TemporaryTriangleIndices[IndexIndex+2]];
         t0:=@TemporaryTexCoord0[TemporaryTriangleIndices[IndexIndex+0]];
         t1:=@TemporaryTexCoord0[TemporaryTriangleIndices[IndexIndex+1]];
         t2:=@TemporaryTexCoord0[TemporaryTriangleIndices[IndexIndex+2]];
         p1p0:=Vector3Sub(p1^,p0^);
         p2p0:=Vector3Sub(p2^,p0^);
         t1t0:=Vector2Sub(t1^,t0^);
         t2t0:=Vector2Sub(t2^,t0^);
         Normal:=Vector3Normalize(Vector3Cross(p1p0,p2p0));
         if Vector3Dot(TemporaryNormals[TemporaryTriangleIndices[IndexIndex+0]],Normal)<0.0 then begin
          Normal:=Vector3Neg(Normal);
         end;
{$if true}
         Area:=(t2t0[0]*t1t0[1])-(t1t0[0]*t2t0[1]);
         if IsZero(Area) then begin
          Tangent[0]:=0.0;
          Tangent[1]:=1.0;
          Tangent[2]:=0.0;
          Bitangent[0]:=1.0;
          Bitangent[1]:=0.0;
          Bitangent[2]:=0.0;
         end else begin
          Tangent[0]:=((t1t0[1]*p2p0[0])-(t2t0[1]*p1p0[0]))/Area;
          Tangent[1]:=((t1t0[1]*p2p0[1])-(t2t0[1]*p1p0[1]))/Area;
          Tangent[2]:=((t1t0[1]*p2p0[2])-(t2t0[1]*p1p0[2]))/Area;
          Bitangent[0]:=((t1t0[0]*p2p0[0])-(t2t0[0]*p1p0[0]))/Area;
          Bitangent[1]:=((t1t0[0]*p2p0[1])-(t2t0[0]*p1p0[1]))/Area;
          Bitangent[2]:=((t1t0[0]*p2p0[2])-(t2t0[0]*p1p0[2]))/Area;
         end;
         if Vector3Dot(Vector3Cross(Tangent,Bitangent),Normal)<0.0 then begin
          Tangent:=Vector3Neg(Tangent);
          Bitangent:=Vector3Neg(Bitangent);
         end;
{$else}
         Tangent[0]:=(t1t0[1]*p2p0[0])-(t2t0[1]*p1p0[0]);
         Tangent[1]:=(t1t0[1]*p2p0[1])-(t2t0[1]*p1p0[1]);
         Tangent[2]:=(t1t0[1]*p2p0[2])-(t2t0[1]*p1p0[2]);
         Bitangent[0]:=(t1t0[0]*p2p0[0])-(t2t0[0]*p1p0[0]);
         Bitangent[1]:=(t1t0[0]*p2p0[1])-(t2t0[0]*p1p0[1]);
         Bitangent[2]:=(t1t0[0]*p2p0[2])-(t2t0[0]*p1p0[2]);
         if Vector3Dot(Vector3Cross(Tangent,Bitangent),Normal)<0.0 then begin
          Tangent:=Vector3Neg(Tangent);
          Bitangent:=Vector3Neg(Bitangent);
         end;
{$ifend}
         PVector3(@TemporaryTangents[TemporaryTriangleIndices[IndexIndex+0]])^:=Vector3Add(PVector3(@TemporaryTangents[TemporaryTriangleIndices[IndexIndex+0]])^,Tangent);
         PVector3(@TemporaryTangents[TemporaryTriangleIndices[IndexIndex+1]])^:=Vector3Add(PVector3(@TemporaryTangents[TemporaryTriangleIndices[IndexIndex+1]])^,Tangent);
         PVector3(@TemporaryTangents[TemporaryTriangleIndices[IndexIndex+2]])^:=Vector3Add(PVector3(@TemporaryTangents[TemporaryTriangleIndices[IndexIndex+2]])^,Tangent);
         TemporaryBitangents[TemporaryTriangleIndices[IndexIndex+0]]:=Vector3Add(TemporaryBitangents[TemporaryTriangleIndices[IndexIndex+0]],Bitangent);
         TemporaryBitangents[TemporaryTriangleIndices[IndexIndex+1]]:=Vector3Add(TemporaryBitangents[TemporaryTriangleIndices[IndexIndex+1]],Bitangent);
         TemporaryBitangents[TemporaryTriangleIndices[IndexIndex+2]]:=Vector3Add(TemporaryBitangents[TemporaryTriangleIndices[IndexIndex+2]],Bitangent);
         inc(IndexIndex,3);
        end;
        for VertexIndex:=0 to length(TemporaryTangents)-1 do begin
         Normal:=TemporaryNormals[VertexIndex];
         Tangent:=Vector3Normalize(PVector3(@TemporaryTangents[VertexIndex])^);
         Tangent:=Vector3Normalize(Vector3Sub(Tangent,Vector3Scale(Normal,Vector3Dot(Tangent,Normal))));
         Bitangent:=Vector3Normalize(TemporaryBitangents[VertexIndex]);
         Bitangent:=Vector3Normalize(Vector3Sub(Bitangent,Vector3Scale(Normal,Vector3Dot(Bitangent,Normal))));
         PVector3(@TemporaryTangents[VertexIndex])^:=Tangent;
         if Vector3Dot(Vector3Cross(TemporaryNormals[VertexIndex],Tangent),Bitangent)<0.0 then begin
          TemporaryTangents[VertexIndex,3]:=-1.0;
         end else begin
          TemporaryTangents[VertexIndex,3]:=1.0;
         end;
        end;
       end;
       SetLength(DestinationMeshPrimitiveTarget^.Vertices,length(DestinationMeshPrimitive^.Vertices));
       for VertexIndex:=0 to length(DestinationMeshPrimitiveTarget^.Vertices)-1 do begin
        DestinationMeshPrimitiveTargetVertex:=@DestinationMeshPrimitiveTarget^.Vertices[VertexIndex];
        if trunc(TemporaryTangents[VertexIndex,3])<>trunc(DestinationMeshPrimitive^.Vertices[VertexIndex].Tangent[3]) then begin
         DestinationMeshPrimitiveTargetVertex^.Tangent[0]:=DestinationMeshPrimitive^.Vertices[VertexIndex].Tangent[0]-TemporaryTangents[VertexIndex,0];
         DestinationMeshPrimitiveTargetVertex^.Tangent[1]:=DestinationMeshPrimitive^.Vertices[VertexIndex].Tangent[1]-TemporaryTangents[VertexIndex,1];
         DestinationMeshPrimitiveTargetVertex^.Tangent[2]:=DestinationMeshPrimitive^.Vertices[VertexIndex].Tangent[2]-TemporaryTangents[VertexIndex,2];
        end else begin
         DestinationMeshPrimitiveTargetVertex^.Tangent[0]:=TemporaryTangents[VertexIndex,0]-DestinationMeshPrimitive^.Vertices[VertexIndex].Tangent[0];
         DestinationMeshPrimitiveTargetVertex^.Tangent[1]:=TemporaryTangents[VertexIndex,1]-DestinationMeshPrimitive^.Vertices[VertexIndex].Tangent[1];
         DestinationMeshPrimitiveTargetVertex^.Tangent[2]:=TemporaryTangents[VertexIndex,2]-DestinationMeshPrimitive^.Vertices[VertexIndex].Tangent[2];
        end;
       end;
      end;

     end;

    end;

   end;

   begin
    // Process morph target weights
    SetLength(DestinationMesh^.Weights,SourceMesh.Weights.Count);
    for WeightIndex:=0 to length(DestinationMesh^.Weights)-1 do begin
     DestinationMesh^.Weights[WeightIndex]:=SourceMesh.Weights[WeightIndex];
    end;
    OldCount:=length(DestinationMesh^.Weights);
    if OldCount<MaxCountTargets then begin
     SetLength(DestinationMesh^.Weights,MaxCountTargets);
     for WeightIndex:=OldCount to length(DestinationMesh^.Weights)-1 do begin
      DestinationMesh^.Weights[WeightIndex]:=0.0;
     end;
    end;
   end;

  end;

 end;
 procedure LoadSkins;
 var Index,JointIndex,OldCount:TPasGLTFSizeInt;
     SourceSkin:TPasGLTF.TSkin;
     DestinationSkin:PSkin;
     JSONItem:TPasJSONItem;
     JSONObject:TPasJSONItemObject;
 begin

  SetLength(fSkins,aDocument.Skins.Count);

  for Index:=0 to aDocument.Skins.Count-1 do begin

   SourceSkin:=aDocument.Skins.Items[Index];

   DestinationSkin:=@fSkins[Index];

   DestinationSkin^.Name:=SourceSkin.Name;

   DestinationSkin^.Skeleton:=SourceSkin.Skeleton;

   DestinationSkin^.SkinShaderStorageBufferObjectIndex:=-1;

   if SourceSkin.InverseBindMatrices>=0 then begin
    DestinationSkin^.InverseBindMatrices:=aDocument.Accessors[SourceSkin.InverseBindMatrices].DecodeAsMatrix4x4Array(false);
   end else begin
    DestinationSkin^.InverseBindMatrices:=nil;
   end;

   SetLength(DestinationSkin^.Matrices,SourceSkin.Joints.Count);

   SetLength(DestinationSkin^.Joints,SourceSkin.Joints.Count);
   for JointIndex:=0 to length(DestinationSkin^.Joints)-1 do begin
    DestinationSkin^.Joints[JointIndex]:=SourceSkin.Joints[JointIndex];
   end;

   OldCount:=length(DestinationSkin^.InverseBindMatrices);
   if OldCount<SourceSkin.Joints.Count then begin
    SetLength(DestinationSkin^.InverseBindMatrices,SourceSkin.Joints.Count);
    for JointIndex:=0 to length(DestinationSkin^.InverseBindMatrices)-1 do begin
     DestinationSkin^.InverseBindMatrices[JointIndex]:=TPasGLTF.TDefaults.IdentityMatrix4x4;
    end;
   end;

  end;

 end;
 procedure LoadCameras;
 var Index:TPasGLTFSizeInt;
     SourceCamera:TPasGLTF.TCamera;
     DestinationCamera:PCamera;
 begin
  SetLength(fCameras,aDocument.Cameras.Count);
  for Index:=0 to aDocument.Cameras.Count-1 do begin
   SourceCamera:=aDocument.Cameras[Index];
   DestinationCamera:=@fCameras[Index];
   DestinationCamera^.Name:=SourceCamera.Name;
   DestinationCamera^.Type_:=SourceCamera.Type_;
   case DestinationCamera^.Type_ of
    TPasGLTF.TCamera.TType.Orthographic:begin
     DestinationCamera^.XMag:=SourceCamera.Orthographic.XMag;
     DestinationCamera^.YMag:=SourceCamera.Orthographic.YMag;
     DestinationCamera^.ZNear:=SourceCamera.Orthographic.ZNear;
     DestinationCamera^.ZFar:=SourceCamera.Orthographic.ZFar;
    end;
    TPasGLTF.TCamera.TType.Perspective:begin
     DestinationCamera^.AspectRatio:=SourceCamera.Perspective.AspectRatio;
     DestinationCamera^.YFov:=SourceCamera.Perspective.YFov;
     DestinationCamera^.ZNear:=SourceCamera.Perspective.ZNear;
     DestinationCamera^.ZFar:=SourceCamera.Perspective.ZFar;
    end;
   end;
  end;
 end;
 procedure LoadNodes;
 var Index,WeightIndex,ChildrenIndex,Count,LightIndex:TPasGLTFSizeInt;
     SourceNode:TPasGLTF.TNode;
     DestinationNode:PNode;
     Mesh:PMesh;
     ExtensionObject:TPasJSONItemObject;
     KHRLightsPunctualItem:TPasJSONItem;
     KHRLightsPunctualObject:TPasJSONItemObject;
 begin
  SetLength(fNodes,aDocument.Nodes.Count);
  for Index:=0 to aDocument.Nodes.Count-1 do begin
   SourceNode:=aDocument.Nodes[Index];
   DestinationNode:=@fNodes[Index];
   DestinationNode^.Name:=SourceNode.Name;
   if length(DestinationNode^.Name)>0 then begin
    fNodeNameHashMap.Add(DestinationNode^.Name,Index);
   end;
   DestinationNode^.Mesh:=SourceNode.Mesh;
   DestinationNode^.Camera:=SourceNode.Camera;
   DestinationNode^.Skin:=SourceNode.Skin;
   DestinationNode^.Joint:=-1;
   DestinationNode^.Matrix:=SourceNode.Matrix;
   DestinationNode^.Translation:=SourceNode.Translation;
   DestinationNode^.Rotation:=SourceNode.Rotation;
   DestinationNode^.Scale:=SourceNode.Scale;
   SetLength(DestinationNode^.Weights,SourceNode.Weights.Count);
   for WeightIndex:=0 to length(DestinationNode^.Weights)-1 do begin
    DestinationNode^.Weights[WeightIndex]:=SourceNode.Weights[WeightIndex];
   end;
   if (DestinationNode^.Mesh>=0) and
      (DestinationNode^.Mesh<length(fMeshes)) then begin
    Mesh:=@fMeshes[DestinationNode^.Mesh];
    Count:=length(DestinationNode^.Weights);
    if Count<length(Mesh^.Weights) then begin
     SetLength(DestinationNode^.Weights,length(Mesh^.Weights));
     for WeightIndex:=Count to length(Mesh^.Weights)-1 do begin
      DestinationNode^.Weights[WeightIndex]:=Mesh^.Weights[WeightIndex];
     end;
    end;
   end;
   SetLength(DestinationNode^.Children,SourceNode.Children.Count);
   for ChildrenIndex:=0 to length(DestinationNode^.Children)-1 do begin
    DestinationNode^.Children[ChildrenIndex]:=SourceNode.Children[ChildrenIndex];
   end;
   DestinationNode^.Light:=-1;
   if HasLights then begin
    ExtensionObject:=SourceNode.Extensions;
    if assigned(ExtensionObject) then begin
     KHRLightsPunctualItem:=ExtensionObject.Properties['KHR_lights_punctual'];
     if assigned(KHRLightsPunctualItem) and (KHRLightsPunctualItem is TPasJSONItemObject) then begin
      KHRLightsPunctualObject:=TPasJSONItemObject(KHRLightsPunctualItem);
      LightIndex:=TPasJSON.GetInt64(KHRLightsPunctualObject.Properties['light'],-1);
      if (LightIndex>=0) and (LightIndex<length(fLights)) then begin
       fLights[LightIndex].Node:=Index;
       DestinationNode^.Light:=LightIndex;
      end;
     end;
    end;
   end;
  end;
 end;
 procedure LoadImages;
 var Index:TPasGLTFSizeInt;
     SourceImage:TPasGLTF.TImage;
     DestinationImage:PImage;
     Stream:TMemoryStream;
 begin
  SetLength(fImages,aDocument.Images.Count);
  for Index:=0 to aDocument.Images.Count-1 do begin
   SourceImage:=aDocument.Images[Index];
   DestinationImage:=@fImages[Index];
   DestinationImage^.Name:=SourceImage.Name;
   DestinationImage^.URI:=SourceImage.URI;
   DestinationImage^.MIMEType:=SourceImage.MIMEType;
   DestinationImage^.Data:=nil;
   if not SourceImage.IsExternalResource then begin
    Stream:=TMemoryStream.Create;
    try
     SourceImage.GetResourceData(Stream);
     SetLength(DestinationImage^.Data,Stream.Size);
     Move(Stream.Memory^,DestinationImage^.Data[0],Stream.Size);
    finally
     FreeAndNil(Stream);
    end;
   end;
  end;
 end;
 procedure LoadSamplers;
 var Index:TPasGLTFSizeInt;
     SourceSampler:TPasGLTF.TSampler;
     DestinationSampler:PSampler;
 begin
  SetLength(fSamplers,aDocument.Samplers.Count);
  for Index:=0 to aDocument.Samplers.Count-1 do begin
   SourceSampler:=aDocument.Samplers[Index];
   DestinationSampler:=@fSamplers[Index];
   DestinationSampler^.Name:=SourceSampler.Name;
   DestinationSampler^.MinFilter:=SourceSampler.MinFilter;
   DestinationSampler^.MagFilter:=SourceSampler.MagFilter;
   DestinationSampler^.WrapS:=SourceSampler.WrapS;
   DestinationSampler^.WrapT:=SourceSampler.WrapT;
  end;
 end;
 procedure LoadTextures;
 var Index,NodeIndex:TPasGLTFSizeInt;
     SourceTexture:TPasGLTF.TTexture;
     DestinationTexture:PTexture;
 begin
  SetLength(fTextures,aDocument.Textures.Count);
  for Index:=0 to aDocument.Textures.Count-1 do begin
   SourceTexture:=aDocument.Textures[Index];
   DestinationTexture:=@fTextures[Index];
   DestinationTexture^.Name:=SourceTexture.Name;
   DestinationTexture^.Image:=SourceTexture.Source;
   DestinationTexture^.Sampler:=SourceTexture.Sampler;
  end;
 end;
 procedure LoadScenes;
 var Index,NodeIndex:TPasGLTFSizeInt;
     SourceScene:TPasGLTF.TScene;
     DestinationScene:PScene;
 begin
  SetLength(fScenes,aDocument.Scenes.Count);
  for Index:=0 to aDocument.Scenes.Count-1 do begin
   SourceScene:=aDocument.Scenes[Index];
   DestinationScene:=@fScenes[Index];
   DestinationScene^.Name:=SourceScene.Name;
   SetLength(DestinationScene^.Nodes,SourceScene.Nodes.Count);
   for NodeIndex:=0 to length(DestinationScene^.Nodes)-1 do begin
    DestinationScene^.Nodes[NodeIndex]:=SourceScene.Nodes[NodeIndex];
   end;
  end;
 end;
 procedure ProcessScenes;
 var CountJointNodes:TPasGLTFSizeInt;
  procedure ProcessNode(const aNodeIndex,aLastParentJointIndex:TPasGLTFSizeInt;const aMatrix:TMatrix);
  var Index,SubIndex,LastParentJointIndex:TPasGLTFSizeInt;
      Matrix:TPasGLTF.TMatrix4x4;
      Node:PNode;
      TemporaryVector3:TPasGLTF.TVector3;
      Mesh:PMesh;
  begin
   Node:=@fNodes[aNodeIndex];
   if Node^.Joint=(-2) then begin
    Node^.Joint:=CountJointNodes;
    if length(fJoints)<=CountJointNodes then begin
     SetLength(fJoints,(CountJointNodes+1)*2);
    end;
    fJoints[CountJointNodes].Parent:=aLastParentJointIndex;
    fJoints[CountJointNodes].Node:=aNodeIndex;
    fJoints[CountJointNodes].Children:=nil;
    fJoints[CountJointNodes].CountChildren:=0;
    LastParentJointIndex:=CountJointNodes;
    inc(CountJointNodes);
    if aLastParentJointIndex>=0 then begin
     if length(fJoints[aLastParentJointIndex].Children)<=fJoints[aLastParentJointIndex].CountChildren then begin
      SetLength(fJoints[aLastParentJointIndex].Children,(fJoints[aLastParentJointIndex].CountChildren+1)*2);
     end;
     fJoints[aLastParentJointIndex].Children[fJoints[aLastParentJointIndex].CountChildren]:=LastParentJointIndex;
     inc(fJoints[aLastParentJointIndex].CountChildren);
    end;
   end else begin
    LastParentJointIndex:=aLastParentJointIndex;
   end;
   Matrix:=MatrixMul(
            MatrixMul(
             MatrixMul(
              MatrixFromScale(Node^.Scale),
              MatrixMul(
               MatrixFromRotation(Node^.Rotation),
               MatrixFromTranslation(Node^.Translation))),
             Node^.Matrix),
            aMatrix);
   if Node^.Mesh>=0 then begin
    Mesh:=@fMeshes[Node^.Mesh];
    for SubIndex:=0 to 1 do begin
     TemporaryVector3:=Vector3MatrixMul(Matrix,Mesh^.BoundingBox.MinMax[SubIndex]);
     fStaticBoundingBox.Min[0]:=Min(fStaticBoundingBox.Min[0],TemporaryVector3[0]);
     fStaticBoundingBox.Min[1]:=Min(fStaticBoundingBox.Min[1],TemporaryVector3[1]);
     fStaticBoundingBox.Min[2]:=Min(fStaticBoundingBox.Min[2],TemporaryVector3[2]);
     fStaticBoundingBox.Max[0]:=Max(fStaticBoundingBox.Max[0],TemporaryVector3[0]);
     fStaticBoundingBox.Max[1]:=Max(fStaticBoundingBox.Max[1],TemporaryVector3[1]);
     fStaticBoundingBox.Max[2]:=Max(fStaticBoundingBox.Max[2],TemporaryVector3[2]);
    end;
   end;
   for Index:=0 to length(Node^.Children)-1 do begin
    ProcessNode(Node^.Children[Index],LastParentJointIndex,Matrix);
   end;
  end;
 var SceneIndex,Index,SubIndex,Count:TPasGLTFSizeInt;
     Scene:PScene;
     Skin:PSkin;
     Node:PNode;
 begin
  fScene:=aDocument.Scene;
  fStaticBoundingBox:=EmptyBoundingBox;
  CountJointNodes:=0;
  try
   for Index:=0 to length(fSkins)-1 do begin
    Skin:=@fSkins[Index];
    for SubIndex:=0 to length(Skin^.Joints)-1 do begin
     Node:=@fNodes[Skin^.Joints[SubIndex]];
     if Node^.Joint=(-1) then begin
      Node^.Joint:=-2;
     end;
    end;
   end;
   for SceneIndex:=0 to length(fScenes)-1 do begin
    Scene:=@fScenes[SceneIndex];
    for Index:=0 to length(Scene^.Nodes)-1 do begin
     ProcessNode(Scene^.Nodes[Index],-1,TPasGLTF.TDefaults.IdentityMatrix4x4);
    end;
   end;
  finally
   SetLength(fJointVertices,CountJointNodes*4);
   SetLength(fJoints,CountJointNodes);
   for Index:=0 to CountJointNodes-1 do begin
    SetLength(fJoints[Index].Children,fJoints[Index].CountChildren);
   end;
  end;
 end;
 procedure InitializeSkinShaderStorageBufferObjects;
 var Index,CountMatrices,CountSkinShaderStorageBufferObjects:TPasGLTFSizeInt;
     SourceSkin:TPasGLTF.TSkin;
     DestinationSkin:PSkin;
     SkinShaderStorageBufferObject:PSkinShaderStorageBufferObject;
 begin
  CountSkinShaderStorageBufferObjects:=0;
  try
   for Index:=0 to aDocument.Skins.Count-1 do begin
    SourceSkin:=aDocument.Skins[Index];
    DestinationSkin:=@fSkins[Index];
    CountMatrices:=SourceSkin.Joints.Count;
    if (CountSkinShaderStorageBufferObjects=0) or
       ((fSkinShaderStorageBufferObjects[CountSkinShaderStorageBufferObjects-1].Size+(CountMatrices*SizeOf(TPasGLTF.TMatrix4x4)))>134217728) then begin // 128MB = the minimum required SSBO size in the OpenGL specification
     if length(fSkinShaderStorageBufferObjects)<=CountSkinShaderStorageBufferObjects then begin
      SetLength(fSkinShaderStorageBufferObjects,(CountSkinShaderStorageBufferObjects+1)*2);
     end;
     DestinationSkin^.SkinShaderStorageBufferObjectIndex:=CountSkinShaderStorageBufferObjects;
     DestinationSkin^.SkinShaderStorageBufferObjectOffset:=0;
     DestinationSkin^.SkinShaderStorageBufferObjectByteOffset:=DestinationSkin^.SkinShaderStorageBufferObjectOffset*SizeOf(TPasGLTF.TMatrix4x4);
     DestinationSkin^.SkinShaderStorageBufferObjectByteSize:=CountMatrices*SizeOf(TPasGLTF.TMatrix4x4);
     SkinShaderStorageBufferObject:=@fSkinShaderStorageBufferObjects[CountSkinShaderStorageBufferObjects];
     inc(CountSkinShaderStorageBufferObjects);
     SkinShaderStorageBufferObject^.Count:=CountMatrices;
     SkinShaderStorageBufferObject^.Size:=CountMatrices*SizeOf(TPasGLTF.TMatrix4x4);
     SkinShaderStorageBufferObject^.CountSkins:=1;
     SetLength(SkinShaderStorageBufferObject^.Skins,1);
     SkinShaderStorageBufferObject^.Skins[0]:=Index;
    end else begin
     SkinShaderStorageBufferObject:=@fSkinShaderStorageBufferObjects[CountSkinShaderStorageBufferObjects-1];
     DestinationSkin^.SkinShaderStorageBufferObjectIndex:=CountSkinShaderStorageBufferObjects-1;
     DestinationSkin^.SkinShaderStorageBufferObjectOffset:=SkinShaderStorageBufferObject^.Count;
     DestinationSkin^.SkinShaderStorageBufferObjectByteOffset:=DestinationSkin^.SkinShaderStorageBufferObjectOffset*SizeOf(TPasGLTF.TMatrix4x4);
     DestinationSkin^.SkinShaderStorageBufferObjectByteSize:=CountMatrices*SizeOf(TPasGLTF.TMatrix4x4);
     inc(SkinShaderStorageBufferObject^.Count,CountMatrices);
     inc(SkinShaderStorageBufferObject^.Size,CountMatrices*SizeOf(TPasGLTF.TMatrix4x4));
     if length(SkinShaderStorageBufferObject^.Skins)<=SkinShaderStorageBufferObject^.CountSkins then begin
      SetLength(SkinShaderStorageBufferObject^.Skins,(SkinShaderStorageBufferObject^.CountSkins+1)*2);
     end;
     SkinShaderStorageBufferObject^.Skins[SkinShaderStorageBufferObject^.CountSkins]:=Index;
     inc(SkinShaderStorageBufferObject^.CountSkins);
    end;
   end;
  finally
   SetLength(fSkinShaderStorageBufferObjects,CountSkinShaderStorageBufferObjects);
  end;
  for Index:=0 to length(fSkinShaderStorageBufferObjects)-1 do begin
   SkinShaderStorageBufferObject:=@fSkinShaderStorageBufferObjects[Index];
   SetLength(SkinShaderStorageBufferObject^.Skins,SkinShaderStorageBufferObject^.CountSkins);
  end;
 end;
begin
 if not fReady then begin
  HasLights:=aDocument.ExtensionsUsed.IndexOf('KHR_lights_punctual')>=0;
  LoadLights;
  LoadAnimations;
  LoadImages;
  LoadSamplers;
  LoadTextures;
  LoadMaterials;
  LoadMeshes;
  LoadSkins;
  LoadCameras;
  LoadNodes;
  LoadScenes;
  ProcessScenes;
  InitializeSkinShaderStorageBufferObjects;
  fReady:=true;
 end;
end;

procedure TpvGLTF.LoadFromStream(const aStream:TStream);
var Document:TPasGLTF.TDocument;
begin
 Document:=TPasGLTF.TDocument.Create;
 try
  Document.RootPath:=fRootPath;
  Document.LoadFromStream(aStream);
  LoadFromDocument(Document);
 finally
  FreeAndNil(Document);
 end;
end;

procedure TpvGLTF.LoadFromFile(const aFileName:String);
var MemoryStream:TMemoryStream;
begin
 MemoryStream:=TMemoryStream.Create;
 try
  MemoryStream.LoadFromFile(aFileName);
  LoadFromStream(MemoryStream);
 finally
  FreeAndNil(MemoryStream);
 end;
end;

function TpvGLTF.AddDirectionalLight(const aDirectionX,aDirectionY,aDirectionZ,aColorX,aColorY,aColorZ:TPasGLTFFloat):TPasGLTFSizeInt;
var Light:TpvGLTF.PLight;
begin
 result:=length(fLights);
 begin
  inc(fCountNormalShadowMaps);
  SetLength(fLights,result+1);
  Light:=@fLights[result];
  Light^.Name:='DefaultDirectionalLight'+IntToStr(length(fLights));
  Light^.Type_:=TLightDataType.Directional;
  Light^.Node:=-$8000000;
  Light^.ShadowMapIndex:=0;
  Light^.Intensity:=1.0;
  Light^.Range:=Infinity;
  Light^.InnerConeAngle:=0.0;
  Light^.OuterConeAngle:=0.0;
  Light^.Direction[0]:=aDirectionX;
  Light^.Direction[1]:=aDirectionY;
  Light^.Direction[2]:=aDirectionZ;
  Light^.Color[0]:=aColorX;
  Light^.Color[1]:=aColorY;
  Light^.Color[2]:=aColorZ;
  Light^.CastShadows:=true;
 end;
end;

procedure TpvGLTF.Upload;
type TAllVertices=TPasGLTFDynamicArray<TVertex>;
     TAllIndices=TPasGLTFDynamicArray<TPasGLTFUInt32>;
var AllVertices:TAllVertices;
    AllIndices:TAllIndices;
 procedure CollectVerticesAndIndicesFromMeshes;
 var Index,
     PrimitiveIndex,
     VertexIndex,
     IndexIndex:TPasGLTFSizeInt;
     Mesh:PMesh;
     Primitive:TMesh.PPrimitive;
 begin
  for Index:=0 to length(fMeshes)-1 do begin
   Mesh:=@fMeshes[Index];
   for PrimitiveIndex:=0 to length(Mesh^.Primitives)-1 do begin
    Primitive:=@Mesh^.Primitives[PrimitiveIndex];
    Primitive^.StartBufferVertexOffset:=AllVertices.Count;
    Primitive^.StartBufferIndexOffset:=AllIndices.Count;
    Primitive^.CountVertices:=length(Primitive^.Vertices);
    Primitive^.CountIndices:=length(Primitive^.Indices);
    AllVertices.Add(Primitive^.Vertices);
    AllIndices.Add(Primitive^.Indices);
    for IndexIndex:=Primitive^.StartBufferIndexOffset to (Primitive^.StartBufferIndexOffset+Primitive^.CountIndices)-1 do begin
     AllIndices[IndexIndex]:=AllIndices[IndexIndex]+Primitive^.StartBufferVertexOffset;
    end;
   end;
  end;
 end;
 procedure LoadTextures;
 var Index:TPasGLTFSizeInt;
     Texture:PTexture;
     Image:PImage;
     Sampler:PSampler;
     MemoryStream:TMemoryStream;
     Stream:TStream;
     ImageData:TPasGLTFPointer;
     ImageWidth,ImageHeight:TPasGLTFInt32;
     Anisotropy:TPasGLTFFloat;
 begin
  for Index:=0 to length(fTextures)-1 do begin
   Texture:=@fTextures[Index];
   if (Texture^.Image>=0) and (Texture^.Image<length(fImages)) then begin
    Image:=@fImages[Texture^.Image];
    MemoryStream:=TMemoryStream.Create;
    try
     if length(Image^.Data)>0 then begin
      MemoryStream.Write(Image^.Data[0],length(Image^.Data));
     end else if assigned(fGetURI) then begin
      Stream:=fGetURI(Image^.URI);
      if assigned(Stream) then begin
       try
        MemoryStream.LoadFromStream(Stream);
       finally
        FreeAndNil(Stream);
       end;
      end;
     end;
    finally
     FreeAndNil(MemoryStream);
    end;
   end;
  end;
 end;
begin
 if not fUploaded then begin
  fUploaded:=true;
  AllVertices:=TAllVertices.Create;
  try
   AllIndices:=TAllIndices.Create;
   try
    CollectVerticesAndIndicesFromMeshes;
    LoadTextures;
   finally
    FreeAndNil(AllIndices);
   end;
  finally
   FreeAndNil(AllVertices);
  end;
 end;
end;

procedure TpvGLTF.Unload;
begin
 if fUploaded then begin
  fUploaded:=false;
 end;
end;

function TpvGLTF.GetAnimationBeginTime(const aAnimation:TPasGLTFSizeInt):TPasGLTFDouble;
var Index:TPasGLTFSizeInt;
    Animation:TpvGLTF.PAnimation;
    Channel:TpvGLTF.TAnimation.PChannel;
begin
 result:=0.0;
 if (aAnimation>=0) and (aAnimation<length(fAnimations)) then begin
  Animation:=@fAnimations[aAnimation];
  for Index:=0 to length(Animation^.Channels)-1 do begin
   Channel:=@Animation^.Channels[Index];
   if length(Channel^.InputTimeArray)>0 then begin
    if Index=0 then begin
     result:=Channel^.InputTimeArray[0];
    end else begin
     result:=Min(result,Channel^.InputTimeArray[0]);
    end;
   end;
  end;
 end;
end;

function TpvGLTF.GetAnimationEndTime(const aAnimation:TPasGLTFSizeInt):TPasGLTFDouble;
var Index:TPasGLTFSizeInt;
    Animation:TpvGLTF.PAnimation;
    Channel:TpvGLTF.TAnimation.PChannel;
begin
 result:=1.0;
 if (aAnimation>=0) and (aAnimation<length(fAnimations)) then begin
  Animation:=@fAnimations[aAnimation];
  for Index:=0 to length(Animation^.Channels)-1 do begin
   Channel:=@Animation^.Channels[Index];
   if length(Channel^.InputTimeArray)>0 then begin
    if Index=0 then begin
     result:=Channel^.InputTimeArray[length(Channel^.InputTimeArray)-1];
    end else begin
     result:=Max(result,Channel^.InputTimeArray[length(Channel^.InputTimeArray)-1]);
    end;
   end;
  end;
 end;
end;

function TpvGLTF.GetAnimationTimes(const aAnimation:TPasGLTFSizeInt):TPasGLTFDoubleDynamicArray;
var Index,TimeIndex,Count:TPasGLTFSizeInt;
    Animation:TpvGLTF.PAnimation;
    Channel:TpvGLTF.TAnimation.PChannel;
    Temporary:TPasGLTFDouble;
begin
 
 result:=nil;
 
 if (aAnimation>=0) and (aAnimation<length(fAnimations)) then begin

  Animation:=@fAnimations[aAnimation];

  // Count all time values  
  Count:=0;
  for Index:=0 to length(Animation^.Channels)-1 do begin
   Channel:=@Animation^.Channels[Index];
   if length(Channel^.InputTimeArray)>0 then begin
    inc(Count,length(Channel^.InputTimeArray));
   end;
  end;
  SetLength(result,Count);
  
  // Copy all time values
  Count:=0;
  for Index:=0 to length(Animation^.Channels)-1 do begin
   Channel:=@Animation^.Channels[Index];
   if length(Channel^.InputTimeArray)>0 then begin
    for TimeIndex:=0 to length(Channel^.InputTimeArray)-1 do begin
     result[Count+TimeIndex]:=Channel^.InputTimeArray[TimeIndex];
    end;
    inc(Count,length(Channel^.InputTimeArray));
   end;
  end;

  // Sort all time values. Bubble sort for now
  Index:=0;
  while (Index+1)<Count do begin
   if result[Index]>result[Index+1] then begin
    Temporary:=result[Index];
    result[Index]:=result[Index+1];
    result[Index+1]:=Temporary;
    if Index>0 then begin
     dec(Index);
    end else begin
     inc(Index);
    end;
   end else begin
    inc(Index);
   end;
  end;

  // Remove duplicates
  Index:=0;
  while Index<(Count-1) do begin
   if SameValue(result[Index],result[Index+1]) then begin
    for TimeIndex:=Index to (Count-2) do begin
     result[TimeIndex]:=result[TimeIndex+1];
    end;
    dec(Count);
   end else begin
    inc(Index);
   end;
  end;

  // Set final array size
  if length(result)<>Count then begin
   SetLength(result,Count);
  end;

 end;

end;

function TpvGLTF.GetNodeIndex(const aNodeName:TPasGLTFUTF8String):TPasGLTFSizeInt;
begin
 result:=fNodeNameHashMap[aNodeName];
end;

function TpvGLTF.AcquireInstance:TpvGLTF.TInstance;
begin
 result:=TpvGLTF.TInstance.Create(self);
end;

{ TpvGLTF.TInstance.TAnimation }

constructor TpvGLTF.TInstance.TAnimation.Create;
begin
 inherited Create;
 fFactor:=-1.0;
 fTime:=0.0;
end;

destructor TpvGLTF.TInstance.TAnimation.Destroy;
begin
 inherited Destroy;
end;

{ TpvGLTF.TInstance }

constructor TpvGLTF.TInstance.Create(const aParent:TpvGLTF);
var Index,OtherIndex:TPasGLTFSizeInt;
    InstanceNode:TpvGLTF.TInstance.PNode;
    Node:TpvGLTF.PNode;
begin
 inherited Create;
 fParent:=aParent;
 fScene:=-1;
 fAnimation:=-1;
 fNodes:=nil;
 fSkins:=nil;
 fAnimations:=nil;
 SetLength(fNodes,length(fParent.fNodes));
 SetLength(fSkins,length(fParent.fSkins));
 SetLength(fLightNodes,length(fParent.fLights));
 SetLength(fLightShadowMapMatrices,length(fParent.fLights));
 SetLength(fLightShadowMapZFarValues,length(fParent.fLights));
 for Index:=0 to length(fLightNodes)-1 do begin
  fLightNodes[Index]:=-1;
 end;
 for Index:=0 to length(fParent.fNodes)-1 do begin
  InstanceNode:=@fNodes[Index];
  Node:=@fParent.fNodes[Index];
  SetLength(InstanceNode^.WorkWeights,length(Node^.Weights));
  SetLength(InstanceNode^.OverwriteWeights,length(Node^.Weights));
  SetLength(InstanceNode^.OverwriteWeightsSum,length(Node^.Weights));
  SetLength(InstanceNode^.Overwrites,length(aParent.Animations)+1);
  for OtherIndex:=0 to length(aParent.Animations) do begin
   SetLength(InstanceNode^.Overwrites[OtherIndex].Weights,length(Node^.Weights));
  end;
 end;
 SetLength(fAnimations,length(fParent.fAnimations)+1);
 for Index:=0 to length(fAnimations)-1 do begin
  fAnimations[Index]:=TpvGLTF.TInstance.TAnimation.Create;
 end;
end;

destructor TpvGLTF.TInstance.Destroy;
var Index:TPasGLTFSizeInt;
begin
 for Index:=0 to length(fAnimations)-1 do begin
  FreeAndNil(fAnimations[Index]);
 end;
 fNodes:=nil;
 fSkins:=nil;
 fAnimations:=nil;
 inherited Destroy;
end;

procedure TpvGLTF.TInstance.SetScene(const aScene:TPasGLTFSizeInt);
begin
 fScene:=Min(Max(aScene,-1),length(fParent.fScenes)-1);
end;

function TpvGLTF.TInstance.GetAutomation(const aIndex:TPasGLTFSizeInt):TpvGLTF.TInstance.TAnimation;
begin
 result:=fAnimations[aIndex+1];
end;

procedure TpvGLTF.TInstance.SetAnimation(const aAnimation:TPasGLTFSizeInt);
begin
 fAnimation:=Min(Max(aAnimation,-1),length(fParent.fAnimations)-1);
end;

function TpvGLTF.TInstance.GetScene:TpvGLTF.PScene;
begin
 if fParent.fReady and fParent.fUploaded then begin
  if fScene<0 then begin
   if fParent.fScene<0 then begin
    result:=@fParent.fScenes[0];
   end else if fParent.fScene<length(fParent.fScenes) then begin
    result:=@fParent.fScenes[fParent.fScene];
   end else begin
    result:=nil;
   end;
  end else if fScene<length(fParent.fScenes) then begin
   result:=@fParent.fScenes[fScene];
  end else begin
   result:=nil;
  end;
 end else begin
  result:=nil;
 end;
end;

procedure TpvGLTF.TInstance.Update;
var CullFace,Blend:TPasGLTFInt32;
 procedure ResetNode(const aNodeIndex:TPasGLTFSizeInt);
 var Index:TPasGLTFSizeInt;
     InstanceNode:TpvGLTF.TInstance.PNode;
     Node:TpvGLTF.PNode;
 begin
  InstanceNode:=@fNodes[aNodeIndex];
  Node:=@fParent.fNodes[aNodeIndex];
  InstanceNode^.CountOverwrites:=0;
  InstanceNode^.OverwriteFlags:=[];
  for Index:=0 to length(Node^.Children)-1 do begin
   ResetNode(Node^.Children[Index]);
  end;
 end;
 procedure ProcessBaseOverwrite(const aFactor:TPasGLTFFloat);
 var Index:TPasGLTFSizeInt;
     InstanceNode:TpvGLTF.TInstance.PNode;
     Overwrite:TpvGLTF.TInstance.TNode.POverwrite;
 begin
  if aFactor>=-0.5 then begin
   for Index:=0 to length(fParent.fNodes)-1 do begin
    InstanceNode:=@fNodes[Index];
    if InstanceNode^.CountOverwrites<length(InstanceNode^.Overwrites) then begin
     Overwrite:=@InstanceNode^.Overwrites[InstanceNode^.CountOverwrites];
     Overwrite^.Flags:=[TpvGLTF.TInstance.TNode.TOverwriteFlag.Defaults];
     Overwrite^.Factor:=Max(aFactor,0.0);
     inc(InstanceNode^.CountOverwrites);
    end;
   end;
  end;
 end;
 procedure ProcessAnimation(const aAnimationIndex:TPasGLTFSizeInt;const aAnimationTime:TPasGLTFFloat;const aFactor:TPasGLTFFloat);
 var ChannelIndex,
     InputTimeArrayIndex,
     WeightIndex,
     CountWeights,
     ElementIndex,
     l,r,m:TPasGLTFSizeInt;
     Animation:TpvGLTF.PAnimation;
     AnimationChannel:TpvGLTF.TAnimation.PChannel;
     Node:TpvGLTF.TInstance.PNode;
     Time,Factor,Scalar,Value,SqrFactor,CubeFactor,KeyDelta,v0,v1,a,b:TPasGLTFFloat;
     Vector3:TPasGLTF.TVector3;
     Vector4:TPasGLTF.TVector4;
     Vector3s:array[0..1] of TPasGLTF.PVector3;
     Vector4s:array[0..1] of TPasGLTF.PVector4;
     TimeIndices:array[0..1] of TPasGLTFSizeInt;
     Overwrite:TpvGLTF.TInstance.TNode.POverwrite;
 begin

  Animation:=@fParent.fAnimations[aAnimationIndex];

  for ChannelIndex:=0 to length(Animation^.Channels)-1 do begin

   AnimationChannel:=@Animation^.Channels[ChannelIndex];

   if (AnimationChannel^.Node>=0) and (length(AnimationChannel^.InputTimeArray)>0) then begin

    TimeIndices[1]:=length(AnimationChannel^.InputTimeArray)-1;

    Time:=Min(Max(aAnimationTime,AnimationChannel^.InputTimeArray[0]),AnimationChannel^.InputTimeArray[TimeIndices[1]]);

    if (AnimationChannel^.Last<=0) or (Time<AnimationChannel^.InputTimeArray[AnimationChannel.Last-1]) then begin
     l:=0;
    end else begin
     l:=AnimationChannel^.Last-1;
    end;

    for InputTimeArrayIndex:=Min(Max(l,0),length(AnimationChannel^.InputTimeArray)-1) to Min(Max(l+3,0),length(AnimationChannel^.InputTimeArray)-1) do begin
     if AnimationChannel^.InputTimeArray[InputTimeArrayIndex]>Time then begin
      l:=InputTimeArrayIndex-1;
      break;
     end;
    end;

    r:=length(AnimationChannel^.InputTimeArray);
    if ((l+1)<r) and (Time<AnimationChannel^.InputTimeArray[l+1]) then begin
     inc(l);
    end else begin
     while l<r do begin
      m:=l+((r-l) shr 1);
      Value:=AnimationChannel^.InputTimeArray[m];
      if Value<=Time then begin
       l:=m+1;
       if Time<AnimationChannel^.InputTimeArray[l] then begin
        break;
       end;
      end else begin
       r:=m;
      end;
     end;
    end;

    for InputTimeArrayIndex:=Min(Max(l,0),length(AnimationChannel^.InputTimeArray)-1) to length(AnimationChannel^.InputTimeArray)-1 do begin
     if AnimationChannel^.InputTimeArray[InputTimeArrayIndex]>Time then begin
      TimeIndices[1]:=InputTimeArrayIndex;
      break;
     end;
    end;

    AnimationChannel^.Last:=TimeIndices[1];

    if TimeIndices[1]>=0 then begin

     TimeIndices[0]:=Max(0,TimeIndices[1]-1);

     KeyDelta:=AnimationChannel^.InputTimeArray[TimeIndices[1]]-AnimationChannel^.InputTimeArray[TimeIndices[0]];

     if SameValue(TimeIndices[0],TimeIndices[1]) then begin
      Factor:=0.0;
     end else begin
      Factor:=(Time-AnimationChannel^.InputTimeArray[TimeIndices[0]])/KeyDelta;
      if Factor<0.0 then begin
       Factor:=0.0;
      end else if Factor>1.0 then begin
       Factor:=1.0;
      end;
     end;

     Node:=@fNodes[AnimationChannel^.Node];

     if (aFactor>=-0.5) and (Node^.CountOverwrites<length(Node^.Overwrites)) then begin
      Overwrite:=@Node^.Overwrites[Node^.CountOverwrites];
      Overwrite^.Flags:=[];
      Overwrite^.Factor:=Max(aFactor,0.0);
      inc(Node^.CountOverwrites);
     end else begin
      Overwrite:=nil;
     end;

     case AnimationChannel^.Target of
      TpvGLTF.TAnimation.TChannel.TTarget.Translation,
      TpvGLTF.TAnimation.TChannel.TTarget.Scale:begin
       case AnimationChannel^.Interpolation of
        TpvGLTF.TAnimation.TChannel.TInterpolation.Linear:begin
         Vector3s[0]:=@AnimationChannel^.OutputVector3Array[TimeIndices[0]];
         Vector3s[1]:=@AnimationChannel^.OutputVector3Array[TimeIndices[1]];
         Vector3[0]:=(Vector3s[0]^[0]*(1.0-Factor))+(Vector3s[1]^[0]*Factor);
         Vector3[1]:=(Vector3s[0]^[1]*(1.0-Factor))+(Vector3s[1]^[1]*Factor);
         Vector3[2]:=(Vector3s[0]^[2]*(1.0-Factor))+(Vector3s[1]^[2]*Factor);
        end;
        TpvGLTF.TAnimation.TChannel.TInterpolation.Step:begin
         Vector3:=AnimationChannel^.OutputVector3Array[TimeIndices[0]];
        end;
        TpvGLTF.TAnimation.TChannel.TInterpolation.CubicSpline:begin
         SqrFactor:=sqr(Factor);
         CubeFactor:=SqrFactor*Factor;
         Vector3:=Vector3Add(Vector3Add(Vector3Add(Vector3Scale(AnimationChannel^.OutputVector3Array[(TimeIndices[0]*3)+1],((2.0*CubeFactor)-(3.0*SqrFactor))+1.0),
                                                   Vector3Scale(AnimationChannel^.OutputVector3Array[(TimeIndices[1]*3)+0],KeyDelta*((CubeFactor-(2.0*SqrFactor))+Factor))),
                                       Vector3Scale(AnimationChannel^.OutputVector3Array[(TimeIndices[1]*3)+1],(3.0*SqrFactor)-(2.0*CubeFactor))),
                             Vector3Scale(AnimationChannel^.OutputVector3Array[(TimeIndices[1]*3)+0],KeyDelta*(CubeFactor-SqrFactor)));
        end;
        else begin
         Assert(false);
        end;
       end;
       case AnimationChannel^.Target of
        TpvGLTF.TAnimation.TChannel.TTarget.Translation:begin
         if assigned(Overwrite) then begin
          Include(Overwrite^.Flags,TpvGLTF.TInstance.TNode.TOverwriteFlag.Translation);
          Overwrite^.Translation:=Vector3;
         end else begin
          Include(Node^.OverwriteFlags,TpvGLTF.TInstance.TNode.TOverwriteFlag.Translation);
          Node^.OverwriteTranslation:=Vector3;
         end;
        end;
        TpvGLTF.TAnimation.TChannel.TTarget.Scale:begin
         if assigned(Overwrite) then begin
          Include(Overwrite^.Flags,TpvGLTF.TInstance.TNode.TOverwriteFlag.Scale);
          Overwrite^.Scale:=Vector3;
         end else begin
          Include(Node^.OverwriteFlags,TpvGLTF.TInstance.TNode.TOverwriteFlag.Scale);
          Node^.OverwriteScale:=Vector3;
         end;
        end;
       end;
      end;
      TpvGLTF.TAnimation.TChannel.TTarget.Rotation:begin
       case AnimationChannel^.Interpolation of
        TpvGLTF.TAnimation.TChannel.TInterpolation.Linear:begin
         Vector4:=QuaternionSlerp(AnimationChannel^.OutputVector4Array[TimeIndices[0]],
                                  AnimationChannel^.OutputVector4Array[TimeIndices[1]],
                                  Factor);
        end;
        TpvGLTF.TAnimation.TChannel.TInterpolation.Step:begin
         Vector4:=AnimationChannel^.OutputVector4Array[TimeIndices[0]];
        end;
        TpvGLTF.TAnimation.TChannel.TInterpolation.CubicSpline:begin
         SqrFactor:=sqr(Factor);
         CubeFactor:=SqrFactor*Factor;
         Vector4:=Vector4Normalize(QuaternionAdd(QuaternionAdd(QuaternionAdd(QuaternionScalarMul(AnimationChannel^.OutputVector4Array[(TimeIndices[0]*3)+1],((2.0*CubeFactor)-(3.0*SqrFactor))+1.0),
                                                                             QuaternionScalarMul(AnimationChannel^.OutputVector4Array[(TimeIndices[1]*3)+0],KeyDelta*((CubeFactor-(2.0*SqrFactor))+Factor))),
                                                               QuaternionScalarMul(AnimationChannel^.OutputVector4Array[(TimeIndices[1]*3)+1],(3.0*SqrFactor)-(2.0*CubeFactor))),
                                                 QuaternionScalarMul(AnimationChannel^.OutputVector4Array[(TimeIndices[1]*3)+0],KeyDelta*(CubeFactor-SqrFactor))));
        end;
        else begin
         Assert(false);
        end;
       end;
       if assigned(Overwrite) then begin
        Include(Overwrite^.Flags,TpvGLTF.TInstance.TNode.TOverwriteFlag.Rotation);
        Overwrite^.Rotation:=Vector4;
       end else begin
        Include(Node^.OverwriteFlags,TpvGLTF.TInstance.TNode.TOverwriteFlag.Rotation);
        Node^.OverwriteRotation:=Vector4;
       end;
      end;
      TpvGLTF.TAnimation.TChannel.TTarget.Weights:begin
       CountWeights:=length(Node^.WorkWeights);
       if assigned(Overwrite) then begin
        Include(Overwrite^.Flags,TpvGLTF.TInstance.TNode.TOverwriteFlag.Weights);
        case AnimationChannel^.Interpolation of
         TpvGLTF.TAnimation.TChannel.TInterpolation.Linear:begin
          for WeightIndex:=0 to CountWeights-1 do begin
           Overwrite^.Weights[WeightIndex]:=(AnimationChannel^.OutputScalarArray[(TimeIndices[0]*CountWeights)+WeightIndex]*(1.0-Factor))+
                                            (AnimationChannel^.OutputScalarArray[(TimeIndices[1]*CountWeights)+WeightIndex]*Factor);
          end;
         end;
         TpvGLTF.TAnimation.TChannel.TInterpolation.Step:begin
          for WeightIndex:=0 to CountWeights-1 do begin
           Overwrite^.Weights[WeightIndex]:=AnimationChannel^.OutputScalarArray[(TimeIndices[0]*CountWeights)+WeightIndex];
          end;
         end;
         TpvGLTF.TAnimation.TChannel.TInterpolation.CubicSpline:begin
          SqrFactor:=sqr(Factor);
          CubeFactor:=SqrFactor*Factor;
          for WeightIndex:=0 to CountWeights-1 do begin
           Overwrite^. Weights[WeightIndex]:=((((2.0*CubeFactor)-(3.0*SqrFactor))+1.0)*AnimationChannel^.OutputScalarArray[(((TimeIndices[0]*3)+1)*CountWeights)+WeightIndex])+
                                             (((CubeFactor-(2.0*SqrFactor))+Factor)*KeyDelta*AnimationChannel^.OutputScalarArray[(((TimeIndices[0]*3)+2)*CountWeights)+WeightIndex])+
                                             (((3.0*SqrFactor)-(2.0*CubeFactor))*AnimationChannel^.OutputScalarArray[(((TimeIndices[1]*3)+1)*CountWeights)+WeightIndex])+
                                             ((CubeFactor-SqrFactor)*KeyDelta*AnimationChannel^.OutputScalarArray[(((TimeIndices[1]*3)+0)*CountWeights)+WeightIndex]);
          end;
         end;
         else begin
          Assert(false);
         end;
        end;
       end else begin
        Include(Node^.OverwriteFlags,TpvGLTF.TInstance.TNode.TOverwriteFlag.Weights);
        case AnimationChannel^.Interpolation of
         TpvGLTF.TAnimation.TChannel.TInterpolation.Linear:begin
          for WeightIndex:=0 to CountWeights-1 do begin
           Node^.OverwriteWeights[WeightIndex]:=(AnimationChannel^.OutputScalarArray[(TimeIndices[0]*CountWeights)+WeightIndex]*(1.0-Factor))+
                                                (AnimationChannel^.OutputScalarArray[(TimeIndices[1]*CountWeights)+WeightIndex]*Factor);
          end;
         end;
         TpvGLTF.TAnimation.TChannel.TInterpolation.Step:begin
          for WeightIndex:=0 to CountWeights-1 do begin
           Node^.OverwriteWeights[WeightIndex]:=AnimationChannel^.OutputScalarArray[(TimeIndices[0]*CountWeights)+WeightIndex];
          end;
         end;
         TpvGLTF.TAnimation.TChannel.TInterpolation.CubicSpline:begin
          SqrFactor:=sqr(Factor);
          CubeFactor:=SqrFactor*Factor;
          for WeightIndex:=0 to CountWeights-1 do begin
           Node^.OverwriteWeights[WeightIndex]:=((((2.0*CubeFactor)-(3.0*SqrFactor))+1.0)*AnimationChannel^.OutputScalarArray[(((TimeIndices[0]*3)+1)*CountWeights)+WeightIndex])+
                                                (((CubeFactor-(2.0*SqrFactor))+Factor)*KeyDelta*AnimationChannel^.OutputScalarArray[(((TimeIndices[0]*3)+2)*CountWeights)+WeightIndex])+
                                                (((3.0*SqrFactor)-(2.0*CubeFactor))*AnimationChannel^.OutputScalarArray[(((TimeIndices[1]*3)+1)*CountWeights)+WeightIndex])+
                                                ((CubeFactor-SqrFactor)*KeyDelta*AnimationChannel^.OutputScalarArray[(((TimeIndices[1]*3)+0)*CountWeights)+WeightIndex]);
          end;
         end;
         else begin
          Assert(false);
         end;
        end;
       end;
      end;
     end;


    end;

   end;

  end;

 end;
 procedure ProcessNode(const aNodeIndex:TPasGLTFSizeInt;const aMatrix:TMatrix);
 var Index,OtherIndex,RotationCounter:TPasGLTFSizeInt;
     Matrix:TPasGLTF.TMatrix4x4;
     InstanceNode:TpvGLTF.TInstance.PNode;
     Node:TpvGLTF.PNode;
     Translation,Scale:TPasGLTF.TVector3;
     Rotation,WeightedRotation:TPasGLTF.TVector4;
     TranslationSum,ScaleSum:TpvGLTF.TVector3Sum;
//   RotationSum:TpvGLTF.TVector4Sum;
     Factor,
     WeightsFactorSum:TPasGLTFDouble;
     Overwrite:TpvGLTF.TInstance.TNode.POverwrite;
     FirstWeights:boolean;
     WeightedRotationFactorSum:TPasGLTFDouble;
  procedure AddRotation(const aRotation:TPasGLTF.TVector4;const aFactor:TPasGLTFDouble);
  begin
   if not IsZero(aFactor) then begin
    if RotationCounter=0 then begin
     WeightedRotation:=aRotation;
    end else begin
     // Informal rolling weighted average proof as javascript/ecmascript:
     // var data = [[1, 0.5], [2, 0.25], [3, 0.125], [4, 0.0625]]; // <= [[value, weight], ... ]
     // var weightedAverage = 0, weightSum = 0;
     // for(var i = 0; i < data.length; i++){
     //   weightSum += data[i][1];
     // }
     // for(var i = 0; i < data.length; i++){
     //    weightedAverage += data[i][0] * data[i][1];
     // };
     // weightedAverage /= weightSum;
     // var rollingAverage = 0, rollingWeightSum = 0;
     // for(var i = 0; i < data.length; i++){
     //   //-------------------- THIS -----------------\\ should be replaced with the actual blend operation, for example slerping
     //   rollingAverage += (data[i][0] - rollingAverage) * (data[i][1] / (rollingWeightSum + data[i][1]));
     //   rollingWeightSum += data[i][1];
     // }
     // var output = [weightedAverage, rollingAverage, weightedAverage * weightSum, rollingAverage * weightSum];
     // output should be [1.7333333333333334, 1.7333333333333334, 1.625, 1.625] then
     // Slerp: Commutative =  No, Constant velocity = Yes, Torque minimal = Yes (no artefact-jumps)
     // Nlerp: Commutative = Yes, Constant velocity = No,  Torque minimal = Yes (no artefact-jumps)
     // Elerp: Commutative = Yes, Constant velocity = Yes, Torque minimal = No  (can produce artefact-jumps on too distinct to blending automation WeightedRotation frames)
     WeightedRotation:=QuaternionSlerp(WeightedRotation,aRotation,aFactor/(WeightedRotationFactorSum+aFactor)); // Rolling weighted average
    end;
    inc(RotationCounter);
    WeightedRotationFactorSum:=WeightedRotationFactorSum+aFactor;
   end;
  end;
 begin
  InstanceNode:=@fNodes[aNodeIndex];
  Node:=@fParent.fNodes[aNodeIndex];
  if InstanceNode^.CountOverwrites>0 then begin
   TranslationSum.x:=0.0;
   TranslationSum.y:=0.0;
   TranslationSum.z:=0.0;
   TranslationSum.FactorSum:=0.0;
   ScaleSum.x:=0.0;
   ScaleSum.y:=0.0;
   ScaleSum.z:=0.0;
   ScaleSum.FactorSum:=0.0;
{  RotationSum.x:=0.0;
   RotationSum.y:=0.0;
   RotationSum.z:=0.0;
   RotationSum.w:=0.0;
   RotationSum.FactorSum:=0.0;}
   WeightedRotation[0]:=0.0;
   WeightedRotation[1]:=0.0;
   WeightedRotation[2]:=0.0;
   WeightedRotation[3]:=1.0;
   WeightsFactorSum:=0.0;
   WeightedRotationFactorSum:=0.0;
   RotationCounter:=0;
   FirstWeights:=true;
   for Index:=0 to InstanceNode^.CountOverwrites-1 do begin
    Overwrite:=@InstanceNode^.Overwrites[Index];
    Factor:=Overwrite^.Factor;
    if TpvGLTF.TInstance.TNode.TOverwriteFlag.Defaults in Overwrite^.Flags then begin
     TranslationSum.x:=TranslationSum.x+(Node^.Translation[0]*Factor);
     TranslationSum.y:=TranslationSum.y+(Node^.Translation[1]*Factor);
     TranslationSum.z:=TranslationSum.z+(Node^.Translation[2]*Factor);
     TranslationSum.FactorSum:=TranslationSum.FactorSum+Factor;
     ScaleSum.x:=ScaleSum.x+(Node^.Scale[0]*Factor);
     ScaleSum.y:=ScaleSum.y+(Node^.Scale[1]*Factor);
     ScaleSum.z:=ScaleSum.z+(Node^.Scale[2]*Factor);
     ScaleSum.FactorSum:=ScaleSum.FactorSum+Factor;
     AddRotation(Node.Rotation,Factor);
{    RotationSum.x:=RotationSum.x+(Node^.Rotation[0]*Factor);
     RotationSum.y:=RotationSum.y+(Node^.Rotation[1]*Factor);
     RotationSum.z:=RotationSum.z+(Node^.Rotation[2]*Factor);
     RotationSum.w:=RotationSum.w+(Node^.Rotation[3]*Factor);
     RotationSum.FactorSum:=RotationSum.FactorSum+Factor;}
     if length(Node^.Weights)>0 then begin
      if FirstWeights then begin
       FirstWeights:=false;
       for OtherIndex:=0 to length(InstanceNode^.OverwriteWeightsSum)-1 do begin
        InstanceNode^.OverwriteWeightsSum[OtherIndex]:=0.0;
       end;
      end;
      for OtherIndex:=0 to Min(length(InstanceNode^.OverwriteWeightsSum),length(Node^.Weights))-1 do begin
       InstanceNode^.OverwriteWeightsSum[OtherIndex]:=InstanceNode^.OverwriteWeightsSum[OtherIndex]+(Node^.Weights[OtherIndex]*Factor);
      end;
      WeightsFactorSum:=WeightsFactorSum+Factor;
     end;
    end else begin
     if TpvGLTF.TInstance.TNode.TOverwriteFlag.Translation in Overwrite^.Flags then begin
      TranslationSum.x:=TranslationSum.x+(Overwrite^.Translation[0]*Factor);
      TranslationSum.y:=TranslationSum.y+(Overwrite^.Translation[1]*Factor);
      TranslationSum.z:=TranslationSum.z+(Overwrite^.Translation[2]*Factor);
      TranslationSum.FactorSum:=TranslationSum.FactorSum+Factor;
     end;
     if TpvGLTF.TInstance.TNode.TOverwriteFlag.Scale in Overwrite^.Flags then begin
      ScaleSum.x:=ScaleSum.x+(Overwrite^.Scale[0]*Factor);
      ScaleSum.y:=ScaleSum.y+(Overwrite^.Scale[1]*Factor);
      ScaleSum.z:=ScaleSum.z+(Overwrite^.Scale[2]*Factor);
      ScaleSum.FactorSum:=ScaleSum.FactorSum+Factor;
     end;
     if TpvGLTF.TInstance.TNode.TOverwriteFlag.Rotation in Overwrite^.Flags then begin
      AddRotation(Overwrite^.Rotation,Factor);
{     RotationSum.x:=RotationSum.x+(Overwrite^.Rotation[0]*Factor);
      RotationSum.y:=RotationSum.y+(Overwrite^.Rotation[1]*Factor);
      RotationSum.z:=RotationSum.z+(Overwrite^.Rotation[2]*Factor);
      RotationSum.w:=RotationSum.w+(Overwrite^.Rotation[3]*Factor);
      RotationSum.FactorSum:=RotationSum.FactorSum+Factor;}
     end;
     if TpvGLTF.TInstance.TNode.TOverwriteFlag.Weights in Overwrite^.Flags then begin
      if FirstWeights then begin
       FirstWeights:=false;
       for OtherIndex:=0 to length(InstanceNode^.OverwriteWeightsSum)-1 do begin
        InstanceNode^.OverwriteWeightsSum[OtherIndex]:=0.0;
       end;
      end;
      for OtherIndex:=0 to Min(length(InstanceNode^.OverwriteWeightsSum),length(Overwrite^.Weights))-1 do begin
       InstanceNode^.OverwriteWeightsSum[OtherIndex]:=InstanceNode^.OverwriteWeightsSum[OtherIndex]+(Overwrite^.Weights[OtherIndex]*Factor);
      end;
      WeightsFactorSum:=WeightsFactorSum+Factor;
     end;
    end;
   end;
   if TranslationSum.FactorSum>0.0 then begin
    Factor:=1.0/TranslationSum.FactorSum;
    Translation[0]:=TranslationSum.x*Factor;
    Translation[1]:=TranslationSum.y*Factor;
    Translation[2]:=TranslationSum.z*Factor;
   end else begin
    Translation:=Node^.Translation;
   end;
   if ScaleSum.FactorSum>0.0 then begin
    Factor:=1.0/ScaleSum.FactorSum;
    Scale[0]:=ScaleSum.x*Factor;
    Scale[1]:=ScaleSum.y*Factor;
    Scale[2]:=ScaleSum.z*Factor;
   end else begin
    Scale:=Node^.Scale;
   end;
   if WeightedRotationFactorSum>0.0 then begin
    Rotation:=Vector4Normalize(WeightedRotation);
   end else begin
    Rotation:=Node.Rotation;
   end;
{  if RotationSum.FactorSum>0.0 then begin
    Factor:=1.0/RotationSum.FactorSum;
    Rotation[0]:=RotationSum.x*Factor;
    Rotation[1]:=RotationSum.y*Factor;
    Rotation[2]:=RotationSum.z*Factor;
    Rotation[3]:=RotationSum.w*Factor;
    Rotation:=Vector4Normalize(Rotation);
   end else begin
    Rotation:=Node^.Rotation;
   end;}
   if WeightsFactorSum>0.0 then begin
    Factor:=1.0/WeightsFactorSum;
    for Index:=0 to Min(length(InstanceNode^.WorkWeights),length(Node^.Weights))-1 do begin
     InstanceNode^.WorkWeights[Index]:=InstanceNode^.OverwriteWeightsSum[Index]*Factor;
    end;
   end else begin
    for Index:=0 to Min(length(InstanceNode^.WorkWeights),length(Node^.Weights))-1 do begin
     InstanceNode^.WorkWeights[Index]:=Node^.Weights[Index];
    end;
   end;
  end else begin
   if TpvGLTF.TInstance.TNode.TOverwriteFlag.Translation in InstanceNode^.OverwriteFlags then begin
    Translation:=InstanceNode^.OverwriteTranslation;
   end else begin
    Translation:=Node^.Translation;
   end;
   if TpvGLTF.TInstance.TNode.TOverwriteFlag.Scale in InstanceNode^.OverwriteFlags then begin
    Scale:=InstanceNode^.OverwriteScale;
   end else begin
    Scale:=Node^.Scale;
   end;
   if TpvGLTF.TInstance.TNode.TOverwriteFlag.Rotation in InstanceNode^.OverwriteFlags then begin
    Rotation:=InstanceNode^.OverwriteRotation;
   end else begin
    Rotation:=Node^.Rotation;
   end;
   if TpvGLTF.TInstance.TNode.TOverwriteFlag.Weights in InstanceNode^.OverwriteFlags then begin
    for Index:=0 to Min(length(InstanceNode^.WorkWeights),length(InstanceNode^.OverwriteWeights))-1 do begin
     InstanceNode^.WorkWeights[Index]:=InstanceNode^.OverwriteWeights[Index];
    end;
   end else begin
    for Index:=0 to Min(length(InstanceNode^.WorkWeights),length(Node^.Weights))-1 do begin
     InstanceNode^.WorkWeights[Index]:=Node^.Weights[Index];
    end;
   end;
  end;
  Matrix:=MatrixMul(
            MatrixFromScale(Scale),
            MatrixMul(
             MatrixFromRotation(Rotation),
             MatrixFromTranslation(Translation)));
  if assigned(fOnNodeMatrixPre) then begin
   fOnNodeMatrixPre(self,Node,InstanceNode,Matrix);
  end;
  Matrix:=MatrixMul(Matrix,Node^.Matrix);
  if assigned(fOnNodeMatrixPost) then begin
   fOnNodeMatrixPost(self,Node,InstanceNode,Matrix);
  end;
  Matrix:=MatrixMul(Matrix,aMatrix);
  InstanceNode^.WorkMatrix:=Matrix;
  if (Node^.Mesh>=0) and (Node^.Mesh<length(fParent.fMeshes)) then begin
   if (fAnimation>=0) and (Node^.Skin>=0) and (Node^.Skin<length(fSkins)) then begin
    fSkins[Node^.Skin].Used:=true;
   end;
  end;
  if (Node^.Light>=0) and (Node^.Light<=length(fLightNodes)) then begin
   fLightNodes[Node^.Light]:=aNodeIndex;
  end;
  for Index:=0 to length(Node^.Children)-1 do begin
   ProcessNode(Node^.Children[Index],Matrix);
  end;
 end;
var Index:TPasGLTFSizeInt;
    Scene:TpvGLTF.PScene;
    Animation:TpvGLTF.TInstance.TAnimation;
begin
 Scene:=GetScene;
 if assigned(Scene) then begin
  for Index:=0 to length(fLightNodes)-1 do begin
   fLightNodes[Index]:=-1;
  end;
  for Index:=0 to length(Scene^.Nodes)-1 do begin
   ResetNode(Scene^.Nodes[Index]);
  end;
  for Index:=0 to length(fSkins)-1 do begin
   fSkins[Index].Used:=false;
  end;
  if (fAnimation>=0) and (fAnimation<length(fParent.fAnimations)) then begin
   ProcessAnimation(fAnimation,fAnimationTime,-1.0);
  end else begin
   for Index:=-1 to length(fAnimations)-2 do begin
    Animation:=fAnimations[Index+1];
    if Animation.fFactor>=-0.5 then begin
     if Index<0 then begin
      ProcessBaseOverwrite(Animation.fFactor);
     end else begin
      ProcessAnimation(Index,Animation.fTime,Animation.fFactor);
     end;
    end;
   end;
  end;
  for Index:=0 to length(Scene^.Nodes)-1 do begin
   ProcessNode(Scene^.Nodes[Index],TPasGLTF.TDefaults.IdentityMatrix4x4);
  end;
 end;
end;

procedure TpvGLTF.TInstance.UpdateDynamicBoundingBox(const aHighQuality:boolean=false);
 procedure ProcessNodeLowQuality(const aNodeIndex:TPasGLTFSizeInt);
 var Index:TPasGLTFSizeInt;
     Matrix:TPasGLTF.TMatrix4x4;
     InstanceNode:TpvGLTF.TInstance.PNode;
     Node:TpvGLTF.PNode;
     Mesh:TpvGLTF.PMesh;
     Center,Extents,NewCenter,NewExtents:TVector3;
     SourceBoundingBox:TpvGLTF.PBoundingBox;
     BoundingBox:TpvGLTF.TBoundingBox;
 begin
  InstanceNode:=@fNodes[aNodeIndex];
  Node:=@fParent.fNodes[aNodeIndex];
  if Node^.Mesh>=0 then begin
   Mesh:=@fParent.fMeshes[Node^.Mesh];
   SourceBoundingBox:=@Mesh^.BoundingBox;
   Matrix:=InstanceNode^.WorkMatrix;
   Center[0]:=(SourceBoundingBox^.Min[0]+SourceBoundingBox^.Max[0])*0.5;
   Center[1]:=(SourceBoundingBox^.Min[1]+SourceBoundingBox^.Max[1])*0.5;
   Center[2]:=(SourceBoundingBox^.Min[2]+SourceBoundingBox^.Max[2])*0.5;
   Extents[0]:=(SourceBoundingBox^.Max[0]-SourceBoundingBox^.Min[0])*0.5;
   Extents[1]:=(SourceBoundingBox^.Max[1]-SourceBoundingBox^.Min[1])*0.5;
   Extents[2]:=(SourceBoundingBox^.Max[2]-SourceBoundingBox^.Min[2])*0.5;
   NewCenter[0]:=(Matrix[0]*Center[0])+(Matrix[4]*Center[1])+(Matrix[8]*Center[2])+Matrix[12];
   NewCenter[1]:=(Matrix[1]*Center[0])+(Matrix[5]*Center[1])+(Matrix[9]*Center[2])+Matrix[13];
   NewCenter[2]:=(Matrix[2]*Center[0])+(Matrix[6]*Center[1])+(Matrix[10]*Center[2])+Matrix[14];
   NewExtents[0]:=abs(Matrix[0]*Extents[0])+abs(Matrix[4]*Extents[1])+abs(Matrix[8]*Extents[2]);
   NewExtents[1]:=abs(Matrix[1]*Extents[0])+abs(Matrix[5]*Extents[1])+abs(Matrix[9]*Extents[2]);
   NewExtents[2]:=abs(Matrix[2]*Extents[0])+abs(Matrix[6]*Extents[1])+abs(Matrix[10]*Extents[2]);
   BoundingBox.Min[0]:=NewCenter[0]-NewExtents[0];
   BoundingBox.Min[1]:=NewCenter[1]-NewExtents[1];
   BoundingBox.Min[2]:=NewCenter[2]-NewExtents[2];
   BoundingBox.Max[0]:=NewCenter[0]+NewExtents[0];
   BoundingBox.Max[1]:=NewCenter[1]+NewExtents[1];
   BoundingBox.Max[2]:=NewCenter[2]+NewExtents[2];
   fDynamicBoundingBox.Min[0]:=Min(fDynamicBoundingBox.Min[0],BoundingBox.Min[0]);
   fDynamicBoundingBox.Min[1]:=Min(fDynamicBoundingBox.Min[1],BoundingBox.Min[1]);
   fDynamicBoundingBox.Min[2]:=Min(fDynamicBoundingBox.Min[2],BoundingBox.Min[2]);
   fDynamicBoundingBox.Max[0]:=Max(fDynamicBoundingBox.Max[0],BoundingBox.Max[0]);
   fDynamicBoundingBox.Max[1]:=Max(fDynamicBoundingBox.Max[1],BoundingBox.Max[1]);
   fDynamicBoundingBox.Max[2]:=Max(fDynamicBoundingBox.Max[2],BoundingBox.Max[2]);
  end;
  for Index:=0 to length(Node^.Children)-1 do begin
   ProcessNodeLowQuality(Node^.Children[Index]);
  end;
 end;
 procedure ProcessNodeHighQuality(const aNodeIndex:TPasGLTFSizeInt);
 var Index,
     PrimitiveIndex,
     VertexIndex,
     MorphTargetWeightIndex,
     JointPartIndex,
     JointWeightIndex,
     JointIndex:TPasGLTFSizeInt;
     Matrix:TPasGLTF.TMatrix4x4;
     InstanceNode:TpvGLTF.TInstance.PNode;
     Node:TpvGLTF.PNode;
     InstanceSkin:TpvGLTF.TInstance.PSkin;
     Skin:TpvGLTF.PSkin;
     Mesh:TpvGLTF.PMesh;
     Primitive:TpvGLTF.TMesh.PPrimitive;
     Vertex:TpvGLTF.PVertex;
     Position:TVector3;
     MorphTargetVertexPosition:PVector3;
     JointIndices:TPasGLTF.PUInt32Vector4;
     JointWeights:TPasGLTF.PVector4;
     JointWeight:TPasGLTFFloat;
     HasMorphTargets:boolean;
     InverseMatrix:TPasGLTF.TMatrix4x4;
 begin
  InstanceNode:=@fNodes[aNodeIndex];
  Node:=@fParent.fNodes[aNodeIndex];
  if Node^.Mesh>=0 then begin
   Mesh:=@fParent.fMeshes[Node^.Mesh];
   HasMorphTargets:=length(InstanceNode^.WorkWeights)>0;
   if Node^.Skin>=0 then begin
    InstanceSkin:=@fSkins[Node^.Skin];
    Skin:=@fParent.fSkins[Node^.Skin];
    InverseMatrix:=MatrixInverse(InstanceNode^.WorkMatrix);
   end else begin
    InstanceSkin:=nil;
    Skin:=nil;
    InverseMatrix[0]:=0.0;
   end;
   for PrimitiveIndex:=0 to length(Mesh^.Primitives)-1 do begin
    Primitive:=@Mesh^.Primitives[PrimitiveIndex];
    for VertexIndex:=0 to length(Primitive^.Vertices)-1 do begin
     Vertex:=@Primitive^.Vertices[VertexIndex];
     Position:=Vertex^.Position;
     if HasMorphTargets then begin
      for MorphTargetWeightIndex:=0 to length(InstanceNode^.WorkWeights)-1 do begin
       MorphTargetVertexPosition:=@Primitive^.Targets[MorphTargetWeightIndex].Vertices[VertexIndex].Position;
       Position:=Vector3Add(Position,Vector3Scale(MorphTargetVertexPosition^,InstanceNode^.WorkWeights[MorphTargetWeightIndex]));
      end;
     end;
     if assigned(Skin) then begin
      Matrix:=TPasGLTF.TDefaults.NullMatrix4x4;
      for JointPartIndex:=0 to 1 do begin
       case JointPartIndex of
        0:begin
         JointIndices:=@Vertex^.Joints0;
         JointWeights:=@Vertex^.Weights0;
        end;
        else begin
         JointIndices:=@Vertex^.Joints1;
         JointWeights:=@Vertex^.Weights1;
        end;
       end;
       for JointWeightIndex:=0 to 3 do begin
        JointIndex:=JointIndices^[JointWeightIndex];
        JointWeight:=JointWeights^[JointWeightIndex];
        if JointWeight<>0.0 then begin
         Matrix:=MatrixAdd(Matrix,
                           MatrixScale(MatrixMul(MatrixMul(Skin^.InverseBindMatrices[JointIndex],
                                                           fNodes[Skin^.Joints[JointIndex]].WorkMatrix),
                                                 InverseMatrix),
                                       JointWeight));
        end;
       end;
      end;
      Position:=Vector3MatrixMul(MatrixMul(Matrix,InstanceNode^.WorkMatrix),Position);
     end else begin
      Position:=Vector3MatrixMul(InstanceNode^.WorkMatrix,Position);
     end;
     fDynamicBoundingBox.Min[0]:=Min(fDynamicBoundingBox.Min[0],Position[0]);
     fDynamicBoundingBox.Min[1]:=Min(fDynamicBoundingBox.Min[1],Position[1]);
     fDynamicBoundingBox.Min[2]:=Min(fDynamicBoundingBox.Min[2],Position[2]);
     fDynamicBoundingBox.Max[0]:=Max(fDynamicBoundingBox.Max[0],Position[0]);
     fDynamicBoundingBox.Max[1]:=Max(fDynamicBoundingBox.Max[1],Position[1]);
     fDynamicBoundingBox.Max[2]:=Max(fDynamicBoundingBox.Max[2],Position[2]);
    end;
   end;
  end;
  for Index:=0 to length(Node^.Children)-1 do begin
   ProcessNodeHighQuality(Node^.Children[Index]);
  end;
 end;
{  procedure ProcessNode(const aNodeIndex:TPasGLTFSizeInt);
 var Index,CountJoints,JointIndex:TPasGLTFSizeInt;
     Matrix,InverseMatrix:TPasGLTF.TMatrix4x4;
     InstanceNode:TpvGLTF.TInstance.PNode;
     Node:TpvGLTF.PNode;
     Mesh:TpvGLTF.PMesh;
     Center,Extents,NewCenter,NewExtents:TVector3;
     Rotation:TVector4;
     SourceBoundingBox:TpvGLTF.PBoundingBox;
     BoundingBox:TpvGLTF.TBoundingBox;
     Skin:TpvGLTF.PSkin;
 begin
  InstanceNode:=@fNodes[aNodeIndex];
  Node:=@fParent.fNodes[aNodeIndex];
  if Node^.Mesh>=0 then begin
   Mesh:=@fParent.fMeshes[Node^.Mesh];
   SourceBoundingBox:=@Mesh^.BoundingBox;
   Center[0]:=(SourceBoundingBox^.Min[0]+SourceBoundingBox^.Max[0])*0.5;
   Center[1]:=(SourceBoundingBox^.Min[1]+SourceBoundingBox^.Max[1])*0.5;
   Center[2]:=(SourceBoundingBox^.Min[2]+SourceBoundingBox^.Max[2])*0.5;
   Extents[0]:=(SourceBoundingBox^.Max[0]-SourceBoundingBox^.Min[0])*0.5;
   Extents[1]:=(SourceBoundingBox^.Max[1]-SourceBoundingBox^.Min[1])*0.5;
   Extents[2]:=(SourceBoundingBox^.Max[2]-SourceBoundingBox^.Min[2])*0.5;
   if Node^.Skin>=0 then begin
    Skin:=@fParent.fSkins[Node^.Skin];
    CountJoints:=length(Skin^.Joints);
    InverseMatrix:=MatrixInverse(InstanceNode^.WorkMatrix);
   end else begin
    Skin:=nil;
    CountJoints:=0;
    InverseMatrix[0]:=0.0;
   end;
   Matrix:=InstanceNode^.WorkMatrix;
   for JointIndex:=-1 to CountJoints-1 do begin
    if JointIndex>=0 then begin
     if (JointIndex<length(Mesh^.JointWeights)) and (Mesh^.JointWeights[JointIndex]>0.0) then begin
      Matrix:=MatrixMul(MatrixScale(MatrixMul(MatrixMul(Skin^.InverseBindMatrices[JointIndex],fNodes[Skin^.Joints[JointIndex]].WorkMatrix),InverseMatrix),Mesh^.JointWeights[JointIndex]),InstanceNode^.WorkMatrix);
     end else begin
      continue;
     end;
    end;
    NewCenter[0]:=(Matrix[0]*Center[0])+(Matrix[4]*Center[1])+(Matrix[8]*Center[2])+Matrix[12];
    NewCenter[1]:=(Matrix[1]*Center[0])+(Matrix[5]*Center[1])+(Matrix[9]*Center[2])+Matrix[13];
    NewCenter[2]:=(Matrix[2]*Center[0])+(Matrix[6]*Center[1])+(Matrix[10]*Center[2])+Matrix[14];
    NewExtents[0]:=abs(Matrix[0]*Extents[0])+abs(Matrix[4]*Extents[1])+abs(Matrix[8]*Extents[2]);
    NewExtents[1]:=abs(Matrix[1]*Extents[0])+abs(Matrix[5]*Extents[1])+abs(Matrix[9]*Extents[2]);
    NewExtents[2]:=abs(Matrix[2]*Extents[0])+abs(Matrix[6]*Extents[1])+abs(Matrix[10]*Extents[2]);
    BoundingBox.Min[0]:=NewCenter[0]-NewExtents[0];
    BoundingBox.Min[1]:=NewCenter[1]-NewExtents[1];
    BoundingBox.Min[2]:=NewCenter[2]-NewExtents[2];
    BoundingBox.Max[0]:=NewCenter[0]+NewExtents[0];
    BoundingBox.Max[1]:=NewCenter[1]+NewExtents[1];
    BoundingBox.Max[2]:=NewCenter[2]+NewExtents[2];
    fDynamicBoundingBox.Min[0]:=Min(fDynamicBoundingBox.Min[0],BoundingBox.Min[0]);
    fDynamicBoundingBox.Min[1]:=Min(fDynamicBoundingBox.Min[1],BoundingBox.Min[1]);
    fDynamicBoundingBox.Min[2]:=Min(fDynamicBoundingBox.Min[2],BoundingBox.Min[2]);
    fDynamicBoundingBox.Max[0]:=Max(fDynamicBoundingBox.Max[0],BoundingBox.Max[0]);
    fDynamicBoundingBox.Max[1]:=Max(fDynamicBoundingBox.Max[1],BoundingBox.Max[1]);
    fDynamicBoundingBox.Max[2]:=Max(fDynamicBoundingBox.Max[2],BoundingBox.Max[2]);
   end;
  end;
  for Index:=0 to length(Node^.Children)-1 do begin
   ProcessNode(Node^.Children[Index]);
  end;
 end;}
var Index:TPasGLTFSizeInt;
    Scene:TpvGLTF.PScene;
begin
 fDynamicBoundingBox:=EmptyBoundingBox;
 Scene:=GetScene;
 if assigned(Scene) then begin
  if aHighQuality then begin
   for Index:=0 to length(Scene^.Nodes)-1 do begin
    ProcessNodeHighQuality(Scene^.Nodes[Index]);
   end;
  end else begin
   for Index:=0 to length(Scene^.Nodes)-1 do begin
    ProcessNodeLowQuality(Scene^.Nodes[Index]);
   end;
  end;
 end;
end;

procedure TpvGLTF.TInstance.UpdateWorstCaseStaticBoundingBox;
 procedure ProcessNode(const aNodeIndex:TPasGLTFSizeInt);
 var Index,
     PrimitiveIndex,
     VertexIndex,
     MorphTargetWeightIndex,
     JointPartIndex,
     JointWeightIndex,
     JointIndex:TPasGLTFSizeInt;
     Matrix:TPasGLTF.TMatrix4x4;
     InstanceNode:TpvGLTF.TInstance.PNode;
     Node:TpvGLTF.PNode;
     InstanceSkin:TpvGLTF.TInstance.PSkin;
     Skin:TpvGLTF.PSkin;
     Mesh:TpvGLTF.PMesh;
     Primitive:TpvGLTF.TMesh.PPrimitive;
     Vertex:TpvGLTF.PVertex;
     Position:TVector3;
     MorphTargetVertexPosition:PVector3;
     JointIndices:TPasGLTF.PUInt32Vector4;
     JointWeights:TPasGLTF.PVector4;
     JointWeight:TPasGLTFFloat;
     HasMorphTargets:boolean;
     InverseMatrix:TPasGLTF.TMatrix4x4;
 begin
  InstanceNode:=@fNodes[aNodeIndex];
  Node:=@fParent.fNodes[aNodeIndex];
  if Node^.Mesh>=0 then begin
   Mesh:=@fParent.fMeshes[Node^.Mesh];
   HasMorphTargets:=length(InstanceNode^.WorkWeights)>0;
   if Node^.Skin>=0 then begin
    InstanceSkin:=@fSkins[Node^.Skin];
    Skin:=@fParent.fSkins[Node^.Skin];
    InverseMatrix:=MatrixInverse(InstanceNode^.WorkMatrix);
   end else begin
    InstanceSkin:=nil;
    Skin:=nil;
    InverseMatrix[0]:=0.0;
   end;
   for PrimitiveIndex:=0 to length(Mesh^.Primitives)-1 do begin
    Primitive:=@Mesh^.Primitives[PrimitiveIndex];
    for VertexIndex:=0 to length(Primitive^.Vertices)-1 do begin
     Vertex:=@Primitive^.Vertices[VertexIndex];
     Position:=Vertex^.Position;
     if HasMorphTargets then begin
      for MorphTargetWeightIndex:=0 to length(InstanceNode^.WorkWeights)-1 do begin
       MorphTargetVertexPosition:=@Primitive^.Targets[MorphTargetWeightIndex].Vertices[VertexIndex].Position;
       Position:=Vector3Add(Position,Vector3Scale(MorphTargetVertexPosition^,InstanceNode^.WorkWeights[MorphTargetWeightIndex]));
      end;
     end;
     if assigned(Skin) then begin
      Matrix:=TPasGLTF.TDefaults.NullMatrix4x4;
      for JointPartIndex:=0 to 1 do begin
       case JointPartIndex of
        0:begin
         JointIndices:=@Vertex^.Joints0;
         JointWeights:=@Vertex^.Weights0;
        end;
        else begin
         JointIndices:=@Vertex^.Joints1;
         JointWeights:=@Vertex^.Weights1;
        end;
       end;
       for JointWeightIndex:=0 to 3 do begin
        JointIndex:=JointIndices^[JointWeightIndex];
        JointWeight:=JointWeights^[JointWeightIndex];
        if JointWeight<>0.0 then begin
         Matrix:=MatrixAdd(Matrix,
                           MatrixScale(MatrixMul(MatrixMul(Skin^.InverseBindMatrices[JointIndex],
                                                           fNodes[Skin^.Joints[JointIndex]].WorkMatrix),
                                                 InverseMatrix),
                                       JointWeight));
        end;
       end;
      end;
      Position:=Vector3MatrixMul(MatrixMul(Matrix,InstanceNode^.WorkMatrix),Position);
     end else begin
      Position:=Vector3MatrixMul(InstanceNode^.WorkMatrix,Position);
     end;
     fWorstCaseStaticBoundingBox.Min[0]:=Min(fWorstCaseStaticBoundingBox.Min[0],Position[0]);
     fWorstCaseStaticBoundingBox.Min[1]:=Min(fWorstCaseStaticBoundingBox.Min[1],Position[1]);
     fWorstCaseStaticBoundingBox.Min[2]:=Min(fWorstCaseStaticBoundingBox.Min[2],Position[2]);
     fWorstCaseStaticBoundingBox.Max[0]:=Max(fWorstCaseStaticBoundingBox.Max[0],Position[0]);
     fWorstCaseStaticBoundingBox.Max[1]:=Max(fWorstCaseStaticBoundingBox.Max[1],Position[1]);
     fWorstCaseStaticBoundingBox.Max[2]:=Max(fWorstCaseStaticBoundingBox.Max[2],Position[2]);
    end;
   end;
  end;
  for Index:=0 to length(Node^.Children)-1 do begin
   ProcessNode(Node^.Children[Index]);
  end;
 end;
var Index,TimeArraySize,TimeArrayIndex:TPasGLTFSizeInt;
    Scene:TpvGLTF.PScene;
    Animation:TpvGLTF.PAnimation;
    AnimationChannel:TpvGLTF.TAnimation.PChannel;
    TimeArray:TPasGLTFFloatDynamicArray;
begin
 fWorstCaseStaticBoundingBox:=EmptyBoundingBox;
 Scene:=GetScene;
 if assigned(Scene) then begin
  if (fAnimation<0) or (fAnimation>=length(fParent.fAnimations)) then begin
   UpdateDynamicBoundingBox(false);
   fWorstCaseStaticBoundingBox:=fDynamicBoundingBox;
  end else begin
   Animation:=@fParent.fAnimations[fAnimation];
   TimeArray:=nil;
   try
    TimeArraySize:=0;
    try
     for Index:=0 to length(Animation^.Channels)-1 do begin
      AnimationChannel:=@Animation^.Channels[Index];
      if length(AnimationChannel^.InputTimeArray)>0 then begin
       if length(TimeArray)<(TimeArraySize+length(AnimationChannel^.InputTimeArray)) then begin
        SetLength(TimeArray,(TimeArraySize+length(AnimationChannel^.InputTimeArray))*2);
       end;
       Move(AnimationChannel^.InputTimeArray[0],TimeArray[TimeArraySize],length(AnimationChannel^.InputTimeArray)*SizeOf(TPasGLTFFloat));
       inc(TimeArraySize,length(AnimationChannel^.InputTimeArray));
      end;
     end;
    finally
     SetLength(TimeArray,TimeArraySize);
    end;
    if TimeArraySize>1 then begin
     TPasGLTFTypedSort<TPasGLTFFloat>.IntroSort(@TimeArray[0],0,TimeArraySize-1,CompareFloats);
    end;
    for TimeArrayIndex:=0 to TimeArraySize-1 do begin
     fAnimationTime:=TimeArray[TimeArrayIndex];
     if (TimeArrayIndex=0) or not SameValue(TimeArray[TimeArrayIndex-1],fAnimationTime) then begin
      Update;
      for Index:=0 to length(Scene^.Nodes)-1 do begin
       ProcessNode(Scene^.Nodes[Index]);
      end;
     end;
    end;
   finally
    TimeArray:=nil;
   end;
  end;
 end;
end;

procedure TpvGLTF.TInstance.Upload;
var Index:TPasGLTFSizeInt;
    Scene:PScene;
begin
 Scene:=GetScene;
 if assigned(Scene) then begin
 end;
end;

function TpvGLTF.TInstance.GetCamera(const aNodeIndex:TPasGLTFSizeInt;
                                         out aViewMatrix:TPasGLTF.TMatrix4x4;
                                         out aProjectionMatrix:TPasGLTF.TMatrix4x4;
                                         const aReversedZWithInfiniteFarPlane:boolean=false):boolean;
const DEG2RAD=PI/180;
var NodeMatrix:TPasGLTF.TMatrix4x4;
    Camera:TpvGLTF.PCamera;
    f:TPasGLTFFloat;
begin
 result:=((aNodeIndex>=0) and (aNodeIndex<length(fParent.fNodes))) and
         ((fParent.fNodes[aNodeIndex].Camera>=0) and (fParent.fNodes[aNodeIndex].Camera<length(fParent.fCameras)));
 if result then begin
  Camera:=@fParent.fCameras[fParent.fNodes[aNodeIndex].Camera];
  NodeMatrix:=fNodes[aNodeIndex].WorkMatrix;
  aViewMatrix:=MatrixInverse(NodeMatrix);
  case Camera.Type_ of
   TPasGLTF.TCamera.TType.Orthographic:begin
    aProjectionMatrix[0]:=2.0/Camera^.XMag;
    aProjectionMatrix[1]:=0.0;
    aProjectionMatrix[2]:=0.0;
    aProjectionMatrix[3]:=0.0;
    aProjectionMatrix[4]:=0.0;
    aProjectionMatrix[5]:=2.0/Camera^.YMag;
    aProjectionMatrix[6]:=0.0;
    aProjectionMatrix[7]:=0.0;
    aProjectionMatrix[8]:=0.0;
    aProjectionMatrix[9]:=0.0;
    aProjectionMatrix[10]:=(-2.0)/(Camera^.ZFar-Camera^.ZNear);
    aProjectionMatrix[11]:=0.0;
    aProjectionMatrix[12]:=0.0; // simplified from: (-((Camera^.XMag*0.5)+(Camera^.XMag*-0.5)))/Camera^.XMag;
    aProjectionMatrix[13]:=0.0; // simplified from: (-((Camera^.YMag*0.5)+(Camera^.YMag*-0.5)))/Camera^.YMag;
    aProjectionMatrix[14]:=(-(Camera^.ZFar+Camera^.ZNear))/(Camera^.ZFar-Camera^.ZNear);
    aProjectionMatrix[15]:=1.0;
   end;
   TPasGLTF.TCamera.TType.Perspective:begin
    f:=1.0/tan(Camera^.YFov*0.5);
    aProjectionMatrix[0]:=f/Camera^.AspectRatio;
    aProjectionMatrix[1]:=0.0;
    aProjectionMatrix[2]:=0.0;
    aProjectionMatrix[3]:=0.0;
    aProjectionMatrix[4]:=0.0;
    aProjectionMatrix[5]:=f;
    aProjectionMatrix[6]:=0.0;
    aProjectionMatrix[7]:=0.0;
    if aReversedZWithInfiniteFarPlane then begin
     // Reversed Z with infinite far plane (so zfar is ignored here)
     aProjectionMatrix[8]:=0.0;
     aProjectionMatrix[9]:=0.0;
     aProjectionMatrix[10]:=0.0;
     aProjectionMatrix[11]:=-1.0;
     aProjectionMatrix[12]:=0.0;
     aProjectionMatrix[13]:=0.0;
     aProjectionMatrix[14]:=Camera^.ZNear;
     aProjectionMatrix[15]:=0.0;
    end else begin
     // Traditional
     aProjectionMatrix[8]:=0.0;
     aProjectionMatrix[9]:=0.0;
     aProjectionMatrix[10]:=(-(Camera^.ZFar+Camera^.ZNear))/(Camera^.ZFar-Camera^.ZNear);
     aProjectionMatrix[11]:=-1.0;
     aProjectionMatrix[12]:=0.0;
     aProjectionMatrix[13]:=0.0;
     aProjectionMatrix[14]:=(-(2.0*Camera^.ZNear*Camera^.ZFar))/(Camera^.ZFar-Camera^.ZNear);
     aProjectionMatrix[15]:=0.0;
    end;
   end;
   else begin
    result:=false;
   end;
  end;
 end;
end;

function TpvGLTF.TInstance.GetBakedMesh(const aRelative:boolean=false;
                                        const aWithDynamicMeshs:boolean=false;
                                        const aRootNodeIndex:TpvSizeInt=-1;
                                        const aMaterialAlphaModes:TPasGLTF.TMaterial.TAlphaModes=[TPasGLTF.TMaterial.TAlphaMode.Opaque,TPasGLTF.TMaterial.TAlphaMode.Blend,TPasGLTF.TMaterial.TAlphaMode.Mask]):TpvGLTF.TBakedMesh;
var BakedMesh:TpvGLTF.TBakedMesh;
 procedure ProcessMorphSkinNode(const aNode:TpvGLTF.PNode;const aInstanceNode:TpvGLTF.TInstance.PNode);
 type TBakedVertex=record
       Position:TpvVector3;
       Normal:TpvVector3;
      end;
      PBakedVertex=^TBakedVertex;
      TBakedVertices=array of TBakedVertex;
      TTemporaryTriangleIndices=array of TpvSizeInt;
 var PrimitiveIndex,VertexIndex,JointBlockIndex,JointIndex,IndexIndex,SideIndex,
     MorphTargetWeightIndex,JointPartIndex,JointWeightIndex:TpvSizeInt;
     Mesh:TpvGLTF.PMesh;
     Skin:TpvGLTF.PSkin;
     InverseMatrix,Matrix,ModelNodeMatrix,ModelNodeMatrixEx:TpvMatrix4x4;
     Primitive:TpvGLTF.TMesh.PPrimitive;
     Vertex:TpvGLTF.PVertex;
     Position,Normal:TpvVector3;
     BakedVertices:TBakedVertices;
     BakedVertex:PBakedVertex;
     BakedTriangle:TpvGLTF.TBakedMesh.PTriangle;
     TemporaryTriangleIndices:TTemporaryTriangleIndices;
     JointIndices:TPasGLTF.PUInt32Vector4;
     JointWeights:TPasGLTF.PVector4;
     JointWeight:TPasGLTFFloat;
 begin
  BakedVertices:=nil;
  try
   if aNode.Mesh>=0 then begin
    Mesh:=@fParent.fMeshes[aNode.Mesh];
   end else begin
    Mesh:=nil;
   end;
   if assigned(Mesh) and
      (aWithDynamicMeshs or
       ((not aWithDynamicMeshs) and
        ((aNode.Skin<0) and
         (length(aNode.Weights)=0) and
         ((aInstanceNode^.CountOverwrites=0) or
          ((aInstanceNode^.CountOverwrites=1) and
           ((aInstanceNode^.Overwrites[0].Flags=[TpvGLTF.TInstance.TNode.TOverwriteFlag.Defaults]))))))) then begin
    if aNode.Skin>=0 then begin
     Skin:=@fParent.fSkins[aNode.Skin];
    end else begin
     Skin:=nil;
    end;
    if assigned(Skin) then begin
     InverseMatrix:=TpvMatrix4x4(pointer(@aInstanceNode^.WorkMatrix)^).Inverse;
    end else begin
     InverseMatrix:=TpvMatrix4x4.Identity;
    end;
    ModelNodeMatrixEx:=TpvMatrix4x4(pointer(@aInstanceNode^.WorkMatrix)^);
{   if not aRelative then begin
     ModelNodeMatrixEx:=ModelNodeMatrixEx*fModelMatrix;
    end;}
    for PrimitiveIndex:=0 to length(Mesh.Primitives)-1 do begin
     Primitive:=@Mesh.Primitives[PrimitiveIndex];
     if (Primitive^.Material<0) or
        ((Primitive^.Material>=0) and
         (fParent.Materials[Primitive^.Material].AlphaMode in aMaterialAlphaModes)) then begin
      case Primitive^.PrimitiveMode of
       GL_TRIANGLES,
       GL_TRIANGLE_STRIP,
       GL_TRIANGLE_FAN:begin
        SetLength(BakedVertices,Primitive^.CountVertices);
        for VertexIndex:=0 to Primitive^.CountVertices-1 do begin
         Vertex:=@Primitive.Vertices[VertexIndex];
         BakedVertex:=@BakedVertices[VertexIndex];
         Position:=TpvVector3(pointer(@Vertex^.Position)^);
         Normal:=TpvVector3(pointer(@Vertex^.Normal)^);
         for MorphTargetWeightIndex:=0 to length(aInstanceNode^.WorkWeights)-1 do begin
          Position:=Position+(TpvVector3(pointer(@Primitive^.Targets[MorphTargetWeightIndex].Vertices[VertexIndex].Position)^)*aInstanceNode^.WorkWeights[MorphTargetWeightIndex]);
          Normal:=Normal+(TpvVector3(pointer(@Primitive^.Targets[MorphTargetWeightIndex].Vertices[VertexIndex].Normal)^)*aInstanceNode^.WorkWeights[MorphTargetWeightIndex]);
         end;
         Normal:=Normal.Normalize;
         ModelNodeMatrix:=ModelNodeMatrixEx;
         if assigned(Skin) then begin
          Matrix:=TpvMatrix4x4.Identity;
          for JointPartIndex:=0 to 1 do begin
           case JointPartIndex of
            0:begin
             JointIndices:=@Vertex^.Joints0;
             JointWeights:=@Vertex^.Weights0;
            end;
            else begin
             JointIndices:=@Vertex^.Joints1;
             JointWeights:=@Vertex^.Weights1;
            end;
           end;
           for JointWeightIndex:=0 to 3 do begin
            JointIndex:=JointIndices^[JointWeightIndex];
            JointWeight:=JointWeights^[JointWeightIndex];
            if JointWeight<>0.0 then begin
             Matrix:=Matrix+(((TpvMatrix4x4(pointer(@Skin^.InverseBindMatrices[JointIndex])^)*
                               TpvMatrix4x4(pointer(@fNodes[Skin^.Joints[JointIndex]].WorkMatrix)^))*
                              InverseMatrix)*JointWeight);
            end;
           end;
          end;
          ModelNodeMatrix:=Matrix*ModelNodeMatrix;
         end;
         BakedVertex^.Position:=ModelNodeMatrix.MulHomogen(Position);
         BakedVertex^.Normal:=ModelNodeMatrix.Transpose.Inverse.MulBasis(Normal);
        end;
        TemporaryTriangleIndices:=nil;
        try
         case Primitive^.PrimitiveMode of
          GL_TRIANGLES:begin
           SetLength(TemporaryTriangleIndices,Primitive^.CountIndices);
           for IndexIndex:=0 to Primitive^.CountIndices-1 do begin
            TemporaryTriangleIndices[IndexIndex]:=Primitive^.Indices[IndexIndex];
           end;
          end;
          GL_TRIANGLE_STRIP:begin
           SetLength(TemporaryTriangleIndices,(Primitive^.CountIndices-2)*3);
           for IndexIndex:=0 to Primitive^.CountIndices-3 do begin
            if (IndexIndex and 1)<>0 then begin
             TemporaryTriangleIndices[(IndexIndex*3)+0]:=Primitive^.Indices[IndexIndex+0];
             TemporaryTriangleIndices[(IndexIndex*3)+1]:=Primitive^.Indices[IndexIndex+1];
             TemporaryTriangleIndices[(IndexIndex*3)+2]:=Primitive^.Indices[IndexIndex+2];
            end else begin
             TemporaryTriangleIndices[(IndexIndex*3)+0]:=Primitive^.Indices[IndexIndex+0];
             TemporaryTriangleIndices[(IndexIndex*3)+1]:=Primitive^.Indices[IndexIndex+2];
             TemporaryTriangleIndices[(IndexIndex*3)+2]:=Primitive^.Indices[IndexIndex+1];
            end;
           end;
          end;
          GL_TRIANGLE_FAN:begin
           SetLength(TemporaryTriangleIndices,(Primitive^.CountIndices-2)*3);
           for IndexIndex:=2 to Primitive^.CountIndices-1 do begin
            TemporaryTriangleIndices[((IndexIndex-1)*3)+0]:=Primitive^.Indices[0];
            TemporaryTriangleIndices[((IndexIndex-1)*3)+1]:=Primitive^.Indices[IndexIndex-1];
            TemporaryTriangleIndices[((IndexIndex-1)*3)+2]:=Primitive^.Indices[IndexIndex];
           end;
          end;
          else begin
          end;
         end;
         IndexIndex:=0;
         while (IndexIndex+2)<length(TemporaryTriangleIndices) do begin
          for SideIndex:=0 to ord(fParent.Materials[Primitive^.Material].DoubleSided) and 1 do begin
           BakedTriangle:=Pointer(BakedMesh.fTriangles.AddNew);
           try
            if SideIndex>0 then begin
             BakedTriangle^.Positions[0]:=BakedVertices[TemporaryTriangleIndices[IndexIndex+2]].Position;
             BakedTriangle^.Positions[1]:=BakedVertices[TemporaryTriangleIndices[IndexIndex+1]].Position;
             BakedTriangle^.Positions[2]:=BakedVertices[TemporaryTriangleIndices[IndexIndex+0]].Position;
             BakedTriangle^.Normals[0]:=-BakedVertices[TemporaryTriangleIndices[IndexIndex+2]].Normal;
             BakedTriangle^.Normals[1]:=-BakedVertices[TemporaryTriangleIndices[IndexIndex+1]].Normal;
             BakedTriangle^.Normals[2]:=-BakedVertices[TemporaryTriangleIndices[IndexIndex+0]].Normal;
             BakedTriangle^.Normal:=-(BakedVertices[TemporaryTriangleIndices[IndexIndex+0]].Normal+BakedVertices[TemporaryTriangleIndices[IndexIndex+1]].Normal+BakedVertices[TemporaryTriangleIndices[IndexIndex+2]].Normal).Normalize;
            end else begin
             BakedTriangle^.Positions[0]:=BakedVertices[TemporaryTriangleIndices[IndexIndex+0]].Position;
             BakedTriangle^.Positions[1]:=BakedVertices[TemporaryTriangleIndices[IndexIndex+1]].Position;
             BakedTriangle^.Positions[2]:=BakedVertices[TemporaryTriangleIndices[IndexIndex+2]].Position;
             BakedTriangle^.Normals[0]:=BakedVertices[TemporaryTriangleIndices[IndexIndex+0]].Normal;
             BakedTriangle^.Normals[1]:=BakedVertices[TemporaryTriangleIndices[IndexIndex+1]].Normal;
             BakedTriangle^.Normals[2]:=BakedVertices[TemporaryTriangleIndices[IndexIndex+2]].Normal;
             BakedTriangle^.Normal:=(BakedVertices[TemporaryTriangleIndices[IndexIndex+0]].Normal+BakedVertices[TemporaryTriangleIndices[IndexIndex+1]].Normal+BakedVertices[TemporaryTriangleIndices[IndexIndex+2]].Normal).Normalize;
            end;
           finally
           end;
          end;
          inc(IndexIndex,3);
         end;
        finally
         TemporaryTriangleIndices:=nil;
        end;
       end;
       else begin
       end;
      end;
     end;
    end;
   end;
  finally
   BakedVertices:=nil;
  end;
 end;
type TNodeStack=TpvDynamicStack<TpvSizeInt>;
var Index,NodeIndex:TpvSizeInt;
    NodeStack:TNodeStack;
    GroupScene:TpvGLTF.PScene;
    GroupNode:TpvGLTF.PNode;
    GroupInstanceNode:TpvGLTF.TInstance.PNode;
begin
 BakedMesh:=TpvGLTF.TBakedMesh.Create;
 try
  NodeStack.Initialize;
  try
   if (aRootNodeIndex>=0) and (aRootNodeIndex<length(fParent.fNodes)) then begin
    NodeStack.Push(aRootNodeIndex);
   end else begin
    if (fScene>=0) and (fScene<length(fParent.fScenes)) then begin
     GroupScene:=@fParent.fScenes[fScene];
    end else if length(fParent.fScenes)>0 then begin
     GroupScene:=@fParent.fScenes[0];
    end else begin
     GroupScene:=nil;
    end;
    if assigned(GroupScene) then begin
     for Index:=length(GroupScene.Nodes)-1 downto 0 do begin
      NodeStack.Push(GroupScene.Nodes[Index]);
     end;
    end;
   end;
   while NodeStack.Pop(NodeIndex) do begin
    GroupNode:=@fParent.fNodes[NodeIndex];
    GroupInstanceNode:=@fNodes[NodeIndex];
    if ((aRootNodeIndex>=0) and
        (NodeIndex=aRootNodeIndex)) or
       (aWithDynamicMeshs or
        ((not aWithDynamicMeshs) and
         ((GroupInstanceNode^.CountOverwrites=0) or
          ((GroupInstanceNode^.CountOverwrites=1) and
           ((GroupInstanceNode^.Overwrites[0].Flags=[TpvGLTF.TInstance.TNode.TOverwriteFlag.Defaults])))))) then begin
     for Index:=length(GroupNode.Children)-1 downto 0 do begin
      NodeStack.Push(GroupNode.Children[Index]);
     end;
     if GroupNode.Mesh>=0 then begin
      ProcessMorphSkinNode(GroupNode,GroupInstanceNode);
     end;
    end;
   end;
  finally
   NodeStack.Finalize;
  end;
 finally
  result:=BakedMesh;
 end;
end;

function TpvGLTF.TInstance.GetBakedVertexIndexedMesh(const aRelative:boolean=false;
                                                     const aWithDynamicMeshs:boolean=false;
                                                     const aRootNodeIndex:TpvSizeInt=-1;
                                                     const aMaterialAlphaModes:TPasGLTF.TMaterial.TAlphaModes=[TPasGLTF.TMaterial.TAlphaMode.Opaque,TPasGLTF.TMaterial.TAlphaMode.Blend,TPasGLTF.TMaterial.TAlphaMode.Mask]):TpvGLTF.TBakedVertexIndexedMesh;
var BakedVertexIndexedMesh:TpvGLTF.TBakedVertexIndexedMesh;
 procedure ProcessMorphSkinNode(const aNode:TpvGLTF.PNode;const aInstanceNode:TpvGLTF.TInstance.PNode);
 type TBakedVertex=record
       Position:TpvVector3;
       Normal:TpvVector3;
       Tangent:TpvVector3;
      end;
      PBakedVertex=^TBakedVertex;
      TBakedVertices=array of TBakedVertex;
      TTemporaryTriangleIndices=array of TpvSizeInt;
 var PrimitiveIndex,VertexIndex,JointBlockIndex,JointIndex,IndexIndex,SideIndex,
     MorphTargetWeightIndex,JointPartIndex,JointWeightIndex:TpvSizeInt;
     Mesh:TpvGLTF.PMesh;
     Skin:TpvGLTF.PSkin;
     InverseMatrix,Matrix,ModelNodeMatrix,ModelNodeMatrixEx:TpvMatrix4x4;
     Primitive:TpvGLTF.TMesh.PPrimitive;
     Vertex:TpvGLTF.PVertex;
     Position,Normal,Tangent:TpvVector3;
     BakedVertices:TBakedVertices;
     BakedVertex:PBakedVertex;
     BakedTriangle:TpvGLTF.TBakedMesh.PTriangle;
     TemporaryTriangleIndices:TTemporaryTriangleIndices;
     JointIndices:TPasGLTF.PUInt32Vector4;
     JointWeights:TPasGLTF.PVector4;
     JointWeight:TPasGLTFFloat;
     OutVertex:TpvGLTF.TVertex;
 begin
  BakedVertices:=nil;
  try
   if aNode.Mesh>=0 then begin
    Mesh:=@fParent.fMeshes[aNode.Mesh];
   end else begin
    Mesh:=nil;
   end;
   if assigned(Mesh) and
      (aWithDynamicMeshs or
       ((not aWithDynamicMeshs) and
        ((aNode.Skin<0) and
         (length(aNode.Weights)=0) and
         ((aInstanceNode^.CountOverwrites=0) or
          ((aInstanceNode^.CountOverwrites=1) and
           ((aInstanceNode^.Overwrites[0].Flags=[TpvGLTF.TInstance.TNode.TOverwriteFlag.Defaults]))))))) then begin
    if aNode.Skin>=0 then begin
     Skin:=@fParent.fSkins[aNode.Skin];
    end else begin
     Skin:=nil;
    end;
    if assigned(Skin) then begin
     InverseMatrix:=TpvMatrix4x4(pointer(@aInstanceNode^.WorkMatrix)^).Inverse;
    end else begin
     InverseMatrix:=TpvMatrix4x4.Identity;
    end;
    ModelNodeMatrixEx:=TpvMatrix4x4(pointer(@aInstanceNode^.WorkMatrix)^);
{   if not aRelative then begin
     ModelNodeMatrixEx:=ModelNodeMatrixEx*fModelMatrix;
    end;}
    for PrimitiveIndex:=0 to length(Mesh.Primitives)-1 do begin
     Primitive:=@Mesh.Primitives[PrimitiveIndex];
     if (Primitive^.Material<0) or
        ((Primitive^.Material>=0) and
         (fParent.Materials[Primitive^.Material].AlphaMode in aMaterialAlphaModes)) then begin
      case Primitive^.PrimitiveMode of
       GL_TRIANGLES,
       GL_TRIANGLE_STRIP,
       GL_TRIANGLE_FAN:begin
        SetLength(BakedVertices,Primitive^.CountVertices);
        for VertexIndex:=0 to Primitive^.CountVertices-1 do begin
         Vertex:=@Primitive.Vertices[VertexIndex];
         BakedVertex:=@BakedVertices[VertexIndex];
         Position:=TpvVector3(pointer(@Vertex^.Position)^);
         Normal:=TpvVector3(pointer(@Vertex^.Normal)^);
         Tangent:=TpvVector3(pointer(@Vertex^.Tangent)^);
         for MorphTargetWeightIndex:=0 to length(aInstanceNode^.WorkWeights)-1 do begin
          Position:=Position+(TpvVector3(pointer(@Primitive^.Targets[MorphTargetWeightIndex].Vertices[VertexIndex].Position)^)*aInstanceNode^.WorkWeights[MorphTargetWeightIndex]);
          Normal:=Normal+(TpvVector3(pointer(@Primitive^.Targets[MorphTargetWeightIndex].Vertices[VertexIndex].Normal)^)*aInstanceNode^.WorkWeights[MorphTargetWeightIndex]);
          Tangent:=Tangent+(TpvVector3(pointer(@Primitive^.Targets[MorphTargetWeightIndex].Vertices[VertexIndex].Tangent)^)*aInstanceNode^.WorkWeights[MorphTargetWeightIndex]);
         end;
         Normal:=Normal.Normalize;
         Tangent:=Tangent.Normalize;
         ModelNodeMatrix:=ModelNodeMatrixEx;
         if assigned(Skin) then begin
          Matrix:=TpvMatrix4x4.Identity;
          for JointPartIndex:=0 to 1 do begin
           case JointPartIndex of
            0:begin
             JointIndices:=@Vertex^.Joints0;
             JointWeights:=@Vertex^.Weights0;
            end;
            else begin
             JointIndices:=@Vertex^.Joints1;
             JointWeights:=@Vertex^.Weights1;
            end;
           end;
           for JointWeightIndex:=0 to 3 do begin
            JointIndex:=JointIndices^[JointWeightIndex];
            JointWeight:=JointWeights^[JointWeightIndex];
            if JointWeight<>0.0 then begin
             Matrix:=Matrix+(((TpvMatrix4x4(pointer(@Skin^.InverseBindMatrices[JointIndex])^)*
                               TpvMatrix4x4(pointer(@fNodes[Skin^.Joints[JointIndex]].WorkMatrix)^))*
                              InverseMatrix)*JointWeight);
            end;
           end;
          end;
          ModelNodeMatrix:=Matrix*ModelNodeMatrix;
         end;
         BakedVertex^.Position:=ModelNodeMatrix.MulHomogen(Position);
         BakedVertex^.Normal:=ModelNodeMatrix.Transpose.Inverse.MulBasis(Normal);
         BakedVertex^.Tangent:=ModelNodeMatrix.Transpose.Inverse.MulBasis(Tangent);
        end;
        TemporaryTriangleIndices:=nil;
        try
         case Primitive^.PrimitiveMode of
          GL_TRIANGLES:begin
           SetLength(TemporaryTriangleIndices,Primitive^.CountIndices);
           for IndexIndex:=0 to Primitive^.CountIndices-1 do begin
            TemporaryTriangleIndices[IndexIndex]:=Primitive^.Indices[IndexIndex];
           end;
          end;
          GL_TRIANGLE_STRIP:begin
           SetLength(TemporaryTriangleIndices,(Primitive^.CountIndices-2)*3);
           for IndexIndex:=0 to Primitive^.CountIndices-3 do begin
            if (IndexIndex and 1)<>0 then begin
             TemporaryTriangleIndices[(IndexIndex*3)+0]:=Primitive^.Indices[IndexIndex+0];
             TemporaryTriangleIndices[(IndexIndex*3)+1]:=Primitive^.Indices[IndexIndex+1];
             TemporaryTriangleIndices[(IndexIndex*3)+2]:=Primitive^.Indices[IndexIndex+2];
            end else begin
             TemporaryTriangleIndices[(IndexIndex*3)+0]:=Primitive^.Indices[IndexIndex+0];
             TemporaryTriangleIndices[(IndexIndex*3)+1]:=Primitive^.Indices[IndexIndex+2];
             TemporaryTriangleIndices[(IndexIndex*3)+2]:=Primitive^.Indices[IndexIndex+1];
            end;
           end;
          end;
          GL_TRIANGLE_FAN:begin
           SetLength(TemporaryTriangleIndices,(Primitive^.CountIndices-2)*3);
           for IndexIndex:=2 to Primitive^.CountIndices-1 do begin
            TemporaryTriangleIndices[((IndexIndex-1)*3)+0]:=Primitive^.Indices[0];
            TemporaryTriangleIndices[((IndexIndex-1)*3)+1]:=Primitive^.Indices[IndexIndex-1];
            TemporaryTriangleIndices[((IndexIndex-1)*3)+2]:=Primitive^.Indices[IndexIndex];
           end;
          end;
          else begin
          end;
         end;
         for IndexIndex:=0 to length(TemporaryTriangleIndices)-1 do begin
          OutVertex:=Primitive.Vertices[TemporaryTriangleIndices[IndexIndex]];
          BakedVertex:=@BakedVertices[TemporaryTriangleIndices[IndexIndex]];
          OutVertex.Position[0]:=BakedVertex^.Position.x;
          OutVertex.Position[1]:=BakedVertex^.Position.y;
          OutVertex.Position[2]:=BakedVertex^.Position.z;
          OutVertex.Normal[0]:=BakedVertex^.Normal.x;
          OutVertex.Normal[1]:=BakedVertex^.Normal.y;
          OutVertex.Normal[2]:=BakedVertex^.Normal.z;
          OutVertex.Tangent[0]:=BakedVertex^.Tangent.x;
          OutVertex.Tangent[1]:=BakedVertex^.Tangent.y;
          OutVertex.Tangent[2]:=BakedVertex^.Tangent.z;
          BakedVertexIndexedMesh.AddOriginalVertexIndex(TemporaryTriangleIndices[IndexIndex],OutVertex,Max(0,Primitive^.Material),true);
         end;
        finally
         TemporaryTriangleIndices:=nil;
        end;
       end;
       else begin
       end;
      end;
     end;
    end;
   end;
  finally
   BakedVertices:=nil;
  end;
 end;
type TNodeStack=TpvDynamicStack<TpvSizeInt>;
var Index,NodeIndex:TpvSizeInt;
    NodeStack:TNodeStack;
    GroupScene:TpvGLTF.PScene;
    GroupNode:TpvGLTF.PNode;
    GroupInstanceNode:TpvGLTF.TInstance.PNode;
begin
 BakedVertexIndexedMesh:=TpvGLTF.TBakedVertexIndexedMesh.Create;
 try
  NodeStack.Initialize;
  try
   if (aRootNodeIndex>=0) and (aRootNodeIndex<length(fParent.fNodes)) then begin
    NodeStack.Push(aRootNodeIndex);
   end else begin
    if (fScene>=0) and (fScene<length(fParent.fScenes)) then begin
     GroupScene:=@fParent.fScenes[fScene];
    end else if length(fParent.fScenes)>0 then begin
     GroupScene:=@fParent.fScenes[0];
    end else begin
     GroupScene:=nil;
    end;
    if assigned(GroupScene) then begin
     for Index:=length(GroupScene.Nodes)-1 downto 0 do begin
      NodeStack.Push(GroupScene.Nodes[Index]);
     end;
    end;
   end;
   while NodeStack.Pop(NodeIndex) do begin
    GroupNode:=@fParent.fNodes[NodeIndex];
    GroupInstanceNode:=@fNodes[NodeIndex];
    if ((aRootNodeIndex>=0) and
        (NodeIndex=aRootNodeIndex)) or
       (aWithDynamicMeshs or
        ((not aWithDynamicMeshs) and
         ((GroupInstanceNode^.CountOverwrites=0) or
          ((GroupInstanceNode^.CountOverwrites=1) and
           ((GroupInstanceNode^.Overwrites[0].Flags=[TpvGLTF.TInstance.TNode.TOverwriteFlag.Defaults])))))) then begin
     for Index:=length(GroupNode.Children)-1 downto 0 do begin
      NodeStack.Push(GroupNode.Children[Index]);
     end;
     if GroupNode.Mesh>=0 then begin
      ProcessMorphSkinNode(GroupNode,GroupInstanceNode);
     end;
    end;
   end;
  finally
   NodeStack.Finalize;
  end;
  BakedVertexIndexedMesh.Finish;
 finally
  result:=BakedVertexIndexedMesh;
 end;
end;

function TpvGLTF.TInstance.GetJointPoints:TPasGLTF.TVector3DynamicArray;
const Vector3Origin:TPasGLTF.TVector3=(0.0,0.0,0.0);
var Index:TPasGLTFSizeInt;
begin
 SetLength(result,length(Parent.fJoints));
 for Index:=0 to length(Parent.fJoints)-1 do begin
  result[Index]:=Vector3MatrixMul(Nodes[Parent.fJoints[Index].Node].WorkMatrix,Vector3Origin);
 end;
end;

function TpvGLTF.TInstance.GetJointMatrices:TPasGLTF.TMatrix4x4DynamicArray;
var Index:TPasGLTFSizeInt;
begin
 SetLength(result,length(Parent.fJoints));
 for Index:=0 to length(Parent.fJoints)-1 do begin
  result[Index]:=Nodes[Parent.fJoints[Index].Node].WorkMatrix;
 end;
end;

end.


