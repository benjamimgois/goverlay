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
unit PasVulkan.VectorPath;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}

{$define CANINLINE}

interface

uses SysUtils,
     Classes,
     Math,
     Generics.Collections,
     Vulkan,
     PasDblStrUtils,
     PasMP,
     PasVulkan.Types,
     PasVulkan.Utils,
     PasVulkan.Collections,
     PasVulkan.Math;

type PpvVectorPathCommandType=^TpvVectorPathCommandType;
     TpvVectorPathCommandType=
      (
       MoveTo,
       LineTo,
       QuadraticCurveTo,
       CubicCurveTo,
       Close
      );

     { TpvVectorPathVector }

     TpvVectorPathVector=record
      public
       constructor Create(const aValue:TpvDouble); overload;
       constructor Create(const aX,aY:TpvDouble); overload;
       function Length:TpvDouble; {$ifdef CANINLINE}inline;{$endif}
       function LengthSquared:TpvDouble; {$ifdef CANINLINE}inline;{$endif}
       function Distance(const b:TpvVectorPathVector):TpvDouble; {$ifdef CANINLINE}inline;{$endif}
       function DistanceSquared(const b:TpvVectorPathVector):TpvDouble; {$ifdef CANINLINE}inline;{$endif}
       function Direction:TpvDouble; {$ifdef CANINLINE}inline;{$endif}
       function Normalize:TpvVectorPathVector; {$ifdef CANINLINE}inline;{$endif}
       function Minimum(const aRight:TpvVectorPathVector):TpvVectorPathVector;
       function Maximum(const aRight:TpvVectorPathVector):TpvVectorPathVector;
       function Dot(const aRight:TpvVectorPathVector):TpvDouble; {$ifdef CANINLINE}inline;{$endif}
       function Cross(const aRight:TpvVectorPathVector):TpvDouble; {$ifdef CANINLINE}inline;{$endif}
       function OrthoNormal:TpvVectorPathVector; {$ifdef CANINLINE}inline;{$endif}
       function Lerp(const b:TpvVectorPathVector;const t:TpvDouble):TpvVectorPathVector;
       function ClampedLerp(const b:TpvVectorPathVector;const t:TpvDouble):TpvVectorPathVector;
       class function IsLeft(const a,b,c:TpvVectorPathVector):TpvDouble; static;
       class operator Equal(const a,b:TpvVectorPathVector):boolean; {$ifdef CANINLINE}inline;{$endif}
       class operator NotEqual(const a,b:TpvVectorPathVector):boolean; {$ifdef CANINLINE}inline;{$endif}
       class operator Add(const a,b:TpvVectorPathVector):TpvVectorPathVector; {$ifdef CANINLINE}inline;{$endif}
       class operator Subtract(const a,b:TpvVectorPathVector):TpvVectorPathVector; {$ifdef CANINLINE}inline;{$endif}
       class operator Multiply(const a,b:TpvVectorPathVector):TpvVectorPathVector; overload; {$ifdef CANINLINE}inline;{$endif}
       class operator Multiply(const a:TpvVectorPathVector;const b:TpvDouble):TpvVectorPathVector; overload; {$ifdef CANINLINE}inline;{$endif}
       class operator Multiply(const a:TpvDouble;const b:TpvVectorPathVector):TpvVectorPathVector; overload; {$ifdef CANINLINE}inline;{$endif}
       class operator Divide(const a,b:TpvVectorPathVector):TpvVectorPathVector; overload; {$ifdef CANINLINE}inline;{$endif}
       class operator Divide(const a:TpvVectorPathVector;const b:TpvDouble):TpvVectorPathVector; overload; {$ifdef CANINLINE}inline;{$endif}
       class operator Negative(const a:TpvVectorPathVector):TpvVectorPathVector; {$ifdef CANINLINE}inline;{$endif}
       class operator Positive(const a:TpvVectorPathVector):TpvVectorPathVector; {$ifdef CANINLINE}inline;{$endif}
      public
       case boolean of
        false:(
         x:TpvDouble;
         y:TpvDouble;
        );
        true:(
         xy:array[0..1] of TpvDouble;
        );
     end;

     PpvVectorPathVector=^TpvVectorPathVector;

     TpvVectorPathVectors=array of TpvVectorPathVector;

     { TpvVectorPathVectorList }

     TpvVectorPathVectorList=class(TpvGenericList<TpvVectorPathVector>)
      public
       procedure Sort; reintroduce;
       procedure RemoveDuplicates;
     end;

     TpvVectorPathRawVectors=array[0..65535] of TpvVectorPathVector;

     PpvVectorPathRawVectors=^TpvVectorPathRawVectors;

     { TpvVectorPathBoundingBox }

     TpvVectorPathBoundingBox=record
      public
       const EPSILON=1e-14;
      public
       constructor Create(const aMin,aMax:TpvVectorPathVector);
       procedure Extend(const aVector:TpvVectorPathVector);
       function Combine(const aWith:TpvVectorPathBoundingBox):TpvVectorPathBoundingBox;
       function Cost:TpvDouble;
       function Volume:TpvDouble;
       function Area:TpvDouble;
       function Center:TpvVectorPathVector;
       function Contains(const aVector:TpvVectorPathVector):Boolean; overload;
       class function Contains(const aMin,aMax:TpvVectorPathVector;const aWith:TpvVectorPathBoundingBox):Boolean; overload; static;
       class function Contains(const aMin,aMax:TpvVector2;const aWith:TpvVectorPathBoundingBox):Boolean; overload; static;
       function Contains(const aBoundingBox:TpvVectorPathBoundingBox):Boolean; overload;
       class function Contains(const aMin,aMax,aVector:TpvVectorPathVector):boolean; overload; static;
       class function Contains(const aMin,aMax:TpvVector2;const aVector:TpvVectorPathVector):Boolean; overload; static;
       function Intersect(const aWith:TpvVectorPathBoundingBox;const aThreshold:TpvDouble=EPSILON):Boolean; overload;
       class function Intersect(const aMin,aMax:TpvVectorPathVector;const aWith:TpvVectorPathBoundingBox;const aThreshold:TpvDouble=EPSILON):Boolean; overload; static;
       class function Intersect(const aMin,aMax:TpvVector2;const aWith:TpvVectorPathBoundingBox;const aThreshold:TpvDouble=EPSILON):Boolean; overload; static;
       function FastRayIntersection(const aOrigin,aDirection:TpvVectorPathVector):Boolean; overload;
       class function FastRayIntersection(const aMin,aMax:TpvVectorPathVector;const aOrigin,aDirection:TpvVectorPathVector):Boolean; overload; static;
       class function FastRayIntersection(const aMin,aMax:TpvVector2;const aOrigin,aDirection:TpvVectorPathVector):Boolean; overload; static;
       function LineIntersection(const aStartPoint,aEndPoint:TpvVectorPathVector):Boolean; overload;
       class function LineIntersection(const aMin,aMax:TpvVectorPathVector;const aStartPoint,aEndPoint:TpvVectorPathVector):Boolean; overload; static;
       class function LineIntersection(const aMin,aMax:TpvVector2;const aStartPoint,aEndPoint:TpvVectorPathVector):Boolean; overload; static;
      public
       case boolean of
        false:(
         Min:TpvVectorPathVector;
         Max:TpvVectorPathVector;
        );
        true:(
         MinMax:array[0..1] of TpvVectorPathVector;
        );
     end;

     PpvVectorPathBoundingBox=^TpvVectorPathBoundingBox;

     { TpvVectorPathBVHDynamicAABBTree }
     TpvVectorPathBVHDynamicAABBTree=class
      public
       const NULLNODE=-1;
             AABBMULTIPLIER=2.0;
             AABBEPSILON=1e-14;
             ThresholdAABBVector:TpvVectorPathVector=(x:AABBEPSILON;y:AABBEPSILON);
       type TTreeNode=record
             public
              AABB:TpvVectorPathBoundingBox;
              UserData:TpvPtrInt;
              Children:array[0..1] of TpvSizeInt;
              Height:TpvSizeInt;
              case boolean of
               false:(
                Parent:TpvSizeInt;
               );
               true:(
                Next:TpvSizeInt;
               );
            end;
            PTreeNode=^TTreeNode;
            TTreeNodes=array of TTreeNode;
            TState=record
             TreeNodes:TTreeNodes;
             Root:TpvSizeInt;
            end;
            PState=^TState;
            TUserDataArray=array of TpvPtrInt;
            TSizeIntArray=array[0..65535] of TpvSizeInt;
            PSizeIntArray=^TSizeIntArray;
            TSkipListNode=packed record // <= GPU-compatible with 32 bytes per node
             public
              // (u)vec4 aabbMinSkipCount
              AABBMin:TpvVector2;
              SkipCount:TpvUInt32;
              Dummy0:TpvUInt32;
              // (u)vec4 aabbMaxUserData
              AABBMax:TpvVector2;
              UserData:TpvUInt32;
              Dummy1:TpvUInt32;
            end;
            PSkipListNode=^TSkipListNode;
            TSkipListNodes=array of TSkipListNode;
            TSkipListNodeArray=TpvDynamicArray<TSkipListNode>;
            TSkipListNodeMap=array of TpvSizeUInt;
            TSkipListNodeStackItem=record
             Pass:TpvSizeInt;
             Node:TpvSizeInt;
            end;
            PSkipListNodeStackItem=^TSkipListNodeStackItem;
            TSkipListNodeStack=TpvDynamicStack<TSkipListNodeStackItem>;
            TGetUserDataIndex=function(const aUserData:TpvPtrInt):TpvUInt32 of object;
            TRayCastUserData=function(const aUserData:TpvPtrInt;const aRayOrigin,aRayDirection:TpvVectorPathVector;out aTime:TpvDouble;out aStop:boolean):boolean of object;
            { TSkipList }
            TSkipList=class
             private
              fNodeArray:TSkipListNodeArray;
             public
              constructor Create(const aFrom:TpvVectorPathBVHDynamicAABBTree;const aGetUserDataIndex:TpvVectorPathBVHDynamicAABBTree.TGetUserDataIndex); reintroduce;
              destructor Destroy; override;
              function IntersectionQuery(const aAABB:TpvVectorPathBoundingBox):TpvVectorPathBVHDynamicAABBTree.TUserDataArray;
              function ContainQuery(const aAABB:TpvVectorPathBoundingBox):TpvVectorPathBVHDynamicAABBTree.TUserDataArray; overload;
              function ContainQuery(const aPoint:TpvVectorPathVector):TpvVectorPathBVHDynamicAABBTree.TUserDataArray; overload;
              function RayCast(const aRayOrigin,aRayDirection:TpvVectorPathVector;out aTime:TpvDouble;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvVectorPathBVHDynamicAABBTree.TRayCastUserData):boolean;
              function RayCastLine(const aFrom,aTo:TpvVectorPathVector;out aTime:TpvDouble;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvVectorPathBVHDynamicAABBTree.TRayCastUserData):boolean;
             public
              property NodeArray:TSkipListNodeArray read fNodeArray;
            end;
      private
       fSkipListNodeLock:TPasMPSpinLock;
       fSkipListNodeMap:TSkipListNodeMap;
       fSkipListNodeStack:TSkipListNodeStack;
      public
       Root:TpvSizeInt;
       Nodes:TTreeNodes;
       NodeCount:TpvSizeInt;
       NodeCapacity:TpvSizeInt;
       FreeList:TpvSizeInt;
       Path:TpvSizeUInt;
       InsertionCount:TpvSizeInt;
       constructor Create;
       destructor Destroy; override;
       function AllocateNode:TpvSizeInt;
       procedure FreeNode(const aNodeID:TpvSizeInt);
       function Balance(const aNodeID:TpvSizeInt):TpvSizeInt;
       procedure InsertLeaf(const aLeaf:TpvSizeInt);
       procedure RemoveLeaf(const aLeaf:TpvSizeInt);
       function CreateProxy(const aAABB:TpvVectorPathBoundingBox;const aUserData:TpvPtrInt):TpvSizeInt;
       procedure DestroyProxy(const aNodeID:TpvSizeInt);
       function MoveProxy(const aNodeID:TpvSizeInt;const aAABB:TpvVectorPathBoundingBox;const aDisplacement:TpvVectorPathVector):boolean;
       procedure Rebalance(const aIterations:TpvSizeInt);
       procedure RebuildBottomUp;
       procedure RebuildTopDown;
       procedure Rebuild;
       function ComputeHeight:TpvSizeInt;
       function GetHeight:TpvSizeInt;
       function GetAreaRatio:TpvDouble;
       function GetMaxBalance:TpvSizeInt;
       function ValidateStructure:boolean;
       function ValidateMetrics:boolean;
       function Validate:boolean;
       function IntersectionQuery(const aAABB:TpvVectorPathBoundingBox):TpvVectorPathBVHDynamicAABBTree.TUserDataArray;
       function ContainQuery(const aAABB:TpvVectorPathBoundingBox):TpvVectorPathBVHDynamicAABBTree.TUserDataArray; overload;
       function ContainQuery(const aPoint:TpvVectorPathVector):TpvVectorPathBVHDynamicAABBTree.TUserDataArray; overload;
       function RayCast(const aRayOrigin,aRayDirection:TpvVectorPathVector;out aTime:TpvDouble;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvVectorPathBVHDynamicAABBTree.TRayCastUserData):boolean;
       function RayCastLine(const aFrom,aTo:TpvVectorPathVector;out aTime:TpvDouble;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvVectorPathBVHDynamicAABBTree.TRayCastUserData):boolean;
       procedure GetSkipListNodes(var aSkipListNodeArray:TSkipListNodeArray;const aGetUserDataIndex:TpvVectorPathBVHDynamicAABBTree.TGetUserDataIndex);
     end;

     { TpvVectorPathVectorCommand }

     TpvVectorPathCommand=class
      private
       fCommandType:TpvVectorPathCommandType;
       fX0:TpvDouble;
       fY0:TpvDouble;
       fX1:TpvDouble;
       fY1:TpvDouble;
       fX2:TpvDouble;
       fY2:TpvDouble;
      public
       constructor Create(const aCommandType:TpvVectorPathCommandType;
                          const aX0:TpvDouble=0.0;
                          const aY0:TpvDouble=0.0;
                          const aX1:TpvDouble=0.0;
                          const aY1:TpvDouble=0.0;
                          const aX2:TpvDouble=0.0;
                          const aY2:TpvDouble=0.0); reintroduce;
      published
       property CommandType:TpvVectorPathCommandType read fCommandType write fCommandType;
       property x0:TpvDouble read fX0 write fX0;
       property y0:TpvDouble read fY0 write fY0;
       property x1:TpvDouble read fX1 write fX1;
       property y1:TpvDouble read fY1 write fY1;
       property x2:TpvDouble read fX2 write fX2;
       property y2:TpvDouble read fY2 write fY2;
     end;

     TpvVectorPathCommandList=class(TObjectList<TpvVectorPathCommand>);

     TpvVectorPathFillRule=
      (
       NonZero=0,
       EvenOdd
      );

     PpvVectorPathFillRule=^TpvVectorPathFillRule;

     TpvVectorPathSegmentType=
      (
       Line=0,
       QuadraticCurve,
       CubicCurve
      );

     PpvVectorPathSegmentType=^TpvVectorPathSegmentType;

     { TpvVectorPathSegment }

     TpvVectorPathSegment=class
      private
       fType:TpvVectorPathSegmentType;
       fCachedBoundingBox:TpvVectorPathBoundingBox;
       fHasCachedBoundingBox:TPasMPBool32;
       fCachedBoundingBoxLock:TPasMPInt32;
      protected
       procedure GetIntersectionPointsWithLineSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); virtual;
       procedure GetIntersectionPointsWithQuadraticCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); virtual;
       procedure GetIntersectionPointsWithCubicCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); virtual;
      public
       constructor Create; reintroduce; overload; virtual;
       destructor Destroy; override;
       procedure Assign(const aSegment:TpvVectorPathSegment); virtual;
       function Clone:TpvVectorPathSegment; virtual;
       function GetBoundingBox:TpvVectorPathBoundingBox; virtual;
       procedure GetIntersectionPointsWithSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); virtual;
       function GetCompareHorizontalLowestXCoordinate:TpvDouble;
      public
       property BoundingBox:TpvVectorPathBoundingBox read GetBoundingBox;
      published
       property Type_:TpvVectorPathSegmentType read fType;
     end;

     { TpvVectorPathSegmentLine }

     TpvVectorPathSegmentLine=class(TpvVectorPathSegment)
      public
       Points:array[0..1] of TpvVectorPathVector;
      protected
       procedure GetIntersectionPointsWithLineSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); override;
       procedure GetIntersectionPointsWithQuadraticCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); override;
       procedure GetIntersectionPointsWithCubicCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); override;
      public
       constructor Create; overload; override;
       constructor Create(const aP0,aP1:TpvVectorPathVector); overload;
       procedure Assign(const aSegment:TpvVectorPathSegment); override;
       function Clone:TpvVectorPathSegment; override;
       function GetBoundingBox:TpvVectorPathBoundingBox; override;
       procedure GetIntersectionPointsWithSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); override;
     end;

     { TpvVectorPathSegmentMetaWindingSettingLine }
     TpvVectorPathSegmentMetaWindingSettingLine=class(TpvVectorPathSegmentLine)
      private
       fWinding:TpvInt32;
      published
       property Winding:TpvInt32 read fWinding write fWinding;
     end;

     { TpvVectorPathSegmentQuadraticCurve }

     TpvVectorPathSegmentQuadraticCurve=class(TpvVectorPathSegment)
      public
       Points:array[0..2] of TpvVectorPathVector;
      protected
       procedure GetIntersectionPointsWithLineSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); override;
       procedure GetIntersectionPointsWithQuadraticCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); override;
       procedure GetIntersectionPointsWithCubicCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); override;
      public
       constructor Create; overload; override;
       constructor Create(const aP0,aP1,aP2:TpvVectorPathVector); overload;
       procedure Assign(const aSegment:TpvVectorPathSegment); override;
       function Clone:TpvVectorPathSegment; override;
       function GetBoundingBox:TpvVectorPathBoundingBox; override;
       procedure GetIntersectionPointsWithSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); override;
     end;

     { TpvVectorPathSegmentCubicCurve }

     TpvVectorPathSegmentCubicCurve=class(TpvVectorPathSegment)
      public
       Points:array[0..3] of TpvVectorPathVector;
      protected
       procedure GetIntersectionPointsWithLineSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); override;
       procedure GetIntersectionPointsWithQuadraticCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); override;
       procedure GetIntersectionPointsWithCubicCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); override;
      public
       constructor Create; overload; override;
       constructor Create(const aP0,aP1,aP2,aP3:TpvVectorPathVector); overload;
       procedure Assign(const aSegment:TpvVectorPathSegment); override;
       function Clone:TpvVectorPathSegment; override;
       function GetBoundingBox:TpvVectorPathBoundingBox; override;
       procedure GetIntersectionPointsWithSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList); override;
     end;

     { TpvVectorPathSegments }

     TpvVectorPathSegments=class(TpvObjectGenericList<TpvVectorPathSegment>)
      public
       procedure SortHorizontal;
     end;

     { TpvVectorPathContour }

     TpvVectorPathContour=class
      private
       fSegments:TpvVectorPathSegments;
       fClosed:boolean;
      public
       constructor Create; reintroduce; overload;
       constructor Create(const aContour:TpvVectorPathContour); overload;
       destructor Destroy; override;
       procedure Assign(const aContour:TpvVectorPathContour);
       function Clone:TpvVectorPathContour;
       function GetBoundingBox:TpvVectorPathBoundingBox;
      published
       property Segments:TpvVectorPathSegments read fSegments;
       property Closed:boolean read fClosed write fClosed;
     end;

     TpvVectorPathContours=TpvObjectGenericList<TpvVectorPathContour>;

     TpvVectorPath=class;

     { TpvVectorPathShape }

     TpvVectorPathShape=class
      private
       fFillRule:TpvVectorPathFillRule;
       fContours:TpvVectorPathContours;
      public
       constructor Create; reintroduce; overload;
       constructor Create(const aVectorPathShape:TpvVectorPathShape); reintroduce; overload;
       constructor Create(const aVectorPath:TpvVectorPath); reintroduce; overload;
       destructor Destroy; override;
       procedure Assign(const aVectorPathShape:TpvVectorPathShape); overload;
       procedure Assign(const aVectorPath:TpvVectorPath); overload;
       function Clone:TpvVectorPathShape;
       function GetBoundingBox:TpvVectorPathBoundingBox;
       procedure ConvertCubicCurvesToQuadraticCurves(const aPixelRatio:TpvDouble=1.0);
       procedure ConvertCurvesToLines(const aPixelRatio:TpvDouble=1.0);
       function GetSignedDistance(const aX,aY,aScale:TpvDouble;out aInsideOutsideSign:TpvInt32):TpvDouble;
       function GetBeginEndPoints:TpvVectorPathVectors;
       procedure GetSegmentIntersectionPoints(const aIntersectionPoints:TpvVectorPathVectorList);
      published
       property FillRule:TpvVectorPathFillRule read fFillRule write fFillRule;
       property Contours:TpvVectorPathContours read fContours;
     end;

     { TpvVectorPath }

     TpvVectorPath=class
      private
       fCommands:TpvVectorPathCommandList;
       fFillRule:TpvVectorPathFillRule;
      public
       constructor Create; reintroduce;
       constructor CreateFromSVGPath(const aCommands:TpvRawByteString);
       constructor CreateFromShape(const aShape:TpvVectorPathShape);
       destructor Destroy; override;
       procedure Assign(const aFrom:TpvVectorPath); overload;
       procedure Assign(const aShape:TpvVectorPathShape); overload;
       procedure MoveTo(const aX,aY:TpvDouble);
       procedure LineTo(const aX,aY:TpvDouble);
       procedure QuadraticCurveTo(const aCX,aCY,aAX,aAY:TpvDouble);
       procedure CubicCurveTo(const aC0X,aC0Y,aC1X,aC1Y,aAX,aAY:TpvDouble);
       procedure Close;
       function GetShape:TpvVectorPathShape;
      published
       property FillRule:TpvVectorPathFillRule read fFillRule write fFillRule;
       property Commands:TpvVectorPathCommandList read fCommands;
     end;

     TpvVectorPathGPUSegmentData=packed record // 32 bytes per segment
      public
       const TypeUnknown=0;
             TypeLine=1;
             TypeQuadraticCurve=2;
             TypeMetaWindingSettingLine=3;
      public
       // uvec4 typeWindingPoint0 - Begin
       Type_:TpvUInt32;
       Winding:TpvInt32;
       Point0:TpvVector2;
       // uvec4 typeWindingPoint0 - End
       // vec4 point1Point2 - Begin
       Point1:TpvVector2;
       Point2:TpvVector2;
       // vec4 point1Point2 - End
     end;

     PpvVectorPathGPUSegmentData=^TpvVectorPathGPUSegmentData;

     TpvVectorPathGPUIndirectSegmentData=TpvUInt32; // 4 bytes per indirect segment

     PpvVectorPathGPUIndirectSegmentData=^TpvVectorPathGPUIndirectSegmentData;

     TpvVectorPathGPUGridCellData=packed record // 8 bytes per grid cell
      // uvec2 Begin
      StartIndirectSegmentIndex:TpvUInt32;
      CountIndirectSegments:TpvUInt32;
      // uvec2 End
     end;

     PpvVectorPathGPUGridCellData=^TpvVectorPathGPUGridCellData;

     TpvVectorPathGPUShapeData=packed record // 32 bytes per segment
      // vec4 minMax - Begin
      Min:TpvVector2;
      Max:TpvVector2;
      // vec4 minMax - End
      // uvec4 flagsStartGridCellIndexGridSize - Begin
      Flags:TpvUInt32; // Bit 0 = even-odd / non-zero fill rule selector (1 => even-odd, 0 => non-zero)
      StartGridCellIndex:TpvUInt32;
      GridSizeX:TpvUInt32;
      GridSizeY:TpvUInt32;
      // uvec4 flagsStartGridCellIndexGridSize - End
     end;

     PpvVectorPathGPUShapeData=^TpvVectorPathGPUShapeData;

     { TpvVectorPathGPUShape }

     TpvVectorPathGPUShape=class
      public
       const CoordinateExtents=1.41421356237; // sqrt(2.0)
       type { TGridCell }
            TGridCell=class
             public
              type TKind=
                    (
                     Empty,
                     HasContent
                    );
             private
              fKind:TKind;
              fVectorPathGPUShape:TpvVectorPathGPUShape;
              fBoundingBox:TpvVectorPathBoundingBox;
              fExtendedBoundingBox:TpvVectorPathBoundingBox;
              fSegments:TpvVectorPathSegments;
             public
              constructor Create(const aVectorPathGPUShape:TpvVectorPathGPUShape;const aBoundingBox:TpvVectorPathBoundingBox); reintroduce;
              destructor Destroy; override;
            end;
            TGridCells=TpvObjectGenericList<TGridCell>;
      private
       fVectorPathShape:TpvVectorPathShape;
       fBoundingBox:TpvVectorPathBoundingBox;
       fResolution:TpvInt32;
       fSegments:TpvVectorPathSegments;
       fSegmentDynamicAABBTree:TpvVectorPathBVHDynamicAABBTree;
       fGridCells:TGridCells;
      public
       constructor Create(const aVectorPathShape:TpvVectorPathShape;const aResolution:TpvInt32;const aBoundingBoxExtent:TpvDouble=4.0); reintroduce;
       destructor Destroy; override;
     end;

implementation

function Clamp(const Value,MinValue,MaxValue:TpvDouble):TpvDouble;
begin
 if Value<=MinValue then begin
  result:=MinValue;
 end else if Value>=MaxValue then begin
  result:=MaxValue;
 end else begin
  result:=Value;
 end;
end;

{ TpvVectorPathVector }

constructor TpvVectorPathVector.Create(const aValue:TpvDouble);
begin
 x:=aValue;
 y:=aValue;
end;

constructor TpvVectorPathVector.Create(const aX,aY:TpvDouble);
begin
 x:=aX;
 y:=aY;
end;

function TpvVectorPathVector.Length:TpvDouble;
begin
 result:=sqrt(sqr(x)+sqr(y));
end;

function TpvVectorPathVector.LengthSquared:TpvDouble;
begin
 result:=sqr(x)+sqr(y);
end;

function TpvVectorPathVector.Distance(const b:TpvVectorPathVector):TpvDouble;
begin
 result:=(b-self).Length;
end;

function TpvVectorPathVector.DistanceSquared(const b:TpvVectorPathVector):TpvDouble;
begin
 result:=(b-self).LengthSquared;
end;

function TpvVectorPathVector.Direction:TpvDouble;
begin
 result:=ArcTan2(y,x);
end;

function TpvVectorPathVector.Normalize:TpvVectorPathVector;
var Len:TpvDouble;
begin
 Len:=Length;
 if IsZero(Len) then begin
  result.x:=0.0;
  result.y:=0.0;
 end else begin
  result.x:=x/Len;
  result.y:=y/Len;
 end;
end;

function TpvVectorPathVector.Minimum(const aRight:TpvVectorPathVector):TpvVectorPathVector;
begin
 result.x:=Min(x,aRight.x);
 result.y:=Min(y,aRight.y);
end;

function TpvVectorPathVector.Maximum(const aRight:TpvVectorPathVector):TpvVectorPathVector;
begin
 result.x:=Max(x,aRight.x);
 result.y:=Max(y,aRight.y);
end;

function TpvVectorPathVector.Dot(const aRight:TpvVectorPathVector):TpvDouble;
begin
 result:=(x*aRight.x)+(y*aRight.y);
end;

function TpvVectorPathVector.Cross(const aRight:TpvVectorPathVector):TpvDouble;
begin
 result:=(x*aRight.y)-(y*aRight.x);
end;

function TpvVectorPathVector.OrthoNormal:TpvVectorPathVector;
var Len:TpvDouble;
begin
 Len:=Length;
 if IsZero(Len) then begin
  result.x:=0.0;
  result.y:=0.0;
 end else begin
  result.x:=y/Len;
  result.y:=(-x)/Len;
 end;
end;

function TpvVectorPathVector.Lerp(const b:TpvVectorPathVector;const t:TpvDouble):TpvVectorPathVector;
begin
 result.x:=(x*(1.0-t))+(b.x*t);
 result.y:=(y*(1.0-t))+(b.y*t);
end;

function TpvVectorPathVector.ClampedLerp(const b:TpvVectorPathVector;const t:TpvDouble):TpvVectorPathVector;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result.x:=(x*(1.0-t))+(b.x*t);
  result.y:=(y*(1.0-t))+(b.y*t);
 end;
end;

class function TpvVectorPathVector.IsLeft(const a,b,c:TpvVectorPathVector):TpvDouble;
begin
 result:=((b.x*a.x)*(c.y*a.y))-((c.x*a.x)*(b.y*a.y));
end;

class operator TpvVectorPathVector.Equal(const a,b:TpvVectorPathVector):boolean;
begin
 result:=SameValue(a.x,b.x) and SameValue(a.y,b.y);
end;

class operator TpvVectorPathVector.NotEqual(const a,b:TpvVectorPathVector):boolean;
begin
 result:=(not SameValue(a.x,b.x)) or (not SameValue(a.y,b.y));
end;

class operator TpvVectorPathVector.Add(const a,b:TpvVectorPathVector):TpvVectorPathVector;
begin
 result.x:=a.x+b.x;
 result.y:=a.y+b.y;
end;

class operator TpvVectorPathVector.Subtract(const a,b:TpvVectorPathVector):TpvVectorPathVector;
begin
 result.x:=a.x-b.x;
 result.y:=a.y-b.y;
end;

class operator TpvVectorPathVector.Multiply(const a,b:TpvVectorPathVector):TpvVectorPathVector;
begin
 result.x:=a.x*b.x;
 result.y:=a.y*b.y;
end;

class operator TpvVectorPathVector.Multiply(const a:TpvVectorPathVector;const b:TpvDouble):TpvVectorPathVector;
begin
 result.x:=a.x*b;
 result.y:=a.y*b;
end;

class operator TpvVectorPathVector.Multiply(const a:TpvDouble;const b:TpvVectorPathVector):TpvVectorPathVector;
begin
 result.x:=a*b.x;
 result.y:=a*b.y;
end;

class operator TpvVectorPathVector.Divide(const a,b:TpvVectorPathVector):TpvVectorPathVector;
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
end;

class operator TpvVectorPathVector.Divide(const a:TpvVectorPathVector;const b:TpvDouble):TpvVectorPathVector;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
end;

class operator TpvVectorPathVector.Negative(const a:TpvVectorPathVector):TpvVectorPathVector;
begin
 result.x:=-a.x;
 result.y:=-a.y;
end;

