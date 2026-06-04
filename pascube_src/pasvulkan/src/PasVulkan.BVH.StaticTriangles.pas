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
unit PasVulkan.BVH.StaticTriangles;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

{$ifdef Delphi2009AndUp}
 {$warn DUPLICATE_CTOR_DTOR off}
{$endif}

{$undef UseDouble}
{$ifdef UseDouble}
 {$define NonSIMD}
{$endif}

{-$define NonSIMD}

{$ifdef NonSIMD}
 {$undef SIMD}
{$else}
 {$ifdef cpu386}
  {$if not (defined(Darwin) or defined(CompileForWithPIC))}
   {$define SIMD}
  {$ifend}
 {$endif}
 {$ifdef cpux64}
  {$define SIMD}
 {$endif}
{$endif}

{$define NonRecursive}

{$ifndef fpc}
 {$scopedenums on}
{$endif}

interface

uses SysUtils,
     Classes,
     Math,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Collections;

type TpvStaticTriangleBVHTriangleVertex=record
      Position:TpvVector3;
      Normal:TpvVector3;
      Tangent:TpvVector3;
      Bitangent:TpvVector3;
      TexCoord:TpvVector2;
     end;
     PpvStaticTriangleBVHTriangleVertex=^TpvStaticTriangleBVHTriangleVertex;

     TpvStaticTriangleBVHTriangleVertices=array[0..2] of TpvStaticTriangleBVHTriangleVertex;
     PpvStaticTriangleBVHTriangleVertices=^TpvStaticTriangleBVHTriangleVertices;

     TpvStaticTriangleBVHTriangle=record
      public
       Vertices:TpvStaticTriangleBVHTriangleVertices;
       Normal:TpvVector3;
       Material:TpvUInt32;
       Flags:TpvUInt32;
       Tag:TpvUInt32;
       AvoidSelfShadowingTag:TpvUInt32;
     end;
     PpvStaticTriangleBVHTriangle=^TpvStaticTriangleBVHTriangle;

     TpvStaticTriangleBVHTriangles=array of TpvStaticTriangleBVHTriangle;

     TpvStaticTriangleBVHTriangleIndex=TpvUInt32;
     PpvStaticTriangleBVHTriangleIndex=^TpvStaticTriangleBVHTriangleIndex;

     TpvStaticTriangleBVHTriangleIndices=array of TpvStaticTriangleBVHTriangleIndex;

     TpvStaticTriangleBVHRay=record
      Origin:TpvVector3;
      Direction:TpvVector3;
     end;
     PpvStaticTriangleBVHRay=^TpvStaticTriangleBVHRay;

     TpvStaticTriangleBVHSkipListNode=packed record
      AABBMin:TpvVector3;
      Flags:TpvUInt32;
      AABBMax:TpvVector3;
      SkipCount:TpvUInt32;
      FirstTriangleIndex:TpvUInt32;
      CountTriangleIndices:TpvUInt32;
      Left:TpvUInt32;
      Right:TpvUInt32;
     end;
     PpvStaticTriangleBVHSkipListNode=^TpvStaticTriangleBVHSkipListNode;

     TpvStaticTriangleBVHSkipListNodes=array of TpvStaticTriangleBVHSkipListNode;

     TpvStaticTriangleBVHSkipListTriangleVertex=packed record
      Position:TpvVector4;
      Normal:TpvVector4;
      Tangent:TpvVector4;
      TexCoord:TpvVector4;
     end;
     PpvStaticTriangleBVHSkipListTriangleVertex=^TpvStaticTriangleBVHSkipListTriangleVertex;

     TpvStaticTriangleBVHSkipListTriangleVertices=array[0..2] of TpvStaticTriangleBVHSkipListTriangleVertex;
     PpvStaticTriangleBVHSkipListTriangleVertices=^TpvStaticTriangleBVHSkipListTriangleVertex;

     TpvStaticTriangleBVHSkipListTriangle=packed record
      Vertices:TpvStaticTriangleBVHSkipListTriangleVertices;
      Material:TpvUInt32;
      Flags:TpvUInt32;
      Tag:TpvUInt32;
      AvoidSelfShadowingTag:TpvUInt32;
     end;
     PpvStaticTriangleBVHSkipListTriangle=^TpvStaticTriangleBVHSkipListTriangle;

     TpvStaticTriangleBVHSkipListTriangles=array of TpvStaticTriangleBVHSkipListTriangle;

     PpvStaticTriangleBVHSkipListTriangleIndex=^TpvStaticTriangleBVHSkipListTriangleIndex;
     TpvStaticTriangleBVHSkipListTriangleIndex=TpvUInt32;

     TpvStaticTriangleBVHSkipListTriangleIndices=array of TpvStaticTriangleBVHSkipListTriangleIndex;

     TpvStaticTriangleBVHIntersection=record
      Time:TpvFloat;
      Triangle:PpvStaticTriangleBVHTriangle;
      SkipListTriangle:PpvStaticTriangleBVHSkipListTriangle;
      HitPoint:TpvVector3;
      Barycentrics:TpvVector3;
      Normal:TpvVector3;
      Tangent:TpvVector3;
      Bitangent:TpvVector3;
      TexCoord:TpvVector2;
     end;
     PpvStaticTriangleBVHIntersection=^TpvStaticTriangleBVHIntersection;

     TpvStaticTriangleBVH=class;

     TpvStaticTriangleBVHNode=class
      private
       fOwner:TpvStaticTriangleBVH;
       fNodeIndex:TpvInt32;
       fTriangleIndex:TpvInt32;
       fLeft:TpvStaticTriangleBVHNode;
       fRight:TpvStaticTriangleBVHNode;
       fTriangleIndices:TpvStaticTriangleBVHTriangleIndices;
       fCountTriangleIndices:TpvInt32;
       fAABB:TpvAABB;
       fAxis:TpvInt32;
       fFlags:TpvUInt32;
       fSkipToNode:TpvUInt32;
       fCountAllContainingNodes:TpvUInt32;
       fCountAllContainingTriangles:TpvUInt32;
      public
       constructor Create(AOwner:TpvStaticTriangleBVH);
       destructor Destroy; override;
       function CountChildren:TpvInt32;
       function GetArea:TpvFloat;
       function IsLeaf:boolean;
       procedure InsertTriangle(const TriangleIndex:TpvStaticTriangleBVHTriangleIndex);
       procedure UpdateAABB;
       procedure AssignIndex(var NodeIndex,TriangleIndex:TpvInt32);
       procedure UpdateIndex;
      published
       property Owner:TpvStaticTriangleBVH read fOwner write fOwner;
       property NodeIndex:TpvInt32 read fNodeIndex write fNodeIndex;
       property TriangleIndex:TpvInt32 read fTriangleIndex write fTriangleIndex;
       property Left:TpvStaticTriangleBVHNode read fLeft write fLeft;
       property Right:TpvStaticTriangleBVHNode read fRight write fRight;
      public
       property TriangleIndices:TpvStaticTriangleBVHTriangleIndices read fTriangleIndices write fTriangleIndices;
      published
       property CountTriangleIndices:TpvInt32 read fCountTriangleIndices write fCountTriangleIndices;
      public
       property AABB:TpvAABB read fAABB write fAABB;
      published
       property Axis:TpvInt32 read fAxis write fAxis;
       property Flags:TpvUInt32 read fFlags write fFlags;
       property SkipToNode:TpvUInt32 read fSkipToNode write fSkipToNode;
       property CountAllContainingNodes:TpvUInt32 read fCountAllContainingNodes write fCountAllContainingNodes;
       property CountAllContainingTriangles:TpvUInt32 read fCountAllContainingTriangles write fCountAllContainingTriangles;
     end;

     TpvStaticTriangleBVHNodes=array of TpvStaticTriangleBVHNode;

     TpvStaticTriangleBVHSweepEvent=record
      Position:TpvFloat;
      Index:TpvInt32;
      Start:longbool;
     end;           
     PpvStaticTriangleBVHSweepEvent=^TpvStaticTriangleBVHSweepEvent;

     TpvStaticTriangleBVH=class
      private
       fSweepEvents:array of TpvStaticTriangleBVHSweepEvent;
       function SearchBestSplitPlane(CurrentNode:TpvStaticTriangleBVHNode;var BestSplitAxis:TpvInt32;var BestSplitPosition:TpvFloat;var BestLeftCount,BestRightCount:TpvInt32):boolean;
       procedure BuildFromRoot(MaxDepth:TpvInt32);
      private
       fRoot:TpvStaticTriangleBVHNode;
       fNodes:TpvStaticTriangleBVHNodes;
       fTriangles:TpvStaticTriangleBVHTriangles;
       fCountTriangles:TpvInt32;
       fSkipListTriangles:TpvStaticTriangleBVHSkipListTriangles;
       fSkipListTriangleIndices:TpvStaticTriangleBVHSkipListTriangleIndices;
       fSkipListNodes:TpvStaticTriangleBVHSkipListNodes;
       fCountLeafs:TpvInt32;
       fKDTreeMode:longbool;
      public
       constructor Create;
       destructor Destroy; override;
       function CountNodes:TpvInt32;
       procedure Clear;
       procedure Build(const Triangles:TpvStaticTriangleBVHTriangles;const aMaxDepth:TpvInt32);
       function RayIntersection(const Ray:TpvStaticTriangleBVHRay;var Intersection:TpvStaticTriangleBVHIntersection;FastCheck,Exact:boolean;const AvoidTag:TpvUInt32=$ffffffff;const AvoidOtherTag:TpvUInt32=$ffffffff;const AvoidSelfShadowingTag:TpvUInt32=$ffffffff;const Flags:TpvUInt32=$ffffffff):boolean;
       function ExactRayIntersection(const Ray:TpvStaticTriangleBVHRay;var Intersection:TpvStaticTriangleBVHIntersection;const AvoidTag:TpvUInt32=$ffffffff;const AvoidOtherTag:TpvUInt32=$ffffffff;const AvoidSelfShadowingTag:TpvUInt32=$ffffffff;const Flags:TpvUInt32=$ffffffff):boolean;
       function FastRayIntersection(const Ray:TpvStaticTriangleBVHRay;var Intersection:TpvStaticTriangleBVHIntersection;const AvoidTag:TpvUInt32=$ffffffff;const AvoidOtherTag:TpvUInt32=$ffffffff;const AvoidSelfShadowingTag:TpvUInt32=$ffffffff;const Flags:TpvUInt32=$ffffffff):boolean;
       function CountRayIntersections(const Ray:TpvStaticTriangleBVHRay;const Flags:TpvUInt32=$ffffffff):TpvInt32;
       function LineIntersection(const v0,v1:TpvVector3;const Exact:boolean=true;const Flags:TpvUInt32=$ffffffff):boolean;
       function IsOpenSpacePerEvenOddRule(const Position:TpvVector3;const Flags:TpvUInt32=$ffffffff):boolean; overload;
       function IsOpenSpacePerEvenOddRule(const Position:TpvVector3;var NearestNormal,NearestNormalPosition:TpvVector3;const Flags:TpvUInt32=$ffffffff):boolean; overload;
       function IsOpenSpacePerNormals(const Position:TpvVector3;const Flags:TpvUInt32=$ffffffff):boolean; overload;
       function IsOpenSpacePerNormals(const Position:TpvVector3;var NearestNormal,NearestNormalPosition:TpvVector3;const Flags:TpvUInt32=$ffffffff):boolean; overload;
{     published
       property Root:TpvStaticTriangleBVHNode read fRoot write fRoot;
      public
       property Nodes:TpvStaticTriangleBVHNodes read fNodes write fNodes;
       property Triangles:TpvStaticTriangleBVHTriangles read fTriangles write fTriangles;}
      published
       property CountTriangles:TpvInt32 read fCountTriangles write fCountTriangles;
      public
       property SkipListTriangles:TpvStaticTriangleBVHSkipListTriangles read fSkipListTriangles write fSkipListTriangles;
       property SkipListTriangleIndices:TpvStaticTriangleBVHSkipListTriangleIndices read fSkipListTriangleIndices write fSkipListTriangleIndices;
       property SkipListNodes:TpvStaticTriangleBVHSkipListNodes read fSkipListNodes write fSkipListNodes;
      published
       property CountLeafs:TpvInt32 read fCountLeafs write fCountLeafs;
       property KDTreeMode:longbool read fKDTreeMode write fKDTreeMode;
     end;

implementation

uses PasVulkan.Utils;

const BARY_EPSILON=0.01;
      ASLF_EPSILON=0.0001;
      COPLANAR_EPSILON=0.25;
      NEAR_SHADOW_EPSILON=1.5;
      SELF_SHADOW_EPSILON=0.5;

