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
unit PasVulkan.Scene3D.Gizmo;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}
{$if defined(Win32) or defined(Win64)}
 {$define Windows}
{$ifend}

{$if defined(Windows) or defined(fpc)}
 {$define UseResources}
{$else}
 {$undef UseResources}
{$ifend}

{$scopedenums on}

interface

uses SysUtils,
     Classes,
     Math,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework;

type { TpvScene3DGizmo }
     TpvScene3DGizmo=class
      public
       type TViewMode=
             (
              Orthographic,
              Perspective
             );
            TOperation=
             (
              None,
              Translate,
              Rotate,
              Scale,
              Bounds
             );
            TMode=
             (
              Local,
              World
             );
            TAction=
             (
              None,
              MoveX,
              MoveY,
              MoveZ,
              MoveYZ,
              MoveZX,
              MoveXY,
              MoveScreen,
              RotateX,
              RotateY,
              RotateZ,
              RotateScreen,
              ScaleX,
              ScaleY,
              ScaleZ,
              ScaleXYZ
             );
            TMouseAction=
             (
              None,
              Check,
              Down,
              Move,
              Up
             );
      private
       const SelectionColor:TpvVector4=(x:1.0;y:0.5;z:0.125;w:0.25);
             InactiveColor:TpvVector4=(x:0.6;y:0.6;z:0.6;w:0.6);
             BlackColor:TpvVector4=(x:0.0;y:0.0;z:0.0;w:0.25);
             WhiteColor:TpvVector4=(x:1.0;y:1.0;z:1.0;w:1.0);
             TranslationColor:TpvVector4=(x:1.0;y:1.0;z:1.0;w:1.0);
             //TranslationColor:TpvVector4=(x:0.6666;y:0.6666;z:0.6666;w:0.6666);
             RotationColor:TpvVector4=(x:1.0;y:0.5;z:0.125;w:1.0);
             RotationHalfAlphaColor:TpvVector4=(x:1.0;y:0.5;z:0.125;w:0.25);
             GrayColor:TpvVector4=(x:0.25;y:0.25;z:0.25;w:1.0);
             PlaneColors:array[0..2] of TpvVector4=((x:1.0;y:0.0;z:0.0;w:0.25),
                                                    (x:0.0;y:1.0;z:0.0;w:0.25),
                                                    (x:0.0;y:0.0;z:1.0;w:0.25));
             DirectionColors:array[0..2] of TpvVector4=((x:0.6666;y:0.0;z:0.0;w:1.0),
                                                        (x:0.0;y:0.6666;z:0.0;w:1.0),
                                                        (x:0.0;y:0.0;z:0.6666;w:1.0));
             DirectionUnary:array[0..2] of TpvVector3=((x:1.0;y:0.0;z:0.0),
                                                       (x:0.0;y:1.0;z:0.0),
                                                       (x:0.0;y:0.0;z:1.0));
             QuadMin=0.5;
             QuadMax=0.8;
             QuadUV:array[0..7] of TpvScalar=(QuadMin,QuadMin,
                                              QuadMin,QuadMax,
                                              QuadMax,QuadMax,
                                              QuadMax,QuadMin);
             ScreenRotateSize=0.06;
             HalfCircleSegmentCount=64;
      private
       fScene3D:TObject;
       fRendererInstance:TObject;
       fMatrix:TpvMatrix4x4;
       fModelMatrix:TpvMatrix4x4;
       fModelLocalMatrix:TpvMatrix4x4;
       fModelSourceMatrix:TpvMatrix4x4;
       fModelScaleOrigin:TpvVector3;
       fViewMatrix:TpvMatrix4x4;
       fProjectionMatrix:TpvMatrix4x4;
       fInverseModelMatrix:TpvMatrix4x4;
       fInverseModelSourceMatrix:TpvMatrix4x4;
       fInverseViewMatrix:TpvMatrix4x4;
       fViewProjectionMatrix:TpvMatrix4x4;
       fInverseViewProjectionMatrix:TpvMatrix4x4;
       fModelViewProjectionMatrix:TpvMatrix4x4;
       fRayOrigin:TpvVector3;
       fRayDirection:TpvVector3;
       fScreenSquareCenter:TpvVector2;
       fScreenSquareMin:TpvVector2;
       fScreenSquareMax:TpvVector2;
       fTranslationPlane:TpvPlane;
       fTranslationPlaneOrigin:TpvVector3;
       fRelativeOrigin:TpvVector3;
       fMatrixOrigin:TpvVector3;
       fRotationVectorSource:TpvVector3;
       fRotationAngle:TpvScalar;
       fRotationAngleOrigin:TpvScalar;
       fScale:TpvVector3;
       fScaleValueOrigin:TpvVector3;
       fSaveMousePosition:TpvVector2;
       fRadiusSquareCenter:TpvScalar;
       fBoundsPivot:TpvVector3;
       fBoundsAnchor:TpvVector3;
       fBoundsPlane:TpvPlane;
       fBoundsLocalPivot:TpvVector3;
       fBoundsBestAxis:TpvSizeInt;
       fBoundsAxis:array[0..1] of TpvSizeInt;
       fUsingBounds:boolean;
       fBoundsMatrix:TpvMatrix4x4;
       fGraphicsInitialized:boolean;
       fViewMode:TViewMode;
       fOperation:TOperation;
       fMode:TMode;
       fAction:TAction;
       fViewPort:TpvVector4;
       fUsing:boolean;
       fBelowAxisLimits:array[0..2] of boolean;
       fBelowPlaneLimits:array[0..2] of boolean;
       fAxisFactors:array[0..2] of TpvScalar;
       fGizmoSizeClipSpace:TpvScalar;
       fScreenFactor:TpvScalar;
       fAspectRatio:TpvScalar;
       fMousePosition:TpvVector2;
       fSnapTranslate:TpvScalar;
       fSnapScale:TpvScalar;
       fSnapRotate:TpvScalar;
      public
       constructor Create(const aScene3D,aRendererInstance:TObject); reintroduce;
       destructor Destroy; override;
       procedure InitializeGraphics;
       procedure FinalizeGraphics;
       procedure ComputeCameraRay(out aRayOrigin,aRayDirection:TpvVector3);
       procedure Update(const aForceLocal:boolean);
       function WorldToPosition(const aWorldPosition:TpvVector3;const aMatrix:TpvMatrix4x4):TpvVector2;
       function WorldToPositionEx(const aWorldPosition:TpvVector3;const aMatrix:TpvMatrix4x4):TpvVector2;
       function ScreenSpaceToClipSpace(const aPoint:TpvVector2):TpvVector2;
       function GetSegmentLengthClipSpace(const aStart,aEnd:TpvVector3):TpvScalar;
       function GetParallelogram(const aO,aA,aB:TpvVector3):TpvScalar;
       procedure ComputeTripodAxisAndVisibility(const aAxisIndex:TpvSizeInt;out aDirAxis,aDirPlaneX,aDirPlaneY:TpvVector3;out aBelowAxisLimit,aBelowPlaneLimit:boolean);
       function IntersectRayPlane(const aRayOrigin,aRayDirection:TpvVector3;const aPlane:TpvPlane):TpvScalar;
       function PointOnSegment(const aPoint,aStart,aEnd:TpvVector2):TpvVector2; overload;
       function PointOnSegment(const aPoint,aStart,aEnd:TpvVector3):TpvVector3; overload;
       function GetRotateAction:TAction;
       function GetMoveAction:TAction;
       function GetScaleAction:TAction;
       procedure DrawGrid(const aInFlightFrameIndex:TpvSizeInt;const aGridSize:TpvScalar);
       procedure Draw(const aInFlightFrameIndex:TpvSizeInt;
                      const aMatrix:TpvMatrix4x4);
       function MouseAction(const aMatrix:TpvMatrix4x4;
                            const aMousePosition:TpvVector2;
                            const aMouseAction:TMouseAction;
                            const aDeltaMatrix:PpvMatrix4x4=nil;
                            const aNewMatrix:PpvMatrix4x4=nil):boolean;
      public
       property MousePosition:TpvVector2 read fMousePosition write fMousePosition;
       property Matrix:TpvMatrix4x4 read fMatrix write fMatrix;
       property ViewMatrix:TpvMatrix4x4 read fViewMatrix write fViewMatrix;
       property ProjectionMatrix:TpvMatrix4x4 read fProjectionMatrix write fProjectionMatrix;
       property ViewPort:TpvVector4 read fViewPort write fViewPort;
       property GizmoSizeClipSpace:TpvScalar read fGizmoSizeClipSpace write fGizmoSizeClipSpace;
       property AspectRatio:TpvScalar read fAspectRatio write fAspectRatio;
      published
       property Scene3D:TObject read fScene3D;
       property RendererInstance:TObject read fRendererInstance;
       property ViewMode:TViewMode read fViewMode write fViewMode;
       property Operation:TOperation read fOperation write fOperation;
       property Mode:TMode read fMode write fMode;
       property Action:TAction read fAction write fAction;
       property Using:boolean read fUsing write fUsing;
       property SnapTranslate:TpvScalar read fSnapTranslate write fSnapTranslate;
       property SnapScale:TpvScalar read fSnapScale write fSnapScale;
       property SnapRotate:TpvScalar read fSnapRotate write fSnapRotate;
     end;

