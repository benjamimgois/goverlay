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
unit PasVulkan.FileFormats.DAE;
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

uses SysUtils,
     Classes,
     Math,
     Generics.Collections,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.XML,
     PasVulkan.Collections;

const dluaNONE=-1;
      dluaXUP=0;
      dluaYUP=1;
      dluaZUP=2;

      dlstCONSTANT=0;
      dlstLAMBERT=1;
      dlstBLINN=2;
      dlstPHONG=3;

      dlltAMBIENT=0;
      dlltDIRECTIONAL=1;
      dllTPOINT=2;
      dlltSPOT=3;

      dlctPERSPECTIVE=0;
      dlctORTHOGRAPHIC=1;

      dlmtTRIANGLES=0;
      dlmtLINESTRIP=1;

      dlMAXTEXCOORDSETS=8;

      dlMAXBLENDWEIGHTS=16;

      dlacdeX=0;
      dlacdeS=dlacdeX;
      dlacdeU=dlacdeX;
      dlacdeR=dlacdeX;
      dlacdeY=1;
      dlacdeT=dlacdeY;
      dlacdeV=dlacdeY;
      dlacdeG=dlacdeY;
      dlacdeZ=2;
      dlacdeP=dlacdeZ;
      dlacdeB=dlacdeZ;
      dlacdeW=3;
      dlacdeQ=dlacdeW;
      dlacdeA=dlacdeW;
      dlacdeANGLE=4;
      dlacdeTIME=5;

type PpvDAEColorOrTexture=^TpvDAEColorOrTexture;
     TpvDAEColorOrTexture=record
      HasColor:boolean;
      HasTexture:boolean;
      Color:TpvVector4;
      Texture:ansistring;
      TexCoord:ansistring;
      OffsetU:TpvFloat;
      OffsetV:TpvFloat;
      RepeatU:TpvFloat;
      RepeatV:TpvFloat;
      WrapU:TpvInt32;
      WrapV:TpvInt32;
     end;

     TpvDAEMaterial=class
      public
       Name:ansistring;
       ShadingType:TpvInt32;
       Ambient:TpvDAEColorOrTexture;
       Diffuse:TpvDAEColorOrTexture;
       Emission:TpvDAEColorOrTexture;
       Specular:TpvDAEColorOrTexture;
       Transparent:TpvDAEColorOrTexture;
       Shininess:TpvFloat;
       Reflectivity:TpvFloat;
       IndexOfRefraction:TpvFloat;
       Transparency:TpvFloat;
       constructor Create;
       destructor Destroy; override;
     end;

     TpvDAEMaterials=class(TList)
      private
       function GetMaterial(const Index:TpvInt32):TpvDAEMaterial;
       procedure SetMaterial(const Index:TpvInt32;Material:TpvDAEMaterial);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:TpvInt32]:TpvDAEMaterial read GetMaterial write SetMaterial; default;
     end;

     PpvDAEVertex=^TpvDAEVertex;
     TpvDAEVertex=record
      Position:TpvVector3;
      Normal:TpvVector3;
      Tangent:TpvVector3;
      Bitangent:TpvVector3;
      TexCoords:array[0..dlMAXTEXCOORDSETS-1] of TpvVector2;
      CountTexCoords:TpvInt32;
      Color:TpvVector3;
      BlendIndices:array[0..dlMAXBLENDWEIGHTS-1] of TpvInt32;
      BlendWeights:array[0..dlMAXBLENDWEIGHTS-1] of TpvFloat;
      CountBlendWeights:TpvInt32;
     end;

     TpvDAEVertices=array of TpvDAEVertex;

     TpvDAEVerticesArray=array of TpvDAEVertices;

     TpvDAEVertexIndex=TpvInt32;

     TpvDAEVertexIndices=array of TpvDAEVertexIndex;

     TpvDAEVertexIndicesArray=array of TpvDAEVertexIndices;

     TpvDAEIndices=array of TpvInt32;

     PpvDAEMeshTexCoordSet=^TpvDAEMeshTexCoordSet;
     TpvDAEMeshTexCoordSet=record
      Semantic:ansistring;
      InputSet:TpvInt32;
     end;

     TpvDAEMeshTexCoordSets=array of TpvDAEMeshTexCoordSet;

     TpvDAEMeshInverseBindMatrices=array of TpvMatrix4x4;

     TpvDAEMeshMorphTargetVertices=array of TpvDAEVertices;

     TpvDAEStringHashMapData=TpvPointer;

     PpvDAEStringHashMapEntity=^TpvDAEStringHashMapEntity;
     TpvDAEStringHashMapEntity=record
      Key:ansistring;
      Value:TpvDAEStringHashMapData;
     end;

     TpvDAEStringHashMapEntities=array of TpvDAEStringHashMapEntity;

     TpvDAEStringHashMapEntityIndices=array of TpvInt32;

     TpvDAEStringHashMap=class
      private
       function FindCell(const Key:ansistring):TpvUInt32;
       procedure Resize;
      protected
       function GetValue(const Key:ansistring):TpvDAEStringHashMapData;
       procedure SetValue(const Key:ansistring;const Value:TpvDAEStringHashMapData);
      public
       RealSize:TpvInt32;
       LogSize:TpvInt32;
       Size:TpvInt32;
       Entities:TpvDAEStringHashMapEntities;
       EntityToCellIndex:TpvDAEStringHashMapEntityIndices;
       CellToEntityIndex:TpvDAEStringHashMapEntityIndices;
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       function Add(const Key:ansistring;Value:TpvDAEStringHashMapData):PpvDAEStringHashMapEntity;
       function Get(const Key:ansistring;CreateIfNotExist:boolean=false):PpvDAEStringHashMapEntity;
       function Delete(const Key:ansistring):boolean;
       property Values[const Key:ansistring]:TpvDAEStringHashMapData read GetValue write SetValue; default;
     end;

     TpvDAEGeometry=class;

     TpvDAEGeometries=class;

     TpvDAENode=class;

     TpvDAEMesh=class
      private
       HasNormals:longbool;
       HasTangents:longbool;
       VertexIndices:TpvDAEVertexIndices;
      public
       ParentGeometry:TpvDAEGeometry;
       MeshType:TpvInt32;
       MaterialIndex:TpvInt32;
       TexCoordSets:TpvDAEMeshTexCoordSets;
       Vertices:TpvDAEVertices;
       Indices:TpvDAEIndices;
       MorphTargetVertices:TpvDAEMeshMorphTargetVertices;
       GeometryIndex:TpvInt32;
       GeometryMeshIndex:TpvInt32;
       constructor Create;
       destructor Destroy; override;
       procedure Optimize;
       procedure CalculateMissingInformations(Normals:boolean=true;Tangents:boolean=true);
       procedure CorrectInformations;
     end;

     TpvDAEGeometryJointNodes=array of TpvDAENode;

     TpvDAEGeometryMorphTargetVertices=array of TpvFloat;

     TpvDAEGeometryMorphTargetWeights=array of TpvFloat;

     TpvDAEGeometry=class(TList)
      private
       function GetMesh(const Index:TpvInt32):TpvDAEMesh;
       procedure SetMesh(const Index:TpvInt32;Mesh:TpvDAEMesh);
       function MorphTargetMatch(const WithGeometry:TpvDAEGeometry):boolean;
      public
       ParentNode:TpvDAENode;
       JointNames:TStringList;
       JointNodes:TpvDAEGeometryJointNodes;
       BindShapeMatrix:TpvMatrix4x4;
       InverseBindMatrices:TpvDAEMeshInverseBindMatrices;
       MorphTargetWeights:TpvDAEGeometryMorphTargetWeights;
       NodeIndex:TpvInt32;
       NodeGeometryIndex:TpvInt32;
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:TpvInt32]:TpvDAEMesh read GetMesh write SetMesh; default;
     end;

     TpvDAEGeometries=class(TList)
      private
       function GetGeometry(const Index:TpvInt32):TpvDAEGeometry;
       procedure SetGeometry(const Index:TpvInt32;Geometry:TpvDAEGeometry);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:TpvInt32]:TpvDAEGeometry read GetGeometry write SetGeometry; default;
     end;

     TpvDAEController=class
      private
      public
       ID:ansistring;
       Name:ansistring;
       constructor Create;
       destructor Destroy; override;
     end;

     TpvDAEControllerSkin=class(TpvDAEController)
      private
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
     end;

     TpvDAEControllerMorph=class(TpvDAEController)
      private
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
     end;

     TpvDAEControllers=class(TList)
      private
       function GetController(const Index:TpvInt32):TpvDAEController;
       procedure SetController(const Index:TpvInt32;Controller:TpvDAEController);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:TpvInt32]:TpvDAEController read GetController write SetController; default;
     end;

     TpvDAETransform=class
      private
      public
       SID:ansistring;
       Matrix:TpvMatrix4x4;
       constructor Create;
       destructor Destroy; override;
       procedure Convert; virtual;
     end;

     TpvDAETransformRotate=class(TpvDAETransform)
      public
       Axis:TpvVector3;
       Angle:TpvFloat;
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Convert; override;
     end;

     TpvDAETransformTranslate=class(TpvDAETransform)
      public
       Offset:TpvVector3;
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Convert; override;
     end;

     TpvDAETransformScale=class(TpvDAETransform)
      public
       Scale:TpvVector3;
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Convert; override;
     end;

     TpvDAETransformMatrix=class(TpvDAETransform)
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Convert; override;
     end;

     TpvDAETransformLookAt=class(TpvDAETransform)
      public
       LookAtOrigin:TpvVector3;
       LookAtDest:TpvVector3;
       LookAtUp:TpvVector3;
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Convert; override;
     end;

     TpvDAETransformSkew=class(TpvDAETransform)
      public
       SkewAngle:TpvFloat;
       SkewA:TpvVector3;
       SkewB:TpvVector3;
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Convert; override;
     end;

     TpvDAETransforms=class(TList)
      private
       function GetTransform(const Index:TpvInt32):TpvDAETransform;
       procedure SetTransform(const Index:TpvInt32;Transform:TpvDAETransform);
      public
       SIDStringHashMap:TpvDAEStringHashMap;
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:TpvInt32]:TpvDAETransform read GetTransform write SetTransform; default;
     end;

     TpvDAECamera=class
      public
       ID:ansistring;
       Name:ansistring;
       Matrix:TpvMatrix4x4;
       ZNear:TpvFloat;
       ZFar:TpvFloat;
       AspectRatio:TpvFloat;
       CameraType:TpvInt32;
       XFov:TpvFloat;
       YFov:TpvFloat;
       XMag:TpvFloat;
       YMag:TpvFloat;
       constructor Create;
       destructor Destroy; override;
     end;

     TpvDAECameras=class(TList)
      private
       function GetCamera(const Index:TpvInt32):TpvDAECamera;
       procedure SetCamera(const Index:TpvInt32;Camera:TpvDAECamera);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:TpvInt32]:TpvDAECamera read GetCamera write SetCamera; default;
     end;

     TpvDAELight=class
      public
       ID:ansistring;
       Name:ansistring;
       LightType:TpvInt32;
       Position:TpvVector3;
       Direction:TpvVector3;
       Color:TpvVector3;
       FallOffAngle:TpvFloat;
       FallOffExponent:TpvFloat;
       ConstantAttenuation:TpvFloat;
       LinearAttenuation:TpvFloat;
       QuadraticAttenuation:TpvFloat;
       constructor Create;
       destructor Destroy; override;
     end;

     TpvDAELightAmbient=class(TpvDAELight);

     TpvDAELightDirectional=class(TpvDAELight);

     TpvDAELightPoint=class(TpvDAELight);

     TpvDAELightSpot=class(TpvDAELight);

     TpvDAELights=class(TList)
      private
       function GetLight(const Index:TpvInt32):TpvDAELight;
       procedure SetLight(const Index:TpvInt32;Light:TpvDAELight);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:TpvInt32]:TpvDAELight read GetLight write SetLight; default;
     end;

     TpvDAENodes=class;

     TpvDAENodeType=
      (
       Node,
       Joint
      );

     TpvDAENode=class
      private
      public
       NodeType:TpvDAENodeType;
       Parent:TpvDAENode;
       Visible:longbool;
       ID:ansistring;
       Name:ansistring;
       SID:ansistring;
       Nodes:TpvDAENodes;
       Cameras:TpvDAECameras;
       Lights:TpvDAELights;
       Controllers:TpvDAEControllers;
       Transforms:TpvDAETransforms;
       Geometries:TpvDAEGeometries;
       Channels:TList;
       Matrix:TpvMatrix4x4;
       constructor Create;
       destructor Destroy; override;
     end;

     TpvDAENodes=class(TList)
      private
       function GetNode(const Index:TpvInt32):TpvDAENode;
       procedure SetNode(const Index:TpvInt32;Node:TpvDAENode);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:TpvInt32]:TpvDAENode read GetNode write SetNode; default;
     end;

     TpvDAEVisualScene=class
      private
      public
       ID:ansistring;
       Name:ansistring;
       Root:TpvDAENode;
       JointNodes:TStringList;
       JointNodeStringHashMap:TpvDAEStringHashMap;
       JointRootNodes:TStringList;
       constructor Create;
       destructor Destroy; override;
     end;

     TpvDAEVisualScenes=class(TList)
      private
       function GetVisualScene(const Index:TpvInt32):TpvDAEVisualScene;
       procedure SetVisualScene(const Index:TpvInt32;VisualScene:TpvDAEVisualScene);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:TpvInt32]:TpvDAEVisualScene read GetVisualScene write SetVisualScene; default;
     end;

     TpvDAEInterpolationType=
      (
       Linear,
       Bezier,
       Cardinal,
       Hermite,
       BSpline,
       Step
      );

     TpvDAEAnimationChannelKeyFrameValues=array of TpvFloat;

     PpvDAEAnimationChannelKeyFrameTangent=^TpvDAEAnimationChannelKeyFrameTangent;
     TpvDAEAnimationChannelKeyFrameTangent=record
      x:TpvFloat;
      y:TpvFloat;
     end;

     TpvDAEAnimationChannelKeyFrame=class
      private
      public
       Interpolation:TpvDAEInterpolationType;
       Time:TpvDouble;
       Values:TpvDAEAnimationChannelKeyFrameValues;
       InTangents:TpvDAEAnimationChannelKeyFrameValues;
       InTangentStride:TpvInt32;
       InTangentParams:TpvInt32;
       OutTangents:TpvDAEAnimationChannelKeyFrameValues;
       OutTangentStride:TpvInt32;
       OutTangentParams:TpvInt32;
       constructor Create;
       destructor Destroy; override;
     end;

     TpvDAEAnimationChannelKeyFrames=class(TList)
      private
       function GetAnimationChannelKeyFrame(const Index:TpvInt32):TpvDAEAnimationChannelKeyFrame;
       procedure SetAnimationChannelKeyFrame(const Index:TpvInt32;AnimationChannelKeyFrame:TpvDAEAnimationChannelKeyFrame);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:TpvInt32]:TpvDAEAnimationChannelKeyFrame read GetAnimationChannelKeyFrame write SetAnimationChannelKeyFrame; default;
     end;

     PpvDAEAnimationChannelLinearKeyFrameValue=^TpvDAEAnimationChannelLinearKeyFrameValue;
     TpvDAEAnimationChannelLinearKeyFrameValue=TpvFloat;

     TpvDAEAnimationChannelLinearKeyFrameValues=array of TpvDAEAnimationChannelLinearKeyFrameValue;

     TpvDAEAnimationChannelLinearKeyFrames=array of TpvDAEAnimationChannelLinearKeyFrameValues;

     TpvDAEAnimationChannel=class
      private
      public
       NodeID:ansistring;
       Node:TpvDAENode;
       ElementID:ansistring;
       DestinationObject:TObject;
       DestinationElement:TpvInt32;
       KeyFrames:TpvDAEAnimationChannelKeyFrames;
       LinearKeyFrames:TpvDAEAnimationChannelLinearKeyFrames;
       CountLinearKeyFrames:TpvInt32;
       CountValues:TpvInt32;
       StartTime:TpvDouble;
       EndTime:TpvDouble;
       TimeStep:TpvDouble;
       constructor Create;
       destructor Destroy; override;
       function GetInterpolatedValue(const Time:TpvDouble;const ValueIndex:TpvInt32):TpvDAEAnimationChannelLinearKeyFrameValue;
       function GetInterpolatedValuesMatrix(const Time:TpvDouble):TpvMatrix4x4;
     end;

     TpvDAEAnimationChannels=class(TList)
      private
       function GetAnimationChannel(const Index:TpvInt32):TpvDAEAnimationChannel;
       procedure SetAnimationChannel(const Index:TpvInt32;AnimationChannel:TpvDAEAnimationChannel);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:TpvInt32]:TpvDAEAnimationChannel read GetAnimationChannel write SetAnimationChannel; default;
     end;

     TpvDAEAnimations=class;

     TpvDAEAnimation=class
      private
      public
       ID:ansistring;
       Name:ansistring;
       Referenced:boolean;
       Channels:TpvDAEAnimationChannels;
       constructor Create;
       destructor Destroy; override;
     end;

     TpvDAEAnimations=class(TList)
      private
       function GetAnimation(const Index:TpvInt32):TpvDAEAnimation;
       procedure SetAnimation(const Index:TpvInt32;Animation:TpvDAEAnimation);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:TpvInt32]:TpvDAEAnimation read GetAnimation write SetAnimation; default;
     end;

     TpvDAEAnimationClip=class
      private
      public
       ID:ansistring;
       Name:ansistring;
       Animations:TList;
       constructor Create;
       destructor Destroy; override;
     end;

     TpvDAEAnimationClips=class(TList)
      private
       function GetAnimationClip(const Index:TpvInt32):TpvDAEAnimationClip;
       procedure SetAnimationClip(const Index:TpvInt32;AnimationClip:TpvDAEAnimationClip);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:TpvInt32]:TpvDAEAnimationClip read GetAnimationClip write SetAnimationClip; default;
     end;

     TpvDAECameraHashMap=TpvStringHashMap<TpvDAECamera>;

     TpvDAECameraList=TObjectList<TpvDAECamera>;

     TpvDAELoader=class
      private
      public
       COLLADAVersion:ansistring;
       AuthoringTool:ansistring;
       Created:TDateTime;
       Modified:TDateTime;
       UnitMeter:double;
       UnitName:ansistring;
       UpAxis:TpvInt32;
       AutomaticCorrect:longbool;
       VisualScenes:TpvDAEVisualScenes;
       CameraHashMap:TpvDAECameraHashMap;
       CameraList:TpvDAECameraList;
       MainVisualScene:TpvDAEVisualScene;
       Animations:TpvDAEAnimations;
       AnimationClips:TpvDAEAnimationClips;
       Materials:TpvDAEMaterials;
       StaticAABB:TpvAABB;
       constructor Create;
       destructor Destroy; override;
       function Load(Stream:TStream):boolean;
     end;

implementation

uses PasDblStrUtils;

function NextPowerOfTwo(i:TpvInt32;MinThreshold:TpvInt32=0):TpvInt32;
begin
 result:=(i or MinThreshold)-1;
 result:=result or (result shr 1);
 result:=result or (result shr 2);
 result:=result or (result shr 4);
 result:=result or (result shr 8);
 result:=result or (result shr 16);
 inc(result);
end;

function CompareBytes(a,b:TpvPointer;Count:TpvInt32):boolean;
var pa,pb:pansichar;
begin
 pa:=a;
 pb:=b;
 result:=true;
 while Count>7 do begin
  if int64(TpvPointer(pa)^)<>int64(TpvPointer(pb)^) then begin
   result:=false;
   exit;
  end;
  inc(pa,8);
  inc(pb,8);
  dec(Count,8);
 end;
 while Count>3 do begin
  if TpvUInt32(TpvPointer(pa)^)<>TpvUInt32(TpvPointer(pb)^) then begin
   result:=false;
   exit;
  end;
  inc(pa,4);
  inc(pb,4);
  dec(Count,4);
 end;
 while Count>1 do begin
  if TpvUInt16(TpvPointer(pa)^)<>TpvUInt16(TpvPointer(pb)^) then begin
   result:=false;
   exit;
  end;
  inc(pa,2);
  inc(pb,2);
  dec(Count,2);
 end;
 while Count>0 do begin
  if pa^<>pb^ then begin
   result:=false;
   exit;
  end;
  inc(pa);
  inc(pb);
  dec(Count);
 end;
end;

function HashBytes(const a:TpvPointer;Count:TpvInt32):TpvUInt32;
{$ifdef cpuarm}
var b:pansichar;
    len,h,i:TpvUInt32;