class operator TpvVectorPathVector.Positive(const a:TpvVectorPathVector):TpvVectorPathVector;
begin
 result.x:=a.x;
 result.y:=a.y;
end;

{ TpvVectorPathVectorList }

procedure TpvVectorPathVectorList.Sort;
type PByteArray=^TByteArray;
     TByteArray=array[0..$3fffffff] of TpvUInt8;
     PStackItem=^TStackItem;
     TStackItem=record
      Left,Right,Depth:TpvInt32;
     end;
var Left,Right,Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:TpvSizeInt;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
 function CompareItem(const a,b:TpvSizeInt):TpvSizeInt;
 var va,vb:TpvVectorPathVector;
 begin
  va:=Items[a];
  vb:=Items[b];
  result:=Sign(va.y-vb.y);
  if result=0 then begin
   result:=Sign(va.x-vb.x);
   if result=0 then begin
    result:=Sign(a-b);
   end;
  end;
 end;
begin
 begin
  if Count>1 then begin
   StackItem:=@Stack[0];
   StackItem^.Left:=0;
   StackItem^.Right:=Count-1;
   StackItem^.Depth:=IntLog2(Count) shl 1;
   inc(StackItem);
   while TpvPtrUInt(TpvPointer(StackItem))>TpvPtrUInt(TpvPointer(@Stack[0])) do begin
    dec(StackItem);
    Left:=StackItem^.Left;
    Right:=StackItem^.Right;
    Depth:=StackItem^.Depth;
    Size:=(Right-Left)+1;
    if Size<16 then begin
     // Insertion sort
     iA:=Left;
     iB:=iA+1;
     while iB<=Right do begin
      iC:=iB;
      while (iA>=Left) and
            (iC>=Left) and
            (CompareItem(iA,iC)>0) do begin
       Exchange(iA,iC);
       dec(iA);
       dec(iC);
      end;
      iA:=iB;
      inc(iB);
     end;
    end else begin
     if (Depth=0) or (TpvPtrUInt(TpvPointer(StackItem))>=TpvPtrUInt(TpvPointer(@Stack[high(Stack)-1]))) then begin
      // Heap sort
      i:=Size div 2;
      repeat
       if i>0 then begin
        dec(i);
       end else begin
        dec(Size);
        if Size>0 then begin
         Exchange(Left+Size,Left);
        end else begin
         break;
        end;
       end;
       Parent:=i;
       repeat
        Child:=(Parent*2)+1;
        if Child<Size then begin
         if (Child<(Size-1)) and (CompareItem(Left+Child,Left+Child+1)<0) then begin
          inc(Child);
         end;
         if CompareItem(Left+Parent,Left+Child)<0 then begin
          Exchange(Left+Parent,Left+Child);
          Parent:=Child;
          continue;
         end;
        end;
        break;
       until false;
      until false;
     end else begin
      // Quick sort width median-of-three optimization
      Middle:=Left+((Right-Left) shr 1);
      if (Right-Left)>3 then begin
       if CompareItem(Left,Middle)>0 then begin
        Exchange(Left,Middle);
       end;
       if CompareItem(Left,Right)>0 then begin
        Exchange(Left,Right);
       end;
       if CompareItem(Middle,Right)>0 then begin
        Exchange(Middle,Right);
       end;
      end;
      Pivot:=Middle;
      i:=Left;
      j:=Right;
      repeat
       while (i<Right) and (CompareItem(i,Pivot)<0) do begin
        inc(i);
       end;
       while (j>=i) and (CompareItem(j,Pivot)>0) do begin
        dec(j);
       end;
       if i>j then begin
        break;
       end else begin
        if i<>j then begin
         Exchange(i,j);
         if Pivot=i then begin
          Pivot:=j;
         end else if Pivot=j then begin
          Pivot:=i;
         end;
        end;
        inc(i);
        dec(j);
       end;
      until false;
      if i<Right then begin
       StackItem^.Left:=i;
       StackItem^.Right:=Right;
       StackItem^.Depth:=Depth-1;
       inc(StackItem);
      end;
      if Left<j then begin
       StackItem^.Left:=Left;
       StackItem^.Right:=j;
       StackItem^.Depth:=Depth-1;
       inc(StackItem);
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure TpvVectorPathVectorList.RemoveDuplicates;
var Index:TpvSizeInt;
begin
 if Count>=2 then begin
  Sort;
  for Index:=Count-1 downto 1 do begin
   if Items[Index-1]=Items[Index] then begin
    Delete(Index-1);
   end;
  end;
 end;
end;

{ TpvVectorPathBoundingBox }

constructor TpvVectorPathBoundingBox.Create(const aMin,aMax:TpvVectorPathVector);
begin
 MinMax[0]:=aMin;
 MinMax[1]:=aMax;
end;

procedure TpvVectorPathBoundingBox.Extend(const aVector:TpvVectorPathVector);
begin
 MinMax[0]:=MinMax[0].Minimum(aVector);
 MinMax[1]:=MinMax[1].Maximum(aVector);
end;

function TpvVectorPathBoundingBox.Combine(const aWith:TpvVectorPathBoundingBox):TpvVectorPathBoundingBox;
begin
 result:=TpvVectorPathBoundingBox.Create(MinMax[0].Minimum(aWith.MinMax[0]),MinMax[1].Maximum(aWith.MinMax[1]));
end;

function TpvVectorPathBoundingBox.Cost:TpvDouble;
begin
 result:=(Max.x-Min.x)+(Max.y-Min.y); // Manhattan distance
end;

function TpvVectorPathBoundingBox.Volume:TpvDouble;
begin
 result:=(Max.x-Min.x)*(Max.y-Min.y); // Volume
end;

function TpvVectorPathBoundingBox.Area:TpvDouble;
begin
 result:=2.0*(abs(Max.x-Min.x)*abs(Max.y-Min.y));
end;

function TpvVectorPathBoundingBox.Center:TpvVectorPathVector;
begin
 result:=Min.Lerp(Max,0.5);
end;

function TpvVectorPathBoundingBox.Contains(const aVector:TpvVectorPathVector):Boolean;
begin
 result:=((aVector.x>=MinMax[0].x) and (aVector.y>=MinMax[0].y)) and
         ((aVector.x<=MinMax[1].x) and (aVector.y<=MinMax[1].y));
end;

function TpvVectorPathBoundingBox.Contains(const aBoundingBox:TpvVectorPathBoundingBox):Boolean;
begin
 result:=((Min.x-EPSILON)<=(aBoundingBox.Min.x+EPSILON)) and ((Min.y-EPSILON)<=(aBoundingBox.Min.y+EPSILON)) and
         ((Max.x+EPSILON)>=(aBoundingBox.Min.x+EPSILON)) and ((Max.y+EPSILON)>=(aBoundingBox.Min.y+EPSILON)) and
         ((Min.x-EPSILON)<=(aBoundingBox.Max.x-EPSILON)) and ((Min.y-EPSILON)<=(aBoundingBox.Max.y-EPSILON)) and
         ((Max.x+EPSILON)>=(aBoundingBox.Max.x-EPSILON)) and ((Max.y+EPSILON)>=(aBoundingBox.Max.y-EPSILON));
end;

class function TpvVectorPathBoundingBox.Contains(const aMin,aMax:TpvVectorPathVector;const aWith:TpvVectorPathBoundingBox):Boolean;
begin
 result:=((aMin.x-EPSILON)<=(aWith.Min.x+EPSILON)) and ((aMin.y-EPSILON)<=(aWith.Min.y+EPSILON)) and
         ((aMax.x+EPSILON)>=(aWith.Min.x+EPSILON)) and ((aMax.y+EPSILON)>=(aWith.Min.y+EPSILON)) and
         ((aMin.x-EPSILON)<=(aWith.Max.x-EPSILON)) and ((aMin.y-EPSILON)<=(aWith.Max.y-EPSILON)) and
         ((aMax.x+EPSILON)>=(aWith.Max.x-EPSILON)) and ((aMax.y+EPSILON)>=(aWith.Max.y-EPSILON));
end;

class function TpvVectorPathBoundingBox.Contains(const aMin,aMax:TpvVector2;const aWith:TpvVectorPathBoundingBox):Boolean;
begin
 result:=((aMin.x-EPSILON)<=(aWith.Min.x+EPSILON)) and ((aMin.y-EPSILON)<=(aWith.Min.y+EPSILON)) and
         ((aMax.x+EPSILON)>=(aWith.Min.x+EPSILON)) and ((aMax.y+EPSILON)>=(aWith.Min.y+EPSILON)) and
         ((aMin.x-EPSILON)<=(aWith.Max.x-EPSILON)) and ((aMin.y-EPSILON)<=(aWith.Max.y-EPSILON)) and
         ((aMax.x+EPSILON)>=(aWith.Max.x-EPSILON)) and ((aMax.y+EPSILON)>=(aWith.Max.y-EPSILON));
end;

class function TpvVectorPathBoundingBox.Contains(const aMin,aMax,aVector:TpvVectorPathVector):boolean;
begin
 result:=((aVector.x>=(aMin.x-EPSILON)) and (aVector.x<=(aMax.x+EPSILON))) and
         ((aVector.y>=(aMin.y-EPSILON)) and (aVector.y<=(aMax.y+EPSILON)));
end;

class function TpvVectorPathBoundingBox.Contains(const aMin,aMax:TpvVector2;const aVector:TpvVectorPathVector):Boolean;
begin
 result:=((aVector.x>=(aMin.x-EPSILON)) and (aVector.x<=(aMax.x+EPSILON))) and
         ((aVector.y>=(aMin.y-EPSILON)) and (aVector.y<=(aMax.y+EPSILON)));
end;

function TpvVectorPathBoundingBox.Intersect(const aWith:TpvVectorPathBoundingBox;const aThreshold:TpvDouble):Boolean;
begin
 result:=(((Max.x+aThreshold)>=(aWith.Min.x-aThreshold)) and ((Min.x-aThreshold)<=(aWith.Max.x+aThreshold))) and
         (((Max.y+aThreshold)>=(aWith.Min.y-aThreshold)) and ((Min.y-aThreshold)<=(aWith.Max.y+aThreshold)));
end;

class function TpvVectorPathBoundingBox.Intersect(const aMin,aMax:TpvVectorPathVector;const aWith:TpvVectorPathBoundingBox;const aThreshold:TpvDouble):Boolean;
begin
 result:=(((aMax.x+aThreshold)>=(aWith.Min.x-aThreshold)) and ((aMin.x-aThreshold)<=(aWith.Max.x+aThreshold))) and
         (((aMax.y+aThreshold)>=(aWith.Min.y-aThreshold)) and ((aMin.y-aThreshold)<=(aWith.Max.y+aThreshold)));
end;

class function TpvVectorPathBoundingBox.Intersect(const aMin,aMax:TpvVector2;const aWith:TpvVectorPathBoundingBox;const aThreshold:TpvDouble):Boolean;
begin
 result:=(((aMax.x+aThreshold)>=(aWith.Min.x-aThreshold)) and ((aMin.x-aThreshold)<=(aWith.Max.x+aThreshold))) and
         (((aMax.y+aThreshold)>=(aWith.Min.y-aThreshold)) and ((aMin.y-aThreshold)<=(aWith.Max.y+aThreshold)));
end;

function TpvVectorPathBoundingBox.FastRayIntersection(const aOrigin,aDirection:TpvVectorPathVector):Boolean;
var Center,BoxExtents,Diff:TpvVectorPathVector;
begin
 Center:=(Min+Max)*0.5;
 BoxExtents:=Center-Min;
 Diff:=aOrigin-Center;
 result:=not ((((abs(Diff.x)>BoxExtents.x) and ((Diff.x*aDirection.x)>=0)) or
               ((abs(Diff.y)>BoxExtents.y) and ((Diff.y*aDirection.y)>=0))) or
              ((abs((aDirection.x*Diff.y)-(aDirection.y*Diff.x))>((BoxExtents.x*abs(aDirection.y))+(BoxExtents.y*abs(aDirection.x))))));
end;

class function TpvVectorPathBoundingBox.FastRayIntersection(const aMin,aMax:TpvVectorPathVector;const aOrigin,aDirection:TpvVectorPathVector):Boolean;
var Center,BoxExtents,Diff:TpvVectorPathVector;
begin
 Center:=(aMin+aMax)*0.5;
 BoxExtents:=Center-aMin;
 Diff:=aOrigin-Center;
 result:=not ((((abs(Diff.x)>BoxExtents.x) and ((Diff.x*aDirection.x)>=0)) or
               ((abs(Diff.y)>BoxExtents.y) and ((Diff.y*aDirection.y)>=0))) or
              ((abs((aDirection.x*Diff.y)-(aDirection.y*Diff.x))>((BoxExtents.x*abs(aDirection.y))+(BoxExtents.y*abs(aDirection.x))))));
end;

class function TpvVectorPathBoundingBox.FastRayIntersection(const aMin,aMax:TpvVector2;const aOrigin,aDirection:TpvVectorPathVector):Boolean;
var Center,BoxExtents,Diff:TpvVectorPathVector;
begin
 Center.x:=(aMin.x+aMax.x)*0.5;
 Center.y:=(aMin.y+aMax.y)*0.5;
 BoxExtents.x:=Center.x-aMin.x;
 BoxExtents.y:=Center.y-aMin.y;
 Diff:=aOrigin-Center;
 result:=not ((((abs(Diff.x)>BoxExtents.x) and ((Diff.x*aDirection.x)>=0)) or
               ((abs(Diff.y)>BoxExtents.y) and ((Diff.y*aDirection.y)>=0))) or
              ((abs((aDirection.x*Diff.y)-(aDirection.y*Diff.x))>((BoxExtents.x*abs(aDirection.y))+(BoxExtents.y*abs(aDirection.x))))));
end;

function TpvVectorPathBoundingBox.LineIntersection(const aStartPoint,aEndPoint:TpvVectorPathVector):Boolean;
var Direction,InvDirection,a,b:TpvVectorPathVector;
    Len,TimeMin,TimeMax:TpvDouble;
begin
 if Contains(aStartPoint) or Contains(aEndPoint) then begin
  result:=true;
 end else begin
  Direction:=aEndPoint-aStartPoint;
  Len:=Direction.Length;
  if Len<>0.0 then begin
   Direction:=Direction/Len;
  end;
  if Direction.x<>0.0 then begin
   InvDirection.x:=1.0/Direction.x;
  end else begin
   InvDirection.x:=Infinity;
  end;
  if Direction.y<>0.0 then begin
   InvDirection.y:=1.0/Direction.y;
  end else begin
   InvDirection.y:=Infinity;
  end;
  a.x:=((Min.x-EPSILON)-aStartPoint.x)*InvDirection.x;
  a.y:=((Min.y-EPSILON)-aStartPoint.y)*InvDirection.y;
  b.x:=((Max.x+EPSILON)-aStartPoint.x)*InvDirection.x;
  b.y:=((Max.y+EPSILON)-aStartPoint.y)*InvDirection.y;
  TimeMin:=Math.Max(Math.Min(a.x,a.y),Math.Min(b.x,b.y));
  TimeMax:=Math.Min(Math.Max(a.x,a.y),Math.Max(b.x,b.y));
  result:=((TimeMin<=TimeMax) and (TimeMax>=0.0)) and (TimeMin<=(Len+EPSILON));
 end;
end;

class function TpvVectorPathBoundingBox.LineIntersection(const aMin,aMax:TpvVectorPathVector;const aStartPoint,aEndPoint:TpvVectorPathVector):Boolean;
var Direction,InvDirection,a,b:TpvVectorPathVector;
    Len,TimeMin,TimeMax:TpvDouble;
begin
 if TpvVectorPathBoundingBox.Contains(aMin,aMax,aStartPoint) or TpvVectorPathBoundingBox.Contains(aMin,aMax,aEndPoint) then begin
  result:=true;
 end else begin
  Direction:=aEndPoint-aStartPoint;
  Len:=Direction.Length;
  if Len<>0.0 then begin
   Direction:=Direction/Len;
  end;
  if Direction.x<>0.0 then begin
   InvDirection.x:=1.0/Direction.x;
  end else begin
   InvDirection.x:=Infinity;
  end;
  if Direction.y<>0.0 then begin
   InvDirection.y:=1.0/Direction.y;
  end else begin
   InvDirection.y:=Infinity;
  end;
  a.x:=((aMin.x-EPSILON)-aStartPoint.x)*InvDirection.x;
  a.y:=((aMin.y-EPSILON)-aStartPoint.y)*InvDirection.y;
  b.x:=((aMax.x+EPSILON)-aStartPoint.x)*InvDirection.x;
  b.y:=((aMax.y+EPSILON)-aStartPoint.y)*InvDirection.y;
  TimeMin:=Math.Max(Math.Min(a.x,a.y),Math.Min(b.x,b.y));
  TimeMax:=Math.Min(Math.Max(a.x,a.y),Math.Max(b.x,b.y));
  result:=((TimeMin<=TimeMax) and (TimeMax>=0.0)) and (TimeMin<=(Len+EPSILON));
 end;
end;

class function TpvVectorPathBoundingBox.LineIntersection(const aMin,aMax:TpvVector2;const aStartPoint,aEndPoint:TpvVectorPathVector):Boolean;
var Direction,InvDirection,a,b:TpvVectorPathVector;
    Len,TimeMin,TimeMax:TpvDouble;
begin
 if TpvVectorPathBoundingBox.Contains(aMin,aMax,aStartPoint) or TpvVectorPathBoundingBox.Contains(aMin,aMax,aEndPoint) then begin
  result:=true;
 end else begin
  Direction:=aEndPoint-aStartPoint;
  Len:=Direction.Length;
  if Len<>0.0 then begin
   Direction:=Direction/Len;
  end;
  if Direction.x<>0.0 then begin
   InvDirection.x:=1.0/Direction.x;
  end else begin
   InvDirection.x:=Infinity;
  end;
  if Direction.y<>0.0 then begin
   InvDirection.y:=1.0/Direction.y;
  end else begin
   InvDirection.y:=Infinity;
  end;
  a.x:=((aMin.x-EPSILON)-aStartPoint.x)*InvDirection.x;
  a.y:=((aMin.y-EPSILON)-aStartPoint.y)*InvDirection.y;
  b.x:=((aMax.x+EPSILON)-aStartPoint.x)*InvDirection.x;
  b.y:=((aMax.y+EPSILON)-aStartPoint.y)*InvDirection.y;
  TimeMin:=Math.Max(Math.Min(a.x,a.y),Math.Min(b.x,b.y));
  TimeMax:=Math.Min(Math.Max(a.x,a.y),Math.Max(b.x,b.y));
  result:=((TimeMin<=TimeMax) and (TimeMax>=0.0)) and (TimeMin<=(Len+EPSILON));
 end;
end;

{ TpvVectorPathBVHDynamicAABBTree.TSkipList }

constructor TpvVectorPathBVHDynamicAABBTree.TSkipList.Create(const aFrom:TpvVectorPathBVHDynamicAABBTree;const aGetUserDataIndex:TpvVectorPathBVHDynamicAABBTree.TGetUserDataIndex);
begin
 fNodeArray.Initialize;
 aFrom.GetSkipListNodes(fNodeArray,aGetUserDataIndex);
end;

destructor TpvVectorPathBVHDynamicAABBTree.TSkipList.Destroy;
begin
 fNodeArray.Finalize;
 inherited Destroy;
end;

function TpvVectorPathBVHDynamicAABBTree.TSkipList.IntersectionQuery(const aAABB:TpvVectorPathBoundingBox):TpvVectorPathBVHDynamicAABBTree.TUserDataArray;
var Index,Count:TpvSizeInt;
    Node:TpvVectorPathBVHDynamicAABBTree.PSkipListNode;
begin
 result:=nil;
 Count:=fNodeArray.Count;
 if Count>0 then begin
  Index:=0;
  while Index<Count do begin
   Node:=@fNodeArray.Items[Index];
   if TpvVectorPathBoundingBox.Intersect(Node^.AABBMin,Node^.AABBMax,aAABB) then begin
    if Node^.UserData<>0 then begin
     result:=result+[Node^.UserData];
    end;
    inc(Index);
   end else begin
    if Node^.SkipCount>0 then begin
     inc(Index,Node^.SkipCount);
    end else begin
     break;
    end;
   end;
  end;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.TSkipList.ContainQuery(const aAABB:TpvVectorPathBoundingBox):TpvVectorPathBVHDynamicAABBTree.TUserDataArray;
var Index,Count:TpvSizeInt;
    Node:TpvVectorPathBVHDynamicAABBTree.PSkipListNode;
begin
 result:=nil;
 Count:=fNodeArray.Count;
 if Count>0 then begin
  Index:=0;
  while Index<Count do begin
   Node:=@fNodeArray.Items[Index];
   if TpvVectorPathBoundingBox.Contains(Node^.AABBMin,Node^.AABBMax,aAABB) then begin
    if Node^.UserData<>0 then begin
     result:=result+[Node^.UserData];
    end;
    inc(Index);
   end else begin
    if Node^.SkipCount>0 then begin
     inc(Index,Node^.SkipCount);
    end else begin
     break;
    end;
   end;
  end;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.TSkipList.ContainQuery(const aPoint:TpvVectorPathVector):TpvVectorPathBVHDynamicAABBTree.TUserDataArray;
var Index,Count:TpvSizeInt;
    Node:TpvVectorPathBVHDynamicAABBTree.PSkipListNode;
begin
 result:=nil;
 Count:=fNodeArray.Count;
 if Count>0 then begin
  Index:=0;
  while Index<Count do begin
   Node:=@fNodeArray.Items[Index];
   if TpvVectorPathBoundingBox.Contains(Node^.AABBMin,Node^.AABBMax,aPoint) then begin
    if Node^.UserData<>0 then begin
     result:=result+[Node^.UserData];
    end;
    inc(Index);
   end else begin
    if Node^.SkipCount>0 then begin
     inc(Index,Node^.SkipCount);
    end else begin
     break;
    end;
   end;
  end;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.TSkipList.RayCast(const aRayOrigin,aRayDirection:TpvVectorPathVector;out aTime:TpvDouble;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvVectorPathBVHDynamicAABBTree.TRayCastUserData):boolean;
var Index,Count:TpvSizeInt;
    Node:TpvVectorPathBVHDynamicAABBTree.PSkipListNode;
    RayEnd:TpvVectorPathVector;
    Time:TpvDouble;
    Stop:boolean;
begin
 result:=false;
 Count:=fNodeArray.Count;
 if assigned(aRayCastUserData) and (Count>0) then begin
  aTime:=Infinity;
  RayEnd:=aRayOrigin;
  Index:=0;
  while Index<Count do begin
   Node:=@fNodeArray.Items[Index];
   if ((not result) and
       (TpvVectorPathBoundingBox.Contains(Node^.AABBMin,Node^.AABBMax,aRayOrigin) or
        TpvVectorPathBoundingBox.FastRayIntersection(Node^.AABBMin,Node^.AABBMax,aRayOrigin,aRayDirection))) or
      (result and TpvVectorPathBoundingBox.LineIntersection(Node^.AABBMin,Node^.AABBMax,aRayOrigin,RayEnd)) then begin
    if (Node^.UserData<>High(TpvUInt32)) and aRayCastUserData(Node^.UserData,aRayOrigin,aRayDirection,Time,Stop) then begin
     if (not result) or (Time<aTime) then begin
      aTime:=Time;
      aUserData:=Node^.UserData;
      result:=true;
      if aStopAtFirstHit or Stop then begin
       break;
      end else begin
       RayEnd:=aRayOrigin+(aRayDirection*Time);
      end;
     end;
    end;
    inc(Index);
   end else begin
    if Node^.SkipCount>0 then begin
     inc(Index,Node^.SkipCount);
    end else begin
     break;
    end;
   end;
  end;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.TSkipList.RayCastLine(const aFrom,aTo:TpvVectorPathVector;out aTime:TpvDouble;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvVectorPathBVHDynamicAABBTree.TRayCastUserData):boolean;
var Index,Count:TpvSizeInt;
    Node:TpvVectorPathBVHDynamicAABBTree.PSkipListNode;
    Time,RayLength:TpvDouble;
    RayOrigin,RayDirection,RayEnd:TpvVectorPathVector;
    Stop:boolean;
begin
 result:=false;
 Count:=fNodeArray.Count;
 if assigned(aRayCastUserData) and (Count>0) then begin
  aTime:=Infinity;
  RayOrigin:=aFrom;
  RayEnd:=aTo;
  RayDirection:=(RayEnd-RayOrigin).Normalize;
  RayLength:=(RayEnd-RayOrigin).Length;
  Index:=0;
  while Index<Count do begin
   Node:=@fNodeArray.Items[Index];
   if TpvVectorPathBoundingBox.LineIntersection(Node^.AABBMin,Node^.AABBMax,RayOrigin,RayEnd) then begin
    if (Node^.UserData<>High(TpvUInt32)) and aRayCastUserData(Node^.UserData,RayOrigin,RayDirection,Time,Stop) then begin
     if ((Time>=0.0) and (Time<=RayLength)) and ((not result) or (Time<aTime)) then begin
      aTime:=Time;
      aUserData:=Node^.UserData;
      result:=true;
      if aStopAtFirstHit or Stop then begin
       break;
      end else begin
       RayEnd:=RayOrigin+(RayDirection*Time);
       RayLength:=Time;
      end;
     end;
    end;
    inc(Index);
   end else begin
    if Node^.SkipCount>0 then begin
     inc(Index,Node^.SkipCount);
    end else begin
     break;
    end;
   end;
  end;
 end;
end;

{ TpvVectorPathBVHDynamicAABBTree }

