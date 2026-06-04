unit UnitGLTFOpenGL;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
{$else}
 {$legacyifend on}
{$endif}
{$m+}

{$scopedenums on}

interface

uses SysUtils,Classes,Math,PasJSON,PasGLTF,{$ifdef fpcgl}gl,glext,{$else}dglOpenGL,{$endif}
     UnitOpenGLImage,UnitOpenGLShader,UnitOpenGLShadingShader,UnitOpenGLSolidColorShader,
     UnitOpenGLShadowMapMultisampleResolveShader,UnitOpenGLShadowMapBlurShader;

type EGLTFOpenGL=class(Exception);

     TGLTFOpenGL=class
      public
       const BRDFLUTTextureUnit=GL_TEXTURE0;
             NormalShadowMapArrayTextureUnit=GL_TEXTURE1;
             CubeMapShadowMapArrayTextureUnit=GL_TEXTURE2;
             EnvironmentMapTextureUnit=GL_TEXTURE3;
             BaseTextureUnit=GL_TEXTURE4;
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
              fParent:TGLTFOpenGL;
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
              function GetScene:TGLTFOpenGL.PScene;
             public
              constructor Create(const aParent:TGLTFOpenGL); reintroduce;
              destructor Destroy; override;
              procedure Update;
              procedure UpdateDynamicBoundingBox(const aHighQuality:boolean=false);
              procedure UpdateWorstCaseStaticBoundingBox;
              procedure Upload;
              function GetCamera(const aNodeIndex:TPasGLTFSizeInt;
                                 out aViewMatrix:TPasGLTF.TMatrix4x4;
                                 out aProjectionMatrix:TPasGLTF.TMatrix4x4;
                                 const aReversedZWithInfiniteFarPlane:boolean=false):boolean;
              procedure Draw(const aModelMatrix:TPasGLTF.TMatrix4x4;
                             const aViewMatrix:TPasGLTF.TMatrix4x4;
                             const aProjectionMatrix:TPasGLTF.TMatrix4x4;
                             const aNonSkinnedNormalShadingShader:TShadingShader;
                             const aNonSkinnedAlphaTestShadingShader:TShadingShader;
                             const aSkinnedNormalShadingShader:TShadingShader;
                             const aSkinnedAlphaTestShadingShader:TShadingShader;
                             const aAlphaModes:TPasGLTF.TMaterial.TAlphaModes=[]);
              procedure DrawShadows(const aModelMatrix:TPasGLTF.TMatrix4x4;
                                    const aViewMatrix:TPasGLTF.TMatrix4x4;
                                    const aProjectionMatrix:TPasGLTF.TMatrix4x4;
                                    const aShadowMapMultisampleResolveShader:TShadowMapMultisampleResolveShader;
                                    const aShadowMapBlurShader:TShadowMapBlurShader;
                                    const aNonSkinnedNormalShadingShader:TShadingShader;
                                    const aNonSkinnedAlphaTestShadingShader:TShadingShader;
                                    const aSkinnedNormalShadingShader:TShadingShader;
                                    const aSkinnedAlphaTestShadingShader:TShadingShader;
                                    const aAlphaModes:TPasGLTF.TMaterial.TAlphaModes=[]);
              procedure DrawFinal(const aModelMatrix:TPasGLTF.TMatrix4x4;
                                  const aViewMatrix:TPasGLTF.TMatrix4x4;
                                  const aProjectionMatrix:TPasGLTF.TMatrix4x4;
                                  const aNonSkinnedNormalShadingShader:TShadingShader;
                                  const aNonSkinnedAlphaTestShadingShader:TShadingShader;
                                  const aSkinnedNormalShadingShader:TShadingShader;
                                  const aSkinnedAlphaTestShadingShader:TShadingShader;
                                  const aAlphaModes:TPasGLTF.TMaterial.TAlphaModes=[]);
              procedure DrawJoints(const aModelMatrix:TPasGLTF.TMatrix4x4;
                                   const aViewMatrix:TPasGLTF.TMatrix4x4;
                                   const aProjectionMatrix:TPasGLTF.TMatrix4x4;
                                   const aSolidColorShader:TSolidColorShader);
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
             published
              property Parent:TGLTFOpenGL read fParent;
              property Automations[const aIndex:TPasGLTFSizeInt]:TAnimation read GetAutomation;
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
              EmissiveFactor:TPasGLTF.TVector3;
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
                     PrimitiveMode:glEnum;
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
             Handle:glUInt;
{$ifdef PasGLTFBindlessTextures}
             BindlessHandle:glUInt64;
{$else}
             ExternalHandle:glUInt;
{$endif}
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
             ShaderStorageBufferObjectHandle:glUInt;
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
             ShaderStorageBufferObjectHandle:glUInt;
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
             UniformBufferObjectHandle:glUInt;
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
             ShaderStorageBufferObjectHandle:glUInt;
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
             ShaderStorageBufferObjectHandle:glUInt;
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
       fVertexBufferObjectHandle:glInt;
       fIndexBufferObjectHandle:glInt;
       fVertexArrayHandle:glInt;
       fJointVertexBufferObjectHandle:glInt;
       fJointVertexArrayHandle:glInt;
       fEmptyVertexArrayObjectHandle:glInt;
       fStaticBoundingBox:TBoundingBox;
       fFrameGlobalsUniformBufferObjectHandle:glUInt;
       fShaderStorageBufferOffsetAlignment:glInt;
       fMaximumShaderStorageBufferBlockSize:glInt;
       fUniformBufferOffsetAlignment:glInt;
       fMaximumUniformBufferBlockSize:glInt;
       fShadowMapSize:glInt;
       fTemporaryMultisampledShadowMapSamples:glInt;
       fTemporaryMultisampledShadowMapFrameBufferObject:glUInt;
       fTemporaryMultisampledShadowMapTexture:glUInt;
       fTemporaryMultisampledShadowMapDepthTexture:glUInt;
       fTemporaryCubeMapShadowMapArrayTexture:glUInt;
//     fTemporaryCubeMapShadowMapArrayFrameBufferObject:glUInt;
       fTemporaryCubeMapShadowMapArraySingleFrameBufferObjects:array of glUInt;
       fTemporaryShadowMapTextures:array[0..1] of glUInt;
       fTemporaryShadowMapFrameBufferObjects:array[0..1] of glUInt;
       fTemporaryShadowMapArrayTexture:glUInt;
//     fTemporaryShadowMapArrayFrameBufferObject:glUInt;
       fTemporaryShadowMapArraySingleFrameBufferObjects:array of glUInt;
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
       procedure AddDefaultDirectionalLight(const aDirectionX,aDirectionY,aDirectionZ,aColorX,aColorY,aColorZ:TPasGLTFFloat);
       procedure Upload;
       procedure Unload;
       function GetAnimationBeginTime(const aAnimation:TPasGLTFSizeInt):TPasGLTFFloat;
       function GetAnimationEndTime(const aAnimation:TPasGLTFSizeInt):TPasGLTFFloat;
       function GetNodeIndex(const aNodeName:TPasGLTFUTF8String):TPasGLTFSizeInt;
{$ifndef PasGLTFBindlessTextures}
       procedure ClearExternalTextures;
       procedure SetExternalTexture(const aTextureName:TPasGLTFUTF8String;const aHandle:glUInt);
{$endif}
       function AcquireInstance:TGLTFOpenGL.TInstance;
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
       property ShadowMapSize:glInt read fShadowMapSize write fShadowMapSize;
       property GetURI:TGetURI read fGetURI write fGetURI;
       property RootPath:String read fRootPath write fRootPath;
     end;

implementation

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

var glClipControl:TglClipControl=nil;
{$endif}

type TVector2=TPasGLTF.TVector2;
     PVector2=^TVector2;

     TVector3=TPasGLTF.TVector3;
     PVector3=^TVector3;

     TVector4=TPasGLTF.TVector4;
     PVector4=^TVector4;

     TMatrix=TPasGLTF.TMatrix4x4;
     PMatrix=^TMatrix;

const EmptyMaterialUniformBufferObjectData:TGLTFOpenGL.TMaterial.TUniformBufferObjectData=
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

{ TGLTFModel }

constructor TGLTFOpenGL.Create;
begin
 inherited Create;
 fShadowMapSize:=512;
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

destructor TGLTFOpenGL.Destroy;
begin
 Unload;
 Clear;
 FreeAndNil(fNodeNameHashMap);
 inherited Destroy;
end;

procedure TGLTFOpenGL.Clear;
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

function TGLTFOpenGL.DefaultGetURI(const aURI:TPasGLTFUTF8String):TStream;
var FileName:String;
begin
 FileName:=ExpandFileName(IncludeTrailingPathDelimiter(fRootPath)+String(TPasGLTF.ResolveURIToPath(aURI)));
 result:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite);
end;

procedure TGLTFOpenGL.LoadFromDocument(const aDocument:TPasGLTF.TDocument);
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
     raise EGLTFOpenGL.Create('Non-supported animation channel target path "'+String(SourceAnimationChannel.Target.Path)+'"');
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
       raise EGLTFOpenGL.Create('Non-supported animation sampler interpolation method type');
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
     raise EGLTFOpenGL.Create('Non-existent sampler');
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
    DestinationMaterial^.EmissiveFactor:=SourceMaterial.EmissiveFactor;
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
    UniformBufferObjectData^.EmissiveFactor[0]:=SourceMaterial.EmissiveFactor[0];
    UniformBufferObjectData^.EmissiveFactor[1]:=SourceMaterial.EmissiveFactor[1];
    UniformBufferObjectData^.EmissiveFactor[2]:=SourceMaterial.EmissiveFactor[2];
    UniformBufferObjectData^.EmissiveFactor[3]:=0.0;

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
       raise EGLTFOpenGL.Create('Missing position data');
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
       raise EGLTFOpenGL.Create('Invalid primitive mode');
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
        raise EGLTFOpenGL.Create('Vertex count mismatch');
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
        raise EGLTFOpenGL.Create('Vertex count mismatch');
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
        raise EGLTFOpenGL.Create('Vertex count mismatch');
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

procedure TGLTFOpenGL.LoadFromStream(const aStream:TStream);
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

procedure TGLTFOpenGL.LoadFromFile(const aFileName:String);
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

procedure TGLTFOpenGL.AddDefaultDirectionalLight(const aDirectionX,aDirectionY,aDirectionZ,aColorX,aColorY,aColorZ:TPasGLTFFloat);
var Light:TGLTFOpenGL.PLight;
begin
 if length(fLights)=0 then begin
  fCountNormalShadowMaps:=1;
  fCountCubeMapShadowMaps:=0;
  SetLength(fLights,1);
  Light:=@fLights[0];
  Light^.Name:='DefaultDirectionalLight';
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

