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
unit PasVulkan.SignedDistanceField2D;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}

interface

uses SysUtils,
     Classes,
     Math,
     PUCU,
     PasMP,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Collections,
     PasVulkan.Framework,
     PasVulkan.VectorPath;

type TpvSignedDistanceField2DVariant=
      (
       SDF=0,      // Mono SDF
       SSAASDF=1,  // Supersampling Antialiased SDF
       GSDF=2,     // Gradient SDF
       MSDF=3,     // Multi Channel SDF
       Default=1   // SSAASDF as default
      );
     PpvSignedDistanceField2DVariant=^TpvSignedDistanceField2DVariant;

     TpvSignedDistanceField2DPixel=packed record
      r,g,b,a:TpvUInt8;
     end;
     PpvSignedDistanceField2DPixel=^TpvSignedDistanceField2DPixel;

     TpvSignedDistanceField2DPixels=array of TpvSignedDistanceField2DPixel;

     TpvSignedDistanceField2D=record
      Width:TpvInt32;
      Height:TpvInt32;
      Pixels:TpvSignedDistanceField2DPixels;
     end;
     PpvSignedDistanceField2D=^TpvSignedDistanceField2D;

     TpvSignedDistanceField2DArray=array of TpvSignedDistanceField2D;

     TpvSignedDistanceField2DPathSegmentSide=
      (
       Left=-1,
       On=0,
       Right=1,
       None=2
      );
     PpvSignedDistanceField2DPathSegmentSide=^TpvSignedDistanceField2DPathSegmentSide;

     TpvSignedDistanceField2DDataItem=record
      SquaredDistance:TpvFloat;
      Distance:TpvFloat;
      DeltaWindingScore:TpvInt32;
     end;
     PpvSignedDistanceField2DDataItem=^TpvSignedDistanceField2DDataItem;

     TpvSignedDistanceField2DData=array of TpvSignedDistanceField2DDataItem;

     TpvSignedDistanceField2DDoublePrecisionAffineMatrix=array[0..5] of TpvDouble;

     PpvSignedDistanceField2DDoublePrecisionAffineMatrix=^TpvSignedDistanceField2DDoublePrecisionAffineMatrix;

     TpvSignedDistanceField2DPathSegmentType=
      (
       Line,
       QuadraticBezierCurve
      );

     PpvSignedDistanceField2DPathSegmentType=^TpvSignedDistanceField2DPathSegmentType;

     TpvSignedDistanceField2DBoundingBox=record
      Min:TpvVectorPathVector;
      Max:TpvVectorPathVector;
     end;

     PpvSignedDistanceField2DBoundingBox=^TpvSignedDistanceField2DBoundingBox;

     TpvSignedDistanceField2DPathSegmentPoints=array[0..2] of TpvVectorPathVector;

     PpvSignedDistanceField2DPathSegmentPoints=^TpvSignedDistanceField2DPathSegmentPoints;

     TpvSignedDistanceField2DPathSegment=record
      Type_:TpvSignedDistanceField2DPathSegmentType;
      Points:TpvSignedDistanceField2DPathSegmentPoints;
      P0T,P2T:TpvVectorPathVector;
      XFormMatrix:TpvSignedDistanceField2DDoublePrecisionAffineMatrix;
      ScalingFactor:TpvDouble;
      SquaredScalingFactor:TpvDouble;
      NearlyZeroScaled:TpvDouble;
      SquaredTangentToleranceScaled:TpvDouble;
      BoundingBox:TpvSignedDistanceField2DBoundingBox;
     end;

     PpvSignedDistanceField2DPathSegment=^TpvSignedDistanceField2DPathSegment;

     TpvSignedDistanceField2DPathSegments=array of TpvSignedDistanceField2DPathSegment;

     PpvSignedDistanceField2DPathContour=^TpvSignedDistanceField2DPathContour;
     TpvSignedDistanceField2DPathContour=record
      PathSegments:TpvSignedDistanceField2DPathSegments;
      CountPathSegments:TpvInt32;
     end;

     TpvSignedDistanceField2DPathContours=array of TpvSignedDistanceField2DPathContour;

     TpvSignedDistanceField2DShape=record
      Contours:TpvSignedDistanceField2DPathContours;
      CountContours:TpvInt32;
     end;

     PpvSignedDistanceField2DShape=^TpvSignedDistanceField2DShape;

     TpvSignedDistanceField2DRowDataIntersectionType=
      (
       NoIntersection,
       VerticalLine,
       TangentLine,
       TwoPointsIntersect
      );

     PpvSignedDistanceField2DRowDataIntersectionType=^TpvSignedDistanceField2DRowDataIntersectionType;

     TpvSignedDistanceField2DRowData=record
      IntersectionType:TpvSignedDistanceField2DRowDataIntersectionType;
      QuadraticXDirection:TpvInt32;
      ScanlineXDirection:TpvInt32;
      YAtIntersection:TpvFloat;
      XAtIntersection:array[0..1] of TpvFloat;
     end;

     PpvSignedDistanceField2DRowData=^TpvSignedDistanceField2DRowData;

     TpvSignedDistanceField2DPointInPolygonPathSegment=record
      Points:array[0..1] of TpvVectorPathVector;
     end;

     PpvSignedDistanceField2DPointInPolygonPathSegment=^TpvSignedDistanceField2DPointInPolygonPathSegment;

     TpvSignedDistanceField2DPointInPolygonPathSegments=array of TpvSignedDistanceField2DPointInPolygonPathSegment;

     EpvSignedDistanceField2DMSDFGenerator=class(Exception);

     { TpvSignedDistanceField2DMSDFGenerator }

     TpvSignedDistanceField2DMSDFGenerator=class
      public
       const PositiveInfinityDistance=1e240;
             NegativeInfinityDistance=-1e240;
       type { TSignedDistance }
            TSignedDistance=record
             public
              Distance:TpvDouble;
              Dot:TpvDouble;
              constructor Create(const aDistance,aDot:TpvDouble);
              class function Empty:TSignedDistance; static;
              class operator Equal(const a,b:TSignedDistance):boolean;
              class operator NotEqual(const a,b:TSignedDistance):boolean;
              class operator LessThan(const a,b:TSignedDistance):boolean;
              class operator LessThanOrEqual(const a,b:TSignedDistance):boolean;
              class operator GreaterThan(const a,b:TSignedDistance):boolean;
              class operator GreaterThanOrEqual(const a,b:TSignedDistance):boolean;
            end;
            { TMultiSignedDistance }
            TMultiSignedDistance=record
             public
              r:TpvDouble;
              g:TpvDouble;
              b:TpvDouble;
              Median:TpvDouble;
            end;
            { TBounds }
            TBounds=record
             public
              l:TpvDouble;
              b:TpvDouble;
              r:TpvDouble;
              t:TpvDouble;
              procedure PointBounds(const p:TpvVectorPathVector);
            end;
            TEdgeColor=
             (
              BLACK=0,
              RED=1,
              GREEN=2,
              YELLOW=3,
              BLUE=4,
              MAGENTA=5,
              CYAN=6,
              WHITE=7
             );
            TEdgeType=
             (
              LINEAR=0,
              QUADRATIC=1,
              CUBIC=2
             );
       const TOO_LARGE_RATIO=1e12;
             MSDFGEN_CUBIC_SEARCH_STARTS=8;
             MSDFGEN_CUBIC_SEARCH_STEPS=8;
       type { TEdgeSegment }
            TEdgeSegment=record
             public
              Points:array[0..3] of TpvVectorPathVector;
              Color:TpvSignedDistanceField2DMSDFGenerator.TEdgeColor;
              Type_:TpvSignedDistanceField2DMSDFGenerator.TEdgeType;
              constructor Create(const aP0,aP1:TpvVectorPathVector;const aColor:TpvSignedDistanceField2DMSDFGenerator.TEdgeColor=TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.WHITE); overload;
              constructor Create(const aP0,aP1,aP2:TpvVectorPathVector;const aColor:TpvSignedDistanceField2DMSDFGenerator.TEdgeColor=TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.WHITE); overload;
              constructor Create(const aP0,aP1,aP2,aP3:TpvVectorPathVector;const aColor:TpvSignedDistanceField2DMSDFGenerator.TEdgeColor=TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.WHITE); overload;
              function Point(const aParam:TpvDouble):TpvVectorPathVector;
              function Direction(const aParam:TpvDouble):TpvVectorPathVector;
              function MinSignedDistance(const aOrigin:TpvVectorPathVector;var aParam:TpvDouble):TpvSignedDistanceField2DMSDFGenerator.TSignedDistance;
              procedure DistanceToPseudoDistance(var aDistance:TpvSignedDistanceField2DMSDFGenerator.TSignedDistance;const aOrigin:TpvVectorPathVector;const aParam:TpvDouble);
              procedure Bounds(var aBounds:TpvSignedDistanceField2DMSDFGenerator.TBounds);
              procedure SplitInThirds(out aPart1,aPart2,aPart3:TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment);
            end;
            PEdgeSegment=^TEdgeSegment;
            TEdgeSegments=array of TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment;
            { TContour }
            TContour=record
             public
              Edges:TpvSignedDistanceField2DMSDFGenerator.TEdgeSegments;
              Count:TpvSizeInt;
              CachedWinding:TpvSizeInt;
              MultiSignedDistance:TMultiSignedDistance;
              class function Create:TContour; static;
              function AddEdge({$ifdef fpc}constref{$else}const{$endif} aEdge:TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment):TpvSignedDistanceField2DMSDFGenerator.PEdgeSegment;
              procedure Bounds(var aBounds:TpvSignedDistanceField2DMSDFGenerator.TBounds);
              procedure BoundMiters(var aBounds:TpvSignedDistanceField2DMSDFGenerator.TBounds;const aBorder,aMiterLimit:TpvDouble;const aPolarity:TpvSizeInt);
              function Winding:TpvSizeInt;
            end;
            PContour=^TContour;
            TContours=array of TpvSignedDistanceField2DMSDFGenerator.TContour;
            { TShape }
            TShape=record
             Contours:TContours;
             Count:TpvSizeInt;
             InverseYAxis:boolean;
             class function Create:TShape; static;
             function AddContour:TpvSignedDistanceField2DMSDFGenerator.PContour;
             function Validate:boolean;
             procedure Normalize;
             procedure Bounds(var aBounds:TpvSignedDistanceField2DMSDFGenerator.TBounds);
             procedure BoundMiters(var aBounds:TpvSignedDistanceField2DMSDFGenerator.TBounds;const aBorder,aMiterLimit:TpvDouble;const aPolarity:TpvSizeInt);
             function GetBounds(const aBorder:TpvDouble=0.0;const aMiterLimit:TpvDouble=0;const aPolarity:TpvSizeInt=0):TpvSignedDistanceField2DMSDFGenerator.TBounds;
            end;
            PShape=^TShape;
            TShapes=array of TpvSignedDistanceField2DMSDFGenerator.TShape;
            TPixel=record
             r:TpvDouble;
             g:TpvDouble;
             b:TpvDouble;
             a:TpvDouble;
            end;
            PPixel=^TPixel;
            TPixels=array of TPixel;
            TPixelArray=array[0..65535] of TPixel;
            PPixelArray=^TPixelArray;
            TImage=record
             Width:TpvSizeInt;
             Height:TpvSizeInt;
             Pixels:TPixels;
            end;
            PImage=^TImage;
      public
       class function Median(a,b,c:TpvDouble):TpvDouble; static;
       class function Sign(n:TpvDouble):TpvInt32; static;
       class function NonZeroSign(n:TpvDouble):TpvInt32; static;
       class function SolveQuadratic(out x0,x1:TpvDouble;const a,b,c:TpvDouble):TpvSizeInt; static;
       class function SolveCubicNormed(out x0,x1,x2:TpvDouble;a,b,c:TpvDouble):TpvSizeInt; static;
       class function SolveCubic(out x0,x1,x2:TpvDouble;const a,b,c,d:TpvDouble):TpvSizeInt; static;
       class function Shoelace(const a,b:TpvVectorPathVector):TpvDouble; static;
       class procedure AutoFrame({$ifdef fpc}constref{$else}const{$endif} aShape:TpvSignedDistanceField2DMSDFGenerator.TShape;const aWidth,aHeight:TpvSizeInt;const aPixelRange:TpvDouble;out aTranslate,aScale:TpvVectorPathVector); static;
       class function IsCorner(const aDirection,bDirection:TpvVectorPathVector;const aCrossThreshold:TpvDouble):boolean; static;
       class procedure SwitchColor(var aColor:TpvSignedDistanceField2DMSDFGenerator.TEdgeColor;var aSeed:TpvUInt64;const aBanned:TpvSignedDistanceField2DMSDFGenerator.TEdgeColor=TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.BLACK); static;
       class procedure EdgeColoringSimple(var aShape:TpvSignedDistanceField2DMSDFGenerator.TShape;const aAngleThreshold:TpvDouble;aSeed:TpvUInt64); static;
       class procedure GenerateDistanceFieldPixel(var aImage:TpvSignedDistanceField2DMSDFGenerator.TImage;{$ifdef fpc}constref{$else}const{$endif} aShape:TpvSignedDistanceField2DMSDFGenerator.TShape;const aRange:TpvDouble;const aScale,aTranslate:TpvVectorPathVector;const aX,aY:TpvSizeInt); static;
       class procedure GenerateDistanceField(var aImage:TpvSignedDistanceField2DMSDFGenerator.TImage;{$ifdef fpc}constref{$else}const{$endif} aShape:TpvSignedDistanceField2DMSDFGenerator.TShape;const aRange:TpvDouble;const aScale,aTranslate:TpvVectorPathVector;const aPasMPInstance:TPasMP=nil); static;
       class function DetectClash({$ifdef fpc}constref{$else}const{$endif} a,b:TpvSignedDistanceField2DMSDFGenerator.TPixel;const aThreshold:TpvDouble):boolean; static;
       class procedure ErrorCorrection(var aImage:TpvSignedDistanceField2DMSDFGenerator.TImage;{$ifdef fpc}constref{$else}const{$endif} aShape:TpvSignedDistanceField2DMSDFGenerator.TShape;const aRange:TpvDouble;const aScale,aTranslate:TpvVectorPathVector); static;
     end;

     { TpvSignedDistanceField2DGenerator }

     TpvSignedDistanceField2DGenerator=class
      private
       const DistanceField2DMagnitudeValue=VulkanDistanceField2DSpreadValue;
             DistanceField2DPadValue=VulkanDistanceField2DSpreadValue;
             DistanceField2DScalar1Value=1.0;
             DistanceField2DCloseValue=DistanceField2DScalar1Value/16.0;
             DistanceField2DCloseSquaredValue=DistanceField2DCloseValue*DistanceField2DCloseValue;
             DistanceField2DNearlyZeroValue=DistanceField2DScalar1Value/int64(1 shl 18);
             DistanceField2DTangentToleranceValue=DistanceField2DScalar1Value/int64(1 shl 11);
             DistanceField2DRasterizerToScreenScale=1.0;
             CurveTessellationTolerance=0.125;
             CurveTessellationToleranceSquared=CurveTessellationTolerance*CurveTessellationTolerance;
             CurveRecursionLimit=16;
       type TMSDFMatches=array of TpvInt8;
      private
       fPointInPolygonPathSegments:TpvSignedDistanceField2DPointInPolygonPathSegments;
       fVectorPathShape:TpvVectorPathShape;
       fScale:TpvDouble;
       fOffsetX:TpvDouble;
       fOffsetY:TpvDouble;
       fDistanceField:PpvSignedDistanceField2D;
       fVariant:TpvSignedDistanceField2DVariant;
       fShape:TpvSignedDistanceField2DShape;
       fDistanceFieldData:TpvSignedDistanceField2DData;
       fColorChannelIndex:TpvSizeInt;
       fMSDFShape:TpvSignedDistanceField2DMSDFGenerator.PShape;
       fMSDFImage:TpvSignedDistanceField2DMSDFGenerator.PImage;
       fMSDFAmbiguous:boolean;
       fMSDFMatches:TMSDFMatches;
      protected
       function Clamp(const Value,MinValue,MaxValue:TpvInt64):TpvInt64; overload;
       function Clamp(const Value,MinValue,MaxValue:TpvDouble):TpvDouble; overload;
       function VectorMap(const p:TpvVectorPathVector;const m:TpvSignedDistanceField2DDoublePrecisionAffineMatrix):TpvVectorPathVector;
       procedure GetOffset(out oX,oY:TpvDouble);
       procedure ApplyOffset(var aX,aY:TpvDouble); overload;
       function ApplyOffset(const aPoint:TpvVectorPathVector):TpvVectorPathVector; overload;
       function BetweenClosedOpen(const a,b,c:TpvDouble;const Tolerance:TpvDouble=0.0;const XFormToleranceToX:boolean=false):boolean;
       function BetweenClosed(const a,b,c:TpvDouble;const Tolerance:TpvDouble=0.0;const XFormToleranceToX:boolean=false):boolean;
       function NearlyZero(const Value:TpvDouble;const Tolerance:TpvDouble=DistanceField2DNearlyZeroValue):boolean;
       function NearlyEqual(const x,y:TpvDouble;const Tolerance:TpvDouble=DistanceField2DNearlyZeroValue;const XFormToleranceToX:boolean=false):boolean;
       function SignOf(const Value:TpvDouble):TpvInt32;
       function IsColinear(const Points:array of TpvVectorPathVector):boolean;
       function PathSegmentDirection(const PathSegment:TpvSignedDistanceField2DPathSegment;const Which:TpvInt32):TpvVectorPathVector;
       function PathSegmentCountPoints(const PathSegment:TpvSignedDistanceField2DPathSegment):TpvInt32;
       function PathSegmentEndPoint(const PathSegment:TpvSignedDistanceField2DPathSegment):PpvVectorPathVector;
       function PathSegmentCornerPoint(const PathSegment:TpvSignedDistanceField2DPathSegment;const WhichA,WhichB:TpvInt32):PpvVectorPathVector;
       procedure InitializePathSegment(var PathSegment:TpvSignedDistanceField2DPathSegment);
       procedure InitializeDistances;
       function AddLineToPathSegmentArray(var Contour:TpvSignedDistanceField2DPathContour;const Points:array of TpvVectorPathVector):TpvInt32;
       function AddQuadraticBezierCurveToPathSegmentArray(var Contour:TpvSignedDistanceField2DPathContour;const Points:array of TpvVectorPathVector):TpvInt32;
       function CubeRoot(Value:TpvDouble):TpvDouble;
       function CalculateNearestPointForQuadraticBezierCurve(const PathSegment:TpvSignedDistanceField2DPathSegment;const XFormPoint:TpvVectorPathVector):TpvDouble;
       procedure PrecomputationForRow(out RowData:TpvSignedDistanceField2DRowData;const PathSegment:TpvSignedDistanceField2DPathSegment;const PointLeft,PointRight:TpvVectorPathVector);
       function CalculateSideOfQuadraticBezierCurve(const PathSegment:TpvSignedDistanceField2DPathSegment;const Point,XFormPoint:TpvVectorPathVector;const RowData:TpvSignedDistanceField2DRowData):TpvSignedDistanceField2DPathSegmentSide;
       function DistanceToPathSegment(const Point:TpvVectorPathVector;const PathSegment:TpvSignedDistanceField2DPathSegment;const RowData:TpvSignedDistanceField2DRowData;out PathSegmentSide:TpvSignedDistanceField2DPathSegmentSide):TpvDouble;
       procedure ConvertShape(const DoSubdivideCurvesIntoLines:boolean);
       function ConvertShapeToMSDFShape:TpvSignedDistanceField2DMSDFGenerator.TShape;
       procedure CalculateDistanceFieldDataLineRange(const FromY,ToY:TpvInt32);
       procedure CalculateDistanceFieldDataLineRangeParallelForJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32;const Data:TpvPointer;const FromIndex,ToIndex:TPasMPNativeInt);
       function PackDistanceFieldValue(Distance:TpvDouble):TpvUInt8;
       function PackPseudoDistanceFieldValue(Distance:TpvDouble):TpvUInt8;
       procedure ConvertToPointInPolygonPathSegments;
       function GetWindingNumberAtPointInPolygon(const Point:TpvVectorPathVector):TpvInt32;
       function GenerateDistanceFieldPicture(const DistanceFieldData:TpvSignedDistanceField2DData;const Width,Height,TryIteration:TpvInt32):boolean;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Execute(var aDistanceField:TpvSignedDistanceField2D;const aVectorPathShape:TpvVectorPathShape;const aScale:TpvDouble=1.0;const aOffsetX:TpvDouble=0.0;const aOffsetY:TpvDouble=0.0;const aVariant:TpvSignedDistanceField2DVariant=TpvSignedDistanceField2DVariant.Default;const aProtectBorder:boolean=false);
       class procedure Generate(var aDistanceField:TpvSignedDistanceField2D;const aVectorPathShape:TpvVectorPathShape;const aScale:TpvDouble=1.0;const aOffsetX:TpvDouble=0.0;const aOffsetY:TpvDouble=0.0;const aVariant:TpvSignedDistanceField2DVariant=TpvSignedDistanceField2DVariant.Default;const aProtectBorder:boolean=false); static;
     end;

implementation

{ TpvSignedDistanceField2DMSDFGenerator.TSignedDistance }

constructor TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Create(const aDistance,aDot:TpvDouble);
begin
 Distance:=aDistance;
 Dot:=aDot;
end;

class function TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Empty:TpvSignedDistanceField2DMSDFGenerator.TSignedDistance;
begin
 result.Distance:=TpvSignedDistanceField2DMSDFGenerator.NegativeInfinityDistance;
 result.Dot:=0.0;
end;