function TriangleGetExtremeAxisPointsForAABB(const Triangle:TpvStaticTriangleBVHTriangle;const aAABBMin,aAABBMax:TpvVector3;const Axis:TpvInt32;var PMin,PMax:TpvFloat):boolean;
var EdgeIndex:TpvInt32;
    TimeMin,TimeMax,Len,TempMin,TempMax,Temp:TpvFloat;
    v0,v1,InvDirection,a,b,AABBMin,AABBMax:TpvVector3;
    Ray:TpvStaticTriangleBVHRay;
    First:boolean;
begin
 result:=false;
 First:=true;
 v1:=Triangle.Vertices[2].Position;
 for EdgeIndex:=0 to 2 do begin
  v0:=v1;
  v1:=Triangle.Vertices[EdgeIndex].Position;
  Ray.Origin:=v0;
  Ray.Direction:=v1-v0;
  Len:=Ray.Direction.Length;
  Ray.Direction:=Ray.Direction/Len;
  if IsZero(Ray.Direction.x) then begin
   InvDirection.x:=0.0;
  end else begin
   InvDirection.x:=1.0/Ray.Direction.x;
  end;
  if IsZero(Ray.Direction.y) then begin
   InvDirection.y:=0.0;
  end else begin
   InvDirection.y:=1.0/Ray.Direction.y;
  end;
  if IsZero(Ray.Direction.z) then begin
   InvDirection.z:=0.0;
  end else begin
   InvDirection.z:=1.0/Ray.Direction.z;
  end;
  a.x:=(aAABBMin.x-Ray.Origin.x)*InvDirection.x;
  a.y:=(aAABBMin.y-Ray.Origin.y)*InvDirection.y;
  a.z:=(aAABBMin.z-Ray.Origin.z)*InvDirection.z;
  b.x:=(aAABBMax.x-Ray.Origin.x)*InvDirection.x;
  b.y:=(aAABBMax.y-Ray.Origin.y)*InvDirection.y;
  b.z:=(aAABBMax.z-Ray.Origin.z)*InvDirection.z;
  if a.x<b.x then begin
   AABBMin.x:=a.x;
   AABBMax.x:=b.x;
  end else begin
   AABBMin.x:=b.x;
   AABBMax.x:=a.x;
  end;
  if a.y<b.y then begin
   AABBMin.y:=a.y;
   AABBMax.y:=b.y;
  end else begin
   AABBMin.y:=b.y;
   AABBMax.y:=a.y;
  end;
  if a.z<b.z then begin
   AABBMin.z:=a.z;
   AABBMax.z:=b.z;
  end else begin
   AABBMin.z:=b.z;
   AABBMax.z:=a.z;
  end;
  if AABBMin.x<AABBMin.y then begin
   if AABBMin.y<AABBMin.z then begin
    TimeMin:=AABBMin.z;
   end else begin
    TimeMin:=AABBMin.y;
   end;
  end else begin
   if AABBMin.x<AABBMin.z then begin
    TimeMin:=AABBMin.z;
   end else begin
    TimeMin:=AABBMin.x;
   end;
  end;
  if AABBMax.x<AABBMax.y then begin
   if AABBMax.x<AABBMax.z then begin
    TimeMax:=AABBMax.x;
   end else begin
    TimeMax:=AABBMax.z;
   end;
  end else begin
   if AABBMax.y<AABBMax.z then begin
    TimeMax:=AABBMax.y;
   end else begin
    TimeMax:=AABBMax.z;
   end;
  end;
  if ((TimeMax>=0.0) and (TimeMin<=TimeMax)) and (TimeMin<=Len) then begin
   if TimeMin<0.0 then begin
    TimeMin:=0.0;
   end else if TimeMin>Len then begin
    TimeMin:=Len;
   end;
   if TimeMax<0.0 then begin
    TimeMax:=0.0;
   end else if TimeMax>Len then begin
    TimeMax:=Len;
   end;
   TempMin:=Ray.Origin.xyz[Axis]+(Ray.Direction.xyz[Axis]*TimeMin);
   TempMax:=Ray.Origin.xyz[Axis]+(Ray.Direction.xyz[Axis]*TimeMax);
   if TempMin>TempMax then begin
    Temp:=TempMin;
    TempMin:=TempMax;
    TempMax:=Temp;
   end;
   if First then begin
    First:=false;
    PMin:=TempMin;
    PMax:=TempMax;
   end else begin
    if PMin>TempMin then begin
     PMin:=TempMin;
    end;
    if PMax<TempMax then begin
     PMax:=TempMax;
    end;
   end;
   result:=true;
  end;
 end;
end;

function AABBRayIntersection(const aAABBMin,aAABBMax:TpvVector3;const Ray:TpvStaticTriangleBVHRay;out Time:TpvFloat):boolean; overload;
var InvDirection,a,b,AABBMin,AABBMax:TpvVector3;
    TimeMin,TimeMax:TpvFloat;
begin
 if IsZero(Ray.Direction.x) then begin
  InvDirection.x:=0.0;
 end else begin
  InvDirection.x:=1.0/Ray.Direction.x;
 end;
 if IsZero(Ray.Direction.y) then begin
  InvDirection.y:=0.0;
 end else begin
  InvDirection.y:=1.0/Ray.Direction.y;
 end;
 if IsZero(Ray.Direction.z) then begin
  InvDirection.z:=0.0;
 end else begin
  InvDirection.z:=1.0/Ray.Direction.z;
 end;
 a.x:=(aAABBMin.x-Ray.Origin.x)*InvDirection.x;
 a.y:=(aAABBMin.y-Ray.Origin.y)*InvDirection.y;
 a.z:=(aAABBMin.z-Ray.Origin.z)*InvDirection.z;
 b.x:=(aAABBMax.x-Ray.Origin.x)*InvDirection.x;
 b.y:=(aAABBMax.y-Ray.Origin.y)*InvDirection.y;
 b.z:=(aAABBMax.z-Ray.Origin.z)*InvDirection.z;
 if a.x<b.x then begin
  AABBMin.x:=a.x;
  AABBMax.x:=b.x;
 end else begin
  AABBMin.x:=b.x;
  AABBMax.x:=a.x;
 end;
 if a.y<b.y then begin
  AABBMin.y:=a.y;
  AABBMax.y:=b.y;
 end else begin
  AABBMin.y:=b.y;
  AABBMax.y:=a.y;
 end;
 if a.z<b.z then begin
  AABBMin.z:=a.z;
  AABBMax.z:=b.z;
 end else begin
  AABBMin.z:=b.z;
  AABBMax.z:=a.z;
 end;
 if AABBMin.x<AABBMin.y then begin
  if AABBMin.y<AABBMin.z then begin
   TimeMin:=AABBMin.z;
  end else begin
   TimeMin:=AABBMin.y;
  end;
 end else begin
  if AABBMin.x<AABBMin.z then begin
   TimeMin:=AABBMin.z;
  end else begin
   TimeMin:=AABBMin.x;
  end;
 end;
 if AABBMax.x<AABBMax.y then begin
  if AABBMax.x<AABBMax.z then begin
   TimeMax:=AABBMax.x;
  end else begin
   TimeMax:=AABBMax.z;
  end;
 end else begin
  if AABBMax.y<AABBMax.z then begin
   TimeMax:=AABBMax.y;
  end else begin
   TimeMax:=AABBMax.z;
  end;
 end;
 if (TimeMax<0) or (TimeMin>TimeMax) then begin
  Time:=TimeMax;
  result:=false;
 end else begin
  Time:=TimeMin;
  result:=true;
 end;
end;

function AABBRayIntersection(const aAABBMin,aAABBMax:TpvVector3;const Ray:TpvStaticTriangleBVHRay):boolean; overload;
var Center,Extents,Diff:TpvVector3;
begin
 Center.x:=(aAABBMin.x+aAABBMax.x)*0.5;
 Center.y:=(aAABBMin.y+aAABBMax.z)*0.5;
 Center.z:=(aAABBMin.z+aAABBMax.z)*0.5;
 Extents.x:=Center.x-aAABBMin.x;
 Extents.y:=Center.y-aAABBMin.y;
 Extents.z:=Center.z-aAABBMin.z;
 Diff.x:=Ray.Origin.x-Center.x;
 Diff.y:=Ray.Origin.y-Center.y;
 Diff.z:=Ray.Origin.z-Center.z;
 result:=(((abs(Diff.x)<=Extents.x) or ((Diff.x*Ray.Direction.x)<0.0)) and
          ((abs(Diff.y)<=Extents.y) or ((Diff.y*Ray.Direction.y)<0.0)) and
          ((abs(Diff.z)<=Extents.z) or ((Diff.z*Ray.Direction.z)<0.0))) and
         ((abs((Ray.Direction.y*Diff.z)-(Ray.Direction.z*Diff.y))<=((Extents.y*abs(Ray.Direction.z))+(Extents.z*abs(Ray.Direction.y)))) and
          (abs((Ray.Direction.z*Diff.x)-(Ray.Direction.x*Diff.z))<=((Extents.x*abs(Ray.Direction.z))+(Extents.z*abs(Ray.Direction.x)))) and
          (abs((Ray.Direction.x*Diff.y)-(Ray.Direction.y*Diff.x))<=((Extents.x*abs(Ray.Direction.y))+(Extents.y*abs(Ray.Direction.x)))));
end;

function TriangleRayIntersectionExact(const Triangle:TpvStaticTriangleBVHSkipListTriangle;const Ray:TpvStaticTriangleBVHRay;out Time:TpvFloat):boolean; overload;
var U,V:TpvUInt32;
    Normal:TpvVector3;
    h:TpvVector2;
    BarycentricDivide,Beta,Gamma:TpvFloat;
begin
 result:=false;
 Normal:=TpvVector3.InlineableCreate(Triangle.Vertices[0].TexCoord.w,Triangle.Vertices[1].TexCoord.w,Triangle.Vertices[2].TexCoord.w);
 Time:=((Triangle.Vertices[0].Position.xyz-Ray.Origin)*Normal).Dot(TpvVector3.AllAxis)/(Ray.Direction*Normal).Dot(TpvVector3.AllAxis);
 if Time>1e-9 then begin
  U:=TpvUInt32(pointer(@Triangle.Vertices[0].TexCoord.z)^) shr 16;
  V:=TpvUInt32(pointer(@Triangle.Vertices[0].TexCoord.z)^) and $ffff;
  BarycentricDivide:=Triangle.Vertices[1].TexCoord.z;
  h.u:=(Ray.Origin.xyz[U]+(Time*Ray.Direction.xyz[U]))-Triangle.Vertices[0].Position.xyz[U];
  h.v:=(Ray.Origin.xyz[V]+(Time*Ray.Direction.xyz[V]))-Triangle.Vertices[0].Position.xyz[V];
  Beta:=((Triangle.Vertices[0].Position.w*h.v)-(Triangle.Vertices[1].Position.w*h.u))*BarycentricDivide;
  if Beta>=0.0 then begin
   Gamma:=((Triangle.Vertices[1].Normal.w*h.u)-(Triangle.Vertices[0].Normal.w*h.v))*BarycentricDivide;
   result:=(Gamma>=0.0) and ((Beta+Gamma)<=1.0);
  end;
 end;
end;

function TriangleRayIntersectionLazy(const Triangle:TpvStaticTriangleBVHSkipListTriangle;const Ray:TpvStaticTriangleBVHRay;out Time,Beta,Gamma:TpvFloat):boolean; overload;
var U,V:TpvUInt32;
    Normal:TpvVector3;
    h:TpvVector2;
    Det,BarycentricDivide:TpvFloat;
begin
 result:=false;
 Normal:=TpvVector3.InlineableCreate(Triangle.Vertices[0].TexCoord.w,Triangle.Vertices[1].TexCoord.w,Triangle.Vertices[2].TexCoord.w);
 Det:=(Ray.Direction*Normal).Dot(TpvVector3.AllAxis);
 if abs(Det)>=COPLANAR_EPSILON then begin
  Time:=((Triangle.Vertices[0].Position.xyz-Ray.Origin)*Normal).Dot(TpvVector3.AllAxis)/Det;
  if Time>1e-9 then begin
   U:=TpvUInt32(pointer(@Triangle.Vertices[0].TexCoord.z)^) shr 16;
   V:=TpvUInt32(pointer(@Triangle.Vertices[0].TexCoord.z)^) and $ffff;
   BarycentricDivide:=Triangle.Vertices[1].TexCoord.z;
   h.u:=(Ray.Origin.xyz[U]+(Time*Ray.Direction.xyz[U]))-Triangle.Vertices[0].Position.xyz[U];
   h.v:=(Ray.Origin.xyz[V]+(Time*Ray.Direction.xyz[V]))-Triangle.Vertices[0].Position.xyz[V];
   Beta:=((Triangle.Vertices[0].Position.w*h.v)-(Triangle.Vertices[1].Position.w*h.u))*BarycentricDivide;
   if (Beta>=-BARY_EPSILON) and (Beta<=(1.0+BARY_EPSILON)) then begin
    Gamma:=((Triangle.Vertices[1].Normal.w*h.u)-(Triangle.Vertices[0].Normal.w*h.v))*BarycentricDivide;
    result:=(Gamma>=-BARY_EPSILON) and ((Beta+Gamma)<=(1.0+BARY_EPSILON));
   end;
  end;
 end;