procedure TGLTFOpenGL.Upload;
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
 procedure CreateOpenGLObjects;
 begin

  glGenBuffers(1,@fVertexBufferObjectHandle);
  glBindBuffer(GL_ARRAY_BUFFER,fVertexBufferObjectHandle);
  glBufferData(GL_ARRAY_BUFFER,AllVertices.Count*SizeOf(TVertex),AllVertices.Memory,GL_STATIC_DRAW);
  glBindBuffer(GL_ARRAY_BUFFER,0);

  glGenBuffers(1,@fIndexBufferObjectHandle);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,fIndexBufferObjectHandle);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER,AllIndices.Count*SizeOf(TPasGLTFUInt32),AllIndices.Memory,GL_STATIC_DRAW);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);

  glGenVertexArrays(1,@fVertexArrayHandle);
  glBindVertexArray(fVertexArrayHandle);
  glBindBuffer(GL_ARRAY_BUFFER,fVertexBufferObjectHandle);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,fIndexBufferObjectHandle);
  begin
   begin
    glVertexAttribPointer(TVertexAttributeBindingLocations.Position,3,GL_FLOAT,GL_FALSE,SizeOf(TVertex),@PVertex(nil)^.Position);
    glEnableVertexAttribArray(TVertexAttributeBindingLocations.Position);
   end;
   begin
    glVertexAttribPointer(TVertexAttributeBindingLocations.Normal,3,GL_FLOAT,GL_FALSE,SizeOf(TVertex),@PVertex(nil)^.Normal);
    glEnableVertexAttribArray(TVertexAttributeBindingLocations.Normal);
   end;
   begin
    glVertexAttribPointer(TVertexAttributeBindingLocations.Tangent,4,GL_FLOAT,GL_FALSE,SizeOf(TVertex),@PVertex(nil)^.Tangent);
    glEnableVertexAttribArray(TVertexAttributeBindingLocations.Tangent);
   end;
   begin
    glVertexAttribPointer(TVertexAttributeBindingLocations.TexCoord0,2,GL_FLOAT,GL_FALSE,SizeOf(TVertex),@PVertex(nil)^.TexCoord0);
    glEnableVertexAttribArray(TVertexAttributeBindingLocations.TexCoord0);
   end;
   begin
    glVertexAttribPointer(TVertexAttributeBindingLocations.TexCoord1,2,GL_FLOAT,GL_FALSE,SizeOf(TVertex),@PVertex(nil)^.TexCoord1);
    glEnableVertexAttribArray(TVertexAttributeBindingLocations.TexCoord1);
   end;
   begin
    glVertexAttribPointer(TVertexAttributeBindingLocations.Color0,4,GL_FLOAT,GL_FALSE,SizeOf(TVertex),@PVertex(nil)^.Color0);
    glEnableVertexAttribArray(TVertexAttributeBindingLocations.Color0);
   end;
   begin
    glVertexAttribIPointer(TVertexAttributeBindingLocations.Joints0,4,GL_UNSIGNED_INT,SizeOf(TVertex),@PVertex(nil)^.Joints0);
    glEnableVertexAttribArray(TVertexAttributeBindingLocations.Joints0);
   end;
   begin
    glVertexAttribIPointer(TVertexAttributeBindingLocations.Joints1,4,GL_UNSIGNED_INT,SizeOf(TVertex),@PVertex(nil)^.Joints1);
    glEnableVertexAttribArray(TVertexAttributeBindingLocations.Joints1);
   end;
   begin
    glVertexAttribPointer(TVertexAttributeBindingLocations.Weights0,4,GL_FLOAT,GL_FALSE,SizeOf(TVertex),@PVertex(nil)^.Weights0);
    glEnableVertexAttribArray(TVertexAttributeBindingLocations.Weights0);
   end;
   begin
    glVertexAttribPointer(TVertexAttributeBindingLocations.Weights1,4,GL_FLOAT,GL_FALSE,SizeOf(TVertex),@PVertex(nil)^.Weights1);
    glEnableVertexAttribArray(TVertexAttributeBindingLocations.Weights1);
   end;
   begin
    glVertexAttribIPointer(TVertexAttributeBindingLocations.VertexIndex,1,GL_UNSIGNED_INT,SizeOf(TVertex),@PVertex(nil)^.VertexIndex);
    glEnableVertexAttribArray(TVertexAttributeBindingLocations.VertexIndex);
   end;
  end;
  glBindVertexArray(0);

  glGenBuffers(1,@fJointVertexBufferObjectHandle);
  glBindBuffer(GL_ARRAY_BUFFER,fJointVertexBufferObjectHandle);
  glBufferData(GL_ARRAY_BUFFER,Max(1,length(fJoints))*2*SizeOf(TVector3),nil,GL_DYNAMIC_DRAW);
  glBindBuffer(GL_ARRAY_BUFFER,0);

  glGenVertexArrays(1,@fJointVertexArrayHandle);
  glBindVertexArray(fJointVertexArrayHandle);
  glBindBuffer(GL_ARRAY_BUFFER,fJointVertexBufferObjectHandle);
  glVertexAttribPointer(TVertexAttributeBindingLocations.Position,3,GL_FLOAT,GL_FALSE,SizeOf(TPasGLTF.TVector3),nil);
  glEnableVertexAttribArray(TVertexAttributeBindingLocations.Position);
  glBindVertexArray(0);

  glGenVertexArrays(1,@fEmptyVertexArrayObjectHandle);

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
     Handle:glUInt;
     Anisotropy:TPasGLTFFloat;
 begin
  for Index:=0 to length(fTextures)-1 do begin
   Handle:=0;
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
     if LoadImage(MemoryStream.Memory,MemoryStream.Size,ImageData,ImageWidth,ImageHeight) then begin
      try
       glGenTextures(1,@Handle);
       glBindTexture(GL_TEXTURE_2D,Handle);
       if (Texture^.Sampler>=0) and (Texture^.Sampler<length(fSamplers)) then begin
        Sampler:=@fSamplers[Texture^.Sampler];
        case Sampler^.WrapS of
         TPasGLTF.TSampler.TWrappingMode.Repeat_:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
         end;
         TPasGLTF.TSampler.TWrappingMode.ClampToEdge:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
         end;
         TPasGLTF.TSampler.TWrappingMode.MirroredRepeat:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
         end;
         else begin
          Assert(false);
         end;
        end;
        case Sampler^.WrapT of
         TPasGLTF.TSampler.TWrappingMode.Repeat_:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
         end;
         TPasGLTF.TSampler.TWrappingMode.ClampToEdge:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
         end;
         TPasGLTF.TSampler.TWrappingMode.MirroredRepeat:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
         end;
         else begin
          Assert(false);
         end;
        end;
        case Sampler^.MinFilter of
         TPasGLTF.TSampler.TMinFilter.None:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
         end;
         TPasGLTF.TSampler.TMinFilter.Nearest:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
         end;
         TPasGLTF.TSampler.TMinFilter.Linear:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
         end;
         TPasGLTF.TSampler.TMinFilter.NearestMipMapNearest:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST_MIPMAP_NEAREST);
         end;
         TPasGLTF.TSampler.TMinFilter.LinearMipMapNearest:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST);
         end;
         TPasGLTF.TSampler.TMinFilter.NearestMipMapLinear:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST_MIPMAP_LINEAR);
         end;
         TPasGLTF.TSampler.TMinFilter.LinearMipMapLinear:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR);
         end;
         else begin
          Assert(false);
         end;
        end;
        case Sampler^.MagFilter of
         TPasGLTF.TSampler.TMagFilter.None:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
         end;
         TPasGLTF.TSampler.TMagFilter.Nearest:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
         end;
         TPasGLTF.TSampler.TMagFilter.Linear:begin
          glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
         end;
         else begin
          Assert(false);
         end;
        end;
       end else begin
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
       end;
       glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_BASE_LEVEL,0);
       glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAX_LEVEL,trunc(log2(Min(ImageWidth,ImageHeight))));
       glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA8,ImageWidth,ImageHeight,0,GL_RGBA,GL_UNSIGNED_BYTE,ImageData);
       glGenerateMipmap(GL_TEXTURE_2D);
       glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY,@Anisotropy);
       glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MAX_ANISOTROPY,Anisotropy);
      finally
       FreeMem(ImageData);
      end;
     end;
    finally
     FreeAndNil(MemoryStream);
    end;
   end;
   Texture^.Handle:=Handle;
{$ifdef PasGLTFBindlessTextures}
   Texture^.BindlessHandle:=glGetTextureHandleARB(Texture^.Handle);
   if Texture^.BindlessHandle<>0 then begin
    glMakeTextureHandleResidentARB(Texture^.BindlessHandle);
   end;
   glBindTexture(GL_TEXTURE_2D,0);
{$else}
   Texture^.ExternalHandle:=0;
{$endif}
  end;
  glBindTexture(GL_TEXTURE_2D,0);
 end;
 procedure CreateSkinShaderStorageBufferObjects;
 var Index:TPasGLTFSizeInt;
     SkinShaderStorageBufferObject:PSkinShaderStorageBufferObject;
 begin
  for Index:=0 to length(fSkinShaderStorageBufferObjects)-1 do begin
   SkinShaderStorageBufferObject:=@fSkinShaderStorageBufferObjects[Index];
   glGenBuffers(1,@SkinShaderStorageBufferObject^.ShaderStorageBufferObjectHandle);
   glBindBuffer(GL_SHADER_STORAGE_BUFFER,SkinShaderStorageBufferObject^.ShaderStorageBufferObjectHandle);
   glBufferData(GL_SHADER_STORAGE_BUFFER,SkinShaderStorageBufferObject^.Size,nil,GL_DYNAMIC_DRAW);
   glBindBuffer(GL_SHADER_STORAGE_BUFFER,0);
  end;
 end;
 procedure CreateMorphTargetVertexShaderStorageBufferObjects;
  procedure InitializeMorphTargetVertexShaderStorageBufferObjects;
   procedure FillMorphTargetVertexShaderStorageBufferObject(const aMorphTargetVertexShaderStorageBufferObject:PMorphTargetVertexShaderStorageBufferObject;
                                                            const aPrimitive:TMesh.PPrimitive;
                                                            const aDestinationVertex:PMorphTargetVertex);
   var TargetIndex,
       VertexIndex:TPasGLTFSizeInt;
       SourceVertex:TMesh.TPrimitive.TTarget.PTargetVertex;
       DestinationVertex:PMorphTargetVertex;
       Target:TMesh.TPrimitive.PTarget;
   begin
    DestinationVertex:=aDestinationVertex;
    for TargetIndex:=0 to length(aPrimitive^.Targets)-1 do begin
     Target:=@aPrimitive^.Targets[TargetIndex];
     for VertexIndex:=0 to length(Target^.Vertices)-1 do begin
      SourceVertex:=@Target^.Vertices[VertexIndex];
      DestinationVertex^.Position[0]:=SourceVertex^.Position[0];
      DestinationVertex^.Position[1]:=SourceVertex^.Position[1];
      DestinationVertex^.Position[2]:=SourceVertex^.Position[2];
      DestinationVertex^.Position[3]:=0.0;
      DestinationVertex^.Normal[0]:=SourceVertex^.Normal[0];
      DestinationVertex^.Normal[1]:=SourceVertex^.Normal[1];
      DestinationVertex^.Normal[2]:=SourceVertex^.Normal[2];
      DestinationVertex^.Normal[3]:=0.0;
      DestinationVertex^.Tangent[0]:=SourceVertex^.Tangent[0];
      DestinationVertex^.Tangent[1]:=SourceVertex^.Tangent[1];
      DestinationVertex^.Tangent[2]:=SourceVertex^.Tangent[2];
      DestinationVertex^.Tangent[3]:=0.0;
      inc(DestinationVertex);
     end;
    end;
   end;
  var MeshIndex,
      PrimitiveIndex,
      TargetIndex,
      CountVertices,
      CountMorphTargetVertexShaderStorageBufferObjects,
      Index,
      ItemDataSize:TPasGLTFSizeInt;
      Mesh:PMesh;
      Primitive:TMesh.PPrimitive;
      MorphTargetVertexShaderStorageBufferObject:PMorphTargetVertexShaderStorageBufferObject;
  begin
   CountMorphTargetVertexShaderStorageBufferObjects:=0;
   try
    for MeshIndex:=0 to length(fMeshes)-1 do begin
     Mesh:=@fMeshes[MeshIndex];
     for PrimitiveIndex:=0 to length(Mesh^.Primitives)-1 do begin
      Primitive:=@Mesh^.Primitives[PrimitiveIndex];
      if length(Primitive^.Targets)>0 then begin
       CountVertices:=0;
       for TargetIndex:=0 to length(Primitive^.Targets)-1 do begin
        inc(CountVertices,length(Primitive^.Targets[TargetIndex].Vertices));
       end;
       ItemDataSize:=CountVertices*SizeOf(TGLTFOpenGL.TMorphTargetVertex);
       if (ItemDataSize mod fShaderStorageBufferOffsetAlignment)<>0 then begin
        inc(ItemDataSize,fShaderStorageBufferOffsetAlignment-(ItemDataSize mod fShaderStorageBufferOffsetAlignment));
       end;
       if true or
          (CountMorphTargetVertexShaderStorageBufferObjects=0) or
          ((fMorphTargetVertexShaderStorageBufferObjects[CountMorphTargetVertexShaderStorageBufferObjects-1].Size+ItemDataSize)>fMaximumShaderStorageBufferBlockSize) then begin
        if length(fMorphTargetVertexShaderStorageBufferObjects)<=CountMorphTargetVertexShaderStorageBufferObjects then begin
         SetLength(fMorphTargetVertexShaderStorageBufferObjects,(CountMorphTargetVertexShaderStorageBufferObjects+1)*2);
        end;
        Primitive^.MorphTargetVertexShaderStorageBufferObjectIndex:=CountMorphTargetVertexShaderStorageBufferObjects;
        Primitive^.MorphTargetVertexShaderStorageBufferObjectOffset:=0;
        Primitive^.MorphTargetVertexShaderStorageBufferObjectByteOffset:=0;
        Primitive^.MorphTargetVertexShaderStorageBufferObjectByteSize:=ItemDataSize;
        MorphTargetVertexShaderStorageBufferObject:=@fMorphTargetVertexShaderStorageBufferObjects[CountMorphTargetVertexShaderStorageBufferObjects];
        inc(CountMorphTargetVertexShaderStorageBufferObjects);
        MorphTargetVertexShaderStorageBufferObject^.Count:=0;
        MorphTargetVertexShaderStorageBufferObject^.Size:=0;
        if length(MorphTargetVertexShaderStorageBufferObject^.Data)<(MorphTargetVertexShaderStorageBufferObject^.Size+ItemDataSize) then begin
         SetLength(MorphTargetVertexShaderStorageBufferObject^.Data,(MorphTargetVertexShaderStorageBufferObject^.Size+ItemDataSize)*2);
        end;
        FillMorphTargetVertexShaderStorageBufferObject(MorphTargetVertexShaderStorageBufferObject,Primitive,pointer(@MorphTargetVertexShaderStorageBufferObject^.Data[Primitive^.MorphTargetVertexShaderStorageBufferObjectByteOffset]));
        inc(MorphTargetVertexShaderStorageBufferObject^.Count,CountVertices);
        inc(MorphTargetVertexShaderStorageBufferObject^.Size,ItemDataSize);
       end else begin
        MorphTargetVertexShaderStorageBufferObject:=@fMorphTargetVertexShaderStorageBufferObjects[CountMorphTargetVertexShaderStorageBufferObjects-1];
        Primitive^.MorphTargetVertexShaderStorageBufferObjectIndex:=CountMorphTargetVertexShaderStorageBufferObjects-1;
        Primitive^.MorphTargetVertexShaderStorageBufferObjectOffset:=MorphTargetVertexShaderStorageBufferObject^.Count;
        Primitive^.MorphTargetVertexShaderStorageBufferObjectByteOffset:=MorphTargetVertexShaderStorageBufferObject^.Size;
        Primitive^.MorphTargetVertexShaderStorageBufferObjectByteSize:=ItemDataSize;
        if length(MorphTargetVertexShaderStorageBufferObject^.Data)<(MorphTargetVertexShaderStorageBufferObject^.Size+ItemDataSize) then begin
         SetLength(MorphTargetVertexShaderStorageBufferObject^.Data,(MorphTargetVertexShaderStorageBufferObject^.Size+ItemDataSize)*2);
        end;
        FillMorphTargetVertexShaderStorageBufferObject(MorphTargetVertexShaderStorageBufferObject,Primitive,pointer(@MorphTargetVertexShaderStorageBufferObject^.Data[Primitive^.MorphTargetVertexShaderStorageBufferObjectByteOffset]));
        inc(MorphTargetVertexShaderStorageBufferObject^.Count,CountVertices);
        inc(MorphTargetVertexShaderStorageBufferObject^.Size,ItemDataSize);
       end;
      end else begin
       Primitive^.MorphTargetVertexShaderStorageBufferObjectIndex:=-1;
      end;
     end;
    end;
   finally
    SetLength(fMorphTargetVertexShaderStorageBufferObjects,CountMorphTargetVertexShaderStorageBufferObjects);
   end;
   for Index:=0 to length(fMorphTargetVertexShaderStorageBufferObjects)-1 do begin
    MorphTargetVertexShaderStorageBufferObject:=@fMorphTargetVertexShaderStorageBufferObjects[Index];
    SetLength(MorphTargetVertexShaderStorageBufferObject^.Data,MorphTargetVertexShaderStorageBufferObject^.Size);
   end;
  end;
 var Index:TPasGLTFSizeInt;
     MorphTargetVertexShaderStorageBufferObject:PMorphTargetVertexShaderStorageBufferObject;
 begin
  InitializeMorphTargetVertexShaderStorageBufferObjects;
  for Index:=0 to length(fMorphTargetVertexShaderStorageBufferObjects)-1 do begin
   MorphTargetVertexShaderStorageBufferObject:=@fMorphTargetVertexShaderStorageBufferObjects[Index];
   glGenBuffers(1,@MorphTargetVertexShaderStorageBufferObject^.ShaderStorageBufferObjectHandle);
   glBindBuffer(GL_SHADER_STORAGE_BUFFER,MorphTargetVertexShaderStorageBufferObject^.ShaderStorageBufferObjectHandle);
   glBufferData(GL_SHADER_STORAGE_BUFFER,MorphTargetVertexShaderStorageBufferObject^.Size,@MorphTargetVertexShaderStorageBufferObject^.Data[0],GL_STATIC_DRAW);
   glBindBuffer(GL_SHADER_STORAGE_BUFFER,0);
   MorphTargetVertexShaderStorageBufferObject^.Data:=nil;
  end;
 end;
 procedure CreateNodeMeshPrimitiveShaderStorageBufferObjects;
 var Index,
     NodeIndex,
     PrimitiveIndex,
     Count,
     ItemDataSize:TPasGLTFSizeInt;
     ShaderStorageBufferObjectData:PNodeMeshPrimitiveShaderStorageBufferObjectDataItem;
     Node:PNode;
     Mesh:PMesh;
     NodeMeshPrimitiveShaderStorageBufferObject:PNodeMeshPrimitiveShaderStorageBufferObject;
     NodeMeshPrimitiveShaderStorageBufferObjectItem:PNodeMeshPrimitiveShaderStorageBufferObjectItem;
 begin
  fNodeMeshPrimitiveShaderStorageBufferObjects:=nil;
  Count:=0;
  try
   for NodeIndex:=0 to length(fNodes)-1 do begin
    Node:=@fNodes[NodeIndex];
    if (Node^.Mesh>=0) and (Node^.Mesh<length(fMeshes)) then begin
     ItemDataSize:=SizeOf(TNodeMeshPrimitiveShaderStorageBufferObjectDataItem);
     inc(ItemDataSize,(length(Node^.Weights)-1)*SizeOf(TPasGLTFFloat));
     if (ItemDataSize mod fShaderStorageBufferOffsetAlignment)<>0 then begin
      inc(ItemDataSize,fShaderStorageBufferOffsetAlignment-(ItemDataSize mod fShaderStorageBufferOffsetAlignment));
     end;
     Mesh:=@fMeshes[Node^.Mesh];
     SetLength(Node^.MeshPrimitiveMetaDataArray,length(Mesh^.Primitives));
     for PrimitiveIndex:=0 to length(Mesh^.Primitives)-1 do begin
      if (Count=0) or
         ((fNodeMeshPrimitiveShaderStorageBufferObjects[Count-1].Size+ItemDataSize)>fMaximumShaderStorageBufferBlockSize) then begin
       if length(fNodeMeshPrimitiveShaderStorageBufferObjects)<=Count then begin
        SetLength(fNodeMeshPrimitiveShaderStorageBufferObjects,(Count+1)*2);
       end;
       Node^.MeshPrimitiveMetaDataArray[PrimitiveIndex].ShaderStorageBufferObjectIndex:=Count;
       Node^.MeshPrimitiveMetaDataArray[PrimitiveIndex].ShaderStorageBufferObjectOffset:=0;
       Node^.MeshPrimitiveMetaDataArray[PrimitiveIndex].ShaderStorageBufferObjectByteOffset:=0;
       Node^.MeshPrimitiveMetaDataArray[PrimitiveIndex].ShaderStorageBufferObjectByteSize:=ItemDataSize;
       NodeMeshPrimitiveShaderStorageBufferObject:=@fNodeMeshPrimitiveShaderStorageBufferObjects[Count];
       inc(Count);
       NodeMeshPrimitiveShaderStorageBufferObject^.Size:=ItemDataSize;
       NodeMeshPrimitiveShaderStorageBufferObject^.Count:=1;
       SetLength(NodeMeshPrimitiveShaderStorageBufferObject^.Items,1);
       NodeMeshPrimitiveShaderStorageBufferObjectItem:=@NodeMeshPrimitiveShaderStorageBufferObject^.Items[0];
       NodeMeshPrimitiveShaderStorageBufferObjectItem^.Node:=NodeIndex;
       NodeMeshPrimitiveShaderStorageBufferObjectItem^.Mesh:=Node^.Mesh;
       NodeMeshPrimitiveShaderStorageBufferObjectItem^.Primitive:=PrimitiveIndex;
      end else begin
       NodeMeshPrimitiveShaderStorageBufferObject:=@fNodeMeshPrimitiveShaderStorageBufferObjects[Count-1];
       Node^.MeshPrimitiveMetaDataArray[PrimitiveIndex].ShaderStorageBufferObjectIndex:=Count-1;
       Node^.MeshPrimitiveMetaDataArray[PrimitiveIndex].ShaderStorageBufferObjectOffset:=NodeMeshPrimitiveShaderStorageBufferObject^.Count;
       Node^.MeshPrimitiveMetaDataArray[PrimitiveIndex].ShaderStorageBufferObjectByteOffset:=NodeMeshPrimitiveShaderStorageBufferObject^.Size;
       Node^.MeshPrimitiveMetaDataArray[PrimitiveIndex].ShaderStorageBufferObjectByteSize:=ItemDataSize;
       inc(NodeMeshPrimitiveShaderStorageBufferObject^.Size,ItemDataSize);
       if length(NodeMeshPrimitiveShaderStorageBufferObject^.Items)<=NodeMeshPrimitiveShaderStorageBufferObject^.Count then begin
        SetLength(NodeMeshPrimitiveShaderStorageBufferObject^.Items,(NodeMeshPrimitiveShaderStorageBufferObject^.Count+1)*2);
       end;
       NodeMeshPrimitiveShaderStorageBufferObjectItem:=@NodeMeshPrimitiveShaderStorageBufferObject^.Items[NodeMeshPrimitiveShaderStorageBufferObject^.Count];
       inc(NodeMeshPrimitiveShaderStorageBufferObject^.Count);
       NodeMeshPrimitiveShaderStorageBufferObjectItem^.Node:=NodeIndex;
       NodeMeshPrimitiveShaderStorageBufferObjectItem^.Mesh:=Node^.Mesh;
       NodeMeshPrimitiveShaderStorageBufferObjectItem^.Primitive:=PrimitiveIndex;
      end;
     end;
    end;
   end;
  finally
   SetLength(fNodeMeshPrimitiveShaderStorageBufferObjects,Count);
   for Index:=0 to length(fNodeMeshPrimitiveShaderStorageBufferObjects)-1 do begin
    NodeMeshPrimitiveShaderStorageBufferObject:=@fNodeMeshPrimitiveShaderStorageBufferObjects[Index];
    SetLength(NodeMeshPrimitiveShaderStorageBufferObject^.Items,NodeMeshPrimitiveShaderStorageBufferObject^.Count);
   end;
  end;
  for Index:=0 to length(fNodeMeshPrimitiveShaderStorageBufferObjects)-1 do begin
   NodeMeshPrimitiveShaderStorageBufferObject:=@fNodeMeshPrimitiveShaderStorageBufferObjects[Index];
   glGenBuffers(1,@NodeMeshPrimitiveShaderStorageBufferObject^.ShaderStorageBufferObjectHandle);
   glBindBuffer(GL_SHADER_STORAGE_BUFFER,NodeMeshPrimitiveShaderStorageBufferObject^.ShaderStorageBufferObjectHandle);
   glBufferData(GL_SHADER_STORAGE_BUFFER,NodeMeshPrimitiveShaderStorageBufferObject^.Size,nil,GL_DYNAMIC_DRAW);
  end;
  glBindBuffer(GL_SHADER_STORAGE_BUFFER,0);
 end;
 procedure CreateFrameGlobalsUniformBufferObject;
 begin
  glGenBuffers(1,@fFrameGlobalsUniformBufferObjectHandle);
  glBindBuffer(GL_UNIFORM_BUFFER,fFrameGlobalsUniformBufferObjectHandle);
  glBufferData(GL_UNIFORM_BUFFER,SizeOf(TFrameGlobalsUniformBufferObjectData),nil,GL_DYNAMIC_DRAW);
  glBindBuffer(GL_UNIFORM_BUFFER,0);
 end;
 procedure CreateMaterialUniformBufferObjects;
 var Index,MaterialIndex,Count,MaterialDataSize{$if defined(PasGLTFIndicatedTextures) and not defined(PasGLTFBindlessTextures)},TextureUnit{$ifend}:TPasGLTFSizeInt;
     UniformBufferObjectData:TMaterial.PUniformBufferObjectData;
     Material:PMaterial;
     MaterialUniformBufferObject:PMaterialUniformBufferObject;
     p:PPasGLTFUInt8Array;
 begin
  fMaterialUniformBufferObjects:=nil;
  Count:=0;
  try
   MaterialDataSize:=SizeOf(TMaterial.TUniformBufferObjectData);
   if (MaterialDataSize mod fUniformBufferOffsetAlignment)<>0 then begin
    inc(MaterialDataSize,fUniformBufferOffsetAlignment-(MaterialDataSize mod fUniformBufferOffsetAlignment));
   end;
   for MaterialIndex:=-1 to length(fMaterials)-1 do begin
    if MaterialIndex<0 then begin
     Material:=nil;
    end else begin
     Material:=@fMaterials[MaterialIndex];
    end;
    if (Count=0) or
       ((fMaterialUniformBufferObjects[Count-1].Size+MaterialDataSize)>fMaximumUniformBufferBlockSize) then begin
     if length(fMaterialUniformBufferObjects)<=Count then begin
      SetLength(fMaterialUniformBufferObjects,(Count+1)*2);
     end;
     if assigned(Material) then begin
      Material^.UniformBufferObjectIndex:=Count;
      Material^.UniformBufferObjectOffset:=0;
     end;
     MaterialUniformBufferObject:=@fMaterialUniformBufferObjects[Count];
     inc(Count);
     MaterialUniformBufferObject^.Size:=MaterialDataSize;
     MaterialUniformBufferObject^.Count:=1;
     SetLength(MaterialUniformBufferObject^.Materials,1);
     MaterialUniformBufferObject^.Materials[0]:=MaterialIndex;
    end else begin
     MaterialUniformBufferObject:=@fMaterialUniformBufferObjects[Count-1];
     if assigned(Material) then begin
      Material^.UniformBufferObjectIndex:=Count-1;
      Material^.UniformBufferObjectOffset:=MaterialUniformBufferObject^.Size;
     end;
     inc(MaterialUniformBufferObject^.Size,MaterialDataSize);
     if length(MaterialUniformBufferObject^.Materials)<=MaterialUniformBufferObject^.Count then begin
      SetLength(MaterialUniformBufferObject^.Materials,(MaterialUniformBufferObject^.Count+1)*2);
     end;
     MaterialUniformBufferObject^.Materials[MaterialUniformBufferObject^.Count]:=MaterialIndex;
     inc(MaterialUniformBufferObject^.Count);
    end;
   end;
  finally
   SetLength(fMaterialUniformBufferObjects,Count);
   for Index:=0 to length(fMaterialUniformBufferObjects)-1 do begin
    MaterialUniformBufferObject:=@fMaterialUniformBufferObjects[Index];
    SetLength(MaterialUniformBufferObject^.Materials,MaterialUniformBufferObject^.Count);
   end;
  end;
  for Index:=0 to length(fMaterialUniformBufferObjects)-1 do begin
   MaterialUniformBufferObject:=@fMaterialUniformBufferObjects[Index];
   glGenBuffers(1,@MaterialUniformBufferObject^.UniformBufferObjectHandle);
   glBindBuffer(GL_UNIFORM_BUFFER,MaterialUniformBufferObject^.UniformBufferObjectHandle);
   glBufferData(GL_UNIFORM_BUFFER,MaterialUniformBufferObject^.Size,nil,GL_DYNAMIC_DRAW);
   p:=glMapBuffer(GL_UNIFORM_BUFFER,GL_WRITE_ONLY);
   if assigned(p) then begin
    for MaterialIndex:=0 to length(MaterialUniformBufferObject^.Materials)-1 do begin
     if MaterialUniformBufferObject^.Materials[MaterialIndex]<0 then begin
      TMaterial.PUniformBufferObjectData(@p^[0])^:=EmptyMaterialUniformBufferObjectData;
     end else begin
      Material:=@fMaterials[MaterialUniformBufferObject^.Materials[MaterialIndex]];
{$if defined(PasGLTFBindlessTextures)}
      Material^.UniformBufferObjectData.TextureHandles:=EmptyMaterialUniformBufferObjectData.TextureHandles;
      case Material^.ShadingModel of
       TGLTFOpenGL.TMaterial.TShadingModel.PBRMetallicRoughness:begin
        if (Material^.PBRMetallicRoughness.BaseColorTexture.Index>=0) and (Material^.PBRMetallicRoughness.BaseColorTexture.Index<length(fTextures)) then begin
         Material^.UniformBufferObjectData.TextureHandles[0]:=fTextures[Material^.PBRMetallicRoughness.BaseColorTexture.Index].BindlessHandle;
        end;
        if (Material^.PBRMetallicRoughness.MetallicRoughnessTexture.Index>=0) and (Material^.PBRMetallicRoughness.MetallicRoughnessTexture.Index<length(fTextures)) then begin
         Material^.UniformBufferObjectData.TextureHandles[1]:=fTextures[Material^.PBRMetallicRoughness.MetallicRoughnessTexture.Index].BindlessHandle;
        end;
       end;
       TGLTFOpenGL.TMaterial.TShadingModel.PBRSpecularGlossiness:begin
        if (Material^.PBRSpecularGlossiness.DiffuseTexture.Index>=0) and (Material^.PBRSpecularGlossiness.DiffuseTexture.Index<length(fTextures)) then begin
         Material^.UniformBufferObjectData.TextureHandles[0]:=fTextures[Material^.PBRSpecularGlossiness.DiffuseTexture.Index].BindlessHandle;
        end;
        if (Material^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index>=0) and (Material^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index<length(fTextures)) then begin
         Material^.UniformBufferObjectData.TextureHandles[1]:=fTextures[Material^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index].BindlessHandle;
        end;
       end;
       TGLTFOpenGL.TMaterial.TShadingModel.Unlit:begin
        if (Material^.PBRMetallicRoughness.BaseColorTexture.Index>=0) and (Material^.PBRMetallicRoughness.BaseColorTexture.Index<length(fTextures)) then begin
         Material^.UniformBufferObjectData.TextureHandles[0]:=fTextures[Material^.PBRMetallicRoughness.BaseColorTexture.Index].BindlessHandle;
        end;
       end;
       else begin
        Assert(false);
       end;
      end;
      if (Material^.NormalTexture.Index>=0) and (Material^.NormalTexture.Index<length(fTextures)) then begin
       Material^.UniformBufferObjectData.TextureHandles[2]:=fTextures[Material^.NormalTexture.Index].BindlessHandle;
      end;
      if (Material^.OcclusionTexture.Index>=0) and (Material^.OcclusionTexture.Index<length(fTextures)) then begin
       Material^.UniformBufferObjectData.TextureHandles[3]:=fTextures[Material^.OcclusionTexture.Index].BindlessHandle;
      end;
      if (Material^.EmissiveTexture.Index>=0) and (Material^.EmissiveTexture.Index<length(fTextures)) then begin
       Material^.UniformBufferObjectData.TextureHandles[4]:=fTextures[Material^.EmissiveTexture.Index].BindlessHandle;
      end;
      if (Material^.PBRSheen.ColorIntensityTexture.Index>=0) and (Material^.PBRSheen.ColorIntensityTexture.Index<length(fTextures)) then begin
       Material^.UniformBufferObjectData.TextureHandles[5]:=fTextures[Material^.PBRSheen.ColorIntensityTexture.Index].BindlessHandle;
      end;
      if (Material^.PBRClearCoat.Texture.Index>=0) and (Material^.PBRClearCoat.Texture.Index<length(fTextures)) then begin
       Material^.UniformBufferObjectData.TextureHandles[6]:=fTextures[Material^.PBRClearCoat.Texture.Index].BindlessHandle;
      end;
      if (Material^.PBRClearCoat.RoughnessTexture.Index>=0) and (Material^.PBRClearCoat.RoughnessTexture.Index<length(fTextures)) then begin
       Material^.UniformBufferObjectData.TextureHandles[7]:=fTextures[Material^.PBRClearCoat.RoughnessTexture.Index].BindlessHandle;
      end;
      if (Material^.PBRClearCoat.NormalTexture.Index>=0) and (Material^.PBRClearCoat.NormalTexture.Index<length(fTextures)) then begin
       Material^.UniformBufferObjectData.TextureHandles[8]:=fTextures[Material^.PBRClearCoat.NormalTexture.Index].BindlessHandle;
      end;
{$elseif defined(PasGLTFIndicatedTextures) and not defined(PasGLTFBindlessTextures)}
      Material^.UniformBufferObjectData.TextureIndices:=EmptyMaterialUniformBufferObjectData.TextureIndices;
      TextureUnit:=0;
      case Material^.ShadingModel of
       TGLTFOpenGL.TMaterial.TShadingModel.PBRMetallicRoughness:begin
        if (Material^.PBRMetallicRoughness.BaseColorTexture.Index>=0) and (Material^.PBRMetallicRoughness.BaseColorTexture.Index<length(fTextures)) then begin
         Material^.UniformBufferObjectData.TextureIndices[0]:=TextureUnit;
         inc(TextureUnit);
        end;
        if (Material^.PBRMetallicRoughness.MetallicRoughnessTexture.Index>=0) and (Material^.PBRMetallicRoughness.MetallicRoughnessTexture.Index<length(fTextures)) then begin
         Material^.UniformBufferObjectData.TextureIndices[1]:=TextureUnit;
         inc(TextureUnit);
        end;
       end;
       TGLTFOpenGL.TMaterial.TShadingModel.PBRSpecularGlossiness:begin
        if (Material^.PBRSpecularGlossiness.DiffuseTexture.Index>=0) and (Material^.PBRSpecularGlossiness.DiffuseTexture.Index<length(fTextures)) then begin
         Material^.UniformBufferObjectData.TextureIndices[0]:=TextureUnit;
         inc(TextureUnit);
        end;
        if (Material^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index>=0) and (Material^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index<length(fTextures)) then begin
         Material^.UniformBufferObjectData.TextureIndices[1]:=TextureUnit;
         inc(TextureUnit);
        end;
       end;
       TGLTFOpenGL.TMaterial.TShadingModel.Unlit:begin
        if (Material^.PBRMetallicRoughness.BaseColorTexture.Index>=0) and (Material^.PBRMetallicRoughness.BaseColorTexture.Index<length(fTextures)) then begin
         Material^.UniformBufferObjectData.TextureIndices[0]:=TextureUnit;
         inc(TextureUnit);
        end;
       end;
       else begin
        Assert(false);
       end;
      end;
      if (Material^.NormalTexture.Index>=0) and (Material^.NormalTexture.Index<length(fTextures)) then begin
       Material^.UniformBufferObjectData.TextureIndices[2]:=TextureUnit;
       inc(TextureUnit);
      end;
      if (Material^.OcclusionTexture.Index>=0) and (Material^.OcclusionTexture.Index<length(fTextures)) then begin
       Material^.UniformBufferObjectData.TextureIndices[3]:=TextureUnit;
       inc(TextureUnit);
      end;
      if (Material^.EmissiveTexture.Index>=0) and (Material^.EmissiveTexture.Index<length(fTextures)) then begin
       Material^.UniformBufferObjectData.TextureIndices[4]:=TextureUnit;
       inc(TextureUnit);
      end;
      if (Material^.PBRSheen.ColorIntensityTexture.Index>=0) and (Material^.PBRSheen.ColorIntensityTexture.Index<length(fTextures)) then begin
       Material^.UniformBufferObjectData.TextureIndices[5]:=TextureUnit;
       inc(TextureUnit);
      end;
      if (Material^.PBRClearCoat.Texture.Index>=0) and (Material^.PBRClearCoat.Texture.Index<length(fTextures)) then begin
       Material^.UniformBufferObjectData.TextureIndices[6]:=TextureUnit;
       inc(TextureUnit);
      end;
      if (Material^.PBRClearCoat.RoughnessTexture.Index>=0) and (Material^.PBRClearCoat.RoughnessTexture.Index<length(fTextures)) then begin
       Material^.UniformBufferObjectData.TextureIndices[7]:=TextureUnit;
       inc(TextureUnit);
      end;
      if (Material^.PBRClearCoat.NormalTexture.Index>=0) and (Material^.PBRClearCoat.NormalTexture.Index<length(fTextures)) then begin
       Material^.UniformBufferObjectData.TextureIndices[8]:=TextureUnit;
       inc(TextureUnit);
      end;
{$ifend}
      TMaterial.PUniformBufferObjectData(@p^[Material^.UniformBufferObjectOffset])^:=Material^.UniformBufferObjectData;
     end;
    end;
    glUnmapBuffer(GL_UNIFORM_BUFFER);
   end;
   glBindBuffer(GL_UNIFORM_BUFFER,0);
  end;
 end;
 procedure CreateLightShaderStorageBufferObject;
 var Index:TPasGLTFSizeInt;
     Light:PLight;
     LightShaderStorageBufferObjectDataItem:PLightShaderStorageBufferObjectDataItem;
     InnerConeAngleCosinus,OuterConeAngleCosinus:TPasGLTFFloat;
 begin
  if fLightShaderStorageBufferObject.ShaderStorageBufferObjectHandle>0 then begin
   glDeleteBuffers(1,@fLightShaderStorageBufferObject.ShaderStorageBufferObjectHandle);
  end;
  if assigned(fLightShaderStorageBufferObject.Data) then begin
   FreeMem(fLightShaderStorageBufferObject.Data);
  end;
  FillChar(fLightShaderStorageBufferObject,SizeOf(TLightShaderStorageBufferObject),#0);
  fLightShaderStorageBufferObject.Size:=SizeOf(TLightShaderStorageBufferObjectData)+(Max(0,length(fLights)-1)*SizeOf(TLightShaderStorageBufferObjectDataItem));
  GetMem(fLightShaderStorageBufferObject.Data,fLightShaderStorageBufferObject.Size);
  FillChar(fLightShaderStorageBufferObject.Data^,fLightShaderStorageBufferObject.Size,#0);
  fLightShaderStorageBufferObject.Data^.Count:=length(fLights);
  for Index:=0 to length(fLights)-1 do begin
   Light:=@fLights[Index];
   LightShaderStorageBufferObjectDataItem:=@fLightShaderStorageBufferObject.Data^.Lights[Index];
   LightShaderStorageBufferObjectDataItem^.Type_:=Light^.Type_;
   InnerConeAngleCosinus:=cos(Light^.InnerConeAngle);
   OuterConeAngleCosinus:=cos(Light^.OuterConeAngle);
   if (Light^.ShadowMapIndex>=0) and Light^.CastShadows then begin
    LightShaderStorageBufferObjectDataItem^.ShadowMapIndex:=Light^.ShadowMapIndex;
   end else begin
    LightShaderStorageBufferObjectDataItem^.ShadowMapIndex:=TPasGLTFUInt32($ffffffff);
   end;
  {LightShaderStorageBufferObjectDataItem^.InnerConeCosinus:=InnerConeAngleCosinus;
   LightShaderStorageBufferObjectDataItem^.OuterConeCosinus:=OuterConeAngleCosinus;}
   LightShaderStorageBufferObjectDataItem^.LightAngleScale:=1.0/Max(1e-5,InnerConeAngleCosinus-OuterConeAngleCosinus);
   LightShaderStorageBufferObjectDataItem^.LightAngleOffset:=-(OuterConeAngleCosinus*LightShaderStorageBufferObjectDataItem^.LightAngleScale);
   LightShaderStorageBufferObjectDataItem^.ColorIntensity[0]:=Light^.Color[0];
   LightShaderStorageBufferObjectDataItem^.ColorIntensity[1]:=Light^.Color[1];
   LightShaderStorageBufferObjectDataItem^.ColorIntensity[2]:=Light^.Color[2];
   LightShaderStorageBufferObjectDataItem^.ColorIntensity[3]:=Light^.Intensity;
   LightShaderStorageBufferObjectDataItem^.PositionRange[0]:=0.0;
   LightShaderStorageBufferObjectDataItem^.PositionRange[1]:=0.0;
   LightShaderStorageBufferObjectDataItem^.PositionRange[2]:=0.0;
   LightShaderStorageBufferObjectDataItem^.PositionRange[3]:=Light^.Range;
   LightShaderStorageBufferObjectDataItem^.DirectionZFar[0]:=0.0;
   LightShaderStorageBufferObjectDataItem^.DirectionZFar[1]:=0.0;
   LightShaderStorageBufferObjectDataItem^.DirectionZFar[2]:=-1.0;
   LightShaderStorageBufferObjectDataItem^.DirectionZFar[3]:=0.0;
  end;
  glGenBuffers(1,@fLightShaderStorageBufferObject.ShaderStorageBufferObjectHandle);
  glBindBuffer(GL_SHADER_STORAGE_BUFFER,fLightShaderStorageBufferObject.ShaderStorageBufferObjectHandle);
  glBufferData(GL_SHADER_STORAGE_BUFFER,fLightShaderStorageBufferObject.Size,fLightShaderStorageBufferObject.Data,GL_DYNAMIC_DRAW);
  glBindBuffer(GL_SHADER_STORAGE_BUFFER,0);
 end;
 procedure CreateTemporaryMultisampledShadowMapFrameBufferObject;
 var Status:GLenum;
 begin
  fTemporaryMultisampledShadowMapSamples:=2;
  glGetIntegerv(GL_MAX_SAMPLES,@fTemporaryMultisampledShadowMapSamples);
  if fTemporaryMultisampledShadowMapSamples>8 then begin
   fTemporaryMultisampledShadowMapSamples:=8;
  end;
  glActiveTexture(GL_TEXTURE0);
  glGenFramebuffers(1,@fTemporaryMultisampledShadowMapFrameBufferObject);
  glBindFramebuffer(GL_FRAMEBUFFER,fTemporaryMultisampledShadowMapFrameBufferObject);
  glGenTextures(1,@fTemporaryMultisampledShadowMapTexture);
  glBindTexture(GL_TEXTURE_2D_MULTISAMPLE,fTemporaryMultisampledShadowMapTexture);
  glTexParameteri(GL_TEXTURE_2D_MULTISAMPLE,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D_MULTISAMPLE,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
  glTexImage2DMultisample(GL_TEXTURE_2D_MULTISAMPLE,fTemporaryMultisampledShadowMapSamples,GL_R32F,fShadowMapSize,fShadowMapSize,{$ifdef fpcgl}GL_TRUE{$else}true{$endif});
  glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D_MULTISAMPLE,fTemporaryMultisampledShadowMapTexture,0);
  glGenTextures(1,@fTemporaryMultisampledShadowMapDepthTexture);
  glBindTexture(GL_TEXTURE_2D_MULTISAMPLE,fTemporaryMultisampledShadowMapDepthTexture);
  glTexParameteri(GL_TEXTURE_2D_MULTISAMPLE,GL_DEPTH_TEXTURE_MODE,GL_LUMINANCE);
  glTexParameteri(GL_TEXTURE_2D_MULTISAMPLE,GL_TEXTURE_COMPARE_MODE,GL_NONE);
  glTexParameteri(GL_TEXTURE_2D_MULTISAMPLE,GL_TEXTURE_COMPARE_FUNC,GL_ALWAYS);
  glTexParameteri(GL_TEXTURE_2D_MULTISAMPLE,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D_MULTISAMPLE,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
  glTexImage2DMultisample(GL_TEXTURE_2D_MULTISAMPLE,fTemporaryMultisampledShadowMapSamples,GL_DEPTH_COMPONENT32F,fShadowMapSize,fShadowMapSize,{$ifdef fpcgl}GL_TRUE{$else}true{$endif});
  glBindTexture(GL_TEXTURE_2D,0);
  glFramebufferTexture2D(GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT,GL_TEXTURE_2D_MULTISAMPLE,fTemporaryMultisampledShadowMapDepthTexture,0);
  Status:=glCheckFramebufferStatus(GL_FRAMEBUFFER);
  Assert(Status=GL_FRAMEBUFFER_COMPLETE);
  glBindFramebuffer(GL_FRAMEBUFFER,0);
 end;
 procedure CreateTemporaryCubeMapShadowMapArrayFrameBufferObject;
 var Count,Index,SideIndex:TPasGLTFSizeInt;
     Status:GLenum;
 begin
  Count:=Max(1,fCountCubeMapShadowMaps);
  glActiveTexture(GL_TEXTURE0);
{ glGenFramebuffers(1,@fTemporaryCubeMapShadowMapArrayFrameBufferObject);
  glBindFramebuffer(GL_FRAMEBUFFER,fTemporaryCubeMapShadowMapArrayFrameBufferObject);}
  glGenTextures(1,@fTemporaryCubeMapShadowMapArrayTexture);
  glBindTexture(GL_TEXTURE_CUBE_MAP_ARRAY,fTemporaryCubeMapShadowMapArrayTexture);
  glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_R,GL_CLAMP_TO_EDGE);
  glTexImage3D(GL_TEXTURE_CUBE_MAP_ARRAY,0,GL_RGBA16,fShadowMapSize,fShadowMapSize,6*Count,0,GL_RGBA,GL_UNSIGNED_SHORT,nil);
  glBindTexture(GL_TEXTURE_CUBE_MAP_ARRAY,0);
{ glFramebufferTexture3D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_CUBE_MAP_ARRAY,fTemporaryCubeMapShadowMapArrayTexture,0,0);
  Status:=glCheckFramebufferStatus(GL_FRAMEBUFFER);
  Assert(Status=GL_FRAMEBUFFER_COMPLETE);
  glBindFramebuffer(GL_FRAMEBUFFER,0);}
  SetLength(fTemporaryCubeMapShadowMapArraySingleFrameBufferObjects,Count*6);
  glGenFramebuffers(Count*6,@fTemporaryCubeMapShadowMapArraySingleFrameBufferObjects[0]);
  for Index:=0 to (Count*6)-1 do begin
   glBindFramebuffer(GL_FRAMEBUFFER,fTemporaryCubeMapShadowMapArraySingleFrameBufferObjects[Index]);
   glBindTexture(GL_TEXTURE_CUBE_MAP_ARRAY,fTemporaryCubeMapShadowMapArrayTexture);
   glFramebufferTextureLayer(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,fTemporaryCubeMapShadowMapArrayTexture,0,Index);
   Status:=glCheckFramebufferStatus(GL_FRAMEBUFFER);
   Assert(Status=GL_FRAMEBUFFER_COMPLETE);
   glBindFramebuffer(GL_FRAMEBUFFER,0);
   glBindTexture(GL_TEXTURE_CUBE_MAP_ARRAY,0);
  end;
 end;
 procedure CreateTemporaryShadowMapFrameBufferObjects;
 var Index:TPasGLTFSizeInt;
     Status:GLenum;
 begin
  for Index:=0 to 1 do begin
   glActiveTexture(GL_TEXTURE0);
   glGenFramebuffers(1,@fTemporaryShadowMapFrameBufferObjects[Index]);
   glBindFramebuffer(GL_FRAMEBUFFER,fTemporaryShadowMapFrameBufferObjects[Index]);
   glGenTextures(1,@fTemporaryShadowMapTextures[Index]);
   glBindTexture(GL_TEXTURE_2D,fTemporaryShadowMapTextures[Index]);
   glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
   glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
   glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
   glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
   glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA16,fShadowMapSize,fShadowMapSize,0,GL_RGBA,GL_UNSIGNED_SHORT,nil);
   glBindTexture(GL_TEXTURE_2D,0);
   glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,fTemporaryShadowMapTextures[Index],0);
   Status:=glCheckFramebufferStatus(GL_FRAMEBUFFER);
   Assert(Status=GL_FRAMEBUFFER_COMPLETE);
   glBindFramebuffer(GL_FRAMEBUFFER,0);
  end;
 end;
 procedure CreateTemporaryShadowMapArrayFrameBufferObject;
 var Index,Count:TPasGLTFSizeInt;
     Status:GLenum;
 begin
  Count:=Max(1,fCountNormalShadowMaps);
  glActiveTexture(GL_TEXTURE0);
{ glGenFramebuffers(1,@fTemporaryShadowMapArrayFrameBufferObject);
  glBindFramebuffer(GL_FRAMEBUFFER,fTemporaryShadowMapArrayFrameBufferObject);}
  glGenTextures(1,@fTemporaryShadowMapArrayTexture);
  glBindTexture(GL_TEXTURE_2D_ARRAY,fTemporaryShadowMapArrayTexture);
  glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
  glTexImage3D(GL_TEXTURE_2D_ARRAY,0,GL_RGBA16,fShadowMapSize,fShadowMapSize,Count,0,GL_RGBA,GL_UNSIGNED_SHORT,nil);
  glBindTexture(GL_TEXTURE_2D_ARRAY,0);
{ glFramebufferTexture3D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D_ARRAY,fTemporaryShadowMapArrayTexture,0,0);
  Status:=glCheckFramebufferStatus(GL_FRAMEBUFFER);
  Assert(Status=GL_FRAMEBUFFER_COMPLETE);
  glBindFramebuffer(GL_FRAMEBUFFER,0);}
  SetLength(fTemporaryShadowMapArraySingleFrameBufferObjects,Count);
  glGenFramebuffers(Count,@fTemporaryShadowMapArraySingleFrameBufferObjects[0]);
  for Index:=0 to Count-1 do begin
   glBindFramebuffer(GL_FRAMEBUFFER,fTemporaryShadowMapArraySingleFrameBufferObjects[Index]);
   glBindTexture(GL_TEXTURE_2D_ARRAY,fTemporaryShadowMapArrayTexture);
   glFramebufferTextureLayer(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,fTemporaryShadowMapArrayTexture,0,Index);
   Status:=glCheckFramebufferStatus(GL_FRAMEBUFFER);
   Assert(Status=GL_FRAMEBUFFER_COMPLETE);
   glBindFramebuffer(GL_FRAMEBUFFER,0);
   glBindTexture(GL_TEXTURE_2D_ARRAY,0);
  end;
 end;