class operator TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Equal(const a,b:TpvSignedDistanceField2DMSDFGenerator.TSignedDistance):boolean;
begin
 result:=SameValue(a.Distance,b.Distance) and SameValue(a.Dot,b.Dot);
end;

class operator TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.NotEqual(const a,b:TpvSignedDistanceField2DMSDFGenerator.TSignedDistance):boolean;
begin
 result:=(not SameValue(a.Distance,b.Distance)) or (not SameValue(a.Dot,b.Dot));
end;

class operator TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.LessThan(const a,b:TpvSignedDistanceField2DMSDFGenerator.TSignedDistance):boolean;
begin
 result:=(abs(a.Distance)<abs(b.Distance)) or (SameValue(abs(a.Distance),abs(b.Distance)) and (a.Dot<b.Dot));
end;

class operator TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.LessThanOrEqual(const a,b:TpvSignedDistanceField2DMSDFGenerator.TSignedDistance):boolean;
begin
 result:=(abs(a.Distance)<abs(b.Distance)) or (SameValue(abs(a.Distance),abs(b.Distance)) and ((a.Dot<=b.Dot) or SameValue(a.Dot,b.Dot)));
end;

class operator TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.GreaterThan(const a,b:TpvSignedDistanceField2DMSDFGenerator.TSignedDistance):boolean;
begin
 result:=(abs(a.Distance)>abs(b.Distance)) or (SameValue(abs(a.Distance),abs(b.Distance)) and (a.Dot>b.Dot));
end;

class operator TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.GreaterThanOrEqual(const a,b:TpvSignedDistanceField2DMSDFGenerator.TSignedDistance):boolean;
begin
 result:=(abs(a.Distance)>abs(b.Distance)) or (SameValue(abs(a.Distance),abs(b.Distance)) and ((a.Dot>=b.Dot) or SameValue(a.Dot,b.Dot)));
end;

{ TpvSignedDistanceField2DMSDFGenerator.TBounds }

procedure TpvSignedDistanceField2DMSDFGenerator.TBounds.PointBounds(const p:TpvVectorPathVector);
begin
 if p.x<l then begin
  l:=p.x;
 end;
 if p.y<b then begin
  b:=p.y;
 end;
 if p.x>r then begin
  r:=p.x;
 end;
 if p.y>t then begin
  t:=p.y;
 end;
end;

{ TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment }

constructor TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(const aP0,aP1:TpvVectorPathVector;const aColor:TpvSignedDistanceField2DMSDFGenerator.TEdgeColor);
begin
 Points[0]:=aP0;
 Points[1]:=aP1;
 Color:=aColor;
 Type_:=TpvSignedDistanceField2DMSDFGenerator.TEdgeType.LINEAR;
end;

constructor TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(const aP0,aP1,aP2:TpvVectorPathVector;const aColor:TpvSignedDistanceField2DMSDFGenerator.TEdgeColor);
begin
 Points[0]:=aP0;
 if IsZero((aP1-aP0).Cross(aP2-aP1)) then begin
  Points[1]:=aP2;
  Color:=aColor;
  Type_:=TpvSignedDistanceField2DMSDFGenerator.TEdgeType.LINEAR;
 end else begin
  Points[1]:=aP1;
  Points[2]:=aP2;
  Color:=aColor;
  Type_:=TpvSignedDistanceField2DMSDFGenerator.TEdgeType.QUADRATIC;
 end;
end;

constructor TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(const aP0,aP1,aP2,aP3:TpvVectorPathVector;const aColor:TpvSignedDistanceField2DMSDFGenerator.TEdgeColor);
var p12:TpvVectorPathVector;
begin
 Points[0]:=aP0;
 p12:=aP2-aP1;
 if IsZero((aP1-aP0).Cross(p12)) and IsZero(p12.Cross(aP3-aP2)) then begin
  Points[1]:=aP3;
  Color:=aColor;
  Type_:=TpvSignedDistanceField2DMSDFGenerator.TEdgeType.LINEAR;
 end else begin
  p12:=(aP1*1.5)-(aP0*0.5);
  if p12=((aP2*1.5)-(aP3*0.5)) then begin
   Points[1]:=p12;
   Points[2]:=aP3;
   Color:=aColor;
   Type_:=TpvSignedDistanceField2DMSDFGenerator.TEdgeType.QUADRATIC;
  end else begin
   Points[1]:=aP1;
   Points[2]:=aP2;
   Points[3]:=aP3;
   Color:=aColor;
   Type_:=TpvSignedDistanceField2DMSDFGenerator.TEdgeType.CUBIC;
  end;
 end;
end;

function TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Point(const aParam:TpvDouble):TpvVectorPathVector;
var p12:TpvVectorPathVector;
begin
 case Type_ of
  TpvSignedDistanceField2DMSDFGenerator.TEdgeType.LINEAR:begin
   result:=Points[0].Lerp(Points[1],aParam);
  end;
  TpvSignedDistanceField2DMSDFGenerator.TEdgeType.QUADRATIC:begin
   result:=(Points[0].Lerp(Points[1],aParam)).Lerp(Points[1].Lerp(Points[2],aParam),aParam);
  end;
  else {TpvSignedDistanceField2DMSDFGenerator.TEdgeType.CUBIC:}begin
   p12:=Points[1].Lerp(Points[2],aParam);
   result:=((Points[0].Lerp(Points[1],aParam)).Lerp(p12,aParam)).Lerp(p12.Lerp(Points[2].Lerp(Points[3],aParam),aParam),aParam);
  end;
 end;
end;

function TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Direction(const aParam:TpvDouble):TpvVectorPathVector;
begin
 case Type_ of
  TpvSignedDistanceField2DMSDFGenerator.TEdgeType.LINEAR:begin
   result:=Points[1]-Points[0];
  end;
  TpvSignedDistanceField2DMSDFGenerator.TEdgeType.QUADRATIC:begin
   result:=(Points[1]-Points[0]).Lerp(Points[2]-Points[1],aParam);
   if IsZero(result.x) and IsZero(result.y) then begin
    result:=Points[2]-Points[0];
   end;
  end;
  else {TpvSignedDistanceField2DMSDFGenerator.TEdgeType.CUBIC:}begin
   result:=((Points[1]-Points[0]).Lerp(Points[2]-Points[1],aParam)).Lerp((Points[2]-Points[1]).Lerp(Points[3]-Points[2],aParam),aParam);
   if IsZero(result.x) and IsZero(result.y) then begin
    if SameValue(aParam,0) then begin
     result:=Points[2]-Points[0];
    end else if SameValue(aParam,1) then begin
     result:=Points[3]-Points[1];
    end;
   end;
  end;
 end;
end;

function TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.MinSignedDistance(const aOrigin:TpvVectorPathVector;var aParam:TpvDouble):TpvSignedDistanceField2DMSDFGenerator.TSignedDistance;
var aq,ab,eq,qa,br,epDir,qe,sa,d1,d2:TpvVectorPathVector;
    EndPointDistance,OrthoDistance,a,b,c,d,MinDistance,Distance,Time,ImprovedTime:TpvDouble;
    t:array[0..3] of TpvDouble;
    Solutions,Index,Step:TpvSizeInt;
begin
 case Type_ of
  TpvSignedDistanceField2DMSDFGenerator.TEdgeType.LINEAR:begin
   aq:=aOrigin-Points[0];
   ab:=Points[1]-Points[0];
   aParam:=aq.Dot(ab)/ab.Dot(ab);
   eq:=Points[ord(aParam>0.5) and 1]-aOrigin;
   EndPointDistance:=eq.Length;
   if (aParam>0.0) and (aParam<1.0) then begin
    OrthoDistance:=ab.OrthoNormal.Dot(aq);
    if abs(OrthoDistance)<EndPointDistance then begin
     result:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Create(OrthoDistance,0.0);
     exit;
    end;
   end;
   result:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Create(TpvSignedDistanceField2DMSDFGenerator.NonZeroSign(aq.Cross(ab))*EndPointDistance,abs(ab.Normalize.Dot(eq.Normalize)));
  end;
  TpvSignedDistanceField2DMSDFGenerator.TEdgeType.QUADRATIC:begin
   qa:=Points[0]-aOrigin;
   ab:=Points[1]-Points[0];
   br:=(Points[2]-Points[1])-ab;
   a:=br.Dot(br);
   b:=3.0*ab.Dot(br);
   c:=(2.0*ab.Dot(ab))+qa.Dot(br);
   d:=qa.Dot(ab);
   Solutions:=SolveCubic(t[0],t[1],t[2],a,b,c,d);
   epDir:=Direction(0);
   MinDistance:=TpvSignedDistanceField2DMSDFGenerator.NonZeroSign(epDir.Cross(qa))*qa.Length;
   aParam:=-(qa.Dot(epDir)/epDir.Dot(epDir));
   epDir:=Direction(1);
   Distance:=TpvSignedDistanceField2DMSDFGenerator.NonZeroSign(epDir.Cross(Points[2]-aOrigin))*((Points[2]-aOrigin).Length);
   if abs(Distance)<abs(MinDistance) then begin
    MinDistance:=Distance;
    aParam:=(aOrigin-Points[1]).Dot(epDir)/epDir.Dot(epDir);
   end;
   for Index:=0 to Solutions-1 do begin
    if (t[Index]>0.0) and (t[Index]<1.0) then begin
     qe:=(qa+(ab*(2.0*t[Index])))+(br*sqr(t[Index]));
     Distance:=TpvSignedDistanceField2DMSDFGenerator.NonZeroSign((ab+(br*t[Index])).Cross(qe))*qe.Length;
     if abs(Distance)<=abs(MinDistance) then begin
      MinDistance:=Distance;
      aParam:=t[Index];
     end;
    end;
   end;
   if (aParam>=0.0) and (aParam<=1.0) then begin
    result:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Create(MinDistance,0.0);
   end else if aParam<0.5 then begin
    result:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Create(MinDistance,abs(Direction(0).Normalize.Dot(qa.Normalize)));
   end else begin
    result:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Create(MinDistance,abs(Direction(1).Normalize.Dot((Points[2]-aOrigin).Normalize)));
   end;
  end;
  else {TpvSignedDistanceField2DMSDFGenerator.TEdgeType.CUBIC:}begin
   qa:=Points[0]-aOrigin;
   ab:=Points[1]-Points[0];
   br:=(Points[2]-Points[1])-ab;
   sa:=((Points[3]-Points[2])-(Points[2]-Points[1]))-br;
   epDir:=Direction(0);
   MinDistance:=TpvSignedDistanceField2DMSDFGenerator.NonZeroSign(epDir.Cross(qa))*qa.Length;
   aParam:=-qa.Dot(epDir)/epDir.Dot(epDir);
   begin
    epDir:=Direction(1);
    Distance:=TpvSignedDistanceField2DMSDFGenerator.NonZeroSign(epDir.Cross(Points[3]-aOrigin))*(Points[3]-aOrigin).Length;
    if abs(Distance)<abs(MinDistance) then begin
     MinDistance:=Distance;
     aParam:=(epDir-(Points[3]-aOrigin)).Dot(epDir)/epDir.Dot(epDir);
    end;
   end;
   for Index:=0 to TpvSignedDistanceField2DMSDFGenerator.MSDFGEN_CUBIC_SEARCH_STARTS do begin
    Time:=Index/TpvSignedDistanceField2DMSDFGenerator.MSDFGEN_CUBIC_SEARCH_STARTS;
    qe:=(((Points[0]+(ab*(3.0*Time)))+(br*(3.0*sqr(Time))))+(sa*(sqr(Time)*Time)))-aOrigin;
    d1:=((ab*3.0)+(br*(6.0*Time)))+(sa*(sqr(Time)*3.0));
    d2:=(br*6.0)+(sa*(6.0*Time));
    ImprovedTime:=Time-(qe.Dot(d1)/(d1.Dot(d1)+qe.Dot(d2)));
    if (ImprovedTime>0.0) and (ImprovedTime<1.0) then begin
     Step:=TpvSignedDistanceField2DMSDFGenerator.MSDFGEN_CUBIC_SEARCH_STEPS;
     repeat
      Time:=ImprovedTime;
      qe:=(((Points[0]+(ab*(3.0*Time)))+(br*(3.0*sqr(Time))))+(sa*(sqr(Time)*Time)))-aOrigin;
      d1:=((ab*3.0)+(br*(6.0*Time)))+(sa*(sqr(Time)*3.0));
      dec(Step);
      if Step=0 then begin
       break;
      end;
      d2:=(br*6.0)+(sa*(6.0*Time));
      ImprovedTime:=Time-(qe.Dot(d1)/(d1.Dot(d1)+qe.Dot(d2)));
     until not ((ImprovedTime>0.0) and (ImprovedTime<1.0));
     Distance:=qe.Length;
     if Distance<abs(MinDistance) then begin
      MinDistance:=TpvSignedDistanceField2DMSDFGenerator.NonZeroSign(d1.Cross(qe))*Distance;
      aParam:=Time;
     end;
    end;
   end;
   if (aParam>=0.0) and (aParam<=1.0) then begin
    result:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Create(MinDistance,0.0);
   end else if aParam<0.5 then begin
    result:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Create(MinDistance,abs(Direction(0).Normalize.Dot(qa.Normalize)));
   end else begin
    result:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Create(MinDistance,abs(Direction(1).Normalize.Dot((Points[3]-aOrigin).Normalize)));
   end;
  end;
 end;
end;

procedure TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.DistanceToPseudoDistance(var aDistance:TpvSignedDistanceField2DMSDFGenerator.TSignedDistance;const aOrigin:TpvVectorPathVector;const aParam:TpvDouble);
var dir,aq,bq:TpvVectorPathVector;
    ts,PseudoDistance:TpvDouble;
begin
 if aParam<0.0 then begin
  dir:=Direction(0).Normalize;
  aq:=aOrigin-Point(0);
  ts:=aq.Dot(dir);
  if ts<0.0 then begin
   PseudoDistance:=aq.Cross(dir);
   if abs(PseudoDistance)<=abs(aDistance.Distance) then begin
    aDistance.Distance:=PseudoDistance;
    aDistance.Dot:=0.0;
   end;
  end;
 end else if aParam>1.0 then begin
  dir:=Direction(1).Normalize;
  bq:=aOrigin-Point(1);
  ts:=bq.Dot(dir);
  if ts>0.0 then begin
   PseudoDistance:=bq.Cross(dir);
   if abs(PseudoDistance)<=abs(aDistance.Distance) then begin
    aDistance.Distance:=PseudoDistance;
    aDistance.Dot:=0.0;
   end;
  end;
 end;
end;

procedure TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Bounds(var aBounds:TpvSignedDistanceField2DMSDFGenerator.TBounds);
var b,a0,a1,a2:TpvVectorPathVector;
    Param:TpvDouble;
    Params:array[0..1] of TpvDouble;
    Solutions:TpvSizeInt;
begin
 case Type_ of
  TpvSignedDistanceField2DMSDFGenerator.TEdgeType.LINEAR:begin
   aBounds.PointBounds(Points[0]);
   aBounds.PointBounds(Points[1]);
  end;
  TpvSignedDistanceField2DMSDFGenerator.TEdgeType.QUADRATIC:begin
   aBounds.PointBounds(Points[0]);
   aBounds.PointBounds(Points[2]);
   b:=(Points[1]-Points[0])-(Points[2]-Points[1]);
   if not IsZero(b.x) then begin
    Param:=(Points[1].x-Points[0].x)/b.x;
    if (Param>0.0) and (Param<1.0) then begin
     aBounds.PointBounds(Point(Param));
    end;
   end;
   if not IsZero(b.y) then begin
    Param:=(Points[1].y-Points[0].y)/b.y;
    if (Param>0.0) and (Param<1.0) then begin
     aBounds.PointBounds(Point(Param));
    end;
   end;
  end;
  else {TpvSignedDistanceField2DMSDFGenerator.TEdgeType.CUBIC:}begin
   aBounds.PointBounds(Points[0]);
   aBounds.PointBounds(Points[3]);
   a0:=Points[1]-Points[0];
   a1:=((Points[2]-Points[1])-a0)*2.0;
   a2:=((Points[3]-(Points[2]*3.0))+(Points[1]*3.0))-Points[0];
   Solutions:=SolveQuadratic(Params[0],Params[1],a2.x,a1.x,a0.x);
   if (Solutions>0) and ((Params[0]>0.0) and (Params[0]<1.0)) then begin
    aBounds.PointBounds(Point(Params[0]));
   end;
   if (Solutions>1) and ((Params[1]>0.0) and (Params[1]<1.0)) then begin
    aBounds.PointBounds(Point(Params[1]));
   end;
   Solutions:=SolveQuadratic(Params[0],Params[1],a2.y,a1.y,a0.y);
   if (Solutions>0) and ((Params[0]>0.0) and (Params[0]<1.0)) then begin
    aBounds.PointBounds(Point(Params[0]));
   end;
   if (Solutions>1) and ((Params[1]>0.0) and (Params[1]<1.0)) then begin
    aBounds.PointBounds(Point(Params[1]));
   end;
  end;
 end;
end;

procedure TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.SplitInThirds(out aPart1,aPart2,aPart3:TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment);
begin
 case Type_ of
  TpvSignedDistanceField2DMSDFGenerator.TEdgeType.LINEAR:begin
   aPart1:=TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(Points[0],Point(1.0/3.0),Color);
   aPart2:=TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(Point(1.0/3.0),Point(2.0/3.0),Color);
   aPart3:=TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(Point(2.0/3.0),Points[1],Color);
  end;
  TpvSignedDistanceField2DMSDFGenerator.TEdgeType.QUADRATIC:begin
   aPart1:=TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(Points[0],Points[0].Lerp(Points[1],1.0/3.0),Point(1.0/3.0),Color);
   aPart2:=TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(Point(1.0/3.0),(Points[0].Lerp(Points[1],5.0/9.0)).Lerp(Points[1].Lerp(Points[2],4.0/9.0),0.5),Point(2.0/3.0),Color);
   aPart3:=TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(Point(2.0/3.0),Points[1].Lerp(Points[2],2.0/3.0),Points[2],Color);
  end;
  else {TpvSignedDistanceField2DMSDFGenerator.TEdgeType.CUBIC:}begin
   if Points[0]=Points[1] then begin
    aPart1:=TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(Points[0],(Points[0].Lerp(Points[1],1.0/3.0)).Lerp(Points[1].Lerp(Points[2],1.0/3.0),1.0/3.0),Point(1.0/3.0),Color);
   end else begin
    aPart1:=TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(Points[0].Lerp(Points[1],1.0/3.0),(Points[0].Lerp(Points[1],1.0/3.0)).Lerp(Points[1].Lerp(Points[2],1.0/3.0),1.0/3.0),Point(1.0/3.0),Color);
   end;
   aPart2:=TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(Point(1.0/3.0),
                                                                     ((Points[0].Lerp(Points[1],1.0/3.0)).Lerp(Points[1].Lerp(Points[2],1.0/3.0),1.0/3.0)).Lerp(((Points[1].Lerp(Points[2],1.0/3.0)).Lerp(Points[2].Lerp(Points[3],1.0/3.0),1.0/3.0)),2.0/3.0),
                                                                     ((Points[0].Lerp(Points[1],2.0/3.0)).Lerp(Points[1].Lerp(Points[2],2.0/3.0),2.0/3.0)).Lerp(((Points[1].Lerp(Points[2],2.0/3.0)).Lerp(Points[2].Lerp(Points[3],2.0/3.0),2.0/3.0)),1.0/3.0),
                                                                     Point(2.0/3.0),
                                                                     Color);
   if Points[2]=Points[3] then begin
    aPart3:=TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(Point(2.0/3.0),
                                                                      (Points[1].Lerp(Points[2],2.0/3.0)).Lerp(Points[2].Lerp(Points[3],2.0/3.0),2.0/3.0),
                                                                      Points[3],
                                                                      Points[3],
                                                                      Color);
   end else begin
    aPart3:=TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(Point(2.0/3.0),
                                                                      (Points[1].Lerp(Points[2],2.0/3.0)).Lerp(Points[2].Lerp(Points[3],2.0/3.0),2.0/3.0),
                                                                      Points[2].Lerp(Points[3],2.0/3.0),
                                                                      Points[3],
                                                                      Color);
   end;
  end;
 end;
end;

{ TpvSignedDistanceField2DMSDFGenerator.TContour }

class function TpvSignedDistanceField2DMSDFGenerator.TContour.Create:TpvSignedDistanceField2DMSDFGenerator.TContour;
begin
 result.Edges:=nil;
 result.Count:=0;
 result.CachedWinding:=Low(TpvSizeInt);
end;

function TpvSignedDistanceField2DMSDFGenerator.TContour.AddEdge({$ifdef fpc}constref{$else}const{$endif} aEdge:TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment):TpvSignedDistanceField2DMSDFGenerator.PEdgeSegment;
begin
 if Count>=length(Edges) then begin
  SetLength(Edges,(Count+1)+((Count+1) shr 1)); // Grow factor 1.5
 end;
 Edges[Count]:=aEdge;
 result:=@Edges[Count];
 inc(Count);
end;

procedure TpvSignedDistanceField2DMSDFGenerator.TContour.Bounds(var aBounds:TpvSignedDistanceField2DMSDFGenerator.TBounds);
var Index:TpvSizeInt;
begin
 for Index:=0 to Count-1 do begin
  Edges[Index].Bounds(aBounds);
 end;
end;

procedure TpvSignedDistanceField2DMSDFGenerator.TContour.BoundMiters(var aBounds:TpvSignedDistanceField2DMSDFGenerator.TBounds;const aBorder,aMiterLimit:TpvDouble;const aPolarity:TpvSizeInt);
var Index:TpvSizeInt;
    PreviousDirection,Direction,Miter:TpvVectorPathVector;
    Edge:TpvSignedDistanceField2DMSDFGenerator.PEdgeSegment;
    MiterLength,q:TpvDouble;