end;

procedure TriangleInterpolation(const Triangle:TpvStaticTriangleBVHSkipListTriangle;const HitPoint:TpvVector3;out Barycentrics,Normal,Tangent,Bitangent:TpvVector3;out TexCoord:TpvVector2); overload;
var TempNormal,Cross:TpvVector3;
    Bitangents:array[0..2] of TpvVector3;
    WholeArea:TpvFloat;
begin
 Cross:=(Triangle.Vertices[1].Position.xyz-Triangle.Vertices[0].Position.xyz).Cross(Triangle.Vertices[2].Position.xyz-Triangle.Vertices[0].Position.xyz);
 TempNormal:=Cross.Normalize;
 WholeArea:=TempNormal.Dot(Cross);
 Barycentrics.x:=TempNormal.Dot((Triangle.Vertices[1].Position.xyz-HitPoint).Cross(Triangle.Vertices[2].Position.xyz-HitPoint))/WholeArea;
 Barycentrics.y:=TempNormal.Dot((Triangle.Vertices[2].Position.xyz-HitPoint).Cross(Triangle.Vertices[0].Position.xyz-HitPoint))/WholeArea;
 Barycentrics.z:=(1.0-Barycentrics.x)-Barycentrics.y;
 Normal:=TpvVector3.InlineableCreate(
  (Triangle.Vertices[0].Normal.x*Barycentrics.x)+(Triangle.Vertices[1].Normal.x*Barycentrics.y)+(Triangle.Vertices[2].Normal.x*Barycentrics.z),
  (Triangle.Vertices[0].Normal.y*Barycentrics.x)+(Triangle.Vertices[1].Normal.y*Barycentrics.y)+(Triangle.Vertices[2].Normal.y*Barycentrics.z),
  (Triangle.Vertices[0].Normal.z*Barycentrics.x)+(Triangle.Vertices[1].Normal.z*Barycentrics.y)+(Triangle.Vertices[2].Normal.z*Barycentrics.z)
 ).Normalize;
 Tangent:=TpvVector3.InlineableCreate(
  (Triangle.Vertices[0].Tangent.x*Barycentrics.x)+(Triangle.Vertices[1].Tangent.x*Barycentrics.y)+(Triangle.Vertices[2].Tangent.x*Barycentrics.z),
  (Triangle.Vertices[0].Tangent.y*Barycentrics.x)+(Triangle.Vertices[1].Tangent.y*Barycentrics.y)+(Triangle.Vertices[2].Tangent.y*Barycentrics.z),
  (Triangle.Vertices[0].Tangent.z*Barycentrics.x)+(Triangle.Vertices[1].Tangent.z*Barycentrics.y)+(Triangle.Vertices[2].Tangent.z*Barycentrics.z)
 ).Normalize;
 Bitangents[0]:=Triangle.Vertices[0].Normal.xyz.Cross(Triangle.Vertices[0].Tangent.xyz).Normalize*Triangle.Vertices[0].Tangent.w;
 Bitangents[1]:=Triangle.Vertices[1].Normal.xyz.Cross(Triangle.Vertices[1].Tangent.xyz).Normalize*Triangle.Vertices[1].Tangent.w;
 Bitangents[2]:=Triangle.Vertices[2].Normal.xyz.Cross(Triangle.Vertices[2].Tangent.xyz).Normalize*Triangle.Vertices[2].Tangent.w;
 Bitangent:=TpvVector3.InlineableCreate(
  (Bitangents[0].x*Barycentrics.x)+(Bitangents[1].x*Barycentrics.y)+(Bitangents[2].x*Barycentrics.z),
  (Bitangents[0].y*Barycentrics.x)+(Bitangents[1].y*Barycentrics.y)+(Bitangents[2].y*Barycentrics.z),
  (Bitangents[0].z*Barycentrics.x)+(Bitangents[1].z*Barycentrics.y)+(Bitangents[2].z*Barycentrics.z)
 ).Normalize;
 TexCoord:=TpvVector2.InlineableCreate(
  (Triangle.Vertices[0].TexCoord.x*Barycentrics.x)+(Triangle.Vertices[1].TexCoord.x*Barycentrics.y)+(Triangle.Vertices[2].TexCoord.x*Barycentrics.z),
  (Triangle.Vertices[0].TexCoord.y*Barycentrics.x)+(Triangle.Vertices[1].TexCoord.y*Barycentrics.y)+(Triangle.Vertices[2].TexCoord.y*Barycentrics.z)
 );
end;

constructor TpvStaticTriangleBVHNode.Create(AOwner:TpvStaticTriangleBVH);
begin
 inherited Create;
 fOwner:=AOwner;
 fNodeIndex:=-1;
 fTriangleIndex:=-1;
 fLeft:=nil;
 fRight:=nil;
 fTriangleIndices:=nil;
 fCountTriangleIndices:=0;
 fAABB.Min:=TpvVector3.Origin;
 fAABB.Max:=TpvVector3.Origin;
 fFlags:=0;
 fCountAllContainingNodes:=0;
 fCountAllContainingTriangles:=0;
end;

destructor TpvStaticTriangleBVHNode.Destroy;
begin
 FreeAndNil(fLeft);
 FreeAndNil(fRight);
 SetLength(fTriangleIndices,0);
 inherited Destroy;
end;

function TpvStaticTriangleBVHNode.CountChildren:TpvInt32;
begin
 result:=0;
 if assigned(fLeft) then begin
  inc(result,1+fLeft.CountChildren);
 end;
 if assigned(fRight) then begin
  inc(result,1+fRight.CountChildren);
 end;
end;

function TpvStaticTriangleBVHNode.GetArea:TpvFloat;
begin
 result:=fAABB.Area;
end;

function TpvStaticTriangleBVHNode.IsLeaf:boolean;
begin
 result:=not (assigned(fLeft) or assigned(fRight));
end;

procedure TpvStaticTriangleBVHNode.InsertTriangle(const TriangleIndex:TpvStaticTriangleBVHTriangleIndex);
begin
 if (fCountTriangleIndices+1)>length(fTriangleIndices) then begin
  SetLength(fTriangleIndices,RoundUpToPowerOfTwo(fCountTriangleIndices+1));
 end;
 fTriangleIndices[fCountTriangleIndices]:=TriangleIndex;
 inc(fCountTriangleIndices);
 fFlags:=fFlags or fOwner.fTriangles[TriangleIndex].Flags;
end;

procedure TpvStaticTriangleBVHNode.UpdateAABB;
var i,j:TpvInt32;
    Triangle:PpvStaticTriangleBVHTriangle;
begin
 for i:=0 to fCountTriangleIndices-1 do begin
  Triangle:=@fOwner.fTriangles[fTriangleIndices[i]];
  for j:=0 to 2 do begin
   if (i=0) and (j=0) then begin
    fAABB.Min:=Triangle^.Vertices[j].Position;
    fAABB.Max:=Triangle^.Vertices[j].Position;
   end else begin
    if fAABB.Min.x>Triangle^.Vertices[j].Position.x then begin
     fAABB.Min.x:=Triangle^.Vertices[j].Position.x;
    end;
    if fAABB.Min.y>Triangle^.Vertices[j].Position.y then begin
     fAABB.Min.y:=Triangle^.Vertices[j].Position.y;
    end;
    if fAABB.Min.z>Triangle^.Vertices[j].Position.z then begin
     fAABB.Min.z:=Triangle^.Vertices[j].Position.z;
    end;
    if fAABB.Max.x<Triangle^.Vertices[j].Position.x then begin
     fAABB.Max.x:=Triangle^.Vertices[j].Position.x;
    end;
    if fAABB.Max.y<Triangle^.Vertices[j].Position.y then begin
     fAABB.Max.y:=Triangle^.Vertices[j].Position.y;
    end;
    if fAABB.Max.z<Triangle^.Vertices[j].Position.z then begin
     fAABB.Max.z:=Triangle^.Vertices[j].Position.z;
    end;
   end;
  end;
 end;
end;

procedure TpvStaticTriangleBVHNode.AssignIndex(var NodeIndex,TriangleIndex:TpvInt32);
begin
 fNodeIndex:=NodeIndex;
 inc(NodeIndex);
 fTriangleIndex:=TriangleIndex;
 inc(TriangleIndex,fCountTriangleIndices);
 if assigned(fLeft) then begin
  fLeft.AssignIndex(NodeIndex,TriangleIndex);
 end;
 if assigned(fRight) then begin
  fRight.AssignIndex(NodeIndex,TriangleIndex);
 end;
 fSkipToNode:=NodeIndex;
 fCountAllContainingNodes:=NodeIndex-fNodeIndex;
 fCountAllContainingTriangles:=TriangleIndex-fTriangleIndex;
end;

procedure TpvStaticTriangleBVHNode.UpdateIndex;
begin
 fOwner.fNodes[fNodeIndex]:=self;
 if assigned(fLeft) then begin
  fLeft.UpdateIndex;
 end;
 if assigned(fRight) then begin
  fRight.UpdateIndex;
 end;
end;

constructor TpvStaticTriangleBVH.Create;
begin
 inherited Create;
 fRoot:=nil;
 fNodes:=nil;
 fSweepEvents:=nil;
 fTriangles:=nil;
 fCountTriangles:=0;
 fSkipListTriangles:=nil;
 fSkipListTriangleIndices:=nil;
 fSkipListNodes:=nil;
 fCountLeafs:=0;
 fKDTreeMode:=false;
end;

destructor TpvStaticTriangleBVH.Destroy;
begin
 FreeAndNil(fRoot);
 SetLength(fNodes,0);
 SetLength(fTriangles,0);
 SetLength(fSkipListTriangles,0);
 SetLength(fSkipListTriangleIndices,0);
 SetLength(fSkipListNodes,0);
 SetLength(fSweepEvents,0);
 inherited Destroy;
end;

function TpvStaticTriangleBVH.CountNodes:TpvInt32;
begin
 if assigned(fRoot) then begin
  result:=1+fRoot.CountChildren;
 end else begin
  result:=0;
 end;
end;

procedure TpvStaticTriangleBVH.Clear;
begin
 FreeAndNil(fRoot);
 SetLength(fSkipListTriangles,0);
 SetLength(fSkipListTriangleIndices,0);
 SetLength(fSkipListNodes,0);
 fCountLeafs:=0;
end;

function CompareFloat(const a,b:pointer):TpvInt32;
begin
 if TpvFloat(a^)<TpvFloat(b^) then begin
  result:=1;
 end else if TpvFloat(a^)>TpvFloat(b^) then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function CompareTriangleMinX(const a,b:pointer):TpvInt32;
var ac,bc:TpvFloat;
begin
 ac:=Min(Min(PpvStaticTriangleBVHTriangle(a)^.Vertices[0].Position.x,PpvStaticTriangleBVHTriangle(a)^.Vertices[1].Position.x),PpvStaticTriangleBVHTriangle(a)^.Vertices[2].Position.x);
 bc:=Min(Min(PpvStaticTriangleBVHTriangle(b)^.Vertices[0].Position.x,PpvStaticTriangleBVHTriangle(b)^.Vertices[1].Position.x),PpvStaticTriangleBVHTriangle(b)^.Vertices[2].Position.x);
 if ac<bc then begin
  result:=1;
 end else if bc>ac then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function CompareTriangleMinY(const a,b:pointer):TpvInt32;
var ac,bc:TpvFloat;
begin
 ac:=Min(Min(PpvStaticTriangleBVHTriangle(a)^.Vertices[0].Position.y,PpvStaticTriangleBVHTriangle(a)^.Vertices[1].Position.y),PpvStaticTriangleBVHTriangle(a)^.Vertices[2].Position.y);
 bc:=Min(Min(PpvStaticTriangleBVHTriangle(b)^.Vertices[0].Position.y,PpvStaticTriangleBVHTriangle(b)^.Vertices[1].Position.y),PpvStaticTriangleBVHTriangle(b)^.Vertices[2].Position.y);
 if ac<bc then begin
  result:=1;
 end else if bc>ac then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function CompareTriangleMinZ(const a,b:pointer):TpvInt32;