implementation

uses PasVulkan.Scene3D,
     PasVulkan.Scene3D.Renderer,
     PasVulkan.Scene3D.Renderer.Instance;

const Epsilon=1.192092896e-07;

{ TpvScene3DGizmo }

constructor TpvScene3DGizmo.Create(const aScene3D,aRendererInstance:TObject);
begin
 inherited Create;
 fScene3D:=aScene3D;
 fRendererInstance:=aRendererInstance;
 fGraphicsInitialized:=false;
 fViewMode:=TViewMode.Perspective;
 fOperation:=TOperation.None;
 fMode:=TMode.Local;
 fAction:=TAction.None;
 fUsing:=false;
 fScreenFactor:=1.0;
 fAspectRatio:=1.0;
 fGizmoSizeClipSpace:=0.1;
 fSnapTranslate:=0.0;
 fSnapScale:=0.0;
 fSnapRotate:=0.0;
 fScene3D:=aScene3D;
end;

destructor TpvScene3DGizmo.Destroy;
begin
 FinalizeGraphics;
 inherited Destroy;
end;

procedure TpvScene3DGizmo.InitializeGraphics;
begin
 if not fGraphicsInitialized then begin
  fGraphicsInitialized:=true;
 end;
end;

procedure TpvScene3DGizmo.FinalizeGraphics;
begin
 if fGraphicsInitialized then begin
  fGraphicsInitialized:=false;
 end;
end;

procedure TpvScene3DGizmo.ComputeCameraRay(out aRayOrigin,aRayDirection:TpvVector3);
var m:TpvVector4;
begin
 m:=fInverseViewProjectionMatrix*TpvVector4.InlineableCreate((((fMousePosition.x-fViewPort.x)/fViewPort.z)*2.0)-1.0,
                                                             ((((fMousePosition.y-fViewPort.y)/fViewPort.w)*2.0)-1.0),
                                                             -1.0,
                                                             1.0);
 aRayOrigin:=m.xyz/m.w;
 m:=fInverseViewProjectionMatrix*TpvVector4.InlineableCreate((((fMousePosition.x-fViewPort.x)/fViewPort.z)*2.0)-1.0,
                                                             ((((fMousePosition.y-fViewPort.y)/fViewPort.w)*2.0)-1.0),
                                                             1.0-Epsilon,
                                                             1.0);
 aRayDirection:=((m.xyz/m.w)-aRayOrigin).Normalize;
end;

procedure TpvScene3DGizmo.Update(const aForceLocal:boolean);
var p:TpvVector4;
begin
 fModelLocalMatrix:=fMatrix.OrthoNormalize;
 if aForceLocal or (fMode=TMode.Local) then begin
  fModelMatrix:=fModelLocalMatrix;
 end else begin
  fModelMatrix:=TpvMatrix4x4.CreateTranslation(fMatrix.Translation);
 end;
 fModelSourceMatrix:=fMatrix;
 fModelScaleOrigin:=TpvVector3.InlineableCreate(fModelSourceMatrix.Right.xyz.Length,
                                                fModelSourceMatrix.Up.xyz.Length,
                                                fModelSourceMatrix.Forwards.xyz.Length);
 fInverseModelMatrix:=fModelMatrix.Inverse;
 fInverseModelSourceMatrix:=fModelSourceMatrix.Inverse;
 fInverseViewMatrix:=fViewMatrix.Inverse;
 fViewProjectionMatrix:=fViewMatrix*fProjectionMatrix;
 fInverseViewProjectionMatrix:=fViewProjectionMatrix.Inverse;
 fModelViewProjectionMatrix:=fModelMatrix*fViewProjectionMatrix;
 begin
{ p:=fViewProjectionMatrix*TpvVector4.InlineableCreate(fInverseViewMatrix.Right.xyz,1.0);
  fScreenFactor:=fGizmoSizeClipSpace/((p.x/p.w)-(fModelViewProjectionMatrix.Translation.x/fModelViewProjectionMatrix.Translation.w));}
  fScreenFactor:=fGizmoSizeClipSpace/GetSegmentLengthClipSpace(TpvVector3.Null,fInverseModelMatrix.MulBasis(fInverseViewMatrix.Right.xyz));
 end;
 begin
  fScreenSquareCenter:=WorldToPositionEx(TpvVector3.Null,fModelViewProjectionMatrix);
  fScreenSquareMin:=fScreenSquareCenter-TpvVector2.InlineableCreate(10.0,10.0);
  fScreenSquareMax:=fScreenSquareCenter+TpvVector2.InlineableCreate(10.0,10.0);
 end;
 ComputeCameraRay(fRayOrigin,fRayDirection);
end;

function TpvScene3DGizmo.WorldToPosition(const aWorldPosition:TpvVector3;const aMatrix:TpvMatrix4x4):TpvVector2;
var t:TpvVector4;
begin
 t:=aMatrix*TpvVector4.Create(aWorldPosition.xyz,1.0);
 t:=((t/t.w)*0.5)+TpvVector4.Create(0.5,0.5,0.0,0.0);
 t.y:=1.0-t.y;
 result:=(t.xy*fViewPort.zw)+fViewPort.xy;
end;

function TpvScene3DGizmo.WorldToPositionEx(const aWorldPosition:TpvVector3;const aMatrix:TpvMatrix4x4):TpvVector2;
var t:TpvVector4;
begin
 t:=aMatrix*TpvVector4.Create(aWorldPosition.xyz,1.0);
 t:=((t/t.w)*0.5)+TpvVector4.Create(0.5,0.5,0.0,0.0);
 result:=(t.xy*fViewPort.zw)+fViewPort.xy;
end;

function TpvScene3DGizmo.ScreenSpaceToClipSpace(const aPoint:TpvVector2):TpvVector2;
const Ones:TpvVector2=(x:1.0;y:1.0);
      FlipY:TpvVector2=(x:1.0;y:-1.0);
begin
 result:=((((aPoint-fViewPort.xy)/fViewPort.zw)*2.0)-Ones)*FlipY;
end;

function TpvScene3DGizmo.GetSegmentLengthClipSpace(const aStart,aEnd:TpvVector3):TpvScalar;
var StartOfSegment,EndOfSegment,ClipSpaceAxis:TpvVector4;
begin
 StartOfSegment:=fModelViewProjectionMatrix*TpvVector4.Create(aStart.xyz,1.0);
 if (abs(StartOfSegment.w)>Epsilon) and not IsZero(StartOfSegment.w) then begin
  StartOfSegment:=StartOfSegment/StartOfSegment.w;
 end;
 EndOfSegment:=fModelViewProjectionMatrix*TpvVector4.Create(aEnd.xyz,1.0);
 if (abs(EndOfSegment.w)>Epsilon) and not IsZero(EndOfSegment.w) then begin
  EndOfSegment:=EndOfSegment/EndOfSegment.w;
 end;
 ClipSpaceAxis:=EndOfSegment-StartOfSegment;
 ClipSpaceAxis.y:=ClipSpaceAxis.y/fAspectRatio;
 result:=ClipSpaceAxis.xy.Length;
end;

function TpvScene3DGizmo.GetParallelogram(const aO,aA,aB:TpvVector3):TpvScalar;
var Index:TpvSizeInt;
    p:array[0..2] of TpvVector4;
    SegA,SegB,SegAOrtho:TpvVector4;