begin
 if not fUploaded then begin
  fUploaded:=true;
  AllVertices:=TAllVertices.Create;
  try
   AllIndices:=TAllIndices.Create;
   try
{$ifdef fpcgl}
    if not assigned(glClipControl) then begin
     glClipControl:=wglGetProcAddress(PAnsiChar('glClipControl'));
    end;
{$endif}
    glGetIntegerv(GL_SHADER_STORAGE_BUFFER_OFFSET_ALIGNMENT,@fShaderStorageBufferOffsetAlignment);
    glGetIntegerv(GL_MAX_SHADER_STORAGE_BLOCK_SIZE,@fMaximumShaderStorageBufferBlockSize);
    glGetIntegerv(GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT,@fUniformBufferOffsetAlignment);
    glGetIntegerv(GL_MAX_UNIFORM_BLOCK_SIZE,@fMaximumUniformBufferBlockSize);
    CollectVerticesAndIndicesFromMeshes;
    CreateOpenGLObjects;
    LoadTextures;
    CreateSkinShaderStorageBufferObjects;
    CreateMorphTargetVertexShaderStorageBufferObjects;
    CreateFrameGlobalsUniformBufferObject;
    CreateNodeMeshPrimitiveShaderStorageBufferObjects;
    CreateMaterialUniformBufferObjects;
    CreateLightShaderStorageBufferObject;
    CreateTemporaryMultisampledShadowMapFrameBufferObject;
    CreateTemporaryCubeMapShadowMapArrayFrameBufferObject;
    CreateTemporaryShadowMapFrameBufferObjects;
    CreateTemporaryShadowMapArrayFrameBufferObject;
   finally
    FreeAndNil(AllIndices);
   end;
  finally
   FreeAndNil(AllVertices);
  end;
 end;