begin
 result:=2166136261;
 len:=Count;
 h:=len;
 if len>0 then begin
  b:=a;
  while len>3 do begin
   i:=TpvUInt32(TpvPointer(b)^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
   inc(b,4);
   dec(len,4);
  end;
  if len>1 then begin
   i:=TpvUInt16(TpvPointer(b)^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
   inc(b,2);
   dec(len,2);
  end;
  if len>0 then begin
   i:=TpvUInt8(b^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
  end;
 end;
 result:=result xor h;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;
{$else}
{$ifndef fpc}
type qword=int64;
{$endif}
const m=TpvUInt32($57559429);
      n=TpvUInt32($5052acdb);
var b:pansichar;
    h,k,len:TpvUInt32;
    p:{$ifdef fpc}qword{$else}int64{$endif};
begin
 len:=Count;
 h:=len;
 k:=h+n+1;
 if len>0 then begin
  b:=a;
  while len>7 do begin
   begin
    p:=TpvUInt32(TpvPointer(b)^)*qword(n);
    h:=h xor TpvUInt32(p and $ffffffff);
    k:=k xor TpvUInt32(p shr 32);
    inc(b,4);
   end;
   begin
    p:=TpvUInt32(TpvPointer(b)^)*qword(m);
    k:=k xor TpvUInt32(p and $ffffffff);
    h:=h xor TpvUInt32(p shr 32);
    inc(b,4);
   end;
   dec(len,8);
  end;
  if len>3 then begin
   p:=TpvUInt32(TpvPointer(b)^)*qword(n);
   h:=h xor TpvUInt32(p and $ffffffff);
   k:=k xor TpvUInt32(p shr 32);
   inc(b,4);
   dec(len,4);
  end;
  if len>0 then begin
   if len>1 then begin
    p:=TpvUInt16(TpvPointer(b)^);
    inc(b,2);
    dec(len,2);
   end else begin
    p:=0;
   end;
   if len>0 then begin
    p:=p or (TpvUInt8(b^) shl 16);
   end;
   p:=p*qword(m);
   k:=k xor TpvUInt32(p and $ffffffff);
   h:=h xor TpvUInt32(p shr 32);
  end;
 end;
 begin
  p:=(h xor (k+n))*qword(n);
  h:=h xor TpvUInt32(p and $ffffffff);
  k:=k xor TpvUInt32(p shr 32);
 end;
 result:=k xor h;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;
{$endif}

function StrToDouble(s:ansistring;const DefaultValue:double=0.0):double;
var OK:longbool;
begin
 OK:=false;
 if length(s)>0 then begin
  result:=ConvertStringToDouble(s,rmNearest,@OK);
  if not OK then begin
   result:=DefaultValue;
  end;
 end else begin
  result:=DefaultValue;
 end;
end;

function DoubleToStr(v:double):ansistring;
begin
 result:=ConvertDoubleToString(v,omStandard,0);
end;

type TCharSet=set of ansichar;

function GetToken(var InputString:ansistring;const Divider:TCharSet=[#0..#32]):ansistring;
var i:TpvInt32;
begin
 i:=1;
 while (i<=length(InputString)) and (InputString[i] in Divider) do begin
  inc(i);
 end;
 if i>1 then begin
  Delete(InputString,1,i-1);
 end;
 i:=1;
 while (i<=length(InputString)) and not (InputString[i] in Divider) do begin
  inc(i);
 end;
 result:=Copy(InputString,1,i-1);
 Delete(InputString,1,i);
end;

const CELL_EMPTY=-1;
      CELL_DELETED=-2;

      ENT_EMPTY=-1;
      ENT_DELETED=-2;

function HashString(const Str:ansistring):TpvUInt32;
var b:PpvUInt8;
    len,h,i:TpvUInt32;
begin
 result:=2166136261;
 len:=length(Str);
 h:=len;
 if len>0 then begin
  b:=PpvUInt8(pansichar(Str));
  while len>3 do begin
   i:=TpvUInt32(TpvPointer(b)^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
   inc(b,4);
   dec(len,4);
  end;
  if len>1 then begin
   i:=TpvUInt16(TpvPointer(b)^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
   inc(b,2);
   dec(len,2);
  end;
  if len>0 then begin
   i:=TpvUInt8(b^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
  end;
 end;
 result:=result xor h;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;

constructor TpvDAEStringHashMap.Create;
begin
 inherited Create;
 RealSize:=0;
 LogSize:=0;
 Size:=0;
 Entities:=nil;
 EntityToCellIndex:=nil;
 CellToEntityIndex:=nil;
 Resize;
end;

destructor TpvDAEStringHashMap.Destroy;
var Counter:TpvInt32;
begin
 Clear;
 for Counter:=0 to length(Entities)-1 do begin
  Entities[Counter].Key:='';
 end;
 SetLength(Entities,0);
 SetLength(EntityToCellIndex,0);
 SetLength(CellToEntityIndex,0);
 inherited Destroy;
end;

procedure TpvDAEStringHashMap.Clear;
var Counter:TpvInt32;
begin
 for Counter:=0 to length(Entities)-1 do begin
  Entities[Counter].Key:='';
 end;
 RealSize:=0;
 LogSize:=0;
 Size:=0;
 SetLength(Entities,0);
 SetLength(EntityToCellIndex,0);
 SetLength(CellToEntityIndex,0);
 Resize;
end;

function TpvDAEStringHashMap.FindCell(const Key:ansistring):TpvUInt32;
var HashCode,Mask,Step:TpvUInt32;
    Entity:TpvInt32;
begin
 HashCode:=HashString(Key);
 Mask:=(2 shl LogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 if LogSize<>0 then begin
  result:=HashCode shr (32-LogSize);
 end else begin
  result:=0;
 end;
 repeat
  Entity:=CellToEntityIndex[result];
  if (Entity=ENT_EMPTY) or ((Entity<>ENT_DELETED) and (Entities[Entity].Key=Key)) then begin
   exit;
  end;
  result:=(result+Step) and Mask;
 until false;
end;

procedure TpvDAEStringHashMap.Resize;
var NewLogSize,NewSize,Cell,Entity,Counter:TpvInt32;
    OldEntities:TpvDAEStringHashMapEntities;
    OldCellToEntityIndex:TpvDAEStringHashMapEntityIndices;
    OldEntityToCellIndex:TpvDAEStringHashMapEntityIndices;
begin
 NewLogSize:=0;
 NewSize:=RealSize;
 while NewSize<>0 do begin
  NewSize:=NewSize shr 1;
  inc(NewLogSize);
 end;
 if NewLogSize<1 then begin
  NewLogSize:=1;
 end;
 Size:=0;
 RealSize:=0;
 LogSize:=NewLogSize;
 OldEntities:=Entities;
 OldCellToEntityIndex:=CellToEntityIndex;
 OldEntityToCellIndex:=EntityToCellIndex;
 Entities:=nil;
 CellToEntityIndex:=nil;
 EntityToCellIndex:=nil;
 SetLength(Entities,2 shl LogSize);
 SetLength(CellToEntityIndex,2 shl LogSize);
 SetLength(EntityToCellIndex,2 shl LogSize);
 for Counter:=0 to length(CellToEntityIndex)-1 do begin
  CellToEntityIndex[Counter]:=ENT_EMPTY;
 end;
 for Counter:=0 to length(EntityToCellIndex)-1 do begin
  EntityToCellIndex[Counter]:=CELL_EMPTY;
 end;
 for Counter:=0 to length(OldEntityToCellIndex)-1 do begin
  Cell:=OldEntityToCellIndex[Counter];
  if Cell>=0 then begin
   Entity:=OldCellToEntityIndex[Cell];
   if Entity>=0 then begin
    Add(OldEntities[Counter].Key,OldEntities[Counter].Value);
   end;
  end;
 end;
 for Counter:=0 to length(OldEntities)-1 do begin
  OldEntities[Counter].Key:='';
 end;
 SetLength(OldEntities,0);
 SetLength(OldCellToEntityIndex,0);
 SetLength(OldEntityToCellIndex,0);
end;

function TpvDAEStringHashMap.Add(const Key:ansistring;Value:TpvDAEStringHashMapData):PpvDAEStringHashMapEntity;
var Entity:TpvInt32;
    Cell:TpvUInt32;
begin
 result:=nil;
 while RealSize>=(1 shl LogSize) do begin
  Resize;
 end;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=@Entities[Entity];
  result^.Key:=Key;
  result^.Value:=Value;
  exit;
 end;
 Entity:=Size;
 inc(Size);
 if Entity<(2 shl LogSize) then begin
  CellToEntityIndex[Cell]:=Entity;
  EntityToCellIndex[Entity]:=Cell;
  inc(RealSize);
  result:=@Entities[Entity];
  result^.Key:=Key;
  result^.Value:=Value;
 end;
end;

function TpvDAEStringHashMap.Get(const Key:ansistring;CreateIfNotExist:boolean=false):PpvDAEStringHashMapEntity;
var Entity:TpvInt32;
    Cell:TpvUInt32;
begin
 result:=nil;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=@Entities[Entity];
 end else if CreateIfNotExist then begin
  result:=Add(Key,nil);
 end;
end;

function TpvDAEStringHashMap.Delete(const Key:ansistring):boolean;
var Entity:TpvInt32;
    Cell:TpvUInt32;
begin
 result:=false;
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  Entities[Entity].Key:='';
  Entities[Entity].Value:=nil;
  EntityToCellIndex[Entity]:=CELL_DELETED;
  CellToEntityIndex[Cell]:=ENT_DELETED;
  result:=true;
 end;
end;

function TpvDAEStringHashMap.GetValue(const Key:ansistring):TpvDAEStringHashMapData;
var Entity:TpvInt32;
    Cell:TpvUInt32;
begin
 Cell:=FindCell(Key);
 Entity:=CellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=Entities[Entity].Value;
 end else begin
  result:=nil;
 end;
end;

procedure TpvDAEStringHashMap.SetValue(const Key:ansistring;const Value:TpvDAEStringHashMapData);
begin
 Add(Key,Value);
end;

constructor TpvDAEMaterial.Create;
begin
 inherited Create;
 Name:='';
 ShadingType:=0;
 FillChar(Ambient,SizeOf(TpvDAEColorOrTexture),AnsiChar(#0));
 FillChar(Diffuse,SizeOf(TpvDAEColorOrTexture),AnsiChar(#0));
 FillChar(Emission,SizeOf(TpvDAEColorOrTexture),AnsiChar(#0));
 FillChar(Specular,SizeOf(TpvDAEColorOrTexture),AnsiChar(#0));
 FillChar(Transparent,SizeOf(TpvDAEColorOrTexture),AnsiChar(#0));
 Shininess:=0.0;
 Reflectivity:=0.0;
 IndexOfRefraction:=0.0;
 Transparency:=0.0;
end;

destructor TpvDAEMaterial.Destroy;
begin
 Name:='';
 inherited Destroy;
end;

constructor TpvDAEMaterials.Create;
begin
 inherited Create;
end;

destructor TpvDAEMaterials.Destroy;
var i:TpvInt32;
    Material:TpvDAEMaterial;
begin
 for i:=0 to Count-1 do begin
  Material:=Items[i];
  Material.Free;
  Items[i]:=nil;
 end;
 inherited Destroy;
end;

procedure TpvDAEMaterials.Clear;
var i:TpvInt32;
    Material:TpvDAEMaterial;
begin
 for i:=0 to Count-1 do begin
  Material:=Items[i];
  Material.Free;
  Items[i]:=nil;
 end;
 inherited Clear;
end;

function TpvDAEMaterials.GetMaterial(const Index:TpvInt32):TpvDAEMaterial;
begin
 result:=inherited Items[Index];
end;

procedure TpvDAEMaterials.SetMaterial(const Index:TpvInt32;Material:TpvDAEMaterial);
begin
 inherited Items[Index]:=Material;
end;

constructor TpvDAEMesh.Create;
begin
 inherited Create;
 ParentGeometry:=nil;
 MeshType:=dlmtTRIANGLES;
 Vertices:=nil;
 Indices:=nil;
 TexCoordSets:=nil;
 VertexIndices:=nil;
 MorphTargetVertices:=nil;
end;

destructor TpvDAEMesh.Destroy;
begin
 SetLength(Vertices,0);
 SetLength(Indices,0);
 SetLength(TexCoordSets,0);
 SetLength(VertexIndices,0);
 SetLength(MorphTargetVertices,0);
 inherited Destroy;
end;

procedure TpvDAEMesh.Optimize;
const HashBits=16;
      HashSize=1 shl HashBits;
      HashMask=HashSize-1;
type PHashTableItem=^THashTableItem;
     THashTableItem=record
      Next:PHashTableItem;
      Hash:TpvUInt32;
      VertexIndex:TpvInt32;
     end;
     PHashTable=^THashTable;
     THashTable=array[0..HashSize-1] of PHashTableItem;
 function HashVector(const v:TpvDAEVertex):TpvUInt32;
 begin
  result:=((round(v.Position.x)*73856093) xor (round(v.Position.y)*19349663) xor (round(v.Position.z)*83492791));
 end;
var NewVertices:TpvDAEVertices;
    NewIndices:TpvDAEIndices;
    NewVerticesCount,NewIndicesCount,IndicesIndex,VertexIndex,VertexCounter,FoundVertexIndex,TexCoordSetIndex,
    BlendWeightIndex,Index:TpvInt32;
    OK:boolean;
    HashTable:PHashTable;
    HashTableItem,NextHashTableItem:PHashTableItem;
    Hash:TpvUInt32;
begin
 NewVertices:=nil;
 NewIndices:=nil;
 HashTable:=nil;
 try
  GetMem(HashTable,SizeOf(THashTable));
  FillChar(HashTable^,SizeOf(THashTable),AnsiChar(#0));
  NewVerticesCount:=0;
  NewIndicesCount:=0;
  SetLength(NewVertices,length(Vertices));
  SetLength(NewIndices,length(Indices));
  for IndicesIndex:=0 to length(Indices)-1 do begin
   VertexIndex:=Indices[IndicesIndex];
   FoundVertexIndex:=-1;
   Hash:=HashVector(Vertices[VertexIndex]);
   HashTableItem:=HashTable[Hash and HashMask];
   while assigned(HashTableItem) do begin
    if HashTableItem^.Hash=Hash then begin
     VertexCounter:=HashTableItem^.VertexIndex;
     if SameValue(Vertices[VertexIndex].Position.x,NewVertices[VertexCounter].Position.x) and
        SameValue(Vertices[VertexIndex].Position.y,NewVertices[VertexCounter].Position.y) and
        SameValue(Vertices[VertexIndex].Position.z,NewVertices[VertexCounter].Position.z) and
        SameValue(Vertices[VertexIndex].Normal.x,NewVertices[VertexCounter].Normal.x) and
        SameValue(Vertices[VertexIndex].Normal.y,NewVertices[VertexCounter].Normal.y) and
        SameValue(Vertices[VertexIndex].Normal.z,NewVertices[VertexCounter].Normal.z) and
        SameValue(Vertices[VertexIndex].Tangent.x,NewVertices[VertexCounter].Tangent.x) and
        SameValue(Vertices[VertexIndex].Tangent.y,NewVertices[VertexCounter].Tangent.y) and
        SameValue(Vertices[VertexIndex].Tangent.z,NewVertices[VertexCounter].Tangent.z) and
        SameValue(Vertices[VertexIndex].Bitangent.x,NewVertices[VertexCounter].Bitangent.x) and
        SameValue(Vertices[VertexIndex].Bitangent.y,NewVertices[VertexCounter].Bitangent.y) and
        SameValue(Vertices[VertexIndex].Bitangent.z,NewVertices[VertexCounter].Bitangent.z) and
        SameValue(Vertices[VertexIndex].Color.r,NewVertices[VertexCounter].Color.r) and
        SameValue(Vertices[VertexIndex].Color.g,NewVertices[VertexCounter].Color.g) and
        SameValue(Vertices[VertexIndex].Color.b,NewVertices[VertexCounter].Color.b) then begin
      OK:=true;
      for TexCoordSetIndex:=0 to Max(Min(Vertices[VertexIndex].CountTexCoords,dlMAXTEXCOORDSETS),0)-1 do begin
       if (not SameValue(Vertices[VertexIndex].TexCoords[TexCoordSetIndex].x,NewVertices[VertexCounter].TexCoords[TexCoordSetIndex].x)) or
          (not SameValue(Vertices[VertexIndex].TexCoords[TexCoordSetIndex].y,NewVertices[VertexCounter].TexCoords[TexCoordSetIndex].y)) then begin
        OK:=false;
        break;
       end;
      end;
      if OK then begin
       for BlendWeightIndex:=0 to Max(Min(Vertices[VertexIndex].CountBlendWeights,dlMAXBLENDWEIGHTS),0)-1 do begin
        if (Vertices[VertexIndex].BlendIndices[BlendWeightIndex]<>NewVertices[VertexCounter].BlendIndices[BlendWeightIndex]) or
           (not SameValue(Vertices[VertexIndex].BlendWeights[BlendWeightIndex],NewVertices[VertexCounter].BlendWeights[BlendWeightIndex])) then begin
         OK:=false;
         break;
        end;
       end;
       if OK then begin
        FoundVertexIndex:=VertexCounter;
        break;
       end;
      end;
     end;
    end;
    HashTableItem:=HashTableItem^.Next;
   end;
   if FoundVertexIndex<0 then begin
    GetMem(HashTableItem,SizeOf(THashTableItem));
    HashTableItem^.Next:=HashTable[Hash and HashMask];
    HashTable[Hash and HashMask]:=HashTableItem;
    HashTableItem^.Hash:=Hash;
    HashTableItem^.VertexIndex:=NewVerticesCount;
    FoundVertexIndex:=NewVerticesCount;
    NewVertices[NewVerticesCount]:=Vertices[VertexIndex];
    inc(NewVerticesCount);
   end;
   NewIndices[NewIndicesCount]:=FoundVertexIndex;
   inc(NewIndicesCount);
  end;
  SetLength(NewVertices,NewVerticesCount);
  SetLength(NewIndices,NewIndicesCount);
  SetLength(Vertices,0);
  SetLength(Indices,0);
  Vertices:=NewVertices;
  Indices:=NewIndices;
  NewVertices:=nil;
  NewIndices:=nil;
 finally
  SetLength(NewVertices,0);
  SetLength(NewIndices,0);
  for Index:=low(THashTable) to high(THashTable) do begin
   HashTableItem:=HashTable[Index];
   HashTable[Index]:=nil;
   while assigned(HashTableItem) do begin
    NextHashTableItem:=HashTableItem^.Next;
    FreeMem(HashTableItem);
    HashTableItem:=NextHashTableItem;
   end;
  end;
  FreeMem(HashTable);
 end;
end;

procedure TpvDAEMesh.CalculateMissingInformations(Normals:boolean=true;Tangents:boolean=true);
const f1d3=1.0/3.0;
var IndicesIndex,CountIndices,VertexIndex,CountVertices,CountTriangles,Counter:TpvInt32;
    v0,v1,v2:PpvDAEVertex;
    VerticesCounts:array of TpvInt32;
    VerticesNormals,VerticesTangents,VerticesBitangents:array of TpvVector3;
    TriangleNormal,TriangleTangent,TriangleBitangent,Normal:TpvVector3;
begin
 VerticesCounts:=nil;
 VerticesNormals:=nil;
 VerticesTangents:=nil;
 VerticesBitangents:=nil;
 try
  if Normals or Tangents then begin
   case MeshType of
    dlmtTRIANGLES:begin
     CountIndices:=length(Indices);
     CountTriangles:=length(Indices) div 3;
     if CountTriangles>0 then begin
      CountVertices:=length(Vertices);
      SetLength(VerticesCounts,CountVertices);
      SetLength(VerticesNormals,CountVertices);
      SetLength(VerticesTangents,CountVertices);
      SetLength(VerticesBitangents,CountVertices);
      for VertexIndex:=0 to CountVertices-1 do begin
       VerticesCounts[VertexIndex]:=0;
       VerticesNormals[VertexIndex]:=0;
       VerticesTangents[VertexIndex]:=0;
       VerticesBitangents[VertexIndex]:=0;
      end;
      IndicesIndex:=0;
      while (IndicesIndex+2)<CountIndices do begin
       v0:=@Vertices[Indices[IndicesIndex+0]];
       v1:=@Vertices[Indices[IndicesIndex+1]];
       v2:=@Vertices[Indices[IndicesIndex+2]];
       TriangleNormal:=((v2^.Position-v0^.Position).Cross(v1^.Position-v0^.Position)).Normalize;
       if not Normals then begin
        Normal:=(v0^.Normal+v1^.Normal+v2^.Normal)/3.0;
        if TriangleNormal.Dot(Normal)<0.0 then begin
         TriangleNormal:=-TriangleNormal;
        end;
       end;
       TriangleTangent:=((v2^.Position-v0^.Position)*(v1^.TexCoords[0].v-v0^.TexCoords[0].v))-((v1^.Position-v0^.Position)*(v2^.TexCoords[0].v-v0^.TexCoords[0].v));
       TriangleBitangent:=((v2^.Position-v0^.Position)*(v1^.TexCoords[0].u-v0^.TexCoords[0].u))-((v1^.Position-v0^.Position)*(v2^.TexCoords[0].u-v0^.TexCoords[0].u));
       TriangleTangent:=(TriangleTangent-(TriangleNormal*TriangleTangent.Dot(TriangleNormal))).Normalize;
       TriangleBitangent:=(TriangleBitangent-(TriangleNormal*TriangleBitangent.Dot(TriangleNormal))).Normalize;
       if (TriangleBitangent.Cross(TriangleTangent)).Dot(TriangleNormal)<0.0 then begin
        TriangleTangent:=-TriangleTangent;
        TriangleBitangent:=-TriangleBitangent;
       end;
       RobustOrthonormalize(TriangleTangent,TriangleBitangent,TriangleNormal);
       for Counter:=0 to 2 do begin
        VertexIndex:=Indices[IndicesIndex+Counter];
        inc(VerticesCounts[VertexIndex]);
        VerticesNormals[VertexIndex]:=VerticesNormals[VertexIndex]+TriangleNormal;
        VerticesTangents[VertexIndex]:=VerticesTangents[VertexIndex]+TriangleTangent;
        VerticesBitangents[VertexIndex]:=VerticesBitangents[VertexIndex]+TriangleBitangent;
       end;
       inc(IndicesIndex,3);
      end;
      for VertexIndex:=0 to CountVertices-1 do begin
       v0:=@Vertices[VertexIndex];
       if Normals then begin
        v0^.Normal:=VerticesNormals[VertexIndex].Normalize;
       end;
       if Tangents then begin
        v0^.Tangent:=VerticesTangents[VertexIndex].Normalize;
        v0^.Bitangent:=VerticesBitangents[VertexIndex].Normalize;
       end;
      end;
     end;
    end;
   end;
  end;
 finally
  SetLength(VerticesCounts,0);
  SetLength(VerticesNormals,0);
  SetLength(VerticesTangents,0);
  SetLength(VerticesBitangents,0);
 end;
end;

procedure TpvDAEMesh.CorrectInformations;
var VertexIndex:TpvInt32;
    Vertex:PpvDAEVertex;
begin
 for VertexIndex:=0 to length(Vertices)-1 do begin
  Vertex:=@Vertices[VertexIndex];
  RobustOrthonormalize(Vertex^.Normal,Vertex^.Tangent,Vertex^.Bitangent);
 end;
end;

constructor TpvDAEGeometry.Create;
begin
 inherited Create;
 ParentNode:=nil;
 JointNames:=TStringList.Create;
 JointNodes:=nil;
 BindShapeMatrix:=TpvMatrix4x4.Identity;
 InverseBindMatrices:=nil;
 MorphTargetWeights:=nil;
end;

destructor TpvDAEGeometry.Destroy;
var i:TpvInt32;
    Mesh:TpvDAEMesh;
begin
 JointNames.Free;
 SetLength(JointNodes,0);
 SetLength(InverseBindMatrices,0);
 SetLength(MorphTargetWeights,0);
 for i:=0 to Count-1 do begin
  Mesh:=Items[i];
  Mesh.Free;
  Items[i]:=nil;
 end;
 inherited Destroy;
end;

procedure TpvDAEGeometry.Clear;
var i:TpvInt32;
    Mesh:TpvDAEMesh;
begin
 for i:=0 to Count-1 do begin
  Mesh:=Items[i];
  Mesh.Free;
  Items[i]:=nil;
 end;
 inherited Clear;
end;

function TpvDAEGeometry.GetMesh(const Index:TpvInt32):TpvDAEMesh;
begin
 result:=inherited Items[Index];
end;

procedure TpvDAEGeometry.SetMesh(const Index:TpvInt32;Mesh:TpvDAEMesh);
begin
 inherited Items[Index]:=Mesh;
end;

function TpvDAEGeometry.MorphTargetMatch(const WithGeometry:TpvDAEGeometry):boolean;
var MeshIndex,IndexArrayIndex:TpvInt32;
    Mesh,WithMesh:TpvDAEMesh;
begin
 result:=Count=WithGeometry.Count;
 if result then begin
  for MeshIndex:=0 to Count-1 do begin
   Mesh:=GetMesh(MeshIndex);
   WithMesh:=WithGeometry.GetMesh(MeshIndex);
   if length(Mesh.Vertices)=length(WithMesh.Vertices) then begin
    if length(Mesh.Indices)=length(WithMesh.Indices) then begin
     for IndexArrayIndex:=0 to length(Mesh.Indices)-1 do begin
      if Mesh.Indices[IndexArrayIndex]<>WithMesh.Indices[IndexArrayIndex] then begin
       result:=false;
       exit;
      end;
     end;
    end else begin
     result:=false;
     exit;
    end;
   end else begin
    result:=false;
    exit;
   end;
  end;
 end;
end;

constructor TpvDAEGeometries.Create;
begin
 inherited Create;
end;

destructor TpvDAEGeometries.Destroy;
var i:TpvInt32;
    Geometry:TpvDAEGeometry;
begin
 for i:=0 to Count-1 do begin
  Geometry:=Items[i];
  Geometry.Free;
  Items[i]:=nil;
 end;
 inherited Destroy;
end;

procedure TpvDAEGeometries.Clear;
var i:TpvInt32;
    Geometry:TpvDAEGeometry;
begin
 for i:=0 to Count-1 do begin
  Geometry:=Items[i];
  Geometry.Free;
  Items[i]:=nil;
 end;
 inherited Clear;
end;

function TpvDAEGeometries.GetGeometry(const Index:TpvInt32):TpvDAEGeometry;
begin
 result:=inherited Items[Index];
end;

procedure TpvDAEGeometries.SetGeometry(const Index:TpvInt32;Geometry:TpvDAEGeometry);
begin
 inherited Items[Index]:=Geometry;
end;

constructor TpvDAEController.Create;
begin
 inherited Create;
 ID:='';
 Name:='';
end;

destructor TpvDAEController.Destroy;
begin
 ID:='';
 Name:='';
 inherited Destroy;
end;

constructor TpvDAEControllerSkin.Create;
begin
 inherited Create;
end;

destructor TpvDAEControllerSkin.Destroy;
begin
 inherited Destroy;
end;

constructor TpvDAEControllerMorph.Create;
begin
 inherited Create;
end;

destructor TpvDAEControllerMorph.Destroy;
begin
 inherited Destroy;
end;

constructor TpvDAEControllers.Create;
begin
 inherited Create;
end;

destructor TpvDAEControllers.Destroy;
var i:TpvInt32;
    Controller:TpvDAEController;
begin
 for i:=0 to Count-1 do begin
  Controller:=Items[i];
  Controller.Free;
  Items[i]:=nil;
 end;
 inherited Destroy;
end;

procedure TpvDAEControllers.Clear;
var i:TpvInt32;
    Controller:TpvDAEController;
begin
 for i:=0 to Count-1 do begin
  Controller:=Items[i];
  Controller.Free;
  Items[i]:=nil;
 end;
 inherited Clear;
end;

function TpvDAEControllers.GetController(const Index:TpvInt32):TpvDAEController;
begin
 result:=inherited Items[Index];
end;

procedure TpvDAEControllers.SetController(const Index:TpvInt32;Controller:TpvDAEController);
begin
 inherited Items[Index]:=Controller;
end;

constructor TpvDAETransform.Create;
begin
 inherited Create;
 SID:='';
 Matrix:=TpvMatrix4x4.Identity;
end;

destructor TpvDAETransform.Destroy;
begin
 SID:='';
 inherited Destroy;
end;

procedure TpvDAETransform.Convert;
begin
end;

constructor TpvDAETransformRotate.Create;
begin
 inherited Create;
 Axis:=0;
 Angle:=0.0;
end;

destructor TpvDAETransformRotate.Destroy;
begin
 inherited Destroy;
end;

procedure TpvDAETransformRotate.Convert;
begin
 Matrix:=TpvMatrix4x4.CreateRotate(Angle*DEG2RAD,Axis);
end;

constructor TpvDAETransformTranslate.Create;
begin
 inherited Create;
 Offset:=0;
end;

destructor TpvDAETransformTranslate.Destroy;
begin
 inherited Destroy;
end;

procedure TpvDAETransformTranslate.Convert;
begin
 Matrix:=TpvMatrix4x4.CreateTranslation(Offset);
end;

constructor TpvDAETransformScale.Create;
begin
 inherited Create;
 Scale:=0;
end;

destructor TpvDAETransformScale.Destroy;
begin
 inherited Destroy;
end;

procedure TpvDAETransformScale.Convert;
begin
 Matrix:=TpvMatrix4x4.CreateScale(Scale);
end;

constructor TpvDAETransformMatrix.Create;
begin
 inherited Create;
end;

destructor TpvDAETransformMatrix.Destroy;
begin
 inherited Destroy;
end;

procedure TpvDAETransformMatrix.Convert;
begin
end;

constructor TpvDAETransformLookAt.Create;
begin
 inherited Create;
 LookAtOrigin:=0;
 LookAtDest:=0;
 LookAtUp:=0;
end;

destructor TpvDAETransformLookAt.Destroy;
begin
 inherited Destroy;
end;

procedure TpvDAETransformLookAt.Convert;
var LookAtDirection,LookAtRight:TpvVector3;
begin
 LookAtUp:=LookAtUp.Normalize;
 LookAtDirection:=(LookAtDest-LookAtOrigin).Normalize;
 LookAtRight:=(LookAtDirection.Cross(LookAtUp)).Normalize;
 Matrix[0,0]:=LookAtRight.x;
 Matrix[0,1]:=LookAtUp.x;
 Matrix[0,2]:=-LookAtDirection.x;
 Matrix[0,3]:=LookAtOrigin.x;
 Matrix[1,0]:=LookAtRight.y;
 Matrix[1,1]:=LookAtUp.y;
 Matrix[1,2]:=-LookAtDirection.y;
 Matrix[1,3]:=LookAtOrigin.y;
 Matrix[1,0]:=LookAtRight.z;
 Matrix[2,1]:=LookAtUp.z;
 Matrix[2,2]:=-LookAtDirection.z;
 Matrix[2,3]:=LookAtOrigin.z;
 Matrix[3,0]:=0.0;
 Matrix[3,1]:=0.0;
 Matrix[3,2]:=0.0;
 Matrix[3,3]:=1.0;
end;

constructor TpvDAETransformSkew.Create;
begin
 inherited Create;
 SkewAngle:=0.0;
 SkewA:=0;
 SkewB:=0;
end;

destructor TpvDAETransformSkew.Destroy;
begin
 inherited Destroy;
end;

procedure TpvDAETransformSkew.Convert;
var SkewN1,SkewN2,SkewA1,SkewA2:TpvVector3;
    SkewAN1,SkewAN2,SkewRX,SkewRY,SkewAlpha:TpvFloat;
begin
 SkewN2:=SkewB.Normalize;
 SkewA1:=SkewN2*SkewA.Dot(SkewN2);
 SkewA2:=SkewA-SkewA1;
 SkewN1:=SkewA2.Normalize;
 SkewAN1:=SkewA.Dot(SkewN1);
 SkewAN2:=SkewA.Dot(SkewN2);
 SkewRX:=(SkewAN1*cos(SkewAngle*DEG2RAD))-(SkewAN2*sin(SkewAngle*DEG2RAD));
 SkewRY:=(SkewAN1*sin(SkewAngle*DEG2RAD))+(SkewAN2*cos(SkewAngle*DEG2RAD));
 if SkewRX>EPSILON then begin
  if SkewAN1<EPSILON then begin
   SkewAlpha:=0.0;
  end else begin
   SkewAlpha:=(SkewRY/SkewRX)-(SkewAN2/SkewAN1);
  end;
  Matrix[0,0]:=(SkewN1.x*SkewN2.x*SkewAlpha)+1.0;
  Matrix[0,1]:=SkewN1.y*SkewN2.x*SkewAlpha;
  Matrix[0,2]:=SkewN1.z*SkewN2.x*SkewAlpha;
  Matrix[0,3]:=0.0;
  Matrix[1,0]:=SkewN1.x*SkewN2.y*SkewAlpha;
  Matrix[1,1]:=(SkewN1.y*SkewN2.y*SkewAlpha)+1.0;
  Matrix[1,2]:=SkewN1.z*SkewN2.y*SkewAlpha;
  Matrix[1,3]:=0.0;
  Matrix[2,0]:=SkewN1.x*SkewN2.z*SkewAlpha;
  Matrix[2,1]:=SkewN1.y*SkewN2.z*SkewAlpha;
  Matrix[2,2]:=(SkewN1.z*SkewN2.z*SkewAlpha)+1.0;
  Matrix[2,3]:=0.0;
  Matrix[2,3]:=0.0;
  Matrix[3,0]:=0.0;
  Matrix[3,1]:=0.0;
  Matrix[3,2]:=0.0;
  Matrix[3,3]:=1.0;
 end else begin
  Matrix:=TpvMatrix4x4.Identity;
 end;
end;

constructor TpvDAETransforms.Create;
begin
 inherited Create;
 SIDStringHashMap:=TpvDAEStringHashMap.Create;
end;

destructor TpvDAETransforms.Destroy;
var i:TpvInt32;
    Transform:TpvDAETransform;
begin
 for i:=0 to Count-1 do begin
  Transform:=Items[i];
  Transform.Free;
  Items[i]:=nil;
 end;
 SIDStringHashMap.Free;
 inherited Destroy;
end;

procedure TpvDAETransforms.Clear;
var i:TpvInt32;
    Transform:TpvDAETransform;
begin
 for i:=0 to Count-1 do begin
  Transform:=Items[i];
  Transform.Free;
  Items[i]:=nil;
 end;
 inherited Clear;
end;

function TpvDAETransforms.GetTransform(const Index:TpvInt32):TpvDAETransform;
begin
 result:=inherited Items[Index];
end;

procedure TpvDAETransforms.SetTransform(const Index:TpvInt32;Transform:TpvDAETransform);
begin
 inherited Items[Index]:=Transform;
end;

constructor TpvDAECamera.Create;
begin
 inherited Create;
 ID:='';
 Name:='';
 Matrix:=TpvMatrix4x4.Identity;
 ZNear:=0.0;
 ZFar:=0.0;
 AspectRatio:=0.0;
 CameraType:=0;
 XFov:=0.0;
 YFov:=0.0;
 XMag:=0.0;
 YMag:=0.0;
end;

destructor TpvDAECamera.Destroy;
begin
 ID:='';
 Name:='';
 inherited Destroy;
end;

constructor TpvDAECameras.Create;
begin
 inherited Create;
end;

destructor TpvDAECameras.Destroy;
var i:TpvInt32;
    Camera:TpvDAECamera;
begin
 for i:=0 to Count-1 do begin
  Camera:=Items[i];
  Camera.Free;
  Items[i]:=nil;
 end;
 inherited Destroy;
end;

procedure TpvDAECameras.Clear;
var i:TpvInt32;
    Camera:TpvDAECamera;
begin
 for i:=0 to Count-1 do begin
  Camera:=Items[i];
  Camera.Free;
  Items[i]:=nil;
 end;
 inherited Clear;
end;

function TpvDAECameras.GetCamera(const Index:TpvInt32):TpvDAECamera;
begin
 result:=inherited Items[Index];
end;

procedure TpvDAECameras.SetCamera(const Index:TpvInt32;Camera:TpvDAECamera);
begin
 inherited Items[Index]:=Camera;
end;

constructor TpvDAELight.Create;
begin
 inherited Create;
 ID:='';
 Name:='';
 LightType:=0;
 Position:=0;
 Direction:=0;
 Color:=0;
 FallOffAngle:=0.0;
 FallOffExponent:=0.0;
 ConstantAttenuation:=0.0;
 LinearAttenuation:=0.0;
 QuadraticAttenuation:=0.0;
end;

destructor TpvDAELight.Destroy;
begin
 ID:='';
 Name:='';
 inherited Destroy;
end;

constructor TpvDAELights.Create;
begin
 inherited Create;
end;

destructor TpvDAELights.Destroy;
var i:TpvInt32;
    Light:TpvDAELight;
begin
 for i:=0 to Count-1 do begin
  Light:=Items[i];
  Light.Free;
  Items[i]:=nil;
 end;
 inherited Destroy;
end;

procedure TpvDAELights.Clear;
var i:TpvInt32;
    Light:TpvDAELight;
begin
 for i:=0 to Count-1 do begin
  Light:=Items[i];
  Light.Free;
  Items[i]:=nil;
 end;
 inherited Clear;
end;

function TpvDAELights.GetLight(const Index:TpvInt32):TpvDAELight;
begin
 result:=inherited Items[Index];
end;

procedure TpvDAELights.SetLight(const Index:TpvInt32;Light:TpvDAELight);
begin
 inherited Items[Index]:=Light;
end;

constructor TpvDAENode.Create;
begin
 inherited Create;
 NodeType:=TpvDAENodeType.Node;
 Parent:=nil;
 Visible:=true;
 ID:='';
 Name:='';
 SID:='';
 Nodes:=TpvDAENodes.Create;
 Cameras:=TpvDAECameras.Create;
 Lights:=TpvDAELights.Create;
 Controllers:=TpvDAEControllers.Create;
 Transforms:=TpvDAETransforms.Create;
 Geometries:=TpvDAEGeometries.Create;
 Channels:=TList.Create;
 Matrix:=TpvMatrix4x4.Identity;
end;

destructor TpvDAENode.Destroy;
begin
 Nodes.Free;
 Cameras.Free;
 Lights.Free;
 Controllers.Free;
 Transforms.Free;
 Geometries.Free;
 Channels.Free;
 ID:='';
 Name:='';
 SID:='';
 inherited Destroy;
end;

constructor TpvDAENodes.Create;
begin
 inherited Create;
end;

destructor TpvDAENodes.Destroy;
var i:TpvInt32;
    Node:TpvDAENode;
begin
 for i:=0 to Count-1 do begin
  Node:=Items[i];
  Node.Free;
  Items[i]:=nil;
 end;
 inherited Destroy;
end;

procedure TpvDAENodes.Clear;
var i:TpvInt32;
    Node:TpvDAENode;
begin
 for i:=0 to Count-1 do begin
  Node:=Items[i];
  Node.Free;
  Items[i]:=nil;
 end;
 inherited Clear;
end;

function TpvDAENodes.GetNode(const Index:TpvInt32):TpvDAENode;
begin
 result:=inherited Items[Index];
end;

procedure TpvDAENodes.SetNode(const Index:TpvInt32;Node:TpvDAENode);
begin
 inherited Items[Index]:=Node;
end;

constructor TpvDAEVisualScene.Create;
begin
 inherited Create;
 ID:='';
 Name:='';
 Root:=TpvDAENode.Create;
 JointNodes:=TStringList.Create;
 JointNodeStringHashMap:=TpvDAEStringHashMap.Create;
 JointRootNodes:=TStringList.Create;
end;

destructor TpvDAEVisualScene.Destroy;
begin
 Root.Free;
 JointNodes.Free;
 JointNodeStringHashMap.Free;
 JointRootNodes.Free;
 ID:='';
 Name:='';
 inherited Destroy;
end;

constructor TpvDAEVisualScenes.Create;
begin
 inherited Create;
end;

destructor TpvDAEVisualScenes.Destroy;
var i:TpvInt32;
    VisualScene:TpvDAEVisualScene;
begin
 for i:=0 to Count-1 do begin
  VisualScene:=Items[i];
  VisualScene.Free;
  Items[i]:=nil;
 end;
 inherited Destroy;
end;

procedure TpvDAEVisualScenes.Clear;
var i:TpvInt32;
    VisualScene:TpvDAEVisualScene;
begin
 for i:=0 to Count-1 do begin
  VisualScene:=Items[i];
  VisualScene.Free;
  Items[i]:=nil;
 end;
 inherited Clear;
end;

function TpvDAEVisualScenes.GetVisualScene(const Index:TpvInt32):TpvDAEVisualScene;
begin
 result:=inherited Items[Index];
end;

procedure TpvDAEVisualScenes.SetVisualScene(const Index:TpvInt32;VisualScene:TpvDAEVisualScene);
begin
 inherited Items[Index]:=VisualScene;
end;

constructor TpvDAEAnimationChannelKeyFrame.Create;
begin
 inherited Create;
 Interpolation:=TpvDAEInterpolationType.Linear;
 Time:=0;
 Values:=nil;
 InTangents:=nil;
 InTangentStride:=0;
 InTangentParams:=0;
 OutTangents:=nil;
 OutTangentStride:=0;
 OutTangentParams:=0;
end;

destructor TpvDAEAnimationChannelKeyFrame.Destroy;
begin
 SetLength(Values,0);
 SetLength(InTangents,0);
 SetLength(OutTangents,0);
 inherited Destroy;
end;

constructor TpvDAEAnimationChannelKeyFrames.Create;
begin
 inherited Create;
end;

destructor TpvDAEAnimationChannelKeyFrames.Destroy;
var i:TpvInt32;
    AnimationChannelKeyFrame:TpvDAEAnimationChannelKeyFrame;
begin
 for i:=0 to Count-1 do begin
  AnimationChannelKeyFrame:=Items[i];
  AnimationChannelKeyFrame.Free;
  Items[i]:=nil;
 end;
 inherited Destroy;
end;

procedure TpvDAEAnimationChannelKeyFrames.Clear;
var i:TpvInt32;
    AnimationChannelKeyFrame:TpvDAEAnimationChannelKeyFrame;
begin
 for i:=0 to Count-1 do begin
  AnimationChannelKeyFrame:=Items[i];
  AnimationChannelKeyFrame.Free;
  Items[i]:=nil;
 end;
 inherited Clear;
end;

function TpvDAEAnimationChannelKeyFrames.GetAnimationChannelKeyFrame(const Index:TpvInt32):TpvDAEAnimationChannelKeyFrame;
begin
 result:=inherited Items[Index];
end;

procedure TpvDAEAnimationChannelKeyFrames.SetAnimationChannelKeyFrame(const Index:TpvInt32;AnimationChannelKeyFrame:TpvDAEAnimationChannelKeyFrame);
begin
 inherited Items[Index]:=AnimationChannelKeyFrame;
end;

constructor TpvDAEAnimationChannel.Create;
begin
 inherited Create;
 NodeID:='';
 Node:=nil;
 ElementID:='';
 DestinationObject:=nil;
 DestinationElement:=0;
 StartTime:=0.0;
 EndTime:=0.0;
 TimeStep:=0.0;
 KeyFrames:=TpvDAEAnimationChannelKeyFrames.Create;
 LinearKeyFrames:=nil;
 CountLinearKeyFrames:=0;
 CountValues:=0;
end;

destructor TpvDAEAnimationChannel.Destroy;
begin
 LinearKeyFrames:=nil;
 KeyFrames.Free;
 NodeID:='';
 ElementID:='';
 inherited Destroy;
end;

function TpvDAEAnimationChannel.GetInterpolatedValue(const Time:TpvDouble;const ValueIndex:TpvInt32):TpvDAEAnimationChannelLinearKeyFrameValue;
var FrameTime:TpvDouble;
    LastKeyFrameIndex,Index0,Index1:TpvInt32;
begin
 LastKeyFrameIndex:=CountLinearKeyFrames-1;
 if Time<=StartTime then begin
  FrameTime:=0.0;
 end else begin
  FrameTime:=Min(Max((Min(Time,EndTime)-StartTime)/TimeStep,0.0),LastKeyFrameIndex);
 end;
 Index0:=Min(Max(trunc(FrameTime),0),LastKeyFrameIndex);
 Index1:=Min(Max(Index0+1,0),LastKeyFrameIndex);
 if (Index0>=0) and (Index1<CountLinearKeyFrames) and (ValueIndex>=0) and (ValueIndex<CountValues) then begin
  result:=FloatLerp(LinearKeyFrames[Index0,ValueIndex],LinearKeyFrames[Index1,ValueIndex],Min(Max(frac(FrameTime),0.0),1.0));
 end else begin
  result:=0.0;
 end;
end;

function TpvDAEAnimationChannel.GetInterpolatedValuesMatrix(const Time:TpvDouble):TpvMatrix4x4;
var FrameTime:TpvDouble;
    LastKeyFrameIndex,Index0,Index1:TpvInt32;
    dm0,dm1:TpvDecomposedMatrix4x4;
begin
 LastKeyFrameIndex:=CountLinearKeyFrames-1;
 if Time<=StartTime then begin
  FrameTime:=0.0;
 end else begin
  FrameTime:=Min(Max((Min(Time,EndTime)-StartTime)/TimeStep,0.0),LastKeyFrameIndex);
 end;
 Index0:=Min(Max(trunc(FrameTime),0),LastKeyFrameIndex);
 Index1:=Min(Max(Index0+1,0),LastKeyFrameIndex);
 if (Index0>=0) and (Index1<CountLinearKeyFrames) and (CountValues=16) then begin
  dm0:=TpvMatrix4x4(pointer(@LinearKeyFrames[Index0,0])^).Decompose;
  dm1:=TpvMatrix4x4(pointer(@LinearKeyFrames[Index1,0])^).Decompose;
  if dm0.Valid and dm1.Valid then begin
   result:=TpvMatrix4x4.CreateRecomposed(dm0.Slerp(dm1,Min(Max(frac(FrameTime),0.0),1.0)));
  end else begin
   result:=TpvMatrix4x4(pointer(@LinearKeyFrames[Index0,0])^).SimpleLerp(TpvMatrix4x4(pointer(@LinearKeyFrames[Index1,0])^),Min(Max(frac(FrameTime),0.0),1.0));
  end;
 end else begin
  result:=0.0;
 end;
end;

constructor TpvDAEAnimationChannels.Create;
begin
 inherited Create;
end;

destructor TpvDAEAnimationChannels.Destroy;
var i:TpvInt32;
    AnimationChannel:TpvDAEAnimationChannel;
begin
 for i:=0 to Count-1 do begin
  AnimationChannel:=Items[i];
  AnimationChannel.Free;
  Items[i]:=nil;
 end;
 inherited Destroy;
end;

procedure TpvDAEAnimationChannels.Clear;
var i:TpvInt32;
    AnimationChannel:TpvDAEAnimationChannel;
begin
 for i:=0 to Count-1 do begin
  AnimationChannel:=Items[i];
  AnimationChannel.Free;
  Items[i]:=nil;
 end;
 inherited Clear;
end;

function TpvDAEAnimationChannels.GetAnimationChannel(const Index:TpvInt32):TpvDAEAnimationChannel;
begin
 result:=inherited Items[Index];
end;

procedure TpvDAEAnimationChannels.SetAnimationChannel(const Index:TpvInt32;AnimationChannel:TpvDAEAnimationChannel);
begin
 inherited Items[Index]:=AnimationChannel;
end;

constructor TpvDAEAnimation.Create;
begin
 inherited Create;
 ID:='';
 Name:='';
 Referenced:=false;
 Channels:=TpvDAEAnimationChannels.Create;
end;

destructor TpvDAEAnimation.Destroy;
begin
 Channels.Free;
 ID:='';
 Name:='';
 inherited Destroy;
end;

constructor TpvDAEAnimations.Create;
begin
 inherited Create;
end;

destructor TpvDAEAnimations.Destroy;
var i:TpvInt32;
    Animation:TpvDAEAnimation;
begin
 for i:=0 to Count-1 do begin
  Animation:=Items[i];
  Animation.Free;
  Items[i]:=nil;
 end;
 inherited Destroy;
end;

procedure TpvDAEAnimations.Clear;
var i:TpvInt32;
    Animation:TpvDAEAnimation;
begin
 for i:=0 to Count-1 do begin
  Animation:=Items[i];
  Animation.Free;
  Items[i]:=nil;
 end;
 inherited Clear;
end;

function TpvDAEAnimations.GetAnimation(const Index:TpvInt32):TpvDAEAnimation;
begin
 result:=inherited Items[Index];
end;

procedure TpvDAEAnimations.SetAnimation(const Index:TpvInt32;Animation:TpvDAEAnimation);
begin
 inherited Items[Index]:=Animation;
end;

constructor TpvDAEAnimationClip.Create;
begin
 inherited Create;
 ID:='';
 Name:='';
 Animations:=TList.Create;
end;

destructor TpvDAEAnimationClip.Destroy;
begin
 Animations.Free;
 ID:='';
 Name:='';
 inherited Destroy;
end;

constructor TpvDAEAnimationClips.Create;
begin
 inherited Create;
end;

destructor TpvDAEAnimationClips.Destroy;
var i:TpvInt32;
    AnimationClip:TpvDAEAnimationClip;
begin
 for i:=0 to Count-1 do begin
  AnimationClip:=Items[i];
  AnimationClip.Free;
  Items[i]:=nil;
 end;
 inherited Destroy;
end;

procedure TpvDAEAnimationClips.Clear;
var i:TpvInt32;
    AnimationClip:TpvDAEAnimationClip;
begin
 for i:=0 to Count-1 do begin
  AnimationClip:=Items[i];
  AnimationClip.Free;
  Items[i]:=nil;
 end;
 inherited Clear;
end;

function TpvDAEAnimationClips.GetAnimationClip(const Index:TpvInt32):TpvDAEAnimationClip;
begin
 result:=inherited Items[Index];
end;

procedure TpvDAEAnimationClips.SetAnimationClip(const Index:TpvInt32;AnimationClip:TpvDAEAnimationClip);
begin
 inherited Items[Index]:=AnimationClip;
end;

constructor TpvDAELoader.Create;
begin
 inherited Create;
 COLLADAVersion:='1.5.0';
 AuthoringTool:='';
 Created:=Now;
 Modified:=Now;
 UnitMeter:=1.0;
 UnitName:='meter';
 UpAxis:=dluaYUP;
 AutomaticCorrect:=true;
 VisualScenes:=TpvDAEVisualScenes.Create;
 CameraHashMap:=TpvDAECameraHashMap.Create(nil);
 CameraList:=TpvDAECameraList.Create(false);
 MainVisualScene:=nil;
 Animations:=TpvDAEAnimations.Create;
 AnimationClips:=TpvDAEAnimationClips.Create;
 Materials:=TpvDAEMaterials.Create;
end;

destructor TpvDAELoader.Destroy;
begin
 CameraHashMap.Free;
 CameraList.Free;
 VisualScenes.Free;
 Animations.Free;
 AnimationClips.Free;
 Materials.Free;
 COLLADAVersion:='';
 AuthoringTool:='';
 UnitName:='';
 inherited Destroy;
end;

function TpvDAELoader.Load(Stream:TStream):boolean;
const lstBOOL=0;
      lstINT=1;
      lsTpvFloat=2;
      lstIDREF=3;
      lstNAME=4;
      aptNONE=0;
      aptIDREF=1;
      aptNAME=2;
      aptINT=3;
      apTpvFloat=4;
      apTpvFloat4x4=5;
      ltAMBIENT=0;
      ltDIRECTIONAL=1;
      ltPOINT=2;
      ltSPOT=3;
      ntNODE=0;
      ntROTATE=1;
      ntTRANSLATE=2;
      ntSCALE=3;
      ntMATRIX=4;
      ntLOOKAT=5;
      ntSKEW=6;
      ntEXTRA=7;
      ntINSTANCECAMERA=8;
      ntINSTANCELIGHT=9;
      ntINSTANCECONTROLLER=10;
      ntINSTANCEGEOMETRY=11;
      ntINSTANCENODE=12;
      mtNONE=0;
      mtTRIANGLES=1;
      mtTRIFANS=2;
      mtTRISTRIPS=3;
      mtPOLYGONS=4;
      mtPOLYLIST=5;
      mtLINES=6;
      mtLINESTRIPS=7;
      mtMORPHTARGET=8;
      ctNONE=0;
      ctSKIN=1;
      ctMORPH=2;
type PLibraryImage=^TLibraryImage;
     TLibraryImage=record
      Next:PLibraryImage;
      ID:ansistring;
      InitFrom:ansistring;
     end;
     PLibraryEffect=^TLibraryEffect;
     PLibraryMaterial=^TLibraryMaterial;
     TLibraryMaterial=record
      Next:PLibraryMaterial;
      ID:ansistring;
      Name:ansistring;
      EffectURL:ansistring;
      Effect:PLibraryEffect;
      Index:TpvInt32;
     end;
     PLibraryEffectSurface=^TLibraryEffectSurface;
     TLibraryEffectSurface=record
      Next:PLibraryEffectSurface;
      Effect:PLibraryEffect;
      SID:ansistring;
      InitFrom:ansistring;
      Format:ansistring;
     end;
     PLibraryEffectSampler2D=^TLibraryEffectSampler2D;
     TLibraryEffectSampler2D=record
      Next:PLibraryEffectSampler2D;
      Effect:PLibraryEffect;
      SID:ansistring;
      Source:ansistring;
      WrapS:ansistring;
      WrapT:ansistring;
      MinFilter:ansistring;
      MagFilter:ansistring;
      MipFilter:ansistring;
     end;
     PLibraryEffecTpvFloat=^TLibraryEffecTpvFloat;
     TLibraryEffecTpvFloat=record
      Next:PLibraryEffecTpvFloat;
      Effect:PLibraryEffect;
      SID:ansistring;
      Value:TpvFloat;
     end;
     PLibraryEffecTpvFloat4=^TLibraryEffecTpvFloat4;
     TLibraryEffecTpvFloat4=record
      Next:PLibraryEffecTpvFloat4;
      Effect:PLibraryEffect;
      SID:ansistring;
      Values:array[0..3] of TpvFloat;
     end;
     TLibraryEffect=record
      Next:PLibraryEffect;
      ID:ansistring;
      Name:ansistring;
      Images:TList;
      Surfaces:PLibraryEffectSurface;
      Sampler2D:PLibraryEffectSampler2D;
      Floats:PLibraryEffecTpvFloat;
      Float4s:PLibraryEffecTpvFloat4;
      ShadingType:TpvInt32;
      Ambient:TpvDAEColorOrTexture;
      Diffuse:TpvDAEColorOrTexture;
      Emission:TpvDAEColorOrTexture;
      Specular:TpvDAEColorOrTexture;
      Transparent:TpvDAEColorOrTexture;
      Shininess:TpvFloat;
      Reflectivity:TpvFloat;
      IndexOfRefraction:TpvFloat;
      Transparency:TpvFloat;
     end;
     PLibrarySourceData=^TLibrarySourceData;
     TLibrarySourceData=record
      Next:PLibrarySourceData;
      ID:ansistring;
      SourceType:TpvInt32;
      Data:array of double;
      Strings:array of ansistring;
     end;
     PLibrarySourceAccessorParam=^TLibrarySourceAccessorParam;
     TLibrarySourceAccessorParam=record
      ParamName:ansistring;
      ParamType:TpvInt32;
     end;
     TLibrarySourceAccessorParams=array of TLibrarySourceAccessorParam;
     PLibrarySourceAccessor=^TLibrarySourceAccessor;
     TLibrarySourceAccessor=record
      Source:ansistring;
      Count:TpvInt32;
      Offset:TpvInt32;
      Stride:TpvInt32;
      Params:TLibrarySourceAccessorParams;
     end;
     PLibrarySource=^TLibrarySource;
     TLibrarySource=record
      Next:PLibrarySource;
      ID:ansistring;
      SourceDatas:TList;
      Accessor:TLibrarySourceAccessor;
     end;
     PInput=^TInput;
     TInput=record
      Semantic:ansistring;
      Source:ansistring;
      Set_:TpvInt32;
      Offset:TpvInt32;
     end;
     TInputs=array of TInput;
     TInts=array of TpvInt32;
     TDoubles=array of double;
     PSourceInput=^TSourceInput;
     TSourceInput=record
      Inputs:TInputs;
      VCounts:TInts;
      V:TInts;
     end;
     PLibraryVertices=^TLibraryVertices;
     TLibraryVertices=record
      Next:PLibraryVertices;
      ID:ansistring;
      Inputs:TInputs;
     end;
     PLibraryGeometryMesh=^TLibraryGeometryMesh;
     TLibraryGeometryMesh=record
      MeshType:TpvInt32;
      Count:TpvInt32;
      Material:ansistring;
      Inputs:TInputs;
      VCounts:TInts;
      Indices:array of TInts;
     end;
     TLibraryGeometryMeshs=array of TLibraryGeometryMesh;
     PLibraryGeometry=^TLibraryGeometry;
     TLibraryGeometry=record
      Next:PLibraryGeometry;
      ID:ansistring;
      Meshs:TLibraryGeometryMeshs;
      CountMeshs:TpvInt32;
     end;
     PLibraryController=^TLibraryController;
     PLibraryControllerSkin=^TLibraryControllerSkin;
     TLibraryControllerSkin=record
      Geometry:PLibraryGeometry;
      Controller:PLibraryController;
      Source:ansistring;
      BindShapeMatrix:TpvMatrix4x4;
      InverseBindMatrices:array of TpvMatrix4x4;
      Joints:TSourceInput;
      VertexWeights:TSourceInput;
      Count:TpvInt32;
     end;
     PLibraryControllerMorph=^TLibraryControllerMorph;
     TLibraryControllerMorph=record
      Geometry:PLibraryGeometry;
      Controller:PLibraryController;
      Method:ansistring;
      Source:ansistring;
      Targets:TSourceInput;
     end;
     TLibraryController=record
      Next:PLibraryController;
      ID:ansistring;
      Name:ansistring;
      ControllerType:TpvInt32;
      Geometry:PLibraryGeometry;
      Skin:PLibraryControllerSkin;
      Morph:PLibraryControllerMorph;
     end;
     PLibraryAnimationSampler=^TLibraryAnimationSampler;
     TLibraryAnimationSampler=record
      ID:ansistring;
      Inputs:TInputs;
     end;
     TLibraryAnimationSamplers=array of TLibraryAnimationSampler;
     PLibraryAnimationChannel=^TLibraryAnimationChannel;
     TLibraryAnimationChannel=record
      Source:ansistring;
      Target:ansistring;
     end;
     TLibraryAnimationChannels=array of TLibraryAnimationChannel;
     PLibraryAnimation=^TLibraryAnimation;
     TLibraryAnimation=record
      Next:PLibraryAnimation;
      ID:ansistring;
      Name:ansistring;
      Referenced:longbool;
      Samplers:TLibraryAnimationSamplers;
      Channels:TLibraryAnimationChannels;
      DAEAnimation:TpvDAEAnimation;
     end;
     TLibraryAnimationClipAnimations=array of PLibraryAnimation;
     PLibraryAnimationClip=^TLibraryAnimationClip;
     TLibraryAnimationClip=record
      Next:PLibraryAnimationClip;
      ID:ansistring;
      Name:ansistring;
      Animations:TLibraryAnimationClipAnimations;
     end;
     PLibraryLight=^TLibraryLight;
     TLibraryLight=record
      Next:PLibraryLight;
      ID:ansistring;
      Name:ansistring;
      LightType:TpvInt32;
      Color:TpvVector3;
      FallOffAngle:TpvFloat;
      FallOffExponent:TpvFloat;
      ConstantAttenuation:TpvFloat;
      LinearAttenuation:TpvFloat;
      QuadraticAttenuation:TpvFloat;
     end;
     PLibraryCamera=^TLibraryCamera;
     TLibraryCamera=record
      Next:PLibraryCamera;
      ID:ansistring;
      Name:ansistring;
      Camera:record
       Name:ansistring;
       Matrix:TpvMatrix4x4;
       ZNear:TpvFloat;
       ZFar:TpvFloat;
       AspectRatio:TpvFloat;
       case CameraType:TpvInt32 of
        dlctPERSPECTIVE:(
         XFov:TpvFloat;
         YFov:TpvFloat;
        );
        dlctORTHOGRAPHIC:(
         XMag:TpvFloat;
         YMag:TpvFloat;
        );
      end;
      SIDZNear:ansistring;
      SIDZFar:ansistring;
      SIDAspectRatio:ansistring;
      SIDXFov:ansistring;
      SIDYFov:ansistring;
      SIDXMag:ansistring;
      SIDYMag:ansistring;
     end;
     PInstanceMaterialTexCoordSet=^TInstanceMaterialTexCoordSet;
     TInstanceMaterialTexCoordSet=record
      Semantic:ansistring;
      InputSet:TpvInt32;
     end;
     TInstanceMaterialTexCoordSets=array of TInstanceMaterialTexCoordSet;
     PInstanceMaterial=^TInstanceMaterial;
     TInstanceMaterial=record
      Symbol:ansistring;
      Target:ansistring;
      TexCoordSets:TInstanceMaterialTexCoordSets;
     end;
     TInstanceMaterials=array of TInstanceMaterial;
     PLibraryNode=^TLibraryNode;
     TLibraryNode=record
      Next:PLibraryNode;
      ID:ansistring;
      SID:ansistring;
      Name:ansistring;
      NodeType_:ansistring;
      IsJoint:longbool;
      Visible:longbool;
      InstanceMaterials:TInstanceMaterials;
      InstanceNode:ansistring;
      case NodeType:TpvInt32 of
       ntNODE:(
        Children:TList;
       );
       ntROTATE,
       ntTRANSLATE,
       ntSCALE,
       ntMATRIX,
       ntLOOKAT,
       ntSKEW:(
        Matrix:TpvMatrix4x4;
        case TpvInt32 of
         ntROTATE:(
          RotateAxis:TpvVector3;
          RotateAngle:TpvFloat;
         );
         ntTRANSLATE:(
          TranslateOffset:TpvVector3;
         );
         ntSCALE:(
          Scale:TpvVector3;
         );
         ntMATRIX:(
         );
         ntLOOKAT:(
          LookAtOrigin:TpvVector3;
          LookAtDest:TpvVector3;
          LookAtUp:TpvVector3;
         );
         ntSKEW:(
          SkewAngle:TpvFloat;
          SkewA:TpvVector3;
          SkewB:TpvVector3;
         );
       );
       ntEXTRA:(
       );
       ntINSTANCECAMERA:(
        InstanceCamera:PLibraryCamera;
       );
       ntINSTANCELIGHT:(
        InstanceLight:PLibraryLight;
       );
       ntINSTANCECONTROLLER:(
        InstanceController:PLibraryController;
       );
       ntINSTANCEGEOMETRY:(
        InstanceGeometry:PLibraryGeometry;
       );
       ntINSTANCENODE:(
       );
     end;
     PLibraryVisualScene=^TLibraryVisualScene;
     TLibraryVisualScene=record
      Next:PLibraryVisualScene;
      ID:ansistring;
      Name:ansistring;
      Items:TList;
     end;
var IDStringHashMap:TpvDAEStringHashMap;
    NodeIDStringHashMap:TpvDAEStringHashMap;
    MorphTargetWeightIDStringHashMap:TpvDAEStringHashMap;
    LibraryImagesIDStringHashMap:TpvDAEStringHashMap;
    LibraryImages:PLibraryImage;
    LibraryMaterialsIDStringHashMap:TpvDAEStringHashMap;
    LibraryMaterials:PLibraryMaterial;
    LibraryEffectsIDStringHashMap:TpvDAEStringHashMap;
    LibraryEffects:PLibraryEffect;
    LibrarySourcesIDStringHashMap:TpvDAEStringHashMap;
    LibrarySources:PLibrarySource;
    LibrarySourceDatasIDStringHashMap:TpvDAEStringHashMap;
    LibrarySourceDatas:PLibrarySourceData;
    LibraryVerticesesIDStringHashMap:TpvDAEStringHashMap;
    LibraryVerticeses:PLibraryVertices;
    LibraryGeometriesIDStringHashMap:TpvDAEStringHashMap;
    LibraryGeometries:PLibraryGeometry;
    LibraryControllersIDStringHashMap:TpvDAEStringHashMap;
    LibraryControllers:PLibraryController;
    LibraryAnimationsIDStringHashMap:TpvDAEStringHashMap;
    LibraryAnimationList:TList;
    LibraryAnimations:PLibraryAnimation;
    LibraryAnimationClipsIDStringHashMap:TpvDAEStringHashMap;
    LibraryAnimationClipList:TList;
    LibraryAnimationClips:PLibraryAnimationClip;
    LibraryCamerasIDStringHashMap:TpvDAEStringHashMap;
    LibraryCameras:PLibraryCamera;
    LibraryLightsIDStringHashMap:TpvDAEStringHashMap;
    LibraryLights:PLibraryLight;
    LibraryVisualScenesIDStringHashMap:TpvDAEStringHashMap;
    LibraryVisualScenes:PLibraryVisualScene;
    LibraryNodesIDStringHashMap:TpvDAEStringHashMap;
    LibraryNodes:PLibraryNode;
    MainLibraryVisualScene:PLibraryVisualScene;
    BadAccessor:boolean;
    FlipAngle:boolean;
    NegJoints:boolean;
 function MyTrim(const s:AnsiString):AnsiString;
 begin
  result:=AnsiString(Trim(String(s)));
 end;
 function MyLowerCase(const s:AnsiString):AnsiString;
 begin
  result:=AnsiString(LowerCase(String(s)));
 end;
 function MyUpperCase(const s:AnsiString):AnsiString;
 begin
  result:=AnsiString(UpperCase(String(s)));
 end;
 function MyStringReplace(const s,OldPattern,NewPattern:AnsiString;const Flags:TReplaceFlags):AnsiString;
 begin
  result:=AnsiString(StringReplace(String(s),String(OldPattern),String(NewPattern),Flags));
 end;
 function MyStrToIntDef(const s:AnsiString;const DefaultValue:TpvInt32):TpvInt32;
 begin
  result:=StrToIntDef(String(s),DefaultValue);
 end;
 procedure CollectIDs(ParentItem:TpvXMLItem);
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     ID:ansistring;
 begin
  if assigned(ParentItem) then begin
   for XMLItemIndex:=0 to ParentItem.Items.Count-1 do begin
    XMLItem:=ParentItem.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      ID:=TpvXMLTag(XMLItem).GetParameter('id','');
      if length(ID)>0 then begin
       IDStringHashMap.Add(ID,XMLItem);
      end;
     end;
     CollectIDs(XMLItem);
    end;
   end;
  end;
 end;
 function ParseText(ParentItem:TpvXMLItem):ansistring;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
 begin
  result:='';
  if assigned(ParentItem) then begin
   for XMLItemIndex:=0 to ParentItem.Items.Count-1 do begin
    XMLItem:=ParentItem.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLText then begin
      result:=result+AnsiString(TpvXMLText(XMLItem).Text);
     end else if XMLItem is TpvXMLTag then begin
      if TpvXMLTag(XMLItem).Name='br' then begin
       result:=result+#13#10;
      end;
      result:=result+ParseText(XMLItem);
     end;
    end;
   end;
  end;
 end;
 function ParseContributorTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='authoring_tool' then begin
       AuthoringTool:=ParseText(XMLTag);
       if AuthoringTool='COLLADA Mixamo exporter' then begin
        BadAccessor:=true;
       end else if AuthoringTool='FBX COLLADA exporter' then begin
        BadAccessor:=true;
       end else if pos('Blender 2.5',String(AuthoringTool))>0 then begin
        FlipAngle:=true;
        NegJoints:=true;
       end;
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseAssetTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     s:ansistring;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='contributor' then begin
       ParseContributorTag(XMLTag);
      end else if XMLTag.Name='created' then begin
       s:=ParseText(XMLTag);
       if length(s)>0 then begin
       end;
      end else if XMLTag.Name='modified' then begin
       s:=ParseText(XMLTag);
       if length(s)>0 then begin
       end;
      end else if XMLTag.Name='unit' then begin
       UnitMeter:=StrToDouble(XMLTag.GetParameter('meter','1.0'),1.0);
       UnitName:=XMLTag.GetParameter('name','meter');
      end else if XMLTag.Name='up_axis' then begin
       s:=MyUpperCase(MyTrim(ParseText(XMLTag)));
       if (s='X') or (s='X_UP') then begin
        UpAxis:=dluaXUP;
       end else if (s='Y') or (s='Y_UP') then begin
        UpAxis:=dluaYUP;
       end else if (s='Z') or (s='Z_UP') then begin
        UpAxis:=dluaZUP;
       end;
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseImageTag(ParentTag:TpvXMLTag):PLibraryImage;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag,XMLSubTag:TpvXMLTag;
     ID,InitFrom:ansistring;
     Image:PLibraryImage;
 begin
  result:=nil;
  if assigned(ParentTag) then begin
   ID:=TpvXMLTag(ParentTag).GetParameter('id','');
   if length(ID)>0 then begin
    InitFrom:='';
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='init_from' then begin
        XMLSubTag:=XMLTag.FindTag('ref');
        if assigned(XMLSubTag) then begin
         InitFrom:=ParseText(XMLSubTag);
        end else begin
         InitFrom:=ParseText(XMLTag);
        end;
       end;
      end;
     end;
    end;
    if length(InitFrom)>0 then begin
     GetMem(Image,SizeOf(TLibraryImage));
     FillChar(Image^,SizeOf(TLibraryImage),AnsiChar(#0));
     Image^.Next:=LibraryImages;
     LibraryImages:=Image;
     Image^.ID:=ID;
     Image^.InitFrom:=InitFrom;
     LibraryImagesIDStringHashMap.Add(ID,Image);
     result:=Image;
    end;
   end;
  end;
 end;
 function ParseLibraryImagesTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='image' then begin
       ParseImageTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseMaterialTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     ID,Name,EffectURL:ansistring;
     Material:PLibraryMaterial;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TpvXMLTag(ParentTag).GetParameter('id','');
   Name:=TpvXMLTag(ParentTag).GetParameter('name','');
   if length(ID)>0 then begin
    EffectURL:='';
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='instance_effect' then begin
        EffectURL:=MyStringReplace(XMLTag.GetParameter('url',''),'#','',[rfReplaceAll]);
       end;
      end;
     end;
    end;
    if length(EffectURL)>0 then begin
     GetMem(Material,SizeOf(TLibraryMaterial));
     FillChar(Material^,SizeOf(TLibraryMaterial),AnsiChar(#0));
     Material^.Next:=LibraryMaterials;
     LibraryMaterials:=Material;
     Material^.ID:=ID;
     Material^.Name:=Name;
     Material^.EffectURL:=EffectURL;
     Material^.Index:=-1;
     LibraryMaterialsIDStringHashMap.Add(ID,Material);
    end;
   end;
   result:=true;
  end;
 end;
 function ParseLibraryMaterialsTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='material' then begin
       ParseMaterialTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseNewParamTag(ParentTag:TpvXMLTag;Effect:PLibraryEffect):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag,XMLSubTag,XMLSubSubTag:TpvXMLTag;
     SID,s:ansistring;
     Surface:PLibraryEffectSurface;
     Sampler2D:PLibraryEffectSampler2D;
     Float:PLibraryEffecTpvFloat;
     Float4:PLibraryEffecTpvFloat4;
     Image:PLibraryImage;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   SID:=TpvXMLTag(ParentTag).GetParameter('sid','');
   if length(SID)>0 then begin
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='surface' then begin
        GetMem(Surface,SizeOf(TLibraryEffectSurface));
        FillChar(Surface^,SizeOf(TLibraryEffectSurface),AnsiChar(#0));
        Surface^.Next:=Effect^.Surfaces;
        Effect^.Surfaces:=Surface;
        Surface^.Effect:=Effect;
        Surface^.SID:=SID;
        XMLSubTag:=XMLTag.FindTag('init_from');
        if assigned(XMLSubTag) then begin
         XMLSubSubTag:=XMLSubTag.FindTag('ref');
         if assigned(XMLSubSubTag) then begin
          Surface^.InitFrom:=ParseText(XMLSubSubTag);
         end else begin
          Surface^.InitFrom:=ParseText(XMLSubTag);
         end;
        end else begin
         Surface^.InitFrom:='';
        end;
        Surface^.Format:=ParseText(XMLTag.FindTag('format'));
       end else if XMLTag.Name='sampler2D' then begin
        GetMem(Sampler2D,SizeOf(TLibraryEffectSampler2D));
        FillChar(Sampler2D^,SizeOf(TLibraryEffectSampler2D),AnsiChar(#0));
        Sampler2D^.Next:=Effect^.Sampler2D;
        Effect^.Sampler2D:=Sampler2D;
        Sampler2D^.Effect:=Effect;
        Sampler2D^.SID:=SID;
        Sampler2D^.Source:=ParseText(XMLTag.FindTag('source'));
        Sampler2D^.WrapS:=ParseText(XMLTag.FindTag('wrap_s'));
        Sampler2D^.WrapT:=ParseText(XMLTag.FindTag('wrap_t'));
        Sampler2D^.MinFilter:=ParseText(XMLTag.FindTag('minfilter'));
        Sampler2D^.MagFilter:=ParseText(XMLTag.FindTag('magfilter'));
        Sampler2D^.MipFilter:=ParseText(XMLTag.FindTag('mipfilter'));
        XMLSubTag:=XMLTag.FindTag('instance_image');
        if assigned(XMLSubTag) then begin
         Image:=LibraryImagesIDStringHashMap[MyStringReplace(XMLSubTag.GetParameter('url',''),'#','',[rfReplaceAll])];
         if assigned(Image) then begin
          Sampler2D^.Source:=Image^.InitFrom;
         end;
        end;
       end else if XMLTag.Name='float' then begin
        GetMem(Float,SizeOf(TLibraryEffecTpvFloat));
        FillChar(Float^,SizeOf(TLibraryEffecTpvFloat),AnsiChar(#0));
        Float^.Next:=Effect^.Floats;
        Effect^.Floats:=Float;
        Float^.Effect:=Effect;
        Float^.SID:=SID;
        Float^.Value:=StrToDouble(ParseText(XMLTag),0.0);
       end else if XMLTag.Name='float4' then begin
        GetMem(Float4,SizeOf(TLibraryEffecTpvFloat4));
        FillChar(Float4^,SizeOf(TLibraryEffecTpvFloat4),AnsiChar(#0));
        Float4^.Next:=Effect^.Float4s;
        Effect^.Float4s:=Float4;
        Float4^.Effect:=Effect;
        Float4^.SID:=SID;
        s:=ParseText(XMLTag);
        Float4^.Values[0]:=StrToDouble(GetToken(s),0.0);
        Float4^.Values[1]:=StrToDouble(GetToken(s),0.0);
        Float4^.Values[2]:=StrToDouble(GetToken(s),0.0);
        Float4^.Values[3]:=StrToDouble(GetToken(s),0.0);
       end else if XMLTag.Name='extra' then begin
       end;
      end;
     end;
    end;
    result:=true;
   end;
  end;
 end;
 function ParseFloat(ParentTag:TpvXMLTag;Effect:PLibraryEffect;const DefaultValue:TpvFloat=0.0):TpvFloat;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     s:ansistring;
     Float:PLibraryEffecTpvFloat;
 begin
  result:=DefaultValue;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='float' then begin
       result:=StrToDouble(ParseText(XMLTag),DefaultValue);
       exit;
      end else if XMLTag.Name='param' then begin
       s:=XMLTag.GetParameter('ref');
       if length(s)>0 then begin
        Float:=Effect^.Floats;
        while assigned(Float) do begin
         if Float^.SID=s then begin
          result:=Float^.Value;
          exit;
         end;
         Float:=Float^.Next;
        end;
       end;
      end;
     end;
    end;
   end;
   result:=StrToDouble(ParseText(ParentTag),DefaultValue);
  end;
 end;
 function ParseFloat4(ParentTag:TpvXMLTag;Effect:PLibraryEffect;const DefaultValue:TpvVector4):TpvVector4;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     s:ansistring;
     Float4:PLibraryEffecTpvFloat4;
 begin
  result:=DefaultValue;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='float' then begin
       s:=ParseText(XMLTag);
       result.x:=StrToDouble(GetToken(s),DefaultValue.x);
       result.y:=StrToDouble(GetToken(s),DefaultValue.y);
       result.z:=StrToDouble(GetToken(s),DefaultValue.z);
       result.w:=StrToDouble(GetToken(s),DefaultValue.w);
       exit;
      end else if XMLTag.Name='param' then begin
       s:=XMLTag.GetParameter('ref');
       if length(s)>0 then begin
        Float4:=Effect^.Float4s;
        while assigned(Float4) do begin
         if Float4^.SID=s then begin
          result.x:=Float4.Values[0];
          result.y:=Float4.Values[1];
          result.z:=Float4.Values[2];
          result.w:=Float4.Values[3];
          exit;
         end;
         Float4:=Float4^.Next;
        end;
       end;
      end;
     end;
    end;
   end;
   s:=ParseText(ParentTag);
   result.x:=StrToDouble(GetToken(s),DefaultValue.x);
   result.y:=StrToDouble(GetToken(s),DefaultValue.y);
   result.z:=StrToDouble(GetToken(s),DefaultValue.z);
   result.w:=StrToDouble(GetToken(s),DefaultValue.w);
  end;
 end;
 function ParseColorOrTextureTag(ParentTag:TpvXMLTag;Effect:PLibraryEffect;const DefaultColor:TpvVector4):TpvDAEColorOrTexture;
 var XMLTag,TempXMLTag:TpvXMLTag;
     s:ansistring;
     Sampler2D:PLibraryEffectSampler2D;
     Surface:PLibraryEffectSurface;
     Image:PLibraryImage;
 begin
  FillChar(result,SizeOf(TpvDAEColorOrTexture),AnsiChar(#0));
  if assigned(ParentTag) then begin
   begin
    XMLTag:=ParentTag.FindTag('color');
    if assigned(XMLTag) then begin
     result.HasColor:=true;
     s:=MyTrim(ParseText(XMLTag));
     result.Color.r:=StrToDouble(GetToken(s),DefaultColor.r);
     result.Color.g:=StrToDouble(GetToken(s),DefaultColor.g);
     result.Color.b:=StrToDouble(GetToken(s),DefaultColor.b);
     result.Color.a:=StrToDouble(GetToken(s),DefaultColor.a);
    end else begin
     XMLTag:=ParentTag.FindTag('param');
     if assigned(XMLTag) then begin
      result.HasColor:=true;
      result.Color:=ParseFloat4(XMLTag,Effect,DefaultColor);
     end else begin
      result.Color:=DefaultColor;
     end;
    end;
   end;
   begin
    XMLTag:=ParentTag.FindTag('texture');
    if assigned(XMLTag) then begin
     result.HasTexture:=true;
     s:=XMLTag.GetParameter('texture');
     result.Texture:=s;
     if length(s)>0 then begin
      Sampler2D:=Effect^.Sampler2D;
      while assigned(Sampler2D) do begin
       if Sampler2D^.SID=s then begin
        result.Texture:=Sampler2D^.Source;
        s:='';
        break;
       end;
       Sampler2D:=Sampler2D^.Next;
      end;
      if length(s)>0 then begin
       Surface:=Effect^.Surfaces;
       while assigned(Surface) do begin
        if Surface^.SID=s then begin
         result.Texture:=Surface^.InitFrom;
         s:='';
         break;
        end;
        Surface:=Surface^.Next;
       end;
      end;
      if length(s)>0 then begin
       Image:=LibraryImagesIDStringHashMap[s];
       if assigned(Image) then begin
        result.Texture:=Image^.InitFrom;
        s:='';
       end;
      end;
     end;
     result.TexCoord:=XMLTag.GetParameter('texcoord');
     result.OffsetU:=0.0;
     result.OffsetV:=0.0;
     result.RepeatU:=1.0;
     result.RepeatV:=1.0;
     result.WrapU:=1;
     result.WrapV:=1;
     XMLTag:=XMLTag.FindTag('extra');
     if assigned(XMLTag) then begin
      TempXMLTag:=XMLTag.FindTag('technique');
      if assigned(TempXMLTag) then begin
       XMLTag:=TempXMLTag;
      end;
      result.OffsetU:=StrToDouble(ParseText(XMLTag.FindTag('offsetU')),0.0);
      result.OffsetV:=StrToDouble(ParseText(XMLTag.FindTag('offsetV')),0.0);
      result.RepeatU:=StrToDouble(ParseText(XMLTag.FindTag('repeatU')),1.0);
      result.RepeatV:=StrToDouble(ParseText(XMLTag.FindTag('repeatV')),1.0);
      result.WrapU:=MyStrToIntDef(ParseText(XMLTag.FindTag('wrapU')),1);
      result.WrapV:=MyStrToIntDef(ParseText(XMLTag.FindTag('wrapV')),1);
     end;
    end;
   end;
  end;
 end;
 function ParseTechniqueTag(ParentTag:TpvXMLTag;Effect:PLibraryEffect):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     ShadingType:TpvInt32;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ShadingType:=-1;
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='constant' then begin
       ShadingType:=dlstCONSTANT;
      end else if XMLTag.Name='lambert' then begin
       ShadingType:=dlstLAMBERT;
      end else if XMLTag.Name='blinn' then begin
       ShadingType:=dlstBLINN;
      end else if XMLTag.Name='phong' then begin
       ShadingType:=dlstPHONG;
      end;
      if ShadingType>=0 then begin
       Effect^.ShadingType:=ShadingType;
       Effect^.Ambient:=ParseColorOrTextureTag(XMLTag.FindTag('ambient'),Effect,TpvVector4.Create(0.0,0.0,0.0,1.0));
       Effect^.Diffuse:=ParseColorOrTextureTag(XMLTag.FindTag('diffuse'),Effect,TpvVector4.Create(1.0,1.0,1.0,1.0));
       Effect^.Emission:=ParseColorOrTextureTag(XMLTag.FindTag('emission'),Effect,TpvVector4.Create(0.0,0.0,0.0,1.0));
       Effect^.Specular:=ParseColorOrTextureTag(XMLTag.FindTag('specular'),Effect,TpvVector4.Create(0.0,0.0,0.0,1.0));
       Effect^.Transparent:=ParseColorOrTextureTag(XMLTag.FindTag('transparent'),Effect,TpvVector4.Create(0.0,0.0,0.0,1.0));
       Effect^.Shininess:=ParseFloat(XMLTag.FindTag('shininess'),Effect,-Infinity);
       Effect^.Reflectivity:=ParseFloat(XMLTag.FindTag('reflectivity'),Effect,-Infinity);
       Effect^.IndexOfRefraction:=ParseFloat(XMLTag.FindTag('index_of_refraction'),Effect,-Infinity);
       Effect^.Transparency:=ParseFloat(XMLTag.FindTag('transparency'),Effect,-Infinity);
       break;
      end;
     end;
     result:=true;
    end;
   end;
  end;
 end;
 function ParseProfileCommonTag(ParentTag:TpvXMLTag;Effect:PLibraryEffect):TpvXMLTag;
 var PassIndex,XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     Image:PLibraryImage;
 begin
  result:=nil;
  if assigned(ParentTag) then begin
   for PassIndex:=0 to 4 do begin
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if (PassIndex=0) and (XMLTag.Name='profile_COMMON') then begin
        result:=ParseProfileCommonTag(XMLTag,Effect);
       end else if (PassIndex=1) and (XMLTag.Name='image') then begin
        Image:=ParseImageTag(XMLTag);
        if assigned(Image) then begin
         Effect^.Images.Add(Image);
        end;
       end else if (PassIndex=2) and (XMLTag.Name='newparam') then begin
        ParseNewParamTag(XMLTag,Effect);
       end else if (PassIndex=3) and (XMLTag.Name='technique') then begin
        result:=XMLTag;
       end else if (PassIndex=4) and (XMLTag.Name='extra') then begin
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 function ParseEffectTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     ID,Name:ansistring;
     Effect:PLibraryEffect;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TpvXMLTag(ParentTag).GetParameter('id','');
   Name:=TpvXMLTag(ParentTag).GetParameter('name','');
   if length(ID)>0 then begin
    GetMem(Effect,SizeOf(TLibraryEffect));
    FillChar(Effect^,SizeOf(TLibraryEffect),AnsiChar(#0));
    Effect^.Next:=LibraryEffects;
    LibraryEffects:=Effect;
    Effect^.ID:=ID;
    Effect^.Name:=Name;
    EFfect^.Images:=TList.Create;
    Effect^.ShadingType:=-1;
    LibraryEffectsIDStringHashMap.Add(ID,Effect);
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='profile_COMMON' then begin
        ParseTechniqueTag(ParseProfileCommonTag(XMLTag,Effect),Effect);
       end;
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseLibraryEffectsTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='effect' then begin
       ParseEffectTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseAccessorTag(ParentTag:TpvXMLTag;const Accessor:PLibrarySourceAccessor):boolean;
 var XMLItemIndex,Count:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     s:ansistring;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   Accessor^.Source:=MyStringReplace(ParentTag.GetParameter('source',''),'#','',[rfReplaceAll]);
   Accessor^.Count:=MyStrToIntDef(ParentTag.GetParameter('count'),0);
   Accessor^.Offset:=MyStrToIntDef(ParentTag.GetParameter('offset'),0);
   Accessor^.Stride:=MyStrToIntDef(ParentTag.GetParameter('stride'),1);
   Count:=0;
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='param' then begin
       if (Count+1)>length(Accessor^.Params) then begin
        SetLength(Accessor^.Params,(Count+1)*2);
       end;
       Accessor^.Params[Count].ParamName:=XMLTag.GetParameter('name');
       s:=XMLTag.GetParameter('type');
       if (s='IDREF') or (s='IDREF_array') then begin
        Accessor^.Params[Count].ParamType:=aptIDREF;
       end else if (s='Name') or (s='name') then begin
        Accessor^.Params[Count].ParamType:=aptNAME;
       end else if s='int' then begin
        Accessor^.Params[Count].ParamType:=aptINT;
       end else if s='float' then begin
        Accessor^.Params[Count].ParamType:=apTpvFloat;
       end else if s='float4x4' then begin
        Accessor^.Params[Count].ParamType:=apTpvFloat4x4;
       end else begin
        Accessor^.Params[Count].ParamType:=aptNONE;
       end;
       inc(Count);
      end;
     end;
    end;
   end;
   SetLength(Accessor^.Params,Count);
   result:=true;
  end;
 end;
 function ParseSourceTag(ParentTag:TpvXMLTag):boolean;
 var PassIndex,XMLItemIndex,Count,i,j:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     ID:ansistring;
     s,si:ansistring;
     Source:PLibrarySource;
     SourceData:PLibrarySourceData;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TpvXMLTag(ParentTag).GetParameter('id','');
   if length(ID)>0 then begin
    GetMem(Source,SizeOf(TLibrarySource));
    FillChar(Source^,SizeOf(TLibrarySource),AnsiChar(#0));
    Source^.Next:=LibrarySources;
    LibrarySources:=Source;
    Source^.ID:=ID;
    Source^.SourceDatas:=TList.Create;
    LibrarySourcesIDStringHashMap.Add(ID,Source);
    for PassIndex:=0 to 1 do begin
     for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
      XMLItem:=ParentTag.Items[XMLItemIndex];
      if assigned(XMLItem) then begin
       if XMLItem is TpvXMLTag then begin
        XMLTag:=TpvXMLTag(XMLItem);
        if (PassIndex=0) and (XMLTag.Name='bool_array') then begin
         GetMem(SourceData,SizeOf(TLibrarySourceData));
         FillChar(SourceData^,SizeOf(TLibrarySourceData),AnsiChar(#0));
         SourceData^.Next:=LibrarySourceDatas;
         LibrarySourceDatas:=SourceData;
         SourceData^.ID:=XMLTag.GetParameter('id');
         LibrarySourceDatasIDStringHashMap.Add(SourceData^.ID,SourceData);
         SourceData^.SourceType:=lstBOOL;
         Source^.SourceDatas.Add(SourceData);
         s:=ParseText(XMLTag);
         Count:=0;
         i:=1;
         while i<=length(s) do begin
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          j:=i;
          while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if j<i then begin
           si:=copy(s,j,i-j);
          end else begin
           si:='';
          end;
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if (Count+1)>length(SourceData^.Data) then begin
           SetLength(SourceData^.Data,(Count+1)*2);
          end;
          si:=MyLowerCase(MyTrim(si));
          if (si='true') or (si='yes') or (si='1') then begin
           SourceData^.Data[Count]:=1;
          end else begin
           SourceData^.Data[Count]:=0;
          end;
          inc(Count);
         end;
         SetLength(SourceData^.Data,Count);
         break;
        end else if (PassIndex=0) and (XMLTag.Name='float_array') then begin
         GetMem(SourceData,SizeOf(TLibrarySourceData));
         FillChar(SourceData^,SizeOf(TLibrarySourceData),AnsiChar(#0));
         SourceData^.Next:=LibrarySourceDatas;
         LibrarySourceDatas:=SourceData;
         SourceData^.ID:=XMLTag.GetParameter('id');
         LibrarySourceDatasIDStringHashMap.Add(SourceData^.ID,SourceData);
         SourceData^.SourceType:=lsTpvFloat;
         Source^.SourceDatas.Add(SourceData);
         s:=ParseText(XMLTag);
         Count:=0;
         i:=1;
         while i<=length(s) do begin
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          j:=i;
          while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if j<i then begin
           si:=copy(s,j,i-j);
          end else begin
           si:='';
          end;
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if (Count+1)>length(SourceData^.Data) then begin
           SetLength(SourceData^.Data,(Count+1)*2);
          end;
          SourceData^.Data[Count]:=StrToDouble(MyTrim(si),0.0);
          inc(Count);
         end;
         SetLength(SourceData^.Data,Count);
         break;
        end else if (PassIndex=0) and (XMLTag.Name='int_array') then begin
         GetMem(SourceData,SizeOf(TLibrarySourceData));
         FillChar(SourceData^,SizeOf(TLibrarySourceData),AnsiChar(#0));
         SourceData^.Next:=LibrarySourceDatas;
         LibrarySourceDatas:=SourceData;
         SourceData^.ID:=XMLTag.GetParameter('id');
         LibrarySourceDatasIDStringHashMap.Add(SourceData^.ID,SourceData);
         SourceData^.SourceType:=lstINT;
         Source^.SourceDatas.Add(SourceData);
         s:=ParseText(XMLTag);
         Count:=0;
         i:=1;
         while i<=length(s) do begin
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          j:=i;
          while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if j<i then begin
           si:=copy(s,j,i-j);
          end else begin
           si:='';
          end;
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if (Count+1)>length(SourceData^.Data) then begin
           SetLength(SourceData^.Data,(Count+1)*2);
          end;
          SourceData^.Data[Count]:=MyStrToIntDef(MyTrim(si),0);
          inc(Count);
         end;
         SetLength(SourceData^.Data,Count);
         break;
        end else if (PassIndex=0) and (XMLTag.Name='IDREF_array') then begin
         GetMem(SourceData,SizeOf(TLibrarySourceData));
         FillChar(SourceData^,SizeOf(TLibrarySourceData),AnsiChar(#0));
         SourceData^.Next:=LibrarySourceDatas;
         LibrarySourceDatas:=SourceData;
         SourceData^.ID:=XMLTag.GetParameter('id');
         LibrarySourceDatasIDStringHashMap.Add(SourceData^.ID,SourceData);
         SourceData^.SourceType:=lstIDREF;
         Source^.SourceDatas.Add(SourceData);
         s:=ParseText(XMLTag);
         Count:=0;
         i:=1;
         while i<=length(s) do begin
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          j:=i;
          while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if j<i then begin
           si:=copy(s,j,i-j);
          end else begin
           si:='';
          end;
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if (Count+1)>length(SourceData^.Strings) then begin
           SetLength(SourceData^.Strings,(Count+1)*2);
          end;
          SourceData^.Strings[Count]:=si;
          inc(Count);
         end;
         SetLength(SourceData^.Strings,Count);
         break;
        end else if (PassIndex=0) and ((XMLTag.Name='Name_array') or (XMLTag.Name='name_array')) then begin
         GetMem(SourceData,SizeOf(TLibrarySourceData));
         FillChar(SourceData^,SizeOf(TLibrarySourceData),AnsiChar(#0));
         SourceData^.Next:=LibrarySourceDatas;
         LibrarySourceDatas:=SourceData;
         SourceData^.ID:=XMLTag.GetParameter('id');
         LibrarySourceDatasIDStringHashMap.Add(SourceData^.ID,SourceData);
         SourceData^.SourceType:=lstNAME;
         Source^.SourceDatas.Add(SourceData);
         s:=ParseText(XMLTag);
         Count:=0;
         i:=1;
         while i<=length(s) do begin
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          j:=i;
          while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if j<i then begin
           si:=copy(s,j,i-j);
          end else begin
           si:='';
          end;
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if (Count+1)>length(SourceData^.Strings) then begin
           SetLength(SourceData^.Strings,(Count+1)*2);
          end;
          SourceData^.Strings[Count]:=si;
          inc(Count);
         end;
         SetLength(SourceData^.Strings,Count);
         break;
        end else if (PassIndex=1) and (XMLTag.Name='technique_common') then begin
         ParseAccessorTag(XMLTag.FindTag('accessor'),@Source^.Accessor);
        end;
       end;
      end;
     end;
    end;
    result:=true;
   end;
  end;
 end;
 function ParseInputTag(ParentTag:TpvXMLTag;var Input:TInput):boolean;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   Input.Semantic:=ParentTag.GetParameter('semantic');
   Input.Source:=MyStringReplace(ParentTag.GetParameter('source',''),'#','',[rfReplaceAll]);
   Input.Set_:=MyStrToIntDef(ParentTag.GetParameter('set','-1'),-1);
   Input.Offset:=MyStrToIntDef(ParentTag.GetParameter('offset','0'),0);
   if (Input.Semantic='TEXCOORD') and (Input.Set_<0) then begin
    Input.Set_:=0;
   end;
   result:=true;
  end;
 end;
 function ParseVerticesTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex,Count:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     ID:ansistring;
     Vertices:PLibraryVertices;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TpvXMLTag(ParentTag).GetParameter('id','');
   if length(ID)>0 then begin
    GetMem(Vertices,SizeOf(TLibraryVertices));
    FillChar(Vertices^,SizeOf(TLibraryVertices),AnsiChar(#0));
    Vertices^.Next:=LibraryVerticeses;
    LibraryVerticeses:=Vertices;
    Vertices^.ID:=ID;
    LibraryVerticesesIDStringHashMap.Add(ID,Vertices);
    Count:=0;
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='input' then begin
        if (Count+1)>length(Vertices^.Inputs) then begin
         SetLength(Vertices^.Inputs,(Count+1)*2);
        end;
        ParseInputTag(XMLTag,Vertices^.Inputs[Count]);
        inc(Count);
       end;
      end;
     end;
    end;
    SetLength(Vertices^.Inputs,Count);
    result:=true;
   end;
  end;
 end;
 function ParseMeshTag(ParentTag:TpvXMLTag;Geometry:PLibraryGeometry):boolean;
 var PassIndex,XMLItemIndex,XMLSubItemIndex,MeshType,InputCount,IndicesCount,Count,i,j,
     TotalIndicesCount:TpvInt32;
     XMLItem,XMLSubItem:TpvXMLItem;
     XMLTag,XMLSubTag:TpvXMLTag;
     s,si:ansistring;
     Mesh:PLibraryGeometryMesh;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   MeshType:=mtNONE;
   IndicesCount:=0;
   for PassIndex:=0 to 2 do begin
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if (PassIndex=0) and (XMLTag.Name='source') then begin
        ParseSourceTag(XMLTag);
       end else if (PassIndex=1) and (XMLTag.Name='vertices') then begin
        ParseVerticesTag(XMLTag);
       end else if (PassIndex=2) and ((XMLTag.Name='triangles') or
                                      (XMLTag.Name='trifans') or
                                      (XMLTag.Name='tristrips') or
                                      (XMLTag.Name='polygons') or
                                      (XMLTag.Name='polylist') or
                                      (XMLTag.Name='lines') or
                                      (XMLTag.Name='linestrips')) then begin
        if XMLTag.Name='triangles' then begin
         MeshType:=mtTRIANGLES;
        end else if XMLTag.Name='trifans' then begin
         MeshType:=mtTRIFANS;
        end else if XMLTag.Name='tristrips' then begin
         MeshType:=mtTRIFANS;
        end else if XMLTag.Name='polygons' then begin
         MeshType:=mtPOLYGONS;
        end else if XMLTag.Name='polylist' then begin
         MeshType:=mtPOLYLIST;
        end else if XMLTag.Name='lines' then begin
         MeshType:=mtLINES;
        end else if XMLTag.Name='lines' then begin
         MeshType:=mtLINES;
        end else if XMLTag.Name='linestrips' then begin
         MeshType:=mtLINESTRIPS;
        end;
        if (Geometry^.CountMeshs+1)>length(Geometry^.Meshs) then begin
         SetLength(Geometry^.Meshs,(Geometry^.CountMeshs+1)*2);
        end;
        Mesh:=@Geometry^.Meshs[Geometry^.CountMeshs];
        inc(Geometry^.CountMeshs);
        Mesh^.MeshType:=MeshType;
        Mesh^.Material:=XMLTag.GetParameter('material');
        Mesh^.Count:=MyStrToIntDef(XMLTag.GetParameter('count'),0);
        InputCount:=0;
        TotalIndicesCount:=0;
        for XMLSubItemIndex:=0 to XMLTag.Items.Count-1 do begin
         XMLSubItem:=XMLTag.Items[XMLSubItemIndex];
         if assigned(XMLSubItem) then begin
          if XMLSubItem is TpvXMLTag then begin
           XMLSubTag:=TpvXMLTag(XMLSubItem);
           if XMLSubTag.Name='input' then begin
            if (InputCount+1)>length(Mesh^.Inputs) then begin
             SetLength(Mesh^.Inputs,(InputCount+1)*2);
            end;
            ParseInputTag(XMLSubTag,Mesh^.Inputs[InputCount]);
            inc(InputCount);
           end else if XMLSubTag.Name='vcount' then begin
            s:=ParseText(XMLSubTag);
            Count:=0;
            i:=1;
            while i<=length(s) do begin
             while (i<=length(s)) and (s[i] in [#0..#32]) do begin
              inc(i);
             end;
             j:=i;
             while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
              inc(i);
             end;
             if j<i then begin
              si:=copy(s,j,i-j);
             end else begin
              si:='';
             end;
             while (i<=length(s)) and (s[i] in [#0..#32]) do begin
              inc(i);
             end;
             if (Count+1)>length(Mesh^.VCounts) then begin
              SetLength(Mesh^.VCounts,(Count+1)*2);
             end;
             Mesh^.VCounts[Count]:=MyStrToIntDef(MyTrim(si),0);
             inc(Count);
            end;
            SetLength(Mesh^.VCounts,Count);
           end else if XMLSubTag.Name='p' then begin
            if (IndicesCount+1)>length(Mesh^.Indices) then begin
             SetLength(Mesh^.Indices,(IndicesCount+1)*2);
            end;
            s:=ParseText(XMLSubTag);
            Count:=0;
            i:=1;
            while i<=length(s) do begin
             while (i<=length(s)) and (s[i] in [#0..#32]) do begin
              inc(i);
             end;
             j:=i;
             while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
              inc(i);
             end;
             if j<i then begin
              si:=copy(s,j,i-j);
             end else begin
              si:='';
             end;
             while (i<=length(s)) and (s[i] in [#0..#32]) do begin
              inc(i);
             end;
             if (Count+1)>length(Mesh^.Indices[IndicesCount]) then begin
              SetLength(Mesh^.Indices[IndicesCount],(Count+1)*2);
             end;
             Mesh^.Indices[IndicesCount,Count]:=MyStrToIntDef(MyTrim(si),0);
             inc(Count);
            end;
            SetLength(Mesh^.Indices[IndicesCount],Count);
            inc(IndicesCount);
            inc(TotalIndicesCount,Count);
           end;
          end;
         end;
        end;
        if TotalIndicesCount>0 then begin
        end;
        SetLength(Mesh^.Inputs,InputCount);
        SetLength(Mesh^.Indices,IndicesCount);
       end;
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseGeometryTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     ID:ansistring;
     Geometry:PLibraryGeometry;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TpvXMLTag(ParentTag).GetParameter('id','');
   if length(ID)>0 then begin
    if ID='MCMToesSmallCurlLeft01-Genesis2Female' then begin
     if ID='MCMToesSmallCurlLeft01-Genesis2Female' then begin
     end;
    end;
    GetMem(Geometry,SizeOf(TLibraryGeometry));
    FillChar(Geometry^,SizeOf(TLibraryGeometry),AnsiChar(#0));
    Geometry^.Next:=LibraryGeometries;
    LibraryGeometries:=Geometry;
    Geometry^.ID:=ID;
    LibraryGeometriesIDStringHashMap.Add(ID,Geometry);
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='mesh' then begin
        ParseMeshTag(XMLTag,Geometry);
       end;
      end;
     end;
    end;
    SetLength(Geometry^.Meshs,Geometry^.CountMeshs);
    result:=true;
   end;
  end;
 end;
 function ParseLibraryGeometriesTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='geometry' then begin
       ParseGeometryTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseCameraTag(ParentTag:TpvXMLTag):boolean;
 var XMLSubItemIndex:TpvInt32;
     XMLSubItem:TpvXMLItem;
     XMLTag,XMLSubTag,XMLSubSubTag:TpvXMLTag;
     ID,Name:ansistring;
     Camera:PLibraryCamera;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TpvXMLTag(ParentTag).GetParameter('id','');
   Name:=TpvXMLTag(ParentTag).GetParameter('name','');
   if length(ID)>0 then begin
    GetMem(Camera,SizeOf(TLibraryCamera));
    FillChar(Camera^,SizeOf(TLibraryCamera),AnsiChar(#0));
    Camera^.Next:=LibraryCameras;
    LibraryCameras:=Camera;
    Camera^.ID:=ID;
    Camera^.Name:=Name;
    Camera^.Camera.Name:=Name;
    LibraryCamerasIDStringHashMap.Add(ID,Camera);
    XMLTag:=ParentTag.FindTag('optics');
    if assigned(XMLTag) then begin
     XMLTag:=XMLTag.FindTag('technique_common');
     if assigned(XMLTag) then begin
      for XMLSubItemIndex:=0 to XMLTag.Items.Count-1 do begin
       XMLSubItem:=XMLTag.Items[XMLSubItemIndex];
       if assigned(XMLSubItem) then begin
        if XMLSubItem is TpvXMLTag then begin
         XMLSubTag:=TpvXMLTag(XMLSubItem);
         if XMLSubTag.Name='perspective' then begin
          Camera^.Camera.CameraType:=dlctPERSPECTIVE;
          Camera^.Camera.XFov:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('xfov'))),0.0);
          Camera^.Camera.YFov:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('yfov'))),0.0);
          Camera^.Camera.ZNear:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('znear'))),0.0);
          Camera^.Camera.ZFar:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('zfar'))),0.0);
          Camera^.Camera.AspectRatio:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('aspect_ratio'))),0.0);
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('xfov');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDXFov:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('yfov');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDYFov:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('znear');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDZNear:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('zfar');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDZFar:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('aspect_ratio');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDAspectRatio:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          break;
         end else if XMLSubTag.Name='orthographic' then begin
          Camera^.Camera.CameraType:=dlctORTHOGRAPHIC;
          Camera^.Camera.XMag:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('xmag'))),0.0);
          Camera^.Camera.YMag:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('ymag'))),0.0);
          Camera^.Camera.ZNear:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('znear'))),0.0);
          Camera^.Camera.ZFar:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('zfar'))),0.0);
          Camera^.Camera.AspectRatio:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('aspect_ratio'))),0.0);
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('xmag');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDXMag:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('ymag');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDYMag:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('znear');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDZNear:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('zfar');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDZFar:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('aspect_ratio');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDAspectRatio:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          break;
         end;
        end;
       end;
      end;
     end;
    end;
    result:=true;
   end;
  end;
 end;
 function ParseLibraryCamerasTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='camera' then begin
       ParseCameraTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseLightTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex,XMLSubItemIndex:TpvInt32;
     XMLItem,XMLSubItem:TpvXMLItem;
     XMLTag,XMLSubTag:TpvXMLTag;
     ID,Name:ansistring;
     Light:PLibraryLight;
     s:ansistring;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TpvXMLTag(ParentTag).GetParameter('id','');
   Name:=TpvXMLTag(ParentTag).GetParameter('name','');
   if length(ID)>0 then begin
    GetMem(Light,SizeOf(TLibraryLight));
    FillChar(Light^,SizeOf(TLibraryLight),AnsiChar(#0));
    Light^.Next:=LibraryLights;
    LibraryLights:=Light;
    Light^.ID:=ID;
    Light^.Name:=Name;
    LibraryLightsIDStringHashMap.Add(ID,Light);
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='technique_common' then begin
        for XMLSubItemIndex:=0 to XMLTag.Items.Count-1 do begin
         XMLSubItem:=XMLTag.Items[XMLSubItemIndex];
         if assigned(XMLSubItem) then begin
          if XMLSubItem is TpvXMLTag then begin
           XMLSubTag:=TpvXMLTag(XMLSubItem);
           if (XMLSubTag.Name='ambient') or
              (XMLSubTag.Name='directional') or
              (XMLSubTag.Name='point') or
              (XMLSubTag.Name='spot') then begin
            if XMLSubTag.Name='ambient' then begin
             Light^.LightType:=ltAMBIENT;
            end else if XMLSubTag.Name='directional' then begin
             Light^.LightType:=ltDIRECTIONAL;
            end else if XMLSubTag.Name='point' then begin
             Light^.LightType:=ltPOINT;
            end else if XMLSubTag.Name='spot' then begin
             Light^.LightType:=ltSPOT;
            end;
            s:=MyTrim(ParseText(XMLSubTag.FindTag('color')));
            Light^.Color.r:=StrToDouble(GetToken(s),1.0);
            Light^.Color.g:=StrToDouble(GetToken(s),1.0);
            Light^.Color.b:=StrToDouble(GetToken(s),1.0);
            Light^.ConstantAttenuation:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('constant_attenuation'))),1.0);
            Light^.LinearAttenuation:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('linear_attenuation'))),0.0);
            Light^.QuadraticAttenuation:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('quadratic_attenuation'))),0.0);
            if Light^.LightType=ltSPOT then begin
             Light^.FallOffAngle:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('falloff_angle'))),180.0);
             Light^.FallOffExponent:=StrToDouble(MyTrim(ParseText(XMLSubTag.FindTag('falloff_exponent'))),0.0);
            end else begin
             Light^.FallOffAngle:=180.0;
             Light^.FallOffExponent:=0.0;
            end;
            break;
           end;
          end;
         end;
        end;
       end;
      end;
     end;
    end;
    result:=true;
   end;
  end;
 end;
 function ParseLibraryLightsTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='light' then begin
       ParseLightTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseSourceInput(ParentTag:TpvXMLTag;var SourceInput:TSourceInput):boolean;
 var XMLItemIndex,Count,i,j:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     s,si:ansistring;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   Count:=0;
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='input' then begin
       if (Count+1)>length(SourceInput.Inputs) then begin
        SetLength(SourceInput.Inputs,(Count+1)*2);
       end;
       ParseInputTag(XMLTag,SourceInput.Inputs[Count]);
       inc(Count);
      end;
     end;
    end;
   end;
   SetLength(SourceInput.Inputs,Count);
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='vcount' then begin
       s:=ParseText(XMLTag);
       Count:=0;
       i:=1;
       while i<=length(s) do begin
        while (i<=length(s)) and (s[i] in [#0..#32]) do begin
         inc(i);
        end;
        j:=i;
        while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
         inc(i);
        end;
        if j<i then begin
         si:=copy(s,j,i-j);
        end else begin
         si:='';
        end;
        while (i<=length(s)) and (s[i] in [#0..#32]) do begin
         inc(i);
        end;
        if (Count+1)>length(SourceInput.VCounts) then begin
         SetLength(SourceInput.VCounts,(Count+1)*2);
        end;
        SourceInput.VCounts[Count]:=MyStrToIntDef(MyTrim(si),0);
        inc(Count);
       end;
       SetLength(SourceInput.VCounts,Count);
      end else if XMLTag.Name='v' then begin
       s:=ParseText(XMLTag);
       Count:=0;
       i:=1;
       while i<=length(s) do begin
        while (i<=length(s)) and (s[i] in [#0..#32]) do begin
         inc(i);
        end;
        j:=i;
        while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
         inc(i);
        end;
        if j<i then begin
         si:=copy(s,j,i-j);
        end else begin
         si:='';
        end;
        while (i<=length(s)) and (s[i] in [#0..#32]) do begin
         inc(i);
        end;
        if (Count+1)>length(SourceInput.V) then begin
         SetLength(SourceInput.V,(Count+1)*2);
        end;
        SourceInput.V[Count]:=MyStrToIntDef(MyTrim(si),0);
        inc(Count);
       end;
       SetLength(SourceInput.V,Count);
      end else if XMLTag.Name='extra' then begin
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseControllerTag(ParentTag:TpvXMLTag):boolean;
  function ParseSkinTag(ParentTag:TpvXMLTag):PLibraryControllerSkin;
  var XMLItemIndex:TpvInt32;
      XMLItem:TpvXMLItem;
      XMLTag,JointsTag,VertexWeightsTag:TpvXMLTag;
      Source,s:ansistring;
      BindShapeMatrix:TpvMatrix4x4;
  begin
   result:=nil;
   if assigned(ParentTag) then begin
    Source:=MyStringReplace(ParentTag.GetParameter('source',''),'#','',[rfReplaceAll]);
    JointsTag:=nil;
    VertexWeightsTag:=nil;
    BindShapeMatrix:=TpvMatrix4x4.Identity;
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='bind_shape_matrix' then begin
        s:=MyTrim(ParseText(XMLTag));
        BindShapeMatrix[0,0]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[1,0]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[2,0]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[3,0]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[0,1]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[1,1]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[2,1]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[3,1]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[0,2]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[1,2]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[2,2]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[3,2]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[0,3]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[1,3]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[2,3]:=StrToDouble(GetToken(s),0.0);
        BindShapeMatrix[3,3]:=StrToDouble(GetToken(s),0.0);
       end else if XMLTag.Name='source' then begin
        ParseSourceTag(XMLTag);
       end else if XMLTag.Name='joints' then begin
        JointsTag:=XMLTag;
       end else if XMLTag.Name='vertex_weights' then begin
        VertexWeightsTag:=XMLTag;
       end else if XMLTag.Name='extra' then begin
       end;
      end;
     end;
    end;
    if assigned(JointsTag) and assigned(VertexWeightsTag) then begin
     GetMem(result,SizeOf(TLibraryControllerSkin));
     FillChar(result^,SizeOf(TLibraryControllerSkin),AnsiChar(#0));
     result^.Geometry:=LibraryGeometriesIDStringHashMap.Values[Source];
     result^.Controller:=LibraryControllersIDStringHashMap.Values[Source];
     result^.Source:=Source;
     result^.BindShapeMatrix:=BindShapeMatrix;
     ParseSourceInput(JointsTag,result^.Joints);
     ParseSourceInput(VertexWeightsTag,result^.VertexWeights);
     result^.Count:=MyStrToIntDef(VertexWeightsTag.GetParameter('count',''),0);
    end;
   end;
  end;
  function ParseMorphTag(ParentTag:TpvXMLTag):PLibraryControllerMorph;
  var XMLItemIndex:TpvInt32;
      XMLItem:TpvXMLItem;
      XMLTag,TargetsTag:TpvXMLTag;
      Source,Method:ansistring;
  begin
   result:=nil;
   if assigned(ParentTag) then begin
    Source:=MyStringReplace(ParentTag.GetParameter('source',''),'#','',[rfReplaceAll]);
    Method:=ParentTag.GetParameter('method','NORMALIZED');
    TargetsTag:=nil;
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='source' then begin
        ParseSourceTag(XMLTag);
       end else if XMLTag.Name='targets' then begin
        TargetsTag:=XMLTag;
       end;
      end;
     end;
    end;
    if assigned(TargetsTag) then begin
     GetMem(result,SizeOf(TLibraryControllerMorph));
     FillChar(result^,SizeOf(TLibraryControllerMorph),AnsiChar(#0));
     result^.Geometry:=LibraryGeometriesIDStringHashMap.Values[Source];
     result^.Controller:=LibraryControllersIDStringHashMap.Values[Source];
     result^.Source:=Source;
     result^.Method:=Method;
     ParseSourceInput(TargetsTag,result^.Targets);
    end;
   end;
  end;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     ID:ansistring;
     Controller:PLibraryController;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=ParentTag.GetParameter('id','');
   if length(ID)>0 then begin
    GetMem(Controller,SizeOf(TLibraryController));
    FillChar(Controller^,SizeOf(TLibraryController),AnsiChar(#0));
    Controller^.Next:=LibraryControllers;
    LibraryControllers:=Controller;
    Controller^.ID:=ID;
    Controller^.Name:=ParentTag.GetParameter('name','');
    Controller^.ControllerType:=ctNONE;
    Controller^.Geometry:=nil;
    LibraryControllersIDStringHashMap.Add(ID,Controller);
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='skin' then begin
        Controller^.ControllerType:=ctSKIN;
        Controller^.Skin:=ParseSkinTag(XMLTag);
        if assigned(Controller^.Skin) and assigned(Controller^.Skin^.Geometry) then begin
         Controller^.Geometry:=Controller^.Skin^.Geometry;
        end;
        break;
       end else if XMLTag.Name='morph' then begin
        Controller^.ControllerType:=ctMORPH;
        Controller^.Morph:=ParseMorphTag(XMLTag);
        if assigned(Controller^.Morph) and assigned(Controller^.Morph^.Geometry) then begin
         Controller^.Geometry:=Controller^.Morph^.Geometry;
        end;
        break;
       end;
      end;
     end;
    end;
    result:=true;
   end;
  end;
 end;
 function ParseLibraryControllersTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='controller' then begin
       ParseControllerTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseAnimationTag(ParentTag:TpvXMLTag;var LibraryAnimation:TLibraryAnimation):boolean;
 var XMLItemIndex,XMLSubItemIndex,i,j:TpvInt32;
     XMLItem,XMLSubItem:TpvXMLItem;
     XMLTag,XMLSubTag:TpvXMLTag;
     OtherLibraryAnimation:TLibraryAnimation;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='source' then begin
       ParseSourceTag(XMLTag);
      end;
     end;
    end;
   end;
   begin
    i:=0;
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='sampler' then begin
        if (i+1)>length(LibraryAnimation.Samplers) then begin
         SetLength(LibraryAnimation.Samplers,(i+1)*2);
        end;
        LibraryAnimation.Samplers[i].ID:=XMLTag.GetParameter('id','');
        j:=0;
        for XMLSubItemIndex:=0 to XMLTag.Items.Count-1 do begin
         XMLSubItem:=XMLTag.Items[XMLSubItemIndex];
         if assigned(XMLSubItem) then begin
          if XMLSubItem is TpvXMLTag then begin
           XMLSubTag:=TpvXMLTag(XMLSubItem);
           if XMLSubTag.Name='input' then begin
            if (j+1)>length(LibraryAnimation.Samplers[i].Inputs) then begin
             SetLength(LibraryAnimation.Samplers[i].Inputs,(j+1)*2);
            end;
            ParseInputTag(XMLSubTag,LibraryAnimation.Samplers[i].Inputs[j]);
            inc(j);
           end;
          end;
         end;
        end;
        SetLength(LibraryAnimation.Samplers[i].Inputs,j);
        inc(i);
       end;
      end;
     end;
    end;
    SetLength(LibraryAnimation.Samplers,i);
   end;
   begin
    i:=0;
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='channel' then begin
        if (i+1)>length(LibraryAnimation.Channels) then begin
         SetLength(LibraryAnimation.Channels,(i+1)*2);
        end;
        LibraryAnimation.Channels[i].Source:=MyStringReplace(XMLTag.GetParameter('source',''),'#','',[rfReplaceAll]);
        LibraryAnimation.Channels[i].Target:=XMLTag.GetParameter('target','');
        inc(i);
       end;
      end;
     end;
    end;
    SetLength(LibraryAnimation.Channels,i);
   end;
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='animation' then begin
       ParseAnimationTag(XMLTag,OtherLibraryAnimation);
       j:=length(LibraryAnimation.Samplers);
       SetLength(LibraryAnimation.Samplers,j+length(OtherLibraryAnimation.Samplers));
       for i:=0 to length(OtherLibraryAnimation.Samplers)-1 do begin
        LibraryAnimation.Samplers[i+j]:=OtherLibraryAnimation.Samplers[i];
       end;
       j:=length(LibraryAnimation.Channels);
       SetLength(LibraryAnimation.Channels,j+length(OtherLibraryAnimation.Channels));
       for i:=0 to length(OtherLibraryAnimation.Channels)-1 do begin
        LibraryAnimation.Channels[i+j]:=OtherLibraryAnimation.Channels[i];
       end;
       OtherLibraryAnimation.ID:='';
       OtherLibraryAnimation.Name:='';
       SetLength(OtherLibraryAnimation.Samplers,0);
       SetLength(OtherLibraryAnimation.Channels,0);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseLibraryAnimationsTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     LibraryAnimation:PLibraryAnimation;
     ID:ansistring;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='animation' then begin
       ID:=XMLTag.GetParameter('id','');
       GetMem(LibraryAnimation,SizeOf(TLibraryAnimation));
       FillChar(LibraryAnimation^,SizeOf(TLibraryAnimation),AnsiChar(#0));
       LibraryAnimation^.ID:=ID;
       LibraryAnimation^.Name:=XMLTag.GetParameter('name','');
       LibraryAnimation^.Next:=LibraryAnimations;
       LibraryAnimation^.Referenced:=false;
       LibraryAnimations:=LibraryAnimation;
       if length(ID)>0 then begin
        LibraryAnimationsIDStringHashMap.Add(ID,LibraryAnimation);
       end;
       LibraryAnimationList.Add(LibraryAnimation);
       ParseAnimationTag(XMLTag,LibraryAnimation^);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseAnimationClipTag(ParentTag:TpvXMLTag;var LibraryAnimationClip:TLibraryAnimationClip):boolean;
 var XMLItemIndex,XMLSubItemIndex,i,j:TpvInt32;
     XMLItem,XMLSubItem:TpvXMLItem;
     XMLTag,XMLSubTag:TpvXMLTag;
     LibraryAnimation:PLibraryAnimation;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='source' then begin
       ParseSourceTag(XMLTag);
      end;
     end;
    end;
   end;
   begin
    i:=0;
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='instance_animation' then begin
        LibraryAnimation:=LibraryAnimationsIDStringHashMap[MyStringReplace(XMLTag.GetParameter('url',''),'#','',[rfReplaceAll])];
        if assigned(LibraryAnimation) then begin
         if (i+1)>length(LibraryAnimationClip.Animations) then begin
          SetLength(LibraryAnimationClip.Animations,(i+1)*2);
         end;
         LibraryAnimationClip.Animations[i]:=LibraryAnimation;
         inc(i);
         LibraryAnimation^.Referenced:=true;
        end;
       end;
      end;
     end;
    end;
    SetLength(LibraryAnimationClip.Animations,i);
   end;
   result:=true;
  end;
 end;
 function ParseLibraryAnimationClipsTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     LibraryAnimationClip:PLibraryAnimationClip;
     ID:ansistring;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='animation_clip' then begin
       ID:=XMLTag.GetParameter('id','');
       GetMem(LibraryAnimationClip,SizeOf(TLibraryAnimationClip));
       FillChar(LibraryAnimationClip^,SizeOf(TLibraryAnimationClip),AnsiChar(#0));
       LibraryAnimationClip^.ID:=ID;
       LibraryAnimationClip^.Name:=XMLTag.GetParameter('name','');
       LibraryAnimationClip^.Next:=LibraryAnimationClips;
       LibraryAnimationClips:=LibraryAnimationClip;
       if length(ID)>0 then begin
        LibraryAnimationClipsIDStringHashMap.Add(ID,LibraryAnimationClip);
       end;
       LibraryAnimationClipList.Add(LibraryAnimationClip);
       ParseAnimationClipTag(XMLTag,LibraryAnimationClip^);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseNodeTag(ParentTag:TpvXMLTag):PLibraryNode;
 var XMLItemIndex{,XMLSubItemIndex,XMLSubSubItemIndex{,Count,SubCount}:TpvInt32;
     XMLItem{,XMLSubItem,XMLSubSubItem}:TpvXMLItem;
     XMLTag,XMLSubTag,XMLSubSubTag{,BindMaterialTag,TechniqueCommonTag}:TpvXMLTag;
     ID,Name,s:ansistring;
     Node,Item:PLibraryNode;
     Vector3,LookAtOrigin,LookAtDest,LookAtUp,SkewA,SkewB:TpvVector3;
     Angle,SkewAngle:TpvFloat;
  procedure CreateItem(NodeType:TpvInt32);
  begin
   GetMem(Item,SizeOf(TLibraryNode));
   FillChar(Item^,SizeOf(TLibraryNode),AnsiChar(#0));
   Item^.Next:=LibraryNodes;
   LibraryNodes:=Item;
   Item^.ID:=XMLTag.GetParameter('id','');
   Item^.SID:=XMLTag.GetParameter('sid','');
   Item^.Name:=XMLTag.GetParameter('name','');
   Item^.NodeType_:=XMLTag.GetParameter('type','');
   Item^.NodeType:=NodeType;
   Item^.Visible:=true;
   LibraryNodesIDStringHashMap.Add(Item^.ID,Item);
  end;
  procedure ParseInstanceMaterials;
  var XMLSubItemIndex,XMLSubSubItemIndex,Count,SubCount:TpvInt32;
      XMLSubItem,XMLSubSubItem:TpvXMLItem;
      XMLSubTag,XMLSubSubTag,BindMaterialTag,TechniqueCommonTag:TpvXMLTag;
  begin
   BindMaterialTag:=XMLTag.FindTag('bind_material');
   if assigned(BindMaterialTag) then begin
    TechniqueCommonTag:=BindMaterialTag.FindTag('technique_common');
    if not assigned(TechniqueCommonTag) then begin
     TechniqueCommonTag:=BindMaterialTag;
    end;
    Count:=0;
    for XMLSubItemIndex:=0 to TechniqueCommonTag.Items.Count-1 do begin
     XMLSubItem:=TechniqueCommonTag.Items[XMLSubItemIndex];
     if assigned(XMLSubItem) then begin
      if XMLSubItem is TpvXMLTag then begin
       XMLSubTag:=TpvXMLTag(XMLSubItem);
       if XMLSubTag.Name='instance_material' then begin
        if (Count+1)>length(Item^.InstanceMaterials) then begin
         SetLength(Item^.InstanceMaterials,(Count+1)*2);
        end;
        Item^.InstanceMaterials[Count].Symbol:=XMLSubTag.GetParameter('symbol');
        Item^.InstanceMaterials[Count].Target:=MyStringReplace(XMLSubTag.GetParameter('target'),'#','',[rfReplaceAll]);
        Item^.InstanceMaterials[Count].TexCoordSets:=nil;
        SubCount:=0;
        for XMLSubSubItemIndex:=0 to XMLSubTag.Items.Count-1 do begin
         XMLSubSubItem:=TechniqueCommonTag.Items[XMLSubSubItemIndex];
         if assigned(XMLSubSubItem) then begin
          if XMLSubSubItem is TpvXMLTag then begin
           XMLSubSubTag:=TpvXMLTag(XMLSubSubItem);
           if XMLSubSubTag.Name='bind_vertex_input' then begin
            if XMLSubSubTag.GetParameter('input_semantic')='TEXCOORD' then begin
             if (SubCount+1)>length(Item^.InstanceMaterials[Count].TexCoordSets) then begin
              SetLength(Item^.InstanceMaterials[Count].TexCoordSets,(SubCount+1)*2);
             end;
             Item^.InstanceMaterials[Count].TexCoordSets[SubCount].Semantic:=XMLSubSubTag.GetParameter('semantic');
             Item^.InstanceMaterials[Count].TexCoordSets[SubCount].InputSet:=MyStrToIntDef(XMLSubSubTag.GetParameter('input_set'),0);
             inc(SubCount);
            end;
           end;
          end;
         end;
        end;
        if SubCount=0 then begin
         if (SubCount+1)>length(Item^.InstanceMaterials[Count].TexCoordSets) then begin
          SetLength(Item^.InstanceMaterials[Count].TexCoordSets,(SubCount+1)*2);
         end;
         Item^.InstanceMaterials[Count].TexCoordSets[SubCount].Semantic:='UVSET0';
         Item^.InstanceMaterials[Count].TexCoordSets[SubCount].InputSet:=0;
         inc(SubCount);
        end;
        SetLength(Item^.InstanceMaterials[Count].TexCoordSets,SubCount);
        inc(Count);
       end;
      end;
     end;
    end;
    SetLength(Item^.InstanceMaterials,Count);
   end;
  end;
 begin
  result:=nil;
  if assigned(ParentTag) then begin
   ID:=TpvXMLTag(ParentTag).GetParameter('id','');
   Name:=TpvXMLTag(ParentTag).GetParameter('name','');
   if length(ID)>0 then begin
    GetMem(Node,SizeOf(TLibraryNode));
    FillChar(Node^,SizeOf(TLibraryNode),AnsiChar(#0));
    Node^.Next:=LibraryNodes;
    LibraryNodes:=Node;
    Node^.ID:=ID;
    Node^.SID:=ParentTag.GetParameter('sid','');
    Node^.Name:=Name;
    Node^.NodeType_:=ParentTag.GetParameter('type','node');
    Node^.IsJoint:=MyLowerCase(Node^.NodeType_)='joint';
    Node^.Visible:=true;
    Node^.Children:=TList.Create;
    Node^.NodeType:=ntNODE;
    LibraryNodesIDStringHashMap.Add(ID,Node);
    result:=Node;
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='node' then begin
        Item:=ParseNodeTag(XMLTag);
       end else if XMLTag.Name='rotate' then begin
        CreateItem(ntROTATE);
        s:=MyTrim(ParseText(XMLTag));
        Vector3.x:=StrToDouble(GetToken(s),0.0);
        Vector3.y:=StrToDouble(GetToken(s),0.0);
        Vector3.z:=StrToDouble(GetToken(s),0.0);
        Angle:=StrToDouble(GetToken(s),0.0);
        Item^.RotateAxis:=Vector3;
        Item^.RotateAngle:=Angle;
       end else if XMLTag.Name='translate' then begin
        CreateItem(ntTRANSLATE);
        s:=MyTrim(ParseText(XMLTag));
        Vector3.x:=StrToDouble(GetToken(s),0.0);
        Vector3.y:=StrToDouble(GetToken(s),0.0);
        Vector3.z:=StrToDouble(GetToken(s),0.0);
        Item^.TranslateOffset:=Vector3;
       end else if XMLTag.Name='scale' then begin
        CreateItem(ntSCALE);
        s:=MyTrim(ParseText(XMLTag));
        Vector3.x:=StrToDouble(GetToken(s),0.0);
        Vector3.y:=StrToDouble(GetToken(s),0.0);
        Vector3.z:=StrToDouble(GetToken(s),0.0);
        Item^.Scale:=Vector3;
       end else if XMLTag.Name='matrix' then begin
        CreateItem(ntMATRIX);
        s:=MyTrim(ParseText(XMLTag));
        Item^.Matrix[0,0]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[1,0]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[2,0]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[3,0]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[0,1]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[1,1]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[2,1]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[3,1]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[0,2]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[1,2]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[2,2]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[3,2]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[0,3]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[1,3]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[2,3]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[3,3]:=StrToDouble(GetToken(s),0.0);
       end else if XMLTag.Name='lookat' then begin
        CreateItem(ntLOOKAT);
        s:=MyTrim(ParseText(XMLTag));
        LookAtOrigin.x:=StrToDouble(GetToken(s),0.0);
        LookAtOrigin.y:=StrToDouble(GetToken(s),0.0);
        LookAtOrigin.z:=StrToDouble(GetToken(s),0.0);
        LookAtDest.x:=StrToDouble(GetToken(s),0.0);
        LookAtDest.y:=StrToDouble(GetToken(s),0.0);
        LookAtDest.z:=StrToDouble(GetToken(s),0.0);
        LookAtUp.x:=StrToDouble(GetToken(s),0.0);
        LookAtUp.y:=StrToDouble(GetToken(s),0.0);
        LookAtUp.z:=StrToDouble(GetToken(s),0.0);
        Item^.LookAtOrigin:=LookAtOrigin;
        Item^.LookAtDest:=LookAtDest;
        Item^.LookAtUp:=LookAtUp;
       end else if XMLTag.Name='skew' then begin
        CreateItem(ntSKEW);
        s:=MyTrim(ParseText(XMLTag));
        SkewAngle:=StrToDouble(GetToken(s),0.0);
        SkewA.x:=StrToDouble(GetToken(s),0.0);
        SkewA.y:=StrToDouble(GetToken(s),1.0);
        SkewA.z:=StrToDouble(GetToken(s),0.0);
        SkewB.x:=StrToDouble(GetToken(s),1.0);
        SkewB.y:=StrToDouble(GetToken(s),0.0);
        SkewB.z:=StrToDouble(GetToken(s),0.0);
        Item^.SkewAngle:=SkewAngle;
        Item^.SkewA:=SkewA;
        Item^.SkewB:=SkewB;
       end else if XMLTag.Name='extra' then begin
        CreateItem(ntEXTRA);
        XMLSubTag:=XMLTag.FindTag('technique');
        if assigned(XMLSubTag) then begin
         if XMLSubTag.GetParameter('profile','')='OpenCOLLADAMaya' then begin
          XMLSubSubTag:=XMLSubTag.FindTag('visibility');
          if assigned(XMLSubSubTag) then begin
           if trim(ParseText(XMLSubSubTag))='0' then begin
            Node^.Visible:=false;
           end;
          end;
         end;
        end;
       end else if XMLTag.Name='instance_camera' then begin
        CreateItem(ntINSTANCECAMERA);
        Item^.InstanceCamera:=LibraryCamerasIDStringHashMap.Values[MyStringReplace(XMLTag.GetParameter('url',''),'#','',[rfReplaceAll])];
       end else if XMLTag.Name='instance_light' then begin
        CreateItem(ntINSTANCELIGHT);
        Item^.InstanceLight:=LibraryLightsIDStringHashMap.Values[MyStringReplace(XMLTag.GetParameter('url',''),'#','',[rfReplaceAll])];
       end else if XMLTag.Name='instance_controller' then begin
        CreateItem(ntINSTANCECONTROLLER);
        Item^.InstanceController:=LibraryControllersIDStringHashMap.Values[MyStringReplace(XMLTag.GetParameter('url',''),'#','',[rfReplaceAll])];
        ParseInstanceMaterials;
       end else if XMLTag.Name='instance_geometry' then begin
        CreateItem(ntINSTANCEGEOMETRY);
        Item^.InstanceGeometry:=LibraryGeometriesIDStringHashMap.Values[MyStringReplace(XMLTag.GetParameter('url',''),'#','',[rfReplaceAll])];
        ParseInstanceMaterials;
       end else if XMLTag.Name='instance_node' then begin
        CreateItem(ntINSTANCENODE);
        Item^.InstanceNode:=MyStringReplace(XMLTag.GetParameter('url',''),'#','',[rfReplaceAll]);
       end else begin
        Item:=nil;
       end;
       if assigned(Item) then begin
        Node^.Children.Add(Item);
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 function ParseVisualSceneTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     ID:ansistring;
     VisualScene:PLibraryVisualScene;
     Item:PLibraryNode;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TpvXMLTag(ParentTag).GetParameter('id','');
   if length(ID)>=0 then begin
    GetMem(VisualScene,SizeOf(TLibraryVisualScene));
    FillChar(VisualScene^,SizeOf(TLibraryVisualScene),AnsiChar(#0));
    VisualScene^.Next:=LibraryVisualScenes;
    LibraryVisualScenes:=VisualScene;
    VisualScene^.ID:=ID;
    VisualScene^.Name:=TpvXMLTag(ParentTag).GetParameter('name','');
    VisualScene^.Items:=TList.Create;
    LibraryVisualScenesIDStringHashMap.Add(ID,VisualScene);
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if XMLTag.Name='node' then begin
        Item:=ParseNodeTag(XMLTag);
        if assigned(Item) then begin
         VisualScene^.Items.Add(Item);
        end;
       end;
      end;
     end;
    end;
    result:=true;
   end;
  end;
 end;
 function ParseLibraryNodesTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='node' then begin
       ParseNodeTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseLibraryVisualScenesTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='visual_scene' then begin
       ParseVisualSceneTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseInstanceVisualSceneTag(ParentTag:TpvXMLTag):boolean;
 var URL:ansistring;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   URL:=MyStringReplace(ParentTag.GetParameter('url','#visual_scene0'),'#','',[rfReplaceAll]);
   MainLibraryVisualScene:=LibraryVisualScenesIDStringHashMap.Values[URL];
   result:=true;
  end;
 end;
 function ParseSceneTag(ParentTag:TpvXMLTag):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='instance_visual_scene' then begin
       ParseInstanceVisualSceneTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseCOLLADATag(ParentTag:TpvXMLTag):boolean;
 var PassIndex,XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
     Material:PLibraryMaterial;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   COLLADAVersion:=ParentTag.GetParameter('version',COLLADAVersion);
   for PassIndex:=0 to 12 do begin
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TpvXMLTag then begin
       XMLTag:=TpvXMLTag(XMLItem);
       if (PassIndex=0) and (XMLTag.Name='asset') then begin
        ParseAssetTag(XMLTag);
       end else if (PassIndex=1) and (XMLTag.Name='library_images') then begin
        ParseLibraryImagesTag(XMLTag);
       end else if (PassIndex=2) and (XMLTag.Name='library_materials') then begin
        ParseLibraryMaterialsTag(XMLTag);
       end else if (PassIndex=3) and (XMLTag.Name='library_effects') then begin
        ParseLibraryEffectsTag(XMLTag);
       end else if (PassIndex=4) and (XMLTag.Name='library_geometries') then begin
        ParseLibraryGeometriesTag(XMLTag);
       end else if (PassIndex=5) and (XMLTag.Name='library_cameras') then begin
        ParseLibraryCamerasTag(XMLTag);
       end else if (PassIndex=6) and (XMLTag.Name='library_lights') then begin
        ParseLibraryLightsTag(XMLTag);
       end else if (PassIndex=7) and (XMLTag.Name='library_controllers') then begin
        ParseLibraryControllersTag(XMLTag);
       end else if (PassIndex=8) and (XMLTag.Name='library_animations') then begin
        ParseLibraryAnimationsTag(XMLTag);
       end else if (PassIndex=9) and (XMLTag.Name='library_animation_clips') then begin
        ParseLibraryAnimationClipsTag(XMLTag);
       end else if (PassIndex=10) and (XMLTag.Name='library_nodes') then begin
        ParseLibraryNodesTag(XMLTag);
       end else if (PassIndex=11) and (XMLTag.Name='library_visual_scenes') then begin
        ParseLibraryVisualScenesTag(XMLTag);
       end else if (PassIndex=12) and (XMLTag.Name='scene') then begin
        ParseSceneTag(XMLTag);
       end;
      end;
     end;
    end;
    case PassIndex of
     3:begin
      Material:=LibraryMaterials;
      while assigned(Material) do begin
       Material^.Effect:=LibraryEffectsIDStringHashMap.Values[Material^.EffectURL];
       Material:=Material^.Next;
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseRoot(ParentItem:TpvXMLItem):boolean;
 var XMLItemIndex:TpvInt32;
     XMLItem:TpvXMLItem;
     XMLTag:TpvXMLTag;
 begin
  result:=false;
  if assigned(ParentItem) then begin
   for XMLItemIndex:=0 to ParentItem.Items.Count-1 do begin
    XMLItem:=ParentItem.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TpvXMLTag then begin
      XMLTag:=TpvXMLTag(XMLItem);
      if XMLTag.Name='COLLADA' then begin
       ParseCOLLADATag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 procedure ConvertMaterials;
 var LibraryMaterial:PLibraryMaterial;
     Material:TpvDAEMaterial;
 begin
  LibraryMaterial:=LibraryMaterials;
  while assigned(LibraryMaterial) do begin
   if assigned(LibraryMaterial^.Effect) then begin
    Material:=TpvDAEMaterial.Create;
    LibraryMaterial^.Index:=Materials.Add(Material);
    Material.Name:=LibraryMaterial^.Name;
    Material.ShadingType:=LibraryMaterial^.Effect^.ShadingType;
    Material.Ambient:=LibraryMaterial^.Effect^.Ambient;
    Material.Diffuse:=LibraryMaterial^.Effect^.Diffuse;
    Material.Emission:=LibraryMaterial^.Effect^.Emission;
    Material.Specular:=LibraryMaterial^.Effect^.Specular;
    Material.Transparent:=LibraryMaterial^.Effect^.Transparent;
    Material.Shininess:=LibraryMaterial^.Effect^.Shininess;
    Material.Reflectivity:=LibraryMaterial^.Effect^.Reflectivity;
    Material.IndexOfRefraction:=LibraryMaterial^.Effect^.IndexOfRefraction;
    Material.Transparency:=LibraryMaterial^.Effect^.Transparency;
   end;
   LibraryMaterial:=LibraryMaterial^.Next;
  end;
 end;
 procedure ConvertContent;
 const stPOSITION=0;
       stNORMAL=1;
       stTANGENT=2;
       stBITANGENT=3;
       stTEXCOORD=4;
       stCOLOR=5;
 type TVectorArray=record
       Vectors:array of TpvVector4;
       Count:TpvInt32;
      end;
      TpvFloatArray=record
       Floats:array of TpvFloat;
       Count:TpvInt32;
       Stride:TpvInt32;
       Params:TpvInt32;
      end;
      TNameArray=record
       Names:array of ansistring;
       Count:TpvInt32;
      end;
      TMatrixArray=record
       Matrices:array of TpvMatrix4x4;
       Count:TpvInt32;
      end;
 var VisualScene:TpvDAEVisualScene;
     Animation:TpvDAEAnimation;
  procedure ConvertVectorSource(Source:PLibrarySource;var Target:TVectorArray;SourceType:TpvInt32);
  var Index,CountParams,Offset,Stride,DataSize,DataIndex,DataCount:TpvInt32;
      Mapping:array[0..3] of TpvInt32;
      Param:PLibrarySourceAccessorParam;
      SourceData:PLibrarySourceData;
      v:PpvVector4;
  begin
   if assigned(Source) then begin
    Mapping[0]:=-1;
    Mapping[1]:=-1;
    Mapping[2]:=-1;
    Mapping[3]:=-1;
    CountParams:=length(Source^.Accessor.Params);
    Offset:=Source^.Accessor.Offset;
    if Offset>0 then begin
    end;
    Stride:=Source^.Accessor.Stride;
    if Stride>0 then begin
     if CountParams>0 then begin
      for Index:=0 to CountParams-1 do begin
       Param:=@Source^.Accessor.Params[Index];
       if Param^.ParamType in [aptINT,apTpvFloat] then begin
        if BadAccessor and (length(Param^.ParamName)=0) then begin
         if (Index>=0) and (Index<=3) then begin
          Mapping[Index]:=Index;
         end;
        end else if ((SourceType in [stPOSITION,stNORMAL,stTANGENT,stBITANGENT]) and (Param^.ParamName='X')) or
                    ((SourceType in [stTEXCOORD]) and ((Param^.ParamName='X') or (Param^.ParamName='U') or (Param^.ParamName='S'))) or
                    ((SourceType in [stCOLOR]) and ((Param^.ParamName='X') or (Param^.ParamName='R'))) then begin
         Mapping[0]:=Index;
        end else if ((SourceType in [stPOSITION,stNORMAL,stTANGENT,stBITANGENT]) and (Param^.ParamName='Y')) or
                    ((SourceType in [stTEXCOORD]) and ((Param^.ParamName='Y') or (Param^.ParamName='V') or (Param^.ParamName='T'))) or
                    ((SourceType in [stCOLOR]) and ((Param^.ParamName='Y') or (Param^.ParamName='G'))) then begin
         Mapping[1]:=Index;
        end else if ((SourceType in [stPOSITION,stNORMAL,stTANGENT,stBITANGENT]) and (Param^.ParamName='Z')) or
                    ((SourceType in [stTEXCOORD]) and ((Param^.ParamName='Z') or (Param^.ParamName='W') or (Param^.ParamName='R'))) or
                    ((SourceType in [stCOLOR]) and ((Param^.ParamName='Z') or (Param^.ParamName='B'))) then begin
         Mapping[2]:=Index;
        end else if ((SourceType in [stPOSITION,stNORMAL,stTANGENT,stBITANGENT]) and (Param^.ParamName='W')) or
                    ((SourceType in [stCOLOR]) and ((Param^.ParamName='W') or (Param^.ParamName='A'))) then begin
         Mapping[3]:=Index;
        end;
       end;
      end;
     end;
     SourceData:=LibrarySourceDatasIDStringHashMap.Values[Source^.Accessor.Source];
     if not assigned(SourceData) then begin
      if Source^.SourceDatas.Count>0 then begin
       SourceData:=Source^.SourceDatas.Items[0];
      end;
     end;
     if assigned(SourceData) and (SourceData^.SourceType in [lstBOOL,lstINT,lsTpvFloat]) then begin
      DataSize:=length(SourceData^.Data);
      DataCount:=DataSize div Stride;
      SetLength(Target.Vectors,DataCount);
      DataCount:=0;
      DataIndex:=0;
      while (DataIndex+(Stride-1))<DataSize do begin
       v:=@Target.Vectors[DataCount];
       for Index:=0 to 3 do begin
        if Mapping[Index]>=0 then begin
         v.RawComponents[Index]:=SourceData^.Data[DataIndex+Mapping[Index]];
        end else begin
         v.RawComponents[Index]:=0.0;
        end;
       end;
       inc(DataCount);
       inc(DataIndex,Stride);
      end;
      SetLength(Target.Vectors,DataCount);
      Target.Count:=DataCount;
     end;
    end;
   end;
  end;
  procedure ConverTpvFloatSource(Source:PLibrarySource;var Target:TpvFloatArray);
  var {Index,}CountParams,Offset,Stride,DataSize,DataIndex,DataCount:TpvInt32;
//     Param:PLibrarySourceAccessorParam;
      SourceData:PLibrarySourceData;
//      v:PVector4;
  begin
   if assigned(Source) then begin
    CountParams:=length(Source^.Accessor.Params);
    Offset:=Source^.Accessor.Offset;
    if Offset>0 then begin
    end;
    Stride:=Source^.Accessor.Stride;
    if (Stride>0) and (CountParams=1) and (Source^.Accessor.Params[0].ParamType=apTpvFloat) then begin
     SourceData:=LibrarySourceDatasIDStringHashMap.Values[Source^.Accessor.Source];
     if not assigned(SourceData) then begin
      if Source^.SourceDatas.Count>0 then begin
       SourceData:=Source^.SourceDatas.Items[0];
      end;
     end;
     if assigned(SourceData) and (SourceData^.SourceType in [lstBOOL,lstINT,lsTpvFloat]) then begin
      DataSize:=length(SourceData^.Data);
      DataCount:=DataSize div Stride;
      SetLength(Target.Floats,DataCount);
      DataCount:=0;
      DataIndex:=0;
      while (DataIndex+(Stride-1))<DataSize do begin
       Target.Floats[DataCount]:=SourceData^.Data[DataIndex];
       inc(DataCount);
       inc(DataIndex,Stride);
      end;
      SetLength(Target.Floats,DataCount);
      Target.Count:=DataCount;
     end;
    end;
   end;
  end;
  procedure ConvertMultipleFloatSource(Source:PLibrarySource;var Target:TpvFloatArray);
  var {Index,}CountParams,Offset,Stride,DataSize,DataIndex,DataCount:TpvInt32;
//     Param:PLibrarySourceAccessorParam;
      SourceData:PLibrarySourceData;
//      v:PVector4;
  begin
   if assigned(Source) then begin
    CountParams:=length(Source^.Accessor.Params);
    Offset:=Source^.Accessor.Offset;
    if Offset>0 then begin
    end;
    Stride:=Source^.Accessor.Stride;
    Target.Stride:=Stride;
    if (Stride>0) and (CountParams=1) and (Source^.Accessor.Params[0].ParamType in [apTpvFloat,apTpvFloat4X4]) then begin
     SourceData:=LibrarySourceDatasIDStringHashMap.Values[Source^.Accessor.Source];
     if not assigned(SourceData) then begin
      if Source^.SourceDatas.Count>0 then begin
       SourceData:=Source^.SourceDatas.Items[0];
      end;
     end;
     if assigned(SourceData) and (SourceData^.SourceType in [lstBOOL,lstINT,lsTpvFloat]) then begin
      DataSize:=length(SourceData^.Data);
      DataCount:=DataSize;
      SetLength(Target.Floats,DataCount);
      DataCount:=0;
      DataIndex:=0;
      if (Stride=16) and (Source^.Accessor.Params[0].ParamType=apTpvFloat4X4) then begin
       while DataIndex<DataSize do begin
        Target.Floats[DataCount]:=SourceData^.Data[DataIndex];
        inc(DataCount);
        inc(DataIndex);
       end;
       DataIndex:=0;
       while (DataIndex+15)<DataSize do begin
        PpvMatrix4x4(TpvPointer(@Target.Floats[DataIndex]))^:=PpvMatrix4x4(TpvPointer(@Target.Floats[DataIndex]))^.Transpose;
        inc(DataIndex,16);
       end;
      end else begin
       while DataIndex<DataSize do begin
        Target.Floats[DataCount]:=SourceData^.Data[DataIndex];
        inc(DataCount);
        inc(DataIndex);
       end;
      end;
      SetLength(Target.Floats,DataCount);
      Target.Count:=DataCount;
     end;
    end;
   end;
  end;
  procedure ConvertMultipleParamFloatSource(Source:PLibrarySource;var Target:TpvFloatArray);
  var {Index,}CountParams,Offset,Stride,DataSize,DataIndex,DataCount:TpvInt32;
//     Param:PLibrarySourceAccessorParam;
      SourceData:PLibrarySourceData;
//      v:PVector4;
  begin
   if assigned(Source) then begin
    CountParams:=length(Source^.Accessor.Params);
    Offset:=Source^.Accessor.Offset;
    if Offset>0 then begin
    end;
    Stride:=Source^.Accessor.Stride;
    Target.Stride:=Stride;
    Target.Params:=CountParams;
    if (Stride>0) and (CountParams>0) and (Source^.Accessor.Params[0].ParamType in [apTpvFloat,apTpvFloat4X4]) then begin
     SourceData:=LibrarySourceDatasIDStringHashMap.Values[Source^.Accessor.Source];
     if not assigned(SourceData) then begin
      if Source^.SourceDatas.Count>0 then begin
       SourceData:=Source^.SourceDatas.Items[0];
      end;
     end;
     if assigned(SourceData) and (SourceData^.SourceType in [lstBOOL,lstINT,lsTpvFloat]) then begin
      DataSize:=length(SourceData^.Data);
      DataCount:=DataSize;
      SetLength(Target.Floats,DataCount);
      DataCount:=0;
      DataIndex:=0;
      if (Stride=16) and (Source^.Accessor.Params[0].ParamType=apTpvFloat4X4) then begin
       while DataIndex<DataSize do begin
        Target.Floats[DataCount]:=SourceData^.Data[DataIndex];
        inc(DataCount);
        inc(DataIndex);
       end;
       DataIndex:=0;
       while (DataIndex+15)<DataSize do begin
        PpvMatrix4x4(TpvPointer(@Target.Floats[DataIndex]))^:=PpvMatrix4x4(TpvPointer(@Target.Floats[DataIndex]))^.Transpose;
        inc(DataIndex,16);
       end;
      end else begin
       while DataIndex<DataSize do begin
        Target.Floats[DataCount]:=SourceData^.Data[DataIndex];
        inc(DataCount);
        inc(DataIndex);
       end;
      end;
      SetLength(Target.Floats,DataCount);
      Target.Count:=DataCount;
     end;
    end;
   end;
  end;
  procedure ConvertNameSource(Source:PLibrarySource;var Target:TNameArray);
  var {Index,}CountParams,Offset,Stride,DataSize,DataIndex,DataCount:TpvInt32;
//      Param:PLibrarySourceAccessorParam;
      SourceData:PLibrarySourceData;
//      v:PVector4;
  begin
   if assigned(Source) then begin
    CountParams:=length(Source^.Accessor.Params);
    Offset:=Source^.Accessor.Offset;
    if Offset>0 then begin
    end;
    Stride:=Source^.Accessor.Stride;
    if (Stride>0) and (CountParams=1) and (Source^.Accessor.Params[0].ParamType in [aptIDREF,aptNAME]) then begin
     SourceData:=LibrarySourceDatasIDStringHashMap.Values[Source^.Accessor.Source];
     if not assigned(SourceData) then begin
      if Source^.SourceDatas.Count>0 then begin
       SourceData:=Source^.SourceDatas.Items[0];
      end;
     end;
     if assigned(SourceData) and (SourceData^.SourceType in [lstIDREF,lstNAME]) then begin
      DataSize:=length(SourceData^.Strings);
      DataCount:=DataSize div Stride;
      SetLength(Target.Names,DataCount);
      DataCount:=0;
      DataIndex:=0;
      while (DataIndex+(Stride-1))<DataSize do begin
       Target.Names[DataCount]:=SourceData^.Strings[DataIndex];
       inc(DataCount);
       inc(DataIndex,Stride);
      end;
      SetLength(Target.Names,DataCount);
      Target.Count:=DataCount;
     end;
    end;
   end;
  end;
  procedure ConvertMatrixSource(Source:PLibrarySource;var Target:TMatrixArray);
  var {Index,}CountParams,Offset,Stride,DataSize,DataIndex,DataCount:TpvInt32;
//      Param:PLibrarySourceAccessorParam;
      SourceData:PLibrarySourceData;
      m:PpvMatrix4x4;
  begin
   if assigned(Source) then begin
    CountParams:=length(Source^.Accessor.Params);
    Offset:=Source^.Accessor.Offset;
    if Offset>0 then begin
    end;
    Stride:=Source^.Accessor.Stride;
    if (Stride>0) and (CountParams=1) and (Source^.Accessor.Params[0].ParamType=apTpvFloat4x4) then begin
     SourceData:=LibrarySourceDatasIDStringHashMap.Values[Source^.Accessor.Source];
     if not assigned(SourceData) then begin
      if Source^.SourceDatas.Count>0 then begin
       SourceData:=Source^.SourceDatas.Items[0];
      end;
     end;
     if assigned(SourceData) and (SourceData^.SourceType in [lstBOOL,lstINT,lsTpvFloat]) and (Stride=16) then begin
      DataSize:=length(SourceData^.Data);
      DataCount:=DataSize div Stride;
      SetLength(Target.Matrices,DataCount);
      DataCount:=0;
      DataIndex:=0;
      while (DataIndex+(Stride-1))<DataSize do begin
       m:=@Target.Matrices[DataCount];
       m^[0,0]:=SourceData^.Data[DataIndex+0];
       m^[1,0]:=SourceData^.Data[DataIndex+1];
       m^[2,0]:=SourceData^.Data[DataIndex+2];
       m^[3,0]:=SourceData^.Data[DataIndex+3];
       m^[0,1]:=SourceData^.Data[DataIndex+4];
       m^[1,1]:=SourceData^.Data[DataIndex+5];
       m^[2,1]:=SourceData^.Data[DataIndex+6];
       m^[3,1]:=SourceData^.Data[DataIndex+7];
       m^[0,2]:=SourceData^.Data[DataIndex+8];
       m^[1,2]:=SourceData^.Data[DataIndex+9];
       m^[2,2]:=SourceData^.Data[DataIndex+10];
       m^[3,2]:=SourceData^.Data[DataIndex+11];
       m^[0,3]:=SourceData^.Data[DataIndex+12];
       m^[1,3]:=SourceData^.Data[DataIndex+13];
       m^[2,3]:=SourceData^.Data[DataIndex+14];
       m^[3,3]:=SourceData^.Data[DataIndex+15];
       inc(DataCount);
       inc(DataIndex,Stride);
      end;
      SetLength(Target.Matrices,DataCount);
      Target.Count:=DataCount;
     end;
    end;
   end;
  end;
  procedure ConvertNode(const ParentNode:TpvDAENode;const LibraryNode:PLibraryNode);
   function ConvertGeometry(const Node:TpvDAENode;const LibraryGeometry:PLibraryGeometry;const LibraryControllerMorph:PLibraryControllerMorph=nil;const LibraryControllerSkin:PLibraryControllerSkin=nil;const Child:boolean=false):TpvDAEGeometry;
   type PBlendVertex=^TBlendVertex;
        TBlendVertex=record
         BlendIndices:array[0..dlMAXBLENDWEIGHTS-1] of TpvInt32;
         BlendWeights:array[0..dlMAXBLENDWEIGHTS-1] of TpvFloat;
         Count:TpvInt32;
        end;
        TBlendVertices=array of TBlendVertex;
   var Index,InputIndex,SubInputIndex,TexcoordSetIndex:TpvInt32;
       NodeMatrix,RotationMatrix:TpvMatrix4x4;
       RemappedMaterials,RemappedInstanceMaterials:TpvDAEStringHashMap;
       InstanceMaterial:PInstanceMaterial;
       LibraryMaterial:PLibraryMaterial;
       LibraryGeometryMesh:PLibraryGeometryMesh;
       Positions,Normals,Tangents,Bitangents,Colors:TVectorArray;
       PositionOffset,NormalOffset,TangentOffset,BitangentOffset,ColorOffset,
       IndicesIndex,IndicesCount,CountOffsets,VCountIndex,
       VertexIndex,VCount,ItemIndex,IndicesMeshIndex,VerticesCount,VertexSubCount,
       ArrayIndex,BaseIndex,CountTexCoords,
       JointOffset,InverseBindMatrixOffset,WeightOffset,
       TargetIndex:TpvInt32;
       TexCoords:array[0..dlMAXTEXCOORDSETS-1] of TVectorArray;
       TexCoordOffsets:array[0..dlMAXTEXCOORDSETS-1] of TpvInt32;
       Input,SubInput:PInput;
       LibraryVertices:PLibraryVertices;
       LibrarySource:PLibrarySource;
       VerticesArray:TpvDAEVerticesArray;
       VertexIndicesArray:TpvDAEVertexIndicesArray;
       Mesh,OtherMesh:TpvDAEMesh;
       HasNormals,HasTangents:boolean;
       Weights:TpvFloatArray;
       Joints,Targets:TNameArray;
       BlendVertices:TBlendVertices;
       BlendVertex:PBlendVertex;
       Vertex:PpvDAEVertex;
       InverseBindMatrices:TMatrixArray;
       Geometry:TpvDAEGeometry;
       Sum:double;
   begin
    if assigned(LibraryGeometry) then begin
     result:=TpvDAEGeometry.Create;
     result.ParentNode:=Node;
     RemappedMaterials:=TpvDAEStringHashMap.Create;
     RemappedInstanceMaterials:=TpvDAEStringHashMap.Create;
     try
      for Index:=0 to length(LibraryNode^.InstanceMaterials)-1 do begin
       LibraryMaterial:=LibraryMaterialsIDStringHashMap.Values[LibraryNode^.InstanceMaterials[Index].Target];
       if assigned(LibraryMaterial) then begin
        RemappedMaterials.Add(LibraryNode^.InstanceMaterials[Index].Symbol,LibraryMaterial);
        RemappedInstanceMaterials.Add(LibraryNode^.InstanceMaterials[Index].Symbol,@LibraryNode^.InstanceMaterials[Index]);
       end;
      end;
      for Index:=0 to length(LibraryGeometry.Meshs)-1 do begin
       LibraryGeometryMesh:=@LibraryGeometry.Meshs[Index];
       if length(LibraryGeometryMesh^.Indices)>0 then begin
{$ifdef DoScanMemoryPoolForCorruptions}
        ScanMemoryPoolForCorruptions;
{$endif}
        SetLength(Positions.Vectors,0);
        Positions.Count:=0;
        SetLength(Normals.Vectors,0);
        Normals.Count:=0;
        SetLength(Tangents.Vectors,0);
        Tangents.Count:=0;
        SetLength(Bitangents.Vectors,0);
        Bitangents.Count:=0;
        SetLength(Colors.Vectors,0);
        Colors.Count:=0;
{$ifdef DoScanMemoryPoolForCorruptions}
        ScanMemoryPoolForCorruptions;
{$endif}
        for TexCoordSetIndex:=0 to dlMAXTEXCOORDSETS-1 do begin
         SetLength(TexCoords[TexCoordSetIndex].Vectors,0);
         TexCoords[TexCoordSetIndex].Count:=0;
        end;
{$ifdef DoScanMemoryPoolForCorruptions}
        ScanMemoryPoolForCorruptions;
{$endif}
        PositionOffset:=-1;
        NormalOffset:=-1;
        TangentOffset:=-1;
        BitangentOffset:=-1;
        ColorOffset:=-1;
        for TexCoordSetIndex:=0 to dlMAXTEXCOORDSETS-1 do begin
         TexCoordOffsets[TexCoordSetIndex]:=-1;
        end;
{$ifdef DoScanMemoryPoolForCorruptions}
        ScanMemoryPoolForCorruptions;
{$endif}
        CountTexCoords:=0;
        CountOffsets:=0;
{$ifdef DoScanMemoryPoolForCorruptions}
        ScanMemoryPoolForCorruptions;
{$endif}
        for InputIndex:=0 to length(LibraryGeometryMesh^.Inputs)-1 do begin
{$ifdef DoScanMemoryPoolForCorruptions}
         ScanMemoryPoolForCorruptions;
{$endif}
         Input:=@LibraryGeometryMesh^.Inputs[InputIndex];
         CountOffsets:=Max(CountOffsets,Input^.Offset+1);
         LibrarySource:=nil;
         if Input^.Semantic='VERTEX' then begin
          LibraryVertices:=LibraryVerticesesIDStringHashMap.Values[Input^.Source];
          if assigned(LibraryVertices) then begin
           for SubInputIndex:=0 to length(LibraryVertices^.Inputs)-1 do begin
            SubInput:=@LibraryVertices^.Inputs[SubInputIndex];
            if SubInput^.Semantic='POSITION' then begin
             PositionOffset:=Input^.Offset;
             LibrarySource:=LibrarySourcesIDStringHashMap.Values[SubInput^.Source];
             if assigned(LibrarySource) then begin
              ConvertVectorSource(LibrarySource,Positions,stPOSITION);
             end;
            end else if SubInput^.Semantic='NORMAL' then begin
             NormalOffset:=Input^.Offset;
             LibrarySource:=LibrarySourcesIDStringHashMap.Values[SubInput^.Source];
             if assigned(LibrarySource) then begin
              ConvertVectorSource(LibrarySource,Normals,stNORMAL);
             end;
            end else if SubInput^.Semantic='TANGENT' then begin
             TangentOffset:=Input^.Offset;
             LibrarySource:=LibrarySourcesIDStringHashMap.Values[SubInput^.Source];
             if assigned(LibrarySource) then begin
              ConvertVectorSource(LibrarySource,Tangents,stTANGENT);
             end;
            end else if (SubInput^.Semantic='BINORMAL') or (SubInput^.Semantic='BITANGENT') then begin
             BitangentOffset:=Input^.Offset;
             LibrarySource:=LibrarySourcesIDStringHashMap.Values[SubInput^.Source];
             if assigned(LibrarySource) then begin
              ConvertVectorSource(LibrarySource,Bitangents,stBITANGENT);
             end;
            end else if SubInput^.Semantic='TEXCOORD' then begin
             if (SubInput^.Set_>=0) and (SubInput^.Set_<dlMAXTEXCOORDSETS) then begin
              CountTexCoords:=Max(CountTexCoords,SubInput^.Set_+1);
              TexCoordOffsets[SubInput^.Set_]:=Input^.Offset;
              LibrarySource:=LibrarySourcesIDStringHashMap.Values[SubInput^.Source];
              if assigned(LibrarySource) then begin
               ConvertVectorSource(LibrarySource,TexCoords[SubInput^.Set_],stTEXCOORD);
              end;
             end;
            end else if SubInput^.Semantic='COLOR' then begin
             ColorOffset:=Input^.Offset;
             LibrarySource:=LibrarySourcesIDStringHashMap.Values[SubInput^.Source];
             if assigned(LibrarySource) then begin
              ConvertVectorSource(LibrarySource,Colors,stCOLOR);
             end;
            end;
           end;
          end;
         end else if Input^.Semantic='POSITION' then begin
          PositionOffset:=Input^.Offset;
          LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
          if assigned(LibrarySource) then begin
           ConvertVectorSource(LibrarySource,Positions,stPOSITION);
          end;
         end else if Input^.Semantic='NORMAL' then begin
          NormalOffset:=Input^.Offset;
          LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
          if assigned(LibrarySource) then begin
           ConvertVectorSource(LibrarySource,Normals,stNORMAL);
          end;
         end else if Input^.Semantic='TANGENT' then begin
          TangentOffset:=Input^.Offset;
          LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
          if assigned(LibrarySource) then begin
           ConvertVectorSource(LibrarySource,Tangents,stTANGENT);
          end;
         end else if (Input^.Semantic='BINORMAL') or (Input^.Semantic='BITANGENT') then begin
          BitangentOffset:=Input^.Offset;
          LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
          if assigned(LibrarySource) then begin
           ConvertVectorSource(LibrarySource,Bitangents,stBITANGENT);
          end;
         end else if Input^.Semantic='TEXCOORD' then begin
          if (Input^.Set_>=0) and (Input^.Set_<dlMAXTEXCOORDSETS) then begin
           CountTexCoords:=Max(CountTexCoords,Input^.Set_+1);
           TexCoordOffsets[Input^.Set_]:=Input^.Offset;
           LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
           if assigned(LibrarySource) then begin
            ConvertVectorSource(LibrarySource,TexCoords[Input^.Set_],stTEXCOORD);
           end;
          end;
         end else if Input^.Semantic='COLOR' then begin
          ColorOffset:=Input^.Offset;
          LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
          if assigned(LibrarySource) then begin
           ConvertVectorSource(LibrarySource,Colors,stCOLOR);
          end;
         end;
        end;
        if CountOffsets>0 then begin
         for IndicesMeshIndex:=0 to length(LibraryGeometryMesh^.Indices)-1 do begin
{$ifdef DoScanMemoryPoolForCorruptions}
          ScanMemoryPoolForCorruptions;
{$endif}
          if length(LibraryGeometryMesh^.Indices[IndicesMeshIndex])>0 then begin
           HasNormals:=false;
           HasTangents:=false;
           VCountIndex:=0;
           IndicesIndex:=0;
           IndicesCount:=length(LibraryGeometryMesh.Indices[IndicesMeshIndex]);
           SetLength(VerticesArray,IndicesCount);
           SetLength(VertexIndicesArray,IndicesCount);
           VerticesCount:=0;
           while IndicesIndex<IndicesCount do begin
            if (LibraryGeometryMesh^.MeshType=mtPOLYLIST) and
               ((VCountIndex>=0) and (VCountIndex<length(LibraryGeometryMesh^.VCounts))) then begin
             VCount:=LibraryGeometryMesh^.VCounts[VCountIndex];
             inc(VCountIndex);
            end else begin
             case LibraryGeometryMesh^.MeshType of
              mtTRIANGLES:begin
               VCount:=3;
              end;
              mtTRIFANS:begin
               VCount:=1;
              end;
              mtTRISTRIPS:begin
               VCount:=1;
              end;
              mtPOLYGONS:begin
               VCount:=1;
              end;
              mtPOLYLIST:begin
               VCount:=IndicesCount div CountOffsets;
              end;
              mtLINES:begin
               VCount:=2;
              end;
              mtLINESTRIPS:begin
               VCount:=IndicesCount div CountOffsets;
              end;
              else begin
               VCount:=IndicesCount div CountOffsets;
              end;
             end;
            end;
{$ifdef DoScanMemoryPoolForCorruptions}
            ScanMemoryPoolForCorruptions;
{$endif}
            SetLength(VerticesArray[VerticesCount],VCount);
{$ifdef DoScanMemoryPoolForCorruptions}
            ScanMemoryPoolForCorruptions;
{$endif}
            FillChar(VerticesArray[VerticesCount,0],VCount*SizeOf(TpvDAEVertex),AnsiChar(#0));
{$ifdef DoScanMemoryPoolForCorruptions}
            ScanMemoryPoolForCorruptions;
{$endif}
{$ifdef DebugWrite}
            writeln(Index,' ',IndicesMeshIndex,' ',VCount,' ',VerticesCount);
            Flush(Output);
{$endif}
{$ifdef DoScanMemoryPoolForCorruptions}
            ScanMemoryPoolForCorruptions;
{$endif}
            if length(VertexIndicesArray[VerticesCount])<>VCount then begin
             SetLength(VertexIndicesArray[VerticesCount],VCount);
            end;
{$ifdef DoScanMemoryPoolForCorruptions}
            ScanMemoryPoolForCorruptions;
{$endif}
            FillChar(VertexIndicesArray[VerticesCount,0],VCount*SizeOf(TpvDAEVertexIndex),AnsiChar(#0));
{$ifdef DoScanMemoryPoolForCorruptions}
            ScanMemoryPoolForCorruptions;
{$endif}
            for VertexIndex:=0 to VCount-1 do begin
             VerticesArray[VerticesCount,VertexIndex].Position:=0;
             VerticesArray[VerticesCount,VertexIndex].Normal:=0;
             VerticesArray[VerticesCount,VertexIndex].Tangent:=0;
             VerticesArray[VerticesCount,VertexIndex].Bitangent:=0;
             for TexCoordSetIndex:=0 to dlMAXTEXCOORDSETS-1 do begin
              VerticesArray[VerticesCount,VertexIndex].TexCoords[TexCoordSetIndex]:=0;
             end;
             VerticesArray[VerticesCount,VertexIndex].CountTexCoords:=CountTexCoords;
             VerticesArray[VerticesCount,VertexIndex].Color.x:=1.0;
             VerticesArray[VerticesCount,VertexIndex].Color.y:=1.0;
             VerticesArray[VerticesCount,VertexIndex].Color.z:=1.0;
             VerticesArray[VerticesCount,VertexIndex].CountBlendWeights:=0;
             BaseIndex:=IndicesIndex+(VertexIndex*CountOffsets);
//           VertexIndicesArray[VerticesCount,VertexIndex]:=BaseIndex+PositionOffset;
             VertexIndicesArray[VerticesCount,VertexIndex]:=0;
             if PositionOffset>=0 then begin
              ArrayIndex:=BaseIndex+PositionOffset;
              if (ArrayIndex>=0) and (ArrayIndex<length(LibraryGeometryMesh^.Indices[IndicesMeshIndex])) then begin
               ItemIndex:=LibraryGeometryMesh^.Indices[IndicesMeshIndex,ArrayIndex];
               if (ItemIndex>=0) and (ItemIndex<Positions.Count) then begin
                VerticesArray[VerticesCount,VertexIndex].Position.x:=Positions.Vectors[ItemIndex].x;
                VerticesArray[VerticesCount,VertexIndex].Position.y:=Positions.Vectors[ItemIndex].y;
                VerticesArray[VerticesCount,VertexIndex].Position.z:=Positions.Vectors[ItemIndex].z;
                VertexIndicesArray[VerticesCount,VertexIndex]:=ItemIndex;
               end;
              end;
             end;
             if NormalOffset>=0 then begin
              ArrayIndex:=BaseIndex+NormalOffset;
              if (ArrayIndex>=0) and (ArrayIndex<length(LibraryGeometryMesh^.Indices[IndicesMeshIndex])) then begin
               ItemIndex:=LibraryGeometryMesh^.Indices[IndicesMeshIndex,ArrayIndex];
               if (ItemIndex>=0) and (ItemIndex<Normals.Count) then begin
                VerticesArray[VerticesCount,VertexIndex].Normal.x:=Normals.Vectors[ItemIndex].x;
                VerticesArray[VerticesCount,VertexIndex].Normal.y:=Normals.Vectors[ItemIndex].y;
                VerticesArray[VerticesCount,VertexIndex].Normal.z:=Normals.Vectors[ItemIndex].z;
                HasNormals:=true;
               end;
              end;
             end;
             if TangentOffset>=0 then begin
              ArrayIndex:=BaseIndex+TangentOffset;
              if (ArrayIndex>=0) and (ArrayIndex<length(LibraryGeometryMesh^.Indices[IndicesMeshIndex])) then begin
               ItemIndex:=LibraryGeometryMesh^.Indices[IndicesMeshIndex,ArrayIndex];
               if (ItemIndex>=0) and (ItemIndex<Tangents.Count) then begin
                VerticesArray[VerticesCount,VertexIndex].Tangent.x:=Tangents.Vectors[ItemIndex].x;
                VerticesArray[VerticesCount,VertexIndex].Tangent.y:=Tangents.Vectors[ItemIndex].y;
                VerticesArray[VerticesCount,VertexIndex].Tangent.z:=Tangents.Vectors[ItemIndex].z;
                HasTangents:=true;
               end;
              end;
             end;
             if BitangentOffset>=0 then begin
              ArrayIndex:=BaseIndex+BitangentOffset;
              if (ArrayIndex>=0) and (ArrayIndex<length(LibraryGeometryMesh^.Indices[IndicesMeshIndex])) then begin
               ItemIndex:=LibraryGeometryMesh^.Indices[IndicesMeshIndex,ArrayIndex];
               if (ItemIndex>=0) and (ItemIndex<Bitangents.Count) then begin
                VerticesArray[VerticesCount,VertexIndex].Bitangent.x:=Bitangents.Vectors[ItemIndex].x;
                VerticesArray[VerticesCount,VertexIndex].Bitangent.y:=Bitangents.Vectors[ItemIndex].y;
                VerticesArray[VerticesCount,VertexIndex].Bitangent.z:=Bitangents.Vectors[ItemIndex].z;
                HasTangents:=true;
               end;
              end;
             end;
             for TexCoordSetIndex:=0 to dlMAXTEXCOORDSETS-1 do begin
              if TexCoordOffsets[TexCoordSetIndex]>=0 then begin
               ArrayIndex:=BaseIndex+TexCoordOffsets[TexCoordSetIndex];
               if (ArrayIndex>=0) and (ArrayIndex<length(LibraryGeometryMesh^.Indices[IndicesMeshIndex])) then begin
                ItemIndex:=LibraryGeometryMesh^.Indices[IndicesMeshIndex,ArrayIndex];
                if (ItemIndex>=0) and (ItemIndex<TexCoords[TexCoordSetIndex].Count) then begin
                 VerticesArray[VerticesCount,VertexIndex].CountTexCoords:=Max(VerticesArray[VerticesCount,VertexIndex].CountTexCoords,TexCoordSetIndex+1);
                 VerticesArray[VerticesCount,VertexIndex].TexCoords[TexCoordSetIndex].x:=TexCoords[TexCoordSetIndex].Vectors[ItemIndex].x;
                 VerticesArray[VerticesCount,VertexIndex].TexCoords[TexCoordSetIndex].y:=1.0-TexCoords[TexCoordSetIndex].Vectors[ItemIndex].y;
                end;
               end;
              end;
             end;
             if ColorOffset>=0 then begin
              ArrayIndex:=BaseIndex+ColorOffset;
              if (ArrayIndex>=0) and (ArrayIndex<length(LibraryGeometryMesh^.Indices[IndicesMeshIndex])) then begin
               ItemIndex:=LibraryGeometryMesh^.Indices[IndicesMeshIndex,ArrayIndex];
               if (ItemIndex>=0) and (ItemIndex<Colors.Count) then begin
                VerticesArray[VerticesCount,VertexIndex].Color.x:=Colors.Vectors[ItemIndex].x;
                VerticesArray[VerticesCount,VertexIndex].Color.y:=Colors.Vectors[ItemIndex].y;
                VerticesArray[VerticesCount,VertexIndex].Color.z:=Colors.Vectors[ItemIndex].z;
               end;
              end;
             end;
             VerticesArray[VerticesCount,VertexIndex].Normal:=VerticesArray[VerticesCount,VertexIndex].Normal.Normalize;
             VerticesArray[VerticesCount,VertexIndex].Tangent:=VerticesArray[VerticesCount,VertexIndex].Tangent.Normalize;
             VerticesArray[VerticesCount,VertexIndex].Bitangent:=VerticesArray[VerticesCount,VertexIndex].Bitangent.Normalize;
            end;
            inc(VerticesCount);
            inc(IndicesIndex,CountOffsets*VCount);
           end;
{$ifdef DoScanMemoryPoolForCorruptions}
           ScanMemoryPoolForCorruptions;
{$endif}
           SetLength(VerticesArray,VerticesCount);
           SetLength(VertexIndicesArray,VerticesCount);
{$ifdef DoScanMemoryPoolForCorruptions}
           ScanMemoryPoolForCorruptions;
{$endif}
           if VerticesCount>0 then begin
            case LibraryGeometryMesh^.MeshType of
             mtTRIANGLES:begin
              Mesh:=TpvDAEMesh.Create;
              result.Add(Mesh);
              Mesh.ParentGeometry:=result;
              Mesh.MeshType:=dlmtTRIANGLES;
              Mesh.TexCoordSets:=nil;
              LibraryMaterial:=RemappedMaterials.Values[LibraryGeometryMesh^.Material];
              if assigned(LibraryMaterial) then begin
               Mesh.MaterialIndex:=LibraryMaterial^.Index;
               InstanceMaterial:=RemappedInstanceMaterials.Values[LibraryGeometryMesh^.Material];
               if assigned(InstanceMaterial) then begin
                SetLength(Mesh.TexCoordSets,length(InstanceMaterial^.TexCoordSets));
                for TexCoordSetIndex:=0 to length(InstanceMaterial^.TexCoordSets)-1 do begin
                 Mesh.TexCoordSets[TexCoordSetIndex].Semantic:=InstanceMaterial^.TexCoordSets[TexCoordSetIndex].Semantic;
                 Mesh.TexCoordSets[TexCoordSetIndex].InputSet:=InstanceMaterial^.TexCoordSets[TexCoordSetIndex].InputSet;
                end;
               end;
              end else begin
               Mesh.MaterialIndex:=-1;
              end;
              SetLength(Mesh.Vertices,VerticesCount*3);
              SetLength(Mesh.Indices,VerticesCount*3);
              SetLength(Mesh.VertexIndices,VerticesCount*3);
              for BaseIndex:=0 to VerticesCount-1 do begin
               Mesh.Vertices[(BaseIndex*3)+0]:=VerticesArray[BaseIndex,0];
               Mesh.Vertices[(BaseIndex*3)+1]:=VerticesArray[BaseIndex,1];
               Mesh.Vertices[(BaseIndex*3)+2]:=VerticesArray[BaseIndex,2];
               Mesh.Indices[(BaseIndex*3)+0]:=(BaseIndex*3)+0;
               Mesh.Indices[(BaseIndex*3)+1]:=(BaseIndex*3)+1;
               Mesh.Indices[(BaseIndex*3)+2]:=(BaseIndex*3)+2;
               Mesh.VertexIndices[(BaseIndex*3)+0]:=VertexIndicesArray[BaseIndex,0];
               Mesh.VertexIndices[(BaseIndex*3)+1]:=VertexIndicesArray[BaseIndex,1];
               Mesh.VertexIndices[(BaseIndex*3)+2]:=VertexIndicesArray[BaseIndex,2];
              end;
              Mesh.HasNormals:=HasNormals;
              Mesh.HasTangents:=HasTangents;
             end;
             mtTRIFANS:begin
              Mesh:=TpvDAEMesh.Create;
              result.Add(Mesh);
              LibraryMaterial:=RemappedMaterials.Values[LibraryGeometryMesh^.Material];
              Mesh.ParentGeometry:=result;
              Mesh.MeshType:=dlmtTRIANGLES;
              if assigned(LibraryMaterial) then begin
               Mesh.MaterialIndex:=LibraryMaterial^.Index;
              end else begin
               Mesh.MaterialIndex:=-1;
              end;
              SetLength(Mesh.Vertices,VerticesCount);
              SetLength(Mesh.VertexIndices,VerticesCount);
              for BaseIndex:=0 to VerticesCount-1 do begin
               Mesh.Vertices[BaseIndex]:=VerticesArray[BaseIndex,0];
               Mesh.VertexIndices[BaseIndex]:=VertexIndicesArray[BaseIndex,0];
              end;
              SetLength(Mesh.Indices,VerticesCount*3);
              IndicesCount:=0;
              for BaseIndex:=0 to VerticesCount-3 do begin
               Mesh.Indices[IndicesCount+0]:=0;
               Mesh.Indices[IndicesCount+1]:=BaseIndex+1;
               Mesh.Indices[IndicesCount+2]:=BaseIndex+2;
               inc(IndicesCount,3);
              end;
              SetLength(Mesh.Indices,IndicesCount);
              Mesh.HasNormals:=HasNormals;
              Mesh.HasTangents:=HasTangents;
             end;
             mtTRISTRIPS:begin
              Mesh:=TpvDAEMesh.Create;
              result.Add(Mesh);
              LibraryMaterial:=RemappedMaterials.Values[LibraryGeometryMesh^.Material];
              Mesh.ParentGeometry:=result;
              Mesh.MeshType:=dlmtTRIANGLES;
              if assigned(LibraryMaterial) then begin
               Mesh.MaterialIndex:=LibraryMaterial^.Index;
              end else begin
               Mesh.MaterialIndex:=-1;
              end;
              SetLength(Mesh.Vertices,VerticesCount);
              SetLength(Mesh.VertexIndices,VerticesCount);
              for BaseIndex:=0 to VerticesCount-1 do begin
               Mesh.Vertices[BaseIndex]:=VerticesArray[BaseIndex,0];
               Mesh.VertexIndices[BaseIndex]:=VertexIndicesArray[BaseIndex,0];
              end;
              SetLength(Mesh.Indices,VerticesCount*3);
              IndicesCount:=0;
              for BaseIndex:=0 to VerticesCount-3 do begin
               if (BaseIndex and 1)<>0 then begin
                Mesh.Indices[IndicesCount+0]:=BaseIndex;
                Mesh.Indices[IndicesCount+1]:=BaseIndex+2;
                Mesh.Indices[IndicesCount+2]:=BaseIndex+1;
               end else begin
                Mesh.Indices[IndicesCount+0]:=BaseIndex;
                Mesh.Indices[IndicesCount+1]:=BaseIndex+1;
                Mesh.Indices[IndicesCount+2]:=BaseIndex+2;
               end;
               inc(IndicesCount,3);
              end;
              SetLength(Mesh.Indices,IndicesCount);
              Mesh.HasNormals:=HasNormals;
              Mesh.HasTangents:=HasTangents;
             end;
             mtPOLYGONS:begin
              Mesh:=TpvDAEMesh.Create;
              result.Add(Mesh);
              LibraryMaterial:=RemappedMaterials.Values[LibraryGeometryMesh^.Material];
              Mesh.ParentGeometry:=result;
              Mesh.MeshType:=dlmtTRIANGLES;
              if assigned(LibraryMaterial) then begin
               Mesh.MaterialIndex:=LibraryMaterial^.Index;
              end else begin
               Mesh.MaterialIndex:=-1;
              end;
              SetLength(Mesh.Vertices,VerticesCount);
              SetLength(Mesh.VertexIndices,VerticesCount);
              for BaseIndex:=0 to VerticesCount-1 do begin
               Mesh.Vertices[BaseIndex]:=VerticesArray[BaseIndex,0];
               Mesh.VertexIndices[BaseIndex]:=VertexIndicesArray[BaseIndex,0];
              end;
              SetLength(Mesh.Indices,VerticesCount*3);
              IndicesCount:=0;
              for BaseIndex:=0 to VerticesCount-3 do begin
               Mesh.Indices[IndicesCount+0]:=0;
               Mesh.Indices[IndicesCount+1]:=BaseIndex+1;
               Mesh.Indices[IndicesCount+2]:=BaseIndex+2;
               inc(IndicesCount,3);
              end;
              SetLength(Mesh.Indices,IndicesCount);
              Mesh.HasNormals:=HasNormals;
              Mesh.HasTangents:=HasTangents;
             end;
             mtPOLYLIST:begin
              Mesh:=TpvDAEMesh.Create;
              result.Add(Mesh);
              LibraryMaterial:=RemappedMaterials.Values[LibraryGeometryMesh^.Material];
              Mesh.ParentGeometry:=result;
              Mesh.MeshType:=dlmtTRIANGLES;
              if assigned(LibraryMaterial) then begin
               Mesh.MaterialIndex:=LibraryMaterial^.Index;
              end else begin
               Mesh.MaterialIndex:=-1;
              end;
              VCount:=0;
              for BaseIndex:=0 to VerticesCount-1 do begin
               inc(VCount,length(VerticesArray[BaseIndex]));
              end;
              SetLength(Mesh.Vertices,VCount+2);
              SetLength(Mesh.VertexIndices,VCount+2);
              SetLength(Mesh.Indices,(VCount+2)*3);
              VCount:=0;
              IndicesCount:=0;
              for BaseIndex:=0 to VerticesCount-1 do begin
               VertexSubCount:=length(VerticesArray[BaseIndex]);
               if (VCount+VertexSubCount)>length(Mesh.Indices) then begin
                SetLength(Mesh.Vertices,NextPowerOfTwo(VCount+VertexSubCount));
                SetLength(Mesh.VertexIndices,NextPowerOfTwo(VCount+VertexSubCount));
               end;
               for ArrayIndex:=0 to VertexSubCount-1 do begin
                Mesh.Vertices[VCount+ArrayIndex]:=VerticesArray[BaseIndex,ArrayIndex];
                Mesh.VertexIndices[VCount+ArrayIndex]:=VertexIndicesArray[BaseIndex,ArrayIndex];
               end;
               for ArrayIndex:=0 to VertexSubCount-3 do begin
                if (IndicesCount+3)>length(Mesh.Indices) then begin
                 SetLength(Mesh.Indices,NextPowerOfTwo(IndicesCount+3));
                end;
                Mesh.Indices[IndicesCount+0]:=VCount;
                Mesh.Indices[IndicesCount+1]:=VCount+ArrayIndex+1;
                Mesh.Indices[IndicesCount+2]:=VCount+ArrayIndex+2;
                inc(IndicesCount,3);
               end;
               inc(VCount,VertexSubCount);
              end;
              SetLength(Mesh.Vertices,VCount);
              SetLength(Mesh.VertexIndices,VCount);
              SetLength(Mesh.Indices,IndicesCount);
              Mesh.HasNormals:=HasNormals;
              Mesh.HasTangents:=HasTangents;
             end;
             mtLINES:begin
              for BaseIndex:=0 to VerticesCount-1 do begin
               Mesh:=TpvDAEMesh.Create;
               result.Add(Mesh);
               Mesh.ParentGeometry:=result;
               Mesh.MeshType:=dlmtLINESTRIP;
               LibraryMaterial:=RemappedMaterials.Values[LibraryGeometryMesh^.Material];
               if assigned(LibraryMaterial) then begin
                Mesh.MaterialIndex:=LibraryMaterial^.Index;
               end else begin
                Mesh.MaterialIndex:=-1;
               end;
               SetLength(Mesh.Vertices,2);
               SetLength(Mesh.VertexIndices,2);
               Mesh.Vertices[0]:=VerticesArray[BaseIndex,0];
               Mesh.Vertices[1]:=VerticesArray[BaseIndex,1];
               Mesh.VertexIndices[0]:=VertexIndicesArray[BaseIndex,0];
               Mesh.VertexIndices[1]:=VertexIndicesArray[BaseIndex,1];
               SetLength(Mesh.Indices,2);
               Mesh.Indices[0]:=0;
               Mesh.Indices[1]:=1;
               Mesh.HasNormals:=HasNormals;
               Mesh.HasTangents:=HasTangents;
              end;
             end;
             mtLINESTRIPS:begin
              Mesh:=TpvDAEMesh.Create;
              result.Add(Mesh);
              Mesh.ParentGeometry:=result;
              Mesh.MeshType:=dlmtLINESTRIP;
              LibraryMaterial:=RemappedMaterials.Values[LibraryGeometryMesh^.Material];
              if assigned(LibraryMaterial) then begin
               Mesh.MaterialIndex:=LibraryMaterial^.Index;
              end else begin
               Mesh.MaterialIndex:=-1;
              end;
              if length(VerticesArray)>0 then begin
               Mesh.Vertices:=copy(VerticesArray[0],0,length(VerticesArray[0]));
               Mesh.VertexIndices:=copy(VertexIndicesArray[0],0,length(VertexIndicesArray[0]));
               SetLength(Mesh.Indices,length(Mesh.Vertices));
               for ArrayIndex:=0 to length(Mesh.Indices)-1 do begin
                Mesh.Indices[ArrayIndex]:=ArrayIndex;
               end;
               Mesh.HasNormals:=HasNormals;
               Mesh.HasTangents:=HasTangents;
              end else begin
               Mesh.Vertices:=nil;
               Mesh.Indices:=nil;
              end;
             end;
            end;
           end;
{$ifdef DoScanMemoryPoolForCorruptions}
           ScanMemoryPoolForCorruptions;
{$endif}
{          SetLength(VerticesArray,0);
           SetLength(VertexIndicesArray,0);}
          end;
         end;
        end;
       end;
      end;

     finally
      RemappedMaterials.Free;
      RemappedInstanceMaterials.Free;
     end;

     if assigned(LibraryControllerSkin) then begin
      if (LibraryControllerSkin^.Count>0) and (LibraryControllerSkin^.Count=length(LibraryControllerSkin^.VertexWeights.VCounts)) then begin
       begin
        result.BindShapeMatrix:=LibraryControllerSkin^.BindShapeMatrix;
        JointOffset:=-1;
        InverseBindMatrixOffset:=-1;
        CountOffsets:=0;
        for InputIndex:=0 to length(LibraryControllerSkin^.Joints.Inputs)-1 do begin
         Input:=@LibraryControllerSkin^.Joints.Inputs[InputIndex];
         CountOffsets:=Max(CountOffsets,Input^.Offset+1);
         if Input^.Semantic='JOINT' then begin
          JointOffset:=Input^.Offset;
          LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
          if assigned(LibrarySource) then begin
           ConvertNameSource(LibrarySource,Joints);
          end;
         end else if Input^.Semantic='INV_BIND_MATRIX' then begin
          InverseBindMatrixOffset:=Input^.Offset;
          LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
          if assigned(LibrarySource) then begin
           ConvertMatrixSource(LibrarySource,InverseBindMatrices);
          end;
         end;
        end;
        result.JointNames.Clear;
        SetLength(result.InverseBindMatrices,Joints.Count);
        for ItemIndex:=0 to Joints.Count-1 do begin
         result.JointNames.Add(String(Joints.Names[ItemIndex]));
         if (ItemIndex>=0) and (ItemIndex<InverseBindMatrices.Count) then begin
          result.InverseBindMatrices[ItemIndex]:=InverseBindMatrices.Matrices[ItemIndex];
         end else begin
          result.InverseBindMatrices[ItemIndex]:=TpvMatrix4x4.Identity;
         end;
        end;
       end;
       begin
        JointOffset:=-1;
        WeightOffset:=-1;
        CountOffsets:=0;
        for InputIndex:=0 to length(LibraryControllerSkin^.VertexWeights.Inputs)-1 do begin
         Input:=@LibraryControllerSkin^.VertexWeights.Inputs[InputIndex];
         CountOffsets:=Max(CountOffsets,Input^.Offset+1);
         if Input^.Semantic='JOINT' then begin
          JointOffset:=Input^.Offset;
          LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
          if assigned(LibrarySource) then begin
           ConvertNameSource(LibrarySource,Joints);
          end;
         end else if Input^.Semantic='WEIGHT' then begin
          WeightOffset:=Input^.Offset;
          LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
          if assigned(LibrarySource) then begin
           ConverTpvFloatSource(LibrarySource,Weights);
          end;
         end;
        end;
       end;
       begin
        SetLength(BlendVertices,LibraryControllerSkin^.Count);
        BaseIndex:=0;
        for VertexIndex:=0 to LibraryControllerSkin^.Count-1 do begin
         VCount:=LibraryControllerSkin^.VertexWeights.VCounts[VertexIndex];
         BlendVertex:=@BlendVertices[VertexIndex];
         FillChar(BlendVertex^,SizeOf(TBlendVertex),AnsiChar(#0));
         BlendVertex^.Count:=VCount;
         for VCountIndex:=0 to VCount-1 do begin
          if VCountIndex<dlMAXBLENDWEIGHTS then begin
           BlendVertex^.BlendIndices[VCountIndex]:=-1;
           BlendVertex^.BlendWeights[VCountIndex]:=0.0;
           begin
            ArrayIndex:=BaseIndex+JointOffset;
            if (ArrayIndex>=0) and (ArrayIndex<length(LibraryControllerSkin^.VertexWeights.V)) then begin
             ItemIndex:=LibraryControllerSkin^.VertexWeights.V[ArrayIndex];
             if (ItemIndex>=0) and (ItemIndex<Joints.Count) then begin
              BlendVertex^.BlendIndices[VCountIndex]:=result.JointNames.IndexOf(String(Joints.Names[ItemIndex]));
             end else if ItemIndex=-1 then begin
              BlendVertex^.BlendIndices[VCountIndex]:=-1;
             end else begin
              Assert(false);
             end;
            end else begin
             Assert(false);
            end;
           end;
           begin
            ArrayIndex:=BaseIndex+WeightOffset;
            if (ArrayIndex>=0) and (ArrayIndex<length(LibraryControllerSkin^.VertexWeights.V)) then begin
             ItemIndex:=LibraryControllerSkin^.VertexWeights.V[ArrayIndex];
             if (ItemIndex>=0) and (ItemIndex<Weights.Count) then begin
              BlendVertex^.BlendWeights[VCountIndex]:=Weights.Floats[ItemIndex];
             end else begin
              Assert(false);
             end;
            end else begin
             Assert(false);
            end;
           end;
          end;
          inc(BaseIndex,CountOffsets);
         end;
        end;
       end;
       for Index:=0 to result.Count-1 do begin
        Mesh:=result[Index];
        if assigned(Mesh) then begin
         for VertexIndex:=0 to length(Mesh.VertexIndices)-1 do begin
          ItemIndex:=Mesh.VertexIndices[VertexIndex];
          if (ItemIndex>=0) and (ItemIndex<length(BlendVertices)) then begin
           BlendVertex:=@BlendVertices[ItemIndex];
           Vertex:=@Mesh.Vertices[VertexIndex];
           Vertex^.CountBlendWeights:=BlendVertex^.Count;
           Sum:=0.0;
           for BaseIndex:=0 to dlMAXBLENDWEIGHTS-1 do begin
            Vertex^.BlendIndices[BaseIndex]:=BlendVertex^.BlendIndices[BaseIndex];
            Vertex^.BlendWeights[BaseIndex]:=BlendVertex^.BlendWeights[BaseIndex];
            if BaseIndex<Vertex^.CountBlendWeights then begin
             Sum:=Sum+Vertex^.BlendWeights[BaseIndex];
            end;
           end;
           if (Sum<>0.0) and (Sum<>1.0) then begin
            for BaseIndex:=0 to dlMAXBLENDWEIGHTS-1 do begin
             if BaseIndex<Vertex^.CountBlendWeights then begin
              Vertex^.BlendWeights[BaseIndex]:=Vertex^.BlendWeights[BaseIndex]/Sum;
             end else begin
              break;
             end;
            end;
           end;
          end else begin
           Assert(false);
          end;
         end;
{        for VertexIndex:=0 to length(Mesh.Vertices)-1 do begin
          write(Mesh.Vertices[VertexIndex].CountBlendWeights,' ');
         end;{}
        end;
       end;
      end else begin
       Assert(false);
      end;
     end;

     if assigned(LibraryControllerMorph) then begin
      Targets.Names:=nil;
      Targets.Count:=0;
      Weights.Floats:=nil;
      Weights.Count:=0;
      try
       CountOffsets:=0;
       for InputIndex:=0 to length(LibraryControllerMorph^.Targets.Inputs)-1 do begin
        Input:=@LibraryControllerMorph^.Targets.Inputs[InputIndex];
        CountOffsets:=Max(CountOffsets,Input^.Offset+1);
        if Input^.Semantic='MORPH_TARGET' then begin
         LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
         if assigned(LibrarySource) then begin
          ConvertNameSource(LibrarySource,Targets);
         end;
        end else if Input^.Semantic='MORPH_WEIGHT' then begin
         LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
         if assigned(LibrarySource) then begin
          ConverTpvFloatSource(LibrarySource,Weights);
          MorphTargetWeightIDStringHashMap.Add(Input^.Source,result);
         end;
        end;
       end;
       if (CountOffsets>0) and (length(Targets.Names)=length(Weights.Floats)) then begin
        SetLength(result.MorphTargetWeights,length(Weights.Floats));
        for Index:=0 to result.Count-1 do begin
         Mesh:=result[Index];
         if assigned(Mesh) then begin
          SetLength(Mesh.MorphTargetVertices,length(Weights.Floats));
          for TargetIndex:=0 to length(Targets.Names)-1 do begin
           Mesh.MorphTargetVertices[TargetIndex]:=Mesh.Vertices;
          end;
         end;
        end;
        for TargetIndex:=0 to length(Targets.Names)-1 do begin
         result.MorphTargetWeights[TargetIndex]:=Weights.Floats[TargetIndex];
         Geometry:=ConvertGeometry(Node,LibraryGeometriesIDStringHashMap.Values[Targets.Names[TargetIndex]],nil,nil,true);
         if assigned(Geometry) then begin
          try
           if result.MorphTargetMatch(Geometry) then begin
            for Index:=0 to result.Count-1 do begin
             Mesh:=result[Index];
             OtherMesh:=Geometry[Index];
             if assigned(Mesh) and assigned(OtherMesh) then begin
              Mesh.MorphTargetVertices[TargetIndex]:=OtherMesh.Vertices;
              OtherMesh.Vertices:=nil;
             end;
            end;
           end;
          finally
           Geometry.Free;
          end;
         end;
        end;
       end;
      finally
       SetLength(Targets.Names,0);
       SetLength(Weights.Floats,0);
      end;
     end;

     for Index:=0 to result.Count-1 do begin
      Mesh:=result[Index];
      if assigned(Mesh) then begin
       SetLength(Mesh.VertexIndices,0);
       if not (Child or assigned(LibraryControllerMorph)) then begin
        Mesh.Optimize;
       end;
       Mesh.CalculateMissingInformations(not Mesh.HasNormals,not Mesh.HasTangents);
       Mesh.CorrectInformations;
       if not (Child or assigned(LibraryControllerMorph)) then begin
        Mesh.Optimize;
       end;
      end;
     end;

    end else begin
     result:=nil;
    end;
   end;
  var Index:TpvInt32;
      Node:TpvDAENode;
      TranformRotate:TpvDAETransformRotate;
      TranformTranslate:TpvDAETransformTranslate;
      TranformScale:TpvDAETransformScale;
      TranformMatrix:TpvDAETransformMatrix;
      TranformLookAt:TpvDAETransformLookAt;
      TranformSkew:TpvDAETransformSkew;
      Camera:TpvDAECamera;
      Light:TpvDAELight;
      Geometry:TpvDAEGeometry;
      InstanceNode:PLibraryNode;
      LibraryGeometry:PLibraryGeometry;
      LibraryControllerSkin:PLibraryControllerSkin;
      LibraryControllerMorph:PLibraryControllerMorph;
  begin
   if assigned(LibraryNode) then begin
    case LibraryNode^.NodeType of
     ntNODE:begin
      Node:=TpvDAENode.Create;
      Node.Parent:=ParentNode;
      Node.ID:=LibraryNode^.ID;
      Node.SID:=LibraryNode^.SID;
      Node.Name:=LibraryNode^.Name;
      Node.Visible:=LibraryNode^.Visible;
      if LibraryNode^.IsJoint then begin
       Node.NodeType:=TpvDAENodeType.Joint;
       VisualScene.JointNodes.AddObject(String(LibraryNode^.SID),Node);
       VisualScene.JointNodeStringHashMap.Add(LibraryNode^.SID,Node);
       if ParentNode.NodeType<>TpvDAENodeType.Joint then begin
        VisualScene.JointRootNodes.AddObject(String(LibraryNode^.SID),Node);
       end;
      end else begin
       Node.NodeType:=TpvDAENodeType.Node;
      end;
      ParentNode.Nodes.Add(Node);
      NodeIDStringHashMap.Add(Node.ID,Node);
      for Index:=0 to LibraryNode^.Children.Count-1 do begin
       ConvertNode(Node,LibraryNode^.Children[Index]);
      end;
     end;
     ntROTATE:begin
      TranformRotate:=TpvDAETransformRotate.Create;
      TranformRotate.SID:=LibraryNode^.SID;
      TranformRotate.Axis:=LibraryNode^.RotateAxis;
      TranformRotate.Angle:=LibraryNode^.RotateAngle;
      TranformRotate.Convert;
      ParentNode.Transforms.Add(TranformRotate);
      ParentNode.Transforms.SIDStringHashMap.Add(TranformRotate.SID,TranformRotate);
     end;
     ntTRANSLATE:begin
      TranformTranslate:=TpvDAETransformTranslate.Create;
      TranformTranslate.SID:=LibraryNode^.SID;
      TranformTranslate.Offset:=LibraryNode^.TranslateOffset;
      TranformTranslate.Convert;
      ParentNode.Transforms.Add(TranformTranslate);
      ParentNode.Transforms.SIDStringHashMap.Add(TranformTranslate.SID,TranformTranslate);
     end;
     ntSCALE:begin
      TranformScale:=TpvDAETransformScale.Create;
      TranformScale.SID:=LibraryNode^.SID;
      TranformScale.Scale:=LibraryNode^.Scale;
      TranformScale.Convert;
      ParentNode.Transforms.Add(TranformScale);
      ParentNode.Transforms.SIDStringHashMap.Add(TranformScale.SID,TranformScale);
     end;
     ntMATRIX:begin
      TranformMatrix:=TpvDAETransformMatrix.Create;
      TranformMatrix.SID:=LibraryNode^.SID;
      TranformMatrix.Matrix:=LibraryNode^.Matrix;
      TranformMatrix.Convert;
      ParentNode.Transforms.Add(TranformMatrix);
      ParentNode.Transforms.SIDStringHashMap.Add(TranformMatrix.SID,TranformMatrix);
     end;
     ntLOOKAT:begin
      TranformLookAt:=TpvDAETransformLookAt.Create;
      TranformLookAt.SID:=LibraryNode^.SID;
      TranformLookAt.LookAtOrigin:=LibraryNode^.LookAtOrigin;
      TranformLookAt.LookAtDest:=LibraryNode^.LookAtDest;
      TranformLookAt.LookAtUp:=LibraryNode^.LookAtUp;
      TranformLookAt.Convert;
      ParentNode.Transforms.Add(TranformLookAt);
      ParentNode.Transforms.SIDStringHashMap.Add(TranformLookAt.SID,TranformLookAt);
     end;
     ntSKEW:begin
      TranformSkew:=TpvDAETransformSkew.Create;
      TranformSkew.SID:=LibraryNode^.SID;
      TranformSkew.SkewAngle:=LibraryNode^.SkewAngle;
      TranformSkew.SkewA:=LibraryNode^.SkewA;
      TranformSkew.SkewB:=LibraryNode^.SkewB;
      TranformSkew.Convert;
      ParentNode.Transforms.Add(TranformSkew);
      ParentNode.Transforms.SIDStringHashMap.Add(TranformSkew.SID,TranformSkew);
     end;
     ntEXTRA:begin
     end;
     ntINSTANCECAMERA:begin
      if assigned(LibraryNode^.InstanceCamera) then begin
       Camera:=TpvDAECamera.Create;
       Camera.ID:=LibraryNode^.InstanceCamera^.ID;
       Camera.Name:=LibraryNode^.InstanceCamera^.Name;
       Camera.ZNear:=LibraryNode^.InstanceCamera^.Camera.ZNear;
       Camera.ZFar:=LibraryNode^.InstanceCamera^.Camera.ZFar;
       Camera.AspectRatio:=LibraryNode^.InstanceCamera^.Camera.AspectRatio;
       Camera.CameraType:=LibraryNode^.InstanceCamera^.Camera.CameraType;
       Camera.XFov:=LibraryNode^.InstanceCamera^.Camera.XFov;
       Camera.YFov:=LibraryNode^.InstanceCamera^.Camera.YFov;
       Camera.XMag:=LibraryNode^.InstanceCamera^.Camera.XMag;
       Camera.YMag:=LibraryNode^.InstanceCamera^.Camera.YMag;
       ParentNode.Cameras.Add(Camera);
       if assigned(ParentNode) and (length(ParentNode.ID)>0) then begin
        CameraHashMap.Add(ParentNode.ID,Camera);
       end else begin
        CameraHashMap.Add(Camera.ID,Camera);
       end;
       CameraList.Add(Camera);
      end;
     end;
     ntINSTANCELIGHT:begin
      if assigned(LibraryNode^.InstanceLight) then begin
       case LibraryNode^.InstanceLight^.LightType of
        ltAMBIENT:begin
         Light:=TpvDAELightAmbient.Create;
         Light.LightType:=dlltAMBIENT;
         Light.Color:=LibraryNode^.InstanceLight^.Color;
         Light.ConstantAttenuation:=LibraryNode^.InstanceLight^.ConstantAttenuation;
         Light.LinearAttenuation:=LibraryNode^.InstanceLight^.LinearAttenuation;
         Light.QuadraticAttenuation:=LibraryNode^.InstanceLight^.QuadraticAttenuation;
        end;
        ltDIRECTIONAL:begin
         Light:=TpvDAELightDirectional.Create;
         Light.LightType:=dlltDIRECTIONAL;
         Light.Color:=LibraryNode^.InstanceLight^.Color;
         Light.Direction:=TpvVector3.Create(0.0,0.0,-1.0);
         Light.ConstantAttenuation:=LibraryNode^.InstanceLight^.ConstantAttenuation;
         Light.LinearAttenuation:=LibraryNode^.InstanceLight^.LinearAttenuation;
         Light.QuadraticAttenuation:=LibraryNode^.InstanceLight^.QuadraticAttenuation;
        end;
        ltPOINT:begin
         Light:=TpvDAELightPoint.Create;
         Light.LightType:=dlltPOINT;
         Light.Color:=LibraryNode^.InstanceLight^.Color;
         Light.ConstantAttenuation:=LibraryNode^.InstanceLight^.ConstantAttenuation;
         Light.LinearAttenuation:=LibraryNode^.InstanceLight^.LinearAttenuation;
         Light.QuadraticAttenuation:=LibraryNode^.InstanceLight^.QuadraticAttenuation;
        end;
        ltSPOT:begin
         Light:=TpvDAELightSpot.Create;
         Light.LightType:=dlltSPOT;
         Light.Color:=LibraryNode^.InstanceLight^.Color;
         Light.Direction:=TpvVector3.Create(0.0,0.0,-1.0);
         Light.FallOffAngle:=LibraryNode^.InstanceLight^.FallOffAngle;
         Light.FallOffExponent:=LibraryNode^.InstanceLight^.FallOffExponent;
         Light.ConstantAttenuation:=LibraryNode^.InstanceLight^.ConstantAttenuation;
         Light.LinearAttenuation:=LibraryNode^.InstanceLight^.LinearAttenuation;
         Light.QuadraticAttenuation:=LibraryNode^.InstanceLight^.QuadraticAttenuation;
        end;
        else begin
         Light:=nil;
        end;
       end;
       ParentNode.Lights.Add(Light);
      end;
     end;
     ntINSTANCECONTROLLER:begin
      if assigned(LibraryNode^.InstanceController) then begin
       LibraryGeometry:=LibraryNode^.InstanceController^.Geometry;
       LibraryControllerSkin:=LibraryNode^.InstanceController^.Skin;
       LibraryControllerMorph:=LibraryNode^.InstanceController^.Morph;
       if assigned(LibraryControllerSkin) and not assigned(LibraryControllerMorph) then begin
        LibraryControllerSkin^.Controller:=LibraryControllersIDStringHashMap.Values[LibraryControllerSkin^.Source];
        if assigned(LibraryControllerSkin^.Controller) and (LibraryControllerSkin^.Controller^.ControllerType=ctMORPH) then begin
         LibraryControllerMorph:=LibraryControllerSkin^.Controller^.Morph;
        end;
       end;
       if assigned(LibraryControllerMorph) and not assigned(LibraryControllerSkin) then begin
        LibraryControllerMorph^.Controller:=LibraryControllersIDStringHashMap.Values[LibraryControllerMorph^.Source];
        if assigned(LibraryControllerMorph^.Controller) and (LibraryControllerMorph^.Controller^.ControllerType=ctSKIN) then begin
         LibraryControllerSkin:=LibraryControllerMorph^.Controller^.Skin;
        end;
       end;
       if not assigned(LibraryGeometry) then begin
        if assigned(LibraryControllerSkin) and assigned(LibraryControllerSkin^.Geometry) then begin
         LibraryGeometry:=LibraryControllerSkin^.Geometry;
        end;
        if assigned(LibraryControllerMorph) and assigned(LibraryControllerMorph^.Geometry) then begin
         LibraryGeometry:=LibraryControllerMorph^.Geometry;
        end;
       end;
       if assigned(LibraryGeometry) then begin
        Geometry:=ConvertGeometry(ParentNode,LibraryGeometry,LibraryControllerMorph,LibraryControllerSkin);
        if assigned(Geometry) then begin
         ParentNode.Geometries.Add(Geometry);
        end;
       end;
      end;
     end;
     ntINSTANCEGEOMETRY:begin
      Geometry:=ConvertGeometry(ParentNode,LibraryNode^.InstanceGeometry,nil,nil);
      if assigned(Geometry) then begin
       ParentNode.Geometries.Add(Geometry);
      end;
     end;
     ntINSTANCENODE:begin
      InstanceNode:=LibraryNodesIDStringHashMap.Values[LibraryNode^.InstanceNode];
      if assigned(InstanceNode) then begin
       Node:=TpvDAENode.Create;
       Node.ID:=LibraryNode^.ID;
       Node.SID:=LibraryNode^.SID;
       Node.Name:=LibraryNode^.Name;
       Node.Visible:=LibraryNode^.Visible;
       if ((length(LibraryNode^.NodeType_)>0) and (MyLowerCase(LibraryNode^.NodeType_)='joint')) or
          ((length(LibraryNode^.NodeType_)=0) and InstanceNode^.IsJoint) then begin
        Node.NodeType:=TpvDAENodeType.Joint;
       end else begin
        Node.NodeType:=TpvDAENodeType.Node;
       end;
       ParentNode.Nodes.Add(Node);
       ConvertNode(Node,InstanceNode);
      end;
     end;
    end;
   end;
  end;
 var TransformMatrix:TpvDAETransformMatrix;
     UnitScaleAxisMatrix:TpvMatrix4x4;
  procedure ConvertVisualScenes;
  var LibraryVisualScene:PLibraryVisualScene;
      Index:TpvInt32;
  begin
   LibraryVisualScene:=LibraryVisualScenes;
   while assigned(LibraryVisualScene) do begin
    VisualScene:=TpvDAEVisualScene.Create;
    VisualScene.ID:=LibraryVisualScene^.ID;
    VisualScene.Name:=LibraryVisualScene^.Name;
    NodeIDStringHashMap.Add(VisualScene.ID,VisualScene.Root);
    if AutomaticCorrect then begin
     TransformMatrix:=TpvDAETransformMatrix.Create;
     TransformMatrix.SID:='';
     TransformMatrix.Matrix:=UnitScaleAxisMatrix;
     VisualScene.Root.Transforms.Add(TransformMatrix);
    end;
    VisualScenes.Insert(0,VisualScene);
    if MainLibraryVisualScene=LibraryVisualScene then begin
     MainVisualScene:=VisualScene;
    end;
    for Index:=0 to LibraryVisualScene^.Items.Count-1 do begin
     ConvertNode(VisualScene.Root,LibraryVisualScene^.Items[Index]);
    end;
    LibraryVisualScene:=LibraryVisualScene^.Next;
   end;
  end;
  procedure ConvertAnimations;
  var LibraryAnimation:PLibraryAnimation;
      LibraryAnimationChannel:PLibraryAnimationChannel;
      LibraryAnimationSampler:PLibraryAnimationSampler;
      CountOffsets,ChannelIndex,SampleIndex,InputIndex,PositionOffset,TargetSplitterPositionIndex,TargetSplitterPosition,KeyFrameIndex,ValueIndex:TpvInt32;
      TargetNodeID,TargetString,TargetSID:ansistring;
      AnimationChannel:TpvDAEAnimationChannel;
      SamplerInput:PInput;
      SamplerInputSource:PLibrarySource;
      InputValues,OutputValues,InTangentValues,OutTangentValues:TpvFloatArray;
      InterpolationValues:TNameArray;
      AnimationChannelKeyFrame:TpvDAEAnimationChannelKeyFrame;
      StartChar,EndChar:ansichar;
  begin
   LibraryAnimation:=LibraryAnimations;
   while assigned(LibraryAnimation) do begin
    Animation:=TpvDAEAnimation.Create;
    Animation.ID:=LibraryAnimation^.ID;
    Animation.Name:=LibraryAnimation^.Name;
    Animation.Referenced:=LibraryAnimation^.Referenced;
    Animations.Add(Animation);
    LibraryAnimation^.DAEAnimation:=Animation;
    for ChannelIndex:=0 to length(LibraryAnimation^.Channels)-1 do begin
     LibraryAnimationChannel:=@LibraryAnimation^.Channels[ChannelIndex];
     for SampleIndex:=0 to length(LibraryAnimation^.Samplers)-1 do begin
      LibraryAnimationSampler:=@LibraryAnimation^.Samplers[SampleIndex];
      if LibraryAnimationChannel^.Source=LibraryAnimationSampler^.ID then begin
       TargetSplitterPosition:=0;
       for TargetSplitterPositionIndex:=1 to length(LibraryAnimationChannel^.Target) do begin
        if LibraryAnimationChannel^.Target[TargetSplitterPositionIndex]='/' then begin
         TargetSplitterPosition:=TargetSplitterPositionIndex;
         break;
        end;
       end;
       if TargetSplitterPosition>0 then begin
        TargetNodeID:=copy(LibraryAnimationChannel^.Target,1,TargetSplitterPosition-1);
        TargetString:=copy(LibraryAnimationChannel^.Target,TargetSplitterPosition+1,length(LibraryAnimationChannel^.Target)-TargetSplitterPosition);
       end else begin
        TargetNodeID:='';
        TargetString:=LibraryAnimationChannel^.Target;
       end;
       begin
        AnimationChannel:=TpvDAEAnimationChannel.Create;
        Animation.Channels.Add(AnimationChannel);
        AnimationChannel.NodeID:=TargetNodeID;
        AnimationChannel.Node:=NodeIDStringHashMap[AnimationChannel.NodeID];
        AnimationChannel.ElementID:=TargetString;
        AnimationChannel.DestinationObject:=nil;
        TargetSID:='';
        for TargetSplitterPosition:=1 to length(TargetString) do begin
         if (TargetString[TargetSplitterPosition] in ['.','(','[']) or (TargetSplitterPosition=length(TargetString)) then begin
          if TargetString[TargetSplitterPosition] in ['.','(','['] then begin
           TargetSID:=copy(TargetString,1,TargetSplitterPosition-1);
           Delete(TargetString,1,TargetSplitterPosition-1);
          end else begin
           TargetSID:=TargetString;
           TargetString:='';
          end;
          break;
         end;
        end;
        if length(TargetSID)>0 then begin
         if assigned(AnimationChannel.Node) then begin
          AnimationChannel.DestinationObject:=AnimationChannel.Node.Transforms.SIDStringHashMap[TargetSID];
         end;
         if not assigned(AnimationChannel.DestinationObject) then begin
          AnimationChannel.DestinationObject:=MorphTargetWeightIDStringHashMap[TargetSID];
         end;
        end;
        AnimationChannel.DestinationElement:=0;
        if length(TargetString)>0 then begin
         case TargetString[1] of
          '.':begin
           TargetString:=MyLowerCase(copy(TargetString,2,length(TargetString)-1));
           case length(TargetString) of
            1:begin
             case AnsiChar(TargetString[1]) of
              'x','u','s','r':begin
               AnimationChannel.DestinationElement:=dlacdeX;
              end;
              'y','v','t','g':begin
               AnimationChannel.DestinationElement:=dlacdeY;
              end;
              'z','p','b':begin
               AnimationChannel.DestinationElement:=dlacdeZ;
              end;
              'w','q','a':begin
               AnimationChannel.DestinationElement:=dlacdeW;
              end;
             end;
            end;
            4:begin
             if TargetString='time' then begin
              AnimationChannel.DestinationElement:=dlacdeTIME;
             end;
            end;
            5:begin
             if TargetString='angle' then begin
              AnimationChannel.DestinationElement:=dlacdeANGLE;
             end;
            end;
           end;
          end;
          '(','[':begin
           StartChar:=TargetString[1];
           if StartChar='(' then begin
            EndChar:=')';
           end else begin
            EndChar:=']';
           end;
           TargetSplitterPosition:=0;
           for TargetSplitterPositionIndex:=1 to length(TargetString) do begin
            if TargetString[TargetSplitterPositionIndex]=EndChar then begin
             TargetSplitterPosition:=TargetSplitterPositionIndex;
             break;
            end;
           end;
           if TargetSplitterPosition>0 then begin
            AnimationChannel.DestinationElement:=MyStrToIntDef(copy(TargetString,2,TargetSplitterPosition-2),0);
            Delete(TargetString,1,TargetSplitterPosition);
            if (length(TargetString)>0) and (TargetString[1]=StartChar) then begin
             TargetSplitterPosition:=0;
             for TargetSplitterPositionIndex:=1 to length(TargetString) do begin
              if TargetString[TargetSplitterPositionIndex]=EndChar then begin
               TargetSplitterPosition:=TargetSplitterPositionIndex;
               break;
              end;
             end;
             if TargetSplitterPosition>0 then begin
              if assigned(AnimationChannel.DestinationObject) and (AnimationChannel.DestinationObject is TpvDAETransformMatrix) then begin
               AnimationChannel.DestinationElement:=(MyStrToIntDef(copy(TargetString,2,TargetSplitterPosition-2),0)*4)+AnimationChannel.DestinationElement;
              end;
             end;
            end;
           end;
          end;
         end;
        end;
        InputValues.Floats:=nil;
        InputValues.Count:=0;
        OutputValues.Floats:=nil;
        OutputValues.Count:=0;
        InTangentValues.Floats:=nil;
        InTangentValues.Count:=0;
        InTangentValues.Params:=0;
        OutTangentValues.Floats:=nil;
        OutTangentValues.Count:=0;
        OutTangentValues.Params:=0;
        InterpolationValues.Names:=nil;
        InterpolationValues.Count:=0;
        try
         if AnimationChannel.DestinationElement=15 then begin
          if AnimationChannel.DestinationElement=15 then begin
          end;
         end;
         CountOffsets:=0;
         for InputIndex:=0 to length(LibraryAnimationSampler^.Inputs)-1 do begin
          SamplerInput:=@LibraryAnimationSampler^.Inputs[InputIndex];
          SamplerInputSource:=LibrarySourcesIDStringHashMap.Values[SamplerInput^.Source];
          if assigned(SamplerInputSource) then begin
           CountOffsets:=Max(CountOffsets,SamplerInput^.Offset+1);
           if SamplerInput^.Semantic='INPUT' then begin
            ConverTpvFloatSource(SamplerInputSource,InputValues);
           end else if SamplerInput^.Semantic='OUTPUT' then begin
            ConvertMultipleFloatSource(SamplerInputSource,OutputValues);
           end else if SamplerInput^.Semantic='IN_TANGENT' then begin
            ConvertMultipleParamFloatSource(SamplerInputSource,InTangentValues);
//          ConvertVectorSource(SamplerInputSource,InTangentValues,stTANGENT);
           end else if SamplerInput^.Semantic='OUT_TANGENT' then begin
            ConvertMultipleParamFloatSource(SamplerInputSource,OutTangentValues);
//          ConvertVectorSource(SamplerInputSource,OutTangentValues,stTANGENT);
           end else if SamplerInput^.Semantic='INTERPOLATION' then begin
            ConvertNameSource(SamplerInputSource,InterpolationValues);
           end;
          end;
         end;
         if CountOffsets>0 then begin
          KeyFrameIndex:=0;
          while KeyFrameIndex<InputValues.Count do begin
           AnimationChannelKeyFrame:=TpvDAEAnimationChannelKeyFrame.Create;
           AnimationChannel.KeyFrames.Add(AnimationChannelKeyFrame);
           if KeyFrameIndex<length(InterpolationValues.Names) then begin
            if InterpolationValues.Names[KeyFrameIndex]='BEZIER' then begin
             AnimationChannelKeyFrame.Interpolation:=TpvDAEInterpolationType.Bezier;
            end else if InterpolationValues.Names[KeyFrameIndex]='CARDINAL' then begin
             AnimationChannelKeyFrame.Interpolation:=TpvDAEInterpolationType.Cardinal;
            end else if InterpolationValues.Names[KeyFrameIndex]='HERMITE' then begin
             AnimationChannelKeyFrame.Interpolation:=TpvDAEInterpolationType.Hermite;
            end else if InterpolationValues.Names[KeyFrameIndex]='BSPLINE' then begin
             AnimationChannelKeyFrame.Interpolation:=TpvDAEInterpolationType.BSpline;
            end else if InterpolationValues.Names[KeyFrameIndex]='STEP' then begin
             AnimationChannelKeyFrame.Interpolation:=TpvDAEInterpolationType.Step;
            end else {if InterpolationValues.Names[KeyFrameIndex]='LINEAR' then}begin
             AnimationChannelKeyFrame.Interpolation:=TpvDAEInterpolationType.Linear;
            end;
           end else begin
            AnimationChannelKeyFrame.Interpolation:=TpvDAEInterpolationType.Linear;
           end;
           if KeyFrameIndex<length(InputValues.Floats) then begin
            AnimationChannelKeyFrame.Time:=InputValues.Floats[KeyFrameIndex];
           end else begin
            AnimationChannelKeyFrame.Time:=0.0;
           end;
           SetLength(AnimationChannelKeyFrame.Values,OutputValues.Stride);
           for ValueIndex:=0 to OutputValues.Stride-1 do begin
            if ((KeyFrameIndex*OutputValues.Stride)+ValueIndex)<length(OutputValues.Floats) then begin
             AnimationChannelKeyFrame.Values[ValueIndex]:=OutputValues.Floats[(KeyFrameIndex*OutputValues.Stride)+ValueIndex];
            end else begin
             AnimationChannelKeyFrame.Values[ValueIndex]:=0.0;
            end;
           end;
           begin
            SetLength(AnimationChannelKeyFrame.InTangents,InTangentValues.Stride);
            AnimationChannelKeyFrame.InTangentStride:=InTangentValues.Stride;
            AnimationChannelKeyFrame.InTangentParams:=InTangentValues.Params;
            for ValueIndex:=0 to InTangentValues.Stride-1 do begin
             if ((KeyFrameIndex*InTangentValues.Stride)+ValueIndex)<length(InTangentValues.Floats) then begin
              AnimationChannelKeyFrame.InTangents[ValueIndex]:=InTangentValues.Floats[(KeyFrameIndex*InTangentValues.Stride)+ValueIndex];
             end else begin
              AnimationChannelKeyFrame.InTangents[ValueIndex]:=0.0;
             end;
            end;
           end;
           begin
            SetLength(AnimationChannelKeyFrame.OutTangents,OutTangentValues.Stride);
            AnimationChannelKeyFrame.OutTangentStride:=OutTangentValues.Stride;
            AnimationChannelKeyFrame.OutTangentParams:=OutTangentValues.Params;
            for ValueIndex:=0 to OutTangentValues.Stride-1 do begin
             if ((KeyFrameIndex*OutTangentValues.Stride)+ValueIndex)<length(OutTangentValues.Floats) then begin
              AnimationChannelKeyFrame.OutTangents[ValueIndex]:=OutTangentValues.Floats[(KeyFrameIndex*OutTangentValues.Stride)+ValueIndex];
             end else begin
              AnimationChannelKeyFrame.OutTangents[ValueIndex]:=0.0;
             end;
            end;
           end;
           inc(KeyFrameIndex);//,CountOffsets);
          end;
         end;
        finally
         SetLength(InputValues.Floats,0);
         SetLength(OutputValues.Floats,0);
         SetLength(InTangentValues.Floats,0);
         SetLength(OutTangentValues.Floats,0);
         SetLength(InterpolationValues.Names,0);
        end;
       end;
      end;
     end;
    end;
    LibraryAnimation:=LibraryAnimation^.Next;
   end;
  end;
  procedure ConvertAnimationClips;
  var Index:TpvInt32;
      LibraryAnimationClip:PLibraryAnimationClip;
      AnimationClip:TpvDAEAnimationClip;
      LibraryAnimation:PLibraryAnimation;
      Animation:TpvDAEAnimation;
  begin
   AnimationClip:=TpvDAEAnimationClip.Create;
   AnimationClip.ID:='unreferenced';
   AnimationClip.Name:='unreferenced';
   AnimationClips.Add(AnimationClip);
   for Index:=0 to Animations.Count-1 do begin
    Animation:=Animations[Index];
    if not Animation.Referenced then begin
     AnimationClip.Animations.Add(Animation);
    end;
   end;
   LibraryAnimationClip:=LibraryAnimationClips;
   while assigned(LibraryAnimationClip) do begin
    AnimationClip:=TpvDAEAnimationClip.Create;
    AnimationClip.ID:=LibraryAnimationClip^.ID;
    AnimationClip.Name:=LibraryAnimationClip^.Name;
    AnimationClips.Add(AnimationClip);
    for Index:=0 to length(LibraryAnimationClip^.Animations)-1 do begin
     LibraryAnimation:=LibraryAnimationClip^.Animations[Index];
     if assigned(LibraryAnimation) then begin
      AnimationClip.Animations.Add(LibraryAnimation^.DAEAnimation);
     end;
    end;
    LibraryAnimationClip:=LibraryAnimationClip^.Next;
   end;
  end;
  procedure ConvertAnimationKeyframes;
  const TimeStep=1.0/60.0; // 60 Hz
  type PValue=^TValue;
       TValue=record
        Time:TpvDouble;
        Value:TpvFloat;
       end;
   function InverseParametericCubic(x,x0,x1,x2,x3:TpvDouble):TpvFloat;
   const Tolerance=1.0e-09;
         SmallerTolerance=1.0e-20;
         MaxIterationCount=100;
   var Iteration:TpvInt32;
       u,v:TpvFloat;
       a,b,c,d,e,f:TpvDouble;
   begin
    if (x-x0)<SmallerTolerance then begin
     result:=0.0;
    end else if (x3-x)<SmallerTolerance then begin
     result:=1.0;
    end else begin
     u:=0.0;
     v:=1.0;
     for Iteration:=0 to MaxIterationCount-1 do begin
      a:=(x0+x1)*0.5;
      b:=(x1+x2)*0.5;
      c:=(x2+x3)*0.5;
      d:=(a+b)*0.5;
      e:=(b+c)*0.5;
      f:=(d+e)*0.5;
      if abs(f-x)<Tolerance then begin
       break;
      end else if f<x then begin
       x0:=f;
       x1:=e;
       x2:=c;
       u:=(u+v)*0.5;
      end else begin
       x1:=a;
       x2:=d;
       x3:=f;
       v:=(u+v)*0.5;
      end;
     end;
     result:=Min(Max((u+v)*0.5,0.0),1.0);
    end;
   end;
  var AnimationIndex,AnimationChannelIndex,CountLinearKeyFrames,TimeStepIndex,CountValues,ValueIndex,KeyFrameIndex,
      SubValueIndex:TpvInt32;
      Animation:TpvDAEAnimation;
      AnimationChannel:TpvDAEAnimationChannel;
      AnimationChannelKeyFrame:TpvDAEAnimationChannelKeyFrame;
      StartTime,EndTime,CurrentTime:TpvDouble;
      s,c,e:TpvFloat;
      Indices:array[-1..3] of TpvInt32;
      Values:array[0..3] of TValue;
      dm0,dm1:TpvDecomposedMatrix4x4;
  begin
   for AnimationIndex:=0 to Animations.Count-1 do begin
    Animation:=Animations[AnimationIndex];
    for AnimationChannelIndex:=0 to Animation.Channels.Count-1 do begin
     AnimationChannel:=Animation.Channels[AnimationChannelIndex];
     if AnimationChannel.KeyFrames.Count>0 then begin
      StartTime:=AnimationChannel.KeyFrames[0].Time;
      AnimationChannelKeyFrame:=AnimationChannel.KeyFrames[AnimationChannel.KeyFrames.Count-1];
      EndTime:=AnimationChannelKeyFrame.Time;
      CountValues:=length(AnimationChannelKeyFrame.Values);
      AnimationChannel.CountValues:=CountValues;
      AnimationChannel.StartTime:=StartTime;
      AnimationChannel.EndTime:=EndTime;
      AnimationChannel.TimeStep:=TimeStep;
      CountLinearKeyFrames:=trunc(ceil((EndTime-StartTime)/TimeStep));
      AnimationChannel.CountLinearKeyFrames:=CountLinearKeyFrames;
      CurrentTime:=StartTime;
      for TimeStepIndex:=0 to CountLinearKeyFrames-1 do begin
       Indices[1]:=Max(0,AnimationChannel.KeyFrames.Count-1);
       for KeyFrameIndex:=0 to AnimationChannel.KeyFrames.Count-1 do begin
        if CurrentTime<=AnimationChannel.KeyFrames[KeyFrameIndex].Time then begin
         Indices[1]:=KeyFrameIndex;
         break;
        end;
       end;
       Indices[0]:=Min(Max(Indices[1]-1,0),AnimationChannel.KeyFrames.Count-1);
       Indices[-1]:=Min(Max(Indices[0]-1,0),AnimationChannel.KeyFrames.Count-1);
       Indices[2]:=Min(Max(Indices[1]+1,0),AnimationChannel.KeyFrames.Count-1);
       Indices[3]:=Min(Max(Indices[2]+1,0),AnimationChannel.KeyFrames.Count-1);
       SetLength(AnimationChannel.LinearKeyFrames,CountLinearKeyFrames,CountValues);
       if (CountValues=16) and
          (AnimationChannel.KeyFrames[Indices[0]].Interpolation in [TpvDAEInterpolationType.Linear]) then begin
        case AnimationChannel.KeyFrames[Indices[0]].Interpolation of
         TpvDAEInterpolationType.Linear:begin
          if AnimationChannel.KeyFrames[Indices[0]].Time=AnimationChannel.KeyFrames[Indices[1]].Time then begin
           TpvMatrix4x4(pointer(@AnimationChannel.LinearKeyFrames[TimeStepIndex,0])^):=TpvMatrix4x4(pointer(@AnimationChannel.KeyFrames[Indices[0]].Values[0])^);
          end else if CurrentTime<=AnimationChannel.KeyFrames[Indices[0]].Time then begin
           TpvMatrix4x4(pointer(@AnimationChannel.LinearKeyFrames[TimeStepIndex,0])^):=TpvMatrix4x4(pointer(@AnimationChannel.KeyFrames[Indices[0]].Values[0])^);
          end else if CurrentTime>=AnimationChannel.KeyFrames[Indices[1]].Time then begin
           TpvMatrix4x4(pointer(@AnimationChannel.LinearKeyFrames[TimeStepIndex,0])^):=TpvMatrix4x4(pointer(@AnimationChannel.KeyFrames[Indices[1]].Values[0])^);
          end else begin
           dm0:=TpvMatrix4x4(pointer(@AnimationChannel.KeyFrames[Indices[0]].Values[0])^).Decompose;
           dm1:=TpvMatrix4x4(pointer(@AnimationChannel.KeyFrames[Indices[1]].Values[0])^).Decompose;
           if dm0.Valid and dm1.Valid then begin
            TpvMatrix4x4(pointer(@AnimationChannel.LinearKeyFrames[TimeStepIndex,0])^):=TpvMatrix4x4.CreateRecomposed(dm0.Slerp(dm1,Min(Max((CurrentTime-AnimationChannel.KeyFrames[Indices[0]].Time)/(AnimationChannel.KeyFrames[Indices[1]].Time-AnimationChannel.KeyFrames[Indices[0]].Time),0.0),1.0)));
           end else begin
            TpvMatrix4x4(pointer(@AnimationChannel.LinearKeyFrames[TimeStepIndex,0])^):=TpvMatrix4x4(pointer(@AnimationChannel.KeyFrames[Indices[0]].Values[0])^).SimpleLerp(TpvMatrix4x4(pointer(@AnimationChannel.KeyFrames[Indices[1]].Values[0])^),Min(Max((CurrentTime-AnimationChannel.KeyFrames[Indices[0]].Time)/(AnimationChannel.KeyFrames[Indices[1]].Time-AnimationChannel.KeyFrames[Indices[0]].Time),0.0),1.0));
           end;
          end;
         end;
        end;
       end else begin
        for ValueIndex:=0 to CountValues-1 do begin
         case AnimationChannel.KeyFrames[Indices[0]].Interpolation of
          TpvDAEInterpolationType.Linear:begin
           if AnimationChannel.KeyFrames[Indices[0]].Time=AnimationChannel.KeyFrames[Indices[1]].Time then begin
            AnimationChannel.LinearKeyFrames[TimeStepIndex,ValueIndex]:=AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex];
           end else if CurrentTime<=AnimationChannel.KeyFrames[Indices[0]].Time then begin
            AnimationChannel.LinearKeyFrames[TimeStepIndex,ValueIndex]:=AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex];
           end else if CurrentTime>=AnimationChannel.KeyFrames[Indices[1]].Time then begin
            AnimationChannel.LinearKeyFrames[TimeStepIndex,ValueIndex]:=AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex];
           end else begin
            AnimationChannel.LinearKeyFrames[TimeStepIndex,ValueIndex]:=FloatLerp(AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex],
                                                                                  AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex],
                                                                                  Min(Max((CurrentTime-AnimationChannel.KeyFrames[Indices[0]].Time)/(AnimationChannel.KeyFrames[Indices[1]].Time-AnimationChannel.KeyFrames[Indices[0]].Time),0.0),1.0));
           end;
          end;
          TpvDAEInterpolationType.Bezier:begin
           Values[0].Time:=AnimationChannel.KeyFrames[Indices[0]].Time;
           Values[0].Value:=AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex];
           if (AnimationChannel.KeyFrames[Indices[1]].InTangentStride=AnimationChannel.KeyFrames[Indices[0]].OutTangentStride) and
              (AnimationChannel.KeyFrames[Indices[1]].InTangentParams=AnimationChannel.KeyFrames[Indices[0]].OutTangentParams) then begin
            case AnimationChannel.KeyFrames[Indices[0]].OutTangentParams of
             1:begin
              Values[1].Time:=((AnimationChannel.KeyFrames[Indices[0]].Time*2.0)+AnimationChannel.KeyFrames[Indices[1]].Time)/3.0;
              Values[1].Value:=AnimationChannel.KeyFrames[Indices[0]].OutTangents[ValueIndex];
              Values[2].Time:=(AnimationChannel.KeyFrames[Indices[0]].Time+(AnimationChannel.KeyFrames[Indices[1]].Time*2.0))/3.0;
              Values[2].Value:=AnimationChannel.KeyFrames[Indices[1]].InTangents[ValueIndex];
             end;
             2:begin
              Values[1].Time:=AnimationChannel.KeyFrames[Indices[0]].OutTangents[(ValueIndex*2)+0];
              Values[1].Value:=AnimationChannel.KeyFrames[Indices[0]].OutTangents[(ValueIndex*2)+1];
              Values[2].Time:=AnimationChannel.KeyFrames[Indices[1]].InTangents[(ValueIndex*2)+0];
              Values[2].Value:=AnimationChannel.KeyFrames[Indices[1]].InTangents[(ValueIndex*2)+1];
             end;
             else begin
              Values[1].Time:=((AnimationChannel.KeyFrames[Indices[0]].Time*2.0)+AnimationChannel.KeyFrames[Indices[1]].Time)/3.0;
              Values[1].Value:=((AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex]*2.0)+AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex])/3.0;
              Values[2].Time:=(AnimationChannel.KeyFrames[Indices[0]].Time+(AnimationChannel.KeyFrames[Indices[1]].Time*2.0))/3.0;
              Values[2].Value:=(AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex]+(AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex]*2.0))/3.0;
             end;
            end;
           end else begin
            Values[1].Time:=((AnimationChannel.KeyFrames[Indices[0]].Time*2.0)+AnimationChannel.KeyFrames[Indices[1]].Time)/3.0;
            Values[1].Value:=((AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex]*2.0)+AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex])/3.0;
            Values[2].Time:=(AnimationChannel.KeyFrames[Indices[0]].Time+(AnimationChannel.KeyFrames[Indices[1]].Time*2.0))/3.0;
            Values[2].Value:=(AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex]+(AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex]*2.0))/3.0;
           end;
           Values[3].Time:=AnimationChannel.KeyFrames[Indices[1]].Time;
           Values[3].Value:=AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex];
           s:=InverseParametericCubic(CurrentTime,Values[0].Time,Values[1].Time,Values[2].Time,Values[3].Time);
           c:=3.0*(Values[1].Value-Values[0].Value);
           e:=3.0*(Values[2].Value-Values[1].Value);
           AnimationChannel.LinearKeyFrames[TimeStepIndex,ValueIndex]:=((((((((Values[3].Value-Values[0].Value)-e)*s)+e)-c)*s)+c)*s)+Values[0].Value;
          end;
          TpvDAEInterpolationType.Cardinal:begin
           Values[0].Time:=AnimationChannel.KeyFrames[Indices[0]].Time;
           Values[0].Value:=AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex];
           if (AnimationChannel.KeyFrames[Indices[1]].InTangentStride=AnimationChannel.KeyFrames[Indices[0]].OutTangentStride) and
              (AnimationChannel.KeyFrames[Indices[1]].InTangentParams=AnimationChannel.KeyFrames[Indices[0]].OutTangentParams) then begin
            case AnimationChannel.KeyFrames[Indices[0]].OutTangentParams of
             1:begin
              Values[1].Time:=((AnimationChannel.KeyFrames[Indices[0]].Time*2.0)+AnimationChannel.KeyFrames[Indices[1]].Time)/3.0;
              Values[1].Value:=AnimationChannel.KeyFrames[Indices[0]].OutTangents[ValueIndex];
              Values[2].Time:=(AnimationChannel.KeyFrames[Indices[0]].Time+(AnimationChannel.KeyFrames[Indices[1]].Time*2.0))/3.0;
              Values[2].Value:=AnimationChannel.KeyFrames[Indices[1]].InTangents[ValueIndex];
             end;
             2:begin
              Values[1].Time:=AnimationChannel.KeyFrames[Indices[0]].Time+AnimationChannel.KeyFrames[Indices[0]].OutTangents[(ValueIndex*2)+0];
              Values[1].Value:=AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex]-AnimationChannel.KeyFrames[Indices[0]].OutTangents[(ValueIndex*2)+1];
              Values[2].Time:=AnimationChannel.KeyFrames[Indices[0]].Time+AnimationChannel.KeyFrames[Indices[1]].InTangents[(ValueIndex*2)+0];
              Values[2].Value:=AnimationChannel.KeyFrames[Indices[1]].Time-AnimationChannel.KeyFrames[Indices[1]].InTangents[(ValueIndex*2)+1];
              Values[1].Time:=AnimationChannel.KeyFrames[Indices[0]].OutTangents[(ValueIndex*2)+0];
              Values[1].Value:=AnimationChannel.KeyFrames[Indices[0]].OutTangents[(ValueIndex*2)+1];
              Values[2].Time:=AnimationChannel.KeyFrames[Indices[1]].InTangents[(ValueIndex*2)+0];
              Values[2].Value:=AnimationChannel.KeyFrames[Indices[1]].InTangents[(ValueIndex*2)+1];
             end;
             else begin
              Values[1].Time:=((AnimationChannel.KeyFrames[Indices[0]].Time*2.0)+AnimationChannel.KeyFrames[Indices[1]].Time)/3.0;
              Values[1].Value:=((AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex]*2.0)+AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex])/3.0;
              Values[2].Time:=(AnimationChannel.KeyFrames[Indices[0]].Time+(AnimationChannel.KeyFrames[Indices[1]].Time*2.0))/3.0;
              Values[2].Value:=(AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex]+(AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex]*2.0))/3.0;
             end;
            end;
           end else begin
            Values[1].Time:=((AnimationChannel.KeyFrames[Indices[0]].Time*2.0)+AnimationChannel.KeyFrames[Indices[1]].Time)/3.0;
            Values[1].Value:=((AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex]*2.0)+AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex])/3.0;
            Values[2].Time:=(AnimationChannel.KeyFrames[Indices[0]].Time+(AnimationChannel.KeyFrames[Indices[1]].Time*2.0))/3.0;
            Values[2].Value:=(AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex]+(AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex]*2.0))/3.0;
           end;
           Values[3].Time:=AnimationChannel.KeyFrames[Indices[1]].Time;
           Values[3].Value:=AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex];
           s:=InverseParametericCubic(CurrentTime,Values[0].Time,Values[1].Time,Values[2].Time,Values[3].Time);
           c:=3.0*(Values[1].Value-Values[0].Value);
           e:=3.0*(Values[2].Value-Values[1].Value);
           AnimationChannel.LinearKeyFrames[TimeStepIndex,ValueIndex]:=((((((((Values[3].Value-Values[0].Value)-e)*s)+e)-c)*s)+c)*s)+Values[0].Value;
          end;
          TpvDAEInterpolationType.Hermite:begin
           Values[0].Time:=AnimationChannel.KeyFrames[Indices[0]].Time;
           Values[0].Value:=AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex];
           if (AnimationChannel.KeyFrames[Indices[1]].InTangentStride=AnimationChannel.KeyFrames[Indices[0]].OutTangentStride) and
              (AnimationChannel.KeyFrames[Indices[1]].InTangentParams=AnimationChannel.KeyFrames[Indices[0]].OutTangentParams) then begin
            case AnimationChannel.KeyFrames[Indices[0]].OutTangentParams of
             1:begin
              Values[1].Time:=((AnimationChannel.KeyFrames[Indices[0]].Time*2.0)+AnimationChannel.KeyFrames[Indices[1]].Time)/3.0;
              Values[1].Value:=AnimationChannel.KeyFrames[Indices[0]].OutTangents[ValueIndex];
              Values[2].Time:=(AnimationChannel.KeyFrames[Indices[0]].Time+(AnimationChannel.KeyFrames[Indices[1]].Time*2.0))/3.0;
              Values[2].Value:=AnimationChannel.KeyFrames[Indices[1]].InTangents[ValueIndex];
             end;
             2:begin
              Values[1].Time:=AnimationChannel.KeyFrames[Indices[0]].Time+AnimationChannel.KeyFrames[Indices[0]].OutTangents[(ValueIndex*2)+0];
              Values[1].Value:=AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex]-AnimationChannel.KeyFrames[Indices[0]].OutTangents[(ValueIndex*2)+1];
              Values[2].Time:=AnimationChannel.KeyFrames[Indices[0]].Time+AnimationChannel.KeyFrames[Indices[1]].InTangents[(ValueIndex*2)+0];
              Values[2].Value:=AnimationChannel.KeyFrames[Indices[1]].Time-AnimationChannel.KeyFrames[Indices[1]].InTangents[(ValueIndex*2)+1];
              Values[1].Time:=AnimationChannel.KeyFrames[Indices[0]].OutTangents[(ValueIndex*2)+0];
              Values[1].Value:=AnimationChannel.KeyFrames[Indices[0]].OutTangents[(ValueIndex*2)+1];
              Values[2].Time:=AnimationChannel.KeyFrames[Indices[1]].InTangents[(ValueIndex*2)+0];
              Values[2].Value:=AnimationChannel.KeyFrames[Indices[1]].InTangents[(ValueIndex*2)+1];
             end;
             else begin
              Values[1].Time:=((AnimationChannel.KeyFrames[Indices[0]].Time*2.0)+AnimationChannel.KeyFrames[Indices[1]].Time)/3.0;
              Values[1].Value:=((AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex]*2.0)+AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex])/3.0;
              Values[2].Time:=(AnimationChannel.KeyFrames[Indices[0]].Time+(AnimationChannel.KeyFrames[Indices[1]].Time*2.0))/3.0;
              Values[2].Value:=(AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex]+(AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex]*2.0))/3.0;
             end;
            end;
           end else begin
            Values[1].Time:=((AnimationChannel.KeyFrames[Indices[0]].Time*2.0)+AnimationChannel.KeyFrames[Indices[1]].Time)/3.0;
            Values[1].Value:=((AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex]*2.0)+AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex])/3.0;
            Values[2].Time:=(AnimationChannel.KeyFrames[Indices[0]].Time+(AnimationChannel.KeyFrames[Indices[1]].Time*2.0))/3.0;
            Values[2].Value:=(AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex]+(AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex]*2.0))/3.0;
           end;
           Values[3].Time:=AnimationChannel.KeyFrames[Indices[1]].Time;
           Values[3].Value:=AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex];
           s:=InverseParametericCubic(CurrentTime,Values[0].Time,Values[1].Time,Values[2].Time,Values[3].Time);
           c:=3.0*(Values[1].Value-Values[0].Value);
           e:=3.0*(Values[2].Value-Values[1].Value);
           AnimationChannel.LinearKeyFrames[TimeStepIndex,ValueIndex]:=((((((((Values[3].Value-Values[0].Value)-e)*s)+e)-c)*s)+c)*s)+Values[0].Value;
          end;
          TpvDAEInterpolationType.BSpline:begin
           for SubValueIndex:=0 to 3 do begin
            Values[SubValueIndex].Time:=AnimationChannel.KeyFrames[Indices[SubValueIndex]].Time;
            Values[SubValueIndex].Value:=AnimationChannel.KeyFrames[Indices[SubValueIndex]].Values[ValueIndex];
           end;
           if (Indices[0]=Indices[1]) or (Values[0].Time>=Values[1].Time) then begin
            Values[0].Time:=Values[1].Time+(Values[1].Time-Values[2].Time);
            Values[0].Value:=Values[1].Value+(Values[1].Value-Values[2].Value);
           end;
           if (Indices[2]=Indices[3]) or (Values[2].Time>=Values[3].Time) then begin
            Values[3].Time:=Values[2].Time+(Values[2].Time-Values[1].Time);
            Values[3].Value:=Values[2].Value+(Values[2].Value-Values[1].Value);
           end;
           s:=InverseParametericCubic(CurrentTime,Values[0].Time,Values[1].Time,Values[2].Time,Values[3].Time);
           c:=3.0*(Values[1].Value-Values[0].Value);
           e:=3.0*(Values[2].Value-Values[1].Value);
           AnimationChannel.LinearKeyFrames[TimeStepIndex,ValueIndex]:=((((((((Values[3].Value-Values[0].Value)-e)*s)+e)-c)*s)+c)*s)+Values[0].Value;
          end
          else {TpvDAEInterpolationType.Step:}begin
           if CurrentTime<AnimationChannel.KeyFrames[Indices[1]].Time then begin
            AnimationChannel.LinearKeyFrames[TimeStepIndex,ValueIndex]:=AnimationChannel.KeyFrames[Indices[0]].Values[ValueIndex];
           end else begin
            AnimationChannel.LinearKeyFrames[TimeStepIndex,ValueIndex]:=AnimationChannel.KeyFrames[Indices[1]].Values[ValueIndex];
           end;
          end;
         end;
        end;
       end;
       CurrentTime:=Min(Max(CurrentTime+TimeStep,StartTime),EndTime);
      end;
     end;
    end;
   end;
  end;
  procedure CollectJointNodesAndSetupSkeleton;
   procedure ProcessVisualScene(const VisualScene:TpvDAEVisualScene);
    procedure ProcessNode(const Node:TpvDAENode);
     procedure ProcessGeometry(const Geometry:TpvDAEGeometry);
     var JointIndex,GeometryIndex:TpvInt32;
     begin
      if Geometry.JointNames.Count>0 then begin
       SetLength(Geometry.JointNodes,Geometry.JointNames.Count);
       for JointIndex:=0 to Geometry.JointNames.Count-1 do begin
        Geometry.JointNodes[JointIndex]:=TpvDAENode(VisualScene.JointNodeStringHashMap[AnsiString(Geometry.JointNames[JointIndex])]);
       end;
      end;
     end;
    var NodeIndex,GeometryIndex:TpvInt32;
    begin
     for NodeIndex:=0 to Node.Nodes.Count-1 do begin
      ProcessNode(Node.Nodes[NodeIndex]);
     end;
     for GeometryIndex:=0 to Node.Geometries.Count-1 do begin
      ProcessGeometry(Node.Geometries[GeometryIndex]);
     end;
    end;
   begin
    ProcessNode(VisualScene.Root);
   end;
  var VisualSceneIndex:TpvInt32;
  begin
   for VisualSceneIndex:=0 to VisualScenes.Count-1 do begin
    ProcessVisualScene(VisualScenes[VisualSceneIndex]);
   end;
  end;
 begin
  if AutomaticCorrect then begin
   case UpAxis of
    dluaXUP:begin
     UnitScaleAxisMatrix[0,0]:=0.0;
     UnitScaleAxisMatrix[0,1]:=UnitMeter;
     UnitScaleAxisMatrix[0,2]:=0.0;
     UnitScaleAxisMatrix[0,3]:=0.0;
     UnitScaleAxisMatrix[1,0]:=-UnitMeter;
     UnitScaleAxisMatrix[1,1]:=0.0;
     UnitScaleAxisMatrix[1,2]:=0.0;
     UnitScaleAxisMatrix[1,3]:=0.0;
     UnitScaleAxisMatrix[2,0]:=0.0;
     UnitScaleAxisMatrix[2,1]:=0.0;
     UnitScaleAxisMatrix[2,2]:=UnitMeter;
     UnitScaleAxisMatrix[2,3]:=0.0;
     UnitScaleAxisMatrix[3,0]:=0.0;
     UnitScaleAxisMatrix[3,1]:=0.0;
     UnitScaleAxisMatrix[3,2]:=0.0;
     UnitScaleAxisMatrix[3,3]:=1.0;
    end;
    dluaZUP:begin
     UnitScaleAxisMatrix[0,0]:=UnitMeter;
     UnitScaleAxisMatrix[0,1]:=0.0;
     UnitScaleAxisMatrix[0,2]:=0.0;
     UnitScaleAxisMatrix[0,3]:=0.0;
     UnitScaleAxisMatrix[1,0]:=0.0;
     UnitScaleAxisMatrix[1,1]:=0.0;
     UnitScaleAxisMatrix[1,2]:=-UnitMeter;
     UnitScaleAxisMatrix[1,3]:=0.0;
     UnitScaleAxisMatrix[2,0]:=0.0;
     UnitScaleAxisMatrix[2,1]:=UnitMeter;
     UnitScaleAxisMatrix[2,2]:=0.0;
     UnitScaleAxisMatrix[2,3]:=0.0;
     UnitScaleAxisMatrix[3,0]:=0.0;
     UnitScaleAxisMatrix[3,1]:=0.0;
     UnitScaleAxisMatrix[3,2]:=0.0;
     UnitScaleAxisMatrix[3,3]:=1.0;
    end;
    else {dluaYUP:}begin
     UnitScaleAxisMatrix[0,0]:=UnitMeter;
     UnitScaleAxisMatrix[0,1]:=0.0;
     UnitScaleAxisMatrix[0,2]:=0.0;
     UnitScaleAxisMatrix[0,3]:=0.0;
     UnitScaleAxisMatrix[1,0]:=0.0;
     UnitScaleAxisMatrix[1,1]:=UnitMeter;
     UnitScaleAxisMatrix[1,2]:=0.0;
     UnitScaleAxisMatrix[1,3]:=0.0;
     UnitScaleAxisMatrix[2,0]:=0.0;
     UnitScaleAxisMatrix[2,1]:=0.0;
     UnitScaleAxisMatrix[2,2]:=UnitMeter;
     UnitScaleAxisMatrix[2,3]:=0.0;
     UnitScaleAxisMatrix[3,0]:=0.0;
     UnitScaleAxisMatrix[3,1]:=0.0;
     UnitScaleAxisMatrix[3,2]:=0.0;
     UnitScaleAxisMatrix[3,3]:=1.0;
    end;
   end;
  end else begin
   UnitScaleAxisMatrix:=TpvMatrix4x4.Identity;
  end;
  ConvertVisualScenes;
  ConvertAnimations;
  ConvertAnimationClips;
  ConvertAnimationKeyframes;
  CollectJointNodesAndSetupSkeleton;
 end;
 procedure ConstructStaticAABB;
 var KeyFrameIndex,MaxKeyFrameCount:TpvInt32;
  procedure GetMaxAnimationKeyCount;
  var AnimationIndex,AnimationChannelIndex,x,y:TpvInt32;
      Animation:TpvDAEAnimation;
      AnimationChannel:TpvDAEAnimationChannel;
  begin
   MaxKeyFrameCount:=0;
   for AnimationIndex:=0 to Animations.Count-1 do begin
    Animation:=Animations[AnimationIndex];
    for AnimationChannelIndex:=0 to Animation.Channels.Count-1 do begin
     AnimationChannel:=Animation.Channels[AnimationChannelIndex];
     if assigned(AnimationChannel.DestinationObject) then begin
      MaxKeyFrameCount:=Max(MaxKeyFrameCount,AnimationChannel.KeyFrames.Count);
     end;
    end;
   end;
  end;
  procedure UpdateAnimation;
  var AnimationIndex,AnimationChannelIndex,x,y:TpvInt32;
      Animation:TpvDAEAnimation;
      AnimationChannel:TpvDAEAnimationChannel;
      AnimationChannelKeyFrame:TpvDAEAnimationChannelKeyFrame;
  begin
   for AnimationIndex:=0 to Animations.Count-1 do begin
    Animation:=Animations[AnimationIndex];
    for AnimationChannelIndex:=0 to Animation.Channels.Count-1 do begin
     AnimationChannel:=Animation.Channels[AnimationChannelIndex];
     if assigned(AnimationChannel.DestinationObject) then begin
      AnimationChannelKeyFrame:=AnimationChannel.KeyFrames[KeyFrameIndex mod AnimationChannel.KeyFrames.Count];
      if AnimationChannel.DestinationObject is TpvDAEGeometry then begin
       if (AnimationChannel.DestinationElement>=0) and (AnimationChannel.DestinationElement<length(TpvDAEGeometry(AnimationChannel.DestinationObject).MorphTargetWeights)) then begin
        case length(AnimationChannelKeyFrame.Values) of
         1:begin
          TpvDAEGeometry(AnimationChannel.DestinationObject).MorphTargetWeights[AnimationChannel.DestinationElement]:=AnimationChannelKeyFrame.Values[0];
         end;
        end;
       end;
      end else if AnimationChannel.DestinationObject is TpvDAETransformRotate then begin
       case length(AnimationChannelKeyFrame.Values) of
        1:begin
         case AnimationChannel.DestinationElement of
          dlacdeX:begin
           TpvDAETransformRotate(AnimationChannel.DestinationObject).Axis.x:=AnimationChannelKeyFrame.Values[0];
          end;
          dlacdeY:begin
           TpvDAETransformRotate(AnimationChannel.DestinationObject).Axis.y:=AnimationChannelKeyFrame.Values[0];
          end;
          dlacdeZ:begin
           TpvDAETransformRotate(AnimationChannel.DestinationObject).Axis.z:=AnimationChannelKeyFrame.Values[0];
          end;
          dlacdeANGLE:begin
           TpvDAETransformRotate(AnimationChannel.DestinationObject).Angle:=AnimationChannelKeyFrame.Values[0];
          end;
         end;
        end;
        4:begin
         TpvDAETransformRotate(AnimationChannel.DestinationObject).Axis.x:=AnimationChannelKeyFrame.Values[0];
         TpvDAETransformRotate(AnimationChannel.DestinationObject).Axis.y:=AnimationChannelKeyFrame.Values[1];
         TpvDAETransformRotate(AnimationChannel.DestinationObject).Axis.z:=AnimationChannelKeyFrame.Values[2];
         TpvDAETransformRotate(AnimationChannel.DestinationObject).Angle:=AnimationChannelKeyFrame.Values[3];
        end;
       end;
      end else if AnimationChannel.DestinationObject is TpvDAETransformScale then begin
       case length(AnimationChannelKeyFrame.Values) of
        1:begin
         case AnimationChannel.DestinationElement of
          dlacdeX:begin
           TpvDAETransformScale(AnimationChannel.DestinationObject).Scale.x:=AnimationChannelKeyFrame.Values[0];
          end;
          dlacdeY:begin
           TpvDAETransformScale(AnimationChannel.DestinationObject).Scale.y:=AnimationChannelKeyFrame.Values[0];
          end;
          dlacdeZ:begin
           TpvDAETransformScale(AnimationChannel.DestinationObject).Scale.z:=AnimationChannelKeyFrame.Values[0];
          end;
         end;
        end;
        3:begin
         TpvDAETransformScale(AnimationChannel.DestinationObject).Scale.x:=AnimationChannelKeyFrame.Values[0];
         TpvDAETransformScale(AnimationChannel.DestinationObject).Scale.y:=AnimationChannelKeyFrame.Values[1];
         TpvDAETransformScale(AnimationChannel.DestinationObject).Scale.z:=AnimationChannelKeyFrame.Values[2];
        end;
       end;
      end else if AnimationChannel.DestinationObject is TpvDAETransformTranslate then begin
       case length(AnimationChannelKeyFrame.Values) of
        1:begin
         case AnimationChannel.DestinationElement of
          dlacdeX:begin
           TpvDAETransformTranslate(AnimationChannel.DestinationObject).Offset.x:=AnimationChannelKeyFrame.Values[0];
          end;
          dlacdeY:begin
           TpvDAETransformTranslate(AnimationChannel.DestinationObject).Offset.y:=AnimationChannelKeyFrame.Values[0];
          end;
          dlacdeZ:begin
           TpvDAETransformTranslate(AnimationChannel.DestinationObject).Offset.z:=AnimationChannelKeyFrame.Values[0];
          end;
         end;
        end;
        3:begin
         TpvDAETransformTranslate(AnimationChannel.DestinationObject).Offset.x:=AnimationChannelKeyFrame.Values[0];
         TpvDAETransformTranslate(AnimationChannel.DestinationObject).Offset.y:=AnimationChannelKeyFrame.Values[1];
         TpvDAETransformTranslate(AnimationChannel.DestinationObject).Offset.z:=AnimationChannelKeyFrame.Values[2];
        end;
       end;
      end else if AnimationChannel.DestinationObject is TpvDAETransformMatrix then begin
       case length(AnimationChannelKeyFrame.Values) of
        1:begin
         x:=AnimationChannel.DestinationElement and 3;
         y:=AnimationChannel.DestinationElement shr 2;
         TpvDAETransformMatrix(AnimationChannel.DestinationObject).Matrix[x,y]:=AnimationChannelKeyFrame.Values[0];
        end;
        4:begin
         y:=AnimationChannel.DestinationElement shr 2;
         TpvDAETransformMatrix(AnimationChannel.DestinationObject).Matrix[0,y]:=AnimationChannelKeyFrame.Values[0];
         TpvDAETransformMatrix(AnimationChannel.DestinationObject).Matrix[1,y]:=AnimationChannelKeyFrame.Values[1];
         TpvDAETransformMatrix(AnimationChannel.DestinationObject).Matrix[2,y]:=AnimationChannelKeyFrame.Values[2];
         TpvDAETransformMatrix(AnimationChannel.DestinationObject).Matrix[3,y]:=AnimationChannelKeyFrame.Values[3];
        end;
        16:begin
         TpvDAETransformMatrix(AnimationChannel.DestinationObject).Matrix:=TpvMatrix4x4(pointer(@AnimationChannelKeyFrame.Values[0])^);
        end;
       end;
      end;
     end;
    end;
   end;
  end;
  procedure UpdateSkeleton(VisualScene:TpvDAEVisualScene;const Matrix:TpvMatrix4x4);
   procedure UpdateNode(Node:TpvDAENode;Matrix:TpvMatrix4x4);
   var i:TpvInt32;
       Transform:TpvDAETransform;
   begin
    for i:=0 to Node.Transforms.Count-1 do begin
     Transform:=Node.Transforms[i];
     if Transform is TpvDAETransformMatrix then begin
      Transform.Matrix[3,3]:=1;
     end;
     Transform.Convert;
     Matrix:=Transform.Matrix*Matrix;
    end;
    Node.Matrix:=Matrix;
    for i:=0 to Node.Nodes.Count-1 do begin
     UpdateNode(Node.Nodes[i],Matrix);
    end;
    for i:=0 to Node.Cameras.Count-1 do begin
     Node.Cameras[i].Matrix:=Matrix;
    end;
   end;
  begin
   if assigned(VisualScene.Root) then begin
    UpdateNode(VisualScene.Root,Matrix);
   end;
  end;
  procedure ProcessNode(Node:TpvDAENode;Matrix:TpvMatrix4x4);
   procedure ProcessGeometry(Geometry:TpvDAEGeometry;Matrix:TpvMatrix4x4);
    procedure ProcessMesh(Mesh:TpvDAEMesh;Matrix:TpvMatrix4x4);
    const Black:array[0..3] of TpvFloat=(0.0,0.0,0.0,0.0);
    var i,j:TpvInt32;
        v,ov:PpvDAEVertex;
        n,p,no,po:TpvVector3;
        m:TpvMatrix4x4;
        m3:TpvMatrix3x3;
    begin
     for i:=0 to length(Mesh.Indices)-1 do begin
      v:=@Mesh.Vertices[Mesh.Indices[i]];
      n:=v^.Normal;
      p:=v^.Position;
      for j:=0 to length(Mesh.MorphTargetVertices)-1 do begin
       ov:=@Mesh.MorphTargetVertices[j,Mesh.Indices[i]];
       n:=n.Lerp(ov^.Normal,Geometry.MorphTargetWeights[j]);
       p:=p.Lerp(ov^.Position,Geometry.MorphTargetWeights[j]);
      end;
      if v^.CountBlendWeights<=0 then begin
       no:=n;
       po:=p;
       m:=Matrix;
       no:=m.Inverse.MulTransposedBasis(no);
       po:=m*po;
      end else begin
       m:=Geometry.BindShapeMatrix;
       n:=m.Inverse.MulTransposedBasis(n);
       p:=m*p;
       no:=TpvVector3.Create(0.0,0.0,0.0);
       po:=TpvVector3.Create(0.0,0.0,0.0);
       for j:=0 to v^.CountBlendWeights-1 do begin
        if v^.BlendIndices[j]<0 then begin
         m:=Geometry.InverseBindMatrices[v^.BlendIndices[j]]*Matrix;
        end else begin
         m:=Geometry.InverseBindMatrices[v^.BlendIndices[j]]*TpvDAENode(Geometry.JointNodes[v^.BlendIndices[j]]).Matrix;
        end;
        no:=no+((m.ToMatrix3x3.Inverse.Transpose*n)*v.BlendWeights[j]);
        po:=po+((m*p)*v.BlendWeights[j]);
       end;
      end;
      StaticAABB.Min.x:=Min(StaticAABB.Min.x,po.x);
      StaticAABB.Min.y:=Min(StaticAABB.Min.y,po.y);
      StaticAABB.Min.z:=Min(StaticAABB.Min.z,po.z);
      StaticAABB.Max.x:=Max(StaticAABB.Max.x,po.x);
      StaticAABB.Max.y:=Max(StaticAABB.Max.y,po.y);
      StaticAABB.Max.z:=Max(StaticAABB.Max.z,po.z);
     end;
    end;
   var i:TpvInt32;
   begin
    for i:=0 to Geometry.Count-1 do begin
     ProcessMesh(Geometry[i],Matrix);
    end;
   end;
  var i:TpvInt32;
      Transform:TpvDAETransform;
  begin
   for i:=0 to Node.Transforms.Count-1 do begin
    Transform:=Node.Transforms[i];
    Matrix:=Transform.Matrix*Matrix;
   end;
   for i:=0 to Node.Geometries.Count-1 do begin
    ProcessGeometry(Node.Geometries[i],Matrix);
   end;
   for i:=0 to Node.Nodes.Count-1 do begin
    ProcessNode(Node.Nodes[i],Matrix);
   end;
  end;
 begin
  StaticAABB.Min.x:=MaxSingle;
  StaticAABB.Min.y:=MaxSingle;
  StaticAABB.Min.z:=MaxSingle;
  StaticAABB.Max.x:=-MaxSingle;
  StaticAABB.Max.y:=-MaxSingle;
  StaticAABB.Max.z:=-MaxSingle;
  if assigned(MainVisualScene) and assigned(MainVisualScene.Root) then begin
   UpdateSkeleton(MainVisualScene,TpvMatrix4x4.Identity);
   ProcessNode(MainVisualScene.Root,TpvMatrix4x4.Identity);
   MaxKeyFrameCount:=0;
   GetMaxAnimationKeyCount;
   for KeyFrameIndex:=0 to MaxKeyFrameCount-1 do begin
    UpdateSkeleton(MainVisualScene,TpvMatrix4x4.Identity);
    ProcessNode(MainVisualScene.Root,TpvMatrix4x4.Identity);
   end;
  end;
 end;
 function Convert:boolean;
 begin
  ConvertMaterials;
  ConvertContent;
  ConstructStaticAABB;
  result:=assigned(MainLibraryVisualScene);
 end;
var Index:TpvInt32;
    XML:TpvXML;
    Next,SubNext:TpvPointer;
begin
 result:=false;
 XML:=TpvXML.Create;
 try
  IDStringHashMap:=TpvDAEStringHashMap.Create;
  NodeIDStringHashMap:=TpvDAEStringHashMap.Create;
  MorphTargetWeightIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibraryImagesIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibraryImages:=nil;
  LibraryMaterialsIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibraryMaterials:=nil;
  LibraryEffectsIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibraryEffects:=nil;
  LibrarySourcesIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibrarySources:=nil;
  LibrarySourceDatasIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibrarySourceDatas:=nil;
  LibraryVerticesesIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibraryVerticeses:=nil;
  LibraryGeometriesIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibraryGeometries:=nil;
  LibraryControllersIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibraryControllers:=nil;
  LibraryAnimationsIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibraryAnimationList:=TList.Create;
  LibraryAnimations:=nil;
  LibraryAnimationClipsIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibraryAnimationClipList:=TList.Create;
  LibraryAnimationClips:=nil;
  LibraryCamerasIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibraryCameras:=nil;
  LibraryLightsIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibraryLights:=nil;
  LibraryVisualScenesIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibraryVisualScenes:=nil;
  LibraryNodesIDStringHashMap:=TpvDAEStringHashMap.Create;
  LibraryNodes:=nil;
  try
   if XML.Parse(Stream) then begin
    COLLADAVersion:='1.5.0';
    AuthoringTool:='';
    Created:=Now;
    Modified:=Now;
    UnitMeter:=1.0;
    UnitName:='meter';
    UpAxis:=dluaYUP;
    MainLibraryVisualScene:=nil;
    Materials.Clear;
    BadAccessor:=false;
    FlipAngle:=false;
    NegJoints:=false;
    CollectIDs(XML.Root);
    result:=ParseRoot(XML.Root);
    if result then begin
     result:=Convert;
    end;
   end;
  finally
   begin
    while assigned(LibraryNodes) do begin
     Next:=LibraryNodes^.Next;
     LibraryNodes^.ID:='';
     LibraryNodes^.SID:='';
     LibraryNodes^.Name:='';
     for Index:=0 to length(LibraryNodes^.InstanceMaterials)-1 do begin
      SetLength(LibraryNodes^.InstanceMaterials[Index].TexCoordSets,0);
     end;
     SetLength(LibraryNodes^.InstanceMaterials,0);
     LibraryNodes^.InstanceNode:='';
     if LibraryNodes^.NodeType=ntNODE then begin
      FreeAndNil(LibraryNodes^.Children);
     end;
     Finalize(LibraryNodes^);
     FreeMem(LibraryNodes);
     LibraryNodes:=Next;
    end;
    LibraryNodesIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryVisualScenes) do begin
     Next:=LibraryVisualScenes^.Next;
     LibraryVisualScenes^.ID:='';
     FreeAndNil(LibraryVisualScenes^.Items);
     Finalize(LibraryVisualScenes^);
     FreeMem(LibraryVisualScenes);
     LibraryVisualScenes:=Next;
    end;
    LibraryVisualScenesIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryCameras) do begin
     Next:=LibraryCameras^.Next;
     LibraryCameras^.ID:='';
     LibraryCameras^.Name:='';
     LibraryCameras^.Camera.Name:='';
     Finalize(LibraryCameras^);
     FreeMem(LibraryCameras);
     LibraryCameras:=Next;
    end;
    LibraryCamerasIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryLights) do begin
     Next:=LibraryLights^.Next;
     LibraryLights^.ID:='';
     LibraryLights^.Name:='';
     FreeMem(LibraryLights);
     LibraryLights:=Next;
    end;
    LibraryLightsIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryGeometries) do begin
     Next:=LibraryGeometries^.Next;
     LibraryGeometries^.ID:='';
     SetLength(LibraryGeometries^.Meshs,0);
     Finalize(LibraryGeometries^);
     FreeMem(LibraryGeometries);
     LibraryGeometries:=Next;
    end;
    LibraryGeometriesIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryControllers) do begin
     Next:=LibraryControllers^.Next;
     LibraryControllers^.ID:='';
     LibraryControllers^.Name:='';
     if assigned(LibraryControllers^.Skin) then begin
      Finalize(LibraryControllers^.Skin^);
      FreeMem(LibraryControllers.Skin);
     end;
     if assigned(LibraryControllers^.Morph) then begin
      Finalize(LibraryControllers^.Morph^);
      FreeMem(LibraryControllers.Morph);
     end;
     Finalize(LibraryControllers^);
     FreeMem(LibraryControllers);
     LibraryControllers:=Next;
    end;
    LibraryControllersIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryAnimations) do begin
     Next:=LibraryAnimations^.Next;
     LibraryAnimations^.ID:='';
     LibraryAnimations^.Name:='';
     Finalize(LibraryAnimations^);
     FreeMem(LibraryAnimations);
     LibraryAnimations:=Next;
    end;
    LibraryAnimationList.Free;
    LibraryAnimationsIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryAnimationClips) do begin
     Next:=LibraryAnimationClips^.Next;
     LibraryAnimationClips^.ID:='';
     LibraryAnimationClips^.Name:='';
     Finalize(LibraryAnimationClips^);
     FreeMem(LibraryAnimationClips);
     LibraryAnimationClips:=Next;
    end;
    LibraryAnimationClipList.Free;
    LibraryAnimationClipsIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryVerticeses) do begin
     Next:=LibraryVerticeses^.Next;
     LibraryVerticeses^.ID:='';
     SetLength(LibraryVerticeses^.Inputs,0);
     FreeMem(LibraryVerticeses);
     LibraryVerticeses:=Next;
    end;
    LibraryVerticesesIDStringHashMap.Free;
   end;
   begin
    while assigned(LibrarySources) do begin
     Next:=LibrarySources^.Next;
     LibrarySources^.ID:='';
     FreeAndNil(LibrarySources^.SourceDatas);
     LibrarySources^.Accessor.Source:='';
     SetLength(LibrarySources^.Accessor.Params,0);
     FreeMem(LibrarySources);
     LibrarySources:=Next;
    end;
    LibrarySourcesIDStringHashMap.Free;
   end;
   begin
    while assigned(LibrarySourceDatas) do begin
     Next:=LibrarySourceDatas^.Next;
     LibrarySourceDatas^.ID:='';
     SetLength(LibrarySourceDatas^.Data,0);
     SetLength(LibrarySourceDatas^.Strings,0);
     FreeMem(LibrarySourceDatas);
     LibrarySourceDatas:=Next;
    end;
    LibrarySourceDatasIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryEffects) do begin
     Next:=LibraryEffects^.Next;
     LibraryEffects^.ID:='';
     LibraryEffects^.Name:='';
     while assigned(LibraryEffects^.Surfaces) do begin
      SubNext:=LibraryEffects^.Surfaces^.Next;
      LibraryEffects^.Surfaces^.SID:='';
      LibraryEffects^.Surfaces^.InitFrom:='';
      LibraryEffects^.Surfaces^.Format:='';
      FreeMem(LibraryEffects^.Surfaces);
      LibraryEffects^.Surfaces:=SubNext;
     end;
     while assigned(LibraryEffects^.Sampler2D) do begin
      SubNext:=LibraryEffects^.Sampler2D^.Next;
      LibraryEffects^.Sampler2D^.SID:='';
      LibraryEffects^.Sampler2D^.Source:='';
      LibraryEffects^.Sampler2D^.WrapS:='';
      LibraryEffects^.Sampler2D^.WrapT:='';
      LibraryEffects^.Sampler2D^.MinFilter:='';
      LibraryEffects^.Sampler2D^.MagFilter:='';
      LibraryEffects^.Sampler2D^.MipFilter:='';
      Finalize(LibraryEffects^);
      FreeMem(LibraryEffects^.Sampler2D);
      LibraryEffects^.Sampler2D:=SubNext;
     end;
     while assigned(LibraryEffects^.Floats) do begin
      SubNext:=LibraryEffects^.Floats^.Next;
      LibraryEffects^.Floats^.SID:='';
      FreeMem(LibraryEffects^.Floats);
      LibraryEffects^.Floats:=SubNext;
     end;
     while assigned(LibraryEffects^.Float4s) do begin
      SubNext:=LibraryEffects^.Float4s^.Next;
      LibraryEffects^.Float4s^.SID:='';
      FreeMem(LibraryEffects^.Float4s);
      LibraryEffects^.Float4s:=SubNext;
     end;
     FreeAndNil(LibraryEffects^.Images);
     FreeMem(LibraryEffects);
     LibraryEffects:=Next;
    end;
    LibraryEffectsIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryMaterials) do begin
     Next:=LibraryMaterials^.Next;
     LibraryMaterials^.ID:='';
     LibraryMaterials^.Name:='';
     LibraryMaterials^.EffectURL:='';
     FreeMem(LibraryMaterials);
     LibraryMaterials:=Next;
    end;
    LibraryMaterialsIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryImages) do begin
     Next:=LibraryImages^.Next;
     LibraryImages^.ID:='';
     LibraryImages^.InitFrom:='';
     FreeMem(LibraryImages);
     LibraryImages:=Next;
    end;
    LibraryImagesIDStringHashMap.Free;
   end;
   IDStringHashMap.Free;
   NodeIDStringHashMap.Free;
   MorphTargetWeightIDStringHashMap.Free;
  end;
 finally
  XML.Free;
 end;
end;

end.
