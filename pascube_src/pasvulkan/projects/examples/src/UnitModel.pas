unit UnitModel;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
 {$ifdef fpc_little_endian}
  {$define little_endian}
 {$else}
  {$ifdef fpc_big_endian}
   {$define big_endian}
  {$endif}
 {$endif}
 {$ifdef fpc_has_internal_sar}
  {$define HasSAR}
 {$endif}
 {-$pic off}
 {$define CAN_INLINE}
 {$ifdef FPC_HAS_TYPE_EXTENDED}
  {$define HAS_TYPE_EXTENDED}
 {$else}
  {$undef HAS_TYPE_EXTENDED}
 {$endif}
 {$ifdef FPC_HAS_TYPE_DOUBLE}
  {$define HAS_TYPE_DOUBLE}
 {$else}
  {$undef HAS_TYPE_DOUBLE}
 {$endif}
 {$ifdef FPC_HAS_TYPE_SINGLE}
  {$define HAS_TYPE_SINGLE}
 {$else}
  {$undef HAS_TYPE_SINGLE}
 {$endif}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
 {$realcompatibility off}
 {$localsymbols on}
 {$define little_endian}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$define delphi} 
 {$undef HasSAR}
 {$define UseDIV}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$define HAS_TYPE_SINGLE}
{$endif}
{$ifdef cpu386}
 {$define cpux86}
{$endif}
{$ifdef cpuamd64}
 {$define cpux86}
{$endif}
{$ifdef win32}
 {$define windows}
{$endif}
{$ifdef win64}
 {$define windows}
{$endif}
{$ifdef wince}
 {$define windows}
{$endif}
{$ifdef windows}
 {$define win}
{$endif}
{$ifdef sdl20}
 {$define sdl}
{$endif}
{$rangechecks off}
{$extendedsyntax on}
{$writeableconst on}
{$hints off}
{$booleval off}
{$typedaddress off}
{$stackframes off}
{$varstringchecks on}
{$typeinfo on}
{$overflowchecks off}
{$longstrings on}
{$openstrings on}
{$ifndef HAS_TYPE_DOUBLE}
 {$error No double floating point precision}
{$endif}
{$ifdef fpc}
 {$define CAN_INLINE}
{$else}
 {$undef CAN_INLINE}
 {$ifdef ver180}
  {$define CAN_INLINE}
 {$else}
  {$ifdef conditionalexpressions}
   {$if compilerversion>=18}
    {$define CAN_INLINE}
   {$ifend}
  {$endif}
 {$endif}
{$endif}

interface

uses SysUtils,
     Classes,
     Math,
     Vulkan,
     Kraft,
     PasVulkan.Framework,
     PasVulkan.Streams;

const VULKAN_MODEL_VERTEX_BUFFER_BIND_ID=0;

type PVulkanModelVector2=^TVulkanModelVector2;
     TVulkanModelVector2=packed record
      case TVkInt32 of
       0:(
        x,y:TVkFloat;
       );
       1:(
        u,v:TVkFloat;
       );
       2:(
        r,g:TVkFloat;
       );
     end;

     PVulkanModelVector3=^TVulkanModelVector3;
     TVulkanModelVector3=packed record
      case TVkInt32 of
       0:(
        x,y,z:TVkFloat;
       );
       1:(
        u,v,w:TVkFloat;
       );
       2:(
        r,g,b:TVkFloat;
       );
     end;

     PVulkanModelVector4=^TVulkanModelVector4;
     TVulkanModelVector4=packed record
      case TVkInt32 of
       0:(
        x,y,z,w:TVkFloat;
       );
       1:(
        u,v,w_,q:TVkFloat;
       );
       2:(
        r,g,b,a:TVkFloat;
       );
     end;

     PVulkanModelQuaternion=^TVulkanModelQuaternion;
     TVulkanModelQuaternion=packed record
      x,y,z,w:TVkFloat;
     end;

     PVulkanModelQTangent=^TVulkanModelQTangent;
     TVulkanModelQTangent=packed record
      x,y,z,w:TVkInt16;
     end;

     PVulkanModelMatrix3x3=^TVulkanModelMatrix3x3;
     TVulkanModelMatrix3x3=packed record
      case TVkInt32 of
       0:(
        RawComponents:array[0..2,0..2] of TVkFloat;
       );
       1:(
        Vectors:array[0..2] of TVulkanModelVector3;
       );
       2:(
        Tangent:TVulkanModelVector3;
        Bitangent:TVulkanModelVector3;
        Normal:TVulkanModelVector3;
       );
      end;

     PVulkanModelVertex=^TVulkanModelVertex;
     TVulkanModelVertex=packed record
      Position:TVulkanModelVector3;
      QTangent:TVulkanModelQTangent;
      TexCoord:TVulkanModelVector2;
      Material:TVkInt32;
{     // In future maybe also:
      BlendIndices:array[0..7] of TVkUInt16;
      BlendWeight:array[0..7] of TVkUInt16;
}
     end;

     TVulkanModelVertices=array of TVulkanModelVertex;

     PVulkanModelIndex=^TVulkanModelIndex;
     TVulkanModelIndex=TVkUInt32;

     TVulkanModelIndices=array of TVulkanModelIndex;

     PVulkanModelMaterial=^TVulkanModelMaterial;
     TVulkanModelMaterial=record
      Name:ansistring;
      Texture:ansistring;
      Ambient:TVulkanModelVector3;
      Diffuse:TVulkanModelVector3;
      Emission:TVulkanModelVector3;
      Specular:TVulkanModelVector3;
      Shininess:TVkFloat;
     end;

     TVulkanModelMaterials=array of TVulkanModelMaterial;

     PVulkanModelPart=^TVulkanModelPart;
     TVulkanModelPart=record
      Material:TVkInt32;
      StartIndex:TVkInt32;
      CountIndices:TVkInt32;
     end;

     TVulkanModelParts=array of TVulkanModelPart;

     PVulkanModelSphere=^TVulkanModelSphere;
     TVulkanModelSphere=record
      Center:TVulkanModelVector3;
      Radius:TVkFloat;
     end;

     PVulkanModelAABB=^TVulkanModelAABB;
     TVulkanModelAABB=record
      Min:TVulkanModelVector3;
      Max:TVulkanModelVector3;
     end;

     PVulkanModelObject=^TVulkanModelObject;
     TVulkanModelObject=record
      Name:ansistring;
      Sphere:TVulkanModelSphere;
      AABB:TVulkanModelAABB;
     end;

     TVulkanModelObjects=array of TVulkanModelObject;

     EModelLoad=class(Exception);

     TVulkanModelBuffers=array of TpvVulkanBuffer;

     PVulkanModelBufferSize=^TVulkanModelBufferSize;
     TVulkanModelBufferSize=TVkUInt32;

     TVulkanModelBufferSizes=array of TVulkanModelBufferSize;

     TVulkanModel=class
      private
       fVulkanDevice:TpvVulkanDevice;
       fUploaded:boolean;
       fSphere:TVulkanModelSphere;
       fAABB:TVulkanModelAABB;
       fMaterials:TVulkanModelMaterials;
       fCountMaterials:TVkInt32;
       fVertices:TVulkanModelVertices;
       fCountVertices:TVkInt32;
       fIndices:TVulkanModelIndices;
       fCountIndices:TVkInt32;
       fParts:TVulkanModelParts;
       fCountParts:TVkInt32;
       fObjects:TVulkanModelObjects;
       fCountObjects:TVkInt32;
       fKraftMesh:TKraftMesh;
       fKraftConvexHull:TKraftConvexHull;
       fVertexBuffers:TVulkanModelBuffers;
       fIndexBuffers:TVulkanModelBuffers;
       fBufferSizes:TVulkanModelBufferSizes;
       fCountBuffers:TVkInt32;
      public
       constructor Create(const aVulkanDevice:TpvVulkanDevice); reintroduce;
       destructor Destroy; override;
       procedure Clear;
       procedure MakeCube(const aSizeX,aSizeY,aSizeZ:TVkFloat);
       procedure LoadFromStream(const aStream:TStream;const aDoFree:boolean=false);
       procedure Upload(const aQueue:TpvVulkanQueue;
                        const aCommandBuffer:TpvVulkanCommandBuffer;
                        const aFence:TpvVulkanFence);
       procedure Unload;
       procedure Draw(const aCommandBuffer:TpvVulkanCommandBuffer;const aInstanceCount:TVkUInt32=1;const aFirstInstance:TVkUInt32=0);
       property Uploaded:boolean read fUploaded;
       property Sphere:TVulkanModelSphere read fSphere;
       property AABB:TVulkanModelAABB read fAABB;
       property Materials:TVulkanModelMaterials read fMaterials;
       property CountMaterials:TVkInt32 read fCountMaterials;
       property Vertices:TVulkanModelVertices read fVertices;
       property CountVertices:TVkInt32 read fCountVertices;
       property Indices:TVulkanModelIndices read fIndices;
       property CountIndices:TVkInt32 read fCountIndices;
       property Parts:TVulkanModelParts read fParts;
       property CountParts:TVkInt32 read fCountParts;
       property Objects:TVulkanModelObjects read fObjects;
       property CountObjects:TVkInt32 read fCountObjects;
       property KraftMesh:TKraftMesh read fKraftMesh write fKraftMesh;
       property KraftConvexHull:TKraftConvexHull read fKraftConvexHull write fKraftConvexHull;
     end;