end;

procedure TGLTFOpenGL.Unload;
 procedure DeleteOpenGLObjects;
 begin
  glBindBuffer(GL_ARRAY_BUFFER,0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);
  glBindVertexArray(0);
  glDeleteVertexArrays(1,@fVertexArrayHandle);
  glDeleteBuffers(1,@fVertexBufferObjectHandle);
  glDeleteBuffers(1,@fIndexBufferObjectHandle);
  glDeleteVertexArrays(1,@fJointVertexArrayHandle);
  glDeleteBuffers(1,@fJointVertexBufferObjectHandle);
  glDeleteVertexArrays(1,@fEmptyVertexArrayObjectHandle);
 end;
 procedure UnloadTextures;
 var Index:TPasGLTFSizeInt;
 begin
  for Index:=0 to length(fTextures)-1 do begin
{$ifdef PasGLTFBindlessTextures}
   if fTextures[Index].BindlessHandle>0 then begin
    glMakeTextureHandleNonResidentARB(fTextures[Index].BindlessHandle);
   end;
{$endif}
   if fTextures[Index].Handle>0 then begin
    glDeleteTextures(1,@fTextures[Index].Handle);
   end;
  end;
 end;
 procedure DestroySkinShaderStorageBufferObjects;
 var Index:TPasGLTFSizeInt;
     SkinShaderStorageBufferObject:PSkinShaderStorageBufferObject;
 begin
  for Index:=0 to length(fSkinShaderStorageBufferObjects)-1 do begin
   SkinShaderStorageBufferObject:=@fSkinShaderStorageBufferObjects[Index];
   if SkinShaderStorageBufferObject^.ShaderStorageBufferObjectHandle>0 then begin
    glDeleteBuffers(1,@SkinShaderStorageBufferObject^.ShaderStorageBufferObjectHandle);
   end;
  end;
 end;
 procedure DestroyMorphTargetVertexShaderStorageBufferObjects;
 var Index:TPasGLTFSizeInt;
     MorphTargetVertexShaderStorageBufferObject:PMorphTargetVertexShaderStorageBufferObject;
 begin
  for Index:=0 to length(fMorphTargetVertexShaderStorageBufferObjects)-1 do begin
   MorphTargetVertexShaderStorageBufferObject:=@fMorphTargetVertexShaderStorageBufferObjects[Index];
   if MorphTargetVertexShaderStorageBufferObject^.ShaderStorageBufferObjectHandle>0 then begin
    glDeleteBuffers(1,@MorphTargetVertexShaderStorageBufferObject^.ShaderStorageBufferObjectHandle);
   end;
  end;
 end;
 procedure DestroyNodeMeshPrimitiveShaderStorageBufferObjects;
 var Index:TPasGLTFSizeInt;
     NodeMeshPrimitiveShaderStorageBufferObject:PNodeMeshPrimitiveShaderStorageBufferObject;
 begin
  for Index:=0 to length(fNodeMeshPrimitiveShaderStorageBufferObjects)-1 do begin
   NodeMeshPrimitiveShaderStorageBufferObject:=@fNodeMeshPrimitiveShaderStorageBufferObjects[Index];
   if NodeMeshPrimitiveShaderStorageBufferObject^.ShaderStorageBufferObjectHandle>0 then begin
    glDeleteBuffers(1,@NodeMeshPrimitiveShaderStorageBufferObject^.ShaderStorageBufferObjectHandle);
   end;
  end;
 end;
 procedure DestroyFrameGlobalsUniformBufferObject;
 begin
  glDeleteBuffers(1,@fFrameGlobalsUniformBufferObjectHandle);
 end;
 procedure DestroyMaterialUniformBufferObjects;
 var Index:TPasGLTFSizeInt;
 begin
  for Index:=0 to length(fMaterialUniformBufferObjects)-1 do begin
   if fMaterialUniformBufferObjects[Index].UniformBufferObjectHandle>0 then begin
    glDeleteBuffers(1,@fMaterialUniformBufferObjects[Index].UniformBufferObjectHandle);
   end;
  end;
  fMaterialUniformBufferObjects:=nil;
 end;
 procedure DestroyLightShaderStorageBufferObject;
 begin
  if fLightShaderStorageBufferObject.ShaderStorageBufferObjectHandle>0 then begin
   glDeleteBuffers(1,@fLightShaderStorageBufferObject.ShaderStorageBufferObjectHandle);
  end;
  if assigned(fLightShaderStorageBufferObject.Data) then begin
   FreeMem(fLightShaderStorageBufferObject.Data);
  end;
  FillChar(fLightShaderStorageBufferObject,SizeOf(TLightShaderStorageBufferObject),#0);
 end;
 procedure DestroyTemporaryMultisampledShadowMapFrameBufferObject;
 var Status:GLenum;
 begin
  if fTemporaryMultisampledShadowMapFrameBufferObject>0 then begin
   glDeleteFramebuffers(1,@fTemporaryMultisampledShadowMapFrameBufferObject);
   fTemporaryMultisampledShadowMapFrameBufferObject:=0;
  end;
  if fTemporaryMultisampledShadowMapTexture>0 then begin
   glDeleteTextures(1,@fTemporaryMultisampledShadowMapTexture);
   fTemporaryMultisampledShadowMapTexture:=0;
  end;
  if fTemporaryMultisampledShadowMapDepthTexture>0 then begin
   glDeleteTextures(1,@fTemporaryMultisampledShadowMapDepthTexture);
   fTemporaryMultisampledShadowMapDepthTexture:=0;
  end;
 end;
 procedure DestroyTemporaryCubeMapShadowMapArrayFrameBufferObject;
 var Index:TPasGLTFSizeInt;
 begin
  for Index:=0 to length(fTemporaryCubeMapShadowMapArraySingleFrameBufferObjects)-1 do begin
   if fTemporaryCubeMapShadowMapArraySingleFrameBufferObjects[Index]>0 then begin
    glDeleteFramebuffers(1,@fTemporaryCubeMapShadowMapArraySingleFrameBufferObjects[Index]);
   end;
  end;
{ if fTemporaryCubeMapShadowMapArrayFrameBufferObject>0 then begin
   glDeleteFramebuffers(1,@fTemporaryCubeMapShadowMapArrayFrameBufferObject);
   fTemporaryCubeMapShadowMapArrayFrameBufferObject:=0;
  end;}
  if fTemporaryCubeMapShadowMapArrayTexture>0 then begin
   glDeleteTextures(1,@fTemporaryCubeMapShadowMapArrayTexture);
   fTemporaryCubeMapShadowMapArrayTexture:=0;
  end;
 end;
 procedure DestroyTemporaryShadowMapFrameBufferObjects;
 var Index:TPasGLTFSizeInt;
 begin
  for Index:=0 to 1 do begin
   if fTemporaryShadowMapFrameBufferObjects[Index]>0 then begin
    glDeleteFramebuffers(1,@fTemporaryShadowMapFrameBufferObjects[Index]);
    fTemporaryShadowMapFrameBufferObjects[Index]:=0;
   end;
   if fTemporaryShadowMapTextures[Index]>0 then begin
    glDeleteTextures(1,@fTemporaryShadowMapTextures[Index]);
    fTemporaryShadowMapTextures[Index]:=0;
   end;
  end;
 end;
 procedure DestroyTemporaryShadowMapArrayFrameBufferObject;
 var Index:TPasGLTFSizeInt;
 begin
  for Index:=0 to length(fTemporaryShadowMapArraySingleFrameBufferObjects)-1 do begin
   if fTemporaryShadowMapArraySingleFrameBufferObjects[Index]>0 then begin
    glDeleteFramebuffers(1,@fTemporaryShadowMapArraySingleFrameBufferObjects[Index]);
   end;
  end;
  fTemporaryShadowMapArraySingleFrameBufferObjects:=nil;
{ if fTemporaryShadowMapArrayFrameBufferObject>0 then begin
   glDeleteFramebuffers(1,@fTemporaryShadowMapArrayFrameBufferObject);
   fTemporaryShadowMapArrayFrameBufferObject:=0;
  end;}
  if fTemporaryShadowMapArrayTexture>0 then begin
   glDeleteTextures(1,@fTemporaryShadowMapArrayTexture);
   fTemporaryShadowMapArrayTexture:=0;
  end;
 end;
begin
 if fUploaded then begin
  fUploaded:=false;
  DeleteOpenGLObjects;
  UnloadTextures;
  DestroySkinShaderStorageBufferObjects;
  DestroyMorphTargetVertexShaderStorageBufferObjects;
  DestroyNodeMeshPrimitiveShaderStorageBufferObjects;
  DestroyFrameGlobalsUniformBufferObject;
  DestroyMaterialUniformBufferObjects;
  DestroyLightShaderStorageBufferObject;
  DestroyTemporaryMultisampledShadowMapFrameBufferObject;
  DestroyTemporaryCubeMapShadowMapArrayFrameBufferObject;
  DestroyTemporaryShadowMapFrameBufferObjects;
  DestroyTemporaryShadowMapArrayFrameBufferObject;
 end;
end;

function TGLTFOpenGL.GetAnimationBeginTime(const aAnimation:TPasGLTFSizeInt):TPasGLTFFloat;
var Index:TPasGLTFSizeInt;
    Animation:TGLTFOpenGL.PAnimation;
    Channel:TGLTFOpenGL.TAnimation.PChannel;
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

function TGLTFOpenGL.GetAnimationEndTime(const aAnimation:TPasGLTFSizeInt):TPasGLTFFloat;
var Index:TPasGLTFSizeInt;
    Animation:TGLTFOpenGL.PAnimation;
    Channel:TGLTFOpenGL.TAnimation.PChannel;
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

function TGLTFOpenGL.GetNodeIndex(const aNodeName:TPasGLTFUTF8String):TPasGLTFSizeInt;
begin
 result:=fNodeNameHashMap[aNodeName];
end;

{$ifndef PasGLTFBindlessTextures}
procedure TGLTFOpenGL.ClearExternalTextures;
var Index:TPasGLTFSizeInt;
    Texture:TGLTFOpenGL.PTexture;
begin
 for Index:=0 to length(fTextures)-1 do begin
  Texture:=@fTextures[Index];
  Texture^.ExternalHandle:=0;
 end;
end;

procedure TGLTFOpenGL.SetExternalTexture(const aTextureName:TPasGLTFUTF8String;const aHandle:glUInt);
var Index:TPasGLTFSizeInt;
    Texture:TGLTFOpenGL.PTexture;
begin
 for Index:=0 to length(fTextures)-1 do begin
  Texture:=@fTextures[Index];
  if assigned(Texture) and ((Texture^.Name=aTextureName) or (((Texture^.Image>=0) and (Texture^.Image<length(fImages))) and (fImages[Texture^.Image].Name=aTextureName))) then begin
   Texture^.ExternalHandle:=aHandle;
  end;
 end;
end;
{$endif}

function TGLTFOpenGL.AcquireInstance:TGLTFOpenGL.TInstance;
begin
 result:=TGLTFOpenGL.TInstance.Create(self);
end;

{ TGLTFOpenGL.TInstance.TAnimation }

constructor TGLTFOpenGL.TInstance.TAnimation.Create;
begin
 inherited Create;
 fFactor:=-1.0;
 fTime:=0.0;
end;

destructor TGLTFOpenGL.TInstance.TAnimation.Destroy;
begin
 inherited Destroy;
end;

{ TGLTFOpenGL.TInstance }

constructor TGLTFOpenGL.TInstance.Create(const aParent:TGLTFOpenGL);
var Index,OtherIndex:TPasGLTFSizeInt;
    InstanceNode:TGLTFOpenGL.TInstance.PNode;
    Node:TGLTFOpenGL.PNode;
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
  fAnimations[Index]:=TGLTFOpenGL.TInstance.TAnimation.Create;
 end;
end;

destructor TGLTFOpenGL.TInstance.Destroy;
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

procedure TGLTFOpenGL.TInstance.SetScene(const aScene:TPasGLTFSizeInt);
begin
 fScene:=Min(Max(aScene,-1),length(fParent.fScenes)-1);
end;

function TGLTFOpenGL.TInstance.GetAutomation(const aIndex:TPasGLTFSizeInt):TGLTFOpenGL.TInstance.TAnimation;
begin
 result:=fAnimations[aIndex+1];
end;

procedure TGLTFOpenGL.TInstance.SetAnimation(const aAnimation:TPasGLTFSizeInt);
begin
 fAnimation:=Min(Max(aAnimation,-1),length(fParent.fAnimations)-1);
end;

function TGLTFOpenGL.TInstance.GetScene:TGLTFOpenGL.PScene;
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
 end;
end;

procedure TGLTFOpenGL.TInstance.Update;
var NonSkinnedShadingShader,SkinnedShadingShader:TShadingShader;
    CurrentShader:TShader;
    CurrentSkinShaderStorageBufferObjectHandle:glUInt;
    CullFace,Blend:TPasGLTFInt32;
 procedure ResetNode(const aNodeIndex:TPasGLTFSizeInt);
 var Index:TPasGLTFSizeInt;
     InstanceNode:TGLTFOpenGL.TInstance.PNode;
     Node:TGLTFOpenGL.PNode;
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
     InstanceNode:TGLTFOpenGL.TInstance.PNode;
     Overwrite:TGLTFOpenGL.TInstance.TNode.POverwrite;
 begin
  if aFactor>=-0.5 then begin
   for Index:=0 to length(fParent.fNodes)-1 do begin
    InstanceNode:=@fNodes[Index];
    if InstanceNode^.CountOverwrites<length(InstanceNode^.Overwrites) then begin
     Overwrite:=@InstanceNode^.Overwrites[InstanceNode^.CountOverwrites];
     Overwrite^.Flags:=[TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Defaults];
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
     Animation:TGLTFOpenGL.PAnimation;
     AnimationChannel:TGLTFOpenGL.TAnimation.PChannel;
     Node:TGLTFOpenGL.TInstance.PNode;
     Time,Factor,Scalar,Value,SqrFactor,CubeFactor,KeyDelta,v0,v1,a,b:TPasGLTFFloat;
     Vector3:TPasGLTF.TVector3;
     Vector4:TPasGLTF.TVector4;
     Vector3s:array[0..1] of TPasGLTF.PVector3;
     Vector4s:array[0..1] of TPasGLTF.PVector4;
     TimeIndices:array[0..1] of TPasGLTFSizeInt;
     Overwrite:TGLTFOpenGL.TInstance.TNode.POverwrite;
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
      TGLTFOpenGL.TAnimation.TChannel.TTarget.Translation,
      TGLTFOpenGL.TAnimation.TChannel.TTarget.Scale:begin
       case AnimationChannel^.Interpolation of
        TGLTFOpenGL.TAnimation.TChannel.TInterpolation.Linear:begin
         Vector3s[0]:=@AnimationChannel^.OutputVector3Array[TimeIndices[0]];
         Vector3s[1]:=@AnimationChannel^.OutputVector3Array[TimeIndices[1]];
         Vector3[0]:=(Vector3s[0]^[0]*(1.0-Factor))+(Vector3s[1]^[0]*Factor);
         Vector3[1]:=(Vector3s[0]^[1]*(1.0-Factor))+(Vector3s[1]^[1]*Factor);
         Vector3[2]:=(Vector3s[0]^[2]*(1.0-Factor))+(Vector3s[1]^[2]*Factor);
        end;
        TGLTFOpenGL.TAnimation.TChannel.TInterpolation.Step:begin
         Vector3:=AnimationChannel^.OutputVector3Array[TimeIndices[0]];
        end;
        TGLTFOpenGL.TAnimation.TChannel.TInterpolation.CubicSpline:begin
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
        TGLTFOpenGL.TAnimation.TChannel.TTarget.Translation:begin
         if assigned(Overwrite) then begin
          Include(Overwrite^.Flags,TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Translation);
          Overwrite^.Translation:=Vector3;
         end else begin
          Include(Node^.OverwriteFlags,TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Translation);
          Node^.OverwriteTranslation:=Vector3;
         end;
        end;
        TGLTFOpenGL.TAnimation.TChannel.TTarget.Scale:begin
         if assigned(Overwrite) then begin
          Include(Overwrite^.Flags,TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Scale);
          Overwrite^.Scale:=Vector3;
         end else begin
          Include(Node^.OverwriteFlags,TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Scale);
          Node^.OverwriteScale:=Vector3;
         end;
        end;
       end;
      end;
      TGLTFOpenGL.TAnimation.TChannel.TTarget.Rotation:begin
       case AnimationChannel^.Interpolation of
        TGLTFOpenGL.TAnimation.TChannel.TInterpolation.Linear:begin
         Vector4:=QuaternionSlerp(AnimationChannel^.OutputVector4Array[TimeIndices[0]],
                                  AnimationChannel^.OutputVector4Array[TimeIndices[1]],
                                  Factor);
        end;
        TGLTFOpenGL.TAnimation.TChannel.TInterpolation.Step:begin
         Vector4:=AnimationChannel^.OutputVector4Array[TimeIndices[0]];
        end;
        TGLTFOpenGL.TAnimation.TChannel.TInterpolation.CubicSpline:begin
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
        Include(Overwrite^.Flags,TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Rotation);
        Overwrite^.Rotation:=Vector4;
       end else begin
        Include(Node^.OverwriteFlags,TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Rotation);
        Node^.OverwriteRotation:=Vector4;
       end;
      end;
      TGLTFOpenGL.TAnimation.TChannel.TTarget.Weights:begin
       CountWeights:=length(Node^.WorkWeights);
       if assigned(Overwrite) then begin
        Include(Overwrite^.Flags,TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Weights);
        case AnimationChannel^.Interpolation of
         TGLTFOpenGL.TAnimation.TChannel.TInterpolation.Linear:begin
          for WeightIndex:=0 to CountWeights-1 do begin
           Overwrite^.Weights[WeightIndex]:=(AnimationChannel^.OutputScalarArray[(TimeIndices[0]*CountWeights)+WeightIndex]*(1.0-Factor))+
                                            (AnimationChannel^.OutputScalarArray[(TimeIndices[1]*CountWeights)+WeightIndex]*Factor);
          end;
         end;
         TGLTFOpenGL.TAnimation.TChannel.TInterpolation.Step:begin
          for WeightIndex:=0 to CountWeights-1 do begin
           Overwrite^.Weights[WeightIndex]:=AnimationChannel^.OutputScalarArray[(TimeIndices[0]*CountWeights)+WeightIndex];
          end;
         end;
         TGLTFOpenGL.TAnimation.TChannel.TInterpolation.CubicSpline:begin
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
        Include(Node^.OverwriteFlags,TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Weights);
        case AnimationChannel^.Interpolation of
         TGLTFOpenGL.TAnimation.TChannel.TInterpolation.Linear:begin
          for WeightIndex:=0 to CountWeights-1 do begin
           Node^.OverwriteWeights[WeightIndex]:=(AnimationChannel^.OutputScalarArray[(TimeIndices[0]*CountWeights)+WeightIndex]*(1.0-Factor))+
                                                (AnimationChannel^.OutputScalarArray[(TimeIndices[1]*CountWeights)+WeightIndex]*Factor);
          end;
         end;
         TGLTFOpenGL.TAnimation.TChannel.TInterpolation.Step:begin
          for WeightIndex:=0 to CountWeights-1 do begin
           Node^.OverwriteWeights[WeightIndex]:=AnimationChannel^.OutputScalarArray[(TimeIndices[0]*CountWeights)+WeightIndex];
          end;
         end;
         TGLTFOpenGL.TAnimation.TChannel.TInterpolation.CubicSpline:begin
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
 var Index,OtherIndex:TPasGLTFSizeInt;
     Matrix:TPasGLTF.TMatrix4x4;
     InstanceNode:TGLTFOpenGL.TInstance.PNode;
     Node:TGLTFOpenGL.PNode;
     Translation,Scale:TPasGLTF.TVector3;
     Rotation:TPasGLTF.TVector4;
     TranslationSum,ScaleSum:TGLTFOpenGL.TVector3Sum;
     RotationSum:TGLTFOpenGL.TVector4Sum;
     Factor,
     WeightsFactorSum:TPasGLTFDouble;
     Overwrite:TGLTFOpenGL.TInstance.TNode.POverwrite;
     FirstWeights:boolean;
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
   RotationSum.x:=0.0;
   RotationSum.y:=0.0;
   RotationSum.z:=0.0;
   RotationSum.w:=0.0;
   RotationSum.FactorSum:=0.0;
   WeightsFactorSum:=0.0;
   FirstWeights:=true;
   for Index:=0 to InstanceNode^.CountOverwrites-1 do begin
    Overwrite:=@InstanceNode^.Overwrites[Index];
    Factor:=Overwrite^.Factor;
    if TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Defaults in Overwrite^.Flags then begin
     TranslationSum.x:=TranslationSum.x+(Node^.Translation[0]*Factor);
     TranslationSum.y:=TranslationSum.y+(Node^.Translation[1]*Factor);
     TranslationSum.z:=TranslationSum.z+(Node^.Translation[2]*Factor);
     TranslationSum.FactorSum:=TranslationSum.FactorSum+Factor;
     ScaleSum.x:=ScaleSum.x+(Node^.Scale[0]*Factor);
     ScaleSum.y:=ScaleSum.y+(Node^.Scale[1]*Factor);
     ScaleSum.z:=ScaleSum.z+(Node^.Scale[2]*Factor);
     ScaleSum.FactorSum:=ScaleSum.FactorSum+Factor;
     RotationSum.x:=RotationSum.x+(Node^.Rotation[0]*Factor);
     RotationSum.y:=RotationSum.y+(Node^.Rotation[1]*Factor);
     RotationSum.z:=RotationSum.z+(Node^.Rotation[2]*Factor);
     RotationSum.w:=RotationSum.w+(Node^.Rotation[3]*Factor);
     RotationSum.FactorSum:=RotationSum.FactorSum+Factor;
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
     if TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Translation in Overwrite^.Flags then begin
      TranslationSum.x:=TranslationSum.x+(Overwrite^.Translation[0]*Factor);
      TranslationSum.y:=TranslationSum.y+(Overwrite^.Translation[1]*Factor);
      TranslationSum.z:=TranslationSum.z+(Overwrite^.Translation[2]*Factor);
      TranslationSum.FactorSum:=TranslationSum.FactorSum+Factor;
     end;
     if TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Scale in Overwrite^.Flags then begin
      ScaleSum.x:=ScaleSum.x+(Overwrite^.Scale[0]*Factor);
      ScaleSum.y:=ScaleSum.y+(Overwrite^.Scale[1]*Factor);
      ScaleSum.z:=ScaleSum.z+(Overwrite^.Scale[2]*Factor);
      ScaleSum.FactorSum:=ScaleSum.FactorSum+Factor;
     end;
     if TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Rotation in Overwrite^.Flags then begin
      RotationSum.x:=RotationSum.x+(Overwrite^.Rotation[0]*Factor);
      RotationSum.y:=RotationSum.y+(Overwrite^.Rotation[1]*Factor);
      RotationSum.z:=RotationSum.z+(Overwrite^.Rotation[2]*Factor);
      RotationSum.w:=RotationSum.w+(Overwrite^.Rotation[3]*Factor);
      RotationSum.FactorSum:=RotationSum.FactorSum+Factor;
     end;
     if TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Weights in Overwrite^.Flags then begin
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
   if RotationSum.FactorSum>0.0 then begin
    Factor:=1.0/RotationSum.FactorSum;
    Rotation[0]:=RotationSum.x*Factor;
    Rotation[1]:=RotationSum.y*Factor;
    Rotation[2]:=RotationSum.z*Factor;
    Rotation[3]:=RotationSum.w*Factor;
    Rotation:=Vector4Normalize(Rotation);
   end else begin
    Rotation:=Node^.Rotation;
   end;
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
   if TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Translation in InstanceNode^.OverwriteFlags then begin
    Translation:=InstanceNode^.OverwriteTranslation;
   end else begin
    Translation:=Node^.Translation;
   end;
   if TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Scale in InstanceNode^.OverwriteFlags then begin
    Scale:=InstanceNode^.OverwriteScale;
   end else begin
    Scale:=Node^.Scale;
   end;
   if TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Rotation in InstanceNode^.OverwriteFlags then begin
    Rotation:=InstanceNode^.OverwriteRotation;
   end else begin
    Rotation:=Node^.Rotation;
   end;
   if TGLTFOpenGL.TInstance.TNode.TOverwriteFlag.Weights in InstanceNode^.OverwriteFlags then begin
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
    Scene:TGLTFOpenGL.PScene;
    Animation:TGLTFOpenGL.TInstance.TAnimation;
begin
 Scene:=GetScene;
 if assigned(Scene) then begin
  CurrentSkinShaderStorageBufferObjectHandle:=0;
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

procedure TGLTFOpenGL.TInstance.UpdateDynamicBoundingBox(const aHighQuality:boolean=false);
 procedure ProcessNodeLowQuality(const aNodeIndex:TPasGLTFSizeInt);
 var Index:TPasGLTFSizeInt;
     Matrix:TPasGLTF.TMatrix4x4;
     InstanceNode:TGLTFOpenGL.TInstance.PNode;
     Node:TGLTFOpenGL.PNode;
     Mesh:TGLTFOpenGL.PMesh;
     Center,Extents,NewCenter,NewExtents:TVector3;
     SourceBoundingBox:TGLTFOpenGL.PBoundingBox;
     BoundingBox:TGLTFOpenGL.TBoundingBox;
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
     InstanceNode:TGLTFOpenGL.TInstance.PNode;
     Node:TGLTFOpenGL.PNode;
     InstanceSkin:TGLTFOpenGL.TInstance.PSkin;
     Skin:TGLTFOpenGL.PSkin;
     Mesh:TGLTFOpenGL.PMesh;
     Primitive:TGLTFOpenGL.TMesh.PPrimitive;
     Vertex:TGLTFOpenGL.PVertex;
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
     InstanceNode:TGLTFOpenGL.TInstance.PNode;
     Node:TGLTFOpenGL.PNode;
     Mesh:TGLTFOpenGL.PMesh;
     Center,Extents,NewCenter,NewExtents:TVector3;
     Rotation:TVector4;
     SourceBoundingBox:TGLTFOpenGL.PBoundingBox;
     BoundingBox:TGLTFOpenGL.TBoundingBox;
     Skin:TGLTFOpenGL.PSkin;
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
    Scene:TGLTFOpenGL.PScene;
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

procedure TGLTFOpenGL.TInstance.UpdateWorstCaseStaticBoundingBox;
 procedure ProcessNode(const aNodeIndex:TPasGLTFSizeInt);
 var Index,
     PrimitiveIndex,
     VertexIndex,
     MorphTargetWeightIndex,
     JointPartIndex,
     JointWeightIndex,
     JointIndex:TPasGLTFSizeInt;
     Matrix:TPasGLTF.TMatrix4x4;
     InstanceNode:TGLTFOpenGL.TInstance.PNode;
     Node:TGLTFOpenGL.PNode;
     InstanceSkin:TGLTFOpenGL.TInstance.PSkin;
     Skin:TGLTFOpenGL.PSkin;
     Mesh:TGLTFOpenGL.PMesh;
     Primitive:TGLTFOpenGL.TMesh.PPrimitive;
     Vertex:TGLTFOpenGL.PVertex;
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
    Scene:TGLTFOpenGL.PScene;
    Animation:TGLTFOpenGL.PAnimation;
    AnimationChannel:TGLTFOpenGL.TAnimation.PChannel;
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

procedure TGLTFOpenGL.TInstance.Upload;
 procedure ProcessNodeMeshPrimitiveShaderStorageBufferObjects;
  procedure ProcessNodeMeshPrimitiveShaderStorageBufferObject(const aNodeMeshPrimitiveShaderStorageBufferObject:TGLTFOpenGL.PNodeMeshPrimitiveShaderStorageBufferObject);
   procedure Process(const aInstanceNode:TGLTFOpenGL.TInstance.PNode;
                     const aNode:TGLTFOpenGL.PNode;
                     const aPrimitive:TMesh.PPrimitive;
                     const aData:pointer);
   var WeightIndex:TPasGLTFSizeInt;
       NodeMeshPrimitiveShaderStorageBufferObject:TGLTFOpenGL.PNodeMeshPrimitiveShaderStorageBufferObject;
       NodeMeshPrimitiveShaderStorageBufferObjectItem:TGLTFOpenGL.PNodeMeshPrimitiveShaderStorageBufferObjectDataItem;
       SkinShaderStorageBufferObject:TGLTFOpenGL.PSkinShaderStorageBufferObject;
       Skin:TGLTFOpenGL.PSkin;
   begin
    NodeMeshPrimitiveShaderStorageBufferObjectItem:=aData;
    NodeMeshPrimitiveShaderStorageBufferObjectItem^.Matrix:=aInstanceNode^.WorkMatrix;
    NodeMeshPrimitiveShaderStorageBufferObjectItem^.Reversed:=0;
    if (fAnimation>=0) and
       ((aNode^.Skin>=0) and (aNode^.Skin<length(fParent.fSkins))) and
       (fParent.fSkins[aNode^.Skin].SkinShaderStorageBufferObjectIndex>=0) then begin
     Skin:=@fParent.fSkins[aNode^.Skin];
     SkinShaderStorageBufferObject:=@fParent.fSkinShaderStorageBufferObjects[Skin^.SkinShaderStorageBufferObjectIndex];
     NodeMeshPrimitiveShaderStorageBufferObjectItem^.JointOffset:=Skin^.SkinShaderStorageBufferObjectOffset;
    end else begin
     NodeMeshPrimitiveShaderStorageBufferObjectItem^.JointOffset:=0;
    end;
    NodeMeshPrimitiveShaderStorageBufferObjectItem^.CountVertices:=length(aPrimitive^.Vertices);
    NodeMeshPrimitiveShaderStorageBufferObjectItem^.CountMorphTargets:=length(aPrimitive^.Targets);
    for WeightIndex:=0 to length(aPrimitive^.Targets)-1 do begin
     NodeMeshPrimitiveShaderStorageBufferObjectItem^.MorphTargetWeights[WeightIndex]:=aInstanceNode^.WorkWeights[WeightIndex];
    end;
   end;
  var Index,SubIndex:TPasGLTFSizeInt;
      Data:pointer;
      Item:TGLTFOpenGL.PNodeMeshPrimitiveShaderStorageBufferObjectItem;
      InstanceNode:TGLTFOpenGL.TInstance.PNode;
      Node:TGLTFOpenGL.PNode;
      MeshPrimitiveMetaData:TGLTFOpenGL.TNode.PMeshPrimitiveMetaData;
      Mesh:TGLTFOpenGL.PMesh;
  begin
   glBindBuffer(GL_SHADER_STORAGE_BUFFER,aNodeMeshPrimitiveShaderStorageBufferObject^.ShaderStorageBufferObjectHandle);
   Data:=glMapBufferRange(GL_SHADER_STORAGE_BUFFER,0,aNodeMeshPrimitiveShaderStorageBufferObject^.Size,GL_MAP_WRITE_BIT or GL_MAP_INVALIDATE_BUFFER_BIT);
   if assigned(Data) then begin
    for Index:=0 to length(aNodeMeshPrimitiveShaderStorageBufferObject^.Items)-1 do begin
     Item:=@aNodeMeshPrimitiveShaderStorageBufferObject^.Items[Index];
     InstanceNode:=@fNodes[Item^.Node];
     Node:=@fParent.fNodes[Item^.Node];
     Mesh:=@fParent.fMeshes[Item^.Mesh];
     for SubIndex:=0 to length(Node^.MeshPrimitiveMetaDataArray)-1 do begin
      MeshPrimitiveMetaData:=@Node^.MeshPrimitiveMetaDataArray[SubIndex];
      Process(InstanceNode,
              Node,
              @Mesh^.Primitives[SubIndex],
              @PPasGLTFUInt8Array(Data)^[MeshPrimitiveMetaData^.ShaderStorageBufferObjectByteOffset]);
     end;
    end;
    glUnmapBuffer(GL_SHADER_STORAGE_BUFFER);
   end;
  end;
 var Index:TPasGLTFSizeInt;
 begin
  for Index:=0 to length(fParent.fNodeMeshPrimitiveShaderStorageBufferObjects)-1 do begin
   ProcessNodeMeshPrimitiveShaderStorageBufferObject(@fParent.fNodeMeshPrimitiveShaderStorageBufferObjects[Index]);
  end;
  glBindBuffer(GL_SHADER_STORAGE_BUFFER,0);
 end;
 procedure ProcessSkins;
  procedure ProcessSkinShaderStorageBufferObjects;
   procedure ProcessSkinShaderStorageBufferObject(const aSkinShaderStorageBufferObject:TGLTFOpenGL.PSkinShaderStorageBufferObject);
    procedure ProcessSkin(const aSkin:TGLTFOpenGL.PSkin;const aData:pointer);
    var JointIndex:TPasGLTFSizeInt;
        Skin:TGLTFOpenGL.PSkin;
        SkinShaderStorageBufferObject:TGLTFOpenGL.PSkinShaderStorageBufferObject;
        UniformBufferObjectMatrix:TPasGLTF.PMatrix4x4;
    begin
     UniformBufferObjectMatrix:=aData;
     for JointIndex:=0 to length(aSkin^.Joints)-1 do begin
      UniformBufferObjectMatrix^:=MatrixMul(aSkin^.InverseBindMatrices[JointIndex],fNodes[aSkin^.Joints[JointIndex]].WorkMatrix);
      inc(UniformBufferObjectMatrix);
     end;
    end;
   var Index:TPasGLTFSizeInt;
       Used:boolean;
       Data:pointer;
       Skin:TGLTFOpenGL.PSkin;
   begin
    Used:=false;
    for Index:=0 to length(aSkinShaderStorageBufferObject^.Skins)-1 do begin
     if fSkins[aSkinShaderStorageBufferObject^.Skins[Index]].Used then begin
      Used:=true;
      break;
     end;
    end;
    if Used then begin
     glBindBuffer(GL_SHADER_STORAGE_BUFFER,aSkinShaderStorageBufferObject^.ShaderStorageBufferObjectHandle);
     Data:=glMapBufferRange(GL_SHADER_STORAGE_BUFFER,0,aSkinShaderStorageBufferObject^.Size,GL_MAP_WRITE_BIT or GL_MAP_INVALIDATE_BUFFER_BIT);
     if assigned(Data) then begin
      for Index:=0 to length(aSkinShaderStorageBufferObject^.Skins)-1 do begin
       Skin:=@fParent.fSkins[aSkinShaderStorageBufferObject^.Skins[Index]];
       if fSkins[aSkinShaderStorageBufferObject^.Skins[Index]].Used then begin
        ProcessSkin(Skin,@PPasGLTFUint8Array(Data)^[Skin^.SkinShaderStorageBufferObjectByteOffset]);
       end;
      end;
      glUnmapBuffer(GL_SHADER_STORAGE_BUFFER);
     end;
    end;
   end;
  var Index:TPasGLTFSizeInt;
  begin
   for Index:=0 to length(fParent.fSkinShaderStorageBufferObjects)-1 do begin
    ProcessSkinShaderStorageBufferObject(@fParent.fSkinShaderStorageBufferObjects[Index]);
   end;
   glBindBuffer(GL_SHADER_STORAGE_BUFFER,0);
  end;
 begin
  ProcessSkinShaderStorageBufferObjects;
 end;
var Index:TPasGLTFSizeInt;
    Scene:PScene;
begin
 Scene:=GetScene;
 if assigned(Scene) then begin
  ProcessNodeMeshPrimitiveShaderStorageBufferObjects;
  ProcessSkins;
 end;
end;

function TGLTFOpenGL.TInstance.GetCamera(const aNodeIndex:TPasGLTFSizeInt;
                                         out aViewMatrix:TPasGLTF.TMatrix4x4;
                                         out aProjectionMatrix:TPasGLTF.TMatrix4x4;
                                         const aReversedZWithInfiniteFarPlane:boolean=false):boolean;
const DEG2RAD=PI/180;
var NodeMatrix:TPasGLTF.TMatrix4x4;
    Camera:TGLTFOpenGL.PCamera;
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

procedure TGLTFOpenGL.TInstance.Draw(const aModelMatrix:TPasGLTF.TMatrix4x4;
                                     const aViewMatrix:TPasGLTF.TMatrix4x4;
                                     const aProjectionMatrix:TPasGLTF.TMatrix4x4;
                                     const aNonSkinnedNormalShadingShader:TShadingShader;
                                     const aNonSkinnedAlphaTestShadingShader:TShadingShader;
                                     const aSkinnedNormalShadingShader:TShadingShader;
                                     const aSkinnedAlphaTestShadingShader:TShadingShader;
                                     const aAlphaModes:TPasGLTF.TMaterial.TAlphaModes=[]);
var NonSkinnedShadingShader,SkinnedShadingShader:TShadingShader;
    CurrentShader:TShader;
    CurrentSkinShaderStorageBufferObjectHandle:glUInt;
    CullFaceState,BlendState,DepthWriteMaskState:TPasGLTFInt32;
 procedure UseShader(const aShader:TShader);
 begin
  if CurrentShader<>aShader then begin
   CurrentShader:=aShader;
   if assigned(CurrentShader) then begin
    CurrentShader.Bind;
   end;
  end;
 end;
 procedure DrawNode(const aNodeIndex:TPasGLTFSizeInt;const aAlphaMode:TPasGLTF.TMaterial.TAlphaMode);
 var ShadingShader:TShadingShader;
     InstanceNode:TGLTFOpenGL.TInstance.PNode;
     Node:TGLTFOpenGL.PNode;
  procedure DrawMesh(const aMesh:TGLTFOpenGL.TMesh);
{$if not defined(PasGLTFBindlessTextures)}
   function GetTextureHandle(const aTexture:TGLTFOpenGL.TTexture):glUInt;
   begin
    if aTexture.ExternalHandle<>0 then begin
     result:=aTexture.ExternalHandle;
    end else begin
     result:=aTexture.Handle;
    end;
   end;
{$ifend}
  var PrimitiveIndex:TPasGLTFSizeInt;
      Primitive:TGLTFOpenGL.TMesh.PPrimitive;
      Material:TGLTFOpenGL.PMaterial;
      MorphTargetVertexShaderStorageBufferObject:TGLTFOpenGL.PMorphTargetVertexShaderStorageBufferObject;
      MeshPrimitiveMetaData:TGLTFOpenGL.TNode.PMeshPrimitiveMetaData;
      DoDraw,DoClearTextures:boolean;
  begin
   for PrimitiveIndex:=0 to length(aMesh.Primitives)-1 do begin
    Primitive:=@aMesh.Primitives[PrimitiveIndex];
    DoClearTextures:=false;
    DoDraw:=false;
    if (Primitive^.Material>=0) and (Primitive^.Material<length(fParent.fMaterials)) then begin
     Material:=@fParent.fMaterials[Primitive^.Material];
     if Material^.AlphaMode=aAlphaMode then begin
      case aAlphaMode of
       TPasGLTF.TMaterial.TAlphaMode.Opaque:begin
        if BlendState<>0 then begin
         BlendState:=0;
         glDisable(GL_BLEND);
        end;
        if DepthWriteMaskState<>1 then begin
         DepthWriteMaskState:=1;
         glDepthMask(GL_TRUE);
        end;
       end;
       TPasGLTF.TMaterial.TAlphaMode.Mask:begin
        if BlendState<>0 then begin
         BlendState:=0;
         glDisable(GL_BLEND);
        end;
        if DepthWriteMaskState<>1 then begin
         DepthWriteMaskState:=1;
         glDepthMask(GL_TRUE);
        end;
       end;
       TPasGLTF.TMaterial.TAlphaMode.Blend:begin
        if BlendState<>1 then begin
         BlendState:=1;
         glEnable(GL_BLEND);
         glBlendFuncSeparate(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA,GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
        end;
        if DepthWriteMaskState<>0 then begin
         DepthWriteMaskState:=0;
         glDepthMask(GL_FALSE);
        end;
       end;
       else begin
        Assert(false);
       end;
      end;
      if Material^.DoubleSided then begin
       if CullFaceState<>0 then begin
        CullFaceState:=0;
        glDisable(GL_CULL_FACE);
       end;
      end else begin
       if CullFaceState<>1 then begin
        CullFaceState:=1;
        glEnable(GL_CULL_FACE);
       end;
      end;
{$if not defined(PasGLTFBindlessTextures)}
      case Material^.ShadingModel of
       TGLTFOpenGL.TMaterial.TShadingModel.PBRMetallicRoughness:begin
        if (Material^.PBRMetallicRoughness.BaseColorTexture.Index>=0) and (Material^.PBRMetallicRoughness.BaseColorTexture.Index<length(fParent.fTextures)) then begin
         glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[0]{$else}BaseTextureUnit{$endif});
         glBindTexture(GL_TEXTURE_2D,GetTextureHandle(fParent.fTextures[Material^.PBRMetallicRoughness.BaseColorTexture.Index]));
        end;
        if (Material^.PBRMetallicRoughness.MetallicRoughnessTexture.Index>=0) and (Material^.PBRMetallicRoughness.MetallicRoughnessTexture.Index<length(fParent.fTextures)) then begin
         glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[1]{$else}BaseTextureUnit+1{$endif});
         glBindTexture(GL_TEXTURE_2D,GetTextureHandle(fParent.fTextures[Material^.PBRMetallicRoughness.MetallicRoughnessTexture.Index]));
        end;
       end;
       TGLTFOpenGL.TMaterial.TShadingModel.PBRSpecularGlossiness:begin
        if (Material^.PBRSpecularGlossiness.DiffuseTexture.Index>=0) and (Material^.PBRSpecularGlossiness.DiffuseTexture.Index<length(fParent.fTextures)) then begin
         glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[0]{$else}BaseTextureUnit{$endif});
         glBindTexture(GL_TEXTURE_2D,GetTextureHandle(fParent.fTextures[Material^.PBRSpecularGlossiness.DiffuseTexture.Index]));
        end;
        if (Material^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index>=0) and (Material^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index<length(fParent.fTextures)) then begin
         glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[1]{$else}BaseTextureUnit+1{$endif});
         glBindTexture(GL_TEXTURE_2D,GetTextureHandle(fParent.fTextures[Material^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index]));
        end;
       end;
       TGLTFOpenGL.TMaterial.TShadingModel.Unlit:begin
        if (Material^.PBRMetallicRoughness.BaseColorTexture.Index>=0) and (Material^.PBRMetallicRoughness.BaseColorTexture.Index<length(fParent.fTextures)) then begin
         glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[0]{$else}BaseTextureUnit{$endif});
         glBindTexture(GL_TEXTURE_2D,GetTextureHandle(fParent.fTextures[Material^.PBRMetallicRoughness.BaseColorTexture.Index]));
        end;
       end;
       else begin
        Assert(false);
       end;
      end;
      if (Material^.NormalTexture.Index>=0) and (Material^.NormalTexture.Index<length(fParent.fTextures)) then begin
       glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[2]{$else}BaseTextureUnit+2{$endif});
       glBindTexture(GL_TEXTURE_2D,GetTextureHandle(fParent.fTextures[Material^.NormalTexture.Index]));
      end;
      if (Material^.OcclusionTexture.Index>=0) and (Material^.OcclusionTexture.Index<length(fParent.fTextures)) then begin
       glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[3]{$else}BaseTextureUnit+3{$endif});
       glBindTexture(GL_TEXTURE_2D,GetTextureHandle(fParent.fTextures[Material^.OcclusionTexture.Index]));
      end;
      if (Material^.EmissiveTexture.Index>=0) and (Material^.EmissiveTexture.Index<length(fParent.fTextures)) then begin
       glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[4]{$else}BaseTextureUnit+4{$endif});
       glBindTexture(GL_TEXTURE_2D,GetTextureHandle(fParent.fTextures[Material^.EmissiveTexture.Index]));
      end;
      if (Material^.PBRSheen.ColorIntensityTexture.Index>=0) and (Material^.PBRSheen.ColorIntensityTexture.Index<length(fParent.fTextures)) then begin
       glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[5]{$else}BaseTextureUnit+5{$endif});
       glBindTexture(GL_TEXTURE_2D,GetTextureHandle(fParent.fTextures[Material^.PBRSheen.ColorIntensityTexture.Index]));
      end;
      if (Material^.PBRClearCoat.Texture.Index>=0) and (Material^.PBRClearCoat.Texture.Index<length(fParent.fTextures)) then begin
       glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[6]{$else}BaseTextureUnit+6{$endif});
       glBindTexture(GL_TEXTURE_2D,GetTextureHandle(fParent.fTextures[Material^.PBRClearCoat.Texture.Index]));
      end;
      if (Material^.PBRClearCoat.RoughnessTexture.Index>=0) and (Material^.PBRClearCoat.RoughnessTexture.Index<length(fParent.fTextures)) then begin
       glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[7]{$else}BaseTextureUnit+7{$endif});
       glBindTexture(GL_TEXTURE_2D,GetTextureHandle(fParent.fTextures[Material^.PBRClearCoat.RoughnessTexture.Index]));
      end;
      if (Material^.PBRClearCoat.NormalTexture.Index>=0) and (Material^.PBRClearCoat.NormalTexture.Index<length(fParent.fTextures)) then begin
       glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[8]{$else}BaseTextureUnit+8{$endif});
       glBindTexture(GL_TEXTURE_2D,GetTextureHandle(fParent.fTextures[Material^.PBRClearCoat.NormalTexture.Index]));
      end;
{$ifend}
      glBindBufferRange(GL_UNIFORM_BUFFER,
                        TShadingShader.uboMaterial,
                        fParent.fMaterialUniformBufferObjects[Material^.UniformBufferObjectIndex].UniformBufferObjectHandle,
                        Material^.UniformBufferObjectOffset,
                        SizeOf(TMaterial.TUniformBufferObjectData));
      DoDraw:=true;
      DoClearTextures:=true;
     end;
    end else begin
     if aAlphaMode=TPasGLTF.TMaterial.TAlphaMode.Opaque then begin
      if BlendState<>0 then begin
       BlendState:=0;
       glDisable(GL_BLEND);
      end;
      if DepthWriteMaskState<>1 then begin
       DepthWriteMaskState:=1;
       glDepthMask(GL_TRUE);
      end;
      if CullFaceState<>1 then begin
       CullFaceState:=1;
       glEnable(GL_CULL_FACE);
      end;
      glBindBufferRange(GL_UNIFORM_BUFFER,
                        TShadingShader.uboMaterial,
                        fParent.fMaterialUniformBufferObjects[0].UniformBufferObjectHandle,
                        0,
                        SizeOf(TMaterial.TUniformBufferObjectData));
      DoDraw:=true;
     end;
    end;
    if DoDraw then begin
     if Primitive^.MorphTargetVertexShaderStorageBufferObjectIndex>=0 then begin
      MorphTargetVertexShaderStorageBufferObject:=@fParent.fMorphTargetVertexShaderStorageBufferObjects[Primitive^.MorphTargetVertexShaderStorageBufferObjectIndex];
      glBindBufferRange(GL_SHADER_STORAGE_BUFFER,
                        TShadingShader.ssboMorphTargetVertices,
                        MorphTargetVertexShaderStorageBufferObject^.ShaderStorageBufferObjectHandle,
                        Primitive^.MorphTargetVertexShaderStorageBufferObjectByteOffset,
                        Primitive^.MorphTargetVertexShaderStorageBufferObjectByteSize);
     end;
     MeshPrimitiveMetaData:=@Node^.MeshPrimitiveMetaDataArray[PrimitiveIndex];
     glBindBufferRange(GL_SHADER_STORAGE_BUFFER,
                       TShadingShader.ssboNodeMeshPrimitiveMetaData,
                       fParent.fNodeMeshPrimitiveShaderStorageBufferObjects[MeshPrimitiveMetaData^.ShaderStorageBufferObjectIndex].ShaderStorageBufferObjectHandle,
                       MeshPrimitiveMetaData^.ShaderStorageBufferObjectByteOffset,
                       MeshPrimitiveMetaData^.ShaderStorageBufferObjectByteSize);
     glBindBufferRange(GL_SHADER_STORAGE_BUFFER,
                       TShadingShader.ssboLightData,
                       fParent.fLightShaderStorageBufferObject.ShaderStorageBufferObjectHandle,
                       0,
                       fParent.fLightShaderStorageBufferObject.Size);
     glDrawElements(Primitive^.PrimitiveMode,
                    Primitive^.CountIndices,
                    GL_UNSIGNED_INT,
                    @PPasGLTFUInt32Array(nil)^[Primitive^.StartBufferIndexOffset]);
    end;
    if DoClearTextures then begin
{$if defined(PasGLTFCleanupTextures)}
     Material:=@fParent.fMaterials[Primitive^.Material];
{$if not defined(PasGLTFBindlessTextures)}
     case Material^.ShadingModel of
      TGLTFOpenGL.TMaterial.TShadingModel.PBRMetallicRoughness:begin
       if (Material^.PBRMetallicRoughness.BaseColorTexture.Index>=0) and (Material^.PBRMetallicRoughness.BaseColorTexture.Index<length(fParent.fTextures)) then begin
        glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[0]{$else}BaseTextureUnit{$endif});
        glBindTexture(GL_TEXTURE_2D,0);
       end;
       if (Material^.PBRMetallicRoughness.MetallicRoughnessTexture.Index>=0) and (Material^.PBRMetallicRoughness.MetallicRoughnessTexture.Index<length(fParent.fTextures)) then begin
        glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[1]{$else}BaseTextureUnit+1{$endif});
        glBindTexture(GL_TEXTURE_2D,0);
       end;
      end;
      TGLTFOpenGL.TMaterial.TShadingModel.PBRSpecularGlossiness:begin
       if (Material^.PBRSpecularGlossiness.DiffuseTexture.Index>=0) and (Material^.PBRSpecularGlossiness.DiffuseTexture.Index<length(fParent.fTextures)) then begin
        glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[0]{$else}BaseTextureUnit{$endif});
        glBindTexture(GL_TEXTURE_2D,0);
       end;
       if (Material^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index>=0) and (Material^.PBRSpecularGlossiness.SpecularGlossinessTexture.Index<length(fParent.fTextures)) then begin
        glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[1]{$else}BaseTextureUnit+1{$endif});
        glBindTexture(GL_TEXTURE_2D,0);
       end;
      end;
      TGLTFOpenGL.TMaterial.TShadingModel.Unlit:begin
       if (Material^.PBRMetallicRoughness.BaseColorTexture.Index>=0) and (Material^.PBRMetallicRoughness.BaseColorTexture.Index<length(fParent.fTextures)) then begin
        glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[0]{$else}BaseTextureUnit{$endif});
        glBindTexture(GL_TEXTURE_2D,0);
       end;
      end;
      else begin
       Assert(false);
      end;
     end;
     if (Material^.NormalTexture.Index>=0) and (Material^.NormalTexture.Index<length(fParent.fTextures)) then begin
      glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[2]{$else}BaseTextureUnit+2{$endif});
      glBindTexture(GL_TEXTURE_2D,0);
     end;
     if (Material^.OcclusionTexture.Index>=0) and (Material^.OcclusionTexture.Index<length(fParent.fTextures)) then begin
      glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[3]{$else}BaseTextureUnit+3{$endif});
      glBindTexture(GL_TEXTURE_2D,0);
     end;
     if (Material^.EmissiveTexture.Index>=0) and (Material^.EmissiveTexture.Index<length(fParent.fTextures)) then begin
      glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[4]{$else}BaseTextureUnit+4{$endif});
      glBindTexture(GL_TEXTURE_2D,0);
     end;
     if (Material^.PBRSheen.ColorIntensityTexture.Index>=0) and (Material^.PBRSheen.ColorIntensityTexture.Index<length(fParent.fTextures)) then begin
      glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[5]{$else}BaseTextureUnit+5{$endif});
      glBindTexture(GL_TEXTURE_2D,0);
     end;
     if (Material^.PBRClearCoat.Texture.Index>=0) and (Material^.PBRClearCoat.Texture.Index<length(fParent.fTextures)) then begin
      glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[6]{$else}BaseTextureUnit+6{$endif});
      glBindTexture(GL_TEXTURE_2D,0);
     end;
     if (Material^.PBRClearCoat.RoughnessTexture.Index>=0) and (Material^.PBRClearCoat.RoughnessTexture.Index<length(fParent.fTextures)) then begin
      glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[7]{$else}BaseTextureUnit+7{$endif});
      glBindTexture(GL_TEXTURE_2D,0);
     end;
     if (Material^.PBRClearCoat.NormalTexture.Index>=0) and (Material^.PBRClearCoat.NormalTexture.Index<length(fParent.fTextures)) then begin
      glActiveTexture({$ifdef PasGLTFIndicatedTextures}BaseTextureUnit+Material^.UniformBufferObjectData.TextureIndices[8]{$else}BaseTextureUnit+8{$endif});
      glBindTexture(GL_TEXTURE_2D,0);
     end;
{$ifend}
{$ifend}
    end;
   end;
  end;
 var Index:TPasGLTFSizeInt;
     Skin:TGLTFOpenGL.PSkin;
     SkinShaderStorageBufferObject:TGLTFOpenGL.PSkinShaderStorageBufferObject;
 begin
  InstanceNode:=@fNodes[aNodeIndex];
  Node:=@fParent.fNodes[aNodeIndex];
  if (Node^.Mesh>=0) and (Node^.Mesh<length(fParent.fMeshes)) then begin
   if (fAnimation>=0) and
      ((Node^.Skin>=0) and (Node^.Skin<length(fParent.fSkins))) and
      (fParent.fSkins[Node^.Skin].SkinShaderStorageBufferObjectIndex>=0) then begin
    Skin:=@fParent.fSkins[Node^.Skin];
    SkinShaderStorageBufferObject:=@fParent.fSkinShaderStorageBufferObjects[Skin^.SkinShaderStorageBufferObjectIndex];
    if CurrentSkinShaderStorageBufferObjectHandle<>SkinShaderStorageBufferObject^.ShaderStorageBufferObjectHandle then begin
     CurrentSkinShaderStorageBufferObjectHandle:=SkinShaderStorageBufferObject^.ShaderStorageBufferObjectHandle;
     glBindBufferBase(GL_SHADER_STORAGE_BUFFER,
                      TShadingShader.ssboJointMatrices,
                      SkinShaderStorageBufferObject^.ShaderStorageBufferObjectHandle);
    end;
    ShadingShader:=SkinnedShadingShader;
   end else begin
    ShadingShader:=NonSkinnedShadingShader;
   end;
   UseShader(ShadingShader);
   DrawMesh(fParent.fMeshes[Node^.Mesh]);
  end;
  for Index:=0 to length(Node^.Children)-1 do begin
   DrawNode(Node^.Children[Index],aAlphaMode);
  end;
 end;
 procedure UpdateFrameGlobalsUniformBufferObject;
 var p:PFrameGlobalsUniformBufferObjectData;
 begin
  glBindBuffer(GL_UNIFORM_BUFFER,fParent.fFrameGlobalsUniformBufferObjectHandle);
  p:=glMapBufferRange(GL_UNIFORM_BUFFER,0,SizeOf(TFrameGlobalsUniformBufferObjectData),GL_MAP_WRITE_BIT or GL_MAP_INVALIDATE_BUFFER_BIT);
  if assigned(p) then begin
   p^.InverseViewMatrix:=MatrixInverse(aViewMatrix);
   p^.ModelMatrix:=aModelMatrix;
   p^.ViewProjectionMatrix:=MatrixMul(aViewMatrix,aProjectionMatrix);
   p^.NormalMatrix:=aModelMatrix;
   p^.NormalMatrix[3]:=0.0;
   p^.NormalMatrix[7]:=0.0;
   p^.NormalMatrix[11]:=0.0;
   p^.NormalMatrix[15]:=1.0;
   p^.NormalMatrix:=MatrixTranspose(MatrixInverse(p^.NormalMatrix));
   glUnmapBuffer(GL_UNIFORM_BUFFER);
  end;
  glBindBufferBase(GL_UNIFORM_BUFFER,
                   TShadingShader.uboFrameGlobals,
                   fParent.fFrameGlobalsUniformBufferObjectHandle);
 end;
 procedure UpdateLights;
 const Zero:TPasGLTF.TVector3=(0.0,0.0,0.0);
       DownZ:TPasGLTF.TVector3=(0.0,0.0,-1.0);
 var Index,NodeIndex:TPasGLTFSizeInt;
     Light:PLight;
     LightShaderStorageBufferObjectDataItem:PLightShaderStorageBufferObjectDataItem;
     InstanceNode:TGLTFOpenGL.TInstance.PNode;
     Matrix:TPasGLTF.TMatrix4x4;
 begin
  if length(fParent.fLights)>0 then begin
   for Index:=0 to length(fParent.fLights)-1 do begin
    Light:=@fParent.fLights[Index];
    LightShaderStorageBufferObjectDataItem:=@fParent.fLightShaderStorageBufferObject.Data^.Lights[Index];
    NodeIndex:=fLightNodes[Index];
    if (NodeIndex>=0) and (NodeIndex<length(fNodes)) then begin
     InstanceNode:=@fNodes[NodeIndex];
     Matrix:=InstanceNode^.WorkMatrix;
     TPasGLTF.TVector3(pointer(@Matrix[0])^):=Vector3Normalize(TPasGLTF.TVector3(pointer(@Matrix[0])^));
     TPasGLTF.TVector3(pointer(@Matrix[4])^):=Vector3Normalize(TPasGLTF.TVector3(pointer(@Matrix[4])^));
     TPasGLTF.TVector3(pointer(@Matrix[8])^):=Vector3Normalize(TPasGLTF.TVector3(pointer(@Matrix[8])^));
     TPasGLTF.TVector3(pointer(@LightShaderStorageBufferObjectDataItem^.PositionRange)^):=Vector3MatrixMul(Matrix,Zero);
     TPasGLTF.TVector3(pointer(@LightShaderStorageBufferObjectDataItem^.DirectionZFar)^):=Vector3Normalize(Vector3Sub(Vector3MatrixMul(Matrix,DownZ),TPasGLTF.TVector3(pointer(@LightShaderStorageBufferObjectDataItem^.PositionRange)^)));
    end else begin
     LightShaderStorageBufferObjectDataItem^.PositionRange[0]:=0.0;
     LightShaderStorageBufferObjectDataItem^.PositionRange[1]:=0.0;
     LightShaderStorageBufferObjectDataItem^.PositionRange[2]:=0.0;
     case Light^.Node of
      -$8000000:begin
       // For default directional light, when no other lights were defined
       TPasGLTF.TVector3(pointer(@LightShaderStorageBufferObjectDataItem^.DirectionZFar[0])^):=Light^.Direction;
      end;
      else begin
       LightShaderStorageBufferObjectDataItem^.DirectionZFar[0]:=0.0;
       LightShaderStorageBufferObjectDataItem^.DirectionZFar[1]:=0.0;
       LightShaderStorageBufferObjectDataItem^.DirectionZFar[2]:=-1.0;
      end;
     end;
    end;
    LightShaderStorageBufferObjectDataItem^.DirectionZFar[3]:=fLightShadowMapZFarValues[Index];
    LightShaderStorageBufferObjectDataItem^.ShadowMapMatrix:=fLightShadowMapMatrices[Index];
   end;
   glBindBuffer(GL_SHADER_STORAGE_BUFFER,fParent.fLightShaderStorageBufferObject.ShaderStorageBufferObjectHandle);
   glBufferData(GL_SHADER_STORAGE_BUFFER,fParent.fLightShaderStorageBufferObject.Size,fParent.fLightShaderStorageBufferObject.Data,GL_DYNAMIC_DRAW);
   glBindBuffer(GL_SHADER_STORAGE_BUFFER,0);
  end;
 end;
