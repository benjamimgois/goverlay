unit UnitMath3D; // Copyright (C) 2006-2017, Benjamin Rosseaux - License: zlib
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
 {$define caninline}
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
 {$define caninline}
{$else}
 {$undef caninline}
 {$ifdef ver180}
  {$define caninline}
 {$else}
  {$ifdef conditionalexpressions}
   {$if compilerversion>=18}
    {$define caninline}
   {$ifend}
  {$endif}
 {$endif}
{$endif}

{$ifdef cpu386}
 {$define cpu386asm}
{$endif}

{$undef SIMD}
{$ifdef cpu386asm}
 {$define SIMD}
{$endif}

interface

uses Math;

const EPSILON:single=1e-12;
      INFINITY:single=1e+30;

      AABBEPSILON=1e-12;
      SPHEREEPSILON=1e-12;

      DEG2RAD=PI/180;
      RAD2DEG=180/PI;

      DISTANCE_EPSILON:single=1E-12;

type PVector2=^TVector2;
     TVector2=record
      case byte of
       0:(x,y:single);
       1:(u,v:single);
       2:(s,t:single);
       3:(xy:array[0..1] of single);
       4:(uv:array[0..1] of single);
       5:(st:array[0..1] of single);
     end;

     PVector2i=^TVector2i;
     TVector2i=record
      case byte of
       0:(x,y:longint);
       1:(u,v:longint);
       2:(s,t:longint);
       3:(xy:array[0..1] of longint);
       4:(uv:array[0..1] of longint);
       5:(st:array[0..1] of longint);
     end;

     PVector2ui=^TVector2ui;
     TVector2ui=record
      case byte of
       0:(x,y:longword);
       1:(u,v:longword);
       2:(s,t:longword);
       3:(xy:array[0..1] of longword);
       4:(uv:array[0..1] of longword);
       5:(st:array[0..1] of longword);
     end;

     PVector2w=^TVector2w;
     TVector2w=record
      case byte of
       0:(x,y:word);
       1:(u,v:word);
       2:(s,t:word);
       3:(xy:array[0..1] of word);
       4:(uv:array[0..1] of word);
       5:(st:array[0..1] of word);
     end;

     PVector2b=^TVector2b;
     TVector2b=record
      case byte of
       0:(x,y:byte);
       1:(u,v:byte);
       2:(s,t:byte);
       3:(xy:array[0..1] of byte);
       4:(uv:array[0..1] of byte);
       5:(st:array[0..1] of byte);
     end;

     PVector3=^TVector3;
     TVector3=packed record
      case byte of
       0:(x,y,z:single);
       1:(r,g,b:single);
       2:(Pitch,Yaw,Roll:single);
       3:(xyz:array[0..2] of single);
       4:(rgb:array[0..2] of single);
       5:(PitchYawRoll:array[0..2] of single);
     end;

     TVector3Array=array of TVector3;

     PVector3s=^TVector3s;
     TVector3s=array[0..$ff] of TVector3;

     PPVector3s=^TPVector3s;
     TPVector3s=array[0..$ff] of PVector3;

     PSIMDVector3=^TSIMDVector3;
     TSIMDVector3=packed record
{$ifdef SIMD}
      case byte of
       0:(x,y,z,w:single);
       1:(xyz:array[0..2] of single);
       2:(xyzw:array[0..3] of single);
       3:(Vector:TVector3);
{$else}
      case byte of
       0:(x,y,z:single);
       1:(xyz:array[0..2] of single);
       2:(Vector:TVector3);
{$endif}
     end;

     TSIMDVector3Array=array of TSIMDVector3;

     PSIMDVector3s=^TSIMDVector3s;
     TSIMDVector3s=array[0..$ff] of TSIMDVector3;

     PPSIMDVector3s=^TPSIMDVector3s;
     TPSIMDVector3s=array[0..$ff] of PSIMDVector3;

     PVector3i=^TVector3i;
     TVector3i=packed record
      case byte of
       0:(x,y,z:longint);
       1:(r,g,b:longint);
       2:(xyz:array[0..2] of longint);
       3:(rgb:array[0..2] of longint);
     end;

     PVector3w=^TVector3w;
     TVector3w=packed record
      case byte of
       0:(x,y,z:word);
       1:(r,g,b:word);
       2:(xyz:array[0..2] of word);
       3:(rgb:array[0..2] of word);
     end;

     PVector3b=^TVector3b;
     TVector3b=packed record
      case byte of
       0:(x,y,z:byte);
       1:(r,g,b:byte);
       2:(xyz:array[0..2] of byte);
       3:(rgb:array[0..2] of byte);
     end;

     PVector3d=^TVector3d;
     TVector3d=packed record
      case byte of
       0:(x,y,z:double);
       1:(r,g,b:double);
       2:(xyz:array[0..2] of double);
       3:(rgb:array[0..2] of double);
     end;

     PVector4=^TVector4;
     TVector4=packed record
      case byte of
       0:(x,y,z,w:single);
       1:(r,g,b,a:single);
       2:(xyzw:array[0..3] of single);
       3:(rgba:array[0..3] of single);
     end;

     PVector4i=^TVector4i;
     TVector4i=packed record
      case byte of
       0:(x,y,z,w:longint);
       1:(r,g,b,a:longint);
       2:(xyzw:array[0..3] of longint);
       3:(rgba:array[0..3] of longint);
     end;

     PVector4u=^TVector4u;
     TVector4u=packed record
      case byte of
       0:(x,y,z,w:longword);
       1:(r,g,b,a:longword);
       2:(xyzw:array[0..3] of longword);
       3:(rgba:array[0..3] of longword);
     end;

     PVector4w=^TVector4w;
     TVector4w=packed record
      case byte of
       0:(x,y,z,w:word);
       1:(r,g,b,a:word);
       2:(xyzw:array[0..3] of word);
       3:(rgba:array[0..3] of word);
     end;

     PVector4b=^TVector4b;
     TVector4b=packed record
      case byte of
       0:(x,y,z,w:byte);
       1:(r,g,b,a:byte);
       2:(xyzw:array[0..3] of byte);
       3:(rgba:array[0..3] of byte);
     end;

     PPlane=^TPlane;
     TPlane=packed record
      case longint of
       0:(a,b,c,d:single);
       1:(Normal:TVector3;Distance:single);
       2:(xyzw:TVector4);
      end;

     PQuaternion=^TQuaternion;
     TQuaternion=record
      case longint of
       0:(x,y,z,w:single);
       1:(Vector:TVector3;Scalar:single);
       2:(xyzw:array[0..3] of single);
     end;

     PSphereCoords=^TSphereCoords;
     TSphereCoords=record
      Radius,Theta,Phi:single;
     end;

     PMatrix2x2=^TMatrix2x2;
     TMatrix2x2=array[0..1,0..1] of single;

     PMatrix3x2=^TMatrix3x2;
     TMatrix3x2=array[0..2,0..1] of single;

     PMatrix3x3=^TMatrix3x3;
     TMatrix3x3=array[0..2,0..2] of single;

     PMatrix3x4=^TMatrix3x4;
     TMatrix3x4=array[0..2,0..3] of single;

     PMatrix4x4=^TMatrix4x4;
     TMatrix4x4=array[0..3,0..3] of single;

     PMatrix4x3=^TMatrix4x3;
     TMatrix4x3=array[0..3,0..2] of single;

     PAABB=^TAABB;
     TAABB=packed record
      case boolean of
       false:(
        Min,Max:TVector3;
       );
       true:(
        MinMax:array[0..1] of TVector3;
       );
     end;

     PAABBs=^TAABBs;
     TAABBs=array[0..65535] of TAABB;

     POBB=^TOBB;
     TOBB=packed record
      Center:TVector3;
      Extents:TVector3;
      case longint of
       0:(
        Axis:array[0..2] of TVector3;
       );
       1:(
        Matrix:TMatrix3x3;
       );
     end;

     POBBs=^TOBBs;
     TOBBs=array[0..65535] of TOBB;

     PSphere=^TSphere;
     TSphere=packed record
      case longint of
       0:(
        Center:TVector3;
        Radius:single;
       );
       1:(
        xyzw:TVector4;
       );
     end;

     PSpheres=^TSpheres;
     TSpheres=array[0..65535] of TSphere;

     PCapsule=^TCapsule;
     TCapsule=packed record
      LineStartPoint:TVector3;
      LineEndPoint:TVector3;
      Radius:single;
     end;

     PSegment=^TSegment;
     TSegment=record
      Origin:TVector3;
      Delta:TVector3;
     end;

     PSegmentTriangle=^TSegmentTriangle;
     TSegmentTriangle=record
      Origin:TVector3;
      Edge0:TVector3;
      Edge1:TVector3;
      Edge2:TVector3;
     end;

     PTriangle=^TTriangle;
     TTriangle=record
      Vertices:array[0..2] of TVector3;
      Normal:TVector3;
     end;

     PSIMDSegment=^TSIMDSegment;
     TSIMDSegment=record
      Points:array[0..1] of TSIMDVector3;
     end;

     PSIMDTriangle=^TSIMDTriangle;
     TSIMDTriangle=record
      Points:array[0..2] of TSIMDVector3;
      Normal:TSIMDVector3;
     end;

     TClipRect=array[0..3] of longint;

     TFloatClipRect=array[0..3] of single;

     PFloats=^TFloats;
     TFloats=array[0..$ffff] of single;

     PLongints=^TLongints;
     TLongints=array[0..$ffff] of longint;

     PPlanes=^TPlanes;
     TPlanes=array[0..5] of TPlane;

     PMinkowskiDescription=^TMinkowskiDescription;
     TMinkowskiDescription=record
      HalfAxis:TVector4;
      Position_LM:TVector3;
     end;

const Vector2Origin:TVector2=(x:0.0;y:0.0);
      Vector2XAxis:TVector2=(x:1.0;y:0.0);
      Vector2YAxis:TVector2=(x:0.0;y:1.0);
      Vector2ZAxis:TVector2=(x:0.0;y:0.0);

      Vector3Origin:TVector3=(x:0.0;y:0.0;z:0.0);
      Vector3XAxis:TVector3=(x:1.0;y:0.0;z:0.0);
      Vector3YAxis:TVector3=(x:0.0;y:1.0;z:0.0);
      Vector3ZAxis:TVector3=(x:0.0;y:0.0;z:1.0);
      Vector3All:TVector3=(x:1.0;y:1.0;z:1.0);

{$ifdef SIMD}
      SIMDVector3Origin:TSIMDVector3=(x:0.0;y:0.0;z:0.0;w:0.0);
      SIMDVector3XAxis:TSIMDVector3=(x:1.0;y:0.0;z:0.0;w:0.0);
      SIMDVector3YAxis:TSIMDVector3=(x:0.0;y:1.0;z:0.0;w:0.0);
      SIMDVector3ZAxis:TSIMDVector3=(x:0.0;y:0.0;z:1.0;w:0.0);
      SIMDVector3All:TSIMDVector3=(x:1.0;y:1.0;z:1.0;w:0.0);
{$else}
      SIMDVector3Origin:TSIMDVector3=(x:0.0;y:0.0;z:0.0);
      SIMDVector3XAxis:TSIMDVector3=(x:1.0;y:0.0;z:0.0);
      SIMDVector3YAxis:TSIMDVector3=(x:0.0;y:1.0;z:0.0);
      SIMDVector3ZAxis:TSIMDVector3=(x:0.0;y:0.0;z:1.0);
      SIMDVector3All:TSIMDVector3=(x:1.0;y:1.0;z:1.0);
{$endif}

      Vector4Origin:TVector4=(x:0.0;y:0.0;z:0.0;w:1.0);
      Vector4XAxis:TVector4=(x:1.0;y:0.0;z:0.0;w:1.0);
      Vector4YAxis:TVector4=(x:0.0;y:1.0;z:0.0;w:1.0);
      Vector4ZAxis:TVector4=(x:0.0;y:0.0;z:1.0;w:1.0);

      Matrix2x2Identity:TMatrix2x2=((1.0,0.0),(0.0,1.0));
      Matrix2x2Null:TMatrix2x2=((0.0,0.0),(0.0,0.0));

      Matrix3x2Identity:TMatrix3x2=((1.0,0.0),(0.0,1.0),(0.0,0.0));
      Matrix3x2Null:TMatrix3x2=((0.0,0.0),(0.0,0.0),(0.0,0.0));

      Matrix3x3Identity:TMatrix3x3=((1.0,0.0,0.0),(0.0,1.0,0.0),(0.0,0.0,1.0));
      Matrix3x3Null:TMatrix3x3=((0.0,0.0,0.0),(0.0,0.0,0.0),(0.0,0.0,0.0));

      Matrix3x4Identity:TMatrix3x4=((1.0,0.0,0.0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,1.0,0.0));
      Matrix3x4Null:TMatrix3x4=((0.0,0.0,0.0,0.0),(0.0,0.0,0.0,0.0),(0.0,0.0,0.0,0.0));

      Matrix4x4Identity:TMatrix4x4=((1.0,0.0,0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,1.0,0.0),(0.0,0.0,0,1.0));
      Matrix4x4RightToLeftHanded:TMatrix4x4=((1.0,0.0,0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,-1.0,0.0),(0.0,0.0,0,1.0));
      Matrix4x4Flip:TMatrix4x4=((0.0,0.0,-1.0,0.0),(-1.0,0.0,0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,0,1.0));
      Matrix4x4InverseFlip:TMatrix4x4=((0.0,-1.0,0.0,0.0),(0.0,0.0,1.0,0.0),(-1.0,0.0,0,0.0),(0.0,0.0,0,1.0));
      Matrix4x4FlipYZ:TMatrix4x4=((1.0,0.0,0,0.0),(0.0,0.0,1.0,0.0),(0.0,-1.0,0.0,0.0),(0.0,0.0,0,1.0));
      Matrix4x4InverseFlipYZ:TMatrix4x4=((1.0,0.0,0,0.0),(0.0,0.0,-1.0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,0,1.0));
      Matrix4x4Null:TMatrix4x4=((0.0,0.0,0,0.0),(0.0,0.0,0,0.0),(0.0,0.0,0,0.0),(0.0,0.0,0,0.0));
      Matrix4x4NormalizedSpace:TMatrix4x4=((2.0,0.0,0,0.0),(0.0,2.0,0.0,0.0),(0.0,0.0,2.0,0.0),(-1.0,-1.0,-1.0,1.0));

      QuaternionIdentity:TQuaternion=(x:0.0;y:0.0;z:0.0;w:1.0);

      InvalidAABB:TAABB=(Min:(x:Math.Infinity;y:Math.Infinity;z:Math.Infinity);Max:(x:-Math.Infinity;y:-Math.Infinity;z:-Math.Infinity));

function RoundUpToPowerOfTwo(x:longword):longword; {$ifdef caninline}inline;{$endif}

function Modulo(x,y:single):single; {$ifdef caninline}inline;{$endif}
function ModuloPos(x,y:single):single; {$ifdef caninline}inline;{$endif}
function IEEERemainder(x,y:single):single; {$ifdef caninline}inline;{$endif}
function Modulus(x,y:single):single; {$ifdef caninline}inline;{$endif}

function GetSign(x:single):longint; {$ifdef caninline}inline;{$endif}
function GetSignEx(x:single):longint; {$ifdef caninline}inline;{$endif}
function Sign(x:single):longint; {$ifdef caninline}inline;{$endif}
{function POW(Number,Exponent:single):single; assembler; pascal;
function TAN(Angle:single):single;
function ArcTan2(y,x:single):single;
function ArcCos(x:single):single;
function ArcSin(x:single):single;}
function Determinant4x4(const v0,v1,v2,v3:TVector4):single; {$ifdef caninline}inline;{$endif}
function SolveQuadraticRoots(const a,b,c:single;out t1,t2:single):boolean; {$ifdef caninline}inline;{$endif}
function LinearPolynomialRoot(const a,b:single):single; {$ifdef caninline}inline;{$endif}
function QuadraticPolynomialRoot(const a,b,c:single):single; {$ifdef caninline}inline;{$endif}
function CubicPolynomialRoot(const a,b,c,d:single):single;
function Vector2(x,y:single):TVector2; {$ifdef caninline}inline;{$endif}
function Vector3(x,y,z:single):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3(const v:TSIMDVector3):TVector3; overload; {$ifdef caninline}inline;{$endif}
procedure Vector3(out o:TVector3;const v:TSIMDVector3); overload; {$ifdef caninline}inline;{$endif}
function Vector3(const v:TVector4):TVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3(x,y,z:single):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3(const v:TVector3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
procedure SIMDVector3(out o:TSIMDVector3;const v:TVector3); overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3(const v:TVector4):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector4(x,y,z:single;w:single=1.0):TVector4; overload; {$ifdef caninline}inline;{$endif}
function Vector4(const v:TVector2;z:single=0.0;w:single=1.0):TVector4; overload; {$ifdef caninline}inline;{$endif}
function Vector4(const v:TVector3;w:single=1.0):TVector4; overload; {$ifdef caninline}inline;{$endif}
function Matrix3x3(const XX,XY,XZ,YX,YY,YZ,ZX,ZY,ZZ:single):TMatrix3x3; overload;
function Matrix3x3(const x,y,z:TVector3):TMatrix3x3; overload;
function Matrix3x3(const m:TMatrix4x4):TMatrix3x3; overload;
function Matrix3x3Raw(const XX,XY,XZ,YX,YY,YZ,ZX,ZY,ZZ:single):TMatrix3x3;
function Matrix3x4(const m:TMatrix3x3):TMatrix3x4; overload;
procedure Matrix3x4(out o:TMatrix3x4;const m:TMatrix3x3); overload;
function Matrix4x4(const XX,xy,XZ,XW,YX,YY,YZ,YW,ZX,ZY,ZZ,ZW,WX,WY,WZ,WW:single):TMatrix4x4; overload;
function Matrix4x4(const x,y,z,w:TVector4):TMatrix4x4; overload;
function Matrix4x4(const m:TMatrix3x3):TMatrix4x4; overload;
function Matrix4x4Raw(const XX,xy,XZ,XW,YX,YY,YZ,YW,ZX,ZY,ZZ,ZW,WX,WY,WZ,WW:single):TMatrix4x4;
function Plane(a,b,c,d:single):TPlane; overload; {$ifdef caninline}inline;{$endif}
function Plane(Normal:TVector3;Distance:single):TPlane; overload; {$ifdef caninline}inline;{$endif}
function Quaternion(w,x,y,z:single):TQuaternion; {$ifdef caninline}inline;{$endif}
function Angles(Pitch,Yaw,Roll:single):TVector3; {$ifdef caninline}inline;{$endif}
function FloatLerp(const v1,v2,w:single):single; {$ifdef caninline}inline;{$endif}

function Vector2Compare(const v1,v2:TVector2):boolean; {$ifdef caninline}inline;{$endif}
function Vector2CompareEx(const v1,v2:TVector2;const Threshold:single=1e-12):boolean; {$ifdef caninline}inline;{$endif}
function Vector2Add(const v1,v2:TVector2):TVector2; {$ifdef caninline}inline;{$endif}
function Vector2Sub(const v1,v2:TVector2):TVector2; {$ifdef caninline}inline;{$endif}
function Vector2Avg(const v1,v2:TVector2):TVector2; {$ifdef caninline}inline;{$endif}
function Vector2ScalarMul(const v:TVector2;s:single):TVector2; {$ifdef caninline}inline;{$endif}
function Vector2Dot(const v1,v2:TVector2):single; {$ifdef caninline}inline;{$endif}
function Vector2Neg(const v:TVector2):TVector2; {$ifdef caninline}inline;{$endif}
procedure Vector2Scale(var v:TVector2;s:single); overload; {$ifdef caninline}inline;{$endif}
procedure Vector2Scale(var v:TVector2;sx,sy:single); overload; {$ifdef caninline}inline;{$endif}
function Vector2Mul(const v1,v2:TVector2):TVector2; {$ifdef caninline}inline;{$endif}
function Vector2Length(const v:TVector2):single; {$ifdef caninline}inline;{$endif}
function Vector2Dist(const v1,v2:TVector2):single; {$ifdef caninline}inline;{$endif}
function Vector2LengthSquared(const v:TVector2):single; {$ifdef caninline}inline;{$endif}
function Vector2Angle(const v1,v2,v3:TVector2):single; {$ifdef caninline}inline;{$endif}
procedure Vector2Normalize(var v:TVector2); {$ifdef caninline}inline;{$endif}
function Vector2Norm(const v:TVector2):TVector2; {$ifdef caninline}inline;{$endif}
procedure Vector2Rotate(var v:TVector2;a:single); overload; {$ifdef caninline}inline;{$endif}
procedure Vector2Rotate(var v:TVector2;const Center:TVector2;a:single); overload; {$ifdef caninline}inline;{$endif}
procedure Vector2MatrixMul(var v:TVector2;const m:TMatrix2x2); {$ifdef caninline}inline;{$endif}
function Vector2TermMatrixMul(const v:TVector2;const m:TMatrix2x2):TVector2; {$ifdef caninline}inline;{$endif}
function Vector2Lerp(const v1,v2:TVector2;w:single):TVector2; {$ifdef caninline}inline;{$endif}

function Vector3Flip(const v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3Abs(const v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3Compare(const v1,v2:TVector3):boolean; {$ifdef caninline}inline;{$endif}
function Vector3CompareEx(const v1,v2:TVector3;const Threshold:single=1e-12):boolean; {$ifdef caninline}inline;{$endif}
function Vector3DirectAdd(var v1:TVector3;const v2:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3DirectSub(var v1:TVector3;const v2:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3Add(const v1,v2:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3Sub(const v1,v2:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3Avg(const v1,v2:TVector3):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3Avg(const v1,v2,v3:TVector3):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3Avg(const va:PVector3s;Count:longint):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3ScalarMul(const v:TVector3;const s:single):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3Dot(const v1,v2:TVector3):single; {$ifdef caninline}inline;{$endif}
function Vector3Cos(const v1,v2:TVector3):single; {$ifdef caninline}inline;{$endif}
function Vector3GetOneUnitOrthogonalVector(const v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3Cross(const v1,v2:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3Neg(const v:TVector3):TVector3;  {$ifdef caninline}inline;{$endif}
procedure Vector3Scale(var v:TVector3;const sx,sy,sz:single); overload; {$ifdef caninline}inline;{$endif}
procedure Vector3Scale(var v:TVector3;const s:single); overload; {$ifdef caninline}inline;{$endif}
function Vector3Mul(const v1,v2:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3Length(const v:TVector3):single; {$ifdef caninline}inline;{$endif}
function Vector3Dist(const v1,v2:TVector3):single; {$ifdef caninline}inline;{$endif}
function Vector3LengthSquared(const v:TVector3):single; {$ifdef caninline}inline;{$endif}
function Vector3DistSquared(const v1,v2:TVector3):single; {$ifdef caninline}inline;{$endif}
function Vector3Angle(const v1,v2,v3:TVector3):single; {$ifdef caninline}inline;{$endif}
function Vector3LengthNormalize(var v:TVector3):single; {$ifdef caninline}inline;{$endif}
function Vector3Normalize(var v:TVector3):single; {$ifdef caninline}inline;{$endif}
function Vector3NormalizeEx(var v:TVector3):single; {$ifdef caninline}inline;{$endif}
function Vector3SafeNorm(const v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3Norm(const v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3NormEx(const v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
procedure Vector3RotateX(var v:TVector3;a:single); {$ifdef caninline}inline;{$endif}
procedure Vector3RotateY(var v:TVector3;a:single); {$ifdef caninline}inline;{$endif}
procedure Vector3RotateZ(var v:TVector3;a:single); {$ifdef caninline}inline;{$endif}
procedure Vector3MatrixMul(var v:TVector3;const m:TMatrix3x3); overload; {$ifdef caninline}inline;{$endif}
procedure Vector3MatrixMul(var v:TVector3;const m:TMatrix4x3); overload; {$ifdef caninline}inline;{$endif}
procedure Vector3MatrixMul(var v:TVector3;const m:TMatrix4x4); overload; {$ifdef cpu386asm}assembler;{$endif}
procedure Vector3MatrixMulBasis(var v:TVector3;const m:TMatrix4x3); overload; {$ifdef caninline}inline;{$endif}
procedure Vector3MatrixMulBasis(var v:TVector3;const m:TMatrix4x4); overload; {$ifdef caninline}inline;{$endif}
procedure Vector3MatrixMulInverted(var v:TVector3;const m:TMatrix4x3); overload; {$ifdef caninline}inline;{$endif}
procedure Vector3MatrixMulInverted(var v:TVector3;const m:TMatrix4x4); overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMul(const v:TVector3;const m:TMatrix3x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMul(const v:TVector3;const m:TMatrix3x4):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMul(const v:TVector3;const m:TMatrix4x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMul(const v:TVector3;const m:TMatrix4x4):TVector3; overload; {$ifdef cpu386asm}assembler;{$endif}
function Vector3TermMatrixMulInverse(const v:TVector3;const m:TMatrix3x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMulInverse(const v:TVector3;const m:TMatrix4x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMulInverted(const v:TVector3;const m:TMatrix4x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMulInverted(const v:TVector3;const m:TMatrix4x4):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMulTransposed(const v:TVector3;const m:TMatrix3x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMulTransposed(const v:TVector3;const m:TMatrix4x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMulTransposed(const v:TVector3;const m:TMatrix4x4):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMulTransposedBasis(const v:TVector3;const m:TMatrix4x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMulTransposedBasis(const v:TVector3;const m:TMatrix4x4):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMulBasis(const v:TVector3;const m:TMatrix4x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMulBasis(const v:TVector3;const m:TMatrix4x4):TVector3; overload; {$ifdef caninline}inline;{$endif}
function Vector3TermMatrixMulHomogen(const v:TVector3;const m:TMatrix4x4):TVector3; {$ifdef caninline}inline;{$endif}
procedure Vector3Rotate(var v:TVector3;const Axis:TVector3;a:single); {$ifdef caninline}inline;{$endif}
function Vector3Lerp(const v1,v2:TVector3;w:single):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3Perpendicular(v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3TermQuaternionRotate(const v:TVector3;const q:TQuaternion):TVector3; {$ifdef caninline}inline;{$endif}
function Vector3ProjectToBounds(const v:TVector3;const MinVector,MaxVector:TVector3):single; {$ifdef caninline}inline;{$endif}

{$ifdef SIMD}
function SIMDVector3Flip(const v:TSIMDVector3):TSIMDVector3;
function SIMDVector3Abs(const v:TSIMDVector3):TSIMDVector3;
function SIMDVector3Compare(const v1,v2:TSIMDVector3):boolean;
function SIMDVector3CompareEx(const v1,v2:TSIMDVector3;const Threshold:single=1e-12):boolean;
procedure SIMDVector3DirectAdd(var v1:TSIMDVector3;const v2:TSIMDVector3);
procedure SIMDVector3DirectSub(var v1:TSIMDVector3;const v2:TSIMDVector3);
function SIMDVector3Add(const v1,v2:TSIMDVector3):TSIMDVector3;
function SIMDVector3Sub(const v1,v2:TSIMDVector3):TSIMDVector3;
function SIMDVector3Avg(const v1,v2:TSIMDVector3):TSIMDVector3; overload;
function SIMDVector3Avg(const v1,v2,v3:TSIMDVector3):TSIMDVector3; overload;
function SIMDVector3Avg(const va:PSIMDVector3s;Count:longint):TSIMDVector3; overload;
function SIMDVector3ScalarMul(const v:TSIMDVector3;const s:single):TSIMDVector3; {$ifdef cpu386asm}assembler;{$endif}
function SIMDVector3Dot(const v1,v2:TSIMDVector3):single; {$ifdef cpu386asm}assembler;{$endif}
function SIMDVector3Cos(const v1,v2:TSIMDVector3):single;
function SIMDVector3GetOneUnitOrthogonalVector(const v:TSIMDVector3):TSIMDVector3;
function SIMDVector3Cross(const v1,v2:TSIMDVector3):TSIMDVector3;
function SIMDVector3Neg(const v:TSIMDVector3):TSIMDVector3; {$ifdef cpu386asm}assembler;{$endif}
procedure SIMDVector3Scale(var v:TSIMDVector3;const sx,sy,sz:single); overload; {$ifdef cpu386asm}assembler;{$endif}
procedure SIMDVector3Scale(var v:TSIMDVector3;const s:single); overload; {$ifdef cpu386asm}assembler;{$endif}
function SIMDVector3Mul(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef cpu386asm}assembler;{$endif}
function SIMDVector3Length(const v:TSIMDVector3):single; {$ifdef cpu386asm}assembler;{$endif}
function SIMDVector3Dist(const v1,v2:TSIMDVector3):single; {$ifdef cpu386asm}assembler;{$endif}
function SIMDVector3LengthSquared(const v:TSIMDVector3):single; {$ifdef cpu386asm}assembler;{$endif}
function SIMDVector3DistSquared(const v1,v2:TSIMDVector3):single; {$ifdef cpu386asm}assembler;{$endif}
function SIMDVector3Angle(const v1,v2,v3:TSIMDVector3):single;
function SIMDVector3LengthNormalize(var v:TSIMDVector3):single;
procedure SIMDVector3Normalize(var v:TSIMDVector3);
function SIMDVector3SafeNorm(const v:TSIMDVector3):TSIMDVector3;
function SIMDVector3Norm(const v:TSIMDVector3):TSIMDVector3;
function SIMDVector3NormEx(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
procedure SIMDVector3RotateX(var v:TSIMDVector3;a:single);
procedure SIMDVector3RotateY(var v:TSIMDVector3;a:single);
procedure SIMDVector3RotateZ(var v:TSIMDVector3;a:single);
procedure SIMDVector3MatrixMul(var v:TSIMDVector3;const m:TMatrix3x3); overload;
procedure SIMDVector3MatrixMul(var v:TSIMDVector3;const m:TMatrix4x3); overload;
procedure SIMDVector3MatrixMul(var v:TSIMDVector3;const m:TMatrix4x4); overload; {$ifdef cpu386asm}assembler;{$endif}
procedure SIMDVector3MatrixMulBasis(var v:TSIMDVector3;const m:TMatrix4x3); overload;
procedure SIMDVector3MatrixMulBasis(var v:TSIMDVector3;const m:TMatrix4x4); overload;
procedure SIMDVector3MatrixMulInverted(var v:TSIMDVector3;const m:TMatrix4x3); overload;
procedure SIMDVector3MatrixMulInverted(var v:TSIMDVector3;const m:TMatrix4x4); overload;
function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix3x3):TSIMDVector3; overload;
function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix3x4):TSIMDVector3; overload; {$ifdef cpu386asm}assembler;{$endif}
function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload;
function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload; {$ifdef cpu386asm}assembler;{$endif}
function SIMDVector3TermMatrixMulInverse(const v:TSIMDVector3;const m:TMatrix3x3):TSIMDVector3; overload;
function SIMDVector3TermMatrixMulInverse(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload;
function SIMDVector3TermMatrixMulInverted(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload;
function SIMDVector3TermMatrixMulInverted(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload;
function SIMDVector3TermMatrixMulTransposed(const v:TSIMDVector3;const m:TMatrix3x3):TSIMDVector3; overload;
function SIMDVector3TermMatrixMulTransposed(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload;
function SIMDVector3TermMatrixMulTransposed(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload;
function SIMDVector3TermMatrixMulTransposedBasis(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload;
function SIMDVector3TermMatrixMulTransposedBasis(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload;
function SIMDVector3TermMatrixMulBasis(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload;
function SIMDVector3TermMatrixMulBasis(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload;
function SIMDVector3TermMatrixMulHomogen(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3;
function SIMDVector3Lerp(const v1,v2:TSIMDVector3;w:single):TSIMDVector3;
function SIMDVector3Perpendicular(v:TSIMDVector3):TSIMDVector3;
function SIMDVector3TermQuaternionRotate(const v:TSIMDVector3;const q:TQuaternion):TSIMDVector3;
function SIMDVector3ProjectToBounds(const v:TSIMDVector3;const MinVector,MaxVector:TSIMDVector3):single;
{$else}
function SIMDVector3Flip(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3Abs(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3Compare(const v1,v2:TSIMDVector3):boolean; {$ifdef caninline}inline;{$endif}
function SIMDVector3CompareEx(const v1,v2:TSIMDVector3;const Threshold:single=1e-12):boolean; {$ifdef caninline}inline;{$endif}
function SIMDVector3DirectAdd(var v1:TSIMDVector3;const v2:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3DirectSub(var v1:TSIMDVector3;const v2:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3Add(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3Sub(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3Avg(const v1,v2:TSIMDVector3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3Avg(const v1,v2,v3:TSIMDVector3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3Avg(const va:PSIMDVector3s;Count:longint):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3ScalarMul(const v:TSIMDVector3;const s:single):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3Dot(const v1,v2:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
function SIMDVector3Cos(const v1,v2:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
function SIMDVector3GetOneUnitOrthogonalVector(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3Cross(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3Neg(const v:TSIMDVector3):TSIMDVector3;  {$ifdef caninline}inline;{$endif}
procedure SIMDVector3Scale(var v:TSIMDVector3;const sx,sy,sz:single); overload; {$ifdef caninline}inline;{$endif}
procedure SIMDVector3Scale(var v:TSIMDVector3;const s:single); overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3Mul(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3Length(const v:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
function SIMDVector3Dist(const v1,v2:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
function SIMDVector3LengthSquared(const v:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
function SIMDVector3DistSquared(const v1,v2:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
function SIMDVector3Angle(const v1,v2,v3:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
function SIMDVector3LengthNormalize(var v:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
function SIMDVector3Normalize(var v:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
function SIMDVector3NormalizeEx(var v:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
function SIMDVector3SafeNorm(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3Norm(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3NormEx(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
procedure SIMDVector3RotateX(var v:TSIMDVector3;a:single); {$ifdef caninline}inline;{$endif}
procedure SIMDVector3RotateY(var v:TSIMDVector3;a:single); {$ifdef caninline}inline;{$endif}
procedure SIMDVector3RotateZ(var v:TSIMDVector3;a:single); {$ifdef caninline}inline;{$endif}
procedure SIMDVector3MatrixMul(var v:TSIMDVector3;const m:TMatrix3x3); overload; {$ifdef caninline}inline;{$endif}
procedure SIMDVector3MatrixMul(var v:TSIMDVector3;const m:TMatrix4x3); overload; {$ifdef caninline}inline;{$endif}
procedure SIMDVector3MatrixMul(var v:TSIMDVector3;const m:TMatrix4x4); overload; {$ifdef cpu386asm}assembler;{$endif}
procedure SIMDVector3MatrixMulBasis(var v:TSIMDVector3;const m:TMatrix4x3); overload; {$ifdef caninline}inline;{$endif}
procedure SIMDVector3MatrixMulBasis(var v:TSIMDVector3;const m:TMatrix4x4); overload; {$ifdef caninline}inline;{$endif}
procedure SIMDVector3MatrixMulInverted(var v:TSIMDVector3;const m:TMatrix4x3); overload; {$ifdef caninline}inline;{$endif}
procedure SIMDVector3MatrixMulInverted(var v:TSIMDVector3;const m:TMatrix4x4); overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix3x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix3x4):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload; {$ifdef cpu386asm}assembler;{$endif}
function SIMDVector3TermMatrixMulInverse(const v:TSIMDVector3;const m:TMatrix3x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMulInverse(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMulInverted(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMulInverted(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMulTransposed(const v:TSIMDVector3;const m:TMatrix3x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMulTransposed(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMulTransposed(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMulTransposedBasis(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMulTransposedBasis(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMulBasis(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMulBasis(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermMatrixMulHomogen(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3Lerp(const v1,v2:TSIMDVector3;w:single):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3Perpendicular(v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3TermQuaternionRotate(const v:TSIMDVector3;const q:TQuaternion):TSIMDVector3; {$ifdef caninline}inline;{$endif}
function SIMDVector3ProjectToBounds(const v:TSIMDVector3;const MinVector,MaxVector:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
{$endif}

function Vector4Compare(const v1,v2:TVector4):boolean;
function Vector4CompareEx(const v1,v2:TVector4;const Threshold:single=1e-12):boolean;
function Vector4Add(const v1,v2:TVector4):TVector4;
function Vector4Sub(const v1,v2:TVector4):TVector4;
function Vector4ScalarMul(const v:TVector4;s:single):TVector4;
function Vector4Dot(const v1,v2:TVector4):single;
function Vector4Cross(const v1,v2:TVector4):TVector4;
function Vector4Neg(const v:TVector4):TVector4;
procedure Vector4Scale(var v:TVector4;sx,sy,sz:single); overload;
procedure Vector4Scale(var v:TVector4;s:single); overload;
function Vector4Mul(const v1,v2:TVector4):TVector4;
function Vector4Length(const v:TVector4):single;
function Vector4Dist(const v1,v2:TVector4):single;
function Vector4LengthSquared(const v:TVector4):single;
function Vector4DistSquared(const v1,v2:TVector4):single;
function Vector4Angle(const v1,v2,v3:TVector4):single;
procedure Vector4Normalize(var v:TVector4);
function Vector4Norm(const v:TVector4):TVector4;
procedure Vector4RotateX(var v:TVector4;a:single);
procedure Vector4RotateY(var v:TVector4;a:single);
procedure Vector4RotateZ(var v:TVector4;a:single);
procedure Vector4MatrixMul(var v:TVector4;const m:TMatrix4x4); {$ifdef cpu386asm}register;{$endif}
function Vector4TermMatrixMul(const v:TVector4;const m:TMatrix4x4):TVector4; {$ifdef cpu386asm}register;{$endif}
function Vector4TermMatrixMulHomogen(const v:TVector4;const m:TMatrix4x4):TVector4;
procedure Vector4Rotate(var v:TVector4;const Axis:TVector4;a:single);
function Vector4Lerp(const v1,v2:TVector4;w:single):TVector4;

function Matrix2x2Inverse(var mr:TMatrix2x2;const ma:TMatrix2x2):boolean;
function Matrix2x2TermInverse(const m:TMatrix2x2):TMatrix2x2;

function Matrix3x3RotateX(Angle:single):TMatrix3x3; {$ifdef caninline}inline;{$endif}
function Matrix3x3RotateY(Angle:single):TMatrix3x3; {$ifdef caninline}inline;{$endif}
function Matrix3x3RotateZ(Angle:single):TMatrix3x3; {$ifdef caninline}inline;{$endif}
function Matrix3x3RotateAngles(Angles:TVector3):TMatrix3x3; overload;
function Matrix3x3RotateAnglesLDX(const Angles:TVector3):TMatrix3x3; overload;
function Matrix3x3RotateAnglesLDXModel(const Angles:TVector3):TMatrix3x3; overload;
function Matrix3x3Rotate(Angle:single;Axis:TVector3):TMatrix3x3; overload;
function Matrix3x3Scale(sx,sy,sz:single):TMatrix3x3; {$ifdef caninline}inline;{$endif}
procedure Matrix3x3Add(var m1:TMatrix3x3;const m2:TMatrix3x3); {$ifdef caninline}inline;{$endif}
procedure Matrix3x3Sub(var m1:TMatrix3x3;const m2:TMatrix3x3); {$ifdef caninline}inline;{$endif}
procedure Matrix3x3Mul(var m1:TMatrix3x3;const m2:TMatrix3x3);
function Matrix3x3TermAdd(const m1,m2:TMatrix3x3):TMatrix3x3; {$ifdef caninline}inline;{$endif}
function Matrix3x3TermSub(const m1,m2:TMatrix3x3):TMatrix3x3; {$ifdef caninline}inline;{$endif}
function Matrix3x3TermMul(const m1,m2:TMatrix3x3):TMatrix3x3;
function Matrix3x3TermMulTranspose(const m1,m2:TMatrix3x3):TMatrix3x3;
procedure Matrix3x3ScalarMul(var m:TMatrix3x3;s:single); {$ifdef caninline}inline;{$endif}
function Matrix3x3TermScalarMul(const m:TMatrix3x3;s:single):TMatrix3x3; {$ifdef caninline}inline;{$endif}
procedure Matrix3x3Transpose(var m:TMatrix3x3); {$ifdef caninline}inline;{$endif}
function Matrix3x3TermTranspose(const m:TMatrix3x3):TMatrix3x3; {$ifdef caninline}inline;{$endif}
function Matrix3x3Determinant(const m:TMatrix3x3):single; {$ifdef caninline}inline;{$endif}
function Matrix3x3Angles(const m:TMatrix3x3):TVector3;
function Matrix3x3EulerAngles(const m:TMatrix3x3):TVector3;
procedure Matrix3x3SetColumn(var m:TMatrix3x3;const c:longint;const v:TVector3); {$ifdef caninline}inline;{$endif}
function Matrix3x3GetColumn(const m:TMatrix3x3;const c:longint):TVector3; {$ifdef caninline}inline;{$endif}
procedure Matrix3x3SetRow(var m:TMatrix3x3;const r:longint;const v:TVector3); {$ifdef caninline}inline;{$endif}
function Matrix3x3GetRow(const m:TMatrix3x3;const r:longint):TVector3; {$ifdef caninline}inline;{$endif}
function Matrix3x3Compare(const m1,m2:TMatrix3x3):boolean;
function Matrix3x3Inverse(var mr:TMatrix3x3;const ma:TMatrix3x3):boolean;
function Matrix3x3TermInverse(const m:TMatrix3x3):TMatrix3x3;
function Matrix3x3Map(const a,b:TVector3):TMatrix3x3;
procedure Matrix3x3OrthoNormalize(var m:TMatrix3x3);
function Matrix3x3Slerp(const a,b:TMatrix3x3;x:single):TMatrix3x3;
function Matrix3x3FromToRotation(const FromDirection,ToDirection:TVector3):TMatrix3x3;
function Matrix3x3Construct(const Forwards,Up:TVector3):TMatrix3x3;

function Matrix4x4Set(m:TMatrix3x3):TMatrix4x4;
function Matrix4x4Rotation(m:TMatrix4x4):TMatrix4x4;
function Matrix4x4RotateX(Angle:single):TMatrix4x4;
function Matrix4x4RotateY(Angle:single):TMatrix4x4;
function Matrix4x4RotateZ(Angle:single):TMatrix4x4;
function Matrix4x4RotateAngles(const Angles:TVector3):TMatrix4x4; overload;
function Matrix4x4RotateAnglesLDX(const Angles:TVector3):TMatrix4x4; overload;
function Matrix4x4RotateAnglesLDXModel(const Angles:TVector3):TMatrix4x4; overload;
function Matrix4x4Rotate(Angle:single;Axis:TVector3):TMatrix4x4; overload;
function Matrix4x4Translate(x,y,z:single):TMatrix4x4; overload; {$ifdef caninline}inline;{$endif}
function Matrix4x4Translate(const v:TVector3):TMatrix4x4; overload; {$ifdef caninline}inline;{$endif}
function Matrix4x4Translate(const v:TVector4):TMatrix4x4; overload; {$ifdef caninline}inline;{$endif}
procedure Matrix4x4Translate(var m:TMatrix4x4;const v:TVector3); overload; {$ifdef caninline}inline;{$endif}
procedure Matrix4x4Translate(var m:TMatrix4x4;const v:TVector4); overload; {$ifdef caninline}inline;{$endif}
function Matrix4x4Scale(sx,sy,sz:single):TMatrix4x4; overload; {$ifdef caninline}inline;{$endif}
function Matrix4x4Scale(const s:TVector3):TMatrix4x4; overload; {$ifdef caninline}inline;{$endif}
procedure Matrix4x4Add(var m1:TMatrix4x4;const m2:TMatrix4x4); {$ifdef caninline}inline;{$endif}
procedure Matrix4x4Sub(var m1:TMatrix4x4;const m2:TMatrix4x4); {$ifdef caninline}inline;{$endif}
procedure Matrix4x4Mul(var m1:TMatrix4x4;const m2:TMatrix4x4); overload; {$ifdef cpu386asm}register;{$endif}
procedure Matrix4x4Mul(var mr:TMatrix4x4;const m1,m2:TMatrix4x4); overload; {$ifdef cpu386asm}register;{$endif}
function Matrix4x4TermAdd(const m1,m2:TMatrix4x4):TMatrix4x4; {$ifdef caninline}inline;{$endif}
function Matrix4x4TermSub(const m1,m2:TMatrix4x4):TMatrix4x4; {$ifdef caninline}inline;{$endif}
function Matrix4x4TermMul(const m1,m2:TMatrix4x4):TMatrix4x4; {$ifdef cpu386asm}register;{$endif}
function Matrix4x4TermMulInverted(const m1,m2:TMatrix4x4):TMatrix4x4; {$ifdef caninline}inline;{$endif}
function Matrix4x4TermMulSimpleInverted(const m1,m2:TMatrix4x4):TMatrix4x4; {$ifdef caninline}inline;{$endif}
function Matrix4x4TermMulTranspose(const m1,m2:TMatrix4x4):TMatrix4x4;
function Matrix4x4Lerp(const a,b:TMatrix4x4;x:single):TMatrix4x4;
function Matrix4x4Slerp(const a,b:TMatrix4x4;x:single):TMatrix4x4;
procedure Matrix4x4ScalarMul(var m:TMatrix4x4;s:single); {$ifdef caninline}inline;{$endif}
procedure Matrix4x4Transpose(var m:TMatrix4x4);
function Matrix4x4TermTranspose(const m:TMatrix4x4):TMatrix4x4; 
function Matrix4x4Determinant(const m:TMatrix4x4):single;
function Matrix4x4Angles(const m:TMatrix4x4):TVector3;
procedure Matrix4x4SetColumn(var m:TMatrix4x4;const c:longint;const v:TVector4); {$ifdef caninline}inline;{$endif}
function Matrix4x4GetColumn(const m:TMatrix4x4;const c:longint):TVector4; {$ifdef caninline}inline;{$endif}
procedure Matrix4x4SetRow(var m:TMatrix4x4;const r:longint;const v:TVector4); {$ifdef caninline}inline;{$endif}
function Matrix4x4GetRow(const m:TMatrix4x4;const r:longint):TVector4; {$ifdef caninline}inline;{$endif}
function Matrix4x4Compare(const m1,m2:TMatrix4x4):boolean;
procedure Matrix4x4Reflect(var mr:TMatrix4x4;Plane:TPlane);
function Matrix4x4TermReflect(Plane:TPlane):TMatrix4x4;
function Matrix4x4SimpleInverse(var mr:TMatrix4x4;const ma:TMatrix4x4):boolean; {$ifdef caninline}inline;{$endif}
function Matrix4x4TermSimpleInverse(const ma:TMatrix4x4):TMatrix4x4; {$ifdef caninline}inline;{$endif}
function Matrix4x4Inverse(var mr:TMatrix4x4;const ma:TMatrix4x4):boolean;
function Matrix4x4TermInverse(const ma:TMatrix4x4):TMatrix4x4;
function Matrix4x4InverseOld(var mr:TMatrix4x4;const ma:TMatrix4x4):boolean;
function Matrix4x4TermInverseOld(const ma:TMatrix4x4):TMatrix4x4;
function Matrix4x4GetSubMatrix3x3(const m:TMatrix4x4;i,j:longint):TMatrix3x3;
function Matrix4x4Frustum(Left,Right,Bottom,Top,zNear,zFar:single):TMatrix4x4;
function Matrix4x4Ortho(Left,Right,Bottom,Top,zNear,zFar:single):TMatrix4x4;
function Matrix4x4OrthoLH(Left,Right,Bottom,Top,zNear,zFar:single):TMatrix4x4;
function Matrix4x4OrthoRH(Left,Right,Bottom,Top,zNear,zFar:single):TMatrix4x4;
function Matrix4x4OrthoOffCenterLH(Left,Right,Bottom,Top,zNear,zFar:single):TMatrix4x4;
function Matrix4x4OrthoOffCenterRH(Left,Right,Bottom,Top,zNear,zFar:single):TMatrix4x4;
function Matrix4x4Perspective(fovy,Aspect,zNear,zFar:single):TMatrix4x4;
function Matrix4x4LookAtViewerLDX(const Eye,Angles:TVector3):TMatrix4x4;
function Matrix4x4LookWithAnglesLDX(const Eye,Angles:TVector3):TMatrix4x4;
function Matrix4x4LookAtLDX(const Eye,Center,Up:TVector3):TMatrix4x4;
function Matrix4x4LookAtLDX2(const Eye,Center,Up:TVector3):TMatrix4x4;
function Matrix4x4LookAt(const Eye,Center,Up:TVector3):TMatrix4x4;
function Matrix4x4ModelLookAt(const Position,Target,Up:TVector3):TMatrix4x4;
function Matrix4x4Fill(const Eye,RightVector,UpVector,ForwardVector:TVector3):TMatrix4x4;
function Matrix4x4LookAtLH(const Eye,At,Up:TVector3):TMatrix4x4;
function Matrix4x4LookAtRH(const Eye,At,Up:TVector3):TMatrix4x4;
function Matrix4x4LookAtLight(const Pos,Dir,Up:TVector3):TMatrix4x4;
function Matrix4x4ConstructX(const xAxis:TVector3):TMatrix4x4;
function Matrix4x4ConstructY(const yAxis:TVector3):TMatrix4x4;
function Matrix4x4ConstructZ(const zAxis:TVector3):TMatrix4x4;
function Matrix4x4ProjectionMatrixClip(const ProjectionMatrix:TMatrix4x4;const ClipPlane:TPlane):TMatrix4x4;

procedure PlaneNormalize(var Plane:TPlane); {$ifdef caninline}inline;{$endif}
function PlaneMatrixMul(const Plane:TPlane;const Matrix:TMatrix4x4):TPlane;
function PlaneTransform(const Plane:TPlane;const Matrix:TMatrix4x4):TPlane; overload;
function PlaneTransform(const Plane:TPlane;const Matrix,NormalMatrix:TMatrix4x4):TPlane; overload;
function PlaneFastTransform(const Plane:TPlane;const Matrix:TMatrix4x4):TPlane; overload; {$ifdef caninline}inline;{$endif}
function PlaneVectorDistance(const Plane:TPlane;const Point:TVector3):single; overload; {$ifdef caninline}inline;{$endif}
function PlaneVectorDistance(const Plane:TPlane;const Point:TSIMDVector3):single; overload;
function PlaneVectorDistance(const Plane:TPlane;const Point:TVector4):single; overload; {$ifdef caninline}inline;{$endif}
function PlaneFromPoints(const p1,p2,p3:TVector3):TPlane; overload; {$ifdef caninline}inline;{$endif}
function PlaneFromPoints(const p1,p2,p3:TVector4):TPlane; overload; {$ifdef caninline}inline;{$endif}
procedure PlaneClipSegment(const Plane:TPlane;var p0,p1,Clipped:TVector3); overload;
function PlaneClipSegmentClosest(const Plane:TPlane;var p0,p1,Clipped0,Clipped1:TVector3):longint; overload;

function ClipSegmentToPlane(const Plane:TPlane;var p0,p1:TVector3):boolean; overload;
function ClipSegmentToPlane(const Plane:TPlane;var p0,p1:TSIMDVector3):boolean; overload;

function QuaternionNormal(const AQuaternion:TQuaternion):single;
function QuaternionLengthSquared(const AQuaternion:TQuaternion):single;
procedure QuaternionNormalize(var AQuaternion:TQuaternion);
function QuaternionTermNormalize(const AQuaternion:TQuaternion):TQuaternion;
function QuaternionNeg(const AQuaternion:TQuaternion):TQuaternion;
function QuaternionConjugate(const AQuaternion:TQuaternion):TQuaternion;
function QuaternionInverse(const AQuaternion:TQuaternion):TQuaternion;
function QuaternionAdd(const q1,q2:TQuaternion):TQuaternion;
function QuaternionSub(const q1,q2:TQuaternion):TQuaternion;
function QuaternionScalarMul(const q:TQuaternion;const s:single):TQuaternion;
function QuaternionMul(const q1,q2:TQuaternion):TQuaternion; 
function QuaternionRotateAroundAxis(const q1,q2:TQuaternion):TQuaternion; {$ifdef caninline}inline;{$endif}
function QuaternionFromAxisAngle(const Axis:TVector3;Angle:single):TQuaternion; overload; {$ifdef caninline}inline;{$endif}
function QuaternionFromSpherical(const Latitude,Longitude:single):TQuaternion; {$ifdef caninline}inline;{$endif}
procedure QuaternionToSpherical(const q:TQuaternion;var Latitude,Longitude:single);
function QuaternionFromAngles(const Pitch,Yaw,Roll:single):TQuaternion; overload; {$ifdef caninline}inline;{$endif}
function QuaternionFromAngles(const Angles:TVector3):TQuaternion; overload; {$ifdef caninline}inline;{$endif}
function QuaternionFromMatrix3x3(const AMatrix:TMatrix3x3):TQuaternion;
function QuaternionToMatrix3x3(AQuaternion:TQuaternion):TMatrix3x3;
function QuaternionFromTangentSpaceMatrix3x3(AMatrix:TMatrix3x3):TQuaternion;
function QuaternionToTangentSpaceMatrix3x3(AQuaternion:TQuaternion):TMatrix3x3;
function QuaternionFromMatrix3x4(const AMatrix:TMatrix3x4):TQuaternion;
function QuaternionToMatrix3x4(AQuaternion:TQuaternion):TMatrix3x4;
function QuaternionFromMatrix4x3(const AMatrix:TMatrix4x3):TQuaternion;
function QuaternionToMatrix4x3(AQuaternion:TQuaternion):TMatrix4x3;
function QuaternionFromMatrix4x4(const AMatrix:TMatrix4x4):TQuaternion;
function QuaternionToMatrix4x4(AQuaternion:TQuaternion):TMatrix4x4;
function QuaternionToAngles(const AQuaternion:TQuaternion):TVector3;
function QuaternionToEuler(const AQuaternion:TQuaternion):TVector3; {$ifdef caninline}inline;{$endif}
procedure QuaternionToAxisAngle(AQuaternion:TQuaternion;var Axis:TVector3;var Angle:single); {$ifdef caninline}inline;{$endif}
function QuaternionGenerator(AQuaternion:TQuaternion):TVector3; {$ifdef caninline}inline;{$endif}
function QuaternionLerp(const q1,q2:TQuaternion;const t:single):TQuaternion; {$ifdef caninline}inline;{$endif}
function QuaternionNlerp(const q1,q2:TQuaternion;const t:single):TQuaternion; {$ifdef caninline}inline;{$endif}
function QuaternionSlerp(const q1,q2:TQuaternion;const t:single):TQuaternion;
function QuaternionIntegrate(const q:TQuaternion;const Omega:TVector3;const DeltaTime:single):TQuaternion;
function QuaternionSpin(const q:TQuaternion;const Omega:TVector3;const DeltaTime:single):TQuaternion; overload;
function QuaternionSpin(const q:TQuaternion;const Omega:TSIMDVector3;const DeltaTime:single):TQuaternion; overload;
procedure QuaternionDirectSpin(var q:TQuaternion;const Omega:TVector3;const DeltaTime:single); overload;
procedure QuaternionDirectSpin(var q:TQuaternion;const Omega:TSIMDVector3;const DeltaTime:single); overload;
function QuaternionFromToRotation(const FromDirection,ToDirection:TVector3):TQuaternion; {$ifdef caninline}inline;{$endif}

function SphereCoordsFromCartesianVector3(const v:TVector3):TSphereCoords; {$ifdef caninline}inline;{$endif}
function SphereCoordsFromCartesianVector4(const v:TVector4):TSphereCoords; {$ifdef caninline}inline;{$endif}
function SphereCoordsToCartesianVector3(const s:TSphereCoords):TVector3; {$ifdef caninline}inline;{$endif}
function SphereCoordsToCartesianVector4(const s:TSphereCoords):TVector4; {$ifdef caninline}inline;{$endif}

function CullSphere(const s:TSphere;const p:array of TPlane):boolean; //{$ifdef caninline}inline;{$endif}
function SphereContains(const a,b:TSphere):boolean; overload; {$ifdef caninline}inline;{$endif}
function SphereContains(const a:TSphere;const v:TVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
function SphereContainsEx(const a,b:TSphere):boolean; overload; {$ifdef caninline}inline;{$endif}
function SphereContainsEx(const a:TSphere;const v:TVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
function SphereDistance(const a,b:TSphere):single; overload; {$ifdef caninline}inline;{$endif}
function SphereDistance(const a:TSphere;const v:TVector3):single; overload; {$ifdef caninline}inline;{$endif}
function SphereIntersect(const a,b:TSphere):boolean; {$ifdef caninline}inline;{$endif}
function SphereIntersectEx(const a,b:TSphere;Threshold:single=SPHEREEPSILON):boolean; {$ifdef caninline}inline;{$endif}
function SphereRayIntersect(var s:TSphere;const Origin,Direction:TVector3):boolean; {$ifdef caninline}inline;{$endif}
function SphereFromAABB(const AABB:TAABB):TSphere; {$ifdef caninline}inline;{$endif}
function SphereFromFrustum(zNear,zFar,FOV,AspectRatio:single;Position,Direction:TVector3):TSphere; {$ifdef caninline}inline;{$endif}
function SphereExtend(const Sphere,WithSphere:TSphere):TSphere; {$ifdef caninline}inline;{$endif}
function SphereTransform(const Sphere:TSphere;const Transform:TMatrix4x4):TSphere; {$ifdef caninline}inline;{$endif}
function SphereTriangleIntersection(const Sphere:TSphere;const TriangleVertex0,TriangleVertex1,TriangleVertex2,TriangleNormal:TVector3;out Position,Normal:TVector3;out Depth:single):boolean; overload;
function SphereTriangleIntersection(const Sphere:TSphere;const SegmentTriangle:TSegmentTriangle;const TriangleNormal:TVector3;out Position,Normal:TVector3;out Depth:single):boolean; overload;
function SweptSphereIntersection(const SphereA,SphereB:TSphere;const VelocityA,VelocityB:TVector3;out TimeFirst,TimeLast:single):boolean; {$ifdef caninline}inline;{$endif}

function AABBCost(const AABB:TAABB):single; {$ifdef caninline}inline;{$endif}
function AABBVolume(const AABB:TAABB):single; {$ifdef caninline}inline;{$endif}
function AABBArea(const AABB:TAABB):single; {$ifdef caninline}inline;{$endif}
function AABBFlip(const AABB:TAABB):TAABB;
function AABBFromSphere(const Sphere:TSphere;const Scale:single=1.0):TAABB;
function AABBFromOBB(const OBB:TOBB):TAABB;
function AABBFromOBBEx(const OBB:TOBB):TAABB;
function AABBSquareMagnitude(const AABB:TAABB):single; {$ifdef caninline}inline;{$endif}
function AABBResize(const AABB:TAABB;f:single):TAABB; {$ifdef caninline}inline;{$endif}
function AABBCombine(const AABB,WithAABB:TAABB):TAABB; {$ifdef caninline}inline;{$endif}
function AABBCombineVector3(const AABB:TAABB;v:TVector3):TAABB; {$ifdef caninline}inline;{$endif}
function AABBDistance(const AABB,WithAABB:TAABB):single; {$ifdef caninline}inline;{$endif}
function AABBRadius(const AABB:TAABB):single; {$ifdef caninline}inline;{$endif}
function AABBCompare(const AABB,WithAABB:TAABB):boolean; {$ifdef caninline}inline;{$endif}
function AABBIntersect(const AABB,WithAABB:TAABB):boolean; overload; {$ifdef caninline}inline;{$endif}
function AABBIntersectEx(const AABB,WithAABB:TAABB;Threshold:single=AABBEPSILON):boolean; {$ifdef caninline}inline;{$endif}
function AABBIntersect(const AABB:TAABB;const Sphere:TSphere):boolean; overload; {$ifdef caninline}inline;{$endif}
function AABBContains(const InAABB,AABB:TAABB):boolean; overload; {$ifdef caninline}inline;{$endif}
function AABBContains(const AABB:TAABB;Vector:TVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
function AABBContainsEx(const InAABB,AABB:TAABB):boolean; overload; {$ifdef caninline}inline;{$endif}
function AABBContainsEx(const AABB:TAABB;Vector:TVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
function AABBTouched(const AABB:TAABB;Vector:TVector3;Threshold:single):boolean; {$ifdef caninline}inline;{$endif}
function AABBGetIntersectAABB(const AABB,WithAABB:TAABB):TAABB; {$ifdef caninline}inline;{$endif}
function AABBGetIntersection(const AABB,WithAABB:TAABB):TAABB; {$ifdef caninline}inline;{$endif}
function AABBRayIntersect(const AABB:TAABB;const Origin,Direction:TVector3):boolean; {$ifdef caninline}inline;{$endif}
function AABBRayIntersectHit(const AABB:TAABB;const Origin,Direction:TVector3;var HitDist:single):boolean; {$ifdef caninline}inline;{$endif}
function AABBRayIntersectHitFast(const AABB:TAABB;const Origin,Direction:TVector3;var HitDist:single):boolean; {$ifdef caninline}inline;{$endif}
function AABBRayIntersectHitPoint(const AABB:TAABB;const Origin,Direction:TVector3;var HitPoint:TVector3):boolean; {$ifdef caninline}inline;{$endif}
function AABBRayIntersection(const AABB:TAABB;const Origin,Direction:TVector3;var Time:single):boolean; overload; {$ifdef caninline}inline;{$endif}
function AABBRayIntersection(const AABB:TAABB;const Origin,Direction:TSIMDVector3;var Time:single):boolean; overload; {$ifdef caninline}inline;{$endif}
function AABBLineIntersection(const AABB:TAABB;const StartPoint,EndPoint:TVector3):boolean; {$ifdef caninline}inline;{$endif}
function AABBTransform(const DstAABB:TAABB;const Transform:TMatrix4x4):TAABB; {$ifdef caninline}inline;{$endif}
function AABBTransformEx(const DstAABB:TAABB;const Transform:TMatrix4x4):TAABB; {$ifdef caninline}inline;{$endif}
function AABBIntersectTriangle(const AABB:TAABB;const tv0,tv1,tv2:TVector3):boolean;
function AABBMatrixMul(const DstAABB:TAABB;const Transform:TMatrix4x4):TAABB; {$ifdef caninline}inline;{$endif}
function AABBScissorRect(const AABB:TAABB;var Scissor:TClipRect;const mvp:TMatrix4x4;const vp:TClipRect;zcull:boolean):boolean; overload; {$ifdef caninline}inline;{$endif}
function AABBScissorRect(const AABB:TAABB;var Scissor:TFloatClipRect;const mvp:TMatrix4x4;const vp:TFloatClipRect;zcull:boolean):boolean; overload; {$ifdef caninline}inline;{$endif}
function AABBMovingTest(const aAABBFrom,aAABBTo,bAABBFrom,bAABBTo:TAABB;var t:single):boolean;
function AABBSweepTest(const aAABB,bAABB:TAABB;const aV,bV:TVector3;var FirstTime,LastTime:single):boolean; {$ifdef caninline}inline;{$endif}

procedure SIMDSegment(out Segment:TSIMDSegment;const p0,p1:TSIMDVector3); overload;
function SIMDSegment(const p0,p1:TSIMDVector3):TSIMDSegment; overload;
function SIMDSegmentSquaredDistanceTo(const Segment:TSIMDSegment;const p:TSIMDVector3):single;
procedure SIMDSegmentClosestPointTo(const Segment:TSIMDSegment;const p:TSIMDVector3;out Time:single;out ClosestPoint:TSIMDVector3);
procedure SIMDSegmentTransform(out OutputSegment:TSIMDSegment;const Segment:TSIMDSegment;const Transform:TMatrix4x4); overload;
function SIMDSegmentTransform(const Segment:TSIMDSegment;const Transform:TMatrix4x4):TSIMDSegment; overload;
procedure SIMDSegmentClosestPoints(const SegmentA,SegmentB:TSIMDSegment;out TimeA:single;out ClosestPointA:TSIMDVector3;out TimeB:single;out ClosestPointB:TSIMDVector3);
function SIMDSegmentIntersect(const SegmentA,SegmentB:TSIMDSegment;out TimeA,TimeB:single;out IntersectionPoint:TSIMDVector3):boolean;

function SIMDTriangleContains(const Triangle:TSIMDTriangle;const p:TSIMDVector3):boolean;
function SIMDTriangleIntersect(const Triangle:TSIMDTriangle;const Segment:TSIMDSegment;out Time:single;out IntersectionPoint:TSIMDVector3):boolean;
function SIMDTriangleClosestPointTo(const Triangle:TSIMDTriangle;const Point:TSIMDVector3;out ClosestPoint:TSIMDVector3):boolean; overload;
function SIMDTriangleClosestPointTo(const Triangle:TSIMDTriangle;const Segment:TSIMDSegment;out Time:single;out ClosestPointOnSegment,ClosestPointOnTriangle:TSIMDVector3):boolean; overload;

procedure DoCalculateInterval(const Vertices:PVector3s;const Count:longint;const Axis:TVector3;out OutMin,OutMax:single);
function DoSpanIntersect(const Vertices1:PVector3s;const Count1:longint;const Vertices2:PVector3s;const Count2:longint;const AxisTest:TVector3;out AxisPenetration:TVector3):single;
function CollideOBBTriangle(const OBB:TOBB;const v0,v1,v2:TVector3;out Position,Normal:TVector3;out Penetration:single):boolean;

function RayIntersectTriangle(const RayOrigin,RayDirection,v0,v1,v2:TVector3;var Time,u,v:single):boolean; overload;
function RayIntersectTriangle(const RayOrigin,RayDirection,v0,v1,v2:TSIMDVector3;var Time,u,v:single):boolean; overload;

function SegmentTriangleIntersection(out tS,tT0,tT1:single;seg:TSegment;triangle:TSegmentTriangle):boolean;
function BoxSegmentIntersect(const OBB:TOBB;out fracOut:single;out posOut,NormalOut:TVector3;seg:TSegment):boolean;
function SegmentSegmentDistanceSq(out t0,t1:single;seg0,seg1:TSegment):single;
function PointTriangleDistanceSq(out pfSParam,pfTParam:single;rkPoint:TVector3;const rkTri:TSegmentTriangle):single; overload;
function PointTriangleDistance(const Point,t0,t1,t2:TVector3):single; overload;
function PointTriangleDistanceSq(const Point,t0,t1,t2:TVector3):single; overload;
function PointTriangleDistanceSq(const Point:TVector3;const SegmentTriangle:TSegmentTriangle):single; overload;
function ProjectOnTriangle(var pt:TVector3;const p0,p1,p2:TVector3;s,t:single):single;
function ClosestPointOnTriangle(const p0,p1,p2,pt:TVector3;var ClosestPoint:TVector3):single;
function SegmentTriangleDistanceSq(out segT,triT0,triT1:single;const seg:TSegment;const triangle:TSegmentTriangle):single;
function BoxGetDistanceToPoint(Point:TVector3;const Center,Size:TVector3;const InvTransformMatrix,TransformMatrix:TMatrix4x4;var ClosestBoxPoint:TVector3):single;
function GetDistanceFromLine(const p0,p1,p:TVector3;var Projected:TVector3;const Time:psingle=nil):single;
procedure LineClosestApproach(const pa,ua,pb,ub:TVector3;var Alpha,Beta:single);
procedure ClosestLineBoxPoints(const p1,p2,c:TVector3;const ir,r:TMatrix4x4;const side:TVector3;var lret,bret:TVector3);
procedure ClosestLineSegmentPoints(const a0,a1,b0,b1:TVector3;var cp0,cp1:TVector3);
function LineSegmentIntersection(const a0,a1,b0,b1:TVector3;const p:PVector3=nil):boolean;
function LineLineIntersection(const a0,a1,b0,b1:TVector3;const pa:PVector3=nil;const pb:PVector3=nil;const ta:psingle=nil;const tb:psingle=nil):boolean;

function MinkowskizeOBBInOBB(const OBB1,OBB2:TOBB):TMinkowskiDescription;
function MinkowskizeSphereInOBB(const Sphere:TSphere;const OBB:TOBB):TMinkowskiDescription;
function MinkowskizeTriangleInOBB(const v0,v1,v2:TVector3;const OBB:TOBB):TMinkowskiDescription;
function MinkowskizeOBBInTriangle(const v0,v1,v2:TVector3;const OBB:TOBB):TMinkowskiDescription;

function IsPointsSameSide(const p0,p1,Origin,Direction:TVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
function IsPointsSameSide(const p0,p1,Origin,Direction:TSIMDVector3):boolean; overload; {$ifdef caninline}inline;{$endif}

function PointInTriangle(const p0,p1,p2,Normal,p:TVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
function PointInTriangle(const p0,p1,p2,Normal,p:TSIMDVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
function PointInTriangle(const p0,p1,p2,p:TVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
function PointInTriangle(const p0,p1,p2,p:TSIMDVector3):boolean; overload; {$ifdef caninline}inline;{$endif}

function SegmentSqrDistance(const FromVector,ToVector,p:TVector3;out Nearest:TVector3):single; overload; {$ifdef caninline}inline;{$endif}
function SegmentSqrDistance(const FromVector,ToVector,p:TSIMDVector3;out Nearest:TSIMDVector3):single; overload; {$ifdef caninline}inline;{$endif}

procedure ProjectOBBToVector(const OBB:TOBB;const Vector:TVector3;out OBBMin,OBBMax:single); {$ifdef caninline}inline;{$endif}

procedure ProjectTriangleToVector(const v0,v1,v2,Vector:TVector3;out TriangleMin,TriangleMax:single); {$ifdef caninline}inline;{$endif}

function GetOverlap(const MinA,MaxA,MinB,MaxB:single):single; {$ifdef caninline}inline;{$endif}

function OldTriangleTriangleIntersection(const a0,a1,a2,b0,b1,b2:TVector3):boolean;
function TriangleTriangleIntersection(const v0,v1,v2,u0,u1,u2:TVector3):boolean;

function OBBTriangleIntersection(const OBB:TOBB;const v0,v1,v2:TVector3;const MTV:PVector3=nil):boolean;

function ClosestPointToLine(const LineStartPoint,LineEndPoint,Point:TVector3;const ClosestPointOnLine:PVector3=nil;const Time:psingle=nil):single;
function ClosestPointToAABB(const AABB:TAABB;const Point:TVector3;const ClosestPointOnAABB:PVector3=nil):single; {$ifdef caninline}inline;{$endif}
function ClosestPointToOBB(const OBB:TOBB;const Point:TVector3;out ClosestPoint:TVector3):single; {$ifdef caninline}inline;{$endif}
function ClosestPointToSphere(const Sphere:TSphere;const Point:TVector3;out ClosestPoint:TVector3):single; {$ifdef caninline}inline;{$endif}
function ClosestPointToCapsule(const Capsule:TCapsule;const Point:TVector3;out ClosestPoint:TVector3):single; {$ifdef caninline}inline;{$endif}
function ClosestPointToTriangle(const a,b,c,p:TVector3;out ClosestPoint:TVector3):single;

function SquaredDistanceFromPointToTriangle(const p,a,b,c:TVector3):single; overload;
function SquaredDistanceFromPointToTriangle(const p,a,b,c:TSIMDVector3):single; overload;

function IsParallel(const a,b:TVector3;const Tolerance:single=1e-5):boolean; {$ifdef caninline}inline;{$endif}

function Vector3ToAnglesLDX(v:TVector3):TVector3;

procedure AnglesToVector3LDX(const Angles:TVector3;var ForwardVector,RightVector,UpVector:TVector3);

function UnsignedAngle(const v0,v1:TVector3):single; {$ifdef caninline}inline;{$endif}

function AngleDegClamp(a:single):single; {$ifdef caninline}inline;{$endif}
function AngleDegDiff(a,b:single):single; {$ifdef caninline}inline;{$endif}

function AngleClamp(a:single):single; {$ifdef caninline}inline;{$endif}
function AngleDiff(a,b:single):single; {$ifdef caninline}inline;{$endif}
function AngleLerp(a,b,x:single):single; {$ifdef caninline}inline;{$endif}

procedure CalculateShadowMapViewProjectionMatrixUSMOld(var ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;const LightPosition,LightDirection:TVector3;const ShadowRecieverAABB,ShadowCasterAABB:TAABB;var ZBias,ShadowMapZNear,ShadowMapZFar:single);

procedure CalculateShadowMapViewProjectionMatrixUSM(out ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;const LightDirection:TVector3;const ShadowRecieverAABB,ShadowCasterAABB:TAABB;out ZBias,ShadowMapZNear,ShadowMapZFar,SizeX,SizeY:single); overload;
procedure CalculateShadowMapViewProjectionMatrixUSM(out ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;const LightDirection:TVector3;const FocusPoints:PVector3s;const CountFocusPoints:longint;const Casters:PAABBs;const CountCasters:longint;out ZBias,ShadowMapZNear,ShadowMapZFar,SizeX,SizeY:single); overload;

procedure CalculateShadowMapViewProjectionMatrixXPSM(out ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;const LightDirection:TVector3;const ShadowRecieverPoints:PVector3s;const CountShadowRecieverPoints:longint;const ShadowCasterAABBs:PAABBs;const CountShadowCasterAABBs:longint;out ZBias,ShadowMapZNear,ShadowMapZFar:single);

procedure GetLiSPSMMatrix(out ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;const LightDirection:TVector3;const FocusPoints:PVector3s;const CountFocusPoints:longint;const Casters:PAABBs;const CountCasters:longint;const GLPSM:boolean;const lispsm_n,lispsm_nopt_weight:single;out ZBias,ShadowMapZNear,ShadowMapZFar:single);

procedure GetLiSPSMMatrix1(var ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;CameraZFar:single;const LightDirection:TVector3;const InvLight:TMatrix4x4;const SceneAABB:TAABB);
procedure GetLiSPSMMatrix2(var ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;const LightDirection:TVector3;const SceneAABB:TAABB);
procedure GetLiSPSMMatrix3(var ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;const LightDirection:TVector3;const SceneAABB,ViewAABB:TAABB);

function MaxOverlaps(const Min1,Max1,Min2,Max2:single;var LowerLim,UpperLim:single):boolean;

function PackFP32FloatToM6E5Float(const Value:single):longword;
function PackFP32FloatToM5E5Float(const Value:single):longword;
function Float32ToFloat11(const Value:single):longword;
function Float32ToFloat10(const Value:single):longword;
function FloatToHalfFloat(const Value:single):longword;
function HalfFloatToFloat(const Value:longword):single;

function ConvertRGB32FToRGB9E5(r,g,b:single):longword;
function ConvertRGB32FToR11FG11FB10F(const r,g,b:single):longword; {$ifdef caninline}inline;{$endif}

implementation

function RoundUpToPowerOfTwo(x:longword):longword; {$ifdef caninline}inline;{$endif}
begin
 dec(x);
 x:=x or (x shr 1);
 x:=x or (x shr 2);
 x:=x or (x shr 4);
 x:=x or (x shr 8);
 x:=x or (x shr 16);
 result:=x+1;
end;

function Modulo(x,y:single):single; {$ifdef caninline}inline;{$endif}
begin
 result:=x-(floor(x/y)*y);
end;

function ModuloPos(x,y:single):single; {$ifdef caninline}inline;{$endif}
begin
 if y>0.0 then begin
  result:=Modulo(x,y);
  while result<0.0 do begin
   result:=result+y;
  end;
  while result>=y do begin
   result:=result-y;
  end;
 end else begin
  result:=x;
 end;
end;

function IEEERemainder(x,y:single):single; {$ifdef caninline}inline;{$endif}
begin
 result:=x-(round(x/y)*y);
end;

function Modulus(x,y:single):single; {$ifdef caninline}inline;{$endif}
begin
 result:=(abs(x)-(abs(y)*(floor(abs(x)/abs(y)))))*sign(x);
end;

function GetSign(x:single):longint; {$ifdef caninline}inline;{$endif}
begin
 if x<-EPSILON then begin
  result:=-1;
 end else if x>EPSILON then begin
  result:=1;
 end else begin
  result:=0;
 end;
end;

function GetSignEx(x:single):longint; {$ifdef caninline}inline;{$endif}
begin
 if x<0.0 then begin
  result:=-1;
 end else if x>0.0 then begin
  result:=1;
 end else begin
  result:=0;
 end;
end;

function Sign(x:single):longint; {$ifdef caninline}inline;{$endif}
begin
 if x<0.0 then begin
  result:=-1;
 end else if x>0.0 then begin
  result:=1;
 end else begin
  result:=0;
 end;
end;

{function Min(a,b:single):single;
begin
 if a<b then begin
  result:=a;
 end else begin
  result:=b;
 end;
end;

function Max(a,b:single):single;
begin
 if a>b then begin
  result:=a;
 end else begin
  result:=b;
 end;
end;{}

function MinInt(a,b:longint):longint;
begin
 if a<b then begin
  result:=a;
 end else begin
  result:=b;
 end;
end;

function MaxInt(a,b:longint):longint;
begin
 if a>b then begin
  result:=a;
 end else begin
  result:=b;
 end;
end;

{function TAN(Angle:single):single;
begin
 result:=sin(Angle)/cos(Angle);
end;

function POW(Number,Exponent:single):single; assembler; pascal;
asm
 FLD Exponent
 FLD Number
 FYL2X
 FLD1
 FLD ST(1)
 FPREM
 F2XM1
 FADDP ST(1),ST
 FSCALE
 FSTP ST(1)
end;

function ArcTan2(y,x:single):single; assembler;
asm
 FLD y
 FLD x
 FPATAN
 FWAIT
end;

function ArcCos(x:single):single;
begin
 result:=ArcTan2(sqrt(1-sqr(x)),x);
end;

function ArcSin(x:single):single;
begin
 result:=ArcTan2(x,sqrt(1-sqr(x)));
end;{}

function Determinant4x4(const v0,v1,v2,v3:TVector4):single; {$ifdef caninline}inline;{$endif}
begin
 result:=(v0.w*v1.z*v2.y*v3.x)-(v0.z*v1.w*v2.y*v3.x)-
         (v0.w*v1.y*v2.z*v3.x)+(v0.y*v1.w*v2.z*v3.x)+
         (v0.z*v1.y*v2.w*v3.x)-(v0.y*v1.z*v2.w*v3.x)-
         (v0.w*v1.z*v2.x*v3.y)+(v0.z*v1.w*v2.x*v3.y)+
         (v0.w*v1.x*v2.z*v3.y)-(v0.x*v1.w*v2.z*v3.y)-
         (v0.z*v1.x*v2.w*v3.y)+(v0.x*v1.z*v2.w*v3.y)+
         (v0.w*v1.y*v2.x*v3.z)-(v0.y*v1.w*v2.x*v3.z)-
         (v0.w*v1.x*v2.y*v3.z)+(v0.x*v1.w*v2.y*v3.z)+
         (v0.y*v1.x*v2.w*v3.z)-(v0.x*v1.y*v2.w*v3.z)-
         (v0.z*v1.y*v2.x*v3.w)+(v0.y*v1.z*v2.x*v3.w)+
         (v0.z*v1.x*v2.y*v3.w)-(v0.x*v1.z*v2.y*v3.w)-
         (v0.y*v1.x*v2.z*v3.w)+(v0.x*v1.y*v2.z*v3.w);
end;

function SolveQuadraticRoots(const a,b,c:single;out t1,t2:single):boolean; {$ifdef caninline}inline;{$endif}
var d,InverseDenominator:single;
begin
 result:=false;
 d:=sqr(b)-(4.0*(a*c));
 if d>=0.0 then begin
  InverseDenominator:=1.0/(2.0*a);
  if abs(d)<EPSILON then begin
   t1:=(-b)*InverseDenominator;
   t2:=t1;
  end else begin
   d:=sqrt(d);
   t1:=((-b)-d)*InverseDenominator;
   t2:=((-b)+d)*InverseDenominator;
  end;
  result:=true;
 end;
end;

function LinearPolynomialRoot(const a,b:single):single; {$ifdef caninline}inline;{$endif}
begin
 if abs(a)>1e-12 then begin
  result:=-(b/a);
 end else begin
  result:=0.0;
 end;
end;

function QuadraticPolynomialRoot(const a,b,c:single):single; {$ifdef caninline}inline;{$endif}
var d,InverseDenominator,t0,t1:single;
begin
 if abs(a)>1e-12 then begin
  d:=sqr(b)-(4.0*(a*c));
  InverseDenominator:=1.0/(2.0*a);
  if d>=0.0 then begin
   if d<1e-12 then begin
    t0:=(-b)*InverseDenominator;
    t1:=t0;
   end else begin
    d:=sqrt(d);
    t0:=((-b)+d)*InverseDenominator;
    t1:=((-b)-d)*InverseDenominator;
   end;
   if abs(t0)<abs(t1) then begin
    result:=t0;
   end else begin
    result:=t1;
   end;
  end else begin
   result:=0.0;
  end;
 end else begin
  result:=LinearPolynomialRoot(b,c);
 end;
end;

function CubicPolynomialRoot(const a,b,c,d:single):single;
var f,g,h,hs,r,s,t,u,i,j,k,l,m,n,p,t0,t1,t2:single;
begin
 if abs(a)>1e-12 then begin
  if abs(1.0-a)<1e-12 then begin
   f:=((3.0*c)-sqr(b))/3.0;
   g:=((2.0*(b*sqr(b)))-(9.0*(b*c))+(27.0*d))/27.0;
   h:=(sqr(g)*0.25)+((f*sqr(f))/27.0);
   if (abs(f)<1e-12) and (abs(h)<1e-12) and (abs(g)<1e-12) then begin
    result:=d;
    if result<0.0 then begin
     result:=power(-result,1.0/3.0);
    end else begin
     result:=-power(result,1.0/3.0);
    end;
   end else if h>0.0 then begin
    hs:=sqrt(h);
    r:=(-(g*0.5))+hs;
    if r<0.0 then begin
     s:=-power(-r,1.0/3.0);
    end else begin
     s:=power(r,1.0/3.0);
    end;
    t:=(-(g*0.5))-hs;
    if t<0.0 then begin
     u:=-power(-t,1.0/3.0);
    end else begin
     u:=power(t,1.0/3.0);
    end;
    result:=(s+u)-(b/3.0);
   end else begin
    i:=sqrt((sqr(g)/4.0)-h);
    if i<0.0 then begin
     j:=-power(-i,1.0/3.0);
    end else begin
     j:=power(i,1.0/3.0);
    end;
    k:=ArcCos(-(g/(2.0*i)));
    l:=-j;
    m:=cos(k/3.0);
    n:=sqrt(3.0)*sin(k/3.0);
    p:=-(b/3.0);
    t0:=(2.0*(j*cos(k/3.0)))-(b/3.0);
    t1:=(l*(m+n))+p;
    t2:=(l*(m-n))+p;
    if abs(t0)<abs(t1) then begin
     if abs(t0)<abs(t2) then begin
      result:=t0;
     end else begin
      result:=t2;
     end;
    end else begin
     if abs(t1)<abs(t2) then begin
      result:=t1;
     end else begin
      result:=t2;
     end;
    end;
   end;
  end else begin
   f:=((3.0*(c/a))-(sqr(b)/sqr(a)))/3.0;
   g:=(((2.0*(b*sqr(b)))/(a*sqr(a)))-((9.0*(b*c))/sqr(a))+(27.0*(d/a)))/27.0;
   h:=(sqr(g)*0.25)+((f*sqr(f))/27.0);
   if (abs(f)<1e-12) and (abs(h)<1e-12) and (abs(g)<1e-12) then begin
    result:=d/a;
    if result<0.0 then begin
     result:=power(-result,1.0/3.0);
    end else begin
     result:=-power(result,1.0/3.0);
    end;
   end else if h>0.0 then begin
    hs:=sqrt(h);
    r:=(-(g*0.5))+hs;
    if r<0.0 then begin
     s:=-power(-r,1.0/3.0);
    end else begin
     s:=power(r,1.0/3.0);
    end;
    t:=(-(g*0.5))-hs;
    if t<0.0 then begin
     u:=-power(-t,1.0/3.0);
    end else begin
     u:=power(t,1.0/3.0);
    end;
    result:=(s+u)-(b/(3.0*a));
   end else begin
    i:=sqrt((sqr(g)/4.0)-h);
    if i<0.0 then begin
     j:=-power(-i,1.0/3.0);
    end else begin
     j:=power(i,1.0/3.0);
    end;
    k:=ArcCos(-(g/(2.0*i)));
    l:=-j;
    m:=cos(k/3.0);
    n:=sqrt(3.0)*sin(k/3.0);
    p:=-(b/(3.0*a));
    t0:=(2.0*(j*cos(k/3.0)))-(b/(3.0*a));
    t1:=(l*(m+n))+p;
    t2:=(l*(m-n))+p;
    if abs(t0)<abs(t1) then begin
     if abs(t0)<abs(t2) then begin
      result:=t0;
     end else begin
      result:=t2;
     end;
    end else begin
     if abs(t1)<abs(t2) then begin
      result:=t1;
     end else begin
      result:=t2;
     end;
    end;
   end;
  end;
 end else begin
  result:=QuadraticPolynomialRoot(b,c,d);
 end;
end;

function Vector2(x,y:single):TVector2; {$ifdef caninline}inline;{$endif}
begin
 result.x:=x;
 result.y:=y;
end;

function Vector3(x,y,z:single):TVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=x;
 result.y:=y;
 result.z:=z;
end;

function Vector3(const v:TSIMDVector3):TVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v.x;
 result.y:=v.y;
 result.z:=v.z;
end;

procedure Vector3(out o:TVector3;const v:TSIMDVector3); overload; {$ifdef caninline}inline;{$endif}
begin
 o.x:=v.x;
 o.y:=v.y;
 o.z:=v.z;
end;

function Vector3(const v:TVector4):TVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v.x;
 result.y:=v.y;
 result.z:=v.z;
end;

function SIMDVector3(x,y,z:single):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=x;
 result.y:=y;
 result.z:=z;
end;

function SIMDVector3(const v:TVector3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.Vector:=v;
end;

procedure SIMDVector3(out o:TSIMDVector3;const v:TVector3); overload; {$ifdef caninline}inline;{$endif}
begin
 o.Vector:=v;
end;

function SIMDVector3(const v:TVector4):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.Vector:=PVector3(pointer(@v))^;
end;

function Vector4(x,y,z:single;w:single=1.0):TVector4; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=x;
 result.y:=y;
 result.z:=z;
 result.w:=w;
end;

function Vector4(const v:TVector2;z:single=0.0;w:single=1.0):TVector4; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v.x;
 result.y:=v.y;
 result.z:=z;
 result.w:=w;
end;

function Vector4(const v:TVector3;w:single=1.0):TVector4; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v.x;
 result.y:=v.y;
 result.z:=v.z;
 result.w:=w;
end;

function Matrix3x3(const XX,xy,XZ,YX,YY,YZ,ZX,ZY,ZZ:single):TMatrix3x3; overload;
begin
 result[0,0]:=XX;
 result[0,1]:=YX;
 result[0,2]:=ZX;
 result[1,0]:=XY;
 result[1,1]:=YY;
 result[1,2]:=ZY;
 result[2,0]:=XZ;
 result[2,1]:=YZ;
 result[2,2]:=ZZ;
end;

function Matrix3x3(const x,y,z:TVector3):TMatrix3x3; overload;
begin
 result[0,0]:=x.x;
 result[0,1]:=x.y;
 result[0,2]:=x.z;
 result[1,0]:=y.x;
 result[1,1]:=y.y;
 result[1,2]:=y.z;
 result[2,0]:=z.x;
 result[2,1]:=z.y;
 result[2,2]:=z.z;
end;

function Matrix3x3(const m:TMatrix4x4):TMatrix3x3; overload;
begin
 result[0,0]:=m[0,0];
 result[0,1]:=m[0,1];
 result[0,2]:=m[0,2];
 result[1,0]:=m[1,0];
 result[1,1]:=m[1,1];
 result[1,2]:=m[1,2];
 result[2,0]:=m[2,0];
 result[2,1]:=m[2,1];
 result[2,2]:=m[2,2];
end;

function Matrix3x3Raw(const XX,XY,XZ,YX,YY,YZ,ZX,ZY,ZZ:single):TMatrix3x3;
begin
 result[0,0]:=XX;
 result[0,1]:=XY;
 result[0,2]:=XZ;
 result[1,0]:=YX;
 result[1,1]:=YY;
 result[1,2]:=YZ;
 result[2,0]:=ZX;
 result[2,1]:=ZY;
 result[2,2]:=ZZ;
end;

function Matrix3x4(const m:TMatrix3x3):TMatrix3x4; overload;
{$ifdef cpu386asm}
const Mask:array[0..3] of longword=($ffffffff,$ffffffff,$ffffffff,$00000000);
asm
 movups xmm3,dqword ptr [m+0]
 movups xmm4,dqword ptr [m+12]
 movss xmm5,dword ptr [m+24]
 movss xmm6,dword ptr [m+28]
 movlhps xmm5,xmm6
 movss xmm6,dword ptr [m+32]
 shufps xmm5,xmm6,$88
 movups xmm6,dqword ptr [Mask]
 andps xmm3,xmm6
 andps xmm4,xmm6
 andps xmm5,xmm6
 movups dqword ptr [result+0],xmm3
 movups dqword ptr [result+16],xmm4
 movups dqword ptr [result+32],xmm5
end;
{$else}
begin
 PVector3(pointer(@result[0,0]))^:=PVector3(pointer(@m[0,0]))^;
 result[0,3]:=0.0;
 PVector3(pointer(@result[1,0]))^:=PVector3(pointer(@m[1,0]))^;
 result[1,3]:=0.0;
 PVector3(pointer(@result[2,0]))^:=PVector3(pointer(@m[2,0]))^;
 result[2,3]:=0.0;
end;
{$endif}

procedure Matrix3x4(out o:TMatrix3x4;const m:TMatrix3x3); overload;
{$ifdef cpu386asm}
const Mask:array[0..3] of longword=($ffffffff,$ffffffff,$ffffffff,$00000000);
asm
 movups xmm3,dqword ptr [m+0]
 movups xmm4,dqword ptr [m+12]
 movss xmm5,dword ptr [m+24]
 movss xmm6,dword ptr [m+28]
 movlhps xmm5,xmm6
 movss xmm6,dword ptr [m+32]
 shufps xmm5,xmm6,$88
 movups xmm6,dqword ptr [Mask]
 andps xmm3,xmm6
 andps xmm4,xmm6
 andps xmm5,xmm6
 movups dqword ptr [o+0],xmm3
 movups dqword ptr [o+16],xmm4
 movups dqword ptr [o+32],xmm5
end;
{$else}
begin
 PVector3(pointer(@o[0,0]))^:=PVector3(pointer(@m[0,0]))^;
 o[0,3]:=0.0;
 PVector3(pointer(@o[1,0]))^:=PVector3(pointer(@m[1,0]))^;
 o[1,3]:=0.0;
 PVector3(pointer(@o[2,0]))^:=PVector3(pointer(@m[2,0]))^;
 o[2,3]:=0.0;
end;
{$endif}

function Matrix4x4(const XX,XY,XZ,XW,YX,YY,YZ,YW,ZX,ZY,ZZ,ZW,WX,WY,WZ,WW:single):TMatrix4x4; overload;
begin
 result[0,0]:=XX;
 result[0,1]:=YX;
 result[0,2]:=ZX;
 result[0,3]:=WX;
 result[1,0]:=XY;
 result[1,1]:=YY;
 result[1,2]:=ZY;
 result[1,3]:=WY;
 result[2,0]:=XZ;
 result[2,1]:=YZ;
 result[2,2]:=ZZ;
 result[2,3]:=WZ;
 result[3,0]:=XW;
 result[3,1]:=YW;
 result[3,2]:=ZW;
 result[3,3]:=WW;
end;

function Matrix4x4(const x,y,z,w:TVector4):TMatrix4x4; overload;
begin
 result[0,0]:=x.x;
 result[0,1]:=x.y;
 result[0,2]:=x.z;
 result[0,3]:=x.w;
 result[1,0]:=y.x;
 result[1,1]:=y.y;
 result[1,2]:=y.z;
 result[1,3]:=y.w;
 result[2,0]:=z.x;
 result[2,1]:=z.y;
 result[2,2]:=z.z;
 result[2,3]:=z.w;
 result[3,0]:=w.x;
 result[3,1]:=w.y;
 result[3,2]:=w.z;
 result[3,3]:=w.w;
end;

function Matrix4x4(const m:TMatrix3x3):TMatrix4x4; overload;
const LastRow:TVector4=(x:0.0;y:0.0;z:0.0;w:1.0);
{$ifdef cpu386asm}
const Mask:array[0..3] of longword=($ffffffff,$ffffffff,$ffffffff,$00000000);
asm
 movups xmm3,dqword ptr [m+0]
 movups xmm4,dqword ptr [m+12]
 movss xmm5,dword ptr [m+24]
 movss xmm6,dword ptr [m+28]
 movlhps xmm5,xmm6
 movss xmm6,dword ptr [m+32]
 shufps xmm5,xmm6,$88
 movups xmm6,dqword ptr [LastRow]
 movups xmm7,dqword ptr [Mask]
 andps xmm3,xmm7
 andps xmm4,xmm7
 andps xmm5,xmm7
 movups dqword ptr [result+0],xmm3
 movups dqword ptr [result+16],xmm4
 movups dqword ptr [result+32],xmm5
 movups dqword ptr [result+48],xmm6
end;
{$else}
begin
 PVector3(pointer(@result[0,0]))^:=PVector3(pointer(@m[0,0]))^;
 result[0,3]:=0.0;
 PVector3(pointer(@result[1,0]))^:=PVector3(pointer(@m[1,0]))^;
 result[1,3]:=0.0;
 PVector3(pointer(@result[2,0]))^:=PVector3(pointer(@m[2,0]))^;
 result[2,3]:=0.0;
 PVector4(pointer(@result[3,0]))^:=LastRow;
end;
{$endif}

function Matrix4x4Raw(const XX,XY,XZ,XW,YX,YY,YZ,YW,ZX,ZY,ZZ,ZW,WX,WY,WZ,WW:single):TMatrix4x4;
begin
 result[0,0]:=XX;
 result[0,1]:=XY;
 result[0,2]:=XZ;
 result[0,3]:=XW;
 result[1,0]:=YX;
 result[1,1]:=YY;
 result[1,2]:=YZ;
 result[1,3]:=YW;
 result[2,0]:=ZX;
 result[2,1]:=ZY;
 result[2,2]:=ZZ;
 result[2,3]:=ZW;
 result[3,0]:=WX;
 result[3,1]:=WY;
 result[3,2]:=WZ;
 result[3,3]:=WW;
end;

function Plane(a,b,c,d:single):TPlane; overload; {$ifdef caninline}inline;{$endif}
begin
 result.a:=a;
 result.b:=b;
 result.c:=c;
 result.d:=d;
end;

function Plane(Normal:TVector3;Distance:single):TPlane; overload; {$ifdef caninline}inline;{$endif}
begin
 result.Normal:=Normal;
 result.Distance:=Distance;
end;

function Quaternion(w,x,y,z:single):TQuaternion; {$ifdef caninline}inline;{$endif}
begin
 result.w:=w;
 result.x:=x;
 result.y:=y;
 result.z:=z;
end;

function Angles(Pitch,Yaw,Roll:single):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.Pitch:=Pitch;
 result.Yaw:=Yaw;
 result.Roll:=Roll;
end;

function FloatLerp(const v1,v2,w:single):single; {$ifdef caninline}inline;{$endif}
begin
 if w<0.0 then begin
  result:=v1;
 end else if w>1.0 then begin
  result:=v2;
 end else begin
  result:=(v1*(1.0-w))+(v2*w);
 end;
end;

function Vector2Compare(const v1,v2:TVector2):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=(abs(v1.x-v2.x)<EPSILON) and (abs(v1.y-v2.y)<EPSILON);
end;

function Vector2CompareEx(const v1,v2:TVector2;const Threshold:single=1e-12):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=(abs(v1.x-v2.x)<Threshold) and (abs(v1.y-v2.y)<Threshold);
end;

function Vector2Add(const v1,v2:TVector2):TVector2; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v1.x+v2.x;
 result.y:=v1.y+v2.y;
end;

function Vector2Sub(const v1,v2:TVector2):TVector2; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v1.x-v2.x;
 result.y:=v1.y-v2.y;
end;

function Vector2Avg(const v1,v2:TVector2):TVector2; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(v1.x+v2.x)*0.5;
 result.y:=(v1.y+v2.y)*0.5;
end;

function Vector2ScalarMul(const v:TVector2;s:single):TVector2; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v.x*s;
 result.y:=v.y*s;
end;

function Vector2Dot(const v1,v2:TVector2):single; {$ifdef caninline}inline;{$endif}
begin
 result:=(v1.x*v2.x)+(v1.y*v2.y);
end;

function Vector2Neg(const v:TVector2):TVector2; {$ifdef caninline}inline;{$endif}
begin
 result.x:=-v.x;
 result.y:=-v.y;
end;

procedure Vector2Scale(var v:TVector2;sx,sy:single); overload; {$ifdef caninline}inline;{$endif}
begin
 v.x:=v.x*sx;
 v.y:=v.y*sy;
end;

procedure Vector2Scale(var v:TVector2;s:single); overload; {$ifdef caninline}inline;{$endif}
begin
 v.x:=v.x*s;
 v.y:=v.y*s;
end;

function Vector2Mul(const v1,v2:TVector2):TVector2; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v1.x*v2.x;
 result.y:=v1.y*v2.y;
end;

function Vector2Length(const v:TVector2):single; {$ifdef caninline}inline;{$endif}
begin
 result:=sqrt(sqr(v.x)+sqr(v.y));
end;

function Vector2Dist(const v1,v2:TVector2):single; {$ifdef caninline}inline;{$endif}
begin
 result:=Vector2Length(Vector2Sub(v2,v1));
end;

function Vector2LengthSquared(const v:TVector2):single; {$ifdef caninline}inline;{$endif}
begin
 result:=sqr(v.x)+sqr(v.y);
end;

function Vector2Angle(const v1,v2,v3:TVector2):single; {$ifdef caninline}inline;{$endif}
var A1,A2:TVector2;
    L1,L2:single;
begin
 A1:=Vector2Sub(v1,v2);
 A2:=Vector2Sub(v3,v2);
 L1:=Vector2Length(A1);
 L2:=Vector2Length(A2);
 if (L1=0) or (L2=0) then begin
  result:=0;
 end else begin
  result:=ArcCos(Vector2Dot(A1,A2)/(L1*L2));
 end;
end;

procedure Vector2Normalize(var v:TVector2); {$ifdef caninline}inline;{$endif}
var L:single;
begin
 L:=Vector2Length(v);
 if abs(L)>EPSILON then begin
  Vector2Scale(v,1/L);
 end else begin
  v:=Vector2Origin;
 end;
end;

function Vector2Norm(const v:TVector2):TVector2; {$ifdef caninline}inline;{$endif}
var L:single;
begin
 L:=Vector2Length(v);
 if abs(L)>EPSILON then begin
  result:=Vector2ScalarMul(v,1/L);
 end else begin
  result:=Vector2Origin;
 end;
end;

procedure Vector2Rotate(var v:TVector2;a:single); overload; {$ifdef caninline}inline;{$endif}
var r:TVector2;
begin
 r.x:=(v.x*cos(a))-(v.y*sin(a));
 r.y:=(v.y*cos(a))+(v.x*sin(a));
 v:=r;
end;

procedure Vector2Rotate(var v:TVector2;const Center:TVector2;a:single); overload; {$ifdef caninline}inline;{$endif}
var V0,r:TVector2;
begin
 V0:=Vector2Sub(v,Center);
 r.x:=(V0.x*cos(a))-(V0.y*sin(a));
 r.y:=(V0.y*cos(a))+(V0.x*sin(a));
 v:=Vector2Add(r,Center);
end;

procedure Vector2MatrixMul(var v:TVector2;const m:TMatrix2x2); {$ifdef caninline}inline;{$endif}
var t:TVector2;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y);
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y);
 v:=t;
end;

function Vector2TermMatrixMul(const v:TVector2;const m:TMatrix2x2):TVector2; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y);
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y);
end;

function Vector2Lerp(const v1,v2:TVector2;w:single):TVector2; {$ifdef caninline}inline;{$endif}
var iw:single;
begin
 if w<0.0 then begin
  result:=v1;
 end else if w>1.0 then begin
  result:=v2;
 end else begin
  iw:=1.0-w;
  result.x:=(iw*v1.x)+(w*v2.x);
  result.y:=(iw*v1.y)+(w*v2.y);
 end;
end;

function Vector3Flip(const v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v.x;
 result.y:=v.z;
 result.z:=-v.y;
end;

function Vector3Abs(const v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=abs(v.x);
 result.y:=abs(v.y);
 result.z:=abs(v.z);
end;

function Vector3Compare(const v1,v2:TVector3):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=(abs(v1.x-v2.x)<EPSILON) and (abs(v1.y-v2.y)<EPSILON) and (abs(v1.z-v2.z)<EPSILON);
end;

function Vector3CompareEx(const v1,v2:TVector3;const Threshold:single=1e-12):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=(abs(v1.x-v2.x)<Threshold) and (abs(v1.y-v2.y)<Threshold) and (abs(v1.z-v2.z)<Threshold);
end;

function Vector3DirectAdd(var v1:TVector3;const v2:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
begin
 v1.x:=v1.x+v2.x;
 v1.y:=v1.y+v2.y;
 v1.z:=v1.z+v2.z;
end;

function Vector3DirectSub(var v1:TVector3;const v2:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
begin
 v1.x:=v1.x-v2.x;
 v1.y:=v1.y-v2.y;
 v1.z:=v1.z-v2.z;
end;

function Vector3Add(const v1,v2:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v1.x+v2.x;
 result.y:=v1.y+v2.y;
 result.z:=v1.z+v2.z;
end;

function Vector3Sub(const v1,v2:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v1.x-v2.x;
 result.y:=v1.y-v2.y;
 result.z:=v1.z-v2.z;
end;

function Vector3Avg(const v1,v2:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(v1.x+v2.x)*0.5;
 result.y:=(v1.y+v2.y)*0.5;
 result.z:=(v1.z+v2.z)*0.5;
end;

function Vector3Avg(const v1,v2,v3:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(v1.x+v2.x+v3.x)/3.0;
 result.y:=(v1.y+v2.y+v3.y)/3.0;
 result.z:=(v1.z+v2.z+v3.z)/3.0;
end;

function Vector3Avg(const va:PVector3s;Count:longint):TVector3; {$ifdef caninline}inline;{$endif}
var i:longint;
begin
 result.x:=0.0;
 result.y:=0.0;
 result.z:=0.0;
 if Count>0 then begin
  for i:=0 to Count-1 do begin
   result.x:=result.x+va^[i].x;
   result.y:=result.y+va^[i].y;
   result.z:=result.z+va^[i].z;
  end;
  result.x:=result.x/Count;
  result.y:=result.y/Count;
  result.z:=result.z/Count;
 end;
end;

function Vector3ScalarMul(const v:TVector3;const s:single):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v.x*s;
 result.y:=v.y*s;
 result.z:=v.z*s;
end;

function Vector3Dot(const v1,v2:TVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=(v1.x*v2.x)+(v1.y*v2.y)+(v1.z*v2.z);
end;

function Vector3Cos(const v1,v2:TVector3):single; {$ifdef caninline}inline;{$endif}
var d:extended;
begin
 d:=SQRT(Vector3LengthSquared(v1)*Vector3LengthSquared(v2));
 if d<>0 then begin
  result:=((v1.x*v2.x)+(v1.y*v2.y)+(v1.z*v2.z))/d; //result:=Vector3Dot(v1,v2)/d;
 end else begin
  result:=0;
 end
end;

function Vector3GetOneUnitOrthogonalVector(const v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
var MinimumAxis:longint;
    l:single;
begin
 if abs(v.x)<abs(v.y) then begin
  if abs(v.x)<abs(v.z) then begin
   MinimumAxis:=0;
  end else begin
   MinimumAxis:=2;
  end;
 end else begin
  if abs(v.y)<abs(v.z) then begin
   MinimumAxis:=1;
  end else begin
   MinimumAxis:=2;
  end;
 end;
 case MinimumAxis of
  0:begin
   l:=sqrt(sqr(v.y)+sqr(v.z));
   result.x:=0.0;
   result.y:=-(v.z/l);
   result.z:=v.y/l;
  end;
  1:begin
   l:=sqrt(sqr(v.x)+sqr(v.z));
   result.x:=-(v.z/l);
   result.y:=0.0;
   result.z:=v.x/l;
  end;
  else begin
   l:=sqrt(sqr(v.x)+sqr(v.y));
   result.x:=-(v.y/l);
   result.y:=v.x/l;
   result.z:=0.0;
  end;
 end;
end;

function Vector3Cross(const v1,v2:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(v1.y*v2.z)-(v1.z*v2.y);
 result.y:=(v1.z*v2.x)-(v1.x*v2.z);
 result.z:=(v1.x*v2.y)-(v1.y*v2.x);
end;

function Vector3Neg(const v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=-v.x;
 result.y:=-v.y;
 result.z:=-v.z;
end;

procedure Vector3Scale(var v:TVector3;const sx,sy,sz:single); overload; {$ifdef caninline}inline;{$endif}
begin
 v.x:=v.x*sx;
 v.y:=v.y*sy;
 v.z:=v.z*sz;
end;

procedure Vector3Scale(var v:TVector3;const s:single); overload; {$ifdef caninline}inline;{$endif}
begin
 v.x:=v.x*s;
 v.y:=v.y*s;
 v.z:=v.z*s;
end;

function Vector3Mul(const v1,v2:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v1.x*v2.x;
 result.y:=v1.y*v2.y;
 result.z:=v1.z*v2.z;
end;

function Vector3Length(const v:TVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z));
end;

function Vector3Dist(const v1,v2:TVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=sqrt(sqr(v2.x-v1.x)+sqr(v2.y-v1.y)+sqr(v2.z-v1.z));
end;

function Vector3LengthSquared(const v:TVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=sqr(v.x)+sqr(v.y)+sqr(v.z);
end;

function Vector3DistSquared(const v1,v2:TVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=sqr(v2.x-v1.x)+sqr(v2.y-v1.y)+sqr(v2.z-v1.z);
end;

function Vector3Angle(const v1,v2,v3:TVector3):single; {$ifdef caninline}inline;{$endif}
var A1,A2:TVector3;
    L1,L2:single;
begin
 A1:=Vector3Sub(v1,v2);
 A2:=Vector3Sub(v3,v2);
 L1:=Vector3Length(A1);
 L2:=Vector3Length(A2);
 if (L1=0) or (L2=0) then begin
  result:=0;
 end else begin
  result:=ArcCos(Vector3Dot(A1,A2)/(L1*L2));
 end;
end;

function Vector3LengthNormalize(var v:TVector3):single; {$ifdef caninline}inline;{$endif}
var l:single;
begin
 result:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if result>EPSILON then begin
  result:=sqrt(result);
  l:=1.0/result;
  v.x:=v.x*l;
  v.y:=v.y*l;
  v.z:=v.z*l;
 end else begin
  result:=0.0;
  v.x:=0.0;
  v.y:=0.0;
  v.z:=0.0;
 end;
end;

function Vector3Normalize(var v:TVector3):single; {$ifdef caninline}inline;{$endif}
var l:single;
begin
 result:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if result>EPSILON then begin
  result:=sqrt(result);
  l:=1.0/result;
  v.x:=v.x*l;
  v.y:=v.y*l;
  v.z:=v.z*l;
 end else begin
  result:=0.0;
  v.x:=0.0;
  v.y:=0.0;
  v.z:=0.0;
 end;
end;

function Vector3NormalizeEx(var v:TVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if result>EPSILON then begin
  result:=sqrt(result);
  v.x:=v.x/result;
  v.y:=v.y/result;
  v.z:=v.z/result;
 end else begin
  result:=0.0;
  v.x:=0.0;
  v.y:=0.0;
  v.z:=0.0;
 end;
end;

function Vector3SafeNorm(const v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
var l:single;
begin
 l:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if l>sqr(EPSILON) then begin
  l:=1.0/sqrt(l);
  result.x:=v.x*l;
  result.y:=v.y*l;
  result.z:=v.z*l;
 end else begin
  result.x:=1.0;
  result.y:=0.0;
  result.z:=0.0;
 end;
end;

function Vector3Norm(const v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
var l:single;
begin
 l:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if l>sqr(EPSILON) then begin
  l:=1.0/sqrt(l);
  result.x:=v.x*l;
  result.y:=v.y*l;
  result.z:=v.z*l;
 end else begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
 end;
end;

function Vector3NormEx(const v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
var l:single;
begin
 l:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if l>EPSILON then begin
  l:=sqrt(l);
  result.x:=v.x/l;
  result.y:=v.y/l;
  result.z:=v.z/l;
 end else begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
 end;
end;

procedure Vector3RotateX(var v:TVector3;a:single); {$ifdef caninline}inline;{$endif}
var t:TVector3;
begin
 t.x:=v.x;
 t.y:=(v.y*cos(a))-(v.z*sin(a));
 t.z:=(v.y*sin(a))+(v.z*cos(a));
 v:=t;
end;

procedure Vector3RotateY(var v:TVector3;a:single); {$ifdef caninline}inline;{$endif}
var t:TVector3;
begin
 t.x:=(v.x*cos(a))+(v.z*sin(a));
 t.y:=v.y;
 t.z:=(v.z*cos(a))-(v.x*sin(a));
 v:=t;
end;

procedure Vector3RotateZ(var v:TVector3;a:single); {$ifdef caninline}inline;{$endif}
var t:TVector3;
begin
 t.x:=(v.x*cos(a))-(v.y*sin(a));
 t.y:=(v.x*sin(a))+(v.y*cos(a));
 t.z:=v.z;
 v:=t;
end;

procedure Vector3MatrixMul(var v:TVector3;const m:TMatrix3x3); overload; {$ifdef caninline}inline;{$endif}
var t:TVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
 v:=t;
end;

procedure Vector3MatrixMul(var v:TVector3;const m:TMatrix4x3); overload; {$ifdef caninline}inline;{$endif}
var t:TVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
 v:=t;
end;

procedure Vector3MatrixMul(var v:TVector3;const m:TMatrix4x4); overload; {$ifdef cpu386asm}assembler;{$endif}
{$ifdef cpu386asm}
const cOne:single=1.0;
asm
{mov eax,v
 mov edx,m}
 sub esp,16
 movss xmm0,dword ptr [eax]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 movss xmm3,dword ptr cOne
 movss dword ptr [esp],xmm0
 movss dword ptr [esp+4],xmm1
 movss dword ptr [esp+8],xmm2
 movss dword ptr [esp+12],xmm3
 movups xmm0,[esp]              // d c b a
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 movaps xmm3,xmm0               // d c b a
 shufps xmm0,xmm0,$00           // a a a a 00000000b
 shufps xmm1,xmm1,$55           // b b b b 01010101b
 shufps xmm2,xmm2,$aa           // c c c c 10101010b
 shufps xmm3,xmm3,$ff           // d d d d 11111111b
 movups xmm4,[edx+0]
 movups xmm5,[edx+16]
 movups xmm6,[edx+32]
 movups xmm7,[edx+48]
 mulps xmm0,xmm4
 mulps xmm1,xmm5
 mulps xmm2,xmm6
 mulps xmm3,xmm7
 addps xmm0,xmm1
 addps xmm2,xmm3
 addps xmm0,xmm2
 movups [esp],xmm0
 movss xmm0,dword ptr [esp]
 movss xmm1,dword ptr [esp+4]
 movss xmm2,dword ptr [esp+8]
 movss dword ptr [eax],xmm0
 movss dword ptr [eax+4],xmm1
 movss dword ptr [eax+8],xmm2
 add esp,16
end;
{$else}
var t:TVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
 v:=t;
end;
{$endif}

procedure Vector3MatrixMulBasis(var v:TVector3;const m:TMatrix4x3); overload; {$ifdef caninline}inline;{$endif}
var t:TVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
 v:=t;
end;

procedure Vector3MatrixMulBasis(var v:TVector3;const m:TMatrix4x4); overload; {$ifdef caninline}inline;{$endif}
var t:TVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
 v:=t;
end;

procedure Vector3MatrixMulInverted(var v:TVector3;const m:TMatrix4x3); overload; {$ifdef caninline}inline;{$endif}
var p,t:TVector3;
begin
 p.x:=v.x-m[3,0];
 p.y:=v.y-m[3,1];
 p.z:=v.z-m[3,2];
 t.x:=(m[0,0]*p.x)+(m[0,1]*p.y)+(m[0,2]*p.z);
 t.y:=(m[1,0]*p.x)+(m[1,1]*p.y)+(m[1,2]*p.z);
 t.z:=(m[2,0]*p.x)+(m[2,1]*p.y)+(m[2,2]*p.z);
 v:=t;
end;

procedure Vector3MatrixMulInverted(var v:TVector3;const m:TMatrix4x4); overload; {$ifdef caninline}inline;{$endif}
var p,t:TVector3;
begin
 p.x:=v.x-m[3,0];
 p.y:=v.y-m[3,1];
 p.z:=v.z-m[3,2];
 t.x:=(m[0,0]*p.x)+(m[0,1]*p.y)+(m[0,2]*p.z);
 t.y:=(m[1,0]*p.x)+(m[1,1]*p.y)+(m[1,2]*p.z);
 t.z:=(m[2,0]*p.x)+(m[2,1]*p.y)+(m[2,2]*p.z);
 v:=t;
end;

function Vector3TermMatrixMul(const v:TVector3;const m:TMatrix3x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
end;

function Vector3TermMatrixMul(const v:TVector3;const m:TMatrix3x4):TVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
end;

function Vector3TermMatrixMul(const v:TVector3;const m:TMatrix4x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
end;

function Vector3TermMatrixMulInverse(const v:TVector3;const m:TMatrix3x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
var Determinant:single;
begin
 Determinant:=((m[0,0]*((m[1,1]*m[2,2])-(m[2,1]*m[1,2])))-
               (m[0,1]*((m[1,0]*m[2,2])-(m[2,0]*m[1,2]))))+
               (m[0,2]*((m[1,0]*m[2,1])-(m[2,0]*m[1,1])));
 if abs(Determinant)>EPSILON then begin
  Determinant:=1.0/Determinant;
 end;
 result.x:=((v.x*((m[1,1]*m[2,2])-(m[1,2]*m[2,1])))+(v.y*((m[1,2]*m[2,0])-(m[1,0]*m[2,2])))+(v.z*((m[1,0]*m[2,1])-(m[1,1]*m[2,0]))))*Determinant;
 result.y:=((m[0,0]*((v.y*m[2,2])-(v.z*m[2,1])))+(m[0,1]*((v.z*m[2,0])-(v.x*m[2,2])))+(m[0,2]*((v.x*m[2,1])-(v.y*m[2,0]))))*Determinant;
 result.z:=((m[0,0]*((m[1,1]*v.z)-(m[1,2]*v.y)))+(m[0,1]*((m[1,2]*v.x)-(m[1,0]*v.z)))+(m[0,2]*((m[1,0]*v.y)-(m[1,1]*v.x))))*Determinant;
end;

function Vector3TermMatrixMulInverse(const v:TVector3;const m:TMatrix4x3):TVector3; overload;
var Determinant:single;
begin
 Determinant:=((m[0,0]*((m[1,1]*m[2,2])-(m[2,1]*m[1,2])))-
               (m[0,1]*((m[1,0]*m[2,2])-(m[2,0]*m[1,2]))))+
               (m[0,2]*((m[1,0]*m[2,1])-(m[2,0]*m[1,1])));
 if abs(Determinant)>EPSILON then begin
  Determinant:=1.0/Determinant;
 end;
 result.x:=((v.x*((m[1,1]*m[2,2])-(m[1,2]*m[2,1])))+(v.y*((m[1,2]*m[2,0])-(m[1,0]*m[2,2])))+(v.z*((m[1,0]*m[2,1])-(m[1,1]*m[2,0]))))*Determinant;
 result.y:=((m[0,0]*((v.y*m[2,2])-(v.z*m[2,1])))+(m[0,1]*((v.z*m[2,0])-(v.x*m[2,2])))+(m[0,2]*((v.x*m[2,1])-(v.y*m[2,0]))))*Determinant;
 result.z:=((m[0,0]*((m[1,1]*v.z)-(m[1,2]*v.y)))+(m[0,1]*((m[1,2]*v.x)-(m[1,0]*v.z)))+(m[0,2]*((m[1,0]*v.y)-(m[1,1]*v.x))))*Determinant;
end;

function Vector3TermMatrixMulInverted(const v:TVector3;const m:TMatrix4x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
var p:TVector3;
begin
 p.x:=v.x-m[3,0];
 p.y:=v.y-m[3,1];
 p.z:=v.z-m[3,2];
 result.x:=(m[0,0]*p.x)+(m[0,1]*p.y)+(m[0,2]*p.z);
 result.y:=(m[1,0]*p.x)+(m[1,1]*p.y)+(m[1,2]*p.z);
 result.z:=(m[2,0]*p.x)+(m[2,1]*p.y)+(m[2,2]*p.z);
end;

function Vector3TermMatrixMulInverted(const v:TVector3;const m:TMatrix4x4):TVector3; overload; {$ifdef caninline}inline;{$endif}
var p:TVector3;
begin
 p.x:=v.x-m[3,0];
 p.y:=v.y-m[3,1];
 p.z:=v.z-m[3,2];
 result.x:=(m[0,0]*p.x)+(m[0,1]*p.y)+(m[0,2]*p.z);
 result.y:=(m[1,0]*p.x)+(m[1,1]*p.y)+(m[1,2]*p.z);
 result.z:=(m[2,0]*p.x)+(m[2,1]*p.y)+(m[2,2]*p.z);
end;

function Vector3TermMatrixMulTransposed(const v:TVector3;const m:TMatrix3x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z);
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z);
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z);
end;

function Vector3TermMatrixMulTransposed(const v:TVector3;const m:TMatrix4x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z);
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z);
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z);
end;

function Vector3TermMatrixMulTransposed(const v:TVector3;const m:TMatrix4x4):TVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z)+m[0,3];
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z)+m[1,3];
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z)+m[2,3];
end;

function Vector3TermMatrixMulTransposedBasis(const v:TVector3;const m:TMatrix4x4):TVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z);
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z);
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z);
end;

function Vector3TermMatrixMulTransposedBasis(const v:TVector3;const m:TMatrix4x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z);
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z);
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z);
end;

function Vector3TermMatrixMulHomogen(const v:TVector3;const m:TMatrix4x4):TVector3; {$ifdef caninline}inline;{$endif}
var result_w:single;
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
 result_w:=(m[0,3]*v.x)+(m[1,3]*v.y)+(m[2,3]*v.z)+m[3,3];
 result.x:=result.x/result_w;
 result.y:=result.y/result_w;
 result.z:=result.z/result_w;
end;

function Vector3TermMatrixMulBasis(const v:TVector3;const m:TMatrix4x3):TVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
end;

function Vector3TermMatrixMulBasis(const v:TVector3;const m:TMatrix4x4):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
end;

function Vector3TermMatrixMul(const v:TVector3;const m:TMatrix4x4):TVector3; overload;{$ifdef cpu386asm}assembler;{$endif}
{$ifdef cpu386asm}
const cOne:single=1.0;
asm
{mov eax,v
 mov edx,m
 mov ecx,result}
 sub esp,16
 movss xmm0,dword ptr [eax]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 movss xmm3,dword ptr cOne
 movss dword ptr [esp],xmm0
 movss dword ptr [esp+4],xmm1
 movss dword ptr [esp+8],xmm2
 movss dword ptr [esp+12],xmm3
 movups xmm0,[esp]              // d c b a
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 movaps xmm3,xmm0               // d c b a
 shufps xmm0,xmm0,$00           // a a a a 00000000b
 shufps xmm1,xmm1,$55           // b b b b 01010101b
 shufps xmm2,xmm2,$aa           // c c c c 10101010b
 shufps xmm3,xmm3,$ff           // d d d d 11111111b
 movups xmm4,[edx+0]
 movups xmm5,[edx+16]
 movups xmm6,[edx+32]
 movups xmm7,[edx+48]
 mulps xmm0,xmm4
 mulps xmm1,xmm5
 mulps xmm2,xmm6
 mulps xmm3,xmm7
 addps xmm0,xmm1
 addps xmm2,xmm3
 addps xmm0,xmm2
 movups [esp],xmm0
 movss xmm0,dword ptr [esp]
 movss xmm1,dword ptr [esp+4]
 movss xmm2,dword ptr [esp+8]
 movss dword ptr [ecx],xmm0
 movss dword ptr [ecx+4],xmm1
 movss dword ptr [ecx+8],xmm2
 add esp,16
end;
{$else}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
end;
{$endif}

procedure Vector3Rotate(var v:TVector3;const Axis:TVector3;a:single); {$ifdef caninline}inline;{$endif}
begin
 Vector3MatrixMul(v,Matrix3x3Rotate(a,Axis));
end;

function Vector3Lerp(const v1,v2:TVector3;w:single):TVector3; {$ifdef caninline}inline;{$endif}
var iw:single;
begin
 if w<0.0 then begin
  result:=v1;
 end else if w>1.0 then begin
  result:=v2;
 end else begin
  iw:=1.0-w;
  result.x:=(iw*v1.x)+(w*v2.x);
  result.y:=(iw*v1.y)+(w*v2.y);
  result.z:=(iw*v1.z)+(w*v2.z);
 end;
end;

function Vector3Perpendicular(v:TVector3):TVector3; {$ifdef caninline}inline;{$endif}
var p:TVector3;
begin
 Vector3Normalize(v);
 p.x:=abs(v.x);
 p.y:=abs(v.y);
 p.z:=abs(v.z);
 if (p.x<=p.y) and (p.x<=p.z) then begin
  p:=Vector3XAxis;
 end else if (p.y<=p.x) and (p.y<=p.z) then begin
  p:=Vector3YAxis;
 end else begin
  p:=Vector3ZAxis;
 end;
 result:=Vector3Norm(Vector3Sub(p,Vector3ScalarMul(v,Vector3Dot(v,p))));
end;

function Vector3TermQuaternionRotate(const v:TVector3;const q:TQuaternion):TVector3; {$ifdef caninline}inline;{$endif}
var t,qv:TVector3;
begin
 // t = 2 * cross(q.xyz, v)
 // v' = v + q.w * t + cross(q.xyz, t)
 qv:=PVector3(pointer(@q))^;
 t:=Vector3ScalarMul(Vector3Cross(qv,v),2.0);
 result:=Vector3Add(Vector3Add(v,Vector3ScalarMul(t,q.w)),Vector3Cross(qv,t));
end;
{var vn:TVector3;
vq,rq:TQuaternion;
begin
 vq.x:=vn.x;
 vq.y:=vn.y;
 vq.z:=vn.z;
 vq.w:=0.0;
 rq:=QuaternionMul(q,QuaternionMul(vq,QuaternionConjugate(q)));
 result.x:=rq.x;
 result.y:=rq.y;
 result.z:=rq.z;
end;{}

function Vector3ProjectToBounds(const v:TVector3;const MinVector,MaxVector:TVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=0.0;
 if v.x<0.0 then begin
  result:=v.x*MaxVector.x;
 end else begin
  result:=v.x*MinVector.x;
 end;
 if v.y<0.0 then begin
  result:=result+(v.y*MaxVector.y);
 end else begin
  result:=result+(v.y*MinVector.y);
 end;
 if v.z<0.0 then begin
  result:=result+(v.z*MaxVector.z);
 end else begin
  result:=result+(v.z*MinVector.z);
 end;
end;

{$ifdef SIMD}
function SIMDVector3Flip(const v:TSIMDVector3):TSIMDVector3;
begin
 result.x:=v.x;
 result.y:=v.z;
 result.z:=-v.y;
end;

const SIMDVector3Mask:array[0..3] of longword=($ffffffff,$ffffffff,$ffffffff,$00000000);

function SIMDVector3Abs(const v:TSIMDVector3):TSIMDVector3;
begin
 result.x:=abs(v.x);
 result.y:=abs(v.y);
 result.z:=abs(v.z);
end;

function SIMDVector3Compare(const v1,v2:TSIMDVector3):boolean;
begin
 result:=(abs(v1.x-v2.x)<EPSILON) and (abs(v1.y-v2.y)<EPSILON) and (abs(v1.z-v2.z)<EPSILON);
end;

function SIMDVector3CompareEx(const v1,v2:TSIMDVector3;const Threshold:single=1e-12):boolean;
begin
 result:=(abs(v1.x-v2.x)<Threshold) and (abs(v1.y-v2.y)<Threshold) and (abs(v1.z-v2.z)<Threshold);
end;

procedure SIMDVector3DirectAdd(var v1:TSIMDVector3;const v2:TSIMDVector3); {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v1]
 movups xmm1,dqword ptr [v2]
 addps xmm0,xmm1
 movups dqword ptr [v1],xmm0
end;
{$else}
begin
 v1.x:=v1.x+v2.x;
 v1.y:=v1.y+v2.y;
 v1.z:=v1.z+v2.z;
end;
{$endif}

procedure SIMDVector3DirectSub(var v1:TSIMDVector3;const v2:TSIMDVector3); {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v1]
 movups xmm1,dqword ptr [v2]
 subps xmm0,xmm1
 movups dqword ptr [v1],xmm0
end;
{$else}
begin
 v1.x:=v1.x-v2.x;
 v1.y:=v1.y-v2.y;
 v1.z:=v1.z-v2.z;
end;
{$endif}


function SIMDVector3Add(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v1]
 movups xmm1,dqword ptr [v2]
 addps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=v1.x+v2.x;
 result.y:=v1.y+v2.y;
 result.z:=v1.z+v2.z;
end;
{$endif}

function SIMDVector3Sub(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v1]
 movups xmm1,dqword ptr [v2]
 subps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=v1.x-v2.x;
 result.y:=v1.y-v2.y;
 result.z:=v1.z-v2.z;
end;
{$endif}

function SIMDVector3Avg(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef cpu386asm}assembler;
const Half:TSIMDVector3=(x:0.5;y:0.5;z:0.5;w:0.0);
asm
 movups xmm0,dqword ptr [v1]
 movups xmm1,dqword ptr [v2]
 movups xmm2,dqword ptr [Half]
 addps xmm0,xmm1
 mulps xmm0,xmm2
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=(v1.x+v2.x)*0.5;
 result.y:=(v1.y+v2.y)*0.5;
 result.z:=(v1.z+v2.z)*0.5;
end;
{$endif}

function SIMDVector3Avg(const v1,v2,v3:TSIMDVector3):TSIMDVector3;
begin
 result.x:=(v1.x+v2.x+v3.x)/3.0;
 result.y:=(v1.y+v2.y+v3.y)/3.0;
 result.z:=(v1.z+v2.z+v3.z)/3.0;
end;

function SIMDVector3Avg(const va:PSIMDVector3s;Count:longint):TSIMDVector3;
var i:longint;
begin
 result.x:=0.0;
 result.y:=0.0;
 result.z:=0.0;
 if Count>0 then begin
  for i:=0 to Count-1 do begin
   result.x:=result.x+va^[i].x;
   result.y:=result.y+va^[i].y;
   result.z:=result.z+va^[i].z;
  end;
  result.x:=result.x/Count;
  result.y:=result.y/Count;
  result.z:=result.z/Count;
 end;
end;

function SIMDVector3ScalarMul(const v:TSIMDVector3;const s:single):TSIMDVector3; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v]
 movss xmm1,dword ptr [s]
 shufps xmm1,xmm1,$00
 mulps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=v.x*s;
 result.y:=v.y*s;
 result.z:=v.z*s;
end;
{$endif}

function SIMDVector3Dot(const v1,v2:TSIMDVector3):single; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v1]
 movups xmm1,dqword ptr [v2]
 mulps xmm0,xmm1         // xmm0 = ?, z1*z2, y1*y2, x1*x2
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z1*z2
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z1*z2 + x1*x2
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y1*y2
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z1*z2 + y1*y2 + x1*x2
 movss dword ptr [result],xmm1
end;
{$else}
begin
 result:=(v1.x*v2.x)+(v1.y*v2.y)+(v1.z*v2.z);
end;
{$endif}

function SIMDVector3Cos(const v1,v2:TSIMDVector3):single;
var d:extended;
begin
 d:=SQRT(SIMDVector3LengthSquared(v1)*SIMDVector3LengthSquared(v2));
 if d<>0 then begin
  result:=((v1.x*v2.x)+(v1.y*v2.y)+(v1.z*v2.z))/d; //result:=SIMDVector3Dot(v1,v2)/d;
 end else begin
  result:=0;
 end
end;

function SIMDVector3GetOneUnitOrthogonalVector(const v:TSIMDVector3):TSIMDVector3;
var MinimumAxis:longint;
    l:single;
begin
 if abs(v.x)<abs(v.y) then begin
  if abs(v.x)<abs(v.z) then begin
   MinimumAxis:=0;
  end else begin
   MinimumAxis:=2;
  end;
 end else begin
  if abs(v.y)<abs(v.z) then begin
   MinimumAxis:=1;
  end else begin
   MinimumAxis:=2;
  end;
 end;
 case MinimumAxis of
  0:begin
   l:=sqrt(sqr(v.y)+sqr(v.z));
   result.x:=0.0;
   result.y:=-(v.z/l);
   result.z:=v.y/l;
  end;
  1:begin
   l:=sqrt(sqr(v.x)+sqr(v.z));
   result.x:=-(v.z/l);
   result.y:=0.0;
   result.z:=v.x/l;
  end;
  else begin
   l:=sqrt(sqr(v.x)+sqr(v.y));
   result.x:=-(v.y/l);
   result.y:=v.x/l;
   result.z:=0.0;
  end;
 end;
 result.w:=0.0;
end;

function SIMDVector3Cross(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef cpu386asm}assembler;
asm
{$ifdef SSEVector3CrossOtherVariant}
 movups xmm0,dqword ptr [v1]
 movups xmm2,dqword ptr [v2]
 movaps xmm1,xmm0
 movaps xmm3,xmm2
 shufps xmm0,xmm0,$c9
 shufps xmm1,xmm1,$d2
 shufps xmm2,xmm2,$d2
 shufps xmm3,xmm3,$c9
 mulps xmm0,xmm2
 mulps xmm1,xmm3
 subps xmm0,xmm1
 movups dqword ptr [result],xmm0
{$else}
 movups xmm0,dqword ptr [v1]
 movups xmm1,dqword ptr [v2]
 movaps xmm2,xmm0
 movaps xmm3,xmm1
 shufps xmm0,xmm0,$12
 shufps xmm1,xmm1,$09
 shufps xmm2,xmm2,$09
 shufps xmm3,xmm3,$12
 mulps xmm0,xmm1
 mulps xmm2,xmm3
 subps xmm2,xmm0
 movups dqword ptr [result],xmm2
{$endif}
end;
{$else}
begin
 result.x:=(v1.y*v2.z)-(v1.z*v2.y);
 result.y:=(v1.z*v2.x)-(v1.x*v2.z);
 result.z:=(v1.x*v2.y)-(v1.y*v2.x);
end;
{$endif}

function SIMDVector3Neg(const v:TSIMDVector3):TSIMDVector3; {$ifdef cpu386asm}assembler;
asm
 xorps xmm0,xmm0
 movups xmm1,dqword ptr [v]
 subps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=-v.x;
 result.y:=-v.y;
 result.z:=-v.z;
end;
{$endif}

procedure SIMDVector3Scale(var v:TSIMDVector3;const sx,sy,sz:single); overload; {$ifdef cpu386asm}assembler;
asm
 movss xmm0,dword ptr [v+0]
 movss xmm1,dword ptr [v+4]
 movss xmm2,dword ptr [v+8]
 mulss xmm0,dword ptr [sx]
 mulss xmm1,dword ptr [sy]
 mulss xmm2,dword ptr [sz]
 movss dword ptr [v+0],xmm0
 movss dword ptr [v+4],xmm1
 movss dword ptr [v+8],xmm2
end;
{$else}
begin
 v.x:=v.x*sx;
 v.y:=v.y*sy;
 v.z:=v.z*sz;
end;
{$endif}

procedure SIMDVector3Scale(var v:TSIMDVector3;const s:single); overload; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v]
 movss xmm1,dword ptr [s]
 shufps xmm1,xmm1,$00
 mulps xmm0,xmm1
 movups dqword ptr [v],xmm0
end;
{$else}
begin
 v.x:=v.x*s;
 v.y:=v.y*s;
 v.z:=v.z*s;
end;
{$endif}

function SIMDVector3Mul(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v1]
 movups xmm1,dqword ptr [v2]
 mulps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=v1.x*v2.x;
 result.y:=v1.y*v2.y;
 result.z:=v1.z*v2.z;
end;
{$endif}

function SIMDVector3Length(const v:TSIMDVector3):single; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v]
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + y*y + x*x
 sqrtss xmm0,xmm1
 movss dword ptr [result],xmm0
end;
{$else}
begin
 result:=sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z));
end;
{$endif}

function SIMDVector3Dist(const v1,v2:TSIMDVector3):single; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v1]
 movups xmm1,dqword ptr [v2]
 subps xmm0,xmm1
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + y*y + x*x
 sqrtss xmm0,xmm1
 movss dword ptr [result],xmm0
end;
{$else}
begin
 result:=sqrt(sqr(v2.x-v1.x)+sqr(v2.y-v1.y)+sqr(v2.z-v1.z));
end;
{$endif}

function SIMDVector3LengthSquared(const v:TSIMDVector3):single; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v]
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + y*y + x*x
 movss dword ptr [result],xmm1
end;
{$else}
begin
 result:=sqr(v.x)+sqr(v.y)+sqr(v.z);
end;
{$endif}

function SIMDVector3DistSquared(const v1,v2:TSIMDVector3):single; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v1]
 movups xmm1,dqword ptr [v2]
 subps xmm0,xmm1
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + y*y + x*x
 movss dword ptr [result],xmm1
end;
{$else}
begin
 result:=sqr(v2.x-v1.x)+sqr(v2.y-v1.y)+sqr(v2.z-v1.z);
end;
{$endif}

function SIMDVector3Angle(const v1,v2,v3:TSIMDVector3):single;
var A1,A2:TSIMDVector3;
    L1,L2:single;
begin
 A1:=SIMDVector3Sub(v1,v2);
 A2:=SIMDVector3Sub(v3,v2);
 L1:=SIMDVector3Length(A1);
 L2:=SIMDVector3Length(A2);
 if (L1=0) or (L2=0) then begin
  result:=0;
 end else begin
  result:=ArcCos(SIMDVector3Dot(A1,A2)/(L1*L2));
 end;
end;

function SIMDVector3LengthNormalize(var v:TSIMDVector3):single; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v]
 movups xmm1,dqword ptr [SIMDVector3Mask]
 andps xmm0,xmm1
 movaps xmm2,xmm0
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + y*y + x*x
 sqrtss xmm0,xmm1
 movss dword ptr [result],xmm0
 rcpss xmm1,xmm0
 shufps xmm1,xmm1,$00
 mulps xmm2,xmm1
 movups dqword ptr [v],xmm2
end;
{$else}
var l:single;
begin
 result:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if result>EPSILON then begin
  result:=sqrt(result);
  l:=1.0/result;
  v.x:=v.x*l;
  v.y:=v.y*l;
  v.z:=v.z*l;
 end else begin
  result:=0.0;
  v.x:=0.0;
  v.y:=0.0;
  v.z:=0.0;
 end;
end;
{$endif}

procedure SIMDVector3Normalize(var v:TSIMDVector3); {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v]
 movaps xmm2,xmm0
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + y*y + x*x
 sqrtss xmm0,xmm1
 rcpss xmm0,xmm0
 shufps xmm0,xmm0,$00
 mulps xmm2,xmm0
 movups dqword ptr [v],xmm2
end;
{$else}
var l:single;
begin
 l:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if l>EPSILON then begin
  l:=1.0/sqrt(l);
  v.x:=v.x*l;
  v.y:=v.y*l;
  v.z:=v.z*l;
 end else begin
  v.x:=0.0;
  v.y:=0.0;
  v.z:=0.0;
 end;
end;
{$endif}

function SIMDVector3SafeNorm(const v:TSIMDVector3):TSIMDVector3;
var l:single;
begin
 l:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if l>sqr(EPSILON) then begin
  l:=1.0/sqrt(l);
  result.x:=v.x*l;
  result.y:=v.y*l;
  result.z:=v.z*l;
 end else begin
  result.x:=1.0;
  result.y:=0.0;
  result.z:=0.0;
 end;
end;

function SIMDVector3Norm(const v:TSIMDVector3):TSIMDVector3; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [v]
 movaps xmm2,xmm0
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + y*y + x*x
 sqrtss xmm0,xmm1
 rcpss xmm0,xmm0
 shufps xmm0,xmm0,$00
 mulps xmm2,xmm0
 movups dqword ptr [result],xmm2
end;
{$else}
var l:single;
begin
 l:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if l>sqr(EPSILON) then begin
  l:=1.0/sqrt(l);
  result.x:=v.x*l;
  result.y:=v.y*l;
  result.z:=v.z*l;
 end else begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
 end;
end;
{$endif}

function SIMDVector3NormEx(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
var l:single;
begin
 l:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if l>EPSILON then begin
  l:=sqrt(l);
  result.x:=v.x/l;
  result.y:=v.y/l;
  result.z:=v.z/l;
 end else begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
 end;
end;

procedure SIMDVector3RotateX(var v:TSIMDVector3;a:single);
var t:TSIMDVector3;
begin
 t.x:=v.x;
 t.y:=(v.y*cos(a))-(v.z*sin(a));
 t.z:=(v.y*sin(a))+(v.z*cos(a));
 v:=t;
end;

procedure SIMDVector3RotateY(var v:TSIMDVector3;a:single);
var t:TSIMDVector3;
begin
 t.x:=(v.x*cos(a))+(v.z*sin(a));
 t.y:=v.y;
 t.z:=(v.z*cos(a))-(v.x*sin(a));
 v:=t;
end;

procedure SIMDVector3RotateZ(var v:TSIMDVector3;a:single);
var t:TSIMDVector3;
begin
 t.x:=(v.x*cos(a))-(v.y*sin(a));
 t.y:=(v.x*sin(a))+(v.y*cos(a));
 t.z:=v.z;
 v:=t;
end;

procedure SIMDVector3MatrixMul(var v:TSIMDVector3;const m:TMatrix3x3); overload;
var t:TSIMDVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
 v:=t;
end;

procedure SIMDVector3MatrixMul(var v:TSIMDVector3;const m:TMatrix4x3); overload;
var t:TSIMDVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
 v:=t;
end;

procedure SIMDVector3MatrixMul(var v:TSIMDVector3;const m:TMatrix4x4); overload; {$ifdef cpu386asm}assembler;{$endif}
{$ifdef cpu386asm}
const cOne:array[0..3] of single=(0.0,0.0,0.0,1.0);
asm
 movups xmm0,dqword ptr [v]     // d c b a
 movups xmm1,dqword ptr [SIMDVector3Mask]
 movups xmm2,dqword ptr [cOne]
 andps xmm0,xmm1
 addps xmm0,xmm2
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 movaps xmm3,xmm0               // d c b a
 shufps xmm0,xmm0,$00           // a a a a 00000000b
 shufps xmm1,xmm1,$55           // b b b b 01010101b
 shufps xmm2,xmm2,$aa           // c c c c 10101010b
 shufps xmm3,xmm3,$ff           // d d d d 11111111b
 movups xmm4,dqword ptr [m+0]
 movups xmm5,dqword ptr [m+16]
 movups xmm6,dqword ptr [m+32]
 movups xmm7,dqword ptr [m+48]
 mulps xmm0,xmm4
 mulps xmm1,xmm5
 mulps xmm2,xmm6
 mulps xmm3,xmm7
 addps xmm0,xmm1
 addps xmm2,xmm3
 addps xmm0,xmm2
 movups dqword ptr [v],xmm0
end;
{$else}
var t:TSIMDVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
 v:=t;
end;
{$endif}

procedure SIMDVector3MatrixMulBasis(var v:TSIMDVector3;const m:TMatrix4x3); overload;
var t:TSIMDVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
 v:=t;
end;

procedure SIMDVector3MatrixMulBasis(var v:TSIMDVector3;const m:TMatrix4x4); overload;
var t:TSIMDVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
 v:=t;
end;

procedure SIMDVector3MatrixMulInverted(var v:TSIMDVector3;const m:TMatrix4x3); overload;
var p,t:TSIMDVector3;
begin
 p.x:=v.x-m[3,0];
 p.y:=v.y-m[3,1];
 p.z:=v.z-m[3,2];
 t.x:=(m[0,0]*p.x)+(m[0,1]*p.y)+(m[0,2]*p.z);
 t.y:=(m[1,0]*p.x)+(m[1,1]*p.y)+(m[1,2]*p.z);
 t.z:=(m[2,0]*p.x)+(m[2,1]*p.y)+(m[2,2]*p.z);
 v:=t;
end;

procedure SIMDVector3MatrixMulInverted(var v:TSIMDVector3;const m:TMatrix4x4); overload;
var p,t:TSIMDVector3;
begin
 p.x:=v.x-m[3,0];
 p.y:=v.y-m[3,1];
 p.z:=v.z-m[3,2];
 t.x:=(m[0,0]*p.x)+(m[0,1]*p.y)+(m[0,2]*p.z);
 t.y:=(m[1,0]*p.x)+(m[1,1]*p.y)+(m[1,2]*p.z);
 t.z:=(m[2,0]*p.x)+(m[2,1]*p.y)+(m[2,2]*p.z);
 v:=t;
end;

function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix3x3):TSIMDVector3; overload;{$ifdef cpu386asm}assembler;
const Mask:array[0..3] of longword=($ffffffff,$ffffffff,$ffffffff,$00000000);
asm
 movups xmm6,dqword ptr [Mask]
 movups xmm0,dqword ptr [v]     // d c b a
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 shufps xmm0,xmm0,$00           // a a a a 00000000b
 shufps xmm1,xmm1,$55           // b b b b 01010101b
 shufps xmm2,xmm2,$aa           // c c c c 10101010b
 movups xmm3,dqword ptr [m+0]
 movups xmm4,dqword ptr [m+12]
 andps xmm3,xmm6
 andps xmm4,xmm6
 movss xmm5,dword ptr [m+24]
 movss xmm6,dword ptr [m+28]
 movlhps xmm5,xmm6
 movss xmm6,dword ptr [m+32]
 shufps xmm5,xmm6,$88
 mulps xmm0,xmm3
 mulps xmm1,xmm4
 mulps xmm2,xmm5
 addps xmm0,xmm1
 addps xmm0,xmm2
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
end;
{$endif}

function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix3x4):TSIMDVector3; overload;{$ifdef cpu386asm}assembler;
const cOne:array[0..3] of single=(0.0,0.0,0.0,1.0);
asm
 movups xmm0,dqword ptr [v]     // d c b a
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 shufps xmm0,xmm0,$00           // a a a a 00000000b
 shufps xmm1,xmm1,$55           // b b b b 01010101b
 shufps xmm2,xmm2,$aa           // c c c c 10101010b
 movups xmm3,dqword ptr [m+0]
 movups xmm4,dqword ptr [m+16]
 movups xmm5,dqword ptr [m+32]
 mulps xmm0,xmm3
 mulps xmm1,xmm4
 mulps xmm2,xmm5
 addps xmm0,xmm1
 addps xmm0,xmm2
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
end;
{$endif}

function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload;
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
end;

function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload;{$ifdef cpu386asm}assembler;
const cOne:array[0..3] of single=(0.0,0.0,0.0,1.0);
asm
 movups xmm0,dqword ptr [v]     // d c b a
 movups xmm1,dqword ptr [SIMDVector3Mask]
 movups xmm2,dqword ptr [cOne]
 andps xmm0,xmm1
 addps xmm0,xmm2
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 movaps xmm3,xmm0               // d c b a
 shufps xmm0,xmm0,$00           // a a a a 00000000b
 shufps xmm1,xmm1,$55           // b b b b 01010101b
 shufps xmm2,xmm2,$aa           // c c c c 10101010b
 shufps xmm3,xmm3,$ff           // d d d d 11111111b
 movups xmm4,dqword ptr [m+0]
 movups xmm5,dqword ptr [m+16]
 movups xmm6,dqword ptr [m+32]
 movups xmm7,dqword ptr [m+48]
 mulps xmm0,xmm4
 mulps xmm1,xmm5
 mulps xmm2,xmm6
 mulps xmm3,xmm7
 addps xmm0,xmm1
 addps xmm2,xmm3
 addps xmm0,xmm2
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
end;
{$endif}

function SIMDVector3TermMatrixMulInverse(const v:TSIMDVector3;const m:TMatrix3x3):TSIMDVector3; overload;
var Determinant:single;
begin
 Determinant:=((m[0,0]*((m[1,1]*m[2,2])-(m[2,1]*m[1,2])))-
               (m[0,1]*((m[1,0]*m[2,2])-(m[2,0]*m[1,2]))))+
               (m[0,2]*((m[1,0]*m[2,1])-(m[2,0]*m[1,1])));
 if abs(Determinant)>EPSILON then begin
  Determinant:=1.0/Determinant;
 end;
 result.x:=((v.x*((m[1,1]*m[2,2])-(m[1,2]*m[2,1])))+(v.y*((m[1,2]*m[2,0])-(m[1,0]*m[2,2])))+(v.z*((m[1,0]*m[2,1])-(m[1,1]*m[2,0]))))*Determinant;
 result.y:=((m[0,0]*((v.y*m[2,2])-(v.z*m[2,1])))+(m[0,1]*((v.z*m[2,0])-(v.x*m[2,2])))+(m[0,2]*((v.x*m[2,1])-(v.y*m[2,0]))))*Determinant;
 result.z:=((m[0,0]*((m[1,1]*v.z)-(m[1,2]*v.y)))+(m[0,1]*((m[1,2]*v.x)-(m[1,0]*v.z)))+(m[0,2]*((m[1,0]*v.y)-(m[1,1]*v.x))))*Determinant;
end;

function SIMDVector3TermMatrixMulInverse(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload;
var Determinant:single;
begin
 Determinant:=((m[0,0]*((m[1,1]*m[2,2])-(m[2,1]*m[1,2])))-
               (m[0,1]*((m[1,0]*m[2,2])-(m[2,0]*m[1,2]))))+
               (m[0,2]*((m[1,0]*m[2,1])-(m[2,0]*m[1,1])));
 if abs(Determinant)>EPSILON then begin
  Determinant:=1.0/Determinant;
 end;
 result.x:=((v.x*((m[1,1]*m[2,2])-(m[1,2]*m[2,1])))+(v.y*((m[1,2]*m[2,0])-(m[1,0]*m[2,2])))+(v.z*((m[1,0]*m[2,1])-(m[1,1]*m[2,0]))))*Determinant;
 result.y:=((m[0,0]*((v.y*m[2,2])-(v.z*m[2,1])))+(m[0,1]*((v.z*m[2,0])-(v.x*m[2,2])))+(m[0,2]*((v.x*m[2,1])-(v.y*m[2,0]))))*Determinant;
 result.z:=((m[0,0]*((m[1,1]*v.z)-(m[1,2]*v.y)))+(m[0,1]*((m[1,2]*v.x)-(m[1,0]*v.z)))+(m[0,2]*((m[1,0]*v.y)-(m[1,1]*v.x))))*Determinant;
end;

function SIMDVector3TermMatrixMulInverted(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload;
var p:TSIMDVector3;
begin
 p.x:=v.x-m[3,0];
 p.y:=v.y-m[3,1];
 p.z:=v.z-m[3,2];
 result.x:=(m[0,0]*p.x)+(m[0,1]*p.y)+(m[0,2]*p.z);
 result.y:=(m[1,0]*p.x)+(m[1,1]*p.y)+(m[1,2]*p.z);
 result.z:=(m[2,0]*p.x)+(m[2,1]*p.y)+(m[2,2]*p.z);
end;

function SIMDVector3TermMatrixMulInverted(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload;
var p:TSIMDVector3;
begin
 p.x:=v.x-m[3,0];
 p.y:=v.y-m[3,1];
 p.z:=v.z-m[3,2];
 result.x:=(m[0,0]*p.x)+(m[0,1]*p.y)+(m[0,2]*p.z);
 result.y:=(m[1,0]*p.x)+(m[1,1]*p.y)+(m[1,2]*p.z);
 result.z:=(m[2,0]*p.x)+(m[2,1]*p.y)+(m[2,2]*p.z);
end;

function SIMDVector3TermMatrixMulTransposed(const v:TSIMDVector3;const m:TMatrix3x3):TSIMDVector3; overload;
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z);
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z);
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z);
end;

function SIMDVector3TermMatrixMulTransposed(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload;
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z);
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z);
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z);
end;

function SIMDVector3TermMatrixMulTransposed(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload;
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z)+m[0,3];
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z)+m[1,3];
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z)+m[2,3];
end;

function SIMDVector3TermMatrixMulTransposedBasis(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload;
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z);
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z);
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z);
end;

function SIMDVector3TermMatrixMulTransposedBasis(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload;
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z);
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z);
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z);
end;

function SIMDVector3TermMatrixMulHomogen(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3;
var result_w:single;
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
 result_w:=(m[0,3]*v.x)+(m[1,3]*v.y)+(m[2,3]*v.z)+m[3,3];
 result.x:=result.x/result_w;
 result.y:=result.y/result_w;
 result.z:=result.z/result_w;
end;

function SIMDVector3TermMatrixMulBasis(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload;
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
end;

function SIMDVector3TermMatrixMulBasis(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload;{$ifdef cpu386asm}assembler;
const Mask:array[0..3] of longword=($ffffffff,$ffffffff,$ffffffff,$00000000);
asm
 movups xmm0,dqword ptr [v]     // d c b a
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 shufps xmm0,xmm0,$00           // a a a a 00000000b
 shufps xmm1,xmm1,$55           // b b b b 01010101b
 shufps xmm2,xmm2,$aa           // c c c c 10101010b
 movups xmm3,dqword ptr [m+0]
 movups xmm4,dqword ptr [m+16]
 movups xmm5,dqword ptr [m+32]
 movups xmm6,dqword ptr [Mask]
 andps xmm3,xmm6
 andps xmm4,xmm6
 andps xmm5,xmm6
 mulps xmm0,xmm3
 mulps xmm1,xmm4
 mulps xmm2,xmm5
 addps xmm0,xmm1
 addps xmm0,xmm2
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
end;
{$endif}

function SIMDVector3Lerp(const v1,v2:TSIMDVector3;w:single):TSIMDVector3;
var iw:single;
begin
 if w<0.0 then begin
  result:=v1;
 end else if w>1.0 then begin
  result:=v2;
 end else begin
  iw:=1.0-w;
  result.x:=(iw*v1.x)+(w*v2.x);
  result.y:=(iw*v1.y)+(w*v2.y);
  result.z:=(iw*v1.z)+(w*v2.z);
 end;
end;

function SIMDVector3Perpendicular(v:TSIMDVector3):TSIMDVector3;
var p:TSIMDVector3;
begin
 SIMDVector3Normalize(v);
 p.x:=abs(v.x);
 p.y:=abs(v.y);
 p.z:=abs(v.z);
 if (p.x<=p.y) and (p.x<=p.z) then begin
  p:=SIMDVector3XAxis;
 end else if (p.y<=p.x) and (p.y<=p.z) then begin
  p:=SIMDVector3YAxis;
 end else begin
  p:=SIMDVector3ZAxis;
 end;
 result:=SIMDVector3Norm(SIMDVector3Sub(p,SIMDVector3ScalarMul(v,SIMDVector3Dot(v,p))));
end;

function SIMDVector3TermQuaternionRotate(const v:TSIMDVector3;const q:TQuaternion):TSIMDVector3;{$ifdef cpu386asm}assembler;
const Mask:array[0..3] of longword=($ffffffff,$ffffffff,$ffffffff,$00000000);
var t,qv:TSIMDVector3;
asm

 movups xmm4,dqword ptr [q] // xmm4 = q.xyzw

 movups xmm5,dqword ptr [v] // xmm5 = v.xyz?

 movaps xmm6,xmm4
 shufps xmm6,xmm6,$ff // xmm6 = q.wwww

 movups xmm7,dqword ptr [Mask] // xmm7 = Mask

 andps xmm4,xmm7 // xmm4 = q.xyz0

 andps xmm5,xmm7 // xmm5 = v.xyz0

 // t:=SIMDVector3ScalarMul(SIMDVector3Cross(qv,v),2.0);
 movaps xmm0,xmm4 // xmm4 = qv
 movaps xmm1,xmm5 // xmm5 = v
 movaps xmm2,xmm4 // xmm4 = qv
 movaps xmm3,xmm5 // xmm5 = v
 shufps xmm0,xmm0,$12
 shufps xmm1,xmm1,$09
 shufps xmm2,xmm2,$09
 shufps xmm3,xmm3,$12
 mulps xmm0,xmm1
 mulps xmm2,xmm3
 subps xmm2,xmm0
 addps xmm2,xmm2

 // xmm6 = SIMDVector3Add(v,SIMDVector3ScalarMul(t,q.w))
 mulps xmm6,xmm2 // xmm6 = q.wwww, xmm2 = t
 addps xmm6,xmm5 // xmm5 = v

 // SIMDVector3Cross(qv,t)
 movaps xmm1,xmm4 // xmm4 = qv
 movaps xmm3,xmm2 // xmm2 = t
 shufps xmm4,xmm4,$12
 shufps xmm2,xmm2,$09
 shufps xmm1,xmm1,$09
 shufps xmm3,xmm3,$12
 mulps xmm4,xmm2
 mulps xmm1,xmm3
 subps xmm1,xmm4

 // result:=SIMDVector3Add(SIMDVector3Add(v,SIMDVector3ScalarMul(t,q.w)),SIMDVector3Cross(qv,t));
 addps xmm1,xmm6

 movups dqword ptr [result],xmm1

end;
{$else}
var t,qv:TSIMDVector3;
begin
 // t = 2 * cross(q.xyz, v)
 // v' = v + q.w * t + cross(q.xyz, t)
 qv.x:=q.x;
 qv.y:=q.y;
 qv.z:=q.z;
 qv.w:=0.0;
 t:=SIMDVector3ScalarMul(SIMDVector3Cross(qv,v),2.0);
 result:=SIMDVector3Add(SIMDVector3Add(v,SIMDVector3ScalarMul(t,q.w)),SIMDVector3Cross(qv,t));
end;
{$endif}

function SIMDVector3ProjectToBounds(const v:TSIMDVector3;const MinVector,MaxVector:TSIMDVector3):single;
begin
 result:=0.0;
 if v.x<0.0 then begin
  result:=v.x*MaxVector.x;
 end else begin
  result:=v.x*MinVector.x;
 end;
 if v.y<0.0 then begin
  result:=result+(v.y*MaxVector.y);
 end else begin
  result:=result+(v.y*MinVector.y);
 end;
 if v.z<0.0 then begin
  result:=result+(v.z*MaxVector.z);
 end else begin
  result:=result+(v.z*MinVector.z);
 end;
end;
{$else}
function SIMDVector3Flip(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v.x;
 result.y:=v.z;
 result.z:=-v.y;
end;

function SIMDVector3Abs(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=abs(v.x);
 result.y:=abs(v.y);
 result.z:=abs(v.z);
end;

function SIMDVector3Compare(const v1,v2:TSIMDVector3):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=(abs(v1.x-v2.x)<EPSILON) and (abs(v1.y-v2.y)<EPSILON) and (abs(v1.z-v2.z)<EPSILON);
end;

function SIMDVector3CompareEx(const v1,v2:TSIMDVector3;const Threshold:single=1e-12):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=(abs(v1.x-v2.x)<Threshold) and (abs(v1.y-v2.y)<Threshold) and (abs(v1.z-v2.z)<Threshold);
end;

function SIMDVector3DirectAdd(var v1:TSIMDVector3;const v2:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
begin
 v1.x:=v1.x+v2.x;
 v1.y:=v1.y+v2.y;
 v1.z:=v1.z+v2.z;
end;

function SIMDVector3DirectSub(var v1:TSIMDVector3;const v2:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
begin
 v1.x:=v1.x-v2.x;
 v1.y:=v1.y-v2.y;
 v1.z:=v1.z-v2.z;
end;

function SIMDVector3Add(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v1.x+v2.x;
 result.y:=v1.y+v2.y;
 result.z:=v1.z+v2.z;
end;

function SIMDVector3Sub(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v1.x-v2.x;
 result.y:=v1.y-v2.y;
 result.z:=v1.z-v2.z;
end;

function SIMDVector3Avg(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(v1.x+v2.x)*0.5;
 result.y:=(v1.y+v2.y)*0.5;
 result.z:=(v1.z+v2.z)*0.5;
end;

function SIMDVector3Avg(const v1,v2,v3:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(v1.x+v2.x+v3.x)/3.0;
 result.y:=(v1.y+v2.y+v3.y)/3.0;
 result.z:=(v1.z+v2.z+v3.z)/3.0;
end;

function SIMDVector3Avg(const va:PSIMDVector3s;Count:longint):TSIMDVector3; {$ifdef caninline}inline;{$endif}
var i:longint;
begin
 result.x:=0.0;
 result.y:=0.0;
 result.z:=0.0;
 if Count>0 then begin
  for i:=0 to Count-1 do begin
   result.x:=result.x+va^[i].x;
   result.y:=result.y+va^[i].y;
   result.z:=result.z+va^[i].z;
  end;
  result.x:=result.x/Count;
  result.y:=result.y/Count;
  result.z:=result.z/Count;
 end;
end;

function SIMDVector3ScalarMul(const v:TSIMDVector3;const s:single):TSIMDVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v.x*s;
 result.y:=v.y*s;
 result.z:=v.z*s;
end;

function SIMDVector3Dot(const v1,v2:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=(v1.x*v2.x)+(v1.y*v2.y)+(v1.z*v2.z);
end;

function SIMDVector3Cos(const v1,v2:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
var d:extended;
begin
 d:=SQRT(SIMDVector3LengthSquared(v1)*SIMDVector3LengthSquared(v2));
 if d<>0 then begin
  result:=((v1.x*v2.x)+(v1.y*v2.y)+(v1.z*v2.z))/d; //result:=SIMDVector3Dot(v1,v2)/d;
 end else begin
  result:=0;
 end
end;

function SIMDVector3GetOneUnitOrthogonalVector(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
var MinimumAxis:longint;
    l:single;
begin
 if abs(v.x)<abs(v.y) then begin
  if abs(v.x)<abs(v.z) then begin
   MinimumAxis:=0;
  end else begin
   MinimumAxis:=2;
  end;
 end else begin
  if abs(v.y)<abs(v.z) then begin
   MinimumAxis:=1;
  end else begin
   MinimumAxis:=2;
  end;
 end;
 case MinimumAxis of
  0:begin
   l:=sqrt(sqr(v.y)+sqr(v.z));
   result.x:=0.0;
   result.y:=-(v.z/l);
   result.z:=v.y/l;
  end;
  1:begin
   l:=sqrt(sqr(v.x)+sqr(v.z));
   result.x:=-(v.z/l);
   result.y:=0.0;
   result.z:=v.x/l;
  end;
  else begin
   l:=sqrt(sqr(v.x)+sqr(v.y));
   result.x:=-(v.y/l);
   result.y:=v.x/l;
   result.z:=0.0;
  end;
 end;
end;

function SIMDVector3Cross(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(v1.y*v2.z)-(v1.z*v2.y);
 result.y:=(v1.z*v2.x)-(v1.x*v2.z);
 result.z:=(v1.x*v2.y)-(v1.y*v2.x);
end;

function SIMDVector3Neg(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=-v.x;
 result.y:=-v.y;
 result.z:=-v.z;
end;

procedure SIMDVector3Scale(var v:TSIMDVector3;const sx,sy,sz:single); overload; {$ifdef caninline}inline;{$endif}
begin
 v.x:=v.x*sx;
 v.y:=v.y*sy;
 v.z:=v.z*sz;
end;

procedure SIMDVector3Scale(var v:TSIMDVector3;const s:single); overload; {$ifdef caninline}inline;{$endif}
begin
 v.x:=v.x*s;
 v.y:=v.y*s;
 v.z:=v.z*s;
end;

function SIMDVector3Mul(const v1,v2:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=v1.x*v2.x;
 result.y:=v1.y*v2.y;
 result.z:=v1.z*v2.z;
end;

function SIMDVector3Length(const v:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z));
end;

function SIMDVector3Dist(const v1,v2:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=sqrt(sqr(v2.x-v1.x)+sqr(v2.y-v1.y)+sqr(v2.z-v1.z));
end;

function SIMDVector3LengthSquared(const v:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=sqr(v.x)+sqr(v.y)+sqr(v.z);
end;

function SIMDVector3DistSquared(const v1,v2:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=sqr(v2.x-v1.x)+sqr(v2.y-v1.y)+sqr(v2.z-v1.z);
end;

function SIMDVector3Angle(const v1,v2,v3:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
var A1,A2:TSIMDVector3;
    L1,L2:single;
begin
 A1:=SIMDVector3Sub(v1,v2);
 A2:=SIMDVector3Sub(v3,v2);
 L1:=SIMDVector3Length(A1);
 L2:=SIMDVector3Length(A2);
 if (L1=0) or (L2=0) then begin
  result:=0;
 end else begin
  result:=ArcCos(SIMDVector3Dot(A1,A2)/(L1*L2));
 end;
end;

function SIMDVector3LengthNormalize(var v:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
var l:single;
begin
 result:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if result>EPSILON then begin
  result:=sqrt(result);
  l:=1.0/result;
  v.x:=v.x*l;
  v.y:=v.y*l;
  v.z:=v.z*l;
 end else begin
  result:=0.0;
  v.x:=0.0;
  v.y:=0.0;
  v.z:=0.0;
 end;
end;

function SIMDVector3Normalize(var v:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
var l:single;
begin
 result:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if result>EPSILON then begin
  result:=sqrt(result);
  l:=1.0/result;
  v.x:=v.x*l;
  v.y:=v.y*l;
  v.z:=v.z*l;
 end else begin
  result:=0.0;
  v.x:=0.0;
  v.y:=0.0;
  v.z:=0.0;
 end;
end;

function SIMDVector3NormalizeEx(var v:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if result>EPSILON then begin
  result:=sqrt(result);
  v.x:=v.x/result;
  v.y:=v.y/result;
  v.z:=v.z/result;
 end else begin
  result:=0.0;
  v.x:=0.0;
  v.y:=0.0;
  v.z:=0.0;
 end;
end;

function SIMDVector3SafeNorm(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
var l:single;
begin
 l:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if l>sqr(EPSILON) then begin
  l:=1.0/sqrt(l);
  result.x:=v.x*l;
  result.y:=v.y*l;
  result.z:=v.z*l;
 end else begin
  result.x:=1.0;
  result.y:=0.0;
  result.z:=0.0;
 end;
end;

function SIMDVector3Norm(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
var l:single;
begin
 l:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if l>sqr(EPSILON) then begin
  l:=1.0/sqrt(l);
  result.x:=v.x*l;
  result.y:=v.y*l;
  result.z:=v.z*l;
 end else begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
 end;
end;

function SIMDVector3NormEx(const v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
var l:single;
begin
 l:=sqr(v.x)+sqr(v.y)+sqr(v.z);
 if l>EPSILON then begin
  l:=sqrt(l);
  result.x:=v.x/l;
  result.y:=v.y/l;
  result.z:=v.z/l;
 end else begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
 end;
end;

procedure SIMDVector3RotateX(var v:TSIMDVector3;a:single); {$ifdef caninline}inline;{$endif}
var t:TSIMDVector3;
begin
 t.x:=v.x;
 t.y:=(v.y*cos(a))-(v.z*sin(a));
 t.z:=(v.y*sin(a))+(v.z*cos(a));
 v:=t;
end;

procedure SIMDVector3RotateY(var v:TSIMDVector3;a:single); {$ifdef caninline}inline;{$endif}
var t:TSIMDVector3;
begin
 t.x:=(v.x*cos(a))+(v.z*sin(a));
 t.y:=v.y;
 t.z:=(v.z*cos(a))-(v.x*sin(a));
 v:=t;
end;

procedure SIMDVector3RotateZ(var v:TSIMDVector3;a:single); {$ifdef caninline}inline;{$endif}
var t:TSIMDVector3;
begin
 t.x:=(v.x*cos(a))-(v.y*sin(a));
 t.y:=(v.x*sin(a))+(v.y*cos(a));
 t.z:=v.z;
 v:=t;
end;

procedure SIMDVector3MatrixMul(var v:TSIMDVector3;const m:TMatrix3x3); overload; {$ifdef caninline}inline;{$endif}
var t:TSIMDVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
 v:=t;
end;

procedure SIMDVector3MatrixMul(var v:TSIMDVector3;const m:TMatrix4x3); overload; {$ifdef caninline}inline;{$endif}
var t:TSIMDVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
 v:=t;
end;

procedure SIMDVector3MatrixMul(var v:TSIMDVector3;const m:TMatrix4x4); overload; {$ifdef cpu386asm}assembler;{$endif}
{$ifdef cpu386asm}
const cOne:single=1.0;
asm
{mov eax,v
 mov edx,m}
 sub esp,16
 movss xmm0,dword ptr [eax]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 movss xmm3,dword ptr cOne
 movss dword ptr [esp],xmm0
 movss dword ptr [esp+4],xmm1
 movss dword ptr [esp+8],xmm2
 movss dword ptr [esp+12],xmm3
 movups xmm0,[esp]              // d c b a
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 movaps xmm3,xmm0               // d c b a
 shufps xmm0,xmm0,$00           // a a a a 00000000b
 shufps xmm1,xmm1,$55           // b b b b 01010101b
 shufps xmm2,xmm2,$aa           // c c c c 10101010b
 shufps xmm3,xmm3,$ff           // d d d d 11111111b
 movups xmm4,[edx+0]
 movups xmm5,[edx+16]
 movups xmm6,[edx+32]
 movups xmm7,[edx+48]
 mulps xmm0,xmm4
 mulps xmm1,xmm5
 mulps xmm2,xmm6
 mulps xmm3,xmm7
 addps xmm0,xmm1
 addps xmm2,xmm3
 addps xmm0,xmm2
 movups [esp],xmm0
 movss xmm0,dword ptr [esp]
 movss xmm1,dword ptr [esp+4]
 movss xmm2,dword ptr [esp+8]
 movss dword ptr [eax],xmm0
 movss dword ptr [eax+4],xmm1
 movss dword ptr [eax+8],xmm2
 add esp,16
end;
{$else}
var t:TSIMDVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
 v:=t;
end;
{$endif}

procedure SIMDVector3MatrixMulBasis(var v:TSIMDVector3;const m:TMatrix4x3); overload; {$ifdef caninline}inline;{$endif}
var t:TSIMDVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
 v:=t;
end;

procedure SIMDVector3MatrixMulBasis(var v:TSIMDVector3;const m:TMatrix4x4); overload; {$ifdef caninline}inline;{$endif}
var t:TSIMDVector3;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
 v:=t;
end;

procedure SIMDVector3MatrixMulInverted(var v:TSIMDVector3;const m:TMatrix4x3); overload; {$ifdef caninline}inline;{$endif}
var p,t:TSIMDVector3;
begin
 p.x:=v.x-m[3,0];
 p.y:=v.y-m[3,1];
 p.z:=v.z-m[3,2];
 t.x:=(m[0,0]*p.x)+(m[0,1]*p.y)+(m[0,2]*p.z);
 t.y:=(m[1,0]*p.x)+(m[1,1]*p.y)+(m[1,2]*p.z);
 t.z:=(m[2,0]*p.x)+(m[2,1]*p.y)+(m[2,2]*p.z);
 v:=t;
end;

procedure SIMDVector3MatrixMulInverted(var v:TSIMDVector3;const m:TMatrix4x4); overload; {$ifdef caninline}inline;{$endif}
var p,t:TSIMDVector3;
begin
 p.x:=v.x-m[3,0];
 p.y:=v.y-m[3,1];
 p.z:=v.z-m[3,2];
 t.x:=(m[0,0]*p.x)+(m[0,1]*p.y)+(m[0,2]*p.z);
 t.y:=(m[1,0]*p.x)+(m[1,1]*p.y)+(m[1,2]*p.z);
 t.z:=(m[2,0]*p.x)+(m[2,1]*p.y)+(m[2,2]*p.z);
 v:=t;
end;

function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix3x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
end;

function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix3x4):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
end;

function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
end;

function SIMDVector3TermMatrixMulInverse(const v:TSIMDVector3;const m:TMatrix3x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
var Determinant:single;
begin
 Determinant:=((m[0,0]*((m[1,1]*m[2,2])-(m[2,1]*m[1,2])))-
               (m[0,1]*((m[1,0]*m[2,2])-(m[2,0]*m[1,2]))))+
               (m[0,2]*((m[1,0]*m[2,1])-(m[2,0]*m[1,1])));
 if abs(Determinant)>EPSILON then begin
  Determinant:=1.0/Determinant;
 end;
 result.x:=((v.x*((m[1,1]*m[2,2])-(m[1,2]*m[2,1])))+(v.y*((m[1,2]*m[2,0])-(m[1,0]*m[2,2])))+(v.z*((m[1,0]*m[2,1])-(m[1,1]*m[2,0]))))*Determinant;
 result.y:=((m[0,0]*((v.y*m[2,2])-(v.z*m[2,1])))+(m[0,1]*((v.z*m[2,0])-(v.x*m[2,2])))+(m[0,2]*((v.x*m[2,1])-(v.y*m[2,0]))))*Determinant;
 result.z:=((m[0,0]*((m[1,1]*v.z)-(m[1,2]*v.y)))+(m[0,1]*((m[1,2]*v.x)-(m[1,0]*v.z)))+(m[0,2]*((m[1,0]*v.y)-(m[1,1]*v.x))))*Determinant;
end;

function SIMDVector3TermMatrixMulInverse(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload;
var Determinant:single;
begin
 Determinant:=((m[0,0]*((m[1,1]*m[2,2])-(m[2,1]*m[1,2])))-
               (m[0,1]*((m[1,0]*m[2,2])-(m[2,0]*m[1,2]))))+
               (m[0,2]*((m[1,0]*m[2,1])-(m[2,0]*m[1,1])));
 if abs(Determinant)>EPSILON then begin
  Determinant:=1.0/Determinant;
 end;
 result.x:=((v.x*((m[1,1]*m[2,2])-(m[1,2]*m[2,1])))+(v.y*((m[1,2]*m[2,0])-(m[1,0]*m[2,2])))+(v.z*((m[1,0]*m[2,1])-(m[1,1]*m[2,0]))))*Determinant;
 result.y:=((m[0,0]*((v.y*m[2,2])-(v.z*m[2,1])))+(m[0,1]*((v.z*m[2,0])-(v.x*m[2,2])))+(m[0,2]*((v.x*m[2,1])-(v.y*m[2,0]))))*Determinant;
 result.z:=((m[0,0]*((m[1,1]*v.z)-(m[1,2]*v.y)))+(m[0,1]*((m[1,2]*v.x)-(m[1,0]*v.z)))+(m[0,2]*((m[1,0]*v.y)-(m[1,1]*v.x))))*Determinant;
end;

function SIMDVector3TermMatrixMulInverted(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
var p:TSIMDVector3;
begin
 p.x:=v.x-m[3,0];
 p.y:=v.y-m[3,1];
 p.z:=v.z-m[3,2];
 result.x:=(m[0,0]*p.x)+(m[0,1]*p.y)+(m[0,2]*p.z);
 result.y:=(m[1,0]*p.x)+(m[1,1]*p.y)+(m[1,2]*p.z);
 result.z:=(m[2,0]*p.x)+(m[2,1]*p.y)+(m[2,2]*p.z);
end;

function SIMDVector3TermMatrixMulInverted(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
var p:TSIMDVector3;
begin
 p.x:=v.x-m[3,0];
 p.y:=v.y-m[3,1];
 p.z:=v.z-m[3,2];
 result.x:=(m[0,0]*p.x)+(m[0,1]*p.y)+(m[0,2]*p.z);
 result.y:=(m[1,0]*p.x)+(m[1,1]*p.y)+(m[1,2]*p.z);
 result.z:=(m[2,0]*p.x)+(m[2,1]*p.y)+(m[2,2]*p.z);
end;

function SIMDVector3TermMatrixMulTransposed(const v:TSIMDVector3;const m:TMatrix3x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z);
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z);
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z);
end;

function SIMDVector3TermMatrixMulTransposed(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z);
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z);
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z);
end;

function SIMDVector3TermMatrixMulTransposed(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z)+m[0,3];
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z)+m[1,3];
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z)+m[2,3];
end;

function SIMDVector3TermMatrixMulTransposedBasis(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z);
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z);
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z);
end;

function SIMDVector3TermMatrixMulTransposedBasis(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[0,1]*v.y)+(m[0,2]*v.z);
 result.y:=(m[1,0]*v.x)+(m[1,1]*v.y)+(m[1,2]*v.z);
 result.z:=(m[2,0]*v.x)+(m[2,1]*v.y)+(m[2,2]*v.z);
end;

function SIMDVector3TermMatrixMulHomogen(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; {$ifdef caninline}inline;{$endif}
var result_w:single;
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
 result_w:=(m[0,3]*v.x)+(m[1,3]*v.y)+(m[2,3]*v.z)+m[3,3];
 result.x:=result.x/result_w;
 result.y:=result.y/result_w;
 result.z:=result.z/result_w;
end;

function SIMDVector3TermMatrixMulBasis(const v:TSIMDVector3;const m:TMatrix4x3):TSIMDVector3; overload; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
end;

function SIMDVector3TermMatrixMulBasis(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z);
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z);
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z);
end;

function SIMDVector3TermMatrixMul(const v:TSIMDVector3;const m:TMatrix4x4):TSIMDVector3; overload;{$ifdef cpu386asm}assembler;{$endif}
{$ifdef cpu386asm}
const cOne:single=1.0;
asm
{mov eax,v
 mov edx,m
 mov ecx,result}
 sub esp,16
 movss xmm0,dword ptr [eax]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 movss xmm3,dword ptr cOne
 movss dword ptr [esp],xmm0
 movss dword ptr [esp+4],xmm1
 movss dword ptr [esp+8],xmm2
 movss dword ptr [esp+12],xmm3
 movups xmm0,[esp]              // d c b a
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 movaps xmm3,xmm0               // d c b a
 shufps xmm0,xmm0,$00           // a a a a 00000000b
 shufps xmm1,xmm1,$55           // b b b b 01010101b
 shufps xmm2,xmm2,$aa           // c c c c 10101010b
 shufps xmm3,xmm3,$ff           // d d d d 11111111b
 movups xmm4,[edx+0]
 movups xmm5,[edx+16]
 movups xmm6,[edx+32]
 movups xmm7,[edx+48]
 mulps xmm0,xmm4
 mulps xmm1,xmm5
 mulps xmm2,xmm6
 mulps xmm3,xmm7
 addps xmm0,xmm1
 addps xmm2,xmm3
 addps xmm0,xmm2
 movups [esp],xmm0
 movss xmm0,dword ptr [esp]
 movss xmm1,dword ptr [esp+4]
 movss xmm2,dword ptr [esp+8]
 movss dword ptr [ecx],xmm0
 movss dword ptr [ecx+4],xmm1
 movss dword ptr [ecx+8],xmm2
 add esp,16
end;
{$else}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
end;
{$endif}

function SIMDVector3Lerp(const v1,v2:TSIMDVector3;w:single):TSIMDVector3; {$ifdef caninline}inline;{$endif}
var iw:single;
begin
 if w<0.0 then begin
  result:=v1;
 end else if w>1.0 then begin
  result:=v2;
 end else begin
  iw:=1.0-w;
  result.x:=(iw*v1.x)+(w*v2.x);
  result.y:=(iw*v1.y)+(w*v2.y);
  result.z:=(iw*v1.z)+(w*v2.z);
 end;
end;

function SIMDVector3Perpendicular(v:TSIMDVector3):TSIMDVector3; {$ifdef caninline}inline;{$endif}
var p:TSIMDVector3;
begin
 SIMDVector3Normalize(v);
 p.x:=abs(v.x);
 p.y:=abs(v.y);
 p.z:=abs(v.z);
 if (p.x<=p.y) and (p.x<=p.z) then begin
  p:=SIMDVector3XAxis;
 end else if (p.y<=p.x) and (p.y<=p.z) then begin
  p:=SIMDVector3YAxis;
 end else begin
  p:=SIMDVector3ZAxis;
 end;
 result:=SIMDVector3Norm(SIMDVector3Sub(p,SIMDVector3ScalarMul(v,SIMDVector3Dot(v,p))));
end;

function SIMDVector3TermQuaternionRotate(const v:TSIMDVector3;const q:TQuaternion):TSIMDVector3; {$ifdef caninline}inline;{$endif}
var t,qv:TSIMDVector3;
begin
 // t = 2 * cross(q.xyz, v)
 // v' = v + q.w * t + cross(q.xyz, t)
 qv:=PSIMDVector3(pointer(@q))^;
 t:=SIMDVector3ScalarMul(SIMDVector3Cross(qv,v),2.0);
 result:=SIMDVector3Add(SIMDVector3Add(v,SIMDVector3ScalarMul(t,q.w)),SIMDVector3Cross(qv,t));
end;
{var vn:TSIMDVector3;
vq,rq:TQuaternion;
begin
 vq.x:=vn.x;
 vq.y:=vn.y;
 vq.z:=vn.z;
 vq.w:=0.0;
 rq:=QuaternionMul(q,QuaternionMul(vq,QuaternionConjugate(q)));
 result.x:=rq.x;
 result.y:=rq.y;
 result.z:=rq.z;
end;{}

function SIMDVector3ProjectToBounds(const v:TSIMDVector3;const MinVector,MaxVector:TSIMDVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=0.0;
 if v.x<0.0 then begin
  result:=v.x*MaxVector.x;
 end else begin
  result:=v.x*MinVector.x;
 end;
 if v.y<0.0 then begin
  result:=result+(v.y*MaxVector.y);
 end else begin
  result:=result+(v.y*MinVector.y);
 end;
 if v.z<0.0 then begin
  result:=result+(v.z*MaxVector.z);
 end else begin
  result:=result+(v.z*MinVector.z);
 end;
end;
{$endif}

function Vector4Compare(const v1,v2:TVector4):boolean;
begin
 result:=(abs(v1.x-v2.x)<EPSILON) and (abs(v1.y-v2.y)<EPSILON) and (abs(v1.z-v2.z)<EPSILON) and (abs(v1.w-v2.w)<EPSILON);
end;

function Vector4CompareEx(const v1,v2:TVector4;const Threshold:single=1e-12):boolean;
begin
 result:=(abs(v1.x-v2.x)<Threshold) and (abs(v1.y-v2.y)<Threshold) and (abs(v1.z-v2.z)<Threshold) and (abs(v1.w-v2.w)<Threshold);
end;

function Vector4Add(const v1,v2:TVector4):TVector4;
begin
 result.x:=v1.x+v2.x;
 result.y:=v1.y+v2.y;
 result.z:=v1.z+v2.z;
 result.w:=v1.w+v2.w;
end;

function Vector4Sub(const v1,v2:TVector4):TVector4;
begin
 result.x:=v1.x-v2.x;
 result.y:=v1.y-v2.y;
 result.z:=v1.z-v2.z;
 result.w:=v1.w-v2.w;
end;

function Vector4ScalarMul(const v:TVector4;s:single):TVector4;
begin
 result.x:=v.x*s;
 result.y:=v.y*s;
 result.z:=v.z*s;
 result.w:=v.w*s;
end;

function Vector4Dot(const v1,v2:TVector4):single;
begin
 result:=(v1.x*v2.x)+(v1.y*v2.y)+(v1.z*v2.z)+(v1.w*v2.w);
end;

function Vector4Cross(const v1,v2:TVector4):TVector4;
begin
 result.x:=(v1.y*v2.z)-(v2.y*v1.z);
 result.y:=(v2.x*v1.z)-(v1.x*v2.z);
 result.z:=(v1.x*v2.y)-(v2.x*v1.y);
 result.w:=1;
end;

function Vector4Neg(const v:TVector4):TVector4;
begin
 result.x:=-v.x;
 result.y:=-v.y;
 result.z:=-v.z;
 result.w:=1;
end;

procedure Vector4Scale(var v:TVector4;sx,sy,sz:single); overload;
begin
 v.x:=v.x*sx;
 v.y:=v.y*sy;
 v.z:=v.z*sz;
end;

procedure Vector4Scale(var v:TVector4;s:single); overload;
begin
 v.x:=v.x*s;
 v.y:=v.y*s;
 v.z:=v.z*s;
end;

function Vector4Mul(const v1,v2:TVector4):TVector4;
begin
 result.x:=v1.x*v2.x;
 result.y:=v1.y*v2.y;
 result.z:=v1.z*v2.z;
 result.w:=1;
end;

function Vector4Length(const v:TVector4):single;
begin
 result:=SQRT((v.x*v.x)+(v.y*v.y)+(v.z*v.z));
end;

function Vector4Dist(const v1,v2:TVector4):single;
begin
 result:=Vector4Length(Vector4Sub(v2,v1));
end;

function Vector4LengthSquared(const v:TVector4):single;
begin
 result:=(v.x*v.x)+(v.y*v.y)+(v.z*v.z);
end;

function Vector4DistSquared(const v1,v2:TVector4):single;
begin
 result:=Vector4LengthSquared(Vector4Sub(v2,v1));
end;

function Vector4Angle(const v1,v2,v3:TVector4):single;
var A1,A2:TVector4;
    L1,L2:single;
begin
 A1:=Vector4Sub(v1,v2);
 A2:=Vector4Sub(v3,v2);
 L1:=Vector4Length(A1);
 L2:=Vector4Length(A2);
 if (L1=0) or (L2=0) then begin
  result:=0;
 end else begin
  result:=ArcCos(Vector4Dot(A1,A2)/(L1*L2));
 end;
end;

procedure Vector4Normalize(var v:TVector4);
var L:single;
begin
 L:=Vector4Length(v);
 if abs(L)>EPSILON then begin
  Vector4Scale(v,1/L);
 end else begin
  v:=Vector4Origin;
 end;
end;

function Vector4Norm(const v:TVector4):TVector4;
var L:single;
begin
 L:=Vector4Length(v);
 if abs(L)>EPSILON then begin
  result:=Vector4ScalarMul(v,1/L);
 end else begin
  result:=Vector4Origin;
 end;
end;

procedure Vector4RotateX(var v:TVector4;a:single);
var t:TVector4;
begin
 t.x:=v.x;
 t.y:=(v.y*cos(a))+(v.z*-sin(a));
 t.z:=(v.y*sin(a))+(v.z*cos(a));
 t.w:=1;
 v:=t;
end;

procedure Vector4RotateY(var v:TVector4;a:single);
var t:TVector4;
begin
 t.x:=(v.x*cos(a))+(v.z*sin(a));
 t.y:=v.y;
 t.z:=(v.x*-sin(a))+(v.z*cos(a));
 t.w:=1;
 v:=t;
end;

procedure Vector4RotateZ(var v:TVector4;a:single);
var t:TVector4;
begin
 t.x:=(v.x*cos(a))+(v.y*-sin(a));
 t.y:=(v.x*sin(a))+(v.y*cos(a));
 t.z:=v.z;
 t.w:=1;
 v:=t;
end;

procedure Vector4MatrixMul(var v:TVector4;const m:TMatrix4x4); {$ifdef cpu386asm}register;{$endif}
{$ifdef cpu386asm}
asm
{mov eax,v
 mov edx,m}
 movups xmm0,dqword ptr [v]     // d c b a
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 movaps xmm3,xmm0               // d c b a
 shufps xmm0,xmm0,$00           // a a a a 00000000b
 shufps xmm1,xmm1,$55           // b b b b 01010101b
 shufps xmm2,xmm2,$aa           // c c c c 10101010b
 shufps xmm3,xmm3,$ff           // d d d d 11111111b
 movups xmm4,dqword ptr [m+0]
 movups xmm5,dqword ptr [m+16]
 movups xmm6,dqword ptr [m+32]
 movups xmm7,dqword ptr [m+48]
 mulps xmm0,xmm4
 mulps xmm1,xmm5
 mulps xmm2,xmm6
 mulps xmm3,xmm7
 addps xmm0,xmm1
 addps xmm2,xmm3
 addps xmm0,xmm2
 movups dqword ptr [v],xmm0
end;
{$else}
var t:TVector4;
begin
 t.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+(m[3,0]*v.w);
 t.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+(m[3,1]*v.w);
 t.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+(m[3,2]*v.w);
 t.w:=(m[0,3]*v.x)+(m[1,3]*v.y)+(m[2,3]*v.z)+(m[3,3]*v.w);
 v:=t;
end;
{$endif}

function Vector4TermMatrixMul(const v:TVector4;const m:TMatrix4x4):TVector4; {$ifdef cpu386asm}register;{$endif}
{$ifdef cpu386asm}
asm
{mov eax,v
 mov edx,m
 mov ecx,result}
 movups xmm0,[eax]              // d c b a
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 movaps xmm3,xmm0               // d c b a
 shufps xmm0,xmm0,$00           // a a a a 00000000b
 shufps xmm1,xmm1,$55           // b b b b 01010101b
 shufps xmm2,xmm2,$aa           // c c c c 10101010b
 shufps xmm3,xmm3,$ff           // d d d d 11111111b
 movups xmm4,[edx+0]
 movups xmm5,[edx+16]
 movups xmm6,[edx+32]
 movups xmm7,[edx+48]
 mulps xmm0,xmm4
 mulps xmm1,xmm5
 mulps xmm2,xmm6
 mulps xmm3,xmm7
 addps xmm0,xmm1
 addps xmm2,xmm3
 addps xmm0,xmm2
 movups [ecx],xmm0
end;
{$else}
begin
 result.x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+(m[3,0]*v.w);
 result.y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+(m[3,1]*v.w);
 result.z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+(m[3,2]*v.w);
 result.w:=(m[0,3]*v.x)+(m[1,3]*v.y)+(m[2,3]*v.z)+(m[3,3]*v.w);
end;
{$endif}

function Vector4TermMatrixMulHomogen(const v:TVector4;const m:TMatrix4x4):TVector4;
begin
 result.w:=(m[0,3]*v.x)+(m[1,3]*v.y)+(m[2,3]*v.z)+(m[3,3]*v.w);
 result.x:=((m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+(m[3,0]*v.w))/result.w;
 result.y:=((m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+(m[3,1]*v.w))/result.w;
 result.z:=((m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+(m[3,2]*v.w))/result.w;
 result.w:=1.0;
end;

procedure Vector4Rotate(var v:TVector4;const Axis:TVector4;a:single);
begin
 Vector4MatrixMul(v,Matrix4x4Rotate(a,Vector3(Axis)));
end;

function Vector4Lerp(const v1,v2:TVector4;w:single):TVector4;
var iw:single;
begin
 if w<0.0 then begin
  result:=v1;
 end else if w>1.0 then begin
  result:=v2;
 end else begin
  iw:=1.0-w;
  result.x:=(iw*v1.x)+(w*v2.x);
  result.y:=(iw*v1.y)+(w*v2.y);
  result.z:=(iw*v1.z)+(w*v2.z);
  result.w:=(iw*v1.w)+(w*v2.w);
 end;
end;

function Matrix2x2Inverse(var mr:TMatrix2x2;const ma:TMatrix2x2):boolean;
var Determinant:single;
begin
 Determinant:=(ma[0,0]*ma[1,1])-(ma[0,1]*ma[1,0]);
 if abs(Determinant)<EPSILON then begin
  mr:=Matrix2x2Identity;
  result:=false;
 end else begin
  Determinant:=1.0/Determinant;
  mr[0,0]:=ma[1,1]*Determinant;
  mr[0,1]:=-(ma[0,1]*Determinant);
  mr[1,0]:=-(ma[1,0]*Determinant);
  mr[1,1]:=ma[0,0]*Determinant;
  result:=true;
 end;
end;

function Matrix2x2TermInverse(const m:TMatrix2x2):TMatrix2x2;
var Determinant:single;
begin
 Determinant:=(m[0,0]*m[1,1])-(m[0,1]*m[1,0]);
 if abs(Determinant)<EPSILON then begin
  result:=Matrix2x2Identity;
 end else begin
  Determinant:=1.0/Determinant;
  result[0,0]:=m[1,1]*Determinant;
  result[0,1]:=-(m[0,1]*Determinant);
  result[1,0]:=-(m[1,0]*Determinant);
  result[1,1]:=m[0,0]*Determinant;
 end;
end;

function Matrix3x3RotateX(Angle:single):TMatrix3x3; {$ifdef caninline}inline;{$endif}
begin
 result:=Matrix3x3Identity;
 result[1,1]:=cos(Angle);
 result[2,2]:=result[1,1];
 result[1,2]:=sin(Angle);
 result[2,1]:=-result[1,2];
end;

function Matrix3x3RotateY(Angle:single):TMatrix3x3; {$ifdef caninline}inline;{$endif}
begin
 result:=Matrix3x3Identity;
 result[0,0]:=cos(Angle);
 result[2,2]:=result[0,0];
 result[0,2]:=-sin(Angle);
 result[2,0]:=-result[0,2];
end;

function Matrix3x3RotateZ(Angle:single):TMatrix3x3; {$ifdef caninline}inline;{$endif}
begin
 result:=Matrix3x3Identity;
 result[0,0]:=cos(Angle);
 result[1,1]:=result[0,0];
 result[0,1]:=sin(Angle);
 result[1,0]:=-result[0,1];
end;

function Matrix3x3RotateAngles(Angles:TVector3):TMatrix3x3; overload;
var a,b,c,d,e,f,ad,bd:single;
begin
 a:=cos(Angles.Pitch);
 b:=sin(Angles.Pitch);
 c:=cos(Angles.Yaw);
 d:=sin(Angles.Yaw);
 e:=cos(Angles.Roll);
 f:=sin(Angles.Roll);
 ad:=a*d;
 bd:=b*d;
 result[0,0]:=c*e;
 result[1,0]:=-(c*f);
 result[2,0]:=d;
 result[0,1]:=(bd*e)+(a*f);
 result[1,1]:=(-(bd*f))+(a*e);
 result[2,1]:=-(b*c);
 result[0,2]:=(-(ad*e))+(b*f);
 result[1,2]:=(ad*f)+(b*e);
 result[2,2]:=a*c;
end;

function Matrix3x3RotateAnglesLDX(const Angles:TVector3):TMatrix3x3; overload;
var cp,sp,cy,sy,cr,sr:single;
    ForwardVector,RightVector,UpVector:TVector3;
begin
 cp:=cos(Angles.Pitch);
 sp:=sin(Angles.Pitch);
 cy:=cos(Angles.Yaw);
 sy:=sin(Angles.Yaw);
 cr:=cos(Angles.Roll);
 sr:=sin(Angles.Roll);
 ForwardVector.x:=cp*cy;
 ForwardVector.y:=cp*sy;
 ForwardVector.z:=-sp;
 RightVector.x:=((-(sr*sp*cy))-(cr*(-sy)));
 RightVector.y:=((-(sr*sp*sy))-(cr*cy));
 RightVector.z:=-(sr*cp);
 UpVector.x:=(cr*sp*cy)+((-sr)*(-sy));
 UpVector.y:=(cr*sp*sy)+((-sr)*cy);
 UpVector.z:=cr*cp;
 Vector3Normalize(ForwardVector);
 Vector3Normalize(RightVector);
 Vector3Normalize(UpVector);
 result[0,0]:=ForwardVector.x;
 result[1,0]:=ForwardVector.y;
 result[2,0]:=ForwardVector.z;
 result[0,1]:=-RightVector.x;
 result[1,1]:=-RightVector.y;
 result[2,1]:=-RightVector.z;
 result[0,2]:=UpVector.x;
 result[1,2]:=UpVector.y;
 result[2,2]:=UpVector.z;
end;

function Matrix3x3RotateAnglesLDXModel(const Angles:TVector3):TMatrix3x3; overload;
var cp,sp,cy,sy,cr,sr:single;
    ForwardVector,RightVector,UpVector:TVector3;
begin
 cp:=cos(Angles.Pitch);
 sp:=sin(Angles.Pitch);
 cy:=cos(Angles.Yaw);
 sy:=sin(Angles.Yaw);
 cr:=cos(Angles.Roll);
 sr:=sin(Angles.Roll);
 ForwardVector.x:=cp*cy;
 ForwardVector.y:=cp*sy;
 ForwardVector.z:=-sp;
 RightVector.x:=((-(sr*sp*cy))-(cr*(-sy)));
 RightVector.y:=((-(sr*sp*sy))-(cr*cy));
 RightVector.z:=-(sr*cp);
 UpVector.x:=(cr*sp*cy)+((-sr)*(-sy));
 UpVector.y:=(cr*sp*sy)+((-sr)*cy);
 UpVector.z:=cr*cp;
 Vector3Normalize(ForwardVector);
 Vector3Normalize(RightVector);
 Vector3Normalize(UpVector);
 result[0,0]:=ForwardVector.x;
 result[0,1]:=ForwardVector.y;
 result[0,2]:=ForwardVector.z;
 result[1,0]:=-RightVector.x;
 result[1,1]:=-RightVector.y;
 result[1,2]:=-RightVector.z;
 result[2,0]:=UpVector.x;
 result[2,1]:=UpVector.y;
 result[2,2]:=UpVector.z;
end;

function Matrix3x3Rotate(Angle:single;Axis:TVector3):TMatrix3x3; overload;
var m:TMatrix3x3;
    CosinusAngle,SinusAngle:single;
begin
 m:=Matrix3x3Identity;
 CosinusAngle:=cos(Angle);
 SinusAngle:=sin(Angle);
 m[0,0]:=CosinusAngle+((1.0-CosinusAngle)*sqr(Axis.x));
 m[1,0]:=((1.0-CosinusAngle)*Axis.x*Axis.y)-(Axis.z*SinusAngle);
 m[2,0]:=((1.0-CosinusAngle)*Axis.x*Axis.z)+(Axis.y*SinusAngle);
 m[0,1]:=((1.0-CosinusAngle)*Axis.x*Axis.z)+(Axis.z*SinusAngle);
 m[1,1]:=CosinusAngle+((1.0-CosinusAngle)*sqr(Axis.y));
 m[2,1]:=((1.0-CosinusAngle)*Axis.y*Axis.z)-(Axis.x*SinusAngle);
 m[0,2]:=((1.0-CosinusAngle)*Axis.x*Axis.z)-(Axis.y*SinusAngle);
 m[1,2]:=((1.0-CosinusAngle)*Axis.y*Axis.z)+(Axis.x*SinusAngle);
 m[2,2]:=CosinusAngle+((1.0-CosinusAngle)*sqr(Axis.z));
 result:=m;
end;

function Matrix3x3Scale(sx,sy,sz:single):TMatrix3x3; {$ifdef caninline}inline;{$endif}
begin
 result:=Matrix3x3Identity;
 result[0,0]:=sx;
 result[1,1]:=sy;
 result[2,2]:=sz;
end;

procedure Matrix3x3Add(var m1:TMatrix3x3;const m2:TMatrix3x3); {$ifdef caninline}inline;{$endif}
begin
 m1[0,0]:=m1[0,0]+m2[0,0];
 m1[0,1]:=m1[0,1]+m2[0,1];
 m1[0,2]:=m1[0,2]+m2[0,2];
 m1[1,0]:=m1[1,0]+m2[1,0];
 m1[1,1]:=m1[1,1]+m2[1,1];
 m1[1,2]:=m1[1,2]+m2[1,2];
 m1[2,0]:=m1[2,0]+m2[2,0];
 m1[2,1]:=m1[2,1]+m2[2,1];
 m1[2,2]:=m1[2,2]+m2[2,2];
end;

procedure Matrix3x3Sub(var m1:TMatrix3x3;const m2:TMatrix3x3); {$ifdef caninline}inline;{$endif}
begin
 m1[0,0]:=m1[0,0]-m2[0,0];
 m1[0,1]:=m1[0,1]-m2[0,1];
 m1[0,2]:=m1[0,2]-m2[0,2];
 m1[1,0]:=m1[1,0]-m2[1,0];
 m1[1,1]:=m1[1,1]-m2[1,1];
 m1[1,2]:=m1[1,2]-m2[1,2];
 m1[2,0]:=m1[2,0]-m2[2,0];
 m1[2,1]:=m1[2,1]-m2[2,1];
 m1[2,2]:=m1[2,2]-m2[2,2];
end;

procedure Matrix3x3Mul(var m1:TMatrix3x3;const m2:TMatrix3x3);
var t:TMatrix3x3;
begin
 t[0,0]:=(m1[0,0]*m2[0,0])+(m1[0,1]*m2[1,0])+(m1[0,2]*m2[2,0]);
 t[0,1]:=(m1[0,0]*m2[0,1])+(m1[0,1]*m2[1,1])+(m1[0,2]*m2[2,1]);
 t[0,2]:=(m1[0,0]*m2[0,2])+(m1[0,1]*m2[1,2])+(m1[0,2]*m2[2,2]);
 t[1,0]:=(m1[1,0]*m2[0,0])+(m1[1,1]*m2[1,0])+(m1[1,2]*m2[2,0]);
 t[1,1]:=(m1[1,0]*m2[0,1])+(m1[1,1]*m2[1,1])+(m1[1,2]*m2[2,1]);
 t[1,2]:=(m1[1,0]*m2[0,2])+(m1[1,1]*m2[1,2])+(m1[1,2]*m2[2,2]);
 t[2,0]:=(m1[2,0]*m2[0,0])+(m1[2,1]*m2[1,0])+(m1[2,2]*m2[2,0]);
 t[2,1]:=(m1[2,0]*m2[0,1])+(m1[2,1]*m2[1,1])+(m1[2,2]*m2[2,1]);
 t[2,2]:=(m1[2,0]*m2[0,2])+(m1[2,1]*m2[1,2])+(m1[2,2]*m2[2,2]);
 m1:=t;
end;
          
function Matrix3x3TermAdd(const m1,m2:TMatrix3x3):TMatrix3x3; {$ifdef caninline}inline;{$endif}
begin
 result[0,0]:=m1[0,0]+m2[0,0];
 result[0,1]:=m1[0,1]+m2[0,1];
 result[0,2]:=m1[0,2]+m2[0,2];
 result[1,0]:=m1[1,0]+m2[1,0];
 result[1,1]:=m1[1,1]+m2[1,1];
 result[1,2]:=m1[1,2]+m2[1,2];
 result[2,0]:=m1[2,0]+m2[2,0];
 result[2,1]:=m1[2,1]+m2[2,1];
 result[2,2]:=m1[2,2]+m2[2,2];
end;

function Matrix3x3TermSub(const m1,m2:TMatrix3x3):TMatrix3x3; {$ifdef caninline}inline;{$endif}
begin
 result[0,0]:=m1[0,0]-m2[0,0];
 result[0,1]:=m1[0,1]-m2[0,1];
 result[0,2]:=m1[0,2]-m2[0,2];
 result[1,0]:=m1[1,0]-m2[1,0];
 result[1,1]:=m1[1,1]-m2[1,1];
 result[1,2]:=m1[1,2]-m2[1,2];
 result[2,0]:=m1[2,0]-m2[2,0];
 result[2,1]:=m1[2,1]-m2[2,1];
 result[2,2]:=m1[2,2]-m2[2,2];
end;

function Matrix3x3TermMul(const m1,m2:TMatrix3x3):TMatrix3x3;
begin
 result[0,0]:=(m1[0,0]*m2[0,0])+(m1[0,1]*m2[1,0])+(m1[0,2]*m2[2,0]);
 result[0,1]:=(m1[0,0]*m2[0,1])+(m1[0,1]*m2[1,1])+(m1[0,2]*m2[2,1]);
 result[0,2]:=(m1[0,0]*m2[0,2])+(m1[0,1]*m2[1,2])+(m1[0,2]*m2[2,2]);
 result[1,0]:=(m1[1,0]*m2[0,0])+(m1[1,1]*m2[1,0])+(m1[1,2]*m2[2,0]);
 result[1,1]:=(m1[1,0]*m2[0,1])+(m1[1,1]*m2[1,1])+(m1[1,2]*m2[2,1]);
 result[1,2]:=(m1[1,0]*m2[0,2])+(m1[1,1]*m2[1,2])+(m1[1,2]*m2[2,2]);
 result[2,0]:=(m1[2,0]*m2[0,0])+(m1[2,1]*m2[1,0])+(m1[2,2]*m2[2,0]);
 result[2,1]:=(m1[2,0]*m2[0,1])+(m1[2,1]*m2[1,1])+(m1[2,2]*m2[2,1]);
 result[2,2]:=(m1[2,0]*m2[0,2])+(m1[2,1]*m2[1,2])+(m1[2,2]*m2[2,2]);
end;

function Matrix3x3TermMulTranspose(const m1,m2:TMatrix3x3):TMatrix3x3;
begin
 result[0,0]:=(m1[0,0]*m2[0,0])+(m1[0,1]*m2[0,1])+(m1[0,2]*m2[0,2]);
 result[0,1]:=(m1[0,0]*m2[1,0])+(m1[0,1]*m2[1,1])+(m1[0,2]*m2[1,2]);
 result[0,2]:=(m1[0,0]*m2[2,0])+(m1[0,1]*m2[2,1])+(m1[0,2]*m2[2,2]);
 result[1,0]:=(m1[1,0]*m2[0,0])+(m1[1,1]*m2[0,1])+(m1[1,2]*m2[0,2]);
 result[1,1]:=(m1[1,0]*m2[1,0])+(m1[1,1]*m2[1,1])+(m1[1,2]*m2[1,2]);
 result[1,2]:=(m1[1,0]*m2[2,0])+(m1[1,1]*m2[2,1])+(m1[1,2]*m2[2,2]);
 result[2,0]:=(m1[2,0]*m2[0,0])+(m1[2,1]*m2[0,1])+(m1[2,2]*m2[0,2]);
 result[2,1]:=(m1[2,0]*m2[1,0])+(m1[2,1]*m2[1,1])+(m1[2,2]*m2[1,2]);
 result[2,2]:=(m1[2,0]*m2[2,0])+(m1[2,1]*m2[2,1])+(m1[2,2]*m2[2,2]);
end;

procedure Matrix3x3ScalarMul(var m:TMatrix3x3;s:single); {$ifdef caninline}inline;{$endif}
begin
 m[0,0]:=m[0,0]*s;
 m[0,1]:=m[0,1]*s;
 m[0,2]:=m[0,2]*s;
 m[1,0]:=m[1,0]*s;
 m[1,1]:=m[1,1]*s;
 m[1,2]:=m[1,2]*s;
 m[2,0]:=m[2,0]*s;
 m[2,1]:=m[2,1]*s;
 m[2,2]:=m[2,2]*s;
end;

function Matrix3x3TermScalarMul(const m:TMatrix3x3;s:single):TMatrix3x3; {$ifdef caninline}inline;{$endif}
begin
 result[0,0]:=m[0,0]*s;
 result[0,1]:=m[0,1]*s;
 result[0,2]:=m[0,2]*s;
 result[1,0]:=m[1,0]*s;
 result[1,1]:=m[1,1]*s;
 result[1,2]:=m[1,2]*s;
 result[2,0]:=m[2,0]*s;
 result[2,1]:=m[2,1]*s;
 result[2,2]:=m[2,2]*s;
end;

procedure Matrix3x3Transpose(var m:TMatrix3x3); {$ifdef caninline}inline;{$endif}
var mt:TMatrix3x3;
begin
 mt[0,0]:=m[0,0];
 mt[1,0]:=m[0,1];
 mt[2,0]:=m[0,2];
 mt[0,1]:=m[1,0];
 mt[1,1]:=m[1,1];
 mt[2,1]:=m[1,2];
 mt[0,2]:=m[2,0];
 mt[1,2]:=m[2,1];
 mt[2,2]:=m[2,2];
 m:=mt;
end;

function Matrix3x3TermTranspose(const m:TMatrix3x3):TMatrix3x3; {$ifdef caninline}inline;{$endif}
begin
 result[0,0]:=m[0,0];
 result[1,0]:=m[0,1];
 result[2,0]:=m[0,2];
 result[0,1]:=m[1,0];
 result[1,1]:=m[1,1];
 result[2,1]:=m[1,2];
 result[0,2]:=m[2,0];
 result[1,2]:=m[2,1];
 result[2,2]:=m[2,2];
end;

function Matrix3x3Determinant(const m:TMatrix3x3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=(m[0,0]*((m[1,1]*m[2,2])-(m[2,1]*m[1,2])))-
         (m[0,1]*((m[1,0]*m[2,2])-(m[2,0]*m[1,2])))+
         (m[0,2]*((m[1,0]*m[2,1])-(m[2,0]*m[1,1])));{}
{result:=(m[0,0]*m[1,1]*m[2,2])+
         (m[1,0]*m[2,1]*m[0,2])+
         (m[2,0]*m[0,1]*m[1,2])-
         (m[2,0]*m[1,1]*m[0,2])-
         (m[1,0]*m[0,1]*m[2,2])-
         (m[0,0]*m[2,1]*m[1,2]);{}
end;

function Matrix3x3Angles(const m:TMatrix3x3):TVector3;
var XAngle,YAngle,ZAngle,c,d,tx,ty:single;
begin
 d:=ArcSin(m[2,0]);
 YAngle:=d;
 c:=cos(YAngle);
 if abs(c)>0.005 then begin
  tx:=m[2,2]/c;
  ty:=-m[2,1]/c;
  XAngle:=ArcTan2(ty,tx);
  tx:=m[0,0]/c;
  ty:=-m[1,0]/c;
  ZAngle:=ArcTan2(ty,tx);
 end else begin
  XAngle:=0;
  tx:=m[1,1];
  ty:=m[0,1];
  ZAngle:=ArcTan2(ty,tx);
 end;
 if XAngle<0 then begin
  XAngle:=XAngle+(2*PI);
 end;
 if YAngle<0 then begin
  YAngle:=YAngle+(2*PI);
 end;
 if ZAngle<0 then begin
  ZAngle:=ZAngle+(2*PI);
 end;
 result.Pitch:=XAngle;
 result.Yaw:=ZAngle;
 result.Roll:=YAngle;
end;

function Matrix3x3EulerAngles(const m:TMatrix3x3):TVector3;
var v0,v1:TVector3;
begin
 if abs((-1.0)-m[0,2])<EPSILON then begin
  result.x:=0.0;
  result.y:=pi*0.5;
  result.z:=ArcTan2(m[1,0],m[2,0]);
 end else if abs(1.0-m[0,2])<EPSILON then begin
  result.x:=0.0;
  result.y:=-(pi*0.5);
  result.z:=ArcTan2(-m[1,0],-m[2,0]);
 end else begin
  v0.x:=-ArcSin(m[0,2]);
  v1.x:=pi-v0.x;
  v0.y:=ArcTan2(m[1,2]/cos(v0.x),m[2,2]/cos(v0.x));
  v1.y:=ArcTan2(m[1,2]/cos(v1.x),m[2,2]/cos(v1.x));
  v0.z:=ArcTan2(m[0,1]/cos(v0.x),m[0,0]/cos(v0.x));
  v1.z:=ArcTan2(m[0,1]/cos(v1.x),m[0,0]/cos(v1.x));
  if Vector3LengthSquared(v0)<Vector3LengthSquared(v1) then begin
   result:=v0;
  end else begin
   result:=v1;
  end;
 end;
end;

procedure Matrix3x3SetColumn(var m:TMatrix3x3;const c:longint;const v:TVector3); {$ifdef caninline}inline;{$endif}
begin
 m[c,0]:=v.x;
 m[c,1]:=v.y;
 m[c,2]:=v.z;
end;

function Matrix3x3GetColumn(const m:TMatrix3x3;const c:longint):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=m[c,0];
 result.y:=m[c,1];
 result.z:=m[c,2];
end;

procedure Matrix3x3SetRow(var m:TMatrix3x3;const r:longint;const v:TVector3); {$ifdef caninline}inline;{$endif}
begin
 m[0,r]:=v.x;
 m[1,r]:=v.y;
 m[2,r]:=v.z;
end;

function Matrix3x3GetRow(const m:TMatrix3x3;const r:longint):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=m[0,r];
 result.y:=m[1,r];
 result.z:=m[2,r];
end;

function Matrix3x3Compare(const m1,m2:TMatrix3x3):boolean;
var r,c:longint;
begin
 result:=true;
 for r:=0 to 2 do begin
  for c:=0 to 2 do begin
   if abs(m1[r,c]-m2[r,c])>EPSILON then begin
    result:=false;
    exit;
   end;
  end;
 end;
end;

function Matrix3x3Inverse(var mr:TMatrix3x3;const ma:TMatrix3x3):boolean;
var Determinant:single;
begin
 Determinant:=((ma[0,0]*((ma[1,1]*ma[2,2])-(ma[2,1]*ma[1,2])))-
               (ma[0,1]*((ma[1,0]*ma[2,2])-(ma[2,0]*ma[1,2]))))+
               (ma[0,2]*((ma[1,0]*ma[2,1])-(ma[2,0]*ma[1,1])));
 if abs(Determinant)<EPSILON then begin
  mr:=Matrix3x3Identity;
  result:=false;
 end else begin
  Determinant:=1.0/Determinant;
  mr[0,0]:=((ma[1,1]*ma[2,2])-(ma[2,1]*ma[1,2]))*Determinant;
  mr[0,1]:=((ma[0,2]*ma[2,1])-(ma[0,1]*ma[2,2]))*Determinant;
  mr[0,2]:=((ma[0,1]*ma[1,2])-(ma[0,2]*ma[1,1]))*Determinant;
  mr[1,0]:=((ma[1,2]*ma[2,0])-(ma[1,0]*ma[2,2]))*Determinant;
  mr[1,1]:=((ma[0,0]*ma[2,2])-(ma[0,2]*ma[2,0]))*Determinant;
  mr[1,2]:=((ma[1,0]*ma[0,2])-(ma[0,0]*ma[1,2]))*Determinant;
  mr[2,0]:=((ma[1,0]*ma[2,1])-(ma[2,0]*ma[1,1]))*Determinant;
  mr[2,1]:=((ma[2,0]*ma[0,1])-(ma[0,0]*ma[2,1]))*Determinant;
  mr[2,2]:=((ma[0,0]*ma[1,1])-(ma[1,0]*ma[0,1]))*Determinant;
  result:=true;
 end;
end;

function Matrix3x3TermInverse(const m:TMatrix3x3):TMatrix3x3;
var Determinant:single;
begin
 Determinant:=((m[0,0]*((m[1,1]*m[2,2])-(m[2,1]*m[1,2])))-
               (m[0,1]*((m[1,0]*m[2,2])-(m[2,0]*m[1,2]))))+
               (m[0,2]*((m[1,0]*m[2,1])-(m[2,0]*m[1,1])));
 if abs(Determinant)<EPSILON then begin
  result:=Matrix3x3Identity;
 end else begin
  Determinant:=1.0/Determinant;
  result[0,0]:=((m[1,1]*m[2,2])-(m[2,1]*m[1,2]))*Determinant;
  result[0,1]:=((m[0,2]*m[2,1])-(m[0,1]*m[2,2]))*Determinant;
  result[0,2]:=((m[0,1]*m[1,2])-(m[0,2]*m[1,1]))*Determinant;
  result[1,0]:=((m[1,2]*m[2,0])-(m[1,0]*m[2,2]))*Determinant;
  result[1,1]:=((m[0,0]*m[2,2])-(m[0,2]*m[2,0]))*Determinant;
  result[1,2]:=((m[1,0]*m[0,2])-(m[0,0]*m[1,2]))*Determinant;
  result[2,0]:=((m[1,0]*m[2,1])-(m[2,0]*m[1,1]))*Determinant;
  result[2,1]:=((m[2,0]*m[0,1])-(m[0,0]*m[2,1]))*Determinant;
  result[2,2]:=((m[0,0]*m[1,1])-(m[1,0]*m[0,1]))*Determinant;
 end;
end;

function Matrix3x3Map(const a,b:TVector3):TMatrix3x3;
var Axis:TVector3;
    Angle,Dot:single;
    Mat:TMatrix3x3;
    AQuaternion:TQuaternion;
begin
 Dot:=Vector3Dot(a,b);
 if abs(Dot-1)<EPSILON then begin
  Mat:=Matrix3x3Identity;
 end else begin
  Axis:=Vector3Cross(a,b);
  if abs(Dot+1)<EPSILON then begin
   AQuaternion:=QuaternionFromAxisAngle(Vector3(1.0,0.0,0.0),PI);
   Mat:=QuaternionToMatrix3x3(AQuaternion);
  end else begin
   Angle:=ArcCos(Dot);
   if Vector3Compare(Axis,Vector3Origin) then begin
    Axis:=Vector3Cross(a,Vector3Norm(Vector3(b.y,a.z,a.x)));
    Angle:=PI;
   end;
   Vector3Normalize(Axis);
   AQuaternion:=QuaternionFromAxisAngle(Axis,Angle);
   Mat:=QuaternionToMatrix3x3(AQuaternion);
  end;
 end;
 result:=Mat;
end;

procedure Matrix3x3OrthoNormalize(var m:TMatrix3x3);
var x,y,z:TVector3;
begin
 x:=Vector3Norm(Vector3(m[0,0],m[0,1],m[0,2]));
 y:=Vector3(m[1,0],m[1,1],m[1,2]);
 z:=Vector3Norm(Vector3Cross(x,y));
 y:=Vector3Norm(Vector3Cross(z,x));
 m[0,0]:=x.x;
 m[0,1]:=x.y;
 m[0,2]:=x.z;
 m[1,0]:=y.x;
 m[1,1]:=y.y;
 m[1,2]:=y.z;
 m[2,0]:=z.x;
 m[2,1]:=z.y;
 m[2,2]:=z.z;
end;

function Matrix3x3Slerp(const a,b:TMatrix3x3;x:single):TMatrix3x3;
//var ix:single;
begin
 if x<=0.0 then begin
  result:=a;
 end else if x>=1.0 then begin
  result:=b;
 end else begin
  result:=QuaternionToMatrix3x3(QuaternionSlerp(QuaternionFromMatrix3x3(a),QuaternionFromMatrix3x3(b),x));
 end;
end;

function Matrix3x3FromToRotation(const FromDirection,ToDirection:TVector3):TMatrix3x3;
const EPSILON=1e-7;
var e,h,hvx,hvz,hvxy,hvxz,hvyz:single;
    x,u,v,c:TVector3;
begin
 e:=(FromDirection.x*ToDirection.x)+(FromDirection.y*ToDirection.y)+(FromDirection.z*ToDirection.z);
 if abs(e)>(1.0-EPSILON) then begin
  x.x:=abs(FromDirection.x);
  x.y:=abs(FromDirection.y);
  x.z:=abs(FromDirection.z);
  if x.x<x.y then begin
   if x.x<x.z then begin
    x.x:=1.0;
    x.y:=0.0;
    x.z:=0.0;
   end else begin
    x.x:=0.0;
    x.y:=0.0;
    x.z:=1.0;
   end;
  end else begin
   if x.y<x.z then begin
    x.x:=0.0;
    x.y:=1.0;
    x.z:=0.0;
   end else begin
    x.x:=0.0;
    x.y:=0.0;
    x.z:=1.0;
   end;
  end;
  u.x:=x.x-FromDirection.x;
  u.y:=x.y-FromDirection.y;
  u.z:=x.z-FromDirection.z;
  v.x:=x.x-ToDirection.x;
  v.y:=x.y-ToDirection.y;
  v.z:=x.z-ToDirection.z;
  c.x:=2.0/(sqr(u.x)+sqr(u.y)+sqr(u.z));
  c.y:=2.0/(sqr(v.x)+sqr(v.y)+sqr(v.z));
  c.z:=c.x*c.y*((u.x*v.x)+(u.y*v.y)+(u.z*v.z));
  result[0,0]:=1.0+((c.z*(v.x*u.x))-((c.y*(v.x*v.x))+(c.x*(u.x*u.x))));
  result[0,1]:=(c.z*(v.x*u.y))-((c.y*(v.x*v.y))+(c.x*(u.x*u.y)));
  result[0,2]:=(c.z*(v.x*u.z))-((c.y*(v.x*v.z))+(c.x*(u.x*u.z)));
  result[1,0]:=(c.z*(v.y*u.x))-((c.y*(v.y*v.x))+(c.x*(u.y*u.x)));
  result[1,1]:=1.0+((c.z*(v.y*u.y))-((c.y*(v.y*v.y))+(c.x*(u.y*u.y))));
  result[1,2]:=(c.z*(v.y*u.z))-((c.y*(v.y*v.z))+(c.x*(u.y*u.z)));
  result[2,0]:=(c.z*(v.z*u.x))-((c.y*(v.z*v.x))+(c.x*(u.z*u.x)));
  result[2,1]:=(c.z*(v.z*u.y))-((c.y*(v.z*v.y))+(c.x*(u.z*u.y)));
  result[2,2]:=1.0+((c.z*(v.z*u.z))-((c.y*(v.z*v.z))+(c.x*(u.z*u.z))));
 end else begin
  v:=Vector3Cross(FromDirection,ToDirection);
  h:=1.0/(1.0+e);
  hvx:=h*v.x;
  hvz:=h*v.z;
  hvxy:=hvx*v.y;
  hvxz:=hvx*v.z;
  hvyz:=hvz*v.y;
  result[0,0]:=e+(hvx*v.x);
  result[0,1]:=hvxy-v.z;
  result[0,2]:=hvxz+v.y;
  result[1,0]:=hvxy+v.z;
  result[1,1]:=e+(h*sqr(v.y));
  result[1,2]:=hvyz-v.x;
  result[2,0]:=hvxz-v.y;
  result[2,1]:=hvyz+v.x;
  result[2,2]:=e+(hvz*v.z);
 end;
end;

function Matrix3x3Construct(const Forwards,Up:TVector3):TMatrix3x3;
var RightVector,UpVector,ForwardVector:TVector3;
begin
 ForwardVector:=Vector3Norm(Vector3Neg(Forwards));
 RightVector:=Vector3Norm(Vector3Cross(Up,ForwardVector));
 UpVector:=Vector3Norm(Vector3Cross(ForwardVector,RightVector));
 result[0,0]:=RightVector.x;
 result[0,1]:=RightVector.y;
 result[0,2]:=RightVector.z;
 result[1,0]:=UpVector.x;
 result[1,1]:=UpVector.y;
 result[1,2]:=UpVector.z;
 result[2,0]:=ForwardVector.x;
 result[2,1]:=ForwardVector.y;
 result[2,2]:=ForwardVector.z;
end;     

function Matrix4x4Set(m:TMatrix3x3):TMatrix4x4;
begin
 result[0,0]:=m[0,0];
 result[0,1]:=m[0,1];
 result[0,2]:=m[0,2];
 result[0,3]:=0;
 result[1,0]:=m[1,0];
 result[1,1]:=m[1,1];
 result[1,2]:=m[1,2];
 result[1,3]:=0;
 result[2,0]:=m[2,0];
 result[2,1]:=m[2,1];
 result[2,2]:=m[2,2];
 result[2,3]:=0;
 result[3,0]:=0;
 result[3,1]:=0;
 result[3,2]:=0;
 result[3,3]:=1;
end;

function Matrix4x4Rotation(m:TMatrix4x4):TMatrix4x4;
begin
 result[0,0]:=m[0,0];
 result[0,1]:=m[0,1];
 result[0,2]:=m[0,2];
 result[0,3]:=0;
 result[1,0]:=m[1,0];
 result[1,1]:=m[1,1];
 result[1,2]:=m[1,2];
 result[1,3]:=0;
 result[2,0]:=m[2,0];
 result[2,1]:=m[2,1];
 result[2,2]:=m[2,2];
 result[2,3]:=0;
 result[3,0]:=0;
 result[3,1]:=0;
 result[3,2]:=0;
 result[3,3]:=1;
end;

function Matrix4x4RotateX(Angle:single):TMatrix4x4;
begin
 result:=Matrix4x4Identity;
 result[1,1]:=cos(Angle);
 result[2,2]:=result[1,1];
 result[1,2]:=sin(Angle);
 result[2,1]:=-result[1,2];
end;

function Matrix4x4RotateY(Angle:single):TMatrix4x4;
begin
 result:=Matrix4x4Identity;
 result[0,0]:=cos(Angle);
 result[2,2]:=result[0,0];
 result[0,2]:=-sin(Angle);
 result[2,0]:=-result[0,2];
end;

function Matrix4x4RotateZ(Angle:single):TMatrix4x4;
begin
 result:=Matrix4x4Identity;
 result[0,0]:=cos(Angle);
 result[1,1]:=result[0,0];
 result[0,1]:=sin(Angle);
 result[1,0]:=-result[0,1];
end;

function Matrix4x4RotateAngles(const Angles:TVector3):TMatrix4x4; overload;
var a,b,c,d,e,f,ad,bd:single;
begin
 a:=cos(Angles.Pitch);
 b:=sin(Angles.Pitch);
 c:=cos(Angles.Roll);
 d:=sin(Angles.Roll);
 e:=cos(Angles.Yaw);
 f:=sin(Angles.Yaw);
 ad:=a*d;
 bd:=b*d;
 result[0,0]:=c*e;
 result[1,0]:=-(c*f);
 result[2,0]:=d;
 result[3,0]:=0;
 result[0,1]:=(bd*e)+(a*f);
 result[1,1]:=(-(bd*f))+(a*e);
 result[2,1]:=-(b*c);
 result[3,1]:=0;
 result[0,2]:=(-(ad*e))+(b*f);
 result[1,2]:=(ad*f)+(b*e);
 result[2,2]:=a*c;
 result[3,2]:=0;
 result[0,3]:=0;
 result[1,3]:=0;
 result[2,3]:=0;
 result[3,3]:=1;
end;

function Matrix4x4RotateAnglesLDX(const Angles:TVector3):TMatrix4x4; overload;
var cp,sp,cy,sy,cr,sr:single;
    ForwardVector,RightVector,UpVector:TVector3;
begin
 cp:=cos(Angles.Pitch);
 sp:=sin(Angles.Pitch);
 cy:=cos(Angles.Yaw);
 sy:=sin(Angles.Yaw);
 cr:=cos(Angles.Roll);
 sr:=sin(Angles.Roll);
 ForwardVector.x:=cp*cy;
 ForwardVector.y:=cp*sy;
 ForwardVector.z:=-sp;
 RightVector.x:=((-(sr*sp*cy))-(cr*(-sy)));
 RightVector.y:=((-(sr*sp*sy))-(cr*cy));
 RightVector.z:=-(sr*cp);
 UpVector.x:=(cr*sp*cy)+((-sr)*(-sy));
 UpVector.y:=(cr*sp*sy)+((-sr)*cy);
 UpVector.z:=cr*cp;
 Vector3Normalize(ForwardVector);
 Vector3Normalize(RightVector);
 Vector3Normalize(UpVector);
 result[0,0]:=ForwardVector.x;
 result[1,0]:=ForwardVector.y;
 result[2,0]:=ForwardVector.z;
 result[3,0]:=0.0;
 result[0,1]:=-RightVector.x;
 result[1,1]:=-RightVector.y;
 result[2,1]:=-RightVector.z;
 result[3,1]:=0.0;
 result[0,2]:=UpVector.x;
 result[1,2]:=UpVector.y;
 result[2,2]:=UpVector.z;
 result[3,2]:=0.0;
 result[0,3]:=0.0;
 result[1,3]:=0.0;
 result[2,3]:=0.0;
 result[3,3]:=1.0;
end;

function Matrix4x4RotateAnglesLDXModel(const Angles:TVector3):TMatrix4x4; overload;
var cp,sp,cy,sy,cr,sr:single;
    ForwardVector,RightVector,UpVector:TVector3;
begin
 cp:=cos(Angles.Pitch);
 sp:=sin(Angles.Pitch);
 cy:=cos(Angles.Yaw);
 sy:=sin(Angles.Yaw);
 cr:=cos(Angles.Roll);
 sr:=sin(Angles.Roll);
 ForwardVector.x:=cp*cy;
 ForwardVector.y:=cp*sy;
 ForwardVector.z:=-sp;
 RightVector.x:=((-(sr*sp*cy))-(cr*(-sy)));
 RightVector.y:=((-(sr*sp*sy))-(cr*cy));
 RightVector.z:=-(sr*cp);
 UpVector.x:=(cr*sp*cy)+((-sr)*(-sy));
 UpVector.y:=(cr*sp*sy)+((-sr)*cy);
 UpVector.z:=cr*cp;
 Vector3Normalize(ForwardVector);
 Vector3Normalize(RightVector);
 Vector3Normalize(UpVector);
 result[0,0]:=ForwardVector.x;
 result[0,1]:=ForwardVector.y;
 result[0,2]:=ForwardVector.z;
 result[0,3]:=0.0;
 result[1,0]:=-RightVector.x;
 result[1,1]:=-RightVector.y;
 result[1,2]:=-RightVector.z;
 result[1,3]:=0.0;
 result[2,0]:=UpVector.x;
 result[2,1]:=UpVector.y;
 result[2,2]:=UpVector.z;
 result[2,3]:=0.0;
 result[3,0]:=0.0;
 result[3,1]:=0.0;
 result[3,2]:=0.0;
 result[3,3]:=1.0;
end;

function Matrix4x4Rotate(Angle:single;Axis:TVector3):TMatrix4x4; overload;
var m:TMatrix4x4;
    CosinusAngle,SinusAngle:single;
begin
 m:=Matrix4x4Identity;
 CosinusAngle:=cos(Angle);
 SinusAngle:=sin(Angle);    
 m[0,0]:=CosinusAngle+((1-CosinusAngle)*Axis.x*Axis.x);
 m[1,0]:=((1-CosinusAngle)*Axis.x*Axis.y)-(Axis.z*SinusAngle);
 m[2,0]:=((1-CosinusAngle)*Axis.x*Axis.z)+(Axis.y*SinusAngle);
 m[0,1]:=((1-CosinusAngle)*Axis.x*Axis.z)+(Axis.z*SinusAngle);
 m[1,1]:=CosinusAngle+((1-CosinusAngle)*Axis.y*Axis.y);
 m[2,1]:=((1-CosinusAngle)*Axis.y*Axis.z)-(Axis.x*SinusAngle);
 m[0,2]:=((1-CosinusAngle)*Axis.x*Axis.z)-(Axis.y*SinusAngle);
 m[1,2]:=((1-CosinusAngle)*Axis.y*Axis.z)+(Axis.x*SinusAngle);
 m[2,2]:=CosinusAngle+((1-CosinusAngle)*Axis.z*Axis.z);
 result:=m;
end;

function Matrix4x4Translate(x,y,z:single):TMatrix4x4; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=Matrix4x4Identity;
 result[3,0]:=x;
 result[3,1]:=y;
 result[3,2]:=z;
end;

function Matrix4x4Translate(const v:TVector3):TMatrix4x4; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=Matrix4x4Identity;
 result[3,0]:=v.x;
 result[3,1]:=v.y;
 result[3,2]:=v.z;
end;

function Matrix4x4Translate(const v:TVector4):TMatrix4x4; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=Matrix4x4Identity;
 result[3,0]:=v.x;
 result[3,1]:=v.y;
 result[3,2]:=v.z;
end;

procedure Matrix4x4Translate(var m:TMatrix4x4;const v:TVector3); overload; {$ifdef caninline}inline;{$endif}
begin
 m[3,0]:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
 m[3,1]:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
 m[3,2]:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
 m[3,3]:=(m[0,3]*v.x)+(m[1,3]*v.y)+(m[2,3]*v.z)+m[3,3];
end;

procedure Matrix4x4Translate(var m:TMatrix4x4;const v:TVector4); overload; {$ifdef caninline}inline;{$endif}
begin
 m[3,0]:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+(m[3,0]*v.w);
 m[3,1]:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+(m[3,1]*v.w);
 m[3,2]:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+(m[3,2]*v.w);
 m[3,3]:=(m[0,3]*v.x)+(m[1,3]*v.y)+(m[2,3]*v.z)+(m[3,3]*v.w);
end;

function Matrix4x4Scale(sx,sy,sz:single):TMatrix4x4; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=Matrix4x4Identity;
 result[0,0]:=sx;
 result[1,1]:=sy;
 result[2,2]:=sz;
end;

function Matrix4x4Scale(const s:TVector3):TMatrix4x4; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=Matrix4x4Identity;
 result[0,0]:=s.x;
 result[1,1]:=s.y;
 result[2,2]:=s.z;
end;

procedure Matrix4x4Add(var m1:TMatrix4x4;const m2:TMatrix4x4); {$ifdef caninline}inline;{$endif}
begin
 m1[0,0]:=m1[0,0]+m2[0,0];
 m1[0,1]:=m1[0,1]+m2[0,1];
 m1[0,2]:=m1[0,2]+m2[0,2];
 m1[0,3]:=m1[0,3]+m2[0,3];
 m1[1,0]:=m1[1,0]+m2[1,0];
 m1[1,1]:=m1[1,1]+m2[1,1];
 m1[1,2]:=m1[1,2]+m2[1,2];
 m1[1,3]:=m1[1,3]+m2[1,3];
 m1[2,0]:=m1[2,0]+m2[2,0];
 m1[2,1]:=m1[2,1]+m2[2,1];
 m1[2,2]:=m1[2,2]+m2[2,2];
 m1[2,3]:=m1[2,3]+m2[2,3];
 m1[3,0]:=m1[3,0]+m2[3,0];
 m1[3,1]:=m1[3,1]+m2[3,1];
 m1[3,2]:=m1[3,2]+m2[3,2];
 m1[3,3]:=m1[3,3]+m2[3,3];
end;

procedure Matrix4x4Sub(var m1:TMatrix4x4;const m2:TMatrix4x4); {$ifdef caninline}inline;{$endif}
begin
 m1[0,0]:=m1[0,0]-m2[0,0];
 m1[0,1]:=m1[0,1]-m2[0,1];
 m1[0,2]:=m1[0,2]-m2[0,2];
 m1[0,3]:=m1[0,3]-m2[0,3];
 m1[1,0]:=m1[1,0]-m2[1,0];
 m1[1,1]:=m1[1,1]-m2[1,1];
 m1[1,2]:=m1[1,2]-m2[1,2];
 m1[1,3]:=m1[1,3]-m2[1,3];
 m1[2,0]:=m1[2,0]-m2[2,0];
 m1[2,1]:=m1[2,1]-m2[2,1];
 m1[2,2]:=m1[2,2]-m2[2,2];
 m1[2,3]:=m1[2,3]-m2[2,3];
 m1[3,0]:=m1[3,0]-m2[3,0];
 m1[3,1]:=m1[3,1]-m2[3,1];
 m1[3,2]:=m1[3,2]-m2[3,2];
 m1[3,3]:=m1[3,3]-m2[3,3];
end;

procedure Matrix4x4Mul(var m1:TMatrix4x4;const m2:TMatrix4x4); overload; {$ifdef cpu386asm}register;{$endif}
{$ifdef cpu386asm}
asm
 movups xmm0,dqword ptr [m2+0]
 movups xmm1,dqword ptr [m2+16]
 movups xmm2,dqword ptr [m2+32]
 movups xmm3,dqword ptr [m2+48]

 movups xmm7,dqword ptr [m1+0]
 pshufd xmm4,xmm7,$00
 pshufd xmm5,xmm7,$55
 pshufd xmm6,xmm7,$aa
 pshufd xmm7,xmm7,$ff
 mulps xmm4,xmm0
 mulps xmm5,xmm1
 mulps xmm6,xmm2
 mulps xmm7,xmm3
 addps xmm4,xmm5
 addps xmm6,xmm7
 addps xmm4,xmm6
 movups dqword ptr [m1+0],xmm4

 movups xmm7,dqword ptr [m1+16]
 pshufd xmm4,xmm7,$00
 pshufd xmm5,xmm7,$55
 pshufd xmm6,xmm7,$aa
 pshufd xmm7,xmm7,$ff
 mulps xmm4,xmm0
 mulps xmm5,xmm1
 mulps xmm6,xmm2
 mulps xmm7,xmm3
 addps xmm4,xmm5
 addps xmm6,xmm7
 addps xmm4,xmm6
 movups dqword ptr [m1+16],xmm4

 movups xmm7,dqword ptr [m1+32]
 pshufd xmm4,xmm7,$00
 pshufd xmm5,xmm7,$55
 pshufd xmm6,xmm7,$aa
 pshufd xmm7,xmm7,$ff
 mulps xmm4,xmm0
 mulps xmm5,xmm1
 mulps xmm6,xmm2
 mulps xmm7,xmm3
 addps xmm4,xmm5
 addps xmm6,xmm7
 addps xmm4,xmm6
 movups dqword ptr [m1+32],xmm4

 movups xmm7,dqword ptr [m1+48]
 pshufd xmm4,xmm7,$00
 pshufd xmm5,xmm7,$55
 pshufd xmm6,xmm7,$aa
 pshufd xmm7,xmm7,$ff
 mulps xmm4,xmm0
 mulps xmm5,xmm1
 mulps xmm6,xmm2
 mulps xmm7,xmm3
 addps xmm4,xmm5
 addps xmm6,xmm7
 addps xmm4,xmm6
 movups dqword ptr [m1+48],xmm4

end;
{$else}
var t:TMatrix4x4;
begin
 t[0,0]:=(m1[0,0]*m2[0,0])+(m1[0,1]*m2[1,0])+(m1[0,2]*m2[2,0])+(m1[0,3]*m2[3,0]);
 t[0,1]:=(m1[0,0]*m2[0,1])+(m1[0,1]*m2[1,1])+(m1[0,2]*m2[2,1])+(m1[0,3]*m2[3,1]);
 t[0,2]:=(m1[0,0]*m2[0,2])+(m1[0,1]*m2[1,2])+(m1[0,2]*m2[2,2])+(m1[0,3]*m2[3,2]);
 t[0,3]:=(m1[0,0]*m2[0,3])+(m1[0,1]*m2[1,3])+(m1[0,2]*m2[2,3])+(m1[0,3]*m2[3,3]);
 t[1,0]:=(m1[1,0]*m2[0,0])+(m1[1,1]*m2[1,0])+(m1[1,2]*m2[2,0])+(m1[1,3]*m2[3,0]);
 t[1,1]:=(m1[1,0]*m2[0,1])+(m1[1,1]*m2[1,1])+(m1[1,2]*m2[2,1])+(m1[1,3]*m2[3,1]);
 t[1,2]:=(m1[1,0]*m2[0,2])+(m1[1,1]*m2[1,2])+(m1[1,2]*m2[2,2])+(m1[1,3]*m2[3,2]);
 t[1,3]:=(m1[1,0]*m2[0,3])+(m1[1,1]*m2[1,3])+(m1[1,2]*m2[2,3])+(m1[1,3]*m2[3,3]);
 t[2,0]:=(m1[2,0]*m2[0,0])+(m1[2,1]*m2[1,0])+(m1[2,2]*m2[2,0])+(m1[2,3]*m2[3,0]);
 t[2,1]:=(m1[2,0]*m2[0,1])+(m1[2,1]*m2[1,1])+(m1[2,2]*m2[2,1])+(m1[2,3]*m2[3,1]);
 t[2,2]:=(m1[2,0]*m2[0,2])+(m1[2,1]*m2[1,2])+(m1[2,2]*m2[2,2])+(m1[2,3]*m2[3,2]);
 t[2,3]:=(m1[2,0]*m2[0,3])+(m1[2,1]*m2[1,3])+(m1[2,2]*m2[2,3])+(m1[2,3]*m2[3,3]);
 t[3,0]:=(m1[3,0]*m2[0,0])+(m1[3,1]*m2[1,0])+(m1[3,2]*m2[2,0])+(m1[3,3]*m2[3,0]);
 t[3,1]:=(m1[3,0]*m2[0,1])+(m1[3,1]*m2[1,1])+(m1[3,2]*m2[2,1])+(m1[3,3]*m2[3,1]);
 t[3,2]:=(m1[3,0]*m2[0,2])+(m1[3,1]*m2[1,2])+(m1[3,2]*m2[2,2])+(m1[3,3]*m2[3,2]);
 t[3,3]:=(m1[3,0]*m2[0,3])+(m1[3,1]*m2[1,3])+(m1[3,2]*m2[2,3])+(m1[3,3]*m2[3,3]);
 m1:=t;
end;
{$endif}

procedure Matrix4x4Mul(var mr:TMatrix4x4;const m1,m2:TMatrix4x4); overload; {$ifdef cpu386asm}register;{$endif}
{$ifdef cpu386asm}
asm

 movups xmm0,dqword ptr [m2+0]
 movups xmm1,dqword ptr [m2+16]
 movups xmm2,dqword ptr [m2+32]
 movups xmm3,dqword ptr [m2+48]

 movups xmm7,dqword ptr [m1+0]
 pshufd xmm4,xmm7,$00
 pshufd xmm5,xmm7,$55
 pshufd xmm6,xmm7,$aa
 pshufd xmm7,xmm7,$ff
 mulps xmm4,xmm0
 mulps xmm5,xmm1
 mulps xmm6,xmm2
 mulps xmm7,xmm3
 addps xmm4,xmm5
 addps xmm6,xmm7
 addps xmm4,xmm6
 movups dqword ptr [mr+0],xmm4

 movups xmm7,dqword ptr [m1+16]
 pshufd xmm4,xmm7,$00
 pshufd xmm5,xmm7,$55
 pshufd xmm6,xmm7,$aa
 pshufd xmm7,xmm7,$ff
 mulps xmm4,xmm0
 mulps xmm5,xmm1
 mulps xmm6,xmm2
 mulps xmm7,xmm3
 addps xmm4,xmm5
 addps xmm6,xmm7
 addps xmm4,xmm6
 movups dqword ptr [mr+16],xmm4

 movups xmm7,dqword ptr [m1+32]
 pshufd xmm4,xmm7,$00
 pshufd xmm5,xmm7,$55
 pshufd xmm6,xmm7,$aa
 pshufd xmm7,xmm7,$ff
 mulps xmm4,xmm0
 mulps xmm5,xmm1
 mulps xmm6,xmm2
 mulps xmm7,xmm3
 addps xmm4,xmm5
 addps xmm6,xmm7
 addps xmm4,xmm6
 movups dqword ptr [mr+32],xmm4

 movups xmm7,dqword ptr [m1+48]
 pshufd xmm4,xmm7,$00
 pshufd xmm5,xmm7,$55
 pshufd xmm6,xmm7,$aa
 pshufd xmm7,xmm7,$ff
 mulps xmm4,xmm0
 mulps xmm5,xmm1
 mulps xmm6,xmm2
 mulps xmm7,xmm3
 addps xmm4,xmm5
 addps xmm6,xmm7
 addps xmm4,xmm6
 movups dqword ptr [mr+48],xmm4

end;
{$else}
begin
 mr[0,0]:=(m1[0,0]*m2[0,0])+(m1[0,1]*m2[1,0])+(m1[0,2]*m2[2,0])+(m1[0,3]*m2[3,0]);
 mr[0,1]:=(m1[0,0]*m2[0,1])+(m1[0,1]*m2[1,1])+(m1[0,2]*m2[2,1])+(m1[0,3]*m2[3,1]);
 mr[0,2]:=(m1[0,0]*m2[0,2])+(m1[0,1]*m2[1,2])+(m1[0,2]*m2[2,2])+(m1[0,3]*m2[3,2]);
 mr[0,3]:=(m1[0,0]*m2[0,3])+(m1[0,1]*m2[1,3])+(m1[0,2]*m2[2,3])+(m1[0,3]*m2[3,3]);
 mr[1,0]:=(m1[1,0]*m2[0,0])+(m1[1,1]*m2[1,0])+(m1[1,2]*m2[2,0])+(m1[1,3]*m2[3,0]);
 mr[1,1]:=(m1[1,0]*m2[0,1])+(m1[1,1]*m2[1,1])+(m1[1,2]*m2[2,1])+(m1[1,3]*m2[3,1]);
 mr[1,2]:=(m1[1,0]*m2[0,2])+(m1[1,1]*m2[1,2])+(m1[1,2]*m2[2,2])+(m1[1,3]*m2[3,2]);
 mr[1,3]:=(m1[1,0]*m2[0,3])+(m1[1,1]*m2[1,3])+(m1[1,2]*m2[2,3])+(m1[1,3]*m2[3,3]);
 mr[2,0]:=(m1[2,0]*m2[0,0])+(m1[2,1]*m2[1,0])+(m1[2,2]*m2[2,0])+(m1[2,3]*m2[3,0]);
 mr[2,1]:=(m1[2,0]*m2[0,1])+(m1[2,1]*m2[1,1])+(m1[2,2]*m2[2,1])+(m1[2,3]*m2[3,1]);
 mr[2,2]:=(m1[2,0]*m2[0,2])+(m1[2,1]*m2[1,2])+(m1[2,2]*m2[2,2])+(m1[2,3]*m2[3,2]);
 mr[2,3]:=(m1[2,0]*m2[0,3])+(m1[2,1]*m2[1,3])+(m1[2,2]*m2[2,3])+(m1[2,3]*m2[3,3]);
 mr[3,0]:=(m1[3,0]*m2[0,0])+(m1[3,1]*m2[1,0])+(m1[3,2]*m2[2,0])+(m1[3,3]*m2[3,0]);
 mr[3,1]:=(m1[3,0]*m2[0,1])+(m1[3,1]*m2[1,1])+(m1[3,2]*m2[2,1])+(m1[3,3]*m2[3,1]);
 mr[3,2]:=(m1[3,0]*m2[0,2])+(m1[3,1]*m2[1,2])+(m1[3,2]*m2[2,2])+(m1[3,3]*m2[3,2]);
 mr[3,3]:=(m1[3,0]*m2[0,3])+(m1[3,1]*m2[1,3])+(m1[3,2]*m2[2,3])+(m1[3,3]*m2[3,3]);
end;
{$endif}

function Matrix4x4TermAdd(const m1,m2:TMatrix4x4):TMatrix4x4; {$ifdef caninline}inline;{$endif}
begin
 result[0,0]:=m1[0,0]+m2[0,0];
 result[0,1]:=m1[0,1]+m2[0,1];
 result[0,2]:=m1[0,2]+m2[0,2];
 result[0,3]:=m1[0,3]+m2[0,3];
 result[1,0]:=m1[1,0]+m2[1,0];
 result[1,1]:=m1[1,1]+m2[1,1];
 result[1,2]:=m1[1,2]+m2[1,2];
 result[1,3]:=m1[1,3]+m2[1,3];
 result[2,0]:=m1[2,0]+m2[2,0];
 result[2,1]:=m1[2,1]+m2[2,1];
 result[2,2]:=m1[2,2]+m2[2,2];
 result[2,3]:=m1[2,3]+m2[2,3];
 result[3,0]:=m1[3,0]+m2[3,0];
 result[3,1]:=m1[3,1]+m2[3,1];
 result[3,2]:=m1[3,2]+m2[3,2];
 result[3,3]:=m1[3,3]+m2[3,3];
end;

function Matrix4x4TermSub(const m1,m2:TMatrix4x4):TMatrix4x4; {$ifdef caninline}inline;{$endif}
begin
 result[0,0]:=m1[0,0]-m2[0,0];
 result[0,1]:=m1[0,1]-m2[0,1];
 result[0,2]:=m1[0,2]-m2[0,2];
 result[0,3]:=m1[0,3]-m2[0,3];
 result[1,0]:=m1[1,0]-m2[1,0];
 result[1,1]:=m1[1,1]-m2[1,1];
 result[1,2]:=m1[1,2]-m2[1,2];
 result[1,3]:=m1[1,3]-m2[1,3];
 result[2,0]:=m1[2,0]-m2[2,0];
 result[2,1]:=m1[2,1]-m2[2,1];
 result[2,2]:=m1[2,2]-m2[2,2];
 result[2,3]:=m1[2,3]-m2[2,3];
 result[3,0]:=m1[3,0]-m2[3,0];
 result[3,1]:=m1[3,1]-m2[3,1];
 result[3,2]:=m1[3,2]-m2[3,2];
 result[3,3]:=m1[3,3]-m2[3,3];
end;

function Matrix4x4TermMul(const m1,m2:TMatrix4x4):TMatrix4x4; {$ifdef cpu386asm}register;{$endif}
{$ifdef cpu386asm}
asm

 movups xmm0,dqword ptr [m2+0]
 movups xmm1,dqword ptr [m2+16]
 movups xmm2,dqword ptr [m2+32]
 movups xmm3,dqword ptr [m2+48]

 movups xmm7,dqword ptr [m1+0]
 pshufd xmm4,xmm7,$00
 pshufd xmm5,xmm7,$55
 pshufd xmm6,xmm7,$aa
 pshufd xmm7,xmm7,$ff
 mulps xmm4,xmm0
 mulps xmm5,xmm1
 mulps xmm6,xmm2
 mulps xmm7,xmm3
 addps xmm4,xmm5
 addps xmm6,xmm7
 addps xmm4,xmm6
 movups dqword ptr [result+0],xmm4

 movups xmm7,dqword ptr [m1+16]
 pshufd xmm4,xmm7,$00
 pshufd xmm5,xmm7,$55
 pshufd xmm6,xmm7,$aa
 pshufd xmm7,xmm7,$ff
 mulps xmm4,xmm0
 mulps xmm5,xmm1
 mulps xmm6,xmm2
 mulps xmm7,xmm3
 addps xmm4,xmm5
 addps xmm6,xmm7
 addps xmm4,xmm6
 movups dqword ptr [result+16],xmm4

 movups xmm7,dqword ptr [m1+32]
 pshufd xmm4,xmm7,$00
 pshufd xmm5,xmm7,$55
 pshufd xmm6,xmm7,$aa
 pshufd xmm7,xmm7,$ff
 mulps xmm4,xmm0
 mulps xmm5,xmm1
 mulps xmm6,xmm2
 mulps xmm7,xmm3
 addps xmm4,xmm5
 addps xmm6,xmm7
 addps xmm4,xmm6
 movups dqword ptr [result+32],xmm4

 movups xmm7,dqword ptr [m1+48]
 pshufd xmm4,xmm7,$00
 pshufd xmm5,xmm7,$55
 pshufd xmm6,xmm7,$aa
 pshufd xmm7,xmm7,$ff
 mulps xmm4,xmm0
 mulps xmm5,xmm1
 mulps xmm6,xmm2
 mulps xmm7,xmm3
 addps xmm4,xmm5
 addps xmm6,xmm7
 addps xmm4,xmm6
 movups dqword ptr [result+48],xmm4

end;
{$else}
begin
 result[0,0]:=(m1[0,0]*m2[0,0])+(m1[0,1]*m2[1,0])+(m1[0,2]*m2[2,0])+(m1[0,3]*m2[3,0]);
 result[0,1]:=(m1[0,0]*m2[0,1])+(m1[0,1]*m2[1,1])+(m1[0,2]*m2[2,1])+(m1[0,3]*m2[3,1]);
 result[0,2]:=(m1[0,0]*m2[0,2])+(m1[0,1]*m2[1,2])+(m1[0,2]*m2[2,2])+(m1[0,3]*m2[3,2]);
 result[0,3]:=(m1[0,0]*m2[0,3])+(m1[0,1]*m2[1,3])+(m1[0,2]*m2[2,3])+(m1[0,3]*m2[3,3]);
 result[1,0]:=(m1[1,0]*m2[0,0])+(m1[1,1]*m2[1,0])+(m1[1,2]*m2[2,0])+(m1[1,3]*m2[3,0]);
 result[1,1]:=(m1[1,0]*m2[0,1])+(m1[1,1]*m2[1,1])+(m1[1,2]*m2[2,1])+(m1[1,3]*m2[3,1]);
 result[1,2]:=(m1[1,0]*m2[0,2])+(m1[1,1]*m2[1,2])+(m1[1,2]*m2[2,2])+(m1[1,3]*m2[3,2]);
 result[1,3]:=(m1[1,0]*m2[0,3])+(m1[1,1]*m2[1,3])+(m1[1,2]*m2[2,3])+(m1[1,3]*m2[3,3]);
 result[2,0]:=(m1[2,0]*m2[0,0])+(m1[2,1]*m2[1,0])+(m1[2,2]*m2[2,0])+(m1[2,3]*m2[3,0]);
 result[2,1]:=(m1[2,0]*m2[0,1])+(m1[2,1]*m2[1,1])+(m1[2,2]*m2[2,1])+(m1[2,3]*m2[3,1]);
 result[2,2]:=(m1[2,0]*m2[0,2])+(m1[2,1]*m2[1,2])+(m1[2,2]*m2[2,2])+(m1[2,3]*m2[3,2]);
 result[2,3]:=(m1[2,0]*m2[0,3])+(m1[2,1]*m2[1,3])+(m1[2,2]*m2[2,3])+(m1[2,3]*m2[3,3]);
 result[3,0]:=(m1[3,0]*m2[0,0])+(m1[3,1]*m2[1,0])+(m1[3,2]*m2[2,0])+(m1[3,3]*m2[3,0]);
 result[3,1]:=(m1[3,0]*m2[0,1])+(m1[3,1]*m2[1,1])+(m1[3,2]*m2[2,1])+(m1[3,3]*m2[3,1]);
 result[3,2]:=(m1[3,0]*m2[0,2])+(m1[3,1]*m2[1,2])+(m1[3,2]*m2[2,2])+(m1[3,3]*m2[3,2]);
 result[3,3]:=(m1[3,0]*m2[0,3])+(m1[3,1]*m2[1,3])+(m1[3,2]*m2[2,3])+(m1[3,3]*m2[3,3]);
end;
{$endif}

function Matrix4x4TermMulInverted(const m1,m2:TMatrix4x4):TMatrix4x4; {$ifdef caninline}inline;{$endif}
begin
 result:=Matrix4x4TermMul(m1,Matrix4x4TermInverse(m2));
end;

function Matrix4x4TermMulSimpleInverted(const m1,m2:TMatrix4x4):TMatrix4x4; {$ifdef caninline}inline;{$endif}
begin
 result:=Matrix4x4TermMul(m1,Matrix4x4TermSimpleInverse(m2));
end;

function Matrix4x4TermMulTranspose(const m1,m2:TMatrix4x4):TMatrix4x4;
begin
 result[0,0]:=(m1[0,0]*m2[0,0])+(m1[0,1]*m2[1,0])+(m1[0,2]*m2[2,0])+(m1[0,3]*m2[3,0]);
 result[1,0]:=(m1[0,0]*m2[0,1])+(m1[0,1]*m2[1,1])+(m1[0,2]*m2[2,1])+(m1[0,3]*m2[3,1]);
 result[2,0]:=(m1[0,0]*m2[0,2])+(m1[0,1]*m2[1,2])+(m1[0,2]*m2[2,2])+(m1[0,3]*m2[3,2]);
 result[3,0]:=(m1[0,0]*m2[0,3])+(m1[0,1]*m2[1,3])+(m1[0,2]*m2[2,3])+(m1[0,3]*m2[3,3]);
 result[0,1]:=(m1[1,0]*m2[0,0])+(m1[1,1]*m2[1,0])+(m1[1,2]*m2[2,0])+(m1[1,3]*m2[3,0]);
 result[1,1]:=(m1[1,0]*m2[0,1])+(m1[1,1]*m2[1,1])+(m1[1,2]*m2[2,1])+(m1[1,3]*m2[3,1]);
 result[2,1]:=(m1[1,0]*m2[0,2])+(m1[1,1]*m2[1,2])+(m1[1,2]*m2[2,2])+(m1[1,3]*m2[3,2]);
 result[3,1]:=(m1[1,0]*m2[0,3])+(m1[1,1]*m2[1,3])+(m1[1,2]*m2[2,3])+(m1[1,3]*m2[3,3]);
 result[0,2]:=(m1[2,0]*m2[0,0])+(m1[2,1]*m2[1,0])+(m1[2,2]*m2[2,0])+(m1[2,3]*m2[3,0]);
 result[1,2]:=(m1[2,0]*m2[0,1])+(m1[2,1]*m2[1,1])+(m1[2,2]*m2[2,1])+(m1[2,3]*m2[3,1]);
 result[2,2]:=(m1[2,0]*m2[0,2])+(m1[2,1]*m2[1,2])+(m1[2,2]*m2[2,2])+(m1[2,3]*m2[3,2]);
 result[3,2]:=(m1[2,0]*m2[0,3])+(m1[2,1]*m2[1,3])+(m1[2,2]*m2[2,3])+(m1[2,3]*m2[3,3]);
 result[0,3]:=(m1[3,0]*m2[0,0])+(m1[3,1]*m2[1,0])+(m1[3,2]*m2[2,0])+(m1[3,3]*m2[3,0]);
 result[1,3]:=(m1[3,0]*m2[0,1])+(m1[3,1]*m2[1,1])+(m1[3,2]*m2[2,1])+(m1[3,3]*m2[3,1]);
 result[2,3]:=(m1[3,0]*m2[0,2])+(m1[3,1]*m2[1,2])+(m1[3,2]*m2[2,2])+(m1[3,3]*m2[3,2]);
 result[3,3]:=(m1[3,0]*m2[0,3])+(m1[3,1]*m2[1,3])+(m1[3,2]*m2[2,3])+(m1[3,3]*m2[3,3]);
end;

function Matrix4x4Lerp(const a,b:TMatrix4x4;x:single):TMatrix4x4;
var ix:single;
begin
 if x<=0.0 then begin
  result:=a;
 end else if x>=1.0 then begin
  result:=b;
 end else begin
  ix:=1.0-x;
  result[0,0]:=(a[0,0]*ix)+(b[0,0]*x);
  result[0,1]:=(a[0,1]*ix)+(b[0,1]*x);
  result[0,2]:=(a[0,2]*ix)+(b[0,2]*x);
  result[0,3]:=(a[0,3]*ix)+(b[0,3]*x);
  result[1,0]:=(a[1,0]*ix)+(b[1,0]*x);
  result[1,1]:=(a[1,1]*ix)+(b[1,1]*x);
  result[1,2]:=(a[1,2]*ix)+(b[1,2]*x);
  result[1,3]:=(a[1,3]*ix)+(b[1,3]*x);
  result[2,0]:=(a[2,0]*ix)+(b[2,0]*x);
  result[2,1]:=(a[2,1]*ix)+(b[2,1]*x);
  result[2,2]:=(a[2,2]*ix)+(b[2,2]*x);
  result[2,3]:=(a[2,3]*ix)+(b[2,3]*x);
  result[3,0]:=(a[3,0]*ix)+(b[3,0]*x);
  result[3,1]:=(a[3,1]*ix)+(b[3,1]*x);
  result[3,2]:=(a[3,2]*ix)+(b[3,2]*x);
  result[3,3]:=(a[3,3]*ix)+(b[3,3]*x);
 end;
end;

function Matrix4x4Slerp(const a,b:TMatrix4x4;x:single):TMatrix4x4;
var ix:single;
    m:TMatrix3x3;
begin
 if x<=0.0 then begin
  result:=a;
 end else if x>=1.0 then begin
  result:=b;
 end else begin
  m:=QuaternionToMatrix3x3(QuaternionSlerp(QuaternionFromMatrix4x4(a),QuaternionFromMatrix4x4(b),x));
  ix:=1.0-x;
  result[0,0]:=m[0,0];
  result[0,1]:=m[0,1];
  result[0,2]:=m[0,2];
  result[0,3]:=(a[0,3]*ix)+(b[0,3]*x);
  result[1,0]:=m[1,0];
  result[1,1]:=m[1,1];
  result[1,2]:=m[1,2];
  result[1,3]:=(a[1,3]*ix)+(b[1,3]*x);
  result[2,0]:=m[2,0];
  result[2,1]:=m[2,1];
  result[2,2]:=m[2,2];
  result[2,3]:=(a[2,3]*ix)+(b[2,3]*x);
  result[3,0]:=(a[3,0]*ix)+(b[3,0]*x);
  result[3,1]:=(a[3,1]*ix)+(b[3,1]*x);
  result[3,2]:=(a[3,2]*ix)+(b[3,2]*x);
  result[3,3]:=(a[3,3]*ix)+(b[3,3]*x);
 end;
end;

procedure Matrix4x4ScalarMul(var m:TMatrix4x4;s:single); {$ifdef caninline}inline;{$endif}
begin
 m[0,0]:=m[0,0]*s;
 m[0,1]:=m[0,1]*s;
 m[0,2]:=m[0,2]*s;
 m[0,3]:=m[0,3]*s;
 m[1,0]:=m[1,0]*s;
 m[1,1]:=m[1,1]*s;
 m[1,2]:=m[1,2]*s;
 m[1,3]:=m[1,3]*s;
 m[2,0]:=m[2,0]*s;
 m[2,1]:=m[2,1]*s;
 m[2,2]:=m[2,2]*s;
 m[2,3]:=m[2,3]*s;
 m[3,0]:=m[3,0]*s;
 m[3,1]:=m[3,1]*s;
 m[3,2]:=m[3,2]*s;
 m[3,3]:=m[3,3]*s;
end;

procedure Matrix4x4Transpose(var m:TMatrix4x4);
{$ifdef cpu386asm}
asm
 movups xmm0,dqword ptr [m+0]
 movups xmm4,dqword ptr [m+16]
 movups xmm2,dqword ptr [m+32]
 movups xmm5,dqword ptr [m+48]
 movaps xmm1,xmm0
 movaps xmm3,xmm2
 unpcklps xmm0,xmm4
 unpckhps xmm1,xmm4
 unpcklps xmm2,xmm5
 unpckhps xmm3,xmm5
 movaps xmm4,xmm0
 movaps xmm6,xmm1
 shufps xmm0,xmm2,$44 // 01000100b
 shufps xmm4,xmm2,$ee // 11101110b
 shufps xmm1,xmm3,$44 // 01000100b
 shufps xmm6,xmm3,$ee // 11101110b
 movups dqword ptr [m+0],xmm0
 movups dqword ptr [m+16],xmm4
 movups dqword ptr [m+32],xmm1
 movups dqword ptr [m+48],xmm6
end;
{$else}
var mt:TMatrix4x4;
begin
 mt[0,0]:=m[0,0];
 mt[0,1]:=m[1,0];
 mt[0,2]:=m[2,0];
 mt[0,3]:=m[3,0];
 mt[1,0]:=m[0,1];
 mt[1,1]:=m[1,1];
 mt[1,2]:=m[2,1];
 mt[1,3]:=m[3,1];
 mt[2,0]:=m[0,2];
 mt[2,1]:=m[1,2];
 mt[2,2]:=m[2,2];
 mt[2,3]:=m[3,2];
 mt[3,0]:=m[0,3];
 mt[3,1]:=m[1,3];
 mt[3,2]:=m[2,3];
 mt[3,3]:=m[3,3];
 m:=mt;
end;
{$endif}

function Matrix4x4TermTranspose(const m:TMatrix4x4):TMatrix4x4;
{$ifdef cpu386asm}
asm
 movups xmm0,dqword ptr [m+0]
 movups xmm4,dqword ptr [m+16]
 movups xmm2,dqword ptr [m+32]
 movups xmm5,dqword ptr [m+48]
 movaps xmm1,xmm0
 movaps xmm3,xmm2
 unpcklps xmm0,xmm4
 unpckhps xmm1,xmm4
 unpcklps xmm2,xmm5
 unpckhps xmm3,xmm5
 movaps xmm4,xmm0
 movaps xmm6,xmm1
 shufps xmm0,xmm2,$44 // 01000100b
 shufps xmm4,xmm2,$ee // 11101110b
 shufps xmm1,xmm3,$44 // 01000100b
 shufps xmm6,xmm3,$ee // 11101110b
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm4
 movups dqword ptr [result+32],xmm1
 movups dqword ptr [result+48],xmm6
end;
{$else}
begin
 result[0,0]:=m[0,0];
 result[0,1]:=m[1,0];
 result[0,2]:=m[2,0];
 result[0,3]:=m[3,0];
 result[1,0]:=m[0,1];
 result[1,1]:=m[1,1];
 result[1,2]:=m[2,1];
 result[1,3]:=m[3,1];
 result[2,0]:=m[0,2];
 result[2,1]:=m[1,2];
 result[2,2]:=m[2,2];
 result[2,3]:=m[3,2];
 result[3,0]:=m[0,3];
 result[3,1]:=m[1,3];
 result[3,2]:=m[2,3];
 result[3,3]:=m[3,3];
end;
{$endif}

function Matrix4x4Determinant(const m:TMatrix4x4):single;
{$ifdef cpu386asm}
asm
 movups xmm0,dqword ptr [m+32]
 movups xmm1,dqword ptr [m+48]
 movups xmm2,dqword ptr [m+16]
 movaps xmm3,xmm0
 movaps xmm4,xmm0
 movaps xmm6,xmm1
 movaps xmm7,xmm2
 shufps xmm0,xmm0,$1b // 00011011b
 shufps xmm1,xmm1,$b1 // 10110001b
 shufps xmm2,xmm2,$4e // 01001110b
 shufps xmm7,xmm7,$39 // 00111001b
 mulps xmm0,xmm1
 shufps xmm3,xmm3,$7d // 01111101b
 shufps xmm6,xmm6,$0a // 00001010b
 movaps xmm5,xmm0
 shufps xmm0,xmm0,$4e // 01001110b
 shufps xmm4,xmm4,$0a // 00001010b
 shufps xmm1,xmm1,$28 // 00101000b
 subps xmm5,xmm0
 mulps xmm3,xmm6
 mulps xmm4,xmm1
 mulps xmm5,xmm2
 shufps xmm2,xmm2,$39 // 00111001b
 subps xmm3,xmm4
 movaps xmm0,xmm3
 shufps xmm0,xmm0,$39 // 00111001b
 mulps xmm3,xmm2
 mulps xmm0,xmm7
 addps xmm5,xmm3
 subps xmm5,xmm0
 movups xmm6,dqword ptr [m+0]
 mulps xmm5,xmm6
 movhlps xmm7,xmm5
 addps xmm5,xmm7
 movaps xmm6,xmm5
 shufps xmm6,xmm6,$01
 addss xmm5,xmm6
 movss dword ptr [result],xmm5
end;
{$else}
var inv:array[0..15] of single;
begin
 inv[0]:=(((m[1,1]*m[2,2]*m[3,3])-(m[1,1]*m[2,3]*m[3,2]))-(m[2,1]*m[1,2]*m[3,3])+(m[2,1]*m[1,3]*m[3,2])+(m[3,1]*m[1,2]*m[2,3]))-(m[3,1]*m[1,3]*m[2,2]);
 inv[4]:=((((-(m[1,0]*m[2,2]*m[3,3]))+(m[1,0]*m[2,3]*m[3,2])+(m[2,0]*m[1,2]*m[3,3]))-(m[2,0]*m[1,3]*m[3,2]))-(m[3,0]*m[1,2]*m[2,3]))+(m[3,0]*m[1,3]*m[2,2]);
 inv[8]:=((((m[1,0]*m[2,1]*m[3,3])-(m[1,0]*m[2,3]*m[3,1]))-(m[2,0]*m[1,1]*m[3,3]))+(m[2,0]*m[1,3]*m[3,1])+(m[3,0]*m[1,1]*m[2,3]))-(m[3,0]*m[1,3]*m[2,1]);
 inv[12]:=((((-(m[1,0]*m[2,1]*m[3,2]))+(m[1,0]*m[2,2]*m[3,1])+(m[2,0]*m[1,1]*m[3,2]))-(m[2,0]*m[1,2]*m[3,1]))-(m[3,0]*m[1,1]*m[2,2]))+(m[3,0]*m[1,2]*m[2,1]);
 inv[1]:=((((-(m[0,1]*m[2,2]*m[3,3]))+(m[0,1]*m[2,3]*m[3,2])+(m[2,1]*m[0,2]*m[3,3]))-(m[2,1]*m[0,3]*m[3,2]))-(m[3,1]*m[0,2]*m[2,3]))+(m[3,1]*m[0,3]*m[2,2]);
 inv[5]:=(((m[0,0]*m[2,2]*m[3,3])-(m[0,0]*m[2,3]*m[3,2]))-(m[2,0]*m[0,2]*m[3,3])+(m[2,0]*m[0,3]*m[3,2])+(m[3,0]*m[0,2]*m[2,3]))-(m[3,0]*m[0,3]*m[2,2]);
 inv[9]:=((((-(m[0,0]*m[2,1]*m[3,3]))+(m[0,0]*m[2,3]*m[3,1])+(m[2,0]*m[0,1]*m[3,3]))-(m[2,0]*m[0,3]*m[3,1]))-(m[3,0]*m[0,1]*m[2,3]))+(m[3,0]*m[0,3]*m[2,1]);
 inv[13]:=((((m[0,0]*m[2,1]*m[3,2])-(m[0,0]*m[2,2]*m[3,1]))-(m[2,0]*m[0,1]*m[3,2]))+(m[2,0]*m[0,2]*m[3,1])+(m[3,0]*m[0,1]*m[2,2]))-(m[3,0]*m[0,2]*m[2,1]);
 inv[2]:=((((m[0,1]*m[1,2]*m[3,3])-(m[0,1]*m[1,3]*m[3,2]))-(m[1,1]*m[0,2]*m[3,3]))+(m[1,1]*m[0,3]*m[3,2])+(m[3,1]*m[0,2]*m[1,3]))-(m[3,1]*m[0,3]*m[1,2]);
 inv[6]:=((((-(m[0,0]*m[1,2]*m[3,3]))+(m[0,0]*m[1,3]*m[3,2])+(m[1,0]*m[0,2]*m[3,3]))-(m[1,0]*m[0,3]*m[3,2]))-(m[3,0]*m[0,2]*m[1,3]))+(m[3,0]*m[0,3]*m[1,2]);
 inv[10]:=((((m[0,0]*m[1,1]*m[3,3])-(m[0,0]*m[1,3]*m[3,1]))-(m[1,0]*m[0,1]*m[3,3]))+(m[1,0]*m[0,3]*m[3,1])+(m[3,0]*m[0,1]*m[1,3]))-(m[3,0]*m[0,3]*m[1,1]);
 inv[14]:=((((-(m[0,0]*m[1,1]*m[3,2]))+(m[0,0]*m[1,2]*m[3,1])+(m[1,0]*m[0,1]*m[3,2]))-(m[1,0]*m[0,2]*m[3,1]))-(m[3,0]*m[0,1]*m[1,2]))+(m[3,0]*m[0,2]*m[1,1]);
 inv[3]:=((((-(m[0,1]*m[1,2]*m[2,3]))+(m[0,1]*m[1,3]*m[2,2])+(m[1,1]*m[0,2]*m[2,3]))-(m[1,1]*m[0,3]*m[2,2]))-(m[2,1]*m[0,2]*m[1,3]))+(m[2,1]*m[0,3]*m[1,2]);
 inv[7]:=((((m[0,0]*m[1,2]*m[2,3])-(m[0,0]*m[1,3]*m[2,2]))-(m[1,0]*m[0,2]*m[2,3]))+(m[1,0]*m[0,3]*m[2,2])+(m[2,0]*m[0,2]*m[1,3]))-(m[2,0]*m[0,3]*m[1,2]);
 inv[11]:=((((-(m[0,0]*m[1,1]*m[2,3]))+(m[0,0]*m[1,3]*m[2,1])+(m[1,0]*m[0,1]*m[2,3]))-(m[1,0]*m[0,3]*m[2,1]))-(m[2,0]*m[0,1]*m[1,3]))+(m[2,0]*m[0,3]*m[1,1]);
 inv[15]:=((((m[0,0]*m[1,1]*m[2,2])-(m[0,0]*m[1,2]*m[2,1]))-(m[1,0]*m[0,1]*m[2,2]))+(m[1,0]*m[0,2]*m[2,1])+(m[2,0]*m[0,1]*m[1,2]))-(m[2,0]*m[0,2]*m[1,1]);
 result:=(m[0,0]*inv[0])+(m[0,1]*inv[4])+(m[0,2]*inv[8])+(m[0,3]*inv[12]);
end;
{$endif}

(*
var Determinant,i:single;
    SubMatrix3x3:TMatrix3x3;
    Counter:longint;{}
begin
 result:=0;
 i:=1;
 for Counter:=0 to 3 do begin
  SubMatrix3x3:=Matrix4x4GetSubMatrix3x3(m,Counter,0);
  Determinant:=Matrix3x3Determinant(SubMatrix3x3);
  result:=result+(m[Counter,0]*(Determinant*i));
  i:=-i;
 end;{}
{result:=(m[0,0]*m[1,1]*m[2,2])+
         (m[1,0]*m[2,1]*m[0,2])+
         (m[2,0]*m[0,1]*m[1,2])-
         (m[2,0]*m[1,1]*m[0,2])-
         (m[1,0]*m[0,1]*m[2,2])-
         (m[0,0]*m[2,1]*m[1,2]);{}
end;*)

function Matrix4x4Angles(const m:TMatrix4x4):TVector3;
var XAngle,YAngle,ZAngle,c,d,tx,ty:single;
begin
 d:=ArcSin(m[2,0]);
 YAngle:=d;
 c:=cos(YAngle);
 if abs(c)>0.005 then begin
  tx:=m[2,2]/c;
  ty:=-m[2,1]/c;
  XAngle:=ArcTan2(ty,tx);
  tx:=m[0,0]/c;
  ty:=-m[1,0]/c;
  ZAngle:=ArcTan2(ty,tx);
 end else begin
  XAngle:=0;
  tx:=m[1,1];
  ty:=m[0,1];
  ZAngle:=ArcTan2(ty,tx);
 end;
 if XAngle<0 then begin
  XAngle:=XAngle+(2*PI);
 end;
 if YAngle<0 then begin
  YAngle:=YAngle+(2*PI);
 end;
 if ZAngle<0 then begin
  ZAngle:=ZAngle+(2*PI);
 end;
 result.Pitch:=XAngle;
 result.Yaw:=ZAngle;
 result.Roll:=YAngle;
end;

procedure Matrix4x4SetColumn(var m:TMatrix4x4;const c:longint;const v:TVector4); {$ifdef caninline}inline;{$endif}
begin
 m[c,0]:=v.x;
 m[c,1]:=v.y;
 m[c,2]:=v.z;
 m[c,3]:=v.w;
end;

function Matrix4x4GetColumn(const m:TMatrix4x4;const c:longint):TVector4; {$ifdef caninline}inline;{$endif}
begin
 result.x:=m[c,0];
 result.y:=m[c,1];
 result.z:=m[c,2];
 result.w:=m[c,3];
end;

procedure Matrix4x4SetRow(var m:TMatrix4x4;const r:longint;const v:TVector4); {$ifdef caninline}inline;{$endif}
begin
 m[0,r]:=v.x;
 m[1,r]:=v.y;
 m[2,r]:=v.z;
 m[3,r]:=v.w;
end;

function Matrix4x4GetRow(const m:TMatrix4x4;const r:longint):TVector4; {$ifdef caninline}inline;{$endif}
begin
 result.x:=m[0,r];
 result.y:=m[1,r];
 result.z:=m[2,r];
 result.w:=m[3,r];
end;

function Matrix4x4Compare(const m1,m2:TMatrix4x4):boolean;
var r,c:longint;
begin
 result:=true;
 for r:=0 to 3 do begin
  for c:=0 to 3 do begin
   if abs(m1[r,c]-m2[r,c])>EPSILON then begin
    result:=false;
    exit;
   end;
  end;
 end;
end;

procedure Matrix4x4Reflect(var mr:TMatrix4x4;Plane:TPlane);
begin
 PlaneNormalize(Plane);
 mr[0,0]:=1.0-(2.0*(Plane.a*Plane.a));
 mr[0,1]:=-(2.0*(Plane.a*Plane.b));
 mr[0,2]:=-(2.0*(Plane.a*Plane.c));
 mr[0,3]:=0.0;
 mr[1,0]:=-(2.0*(Plane.a*Plane.b));
 mr[1,1]:=1.0-(2.0*(Plane.b*Plane.b));
 mr[1,2]:=-(2.0*(Plane.b*Plane.c));
 mr[1,3]:=0.0;
 mr[2,0]:=-(2.0*(Plane.c*Plane.a));
 mr[2,1]:=-(2.0*(Plane.c*Plane.b));
 mr[2,2]:=1.0-(2.0*(Plane.c*Plane.c));
 mr[2,3]:=0.0;
 mr[3,0]:=-(2.0*(Plane.d*Plane.a));
 mr[3,1]:=-(2.0*(Plane.d*Plane.b));
 mr[3,2]:=-(2.0*(Plane.d*Plane.c));
 mr[3,3]:=1.0;
end;

function Matrix4x4TermReflect(Plane:TPlane):TMatrix4x4;
begin
 PlaneNormalize(Plane);
 result[0,0]:=1.0-(2.0*(Plane.a*Plane.a));
 result[0,1]:=-(2.0*(Plane.a*Plane.b));
 result[0,2]:=-(2.0*(Plane.a*Plane.c));
 result[0,3]:=0.0;
 result[1,0]:=-(2.0*(Plane.a*Plane.b));
 result[1,1]:=1.0-(2.0*(Plane.b*Plane.b));
 result[1,2]:=-(2.0*(Plane.b*Plane.c));
 result[1,3]:=0.0;
 result[2,0]:=-(2.0*(Plane.c*Plane.a));
 result[2,1]:=-(2.0*(Plane.c*Plane.b));
 result[2,2]:=1.0-(2.0*(Plane.c*Plane.c));
 result[2,3]:=0.0;
 result[3,0]:=-(2.0*(Plane.d*Plane.a));
 result[3,1]:=-(2.0*(Plane.d*Plane.b));
 result[3,2]:=-(2.0*(Plane.d*Plane.c));
 result[3,3]:=1.0;
end;

function Matrix4x4SimpleInverse(var mr:TMatrix4x4;const ma:TMatrix4x4):boolean; {$ifdef caninline}inline;{$endif}
begin
 mr[0,0]:=ma[0,0];
 mr[0,1]:=ma[1,0];
 mr[0,2]:=ma[2,0];
 mr[0,3]:=ma[0,3];
 mr[1,0]:=ma[0,1];
 mr[1,1]:=ma[1,1];
 mr[1,2]:=ma[2,1];
 mr[1,3]:=ma[1,3];
 mr[2,0]:=ma[0,2];
 mr[2,1]:=ma[1,2];
 mr[2,2]:=ma[2,2];
 mr[2,3]:=ma[2,3];
 mr[3,0]:=-Vector3Dot(PVector3(pointer(@ma[3,0]))^,Vector3(ma[0,0],ma[0,1],ma[0,2]));
 mr[3,1]:=-Vector3Dot(PVector3(pointer(@ma[3,0]))^,Vector3(ma[1,0],ma[1,1],ma[1,2]));
 mr[3,2]:=-Vector3Dot(PVector3(pointer(@ma[3,0]))^,Vector3(ma[2,0],ma[2,1],ma[2,2]));
 mr[3,3]:=ma[3,3];
 result:=true;
end;

function Matrix4x4TermSimpleInverse(const ma:TMatrix4x4):TMatrix4x4; {$ifdef caninline}inline;{$endif}
begin
 result[0,0]:=ma[0,0];
 result[0,1]:=ma[1,0];
 result[0,2]:=ma[2,0];
 result[0,3]:=ma[0,3];
 result[1,0]:=ma[0,1];
 result[1,1]:=ma[1,1];
 result[1,2]:=ma[2,1];
 result[1,3]:=ma[1,3];
 result[2,0]:=ma[0,2];
 result[2,1]:=ma[1,2];
 result[2,2]:=ma[2,2];
 result[2,3]:=ma[2,3];
 result[3,0]:=-Vector3Dot(PVector3(pointer(@ma[3,0]))^,Vector3(ma[0,0],ma[0,1],ma[0,2]));
 result[3,1]:=-Vector3Dot(PVector3(pointer(@ma[3,0]))^,Vector3(ma[1,0],ma[1,1],ma[1,2]));
 result[3,2]:=-Vector3Dot(PVector3(pointer(@ma[3,0]))^,Vector3(ma[2,0],ma[2,1],ma[2,2]));
 result[3,3]:=ma[3,3];
end;

function Matrix4x4Inverse(var mr:TMatrix4x4;const ma:TMatrix4x4):boolean;
{$ifdef cpu386asm}
asm
 mov ecx,esp
 and esp,$fffffff0
 sub esp,$b0
 movlps xmm2,qword ptr [ma+8]
 movlps xmm4,qword ptr [ma+40]
 movhps xmm2,qword ptr [ma+24]
 movhps xmm4,qword ptr [ma+56]
 movlps xmm3,qword ptr [ma+32]
 movlps xmm1,qword ptr [ma]
 movhps xmm3,qword ptr [ma+48]
 movhps xmm1,qword ptr [ma+16]
 movaps xmm5,xmm2
 shufps xmm5,xmm4,$88
 shufps xmm4,xmm2,$dd
 movaps xmm2,xmm4
 mulps xmm2,xmm5
 shufps xmm2,xmm2,$b1
 movaps xmm6,xmm2
 shufps xmm6,xmm6,$4e
 movaps xmm7,xmm3
 shufps xmm3,xmm1,$dd
 shufps xmm1,xmm7,$88
 movaps xmm7,xmm3
 mulps xmm3,xmm6
 mulps xmm6,xmm1
 movaps xmm0,xmm6
 movaps xmm6,xmm7
 mulps xmm7,xmm2
 mulps xmm2,xmm1
 subps xmm3,xmm7
 movaps xmm7,xmm6
 mulps xmm7,xmm5
 shufps xmm5,xmm5,$4e
 shufps xmm7,xmm7,$b1
 movaps dqword ptr [esp+16],xmm2
 movaps xmm2,xmm4
 mulps xmm2,xmm7
 addps xmm2,xmm3
 movaps xmm3,xmm7
 shufps xmm7,xmm7,$4e
 mulps xmm3,xmm1
 movaps dqword ptr [esp+32],xmm3
 movaps xmm3,xmm4
 mulps xmm3,xmm7
 mulps xmm7,xmm1
 subps xmm2,xmm3
 movaps xmm3,xmm6
 shufps xmm3,xmm3,$4e
 mulps xmm3,xmm4
 shufps xmm3,xmm3,$b1
 movaps dqword ptr [esp+48],xmm7
 movaps xmm7,xmm5
 mulps xmm5,xmm3
 addps xmm5,xmm2
 movaps xmm2,xmm3
 shufps xmm3,xmm3,$4e
 mulps xmm2,xmm1
 movaps dqword ptr [esp+64],xmm4
 movaps xmm4,xmm7
 mulps xmm7,xmm3
 mulps xmm3,xmm1
 subps xmm5,xmm7
 subps xmm3,xmm2
 movaps xmm2,xmm1
 mulps xmm1,xmm5
 shufps xmm3,xmm3,$4e
 movaps xmm7,xmm1
 shufps xmm1,xmm1,$4e
 movaps dqword ptr [esp],xmm5
 addps xmm1,xmm7
 movaps xmm5,xmm1
 shufps xmm1,xmm1,$b1
 addss xmm1,xmm5
 movaps xmm5,xmm6
 mulps xmm5,xmm2
 shufps xmm5,xmm5,$b1
 movaps xmm7,xmm5
 shufps xmm5,xmm5,$4e
 movaps dqword ptr [esp+80],xmm4
 movaps xmm4,dqword ptr [esp+64]
 movaps dqword ptr [esp+64],xmm6
 movaps xmm6,xmm4
 mulps xmm6,xmm7
 addps xmm6,xmm3
 movaps xmm3,xmm4
 mulps xmm3,xmm5
 subps xmm3,xmm6
 movaps xmm6,xmm4
 mulps xmm6,xmm2
 shufps xmm6,xmm6,$b1
 movaps dqword ptr [esp+112],xmm5
 movaps xmm5,dqword ptr [esp+64]
 movaps dqword ptr [esp+128],xmm7
 movaps xmm7,xmm6
 mulps xmm7,xmm5
 addps xmm7,xmm3
 movaps xmm3,xmm6
 shufps xmm3,xmm3,$4e
 movaps dqword ptr [esp+144],xmm4
 movaps xmm4,xmm5
 mulps xmm5,xmm3
 movaps dqword ptr [esp+160],xmm4
 movaps xmm4,xmm6
 movaps xmm6,xmm7
 subps xmm6,xmm5
 movaps xmm5,xmm0
 movaps xmm7,dqword ptr [esp+16]
 subps xmm5,xmm7
 shufps xmm5,xmm5,$4e
 movaps xmm7,dqword ptr [esp+80]
 mulps xmm4,xmm7
 mulps xmm3,xmm7
 subps xmm5,xmm4
 mulps xmm2,xmm7
 addps xmm3,xmm5
 shufps xmm2,xmm2,$b1
 movaps xmm4,xmm2
 shufps xmm4,xmm4,$4e
 movaps xmm5,dqword ptr [esp+144]
 movaps xmm0,xmm6
 movaps xmm6,xmm5
 mulps xmm5,xmm2
 mulps xmm6,xmm4
 addps xmm5,xmm3
 movaps xmm3,xmm4
 movaps xmm4,xmm5
 subps xmm4,xmm6
 movaps xmm5,dqword ptr [esp+48]
 movaps xmm6,dqword ptr [esp+32]
 subps xmm5,xmm6
 shufps xmm5,xmm5,$4e
 movaps xmm6,[esp+128]
 mulps xmm6,xmm7
 subps xmm6,xmm5
 movaps xmm5,dqword ptr [esp+112]
 mulps xmm7,xmm5
 subps xmm6,xmm7
 movaps xmm5,dqword ptr [esp+160]
 mulps xmm2,xmm5
 mulps xmm5,xmm3
 subps xmm6,xmm2
 movaps xmm2,xmm5
 addps xmm2,xmm6
 movaps xmm6,xmm0
 movaps xmm0,xmm1
 movaps xmm1,dqword ptr [esp]
 movaps xmm3,xmm0
 rcpss xmm5,xmm0
 mulss xmm0,xmm5
 mulss xmm0,xmm5
 addss xmm5,xmm5
 subss xmm5,xmm0
 movaps xmm0,xmm5
 addss xmm5,xmm5
 mulss xmm0,xmm0
 mulss xmm3,xmm0
 subss xmm5,xmm3
 shufps xmm5,xmm5,$00
 mulps xmm1,xmm5
 mulps xmm4,xmm5
 mulps xmm6,xmm5
 mulps xmm5,xmm2
 movups dqword ptr [mr+0],xmm1
 movups dqword ptr [mr+16],xmm4
 movups dqword ptr [mr+32],xmm6
 movups dqword ptr [mr+48],xmm5
 mov esp,ecx
 mov eax,1
end;
{$else}
var inv:array[0..15] of single;
    det:single;
begin
 inv[0]:=(((ma[1,1]*ma[2,2]*ma[3,3])-(ma[1,1]*ma[2,3]*ma[3,2]))-(ma[2,1]*ma[1,2]*ma[3,3])+(ma[2,1]*ma[1,3]*ma[3,2])+(ma[3,1]*ma[1,2]*ma[2,3]))-(ma[3,1]*ma[1,3]*ma[2,2]);
 inv[4]:=((((-(ma[1,0]*ma[2,2]*ma[3,3]))+(ma[1,0]*ma[2,3]*ma[3,2])+(ma[2,0]*ma[1,2]*ma[3,3]))-(ma[2,0]*ma[1,3]*ma[3,2]))-(ma[3,0]*ma[1,2]*ma[2,3]))+(ma[3,0]*ma[1,3]*ma[2,2]);
 inv[8]:=((((ma[1,0]*ma[2,1]*ma[3,3])-(ma[1,0]*ma[2,3]*ma[3,1]))-(ma[2,0]*ma[1,1]*ma[3,3]))+(ma[2,0]*ma[1,3]*ma[3,1])+(ma[3,0]*ma[1,1]*ma[2,3]))-(ma[3,0]*ma[1,3]*ma[2,1]);
 inv[12]:=((((-(ma[1,0]*ma[2,1]*ma[3,2]))+(ma[1,0]*ma[2,2]*ma[3,1])+(ma[2,0]*ma[1,1]*ma[3,2]))-(ma[2,0]*ma[1,2]*ma[3,1]))-(ma[3,0]*ma[1,1]*ma[2,2]))+(ma[3,0]*ma[1,2]*ma[2,1]);
 inv[1]:=((((-(ma[0,1]*ma[2,2]*ma[3,3]))+(ma[0,1]*ma[2,3]*ma[3,2])+(ma[2,1]*ma[0,2]*ma[3,3]))-(ma[2,1]*ma[0,3]*ma[3,2]))-(ma[3,1]*ma[0,2]*ma[2,3]))+(ma[3,1]*ma[0,3]*ma[2,2]);
 inv[5]:=(((ma[0,0]*ma[2,2]*ma[3,3])-(ma[0,0]*ma[2,3]*ma[3,2]))-(ma[2,0]*ma[0,2]*ma[3,3])+(ma[2,0]*ma[0,3]*ma[3,2])+(ma[3,0]*ma[0,2]*ma[2,3]))-(ma[3,0]*ma[0,3]*ma[2,2]);
 inv[9]:=((((-(ma[0,0]*ma[2,1]*ma[3,3]))+(ma[0,0]*ma[2,3]*ma[3,1])+(ma[2,0]*ma[0,1]*ma[3,3]))-(ma[2,0]*ma[0,3]*ma[3,1]))-(ma[3,0]*ma[0,1]*ma[2,3]))+(ma[3,0]*ma[0,3]*ma[2,1]);
 inv[13]:=((((ma[0,0]*ma[2,1]*ma[3,2])-(ma[0,0]*ma[2,2]*ma[3,1]))-(ma[2,0]*ma[0,1]*ma[3,2]))+(ma[2,0]*ma[0,2]*ma[3,1])+(ma[3,0]*ma[0,1]*ma[2,2]))-(ma[3,0]*ma[0,2]*ma[2,1]);
 inv[2]:=((((ma[0,1]*ma[1,2]*ma[3,3])-(ma[0,1]*ma[1,3]*ma[3,2]))-(ma[1,1]*ma[0,2]*ma[3,3]))+(ma[1,1]*ma[0,3]*ma[3,2])+(ma[3,1]*ma[0,2]*ma[1,3]))-(ma[3,1]*ma[0,3]*ma[1,2]);
 inv[6]:=((((-(ma[0,0]*ma[1,2]*ma[3,3]))+(ma[0,0]*ma[1,3]*ma[3,2])+(ma[1,0]*ma[0,2]*ma[3,3]))-(ma[1,0]*ma[0,3]*ma[3,2]))-(ma[3,0]*ma[0,2]*ma[1,3]))+(ma[3,0]*ma[0,3]*ma[1,2]);
 inv[10]:=((((ma[0,0]*ma[1,1]*ma[3,3])-(ma[0,0]*ma[1,3]*ma[3,1]))-(ma[1,0]*ma[0,1]*ma[3,3]))+(ma[1,0]*ma[0,3]*ma[3,1])+(ma[3,0]*ma[0,1]*ma[1,3]))-(ma[3,0]*ma[0,3]*ma[1,1]);
 inv[14]:=((((-(ma[0,0]*ma[1,1]*ma[3,2]))+(ma[0,0]*ma[1,2]*ma[3,1])+(ma[1,0]*ma[0,1]*ma[3,2]))-(ma[1,0]*ma[0,2]*ma[3,1]))-(ma[3,0]*ma[0,1]*ma[1,2]))+(ma[3,0]*ma[0,2]*ma[1,1]);
 inv[3]:=((((-(ma[0,1]*ma[1,2]*ma[2,3]))+(ma[0,1]*ma[1,3]*ma[2,2])+(ma[1,1]*ma[0,2]*ma[2,3]))-(ma[1,1]*ma[0,3]*ma[2,2]))-(ma[2,1]*ma[0,2]*ma[1,3]))+(ma[2,1]*ma[0,3]*ma[1,2]);
 inv[7]:=((((ma[0,0]*ma[1,2]*ma[2,3])-(ma[0,0]*ma[1,3]*ma[2,2]))-(ma[1,0]*ma[0,2]*ma[2,3]))+(ma[1,0]*ma[0,3]*ma[2,2])+(ma[2,0]*ma[0,2]*ma[1,3]))-(ma[2,0]*ma[0,3]*ma[1,2]);
 inv[11]:=((((-(ma[0,0]*ma[1,1]*ma[2,3]))+(ma[0,0]*ma[1,3]*ma[2,1])+(ma[1,0]*ma[0,1]*ma[2,3]))-(ma[1,0]*ma[0,3]*ma[2,1]))-(ma[2,0]*ma[0,1]*ma[1,3]))+(ma[2,0]*ma[0,3]*ma[1,1]);
 inv[15]:=((((ma[0,0]*ma[1,1]*ma[2,2])-(ma[0,0]*ma[1,2]*ma[2,1]))-(ma[1,0]*ma[0,1]*ma[2,2]))+(ma[1,0]*ma[0,2]*ma[2,1])+(ma[2,0]*ma[0,1]*ma[1,2]))-(ma[2,0]*ma[0,2]*ma[1,1]);
 det:=(ma[0,0]*inv[0])+(ma[0,1]*inv[4])+(ma[0,2]*inv[8])+(ma[0,3]*inv[12]);
 if abs(det)>EPSILON then begin
  det:=1.0/det;
  mr[0,0]:=inv[0]*det;
  mr[0,1]:=inv[1]*det;
  mr[0,2]:=inv[2]*det;
  mr[0,3]:=inv[3]*det;
  mr[1,0]:=inv[4]*det;
  mr[1,1]:=inv[5]*det;
  mr[1,2]:=inv[6]*det;
  mr[1,3]:=inv[7]*det;
  mr[2,0]:=inv[8]*det;
  mr[2,1]:=inv[9]*det;
  mr[2,2]:=inv[10]*det;
  mr[2,3]:=inv[11]*det;
  mr[3,0]:=inv[12]*det;
  mr[3,1]:=inv[13]*det;
  mr[3,2]:=inv[14]*det;
  mr[3,3]:=inv[15]*det;
  result:=true;
 end else begin
  result:=false;
 end;
end;
{$endif}

function Matrix4x4TermInverse(const ma:TMatrix4x4):TMatrix4x4;
{$ifdef cpu386asm}
asm
 mov ecx,esp
 and esp,$fffffff0
 sub esp,$b0
 movlps xmm2,qword ptr [ma+8]
 movlps xmm4,qword ptr [ma+40]
 movhps xmm2,qword ptr [ma+24]
 movhps xmm4,qword ptr [ma+56]
 movlps xmm3,qword ptr [ma+32]
 movlps xmm1,qword ptr [ma]
 movhps xmm3,qword ptr [ma+48]
 movhps xmm1,qword ptr [ma+16]
 movaps xmm5,xmm2
 shufps xmm5,xmm4,$88
 shufps xmm4,xmm2,$dd
 movaps xmm2,xmm4
 mulps xmm2,xmm5
 shufps xmm2,xmm2,$b1
 movaps xmm6,xmm2
 shufps xmm6,xmm6,$4e
 movaps xmm7,xmm3
 shufps xmm3,xmm1,$dd
 shufps xmm1,xmm7,$88
 movaps xmm7,xmm3
 mulps xmm3,xmm6
 mulps xmm6,xmm1
 movaps xmm0,xmm6
 movaps xmm6,xmm7
 mulps xmm7,xmm2
 mulps xmm2,xmm1
 subps xmm3,xmm7
 movaps xmm7,xmm6
 mulps xmm7,xmm5
 shufps xmm5,xmm5,$4e
 shufps xmm7,xmm7,$b1
 movaps dqword ptr [esp+16],xmm2
 movaps xmm2,xmm4
 mulps xmm2,xmm7
 addps xmm2,xmm3
 movaps xmm3,xmm7
 shufps xmm7,xmm7,$4e
 mulps xmm3,xmm1
 movaps dqword ptr [esp+32],xmm3
 movaps xmm3,xmm4
 mulps xmm3,xmm7
 mulps xmm7,xmm1
 subps xmm2,xmm3
 movaps xmm3,xmm6
 shufps xmm3,xmm3,$4e
 mulps xmm3,xmm4
 shufps xmm3,xmm3,$b1
 movaps dqword ptr [esp+48],xmm7
 movaps xmm7,xmm5
 mulps xmm5,xmm3
 addps xmm5,xmm2
 movaps xmm2,xmm3
 shufps xmm3,xmm3,$4e
 mulps xmm2,xmm1
 movaps dqword ptr [esp+64],xmm4
 movaps xmm4,xmm7
 mulps xmm7,xmm3
 mulps xmm3,xmm1
 subps xmm5,xmm7
 subps xmm3,xmm2
 movaps xmm2,xmm1
 mulps xmm1,xmm5
 shufps xmm3,xmm3,$4e
 movaps xmm7,xmm1
 shufps xmm1,xmm1,$4e
 movaps dqword ptr [esp],xmm5
 addps xmm1,xmm7
 movaps xmm5,xmm1
 shufps xmm1,xmm1,$b1
 addss xmm1,xmm5
 movaps xmm5,xmm6
 mulps xmm5,xmm2
 shufps xmm5,xmm5,$b1
 movaps xmm7,xmm5
 shufps xmm5,xmm5,$4e
 movaps dqword ptr [esp+80],xmm4
 movaps xmm4,dqword ptr [esp+64]
 movaps dqword ptr [esp+64],xmm6
 movaps xmm6,xmm4
 mulps xmm6,xmm7
 addps xmm6,xmm3
 movaps xmm3,xmm4
 mulps xmm3,xmm5
 subps xmm3,xmm6
 movaps xmm6,xmm4
 mulps xmm6,xmm2
 shufps xmm6,xmm6,$b1
 movaps dqword ptr [esp+112],xmm5
 movaps xmm5,dqword ptr [esp+64]
 movaps dqword ptr [esp+128],xmm7
 movaps xmm7,xmm6
 mulps xmm7,xmm5
 addps xmm7,xmm3
 movaps xmm3,xmm6
 shufps xmm3,xmm3,$4e
 movaps dqword ptr [esp+144],xmm4
 movaps xmm4,xmm5
 mulps xmm5,xmm3
 movaps dqword ptr [esp+160],xmm4
 movaps xmm4,xmm6
 movaps xmm6,xmm7
 subps xmm6,xmm5
 movaps xmm5,xmm0
 movaps xmm7,dqword ptr [esp+16]
 subps xmm5,xmm7
 shufps xmm5,xmm5,$4e
 movaps xmm7,dqword ptr [esp+80]
 mulps xmm4,xmm7
 mulps xmm3,xmm7
 subps xmm5,xmm4
 mulps xmm2,xmm7
 addps xmm3,xmm5
 shufps xmm2,xmm2,$b1
 movaps xmm4,xmm2
 shufps xmm4,xmm4,$4e
 movaps xmm5,dqword ptr [esp+144]
 movaps xmm0,xmm6
 movaps xmm6,xmm5
 mulps xmm5,xmm2
 mulps xmm6,xmm4
 addps xmm5,xmm3
 movaps xmm3,xmm4
 movaps xmm4,xmm5
 subps xmm4,xmm6
 movaps xmm5,dqword ptr [esp+48]
 movaps xmm6,dqword ptr [esp+32]
 subps xmm5,xmm6
 shufps xmm5,xmm5,$4e
 movaps xmm6,[esp+128]
 mulps xmm6,xmm7
 subps xmm6,xmm5
 movaps xmm5,dqword ptr [esp+112]
 mulps xmm7,xmm5
 subps xmm6,xmm7
 movaps xmm5,dqword ptr [esp+160]
 mulps xmm2,xmm5
 mulps xmm5,xmm3
 subps xmm6,xmm2
 movaps xmm2,xmm5
 addps xmm2,xmm6
 movaps xmm6,xmm0
 movaps xmm0,xmm1
 movaps xmm1,dqword ptr [esp]
 movaps xmm3,xmm0
 rcpss xmm5,xmm0
 mulss xmm0,xmm5
 mulss xmm0,xmm5
 addss xmm5,xmm5
 subss xmm5,xmm0
 movaps xmm0,xmm5
 addss xmm5,xmm5
 mulss xmm0,xmm0
 mulss xmm3,xmm0
 subss xmm5,xmm3
 shufps xmm5,xmm5,$00
 mulps xmm1,xmm5
 mulps xmm4,xmm5
 mulps xmm6,xmm5
 mulps xmm5,xmm2
 movups dqword ptr [result+0],xmm1
 movups dqword ptr [result+16],xmm4
 movups dqword ptr [result+32],xmm6
 movups dqword ptr [result+48],xmm5
 mov esp,ecx
end;
{$else}
var inv:array[0..15] of single;
    det:single;
begin
 inv[0]:=(((ma[1,1]*ma[2,2]*ma[3,3])-(ma[1,1]*ma[2,3]*ma[3,2]))-(ma[2,1]*ma[1,2]*ma[3,3])+(ma[2,1]*ma[1,3]*ma[3,2])+(ma[3,1]*ma[1,2]*ma[2,3]))-(ma[3,1]*ma[1,3]*ma[2,2]);
 inv[4]:=((((-(ma[1,0]*ma[2,2]*ma[3,3]))+(ma[1,0]*ma[2,3]*ma[3,2])+(ma[2,0]*ma[1,2]*ma[3,3]))-(ma[2,0]*ma[1,3]*ma[3,2]))-(ma[3,0]*ma[1,2]*ma[2,3]))+(ma[3,0]*ma[1,3]*ma[2,2]);
 inv[8]:=((((ma[1,0]*ma[2,1]*ma[3,3])-(ma[1,0]*ma[2,3]*ma[3,1]))-(ma[2,0]*ma[1,1]*ma[3,3]))+(ma[2,0]*ma[1,3]*ma[3,1])+(ma[3,0]*ma[1,1]*ma[2,3]))-(ma[3,0]*ma[1,3]*ma[2,1]);
 inv[12]:=((((-(ma[1,0]*ma[2,1]*ma[3,2]))+(ma[1,0]*ma[2,2]*ma[3,1])+(ma[2,0]*ma[1,1]*ma[3,2]))-(ma[2,0]*ma[1,2]*ma[3,1]))-(ma[3,0]*ma[1,1]*ma[2,2]))+(ma[3,0]*ma[1,2]*ma[2,1]);
 inv[1]:=((((-(ma[0,1]*ma[2,2]*ma[3,3]))+(ma[0,1]*ma[2,3]*ma[3,2])+(ma[2,1]*ma[0,2]*ma[3,3]))-(ma[2,1]*ma[0,3]*ma[3,2]))-(ma[3,1]*ma[0,2]*ma[2,3]))+(ma[3,1]*ma[0,3]*ma[2,2]);
 inv[5]:=(((ma[0,0]*ma[2,2]*ma[3,3])-(ma[0,0]*ma[2,3]*ma[3,2]))-(ma[2,0]*ma[0,2]*ma[3,3])+(ma[2,0]*ma[0,3]*ma[3,2])+(ma[3,0]*ma[0,2]*ma[2,3]))-(ma[3,0]*ma[0,3]*ma[2,2]);
 inv[9]:=((((-(ma[0,0]*ma[2,1]*ma[3,3]))+(ma[0,0]*ma[2,3]*ma[3,1])+(ma[2,0]*ma[0,1]*ma[3,3]))-(ma[2,0]*ma[0,3]*ma[3,1]))-(ma[3,0]*ma[0,1]*ma[2,3]))+(ma[3,0]*ma[0,3]*ma[2,1]);
 inv[13]:=((((ma[0,0]*ma[2,1]*ma[3,2])-(ma[0,0]*ma[2,2]*ma[3,1]))-(ma[2,0]*ma[0,1]*ma[3,2]))+(ma[2,0]*ma[0,2]*ma[3,1])+(ma[3,0]*ma[0,1]*ma[2,2]))-(ma[3,0]*ma[0,2]*ma[2,1]);
 inv[2]:=((((ma[0,1]*ma[1,2]*ma[3,3])-(ma[0,1]*ma[1,3]*ma[3,2]))-(ma[1,1]*ma[0,2]*ma[3,3]))+(ma[1,1]*ma[0,3]*ma[3,2])+(ma[3,1]*ma[0,2]*ma[1,3]))-(ma[3,1]*ma[0,3]*ma[1,2]);
 inv[6]:=((((-(ma[0,0]*ma[1,2]*ma[3,3]))+(ma[0,0]*ma[1,3]*ma[3,2])+(ma[1,0]*ma[0,2]*ma[3,3]))-(ma[1,0]*ma[0,3]*ma[3,2]))-(ma[3,0]*ma[0,2]*ma[1,3]))+(ma[3,0]*ma[0,3]*ma[1,2]);
 inv[10]:=((((ma[0,0]*ma[1,1]*ma[3,3])-(ma[0,0]*ma[1,3]*ma[3,1]))-(ma[1,0]*ma[0,1]*ma[3,3]))+(ma[1,0]*ma[0,3]*ma[3,1])+(ma[3,0]*ma[0,1]*ma[1,3]))-(ma[3,0]*ma[0,3]*ma[1,1]);
 inv[14]:=((((-(ma[0,0]*ma[1,1]*ma[3,2]))+(ma[0,0]*ma[1,2]*ma[3,1])+(ma[1,0]*ma[0,1]*ma[3,2]))-(ma[1,0]*ma[0,2]*ma[3,1]))-(ma[3,0]*ma[0,1]*ma[1,2]))+(ma[3,0]*ma[0,2]*ma[1,1]);
 inv[3]:=((((-(ma[0,1]*ma[1,2]*ma[2,3]))+(ma[0,1]*ma[1,3]*ma[2,2])+(ma[1,1]*ma[0,2]*ma[2,3]))-(ma[1,1]*ma[0,3]*ma[2,2]))-(ma[2,1]*ma[0,2]*ma[1,3]))+(ma[2,1]*ma[0,3]*ma[1,2]);
 inv[7]:=((((ma[0,0]*ma[1,2]*ma[2,3])-(ma[0,0]*ma[1,3]*ma[2,2]))-(ma[1,0]*ma[0,2]*ma[2,3]))+(ma[1,0]*ma[0,3]*ma[2,2])+(ma[2,0]*ma[0,2]*ma[1,3]))-(ma[2,0]*ma[0,3]*ma[1,2]);
 inv[11]:=((((-(ma[0,0]*ma[1,1]*ma[2,3]))+(ma[0,0]*ma[1,3]*ma[2,1])+(ma[1,0]*ma[0,1]*ma[2,3]))-(ma[1,0]*ma[0,3]*ma[2,1]))-(ma[2,0]*ma[0,1]*ma[1,3]))+(ma[2,0]*ma[0,3]*ma[1,1]);
 inv[15]:=((((ma[0,0]*ma[1,1]*ma[2,2])-(ma[0,0]*ma[1,2]*ma[2,1]))-(ma[1,0]*ma[0,1]*ma[2,2]))+(ma[1,0]*ma[0,2]*ma[2,1])+(ma[2,0]*ma[0,1]*ma[1,2]))-(ma[2,0]*ma[0,2]*ma[1,1]);
 det:=(ma[0,0]*inv[0])+(ma[0,1]*inv[4])+(ma[0,2]*inv[8])+(ma[0,3]*inv[12]);
 if abs(det)>EPSILON then begin
  det:=1.0/det;
  result[0,0]:=inv[0]*det;
  result[0,1]:=inv[1]*det;
  result[0,2]:=inv[2]*det;
  result[0,3]:=inv[3]*det;
  result[1,0]:=inv[4]*det;
  result[1,1]:=inv[5]*det;
  result[1,2]:=inv[6]*det;
  result[1,3]:=inv[7]*det;
  result[2,0]:=inv[8]*det;
  result[2,1]:=inv[9]*det;
  result[2,2]:=inv[10]*det;
  result[2,3]:=inv[11]*det;
  result[3,0]:=inv[12]*det;
  result[3,1]:=inv[13]*det;
  result[3,2]:=inv[14]*det;
  result[3,3]:=inv[15]*det;
 end else begin
  result:=ma;
 end;
end;
{$endif}

function Matrix4x4InverseOld(var mr:TMatrix4x4;const ma:TMatrix4x4):boolean;
var Det,IDet:single;
begin
 Det:=(ma[0,0]*ma[1,1]*ma[2,2])+
      (ma[1,0]*ma[2,1]*ma[0,2])+
      (ma[2,0]*ma[0,1]*ma[1,2])-
      (ma[2,0]*ma[1,1]*ma[0,2])-
      (ma[1,0]*ma[0,1]*ma[2,2])-
      (ma[0,0]*ma[2,1]*ma[1,2]);
 if abs(Det)<EPSILON then begin
  mr:=Matrix4x4Identity;
  result:=false;
 end else begin
  IDet:=1/Det;
  mr[0,0]:=(ma[1,1]*ma[2,2]-ma[2,1]*ma[1,2])*IDet;
  mr[0,1]:=-(ma[0,1]*ma[2,2]-ma[2,1]*ma[0,2])*IDet;
  mr[0,2]:=(ma[0,1]*ma[1,2]-ma[1,1]*ma[0,2])*IDet;
  mr[0,3]:=0.0;
  mr[1,0]:=-(ma[1,0]*ma[2,2]-ma[2,0]*ma[1,2])*IDet;
  mr[1,1]:=(ma[0,0]*ma[2,2]-ma[2,0]*ma[0,2])*IDet;
  mr[1,2]:=-(ma[0,0]*ma[1,2]-ma[1,0]*ma[0,2])*IDet;
  mr[1,3]:=0.0;
  mr[2,0]:=(ma[1,0]*ma[2,1]-ma[2,0]*ma[1,1])*IDet;
  mr[2,1]:=-(ma[0,0]*ma[2,1]-ma[2,0]*ma[0,1])*IDet;
  mr[2,2]:=(ma[0,0]*ma[1,1]-ma[1,0]*ma[0,1])*IDet;
  mr[2,3]:=0.0;
  mr[3,0]:=-(ma[3,0]*mr[0,0]+ma[3,1]*mr[1,0]+ma[3,2]*mr[2,0]);
  mr[3,1]:=-(ma[3,0]*mr[0,1]+ma[3,1]*mr[1,1]+ma[3,2]*mr[2,1]);
  mr[3,2]:=-(ma[3,0]*mr[0,2]+ma[3,1]*mr[1,2]+ma[3,2]*mr[2,2]);
  mr[3,3]:=1.0;
  result:=true;
 end;
end;

function Matrix4x4TermInverseOld(const ma:TMatrix4x4):TMatrix4x4;
var Det,IDet:single;
begin
 Det:=((((ma[0,0]*ma[1,1]*ma[2,2])+
         (ma[1,0]*ma[2,1]*ma[0,2])+
         (ma[2,0]*ma[0,1]*ma[1,2]))-
        (ma[2,0]*ma[1,1]*ma[0,2]))-
       (ma[1,0]*ma[0,1]*ma[2,2]))-
      (ma[0,0]*ma[2,1]*ma[1,2]);
 if abs(Det)<EPSILON then begin
  result:=Matrix4x4Identity;
 end else begin
  IDet:=1/Det;
  result[0,0]:=(ma[1,1]*ma[2,2]-ma[2,1]*ma[1,2])*IDet;
  result[0,1]:=-(ma[0,1]*ma[2,2]-ma[2,1]*ma[0,2])*IDet;
  result[0,2]:=(ma[0,1]*ma[1,2]-ma[1,1]*ma[0,2])*IDet;
  result[0,3]:=0.0;
  result[1,0]:=-(ma[1,0]*ma[2,2]-ma[2,0]*ma[1,2])*IDet;
  result[1,1]:=(ma[0,0]*ma[2,2]-ma[2,0]*ma[0,2])*IDet;
  result[1,2]:=-(ma[0,0]*ma[1,2]-ma[1,0]*ma[0,2])*IDet;
  result[1,3]:=0.0;
  result[2,0]:=(ma[1,0]*ma[2,1]-ma[2,0]*ma[1,1])*IDet;
  result[2,1]:=-(ma[0,0]*ma[2,1]-ma[2,0]*ma[0,1])*IDet;
  result[2,2]:=(ma[0,0]*ma[1,1]-ma[1,0]*ma[0,1])*IDet;
  result[2,3]:=0.0;
  result[3,0]:=-(ma[3,0]*result[0,0]+ma[3,1]*result[1,0]+ma[3,2]*result[2,0]);
  result[3,1]:=-(ma[3,0]*result[0,1]+ma[3,1]*result[1,1]+ma[3,2]*result[2,1]);
  result[3,2]:=-(ma[3,0]*result[0,2]+ma[3,1]*result[1,2]+ma[3,2]*result[2,2]);
  result[3,3]:=1.0;
 end;
end;

function Matrix4x4GetSubMatrix3x3(const m:TMatrix4x4;i,j:longint):TMatrix3x3;
var di,dj,si,sj:longint;
begin
 for di:=0 to 2 do begin
  for dj:=0 to 2 do begin
   if di>=i then begin
    si:=di+1;
   end else begin
    si:=di;
   end;
   if dj>=j then begin
    sj:=dj+1;
   end else begin
    sj:=dj;
   end;
   result[di,dj]:=m[si,sj];
  end;
 end;
end;

function Matrix4x4Frustum(Left,Right,Bottom,Top,zNear,zFar:single):TMatrix4x4;
var rml,tmb,fmn:single;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 result[0,0]:=(zNear*2.0)/rml;
 result[0,1]:=0.0;
 result[0,2]:=0.0;
 result[0,3]:=0.0;
 result[1,0]:=0.0;
 result[1,1]:=(zNear*2.0)/tmb;
 result[1,2]:=0.0;
 result[1,3]:=0.0;
 result[2,0]:=(Right+Left)/rml;
 result[2,1]:=(Top+Bottom)/tmb;
 result[2,2]:=(-(zFar+zNear))/fmn;
 result[2,3]:=-1.0;
 result[3,0]:=0.0;
 result[3,1]:=0.0;
 result[3,2]:=(-((zFar*zNear)*2.0))/fmn;
 result[3,3]:=0.0;
end;

function Matrix4x4Ortho(Left,Right,Bottom,Top,zNear,zFar:single):TMatrix4x4;
var rml,tmb,fmn:single;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 result[0,0]:=2.0/rml;
 result[0,1]:=0.0;
 result[0,2]:=0.0;
 result[0,3]:=0.0;
 result[1,0]:=0.0;
 result[1,1]:=2.0/tmb;
 result[1,2]:=0.0;
 result[1,3]:=0.0;
 result[2,0]:=0.0;
 result[2,1]:=0.0;
 result[2,2]:=(-2.0)/fmn;
 result[2,3]:=0.0;
 result[3,0]:=(-(Right+Left))/rml;
 result[3,1]:=(-(Top+Bottom))/tmb;
 result[3,2]:=(-(zFar+zNear))/fmn;
 result[3,3]:=1.0;
end;

function Matrix4x4OrthoLH(Left,Right,Bottom,Top,zNear,zFar:single):TMatrix4x4;
var rml,tmb,fmn:single;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 result[0,0]:=2.0/rml;
 result[0,1]:=0.0;
 result[0,2]:=0.0;
 result[0,3]:=0.0;
 result[1,0]:=0.0;
 result[1,1]:=2.0/tmb;
 result[1,2]:=0.0;
 result[1,3]:=0.0;
 result[2,0]:=0.0;
 result[2,1]:=0.0;
 result[2,2]:=1.0/fmn;
 result[2,3]:=0.0;
 result[3,0]:=0;
 result[3,1]:=0;
 result[3,2]:=(-zNear)/fmn;
 result[3,3]:=1.0;
end;

function Matrix4x4OrthoRH(Left,Right,Bottom,Top,zNear,zFar:single):TMatrix4x4;
var rml,tmb,fmn:single;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 result[0,0]:=2.0/rml;
 result[0,1]:=0.0;
 result[0,2]:=0.0;
 result[0,3]:=0.0;
 result[1,0]:=0.0;
 result[1,1]:=2.0/tmb;
 result[1,2]:=0.0;
 result[1,3]:=0.0;
 result[2,0]:=0.0;
 result[2,1]:=0.0;
 result[2,2]:=1.0/fmn;
 result[2,3]:=0.0;
 result[3,0]:=0;
 result[3,1]:=0;
 result[3,2]:=zNear/fmn;
 result[3,3]:=1.0;
end;

function Matrix4x4OrthoOffCenterLH(Left,Right,Bottom,Top,zNear,zFar:single):TMatrix4x4;
var rml,tmb,fmn:single;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 result[0,0]:=2.0/rml;
 result[0,1]:=0.0;
 result[0,2]:=0.0;
 result[0,3]:=0.0;
 result[1,0]:=0.0;
 result[1,1]:=2.0/tmb;
 result[1,2]:=0.0;
 result[1,3]:=0.0;
 result[2,0]:=0.0;
 result[2,1]:=0.0;
 result[2,2]:=1.0/fmn;
 result[2,3]:=0.0;
 result[3,0]:=(Right+Left)/rml;
 result[3,1]:=(Top+Bottom)/tmb;
 result[3,2]:=zNear/fmn;
 result[3,3]:=1.0;
end;            

function Matrix4x4OrthoOffCenterRH(Left,Right,Bottom,Top,zNear,zFar:single):TMatrix4x4;
var rml,tmb,fmn:single;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 result[0,0]:=2.0/rml;
 result[0,1]:=0.0;
 result[0,2]:=0.0;
 result[0,3]:=0.0;
 result[1,0]:=0.0;
 result[1,1]:=2.0/tmb;
 result[1,2]:=0.0;
 result[1,3]:=0.0;
 result[2,0]:=0.0;
 result[2,1]:=0.0;
 result[2,2]:=(-2.0)/fmn;
 result[2,3]:=0.0;
 result[3,0]:=(-(Right+Left))/rml;
 result[3,1]:=(-(Top+Bottom))/tmb;
 result[3,2]:=(-(zFar+zNear))/fmn;
 result[3,3]:=1.0;
end;

function Matrix4x4Perspective(fovy,Aspect,zNear,zFar:single):TMatrix4x4;
(*)var Top,Right:single;
begin
 Top:=zNear*tan(fovy*pi/360.0);
 Right:=Top*Aspect;
 result:=Matrix4x4Frustum(-Right,Right,-Top,Top,zNear,zFar);
end;{(**)var Sine,Cotangent,ZDelta,Radians:single;
begin
 Radians:=(fovy*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  result:=Matrix4x4Identity;
  result[0][0]:=Cotangent/aspect;
  result[1][1]:=Cotangent;
  result[2][2]:=(-(zFar+zNear))/ZDelta;
  result[2][3]:=-1-0;
  result[3][2]:=(-(2.0*zNear*zFar))/ZDelta;
  result[3][3]:=0.0;
 end;
end;{}

function Matrix4x4LookAtViewerLDX(const Eye,Angles:TVector3):TMatrix4x4;
var cp,sp,cy,sy,cr,sr:single;
    ForwardVector,RightVector,UpVector:TVector3;
begin
 cp:=cos(Angles.Pitch);
 sp:=sin(Angles.Pitch);
 cy:=cos(Angles.Yaw);
 sy:=sin(Angles.Yaw);
 cr:=cos(Angles.Roll);
 sr:=sin(Angles.Roll);
 ForwardVector.x:=cp*cy;
 ForwardVector.y:=cp*sy;
 ForwardVector.z:=-sp;
 RightVector.x:=((-(sr*sp*cy))-(cr*(-sy)));
 RightVector.y:=((-(sr*sp*sy))-(cr*cy));
 RightVector.z:=-(sr*cp);
 UpVector.x:=(cr*sp*cy)+((-sr)*(-sy));
 UpVector.y:=(cr*sp*sy)+((-sr)*cy);
 UpVector.z:=cr*cp;
 Vector3Normalize(ForwardVector);
 Vector3Normalize(RightVector);
 Vector3Normalize(UpVector);
 result[0,0]:=ForwardVector.x;
 result[1,0]:=ForwardVector.y;
 result[2,0]:=ForwardVector.z;
 result[3,0]:=(ForwardVector.x*(-Eye.x))+(ForwardVector.y*(-Eye.y))+(ForwardVector.z*(-Eye.z));
 result[0,1]:=-RightVector.x;
 result[1,1]:=-RightVector.y;
 result[2,1]:=-RightVector.z;
 result[3,1]:=((-RightVector.x)*(-Eye.x))+((-RightVector.y)*(-Eye.y))+((-RightVector.z)*(-Eye.z));
 result[0,2]:=UpVector.x;
 result[1,2]:=UpVector.y;
 result[2,2]:=UpVector.z;
 result[3,2]:=(UpVector.x*(-Eye.x))+(UpVector.y*(-Eye.y))+(UpVector.z*(-Eye.z));
 result[0,3]:=0.0;
 result[1,3]:=0.0;
 result[2,3]:=0.0;
 result[3,3]:=1.0;
end;

function Matrix4x4LookWithAnglesLDX(const Eye,Angles:TVector3):TMatrix4x4;
var Pitch,Yaw,Roll,cp,sp,cy,sy,cr,sr:single;
    ForwardVector,RightVector,UpVector:TVector3;
begin
 Pitch:=Angles.Pitch*DEG2RAD;
 Yaw:=Angles.Yaw*DEG2RAD;
 Roll:=Angles.Roll*DEG2RAD;
 cp:=cos(Pitch);
 sp:=sin(Pitch);
 cy:=cos(Yaw);
 sy:=sin(Yaw);
 cr:=cos(Roll);
 sr:=sin(Roll);
 ForwardVector.x:=cp*cy;
 ForwardVector.y:=cp*sy;
 ForwardVector.z:=-sp;
 RightVector.x:=((-(sr*sp*cy))-(cr*(-sy)));
 RightVector.y:=((-(sr*sp*sy))-(cr*cy));
 RightVector.z:=-(sr*cp);
 UpVector.x:=(cr*sp*cy)+((-sr)*(-sy));
 UpVector.y:=(cr*sp*sy)+((-sr)*cy);
 UpVector.z:=cr*cp;
 Vector3Normalize(ForwardVector);
 Vector3Normalize(RightVector);
 Vector3Normalize(UpVector);
 ForwardVector:=Vector3Neg(ForwardVector);
 RightVector:=Vector3Neg(RightVector);
 UpVector:=Vector3Neg(UpVector);
 result[0,0]:=ForwardVector.x;
 result[1,0]:=ForwardVector.y;
 result[2,0]:=ForwardVector.z;
 result[3,0]:=(ForwardVector.x*(-Eye.x))+(ForwardVector.y*(-Eye.y))+(ForwardVector.z*(-Eye.z));
 result[0,1]:=RightVector.x;
 result[1,1]:=RightVector.y;
 result[2,1]:=RightVector.z;
 result[3,1]:=(RightVector.x*(-Eye.x))+(RightVector.y*(-Eye.y))+(RightVector.z*(-Eye.z));
 result[0,2]:=UpVector.x;
 result[1,2]:=UpVector.y;
 result[2,2]:=UpVector.z;
 result[3,2]:=(UpVector.x*(-Eye.x))+(UpVector.y*(-Eye.y))+(UpVector.z*(-Eye.z));
 result[0,3]:=0.0;
 result[1,3]:=0.0;
 result[2,3]:=0.0;
 result[3,3]:=1.0;
end;

function Matrix4x4LookAtLDX(const Eye,Center,Up:TVector3):TMatrix4x4;
var RightVector,UpVector,ForwardVector:TVector3;
begin
 ForwardVector:=Vector3Norm(Vector3Sub(Eye,Center));
 RightVector:=Vector3Norm(Vector3Cross(Up,ForwardVector));
 UpVector:=Vector3Norm(Vector3Cross(ForwardVector,RightVector));
 result[0,0]:=ForwardVector.x;
 result[1,0]:=ForwardVector.y;
 result[2,0]:=ForwardVector.z;
 result[3,0]:=(ForwardVector.x*(-Eye.x))+(ForwardVector.y*(-Eye.y))+(ForwardVector.z*(-Eye.z));
 result[0,1]:=RightVector.x;
 result[1,1]:=RightVector.y;
 result[2,1]:=RightVector.z;
 result[3,1]:=(RightVector.x*(-Eye.x))+(RightVector.y*(-Eye.y))+(RightVector.z*(-Eye.z));
 result[0,2]:=UpVector.x;
 result[1,2]:=UpVector.y;
 result[2,2]:=UpVector.z;
 result[3,2]:=(UpVector.x*(-Eye.x))+(UpVector.y*(-Eye.y))+(UpVector.z*(-Eye.z));
 result[0,3]:=0.0;
 result[1,3]:=0.0;
 result[2,3]:=0.0;
 result[3,3]:=1.0;
end;

function Matrix4x4LookAtLDX2(const Eye,Center,Up:TVector3):TMatrix4x4;
var RightVector,UpVector,ForwardVector:TVector3;
begin
 ForwardVector:=Vector3Norm(Vector3Sub(Center,Eye));
 RightVector:=Vector3Norm(Vector3Cross(Up,ForwardVector));
 UpVector:=Vector3Norm(Vector3Cross(ForwardVector,RightVector));
 result[0,0]:=ForwardVector.x;
 result[1,0]:=ForwardVector.y;
 result[2,0]:=ForwardVector.z;
 result[3,0]:=(ForwardVector.x*(-Eye.x))+(ForwardVector.y*(-Eye.y))+(ForwardVector.z*(-Eye.z));
 result[0,1]:=RightVector.x;
 result[1,1]:=RightVector.y;
 result[2,1]:=RightVector.z;
 result[3,1]:=(RightVector.x*(-Eye.x))+(RightVector.y*(-Eye.y))+(RightVector.z*(-Eye.z));
 result[0,2]:=UpVector.x;
 result[1,2]:=UpVector.y;
 result[2,2]:=UpVector.z;
 result[3,2]:=(UpVector.x*(-Eye.x))+(UpVector.y*(-Eye.y))+(UpVector.z*(-Eye.z));
 result[0,3]:=0.0;
 result[1,3]:=0.0;
 result[2,3]:=0.0;
 result[3,3]:=1.0;
end;

function Matrix4x4LookAt(const Eye,Center,Up:TVector3):TMatrix4x4;
var RightVector,UpVector,ForwardVector:TVector3;
begin
 ForwardVector:=Vector3Norm(Vector3Sub(Eye,Center));
 RightVector:=Vector3Norm(Vector3Cross(Up,ForwardVector));
 UpVector:=Vector3Norm(Vector3Cross(ForwardVector,RightVector));
 result[0,0]:=RightVector.x;
 result[1,0]:=RightVector.y;
 result[2,0]:=RightVector.z;
 result[3,0]:=-((RightVector.x*Eye.x)+(RightVector.y*Eye.y)+(RightVector.z*Eye.z));
 result[0,1]:=UpVector.x;
 result[1,1]:=UpVector.y;
 result[2,1]:=UpVector.z;
 result[3,1]:=-((UpVector.x*Eye.x)+(UpVector.y*Eye.y)+(UpVector.z*Eye.z));
 result[0,2]:=ForwardVector.x;
 result[1,2]:=ForwardVector.y;
 result[2,2]:=ForwardVector.z;
 result[3,2]:=-((ForwardVector.x*Eye.x)+(ForwardVector.y*Eye.y)+(ForwardVector.z*Eye.z));
 result[0,3]:=0.0;
 result[1,3]:=0.0;
 result[2,3]:=0.0;
 result[3,3]:=1.0;
end;

function Matrix4x4ModelLookAt(const Position,Target,Up:TVector3):TMatrix4x4;
var RightVector,UpVector,ForwardVector:TVector3;
begin
 ForwardVector:=Vector3Norm(Vector3Sub(Position,Target));
 RightVector:=Vector3Norm(Vector3Cross(Up,ForwardVector));
 UpVector:=Vector3Norm(Vector3Cross(ForwardVector,RightVector));
 result[0,0]:=RightVector.x;
 result[0,1]:=RightVector.y;
 result[0,2]:=RightVector.z;
 result[0,3]:=0;
 result[1,0]:=UpVector.x;
 result[1,1]:=UpVector.y;
 result[1,2]:=UpVector.z;
 result[1,3]:=0.0;
 result[2,0]:=ForwardVector.x;
 result[2,1]:=ForwardVector.y;
 result[2,2]:=ForwardVector.z;
 result[2,3]:=0.0;
 result[3,0]:=Position.x;
 result[3,1]:=Position.y;
 result[3,2]:=Position.z;
 result[3,3]:=1.0;
end;

function Matrix4x4Fill(const Eye,RightVector,UpVector,ForwardVector:TVector3):TMatrix4x4;
begin
 result[0,0]:=RightVector.x;
 result[1,0]:=RightVector.y;
 result[2,0]:=RightVector.z;
 result[3,0]:=-((RightVector.x*Eye.x)+(RightVector.y*Eye.y)+(RightVector.z*Eye.z));
 result[0,1]:=UpVector.x;
 result[1,1]:=UpVector.y;
 result[2,1]:=UpVector.z;
 result[3,1]:=-((UpVector.x*Eye.x)+(UpVector.y*Eye.y)+(UpVector.z*Eye.z));
 result[0,2]:=ForwardVector.x;
 result[1,2]:=ForwardVector.y;
 result[2,2]:=ForwardVector.z;
 result[3,2]:=-((ForwardVector.x*Eye.x)+(ForwardVector.y*Eye.y)+(ForwardVector.z*Eye.z));
 result[0,3]:=0.0;
 result[1,3]:=0.0;
 result[2,3]:=0.0;
 result[3,3]:=1.0;
end;

function Matrix4x4LookAtLH(const Eye,At,Up:TVector3):TMatrix4x4;
var xAxis,yAxis,zAxis:TVector3;
begin
 zAxis:=Vector3Norm(Vector3Sub(At,Eye));
 xAxis:=Vector3Norm(Vector3Cross(Up,zAxis));
 yAxis:=Vector3Norm(Vector3Cross(zAxis,xAxis));
 result[0,0]:=xAxis.x;
 result[1,0]:=xAxis.y;
 result[2,0]:=xAxis.z;
 result[3,0]:=-((xAxis.x*Eye.x)+(xAxis.y*Eye.y)+(xAxis.z*Eye.z));
 result[0,1]:=yAxis.x;
 result[1,1]:=yAxis.y;
 result[2,1]:=yAxis.z;
 result[3,1]:=-((yAxis.x*Eye.x)+(yAxis.y*Eye.y)+(yAxis.z*Eye.z));
 result[0,2]:=zAxis.x;
 result[1,2]:=zAxis.y;
 result[2,2]:=zAxis.z;
 result[3,2]:=-((zAxis.x*Eye.x)+(zAxis.y*Eye.y)+(zAxis.z*Eye.z));
 result[0,3]:=0.0;
 result[1,3]:=0.0;
 result[2,3]:=0.0;
 result[3,3]:=1.0;
end;

function Matrix4x4LookAtRH(const Eye,At,Up:TVector3):TMatrix4x4;
var xAxis,yAxis,zAxis:TVector3;
begin
 zAxis:=Vector3Norm(Vector3Sub(Eye,At));
 xAxis:=Vector3Norm(Vector3Cross(Up,zAxis));
 yAxis:=Vector3Norm(Vector3Cross(zAxis,xAxis));
 result[0,0]:=xAxis.x;
 result[1,0]:=xAxis.y;
 result[2,0]:=xAxis.z;
 result[3,0]:=(xAxis.x*Eye.x)+(xAxis.y*Eye.y)+(xAxis.z*Eye.z);
 result[0,1]:=yAxis.x;
 result[1,1]:=yAxis.y;
 result[2,1]:=yAxis.z;
 result[3,1]:=(yAxis.x*Eye.x)+(yAxis.y*Eye.y)+(yAxis.z*Eye.z);
 result[0,2]:=zAxis.x;
 result[1,2]:=zAxis.y;
 result[2,2]:=zAxis.z;
 result[3,2]:=(zAxis.x*Eye.x)+(zAxis.y*Eye.y)+(zAxis.z*Eye.z);
 result[0,3]:=0.0;
 result[1,3]:=0.0;
 result[2,3]:=0.0;
 result[3,3]:=1.0;
end;

function Matrix4x4LookAtLight(const Pos,Dir,Up:TVector3):TMatrix4x4;
begin
 result:=Matrix4x4LookAt(Pos,Vector3Add(Pos,Dir),Up);
end;

{var LeftVector,UpVector,ForwardVector:TVector3;
begin
 LeftVector:=Vector3Norm(Vector3Cross(Dir,Up));
 UpVector:=Vector3Norm(Vector3Cross(LeftVector,Dir));
 ForwardVector:=Vector3Norm(Dir);
 result[0,0]:=LeftVector.x;
 result[0,1]:=LeftVector.y;
 result[0,2]:=LeftVector.z;
 result[0,3]:=-((LeftVector.x*POs.x)+(LeftVector.y*Pos.y)+(LeftVector.z*Pos.z));
 result[1,0]:=UpVector.x;
 result[1,1]:=UpVector.y;
 result[1,2]:=UpVector.z;
 result[1,3]:=-((UpVector.x*POs.x)+(UpVector.y*Pos.y)+(UpVector.z*Pos.z));
 result[2,0]:=-ForwardVector.x;
 result[2,1]:=-ForwardVector.y;
 result[2,2]:=-ForwardVector.z;
 result[2,3]:=((ForwardVector.x*POs.x)+(ForwardVector.y*Pos.y)+(ForwardVector.z*Pos.z));
 result[3,0]:=0.0;
 result[3,1]:=0.0;
 result[3,2]:=0.0;
 result[3,3]:=1.0;
end;              }

function Matrix4x4ConstructX(const xAxis:TVector3):TMatrix4x4;
var a,b,c:TVector3;
begin
 a:=Vector3Norm(xAxis);
 result[0,0]:=a.x;
 result[0,1]:=a.y;
 result[0,2]:=a.z;
 result[0,3]:=0.0;
 b:=Vector3Norm(Vector3Cross(Vector3(0,0,1),a));
//b:=Vector3Norm(Vector3Perpendicular(a));
 result[1,0]:=b.x;
 result[1,1]:=b.y;
 result[1,2]:=b.z;
 result[1,3]:=0.0;
 c:=Vector3Norm(Vector3Cross(a,b));
 result[2,0]:=c.x;
 result[2,1]:=c.y;
 result[2,2]:=c.z;
 result[2,3]:=0.0;
 result[3,0]:=0.0;
 result[3,1]:=0.0;
 result[3,2]:=0.0;
 result[3,3]:=1.0;
end;{}

function Matrix4x4ConstructY(const yAxis:TVector3):TMatrix4x4;
var a,b,c:TVector3;
begin
 a:=Vector3Norm(yAxis);
 result[1,0]:=a.x;
 result[1,1]:=a.y;
 result[1,2]:=a.z;
 result[1,3]:=0.0;
 b:=Vector3Norm(Vector3Perpendicular(a));
 result[0,0]:=b.x;
 result[0,1]:=b.y;
 result[0,2]:=b.z;
 result[0,3]:=0.0;
 c:=Vector3Cross(a,b);
 result[2,0]:=c.x;
 result[2,1]:=c.y;
 result[2,2]:=c.z;
 result[2,3]:=0.0;
 result[3,0]:=0.0;
 result[3,1]:=0.0;
 result[3,2]:=0.0;
 result[3,3]:=1.0;
end;

function Matrix4x4ConstructZ(const zAxis:TVector3):TMatrix4x4;
var a,b,c:TVector3;
begin
 a:=Vector3Norm(zAxis);
 result[2,0]:=a.x;
 result[2,1]:=a.y;
 result[2,2]:=a.z;
 result[2,3]:=0.0;
 b:=Vector3Norm(Vector3Perpendicular(a));
//b:=Vector3Sub(Vector3(0,1,0),Vector3ScalarMul(a,a.y));
 result[1,0]:=b.x;
 result[1,1]:=b.y;
 result[1,2]:=b.z;
 result[1,3]:=0.0;
 c:=Vector3Cross(b,a);
 result[0,0]:=c.x;
 result[0,1]:=c.y;
 result[0,2]:=c.z;
 result[0,3]:=0.0;
 result[3,0]:=0.0;
 result[3,1]:=0.0;
 result[3,2]:=0.0;
 result[3,3]:=1.0;
end;

function Matrix4x4ProjectionMatrixClip(const ProjectionMatrix:TMatrix4x4;const ClipPlane:TPlane):TMatrix4x4;
var q,c:TVector4;
begin
 result:=ProjectionMatrix;
 q.x:=(Sign(ClipPlane.Normal.x)+result[2,0])/result[0,0];
 q.y:=(Sign(ClipPlane.Normal.y)+result[2,1])/result[1,1];
 q.z:=-1.0;
 q.w:=(1.0+result[2,2])/result[3,2];
 c:=Vector4ScalarMul(ClipPlane.xyzw,2.0/Vector4Dot(ClipPlane.xyzw,q));
 result[0,2]:=c.x;
 result[1,2]:=c.y;
 result[2,2]:=c.z+1.0;
 result[3,2]:=c.w;
end;

function PlaneMatrixMul(const Plane:TPlane;const Matrix:TMatrix4x4):TPlane;
begin
 result.a:=(Matrix[0,0]*Plane.a)+(Matrix[1,0]*Plane.b)+(Matrix[2,0]*Plane.c)+(Matrix[3,0]*Plane.d);
 result.b:=(Matrix[0,1]*Plane.a)+(Matrix[1,1]*Plane.b)+(Matrix[2,1]*Plane.c)+(Matrix[3,1]*Plane.d);
 result.c:=(Matrix[0,2]*Plane.a)+(Matrix[1,2]*Plane.b)+(Matrix[2,2]*Plane.c)+(Matrix[3,2]*Plane.d);
 result.d:=(Matrix[0,3]*Plane.a)+(Matrix[1,3]*Plane.b)+(Matrix[2,3]*Plane.c)+(Matrix[3,3]*Plane.d);
end;

function PlaneTransform(const Plane:TPlane;const Matrix:TMatrix4x4):TPlane; overload;
begin
 result.Normal:=Vector3Norm(Vector3TermMatrixMulBasis(Plane.Normal,Matrix4x4TermTranspose(Matrix4x4TermInverse(Matrix))));
 result.Distance:=-Vector3Dot(result.Normal,Vector3TermMatrixMul(Vector3ScalarMul(Plane.Normal,-Plane.Distance),Matrix));
end;

function PlaneTransform(const Plane:TPlane;const Matrix,NormalMatrix:TMatrix4x4):TPlane; overload;
begin
 result.Normal:=Vector3Norm(Vector3TermMatrixMulBasis(Plane.Normal,NormalMatrix));
 result.Distance:=-Vector3Dot(result.Normal,Vector3TermMatrixMul(Vector3ScalarMul(Plane.Normal,-Plane.Distance),Matrix));
end;

function PlaneFastTransform(const Plane:TPlane;const Matrix:TMatrix4x4):TPlane; overload; {$ifdef caninline}inline;{$endif}
begin
 result.Normal:=Vector3Norm(Vector3TermMatrixMulBasis(Plane.Normal,Matrix));
 result.Distance:=-Vector3Dot(result.Normal,Vector3TermMatrixMul(Vector3ScalarMul(Plane.Normal,-Plane.Distance),Matrix));
end;

procedure PlaneNormalize(var Plane:TPlane); {$ifdef caninline}inline;{$endif}
var l:single;
begin
 l:=sqrt(sqr(Plane.a)+sqr(Plane.b)+sqr(Plane.c));
 if abs(l)>EPSILON then begin
  l:=1.0/l;
  Plane.a:=Plane.a*l;
  Plane.b:=Plane.b*l;
  Plane.c:=Plane.c*l;
  Plane.d:=Plane.d*l;
 end else begin
  Plane.a:=0;
  Plane.b:=0;
  Plane.c:=0;
  Plane.d:=0;
 end;
end;

function PlaneVectorDistance(const Plane:TPlane;const Point:TVector3):single; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=(Plane.a*Point.x)+(Plane.b*Point.y)+(Plane.c*Point.z)+Plane.d;
end;

function PlaneVectorDistance(const Plane:TPlane;const Point:TSIMDVector3):single; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=(Plane.a*Point.x)+(Plane.b*Point.y)+(Plane.c*Point.z)+Plane.d;
end;

function PlaneVectorDistance(const Plane:TPlane;const Point:TVector4):single; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=(Plane.a*Point.x)+(Plane.b*Point.y)+(Plane.c*Point.z)+(Plane.d*Point.w);
end;

function PlaneFromPoints(const p1,p2,p3:TVector3):TPlane; overload; {$ifdef caninline}inline;{$endif}
var n:TVector3;
begin
 n:=Vector3Norm(Vector3Cross(Vector3Sub(p2,p1),Vector3Sub(p3,p1)));
 result.a:=n.x;
 result.b:=n.y;
 result.c:=n.z;
 result.d:=-((result.a*p1.x)+(result.b*p1.y)+(result.c*p1.z));
end;

function PlaneFromPoints(const p1,p2,p3:TVector4):TPlane; overload; {$ifdef caninline}inline;{$endif}
var n:TVector4;
begin
 n:=Vector4Norm(Vector4Cross(Vector4Sub(p2,p1),Vector4Sub(p3,p1)));
 result.a:=n.x;
 result.b:=n.y;
 result.c:=n.z;
 result.d:=-((result.a*p1.x)+(result.b*p1.y)+(result.c*p1.z));
end;

procedure PlaneClipSegment(const Plane:TPlane;var p0,p1,Clipped:TVector3); overload;
begin
 Clipped:=Vector3Add(p0,Vector3ScalarMul(Vector3Norm(Vector3Sub(p1,p0)),-PlaneVectorDistance(Plane,p0)));
//Clipped:=Vector3Add(p0,Vector3ScalarMul(Vector3Sub(p1,p0),(-PlaneVectorDistance(Plane,p0))/Vector3Dot(Plane.Normal,Vector3Sub(p1,p0))));
end;

function PlaneClipSegmentClosest(const Plane:TPlane;var p0,p1,Clipped0,Clipped1:TVector3):longint; overload;
var d0,d1:single;
begin
 d0:=-PlaneVectorDistance(Plane,p0);
 d1:=-PlaneVectorDistance(Plane,p1);
 if (d0>(-EPSILON)) and (d1>(-EPSILON)) then begin
  if d0<d1 then begin
   result:=0;
   Clipped0:=p0;
   Clipped1:=p1;
  end else begin
   result:=1;
   Clipped0:=p1;
   Clipped1:=p0;
  end;
 end else if (d0<EPSILON) and (d1<EPSILON) then begin
  if d0>d1 then begin
   result:=2;
   Clipped0:=p0;
   Clipped1:=p1;
  end else begin
   result:=3;
   Clipped0:=p1;
   Clipped1:=p0;
  end;
 end else begin
  if d0<d1 then begin
   result:=4;
   Clipped1:=p0;
  end else begin
   result:=5;
   Clipped1:=p1;
  end;
  Clipped0:=Vector3Sub(p1,p0);
  Clipped0:=Vector3Add(p0,Vector3ScalarMul(Clipped0,(-d0)/Vector3Dot(Plane.Normal,Clipped0)));
 end;
end;

function ClipSegmentToPlane(const Plane:TPlane;var p0,p1:TVector3):boolean;
var d0,d1:single;
    o0,o1:boolean;
begin
 d0:=PlaneVectorDistance(Plane,p0);
 d1:=PlaneVectorDistance(Plane,p1);
 o0:=d0<0.0;
 o1:=d1<0.0;
 if o0 and o1 then begin
  // Both points are below which means that the whole line segment is below => return false
  result:=false;
 end else begin
  // At least one point is above or in the plane which means that the line segment is above => return true
  if (o0<>o1) and (abs(d0-d1)>EPSILON) then begin
   if o0 then begin
    // p1 is above or in the plane which means that the line segment is above => clip l0
    p0:=Vector3Add(p0,Vector3ScalarMul(Vector3Sub(p1,p0),d0/(d0-d1)));
   end else begin
    // p0 is above or in the plane which means that the line segment is above => clip l1
    p1:=Vector3Add(p0,Vector3ScalarMul(Vector3Sub(p1,p0),d0/(d0-d1)));
   end;
  end else begin
   // Near parallel case => no clipping
  end;
  result:=true;
 end;
end;

function ClipSegmentToPlane(const Plane:TPlane;var p0,p1:TSIMDVector3):boolean; overload;
var d0,d1:single;
    o0,o1:boolean;
begin
 d0:=PlaneVectorDistance(Plane,p0);
 d1:=PlaneVectorDistance(Plane,p1);
 o0:=d0<0.0;
 o1:=d1<0.0;
 if o0 and o1 then begin
  // Both points are below which means that the whole line segment is below => return false
  result:=false;
 end else begin
  // At least one point is above or in the plane which means that the line segment is above => return true
  if (o0<>o1) and (abs(d0-d1)>EPSILON) then begin
   if o0 then begin
    // p1 is above or in the plane which means that the line segment is above => clip l0
    p0:=SIMDVector3Add(p0,SIMDVector3ScalarMul(SIMDVector3Sub(p1,p0),d0/(d0-d1)));
   end else begin
    // p0 is above or in the plane which means that the line segment is above => clip l1
    p1:=SIMDVector3Add(p0,SIMDVector3ScalarMul(SIMDVector3Sub(p1,p0),d0/(d0-d1)));
   end;
  end else begin
   // Near parallel case => no clipping
  end;
  result:=true;
 end;
end;

function QuaternionNormal(const AQuaternion:TQuaternion):single; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [AQuaternion]
 mulps xmm0,xmm0
 movhlps xmm1,xmm0
 addps xmm0,xmm1
 pshufd xmm1,xmm0,$01
 addss xmm0,xmm1
 sqrtss xmm0,xmm0
 movss dword ptr [result],xmm0
end;
{$else}
begin
 result:=sqrt(sqr(AQuaternion.x)+sqr(AQuaternion.y)+sqr(AQuaternion.z)+sqr(AQuaternion.w));
end;
{$endif}
                            
function QuaternionLengthSquared(const AQuaternion:TQuaternion):single; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [AQuaternion]
 mulps xmm0,xmm0
 movhlps xmm1,xmm0
 addps xmm0,xmm1
 pshufd xmm1,xmm0,$01
 addss xmm0,xmm1
 movss dword ptr [result],xmm0
end;
{$else}
begin
 result:=sqr(AQuaternion.x)+sqr(AQuaternion.y)+sqr(AQuaternion.z)+sqr(AQuaternion.w);
end;
{$endif}

procedure QuaternionNormalize(var AQuaternion:TQuaternion); {$ifdef cpu386asm}assembler;
asm
{movups xmm2,dqword ptr [AQuaternion]
 movaps xmm0,xmm2
 mulps xmm0,xmm0
 movhlps xmm1,xmm0
 addps xmm0,xmm1
 pshufd xmm1,xmm0,$01
 addss xmm0,xmm1
 movss xmm3,xmm0
 xorps xmm1,xmm1
 cmpps xmm3,xmm1,4
 rsqrtss xmm0,xmm0
 andps xmm0,xmm3
 shufps xmm0,xmm0,$00
 mulps xmm2,xmm0
 movups dqword ptr [AQuaternion],xmm2}
 movups xmm2,dqword ptr [AQuaternion]
 movaps xmm0,xmm2
 mulps xmm0,xmm0
 movhlps xmm1,xmm0
 addps xmm0,xmm1
 pshufd xmm1,xmm0,$01
 addss xmm0,xmm1
 sqrtss xmm0,xmm0
 shufps xmm0,xmm0,$00
 divps xmm2,xmm0
 movups dqword ptr [AQuaternion],xmm2
end;
{$else}
var Normal:single;
begin
 Normal:=sqrt(sqr(AQuaternion.x)+sqr(AQuaternion.y)+sqr(AQuaternion.z)+sqr(AQuaternion.w));
 if abs(Normal)>1e-8 then begin
  Normal:=1.0/Normal;
 end;
 AQuaternion.x:=AQuaternion.x*Normal;
 AQuaternion.y:=AQuaternion.y*Normal;
 AQuaternion.z:=AQuaternion.z*Normal;
 AQuaternion.w:=AQuaternion.w*Normal;
end;
{$endif}

function QuaternionTermNormalize(const AQuaternion:TQuaternion):TQuaternion; {$ifdef cpu386asm}assembler;
asm
 movups xmm2,dqword ptr [AQuaternion]
 movaps xmm0,xmm2
 mulps xmm0,xmm0
 movhlps xmm1,xmm0
 addps xmm0,xmm1
 pshufd xmm1,xmm0,$01
 addss xmm0,xmm1
 sqrtss xmm0,xmm0
 shufps xmm0,xmm0,$00
 divps xmm2,xmm0
 movups dqword ptr [result],xmm2
end;
{$else}
var Normal:single;
begin
 Normal:=sqrt(sqr(AQuaternion.x)+sqr(AQuaternion.y)+sqr(AQuaternion.z)+sqr(AQuaternion.w));
 if abs(Normal)>1e-8 then begin
  Normal:=1.0/Normal;
 end;
 result.x:=AQuaternion.x*Normal;
 result.y:=AQuaternion.y*Normal;
 result.z:=AQuaternion.z*Normal;
 result.w:=AQuaternion.w*Normal;
end;
{$endif}

function QuaternionNeg(const AQuaternion:TQuaternion):TQuaternion; {$ifdef cpu386asm}assembler;
asm
 movups xmm1,dqword ptr [AQuaternion]
 xorps xmm0,xmm0
 subps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=-AQuaternion.x;
 result.y:=-AQuaternion.y;
 result.z:=-AQuaternion.z;
 result.w:=-AQuaternion.w;
end;
{$endif}

function QuaternionConjugate(const AQuaternion:TQuaternion):TQuaternion; {$ifdef cpu386asm}assembler;
const XORMask:array[0..3] of longword=($80000000,$80000000,$80000000,$00000000);
asm
 movups xmm0,dqword ptr [AQuaternion]
 movups xmm1,dqword ptr [XORMask]
 xorps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=-AQuaternion.x;
 result.y:=-AQuaternion.y;
 result.z:=-AQuaternion.z;
 result.w:=AQuaternion.w;
end;
{$endif}

function QuaternionInverse(const AQuaternion:TQuaternion):TQuaternion; {$ifdef cpu386asm}assembler;
const XORMask:array[0..3] of longword=($80000000,$80000000,$80000000,$00000000);
asm
 movups xmm2,dqword ptr [AQuaternion]
 movups xmm3,dqword ptr [XORMask]
 movaps xmm0,xmm2
 mulps xmm0,xmm0
 movhlps xmm1,xmm0
 addps xmm0,xmm1
 pshufd xmm1,xmm0,$01
 addss xmm0,xmm1
 sqrtss xmm0,xmm0
 shufps xmm0,xmm0,$00
 divps xmm2,xmm0
 xorps xmm2,xmm3
 movups dqword ptr [result],xmm2
end;
{$else}
var Normal:single;
begin
 Normal:=sqrt(sqr(AQuaternion.x)+sqr(AQuaternion.y)+sqr(AQuaternion.z)+sqr(AQuaternion.w));
 if abs(Normal)>1e-18 then begin
  Normal:=1.0/Normal;
 end;
 result.x:=-(AQuaternion.x*Normal);
 result.y:=-(AQuaternion.y*Normal);
 result.z:=-(AQuaternion.z*Normal);
 result.w:=(AQuaternion.w*Normal);
end;
{$endif}

function QuaternionAdd(const q1,q2:TQuaternion):TQuaternion; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [q1]
 movups xmm1,dqword ptr [q2]
 addps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=q1.x+q2.x;
 result.y:=q1.y+q2.y;
 result.z:=q1.z+q2.z;
 result.w:=q1.w+q2.w;
end;
{$endif}

function QuaternionSub(const q1,q2:TQuaternion):TQuaternion; {$ifdef cpu386asm}assembler;
asm
 movups xmm0,dqword ptr [q1]
 movups xmm1,dqword ptr [q2]
 subps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=q1.x-q2.x;
 result.y:=q1.y-q2.y;
 result.z:=q1.z-q2.z;
 result.w:=q1.w-q2.w;
end;
{$endif}

function QuaternionScalarMul(const q:TQuaternion;const s:single):TQuaternion; {$ifdef cpu386asm}assembler;
asm                    
 movups xmm0,dqword ptr [q]
 movss xmm1,dword ptr [s]
 shufps xmm1,xmm1,$00
 mulps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=q.x*s;
 result.y:=q.y*s;
 result.z:=q.z*s;
 result.w:=q.w*s;
end;
{$endif}

function QuaternionMul(const q1,q2:TQuaternion):TQuaternion; {$ifdef cpu386asm}assembler;
const XORMaskW:array[0..3] of longword=($00000000,$00000000,$00000000,$80000000);
asm
 movups xmm4,dqword ptr [q1]
 movaps xmm0,xmm4
 shufps xmm0,xmm4,$49
 movups xmm2,dqword ptr [q2]
 movaps xmm3,xmm2
 movaps xmm1,xmm2
 shufps xmm3,xmm2,$52 // 001010010b
 mulps xmm3,xmm0
 movaps xmm0,xmm4
 shufps xmm0,xmm4,$24 // 000100100b
 shufps xmm1,xmm2,$3f // 000111111b
 movups xmm5,dqword ptr [XORMaskW]
 mulps xmm1,xmm0
 movaps xmm0,xmm4
 shufps xmm0,xmm4,$92 // 001001001b
 shufps xmm4,xmm4,$ff // 011111111b
 mulps xmm4,xmm2
 addps xmm3,xmm1
 movaps xmm1,xmm2
 shufps xmm1,xmm2,$89 // 010001001b
 mulps xmm1,xmm0
 xorps xmm3,xmm5
 subps xmm4,xmm1
 addps xmm3,xmm4
 movups dqword ptr [result],xmm3
end;
{$else}
begin
 result.x:=((q1.w*q2.x)+(q1.x*q2.w)+(q1.y*q2.z))-(q1.z*q2.y);
 result.y:=((q1.w*q2.y)+(q1.y*q2.w)+(q1.z*q2.x))-(q1.x*q2.z);
 result.z:=((q1.w*q2.z)+(q1.z*q2.w)+(q1.x*q2.y))-(q1.y*q2.x);
 result.w:=(q1.w*q2.w)-((q1.x*q2.x)+(q1.y*q2.y)+(q1.z*q2.z));
end;
{$endif}

function QuaternionRotateAroundAxis(const q1,q2:TQuaternion):TQuaternion; {$ifdef caninline}inline;{$endif}
begin
 result.x:=((q1.x*q2.w)+(q1.z*q2.y))-(q1.y*q2.z);
 result.y:=((q1.x*q2.z)+(q1.y*q2.w))-(q1.z*q2.x);
 result.z:=((q1.y*q2.x)+(q1.z*q2.w))-(q1.x*q2.y);
 result.w:=((q1.x*q2.x)+(q1.y*q2.y))+(q1.z*q2.z);
end;

function QuaternionFromAxisAngle(const Axis:TVector3;Angle:single):TQuaternion; overload; {$ifdef caninline}inline;{$endif}
var sa2:single;
begin
 result.w:=cos(Angle*0.5);
 sa2:=sin(Angle*0.5);
 result.x:=Axis.x*sa2;
 result.y:=Axis.y*sa2;
 result.z:=Axis.z*sa2;
 QuaternionNormalize(result);
end;

function QuaternionFromSpherical(const Latitude,Longitude:single):TQuaternion; {$ifdef caninline}inline;{$endif}
begin
 result.x:=cos(Latitude)*sin(Longitude);
 result.y:=sin(Latitude);
 result.z:=cos(Latitude)*cos(Longitude);
 result.w:=0.0;
end;

procedure QuaternionToSpherical(const q:TQuaternion;var Latitude,Longitude:single);
var y:single;
begin
 y:=q.y;
 if y<-1.0 then begin
  y:=-1.0;
 end else if y>1.0 then begin
  y:=1.0;
 end;
 Latitude:=ArcSin(y);
 if (sqr(q.x)+sqr(q.z))>0.00005 then begin
  Longitude:=ArcTan2(q.x,q.z);
 end else begin
  Longitude:=0.0;
 end;
end;

function QuaternionFromAngles(const Pitch,Yaw,Roll:single):TQuaternion; overload; {$ifdef caninline}inline;{$endif}
var sp,sy,sr,cp,cy,cr:single;
begin
 sp:=sin(Pitch*0.5);
 sy:=sin(Yaw*0.5);
 sr:=sin(Roll*0.5);
 cp:=cos(Pitch*0.5);
 cy:=cos(Yaw*0.5);
 cr:=cos(Roll*0.5);
 result.x:=(sr*cp*cy)-(cr*sp*sy);
 result.y:=(cr*sp*cy)+(sr*cp*sy);
 result.z:=(cr*cp*sy)-(sr*sp*cy);
 result.w:=(cr*cp*cy)+(sr*sp*sy);
 QuaternionNormalize(result);
end;

function QuaternionFromAngles(const Angles:TVector3):TQuaternion; overload; {$ifdef caninline}inline;{$endif}
var sp,sy,sr,cp,cy,cr:single;
begin
 sp:=sin(Angles.Pitch*0.5);
 sy:=sin(Angles.Yaw*0.5);
 sr:=sin(Angles.Roll*0.5);
 cp:=cos(Angles.Pitch*0.5);
 cy:=cos(Angles.Yaw*0.5);
 cr:=cos(Angles.Roll*0.5);
 result.x:=(sr*cp*cy)-(cr*sp*sy);
 result.y:=(cr*sp*cy)+(sr*cp*sy);
 result.z:=(cr*cp*sy)-(sr*sp*cy);
 result.w:=(cr*cp*cy)+(sr*sp*sy);
 QuaternionNormalize(result);
end;

function QuaternionFromMatrix3x3(const AMatrix:TMatrix3x3):TQuaternion;
var t,s:single;
begin
 t:=AMatrix[0,0]+(AMatrix[1,1]+AMatrix[2,2]);
 if t>2.9999999 then begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
  result.w:=1.0;
 end else if t>0.0000001 then begin
  s:=sqrt(1.0+t)*2.0;
  result.x:=(AMatrix[1,2]-AMatrix[2,1])/s;
  result.y:=(AMatrix[2,0]-AMatrix[0,2])/s;
  result.z:=(AMatrix[0,1]-AMatrix[1,0])/s;
  result.w:=s*0.25;
 end else if (AMatrix[0,0]>AMatrix[1,1]) and (AMatrix[0,0]>AMatrix[2,2]) then begin
  s:=sqrt(1.0+(AMatrix[0,0]-(AMatrix[1,1]+AMatrix[2,2])))*2.0;
  result.x:=s*0.25;
  result.y:=(AMatrix[1,0]+AMatrix[0,1])/s;
  result.z:=(AMatrix[2,0]+AMatrix[0,2])/s;
  result.w:=(AMatrix[1,2]-AMatrix[2,1])/s;
 end else if AMatrix[1,1]>AMatrix[2,2] then begin
  s:=sqrt(1.0+(AMatrix[1,1]-(AMatrix[0,0]+AMatrix[2,2])))*2.0;
  result.x:=(AMatrix[1,0]+AMatrix[0,1])/s;
  result.y:=s*0.25;
  result.z:=(AMatrix[2,1]+AMatrix[1,2])/s;
  result.w:=(AMatrix[2,0]-AMatrix[0,2])/s;
 end else begin
  s:=sqrt(1.0+(AMatrix[2,2]-(AMatrix[0,0]+AMatrix[1,1])))*2.0;
  result.x:=(AMatrix[2,0]+AMatrix[0,2])/s;
  result.y:=(AMatrix[2,1]+AMatrix[1,2])/s;
  result.z:=s*0.25;
  result.w:=(AMatrix[0,1]-AMatrix[1,0])/s;
 end;
 QuaternionNormalize(result);
end;
{var xx,yx,zx,xy,yy,zy,xz,yz,zz,Trace,Radicand,Scale,TempX,TempY,TempZ,TempW:single;
    NegativeTrace,ZgtX,ZgtY,YgtX,LargestXorY,LargestYorZ,LargestZorX:boolean;
begin
 xx:=AMatrix[0,0];
 yx:=AMatrix[0,1];
 zx:=AMatrix[0,2];
 xy:=AMatrix[1,0];
 yy:=AMatrix[1,1];
 zy:=AMatrix[1,2];
 xz:=AMatrix[2,0];
 yz:=AMatrix[2,1];
 zz:=AMatrix[2,2];
 Trace:=(xx+yy)+zz;
 NegativeTrace:=Trace<0.0;
 ZgtX:=zz>xx;
 ZgtY:=zz>yy;
 YgtX:=yy>xx;
 LargestXorY:=NegativeTrace and ((not ZgtX) or not ZgtY);
 LargestYorZ:=NegativeTrace and (YgtX or ZgtX);
 LargestZorX:=NegativeTrace and (ZgtY or not YgtX);
 if LargestXorY then begin
  zz:=-zz;
  xy:=-xy;
 end;
 if LargestYorZ then begin
  xx:=-xx;
  yz:=-yz;
 end;
 if LargestZorX then begin
  yy:=-yy;
  zx:=-zx;
 end;
 Radicand:=((xx+yy)+zz)+1.0;
 Scale:=0.5/sqrt(Radicand);
 TempX:=(zy-yz)*Scale;
 TempY:=(xz-zx)*Scale;
 TempZ:=(yx-xy)*Scale;
 TempW:=Radicand*Scale;
 if LargestXorY then begin
  result.x:=TempW;
  result.y:=TempZ;
  result.z:=TempY;
  result.w:=TempX;
 end else begin
  result.x:=TempX;
  result.y:=TempY;
  result.z:=TempZ;
  result.w:=TempW;
 end;
 if LargestYorZ then begin
  TempX:=result.x;
  TempZ:=result.z;
  result.x:=result.y;
  result.y:=TempX;
  result.z:=result.w;
  result.w:=TempZ;
 end;
end;{}

function QuaternionToMatrix3x3(AQuaternion:TQuaternion):TMatrix3x3;
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:single;
begin
 QuaternionNormalize(AQuaternion);
 qx2:=AQuaternion.x+AQuaternion.x;
 qy2:=AQuaternion.y+AQuaternion.y;
 qz2:=AQuaternion.z+AQuaternion.z;
 qxqx2:=AQuaternion.x*qx2;
 qxqy2:=AQuaternion.x*qy2;
 qxqz2:=AQuaternion.x*qz2;
 qxqw2:=AQuaternion.w*qx2;
 qyqy2:=AQuaternion.y*qy2;
 qyqz2:=AQuaternion.y*qz2;
 qyqw2:=AQuaternion.w*qy2;
 qzqz2:=AQuaternion.z*qz2;
 qzqw2:=AQuaternion.w*qz2;
 result[0,0]:=1.0-(qyqy2+qzqz2);
 result[0,1]:=qxqy2+qzqw2;
 result[0,2]:=qxqz2-qyqw2;
 result[1,0]:=qxqy2-qzqw2;
 result[1,1]:=1.0-(qxqx2+qzqz2);
 result[1,2]:=qyqz2+qxqw2;
 result[2,0]:=qxqz2+qyqw2;
 result[2,1]:=qyqz2-qxqw2;
 result[2,2]:=1.0-(qxqx2+qyqy2);
end;

function QuaternionFromTangentSpaceMatrix3x3(AMatrix:TMatrix3x3):TQuaternion;
const Threshold=1.0/127.0;
var Scale,t,s,Renormalization:single;
begin
 if ((((((AMatrix[0,0]*AMatrix[1,1]*AMatrix[2,2])+
         (AMatrix[0,1]*AMatrix[1,2]*AMatrix[2,0])
        )+
        (AMatrix[0,2]*AMatrix[1,0]*AMatrix[2,1])
       )-
       (AMatrix[0,2]*AMatrix[1,1]*AMatrix[2,0])
      )-
      (AMatrix[0,1]*AMatrix[1,0]*AMatrix[2,2])
     )-
     (AMatrix[0,0]*AMatrix[1,2]*AMatrix[2,1])
    )<0.0 then begin
  // Reflection matrix, so flip y axis in case the tangent frame encodes a reflection
  Scale:=-1.0;
  AMatrix[2,0]:=-AMatrix[2,0];
  AMatrix[2,1]:=-AMatrix[2,1];
  AMatrix[2,2]:=-AMatrix[2,2];
 end else begin
  // Rotation matrix, so nothing is doing to do
  Scale:=1.0;
 end;
 begin
  // Convert to quaternion
  t:=AMatrix[0,0]+(AMatrix[1,1]+AMatrix[2,2]);
  if t>2.9999999 then begin
   result.x:=0.0;
   result.y:=0.0;
   result.z:=0.0;
   result.w:=1.0;
  end else if t>0.0000001 then begin
   s:=sqrt(1.0+t)*2.0;
   result.x:=(AMatrix[1,2]-AMatrix[2,1])/s;
   result.y:=(AMatrix[2,0]-AMatrix[0,2])/s;
   result.z:=(AMatrix[0,1]-AMatrix[1,0])/s;
   result.w:=s*0.25;
  end else if (AMatrix[0,0]>AMatrix[1,1]) and (AMatrix[0,0]>AMatrix[2,2]) then begin
   s:=sqrt(1.0+(AMatrix[0,0]-(AMatrix[1,1]+AMatrix[2,2])))*2.0;
   result.x:=s*0.25;
   result.y:=(AMatrix[1,0]+AMatrix[0,1])/s;
   result.z:=(AMatrix[2,0]+AMatrix[0,2])/s;
   result.w:=(AMatrix[1,2]-AMatrix[2,1])/s;
  end else if AMatrix[1,1]>AMatrix[2,2] then begin
   s:=sqrt(1.0+(AMatrix[1,1]-(AMatrix[0,0]+AMatrix[2,2])))*2.0;
   result.x:=(AMatrix[1,0]+AMatrix[0,1])/s;
   result.y:=s*0.25;
   result.z:=(AMatrix[2,1]+AMatrix[1,2])/s;
   result.w:=(AMatrix[2,0]-AMatrix[0,2])/s;
  end else begin
   s:=sqrt(1.0+(AMatrix[2,2]-(AMatrix[0,0]+AMatrix[1,1])))*2.0;
   result.x:=(AMatrix[2,0]+AMatrix[0,2])/s;
   result.y:=(AMatrix[2,1]+AMatrix[1,2])/s;
   result.z:=s*0.25;
   result.w:=(AMatrix[0,1]-AMatrix[1,0])/s;
  end;
  QuaternionNormalize(result);
 end;
 begin
  // Make sure, that we don't end up with 0 as w component
  if abs(result.w)<=Threshold then begin
   Renormalization:=sqrt(1.0-sqr(Threshold));
   result.x:=result.x*Renormalization;
   result.y:=result.y*Renormalization;
   result.z:=result.z*Renormalization;
   if result.w<0.0 then begin
    result.w:=-Threshold;
   end else begin
    result.w:=Threshold;
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

function QuaternionToTangentSpaceMatrix3x3(AQuaternion:TQuaternion):TMatrix3x3;
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:single;
begin
 QuaternionNormalize(AQuaternion);
 qx2:=AQuaternion.x+AQuaternion.x;
 qy2:=AQuaternion.y+AQuaternion.y;
 qz2:=AQuaternion.z+AQuaternion.z;
 qxqx2:=AQuaternion.x*qx2;
 qxqy2:=AQuaternion.x*qy2;
 qxqz2:=AQuaternion.x*qz2;
 qxqw2:=AQuaternion.w*qx2;
 qyqy2:=AQuaternion.y*qy2;
 qyqz2:=AQuaternion.y*qz2;
 qyqw2:=AQuaternion.w*qy2;
 qzqz2:=AQuaternion.z*qz2;
 qzqw2:=AQuaternion.w*qz2;
 result[0,0]:=1.0-(qyqy2+qzqz2);
 result[0,1]:=qxqy2+qzqw2;
 result[0,2]:=qxqz2-qyqw2;
 result[1,0]:=qxqy2-qzqw2;
 result[1,1]:=1.0-(qxqx2+qzqz2);
 result[1,2]:=qyqz2+qxqw2;
 result[2,0]:=qxqz2+qyqw2;
 result[2,1]:=qyqz2-qxqw2;
 result[2,2]:=1.0-(qxqx2+qyqy2);
 if AQuaternion.w<0.0 then begin
  result[2,0]:=-result[2,0];
  result[2,1]:=-result[2,1];
  result[2,2]:=-result[2,2];
 end;
end;

function QuaternionFromMatrix3x4(const AMatrix:TMatrix3x4):TQuaternion;
var t,s:single;
begin
 t:=AMatrix[0,0]+(AMatrix[1,1]+AMatrix[2,2]);
 if t>2.9999999 then begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
  result.w:=1.0;
 end else if t>0.0000001 then begin
  s:=sqrt(1.0+t)*2.0;
  result.x:=(AMatrix[1,2]-AMatrix[2,1])/s;
  result.y:=(AMatrix[2,0]-AMatrix[0,2])/s;
  result.z:=(AMatrix[0,1]-AMatrix[1,0])/s;
  result.w:=s*0.25;
 end else if (AMatrix[0,0]>AMatrix[1,1]) and (AMatrix[0,0]>AMatrix[2,2]) then begin
  s:=sqrt(1.0+(AMatrix[0,0]-(AMatrix[1,1]+AMatrix[2,2])))*2.0;
  result.x:=s*0.25;
  result.y:=(AMatrix[1,0]+AMatrix[0,1])/s;
  result.z:=(AMatrix[2,0]+AMatrix[0,2])/s;
  result.w:=(AMatrix[1,2]-AMatrix[2,1])/s;
 end else if AMatrix[1,1]>AMatrix[2,2] then begin
  s:=sqrt(1.0+(AMatrix[1,1]-(AMatrix[0,0]+AMatrix[2,2])))*2.0;
  result.x:=(AMatrix[1,0]+AMatrix[0,1])/s;
  result.y:=s*0.25;
  result.z:=(AMatrix[2,1]+AMatrix[1,2])/s;
  result.w:=(AMatrix[2,0]-AMatrix[0,2])/s;
 end else begin
  s:=sqrt(1.0+(AMatrix[2,2]-(AMatrix[0,0]+AMatrix[1,1])))*2.0;
  result.x:=(AMatrix[2,0]+AMatrix[0,2])/s;
  result.y:=(AMatrix[2,1]+AMatrix[1,2])/s;
  result.z:=s*0.25;
  result.w:=(AMatrix[0,1]-AMatrix[1,0])/s;
 end;
 QuaternionNormalize(result);
end;
{var xx,yx,zx,xy,yy,zy,xz,yz,zz,Trace,Radicand,Scale,TempX,TempY,TempZ,TempW:single;
    NegativeTrace,ZgtX,ZgtY,YgtX,LargestXorY,LargestYorZ,LargestZorX:boolean;
begin
 xx:=AMatrix[0,0];
 yx:=AMatrix[0,1];
 zx:=AMatrix[0,2];
 xy:=AMatrix[1,0];
 yy:=AMatrix[1,1];
 zy:=AMatrix[1,2];
 xz:=AMatrix[2,0];
 yz:=AMatrix[2,1];
 zz:=AMatrix[2,2];
 Trace:=(xx+yy)+zz;
 NegativeTrace:=Trace<0.0;
 ZgtX:=zz>xx;
 ZgtY:=zz>yy;
 YgtX:=yy>xx;
 LargestXorY:=NegativeTrace and ((not ZgtX) or not ZgtY);
 LargestYorZ:=NegativeTrace and (YgtX or ZgtX);
 LargestZorX:=NegativeTrace and (ZgtY or not YgtX);
 if LargestXorY then begin
  zz:=-zz;
  xy:=-xy;
 end;
 if LargestYorZ then begin
  xx:=-xx;
  yz:=-yz;
 end;
 if LargestZorX then begin
  yy:=-yy;
  zx:=-zx;
 end;
 Radicand:=((xx+yy)+zz)+1.0;
 Scale:=0.5/sqrt(Radicand);
 TempX:=(zy-yz)*Scale;
 TempY:=(xz-zx)*Scale;
 TempZ:=(yx-xy)*Scale;
 TempW:=Radicand*Scale;
 if LargestXorY then begin
  result.x:=TempW;
  result.y:=TempZ;
  result.z:=TempY;
  result.w:=TempX;
 end else begin
  result.x:=TempX;
  result.y:=TempY;
  result.z:=TempZ;
  result.w:=TempW;
 end;
 if LargestYorZ then begin
  TempX:=result.x;
  TempZ:=result.z;
  result.x:=result.y;
  result.y:=TempX;
  result.z:=result.w;
  result.w:=TempZ;
 end;
end;{}

function QuaternionToMatrix3x4(AQuaternion:TQuaternion):TMatrix3x4;
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:single;
begin
 QuaternionNormalize(AQuaternion);
 qx2:=AQuaternion.x+AQuaternion.x;
 qy2:=AQuaternion.y+AQuaternion.y;
 qz2:=AQuaternion.z+AQuaternion.z;
 qxqx2:=AQuaternion.x*qx2;
 qxqy2:=AQuaternion.x*qy2;
 qxqz2:=AQuaternion.x*qz2;
 qxqw2:=AQuaternion.w*qx2;
 qyqy2:=AQuaternion.y*qy2;
 qyqz2:=AQuaternion.y*qz2;
 qyqw2:=AQuaternion.w*qy2;
 qzqz2:=AQuaternion.z*qz2;
 qzqw2:=AQuaternion.w*qz2;
 result[0,0]:=1.0-(qyqy2+qzqz2);
 result[0,1]:=qxqy2+qzqw2;
 result[0,2]:=qxqz2-qyqw2;
 result[0,3]:=0.0;
 result[1,0]:=qxqy2-qzqw2;
 result[1,1]:=1.0-(qxqx2+qzqz2);
 result[1,2]:=qyqz2+qxqw2;
 result[1,3]:=0.0;
 result[2,0]:=qxqz2+qyqw2;
 result[2,1]:=qyqz2-qxqw2;
 result[2,2]:=1.0-(qxqx2+qyqy2);
 result[2,3]:=0.0;
end;

function QuaternionFromMatrix4x3(const AMatrix:TMatrix4x3):TQuaternion;
var t,s:single;
begin
 t:=AMatrix[0,0]+(AMatrix[1,1]+AMatrix[2,2]);
 if t>2.9999999 then begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
  result.w:=1.0;
 end else if t>0.0000001 then begin
  s:=sqrt(1.0+t)*2.0;
  result.x:=(AMatrix[1,2]-AMatrix[2,1])/s;
  result.y:=(AMatrix[2,0]-AMatrix[0,2])/s;
  result.z:=(AMatrix[0,1]-AMatrix[1,0])/s;
  result.w:=s*0.25;
 end else if (AMatrix[0,0]>AMatrix[1,1]) and (AMatrix[0,0]>AMatrix[2,2]) then begin
  s:=sqrt(1.0+(AMatrix[0,0]-(AMatrix[1,1]+AMatrix[2,2])))*2.0;
  result.x:=s*0.25;
  result.y:=(AMatrix[1,0]+AMatrix[0,1])/s;
  result.z:=(AMatrix[2,0]+AMatrix[0,2])/s;
  result.w:=(AMatrix[1,2]-AMatrix[2,1])/s;
 end else if AMatrix[1,1]>AMatrix[2,2] then begin
  s:=sqrt(1.0+(AMatrix[1,1]-(AMatrix[0,0]+AMatrix[2,2])))*2.0;
  result.x:=(AMatrix[1,0]+AMatrix[0,1])/s;
  result.y:=s*0.25;
  result.z:=(AMatrix[2,1]+AMatrix[1,2])/s;
  result.w:=(AMatrix[2,0]-AMatrix[0,2])/s;
 end else begin
  s:=sqrt(1.0+(AMatrix[2,2]-(AMatrix[0,0]+AMatrix[1,1])))*2.0;
  result.x:=(AMatrix[2,0]+AMatrix[0,2])/s;
  result.y:=(AMatrix[2,1]+AMatrix[1,2])/s;
  result.z:=s*0.25;
  result.w:=(AMatrix[0,1]-AMatrix[1,0])/s;
 end;
 QuaternionNormalize(result);
end;
{var xx,yx,zx,xy,yy,zy,xz,yz,zz,Trace,Radicand,Scale,TempX,TempY,TempZ,TempW:single;
    NegativeTrace,ZgtX,ZgtY,YgtX,LargestXorY,LargestYorZ,LargestZorX:boolean;
begin
 xx:=AMatrix[0,0];
 yx:=AMatrix[0,1];
 zx:=AMatrix[0,2];
 xy:=AMatrix[1,0];
 yy:=AMatrix[1,1];
 zy:=AMatrix[1,2];
 xz:=AMatrix[2,0];
 yz:=AMatrix[2,1];
 zz:=AMatrix[2,2];
 Trace:=(xx+yy)+zz;
 NegativeTrace:=Trace<0.0;
 ZgtX:=zz>xx;
 ZgtY:=zz>yy;
 YgtX:=yy>xx;
 LargestXorY:=NegativeTrace and ((not ZgtX) or not ZgtY);
 LargestYorZ:=NegativeTrace and (YgtX or ZgtX);
 LargestZorX:=NegativeTrace and (ZgtY or not YgtX);
 if LargestXorY then begin
  zz:=-zz;
  xy:=-xy;
 end;
 if LargestYorZ then begin
  xx:=-xx;
  yz:=-yz;
 end;
 if LargestZorX then begin
  yy:=-yy;
  zx:=-zx;
 end;
 Radicand:=((xx+yy)+zz)+1.0;
 Scale:=0.5/sqrt(Radicand);
 TempX:=(zy-yz)*Scale;
 TempY:=(xz-zx)*Scale;
 TempZ:=(yx-xy)*Scale;
 TempW:=Radicand*Scale;
 if LargestXorY then begin
  result.x:=TempW;
  result.y:=TempZ;
  result.z:=TempY;
  result.w:=TempX;
 end else begin
  result.x:=TempX;
  result.y:=TempY;
  result.z:=TempZ;
  result.w:=TempW;
 end;
 if LargestYorZ then begin
  TempX:=result.x;
  TempZ:=result.z;
  result.x:=result.y;
  result.y:=TempX;
  result.z:=result.w;
  result.w:=TempZ;
 end;
end;{}

function QuaternionToMatrix4x3(AQuaternion:TQuaternion):TMatrix4x3;
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:single;
begin
 QuaternionNormalize(AQuaternion);
 qx2:=AQuaternion.x+AQuaternion.x;
 qy2:=AQuaternion.y+AQuaternion.y;
 qz2:=AQuaternion.z+AQuaternion.z;
 qxqx2:=AQuaternion.x*qx2;
 qxqy2:=AQuaternion.x*qy2;
 qxqz2:=AQuaternion.x*qz2;
 qxqw2:=AQuaternion.w*qx2;
 qyqy2:=AQuaternion.y*qy2;
 qyqz2:=AQuaternion.y*qz2;
 qyqw2:=AQuaternion.w*qy2;
 qzqz2:=AQuaternion.z*qz2;
 qzqw2:=AQuaternion.w*qz2;
 result[0,0]:=1.0-(qyqy2+qzqz2);
 result[0,1]:=qxqy2+qzqw2;
 result[0,2]:=qxqz2-qyqw2;
 result[1,0]:=qxqy2-qzqw2;
 result[1,1]:=1.0-(qxqx2+qzqz2);
 result[1,2]:=qyqz2+qxqw2;
 result[2,0]:=qxqz2+qyqw2;
 result[2,1]:=qyqz2-qxqw2;
 result[2,2]:=1.0-(qxqx2+qyqy2);
 result[3,0]:=0.0;
 result[3,1]:=0.0;
 result[3,2]:=0.0;
end;

function QuaternionFromMatrix4x4(const AMatrix:TMatrix4x4):TQuaternion;
var t,s:single;
begin
 t:=AMatrix[0,0]+(AMatrix[1,1]+AMatrix[2,2]);
 if t>2.9999999 then begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
  result.w:=1.0;
 end else if t>0.0000001 then begin
  s:=sqrt(1.0+t)*2.0;
  result.x:=(AMatrix[1,2]-AMatrix[2,1])/s;
  result.y:=(AMatrix[2,0]-AMatrix[0,2])/s;
  result.z:=(AMatrix[0,1]-AMatrix[1,0])/s;
  result.w:=s*0.25;
 end else if (AMatrix[0,0]>AMatrix[1,1]) and (AMatrix[0,0]>AMatrix[2,2]) then begin
  s:=sqrt(1.0+(AMatrix[0,0]-(AMatrix[1,1]+AMatrix[2,2])))*2.0;
  result.x:=s*0.25;
  result.y:=(AMatrix[1,0]+AMatrix[0,1])/s;
  result.z:=(AMatrix[2,0]+AMatrix[0,2])/s;
  result.w:=(AMatrix[1,2]-AMatrix[2,1])/s;
 end else if AMatrix[1,1]>AMatrix[2,2] then begin
  s:=sqrt(1.0+(AMatrix[1,1]-(AMatrix[0,0]+AMatrix[2,2])))*2.0;
  result.x:=(AMatrix[1,0]+AMatrix[0,1])/s;
  result.y:=s*0.25;
  result.z:=(AMatrix[2,1]+AMatrix[1,2])/s;
  result.w:=(AMatrix[2,0]-AMatrix[0,2])/s;
 end else begin
  s:=sqrt(1.0+(AMatrix[2,2]-(AMatrix[0,0]+AMatrix[1,1])))*2.0;
  result.x:=(AMatrix[2,0]+AMatrix[0,2])/s;
  result.y:=(AMatrix[2,1]+AMatrix[1,2])/s;
  result.z:=s*0.25;
  result.w:=(AMatrix[0,1]-AMatrix[1,0])/s;
 end;
 QuaternionNormalize(result);
end;
{var xx,yx,zx,xy,yy,zy,xz,yz,zz,Trace,Radicand,Scale,TempX,TempY,TempZ,TempW:single;
    NegativeTrace,ZgtX,ZgtY,YgtX,LargestXorY,LargestYorZ,LargestZorX:boolean;
begin
 xx:=AMatrix[0,0];
 yx:=AMatrix[0,1];
 zx:=AMatrix[0,2];
 xy:=AMatrix[1,0];
 yy:=AMatrix[1,1];
 zy:=AMatrix[1,2];
 xz:=AMatrix[2,0];
 yz:=AMatrix[2,1];
 zz:=AMatrix[2,2];
 Trace:=(xx+yy)+zz;
 NegativeTrace:=Trace<0.0;
 ZgtX:=zz>xx;
 ZgtY:=zz>yy;
 YgtX:=yy>xx;
 LargestXorY:=NegativeTrace and ((not ZgtX) or not ZgtY);
 LargestYorZ:=NegativeTrace and (YgtX or ZgtX);
 LargestZorX:=NegativeTrace and (ZgtY or not YgtX);
 if LargestXorY then begin
  zz:=-zz;
  xy:=-xy;
 end;
 if LargestYorZ then begin
  xx:=-xx;
  yz:=-yz;
 end;
 if LargestZorX then begin
  yy:=-yy;
  zx:=-zx;
 end;
 Radicand:=((xx+yy)+zz)+1.0;
 Scale:=0.5/sqrt(Radicand);
 TempX:=(zy-yz)*Scale;
 TempY:=(xz-zx)*Scale;
 TempZ:=(yx-xy)*Scale;
 TempW:=Radicand*Scale;
 if LargestXorY then begin
  result.x:=TempW;
  result.y:=TempZ;
  result.z:=TempY;
  result.w:=TempX;
 end else begin
  result.x:=TempX;
  result.y:=TempY;
  result.z:=TempZ;
  result.w:=TempW;
 end;
 if LargestYorZ then begin
  TempX:=result.x;
  TempZ:=result.z;
  result.x:=result.y;
  result.y:=TempX;
  result.z:=result.w;
  result.w:=TempZ;
 end;
end;{}

function QuaternionToMatrix4x4(AQuaternion:TQuaternion):TMatrix4x4;
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:single;
begin
 QuaternionNormalize(AQuaternion);
 qx2:=AQuaternion.x+AQuaternion.x;
 qy2:=AQuaternion.y+AQuaternion.y;
 qz2:=AQuaternion.z+AQuaternion.z;
 qxqx2:=AQuaternion.x*qx2;
 qxqy2:=AQuaternion.x*qy2;
 qxqz2:=AQuaternion.x*qz2;
 qxqw2:=AQuaternion.w*qx2;
 qyqy2:=AQuaternion.y*qy2;
 qyqz2:=AQuaternion.y*qz2;
 qyqw2:=AQuaternion.w*qy2;
 qzqz2:=AQuaternion.z*qz2;
 qzqw2:=AQuaternion.w*qz2;
 result[0,0]:=1.0-(qyqy2+qzqz2);
 result[0,1]:=qxqy2+qzqw2;
 result[0,2]:=qxqz2-qyqw2;
 result[0,3]:=0.0;
 result[1,0]:=qxqy2-qzqw2;
 result[1,1]:=1.0-(qxqx2+qzqz2);
 result[1,2]:=qyqz2+qxqw2;
 result[1,3]:=0.0;
 result[2,0]:=qxqz2+qyqw2;
 result[2,1]:=qyqz2-qxqw2;
 result[2,2]:=1.0-(qxqx2+qyqy2);
 result[2,3]:=0.0;
 result[3,0]:=0.0;
 result[3,1]:=0.0;
 result[3,2]:=0.0;
 result[3,3]:=1.0;
end;

function QuaternionToAngles(const AQuaternion:TQuaternion):TVector3;
begin
 result:=Matrix3x3Angles(QuaternionToMatrix3x3(AQuaternion));
end;

function QuaternionToEuler(const AQuaternion:TQuaternion):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=ArcTan2(2.0*((AQuaternion.x*AQuaternion.y)+(AQuaternion.z*AQuaternion.w)),1.0-(2.0*(sqr(AQuaternion.y)+sqr(AQuaternion.z))));
 result.y:=ArcSin(2.0*((AQuaternion.x*AQuaternion.z)-(AQuaternion.y*AQuaternion.w)));
 result.z:=ArcTan2(2.0*((AQuaternion.x*AQuaternion.w)+(AQuaternion.y*AQuaternion.z)),1.0-(2.0*(sqr(AQuaternion.z)+sqr(AQuaternion.w))));
end;

procedure QuaternionToAxisAngle(AQuaternion:TQuaternion;var Axis:TVector3;var Angle:single); {$ifdef caninline}inline;{$endif}
var SinAngle:single;
begin
 QuaternionNormalize(AQuaternion);
 SinAngle:=sqrt(1.0-sqr(AQuaternion.w));
 if abs(SinAngle)<1e-12 then begin
  SinAngle:=1.0;
 end;
 Angle:=2.0*ArcCos(AQuaternion.w);
 Axis.x:=AQuaternion.x/SinAngle;
 Axis.y:=AQuaternion.y/SinAngle;
 Axis.z:=AQuaternion.z/SinAngle;
end;

function QuaternionGenerator(AQuaternion:TQuaternion):TVector3; {$ifdef caninline}inline;{$endif}
var s:single;
begin
 s:=sqrt(1.0-sqr(AQuaternion.w));
 result:=AQuaternion.Vector;
 if s>0.0 then begin
  result:=Vector3ScalarMul(result,s);
 end;
 result:=Vector3ScalarMul(result,2.0*ArcTan2(s,AQuaternion.w));
end;

function QuaternionLerp(const q1,q2:TQuaternion;const t:single):TQuaternion; {$ifdef caninline}inline;{$endif}
var it,sf:single;
begin
 if ((q1.x*q2.x)+(q1.y*q2.y)+(q1.z*q2.z)+(q1.w*q2.w))<0.0 then begin
  sf:=-1.0;
 end else begin
  sf:=1.0;
 end;
 it:=1.0-t;
 result.x:=(it*q1.x)+(t*(sf*q2.x));
 result.y:=(it*q1.y)+(t*(sf*q2.y));
 result.z:=(it*q1.z)+(t*(sf*q2.z));
 result.w:=(it*q1.w)+(t*(sf*q2.w));
end;

function QuaternionNlerp(const q1,q2:TQuaternion;const t:single):TQuaternion; {$ifdef caninline}inline;{$endif}
var it,sf:single;
begin
 if ((q1.x*q2.x)+(q1.y*q2.y)+(q1.z*q2.z)+(q1.w*q2.w))<0.0 then begin
  sf:=-1.0;
 end else begin
  sf:=1.0;
 end;
 it:=1.0-t;
 result.x:=(it*q1.x)+(t*(sf*q2.x));
 result.y:=(it*q1.y)+(t*(sf*q2.y));
 result.z:=(it*q1.z)+(t*(sf*q2.z));
 result.w:=(it*q1.w)+(t*(sf*q2.w));
 QuaternionNormalize(result);
end;

function QuaternionSlerp(const q1,q2:TQuaternion;const t:single):TQuaternion; {$ifdef caninline}inline;{$endif}
const EPSILON=1e-12;
var Omega,co,so,s0,s1,s2:single;
begin
 co:=(q1.x*q2.x)+(q1.y*q2.y)+(q1.z*q2.z)+(q1.w*q2.w);
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
 result.x:=(s0*q1.x)+(s1*(s2*q2.x));
 result.y:=(s0*q1.y)+(s1*(s2*q2.y));
 result.z:=(s0*q1.z)+(s1*(s2*q2.z));
 result.w:=(s0*q1.w)+(s1*(s2*q2.w));
end;

function QuaternionIntegrate(const q:TQuaternion;const Omega:TVector3;const DeltaTime:single):TQuaternion;
const EPSILON=1e-12;
var ThetaLenSquared,ThetaLen,s:single;
    DeltaQ:TQuaternion;
    Theta:TVector3;
begin
 Theta:=Vector3ScalarMul(Omega,DeltaTime*0.5);
 ThetaLenSquared:=Vector3LengthSquared(Theta);
 if (sqr(ThetaLenSquared)/24.0)<EPSILON then begin
  DeltaQ.w:=1.0-(ThetaLenSquared*0.5);
  s:=1.0-(ThetaLenSquared/6.0);
 end else begin
  ThetaLen:=sqrt(ThetaLenSquared);
  DeltaQ.w:=cos(ThetaLen);
  s:=sin(ThetaLen)/ThetaLen;
 end;
 DeltaQ.x:=Theta.x*s;
 DeltaQ.y:=Theta.y*s;
 DeltaQ.z:=Theta.z*s;
 result:=QuaternionMul(DeltaQ,q);
end;

function QuaternionSpin(const q:TQuaternion;const Omega:TVector3;const DeltaTime:single):TQuaternion; overload;
var wq:TQuaternion;
begin
 wq.x:=Omega.x*DeltaTime;
 wq.y:=Omega.y*DeltaTime;
 wq.z:=Omega.z*DeltaTime;
 wq.w:=0.0;
 result:=QuaternionTermNormalize(QuaternionAdd(q,QuaternionScalarMul(QuaternionMul(wq,q),0.5)));
end;

function QuaternionSpin(const q:TQuaternion;const Omega:TSIMDVector3;const DeltaTime:single):TQuaternion; overload;
var wq:TQuaternion;
begin
 wq.x:=Omega.x*DeltaTime;
 wq.y:=Omega.y*DeltaTime;
 wq.z:=Omega.z*DeltaTime;
 wq.w:=0.0;
 result:=QuaternionTermNormalize(QuaternionAdd(q,QuaternionScalarMul(QuaternionMul(wq,q),0.5)));
end;

procedure QuaternionDirectSpin(var q:TQuaternion;const Omega:TVector3;const DeltaTime:single); overload;
var wq,tq:TQuaternion;
begin
 wq.x:=Omega.x*DeltaTime;
 wq.y:=Omega.y*DeltaTime;
 wq.z:=Omega.z*DeltaTime;
 wq.w:=0.0;
 tq:=QuaternionAdd(q,QuaternionScalarMul(QuaternionMul(wq,q),0.5));
 q:=QuaternionTermNormalize(tq);
end;

procedure QuaternionDirectSpin(var q:TQuaternion;const Omega:TSIMDVector3;const DeltaTime:single); overload;
var wq,tq:TQuaternion;
begin
 wq.x:=Omega.x*DeltaTime;
 wq.y:=Omega.y*DeltaTime;
 wq.z:=Omega.z*DeltaTime;
 wq.w:=0.0;
 tq:=QuaternionAdd(q,QuaternionScalarMul(QuaternionMul(wq,q),0.5));
 q:=QuaternionTermNormalize(tq);
end;

function QuaternionFromToRotation(const FromDirection,ToDirection:TVector3):TQuaternion; {$ifdef caninline}inline;{$endif}
begin
 result.Vector:=Vector3Cross(FromDirection,ToDirection);
 result.Scalar:=sqrt((sqr(FromDirection.x)+sqr(FromDirection.y)+sqr(FromDirection.z))*
                     (sqr(ToDirection.x)+sqr(ToDirection.y)+sqr(ToDirection.z)))+
                ((FromDirection.x*ToDirection.x)+(FromDirection.y*ToDirection.y)+(FromDirection.z*ToDirection.z));
end;

function SphereCoordsFromCartesianVector3(const v:TVector3):TSphereCoords; {$ifdef caninline}inline;{$endif}
begin
 result.Radius:=Vector3Length(v);
 result.Theta:=ArcCos(v.z/result.Radius);
 result.Phi:=GetSign(v.y)*ArcCos(v.x/sqrt(v.x*v.x+v.y*v.y));
end;

function SphereCoordsFromCartesianVector4(const v:TVector4):TSphereCoords; {$ifdef caninline}inline;{$endif}
begin
 result.Radius:=Vector4Length(v);
 result.Theta:=ArcCos(v.z/result.Radius);
 result.Phi:=GetSign(v.y)*ArcCos(v.x/sqrt(v.x*v.x+v.y*v.y));
end;

function SphereCoordsToCartesianVector3(const s:TSphereCoords):TVector3; {$ifdef caninline}inline;{$endif}
begin
 result.x:=s.Radius*sin(s.Theta)*cos(s.Phi);
 result.y:=s.Radius*sin(s.Theta)*sin(s.Phi);
 result.z:=s.Radius*cos(s.Theta);
end;

function SphereCoordsToCartesianVector4(const s:TSphereCoords):TVector4; {$ifdef caninline}inline;{$endif}
begin
 result.x:=s.Radius*sin(s.Theta)*cos(s.Phi);
 result.y:=s.Radius*sin(s.Theta)*sin(s.Phi);
 result.z:=s.Radius*cos(s.Theta);
 result.w:=1.0;
end;

function CullSphere(const s:TSphere;const p:array of TPlane):boolean; //{$ifdef caninline}inline;{$endif}
var i:longint;
begin
 result:=true;
 for i:=0 to length(p)-1 do begin
  if PlaneVectorDistance(p[i],s.Center)<-s.Radius then begin
   result:=false;
   exit;
  end;
 end;
end;

function SphereContains(const a,b:TSphere):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=(a.Radius>=b.Radius) and (Vector3Length(Vector3Sub(a.Center,b.Center))<=(a.Radius-b.Radius));
end;

function SphereContains(const a:TSphere;const v:TVector3):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=Vector3Dist(a.Center,v)<a.Radius;
end;

function SphereContainsEx(const a,b:TSphere):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=((a.Radius+EPSILON)>=(b.Radius-EPSILON)) and (Vector3Length(Vector3Sub(a.Center,b.Center))<=((a.Radius+EPSILON)-(b.Radius-EPSILON)));
end;

function SphereContainsEx(const a:TSphere;const v:TVector3):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=Vector3Dist(a.Center,v)<(a.Radius+EPSILON);
end;

function SphereDistance(const a,b:TSphere):single; {$ifdef caninline}inline;{$endif}
begin
 result:=max(Vector3Length(Vector3Sub(a.Center,b.Center))-(a.Radius+b.Radius),0.0);
end;

function SphereDistance(const a:TSphere;const v:TVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=max(Vector3Dist(a.Center,v)-a.Radius,0.0);
end;

function SphereIntersect(const a,b:TSphere):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=Vector3Length(Vector3Sub(a.Center,b.Center))<=(a.Radius+b.Radius);
end;

function SphereIntersectEx(const a,b:TSphere;Threshold:single=SPHEREEPSILON):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=Vector3Length(Vector3Sub(a.Center,b.Center))<=(a.Radius+b.Radius+(Threshold*2));
end;

function SphereRayIntersect(var s:TSphere;const Origin,Direction:TVector3):boolean; {$ifdef caninline}inline;{$endif}
var m:TVector3;
    p,d:single;
begin
 m:=Vector3Sub(Origin,s.Center);
 p:=-Vector3Dot(m,Direction);
 d:=(sqr(p)-Vector3LengthSquared(m))+sqr(s.Radius);
 result:=(d>0.0) and ((p+sqrt(d))>0.0);
end;

function SphereFromAABB(const AABB:TAABB):TSphere; {$ifdef caninline}inline;{$endif}
begin
 result.Center:=Vector3Avg(AABB.Min,AABB.Max);
 result.Radius:=Vector3Dist(AABB.Min,AABB.Max)*0.5125;
end;

function SphereFromFrustum(zNear,zFar,FOV,AspectRatio:single;Position,Direction:TVector3):TSphere; {$ifdef caninline}inline;{$endif}
var ViewLen,Width,Height:single;
begin
 ViewLen:=zFar-zNear;
 Height:=ViewLen*tan((FOV*0.5)*DEG2RAD);
 Width:=Height*AspectRatio;
 result.Radius:=Vector3Dist(Vector3(Width,Height,ViewLen),Vector3(0.0,0.0,zNear+(ViewLen*0.5)));
 result.Center:=Vector3Add(Position,Vector3ScalarMul(Direction,(ViewLen*0.5)+zNear));
end;

function SphereExtend(const Sphere,WithSphere:TSphere):TSphere; {$ifdef caninline}inline;{$endif}
var x0,y0,z0,r0,x1,y1,z1,r1,xn,yn,zn,dn,t:single;
begin
 x0:=Sphere.Center.x;
 y0:=Sphere.Center.y;
 z0:=Sphere.Center.z;
 r0:=Sphere.Radius;

 x1:=WithSphere.Center.x;
 y1:=WithSphere.Center.y;
 z1:=WithSphere.Center.z;
 r1:=WithSphere.Radius;

 xn:=x1-x0;
 yn:=y1-y0;
 zn:=z1-z0;
 dn:=sqrt(sqr(xn)+sqr(yn)+sqr(zn));
 if abs(dn)<EPSILON then begin
  result:=Sphere;
  exit;
 end;

 if (dn+r1)<r0 then begin
  result:=Sphere;
  exit;
 end;

 result.Radius:=(dn+r0+r1)*0.5;
 t:=(result.Radius-r0)/dn;
 result.Center.x:=x0+(xn*t);
 result.Center.y:=y0+(xn*t);
 result.Center.z:=z0+(xn*t);
end;

function SphereTransform(const Sphere:TSphere;const Transform:TMatrix4x4):TSphere; {$ifdef caninline}inline;{$endif}
begin
 result.Center:=Vector3TermMatrixMul(Sphere.Center,Transform);
 result.Radius:=Vector3Dist(Vector3TermMatrixMul(Vector3(Sphere.Center.x,Sphere.Center.y+Sphere.Radius,Sphere.Center.z),Transform),result.Center);
end;

function SphereTriangleIntersection(const Sphere:TSphere;const TriangleVertex0,TriangleVertex1,TriangleVertex2,TriangleNormal:TVector3;out Position,Normal:TVector3;out Depth:single):boolean;
var SegmentTriangle:TSegmentTriangle;
    Dist,d2,s,t:single;
begin
 result:=false;
 if ((Vector3Dot(TriangleNormal,Sphere.Center)-Vector3Dot(TriangleNormal,TriangleVertex0))-Sphere.Radius)<EPSILON then begin
  SegmentTriangle.Origin:=TriangleVertex0;
  SegmentTriangle.Edge0:=Vector3Sub(TriangleVertex1,TriangleVertex0);
  SegmentTriangle.Edge1:=Vector3Sub(TriangleVertex2,TriangleVertex0);
  SegmentTriangle.Edge2:=Vector3Sub(SegmentTriangle.Edge1,SegmentTriangle.Edge0);
  d2:=PointTriangleDistanceSq(s,t,Sphere.Center,SegmentTriangle);
  if d2<sqr(Sphere.Radius) then begin
   Dist:=sqrt(d2);
   Depth:=Sphere.Radius-Dist;
   if Dist>EPSILON then begin
    Normal:=Vector3Norm(Vector3Sub(Sphere.Center,Vector3Add(SegmentTriangle.Origin,Vector3Add(Vector3ScalarMul(SegmentTriangle.Edge0,s),Vector3ScalarMul(SegmentTriangle.Edge1,t)))));
   end else begin
    Normal:=TriangleNormal;
   end;
   Position:=Vector3Sub(Sphere.Center,Vector3ScalarMul(Normal,Sphere.Radius));
   result:=true;
  end;
 end;
end;

function SphereTriangleIntersection(const Sphere:TSphere;const SegmentTriangle:TSegmentTriangle;const TriangleNormal:TVector3;out Position,Normal:TVector3;out Depth:single):boolean; overload;
var Dist,d2,s,t:single;
begin
 result:=false;
 d2:=PointTriangleDistanceSq(s,t,Sphere.Center,SegmentTriangle);
 if d2<sqr(Sphere.Radius) then begin
  Dist:=sqrt(d2);
  Depth:=Sphere.Radius-Dist;
  if Dist>EPSILON then begin
   Normal:=Vector3Norm(Vector3Sub(Sphere.Center,Vector3Add(SegmentTriangle.Origin,Vector3Add(Vector3ScalarMul(SegmentTriangle.Edge0,s),Vector3ScalarMul(SegmentTriangle.Edge1,t)))));
  end else begin
   Normal:=TriangleNormal;
  end;
  Position:=Vector3Sub(Sphere.Center,Vector3ScalarMul(Normal,Sphere.Radius));
  result:=true;
 end;
end;

function SweptSphereIntersection(const SphereA,SphereB:TSphere;const VelocityA,VelocityB:TVector3;out TimeFirst,TimeLast:single):boolean; {$ifdef caninline}inline;{$endif}
var ab,vab:TVector3;
    rab,a,b,c:single;
begin
 result:=false;
 ab:=Vector3Sub(SphereB.Center,SphereA.Center);
 vab:=Vector3Sub(VelocityB,VelocityA);
 rab:=SphereA.Radius+SphereB.Radius;
 c:=Vector3LengthSquared(ab)-sqr(rab);
 if c<=0.0 then begin
  TimeFirst:=0.0;
  TimeLast:=0.0;
  result:=true;
 end else begin
  a:=Vector3LengthSquared(vab);
  b:=2.0*Vector3Dot(vab,ab);
  if SolveQuadraticRoots(a,b,c,TimeFirst,TimeLast) then begin
   if TimeFirst>TimeLast then begin
    a:=TimeFirst;
    TimeFirst:=TimeLast;
    TimeLast:=a;
   end;
   result:=(TimeLast>=0.0) and (TimeFirst<=1.0);
  end;
 end;
end;

function AABBCost(const AABB:TAABB):single; {$ifdef caninline}inline;{$endif}
begin
// result:=(AABB.Max.x-AABB.Min.x)+(AABB.Max.y-AABB.Min.y)+(AABB.Max.z-AABB.Min.z); // Manhattan distance
 result:=(AABB.Max.x-AABB.Min.x)*(AABB.Max.y-AABB.Min.y)*(AABB.Max.z-AABB.Min.z); // Volume
end;

function AABBVolume(const AABB:TAABB):single; {$ifdef caninline}inline;{$endif}
begin
 result:=(AABB.Max.x-AABB.Min.x)*(AABB.Max.y-AABB.Min.y)*(AABB.Max.z-AABB.Min.z);
end;

function AABBArea(const AABB:TAABB):single; {$ifdef caninline}inline;{$endif}
begin
 result:=2.0*((abs(AABB.Max.x-AABB.Min.x)*abs(AABB.Max.y-AABB.Min.y))+
              (abs(AABB.Max.y-AABB.Min.y)*abs(AABB.Max.z-AABB.Min.z))+
              (abs(AABB.Max.x-AABB.Min.x)*abs(AABB.Max.z-AABB.Min.z)));
end;

function AABBFlip(const AABB:TAABB):TAABB;
var a,b:TVector3;
begin      
 a:=Vector3Flip(AABB.Min);
 b:=Vector3Flip(AABB.Max);
 result.Min.x:=min(a.x,b.x);
 result.Min.y:=min(a.y,b.y);
 result.Min.z:=min(a.z,b.z);
 result.Max.x:=max(a.x,b.x);
 result.Max.y:=max(a.y,b.y);
 result.Max.z:=max(a.z,b.z);
end;

function AABBFromSphere(const Sphere:TSphere;const Scale:single=1.0):TAABB;
begin
 result.Min.x:=Sphere.Center.x-(Sphere.Radius*Scale);
 result.Min.y:=Sphere.Center.y-(Sphere.Radius*Scale);
 result.Min.z:=Sphere.Center.z-(Sphere.Radius*Scale);
 result.Max.x:=Sphere.Center.x+(Sphere.Radius*Scale);
 result.Max.y:=Sphere.Center.y+(Sphere.Radius*Scale);
 result.Max.z:=Sphere.Center.z+(Sphere.Radius*Scale);
end;

function AABBFromOBB(const OBB:TOBB):TAABB;
var t:TVector3;
begin
 t.x:=abs((OBB.Matrix[0,0]*OBB.Extents.x)+(OBB.Matrix[1,0]*OBB.Extents.y)+(OBB.Matrix[2,0]*OBB.Extents.z));
 t.y:=abs((OBB.Matrix[0,1]*OBB.Extents.x)+(OBB.Matrix[1,1]*OBB.Extents.y)+(OBB.Matrix[2,1]*OBB.Extents.z));
 t.z:=abs((OBB.Matrix[0,2]*OBB.Extents.x)+(OBB.Matrix[1,2]*OBB.Extents.y)+(OBB.Matrix[2,2]*OBB.Extents.z));
 result.Min.x:=OBB.Center.x-t.x;
 result.Min.y:=OBB.Center.y-t.y;
 result.Min.z:=OBB.Center.z-t.z;
 result.Max.x:=OBB.Center.x+t.x;
 result.Max.y:=OBB.Center.y+t.y;
 result.Max.z:=OBB.Center.z+t.z;
end;

function AABBFromOBBEx(const OBB:TOBB):TAABB;
var t:TAABB;
   a:TVector3;
    i:longint;
begin
 t.Min.x:=-OBB.Extents.x;
 t.Min.y:=-OBB.Extents.y;
 t.Min.z:=-OBB.Extents.z;
 t.Max.x:=OBB.Extents.x;
 t.Max.y:=OBB.Extents.y;
 t.Max.z:=OBB.Extents.z;
 for i:=0 to 7 do begin
  a.x:=t.MinMax[(i shr 0) and 1].x;
  a.y:=t.MinMax[(i shr 1) and 1].y;
  a.z:=t.MinMax[(i shr 2) and 1].z;
  Vector3MatrixMul(a,OBB.Matrix);
  if i=0 then begin
   result.Min:=a;
   result.Max:=a;
  end else begin
   result.Min.x:=Min(result.Min.x,a.x);
   result.Min.y:=Min(result.Min.y,a.y);
   result.Min.z:=Min(result.Min.z,a.z);
   result.Max.x:=Max(result.Max.x,a.x);
   result.Max.y:=Max(result.Max.y,a.y);
   result.Max.z:=Max(result.Max.z,a.z);
  end;
 end;
 result.Min.x:=OBB.Center.x+result.Min.x;
 result.Min.y:=OBB.Center.y+result.Min.y;
 result.Min.z:=OBB.Center.z+result.Min.z;
 result.Max.x:=OBB.Center.x+result.Max.x;
 result.Max.y:=OBB.Center.y+result.Max.y;
 result.Max.z:=OBB.Center.z+result.Max.z;
end;

function AABBSquareMagnitude(const AABB:TAABB):single; {$ifdef caninline}inline;{$endif}
begin
 result:=sqr(AABB.Max.x-AABB.Min.x)+(AABB.Max.y-AABB.Min.y)+sqr(AABB.Max.z-AABB.Min.z);
end;

function AABBResize(const AABB:TAABB;f:single):TAABB; {$ifdef caninline}inline;{$endif}
var v:TVector3;
begin
 v:=Vector3ScalarMul(Vector3Sub(AABB.Max,AABB.Min),f);
 result.Min:=Vector3Sub(AABB.Min,v);
 result.Max:=Vector3Add(AABB.Max,v);
end;

function AABBCombine(const AABB,WithAABB:TAABB):TAABB; {$ifdef caninline}inline;{$endif}
begin
 result.Min.x:=Min(AABB.Min.x,WithAABB.Min.x);
 result.Min.y:=Min(AABB.Min.y,WithAABB.Min.y);
 result.Min.z:=Min(AABB.Min.z,WithAABB.Min.z);
 result.Max.x:=Max(AABB.Max.x,WithAABB.Max.x);
 result.Max.y:=Max(AABB.Max.y,WithAABB.Max.y);
 result.Max.z:=Max(AABB.Max.z,WithAABB.Max.z);
end;

function AABBCombineVector3(const AABB:TAABB;v:TVector3):TAABB; {$ifdef caninline}inline;{$endif}
begin
 result.Min.x:=Min(AABB.Min.x,v.x);
 result.Min.y:=Min(AABB.Min.y,v.y);
 result.Min.z:=Min(AABB.Min.z,v.z);
 result.Max.x:=Max(AABB.Max.x,v.x);
 result.Max.y:=Max(AABB.Max.y,v.y);
 result.Max.z:=Max(AABB.Max.z,v.z);
end;

function AABBDistance(const AABB,WithAABB:TAABB):single; {$ifdef caninline}inline;{$endif}
begin
 result:=0;
 if AABB.Min.x>WithAABB.Max.x then begin
  result:=result+sqr(WithAABB.Max.x-AABB.Min.x);
 end else if WithAABB.Min.x>AABB.Max.x then begin
  result:=result+sqr(AABB.Max.x-WithAABB.Min.x);
 end;
 if AABB.Min.y>WithAABB.Max.y then begin
  result:=result+sqr(WithAABB.Max.y-AABB.Min.y);
 end else if WithAABB.Min.y>AABB.Max.y then begin
  result:=result+sqr(AABB.Max.y-WithAABB.Min.y);
 end;
 if AABB.Min.z>WithAABB.Max.z then begin
  result:=result+sqr(WithAABB.Max.z-AABB.Min.z);
 end else if WithAABB.Min.z>AABB.Max.z then begin
  result:=result+sqr(AABB.Max.z-WithAABB.Min.z);
 end;
 if result>0.0 then begin
  result:=sqrt(result);
 end;
end;

function AABBRadius(const AABB:TAABB):single; {$ifdef caninline}inline;{$endif}
begin
 result:=max(Vector3Dist(AABB.Min,Vector3Avg(AABB.Min,AABB.Max)),Vector3Dist(AABB.Max,Vector3Avg(AABB.Min,AABB.Max)));
end;

(*function AABBDistance(const AABB,WithAABB:TAABB):single; {$ifdef caninline}inline;{$endif}
var ca,cb,ea,eb:TVector3;
begin
 ca:=Vector3Avg(AABB.Min,AABB.Max);
 cb:=Vector3Avg(WithAABB.Min,WithAABB.Max);
 ea:=Vector3Sub(AABB.Max,ca);
 eb:=Vector3Sub(WithAABB.Max,cb);
 result:=Vector3Length(Vector3Sub(Vector3Sub(cb,ca),Vector3Add(ea,eb)));
end;*)

function AABBCompare(const AABB,WithAABB:TAABB):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=Vector3Compare(AABB.Min,WithAABB.Min) and Vector3Compare(AABB.Max,WithAABB.Max);
end;

function AABBIntersect(const AABB,WithAABB:TAABB):boolean; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=((AABB.Max.x>=WithAABB.Min.x) and (AABB.Min.x<=WithAABB.Max.x)) and
         ((AABB.Max.y>=WithAABB.Min.y) and (AABB.Min.y<=WithAABB.Max.y)) and
         ((AABB.Max.z>=WithAABB.Min.z) and (AABB.Min.z<=WithAABB.Max.z));
end;

function AABBIntersectEx(const AABB,WithAABB:TAABB;Threshold:single=AABBEPSILON):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=(((AABB.Max.x+Threshold)>=(WithAABB.Min.x-Threshold)) and ((AABB.Min.x-Threshold)<=(WithAABB.Max.x+Threshold))) and
         (((AABB.Max.y+Threshold)>=(WithAABB.Min.y-Threshold)) and ((AABB.Min.y-Threshold)<=(WithAABB.Max.y+Threshold))) and
         (((AABB.Max.z+Threshold)>=(WithAABB.Min.z-Threshold)) and ((AABB.Min.z-Threshold)<=(WithAABB.Max.z+Threshold)));
end;

function AABBIntersect(const AABB:TAABB;const Sphere:TSphere):boolean; overload; {$ifdef caninline}inline;{$endif}
var c:TVector3;
begin
 c.x:=Min(Max(Sphere.Center.x,AABB.Min.x),AABB.Max.x);
 c.y:=Min(Max(Sphere.Center.y,AABB.Min.y),AABB.Max.y);
 c.z:=Min(Max(Sphere.Center.z,AABB.Min.z),AABB.Max.z);
 result:=Vector3LengthSquared(Vector3Sub(c,Sphere.Center))<sqr(Sphere.Radius);
end;
{var d:single;
begin
 d:=0.0;
 if Sphere.Center.x<AABB.Min.x then begin
  d:=d+sqr(Sphere.Center.x-AABB.Min.x);
 end else if Sphere.Center.x>AABB.Max.x then begin
  d:=d+sqr(Sphere.Center.x-AABB.Max.x);
 end;
 if Sphere.Center.y<AABB.Min.y then begin
  d:=d+sqr(Sphere.Center.y-AABB.Min.y);
 end else if Sphere.Center.y>AABB.Max.y then begin
  d:=d+sqr(Sphere.Center.y-AABB.Max.y);
 end;
 if Sphere.Center.z<AABB.Min.z then begin
  d:=d+sqr(Sphere.Center.z-AABB.Min.z);
 end else if Sphere.Center.z>AABB.Max.z then begin
  d:=d+sqr(Sphere.Center.z-AABB.Max.z);
 end;
 result:=d<sqr(Sphere.Radius);
end;}

function AABBContains(const InAABB,AABB:TAABB):boolean; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=(InAABB.Min.x<=AABB.Min.x) and (InAABB.Min.y<=AABB.Min.y) and (InAABB.Min.z<=AABB.Min.z) and
         (InAABB.Max.x>=AABB.Min.x) and (InAABB.Max.y>=AABB.Min.y) and (InAABB.Max.z>=AABB.Min.z) and
         (InAABB.Min.x<=AABB.Max.x) and (InAABB.Min.y<=AABB.Max.y) and (InAABB.Min.z<=AABB.Max.z) and
         (InAABB.Max.x>=AABB.Max.x) and (InAABB.Max.y>=AABB.Max.y) and (InAABB.Max.z>=AABB.Max.z);
end;

function AABBContains(const AABB:TAABB;Vector:TVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=((Vector.x>=AABB.Min.x) and (Vector.x<=AABB.Max.x)) and
         ((Vector.y>=AABB.Min.y) and (Vector.y<=AABB.Max.y)) and
         ((Vector.z>=AABB.Min.z) and (Vector.z<=AABB.Max.z));
end;

function AABBContainsEx(const InAABB,AABB:TAABB):boolean; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=((InAABB.Min.x-AABBEPSILON)<=(AABB.Min.x+AABBEPSILON)) and ((InAABB.Min.y-AABBEPSILON)<=(AABB.Min.y+AABBEPSILON)) and ((InAABB.Min.z-AABBEPSILON)<=(AABB.Min.z+AABBEPSILON)) and
         ((InAABB.Max.x+AABBEPSILON)>=(AABB.Min.x+AABBEPSILON)) and ((InAABB.Max.y+AABBEPSILON)>=(AABB.Min.y+AABBEPSILON)) and ((InAABB.Max.z+AABBEPSILON)>=(AABB.Min.z+AABBEPSILON)) and
         ((InAABB.Min.x-AABBEPSILON)<=(AABB.Max.x-AABBEPSILON)) and ((InAABB.Min.y-AABBEPSILON)<=(AABB.Max.y-AABBEPSILON)) and ((InAABB.Min.z-AABBEPSILON)<=(AABB.Max.z-AABBEPSILON)) and
         ((InAABB.Max.x+AABBEPSILON)>=(AABB.Max.x-AABBEPSILON)) and ((InAABB.Max.y+AABBEPSILON)>=(AABB.Max.y-AABBEPSILON)) and ((InAABB.Max.z+AABBEPSILON)>=(AABB.Max.z-AABBEPSILON));
end;

function AABBContainsEx(const AABB:TAABB;Vector:TVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=((Vector.x>=(AABB.Min.x-AABBEPSILON)) and (Vector.x<=(AABB.Max.x+AABBEPSILON))) and
         ((Vector.y>=(AABB.Min.y-AABBEPSILON)) and (Vector.y<=(AABB.Max.y+AABBEPSILON))) and
         ((Vector.z>=(AABB.Min.z-AABBEPSILON)) and (Vector.z<=(AABB.Max.z+AABBEPSILON)));
end;

function AABBTouched(const AABB:TAABB;Vector:TVector3;Threshold:single):boolean; {$ifdef caninline}inline;{$endif}
begin
 result:=((Vector.x>=(AABB.Min.x-Threshold)) and (Vector.x<=(AABB.Max.x+Threshold))) and
         ((Vector.y>=(AABB.Min.y-Threshold)) and (Vector.y<=(AABB.Max.y+Threshold))) and
         ((Vector.z>=(AABB.Min.z-Threshold)) and (Vector.z<=(AABB.Max.z+Threshold)));
end;

function AABBGetIntersectAABB(const AABB,WithAABB:TAABB):TAABB; {$ifdef caninline}inline;{$endif}
begin
 if AABBIntersectEx(AABB,WithAABB) then begin
  result.Min.x:=Max(AABB.Min.x-EPSILON,WithAABB.Min.x-EPSILON);
  result.Min.y:=Max(AABB.Min.y-EPSILON,WithAABB.Min.y-EPSILON);
  result.Min.z:=Max(AABB.Min.z-EPSILON,WithAABB.Min.z-EPSILON);
  result.Max.x:=Min(AABB.Max.x+EPSILON,WithAABB.Max.x+EPSILON);
  result.Max.y:=Min(AABB.Max.y+EPSILON,WithAABB.Max.y+EPSILON);
  result.Max.z:=Min(AABB.Max.z+EPSILON,WithAABB.Max.z+EPSILON);
 end else begin
  FillChar(result,SizeOf(TAABB),#0);
 end;
end;

function AABBGetIntersection(const AABB,WithAABB:TAABB):TAABB; {$ifdef caninline}inline;{$endif}
begin
 result.Min.x:=Max(AABB.Min.x,WithAABB.Min.x);
 result.Min.y:=Max(AABB.Min.y,WithAABB.Min.y);
 result.Min.z:=Max(AABB.Min.z,WithAABB.Min.z);
 result.Max.x:=Min(AABB.Max.x,WithAABB.Max.x);
 result.Max.y:=Min(AABB.Max.y,WithAABB.Max.y);
 result.Max.z:=Min(AABB.Max.z,WithAABB.Max.z);
end;

function AABBRayIntersect(const AABB:TAABB;const Origin,Direction:TVector3):boolean; {$ifdef caninline}inline;{$endif}
var Center,BoxExtents,Diff:TVector3;
begin
 Center:=Vector3ScalarMul(Vector3Add(AABB.Min,AABB.Max),0.5);
 BoxExtents:=Vector3Sub(Center,AABB.Min);
 Diff:=Vector3Sub(Origin,Center);
 result:=not ((((abs(Diff.x)>BoxExtents.x) and ((Diff.x*Direction.x)>=0)) or
               ((abs(Diff.y)>BoxExtents.y) and ((Diff.y*Direction.y)>=0)) or
               ((abs(Diff.z)>BoxExtents.z) and ((Diff.z*Direction.z)>=0))) or
              ((abs((Direction.y*Diff.z)-(Direction.z*Diff.y))>((BoxExtents.y*abs(Direction.z))+(BoxExtents.z*abs(Direction.y)))) or
               (abs((Direction.z*Diff.x)-(Direction.x*Diff.z))>((BoxExtents.x*abs(Direction.z))+(BoxExtents.z*abs(Direction.x)))) or
               (abs((Direction.x*Diff.y)-(Direction.y*Diff.x))>((BoxExtents.x*abs(Direction.y))+(BoxExtents.y*abs(Direction.x))))));
end;

function AABBRayIntersectHit(const AABB:TAABB;const Origin,Direction:TVector3;var HitDist:single):boolean; {$ifdef caninline}inline;{$endif}
var Sides:array[0..5] of TPlane;
    i,j:longint;
    Inside:boolean;
    cosTheta,dist,d:single;
    p:TVector3;
begin
 Sides[0]:=Plane(1,0,0,-AABB.Min.x);
 Sides[1]:=Plane(-1,0,0,AABB.Max.x);
 Sides[2]:=Plane(0,1,0,-AABB.Min.y);
 Sides[3]:=Plane(0,-1,0,AABB.Max.y);
 Sides[4]:=Plane(0,0,1,-AABB.Min.z);
 Sides[5]:=Plane(0,0,-1,AABB.Max.z);
 HitDist:=0;
 Inside:=false;
 for i:=0 to 5 do begin
  cosTheta:=Vector3Dot(Sides[i].Normal,Direction);
  dist:=PlaneVectorDistance(Sides[i],Origin);
  if abs(Dist)<1e-12 then begin
   result:=true;
   exit;
  end;
  if abs(cosTheta)>1e-12 then begin
   HitDist:=(-dist)/cosTheta;
   if HitDist<0.0 then begin
    continue;
   end;
   p:=Vector3Add(Origin,Vector3ScalarMul(Direction,HitDist));
   Inside:=true;
   for j:=0 to 5 do begin
    if j<>i then begin
     d:=PlaneVectorDistance(Sides[i],p);
     inside:=(d+0.0015)>=0;
     if not Inside then begin
      break;
     end;
    end;
   end;
   if Inside then begin
    break;
   end;
  end;
 end;
 result:=Inside;
end;

function AABBRayIntersectHitFast(const AABB:TAABB;const Origin,Direction:TVector3;var HitDist:single):boolean; {$ifdef caninline}inline;{$endif}
var DirFrac:TVector3;
    t:array[0..5] of single;
    tMin,tMax:single;
begin
 DirFrac.x:=1.0/Direction.x;
 DirFrac.y:=1.0/Direction.y;
 DirFrac.z:=1.0/Direction.z;
 t[0]:=(AABB.Min.x-Origin.x)*DirFrac.x;
 t[1]:=(AABB.Max.x-Origin.x)*DirFrac.x;
 t[2]:=(AABB.Min.y-Origin.y)*DirFrac.y;
 t[3]:=(AABB.Max.y-Origin.y)*DirFrac.y;
 t[4]:=(AABB.Min.z-Origin.z)*DirFrac.z;
 t[5]:=(AABB.Max.z-Origin.z)*DirFrac.z;
 tMin:=Max(Max(Min(t[0],t[1]),Min(t[2],t[3])),Min(t[4],t[5]));
 tMax:=Min(Min(Max(t[0],t[1]),Max(t[2],t[3])),Max(t[4],t[5]));
 if (tMax<0) or (tMin>tMax) then begin
  HitDist:=tMax;
  result:=false;
 end else begin
  HitDist:=tMin;
  result:=true;
 end;
end;

function AABBRayIntersectHitPoint(const AABB:TAABB;const Origin,Direction:TVector3;var HitPoint:TVector3):boolean; {$ifdef caninline}inline;{$endif}
const RIGHT=0;
      LEFT=1;
      MIDDLE=2;
var i,WhicHPlane:longint;
    Inside:longbool;
    Quadrant:array[0..2] of longint;
    MaxT,CandidatePlane:TVector3;
begin
 Inside:=true;
 for i:=0 to 2 do begin
  if Origin.xyz[i]<AABB.Min.xyz[i] then begin
   Quadrant[i]:=LEFT;
   CandidatePlane.xyz[i]:=AABB.Min.xyz[i];
   Inside:=false;
  end else if Origin.xyz[i]>AABB.Max.xyz[i] then begin
   Quadrant[i]:=RIGHT;
   CandidatePlane.xyz[i]:=AABB.Max.xyz[i];
   Inside:=false;
  end else begin
   Quadrant[i]:=MIDDLE;
  end;
 end;
 if Inside then begin
  HitPoint:=Origin;
  result:=true;
 end else begin
  for i:=0 to 2 do begin
   if (Quadrant[i]<>MIDDLE) and (Direction.xyz[i]<>0.0) then begin
    MaxT.xyz[i]:=(CandidatePlane.xyz[i]-Origin.xyz[i])/Direction.xyz[i];
   end else begin
    MaxT.xyz[i]:=-1.0;
   end;
  end;
  WhichPlane:=0;
  for i:=1 to 2 do begin
   if MaxT.xyz[WhichPlane]<MaxT.xyz[i] then begin
    WhichPlane:=i;
   end;
  end;
  if MaxT.xyz[WhichPlane]<0.0 then begin
   result:=false;
  end else begin
   for i:=0 to 2 do begin
    if WhichPlane<>i then begin
     HitPoint.xyz[i]:=Origin.xyz[i]+(MaxT.xyz[WhichPlane]*Direction.xyz[i]);
     if (HitPoint.xyz[i]<AABB.Min.xyz[i]) or (HitPoint.xyz[i]>AABB.Min.xyz[i]) then begin
      result:=false;
      exit;
     end;
    end else begin
     HitPoint.xyz[i]:=CandidatePlane.xyz[i];
    end;
   end;
   result:=true;
  end;
 end;
end;

function AABBRayIntersection(const AABB:TAABB;const Origin,Direction:TVector3;var Time:single):boolean; overload; {$ifdef caninline}inline;{$endif}
var InvDirection,a,b,AABBMin,AABBMax:TVector3;
    TimeMin,TimeMax:single;
begin
 if abs(Direction.x)>1e-24 then begin
  InvDirection.x:=1.0/Direction.x;
 end else begin
  InvDirection.x:=0.0;
 end;
 if abs(Direction.y)>1e-24 then begin
  InvDirection.y:=1.0/Direction.y;
 end else begin
  InvDirection.y:=0.0;
 end;
 if abs(Direction.z)>1e-24 then begin
  InvDirection.z:=1.0/Direction.z;
 end else begin
  InvDirection.z:=0.0;
 end;
 a.x:=(AABB.Min.x-Origin.x)*InvDirection.x;
 a.y:=(AABB.Min.y-Origin.y)*InvDirection.y;
 a.z:=(AABB.Min.z-Origin.z)*InvDirection.z;
 b.x:=(AABB.Max.x-Origin.x)*InvDirection.x;
 b.y:=(AABB.Max.y-Origin.y)*InvDirection.y;
 b.z:=(AABB.Max.z-Origin.z)*InvDirection.z;
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

function AABBRayIntersection(const AABB:TAABB;const Origin,Direction:TSIMDVector3;var Time:single):boolean; overload; {$ifdef caninline}inline;{$endif}
var InvDirection,a,b,AABBMin,AABBMax:TVector3;
    TimeMin,TimeMax:single;
begin
 if abs(Direction.x)>1e-24 then begin
  InvDirection.x:=1.0/Direction.x;
 end else begin
  InvDirection.x:=0.0;
 end;
 if abs(Direction.y)>1e-24 then begin
  InvDirection.y:=1.0/Direction.y;
 end else begin
  InvDirection.y:=0.0;
 end;
 if abs(Direction.z)>1e-24 then begin
  InvDirection.z:=1.0/Direction.z;
 end else begin
  InvDirection.z:=0.0;
 end;
 a.x:=(AABB.Min.x-Origin.x)*InvDirection.x;
 a.y:=(AABB.Min.y-Origin.y)*InvDirection.y;
 a.z:=(AABB.Min.z-Origin.z)*InvDirection.z;
 b.x:=(AABB.Max.x-Origin.x)*InvDirection.x;
 b.y:=(AABB.Max.y-Origin.y)*InvDirection.y;
 b.z:=(AABB.Max.z-Origin.z)*InvDirection.z;
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

function AABBLineIntersection(const AABB:TAABB;const StartPoint,EndPoint:TVector3):boolean; {$ifdef caninline}inline;{$endif}
var Direction,InvDirection,a,b:TVector3;
    Len,TimeMin,TimeMax:single;
begin
 if AABBContainsEx(AABB,StartPoint) or AABBContainsEx(AABB,EndPoint) then begin
  result:=true;
 end else begin
  Direction:=Vector3Sub(EndPoint,StartPoint);
  Len:=Vector3Normalize(Direction);
  if abs(Direction.x)>1e-12 then begin
   InvDirection.x:=1.0/Direction.x;
  end else begin
   InvDirection.x:=Infinity;
  end;
  if abs(Direction.y)>1e-12 then begin
   InvDirection.y:=1.0/Direction.y;
  end else begin
   InvDirection.y:=Infinity;
  end;
  if abs(Direction.z)>1e-12 then begin
   InvDirection.z:=1.0/Direction.z;
  end else begin
   InvDirection.z:=Infinity;
  end;
  a.x:=((AABB.Min.x-EPSILON)-StartPoint.x)*InvDirection.x;
  a.y:=((AABB.Min.y-EPSILON)-StartPoint.y)*InvDirection.y;
  a.z:=((AABB.Min.z-EPSILON)-StartPoint.z)*InvDirection.z;
  b.x:=((AABB.Max.x+EPSILON)-StartPoint.x)*InvDirection.x;
  b.y:=((AABB.Max.y+EPSILON)-StartPoint.y)*InvDirection.y;
  b.z:=((AABB.Max.z+EPSILON)-StartPoint.z)*InvDirection.z;
  TimeMin:=Max(Max(Min(a.x,a.y),Min(a.z,b.x)),Min(b.y,b.z));
  TimeMax:=Min(Min(Max(a.x,a.y),Max(a.z,b.x)),Max(b.y,b.z));
  result:=((TimeMin<=TimeMax) and (TimeMax>=0.0)) and (TimeMin<=(Len+EPSILON));
 end;
end;

function AABBTransform(const DstAABB:TAABB;const Transform:TMatrix4x4):TAABB; {$ifdef caninline}inline;{$endif}
var i,j:longint;
    a,b:single;
begin
 result.Min:=Vector3(Transform[3,0],Transform[3,1],Transform[3,2]);
 result.Max:=result.Min;
 for i:=0 to 2 do begin
  for j:=0 to 2 do begin
   a:=Transform[j,i]*DstAABB.Min.xyz[j];
   b:=Transform[j,i]*DstAABB.Max.xyz[j];
   if a<b then begin
    result.Min.xyz[i]:=result.Min.xyz[i]+a;
    result.Max.xyz[i]:=result.Max.xyz[i]+b;
   end else begin
    result.Min.xyz[i]:=result.Min.xyz[i]+b;
    result.Max.xyz[i]:=result.Max.xyz[i]+a;
   end;
  end;
 end;
end;

function AABBTransformEx(const DstAABB:TAABB;const Transform:TMatrix4x4):TAABB; {$ifdef caninline}inline;{$endif}
var a:TVector3;
    i:longint;
begin
 for i:=0 to 7 do begin
  a.x:=DstAABB.MinMax[(i shr 0) and 1].x;
  a.y:=DstAABB.MinMax[(i shr 1) and 1].y;
  a.z:=DstAABB.MinMax[(i shr 2) and 1].z;
  Vector3MatrixMul(a,Transform);
  if i=0 then begin
   result.Min:=a;
   result.Max:=a;
  end else begin
   result.Min.x:=Min(result.Min.x,a.x);
   result.Min.y:=Min(result.Min.y,a.y);
   result.Min.z:=Min(result.Min.z,a.z);
   result.Max.x:=Max(result.Max.x,a.x);
   result.Max.y:=Max(result.Max.y,a.y);
   result.Max.z:=Max(result.Max.z,a.z);
  end;
 end;
end;

function FindMin(const a,b,c:single):single; {$ifdef caninline}inline;{$endif}
begin
 result:=a;
 if result>b then begin
  result:=b;
 end;
 if result>c then begin
  result:=c;
 end;
end;

function FindMax(const a,b,c:single):single; {$ifdef caninline}inline;{$endif}
begin
 result:=a;
 if result<b then begin
  result:=b;
 end;
 if result<c then begin
  result:=c;
 end;
end;

function AABBIntersectTriangle(const AABB:TAABB;const tv0,tv1,tv2:TVector3):boolean;
 function PlaneBoxOverlap(const Normal:TVector3;d:single;MaxBox:TVector3):boolean; {$ifdef caninline}inline;{$endif}
 var vmin,vmax:TVector3;
 begin
  if Normal.x>0 then begin
   vmin.x:=-MaxBox.x;
   vmax.x:=MaxBox.x;
  end else begin
   vmin.x:=MaxBox.x;
   vmax.x:=-MaxBox.x;
  end;
  if Normal.y>0 then begin
   vmin.y:=-MaxBox.y;
   vmax.y:=MaxBox.y;
  end else begin
   vmin.y:=MaxBox.y;
   vmax.y:=-MaxBox.y;
  end;
  if Normal.z>0 then begin
   vmin.z:=-MaxBox.z;
   vmax.z:=MaxBox.z;
  end else begin
   vmin.z:=MaxBox.z;
   vmax.z:=-MaxBox.z;
  end;
  if (Vector3Dot(Normal,vmin)+d)>0 then begin
   result:=false;
  end else if (Vector3Dot(Normal,vmax)+d)>=0 then begin
   result:=true;
  end else begin
   result:=false;
  end;
 end;
var BoxCenter,BoxHalfSize,Normal,v0,v1,v2,e0,e1,e2:TVector3;
    fex,fey,fez:single;
 function AxisTestX01(a,b,fa,fb:single):boolean; //{$ifdef caninline}inline;{$endif}
 var p0,p2,pmin,pmax,Radius:single;
 begin
  p0:=(a*v0.y)-(b*v0.z);
  p2:=(a*v2.y)-(b*v2.z);
  if p0<p2 then begin
   pmin:=p0;
   pmax:=p2;
  end else begin
   pmin:=p2;
   pmax:=p0;
  end;
  Radius:=(fa*BoxHalfSize.y)+(fb*BoxHalfSize.z);
  result:=not ((pmin>Radius) or (pmax<(-radius)));
 end;
 function AxisTestX2(a,b,fa,fb:single):boolean; //{$ifdef caninline}inline;{$endif}
 var p0,p1,pmin,pmax,Radius:single;
 begin
  p0:=(a*v0.y)-(b*v0.z);
  p1:=(a*v1.y)-(b*v1.z);
  if p0<p1 then begin
   pmin:=p0;
   pmax:=p1;
  end else begin
   pmin:=p1;
   pmax:=p0;
  end;
  Radius:=(fa*BoxHalfSize.y)+(fb*BoxHalfSize.z);
  result:=not ((pmin>Radius) or (pmax<(-radius)));
 end;
 function AxisTestY02(a,b,fa,fb:single):boolean; //{$ifdef caninline}inline;{$endif}
 var p0,p2,pmin,pmax,Radius:single;
 begin
  p0:=(-(a*v0.x))+(b*v0.z);
  p2:=(-(a*v2.x))+(b*v2.z);
  if p0<p2 then begin
   pmin:=p0;
   pmax:=p2;
  end else begin
   pmin:=p2;
   pmax:=p0;
  end;
  Radius:=(fa*BoxHalfSize.x)+(fb*BoxHalfSize.z);
  result:=not ((pmin>Radius) or (pmax<(-radius)));
 end;
 function AxisTestY1(a,b,fa,fb:single):boolean; //{$ifdef caninline}inline;{$endif}
 var p0,p1,pmin,pmax,Radius:single;
 begin
  p0:=(-(a*v0.x))+(b*v0.z);
  p1:=(-(a*v1.x))+(b*v1.z);
  if p0<p1 then begin
   pmin:=p0;
   pmax:=p1;
  end else begin
   pmin:=p1;
   pmax:=p0;
  end;
  Radius:=(fa*BoxHalfSize.x)+(fb*BoxHalfSize.z);
  result:=not ((pmin>Radius) or (pmax<(-radius)));
 end;
 function AxisTestZ12(a,b,fa,fb:single):boolean; //{$ifdef caninline}inline;{$endif}
 var p1,p2,pmin,pmax,Radius:single;
 begin
  p1:=(a*v1.x)-(b*v1.y);
  p2:=(a*v2.x)-(b*v2.y);
  if p2<p1 then begin
   pmin:=p2;
   pmax:=p1;
  end else begin
   pmin:=p1;
   pmax:=p2;
  end;
  Radius:=(fa*BoxHalfSize.x)+(fb*BoxHalfSize.y);
  result:=not ((pmin>Radius) or (pmax<(-radius)));
 end;
 function AxisTestZ0(a,b,fa,fb:single):boolean; //{$ifdef caninline}inline;{$endif}
 var p0,p1,pmin,pmax,Radius:single;
 begin
  p0:=(a*v0.x)-(b*v0.y);
  p1:=(a*v1.x)-(b*v1.y);
  if p0<p1 then begin
   pmin:=p0;
   pmax:=p1;
  end else begin
   pmin:=p1;
   pmax:=p0;
  end;
  Radius:=(fa*BoxHalfSize.x)+(fb*BoxHalfSize.y);
  result:=not ((pmin>Radius) or (pmax<(-radius)));
 end;
 procedure FindMinMax(const a,b,c:single;var omin,omax:single); {$ifdef caninline}inline;{$endif}
 begin
  omin:=a;
  if omin>b then begin
   omin:=b;
  end;
  if omin>c then begin
   omin:=c;
  end;
  omax:=a;
  if omax<b then begin
   omax:=b;
  end;
  if omax<c then begin
   omax:=c;
  end;
 end;
begin
 BoxCenter:=Vector3ScalarMul(Vector3Add(AABB.Min,AABB.Max),0.5);
 BoxHalfSize:=Vector3ScalarMul(Vector3Sub(AABB.Max,AABB.Min),0.5);
 v0:=Vector3Sub(tv0,BoxCenter);
 v1:=Vector3Sub(tv1,BoxCenter);
 v2:=Vector3Sub(tv2,BoxCenter);
 e0:=Vector3Sub(v1,v0);
 e1:=Vector3Sub(v2,v1);
 e2:=Vector3Sub(v0,v2);
 fex:=abs(e0.x);
 fey:=abs(e0.y);
 fez:=abs(e0.z);
 if (not AxisTestX01(e0.z,e0.y,fez,fey)) or (not AxisTestY02(e0.z,e0.x,fez,fex)) or (not AxisTestZ12(e0.y,e0.x,fey,fex)) then begin
  result:=false;
  exit;
 end;
 fex:=abs(e1.x);
 fey:=abs(e1.y);
 fez:=abs(e1.z);
 if (not AxisTestX01(e1.z,e1.y,fez,fey)) or (not AxisTestY02(e1.z,e1.x,fez,fex)) or (not AxisTestZ0(e1.y,e1.x,fey,fex)) then begin
  result:=false;
  exit;
 end;
 fex:=abs(e2.x);
 fey:=abs(e2.y);
 fez:=abs(e2.z);
 if (not AxisTestX2(e2.z,e2.y,fez,fey)) or (not AxisTestY1(e2.z,e2.x,fez,fex)) or (not AxisTestZ12(e2.y,e2.x,fey,fex)) then begin
  result:=false;
  exit;
 end;
 if ((FindMin(v0.x,v1.x,v2.x)>BoxHalfSize.x) or (FindMax(v0.x,v1.x,v2.x)<(-BoxHalfSize.x))) or
    ((FindMin(v0.y,v1.y,v2.y)>BoxHalfSize.y) or (FindMax(v0.y,v1.y,v2.y)<(-BoxHalfSize.y))) or
    ((FindMin(v0.z,v1.z,v2.z)>BoxHalfSize.z) or (FindMax(v0.z,v1.z,v2.z)<(-BoxHalfSize.z))) then begin
  result:=false;
  exit;
 end;
 Normal:=Vector3Cross(e0,e1);
 result:=PlaneBoxOverlap(Normal,-Vector3Dot(Normal,v0),BoxHalfSize);
end;

function AABBMatrixMul(const DstAABB:TAABB;const Transform:TMatrix4x4):TAABB; {$ifdef caninline}inline;{$endif}
var Rotation:TMatrix4x4;
    v:array[0..7] of TVector3;
    Center,NewCenter,MinVector,MaxVector:TVector3;
    i:longint;
begin
 Rotation:=Matrix4x4Rotation(Transform);

 Center:=Vector3ScalarMul(Vector3Add(DstAABB.Min,DstAABB.Max),0.5);

 MinVector:=Vector3Sub(DstAABB.Min,Center);
 MaxVector:=Vector3Sub(DstAABB.Max,Center);

 NewCenter:=Vector3Origin;
 Vector3MatrixMul(NewCenter,Transform);
 NewCenter:=Vector3Add(NewCenter,Center);

 v[0]:=Vector3(MinVector.x,MinVector.y,MinVector.z);
 v[1]:=Vector3(MaxVector.x,MinVector.y,MinVector.z);
 v[2]:=Vector3(MaxVector.x,MaxVector.y,MinVector.z);
 v[3]:=Vector3(MaxVector.x,MaxVector.y,MaxVector.z);
 v[4]:=Vector3(MinVector.x,MaxVector.y,MaxVector.z);
 v[5]:=Vector3(MinVector.x,MinVector.y,MaxVector.z);
 v[6]:=Vector3(MaxVector.x,MinVector.y,MaxVector.z);
 v[7]:=Vector3(MinVector.x,MaxVector.y,MinVector.z);

 Vector3MatrixMul(v[0],Rotation);
 Vector3MatrixMul(v[1],Rotation);
 Vector3MatrixMul(v[2],Rotation);
 Vector3MatrixMul(v[3],Rotation);
 Vector3MatrixMul(v[4],Rotation);
 Vector3MatrixMul(v[5],Rotation);
 Vector3MatrixMul(v[6],Rotation);
 Vector3MatrixMul(v[7],Rotation);

 result.Min:=v[0];
 result.Max:=v[0];
 for i:=0 to 7 do begin
  if result.Min.x>v[i].x then begin
   result.Min.x:=v[i].x;
  end;
  if result.Min.y>v[i].y then begin
   result.Min.y:=v[i].y;
  end;
  if result.Min.z>v[i].z then begin
   result.Min.z:=v[i].z;
  end;
  if result.Max.x<v[i].x then begin
   result.Max.x:=v[i].x;
  end;
  if result.Max.y<v[i].y then begin
   result.Max.y:=v[i].y;
  end;
  if result.Max.z<v[i].z then begin
   result.Max.z:=v[i].z;
  end;
 end;
 result.Min:=Vector3Add(result.Min,NewCenter);
 result.Max:=Vector3Add(result.Max,NewCenter);
end;

function AABBScissorRect(const AABB:TAABB;var Scissor:TClipRect;const mvp:TMatrix4x4;const vp:TClipRect;zcull:boolean):boolean; overload; {$ifdef caninline}inline;{$endif}
var p:TVector4;
    i,x,y,z_far,z_near:longint;
begin
 z_near:=0;
 z_far:=0;
 for i:=0 to 7 do begin

  // Get bound edge point
  p.x:=AABB.MinMax[i and 1].x;
  p.y:=AABB.MinMax[(i shr 1) and 1].y;
  p.z:=AABB.MinMax[(i shr 2) and 1].z;
  p.w:=1.0;

  // Project
  Vector4MatrixMul(p,mvp);
  p.x:=p.x/p.w; 
  p.y:=p.y/p.w;
  p.z:=p.z/p.w;

  // Convert to screen space
  p.x:=vp[0]+(vp[2]*((p.x+1.0)*0.5));
  p.y:=vp[1]+(vp[3]*((p.y+1.0)*0.5));
  p.z:=(p.z+1.0)*0.5;
  if zcull then begin
   if p.z<-EPSILON then begin
    inc(z_far);
   end else if p.z>(1.0+EPSILON) then begin
    inc(z_near);
   end;
  end;

  // Round to integer values
  x:=round(p.x);
  y:=round(p.y);

  // Clip
  if x<vp[0] then begin
   x:=vp[0];
  end;
  if x>(vp[0]+vp[2]) then begin
   x:=vp[0]+vp[2];
  end;
  if y<vp[1] then begin
   y:=vp[1];
  end;
  if y>(vp[1]+vp[3]) then begin
   y:=vp[1]+vp[3];
  end;

  // Extend
  if i=0 then begin
   Scissor[0]:=x;
   Scissor[1]:=y;
   Scissor[2]:=x;
   Scissor[3]:=y;
  end else begin
   if x<Scissor[0] then begin
    Scissor[0]:=x;
   end;
   if y<Scissor[1] then begin
    Scissor[1]:=y;
   end;
   if x>Scissor[2] then begin
    Scissor[2]:=x;
   end;
   if y>Scissor[3] then begin
    Scissor[3]:=y;
   end;
  end;

 end;
 if (z_far=8) or (z_near=8) then begin
  result:=false;
 end else if (z_near>0) and (z_near<8) then begin
  result:=true;
  Scissor[0]:=vp[0];
  Scissor[1]:=vp[1];
  Scissor[2]:=vp[0]+vp[2];
  Scissor[3]:=vp[1]+vp[3];
 end else begin
  result:=true;
 end;
end;

function AABBScissorRect(const AABB:TAABB;var Scissor:TFloatClipRect;const mvp:TMatrix4x4;const vp:TFloatClipRect;zcull:boolean):boolean; overload; {$ifdef caninline}inline;{$endif}
var p:TVector4;
    i,z_far,z_near:longint;
begin
 z_near:=0;
 z_far:=0;
 for i:=0 to 7 do begin

  // Get bound edge point
  p.x:=AABB.MinMax[i and 1].x;
  p.y:=AABB.MinMax[(i shr 1) and 1].y;
  p.z:=AABB.MinMax[(i shr 2) and 1].z;
  p.w:=1.0;

  // Project
  Vector4MatrixMul(p,mvp);
  p.x:=p.x/p.w; 
  p.y:=p.y/p.w;
  p.z:=p.z/p.w;

  // Convert to screen space
  p.x:=vp[0]+(vp[2]*((p.x+1.0)*0.5));
  p.y:=vp[1]+(vp[3]*((p.y+1.0)*0.5));
  p.z:=(p.z+1.0)*0.5;
  if zcull then begin
   if p.z<-EPSILON then begin
    inc(z_far);
   end else if p.z>(1.0+EPSILON) then begin
    inc(z_near);
   end;
  end;

  // Clip
  if p.x<vp[0] then begin
   p.x:=vp[0];
  end;
  if p.x>(vp[0]+vp[2]) then begin
   p.x:=vp[0]+vp[2];
  end;
  if p.y<vp[1] then begin
   p.y:=vp[1];
  end;
  if p.y>(vp[1]+vp[3]) then begin
   p.y:=vp[1]+vp[3];
  end;

  // Extend
  if i=0 then begin
   Scissor[0]:=p.x;
   Scissor[1]:=p.y;
   Scissor[2]:=p.x;
   Scissor[3]:=p.y;
  end else begin
   if p.x<Scissor[0] then begin
    Scissor[0]:=p.x;
   end;
   if p.y<Scissor[1] then begin
    Scissor[1]:=p.y;
   end;
   if p.x>Scissor[2] then begin
    Scissor[2]:=p.x;
   end;
   if p.y>Scissor[3] then begin
    Scissor[3]:=p.y;
   end;
  end;

 end;
 if (z_far=8) or (z_near=8) then begin
  result:=false;
 end else if (z_near>0) and (z_near<8) then begin
  result:=true;
  Scissor[0]:=vp[0];
  Scissor[1]:=vp[1];
  Scissor[2]:=vp[0]+vp[2];
  Scissor[3]:=vp[1]+vp[3];
 end else begin
  result:=true;
 end;
end;

// Sweep-test for size-changing AABBs
function AABBMovingTest(const aAABBFrom,aAABBTo,bAABBFrom,bAABBTo:TAABB;var t:single):boolean;
var Axis,AxisSamples,Samples,Sample,FirstSample:longint;
    aAABB,bAABB:TAABB;
    f{,MinRadius},Size,Distance,BestDistance:single;
    HasDistance:boolean;
begin
 if AABBIntersectEx(aAABBFrom,bAABBFrom) then begin
  t:=0.0;
  result:=true;
 end else begin
  result:=false;
  if AABBIntersectEx(AABBCombine(aAABBFrom,aAABBTo),AABBCombine(bAABBFrom,bAABBTo)) then begin
   FirstSample:=0;
   Samples:=1;
   for Axis:=0 to 2 do begin
    if aAABBFrom.Min.xyz[Axis]>aAABBTo.Max.xyz[Axis] then begin
     Distance:=aAABBFrom.Min.xyz[Axis]-aAABBTo.Max.xyz[Axis];
    end else if aAABBTo.Min.xyz[Axis]>aAABBFrom.Max.xyz[Axis] then begin
     Distance:=aAABBTo.Min.xyz[Axis]-aAABBFrom.Max.xyz[Axis];
    end else begin
     Distance:=0;
    end;
    Size:=min(abs(aAABBFrom.Max.xyz[Axis]-aAABBFrom.Min.xyz[Axis]),abs(aAABBTo.Max.xyz[Axis]-aAABBTo.Min.xyz[Axis]));
    if Size>0.0 then begin
     AxisSamples:=round((Distance+Size)/Size);
     if Samples<AxisSamples then begin
      Samples:=AxisSamples;
     end;
    end;
    if bAABBFrom.Min.xyz[Axis]>bAABBTo.Max.xyz[Axis] then begin
     Distance:=bAABBFrom.Min.xyz[Axis]-bAABBTo.Max.xyz[Axis];
    end else if bAABBTo.Min.xyz[Axis]>bAABBFrom.Max.xyz[Axis] then begin
     Distance:=bAABBTo.Min.xyz[Axis]-bAABBFrom.Max.xyz[Axis];
    end else begin
     Distance:=0;
    end;
    Size:=min(abs(bAABBFrom.Max.xyz[Axis]-bAABBFrom.Min.xyz[Axis]),abs(bAABBTo.Max.xyz[Axis]-bAABBTo.Min.xyz[Axis]));
    if Size>0.0 then begin
     AxisSamples:=round((Distance+Size)/Size);
     if Samples<AxisSamples then begin
      Samples:=AxisSamples;
     end;
    end;
   end;
   BestDistance:=1e+18;
   HasDistance:=false;
   for Sample:=FirstSample to Samples do begin
    f:=Sample/Samples;
    aAABB.Min:=Vector3Lerp(aAABBFrom.Min,aAABBTo.Min,f);
    aAABB.Max:=Vector3Lerp(aAABBFrom.Max,aAABBTo.Max,f);
    bAABB.Min:=Vector3Lerp(bAABBFrom.Min,bAABBTo.Min,f);
    bAABB.Max:=Vector3Lerp(bAABBFrom.Max,bAABBTo.Max,f);
    if AABBIntersectEx(aAABB,bAABB) then begin
     t:=f;
     result:=true;
     break;
    end else begin
     Distance:=AABBDistance(aAABB,bAABB);
     if (not HasDistance) and (Distance<BestDistance) then begin
      BestDistance:=Distance;
      HasDistance:=true;
     end else begin
      break;
     end;
    end;
   end;
  end;
 end;
end;

// Sweep-test for non-size-changing AABBs
function AABBSweepTest(const aAABB,bAABB:TAABB;const aV,bV:TVector3;var FirstTime,LastTime:single):boolean; {$ifdef caninline}inline;{$endif}
var Axis:longint;
    v,tMin,tMax:TVector3;
begin
 if AABBIntersect(aAABB,bAABB) then begin
  FirstTime:=0.0;
  LastTime:=0.0;
  result:=true;
 end else begin
  v:=Vector3Sub(bV,aV);
  for Axis:=0 to 2 do begin
   if v.xyz[Axis]<0.0 then begin
    tMin.xyz[Axis]:=(aAABB.Max.xyz[Axis]-bAABB.Min.xyz[Axis])/v.xyz[Axis];
    tMax.xyz[Axis]:=(aAABB.Min.xyz[Axis]-bAABB.Max.xyz[Axis])/v.xyz[Axis];
   end else if v.xyz[Axis]>0.0 then begin
    tMin.xyz[Axis]:=(aAABB.Min.xyz[Axis]-bAABB.Max.xyz[Axis])/v.xyz[Axis];
    tMax.xyz[Axis]:=(aAABB.Max.xyz[Axis]-bAABB.Min.xyz[Axis])/v.xyz[Axis];
   end else if (aAABB.Max.xyz[Axis]>=bAABB.Min.xyz[Axis]) and (aAABB.Min.xyz[Axis]<=bAABB.Max.xyz[Axis]) then begin
    tMin.xyz[Axis]:=0.0;
    tMax.xyz[Axis]:=1.0;
   end else begin
    result:=false;
    exit;
   end;
  end;
  FirstTime:=max(max(tMin.x,tMin.y),tMin.z);
  LastTime:=min(min(tMax.x,tMax.y),tMax.z);
  result:=(LastTime>=0.0) and (FirstTime<=1.0) and (FirstTime<=LastTime);
 end;
end;

procedure SIMDSegment(out Segment:TSIMDSegment;const p0,p1:TSIMDVector3); overload;
begin
 Segment.Points[0]:=p0;
 Segment.Points[1]:=p1;
end;

function SIMDSegment(const p0,p1:TSIMDVector3):TSIMDSegment; overload;
begin
 result.Points[0]:=p0;
 result.Points[1]:=p1;
end;

function SIMDSegmentSquaredDistanceTo(const Segment:TSIMDSegment;const p:TSIMDVector3):single;
var pq,pp:TSIMDVector3;
    e,f:single;
begin
 pq:=SIMDVector3Sub(Segment.Points[1],Segment.Points[0]);
 pp:=SIMDVector3Sub(p,Segment.Points[0]);
 e:=SIMDVector3Dot(pp,pq);
 if e<=0.0 then begin
  result:=SIMDVector3LengthSquared(pp);
 end else begin
  f:=SIMDVector3LengthSquared(pq);
  if e<f then begin
   result:=SIMDVector3LengthSquared(pp)-(sqr(e)/f);
  end else begin
   result:=SIMDVector3LengthSquared(SIMDVector3Sub(p,Segment.Points[1]));
  end;
 end;
end;

procedure SIMDSegmentClosestPointTo(const Segment:TSIMDSegment;const p:TSIMDVector3;out Time:single;out ClosestPoint:TSIMDVector3);
var u,v:TSIMDVector3;
begin
 u:=SIMDVector3Sub(Segment.Points[1],Segment.Points[0]);
 v:=SIMDVector3Sub(p,Segment.Points[0]);
 Time:=SIMDVector3Dot(u,v)/SIMDVector3LengthSquared(u);
 if Time<=0.0 then begin
  ClosestPoint:=Segment.Points[0];
 end else if Time>=1.0 then begin
  ClosestPoint:=Segment.Points[1];
 end else begin
  ClosestPoint:=SIMDVector3Add(SIMDVector3ScalarMul(Segment.Points[0],1.0-Time),SIMDVector3ScalarMul(Segment.Points[1],Time));
 end;
end;

procedure SIMDSegmentTransform(out OutputSegment:TSIMDSegment;const Segment:TSIMDSegment;const Transform:TMatrix4x4); overload;
begin
 OutputSegment.Points[0]:=SIMDVector3TermMatrixMul(Segment.Points[0],Transform);
 OutputSegment.Points[1]:=SIMDVector3TermMatrixMul(Segment.Points[1],Transform);
end;

function SIMDSegmentTransform(const Segment:TSIMDSegment;const Transform:TMatrix4x4):TSIMDSegment; overload;
begin
 result.Points[0]:=SIMDVector3TermMatrixMul(Segment.Points[0],Transform);
 result.Points[1]:=SIMDVector3TermMatrixMul(Segment.Points[1],Transform);
end;

procedure SIMDSegmentClosestPoints(const SegmentA,SegmentB:TSIMDSegment;out TimeA:single;out ClosestPointA:TSIMDVector3;out TimeB:single;out ClosestPointB:TSIMDVector3);
const EPSILON=1e-7;
var dA,dB,r:TSIMDVector3;
    a,b,c,d,e,f,Denominator,aA,aB,bA,bB:single;
begin
 dA:=SIMDVector3Sub(SegmentA.Points[1],SegmentA.Points[0]);
 dB:=SIMDVector3Sub(SegmentB.Points[1],SegmentB.Points[0]);
 r:=SIMDVector3Sub(SegmentA.Points[0],SegmentB.Points[0]);
 a:=SIMDVector3LengthSquared(dA);
 e:=SIMDVector3LengthSquared(dB);
 f:=SIMDVector3Dot(dB,r);
 if (a<EPSILON) and (e<EPSILON) then begin
  // segment a and b are both points
  TimeA:=0.0;
  TimeB:=0.0;
  ClosestPointA:=SegmentA.Points[0];
  ClosestPointB:=SegmentB.Points[0];
 end else begin
  if a<EPSILON then begin
   // segment a is a point
	 TimeA:=0.0;
   TimeB:=f/e;
   if TimeB<0.0 then begin
    TimeB:=0.0;
   end else if TimeB>1.0 then begin
    TimeB:=1.0;
   end;
  end else begin
   c:=SIMDVector3Dot(dA,r);
   if e<EPSILON then begin
		// segment b is a point
    TimeA:=-(c/a);
    if TimeA<0.0 then begin
     TimeA:=0.0;
    end else if TimeA>1.0 then begin
     TimeA:=1.0;
    end;
    TimeB:=0.0;
	 end else begin
    b:=SIMDVector3Dot(dA,dB);
    Denominator:=(a*e)-sqr(b);
		if Denominator<EPSILON then begin
     // segments are parallel
     aA:=SIMDVector3Dot(dB,SegmentA.Points[0]);
     aB:=SIMDVector3Dot(dB,SegmentA.Points[1]);
     bA:=SIMDVector3Dot(dB,SegmentB.Points[0]);
     bB:=SIMDVector3Dot(dB,SegmentB.Points[1]);
     if (aA<=bA) and (aB<=bA) then begin
			// segment A is completely "before" segment B
      if aB>aA then begin
       TimeA:=1.0;
      end else begin
       TimeA:=0.0;
      end;
      TimeB:=0.0;
     end else if (aA>=bB) and (aB>=bB) then begin
      // segment B is completely "before" segment A
      if aB>aA then begin
       TimeA:=0.0;
      end else begin
       TimeA:=1.0;
      end;
      TimeB:=1.0;
     end else begin
      // segments A and B overlap, use midpoint of shared length
			if aA>aB then begin
       f:=aA;
       aA:=aB;
       aB:=f;
      end;
      f:=(Min(aB,bB)+Max(aA,bA))*0.5;
      TimeB:=(f-bA)/e;
      ClosestPointB:=SIMDVector3Add(SegmentB.Points[0],SIMDVector3ScalarMul(dB,TimeB));
      SIMDSegmentClosestPointTo(SegmentA,ClosestPointB,TimeB,ClosestPointA);
      exit;
     end;
    end	else begin
     // general case
     TimeA:=((b*f)-(c*e))/Denominator;
     if TimeA<0.0 then begin
      TimeA:=0.0;
     end else if TimeA>1.0 then begin
      TimeA:=1.0;
     end;
     TimeB:=((b*TimeA)+f)/e;
     if TimeB<0.0 then begin
      TimeB:=0.0;
      TimeA:=-(c/a);
      if TimeA<0.0 then begin
       TimeA:=0.0;
      end else if TimeA>1.0 then begin
       TimeA:=1.0;
      end;
     end else if TimeB>1.0 then begin
      TimeB:=1.0;
      TimeA:=(b-c)/a;
      if TimeA<0.0 then begin
       TimeA:=0.0;
      end else if TimeA>1.0 then begin
       TimeA:=1.0;
      end;
     end;
    end;
   end;
  end;
  ClosestPointA:=SIMDVector3Add(SegmentA.Points[0],SIMDVector3ScalarMul(dA,TimeA));
  ClosestPointB:=SIMDVector3Add(SegmentB.Points[0],SIMDVector3ScalarMul(dB,TimeB));
 end;
end;

function SIMDSegmentIntersect(const SegmentA,SegmentB:TSIMDSegment;out TimeA,TimeB:single;out IntersectionPoint:TSIMDVector3):boolean;
const EPSILON=1e-7;
var PointA:TSIMDVector3;
begin
 SIMDSegmentClosestPoints(SegmentA,SegmentB,TimeA,PointA,TimeB,IntersectionPoint);
 result:=SIMDVector3DistSquared(PointA,IntersectionPoint)<EPSILON;
end;

function SIMDTriangleContains(const Triangle:TSIMDTriangle;const p:TSIMDVector3):boolean;
var vA,vB,vC:TSIMDVector3;
    dAB,dAC,dBC:single;
begin
 vA:=SIMDVector3Sub(Triangle.Points[0],p);
 vB:=SIMDVector3Sub(Triangle.Points[1],p);
 vC:=SIMDVector3Sub(Triangle.Points[2],p);
 dAB:=SIMDVector3Dot(vA,vB);
 dAC:=SIMDVector3Dot(vA,vC);
 dBC:=SIMDVector3Dot(vB,vC);
 if ((dBC*dAC)-(SIMDVector3LengthSquared(vC)*dAB))<0.0 then begin
  result:=false;
 end else begin
  result:=((dAB*dBC)-(dAC*SIMDVector3LengthSquared(vB)))>=0.0;
 end;
end;

function SIMDTriangleIntersect(const Triangle:TSIMDTriangle;const Segment:TSIMDSegment;out Time:single;out IntersectionPoint:TSIMDVector3):boolean;
var Switched:boolean;
    d,t,v,w:single;
    vAB,vAC,pBA,vApA,e,n:TSIMDVector3;
    s:TSIMDSegment;
begin

 result:=false;

 Time:=NaN;

 IntersectionPoint:=SIMDVector3Origin;

 Switched:=false;

 vAB:=SIMDVector3Sub(Triangle.Points[1],Triangle.Points[0]);
 vAC:=SIMDVector3Sub(Triangle.Points[2],Triangle.Points[0]);

 pBA:=SIMDVector3Sub(Segment.Points[0],Segment.Points[1]);

 n:=SIMDVector3Cross(vAB,vAC);

 d:=SIMDVector3Dot(n,pBA);

 if abs(d)<EPSILON then begin
  exit; // segment is parallel
 end else if d<0.0 then begin
  s.Points[0]:=Segment.Points[1];
  s.Points[1]:=Segment.Points[0];
  Switched:=true;
  pBA:=SIMDVector3Sub(s.Points[0],s.Points[1]);
  d:=-d;
 end else begin
  s:=Segment;
 end;

 vApA:=SIMDVector3Sub(s.Points[0],Triangle.Points[0]);
 t:=SIMDVector3Dot(n,vApA);
 e:=SIMDVector3Cross(pBA,vApA);

 v:=SIMDVector3Dot(vAC,e);
 if (v<0.0) or (v>d) then begin
  exit; // intersects outside triangle
 end;

 w:=-SIMDVector3Dot(vAB,e);
 if (w<0.0) or ((v+w)>d) then begin
  exit; // intersects outside triangle
 end;

 d:=1.0/d;
 t:=t*d;
 v:=v*d;
 w:=w*d;
 Time:=t;

 IntersectionPoint:=SIMDVector3Add(Triangle.Points[0],SIMDVector3Add(SIMDVector3ScalarMul(vAB,v),SIMDVector3ScalarMul(vAC,w)));

 if Switched then begin
	Time:=1.0-Time;
 end;

 result:=(Time>=0.0) and (Time<=1.0);
end;

function SIMDTriangleClosestPointTo(const Triangle:TSIMDTriangle;const Point:TSIMDVector3;out ClosestPoint:TSIMDVector3):boolean; overload;
var u,v,w,d1,d2,d3,d4,d5,d6,Denominator:single;
    vAB,vAC,vAp,vBp,vCp:TSIMDVector3;
begin
 result:=false;

 vAB:=SIMDVector3Sub(Triangle.Points[1],Triangle.Points[0]);
 vAC:=SIMDVector3Sub(Triangle.Points[2],Triangle.Points[0]);
 vAp:=SIMDVector3Sub(Point,Triangle.Points[0]);

 d1:=SIMDVector3Dot(vAB,vAp);
 d2:=SIMDVector3Dot(vAC,vAp);
 if (d1<=0.0) and (d2<=0.0) then begin
	ClosestPoint:=Triangle.Points[0]; // closest point is vertex A
	exit;
 end;

 vBp:=SIMDVector3Sub(Point,Triangle.Points[1]);
 d3:=SIMDVector3Dot(vAB,vBp);
 d4:=SIMDVector3Dot(vAC,vBp);
 if (d3>=0.0) and (d4<=d3) then begin
	ClosestPoint:=Triangle.Points[1]; // closest point is vertex B
	exit;
 end;
                                  
 w:=(d1*d4)-(d3*d2);
 if (w<=0.0) and (d1>=0.0) and (d3<=0.0) then begin
 	// closest point is along edge 1-2
	ClosestPoint:=SIMDVector3Add(Triangle.Points[0],SIMDVector3ScalarMul(vAB,d1/(d1-d3)));
  exit;
 end;

 vCp:=SIMDVector3Sub(Point,Triangle.Points[2]);
 d5:=SIMDVector3Dot(vAB,vCp);
 d6:=SIMDVector3Dot(vAC,vCp);
 if (d6>=0.0) and (d5<=d6) then begin
	ClosestPoint:=Triangle.Points[2]; // closest point is vertex C
	exit;
 end;

 v:=(d5*d2)-(d1*d6);
 if (v<=0.0) and (d2>=0.0) and (d6<=0.0) then begin
 	// closest point is along edge 1-3
	ClosestPoint:=SIMDVector3Add(Triangle.Points[0],SIMDVector3ScalarMul(vAC,d2/(d2-d6)));
  exit;
 end;

 u:=(d3*d6)-(d5*d4);
 if (u<=0.0) and ((d4-d3)>=0.0) and ((d5-d6)>=0.0) then begin
	// closest point is along edge 2-3
	ClosestPoint:=SIMDVector3Add(Triangle.Points[1],SIMDVector3ScalarMul(SIMDVector3Sub(Triangle.Points[2],Triangle.Points[1]),(d4-d3)/((d4-d3)+(d5-d6))));
  exit;
 end;

 Denominator:=1.0/(u+v+w);

 ClosestPoint:=SIMDVector3Add(Triangle.Points[0],SIMDVector3Add(SIMDVector3ScalarMul(vAB,v*Denominator),SIMDVector3ScalarMul(vAC,w*Denominator)));

 result:=true;
end;

function SIMDTriangleClosestPointTo(const Triangle:TSIMDTriangle;const Segment:TSIMDSegment;out Time:single;out ClosestPointOnSegment,ClosestPointOnTriangle:TSIMDVector3):boolean; overload;
var MinDist,dtri,d1,d2,sa,sb,dist:single;
    pAInside,pBInside:boolean;
    v,pa,pb:TSIMDVector3;
    Edge:TSIMDSegment;
begin

 result:=SIMDTriangleIntersect(Triangle,Segment,Time,ClosestPointOnTriangle);

 if result then begin

 	// segment intersects triangle
  ClosestPointOnSegment:=ClosestPointOnTriangle;

 end else begin

  MinDist:=3.4e+28;

  ClosestPointOnSegment:=SIMDVector3Origin;

  dtri:=SIMDVector3Dot(Triangle.Normal,Triangle.Points[0]);

  pAInside:=SIMDTriangleContains(Triangle,Segment.Points[0]);
  pBInside:=SIMDTriangleContains(Triangle,Segment.Points[1]);

  if pAInside and pBInside then begin
   // both points inside triangle
   d1:=SIMDVector3Dot(Triangle.Normal,Segment.Points[0])-dtri;
   d2:=SIMDVector3Dot(Triangle.Normal,Segment.Points[1])-dtri;
   if abs(d2-d1)<EPSILON then begin
    // segment is parallel to triangle
    ClosestPointOnSegment:=SIMDVector3Avg(Segment.Points[0],Segment.Points[1]);
    MinDist:=d1;
    Time:=0.5;
   end	else if abs(d1)<abs(d2) then begin
    ClosestPointOnSegment:=Segment.Points[0];
    MinDist:=d1;
    Time:=0.0;
   end else begin
    ClosestPointOnSegment:=Segment.Points[1];
    MinDist:=d2;
    Time:=1.0;
   end;
   ClosestPointOnTriangle:=SIMDVector3Add(ClosestPointOnSegment,SIMDVector3ScalarMul(Triangle.Normal,-MinDist));
   result:=true;
   exit;
  end else if pAInside then begin
   // one point is inside triangle
   ClosestPointOnSegment:=Segment.Points[0];
   Time:=0.0;
   MinDist:=SIMDVector3Dot(Triangle.Normal,ClosestPointOnSegment)-dtri;
   ClosestPointOnTriangle:=SIMDVector3Add(ClosestPointOnSegment,SIMDVector3ScalarMul(Triangle.Normal,-MinDist));
   MinDist:=sqr(MinDist);
  end else if pBInside then begin
   // one point is inside triangle
   ClosestPointOnSegment:=Segment.Points[1];
   Time:=1.0;
   MinDist:=SIMDVector3Dot(Triangle.Normal,ClosestPointOnSegment)-dtri;
   ClosestPointOnTriangle:=SIMDVector3Add(ClosestPointOnSegment,SIMDVector3ScalarMul(Triangle.Normal,-MinDist));
   MinDist:=sqr(MinDist);
  end;

  // test edge 1
  Edge.Points[0]:=Triangle.Points[0];
  Edge.Points[1]:=Triangle.Points[1];
  SIMDSegmentClosestPoints(Segment,Edge,sa,pa,sb,pb);
  Dist:=SIMDVector3DistSquared(pa,pb);
  if Dist<MinDist then begin
   MinDist:=Dist;
   Time:=sa;
   ClosestPointOnSegment:=pa;
   ClosestPointOnTriangle:=pb;
  end;

  // test edge 2
  Edge.Points[0]:=Triangle.Points[1];
  Edge.Points[1]:=Triangle.Points[2];
  SIMDSegmentClosestPoints(Segment,Edge,sa,pa,sb,pb);
  Dist:=SIMDVector3DistSquared(pa,pb);
  if Dist<MinDist then begin
   MinDist:=Dist;
   Time:=sa;
   ClosestPointOnSegment:=pa;
   ClosestPointOnTriangle:=pb;
  end;

  // test edge 3
  Edge.Points[0]:=Triangle.Points[2];
  Edge.Points[1]:=Triangle.Points[0];
  SIMDSegmentClosestPoints(Segment,Edge,sa,pa,sb,pb);
  Dist:=SIMDVector3DistSquared(pa,pb);
  if Dist<MinDist then begin
   MinDist:=Dist;
   Time:=sa;
   ClosestPointOnSegment:=pa;
   ClosestPointOnTriangle:=pb;
  end;

 end;
  
end;

procedure DoCalculateInterval(const Vertices:PVector3s;const Count:longint;const Axis:TVector3;out OutMin,OutMax:single);
var Distance:single;
    Index:longint;
begin
 Distance:=Vector3Dot(Vertices^[0],Axis);
 OutMin:=Distance;
 OutMax:=Distance;
 for Index:=1 to Count-1 do begin
  Distance:=Vector3Dot(Vertices^[Index],Axis);
  if OutMin>Distance then begin
   OutMin:=Distance;
  end;
  if OutMax<Distance then begin
   OutMax:=Distance;
  end;
 end;
end;

function DoSpanIntersect(const Vertices1:PVector3s;const Count1:longint;const Vertices2:PVector3s;const Count2:longint;const AxisTest:TVector3;out AxisPenetration:TVector3):single;
var min1,max1,min2,max2,len1,len2:single;
begin
 AxisPenetration:=Vector3Norm(AxisTest);
 DoCalculateInterval(Vertices1,Count1,AxisPenetration,min1,max1);
 DoCalculateInterval(Vertices2,Count2,AxisPenetration,min2,max2);
 if (max1<min2) or (min1>max2) then begin
  result:=-1.0;
 end else begin
  len1:=max1-min1;
  len2:=max2-min2;
  if (min1>min2) and (max1<max2) then begin
   result:=len1+min(abs(min1-min2),abs(max1-max2));
  end else if (min2>min1) and (max2<max1) then begin
   result:=len2+min(abs(min1-min2),abs(max1-max2));
  end else begin
   result:=(len1+len2)-(max(max1,max2)-min(min1,min2));
  end;
	if min2<min1 then begin
   AxisPenetration:=Vector3Neg(AxisPenetration);
  end;
 end;
end;

function CollideOBBTriangle(const OBB:TOBB;const v0,v1,v2:TVector3;out Position,Normal:TVector3;out Penetration:single):boolean;
const OBBEdges:array[0..11,0..1] of longint=
       ((0,1),
        (0,3),
        (0,4),
        (1,2),
        (1,5),
        (2,3),
        (2,6),
        (3,7),
        (4,5),
        (4,7),
        (5,6),
        (6,7));
      ModuloThree:array[0..5] of longint=(0,1,2,0,1,2);
var OBBVertices:array[0..7] of TVector3;
    TriangleVertices,TriangleEdges:array[0..2] of TVector3;
    TriangleNormal,BestAxis,CurrentAxis,v,p,n,pt0,pt1:TVector3;
    BestPenetration,CurrentPenetration,tS,tT0,tT1:single;
    BestAxisIndex,i,j:longint;
    seg,s1,s2:TSegment;
    SegmentTriangle:TSegmentTriangle;
begin
 result:=false;

 // ---
 OBBVertices[0]:=Vector3Add(Vector3Add(Vector3Add(OBB.Center,Vector3ScalarMul(OBB.Axis[0],-OBB.Extents.x)),Vector3ScalarMul(OBB.Axis[1],-OBB.Extents.y)),Vector3ScalarMul(OBB.Axis[2],-OBB.Extents.z));
 // +--
 OBBVertices[1]:=Vector3Add(Vector3Add(Vector3Add(OBB.Center,Vector3ScalarMul(OBB.Axis[0],OBB.Extents.x)),Vector3ScalarMul(OBB.Axis[1],-OBB.Extents.y)),Vector3ScalarMul(OBB.Axis[2],-OBB.Extents.z));
 // ++-
 OBBVertices[2]:=Vector3Add(Vector3Add(Vector3Add(OBB.Center,Vector3ScalarMul(OBB.Axis[0],OBB.Extents.x)),Vector3ScalarMul(OBB.Axis[1],OBB.Extents.y)),Vector3ScalarMul(OBB.Axis[2],-OBB.Extents.z));
 // -+-
 OBBVertices[3]:=Vector3Add(Vector3Add(Vector3Add(OBB.Center,Vector3ScalarMul(OBB.Axis[0],-OBB.Extents.x)),Vector3ScalarMul(OBB.Axis[1],OBB.Extents.y)),Vector3ScalarMul(OBB.Axis[2],-OBB.Extents.z));
 // --+
 OBBVertices[4]:=Vector3Add(Vector3Add(Vector3Add(OBB.Center,Vector3ScalarMul(OBB.Axis[0],-OBB.Extents.x)),Vector3ScalarMul(OBB.Axis[1],-OBB.Extents.y)),Vector3ScalarMul(OBB.Axis[2],OBB.Extents.z));
 // +-+
 OBBVertices[5]:=Vector3Add(Vector3Add(Vector3Add(OBB.Center,Vector3ScalarMul(OBB.Axis[0],OBB.Extents.x)),Vector3ScalarMul(OBB.Axis[1],-OBB.Extents.y)),Vector3ScalarMul(OBB.Axis[2],OBB.Extents.z));
 // +++
 OBBVertices[6]:=Vector3Add(Vector3Add(Vector3Add(OBB.Center,Vector3ScalarMul(OBB.Axis[0],OBB.Extents.x)),Vector3ScalarMul(OBB.Axis[1],OBB.Extents.y)),Vector3ScalarMul(OBB.Axis[2],OBB.Extents.z));
 // -++
 OBBVertices[7]:=Vector3Add(Vector3Add(Vector3Add(OBB.Center,Vector3ScalarMul(OBB.Axis[0],-OBB.Extents.x)),Vector3ScalarMul(OBB.Axis[1],OBB.Extents.y)),Vector3ScalarMul(OBB.Axis[2],OBB.Extents.z));

 TriangleVertices[0]:=v0;
 TriangleVertices[1]:=v1;
 TriangleVertices[2]:=v2;

 TriangleEdges[0]:=Vector3Sub(v1,v0);
 TriangleEdges[1]:=Vector3Sub(v2,v1);
 TriangleEdges[2]:=Vector3Sub(v0,v2);

 TriangleNormal:=Vector3Norm(Vector3Cross(TriangleEdges[0],TriangleEdges[1]));

 BestPenetration:=0;
 BestAxis:=Vector3Origin;
 BestAxisIndex:=-1;

 for i:=0 to 2 do begin
  CurrentPenetration:=DoSpanIntersect(@OBBVertices[0],8,@TriangleVertices[0],3,OBB.Axis[i],CurrentAxis);
  if CurrentPenetration<0.0 then begin
   exit;
  end else if (i=0) or (CurrentPenetration<BestPenetration) then begin
   BestPenetration:=CurrentPenetration;
   BestAxis:=CurrentAxis;
   BestAxisIndex:=i;
  end;
 end;

 CurrentPenetration:=DoSpanIntersect(@OBBVertices[0],8,@TriangleVertices[0],3,TriangleNormal,CurrentAxis);
 if CurrentPenetration<0.0 then begin
  exit;
 end else if CurrentPenetration<BestPenetration then begin
  BestPenetration:=CurrentPenetration;
  BestAxis:=CurrentAxis;
  BestAxisIndex:=3;
 end;

 for i:=0 to 2 do begin
  for j:=0 to 2 do begin
   CurrentPenetration:=DoSpanIntersect(@OBBVertices[0],8,@TriangleVertices[0],3,Vector3Cross(OBB.Axis[i],TriangleEdges[j]),CurrentAxis);
   if CurrentPenetration<0.0 then begin
    exit;
   end else if CurrentPenetration<BestPenetration then begin
    BestPenetration:=CurrentPenetration;
    BestAxis:=CurrentAxis;
    BestAxisIndex:=((i*3)+j)+4;
   end;
  end;
 end;

 Penetration:=BestPenetration;
 Normal:=BestAxis;

 if BestAxisIndex>=0 then begin
  j:=0;
  v:=Vector3Origin;
  SegmentTriangle.Origin:=v0;
  SegmentTriangle.Edge0:=Vector3Sub(v1,v0);
  SegmentTriangle.Edge1:=Vector3Sub(v2,v0);
  for i:=0 to 11 do begin
   seg.Origin:=OBBVertices[OBBEdges[i,0]];
   seg.Delta:=Vector3Sub(OBBVertices[OBBEdges[i,1]],OBBVertices[OBBEdges[i,0]]);
   if SegmentTriangleIntersection(tS,tT0,tT1,seg,SegmentTriangle) then begin
    v:=Vector3Add(v,Vector3Add(seg.Origin,Vector3ScalarMul(seg.Delta,tS)));
    inc(j);
   end;
  end;
  for i:=0 to 2 do begin
   pt0:=TriangleVertices[i];
   pt1:=TriangleVertices[ModuloThree[i+1]];
   s1.Origin:=pt0;
   s1.Delta:=Vector3Sub(pt1,pt0);
   s2.Origin:=pt1;
   s2.Delta:=Vector3Sub(pt0,pt1);
   if BoxSegmentIntersect(OBB,tS,p,n,s1) then begin
    v:=Vector3Add(v,p);
    inc(j);
   end;
   if BoxSegmentIntersect(OBB,tS,p,n,s2) then begin
    v:=Vector3Add(v,p);
    inc(j);
   end;
  end;
  if j>0 then begin
   Position:=Vector3ScalarMul(v,1.0/j);
  end else begin
   ClosestPointToOBB(OBB,Vector3ScalarMul(Vector3Add(Vector3Add(v0,v1),v2),1.0/3.0),Position);
  end;
 end;

 result:=true;

end;

function RayIntersectTriangle(const RayOrigin,RayDirection,v0,v1,v2:TVector3;var Time,u,v:single):boolean; overload;
var e0,e1,p,t,q:TVector3;
    Determinant,InverseDeterminant:single;
begin
 result:=false;

 e0.x:=v1.x-v0.x;
 e0.y:=v1.y-v0.y;
 e0.z:=v1.z-v0.z;
 e1.x:=v2.x-v0.x;
 e1.y:=v2.y-v0.y;
 e1.z:=v2.z-v0.z;

 p.x:=(RayDirection.y*e1.z)-(RayDirection.z*e1.y);
 p.y:=(RayDirection.z*e1.x)-(RayDirection.x*e1.z);
 p.z:=(RayDirection.x*e1.y)-(RayDirection.y*e1.x);

 Determinant:=(e0.x*p.x)+(e0.y*p.y)+(e0.z*p.z);
 if Determinant<1e-4 then begin
  exit;
 end;

 t.x:=RayOrigin.x-v0.x;
 t.y:=RayOrigin.y-v0.y;
 t.z:=RayOrigin.z-v0.z;

 u:=(t.x*p.x)+(t.y*p.y)+(t.z*p.z);
 if (u<0.0) or (u>Determinant) then begin
  exit;
 end;

 q.x:=(t.y*e0.z)-(t.z*e0.y);
 q.y:=(t.z*e0.x)-(t.x*e0.z);
 q.z:=(t.x*e0.y)-(t.y*e0.x);

 v:=(RayDirection.x*q.x)+(RayDirection.y*q.y)+(RayDirection.z*q.z);
 if (v<0.0) or ((u+v)>Determinant) then begin
  exit;
 end;

 Time:=(e1.x*q.x)+(e1.y*q.y)+(e1.z*q.z);
 if abs(Determinant)<EPSILON then begin
  Determinant:=0.01;
 end;
 InverseDeterminant:=1.0/Determinant;
 Time:=Time*InverseDeterminant;
 u:=u*InverseDeterminant;
 v:=v*InverseDeterminant;

 result:=true;
end;

function RayIntersectTriangle(const RayOrigin,RayDirection,v0,v1,v2:TSIMDVector3;var Time,u,v:single):boolean; overload;
var e0,e1,p,t,q:TVector3;
    Determinant,InverseDeterminant:single;
begin
 result:=false;

 e0.x:=v1.x-v0.x;
 e0.y:=v1.y-v0.y;
 e0.z:=v1.z-v0.z;
 e1.x:=v2.x-v0.x;
 e1.y:=v2.y-v0.y;
 e1.z:=v2.z-v0.z;

 p.x:=(RayDirection.y*e1.z)-(RayDirection.z*e1.y);
 p.y:=(RayDirection.z*e1.x)-(RayDirection.x*e1.z);
 p.z:=(RayDirection.x*e1.y)-(RayDirection.y*e1.x);

 Determinant:=(e0.x*p.x)+(e0.y*p.y)+(e0.z*p.z);
 if Determinant<1e-4 then begin
  exit;
 end;

 t.x:=RayOrigin.x-v0.x;
 t.y:=RayOrigin.y-v0.y;
 t.z:=RayOrigin.z-v0.z;

 u:=(t.x*p.x)+(t.y*p.y)+(t.z*p.z);
 if (u<0.0) or (u>Determinant) then begin
  exit;
 end;

 q.x:=(t.y*e0.z)-(t.z*e0.y);
 q.y:=(t.z*e0.x)-(t.x*e0.z);
 q.z:=(t.x*e0.y)-(t.y*e0.x);

 v:=(RayDirection.x*q.x)+(RayDirection.y*q.y)+(RayDirection.z*q.z);
 if (v<0.0) or ((u+v)>Determinant) then begin
  exit;
 end;

 Time:=(e1.x*q.x)+(e1.y*q.y)+(e1.z*q.z);
 if abs(Determinant)<EPSILON then begin
  Determinant:=0.01;
 end;
 InverseDeterminant:=1.0/Determinant;
 Time:=Time*InverseDeterminant;
 u:=u*InverseDeterminant;
 v:=v*InverseDeterminant;

 result:=true;
end;

function SegmentTriangleIntersection(out tS,tT0,tT1:single;seg:TSegment;triangle:TSegmentTriangle):boolean;
var u,v,t,a,f:single;
    e1,e2,p,s,q:TVector3;
begin
 result:=false;
 tS:=0.0;
 tT0:=0.0;
 tT1:=0.0;

 e1:=triangle.Edge0;
 e2:=triangle.Edge1;

 p:=Vector3Cross(seg.Delta,e2);
 a:=Vector3Dot(e1,p);
 if abs(a)<EPSILON then begin
  exit;
 end;

 f:=1.0/a;

 s:=Vector3Sub(seg.Origin,triangle.Origin);
 u:=f*Vector3Dot(s,p);
 if (u<0.0) or (u>1.0) then begin
  exit;
 end;

 q:=Vector3Cross(s,e1);
 v:=f*Vector3Dot(seg.Delta,q);
 if (v<0.0) or ((u+v)>1.0) then begin
  exit;
 end;

 t:=f*Vector3Dot(e2,q);
 if (t<0.0) or (t>1.0) then begin
  exit;
 end;

 tS:=t;
 tT0:=u;
 tT1:=v;

 result:=true;
end;

function BoxSegmentIntersect(const OBB:TOBB;out fracOut:single;out posOut,NormalOut:TVector3;seg:TSegment):boolean;
var min_,max_,e,f,t1,t2,t:single;
    p,h:TVector3;
    dirMax,dirMin,dir:longint;
begin
 result:=false;

 fracOut:=1e+34;
 posOut:=Vector3Origin;
 normalOut:=Vector3Origin;

 min_:=-1e+34;
 max_:=1e+34;

 p:=Vector3Sub(OBB.Center,Seg.Origin);
 h:=obb.Extents;

 dirMax:=0;             
 dirMin:=0;

 for dir:=0 to 2 do begin
  e:=Vector3Dot(OBB.Axis[Dir],p);
  f:=Vector3Dot(OBB.Axis[Dir],Seg.Delta);
  if abs(f)>EPSILON then begin
   t1:=(e+OBB.Extents.xyz[dir])/f;
   t2:=(e-OBB.Extents.xyz[dir])/f;
   if t1>t2 then begin
    t:=t1;
    t1:=t2;
    t2:=t;
   end;
   if min_<t1 then begin
    min_:=t1;
    dirMin:=dir;
   end;
   if max_>t2 then begin
    max_:=t2;
    dirMax:=dir;
   end;
   if (min_>max_) or (max_<0.0) then begin
    exit;
   end;
  end else if (((-e)-OBB.Extents.xyz[dir])>0.0) or (((-e)+OBB.Extents.xyz[dir])<0.0) then begin
   exit;
  end;
 end;

 if min_>0.0 then begin
  dir:=dirMin;
  fracOut:=min_;
 end else begin
  dir:=dirMax;
  fracOut:=max_;
 end;

 fracOut:=Min(Max(fracOut,0.0),1.0);

 posOut:=Vector3Add(Seg.Origin,Vector3ScalarMul(Seg.Delta,fracOut));

 if Vector3Dot(OBB.Axis[dir],Seg.Delta)>0.0 then begin
  normalOut:=Vector3Neg(OBB.Axis[dir]);
 end else begin
  normalOut:=OBB.Axis[dir];
 end;

 result:=true;
end;

function SegmentSegmentDistanceSq(out t0,t1:single;seg0,seg1:TSegment):single;
var kDiff:TVector3;
    fA00,fA01,fA11,fB0,fC,fDet,fB1,fS,fT,fSqrDist,fTmp,fInvDet:single;
begin
 kDiff:=Vector3Sub(seg0.Origin,seg1.Origin);
 fA00:=Vector3LengthSquared(seg0.Delta);
 fA01:=-Vector3Dot(seg0.Delta,seg1.Delta);
 fA11:=Vector3LengthSquared(seg1.Delta);
 fB0:=Vector3Dot(kDiff,seg0.Delta);
 fC:=Vector3LengthSquared(kDiff);
 fDet:=abs((fA00*fA11)-(fA01*fA01));
 if fDet>=EPSILON then begin
  // line segments are not parallel
  fB1:=-Vector3Dot(kDiff,seg1.Delta);
  fS:=(fA01*fB1)-(fA11*fB0);
  fT:=(fA01*fB0)-(fA00*fB1);
  if fS>=0.0 then begin
   if fS<=fDet then begin
    if fT>=0.0 then begin
     if fT<=fDet then begin // region 0 (interior)
      // minimum at two interior points of 3D lines
      fInvDet:=1.0/fDet;
      fS:=fS*fInvDet;
      fT:=fT*fInvDet;
      fSqrDist:=(fS*((fA00*fS)+(fA01*fT)+(2.0*fB0)))+(fT*((fA01*fS)+(fA11*fT)+(2.0*fB1)))+fC;
     end else begin // region 3 (side)
      fT:=1.0;
      fTmp:=fA01+fB0;
      if fTmp>=0.0 then begin
       fS:=0.0;
       fSqrDist:=fA11+(2.0*fB1)+fC;
      end else if (-fTmp)>=fA00 then begin
       fS:=1.0;
       fSqrDist:=fA00+fA11+fC+(2.0*(fB1+fTmp));
      end else begin
       fS:=-fTmp/fA00;
       fSqrDist:=fTmp*fS+fA11+(2.0*fB1)+fC;
      end;
     end;
    end else begin // region 7 (side)
     fT:=0.0;
     if fB0>=0.0 then begin
      fS:=0.0;
      fSqrDist:=fC;
     end else if (-fB0)>=fA00 then begin
      fS:=1.0;
      fSqrDist:=fA00+(2.0*fB0)+fC;
     end else begin
      fS:=(-fB0)/fA00;
      fSqrDist:=(fB0*fS)+fC;
     end;
    end;
   end else begin
    if fT>=0.0 then begin
     if fT<=fDet then begin // region 1 (side)
      fS:=1.0;
      fTmp:=fA01+fB1;
      if fTmp>=0.0 then begin
       fT:=0.0;
       fSqrDist:=fA00+(2.0*fB0)+fC;
      end else if (-fTmp)>=fA11 then begin
       fT:=1.0;
       fSqrDist:=fA00+fA11+fC+(2.0*(fB0+fTmp));
      end else begin
       fT:=(-fTmp)/fA11;
       fSqrDist:=(fTmp*fT)+fA00+(2.0*fB0)+fC;
      end;
     end else begin // region 2 (corner)
      fTmp:=fA01+fB0;
      if (-fTmp)<=fA00 then begin
       fT:=1.0;
       if fTmp>=0.0 then begin
        fS:=0.0;
        fSqrDist:=fA11+(2.0*fB1)+fC;
       end else begin
        fS:=(-fTmp)/fA00;
        fSqrDist:=(fTmp*fS)+fA11+(2.0*fB1)+fC;
       end;
      end else begin
       fS:=1.0;
       fTmp:=fA01+fB1;
       if fTmp>=0.0 then begin
        fT:=0.0;
        fSqrDist:=fA00+(2.0*fB0)+fC;
       end else if (-fTmp)>=fA11 then begin
        fT:=1.0;
        fSqrDist:=fA00+fA11+fC+(2.0*(fB0+fTmp));
       end else begin
        fT:=(-fTmp)/fA11;
        fSqrDist:=(fTmp*fT)+fA00+(2.0*fB0)+fC;
       end;
      end;
     end;
    end else begin // region 8 (corner)
     if (-fB0)<fA00 then begin
      fT:=0.0;
      if fB0>=0.0 then begin
       fS:=0.0;
       fSqrDist:=fC;
      end else begin
       fS:=(-fB0)/fA00;
       fSqrDist:=(fB0*fS)+fC;
      end;
     end else begin
      fS:=1.0;
      fTmp:=fA01+fB1;
      if fTmp>=0.0 then begin
       fT:=0.0;
       fSqrDist:=fA00+(2.0*fB0)+fC;
      end else if (-fTmp)>=fA11 then begin
       fT:=1.0;
       fSqrDist:=fA00+fA11+fC+(2.0*(fB0+fTmp));
      end else begin
       fT:=(-fTmp)/fA11;
       fSqrDist:=(fTmp*fT)+fA00+(2.0*fB0)+fC;
      end;
      end;
    end;
   end;
  end else begin
   if fT>=0.0 then begin
    if fT<=fDet then begin // region 5 (side)
     fS:=0.0;
     if fB1>=0.0 then begin
      fT:=0.0;
      fSqrDist:=fC;
     end else if (-fB1)>=fA11 then begin
      fT:=1.0;
      fSqrDist:=fA11+(2.0*fB1)+fC;
     end else begin
      fT:=(-fB1)/fA11;
      fSqrDist:=fB1*fT+fC;
     end
    end else begin // region 4 (corner)
     fTmp:=fA01+fB0;
     if fTmp<0.0 then begin
      fT:=1.0;
      if (-fTmp)>=fA00 then begin
       fS:=1.0;
       fSqrDist:=fA00+fA11+fC+(2.0*(fB1+fTmp));
      end else begin
       fS:=(-fTmp)/fA00;
       fSqrDist:=fTmp*fS+fA11+(2.0*fB1)+fC;
      end;
     end else begin
      fS:=0.0;
      if fB1>=0.0 then begin
       fT:=0.0;
       fSqrDist:=fC;
      end else if (-fB1)>=fA11 then begin
       fT:=1.0;
       fSqrDist:=fA11+(2.0*fB1)+fC;
      end else begin
       fT:=(-fB1)/fA11;
       fSqrDist:=(fB1*fT)+fC;
      end;
     end;
    end;
   end else begin // region 6 (corner)
    if fB0<0.0 then begin
     fT:=0.0;
     if (-fB0)>=fA00 then begin
      fS:=1.0;
      fSqrDist:=fA00+(2.0*fB0)+fC;
     end else begin
      fS:=(-fB0)/fA00;
      fSqrDist:=(fB0*fS)+fC;
     end;
    end else begin
     fS:=0.0;
     if fB1>=0.0 then begin
      fT:=0.0;
      fSqrDist:=fC;
     end else if (-fB1)>=fA11 then begin
      fT:=1.0;
      fSqrDist:=fA11+(2.0*fB1)+fC;
     end else begin
      fT:=(-fB1)/fA11;
      fSqrDist:=(fB1*fT)+fC;
     end;
    end;
   end;
  end;
 end else begin // line segments are parallel
  if fA01>0.0 then begin // direction vectors form an obtuse angle
   if fB0>=0.0 then begin
    fS:=0.0;
    fT:=0.0;
    fSqrDist:=fC;
   end else if (-fB0)<=fA00 then begin
    fS:=(-fB0)/fA00;
    fT:=0.0;
    fSqrDist:=(fB0*fS)+fC;
   end else begin
    fB1:=-Vector3Dot(kDiff,seg1.Delta);
    fS:=1.0;
    fTmp:=fA00+fB0;
    if (-fTmp)>=fA01 then begin
     fT:=1.0;
     fSqrDist:=fA00+fA11+fC+(2.0*(fA01+fB0+fB1));
    end else begin
     fT:=(-fTmp)/fA01;
     fSqrDist:=fA00+(2.0*fB0)+fC+(fT*((fA11*fT)+(2.0*(fA01+fB1))));
    end;
   end;
  end else begin // direction vectors form an acute angle
   if (-fB0)>=fA00 then begin
    fS:=1.0;
    fT:=0.0;
    fSqrDist:=fA00+(2.0*fB0)+fC;
   end else if fB0<=0.0 then begin
    fS:=(-fB0)/fA00;
    fT:=0.0;
    fSqrDist:=(fB0*fS)+fC;
   end else begin
    fB1:=-Vector3Dot(kDiff,seg1.Delta);
    fS:=0.0;
    if fB0>=(-fA01) then begin
     fT:=1.0;
     fSqrDist:=fA11+(2.0*fB1)+fC;
    end else begin
     fT:=(-fB0)/fA01;
     fSqrDist:=fC+(fT*((2.0)*fB1)+(fA11*fT));
    end;
   end;
  end;
 end;
 t0:=fS;
 t1:=fT;
 result:=abs(fSqrDist);
end;

function PointTriangleDistanceSq(out pfSParam,pfTParam:single;rkPoint:TVector3;const rkTri:TSegmentTriangle):single;
var kDiff:TVector3;
    fA00,fA01,fA11,fB0,fC,fDet,fB1,fS,fT,fSqrDist,fInvDet,
    fTmp0,fTmp1,fNumer,fDenom:single;
begin
 kDiff:=Vector3Sub(rkTri.Origin,rkPoint);
 fA00:=Vector3LengthSquared(rkTri.Edge0);
 fA01:=Vector3Dot(rkTri.Edge0,rkTri.Edge1);
 fA11:=Vector3LengthSquared(rkTri.Edge1);
 fB0:=Vector3Dot(kDiff,rkTri.Edge0);
 fB1:=Vector3Dot(kDiff,rkTri.Edge1);
 fC:=Vector3LengthSquared(kDiff);
 fDet:=max(abs((fA00*fA11)-(fA01*fA01)),EPSILON);
 fS:=(fA01*fB1)-(fA11*fB0);
 fT:=(fA01*fB0)-(fA00*fB1);
 if (fS+fT)<=fDet then begin
  if fS<0.0 then begin
   if fT<0.0 then begin // region 4
    if fB0<0.0 then begin
     fT:=0.0;
     if (-fB0)>=fA00 then begin
      fS:=1.0;
      fSqrDist:=fA00+(2.0*fB0)+fC;
     end else begin
      fS:=(-fB0)/fA00;
      fSqrDist:=(fB0*fS)+fC;
     end;
    end else begin
     fS:=0.0;
     if fB1>=0.0 then begin
      fT:=0.0;
      fSqrDist:=fC;
     end else if (-fB1)>=fA11 then begin
      fT:=1.0;
      fSqrDist:=fA11+(2.0*fB1)+fC;
     end else begin
      fT:=(-fB1)/fA11;
      fSqrDist:=(fB1*fT)+fC;
     end;
    end;
   end else begin // region 3
    fS:=0.0;
    if fB1>=0.0 then begin
     fT:=0.0;
     fSqrDist:=fC;
    end else if (-fB1)>=fA11 then begin
     fT:=1.0;
     fSqrDist:=fA11+(2.0*fB1)+fC;
    end else begin
     fT:=(-fB1)/fA11;
     fSqrDist:=(fB1*fT)+fC;
    end;
   end;
  end else if fT<0.0 then begin // region 5
   fT:=0.0;
   if fB0>=0.0 then begin
    fS:=0.0;
    fSqrDist:=fC;
   end else if (-fB0)>=fA00 then begin
    fS:=1.0;
    fSqrDist:=fA00+(2.0*fB0)+fC;
   end else begin
    fS:=(-fB0)/fA00;
    fSqrDist:=(fB0*fS)+fC;
   end;
  end else begin // region 0
   // minimum at interior point
   fInvDet:=1.0/fDet;
   fS:=fS*fInvDet;
   fT:=fT*fInvDet;
   fSqrDist:=(fS*((fA00*fS)+(fA01*fT)+(2.0*fB0)))+(fT*((fA01*fS)+(fA11*fT)+(2.0*fB1)))+fC;
  end;
 end else begin
  if fS<0.0 then begin // region 2
   fTmp0:=fA01+fB0;
   fTmp1:=fA11+fB1;
   if fTmp1>fTmp0 then begin
    fNumer:=fTmp1-fTmp0;
    fDenom:=fA00-(2.0*fA01)+fA11;
    if fNumer>=fDenom then begin
     fS:=1.0;
     fT:=0.0;
     fSqrDist:=fA00+(2.0*fB0)+fC;
    end else begin
     fS:=fNumer/fDenom;
     fT:=1.0-fS;
     fSqrDist:=(fS*((fA00*fS)+(fA01*fT)+(2*fB0)))+(fT*((fA01*fS)+(fA11*fT)+(2*fB1)))+fC;
    end;
   end else begin
    fS:=0.0;
    if fTmp1<=0.0 then begin
     fT:=1.0;
     fSqrDist:=fA11+(2.0*fB1)+fC;
    end else if fB1>=0.0 then begin
     fT:=0.0;
     fSqrDist:=fC;
    end else begin
     fT:=(-fB1)/fA11;
     fSqrDist:=(fB1*fT)+fC;
    end;
   end;
  end else if fT<0.0 then begin // region 6
   fTmp0:=fA01+fB1;
   fTmp1:=fA00+fB0;
   if fTmp1>fTmp0 then begin
    fNumer:=fTmp1-fTmp0;
    fDenom:=fA00-(2.0*fA01)+fA11;
    if fNumer>=fDenom then begin
     fT:=1.0;
     fS:=0.0;
     fSqrDist:=fA11+(2*fB1)+fC;
    end else begin
     fT:=fNumer/fDenom;
     fS:=1.0-fT;
     fSqrDist:=(fS*((fA00*fS)+(fA01*fT)+(2.0*fB0)))+(fT*((fA01*fS)+(fA11*fT)+(2.0*fB1)))+fC;
    end;
   end else begin
    fT:=0.0;
    if fTmp1<=0.0 then begin
     fS:=1.0;
     fSqrDist:=fA00+(2.0*fB0)+fC;
    end else if fB0>=0.0 then begin
     fS:=0.0;
     fSqrDist:=fC;
    end else begin
     fS:=(-fB0)/fA00;
     fSqrDist:=(fB0*fS)+fC;
    end;
   end;
  end else begin // region 1
   fNumer:=((fA11+fB1)-fA01)-fB0;
   if fNumer<=0.0 then begin
    fS:=0.0;
    fT:=1.0;
    fSqrDist:=fA11+(2.0*fB1)+fC;
   end else begin
    fDenom:=fA00-(2.0*fA01)+fA11;
    if fNumer>=fDenom then begin
     fS:=1.0;
     fT:=0.0;
     fSqrDist:=fA00+(2.0*fB0)+fC;
    end else begin
     fS:=fNumer/fDenom;
     fT:=1.0-fS;
     fSqrDist:=(fS*((fA00*fS)+(fA01*fT)+(2.0*fB0)))+(fT*((fA01*fS)+(fA11*fT)+(2.0*fB1)))+fC;
    end;
   end;
  end;
 end;
 pfSParam:=fS;
 pfTParam:=fT;
 result:=abs(fSqrDist);
end;

function PointTriangleDistance(const Point,t0,t1,t2:TVector3):single; overload;
var SegmentTriangle:TSegmentTriangle;
    s,t:single;
begin
 SegmentTriangle.Origin:=t0;
 SegmentTriangle.Edge0:=Vector3Sub(t1,t0);
 SegmentTriangle.Edge1:=Vector3Sub(t2,t0);
 SegmentTriangle.Edge2:=Vector3Sub(SegmentTriangle.Edge1,SegmentTriangle.Edge0);
{result:=}PointTriangleDistanceSq(s,t,Point,SegmentTriangle);
{if result>1e-12 then begin
  result:=sqrt(result);
 end else if result<1e-12 then begin
  result:=-sqrt(-result);
 end else begin
  result:=0;
 end;}
 result:=Vector3Dist(Point,Vector3Add(SegmentTriangle.Origin,Vector3Add(Vector3ScalarMul(SegmentTriangle.Edge0,s),Vector3ScalarMul(SegmentTriangle.Edge1,t))));
end;

function PointTriangleDistanceSq(const Point,t0,t1,t2:TVector3):single; overload;
var SegmentTriangle:TSegmentTriangle;
    s,t:single;
begin
 SegmentTriangle.Origin:=t0;
 SegmentTriangle.Edge0:=Vector3Sub(t1,t0);
 SegmentTriangle.Edge1:=Vector3Sub(t2,t0);
 SegmentTriangle.Edge2:=Vector3Sub(SegmentTriangle.Edge1,SegmentTriangle.Edge0);
 result:=PointTriangleDistanceSq(s,t,Point,SegmentTriangle);
end;

function PointTriangleDistanceSq(const Point:TVector3;const SegmentTriangle:TSegmentTriangle):single; overload;
var s,t:single;
begin
 result:=PointTriangleDistanceSq(s,t,Point,SegmentTriangle);
end;

function ProjectOnTriangle(var pt:TVector3;const p0,p1,p2:TVector3;s,t:single):single;
var Diff,Edge0,Edge1:TVector3;
    A00,A01,A11,B0,C,Det,B1,SquaredDistance,InvDet,Tmp0,Tmp1,Numer,Denom:single;
begin
 Diff:=Vector3Sub(p0,pt);
 Edge0:=Vector3Sub(p1,p0);
 Edge1:=Vector3Sub(p2,p0);
 A00:=Vector3LengthSquared(Edge0);
 A01:=Vector3Dot(Edge0,Edge1);
 A11:=Vector3LengthSquared(Edge1);
 B0:=Vector3Dot(Diff,Edge0);
 B1:=Vector3Dot(Diff,Edge1);
 C:=Vector3LengthSquared(Diff);
 Det:=max(abs((A00*A11)-(A01*A01)),EPSILON);
 s:=(A01*B1)-(A11*B0);
 t:=(A01*B0)-(A00*B1);
 if (s+t)<=Det then begin
  if s<0.0 then begin
   if t<0.0 then begin // region 4
    if B0<0.0 then begin
     t:=0.0;
     if (-B0)>=A00 then begin
      s:=1.0;
      SquaredDistance:=A00+(2.0*B0)+C;
     end else begin
      s:=(-B0)/A00;
      SquaredDistance:=(B0*s)+C;
     end;
    end else begin
     s:=0.0;
     if B1>=0.0 then begin
      t:=0.0;
      SquaredDistance:=C;
     end else if (-B1)>=A11 then begin
      t:=1.0;
      SquaredDistance:=A11+(2.0*B1)+C;
     end else begin
      t:=(-B1)/A11;
      SquaredDistance:=(B1*t)+C;
     end;
    end;
   end else begin // region 3
    s:=0.0;
    if B1>=0.0 then begin
     t:=0.0;
     SquaredDistance:=C;
    end else if (-B1)>=A11 then begin
     t:=1.0;
     SquaredDistance:=A11+(2.0*B1)+C;
    end else begin
     t:=(-B1)/A11;
     SquaredDistance:=(B1*t)+C;
    end;
   end;
  end else if t<0.0 then begin // region 5
   t:=0.0;
   if B0>=0.0 then begin
    s:=0.0;
    SquaredDistance:=C;
   end else if (-B0)>=A00 then begin
    s:=1.0;
    SquaredDistance:=A00+(2.0*B0)+C;
   end else begin
    s:=(-B0)/A00;
    SquaredDistance:=(B0*s)+C;
   end;
  end else begin // region 0
   // minimum at interior point
   InvDet:=1.0/Det;
   s:=s*InvDet;
   t:=t*InvDet;
   SquaredDistance:=(s*((A00*s)+(A01*t)+(2.0*B0)))+(t*((A01*s)+(A11*t)+(2.0*B1)))+C;
  end;
 end else begin
  if s<0.0 then begin // region 2
   Tmp0:=A01+B0;
   Tmp1:=A11+B1;
   if Tmp1>Tmp0 then begin
    Numer:=Tmp1-Tmp0;
    Denom:=A00-(2.0*A01)+A11;
    if Numer>=Denom then begin
     s:=1.0;
     t:=0.0;
     SquaredDistance:=A00+(2.0*B0)+C;
    end else begin
     s:=Numer/Denom;
     t:=1.0-s;
     SquaredDistance:=(s*((A00*s)+(A01*t)+(2*B0)))+(t*((A01*s)+(A11*t)+(2*B1)))+C;
    end;
   end else begin
    s:=0.0;
    if Tmp1<=0.0 then begin
     t:=1.0;
     SquaredDistance:=A11+(2.0*B1)+C;
    end else if B1>=0.0 then begin
     t:=0.0;
     SquaredDistance:=C;
    end else begin
     t:=(-B1)/A11;
     SquaredDistance:=(B1*t)+C;
    end;
   end;
  end else if t<0.0 then begin // region 6
   Tmp0:=A01+B1;
   Tmp1:=A00+B0;
   if Tmp1>Tmp0 then begin
    Numer:=Tmp1-Tmp0;
    Denom:=A00-(2.0*A01)+A11;
    if Numer>=Denom then begin
     t:=1.0;
     s:=0.0;
     SquaredDistance:=A11+(2*B1)+C;
    end else begin
     t:=Numer/Denom;
     s:=1.0-t;
     SquaredDistance:=(s*((A00*s)+(A01*t)+(2.0*B0)))+(t*((A01*s)+(A11*t)+(2.0*B1)))+C;
    end;
   end else begin
    t:=0.0;
    if Tmp1<=0.0 then begin
     s:=1.0;
     SquaredDistance:=A00+(2.0*B0)+C;
    end else if B0>=0.0 then begin
     s:=0.0;
     SquaredDistance:=C;
    end else begin
     s:=(-B0)/A00;
     SquaredDistance:=(B0*s)+C;
    end;
   end;
  end else begin // region 1
   Numer:=((A11+B1)-A01)-B0;
   if Numer<=0.0 then begin
    s:=0.0;
    t:=1.0;
    SquaredDistance:=A11+(2.0*B1)+C;
   end else begin
    Denom:=A00-(2.0*A01)+A11;
    if Numer>=Denom then begin
     s:=1.0;
     t:=0.0;
     SquaredDistance:=A00+(2.0*B0)+C;
    end else begin
     s:=Numer/Denom;
     t:=1.0-s;
     SquaredDistance:=(s*((A00*s)+(A01*t)+(2.0*B0)))+(t*((A01*s)+(A11*t)+(2.0*B1)))+C;
    end;
   end;
  end;
 end;
 pt.x:=p0.x+((Edge0.x*s)+(Edge1.x*t));
 pt.y:=p0.y+((Edge0.y*s)+(Edge1.y*t));
 pt.z:=p0.z+((Edge0.z*s)+(Edge1.z*t));
 result:=abs(SquaredDistance);
end;

function ClosestPointOnTriangle(const p0,p1,p2,pt:TVector3;var ClosestPoint:TVector3):single;
var Diff,Edge0,Edge1:TVector3;
    A00,A01,A11,B0,C,Det,B1,s,t,SquaredDistance,InvDet,Tmp0,Tmp1,Numer,Denom:single;
begin
 Diff:=Vector3Sub(p0,pt);
 Edge0:=Vector3Sub(p1,p0);
 Edge1:=Vector3Sub(p2,p0);
 A00:=Vector3LengthSquared(Edge0);
 A01:=Vector3Dot(Edge0,Edge1);
 A11:=Vector3LengthSquared(Edge1);
 B0:=Vector3Dot(Diff,Edge0);
 B1:=Vector3Dot(Diff,Edge1);
 C:=Vector3LengthSquared(Diff);
 Det:=max(abs((A00*A11)-(A01*A01)),EPSILON);
 s:=(A01*B1)-(A11*B0);
 t:=(A01*B0)-(A00*B1);
 if (s+t)<=Det then begin
  if s<0.0 then begin
   if t<0.0 then begin // region 4
    if B0<0.0 then begin
     t:=0.0;
     if (-B0)>=A00 then begin
      s:=1.0;
      SquaredDistance:=A00+(2.0*B0)+C;
     end else begin
      s:=(-B0)/A00;
      SquaredDistance:=(B0*s)+C;
     end;
    end else begin
     s:=0.0;
     if B1>=0.0 then begin
      t:=0.0;
      SquaredDistance:=C;
     end else if (-B1)>=A11 then begin
      t:=1.0;
      SquaredDistance:=A11+(2.0*B1)+C;
     end else begin
      t:=(-B1)/A11;
      SquaredDistance:=(B1*t)+C;
     end;
    end;
   end else begin // region 3
    s:=0.0;
    if B1>=0.0 then begin
     t:=0.0;
     SquaredDistance:=C;
    end else if (-B1)>=A11 then begin
     t:=1.0;
     SquaredDistance:=A11+(2.0*B1)+C;
    end else begin
     t:=(-B1)/A11;
     SquaredDistance:=(B1*t)+C;
    end;
   end;
  end else if t<0.0 then begin // region 5
   t:=0.0;
   if B0>=0.0 then begin
    s:=0.0;
    SquaredDistance:=C;
   end else if (-B0)>=A00 then begin
    s:=1.0;
    SquaredDistance:=A00+(2.0*B0)+C;
   end else begin
    s:=(-B0)/A00;
    SquaredDistance:=(B0*s)+C;
   end;
  end else begin // region 0
   // minimum at interior point
   InvDet:=1.0/Det;
   s:=s*InvDet;
   t:=t*InvDet;
   SquaredDistance:=(s*((A00*s)+(A01*t)+(2.0*B0)))+(t*((A01*s)+(A11*t)+(2.0*B1)))+C;
  end;
 end else begin
  if s<0.0 then begin // region 2
   Tmp0:=A01+B0;
   Tmp1:=A11+B1;
   if Tmp1>Tmp0 then begin
    Numer:=Tmp1-Tmp0;
    Denom:=A00-(2.0*A01)+A11;
    if Numer>=Denom then begin
     s:=1.0;
     t:=0.0;
     SquaredDistance:=A00+(2.0*B0)+C;
    end else begin
     s:=Numer/Denom;
     t:=1.0-s;
     SquaredDistance:=(s*((A00*s)+(A01*t)+(2*B0)))+(t*((A01*s)+(A11*t)+(2*B1)))+C;
    end;
   end else begin
    s:=0.0;
    if Tmp1<=0.0 then begin
     t:=1.0;
     SquaredDistance:=A11+(2.0*B1)+C;
    end else if B1>=0.0 then begin
     t:=0.0;
     SquaredDistance:=C;
    end else begin
     t:=(-B1)/A11;
     SquaredDistance:=(B1*t)+C;
    end;
   end;
  end else if t<0.0 then begin // region 6
   Tmp0:=A01+B1;
   Tmp1:=A00+B0;
   if Tmp1>Tmp0 then begin
    Numer:=Tmp1-Tmp0;
    Denom:=A00-(2.0*A01)+A11;
    if Numer>=Denom then begin
     t:=1.0;
     s:=0.0;
     SquaredDistance:=A11+(2*B1)+C;
    end else begin
     t:=Numer/Denom;
     s:=1.0-t;
     SquaredDistance:=(s*((A00*s)+(A01*t)+(2.0*B0)))+(t*((A01*s)+(A11*t)+(2.0*B1)))+C;
    end;
   end else begin
    t:=0.0;
    if Tmp1<=0.0 then begin
     s:=1.0;
     SquaredDistance:=A00+(2.0*B0)+C;
    end else if B0>=0.0 then begin
     s:=0.0;
     SquaredDistance:=C;
    end else begin
     s:=(-B0)/A00;
     SquaredDistance:=(B0*s)+C;
    end;
   end;
  end else begin // region 1
   Numer:=((A11+B1)-A01)-B0;
   if Numer<=0.0 then begin
    s:=0.0;
    t:=1.0;
    SquaredDistance:=A11+(2.0*B1)+C;
   end else begin
    Denom:=A00-(2.0*A01)+A11;
    if Numer>=Denom then begin
     s:=1.0;
     t:=0.0;
     SquaredDistance:=A00+(2.0*B0)+C;
    end else begin
     s:=Numer/Denom;
     t:=1.0-s;
     SquaredDistance:=(s*((A00*s)+(A01*t)+(2.0*B0)))+(t*((A01*s)+(A11*t)+(2.0*B1)))+C;
    end;
   end;
  end;
 end;
 ClosestPoint.x:=p0.x+((Edge0.x*s)+(Edge1.x*t));
 ClosestPoint.y:=p0.y+((Edge0.y*s)+(Edge1.y*t));
 ClosestPoint.z:=p0.z+((Edge0.z*s)+(Edge1.z*t));
 result:=abs(SquaredDistance);
end;

function SegmentTriangleDistanceSq(out segT,triT0,triT1:single;const seg:TSegment;const triangle:TSegmentTriangle):single;
var s,t,u,distEdgeSq,startTriSq,endTriSq:single;
    tseg:TSegment;
begin
 result:=INFINITY; 
 if SegmentTriangleIntersection(segT,triT0,triT1,seg,triangle) then begin
  segT:=0.0;
  triT0:=0.0;
  triT1:=0.0;
  result:=0.0;
  exit;
 end;
 tseg.Origin:=triangle.Origin;
 tseg.Delta:=triangle.Edge0;
 distEdgeSq:=SegmentSegmentDistanceSq(s,t,seg,tseg);
 if distEdgeSq<result then begin
  result:=distEdgeSq;
  segT:=s;
  triT0:=t;
  triT1:=0.0;
 end;
 tseg.Delta:=triangle.Edge1;
 distEdgeSq:=SegmentSegmentDistanceSq(s,t,seg,tseg);
 if distEdgeSq<result then begin
  result:=distEdgeSq;
  segT:=s;
  triT0:=0.0;
  triT1:=t;
 end;
 tseg.Origin:=Vector3Add(triangle.Origin,triangle.Edge1);
 tseg.Delta:=triangle.Edge2;
 distEdgeSq:=SegmentSegmentDistanceSq(s,t,seg,tseg);
 if distEdgeSq<result then begin
  result:=distEdgeSq;
  segT:=s;
  triT0:=1.0-t;
  triT1:=t;
 end;
 startTriSq:=PointTriangleDistanceSq(t,u,seg.Origin,triangle);
 if startTriSq<result then begin
  result:=startTriSq;
  segT:=0.0;
  triT0:=t;
  triT1:=u;
 end;
 endTriSq:=PointTriangleDistanceSq(t,u,Vector3Add(seg.Origin,seg.Delta),triangle);
 if endTriSq<result then begin
  result:=endTriSq;
  segT:=1.0;
  triT0:=t;
  triT1:=u;
 end;
end;

function BoxGetDistanceToPoint(Point:TVector3;const Center,Size:TVector3;const InvTransformMatrix,TransformMatrix:TMatrix4x4;var ClosestBoxPoint:TVector3):single; 
var HalfSize:TVector3;
begin
 result:=0;
 ClosestBoxPoint:=Vector3Sub(Vector3TermMatrixMul(Point,InvTransformMatrix),Center);
 HalfSize.x:=abs(Size.x*0.5);
 HalfSize.y:=abs(Size.y*0.5);
 HalfSize.z:=abs(Size.z*0.5);
 if ClosestBoxPoint.x<-HalfSize.x then begin
  result:=result+sqr(ClosestBoxPoint.x-(-HalfSize.x));
  ClosestBoxPoint.x:=-HalfSize.x;
 end else if ClosestBoxPoint.x>HalfSize.x then begin
  result:=result+sqr(ClosestBoxPoint.x-HalfSize.x);
  ClosestBoxPoint.x:=HalfSize.x;
 end;
 if ClosestBoxPoint.y<-HalfSize.y then begin
  result:=result+sqr(ClosestBoxPoint.y-(-HalfSize.y));
  ClosestBoxPoint.y:=-HalfSize.y;
 end else if ClosestBoxPoint.y>HalfSize.y then begin
  result:=result+sqr(ClosestBoxPoint.y-HalfSize.y);
  ClosestBoxPoint.y:=HalfSize.y;
 end;
 if ClosestBoxPoint.z<-HalfSize.z then begin
  result:=result+sqr(ClosestBoxPoint.z-(-HalfSize.z));
  ClosestBoxPoint.z:=-HalfSize.z;
 end else if ClosestBoxPoint.z>HalfSize.z then begin
  result:=result+sqr(ClosestBoxPoint.z-HalfSize.z);
  ClosestBoxPoint.z:=HalfSize.z;
 end;
 ClosestBoxPoint:=Vector3TermMatrixMul(Vector3Add(ClosestBoxPoint,Center),TransformMatrix);
end;

function GetDistanceFromLine(const p0,p1,p:TVector3;var Projected:TVector3;const Time:psingle=nil):single;
var p10:TVector3;
    t:single;
begin
 p10:=Vector3Sub(p1,p0);
 t:=Vector3Length(p10);
 if t<EPSILON then begin
  p10:=Vector3Origin;
 end else begin
  p10:=Vector3ScalarMul(p10,1.0/t);
 end;
 t:=Vector3Dot(Vector3Sub(p,p0),p10);
 if assigned(Time) then begin
  Time^:=t;
 end;
 Projected:=Vector3Add(p0,Vector3ScalarMul(p10,t));
 result:=Vector3Length(Vector3Sub(p,Projected));
end;

procedure LineClosestApproach(const pa,ua,pb,ub:TVector3;var Alpha,Beta:single);
var p:TVector3;
    uaub,q1,q2,d:single;
begin
 p:=Vector3Sub(pb,pa);
 uaub:=Vector3Dot(ua,ub);
 q1:=Vector3Dot(ua,p);
 q2:=Vector3Dot(ub,p);
 d:=1.0-sqr(uaub);
 if d<EPSILON then begin
  Alpha:=0;
  Beta:=0;
 end else begin
  d:=1.0/d;
  Alpha:=(q1+(uaub*q2))*d;
  Beta:=((uaub*q1)+q2)*d;
 end;
end;

procedure ClosestLineBoxPoints(const p1,p2,c:TVector3;const ir,r:TMatrix4x4;const side:TVector3;var lret,bret:TVector3); 
const tanchorepsilon:single={$ifdef physicsdouble}1e-307{$else}1e-19{$endif};
var tmp,s,v,sign,v2,h:TVector3;
    region:array[0..2] of longint;
    tanchor:array[0..2] of single;
    i:longint;
    t,dd2dt,nextt,nextdd2dt:single;
    DoGetAnswer:boolean;
begin
 s:=Vector3TermMatrixMul(Vector3Sub(p1,c),ir);
 v:=Vector3TermMatrixMul(Vector3Sub(p2,p1),ir);
 for i:=0 to 2 do begin
  if v.xyz[i]<0 then begin
   s.xyz[i]:=-s.xyz[i];
   v.xyz[i]:=-v.xyz[i];
   sign.xyz[i]:=-1;
  end else begin
   sign.xyz[i]:=1;
  end;
 end;
 v2:=Vector3Mul(v,v);
 h:=Vector3ScalarMul(side,0.5);
 for i:=0 to 2 do begin
  if v.xyz[i]>tanchorepsilon then begin
   if s.xyz[i]<-h.xyz[i] then begin
    region[i]:=-1;
    tanchor[i]:=((-h.xyz[i])-s.xyz[i])/v.xyz[i];
   end else begin
    if s.xyz[i]>h.xyz[i] then begin
     region[i]:=1;
    end else begin
     region[i]:=0;
    end;
    tanchor[i]:=(h.xyz[i]-s.xyz[i])/v.xyz[i];
   end;
  end else begin
   region[i]:=0;
   tanchor[i]:=2;
  end;
 end;
 t:=0;
 dd2dt:=0;
 for i:=0 to 2 do begin
  if region[i]<>0 then begin
   dd2dt:=dd2dt-(v2.xyz[i]*tanchor[i]);
  end;
 end;
 if dd2dt<0 then begin
  DoGetAnswer:=false;
  repeat
   nextt:=1;
   for i:=0 to 2 do begin
    if (tanchor[i]>t) and (tanchor[i]<1) and (tanchor[i]<nextt) then begin
     nextt:=tanchor[i];
    end;
   end;
   nextdd2dt:=0;
   for i:=0 to 2 do begin
    if region[i]<>0 then begin
     nextdd2dt:=nextdd2dt+(v2.xyz[i]*(nextt-tanchor[i]));
    end;
   end;
   if nextdd2dt>=0 then begin
    t:=t-(dd2dt/((nextdd2dt-dd2dt)/(nextt-t)));
    DoGetAnswer:=true;
    break;
   end;
   for i:=0 to 2 do begin
    if abs(tanchor[i]-nextt)<EPSILON then begin
     tanchor[i]:=(h.xyz[i]-s.xyz[i])/v.xyz[i];
     inc(region[i]);
    end;
   end;
   t:=nextt;
   dd2dt:=nextdd2dt;
  until t>=1;
  if not DoGetAnswer then begin
   t:=1;
  end;
 end;
 lret:=Vector3Add(p1,Vector3ScalarMul(Vector3Sub(p2,p1),t));
 for i:=0 to 2 do begin
  tmp.xyz[i]:=sign.xyz[i]*(s.xyz[i]+(t*v.xyz[i]));
  if tmp.xyz[i]<-h.xyz[i] then begin
   tmp.xyz[i]:=-h.xyz[i];
  end else if tmp.xyz[i]>h.xyz[i] then begin
   tmp.xyz[i]:=h.xyz[i];
  end;
 end;
 bret:=Vector3Add(c,Vector3TermMatrixMul(tmp,r));
end;

procedure ClosestLineSegmentPoints(const a0,a1,b0,b1:TVector3;var cp0,cp1:TVector3);
var a0a1,b0b1,a0b0,a0b1,a1b0,a1b1,n:TVector3;
    la,lb,k,da0,da1,da2,da3,db0,db1,db2,db3,det,Alpha,Beta:single;
begin
 a0a1:=Vector3Sub(a1,a0);
 b0b1:=Vector3Sub(b1,b0);
 a0b0:=Vector3Sub(b0,a0);
 da0:=Vector3Dot(a0a1,a0b0);
 db0:=Vector3Dot(b0b1,a0b0);
 if (da0<=0) and (db0>=0) then begin
  cp0:=a0;
  cp1:=b0;
  exit;
 end;
 a0b1:=Vector3Sub(b1,a0);
 da1:=Vector3Dot(a0a1,a0b1);
 db1:=Vector3Dot(b0b1,a0b1);
 if (da1<=0) and (db1<=0) then begin
  cp0:=a0;
  cp1:=b1;
  exit;
 end;
 a1b0:=Vector3Sub(b0,a1);
 da2:=Vector3Dot(a0a1,a1b0);
 db2:=Vector3Dot(b0b1,a1b0);
 if (da2>=0) and (db2>=0) then begin
  cp0:=a1;
  cp1:=b0;
  exit;
 end;
 a1b1:=Vector3Sub(b1,a1);
 da3:=Vector3Dot(a0a1,a1b1);
 db3:=Vector3Dot(b0b1,a1b1);
 if (da3>=0) and (db3<=0) then begin
  cp0:=a1;
  cp1:=b1;
  exit;
 end;
 la:=Vector3Dot(a0a1,a0a1);
 if (da0>=0) and (da2<=0) then begin
  k:=da0/la;
  n:=Vector3Sub(a0b0,Vector3ScalarMul(a0a1,k));
  if Vector3Dot(b0b1,n)>=0 then begin
   cp0:=Vector3Add(a0,Vector3ScalarMul(a0a1,k));
   cp1:=b0;
   exit;
  end;
 end;
 if (da1>=0) and (da3<=0) then begin
  k:=da1/la;
  n:=Vector3Sub(a0b1,Vector3ScalarMul(a0a1,k));
  if Vector3Dot(b0b1,n)<=0 then begin
   cp0:=Vector3Add(a0,Vector3ScalarMul(a0a1,k));
   cp1:=b1;
   exit;
  end;
 end;
 lb:=Vector3Dot(b0b1,b0b1);
 if (db0<=0) and (db1>=0) then begin
  k:=-db0/lb;
  n:=Vector3Sub(Vector3Neg(a0a1),Vector3ScalarMul(b0b1,k));
  if Vector3Dot(a0a1,n)>=0 then begin
   cp0:=a0;
   cp1:=Vector3Add(b0,Vector3ScalarMul(b0b1,k));
   exit;
  end;
 end;
 if (db2<=0) and (db3>=0) then begin
  k:=-db2/lb;
  n:=Vector3Sub(Vector3Neg(a1b0),Vector3ScalarMul(b0b1,k));
  if Vector3Dot(a0a1,n)>=0 then begin
   cp0:=a1;
   cp1:=Vector3Add(b0,Vector3ScalarMul(b0b1,k));
   exit;
  end;
 end;
 k:=Vector3Dot(a0a1,b0b1);
 det:=(la*lb)-sqr(k);
 if det<=EPSILON then begin
  cp0:=a0;
  cp1:=b0;
 end else begin
  det:=1/det;
  Alpha:=((lb*da0)-(k*db0))*det;
  Beta:=((k*da0)-(la*db0))*det;
  cp0:=Vector3Add(a0,Vector3ScalarMul(a0a1,Alpha));
  cp1:=Vector3Add(b0,Vector3ScalarMul(b0b1,Beta));
 end;
end;

function LineSegmentIntersection(const a0,a1,b0,b1:TVector3;const p:PVector3=nil):boolean;
var da,db,dc,cdadb:TVector3;
    t:single;
begin
 result:=false;
 da:=Vector3Sub(a1,a0);
 db:=Vector3Sub(b1,b0);
 dc:=Vector3Sub(b0,a0);
 cdadb:=Vector3Cross(da,db);
 if abs(Vector3Dot(cdadb,dc))>EPSILON then begin
  // Lines are not coplanar
  exit;
 end;
 t:=Vector3Dot(Vector3Cross(dc,db),cdadb)/Vector3LengthSquared(cdadb);
 if (t>=0.0) and (t<=1.0) then begin
  if assigned(p) then begin
   p^:=Vector3Lerp(a0,a1,t);
  end;
  result:=true;
 end;
end;

function LineLineIntersection(const a0,a1,b0,b1:TVector3;const pa:PVector3=nil;const pb:PVector3=nil;const ta:psingle=nil;const tb:psingle=nil):boolean;
var p02,p32,p10:TVector3d;
    d0232,d3210,d0210,d3232,d1010,Numerator,Denominator,lta,ltb:double;
begin
 result:=false;

 p32.x:=b1.x-b0.x;
 p32.y:=b1.y-b0.y;
 p32.z:=b1.z-b0.z;
 if (abs(p32.x)<EPSILON) and (abs(p32.y)<EPSILON) and (abs(p32.z)<EPSILON) then begin
  exit;
 end;

 p10.x:=a1.x-a0.x;
 p10.y:=a1.y-a0.y;
 p10.z:=a1.z-a0.z;
 if (abs(p10.x)<EPSILON) and (abs(p10.y)<EPSILON) and (abs(p10.z)<EPSILON) then begin
  exit;
 end;

 p02.x:=a0.x-b0.x;
 p02.y:=a0.y-b0.y;
 p02.z:=a0.z-b0.z;

 d0232:=(p02.x*p32.x)+(p02.y*p32.y)+(p02.z*p32.z);
 d3210:=(p32.x*p10.x)+(p32.y*p10.y)+(p32.z*p10.z);
 d0210:=(p02.x*p10.x)+(p02.y*p10.y)+(p02.z*p10.z);
 d3232:=(p32.x*p32.x)+(p32.y*p32.y)+(p32.z*p32.z);
 d1010:=(p10.x*p10.x)+(p10.y*p10.y)+(p10.z*p10.z);

 Denominator:=(d1010*d3232)-(d3210*d3210);
 if abs(Denominator)<EPSILON then begin
  exit;
 end;

 if assigned(pa) or assigned(pb) or assigned(ta) or assigned(tb) then begin
  Numerator:=(d0232*d3210)-(d0210*d3232);
  lta:=Numerator/Denominator;
  ltb:=(d0232+(d3210*lta))/d3232;
  if assigned(ta) then begin
   ta^:=lta;
  end;
  if assigned(tb) then begin
   tb^:=ltb;
  end;
  if assigned(pa) then begin
   pa^:=Vector3Lerp(a0,a1,lta);
  end;
  if assigned(pb) then begin
   pb^:=Vector3Lerp(b0,b1,ltb);
  end;
 end;

 result:=true;
end;

function MinkowskizeOBBInOBB(const OBB1,OBB2:TOBB):TMinkowskiDescription;
var AxisXinNewCoord,AxisYinNewCoord,AxisZinNewCoord:TVector3;
begin
 AxisXinNewCoord:=Vector3TermMatrixMul(obb1.Axis[0],obb2.Matrix);
 AxisYinNewCoord:=Vector3TermMatrixMul(obb1.Axis[1],obb2.Matrix);
 AxisZinNewCoord:=Vector3TermMatrixMul(obb1.Axis[2],obb2.Matrix);
 result.HalfAxis.x:=(obb1.Extents.x*abs(AxisXinNewCoord.x))+(obb1.Extents.y*abs(AxisYinNewCoord.x))+(obb1.Extents.z*abs(AxisZinNewCoord.x));
 result.HalfAxis.y:=(obb1.Extents.x*abs(AxisXinNewCoord.y))+(obb1.Extents.y*abs(AxisYinNewCoord.y))+(obb1.Extents.z*abs(AxisZinNewCoord.y));
 result.HalfAxis.z:=(obb1.Extents.x*abs(AxisXinNewCoord.z))+(obb1.Extents.y*abs(AxisYinNewCoord.z))+(obb1.Extents.z*abs(AxisZinNewCoord.z));
 result.HalfAxis.w:=0.0;
 result.Position_LM:=Vector3TermMatrixMul(Vector3Sub(OBB1.Center,OBB2.Center),obb2.Matrix);
end;

function MinkowskizeSphereInOBB(const Sphere:TSphere;const OBB:TOBB):TMinkowskiDescription;
begin
 result.HalfAxis.x:=Sphere.Radius;
 result.HalfAxis.y:=0.0;
 result.HalfAxis.z:=0.0;
 result.HalfAxis.w:=0.0;
// result.Position_LM:=Vector3TermMatrixMul(Vector3Sub(OBB1.Center,OBB2.Center),obb2.Matrix);
end;

function MinkowskizeTriangleInOBB(const v0,v1,v2:TVector3;const OBB:TOBB):TMinkowskiDescription;
begin
end;

function MinkowskizeOBBInTriangle(const v0,v1,v2:TVector3;const OBB:TOBB):TMinkowskiDescription;
begin
end;

function IsPointsSameSide(const p0,p1,Origin,Direction:TVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=Vector3Dot(Vector3Cross(Direction,Vector3Sub(p0,Origin)),Vector3Cross(Direction,Vector3Sub(p1,Origin)))>=0.0;
end;

function IsPointsSameSide(const p0,p1,Origin,Direction:TSIMDVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=SIMDVector3Dot(SIMDVector3Cross(Direction,SIMDVector3Sub(p0,Origin)),SIMDVector3Cross(Direction,SIMDVector3Sub(p1,Origin)))>=0.0;
end;

function PointInTriangle(const p0,p1,p2,Normal,p:TVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
var r0,r1,r2:single;
begin
 r0:=Vector3Dot(Vector3Cross(Vector3Sub(p1,p0),Normal),Vector3Sub(p,p0));
 r1:=Vector3Dot(Vector3Cross(Vector3Sub(p2,p1),Normal),Vector3Sub(p,p1));
 r2:=Vector3Dot(Vector3Cross(Vector3Sub(p0,p2),Normal),Vector3Sub(p,p2));
 result:=((r0>0.0) and (r1>0.0) and (r2>0.0)) or ((r0<=0.0) and (r1<=0.0) and (r2<=0.0));
end;

function PointInTriangle(const p0,p1,p2,Normal,p:TSIMDVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
var r0,r1,r2:single;
begin
 r0:=SIMDVector3Dot(SIMDVector3Cross(SIMDVector3Sub(p1,p0),Normal),SIMDVector3Sub(p,p0));
 r1:=SIMDVector3Dot(SIMDVector3Cross(SIMDVector3Sub(p2,p1),Normal),SIMDVector3Sub(p,p1));
 r2:=SIMDVector3Dot(SIMDVector3Cross(SIMDVector3Sub(p0,p2),Normal),SIMDVector3Sub(p,p2));
 result:=((r0>0.0) and (r1>0.0) and (r2>0.0)) or ((r0<=0.0) and (r1<=0.0) and (r2<=0.0));
end;

function PointInTriangle(const p0,p1,p2,p:TVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=IsPointsSameSide(p,p0,p1,Vector3Sub(p2,p1)) and
         IsPointsSameSide(p,p1,p0,Vector3Sub(p2,p0)) and
         IsPointsSameSide(p,p2,p0,Vector3Sub(p1,p0));
end;

function PointInTriangle(const p0,p1,p2,p:TSIMDVector3):boolean; overload; {$ifdef caninline}inline;{$endif}
begin
 result:=IsPointsSameSide(p,p0,p1,SIMDVector3Sub(p2,p1)) and
         IsPointsSameSide(p,p1,p0,SIMDVector3Sub(p2,p0)) and
         IsPointsSameSide(p,p2,p0,SIMDVector3Sub(p1,p0));
end;

function SegmentSqrDistance(const FromVector,ToVector,p:TVector3;out Nearest:TVector3):single; overload; {$ifdef caninline}inline;{$endif}
var t,DotUV:single;
    Diff,v:TVector3;
begin
 Diff:=Vector3Sub(p,FromVector);
 v:=Vector3Sub(ToVector,FromVector);
 t:=Vector3Dot(v,Diff);
 if t>0.0 then begin
  DotUV:=Vector3LengthSquared(v);
  if t<DotUV then begin
   t:=t/DotUV;
   Diff:=Vector3Sub(Diff,Vector3ScalarMul(v,t));
  end else begin
   t:=1;
   Diff:=Vector3Sub(Diff,v);
  end;
 end else begin
  t:=0.0;
 end;
 Nearest:=Vector3Lerp(FromVector,ToVector,t);
 result:=Vector3LengthSquared(Diff);
end;

function SegmentSqrDistance(const FromVector,ToVector,p:TSIMDVector3;out Nearest:TSIMDVector3):single; overload; {$ifdef caninline}inline;{$endif}
var t,DotUV:single;
    Diff,v:TSIMDVector3;
begin
 Diff:=SIMDVector3Sub(p,FromVector);
 v:=SIMDVector3Sub(ToVector,FromVector);
 t:=SIMDVector3Dot(v,Diff);
 if t>0.0 then begin
  DotUV:=SIMDVector3LengthSquared(v);
  if t<DotUV then begin
   t:=t/DotUV;
   Diff:=SIMDVector3Sub(Diff,SIMDVector3ScalarMul(v,t));
  end else begin
   t:=1;
   Diff:=SIMDVector3Sub(Diff,v);
  end;
 end else begin
  t:=0.0;
 end;
 Nearest:=SIMDVector3Lerp(FromVector,ToVector,t);
 result:=SIMDVector3LengthSquared(Diff);
end;

procedure ProjectOBBToVector(const OBB:TOBB;const Vector:TVector3;out OBBMin,OBBMax:single); {$ifdef caninline}inline;{$endif}
var ProjectionCenter,ProjectionRadius:single;
begin
 ProjectionCenter:=Vector3Dot(OBB.Center,Vector);
 ProjectionRadius:=abs(Vector3Dot(Vector,OBB.Axis[0])*OBB.Extents.x)+
                   abs(Vector3Dot(Vector,OBB.Axis[1])*OBB.Extents.y)+
                   abs(Vector3Dot(Vector,OBB.Axis[2])*OBB.Extents.z);
 OBBMin:=ProjectionCenter-ProjectionRadius;
 OBBMax:=ProjectionCenter+ProjectionRadius;
end;

procedure ProjectTriangleToVector(const v0,v1,v2,Vector:TVector3;out TriangleMin,TriangleMax:single); {$ifdef caninline}inline;{$endif}
var Projection:single;
begin
 Projection:=Vector3Dot(Vector,v0);
 TriangleMin:=Projection;
 TriangleMax:=Projection;
 Projection:=Vector3Dot(Vector,v1);
 TriangleMin:=Min(TriangleMin,Projection);
 TriangleMax:=Max(TriangleMax,Projection);
 Projection:=Vector3Dot(Vector,v2);
 TriangleMin:=Min(TriangleMin,Projection);
 TriangleMax:=Max(TriangleMax,Projection);
end;

function GetOverlap(const MinA,MaxA,MinB,MaxB:single):single; {$ifdef caninline}inline;{$endif}
var Mins,Maxs:single;
begin
 if (MinA>MaxB) or (MaxA<MinB) then begin
  result:=0.0;
 end else begin
  if MinA<MinB then begin
   result:=MinB-MaxA;
  end else begin
   result:=MinA-MaxB;
  end;
  if ((MinB>=MinA) and (MaxB<=MaxA)) or ((MinA>=MinB) and (MaxA<=MaxB)) then begin
   Mins:=abs(MinA-MinB);
   Maxs:=abs(MaxA-MaxB);
   if Mins<Maxs then begin
    result:=result+Mins;
   end else begin
    result:=result+Maxs;
   end;
  end;
 end;
end;

function OldTriangleTriangleIntersection(const a0,a1,a2,b0,b1,b2:TVector3):boolean;
const EPSILON=1e-2;
      LINEEPSILON=1e-6;
var Index,NextIndex,RemainingIndex,i,j,k,h:longint;
    l,tS,tT0,tT1:single;
    v:array[0..1,0..2] of TVector3;
    SegmentTriangles:array[0..1] of TSegmentTriangle;
    Segment:TSegment;
    lv,plv:TVector3;
    OK:boolean;
begin
 result:=false;
 v[0,0]:=a0;
 v[0,1]:=a1;
 v[0,2]:=a2;
 v[1,0]:=b0;
 v[1,1]:=b1;
 v[1,2]:=b2;
 SegmentTriangles[0].Origin:=a0;
 SegmentTriangles[0].Edge0:=Vector3Sub(a1,a0);
 SegmentTriangles[0].Edge1:=Vector3Sub(a2,a0);
 SegmentTriangles[1].Origin:=b0;
 SegmentTriangles[1].Edge0:=Vector3Sub(b1,b0);
 SegmentTriangles[1].Edge1:=Vector3Sub(b2,b0);
 for Index:=0 to 2 do begin
  NextIndex:=Index+1;
  if NextIndex>2 then begin
   dec(NextIndex,3);
  end;
  RemainingIndex:=NextIndex+1;
  if RemainingIndex>2 then begin
   dec(RemainingIndex,3);
  end;

  for i:=0 to 3 do begin
   case i of
    0:begin
     Segment.Origin:=v[0,Index];
     Segment.Delta:=Vector3Sub(v[0,NextIndex],v[0,Index]);
     j:=1;
    end;
    1:begin
     Segment.Origin:=v[1,Index];
     Segment.Delta:=Vector3Sub(v[1,NextIndex],v[1,Index]);
     j:=0;
    end;
    2:begin
     Segment.Origin:=v[0,Index];
     Segment.Delta:=Vector3Sub(Vector3Avg(v[0,NextIndex],v[0,RemainingIndex]),v[0,Index]);
     j:=1;
    end;
    else begin
     Segment.Origin:=v[1,Index];
     Segment.Delta:=Vector3Sub(Vector3Avg(v[1,NextIndex],v[1,RemainingIndex]),v[1,Index]);
     j:=0;
    end;
   end;
   if SegmentTriangleIntersection(tS,tT0,tT1,Segment,SegmentTriangles[j]) then begin
    OK:=true;
    if i<2 then begin
     lv:=Vector3Add(Segment.Origin,Vector3ScalarMul(Segment.Delta,tS));
     for k:=0 to 2 do begin
      h:=k+1;
      if h>2 then begin
       dec(h,2);
      end;
      if GetDistanceFromLine(v[j,k],v[j,j],lv,plv)<EPSILON then begin
       OK:=false;
       break;
      end;
     end;
    end;
    if OK and (((tT0>EPSILON) and (tT0<(1.0-EPSILON))) or ((tT1>EPSILON) and (tT1<(1.0-EPSILON)))) then begin
     result:=true;
     exit;
    end;
   end;
  end;

 end;
end;

function TriangleTriangleIntersection(const v0,v1,v2,u0,u1,u2:TVector3):boolean;
const EPSILON=1e-6;
 procedure SORT(var a,b:single); {$ifdef caninline}inline;{$endif}
 var c:single;
 begin
  if a>b then begin
   c:=a;
   a:=b;
   b:=c;
  end;
 end;
 procedure ISECT(const VV0,VV1,VV2,D0,D1,D2:single;var isect0,isect1:single); {$ifdef caninline}inline;{$endif}
 begin
  isect0:=VV0+(((VV1-VV0)*D0)/(D0-D1));
  isect1:=VV0+(((VV2-VV0)*D0)/(D0-D2));
 end;
 function EDGE_EDGE_TEST(const v0,u0,u1:TVector3;const Ax,Ay:single;const i0,i1:longint):boolean; {$ifdef caninline}inline;{$endif}
 var Bx,By,Cx,Cy,e,f,d:single;
 begin
  result:=false;
  Bx:=U0.xyz[i0]-U1.xyz[i0];
  By:=U0.xyz[i1]-U1.xyz[i1];
  Cx:=V0.xyz[i0]-U0.xyz[i0];
  Cy:=V0.xyz[i1]-U0.xyz[i1];
  f:=(Ay*Bx)-(Ax*By);
  d:=(By*Cx)-(Bx*Cy);
  if ((f>0.0) and (d>=0.0) and (d<=f)) or ((f<0.0) and (d<=0.0) and (d>=f)) then begin
   e:=(Ax*Cy)-(Ay*Cx);
   if f>0.0 then begin
    if (e>=0.0) and (e<=f) then begin
     result:=true;
    end;
   end else begin
    if (e<=0.0) and (e>=f) then begin
     result:=true;
    end;
   end;
  end;
 end;
 function POINT_IN_TRI(const v0,u0,u1,u2:TVector3;const i0,i1:longint):boolean; {$ifdef caninline}inline;{$endif}
 var a,b,c,d0,d1,d2:single;
 begin

  // is T1 completly inside T2?
  // check if V0 is inside tri(U0,U1,U2)

  a:=U1.xyz[i1]-U0.xyz[i1];
  b:=-(U1.xyz[i0]-U0.xyz[i0]);
  c:=(-(a*U0.xyz[i0]))-(b*U0.xyz[i1]);
  d0:=((a*V0.xyz[i0])+(b*V0.xyz[i1]))+c;

  a:=U2.xyz[i1]-U1.xyz[i1];
  b:=-(U2.xyz[i0]-U1.xyz[i0]);
  c:=(-(a*U1.xyz[i0]))-(b*U1.xyz[i1]);
  d1:=((a*V0.xyz[i0])+(b*V0.xyz[i1]))+c;

  a:=U0.xyz[i1]-U2.xyz[i1];
  b:=-(U0.xyz[i0]-U2.xyz[i0]);
  c:=(-(a*U2.xyz[i0]))-(b*U2.xyz[i1]);
  d2:=((a*V0.xyz[i0])+(b*V0.xyz[i1]))+c;

  result:=((d0*d1)>0.0) and ((d0*d2)>0.0);
 end;
 function EDGE_AGAINST_TRI_EDGES(const v0,v1,u0,u1,u2:TVector3;const i0,i1:longint):boolean; {$ifdef caninline}inline;{$endif}
 var Ax,Ay:single;
 begin
  Ax:=v1.xyz[i0]-v0.xyz[i0];
  Ay:=v1.xyz[i1]-v0.xyz[i1];
  result:=EDGE_EDGE_TEST(V0,U0,U1,Ax,Ay,i0,i1) or // test edge U0,U1 against V0,V1
          EDGE_EDGE_TEST(V0,U1,U2,Ax,Ay,i0,i1) or // test edge U1,U2 against V0,V1
          EDGE_EDGE_TEST(V0,U2,U0,Ax,Ay,i0,i1);   // test edge U2,U1 against V0,V1
 end;
 function coplanar_tri_tri(const n,v0,v1,v2,u0,u1,u2:TVector3):boolean; {$ifdef caninline}inline;{$endif}
 var i0,i1:longint;
     a:TVector3;
 begin
  a.x:=abs(n.x);
  a.y:=abs(n.y);
  a.z:=abs(n.z);
  if a.x>a.y then begin
   if a.x>a.z then begin
    i0:=1;
    i1:=2;
   end else begin
    i0:=0;
    i1:=1;
   end;
  end else begin
   if a.y<a.z then begin
    i0:=0;
    i1:=1;
   end else begin
    i0:=0;
    i1:=2;
   end;
  end;
  // test all edges of triangle 1 against the edges of triangle 2
  result:=EDGE_AGAINST_TRI_EDGES(V0,V1,U0,U1,U2,i0,i1) or
          EDGE_AGAINST_TRI_EDGES(V1,V2,U0,U1,U2,i0,i1) or
          EDGE_AGAINST_TRI_EDGES(V2,V0,U0,U1,U2,i0,i1) or
          POINT_IN_TRI(V0,U0,U1,U2,i0,i1) or // finally, test if tri1 is totally contained in tri2 or vice versa
          POINT_IN_TRI(U0,V0,V1,V2,i0,i1);
 end;
 function COMPUTE_INTERVALS(const N1:TVector3;const VV0,VV1,VV2,D0,D1,D2,D0D1,D0D2:single;var isect0,isect1:single):boolean; //{$ifdef caninline}inline;{$endif}
 begin
  result:=false;
  if D0D1>0.0 then begin
   // here we know that D0D2<=0.0
   // that is D0, D1 are on the same side, D2 on the other or on the plane
   ISECT(VV2,VV0,VV1,D2,D0,D1,isect0,isect1);
  end else if D0D2>0.0 then begin
   // here we know that d0d1<=0.0
   ISECT(VV1,VV0,VV2,D1,D0,D2,isect0,isect1);
  end else if ((D1*D2)>0.0) or (D0<>0.0) then begin
   // here we know that d0d1<=0.0 or that D0<>0.0
   ISECT(VV0,VV1,VV2,D0,D1,D2,isect0,isect1);
  end else if D1<>0.0 then begin
   ISECT(VV1,VV0,VV2,D1,D0,D2,isect0,isect1);
  end else if D2<>0.0 then begin
   ISECT(VV2,VV0,VV1,D2,D0,D1,isect0,isect1);
  end else begin
   // triangles are coplanar
   result:=coplanar_tri_tri(N1,V0,V1,V2,U0,U1,U2);
  end;
 end;
var index:longint;
    d1,d2,du0,du1,du2,dv0,dv1,dv2,du0du1,du0du2,dv0dv1,dv0dv2,vp0,vp1,vp2,up0,up1,up2,b,c,m:single;
    isect1,isect2:array[0..1] of single;
    e1,e2,n1,n2,d:TVector3;
begin

 result:=false;

 // compute plane equation of triangle(V0,V1,V2)
 e1:=Vector3Sub(v1,v0);
 e2:=Vector3Sub(v2,v0);
 n1:=Vector3Cross(e1,e2);
 d1:=-Vector3Dot(n1,v0);

 // put U0,U1,U2 into plane equation 1 to compute signed distances to the plane
 du0:=Vector3Dot(n1,u0)+d1;
 du1:=Vector3Dot(n1,u1)+d1;
 du2:=Vector3Dot(n1,u2)+d1;

 // coplanarity robustness check
 if abs(du0)<EPSILON then begin
  du0:=0.0;
 end;
 if abs(du1)<EPSILON then begin
  du1:=0.0;
 end;
 if abs(du2)<EPSILON then begin
  du2:=0.0;
 end;

 du0du1:=du0*du1;
 du0du2:=du0*du2;

 // same sign on all of them + not equal 0 ?
 if (du0du1>0.0) and (du0du2>0.0) then begin
  // no intersection occurs
  exit;
 end;

 // compute plane of triangle (U0,U1,U2)
 e1:=Vector3Sub(u1,u0);
 e2:=Vector3Sub(u2,u0);
 n2:=Vector3Cross(e1,e2);
 d2:=-Vector3Dot(n2,u0);

 // put V0,V1,V2 into plane equation 2
 dv0:=Vector3Dot(n2,v0)+d2;
 dv1:=Vector3Dot(n2,v1)+d2;
 dv2:=Vector3Dot(n2,v2)+d2;

 // coplanarity robustness check
 if abs(dv0)<EPSILON then begin
  dv0:=0.0;
 end;
 if abs(dv1)<EPSILON then begin
  dv1:=0.0;
 end;
 if abs(dv2)<EPSILON then begin
  dv2:=0.0;
 end;

 dv0dv1:=dv0*dv1;
 dv0dv2:=dv0*dv2;

 // same sign on all of them + not equal 0 ?
 if (dv0dv1>0.0) and (dv0dv2>0.0) then begin
  // no intersection occurs
  exit;
 end;

 // compute direction of intersection line
 d:=Vector3Cross(n1,n2);

 // compute and index to the largest component of D
 m:=abs(d.x);
 index:=0;
 b:=abs(d.y);
 c:=abs(d.z);
 if m<b then begin
  m:=b;
  index:=1;
 end;
 if m<c then begin
  m:=c;
  index:=2;
 end;

 // this is the simplified projection onto L
 vp0:=v0.xyz[index];
 vp1:=v1.xyz[index];
 vp2:=v2.xyz[index];

 up0:=u0.xyz[index];
 up1:=u1.xyz[index];
 up2:=u2.xyz[index];

 // compute interval for triangle 1
 result:=COMPUTE_INTERVALS(N1,vp0,vp1,vp2,dv0,dv1,dv2,dv0dv1,dv0dv2,isect1[0],isect1[1]);
 if result then begin
  exit;
 end;

 // compute interval for triangle 2
 result:=COMPUTE_INTERVALS(N1,up0,up1,up2,du0,du1,du2,du0du1,du0du2,isect2[0],isect2[1]);
 if result then begin
  exit;
 end;

 SORT(isect1[0],isect1[1]);
 SORT(isect2[0],isect2[1]);

 result:=not ((isect1[1]<isect2[0]) or (isect2[1]<isect1[0]));
end;

function OBBTriangleIntersection(const OBB:TOBB;const v0,v1,v2:TVector3;const MTV:PVector3=nil):boolean;
var TriangleEdges:array[0..2] of TVEctor3;
    TriangleNormal,d,ProjectionVector:TVector3;
    TriangleMin,TriangleMax,OBBMin,OBBMax,Projection,BestOverlap,Overlap:single;
    OBBAxisIndex,TriangleEdgeIndex:longint;
    BestAxis,Axis:TVector3;
begin
 result:=false;

 TriangleEdges[0]:=Vector3Sub(v1,v0);
 TriangleEdges[1]:=Vector3Sub(v2,v0);
 TriangleEdges[2]:=Vector3Sub(v2,v1);

 TriangleNormal:=Vector3Cross(TriangleEdges[0],TriangleEdges[1]);

 d:=Vector3Sub(TriangleEdges[0],OBB.Center);

 TriangleMin:=Vector3Dot(TriangleNormal,v0);
 TriangleMax:=TriangleMin;
 ProjectOBBToVector(OBB,TriangleNormal,OBBMin,OBBMax);
 if (TriangleMin>OBBMax) or (TriangleMax<OBBMin) then begin
  exit;
 end;
 BestAxis:=TriangleNormal;
 BestOverlap:=GetOverlap(OBBMin,OBBMax,TriangleMin,TriangleMax);

 for OBBAxisIndex:=0 to 2 do begin
  Axis:=OBB.Axis[OBBAxisIndex];
  ProjectTriangleToVector(v0,v1,v2,Axis,TriangleMin,TriangleMax);
  Projection:=Vector3Dot(Axis,OBB.Center);
  OBBMin:=Projection-OBB.Extents.xyz[OBBAxisIndex];
  OBBMax:=Projection+OBB.Extents.xyz[OBBAxisIndex];
  if (TriangleMin>OBBMax) or (TriangleMax<OBBMin) then begin
   exit;
  end;
  Overlap:=GetOverlap(OBBMin,OBBMax,TriangleMin,TriangleMax);
  if Overlap<BestOverlap then begin
   BestAxis:=Axis;
   BestOverlap:=Overlap;
  end;
 end;

 for OBBAxisIndex:=0 to 2 do begin
  for TriangleEdgeIndex:=0 to 2 do begin
   ProjectionVector:=Vector3Cross(TriangleEdges[TriangleEdgeIndex],OBB.Axis[OBBAxisIndex]);
   ProjectOBBToVector(OBB,ProjectionVector,OBBMin,OBBMax);
   ProjectTriangleToVector(v0,v1,v2,ProjectionVector,TriangleMin,TriangleMax);
   if (TriangleMin>OBBMax) or (TriangleMax<OBBMin) then begin
    exit;
   end;
   Overlap:=GetOverlap(OBBMin,OBBMax,TriangleMin,TriangleMax);
   if Overlap<BestOverlap then begin
    BestAxis:=ProjectionVector;
    BestOverlap:=Overlap;
   end;
  end;
 end;

 if assigned(MTV) then begin
  MTV^:=Vector3ScalarMul(BestAxis,BestOverlap);
 end;

 result:=true;
end;

function ClosestPointToLine(const LineStartPoint,LineEndPoint,Point:TVector3;const ClosestPointOnLine:PVector3=nil;const Time:psingle=nil):single;
var LineSegmentPointsDifference,ClosestPoint:TVector3;
    LineSegmentLengthSquared,PointOnLineSegmentTime:single;
begin
 LineSegmentPointsDifference:=Vector3Sub(LineEndPoint,LineStartPoint);
 LineSegmentLengthSquared:=Vector3LengthSquared(LineSegmentPointsDifference);
 if LineSegmentLengthSquared<EPSILON then begin
  PointOnLineSegmentTime:=0.0;
  ClosestPoint:=LineStartPoint;
 end else begin
  PointOnLineSegmentTime:=Vector3Dot(Vector3Sub(Point,LineStartPoint),LineSegmentPointsDifference)/LineSegmentLengthSquared;
  if PointOnLineSegmentTime<=0.0 then begin
   PointOnLineSegmentTime:=0.0;
   ClosestPoint:=LineStartPoint;
  end else if PointOnLineSegmentTime>=1.0 then begin
   PointOnLineSegmentTime:=1.0;
   ClosestPoint:=LineEndPoint;
  end else begin
   ClosestPoint:=Vector3Add(LineStartPoint,Vector3ScalarMul(LineSegmentPointsDifference,PointOnLineSegmentTime));
  end;
 end;
 if assigned(ClosestPointOnLine) then begin
  ClosestPointOnLine^:=ClosestPoint;
 end;
 if assigned(Time) then begin
  Time^:=PointOnLineSegmentTime;
 end;
 result:=Vector3Dist(Point,ClosestPoint);
end;

function ClosestPointToAABB(const AABB:TAABB;const Point:TVector3;const ClosestPointOnAABB:PVector3=nil):single; {$ifdef caninline}inline;{$endif}
var ClosestPoint:TVector3;
begin
 ClosestPoint.x:=Min(Max(Point.x,AABB.Min.x),AABB.Max.x);
 ClosestPoint.y:=Min(Max(Point.y,AABB.Min.y),AABB.Max.y);
 ClosestPoint.z:=Min(Max(Point.z,AABB.Min.z),AABB.Max.z);
 if assigned(ClosestPointOnAABB) then begin
  ClosestPointOnAABB^:=ClosestPoint;
 end;
 result:=Vector3Dist(ClosestPoint,Point);
end;

function ClosestPointToOBB(const OBB:TOBB;const Point:TVector3;out ClosestPoint:TVector3):single; {$ifdef caninline}inline;{$endif}
var DistanceVector:TVector3;
begin
 DistanceVector:=Vector3Sub(Point,OBB.Center);
 ClosestPoint:=Vector3Add(Vector3Add(Vector3Add(OBB.Center,
                                                Vector3ScalarMul(OBB.Axis[0],Min(Max(Vector3Dot(DistanceVector,OBB.Axis[0]),-OBB.Extents.xyz[0]),OBB.Extents.xyz[0]))
                                               ),
                                     Vector3ScalarMul(OBB.Axis[1],Min(Max(Vector3Dot(DistanceVector,OBB.Axis[1]),-OBB.Extents.xyz[1]),OBB.Extents.xyz[1]))
                                    ),
                          Vector3ScalarMul(OBB.Axis[2],Min(Max(Vector3Dot(DistanceVector,OBB.Axis[2]),-OBB.Extents.xyz[2]),OBB.Extents.xyz[2]))
                         );
 result:=Vector3Dist(ClosestPoint,Point);
end;

function ClosestPointToSphere(const Sphere:TSphere;const Point:TVector3;out ClosestPoint:TVector3):single; {$ifdef caninline}inline;{$endif}
begin
 result:=Max(0.0,Vector3Dist(Sphere.Center,Point)-Sphere.Radius);
 ClosestPoint:=Vector3Add(Point,Vector3ScalarMul(Vector3Norm(Vector3Sub(Sphere.Center,Point)),result));
end;

function ClosestPointToCapsule(const Capsule:TCapsule;const Point:TVector3;out ClosestPoint:TVector3):single; {$ifdef caninline}inline;{$endif}
var LineSegmentPointsDifference,LineClosestPoint:TVector3;
    LineSegmentLengthSquared,PointOnLineSegmentTime:single;
begin
 LineSegmentPointsDifference:=Vector3Sub(Capsule.LineEndPoint,Capsule.LineStartPoint);
 LineSegmentLengthSquared:=Vector3LengthSquared(LineSegmentPointsDifference);
 if LineSegmentLengthSquared<EPSILON then begin
  PointOnLineSegmentTime:=0.0;
  LineClosestPoint:=Capsule.LineStartPoint;
 end else begin
  PointOnLineSegmentTime:=Vector3Dot(Vector3Sub(Point,Capsule.LineStartPoint),LineSegmentPointsDifference)/LineSegmentLengthSquared;
  if PointOnLineSegmentTime<=0.0 then begin
   PointOnLineSegmentTime:=0.0;
   LineClosestPoint:=Capsule.LineStartPoint;
  end else if PointOnLineSegmentTime>=1.0 then begin
   PointOnLineSegmentTime:=1.0;
   LineClosestPoint:=Capsule.LineEndPoint;
  end else begin
   LineClosestPoint:=Vector3Add(Capsule.LineStartPoint,Vector3ScalarMul(LineSegmentPointsDifference,PointOnLineSegmentTime));
  end;
 end;
 LineSegmentPointsDifference:=Vector3Sub(LineClosestPoint,Point);
 result:=Max(0.0,Vector3Length(LineSegmentPointsDifference)-Capsule.Radius);
 ClosestPoint:=Vector3Add(Point,Vector3ScalarMul(Vector3Norm(LineSegmentPointsDifference),result));
end;

function ClosestPointToTriangle(const a,b,c,p:TVector3;out ClosestPoint:TVector3):single;
var ab,ac,bc,pa,pb,pc,ap,bp,cp,n:TVector3;
    snom,sdenom,tnom,tdenom,unom,udenom,vc,vb,va,u,v,w:single;
begin

 ab.x:=b.x-a.x;
 ab.y:=b.y-a.y;
 ab.z:=b.z-a.z;

 ac.x:=c.x-a.x;
 ac.y:=c.y-a.y;
 ac.z:=c.z-a.z;

 bc.x:=c.x-b.x;
 bc.y:=c.y-b.y;
 bc.z:=c.z-b.z;

 pa.x:=p.x-a.x;
 pa.y:=p.y-a.y;
 pa.z:=p.z-a.z;

 pb.x:=p.x-b.x;
 pb.y:=p.y-b.y;
 pb.z:=p.z-b.z;

 pc.x:=p.x-c.x;
 pc.y:=p.y-c.y;
 pc.z:=p.z-c.z;

 // Determine the parametric position s for the projection of P onto AB (i.e. P’ = A+s*AB, where
 // s = snom/(snom+sdenom), and then parametric position t for P projected onto AC
 snom:=(ab.x*pa.x)+(ab.y*pa.y)+(ab.z*pa.z);
 sdenom:=(pb.x*(a.x-b.x))+(pb.y*(a.y-b.y))+(pb.z*(a.z-b.z));
 tnom:=(ac.x*pa.x)+(ac.y*pa.y)+(ac.z*pa.z);
 tdenom:=(pc.x*(a.x-c.x))+(pc.y*(a.y-c.y))+(pc.z*(a.z-c.z));
 if (snom<=0.0) and (tnom<=0.0) then begin
  // Vertex voronoi region hit early out
  ClosestPoint:=a;
  result:=sqrt(sqr(ClosestPoint.x-p.x)+sqr(ClosestPoint.y-p.y)+sqr(ClosestPoint.z-p.z));
  exit;
 end;

 // Parametric position u for P projected onto BC
 unom:=(bc.x*pb.x)+(bc.y*pb.y)+(bc.z*pb.z);
 udenom:=(pc.x*(b.x-c.x))+(pc.y*(b.y-c.y))+(pc.z*(b.z-c.z));
 if (sdenom<=0.0) and (unom<=0.0) then begin
  // Vertex voronoi region hit early out
  ClosestPoint:=b;
  result:=sqrt(sqr(ClosestPoint.x-p.x)+sqr(ClosestPoint.y-p.y)+sqr(ClosestPoint.z-p.z));
  exit;
 end;
 if (tdenom<=0.0) and (udenom<=0.0) then begin
  // Vertex voronoi region hit early out
  ClosestPoint:=c;
  result:=sqrt(sqr(ClosestPoint.x-p.x)+sqr(ClosestPoint.y-p.y)+sqr(ClosestPoint.z-p.z));
  exit;
 end;

 // Determine if P is outside (or on) edge AB by finding the area formed by vectors PA, PB and
 // the triangle normal. A scalar triple product is used. P is outside (or on) AB if the triple
 // scalar product [N PA PB] <= 0
 n.x:=(ab.y*ac.z)-(ab.z*ac.y);
 n.y:=(ab.z*ac.x)-(ab.x*ac.z);
 n.z:=(ab.x*ac.y)-(ab.y*ac.x);
 ap.x:=a.x-p.x;
 ap.y:=a.y-p.y;
 ap.z:=a.z-p.z;
 bp.x:=b.x-p.x;
 bp.y:=b.y-p.y;
 bp.z:=b.z-p.z;
 vc:=(n.x*((ap.y*bp.z)-(ap.z*bp.y)))+(n.y*((ap.z*bp.x)-(ap.x*bp.z)))+(n.z*((ap.x*bp.y)-(ap.y*bp.x)));

 // If P is outside of AB (signed area <= 0) and within voronoi feature region, then return
 // projection of P onto AB
 if (vc<=0.0) and (snom>=0.0) and (sdenom>=0.0) then begin
  u:=snom/(snom+sdenom);
  ClosestPoint.x:=a.x+(ab.x*u);
  ClosestPoint.y:=a.y+(ab.y*u);
  ClosestPoint.z:=a.z+(ab.z*u);
  result:=sqrt(sqr(ClosestPoint.x-p.x)+sqr(ClosestPoint.y-p.y)+sqr(ClosestPoint.z-p.z));
  exit;
 end;

 // Repeat the same test for P onto BC
 cp.x:=c.x-p.x;
 cp.y:=c.y-p.y;
 cp.z:=c.z-p.z;
 va:=(n.x*((bp.y*cp.z)-(bp.z*cp.y)))+(n.y*((bp.z*cp.x)-(bp.x*cp.z)))+(n.z*((bp.x*cp.y)-(bp.y*cp.x)));
 if (va<=0.0) and (unom>=0.0) and (udenom>=0.0) then begin
  v:=unom/(unom+udenom);
  ClosestPoint.x:=b.x+(bc.x*v);
  ClosestPoint.y:=b.y+(bc.y*v);
  ClosestPoint.z:=b.z+(bc.z*v);
  result:=sqrt(sqr(ClosestPoint.x-p.x)+sqr(ClosestPoint.y-p.y)+sqr(ClosestPoint.z-p.z));
  exit;
 end;

 // Repeat the same test for P onto CA
 vb:=(n.x*((cp.y*ap.z)-(cp.z*ap.y)))+(n.y*((cp.z*ap.x)-(cp.x*ap.z)))+(n.z*((cp.x*ap.y)-(cp.y*ap.x)));
 if (vb<=0.0) and (tnom>=0.0) and (tdenom>=0.0) then begin
  w:=tnom/(tnom+tdenom);
  ClosestPoint.x:=a.x+(ac.x*w);
  ClosestPoint.y:=a.y+(ac.y*w);
  ClosestPoint.z:=a.z+(ac.z*w);
  result:=sqrt(sqr(ClosestPoint.x-p.x)+sqr(ClosestPoint.y-p.y)+sqr(ClosestPoint.z-p.z));
  exit;
 end;

 // P must project onto inside face. Find closest point using the barycentric coordinates
 w:=1.0/(va+vb+vc);
 u:=va*w;
 v:=vb*w;
 w:=(1.0-u)-v;
 
 ClosestPoint.x:=(a.x*u)+(b.x*v)+(c.x*w);
 ClosestPoint.y:=(a.y*u)+(b.y*v)+(c.y*w);
 ClosestPoint.z:=(a.z*u)+(b.z*v)+(c.z*w);
 result:=sqrt(sqr(ClosestPoint.x-p.x)+sqr(ClosestPoint.y-p.y)+sqr(ClosestPoint.z-p.z));
end;

function SquaredDistanceFromPointToTriangle(const p,a,b,c:TVector3):single; overload;
var ab,ac,bc,pa,pb,pc,ap,bp,cp,n:TVector3;
    snom,sdenom,tnom,tdenom,unom,udenom,vc,vb,va,u,v,w:single;
begin

 ab.x:=b.x-a.x;
 ab.y:=b.y-a.y;
 ab.z:=b.z-a.z;

 ac.x:=c.x-a.x;
 ac.y:=c.y-a.y;
 ac.z:=c.z-a.z;

 bc.x:=c.x-b.x;
 bc.y:=c.y-b.y;
 bc.z:=c.z-b.z;

 pa.x:=p.x-a.x;
 pa.y:=p.y-a.y;
 pa.z:=p.z-a.z;

 pb.x:=p.x-b.x;
 pb.y:=p.y-b.y;
 pb.z:=p.z-b.z;

 pc.x:=p.x-c.x;
 pc.y:=p.y-c.y;
 pc.z:=p.z-c.z;

 // Determine the parametric position s for the projection of P onto AB (i.e. P’ = A+s*AB, where
 // s = snom/(snom+sdenom), and then parametric position t for P projected onto AC
 snom:=(ab.x*pa.x)+(ab.y*pa.y)+(ab.z*pa.z);
 sdenom:=(pb.x*(a.x-b.x))+(pb.y*(a.y-b.y))+(pb.z*(a.z-b.z));
 tnom:=(ac.x*pa.x)+(ac.y*pa.y)+(ac.z*pa.z);
 tdenom:=(pc.x*(a.x-c.x))+(pc.y*(a.y-c.y))+(pc.z*(a.z-c.z));
 if (snom<=0.0) and (tnom<=0.0) then begin
  // Vertex voronoi region hit early out
  result:=sqr(a.x-p.x)+sqr(a.y-p.y)+sqr(a.z-p.z);
  exit;
 end;

 // Parametric position u for P projected onto BC
 unom:=(bc.x*pb.x)+(bc.y*pb.y)+(bc.z*pb.z);
 udenom:=(pc.x*(b.x-c.x))+(pc.y*(b.y-c.y))+(pc.z*(b.z-c.z));
 if (sdenom<=0.0) and (unom<=0.0) then begin
  // Vertex voronoi region hit early out
  result:=sqr(b.x-p.x)+sqr(b.y-p.y)+sqr(b.z-p.z);
  exit;
 end;
 if (tdenom<=0.0) and (udenom<=0.0) then begin
  // Vertex voronoi region hit early out
  result:=sqr(c.x-p.x)+sqr(c.y-p.y)+sqr(c.z-p.z);
  exit;
 end;

 // Determine if P is outside (or on) edge AB by finding the area formed by vectors PA, PB and
 // the triangle normal. A scalar triple product is used. P is outside (or on) AB if the triple
 // scalar product [N PA PB] <= 0
 n.x:=(ab.y*ac.z)-(ab.z*ac.y);
 n.y:=(ab.z*ac.x)-(ab.x*ac.z);
 n.z:=(ab.x*ac.y)-(ab.y*ac.x);
 ap.x:=a.x-p.x;
 ap.y:=a.y-p.y;
 ap.z:=a.z-p.z;
 bp.x:=b.x-p.x;
 bp.y:=b.y-p.y;
 bp.z:=b.z-p.z;
 vc:=(n.x*((ap.y*bp.z)-(ap.z*bp.y)))+(n.y*((ap.z*bp.x)-(ap.x*bp.z)))+(n.z*((ap.x*bp.y)-(ap.y*bp.x)));

 // If P is outside of AB (signed area <= 0) and within voronoi feature region, then return
 // projection of P onto AB
 if (vc<=0.0) and (snom>=0.0) and (sdenom>=0.0) then begin
  u:=snom/(snom+sdenom);
  result:=sqr((a.x+(ab.x*u))-p.x)+sqr((a.y+(ab.y*u))-p.y)+sqr((a.z+(ab.z*u))-p.z);
  exit;
 end;

 // Repeat the same test for P onto BC
 cp.x:=c.x-p.x;
 cp.y:=c.y-p.y;
 cp.z:=c.z-p.z;
 va:=(n.x*((bp.y*cp.z)-(bp.z*cp.y)))+(n.y*((bp.z*cp.x)-(bp.x*cp.z)))+(n.z*((bp.x*cp.y)-(bp.y*cp.x)));
 if (va<=0.0) and (unom>=0.0) and (udenom>=0.0) then begin
  v:=unom/(unom+udenom);
  result:=sqr((b.x+(bc.x*v))-p.x)+sqr((b.y+(bc.y*v))-p.y)+sqr((b.z+(bc.z*v))-p.z);
  exit;
 end;

 // Repeat the same test for P onto CA
 vb:=(n.x*((cp.y*ap.z)-(cp.z*ap.y)))+(n.y*((cp.z*ap.x)-(cp.x*ap.z)))+(n.z*((cp.x*ap.y)-(cp.y*ap.x)));
 if (vb<=0.0) and (tnom>=0.0) and (tdenom>=0.0) then begin
  w:=tnom/(tnom+tdenom);
  result:=sqr((a.x+(ac.x*w))-p.x)+sqr((a.y+(ac.y*w))-p.y)+sqr((a.z+(ac.z*w))-p.z);
  exit;
 end;

 // P must project onto inside face. Find closest point using the barycentric coordinates
 w:=1.0/(va+vb+vc);
 u:=va*w;
 v:=vb*w;
 w:=(1.0-u)-v;

 result:=sqr(((a.x*u)+(b.x*v)+(c.x*w))-p.x)+sqr(((a.y*u)+(b.y*v)+(c.y*w))-p.y)+sqr(((a.z*u)+(b.z*v)+(c.z*w))-p.z);

end;

function SquaredDistanceFromPointToTriangle(const p,a,b,c:TSIMDVector3):single; overload;
var ab,ac,bc,pa,pb,pc,ap,bp,cp,n:TVector3;
    snom,sdenom,tnom,tdenom,unom,udenom,vc,vb,va,u,v,w:single;
begin

 ab.x:=b.x-a.x;
 ab.y:=b.y-a.y;
 ab.z:=b.z-a.z;

 ac.x:=c.x-a.x;
 ac.y:=c.y-a.y;
 ac.z:=c.z-a.z;

 bc.x:=c.x-b.x;
 bc.y:=c.y-b.y;
 bc.z:=c.z-b.z;

 pa.x:=p.x-a.x;
 pa.y:=p.y-a.y;
 pa.z:=p.z-a.z;

 pb.x:=p.x-b.x;
 pb.y:=p.y-b.y;
 pb.z:=p.z-b.z;

 pc.x:=p.x-c.x;
 pc.y:=p.y-c.y;
 pc.z:=p.z-c.z;

 // Determine the parametric position s for the projection of P onto AB (i.e. P’ = A+s*AB, where
 // s = snom/(snom+sdenom), and then parametric position t for P projected onto AC
 snom:=(ab.x*pa.x)+(ab.y*pa.y)+(ab.z*pa.z);
 sdenom:=(pb.x*(a.x-b.x))+(pb.y*(a.y-b.y))+(pb.z*(a.z-b.z));
 tnom:=(ac.x*pa.x)+(ac.y*pa.y)+(ac.z*pa.z);
 tdenom:=(pc.x*(a.x-c.x))+(pc.y*(a.y-c.y))+(pc.z*(a.z-c.z));
 if (snom<=0.0) and (tnom<=0.0) then begin
  // Vertex voronoi region hit early out
  result:=sqr(a.x-p.x)+sqr(a.y-p.y)+sqr(a.z-p.z);
  exit;
 end;

 // Parametric position u for P projected onto BC
 unom:=(bc.x*pb.x)+(bc.y*pb.y)+(bc.z*pb.z);
 udenom:=(pc.x*(b.x-c.x))+(pc.y*(b.y-c.y))+(pc.z*(b.z-c.z));
 if (sdenom<=0.0) and (unom<=0.0) then begin
  // Vertex voronoi region hit early out
  result:=sqr(b.x-p.x)+sqr(b.y-p.y)+sqr(b.z-p.z);
  exit;
 end;
 if (tdenom<=0.0) and (udenom<=0.0) then begin
  // Vertex voronoi region hit early out
  result:=sqr(c.x-p.x)+sqr(c.y-p.y)+sqr(c.z-p.z);
  exit;
 end;

 // Determine if P is outside (or on) edge AB by finding the area formed by vectors PA, PB and
 // the triangle normal. A scalar triple product is used. P is outside (or on) AB if the triple
 // scalar product [N PA PB] <= 0
 n.x:=(ab.y*ac.z)-(ab.z*ac.y);
 n.y:=(ab.z*ac.x)-(ab.x*ac.z);
 n.z:=(ab.x*ac.y)-(ab.y*ac.x);
 ap.x:=a.x-p.x;
 ap.y:=a.y-p.y;
 ap.z:=a.z-p.z;
 bp.x:=b.x-p.x;
 bp.y:=b.y-p.y;
 bp.z:=b.z-p.z;
 vc:=(n.x*((ap.y*bp.z)-(ap.z*bp.y)))+(n.y*((ap.z*bp.x)-(ap.x*bp.z)))+(n.z*((ap.x*bp.y)-(ap.y*bp.x)));

 // If P is outside of AB (signed area <= 0) and within voronoi feature region, then return
 // projection of P onto AB
 if (vc<=0.0) and (snom>=0.0) and (sdenom>=0.0) then begin
  u:=snom/(snom+sdenom);
  result:=sqr((a.x+(ab.x*u))-p.x)+sqr((a.y+(ab.y*u))-p.y)+sqr((a.z+(ab.z*u))-p.z);
  exit;
 end;

 // Repeat the same test for P onto BC
 cp.x:=c.x-p.x;
 cp.y:=c.y-p.y;
 cp.z:=c.z-p.z;
 va:=(n.x*((bp.y*cp.z)-(bp.z*cp.y)))+(n.y*((bp.z*cp.x)-(bp.x*cp.z)))+(n.z*((bp.x*cp.y)-(bp.y*cp.x)));
 if (va<=0.0) and (unom>=0.0) and (udenom>=0.0) then begin
  v:=unom/(unom+udenom);
  result:=sqr((b.x+(bc.x*v))-p.x)+sqr((b.y+(bc.y*v))-p.y)+sqr((b.z+(bc.z*v))-p.z);
  exit;
 end;

 // Repeat the same test for P onto CA
 vb:=(n.x*((cp.y*ap.z)-(cp.z*ap.y)))+(n.y*((cp.z*ap.x)-(cp.x*ap.z)))+(n.z*((cp.x*ap.y)-(cp.y*ap.x)));
 if (vb<=0.0) and (tnom>=0.0) and (tdenom>=0.0) then begin
  w:=tnom/(tnom+tdenom);
  result:=sqr((a.x+(ac.x*w))-p.x)+sqr((a.y+(ac.y*w))-p.y)+sqr((a.z+(ac.z*w))-p.z);
  exit;
 end;

 // P must project onto inside face. Find closest point using the barycentric coordinates
 w:=1.0/(va+vb+vc);
 u:=va*w;
 v:=vb*w;
 w:=(1.0-u)-v;

 result:=sqr(((a.x*u)+(b.x*v)+(c.x*w))-p.x)+sqr(((a.y*u)+(b.y*v)+(c.y*w))-p.y)+sqr(((a.z*u)+(b.z*v)+(c.z*w))-p.z);

end;

function IsParallel(const a,b:TVector3;const Tolerance:single=1e-5):boolean; {$ifdef caninline}inline;{$endif}
var t:TVector3;
begin
 t:=Vector3Sub(a,Vector3ScalarMul(b,Vector3Length(a)/Vector3Length(b)));
 result:=(abs(t.x)<Tolerance) and (abs(t.y)<Tolerance) and (abs(t.z)<Tolerance);
end;

function Vector3ToAnglesLDX(v:TVector3):TVector3;
var Yaw,Pitch:single;
begin
 if (v.x=0) and (v.y=0) then begin
  Yaw:=0;
  if v.z>0 then begin
   Pitch:=pi*0.5;
  end else begin
   Pitch:=pi*1.5;
  end;
 end else begin
  if v.x<>0 then begin
   Yaw:=arctan2(v.y,v.x);
  end else if v.y>0 then begin
   Yaw:=pi*0.5;
  end else begin
   Yaw:=pi;
  end;
  if Yaw<0 then begin
   Yaw:=Yaw+(2*pi);
  end;
  Pitch:=arctan2(v.z,sqrt(sqr(v.x)+sqr(v.y)));
  if Pitch<0 then begin
   Pitch:=Pitch+(2*pi);
  end;
 end;
 result.Pitch:=-Pitch;
 result.Yaw:=Yaw;
 result.Roll:=0;
end;

procedure AnglesToVector3LDX(const Angles:TVector3;var ForwardVector,RightVector,UpVector:TVector3);
var cp,sp,cy,sy,cr,sr:single;
begin
 cp:=cos(Angles.Pitch);
 sp:=sin(Angles.Pitch);
 cy:=cos(Angles.Yaw);
 sy:=sin(Angles.Yaw);
 cr:=cos(Angles.Roll);
 sr:=sin(Angles.Roll);
 ForwardVector.x:=cp*cy;
 ForwardVector.y:=cp*sy;
 ForwardVector.z:=-sp;
 RightVector.x:=((-(sr*sp*cy))-(cr*(-sy)));
 RightVector.y:=((-(sr*sp*sy))-(cr*cy));
 RightVector.z:=-(sr*cp);
 UpVector.x:=(cr*sp*cy)+((-sr)*(-sy));
 UpVector.y:=(cr*sp*sy)+((-sr)*cy);
 UpVector.z:=cr*cp;
 Vector3Normalize(ForwardVector);
 Vector3Normalize(RightVector);
 Vector3Normalize(UpVector);
end;

function UnsignedAngle(const v0,v1:TVector3):single; {$ifdef caninline}inline;{$endif}
begin
//result:=ArcCos(Vector3Dot(Vector3Norm(v0),Vector3Norm(v1)));
 result:=ArcTan2(Vector3Length(Vector3Cross(v0,v1)),Vector3Dot(v0,v1));
 if IsNaN(result) or IsInfinite(result) or (abs(result)<1e-12) then begin
  result:=0.0;
 end else begin
  result:=ModuloPos(result,pi*2.0);
 end;
end;

function AngleDegClamp(a:single):single; {$ifdef caninline}inline;{$endif}
begin
 a:=ModuloPos(ModuloPos(a+180.0,360.0)+360.0,360.0)-180.0;
 while a<-180.0 do begin
  a:=a+360.0;
 end;
 while a>180.0 do begin
  a:=a-360.0;
 end;
 result:=a;
end;

function AngleDegDiff(a,b:single):single; {$ifdef caninline}inline;{$endif}
begin
 result:=AngleDegClamp(AngleDegClamp(b)-AngleDegClamp(a));
end;

function AngleClamp(a:single):single; {$ifdef caninline}inline;{$endif}
begin
 a:=ModuloPos(ModuloPos(a+pi,pi*2.0)+(pi*2.0),pi*2.0)-pi;
 while a<(-pi) do begin
  a:=a+(pi*2.0);
 end;
 while a>pi do begin
  a:=a-(pi*2.0);
 end;
 result:=a;
end;

function AngleDiff(a,b:single):single; {$ifdef caninline}inline;{$endif}
begin
 result:=AngleClamp(AngleClamp(b)-AngleClamp(a));
end;

function AngleLerp(a,b,x:single):single; {$ifdef caninline}inline;{$endif}
begin
{if (b-a)>pi then begin
  b:=b-(pi*2);
 end;
 if (b-a)<(-pi) then begin
  b:=b+(pi*2);
 end;
 result:=a+((b-a)*x);}
 result:=a+(AngleDiff(a,b)*x);
end;

procedure CalculateShadowMapViewProjectionMatrixUSMOld(var ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;const LightPosition,LightDirection:TVector3;const ShadowRecieverAABB,ShadowCasterAABB:TAABB;var ZBias,ShadowMapZNear,ShadowMapZFar:single);
const ZBiasCoef=0.55;
var AABB,RecieverAABB,CasterAABB:TAABB;
    AABBCenter,Axis,Origin:TVector3;
    AABBHitDist,MinZ,MaxZ:single;
begin

 AABB:=AABBGetIntersection(ShadowRecieverAABB,ShadowCasterAABB);

 AABBCenter:=Vector3Avg(AABB.Min,AABB.Max);

 if AABBRayIntersectHit(AABB,AABBCenter,Vector3Neg(LightDirection),AABBHitDist) then begin
  Origin:=Vector3Add(AABBCenter,Vector3ScalarMul(LightDirection,-(2.0*AABBHitDist)));
 end else begin
  Origin:=LightPosition;
 end;

 Axis:=Vector3(0,1,0);
 if abs(Vector3Dot(Axis,LightDirection))>0.99 then begin
  Axis:=Vector3(0,0,1);
 end;

 ShadowMapViewMatrix:=Matrix4x4LookAt(Origin,Vector3Add(Origin,LightDirection),Axis);

 RecieverAABB:=AABBTransform(ShadowRecieverAABB,ShadowMapViewMatrix);
 CasterAABB:=AABBTransform(ShadowCasterAABB,ShadowMapViewMatrix);

 AABB:=AABBGetIntersection(RecieverAABB,CasterAABB);
 MinZ:=Min(RecieverAABB.Min.z,CasterAABB.Min.z);
 MaxZ:=Max(RecieverAABB.Max.z,CasterAABB.Max.z);

 ShadowMapProjectionMatrix:=Matrix4x4Ortho(AABB.Min.x,AABB.Max.x,AABB.Min.y,AABB.Max.y,-MaxZ,-MinZ);

 ZBias:=(2.0*ZBiasCoef)/(MaxZ-MinZ);

 ShadowMapZNear:=-MaxZ;
 ShadowMapZFar:=-MinZ;
end;

procedure CalculateShadowMapViewProjectionMatrixUSM(out ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;const LightDirection:TVector3;const ShadowRecieverAABB,ShadowCasterAABB:TAABB;out ZBias,ShadowMapZNear,ShadowMapZFar,SizeX,SizeY:single); overload;
const ZBiasCoef=0.55;
var AABB,RecieverAABB,CasterAABB:TAABB;
    ViewDirection,LightSideVector,LightUpVector,LightForwardVector:TVector3;
    MinZ,MaxZ:single;
begin
 ViewDirection.x:=-CameraViewMatrix[2,0];
 ViewDirection.y:=-CameraViewMatrix[2,1];
 ViewDirection.z:=-CameraViewMatrix[2,2];
 Vector3Normalize(ViewDirection);

 LightForwardVector:=Vector3Norm(Vector3Neg(LightDirection));
 LightSideVector:=Vector3Norm(Vector3Cross(ViewDirection,LightForwardVector));
 LightUpVector:=Vector3Norm(Vector3Cross(LightForwardVector,LightSideVector));

 ShadowMapViewMatrix[0,0]:=LightSideVector.x;
 ShadowMapViewMatrix[0,1]:=LightUpVector.x;
 ShadowMapViewMatrix[0,2]:=LightForwardVector.x;
 ShadowMapViewMatrix[0,3]:=0.0;
 ShadowMapViewMatrix[1,0]:=LightSideVector.y;
 ShadowMapViewMatrix[1,1]:=LightUpVector.y;
 ShadowMapViewMatrix[1,2]:=LightForwardVector.y;
 ShadowMapViewMatrix[1,3]:=0.0;
 ShadowMapViewMatrix[2,0]:=LightSideVector.z;
 ShadowMapViewMatrix[2,1]:=LightUpVector.z;
 ShadowMapViewMatrix[2,2]:=LightForwardVector.z;
 ShadowMapViewMatrix[2,3]:=0.0;
 ShadowMapViewMatrix[3,0]:=0.0;
 ShadowMapViewMatrix[3,1]:=0.0;
 ShadowMapViewMatrix[3,2]:=0.0;
 ShadowMapViewMatrix[3,3]:=1.0;

 RecieverAABB:=AABBTransform(ShadowRecieverAABB,ShadowMapViewMatrix);
 CasterAABB:=AABBTransform(ShadowCasterAABB,ShadowMapViewMatrix);

 AABB:=AABBGetIntersection(RecieverAABB,CasterAABB);
 MinZ:=Min(RecieverAABB.Min.z,CasterAABB.Min.z);
 MaxZ:=Max(RecieverAABB.Max.z,CasterAABB.Max.z);

 ShadowMapProjectionMatrix:=Matrix4x4Ortho(AABB.Min.x,AABB.Max.x,AABB.Min.y,AABB.Max.y,-MaxZ,-MinZ);

 ZBias:=(2.0*ZBiasCoef)/(MaxZ-MinZ);

 ShadowMapZNear:=-MaxZ;
 ShadowMapZFar:=-MinZ;

 SizeX:=AABB.Max.x-AABB.Min.x;
 SizeY:=AABB.Max.y-AABB.Min.y;

end;{}

procedure CalculateShadowMapViewProjectionMatrixUSM(out ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;const LightDirection:TVector3;const FocusPoints:PVector3s;const CountFocusPoints:longint;const Casters:PAABBs;const CountCasters:longint;out ZBias,ShadowMapZNear,ShadowMapZFar,SizeX,SizeY:single); overload;
const ZBiasCoef=0.55;
var Counter,SubCounter:longint;
    ViewDirection,LightSideVector,LightUpVector,LightForwardVector,TempVector:TVector3;
    AABB,RecieverAABB,CasterAABB:TAABB;
    MinZ,MaxZ:single;
    First:boolean;
begin
 ViewDirection.x:=-CameraViewMatrix[2,0];
 ViewDirection.y:=-CameraViewMatrix[2,1];
 ViewDirection.z:=-CameraViewMatrix[2,2];
 Vector3Normalize(ViewDirection);

 LightForwardVector:=Vector3Norm(Vector3Neg(LightDirection));
 LightSideVector:=Vector3Norm(Vector3Cross(ViewDirection,LightForwardVector));
 LightUpVector:=Vector3Norm(Vector3Cross(LightForwardVector,LightSideVector));

 ShadowMapViewMatrix[0,0]:=LightSideVector.x;
 ShadowMapViewMatrix[0,1]:=LightUpVector.x;
 ShadowMapViewMatrix[0,2]:=LightForwardVector.x;
 ShadowMapViewMatrix[0,3]:=0.0;
 ShadowMapViewMatrix[1,0]:=LightSideVector.y;
 ShadowMapViewMatrix[1,1]:=LightUpVector.y;
 ShadowMapViewMatrix[1,2]:=LightForwardVector.y;
 ShadowMapViewMatrix[1,3]:=0.0;
 ShadowMapViewMatrix[2,0]:=LightSideVector.z;
 ShadowMapViewMatrix[2,1]:=LightUpVector.z;
 ShadowMapViewMatrix[2,2]:=LightForwardVector.z;
 ShadowMapViewMatrix[2,3]:=0.0;
 ShadowMapViewMatrix[3,0]:=0.0;
 ShadowMapViewMatrix[3,1]:=0.0;
 ShadowMapViewMatrix[3,2]:=0.0;
 ShadowMapViewMatrix[3,3]:=1.0;

 First:=true;
 for Counter:=0 to CountFocusPoints-1 do begin
  TempVector:=Vector3TermMatrixMul(FocusPoints^[Counter],ShadowMapViewMatrix);
  if First then begin
   First:=false;
   RecieverAABB.Min:=TempVector;
   RecieverAABB.Max:=TempVector;
  end else begin
   RecieverAABB.Min.x:=Min(RecieverAABB.Min.x,TempVector.x);
   RecieverAABB.Min.y:=Min(RecieverAABB.Min.y,TempVector.y);
   RecieverAABB.Min.z:=Min(RecieverAABB.Min.z,TempVector.z);
   RecieverAABB.Max.x:=Max(RecieverAABB.Max.x,TempVector.x);
   RecieverAABB.Max.y:=Max(RecieverAABB.Max.y,TempVector.y);
   RecieverAABB.Max.z:=Max(RecieverAABB.Max.z,TempVector.z);
  end;
 end;

 First:=true;
 for Counter:=0 to CountCasters-1 do begin
  for SubCounter:=0 to 7 do begin
   TempVector:=Vector3TermMatrixMul(Vector3(Casters^[Counter].MinMax[(SubCounter shr 0) and 1].x,Casters^[Counter].MinMax[(SubCounter shr 1) and 1].y,Casters^[Counter].MinMax[(SubCounter shr 2) and 1].z),ShadowMapViewMatrix);
   if First then begin
    First:=false;
    CasterAABB.Min:=TempVector;
    CasterAABB.Max:=TempVector;
   end else begin
    CasterAABB.Min.x:=Min(CasterAABB.Min.x,TempVector.x);
    CasterAABB.Min.y:=Min(CasterAABB.Min.y,TempVector.y);
    CasterAABB.Min.z:=Min(CasterAABB.Min.z,TempVector.z);
    CasterAABB.Max.x:=Max(CasterAABB.Max.x,TempVector.x);
    CasterAABB.Max.y:=Max(CasterAABB.Max.y,TempVector.y);
    CasterAABB.Max.z:=Max(CasterAABB.Max.z,TempVector.z);
   end;
  end;
 end;

 AABB:=AABBGetIntersection(RecieverAABB,CasterAABB);
 MinZ:=Min(RecieverAABB.Min.z,CasterAABB.Min.z);
 MaxZ:=Max(RecieverAABB.Max.z,CasterAABB.Max.z);

 ShadowMapProjectionMatrix:=Matrix4x4Ortho(AABB.Min.x,AABB.Max.x,AABB.Min.y,AABB.Max.y,-MaxZ,-MinZ);

 ZBias:=(2.0*ZBiasCoef)/(MaxZ-MinZ);

 ShadowMapZNear:=-MaxZ;
 ShadowMapZFar:=-MinZ;

 SizeX:=AABB.Max.x-AABB.Min.x;
 SizeY:=AABB.Max.y-AABB.Min.y;
end;

procedure CalculateShadowMapViewProjectionMatrixXPSM(out ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;const LightDirection:TVector3;const ShadowRecieverPoints:PVector3s;const CountShadowRecieverPoints:longint;const ShadowCasterAABBs:PAABBs;const CountShadowCasterAABBs:longint;out ZBias,ShadowMapZNear,ShadowMapZFar:single);
const Coef=0.05;
      EpsilonW=0.85;
      ZBiasCoef=0.55;
var Counter,SubCounter:longint;
    PPLSFocusRegionAABB,PPLSShadowRecieverAABB,PPLSShadowCasterAABB:TAABB;
    ViewDirection,LightSideVector,LightUpVector,LightForwardVector,
    ViewLightDir,ViewVector,TempVector:TVector3;
    UnitProjectionVector:TVector2;
    LightSpace,PostProjectionLightSpaceTransformationMatrix,
    ProjectionMatrix,ZRotationMatrix,UnitCubeBaseMatrix,TempMatrix:TMatrix4x4;
    UnitProjectionVectorLength,MinCastersProjection,MinRecieversProjection,
    MinFocusRegionProjection,MaximumProjectionVectorLength,CosGamma,
    LengthProjection,MinZ,MaxZ,Temp:single;
    v4:TVector4;
    First:boolean;
begin
 ViewDirection.x:=-CameraViewMatrix[2,0];
 ViewDirection.y:=-CameraViewMatrix[2,1];
 ViewDirection.z:=-CameraViewMatrix[2,2];
 Vector3Normalize(ViewDirection);
 Temp:=abs(Vector3Dot(ViewDirection,LightDirection));

 if Temp<0.1 then begin

  LightForwardVector:=Vector3Norm(Vector3Neg(LightDirection));
  LightSideVector:=Vector3Norm(Vector3Cross(ViewDirection,LightForwardVector));
  LightUpVector:=Vector3Norm(Vector3Cross(LightForwardVector,LightSideVector));

  ShadowMapViewMatrix[0,0]:=LightSideVector.x;
  ShadowMapViewMatrix[0,1]:=LightUpVector.x;
  ShadowMapViewMatrix[0,2]:=LightForwardVector.x;
  ShadowMapViewMatrix[0,3]:=0.0;
  ShadowMapViewMatrix[1,0]:=LightSideVector.y;
  ShadowMapViewMatrix[1,1]:=LightUpVector.y;
  ShadowMapViewMatrix[1,2]:=LightForwardVector.y;
  ShadowMapViewMatrix[1,3]:=0.0;
  ShadowMapViewMatrix[2,0]:=LightSideVector.z;
  ShadowMapViewMatrix[2,1]:=LightUpVector.z;
  ShadowMapViewMatrix[2,2]:=LightForwardVector.z;
  ShadowMapViewMatrix[2,3]:=0.0;
  ShadowMapViewMatrix[3,0]:=0.0;
  ShadowMapViewMatrix[3,1]:=0.0;
  ShadowMapViewMatrix[3,2]:=0.0;
  ShadowMapViewMatrix[3,3]:=1.0;

  First:=true;
  for Counter:=0 to CountShadowRecieverPoints-1 do begin
   TempVector:=Vector3TermMatrixMul(ShadowRecieverPoints^[Counter],ShadowMapViewMatrix);
   if First then begin
    First:=false;
    PPLSShadowRecieverAABB.Min:=TempVector;
    PPLSShadowRecieverAABB.Max:=TempVector;
   end else begin
    PPLSShadowRecieverAABB.Min.x:=Min(PPLSShadowRecieverAABB.Min.x,TempVector.x);
    PPLSShadowRecieverAABB.Min.y:=Min(PPLSShadowRecieverAABB.Min.y,TempVector.y);
    PPLSShadowRecieverAABB.Min.z:=Min(PPLSShadowRecieverAABB.Min.z,TempVector.z);
    PPLSShadowRecieverAABB.Max.x:=Max(PPLSShadowRecieverAABB.Max.x,TempVector.x);
    PPLSShadowRecieverAABB.Max.y:=Max(PPLSShadowRecieverAABB.Max.y,TempVector.y);
    PPLSShadowRecieverAABB.Max.z:=Max(PPLSShadowRecieverAABB.Max.z,TempVector.z);
   end;
  end;

  First:=true;
  for Counter:=0 to CountShadowCasterAABBs-1 do begin
   for SubCounter:=0 to 7 do begin
    TempVector:=Vector3TermMatrixMul(Vector3(ShadowCasterAABBs^[Counter].MinMax[(SubCounter shr 0) and 1].x,ShadowCasterAABBs^[Counter].MinMax[(SubCounter shr 1) and 1].y,ShadowCasterAABBs^[Counter].MinMax[(SubCounter shr 2) and 1].z),ShadowMapViewMatrix);
    if First then begin
     First:=false;
     PPLSShadowCasterAABB.Min:=TempVector;
     PPLSShadowCasterAABB.Max:=TempVector;
    end else begin
     PPLSShadowCasterAABB.Min.x:=Min(PPLSShadowCasterAABB.Min.x,TempVector.x);
     PPLSShadowCasterAABB.Min.y:=Min(PPLSShadowCasterAABB.Min.y,TempVector.y);
     PPLSShadowCasterAABB.Min.z:=Min(PPLSShadowCasterAABB.Min.z,TempVector.z);
     PPLSShadowCasterAABB.Max.x:=Max(PPLSShadowCasterAABB.Max.x,TempVector.x);
     PPLSShadowCasterAABB.Max.y:=Max(PPLSShadowCasterAABB.Max.y,TempVector.y);
     PPLSShadowCasterAABB.Max.z:=Max(PPLSShadowCasterAABB.Max.z,TempVector.z);
    end;
   end;
  end;

  PPLSFocusRegionAABB:=AABBGetIntersection(PPLSShadowRecieverAABB,PPLSShadowCasterAABB);
  MinZ:=Min(PPLSShadowRecieverAABB.Min.z,PPLSShadowCasterAABB.Min.z);
  MaxZ:=Max(PPLSShadowRecieverAABB.Max.z,PPLSShadowCasterAABB.Max.z);

  ShadowMapProjectionMatrix:=Matrix4x4Ortho(PPLSFocusRegionAABB.Min.x,PPLSFocusRegionAABB.Max.x,PPLSFocusRegionAABB.Min.y,PPLSFocusRegionAABB.Max.y,-MaxZ,-MinZ);

  ZBias:=(2.0*ZBiasCoef)/(MaxZ-MinZ);

  ShadowMapZNear:=-MaxZ;
  ShadowMapZFar:=-MinZ;

 end else begin

  // Transform light direction into view space
  ViewLightDir:=Vector3Neg(Vector3Norm(Vector3TermMatrixMulBasis(LightDirection,CameraViewMatrix)));

  // Build light space look at matrix
  LightSpace:=Matrix4x4LookAtLH(Vector3Origin,ViewLightDir,Vector3YAxis);

  // Transform view vector into light space
  ViewVector.x:=LightSpace[2,0];
  ViewVector.y:=LightSpace[2,1];
  ViewVector.z:=LightSpace[2,2];

  // Project view vector into xy plane and find unit projection vector
  UnitProjectionVector.x:=ViewVector.x;
  UnitProjectionVector.y:=ViewVector.y;
  UnitProjectionVectorLength:=Vector2Length(UnitProjectionVector);

  // Check projection vector length
  if UnitProjectionVectorLength>0.1 then begin

   // Normalize projection vector
   UnitProjectionVector.x:=UnitProjectionVector.x/UnitProjectionVectorLength;
   UnitProjectionVector.y:=UnitProjectionVector.y/UnitProjectionVectorLength;

   TempMatrix:=Matrix4x4TermMul(CameraViewMatrix,LightSpace);

   // Project casters points into unit projection vector and find minimal value
   MinCastersProjection:=1.0;
   for Counter:=0 to CountShadowCasterAABBs-1 do begin
    for SubCounter:=0 to 7 do begin
     TempVector:=Vector3TermMatrixMul(Vector3(ShadowCasterAABBs^[Counter].MinMax[(SubCounter shr 0) and 1].x,
                                              ShadowCasterAABBs^[Counter].MinMax[(SubCounter shr 1) and 1].y,
                                              ShadowCasterAABBs^[Counter].MinMax[(SubCounter shr 2) and 1].z),
                                      TempMatrix);
     MinCastersProjection:=Min(MinCastersProjection,(TempVector.x*UnitProjectionVector.x)+(TempVector.y*UnitProjectionVector.y));
    end;
   end;

   // Project recievers points into unit projection vector and find minimal value
   MinRecieversProjection:=1.0;
   for Counter:=0 to CountShadowRecieverPoints-1 do begin
    TempVector:=Vector3TermMatrixMul(ShadowRecieverPoints[Counter],TempMatrix);
    MinRecieversProjection:=Min(MinRecieversProjection,(TempVector.x*UnitProjectionVector.x)+(TempVector.y*UnitProjectionVector.y));
   end;

   // Find focus region interval minimal point
   MinFocusRegionProjection:=Max(MinCastersProjection,MinRecieversProjection);

   // Find maximum projection vector length
   MaximumProjectionVectorLength:=(EpsilonW-1.0)/MinFocusRegionProjection;

   // Find optimal (fixed warping) projection vector length
   CosGamma:=(ViewVector.x*UnitProjectionVector.x)+(ViewVector.y*UnitProjectionVector.y);
   LengthProjection:=Coef/CosGamma;

   // Clip projection vector length
   if (MaximumProjectionVectorLength>0.0) and (LengthProjection>MaximumProjectionVectorLength) then begin
    LengthProjection:=MaximumProjectionVectorLength;
   end;

   // Calculate projection matrix
   ProjectionMatrix[0,0]:=1.0;
   ProjectionMatrix[0,1]:=0.0;
   ProjectionMatrix[0,2]:=0.0;
   ProjectionMatrix[0,3]:=UnitProjectionVector.x*LengthProjection;
   ProjectionMatrix[1,0]:=0.0;
   ProjectionMatrix[1,1]:=1.0;
   ProjectionMatrix[1,2]:=0.0;
   ProjectionMatrix[1,3]:=UnitProjectionVector.y*LengthProjection;
   ProjectionMatrix[2,0]:=0.0;
   ProjectionMatrix[2,1]:=0.0;
   ProjectionMatrix[2,2]:=1.0;
   ProjectionMatrix[2,3]:=0.0;
   ProjectionMatrix[3,0]:=0.0;
   ProjectionMatrix[3,1]:=0.0;
   ProjectionMatrix[3,2]:=0.0;
   ProjectionMatrix[3,3]:=1.0;

   // Calculate Z rotation basis for to maximize shadow map resolution
   ZRotationMatrix[0,0]:=UnitProjectionVector.x;
   ZRotationMatrix[0,1]:=UnitProjectionVector.y;
   ZRotationMatrix[0,2]:=0.0;
   ZRotationMatrix[0,3]:=0.0;
   ZRotationMatrix[1,0]:=UnitProjectionVector.y;
   ZRotationMatrix[1,1]:=-UnitProjectionVector.x;
   ZRotationMatrix[1,2]:=0.0;
   ZRotationMatrix[1,3]:=0.0;
   ZRotationMatrix[2,0]:=0.0;
   ZRotationMatrix[2,1]:=0.0;
   ZRotationMatrix[2,2]:=1.0;
   ZRotationMatrix[2,3]:=0.0;
   ZRotationMatrix[3,0]:=0.0;
   ZRotationMatrix[3,1]:=0.0;
   ZRotationMatrix[3,2]:=0.0;
   ZRotationMatrix[3,3]:=1.0;

   // Combine transformations
   PostProjectionLightSpaceTransformationMatrix:=Matrix4x4TermMul(ProjectionMatrix,ZRotationMatrix);

  end else begin

   // Miner lamp case, use orthogonal shadows
   PostProjectionLightSpaceTransformationMatrix:=Matrix4x4Identity;

  end;

  // Final, combined PPLS transformation: LightSpace * PPLS Transform
  PostProjectionLightSpaceTransformationMatrix:=Matrix4x4TermMul(LightSpace,PostProjectionLightSpaceTransformationMatrix);

  TempMatrix:=Matrix4x4TermMul(CameraViewMatrix,PostProjectionLightSpaceTransformationMatrix);

  // Transform receivers into PPLS (post projection light space) and construct an AABB
  First:=true;
  for Counter:=0 to CountShadowRecieverPoints-1 do begin
   TempVector:=ShadowRecieverPoints[Counter];
   v4.x:=TempVector.x;
   v4.y:=TempVector.y;
   v4.z:=TempVector.z;
   v4.w:=1.0;
   Vector4MatrixMul(v4,TempMatrix);
   TempVector.x:=v4.x/v4.w;
   TempVector.y:=v4.y/v4.w;
   if v4.w<EpsilonW then begin
    TempVector.z:=0.0;
   end else begin
    TempVector.z:=v4.z/v4.w;
   end;
   if First then begin
    First:=false;
    PPLSShadowRecieverAABB.Min:=TempVector;
    PPLSShadowRecieverAABB.Max:=TempVector;
   end else begin
    PPLSShadowRecieverAABB:=AABBCombineVector3(PPLSShadowRecieverAABB,TempVector);
   end;
  end;

  // Transform casters into PPLS (post projection light space) and construct an AABB
  First:=true;
  for Counter:=0 to CountShadowCasterAABBs-1 do begin
   for SubCounter:=0 to 7 do begin
    TempVector:=Vector3(ShadowCasterAABBs^[Counter].MinMax[(SubCounter shr 0) and 1].x,
                        ShadowCasterAABBs^[Counter].MinMax[(SubCounter shr 1) and 1].y,
                        ShadowCasterAABBs^[Counter].MinMax[(SubCounter shr 2) and 1].z);
    v4.x:=TempVector.x;
    v4.y:=TempVector.y;
    v4.z:=TempVector.z;
    v4.w:=1.0;
    Vector4MatrixMul(v4,TempMatrix);
    TempVector.x:=v4.x/v4.w;
    TempVector.y:=v4.y/v4.w;
    if v4.w<EpsilonW then begin
     TempVector.z:=0.0;
    end else begin
     TempVector.z:=v4.z/v4.w;
    end;
    if First then begin
     First:=false;
     PPLSShadowCasterAABB.Min:=TempVector;
     PPLSShadowCasterAABB.Max:=TempVector;
    end else begin
     PPLSShadowCasterAABB:=AABBCombineVector3(PPLSShadowCasterAABB,TempVector);
    end;
   end;
  end;

  // Find post projection space focus region and build focus region linear basis
  PPLSFocusRegionAABB:=AABBGetIntersection(PPLSShadowRecieverAABB,PPLSShadowCasterAABB);
  MinZ:=Max(PPLSShadowRecieverAABB.Min.z,PPLSShadowCasterAABB.Min.z);
  MaxZ:=Max(PPLSShadowRecieverAABB.Max.z,PPLSShadowCasterAABB.Max.z);

  UnitCubeBaseMatrix[0,0]:=1.0/(PPLSFocusRegionAABB.Max.x-PPLSFocusRegionAABB.Min.x);
  UnitCubeBaseMatrix[0,1]:=0.0;
  UnitCubeBaseMatrix[0,2]:=0.0;
  UnitCubeBaseMatrix[0,3]:=0.0;
  UnitCubeBaseMatrix[1,0]:=0.0;
  UnitCubeBaseMatrix[1,1]:=1.0/(PPLSFocusRegionAABB.Max.y-PPLSFocusRegionAABB.Min.y);
  UnitCubeBaseMatrix[1,2]:=0.0;
  UnitCubeBaseMatrix[1,3]:=0.0;
  UnitCubeBaseMatrix[2,0]:=0.0;
  UnitCubeBaseMatrix[2,1]:=0.0;
  UnitCubeBaseMatrix[2,2]:=1.0/(MaxZ-MinZ);
  UnitCubeBaseMatrix[2,3]:=0.0;
  UnitCubeBaseMatrix[3,0]:=(-PPLSFocusRegionAABB.Min.x)/(PPLSFocusRegionAABB.Max.x-PPLSFocusRegionAABB.Min.x);
  UnitCubeBaseMatrix[3,1]:=(-PPLSFocusRegionAABB.Min.y)/(PPLSFocusRegionAABB.Max.y-PPLSFocusRegionAABB.Min.y);
  UnitCubeBaseMatrix[3,2]:=(-MinZ)/(MaxZ-MinZ);
  UnitCubeBaseMatrix[3,3]:=1.0;

  ShadowMapViewMatrix:=Matrix4x4Identity;
  ShadowMapProjectionMatrix:=Matrix4x4TermMul(CameraViewMatrix,PostProjectionLightSpaceTransformationMatrix);
  Matrix4x4Mul(ShadowMapProjectionMatrix,UnitCubeBaseMatrix);
  Matrix4x4Mul(ShadowMapProjectionMatrix,Matrix4x4NormalizedSpace);{}

{ ShadowMapViewMatrix:=Matrix4x4TermMul(CameraViewMatrix,PostProjectionLightSpaceTransformationMatrix);
  ShadowMapProjectionMatrix:=Matrix4x4TermMul(UnitCubeBaseMatrix,Matrix4x4NormalizedSpace);{}

  ZBias:=(2.0*ZBiasCoef)/(MaxZ-MinZ);

  ShadowMapZNear:=-MaxZ;
  ShadowMapZFar:=-MinZ;

 end;
end;

procedure GetLiSPSMMatrix(out ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;const LightDirection:TVector3;const FocusPoints:PVector3s;const CountFocusPoints:longint;const Casters:PAABBs;const CountCasters:longint;const GLPSM:boolean;const lispsm_n,lispsm_nopt_weight:single;out ZBias,ShadowMapZNear,ShadowMapZFar:single);
type PConeExtents=^TConeExtents;
     TConeExtents=record
      MaxX:single;
      MaxY:single;
      MinZ:single;
      MaxZ:single;
     end;
 function CalculateLambda1GLPR(const theta,a,b,n,f:single):single;
 begin
  result:=(n-(a/tan(theta)))/((f-n)+((a+b)/tan(theta)));
 end;
 function CalculateLambda2GLPR(const theta,Gamma,a,b,n,f:single):single;
 begin
  result:=CalculateLambda1GLPR(Gamma,a,b,n,f)/sin((theta/(2.0*gamma))*pi);
 end;
const ZBiasCoef=0.55;
var Counter,SubCounter:longint;
    First:boolean;
    cos_theta,sin_theta,nopt,n,MinZ,MaxZ,camera_z_near,foc_near,foc_far,theta,
    tan_fov_2,a,b,gamma,lambda1_gamma_threshold,lambda,max_x,max_y,max_z:single;
    ViewDirection,LightSideVector,LightUpVector,LightForwardVector,TempVector,
    projection_point:TVector3;
    LightSpace,WorldToLightSpace:TMatrix3x3;
    new_light_space,l_view,l_projection,permute,r:TMatrix4x4;
    LightSpaceRecieversExtents,LightSpaceCastersExtents,LightSpaceExtents,AABB,
    RecieverAABB,CasterAABB:TAABB;
    receivers_new_ls_extents,casters_new_ls_extents:TConeExtents;
begin

 ViewDirection:=PVector3(pointer(@CameraViewMatrix[2,0]))^;

 PVector3(pointer(@LightSpace[1,0]))^:=Vector3Neg(LightDirection);
 PVector3(pointer(@LightSpace[0,0]))^:=Vector3Norm(Vector3Cross(PVector3(pointer(@LightSpace[1,0]))^,ViewDirection));
 PVector3(pointer(@LightSpace[2,0]))^:=Vector3Norm(Vector3Cross(PVector3(pointer(@LightSpace[0,0]))^,PVector3(pointer(@LightSpace[1,0]))^));

 Matrix3x3Transpose(LightSpace);

 WorldToLightSpace:=Matrix3x3TermTranspose(LightSpace);

 First:=true;
 for Counter:=0 to CountFocusPoints-1 do begin
  TempVector:=Vector3TermMatrixMul(FocusPoints^[Counter],WorldToLightSpace);
  if First then begin
   First:=false;
   LightSpaceRecieversExtents.Min:=TempVector;
   LightSpaceRecieversExtents.Max:=TempVector;
  end else begin
   LightSpaceRecieversExtents.Min.x:=Min(LightSpaceRecieversExtents.Min.x,TempVector.x);
   LightSpaceRecieversExtents.Min.y:=Min(LightSpaceRecieversExtents.Min.y,TempVector.y);
   LightSpaceRecieversExtents.Min.z:=Min(LightSpaceRecieversExtents.Min.z,TempVector.z);
   LightSpaceRecieversExtents.Max.x:=Max(LightSpaceRecieversExtents.Max.x,TempVector.x);
   LightSpaceRecieversExtents.Max.y:=Max(LightSpaceRecieversExtents.Max.y,TempVector.y);
   LightSpaceRecieversExtents.Max.z:=Max(LightSpaceRecieversExtents.Max.z,TempVector.z);
  end;
 end;

 First:=true;
 for Counter:=0 to CountCasters-1 do begin
  for SubCounter:=0 to 7 do begin
   TempVector:=Vector3TermMatrixMul(Vector3(Casters^[Counter].MinMax[(SubCounter shr 0) and 1].x,Casters^[Counter].MinMax[(SubCounter shr 1) and 1].y,Casters^[Counter].MinMax[(SubCounter shr 2) and 1].z),ShadowMapViewMatrix);
   if First then begin
    First:=false;
    LightSpaceCastersExtents.Min:=TempVector;
    LightSpaceCastersExtents.Max:=TempVector;
   end else begin
    LightSpaceCastersExtents.Min.x:=Min(LightSpaceCastersExtents.Min.x,TempVector.x);
    LightSpaceCastersExtents.Min.y:=Min(LightSpaceCastersExtents.Min.y,TempVector.y);
    LightSpaceCastersExtents.Min.z:=Min(LightSpaceCastersExtents.Min.z,TempVector.z);
    LightSpaceCastersExtents.Max.x:=Max(LightSpaceCastersExtents.Max.x,TempVector.x);
    LightSpaceCastersExtents.Max.y:=Max(LightSpaceCastersExtents.Max.y,TempVector.y);
    LightSpaceCastersExtents.Max.z:=Max(LightSpaceCastersExtents.Max.z,TempVector.z);
   end;
  end;
 end;

 LightSpaceExtents:=AABBCombine(LightSpaceRecieversExtents,LightSpaceCastersExtents);

 cos_theta:=Vector3Dot(ViewDirection,LightDirection);

 if abs(cos_theta)>0.99 then begin

  ViewDirection.x:=-CameraViewMatrix[2,0];
  ViewDirection.y:=-CameraViewMatrix[2,1];
  ViewDirection.z:=-CameraViewMatrix[2,2];
  Vector3Normalize(ViewDirection);

  LightForwardVector:=Vector3Norm(Vector3Neg(LightDirection));
  LightSideVector:=Vector3Norm(Vector3Cross(ViewDirection,LightForwardVector));
  LightUpVector:=Vector3Norm(Vector3Cross(LightForwardVector,LightSideVector));

  ShadowMapViewMatrix[0,0]:=LightSideVector.x;
  ShadowMapViewMatrix[0,1]:=LightUpVector.x;
  ShadowMapViewMatrix[0,2]:=LightForwardVector.x;
  ShadowMapViewMatrix[0,3]:=0.0;
  ShadowMapViewMatrix[1,0]:=LightSideVector.y;
  ShadowMapViewMatrix[1,1]:=LightUpVector.y;
  ShadowMapViewMatrix[1,2]:=LightForwardVector.y;
  ShadowMapViewMatrix[1,3]:=0.0;
  ShadowMapViewMatrix[2,0]:=LightSideVector.z;
  ShadowMapViewMatrix[2,1]:=LightUpVector.z;
  ShadowMapViewMatrix[2,2]:=LightForwardVector.z;
  ShadowMapViewMatrix[2,3]:=0.0;
  ShadowMapViewMatrix[3,0]:=0.0;
  ShadowMapViewMatrix[3,1]:=0.0;
  ShadowMapViewMatrix[3,2]:=0.0;
  ShadowMapViewMatrix[3,3]:=1.0;

  First:=true;
  for Counter:=0 to CountFocusPoints-1 do begin
   TempVector:=Vector3TermMatrixMul(FocusPoints^[Counter],ShadowMapViewMatrix);
   if First then begin
    First:=false;
    RecieverAABB.Min:=TempVector;
    RecieverAABB.Max:=TempVector;
   end else begin
    RecieverAABB.Min.x:=Min(RecieverAABB.Min.x,TempVector.x);
    RecieverAABB.Min.y:=Min(RecieverAABB.Min.y,TempVector.y);
    RecieverAABB.Min.z:=Min(RecieverAABB.Min.z,TempVector.z);
    RecieverAABB.Max.x:=Max(RecieverAABB.Max.x,TempVector.x);
    RecieverAABB.Max.y:=Max(RecieverAABB.Max.y,TempVector.y);
    RecieverAABB.Max.z:=Max(RecieverAABB.Max.z,TempVector.z);
   end;
  end;

  First:=true;
  for Counter:=0 to CountCasters-1 do begin
   for SubCounter:=0 to 7 do begin
    TempVector:=Vector3TermMatrixMul(Vector3(Casters^[Counter].MinMax[(SubCounter shr 0) and 1].x,Casters^[Counter].MinMax[(SubCounter shr 1) and 1].y,Casters^[Counter].MinMax[(SubCounter shr 2) and 1].z),ShadowMapViewMatrix);
    if First then begin
     First:=false;
     CasterAABB.Min:=TempVector;
     CasterAABB.Max:=TempVector;
    end else begin
     CasterAABB.Min.x:=Min(CasterAABB.Min.x,TempVector.x);
     CasterAABB.Min.y:=Min(CasterAABB.Min.y,TempVector.y);
     CasterAABB.Min.z:=Min(CasterAABB.Min.z,TempVector.z);
     CasterAABB.Max.x:=Max(CasterAABB.Max.x,TempVector.x);
     CasterAABB.Max.y:=Max(CasterAABB.Max.y,TempVector.y);
     CasterAABB.Max.z:=Max(CasterAABB.Max.z,TempVector.z);
    end;
   end;
  end;

  AABB:=AABBGetIntersection(RecieverAABB,CasterAABB);
  MinZ:=Min(RecieverAABB.Min.z,CasterAABB.Min.z);
  MaxZ:=Max(RecieverAABB.Max.z,CasterAABB.Max.z);

  ShadowMapProjectionMatrix:=Matrix4x4Ortho(AABB.Min.x,AABB.Max.x,AABB.Min.y,AABB.Max.y,-MaxZ,-MinZ);

  ZBias:=(2.0*ZBiasCoef)/(MaxZ-MinZ);

  ShadowMapZNear:=-MaxZ;
  ShadowMapZFar:=-MinZ;

 end else begin

  sin_theta:=sqrt(1.0-sqr(cos_theta));

  if GLPSM then begin

   foc_near:=0.0;
   foc_far:=0.0;

   First:=true;
   for Counter:=0 to CountFocusPoints-1 do begin
    TempVector:=Vector3TermMatrixMul(FocusPoints^[Counter],CameraViewMatrix);
    if First then begin
     First:=false;
     foc_near:=TempVector.z;
     foc_far:=TempVector.z;
    end else begin
     foc_near:=Min(foc_near,TempVector.z);
     foc_far:=Max(foc_far,TempVector.z);
    end;
   end;
   theta:=ArcSin(sin_theta);

   tan_fov_2:=1.0/CameraProjectionMatrix[1,2];

   a:=foc_near*tan_fov_2;
	 b:=foc_far*tan_fov_2;
		
   gamma:=ArcTan(tan_fov_2)+0.05;
   lambda1_gamma_threshold:=foc_near/(2.0*(foc_far-foc_near));

	 while CalculateLambda1GLPR(gamma,a,b,foc_near,foc_far)<lambda1_gamma_threshold do begin
    gamma:=gamma+0.05;
   end;

   if abs(Theta)<Gamma then begin
 	  lambda:=CalculateLambda2GLPR(theta,gamma,a,b,foc_near,foc_far);
   end else begin
	  lambda:=CalculateLambda1GLPR(theta,a,b,foc_near,foc_far);
   end;

   nopt:=(foc_far-foc_near)*lambda;
  end else begin
   camera_z_near:=-(CameraProjectionMatrix[2,3]/CameraProjectionMatrix[2,2]);
   nopt:=(camera_z_near+sqrt(camera_z_near*(camera_z_near+((LightSpaceExtents.Max.z-LightSpaceExtents.Min.z)*sin_theta))))/sin_theta;
  end;

  n:=FloatLerp(lispsm_n,nopt,lispsm_nopt_weight);

	projection_point:=Vector3Avg(LightSpaceExtents.Min,LightSpaceExtents.Max);
	projection_point.z:=LightSpaceExtents.min.z-n;

	new_light_space[0,0]:=LightSpace[0,0];
	new_light_space[0,1]:=LightSpace[0,1];
	new_light_space[0,2]:=LightSpace[0,2];
	new_light_space[0,3]:=0.0;
	new_light_space[1,0]:=LightSpace[1,0];
	new_light_space[1,1]:=LightSpace[1,1];
	new_light_space[1,2]:=LightSpace[1,2];
	new_light_space[1,3]:=0.0;
	new_light_space[2,0]:=LightSpace[2,0];
	new_light_space[2,1]:=LightSpace[2,1];
	new_light_space[2,2]:=LightSpace[2,2];
	new_light_space[2,3]:=0.0;
  PVector3(pointer(@new_light_space[3,3]))^:=Vector3TermMatrixMul(projection_point,LightSpace);
	new_light_space[3,3]:=1.0;

  Matrix4x4Inverse(l_view,new_light_space);

  First:=true;
  for Counter:=0 to CountFocusPoints-1 do begin
   TempVector:=Vector3TermMatrixMul(FocusPoints^[Counter],ShadowMapViewMatrix);
   if First then begin
    First:=false;
    receivers_new_ls_extents.MaxX:=abs(TempVector.x/TempVector.z);
    receivers_new_ls_extents.MaxY:=abs(TempVector.y/TempVector.z);
    receivers_new_ls_extents.MinZ:=TempVector.z;
    receivers_new_ls_extents.MaxZ:=TempVector.z;
   end else begin
    receivers_new_ls_extents.MaxX:=Max(receivers_new_ls_extents.MaxX,abs(TempVector.x/TempVector.z));
    receivers_new_ls_extents.MaxY:=Max(receivers_new_ls_extents.MaxY,abs(TempVector.y/TempVector.z));
    receivers_new_ls_extents.MinZ:=Min(receivers_new_ls_extents.MinZ,TempVector.z);
    receivers_new_ls_extents.MaxZ:=Max(receivers_new_ls_extents.MaxZ,TempVector.z);
   end;
  end;

  First:=true;
  for Counter:=0 to CountCasters-1 do begin
   for SubCounter:=0 to 7 do begin
    TempVector:=Vector3TermMatrixMul(Vector3(Casters^[Counter].MinMax[(SubCounter shr 0) and 1].x,Casters^[Counter].MinMax[(SubCounter shr 1) and 1].y,Casters^[Counter].MinMax[(SubCounter shr 2) and 1].z),ShadowMapViewMatrix);
    if First then begin
     First:=false;
     casters_new_ls_extents.MaxX:=abs(TempVector.x/TempVector.z);
     casters_new_ls_extents.MaxY:=abs(TempVector.y/TempVector.z);
     casters_new_ls_extents.MinZ:=TempVector.z;
     casters_new_ls_extents.MaxZ:=TempVector.z;
    end else begin
     casters_new_ls_extents.MaxX:=Max(casters_new_ls_extents.MaxX,abs(TempVector.x/TempVector.z));
     casters_new_ls_extents.MaxY:=Max(casters_new_ls_extents.MaxY,abs(TempVector.y/TempVector.z));
     casters_new_ls_extents.MinZ:=Min(casters_new_ls_extents.MinZ,TempVector.z);
     casters_new_ls_extents.MaxZ:=Max(casters_new_ls_extents.MaxZ,TempVector.z);
    end;
   end;
  end;

	max_x:=Max(receivers_new_ls_extents.MaxX,casters_new_ls_extents.MaxX);
	max_y:=Max(receivers_new_ls_extents.MaxY,casters_new_ls_extents.MaxY);
	max_z:=n+(LightSpaceExtents.Max.z-LightSpaceExtents.Min.z);

	l_projection:=Matrix4x4Perspective(ArcTan(max_y)*2.0,max_x/max_y,n,max_z);

  permute[0,0]:=1.0;
  permute[0,1]:=0.0;
  permute[0,2]:=0.0;
  permute[0,3]:=0.0;
  permute[1,0]:=0.0;
  permute[1,1]:=0.0;
  permute[1,2]:=2.0;
  permute[1,3]:=-1.0;
  permute[2,0]:=0.0;
  permute[2,1]:=-0.5;
  permute[2,2]:=0.0;
  permute[2,3]:=0.5;
  permute[3,0]:=0.0;
  permute[3,1]:=0.0;
  permute[3,2]:=0.0;
  permute[3,3]:=1.0;

  r:=Matrix4x4TermMul(Matrix4x4TermMul(l_view,l_projection),permute);

  First:=true;
  for Counter:=0 to CountFocusPoints-1 do begin
   TempVector:=Vector3TermMatrixMul(FocusPoints^[Counter],r);
   if First then begin
    First:=false;
    RecieverAABB.Min:=TempVector;
    RecieverAABB.Max:=TempVector;
   end else begin
    RecieverAABB.Min.x:=Min(RecieverAABB.Min.x,TempVector.x);
    RecieverAABB.Min.y:=Min(RecieverAABB.Min.y,TempVector.y);
    RecieverAABB.Min.z:=Min(RecieverAABB.Min.z,TempVector.z);
    RecieverAABB.Max.x:=Max(RecieverAABB.Max.x,TempVector.x);
    RecieverAABB.Max.y:=Max(RecieverAABB.Max.y,TempVector.y);
    RecieverAABB.Max.z:=Max(RecieverAABB.Max.z,TempVector.z);
   end;
  end;

  First:=true;
  for Counter:=0 to CountCasters-1 do begin
   for SubCounter:=0 to 7 do begin
    TempVector:=Vector3TermMatrixMul(Vector3(Casters^[Counter].MinMax[(SubCounter shr 0) and 1].x,Casters^[Counter].MinMax[(SubCounter shr 1) and 1].y,Casters^[Counter].MinMax[(SubCounter shr 2) and 1].z),r);
    if First then begin
     First:=false;
     CasterAABB.Min:=TempVector;
     CasterAABB.Max:=TempVector;
    end else begin
     CasterAABB.Min.x:=Min(CasterAABB.Min.x,TempVector.x);
     CasterAABB.Min.y:=Min(CasterAABB.Min.y,TempVector.y);
     CasterAABB.Min.z:=Min(CasterAABB.Min.z,TempVector.z);
     CasterAABB.Max.x:=Max(CasterAABB.Max.x,TempVector.x);
     CasterAABB.Max.y:=Max(CasterAABB.Max.y,TempVector.y);
     CasterAABB.Max.z:=Max(CasterAABB.Max.z,TempVector.z);
    end;
   end;
  end;

  AABB:=AABBGetIntersection(RecieverAABB,CasterAABB);
  MinZ:=Min(RecieverAABB.Min.z,CasterAABB.Min.z);
  MaxZ:=Max(RecieverAABB.Max.z,CasterAABB.Max.z);

  r:=Matrix4x4TermMul(r,Matrix4x4Ortho(AABB.Min.x,AABB.Max.x,AABB.Min.y,AABB.Max.y,-MaxZ,-MinZ));

  ShadowMapViewMatrix:=Matrix4x4Identity;
  ShadowMapProjectionMatrix:=r;

  ZBias:=(2.0*ZBiasCoef)/(MaxZ-MinZ);

  ShadowMapZNear:=-MaxZ;
  ShadowMapZFar:=-MinZ;

 end;
end;

procedure GetLiSPSMMatrix1(var ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;CameraZFar:single;const LightDirection:TVector3;const InvLight:TMatrix4x4;const SceneAABB:TAABB);
type TEdgePlanes=record
      Points:array[0..7] of TVector3;
      Edges:array[0..11,0..1] of TVector3;
      Planes:array[0..5] of TPlane;
     end;
     TViewPoints=record
      Points:array of TVector3;
      Count:longint;
     end;
 procedure GetEdgePlanesFromView(var o:TEdgePlanes;const View:TMatrix4x4);
 const Points:array[0..7] of TVector3=((x:-1;y:-1;z:-1),
                                           (x:-1;y:-1;z:1),
                                           (x:-1;y:1;z:-1),
                                           (x:-1;y:1;z:1),
                                           (x:1;y:-1;z:-1),
                                           (x:1;y:-1;z:1),
                                           (x:1;y:1;z:-1),
                                           (x:1;y:1;z:1));
 var InvView:TMatrix4x4;
 begin
  InvView:=Matrix4x4TermInverse(View);
  o.Points[0]:=Vector3TermMatrixMulHomogen(Points[0],InvView);
  o.Points[1]:=Vector3TermMatrixMulHomogen(Points[1],InvView);
  o.Points[2]:=Vector3TermMatrixMulHomogen(Points[2],InvView);
  o.Points[3]:=Vector3TermMatrixMulHomogen(Points[3],InvView);
  o.Points[4]:=Vector3TermMatrixMulHomogen(Points[4],InvView);
  o.Points[5]:=Vector3TermMatrixMulHomogen(Points[5],InvView);
  o.Points[6]:=Vector3TermMatrixMulHomogen(Points[6],InvView);
  o.Points[7]:=Vector3TermMatrixMulHomogen(Points[7],InvView);
  o.Planes[0]:=PlaneFromPoints(o.Points[0],o.Points[1],o.Points[2]);
  o.Planes[1]:=PlaneFromPoints(o.Points[4],o.Points[6],o.Points[5]);
  o.Planes[2]:=PlaneFromPoints(o.Points[5],o.Points[7],o.Points[1]);
  o.Planes[3]:=PlaneFromPoints(o.Points[0],o.Points[2],o.Points[4]);
  o.Planes[4]:=PlaneFromPoints(o.Points[2],o.Points[3],o.Points[6]);
  o.Planes[5]:=PlaneFromPoints(o.Points[0],o.Points[4],o.Points[1]);
  o.Edges[0,0]:=o.Points[0];
  o.Edges[0,1]:=o.Points[4];
  o.Edges[1,0]:=o.Points[4];
  o.Edges[1,1]:=o.Points[6];
  o.Edges[2,0]:=o.Points[6];
  o.Edges[2,1]:=o.Points[2];
  o.Edges[3,0]:=o.Points[2];
  o.Edges[3,1]:=o.Points[0];
  o.Edges[4,0]:=o.Points[1];
  o.Edges[4,1]:=o.Points[5];
  o.Edges[5,0]:=o.Points[5];
  o.Edges[5,1]:=o.Points[7];
  o.Edges[6,0]:=o.Points[7];
  o.Edges[6,1]:=o.Points[3];
  o.Edges[7,0]:=o.Points[3];
  o.Edges[7,1]:=o.Points[1];
  o.Edges[8,0]:=o.Points[0];
  o.Edges[8,1]:=o.Points[1];
  o.Edges[9,0]:=o.Points[3];
  o.Edges[9,1]:=o.Points[2];
  o.Edges[10,0]:=o.Points[7];
  o.Edges[10,1]:=o.Points[6];
  o.Edges[11,0]:=o.Points[5];
  o.Edges[11,1]:=o.Points[4];
 end;
 procedure GetEdgePlanesFromAABB(var o:TEdgePlanes;const AABB:TAABB);
 begin
  o.Planes[0]:=Plane(1,0,0,-AABB.Min.x);
  o.Planes[1]:=Plane(-1,0,0,AABB.Max.x);
  o.Planes[2]:=Plane(0,1,0,-AABB.Min.y);
  o.Planes[3]:=Plane(0,-1,0,AABB.Max.y);
  o.Planes[4]:=Plane(0,0,1,-AABB.Min.z);
  o.Planes[5]:=Plane(0,0,-1,AABB.Max.z);
  o.Points[0]:=Vector3(AABB.Min.x,AABB.Min.y,AABB.Min.z);
  o.Points[1]:=Vector3(AABB.Min.x,AABB.Min.y,AABB.Max.z);
  o.Points[2]:=Vector3(AABB.Min.x,AABB.Max.y,AABB.Min.z);
  o.Points[3]:=Vector3(AABB.Min.x,AABB.Max.y,AABB.Max.z);
  o.Points[4]:=Vector3(AABB.Max.x,AABB.Min.y,AABB.Min.z);
  o.Points[5]:=Vector3(AABB.Max.x,AABB.Min.y,AABB.Max.z);
  o.Points[6]:=Vector3(AABB.Max.x,AABB.Max.y,AABB.Min.z);
  o.Points[7]:=Vector3(AABB.Max.x,AABB.Max.y,AABB.Max.z);
  o.Edges[0,0]:=o.Points[0];
  o.Edges[0,1]:=o.Points[4];
  o.Edges[1,0]:=o.Points[4];
  o.Edges[1,1]:=o.Points[6];
  o.Edges[2,0]:=o.Points[6];
  o.Edges[2,1]:=o.Points[2];
  o.Edges[3,0]:=o.Points[2];
  o.Edges[3,1]:=o.Points[0];
  o.Edges[4,0]:=o.Points[1];
  o.Edges[4,1]:=o.Points[5];
  o.Edges[5,0]:=o.Points[5];
  o.Edges[5,1]:=o.Points[7];
  o.Edges[6,0]:=o.Points[7];
  o.Edges[6,1]:=o.Points[3];
  o.Edges[7,0]:=o.Points[3];
  o.Edges[7,1]:=o.Points[1];
  o.Edges[8,0]:=o.Points[0];
  o.Edges[8,1]:=o.Points[1];
  o.Edges[9,0]:=o.Points[3];
  o.Edges[9,1]:=o.Points[2];
  o.Edges[10,0]:=o.Points[7];
  o.Edges[10,1]:=o.Points[6];
  o.Edges[11,0]:=o.Points[5];
  o.Edges[11,1]:=o.Points[4];
 end;
 function PlaneEdgeIntersect(var o:TVector3;const e0,e1:TVector3;var Plane:TPlane):boolean;
 var d0,d1:single;
 begin
  d0:=PlaneVectorDistance(Plane,e0);
  d1:=PlaneVectorDistance(Plane,e1);
  if ((d0>0) and (d1>0)) or ((d0<0) and (d1<0)) then begin
   result:=false;
  end else begin
   o:=Vector3Add(e0,Vector3ScalarMul(Vector3Sub(e1,e0),(-d0)/(d1-d0)));
   result:=true;
  end;
 end;
 function PointInPlanes(const p:TVector3;const Planes:array of PPlane;CountPlanes:longint):boolean;
 var i:longint;
 begin
  for i:=0 to CountPlanes-1 do begin
   if PlaneVectorDistance(Planes[i]^,p)<(-0.001) then begin
    result:=false;
    exit;
   end;
  end;
  result:=true;
 end;
 procedure GetViewPoints(var o:TViewPoints;const View:TMatrix4x4);
 var ViewPlaneEdges:TEdgePlanes;
     ScenePlaneEdges:TEdgePlanes;
     Planes:array[0..15] of PPlane;
     Points:array of TVector3;
     i,j,CountPlanes,CountPoints:longint;
     v:TVector3;
 begin
  Points:=nil;
  try
   o.Points:=nil;
   o.Count:=0;
   GetEdgePlanesFromView(ViewPlaneEdges,View);
   GetEdgePlanesFromAABB(ScenePlaneEdges,SceneAABB);
   begin
    CountPlanes:=0;
    CountPoints:=0;
    for i:=low(ViewPlaneEdges.Planes) to high(ViewPlaneEdges.Planes) do begin
     for j:=low(ScenePlaneEdges.Edges) to high(ScenePlaneEdges.Edges) do begin
      if PlaneEdgeIntersect(v,ScenePlaneEdges.Edges[j,1],ScenePlaneEdges.Edges[j,0],ViewPlaneEdges.Planes[i]) then begin
       if CountPoints>=length(Points) then begin
        SetLength(Points,(CountPoints+1)*2);
       end;
       Points[CountPoints]:=v;
       inc(CountPoints);
      end;
     end;
     Planes[CountPlanes]:=@ViewPlaneEdges.Planes[i];
     inc(CountPlanes);
    end;
    for i:=low(ScenePlaneEdges.Planes) to high(ScenePlaneEdges.Planes) do begin
     for j:=low(ViewPlaneEdges.Edges) to high(ViewPlaneEdges.Edges) do begin
      if PlaneEdgeIntersect(v,ViewPlaneEdges.Edges[j,0],ViewPlaneEdges.Edges[j,1],ScenePlaneEdges.Planes[i]) then begin
       if CountPoints>=length(Points) then begin
        SetLength(Points,(CountPoints+1)*2);
       end;
       Points[CountPoints]:=v;
       inc(CountPoints);
      end;
     end;
     Planes[CountPlanes]:=@ScenePlaneEdges.Planes[i];
     inc(CountPlanes);
    end;
   end;
   begin
    for i:=0 to CountPoints-1 do begin
     if PointInPlanes(Points[i],Planes,CountPlanes) then begin
      if o.Count>=length(o.Points) then begin
       SetLength(o.Points,(o.Count+1)*2);
      end;
      o.Points[o.Count]:=Points[i];
      inc(o.Count);
     end;
    end;
    for i:=low(ViewPlaneEdges.Points) to high(ViewPlaneEdges.Points) do begin
     if PointInPlanes(ViewPlaneEdges.Points[i],Planes,CountPlanes) then begin
      if o.Count>=length(o.Points) then begin
       SetLength(o.Points,(o.Count+1)*2);
      end;
      o.Points[o.Count]:=ViewPlaneEdges.Points[i];
      inc(o.Count);
     end;
    end;
    for i:=low(ScenePlaneEdges.Points) to high(ScenePlaneEdges.Points) do begin
     if PointInPlanes(ScenePlaneEdges.Points[i],Planes,CountPlanes) then begin
      if o.Count>=length(o.Points) then begin
       SetLength(o.Points,o.Count*2);
      end;
      o.Points[o.Count]:=ScenePlaneEdges.Points[i];
      inc(o.Count);
     end;
    end;
   end;
   SetLength(o.Points,o.Count);
  finally
   SetLength(Points,0);
  end;
 end;
const DirNear=1;
var CameraInverseViewMatrix,CameraViewProjectionMatrix,LightViewMatrix,LightSpaceMatrix,LightProjectionMatrix:TMatrix4x4;
    AddVector,EyePos,NewDirection,Left,Up:TVector3;
    ViewPoints:TViewPoints;
    i:longint;
    DotProduct,SinGamma,Factor,z_n,d,z_f,n,f:single;
    AABB:TAABB;
    v,p:TVector3;
begin
 FillChar(ViewPoints,SizeOf(TViewPoints),AnsiChar(#0));
 try
  CameraInverseViewMatrix:=Matrix4x4TermInverse(CameraViewMatrix);
  CameraViewProjectionMatrix:=Matrix4x4TermMul(CameraViewMatrix,CameraProjectionMatrix);
  EyePos.x:=CameraInverseViewMatrix[3,0];
  EyePos.y:=CameraInverseViewMatrix[3,1];
  EyePos.z:=CameraInverseViewMatrix[3,2];
  GetViewPoints(ViewPoints,CameraViewProjectionMatrix);
  if ViewPoints.Count=0 then begin
   ViewPoints.Count:=8;
   SetLength(ViewPoints.Points,ViewPoints.Count);
   ViewPoints.Points[0]:=Vector3(0,0,0);
   ViewPoints.Points[1]:=Vector3(0,0,1);
   ViewPoints.Points[2]:=Vector3(0,1,0);
   ViewPoints.Points[3]:=Vector3(1,0,0);
   ViewPoints.Points[4]:=Vector3(1,0,1);
   ViewPoints.Points[5]:=Vector3(0,1,1);
   ViewPoints.Points[6]:=Vector3(1,1,1);
   ViewPoints.Points[7]:=Vector3(1,1,0);
  end else begin
   AddVector:=Vector3ScalarMul(LightDirection,CameraZFar);
   SetLength(ViewPoints.Points,ViewPoints.Count*2);
   for i:=0 to ViewPoints.Count-1 do begin
    ViewPoints.Points[ViewPoints.Count+i]:=Vector3Add(ViewPoints.Points[ViewPoints.Count],AddVector);
   end;
   inc(ViewPoints.Count,ViewPoints.Count);
  end;
  NewDirection:=Vector3Origin;
  for i:=0 to ViewPoints.Count-1 do begin
   NewDirection:=Vector3Add(NewDirection,ViewPoints.Points[i]);
  end;
  NewDirection:=Vector3Norm(NewDirection);
  Left:=Vector3Cross(LightDirection,NewDirection);
  Up:=Vector3Norm(Vector3Cross(Left,LightDirection));
  DotProduct:=Vector3Dot(NewDirection,LightDirection);
  SinGamma:=sqrt(1.0-sqr(DotProduct));
  LightViewMatrix:=Matrix4x4LookAtLight(EyePos,LightDirection,Up);
  for i:=0 to ViewPoints.Count-1 do begin
   v:=Vector3TermMatrixMulHomogen(ViewPoints.Points[i],LightViewMatrix);
   if i=0 then begin
    AABB.Min:=v;
    AABB.Max:=v;
   end else begin
    AABB.Min.x:=min(AABB.Min.x,v.x);
    AABB.Min.y:=min(AABB.Min.y,v.y);
    AABB.Min.z:=min(AABB.Min.z,v.z);
    AABB.Max.x:=max(AABB.Max.x,v.x);
    AABB.Max.y:=max(AABB.Max.y,v.y);
    AABB.Max.z:=max(AABB.Max.z,v.z);
   end;
  end;
  Factor:=1.0/SinGamma;
  z_n:=Factor*DirNear;
  d:=abs(AABB.Max.y-AABB.Min.y);
  z_f:=z_n+(d*SinGamma);
  n:=(z_n+sqrt(z_f*z_n))/SinGamma;
  f:=n+d;
  p:=Vector3Add(EyePos,Vector3ScalarMul(up,-(n-DirNear)));
  LightViewMatrix:=Matrix4x4LookAtLight(p,LightDirection,Up);
  LightSpaceMatrix:=Matrix4x4Identity;
  LightSpaceMatrix[1,1]:=(f+n)/(f-n);
  LightSpaceMatrix[1,3]:=(-(2*(f*n)))/(f-n);
  LightSpaceMatrix[3,1]:=1.0;
  LightSpaceMatrix[3,3]:=0.0;
  LightProjectionMatrix:=Matrix4x4TermMul(LightSpaceMatrix,LightViewMatrix);
  for i:=0 to ViewPoints.Count-1 do begin
   v:=Vector3TermMatrixMulHomogen(ViewPoints.Points[i],LightViewMatrix);
   if i=0 then begin
    AABB.Min:=v;
    AABB.Max:=v;
   end else begin
    AABB.Min.x:=min(AABB.Min.x,v.x);
    AABB.Min.y:=min(AABB.Min.y,v.y);
    AABB.Min.z:=min(AABB.Min.z,v.z);
    AABB.Max.x:=max(AABB.Max.x,v.x);
    AABB.Max.y:=max(AABB.Max.y,v.y);
    AABB.Max.z:=max(AABB.Max.z,v.z);
   end;
  end;
  LightProjectionMatrix[0,0]:=2.0/(AABB.Max.x-AABB.Min.x);
  LightProjectionMatrix[0,1]:=0.0;
  LightProjectionMatrix[0,2]:=0.0;
  LightProjectionMatrix[0,3]:=(-(AABB.Max.x+AABB.Min.x))/(AABB.Max.x-AABB.Min.x);
  LightProjectionMatrix[1,0]:=0.0;
  LightProjectionMatrix[1,1]:=2.0/(AABB.Max.y-AABB.Min.y);
  LightProjectionMatrix[1,2]:=0.0;
  LightProjectionMatrix[1,3]:=(-(AABB.Max.y+AABB.Min.y))/(AABB.Max.y-AABB.Min.y);
  LightProjectionMatrix[2,0]:=0.0;
  LightProjectionMatrix[2,1]:=0.0;
  LightProjectionMatrix[2,2]:=2.0/(AABB.Max.z-AABB.Min.z);
  LightProjectionMatrix[2,3]:=(-(AABB.Max.z+AABB.Min.z))/(AABB.Max.z-AABB.Min.z);
  LightProjectionMatrix[3,0]:=0.0;
  LightProjectionMatrix[3,1]:=0.0;
  LightProjectionMatrix[3,2]:=0.0;
  LightProjectionMatrix[3,3]:=1.0;
  LightProjectionMatrix:=Matrix4x4TermMul(LightProjectionMatrix,LightSpaceMatrix);
//  LightProjectionMatrix:=Matrix4x4Frustum(-1,1,-1,1,1,f);
  ShadowMapViewMatrix:=LightViewMatrix;
  ShadowMapViewMatrix:=Matrix4x4LookAtLight(p,LightDirection,Up);//LightViewMatrix;
  ShadowMapProjectionMatrix:=LightProjectionMatrix;
///  result:=Matrix4x4TermMul(LightProjectionMatrix,Matrix4x4TermMul(LightViewMatrix,Matrix4x4TermInverse(InvLight)));
 finally
  SetLength(ViewPoints.Points,0);
 end;
end;

procedure GetLiSPSMMatrix2(var ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;const LightDirection:TVector3;const SceneAABB:TAABB);
const NearDist=1;
type PVecPoint=^TVecPoint;
     TVecPoint=record
      Points:array of TVector3;
      Size:longint;
     end;
     PVecObject=^TVecObject;
     TVecObject=record
      Poly:array of TVecPoint;
      Size:longint;
     end;
     PVector3x8=^TVector3x8;
     TVector3x8=array[0..7] of TVector3;
     PVecPlanes=^TVecPlanes;
     TVecPlanes=record
      Planes:array of TPlane;
      Size:longint;
     end;
var LightDir,ViewDir:TVector3;
    OurAABB:TAABB;
    UseBodyVec:boolean;
    LightView,LightProjection:TMatrix4x4;
    EyePos,EyeDir:TVector3;
    InverseCameraViewProjectionMatrix,CameraInverseViewMatrix:TMatrix4x4;
 procedure CalcNewDir(var Dir:TVector3;const b:TVecPoint);
 var i:longint;
 begin
  Dir:=Vector3Origin;
  for i:=0 to b.Size-1 do begin
   Dir:=Vector3Add(Dir,Vector3Sub(b.Points[i],EyePos));
  end;
  Dir:=Vector3Norm(Dir);
 end;
 procedure Mult(var o:TMatrix4x4;const a,b:TMatrix4x4);
 var t:TMatrix4x4;
     c,r{,k}:longint;
 begin
  for c:=0 to 3 do begin
   for r:=0 to 3 do begin
    t[c,r]:=(a[0,r]*b[c,0])+(a[1,r]*b[c,1])+(a[2,r]*b[c,2])+(a[3,r]*b[c,3]);
   end;
  end;
  o:=t;
 end;
 procedure Look(var o:TMatrix4x4;const pos,dir,up:TVector3);
 var dirN,lftN,upN:TVector3;
 begin
  lftN:=Vector3Norm(Vector3Cross(dir,up));
  upN:=Vector3Norm(Vector3Cross(lftN,dir));
  dirN:=Vector3Norm(dir);
  o[0,0]:=lftN.x;
  o[0,1]:=upN.x;
  o[0,2]:=-dirN.x;
  o[0,3]:=0.0;
  o[1,0]:=lftN.y;
  o[1,1]:=upN.y;
  o[1,2]:=-dirN.y;
  o[1,3]:=0.0;
  o[2,0]:=lftN.z;
  o[2,1]:=upN.z;
  o[2,2]:=-dirN.z;
  o[2,3]:=0.0;
  o[3,0]:=-Vector3Dot(lftN,pos);
  o[3,1]:=-Vector3Dot(upN,pos);
  o[3,2]:=Vector3Dot(dirN,pos);
  o[3,3]:=1.0;
 end;
 procedure MulHomogenPoint(var o:TVector3;const m:TMatrix4x4;const v:TVector3);
 var x,y,z,w:single;
 begin
  x:=(m[0,0]*v.x)+(m[1,0]*v.y)+(m[2,0]*v.z)+m[3,0];
  y:=(m[0,1]*v.x)+(m[1,1]*v.y)+(m[2,1]*v.z)+m[3,1];
  z:=(m[0,2]*v.x)+(m[1,2]*v.y)+(m[2,2]*v.z)+m[3,2];
  w:=(m[0,3]*v.x)+(m[1,3]*v.y)+(m[2,3]*v.z)+m[3,3];
  o.x:=x/w;
  o.y:=y/w;
  o.z:=z/w;
 end;
 procedure TransformVecPoint(var b:TVecPoint;const m:TMatrix4x4);
 var i:longint;
 begin
  for i:=0 to b.Size-1 do begin
   MulHomogenPoint(b.Points[i],m,b.Points[i]);
  end;
 end;
 procedure CalcCubicHull(var AABB:TAABB;Points:PVector3s;Size:longint);
 var i:longint;
     v:PVector3;
 begin
  AABB.Min:=Vector3Origin;
  AABB.Max:=Vector3Origin;
  for i:=0 to Size-1 do begin
   v:=@Points^[i];
   if i=0 then begin
    AABB.Min:=v^;
    AABB.Max:=v^;
   end else begin
    AABB.Min.x:=min(AABB.Min.x,v^.x);
    AABB.Min.y:=min(AABB.Min.y,v^.y);
    AABB.Min.z:=min(AABB.Min.z,v^.z);
    AABB.Max.x:=max(AABB.Max.x,v^.x);
    AABB.Max.y:=max(AABB.Max.y,v^.y);
    AABB.Max.z:=max(AABB.Max.z,v^.z);
   end;
  end;
 end;
 procedure ScaleTranslateToFit(var o:TMatrix4x4;const AABB:TAABB);
 begin
  o[0,0]:=2.0/(AABB.Max.x-AABB.Min.x);
  o[1,0]:=0.0;
  o[2,0]:=0.0;
  o[3,0]:=-((AABB.Max.x+AABB.Min.x)/(AABB.Max.x-AABB.Min.x));
  o[0,1]:=0.0;
  o[1,1]:=2.0/(AABB.Max.y-AABB.Min.y);
  o[2,1]:=0.0;
  o[3,1]:=-((AABB.Max.y+AABB.Min.y)/(AABB.Max.y-AABB.Min.y));
  o[0,2]:=0.0;
  o[1,2]:=0.0;
  o[2,2]:=2.0/(AABB.Max.z-AABB.Min.z);
  o[3,2]:=-((AABB.Max.z+AABB.Min.z)/(AABB.Max.z-AABB.Min.z));
  o[0,3]:=0.0;
  o[1,3]:=0.0;
  o[2,3]:=0.0;
  o[3,3]:=1.0;
 end;
 procedure CalcUniformShadowMtx(var b:TVecPoint);
 var NewDir:TVector3;
 begin
  if UseBodyVec then begin
   CalcNewDir(NewDir,b);
   Look(LightView,EyePos,LightDir,NewDir);
  end else begin
   Look(LightView,EyePos,LightDir,ViewDir);
  end;
  TransformVecPoint(b,lightView);
  CalcCubicHull(OurAABB,@b.Points,b.Size);
  ScaleTranslateToFit(LightProjection,OurAABB);
 end;
 procedure CalcUpVec(var up:TVector3;const viewDirection,lightDirection:TVector3);
 begin
  up:=Vector3Norm(Vector3Cross(Vector3Cross(lightDirection,viewDirection),lightDirection));
 end;
 procedure CalcLiSPSMMtx(var b:TVecPoint);
 var lAABB:TAABB;
     NewDir,up,p:TVector3;
     lispMtx:TMatrix4x4;
     Bcopy:TVecPoint;
     dotProd,sinGamma,Factor,z_n,d,z_f,n,f:single;
 begin
  FillChar(Bcopy,SizeOf(TVecPoint),AnsiChar(#0));
  try
   dotProd:=Vector3Dot(viewDir,lightDir);
   sinGamma:=sqrt(1.0-sqr(dotProd));
   Bcopy.Points:=copy(b.Points);
   Bcopy.Size:=b.Size;
   if UseBodyVec then begin
    CalcNewDir(NewDir,b);
    CalcUpVec(up,NewDir,LightDir);
   end else begin
    CalcUpVec(up,ViewDir,LightDir);
   end;
   Look(LightView,EyePos,LightDir,up);
   TransformVecPoint(b,lightView);
   CalcCubicHull(lAABB,@b.Points,b.Size);
   begin
    Factor:=1.0/sinGamma;
    z_n:=Factor*NearDist;
    d:=abs(lAABB.Max.y-lAABB.Min.y);
    z_f:=z_n+(d*sinGamma);
    n:=(z_n+sqrt(z_f*z_n))/sinGamma;
    f:=n+d;
    p:=Vector3Sub(EyePos,Vector3ScalarMul(up,n-nearDist));
    Look(LightView,p,LightDir,up);
    lispMtx:=Matrix4x4Identity;
    lispMtx[1,1]:=(f+n)/(f-n);
    lispMtx[3,1]:=(-(2*f*n))/(f-n);
    lispMtx[1,3]:=1.0;
    lispMtx[3,3]:=0.0;
    Mult(LightProjection,lispMtx,LightView);
    TransformVecPoint(BCopy,lightProjection);
    CalcCubicHull(lAABB,@BCopy.Points,BCopy.Size);
   end;
   ScaleTranslateToFit(LightProjection,lAABB);
   Mult(LightProjection,LightProjection,lispMtx);
  finally
   SetLength(Bcopy.Points,0);
  end;
 end;
 procedure CalcAABBPoints(var p:TVector3x8;const b:TAABB);
 begin
  p[0]:=Vector3(b.Min.x,b.Min.y,b.Min.z);
  p[1]:=Vector3(b.Max.x,b.Min.y,b.Min.z);
  p[2]:=Vector3(b.Max.x,b.Max.y,b.Min.z);
  p[3]:=Vector3(b.Min.x,b.Max.y,b.Min.z);
  p[4]:=Vector3(b.Min.x,b.Min.y,b.Max.z);
  p[5]:=Vector3(b.Max.x,b.Min.y,b.Max.z);
  p[6]:=Vector3(b.Max.x,b.Max.y,b.Max.z);
  p[7]:=Vector3(b.Min.x,b.Max.y,b.Max.z);
 end;
 procedure CalcViewFrustumWorldCoord(var pts:TVector3x8;const invEyeProjView:TMatrix4x4);
 var Box:TAABB;
     i:longint;
 begin
  Box.Min:=Vector3(-1,-1,-1);
  Box.Max:=Vector3(1,1,1);
  CalcAABBPoints(pts,Box);
  for i:=0 to 7 do begin
   MulHomogenPoint(pts[i],invEyeProjView,pts[i]);
  end;
 end;
 procedure CalcViewFrustumObject(var obj:TVecObject;const p:TVector3x8);
 var i:longint;
 begin
  SetLength(Obj.Poly,6);
  Obj.Size:=6;
  for i:=0 to 5 do begin
   SetLength(Obj.Poly[i].Points,4);
   Obj.Poly[i].Size:=4;
  end;
  Obj.Poly[0].Points[0]:=p[0];
  Obj.Poly[0].Points[1]:=p[1];
  Obj.Poly[0].Points[2]:=p[2];
  Obj.Poly[0].Points[3]:=p[3];
  Obj.Poly[1].Points[0]:=p[7];
  Obj.Poly[1].Points[1]:=p[6];
  Obj.Poly[1].Points[2]:=p[5];
  Obj.Poly[1].Points[3]:=p[4];
  Obj.Poly[2].Points[0]:=p[0];
  Obj.Poly[2].Points[1]:=p[3];
  Obj.Poly[2].Points[2]:=p[7];
  Obj.Poly[2].Points[3]:=p[4];
  Obj.Poly[3].Points[0]:=p[1];
  Obj.Poly[3].Points[1]:=p[5];
  Obj.Poly[3].Points[2]:=p[6];
  Obj.Poly[3].Points[3]:=p[2];
  Obj.Poly[4].Points[0]:=p[4];
  Obj.Poly[4].Points[1]:=p[5];
  Obj.Poly[4].Points[2]:=p[1];
  Obj.Poly[4].Points[3]:=p[0];
  Obj.Poly[5].Points[0]:=p[6];
  Obj.Poly[5].Points[1]:=p[7];
  Obj.Poly[5].Points[2]:=p[3];
  Obj.Poly[5].Points[3]:=p[2];
 end;
 procedure CalcAABBPlanes(var Planes:TVecPlanes;const b:TAABB);
 begin
  SetLength(Planes.Planes,6);
  Planes.Size:=6;
  Planes.Planes[0]:=Plane(0,-1,0,-abs(b.Min.y));
  Planes.Planes[1]:=Plane(0,1,0,-abs(b.Max.y));
  Planes.Planes[2]:=Plane(-1,0,0,-abs(b.Min.y));
  Planes.Planes[3]:=Plane(1,0,0,-abs(b.Max.x));
  Planes.Planes[4]:=Plane(0,0,-1,-abs(b.Min.z));
  Planes.Planes[5]:=Plane(0,0,1,-abs(b.Max.z));
 end;
 procedure Append2VecPoint(var p:TVecPoint;const v:TVector3);
 var i:longint;
 begin
  i:=p.Size;
  inc(p.Size);
  if p.Size>=length(p.Points) then begin
   SetLength(p.Points,p.Size+p.Size);
  end;
  p.Points[i]:=v;
 end;
 function IntersectPlaneEdge(var o:TVector3;const a:TPlane;const va,vb:TVector3):boolean;
 var diff:TVector3;
     t:single;
 begin
  result:=false;
  diff:=Vector3Sub(vb,va);
  t:=Vector3Dot(a.Normal,diff);
  if t=0 then begin
   exit;
  end;
  t:=-((-a.Distance)-Vector3Dot(a.Normal,va))/t;
  if (t<0.0) or (1.0<t) then begin
   exit;
  end;
  o:=Vector3Add(va,Vector3ScalarMul(diff,t));
  result:=true;
 end;
 procedure ClipVecPointByPlane(const poly:TVecPoint;const a:TPlane;var polyOut,interPts:TVecPoint);
 var Outside:array of boolean;
     i,iNext:longint;
     inter:TVector3;
 begin
  Outside:=nil;
  try
   SetLength(Outside,poly.Size);
   for i:=0 to poly.Size-1 do begin
    Outside[i]:=PlaneVectorDistance(a,poly.Points[i])>0.0;
   end;
   for i:=0 to poly.Size-1 do begin
    iNext:=i+1;
    if iNext>=poly.Size then begin
     dec(iNext,poly.Size);
    end;
    if OutSide[i] and OutSide[iNext] then begin
     continue;
    end;
    if OutSide[i] then begin
     if IntersectPlaneEdge(inter,a,poly.points[i],poly.points[iNext]) then begin
      Append2VecPoint(polyOut,inter);
      Append2VecPoint(interPts,inter);
     end;
     Append2VecPoint(polyOut,poly.points[iNext]);
     continue;
    end;
    if OutSide[iNext] then begin
     if IntersectPlaneEdge(inter,a,poly.points[i],poly.points[iNext]) then begin
      Append2VecPoint(polyOut,inter);
      Append2VecPoint(interPts,inter);
     end;
     continue;
    end;
    Append2VecPoint(polyOut,poly.points[iNext]);
   end;
  finally
   SetLength(Outside,0);
  end;
 end;
 function FindSamePointInVecPoint(const Poly:TVecPoint;const p:TVector3):longint;
 var i:longint;
 begin
  result:=-1;
  for i:=0 to Poly.Size-1 do begin
   if Vector3Compare(Poly.Points[i],p) then begin
    result:=i;
    exit;
   end;
  end;
 end;
 function FindSamePointInObjectAndSwapWithList(var inter:TVecObject;const p:TVector3):longint;
 var i,nr:longint;
     poly:PVecPoint;
 begin
  result:=-1;
  if inter.Size<1 then begin
   exit;
  end;
  for i:=inter.Size downto 1 do begin
   poly:=@inter.Poly[i-1];
   if poly^.Size=2 then begin
    nr:=FindSamePointInVecPoint(poly^,p);
    if nr>=0 then begin
     result:=nr;
     exit;
    end;
   end;
  end;
 end;
 procedure AppendIntersectionVecPoint(var obj,inter:TVecObject);
 var polyOut,polyIn:PVecPoint;
     size,i,nr:longint;
     lastPt:PVector3;
 begin
  size:=obj.Size;
  if inter.Size<3 then begin
   exit;
  end;
  i:=Inter.Size;
  while i>0 do begin
   if inter.Poly[i-1].Size=2 then begin
    break;
   end;
   dec(i);
  end;
  inter.Size:=i;
  SetLength(inter.Poly,inter.Size);
  if inter.Size<3 then begin
   exit;
  end;
  obj.Size:=size+1;
  SetLength(obj.Poly,obj.Size);
  polyOut:=@obj.poly[size];
  polyIn:=@inter.poly[inter.Size-1];
  Append2VecPoint(polyOut^,polyIn^.points[0]);
  Append2VecPoint(polyOut^,polyIn^.points[1]);
  dec(inter.Size);
  while inter.Size>0 do begin
   lastPt:=@polyOut^.points[polyOut.Size-1];
   nr:=FindSamePointInObjectAndSwapWithList(inter,lastPt^);
   if nr>=0 then begin
    polyIn:=@inter.poly[inter.Size-1];
    Append2VecPoint(polyOut^,polyIn^.points[(nr+1) and 1]);
   end;
   dec(inter.Size);
  end;
  SetLength(inter.Poly,inter.Size);
  dec(polyOut^.Size);
  SetLength(polyOut^.Points,polyOut^.Size);
 end;
 procedure ClipObjectByPlane(const obj:TVecObject;const a:TPlane;var objOut:TVecObject);
 var inter,objIn:TVecObject;
     i,Size:longint;
 begin
  FillChar(inter,SizeOf(TVecObject),AnsiChar(#0));
  FillChar(objIn,SizeOf(TVecObject),AnsiChar(#0));
  try
   objIn.Poly:=copy(obj.Poly);
   objIn.Size:=obj.Size;
   SetLength(objOut.Poly,0);
   objOut.Size:=0;
   for i:=0 to objIn.Size-1 do begin
    Size:=objOut.Size;
    inc(ObjOut.Size);
    SetLength(ObjOut.Poly,ObjOut.Size);
    inc(inter.Size);
    SetLength(inter.Poly,inter.Size);
    ClipVecPointByPlane(objIn.poly[i],a,objOut.poly[size],inter.poly[size]);
    if objOut.poly[size].Size=0 then begin
     ObjOut.Size:=0;
     SetLength(ObjOut.Poly,ObjOut.Size);
     inter.Size:=0;
     SetLength(inter.Poly,inter.Size);
    end;
   end;
   AppendIntersectionVecPoint(objOut,inter);
  finally
   SetLength(inter.Poly,0);
   SetLength(ObjIn.Poly,0);
  end;
 end;
 procedure ClipObjectByAABB(var obj:TVecObject;const Box:TAABB);
 var Planes:TVecPlanes;
     i:longint;
 begin
  FillChar(Planes,SizeOf(TVecPlanes),AnsiChar(#0));
  try
   CalcAABBPlanes(Planes,Box);
   for i:=0 to Planes.Size-1 do begin
    ClipObjectByPlane(Obj,Planes.Planes[i],Obj);
   end;
  finally
   SetLength(Planes.Planes,0);
  end;
 end;
 function ClipTest(const p,q:single;var u1,u2:single):boolean;
 var r:single;
 begin
  if p<0.0 then begin
   r:=q/p;
   if r>u2 then begin
    result:=false;
   end else begin
    if r>u1 then begin
     u1:=r;
    end;
    result:=true;
   end;
  end else begin
   if p>0.0 then begin
    r:=q/p;
    if r<u1 then begin
     result:=false;
    end else begin
     if r<u2 then begin
      u2:=r;
     end;
     result:=true;
    end;
   end else begin
    result:=q>=0.0;
   end;
  end;
 end;
 function IntersectionLineAABox(var v:TVector3;const p,dir:TVector3;const b:TAABB):boolean;
 var t1,t2:single;
 begin
  t1:=0.0;
  t2:=1e+18;
  result:=ClipTest(-dir.z,p.z-b.min.z,t1,t2) and ClipTest(dir.z,b.max.z-p.z,t1,t2) and ClipTest(-dir.y,p.y-b.min.y,t1,t2) and ClipTest(dir.y,b.max.y-p.y,t1,t2) and ClipTest(-dir.x,p.x-b.min.x,t1,t2) and ClipTest(dir.x,b.max.x-p.x,t1,t2);
  if result then begin
   result:=false;
   if t1>=0 then begin
    v:=Vector3Add(p,Vector3ScalarMul(dir,t1));
    result:=true;
   end;
   if t2>=0 then begin
    v:=Vector3Add(p,Vector3ScalarMul(dir,t2));
    result:=true;
   end;
  end;
 end;
 procedure IncludeObjectLightVolume(var points:TVecPoint;const obj:TVecObject;const lightDir:TVector3;const SceneAABB:TAABB);
 var i,j,size:longint;
     ld,pt:TVector3;
     p:PVecPoint;
 begin
  ld:=Vector3Neg(lightDir);
  points.Size:=0;
  for i:=0 to obj.Size-1 do begin
   p:=@obj.Poly[i];
   for j:=0 to p^.Size-1 do begin
    Append2VecPoint(Points,p^.Points[j]);
   end;
  end;
  Size:=points.Size;
  for i:=0 to size-1 do begin
   if IntersectionLineAABox(pt,points.Points[i],ld,SceneAABB) then begin
    Append2VecPoint(Points,pt);
   end;
  end;
 end;
 procedure CalcFocusedLightVolumePoints(var points:TVecPoint;const InvEyeProjView:TMatrix4x4;const LightDir:TVector3;const SceneAABB:TAABB);
 var obj:TVecObject;
     pts:TVector3x8;
 begin
  FillChar(obj,SizeOf(TVecObject),AnsiChar(#0));
  try
   CalcViewFrustumWorldCoord(pts,invEyeProjView);
	 CalcViewFrustumObject(obj,pts);
	 ClipObjectByAABB(obj,SceneAABB);
	 IncludeObjectLightVolume(points,obj,lightDir,sceneAABB);
  finally
   SetLength(obj.Poly,0);
  end;
 end;
var b:TVecPoint;
begin
 FillChar(b,SizeOf(TVecPoint),AnsiChar(#0));
 try
  UseBodyVec:=true;
  InverseCameraViewProjectionMatrix:=Matrix4x4TermInverse(Matrix4x4TermMul(CameraViewMatrix,CameraProjectionMatrix));
  CameraInverseViewMatrix:=Matrix4x4TermInverse(CameraViewMatrix);
  EyePos.x:=CameraInverseViewMatrix[3,0];
  EyePos.y:=CameraInverseViewMatrix[3,1];
  EyePos.z:=CameraInverseViewMatrix[3,2];
  EyeDir.x:=-CameraViewMatrix[2,0];
  EyeDir.y:=-CameraViewMatrix[2,1];
  EyeDir.z:=-CameraViewMatrix[2,2];
  Vector3Normalize(EyeDir);
  ViewDir:=EyeDir;
  LightDir:=LightDirection;
  CalcFocusedLightVolumePoints(b,InverseCameraViewProjectionMatrix,LightDirection,SceneAABB);
  CalcUniformShadowMtx(b);
  //CalcLiSPSMMtx(b);
  Mult(LightView,Matrix4x4RightToLeftHanded,LightView);
  Mult(LightProjection,Matrix4x4RightToLeftHanded,LightProjection);
  ShadowMapViewMatrix:=LightView;
  ShadowMapProjectionMatrix:=LightProjection;
 finally
  SetLength(b.Points,0);
 end;
end;

procedure GetLiSPSMMatrix3(var ShadowMapViewMatrix,ShadowMapProjectionMatrix:TMatrix4x4;const CameraViewMatrix,CameraProjectionMatrix:TMatrix4x4;const LightDirection:TVector3;const SceneAABB,ViewAABB:TAABB);
var CameraInverseViewMatrix,LightView,LightProjection{,LightSpaceMatrix}:TMatrix4x4;
    AABB:TAABB;
    Transformed,cEye,vEye,LightX,LightY,LightZ,cEye_ls,cP:TVector3;
    i:longint;
    zN,zF,deltaZ,sinGamma,nOpt{,deltaZ2}:single;
begin
 CameraInverseViewMatrix:=Matrix4x4TermInverse(CameraViewMatrix);

 cEye.x:=CameraInverseViewMatrix[3,0];
 cEye.y:=CameraInverseViewMatrix[3,1];
 cEye.z:=CameraInverseViewMatrix[3,2];

 vEye.x:=-CameraViewMatrix[2,0];
 vEye.y:=-CameraViewMatrix[2,1];
 vEye.z:=-CameraViewMatrix[2,2];
 Vector3Normalize(vEye);

 LightZ:=Vector3Norm(LightDirection);
 LightX:=Vector3Norm(Vector3Cross(vEye,LightZ));
 LightY:=Vector3Norm(Vector3Cross(LightZ,lightX));

 LightView[0,0]:=LightX.x;
 LightView[0,1]:=LightY.x;
 LightView[0,2]:=LightZ.x;
 LightView[0,3]:=0.0;
 LightView[1,0]:=LightX.y;
 LightView[1,1]:=LightY.y;
 LightView[1,2]:=LightZ.y;
 LightView[1,3]:=0;
 LightView[2,0]:=LightX.z;
 LightView[2,1]:=LightY.z;
 LightView[2,2]:=LightZ.z;
 LightView[2,3]:=0.0;
 LightView[3,0]:=0.0;
 LightView[3,1]:=0.0;
 LightView[3,2]:=0.0;
 LightView[3,3]:=1.0;

 AABB.Min:=Vector3Origin;
 AABB.Max:=Vector3Origin;
 for i:=0 to 7 do begin
  Transformed:=Vector3TermMatrixMul(Vector3(ViewAABB.MinMax[i and 1].x,ViewAABB.MinMax[(i shr 1) and 1].y,ViewAABB.MinMax[(i shr 2) and 1].z),CameraViewMatrix);
  if i=0 then begin
   AABB.Min:=Transformed;
   AABB.Max:=Transformed;
  end else begin
   AABB.Min.x:=min(AABB.Min.x,Transformed.x);
   AABB.Min.y:=min(AABB.Min.y,Transformed.y);
   AABB.Min.z:=min(AABB.Min.z,Transformed.z);
   AABB.Max.x:=max(AABB.Max.x,Transformed.x);
   AABB.Max.y:=max(AABB.Max.y,Transformed.y);
   AABB.Max.z:=max(AABB.Max.z,Transformed.z);
  end;
 end;

 zN:=AABB.Min.z;
 zF:=AABB.Max.z;
 deltaZ:=zF-zN;
 sinGamma:=sin(abs(arccos(Vector3Dot(LightZ,vEye))));
 nOpt:=(zN+sqrt(zN*(zN+(deltaZ*sinGamma))))/sinGamma;

 AABB.Min:=Vector3Origin;
 AABB.Max:=Vector3Origin;
 for i:=0 to 7 do begin
  Transformed:=Vector3TermMatrixMul(Vector3(ViewAABB.MinMax[i and 1].x,ViewAABB.MinMax[(i shr 1) and 1].y,ViewAABB.MinMax[(i shr 2) and 1].z),LightView);
  if i=0 then begin
   AABB.Min:=Transformed;
   AABB.Max:=Transformed;
  end else begin
   AABB.Min.x:=min(AABB.Min.x,Transformed.x);
   AABB.Min.y:=min(AABB.Min.y,Transformed.y);
   AABB.Min.z:=min(AABB.Min.z,Transformed.z);
   AABB.Max.x:=max(AABB.Max.x,Transformed.x);
   AABB.Max.y:=max(AABB.Max.y,Transformed.y);
   AABB.Max.z:=max(AABB.Max.z,Transformed.z);
  end;
 end;

 for i:=0 to 7 do begin
  Transformed:=Vector3TermMatrixMul(Vector3(SceneAABB.MinMax[i and 1].x,SceneAABB.MinMax[(i shr 1) and 1].y,SceneAABB.MinMax[(i shr 2) and 1].z),LightView);
  AABB.Min.z:=Min(AABB.Min.z,Transformed.z);
  AABB.Max.z:=Max(AABB.Max.z,Transformed.z);
 end;

 if (sinGamma<0.1) or (IsNaN(nOpt) or IsInfinite(nOpt)) then begin
  LightProjection:=Matrix4x4Ortho(AABB.Min.x,AABB.Max.x,AABB.Max.y,AABB.Min.y,AABB.Min.z,AABB.Max.z);
  ShadowMapViewMatrix:=LightView;
  ShadowMapProjectionMatrix:=LightProjection;
 end else begin
  cEye_ls:=Vector3TermMatrixMul(cEye,LightView);
  cEye_ls.z:=AABB.min.z;
  cEye_ls:=Vector3TermMatrixMul(cEye,Matrix4x4TermInverse(LightView));
  cP:=Vector3Sub(cEye_ls,Vector3ScalarMul(LightZ,nOpt{-zN}));

//  LightView:=Matrix4x4TermMul(Matrix4x4Translate(Vector3Neg(cP)),LightView);

  AABB.Min:=Vector3Origin;
  AABB.Max:=Vector3Origin;
  for i:=0 to 7 do begin
   Transformed:=Vector3TermMatrixMul(Vector3(ViewAABB.MinMax[i and 1].x,ViewAABB.MinMax[(i shr 1) and 1].y,ViewAABB.MinMax[(i shr 2) and 1].z),LightView);
   Transformed:=Vector3(Transformed.x/Transformed.y,Transformed.y,Transformed.z/Transformed.y);
   if i=0 then begin
    AABB.Min:=Transformed;
    AABB.Max:=Transformed;
   end else begin
    AABB.Min.x:=min(AABB.Min.x,Transformed.x);
    AABB.Min.y:=min(AABB.Min.y,Transformed.y);
    AABB.Min.z:=min(AABB.Min.z,Transformed.z);
    AABB.Max.x:=max(AABB.Max.x,Transformed.x);
    AABB.Max.y:=max(AABB.Max.y,Transformed.y);
    AABB.Max.z:=max(AABB.Max.z,Transformed.z);
   end;
  end;

  for i:=0 to 7 do begin
   Transformed:=Vector3TermMatrixMul(Vector3(SceneAABB.MinMax[i and 1].x,SceneAABB.MinMax[(i shr 1) and 1].y,SceneAABB.MinMax[(i shr 2) and 1].z),LightView);
   Transformed:=Vector3(Transformed.x/Transformed.y,Transformed.y,Transformed.z/Transformed.y);
   AABB.Min.z:=Min(AABB.Min.z,Transformed.z);
   AABB.Max.z:=Max(AABB.Max.z,Transformed.z);
  end;

//  deltaZ2:=AABB.Max.z-AABB.Min.z;

  LightProjection:=Matrix4x4Ortho(AABB.Min.y,AABB.Max.y,AABB.Min.x*AABB.Min.y,AABB.Max.x*AABB.Min.y,AABB.Min.z*AABB.Min.z,AABB.Max.z*AABB.Min.y);
//LightProjection:=Matrix4x4Ortho(AABB.Min.x*AABB.Min.y,AABB.Max.x*AABB.Min.y,AABB.Min.y,AABB.Max.y,AABB.Min.z*AABB.Min.z,AABB.Max.z*AABB.Min.y);
//LightProjection:=Matrix4x4Ortho(AABB.Min.x*AABB.Min.y,AABB.Max.x*AABB.Min.y,AABB.Min.z*AABB.Min.z,AABB.Max.z*AABB.Min.y,AABB.Min.y,AABB.Max.y);

  LightProjection:=Matrix4x4TermMul(LightProjection,Matrix4x4InverseFlipYZ);
  LightProjection:=Matrix4x4TermMul(Matrix4x4FlipYZ,LightProjection);{}

  ShadowMapViewMatrix:=LightView;
  ShadowMapProjectionMatrix:=LightProjection;


   (*   {



        float deltaZ2 = AABB.max.y - AABB.min.y;

        // With this information, we can now set up the projection frustum.
        Frustumf frustum(	AABB.min.y,
                          AABB.max.y,
                          AABB.min.x * AABB.min.y,
                          AABB.max.x * AABB.min.y,
                          AABB.min.z * AABB.min.y,
                          AABB.max.z * AABB.min.y);

        // if (AABB.min.y <= 0 && AABB.max.y > 0)
        //   cout << "Problem" << endl;

        // Now, that we have the frustum, we can set the projection matrix.
        // We have to switch the Y and Z axis for this.
        static M44f switchYZ( 1, 0, 0, 0,
                              0, 0, 1, 0,
                              0,-1, 0, 0,
                              0, 0, 0, 1);

        static M44f switchYZinverse( 1, 0, 0, 0,
                                     0, 0,-1, 0,
                                     0, 1, 0, 0,
                                     0, 0, 0, 1);

        lightProjection = switchYZinverse;
        lightProjection	*= frustum.projectionMatrix();
        lightProjection *= switchYZ;

        throwBadMatrix(lightView);
        camera.setView(lightView);
        throwBadMatrix(lightProjection);
        camera.setProjection(lightProjection);*)
 end;
end;

function MaxOverlaps(const Min1,Max1,Min2,Max2:single;var LowerLim,UpperLim:single):boolean;
begin
 if (Max1<Min2) or (Max2<Min1) then begin
  result:=false;
 end else begin
  if (Min2<=Min1) and (Min1<=Max2) then begin
   if (Min1<=Max2) and (Max2<=Max1) then begin
    LowerLim:=Min1;
    UpperLim:=Max1;
   end else if (Max1-Min2)<(Max2-Min1) then begin
    LowerLim:=Min2;
    UpperLim:=Max1;
   end else begin
    LowerLim:=Min1;
    UpperLim:=Max2;
   end;
  end else begin
   if (Min1<=Max2) and (Max2<=Max1) then begin
    LowerLim:=Min2;
    UpperLim:=Max1;
   end else if (Max2-Min1)<(Max1-Min2) then begin
    LowerLim:=Min1;
    UpperLim:=Max2;
   end else begin
    LowerLim:=Min2;
    UpperLim:=Max1;
   end;
  end;
  result:=true;
 end;
end;

function ConvertRGB32FToRGB9E5(r,g,b:single):longword;
const RGB9E5_EXPONENT_BITS=5;
      RGB9E5_MANTISSA_BITS=9;
      RGB9E5_EXP_BIAS=15;
      RGB9E5_MAX_VALID_BIASED_EXP=31;
      MAX_RGB9E5_EXP=RGB9E5_MAX_VALID_BIASED_EXP-RGB9E5_EXP_BIAS;
      RGB9E5_MANTISSA_VALUES=1 shl RGB9E5_MANTISSA_BITS;
      MAX_RGB9E5_MANTISSA=RGB9E5_MANTISSA_VALUES-1;
      MAX_RGB9E5=((MAX_RGB9E5_MANTISSA+0.0)/RGB9E5_MANTISSA_VALUES)*(1 shl MAX_RGB9E5_EXP);
      EPSILON_RGB9E5=(1.0/RGB9E5_MANTISSA_VALUES)/(1 shl RGB9E5_EXP_BIAS);
var Exponent,MaxMantissa,ri,gi,bi:longint;
    MaxComponent,Denominator:single;
    CastedMaxComponent:longword absolute MaxComponent;
begin
 if r>0.0 then begin
  if r>MAX_RGB9E5 then begin
   r:=MAX_RGB9E5;
  end;
 end else begin
  r:=0.0;
 end;
 if g>0.0 then begin
  if g>MAX_RGB9E5 then begin
   g:=MAX_RGB9E5;
  end;
 end else begin
  g:=0.0;
 end;
 if b>0.0 then begin
  if b>MAX_RGB9E5 then begin
   b:=MAX_RGB9E5;
  end;
 end else begin
  b:=0.0;
 end;
 if r<g then begin
  if g<b then begin
   MaxComponent:=b;
  end else begin
   MaxComponent:=g;
  end;
 end else begin
  if r<b then begin
   MaxComponent:=b;
  end else begin
   MaxComponent:=r;
  end;
 end;
 Exponent:=(longint(CastedMaxComponent and $7f800000) shr 23)-127;
 if Exponent<((-RGB9E5_EXP_BIAS)-1) then begin
  Exponent:=((-RGB9E5_EXP_BIAS)-1);
 end;
 inc(Exponent,RGB9E5_EXP_BIAS+1);
 if Exponent<0 then begin
  Exponent:=0;
 end else if Exponent>RGB9E5_MAX_VALID_BIASED_EXP then begin
  Exponent:=RGB9E5_MAX_VALID_BIASED_EXP;
 end;
 Denominator:=power(2.0,Exponent-(RGB9E5_EXP_BIAS+RGB9E5_MANTISSA_BITS));
 MaxMantissa:=trunc(floor((MaxComponent/Denominator)+0.5));
 if MaxMantissa=(MAX_RGB9E5_MANTISSA+1) then begin
  Denominator:=Denominator*2.0;
  inc(Exponent);
  Assert(Exponent<=RGB9E5_MAX_VALID_BIASED_EXP);
 end else begin
  Assert(Exponent<=MAX_RGB9E5_MANTISSA);
 end;
 ri:=trunc(floor((r/Denominator))+0.5);
 gi:=trunc(floor((g/Denominator))+0.5);
 bi:=trunc(floor((b/Denominator))+0.5);
 if ri<0 then begin
  ri:=0;
 end else if ri>MAX_RGB9E5_MANTISSA then begin
  ri:=MAX_RGB9E5_MANTISSA;
 end;
 if gi<0 then begin
  gi:=0;
 end else if gi>MAX_RGB9E5_MANTISSA then begin
  gi:=MAX_RGB9E5_MANTISSA;
 end;
 if bi<0 then begin
  bi:=0;
 end else if bi>MAX_RGB9E5_MANTISSA then begin
  bi:=MAX_RGB9E5_MANTISSA;
 end;
 result:=longword(ri) or (longword(gi) shl 9) or (longword(bi) shl 18) or (longword(Exponent and 31) shl 27);
end;

function PackFP32FloatToM6E5Float(const Value:single):longword;
const Float32MantissaBits=23;
      Float32ExponentBits=8;
      Float32Bits=32;
      Float32ExponentBias=127;
      Float6E5MantissaBits=6;
      Float6E5MantissaMask=(1 shl Float6E5MantissaBits)-1;
      Float6E5ExponentBits=5;
      Float6E5Bits=11;
      Float6E5ExponentBias=15;
var CastedValue:longword absolute Value;
    Exponent,Mantissa:longword;
begin

 // Extract the exponent and the mantissa from the 32-bit floating point value
 Exponent:=(CastedValue and $7f800000) shr Float32MantissaBits;
 Mantissa:=(CastedValue shr (Float32MantissaBits-Float6E5MantissaBits)) and Float6E5MantissaMask;

 // Round mantissa
 if (CastedValue and (1 shl ((Float32MantissaBits-Float6E5MantissaBits)-1)))<>0 then begin
  inc(Mantissa);
  if (Mantissa and (1 shl Float6E5MantissaBits))<>0 then begin
   Mantissa:=0;
   inc(Exponent);
  end;
 end;

 if Exponent<=(Float32ExponentBias-Float6E5ExponentBias) then begin
  // Denormal
  if Exponent<((Float32ExponentBias-Float6E5ExponentBias)-Float6E5MantissaBits) then begin
   result:=0;
  end else begin
   result:=(Mantissa or (1 shl Float6E5MantissaBits)) shr (((Float32ExponentBias-Float6E5ExponentBias)+1)-Exponent);
  end;
 end else if Exponent>(Float32ExponentBias+Float6E5ExponentBias) then begin
  // |x| > 2^15, overflow, an existing INF, or NaN
  if Exponent=((1 shl Float32ExponentBits)-1) then begin
   if Mantissa<>0 then begin
    // Return allows -NaN to return as NaN even if there is no sign bit.
    result:=((1 shl (Float6E5ExponentBits+Float6E5MantissaBits))-1) or ((CastedValue shr (Float32Bits-Float6E5Bits)) and (1 shl (Float32MantissaBits+Float32ExponentBits)));
    exit;
   end else begin
    result:=((1 shl Float6E5ExponentBits)-1) shl Float6E5MantissaBits;
   end;
  end else begin
   result:=((((1 shl Float6E5ExponentBits)-1) shl Float6E5MantissaBits)-(1 shl Float6E5MantissaBits)) or Float6E5MantissaMask;
  end;
 end else begin
  result:=((Exponent-(Float32ExponentBias-Float6E5ExponentBias)) shl Float6E5MantissaBits) or Mantissa;
 end;

 if (CastedValue and (1 shl (Float32MantissaBits+Float32ExponentBits)))<>0 then begin
  // Clamp negative value
  result:=0;
 end;
end;

function PackFP32FloatToM5E5Float(const Value:single):longword;
const Float32MantissaBits=23;
      Float32ExponentBits=8;
      Float32Bits=32;
      Float32ExponentBias=127;
      Float5E5MantissaBits=5;
      Float5E5MantissaMask=(1 shl Float5E5MantissaBits)-1;
      Float5E5ExponentBits=5;
      Float5E5Bits=10;
      Float5E5ExponentBias=15;
var CastedValue:longword absolute Value;
    Exponent,Mantissa:longword;
begin

 // Extract the exponent and the mantissa from the 32-bit floating point value
 Exponent:=(CastedValue and $7f800000) shr Float32MantissaBits;
 Mantissa:=(CastedValue shr (Float32MantissaBits-Float5E5MantissaBits)) and Float5E5MantissaMask;

 // Round mantissa
 if (CastedValue and (1 shl ((Float32MantissaBits-Float5E5MantissaBits)-1)))<>0 then begin
  inc(Mantissa);
  if (Mantissa and (1 shl Float5E5MantissaBits))<>0 then begin
   Mantissa:=0;
   inc(Exponent);
  end;
 end;

 if Exponent<=(Float32ExponentBias-Float5E5ExponentBias) then begin
  // Denormal
  if Exponent<((Float32ExponentBias-Float5E5ExponentBias)-Float5E5MantissaBits) then begin
   result:=0;
  end else begin
   result:=(Mantissa or (1 shl Float5E5MantissaBits)) shr (((Float32ExponentBias-Float5E5ExponentBias)+1)-Exponent);
  end;
 end else if Exponent>(Float32ExponentBias+Float5E5ExponentBias) then begin
  // |x| > 2^15, overflow, an existing INF, or NaN
  if Exponent=((1 shl Float32ExponentBits)-1) then begin
   if Mantissa<>0 then begin
    // Return allows -NaN to return as NaN even if there is no sign bit.
    result:=((1 shl (Float5E5ExponentBits+Float5E5MantissaBits))-1) or ((CastedValue shr (Float32Bits-Float5E5Bits)) and (1 shl (Float32MantissaBits+Float32ExponentBits)));
    exit;
   end else begin
    result:=((1 shl Float5E5ExponentBits)-1) shl Float5E5MantissaBits;
   end;
  end else begin
   result:=((((1 shl Float5E5ExponentBits)-1) shl Float5E5MantissaBits)-(1 shl Float5E5MantissaBits)) or Float5E5MantissaMask;
  end;
 end else begin
  result:=((Exponent-(Float32ExponentBias-Float5E5ExponentBias)) shl Float5E5MantissaBits) or Mantissa;
 end;

 if (CastedValue and (1 shl (Float32MantissaBits+Float32ExponentBits)))<>0 then begin
  // Clamp negative value
  result:=0;
 end;
end;

function Float32ToFloat11(const Value:single):longword;
const EXPONENT_BIAS=15;
      EXPONENT_BITS=$1f;
      EXPONENT_SHIFT=6;
      MANTISSA_BITS=$3f;
      MANTISSA_SHIFT=23-EXPONENT_SHIFT;
      MAX_EXPONENT=EXPONENT_BITS shl EXPONENT_SHIFT;
var CastedValue:longword absolute Value;
    Sign:longword;
    Exponent,Mantissa:longint;
begin
 Sign:=CastedValue shr 31;
 Exponent:=longint(longword((CastedValue and $7f800000) shr 23))-127;
 Mantissa:=CastedValue and $007fffff;
 if Exponent=128 then begin
  // Infinity or NaN
  (* From the GL_EXT_packed_float spec:
   *     "Additionally: negative infinity is converted to zero; positive
   *      infinity is converted to positive infinity; and both positive and
   *      negative NaN are converted to positive NaN."
   *)
  if Mantissa<>0 then begin
   result:=MAX_EXPONENT or 1; // NaN
  end else begin
   if Sign<>0 then begin
    result:=0; // 0.0
   end else begin
    result:=MAX_EXPONENT; // Infinity
   end;
  end;
 end else if Sign<>0 then begin
  result:=0;
 end else if Value>65024.0 then begin
  (* From the GL_EXT_packed_float spec:
   *     "Likewise, finite positive values greater than 65024 (the maximum
   *      finite representable unsigned 11-bit floating-point value) are
   *      converted to 65024."
   *)
  result:=(30 shl EXPONENT_SHIFT) or 63;
 end else if Exponent>-15 then begin
  result:=((Exponent+EXPONENT_BIAS) shl EXPONENT_SHIFT) or (Mantissa shr MANTISSA_SHIFT);
 end else begin
  result:=0;
 end;
end;

function Float32ToFloat10(const Value:single):longword;
const EXPONENT_BIAS=15;
      EXPONENT_BITS=$1f;
      EXPONENT_SHIFT=5;
      MANTISSA_BITS=$1f;
      MANTISSA_SHIFT=23-EXPONENT_SHIFT;
      MAX_EXPONENT=EXPONENT_BITS shl EXPONENT_SHIFT;
var CastedValue:longword absolute Value;
    Sign:longword;
    Exponent,Mantissa:longint;
begin
 Sign:=CastedValue shr 31;
 Exponent:=longint(longword((CastedValue and $7f800000) shr 23))-127;
 Mantissa:=CastedValue and $007fffff;
 if Exponent=128 then begin
  // Infinity or NaN
  (* From the GL_EXT_packed_float spec:
   *     "Additionally: negative infinity is converted to zero; positive
   *      infinity is converted to positive infinity; and both positive and
   *      negative NaN are converted to positive NaN."
   *)
  if Mantissa<>0 then begin
   result:=MAX_EXPONENT or 1; // NaN
  end else begin
   if Sign<>0 then begin
    result:=0; // 0.0
   end else begin
    result:=MAX_EXPONENT; // Infinity
   end;
  end;
 end else if Sign<>0 then begin
  result:=0;
 end else if Value>64512.0 then begin
  (* From the GL_EXT_packed_float spec:
   *     "Likewise, finite positive values greater than 64512 (the maximum
   *      finite representable unsigned 11-bit floating-point value) are
   *      converted to 64512."
   *)
  result:=(30 shl EXPONENT_SHIFT) or 31;
 end else if Exponent>-15 then begin
  result:=((Exponent+EXPONENT_BIAS) shl EXPONENT_SHIFT) or (Mantissa shr MANTISSA_SHIFT);
 end else begin
  result:=0;
 end;
end;

function FloatToHalfFloat(const Value:single):longword;
var CastedValue:longword absolute Value;
    fExponent,fMantissa:longword;
    NewExponent:longint;
begin
 fExponent:=(CastedValue and $7f800000) shr 23;
 fMantissa:=CastedValue and $007fffff;
 if fExponent=0 then begin
  // Signed zero/denormal (which will underflow)
  result:=0;
 end else if fExponent=255 then begin
  // Inf or NaN (all exponent bits set)
  if fMantissa<>0 then begin
   result:=$7e00;
  end else begin
   result:=$7c00;
  end;
 end else begin
  // Normalized number
  NewExponent:=(fExponent-127)+15;
  if NewExponent>=31 then begin
   // Overflow, return signed infinity
   result:=$7c00;
  end else if NewExponent<=0 then begin
   // Underflow
   if (14-NewExponent)<=24 then begin
    // Mantissa might be non-zero
    fMantissa:=fMantissa or $800000; // Hidden one bit
    result:=(fMantissa shr (14-NewExponent)) and $3ff;
    if ((fMantissa shr (13-NewExponent)) and 1)<>0 then begin
     inc(result);
    end;
   end else begin
    result:=0;
   end;
  end else begin
   result:=((longword(NewExponent) shl 10) and $7c00) or ((fMantissa shr 13) and $3ff);
   if (fMantissa and $1000)<>0 then begin
    inc(result);
   end;
  end;
 end;
 result:=result or ((CastedValue and $80000000) shr 16);
end;

function HalfFloatToFloat(const Value:longword):single;
var m,e,f:longword;
begin
 m:=Value and $03ff;
 e:=Value and $7c00;
 if e=$7c00 then begin
  e:=$3fc00;
 end else if e<>0 then begin
  inc(e,$1c000);
  if (m=0) and (e>$1c400) then begin
   f:=((Value and $8000) shl 16) or (e shl 13) or $3ff;
   result:=single(pointer(@f)^);
   exit;
  end;
 end else if m<>0 then begin
  e:=$1c400;
  repeat
   m:=m shl 1;
   dec(e,$400);
  until (m and $400)<>0;
  m:=m and $3ff;
 end;
 f:=((Value and $8000) shl 16) or ((e or m) shl 13) or $3ff;
 result:=single(pointer(@f)^);
end;       

function ConvertRGB32FToR11FG11FB10F(const r,g,b:single):longword; {$ifdef caninline}inline;{$endif}
begin
//result:=(PackFP32FloatToM6E5Float(r) and $7ff) or ((PackFP32FloatToM6E5Float(g) and $7ff) shl 11) or ((PackFP32FloatToM6E5Float(b) and $3ff) shl 22);
 result:=(Float32ToFloat11(r) and $7ff) or ((Float32ToFloat11(g) and $7ff) shl 11) or ((Float32ToFloat10(b) and $3ff) shl 22);
end;

end.