implementation

uses UnitChunkStream;

function VulkanModelVector3Length(const v:TVulkanModelVector3):TVkFloat; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if result>0.0 then begin
  result:=sqrt(result);
 end else begin
  result:=0.0;
 end;
end;

function VulkanModelVector3Normalize(const v:TVulkanModelVector3):TVulkanModelVector3; {$ifdef CAN_INLINE}inline;{$endif}
var f:TVkFloat;
begin
 f:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if f>0.0 then begin
  f:=sqrt(f);
  result.x:=v.x/f;
  result.y:=v.y/f;
  result.z:=v.z/f;
 end else begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
 end;
end;

function VulkanModelVector3Cross(const v0,v1:TVulkanModelVector3):TVulkanModelVector3; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=(v0.y*v1.z)-(v0.z*v1.y);
 result.y:=(v0.z*v1.x)-(v0.x*v1.z);
 result.z:=(v0.x*v1.y)-(v0.y*v1.x);
end;

function VulkanModelVector3Add(const v0,v1:TVulkanModelVector3):TVulkanModelVector3; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=v0.x+v1.x;
 result.y:=v0.y+v1.y;
 result.z:=v0.z+v1.z;
end;

function VulkanModelVector3Sub(const v0,v1:TVulkanModelVector3):TVulkanModelVector3; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=v0.x-v1.x;
 result.y:=v0.y-v1.y;
 result.z:=v0.z-v1.z;
end;

function VulkanModelVector3Dot(const v0,v1:TVulkanModelVector3):TVkFloat; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=(v0.x*v1.x)+(v0.y*v1.y)+(v0.z*v1.z);
end;

function VulkanModelVector3ScalarMul(const v:TVulkanModelVector3;const f:TVkFloat):TVulkanModelVector3; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=v.x*f;
 result.y:=v.y*f;
 result.z:=v.z*f;
end;

procedure VulkanModelRobustOrthoNormalize(var Tangent,Bitangent,Normal:TVulkanModelVector3;const Tolerance:TVkFloat=1e-3);
var Bisector,Axis:TVulkanModelVector3;
begin
 begin
  if VulkanModelVector3Length(Normal)<Tolerance then begin
   // Degenerate case, compute new normal
   Normal:=VulkanModelVector3Cross(Tangent,Bitangent);
   if VulkanModelVector3Length(Normal)<Tolerance then begin
    Tangent.x:=1.0;
    Tangent.y:=0.0;
    Tangent.z:=0.0;
    Bitangent.x:=0.0;
    Bitangent.y:=1.0;
    Bitangent.z:=0.0;
    Normal.x:=0.0;
    Normal.y:=0.0;
    Normal.z:=1.0;
    exit;
   end;
  end;
  Normal:=VulkanModelVector3Normalize(Normal);
 end;
 begin
  // Project tangent and bitangent onto the normal orthogonal plane
  Tangent:=VulkanModelVector3Sub(Tangent,VulkanModelVector3ScalarMul(Normal,VulkanModelVector3Dot(Tangent,Normal)));
  Bitangent:=VulkanModelVector3Sub(Bitangent,VulkanModelVector3ScalarMul(Normal,VulkanModelVector3Dot(Bitangent,Normal)));
 end;
 begin
  // Check for several degenerate cases
  if VulkanModelVector3Length(Tangent)<Tolerance then begin
   if VulkanModelVector3Length(Bitangent)<Tolerance then begin
    Tangent:=VulkanModelVector3Normalize(Normal);
    if (Tangent.x<=Tangent.y) and (Tangent.x<=Tangent.z) then begin
     Tangent.x:=1.0;
     Tangent.y:=0.0;
     Tangent.z:=0.0;
    end else if (Tangent.y<=Tangent.x) and (Tangent.y<=Tangent.z) then begin
     Tangent.x:=0.0;
     Tangent.y:=1.0;
     Tangent.z:=0.0;
    end else begin
     Tangent.x:=0.0;
     Tangent.y:=0.0;
     Tangent.z:=1.0;
    end;
    Tangent:=VulkanModelVector3Sub(Tangent,VulkanModelVector3ScalarMul(Normal,VulkanModelVector3Dot(Tangent,Normal)));
    Bitangent:=VulkanModelVector3Normalize(VulkanModelVector3Cross(Normal,Tangent));
   end else begin
    Tangent:=VulkanModelVector3Normalize(VulkanModelVector3Cross(Bitangent,Normal));
   end;
  end else begin
   Tangent:=VulkanModelVector3Normalize(Tangent);
   if VulkanModelVector3Length(Bitangent)<Tolerance then begin
    Bitangent:=VulkanModelVector3Normalize(VulkanModelVector3Cross(Normal,Tangent));
   end else begin
    Bitangent:=VulkanModelVector3Normalize(Bitangent);
    Bisector:=VulkanModelVector3Add(Tangent,Bitangent);
    if VulkanModelVector3Length(Bisector)<Tolerance then begin
     Bisector:=Tangent;
    end else begin
     Bisector:=VulkanModelVector3Normalize(Bisector);
    end;
    Axis:=VulkanModelVector3Normalize(VulkanModelVector3Cross(Bisector,Normal));
    if VulkanModelVector3Dot(Axis,Tangent)>0.0 then begin
     Tangent:=VulkanModelVector3Normalize(VulkanModelVector3Add(Bisector,Axis));
     Bitangent:=VulkanModelVector3Normalize(VulkanModelVector3Sub(Bisector,Axis));
    end else begin
     Tangent:=VulkanModelVector3Normalize(VulkanModelVector3Sub(Bisector,Axis));
     Bitangent:=VulkanModelVector3Normalize(VulkanModelVector3Add(Bisector,Axis));
    end;
   end;
  end;
 end;
 Bitangent:=VulkanModelVector3Normalize(VulkanModelVector3Cross(Normal,Tangent));
 Tangent:=VulkanModelVector3Normalize(VulkanModelVector3Cross(Bitangent,Normal));
 Normal:=VulkanModelVector3Normalize(VulkanModelVector3Cross(Tangent,Bitangent));