begin
 if Count>0 then begin
  PreviousDirection:=Edges[Count-1].Direction(1).Normalize;
  for Index:=0 to Count-1 do begin
   Edge:=@Edges[Index];
   Direction:=-Edge^.Direction(0).Normalize;
   if (aPolarity*PreviousDirection.Cross(Direction))>=0.0 then begin
    MiterLength:=aMiterLimit;
    q:=(1.0-PreviousDirection.Dot(Direction))*0.5;
    if q>0.0 then begin
     MiterLength:=Min(1.0/sqrt(q),aMiterLimit);
    end;
    Miter:=Edge^.Point(0)+((PreviousDirection+Direction).Normalize*(aBorder*MiterLength));
    aBounds.PointBounds(Miter);
   end;
   PreviousDirection:=Edge^.Direction(1).Normalize;
  end;
 end;
end;

function TpvSignedDistanceField2DMSDFGenerator.TContour.Winding:TpvSizeInt;
var Total:TpvDouble;
    Index:TpvSizeInt;
    Edge:TpvSignedDistanceField2DMSDFGenerator.PEdgeSegment;
    a,b,c,d,Previous,Current:TpvVectorPathVector;
begin
 if CachedWinding=Low(TpvSizeInt) then begin
  if Count>0 then begin
   Total:=0.0;
   case Count of
    1:Begin
     a:=Edges[0].Point(0.0);
     b:=Edges[0].Point(1.0/3.0);
     c:=Edges[0].Point(2.0/3.0);
     Total:=Total+TpvSignedDistanceField2DMSDFGenerator.Shoelace(a,b);
     Total:=Total+TpvSignedDistanceField2DMSDFGenerator.Shoelace(b,c);
     Total:=Total+TpvSignedDistanceField2DMSDFGenerator.Shoelace(c,a);
    end;
    2:begin
     a:=Edges[0].Point(0.0);
     b:=Edges[0].Point(0.5);
     c:=Edges[1].Point(0.0);
     d:=Edges[1].Point(0.5);
     Total:=Total+TpvSignedDistanceField2DMSDFGenerator.Shoelace(a,b);
     Total:=Total+TpvSignedDistanceField2DMSDFGenerator.Shoelace(b,c);
     Total:=Total+TpvSignedDistanceField2DMSDFGenerator.Shoelace(c,d);
     Total:=Total+TpvSignedDistanceField2DMSDFGenerator.Shoelace(d,a);
    end;
    else begin
     Previous:=Edges[Count-1].Point(0.0);
     for Index:=0 to Count-1 do begin
      Edge:=@Edges[Index];
      Current:=Edge^.Point(0.0);
      Total:=Total+TpvSignedDistanceField2DMSDFGenerator.Shoelace(Previous,Current);
      Previous:=Current;
     end;
    end;
   end;
   result:=TpvSignedDistanceField2DMSDFGenerator.Sign(Total);
  end else begin
   result:=0;
  end;
  CachedWinding:=result;
 end else begin
  result:=CachedWinding;
 end;
end;

{ TpvSignedDistanceField2DMSDFGenerator.TShape }

class function TpvSignedDistanceField2DMSDFGenerator.TShape.Create:TpvSignedDistanceField2DMSDFGenerator.TShape;
begin
 result.Contours:=nil;
 result.Count:=0;
 result.InverseYAxis:=false;
end;

function TpvSignedDistanceField2DMSDFGenerator.TShape.AddContour:TpvSignedDistanceField2DMSDFGenerator.PContour;
begin
 if Count>=length(Contours) then begin
  SetLength(Contours,(Count+1)+((Count+1) shr 1)); // Grow factor 1.5
 end;
 result:=@Contours[Count];
 inc(Count);
 result^:=TContour.Create;
 result^.CachedWinding:=Low(TpvSizeInt);
end;

function TpvSignedDistanceField2DMSDFGenerator.TShape.Validate:boolean;
var ContourIndex,EdgeIndex:TpvSizeInt;
    Contour:TpvSignedDistanceField2DMSDFGenerator.PContour;
    Edge:TpvSignedDistanceField2DMSDFGenerator.PEdgeSegment;
    Corner:TpvVectorPathVector;
begin
 for ContourIndex:=0 to Count-1 do begin
  Contour:=@Contours[ContourIndex];
  if Contour^.Count>0 then begin
   Corner:=Contour^.Edges[Contour^.Count-1].Point(1);
   for EdgeIndex:=0 to Contour^.Count-1 do begin
    Edge:=@Contour^.Edges[EdgeIndex];
    if Edge^.Point(0)<>Corner then begin
     result:=false;
     exit;
    end;
    Corner:=Edge^.Point(1);
   end;
  end;
 end;
 result:=true;
end;

procedure TpvSignedDistanceField2DMSDFGenerator.TShape.Normalize;
var ContourIndex:TpvSizeInt;
    Contour:TpvSignedDistanceField2DMSDFGenerator.PContour;
    Part1,Part2,Part3:TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment;
begin
 for ContourIndex:=0 to Count-1 do begin
  Contour:=@Contours[ContourIndex];
  if Contour^.Count=1 then begin
   Contour^.Edges[0].SplitInThirds(Part1,Part2,Part3);
   Contour^.Edges:=nil;
   SetLength(Contour^.Edges,3);
   Contour^.Count:=3;
   Contour^.Edges[0]:=Part1;
   Contour^.Edges[1]:=Part2;
   Contour^.Edges[2]:=Part3;
  end;
 end;
end;

procedure TpvSignedDistanceField2DMSDFGenerator.TShape.Bounds(var aBounds:TpvSignedDistanceField2DMSDFGenerator.TBounds);
var ContourIndex:TpvSizeInt;
    Contour:TpvSignedDistanceField2DMSDFGenerator.PContour;
begin
 for ContourIndex:=0 to Count-1 do begin
  Contour:=@Contours[ContourIndex];
  Contour^.Bounds(aBounds);
 end;
end;

procedure TpvSignedDistanceField2DMSDFGenerator.TShape.BoundMiters(var aBounds:TpvSignedDistanceField2DMSDFGenerator.TBounds;const aBorder,aMiterLimit:TpvDouble;const aPolarity:TpvSizeInt);
var ContourIndex:TpvSizeInt;
    Contour:TpvSignedDistanceField2DMSDFGenerator.PContour;
begin
 for ContourIndex:=0 to Count-1 do begin
  Contour:=@Contours[ContourIndex];
  Contour^.BoundMiters(aBounds,aBorder,aMiterLimit,aPolarity);
 end;
end;

function TpvSignedDistanceField2DMSDFGenerator.TShape.GetBounds(const aBorder:TpvDouble;const aMiterLimit:TpvDouble;const aPolarity:TpvSizeInt):TpvSignedDistanceField2DMSDFGenerator.TBounds;
begin
 result.l:=MaxDouble;
 result.b:=MaxDouble;
 result.r:=-MaxDouble;
 result.t:=-MaxDouble;
 Bounds(result);
 if aBorder>0.0 then begin
  result.l:=result.l-aBorder;
  result.b:=result.b-aBorder;
  result.r:=result.r+aBorder;
  result.t:=result.t+aBorder;
  if aMiterLimit>0.0 then begin
   BoundMiters(result,aBorder,aMiterLimit,aPolarity);
  end;
 end;
end;

{ TpvSignedDistanceField2DMSDFGenerator }

class function TpvSignedDistanceField2DMSDFGenerator.Median(a,b,c:TpvDouble):TpvDouble;
begin
 result:=Max(Min(a,b),Min(Max(a,b),c));
end;

class function TpvSignedDistanceField2DMSDFGenerator.Sign(n:TpvDouble):TpvInt32;
begin
 if n<0.0 then begin
  result:=-1;
 end else if n>0.0 then begin
  result:=1;
 end else begin
  result:=0;
 end;
end;

class function TpvSignedDistanceField2DMSDFGenerator.NonZeroSign(n:TpvDouble):TpvInt32;
begin
 if n<0.0 then begin
  result:=-1;
 end else begin
  result:=1;
 end;
end;

class function TpvSignedDistanceField2DMSDFGenerator.SolveQuadratic(out x0,x1:TpvDouble;const a,b,c:TpvDouble):TpvSizeInt;
var d:TpvDouble;
begin
 if IsZero(a) or (abs(b)>(abs(a)*1e+12)) then begin
  if IsZero(b) then begin
   if IsZero(c) then begin
    result:=-1;
   end else begin
    result:=0;
   end;
  end else begin
   x0:=(-c)/b;
   result:=1;
  end;
 end else begin
  d:=sqr(b)-(4.0*a*c);
  if IsZero(d) then begin
   x0:=(-b)/(2.0*a);
   result:=1;
  end else if d>0.0 then begin
   d:=sqrt(d);
   x0:=((-b)+d)/(2.0*a);
   x1:=((-b)-d)/(2.0*a);
   result:=2;
  end else begin
   result:=0;
  end;
 end;
end;

class function TpvSignedDistanceField2DMSDFGenerator.SolveCubicNormed(out x0,x1,x2:TpvDouble;a,b,c:TpvDouble):TpvSizeInt;
const ONE_OVER_3=1.0/3.0;
      ONE_OVER_9=1.0/9.0;
      ONE_OVER_54=1.0/54.0;
      BoolSign:array[boolean] of TpvInt32=(-1,1);
var a2,q,r,r2,q3,t,u,v:TpvDouble;
begin
 a2:=sqr(a);
 q:=ONE_OVER_9*(a2-(3.0*b));
 r:=ONE_OVER_54*((a*((2.0*a2)-(9.0*b)))+(27*c));
 r2:=sqr(r);
 q3:=sqr(q)*q;
 a:=a*ONE_OVER_3;
 if r2<q3 then begin
  t:=r/sqrt(q3);
  if t<-1.0 then begin
   t:=-1.0;
  end else if t>1.0 then begin
   t:=1.0;
  end;
  t:=ArcCos(t);
  q:=(-2.0)*sqrt(q);
  x0:=(q*cos(ONE_OVER_3*t))-a;
  x1:=(q*cos(ONE_OVER_3*((t+2)*PI)))-a;
  x2:=(q*cos(ONE_OVER_3*((t-2)*PI)))-a;
  result:=3;
 end else begin
  u:=BoolSign[Boolean(r<0)]*Power(abs(r)+sqrt(r2-q3),1.0/3.0);
  if IsZero(u) then begin
   v:=0.0;
  end else begin
   v:=q/u;
  end;
  x0:=(u+v)-a;
  if SameValue(u,v) or (abs(u-v)<(1e-12*abs(u+v))) then begin
   x1:=((-0.5)*(u+v))-a;
   result:=2;
  end else begin
   result:=1;
  end;
 end;
end;

class function TpvSignedDistanceField2DMSDFGenerator.SolveCubic(out x0,x1,x2:TpvDouble;const a,b,c,d:TpvDouble):TpvSizeInt;
var bn:TpvDouble;
begin
 if IsZero(a) then begin
  result:=SolveQuadratic(x0,x1,b,c,d);
 end else begin
  bn:=b/a;
  if abs(bn)<1e+6 then begin
   result:=SolveCubicNormed(x0,x1,x2,bn,c/a,d/a);
  end else begin
   result:=SolveQuadratic(x0,x1,b,c,d);
  end;
 end;
end;

class function TpvSignedDistanceField2DMSDFGenerator.Shoelace(const a,b:TpvVectorPathVector):TpvDouble;
begin
 result:=(b.x-a.x)*(a.y+b.y);
end;

class procedure TpvSignedDistanceField2DMSDFGenerator.AutoFrame({$ifdef fpc}constref{$else}const{$endif} aShape:TpvSignedDistanceField2DMSDFGenerator.TShape;const aWidth,aHeight:TpvSizeInt;const aPixelRange:TpvDouble;out aTranslate,aScale:TpvVectorPathVector);
var Bounds:TpvSignedDistanceField2DMSDFGenerator.TBounds;
    l,b,r,t:TpvDouble;
    Frame,Dimensions:TpvVectorPathVector;
begin
 Bounds:=aShape.GetBounds;
 l:=Bounds.l;
 b:=Bounds.b;
 r:=Bounds.r;
 t:=Bounds.t;
 if (l>=r) or (b>=t) then begin
  l:=0.0;
  b:=0.0;
  r:=1.0;
  t:=1.0;
 end;
 Frame:=TpvVectorPathVector.Create(aWidth-aPixelRange,aHeight-aPixelRange);
 if (Frame.x<=1e-6) or (Frame.y<=1e-6) then begin
  raise EpvSignedDistanceField2DMSDFGenerator.Create('Cannot fit the specified pixel range');
 end;
 Dimensions:=TpvVectorPathVector.Create(r-l,t-b);
 if (Dimensions.x*Frame.y)<(Dimensions.y*Frame.x) then begin
  aTranslate:=TpvVectorPathVector.Create(((((Frame.x/Frame.y)*Dimensions.y)-Dimensions.x)*0.5)-l,-b);
  aScale:=TpvVectorPathVector.Create(Frame.y/Dimensions.y);
 end else begin
  aTranslate:=TpvVectorPathVector.Create(-l,((((Frame.y/Frame.x)*Dimensions.x)-Dimensions.y)*0.5)-b);
  aScale:=TpvVectorPathVector.Create(Frame.x/Dimensions.x);
 end;
 aTranslate:=aTranslate+(TpvVectorPathVector.Create(aPixelRange*0.5)/aScale);
end;

class function TpvSignedDistanceField2DMSDFGenerator.IsCorner(const aDirection,bDirection:TpvVectorPathVector;const aCrossThreshold:TpvDouble):boolean;
begin
 result:=(aDirection.Dot(bDirection)<=0.0) or (abs(aDirection.Cross(bDirection))>aCrossThreshold);
end;

class procedure TpvSignedDistanceField2DMSDFGenerator.SwitchColor(var aColor:TpvSignedDistanceField2DMSDFGenerator.TEdgeColor;var aSeed:TpvUInt64;const aBanned:TpvSignedDistanceField2DMSDFGenerator.TEdgeColor=TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.BLACK);
var Combined:TpvSignedDistanceField2DMSDFGenerator.TEdgeColor;
     Shifted:TpvUInt32;
begin
 Combined:=TpvSignedDistanceField2DMSDFGenerator.TEdgeColor(TpvUInt32(TpvUInt32(aColor) and TpvUInt32(aBanned)));
 if Combined in [TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.RED,
                 TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.GREEN,
                 TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.BLUE] then begin
  aColor:=TpvSignedDistanceField2DMSDFGenerator.TEdgeColor(TpvUInt32(TpvUInt32(Combined) xor TpvUInt32(TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.WHITE)));
 end else begin
  Shifted:=TpvUInt32(aColor) shl (1+(aSeed and 1));
  aColor:=TpvSignedDistanceField2DMSDFGenerator.TEdgeColor(TpvUInt32(TpvUInt32(Shifted or (Shifted shr 3)) and TpvUInt32(TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.WHITE)));
  aSeed:=aSeed shr 1;
 end;
end;

class procedure TpvSignedDistanceField2DMSDFGenerator.EdgeColoringSimple(var aShape:TpvSignedDistanceField2DMSDFGenerator.TShape;const aAngleThreshold:TpvDouble;aSeed:TpvUInt64);
type TCorners=array of TpvSizeInt;
var ContourIndex,EdgeIndex,CountCorners,Corner,Spline,Start,Index:TpvSizeInt;
    CrossThreshold:TpvDouble;
    Corners:TCorners;
    Contour:TpvSignedDistanceField2DMSDFGenerator.PContour;
    PreviousDirection:TpvVectorPathVector;
    Edge:TpvSignedDistanceField2DMSDFGenerator.PEdgeSegment;
    Color,InitialColor:TpvSignedDistanceField2DMSDFGenerator.TEdgeColor;
    Colors:array[0..5] of TpvSignedDistanceField2DMSDFGenerator.TEdgeColor;
    Parts:array[0..6] of TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment;
 function InitializeColor(var aColorSeed:TpvUInt64):TpvSignedDistanceField2DMSDFGenerator.TEdgeColor;
 const StartColors:array[0..2] of TpvSignedDistanceField2DMSDFGenerator.TEdgeColor=
        (
         TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.CYAN,
         TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.MAGENTA,
         TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.YELLOW
        );
 begin
  result:=StartColors[aColorSeed mod 3];
  aColorSeed:=aColorSeed div 3;
 end;
 function SymmetricalTrichotomy(const aPosition,aCount:TpvSizeInt):TpvSizeInt;
 begin
  result:=Trunc(3.0+(2.875*aPosition/(aCount-1))-1.4375+0.5)-3;
 end;
begin
 CrossThreshold:=sin(aAngleThreshold);
 Color:=InitializeColor(aSeed);
 Corners:=nil;
 try
  for ContourIndex:=0 to aShape.Count-1 do begin
   Contour:=@aShape.Contours[ContourIndex];
   try
    CountCorners:=0;
    if Contour^.Count>0 then begin
     PreviousDirection:=Contour^.Edges[Contour^.Count-1].Direction(1);
     for EdgeIndex:=0 to Contour^.Count-1 do begin
      Edge:=@Contour^.Edges[EdgeIndex];
      if IsCorner(PreviousDirection.Normalize,Edge^.Direction(0).Normalize,CrossThreshold) then begin
       if CountCorners>=length(Corners) then begin
        SetLength(Corners,(CountCorners+1)+((CountCorners+1) shr 1));
       end;
       Corners[CountCorners]:=EdgeIndex;
       inc(CountCorners);
      end;
      PreviousDirection:=Edge^.Direction(1);
     end;
     case CountCorners of
      0:begin
       TpvSignedDistanceField2DMSDFGenerator.SwitchColor(Color,aSeed);
       for EdgeIndex:=0 to Contour^.Count-1 do begin
        Edge:=@Contour^.Edges[EdgeIndex];
        Edge^.Color:=Color;
       end;
      end;
      1:begin
       TpvSignedDistanceField2DMSDFGenerator.SwitchColor(Color,aSeed);
       Colors[0]:=Color;
       Colors[1]:=TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.WHITE;
       TpvSignedDistanceField2DMSDFGenerator.SwitchColor(Color,aSeed);
       Colors[2]:=Color;
       Corner:=Corners[0];
       if Contour.Count>=3 then begin
        for EdgeIndex:=0 to Contour.Count-1 do begin
         Edge:=@Contour^.Edges[(EdgeIndex+Corner) mod Contour.Count];
         Edge^.Color:=Colors[1+SymmetricalTrichotomy(EdgeIndex,Contour.Count)];
        end;
       end else if Contour.Count>=1 then begin
        Contour.Edges[0].SplitInThirds(Parts[(3*Corner)+0],Parts[(3*Corner)+1],Parts[(3*Corner)+2]);
        if Contour.Count>=2 then begin
         Contour.Edges[1].SplitInThirds(Parts[3-(3*Corner)],Parts[4-(3*Corner)],Parts[5-(3*Corner)]);
         Parts[0].Color:=Colors[0];
         Parts[1].Color:=Colors[0];
         Parts[2].Color:=Colors[1];
         Parts[3].Color:=Colors[1];
         Parts[4].Color:=Colors[2];
         Parts[5].Color:=Colors[2];
         Contour.Count:=6;
         SetLength(Contour.Edges,6);
         Contour.Edges[0]:=Parts[0];
         Contour.Edges[1]:=Parts[1];
         Contour.Edges[2]:=Parts[2];
         Contour.Edges[3]:=Parts[3];
         Contour.Edges[4]:=Parts[4];
         Contour.Edges[5]:=Parts[5];
        end else begin
         Parts[0].Color:=Colors[0];
         Parts[1].Color:=Colors[1];
         Parts[2].Color:=Colors[2];
         Contour.Count:=3;
         SetLength(Contour.Edges,3);
         Contour.Edges[0]:=Parts[0];
         Contour.Edges[1]:=Parts[1];
         Contour.Edges[2]:=Parts[2];
        end;
       end;
      end;
      else begin
       Spline:=0;
       Start:=Corners[0];
       TpvSignedDistanceField2DMSDFGenerator.SwitchColor(Color,aSeed,TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.BLACK);
       InitialColor:=Color;
       for EdgeIndex:=0 to Contour^.Count-1 do begin
        Index:=(Start+EdgeIndex) mod Contour^.Count;
        if ((Spline+1)<CountCorners) and (Corners[Spline+1]=Index) then begin
         inc(Spline);
         TpvSignedDistanceField2DMSDFGenerator.SwitchColor(Color,aSeed,TpvSignedDistanceField2DMSDFGenerator.TEdgeColor(TpvUInt32(TpvUInt32(ord(Spline=(CountCorners-1)) and 1)*TpvUInt32(InitialColor))));
        end;
        Contour^.Edges[Index].Color:=Color;
       end;
      end;
     end;
    end;
   finally
    Corners:=nil;
   end;
  end;
 finally
  Corners:=nil;
 end;

end;

class procedure TpvSignedDistanceField2DMSDFGenerator.GenerateDistanceFieldPixel(var aImage:TpvSignedDistanceField2DMSDFGenerator.TImage;{$ifdef fpc}constref{$else}const{$endif} aShape:TpvSignedDistanceField2DMSDFGenerator.TShape;const aRange:TpvDouble;const aScale,aTranslate:TpvVectorPathVector;const aX,aY:TpvSizeInt);
type TEdgePoint=Record
      MinDistance:TpvSignedDistanceField2DMSDFGenerator.TSignedDistance;
      NearEdge:TpvSignedDistanceField2DMSDFGenerator.PEdgeSegment;
      NearParam:TpvDouble;
     end;