constructor TpvVectorPathBVHDynamicAABBTree.Create;
var i:TpvSizeInt;
begin
 inherited Create;
 Root:=NULLNODE;
 Nodes:=nil;
 NodeCount:=0;
 NodeCapacity:=16;
 SetLength(Nodes,NodeCapacity);
 FillChar(Nodes[0],NodeCapacity*SizeOf(TTreeNode),#0);
 for i:=0 to NodeCapacity-2 do begin
  Nodes[i].Next:=i+1;
  Nodes[i].Height:=-1;
 end;
 Nodes[NodeCapacity-1].Next:=NULLNODE;
 Nodes[NodeCapacity-1].Height:=-1;
 FreeList:=0;
 Path:=0;
 InsertionCount:=0;
 fSkipListNodeLock:=TPasMPSpinLock.Create;
 fSkipListNodeMap:=nil;
 fSkipListNodeStack.Initialize;
end;

destructor TpvVectorPathBVHDynamicAABBTree.Destroy;
begin
 fSkipListNodeStack.Finalize;
 fSkipListNodeMap:=nil;
 FreeAndNil(fSkipListNodeLock);
 Nodes:=nil;
 inherited Destroy;
end;

function TpvVectorPathBVHDynamicAABBTree.AllocateNode:TpvSizeInt;
var Node:PTreeNode;
    i:TpvSizeInt;
begin
 if FreeList=NULLNODE then begin
  inc(NodeCapacity,(NodeCapacity+1) shr 1); // *1.5
  SetLength(Nodes,NodeCapacity);
  FillChar(Nodes[NodeCount],(NodeCapacity-NodeCount)*SizeOf(TTreeNode),#0);
  for i:=NodeCount to NodeCapacity-2 do begin
   Nodes[i].Next:=i+1;
   Nodes[i].Height:=-1;
  end;
  Nodes[NodeCapacity-1].Next:=NULLNODE;
  Nodes[NodeCapacity-1].Height:=-1;
  FreeList:=NodeCount;
 end;
 result:=FreeList;
 FreeList:=Nodes[result].Next;
 Node:=@Nodes[result];
 Node^.Parent:=NULLNODE;
 Node^.Children[0]:=NULLNODE;
 Node^.Children[1]:=NULLNODE;
 Node^.Height:=0;
 Node^.UserData:=0;
 inc(NodeCount);
end;

procedure TpvVectorPathBVHDynamicAABBTree.FreeNode(const aNodeID:TpvSizeInt);
var Node:PTreeNode;
begin
 Node:=@Nodes[aNodeID];
 Node^.Next:=FreeList;
 Node^.Height:=-1;
 FreeList:=aNodeID;
 dec(NodeCount);
end;

function TpvVectorPathBVHDynamicAABBTree.Balance(const aNodeID:TpvSizeInt):TpvSizeInt;
var NodeA,NodeB,NodeC,NodeD,NodeE,NodeF,NodeG:PTreeNode;
    NodeBID,NodeCID,NodeDID,NodeEID,NodeFID,NodeGID,NodeBalance:TpvSizeInt;
begin
 NodeA:=@Nodes[aNodeID];
 if (NodeA.Children[0]<0) or (NodeA^.Height<2) then begin
  result:=aNodeID;
 end else begin
  NodeBID:=NodeA.Children[0];
  NodeCID:=NodeA.Children[1];
  NodeB:=@Nodes[NodeBID];
  NodeC:=@Nodes[NodeCID];
  NodeBalance:=NodeC^.Height-NodeB^.Height;
  if NodeBalance>1 then begin
   NodeFID:=NodeC.Children[0];
   NodeGID:=NodeC.Children[1];
   NodeF:=@Nodes[NodeFID];
   NodeG:=@Nodes[NodeGID];
   NodeC^.Children[0]:=aNodeID;
   NodeC^.Parent:=NodeA^.Parent;
   NodeA^.Parent:=NodeCID;
   if NodeC.Parent>=0 then begin
    if Nodes[NodeC^.Parent].Children[0]=aNodeID then begin
     Nodes[NodeC^.Parent].Children[0]:=NodeCID;
    end else begin
     Nodes[NodeC^.Parent].Children[1]:=NodeCID;
    end;
   end else begin
    Root:=NodeCID;
   end;
   if NodeF^.Height>NodeG^.Height then begin
    NodeC^.Children[1]:=NodeFID;
    NodeA^.Children[1]:=NodeGID;
    NodeG^.Parent:=aNodeID;
    NodeA^.AABB:=NodeB^.AABB.Combine(NodeG^.AABB);
    NodeC^.AABB:=NodeA^.AABB.Combine(NodeF^.AABB);
    NodeA^.Height:=1+Max(NodeB^.Height,NodeG^.Height);
    NodeC^.Height:=1+Max(NodeA^.Height,NodeF^.Height);
   end else begin
    NodeC^.Children[1]:=NodeGID;
    NodeA^.Children[1]:=NodeFID;
    NodeF^.Parent:=aNodeID;
    NodeA^.AABB:=NodeB^.AABB.Combine(NodeF^.AABB);
    NodeC^.AABB:=NodeA^.AABB.Combine(NodeG^.AABB);
    NodeA^.Height:=1+Max(NodeB^.Height,NodeF^.Height);
    NodeC^.Height:=1+Max(NodeA^.Height,NodeG^.Height);
   end;
   result:=NodeCID;
  end else if NodeBalance<-1 then begin
   NodeDID:=NodeB^.Children[0];
   NodeEID:=NodeB^.Children[1];
   NodeD:=@Nodes[NodeDID];
   NodeE:=@Nodes[NodeEID];
   NodeB^.Children[0]:=aNodeID;
   NodeB^.Parent:=NodeA^.Parent;
   NodeA^.Parent:=NodeBID;
   if NodeB^.Parent>=0 then begin
    if Nodes[NodeB^.Parent].Children[0]=aNodeID then begin
     Nodes[NodeB^.Parent].Children[0]:=NodeBID;
    end else begin
     Nodes[NodeB^.Parent].Children[1]:=NodeBID;
    end;
   end else begin
    Root:=NodeBID;
   end;
   if NodeD^.Height>NodeE^.Height then begin
    NodeB^.Children[1]:=NodeDID;
    NodeA^.Children[0]:=NodeEID;
    NodeE^.Parent:=aNodeID;
    NodeA^.AABB:=NodeC^.AABB.Combine(NodeE^.AABB);
    NodeB^.AABB:=NodeA^.AABB.Combine(NodeD^.AABB);
    NodeA^.Height:=1+Max(NodeC^.Height,NodeE^.Height);
    NodeB^.Height:=1+Max(NodeA^.Height,NodeD^.Height);
   end else begin
    NodeB^.Children[1]:=NodeEID;
    NodeA^.Children[0]:=NodeDID;
    NodeD^.Parent:=aNodeID;
    NodeA^.AABB:=NodeC^.AABB.Combine(NodeD^.AABB);
    NodeB^.AABB:=NodeA^.AABB.Combine(NodeE^.AABB);
    NodeA^.Height:=1+Max(NodeC^.Height,NodeD^.Height);
    NodeB^.Height:=1+Max(NodeA^.Height,NodeE^.Height);
   end;
   result:=NodeBID;
  end else begin
   result:=aNodeID;
  end;
 end;
end;

procedure TpvVectorPathBVHDynamicAABBTree.InsertLeaf(const aLeaf:TpvSizeInt);
var Node:PTreeNode;
    LeafAABB,CombinedAABB,AABB:TpvVectorPathBoundingBox;
    Index,Sibling,OldParent,NewParent:TpvSizeInt;
    Children:array[0..1] of TpvSizeInt;
    CombinedCost,Cost,InheritanceCost:TpvDouble;
    Costs:array[0..1] of TpvDouble;
begin
 inc(InsertionCount);
 if Root<0 then begin
  Root:=aLeaf;
  Nodes[aLeaf].Parent:=NULLNODE;
 end else begin
  LeafAABB:=Nodes[aLeaf].AABB;
  Index:=Root;
  while Nodes[Index].Children[0]>=0 do begin

   Children[0]:=Nodes[Index].Children[0];
   Children[1]:=Nodes[Index].Children[1];

   CombinedAABB:=Nodes[Index].AABB.Combine(LeafAABB);
   CombinedCost:=CombinedAABB.Cost;
   Cost:=CombinedCost*2.0;
   InheritanceCost:=2.0*(CombinedCost-Nodes[Index].AABB.Cost);

   AABB:=LeafAABB.Combine(Nodes[Children[0]].AABB);
   if Nodes[Children[0]].Children[0]<0 then begin
    Costs[0]:=AABB.Cost+InheritanceCost;
   end else begin
    Costs[0]:=(AABB.Cost-Nodes[Children[0]].AABB.Cost)+InheritanceCost;
   end;

   AABB:=LeafAABB.Combine(Nodes[Children[1]].AABB);
   if Nodes[Children[1]].Children[1]<0 then begin
    Costs[1]:=AABB.Cost+InheritanceCost;
   end else begin
    Costs[1]:=(AABB.Cost-Nodes[Children[1]].AABB.Cost)+InheritanceCost;
   end;

   if (Cost<Costs[0]) and (Cost<Costs[1]) then begin
    break;
   end else begin
    if Costs[0]<Costs[1] then begin
     Index:=Children[0];
    end else begin
     Index:=Children[1];
    end;
   end;

  end;

  Sibling:=Index;

  OldParent:=Nodes[Sibling].Parent;
  NewParent:=AllocateNode;
  Nodes[NewParent].Parent:=OldParent;
  Nodes[NewParent].UserData:=0;
  Nodes[NewParent].AABB:=LeafAABB.Combine(Nodes[Sibling].AABB);
  Nodes[NewParent].Height:=Nodes[Sibling].Height+1;

  if OldParent>=0 then begin
   if Nodes[OldParent].Children[0]=Sibling then begin
    Nodes[OldParent].Children[0]:=NewParent;
   end else begin
    Nodes[OldParent].Children[1]:=NewParent;
   end;
   Nodes[NewParent].Children[0]:=Sibling;
   Nodes[NewParent].Children[1]:=aLeaf;
   Nodes[Sibling].Parent:=NewParent;
   Nodes[aLeaf].Parent:=NewParent;
  end else begin
   Nodes[NewParent].Children[0]:=Sibling;
   Nodes[NewParent].Children[1]:=aLeaf;
   Nodes[Sibling].Parent:=NewParent;
   Nodes[aLeaf].Parent:=NewParent;
   Root:=NewParent;
  end;

  Index:=Nodes[aLeaf].Parent;
  while Index>=0 do begin
   Index:=Balance(Index);
   Node:=@Nodes[Index];
   Node^.AABB:=Nodes[Node^.Children[0]].AABB.Combine(Nodes[Node^.Children[1]].AABB);
   Node^.Height:=1+Max(Nodes[Node^.Children[0]].Height,Nodes[Node^.Children[1]].Height);
   Index:=Node^.Parent;
  end;

 end;
end;

procedure TpvVectorPathBVHDynamicAABBTree.RemoveLeaf(const aLeaf:TpvSizeInt);
var Node:PTreeNode;
    Parent,GrandParent,Sibling,Index:TpvSizeInt;
begin
 if Root=aLeaf then begin
  Root:=NULLNODE;
 end else begin
  Parent:=Nodes[aLeaf].Parent;
  GrandParent:=Nodes[Parent].Parent;
  if Nodes[Parent].Children[0]=aLeaf then begin
   Sibling:=Nodes[Parent].Children[1];
  end else begin
   Sibling:=Nodes[Parent].Children[0];
  end;
  if GrandParent>=0 then begin
   if Nodes[GrandParent].Children[0]=Parent then begin
    Nodes[GrandParent].Children[0]:=Sibling;
   end else begin
    Nodes[GrandParent].Children[1]:=Sibling;
   end;
   Nodes[Sibling].Parent:=GrandParent;
   FreeNode(Parent);
   Index:=GrandParent;
   while Index>=0 do begin
    Index:=Balance(Index);
    Node:=@Nodes[Index];
    Node^.AABB:=Nodes[Node^.Children[0]].AABB.Combine(Nodes[Node^.Children[1]].AABB);
    Node^.Height:=1+Max(Nodes[Node^.Children[0]].Height,Nodes[Node^.Children[1]].Height);
    Index:=Node^.Parent;
   end;
  end else begin
   Root:=Sibling;
   Nodes[Sibling].Parent:=NULLNODE;
   FreeNode(Parent);
  end;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.CreateProxy(const aAABB:TpvVectorPathBoundingBox;const aUserData:TpvPtrInt):TpvSizeInt;
var Node:PTreeNode;
begin
 result:=AllocateNode;
 Node:=@Nodes[result];
 Node^.AABB.Min:=aAABB.Min-ThresholdAABBVector;
 Node^.AABB.Max:=aAABB.Max+ThresholdAABBVector;
 Node^.UserData:=aUserData;
 Node^.Height:=0;
 InsertLeaf(result);
end;

procedure TpvVectorPathBVHDynamicAABBTree.DestroyProxy(const aNodeID:TpvSizeInt);
begin
 RemoveLeaf(aNodeID);
 FreeNode(aNodeID);
end;

function TpvVectorPathBVHDynamicAABBTree.MoveProxy(const aNodeID:TpvSizeInt;const aAABB:TpvVectorPathBoundingBox;const aDisplacement:TpvVectorPathVector):boolean;
var Node:PTreeNode;
    b:TpvVectorPathBoundingBox;
    d:TpvVectorPathVector;
begin
 Node:=@Nodes[aNodeID];
 result:=not Node^.AABB.Contains(aAABB);
 if result then begin
  RemoveLeaf(aNodeID);
  b.Min:=aAABB.Min-ThresholdAABBVector;
  b.Max:=aAABB.Max+ThresholdAABBVector;
  d:=aDisplacement*AABBMULTIPLIER;
  if d.x<0.0 then begin
   b.Min.x:=b.Min.x+d.x;
  end else if d.x>0.0 then begin
   b.Max.x:=b.Max.x+d.x;
  end;
  if d.y<0.0 then begin
   b.Min.y:=b.Min.y+d.y;
  end else if d.y>0.0 then begin
   b.Max.y:=b.Max.y+d.y;
  end;
  Node^.AABB:=b;
  InsertLeaf(aNodeID);
 end;
end;

procedure TpvVectorPathBVHDynamicAABBTree.Rebalance(const aIterations:TpvSizeInt);
var Counter,Node:TpvSizeInt;
    Bit:TpvSizeUInt;
//  Children:PSizeIntArray;
begin
 if (Root>=0) and (Root<NodeCount) then begin
  for Counter:=1 to aIterations do begin
   Bit:=0;
   Node:=Root;
   while Nodes[Node].Children[0]>=0 do begin
    Node:=Nodes[Node].Children[(Path shr Bit) and 1];
    Bit:=(Bit+1) and 31;
   end;
   inc(Path);
   if ((Node>=0) and (Node<NodeCount)) and (Nodes[Node].Children[0]<0) then begin
    RemoveLeaf(Node);
    InsertLeaf(Node);
   end else begin
    break;
   end;
  end;
 end;
end;

procedure TpvVectorPathBVHDynamicAABBTree.RebuildBottomUp;
var Count,IndexA,IndexB,IndexAMin,IndexBMin,Index1,Index2,ParentIndex:TpvSizeint;
    NewNodes:array of TpvSizeInt;
    Children:array[0..1] of TpvVectorPathBVHDynamicAABBTree.PTreeNode;
    Parent:TpvVectorPathBVHDynamicAABBTree.PTreeNode;
    MinCost,Cost:TpvDouble;
    AABBa,AABBb:PpvVectorPathBoundingBox;
    AABB:TpvVectorPathBoundingBox;
    First:boolean;
begin
 if NodeCount>0 then begin
  NewNodes:=nil;
  try
   SetLength(NewNodes,NodeCount);
   FillChar(NewNodes[0],NodeCount*SizeOf(TpvSizeint),#0);
   Count:=0;
   for IndexA:=0 to NodeCapacity-1 do begin
    if Nodes[IndexA].Height>=0 then begin
     if Nodes[IndexA].Children[0]<0 then begin
      Nodes[IndexA].Parent:=TpvVectorPathBVHDynamicAABBTree.NULLNODE;
      NewNodes[Count]:=IndexA;
      inc(Count);
     end else begin
      FreeNode(IndexA);
     end;
    end;
   end;
   while Count>1 do begin
    First:=true;
    MinCost:=MAX_SCALAR;
    IndexAMin:=-1;
    IndexBMin:=-1;
  {}/////////////////TOOPTIMIZE///////////////////
  {}for IndexA:=0 to Count-1 do begin           //
  {} AABBa:=@Nodes[NewNodes[IndexA]].AABB;      //
  {} for IndexB:=IndexA+1 to Count-1 do begin   //
  {}  AABBb:=@Nodes[NewNodes[IndexB]].AABB;     //
  {}  AABB:=AABBa^.Combine(AABBb^);             //
  {}  Cost:=AABB.Cost;                          //
  {}  if First or (Cost<MinCost) then begin     //
  {}   First:=false;                            //
  {}   MinCost:=Cost;                           //
  {}   IndexAMin:=IndexA;                       //
  {}   IndexBMin:=IndexB;                       //
  {}  end;                                      //
  {} end;                                       //
  {}end;                                        //
  {}/////////////////TOOPTIMIZE///////////////////
    Index1:=NewNodes[IndexAMin];
    Index2:=NewNodes[IndexBMin];
    Children[0]:=@Nodes[Index1];
    Children[1]:=@Nodes[Index2];
    ParentIndex:=AllocateNode;
    Parent:=@Nodes[ParentIndex];
    Parent^.Children[0]:=Index1;
    Parent^.Children[1]:=Index2;
    Parent^.Height:=1+Max(Children[0]^.Height,Children[1]^.Height);
    Parent^.AABB:=Children[0]^.AABB.Combine(Children[1]^.AABB);
    Parent^.Parent:=TpvVectorPathBVHDynamicAABBTree.NULLNODE;
    Children[0]^.Parent:=ParentIndex;
    Children[1]^.Parent:=ParentIndex;
    NewNodes[IndexBMin]:=NewNodes[Count-1];
    NewNodes[IndexAMin]:=ParentIndex;
    dec(Count);
   end;
   Root:=NewNodes[0];
  finally
   NewNodes:=nil;
  end;
 end;
end;

procedure TpvVectorPathBVHDynamicAABBTree.RebuildTopDown;
type TLeafNodes=array of TpvSizeInt;
     TFillStackItem=record
      Parent:TpvSizeInt;
      Which:TpvSizeInt;
      LeafNodes:TLeafNodes;
     end;
     TFillStack=TpvDynamicStack<TFillStackItem>;
     THeightStackItem=record
      Node:TpvSizeInt;
      Pass:TpvSizeInt;
     end;
     THeightStack=TpvDynamicStack<THeightStackItem>;
var Count,Index,MinPerSubTree,ParentIndex,NodeIndex,SplitAxis,TempIndex,
    LeftIndex,RightIndex,LeftCount,RightCount:TpvSizeint;
    LeafNodes:TLeafNodes;
    SplitValue:TpvDouble;
    AABB:TpvVectorPathBoundingBox;
    Center:TpvVectorPathVector;
    VarianceX,VarianceY,MeanX,MeanY:TpvDouble;
    FillStack:TFillStack;
    FillStackItem,NewFillStackItem:TFillStackItem;
    HeightStack:THeightStack;
    HeightStackItem,NewHeightStackItem:THeightStackItem;
begin

 if NodeCount>0 then begin

  LeafNodes:=nil;
  try

   SetLength(LeafNodes,NodeCount);
   FillChar(LeafNodes[0],NodeCount*SizeOf(TpvSizeint),#0);

   Count:=0;
   for Index:=0 to NodeCapacity-1 do begin
    if Nodes[Index].Height>=0 then begin
     if Nodes[Index].Children[0]<0 then begin
      Nodes[Index].Parent:=TpvVectorPathBVHDynamicAABBTree.NULLNODE;
      LeafNodes[Count]:=Index;
      inc(Count);
     end else begin
      FreeNode(Index);
     end;
    end;
   end;

   Root:=TpvVectorPathBVHDynamicAABBTree.NULLNODE;

   if Count>0 then begin

    FillStack.Initialize;
    try

     NewFillStackItem.Parent:=TpvVectorPathBVHDynamicAABBTree.NULLNODE;
     NewFillStackItem.Which:=-1;
     NewFillStackItem.LeafNodes:=copy(LeafNodes,0,Count);
     FillStack.Push(NewFillStackItem);

     while FillStack.Pop(FillStackItem) do begin

      case length(FillStackItem.LeafNodes) of

       0:begin
       end;

       1:begin
        NodeIndex:=FillStackItem.LeafNodes[0];
        ParentIndex:=FillStackItem.Parent;
        Nodes[NodeIndex].Parent:=ParentIndex;
        if (FillStackItem.Which>=0) and (ParentIndex>=0) then begin
         Nodes[ParentIndex].Children[FillStackItem.Which]:=NodeIndex;
        end else begin
         Root:=NodeIndex;
        end;
       end;
       else begin

        NodeIndex:=AllocateNode;

        ParentIndex:=FillStackItem.Parent;

        Nodes[NodeIndex].Parent:=ParentIndex;

        if (FillStackItem.Which>=0) and (ParentIndex>=0) then begin
         Nodes[ParentIndex].Children[FillStackItem.Which]:=NodeIndex;
        end else begin
         Root:=NodeIndex;
        end;

        AABB:=Nodes[FillStackItem.LeafNodes[0]].AABB;
        for Index:=1 to length(FillStackItem.LeafNodes)-1 do begin
         AABB:=AABB.Combine(Nodes[FillStackItem.LeafNodes[Index]].AABB);
        end;

        Nodes[NodeIndex].AABB:=AABB;

        MeanX:=0.0;
        MeanY:=0.0;
        for Index:=0 to length(FillStackItem.LeafNodes)-1 do begin
         Center:=Nodes[FillStackItem.LeafNodes[Index]].AABB.Center;
         MeanX:=MeanX+Center.x;
         MeanY:=MeanY+Center.y;
        end;
        MeanX:=MeanX/length(FillStackItem.LeafNodes);
        MeanY:=MeanY/length(FillStackItem.LeafNodes);

        VarianceX:=0.0;
        VarianceY:=0.0;
        for Index:=0 to length(FillStackItem.LeafNodes)-1 do begin
         Center:=Nodes[FillStackItem.LeafNodes[Index]].AABB.Center;
         VarianceX:=VarianceX+sqr(Center.x-MeanX);
         VarianceY:=VarianceY+sqr(Center.y-MeanY);
        end;
        VarianceX:=VarianceX/length(FillStackItem.LeafNodes);
        VarianceY:=VarianceY/length(FillStackItem.LeafNodes);

        if VarianceX<VarianceY then begin
         SplitAxis:=1;
         SplitValue:=MeanY;
        end else begin
         SplitAxis:=0;
         SplitValue:=MeanX;
        end;

        LeftIndex:=0;
        RightIndex:=length(FillStackItem.LeafNodes);
        LeftCount:=0;
        RightCount:=0;
        while LeftIndex<RightIndex do begin
         Center:=Nodes[FillStackItem.LeafNodes[LeftIndex]].AABB.Center;
         if Center.xy[SplitAxis]<=SplitValue then begin
          inc(LeftIndex);
          inc(LeftCount);
         end else begin
          dec(RightIndex);
          inc(RightCount);
          TempIndex:=FillStackItem.LeafNodes[LeftIndex];
          FillStackItem.LeafNodes[LeftIndex]:=FillStackItem.LeafNodes[RightIndex];
          FillStackItem.LeafNodes[RightIndex]:=TempIndex;
         end;
        end;

        MinPerSubTree:=(TpvInt64(length(FillStackItem.LeafNodes)+1)*341) shr 10;
        if (LeftCount=0) or
           (RightCount=0) or
           (LeftCount<=MinPerSubTree) or
           (RightCount<=MinPerSubTree) then begin
         RightIndex:=(length(FillStackItem.LeafNodes)+1) shr 1;
        end;

        begin
         NewFillStackItem.Parent:=NodeIndex;
         NewFillStackItem.Which:=1;
         NewFillStackItem.LeafNodes:=copy(FillStackItem.LeafNodes,RightIndex,length(FillStackItem.LeafNodes)-RightIndex);
         FillStack.Push(NewFillStackItem);
        end;

        begin
         NewFillStackItem.Parent:=NodeIndex;
         NewFillStackItem.Which:=0;
         NewFillStackItem.LeafNodes:=copy(FillStackItem.LeafNodes,0,RightIndex);
         FillStack.Push(NewFillStackItem);
        end;

        FillStackItem.LeafNodes:=nil;

       end;
      end;
     end;

    finally
     FillStack.Finalize;
    end;

    HeightStack.Initialize;
    try

     NewHeightStackItem.Node:=Root;
     NewHeightStackItem.Pass:=0;
     HeightStack.Push(NewHeightStackItem);

     while HeightStack.Pop(HeightStackItem) do begin
      case HeightStackItem.Pass of
       0:begin
        NewHeightStackItem.Node:=HeightStackItem.Node;
        NewHeightStackItem.Pass:=1;
        HeightStack.Push(NewHeightStackItem);
        if Nodes[HeightStackItem.Node].Children[1]>=0 then begin
         NewHeightStackItem.Node:=Nodes[HeightStackItem.Node].Children[1];
         NewHeightStackItem.Pass:=0;
         HeightStack.Push(NewHeightStackItem);
        end;
        if Nodes[HeightStackItem.Node].Children[0]>=0 then begin
         NewHeightStackItem.Node:=Nodes[HeightStackItem.Node].Children[0];
         NewHeightStackItem.Pass:=0;
         HeightStack.Push(NewHeightStackItem);
        end;
       end;
       1:begin
        if (Nodes[HeightStackItem.Node].Children[0]<0) and (Nodes[HeightStackItem.Node].Children[1]<0) then begin
         Nodes[HeightStackItem.Node].Height:=1;
        end else begin
         Nodes[HeightStackItem.Node].Height:=1+Max(Nodes[Nodes[HeightStackItem.Node].Children[0]].Height,Nodes[Nodes[HeightStackItem.Node].Children[1]].Height);
        end;
       end;
      end;
     end;

    finally
     HeightStack.Finalize;
    end;

   end;

  finally

   LeafNodes:=nil;

  end;

 end;

end;

procedure TpvVectorPathBVHDynamicAABBTree.Rebuild;
begin
 if NodeCount<128 then begin
  RebuildBottomUp;
 end else begin
  RebuildTopDown;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.ComputeHeight:TpvSizeInt;
type TStackItem=record
      NodeID:TpvSizeInt;
      Height:TpvSizeInt;
     end;
     TStack=TpvDynamicStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvVectorPathBVHDynamicAABBTree.PTreeNode;
begin
 result:=0;
 if (NodeCount>0) and (Root>=0) then begin
  Stack.Initialize;
  try
   NewStackItem.NodeID:=Root;
   NewStackItem.Height:=1;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@Nodes[StackItem.NodeID];
    if result<StackItem.Height then begin
     result:=StackItem.Height;
    end;
    if Node^.Children[1]>=0 then begin
     NewStackItem.NodeID:=Node^.Children[1];
     NewStackItem.Height:=StackItem.Height+1;
     Stack.Push(NewStackItem);
    end;
    if Node^.Children[0]>=0 then begin
     NewStackItem.NodeID:=Node^.Children[0];
     NewStackItem.Height:=StackItem.Height+1;
     Stack.Push(NewStackItem);
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.GetHeight:TpvSizeInt;
begin
 if Root>=0 then begin
  result:=Nodes[Root].Height;
 end else begin
  result:=0;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.GetAreaRatio:TpvDouble;
var NodeID:TpvSizeInt;
    Node:TpvVectorPathBVHDynamicAABBTree.PTreeNode;
begin
 result:=0.0;
 if Root>=0 then begin
  for NodeID:=0 to NodeCount-1 do begin
   Node:=@Nodes[NodeID];
   if Node^.Height>=0 then begin
    result:=result+Node^.AABB.Cost;
   end;
  end;
  result:=result/Nodes[Root].AABB.Cost;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.GetMaxBalance:TpvSizeInt;
var NodeID,Balance:TpvSizeInt;
    Node:TpvVectorPathBVHDynamicAABBTree.PTreeNode;
begin
 result:=0;
 if Root>=0 then begin
  for NodeID:=0 to NodeCount-1 do begin
   Node:=@Nodes[NodeID];
   if (Node^.Height>1) and (Node^.Children[0]>=0) and (Node^.Children[1]>=0) then begin
    Balance:=abs(Nodes[Node^.Children[0]].Height-Nodes[Node^.Children[1]].Height);
    if result<Balance then begin
     result:=Balance;
    end;
   end;
  end;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.ValidateStructure:boolean;
type TStackItem=record
      NodeID:TpvSizeInt;
      Parent:TpvSizeInt;
     end;
     TStack=TpvDynamicStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvVectorPathBVHDynamicAABBTree.PTreeNode;
begin
 result:=true;
 if (NodeCount>0) and (Root>=0) and (Root<NodeCount) then begin
  Stack.Initialize;
  try
   NewStackItem.NodeID:=Root;
   NewStackItem.Parent:=TpvVectorPathBVHDynamicAABBTree.NULLNODE;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@Nodes[StackItem.NodeID];
    if Node^.Parent<>StackItem.Parent then begin
     result:=false;
     break;
    end else begin
     if (Node^.Children[1]>=0) and (Node^.Children[1]<NodeCount) then begin
      NewStackItem.NodeID:=Node^.Children[1];
      NewStackItem.Parent:=StackItem.NodeID;
      Stack.Push(NewStackItem);
     end;
     if (Node^.Children[0]>=0) and (Node^.Children[0]<NodeCount) then begin
      NewStackItem.NodeID:=Node^.Children[0];
      NewStackItem.Parent:=StackItem.NodeID;
      Stack.Push(NewStackItem);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.ValidateMetrics:boolean;
type TStackItem=record
      NodeID:TpvSizeInt;
     end;
     TStack=TpvDynamicStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvVectorPathBVHDynamicAABBTree.PTreeNode;
begin
 result:=true;
 if (NodeCount>0) and (Root>=0) and (Root<NodeCount) then begin
  Stack.Initialize;
  try
   NewStackItem.NodeID:=Root;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@Nodes[StackItem.NodeID];
    if (((Node^.Children[0]<0) or (Node^.Children[0]>=NodeCount)) or
        ((Node^.Children[1]<0) or (Node^.Children[1]>=NodeCount))) or
       (Node^.Height<>(1+Max(Nodes[Node^.Children[0]].Height,Nodes[Node^.Children[1]].Height))) then begin
     result:=false;
     break;
    end else begin
     if (Node^.Children[1]>=0) and (Node^.Children[1]<NodeCount) then begin
      NewStackItem.NodeID:=Node^.Children[1];
      Stack.Push(NewStackItem);
     end;
     if (Node^.Children[0]>=0) and (Node^.Children[0]<NodeCount) then begin
      NewStackItem.NodeID:=Node^.Children[0];
      Stack.Push(NewStackItem);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.Validate:boolean;
var NodeID,FreeCount:TpvSizeInt;
begin
 result:=ValidateStructure;
 if result then begin
  result:=ValidateMetrics;
  if result then begin
   result:=ComputeHeight=GetHeight;
   if result then begin
    NodeID:=FreeList;
    FreeCount:=0;
    while NodeID>=0 do begin
     NodeID:=Nodes[NodeID].Next;
     inc(FreeCount);
    end;
    result:=(NodeCount+FreeCount)=NodeCapacity;
   end;
  end;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.IntersectionQuery(const aAABB:TpvVectorPathBoundingBox):TpvVectorPathBVHDynamicAABBTree.TUserDataArray;
type TStackItem=record
      NodeID:TpvSizeInt;
     end;
     TStack=TpvDynamicStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvVectorPathBVHDynamicAABBTree.PTreeNode;
begin
 result:=nil;
 if (NodeCount>0) and (Root>=0) then begin
  Stack.Initialize;
  try
   NewStackItem.NodeID:=Root;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@Nodes[StackItem.NodeID];
    if Node^.AABB.Intersect(aAABB) then begin
     if Node^.UserData<>0 then begin
      result:=result+[Node^.UserData];
     end;
     if (Node^.Children[1]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[1];
      Stack.Push(NewStackItem);
     end;
     if (Node^.Children[0]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[0];
      Stack.Push(NewStackItem);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.ContainQuery(const aAABB:TpvVectorPathBoundingBox):TpvVectorPathBVHDynamicAABBTree.TUserDataArray;
type TStackItem=record
      NodeID:TpvSizeInt;
     end;
     TStack=TpvDynamicStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvVectorPathBVHDynamicAABBTree.PTreeNode;
begin
 result:=nil;
 if (NodeCount>0) and (Root>=0) then begin
  Stack.Initialize;
  try
   NewStackItem.NodeID:=Root;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@Nodes[StackItem.NodeID];
    if Node^.AABB.Contains(aAABB) then begin
     if Node^.UserData<>0 then begin
      result:=result+[Node^.UserData];
     end;
     if (Node^.Children[1]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[1];
      Stack.Push(NewStackItem);
     end;
     if (Node^.Children[0]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[0];
      Stack.Push(NewStackItem);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.ContainQuery(const aPoint:TpvVectorPathVector):TpvVectorPathBVHDynamicAABBTree.TUserDataArray;
type TStackItem=record
      NodeID:TpvSizeInt;
     end;
     TStack=TpvDynamicStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvVectorPathBVHDynamicAABBTree.PTreeNode;
begin
 result:=nil;
 if (NodeCount>0) and (Root>=0) then begin
  Stack.Initialize;
  try
   NewStackItem.NodeID:=Root;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@Nodes[StackItem.NodeID];
    if Node^.AABB.Contains(aPoint) then begin
     if Node^.UserData<>0 then begin
      result:=result+[Node^.UserData];
     end;
     if (Node^.Children[1]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[1];
      Stack.Push(NewStackItem);
     end;
     if (Node^.Children[0]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[0];
      Stack.Push(NewStackItem);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.RayCast(const aRayOrigin,aRayDirection:TpvVectorPathVector;out aTime:TpvDouble;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvVectorPathBVHDynamicAABBTree.TRayCastUserData):boolean;
type TStackItem=record
      NodeID:TpvSizeInt;
     end;
     TStack=TpvDynamicStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvVectorPathBVHDynamicAABBTree.PTreeNode;
    RayEnd:TpvVectorPathVector;
    Time:TpvDouble;
    Stop:boolean;
begin
 result:=false;
 if assigned(aRayCastUserData) and (NodeCount>0) and (Root>=0) then begin
  aTime:=Infinity;
  RayEnd:=aRayOrigin;
  Stack.Initialize;
  try
   NewStackItem.NodeID:=Root;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@Nodes[StackItem.NodeID];
    if ((not result) and
        (Node^.AABB.Contains(aRayOrigin) or Node^.AABB.FastRayIntersection(aRayOrigin,aRayDirection))) or
       (result and Node^.AABB.LineIntersection(aRayOrigin,RayEnd)) then begin
     if (Node^.UserData<>0) and aRayCastUserData(Node^.UserData,aRayOrigin,aRayDirection,Time,Stop) then begin
      if (not result) or (Time<aTime) then begin
       aTime:=Time;
       aUserData:=Node^.UserData;
       result:=true;
       if aStopAtFirstHit or Stop then begin
        break;
       end else begin
        RayEnd:=aRayOrigin+(aRayDirection*Time);
       end;
      end;
     end;
     if (Node^.Children[1]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[1];
      Stack.Push(NewStackItem);
     end;
     if (Node^.Children[0]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[0];
      Stack.Push(NewStackItem);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
end;

function TpvVectorPathBVHDynamicAABBTree.RayCastLine(const aFrom,aTo:TpvVectorPathVector;out aTime:TpvDouble;out aUserData:TpvUInt32;const aStopAtFirstHit:boolean;const aRayCastUserData:TpvVectorPathBVHDynamicAABBTree.TRayCastUserData):boolean;
type TStackItem=record
      NodeID:TpvSizeInt;
     end;
     TStack=TpvDynamicStack<TStackItem>;
var Stack:TStack;
    StackItem,NewStackItem:TStackItem;
    Node:TpvVectorPathBVHDynamicAABBTree.PTreeNode;
    Time,RayLength:TpvDouble;
    RayOrigin,RayDirection,RayEnd:TpvVectorPathVector;
    Stop:boolean;
begin
 result:=false;
 if assigned(aRayCastUserData) and (NodeCount>0) and (Root>=0) then begin
  aTime:=Infinity;
  RayOrigin:=aFrom;
  RayEnd:=aTo;
  RayDirection:=(RayEnd-RayOrigin).Normalize;
  RayLength:=(RayEnd-RayOrigin).Length;
  Stack.Initialize;
  try
   NewStackItem.NodeID:=Root;
   Stack.Push(NewStackItem);
   while Stack.Pop(StackItem) do begin
    Node:=@Nodes[StackItem.NodeID];
    if Node^.AABB.LineIntersection(RayOrigin,RayEnd) then begin
     if (Node^.UserData<>0) and aRayCastUserData(Node^.UserData,RayOrigin,RayDirection,Time,Stop) then begin
      if ((Time>=0.0) and (Time<=RayLength)) and ((not result) or (Time<aTime)) then begin
       aTime:=Time;
       aUserData:=Node^.UserData;
       result:=true;
       if aStopAtFirstHit or Stop then begin
        break;
       end else begin
        RayEnd:=RayOrigin+(RayDirection*Time);
        RayLength:=Time;
       end;
      end;
     end;
     if (Node^.Children[1]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[1];
      Stack.Push(NewStackItem);
     end;
     if (Node^.Children[0]>=0) then begin
      NewStackItem.NodeID:=Node^.Children[0];
      Stack.Push(NewStackItem);
     end;
    end;
   end;
  finally
   Stack.Finalize;
  end;
 end;
end;

procedure TpvVectorPathBVHDynamicAABBTree.GetSkipListNodes(var aSkipListNodeArray:TSkipListNodeArray;const aGetUserDataIndex:TpvVectorPathBVHDynamicAABBTree.TGetUserDataIndex);
//const ThresholdVector:TpvVectorPathVector=(x:1e-7;y:1e-7);
var StackItem,NewStackItem:TSkipListNodeStackItem;
    Node:PTreeNode;
    SkipListNode:TSkipListNode;
    SkipListNodeIndex:TpvSizeInt;
begin
 fSkipListNodeLock.Acquire;
 try
  if Root>=0 then begin
   if length(fSkipListNodeMap)<length(Nodes) then begin
    SetLength(fSkipListNodeMap,(length(Nodes)*3) shr 1);
   end;
   aSkipListNodeArray.Count:=0;
   NewStackItem.Pass:=0;
   NewStackItem.Node:=Root;
   fSkipListNodeStack.Push(NewStackItem);
   while fSkipListNodeStack.Pop(StackItem) do begin
    case StackItem.Pass of
     0:begin
      if StackItem.Node>=0 then begin
       Node:=@Nodes[StackItem.Node];
       SkipListNode.AABBMin.x:=Node^.AABB.Min.x;
       SkipListNode.AABBMin.y:=Node^.AABB.Min.y;
       SkipListNode.AABBMax.x:=Node^.AABB.Max.x;
       SkipListNode.AABBMax.y:=Node^.AABB.Max.y;
       SkipListNode.SkipCount:=0;
       if Node^.UserData<>0 then begin
        if assigned(aGetUserDataIndex) then begin
         SkipListNode.UserData:=aGetUserDataIndex(Node^.UserData);
        end else begin
         SkipListNode.UserData:=Node^.UserData;
        end;
       end else begin
        SkipListNode.UserData:=High(TpvUInt32);
       end;
       SkipListNodeIndex:=aSkipListNodeArray.Add(SkipListNode);
       fSkipListNodeMap[StackItem.Node]:=SkipListNodeIndex;
       NewStackItem.Pass:=1;
       NewStackItem.Node:=StackItem.Node;
       fSkipListNodeStack.Push(NewStackItem);
       if Node^.Children[1]>=0 then begin
        NewStackItem.Pass:=0;
        NewStackItem.Node:=Node^.Children[1];
        fSkipListNodeStack.Push(NewStackItem);
       end;
       if Node^.Children[0]>=0 then begin
        NewStackItem.Pass:=0;
        NewStackItem.Node:=Node^.Children[0];
        fSkipListNodeStack.Push(NewStackItem);
       end;
      end;
     end;
     1:begin
      if StackItem.Node>=0 then begin
       SkipListNodeIndex:=fSkipListNodeMap[StackItem.Node];
       aSkipListNodeArray.Items[SkipListNodeIndex].SkipCount:=aSkipListNodeArray.Count-SkipListNodeIndex;
      end;
     end;
    end;
   end;
  end;
 finally
  fSkipListNodeLock.Release;
 end;
end;

{ TpvVectorPathCommand }

constructor TpvVectorPathCommand.Create(const aCommandType:TpvVectorPathCommandType;
                                        const aX0:TpvDouble=0.0;
                                        const aY0:TpvDouble=0.0;
                                        const aX1:TpvDouble=0.0;
                                        const aY1:TpvDouble=0.0;
                                        const aX2:TpvDouble=0.0;
                                        const aY2:TpvDouble=0.0);
begin
 inherited Create;
 fCommandType:=aCommandType;
 fX0:=aX0;
 fY0:=aY0;
 fX1:=aX1;
 fY1:=aY1;
 fX2:=aX2;
 fY2:=aY2;
end;

procedure GetIntersectionPointsForLineLine(const aSegment0,aSegment1:TpvVectorPathSegmentLine;const aIntersectionPoints:TpvVectorPathVectorList);
var a,b,Determinant:TpvDouble;
begin
 Determinant:=((aSegment1.Points[1].y-aSegment1.Points[0].y)*(aSegment0.Points[1].x-aSegment0.Points[0].x))-((aSegment1.Points[1].x-aSegment1.Points[0].x)*(aSegment0.Points[1].y-aSegment0.Points[0].y));
 if not IsZero(Determinant) then begin
  a:=(((aSegment1.Points[1].x-aSegment1.Points[0].x)*(aSegment0.Points[0].y-aSegment1.Points[0].y))-((aSegment1.Points[1].y-aSegment1.Points[0].y)*(aSegment0.Points[0].x-aSegment1.Points[0].x)))/Determinant;
  b:=(((aSegment0.Points[1].x-aSegment0.Points[0].x)*(aSegment0.Points[0].y-aSegment1.Points[0].y))-((aSegment0.Points[1].y-aSegment0.Points[0].y)*(aSegment0.Points[0].x-aSegment1.Points[0].x)))/Determinant;
  if ((a>=0.0) and (a<=1.0)) and ((b>=0.0) and (b<=1.0)) then begin
   aIntersectionPoints.Add(aSegment0.Points[0].Lerp(aSegment0.Points[1],a));
  end;
 end;
end;

procedure GetIntersectionPointsForLineQuadraticCurve(const aSegment0:TpvVectorPathSegmentLine;const aSegment1:TpvVectorPathSegmentQuadraticCurve;const aIntersectionPoints:TpvVectorPathVectorList);
var Min_,Max_,c0,c1,c2,n,p:TpvVectorPathVector;
    {a,}cl,t:TpvDouble;
    Roots:TpvDoubleDynamicArray;
//  Roots:array[0..1] of TpvDouble;
    RootIndex,CountRoots:TpvSizeInt;
begin
 Min_:=aSegment0.Points[0].Minimum(aSegment0.Points[1]);
 Max_:=aSegment0.Points[0].Maximum(aSegment0.Points[1]);
 c2:=aSegment1.Points[0]+((aSegment1.Points[1]*(-2.0))+aSegment1.Points[2]);
 c1:=(aSegment1.Points[0]*(-2.0))+(aSegment1.Points[1]*2.0);
 c0:=TpvVectorPathVector.Create(aSegment1.Points[0].x,aSegment1.Points[0].y);
 n:=TpvVectorPathVector.Create(aSegment0.Points[0].y-aSegment0.Points[1].y,aSegment0.Points[1].x-aSegment0.Points[0].x);
 cl:=(aSegment0.Points[0].x*aSegment0.Points[1].y)-(aSegment0.Points[1].x*aSegment0.Points[0].y);
 Roots:=(TpvPolynomial.Create([n.Dot(c2),n.Dot(c1),n.Dot(c0)+cl])).GetRoots;
 try
  CountRoots:=length(Roots);
 {a:=n.Dot(c0)+cl;
  if IsZero(a) then begin
   CountRoots:=0;
  end else begin
   CountRoots:=SolveQuadratic(a,n.Dot(c1)/a,n.Dot(c2)/a,Roots[0],Roots[1]);
  end;}
  for RootIndex:=0 to CountRoots-1 do begin
   t:=Roots[RootIndex];
   if (t>=0.0) and (t<=1.0) then begin
    p:=(aSegment1.Points[0].Lerp(aSegment1.Points[1],t)).Lerp(aSegment1.Points[1].Lerp(aSegment1.Points[2],t),t);
    if SameValue(aSegment0.Points[0].x,aSegment0.Points[1].x) then begin
     if (p.y>=Min_.y) and (p.y<=Max_.y) then begin
      aIntersectionPoints.Add(p);
     end;
    end else if SameValue(aSegment0.Points[0].y,aSegment0.Points[1].y) then begin
     if (p.x>=Min_.x) and (p.x<=Max_.x) then begin
      aIntersectionPoints.Add(p);
     end;
    end else if ((p.x>=Min_.x) and (p.x<=Max_.x)) and ((p.y>=Min_.y) and (p.y<=Max_.y)) then begin
     aIntersectionPoints.Add(p);
    end;
   end;
  end;
 finally
  Roots:=nil;
 end;
end;

procedure GetIntersectionPointsForLineCubicCurve(const aSegment0:TpvVectorPathSegmentLine;const aSegment1:TpvVectorPathSegmentCubicCurve;const aIntersectionPoints:TpvVectorPathVectorList);
var Min_,Max_,c0,c1,c2,c3,n,p,p1,p2,p3,p4,p5,p6,p7,p8,p9:TpvVectorPathVector;
    {a,}cl,t:TpvDouble;
    Roots:TpvDoubleDynamicArray;
//  Roots:array[0..2] of TpvDouble;
    RootIndex,CountRoots:TpvSizeInt;
begin
 Min_:=aSegment0.Points[0].Minimum(aSegment0.Points[1]);
 Max_:=aSegment0.Points[0].Maximum(aSegment0.Points[1]);
 p1:=aSegment1.Points[0];
 p2:=aSegment1.Points[1];
 p3:=aSegment1.Points[2];
 p4:=aSegment1.Points[3];
 c0:=p1;
 c1:=(p1*(-3.0))+(p2*3.0);
 c2:=(p1*3.0)+((p2*(-6.0))+(p3*3.0));
 c3:=(p1*(-1.0))+((p2*3.0)+((p3*(-3.0))+p4));
 n:=TpvVectorPathVector.Create(aSegment0.Points[0].y-aSegment0.Points[1].y,aSegment0.Points[1].x-aSegment0.Points[0].x);
 cl:=(aSegment0.Points[0].x*aSegment0.Points[1].y)-(aSegment0.Points[1].x*aSegment0.Points[0].y);
 Roots:=(TpvPolynomial.Create([n.Dot(c3),n.Dot(c2),n.Dot(c1),n.Dot(c0)+cl])).GetRoots;
 try
  CountRoots:=length(Roots);
 {a:=n.Dot(c0)+cl;
  if IsZero(a) then begin
   CountRoots:=0;
  end else begin
   CountRoots:=SolveCubic(a,n.Dot(c1),n.Dot(c2),n.Dot(c3),Roots[0],Roots[1],Roots[2]);
  end;}
  for RootIndex:=0 to CountRoots-1 do begin
   t:=Roots[RootIndex];
   if (t>=0.0) and (t<=1.0) then begin
    p5:=p1.Lerp(p2,t);
    p6:=p2.Lerp(p3,t);
    p7:=p3.Lerp(p4,t);
    p8:=p5.Lerp(p6,t);
    p9:=p6.Lerp(p7,t);
    p:=p8.Lerp(p9,t);
    if SameValue(aSegment0.Points[0].x,aSegment0.Points[1].x) then begin
     if (p.y>=Min_.y) and (p.y<=Max_.y) then begin
      aIntersectionPoints.Add(p);
     end;
    end else if SameValue(aSegment0.Points[0].y,aSegment0.Points[1].y) then begin
     if (p.x>=Min_.x) and (p.x<=Max_.x) then begin
      aIntersectionPoints.Add(p);
     end;
    end else if ((p.x>=Min_.x) and (p.x<=Max_.x)) and ((p.y>=Min_.y) and (p.y<=Max_.y)) then begin
     aIntersectionPoints.Add(p);
    end;
   end;
  end;
 finally
  Roots:=nil;
 end;
end;

procedure GetIntersectionPointsForQuadraticCurveQuadraticCurve(const aSegment0,aSegment1:TpvVectorPathSegmentQuadraticCurve;const aIntersectionPoints:TpvVectorPathVectorList);
var a1,a2,a3,b1,b2,b3,c10,c11,c12,c20,c21,c22:TpvVectorPathVector;
    v0,v1,v2,v3,v4,v5,v6,s,XRoot:TpvDouble;
    Roots,XRoots,YRoots:TpvDoubleDynamicArray;
//  Roots:array[0..3] of TpvDouble;
//  XRoots,YRoots:array[0..1] of TpvDouble;
    CountRoots,CountXRoots,CountYRoots,Index,XIndex,YIndex:TpvSizeInt;
    OK:boolean;
begin
 a1:=aSegment0.Points[0];
 a2:=aSegment0.Points[1];
 a3:=aSegment0.Points[2];
 b1:=aSegment1.Points[0];
 b2:=aSegment1.Points[1];
 b3:=aSegment1.Points[2];
 c10:=a1;
 c11:=(a1*(-2.0))+(a2*2.0);
 c12:=a1+((a2*(-2.0))+a3);
 c20:=b1;
 c21:=(b1*(-2.0))+(b2*2.0);
 c22:=b1+((b2*(-2.0))+b3);
 if IsZero(c12.y) then begin
  v0:=c12.x*(c10.y-c20.y);
  v1:=v0-(c11.x*c11.y);
  v2:=v0+v1;
  v3:=c11.y*c11.y;
  Roots:=(TpvPolynomial.Create([c12.x*c22.y*c22.y,
                               2.0*c12.x*c21.y*c22.y,
                               (((c12.x*c21.y*c21.y)-(c22.x*v3))-(c22.y*v0))-(c22.y*v1),
                               (((-c21.x)*v3)-(c21.y*v0))-(c21.y*v1),
                               ((c10.x-c20.x)*v3)+((c10.y-c20.y)*v1)])).GetRoots;
{ CountRoots:=SolveQuartic(c12.x*c22.y*c22.y,
                           2.0*c12.x*c21.y*c22.y,
                           (((c12.x*c21.y*c21.y)-(c22.x*v3))-(c22.y*v0))-(c22.y*v1),
                           (((-c21.x)*v3)-(c21.y*v0))-(c21.y*v1),
                           ((c10.x-c20.x)*v3)+((c10.y-c20.y)*v1),
                           Roots[0],
                           Roots[1],
                           Roots[2],
                           Roots[3]);}
 end else begin
  v0:=(c12.x*c22.y)-(c12.y*c22.x);
  v1:=(c12.x*c21.y)-(c21.x*c12.y);
  v2:=(c11.x*c12.y)-(c11.y*c12.x);
  v3:=c10.y-c20.y;
  v4:=(c12.y*(c10.x-c20.x))-(c12.x*v3);
  v5:=((-c11.y)*v2)+(c12.y*v4);
  v6:=v2*v2;
  Roots:=(TpvPolynomial.Create([sqr(v0),
                                2.0*v0*v1,
                                ((((-c22.y)*v6)+(c12.y*v1*v1))+(c12.y*v0*v4)+(v0*v5))/c12.y,
                                ((((-c21.y)*v6)+(c12.y*v1*v4))+(v1*v5))/c12.y,
                                ((v3*v6)+(v4*v5))/c12.y])).GetRoots;
{ CountRoots:=SolveQuartic(sqr(v0),
                           2.0*v0*v1,
                           ((((-c22.y)*v6)+(c12.y*v1*v1))+(c12.y*v0*v4)+(v0*v5))/c12.y,
                           ((((-c21.y)*v6)+(c12.y*v1*v4))+(v1*v5))/c12.y,
                           ((v3*v6)+(v4*v5))/c12.y,
                           Roots[0],
                           Roots[1],
                           Roots[2],
                           Roots[3]);}
 end;
 XRoots:=nil;
 YRoots:=nil;
 try
  CountRoots:=length(Roots);
  for Index:=0 to CountRoots-1 do begin
   s:=Roots[Index];
   if (s>=0.0) and (s<=1.0) then begin
    XRoots:=(TpvPolynomial.Create([c12.x,
                                   c11.x,
                                   ((c10.x-c20.x)-(s*c21.x))-(sqr(s)*c22.x)])).GetRoots;
    YRoots:=(TpvPolynomial.Create([c12.y,
                                   c11.y,
                                   ((c10.y-c20.y)-(s*c21.y))-(sqr(s)*c22.y)])).GetRoots;
    CountXRoots:=length(XRoots);
    CountYRoots:=length(YRoots);
{   CountXRoots:=SolveQuadratic(c12.x,
                                c11.x,
                                ((c10.x-c20.x)-(s*c21.x))-(sqr(s)*c22.x),
                                XRoots[0],
                                XRoots[1]
                               );
    CountYRoots:=SolveQuadratic(c12.y,
                                c11.y,
                                ((c10.y-c20.y)-(s*c21.y))-(sqr(s)*c22.y),
                                YRoots[0],
                                YRoots[1]
                               );}
    if (CountXRoots>0) and (CountYRoots>0) then begin
     OK:=false;
     for XIndex:=0 to CountXRoots-1 do begin
      XRoot:=XRoots[XIndex];
      if (XRoot>=0.0) and (XRoot<=1.0) then begin
       for YIndex:=0 to CountYRoots-1 do begin
        if SameValue(XRoot,YRoots[XIndex],1e-4) then begin
         aIntersectionPoints.Add((c22*sqr(s))+(c21*s)+c20);
         OK:=true;
         break;
        end;
       end;
      end;
      if OK then begin
       break;
      end;
     end;
    end;
   end;
  end;
 finally
  Roots:=nil;
  XRoots:=nil;
  YRoots:=nil;
 end;
end;

procedure GetIntersectionPointsForQuadraticCurveCubicCurve(const aSegment0:TpvVectorPathSegmentQuadraticCurve;const aSegment1:TpvVectorPathSegmentCubicCurve;const aIntersectionPoints:TpvVectorPathVectorList);
var a1,a2,a3,b1,b2,b3,b4,
    c10,c11,c12,c20,c21,c22,c23,
    c10s,c11s,c12s,c20s,c21s,c22s,c23s:TpvVectorPathVector;
    PolyCoefs:array[0..6] of TpvDouble;
    Roots,XRoots,YRoots:TpvDoubleDynamicArray;
    //XRoots,YRoots:array[0..1] of TpvDouble;
    CountXRoots,CountYRoots,Index,XIndex,YIndex:TpvSizeInt;
    OK:boolean;
    s,XRoot:TpvDouble;
begin
 a1:=aSegment0.Points[0];
 a2:=aSegment0.Points[1];
 a3:=aSegment0.Points[2];
 b1:=aSegment1.Points[0];
 b2:=aSegment1.Points[1];
 b3:=aSegment1.Points[2];
 b4:=aSegment1.Points[3];
 c10:=a1;
 c11:=(a1*(-2.0))+(a2*2.0);
 c12:=(a1+(a2*(-2.0)))+a3;
 c20:=b1;
 c21:=(b1*(-3.0))+(b2*3.0);
 c22:=((b1*3.0)+(b2*(-6.0)))+(b3*3.0);
 c23:=(((b1*(-1.0))+(b2*3.0))+(b3*(-3.0)))+b4;
 c10s:=c10*c10;
 c11s:=c11*c11;
 c12s:=c12*c12;
 c20s:=c20*c20;
 c21s:=c21*c21;
 c22s:=c22*c22;
 c23s:=c23*c23;
 PolyCoefs[0]:=(((-2.0)*c12.x*c12.y*c23.x*c23.y)+(c12s.x*c23s.y))+(c12s.y*c23s.x);
 PolyCoefs[1]:=((((-2.0)*c12.x*c12.y*c22.x*c23.y)-(2.0*c12.x*c12.y*c22.y*c23.x))+(2.0*c12s.y*c22.x*c23.x))+(2.0*c12s.x*c22.y*c23.y);
 PolyCoefs[2]:=(((((((-2.0)*c12.x*c21.x*c12.y*c23.y)-(2.0*c12.x*c12.y*c21.y*c23.x))-(2.0*c12.x*c12.y*c22.x*c22.y))+(2.0*c21.x*c12s.y*c23.x))+(c12s.y*c22s.x))+(c12s.x*((2.0*c21.y*c23.y)+c22s.y)));
 PolyCoefs[3]:=(((((((((((((((2.0*c10.x*c12.x*c12.y*c23.y)+(2.0*c10.y*c12.x*c12.y*c23.x))+(c11.x*c11.y*c12.x*c23.y))+(c11.x*c11.y*c12.y*c23.x))-(2.0*c20.x*c12.x*c12.y*c23.y))-(2.0*c12.x*c20.y*c12.y*c23.x))-(2.0*c12.x*c21.x*c12.y*c22.y))-(2.0*c12.x*c12.y*c21.y*c22.x))-(2.0*c10.x*c12s.y*c23.x))-(2.0*c10.y*c12s.x*c23.y))+(2.0*c20.x*c12s.y*c23.x))+(2.0*c21.x*c12s.y*c22.x))-(c11s.y*c12.x*c23.x))-(c11s.x*c12.y*c23.y))+(c12s.x*((2.0*c20.y*c23.y)+(2.0*c21.y*c22.y))));
 PolyCoefs[4]:=((((((((((((((2.0*c10.x*c12.x*c12.y*c22.y)+(2.0*c10.y*c12.x*c12.y*c22.x))+(c11.x*c11.y*c12.x*c22.y))+(c11.x*c11.y*c12.y*c22.x))-(2.0*c20.x*c12.x*c12.y*c22.y))-(2.0*c12.x*c20.y*c12.y*c22.x))-(2.0*c12.x*c21.x*c12.y*c21.y))-(2.0*c10.x*c12s.y*c22.x))-(2.0*c10.y*c12s.x*c22.y))+(2.0*c20.x*c12s.y*c22.x))-(c11s.y*c12.x*c22.x))-(c11s.x*c12.y*c22.y))+(c21s.x*c12s.y))+(c12s.x*((2.0*c20.y*c22.y)+c21s.y)));
 PolyCoefs[5]:=(((((((((((2.0*c10.x*c12.x*c12.y*c21.y)+(2.0*c10.y*c12.x*c21.x*c12.y))+(c11.x*c11.y*c12.x*c21.y))+(c11.x*c11.y*c21.x*c12.y)-(2.0*c20.x*c12.x*c12.y*c21.y))-(2.0*c12.x*c20.y*c21.x*c12.y))-(2.0*c10.x*c21.x*c12s.y))-(2.0*c10.y*c12s.x*c21.y))+(2.0*c20.x*c21.x*c12s.y))-(c11s.y*c12.x*c21.x))-(c11s.x*c12.y*c21.y))+(2.0*c12s.x*c20.y*c21.y));
 PolyCoefs[6]:=(((((((((((((((((((-2.0)*c10.x*c10.y*c12.x*c12.y)-(c10.x*c11.x*c11.y*c12.y))-(c10.y*c11.x*c11.y*c12.x))+(2.0*c10.x*c12.x*c20.y*c12.y))+(2.0*c10.y*c20.x*c12.x*c12.y))+(c11.x*c20.x*c11.y*c12.y))+(c11.x*c11.y*c12.x*c20.y))-(2.0*c20.x*c12.x*c20.y*c12.y))-(2.0*c10.x*c20.x*c12s.y))+(c10.x*c11s.y*c12.x))+(c10.y*c11s.x*c12.y))-(2.0*c10.y*c12s.x*c20.y))-(c20.x*c11s.y*c12.x))-(c11s.x*c20.y*c12.y))+(c10s.x*c12s.y))+(c10s.y*c12s.x))+(c20s.x*c12s.y))+(c12s.x*c20s.y));
 Roots:=(TpvPolynomial.Create([PolyCoefs[0],PolyCoefs[1],PolyCoefs[2],PolyCoefs[3],PolyCoefs[4],PolyCoefs[5],PolyCoefs[6]])).GetRootsInInterval(0.0,1.0);
//Roots:=SolveRootsInInterval(PolyCoefs,0.0,1.0);
 XRoots:=nil;
 YRoots:=nil;
 try
  for Index:=0 to length(Roots)-1 do begin
   s:=Roots[Index];
   if (s>=0.0) and (s<=1.0) then begin
    XRoots:=(TpvPolynomial.Create([c12.x,
                                   c11.x,
                                   (((c10.x-c20.x)-(s*c21.x))-(sqr(s)*c22.x))-((sqr(s)*s)*c23.x)])).GetRoots;
    YRoots:=(TpvPolynomial.Create([c12.y,
                                   c11.y,
                                   (((c10.y-c20.y)-(s*c21.y))-(sqr(s)*c22.y))-((sqr(s)*s)*c23.y)])).GetRoots;
    CountXRoots:=length(XRoots);
    CountYRoots:=length(YRoots);
 {  CountXRoots:=SolveQuadratic(c12.x,
                                c11.x,
                                (((c10.x-c20.x)-(s*c21.x))-(sqr(s)*c22.x))-((sqr(s)*s)*c23.x),
                                XRoots[0],
                                XRoots[1]
                               );
    CountYRoots:=SolveQuadratic(c12.y,
                                c11.y,
                                (((c10.x-c20.y)-(s*c21.y))-(sqr(s)*c22.y))-((sqr(s)*s)*c23.y),
                                YRoots[0],
                                YRoots[1]
                               );}
    if (CountXRoots>0) and (CountYRoots>0) then begin
     OK:=false;
     for XIndex:=0 to CountXRoots-1 do begin
      XRoot:=XRoots[XIndex];
      if (XRoot>=0.0) and (XRoot<=1.0) then begin
       for YIndex:=0 to CountYRoots-1 do begin
        if SameValue(XRoot,YRoots[XIndex],1e-4) then begin
         aIntersectionPoints.Add((c23*(sqr(s)*s))+(c22*sqr(s))+(c21*s)+c20);
         OK:=true;
         break;
        end;
       end;
      end;
      if OK then begin
       break;
      end;
     end;
    end;
   end;
  end;
 finally
  Roots:=nil;
  XRoots:=nil;
  YRoots:=nil;
 end;
end;

procedure GetIntersectionPointsForCubicCurveCubicCurve(const aSegment0,aSegment1:TpvVectorPathSegmentCubicCurve;const aIntersectionPoints:TpvVectorPathVectorList);
var a1,a2,a3,a4,b1,b2,b3,b4,
    c10,c11,c12,c13,c20,c21,c22,c23,
    c10s,c11s,c12s,c13s,c20s,c21s,c22s,c23s,
    c10c,c11c,c12c,c13c,c20c,c21c,c22c,c23c:TpvVectorPathVector;
    PolyCoefs:array[0..9] of TpvDouble;
    Roots,XRoots,YRoots:TpvDoubleDynamicArray;
//  XRoots,YRoots:array[0..1] of TpvDouble;
    CountXRoots,CountYRoots,Index,XIndex,YIndex:TpvSizeInt;
    OK:boolean;
    s,XRoot:TpvDouble;
begin
 a1:=aSegment0.Points[0];
 a2:=aSegment0.Points[1];
 a3:=aSegment0.Points[2];
 a4:=aSegment0.Points[3];
 b1:=aSegment1.Points[0];
 b2:=aSegment1.Points[1];
 b3:=aSegment1.Points[2];
 b4:=aSegment1.Points[3];
 c10:=a1;
 c11:=(a1*(-3.0))+(a2*3.0);
 c12:=((a1*3.0)+(a2*(-6.0)))+(a3*3.0);
 c13:=(((a1*(-1.0))+(a2*3.0))+(a3*(-3.0)))+a4;
 c20:=b1;
 c21:=(b1*(-3.0))+(b2*3.0);
 c22:=((b1*3.0)+(b2*(-6.0)))+(b3*3.0);
 c23:=(((b1*(-1.0))+(b2*3.0))+(b3*(-3.0)))+b4;
 c10s:=c10*c10;
 c11s:=c11*c11;
 c12s:=c12*c12;
 c13s:=c13*c13;
 c20s:=c20*c20;
 c21s:=c21*c21;
 c22s:=c22*c22;
 c23s:=c23*c23;
 c10c:=c10s*c10;
 c11c:=c11s*c11;
 c12c:=c12s*c12;
 c13c:=c13s*c13;
 c20c:=c20s*c20;
 c21c:=c21s*c21;
 c22c:=c22s*c22;
 c23c:=c23s*c23;
 PolyCoefs[0]:=-c13c.x*c23c.y+c13c.y*c23c.x-3*c13.x*c13s.y*c23s.x*c23.y+3*c13s.x*c13.y*c23.x*c23s.y;
 PolyCoefs[1]:=-6*c13.x*c22.x*c13s.y*c23.x*c23.y+6*c13s.x*c13.y*c22.y*c23.x*c23.y+3*c22.x*c13c.y*c23s.x-3*c13c.x*c22.y*c23s.y-3*c13.x*c13s.y*c22.y*c23s.x+3*c13s.x*c22.x*c13.y*c23s.y;
 PolyCoefs[2]:=-6*c21.x*c13.x*c13s.y*c23.x*c23.y-6*c13.x*c22.x*c13s.y*c22.y*c23.x+6*c13s.x*c22.x*c13.y*c22.y*c23.y+3*c21.x*c13c.y*c23s.x+3*c22s.x*c13c.y*c23.x+3*c21.x*c13s.x*c13.y*c23s.y-3*c13.x*c21.y*c13s.y*c23s.x-3*c13.x*c22s.x*c13s.y*c23.y+c13s.x*c13.y*c23.x*(6*c21.y*c23.y+3*c22s.y)+c13c.x*(-c21.y*c23s.y-2*c22s.y*c23.y-c23.y*(2*c21.y*c23.y+c22s.y));
 PolyCoefs[3]:=c11.x*c12.y*c13.x*c13.y*c23.x*c23.y-c11.y*c12.x*c13.x*c13.y*c23.x*c23.y+6*c21.x*c22.x*c13c.y*c23.x+3*c11.x*c12.x*c13.x*c13.y*c23s.y+6*c10.x*c13.x*c13s.y*c23.x*c23.y-3*c11.x*c12.x*c13s.y*c23.x*c23.y-3*c11.y*c12.y*c13.x*c13.y*c23s.x-6*c10.y*c13s.x*c13.y*c23.x*c23.y-6*c20.x*c13.x*c13s.y*c23.x*c23.y+3*c11.y*c12.y*c13s.x*c23.x*c23.y-2*c12.x*c12s.y*c13.x*c23.x*c23.y-6*c21.x*c13.x*c22.x*c13s.y*c23.y-6*c21.x*c13.x*c13s.y*c22.y*c23.x-6*c13.x*c21.y*c22.x*c13s.y*c23.x+6*c21.x*c13s.x*c13.y*c22.y*c23.y+2*c12s.x*c12.y*c13.y*c23.x*c23.y+c22c.x*c13c.y-3*c10.x*c13c.y*c23s.x+3*c10.y*c13c.x*c23s.y+3*c20.x*c13c.y*c23s.x+c12c.y*c13.x*c23s.x-c12c.x*c13.y*c23s.y-3*c10.x*c13s.x*c13.y*c23s.y+3*c10.y*c13.x*c13s.y*c23s.x-2*c11.x*c12.y*c13s.x*c23s.y+c11.x*c12.y*c13s.y*c23s.x-c11.y*c12.x*c13s.x*c23s.y+2*c11.y*c12.x*c13s.y*c23s.x+3*c20.x*c13s.x*c13.y*c23s.y-c12.x*c12s.y*c13.y*c23s.x-3*c20.y*c13.x*c13s.y*c23s.x+c12s.x*c12.y*c13.x*c23s.y-
               3*c13.x*c22s.x*c13s.y*c22.y+c13s.x*c13.y*c23.x*(6*c20.y*c23.y+6*c21.y*c22.y)+c13s.x*c22.x*c13.y*(6*c21.y*c23.y+3*c22s.y)+c13c.x*(-2*c21.y*c22.y*c23.y-c20.y*c23s.y-c22.y*(2*c21.y*c23.y+c22s.y)-c23.y*(2*c20.y*c23.y+2*c21.y*c22.y));
 PolyCoefs[4]:=6*c11.x*c12.x*c13.x*c13.y*c22.y*c23.y+c11.x*c12.y*c13.x*c22.x*c13.y*c23.y+c11.x*c12.y*c13.x*c13.y*c22.y*c23.x-c11.y*c12.x*c13.x*c22.x*c13.y*c23.y-c11.y*c12.x*c13.x*c13.y*c22.y*c23.x-6*c11.y*c12.y*c13.x*c22.x*c13.y*c23.x-6*c10.x*c22.x*c13c.y*c23.x+6*c20.x*c22.x*c13c.y*c23.x+6*c10.y*c13c.x*c22.y*c23.y+2*c12c.y*c13.x*c22.x*c23.x-2*c12c.x*c13.y*c22.y*c23.y+6*c10.x*c13.x*c22.x*c13s.y*c23.y+6*c10.x*c13.x*c13s.y*c22.y*c23.x+6*c10.y*c13.x*c22.x*c13s.y*c23.x-3*c11.x*c12.x*c22.x*c13s.y*c23.y-3*c11.x*c12.x*c13s.y*c22.y*c23.x+2*c11.x*c12.y*c22.x*c13s.y*c23.x+4*c11.y*c12.x*c22.x*c13s.y*c23.x-6*c10.x*c13s.x*c13.y*c22.y*c23.y-6*c10.y*c13s.x*c22.x*c13.y*c23.y-6*c10.y*c13s.x*c13.y*c22.y*c23.x-4*c11.x*c12.y*c13s.x*c22.y*c23.y-6*c20.x*c13.x*c22.x*c13s.y*c23.y-6*c20.x*c13.x*c13s.y*c22.y*c23.x-2*c11.y*c12.x*c13s.x*c22.y*c23.y+3*c11.y*c12.y*c13s.x*c22.x*c23.y+3*c11.y*c12.y*c13s.x*c22.y*c23.x-2*c12.x*c12s.y*c13.x*c22.x*c23.y-
               2*c12.x*c12s.y*c13.x*c22.y*c23.x-2*c12.x*c12s.y*c22.x*c13.y*c23.x-6*c20.y*c13.x*c22.x*c13s.y*c23.x-6*c21.x*c13.x*c21.y*c13s.y*c23.x-6*c21.x*c13.x*c22.x*c13s.y*c22.y+6*c20.x*c13s.x*c13.y*c22.y*c23.y+2*c12s.x*c12.y*c13.x*c22.y*c23.y+2*c12s.x*c12.y*c22.x*c13.y*c23.y+2*c12s.x*c12.y*c13.y*c22.y*c23.x+3*c21.x*c22s.x*c13c.y+3*c21s.x*c13c.y*c23.x-3*c13.x*c21.y*c22s.x*c13s.y-3*c21s.x*c13.x*c13s.y*c23.y+c13s.x*c22.x*c13.y*(6*c20.y*c23.y+6*c21.y*c22.y)+c13s.x*c13.y*c23.x*(6*c20.y*c22.y+3*c21s.y)+c21.x*c13s.x*c13.y*(6*c21.y*c23.y+3*c22s.y)+c13c.x*(-2*c20.y*c22.y*c23.y-c23.y*(2*c20.y*c22.y+c21s.y)-c21.y*(2*c21.y*c23.y+c22s.y)-c22.y*(2*c20.y*c23.y+2*c21.y*c22.y));
 PolyCoefs[5]:=c11.x*c21.x*c12.y*c13.x*c13.y*c23.y+c11.x*c12.y*c13.x*c21.y*c13.y*c23.x+c11.x*c12.y*c13.x*c22.x*c13.y*c22.y-c11.y*c12.x*c21.x*c13.x*c13.y*c23.y-c11.y*c12.x*c13.x*c21.y*c13.y*c23.x-c11.y*c12.x*c13.x*c22.x*c13.y*c22.y-6*c11.y*c21.x*c12.y*c13.x*c13.y*c23.x-6*c10.x*c21.x*c13c.y*c23.x+6*c20.x*c21.x*c13c.y*c23.x+2*c21.x*c12c.y*c13.x*c23.x+6*c10.x*c21.x*c13.x*c13s.y*c23.y+6*c10.x*c13.x*c21.y*c13s.y*c23.x+6*c10.x*c13.x*c22.x*c13s.y*c22.y+6*c10.y*c21.x*c13.x*c13s.y*c23.x-3*c11.x*c12.x*c21.x*c13s.y*c23.y-3*c11.x*c12.x*c21.y*c13s.y*c23.x-3*c11.x*c12.x*c22.x*c13s.y*c22.y+2*c11.x*c21.x*c12.y*c13s.y*c23.x+4*c11.y*c12.x*c21.x*c13s.y*c23.x-6*c10.y*c21.x*c13s.x*c13.y*c23.y-6*c10.y*c13s.x*c21.y*c13.y*c23.x-6*c10.y*c13s.x*c22.x*c13.y*c22.y-6*c20.x*c21.x*c13.x*c13s.y*c23.y-6*c20.x*c13.x*c21.y*c13s.y*c23.x-6*c20.x*c13.x*c22.x*c13s.y*c22.y+3*c11.y*c21.x*c12.y*c13s.x*c23.y-3*c11.y*c12.y*c13.x*c22s.x*c13.y+3*c11.y*c12.y*c13s.x*c21.y*c23.x+
               3*c11.y*c12.y*c13s.x*c22.x*c22.y-2*c12.x*c21.x*c12s.y*c13.x*c23.y-2*c12.x*c21.x*c12s.y*c13.y*c23.x-2*c12.x*c12s.y*c13.x*c21.y*c23.x-2*c12.x*c12s.y*c13.x*c22.x*c22.y-6*c20.y*c21.x*c13.x*c13s.y*c23.x-6*c21.x*c13.x*c21.y*c22.x*c13s.y+6*c20.y*c13s.x*c21.y*c13.y*c23.x+2*c12s.x*c21.x*c12.y*c13.y*c23.y+2*c12s.x*c12.y*c21.y*c13.y*c23.x+2*c12s.x*c12.y*c22.x*c13.y*c22.y-3*c10.x*c22s.x*c13c.y+3*c20.x*c22s.x*c13c.y+3*c21s.x*c22.x*c13c.y+c12c.y*c13.x*c22s.x+3*c10.y*c13.x*c22s.x*c13s.y+c11.x*c12.y*c22s.x*c13s.y+2*c11.y*c12.x*c22s.x*c13s.y-c12.x*c12s.y*c22s.x*c13.y-3*c20.y*c13.x*c22s.x*c13s.y-3*c21s.x*c13.x*c13s.y*c22.y+c12s.x*c12.y*c13.x*(2*c21.y*c23.y+c22s.y)+c11.x*c12.x*c13.x*c13.y*(6*c21.y*c23.y+3*c22s.y)+c21.x*c13s.x*c13.y*(6*c20.y*c23.y+6*c21.y*c22.y)+c12c.x*c13.y*(-2*c21.y*c23.y-c22s.y)+c10.y*c13c.x*(6*c21.y*c23.y+3*c22s.y)+c11.y*c12.x*c13s.x*(-2*c21.y*c23.y-c22s.y)+
               c11.x*c12.y*c13s.x*(-4*c21.y*c23.y-2*c22s.y)+c10.x*c13s.x*c13.y*(-6*c21.y*c23.y-3*c22s.y)+c13s.x*c22.x*c13.y*(6*c20.y*c22.y+3*c21s.y)+c20.x*c13s.x*c13.y*(6*c21.y*c23.y+3*c22s.y)+c13c.x*(-2*c20.y*c21.y*c23.y-c22.y*(2*c20.y*c22.y+c21s.y)-c20.y*(2*c21.y*c23.y+c22s.y)-c21.y*(2*c20.y*c23.y+2*c21.y*c22.y));
 PolyCoefs[6]:=-c10.x*c11.x*c12.y*c13.x*c13.y*c23.y+c10.x*c11.y*c12.x*c13.x*c13.y*c23.y+6*c10.x*c11.y*c12.y*c13.x*c13.y*c23.x-6*c10.y*c11.x*c12.x*c13.x*c13.y*c23.y-c10.y*c11.x*c12.y*c13.x*c13.y*c23.x+c10.y*c11.y*c12.x*c13.x*c13.y*c23.x+c11.x*c11.y*c12.x*c12.y*c13.x*c23.y-c11.x*c11.y*c12.x*c12.y*c13.y*c23.x+c11.x*c20.x*c12.y*c13.x*c13.y*c23.y+c11.x*c20.y*c12.y*c13.x*c13.y*c23.x+c11.x*c21.x*c12.y*c13.x*c13.y*c22.y+c11.x*c12.y*c13.x*c21.y*c22.x*c13.y-c20.x*c11.y*c12.x*c13.x*c13.y*c23.y-6*c20.x*c11.y*c12.y*c13.x*c13.y*c23.x-c11.y*c12.x*c20.y*c13.x*c13.y*c23.x-c11.y*c12.x*c21.x*c13.x*c13.y*c22.y-c11.y*c12.x*c13.x*c21.y*c22.x*c13.y-6*c11.y*c21.x*c12.y*c13.x*c22.x*c13.y-6*c10.x*c20.x*c13c.y*c23.x-6*c10.x*c21.x*c22.x*c13c.y-2*c10.x*c12c.y*c13.x*c23.x+6*c20.x*c21.x*c22.x*c13c.y+2*c20.x*c12c.y*c13.x*c23.x+2*c21.x*c12c.y*c13.x*c22.x+2*c10.y*c12c.x*c13.y*c23.y-6*c10.x*c10.y*c13.x*c13s.y*c23.x+3*c10.x*c11.x*c12.x*c13s.y*c23.y-
               2*c10.x*c11.x*c12.y*c13s.y*c23.x-4*c10.x*c11.y*c12.x*c13s.y*c23.x+3*c10.y*c11.x*c12.x*c13s.y*c23.x+6*c10.x*c10.y*c13s.x*c13.y*c23.y+6*c10.x*c20.x*c13.x*c13s.y*c23.y-3*c10.x*c11.y*c12.y*c13s.x*c23.y+2*c10.x*c12.x*c12s.y*c13.x*c23.y+2*c10.x*c12.x*c12s.y*c13.y*c23.x+6*c10.x*c20.y*c13.x*c13s.y*c23.x+6*c10.x*c21.x*c13.x*c13s.y*c22.y+6*c10.x*c13.x*c21.y*c22.x*c13s.y+4*c10.y*c11.x*c12.y*c13s.x*c23.y+6*c10.y*c20.x*c13.x*c13s.y*c23.x+2*c10.y*c11.y*c12.x*c13s.x*c23.y-3*c10.y*c11.y*c12.y*c13s.x*c23.x+2*c10.y*c12.x*c12s.y*c13.x*c23.x+6*c10.y*c21.x*c13.x*c22.x*c13s.y-3*c11.x*c20.x*c12.x*c13s.y*c23.y+2*c11.x*c20.x*c12.y*c13s.y*c23.x+c11.x*c11.y*c12s.y*c13.x*c23.x-3*c11.x*c12.x*c20.y*c13s.y*c23.x-3*c11.x*c12.x*c21.x*c13s.y*c22.y-3*c11.x*c12.x*c21.y*c22.x*c13s.y+2*c11.x*c21.x*c12.y*c22.x*c13s.y+4*c20.x*c11.y*c12.x*c13s.y*c23.x+4*c11.y*c12.x*c21.x*c22.x*c13s.y-2*c10.x*c12s.x*c12.y*c13.y*c23.y-6*c10.y*c20.x*c13s.x*c13.y*c23.y-
               6*c10.y*c20.y*c13s.x*c13.y*c23.x-6*c10.y*c21.x*c13s.x*c13.y*c22.y-2*c10.y*c12s.x*c12.y*c13.x*c23.y-2*c10.y*c12s.x*c12.y*c13.y*c23.x-6*c10.y*c13s.x*c21.y*c22.x*c13.y-c11.x*c11.y*c12s.x*c13.y*c23.y-2*c11.x*c11s.y*c13.x*c13.y*c23.x+3*c20.x*c11.y*c12.y*c13s.x*c23.y-2*c20.x*c12.x*c12s.y*c13.x*c23.y-2*c20.x*c12.x*c12s.y*c13.y*c23.x-6*c20.x*c20.y*c13.x*c13s.y*c23.x-6*c20.x*c21.x*c13.x*c13s.y*c22.y-6*c20.x*c13.x*c21.y*c22.x*c13s.y+3*c11.y*c20.y*c12.y*c13s.x*c23.x+3*c11.y*c21.x*c12.y*c13s.x*c22.y+3*c11.y*c12.y*c13s.x*c21.y*c22.x-2*c12.x*c20.y*c12s.y*c13.x*c23.x-2*c12.x*c21.x*c12s.y*c13.x*c22.y-2*c12.x*c21.x*c12s.y*c22.x*c13.y-2*c12.x*c12s.y*c13.x*c21.y*c22.x-6*c20.y*c21.x*c13.x*c22.x*c13s.y-c11s.y*c12.x*c12.y*c13.x*c23.x+2*c20.x*c12s.x*c12.y*c13.y*c23.y+6*c20.y*c13s.x*c21.y*c22.x*c13.y+2*c11s.x*c11.y*c13.x*c13.y*c23.y+c11s.x*c12.x*c12.y*c13.y*c23.y+2*c12s.x*c20.y*c12.y*c13.y*c23.x+2*c12s.x*c21.x*c12.y*c13.y*c22.y+
               2*c12s.x*c12.y*c21.y*c22.x*c13.y+c21c.x*c13c.y+3*c10s.x*c13c.y*c23.x-3*c10s.y*c13c.x*c23.y+3*c20s.x*c13c.y*c23.x+c11c.y*c13s.x*c23.x-c11c.x*c13s.y*c23.y-c11.x*c11s.y*c13s.x*c23.y+c11s.x*c11.y*c13s.y*c23.x-3*c10s.x*c13.x*c13s.y*c23.y+3*c10s.y*c13s.x*c13.y*c23.x-c11s.x*c12s.y*c13.x*c23.y+c11s.y*c12s.x*c13.y*c23.x-3*c21s.x*c13.x*c21.y*c13s.y-3*c20s.x*c13.x*c13s.y*c23.y+3*c20s.y*c13s.x*c13.y*c23.x+c11.x*c12.x*c13.x*c13.y*(6*c20.y*c23.y+6*c21.y*c22.y)+c12c.x*c13.y*(-2*c20.y*c23.y-2*c21.y*c22.y)+c10.y*c13c.x*(6*c20.y*c23.y+6*c21.y*c22.y)+c11.y*c12.x*c13s.x*(-2*c20.y*c23.y-2*c21.y*c22.y)+c12s.x*c12.y*c13.x*(2*c20.y*c23.y+2*c21.y*c22.y)+c11.x*c12.y*c13s.x*(-4*c20.y*c23.y-4*c21.y*c22.y)+c10.x*c13s.x*c13.y*(-6*c20.y*c23.y-6*c21.y*c22.y)+c20.x*c13s.x*c13.y*(6*c20.y*c23.y+6*c21.y*c22.y)+c21.x*c13s.x*c13.y*(6*c20.y*c22.y+3*c21s.y)+c13c.x*(-2*c20.y*c21.y*c22.y-c20s.y*c23.y-c21.y*(2*c20.y*c22.y+c21s.y)-c20.y*(2*c20.y*c23.y+2*c21.y*c22.y));
 PolyCoefs[7]:=-c10.x*c11.x*c12.y*c13.x*c13.y*c22.y+c10.x*c11.y*c12.x*c13.x*c13.y*c22.y+6*c10.x*c11.y*c12.y*c13.x*c22.x*c13.y-6*c10.y*c11.x*c12.x*c13.x*c13.y*c22.y-c10.y*c11.x*c12.y*c13.x*c22.x*c13.y+c10.y*c11.y*c12.x*c13.x*c22.x*c13.y+c11.x*c11.y*c12.x*c12.y*c13.x*c22.y-c11.x*c11.y*c12.x*c12.y*c22.x*c13.y+c11.x*c20.x*c12.y*c13.x*c13.y*c22.y+c11.x*c20.y*c12.y*c13.x*c22.x*c13.y+c11.x*c21.x*c12.y*c13.x*c21.y*c13.y-c20.x*c11.y*c12.x*c13.x*c13.y*c22.y-6*c20.x*c11.y*c12.y*c13.x*c22.x*c13.y-c11.y*c12.x*c20.y*c13.x*c22.x*c13.y-c11.y*c12.x*c21.x*c13.x*c21.y*c13.y-6*c10.x*c20.x*c22.x*c13c.y-2*c10.x*c12c.y*c13.x*c22.x+2*c20.x*c12c.y*c13.x*c22.x+2*c10.y*c12c.x*c13.y*c22.y-6*c10.x*c10.y*c13.x*c22.x*c13s.y+3*c10.x*c11.x*c12.x*c13s.y*c22.y-2*c10.x*c11.x*c12.y*c22.x*c13s.y-4*c10.x*c11.y*c12.x*c22.x*c13s.y+3*c10.y*c11.x*c12.x*c22.x*c13s.y+6*c10.x*c10.y*c13s.x*c13.y*c22.y+6*c10.x*c20.x*c13.x*c13s.y*c22.y-3*c10.x*c11.y*c12.y*c13s.x*c22.y+
               2*c10.x*c12.x*c12s.y*c13.x*c22.y+2*c10.x*c12.x*c12s.y*c22.x*c13.y+6*c10.x*c20.y*c13.x*c22.x*c13s.y+6*c10.x*c21.x*c13.x*c21.y*c13s.y+4*c10.y*c11.x*c12.y*c13s.x*c22.y+6*c10.y*c20.x*c13.x*c22.x*c13s.y+2*c10.y*c11.y*c12.x*c13s.x*c22.y-3*c10.y*c11.y*c12.y*c13s.x*c22.x+2*c10.y*c12.x*c12s.y*c13.x*c22.x-3*c11.x*c20.x*c12.x*c13s.y*c22.y+2*c11.x*c20.x*c12.y*c22.x*c13s.y+c11.x*c11.y*c12s.y*c13.x*c22.x-3*c11.x*c12.x*c20.y*c22.x*c13s.y-3*c11.x*c12.x*c21.x*c21.y*c13s.y+4*c20.x*c11.y*c12.x*c22.x*c13s.y-2*c10.x*c12s.x*c12.y*c13.y*c22.y-6*c10.y*c20.x*c13s.x*c13.y*c22.y-6*c10.y*c20.y*c13s.x*c22.x*c13.y-6*c10.y*c21.x*c13s.x*c21.y*c13.y-2*c10.y*c12s.x*c12.y*c13.x*c22.y-2*c10.y*c12s.x*c12.y*c22.x*c13.y-c11.x*c11.y*c12s.x*c13.y*c22.y-2*c11.x*c11s.y*c13.x*c22.x*c13.y+3*c20.x*c11.y*c12.y*c13s.x*c22.y-2*c20.x*c12.x*c12s.y*c13.x*c22.y-2*c20.x*c12.x*c12s.y*c22.x*c13.y-6*c20.x*c20.y*c13.x*c22.x*c13s.y-6*c20.x*c21.x*c13.x*c21.y*c13s.y+
               3*c11.y*c20.y*c12.y*c13s.x*c22.x+3*c11.y*c21.x*c12.y*c13s.x*c21.y-2*c12.x*c20.y*c12s.y*c13.x*c22.x-2*c12.x*c21.x*c12s.y*c13.x*c21.y-c11s.y*c12.x*c12.y*c13.x*c22.x+2*c20.x*c12s.x*c12.y*c13.y*c22.y-3*c11.y*c21s.x*c12.y*c13.x*c13.y+6*c20.y*c21.x*c13s.x*c21.y*c13.y+2*c11s.x*c11.y*c13.x*c13.y*c22.y+c11s.x*c12.x*c12.y*c13.y*c22.y+2*c12s.x*c20.y*c12.y*c22.x*c13.y+2*c12s.x*c21.x*c12.y*c21.y*c13.y-3*c10.x*c21s.x*c13c.y+3*c20.x*c21s.x*c13c.y+3*c10s.x*c22.x*c13c.y-3*c10s.y*c13c.x*c22.y+3*c20s.x*c22.x*c13c.y+c21s.x*c12c.y*c13.x+c11c.y*c13s.x*c22.x-c11c.x*c13s.y*c22.y+3*c10.y*c21s.x*c13.x*c13s.y-c11.x*c11s.y*c13s.x*c22.y+c11.x*c21s.x*c12.y*c13s.y+2*c11.y*c12.x*c21s.x*c13s.y+c11s.x*c11.y*c22.x*c13s.y-c12.x*c21s.x*c12s.y*c13.y-3*c20.y*c21s.x*c13.x*c13s.y-3*c10s.x*c13.x*c13s.y*c22.y+3*c10s.y*c13s.x*c22.x*c13.y-c11s.x*c12s.y*c13.x*c22.y+c11s.y*c12s.x*c22.x*c13.y-3*c20s.x*c13.x*c13s.y*c22.y+3*c20s.y*c13s.x*c22.x*c13.y+
               c12s.x*c12.y*c13.x*(2*c20.y*c22.y+c21s.y)+c11.x*c12.x*c13.x*c13.y*(6*c20.y*c22.y+3*c21s.y)+c12c.x*c13.y*(-2*c20.y*c22.y-c21s.y)+c10.y*c13c.x*(6*c20.y*c22.y+3*c21s.y)+c11.y*c12.x*c13s.x*(-2*c20.y*c22.y-c21s.y)+c11.x*c12.y*c13s.x*(-4*c20.y*c22.y-2*c21s.y)+c10.x*c13s.x*c13.y*(-6*c20.y*c22.y-3*c21s.y)+c20.x*c13s.x*c13.y*(6*c20.y*c22.y+3*c21s.y)+c13c.x*(-2*c20.y*c21s.y-c20s.y*c22.y-c20.y*(2*c20.y*c22.y+c21s.y));
 PolyCoefs[8]:=-c10.x*c11.x*c12.y*c13.x*c21.y*c13.y+c10.x*c11.y*c12.x*c13.x*c21.y*c13.y+6*c10.x*c11.y*c21.x*c12.y*c13.x*c13.y-6*c10.y*c11.x*c12.x*c13.x*c21.y*c13.y-c10.y*c11.x*c21.x*c12.y*c13.x*c13.y+c10.y*c11.y*c12.x*c21.x*c13.x*c13.y-c11.x*c11.y*c12.x*c21.x*c12.y*c13.y+c11.x*c11.y*c12.x*c12.y*c13.x*c21.y+c11.x*c20.x*c12.y*c13.x*c21.y*c13.y+6*c11.x*c12.x*c20.y*c13.x*c21.y*c13.y+c11.x*c20.y*c21.x*c12.y*c13.x*c13.y-c20.x*c11.y*c12.x*c13.x*c21.y*c13.y-6*c20.x*c11.y*c21.x*c12.y*c13.x*c13.y-c11.y*c12.x*c20.y*c21.x*c13.x*c13.y-6*c10.x*c20.x*c21.x*c13c.y-2*c10.x*c21.x*c12c.y*c13.x+6*c10.y*c20.y*c13c.x*c21.y+2*c20.x*c21.x*c12c.y*c13.x+2*c10.y*c12c.x*c21.y*c13.y-2*c12c.x*c20.y*c21.y*c13.y-6*c10.x*c10.y*c21.x*c13.x*c13s.y+3*c10.x*c11.x*c12.x*c21.y*c13s.y-2*c10.x*c11.x*c21.x*c12.y*c13s.y-4*c10.x*c11.y*c12.x*c21.x*c13s.y+3*c10.y*c11.x*c12.x*c21.x*c13s.y+6*c10.x*c10.y*c13s.x*c21.y*c13.y+6*c10.x*c20.x*c13.x*c21.y*c13s.y-
               3*c10.x*c11.y*c12.y*c13s.x*c21.y+2*c10.x*c12.x*c21.x*c12s.y*c13.y+2*c10.x*c12.x*c12s.y*c13.x*c21.y+6*c10.x*c20.y*c21.x*c13.x*c13s.y+4*c10.y*c11.x*c12.y*c13s.x*c21.y+6*c10.y*c20.x*c21.x*c13.x*c13s.y+2*c10.y*c11.y*c12.x*c13s.x*c21.y-3*c10.y*c11.y*c21.x*c12.y*c13s.x+2*c10.y*c12.x*c21.x*c12s.y*c13.x-3*c11.x*c20.x*c12.x*c21.y*c13s.y+2*c11.x*c20.x*c21.x*c12.y*c13s.y+c11.x*c11.y*c21.x*c12s.y*c13.x-3*c11.x*c12.x*c20.y*c21.x*c13s.y+4*c20.x*c11.y*c12.x*c21.x*c13s.y-6*c10.x*c20.y*c13s.x*c21.y*c13.y-2*c10.x*c12s.x*c12.y*c21.y*c13.y-6*c10.y*c20.x*c13s.x*c21.y*c13.y-6*c10.y*c20.y*c21.x*c13s.x*c13.y-2*c10.y*c12s.x*c21.x*c12.y*c13.y-2*c10.y*c12s.x*c12.y*c13.x*c21.y-c11.x*c11.y*c12s.x*c21.y*c13.y-4*c11.x*c20.y*c12.y*c13s.x*c21.y-2*c11.x*c11s.y*c21.x*c13.x*c13.y+3*c20.x*c11.y*c12.y*c13s.x*c21.y-2*c20.x*c12.x*c21.x*c12s.y*c13.y-2*c20.x*c12.x*c12s.y*c13.x*c21.y-6*c20.x*c20.y*c21.x*c13.x*c13s.y-2*c11.y*c12.x*c20.y*c13s.x*c21.y+
               3*c11.y*c20.y*c21.x*c12.y*c13s.x-2*c12.x*c20.y*c21.x*c12s.y*c13.x-c11s.y*c12.x*c21.x*c12.y*c13.x+6*c20.x*c20.y*c13s.x*c21.y*c13.y+2*c20.x*c12s.x*c12.y*c21.y*c13.y+2*c11s.x*c11.y*c13.x*c21.y*c13.y+c11s.x*c12.x*c12.y*c21.y*c13.y+2*c12s.x*c20.y*c21.x*c12.y*c13.y+2*c12s.x*c20.y*c12.y*c13.x*c21.y+3*c10s.x*c21.x*c13c.y-3*c10s.y*c13c.x*c21.y+3*c20s.x*c21.x*c13c.y+c11c.y*c21.x*c13s.x-c11c.x*c21.y*c13s.y-3*c20s.y*c13c.x*c21.y-c11.x*c11s.y*c13s.x*c21.y+c11s.x*c11.y*c21.x*c13s.y-3*c10s.x*c13.x*c21.y*c13s.y+3*c10s.y*c21.x*c13s.x*c13.y-c11s.x*c12s.y*c13.x*c21.y+c11s.y*c12s.x*c21.x*c13.y-3*c20s.x*c13.x*c21.y*c13s.y+3*c20s.y*c21.x*c13s.x*c13.y;
 PolyCoefs[9]:=c10.x*c10.y*c11.x*c12.y*c13.x*c13.y-c10.x*c10.y*c11.y*c12.x*c13.x*c13.y+c10.x*c11.x*c11.y*c12.x*c12.y*c13.y-c10.y*c11.x*c11.y*c12.x*c12.y*c13.x-c10.x*c11.x*c20.y*c12.y*c13.x*c13.y+6*c10.x*c20.x*c11.y*c12.y*c13.x*c13.y+c10.x*c11.y*c12.x*c20.y*c13.x*c13.y-c10.y*c11.x*c20.x*c12.y*c13.x*c13.y-6*c10.y*c11.x*c12.x*c20.y*c13.x*c13.y+c10.y*c20.x*c11.y*c12.x*c13.x*c13.y-c11.x*c20.x*c11.y*c12.x*c12.y*c13.y+c11.x*c11.y*c12.x*c20.y*c12.y*c13.x+c11.x*c20.x*c20.y*c12.y*c13.x*c13.y-c20.x*c11.y*c12.x*c20.y*c13.x*c13.y-2*c10.x*c20.x*c12c.y*c13.x+2*c10.y*c12c.x*c20.y*c13.y-3*c10.x*c10.y*c11.x*c12.x*c13s.y-6*c10.x*c10.y*c20.x*c13.x*c13s.y+3*c10.x*c10.y*c11.y*c12.y*c13s.x-2*c10.x*c10.y*c12.x*c12s.y*c13.x-2*c10.x*c11.x*c20.x*c12.y*c13s.y-c10.x*c11.x*c11.y*c12s.y*c13.x+3*c10.x*c11.x*c12.x*c20.y*c13s.y-4*c10.x*c20.x*c11.y*c12.x*c13s.y+3*c10.y*c11.x*c20.x*c12.x*c13s.y+6*c10.x*c10.y*c20.y*c13s.x*c13.y+2*c10.x*c10.y*c12s.x*c12.y*c13.y+
               2*c10.x*c11.x*c11s.y*c13.x*c13.y+2*c10.x*c20.x*c12.x*c12s.y*c13.y+6*c10.x*c20.x*c20.y*c13.x*c13s.y-3*c10.x*c11.y*c20.y*c12.y*c13s.x+2*c10.x*c12.x*c20.y*c12s.y*c13.x+c10.x*c11s.y*c12.x*c12.y*c13.x+c10.y*c11.x*c11.y*c12s.x*c13.y+4*c10.y*c11.x*c20.y*c12.y*c13s.x-3*c10.y*c20.x*c11.y*c12.y*c13s.x+2*c10.y*c20.x*c12.x*c12s.y*c13.x+2*c10.y*c11.y*c12.x*c20.y*c13s.x+c11.x*c20.x*c11.y*c12s.y*c13.x-3*c11.x*c20.x*c12.x*c20.y*c13s.y-2*c10.x*c12s.x*c20.y*c12.y*c13.y-6*c10.y*c20.x*c20.y*c13s.x*c13.y-2*c10.y*c20.x*c12s.x*c12.y*c13.y-2*c10.y*c11s.x*c11.y*c13.x*c13.y-c10.y*c11s.x*c12.x*c12.y*c13.y-2*c10.y*c12s.x*c20.y*c12.y*c13.x-2*c11.x*c20.x*c11s.y*c13.x*c13.y-c11.x*c11.y*c12s.x*c20.y*c13.y+3*c20.x*c11.y*c20.y*c12.y*c13s.x-2*c20.x*c12.x*c20.y*c12s.y*c13.x-c20.x*c11s.y*c12.x*c12.y*c13.x+3*c10s.y*c11.x*c12.x*c13.x*c13.y+3*c11.x*c12.x*c20s.y*c13.x*c13.y+2*c20.x*c12s.x*c20.y*c12.y*c13.y-3*c10s.x*c11.y*c12.y*c13.x*c13.y+
               2*c11s.x*c11.y*c20.y*c13.x*c13.y+c11s.x*c12.x*c20.y*c12.y*c13.y-3*c20s.x*c11.y*c12.y*c13.x*c13.y-c10c.x*c13c.y+c10c.y*c13c.x+c20c.x*c13c.y-c20c.y*c13c.x-3*c10.x*c20s.x*c13c.y-c10.x*c11c.y*c13s.x+3*c10s.x*c20.x*c13c.y+c10.y*c11c.x*c13s.y+3*c10.y*c20s.y*c13c.x+c20.x*c11c.y*c13s.x+c10s.x*c12c.y*c13.x-3*c10s.y*c20.y*c13c.x-c10s.y*c12c.x*c13.y+c20s.x*c12c.y*c13.x-c11c.x*c20.y*c13s.y-c12c.x*c20s.y*c13.y-c10.x*c11s.x*c11.y*c13s.y+c10.y*c11.x*c11s.y*c13s.x-3*c10.x*c10s.y*c13s.x*c13.y-c10.x*c11s.y*c12s.x*c13.y+c10.y*c11s.x*c12s.y*c13.x-c11.x*c11s.y*c20.y*c13s.x+3*c10s.x*c10.y*c13.x*c13s.y+c10s.x*c11.x*c12.y*c13s.y+2*c10s.x*c11.y*c12.x*c13s.y-2*c10s.y*c11.x*c12.y*c13s.x-c10s.y*c11.y*c12.x*c13s.x+c11s.x*c20.x*c11.y*c13s.y-3*c10.x*c20s.y*c13s.x*c13.y+3*c10.y*c20s.x*c13.x*c13s.y+c11.x*c20s.x*c12.y*c13s.y-2*c11.x*c20s.y*c12.y*c13s.x+c20.x*c11s.y*c12s.x*c13.y-c11.y*c12.x*c20s.y*c13s.x-c10s.x*c12.x*c12s.y*c13.y-3*c10s.x*c20.y*c13.x*c13s.y+
               3*c10s.y*c20.x*c13s.x*c13.y+c10s.y*c12s.x*c12.y*c13.x-c11s.x*c20.y*c12s.y*c13.x+2*c20s.x*c11.y*c12.x*c13s.y+3*c20.x*c20s.y*c13s.x*c13.y-c20s.x*c12.x*c12s.y*c13.y-3*c20s.x*c20.y*c13.x*c13s.y+c12s.x*c20s.y*c12.y*c13.x;
 Roots:=(TpvPolynomial.Create([PolyCoefs[0],PolyCoefs[1],PolyCoefs[2],PolyCoefs[3],PolyCoefs[4],PolyCoefs[5],PolyCoefs[6],PolyCoefs[7],PolyCoefs[8],PolyCoefs[9]])).GetRootsInInterval(0.0,1.0);
//Roots:=SolveRootsInInterval(PolyCoefs,0.0,1.0);
 XRoots:=nil;
 YRoots:=nil;
 try
  for Index:=0 to length(Roots)-1 do begin
   s:=Roots[Index];
   if (s>=0.0) and (s<=1.0) then begin
    XRoots:=(TpvPolynomial.Create([c12.x,
                                   c11.x,
                                   (((c10.x-c20.x)-(s*c21.x))-(sqr(s)*c22.x))-((sqr(s)*s)*c23.x)])).GetRoots;
    YRoots:=(TpvPolynomial.Create([c12.y,
                                   c11.y,
                                   (((c10.y-c20.y)-(s*c21.y))-(sqr(s)*c22.y))-((sqr(s)*s)*c23.y)])).GetRoots;
    CountXRoots:=length(XRoots);
    CountYRoots:=length(YRoots);
{   CountXRoots:=SolveQuadratic(c12.x,
                                c11.x,
                                (((c10.x-c20.x)-(s*c21.x))-(sqr(s)*c22.x))-((sqr(s)*s)*c23.x),
                                XRoots[0],
                                XRoots[1]
                               );
    CountYRoots:=SolveQuadratic(c12.y,
                                c11.y,
                                (((c10.x-c20.y)-(s*c21.y))-(sqr(s)*c22.y))-((sqr(s)*s)*c23.y),
                                YRoots[0],
                                YRoots[1]
                               );}
    if (CountXRoots>0) and (CountYRoots>0) then begin
     OK:=false;
     for XIndex:=0 to CountXRoots-1 do begin
      XRoot:=XRoots[XIndex];
      if (XRoot>=0.0) and (XRoot<=1.0) then begin
       for YIndex:=0 to CountYRoots-1 do begin
        if SameValue(XRoot,YRoots[XIndex],1e-4) then begin
         aIntersectionPoints.Add((c23*(sqr(s)*s))+(c22*sqr(s))+(c21*s)+c20);
         OK:=true;
         break;
        end;
       end;
      end;
      if OK then begin
       break;
      end;
     end;
    end;
   end;
  end;
 finally
  Roots:=nil;
  XRoots:=nil;
  YRoots:=nil;
 end;
end;

{ TpvVectorPathSegment }

constructor TpvVectorPathSegment.Create;
begin
 inherited Create;
 fHasCachedBoundingBox:=false;
 fCachedBoundingBoxLock:=0;
end;

destructor TpvVectorPathSegment.Destroy;
begin
 inherited Destroy;
end;

procedure TpvVectorPathSegment.Assign(const aSegment:TpvVectorPathSegment);
begin
end;

function TpvVectorPathSegment.Clone:TpvVectorPathSegment;
begin
 result:=TpvVectorPathSegment(ClassType).Create;
 result.Assign(self);
end;

function TpvVectorPathSegment.GetBoundingBox:TpvVectorPathBoundingBox;
begin
 result:=TpvVectorPathBoundingBox.Create(TpvVectorPathVector.Create(MaxDouble,MaxDouble),
                                         TpvVectorPathVector.Create(-MaxDouble,-MaxDouble));
end;

procedure TpvVectorPathSegment.GetIntersectionPointsWithLineSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
end;

procedure TpvVectorPathSegment.GetIntersectionPointsWithQuadraticCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
end;

procedure TpvVectorPathSegment.GetIntersectionPointsWithCubicCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
end;

procedure TpvVectorPathSegment.GetIntersectionPointsWithSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin

end;

function TpvVectorPathSegment.GetCompareHorizontalLowestXCoordinate:TpvDouble;
var OK:boolean;
begin
 OK:=false;
 TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fCachedBoundingBoxLock);
 try
  if fHasCachedBoundingBox then begin
   result:=fCachedBoundingBox.MinMax[0].x;
   OK:=true;
  end;
 finally
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fCachedBoundingBoxLock);
 end;
 if OK then begin
  exit;
 end;
 result:=GetBoundingBox.MinMax[0].x;
end;

{ TpvVectorPathSegmentLine }

constructor TpvVectorPathSegmentLine.Create;
begin
 inherited Create;
 fType:=TpvVectorPathSegmentType.Line;
end;

constructor TpvVectorPathSegmentLine.Create(const aP0,aP1:TpvVectorPathVector);
begin
 Create;
 Points[0]:=aP0;
 Points[1]:=aP1;
end;

procedure TpvVectorPathSegmentLine.Assign(const aSegment:TpvVectorPathSegment);
begin
 if assigned(aSegment) and (aSegment is TpvVectorPathSegmentLine) then begin
  Points:=TpvVectorPathSegmentLine(aSegment).Points;
 end;
end;

function TpvVectorPathSegmentLine.Clone:TpvVectorPathSegment;
begin
 result:=TpvVectorPathSegmentLine.Create(Points[0],Points[1]);
end;

function TpvVectorPathSegmentLine.GetBoundingBox:TpvVectorPathBoundingBox;
begin
 TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fCachedBoundingBoxLock);
 try
  if fHasCachedBoundingBox then begin
   result:=fCachedBoundingBox;
  end else begin
   TPasMPMultipleReaderSingleWriterSpinLock.ReadToWrite(fCachedBoundingBoxLock);
   try
    if fHasCachedBoundingBox then begin
     result:=fCachedBoundingBox;
    end else begin
     result:=TpvVectorPathBoundingBox.Create(Points[0].Minimum(Points[1]),
                                             Points[0].Maximum(Points[1]));
     fCachedBoundingBox:=result;
     fHasCachedBoundingBox:=true;
    end;
   finally
    TPasMPMultipleReaderSingleWriterSpinLock.WriteToRead(fCachedBoundingBoxLock);
   end;
  end;
 finally
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fCachedBoundingBoxLock);
 end;
end;

procedure TpvVectorPathSegmentLine.GetIntersectionPointsWithLineSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
 GetIntersectionPointsForLineLine(TpvVectorPathSegmentLine(self),TpvVectorPathSegmentLine(aWith),aIntersectionPoints);
end;

procedure TpvVectorPathSegmentLine.GetIntersectionPointsWithQuadraticCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
 GetIntersectionPointsForLineQuadraticCurve(TpvVectorPathSegmentLine(self),TpvVectorPathSegmentQuadraticCurve(aWith),aIntersectionPoints);
end;

procedure TpvVectorPathSegmentLine.GetIntersectionPointsWithCubicCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
 GetIntersectionPointsForLineCubicCurve(TpvVectorPathSegmentLine(self),TpvVectorPathSegmentCubicCurve(aWith),aIntersectionPoints);
end;

procedure TpvVectorPathSegmentLine.GetIntersectionPointsWithSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
 if assigned(self) and assigned(aWith) then begin
  aWith.GetIntersectionPointsWithLineSegment(self,aIntersectionPoints);
 end;
end;

{ TpvVectorPathSegmentQuadraticCurve }

constructor TpvVectorPathSegmentQuadraticCurve.Create;
begin
 inherited Create;
 fType:=TpvVectorPathSegmentType.QuadraticCurve;
end;

constructor TpvVectorPathSegmentQuadraticCurve.Create(const aP0,aP1,aP2:TpvVectorPathVector);
begin
 Create;
 Points[0]:=aP0;
 Points[1]:=aP1;
 Points[2]:=aP2;
end;

procedure TpvVectorPathSegmentQuadraticCurve.Assign(const aSegment:TpvVectorPathSegment);
begin
 if assigned(aSegment) and (aSegment is TpvVectorPathSegmentQuadraticCurve) then begin
  Points:=TpvVectorPathSegmentQuadraticCurve(aSegment).Points;
 end;
end;

function TpvVectorPathSegmentQuadraticCurve.Clone:TpvVectorPathSegment;
begin
 result:=TpvVectorPathSegmentQuadraticCurve.Create(Points[0],Points[1],Points[2]);
end;

function TpvVectorPathSegmentQuadraticCurve.GetBoundingBox:TpvVectorPathBoundingBox;
var t,s:TpvVectorPathVector;
begin
 TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fCachedBoundingBoxLock);
 try
  if fHasCachedBoundingBox then begin
   result:=fCachedBoundingBox;
  end else begin
   TPasMPMultipleReaderSingleWriterSpinLock.ReadToWrite(fCachedBoundingBoxLock);
   try
    if fHasCachedBoundingBox then begin
     result:=fCachedBoundingBox;
    end else begin
     // This code calculates the bounding box for a quadratic bezier curve. It starts by initializing the
     // bounding box to the minimum and maximum values of the start and end points of the curve. It then
     // checks if the control point is already contained within the bounding box, and if it is not, it
     // calculates the value of t at which the derivative of the curve (which is a linear equation) is
     // equal to 0. If t is within the range of 0 to 1, the code calculates the corresponding point on the
     // curve and extends the bounding box to include that point if necessary.
     // Overall, this code appears to be well written and effective at calculating the bounding box for a
     // quadratic bezier curve. It is concise and uses a clever method for finding the extrema of the curve.
     result:=TpvVectorPathBoundingBox.Create(Points[0].Minimum(Points[2]),Points[0].Maximum(Points[2]));
     if not result.Contains(Points[1]) then begin
      // Since the bezier is quadratic, the bounding box can be compute here with a linear equation.
      // p = (1-t)^2*p0 + 2(1-t)t*p1 + t^2*p2
      // dp/dt = 2(t-1)*p0 + 2(1-2t)*p1 + 2t*p2 = t*(2*p0-4*p1+2*p2) + 2*(p1-p0)
      // dp/dt = 0 -> t*(p0-2*p1+p2) = (p0-p1);
      // Credits for the idea: Inigo Quilez
      t:=(Points[0]-Points[1])/((Points[0]-(Points[1]*2.0))+Points[2]);
      if t.x<=0.0 then begin
       t.x:=0.0;
      end else if t.x>=1.0 then begin
       t.x:=1.0;
      end;
      if t.y<=0.0 then begin
       t.y:=0.0;
      end else if t.y>=1.0 then begin
       t.y:=1.0;
      end;
      s:=TpvVectorPathVector.Create(1.0,1.0)-t;
      result.Extend((Points[0]*(s*s))+(Points[1]*((t*s)*2.0))+(Points[2]*(t*t)));
     end;
     fCachedBoundingBox:=result;
     fHasCachedBoundingBox:=true;
    end;
   finally
    TPasMPMultipleReaderSingleWriterSpinLock.WriteToRead(fCachedBoundingBoxLock);
   end;
  end;
 finally
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fCachedBoundingBoxLock);
 end;
end;

procedure TpvVectorPathSegmentQuadraticCurve.GetIntersectionPointsWithLineSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
 GetIntersectionPointsForLineQuadraticCurve(TpvVectorPathSegmentLine(aWith),TpvVectorPathSegmentQuadraticCurve(self),aIntersectionPoints);
end;

procedure TpvVectorPathSegmentQuadraticCurve.GetIntersectionPointsWithQuadraticCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
 GetIntersectionPointsForQuadraticCurveQuadraticCurve(TpvVectorPathSegmentQuadraticCurve(self),TpvVectorPathSegmentQuadraticCurve(aWith),aIntersectionPoints);
end;

procedure TpvVectorPathSegmentQuadraticCurve.GetIntersectionPointsWithCubicCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
 GetIntersectionPointsForQuadraticCurveCubicCurve(TpvVectorPathSegmentQuadraticCurve(self),TpvVectorPathSegmentCubicCurve(aWith),aIntersectionPoints);
end;

procedure TpvVectorPathSegmentQuadraticCurve.GetIntersectionPointsWithSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
 if assigned(self) and assigned(aWith) then begin
  aWith.GetIntersectionPointsWithQuadraticCurveSegment(self,aIntersectionPoints);
 end;
end;

{ TpvVectorPathSegmentCubicCurve }

constructor TpvVectorPathSegmentCubicCurve.Create;
begin
 inherited Create;
 fType:=TpvVectorPathSegmentType.CubicCurve;
end;

constructor TpvVectorPathSegmentCubicCurve.Create(const aP0,aP1,aP2,aP3:TpvVectorPathVector);
begin
 Create;
 Points[0]:=aP0;
 Points[1]:=aP1;
 Points[2]:=aP2;
 Points[3]:=aP3;
end;

procedure TpvVectorPathSegmentCubicCurve.Assign(const aSegment:TpvVectorPathSegment);
begin
 if assigned(aSegment) and (aSegment is TpvVectorPathSegmentCubicCurve) then begin
  Points:=TpvVectorPathSegmentCubicCurve(aSegment).Points;
 end;
end;

function TpvVectorPathSegmentCubicCurve.Clone:TpvVectorPathSegment;
begin
 result:=TpvVectorPathSegmentCubicCurve.Create(Points[0],Points[1],Points[2],Points[3]);
end;

function TpvVectorPathSegmentCubicCurve.GetBoundingBox:TpvVectorPathBoundingBox;
var c,b,a,h:TpvVectorPathVector;
    t,s,q:TpvDouble;
begin
 TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fCachedBoundingBoxLock);
 try
  if fHasCachedBoundingBox then begin
   result:=fCachedBoundingBox;
  end else begin
   TPasMPMultipleReaderSingleWriterSpinLock.ReadToWrite(fCachedBoundingBoxLock);
   try
    if fHasCachedBoundingBox then begin
     result:=fCachedBoundingBox;
    end else begin
     // This code appears to be a correct implementation for computing the bounding box of a cubic bezier curve.
     // It uses the fact that the bounding box of a cubic Bezier curve can be computed by finding the roots of
     // quadratic equation formed from the bezier curve's coefficients. The roots of this equation correspond
     // to the parameter values at which the curve reaches an extreme point (i.e., a minimum or maximum). The
     // bounding box is then constructed by evaluating the curve at these parameter values and using the
     // resulting points to extend the initial bounding box.
     // One thing to note is that the code only handles the case where the roots of the quadratic equation are real.
     // If the roots are complex, the bounding box is not extended. This is acceptable since complex roots do not
     // correspond to physical points on the curve.
     // Overall, I would rate this code as good and efficient for computing the bounding box of a cubic bezier curve.
     result:=TpvVectorPathBoundingBox.Create(Points[0].Minimum(Points[3]),Points[0].Maximum(Points[3]));
     // Since the bezier is cubic, the bounding box can be compute here with a quadratic equation with
     // pascal triangle coefficients. Credits for the idea: Inigo Quilez
     a:=(((-Points[0])+(Points[1]*3.0))-(Points[2]*3.0))+Points[3];
     b:=(Points[0]-(Points[1]*2.0))+Points[2];
     c:=Points[1]-Points[0];
     h:=(b*b)-(c*a);
     if h.x>0.0 then begin
      h.x:=sqrt(h.x);
      t:=c.x/((-b.x)-h.x);
      if (t>0.0) and (t<1.0) then begin
       s:=1.0-t;
       q:=(Points[0].x*(sqr(s)*s))+(Points[1].x*(3.0*sqr(s)*t))+(Points[2].x*(3.0*s*sqr(t)))+(Points[3].x*sqr(t)*t);
       if result.Min.x<q then begin
        result.Min.x:=q;
       end;
       if result.Max.x>q then begin
        result.Max.x:=q;
       end;
      end;
      t:=c.x/((-b.x)+h.x);
      if (t>0.0) and (t<1.0) then begin
       s:=1.0-t;
       q:=(Points[0].x*(sqr(s)*s))+(Points[1].x*(3.0*sqr(s)*t))+(Points[2].x*(3.0*s*sqr(t)))+(Points[3].x*sqr(t)*t);
       if result.Min.x<q then begin
        result.Min.x:=q;
       end;
       if result.Max.x>q then begin
        result.Max.x:=q;
       end;
      end;
     end;
     if h.y>0.0 then begin
      h.y:=sqrt(h.y);
      t:=c.y/((-b.y)-h.y);
      if (t>0.0) and (t<1.0) then begin
       s:=1.0-t;
       q:=(Points[0].y*(sqr(s)*s))+(Points[1].y*(3.0*sqr(s)*t))+(Points[2].y*(3.0*s*sqr(t)))+(Points[3].y*sqr(t)*t);
       if result.Min.y<q then begin
        result.Min.y:=q;
       end;
       if result.Max.y>q then begin
        result.Max.y:=q;
       end;
      end;
      t:=c.y/((-b.y)+h.y);
      if (t>0.0) and (t<1.0) then begin
       s:=1.0-t;
       q:=(Points[0].y*(sqr(s)*s))+(Points[1].y*(3.0*sqr(s)*t))+(Points[2].y*(3.0*s*sqr(t)))+(Points[3].y*sqr(t)*t);
       if result.Min.y<q then begin
        result.Min.y:=q;
       end;
       if result.Max.y>q then begin
        result.Max.y:=q;
       end;
      end;
     end;
     fCachedBoundingBox:=result;
     fHasCachedBoundingBox:=true;
    end;
   finally
    TPasMPMultipleReaderSingleWriterSpinLock.WriteToRead(fCachedBoundingBoxLock);
   end;
  end;
 finally
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fCachedBoundingBoxLock);
 end;
end;

procedure TpvVectorPathSegmentCubicCurve.GetIntersectionPointsWithLineSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
 GetIntersectionPointsForLineCubicCurve(TpvVectorPathSegmentLine(aWith),TpvVectorPathSegmentCubicCurve(self),aIntersectionPoints);
end;

procedure TpvVectorPathSegmentCubicCurve.GetIntersectionPointsWithQuadraticCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
 GetIntersectionPointsForQuadraticCurveCubicCurve(TpvVectorPathSegmentQuadraticCurve(aWith),TpvVectorPathSegmentCubicCurve(self),aIntersectionPoints);
end;

procedure TpvVectorPathSegmentCubicCurve.GetIntersectionPointsWithCubicCurveSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
 GetIntersectionPointsForCubicCurveCubicCurve(TpvVectorPathSegmentCubicCurve(self),TpvVectorPathSegmentCubicCurve(aWith),aIntersectionPoints);
end;

procedure TpvVectorPathSegmentCubicCurve.GetIntersectionPointsWithSegment(const aWith:TpvVectorPathSegment;const aIntersectionPoints:TpvVectorPathVectorList);
begin
 if assigned(self) and assigned(aWith) then begin
  aWith.GetIntersectionPointsWithCubicCurveSegment(self,aIntersectionPoints);
 end;
end;

{ TpvVectorPathSegments }

procedure TpvVectorPathSegments.SortHorizontal;
type PByteArray=^TByteArray;
     TByteArray=array[0..$3fffffff] of TpvUInt8;
     PStackItem=^TStackItem;
     TStackItem=record
      Left,Right,Depth:TpvInt32;
     end;
var Left,Right,Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:TpvSizeInt;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
 function CompareItem(const a,b:TpvSizeInt):TpvSizeInt;
 var SegmentA,SegmentB:TpvVectorPathSegment;
 begin
  SegmentA:=Items[a];
  SegmentB:=Items[b];
  result:=Sign(SegmentA.GetCompareHorizontalLowestXCoordinate-SegmentB.GetCompareHorizontalLowestXCoordinate);
  if result=0 then begin
   result:=Sign(a-b);
  end;
 end;
begin
 begin
  if Count>1 then begin
   StackItem:=@Stack[0];
   StackItem^.Left:=0;
   StackItem^.Right:=Count-1;
   StackItem^.Depth:=IntLog2(Count) shl 1;
   inc(StackItem);
   while TpvPtrUInt(TpvPointer(StackItem))>TpvPtrUInt(TpvPointer(@Stack[0])) do begin
    dec(StackItem);
    Left:=StackItem^.Left;
    Right:=StackItem^.Right;
    Depth:=StackItem^.Depth;
    Size:=(Right-Left)+1;
    if Size<16 then begin
     // Insertion sort
     iA:=Left;
     iB:=iA+1;
     while iB<=Right do begin
      iC:=iB;
      while (iA>=Left) and
            (iC>=Left) and
            (CompareItem(iA,iC)>0) do begin
       Exchange(iA,iC);
       dec(iA);
       dec(iC);
      end;
      iA:=iB;
      inc(iB);
     end;
    end else begin
     if (Depth=0) or (TpvPtrUInt(TpvPointer(StackItem))>=TpvPtrUInt(TpvPointer(@Stack[high(Stack)-1]))) then begin
      // Heap sort
      i:=Size div 2;
      repeat
       if i>0 then begin
        dec(i);
       end else begin
        dec(Size);
        if Size>0 then begin
         Exchange(Left+Size,Left);
        end else begin
         break;
        end;
       end;
       Parent:=i;
       repeat
        Child:=(Parent*2)+1;
        if Child<Size then begin
         if (Child<(Size-1)) and (CompareItem(Left+Child,Left+Child+1)<0) then begin
          inc(Child);
         end;
         if CompareItem(Left+Parent,Left+Child)<0 then begin
          Exchange(Left+Parent,Left+Child);
          Parent:=Child;
          continue;
         end;
        end;
        break;
       until false;
      until false;
     end else begin
      // Quick sort width median-of-three optimization
      Middle:=Left+((Right-Left) shr 1);
      if (Right-Left)>3 then begin
       if CompareItem(Left,Middle)>0 then begin
        Exchange(Left,Middle);
       end;
       if CompareItem(Left,Right)>0 then begin
        Exchange(Left,Right);
       end;
       if CompareItem(Middle,Right)>0 then begin
        Exchange(Middle,Right);
       end;
      end;
      Pivot:=Middle;
      i:=Left;
      j:=Right;
      repeat
       while (i<Right) and (CompareItem(i,Pivot)<0) do begin
        inc(i);
       end;
       while (j>=i) and (CompareItem(j,Pivot)>0) do begin
        dec(j);
       end;
       if i>j then begin
        break;
       end else begin
        if i<>j then begin
         Exchange(i,j);
         if Pivot=i then begin
          Pivot:=j;
         end else if Pivot=j then begin
          Pivot:=i;
         end;
        end;
        inc(i);
        dec(j);
       end;
      until false;
      if i<Right then begin
       StackItem^.Left:=i;
       StackItem^.Right:=Right;
       StackItem^.Depth:=Depth-1;
       inc(StackItem);
      end;
      if Left<j then begin
       StackItem^.Left:=Left;
       StackItem^.Right:=j;
       StackItem^.Depth:=Depth-1;
       inc(StackItem);
      end;
     end;
    end;
   end;
  end;
 end;
end;

{ TpvVectorPathContour }

constructor TpvVectorPathContour.Create;
begin
 inherited Create;
 fSegments:=TpvVectorPathSegments.Create;
 fSegments.OwnsObjects:=true;
 fClosed:=false;
end;

constructor TpvVectorPathContour.Create(const aContour:TpvVectorPathContour);
begin
 Create;
 Assign(aContour);
end;

destructor TpvVectorPathContour.Destroy;
begin
 FreeAndNil(fSegments);
 inherited Destroy;
end;

procedure TpvVectorPathContour.Assign(const aContour:TpvVectorPathContour);
var Segment:TpvVectorPathSegment;
begin
 fSegments.Clear;
 if assigned(aContour) and assigned(aContour.fSegments) then begin
  for Segment in aContour.fSegments do begin
   if assigned(Segment) then begin
    fSegments.Add(Segment.Clone);
   end;
  end;
 end;
end;

function TpvVectorPathContour.Clone:TpvVectorPathContour;
begin
 result:=TpvVectorPathContour.Create(self);
end;

function TpvVectorPathContour.GetBoundingBox:TpvVectorPathBoundingBox;
var Segment:TpvVectorPathSegment;
begin
 result:=TpvVectorPathBoundingBox.Create(TpvVectorPathVector.Create(MaxDouble,MaxDouble),
                                         TpvVectorPathVector.Create(-MaxDouble,-MaxDouble));
 for Segment in fSegments do begin
  if assigned(Segment) then begin
   result:=result.Combine(Segment.GetBoundingBox);
  end;
 end;
end;

{ TpvVectorPathShape }

constructor TpvVectorPathShape.Create;
begin
 inherited Create;
 fContours:=TpvVectorPathContours.Create;
 fContours.OwnsObjects:=true;
end;

constructor TpvVectorPathShape.Create(const aVectorPathShape:TpvVectorPathShape);
begin
 Create;
 if assigned(aVectorPathShape) then begin
  Assign(aVectorPathShape);
 end;
end;

constructor TpvVectorPathShape.Create(const aVectorPath:TpvVectorPath);
begin
 Create;
 if assigned(aVectorPath) then begin
  Assign(aVectorPath);
 end;
end;

destructor TpvVectorPathShape.Destroy;
begin
 FreeAndNil(fContours);
 inherited Destroy;
end;

procedure TpvVectorPathShape.Assign(const aVectorPathShape:TpvVectorPathShape);
var Contour:TpvVectorPathContour;
begin
 fContours.Clear;
 if assigned(aVectorPathShape) then begin
  fFillRule:=aVectorPathShape.fFillRule;
  if assigned(aVectorPathShape.fContours) then begin
   for Contour in aVectorPathShape.fContours do begin
    if assigned(Contour) then begin
     fContours.Add(Contour.Clone);
    end;
   end;
  end;
 end;
end;

procedure TpvVectorPathShape.Assign(const aVectorPath:TpvVectorPath);
var CommandIndex:TpvSizeInt;
    Command:TpvVectorPathCommand;
    Contour:TpvVectorPathContour;
    StartPoint,LastPoint,ControlPoint,OtherControlPoint,Point:TpvVectorPathVector;
begin
 fContours.Clear;
 if assigned(aVectorPath) then begin
  fFillRule:=aVectorPath.fFillRule;
  Contour:=nil;
  StartPoint:=TpvVectorPathVector.Create(0.0,0.0);
  LastPoint:=TpvVectorPathVector.Create(0.0,0.0);
  for CommandIndex:=0 to aVectorPath.fCommands.Count-1 do begin
   Command:=aVectorPath.fCommands[CommandIndex];
   case Command.CommandType of
    TpvVectorPathCommandType.MoveTo:begin
     if assigned(Contour) then begin
      if LastPoint<>StartPoint then begin
       Contour.fSegments.Add(TpvVectorPathSegmentLine.Create(LastPoint,StartPoint));
      end;
     end;
     Contour:=TpvVectorPathContour.Create;
     fContours.Add(Contour);
     LastPoint.x:=Command.x0;
     LastPoint.y:=Command.y0;
     StartPoint:=LastPoint;
    end;
    TpvVectorPathCommandType.LineTo:begin
     if not assigned(Contour) then begin
      Contour:=TpvVectorPathContour.Create;
      fContours.Add(Contour);
     end;
     Point.x:=Command.x0;
     Point.y:=Command.y0;
     if assigned(Contour) and (LastPoint<>Point) then begin
      Contour.fSegments.Add(TpvVectorPathSegmentLine.Create(LastPoint,Point));
     end;
     LastPoint:=Point;
    end;
    TpvVectorPathCommandType.QuadraticCurveTo:begin
     if not assigned(Contour) then begin
      Contour:=TpvVectorPathContour.Create;
      fContours.Add(Contour);
     end;
     ControlPoint.x:=Command.x0;
     ControlPoint.y:=Command.y0;
     Point.x:=Command.x1;
     Point.y:=Command.y1;
     if assigned(Contour) and not ((LastPoint=ControlPoint) and (LastPoint=Point)) then begin
      Contour.fSegments.Add(TpvVectorPathSegmentQuadraticCurve.Create(LastPoint,ControlPoint,Point));
     end;
     LastPoint:=Point;
    end;
    TpvVectorPathCommandType.CubicCurveTo:begin
     if not assigned(Contour) then begin
      Contour:=TpvVectorPathContour.Create;
      fContours.Add(Contour);
     end;
     ControlPoint.x:=Command.x0;
     ControlPoint.y:=Command.y0;
     OtherControlPoint.x:=Command.x1;
     OtherControlPoint.y:=Command.y1;
     Point.x:=Command.x2;
     Point.y:=Command.y2;
     if assigned(Contour) and not ((LastPoint=ControlPoint) and (LastPoint=OtherControlPoint) and (LastPoint=Point)) then begin
      Contour.fSegments.Add(TpvVectorPathSegmentCubicCurve.Create(LastPoint,ControlPoint,OtherControlPoint,Point));
     end;
     LastPoint:=Point;
    end;
    TpvVectorPathCommandType.Close:begin
     if assigned(Contour) then begin
      Contour.fClosed:=true;
      if LastPoint<>StartPoint then begin
       Contour.fSegments.Add(TpvVectorPathSegmentLine.Create(LastPoint,StartPoint));
      end;
     end;
     Contour:=nil;
    end;
   end;
  end;
 end;
end;

function TpvVectorPathShape.Clone:TpvVectorPathShape;
begin
 result:=TpvVectorPathShape.Create(self);
end;

function TpvVectorPathShape.GetBoundingBox:TpvVectorPathBoundingBox;
var Contour:TpvVectorPathContour;
begin
 result:=TpvVectorPathBoundingBox.Create(TpvVectorPathVector.Create(MaxDouble,MaxDouble),
                                         TpvVectorPathVector.Create(-MaxDouble,-MaxDouble));
 for Contour in fContours do begin
  if assigned(Contour) then begin
   result:=result.Combine(Contour.GetBoundingBox);
  end;
 end;
end;

function TpvVectorPathShape.GetBeginEndPoints:TpvVectorPathVectors;
var Count:TpvSizeInt;
    Contour:TpvVectorPathContour;
    Segment:TpvVectorPathSegment;
begin
 result:=nil;
 Count:=0;
 try
  for Contour in fContours do begin
   for Segment in Contour.fSegments do begin
    case Segment.Type_ of
     TpvVectorPathSegmentType.Line:begin
      if (Count+1)>=length(result) then begin
       SetLength(result,(Count+2)*2);
      end;
      result[Count]:=TpvVectorPathSegmentLine(Segment).Points[0];
      result[Count+1]:=TpvVectorPathSegmentLine(Segment).Points[1];
      inc(Count,2);
     end;
     TpvVectorPathSegmentType.QuadraticCurve:begin
      if (Count+1)>=length(result) then begin
       SetLength(result,(Count+2)*2);
      end;
      result[Count]:=TpvVectorPathSegmentQuadraticCurve(Segment).Points[0];
      result[Count+1]:=TpvVectorPathSegmentQuadraticCurve(Segment).Points[2];
      inc(Count,2);
     end;
     TpvVectorPathSegmentType.CubicCurve:begin
      if (Count+1)>=length(result) then begin
       SetLength(result,(Count+2)*2);
      end;
      result[Count]:=TpvVectorPathSegmentCubicCurve(Segment).Points[0];
      result[Count+1]:=TpvVectorPathSegmentCubicCurve(Segment).Points[3];
      inc(Count,2);
     end;
     else begin
     end;
    end;
   end;
  end;
 finally
  SetLength(result,Count);
 end;
end;

procedure TpvVectorPathShape.GetSegmentIntersectionPoints(const aIntersectionPoints:TpvVectorPathVectorList);
var SegmentIndex,OtherSegmentIndex:TpvSizeInt;
    Segment,OtherSegment:TpvVectorPathSegment;
    Segments:TpvVectorPathSegments;
    Contour:TpvVectorPathContour;
begin
 aIntersectionPoints.Clear;
 Segments:=TpvVectorPathSegments.Create;
 try
  Segments.OwnsObjects:=false;
  for Contour in fContours do begin
   for Segment in Contour.fSegments do begin
    Segments.Add(Segment);
   end;
  end;
  for SegmentIndex:=0 to Segments.Count-1 do begin
   Segment:=Segments[SegmentIndex];
   for OtherSegmentIndex:=SegmentIndex+1 to Segments.Count-1 do begin
    OtherSegment:=Segments[OtherSegmentIndex];
    Segment.GetIntersectionPointsWithSegment(OtherSegment,aIntersectionPoints);
   end;
  end;
 finally
  FreeAndNil(Segments);
 end;
 aIntersectionPoints.RemoveDuplicates;
end;

procedure TpvVectorPathShape.ConvertCubicCurvesToQuadraticCurves(const aPixelRatio:TpvDouble);
var ValueOne,NearlyZeroValue,LengthScale:TpvDouble;
    Contour:TpvVectorPathContour;
 procedure ConvertCubicCurveToQuadraticCurve(const aCP0,aCP1,aCP2,aCP3:TpvVectorPathVector);
 const MaxChoppedPoints=10;
 type TChoppedPoints=array[0..MaxChoppedPoints-1] of TpvVectorPathVector;
 var ChoppedPoints:TChoppedPoints;
  procedure OutputLine(const aP0,aP1:TpvVectorPathVector);
  begin
   Contour.fSegments.Add(TpvVectorPathSegmentLine.Create(aP0,aP1));
  end;
  procedure OutputQuad(const aP0,aP1,aP2:TpvVectorPathVector);
  begin
   Contour.fSegments.Add(TpvVectorPathSegmentQuadraticCurve.Create(aP0,aP1,aP2));
  end;
  procedure ChopCubicAt(Src,Dst:PpvVectorPathRawVectors;const t:TpvDouble); overload;
  var p0,p1,p2,p3,ab,bc,cd,abc,bcd,abcd:TpvVectorPathVector;
  begin
   if SameValue(t,1.0) then begin
    Dst^[0]:=Src^[0];
    Dst^[1]:=Src^[1];
    Dst^[2]:=Src^[2];
    Dst^[3]:=Src^[3];
    Dst^[4]:=Src^[3];
    Dst^[5]:=Src^[3];
    Dst^[6]:=Src^[3];
   end else begin
    p0:=Src^[0];
    p1:=Src^[1];
    p2:=Src^[2];
    p3:=Src^[3];
    ab:=p0.Lerp(p1,t);
    bc:=p1.Lerp(p2,t);
    cd:=p2.Lerp(p3,t);
    abc:=ab.Lerp(bc,t);
    bcd:=bc.Lerp(cd,t);
    abcd:=abc.Lerp(bcd,t);
    Dst^[0]:=p0;
    Dst^[1]:=ab;
    Dst^[2]:=abc;
    Dst^[3]:=abcd;
    Dst^[4]:=bcd;
    Dst^[5]:=cd;
    Dst^[6]:=p3;
   end;
  end;
  procedure ChopCubicAt(Src,Dst:PpvVectorPathRawVectors;const t0,t1:TpvDouble); overload;
  var p0,p1,p2,p3,
      ab0,bc0,cd0,abc0,bcd0,abcd0,
      ab1,bc1,cd1,abc1,bcd1,abcd1,
      Middle0,Middle1:TpvVectorPathVector;
  begin
   if SameValue(t1,1.0) then begin
    ChopCubicAt(Src,Dst,t0);
    Dst^[7]:=Src^[3];
    Dst^[8]:=Src^[3];
    Dst^[9]:=Src^[3];
   end else begin
    p0:=Src^[0];
    p1:=Src^[1];
    p2:=Src^[2];
    p3:=Src^[3];
    ab0:=p0.Lerp(p1,t0);
    bc0:=p1.Lerp(p2,t0);
    cd0:=p2.Lerp(p3,t0);
    abc0:=ab0.Lerp(bc0,t0);
    bcd0:=bc0.Lerp(cd0,t0);
    abcd0:=abc0.Lerp(bcd0,t0);
    ab1:=p0.Lerp(p1,t1);
    bc1:=p1.Lerp(p2,t1);
    cd1:=p2.Lerp(p3,t1);
    abc1:=ab1.Lerp(bc1,t1);
    bcd1:=bc1.Lerp(cd1,t1);
    abcd1:=abc1.Lerp(bcd1,t1);
    Middle0:=abc0.Lerp(bcd0,t1);
    Middle1:=abc1.Lerp(bcd1,t0);
    Dst^[0]:=p0;
    Dst^[1]:=ab0;
    Dst^[2]:=abc0;
    Dst^[3]:=abcd0;
    Dst^[4]:=Middle0;
    Dst^[5]:=Middle1;
    Dst^[6]:=abcd1;
    Dst^[7]:=bcd1;
    Dst^[8]:=cd1;
    Dst^[9]:=p3;
   end;
  end;
  function ChopCubicAtInflections(const aSrc:array of TpvVectorPathVector;out aDst:TChoppedPoints):TpvSizeInt;
   function ValidUnitDivide(aNumerator,aDenominator:TpvDouble;out aRatio:TpvDouble):boolean;
   begin
    if aNumerator<0.0 then begin
     aNumerator:=-aNumerator;
     aDenominator:=-aDenominator;
    end;
    if IsZero(aNumerator) or IsZero(aDenominator) or (aNumerator>=aDenominator) then begin
     result:=false;
    end else begin
     aRatio:=aNumerator/aDenominator;
     if IsNaN(aRatio) or IsZero(aRatio) then begin
      result:=false;
     end else begin
      result:=true;
     end;
    end;
   end;
   function FindUnitQuadRoots(const A,B,C:TpvDouble;out aRoot0,aRoot1:TpvDouble):TpvSizeInt;
   var dr,Q:TpvDouble;
   begin
    if IsZero(A) then begin
     if ValidUnitDivide(-C,B,aRoot0) then begin
      result:=1;
     end else begin
      result:=0;
     end;
    end else begin
     dr:=sqr(B)-(4.0*A*C);
     if dr<0.0 then begin
      result:=0;
     end else begin
      dr:=sqrt(dr);
      if IsInfinite(dr) or IsNaN(dr) then begin
       result:=0;
      end else begin
       if B<0.0 then begin
        Q:=-(B-dr)*0.5;
       end else begin
        Q:=-(B+dr)*0.5;
       end;
       if ValidUnitDivide(Q,A,aRoot0) then begin
        if ValidUnitDivide(C,Q,aRoot1) then begin
         result:=2;
         if aRoot0>aRoot1 then begin
          Q:=aRoot0;
          aRoot0:=aRoot1;
          aRoot1:=Q;
         end else if SameValue(aRoot0,aRoot1) then begin
          dec(result);
         end;
        end else begin
         result:=1;
        end;
       end else begin
        if ValidUnitDivide(C,Q,aRoot0) then begin
         result:=1;
        end else begin
         result:=0;
        end;
       end;
      end;
     end;
    end;
   end;
  var Index,Count:TpvSizeInt;
      Times:array[0..1] of TpvDouble;
      Ax,Ay,Bx,By,Cx,Cy,t0,t1,LastTime:TpvDouble;
      Src:PpvVectorPathVector;
      Dst:PpvVectorPathVector;
  begin
   Ax:=aSrc[1].x-aSrc[0].x;
   Ay:=aSrc[1].y-aSrc[0].y;
   Bx:=aSrc[2].x-(2.0*aSrc[1].x)+aSrc[0].x;
   By:=aSrc[2].y-(2.0*aSrc[1].y)+aSrc[0].y;
   Cx:=aSrc[3].x+(3.0*(aSrc[1].x-aSrc[2].x))-aSrc[0].x;
   Cy:=aSrc[3].y+(3.0*(aSrc[1].y-aSrc[2].y))-aSrc[0].y;
   Count:=FindUnitQuadRoots((Bx*Cy)-(By*Cx),(Ax*Cy)-(Ay*Cx),(Ax*By)-(Ay*Bx),Times[0],Times[1]);
   if Count=0 then begin
    aDst[0]:=aSrc[0];
    aDst[1]:=aSrc[1];
    aDst[2]:=aSrc[2];
    aDst[3]:=aSrc[3];
   end else begin
    Src:=@aSrc[0];
    Dst:=@aDst[0];
    Index:=0;
    while Index<(Count-1) do begin
     t0:=Times[Index+0];
     t1:=Times[Index+1];
     if Index<>0 then begin
      LastTime:=Times[Index-1];
      t0:=Clamp((t0-LastTime)/(1.0-LastTime),0.0,1.0);
      t1:=Clamp((t1-LastTime)/(1.0-LastTime),0.0,1.0);
     end;
     ChopCubicAt(TpvPointer(Src),TpvPointer(Dst),t0,t1);
     inc(Src,4);
     inc(Dst,6);
     inc(Index,2);
    end;
    if Index<Count then begin
     t0:=Times[Index];
     if Index<>0 then begin
      LastTime:=Times[Index-1];
      t0:=Clamp((t0-LastTime)/(1.0-LastTime),0.0,1.0);
     end;
     ChopCubicAt(TpvPointer(Src),TpvPointer(Dst),t0);
    end;
   end;
   result:=Count+1;
  end;
  function IsNearlyZeroValue(const aValue:TpvDouble):Boolean;
  begin
   result:=(aValue<NearlyZeroValue) or IsZero(aValue);
  end;
  procedure ConvertNonInflectCubicToQuads(const aPoints:PpvVectorPathRawVectors;const aSquaredTolerance:TpvDouble;const aSubLevel:TpvSizeInt=0;const aPreserveFirstTangent:boolean=true;const aPreserveLastTangent:boolean=true);
  const MaxSubdivisions=10;
  var ab,dc,c0,c1,c:TpvVectorPathVector;
      p:array[0..7] of TpvVectorPathVector;
  begin
   ab:=aPoints^[1]-aPoints^[0];
   dc:=aPoints^[2]-aPoints^[3];
   if IsNearlyZeroValue(ab.LengthSquared) then begin
    if IsNearlyZeroValue(dc.LengthSquared) then begin
     OutputLine(aPoints^[0],aPoints^[3]);
     exit;
    end else begin
     ab:=aPoints^[2]-aPoints^[0];
    end;
   end;
   if IsNearlyZeroValue(dc.LengthSquared) then begin
    dc:=aPoints^[1]-aPoints^[3];
   end;
   ab.x:=ab.x*LengthScale;
   ab.y:=ab.y*LengthScale;
   dc.x:=dc.x*LengthScale;
   dc.y:=dc.y*LengthScale;
   c0:=aPoints^[0]+ab;
   c1:=aPoints^[3]+dc;
   if (aSubLevel>MaxSubdivisions) or ((c0-c1).LengthSquared<aSquaredTolerance) then begin
    if aPreserveFirstTangent=aPreserveLastTangent then begin
     c:=c0.Lerp(c1,0.5);
    end else if aPreserveFirstTangent then begin
     c:=c0;
    end else begin
     c:=c1;
    end;
    OutputQuad(aPoints^[0],c,aPoints^[3]);
   end else begin
    ChopCubicAt(aPoints,TpvPointer(@p[0]),0.5);
    ConvertNonInflectCubicToQuads(TpvPointer(@p[0]),aSquaredTolerance,aSubLevel+1,aPreserveFirstTangent,false);
    ConvertNonInflectCubicToQuads(TpvPointer(@p[3]),aSquaredTolerance,aSubLevel+1,false,aPreserveLastTangent);
   end;
  end;
 var Count,Index:TpvSizeInt;
     Points:array[0..3] of TpvVectorPathVector;
 begin
  Points[0]:=aCP0;
  Points[1]:=aCP1;
  Points[2]:=aCP2;
  Points[3]:=aCP3;
  if (IsNaN(Points[0].x) or IsInfinite(Points[0].x)) or
     (IsNaN(Points[0].y) or IsInfinite(Points[0].y)) or
     (IsNaN(Points[1].x) or IsInfinite(Points[1].x)) or
     (IsNaN(Points[1].y) or IsInfinite(Points[1].y)) or
     (IsNaN(Points[2].x) or IsInfinite(Points[2].x)) or
     (IsNaN(Points[2].y) or IsInfinite(Points[2].y)) or
     (IsNaN(Points[3].x) or IsInfinite(Points[3].x)) or
     (IsNaN(Points[3].y) or IsInfinite(Points[3].y)) then begin
   OutputLine(Points[0],Points[2]);
  end else begin
   Count:=ChopCubicAtInflections(Points,ChoppedPoints);
   if Count>0 then begin
    for Index:=0 to Count-1 do begin
     ConvertNonInflectCubicToQuads(TpvPointer(@ChoppedPoints[Index*3]),ValueOne,0,true,true);
    end;
   end;
  end;
 end;
var Segments:TpvVectorPathSegments;
    Segment:TpvVectorPathSegment;
begin
 ValueOne:=aPixelRatio;
 NearlyZeroValue:=ValueOne/TpvInt64(1 shl 18);
 LengthScale:=ValueOne*1.5;
 for Contour in fContours do begin
  Segments:=Contour.fSegments;
  try
   Contour.fSegments:=TpvVectorPathSegments.Create;
   Contour.fSegments.OwnsObjects:=true;
   for Segment in Segments do begin
    case Segment.Type_ of
     TpvVectorPathSegmentType.CubicCurve:begin
      ConvertCubicCurveToQuadraticCurve(TpvVectorPathSegmentCubicCurve(Segment).Points[0],
                                        TpvVectorPathSegmentCubicCurve(Segment).Points[1],
                                        TpvVectorPathSegmentCubicCurve(Segment).Points[2],
                                        TpvVectorPathSegmentCubicCurve(Segment).Points[3]);
     end;
     else begin
      Contour.fSegments.Add(Segment.Clone);
     end;
    end;
   end;
  finally
   FreeAndNil(Segments);
  end;
 end;
end;

procedure TpvVectorPathShape.ConvertCurvesToLines(const aPixelRatio:TpvDouble);
const CurveRecursionLimit=16;
var Contour:TpvVectorPathContour;
    CurveTessellationTolerance,CurveTessellationToleranceSquared,
    LastX,LastY:TpvDouble;
 procedure DoLineTo(const aToX,aToY:TpvDouble);
 begin
  if (not SameValue(LastX,aToX)) or (not SameValue(LastY,aToY)) then begin
   Contour.fSegments.Add(TpvVectorPathSegmentLine.Create(TpvVectorPathVector.Create(LastX,LastY),TpvVectorPathVector.Create(aToX,aToY)));
  end;
  LastX:=aToX;
  LastY:=aToY;
 end;
 procedure DoQuadraticCurveTo(const aLX,aLY,aC0X,aC0Y,aA0X,aA0Y:TpvDouble);
  procedure Recursive(const x1,y1,x2,y2,x3,y3:TpvDouble;const Level:TpvInt32);
  var x12,y12,x23,y23,x123,y123,dx,dy:TpvDouble;
  begin
   x12:=(x1+x2)*0.5;
   y12:=(y1+y2)*0.5;
   x23:=(x2+x3)*0.5;
   y23:=(y2+y3)*0.5;
   x123:=(x12+x23)*0.5;
   y123:=(y12+y23)*0.5;
   dx:=x3-x1;
   dy:=y3-y1;
   if (Level>CurveRecursionLimit) or
      ((Level>0) and
       (sqr(((x2-x3)*dy)-((y2-y3)*dx))<((sqr(dx)+sqr(dy))*CurveTessellationToleranceSquared))) then begin
    DoLineTo(x3,y3);
   end else begin
    Recursive(x1,y1,x12,y12,x123,y123,Level+1);
    Recursive(x123,y123,x23,y23,x3,y3,Level+1);
   end;
  end;
 begin
  LastX:=aLX;
  LastY:=aLY;
  Recursive(aLX,aLY,aC0X,aC0Y,aA0X,aA0Y,0);
  DoLineTo(aA0X,aA0Y);
 end;
 procedure DoCubicCurveTo(const aLX,aLY,aC0X,aC0Y,aC1X,aC1Y,aA0X,aA0Y:TpvDouble);
  procedure Recursive(const x1,y1,x2,y2,x3,y3,x4,y4:TpvDouble;const Level:TpvInt32);
  var x12,y12,x23,y23,x34,y34,x123,y123,x234,y234,x1234,y1234,dx,dy:TpvDouble;
  begin
   x12:=(x1+x2)*0.5;
   y12:=(y1+y2)*0.5;
   x23:=(x2+x3)*0.5;
   y23:=(y2+y3)*0.5;
   x34:=(x3+x4)*0.5;
   y34:=(y3+y4)*0.5;
   x123:=(x12+x23)*0.5;
   y123:=(y12+y23)*0.5;
   x234:=(x23+x34)*0.5;
   y234:=(y23+y34)*0.5;
   x1234:=(x123+x234)*0.5;
   y1234:=(y123+y234)*0.5;
   dx:=x4-x1;
   dy:=y4-y1;
   if (Level>CurveRecursionLimit) or
      ((Level>0) and
       (sqr(abs(((x2-x4)*dy)-((y2-y4)*dx))+
            abs(((x3-x4)*dy)-((y3-y4)*dx)))<((sqr(dx)+sqr(dy))*CurveTessellationToleranceSquared))) then begin
    DoLineTo(x4,y4);
   end else begin
    Recursive(x1,y1,x12,y12,x123,y123,x1234,y1234,Level+1);
    Recursive(x1234,y1234,x234,y234,x34,y34,x4,y4,Level+1);
   end;
  end;
 begin
  LastX:=aLX;
  LastY:=aLY;
  Recursive(aLX,aLY,aC0X,aC0Y,aC1X,aC1Y,aA0X,aA0Y,0);
  DoLineTo(aA0X,aA0Y);
 end;
var Segments:TpvVectorPathSegments;
    Segment:TpvVectorPathSegment;
begin
 CurveTessellationTolerance:=aPixelRatio*0.125;
 CurveTessellationToleranceSquared:=CurveTessellationTolerance*CurveTessellationTolerance;
 LastX:=0.0;
 LastY:=0.0;
 for Contour in fContours do begin
  Segments:=Contour.fSegments;
  try
   Contour.fSegments:=TpvVectorPathSegments.Create;
   Contour.fSegments.OwnsObjects:=true;
   for Segment in Segments do begin
    case Segment.Type_ of
     TpvVectorPathSegmentType.QuadraticCurve:begin
      DoQuadraticCurveTo(TpvVectorPathSegmentQuadraticCurve(Segment).Points[0].x,TpvVectorPathSegmentQuadraticCurve(Segment).Points[0].y,
                         TpvVectorPathSegmentQuadraticCurve(Segment).Points[1].x,TpvVectorPathSegmentQuadraticCurve(Segment).Points[1].y,
                         TpvVectorPathSegmentQuadraticCurve(Segment).Points[2].x,TpvVectorPathSegmentQuadraticCurve(Segment).Points[2].y);
     end;
     TpvVectorPathSegmentType.CubicCurve:begin
      DoCubicCurveTo(TpvVectorPathSegmentCubicCurve(Segment).Points[0].x,TpvVectorPathSegmentCubicCurve(Segment).Points[0].y,
                     TpvVectorPathSegmentCubicCurve(Segment).Points[1].x,TpvVectorPathSegmentCubicCurve(Segment).Points[1].y,
                     TpvVectorPathSegmentCubicCurve(Segment).Points[2].x,TpvVectorPathSegmentCubicCurve(Segment).Points[2].y,
                     TpvVectorPathSegmentCubicCurve(Segment).Points[3].x,TpvVectorPathSegmentCubicCurve(Segment).Points[3].y);
     end;
     else begin
      Contour.fSegments.Add(Segment.Clone);
     end;
    end;
   end;
  finally
   FreeAndNil(Segments);
  end;
 end;
end;

function TpvVectorPathShape.GetSignedDistance(const aX,aY,aScale:TpvDouble;out aInsideOutsideSign:TpvInt32):TpvDouble;
const CurveTessellationTolerance=0.25;
      CurveTessellationToleranceSquared=CurveTessellationTolerance*CurveTessellationTolerance;
      CurveRecursionLimit=16;
var ResultDistance,LastX,LastY:TpvDouble;
 procedure LineDistance(const aPX,aPY,aAX,aAY,aBX,aBY:TpvDouble);
 var pax,pay,bax,bay,t:TpvDouble;
 begin
  pax:=aPX-aAX;
  pay:=aPY-aAY;
  bax:=aBX-aAX;
  bay:=aBY-aAY;
  if ((aAY>aPY)<>(aBY>aPY)) and (pax<(bax*(pay/bay))) then begin
   aInsideOutsideSign:=-aInsideOutsideSign;
  end;
  t:=sqr(bax)+sqr(bay);
  if t>0.0 then begin
   t:=Min(Max(((pax*bax)+(pay*bay))/t,0.0),1.0);
  end else begin
   t:=0.0;
  end;
  ResultDistance:=Min(ResultDistance,sqr(pax-(bax*t))+sqr(pay-(bay*t)));
 end;
 procedure DoLineTo(const aLX,aLY,aToX,aToY:TpvDouble);
 begin
  LineDistance(aX,aY,aLX,aLY,aToX,aToY);
  LastX:=aToX;
  LastY:=aToY;
 end;
 procedure DoQuadraticCurveTo(const aLX,aLY,aC0X,aC0Y,aA0X,aA0Y:TpvDouble);
  procedure Recursive(const x1,y1,x2,y2,x3,y3:TpvDouble;const Level:TpvInt32);
  var x12,y12,x23,y23,x123,y123,dx,dy:TpvDouble;
  begin
   x12:=(x1+x2)*0.5;
   y12:=(y1+y2)*0.5;
   x23:=(x2+x3)*0.5;
   y23:=(y2+y3)*0.5;
   x123:=(x12+x23)*0.5;
   y123:=(y12+y23)*0.5;
   dx:=x3-x1;
   dy:=y3-y1;
   if (Level>CurveRecursionLimit) or
      ((Level>0) and
       (sqr(((x2-x3)*dy)-((y2-y3)*dx))<((sqr(dx)+sqr(dy))*CurveTessellationToleranceSquared))) then begin
    DoLineTo(LastX,LastY,x3,y3);
   end else begin
    Recursive(x1,y1,x12,y12,x123,y123,level+1);
    Recursive(x123,y123,x23,y23,x3,y3,level+1);
   end;
  end;
 begin
  LastX:=aLX;
  LastY:=aLY;
  Recursive(aLX,aLY,aC0X,aC0Y,aA0X,aA0Y,0);
  DoLineTo(LastX,LastY,aA0X,aA0Y);
 end;
 procedure DoCubicCurveTo(const aLX,aLY,aC0X,aC0Y,aC1X,aC1Y,aA0X,aA0Y:TpvDouble);
  procedure Recursive(const x1,y1,x2,y2,x3,y3,x4,y4:TpvDouble;const Level:TpvInt32);
  var x12,y12,x23,y23,x34,y34,x123,y123,x234,y234,x1234,y1234,dx,dy:TpvDouble;
  begin
   x12:=(x1+x2)*0.5;
   y12:=(y1+y2)*0.5;
   x23:=(x2+x3)*0.5;
   y23:=(y2+y3)*0.5;
   x34:=(x3+x4)*0.5;
   y34:=(y3+y4)*0.5;
   x123:=(x12+x23)*0.5;
   y123:=(y12+y23)*0.5;
   x234:=(x23+x34)*0.5;
   y234:=(y23+y34)*0.5;
   x1234:=(x123+x234)*0.5;
   y1234:=(y123+y234)*0.5;
   dx:=x4-x1;
   dy:=y4-y1;
   if (Level>CurveRecursionLimit) or
      ((Level>0) and
       (sqr(abs(((x2-x4)*dy)-((y2-y4)*dx))+
            abs(((x3-x4)*dy)-((y3-y4)*dx)))<((sqr(dx)+sqr(dy))*CurveTessellationToleranceSquared))) then begin
    DoLineTo(LastX,LastY,x4,y4);
   end else begin
    Recursive(x1,y1,x12,y12,x123,y123,x1234,y1234,Level+1);
    Recursive(x1234,y1234,x234,y234,x34,y34,x4,y4,Level+1);
   end;
  end;
 begin
  LastX:=aLX;
  LastY:=aLY;
  Recursive(aLX,aLY,aC0X,aC0Y,aC1X,aC1Y,aA0X,aA0Y,0);
  DoLineTo(LastX,LastY,aA0X,aA0Y);
 end;
var Contour:TpvVectorPathContour;
    Segments:TpvVectorPathSegments;
    Segment:TpvVectorPathSegment;
begin
 ResultDistance:=Infinity;
 aInsideOutsideSign:=1;
 LastX:=0.0;
 LastY:=0.0;
 for Contour in fContours do begin
  for Segment in Contour.fSegments do begin
   case Segment.Type_ of
    TpvVectorPathSegmentType.Line:begin
     DoLineTo(TpvVectorPathSegmentLine(Segment).Points[0].x,TpvVectorPathSegmentLine(Segment).Points[0].y,
              TpvVectorPathSegmentLine(Segment).Points[1].x,TpvVectorPathSegmentLine(Segment).Points[1].y);
    end;
    TpvVectorPathSegmentType.QuadraticCurve:begin
     DoQuadraticCurveTo(TpvVectorPathSegmentQuadraticCurve(Segment).Points[0].x,TpvVectorPathSegmentQuadraticCurve(Segment).Points[0].y,
                        TpvVectorPathSegmentQuadraticCurve(Segment).Points[1].x,TpvVectorPathSegmentQuadraticCurve(Segment).Points[1].y,
                        TpvVectorPathSegmentQuadraticCurve(Segment).Points[2].x,TpvVectorPathSegmentQuadraticCurve(Segment).Points[2].y);
    end;
    TpvVectorPathSegmentType.CubicCurve:begin
     DoCubicCurveTo(TpvVectorPathSegmentCubicCurve(Segment).Points[0].x,TpvVectorPathSegmentCubicCurve(Segment).Points[0].y,
                    TpvVectorPathSegmentCubicCurve(Segment).Points[1].x,TpvVectorPathSegmentCubicCurve(Segment).Points[1].y,
                    TpvVectorPathSegmentCubicCurve(Segment).Points[2].x,TpvVectorPathSegmentCubicCurve(Segment).Points[2].y,
                    TpvVectorPathSegmentCubicCurve(Segment).Points[3].x,TpvVectorPathSegmentCubicCurve(Segment).Points[3].y);
    end;
    else begin
    end;
   end;
  end;
 end;
 result:=sqrt(ResultDistance);
end;

{ TpvVectorPath }

constructor TpvVectorPath.Create;
begin
 inherited Create;
 fCommands:=TpvVectorPathCommandList.Create(true);
 fFillRule:=TpvVectorPathFillRule.EvenOdd;
end;

constructor TpvVectorPath.CreateFromSVGPath(const aCommands:TpvRawByteString);
var i,SrcPos,SrcLen,large_arc_flag,sweep_flag:TpvInt32;
    lx,ly,lcx,lcy,x0,y0,x1,y1,x2,y2,lmx,lmy,rx,ry,x_axis_rotation,x,y:TpvDouble;
    Src:TpvRawByteString;
    Command,LastCommand:AnsiChar;
 procedure SkipBlank;
 begin
  while (SrcPos<=SrcLen) and (Src[SrcPos] in [#0..#32]) do begin
   inc(SrcPos);
  end;
 end;
 function GetFloat:TpvDouble;
 var StartPos:TpvInt32;
 begin
  SkipBlank;
  StartPos:=SrcPos;
  if (SrcPos<=SrcLen) and (Src[SrcPos] in ['-','+']) then begin
   inc(SrcPos);
  end;
  while (SrcPos<=SrcLen) and (Src[SrcPos] in ['0'..'9']) do begin
   inc(SrcPos);
  end;
  if (SrcPos<=SrcLen) and (Src[SrcPos] in ['.']) then begin
   inc(SrcPos);
   while (SrcPos<=SrcLen) and (Src[SrcPos] in ['0'..'9']) do begin
    inc(SrcPos);
   end;
  end;
  if (SrcPos<=SrcLen) and (Src[SrcPos] in ['e','E']) then begin
   inc(SrcPos);
   if (SrcPos<=SrcLen) and (Src[SrcPos] in ['-','+']) then begin
    inc(SrcPos);
   end;
   while (SrcPos<=SrcLen) and (Src[SrcPos] in ['0'..'9']) do begin
    inc(SrcPos);
   end;
  end;
  if StartPos<SrcPos then begin
   result:=ConvertStringToDouble(TpvRawByteString(copy(String(Src),StartPos,SrcPos-StartPos)),rmNearest,nil,-1);
  end else begin
   result:=0.0;
  end;
  SkipBlank;
 end;
 function GetInt:TpvInt32;
 var s:TpvRawByteString;
 begin
  SkipBlank;
  s:='';
  if (SrcPos<=SrcLen) and (Src[SrcPos] in ['-','+']) then begin
   s:=s+Src[SrcPos];
   inc(SrcPos);
  end;
  while (SrcPos<=SrcLen) and (Src[SrcPos] in ['0'..'9']) do begin
   s:=s+Src[SrcPos];
   inc(SrcPos);
  end;
  if (SrcPos<=SrcLen) and (Src[SrcPos] in ['.']) then begin
   inc(SrcPos);
   while (SrcPos<=SrcLen) and (Src[SrcPos] in ['0'..'9']) do begin
    inc(SrcPos);
   end;
  end;
  if (SrcPos<=SrcLen) and (Src[SrcPos] in ['e','E']) then begin
   inc(SrcPos);
   if (SrcPos<=SrcLen) and (Src[SrcPos] in ['-','+']) then begin
    inc(SrcPos);
   end;
   while (SrcPos<=SrcLen) and (Src[SrcPos] in ['0'..'9']) do begin
    inc(SrcPos);
   end;
  end;
  SkipBlank;
  result:=Trunc(ConvertStringToDouble(s,rmNearest,nil,-1));
 end;
 procedure ConvertArcToCubicCurves(rx,ry,x_axis_rotation:TpvDouble;large_arc_flag,sweep_flag:TpvInt32;x,y:TpvDouble);
 var sin_th,cos_th,a00,a01,a10,a11,x0,y0,x1,y1,xc,yc,d,sfactor,sfactor_sq,
     th0,th1,th_arc,dx,dy,dx1,dy1,Pr1,Pr2,Px,Py,check:TpvDouble;
     i,n_segs:TpvInt32;
  procedure ProcessSegment(xc,yc,th0,th1,rx,ry,x_axis_rotation:TpvDouble);
  var sin_th,cos_th,a00,a01,a10,a11,x1,y1,x2,y2,x3,y3,t,th_half:TpvDouble;
      i:TpvInt32;
  begin
   sin_th:=sin(x_axis_rotation*deg2rad);
   cos_th:=cos(x_axis_rotation*deg2rad);
   a00:=cos_th*rx;
   a01:=(-sin_th)*ry;
   a10:=sin_th*rx;
   a11:=cos_th*ry;
   th_half:=0.5*(th1-th0);
   t:=(8.0/3.0)*sin(th_half*0.5)*sin(th_half*0.5)/sin(th_half);
   x1:=(xc+cos(th0))-(t*sin(th0));
   y1:=(yc+sin(th0))+(t*cos(th0));
   x3:=xc+cos(th1);
   y3:=yc+sin(th1);
   x2:=x3+(t*sin(th1));
   y2:=y3-(t*cos(th1));
   CubicCurveTo((a00*x1)+(a01*y1),(a10*x1)+(a11*y1),
                (a00*x2)+(a01*y2),(a10*x2)+(a11*y2),
                (a00*x3)+(a01*y3),(a10*x3)+(a11*y3));
  end;
 begin
  if (abs(rx)<1e-14) or (abs(ry)<1e-14) then begin
   LineTo(x,y);
   exit;
  end;
  sin_th:=sin(x_axis_rotation*deg2rad);
  cos_th:=cos(x_axis_rotation*deg2rad);
  dx:=(lx-x)*0.5;
  dy:=(ly-y)*0.5;
  dx1:=(cos_th*dx)+(sin_th*dy);
  dy1:=(cos_th*dy)-(sin_th*dx);
  Pr1:=sqr(rx);
  Pr2:=sqr(ry);
  Px:=sqr(dx1);
  Py:=sqr(dy1);
  check:=(Px/Pr1)+(Py/Pr2);
  if check>1.0 then begin
   rx:=rx*sqrt(check);
   ry:=ry*sqrt(check);
  end;
  a00:=cos_th/rx;
  a01:=sin_th/rx;
  a10:=(-sin_th)/ry;
  a11:=cos_th/ry;
  x0:=(a00*lx)+(a01*ly);
  y0:=(a10*lx)+(a11*ly);
  x1:=(a00*x)+(a01*y);
  y1:=(a10*x)+(a11*y);
  d:=sqr(x1-x0)+sqr(y1-y0);
  sfactor_sq:=(1.0/d)-0.25;
  if sfactor_sq<0.0 then begin
   sfactor_sq:=0.0;
  end;
  sfactor:=sqrt(sfactor_sq);
  if sweep_flag=large_arc_flag then begin
   sfactor:=-sfactor;
  end;
  xc:=(0.5*(x0+x1))-(sfactor*(y1-y0));
  yc:=(0.5*(y0+y1))+(sfactor*(x1-x0));
  th0:=arctan2(y0-yc,x0-xc);
  th1:=arctan2(y1-yc,x1-xc);
  th_arc:=th1-th0;
  if (th_arc<0.0) and (sweep_flag<>0) then begin
   th_arc:=th_arc+TwoPI;
  end else if (th_arc>0.0) and (sweep_flag=0) then begin
   th_arc:=th_arc-TwoPI;
  end;
  n_segs:=ceil(abs(th_arc/((pi*0.5)+0.001)));
  for i:=0 to n_segs-1 do begin
   ProcessSegment(xc,yc,
                  th0+((i*th_arc)/n_segs),
                  th0+(((i+1)*th_arc)/n_segs),
                  rx,ry,
                  x_axis_rotation);
  end;
  if n_segs=0 then begin
   LineTo(x,y);
  end;
 end;
begin
 Create;
 SrcLen:=length(aCommands);
 Src:=aCommands;
 for i:=1 to SrcLen do begin
  if Src[i] in [#0..#32,','] then begin
   Src[i]:=' ';
  end;
 end;
 lx:=0;
 ly:=0;
 lcx:=0;
 lcy:=0;
 lmx:=0;
 lmy:=0;
 SrcPos:=1;
 Command:=#0;
 LastCommand:=#0;
 while SrcPos<=SrcLen do begin
  SkipBlank;
  if SrcPos<=SrcLen then begin
   if Src[SrcPos] in ['A'..'Z','a'..'z'] then begin
    Command:=Src[SrcPos];
    inc(SrcPos);
    SkipBlank;
   end;
   case Command of
    'Z','z':begin
     Close;
     lx:=lmx;
     ly:=lmy;
    end;
    'H':begin
     lx:=GetFloat;
     LineTo(lx,ly);
    end;
    'h':begin
     lx:=lx+GetFloat;
     LineTo(lx,ly);
    end;
    'V':begin
     ly:=GetFloat;
     LineTo(lx,ly);
    end;
    'v':begin
     ly:=ly+GetFloat;
     LineTo(lx,ly);
    end;
    'M':begin
     lx:=GetFloat;
     ly:=GetFloat;
     lmx:=lx;
     lmy:=ly;
     MoveTo(lx,ly);
     Command:='L';
    end;
    'm':begin
     lx:=lx+GetFloat;
     ly:=ly+GetFloat;
     lmx:=lx;
     lmy:=ly;
     MoveTo(lx,ly);
     Command:='l';
    end;
    'L':begin
     lx:=GetFloat;
     ly:=GetFloat;
     LineTo(lx,ly);
    end;
    'l':begin
     lx:=lx+GetFloat;
     ly:=ly+GetFloat;
     LineTo(lx,ly);
    end;
    'A':begin
     rx:=GetFloat;
     ry:=GetFloat;
     x_axis_rotation:=GetFloat;
     large_arc_flag:=GetInt;
     sweep_flag:=GetInt;
     x:=GetFloat;
     y:=GetFloat;
     ConvertArcToCubicCurves(rx,ry,x_axis_rotation,large_arc_flag,sweep_flag,x,y);
     lx:=x;
     ly:=y;
    end;
    'a':begin
     rx:=GetFloat;
     ry:=GetFloat;
     x_axis_rotation:=GetFloat;
     large_arc_flag:=GetInt;
     sweep_flag:=GetInt;
     x:=lx+GetFloat;
     y:=ly+GetFloat;
     ConvertArcToCubicCurves(rx,ry,x_axis_rotation,large_arc_flag,sweep_flag,x,y);
     lx:=x;
     ly:=y;
    end;
    'T':begin
     lcx:=lx+(lx-lcx);
     lcy:=ly+(ly-lcy);
     if not (LastCommand in ['T','t','Q','q']) then begin
      lcx:=lx;
      lcy:=ly;
     end;
     lx:=GetFloat;
     ly:=GetFloat;
     QuadraticCurveTo(lcx,lcy,lx,ly);
    end;
    't':begin
     lcx:=lx+(lx-lcx);
     lcy:=ly+(ly-lcy);
     if not (LastCommand in ['T','t','Q','q']) then begin
      lcx:=lx;
      lcy:=ly;
     end;
     lx:=lx+GetFloat;
     ly:=ly+GetFloat;
     QuadraticCurveTo(lcx,lcy,lx,ly);
    end;
    'S':begin
     x0:=lx+(lx-lcx);
     y0:=ly+(ly-lcy);
     if not (LastCommand in ['S','s','C','c']) then begin
      x0:=lx;
      y0:=ly;
     end;
     x1:=GetFloat;
     y1:=GetFloat;
     x2:=GetFloat;
     y2:=GetFloat;
     lcx:=x1;
     lcy:=y1;
     lx:=x2;
     ly:=y2;
     CubicCurveTo(x0,y0,x1,y1,x2,y2);
    end;
    's':begin
     x0:=lx+(lx-lcx);
     y0:=ly+(ly-lcy);
     if not (LastCommand in ['S','s','C','c']) then begin
      x0:=lx;
      y0:=ly;
     end;
     x1:=lx+GetFloat;
     y1:=ly+GetFloat;
     x2:=lx+GetFloat;
     y2:=ly+GetFloat;
     lcx:=x1;
     lcy:=y1;
     lx:=x2;
     ly:=y2;
     CubicCurveTo(x0,y0,x1,y1,x2,y2);
    end;
    'Q':begin
     x0:=GetFloat;
     y0:=GetFloat;
     x1:=GetFloat;
     y1:=GetFloat;
     lcx:=x0;
     lcy:=y0;
     lx:=x1;
     ly:=y1;
     QuadraticCurveTo(x0,y0,x1,y1);
    end;
    'q':begin
     x0:=lx+GetFloat;
     y0:=ly+GetFloat;
     x1:=lx+GetFloat;
     y1:=ly+GetFloat;
     lcx:=x0;
     lcy:=y0;
     lx:=x1;
     ly:=y1;
     QuadraticCurveTo(x0,y0,x1,y1);
    end;
    'C':begin
     x0:=GetFloat;
     y0:=GetFloat;
     x1:=GetFloat;
     y1:=GetFloat;
     x2:=GetFloat;
     y2:=GetFloat;
     lcx:=x1;
     lcy:=y1;
     lx:=x2;
     ly:=y2;
     CubicCurveTo(x0,y0,x1,y1,x2,y2);
    end;
    'c':begin
     x0:=lx+GetFloat;
     y0:=ly+GetFloat;
     x1:=lx+GetFloat;
     y1:=ly+GetFloat;
     x2:=lx+GetFloat;
     y2:=ly+GetFloat;
     lcx:=x1;
     lcy:=y1;
     lx:=x2;
     ly:=y2;
     CubicCurveTo(x0,y0,x1,y1,x2,y2);
    end;
    else begin
     break;
    end;
   end;
  end else begin
   break;
  end;
 end;
end;

constructor TpvVectorPath.CreateFromShape(const aShape:TpvVectorPathShape);
begin
 Create;
 Assign(aShape);
end;

destructor TpvVectorPath.Destroy;
begin
 FreeAndNil(fCommands);
 inherited Destroy;
end;

procedure TpvVectorPath.Assign(const aFrom:TpvVectorPath);
var Index:TpvSizeInt;
    SrcCmd:TpvVectorPathCommand;
begin
 fCommands.Clear;
 for Index:=0 to aFrom.fCommands.Count-1 do begin
  SrcCmd:=aFrom.fCommands[Index];
  fCommands.Add(TpvVectorPathCommand.Create(SrcCmd.fCommandType,SrcCmd.fX0,SrcCmd.fY0,SrcCmd.fX1,SrcCmd.fY1,SrcCmd.fX2,SrcCmd.fY2));
 end;
 fFillRule:=aFrom.fFillRule;
end;

procedure TpvVectorPath.Assign(const aShape:TpvVectorPathShape);
var Contour:TpvVectorPathContour;
    Segment:TpvVectorPathSegment;
    First:boolean;
    Last,Start:TpvVectorPathVector;
begin
 fCommands.Clear;
 if assigned(aShape) then begin
  fFillRule:=aShape.fFillRule;
  First:=true;
  Last:=TpvVectorPathVector.Create(0.0,0.0);
  Start:=TpvVectorPathVector.Create(0.0,0.0);
  for Contour in aShape.fContours do begin
   for Segment in Contour.fSegments do begin
    case Segment.Type_ of
     TpvVectorPathSegmentType.Line:begin
      if First then begin
       First:=false;
       Start:=TpvVectorPathSegmentLine(Segment).Points[0];
       Last:=Start;
       fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.MoveTo,
                                                 TpvVectorPathSegmentLine(Segment).Points[0].x,TpvVectorPathSegmentLine(Segment).Points[0].y));
      end else if Last<>TpvVectorPathSegmentLine(Segment).Points[0] then begin
       fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.MoveTo,
                                                 TpvVectorPathSegmentLine(Segment).Points[0].x,TpvVectorPathSegmentLine(Segment).Points[0].y));
      end;
      fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.LineTo,
                                                TpvVectorPathSegmentLine(Segment).Points[1].x,TpvVectorPathSegmentLine(Segment).Points[1].y));
      Last:=TpvVectorPathSegmentLine(Segment).Points[1];
     end;
     TpvVectorPathSegmentType.QuadraticCurve:begin
      if First then begin
       First:=false;
       Start:=TpvVectorPathSegmentQuadraticCurve(Segment).Points[0];
       Last:=Start;
       fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.MoveTo,
                                                 TpvVectorPathSegmentQuadraticCurve(Segment).Points[0].x,TpvVectorPathSegmentQuadraticCurve(Segment).Points[0].y));
      end else if Last<>TpvVectorPathSegmentQuadraticCurve(Segment).Points[0] then begin
       fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.MoveTo,
                                                 TpvVectorPathSegmentQuadraticCurve(Segment).Points[0].x,TpvVectorPathSegmentQuadraticCurve(Segment).Points[0].y));
      end;
      fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.QuadraticCurveTo,
                                                TpvVectorPathSegmentQuadraticCurve(Segment).Points[1].x,TpvVectorPathSegmentQuadraticCurve(Segment).Points[1].y,
                                                TpvVectorPathSegmentQuadraticCurve(Segment).Points[2].x,TpvVectorPathSegmentQuadraticCurve(Segment).Points[2].y));
      Last:=TpvVectorPathSegmentQuadraticCurve(Segment).Points[2];
     end;
     TpvVectorPathSegmentType.CubicCurve:begin
      if First then begin
       First:=false;
       Start:=TpvVectorPathSegmentCubicCurve(Segment).Points[0];
       Last:=Start;
       fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.MoveTo,
                                                 TpvVectorPathSegmentCubicCurve(Segment).Points[0].x,TpvVectorPathSegmentCubicCurve(Segment).Points[0].y));
      end else if Last<>TpvVectorPathSegmentCubicCurve(Segment).Points[0] then begin
       fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.MoveTo,
                                                 TpvVectorPathSegmentCubicCurve(Segment).Points[0].x,TpvVectorPathSegmentCubicCurve(Segment).Points[0].y));
      end;
      fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.CubicCurveTo,
                                                TpvVectorPathSegmentCubicCurve(Segment).Points[1].x,TpvVectorPathSegmentCubicCurve(Segment).Points[1].y,
                                                TpvVectorPathSegmentCubicCurve(Segment).Points[2].x,TpvVectorPathSegmentCubicCurve(Segment).Points[2].y,
                                                TpvVectorPathSegmentCubicCurve(Segment).Points[3].x,TpvVectorPathSegmentCubicCurve(Segment).Points[3].y));
      Last:=TpvVectorPathSegmentCubicCurve(Segment).Points[3];
     end;
     else begin
     end;
    end;
   end;
   if (not First) and Contour.fClosed then begin
    fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.Close));
   end;
  end;
 end;