end;

function VulkanModelMatrix3x3ToQTangent(aMatrix:TVulkanModelMatrix3x3):TVulkanModelQuaternion;
const Threshold=1.0/32767.0;
var Scale,t,s,Renormalization:TVkFloat;
begin
 VulkanModelRobustOrthoNormalize(aMatrix.Tangent,
                                 aMatrix.Bitangent,
                                 aMatrix.Normal);
 if ((((((aMatrix.RawComponents[0,0]*aMatrix.RawComponents[1,1]*aMatrix.RawComponents[2,2])+
         (aMatrix.RawComponents[0,1]*aMatrix.RawComponents[1,2]*aMatrix.RawComponents[2,0])
        )+
        (aMatrix.RawComponents[0,2]*aMatrix.RawComponents[1,0]*aMatrix.RawComponents[2,1])
       )-
       (aMatrix.RawComponents[0,2]*aMatrix.RawComponents[1,1]*aMatrix.RawComponents[2,0])
      )-
      (aMatrix.RawComponents[0,1]*aMatrix.RawComponents[1,0]*aMatrix.RawComponents[2,2])
     )-
     (aMatrix.RawComponents[0,0]*aMatrix.RawComponents[1,2]*aMatrix.RawComponents[2,1])
    )<0.0 then begin
  // Reflection matrix, so flip y axis in case the tangent frame encodes a reflection
  Scale:=-1.0;
  aMatrix.RawComponents[2,0]:=-aMatrix.RawComponents[2,0];
  aMatrix.RawComponents[2,1]:=-aMatrix.RawComponents[2,1];
  aMatrix.RawComponents[2,2]:=-aMatrix.RawComponents[2,2];
 end else begin
  // Rotation matrix, so nothing is doing to do
  Scale:=1.0;
 end;
 begin
  // Convert to quaternion
  t:=aMatrix.RawComponents[0,0]+(aMatrix.RawComponents[1,1]+aMatrix.RawComponents[2,2]);
  if t>2.9999999 then begin
   result.x:=0.0;
   result.y:=0.0;
   result.z:=0.0;
   result.w:=1.0;
  end else if t>0.0000001 then begin
   s:=sqrt(1.0+t)*2.0;
   result.x:=(aMatrix.RawComponents[1,2]-aMatrix.RawComponents[2,1])/s;
   result.y:=(aMatrix.RawComponents[2,0]-aMatrix.RawComponents[0,2])/s;
   result.z:=(aMatrix.RawComponents[0,1]-aMatrix.RawComponents[1,0])/s;
   result.w:=s*0.25;
  end else if (aMatrix.RawComponents[0,0]>aMatrix.RawComponents[1,1]) and (aMatrix.RawComponents[0,0]>aMatrix.RawComponents[2,2]) then begin
   s:=sqrt(1.0+(aMatrix.RawComponents[0,0]-(aMatrix.RawComponents[1,1]+aMatrix.RawComponents[2,2])))*2.0;
   result.x:=s*0.25;
   result.y:=(aMatrix.RawComponents[1,0]+aMatrix.RawComponents[0,1])/s;
   result.z:=(aMatrix.RawComponents[2,0]+aMatrix.RawComponents[0,2])/s;
   result.w:=(aMatrix.RawComponents[1,2]-aMatrix.RawComponents[2,1])/s;
  end else if aMatrix.RawComponents[1,1]>aMatrix.RawComponents[2,2] then begin
   s:=sqrt(1.0+(aMatrix.RawComponents[1,1]-(aMatrix.RawComponents[0,0]+aMatrix.RawComponents[2,2])))*2.0;
   result.x:=(aMatrix.RawComponents[1,0]+aMatrix.RawComponents[0,1])/s;
   result.y:=s*0.25;
   result.z:=(aMatrix.RawComponents[2,1]+aMatrix.RawComponents[1,2])/s;
   result.w:=(aMatrix.RawComponents[2,0]-aMatrix.RawComponents[0,2])/s;
  end else begin
   s:=sqrt(1.0+(aMatrix.RawComponents[2,2]-(aMatrix.RawComponents[0,0]+aMatrix.RawComponents[1,1])))*2.0;
   result.x:=(aMatrix.RawComponents[2,0]+aMatrix.RawComponents[0,2])/s;
   result.y:=(aMatrix.RawComponents[2,1]+aMatrix.RawComponents[1,2])/s;
   result.z:=s*0.25;
   result.w:=(aMatrix.RawComponents[0,1]-aMatrix.RawComponents[1,0])/s;
  end;
  s:=sqr(result.x)+sqr(result.y)+sqr(result.z)+sqr(result.w);
  if s>0.0 then begin
   s:=sqrt(s);
   result.x:=result.x/s;
   result.y:=result.y/s;
   result.z:=result.z/s;
   result.w:=result.w/s;
  end else begin
   result.x:=0.0;
   result.y:=0.0;
   result.z:=0.0;
   result.w:=1.0;
  end;
 end;
 begin
  // Make sure, that we don't end up with 0 as w component
  if abs(result.w)<=Threshold then begin
   Renormalization:=sqrt(1.0-sqr(Threshold));
   result.x:=result.x*Renormalization;
   result.y:=result.y*Renormalization;
   result.z:=result.z*Renormalization;
   if result.w>0.0 then begin
    result.w:=Threshold;
   end else begin
    result.w:=-Threshold;
   end;
  end;
 end;
 if ((Scale<0.0) and (result.w>=0.0)) or ((Scale>=0.0) and (result.w<0.0)) then begin
  // Encode reflection into quaternion's w element by making sign of w negative,
  // if y axis needs to be flipped, otherwise it stays positive
  result.x:=-result.x;
  result.y:=-result.y;
  result.z:=-result.z;
  result.w:=-result.w;
 end;