var x,y,ContourIndex,EdgeIndex,Winding:TpvSizeInt;
    Contour:TpvSignedDistanceField2DMSDFGenerator.PContour;
    Edge:TpvSignedDistanceField2DMSDFGenerator.PEdgeSegment;
    r,g,b,sr,sg,sb:TEdgePoint;
    p:TpvVectorPathVector;
    Param,MedianMinDistance,MinMedianDistance,
    PositiveDistance,NegativeDistance:TpvDouble;
    MinDistance,Distance:TpvSignedDistanceField2DMSDFGenerator.TSignedDistance;
    HasMinDistance,UseShapeDistanceFallback:boolean;
    Pixel:TpvSignedDistanceField2DMSDFGenerator.PPixel;
    MultiSignedDistance,PositiveMultiSignedDistance,NegativeMultiSignedDistance,ShapeMultiSignedDistance:TMultiSignedDistance;
    HasPositiveMultiSignedDistance,HasNegativeMultiSignedDistance:boolean;
 procedure MergeMultiSignedDistance(var aTarget:TpvSignedDistanceField2DMSDFGenerator.TMultiSignedDistance;const aSource:TpvSignedDistanceField2DMSDFGenerator.TMultiSignedDistance;var aInitialized:boolean);
 begin
  if not aInitialized then begin
   aTarget:=aSource;
   aInitialized:=true;
  end else begin
   if abs(aSource.r)<abs(aTarget.r) then begin
    aTarget.r:=aSource.r;
   end;
   if abs(aSource.g)<abs(aTarget.g) then begin
    aTarget.g:=aSource.g;
   end;
   if abs(aSource.b)<abs(aTarget.b) then begin
    aTarget.b:=aSource.b;
   end;
   aTarget.Median:=TpvSignedDistanceField2DMSDFGenerator.Median(aTarget.r,aTarget.g,aTarget.b);
  end;
 end;
begin

 x:=aX;

 if aShape.InverseYAxis then begin
  y:=aImage.Height-(aY+1);
 end else begin
  y:=aY;
 end;

 p:=(TpvVectorPathVector.Create(x+0.5,y+0.5)/aScale)-aTranslate;

 MinMedianDistance:=abs(TpvSignedDistanceField2DMSDFGenerator.PositiveInfinityDistance);

 PositiveDistance:=TpvSignedDistanceField2DMSDFGenerator.NegativeInfinityDistance;

 NegativeDistance:=TpvSignedDistanceField2DMSDFGenerator.PositiveInfinityDistance;

 HasPositiveMultiSignedDistance:=false;

 HasNegativeMultiSignedDistance:=false;

 MinDistance:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Empty;
 HasMinDistance:=false;

 sr.MinDistance:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Empty;
 sr.NearEdge:=nil;
 sr.NearParam:=0.0;

 sg.MinDistance:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Empty;
 sg.NearEdge:=nil;
 sg.NearParam:=0.0;

 sb.MinDistance:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Empty;
 sb.NearEdge:=nil;
 sb.NearParam:=0.0;

 Winding:=0;

 for ContourIndex:=0 to aShape.Count-1 do begin

  r.MinDistance:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Empty;
  r.NearEdge:=nil;
  r.NearParam:=0.0;

  g.MinDistance:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Empty;
  g.NearEdge:=nil;
  g.NearParam:=0.0;

  b.MinDistance:=TpvSignedDistanceField2DMSDFGenerator.TSignedDistance.Empty;
  b.NearEdge:=nil;
  b.NearParam:=0.0;

  Contour:=@aShape.Contours[ContourIndex];
  if Contour^.Count>0 then begin

   for EdgeIndex:=0 to Contour^.Count-1 do begin

    Edge:=@Contour^.Edges[EdgeIndex];

    Distance:=Edge^.MinSignedDistance(p,Param);

    if (not HasMinDistance) or (Distance<MinDistance) then begin
     MinDistance:=Distance;
     HasMinDistance:=true;
    end;

    if ((TpvUInt32(Edge^.Color) and TpvUInt32(TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.RED))<>0) and ((not assigned(r.NearEdge)) or (Distance<r.MinDistance)) then begin
     r.MinDistance:=Distance;
     r.NearEdge:=Edge;
     r.NearParam:=Param;
    end;

    if ((TpvUInt32(Edge^.Color) and TpvUInt32(TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.GREEN))<>0) and ((not assigned(g.NearEdge)) or (Distance<g.MinDistance)) then begin
     g.MinDistance:=Distance;
     g.NearEdge:=Edge;
     g.NearParam:=Param;
    end;

    if ((TpvUInt32(Edge^.Color) and TpvUInt32(TpvSignedDistanceField2DMSDFGenerator.TEdgeColor.BLUE))<>0) and ((not assigned(b.NearEdge)) or (Distance<b.MinDistance)) then begin
     b.MinDistance:=Distance;
     b.NearEdge:=Edge;
     b.NearParam:=Param;
    end;

   end;

  end;

  if (not assigned(sr.NearEdge)) or (r.MinDistance<sr.MinDistance) then begin
   sr:=r;
  end;

  if (not assigned(sg.NearEdge)) or (g.MinDistance<sg.MinDistance) then begin
   sg:=g;
  end;

  if (not assigned(sb.NearEdge)) or (b.MinDistance<sb.MinDistance) then begin
   sb:=b;
  end;

  MedianMinDistance:=abs(TpvSignedDistanceField2DMSDFGenerator.Median(r.MinDistance.Distance,g.MinDistance.Distance,b.MinDistance.Distance));
  if MedianMinDistance<MinMedianDistance then begin
   MinMedianDistance:=MedianMinDistance;
   Winding:=Contour^.Winding;
  end;

  if assigned(r.NearEdge) then begin
   r.NearEdge^.DistanceToPseudoDistance(r.MinDistance,p,r.NearParam);
  end;

  if assigned(g.NearEdge) then begin
   g.NearEdge^.DistanceToPseudoDistance(g.MinDistance,p,g.NearParam);
  end;

  if assigned(b.NearEdge) then begin
   b.NearEdge^.DistanceToPseudoDistance(b.MinDistance,p,b.NearParam);
  end;

  MedianMinDistance:=TpvSignedDistanceField2DMSDFGenerator.Median(r.MinDistance.Distance,g.MinDistance.Distance,b.MinDistance.Distance);
  Contour^.MultiSignedDistance.r:=r.MinDistance.Distance;
  Contour^.MultiSignedDistance.g:=g.MinDistance.Distance;
  Contour^.MultiSignedDistance.b:=b.MinDistance.Distance;
  Contour^.MultiSignedDistance.Median:=MedianMinDistance;

  if abs(MedianMinDistance)<>1e240 then begin
   if (Contour^.Winding>0) and (MedianMinDistance>=0.0) then begin
    MergeMultiSignedDistance(PositiveMultiSignedDistance,Contour^.MultiSignedDistance,HasPositiveMultiSignedDistance);
   end;
   if (Contour^.Winding<0) and (MedianMinDistance<=0.0) then begin
    MergeMultiSignedDistance(NegativeMultiSignedDistance,Contour^.MultiSignedDistance,HasNegativeMultiSignedDistance);
   end;
  end;
 end;

 if assigned(sr.NearEdge) then begin
  sr.NearEdge^.DistanceToPseudoDistance(sr.MinDistance,p,sr.NearParam);
 end;

 if assigned(sg.NearEdge) then begin
  sg.NearEdge^.DistanceToPseudoDistance(sg.MinDistance,p,sg.NearParam);
 end;

 if assigned(sb.NearEdge) then begin
  sb.NearEdge^.DistanceToPseudoDistance(sb.MinDistance,p,sb.NearParam);
 end;

 ShapeMultiSignedDistance.r:=sr.MinDistance.Distance;
 ShapeMultiSignedDistance.g:=sg.MinDistance.Distance;
 ShapeMultiSignedDistance.b:=sb.MinDistance.Distance;
 ShapeMultiSignedDistance.Median:=TpvSignedDistanceField2DMSDFGenerator.Median(sr.MinDistance.Distance,sg.MinDistance.Distance,sb.MinDistance.Distance);

 if HasPositiveMultiSignedDistance then begin
  PositiveDistance:=PositiveMultiSignedDistance.Median;
 end;

 if HasNegativeMultiSignedDistance then begin
  NegativeDistance:=NegativeMultiSignedDistance.Median;
 end;

 UseShapeDistanceFallback:=false;

 MultiSignedDistance.r:=TpvSignedDistanceField2DMSDFGenerator.NegativeInfinityDistance;
 MultiSignedDistance.g:=TpvSignedDistanceField2DMSDFGenerator.NegativeInfinityDistance;
 MultiSignedDistance.b:=TpvSignedDistanceField2DMSDFGenerator.NegativeInfinityDistance;
 MultiSignedDistance.Median:=TpvSignedDistanceField2DMSDFGenerator.NegativeInfinityDistance;

 if HasPositiveMultiSignedDistance and (PositiveDistance>=0.0) and (abs(PositiveDistance)<=abs(NegativeDistance)) then begin
  MultiSignedDistance:=PositiveMultiSignedDistance;
  Winding:=1;
  for ContourIndex:=0 to aShape.Count-1 do begin
   Contour:=@aShape.Contours[ContourIndex];
   if (Contour^.Winding>0) and (Contour^.MultiSignedDistance.Median>MultiSignedDistance.Median) and (abs(Contour^.MultiSignedDistance.Median)<abs(NegativeDistance)) then begin
    MultiSignedDistance:=Contour^.MultiSignedDistance;
   end;
  end;
 end else if HasNegativeMultiSignedDistance and (NegativeDistance<=0.0) and (abs(NegativeDistance)<abs(PositiveDistance)) then begin
  MultiSignedDistance:=NegativeMultiSignedDistance;
  Winding:=-1;
  for ContourIndex:=0 to aShape.Count-1 do begin
   Contour:=@aShape.Contours[ContourIndex];
   if (Contour^.Winding<0) and (Contour^.MultiSignedDistance.Median<MultiSignedDistance.Median) and (abs(Contour^.MultiSignedDistance.Median)<abs(PositiveDistance)) then begin
    MultiSignedDistance:=Contour^.MultiSignedDistance;
   end;
  end;
 end else begin
  UseShapeDistanceFallback:=true;
  MultiSignedDistance:=ShapeMultiSignedDistance;
 end;

 if not UseShapeDistanceFallback then begin
  for ContourIndex:=0 to aShape.Count-1 do begin
   Contour:=@aShape.Contours[ContourIndex];
   if (Contour^.Winding<>Winding) and (Contour^.MultiSignedDistance.Median*MultiSignedDistance.Median>=0.0) and (abs(Contour^.MultiSignedDistance.Median)<abs(MultiSignedDistance.Median)) then begin
    MultiSignedDistance:=Contour^.MultiSignedDistance;
   end;
  end;
  if SameValue(ShapeMultiSignedDistance.Median,MultiSignedDistance.Median) then begin
   MultiSignedDistance.r:=ShapeMultiSignedDistance.r;
   MultiSignedDistance.g:=ShapeMultiSignedDistance.g;
   MultiSignedDistance.b:=ShapeMultiSignedDistance.b;
  end;
 end;

 Pixel:=@aImage.Pixels[(aY*aImage.Width)+aX];
 Pixel^.r:=(MultiSignedDistance.r/aRange)+0.5;
 Pixel^.g:=(MultiSignedDistance.g/aRange)+0.5;
 Pixel^.b:=(MultiSignedDistance.b/aRange)+0.5;
 Pixel^.a:=(MinDistance.Distance/aRange)+0.5;
end;

type TpvSignedDistanceField2DMSDFGeneratorGenerateDistanceFieldData=record
      Image:TpvSignedDistanceField2DMSDFGenerator.PImage;
      Shape:TpvSignedDistanceField2DMSDFGenerator.PShape;
      Range:TpvDouble;
      Scale:TpvVectorPathVector;
      Translate:TpvVectorPathVector;
     end;

     PpvSignedDistanceField2DMSDFGeneratorGenerateDistanceFieldData=^TpvSignedDistanceField2DMSDFGeneratorGenerateDistanceFieldData;

procedure TpvSignedDistanceField2DMSDFGeneratorGenerateDistanceFieldParallelForJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32;const DataPointer:TpvPointer;const FromIndex,ToIndex:TPasMPNativeInt);
var Data:PpvSignedDistanceField2DMSDFGeneratorGenerateDistanceFieldData;
    Index,x,y,w:TPasMPNativeInt;
begin
 Data:=DataPointer;
 w:=Data^.Image^.Width;
 for Index:=FromIndex to ToIndex do begin
  y:=Index div w;
  x:=Index-(y*w);
  TpvSignedDistanceField2DMSDFGenerator.GenerateDistanceFieldPixel(Data^.Image^,Data^.Shape^,Data^.Range,Data^.Scale,Data^.Translate,x,y);
 end;
end;

class procedure TpvSignedDistanceField2DMSDFGenerator.GenerateDistanceField(var aImage:TpvSignedDistanceField2DMSDFGenerator.TImage;{$ifdef fpc}constref{$else}const{$endif} aShape:TpvSignedDistanceField2DMSDFGenerator.TShape;const aRange:TpvDouble;const aScale,aTranslate:TpvVectorPathVector;const aPasMPInstance:TPasMP=nil);
var x,y:TpvSizeInt;
    Data:TpvSignedDistanceField2DMSDFGeneratorGenerateDistanceFieldData;
begin
 if assigned(aPasMPInstance) then begin
  Data.Image:=@aImage;
  Data.Shape:=@aShape;
  Data.Range:=aRange;
  Data.Scale:=aScale;
  Data.Translate:=aTranslate;
  aPasMPInstance.Invoke(aPasMPInstance.ParallelFor(@Data,0,(aImage.Width*aImage.Height)-1,TpvSignedDistanceField2DMSDFGeneratorGenerateDistanceFieldParallelForJobFunction,1,10,nil,0));
 end else begin
  for y:=0 to aImage.Height-1 do begin
   for x:=0 to aImage.Width-1 do begin
    TpvSignedDistanceField2DMSDFGenerator.GenerateDistanceFieldPixel(aImage,aShape,aRange,aScale,aTranslate,x,y);
   end;
  end;
 end;
end;

class function TpvSignedDistanceField2DMSDFGenerator.DetectClash({$ifdef fpc}constref{$else}const{$endif} a,b:TpvSignedDistanceField2DMSDFGenerator.TPixel;const aThreshold:TpvDouble):boolean;
var a0,a1,a2,b0,b1,b2,t:TpvDouble;
begin
 a0:=a.r;
 a1:=a.g;
 a2:=a.b;
 b0:=b.r;
 b1:=b.g;
 b2:=b.b;
 if abs(b0-a0)<abs(b1-a1) then begin
  t:=a0;
  a0:=a1;
  a1:=t;
  t:=b0;
  b0:=b1;
  b1:=t;
 end;
 if abs(b1-a1)<abs(b2-a2) then begin
  t:=a1;
  a1:=a2;
  a2:=t;
  t:=b1;
  b1:=b2;
  b2:=t;
  if abs(b0-a0)<abs(b1-a1) then begin
   t:=a0;
   a0:=a1;
   a1:=t;
   t:=b0;
   b0:=b1;
   b1:=t;
  end;
 end;
 result:=(abs(b1-a1)>=aThreshold) and (not (SameValue(b0,b1) and SameValue(b0,b2))) and (abs(a2-0.5)>=abs(b2-0.5));
end;

class procedure TpvSignedDistanceField2DMSDFGenerator.ErrorCorrection(var aImage:TpvSignedDistanceField2DMSDFGenerator.TImage;{$ifdef fpc}constref{$else}const{$endif} aShape:TpvSignedDistanceField2DMSDFGenerator.TShape;const aRange:TpvDouble;const aScale,aTranslate:TpvVectorPathVector);
const ARTIFACT_T_EPSILON=0.01;
      MIN_DEVIATION_RATIO=10.0/9.0;
      PROTECTION_RADIUS_TOLERANCE=1.001;
      STENCIL_ERROR=1;
      STENCIL_PROTECTED=2;