end;

procedure TpvVectorPath.MoveTo(const aX,aY:TpvDouble);
begin
 fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.MoveTo,aX,aY));
end;

procedure TpvVectorPath.LineTo(const aX,aY:TpvDouble);
begin
 fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.LineTo,aX,aY));
end;

procedure TpvVectorPath.QuadraticCurveTo(const aCX,aCY,aAX,aAY:TpvDouble);
begin
 fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.QuadraticCurveTo,aCX,aCY,aAX,aAY));
end;

procedure TpvVectorPath.CubicCurveTo(const aC0X,aC0Y,aC1X,aC1Y,aAX,aAY:TpvDouble);
begin
 fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.CubicCurveTo,aC0X,aC0Y,aC1X,aC1Y,aAX,aAY));
end;

procedure TpvVectorPath.Close;
begin
 fCommands.Add(TpvVectorPathCommand.Create(TpvVectorPathCommandType.Close));
end;

function TpvVectorPath.GetShape:TpvVectorPathShape;
begin
 result:=TpvVectorPathShape.Create(self);
end;

{ TpvVectorPathGPUShape.TGridCell }

function TpvVectorPathGPUShape_TGridCell_YCoordinatesSortFunc(const a,b:TpvDouble):TpvInt32;
begin
 result:=Sign(a-b);