end;

function VulkanModelMatrix3x3FromQTangent(pQTangent:TVulkanModelQuaternion):TVulkanModelMatrix3x3;
var f,qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:TVkFloat;
begin
 f:=sqr(pQTangent.x)+sqr(pQTangent.y)+sqr(pQTangent.z)+sqr(pQTangent.w);
 if f>0.0 then begin
  f:=sqrt(f);
  pQTangent.x:=pQTangent.x/f;
  pQTangent.y:=pQTangent.y/f;
  pQTangent.z:=pQTangent.z/f;
  pQTangent.w:=pQTangent.w/f;
 end else begin
  pQTangent.x:=0.0;
  pQTangent.y:=0.0;
  pQTangent.z:=0.0;
  pQTangent.w:=1.0;
 end;
 qx2:=pQTangent.x+pQTangent.x;
 qy2:=pQTangent.y+pQTangent.y;
 qz2:=pQTangent.z+pQTangent.z;
 qxqx2:=pQTangent.x*qx2;
 qxqy2:=pQTangent.x*qy2;
 qxqz2:=pQTangent.x*qz2;
 qxqw2:=pQTangent.w*qx2;
 qyqy2:=pQTangent.y*qy2;
 qyqz2:=pQTangent.y*qz2;
 qyqw2:=pQTangent.w*qy2;
 qzqz2:=pQTangent.z*qz2;
 qzqw2:=pQTangent.w*qz2;
 result.RawComponents[0,0]:=1.0-(qyqy2+qzqz2);
 result.RawComponents[0,1]:=qxqy2+qzqw2;
 result.RawComponents[0,2]:=qxqz2-qyqw2;
 result.RawComponents[1,0]:=qxqy2-qzqw2;
 result.RawComponents[1,1]:=1.0-(qxqx2+qzqz2);
 result.RawComponents[1,2]:=qyqz2+qxqw2;
 result.RawComponents[2,0]:=(result.RawComponents[0,1]*result.RawComponents[1,2])-(result.RawComponents[0,2]*result.RawComponents[1,1]);
 result.RawComponents[2,1]:=(result.RawComponents[0,2]*result.RawComponents[1,0])-(result.RawComponents[0,0]*result.RawComponents[1,2]);
 result.RawComponents[2,2]:=(result.RawComponents[0,0]*result.RawComponents[1,1])-(result.RawComponents[0,1]*result.RawComponents[1,0]);
{result.RawComponents[2,0]:=qxqz2+qyqw2;
 result.RawComponents[2,1]:=qyqz2-qxqw2;
 result.RawComponents[2,2]:=1.0-(qxqx2+qyqy2);}
 if pQTangent.w<0.0 then begin
  result.RawComponents[2,0]:=-result.RawComponents[2,0];
  result.RawComponents[2,1]:=-result.RawComponents[2,1];
  result.RawComponents[2,2]:=-result.RawComponents[2,2];
 end;
end;

constructor TVulkanModel.Create(const aVulkanDevice:TpvVulkanDevice);
begin
 inherited Create;
 fVulkanDevice:=aVulkanDevice;
 fUploaded:=false;
 fKraftMesh:=nil;
 fKraftConvexHull:=nil;
 fVertexBuffers:=nil;
 fIndexBuffers:=nil;
 fBufferSizes:=nil;
 fCountBuffers:=0;
 Clear;
end;

destructor TVulkanModel.Destroy;
begin
 Unload;
 Clear;
 inherited Destroy;
end;

procedure TVulkanModel.Clear;
begin
 fMaterials:=nil;
 fCountMaterials:=0;
 fVertices:=nil;
 fCountVertices:=0;
 fIndices:=nil;
 fCountIndices:=0;
 fParts:=nil;
 fCountParts:=0;
 fObjects:=nil;
 fCountObjects:=0;
end;

procedure TVulkanModel.MakeCube(const aSizeX,aSizeY,aSizeZ:TVkFloat);
type PCubeVertex=^TCubeVertex;
     TCubeVertex=record
      Position:TVulkanModelVector3;
      Tangent:TVulkanModelVector3;
      Bitangent:TVulkanModelVector3;
      Normal:TVulkanModelVector3;
      TexCoord:TVulkanModelVector2;
     end;