type TStencilArray=TpvUInt8DynamicArray;
var Stencil:TStencilArray;
    X,Y,ContourIndex,EdgeIndex:TpvSizeInt;
    Contour:TpvSignedDistanceField2DMSDFGenerator.PContour;
    Edge,PreviousEdge:TpvSignedDistanceField2DMSDFGenerator.PEdgeSegment;
    CornerPoint:TpvVectorPathVector;
    CornerX,CornerY,CornerEndX,CornerEndY:TpvSizeInt;
    CommonColor:TpvSizeInt;
    HorizontalSpan,VerticalSpan,DiagonalSpan,HorizontalProtectionRadius,VerticalProtectionRadius,DiagonalProtectionRadius,DistanceMappingDelta,InverseScaleX,InverseScaleY:TpvDouble;
    PixelA,PixelB,PixelC,PixelD:TpvSignedDistanceField2DMSDFGenerator.PPixel;
    CurrentMedian,MedianValue,MedianValueA,MedianValueB:TpvDouble;
    EdgeMask:TpvSizeInt;
    Pixel:TpvSignedDistanceField2DMSDFGenerator.PPixel;

 function PixelChannel(const aPixel:TpvSignedDistanceField2DMSDFGenerator.TPixel;const aChannel:TpvSizeInt):TpvDouble;
 begin
  case aChannel of
   0:begin
    result:=aPixel.r;
   end;
   1:begin
    result:=aPixel.g;
   end;
   else begin
    result:=aPixel.b;
   end;
  end;
 end;

 function LinearMedian(const aA,aB:TpvSignedDistanceField2DMSDFGenerator.TPixel;const aTime:TpvDouble):TpvDouble;
 var InverseTime:TpvDouble;
 begin
  InverseTime:=1.0-aTime;
  result:=TpvSignedDistanceField2DMSDFGenerator.Median((aA.r*InverseTime)+(aB.r*aTime),
                                                       (aA.g*InverseTime)+(aB.g*aTime),
                                                       (aA.b*InverseTime)+(aB.b*aTime));
 end;

 function BilinearMedian(const aA:TpvSignedDistanceField2DMSDFGenerator.TPixel;
                         const aLinear,aQuadratic:array of TpvDouble;
                         const aTime:TpvDouble):TpvDouble;
 begin
  result:=TpvSignedDistanceField2DMSDFGenerator.Median((aTime*((aTime*aQuadratic[0])+aLinear[0]))+aA.r,
                                                       (aTime*((aTime*aQuadratic[1])+aLinear[1]))+aA.g,
                                                       (aTime*((aTime*aQuadratic[2])+aLinear[2]))+aA.b);
 end;

 function RangeTest(const aATime,aBTime,aXTime,aAMedian,aBMedian,aXMedian,aSpan:TpvDouble;const aProtected:boolean):TpvSizeInt;
 var AXSpan,BXSpan:TpvDouble;
 begin
  if ((aAMedian>0.5) and (aBMedian>0.5) and (aXMedian<=0.5)) or
     ((aAMedian<0.5) and (aBMedian<0.5) and (aXMedian>=0.5)) or
     ((not aProtected) and (TpvSignedDistanceField2DMSDFGenerator.Median(aAMedian,aBMedian,aXMedian)<>aXMedian)) then begin
   AXSpan:=(aXTime-aATime)*aSpan;
   BXSpan:=(aBTime-aXTime)*aSpan;
   if not ((aXMedian>=(aAMedian-AXSpan)) and (aXMedian<=(aAMedian+AXSpan)) and (aXMedian>=(aBMedian-BXSpan)) and (aXMedian<=(aBMedian+BXSpan))) then begin
    result:=3;
   end else begin
    result:=1;
   end;
  end else begin
   result:=0;
  end;
 end;

 function HasLinearArtifactInner(const aAm,aBm:TpvDouble;
                                 const aA,aB:TpvSignedDistanceField2DMSDFGenerator.TPixel;
                                 const aDA,aDB,aSpan:TpvDouble;
                                 const aProtected:boolean):boolean;
 var xT,xM:TpvDouble;
 begin
  if abs(aDA-aDB)>=1e-15 then begin
   xT:=aDA/(aDA-aDB);
   if (xT>ARTIFACT_T_EPSILON) and (xT<(1.0-ARTIFACT_T_EPSILON)) then begin
    xM:=LinearMedian(aA,aB,xT);
    result:=(RangeTest(0.0,1.0,xT,aAm,aBm,xM,aSpan,aProtected) and 2)<>0;
   end else begin
    result:=false;
   end;
  end else begin
   result:=false;
  end;
 end;

 function HasLinearArtifact(const aCurrentMedian:TpvDouble;
                            const aCurrentPixel,aNeighborPixel:TpvSignedDistanceField2DMSDFGenerator.TPixel;
                            const aSpan:TpvDouble;const aProtected:boolean):boolean;
 var NeighborMedian:TpvDouble;
 begin
  NeighborMedian:=TpvSignedDistanceField2DMSDFGenerator.Median(aNeighborPixel.r,aNeighborPixel.g,aNeighborPixel.b);
  if abs(aCurrentMedian-0.5)>=abs(NeighborMedian-0.5) then begin
   result:=HasLinearArtifactInner(aCurrentMedian,NeighborMedian,aCurrentPixel,aNeighborPixel,
                                  aCurrentPixel.g-aCurrentPixel.r,aNeighborPixel.g-aNeighborPixel.r,aSpan,aProtected) or
           HasLinearArtifactInner(aCurrentMedian,NeighborMedian,aCurrentPixel,aNeighborPixel,
                                  aCurrentPixel.b-aCurrentPixel.g,aNeighborPixel.b-aNeighborPixel.g,aSpan,aProtected) or
           HasLinearArtifactInner(aCurrentMedian,NeighborMedian,aCurrentPixel,aNeighborPixel,
                                  aCurrentPixel.r-aCurrentPixel.b,aNeighborPixel.r-aNeighborPixel.b,aSpan,aProtected);
  end else begin
   result:=false;
  end;
 end;

 function HasDiagonalArtifactInner(const aAMedian,aDMedian:TpvDouble;
                                   const aA:TpvSignedDistanceField2DMSDFGenerator.TPixel;
                                   const aLinearCoefficients,aQuadraticCoefficients:array of TpvDouble;
                                   const aDeltaA,aDeltaBC,aDeltaD,aTimeExtrema0,aTimeExtrema1,aSpan:TpvDouble;
                                   const aProtected:boolean):boolean;
 var Solutions,Index,Flags:TpvSizeInt;
     XMedian:TpvDouble;
     Times,TimeEnd,EndMedians:array[0..1] of TpvDouble;
 begin
  result:=false;
  Solutions:=TpvSignedDistanceField2DMSDFGenerator.SolveQuadratic(Times[0],Times[1],aDeltaD-aDeltaBC+aDeltaA,aDeltaBC-aDeltaA-aDeltaA,aDeltaA);
  for Index:=0 to Solutions-1 do begin
   if (Times[Index]>ARTIFACT_T_EPSILON) and (Times[Index]<1.0-ARTIFACT_T_EPSILON) then begin
    XMedian:=BilinearMedian(aA,aLinearCoefficients,aQuadraticCoefficients,Times[Index]);
    Flags:=RangeTest(0,1,Times[Index],aAMedian,aDMedian,XMedian,aSpan,aProtected);
    if (aTimeExtrema0>0) and (aTimeExtrema0<1) then begin
     TimeEnd[0]:=0;
     TimeEnd[1]:=1;
     EndMedians[0]:=aAMedian;
     EndMedians[1]:=aDMedian;
     if aTimeExtrema0>Times[Index] then begin
      TimeEnd[1]:=aTimeExtrema0;
      EndMedians[1]:=BilinearMedian(aA,aLinearCoefficients,aQuadraticCoefficients,aTimeExtrema0);
     end else begin
      TimeEnd[0]:=aTimeExtrema0;
      EndMedians[0]:=BilinearMedian(aA,aLinearCoefficients,aQuadraticCoefficients,aTimeExtrema0);
     end;
     Flags:=Flags or RangeTest(TimeEnd[0],TimeEnd[1],Times[Index],EndMedians[0],EndMedians[1],XMedian,aSpan,aProtected);
    end;
    if (aTimeExtrema1>0) and (aTimeExtrema1<1) then begin
     TimeEnd[0]:=0;
     TimeEnd[1]:=1;
     EndMedians[0]:=aAMedian;
     EndMedians[1]:=aDMedian;
     if aTimeExtrema1>Times[Index] then begin
      TimeEnd[1]:=aTimeExtrema1;
      EndMedians[1]:=BilinearMedian(aA,aLinearCoefficients,aQuadraticCoefficients,aTimeExtrema1);
     end else begin
      TimeEnd[0]:=aTimeExtrema1;
      EndMedians[0]:=BilinearMedian(aA,aLinearCoefficients,aQuadraticCoefficients,aTimeExtrema1);
     end;
     Flags:=Flags or RangeTest(TimeEnd[0],TimeEnd[1],Times[Index],EndMedians[0],EndMedians[1],XMedian,aSpan,aProtected);
    end;
    if (Flags and 2)<>0 then begin
     result:=true;
     exit;
    end;
   end;
  end;
 end;

 function HasDiagonalArtifact(const aAMedian:TpvDouble;
                              const aA,aB,aC,aD:TpvSignedDistanceField2DMSDFGenerator.TPixel;
                              const aSpan:TpvDouble;const aProtected:boolean):boolean;
 var DiagonalMedian:TpvDouble;
     BilinearCross:array[0..2] of TpvDouble;
     LinearCoefficients:array[0..2] of TpvDouble;
     QuadraticCoefficients:array[0..2] of TpvDouble;
     TimeExtrema:array[0..2] of TpvDouble;
     Index:TpvSizeInt;
 begin
  DiagonalMedian:=TpvSignedDistanceField2DMSDFGenerator.Median(aD.r,aD.g,aD.b);
  if abs(aAMedian-0.5)>=abs(DiagonalMedian-0.5) then begin
   BilinearCross[0]:=(aA.r-aB.r)-aC.r;
   BilinearCross[1]:=(aA.g-aB.g)-aC.g;
   BilinearCross[2]:=(aA.b-aB.b)-aC.b;
   LinearCoefficients[0]:=(-aA.r)-BilinearCross[0];
   LinearCoefficients[1]:=(-aA.g)-BilinearCross[1];
   LinearCoefficients[2]:=(-aA.b)-BilinearCross[2];
   QuadraticCoefficients[0]:=aD.r+BilinearCross[0];
   QuadraticCoefficients[1]:=aD.g+BilinearCross[1];
   QuadraticCoefficients[2]:=aD.b+BilinearCross[2];
   for Index:=0 to 2 do begin
    if abs(QuadraticCoefficients[Index])>1e-15 then begin
     TimeExtrema[Index]:=(-0.5)*(LinearCoefficients[Index]/QuadraticCoefficients[Index]);
    end else begin
     TimeExtrema[Index]:=-1.0;
    end;
   end;
   result:=HasDiagonalArtifactInner(aAMedian,DiagonalMedian,
                                    aA,LinearCoefficients,QuadraticCoefficients,
                                    aA.g-aA.r,((aB.g-aB.r)+aC.g)-aC.r,aD.g-aD.r,
                                    TimeExtrema[0],TimeExtrema[1],aSpan,aProtected) or
           HasDiagonalArtifactInner(aAMedian,DiagonalMedian,
                                    aA,LinearCoefficients,QuadraticCoefficients,
                                    aA.b-aA.g,((aB.b-aB.g)+aC.b)-aC.g,aD.b-aD.g,
                                    TimeExtrema[1],TimeExtrema[2],aSpan,aProtected) or
           HasDiagonalArtifactInner(aAMedian,DiagonalMedian,
                                    aA,LinearCoefficients,QuadraticCoefficients,
                                    aA.r-aA.b,((aB.r-aB.b)+aC.r)-aC.b,aD.r-aD.b,
                                    TimeExtrema[2],TimeExtrema[0],aSpan,aProtected);
  end else begin
   result:=false;
  end;
 end;

 function EdgeBetweenTexelsChannel(const aA,aB:TpvSignedDistanceField2DMSDFGenerator.TPixel;const aChannel:TpvSizeInt):boolean;
 var ChannelValueA,ChannelValueB,InterpolationTime:TpvDouble;
     InterpolatedChannels:array[0..2] of TpvDouble;
 begin
  ChannelValueA:=PixelChannel(aA,aChannel);
  ChannelValueB:=PixelChannel(aB,aChannel);
  if abs(ChannelValueA-ChannelValueB)>=1e-15 then begin
   InterpolationTime:=(ChannelValueA-0.5)/(ChannelValueA-ChannelValueB);
   if (InterpolationTime>0) and (InterpolationTime<1) then begin
    InterpolatedChannels[0]:=aA.r+InterpolationTime*(aB.r-aA.r);
    InterpolatedChannels[1]:=aA.g+InterpolationTime*(aB.g-aA.g);
    InterpolatedChannels[2]:=aA.b+InterpolationTime*(aB.b-aA.b);
    result:=TpvSignedDistanceField2DMSDFGenerator.Median(InterpolatedChannels[0],
                                                         InterpolatedChannels[1],
                                                         InterpolatedChannels[2])=InterpolatedChannels[aChannel];
   end else begin
    result:=false;
   end;
  end else begin
   result:=false;
  end;
 end;

 function EdgeBetweenTexels(const aA,aB:TpvSignedDistanceField2DMSDFGenerator.TPixel):TpvSizeInt; inline;
 begin
  result:=0;
  if EdgeBetweenTexelsChannel(aA,aB,0) then begin
   inc(result,1);
  end;
  if EdgeBetweenTexelsChannel(aA,aB,1) then begin
   inc(result,2);
  end;
  if EdgeBetweenTexelsChannel(aA,aB,2) then begin
   inc(result,4);
  end;
 end;

 procedure ProtectExtremeChannels(const aStencil:PpvUInt8;const aMSD:TpvSignedDistanceField2DMSDFGenerator.TPixel;const aMedian:TpvDouble;const aMask:TpvSizeInt); inline;
 begin
  if ((aMask and 1)<>0) and (aMSD.r<>aMedian) then begin
   aStencil^:=aStencil^ or STENCIL_PROTECTED;
   exit;
  end;
  if ((aMask and 2)<>0) and (aMSD.g<>aMedian) then begin
   aStencil^:=aStencil^ or STENCIL_PROTECTED;
   exit;
  end;
  if ((aMask and 4)<>0) and (aMSD.b<>aMedian) then begin
   aStencil^:=aStencil^ or STENCIL_PROTECTED;
  end;
 end;

begin

 if (aImage.Width>0) and (aImage.Height>0) then begin

  if abs(aScale.x)>1e-15 then begin
   InverseScaleX:=1.0/abs(aScale.x);
  end else begin
   InverseScaleX:=1.0;
  end;
  if abs(aScale.y)>1e-15 then begin
   InverseScaleY:=1.0/abs(aScale.y);
  end else begin
   InverseScaleY:=1.0;
  end;
  DistanceMappingDelta:=1.0/aRange;
  HorizontalSpan:=MIN_DEVIATION_RATIO*DistanceMappingDelta*InverseScaleX;
  VerticalSpan:=MIN_DEVIATION_RATIO*DistanceMappingDelta*InverseScaleY;
  DiagonalSpan:=MIN_DEVIATION_RATIO*DistanceMappingDelta*Sqrt(sqr(InverseScaleX)+sqr(InverseScaleY));
  HorizontalProtectionRadius:=PROTECTION_RADIUS_TOLERANCE*DistanceMappingDelta*InverseScaleX;
  VerticalProtectionRadius:=PROTECTION_RADIUS_TOLERANCE*DistanceMappingDelta*InverseScaleY;
  DiagonalProtectionRadius:=PROTECTION_RADIUS_TOLERANCE*DistanceMappingDelta*Sqrt(sqr(InverseScaleX)+sqr(InverseScaleY));

  SetLength(Stencil,aImage.Width*aImage.Height);
  FillChar(Stencil[0],length(Stencil)*SizeOf(TpvUInt8),0);

  // ProtectCorners
  for ContourIndex:=0 to aShape.Count-1 do begin
   Contour:=@aShape.Contours[ContourIndex];
   if Contour^.Count>0 then begin
    PreviousEdge:=@Contour^.Edges[Contour^.Count-1];
    for EdgeIndex:=0 to Contour^.Count-1 do begin
     Edge:=@Contour^.Edges[EdgeIndex];
     CommonColor:=TpvSizeInt(PreviousEdge^.Color) and TpvSizeInt(Edge^.Color);
     if (CommonColor and (CommonColor-1))=0 then begin
      CornerPoint:=Edge^.Points[0];
      CornerPoint.x:=CornerPoint.x*aScale.x+aTranslate.x;
      CornerPoint.y:=CornerPoint.y*aScale.y+aTranslate.y;
      CornerX:=TpvSizeInt(Floor(CornerPoint.x-0.5));
      CornerY:=TpvSizeInt(Floor(CornerPoint.y-0.5));
      CornerEndX:=CornerX+1;
      CornerEndY:=CornerY+1;
      if (CornerX>=0) and (CornerY>=0) and (CornerX<aImage.Width) and (CornerY<aImage.Height) then begin
       Stencil[CornerY*aImage.Width+CornerX]:=Stencil[CornerY*aImage.Width+CornerX] or STENCIL_PROTECTED;
      end;
      if (CornerEndX>=0) and (CornerY>=0) and (CornerEndX<aImage.Width) and (CornerY<aImage.Height) then begin
       Stencil[CornerY*aImage.Width+CornerEndX]:=Stencil[CornerY*aImage.Width+CornerEndX] or STENCIL_PROTECTED;
      end;
      if (CornerX>=0) and (CornerEndY>=0) and (CornerX<aImage.Width) and (CornerEndY<aImage.Height) then begin
       Stencil[CornerEndY*aImage.Width+CornerX]:=Stencil[CornerEndY*aImage.Width+CornerX] or STENCIL_PROTECTED;
      end;
      if (CornerEndX>=0) and (CornerEndY>=0) and (CornerEndX<aImage.Width) and (CornerEndY<aImage.Height) then begin
       Stencil[CornerEndY*aImage.Width+CornerEndX]:=Stencil[CornerEndY*aImage.Width+CornerEndX] or STENCIL_PROTECTED;
      end;
     end;
     PreviousEdge:=Edge;
    end;
   end;
  end;

  // ProtectEdges: horizontal
  for Y:=0 to aImage.Height-1 do begin
   for X:=0 to aImage.Width-2 do begin
    PixelA:=@aImage.Pixels[(Y*aImage.Width)+X];
    PixelB:=@aImage.Pixels[(Y*aImage.Width)+(X+1)];
    MedianValueA:=TpvSignedDistanceField2DMSDFGenerator.Median(PixelA^.r,PixelA^.g,PixelA^.b);
    MedianValueB:=TpvSignedDistanceField2DMSDFGenerator.Median(PixelB^.r,PixelB^.g,PixelB^.b);
    if (abs(MedianValueA-0.5)+abs(MedianValueB-0.5))<HorizontalProtectionRadius then begin
     EdgeMask:=EdgeBetweenTexels(PixelA^,PixelB^);
     if EdgeMask<>0 then begin
      ProtectExtremeChannels(@Stencil[(Y*aImage.Width)+X],PixelA^,MedianValueA,EdgeMask);
      ProtectExtremeChannels(@Stencil[(Y*aImage.Width)+(X+1)],PixelB^,MedianValueB,EdgeMask);
     end;
    end;
   end;
  end;

  // ProtectEdges: vertical
  for Y:=0 to aImage.Height-2 do begin
   for X:=0 to aImage.Width-1 do begin
    PixelA:=@aImage.Pixels[(Y*aImage.Width)+X];
    PixelB:=@aImage.Pixels[((Y+1)*aImage.Width)+X];
    MedianValueA:=TpvSignedDistanceField2DMSDFGenerator.Median(PixelA^.r,PixelA^.g,PixelA^.b);
    MedianValueB:=TpvSignedDistanceField2DMSDFGenerator.Median(PixelB^.r,PixelB^.g,PixelB^.b);
    if (abs(MedianValueA-0.5)+abs(MedianValueB-0.5))<VerticalProtectionRadius then begin
     EdgeMask:=EdgeBetweenTexels(PixelA^,PixelB^);
     if EdgeMask<>0 then begin
      ProtectExtremeChannels(@Stencil[(Y*aImage.Width)+X],PixelA^,MedianValueA,EdgeMask);
      ProtectExtremeChannels(@Stencil[((Y+1)*aImage.Width)+X],PixelB^,MedianValueB,EdgeMask);
     end;
    end;
   end;
  end;

  // ProtectEdges: diagonal (\)
  for Y:=0 to aImage.Height-2 do begin
   for X:=0 to aImage.Width-2 do begin
    PixelA:=@aImage.Pixels[(Y*aImage.Width)+X];
    PixelB:=@aImage.Pixels[((Y+1)*aImage.Width)+(X+1)];
    MedianValueA:=TpvSignedDistanceField2DMSDFGenerator.Median(PixelA^.r,PixelA^.g,PixelA^.b);
    MedianValueB:=TpvSignedDistanceField2DMSDFGenerator.Median(PixelB^.r,PixelB^.g,PixelB^.b);
    if (abs(MedianValueA-0.5)+abs(MedianValueB-0.5))<DiagonalProtectionRadius then begin
     EdgeMask:=EdgeBetweenTexels(PixelA^,PixelB^);
     if EdgeMask<>0 then begin
      ProtectExtremeChannels(@Stencil[(Y*aImage.Width)+X],PixelA^,MedianValueA,EdgeMask);
      ProtectExtremeChannels(@Stencil[((Y+1)*aImage.Width)+(X+1)],PixelB^,MedianValueB,EdgeMask);
     end;
    end;
   end;
  end;

  // ProtectEdges: diagonal (/)
  for Y:=0 to aImage.Height-2 do begin
   for X:=1 to aImage.Width-1 do begin
    PixelA:=@aImage.Pixels[(Y*aImage.Width)+X];
    PixelB:=@aImage.Pixels[((Y+1)*aImage.Width)+(X-1)];
    MedianValueA:=TpvSignedDistanceField2DMSDFGenerator.Median(PixelA^.r,PixelA^.g,PixelA^.b);
    MedianValueB:=TpvSignedDistanceField2DMSDFGenerator.Median(PixelB^.r,PixelB^.g,PixelB^.b);
    if (abs(MedianValueA-0.5)+abs(MedianValueB-0.5))<DiagonalProtectionRadius then begin
     EdgeMask:=EdgeBetweenTexels(PixelA^,PixelB^);
     if EdgeMask<>0 then begin
      ProtectExtremeChannels(@Stencil[(Y*aImage.Width)+X],PixelA^,MedianValueA,EdgeMask);
      ProtectExtremeChannels(@Stencil[((Y+1)*aImage.Width)+(X-1)],PixelB^,MedianValueB,EdgeMask);
     end;
    end;
   end;
  end;

  // FindErrors
  for Y:=0 to aImage.Height-1 do begin
   for X:=0 to aImage.Width-1 do begin
    if (Stencil[(Y*aImage.Width)+X] and STENCIL_ERROR)=0 then begin
     PixelA:=@aImage.Pixels[(Y*aImage.Width)+X];
     CurrentMedian:=TpvSignedDistanceField2DMSDFGenerator.Median(PixelA^.r,PixelA^.g,PixelA^.b);
     if X>0 then begin
      PixelB:=@aImage.Pixels[(Y*aImage.Width)+(X-1)];
      if HasLinearArtifact(CurrentMedian,PixelA^,PixelB^,HorizontalSpan,
                           (Stencil[(Y*aImage.Width)+X] and STENCIL_PROTECTED)<>0) then begin
       Stencil[(Y*aImage.Width)+X]:=Stencil[(Y*aImage.Width)+X] or STENCIL_ERROR;
      end;
     end;
     if (Stencil[(Y*aImage.Width)+X] and STENCIL_ERROR)=0 then begin
      if X<aImage.Width-1 then begin
       PixelB:=@aImage.Pixels[(Y*aImage.Width)+(X+1)];
       if HasLinearArtifact(CurrentMedian,PixelA^,PixelB^,HorizontalSpan,
                            (Stencil[(Y*aImage.Width)+X] and STENCIL_PROTECTED)<>0) then begin
        Stencil[(Y*aImage.Width)+X]:=Stencil[(Y*aImage.Width)+X] or STENCIL_ERROR;
       end;
      end;
     end;
     if (Stencil[(Y*aImage.Width)+X] and STENCIL_ERROR)=0 then begin
      if Y>0 then begin
       PixelB:=@aImage.Pixels[((Y-1)*aImage.Width)+X];
       if HasLinearArtifact(CurrentMedian,PixelA^,PixelB^,VerticalSpan,
                            (Stencil[(Y*aImage.Width)+X] and STENCIL_PROTECTED)<>0) then begin
        Stencil[(Y*aImage.Width)+X]:=Stencil[(Y*aImage.Width)+X] or STENCIL_ERROR;
       end;
      end;
     end;
     if (Stencil[(Y*aImage.Width)+X] and STENCIL_ERROR)=0 then begin
      if Y<aImage.Height-1 then begin
       PixelB:=@aImage.Pixels[((Y+1)*aImage.Width)+X];
       if HasLinearArtifact(CurrentMedian,PixelA^,PixelB^,VerticalSpan,
                            (Stencil[(Y*aImage.Width)+X] and STENCIL_PROTECTED)<>0) then begin
        Stencil[(Y*aImage.Width)+X]:=Stencil[(Y*aImage.Width)+X] or STENCIL_ERROR;
       end;
      end;
     end;
     if (Stencil[(Y*aImage.Width)+X] and STENCIL_ERROR)=0 then begin
      if (X>0) and (Y>0) then begin
       if HasDiagonalArtifact(CurrentMedian,
                              aImage.Pixels[(Y*aImage.Width)+X],
                              aImage.Pixels[(Y*aImage.Width)+(X-1)],
                              aImage.Pixels[((Y-1)*aImage.Width)+X],
                              aImage.Pixels[((Y-1)*aImage.Width)+(X-1)],
                              DiagonalSpan,
                              (Stencil[(Y*aImage.Width)+X] and STENCIL_PROTECTED)<>0) then begin
        Stencil[(Y*aImage.Width)+X]:=Stencil[(Y*aImage.Width)+X] or STENCIL_ERROR;
       end;
      end;
     end;
     if (Stencil[(Y*aImage.Width)+X] and STENCIL_ERROR)=0 then begin
      if (X<aImage.Width-1) and (Y>0) then begin
       if HasDiagonalArtifact(CurrentMedian,
                              aImage.Pixels[(Y*aImage.Width)+X],
                              aImage.Pixels[(Y*aImage.Width)+(X+1)],
                              aImage.Pixels[((Y-1)*aImage.Width)+X],
                              aImage.Pixels[((Y-1)*aImage.Width)+(X+1)],
                              DiagonalSpan,
                              (Stencil[(Y*aImage.Width)+X] and STENCIL_PROTECTED)<>0) then begin
        Stencil[(Y*aImage.Width)+X]:=Stencil[(Y*aImage.Width)+X] or STENCIL_ERROR;
       end;
      end;
     end;
     if (Stencil[(Y*aImage.Width)+X] and STENCIL_ERROR)=0 then begin
      if (X>0) and (Y<aImage.Height-1) then begin
       if HasDiagonalArtifact(CurrentMedian,
                              aImage.Pixels[(Y*aImage.Width)+X],
                              aImage.Pixels[(Y*aImage.Width)+(X-1)],
                              aImage.Pixels[((Y+1)*aImage.Width)+X],
                              aImage.Pixels[((Y+1)*aImage.Width)+(X-1)],
                              DiagonalSpan,
                              (Stencil[(Y*aImage.Width)+X] and STENCIL_PROTECTED)<>0) then begin
        Stencil[(Y*aImage.Width)+X]:=Stencil[(Y*aImage.Width)+X] or STENCIL_ERROR;
       end;
      end;
     end;
     if (Stencil[(Y*aImage.Width)+X] and STENCIL_ERROR)=0 then begin
      if (X<aImage.Width-1) and (Y<aImage.Height-1) then begin
       if HasDiagonalArtifact(CurrentMedian,
                              aImage.Pixels[(Y*aImage.Width)+X],
                              aImage.Pixels[(Y*aImage.Width)+(X+1)],
                              aImage.Pixels[((Y+1)*aImage.Width)+X],
                              aImage.Pixels[((Y+1)*aImage.Width)+(X+1)],
                              DiagonalSpan,
                              (Stencil[(Y*aImage.Width)+X] and STENCIL_PROTECTED)<>0) then begin
        Stencil[(Y*aImage.Width)+X]:=Stencil[(Y*aImage.Width)+X] or STENCIL_ERROR;
       end;
      end;
     end;
    end;
   end;
  end;

  // Apply
  for Y:=0 to aImage.Height-1 do begin
   for X:=0 to aImage.Width-1 do begin
    if (Stencil[(Y*aImage.Width)+X] and STENCIL_ERROR)<>0 then begin
     Pixel:=@aImage.Pixels[(Y*aImage.Width)+X];
     MedianValue:=TpvSignedDistanceField2DMSDFGenerator.Median(Pixel^.r,Pixel^.g,Pixel^.b);
     Pixel^.r:=MedianValue;
     Pixel^.g:=MedianValue;
     Pixel^.b:=MedianValue;
    end;
   end;
  end;

  Stencil:=nil;

 end;