var ac,bc:TpvFloat;
begin
 ac:=Min(Min(PpvStaticTriangleBVHTriangle(a)^.Vertices[0].Position.z,PpvStaticTriangleBVHTriangle(a)^.Vertices[1].Position.z),PpvStaticTriangleBVHTriangle(a)^.Vertices[2].Position.z);
 bc:=Min(Min(PpvStaticTriangleBVHTriangle(b)^.Vertices[0].Position.z,PpvStaticTriangleBVHTriangle(b)^.Vertices[1].Position.z),PpvStaticTriangleBVHTriangle(b)^.Vertices[2].Position.z);
 if ac<bc then begin
  result:=1;
 end else if bc>ac then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function CompareTriangleMaxX(const a,b:pointer):TpvInt32;
var ac,bc:TpvFloat;
begin
 ac:=Max(Max(PpvStaticTriangleBVHTriangle(a)^.Vertices[0].Position.x,PpvStaticTriangleBVHTriangle(a)^.Vertices[1].Position.x),PpvStaticTriangleBVHTriangle(a)^.Vertices[2].Position.x);
 bc:=Max(Max(PpvStaticTriangleBVHTriangle(b)^.Vertices[0].Position.x,PpvStaticTriangleBVHTriangle(b)^.Vertices[1].Position.x),PpvStaticTriangleBVHTriangle(b)^.Vertices[2].Position.x);
 if ac<bc then begin
  result:=1;
 end else if bc>ac then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function CompareTriangleMaxY(const a,b:pointer):TpvInt32;
var ac,bc:TpvFloat;
begin
 ac:=Max(Max(PpvStaticTriangleBVHTriangle(a)^.Vertices[0].Position.y,PpvStaticTriangleBVHTriangle(a)^.Vertices[1].Position.y),PpvStaticTriangleBVHTriangle(a)^.Vertices[2].Position.y);
 bc:=Max(Max(PpvStaticTriangleBVHTriangle(b)^.Vertices[0].Position.y,PpvStaticTriangleBVHTriangle(b)^.Vertices[1].Position.y),PpvStaticTriangleBVHTriangle(b)^.Vertices[2].Position.y);
 if ac<bc then begin
  result:=1;
 end else if bc>ac then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function CompareTriangleMaxZ(const a,b:pointer):TpvInt32;
var ac,bc:TpvFloat;
begin
 ac:=Max(Max(PpvStaticTriangleBVHTriangle(a)^.Vertices[0].Position.z,PpvStaticTriangleBVHTriangle(a)^.Vertices[1].Position.z),PpvStaticTriangleBVHTriangle(a)^.Vertices[2].Position.z);
 bc:=Max(Max(PpvStaticTriangleBVHTriangle(b)^.Vertices[0].Position.z,PpvStaticTriangleBVHTriangle(b)^.Vertices[1].Position.z),PpvStaticTriangleBVHTriangle(b)^.Vertices[2].Position.z);
 if ac<bc then begin
  result:=1;
 end else if bc>ac then begin
  result:=-1;
 end else begin
  result:=0;
 end;
end;

function CompareSweepEvent(const a,b:pointer):TpvInt32;
begin
 if PpvStaticTriangleBVHSweepEvent(a)^.Position<PpvStaticTriangleBVHSweepEvent(b)^.Position then begin
  result:=-1;
 end else if PpvStaticTriangleBVHSweepEvent(a)^.Position>PpvStaticTriangleBVHSweepEvent(b)^.Position then begin
  result:=1;
 end else begin
  result:=0;
 end;
end;

function GetTriangleMidAxisPoint(const Triangle:TpvStaticTriangleBVHTriangle;const Axis:TpvInt32):TpvFloat;
begin
 result:=(Triangle.Vertices[0].Position.xyz[Axis]+Triangle.Vertices[1].Position.xyz[Axis]+Triangle.Vertices[2].Position.xyz[Axis])/3.0;
end;

function GetTriangleAABB(const Triangle:TpvStaticTriangleBVHTriangle):TpvAABB;
begin
 result.Min.x:=Min(Min(Triangle.Vertices[0].Position.x,Triangle.Vertices[1].Position.x),Triangle.Vertices[2].Position.x);
 result.Min.y:=Min(Min(Triangle.Vertices[0].Position.y,Triangle.Vertices[1].Position.y),Triangle.Vertices[2].Position.y);
 result.Min.z:=Min(Min(Triangle.Vertices[0].Position.z,Triangle.Vertices[1].Position.z),Triangle.Vertices[2].Position.z);
 result.Max.x:=Max(Max(Triangle.Vertices[0].Position.x,Triangle.Vertices[1].Position.x),Triangle.Vertices[2].Position.x);
 result.Max.y:=Max(Max(Triangle.Vertices[0].Position.y,Triangle.Vertices[1].Position.y),Triangle.Vertices[2].Position.y);
 result.Max.z:=Max(Max(Triangle.Vertices[0].Position.z,Triangle.Vertices[1].Position.z),Triangle.Vertices[2].Position.z);
end;

procedure GetTriangleExtremePoints(const Triangle:TpvStaticTriangleBVHTriangle;const Axis:TpvInt32;var MinPoint,MaxPoint:TpvFloat);
begin
 MinPoint:=Min(Min(Triangle.Vertices[0].Position.xyz[Axis],Triangle.Vertices[1].Position.xyz[Axis]),Triangle.Vertices[2].Position.xyz[Axis]);
 MaxPoint:=Max(Max(Triangle.Vertices[0].Position.xyz[Axis],Triangle.Vertices[1].Position.xyz[Axis]),Triangle.Vertices[2].Position.xyz[Axis]);
end;

function CanInsertTriangle(const Triangle:TpvStaticTriangleBVHTriangle;const AABB:TpvAABB):boolean;
begin
 result:=AABB.Contains(GetTriangleAABB(Triangle));
{result:=AABB.TriangleIntersection(TpvTriangle.Create(Triangle.Vertices[0].Position,
                                                      Triangle.Vertices[1].Position,
                                                      Triangle.Vertices[2].Position));}
end;

function TpvStaticTriangleBVH.SearchBestSplitPlane(CurrentNode:TpvStaticTriangleBVHNode;var BestSplitAxis:TpvInt32;var BestSplitPosition:TpvFloat;var BestLeftCount,BestRightCount:TpvInt32):boolean;
const TraversalCost=0.3;//2.0;//0.3;
      IntersectionCost=1.0;//5.6;//1.0;
      MaximiumPrimitivesPerLeaf=4;//16;//4;
var AxisIndex,VertexIndex,TriangleIndex,CountTriangles,LeftCount,RightCount,ParentCount,BestAxis,
    SplitPlaneIndex,FarthestSweepEventIndex,SweepEventIndex,CountSweepEvents,SubSweepEventIndex,
    CurrentAxisBestSplitLeftCount,CurrentAxisBestSplitRightCount:TpvInt32;
    LeftAABB,RightAABB,ParentAABB,TriangleAABB:TpvAABB;
    ParentArea,ProposedSplitPosition,CurrentAxisSplitPosition,CurrentAxisBestSplitPosition,CurrentAxisBestCost,LeftProb,RightProb,
    CurrentAxisSplitCost,BestSplitCost,c0,c1:TpvFloat;
    SweepStep,SweepTime,SweepTimeMin,SweepTimeMax,SweepTimeBest,SweepTimeLastBest:double;
    Found,First,AllFirst:boolean;
    Triangle:PpvStaticTriangleBVHTriangle;