var Index:TPasGLTFSizeInt;
    Scene:PScene;
    AlphaMode:TPasGLTF.TMaterial.TAlphaMode;
    PreviousDepthWriteMask:TGLboolean;
begin
 Scene:=GetScene;
 if assigned(Scene) then begin
  CurrentSkinShaderStorageBufferObjectHandle:=0;
  UpdateFrameGlobalsUniformBufferObject;
  UpdateLights;
  PreviousDepthWriteMask:=GL_FALSE;
  glGetBooleanv(GL_DEPTH_WRITEMASK,@PreviousDepthWriteMask);
  glBindVertexArray(fParent.fVertexArrayHandle);
  glBindBuffer(GL_ARRAY_BUFFER,fParent.fVertexBufferObjectHandle);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,fParent.fIndexBufferObjectHandle);
  glCullFace(GL_BACK);
  CullFaceState:=-1;
  BlendState:=-1;
  DepthWriteMaskState:=-1;
  CurrentShader:=nil;
  for AlphaMode:=TPasGLTF.TMaterial.TAlphaMode.Opaque to TPasGLTF.TMaterial.TAlphaMode.Blend do begin
   if (aAlphaModes=[]) or (AlphaMode in aAlphaModes) then begin
    case AlphaMode of
     TPasGLTF.TMaterial.TAlphaMode.Opaque:begin
      NonSkinnedShadingShader:=aNonSkinnedNormalShadingShader;
      SkinnedShadingShader:=aSkinnedNormalShadingShader;
     end;
     TPasGLTF.TMaterial.TAlphaMode.Mask:begin
      NonSkinnedShadingShader:=aNonSkinnedAlphaTestShadingShader;
      SkinnedShadingShader:=aSkinnedAlphaTestShadingShader;
     end;
     TPasGLTF.TMaterial.TAlphaMode.Blend:begin
      NonSkinnedShadingShader:=aNonSkinnedNormalShadingShader;
      SkinnedShadingShader:=aSkinnedNormalShadingShader;
     end;
     else begin
      NonSkinnedShadingShader:=nil;
      Assert(false);
     end;
    end;
    for Index:=0 to length(Scene^.Nodes)-1 do begin
     DrawNode(Scene^.Nodes[Index],AlphaMode);
    end;
   end;
  end;
  glUseProgram(0);
  glBindVertexArray(0);
  glBindBuffer(GL_ARRAY_BUFFER,0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);
  glActiveTexture(GL_TEXTURE0);
  if (DepthWriteMaskState>=0) and ((DepthWriteMaskState<>0)<>(PreviousDepthWriteMask<>GL_FALSE)) then begin
   glDepthMask(PreviousDepthWriteMask);
  end;
 end;