end;

{ TpvSignedDistanceField2DGenerator }

constructor TpvSignedDistanceField2DGenerator.Create;
begin
 inherited Create;
 fPointInPolygonPathSegments:=nil;
 fVectorPathShape:=nil;
 fDistanceField:=nil;
 fVariant:=TpvSignedDistanceField2DVariant.Default;
end;

destructor TpvSignedDistanceField2DGenerator.Destroy;
begin
 fPointInPolygonPathSegments:=nil;
 fVectorPathShape:=nil;
 fDistanceField:=nil;
 inherited Destroy;
end;

function TpvSignedDistanceField2DGenerator.Clamp(const Value,MinValue,MaxValue:TpvInt64):TpvInt64;
begin
 if Value<=MinValue then begin
  result:=MinValue;
 end else if Value>=MaxValue then begin
  result:=MaxValue;
 end else begin
  result:=Value;
 end;
end;

function TpvSignedDistanceField2DGenerator.Clamp(const Value,MinValue,MaxValue:TpvDouble):TpvDouble;
begin
 if Value<=MinValue then begin
  result:=MinValue;
 end else if Value>=MaxValue then begin
  result:=MaxValue;
 end else begin
  result:=Value;
 end;
end;

function TpvSignedDistanceField2DGenerator.VectorMap(const p:TpvVectorPathVector;const m:TpvSignedDistanceField2DDoublePrecisionAffineMatrix):TpvVectorPathVector;
begin
 result.x:=(p.x*m[0])+(p.y*m[1])+m[2];
 result.y:=(p.x*m[3])+(p.y*m[4])+m[5];
end;

procedure TpvSignedDistanceField2DGenerator.GetOffset(out oX,oY:TpvDouble);
begin
 case fVariant of
  TpvSignedDistanceField2DVariant.GSDF:begin
   case fColorChannelIndex of
    1:begin
     oX:=1.0;
     oY:=0.0;
    end;
    2:begin
     oX:=0.0;
     oY:=1.0;
    end;
    else {0:}begin
     oX:=0.0;
     oY:=0.0;
    end;
   end;
  end;
  TpvSignedDistanceField2DVariant.SSAASDF:begin
   case fColorChannelIndex of
    0:begin
     oX:=0.125;
     oY:=0.375;
    end;
    1:begin
     oX:=-0.125;
     oY:=-0.375;
    end;
    2:begin
     oX:=0.375;
     oY:=-0.125;
    end;
    else {3:}begin
     oX:=-0.375;
     oY:=0.125;
    end;
   end;
  end;
  else begin
   oX:=0.0;
   oY:=0.0;
  end;
 end;
end;

procedure TpvSignedDistanceField2DGenerator.ApplyOffset(var aX,aY:TpvDouble);
var oX,oY:TpvDouble;
begin
 GetOffset(oX,oY);
 aX:=aX+oX;
 aY:=aY+oY;
end;

function TpvSignedDistanceField2DGenerator.ApplyOffset(const aPoint:TpvVectorPathVector):TpvVectorPathVector;
var oX,oY:TpvDouble;
begin
 GetOffset(oX,oY);
 result.x:=aPoint.x+oX;
 result.y:=aPoint.y+oY;
end;

function TpvSignedDistanceField2DGenerator.BetweenClosedOpen(const a,b,c:TpvDouble;const Tolerance:TpvDouble=0.0;const XFormToleranceToX:boolean=false):boolean;
var ToleranceB,ToleranceC:TpvDouble;
begin
 Assert(Tolerance>=0.0);
 if XFormToleranceToX then begin
  ToleranceB:=Tolerance/sqrt((sqr(b)*4.0)+1.0);
  ToleranceC:=Tolerance/sqrt((sqr(c)*4.0)+1.0);
 end else begin
  ToleranceB:=Tolerance;
  ToleranceC:=Tolerance;
 end;
 if b<c then begin
  result:=(a>=(b-ToleranceB)) and (a<(c-ToleranceC));
 end else begin
  result:=(a>=(c-ToleranceC)) and (a<(b-ToleranceB));
 end;
end;

function TpvSignedDistanceField2DGenerator.BetweenClosed(const a,b,c:TpvDouble;const Tolerance:TpvDouble=0.0;const XFormToleranceToX:boolean=false):boolean;
var ToleranceB,ToleranceC:TpvDouble;
begin
 Assert(Tolerance>=0.0);
 if XFormToleranceToX then begin
  ToleranceB:=Tolerance/sqrt((sqr(b)*4.0)+1.0);
  ToleranceC:=Tolerance/sqrt((sqr(c)*4.0)+1.0);
 end else begin
  ToleranceB:=Tolerance;
  ToleranceC:=Tolerance;
 end;
 if b<c then begin
  result:=(a>=(b-ToleranceB)) and (a<=(c+ToleranceC));
 end else begin
  result:=(a>=(c-ToleranceC)) and (a<=(b+ToleranceB));
 end;
end;

function TpvSignedDistanceField2DGenerator.NearlyZero(const Value:TpvDouble;const Tolerance:TpvDouble=DistanceField2DNearlyZeroValue):boolean;
begin
 Assert(Tolerance>=0.0);
 result:=abs(Value)<=Tolerance;
end;

function TpvSignedDistanceField2DGenerator.NearlyEqual(const x,y:TpvDouble;const Tolerance:TpvDouble=DistanceField2DNearlyZeroValue;const XFormToleranceToX:boolean=false):boolean;
begin
 Assert(Tolerance>=0.0);
 if XFormToleranceToX then begin
  result:=abs(x-y)<=(Tolerance/sqrt((sqr(y)*4.0)+1.0));
 end else begin
  result:=abs(x-y)<=Tolerance;
 end;
end;

function TpvSignedDistanceField2DGenerator.SignOf(const Value:TpvDouble):TpvInt32;
begin
 if Value<0.0 then begin
  result:=-1;
 end else begin
  result:=1;
 end;
end;

function TpvSignedDistanceField2DGenerator.IsColinear(const Points:array of TpvVectorPathVector):boolean;
begin
 Assert(length(Points)=3);
 result:=abs(((Points[1].y-Points[0].y)*(Points[1].x-Points[2].x))-
             ((Points[1].y-Points[2].y)*(Points[1].x-Points[0].x)))<=DistanceField2DCloseSquaredValue;
end;

function TpvSignedDistanceField2DGenerator.PathSegmentDirection(const PathSegment:TpvSignedDistanceField2DPathSegment;const Which:TpvInt32):TpvVectorPathVector;
begin
 case PathSegment.Type_ of
  TpvSignedDistanceField2DPathSegmentType.Line:begin
   result.x:=PathSegment.Points[1].x-PathSegment.Points[0].x;
   result.y:=PathSegment.Points[1].y-PathSegment.Points[0].y;
  end;
  TpvSignedDistanceField2DPathSegmentType.QuadraticBezierCurve:begin
   case Which of
    0:begin
     result.x:=PathSegment.Points[1].x-PathSegment.Points[0].x;
     result.y:=PathSegment.Points[1].y-PathSegment.Points[0].y;
    end;
    1:begin
     result.x:=PathSegment.Points[2].x-PathSegment.Points[1].x;
     result.y:=PathSegment.Points[2].y-PathSegment.Points[1].y;
    end;
    else begin
     result.x:=0.0;
     result.y:=0.0;
     Assert(false);
    end;
   end;
  end;
  else begin
   result.x:=0.0;
   result.y:=0.0;
   Assert(false);
  end;
 end;
end;

function TpvSignedDistanceField2DGenerator.PathSegmentCountPoints(const PathSegment:TpvSignedDistanceField2DPathSegment):TpvInt32;
begin
 case PathSegment.Type_ of
  TpvSignedDistanceField2DPathSegmentType.Line:begin
   result:=2;
  end;
  TpvSignedDistanceField2DPathSegmentType.QuadraticBezierCurve:begin
   result:=3;
  end;
  else begin
   result:=0;
   Assert(false);
  end;
 end;
end;

function TpvSignedDistanceField2DGenerator.PathSegmentEndPoint(const PathSegment:TpvSignedDistanceField2DPathSegment):PpvVectorPathVector;
begin
 case PathSegment.Type_ of
  TpvSignedDistanceField2DPathSegmentType.Line:begin
   result:=@PathSegment.Points[1];
  end;
  TpvSignedDistanceField2DPathSegmentType.QuadraticBezierCurve:begin
   result:=@PathSegment.Points[2];
  end;
  else begin
   result:=nil;
   Assert(false);
  end;
 end;
end;

function TpvSignedDistanceField2DGenerator.PathSegmentCornerPoint(const PathSegment:TpvSignedDistanceField2DPathSegment;const WhichA,WhichB:TpvInt32):PpvVectorPathVector;
begin
 case PathSegment.Type_ of
  TpvSignedDistanceField2DPathSegmentType.Line:begin
   result:=@PathSegment.Points[WhichB and 1];
  end;
  TpvSignedDistanceField2DPathSegmentType.QuadraticBezierCurve:begin
   result:=@PathSegment.Points[(WhichA and 1)+(WhichB and 1)];
  end;
  else begin
   result:=nil;
   Assert(false);
  end;
 end;
end;

procedure TpvSignedDistanceField2DGenerator.InitializePathSegment(var PathSegment:TpvSignedDistanceField2DPathSegment);
var p0,p1,p2,p1mp0,d,t,sp0,sp1,sp2,p01p,p02p,p12p:TpvVectorPathVector;
    Hypotenuse,CosTheta,SinTheta,a,b,h,c,g,f,gd,fd,x,y,Lambda:TpvDouble;
begin
 case PathSegment.Type_ of
  TpvSignedDistanceField2DPathSegmentType.Line:begin
   p0:=PathSegment.Points[0];
   p2:=PathSegment.Points[1];
   PathSegment.BoundingBox.Min.x:=Min(p0.x,p2.x);
   PathSegment.BoundingBox.Min.y:=Min(p0.y,p2.y);
   PathSegment.BoundingBox.Max.x:=Max(p0.x,p2.x);
   PathSegment.BoundingBox.Max.y:=Max(p0.y,p2.y);
   PathSegment.ScalingFactor:=1.0;
   PathSegment.SquaredScalingFactor:=1.0;
   Hypotenuse:=p0.Distance(p2);
   CosTheta:=(p2.x-p0.x)/Hypotenuse;
   SinTheta:=(p2.y-p0.y)/Hypotenuse;
   PathSegment.XFormMatrix[0]:=CosTheta;
   PathSegment.XFormMatrix[1]:=SinTheta;
   PathSegment.XFormMatrix[2]:=(-(CosTheta*p0.x))-(SinTheta*p0.y);
   PathSegment.XFormMatrix[3]:=-SinTheta;
   PathSegment.XFormMatrix[4]:=CosTheta;
   PathSegment.XFormMatrix[5]:=(SinTheta*p0.x)-(CosTheta*p0.y);
  end;
  else {pstQuad:}begin
   p0:=PathSegment.Points[0];
   p1:=PathSegment.Points[1];
   p2:=PathSegment.Points[2];
   PathSegment.BoundingBox.Min.x:=Min(p0.x,p2.x);
   PathSegment.BoundingBox.Min.y:=Min(p0.y,p2.y);
   PathSegment.BoundingBox.Max.x:=Max(p0.x,p2.x);
   PathSegment.BoundingBox.Max.y:=Max(p0.y,p2.y);
   p1mp0.x:=p1.x-p0.x;
   p1mp0.y:=p1.y-p0.y;
   d.x:=(p1mp0.x-p2.x)+p1.x;
   d.y:=(p1mp0.y-p2.y)+p1.y;
   if IsZero(d.x) then begin
    t.x:=p0.x;
   end else begin
    t.x:=p0.x+(Clamp(p1mp0.x/d.x,0.0,1.0)*p1mp0.x);
   end;
   if IsZero(d.y) then begin
    t.y:=p0.y;
   end else begin
    t.y:=p0.y+(Clamp(p1mp0.y/d.y,0.0,1.0)*p1mp0.y);
   end;
   PathSegment.BoundingBox.Min.x:=Min(PathSegment.BoundingBox.Min.x,t.x);
   PathSegment.BoundingBox.Min.y:=Min(PathSegment.BoundingBox.Min.y,t.y);
   PathSegment.BoundingBox.Max.x:=Max(PathSegment.BoundingBox.Max.x,t.x);
   PathSegment.BoundingBox.Max.y:=Max(PathSegment.BoundingBox.Max.y,t.y);
   sp0.x:=sqr(p0.x);
   sp0.y:=sqr(p0.y);
   sp1.x:=sqr(p1.x);
   sp1.y:=sqr(p1.y);
   sp2.x:=sqr(p2.x);
   sp2.y:=sqr(p2.y);
   p01p.x:=p0.x*p1.x;
   p01p.y:=p0.y*p1.y;
   p02p.x:=p0.x*p2.x;
   p02p.y:=p0.y*p2.y;
   p12p.x:=p1.x*p2.x;
   p12p.y:=p1.y*p2.y;
   a:=sqr((p0.y-(2.0*p1.y))+p2.y);
   h:=-(((p0.y-(2.0*p1.y))+p2.y)*((p0.x-(2.0*p1.x))+p2.x));
   b:=sqr((p0.x-(2.0*p1.x))+p2.x);
   c:=((((((sp0.x*sp2.y)-(4.0*p01p.x*p12p.y))-(2.0*p02p.x*p02p.y))+(4.0*p02p.x*sp1.y))+(4.0*sp1.x*p02p.y))-(4.0*p12p.x*p01p.y))+(sp2.x*sp0.y);
   g:=((((((((((p0.x*p02p.y)-(2.0*p0.x*sp1.y))+(2.0*p0.x*p12p.y))-(p0.x*sp2.y))+(2.0*p1.x*p01p.y))-(4.0*p1.x*p02p.y))+(2.0*p1.x*p12p.y))-(p2.x*sp0.y))+(2.0*p2.x*p01p.y))+(p2.x*p02p.y))-(2.0*p2.x*sp1.y);
   f:=-(((((((((((sp0.x*p2.y)-(2.0*p01p.x*p1.y))-(2.0*p01p.x*p2.y))-(p02p.x*p0.y))+(4.0*p02p.x*p1.y))-(p02p.x*p2.y))+(2.0*sp1.x*p0.y))+(2.0*sp1.x*p2.y))-(2.0*p12p.x*p0.y))-(2.0*p12p.x*p1.y))+(sp2.x*p0.y));
   CosTheta:=sqrt(a/(a+b));
   SinTheta:=(-SignOf((a+b)*h))*sqrt(b/(a+b));
   gd:=(CosTheta*g)-(SinTheta*f);
   fd:=(SinTheta*g)+(CosTheta*f);
   x:=gd/(a+b);
   y:=(1.0/(2.0*fd))*(c-(sqr(gd)/(a+b)));
   Lambda:=-((a+b)/(2.0*fd));
   PathSegment.ScalingFactor:=abs(1.0/Lambda);
   PathSegment.SquaredScalingFactor:=sqr(PathSegment.ScalingFactor);
   CosTheta:=CosTheta*Lambda;
   SinTheta:=SinTheta*Lambda;
   PathSegment.XFormMatrix[0]:=CosTheta;
   PathSegment.XFormMatrix[1]:=-SinTheta;
   PathSegment.XFormMatrix[2]:=x*Lambda;
   PathSegment.XFormMatrix[3]:=SinTheta;
   PathSegment.XFormMatrix[4]:=CosTheta;
   PathSegment.XFormMatrix[5]:=y*Lambda;
  end;
 end;
 PathSegment.NearlyZeroScaled:=DistanceField2DNearlyZeroValue/PathSegment.ScalingFactor;
 PathSegment.SquaredTangentToleranceScaled:=sqr(DistanceField2DTangentToleranceValue)/PathSegment.SquaredScalingFactor;
 PathSegment.P0T:=VectorMap(p0,PathSegment.XFormMatrix);
 PathSegment.P2T:=VectorMap(p2,PathSegment.XFormMatrix);
end;

procedure TpvSignedDistanceField2DGenerator.InitializeDistances;
var Index:TpvInt32;
begin
 for Index:=0 to length(fDistanceFieldData)-1 do begin
  fDistanceFieldData[Index].SquaredDistance:=sqr(DistanceField2DMagnitudeValue);
  fDistanceFieldData[Index].Distance:=DistanceField2DMagnitudeValue;
  fDistanceFieldData[Index].DeltaWindingScore:=0;
 end;
end;

function TpvSignedDistanceField2DGenerator.AddLineToPathSegmentArray(var Contour:TpvSignedDistanceField2DPathContour;const Points:array of TpvVectorPathVector):TpvInt32;
var PathSegment:PpvSignedDistanceField2DPathSegment;
begin
 Assert(length(Points)=2);
 result:=Contour.CountPathSegments;
 if not (SameValue(Points[0].x,Points[1].x) and SameValue(Points[0].y,Points[1].y)) then begin
  inc(Contour.CountPathSegments);
  if length(Contour.PathSegments)<=Contour.CountPathSegments then begin
   SetLength(Contour.PathSegments,Contour.CountPathSegments*2);
  end;
  PathSegment:=@Contour.PathSegments[result];
  PathSegment^.Type_:=TpvSignedDistanceField2DPathSegmentType.Line;
  PathSegment^.Points[0]:=Points[0];
  PathSegment^.Points[1]:=Points[1];
  InitializePathSegment(PathSegment^);
 end;
end;

function TpvSignedDistanceField2DGenerator.AddQuadraticBezierCurveToPathSegmentArray(var Contour:TpvSignedDistanceField2DPathContour;const Points:array of TpvVectorPathVector):TpvInt32;
var PathSegment:PpvSignedDistanceField2DPathSegment;
begin
 Assert(length(Points)=3);
 result:=Contour.CountPathSegments;
 if (Points[0].DistanceSquared(Points[1])<DistanceField2DCloseSquaredValue) or
    (Points[1].DistanceSquared(Points[2])<DistanceField2DCloseSquaredValue) or
    IsColinear(Points) then begin
  if not (SameValue(Points[0].x,Points[2].x) and SameValue(Points[0].y,Points[2].y)) then begin
   inc(Contour.CountPathSegments);
   if length(Contour.PathSegments)<=Contour.CountPathSegments then begin
    SetLength(Contour.PathSegments,Contour.CountPathSegments*2);
   end;
   PathSegment:=@Contour.PathSegments[result];
   PathSegment^.Type_:=TpvSignedDistanceField2DPathSegmentType.Line;
   PathSegment^.Points[0]:=Points[0];
   PathSegment^.Points[1]:=Points[2];
   InitializePathSegment(PathSegment^);
  end;
 end else begin
  inc(Contour.CountPathSegments);
  if length(Contour.PathSegments)<=Contour.CountPathSegments then begin
   SetLength(Contour.PathSegments,Contour.CountPathSegments*2);
  end;
  PathSegment:=@Contour.PathSegments[result];
  PathSegment^.Type_:=TpvSignedDistanceField2DPathSegmentType.QuadraticBezierCurve;
  PathSegment^.Points[0]:=Points[0];
  PathSegment^.Points[1]:=Points[1];
  PathSegment^.Points[2]:=Points[2];
  InitializePathSegment(PathSegment^);
 end;
end;

function TpvSignedDistanceField2DGenerator.CubeRoot(Value:TpvDouble):TpvDouble;
begin
 if IsZero(Value) then begin
  result:=0.0;
 end else begin
  result:=exp(ln(abs(Value))/3.0);
  if Value<0.0 then begin
   result:=-result;
  end;
 end;