begin
 result:=false;
 if fKDTreeMode and (CurrentNode.fCountTriangleIndices>=65536) then begin

  CountSweepEvents:=CurrentNode.fCountTriangleIndices*2;
  if length(fSweepEvents)<CountSweepEvents then begin
   SetLength(fSweepEvents,CountSweepEvents*2);
  end;
  BestSplitCost:=Infinity;
  AllFirst:=true;
  ParentArea:=CurrentNode.fAABB.Area;
  for AxisIndex:=0 to 2 do begin

   CountSweepEvents:=0;
   CountTriangles:=0;
   for TriangleIndex:=0 to CurrentNode.fCountTriangleIndices-1 do begin
    c0:=0.0;
    c1:=0.0;
    if TriangleGetExtremeAxisPointsForAABB(fTriangles[CurrentNode.fTriangleIndices[TriangleIndex]],CurrentNode.fAABB.Min,CurrentNode.fAABB.Max,AxisIndex,c0,c1) then begin
     fSweepEvents[CountSweepEvents].Position:=Max(CurrentNode.fAABB.Min.xyz[AxisIndex],c0);
     fSweepEvents[CountSweepEvents].Index:=TriangleIndex;
     fSweepEvents[CountSweepEvents].Start:=true;
     inc(CountSweepEvents);
     fSweepEvents[CountSweepEvents].Position:=Min(CurrentNode.fAABB.Max.xyz[AxisIndex],c1);
     fSweepEvents[CountSweepEvents].Index:=TriangleIndex;
     fSweepEvents[CountSweepEvents].Start:=false;
     inc(CountSweepEvents);
     inc(CountTriangles);
    end;
   end;
   if CountSweepEvents>1 then begin
    UntypedDirectIntroSort(@fSweepEvents[0],0,CountSweepEvents-1,SizeOf(TpvStaticTriangleBVHSweepEvent),@CompareSweepEvent);
   end;

   CurrentAxisBestSplitPosition:=0.0;
   CurrentAxisBestCost:=Infinity;

   LeftCount:=0;
   RightCount:=CountTriangles;

   FarthestSweepEventIndex:=0;

   First:=true;

   SweepEventIndex:=0;
   while SweepEventIndex<CountSweepEvents do begin

    ProposedSplitPosition:=fSweepEvents[SweepEventIndex].Position;

    TriangleIndex:=fSweepEvents[SweepEventIndex].Index;

    Triangle:=@fTriangles[CurrentNode.fTriangleIndices[TriangleIndex]];

    CurrentAxisSplitPosition:=ProposedSplitPosition;
    CurrentAxisSplitPosition:=Max(CurrentAxisSplitPosition,Max(CurrentNode.fAABB.Min.xyz[AxisIndex],Min(Min(Triangle^.Vertices[0].Position.xyz[AxisIndex],Triangle^.Vertices[1].Position.xyz[AxisIndex]),Triangle^.Vertices[2].Position.xyz[AxisIndex])));
    CurrentAxisSplitPosition:=Min(CurrentAxisSplitPosition,Min(CurrentNode.fAABB.Max.xyz[AxisIndex],Max(Max(Triangle^.Vertices[0].Position.xyz[AxisIndex],Triangle^.Vertices[1].Position.xyz[AxisIndex]),Triangle^.Vertices[2].Position.xyz[AxisIndex])));

    LeftAABB:=CurrentNode.fAABB;
    RightAABB:=CurrentNode.fAABB;
    LeftAABB.Max.xyz[AxisIndex]:=CurrentAxisSplitPosition;
    RightAABB.Min.xyz[AxisIndex]:=CurrentAxisSplitPosition;
    LeftProb:=LeftAABB.Area/ParentArea;
    RightProb:=RightAABB.Area/ParentArea;

    //FarthestSweepEventIndex:=SweepEventIndex;
    while (FarthestSweepEventIndex<CountSweepEvents) and (fSweepEvents[FarthestSweepEventIndex].Position<=ProposedSplitPosition) do begin
     if fSweepEvents[FarthestSweepEventIndex].Start then begin
      inc(LeftCount);
     end else begin
      dec(RightCount);
     end;
     inc(FarthestSweepEventIndex);
    end;
    //SweepEventIndex:=Max(SweepEventIndex,FarthestSweepEventIndex-1);

    if ((CurrentAxisSplitPosition<CurrentNode.fAABB.Max.xyz[AxisIndex]) and (CurrentAxisSplitPosition>CurrentNode.fAABB.Min.xyz[AxisIndex])) then begin

     CurrentAxisSplitCost:=TraversalCost+(IntersectionCost*((LeftProb*LeftCount)+(RightProb*RightCount)));

     if First or (CurrentAxisBestCost>CurrentAxisSplitCost) then begin
      First:=false;
      CurrentAxisBestCost:=CurrentAxisSplitCost;
      CurrentAxisBestSplitPosition:=CurrentAxisSplitPosition;
     end;

    end;

    inc(SweepEventIndex);

   end;

   if (not First) and
      (CurrentAxisBestCost<(IntersectionCost*CurrentNode.fCountTriangleIndices)) and
      (AllFirst or (CurrentAxisBestCost<BestSplitCost)) then begin
    LeftAABB:=CurrentNode.fAABB;
    LeftAABB.Max.xyz[AxisIndex]:=CurrentAxisBestSplitPosition;
    RightAABB:=CurrentNode.fAABB;
    RightAABB.Min.xyz[AxisIndex]:=CurrentAxisBestSplitPosition;
    LeftCount:=0;
    RightCount:=0;
    for TriangleIndex:=0 to CurrentNode.fCountTriangleIndices-1 do begin
     Triangle:=@fTriangles[CurrentNode.fTriangleIndices[TriangleIndex]];
     if CanInsertTriangle(Triangle^,LeftAABB) then begin
      inc(LeftCount);
     end;
     if CanInsertTriangle(Triangle^,RightAABB) then begin
      inc(RightCount);
     end;
    end;
    if (LeftCount>0) or (RightCount>0) then begin
     AllFirst:=false;
     BestSplitCost:=CurrentAxisBestCost;
     BestSplitAxis:=AxisIndex;
     BestSplitPosition:=CurrentAxisBestSplitPosition;
     BestLeftCount:=LeftCount;
     BestRightCount:=RightCount;
     result:=true;
    end;
   end;

  end;

 end else if CurrentNode.fCountTriangleIndices>=256 then begin

  CountSweepEvents:=CurrentNode.fCountTriangleIndices*2;
  if length(fSweepEvents)<CountSweepEvents then begin
   SetLength(fSweepEvents,CountSweepEvents*2);
  end;
  AllFirst:=true;
  BestSplitCost:=Infinity;
  ParentArea:=CurrentNode.fAABB.Area;
  for AxisIndex:=0 to 2 do begin

   CurrentAxisBestSplitPosition:=0.0;
   CurrentAxisBestCost:=Infinity;
   CurrentAxisBestSplitLeftCount:=0;
   CurrentAxisBestSplitRightCount:=0;

   First:=true;

   SweepStep:=0.1;

   SweepTimeMin:=SweepStep;
   SweepTimeMax:=1.0;

   SweepTimeBest:=-1.0;

   while SweepStep>1e-6 do begin

    SweepTimeLastBest:=SweepTimeBest;

    SweepTime:=SweepTimeMin;
    while SweepTime<SweepTimeMax do begin

     CurrentAxisSplitPosition:=FloatLerp(CurrentNode.fAABB.Min.xyz[AxisIndex],CurrentNode.fAABB.Max.xyz[AxisIndex],SweepTime);

     if not SameValue(SweepTime,SweepTimeLastBest) then begin

      LeftAABB:=CurrentNode.fAABB;
      RightAABB:=CurrentNode.fAABB;
      LeftAABB.Max.xyz[AxisIndex]:=CurrentAxisSplitPosition;
      RightAABB.Min.xyz[AxisIndex]:=CurrentAxisSplitPosition;
      LeftCount:=0;
      RightCount:=0;
      ParentCount:=0;

      if fKDTreeMode then begin
       for TriangleIndex:=0 to CurrentNode.fCountTriangleIndices-1 do begin
        Triangle:=@fTriangles[CurrentNode.fTriangleIndices[TriangleIndex]];
        if CanInsertTriangle(Triangle^,LeftAABB) then begin
         inc(LeftCount);
        end else if CanInsertTriangle(Triangle^,RightAABB) then begin
         inc(RightCount);
        end else begin
         inc(ParentCount);
        end;
       end;
      end else begin
       for TriangleIndex:=0 to CurrentNode.fCountTriangleIndices-1 do begin
        Triangle:=@fTriangles[CurrentNode.fTriangleIndices[TriangleIndex]];
        if GetTriangleMidAxisPoint(Triangle^,AxisIndex)<CurrentAxisSplitPosition then begin
         if LeftCount=0 then begin
          LeftAABB:=GetTriangleAABB(Triangle^);
         end else begin
          LeftAABB:=LeftAABB.Combine(GetTriangleAABB(Triangle^));
         end;
         inc(LeftCount);
        end else begin
         if RightCount=0 then begin
          RightAABB:=GetTriangleAABB(Triangle^);
         end else begin
          RightAABB:=RightAABB.Combine(GetTriangleAABB(Triangle^));
         end;
         inc(RightCount);
        end;
       end;
      end;

      LeftProb:=LeftAABB.Area/ParentArea;
      RightProb:=RightAABB.Area/ParentArea;

      CurrentAxisSplitCost:=TraversalCost+(IntersectionCost*((LeftProb*LeftCount)+(RightProb*RightCount)+ParentCount));

      if First or (CurrentAxisBestCost>CurrentAxisSplitCost) then begin
       First:=false;
       CurrentAxisBestCost:=CurrentAxisSplitCost;
       CurrentAxisBestSplitPosition:=CurrentAxisSplitPosition;
       CurrentAxisBestSplitLeftCount:=LeftCount;
       CurrentAxisBestSplitRightCount:=RightCount;
       SweepTimeBest:=SweepTime;
      end;

     end;

     SweepTime:=SweepTime+SweepStep;

    end;

    if First then begin
     break;
    end else begin
     SweepTimeMin:=SweepTimeBest-SweepStep;
     SweepTimeMax:=SweepTimeBest+SweepStep;
     SweepStep:=SweepStep*0.1;                
    end;

   end;

   if (not First) and
      ((CurrentAxisBestSplitLeftCount>0) or (CurrentAxisBestSplitRightCount>0)) and
      (CurrentAxisBestCost<(IntersectionCost*CurrentNode.fCountTriangleIndices)) and
      (AllFirst or (CurrentAxisBestCost<BestSplitCost)) then begin
    AllFirst:=false;
    BestSplitCost:=CurrentAxisBestCost;
    BestSplitAxis:=AxisIndex;
    BestSplitPosition:=CurrentAxisBestSplitPosition;
    BestLeftCount:=CurrentAxisBestSplitLeftCount;
    BestRightCount:=CurrentAxisBestSplitRightCount;
    result:=true;
   end;

  end;

 end else if CurrentNode.fCountTriangleIndices>MaximiumPrimitivesPerLeaf then begin

  CountSweepEvents:=CurrentNode.fCountTriangleIndices*2;
  if length(fSweepEvents)<CountSweepEvents then begin
   SetLength(fSweepEvents,CountSweepEvents*2);
  end;
  AllFirst:=true;
  BestSplitCost:=Infinity;
  ParentArea:=CurrentNode.fAABB.Area;
  for AxisIndex:=0 to 2 do begin

   CountSweepEvents:=0;
   for TriangleIndex:=0 to CurrentNode.fCountTriangleIndices-1 do begin
    c0:=0.0;
    c1:=0.0;
    if TriangleGetExtremeAxisPointsForAABB(fTriangles[CurrentNode.fTriangleIndices[TriangleIndex]],CurrentNode.fAABB.Min,CurrentNode.fAABB.Max,AxisIndex,c0,c1) then begin
     fSweepEvents[CountSweepEvents].Position:=Max(CurrentNode.fAABB.Min.xyz[AxisIndex],c0);
     fSweepEvents[CountSweepEvents].Index:=TriangleIndex;
     fSweepEvents[CountSweepEvents].Start:=true;
     inc(CountSweepEvents);
     fSweepEvents[CountSweepEvents].Position:=Min(CurrentNode.fAABB.Max.xyz[AxisIndex],c1);
     fSweepEvents[CountSweepEvents].Index:=TriangleIndex;
     fSweepEvents[CountSweepEvents].Start:=false;
     inc(CountSweepEvents);
    end;
   end;
   if CountSweepEvents>1 then begin
    UntypedDirectIntroSort(@fSweepEvents[0],0,CountSweepEvents-1,SizeOf(TpvStaticTriangleBVHSweepEvent),@CompareSweepEvent);
   end;

   CurrentAxisBestSplitPosition:=0.0;
   CurrentAxisBestCost:=Infinity;
   CurrentAxisBestSplitLeftCount:=0;
   CurrentAxisBestSplitRightCount:=0;

   First:=true;

   for SweepEventIndex:=0 to CountSweepEvents-1 do begin

    CurrentAxisSplitPosition:=fSweepEvents[SweepEventIndex].Position;

    if ((CurrentAxisSplitPosition>CurrentNode.fAABB.Min.xyz[AxisIndex]) and (CurrentAxisSplitPosition<CurrentNode.fAABB.Max.xyz[AxisIndex])) and
       ((SweepEventIndex=0) or not SameValue(CurrentAxisSplitPosition,fSweepEvents[SweepEventIndex-1].Position)) then begin

     LeftAABB:=CurrentNode.fAABB;
     RightAABB:=CurrentNode.fAABB;
     LeftAABB.Max.xyz[AxisIndex]:=CurrentAxisSplitPosition;
     RightAABB.Min.xyz[AxisIndex]:=CurrentAxisSplitPosition;
     LeftCount:=0;
     RightCount:=0;
     ParentCount:=0;

     if fKDTreeMode then begin
      for TriangleIndex:=0 to CurrentNode.fCountTriangleIndices-1 do begin
       Triangle:=@fTriangles[CurrentNode.fTriangleIndices[TriangleIndex]];
       if CanInsertTriangle(Triangle^,LeftAABB) then begin
        inc(LeftCount);
       end else if CanInsertTriangle(Triangle^,RightAABB) then begin
        inc(RightCount);
       end else begin
        inc(ParentCount);
       end;
      end;
     end else begin
      for TriangleIndex:=0 to CurrentNode.fCountTriangleIndices-1 do begin
       Triangle:=@fTriangles[CurrentNode.fTriangleIndices[TriangleIndex]];
       if GetTriangleMidAxisPoint(Triangle^,AxisIndex)<CurrentAxisSplitPosition then begin
        if LeftCount=0 then begin
         LeftAABB:=GetTriangleAABB(Triangle^);
        end else begin
         LeftAABB:=LeftAABB.Combine(GetTriangleAABB(Triangle^));
        end;
        inc(LeftCount);
       end else begin
        if RightCount=0 then begin
         RightAABB:=GetTriangleAABB(Triangle^);
        end else begin
         RightAABB:=RightAABB.Combine(GetTriangleAABB(Triangle^));
        end;
        inc(RightCount);
       end;
      end;
     end;

     LeftProb:=LeftAABB.Area/ParentArea;
     RightProb:=RightAABB.Area/ParentArea;

     CurrentAxisSplitCost:=TraversalCost+(IntersectionCost*((LeftProb*LeftCount)+(RightProb*RightCount)+ParentCount));

     if First or (CurrentAxisBestCost>CurrentAxisSplitCost) then begin
      First:=false;
      CurrentAxisBestCost:=CurrentAxisSplitCost;
      CurrentAxisBestSplitPosition:=CurrentAxisSplitPosition;
      CurrentAxisBestSplitLeftCount:=LeftCount;
      CurrentAxisBestSplitRightCount:=RightCount;
     end;

    end;

   end;

   if (not First) and
      ((CurrentAxisBestSplitLeftCount>0) or (CurrentAxisBestSplitRightCount>0)) and
      (CurrentAxisBestCost<(IntersectionCost*CurrentNode.fCountTriangleIndices)) and
      (AllFirst or (CurrentAxisBestCost<BestSplitCost)) then begin
    AllFirst:=false;
    BestSplitCost:=CurrentAxisBestCost;
    BestSplitAxis:=AxisIndex;
    BestSplitPosition:=CurrentAxisBestSplitPosition;
    BestLeftCount:=CurrentAxisBestSplitLeftCount;
    BestRightCount:=CurrentAxisBestSplitRightCount;
    result:=true;
   end;

  end;

 end;
end;

procedure TpvStaticTriangleBVH.BuildFromRoot(MaxDepth:TpvInt32);
type TStackItem=record
      Node:TpvStaticTriangleBVHNode;
      Parent:TpvStaticTriangleBVHNode;
      Depth:TpvInt32;
     end;
     PStackItem=^TStackItem;
     TStack=TpvDynamicStack<TStackItem>;
var Stack:TStack;
    CurrentDepth,CurrentSplitAxis,CurrentLeftCount,CurrentRightCount,TriangleIndex,NodeIndex,CountTriangles:TpvInt32;
    StackItem:TStackItem;
    CurrentNode,LeftNode,RightNode:TpvStaticTriangleBVHNode;
    CurrentAxisSplitPosition,MinPosition,MaxPosition:TpvFloat;
    TryAgain,OK:boolean;
    CurrentTriangle:TpvStaticTriangleBVHTriangleIndex;
    Triangles:TpvStaticTriangleBVHTriangleIndices;