const CubeVertices:array[0..23] of TCubeVertex=
       (// Left
        (Position:(x:-1;y:-1;z:-1;);Tangent:(x:0;y:0;z:1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:-1;y:0;z:0;);TexCoord:(u:0;v:0)),
        (Position:(x:-1;y: 1;z:-1;);Tangent:(x:0;y:0;z:1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:-1;y:0;z:0;);TexCoord:(u:0;v:1)),
        (Position:(x:-1;y: 1;z: 1;);Tangent:(x:0;y:0;z:1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:-1;y:0;z:0;);TexCoord:(u:1;v:1)),
        (Position:(x:-1;y:-1;z: 1;);Tangent:(x:0;y:0;z:1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:-1;y:0;z:0;);TexCoord:(u:1;v:0)),

        // Right
        (Position:(x: 1;y:-1;z: 1;);Tangent:(x:0;y:0;z:-1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:1;y:0;z:0;);TexCoord:(u:0;v:0)),
        (Position:(x: 1;y: 1;z: 1;);Tangent:(x:0;y:0;z:-1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:1;y:0;z:0;);TexCoord:(u:0;v:1)),
        (Position:(x: 1;y: 1;z:-1;);Tangent:(x:0;y:0;z:-1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:1;y:0;z:0;);TexCoord:(u:1;v:1)),
        (Position:(x: 1;y:-1;z:-1;);Tangent:(x:0;y:0;z:-1;);Bitangent:(x:0;y:1;z:0;);Normal:(x:1;y:0;z:0;);TexCoord:(u:1;v:0)),

        // Bottom
        (Position:(x:-1;y:-1;z:-1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:1;);Normal:(x:0;y:-1;z:0;);TexCoord:(u:0;v:0)),
        (Position:(x:-1;y:-1;z: 1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:1;);Normal:(x:0;y:-1;z:0;);TexCoord:(u:0;v:1)),
        (Position:(x: 1;y:-1;z: 1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:1;);Normal:(x:0;y:-1;z:0;);TexCoord:(u:1;v:1)),
        (Position:(x: 1;y:-1;z:-1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:1;);Normal:(x:0;y:-1;z:0;);TexCoord:(u:1;v:0)),

        // Top
        (Position:(x:-1;y: 1;z:-1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:-1;);Normal:(x:0;y:1;z:0;);TexCoord:(u:0;v:0)),
        (Position:(x: 1;y: 1;z:-1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:-1;);Normal:(x:0;y:1;z:0;);TexCoord:(u:0;v:1)),
        (Position:(x: 1;y: 1;z: 1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:-1;);Normal:(x:0;y:1;z:0;);TexCoord:(u:1;v:1)),
        (Position:(x:-1;y: 1;z: 1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:0;z:-1;);Normal:(x:0;y:1;z:0;);TexCoord:(u:1;v:0)),

        // Back
        (Position:(x: 1;y:-1;z:-1;);Tangent:(x:-1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:-1;);TexCoord:(u:0;v:0)),
        (Position:(x: 1;y: 1;z:-1;);Tangent:(x:-1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:-1;);TexCoord:(u:0;v:1)),
        (Position:(x:-1;y: 1;z:-1;);Tangent:(x:-1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:-1;);TexCoord:(u:1;v:1)),
        (Position:(x:-1;y:-1;z:-1;);Tangent:(x:-1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:-1;);TexCoord:(u:1;v:0)),

        // Front
        (Position:(x:-1;y:-1;z:1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:1;);TexCoord:(u:0;v:0)),
        (Position:(x:-1;y: 1;z:1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:1;);TexCoord:(u:0;v:1)),
        (Position:(x: 1;y: 1;z:1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:1;);TexCoord:(u:1;v:1)),
        (Position:(x: 1;y:-1;z:1;);Tangent:(x:1;y:0;z:0;);Bitangent:(x:0;y:1;z:0;);Normal:(x:0;y:0;z:1;);TexCoord:(u:1;v:0))

       );
      CubeIndices:array[0..35] of TVkInt32=
       ( 0, 1, 2,
         0, 2, 3,

         // Right
         4, 5, 6,
         4, 6, 7,

         // Bottom
         8, 9, 10,
         8, 10, 11,

         // Top
         12, 13, 14,
         12, 14, 15,

         // Back
         16, 17, 18,
         16, 18, 19,

         // Front
         20, 21, 22,
         20, 22, 23);
var Index:TVkInt32;
    Material:PVulkanModelMaterial;
    ModelVertex:PVulkanModelVertex;
    CubeVertex:PCubeVertex;
    m:TVulkanModelMatrix3x3;
    q:TVulkanModelQuaternion;
    Part:PVulkanModelPart;
    AObject:PVulkanModelObject;
begin

 fCountMaterials:=1;
 fCountVertices:=length(CubeVertices);
 fCountIndices:=length(CubeIndices);
 fCountParts:=1;
 fCountObjects:=1;

 SetLength(fMaterials,fCountMaterials);
 SetLength(fVertices,fCountVertices);
 SetLength(fIndices,fCountIndices);
 SetLength(fParts,fCountParts);
 SetLength(fObjects,fCountObjects);

 Material:=@fMaterials[0];
 Material^.Name:='cube';
 Material^.Texture:='cube';
 Material^.Ambient.r:=0.1;
 Material^.Ambient.g:=0.1;
 Material^.Ambient.b:=0.1;
 Material^.Diffuse.r:=0.8;
 Material^.Diffuse.g:=0.8;
 Material^.Diffuse.b:=0.8;
 Material^.Emission.r:=0.0;
 Material^.Emission.g:=0.0;
 Material^.Emission.b:=0.0;
 Material^.Specular.r:=0.1;
 Material^.Specular.g:=0.1;
 Material^.Specular.b:=0.1;
 Material^.Shininess:=1.0;

 for Index:=0 to fCountVertices-1 do begin
  ModelVertex:=@fVertices[Index];
  CubeVertex:=@CubeVertices[Index];
  ModelVertex^.Position.x:=CubeVertex^.Position.x*aSizeX*0.5;
  ModelVertex^.Position.y:=CubeVertex^.Position.y*aSizeY*0.5;
  ModelVertex^.Position.z:=CubeVertex^.Position.z*aSizeZ*0.5;
  m.Tangent:=CubeVertex^.Tangent;
  m.Bitangent:=CubeVertex^.Bitangent;
  m.Normal:=CubeVertex^.Normal;
  q:=VulkanModelMatrix3x3ToQTangent(m);
  ModelVertex^.QTangent.x:=Min(Max(round(Min(Max(q.x,-1.0),1.0)*32767),-32767),32767);
  ModelVertex^.QTangent.y:=Min(Max(round(Min(Max(q.y,-1.0),1.0)*32767),-32767),32767);
  ModelVertex^.QTangent.z:=Min(Max(round(Min(Max(q.z,-1.0),1.0)*32767),-32767),32767);
  ModelVertex^.QTangent.w:=Min(Max(round(Min(Max(q.w,-1.0),1.0)*32767),-32767),32767);
  ModelVertex^.TexCoord:=CubeVertex^.TexCoord;
  ModelVertex^.Material:=0;
 end;

 for Index:=0 to fCountIndices-1 do begin
  fIndices[Index]:=CubeIndices[Index];
 end;

 Part:=@fParts[0];
 Part^.Material:=0;
 Part^.StartIndex:=0;
 Part^.CountIndices:=fCountIndices;

 AObject:=@fObjects[0];
 AObject^.Name:='cube';
 AObject^.AABB.Min.x:=-(aSizeX*0.5);
 AObject^.AABB.Min.y:=-(aSizeY*0.5);
 AObject^.AABB.Min.z:=-(aSizeZ*0.5);
 AObject^.AABB.Max.x:=aSizeX*0.5;
 AObject^.AABB.Max.y:=aSizeY*0.5;
 AObject^.AABB.Max.z:=aSizeZ*0.5;
 AObject^.Sphere.Center:=VulkanModelVector3ScalarMul(VulkanModelVector3Sub(AObject^.AABB.Max,AObject^.AABB.Min),0.5);
 AObject^.Sphere.Radius:=VulkanModelVector3Length(VulkanModelVector3Sub(AObject^.AABB.Max,AObject^.AABB.Min))/sqrt(3.0);

end;