end;

constructor TpvVectorPathGPUShape.TGridCell.Create(const aVectorPathGPUShape:TpvVectorPathGPUShape;const aBoundingBox:TpvVectorPathBoundingBox);
type TYCoordinateHashMap=TpvHashMap<TpvDouble,Boolean>;
var Segment:TpvVectorPathSegment;
    IntersectionSegments:TpvVectorPathSegments;
    BoundingBox:TpvVectorPathBoundingBox;
    YCoordinateIndex,SegmentIndex,OtherSegmentIndex,PointIndex:TpvSizeInt;
    YCoordinates:TpvDynamicArray<TpvDouble>;
    YCoordinateHashMap:TYCoordinateHashMap;
    Vector:TpvVectorPathVector;
    LastY,CurrentY:TpvDouble;
    IntersectionPoints:TpvVectorPathVectorList;
    DummyGridCellLeftSplitSegmentLine:TpvVectorPathSegmentLine;
    SegmentMetaWindingSettingLine:TpvVectorPathSegmentMetaWindingSettingLine;
begin
 inherited Create;

 fVectorPathGPUShape:=aVectorPathGPUShape;

 fBoundingBox:=aBoundingBox;

 fExtendedBoundingBox.MinMax[0]:=fBoundingBox.MinMax[0]-TpvVectorPathVector.Create(TpvVectorPathGPUShape.CoordinateExtents,TpvVectorPathGPUShape.CoordinateExtents);
 fExtendedBoundingBox.MinMax[1]:=fBoundingBox.MinMax[1]+TpvVectorPathVector.Create(TpvVectorPathGPUShape.CoordinateExtents,TpvVectorPathGPUShape.CoordinateExtents);

 fSegments:=TpvVectorPathSegments.Create;
 fSegments.OwnsObjects:=false;

 IntersectionPoints:=TpvVectorPathVectorList.Create;
 try

  IntersectionSegments:=TpvVectorPathSegments.Create;
  try

   IntersectionSegments.OwnsObjects:=false;

   for Segment in fVectorPathGPUShape.fSegments do begin
    BoundingBox:=Segment.GetBoundingBox;
    if fExtendedBoundingBox.Intersect(BoundingBox) then begin
     fSegments.Add(Segment);
    end;
    if ((BoundingBox.MinMax[0].x-TpvVectorPathBoundingBox.EPSILON)<=(fExtendedBoundingBox.MinMax[0].x+TpvVectorPathBoundingBox.EPSILON)) and
       ((BoundingBox.MinMax[0].y-TpvVectorPathBoundingBox.EPSILON)<=(fExtendedBoundingBox.MinMax[1].y+TpvVectorPathBoundingBox.EPSILON)) and
       ((fExtendedBoundingBox.MinMax[0].y-TpvVectorPathBoundingBox.EPSILON)<=(BoundingBox.MinMax[1].y+TpvVectorPathBoundingBox.EPSILON)) then begin
     IntersectionSegments.Add(Segment);
    end;
   end;

   fSegments.SortHorizontal;

   IntersectionSegments.SortHorizontal;

   DummyGridCellLeftSplitSegmentLine:=TpvVectorPathSegmentLine.Create(fExtendedBoundingBox.MinMax[0],TpvVectorPathVector.Create(fExtendedBoundingBox.MinMax[0].x,fExtendedBoundingBox.MinMax[1].y));
   try

    for SegmentIndex:=0 to IntersectionSegments.Count-1 do begin
     Segment:=fSegments[SegmentIndex];
     Segment.GetIntersectionPointsWithSegment(DummyGridCellLeftSplitSegmentLine,IntersectionPoints);
     for OtherSegmentIndex:=SegmentIndex+1 to IntersectionSegments.Count-1 do begin
      Segment.GetIntersectionPointsWithSegment(IntersectionSegments[OtherSegmentIndex],IntersectionPoints);
     end;
    end;

   finally
    FreeAndNil(DummyGridCellLeftSplitSegmentLine);
   end;

   IntersectionPoints.RemoveDuplicates;

   for PointIndex:=IntersectionPoints.Count-1 downto 0 do begin
    Vector:=IntersectionPoints[PointIndex];
    if Vector.x>=fExtendedBoundingBox.MinMax[0].x then begin
     IntersectionPoints.Delete(PointIndex);
    end;
   end;

  finally
   FreeAndNil(IntersectionSegments);
  end;

  YCoordinates.Initialize;
  try

   YCoordinateHashMap:=TYCoordinateHashMap.Create(false);
   try
    for Vector in IntersectionPoints do begin
     //if (Vector.x-TpvVectorPathBoundingBox.EPSILON)<=(fExtendedBoundingBox.MinMax[1].x+TpvVectorPathBoundingBox.EPSILON) then begin
     if Vector.x<fExtendedBoundingBox.MinMax[0].x then begin
      CurrentY:=Vector.y;
      if not YCoordinateHashMap.ExistKey(CurrentY) then begin
       YCoordinateHashMap.Add(CurrentY,true);
       YCoordinates.Add(CurrentY);
      end;
     end;
    end;
   finally
    FreeAndNil(YCoordinateHashMap);
   end;

   if YCoordinates.Count>=2 then begin
    TpvTypedSort<TpvDouble>.IntroSort(@YCoordinates.Items[0],0,YCoordinates.Count-1,TpvVectorPathGPUShape_TGridCell_YCoordinatesSortFunc);
   end;

   LastY:=fExtendedBoundingBox.MinMax[0].y;
   for YCoordinateIndex:=0 to YCoordinates.Count do begin
    if YCoordinateIndex<YCoordinates.Count then begin
     CurrentY:=YCoordinates.Items[YCoordinateIndex];
     if (CurrentY<fExtendedBoundingBox.MinMax[0].y) or (CurrentY>fExtendedBoundingBox.MinMax[1].y) then begin
      continue;
     end;
    end else begin
     CurrentY:=fExtendedBoundingBox.MinMax[1].y;
    end;
    if not SameValue(CurrentY,LastY) then begin
     SegmentMetaWindingSettingLine:=TpvVectorPathSegmentMetaWindingSettingLine.Create(TpvVectorPathVector.Create(-Infinity,LastY),TpvVectorPathVector.Create(-Infinity,CurrentY));
     try
      fSegments.Add(SegmentMetaWindingSettingLine);
     finally
      fVectorPathGPUShape.fSegments.Add(SegmentMetaWindingSettingLine);
     end;
    end;
    LastY:=CurrentY;
   end;

  finally
   YCoordinates.Finalize;
  end;

 finally
  FreeAndNil(IntersectionPoints);
 end;