begin
 p[0]:=TpvVector4.InlineableCreate(aO,1.0);
 p[1]:=TpvVector4.InlineableCreate(aA,1.0);
 p[2]:=TpvVector4.InlineableCreate(aB,1.0);
 for Index:=0 to 2 do begin
  p[Index]:=fModelViewProjectionMatrix*TpvVector4.Create(p[Index].xyz,1.0);
  if (abs(p[Index].w)>Epsilon) and not IsZero(p[Index].w) then begin
   p[Index]:=p[Index]/p[Index].w;
  end;
 end;
 SegA:=p[1]-p[0];
 SegB:=p[2]-p[0];
 SegA.y:=SegA.y/fAspectRatio;
 SegB.y:=SegB.y/fAspectRatio;
 SegAOrtho:=TpvVector4.InlineableCreate(-SegA.y,SegA.x,0.0,0.0);
 SegAOrtho.xyz:=SegAOrtho.xyz.Normalize;
 result:=SegA.xy.Length+abs(SegAOrtho.xyz.Dot(SegB.xyz));
end;

procedure TpvScene3DGizmo.ComputeTripodAxisAndVisibility(const aAxisIndex:TpvSizeInt;out aDirAxis,aDirPlaneX,aDirPlaneY:TpvVector3;out aBelowAxisLimit,aBelowPlaneLimit:boolean);
var LenDir,LenDirMinus,
    LenDirPlaneX,LenDirMinusPlaneX,
    LenDirPlaneY,LenDirMinusPlaneY,
    MulAxis,MulAxisX,MulAxisY,
    AxisLengthInClipSpace,
    ParaSurf:TpvScalar;
begin
 aDirAxis:=DirectionUnary[aAxisIndex];
 aDirPlaneX:=DirectionUnary[(aAxisIndex+1) mod 3];
 aDirPlaneY:=DirectionUnary[(aAxisIndex+2) mod 3];
 if fUsing then begin
  aBelowAxisLimit:=fBelowAxisLimits[aAxisIndex];
  aBelowPlaneLimit:=fBelowPlaneLimits[aAxisIndex];
  aDirAxis:=aDirAxis*fAxisFactors[aAxisIndex];
  aDirPlaneX:=aDirPlaneX*fAxisFactors[(aAxisIndex+1) mod 3];
  aDirPlaneY:=aDirPlaneY*fAxisFactors[(aAxisIndex+2) mod 3];
 end else begin
  LenDir:=GetSegmentLengthClipSpace(TpvVector3.Null,aDirAxis);
  LenDirMinus:=GetSegmentLengthClipSpace(TpvVector3.Null,-aDirAxis);
  LenDirPlaneX:=GetSegmentLengthClipSpace(TpvVector3.Null,aDirPlaneX);
  LenDirMinusPlaneX:=GetSegmentLengthClipSpace(TpvVector3.Null,-aDirPlaneX);
  LenDirPlaneY:=GetSegmentLengthClipSpace(TpvVector3.Null,aDirPlaneY);
  LenDirMinusPlaneY:=GetSegmentLengthClipSpace(TpvVector3.Null,-aDirPlaneY);
  if (LenDir<LenDirMinus) and (abs(LenDir-LenDirMinus)>Epsilon) and not IsZero(LenDir-LenDirMinus) then begin
   MulAxis:=-1.0;
  end else begin
   MulAxis:=1.0;
  end;
  if (LenDirPlaneX<LenDirMinusPlaneX) and (abs(LenDirPlaneX-LenDirMinusPlaneX)>Epsilon) and not IsZero(LenDirPlaneX-LenDirMinusPlaneX) then begin
   MulAxisX:=-1.0;
  end else begin
   MulAxisX:=1.0;
  end;
  if (LenDirPlaneY<LenDirMinusPlaneY) and (abs(LenDirPlaneY-LenDirMinusPlaneY)>Epsilon) and not IsZero(LenDirPlaneY-LenDirMinusPlaneY) then begin
   MulAxisY:=-1.0;
  end else begin
   MulAxisY:=1.0;
  end;
//writeln(MulAxisX);
  aDirAxis:=aDirAxis*MulAxis;
  aDirPlaneX:=aDirPlaneX*MulAxisX;
  aDirPlaneY:=aDirPlaneY*MulAxisY;
  AxisLengthInClipSpace:=GetSegmentLengthClipSpace(TpvVector3.Null,aDirAxis*fScreenFactor);
  ParaSurf:=GetParallelogram(TpvVector3.Null,aDirPlaneX*fScreenFactor,aDirPlaneY*fScreenFactor);
  aBelowPlaneLimit:=ParaSurf>0.0025;
  aBelowAxisLimit:=AxisLengthInClipSpace>0.02;
  fAxisFactors[aAxisIndex]:=MulAxis;
  fAxisFactors[(aAxisIndex+1) mod 3]:=MulAxisX;
  fAxisFactors[(aAxisIndex+2) mod 3]:=MulAxisY;
  fBelowAxisLimits[aAxisIndex]:=aBelowAxisLimit;
  fBelowPlaneLimits[aAxisIndex]:=aBelowPlaneLimit;
 end;
end;

function TpvScene3DGizmo.IntersectRayPlane(const aRayOrigin,aRayDirection:TpvVector3;const aPlane:TpvPlane):TpvScalar;
var d:TpvScalar;
begin
 d:=aPlane.Normal.Dot(aRayDirection);
 if (abs(d)<Epsilon) or IsZero(d) then begin
  result:=-1.0;
 end else begin
  result:=-(aPlane.DistanceTo(aRayOrigin)/d);
 end;
end;

function TpvScene3DGizmo.PointOnSegment(const aPoint,aStart,aEnd:TpvVector2):TpvVector2;
var Delta:TpvVector2;
    SquaredLength,Time:TpvScalar;
begin
 Delta:=aEnd-aStart;
 SquaredLength:=Delta.SquaredLength;
 if (SquaredLength<Epsilon) or IsZero(SquaredLength) then begin
  result:=aStart;
 end else begin
  Time:=Delta.Dot(aPoint-aStart)/SquaredLength;
  if Time<0.0 then begin
   result:=aStart;
  end else if Time>1.0 then begin
   result:=aEnd;
  end else begin
   result:=aStart.Lerp(aEnd,Time);
  end;
 end;
end;

function TpvScene3DGizmo.PointOnSegment(const aPoint,aStart,aEnd:TpvVector3):TpvVector3;
var Delta:TpvVector3;
    SquaredLength,Time:TpvScalar;
begin
 Delta:=aEnd-aStart;
 SquaredLength:=Delta.SquaredLength;
 if (SquaredLength<Epsilon) or IsZero(SquaredLength) then begin
  result:=aStart;
 end else begin
  Time:=Delta.Dot(aPoint-aStart)/SquaredLength;
  if Time<0.0 then begin
   result:=aStart;
  end else if Time>1.0 then begin
   result:=aEnd;
  end else begin
   result:=aStart.Lerp(aEnd,Time);
  end;
 end;
end;

function TpvScene3DGizmo.GetRotateAction:TAction;
var Index:TpvSizeInt;
    DeltaScreen,IdealPosOnCircleScreen:TpvVector2;
    Dist:TpvScalar;
    PlaneNormals:array[0..2] of TpvVector3;
    Plane:TpvPlane;
    IdealPosOnCircle,LocalPos:TpvVector3;
begin

 DeltaScreen:=fMousePosition-fScreenSquareCenter;
 Dist:=DeltaScreen.Length;
 if (Dist>=(fRadiusSquareCenter-1.0)) and (Dist<=(fRadiusSquareCenter+1.0)) then begin
  result:=TAction.RotateScreen;
 end else begin
  result:=TAction.None;
 end;

 PlaneNormals[0]:=fModelMatrix.Right.xyz;
 PlaneNormals[1]:=fModelMatrix.Up.xyz;
 PlaneNormals[2]:=fModelMatrix.Forwards.xyz;

 for Index:=0 to 2 do begin
  if result<>TAction.None then begin
   break;
  end;
  Plane:=TpvPlane.Create(PlaneNormals[Index],-PlaneNormals[Index].Dot(fModeLMatrix.Translation.xyz));
  LocalPos:=(fRayOrigin+(fRayDirection*IntersectRayPlane(fRayOrigin,fRayDirection,Plane)))-fModeLMatrix.Translation.xyz;
  IdealPosOnCircle:=LocalPos.Normalize;
  Dist:=IdealPosOnCircle.Dot(fRayDirection);
  if Dist<=Epsilon then begin
   IdealPosOnCircle:=fInverseModelMatrix.MulBasis(IdealPosOnCircle);
   IdealPosOnCircleScreen:=WorldToPositionEx(IdealPosOnCircle*fScreenFactor,fModelViewProjectionMatrix);
   if fMousePosition.DistanceTo(IdealPosOnCircleScreen)<8.0 then begin
    case Index of
     0:begin
      result:=TAction.RotateX;
     end;
     1:begin
      result:=TAction.RotateY;
     end;
     else {2:}begin
      result:=TAction.RotateZ;
     end;
    end;
   end;
  end;
 end;