procedure TVulkanModel.LoadFromStream(const aStream:TStream;const aDoFree:boolean=false);
const ModelSignature:TChunkSignature=('m','d','l',#0);
      ModelVersion:TVkUInt32=0;
var Signature:TChunkSignature;
    Version:TVkUInt32;
    ChunkOffset,CountChunks:TVkInt32;
    Chunks:TChunks;
 function GetChunkStream(const ChunkSignature:TChunkSignature;const WithMemoryCopy:boolean=true):TChunkStream;
 var Index:TVkInt32;
     Chunk:PChunk;
 begin
  result:=nil;
  for Index:=0 to CountChunks-1 do begin
   Chunk:=@Chunks[Index];
   if Chunk^.Signature=ChunkSignature then begin
    result:=TChunkStream.Create(aStream,Chunk^.Offset,Chunk^.Size,WithMemoryCopy);
    exit;
   end;
  end;
 end;
 procedure ReadBOVO;
 const ChunkSignature:TChunkSignature=('B','O','V','O');
 var ChunkStream:TChunkStream;
 begin
  ChunkStream:=GetChunkStream(ChunkSignature,false);
  try
   if assigned(ChunkStream) and (ChunkStream.Size<>0) then begin
    fSphere.Center.x:=ChunkStream.ReadFloat;
    fSphere.Center.y:=ChunkStream.ReadFloat;
    fSphere.Center.z:=ChunkStream.ReadFloat;
    fSphere.Radius:=ChunkStream.ReadFloat;
    fAABB.Min.x:=ChunkStream.ReadFloat;
    fAABB.Min.y:=ChunkStream.ReadFloat;
    fAABB.Min.z:=ChunkStream.ReadFloat;
    fAABB.Max.x:=ChunkStream.ReadFloat;
    fAABB.Max.y:=ChunkStream.ReadFloat;
    fAABB.Max.z:=ChunkStream.ReadFloat;
   end else begin
    raise EModelLoad.Create('Missing "'+String(ChunkSignature[0]+ChunkSignature[1]+ChunkSignature[2]+ChunkSignature[3])+'" chunk');
   end;
  finally
   ChunkStream.Free;
  end;
 end;
 procedure ReadMATE;
 const ChunkSignature:TChunkSignature=('M','A','T','E');
 var ChunkStream:TChunkStream;
     Index:TVkInt32;
     Material:PVulkanModelMaterial;
 begin
  ChunkStream:=GetChunkStream(ChunkSignature,true);
  try
   if assigned(ChunkStream) and (ChunkStream.Size<>0) then begin
    fCountMaterials:=ChunkStream.ReadInt32;
    SetLength(fMaterials,fCountMaterials);
    for Index:=0 to fCountMaterials-1 do begin
     Material:=@fMaterials[Index];
     Material^.Name:=ChunkStream.ReadString;
     Material^.Texture:=ChunkStream.ReadString;
     Material^.Ambient.r:=ChunkStream.ReadFloat;
     Material^.Ambient.g:=ChunkStream.ReadFloat;
     Material^.Ambient.b:=ChunkStream.ReadFloat;
     Material^.Diffuse.r:=ChunkStream.ReadFloat;
     Material^.Diffuse.g:=ChunkStream.ReadFloat;
     Material^.Diffuse.b:=ChunkStream.ReadFloat;
     Material^.Emission.r:=ChunkStream.ReadFloat;
     Material^.Emission.g:=ChunkStream.ReadFloat;
     Material^.Emission.b:=ChunkStream.ReadFloat;
     Material^.Specular.r:=ChunkStream.ReadFloat;
     Material^.Specular.g:=ChunkStream.ReadFloat;
     Material^.Specular.b:=ChunkStream.ReadFloat;
     Material^.Shininess:=ChunkStream.ReadFloat;
    end;
   end else begin
    raise EModelLoad.Create('Missing "'+String(ChunkSignature[0]+ChunkSignature[1]+ChunkSignature[2]+ChunkSignature[3])+'" chunk');
   end;
  finally
   ChunkStream.Free;
  end;
 end;
 procedure ReadVBOS;
 const ChunkSignature:TChunkSignature=('V','B','O','S');
 var ChunkStream:TChunkStream;
     VertexIndex:TVkInt32;
     q:TVulkanModelQuaternion;
     m:TVulkanModelMatrix3x3;
 begin
  ChunkStream:=GetChunkStream(ChunkSignature,true);
  try
   if assigned(ChunkStream) and (ChunkStream.Size<>0) then begin
    fCountVertices:=ChunkStream.ReadInt32;
    SetLength(fVertices,fCountVertices);
    if fCountVertices>0 then begin
     ChunkStream.ReadWithCheck(fVertices[0],fCountVertices*SizeOf(TVulkanModelVertex));
     if assigned(fKraftMesh) then begin
      for VertexIndex:=0 to fCountVertices-1 do begin
       fKraftMesh.AddVertex(Kraft.Vector3(fVertices[VertexIndex].Position.x,fVertices[VertexIndex].Position.y,fVertices[VertexIndex].Position.z));
       q.x:=Vertices[VertexIndex].QTangent.x/32767.0;
       q.y:=Vertices[VertexIndex].QTangent.y/32767.0;
       q.z:=Vertices[VertexIndex].QTangent.z/32767.0;
       q.w:=Vertices[VertexIndex].QTangent.w/32767.0;
       m:=VulkanModelMatrix3x3FromQTangent(q);
       fKraftMesh.AddNormal(Kraft.Vector3(m.Normal.x,m.Normal.y,m.Normal.z));
      end;
     end;
    end;
   end else begin
    raise EModelLoad.Create('Missing "'+String(ChunkSignature[0]+ChunkSignature[1]+ChunkSignature[2]+ChunkSignature[3])+'" chunk');
   end;
  finally
   ChunkStream.Free;
  end;
 end;
 procedure ReadIBOS;
 const ChunkSignature:TChunkSignature=('I','B','O','S');
 var ChunkStream:TChunkStream;
     Index:TVkInt32;
 begin
  ChunkStream:=GetChunkStream(ChunkSignature,true);
  try
   if assigned(ChunkStream) and (ChunkStream.Size<>0) then begin
    fCountIndices:=ChunkStream.ReadInt32;
    SetLength(fIndices,fCountIndices);
    if fCountIndices>0 then begin
     ChunkStream.ReadWithCheck(fIndices[0],fCountIndices*SizeOf(TVulkanModelIndex));
     if assigned(fKraftMesh) then begin
      Index:=0;
      while (Index+2)<fCountIndices-1 do begin
       fKraftMesh.AddTriangle(fIndices[Index],fIndices[Index+1],fIndices[Index+2],
                              fIndices[Index],fIndices[Index+1],fIndices[Index+2]);
       inc(Index,3);
      end;
      fKraftMesh.Finish;
     end;
    end;
   end else begin
    raise EModelLoad.Create('Missing "'+String(ChunkSignature[0]+ChunkSignature[1]+ChunkSignature[2]+ChunkSignature[3])+'" chunk');
   end;
  finally
   ChunkStream.Free;
  end;
 end;
 procedure ReadPART;
 const ChunkSignature:TChunkSignature=('P','A','R','T');
 var ChunkStream:TChunkStream;
     Index:TVkInt32;
     Part:PVulkanModelPart;
 begin
  ChunkStream:=GetChunkStream(ChunkSignature,true);
  try
   if assigned(ChunkStream) and (ChunkStream.Size<>0) then begin
    fCountParts:=ChunkStream.ReadInt32;
    SetLength(fParts,fCountParts);
    for Index:=0 to fCountParts-1 do begin
     Part:=@fParts[Index];
     Part^.Material:=ChunkStream.ReadInt32;
     Part^.StartIndex:=ChunkStream.ReadInt32;
     Part^.CountIndices:=ChunkStream.ReadInt32;
    end;
   end else begin
    raise EModelLoad.Create('Missing "'+String(ChunkSignature[0]+ChunkSignature[1]+ChunkSignature[2]+ChunkSignature[3])+'" chunk');
   end;
  finally
   ChunkStream.Free;
  end;
 end;
 procedure ReadOBJS;
 const ChunkSignature:TChunkSignature=('O','B','J','S');
 var ChunkStream:TChunkStream;
     ObjectIndex:TVkInt32;
     AObject:PVulkanModelObject;
 begin
  ChunkStream:=GetChunkStream(ChunkSignature,true);
  try
   if assigned(ChunkStream) and (ChunkStream.Size<>0) then begin
    fCountObjects:=ChunkStream.ReadInt32;
    SetLength(fObjects,fCountObjects);
    for ObjectIndex:=0 to fCountObjects-1 do begin
     AObject:=@fObjects[ObjectIndex];
     AObject^.Name:=ChunkStream.ReadString;
     AObject^.Sphere.Center.x:=ChunkStream.ReadFloat;
     AObject^.Sphere.Center.y:=ChunkStream.ReadFloat;
     AObject^.Sphere.Center.z:=ChunkStream.ReadFloat;
     AObject^.Sphere.Radius:=ChunkStream.ReadFloat;
     AObject^.AABB.Min.x:=ChunkStream.ReadFloat;
     AObject^.AABB.Min.y:=ChunkStream.ReadFloat;
     AObject^.AABB.Min.z:=ChunkStream.ReadFloat;
     AObject^.AABB.Max.x:=ChunkStream.ReadFloat;
     AObject^.AABB.Max.y:=ChunkStream.ReadFloat;
     AObject^.AABB.Max.z:=ChunkStream.ReadFloat;
    end;
   end else begin
    raise EModelLoad.Create('Missing "'+String(ChunkSignature[0]+ChunkSignature[1]+ChunkSignature[2]+ChunkSignature[3])+'" chunk');
   end;
  finally
   ChunkStream.Free;
  end;
 end;
 procedure ReadCOHU;
 const ChunkSignature:TChunkSignature=('C','O','H','U');
 var ChunkStream:TChunkStream;
 begin
  ChunkStream:=GetChunkStream(ChunkSignature,true);
  try
   if assigned(ChunkStream) and (ChunkStream.Size<>0) then begin
    if assigned(fKraftConvexHull) then begin
     fKraftConvexHull.LoadFromStream(ChunkStream);
    end;
   end else begin
    raise EModelLoad.Create('Missing "'+String(ChunkSignature[0]+ChunkSignature[1]+ChunkSignature[2]+ChunkSignature[3])+'" chunk');
   end;
  finally
   ChunkStream.Free;
  end;
 end;
begin
 if assigned(aStream) then begin
  try
   Chunks:=nil;
   try
    begin
     if aStream.Seek(0,soBeginning)<>0 then begin
      raise EModelLoad.Create('Stream seek error');
     end;
    end;
    begin
     if aStream.Read(Signature,SizeOf(TChunkSignature))<>SizeOf(TChunkSignature) then begin
      raise EModelLoad.Create('Stream read error');
     end;
     if Signature<>ModelSignature then begin
      raise EModelLoad.Create('Invalid model file signature');
     end;
    end;
    begin
     if aStream.Read(Version,SizeOf(TVkUInt32))<>SizeOf(TVkUInt32) then begin
      raise EModelLoad.Create('Stream read error');
     end;
     if Version<>ModelVersion then begin
      raise EModelLoad.Create('Invalid model file version');
     end;
    end;
    begin
     if aStream.Read(CountChunks,SizeOf(TVkInt32))<>SizeOf(TVkInt32) then begin
      raise EModelLoad.Create('Stream read error');
     end;
     if aStream.Read(ChunkOffset,SizeOf(TVkInt32))<>SizeOf(TVkInt32) then begin
      raise EModelLoad.Create('Stream read error');
     end;
     if aStream.Seek(ChunkOffset,soBeginning)<>ChunkOffset then begin
      raise EModelLoad.Create('Stream seek error');
     end;
     if CountChunks=0 then begin
      raise EModelLoad.Create('Model file without chunks');
     end;
     SetLength(Chunks,CountChunks);
     if aStream.Read(Chunks[0],CountChunks*SizeOf(TChunk))<>(CountChunks*SizeOf(TChunk)) then begin
      raise EModelLoad.Create('Stream read error');
     end;
    end;
    begin
     ReadBOVO;
     ReadMATE;
     ReadVBOS;
     ReadIBOS;
     ReadPART;
     ReadOBJS;
     ReadCOHU;
    end;
   finally
    SetLength(Chunks,0);
   end;
  finally
   if aDoFree then begin
    aStream.Free;
   end;
  end;
 end;
end;

procedure TVulkanModel.Upload(const aQueue:TpvVulkanQueue;
                        const aCommandBuffer:TpvVulkanCommandBuffer;
                        const aFence:TpvVulkanFence);
type TRemapIndices=array of TVkInt64;
var BufferIndex,IndexIndex,CountTemporaryVertices:TVkInt32;
    MaxIndexedIndex:TVkUInt32;
    MaxCount,CurrentIndex,RemainingCount,ToDoCount,VertexIndex:TVkInt64;
    TemporaryVertices:TVulkanModelVertices;
    TemporaryIndices:TVulkanModelIndices;
    TemporaryRemapIndices:TRemapIndices;
begin
 if not fUploaded then begin

  if fVulkanDevice.PhysicalDevice.Features.fullDrawIndexUint32<>0 then begin
   MaxIndexedIndex:=high(TVkUInt32)-1;
  end else begin
   MaxIndexedIndex:=fVulkanDevice.PhysicalDevice.Properties.limits.maxDrawIndexedIndexValue;
  end;

  // Make sure that MaxCount is divisible by three (one triangle = three vertices)
  MaxCount:=Max(0,(MaxIndexedIndex+1)-((MaxIndexedIndex+1) mod 3));

  if fCountIndices=0 then begin

   fCountBuffers:=0;

  end else if fCountIndices<=MaxCount then begin

   // Good, the whole model fits into TVkFloat vertex and index buffers

   fCountBuffers:=1;

   SetLength(fVertexBuffers,fCountBuffers);
   SetLength(fIndexBuffers,fCountBuffers);
   SetLength(fBufferSizes,fCountBuffers);

   fBufferSizes[0]:=fCountIndices;

   fVertexBuffers[0]:=TpvVulkanBuffer.Create(fVulkanDevice,
                                             fCountVertices*SizeOf(TVulkanModelVertex),
                                             TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT),
                                             TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                             [],
                                             TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                                            );
   fVertexBuffers[0].UploadData(aQueue,
                                aCommandBuffer,
                                aFence,
                                fVertices[0],
                                0,
                                fCountVertices*SizeOf(TVulkanModelVertex),
                                TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);

   fIndexBuffers[0]:=TpvVulkanBuffer.Create(fVulkanDevice,
                                            fCountIndices*SizeOf(TVulkanModelIndex),
                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT),
                                            TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                            [],
                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                                           );
   fIndexBuffers[0].UploadData(aQueue,
                               aCommandBuffer,
                               aFence,
                               fIndices[0],
                               0,
                               fCountIndices*SizeOf(TVulkanModelIndex),
                               TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);

  end else begin

   // In this case, we do to need split the model into multipe vertex and index buffers

   // Avoid signed 2^31 overflow issues
   if MaxCount>=High(TVkInt32) then begin
    MaxCount:=(High(TVkInt32)-1)-((High(TVkInt32)-1) mod 3);
   end;

   TemporaryVertices:=nil;
   TemporaryIndices:=nil;
   TemporaryRemapIndices:=nil;
   try

    SetLength(TemporaryRemapIndices,fCountIndices);

    fCountBuffers:=(fCountIndices+(MaxCount-1)) div MaxCount;

    SetLength(fVertexBuffers,fCountBuffers);
    SetLength(fIndexBuffers,fCountBuffers);
    SetLength(fBufferSizes,fCountBuffers);

    BufferIndex:=0;
    CurrentIndex:=0;
    RemainingCount:=fCountIndices;

    while (BufferIndex<fCountBuffers) and (RemainingCount>0) do begin

     if RemainingCount>MaxCount then begin
      ToDoCount:=MaxCount;
     end else begin
      ToDoCount:=RemainingCount;
     end;

     fBufferSizes[BufferIndex]:=ToDoCount;

     FillChar(TemporaryRemapIndices,length(TemporaryRemapIndices)*SizeOf(TVkInt64),#$ff);

     if length(TemporaryIndices)<ToDoCount then begin
      SetLength(TemporaryIndices,ToDoCount*2);
     end;

     CountTemporaryVertices:=0;

     for IndexIndex:=0 to ToDoCount-1 do begin

      VertexIndex:=TemporaryRemapIndices[fIndices[CurrentIndex+IndexIndex]];

      if VertexIndex<0 then begin

       VertexIndex:=CountTemporaryVertices;
       inc(CountTemporaryVertices);

       TemporaryRemapIndices[fIndices[CurrentIndex+IndexIndex]]:=VertexIndex;

       if length(TemporaryVertices)<CountTemporaryVertices then begin
        SetLength(TemporaryVertices,CountTemporaryVertices*2);
       end;

       TemporaryVertices[VertexIndex]:=fVertices[fIndices[CurrentIndex+IndexIndex]];

      end;

      TemporaryIndices[IndexIndex]:=VertexIndex;

     end;

     fVertexBuffers[BufferIndex]:=TpvVulkanBuffer.Create(fVulkanDevice,
                                                         CountTemporaryVertices*SizeOf(TVulkanModelVertex),
                                                         TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT),
                                                         TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                         [],
                                                         TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                                                        );
     fVertexBuffers[BufferIndex].UploadData(aQueue,
                                            aCommandBuffer,
                                            aFence,
                                            TemporaryVertices[0],
                                            0,
                                            CountTemporaryVertices*SizeOf(TVulkanModelVertex),
                                            TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);

     fIndexBuffers[BufferIndex]:=TpvVulkanBuffer.Create(fVulkanDevice,
                                                        fBufferSizes[BufferIndex]*SizeOf(TVulkanModelIndex),
                                                        TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT),
                                                        TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                        [],
                                                        TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                                                       );
     fIndexBuffers[BufferIndex].UploadData(aQueue,
                                           aCommandBuffer,
                                           aFence,
                                           TemporaryIndices[0],
                                           0,
                                           fBufferSizes[BufferIndex]*SizeOf(TVulkanModelIndex),
                                           TpvVulkanBufferUseTemporaryStagingBufferMode.Yes);


     inc(CurrentIndex,ToDoCount);
     dec(RemainingCount,ToDoCount);

     inc(BufferIndex);
    end;

    fCountBuffers:=BufferIndex;

    SetLength(fVertexBuffers,fCountBuffers);
    SetLength(fIndexBuffers,fCountBuffers);
    SetLength(fBufferSizes,fCountBuffers);

   finally
    TemporaryVertices:=nil;
    TemporaryIndices:=nil;
    TemporaryRemapIndices:=nil;
   end;

  end;

  fUploaded:=true;

 end;