end;

procedure TGLTFOpenGL.TInstance.DrawShadows(const aModelMatrix:TPasGLTF.TMatrix4x4;
                                            const aViewMatrix:TPasGLTF.TMatrix4x4;
                                            const aProjectionMatrix:TPasGLTF.TMatrix4x4;
                                            const aShadowMapMultisampleResolveShader:TShadowMapMultisampleResolveShader;
                                            const aShadowMapBlurShader:TShadowMapBlurShader;
                                            const aNonSkinnedNormalShadingShader:TShadingShader;
                                            const aNonSkinnedAlphaTestShadingShader:TShadingShader;
                                            const aSkinnedNormalShadingShader:TShadingShader;
                                            const aSkinnedAlphaTestShadingShader:TShadingShader;
                                            const aAlphaModes:TPasGLTF.TMaterial.TAlphaModes=[]);
var LightZFar:TPasGLTFFloat;
 function GetDirectionalLightShadowMapMatrix(const aLightDirection:TPasGLTF.TVector3;
                                             const aShadowCastersAABB:TAABB;
                                             const aShadowReceiversAABB:TAABB):TPasGLTF.TMatrix4x4;
 var CameraViewProjectionMatrix,
     CameraInverseViewProjectionMatrix,
     CameraInverseViewMatrix:TPasGLTF.TMatrix4x4;
     WorldSpaceCameraViewFrustumCorners:array[0..7] of TPasGLTF.TVector3;
     InterestedAreaAABB:TAABB;
  function GetLightModelMatrix:TPasGLTF.TMatrix4x4;
  var LightForwardVector,LightSideVector,LightUpvector,p:TPasGLTF.TVector3;
  begin
{$ifdef fpc}
   LightForwardVector:=Vector3Neg(Vector3Normalize(aLightDirection));
{$else}
   // Workaround for a bug in the 64-bit Delphi 10.3.3 Win64 compiler regarding stack allocation and register allocation
   LightForwardVector:=Vector3Normalize(aLightDirection);
   LightForwardVector:=Vector3Neg(LightForwardVector);
{$endif}
   p[0]:=abs(LightForwardVector[0]);
   p[1]:=abs(LightForwardVector[1]);
   p[2]:=abs(LightForwardVector[2]);
   if (p[0]<=p[1]) and (p[0]<=p[2]) then begin
    p[0]:=1.0;
    p[1]:=0.0;
    p[2]:=0.0;
   end else if (p[1]<=p[0]) and (p[1]<=p[2]) then begin
    p[0]:=0.0;
    p[1]:=1.0;
    p[2]:=0.0;
   end else begin
    p[0]:=0.0;
    p[1]:=0.0;
    p[2]:=1.0;
   end;
   LightSideVector:=Vector3Sub(p,Vector3ScalarMul(LightForwardVector,Vector3Dot(LightForwardVector,p)));
   LightUpVector:=Vector3Normalize(Vector3Cross(LightForwardVector,LightSideVector));
   LightSideVector:=Vector3Normalize(Vector3Cross(LightUpVector,LightForwardVector));
   result[0]:=LightSideVector[0];
   result[1]:=LightUpVector[0];
   result[2]:=LightForwardVector[0];
   result[3]:=0.0;
   result[4]:=LightSideVector[1];
   result[5]:=LightUpVector[1];
   result[6]:=LightForwardVector[1];
   result[7]:=0.0;
   result[8]:=LightSideVector[2];
   result[9]:=LightUpVector[2];
   result[10]:=LightForwardVector[2];
   result[11]:=0.0;
   result[12]:=0.0;
   result[13]:=0.0;
   result[14]:=0.0;
   result[15]:=1.0;
  end;
  function GetLightViewMatrix:TPasGLTF.TMatrix4x4;
  var LightModelMatrix:TPasGLTF.TMatrix4x4;
      WorldSpaceCameraForwardVector,
      LightSpaceCameraForwardVector:TPasGLTF.TVector3;
  begin
   result:=TPasGLTF.TDefaults.IdentityMatrix4x4;
   LightModelMatrix:=GetLightModelMatrix;
   WorldSpaceCameraForwardVector:=TPasGLTF.PVector3(@CameraInverseViewMatrix[8])^;
   LightSpaceCameraForwardVector:=Vector3MatrixMul(LightModelMatrix,WorldSpaceCameraForwardVector);
   if abs(LightSpaceCameraForwardVector[2])<0.9997 then begin
    TPasGLTF.PVector3(@result[0])^:=Vector3Normalize(Vector3Cross(LightSpaceCameraForwardVector,Vector3(0.0,0.0,1.0)));
    TPasGLTF.PVector3(@result[4])^:=Vector3Normalize(Vector3Cross(Vector3(0.0,0.0,1.0),TPasGLTF.PVector3(@result[0])^));
    TPasGLTF.PVector3(@result[8])^:=Vector3(0.0,0.0,1.0);
   end;
   result:=MatrixMul(LightModelMatrix,MatrixTranspose(result));
  end;
  function GetLightProjectionMatrix(const aShadowMapViewMatrix:TPasGLTF.TMatrix4x4):TPasGLTF.TMatrix4x4;
  var AABB:TAABB;
      Left,Right,Top,Bottom,ZNear,ZFar,RightMinusLeft,TopMinusBottom,FarMinusNear:TPasGLTFFloat;
  begin
   AABB:=AABBTransform(InterestedAreaAABB,aShadowMapViewMatrix);
   Left:=-1.0;
   Right:=1.0;
   Bottom:=-1.0;
   Top:=1.0;
   ZNear:=-AABB.Max[2];
   ZFar:=-AABB.Min[2];
   LightZFar:=ZFar;
   RightMinusLeft:=Right-Left;
   TopMinusBottom:=Top-Bottom;
   FarMinusNear:=ZFar-ZNear;
   result[0]:=2.0/RightMinusLeft;
   result[1]:=0.0;
   result[2]:=0.0;
   result[3]:=0.0;
   result[4]:=0.0;
   result[5]:=2.0/TopMinusBottom;
   result[6]:=0.0;
   result[7]:=0.0;
   result[8]:=0.0;
   result[9]:=0.0;
   result[10]:=(-2.0)/FarMinusNear;
   result[11]:=0.0;
   result[12]:=(-(Right+Left))/RightMinusLeft;
   result[13]:=(-(Top+Bottom))/TopMinusBottom;
   result[14]:=(-(ZFar+ZNear))/FarMinusNear;
   result[15]:=1.0;
  end;
  procedure SnapShadowMapProjectionMatrix(const aShadowMapViewMatrix:TPasGLTF.TMatrix4x4;
                                          var aShadowMapProjectionMatrix:TPasGLTF.TMatrix4x4;
                                          const aShadowMapWidth:TPasGLTFInt32;
                                          const aShadowMapHeight:TPasGLTFInt32);
  var RoundedOrigin,RoundOffset:TPasGLTF.TVector2;
      ShadowOrigin:TPasGLTF.TVector4;
  begin
   // Create the rounding matrix, by projecting the world-space origin and determining the fractional offset in texel space
   ShadowOrigin:=Vector4MatrixMul(MatrixMul(aShadowMapViewMatrix,aShadowMapProjectionMatrix),Vector4(0.0,0.0,0.0,1.0));
   ShadowOrigin[0]:=ShadowOrigin[0]*aShadowMapWidth;
   ShadowOrigin[1]:=ShadowOrigin[1]*aShadowMapHeight;
   RoundedOrigin[0]:=round(ShadowOrigin[0]);
   RoundedOrigin[1]:=round(ShadowOrigin[1]);
   RoundOffset[0]:=((RoundedOrigin[0]-ShadowOrigin[0])*2.0)/aShadowMapWidth;
   RoundOffset[1]:=((RoundedOrigin[1]-ShadowOrigin[1])*2.0)/aShadowMapHeight;
   aShadowMapProjectionMatrix[12]:=aShadowMapProjectionMatrix[12]+RoundOffset[0];
   aShadowMapProjectionMatrix[13]:=aShadowMapProjectionMatrix[13]+RoundOffset[1];
  end;
 const NormalizedClipSpaceCameraViewFrustumCorners:array[0..7] of TPasGLTF.TVector3=((-1,-1,1),
                                                                                     (1,-1,1),
                                                                                     (-1,1,1),
                                                                                     (1,1,1),
                                                                                     (-1,-1,-1),
                                                                                     (1,-1,-1),
                                                                                     (-1,1,-1),
                                                                                     (1,1,-1));
 var Index:TPasGLTFSizeInt;
     LightViewMatrix,
     LightProjectionMatrix,
     LightSpaceMatrix,
     WarpMatrix,WarppedLightSpaceMatrix,
     FocusTransformMatrix:TPasGLTF.TMatrix4x4;
     WorldSpaceCameraViewFrustumAABB,
     LightSpaceAABB:TAABB;
     Scale,
     Offset:TPasGLTF.TVector2;
     ShadowMapDimension:TPasGLTFFloat;
 begin
  CameraViewProjectionMatrix:=MatrixMul(aViewMatrix,aProjectionMatrix);
  CameraInverseViewProjectionMatrix:=MatrixInverse(CameraViewProjectionMatrix);
  CameraInverseViewMatrix:=MatrixInverse(aViewMatrix);
  for Index:=Low(WorldSpaceCameraViewFrustumCorners) to High(WorldSpaceCameraViewFrustumCorners) do begin
   WorldSpaceCameraViewFrustumCorners[Index]:=Vector3MatrixMulHomogen(CameraInverseViewProjectionMatrix,NormalizedClipSpaceCameraViewFrustumCorners[Index]);
  end;
  WorldSpaceCameraViewFrustumAABB.Min:=WorldSpaceCameraViewFrustumCorners[Low(WorldSpaceCameraViewFrustumCorners)];
  WorldSpaceCameraViewFrustumAABB.Max:=WorldSpaceCameraViewFrustumCorners[Low(WorldSpaceCameraViewFrustumCorners)];
  for Index:=Low(WorldSpaceCameraViewFrustumCorners)+1 to High(WorldSpaceCameraViewFrustumCorners) do begin
   WorldSpaceCameraViewFrustumAABB:=AABBCombineVector3(WorldSpaceCameraViewFrustumAABB,WorldSpaceCameraViewFrustumCorners[Index]);
  end;
  InterestedAreaAABB:=AABBCombine(aShadowCastersAABB,aShadowReceiversAABB);
  LightViewMatrix:=GetLightViewMatrix;
  LightProjectionMatrix:=GetLightProjectionMatrix(LightViewMatrix);
  LightSpaceMatrix:=MatrixMul(LightViewMatrix,LightProjectionMatrix);
  WarpMatrix:=TPasGLTF.TDefaults.IdentityMatrix4x4;
  WarppedLightSpaceMatrix:=MatrixMul(LightSpaceMatrix,WarpMatrix);
  LightSpaceAABB:=AABBTransform(InterestedAreaAABB,WarppedLightSpaceMatrix);
  ShadowMapDimension:=fParent.fShadowMapSize;
  Scale[0]:=2.0/(LightSpaceAABB.Max[0]-LightSpaceAABB.Min[0]);
  Scale[1]:=2.0/(LightSpaceAABB.Max[1]-LightSpaceAABB.Min[1]);
  Offset[0]:=((LightSpaceAABB.Min[0]+LightSpaceAABB.Max[0])*(-0.5))*Scale[0];
  Offset[1]:=((LightSpaceAABB.Min[1]+LightSpaceAABB.Max[1])*(-0.5))*Scale[1];
  // TODO: Snap scale also
  Offset[0]:=ceil(Offset[0]*ShadowMapDimension)/ShadowMapDimension;
  Offset[1]:=ceil(Offset[1]*ShadowMapDimension)/ShadowMapDimension;
  FocusTransformMatrix[0]:=Scale[0];
  FocusTransformMatrix[1]:=0.0;
  FocusTransformMatrix[2]:=0.0;
  FocusTransformMatrix[3]:=0.0;
  FocusTransformMatrix[4]:=0.0;
  FocusTransformMatrix[5]:=Scale[1];
  FocusTransformMatrix[6]:=0.0;
  FocusTransformMatrix[7]:=0.0;
  FocusTransformMatrix[8]:=0.0;
  FocusTransformMatrix[9]:=0.0;
  FocusTransformMatrix[10]:=1.0;
  FocusTransformMatrix[11]:=0.0;
  FocusTransformMatrix[12]:=Offset[0];
  FocusTransformMatrix[13]:=Offset[1];
  FocusTransformMatrix[14]:=0.0;
  FocusTransformMatrix[15]:=1.0;
  result:=MatrixMul(WarppedLightSpaceMatrix,FocusTransformMatrix);
 end;
 procedure RenderToMultisampledShadowMap(const aShadowMapMatrix:TPasGLTF.TMatrix4x4);
 begin
  glBindFramebuffer(GL_FRAMEBUFFER,fParent.fTemporaryMultisampledShadowMapFrameBufferObject);
  glDrawBuffer(GL_COLOR_ATTACHMENT0);
  glEnable(GL_MULTISAMPLE);
  glViewport(0,0,fParent.fShadowMapSize,fParent.fShadowMapSize);
  glClearColor(1.0,1.0,1.0,1.0);
  glClearDepth(1.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glClipControl(GL_LOWER_LEFT,GL_NEGATIVE_ONE_TO_ONE);
  glEnable(GL_DEPTH_TEST);
  glDepthFunc(GL_LEQUAL);
  Draw(TPasGLTF.TMatrix4x4(Pointer(@aModelMatrix)^),
       TPasGLTF.TMatrix4x4(Pointer(@TPasGLTF.TDefaults.IdentityMatrix4x4)^),
       TPasGLTF.TMatrix4x4(Pointer(@aShadowMapMatrix)^),
       aNonSkinnedNormalShadingShader,
       aNonSkinnedAlphaTestShadingShader,
       aSkinnedNormalShadingShader,
       aSkinnedAlphaTestShadingShader,
       aAlphaModes);
  glBindFrameBuffer(GL_FRAMEBUFFER,0);
  glDisable(GL_MULTISAMPLE);
 end;
 procedure ResolveMultisampledShadowMap(const aFrameBufferObject:glUInt);
 begin
  glBindFrameBuffer(GL_FRAMEBUFFER,aFrameBufferObject);
  glDrawBuffer(GL_COLOR_ATTACHMENT0);
  glViewport(0,0,fParent.fShadowMapSize,fParent.fShadowMapSize);
  glClear(GL_COLOR_BUFFER_BIT);
  glDisable(GL_BLEND);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_CULL_FACE);
  glDepthFunc(GL_ALWAYS);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D_MULTISAMPLE,fParent.fTemporaryMultisampledShadowMapTexture);
  aShadowMapMultisampleResolveShader.Bind;
  glUniform1i(aShadowMapMultisampleResolveShader.uTexture,0);
  glUniform1i(aShadowMapMultisampleResolveShader.uSamples,fParent.fTemporaryMultisampledShadowMapSamples);
  glBindVertexArray(fParent.fEmptyVertexArrayObjectHandle);
  glDrawArrays(GL_TRIANGLES,0,3);
  glBindVertexArray(0);
  aShadowMapMultisampleResolveShader.Unbind;
  glBindFrameBuffer(GL_FRAMEBUFFER,0);
  glBindTexture(GL_TEXTURE_2D_MULTISAMPLE,0);
 end;
 procedure BlurShadowMap(const aFrameBufferObject:glUInt=0);
 var Index:TPasGLTFSizeInt;
 begin
  for Index:=0 to 1 do begin
   if (Index=1) and (aFrameBufferObject<>0) then begin
    glBindFrameBuffer(GL_FRAMEBUFFER,aFrameBufferObject);
   end else begin
    glBindFrameBuffer(GL_FRAMEBUFFER,fParent.fTemporaryShadowMapFrameBufferObjects[Index]);
   end;
   glDrawBuffer(GL_COLOR_ATTACHMENT0);
   glViewport(0,0,fParent.fShadowMapSize,fParent.fShadowMapSize);
   glClear(GL_COLOR_BUFFER_BIT);
   glDisable(GL_BLEND);
   glDisable(GL_DEPTH_TEST);
   glDisable(GL_CULL_FACE);
   glDepthFunc(GL_ALWAYS);
   glActiveTexture(GL_TEXTURE0);
   glBindTexture(GL_TEXTURE_2D,fParent.fTemporaryShadowMapTextures[(Index+1) and 1]);
   aShadowMapBlurShader.Bind;
   glUniform1i(aShadowMapBlurShader.uTexture,0);
   if Index=1 then begin
    glUniform2f(aShadowMapBlurShader.uDirection,1.0,0.0);
   end else begin
    glUniform2f(aShadowMapBlurShader.uDirection,0.0,1.0);
   end;
   glBindVertexArray(fParent.fEmptyVertexArrayObjectHandle);
   glDrawArrays(GL_TRIANGLES,0,3);
   glBindVertexArray(0);
   aShadowMapBlurShader.Unbind;
   glBindFrameBuffer(GL_FRAMEBUFFER,0);
   glBindTexture(GL_TEXTURE_2D,0);
  end;
 end;
 function GetSpotLightShadowMapMatrix(const aLightPosition,aLightDirection:TPasGLTF.TVector3;const aRange,aFOV:TPasGLTFFloat;const aAABB:TAABB):TPasGLTF.TMatrix4x4;
 const DEG2RAD=PI/180;
       RAD2DEG=180/PI;
 var ViewMatrix,ProjectionMatrix:TPasGLTF.TMatrix4x4;
     ZNear,ZFar,f,a,b:TPasGLTFFloat;
     UpVector:TVector3;
 begin
  ZNear:=0.1;
  if aRange>1e-4 then begin
   ZFar:=Max(1.0,aRange);
  end else begin
   ZFar:=Max(1.0,sqrt(sqr(aAABB.Max[0]-aAABB.Min[0])+sqr(aAABB.Max[1]-aAABB.Min[1])+sqr(aAABB.Max[2]-aAABB.Min[2])));
  end;
  UpVector:=Vector3(0.0,1.0,0.0);
  if abs(Vector3Dot(UpVector,aLightPosition))>0.9 then begin
   UpVector:=Vector3(0.0,0.0,1.0);
  end;
  LightZFar:=ZFar;
  ViewMatrix:=MatrixLookAt(aLightPosition,Vector3Add(aLightPosition,aLightDirection),UpVector);
  f:=1.0/tan(Min(Max((aFOV*RAD2DEG)*2.0,10.0),170.0)*DEG2RAD*0.5);
  ProjectionMatrix[0]:=f;
  ProjectionMatrix[1]:=0.0;
  ProjectionMatrix[2]:=0.0;
  ProjectionMatrix[3]:=0.0;
  ProjectionMatrix[4]:=0.0;
  ProjectionMatrix[5]:=f;
  ProjectionMatrix[6]:=0.0;
  ProjectionMatrix[7]:=0.0;
  ProjectionMatrix[8]:=0.0;
  ProjectionMatrix[9]:=0.0;
  ProjectionMatrix[10]:=(-(ZFar+ZNear))/(ZFar-ZNear);
  ProjectionMatrix[11]:=-1.0;
  ProjectionMatrix[12]:=0.0;
  ProjectionMatrix[13]:=0.0;
  ProjectionMatrix[14]:=(-(2.0*ZNear*ZFar))/(ZFar-ZNear);
  ProjectionMatrix[15]:=0.0;
  result:=MatrixMul(ViewMatrix,ProjectionMatrix);
 end;
 function GetPointLightShadowMapMatrix(const aLightPosition:TPasGLTF.TVector3;const aRange:TPasGLTFFloat;const aAABB:TAABB;const aSideIndex:TPasGLTFSizeInt):TPasGLTF.TMatrix4x4;
 const CubeMapMatrices:array[0..5] of TPasGLTF.TMatrix4x4=
        (
         (0.0,0.0,-1.0,0.0,0.0,-1.0,0.0,0.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0),  // pos x
         (0.0,0.0,1.0,0.0,0.0,-1.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0),    // neg x
         (1.0,0.0,0.0,0.0,0.0,0.0,-1.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,0.0,1.0),    // pos y
         (1.0,0.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,-1.0,0.0,0.0,0.0,0.0,0.0,1.0),    // neg y
         (1.0,0.0,0.0,0.0,0.0,-1.0,0.0,0.0,0.0,0.0,-1.0,0.0,0.0,0.0,0.0,1.0),   // pos z
         (-1.0,0.0,0.0,0.0,0.0,-1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0)    // neg z
        );
 const DEG2RAD=PI/180;
       AspectRatio=1.0;
       InverseAspectRatio=1.0/AspectRatio;
 var ViewMatrix,ProjectionMatrix:TPasGLTF.TMatrix4x4;
     ZNear,ZFar,f:TPasGLTFFloat;
 begin
  ZNear:=0.1;
  if aRange>1e-4 then begin
   ZFar:=Max(1.0,aRange);
  end else begin
   ZFar:=Max(1.0,sqrt(sqr(aAABB.Max[0]-aAABB.Min[0])+sqr(aAABB.Max[1]-aAABB.Min[1])+sqr(aAABB.Max[2]-aAABB.Min[2])));
  end;
  LightZFar:=ZFar;
  ViewMatrix:=MatrixMul(CubeMapMatrices[aSideIndex],MatrixFromTranslation(Vector3Neg(aLightPosition)));
  f:=1.0/tan(90.0*DEG2RAD*0.5);
  ProjectionMatrix[0]:=f*InverseAspectRatio;
  ProjectionMatrix[1]:=0.0;
  ProjectionMatrix[2]:=0.0;
  ProjectionMatrix[3]:=0.0;
  ProjectionMatrix[4]:=0.0;
  ProjectionMatrix[5]:=f;
  ProjectionMatrix[6]:=0.0;
  ProjectionMatrix[7]:=0.0;
  ProjectionMatrix[8]:=0.0;
  ProjectionMatrix[9]:=0.0;
  ProjectionMatrix[10]:=(-(ZFar+ZNear))/(ZFar-ZNear);
  ProjectionMatrix[11]:=-1.0;
  ProjectionMatrix[12]:=0.0;
  ProjectionMatrix[13]:=0.0;
  ProjectionMatrix[14]:=(-(2.0*ZNear*ZFar))/(ZFar-ZNear);
  ProjectionMatrix[15]:=0.0;
  result:=MatrixMul(ViewMatrix,ProjectionMatrix);
 end;