begin
 Stack.Initialize;
 try
  fSweepEvents:=nil;
  try
   Triangles:=nil;
   try
    fRoot.fAxis:=-1;
    fRoot.UpdateAABB;
    StackItem.Node:=fRoot;
    StackItem.Depth:=MaxDepth;
    Stack.Push(StackItem);
    while Stack.Pop(StackItem) do begin
     CurrentNode:=StackItem.Node;
     CurrentDepth:=StackItem.Depth;
     while assigned(CurrentNode) do begin
      if CurrentDepth>0 then begin
       CurrentSplitAxis:=0;
       CurrentAxisSplitPosition:=0.0;
       CurrentLeftCount:=0;
       CurrentRightCount:=0;
       if SearchBestSplitPlane(CurrentNode,CurrentSplitAxis,CurrentAxisSplitPosition,CurrentLeftCount,CurrentRightCount) then begin
        if (CurrentLeftCount=CurrentNode.fCountTriangleIndices) and (CurrentRightCount=0) then begin
         if fKDTreeMode then begin
          CurrentNode.fAABB.Max.xyz[CurrentSplitAxis]:=CurrentAxisSplitPosition;
          CurrentNode.fAxis:=CurrentSplitAxis;
          CurrentNode.fLeft:=nil;
          CurrentNode.fRight:=nil;
          continue;
         end else begin
          CurrentNode.UpdateAABB;
         end;
        end else if (CurrentLeftCount=0) and (CurrentRightCount=CurrentNode.fCountTriangleIndices) then begin
         if fKDTreeMode then begin
          CurrentNode.fAABB.Min.xyz[CurrentSplitAxis]:=CurrentAxisSplitPosition;
          CurrentNode.fAxis:=CurrentSplitAxis;
          CurrentNode.fLeft:=nil;
          CurrentNode.fRight:=nil;
          continue;
         end else begin
          CurrentNode.UpdateAABB;
         end;
        end else if (CurrentLeftCount>0) or (CurrentRightCount>0) then begin
         LeftNode:=TpvStaticTriangleBVHNode.Create(self);
         RightNode:=TpvStaticTriangleBVHNode.Create(self);
         LeftNode.fAABB:=CurrentNode.fAABB;
         RightNode.fAABB:=CurrentNode.fAABB;
         LeftNode.fAABB.Max.xyz[CurrentSplitAxis]:=CurrentAxisSplitPosition;
         RightNode.fAABB.Min.xyz[CurrentSplitAxis]:=CurrentAxisSplitPosition;
         LeftNode.fAxis:=CurrentSplitAxis;
         RightNode.fAxis:=CurrentSplitAxis;
         Triangles:=CurrentNode.fTriangleIndices;
         CountTriangles:=CurrentNode.fCountTriangleIndices;
         CurrentNode.fTriangleIndices:=nil;
         CurrentNode.fCountTriangleIndices:=0;
         if fKDTreeMode then begin
          for TriangleIndex:=0 to CountTriangles-1 do begin
           CurrentTriangle:=Triangles[TriangleIndex];
           if CanInsertTriangle(fTriangles[CurrentTriangle],LeftNode.fAABB) then begin
            LeftNode.InsertTriangle(CurrentTriangle);
           end else if CanInsertTriangle(fTriangles[CurrentTriangle],RightNode.fAABB) then begin
            RightNode.InsertTriangle(CurrentTriangle);
           end else begin
            CurrentNode.InsertTriangle(CurrentTriangle);
           end;
          end;
         end else begin
          for TriangleIndex:=0 to CountTriangles-1 do begin
           CurrentTriangle:=Triangles[TriangleIndex];
           if GetTriangleMidAxisPoint(fTriangles[CurrentTriangle],CurrentSplitAxis)<CurrentAxisSplitPosition then begin
            LeftNode.InsertTriangle(CurrentTriangle);
           end else begin
            RightNode.InsertTriangle(CurrentTriangle);
           end;
          end;
         end;
         SetLength(Triangles,0);
         if LeftNode.fCountTriangleIndices=0 then begin
          FreeAndNil(LeftNode);
         end else if not fKDTreeMode then begin
          LeftNode.UpdateAABB;
         end;
         if RightNode.fCountTriangleIndices=0 then begin
          FreeAndNil(RightNode);
         end else if not fKDTreeMode then begin
          RightNode.UpdateAABB;
         end;
         CurrentNode.fLeft:=LeftNode;
         CurrentNode.fRight:=RightNode;
         if assigned(RightNode) then begin
          StackItem.Node:=RightNode;
          StackItem.Depth:=CurrentDepth-1;
          Stack.Push(StackItem);
         end;
         if assigned(LeftNode) then begin
          StackItem.Node:=LeftNode;
          StackItem.Depth:=CurrentDepth-1;
          Stack.Push(StackItem);
         end;
        end;
       end;
      end;
      CurrentNode:=nil;
     end;
    end;
    repeat
     TryAgain:=false;
     StackItem.Node:=fRoot;
     StackItem.Parent:=nil;
     StackItem.Depth:=1;
     Stack.Push(StackItem);
     while Stack.Pop(StackItem) do begin
      CurrentNode:=StackItem.Node;
      if assigned(CurrentNode) then begin
       if assigned(CurrentNode.fLeft) and not assigned(CurrentNode.fRight) then begin
        if assigned(StackItem.Parent) then begin
         if StackItem.Parent.fLeft=CurrentNode then begin
          StackItem.Parent.fLeft:=CurrentNode.fLeft;
          CurrentNode.fLeft:=nil;
          CurrentNode.fRight:=nil;
          FreeAndNil(CurrentNode);
         end else if StackItem.Parent.fRight=CurrentNode then begin
          StackItem.Parent.fRight:=CurrentNode.fLeft;
          CurrentNode.fLeft:=nil;
          CurrentNode.fRight:=nil;
          FreeAndNil(CurrentNode);
         end;
        end else begin
         fRoot.fLeft:=nil;
         fRoot.fRight:=nil;
         FreeAndNil(fRoot);
         fRoot:=CurrentNode.fLeft;
         CurrentNode.fLeft:=nil;
         CurrentNode.fRight:=nil;
         FreeAndNil(CurrentNode);
        end;
        TryAgain:=true;
       end else if assigned(CurrentNode.fRight) and not assigned(CurrentNode.fLeft) then begin
        if assigned(StackItem.Parent) then begin
         if StackItem.Parent.fLeft=CurrentNode then begin
          StackItem.Parent.fLeft:=CurrentNode.fRight;
          CurrentNode.fLeft:=nil;
          CurrentNode.fRight:=nil;
          FreeAndNil(CurrentNode);
         end else if StackItem.Parent.fRight=CurrentNode then begin
          StackItem.Parent.fRight:=CurrentNode.fRight;
          CurrentNode.fLeft:=nil;
          CurrentNode.fRight:=nil;
          FreeAndNil(CurrentNode);
         end;
        end else begin
         fRoot.fLeft:=nil;
         fRoot.fRight:=nil;
         FreeAndNil(fRoot);
         fRoot:=CurrentNode.fRight;
         CurrentNode.fLeft:=nil;
         CurrentNode.fRight:=nil;
         FreeAndNil(CurrentNode);
        end;
        TryAgain:=true;
       end;
       if assigned(CurrentNode) then begin
        if assigned(CurrentNode.fRight) then begin
         StackItem.Node:=CurrentNode.fRight;
         StackItem.Parent:=CurrentNode;
         Stack.Push(StackItem);
        end;
        if assigned(CurrentNode.fLeft) then begin
         StackItem.Node:=CurrentNode.fLeft;
         StackItem.Parent:=CurrentNode;
         Stack.Push(StackItem);
        end;
       end;
      end;
     end;
    until not TryAgain;
    begin
     NodeIndex:=0;
     TriangleIndex:=0;
     StackItem.Node:=fRoot;
     StackItem.Depth:=1;
     Stack.Push(StackItem);
     while Stack.Pop(StackItem) do begin
      CurrentNode:=StackItem.Node;
      CurrentDepth:=StackItem.Depth;
      if assigned(CurrentNode) then begin
       if CurrentDepth>0 then begin
        CurrentNode.fNodeIndex:=NodeIndex;
        inc(NodeIndex);
        CurrentNode.fTriangleIndex:=TriangleIndex;
        inc(TriangleIndex,CurrentNode.fCountTriangleIndices);
        begin
         StackItem.Node:=CurrentNode;
         StackItem.Depth:=-1;
         Stack.Push(StackItem);
        end;
        if assigned(CurrentNode.fRight) then begin
         StackItem.Node:=CurrentNode.fRight;
         StackItem.Depth:=1;
         Stack.Push(StackItem);
        end;
        if assigned(CurrentNode.fLeft) then begin
         StackItem.Node:=CurrentNode.fLeft;
         StackItem.Depth:=1;
         Stack.Push(StackItem);
        end;
       end else begin
        CurrentNode.fSkipToNode:=NodeIndex;
        CurrentNode.fCountAllContainingNodes:=NodeIndex-CurrentNode.fNodeIndex;
        CurrentNode.fCountAllContainingTriangles:=TriangleIndex-CurrentNode.fTriangleIndex;
       end;
      end;
     end;
     SetLength(fNodes,NodeIndex);
    end;
    begin
     fCountLeafs:=0;
     StackItem.Node:=fRoot;
     StackItem.Depth:=1;
     Stack.Push(StackItem);
     while Stack.Pop(StackItem) do begin
      CurrentNode:=StackItem.Node;
      if assigned(CurrentNode) then begin
       if not (assigned(CurrentNode.fLeft) or assigned(CurrentNode.fRight)) then begin
        inc(fCountLeafs);
       end;
       fNodes[CurrentNode.fNodeIndex]:=CurrentNode;
       if assigned(CurrentNode.fRight) then begin
        StackItem.Node:=CurrentNode.fRight;
        StackItem.Depth:=1;
        Stack.Push(StackItem);
       end;
       if assigned(CurrentNode.fLeft) then begin
        StackItem.Node:=CurrentNode.fLeft;
        StackItem.Depth:=1;
        Stack.Push(StackItem);
       end;
      end;
     end;
    end;
    begin
     StackItem.Node:=fRoot;
     StackItem.Depth:=1;
     Stack.Push(StackItem);
     while Stack.Pop(StackItem) do begin
      CurrentNode:=StackItem.Node;
      CurrentDepth:=StackItem.Depth;
      if assigned(CurrentNode) then begin
       if CurrentDepth>0 then begin
        CurrentNode.UpdateAABB;
        if assigned(CurrentNode.fLeft) or assigned(CurrentNode.fRight) then begin
         begin
          StackItem.Node:=CurrentNode;
          StackItem.Depth:=-1;
          Stack.Push(StackItem);
         end;
         if assigned(CurrentNode.fRight) then begin
          StackItem.Node:=CurrentNode.fRight;
          StackItem.Depth:=1;
          Stack.Push(StackItem);
         end;
         if assigned(CurrentNode.fLeft) then begin
          StackItem.Node:=CurrentNode.fLeft;
          StackItem.Depth:=1;
          Stack.Push(StackItem);
         end;
        end;
       end;
      end else begin
       if assigned(CurrentNode.fLeft) and assigned(CurrentNode.fRight) then begin
        CurrentNode.fAABB:=CurrentNode.fAABB.GetIntersection(CurrentNode.fAABB.Combine(CurrentNode.fLeft.fAABB.Combine(CurrentNode.fRight.fAABB)));
       end else if assigned(CurrentNode.fLeft) then begin
        CurrentNode.fAABB:=CurrentNode.fAABB.GetIntersection(CurrentNode.fAABB.Combine(CurrentNode.fLeft.fAABB));
       end else if assigned(CurrentNode.fRight) then begin
        CurrentNode.fAABB:=CurrentNode.fAABB.GetIntersection(CurrentNode.fAABB.Combine(CurrentNode.fRight.fAABB));
       end;
      end;
     end;
    end;
   finally
    Triangles:=nil;
   end;
  finally
   fSweepEvents:=nil;
  end;
 finally
  Stack.Finalize;
 end;
end;

procedure TpvStaticTriangleBVH.Build(const Triangles:TpvStaticTriangleBVHTriangles;const aMaxDepth:TpvInt32);
const ModuloThree:array[0..5] of TpvInt32=(0,1,2,0,1,2);
var i,j,k,Pass,U,V:TpvInt32;
    TriangleIndex,DominantAxis:TpvUInt32;
    SkipListNode:PpvStaticTriangleBVHSkipListNode;
    SkipListTriangle:PpvStaticTriangleBVHSkipListTriangle;
    Node:TpvStaticTriangleBVHNode;
    Triangle:PpvStaticTriangleBVHTriangle;
    B,C,Cross,Normal:TpvVector3;
    WholeArea,BarycentricDivide:TpvScalar;
    TempVertex:TpvStaticTriangleBVHTriangleVertex;