end;

function TpvScene3DGizmo.GetMoveAction:TAction;
var Index:TpvSizeInt;
    BelowAxisLimit,BelowPlaneLimit:boolean;
    DirAxis,DirPlaneX,DirPlaneY,
    PosOnPlane,QuadHitProportionVector:TpvVector3;
    QuadHitProportion:TpvVector2;
begin
 if (fMousePosition.x>=fScreenSquareMin.x) and
    (fMousePosition.x<=fScreenSquareMax.x) and
    (fMousePosition.y>=fScreenSquareMin.y) and
    (fMousePosition.y<=fScreenSquareMax.y) then begin
  result:=TAction.MoveScreen;
 end else begin
  result:=TAction.None;
 end;
 for Index:=0 to 2 do begin
  if result<>TAction.None then begin
   break;
  end;
  BelowAxisLimit:=false;
  BelowPlaneLimit:=false;
  ComputeTripodAxisAndVisibility(Index,DirAxis,DirPlaneX,DirPlaneY,BelowAxisLimit,BelowPlaneLimit);
  if BelowAxisLimit and
     (PointOnSegment(fMousePosition,
                     WorldToPositionEx(DirAxis*0.1*fScreenFactor,fModelViewProjectionMatrix),
                     WorldToPositionEx(DirAxis*fScreenFactor,fModelViewProjectionMatrix)).DistanceTo(fMousePosition)<12.0) then begin
   case Index of
    0:begin
     result:=TAction.MoveX;
    end;
    1:begin
     result:=TAction.MoveY;
    end;
    2:begin
     result:=TAction.MoveZ;
    end;
   end;
  end;
  if BelowPlaneLimit then begin
   DirAxis:=fModelMatrix.MulBasis(DirAxis);
   DirPlaneX:=fModelMatrix.MulBasis(DirPlaneX);
   DirPlaneY:=fModelMatrix.MulBasis(DirPlaneY);
   PosOnPlane:=fRayOrigin+(fRayDirection*IntersectRayPlane(fRayOrigin,fRayDirection,TpvPlane.Create(DirAxis,-DirAxis.Dot(fModelMatrix.Translation.xyz))));
   QuadHitProportionVector:=(PosOnPlane-fModelMatrix.Translation.xyz)/fScreenFactor;
   QuadHitProportion:=TpvVector2.Create(DirPlaneX.Dot(QuadHitProportionVector),DirPlaneY.Dot(QuadHitProportionVector));
   if (QuadHitProportion.x>=QuadUV[0]) and (QuadHitProportion.x<=QuadUV[4]) and (QuadHitProportion.y>=QuadUV[1]) and (QuadHitProportion.y<=QuadUV[3]) then begin
    case Index of
     0:begin
      result:=TAction.MoveYZ;
     end;
     1:begin
      result:=TAction.MoveZX;
     end;
     2:begin
      result:=TAction.MoveXY;
     end;
    end;
   end;
  end;
 end;
end;

function TpvScene3DGizmo.GetScaleAction:TAction;
var Index:TpvSizeInt;
    BelowAxisLimit,BelowPlaneLimit:boolean;
    DirAxis,DirPlaneX,DirPlaneY,
    PosOnPlane,QuadHitProportionVector:TpvVector3;
    QuadHitProportion:TpvVector2;
begin
 if (fMousePosition.x>=fScreenSquareMin.x) and
    (fMousePosition.x<=fScreenSquareMax.x) and
    (fMousePosition.y>=fScreenSquareMin.y) and
    (fMousePosition.y<=fScreenSquareMax.y) then begin
  result:=TAction.ScaleXYZ;
 end else begin
  result:=TAction.None;
 end;
 for Index:=0 to 2 do begin
  if result<>TAction.None then begin
   break;
  end;
  BelowAxisLimit:=false;
  BelowPlaneLimit:=false;
  ComputeTripodAxisAndVisibility(Index,DirAxis,DirPlaneX,DirPlaneY,BelowAxisLimit,BelowPlaneLimit);
{ DirAxis:=fModelMatrix.MulBasis(DirAxis);
  DirPlaneX:=fModelMatrix.MulBasis(DirPlaneX);
  DirPlaneY:=fModelMatrix.MulBasis(DirPlaneY);}
  if BelowAxisLimit and
     (PointOnSegment(fMousePosition,
                     WorldToPositionEx(DirAxis*0.1*fScreenFactor,fModelViewProjectionMatrix),
                     WorldToPositionEx(DirAxis*fScreenFactor,fModelViewProjectionMatrix)).DistanceTo(fMousePosition)<12.0) then begin
   case Index of
    0:begin
     result:=TAction.ScaleX;
    end;
    1:begin
     result:=TAction.ScaleY;
    end;
    2:begin
     result:=TAction.ScaleZ;
    end;
   end;
  end;
 end;
end;

procedure TpvScene3DGizmo.DrawGrid(const aInFlightFrameIndex:TpvSizeInt;const aGridSize:TpvScalar);
var f:TpvScalar;
begin
 f:=-aGridSize;
 while f<=aGridSize do begin
  TpvScene3DRendererInstance(fRendererInstance).AddSolidLine3D(aInFlightFrameIndex,
                                                               TpvVector3.InlineableCreate(f,0.0,-aGridSize),
                                                               TpvVector3.InlineableCreate(f,0.0,aGridSize),
                                                               TpvVector4.InlineableCreate(0.5,0.5,0.5,1.0),
                                                               1.0,
                                                               TpvVector2.Null,
                                                               TpvVector2.Null);
  TpvScene3DRendererInstance(fRendererInstance).AddSolidLine3D(aInFlightFrameIndex,
                                                               TpvVector3.InlineableCreate(-aGridSize,0.0,f),
                                                               TpvVector3.InlineableCreate(aGridSize,0.0,f),
                                                               TpvVector4.InlineableCreate(0.5,0.5,0.5,1.0),
                                                               1.0,
                                                               TpvVector2.Null,
                                                               TpvVector2.Null);
  f:=f+1.0;
 end;
end;

procedure TpvScene3DGizmo.Draw(const aInFlightFrameIndex:TpvSizeInt;
                               const aMatrix:TpvMatrix4x4);