const Zero:TPasGLTF.TVector3=(0.0,0.0,0.0);
      DownZ:TPasGLTF.TVector3=(0.0,0.0,-1.0);
var LightIndex,NodeIndex,SideIndex:TPasGLTFSizeInt;
    Light:PLight;
    InstanceNode:TGLTFOpenGL.TInstance.PNode;
    Matrix,ShadowMapMatrix:TPasGLTF.TMatrix4x4;
    Position,Direction:TPasGLTF.TVector3;
    AABB:TAABB;
begin
 if length(fParent.fLights)>0 then begin
  AABB.Min:=fParent.fStaticBoundingBox.Min;
  AABB.Max:=fParent.fStaticBoundingBox.Max;
  for LightIndex:=0 to length(fParent.fLights)-1 do begin
   Light:=@fParent.fLights[LightIndex];
   if (Light^.ShadowMapIndex>=0) and Light^.CastShadows then begin
    NodeIndex:=fLightNodes[LightIndex];
    if (NodeIndex>=0) and (NodeIndex<length(fNodes)) then begin
     InstanceNode:=@fNodes[NodeIndex];
     Matrix:=InstanceNode^.WorkMatrix;
     TPasGLTF.TVector3(pointer(@Matrix[0])^):=Vector3Normalize(TPasGLTF.TVector3(pointer(@Matrix[0])^));
     TPasGLTF.TVector3(pointer(@Matrix[4])^):=Vector3Normalize(TPasGLTF.TVector3(pointer(@Matrix[4])^));
     TPasGLTF.TVector3(pointer(@Matrix[8])^):=Vector3Normalize(TPasGLTF.TVector3(pointer(@Matrix[8])^));
     Position:=Vector3MatrixMul(Matrix,Zero);
     Direction:=Vector3Normalize(Vector3Sub(Vector3MatrixMul(Matrix,DownZ),Position));
    end else begin
     Position[0]:=0.0;
     Position[1]:=0.0;
     Position[2]:=0.0;
     case Light^.Node of
      -$8000000:begin
       // For default directional light, when no other lights were defined
       Direction:=Light^.Direction;
      end;
      else begin
       Direction:=DownZ;
      end;
     end;
    end;
    LightZFar:=1.0;
    case Light^.Type_ of
     TGLTFOpenGL.TLightDataType.Directional,
     TGLTFOpenGL.TLightDataType.Spot:begin
      case Light^.Type_ of
       TGLTFOpenGL.TLightDataType.Directional:begin
        ShadowMapMatrix:=GetDirectionalLightShadowMapMatrix(Direction,AABB,AABB);
       end;
       TGLTFOpenGL.TLightDataType.Spot:begin
        ShadowMapMatrix:=GetSpotLightShadowMapMatrix(Position,Direction,Light^.Range,Light^.OuterConeAngle,AABB);
       end;
       else begin
        ShadowMapMatrix:=TPasGLTF.TDefaults.IdentityMatrix4x4;
       end;
      end;
      RenderToMultisampledShadowMap(ShadowMapMatrix);
      ResolveMultisampledShadowMap(fParent.fTemporaryShadowMapFrameBufferObjects[1]);
      BlurShadowMap(fParent.fTemporaryShadowMapArraySingleFrameBufferObjects[Light^.ShadowMapIndex]);
     end;
     TGLTFOpenGL.TLightDataType.Point:begin
      for SideIndex:=0 to 5 do begin
       ShadowMapMatrix:=GetPointLightShadowMapMatrix(Position,Light^.Range,AABB,SideIndex);
       RenderToMultisampledShadowMap(ShadowMapMatrix);
       ResolveMultisampledShadowMap(fParent.fTemporaryShadowMapFrameBufferObjects[1]);
       BlurShadowMap(fParent.fTemporaryCubeMapShadowMapArraySingleFrameBufferObjects[(Light^.ShadowMapIndex*6)+SideIndex]);
      end;
      ShadowMapMatrix:=TPasGLTF.TDefaults.IdentityMatrix4x4;
     end;
     else begin
      ShadowMapMatrix:=TPasGLTF.TDefaults.IdentityMatrix4x4;
     end;
    end;
   end else begin
    LightZFar:=1.0;
    ShadowMapMatrix:=TPasGLTF.TDefaults.IdentityMatrix4x4;
   end;
   fLightShadowMapZFarValues[LightIndex]:=LightZFar;
   fLightShadowMapMatrices[LightIndex]:=ShadowMapMatrix;
  end;
 end;