end;

function TpvSignedDistanceField2DGenerator.CalculateNearestPointForQuadraticBezierCurve(const PathSegment:TpvSignedDistanceField2DPathSegment;const XFormPoint:TpvVectorPathVector):TpvDouble;
const OneDiv3=1.0/3.0;
      OneDiv27=1.0/27.0;
var a,b,a3,b2,c,SqrtC,CosPhi,Phi:TpvDouble;
begin
 a:=0.5-XFormPoint.y;
 b:=(-0.5)*XFormPoint.x;
 a3:=sqr(a)*a;
 b2:=sqr(b);
 c:=(b2*0.25)+(a3*OneDiv27);
 if c>=0.0 then begin
  SqrtC:=sqrt(c);
  b:=b*(-0.5);
  result:=CubeRoot(b+SqrtC)+CubeRoot(b-SqrtC);
 end else begin
  CosPhi:=sqrt((b2*0.25)*((-27.0)/a3));
  if b>0.0 then begin
   CosPhi:=-CosPhi;
  end;
  Phi:=ArcCos(CosPhi);
  if XFormPoint.x>0.0 then begin
   result:=2.0*sqrt(a*(-OneDiv3))*cos(Phi*OneDiv3);
   if not BetweenClosed(result,PathSegment.P0T.x,PathSegment.P2T.x) then begin
    result:=2.0*sqrt(a*(-OneDiv3))*cos((Phi*OneDiv3)+(pi*2.0*OneDiv3));
   end;
  end else begin
   result:=2.0*sqrt(a*(-OneDiv3))*cos((Phi*OneDiv3)+(pi*2.0*OneDiv3));
   if not BetweenClosed(result,PathSegment.P0T.x,PathSegment.P2T.x) then begin
    result:=2.0*sqrt(a*(-OneDiv3))*cos(Phi*OneDiv3);
   end;
  end;
 end;
end;

procedure TpvSignedDistanceField2DGenerator.PrecomputationForRow(out RowData:TpvSignedDistanceField2DRowData;const PathSegment:TpvSignedDistanceField2DPathSegment;const PointLeft,PointRight:TpvVectorPathVector);
var XFormPointLeft,XFormPointRight:TpvVectorPathVector;
    x0,y0,x1,y1,m,b,m2,c,Tolerance,d:TpvDouble;
begin
 if PathSegment.Type_=TpvSignedDistanceField2DPathSegmentType.QuadraticBezierCurve then begin
  XFormPointLeft:=VectorMap(PointLeft,PathSegment.XFormMatrix);
  XFormPointRight:=VectorMap(PointRight,PathSegment.XFormMatrix);
  RowData.QuadraticXDirection:=SignOf(PathSegment.P2T.x-PathSegment.P0T.x);
  RowData.ScanlineXDirection:=SignOf(XFormPointRight.x-XFormPointLeft.x);
  x0:=XFormPointLeft.x;
  y0:=XFormPointLeft.y;
  x1:=XFormPointRight.x;
  y1:=XFormPointRight.y;
  if NearlyEqual(x0,x1,PathSegment.NearlyZeroScaled,true) then begin
   RowData.IntersectionType:=TpvSignedDistanceField2DRowDataIntersectionType.VerticalLine;
   RowData.YAtIntersection:=sqr(x0);
   RowData.ScanlineXDirection:=0;
  end else begin
   m:=(y1-y0)/(x1-x0);
   b:=y0-(m*x0);
   m2:=sqr(m);
   c:=m2+(4.0*b);
   Tolerance:=(4.0*PathSegment.SquaredTangentToleranceScaled)/(m2+1.0);
   if (RowData.ScanlineXDirection=1) and
      (SameValue(PathSegment.Points[0].y,PointLeft.y) or
       SameValue(PathSegment.Points[2].y,PointLeft.y)) and
       NearlyZero(c,Tolerance) then begin
    RowData.IntersectionType:=TpvSignedDistanceField2DRowDataIntersectionType.TangentLine;
    RowData.XAtIntersection[0]:=m*0.5;
    RowData.XAtIntersection[1]:=m*0.5;
   end else if c<=0.0 then begin
    RowData.IntersectionType:=TpvSignedDistanceField2DRowDataIntersectionType.NoIntersection;
   end else begin
    RowData.IntersectionType:=TpvSignedDistanceField2DRowDataIntersectionType.TwoPointsIntersect;
    d:=sqrt(c);
    RowData.XAtIntersection[0]:=(m+d)*0.5;
    RowData.XAtIntersection[1]:=(m-d)*0.5;
   end;
  end;
 end;
end;

function TpvSignedDistanceField2DGenerator.CalculateSideOfQuadraticBezierCurve(const PathSegment:TpvSignedDistanceField2DPathSegment;const Point,XFormPoint:TpvVectorPathVector;const RowData:TpvSignedDistanceField2DRowData):TpvSignedDistanceField2DPathSegmentSide;
var p0,p1:TpvDouble;
    sp0,sp1:TpvInt32;
    ip0,ip1:boolean;
begin
 case RowData.IntersectionType of
  TpvSignedDistanceField2DRowDataIntersectionType.VerticalLine:begin
   result:=TpvSignedDistanceField2DPathSegmentSide(TpvInt32(SignOf(XFormPoint.y-RowData.YAtIntersection)*RowData.QuadraticXDirection));
  end;
  TpvSignedDistanceField2DRowDataIntersectionType.TwoPointsIntersect:begin
   result:=TpvSignedDistanceField2DPathSegmentSide.None;
   p0:=RowData.XAtIntersection[0];
   p1:=RowData.XAtIntersection[1];
   sp0:=SignOf(p0-XFormPoint.x);
   ip0:=true;
   ip1:=true;
   if RowData.ScanlineXDirection=1 then begin
    if ((RowData.QuadraticXDirection=-1) and
        (PathSegment.Points[0].y<=Point.y) and
        NearlyEqual(PathSegment.P0T.x,p0,PathSegment.NearlyZeroScaled,true)) or
       ((RowData.QuadraticXDirection=1) and
        (PathSegment.Points[2].y<=Point.y) and
        NearlyEqual(PathSegment.P2T.x,p0,PathSegment.NearlyZeroScaled,true)) then begin
     ip0:=false;
    end;
    if ((RowData.QuadraticXDirection=-1) and
        (PathSegment.Points[2].y<=Point.y) and
        NearlyEqual(PathSegment.P2T.x,p1,PathSegment.NearlyZeroScaled,true)) or
       ((RowData.QuadraticXDirection=1) and
        (PathSegment.Points[0].y<=Point.y) and
        NearlyEqual(PathSegment.P0T.x,p1,PathSegment.NearlyZeroScaled,true)) then begin
     ip1:=false;
    end;
   end;
   if ip0 and BetweenClosed(p0,PathSegment.P0T.x,PathSegment.P2T.x,PathSegment.NearlyZeroScaled,true) then begin
    result:=TpvSignedDistanceField2DPathSegmentSide(TpvInt32(sp0*RowData.QuadraticXDirection));
   end;
   if ip1 and BetweenClosed(p1,PathSegment.P0T.x,PathSegment.P2T.x,PathSegment.NearlyZeroScaled,true) then begin
    sp1:=SignOf(p1-XFormPoint.x);
    if (result=TpvSignedDistanceField2DPathSegmentSide.None) or (sp1=1) then begin
     result:=TpvSignedDistanceField2DPathSegmentSide(TpvInt32(-sp1*RowData.QuadraticXDirection));
    end;
   end;
  end;
  TpvSignedDistanceField2DRowDataIntersectionType.TangentLine:begin
   result:=TpvSignedDistanceField2DPathSegmentSide.None;
   if RowData.ScanlineXDirection=1 then begin
    if SameValue(PathSegment.Points[0].y,Point.y) then begin
     result:=TpvSignedDistanceField2DPathSegmentSide(TpvInt32(SignOf(RowData.XAtIntersection[0]-XFormPoint.x)));
    end else if SameValue(PathSegment.Points[2].y,Point.y) then begin
     result:=TpvSignedDistanceField2DPathSegmentSide(TpvInt32(SignOf(XFormPoint.x-RowData.XAtIntersection[0])));
    end;
   end;
  end;
  else begin
   result:=TpvSignedDistanceField2DPathSegmentSide.None;
  end;
 end;
end;

function TpvSignedDistanceField2DGenerator.DistanceToPathSegment(const Point:TpvVectorPathVector;const PathSegment:TpvSignedDistanceField2DPathSegment;const RowData:TpvSignedDistanceField2DRowData;out PathSegmentSide:TpvSignedDistanceField2DPathSegmentSide):TpvDouble;
var XFormPoint,x:TpvVectorPathVector;
    NearestPoint:TpvDouble;
begin
 XFormPoint:=VectorMap(Point,PathSegment.XFormMatrix);
 case PathSegment.Type_ of
  TpvSignedDistanceField2DPathSegmentType.Line:begin
   if BetweenClosed(XFormPoint.x,PathSegment.P0T.x,PathSegment.P2T.x) then begin
    result:=sqr(XFormPoint.y);
   end else if XFormPoint.x<PathSegment.P0T.x then begin
    result:=sqr(XFormPoint.x)+sqr(XFormPoint.y);
   end else begin
    result:=sqr(XFormPoint.x-PathSegment.P2T.x)+sqr(XFormPoint.y);
   end;
   if BetweenClosedOpen(Point.y,PathSegment.BoundingBox.Min.y,PathSegment.BoundingBox.Max.y) then begin
    PathSegmentSide:=TpvSignedDistanceField2DPathSegmentSide(TpvInt32(SignOf(XFormPoint.y)));
   end else begin
    PathSegmentSide:=TpvSignedDistanceField2DPathSegmentSide.None;
   end;
  end;
  TpvSignedDistanceField2DPathSegmentType.QuadraticBezierCurve:begin
   NearestPoint:=CalculateNearestPointForQuadraticBezierCurve(PathSegment,XFormPoint);
   if BetweenClosed(NearestPoint,PathSegment.P0T.x,PathSegment.P2T.x) then begin
    x.x:=NearestPoint;
    x.y:=sqr(NearestPoint);
    result:=XFormPoint.DistanceSquared(x)*PathSegment.SquaredScalingFactor;
   end else begin
    result:=Min(XFormPoint.DistanceSquared(PathSegment.P0T),XFormPoint.DistanceSquared(PathSegment.P2T))*PathSegment.SquaredScalingFactor;
   end;
   if BetweenClosedOpen(Point.y,PathSegment.BoundingBox.Min.y,PathSegment.BoundingBox.Max.y) then begin
    PathSegmentSide:=CalculateSideOfQuadraticBezierCurve(PathSegment,Point,XFormPoint,RowData);
   end else begin
    PathSegmentSide:=TpvSignedDistanceField2DPathSegmentSide.None;
   end;
  end;
  else begin
   PathSegmentSide:=TpvSignedDistanceField2DPathSegmentSide.None;
   result:=0.0;
  end;
 end;
end;

procedure TpvSignedDistanceField2DGenerator.ConvertShape(const DoSubdivideCurvesIntoLines:boolean);
var LocalVectorPathShape:TpvVectorPathShape;
    LocalVectorPathContour:TpvVectorPathContour;
    LocalVectorPathSegment:TpvVectorPathSegment;
    Contour:PpvSignedDistanceField2DPathContour;
    Scale,Translate:TpvVectorPathVector;
begin
 Scale:=TpvVectorPathVector.Create(fScale*DistanceField2DRasterizerToScreenScale);
 Translate:=TpvVectorPathVector.Create(fOffsetX,fOffsetY);
 LocalVectorPathShape:=TpvVectorPathShape.Create(fVectorPathShape);
 try
  if DoSubdivideCurvesIntoLines then begin
   LocalVectorPathShape.ConvertCurvesToLines;
  end else begin
   LocalVectorPathShape.ConvertCubicCurvesToQuadraticCurves;
  end;
  fShape.Contours:=nil;
  fShape.CountContours:=0;
  try
   for LocalVectorPathContour in LocalVectorPathShape.Contours do begin
    if length(fShape.Contours)<(fShape.CountContours+1) then begin
     SetLength(fShape.Contours,(fShape.CountContours+1)*2);
    end;
    Contour:=@fShape.Contours[fShape.CountContours];
    inc(fShape.CountContours);
    try
     for LocalVectorPathSegment in LocalVectorPathContour.Segments do begin
      case LocalVectorPathSegment.Type_ of
       TpvVectorPathSegmentType.Line:begin
        AddLineToPathSegmentArray(Contour^,[(TpvVectorPathSegmentLine(LocalVectorPathSegment).Points[0]*Scale)+Translate,
                                            (TpvVectorPathSegmentLine(LocalVectorPathSegment).Points[1]*Scale)+Translate]);
       end;
       TpvVectorPathSegmentType.QuadraticCurve:begin
        AddQuadraticBezierCurveToPathSegmentArray(Contour^,[(TpvVectorPathSegmentQuadraticCurve(LocalVectorPathSegment).Points[0]*Scale)+Translate,
                                                            (TpvVectorPathSegmentQuadraticCurve(LocalVectorPathSegment).Points[1]*Scale)+Translate,
                                                            (TpvVectorPathSegmentQuadraticCurve(LocalVectorPathSegment).Points[2]*Scale)+Translate]);
       end;
       TpvVectorPathSegmentType.CubicCurve:begin
        raise Exception.Create('Ups?!');
       end;
      end;
     end;
    finally
     SetLength(Contour^.PathSegments,Contour^.CountPathSegments);
    end;
   end;
  finally
   SetLength(fShape.Contours,fShape.CountContours);
  end;
 finally
  FreeAndNil(LocalVectorPathShape);
 end;
end;

function TpvSignedDistanceField2DGenerator.ConvertShapeToMSDFShape:TpvSignedDistanceField2DMSDFGenerator.TShape;
var ContourIndex,EdgeIndex:TpvSizeInt;
    SrcContour:PpvSignedDistanceField2DPathContour;
    DstContour:TpvSignedDistanceField2DMSDFGenerator.PContour;
    SrcPathSegment:PpvSignedDistanceField2DPathSegment;
    DstEdge:TpvSignedDistanceField2DMSDFGenerator.PEdgeSegment;
begin
 result:=TpvSignedDistanceField2DMSDFGenerator.TShape.Create;
 result.Contours:=nil;
 SetLength(result.Contours,fShape.CountContours);
 result.Count:=fShape.CountContours;
 for ContourIndex:=0 to fShape.CountContours-1 do begin
  SrcContour:=@fShape.Contours[ContourIndex];
  DstContour:=@result.Contours[ContourIndex];
  DstContour^.Edges:=nil;
  SetLength(DstContour^.Edges,SrcContour^.CountPathSegments);
  DstContour^.Count:=SrcContour^.CountPathSegments;
  DstContour^.CachedWinding:=Low(TpvSizeInt);
  for EdgeIndex:=0 to SrcContour^.CountPathSegments-1 do begin
   SrcPathSegment:=@SrcContour^.PathSegments[EdgeIndex];
   DstEdge:=@DstContour.Edges[EdgeIndex];
   case SrcPathSegment^.Type_ of
    TpvSignedDistanceField2DPathSegmentType.Line:begin
     DstEdge^:=TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(TpvVectorPathVector.Create(SrcPathSegment^.Points[0].x,SrcPathSegment^.Points[0].y),TpvVectorPathVector.Create(SrcPathSegment^.Points[1].x,SrcPathSegment^.Points[1].y));
    end;
    else {TpvSignedDistanceField2DPathSegmentType.QuadraticBezierCurve:}begin
     DstEdge^:=TpvSignedDistanceField2DMSDFGenerator.TEdgeSegment.Create(TpvVectorPathVector.Create(SrcPathSegment^.Points[0].x,SrcPathSegment^.Points[0].y),TpvVectorPathVector.Create(SrcPathSegment^.Points[1].x,SrcPathSegment^.Points[1].y),TpvVectorPathVector.Create(SrcPathSegment^.Points[2].x,SrcPathSegment^.Points[2].y));
    end;
   end;
  end;
  DstContour^.Winding;
 end;
 result.Normalize;
end;

procedure TpvSignedDistanceField2DGenerator.CalculateDistanceFieldDataLineRange(const FromY,ToY:TpvInt32);
var ContourIndex,PathSegmentIndex,x0,y0,x1,y1,x,y,PixelIndex,Dilation,DeltaWindingScore:TpvInt32;
    Contour:PpvSignedDistanceField2DPathContour;
    PathSegment:PpvSignedDistanceField2DPathSegment;
    PathSegmentBoundingBox:TpvSignedDistanceField2DBoundingBox;
    PreviousPathSegmentSide,PathSegmentSide:TpvSignedDistanceField2DPathSegmentSide;
    RowData:TpvSignedDistanceField2DRowData;
    DistanceFieldDataItem:PpvSignedDistanceField2DDataItem;
    PointLeft,PointRight,Point,p0,p1,Direction,OriginPointDifference:TpvVectorPathVector;
    pX,pY,CurrentSquaredDistance,CurrentSquaredPseudoDistance,Time,Value,oX,oY:TpvDouble;
begin
 GetOffset(oX,oY);
 RowData.QuadraticXDirection:=0;
 for ContourIndex:=0 to fShape.CountContours-1 do begin
  Contour:=@fShape.Contours[ContourIndex];
  for PathSegmentIndex:=0 to Contour^.CountPathSegments-1 do begin
   PathSegment:=@Contour^.PathSegments[PathSegmentIndex];
   PathSegmentBoundingBox.Min.x:=PathSegment.BoundingBox.Min.x-DistanceField2DPadValue;
   PathSegmentBoundingBox.Min.y:=PathSegment.BoundingBox.Min.y-DistanceField2DPadValue;
   PathSegmentBoundingBox.Max.x:=PathSegment.BoundingBox.Max.x+DistanceField2DPadValue;
   PathSegmentBoundingBox.Max.y:=PathSegment.BoundingBox.Max.y+DistanceField2DPadValue;
   x0:=Clamp(Trunc(Floor(PathSegmentBoundingBox.Min.x)),0,fDistanceField.Width-1);
   y0:=Clamp(Trunc(Floor(PathSegmentBoundingBox.Min.y)),0,fDistanceField.Height-1);
   x1:=Clamp(Trunc(Ceil(PathSegmentBoundingBox.Max.x)),0,fDistanceField.Width-1);
   y1:=Clamp(Trunc(Ceil(PathSegmentBoundingBox.Max.y)),0,fDistanceField.Height-1);
{  x0:=0;
   y0:=0;
   x1:=DistanceField.Width-1;
   y1:=DistanceField.Height-1;}
   for y:=Max(FromY,y0) to Min(ToY,y1) do begin
    PreviousPathSegmentSide:=TpvSignedDistanceField2DPathSegmentSide.None;
    pY:=y+oY+0.5;
    PointLeft.x:=x0;
    PointLeft.y:=pY;
    PointRight.x:=x1;
    PointRight.y:=pY;
    if BetweenClosedOpen(pY,PathSegment.BoundingBox.Min.y,PathSegment.BoundingBox.Max.y) then begin
     PrecomputationForRow(RowData,PathSegment^,PointLeft,PointRight);
    end;
    for x:=x0 to x1 do begin
     PixelIndex:=(y*fDistanceField.Width)+x;
     pX:=x+oX+0.5;
     Point.x:=pX;
     Point.y:=pY;
     DistanceFieldDataItem:=@fDistanceFieldData[PixelIndex];
     Dilation:=Clamp(Floor(sqrt(Max(1,DistanceFieldDataItem^.SquaredDistance))+0.5),1,DistanceField2DPadValue);
     PathSegmentBoundingBox.Min.x:=Floor(PathSegment.BoundingBox.Min.x)-DistanceField2DPadValue;
     PathSegmentBoundingBox.Min.y:=Floor(PathSegment.BoundingBox.Min.y)-DistanceField2DPadValue;
     PathSegmentBoundingBox.Max.x:=Ceil(PathSegment.BoundingBox.Max.x)+DistanceField2DPadValue;
     PathSegmentBoundingBox.Max.y:=Ceil(PathSegment.BoundingBox.Max.y)+DistanceField2DPadValue;
     if (Dilation<>DistanceField2DPadValue) and not
        (((x>=PathSegmentBoundingBox.Min.x) and (x<=PathSegmentBoundingBox.Max.x)) and
         ((y>=PathSegmentBoundingBox.Min.y) and (y<=PathSegmentBoundingBox.Max.y))) then begin
      continue;
     end else begin
      PathSegmentSide:=TpvSignedDistanceField2DPathSegmentSide.None;
      CurrentSquaredDistance:=DistanceToPathSegment(Point,PathSegment^,RowData,PathSegmentSide);
      CurrentSquaredPseudoDistance:=CurrentSquaredDistance;
      if (PreviousPathSegmentSide=TpvSignedDistanceField2DPathSegmentSide.Left) and (PathSegmentSide=TpvSignedDistanceField2DPathSegmentSide.Right) then begin
       DeltaWindingScore:=-1;
      end else if (PreviousPathSegmentSide=TpvSignedDistanceField2DPathSegmentSide.Right) and (PathSegmentSide=TpvSignedDistanceField2DPathSegmentSide.Left) then begin
       DeltaWindingScore:=1;
      end else begin
       DeltaWindingScore:=0;
      end;
      PreviousPathSegmentSide:=PathSegmentSide;
      if CurrentSquaredDistance<DistanceFieldDataItem^.SquaredDistance then begin
       DistanceFieldDataItem^.SquaredDistance:=CurrentSquaredDistance;
      end;
      inc(DistanceFieldDataItem^.DeltaWindingScore,DeltaWindingScore);
     end;
    end;
   end;
  end;
 end;