var Colors:array[0..7] of TpvVector4;
 procedure ComputeColors;
 var Index:TpvSizeInt;
 begin
  case Operation of
   TOperation.Rotate:begin
    if fAction=TAction.RotateScreen then begin
     Colors[0]:=SelectionColor;
    end else begin
     Colors[0]:=WhiteColor;
    end;
    if fAction=TAction.RotateX then begin
     Colors[1]:=SelectionColor;
    end else begin
     Colors[1]:=DirectionColors[0];
    end;
    if fAction=TAction.RotateY then begin
     Colors[2]:=SelectionColor;
    end else begin
     Colors[2]:=DirectionColors[1];
    end;
    if fAction=TAction.RotateZ then begin
     Colors[3]:=SelectionColor;
    end else begin
     Colors[3]:=DirectionColors[2];
    end;
   end;
   TOperation.Translate:begin
    if fAction=TAction.MoveScreen then begin
     Colors[0]:=SelectionColor;
    end else begin
     Colors[0]:=WhiteColor;
    end;
    if fAction=TAction.MoveX then begin
     Colors[1]:=SelectionColor;
    end else begin
     Colors[1]:=DirectionColors[0];
    end;
    if fAction=TAction.MoveY then begin
     Colors[2]:=SelectionColor;
    end else begin
     Colors[2]:=DirectionColors[1];
    end;
    if fAction=TAction.MoveZ then begin
     Colors[3]:=SelectionColor;
    end else begin
     Colors[3]:=DirectionColors[2];
    end;
    if fAction=TAction.MoveYZ then begin
     Colors[4]:=SelectionColor;
    end else begin
     Colors[4]:=PlaneColors[0];
    end;
    if fAction=TAction.MoveZX then begin
     Colors[5]:=SelectionColor;
    end else begin
     Colors[5]:=PlaneColors[1];
    end;
    if fAction=TAction.MoveXY then begin
     Colors[6]:=SelectionColor;
    end else begin
     Colors[6]:=PlaneColors[2];
    end;
   end;
   TOperation.Scale:begin
    if fAction=TAction.ScaleXYZ then begin
     Colors[0]:=SelectionColor;
    end else begin
     Colors[0]:=WhiteColor;
    end;
    if fAction=TAction.ScaleX then begin
     Colors[1]:=SelectionColor;
    end else begin
     Colors[1]:=DirectionColors[0];
    end;
    if fAction=TAction.ScaleY then begin
     Colors[2]:=SelectionColor;
    end else begin
     Colors[2]:=DirectionColors[1];
    end;
    if fAction=TAction.ScaleZ then begin
     Colors[3]:=SelectionColor;
    end else begin
     Colors[3]:=DirectionColors[2];
    end;
   end;
   TOperation.Bounds:begin
   end;
   else {TOperation.None:}begin

   end;
  end;
 end;
 procedure DrawFilledCircle(const aCenter:TpvVector3;const aRadius:TpvFloat;const aColor:TpvVector4;const aSegments:TpvSizeInt);
 begin
  TpvScene3DRendererInstance(fRendererInstance).AddSolidPoint3D(aInFlightFrameIndex,
                                                                 aCenter,
                                                                 aColor,
                                                                 aRadius,
                                                                 TpvVector2.Null,
                                                                 0.0);
 end;
 procedure DrawCircle(const aCenter:TpvVector3;const aRadius:TpvFloat;const aColor:TpvVector4;const aSegments:TpvSizeInt;const aWidth:TpvScalar);
 begin
  TpvScene3DRendererInstance(fRendererInstance).AddSolidPoint3D(aInFlightFrameIndex,
                                                                 aCenter,
                                                                 aColor,
                                                                 aRadius,
                                                                 TpvVector2.Null,
                                                                 aWidth);
 end;
 procedure DrawHatchedAxis(const aAxis:TpvVector3);
 var Index:TpvSizeInt;
 begin
  if aInFlightFrameIndex>=0 then begin
   for Index:=1 to 9 do begin
    TpvScene3DRendererInstance(fRendererInstance).AddSolidLine3D(aInFlightFrameIndex,
                                                                 fModelMatrix.MulHomogen(aAxis*0.05*(Index*2)*fScreenFactor),
                                                                 fModelMatrix.MulHomogen(aAxis*0.05*((Index*2)+1)*fScreenFactor),
                                                                 BlackColor,
                                                                 6.0,
                                                                 TpvVector2.Null,
                                                                 TpvVector2.Null);
   end;
  end;
 end;
 procedure DrawRotationGizmo;
 var AxisIndex,Index:TpvSizeInt;
     CameraToModelNormalized,AxisPos:TpvVector3;
     CirclePos:array[0..HalfCircleSegmentCount] of TpvVector2;
     CirclePos3D:array[0..HalfCircleSegmentCount] of TpvVector3;
     AngleStart,ng:TpvScalar;
 begin
  if fViewMode=TViewMode.Orthographic then begin
   CameraToModelNormalized:=-fInverseViewMatrix.Forwards.xyz;
  end else begin
   CameraToModelNormalized:=(fModelMatrix.Translation.xyz-fInverseViewMatrix.Translation.xyz).Normalize;
  end;
  CameraToModelNormalized:=fInverseModelMatrix.MulBasis(CameraToModelNormalized);
  fRadiusSquareCenter:=ScreenRotateSize*fViewPort.w;
  for AxisIndex:=0 to 2 do begin
   AngleStart:=ArcTan2(CameraToModelNormalized[(4-AxisIndex) mod 3],
                       CameraToModelNormalized[(3-AxisIndex) mod 3])+HalfPI;
   for Index:=0 to HalfCircleSegmentCount-1 do begin
    ng:=AngleStart+(PI*(Index/HalfCircleSegmentCount));
    AxisPos:=TpvVector3.InlineableCreate(cos(ng),sin(ng),0.0);
    CirclePos3D[Index]:=fModelMatrix.MulHomogen(TpvVector3.InlineableCreate(AxisPos[AxisIndex],AxisPos[(AxisIndex+1) mod 3],AxisPos[(AxisIndex+2) mod 3])*fScreenFactor);
    CirclePos[Index]:=WorldToPosition(TpvVector3.InlineableCreate(AxisPos[AxisIndex],AxisPos[(AxisIndex+1) mod 3],AxisPos[(AxisIndex+2) mod 3])*fScreenFactor,fModelViewProjectionMatrix);
   end;
   fRadiusSquareCenter:=Max(fRadiusSquareCenter,
                             WorldToPosition(fModelMatrix.Translation.xyz,fViewProjectionMatrix).DistanceTo(CirclePos[0]));
   if aInFlightFrameIndex>=0 then begin
    for Index:=0 to HalfCircleSegmentCount-2 do begin
     TpvScene3DRendererInstance(fRendererInstance).AddSolidLine3D(aInFlightFrameIndex,
                                                                  CirclePos3D[Index],
                                                                  CirclePos3D[(Index+1) mod HalfCircleSegmentCount],
                                                                  Colors[3-AxisIndex],
                                                                  2.0,
                                                                  TpvVector2.Null,
                                                                  TpvVector2.Null);
    end;
   end;
  end;
  if aInFlightFrameIndex>=0 then begin
   //DrawCircle(fModelMatrix.Translation.xyz,fRadiusSquareCenter,Colors[0],64,3.0);
   begin
    for Index:=0 to HalfCircleSegmentCount do begin
     ng:=TwoPI*(Index/HalfCircleSegmentCount);
     AxisPos:=TpvVector3.InlineableCreate(cos(ng),sin(ng),0.0);
     CirclePos3D[Index]:=fModelMatrix.Translation.xyz+
                         (((fInverseViewMatrix.Right.xyz*AxisPos.x)+
                           (fInverseViewMatrix.Up.xyz*AxisPos.y))*fScreenFactor);
    end;
    for Index:=0 to HalfCircleSegmentCount-1 do begin
     TpvScene3DRendererInstance(fRendererInstance).AddSolidLine3D(aInFlightFrameIndex,
                                                                      CirclePos3D[Index],
                                                                      CirclePos3D[Index+1],
                                                                      Colors[0],
                                                                      3.0,
                                                                      TpvVector2.Null,
                                                                      TpvVector2.Null);
    end;
   end;
   if fUsing then begin
    CirclePos3D[0]:=fModelMatrix.Translation.xyz;
    for Index:=1 to HalfCircleSegmentCount do begin
     ng:=fRotationAngle*((Index-1)/(HalfCircleSegmentCount-1));
     CirclePos3D[Index]:=fModelMatrix.Translation.xyz+
                         ((TpvMatrix3x3.CreateRotate(ng,fTranslationPlane.Normal)*fRotationVectorSource)*fScreenFactor);
    end;
    for Index:=0 to HalfCircleSegmentCount-2 do begin
     TpvScene3DRendererInstance(fRendererInstance).AddSolidTriangle3D(aInFlightFrameIndex,
                                                                      CirclePos3D[0],
                                                                      CirclePos3D[Index+1],
                                                                      CirclePos3D[((Index+1) mod HalfCircleSegmentCount)+1],
                                                                      RotationHalfAlphaColor,
                                                                      TpvVector2.Null,
                                                                      TpvVector2.Null,
                                                                      TpvVector2.Null);
    end;
    TpvScene3DRendererInstance(fRendererInstance).AddSolidLine3D(aInFlightFrameIndex,
                                                                 CirclePos3D[0],
                                                                 CirclePos3D[1],
                                                                 RotationColor,
                                                                 2.0,
                                                                 TpvVector2.Null,
                                                                 TpvVector2.Null);
    for Index:=0 to HalfCircleSegmentCount-2 do begin
     TpvScene3DRendererInstance(fRendererInstance).AddSolidLine3D(aInFlightFrameIndex,
                                                                  CirclePos3D[Index+1],
                                                                  CirclePos3D[((Index+1) mod HalfCircleSegmentCount)+1],
                                                                  RotationColor,
                                                                  2.0,
                                                                  TpvVector2.Null,
                                                                  TpvVector2.Null);
    end;
    TpvScene3DRendererInstance(fRendererInstance).AddSolidLine3D(aInFlightFrameIndex,
                                                                 CirclePos3D[HalfCircleSegmentCount],
                                                                 CirclePos3D[0],
                                                                 RotationColor,
                                                                 2.0,
                                                                 TpvVector2.Null,
                                                                 TpvVector2.Null);
   end;
  end;
 end;
 procedure DrawTranslationGizmo;
 var Index,QuadIndex:TpvSizeInt;
     Origin:TpvVector2;
     BelowAxisLimit,BelowPlaneLimit:boolean;
     DirAxis,DirPlaneX,DirPlaneY,v:TpvVector3;
     BaseSSpace,WorldDirSSpace,Dir,
     OrtogonalDir,a,
     SourcePosOnScreen,
     DestinationPosOnScreen,
     Difference:TpvVector2;
     Quad:array[0..3] of TpvVector3;
 begin
  Origin:=WorldToPosition(fModelMatrix.Translation.xyz,fViewProjectionMatrix);
  BelowAxisLimit:=false;
  BelowPlaneLimit:=false;
  for Index:=0 to 2 do begin
   ComputeTripodAxisAndVisibility(Index,DirAxis,DirPlaneX,DirPlaneY,BelowAxisLimit,BelowPlaneLimit);
   if aInFlightFrameIndex>=0 then begin
    if BelowAxisLimit then begin
     BaseSSpace:=WorldToPosition(DirAxis*0.1*fScreenFactor,fModelViewProjectionMatrix);
     WorldDirSSpace:=WorldToPosition(DirAxis*fScreenFactor,fModelViewProjectionMatrix);
     TpvScene3DRendererInstance(fRendererInstance).AddSolidLine3D(aInFlightFrameIndex,
                                                                  fModelMatrix.MulHomogen(DirAxis*0.1*fScreenFactor),
                                                                  fModelMatrix.MulHomogen(DirAxis*fScreenFactor),
                                                                  Colors[Index+1],
                                                                  3.0,
                                                                  TpvVector2.Null,
                                                                  TpvVector2.Null);
     Dir:=(Origin-WorldDirSSpace).Normalize*6.0;
     OrtogonalDir:=TpvVector2.InlineableCreate(-Dir.y,Dir.x);
     a:=WorldDirSSpace+Dir;
     v:=fModelMatrix.MulHomogen(DirAxis*fScreenFactor);
     TpvScene3DRendererInstance(fRendererInstance).AddSolidTriangle3D(aInFlightFrameIndex,
                                                                      v,
                                                                      v,
                                                                      v,
                                                                      Colors[Index+1],
                                                                      (-Dir)/fViewPort.zw,
                                                                      (Dir+OrtogonalDir)/fViewPort.zw,
                                                                      (Dir-OrtogonalDir)/fViewPort.zw);
     if fAxisFactors[Index]<0.0 then begin
      DrawHatchedAxis(DirAxis);
     end;
    end;
    if BelowPlaneLimit then begin
     for QuadIndex:=0 to 3 do begin
      Quad[QuadIndex]:=fModelMatrix.MulHomogen(((DirPlaneX*QuadUV[QuadIndex*2])+
                                                (DirPlaneY*QuadUV[(QuadIndex*2)+1]))*fScreenFactor);
     end;
     TpvScene3DRendererInstance(fRendererInstance).AddSolidQuad3D(aInFlightFrameIndex,
                                                                  Quad[0],
                                                                  Quad[1],
                                                                  Quad[2],
                                                                  Quad[3],
                                                                  Colors[Index+4],
                                                                  TpvVector2.Null,
                                                                  TpvVector2.Null,
                                                                  TpvVector2.Null,
                                                                  TpvVector2.Null);
     TpvScene3DRendererInstance(fRendererInstance).AddSolidQuad3D(aInFlightFrameIndex,
                                                                  Quad[0],
                                                                  Quad[1],
                                                                  Quad[2],
                                                                  Quad[3],
                                                                  Colors[Index+1],
                                                                  TpvVector2.Null,
                                                                  TpvVector2.Null,
                                                                  TpvVector2.Null,
                                                                  TpvVector2.Null,
                                                                  1.0);
    end;
   end;
  end;
  if aInFlightFrameIndex>=0 then begin
   DrawFilledCircle(fModelMatrix.MulHomogen(TpvVector3.Null),6.0,Colors[0],32);
   if fUsing then begin
    SourcePosOnScreen:=WorldToPosition(fMatrixOrigin,fViewProjectionMatrix);
    DestinationPosOnScreen:=WorldToPosition(fModelMatrix.Translation.xyz,fViewProjectionMatrix);
    Difference:=(DestinationPosOnScreen-SourcePosOnScreen).Normalize*5.0;
    DrawCircle(fMatrixOrigin,6.0,TranslationColor,32,1.0);
    DrawCircle(fModelMatrix.Translation.xyz,6.0,TranslationColor,32,1.0);
    TpvScene3DRendererInstance(fRendererInstance).AddSolidLine3D(aInFlightFrameIndex,
                                                                 fMatrixOrigin,
                                                                 fModelMatrix.Translation.xyz,
                                                                 TranslationColor,
                                                                 2.0,
                                                                 Difference/fViewPort.zw,
                                                                 -Difference/fViewPort.zw);
   end;
  end;
 end;
 procedure DrawScaleGizmo;
 var Index:TpvSizeInt;
     Origin:TpvVector2;
     BelowAxisLimit,BelowPlaneLimit:boolean;
     Scale:TpvVector3;
     DirAxis,DirPlaneX,DirPlaneY:TpvVector3;
     BaseSSpace,WorldDirSSpaceNoScale,WorldDirSSpace:TpvVector2;
 begin
  Origin:=WorldToPosition(fModelMatrix.Translation.xyz,fViewProjectionMatrix);
  if fUsing then begin
   Scale:=fScale;
  end else begin
   Scale:=TpvVector3.InlineableCreate(1.0,1.0,1.0);
  end;
  BelowAxisLimit:=false;
  BelowPlaneLimit:=false;
  for Index:=0 to 2 do begin
   ComputeTripodAxisAndVisibility(Index,DirAxis,DirPlaneX,DirPlaneY,BelowAxisLimit,BelowPlaneLimit);
   if aInFlightFrameIndex>=0 then begin
    if BelowAxisLimit then begin
     BaseSSpace:=WorldToPosition(DirAxis*0.1*fScreenFactor,fModelViewProjectionMatrix);
     WorldDirSSpace:=WorldToPosition(DirAxis*Scale[Index]*fScreenFactor,fModelViewProjectionMatrix);
     if fUsing then begin
      WorldDirSSpaceNoScale:=WorldToPosition(DirAxis*fScreenFactor,fModelViewProjectionMatrix);
      TpvScene3DRendererInstance(fRendererInstance).AddSolidLine3D(aInFlightFrameIndex,
                                                                   fModelMatrix.MulHomogen(DirAxis*0.1*fScreenFactor),
                                                                   fModelMatrix.MulHomogen(DirAxis*fScreenFactor),
                                                                   GrayColor,
                                                                   3.0,
                                                                   TpvVector2.Null,
                                                                   TpvVector2.Null);
      DrawFilledCircle(fModelMatrix.MulHomogen(DirAxis*fScreenFactor),6.0,GrayColor,32);
     end;
     TpvScene3DRendererInstance(fRendererInstance).AddSolidLine3D(aInFlightFrameIndex,
                                                                  fModelMatrix.MulHomogen(DirAxis*0.1*fScreenFactor),
                                                                  fModelMatrix.MulHomogen(DirAxis*Scale[Index]*fScreenFactor),
                                                                  Colors[Index+1],
                                                                  3.0,
                                                                  TpvVector2.Null,
                                                                  TpvVector2.Null);
     DrawFilledCircle(fModelMatrix.MulHomogen(DirAxis*Scale[Index]*fScreenFactor),6.0,Colors[Index+1],32);
     if fAxisFactors[Index]<0.0 then begin
      DrawHatchedAxis(DirAxis*Scale[Index]);
     end;
    end;
   end;
  end;
  if aInFlightFrameIndex>=0 then begin
   DrawFilledCircle(fModelMatrix.MulHomogen(TpvVector3.Null),6.0,Colors[0],32);
  end;
 end;