begin
 FreeAndNil(fRoot);
 fTriangles:=copy(Triangles);
 fCountTriangles:=length(Triangles);
 fRoot:=TpvStaticTriangleBVHNode.Create(self);
 fRoot.fTriangleIndices:=nil;
 fRoot.fCountTriangleIndices:=length(Triangles);
 SetLength(fRoot.fTriangleIndices,fRoot.fCountTriangleIndices);
 fRoot.fFlags:=0;
 for i:=0 to fRoot.fCountTriangleIndices-1 do begin
  fRoot.fTriangleIndices[i]:=i;
  Triangle:=@fTriangles[fRoot.fTriangleIndices[i]];
  fRoot.fFlags:=fRoot.fFlags or Triangle^.Flags;
  for j:=0 to 2 do begin
   if (i=0) and (j=0) then begin
    fRoot.fAABB.Min:=Triangle^.Vertices[j].Position;
    fRoot.fAABB.Max:=Triangle^.Vertices[j].Position;
   end else begin
    if fRoot.fAABB.Min.x>Triangle^.Vertices[j].Position.x then begin
     fRoot.fAABB.Min.x:=Triangle^.Vertices[j].Position.x;
    end;
    if fRoot.fAABB.Min.y>Triangle^.Vertices[j].Position.y then begin
     fRoot.fAABB.Min.y:=Triangle^.Vertices[j].Position.y;
    end;
    if fRoot.fAABB.Min.z>Triangle^.Vertices[j].Position.z then begin
     fRoot.fAABB.Min.z:=Triangle^.Vertices[j].Position.z;
    end;
    if fRoot.fAABB.Max.x<Triangle^.Vertices[j].Position.x then begin
     fRoot.fAABB.Max.x:=Triangle^.Vertices[j].Position.x;
    end;
    if fRoot.fAABB.Max.y<Triangle^.Vertices[j].Position.y then begin
     fRoot.fAABB.Max.y:=Triangle^.Vertices[j].Position.y;
    end;
    if fRoot.fAABB.Max.z<Triangle^.Vertices[j].Position.z then begin
     fRoot.fAABB.Max.z:=Triangle^.Vertices[j].Position.z;
    end;
   end;
  end;
 end;
 BuildFromRoot(aMaxDepth);
 begin
  SetLength(fSkipListTriangles,length(Triangles));
  TriangleIndex:=0;
  for i:=0 to fCountTriangles-1 do begin
   if TriangleIndex>=TpvUInt32(length(fSkipListTriangles)) then begin
    SetLength(fSkipListTriangles,(TriangleIndex+1)*2);
   end;
   Triangle:=@fTriangles[i];
   SkipListTriangle:=@fSkipListTriangles[TriangleIndex];
   for Pass:=0 to 1 do begin
    B:=Triangle^.Vertices[2].Position-Triangle^.Vertices[0].Position;
    C:=Triangle^.Vertices[1].Position-Triangle^.Vertices[0].Position;
    Cross:=C.Cross(B);
    Normal:=Cross.Normalize;
    WholeArea:=Normal.Dot(Cross);
    if abs(Normal.x)>abs(Normal.y) then begin
     if abs(Normal.x)>abs(Normal.z) then begin
      DominantAxis:=0;
     end else begin
      DominantAxis:=2;
     end;
    end else begin
     if abs(Normal.y)>abs(Normal.z) then begin
      DominantAxis:=1;
     end else begin
      DominantAxis:=2;
     end;
    end;
    U:=ModuloThree[DominantAxis+1];
    V:=ModuloThree[DominantAxis+2];
    if Pass=0 then begin
     if ((Triangle^.Vertices[1].Position.xyz[V]-Triangle^.Vertices[2].Position.xyz[V])*
         (Triangle^.Vertices[1].Position.xyz[U]-Triangle^.Vertices[0].Position.xyz[U]))<
        ((Triangle^.Vertices[1].Position.xyz[U]-Triangle^.Vertices[2].Position.xyz[U])*
         (Triangle^.Vertices[1].Position.xyz[V]-Triangle^.Vertices[0].Position.xyz[V])) then begin
      TempVertex:=Triangle^.Vertices[0];
      Triangle^.Vertices[0]:=Triangle^.Vertices[2];
      Triangle^.Vertices[2]:=TempVertex;
     end else begin
      break;
     end;
    end else begin
     break;
    end;
   end;
   BarycentricDivide:=((B.xyz[U]*C.xyz[V])-(B.xyz[V]*C.xyz[U]));
   if IsZero(BarycentricDivide) then begin
    BarycentricDivide:=0.0;
   end else begin
    BarycentricDivide:=1.0/BarycentricDivide;
   end;
   SkipListTriangle^.Vertices[0].Position:=TpvVector4.Create(Triangle^.Vertices[0].Position,B[U]);
   SkipListTriangle^.Vertices[1].Position:=TpvVector4.Create(Triangle^.Vertices[1].Position,B[V]);
   SkipListTriangle^.Vertices[2].Position:=TpvVector4.Create(Triangle^.Vertices[2].Position,0.0);
   SkipListTriangle^.Vertices[0].Normal:=TpvVector4.Create(Triangle^.Vertices[0].Normal,C[U]);
   SkipListTriangle^.Vertices[1].Normal:=TpvVector4.Create(Triangle^.Vertices[1].Normal,C[V]);
   SkipListTriangle^.Vertices[2].Normal:=TpvVector4.Create(Triangle^.Vertices[2].Normal,0.0);
   SkipListTriangle^.Vertices[0].Tangent:=TpvVector4.Create(Triangle^.Vertices[0].Tangent,0.0);
   SkipListTriangle^.Vertices[1].Tangent:=TpvVector4.Create(Triangle^.Vertices[1].Tangent,0.0);
   SkipListTriangle^.Vertices[2].Tangent:=TpvVector4.Create(Triangle^.Vertices[2].Tangent,0.0);
   for k:=0 to 2 do begin
    if (Triangle^.Vertices[k].Normal.Cross(Triangle^.Vertices[k].Tangent).Normalize).Dot(Triangle^.Vertices[k].Bitangent)<0.0 then begin
     SkipListTriangle^.Vertices[k].Tangent.w:=-1.0;
    end else begin
     SkipListTriangle^.Vertices[k].Tangent.w:=1.0;
    end;
   end;
   SkipListTriangle^.Vertices[0].TexCoord:=TpvVector4.Create(Triangle^.Vertices[0].TexCoord,0.0,Triangle^.Normal.x);
   TpvUInt32(pointer(@SkipListTriangle^.Vertices[0].TexCoord.z)^):=(U shl 16) or (V and $ffff);
   SkipListTriangle^.Vertices[1].TexCoord:=TpvVector4.Create(Triangle^.Vertices[1].TexCoord,BarycentricDivide,Triangle^.Normal.y);
   SkipListTriangle^.Vertices[2].TexCoord:=TpvVector4.Create(Triangle^.Vertices[2].TexCoord,0.0,Triangle^.Normal.z);
   SkipListTriangle^.Material:=Triangle^.Material;
   SkipListTriangle^.Flags:=Triangle^.Flags;
   SkipListTriangle^.Tag:=Triangle^.Tag;
   SkipListTriangle^.AvoidSelfShadowingTag:=Triangle^.AvoidSelfShadowingTag;
   inc(TriangleIndex);
  end;
  SetLength(fSkipListTriangles,TriangleIndex);
  SetLength(fSkipListTriangleIndices,length(Triangles));
  SetLength(fSkipListNodes,length(fNodes));
  TriangleIndex:=0;
  for i:=0 to length(fNodes)-1 do begin
   Node:=fNodes[i];
   SkipListNode:=@fSkipListNodes[Node.fNodeIndex];
   SkipListNode^.AABBMin:=Node.fAABB.Min;
   SkipListNode^.Flags:=Node.fFlags;
   SkipListNode^.AABBMax:=Node.fAABB.Max;
   SkipListNode^.SkipCount:=Node.fSkipToNode-Node.fNodeIndex;
   if assigned(Node.fLeft) then begin
    SkipListNode^.Left:=Node.fLeft.fNodeIndex;
   end else begin
    SkipListNode^.Left:=TpvUInt32($ffffffff);
   end;
   if assigned(Node.fRight) then begin
    SkipListNode^.Right:=Node.fRight.fNodeIndex;
   end else begin
    SkipListNode^.Right:=TpvUInt32($ffffffff);
   end;
   if Node.fCountTriangleIndices>0 then begin
    SkipListNode^.FirstTriangleIndex:=TriangleIndex;
    SkipListNode^.CountTriangleIndices:=Node.fCountTriangleIndices;
   end else begin
    SkipListNode^.FirstTriangleIndex:=0;
    SkipListNode^.CountTriangleIndices:=0;
   end;
   for j:=0 to Node.fCountTriangleIndices-1 do begin
    if TriangleIndex>=TpvUInt32(length(fSkipListTriangleIndices)) then begin
     SetLength(fSkipListTriangleIndices,(TriangleIndex+1)*2);
    end;
    fSkipListTriangleIndices[TriangleIndex]:=Node.fTriangleIndices[j];
    inc(TriangleIndex);
   end;
  end;
  SetLength(fSkipListTriangleIndices,TriangleIndex);
 end;
 FreeAndNil(fRoot);
 SetLength(fNodes,0);
 SetLength(fTriangles,0);
end;

function TpvStaticTriangleBVH.RayIntersection(const Ray:TpvStaticTriangleBVHRay;var Intersection:TpvStaticTriangleBVHIntersection;FastCheck,Exact:boolean;const AvoidTag:TpvUInt32=$ffffffff;const AvoidOtherTag:TpvUInt32=$ffffffff;const AvoidSelfShadowingTag:TpvUInt32=$ffffffff;const Flags:TpvUInt32=$ffffffff):boolean;
var SkipListNodeIndex,CountSkipListNodes,TriangleIndex:TpvInt32;
    SkipListNode:PpvStaticTriangleBVHSkipListNode;
    SkipListTriangle:PpvStaticTriangleBVHSkipListTriangle;
    Time,u,v:TpvFloat;
    OK:boolean;
begin
 result:=false;
 SkipListNodeIndex:=0;
 CountSkipListNodes:=length(fSkipListNodes);
 while SkipListNodeIndex<CountSkipListNodes do begin
  SkipListNode:=@fSkipListNodes[SkipListNodeIndex];
  if AABBRayIntersection(SkipListNode^.AABBMin,SkipListNode^.AABBMax,Ray,Time) then begin
   for TriangleIndex:=SkipListNode^.FirstTriangleIndex to (SkipListNode^.FirstTriangleIndex+SkipListNode^.CountTriangleIndices)-1 do begin
    SkipListTriangle:=@fSkipListTriangles[fSkipListTriangleIndices[TriangleIndex]];
    if ((SkipListTriangle^.Tag<>AvoidTag) and (SkipListTriangle^.Tag<>AvoidOtherTag)) and (SkipListTriangle^.AvoidSelfShadowingTag<>AvoidSelfShadowingTag) and ((SkipListTriangle^.Flags and Flags)<>0) then begin
     if Exact then begin
      OK:=TriangleRayIntersectionExact(SkipListTriangle^,Ray,Time);
     end else begin
      OK:=TriangleRayIntersectionLazy(SkipListTriangle^,Ray,Time,u,v);
      if OK and
         (((u<(-ASLF_EPSILON)) or (u>(1.0+ASLF_EPSILON)) or
           (v<(-ASLF_EPSILON)) or ((u+v)>(1.0+ASLF_EPSILON))) or
          ((SkipListTriangle^.AvoidSelfShadowingTag=AvoidSelfShadowingTag) and
           (Time<=SELF_SHADOW_EPSILON))
         ) then begin
       OK:=false;
      end;
     end;
     if OK then begin
      if IsInfinite(Intersection.Time) or (Time<Intersection.Time) then begin
       result:=true;
       Intersection.Time:=Time;
       if FastCheck then begin
        exit;
       end;
       Intersection.SkipListTriangle:=SkipListTriangle;
       Intersection.HitPoint:=Ray.Origin+(Ray.Direction*Time);
       TriangleInterpolation(Intersection.SkipListTriangle^,Intersection.HitPoint,Intersection.Barycentrics,Intersection.Normal,Intersection.Tangent,Intersection.Bitangent,Intersection.TexCoord);
      end;
     end;
    end;
   end;
   inc(SkipListNodeIndex);
  end else begin
   if SkipListNode^.SkipCount=0 then begin
    break;
   end else begin
    inc(SkipListNodeIndex,SkipListNode^.SkipCount);
   end;
  end;
 end;
end;

function TpvStaticTriangleBVH.ExactRayIntersection(const Ray:TpvStaticTriangleBVHRay;var Intersection:TpvStaticTriangleBVHIntersection;const AvoidTag:TpvUInt32=$ffffffff;const AvoidOtherTag:TpvUInt32=$ffffffff;const AvoidSelfShadowingTag:TpvUInt32=$ffffffff;const Flags:TpvUInt32=$ffffffff):boolean;
var SkipListNodeIndex,CountSkipListNodes,TriangleIndex:TpvInt32;
    SkipListNode:PpvStaticTriangleBVHSkipListNode;
    SkipListTriangle:PpvStaticTriangleBVHSkipListTriangle;
    Time:TpvFloat;