end;

procedure TpvSignedDistanceField2DGenerator.CalculateDistanceFieldDataLineRangeParallelForJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32;const Data:TpvPointer;const FromIndex,ToIndex:TPasMPNativeInt);
begin
 CalculateDistanceFieldDataLineRange(FromIndex,ToIndex);
end;

function TpvSignedDistanceField2DGenerator.PackDistanceFieldValue(Distance:TpvDouble):TpvUInt8;
begin
 result:=Clamp(Round((Distance*(128.0/DistanceField2DMagnitudeValue))+128.0),0,255);
end;

function TpvSignedDistanceField2DGenerator.PackPseudoDistanceFieldValue(Distance:TpvDouble):TpvUInt8;
begin
 result:=Clamp(Round((Distance*(128.0/DistanceField2DMagnitudeValue))+128.0),0,255);
end;

procedure TpvSignedDistanceField2DGenerator.ConvertToPointInPolygonPathSegments;
var ContourIndex,PathSegmentIndex,CountPathSegments:TpvInt32;
    Contour:PpvSignedDistanceField2DPathContour;
    PathSegment:PpvSignedDistanceField2DPathSegment;
    StartPoint,LastPoint:TpvVectorPathVector;
 procedure AddPathSegment(const p0,p1:TpvVectorPathVector);
 var Index:TpvInt32;
     PointInPolygonPathSegment:PpvSignedDistanceField2DPointInPolygonPathSegment;
 begin
  if not (SameValue(p0.x,p1.x) and SameValue(p0.y,p1.y)) then begin
   Index:=CountPathSegments;
   inc(CountPathSegments);
   if length(fPointInPolygonPathSegments)<CountPathSegments then begin
    SetLength(fPointInPolygonPathSegments,CountPathSegments*2);
   end;
   PointInPolygonPathSegment:=@fPointInPolygonPathSegments[Index];
   PointInPolygonPathSegment^.Points[0]:=p0;
   PointInPolygonPathSegment^.Points[1]:=p1;
  end;
 end;
 procedure AddQuadraticBezierCurveAsSubdividedLinesToPathSegmentArray(const p0,p1,p2:TpvVectorPathVector);
 var LastPoint:TpvVectorPathVector;
  procedure LineToPointAt(const Point:TpvVectorPathVector);
  begin
   AddPathSegment(LastPoint,Point);
   LastPoint:=Point;
  end;
  procedure Recursive(const x1,y1,x2,y2,x3,y3:TpvDouble;const Level:TpvInt32);
  var x12,y12,x23,y23,x123,y123,dx,dy:TpvDouble;
      Point:TpvVectorPathVector;
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
    Point.x:=x3;
    Point.y:=y3;
    LineToPointAt(Point);
   end else begin
    Recursive(x1,y1,x12,y12,x123,y123,Level+1);
    Recursive(x123,y123,x23,y23,x3,y3,Level+1);
   end;
  end;
 begin
  LastPoint:=p0;
  Recursive(p0.x,p0.y,p1.x,p1.y,p2.x,p2.y,0);
  LineToPointAt(p2);
 end;
begin
 fPointInPolygonPathSegments:=nil;
 CountPathSegments:=0;
 try
  for ContourIndex:=0 to fShape.CountContours-1 do begin
   Contour:=@fShape.Contours[ContourIndex];
   if Contour^.CountPathSegments>0 then begin
    StartPoint.x:=0.0;
    StartPoint.y:=0.0;
    LastPoint.x:=0.0;
    LastPoint.y:=0.0;
    for PathSegmentIndex:=0 to Contour^.CountPathSegments-1 do begin
     PathSegment:=@Contour^.PathSegments[PathSegmentIndex];
     case PathSegment^.Type_ of
      TpvSignedDistanceField2DPathSegmentType.Line:begin
       if PathSegmentIndex=0 then begin
        StartPoint:=PathSegment^.Points[0];
       end;
       LastPoint:=PathSegment^.Points[1];
       AddPathSegment(PathSegment^.Points[0],PathSegment^.Points[1]);
      end;
      TpvSignedDistanceField2DPathSegmentType.QuadraticBezierCurve:begin
       if PathSegmentIndex=0 then begin
        StartPoint:=PathSegment^.Points[0];
       end;
       LastPoint:=PathSegment^.Points[2];
       AddQuadraticBezierCurveAsSubdividedLinesToPathSegmentArray(PathSegment^.Points[0],PathSegment^.Points[1],PathSegment^.Points[2]);
      end;
     end;
    end;
    if not (SameValue(LastPoint.x,StartPoint.x) and SameValue(LastPoint.y,StartPoint.y)) then begin
     AddPathSegment(LastPoint,StartPoint);
    end;
   end;
  end;
 finally
  SetLength(fPointInPolygonPathSegments,CountPathSegments);
 end;
end;

function TpvSignedDistanceField2DGenerator.GetWindingNumberAtPointInPolygon(const Point:TpvVectorPathVector):TpvInt32;
var Index,CaseIndex:TpvInt32;
    PointInPolygonPathSegment:PpvSignedDistanceField2DPointInPolygonPathSegment;
    x0,y0,x1,y1:TpvDouble;
begin
 result:=0;
 for Index:=0 to length(fPointInPolygonPathSegments)-1 do begin
  PointInPolygonPathSegment:=@fPointInPolygonPathSegments[Index];
  if not (SameValue(PointInPolygonPathSegment^.Points[0].x,PointInPolygonPathSegment^.Points[1].x) and
          SameValue(PointInPolygonPathSegment^.Points[0].y,PointInPolygonPathSegment^.Points[1].y)) then begin
   y0:=PointInPolygonPathSegment^.Points[0].y-Point.y;
   y1:=PointInPolygonPathSegment^.Points[1].y-Point.y;
   if y0<0.0 then begin
    CaseIndex:=0;
   end else if y0>0.0 then begin
    CaseIndex:=2;
   end else begin
    CaseIndex:=1;
   end;
   if y1<0.0 then begin
    inc(CaseIndex,0);
   end else if y1>0.0 then begin
    inc(CaseIndex,6);
   end else begin
    inc(CaseIndex,3);
   end;
   if CaseIndex in [1,2,3,6] then begin
    x0:=PointInPolygonPathSegment^.Points[0].x-Point.x;
    x1:=PointInPolygonPathSegment^.Points[1].x-Point.x;
    if not (((x0>0.0) and (x1>0.0)) or ((not ((x0<=0.0) and (x1<=0.0))) and ((x0-(y0*((x1-x0)/(y1-y0))))>0.0))) then begin
     if CaseIndex in [1,2] then begin
      inc(result);
     end else begin
      dec(result);
     end;
    end;
   end;
  end;
 end;
end;

function TpvSignedDistanceField2DGenerator.GenerateDistanceFieldPicture(const DistanceFieldData:TpvSignedDistanceField2DData;const Width,Height,TryIteration:TpvInt32):boolean;
var x,y,PixelIndex,DistanceFieldSign,WindingNumber,Value:TpvInt32;
    DistanceFieldDataItem:PpvSignedDistanceField2DDataItem;
    DistanceFieldPixel:PpvSignedDistanceField2DPixel;
    p:TpvVectorPathVector;
    oX,oY,SignedDistance:TpvDouble;
begin

 result:=true;

 GetOffset(oX,oY);

 PixelIndex:=0;
 for y:=0 to Height-1 do begin
  WindingNumber:=0;
  for x:=0 to Width-1 do begin
   DistanceFieldDataItem:=@DistanceFieldData[PixelIndex];
   if TryIteration=2 then begin
    p.x:=x+oX+0.5;
    p.y:=y+oY+0.5;
    WindingNumber:=GetWindingNumberAtPointInPolygon(p);
   end else begin
    inc(WindingNumber,DistanceFieldDataItem^.DeltaWindingScore);
    if (x=(Width-1)) and (WindingNumber<>0) then begin
     result:=false;
     break;
    end;
   end;
   case fVectorPathShape.FillRule of
    TpvVectorPathFillRule.NonZero:begin
     if WindingNumber<>0 then begin
      DistanceFieldSign:=1;
     end else begin
      DistanceFieldSign:=-1;
     end;
    end;
    else {TpvVectorPathFillRule.EvenOdd:}begin
     if (WindingNumber and 1)<>0 then begin
      DistanceFieldSign:=1;
     end else begin
      DistanceFieldSign:=-1;
     end;
    end;
   end;
   DistanceFieldPixel:=@fDistanceField^.Pixels[PixelIndex];
   case fVariant of
    TpvSignedDistanceField2DVariant.MSDF:begin
     if assigned(fMSDFImage) then begin
      SignedDistance:=TpvSignedDistanceField2DMSDFGenerator.Median(fMSDFImage^.Pixels[PixelIndex].r,fMSDFImage^.Pixels[PixelIndex].g,fMSDFImage^.Pixels[PixelIndex].b);
      if SameValue(SignedDistance,0.5) then begin
       fMSDFAmbiguous:=true;
       fMSDFMatches[PixelIndex]:=0;
      end else if TpvSignedDistanceField2DMSDFGenerator.Sign(SignedDistance-0.5)<>DistanceFieldSign then begin
       fMSDFImage.Pixels[PixelIndex].r:=0.5-(fMSDFImage.Pixels[PixelIndex].r-0.5);
       fMSDFImage.Pixels[PixelIndex].g:=0.5-(fMSDFImage.Pixels[PixelIndex].g-0.5);
       fMSDFImage.Pixels[PixelIndex].b:=0.5-(fMSDFImage.Pixels[PixelIndex].b-0.5);
       fMSDFMatches[PixelIndex]:=-1;
      end else begin
       fMSDFMatches[PixelIndex]:=1;
      end;
      if TpvSignedDistanceField2DMSDFGenerator.Sign(fMSDFImage^.Pixels[PixelIndex].a-0.5)<>DistanceFieldSign then begin
       fMSDFImage^.Pixels[PixelIndex].a:=0.5-(fMSDFImage.Pixels[PixelIndex].a-0.5);
      end;
     end;
    end;
    TpvSignedDistanceField2DVariant.GSDF:begin
     case fColorChannelIndex of
      1:begin
       DistanceFieldPixel^.g:=PackDistanceFieldValue((sqrt(DistanceFieldDataItem^.SquaredDistance)*DistanceFieldSign)-DistanceFieldDataItem^.Distance);
      end;
      2:begin
       DistanceFieldPixel^.b:=PackDistanceFieldValue((sqrt(DistanceFieldDataItem^.SquaredDistance)*DistanceFieldSign)-DistanceFieldDataItem^.Distance);
      end;
      else {0:}begin
       DistanceFieldDataItem^.Distance:=sqrt(DistanceFieldDataItem^.SquaredDistance)*DistanceFieldSign;
       Value:=PackDistanceFieldValue(DistanceFieldDataItem^.Distance);
       DistanceFieldPixel^.r:=Value;
       DistanceFieldPixel^.g:=Value;
       DistanceFieldPixel^.b:=Value;
       DistanceFieldPixel^.a:=Value;
      end;
     end;
    end;
    TpvSignedDistanceField2DVariant.SSAASDF:begin
     Value:=PackDistanceFieldValue(sqrt(DistanceFieldDataItem^.SquaredDistance)*DistanceFieldSign);
     case fColorChannelIndex of
      0:begin
       DistanceFieldPixel^.r:=Value;
      end;
      1:begin
       DistanceFieldPixel^.g:=Value;
      end;
      2:begin
       DistanceFieldPixel^.b:=Value;
      end;
      else {3:}begin
       DistanceFieldPixel^.a:=Value;
      end;
     end;
    end;
    else begin
     Value:=PackDistanceFieldValue(sqrt(DistanceFieldDataItem^.SquaredDistance)*DistanceFieldSign);
     DistanceFieldPixel^.r:=Value;
     DistanceFieldPixel^.g:=Value;
     DistanceFieldPixel^.b:=Value;
     DistanceFieldPixel^.a:=Value;
    end;
   end;
   inc(PixelIndex);
  end;
  if not result then begin
   break;
  end;
 end;

end;

procedure TpvSignedDistanceField2DGenerator.Execute(var aDistanceField:TpvSignedDistanceField2D;const aVectorPathShape:TpvVectorPathShape;const aScale:TpvDouble;const aOffsetX:TpvDouble;const aOffsetY:TpvDouble;const aVariant:TpvSignedDistanceField2DVariant;const aProtectBorder:boolean);
var PasMPInstance:TPasMP;
 procedure Generate;
 var TryIteration,ColorChannelIndex,CountColorChannels:TpvInt32;
     OK:boolean;
     CountMSDFPixels:TpvSizeInt;
     MSDFOriginalPixels:TpvSignedDistanceField2DMSDFGenerator.TPixels;
 begin

  case aVariant of
   TpvSignedDistanceField2DVariant.GSDF:begin
    CountColorChannels:=3;
   end;
   TpvSignedDistanceField2DVariant.SSAASDF:begin
    CountColorChannels:=4;
   end;
   else begin
    CountColorChannels:=1;
   end;
  end;

  CountMSDFPixels:=0;
  MSDFOriginalPixels:=nil;
  if assigned(fMSDFImage) then begin
   CountMSDFPixels:=length(fMSDFImage^.Pixels);
   if CountMSDFPixels>0 then begin
    SetLength(MSDFOriginalPixels,CountMSDFPixels);
    Move(fMSDFImage^.Pixels[0],MSDFOriginalPixels[0],CountMSDFPixels*SizeOf(TpvSignedDistanceField2DMSDFGenerator.TPixel));
   end;
  end;

  fDistanceFieldData:=nil;
  try

   SetLength(fDistanceFieldData,fDistanceField.Width*fDistanceField.Height);

   try

    Initialize(fShape);
    try

     fPointInPolygonPathSegments:=nil;
     try

      for TryIteration:=0 to 2 do begin

       if assigned(fMSDFImage) then begin
        fMSDFAmbiguous:=false;
        if CountMSDFPixels>0 then begin
         Move(MSDFOriginalPixels[0],fMSDFImage^.Pixels[0],CountMSDFPixels*SizeOf(TpvSignedDistanceField2DMSDFGenerator.TPixel));
        end;
       end;

       case TryIteration of

        0,1:begin
         InitializeDistances;
         ConvertShape(TryIteration in [1,2]);
        end;

        else {2:}begin
         InitializeDistances;
         ConvertShape(true);
         ConvertToPointInPolygonPathSegments;
        end;
       end;

       OK:=true;

       for ColorChannelIndex:=0 to CountColorChannels-1 do begin
        fColorChannelIndex:=ColorChannelIndex;
        PasMPInstance.Invoke(PasMPInstance.ParallelFor(nil,0,fDistanceField.Height-1,CalculateDistanceFieldDataLineRangeParallelForJobFunction,1,10,nil,0));
        if not GenerateDistanceFieldPicture(fDistanceFieldData,fDistanceField.Width,fDistanceField.Height,TryIteration) then begin
         OK:=false;
         break;
        end;
       end;

       if OK then begin
        break;
       end else begin
        // Try it again, after all quadratic bezier curves were subdivided into lines at the next try iteration
       end;

      end;

     finally
      fPointInPolygonPathSegments:=nil;
     end;

    finally
     Finalize(fShape);
    end;

   finally
    fDistanceField:=nil;
   end;

  finally
   fDistanceFieldData:=nil;
  end;

 end;
 procedure GenerateMSDF;
 var x,y,NeighbourMatch:TpvSizeInt;
     MSDFShape:TpvSignedDistanceField2DMSDFGenerator.TShape;
     MSDFImage:TpvSignedDistanceField2DMSDFGenerator.TImage;
     sp:TpvSignedDistanceField2DMSDFGenerator.PPixel;
     dp:PpvSignedDistanceField2DPixel;
 begin

  MSDFImage.Pixels:=nil;
  try

   MSDFImage.Width:=aDistanceField.Width;
   MSDFImage.Height:=aDistanceField.Height;

   SetLength(MSDFImage.Pixels,MSDFImage.Width*MSDFImage.Height);

   FillChar(MSDFImage.Pixels[0],MSDFImage.Width*MSDFImage.Height*SizeOf(TpvSignedDistanceField2DMSDFGenerator.TPixel),#0);

   Initialize(fShape);
   try

    ConvertShape(false);

    MSDFShape:=ConvertShapeToMSDFShape;
    try

     TpvSignedDistanceField2DMSDFGenerator.EdgeColoringSimple(MSDFShape,3,0);

     TpvSignedDistanceField2DMSDFGenerator.GenerateDistanceField(MSDFImage,MSDFShape,VulkanDistanceField2DSpreadValue,TpvVectorPathVector.Create(1.0,1.0),TpvVectorPathVector.Create(0.0,0.0));

     TpvSignedDistanceField2DMSDFGenerator.ErrorCorrection(MSDFImage,MSDFShape,VulkanDistanceField2DSpreadValue,TpvVectorPathVector.Create(1.0,1.0),TpvVectorPathVector.Create(0.0,0.0));

    finally
     MSDFShape.Contours:=nil;
    end;

   finally
    Finalize(fShape);
   end;

   fMSDFShape:=@MSDFShape;
   fMSDFImage:=@MSDFImage;
   fMSDFAmbiguous:=false;
   fMSDFMatches:=nil;
   try
    SetLength(fMSDFMatches,MSDFImage.Width*MSDFImage.Height);
    Generate;
    if fMSDFAmbiguous then begin
     for y:=0 to MSDFImage.Height-1 do begin
      for x:=0 to MSDFImage.Width-1 do begin
       if fMSDFMatches[(y*MSDFImage.Width)+x]=0 then begin
        NeighbourMatch:=0;
        if x>0 then begin
         inc(NeighbourMatch,fMSDFMatches[(y*MSDFImage.Width)+(x-1)]);
        end;
        if x<(MSDFImage.Width-1) then begin
         inc(NeighbourMatch,fMSDFMatches[(y*MSDFImage.Width)+(x+1)]);
        end;
        if y>0 then begin
         inc(NeighbourMatch,fMSDFMatches[((y-1)*MSDFImage.Width)+x]);
        end;
        if y<(MSDFImage.Height-1) then begin
         inc(NeighbourMatch,fMSDFMatches[((y+1)*MSDFImage.Width)+x]);
        end;
        if NeighbourMatch<0 then begin
         sp:=@MSDFImage.Pixels[(y*MSDFImage.Width)+x];
         sp^.r:=0.5-(sp^.r-0.5);
         sp^.g:=0.5-(sp^.g-0.5);
         sp^.b:=0.5-(sp^.b-0.5);
        end;
       end;
      end;
     end;
    end;
   finally
    fMSDFMatches:=nil;
   end;
   fMSDFImage:=nil;
   fMSDFShape:=nil;

   sp:=@MSDFImage.Pixels[0];
   dp:=@aDistanceField.Pixels[0];
   for y:=0 to MSDFImage.Height-1 do begin
    for x:=0 to MSDFImage.Width-1 do begin
     dp^.r:=Min(Max(Round(sp^.r*256),0),255);
     dp^.g:=Min(Max(Round(sp^.g*256),0),255);
     dp^.b:=Min(Max(Round(sp^.b*256),0),255);
     dp^.a:=Min(Max(Round(sp^.a*256),0),255);
     inc(sp);
     inc(dp);
    end;
   end;

  finally
   MSDFImage.Pixels:=nil;
  end;

 end;
var x,y:TpvSizeInt;
begin

 PasMPInstance:=TPasMP.GetGlobalInstance;

 fDistanceField:=@aDistanceField;

 fVectorPathShape:=aVectorPathShape;

 fScale:=aScale;

 fOffsetX:=aOffsetX;

 fOffsetY:=aOffsetY;

 fVariant:=aVariant;

 try

  case aVariant of

   TpvSignedDistanceField2DVariant.MSDF:begin
    GenerateMSDF;
   end;

   else begin

    fMSDFShape:=nil;
    fMSDFImage:=nil;
    Generate;

   end;

  end;

 finally
  fVectorPathShape:=nil;
 end;

 if aProtectBorder and (aDistanceField.Width>=4) and (aDistanceField.Height>=4) then begin

  for y:=0 to aDistanceField.Height-1 do begin
   aDistanceField.Pixels[(y*aDistanceField.Width)+0]:=aDistanceField.Pixels[(y*aDistanceField.Width)+1];
   aDistanceField.Pixels[(y*aDistanceField.Width)+(aDistanceField.Width-1)]:=aDistanceField.Pixels[(y*aDistanceField.Width)+(aDistanceField.Width-2)];
  end;

  for x:=0 to aDistanceField.Width-1 do begin
   aDistanceField.Pixels[(aDistanceField.Width*0)+x]:=aDistanceField.Pixels[(aDistanceField.Width*1)+x];
   aDistanceField.Pixels[(aDistanceField.Width*(aDistanceField.Height-1))+x]:=aDistanceField.Pixels[(aDistanceField.Width*(aDistanceField.Height-2))+x];
  end;

 end;

end;

class procedure TpvSignedDistanceField2DGenerator.Generate(var aDistanceField:TpvSignedDistanceField2D;const aVectorPathShape:TpvVectorPathShape;const aScale:TpvDouble;const aOffsetX:TpvDouble;const aOffsetY:TpvDouble;const aVariant:TpvSignedDistanceField2DVariant;const aProtectBorder:boolean);
var Generator:TpvSignedDistanceField2DGenerator;
begin
 Generator:=TpvSignedDistanceField2DGenerator.Create;
 try
  Generator.Execute(aDistanceField,aVectorPathShape,aScale,aOffsetX,aOffsetY,aVariant,aProtectBorder);
 finally
  Generator.Free;
 end;
end;

end.