var v:TpvVector4;
begin
 fMatrix:=aMatrix;
 Update(fOperation=TOperation.Scale);
 if fGraphicsInitialized then begin
  case fViewMode of
   TViewMode.Orthographic:begin
    v:=TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0);
   end;
   TViewMode.Perspective:begin
    v:=fModelViewProjectionMatrix*TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0);
   end;
   else begin
    v:=TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0);
   end;
  end;
  if abs(v.z)<=v.w then begin
   ComputeColors;
   case fOperation of
    TOperation.Rotate:begin
     DrawRotationGizmo;
    end;
    TOperation.Translate:begin
     DrawTranslationGizmo;
    end;
    TOperation.Scale:begin
     DrawScaleGizmo;
    end;
    TOperation.Bounds:begin
    end;
    else {TOperation.None:}begin

    end;
   end;
  end;
 end;
end;

function TpvScene3DGizmo.MouseAction(const aMatrix:TpvMatrix4x4;
                                     const aMousePosition:TpvVector2;
                                     const aMouseAction:TMouseAction;
                                     const aDeltaMatrix:PpvMatrix4x4;
                                     const aNewMatrix:PpvMatrix4x4):boolean;
 function ComputeAngleOnPlane:TpvScalar;
 var LocalPos,PerpendicularVector:TpvVector3;
 begin
  LocalPos:=((fRayOrigin+(fRayDirection*IntersectRayPlane(fRayOrigin,fRayDirection,fTranslationPlane)))-fModelMatrix.Translation.xyz).Normalize;
  PerpendicularVector:=fRotationVectorSource.Cross(fTranslationPlane.Normal).Normalize;
  result:=ArcCos(Clamp(LocalPos.Dot(fRotationVectorSource),-1.0,1.0));
  if LocalPos.Dot(PerpendicularVector)>=0.0 then begin
   result:=-result;
  end;
 end;
 procedure SetupRotate;
 var Index:TpvSizeInt;
     RotatePlaneNormals:array[0..3] of TpvVector3;
 begin
  RotatePlaneNormals[0]:=fModelMatrix.Right.xyz;
  RotatePlaneNormals[1]:=fModelMatrix.Up.xyz;
  RotatePlaneNormals[2]:=fModelMatrix.Forwards.xyz;
  RotatePlaneNormals[3]:=-fInverseViewMatrix.Forwards.xyz;
  case fAction of
   TAction.RotateScreen:begin
    Index:=3;
   end;
   TAction.RotateX:begin
    Index:=0;
   end;
   TAction.RotateY:begin
    Index:=1;
   end;
   else {TAction.RotateZ:}begin
    Index:=2;
   end;
  end;
  if fMode=TMode.Local then begin
   fTranslationPlane:=TpvPlane.Create(RotatePlaneNormals[Index],-RotatePlaneNormals[Index].Dot(fModelMatrix.Translation.xyz));
  end else begin
   fTranslationPlane:=TpvPlane.Create(DirectionUnary[Index],-DirectionUnary[Index].Dot(fModelSourceMatrix.Translation.xyz));
  end;
  fRotationVectorSource:=((fRayOrigin+(fRayDirection*IntersectRayPlane(fRayOrigin,fRayDirection,fTranslationPlane)))-fModelMatrix.Translation.xyz).Normalize;
  fRotationAngleOrigin:=ComputeAngleOnPlane;
 end;
 procedure ProcessRotate;
 var RotationAxisLocalSpace:TpvVector3;
     RotationMatrix,ScaleOriginMatrix,NewMatrix:TpvMatrix4x4;
 begin
  fRotationAngle:=ComputeAngleOnPlane;
  RotationAxisLocalSpace:=fInverseModelMatrix.MulBasis(fTranslationPlane.Normal).Normalize;
  RotationMatrix:=TpvMatrix4x4.CreateRotate(fRotationAngle-fRotationAngleOrigin,RotationAxisLocalSpace);
  ScaleOriginMatrix:=TpvMatrix4x4.CreateScale(fModelScaleOrigin);
  fRotationAngleOrigin:=fRotationAngle;
  if assigned(aNewMatrix) then begin
   if fMode=TMode.Local then begin
    NewMatrix:=ScaleOriginMatrix*RotationMatrix*fModelLocalMatrix;
   end else begin
    NewMatrix:=fModelSourceMatrix;
    NewMatrix.Translation.xyz:=TpvVector3.Null;
    NewMatrix:=NewMatrix*RotationMatrix;
    NewMatrix.Translation.xyz:=fModelSourceMatrix.Translation.xyz;
   end;
   aNewMatrix^:=NewMatrix;
  end;
  if assigned(aDeltaMatrix) then begin
   aDeltaMatrix^:=fInverseModelMatrix*(RotationMatrix*fModelMatrix);
  end;
 end;
 procedure SetupMove;
 var Index:TpvSizeInt;
     MovePlaneNormals:array[0..6] of TpvVector3;
     CameraToModelNormalized:TpvVector3;
 begin
  MovePlaneNormals[0]:=fModelMatrix.Right.xyz;
  MovePlaneNormals[1]:=fModelMatrix.Up.xyz;
  MovePlaneNormals[2]:=fModelMatrix.Forwards.xyz;
  MovePlaneNormals[3]:=fModelMatrix.Right.xyz;
  MovePlaneNormals[4]:=fModelMatrix.Up.xyz;
  MovePlaneNormals[5]:=fModelMatrix.Forwards.xyz;
  MovePlaneNormals[6]:=-fInverseViewMatrix.Forwards.xyz;
  CameraToModelNormalized:=(fMatrix.Translation.xyz-fInverseViewMatrix.Translation.xyz).Normalize;
  for Index:=0 to 2 do begin
   MovePlaneNormals[Index]:=MovePlaneNormals[Index].Cross(MovePlaneNormals[Index].Cross(CameraToModelNormalized)).Normalize;
  end;
  case fAction of
   TAction.MoveScreen:begin
    Index:=6;
   end;
   TAction.MoveX:begin
    Index:=0;
   end;
   TAction.MoveY:begin
    Index:=1;
   end;
   TAction.MoveZ:begin
    Index:=2;
   end;
   TAction.MoveYZ:begin
    Index:=3;
   end;
   TAction.MoveZX:begin
    Index:=4;
   end;
   TAction.MoveXY:begin
    Index:=5;
   end;
  end;
  fTranslationPlane:=TpvPlane.Create(MovePlaneNormals[Index],-MovePlaneNormals[Index].Dot(fMatrix.Translation.xyz));
  fTranslationPlaneOrigin:=fRayOrigin+(fRayDirection*IntersectRayPlane(fRayOrigin,fRayDirection,fTranslationPlane));
  fMatrixOrigin:=fMatrix.Translation.xyz;
  fRelativeOrigin:=(fTranslationPlaneOrigin-fMatrixOrigin)/fScreenFactor;
 end;
 procedure ProcessMove;
 var Delta,Axis:TpvVector3;
 begin
  Delta:=(fRayOrigin+(fRayDirection*abs(IntersectRayPlane(fRayOrigin,fRayDirection,fTranslationPlane))))-
         (fMatrix.Translation.xyz+(fRelativeOrigin*fScreenFactor));
  case fAction of
   TAction.MoveX,TAction.MoveY,TAction.MoveZ:begin
    case fAction of
     TAction.MoveX:begin
      Axis:=fModelMatrix.Right.xyz;
     end;
     TAction.MoveY:begin
      Axis:=fModelMatrix.Up.xyz;
     end;
     else {TAction.MoveZ:}begin
      Axis:=fModelMatrix.Forwards.xyz;
     end;
    end;
    Delta:=Axis.Dot(Delta)*Axis;
   end;
  end;
  if assigned(aDeltaMatrix) then begin
   aDeltaMatrix^:=TpvMatrix4x4.CreateTranslation(Delta);
  end;
  if assigned(aNewMatrix) then begin
   aNewMatrix^:=fMatrix;
   aNewMatrix^.Translation.xyz:=aNewMatrix^.Translation.xyz+Delta;
  end;
 end;
 procedure SetupScale;
 var Index:TpvSizeInt;
     MovePlaneNormals:array[0..6] of TpvVector3;
     CameraToModelNormalized:TpvVector3;
 begin
  MovePlaneNormals[0]:=fModelMatrix.Right.xyz;
  MovePlaneNormals[1]:=fModelMatrix.Up.xyz;
  MovePlaneNormals[2]:=fModelMatrix.Forwards.xyz;
  MovePlaneNormals[3]:=fModelMatrix.Right.xyz;
  MovePlaneNormals[4]:=fModelMatrix.Up.xyz;
  MovePlaneNormals[5]:=fModelMatrix.Forwards.xyz;
  MovePlaneNormals[6]:=-fInverseViewMatrix.Forwards.xyz;
  CameraToModelNormalized:=(fModelMatrix.Translation.xyz-fInverseViewMatrix.Translation.xyz).Normalize;
  for Index:=0 to 2 do begin
   MovePlaneNormals[Index]:=MovePlaneNormals[Index].Cross(MovePlaneNormals[Index].Cross(CameraToModelNormalized)).Normalize;
  end;
  case fAction of
   TAction.ScaleXYZ:begin
    Index:=3;
   end;
   TAction.ScaleX:begin
    Index:=0;
   end;
   TAction.ScaleY:begin
    Index:=1;
   end;
   TAction.ScaleZ:begin
    Index:=2;
   end;
  end;
  fTranslationPlane:=TpvPlane.Create(MovePlaneNormals[Index],-MovePlaneNormals[Index].Dot(fModelMatrix.Translation.xyz));
  fTranslationPlaneOrigin:=fRayOrigin+(fRayDirection*IntersectRayPlane(fRayOrigin,fRayDirection,fTranslationPlane));
  fMatrixOrigin:=fModelMatrix.Translation.xyz;
  fScale:=TpvVector3.InlineableCreate(1.0,1.0,1.0);
  fRelativeOrigin:=(fTranslationPlaneOrigin-fMatrixOrigin)/fScreenFactor;
  fScaleValueOrigin:=TpvVector3.InlineableCreate(fModelSourceMatrix.Right.xyz.Length,
                                                 fModelSourceMatrix.Up.xyz.Length,
                                                 fModelSourceMatrix.Forwards.xyz.Length);
  fSaveMousePosition:=fMousePosition;
 end;
 procedure ProcessScale;
 var Delta,Axis,BaseVector:TpvVector3;
     Ratio:TpvScalar;
     DeltaMatrixScale:TpvMatrix4x4;
 begin
  Delta:=(fRayOrigin+(fRayDirection*abs(IntersectRayPlane(fRayOrigin,fRayDirection,fTranslationPlane))))-
         (fModelLocalMatrix.Translation.xyz+(fRelativeOrigin*fScreenFactor));
  case fAction of
   TAction.ScaleX,TAction.ScaleY,TAction.ScaleZ:begin
    case fAction of
     TAction.ScaleX:begin
      Axis:=fModelLocalMatrix.Right.xyz;
     end;
     TAction.ScaleY:begin
      Axis:=fModelLocalMatrix.Up.xyz;
     end;
     else {TAction.ScaleZ:}begin
      Axis:=fModelLocalMatrix.Forwards.xyz;
     end;
    end;
    Delta:=Axis.Dot(Delta)*Axis;
    BaseVector:=fTranslationPlaneOrigin-fModelLocalMatrix.Translation.xyz;
    Ratio:=Axis.Dot(BaseVector+Delta)/Axis.Dot(BaseVector);
    case fAction of
     TAction.ScaleX:begin
      fScale.x:=Max(Ratio,1e-3);
     end;
     TAction.ScaleY:begin
      fScale.y:=Max(Ratio,1e-3);
     end;
     else {TAction.ScaleZ:}begin
      fScale.z:=Max(Ratio,1e-3);
     end;
    end;
   end;
   else {TAction.ScaleXYZ:}begin
    fScale:=TpvVector3.AllAxis*Max(1.0+(((fMousePosition.x-fSaveMousePosition.x)+(fMousePosition.y-fSaveMousePosition.y))*1e-2),1e-3);
   end;
  end;
  fScale.x:=Max(fScale.x,1e-3);
  fScale.y:=Max(fScale.y,1e-3);
  fScale.z:=Max(fScale.z,1e-3);
  DeltaMatrixScale:=TpvMatrix4x4.CreateScale(fScale*fScaleValueOrigin);
  if assigned(aDeltaMatrix) then begin
   aDeltaMatrix^:=TpvMatrix4x4.CreateScale((fScale*fScaleValueOrigin)/fModelScaleOrigin);
  end;
  if assigned(aNewMatrix) then begin
   aNewMatrix^:=DeltaMatrixScale*fModelLocalMatrix;
  end;
 end;