begin
 result:=false;
 SkipListNodeIndex:=0;
 CountSkipListNodes:=length(fSkipListNodes);
 while SkipListNodeIndex<CountSkipListNodes do begin
  SkipListNode:=@fSkipListNodes[SkipListNodeIndex];
  if AABBRayIntersection(SkipListNode^.AABBMin,SkipListNode^.AABBMax,Ray,Time) then begin
   for TriangleIndex:=SkipListNode^.FirstTriangleIndex to (SkipListNode^.FirstTriangleIndex+SkipListNode^.CountTriangleIndices)-1 do begin
    SkipListTriangle:=@fSkipListTriangles[fSkipListTriangleIndices[TriangleIndex]];
    if ((SkipListTriangle^.Tag<>AvoidTag) and (SkipListTriangle^.Tag<>AvoidOtherTag)) and (SkipListTriangle^.AvoidSelfShadowingTag<>AvoidSelfShadowingTag) and ((SkipListTriangle^.Flags and Flags)<>0) then begin
     if TriangleRayIntersectionExact(SkipListTriangle^,Ray,Time) then begin
      if IsInfinite(Intersection.Time) or (Time<Intersection.Time) then begin
       result:=true;
       Intersection.Time:=Time;
       Intersection.SkipListTriangle:=SkipListTriangle;
       Intersection.HitPoint:=Ray.Origin+(Ray.Direction*Time);
       TriangleInterpolation(Intersection.SkipListTriangle^,Intersection.HitPoint,Intersection.Barycentrics,Intersection.Normal,Intersection.Tangent,Intersection.Bitangent,Intersection.TexCoord);
       exit;
      end;
     end;
    end;
   end;
   inc(SkipListNodeIndex);
  end else begin
   if SkipListNode^.SkipCount=0 then begin
    break;
   end else begin
    inc(SkipListNodeIndex,SkipListNode^.SkipCount);
   end;
  end;
 end;
end;

function TpvStaticTriangleBVH.FastRayIntersection(const Ray:TpvStaticTriangleBVHRay;var Intersection:TpvStaticTriangleBVHIntersection;const AvoidTag:TpvUInt32=$ffffffff;const AvoidOtherTag:TpvUInt32=$ffffffff;const AvoidSelfShadowingTag:TpvUInt32=$ffffffff;const Flags:TpvUInt32=$ffffffff):boolean;
var SkipListNodeIndex,CountSkipListNodes,TriangleIndex:TpvInt32;
    SkipListNode:PpvStaticTriangleBVHSkipListNode;
    SkipListTriangle:PpvStaticTriangleBVHSkipListTriangle;
    Time:TpvFloat;
begin
 result:=false;
 SkipListNodeIndex:=0;
 CountSkipListNodes:=length(fSkipListNodes);
 while SkipListNodeIndex<CountSkipListNodes do begin
  SkipListNode:=@fSkipListNodes[SkipListNodeIndex];
  if AABBRayIntersection(SkipListNode^.AABBMin,SkipListNode^.AABBMax,Ray,Time) then begin
   for TriangleIndex:=SkipListNode^.FirstTriangleIndex to (SkipListNode^.FirstTriangleIndex+SkipListNode^.CountTriangleIndices)-1 do begin
    SkipListTriangle:=@fSkipListTriangles[fSkipListTriangleIndices[TriangleIndex]];
    if ((SkipListTriangle^.Tag<>AvoidTag) and (SkipListTriangle^.Tag<>AvoidOtherTag)) and (SkipListTriangle^.AvoidSelfShadowingTag<>AvoidSelfShadowingTag) and ((SkipListTriangle^.Flags and Flags)<>0) then begin
     if TriangleRayIntersectionExact(SkipListTriangle^,Ray,Time) then begin
      if IsInfinite(Intersection.Time) or (Time<Intersection.Time) then begin
       result:=true;
       Intersection.Time:=Time;
       exit;
      end;
     end;
    end;
   end;
   inc(SkipListNodeIndex);
  end else begin
   if SkipListNode^.SkipCount=0 then begin
    break;
   end else begin
    inc(SkipListNodeIndex,SkipListNode^.SkipCount);
   end;
  end;
 end;
end;

function TpvStaticTriangleBVH.CountRayIntersections(const Ray:TpvStaticTriangleBVHRay;const Flags:TpvUInt32=$ffffffff):TpvInt32;
var SkipListNodeIndex,CountSkipListNodes,TriangleIndex:TpvInt32;
    SkipListNode:PpvStaticTriangleBVHSkipListNode;
    SkipListTriangle:PpvStaticTriangleBVHSkipListTriangle;
    Time:TpvFloat;
begin
 result:=0;
 SkipListNodeIndex:=0;
 CountSkipListNodes:=length(fSkipListNodes);
 while SkipListNodeIndex<CountSkipListNodes do begin
  SkipListNode:=@fSkipListNodes[SkipListNodeIndex];
  if AABBRayIntersection(SkipListNode^.AABBMin,SkipListNode^.AABBMax,Ray,Time) then begin
   for TriangleIndex:=SkipListNode^.FirstTriangleIndex to (SkipListNode^.FirstTriangleIndex+SkipListNode^.CountTriangleIndices)-1 do begin
    SkipListTriangle:=@fSkipListTriangles[fSkipListTriangleIndices[TriangleIndex]];
    if TriangleRayIntersectionExact(SkipListTriangle^,Ray,Time) then begin
     inc(result);
    end;
   end;
   inc(SkipListNodeIndex);
  end else begin
   if SkipListNode^.SkipCount=0 then begin
    break;
   end else begin
    inc(SkipListNodeIndex,SkipListNode^.SkipCount);
   end;
  end;
 end;
end;

function TpvStaticTriangleBVH.LineIntersection(const v0,v1:TpvVector3;const Exact:boolean=true;const Flags:TpvUInt32=$ffffffff):boolean;
var Ray:TpvStaticTriangleBVHRay;
    Intersection:TpvStaticTriangleBVHIntersection;
    Distance:TpvFloat;
begin
 result:=false;
 FillChar(Intersection,SizeOf(TpvStaticTriangleBVHIntersection),AnsiChar(#0));
 Ray.Origin:=v0;
 Ray.Direction:=v1-v0;
 Distance:=Ray.Direction.Length;
 Ray.Direction:=Ray.Direction/Distance;
 Intersection.Time:=Distance;
 if RayIntersection(Ray,Intersection,true,Exact,$ffffffff,$ffffffff,$ffffffff,Flags) then begin
  if Intersection.Time<Distance then begin
   result:=true;
  end;
 end;
end;

function TpvStaticTriangleBVH.IsOpenSpacePerEvenOddRule(const Position:TpvVector3;const Flags:TpvUInt32=$ffffffff):boolean;
const Directions:array[0..5] of TpvVector3=((x:-1.0;y:0.0;z:0.0),
                                            (x:1.0;y:0.0;z:0.0),
                                            (x:0.0;y:1.0;z:0.0),
                                            (x:0.0;y:-1.0;z:0.0),
                                            (x:0.0;y:0.0;z:1.0),
                                            (x:0.0;y:0.0;z:-1.0));
var DirectionIndex,Count:TpvInt32;
    Ray:TpvStaticTriangleBVHRay;
begin
 Count:=0;
 Ray.Origin:=Position;
 for DirectionIndex:=low(Directions) to high(Directions) do begin
  Ray.Direction:=Directions[DirectionIndex];
  inc(Count,CountRayIntersections(Ray,Flags));
 end;
 // When it's even = Outside any mesh, so we are in open space
 // When it's odd = Inside a mesh, so we are not in open space
 result:=(Count and 1)=0;
end;

function TpvStaticTriangleBVH.IsOpenSpacePerEvenOddRule(const Position:TpvVector3;var NearestNormal,NearestNormalPosition:TpvVector3;const Flags:TpvUInt32=$ffffffff):boolean;
const Directions:array[0..5] of TpvVector3=((x:-1.0;y:0.0;z:0.0),
                                            (x:1.0;y:0.0;z:0.0),
                                            (x:0.0;y:1.0;z:0.0),
                                            (x:0.0;y:-1.0;z:0.0),
                                            (x:0.0;y:0.0;z:1.0),
                                            (x:0.0;y:0.0;z:-1.0));
var DirectionIndex,Count:TpvInt32;
    Ray:TpvStaticTriangleBVHRay;
    Intersection:TpvStaticTriangleBVHIntersection;
    Direction:TpvVector3;
    Distance,BestDistance:TpvFloat;
begin
 Count:=0;
 Ray.Origin:=Position;
 for DirectionIndex:=low(Directions) to high(Directions) do begin
  Ray.Direction:=Directions[DirectionIndex];
  inc(Count,CountRayIntersections(Ray));
 end;
 // When it's even = Outside any mesh, so we are in open space
 // When it's odd = Inside a mesh, so we are not in open space
 result:=(Count and 1)=0;
 if result then begin
  Count:=0;
  BestDistance:=Infinity;
  for DirectionIndex:=low(Directions) to high(Directions) do begin
   Ray.Direction:=Directions[DirectionIndex];
   FillChar(Intersection,SizeOf(TpvStaticTriangleBVHIntersection),AnsiChar(#0));
   Intersection.Time:=Infinity;
   if ExactRayIntersection(Ray,Intersection,$ffffffff,$ffffffff,$ffffffff,Flags) then begin
    Direction:=Intersection.HitPoint-Position;
    Distance:=Direction.Length;
    Direction:=Direction/Distance;
    if Direction.Dot(Intersection.Normal)>0.0 then begin
     if (Count=0) or (BestDistance>Distance) then begin
      NearestNormal:=Intersection.Normal;
      NearestNormalPosition:=Intersection.HitPoint+(Intersection.Normal*1e-2);
      BestDistance:=Distance;
      inc(Count);
     end;
    end;
   end;
  end;
 end;
end;

function TpvStaticTriangleBVH.IsOpenSpacePerNormals(const Position:TpvVector3;const Flags:TpvUInt32=$ffffffff):boolean;
const Directions:array[0..5] of TpvVector3=((x:-1.0;y:0.0;z:0.0),
                                            (x:1.0;y:0.0;z:0.0),
                                            (x:0.0;y:1.0;z:0.0),
                                            (x:0.0;y:-1.0;z:0.0),
                                            (x:0.0;y:0.0;z:1.0),
                                            (x:0.0;y:0.0;z:-1.0));
var DirectionIndex:TpvInt32;
    Ray:TpvStaticTriangleBVHRay;
    Intersection:TpvStaticTriangleBVHIntersection;
begin
 result:=true;
 Ray.Origin:=Position;
 for DirectionIndex:=low(Directions) to high(Directions) do begin
  Ray.Direction:=Directions[DirectionIndex];
  FillChar(Intersection,SizeOf(TpvStaticTriangleBVHIntersection),AnsiChar(#0));
  Intersection.Time:=Infinity;
  if ExactRayIntersection(Ray,Intersection,$ffffffff,$ffffffff,$ffffffff,Flags) then begin
   if ((Intersection.HitPoint-Position).Normalize).Dot(Intersection.Normal)>0.0 then begin
    // Hit point normal is pointing away from us, so we are not in open space and inside a mesh
    result:=false;
    break;
   end;
  end;
 end;
end;

function TpvStaticTriangleBVH.IsOpenSpacePerNormals(const Position:TpvVector3;var NearestNormal,NearestNormalPosition:TpvVector3;const Flags:TpvUInt32=$ffffffff):boolean;
const Directions:array[0..5] of TpvVector3=((x:-1.0;y:0.0;z:0.0),
                                            (x:1.0;y:0.0;z:0.0),
                                            (x:0.0;y:1.0;z:0.0),
                                            (x:0.0;y:-1.0;z:0.0),
                                            (x:0.0;y:0.0;z:1.0),
                                            (x:0.0;y:0.0;z:-1.0));
var DirectionIndex:TpvInt32;
    Ray:TpvStaticTriangleBVHRay;
    Intersection:TpvStaticTriangleBVHIntersection;
    Direction:TpvVector3;
    Distance,BestDistance:TpvFloat;
begin
 result:=true;
 Ray.Origin:=Position;
 BestDistance:=Infinity;
 for DirectionIndex:=low(Directions) to high(Directions) do begin
  Ray.Direction:=Directions[DirectionIndex];
  FillChar(Intersection,SizeOf(TpvStaticTriangleBVHIntersection),AnsiChar(#0));
  Intersection.Time:=Infinity;
  if ExactRayIntersection(Ray,Intersection,$ffffffff,$ffffffff,$ffffffff,Flags) then begin
   Direction:=Intersection.HitPoint-Position;
   Distance:=Direction.Length;
   Direction:=Direction/Distance;;
   if Direction.Dot(Intersection.Normal)>0.0 then begin
    // Hit point normal is pointing away from us, so we are not in open space and inside a mesh
    if result or (BestDistance>Distance) then begin
     NearestNormal:=Intersection.Normal;
     NearestNormalPosition:=Intersection.HitPoint+(Intersection.Normal*1e-2);
     BestDistance:=Distance;
    end;
    result:=false;
   end;
  end;
 end;
end;

end.