end;

destructor TpvVectorPathGPUShape.TGridCell.Destroy;
begin
 FreeAndNil(fSegments);
 inherited Destroy;
end;

{ TpvVectorPathGPUShape }

constructor TpvVectorPathGPUShape.Create(const aVectorPathShape:TpvVectorPathShape;const aResolution:TpvInt32;const aBoundingBoxExtent:TpvDouble);
var Contour:TpvVectorPathContour;
    Segment,NewSegment:TpvVectorPathSegment;
    IndexX,IndexY:TpvSizeInt;
    tx0,tx1,ty0,ty1:TpvDouble;
begin

 inherited Create;

 fVectorPathShape:=TpvVectorPathShape.Create(aVectorPathShape);

 fBoundingBox:=fVectorPathShape.GetBoundingBox;
 fBoundingBox.MinMax[0]:=fBoundingBox.MinMax[0]-TpvVectorPathVector.Create(aBoundingBoxExtent,aBoundingBoxExtent);
 fBoundingBox.MinMax[1]:=fBoundingBox.MinMax[1]+TpvVectorPathVector.Create(aBoundingBoxExtent,aBoundingBoxExtent);

 fResolution:=aResolution;

 fSegments:=TpvVectorPathSegments.Create;
 fSegments.OwnsObjects:=true;

 fSegmentDynamicAABBTree:=TpvVectorPathBVHDynamicAABBTree.Create;
 try
  for Contour in fVectorPathShape.fContours do begin
   for Segment in Contour.fSegments do begin
    NewSegment:=Segment.Clone;
    try
     fSegmentDynamicAABBTree.CreateProxy(NewSegment.GetBoundingBox,TpvPtrInt(TpvPointer(NewSegment)));
    finally
     fSegments.Add(NewSegment);
    end;
   end;
  end;
 finally
  fSegmentDynamicAABBTree.Rebuild;
 end;

 fGridCells:=TGridCells.Create;
 fGridCells.OwnsObjects:=true;

 for IndexY:=0 to fResolution-1 do begin
  ty0:=IndexY/fResolution;
  ty1:=(IndexY+1)/fResolution;
  for IndexX:=0 to fResolution-1 do begin
   tx0:=IndexX/fResolution;
   tx1:=(IndexX+1)/fResolution;
   fGridCells.Add(TGridCell.Create(self,
                                   TpvVectorPathBoundingBox.Create(TpvVectorPathVector.Create((fBoundingBox.MinMax[0].x*tx0)+(fBoundingBox.MinMax[1].x*(1.0-tx0)),
                                                                                              (fBoundingBox.MinMax[0].y*ty0)+(fBoundingBox.MinMax[1].y*(1.0-ty0))),
                                                                   TpvVectorPathVector.Create((fBoundingBox.MinMax[0].x*tx1)+(fBoundingBox.MinMax[1].x*(1.0-tx1)),
                                                                                              (fBoundingBox.MinMax[0].y*ty1)+(fBoundingBox.MinMax[1].y*(1.0-ty1))))));
  end;
 end;

end;

destructor TpvVectorPathGPUShape.Destroy;
begin
 FreeAndNil(fGridCells);
 FreeAndNil(fSegmentDynamicAABBTree);
 FreeAndNil(fSegments);
 FreeAndNil(fVectorPathShape);
 inherited Destroy;
end;

end.