end;

procedure TGLTFOpenGL.TInstance.DrawFinal(const aModelMatrix:TPasGLTF.TMatrix4x4;
                                          const aViewMatrix:TPasGLTF.TMatrix4x4;
                                          const aProjectionMatrix:TPasGLTF.TMatrix4x4;
                                          const aNonSkinnedNormalShadingShader:TShadingShader;
                                          const aNonSkinnedAlphaTestShadingShader:TShadingShader;
                                          const aSkinnedNormalShadingShader:TShadingShader;
                                          const aSkinnedAlphaTestShadingShader:TShadingShader;
                                          const aAlphaModes:TPasGLTF.TMaterial.TAlphaModes=[]);
begin
 glActiveTexture(GL_TEXTURE2);
 glBindTexture(GL_TEXTURE_2D_ARRAY,fParent.fTemporaryShadowMapArrayTexture);
 glActiveTexture(GL_TEXTURE3);
 glBindTexture(GL_TEXTURE_CUBE_MAP_ARRAY,fParent.fTemporaryCubeMapShadowMapArrayTexture);
 glActiveTexture(GL_TEXTURE0);
 Draw(aModelMatrix,
      aViewMatrix,
      aProjectionMatrix,
      aNonSkinnedNormalShadingShader,
      aNonSkinnedAlphaTestShadingShader,
      aSkinnedNormalShadingShader,
      aSkinnedAlphaTestShadingShader,
      aAlphaModes);
 glActiveTexture(GL_TEXTURE2);
 glBindTexture(GL_TEXTURE_2D_ARRAY,0);
 glActiveTexture(GL_TEXTURE3);
 glBindTexture(GL_TEXTURE_CUBE_MAP_ARRAY,0);
 glActiveTexture(GL_TEXTURE0);
end;

procedure TGLTFOpenGL.TInstance.DrawJoints(const aModelMatrix:TPasGLTF.TMatrix4x4;
                                           const aViewMatrix:TPasGLTF.TMatrix4x4;
                                           const aProjectionMatrix:TPasGLTF.TMatrix4x4;
                                           const aSolidColorShader:TSolidColorShader);
const Vector3Origin:TPasGLTF.TVector3=(0.0,0.0,0.0);
var Index,Count:TPasGLTFSizeInt;
    Scene:PScene;
    Joint:TGLTFOpenGL.PJoint;
    Node:TGLTFOpenGL.TInstance.PNode;
    ModelViewProjectionMatrix:TPasGLTF.TMatrix4x4;
begin
 Scene:=GetScene;
 if assigned(Scene) and (length(Parent.fJoints)>0) then begin
  ModelViewProjectionMatrix:=MatrixMul(MatrixMul(aModelMatrix,aViewMatrix),aProjectionMatrix);
  glBindVertexArray(fParent.fJointVertexArrayHandle);
  glBindBuffer(GL_ARRAY_BUFFER,fParent.fJointVertexBufferObjectHandle);
  glDisable(GL_CULL_FACE);
  glDisable(GL_BLEND);
  glDisable(GL_DEPTH_TEST);
  glPointSize(8.0);
  glLineWidth(4.0);
  glUseProgram(aSolidColorShader.ProgramHandle);
  glUniformMatrix4fv(aSolidColorShader.uModelViewProjectionMatrix,1,{$ifdef fpcgl}0{$else}false{$endif},@ModelViewProjectionMatrix);
  begin
   glUniform4f(aSolidColorShader.uColor,0.0,0.0,1.0,1.0);
   Count:=0;
   for Index:=0 to length(Parent.fJoints)-1 do begin
    Joint:=@Parent.fJoints[Index];
    Parent.fJointVertices[Count]:=Vector3MatrixMul(Nodes[Joint^.Node].WorkMatrix,Vector3Origin);
    if Joint^.Parent>=0 then begin
     Joint:=@Parent.fJoints[Joint^.Parent];
    end;
    Parent.fJointVertices[Count+1]:=Vector3MatrixMul(Nodes[Joint^.Node].WorkMatrix,Vector3Origin);
    inc(Count,2);
   end;
   glBufferSubData(GL_ARRAY_BUFFER,0,Count*SizeOf(TVector3),@Parent.fJointVertices[0]);
   glDrawArrays(GL_LINES,0,Count);
  end;
  begin
   glUniform4f(aSolidColorShader.uColor,1.0,0.0,0.0,1.0);
   Count:=0;
   for Index:=0 to length(Parent.fJoints)-1 do begin
    Joint:=@Parent.fJoints[Index];
    Node:=@Nodes[Joint^.Node];
    Parent.fJointVertices[Count]:=Vector3MatrixMul(Node^.WorkMatrix,Vector3Origin);
    inc(Count);
   end;
   glBufferSubData(GL_ARRAY_BUFFER,0,Count*SizeOf(TVector3),@Parent.fJointVertices[0]);
   glDrawArrays(GL_POINTS,0,Count);
  end;
  glUseProgram(0);
  glBindVertexArray(0);
  glBindBuffer(GL_ARRAY_BUFFER,0);
 end;
end;

function TGLTFOpenGL.TInstance.GetJointPoints:TPasGLTF.TVector3DynamicArray;
const Vector3Origin:TPasGLTF.TVector3=(0.0,0.0,0.0);
var Index:TPasGLTFSizeInt;
begin
 SetLength(result,length(Parent.fJoints));
 for Index:=0 to length(Parent.fJoints)-1 do begin
  result[Index]:=Vector3MatrixMul(Nodes[Parent.fJoints[Index].Node].WorkMatrix,Vector3Origin);
 end;
end;

function TGLTFOpenGL.TInstance.GetJointMatrices:TPasGLTF.TMatrix4x4DynamicArray;
var Index:TPasGLTFSizeInt;
begin
 SetLength(result,length(Parent.fJoints));
 for Index:=0 to length(Parent.fJoints)-1 do begin
  result[Index]:=Nodes[Parent.fJoints[Index].Node].WorkMatrix;
 end;
end;

end.