end;

procedure TVulkanModel.Unload;
var Index:TVkInt32;
begin
 if fUploaded then begin

  fUploaded:=false;

  for Index:=0 to fCountBuffers-1 do begin
   FreeAndNil(fVertexBuffers[Index]);
   FreeAndNil(fIndexBuffers[Index]);
  end;

  fVertexBuffers:=nil;
  fIndexBuffers:=nil;
  fBufferSizes:=nil;
  fCountBuffers:=0;

 end;
end;

procedure TVulkanModel.Draw(const aCommandBuffer:TpvVulkanCommandBuffer;const aInstanceCount:TVkUInt32=1;const aFirstInstance:TVkUInt32=0);
const Offsets:array[0..0] of TVkDeviceSize=(0);
var Index:TVkInt32;
begin
 for Index:=0 to fCountBuffers-1 do begin
  aCommandBuffer.CmdBindVertexBuffers(VULKAN_MODEL_VERTEX_BUFFER_BIND_ID,1,@fVertexBuffers[Index].Handle,@Offsets);
  aCommandBuffer.CmdBindIndexBuffer(fIndexBuffers[Index].Handle,0,VK_INDEX_TYPE_UINT32);
  aCommandBuffer.CmdDrawIndexed(fBufferSizes[Index],aInstanceCount,0,0,aFirstInstance);
 end;
end;

end.
