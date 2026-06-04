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
 *                  General guideTriangles for code contributors                  *
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
unit PasVulkan.BVH.Triangles;
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
     PasMP,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Collections;

type EpvTriangleBVH=class(Exception);

     { TpvTriangleBVHRay }
     TpvTriangleBVHRay=record
      public
       Origin:TpvVector3;
       Direction:TpvVector3;
       constructor Create(const aOrigin,aDirection:TpvVector3);
     end;
     PpvTriangleBVHRay=^TpvTriangleBVHRay;

     { TpvTriangleBVHTriangle }
     TpvTriangleBVHTriangle=packed record
      public
       Points:array[0..2] of TpvVector3;
       Normal:TpvVector3;
       Center:TpvVector3;
       Data:TpvPtrInt;
       Flags:TpvUInt32;
       function Area:TpvScalar;
       function RayIntersection(const aRayOrigin,aRayDirection:TpvVector3;out aTime,aU,aV,aW:TpvScalar):boolean; overload;
       function RayIntersection(const aRay:TpvTriangleBVHRay;out aTime,aU,aV,aW:TpvScalar):boolean; overload;
     end;
     PpvTriangleBVHTriangle=^TpvTriangleBVHTriangle;

     TpvTriangleBVHTriangles=array of TpvTriangleBVHTriangle;

     TpvTriangleBVHIntersection=packed record
      public
       Time:TpvScalar;
       Triangle:PpvTriangleBVHTriangle;
       IntersectionPoint:TpvVector3;
       Barycentrics:TpvVector3;
     end;
     PpvTriangleBVHIntersection=^TpvTriangleBVHIntersection;

     { TpvTriangleBVHTreeNode }
     TpvTriangleBVHTreeNode=packed record
      Bounds:TpvAABB;
      FirstLeftChild:TpvInt32;
      FirstTriangleIndex:TpvInt32;
      CountTriangles:TpvInt32;
     end;
     PpvTriangleBVHTreeNode=^TpvTriangleBVHTreeNode;

     TpvTriangleBVHTreeNodes=array of TpvTriangleBVHTreeNode;

     { TpvTriangleBVHSkipListNode }
     TpvTriangleBVHSkipListNode=packed record // must be GPU-friendly
      Min:TpvVector4;
      Max:TpvVector4;
      FirstTriangleIndex:TpvInt32;
      CountTriangles:TpvInt32;
      SkipCount:TpvInt32;
      Dummy:TpvInt32;
     end; // 48 bytes per Skip list item
     PpvTriangleBVHSkipListNode=^TpvTriangleBVHSkipListNode;

     TpvTriangleBVHSkipListNodes=array of TpvTriangleBVHSkipListNode;

     TpvTriangleBVHNodeQueue=TpvDynamicQueue<TpvInt32>;

     TpvTriangleBVHBuildMode=
      (
       MeanVariance,
       SAHBruteforce,
       SAHSteps,
       SAHBinned,
       SAHRandomInsert
      );

     { TpvTriangleBVH }

     TpvTriangleBVH=class
      private
       type TTreeNodeStack=TpvDynamicStack<TpvUInt64>;
            TSkipListNodeMap=array of TpvInt32;
      private
       fPasMPInstance:TPasMP;
       fBounds:TpvAABB;
       fTriangles:TpvTriangleBVHTriangles;
       fCountTriangles:TpvInt32;
       fTreeNodes:TpvTriangleBVHTreeNodes;
       fCountTreeNodes:TpvInt32;
       fTreeNodeRoot:TpvInt32;
       fSkipListNodeMap:TSkipListNodeMap;
       fSkipListNodes:TpvTriangleBVHSkipListNodes;
       fCountSkipListNodes:TpvInt32;
       fNodeQueue:TpvTriangleBVHNodeQueue;
       fNodeQueueLock:TPasMPSlimReaderWriterLock;
       fCountActiveWorkers:TPasMPInt32;
       fTreeNodeStack:TTreeNodeStack;
       fBVHBuildMode:TpvTriangleBVHBuildMode;
       fBVHSubdivisionSteps:TpvInt32;
       fBVHTraversalCost:TpvScalar;
       fBVHIntersectionCost:TpvScalar;
       fMaximumTrianglesPerNode:TpvInt32;
       fTriangleAreaSplitThreshold:TpvScalar;
       fParallel:Boolean;
       procedure SplitTooLargeTriangles;
       function EvaluateSAH(const aParentTreeNode:PpvTriangleBVHTreeNode;const aAxis:TpvInt32;const aSplitPosition:TpvFloat):TpvFloat;
       function FindBestSplitPlaneMeanVariance(const aParentTreeNode:PpvTriangleBVHTreeNode;out aAxis:TpvInt32;out aSplitPosition:TpvFloat):Boolean;
       function FindBestSplitPlaneSAHBruteforce(const aParentTreeNode:PpvTriangleBVHTreeNode;out aAxis:TpvInt32;out aSplitPosition:TpvFloat):TpvFloat;
       function FindBestSplitPlaneSAHSteps(const aParentTreeNode:PpvTriangleBVHTreeNode;out aAxis:TpvInt32;out aSplitPosition:TpvFloat):TpvFloat;
       function FindBestSplitPlaneSAHBinned(const aParentTreeNode:PpvTriangleBVHTreeNode;out aAxis:TpvInt32;out aSplitPosition:TpvFloat):TpvFloat;
       function CalculateNodeCost(const aParentTreeNode:PpvTriangleBVHTreeNode):TpvFloat;
       procedure UpdateNodeBounds(const aParentTreeNode:PpvTriangleBVHTreeNode);
       procedure ProcessNodeQueue;
       procedure BuildJob(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
      public
       constructor Create(const aPasMPInstance:TPasMP);
       destructor Destroy; override;
       procedure Clear;
       function AddTriangle(const aPoint0,aPoint1,aPoint2:TpvVector3;const aNormal:PpvVector3=nil;const aData:TpvPtrInt=0;const aFlags:TpvUInt32=TpvUInt32($ffffffff)):TpvInt32;
       procedure Build;
       procedure LoadFromStream(const aStream:TStream);
       procedure SaveToStream(const aStream:TStream);
       function RayIntersection(const aRay:TpvTriangleBVHRay;var aIntersection:TpvTriangleBVHIntersection;const aFastCheck:boolean=false;const aFlags:TpvUInt32=TpvUInt32($ffffffff);const aAvoidFlags:TpvUInt32=TpvUInt32(0)):boolean;
       function CountRayIntersections(const aRay:TpvTriangleBVHRay;const aFlags:TpvUInt32=TpvUInt32($ffffffff);const aAvoidFlags:TpvUInt32=TpvUInt32(0)):TpvInt32;
       function LineIntersection(const aV0,aV1:TpvVector3;const aFlags:TpvUInt32=TpvUInt32($ffffffff);const aAvoidFlags:TpvUInt32=TpvUInt32(0)):boolean;
       function IsOpenSpacePerEvenOddRule(const aPosition:TpvVector3;const aFlags:TpvUInt32=TpvUInt32($ffffffff);const aAvoidFlags:TpvUInt32=TpvUInt32(0)):boolean; overload;
       function IsOpenSpacePerEvenOddRule(const aPosition:TpvVector3;out aNearestNormal,aNearestNormalPosition:TpvVector3;const aFlags:TpvUInt32=TpvUInt32($ffffffff);const aAvoidFlags:TpvUInt32=TpvUInt32(0)):boolean; overload;
       function IsOpenSpacePerNormals(const aPosition:TpvVector3;const aFlags:TpvUInt32=TpvUInt32($ffffffff);const aAvoidFlags:TpvUInt32=TpvUInt32(0)):boolean; overload;
       function IsOpenSpacePerNormals(const aPosition:TpvVector3;out aNearestNormal,aNearestNormalPosition:TpvVector3;const aFlags:TpvUInt32=TpvUInt32($ffffffff);const aAvoidFlags:TpvUInt32=TpvUInt32(0)):boolean; overload;
      public
       property Triangles:TpvTriangleBVHTriangles read fTriangles;
       property CountTriangles:TpvInt32 read fCountTriangles;
       property TreeNodes:TpvTriangleBVHTreeNodes read fTreeNodes;
       property CountTreeNodes:TpvInt32 read fCountTreeNodes;
       property TreeNodeRoot:TpvInt32 read fTreeNodeRoot;
       property SkipListNodes:TpvTriangleBVHSkipListNodes read fSkipListNodes;
       property CountSkipListNodes:TpvInt32 read fCountSkipListNodes;
       property BVHBuildMode:TpvTriangleBVHBuildMode read fBVHBuildMode write fBVHBuildMode;
       property BVHSubdivisionSteps:TpvInt32 read fBVHSubdivisionSteps write fBVHSubdivisionSteps;
       property BVHTraversalCost:TpvScalar read fBVHTraversalCost write fBVHTraversalCost;
       property BVHIntersectionCost:TpvScalar read fBVHIntersectionCost write fBVHIntersectionCost;
       property MaximumTrianglesPerNode:TpvInt32 read fMaximumTrianglesPerNode write fMaximumTrianglesPerNode;
       property TriangleAreaSplitThreshold:TpvScalar read fTriangleAreaSplitThreshold write fTriangleAreaSplitThreshold;
       property Parallel:Boolean read fParallel write fParallel;
     end;

implementation

uses PasVulkan.BVH.DynamicAABBTree;

type TTriangleBVHFileSignature=array[0..7] of AnsiChar;

const TriangleBVHFileSignature:TTriangleBVHFileSignature=('T','B','V','H','F','i','l','e'); // Triangle BVH File

      TriangleBVHFileVersion=TpvUInt32($00000001);
      
{ TpvTriangleBVHRay }

constructor TpvTriangleBVHRay.Create(const aOrigin,aDirection:TpvVector3);
begin
 Origin:=aOrigin;
 Direction:=aDirection;
end;

{ TpvTriangleBVHTriangle }

function TpvTriangleBVHTriangle.Area:TpvScalar;
begin
 result:=((Points[1]-Points[0]).Cross(Points[2]-Points[0])).Length;
end;

function TpvTriangleBVHTriangle.RayIntersection(const aRayOrigin,aRayDirection:TpvVector3;out aTime,aU,aV,aW:TpvScalar):boolean;
const EPSILON=1e-7;
var v0v1,v0v2,p,t,q:TpvVector3;
    Determinant,InverseDeterminant:TpvScalar;
begin
 result:=false;
 v0v1:=Points[1]-Points[0];
 v0v2:=Points[2]-Points[0];
 p:=aRayDirection.Cross(v0v2);
 Determinant:=v0v1.Dot(p);
 if Determinant<EPSILON then begin
  exit;
 end;
 InverseDeterminant:=1.0/Determinant;
 t:=aRayOrigin-Points[0];
 aV:=t.Dot(p)*InverseDeterminant;
 if (aV<0.0) or (aV>1.0) then begin
  exit;
 end;
 q:=t.Cross(v0v1);
 aW:=aRayDirection.Dot(q)*InverseDeterminant;
 if (aW<0.0) or ((aV+aW)>1.0) then begin
  exit;
 end;
 aTime:=v0v2.Dot(q)*InverseDeterminant;
 aU:=1.0-(aV+aW);
 result:=true;
end;

function TpvTriangleBVHTriangle.RayIntersection(const aRay:TpvTriangleBVHRay;out aTime,aU,aV,aW:TpvScalar):boolean;
const EPSILON=1e-7;
var v0v1,v0v2,p,t,q:TpvVector3;
    Determinant,InverseDeterminant:TpvScalar;
begin
 result:=false;
 v0v1:=Points[1]-Points[0];
 v0v2:=Points[2]-Points[0];
 p:=aRay.Direction.Cross(v0v2);
 Determinant:=v0v1.Dot(p);
 if Determinant<EPSILON then begin
  exit;
 end;
 InverseDeterminant:=1.0/Determinant;
 t:=aRay.Origin-Points[0];
 aV:=t.Dot(p)*InverseDeterminant;
 if (aV<0.0) or (aV>1.0) then begin
  exit;
 end;
 q:=t.Cross(v0v1);
 aW:=aRay.Direction.Dot(q)*InverseDeterminant;
 if (aW<0.0) or ((aV+aW)>1.0) then begin
  exit;
 end;
 aTime:=v0v2.Dot(q)*InverseDeterminant;
 aU:=1.0-(aV+aW);
 result:=true;
end;

{ TpvTriangleBVH }

constructor TpvTriangleBVH.Create(const aPasMPInstance:TPasMP);
begin

 inherited Create;

 fPasMPInstance:=aPasMPInstance;

 fTriangles:=nil;
 fCountTriangles:=0;

 fTreeNodes:=nil;
 fCountTreeNodes:=0;
 fTreeNodeRoot:=-1;

 fSkipListNodes:=nil;
 fCountSkipListNodes:=0;

 fNodeQueue.Initialize;

 fNodeQueueLock:=TPasMPSlimReaderWriterLock.Create;

 fTreeNodeStack.Initialize;

 fSkipListNodeMap:=nil;

 fBVHBuildMode:=TpvTriangleBVHBuildMode.SAHSteps;

 fBVHSubdivisionSteps:=8;

 fBVHTraversalCost:=2.0;

 fBVHIntersectionCost:=1.0;

 fMaximumTrianglesPerNode:=4;

 fTriangleAreaSplitThreshold:=0.0;

 fParallel:=false;

end;

destructor TpvTriangleBVH.Destroy;
begin
 fTriangles:=nil;
 fTreeNodes:=nil;
 fSkipListNodes:=nil;
 fTreeNodeStack.Finalize;
 fNodeQueue.Finalize;
 FreeAndNil(fNodeQueueLock);
 fSkipListNodeMap:=nil;
 inherited Destroy;
end;

procedure TpvTriangleBVH.Clear;
begin

 fCountTriangles:=0;

 fCountTreeNodes:=0;
 fTreeNodeRoot:=-1;

 fCountSkipListNodes:=0;

end;

function TpvTriangleBVH.AddTriangle(const aPoint0,aPoint1,aPoint2:TpvVector3;const aNormal:PpvVector3;const aData:TpvPtrInt;const aFlags:TpvUInt32):TpvInt32;
var Triangle:PpvTriangleBVHTriangle;
begin
 result:=fCountTriangles;
 inc(fCountTriangles);
 if length(fTriangles)<=fCountTriangles then begin
  SetLength(fTriangles,fCountTriangles+((fCountTriangles+1) shr 1));
 end;
 Triangle:=@fTriangles[result];
 Triangle^.Points[0]:=aPoint0;
 Triangle^.Points[1]:=aPoint1;
 Triangle^.Points[2]:=aPoint2;
 if assigned(aNormal) then begin
  Triangle^.Normal:=aNormal^;
 end else begin
  Triangle^.Normal:=((Triangle^.Points[1]-Triangle^.Points[0]).Cross(Triangle^.Points[2]-Triangle^.Points[0])).Normalize;
 end;
 Triangle^.Center:=(aPoint0+aPoint1+aPoint2)/3.0;
 Triangle^.Data:=aData;
 Triangle^.Flags:=aFlags;
 if result=0 then begin
  fBounds.Min.x:=Min(Min(aPoint0.x,aPoint1.x),aPoint2.x);
  fBounds.Min.y:=Min(Min(aPoint0.y,aPoint1.y),aPoint2.y);
  fBounds.Min.z:=Min(Min(aPoint0.z,aPoint1.z),aPoint2.z);
  fBounds.Max.x:=Max(Max(aPoint0.x,aPoint1.x),aPoint2.x);
  fBounds.Max.y:=Max(Max(aPoint0.y,aPoint1.y),aPoint2.y);
  fBounds.Max.z:=Max(Max(aPoint0.z,aPoint1.z),aPoint2.z);
 end else begin
  fBounds.Min.x:=Min(fBounds.Min.x,Min(Min(aPoint0.x,aPoint1.x),aPoint2.x));
  fBounds.Min.y:=Min(fBounds.Min.y,Min(Min(aPoint0.y,aPoint1.y),aPoint2.y));
  fBounds.Min.z:=Min(fBounds.Min.z,Min(Min(aPoint0.z,aPoint1.z),aPoint2.z));
  fBounds.Max.x:=Max(fBounds.Max.x,Max(Max(aPoint0.x,aPoint1.x),aPoint2.x));
  fBounds.Max.y:=Max(fBounds.Max.y,Max(Max(aPoint0.y,aPoint1.y),aPoint2.y));
  fBounds.Max.z:=Max(fBounds.Max.z,Max(Max(aPoint0.z,aPoint1.z),aPoint2.z));
 end;
end;

procedure TpvTriangleBVH.SplitTooLargeTriangles;
type TTriangleQueue=TpvDynamicQueue<TpvInt32>;
var TriangleIndex:TpvInt32;
    Triangle:PpvTriangleBVHTriangle;
    TriangleQueue:TTriangleQueue;
    Vertices:array[0..2] of PpvVector3;
    NewVertices:array[0..2] of TpvVector3;
    Normal:TpvVector3;
    Data:TpvPtrInt;
    Flags:TpvUInt32;
begin
 if fTriangleAreaSplitThreshold>EPSILON then begin

  TriangleQueue.Initialize;
  try

   // Find seed too large triangles and enqueue them
   for TriangleIndex:=0 to fCountTriangles-1 do begin
    Triangle:=@fTriangles[TriangleIndex];
    if Triangle^.Area>fTriangleAreaSplitThreshold then begin
     TriangleQueue.Enqueue(TriangleIndex);
    end;
   end;

   // Split too large triangles into each four sub triangles until there are no more too large triangles

   //          p0
   //          /\
   //         /  \
   //        / t3 \
   //     m2/______\m0
   //      / \    / \
   //     / t2\t0/ t1\
   //  p2/_____\/_____\p1
   //          m1

   // t0: m0,m1,m2
   // t1: m0,p1,m1
   // t2: m2,m1,p2
   // t3: p0,m0,m2

   while TriangleQueue.Dequeue(TriangleIndex) do begin

    Triangle:=@fTriangles[TriangleIndex];

    Vertices[0]:=@Triangle^.Points[0]; // p0
    Vertices[1]:=@Triangle^.Points[1]; // p1
    Vertices[2]:=@Triangle^.Points[2]; // p2

    NewVertices[0]:=(Vertices[0]^+Vertices[1]^)*0.5; // m0
    NewVertices[1]:=(Vertices[1]^+Vertices[2]^)*0.5;  // m1
    NewVertices[2]:=(Vertices[2]^+Vertices[0]^)*0.5;  // m2

    // Create new four triangles, where the current triangle will overwritten by the first one

    // The first triangle: m0,m1,m2
    Triangle^.Points[0]:=NewVertices[0]; // m0
    Triangle^.Points[1]:=NewVertices[1]; // m1
    Triangle^.Points[2]:=NewVertices[2]; // m2
//  Triangle^.Normal:=((Triangle^.Points[1]-Triangle^.Points[0]).Cross(Triangle^.Points[2]-Triangle^.Points[0])).Normalize;
    Triangle^.Center:=(Triangle^.Points[0]+Triangle^.Points[1]+Triangle^.Points[2])/3.0;
    Normal:=Triangle^.Normal;
    Data:=Triangle^.Data;
    Flags:=Triangle^.Flags;
    if Triangle^.Area>fTriangleAreaSplitThreshold then begin
     TriangleQueue.Enqueue(TriangleIndex); // Enqueue the first triangle again, when it is still too large
    end;

    // The second triangle: m0,p1,m1
    TriangleIndex:=AddTriangle(NewVertices[0],
                               Vertices[1]^,
                               NewVertices[1],
                               @Normal,
                               Data,
                               Flags);
    Triangle:=@fTriangles[TriangleIndex];
    if Triangle^.Area>fTriangleAreaSplitThreshold then begin
     TriangleQueue.Enqueue(TriangleIndex); // Enqueue the second triangle again, when it is still too large
    end;

    // The third triangle: m2,m1,p2
    TriangleIndex:=AddTriangle(NewVertices[2],
                               NewVertices[1],
                               Vertices[2]^,
                               @Normal,
                               Data,
                               Flags);
    Triangle:=@fTriangles[TriangleIndex];
    if Triangle^.Area>fTriangleAreaSplitThreshold then begin
     TriangleQueue.Enqueue(TriangleIndex); // Enqueue the third triangle again, when it is still too large
    end;

    // The fourth triangle: p0,m0,m2
    TriangleIndex:=AddTriangle(Vertices[0]^,
                               NewVertices[0],
                               NewVertices[2],
                               @Normal,
                               Data,
                               Flags);
    Triangle:=@fTriangles[TriangleIndex];
    if Triangle^.Area>fTriangleAreaSplitThreshold then begin
     TriangleQueue.Enqueue(TriangleIndex); // Enqueue the fourth triangle again, when it is still too large
    end;

   end;

  finally
   TriangleQueue.Finalize;
  end;

 end;

end;

function TpvTriangleBVH.EvaluateSAH(const aParentTreeNode:PpvTriangleBVHTreeNode;const aAxis:TpvInt32;const aSplitPosition:TpvFloat):TpvFloat;
var LeftAABB,RightAABB:TpvAABB;
    LeftCount,RightCount,TriangleIndex:TpvInt32;
    Triangle:PpvTriangleBVHTriangle;
begin
 LeftCount:=0;
 RightCount:=0;
 for TriangleIndex:=aParentTreeNode^.FirstTriangleIndex to aParentTreeNode^.FirstTriangleIndex+(aParentTreeNode^.CountTriangles-1) do begin
  Triangle:=@fTriangles[TriangleIndex];
  if Triangle^.Center.xyz[aAxis]<aSplitPosition then begin
   if LeftCount=0 then begin
    LeftAABB.Min.x:=Min(Min(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x);
    LeftAABB.Min.y:=Min(Min(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y);
    LeftAABB.Min.z:=Min(Min(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z);
    LeftAABB.Max.x:=Max(Max(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x);
    LeftAABB.Max.y:=Max(Max(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y);
    LeftAABB.Max.z:=Max(Max(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z);
   end else begin
    LeftAABB.Min.x:=Min(LeftAABB.Min.x,Min(Min(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x));
    LeftAABB.Min.y:=Min(LeftAABB.Min.y,Min(Min(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y));
    LeftAABB.Min.z:=Min(LeftAABB.Min.z,Min(Min(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z));
    LeftAABB.Max.x:=Max(LeftAABB.Max.x,Max(Max(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x));
    LeftAABB.Max.y:=Max(LeftAABB.Max.y,Max(Max(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y));
    LeftAABB.Max.z:=Max(LeftAABB.Max.z,Max(Max(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z));
   end;
   inc(LeftCount);
  end else begin
   if RightCount=0 then begin
    RightAABB.Min.x:=Min(Min(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x);
    RightAABB.Min.y:=Min(Min(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y);
    RightAABB.Min.z:=Min(Min(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z);
    RightAABB.Max.x:=Max(Max(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x);
    RightAABB.Max.y:=Max(Max(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y);
    RightAABB.Max.z:=Max(Max(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z);
   end else begin
    RightAABB.Min.x:=Min(RightAABB.Min.x,Min(Min(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x));
    RightAABB.Min.y:=Min(RightAABB.Min.y,Min(Min(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y));
    RightAABB.Min.z:=Min(RightAABB.Min.z,Min(Min(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z));
    RightAABB.Max.x:=Max(RightAABB.Max.x,Max(Max(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x));
    RightAABB.Max.y:=Max(RightAABB.Max.y,Max(Max(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y));
    RightAABB.Max.z:=Max(RightAABB.Max.z,Max(Max(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z));
   end;
   inc(RightCount);
  end;
 end;
 result:=0.0;
 if LeftCount>0 then begin
  result:=result+(LeftCount*LeftAABB.Area);
 end;
 if RightCount>0 then begin
  result:=result+(RightCount*RightAABB.Area);
 end;
 if (result<=0.0) or IsZero(result) then begin
  result:=Infinity;
 end else begin
  result:=result*fBVHIntersectionCost;
 end;
end;

function TpvTriangleBVH.FindBestSplitPlaneMeanVariance(const aParentTreeNode:PpvTriangleBVHTreeNode;out aAxis:TpvInt32;out aSplitPosition:TpvFloat):Boolean;
var TriangleIndex:TpvInt32;
    Triangle:PpvTriangleBVHTriangle;
    MeanX,MeanY,MeanZ,VarianceX,VarianceY,VarianceZ:TpvDouble;
    Center:PpvVector3;
begin

 aAxis:=-1;
 aSplitPosition:=0.0;

 result:=false;

 if aParentTreeNode^.CountTriangles>0 then begin

  MeanX:=0.0;
  MeanY:=0.0;
  MeanZ:=0.0;
  for TriangleIndex:=aParentTreeNode^.FirstTriangleIndex to aParentTreeNode^.FirstTriangleIndex+(aParentTreeNode^.CountTriangles-1) do begin
   Triangle:=@fTriangles[TriangleIndex];
   Center:=@Triangle^.Center;
   MeanX:=MeanX+Center^.x;
   MeanY:=MeanY+Center^.y;
   MeanZ:=MeanZ+Center^.z;
  end;
  MeanX:=MeanX/aParentTreeNode^.CountTriangles;
  MeanY:=MeanY/aParentTreeNode^.CountTriangles;
  MeanZ:=MeanZ/aParentTreeNode^.CountTriangles;

  VarianceX:=0.0;
  VarianceY:=0.0;
  VarianceZ:=0.0;
  for TriangleIndex:=aParentTreeNode^.FirstTriangleIndex to aParentTreeNode^.FirstTriangleIndex+(aParentTreeNode^.CountTriangles-1) do begin
   Triangle:=@fTriangles[TriangleIndex];
   Center:=@Triangle^.Center;
   VarianceX:=VarianceX+sqr(Center^.x-MeanX);
   VarianceY:=VarianceY+sqr(Center^.y-MeanY);
   VarianceZ:=VarianceZ+sqr(Center^.z-MeanZ);
  end;
  VarianceX:=VarianceX/aParentTreeNode^.CountTriangles;
  VarianceY:=VarianceY/aParentTreeNode^.CountTriangles;
  VarianceZ:=VarianceZ/aParentTreeNode^.CountTriangles;

  if VarianceX<VarianceY then begin
   if VarianceY<VarianceZ then begin
    aAxis:=2;
    aSplitPosition:=MeanZ;
   end else begin
    aAxis:=1;
    aSplitPosition:=MeanY;
   end;
  end else begin
   if VarianceX<VarianceZ then begin
    aAxis:=2;
    aSplitPosition:=MeanZ;
   end else begin
    aAxis:=0;
    aSplitPosition:=MeanX;
   end;
  end;

  result:=true;

 end;

end;

function TpvTriangleBVH.FindBestSplitPlaneSAHBruteforce(const aParentTreeNode:PpvTriangleBVHTreeNode;out aAxis:TpvInt32;out aSplitPosition:TpvFloat):TpvFloat;
var AxisIndex,TriangleIndex:TpvInt32;
    Triangle:PpvTriangleBVHTriangle;
    Cost,SplitPosition:TpvFloat;
begin
 aAxis:=-1;
 aSplitPosition:=0.0;
 result:=Infinity;
 for AxisIndex:=0 to 2 do begin
  for TriangleIndex:=aParentTreeNode^.FirstTriangleIndex to aParentTreeNode^.FirstTriangleIndex+(aParentTreeNode^.CountTriangles-1) do begin
   Triangle:=@fTriangles[TriangleIndex];
   SplitPosition:=Triangle^.Center.xyz[AxisIndex];
   Cost:=EvaluateSAH(aParentTreeNode,AxisIndex,SplitPosition);
   if result>Cost then begin
    result:=Cost;
    aAxis:=AxisIndex;
    aSplitPosition:=SplitPosition;
   end;
  end;
 end;
end;

function TpvTriangleBVH.FindBestSplitPlaneSAHSteps(const aParentTreeNode:PpvTriangleBVHTreeNode;out aAxis:TpvInt32;out aSplitPosition:TpvFloat):TpvFloat;
var AxisIndex,StepIndex:TpvInt32;
    Cost,SplitPosition,Time:TpvFloat;
begin
 aAxis:=-1;
 aSplitPosition:=0.0;
 result:=Infinity;
 for AxisIndex:=0 to 2 do begin
  for StepIndex:=0 to fBVHSubdivisionSteps-1 do begin
   Time:=(StepIndex+1)/(fBVHSubdivisionSteps+1);
   SplitPosition:=(aParentTreeNode^.Bounds.Min.xyz[AxisIndex]*(1.0-Time))+
                  (aParentTreeNode^.Bounds.Max.xyz[AxisIndex]*Time);
   Cost:=EvaluateSAH(aParentTreeNode,AxisIndex,SplitPosition);
   if result>Cost then begin
    result:=Cost;
    aAxis:=AxisIndex;
    aSplitPosition:=SplitPosition;
   end;
  end;
 end;
end;

function TpvTriangleBVH.FindBestSplitPlaneSAHBinned(const aParentTreeNode:PpvTriangleBVHTreeNode;out aAxis:TpvInt32;out aSplitPosition:TpvFloat):TpvFloat;
const CountBINs=8;
type TBIN=record
      Count:Int32;
      Bounds:TpvAABB;
     end;
     PBIN=^TBIN;
     TBINs=array[0..CountBINs-1] of TBIN;
var AxisIndex,TriangleIndex,BINIndex,LeftSum,RightSum:TpvInt32;
    BoundsMin,BoundsMax,Scale,PlaneCost:TpvFloat;
    LeftArea,RightArea:array[0..CountBINs-1] of TpvFloat;
    LeftCount,RightCount:array[0..CountBINs-1] of TpvInt32;
    LeftBounds,RightBounds:TpvAABB;
    Triangle:PpvTriangleBVHTriangle;
    BINs:TBINs;
    BIN:PBIN;
begin

 result:=1e30;

 aAxis:=-1;

 if aParentTreeNode^.CountTriangles>0 then begin

  for AxisIndex:=0 to 2 do begin

   BoundsMin:=1e30;
   BoundsMax:=-1e30;

   for TriangleIndex:=aParentTreeNode^.FirstTriangleIndex to aParentTreeNode^.FirstTriangleIndex+(aParentTreeNode^.CountTriangles-1) do begin
    Triangle:=@fTriangles[TriangleIndex];
    BoundsMin:=Min(BoundsMin,Triangle^.Center[AxisIndex]);
    BoundsMax:=Max(BoundsMax,Triangle^.Center[AxisIndex]);
   end;

   if BoundsMin<>BoundsMax then begin

    Scale:=CountBINs/(BoundsMax-BoundsMin);

    FillChar(BINs,SizeOf(TBINs),#0);

    for TriangleIndex:=aParentTreeNode^.FirstTriangleIndex to aParentTreeNode^.FirstTriangleIndex+(aParentTreeNode^.CountTriangles-1) do begin
     Triangle:=@fTriangles[TriangleIndex];
     BINIndex:=Min(trunc((Triangle^.Center[AxisIndex]-BoundsMin)*Scale),CountBINs-1);
     BIN:=@BINs[BINIndex];
     if BIN^.Count=0 then begin
      BIN^.Bounds.Min.x:=Min(Min(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x);
      BIN^.Bounds.Min.y:=Min(Min(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y);
      BIN^.Bounds.Min.z:=Min(Min(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z);
      BIN^.Bounds.Max.x:=Max(Max(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x);
      BIN^.Bounds.Max.y:=Max(Max(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y);
      BIN^.Bounds.Max.z:=Max(Max(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z);
     end else begin
      BIN^.Bounds.Min.x:=Min(BIN^.Bounds.Min.x,Min(Min(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x));
      BIN^.Bounds.Min.y:=Min(BIN^.Bounds.Min.y,Min(Min(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y));
      BIN^.Bounds.Min.z:=Min(BIN^.Bounds.Min.z,Min(Min(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z));
      BIN^.Bounds.Max.x:=Max(BIN^.Bounds.Max.x,Max(Max(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x));
      BIN^.Bounds.Max.y:=Max(BIN^.Bounds.Max.y,Max(Max(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y));
      BIN^.Bounds.Max.z:=Max(BIN^.Bounds.Max.z,Max(Max(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z));
     end;
     inc(BIN^.Count);
    end;

    LeftSum:=0;
    RightSum:=0;
    for BINIndex:=0 to CountBINs-2 do begin

     BIN:=@BINs[BINIndex];
     inc(LeftSum,BIN^.Count);
     LeftCount[BINIndex]:=LeftSum;
     if BINIndex=0 then begin
      LeftBounds:=BIN^.Bounds;
     end else begin
      LeftBounds:=LeftBounds.Combine(BIN^.Bounds);
     end;
     LeftArea[BINIndex]:=LeftBounds.Area;

     BIN:=@BINs[CountBINs-(BINIndex+1)];
     inc(RightSum,BIN^.Count);
     RightCount[CountBINs-(BINIndex+2)]:=RightSum;
     if BINIndex=0 then begin
      RightBounds:=BIN^.Bounds;
     end else begin
      RightBounds:=RightBounds.Combine(BIN^.Bounds);
     end;
     RightArea[CountBINs-(BINIndex+2)]:=RightBounds.Area;

    end;

    Scale:=(BoundsMax-BoundsMin)/CountBINs;
    for BINIndex:=0 to CountBINs-2 do begin
     PlaneCost:=((LeftCount[BINIndex]*LeftArea[BINIndex])+
                 (RightCount[BINIndex]*RightArea[BINIndex]))*fBVHIntersectionCost;
     if PlaneCost<result then begin
      result:=PlaneCost;
      aAxis:=AxisIndex;
      aSplitPosition:=BoundsMin+((BINIndex+1)*Scale);
     end;
    end;

   end;

  end;

 end;

end;

function TpvTriangleBVH.CalculateNodeCost(const aParentTreeNode:PpvTriangleBVHTreeNode):TpvFloat;
begin
 result:=aParentTreeNode^.Bounds.Area*((aParentTreeNode^.CountTriangles*fBVHIntersectionCost)-fBVHTraversalCost);
end;

procedure TpvTriangleBVH.UpdateNodeBounds(const aParentTreeNode:PpvTriangleBVHTreeNode);
var TriangleIndex:TpvInt32;
    Triangle:PpvTriangleBVHTriangle;
begin
 if aParentTreeNode^.CountTriangles>0 then begin
  Triangle:=@fTriangles[aParentTreeNode^.FirstTriangleIndex];
  aParentTreeNode.Bounds.Min.x:=Min(Min(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x);
  aParentTreeNode.Bounds.Min.y:=Min(Min(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y);
  aParentTreeNode.Bounds.Min.z:=Min(Min(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z);
  aParentTreeNode.Bounds.Max.x:=Max(Max(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x);
  aParentTreeNode.Bounds.Max.y:=Max(Max(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y);
  aParentTreeNode.Bounds.Max.z:=Max(Max(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z);
  for TriangleIndex:=aParentTreeNode^.FirstTriangleIndex+1 to aParentTreeNode^.FirstTriangleIndex+(aParentTreeNode^.CountTriangles-1) do begin
   Triangle:=@fTriangles[TriangleIndex];
   aParentTreeNode.Bounds.Min.x:=Min(aParentTreeNode.Bounds.Min.x,Min(Min(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x));
   aParentTreeNode.Bounds.Min.y:=Min(aParentTreeNode.Bounds.Min.y,Min(Min(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y));
   aParentTreeNode.Bounds.Min.z:=Min(aParentTreeNode.Bounds.Min.z,Min(Min(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z));
   aParentTreeNode.Bounds.Max.x:=Max(aParentTreeNode.Bounds.Max.x,Max(Max(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x));
   aParentTreeNode.Bounds.Max.y:=Max(aParentTreeNode.Bounds.Max.y,Max(Max(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y));
   aParentTreeNode.Bounds.Max.z:=Max(aParentTreeNode.Bounds.Max.z,Max(Max(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z));
  end;
 end;
end;

procedure TpvTriangleBVH.ProcessNodeQueue;
var ParentTreeNodeIndex,AxisIndex,
    LeftIndex,RightIndex,
    LeftCount,
    LeftChildIndex,RightChildIndex:TpvInt32;
    SplitPosition,SplitCost:TpvFloat;
    ParentTreeNode,ChildTreeNode:PpvTriangleBVHTreeNode;
    TemporaryTriangle:TpvTriangleBVHTriangle;
    OK,Added:boolean;
begin
 while (fCountActiveWorkers<>0) or not fNodeQueue.IsEmpty do begin

  Added:=false;

  while true do begin

   fNodeQueueLock.Acquire;
   try
    OK:=fNodeQueue.Dequeue(ParentTreeNodeIndex);
   finally
    fNodeQueueLock.Release;
   end;
   if not OK then begin
    break;
   end;

   if not Added then begin
    TPasMPInterlocked.Increment(fCountActiveWorkers);
    Added:=true;
   end;

   ParentTreeNode:=@fTreeNodes[ParentTreeNodeIndex];
   if ParentTreeNode^.CountTriangles>fMaximumTrianglesPerNode then begin

    case fBVHBuildMode of
     TpvTriangleBVHBuildMode.MeanVariance:begin
      OK:=FindBestSplitPlaneMeanVariance(ParentTreeNode,AxisIndex,SplitPosition);
     end;
     else begin
      case fBVHBuildMode of
       TpvTriangleBVHBuildMode.SAHSteps:begin
        SplitCost:=FindBestSplitPlaneSAHSteps(ParentTreeNode,AxisIndex,SplitPosition);
       end;
       TpvTriangleBVHBuildMode.SAHBinned:begin
        SplitCost:=FindBestSplitPlaneSAHBinned(ParentTreeNode,AxisIndex,SplitPosition);
       end;
       else begin
        SplitCost:=FindBestSplitPlaneSAHBruteforce(ParentTreeNode,AxisIndex,SplitPosition);
       end;
      end;
      OK:=SplitCost<CalculateNodeCost(ParentTreeNode);
     end;
    end;

    if OK then begin

     LeftIndex:=ParentTreeNode^.FirstTriangleIndex;
     RightIndex:=ParentTreeNode^.FirstTriangleIndex+(ParentTreeNode^.CountTriangles-1);
     while LeftIndex<=RightIndex do begin
      if fTriangles[LeftIndex].Center[AxisIndex]<SplitPosition then begin
       inc(LeftIndex);
      end else begin
       TemporaryTriangle:=fTriangles[LeftIndex];
       fTriangles[LeftIndex]:=fTriangles[RightIndex];
       fTriangles[RightIndex]:=TemporaryTriangle;
       dec(RightIndex);
      end;
     end;

     LeftCount:=LeftIndex-ParentTreeNode^.FirstTriangleIndex;

     if (LeftCount<>0) and (LeftCount<>ParentTreeNode^.CountTriangles) then begin

      LeftChildIndex:=TPasMPInterlocked.Add(fCountTreeNodes,2);
      RightChildIndex:=LeftChildIndex+1;

      ParentTreeNode^.FirstLeftChild:=LeftChildIndex;

      ChildTreeNode:=@fTreeNodes[LeftChildIndex];
      ChildTreeNode^.FirstTriangleIndex:=ParentTreeNode^.FirstTriangleIndex;
      ChildTreeNode^.CountTriangles:=LeftCount;
      ChildTreeNode^.FirstLeftChild:=-1;
      UpdateNodeBounds(ChildTreeNode);
      fNodeQueueLock.Acquire;
      try
       fNodeQueue.Enqueue(RightChildIndex);
      finally
       fNodeQueueLock.Release;
      end;

      ChildTreeNode:=@fTreeNodes[RightChildIndex];
      ChildTreeNode^.FirstTriangleIndex:=LeftIndex;
      ChildTreeNode^.CountTriangles:=ParentTreeNode^.CountTriangles-LeftCount;
      ChildTreeNode^.FirstLeftChild:=-1;
      UpdateNodeBounds(ChildTreeNode);
      fNodeQueueLock.Acquire;
      try
       fNodeQueue.Enqueue(RightChildIndex);
      finally
       fNodeQueueLock.Release;
      end;

     end;

    end;

   end;

  end;

  if Added then begin
   TPasMPInterlocked.Decrement(fCountActiveWorkers);
  end;

 end;
end;

procedure TpvTriangleBVH.BuildJob(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
begin
 ProcessNodeQueue;
end;

procedure TpvTriangleBVH.Build;
type TDynamicAABBTreeNode=record
      AABB:TpvAABB;
      Parent:TpvSizeInt;
      Children:array[0..1] of TpvSizeInt;
      Triangles:array of TpvPtrUInt;
      CountChildTriangles:TpvSizeInt;
     end;
     PDynamicAABBTreeNode=^TDynamicAABBTreeNode;
     TDynamicAABBTreeNodes=array of TDynamicAABBTreeNode;
     TDynamicAABBTreeNodeStackItem=record
      DynamicAABBTreeNodeIndex:TpvSizeInt;
      case boolean of
       false:(
        NodeIndex:TpvSizeInt;
       );
       true:(
        Pass:TpvSizeInt;
       );
     end;
     TDynamicAABBTreeNodeStack=TpvDynamicStack<TDynamicAABBTreeNodeStackItem>;
var JobIndex,TreeNodeIndex,SkipListNodeIndex,Index,TargetIndex,TemporaryIndex,
    NextTargetIndex,TriangleIndex,CountNewTriangles:TPasMPInt32;
    TreeNode:PpvTriangleBVHTreeNode;
    Jobs:array of PPasMPJob;
    StackItem:TpvUInt64;
    SkipListNode:PpvTriangleBVHSkipListNode;
    DynamicAABBTree:TpvBVHDynamicAABBTree;
    DynamicAABBTreeOriginalNode:TpvBVHDynamicAABBTree.PTreeNode;
    DynamicAABBTreeNode,OtherDynamicAABBTreeNode:PDynamicAABBTreeNode;
    DynamicAABBTreeNodes:TDynamicAABBTreeNodes;
    DynamicAABBTreeNodeStack:TDynamicAABBTreeNodeStack;
    NewDynamicAABBTreeNodeStackItem:TDynamicAABBTreeNodeStackItem;
    CurrentDynamicAABBTreeNodeStackItem:TDynamicAABBTreeNodeStackItem;
    TriangleIndices:TpvInt32DynamicArray;
    Triangle:PpvTriangleBVHTriangle;
    TemporaryTriangle:TpvTriangleBVHTriangle;
    Seed:TpvUInt32;
    AABB:TpvAABB;
begin

 SplitTooLargeTriangles;

 if length(fTreeNodes)<=Max(1,length(fTriangles)) then begin
  SetLength(fTreeNodes,Max(1,length(fTriangles)*2));
 end;

 if fBVHBuildMode=TpvTriangleBVHBuildMode.SAHRandomInsert then begin

  if fCountTriangles>0 then begin

   DynamicAABBTree:=TpvBVHDynamicAABBTree.Create;
   try

    // Insert triangles in a random order for better tree balance of the dynamic AABB tree
    TriangleIndices:=nil;
    try
     SetLength(TriangleIndices,fCountTriangles);
     for Index:=0 to fCountTriangles-1 do begin
      TriangleIndices[Index]:=Index;
     end;
     Seed:=TpvUInt32($8b0634d1);
     for Index:=0 to fCountTriangles-1 do begin
      TargetIndex:=TpvUInt32(TpvUInt64(TpvUInt64(TpvUInt64(Seed)*fCountTriangles) shr 32));
      Seed:=Seed xor (Seed shl 13);
      Seed:=Seed xor (Seed shr 17);
      Seed:=Seed xor (Seed shl 5);
      TemporaryIndex:=TriangleIndices[Index];
      TriangleIndices[Index]:=TriangleIndices[TargetIndex];
      TriangleIndices[TargetIndex]:=TemporaryIndex;
     end;
     for Index:=0 to fCountTriangles-1 do begin
      TriangleIndex:=TriangleIndices[Index];
      Triangle:=@fTriangles[TriangleIndex];
      AABB.Min.x:=Min(Min(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x);
      AABB.Min.y:=Min(Min(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y);
      AABB.Min.z:=Min(Min(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z);
      AABB.Max.x:=Max(Max(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x);
      AABB.Max.y:=Max(Max(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y);
      AABB.Max.z:=Max(Max(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z);
      DynamicAABBTree.CreateProxy(AABB,TriangleIndex+1);
     end;
    finally
     TriangleIndices:=nil;
    end;

//  DynamicAABBTree.Rebalance(65536);

    DynamicAABBTreeNodes:=nil;
    try

     SetLength(DynamicAABBTreeNodes,DynamicAABBTree.NodeCount);

     for Index:=0 to DynamicAABBTree.NodeCount-1 do begin

      DynamicAABBTreeOriginalNode:=@DynamicAABBTree.Nodes[Index];
      DynamicAABBTreeNode:=@DynamicAABBTreeNodes[Index];

      DynamicAABBTreeNode^.AABB:=DynamicAABBTreeOriginalNode^.AABB;
      DynamicAABBTreeNode^.Parent:=DynamicAABBTreeOriginalNode^.Parent;
      DynamicAABBTreeNode^.Children[0]:=DynamicAABBTreeOriginalNode^.Children[0];
      DynamicAABBTreeNode^.Children[1]:=DynamicAABBTreeOriginalNode^.Children[1];
      if TpvPtrUInt(DynamicAABBTreeOriginalNode^.UserData)>0 then begin
       DynamicAABBTreeNode^.Triangles:=[TpvPtrUInt(DynamicAABBTreeOriginalNode^.UserData)-1];
      end else begin
       DynamicAABBTreeNode^.Triangles:=nil;
      end;
      DynamicAABBTreeNode^.CountChildTriangles:=0;

     end;

     DynamicAABBTreeNodeStack.Initialize;
     try

      // Counting child triangles
      begin
       NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=DynamicAABBTree.Root;
       NewDynamicAABBTreeNodeStackItem.Pass:=0;
       DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);
       while DynamicAABBTreeNodeStack.Pop(CurrentDynamicAABBTreeNodeStackItem) do begin
        DynamicAABBTreeNode:=@DynamicAABBTreeNodes[CurrentDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex];
        case CurrentDynamicAABBTreeNodeStackItem.Pass of
         0:begin
          if DynamicAABBTreeNode^.Parent>=0 then begin
           inc(DynamicAABBTreeNodes[DynamicAABBTreeNode^.Parent].CountChildTriangles,length(DynamicAABBTreeNode^.Triangles));
          end;
          NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=CurrentDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex;
          NewDynamicAABBTreeNodeStackItem.Pass:=1;
          DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);
          if DynamicAABBTreeNode^.Children[1]>=0 then begin
           NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=DynamicAABBTreeNode^.Children[1];
           NewDynamicAABBTreeNodeStackItem.Pass:=0;
           DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);
          end;
          if DynamicAABBTreeNode^.Children[0]>=0 then begin
           NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=DynamicAABBTreeNode^.Children[0];
           NewDynamicAABBTreeNodeStackItem.Pass:=0;
           DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);
          end;
         end;
         1:begin
          if DynamicAABBTreeNode^.Parent>=0 then begin
           inc(DynamicAABBTreeNodes[DynamicAABBTreeNode^.Parent].CountChildTriangles,DynamicAABBTreeNode^.CountChildTriangles);
          end;
         end;
        end;
       end;
      end;

      // Merge leafs
      begin
       NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=DynamicAABBTree.Root;
       NewDynamicAABBTreeNodeStackItem.Pass:=0;
       DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);
       while DynamicAABBTreeNodeStack.Pop(CurrentDynamicAABBTreeNodeStackItem) do begin
        DynamicAABBTreeNode:=@DynamicAABBTreeNodes[CurrentDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex];
        if DynamicAABBTreeNode^.CountChildTriangles<=fMaximumTrianglesPerNode then begin
         NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=CurrentDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex;
         NewDynamicAABBTreeNodeStackItem.Pass:=1;
         DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);
         if DynamicAABBTreeNode^.Children[1]>=0 then begin
          NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=DynamicAABBTreeNode^.Children[1];
          NewDynamicAABBTreeNodeStackItem.Pass:=2;
          DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);
         end;
         if DynamicAABBTreeNode^.Children[0]>=0 then begin
          NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=DynamicAABBTreeNode^.Children[0];
          NewDynamicAABBTreeNodeStackItem.Pass:=2;
          DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);
         end;
         DynamicAABBTreeNode^.Children[0]:=-1;
         DynamicAABBTreeNode^.Children[1]:=-1;
         DynamicAABBTreeNode^.CountChildTriangles:=0;
         while DynamicAABBTreeNodeStack.Pop(CurrentDynamicAABBTreeNodeStackItem) do begin
          case CurrentDynamicAABBTreeNodeStackItem.Pass of
           0:begin
            Assert(false);
           end;
           1:begin
            break;
           end;
           else {2:}begin
            OtherDynamicAABBTreeNode:=@DynamicAABBTreeNodes[CurrentDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex];
            if length(OtherDynamicAABBTreeNode^.Triangles)>0 then begin
             DynamicAABBTreeNode^.Triangles:=DynamicAABBTreeNode^.Triangles+OtherDynamicAABBTreeNode^.Triangles;
            end;
            if OtherDynamicAABBTreeNode^.Children[1]>=0 then begin
             NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=OtherDynamicAABBTreeNode^.Children[1];
             NewDynamicAABBTreeNodeStackItem.Pass:=2;
             DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);
            end;
            if OtherDynamicAABBTreeNode^.Children[0]>=0 then begin
             NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=OtherDynamicAABBTreeNode^.Children[0];
             NewDynamicAABBTreeNodeStackItem.Pass:=2;
             DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);
            end;
            OtherDynamicAABBTreeNode^.Parent:=-1;
            OtherDynamicAABBTreeNode^.Children[0]:=-1;
            OtherDynamicAABBTreeNode^.Children[0]:=-1;
            OtherDynamicAABBTreeNode^.CountChildTriangles:=0;
            OtherDynamicAABBTreeNode^.Triangles:=nil;
           end;
          end;
         end;
        end else begin
         if DynamicAABBTreeNode^.Children[1]>=0 then begin
          NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=DynamicAABBTreeNode^.Children[1];
          NewDynamicAABBTreeNodeStackItem.Pass:=0;
          DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);
         end;
         if DynamicAABBTreeNode^.Children[0]>=0 then begin
          NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=DynamicAABBTreeNode^.Children[0];
          NewDynamicAABBTreeNodeStackItem.Pass:=0;
          DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);
         end;
        end;
       end;
      end;

      // Convert to optimized tree node structure
      begin

       TriangleIndices:=nil;
       try

        SetLength(TriangleIndices,fCountTriangles);

        CountNewTriangles:=0;

        fCountTreeNodes:=0;
        fTreeNodeRoot:=0;

        SetLength(fTreeNodes,length(DynamicAABBTreeNodes));

        NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=DynamicAABBTree.Root;
        NewDynamicAABBTreeNodeStackItem.NodeIndex:=fCountTreeNodes;
        inc(fCountTreeNodes);

        DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);

        while DynamicAABBTreeNodeStack.Pop(CurrentDynamicAABBTreeNodeStackItem) do begin

         if CurrentDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex>=0 then begin
          DynamicAABBTreeNode:=@DynamicAABBTreeNodes[CurrentDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex];
         end else begin
          DynamicAABBTreeNode:=nil;
         end;

         TreeNode:=@fTreeNodes[CurrentDynamicAABBTreeNodeStackItem.NodeIndex];
         if assigned(DynamicAABBTreeNode) then begin

          TreeNode^.Bounds:=DynamicAABBTreeNode^.AABB;
          if (DynamicAABBTreeNode^.Children[0]>=0) or (DynamicAABBTreeNode^.Children[1]>=0) then begin

           TreeNode^.FirstLeftChild:=fCountTreeNodes;
           inc(fCountTreeNodes,2);

           if length(fTreeNodes)<fCountTreeNodes then begin
            SetLength(fTreeNodes,fCountTreeNodes+((fCountTreeNodes+1) shr 1));
           end;

           NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=DynamicAABBTreeNode^.Children[1];
           NewDynamicAABBTreeNodeStackItem.NodeIndex:=TreeNode^.FirstLeftChild+1;
           DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);

           NewDynamicAABBTreeNodeStackItem.DynamicAABBTreeNodeIndex:=DynamicAABBTreeNode^.Children[0];
           NewDynamicAABBTreeNodeStackItem.NodeIndex:=TreeNode^.FirstLeftChild;
           DynamicAABBTreeNodeStack.Push(NewDynamicAABBTreeNodeStackItem);

          end else begin

           TreeNode^.FirstLeftChild:=-1;

          end;

          TreeNode^.CountTriangles:=length(DynamicAABBTreeNode^.Triangles);
          if TreeNode^.CountTriangles>0 then begin

           TreeNode^.FirstTriangleIndex:=CountNewTriangles;

           for Index:=0 to length(DynamicAABBTreeNode^.Triangles)-1 do begin

            TriangleIndex:=DynamicAABBTreeNode^.Triangles[Index];

            TriangleIndices[TriangleIndex]:=CountNewTriangles;
            inc(CountNewTriangles);

            Triangle:=@fTriangles[TriangleIndex];

            AABB.Min.x:=Min(Min(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x);
            AABB.Min.y:=Min(Min(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y);
            AABB.Min.z:=Min(Min(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z);
            AABB.Max.x:=Max(Max(Triangle^.Points[0].x,Triangle^.Points[1].x),Triangle^.Points[2].x);
            AABB.Max.y:=Max(Max(Triangle^.Points[0].y,Triangle^.Points[1].y),Triangle^.Points[2].y);
            AABB.Max.z:=Max(Max(Triangle^.Points[0].z,Triangle^.Points[1].z),Triangle^.Points[2].z);

            if Index=0 then begin
             TreeNode^.Bounds:=AABB;
            end else begin
             TreeNode^.Bounds:=TreeNode^.Bounds.Combine(AABB);
            end;

           end;

          end else begin

           TreeNode^.FirstTriangleIndex:=-1;

          end;

         end else begin

          TreeNode^.Bounds.Min:=TpvVector3.InlineableCreate(1e30,1e30,1e30);
          TreeNode^.Bounds.Max:=TpvVector3.InlineableCreate(-1e30,-1e30,-1e30);
          TreeNode^.FirstTriangleIndex:=0;
          TreeNode^.CountTriangles:=0;
          TreeNode^.FirstLeftChild:=-1;

         end;

        end;

        if CountNewTriangles<fCountTriangles then begin
         for Index:=CountNewTriangles to fCountTriangles-1 do begin
          TriangleIndices[Index]:=CountNewTriangles;
          inc(CountNewTriangles);
         end;
        end;

        // In-place array reindexing
        begin
         for Index:=0 to fCountTriangles-1 do begin
          TargetIndex:=TriangleIndices[Index];
          while Index<>TargetIndex do begin
           TemporaryTriangle:=fTriangles[Index];
           fTriangles[Index]:=fTriangles[TargetIndex];
           fTriangles[TargetIndex]:=TemporaryTriangle;
           NextTargetIndex:=TriangleIndices[TargetIndex];
           TemporaryIndex:=TriangleIndices[Index];
           TriangleIndices[Index]:=NextTargetIndex;
           TriangleIndices[TargetIndex]:=TemporaryIndex;
           TargetIndex:=NextTargetIndex;
          end;
         end;
        end;

       finally
        TriangleIndices:=nil;
       end;

      end;

     finally
      DynamicAABBTreeNodeStack.Finalize;
     end;

    finally
     DynamicAABBTreeNodes:=nil;
    end;

   finally
    FreeAndNil(DynamicAABBTree);
   end;

  end else begin

   fCountTreeNodes:=1;
   fTreeNodeRoot:=0;
   TreeNode:=@fTreeNodes[fTreeNodeRoot];
   TreeNode^.Bounds:=fBounds;
   TreeNode^.FirstLeftChild:=-1;
   TreeNode^.FirstTriangleIndex:=-1;
   TreeNode^.CountTriangles:=0;

  end;

 end else begin

  fCountTreeNodes:=1;
  fTreeNodeRoot:=0;
  TreeNode:=@fTreeNodes[fTreeNodeRoot];
  TreeNode^.Bounds:=fBounds;
  TreeNode^.FirstLeftChild:=-1;
  if fCountTriangles>0 then begin
   TreeNode^.FirstTriangleIndex:=0;
   TreeNode^.CountTriangles:=fCountTriangles;
   if fCountTriangles>=MaximumTrianglesPerNode then begin
    fNodeQueue.Clear;
    fNodeQueue.Enqueue(0);
    fCountActiveWorkers:=0;
    if fParallel and assigned(fPasMPInstance) and (fPasMPInstance.CountJobWorkerThreads>0) then begin
     Jobs:=nil;
     try
      SetLength(Jobs,fPasMPInstance.CountJobWorkerThreads);
      for JobIndex:=0 to length(Jobs)-1 do begin
       Jobs[JobIndex]:=fPasMPInstance.Acquire(BuildJob,self,nil,0,0);
      end;
      fPasMPInstance.Invoke(Jobs);
     finally
      Jobs:=nil;
     end;
    end else begin
     ProcessNodeQueue;
    end;
   end;
  end else begin
   TreeNode^.FirstTriangleIndex:=-1;
   TreeNode^.CountTriangles:=0;
  end;

 end;

 if length(fSkipListNodeMap)<fCountTreeNodes then begin
  SetLength(fSkipListNodeMap,fCountTreeNodes);//+((fCountTreeNodes+1) shr 1));
 end;
 if length(fSkipListNodes)<fCountTreeNodes then begin
  SetLength(fSkipListNodes,fCountTreeNodes);
 end;
 fCountSkipListNodes:=0;
 fTreeNodeStack.Push((TpvUInt64(fTreeNodeRoot) shl 1) or 0);
 while fTreeNodeStack.Pop(StackItem) do begin
  TreeNodeIndex:=StackItem shr 1;
  TreeNode:=@fTreeNodes[TreeNodeIndex];
  case StackItem and 1 of
   0:begin
    SkipListNodeIndex:=fCountSkipListNodes;
    inc(fCountSkipListNodes);
    if length(fSkipListNodes)<=fCountSkipListNodes then begin
     SetLength(fSkipListNodes,fCountSkipListNodes+((fCountSkipListNodes+1) shr 1));
    end;
    SkipListNode:=@fSkipListNodes[SkipListNodeIndex];
    if length(fSkipListNodeMap)<=TreeNodeIndex then begin
     SetLength(fSkipListNodeMap,(TreeNodeIndex+1)+((TreeNodeIndex+2) shr 1));
    end;
    fSkipListNodeMap[TreeNodeIndex]:=SkipListNodeIndex;
    SkipListNode^.Min.xyz:=TreeNode^.Bounds.Min;
    SkipListNode^.Min.w:=0.0;
    SkipListNode^.Max.xyz:=TreeNode^.Bounds.Max;
    SkipListNode^.Max.w:=0.0;
    if TreeNode^.FirstLeftChild>=0 then begin
     // No leaf
     SkipListNode^.FirstTriangleIndex:=-1;
     SkipListNode^.CountTriangles:=0;
    end else begin
     // Leaf
     SkipListNode^.FirstTriangleIndex:=TreeNode^.FirstTriangleIndex;
     SkipListNode^.CountTriangles:=TreeNode^.CountTriangles;
    end;
    SkipListNode^.SkipCount:=0;
    SkipListNode^.Dummy:=0;
    fTreeNodeStack.Push((TpvUInt64(TreeNodeIndex) shl 1) or 1);
    if TreeNode^.FirstLeftChild>=0 then begin
     fTreeNodeStack.Push((TpvUInt64(TreeNode^.FirstLeftChild+1) shl 1) or 0);
     fTreeNodeStack.Push((TpvUInt64(TreeNode^.FirstLeftChild+0) shl 1) or 0);
    end;
   end;
   else {1:}begin
    SkipListNodeIndex:=fSkipListNodeMap[TreeNodeIndex];
    fSkipListNodes[SkipListNodeIndex].SkipCount:=fCountSkipListNodes-SkipListNodeIndex;
   end;
  end;
 end;

 if length(fSkipListNodes)<>fCountSkipListNodes then begin
  SetLength(fSkipListNodes,fCountSkipListNodes);
 end;

 fSkipListNodeMap:=nil;

end;

procedure TpvTriangleBVH.LoadFromStream(const aStream:TStream);
var Signature:TTriangleBVHFileSignature;
    Version:TpvUInt32;
    CountTriangles,CountTreeNodes,CountSkipListNodes:TpvUInt32;
   {TriangleIndex,TreeNodeIndex,SkipListNodeIndex:TpvSizeInt;
    Triangle:PpvTriangleBVHTriangle;
    TreeNode:PpvTriangleBVHTreeNode;
    SkipListNode:PpvTriangleBVHSkipListNode;}
begin

 aStream.ReadBuffer(Signature,SizeOf(TriangleBVHFileSignature));
 if Signature<>TriangleBVHFileSignature then begin
  raise EpvTriangleBVH.Create('Invalid signature');
 end;

 aStream.ReadBuffer(Version,SizeOf(TpvUInt32));
 if Version<>TriangleBVHFileVersion then begin
  raise EpvTriangleBVH.Create('Invalid version');
 end;

 aStream.ReadBuffer(CountTriangles,SizeOf(TpvUInt32));

 aStream.ReadBuffer(CountTreeNodes,SizeOf(TpvUInt32));

 aStream.ReadBuffer(CountSkipListNodes,SizeOf(TpvUInt32));

 Clear;

 SetLength(fTriangles,CountTriangles);

 SetLength(fTreeNodes,CountTreeNodes);

 SetLength(fSkipListNodes,CountSkipListNodes);

{$if true}

 if CountTriangles>0 then begin
  aStream.ReadBuffer(fTriangles[0],CountTriangles*SizeOf(TpvTriangleBVHTriangle));
 end;

 if CountTreeNodes>0 then begin
  aStream.ReadBuffer(fTreeNodes[0],CountTreeNodes*SizeOf(TpvTriangleBVHTreeNode));
 end;

 if CountSkipListNodes>0 then begin
  aStream.ReadBuffer(fSkipListNodes[0],CountSkipListNodes*SizeOf(TpvTriangleBVHSkipListNode));
 end;

{$else}
 for TriangleIndex:=0 to CountTriangles-1 do begin
  Triangle:=@fTriangles[TriangleIndex];
  aStream.ReadBuffer(Triangle^.Points[0],SizeOf(TpvVector3));
  aStream.ReadBuffer(Triangle^.Points[1],SizeOf(TpvVector3));
  aStream.ReadBuffer(Triangle^.Points[2],SizeOf(TpvVector3));
  aStream.ReadBuffer(Triangle^.Normal,SizeOf(TpvVector3));
  aStream.ReadBuffer(Triangle^.Center,SizeOf(TpvVector3));
  aStream.ReadBuffer(Triangle^.Data,SizeOf(TpvPtrInt));
  aStream.ReadBuffer(Triangle^.Flags,SizeOf(TpvUInt32));
 end;

 for TreeNodeIndex:=0 to CountTreeNodes-1 do begin
  TreeNode:=@fTreeNodes[TreeNodeIndex];
  aStream.ReadBuffer(TreeNode^.Bounds,SizeOf(TpvAABB));
  aStream.ReadBuffer(TreeNode^.FirstLeftChild,SizeOf(TpvInt32));
  aStream.ReadBuffer(TreeNode^.FirstTriangleIndex,SizeOf(TpvInt32));
  aStream.ReadBuffer(TreeNode^.CountTriangles,SizeOf(TpvInt32));
 end;

 for SkipListNodeIndex:=0 to CountSkipListNodes-1 do begin
  SkipListNode:=@fSkipListNodes[SkipListNodeIndex];
  aStream.ReadBuffer(SkipListNode^.Min,SizeOf(TpvVector4));
  aStream.ReadBuffer(SkipListNode^.Max,SizeOf(TpvVector4));
  aStream.ReadBuffer(SkipListNode^.FirstTriangleIndex,SizeOf(TpvInt32));
  aStream.ReadBuffer(SkipListNode^.CountTriangles,SizeOf(TpvInt32));
  aStream.ReadBuffer(SkipListNode^.SkipCount,SizeOf(TpvInt32));
  aStream.ReadBuffer(SkipListNode^.Dummy,SizeOf(TpvInt32));
 end;
{$ifend} 

end;

procedure TpvTriangleBVH.SaveToStream(const aStream:TStream);
var Signature:TTriangleBVHFileSignature;
    Version:TpvUInt32;
    CountTriangles,CountTreeNodes,CountSkipListNodes:TpvUInt32;
   {TriangleIndex,TreeNodeIndex,SkipListNodeIndex:TpvSizeInt;
    Triangle:PpvTriangleBVHTriangle;
    TreeNode:PpvTriangleBVHTreeNode;
    SkipListNode:PpvTriangleBVHSkipListNode;}
begin
 
 Signature:=TriangleBVHFileSignature;
 aStream.WriteBuffer(Signature,SizeOf(TriangleBVHFileSignature));

 Version:=TriangleBVHFileVersion;
 aStream.WriteBuffer(Version,SizeOf(TpvUInt32));

 CountTriangles:=fCountTriangles;
 aStream.WriteBuffer(CountTriangles,SizeOf(TpvUInt32));

 CountTreeNodes:=fCountTreeNodes;
 aStream.WriteBuffer(CountTreeNodes,SizeOf(TpvUInt32));

 CountSkipListNodes:=fCountSkipListNodes;
 aStream.WriteBuffer(CountSkipListNodes,SizeOf(TpvUInt32));

{$if true}

 if fCountTriangles>0 then begin
  aStream.WriteBuffer(fTriangles[0],fCountTriangles*SizeOf(TpvTriangleBVHTriangle));
 end; 

 if fCountTreeNodes>0 then begin
  aStream.WriteBuffer(fTreeNodes[0],fCountTreeNodes*SizeOf(TpvTriangleBVHTreeNode));
 end; 

 if fCountSkipListNodes>0 then begin 
  aStream.WriteBuffer(fSkipListNodes[0],fCountSkipListNodes*SizeOf(TpvTriangleBVHSkipListNode));
 end; 

{$else}
 for TriangleIndex:=0 to fCountTriangles-1 do begin
  Triangle:=@fTriangles[TriangleIndex];
  aStream.WriteBuffer(Triangle^.Points[0],SizeOf(TpvVector3));
  aStream.WriteBuffer(Triangle^.Points[1],SizeOf(TpvVector3));
  aStream.WriteBuffer(Triangle^.Points[2],SizeOf(TpvVector3));
  aStream.WriteBuffer(Triangle^.Normal,SizeOf(TpvVector3));
  aStream.WriteBuffer(Triangle^.Center,SizeOf(TpvVector3));
  aStream.WriteBuffer(Triangle^.Data,SizeOf(TpvPtrInt));
  aStream.WriteBuffer(Triangle^.Flags,SizeOf(TpvUInt32));
 end;

 for TreeNodeIndex:=0 to fCountTreeNodes-1 do begin
  TreeNode:=@fTreeNodes[TreeNodeIndex];
  aStream.WriteBuffer(TreeNode^.Bounds,SizeOf(TpvAABB));
  aStream.WriteBuffer(TreeNode^.FirstLeftChild,SizeOf(TpvInt32));
  aStream.WriteBuffer(TreeNode^.FirstTriangleIndex,SizeOf(TpvInt32));
  aStream.WriteBuffer(TreeNode^.CountTriangles,SizeOf(TpvInt32));
 end;

 for SkipListNodeIndex:=0 to fCountSkipListNodes-1 do begin
  SkipListNode:=@fSkipListNodes[SkipListNodeIndex];
  aStream.WriteBuffer(SkipListNode^.Min,SizeOf(TpvVector4));
  aStream.WriteBuffer(SkipListNode^.Max,SizeOf(TpvVector4));
  aStream.WriteBuffer(SkipListNode^.FirstTriangleIndex,SizeOf(TpvInt32));
  aStream.WriteBuffer(SkipListNode^.CountTriangles,SizeOf(TpvInt32));
  aStream.WriteBuffer(SkipListNode^.SkipCount,SizeOf(TpvInt32));
  aStream.WriteBuffer(SkipListNode^.Dummy,SizeOf(TpvInt32));
 end;
{$ifend} 

end;

function TpvTriangleBVH.RayIntersection(const aRay:TpvTriangleBVHRay;var aIntersection:TpvTriangleBVHIntersection;const aFastCheck:boolean;const aFlags:TpvUInt32;const aAvoidFlags:TpvUInt32):boolean;
var SkipListNodeIndex,CountSkipListNodes,TriangleIndex:TpvInt32;
    SkipListNode:PpvTriangleBVHSkipListNode;
    Triangle:PpvTriangleBVHTriangle;
    Time,u,v,w:TpvScalar;
    OK:boolean;
begin
 result:=false;
 SkipListNodeIndex:=0;
 CountSkipListNodes:=fCountSkipListNodes;
 while SkipListNodeIndex<CountSkipListNodes do begin
  SkipListNode:=@fSkipListNodes[SkipListNodeIndex];
  if TpvAABB.FastRayIntersection(SkipListNode^.Min.Vector3,SkipListNode^.Max.Vector3,aRay.Origin,aRay.Direction) then begin
   for TriangleIndex:=SkipListNode^.FirstTriangleIndex to (SkipListNode^.FirstTriangleIndex+SkipListNode^.CountTriangles)-1 do begin
    Triangle:=@fTriangles[TriangleIndex];
    if ((Triangle^.Flags and aFlags)<>0) and ((Triangle^.Flags and aAvoidFlags)=0) then begin
     OK:=Triangle^.RayIntersection(aRay,Time,u,v,w);
     if OK then begin
      if (Time>=0.0) and (IsInfinite(aIntersection.Time) or (Time<aIntersection.Time)) then begin
       result:=true;
       aIntersection.Time:=Time;
       aIntersection.Triangle:=Triangle;
       aIntersection.IntersectionPoint:=aRay.Origin+(aRay.Direction*Time);
       aIntersection.Barycentrics:=TpvVector3.InlineableCreate(u,v,w);
       if aFastCheck then begin
        exit;
       end;
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

function TpvTriangleBVH.CountRayIntersections(const aRay:TpvTriangleBVHRay;const aFlags:TpvUInt32;const aAvoidFlags:TpvUInt32):TpvInt32;
var SkipListNodeIndex,CountSkipListNodes,TriangleIndex:TpvInt32;
    SkipListNode:PpvTriangleBVHSkipListNode;
    Triangle:PpvTriangleBVHTriangle;
    Time,u,v,w:TpvScalar;
begin
 result:=0;
 SkipListNodeIndex:=0;
 CountSkipListNodes:=fCountSkipListNodes;
 while SkipListNodeIndex<CountSkipListNodes do begin
  SkipListNode:=@fSkipListNodes[SkipListNodeIndex];
  if TpvAABB.FastRayIntersection(SkipListNode^.Min.Vector3,SkipListNode^.Max.Vector3,aRay.Origin,aRay.Direction) then begin
   for TriangleIndex:=SkipListNode^.FirstTriangleIndex to (SkipListNode^.FirstTriangleIndex+SkipListNode^.CountTriangles)-1 do begin
    Triangle:=@fTriangles[TriangleIndex];
    if ((Triangle^.Flags and aFlags)<>0) and ((Triangle^.Flags and aAvoidFlags)=0) then begin
     if Triangle^.RayIntersection(aRay,Time,u,v,w) then begin
      inc(result);
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

function TpvTriangleBVH.LineIntersection(const aV0,aV1:TpvVector3;const aFlags:TpvUInt32;const aAvoidFlags:TpvUInt32):boolean;
var Ray:TpvTriangleBVHRay;
    Intersection:TpvTriangleBVHIntersection;
    Distance:TpvFloat;
begin
 result:=false;
 FillChar(Intersection,SizeOf(TpvTriangleBVHIntersection),AnsiChar(#0));
 Ray.Origin:=aV0;
 Ray.Direction:=aV1-aV0;
 Distance:=Ray.Direction.Length;
 Ray.Direction:=Ray.Direction/Distance;
 Intersection.Time:=Distance;
 if RayIntersection(Ray,Intersection,true,aFlags,aAvoidFlags) then begin
  if Intersection.Time<Distance then begin
   result:=true;
  end;
 end;
end;

function TpvTriangleBVH.IsOpenSpacePerEvenOddRule(const aPosition:TpvVector3;const aFlags:TpvUInt32;const aAvoidFlags:TpvUInt32):boolean;
const Directions:array[0..5] of TpvVector3=((x:-1.0;y:0.0;z:0.0),
                                            (x:1.0;y:0.0;z:0.0),
                                            (x:0.0;y:1.0;z:0.0),
                                            (x:0.0;y:-1.0;z:0.0),
                                            (x:0.0;y:0.0;z:1.0),
                                            (x:0.0;y:0.0;z:-1.0));
var DirectionIndex,Count:TpvInt32;
    Ray:TpvTriangleBVHRay;
begin
 Count:=0;
 Ray.Origin:=aPosition;
 for DirectionIndex:=low(Directions) to high(Directions) do begin
  Ray.Direction:=Directions[DirectionIndex];
  inc(Count,CountRayIntersections(Ray,aFlags,aAvoidFlags));
 end;
 // When it's even = Outside any mesh, so we are in open space
 // When it's odd = Inside a mesh, so we are not in open space
 result:=(Count and 1)=0;
end;

function TpvTriangleBVH.IsOpenSpacePerEvenOddRule(const aPosition:TpvVector3;out aNearestNormal,aNearestNormalPosition:TpvVector3;const aFlags:TpvUInt32;const aAvoidFlags:TpvUInt32):boolean;
const Directions:array[0..5] of TpvVector3=((x:-1.0;y:0.0;z:0.0),
                                            (x:1.0;y:0.0;z:0.0),
                                            (x:0.0;y:1.0;z:0.0),
                                            (x:0.0;y:-1.0;z:0.0),
                                            (x:0.0;y:0.0;z:1.0),
                                            (x:0.0;y:0.0;z:-1.0));
var DirectionIndex,Count:TpvInt32;
    Ray:TpvTriangleBVHRay;
    Intersection:TpvTriangleBVHIntersection;
    Direction:TpvVector3;
    Distance,BestDistance:TpvFloat;
begin
 Count:=0;
 Ray.Origin:=aPosition;
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
   FillChar(Intersection,SizeOf(TpvTriangleBVHIntersection),AnsiChar(#0));
   Intersection.Time:=Infinity;
   if RayIntersection(Ray,Intersection,false,aFlags,aAvoidFlags) then begin
    Direction:=Intersection.IntersectionPoint-aPosition;
    Distance:=Direction.Length;
    Direction:=Direction/Distance;
    if Direction.Dot(Intersection.Triangle^.Normal)>0.0 then begin
     if (Count=0) or (BestDistance>Distance) then begin
      aNearestNormal:=Intersection.Triangle^.Normal;
      aNearestNormalPosition:=Intersection.IntersectionPoint+(Intersection.Triangle^.Normal*1e-2);
      BestDistance:=Distance;
      inc(Count);
     end;
    end;
   end;
  end;
 end;
end;

function TpvTriangleBVH.IsOpenSpacePerNormals(const aPosition:TpvVector3;const aFlags:TpvUInt32;const aAvoidFlags:TpvUInt32):boolean;
const Directions:array[0..5] of TpvVector3=((x:-1.0;y:0.0;z:0.0),
                                            (x:1.0;y:0.0;z:0.0),
                                            (x:0.0;y:1.0;z:0.0),
                                            (x:0.0;y:-1.0;z:0.0),
                                            (x:0.0;y:0.0;z:1.0),
                                            (x:0.0;y:0.0;z:-1.0));
var DirectionIndex:TpvInt32;
    Ray:TpvTriangleBVHRay;
    Intersection:TpvTriangleBVHIntersection;
begin
 result:=true;
 Ray.Origin:=aPosition;
 for DirectionIndex:=low(Directions) to high(Directions) do begin
  Ray.Direction:=Directions[DirectionIndex];
  FillChar(Intersection,SizeOf(TpvTriangleBVHIntersection),AnsiChar(#0));
  Intersection.Time:=Infinity;
  if RayIntersection(Ray,Intersection,false,aFlags,aAvoidFlags) then begin
   if ((Intersection.IntersectionPoint-aPosition).Normalize).Dot(Intersection.Triangle^.Normal)>0.0 then begin
    // Hit point normal is pointing away from us, so we are not in open space and inside a mesh
    result:=false;
    break;
   end;
  end;
 end;
end;

function TpvTriangleBVH.IsOpenSpacePerNormals(const aPosition:TpvVector3;out aNearestNormal,aNearestNormalPosition:TpvVector3;const aFlags:TpvUInt32;const aAvoidFlags:TpvUInt32):boolean;
const Directions:array[0..5] of TpvVector3=((x:-1.0;y:0.0;z:0.0),
                                            (x:1.0;y:0.0;z:0.0),
                                            (x:0.0;y:1.0;z:0.0),
                                            (x:0.0;y:-1.0;z:0.0),
                                            (x:0.0;y:0.0;z:1.0),
                                            (x:0.0;y:0.0;z:-1.0));
var DirectionIndex:TpvInt32;
    Ray:TpvTriangleBVHRay;
    Intersection:TpvTriangleBVHIntersection;
    Direction:TpvVector3;
    Distance,BestDistance:TpvFloat;
begin
 result:=true;
 Ray.Origin:=aPosition;
 BestDistance:=Infinity;
 for DirectionIndex:=low(Directions) to high(Directions) do begin
  Ray.Direction:=Directions[DirectionIndex];
  FillChar(Intersection,SizeOf(TpvTriangleBVHIntersection),AnsiChar(#0));
  Intersection.Time:=Infinity;
  if RayIntersection(Ray,Intersection,false,aFlags,aAvoidFlags) then begin
   Direction:=Intersection.IntersectionPoint-aPosition;
   Distance:=Direction.Length;
   Direction:=Direction/Distance;;
   if Direction.Dot(Intersection.Triangle^.Normal)>0.0 then begin
    // Hit point normal is pointing away from us, so we are not in open space and inside a mesh
    if result or (BestDistance>Distance) then begin
     aNearestNormal:=Intersection.Triangle^.Normal;
     aNearestNormalPosition:=Intersection.IntersectionPoint+(Intersection.Triangle^.Normal*1e-2);
     BestDistance:=Distance;
    end;
    result:=false;
   end;
  end;
 end;
end;

end.