var v:TpvVector4;
begin
 fMatrix:=aMatrix;
 fMousePosition:=aMousePosition;
 Update(fOperation=TOperation.Scale);
 if assigned(aDeltaMatrix) then begin
  aDeltaMatrix^:=TpvMatrix4x4.Identity;
 end;
 if assigned(aNewMatrix) then begin
  aNewMatrix^:=fMatrix;
 end;
 case fViewMode of
  TViewMode.Orthographic:begin
   v:=TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0);
  end;
  TViewMode.Perspective:begin
   v:=fModelViewProjectionMatrix*TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0);
  end;
  else begin
   v:=TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0);
  end;
 end;
 if abs(v.z)<=v.w then begin
  case fOperation of
   TOperation.Rotate:begin
    case aMouseAction of
     TMouseAction.Check:begin
      fAction:=GetRotateAction;
      result:=fAction<>TAction.None;
     end;
     TMouseAction.Down:begin
      Draw(-1,fMatrix);
      fAction:=GetRotateAction;
      result:=fAction<>TAction.None;
      fUsing:=result;
      SetupRotate;
      Draw(-1,fMatrix);
     end;
     TMouseAction.Move:begin
      result:=fAction<>TAction.None;
      case fAction of
       TAction.RotateScreen,
       TAction.RotateX,
       TAction.RotateY,
       TAction.RotateZ:begin
        ProcessRotate;
       end;
      end;
     end;
     TMouseAction.Up:begin
      result:=fAction<>TAction.None;
      fUsing:=false;
      fAction:=TAction.None;
     end;
    end;
   end;
   TOperation.Translate:begin
    case aMouseAction of
     TMouseAction.Check:begin
      fAction:=GetMoveAction;
      result:=fAction<>TAction.None;
     end;
     TMouseAction.Down:begin
      Draw(-1,fMatrix);
      fAction:=GetMoveAction;
      result:=fAction<>TAction.None;
      fUsing:=result;
      SetupMove;
      Draw(-1,fMatrix);
     end;
     TMouseAction.Move:begin
      result:=fAction<>TAction.None;
      case fAction of
       TAction.MoveScreen,
       TAction.MoveX,
       TAction.MoveY,
       TAction.MoveZ,
       TAction.MoveYZ,
       TAction.MoveZX,
       TAction.MoveXY:begin
        ProcessMove;
       end;
      end;
     end;
     TMouseAction.Up:begin
      result:=fAction<>TAction.None;
      fUsing:=false;
      fAction:=TAction.None;
     end;
    end;
   end;
   TOperation.Scale:begin
    case aMouseAction of
     TMouseAction.Check:begin
      fAction:=GetScaleAction;
      result:=fAction<>TAction.None;
     end;
     TMouseAction.Down:begin
      Draw(-1,fMatrix);
      fAction:=GetScaleAction;
      result:=fAction<>TAction.None;
      fUsing:=result;
      SetupScale;
      Draw(-1,fMatrix);
     end;
     TMouseAction.Move:begin
      result:=fAction<>TAction.None;
      case fAction of
       TAction.ScaleXYZ,
       TAction.ScaleX,
       TAction.ScaleY,
       TAction.ScaleZ:begin
        ProcessScale;
       end;
      end;
     end;
     TMouseAction.Up:begin
      result:=fAction<>TAction.None;
      fUsing:=false;
      fAction:=TAction.None;
     end;
    end;
   end;
   TOperation.Bounds:begin
    fAction:=TAction.None;
    result:=false;
   end;
   else {TOperation.None:}begin
    fAction:=TAction.None;
    result:=false;
   end;
  end;
 end else begin
  fAction:=TAction.None;
  result:=false;
 end;
end;

end.
