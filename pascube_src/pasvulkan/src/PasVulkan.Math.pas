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
unit PasVulkan.Math;
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
 {$ifndef fpc}
//  {$undef SIMD} // Due to inline assembler bugs in Delphi
 {$endif}
{$endif}

{$if defined(cpux64) and defined(Windows)}
 {$define ExplicitX64SIMDRegs}
{$ifend}

{$warnings off}

interface

uses SysUtils,
     Classes,
     Math,
     PasVulkan.Types,
     Vulkan;

const EPSILON={$ifdef UseDouble}1e-14{$else}1e-5{$endif}; // actually {$ifdef UseDouble}1e-16{$else}1e-7{$endif}; but we are conservative here

      SPHEREEPSILON=EPSILON;

      AABBEPSILON=EPSILON;

      MAX_SCALAR={$ifdef UseDouble}1.7e+308{$else}3.4e+28{$endif};

      DEG2RAD=PI/180.0;
      RAD2DEG=180.0/PI;

      LN2=0.6931471805599453;

      OnePI=PI;

      QuarterPI=PI*0.25;

      HalfPI=PI*0.5;

      TwoPI=PI*2.0;

      OneOverPI=1.0/PI;

      OneOverQuarterPI=1.0/QuarterPI;

      OneOverHalfPI=1.0/HalfPI;

      OneOverTwoPI=1.0/TwoPI;

      SQRT_0_DOT_5=0.70710678118;

      QTangentThreshold8Bit=1.0/127.0;

      QTangentThreshold16Bit=1.0/32767.0;

      SupraEngineFPUPrecisionMode:TFPUPrecisionMode={$ifdef cpu386}pmExtended{$else}{$ifdef cpux64}pmExtended{$else}pmDouble{$endif}{$endif};

      SupraEngineFPUExceptionMask:TFPUExceptionMask=[exInvalidOp,exDenormalized,exZeroDivide,exOverflow,exUnderflow,exPrecision];

type PpvScalar=^TpvScalar;
     TpvScalar={$ifdef UseDouble}TpvDouble{$else}TpvFloat{$endif};

     PpvClipRect=^TpvClipRect;
     TpvClipRect=array[0..3] of TpvInt32;

     PpvFloatClipRect=^TpvFloatClipRect;
     TpvFloatClipRect=array[0..3] of TpvFloat;

     PPpvIntPoint=^PpvIntPoint;
     PpvIntPoint=^TpvIntPoint;
     TpvIntPoint=record
      public
       x,y:TpvInt32;
     end;

     PPpvInt16Vector2=^PpvInt16Vector2;
     PpvInt16Vector2=^TpvInt16Vector2;
     TpvInt16Vector2=packed record
      public
       x,y:TpvInt16;
     end;

     PPpvUInt16Vector2=^PpvUInt16Vector2;
     PpvUInt16Vector2=^TpvUInt16Vector2;
     TpvUInt16Vector2=packed record
      public
       x,y:TpvUInt16;
     end;

     PPpvInt32Vector2=^PpvInt32Vector2;
     PpvInt32Vector2=^TpvInt32Vector2;
     TpvInt32Vector2=packed record
      public
       constructor Create(const aX:TpvInt32); overload;
       constructor Create(const aX,aY:TpvInt32); overload;
       class function InlineableCreate(const aX:TpvInt32):TpvInt32Vector2; overload; inline; static;
       class function InlineableCreate(const aX,aY:TpvInt32):TpvInt32Vector2; overload; inline; static;
       class operator Implicit(const aScalar:TpvInt32):TpvInt32Vector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Explicit(const aScalar:TpvInt32):TpvInt32Vector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Equal(const aLeft,aRight:TpvInt32Vector2):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator NotEqual(const aLeft,aRight:TpvInt32Vector2):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Add(const a,b:TpvInt32Vector2):TpvInt32Vector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract(const a,b:TpvInt32Vector2):TpvInt32Vector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const aLeft,aRight:TpvInt32Vector2):TpvInt32Vector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const aLeft:TpvInt32Vector2;const aRight:TpvInt32):TpvInt32Vector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const aLeft:TpvInt32;const aRight:TpvInt32Vector2):TpvInt32Vector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const aLeft,aRight:TpvInt32Vector2):TpvInt32Vector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const aLeft:TpvInt32Vector2;const aRight:TpvInt32):TpvInt32Vector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const aLeft:TpvInt32;const aRight:TpvInt32Vector2):TpvInt32Vector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Negative(const aValue:TpvInt32Vector2):TpvInt32Vector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Positive(const aValue:TpvInt32Vector2):TpvInt32Vector2; {$ifdef CAN_INLINE}inline;{$endif}
       function Length:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
      public
       x,y:TpvInt32;
     end;

     PpvVector2=^TpvVector2;
     TpvVector2=record
      public
       constructor Create(const aX:TpvScalar); overload;
       constructor Create(const aX,aY:TpvScalar); overload;
       class function InlineableCreate(const aX:TpvScalar):TpvVector2; overload; inline; static;
       class function InlineableCreate(const aX,aY:TpvScalar):TpvVector2; overload; inline; static;
       class operator Implicit(const aScalar:TpvScalar):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Explicit(const aScalar:TpvScalar):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Equal(const aLeft,aRight:TpvVector2):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator NotEqual(const aLeft,aRight:TpvVector2):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Inc(const aValue:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Dec(const aValue:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Add(const a,b:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Add(const a:TpvVector2;const b:TpvScalar):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Add(const a:TpvScalar;const b:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract(const a,b:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract(const a:TpvVector2;const b:TpvScalar):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract(const a:TpvScalar;const b:TpvVector2): TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a,b:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvVector2;const b:TpvScalar):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvScalar;const b:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const a,b:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const a:TpvVector2;const b:TpvScalar):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const a:TpvScalar;const b:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide(const a,b:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide(const a:TpvVector2;const b:TpvScalar):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide(const a:TpvScalar;const b:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a,b:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a:TpvVector2;const b:TpvScalar):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a:TpvScalar;const b:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Negative(const aValue:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Positive(const aValue:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
      private
       {$i PasVulkan.Math.TpvVector2.Swizzle.Definitions.inc}
      private
       function GetComponent(const aIndex:TpvInt32):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetComponent(const aIndex:TpvInt32;const aValue:TpvScalar); {$ifdef CAN_INLINE}inline;{$endif}
      public
       function Perpendicular:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       function Length:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function SquaredLength:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Normalize:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       function Abs:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       function Truncate:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       function Round:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       function Floor:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       function Ceil:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       function Fract:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       function DistanceTo(const aToVector:TpvVector2):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Dot(const aWithVector:TpvVector2):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Cross(const aVector:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       function Lerp(const aToVector:TpvVector2;const aTime:TpvScalar):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       function Nlerp(const aToVector:TpvVector2;const aTime:TpvScalar):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       function Slerp(const aToVector:TpvVector2;const aTime:TpvScalar):TpvVector2;
       function Sqlerp(const aB,aC,aD:TpvVector2;const aTime:TpvScalar):TpvVector2;
       function Angle(const aOtherFirstVector,aOtherSecondVector:TpvVector2):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Rotate(const aAngle:TpvScalar):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Rotate(const aCenter:TpvVector2;const aAngle:TpvScalar):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
       property Components[const aIndex:TpvInt32]:TpvScalar read GetComponent write SetComponent; default;
       case TpvUInt8 of
        0:(RawComponents:array[0..1] of TpvScalar);
        1:(x,y:TpvScalar);
        2:(u,v:TpvScalar);
        3:(s,t:TpvScalar);
        4:(r,g:TpvScalar);
     end;

     PpvVector3=^TpvVector3;
     TpvVector3=record
      public
       constructor Create(const aX:TpvScalar); overload;
       constructor Create(const aX,aY,aZ:TpvScalar); overload;
       constructor Create(const aXY:TpvVector2;const aZ:TpvScalar=0.0); overload;
       class function InlineableCreate(const aX:TpvScalar):TpvVector3; overload; inline; static;
       class function InlineableCreate(const aX,aY,aZ:TpvScalar):TpvVector3; overload; inline; static;
       class function InlineableCreate(const aXY:TpvVector2;const aZ:TpvScalar=0.0):TpvVector3; overload; inline; static;
       class function InlineableCreate(const aXYZ:TpvVector3):TpvVector3; overload; inline; static;
       class operator Implicit(const a:TpvScalar):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Explicit(const a:TpvScalar):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Equal(const a,b:TpvVector3):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator NotEqual(const a,b:TpvVector3):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Inc({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Dec({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector3):TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Add(const a:TpvVector3;const b:TpvScalar):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Add(const a:TpvScalar;const b:TpvVector3):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector3):TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Subtract(const a:TpvVector3;const b:TpvScalar):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract(const a:TpvScalar;const b:TpvVector3):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector3):TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply(const a:TpvVector3;const b:TpvScalar):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvScalar;const b:TpvVector3):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector3):TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Divide(const a:TpvVector3;const b:TpvScalar):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const a:TpvScalar;const b:TpvVector3):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector3):TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator IntDivide(const a:TpvVector3;const b:TpvScalar):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide(const a:TpvScalar;const b:TpvVector3):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a,b:TpvVector3):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a:TpvVector3;const b:TpvScalar):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a:TpvScalar;const b:TpvVector3):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Positive(const a:TpvVector3):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
      private
       {$i PasVulkan.Math.TpvVector3.Swizzle.Definitions.inc}
      private
       function GetComponent(const aIndex:TpvInt32):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetComponent(const aIndex:TpvInt32;const aValue:TpvScalar); {$ifdef CAN_INLINE}inline;{$endif}
      public
       function Flip:TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       function Perpendicular:TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       function OneUnitOrthogonalVector:TpvVector3;
       function OneUnitSmoothOrthogonalVector:TpvVector3;
       function Length:TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function SquaredLength:TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Normalize:TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function DistanceTo({$ifdef fpc}constref{$else}const{$endif} aToVector:TpvVector3):TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Min(const aWith:TpvVector3):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       function Max(const aWith:TpvVector3):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       function Abs:TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Truncate:TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Round:TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Floor:TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Ceil:TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Fract:TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Dot({$ifdef fpc}constref{$else}const{$endif} aWithVector:TpvVector3):TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function AngleTo(const aToVector:TpvVector3):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Cross({$ifdef fpc}constref{$else}const{$endif} aOtherVector:TpvVector3):TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Lerp(const aToVector:TpvVector3;const aTime:TpvScalar):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       function Nlerp(const aToVector:TpvVector3;const aTime:TpvScalar):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       function Slerp(const aToVector:TpvVector3;const aTime:TpvScalar):TpvVector3;
       function Sqlerp(const aB,aC,aD:TpvVector3;const aTime:TpvScalar):TpvVector3;
       function Angle(const aOtherFirstVector,aOtherSecondVector:TpvVector3):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function RotateX(const aAngle:TpvScalar):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       function RotateY(const aAngle:TpvScalar):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       function RotateZ(const aAngle:TpvScalar):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       function ProjectToBounds(const aMinVector,aMaxVector:TpvVector3):TpvScalar;
       property Components[const aIndex:TpvInt32]:TpvScalar read GetComponent write SetComponent; default;
       case TpvUInt8 of
        0:(RawComponents:array[0..2] of TpvScalar);
        1:(x,y,z:TpvScalar);
        2:(r,g,b:TpvScalar);
        3:(s,t,p:TpvScalar);
        4:(Pitch,Yaw,Roll:TpvScalar);
        6:(Vector2:TpvVector2);
     end;

     PpvVector4=^TpvVector4;
     TpvVector4=record
      public
       constructor Create(const aX:TpvScalar); overload;
       constructor Create(const aX,aY,aZ,aW:TpvScalar); overload;
       constructor Create(const aXY:TpvVector2;const aZ:TpvScalar=0.0;const aW:TpvScalar=1.0); overload;
       constructor Create(const aXYZ:TpvVector3;const aW:TpvScalar=1.0); overload;
       class function InlineableCreate(const aX:TpvScalar):TpvVector4; overload; inline; static;
       class function InlineableCreate(const aX,aY,aZ,aW:TpvScalar):TpvVector4; overload; inline; static;
       class function InlineableCreate(const aXY:TpvVector2;const aZ:TpvScalar=0.0;const aW:TpvScalar=0.0):TpvVector4; overload; inline; static;
       class function InlineableCreate(const aXYZ:TpvVector3;const aW:TpvScalar=0.0):TpvVector4; overload; inline; static;
       class operator Implicit(const a:TpvScalar):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Explicit(const a:TpvScalar):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Equal(const a,b:TpvVector4):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator NotEqual(const a,b:TpvVector4):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Inc({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Dec({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector4):TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Add(const a:TpvVector4;const b:TpvScalar):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Add(const a:TpvScalar;const b:TpvVector4):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector4):TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Subtract(const a:TpvVector4;const b:TpvScalar):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract(const a:TpvScalar;const b:TpvVector4): TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector4):TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply(const a:TpvVector4;const b:TpvScalar):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvScalar;const b:TpvVector4):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector4):TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Divide(const a:TpvVector4;const b:TpvScalar):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const a:TpvScalar;const b:TpvVector4):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector4):TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator IntDivide(const a:TpvVector4;const b:TpvScalar):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide(const a:TpvScalar;const b:TpvVector4):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a,b:TpvVector4):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a:TpvVector4;const b:TpvScalar):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a:TpvScalar;const b:TpvVector4):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Positive(const a:TpvVector4):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
      private
       {$i PasVulkan.Math.TpvVector4.Swizzle.Definitions.inc}
      private
       function GetComponent(const aIndex:TpvInt32):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetComponent(const aIndex:TpvInt32;const aValue:TpvScalar); {$ifdef CAN_INLINE}inline;{$endif}
      public
       function Flip:TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       function Perpendicular:TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       function Length:TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function SquaredLength:TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Normalize:TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function DistanceTo({$ifdef fpc}constref{$else}const{$endif} b:TpvVector4):TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Abs:TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Dot({$ifdef fpc}constref{$else}const{$endif} b:TpvVector4):TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function AngleTo(const b:TpvVector4):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Cross({$ifdef fpc}constref{$else}const{$endif} b:TpvVector4):TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Lerp(const aToVector:TpvVector4;const aTime:TpvScalar):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       function Nlerp(const aToVector:TpvVector4;const aTime:TpvScalar):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       function Slerp(const aToVector:TpvVector4;const aTime:TpvScalar):TpvVector4;
       function Sqlerp(const aB,aC,aD:TpvVector4;const aTime:TpvScalar):TpvVector4;
       function Angle(const aOtherFirstVector,aOtherSecondVector:TpvVector4):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function RotateX(const aAngle:TpvScalar):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       function RotateY(const aAngle:TpvScalar):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       function RotateZ(const aAngle:TpvScalar):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       function Rotate(const aAngle:TpvScalar;const aAxis:TpvVector3):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       function ProjectToBounds(const aMinVector,aMaxVector:TpvVector4):TpvScalar;
      public
       property Components[const aIndex:TpvInt32]:TpvScalar read GetComponent write SetComponent; default;
       case TpvUInt8 of
        0:(RawComponents:array[0..3] of TpvScalar);
        1:(x,y,z,w:TpvScalar);
        2:(r,g,b,a:TpvScalar);
        3:(s,t,p,q:TpvScalar);
        5:(Vector2:TpvVector2);
        6:(Vector3:TpvVector3);
     end;

     TpvVector2Helper=record helper for TpvVector2
      public
       const Null:TpvVector2=(x:0.0;y:0.0);
             Origin:TpvVector2=(x:0.0;y:0.0);
             XAxis:TpvVector2=(x:1.0;y:0.0);
             YAxis:TpvVector2=(x:0.0;y:1.0);
             AllAxis:TpvVector2=(x:1.0;y:1.0);
             AllMaxAxis:TpvVector3=(x:3.4e+28;y:3.4e+28);
      public
       {$i PasVulkan.Math.TpvVector2Helper.Swizzle.Definitions.inc}
     end;

     TpvVector3Helper=record helper for TpvVector3
      public
       const Null:TpvVector3=(x:0.0;y:0.0;z:0.0);
             Origin:TpvVector3=(x:0.0;y:0.0;z:0.0);
             XAxis:TpvVector3=(x:1.0;y:0.0;z:0.0);
             YAxis:TpvVector3=(x:0.0;y:1.0;z:0.0);
             ZAxis:TpvVector3=(x:0.0;y:0.0;z:1.0);
             AllAxis:TpvVector3=(x:1.0;y:1.0;z:1.0);
             AllMaxAxis:TpvVector3=(x:16777215.0;y:16777215.0;z:16777215.0);
      public
       {$i PasVulkan.Math.TpvVector3Helper.Swizzle.Definitions.inc}
     end;

     TpvVector4Helper=record helper for TpvVector4
      public
       const Null:TpvVector4=(x:0.0;y:0.0;z:0.0;w:0.0);
             Origin:TpvVector4=(x:0.0;y:0.0;z:0.0;w:0.0);
             XAxis:TpvVector4=(x:1.0;y:0.0;z:0.0;w:0.0);
             YAxis:TpvVector4=(x:0.0;y:1.0;z:0.0;w:0.0);
             ZAxis:TpvVector4=(x:0.0;y:0.0;z:1.0;w:0.0);
             WAxis:TpvVector4=(x:0.0;y:0.0;z:0.0;w:1.0);
             AllAxis:TpvVector4=(x:1.0;y:1.0;z:1.0;w:1.0);
             AllMaxAxis:TpvVector4=(x:16777215.0;y:16777215.0;z:16777215.0;w:16777215.0);
      public
       {$i PasVulkan.Math.TpvVector4Helper.Swizzle.Definitions.inc}
     end;

     PpvHalfFloatVector2=^TpvHalfFloatVector2;
     TpvHalfFloatVector2=record
      public
       case TpvUInt8 of
        0:(RawComponents:array[0..1] of TpvHalfFloat);
        1:(x,y:TpvHalfFloat);
        2:(r,g:TpvHalfFloat);
        3:(s,t:TpvHalfFloat);
        4:(RawIntComponents:array[0..1] of TpvUInt16);
    end;

     PpvHalfFloatVector3=^TpvHalfFloatVector3;
     TpvHalfFloatVector3=record
      public
       case TpvUInt8 of
        0:(RawComponents:array[0..2] of TpvHalfFloat);
        1:(x,y,z:TpvHalfFloat);
        2:(r,g,b:TpvHalfFloat);
        3:(s,t,p:TpvHalfFloat);
        4:(Vector2:TpvHalfFloatVector2);
        5:(RawIntComponents:array[0..2] of TpvUInt16);
     end;

     PpvHalfFloatVector4=^TpvHalfFloatVector4;
     TpvHalfFloatVector4=record
      public
       case TpvUInt8 of
        0:(RawComponents:array[0..3] of TpvHalfFloat);
        1:(x,y,z,w:TpvHalfFloat);
        2:(r,g,b,a:TpvHalfFloat);
        3:(s,t,p,q:TpvHalfFloat);
        5:(Vector2:TpvHalfFloatVector2);
        6:(Vector3:TpvHalfFloatVector3);
        7:(RawIntComponents:array[0..3] of TpvUInt16);
     end;

     PpvInt8PackedTangentSpace=^TpvInt8PackedTangentSpace;
     TpvInt8PackedTangentSpace=record
      x,y,z,w:TpvInt8;
     end;

     PpvInt16PackedTangentSpace=^TpvInt16PackedTangentSpace;
     TpvInt16PackedTangentSpace=record
      x,y,z,w:TpvInt16;
     end;

     PpvUInt8PackedTangentSpace=^TpvUInt8PackedTangentSpace;
     TpvUInt8PackedTangentSpace=record
      x,y,z,w:TpvUInt8;
     end;

     PpvUInt16PackedTangentSpace=^TpvUInt16PackedTangentSpace;
     TpvUInt16PackedTangentSpace=record
      x,y,z,w:TpvUInt16;
     end;

     PpvNormalizedSphericalCoordinates=^TpvNormalizedSphericalCoordinates;
     TpvNormalizedSphericalCoordinates=record
      Longitude:TpvScalar;
      Latitude:TpvScalar;
     end;

     TpvVector2DynamicArray=array of TpvVector2;

     TpvVector3DynamicArray=array of TpvVector3;

     TpvVector4DynamicArray=array of TpvVector4;

     PpvVector2Array=^TpvVector2Array;
     TpvVector2Array=array[0..$ff] of TpvVector2;

     PPpvVector2Array=^TPpvVector3Array;
     TPpvVector2Array=array[0..$ff] of PpvVector2;

     PpvVector3Array=^TpvVector3Array;
     TpvVector3Array=array[0..$ff] of TpvVector3;

     PPpvVector3Array=^TPpvVector3Array;
     TPpvVector3Array=array[0..$ff] of PpvVector3;

     PpvVector4Array=^TpvVector4s;
     TpvVector4s=array[0..$ff] of TpvVector4;

     PPpvVector4Array=^TPpvVector4Array;
     TPpvVector4Array=array[0..$ff] of PpvVector4;

     PpvPlane=^TpvPlane;
     TpvPlane=record
      public
       constructor Create(const aNormal:TpvVector3;const aDistance:TpvScalar); overload;
       constructor Create(const aX,aY,aZ,aDistance:TpvScalar); overload;
       constructor Create(const aA,aB,aC:TpvVector3); overload;
       constructor Create(const aA,aB,aC:TpvVector4); overload;
       constructor Create(const aVector:TpvVector4); overload;
       function ToVector:TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       function Normalize:TpvPlane; {$ifdef CAN_INLINE}inline;{$endif}
       function DistanceTo(const aPoint:TpvVector3):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function DistanceTo(const aPoint:TpvVector4):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
       procedure ClipSegment(const aP0,aP1:TpvVector3;out aClipped:TpvVector3); overload;
       function ClipSegmentClosest(const aP0,aP1:TpvVector3;out aClipped0,aClipped1:TpvVector3):TpvInt32; overload;
       function ClipSegmentLine(var aP0,aP1:TpvVector3):boolean;
       case TpvUInt8 of
        0:(
         RawComponents:array[0..3] of TpvScalar;
        );
        1:(
         x,y,z,w:TpvScalar;
        );
        2:(
         Normal:TpvVector3;
         Distance:TpvScalar;
        );
        3:(
         Vector4:TpvVector4;
        );
     end;

     PpvQuaternion=^TpvQuaternion;
     TpvQuaternion=record
      public
       constructor Create(const aX:TpvScalar); overload;
       constructor Create(const aX,aY,aZ,aW:TpvScalar); overload;
       constructor Create(const aVector:TpvVector4); overload;
       constructor CreateFromScaledAngleAxis(const aScaledAngleAxis:TpvVector3);
       constructor CreateFromAngularVelocity(const aAngularVelocity:TpvVector3);
       constructor CreateFromAngleAxis(const aAngle:TpvScalar;const aAxis:TpvVector3);
       constructor CreateFromEuler(const aPitch,aYaw,aRoll:TpvScalar); overload;
       constructor CreateFromEuler(const aAngles:TpvVector3); overload;
       constructor CreateFromNormalizedSphericalCoordinates(const aNormalizedSphericalCoordinates:TpvNormalizedSphericalCoordinates);
       constructor CreateFromToRotation(const aFromDirection,aToDirection:TpvVector3);
       constructor CreateFromLookRotation(const aForward,aUp:TpvVector3);
       constructor CreateFromCols(const aC0,aC1,aC2:TpvVector3);
       constructor CreateFromXY(const aX,aY:TpvVector3);
       class operator Implicit(const a:TpvScalar):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Explicit(const a:TpvScalar):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Equal(const a,b:TpvQuaternion):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator NotEqual(const a,b:TpvQuaternion):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Inc({$ifdef fpc}constref{$else}const{$endif} a:TpvQuaternion):TpvQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Dec({$ifdef fpc}constref{$else}const{$endif} a:TpvQuaternion):TpvQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvQuaternion):TpvQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Add(const a:TpvQuaternion;const b:TpvScalar):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Add(const a:TpvScalar;const b:TpvQuaternion):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvQuaternion):TpvQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Subtract(const a:TpvQuaternion;const b:TpvScalar):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract(const a:TpvScalar;const b:TpvQuaternion): TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvQuaternion):TpvQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply(const a:TpvQuaternion;const b:TpvScalar):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvScalar;const b:TpvQuaternion):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvQuaternion;{$ifdef fpc}constref{$else}const{$endif} b:TpvVector3):TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply(const a:TpvVector3;const b:TpvQuaternion):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvQuaternion;{$ifdef fpc}constref{$else}const{$endif} b:TpvVector4):TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply(const a:TpvVector4;const b:TpvQuaternion):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvQuaternion):TpvQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Divide(const a:TpvQuaternion;const b:TpvScalar):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const a:TpvScalar;const b:TpvQuaternion):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvQuaternion):TpvQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator IntDivide(const a:TpvQuaternion;const b:TpvScalar):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide(const a:TpvScalar;const b:TpvQuaternion):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a,b:TpvQuaternion):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a:TpvQuaternion;const b:TpvScalar):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a:TpvScalar;const b:TpvQuaternion):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvQuaternion):TpvQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Positive(const a:TpvQuaternion):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
      private
       function GetComponent(const aIndex:TpvInt32):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetComponent(const aIndex:TpvInt32;const aValue:TpvScalar); {$ifdef CAN_INLINE}inline;{$endif}
      public
       function ToNormalizedSphericalCoordinates:TpvNormalizedSphericalCoordinates; {$ifdef CAN_INLINE}inline;{$endif}
       function ToEuler:TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       function ToPitch:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function ToYaw:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function ToRoll:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function ToAngularVelocity:TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       procedure ToAngleAxis(out aAngle:TpvScalar;out aAxis:TpvVector3); {$ifdef CAN_INLINE}inline;{$endif}
       function ToScaledAngleAxis:TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       function Generator:TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       function Flip:TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       function Perpendicular:TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       function Conjugate:TpvQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Inverse:TpvQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Length:TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function SquaredLength:TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Normalize:TpvQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function DistanceTo({$ifdef fpc}constref{$else}const{$endif} b:TpvQuaternion):TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Abs:TpvQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Exp:TpvQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Log:TpvQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Dot({$ifdef fpc}constref{$else}const{$endif} b:TpvQuaternion):TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Lerp(const aToQuaternion:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       function Nlerp(const aToQuaternion:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       function Slerp(const aToQuaternion:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
       function ApproximatedSlerp(const aToQuaternion:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
       function Elerp(const aToQuaternion:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
       function Sqlerp(const aB,aC,aD:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
       function UnflippedSlerp(const aToQuaternion:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
       function UnflippedApproximatedSlerp(const aToQuaternion:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
       function UnflippedSqlerp(const aB,aC,aD:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
       function AngleBetween(const aP:TpvQuaternion):TpvScalar;
       function Between(const aP:TpvQuaternion):TpvQuaternion;
       class procedure Hermite(out aRotation:TpvQuaternion;out aVelocity:TpvVector3;const aTime:TpvScalar;const aR0,aR1:TpvQuaternion;const aV0,aV1:TpvVector3); static;
       class procedure CatmullRom(out aRotation:TpvQuaternion;out aVelocity:TpvVector3;const aTime:TpvScalar;const aR0,aR1,aR2,aR3:TpvQuaternion); static;
       function RotateAroundAxis(const aVector:TpvQuaternion):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       function Integrate(const aOmega:TpvVector3;const aDeltaTime:TpvScalar):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       function Spin(const aOmega:TpvVector3;const aDeltaTime:TpvScalar):TpvQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       property Components[const aIndex:TpvInt32]:TpvScalar read GetComponent write SetComponent; default;
       case TpvUInt8 of
        0:(RawComponents:array[0..3] of TpvScalar);
        1:(x,y,z,w:TpvScalar);
        2:(Vector:TpvVector4);
     end;

     PpvMatrix2x2=^TpvMatrix2x2;
     TpvMatrix2x2=record
      public
//     constructor Create; overload;
       constructor Create(const pX:TpvScalar); overload;
       constructor Create(const pXX,pXY,pYX,pYY:TpvScalar); overload;
       constructor Create(const pX,pY:TpvVector2); overload;
       class operator Implicit(const a:TpvScalar):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Explicit(const a:TpvScalar):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Equal(const a,b:TpvMatrix2x2):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator NotEqual(const a,b:TpvMatrix2x2):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Inc(const a:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Dec(const a:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Add(const a,b:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Add(const a:TpvMatrix2x2;const b:TpvScalar):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Add(const a:TpvScalar;const b:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract(const a,b:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract(const a:TpvMatrix2x2;const b:TpvScalar):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract(const a:TpvScalar;const b:TpvMatrix2x2): TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a,b:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvMatrix2x2;const b:TpvScalar):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvScalar;const b:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvMatrix2x2;const b:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvVector2;const b:TpvMatrix2x2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const a,b:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const a:TpvMatrix2x2;const b:TpvScalar):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const a:TpvScalar;const b:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide(const a,b:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide(const a:TpvMatrix2x2;const b:TpvScalar):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide(const a:TpvScalar;const b:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a,b:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a:TpvMatrix2x2;const b:TpvScalar):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a:TpvScalar;const b:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Negative(const a:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Positive(const a:TpvMatrix2x2):TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
      private
       function GetComponent(const pIndexA,pIndexB:TpvInt32):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetComponent(const pIndexA,pIndexB:TpvInt32;const pValue:TpvScalar); {$ifdef CAN_INLINE}inline;{$endif}
       function GetColumn(const pIndex:TpvInt32):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetColumn(const pIndex:TpvInt32;const pValue:TpvVector2); {$ifdef CAN_INLINE}inline;{$endif}
       function GetRow(const pIndex:TpvInt32):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetRow(const pIndex:TpvInt32;const pValue:TpvVector2); {$ifdef CAN_INLINE}inline;{$endif}
      public
       function Determinant:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Inverse:TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       function Transpose:TpvMatrix2x2; {$ifdef CAN_INLINE}inline;{$endif}
       property Components[const pIndexA,pIndexB:TpvInt32]:TpvScalar read GetComponent write SetComponent; default;
       property Columns[const pIndex:TpvInt32]:TpvVector2 read GetColumn write SetColumn;
       property Rows[const pIndex:TpvInt32]:TpvVector2 read GetRow write SetRow;
       case TpvInt32 of
        0:(RawComponents:array[0..1,0..1] of TpvScalar);
     end;

     PpvDecomposedMatrix3x3=^TpvDecomposedMatrix3x3;
     TpvDecomposedMatrix3x3=record
      public
       Valid:boolean;
       Scale:TpvVector3;
       Skew:TpvVector3; // XY XZ YZ
       Rotation:TpvQuaternion;
       class function Create:TpvDecomposedMatrix3x3; static;
       function Lerp(const b:TpvDecomposedMatrix3x3;const t:TpvScalar):TpvDecomposedMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function Nlerp(const b:TpvDecomposedMatrix3x3;const t:TpvScalar):TpvDecomposedMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function Slerp(const b:TpvDecomposedMatrix3x3;const t:TpvScalar):TpvDecomposedMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function Elerp(const b:TpvDecomposedMatrix3x3;const t:TpvScalar):TpvDecomposedMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function Sqlerp(const aB,aC,aD:TpvDecomposedMatrix3x3;const aTime:TpvScalar):TpvDecomposedMatrix3x3;
     end;

     PpvMatrix3x3=^TpvMatrix3x3;
     TpvMatrix3x3=record
      public
//     constructor Create; overload;
       constructor Create(const pX:TpvScalar); overload;
       constructor Create(const pXX,pXY,pXZ,pYX,pYY,pYZ,pZX,pZY,pZZ:TpvScalar); overload;
       constructor Create(const pX,pY,pZ:TpvVector3); overload;
       constructor CreateRotateX(const Angle:TpvScalar);
       constructor CreateRotateY(const Angle:TpvScalar);
       constructor CreateRotateZ(const Angle:TpvScalar);
       constructor CreateRotate(const Angle:TpvScalar;const Axis:TpvVector3);
       constructor CreateSkewYX(const Angle:TpvScalar);
       constructor CreateSkewZX(const Angle:TpvScalar);
       constructor CreateSkewXY(const Angle:TpvScalar);
       constructor CreateSkewZY(const Angle:TpvScalar);
       constructor CreateSkewXZ(const Angle:TpvScalar);
       constructor CreateSkewYZ(const Angle:TpvScalar);
       constructor CreateScale(const sx,sy:TpvScalar); overload;
       constructor CreateScale(const sx,sy,sz:TpvScalar); overload;
       constructor CreateScale(const pScale:TpvVector2); overload;
       constructor CreateScale(const pScale:TpvVector3); overload;
       constructor CreateTranslation(const tx,ty:TpvScalar); overload;
       constructor CreateTranslation(const pTranslation:TpvVector2); overload;
       constructor CreateFromToRotation(const FromDirection,ToDirection:TpvVector3);
       constructor CreateConstruct(const pForwards,pUp:TpvVector3);
       constructor CreateConstructForwardUp(const aForward,aUp:TpvVector3);
       constructor CreateOuterProduct(const u,v:TpvVector3);
       constructor CreateFromQuaternion(ppvQuaternion:TpvQuaternion);
       constructor CreateFromQTangent(pQTangent:TpvQuaternion);
       constructor CreateRecomposed(const DecomposedMatrix3x3:TpvDecomposedMatrix3x3);
       class operator Implicit(const a:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Explicit(const a:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Equal(const a,b:TpvMatrix3x3):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator NotEqual(const a,b:TpvMatrix3x3):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Inc(const a:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Dec(const a:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Add(const a,b:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Add(const a:TpvMatrix3x3;const b:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Add(const a:TpvScalar;const b:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract(const a,b:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract(const a:TpvMatrix3x3;const b:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Subtract(const a:TpvScalar;const b:TpvMatrix3x3): TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a,b:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvMatrix3x3;const b:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvScalar;const b:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvMatrix3x3;const b:TpvVector2):TpvVector2;  {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvVector2;const b:TpvMatrix3x3):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvMatrix3x3;const b:TpvVector3):TpvVector3;  {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvVector3;const b:TpvMatrix3x3):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvMatrix3x3;const b:TpvVector4):TpvVector4;  {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvVector4;const b:TpvMatrix3x3):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvMatrix3x3;const b:TpvPlane):TpvPlane; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvPlane;const b:TpvMatrix3x3):TpvPlane; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const a,b:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const a:TpvMatrix3x3;const b:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const a:TpvScalar;const b:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide(const a,b:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide(const a:TpvMatrix3x3;const b:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide(const a:TpvScalar;const b:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a,b:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a:TpvMatrix3x3;const b:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a:TpvScalar;const b:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Negative(const a:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Positive(const a:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
      private
       function GetComponent(const pIndexA,pIndexB:TpvInt32):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetComponent(const pIndexA,pIndexB:TpvInt32;const pValue:TpvScalar); {$ifdef CAN_INLINE}inline;{$endif}
       function GetColumn(const pIndex:TpvInt32):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetColumn(const pIndex:TpvInt32;const pValue:TpvVector3); {$ifdef CAN_INLINE}inline;{$endif}
       function GetRow(const pIndex:TpvInt32):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetRow(const pIndex:TpvInt32;const pValue:TpvVector3); {$ifdef CAN_INLINE}inline;{$endif}
      public
       function Determinant:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Inverse:TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function Transpose:TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function Adjugate:TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function EulerAngles:TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       function Normalize:TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function OrthoNormalize:TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function RobustOrthoNormalize(const Tolerance:TpvScalar=1e-3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function ToQuaternion:TpvQuaternion;
       function ToQTangent(const aThreshold:TpvDouble=QTangentThreshold16Bit):TpvQuaternion;
       function SimpleLerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function SimpleNlerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function SimpleSlerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function SimpleElerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function SimpleSqlerp(const aB,aC,aD:TpvMatrix3x3;const aTime:TpvScalar):TpvMatrix3x3;
       function Lerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function Nlerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function Slerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function Elerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function Sqlerp(const aB,aC,aD:TpvMatrix3x3;const aTime:TpvScalar):TpvMatrix3x3;
       function MulInverse(const a:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function MulInverse(const a:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Decompose:TpvDecomposedMatrix3x3;
       property Components[const pIndexA,pIndexB:TpvInt32]:TpvScalar read GetComponent write SetComponent; default;
       property Columns[const pIndex:TpvInt32]:TpvVector3 read GetColumn write SetColumn;
       property Rows[const pIndex:TpvInt32]:TpvVector3 read GetRow write SetRow;
       case TpvInt32 of
        0:(RawComponents:array[0..2,0..2] of TpvScalar);
        1:(LinearRawComponents:array[0..8] of TpvScalar);
        2:(m00,m01,m02,m10,m11,m12,m20,m21,m22:TpvScalar);
        3:(Tangent,Bitangent,Normal:TpvVector3);
        4:(Right,Up,Forwards:TpvVector3);
        5:(RawVectors:array[0..2] of TpvVector3);
     end;

     TpvMatrix3x3DynamicArray=array of TpvMatrix3x3;

     PpvDecomposedMatrix4x4=^TpvDecomposedMatrix4x4;
     TpvDecomposedMatrix4x4=record
      public
       Valid:boolean;
       Perspective:TpvVector4;
       Translation:TpvVector3;
       Scale:TpvVector3;
       Skew:TpvVector3; // XY XZ YZ
       Rotation:TpvQuaternion;
       class function Create:TpvDecomposedMatrix4x4; static;
       function Lerp(const b:TpvDecomposedMatrix4x4;const t:TpvScalar):TpvDecomposedMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function Nlerp(const b:TpvDecomposedMatrix4x4;const t:TpvScalar):TpvDecomposedMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function Slerp(const b:TpvDecomposedMatrix4x4;const t:TpvScalar):TpvDecomposedMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function Elerp(const b:TpvDecomposedMatrix4x4;const t:TpvScalar):TpvDecomposedMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function Sqlerp(const aB,aC,aD:TpvDecomposedMatrix4x4;const aTime:TpvScalar):TpvDecomposedMatrix4x4;
     end;

     PpvMatrix4x4=^TpvMatrix4x4;
     TpvMatrix4x4=record
      public
//     constructor Create; overload;
       constructor Create(const pX:TpvScalar); overload;
       constructor Create(const pXX,pXY,pXZ,pXW,pYX,pYY,pYZ,pYW,pZX,pZY,pZZ,pZW,pWX,pWY,pWZ,pWW:TpvScalar); overload;
       constructor Create(const pX,pY,pZ:TpvVector3); overload;
       constructor Create(const pX,pY,pZ,pW:TpvVector3); overload;
       constructor Create(const pX,pY,pZ,pW:TpvVector4); overload;
       constructor Create(const pMatrix:TpvMatrix3x3); overload;
       constructor CreateRotateX(const Angle:TpvScalar);
       constructor CreateRotateY(const Angle:TpvScalar);
       constructor CreateRotateZ(const Angle:TpvScalar);
       constructor CreateRotate(const Angle:TpvScalar;const Axis:TpvVector3);
       constructor CreateRotation(const pMatrix:TpvMatrix4x4); overload;
       constructor CreateSkewYX(const Angle:TpvScalar);
       constructor CreateSkewZX(const Angle:TpvScalar);
       constructor CreateSkewXY(const Angle:TpvScalar);
       constructor CreateSkewZY(const Angle:TpvScalar);
       constructor CreateSkewXZ(const Angle:TpvScalar);
       constructor CreateSkewYZ(const Angle:TpvScalar);
       constructor CreateScale(const sx,sy:TpvScalar); overload;
       constructor CreateScale(const pScale:TpvVector2); overload;
       constructor CreateScale(const sx,sy,sz:TpvScalar); overload;
       constructor CreateScale(const pScale:TpvVector3); overload;
       constructor CreateScale(const sx,sy,sz,sw:TpvScalar); overload;
       constructor CreateScale(const pScale:TpvVector4); overload;
       constructor CreateTranslation(const tx,ty:TpvScalar); overload;
       constructor CreateTranslation(const pTranslation:TpvVector2); overload;
       constructor CreateTranslation(const tx,ty,tz:TpvScalar); overload;
       constructor CreateTranslation(const pTranslation:TpvVector3); overload;
       constructor CreateTranslation(const tx,ty,tz,tw:TpvScalar); overload;
       constructor CreateTranslation(const pTranslation:TpvVector4); overload;
       constructor CreateTranslated(const pMatrix:TpvMatrix4x4;pTranslation:TpvVector3); overload;
       constructor CreateTranslated(const pMatrix:TpvMatrix4x4;pTranslation:TpvVector4); overload;
       constructor CreateFromToRotation(const FromDirection,ToDirection:TpvVector3);
       constructor CreateConstruct(const pForwards,pUp:TpvVector3);
       constructor CreateOuterProduct(const u,v:TpvVector3);
       constructor CreateFromQuaternion(ppvQuaternion:TpvQuaternion);
       constructor CreateFromQTangent(pQTangent:TpvQuaternion);
       constructor CreateReflect(const PpvPlane:TpvPlane);
       constructor CreateFrustumLeftHandedNegativeOneToPositiveOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateFrustumLeftHandedZeroToOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateFrustumLeftHandedOneToZero(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateFrustumRightHandedNegativeOneToPositiveOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateFrustumRightHandedZeroToOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateFrustumRightHandedOneToZero(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateFrustum(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateOrthoLeftHandedNegativeOneToPositiveOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateOrthoLeftHandedZeroToOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateOrthoRightHandedNegativeOneToPositiveOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateOrthoRightHandedZeroToOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateOrtho(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateOrthoLH(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateOrthoRH(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateOrthoOffCenterLH(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreateOrthoOffCenterRH(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
       constructor CreatePerspectiveLeftHandedNegativeOneToPositiveOne(const fovy,Aspect,zNear,zFar:TpvScalar);
       constructor CreatePerspectiveLeftHandedZeroToOne(const fovy,Aspect,zNear,zFar:TpvScalar);
       constructor CreatePerspectiveLeftHandedOneToZero(const fovy,Aspect,zNear,zFar:TpvScalar);
       constructor CreatePerspectiveRightHandedNegativeOneToPositiveOne(const fovy,Aspect,zNear,zFar:TpvScalar);
       constructor CreatePerspectiveRightHandedZeroToOne(const fovy,Aspect,zNear,zFar:TpvScalar);
       constructor CreatePerspectiveRightHandedOneToZero(const fovy,Aspect,zNear,zFar:TpvScalar);
       constructor CreatePerspectiveReversedZ(const aFOVY,aAspectRatio,aZNear:TpvScalar);
       constructor CreatePerspective(const fovy,Aspect,zNear,zFar:TpvScalar);
       constructor CreateHorizontalFOVPerspectiveLeftHandedNegativeOneToPositiveOne(const fovx,Aspect,zNear,zFar:TpvScalar);
       constructor CreateHorizontalFOVPerspectiveLeftHandedZeroToOne(const fovx,Aspect,zNear,zFar:TpvScalar);
       constructor CreateHorizontalFOVPerspectiveLeftHandedOneToZero(const fovx,Aspect,zNear,zFar:TpvScalar);
       constructor CreateHorizontalFOVPerspectiveRightHandedNegativeOneToPositiveOne(const fovx,Aspect,zNear,zFar:TpvScalar);
       constructor CreateHorizontalFOVPerspectiveRightHandedZeroToOne(const fovx,Aspect,zNear,zFar:TpvScalar);
       constructor CreateHorizontalFOVPerspectiveRightHandedOneToZero(const fovx,Aspect,zNear,zFar:TpvScalar);
       constructor CreateHorizontalFOVPerspectiveReversedZ(const aFOVX,aAspectRatio,aZNear:TpvScalar);
       constructor CreateHorizontalFOVPerspective(const fovx,Aspect,zNear,zFar:TpvScalar);
       constructor CreateInverseLookAt(const Eye,Center,Up:TpvVector3);
       constructor CreateLookAt(const Eye,Center,Up:TpvVector3);
       constructor CreateFill(const Eye,RightVector,UpVector,ForwardVector:TpvVector3);
       constructor CreateConstructX(const xAxis:TpvVector3);
       constructor CreateConstructY(const yAxis:TpvVector3);
       constructor CreateConstructZ(const zAxis:TpvVector3);
       constructor CreateProjectionMatrixClip(const ProjectionMatrix:TpvMatrix4x4;const ClipPlane:TpvPlane);
       constructor CreateRecomposed(const DecomposedMatrix4x4:TpvDecomposedMatrix4x4);
       class operator Implicit({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Explicit({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Equal({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator NotEqual({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Inc({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Dec({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Add({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvScalar):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Add({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Subtract({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvScalar):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Subtract({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4): TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvScalar):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvVector2):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvVector2;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvVector2; {$ifdef CAN_INLINE}inline;{$endif} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvVector3):TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvVector4):TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvPlane):TpvPlane; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvPlane;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvPlane; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Divide({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvScalar):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Divide({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvScalar):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator IntDivide({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Modulus({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvScalar):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4):TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       class operator Positive(const a:TpvMatrix4x4):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
      private
       function GetComponent(const pIndexA,pIndexB:TpvInt32):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetComponent(const pIndexA,pIndexB:TpvInt32;const pValue:TpvScalar); {$ifdef CAN_INLINE}inline;{$endif}
       function GetColumn(const pIndex:TpvInt32):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetColumn(const pIndex:TpvInt32;const pValue:TpvVector4); {$ifdef CAN_INLINE}inline;{$endif}
       function GetRow(const pIndex:TpvInt32):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetRow(const pIndex:TpvInt32;const pValue:TpvVector4); {$ifdef CAN_INLINE}inline;{$endif}
      public
       function Determinant:TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Translate(const aVector:TpvVector3):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function SimpleInverse:TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function Inverse:TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Transpose:TpvMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Adjugate:TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function EulerAngles:TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       function Normalize:TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function OrthoNormalize:TpvMatrix4x4; //{$ifdef CAN_INLINE}inline;{$endif}
       function RobustOrthoNormalize(const Tolerance:TpvScalar=1e-3):TpvMatrix4x4; //{$ifdef CAN_INLINE}inline;{$endif}
       function ToQuaternion:TpvQuaternion;
       function ToQTangent(const aThreshold:TpvDouble=QTangentThreshold16Bit):TpvQuaternion;
       function ToMatrix3x3:TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
       function ToRotation:TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function SimpleLerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function SimpleNlerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function SimpleSlerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function SimpleElerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function SimpleSqlerp(const aB,aC,aD:TpvMatrix4x4;const aTime:TpvScalar):TpvMatrix4x4;
       function Lerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function Nlerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function Slerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function Elerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       function Sqlerp(const aB,aC,aD:TpvMatrix4x4;const aTime:TpvScalar):TpvMatrix4x4;
       function MulInverse({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function MulInverse({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function MulInverted({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function MulInverted({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function MulBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function MulBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function MulAbsBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function MulAbsBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function MulTransposedBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function MulTransposedBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function MulHomogen({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3; overload; //{$ifdef CAN_INLINE}inline;{$endif}
       function MulHomogen({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4; overload; //{$ifdef CAN_INLINE}inline;{$endif}
       function Decompose:TpvDecomposedMatrix4x4;
       property Components[const pIndexA,pIndexB:TpvInt32]:TpvScalar read GetComponent write SetComponent; default;
       property Columns[const pIndex:TpvInt32]:TpvVector4 read GetColumn write SetColumn;
       property Rows[const pIndex:TpvInt32]:TpvVector4 read GetRow write SetRow;
       case TpvInt32 of
        0:(RawComponents:array[0..3,0..3] of TpvScalar);
        1:(LinearRawComponents:array[0..15] of TpvScalar);
        2:(m00,m01,m02,m03,m10,m11,m12,m13,m20,m21,m22,m23,m30,m31,m32,m33:TpvScalar);
        3:(Tangent,Bitangent,Normal,Translation:TpvVector4);
        4:(Right,Up,Forwards,Offset:TpvVector4);
        5:(RawVectors:array[0..3] of TpvVector4);
     end;

     TpvMatrix4x4Array=array[0..65535] of TpvMatrix4x4;
     PpvMatrix4x4Array=^TpvMatrix4x4Array;

     TpvMatrix4x4DynamicArray=array of TpvMatrix4x4;

     // Dual quaternion with uniform scaling support
     PpvDualQuaternion=^TpvDualQuaternion;
     TpvDualQuaternion=record
      public
       constructor Create(const pQ0,PQ1:TpvQuaternion); overload;
       constructor CreateFromRotationTranslationScale(const pRotation:TpvQuaternion;const pTranslation:TpvVector3;const pScale:TpvScalar); overload;
       constructor CreateFromMatrix(const pMatrix:TpvMatrix4x4); overload;
       class operator Implicit(const a:TpvMatrix4x4):TpvDualQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Explicit(const a:TpvMatrix4x4):TpvDualQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Implicit(const a:TpvDualQuaternion):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Explicit(const a:TpvDualQuaternion):TpvMatrix4x4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Equal(const a,b:TpvDualQuaternion):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator NotEqual(const a,b:TpvDualQuaternion):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvDualQuaternion):TpvDualQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend}
       class operator Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvDualQuaternion):TpvDualQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvDualQuaternion):TpvDualQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend}
       class operator Multiply(const a:TpvDualQuaternion;const b:TpvScalar):TpvDualQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply(const a:TpvScalar;const b:TpvDualQuaternion):TpvDualQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvDualQuaternion;{$ifdef fpc}constref{$else}const{$endif} b:TpvVector3):TpvVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend}
       class operator Multiply(const a:TpvVector3;const b:TpvDualQuaternion):TpvVector3; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvDualQuaternion;{$ifdef fpc}constref{$else}const{$endif} b:TpvVector4):TpvVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend}
       class operator Multiply(const a:TpvVector4;const b:TpvDualQuaternion):TpvVector4; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvDualQuaternion):TpvDualQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend}
       class operator Divide(const a:TpvDualQuaternion;const b:TpvScalar):TpvDualQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Divide(const a:TpvScalar;const b:TpvDualQuaternion):TpvDualQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvDualQuaternion):TpvDualQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend}
       class operator IntDivide(const a:TpvDualQuaternion;const b:TpvScalar):TpvDualQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator IntDivide(const a:TpvScalar;const b:TpvDualQuaternion):TpvDualQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a,b:TpvDualQuaternion):TpvDualQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a:TpvDualQuaternion;const b:TpvScalar):TpvDualQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Modulus(const a:TpvScalar;const b:TpvDualQuaternion):TpvDualQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvDualQuaternion):TpvDualQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend}
       class operator Positive(const a:TpvDualQuaternion):TpvDualQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       function Flip:TpvDualQuaternion; {$ifdef CAN_INLINE}inline;{$endif}
       function Conjugate:TpvDualQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Inverse:TpvDualQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       function Normalize:TpvDualQuaternion; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend} {$if defined(fpc) and defined(cpuamd64) and not defined(Windows)}ms_abi_default;{$ifend}
       case TpvUInt8 of
        0:(RawQuaternions:array[0..1] of TpvQuaternion);
        1:(QuaternionR,QuaternionD:TpvQuaternion);
     end;

     TpvMatrix2x2Helper=record helper for TpvMatrix2x2
      public
       const Null:TpvMatrix2x2=(RawComponents:((0.0,0.0),(0.0,0.0)));
             Identity:TpvMatrix2x2=(RawComponents:((1.0,0.0),(0.0,1.0)));
     end;

     TpvMatrix3x3Helper=record helper for TpvMatrix3x3
      public
       const Null:TpvMatrix3x3=(RawComponents:((0.0,0.0,0.0),(0.0,0.0,0.0),(0.0,0.0,0.0)));
             Identity:TpvMatrix3x3=(RawComponents:((1.0,0.0,0.0),(0.0,1.0,0.0),(0.0,0.0,1.0)));
     end;

     TpvMatrix4x4Helper=record helper for TpvMatrix4x4
      public
       const Null:TpvMatrix4x4=(RawComponents:((0.0,0.0,0,0.0),(0.0,0.0,0,0.0),(0.0,0.0,0,0.0),(0.0,0.0,0,0.0)));
             Identity:TpvMatrix4x4=(RawComponents:((1.0,0.0,0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,1.0,0.0),(0.0,0.0,0,1.0)));
             RotateY180:TpvMatrix4x4=(RawComponents:((-1.0,0.0,0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,-1.0,0.0),(0.0,0.0,0,1.0)));
             RightToLeftHanded:TpvMatrix4x4=(RawComponents:((1.0,0.0,0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,-1.0,0.0),(0.0,0.0,0,1.0)));
             Flip:TpvMatrix4x4=(RawComponents:((0.0,0.0,-1.0,0.0),(-1.0,0.0,0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,0,1.0)));
             InverseFlip:TpvMatrix4x4=(RawComponents:((0.0,-1.0,0.0,0.0),(0.0,0.0,1.0,0.0),(-1.0,0.0,0,0.0),(0.0,0.0,0,1.0)));
             FlipYZ:TpvMatrix4x4=(RawComponents:((1.0,0.0,0,0.0),(0.0,0.0,1.0,0.0),(0.0,-1.0,0.0,0.0),(0.0,0.0,0,1.0)));
             InverseFlipYZ:TpvMatrix4x4=(RawComponents:((1.0,0.0,0,0.0),(0.0,0.0,-1.0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,0,1.0)));
             NormalizedSpace:TpvMatrix4x4=(RawComponents:((2.0,0.0,0,0.0),(0.0,2.0,0.0,0.0),(0.0,0.0,2.0,0.0),(-1.0,-1.0,-1.0,1.0)));
             FlipYClipSpace:TpvMatrix4x4=(RawComponents:((1.0,0.0,0,0.0),(0.0,-1.0,0.0,0.0),(0.0,0.0,1.0,0.0),(0.0,0.0,0.0,1.0)));
             HalfZClipSpace:TpvMatrix4x4=(RawComponents:((1.0,0.0,0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,0.5,0.0),(0.0,0.0,0.5,1.0)));
             FlipYHalfZClipSpace:TpvMatrix4x4=(RawComponents:((1.0,0.0,0,0.0),(0.0,-1.0,0.0,0.0),(0.0,0.0,0.5,0.0),(0.0,0.0,0.5,1.0)));
             FlipZ:TpvMatrix4x4=(RawComponents:((1.0,0.0,0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,-1.0,0.0),(0.0,0.0,0.0,1.0)));
     end;

     TpvQuaternionHelper=record helper for TpvQuaternion
      public
       const Identity:TpvQuaternion=(x:0.0;y:0.0;z:0.0;w:1.0);
     end;


     PpvSegment=^TpvSegment;
     TpvSegment=record
      public
       Points:array[0..1] of TpvVector3;
       constructor Create(const p0,p1:TpvVector3);
       function SquaredDistanceTo(const p:TpvVector3):TpvScalar; overload;
       function SquaredDistanceTo(const p:TpvVector3;out Nearest:TpvVector3):TpvScalar; overload;
       procedure ClosestPointTo(const p:TpvVector3;out Time:TpvScalar;out ClosestPoint:TpvVector3);
       function Transform(const Transform:TpvMatrix4x4):TpvSegment; {$ifdef CAN_INLINE}inline;{$endif}
       procedure ClosestPoints(const SegmentB:TpvSegment;out TimeA:TpvScalar;out ClosestPointA:TpvVector3;out TimeB:TpvScalar;out ClosestPointB:TpvVector3);
       function Intersect(const SegmentB:TpvSegment;out TimeA,TimeB:TpvScalar;out IntersectionPoint:TpvVector3):boolean;
     end;

     PpvRelativeSegment=^TpvRelativeSegment;
     TpvRelativeSegment=record
      public
       Origin:TpvVector3;
       Delta:TpvVector3;
       function SquaredSegmentDistanceTo(const pOtherRelativeSegment:TpvRelativeSegment;out t0,t1:TpvScalar):TpvScalar;
     end;

     PpvTriangle=^TpvTriangle;
     TpvTriangle=record
      public
       Points:array[0..2] of TpvVector3;
       Normal:TpvVector3;
       constructor Create(const pA,pB,pC:TpvVector3);
       function Contains(const p:TpvVector3):boolean;
       procedure ProjectToVector(const Vector:TpvVector3;out TriangleMin,TriangleMax:TpvScalar);
       function ProjectToPoint(var pPoint:TpvVector3;out s,t:TpvScalar):TpvScalar;
       function SegmentIntersect(const Segment:TpvSegment;out Time:TpvScalar;out IntersectionPoint:TpvVector3):boolean;
       function ClosestPointTo(const Point:TpvVector3;out ClosestPoint:TpvVector3):boolean; overload;
       function ClosestPointTo(const Segment:TpvSegment;out Time:TpvScalar;out pClosestPointOnSegment,pClosestPointOnTriangle:TpvVector3):boolean; overload;
       function GetClosestPointTo(const pPoint:TpvVector3;out ClosestPoint:TpvVector3;out s,t:TpvScalar):TpvScalar; overload;
       function GetClosestPointTo(const pPoint:TpvVector3;out ClosestPoint:TpvVector3):TpvScalar; overload;
       function DistanceTo(const Point:TpvVector3):TpvScalar;
       function SquaredDistanceTo(const Point:TpvVector3):TpvScalar;
       function RayIntersection(const RayOrigin,RayDirection:TpvVector3;var Time,u,v:TpvScalar):boolean;
     end;

     PpvSegmentTriangle=^TpvSegmentTriangle;
     TpvSegmentTriangle=record
      public
       Origin:TpvVector3;
       Edge0:TpvVector3;
       Edge1:TpvVector3;
       Edge2:TpvVector3;
       function RelativeSegmentIntersection(const ppvSegment:TpvRelativeSegment;out tS,tT0,tT1:TpvScalar):boolean;
       function SquaredPointTriangleDistance(const pPoint:TpvVector3;out pfSParam,pfTParam:TpvScalar):TpvScalar;
       function SquaredDistanceTo(const ppvRelativeSegment:TpvRelativeSegment;out segT,triT0,triT1:TpvScalar):TpvScalar;
     end;

     PpvOBB=^TpvOBB;
     TpvOBB=packed record
      public
       Center:TpvVector3;
       HalfExtents:TpvVector3;
       procedure ProjectToVector(const Vector:TpvVector3;out OBBMin,OBBMax:TpvScalar);
       function Intersect(const aWith:TpvOBB;const aThreshold:TpvScalar=EPSILON):boolean; overload;
       function RelativeSegmentIntersection(const ppvRelativeSegment:TpvRelativeSegment;out fracOut:TpvScalar;out posOut,NormalOut:TpvVector3):boolean;
       function TriangleIntersection(const Triangle:TpvTriangle;out Position,Normal:TpvVector3;out Penetration:TpvScalar):boolean; overload;
       function TriangleIntersection(const ppvTriangle:TpvTriangle;const MTV:PpvVector3=nil):boolean; overload;
       case TpvInt32 of
        0:(
         Axis:array[0..2] of TpvVector3;
        );
        1:(
         Matrix:TpvMatrix3x3;
        );
     end;

     PpvOBBs=^TpvOBBs;
     TpvOBBs=array[0..65535] of TpvOBB;

     PpvAABB=^TpvAABB;
     TpvAABB=record
      public
       constructor Create(const pMin,pMax:TpvVector3);
       constructor CreateFromOBB(const OBB:TpvOBB);
       function Cost:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Volume:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Area:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Center:TpvVector3;
       function Flip:TpvAABB;
       function ToOBB(const aTransform:TpvMatrix4x4):TpvOBB;
       function SquareMagnitude:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Resize(const f:TpvScalar):TpvAABB; {$ifdef CAN_INLINE}inline;{$endif}
       procedure DirectCombine(const WithAABB:TpvAABB); {$ifdef CAN_INLINE}inline;{$endif}
       procedure DirectCombineVector3(const v:TpvVector3); {$ifdef CAN_INLINE}inline;{$endif}
       function Combine(const WithAABB:TpvAABB):TpvAABB; {$ifdef CAN_INLINE}inline;{$endif}
       function CombineVector3(const v:TpvVector3):TpvAABB; {$ifdef CAN_INLINE}inline;{$endif}
       function Enlarge(const aWithAABB:TpvAABB):boolean;
       function DistanceTo(const ToAABB:TpvAABB):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Radius:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Compare(const WithAABB:TpvAABB):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       function Intersect(const aWith:TpvOBB;const aThreshold:TpvScalar=EPSILON):boolean; overload;
       function Intersect(const WithAABB:TpvAABB;Threshold:TpvScalar=EPSILON):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
       class function Intersect(const aAABBMin,aAABBMax:TpvVector3;const WithAABB:TpvAABB;Threshold:TpvScalar=EPSILON):boolean; overload; static; {$ifdef CAN_INLINE}inline;{$endif}
       function Contains(const AABB:TpvAABB;const aThreshold:TpvScalar=EPSILON):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
       class function Contains(const aAABBMin,aAABBMax:TpvVector3;const aAABB:TpvAABB;const aThreshold:TpvScalar=EPSILON):boolean; overload; static; {$ifdef CAN_INLINE}inline;{$endif}
       function Contains(const Vector:TpvVector3):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
       class function Contains(const aAABBMin,aAABBMax,aVector:TpvVector3):boolean; overload; static;  {$ifdef CAN_INLINE}inline;{$endif}
       function Contains(const aOBB:TpvOBB):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Touched(const Vector:TpvVector3;const Threshold:TpvScalar=1e-5):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       function GetIntersection(const WithAABB:TpvAABB):TpvAABB; {$ifdef CAN_INLINE}inline;{$endif}
       function FastRayIntersection(const Origin,Direction:TpvVector3):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
       class function FastRayIntersection(const aAABBMin,aAABBMax:TpvVector3;const Origin,Direction:TpvVector3):boolean; overload; static;  {$ifdef CAN_INLINE}inline;{$endif}
       function RayIntersectionHitDistance(const Origin,Direction:TpvVector3;var HitDist:TpvScalar):boolean;
       function RayIntersectionHitPoint(const Origin,Direction:TpvVector3;out HitPoint:TpvVector3):boolean;
       function RayIntersection(const Origin,Direction:TpvVector3;out Time:TpvScalar):boolean; overload;
       class function RayIntersection(const aAABBMin,aAABBMax:TpvVector3;const Origin,Direction:TpvVector3;out Time:TpvScalar):boolean; overload; static;
       function LineIntersection(const StartPoint,EndPoint:TpvVector3):boolean; overload;
       class function LineIntersection(const aAABBMin,aAABBMax:TpvVector3;const StartPoint,EndPoint:TpvVector3):boolean; overload; static;
       function TriangleIntersection(const Triangle:TpvTriangle):boolean;
       function Transform(const Transform:TpvMatrix3x3):TpvAABB; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Transform(const Transform:TpvMatrix4x4):TpvAABB; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function HomogenTransform(const aTransform:TpvMatrix4x4):TpvAABB; overload;
       function MatrixMul(const Transform:TpvMatrix3x3):TpvAABB; overload;
       function MatrixMul(const Transform:TpvMatrix4x4):TpvAABB; overload;
       function ScissorRect(out Scissor:TpvClipRect;const mvp:TpvMatrix4x4;const vp:TpvClipRect;zcull:boolean):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function ScissorRect(out Scissor:TpvFloatClipRect;const mvp:TpvMatrix4x4;const vp:TpvFloatClipRect;zcull:boolean):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function MovingTest(const aAABBTo,bAABBFrom,bAABBTo:TpvAABB;var t:TpvScalar):boolean;
       function SweepTest(const bAABB:TpvAABB;const aV,bV:TpvVector3;var FirstTime,LastTime:TpvScalar):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       case boolean of
        false:(
         Min,Max:TpvVector3;
        );
        true:(
         MinMax:array[0..1] of TpvVector3;
        );
     end;

     PpvAABBs=^TpvAABBs;
     TpvAABBs=array[0..65535] of TpvAABB;

     PpvSphere=^TpvSphere;
     TpvSphere=record
      public
       constructor Create(const pCenter:TpvVector3;const pRadius:TpvScalar); overload;
       constructor Create(const aVector:TpvVector4); overload;
       constructor CreateFromAABB(const ppvAABB:TpvAABB);
       constructor CreateFromFrustum(const zNear,zFar,FOV,AspectRatio:TpvScalar;const Position,Direction:TpvVector3);
       function ToVector4:TpvVector4;
       function ToAABB(const pScale:TpvScalar=1.0):TpvAABB;
       function Cull(const p:array of TpvPlane):boolean;
       function Contains(const b:TpvSphere):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Contains(const v:TpvVector3):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function DistanceTo(const b:TpvSphere):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function DistanceTo(const b:TpvVector3):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Intersect(const b:TpvSphere):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Intersect(const b:TpvAABB):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function FastRayIntersection(const Origin,Direction:TpvVector3):boolean;
       function RayIntersection(const Origin,Direction:TpvVector3;out Time:TpvScalar):boolean;
       function Extends(const WithSphere:TpvSphere):TpvSphere; {$ifdef CAN_INLINE}inline;{$endif}
       function Transform(const Transform:TpvMatrix4x4):TpvSphere; {$ifdef CAN_INLINE}inline;{$endif}
       function TriangleIntersection(const Triangle:TpvTriangle;out Position,Normal:TpvVector3;out Depth:TpvScalar):boolean; overload;
       function TriangleIntersection(const SegmentTriangle:TpvSegmentTriangle;const TriangleNormal:TpvVector3;out Position,Normal:TpvVector3;out Depth:TpvScalar):boolean; overload;
       function SweptIntersection(const SphereB:TpvSphere;const VelocityA,VelocityB:TpvVector3;out TimeFirst,TimeLast:TpvScalar):boolean; {$ifdef CAN_INLINE}inline;{$endif}
      public
       case TpvUInt8 of
        0:(
         Center:TpvVector3;
        );
        1:(
         x:TpvScalar;
         y:TpvScalar;
         z:TpvScalar;
         Radius:TpvScalar;
        );
        2:(
         Vector4:TpvVector4;
        );
     end;

     PpvSpheres=^TpvSpheres;
     TpvSpheres=array[0..65535] of TpvSphere;

     TpvSphereDynamicArray=array of TpvSphere;
     PpvSphereDynamicArray=^TpvSphereDynamicArray;

     PpvCapsule=^TpvCapsule;
     TpvCapsule=packed record
      LineStartPoint:TpvVector3;
      LineEndPoint:TpvVector3;
      Radius:TpvScalar;
     end;

     PpvMinkowskiDescription=^TpvMinkowskiDescription;
     TpvMinkowskiDescription=record
      public
       HalfAxis:TpvVector4;
       Position_LM:TpvVector3;
     end;

     PpvSphereCoords=^TpvSphereCoords;
     TpvSphereCoords=record
      public
       Radius:TpvScalar;
       Theta:TpvScalar;
       Phi:TpvScalar;
       constructor CreateFromCartesianVector(const v:TpvVector3); overload;
       constructor CreateFromCartesianVector(const v:TpvVector4); overload;
       function ToCartesianVector:TpvVector3;
     end;

     PpvRect=^TpvRect;
     TpvRect=packed record
      private
       function GetWidth:TpvFloat; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetWidth(const aWidth:TpvFloat); {$ifdef CAN_INLINE}inline;{$endif}
       function GetHeight:TpvFloat; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetHeight(const aHeight:TpvFloat); {$ifdef CAN_INLINE}inline;{$endif}
       function GetSize:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       procedure SetSize(const aSize:TpvVector2); {$ifdef CAN_INLINE}inline;{$endif}
      public
       constructor CreateFromVkRect2D(const aFrom:TVkRect2D); overload;
       constructor CreateAbsolute(const aLeft,aTop,aRight,aBottom:TpvFloat); overload;
       constructor CreateAbsolute(const aLeftTop,aRightBottom:TpvVector2); overload;
       constructor CreateRelative(const aLeft,aTop,aWidth,aHeight:TpvFloat); overload;
       constructor CreateRelative(const aLeftTop,aSize:TpvVector2); overload;
       class operator Implicit(const a:TVkRect2D):TpvRect; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Explicit(const a:TVkRect2D):TpvRect; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Implicit(const a:TpvRect):TVkRect2D; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Explicit(const a:TpvRect):TVkRect2D; {$ifdef CAN_INLINE}inline;{$endif}
       class operator Equal(const a,b:TpvRect):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class operator NotEqual(const a,b:TpvRect):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       function ToVkRect2D:TVkRect2D; {$ifdef CAN_INLINE}inline;{$endif}
       function Cost:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Area:TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
       function Center:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
       function Combine(const aWithRect:TpvRect):TpvRect; overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Combine(const aWithPoint:TpvVector2):TpvRect; overload; {$ifdef CAN_INLINE}inline;{$endif}
       procedure DirectCombine(const aWithRect:TpvRect); overload; {$ifdef CAN_INLINE}inline;{$endif}
       procedure DirectCombine(const aWithPoint:TpvVector2); overload; {$ifdef CAN_INLINE}inline;{$endif}
       function Intersect(const aWithRect:TpvRect;Threshold:TpvScalar=EPSILON):boolean; overload;// {$ifdef CAN_INLINE}inline;{$endif}
       function Contains(const aWithRect:TpvRect;Threshold:TpvScalar=EPSILON):boolean; overload;// {$ifdef CAN_INLINE}inline;{$endif}
       function GetIntersection(const WithAABB:TpvRect):TpvRect; {$ifdef CAN_INLINE}inline;{$endif}
       function Touched(const aPosition:TpvVector2;Threshold:TpvScalar=EPSILON):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       property Width:TpvFloat read GetWidth write SetWidth;
       property Height:TpvFloat read GetHeight write SetHeight;
       property Size:TpvVector2 read GetSize write SetSize;
      public
       case TpvInt32 of
        0:(
         Left:TpvFloat;
         Top:TpvFloat;
         Right:TpvFloat;
         Bottom:TpvFloat;
        );
        1:(
         MinX:TpvFloat;
         MinY:TpvFloat;
         MaxX:TpvFloat;
         MaxY:TpvFloat;
        );
        2:(
         LeftTop:TpvVector2;
         RightBottom:TpvVector2;
        );
        3:(
         Min:TpvVector2;
         Max:TpvVector2;
        );
        4:(
         Offset:TpvVector2;
        );
        5:(
         Vector4:TpvVector4;
        );
        6:(
         AxisComponents:array[0..1,0..1] of TpvFloat;
        );
        7:(
         Components:array[0..3] of TpvFloat;
        );
        8:(
         MinMax:array[0..1] of TpvVector2;
        );
     end;

     TpvRectArray=array of TpvRect;

     PpvAABB2D=^TpvAABB2D;
     TpvAABB2D=TpvRect;

     Vec2=TpvVector2;

     Vec3=TpvVector3;

     Vec4=TpvVector4;

     Mat2=TpvMatrix2x2;

     Mat3=TpvMatrix3x3;

     Mat4=TpvMatrix4x4;

     TpvMathPropertyOnChange=procedure(const aSender:TObject) of object;

     TpvVector2Property=class(TPersistent)
      private
       fVector:PpvVector2;
       fOnChange:TpvMathPropertyOnChange;
       function GetX:TpvScalar;
       function GetY:TpvScalar;
       function GetVector:TpvVector2;
       procedure SetX(const aNewValue:TpvScalar);
       procedure SetY(const aNewValue:TpvScalar);
       procedure SetVector(const aNewVector:TpvVector2);
      public
       constructor Create(const aVector:PpvVector2);
       destructor Destroy; override;
       property OnChange:TpvMathPropertyOnChange read fOnChange write fOnChange;
       property Vector:TpvVector2 read GetVector write SetVector;
      published
       property x:TpvScalar read GetX write SetX;
       property y:TpvScalar read GetY write SetY;
     end;

     TpvVector3Property=class(TPersistent)
      private
       fVector:PpvVector3;
       fOnChange:TpvMathPropertyOnChange;
       function GetX:TpvScalar;
       function GetY:TpvScalar;
       function GetZ:TpvScalar;
       function GetVector:TpvVector3;
       procedure SetX(const aNewValue:TpvScalar);
       procedure SetY(const aNewValue:TpvScalar);
       procedure SetZ(const aNewValue:TpvScalar);
       procedure SetVector(const aNewVector:TpvVector3);
      public
       constructor Create(const aVector:PpvVector3);
       destructor Destroy; override;
       property OnChange:TpvMathPropertyOnChange read fOnChange write fOnChange;
       property Vector:TpvVector3 read GetVector write SetVector;
      published
       property x:TpvScalar read GetX write SetX;
       property y:TpvScalar read GetY write SetY;
       property z:TpvScalar read GetZ write SetZ;
     end;

     TpvVector4Property=class(TPersistent)
      private
       fVector:PpvVector4;
       fOnChange:TpvMathPropertyOnChange;
       function GetX:TpvScalar;
       function GetY:TpvScalar;
       function GetZ:TpvScalar;
       function GetW:TpvScalar;
       function GetVector:TpvVector4;
       procedure SetX(const aNewValue:TpvScalar);
       procedure SetY(const aNewValue:TpvScalar);
       procedure SetZ(const aNewValue:TpvScalar);
       procedure SetW(const aNewValue:TpvScalar);
       procedure SetVector(const aNewVector:TpvVector4);
      public
       constructor Create(const aVector:PpvVector4);
       destructor Destroy; override;
       property OnChange:TpvMathPropertyOnChange read fOnChange write fOnChange;
       property Vector:TpvVector4 read GetVector write SetVector;
      published
       property x:TpvScalar read GetX write SetX;
       property y:TpvScalar read GetY write SetY;
       property z:TpvScalar read GetZ write SetZ;
       property w:TpvScalar read GetW write SetW;
     end;

     TpvQuaternionProperty=class(TPersistent)
      private
       fQuaternion:PpvQuaternion;
       fOnChange:TpvMathPropertyOnChange;
       function GetX:TpvScalar;
       function GetY:TpvScalar;
       function GetZ:TpvScalar;
       function GetW:TpvScalar;
       function GetQuaternion:TpvQuaternion;
       procedure SetX(const aNewValue:TpvScalar);
       procedure SetY(const aNewValue:TpvScalar);
       procedure SetZ(const aNewValue:TpvScalar);
       procedure SetW(const aNewValue:TpvScalar);
       procedure SetQuaternion(const aNewQuaternion:TpvQuaternion);
      public
       constructor Create(const AQuaternion:PpvQuaternion);
       destructor Destroy; override;
       property OnChange:TpvMathPropertyOnChange read fOnChange write fOnChange;
       property Quaternion:TpvQuaternion read GetQuaternion write SetQuaternion;
      published
       property x:TpvScalar read GetX write SetX;
       property y:TpvScalar read GetY write SetY;
       property z:TpvScalar read GetZ write SetZ;
       property w:TpvScalar read GetW write SetW;
     end;

     TpvAngleProperty=class(TPersistent)
      private
       fRadianAngle:PpvScalar;
       fOnChange:TpvMathPropertyOnChange;
       function GetAngle:TpvScalar;
       function GetRadianAngle:TpvScalar;
       procedure SetAngle(const aNewValue:TpvScalar);
       procedure SetRadianAngle(const aNewValue:TpvScalar);
      public
       constructor Create(const aRadianAngle:PpvScalar);
       destructor Destroy; override;
       property OnChange:TpvMathPropertyOnChange read fOnChange write fOnChange;
       property RadianAngle:TpvScalar read GetRadianAngle write SetRadianAngle;
      published
       property Angle:TpvScalar read GetAngle write SetAngle;
     end;

     TpvRotation3DProperty=class(TPersistent)
      private
       fQuaternion:PpvQuaternion;
       fOnChange:TpvMathPropertyOnChange;
       function GetX:TpvScalar;
       function GetY:TpvScalar;
       function GetZ:TpvScalar;
       function GetW:TpvScalar;
       function GetPitch:TpvScalar;
       function GetYaw:TpvScalar;
       function GetRoll:TpvScalar;
       function GetQuaternion:TpvQuaternion;
       procedure SetX(const aNewValue:TpvScalar);
       procedure SetY(const aNewValue:TpvScalar);
       procedure SetZ(const aNewValue:TpvScalar);
       procedure SetW(const aNewValue:TpvScalar);
       procedure SetPitch(const aNewValue:TpvScalar);
       procedure SetYaw(const aNewValue:TpvScalar);
       procedure SetRoll(const aNewValue:TpvScalar);
       procedure SetQuaternion(const aNewQuaternion:TpvQuaternion);
      public
       constructor Create(const AQuaternion:PpvQuaternion);
       destructor Destroy; override;
       property OnChange:TpvMathPropertyOnChange read fOnChange write fOnChange;
       property x:TpvScalar read GetX write SetX;
       property y:TpvScalar read GetY write SetY;
       property z:TpvScalar read GetZ write SetZ;
       property w:TpvScalar read GetW write SetW;
       property Quaternion:TpvQuaternion read GetQuaternion write SetQuaternion;
      published
       property Pitch:TpvScalar read GetPitch write SetPitch;
       property Yaw:TpvScalar read GetYaw write SetYaw;
       property Roll:TpvScalar read GetRoll write SetRoll;
     end;

     TpvColorRGBProperty=class(TPersistent)
      private
       fVector:PpvVector3;
       fOnChange:TpvMathPropertyOnChange;
       function GetR:TpvScalar;
       function GetG:TpvScalar;
       function GetB:TpvScalar;
       function GetVector:TpvVector3;
       procedure SetR(const aNewValue:TpvScalar);
       procedure SetG(const aNewValue:TpvScalar);
       procedure SetB(const aNewValue:TpvScalar);
       procedure SetVector(const aNewVector:TpvVector3);
      public
       constructor Create(const aVector:PpvVector3);
       destructor Destroy; override;
       property OnChange:TpvMathPropertyOnChange read fOnChange write fOnChange;
       property Vector:TpvVector3 read GetVector write SetVector;
      published
       property r:TpvScalar read GetR write SetR;
       property g:TpvScalar read GetG write SetG;
       property b:TpvScalar read GetB write SetB;
     end;

     TpvColorRGBAProperty=class(TPersistent)
      private
       fVector:PpvVector4;
       fOnChange:TpvMathPropertyOnChange;
       function GetR:TpvScalar;
       function GetG:TpvScalar;
       function GetB:TpvScalar;
       function GetA:TpvScalar;
       function GetVector:TpvVector4;
       procedure SetR(const aNewValue:TpvScalar);
       procedure SetG(const aNewValue:TpvScalar);
       procedure SetB(const aNewValue:TpvScalar);
       procedure SetA(const aNewValue:TpvScalar);
       procedure SetVector(const aNewVector:TpvVector4);
      public
       constructor Create(const aVector:PpvVector4);
       destructor Destroy; override;
       property OnChange:TpvMathPropertyOnChange read fOnChange write fOnChange;
       property Vector:TpvVector4 read GetVector write SetVector;
      published
       property r:TpvScalar read GetR write SetR;
       property g:TpvScalar read GetG write SetG;
       property b:TpvScalar read GetB write SetB;
       property a:TpvScalar read GetA write SetA;
     end;

     TpvPolynomial=record
      public
       Coefs:TpvDoubleDynamicArray;
       constructor Create(const aCoefs:array of TpvDouble);
       function GetDegree:TpvSizeInt;
       function Eval(const aValue:TpvDouble):TpvDouble;
       procedure SimplifyEquals(const aThreshold:TpvDouble=1e-12);
       function GetDerivative:TpvPolynomial;
       function GetLinearRoots:TpvDoubleDynamicArray;
       function GetQuadraticRoots:TpvDoubleDynamicArray;
       function GetCubicRoots:TpvDoubleDynamicArray;
       function GetQuarticRoots:TpvDoubleDynamicArray;
       function GetRoots:TpvDoubleDynamicArray;
       function Bisection(aMin,aMax:TpvDouble;out aResult:TpvDouble):Boolean;
       function GetRootsInInterval(const aMin,aMax:TpvDouble):TpvDoubleDynamicArray;
     end;

     PpvPolynomial=^TpvPolynomial;

function RoundDownToPowerOfTwo(x:TpvUInt32):TpvUInt32; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
function RoundDownToPowerOfTwo64(x:TpvUInt64):TpvUInt64; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
function RoundDownToPowerOfTwoSizeUInt(x:TpvSizeUInt):TpvSizeUInt; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}

function RoundUpToPowerOfTwo(x:TpvUInt32):TpvUInt32; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
function RoundUpToPowerOfTwo64(x:TpvUInt64):TpvUInt64; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
function RoundUpToPowerOfTwoSizeUInt(x:TpvSizeUInt):TpvSizeUInt; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}

function RoundNearestToPowerOfTwo(x:TpvUInt32):TpvUInt32; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
function RoundNearestToPowerOfTwo64(x:TpvUInt64):TpvUInt64; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
function RoundNearestToPowerOfTwoSizeUInt(x:TpvSizeUInt):TpvSizeUInt; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}

function RoundUp(x,y:TpvUInt32):TpvUInt32; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
function RoundUp64(x,y:TpvUInt64):TpvUInt64; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
function RoundUpSizeUInt(x,y:TpvSizeUInt):TpvSizeUInt; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}

function IntLog2(x:TpvUInt32):TpvUInt32; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
function IntLog264(x:TpvUInt64):TpvUInt32; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}

function Modulo(x,y:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
function ModuloPos(x,y:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
function IEEERemainder(x,y:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
function Modulus(x,y:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}

function CastFloatToUInt32(const v:TpvFloat):TpvUInt32; {$ifdef CAN_INLINE}inline;{$endif}
function CastUInt32ToFloat(const v:TpvUInt32):TpvFloat; {$ifdef CAN_INLINE}inline;{$endif}

function SignNonZero(const v:TpvFloat):TpvInt32; {$ifdef CAN_INLINE}inline;{$endif}

function Determinant4x4(const v0,v1,v2,v3:TpvVector4):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
function OldSolveQuadraticRoots(const a,b,c:TpvScalar;out t0,t1:TpvScalar):boolean;
function SolveQuadraticRoots(const a,b,c:TpvScalar;out t0,t1:TpvScalar):boolean;
function LinearPolynomialRoot(const a,b:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
function QuadraticPolynomialRoot(const a,b,c:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
function CubicPolynomialRoot(const a,b,c,d:TpvScalar):TpvScalar;

function FloatLerp(const aV1,aV2,aTime:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
function DoubleLerp(const aV1,aV2,aTime:TpvDouble):TpvDouble; {$ifdef CAN_INLINE}inline;{$endif}

function Exp2(const aValue:TpvDouble):TpvDouble; {$ifdef CAN_INLINE}inline;{$endif}

function Cross(const a,b:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Cross(const a,b:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Cross(const a,b:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function Dot(const a,b:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Dot(const a,b:TpvVector2):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Dot(const a,b:TpvVector3):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Dot(const a,b:TpvVector4):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}

function Len(const a:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Len(const a:TpvVector2):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Len(const a:TpvVector3):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Len(const a:TpvVector4):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}

function Normalize(const a:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Normalize(const a:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Normalize(const a:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Normalize(const a:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function Minimum(const a,b:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Minimum(const a,b:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Minimum(const a,b:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Minimum(const a,b:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function Maximum(const a,b:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Maximum(const a,b:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Maximum(const a,b:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Maximum(const a,b:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function Pow(const a,b:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Pow(const a,b:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Pow(const a,b:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Pow(const a,b:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function FaceForward(const N,I:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function FaceForward(const N,I:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function FaceForward(const N,I:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function FaceForward(const N,I:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function FaceForward(const N,I,Nref:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function FaceForward(const N,I,Nref:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function FaceForward(const N,I,Nref:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function FaceForward(const N,I,Nref:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function Reflect(const I,N:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Reflect(const I,N:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Reflect(const I,N:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Reflect(const I,N:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function Refract(const I,N:TpvScalar;const Eta:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Refract(const I,N:TpvVector2;const Eta:TpvScalar):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Refract(const I,N:TpvVector3;const Eta:TpvScalar):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Refract(const I,N:TpvVector4;const Eta:TpvScalar):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function Clamp(const Value,MinValue,MaxValue:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Clamp(const Value,MinValue,MaxValue:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Clamp(const Value,MinValue,MaxValue:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Clamp(const Value,MinValue,MaxValue:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function Mix(const a,b,t:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Mix(const a,b,t:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Mix(const a,b,t:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Mix(const a,b,t:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function Step(const Edge,Value:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Step(const Edge,Value:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Step(const Edge,Value:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function Step(const Edge,Value:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function NearestStep(const Edge0,Edge1,Value:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function NearestStep(const Edge0,Edge1,Value:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function NearestStep(const Edge0,Edge1,Value:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function NearestStep(const Edge0,Edge1,Value:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function LinearStep(const Edge0,Edge1,Value:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function LinearStep(const Edge0,Edge1,Value:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function LinearStep(const Edge0,Edge1,Value:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function LinearStep(const Edge0,Edge1,Value:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function SmoothStep(const Edge0,Edge1,Value:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function SmoothStep(const Edge0,Edge1,Value:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function SmoothStep(const Edge0,Edge1,Value:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function SmoothStep(const Edge0,Edge1,Value:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function SmootherStep(const Edge0,Edge1,Value:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function SmootherStep(const Edge0,Edge1,Value:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function SmootherStep(const Edge0,Edge1,Value:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function SmootherStep(const Edge0,Edge1,Value:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function SmoothestStep(const Edge0,Edge1,Value:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function SmoothestStep(const Edge0,Edge1,Value:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function SmoothestStep(const Edge0,Edge1,Value:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function SmoothestStep(const Edge0,Edge1,Value:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

function SuperSmoothestStep(const Edge0,Edge1,Value:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
function SuperSmoothestStep(const Edge0,Edge1,Value:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
function SuperSmoothestStep(const Edge0,Edge1,Value:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
function SuperSmoothestStep(const Edge0,Edge1,Value:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}

procedure DoCalculateInterval(const Vertices:PpvVector3Array;const Count:TpvInt32;const Axis:TpvVector3;out OutMin,OutMax:TpvScalar);
function DoSpanIntersect(const Vertices1:PpvVector3Array;const Count1:TpvInt32;const Vertices2:PpvVector3Array;const Count2:TpvInt32;const AxisTest:TpvVector3;out AxisPenetration:TpvVector3):TpvScalar;

function BoxGetDistanceToPoint(Point:TpvVector3;const Center,Size:TpvVector3;const InvTransformMatrix,TransformMatrix:TpvMatrix4x4;var ClosestBoxPoint:TpvVector3):TpvScalar;
function GetDistanceFromLine(const p0,p1,p:TpvVector3;var Projected:TpvVector3;const Time:PpvScalar=nil):TpvScalar;
procedure LineClosestApproach(const pa,ua,pb,ub:TpvVector3;var Alpha,Beta:TpvScalar);
procedure ClosestLineBoxPoints(const p1,p2,c:TpvVector3;const ir,r:TpvMatrix4x4;const side:TpvVector3;var lret,bret:TpvVector3);
procedure ClosestLineSegmentPoints(const a0,a1,b0,b1:TpvVector3;var cp0,cp1:TpvVector3);
function LineSegmentIntersection(const a0,a1,b0,b1:TpvVector3;const p:PpvVector3=nil):boolean;
function LineLineIntersection(const a0,a1,b0,b1:TpvVector3;const pa:PpvVector3=nil;const pb:PpvVector3=nil;const ta:PpvScalar=nil;const tb:PpvScalar=nil):boolean;

function IsPointsSameSide(const p0,p1,Origin,Direction:TpvVector3):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}

function PointInTriangle(const p0,p1,p2,Normal,p:TpvVector3):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
function PointInTriangle(const p0,p1,p2,p:TpvVector3):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}

function GetOverlap(const MinA,MaxA,MinB,MaxB:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}

function OldTriangleTriangleIntersection(const a0,a1,a2,b0,b1,b2:TpvVector3):boolean;
function TriangleTriangleIntersection(const v0,v1,v2,u0,u1,u2:TpvVector3):boolean;

function UnclampedClosestPointToLine(const LineStartPoint,LineEndPoint,Point:TpvVector3;const ClosestPointOnLine:PpvVector3=nil;const Time:PpvScalar=nil):TpvScalar;
function ClosestPointToLine(const LineStartPoint,LineEndPoint,Point:TpvVector3;const ClosestPointOnLine:PpvVector3=nil;const Time:PpvScalar=nil):TpvScalar;
function ClosestPointToRect(const Rect:TpvRect;const Point:TpvVector2;const ClosestPointOnRect:PpvVector2=nil):TpvScalar; //{$ifdef CAN_INLINE}inline;{$endif}
function ClosestPointToAABB(const AABB:TpvAABB;const Point:TpvVector3;const ClosestPointOnAABB:PpvVector3=nil):TpvScalar; //{$ifdef CAN_INLINE}inline;{$endif}
function ClosestPointToOBB(const OBB:TpvOBB;const Point:TpvVector3;out ClosestPoint:TpvVector3):TpvScalar; //{$ifdef CAN_INLINE}inline;{$endif}
function ClosestPointToSphere(const Sphere:TpvSphere;const Point:TpvVector3;out ClosestPoint:TpvVector3):TpvScalar; //{$ifdef CAN_INLINE}inline;{$endif}
function ClosestPointToCapsule(const Capsule:TpvCapsule;const Point:TpvVector3;out ClosestPoint:TpvVector3;const Time:PpvScalar=nil):TpvScalar; //{$ifdef CAN_INLINE}inline;{$endif}
function ClosestPointToTriangle(const a,b,c,p:TpvVector3;out ClosestPoint:TpvVector3):TpvScalar;

function SquaredDistanceFromPointToAABB(const AABB:TpvAABB;const Point:TpvVector3):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}

function SquaredDistanceFromPointToTriangle(const p,a,b,c:TpvVector3):TpvScalar;

function IsParallel(const a,b:TpvVector3;const Tolerance:TpvScalar=1e-5):boolean; {$ifdef CAN_INLINE}inline;{$endif}

function Vector3ToAnglesLDX(v:TpvVector3):TpvVector3;

procedure AnglesToVector3LDX(const Angles:TpvVector3;var ForwardVector,RightVector,UpVector:TpvVector3);

function UnsignedAngle(const v0,v1:TpvVector3):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}

function AngleDegClamp(a:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
function AngleDegDiff(a,b:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}

function AngleClamp(a:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
function AngleDiff(a,b:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
function AngleLerp(a,b,x:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}

function UnitTimeClamp(a:TpvDouble):TpvDouble;
function UnitTimeDiff(a,b:TpvDouble;const aBackwards:boolean):TpvDouble;
function UnitTimeLerp(a,b,x:TpvDouble;const aBackwards:boolean):TpvDouble; overload;
function UnitTimeLerp(a,b,x:TpvDouble):TpvDouble; overload;

function NonUnitTimeLerp(a,b,x:TpvDouble):TpvDouble;

function InertiaTensorTransform(const Inertia,Transform:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
function InertiaTensorParallelAxisTheorem(const Center:TpvVector3;const Mass:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}

procedure OrthoNormalize(var Tangent,Bitangent,Normal:TpvVector3);

procedure RobustOrthoNormalize(var Tangent,Bitangent,Normal:TpvVector3;const Tolerance:TpvScalar=1e-3);

function MaxOverlaps(const Min1,Max1,Min2,Max2:TpvScalar;var LowerLim,UpperLim:TpvScalar):boolean;

function GetHaltonSequence(const aIndex,aPrimeBase:TpvUInt32):TpvDouble;

function PackFP32FloatToM6E5Float(const pValue:TpvFloat):TpvUInt32;
function PackFP32FloatToM5E5Float(const pValue:TpvFloat):TpvUInt32;
function Float32ToFloat11(const pValue:TpvFloat):TpvUInt32;
function Float32ToFloat10(const pValue:TpvFloat):TpvUInt32;

function ConvertRGB32FToRGB9E5(r,g,b:TpvFloat):TpvUInt32;
function ConvertRGB32FToR11FG11FB10F(const r,g,b:TpvFloat):TpvUInt32; {$ifdef CAN_INLINE}inline;{$endif}

function EncodeAsRGB10A2UNorm(const aVector:TpvVector4):TpvUInt32;
function DecodeFromRGB10A2UNorm(const aValue:TpvUInt32):TpvVector4;

function EncodeAsRGB10A2SNorm(const aVector:TpvVector4):TpvUInt32;
function DecodeFromRGB10A2SNorm(const aValue:TpvUInt32):TpvVector4;

function PackInt8TangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvInt8PackedTangentSpace;
procedure UnpackInt8TangentSpace(const aPackedTangentSpace:TpvInt8PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);

function PackInt16TangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvInt16PackedTangentSpace;
procedure UnpackInt16TangentSpace(const aPackedTangentSpace:TpvInt16PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);

function PackInt8QTangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvInt8PackedTangentSpace;
procedure UnpackInt8QTangentSpace(const aPackedTangentSpace:TpvInt8PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);

function PackInt16QTangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvInt16PackedTangentSpace;
procedure UnpackInt16QTangentSpace(const aPackedTangentSpace:TpvInt16PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);

function PackUInt8TangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvUInt8PackedTangentSpace;
procedure UnpackUInt8TangentSpace(const aPackedTangentSpace:TpvUInt8PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);

function PackUInt16TangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvUInt16PackedTangentSpace;
procedure UnpackUInt16TangentSpace(const aPackedTangentSpace:TpvUInt16PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);

function PackUInt8QTangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvUInt8PackedTangentSpace;
procedure UnpackUInt8QTangentSpace(const aPackedTangentSpace:TpvUInt8PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);

function PackUInt16QTangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvUInt16PackedTangentSpace;
procedure UnpackUInt16QTangentSpace(const aPackedTangentSpace:TpvUInt16PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);

function ConvertLinearToSRGB(const aColor:TpvFloat):TpvFloat; overload;
function ConvertLinearToSRGB(const aColor:TpvVector3):TpvVector3; overload;
function ConvertLinearToSRGB(const aColor:TpvVector4):TpvVector4; overload;
function ConvertSRGBToLinear(const aColor:TpvFloat):TpvFloat; overload;
function ConvertSRGBToLinear(const aColor:TpvVector3):TpvVector3; overload;
function ConvertSRGBToLinear(const aColor:TpvVector4):TpvVector4; overload;

function ConvertHSVToRGB(const aHSV:TpvVector3):TpvVector3;
function ConvertRGBToHSV(const aRGB:TpvVector3):TpvVector3;

function SolveQuadratic(const a,b,c:TpvDouble;out r0,r1:TpvDouble):TpvSizeInt;
function SolveCubic(const a,b,c,d:TpvDouble;out r0,r1,r2:TpvDouble):TpvSizeInt;
function SolveQuartic(const a,b,c,d,e:TpvDouble;out r0,r1,r2,r3:TpvDouble):TpvSizeInt;
function SolveRootsInInterval(const aCoefs:array of TpvDouble;const aMin,aMax:TpvDouble):TpvDoubleDynamicArray;

function EncodeNormalAsUInt32(const aNormal:TpvVector3):TpvUInt32;
function DecodeNormalFromUInt32(const aNormal:TpvUInt32):TpvVector3;

function OctahedralProjectionMappingEncode(const aVector:TpvVector3):TpvVector2;
function OctahedralProjectionMappingDecode(const aVector:TpvVector2):TpvVector3;

function OctahedralProjectionMappingSignedEncode(const aVector:TpvVector3):TpvVector2;
function OctahedralProjectionMappingSignedDecode(const aVector:TpvVector2):TpvVector3;

function OctEncode(const aVector:TpvVector3;const aFloorX,aFloorY:Boolean):TpvInt16Vector2; overload;
function OctDecode(const aOct:TpvInt16Vector2):TpvVector3;
function OctEncode(const aVector:TpvVector3):TpvInt16Vector2; overload;

function EncodeDiamondUnsigned(const aVector:TpvVector2):TpvScalar;
function DecodeDiamondUnsigned(const aValue:TpvScalar):TpvVector2;

function EncodeDiamondSigned(const aVector:TpvVector2):TpvScalar;
function DecodeDiamondSigned(const aValue:TpvScalar):TpvVector2;

function EncodeTangentSpaceAsRGB10A2SNorm(const aTangent,aBitangent,aNormal:TpvVector3):TpvUInt32; overload;
function EncodeTangentSpaceAsRGB10A2SNorm(const aMatrix:TpvMatrix3x3):TpvUInt32; overload;

procedure DecodeTangentSpaceFromRGB10A2SNorm(const aValue:TpvUInt32;out aTangent,aBitangent,aNormal:TpvVector3); overload;
procedure DecodeTangentSpaceFromRGB10A2SNorm(const aValue:TpvUInt32;out aMatrix3x3:TpvMatrix3x3); overload;

function EncodeQTangentUI32(const aTangent,aBitangent:TpvVector3;aNormal:TpvVector3):TpvUInt32; overload;
function EncodeQTangentUI32(const aMatrix:TpvMatrix3x3):TpvUInt32; overload;
function EncodeQTangentUI32(const aMatrix:TpvMatrix4x4):TpvUInt32; overload;

procedure DecodeQTangentUI32Vectors(const aValue:TpvUInt32;out aTangent,aBitangent,aNormal:TpvVector3);

function DecodeQTangentUI32(const aValue:TpvUInt32):TpvMatrix3x3;

function TessellateTriangle(const aIndex,aResolution:TpvSizeInt;const aInputVertices:PpvVector3Array;const aOutputVertices:PpvVector3Array):TpvMatrix3x3;
function IndirectTessellateTriangle(const aIndex,aResolution:TpvSizeInt;const aInputVertices:PPpvVector3Array;const aOutputVertices:PPpvVector3Array):TpvMatrix3x3;

function EaseInSine(x:TpvScalar):TpvScalar;
function EaseOutSine(x:TpvScalar):TpvScalar;
function EaseInOutSine(x:TpvScalar):TpvScalar;

function EaseInQuad(x:TpvScalar):TpvScalar;
function EaseOutQuad(x:TpvScalar):TpvScalar;
function EaseInOutQuad(x:TpvScalar):TpvScalar;

function EaseInCubic(x:TpvScalar):TpvScalar;
function EaseOutCubic(x:TpvScalar):TpvScalar;
function EaseInOutCubic(x:TpvScalar):TpvScalar;

function EaseInQuart(x:TpvScalar):TpvScalar;
function EaseOutQuart(x:TpvScalar):TpvScalar;
function EaseInOutQuart(x:TpvScalar):TpvScalar;

function EaseInQuint(x:TpvScalar):TpvScalar;
function EaseOutQuint(x:TpvScalar):TpvScalar;
function EaseInOutQuint(x:TpvScalar):TpvScalar;

function EaseInExpo(x:TpvScalar):TpvScalar;
function EaseOutExpo(x:TpvScalar):TpvScalar;
function EaseInOutExpo(x:TpvScalar):TpvScalar;

function EaseInCircle(x:TpvScalar):TpvScalar;
function EaseOutCircle(x:TpvScalar):TpvScalar;
function EaseInOutCircle(x:TpvScalar):TpvScalar;

function EaseInBack(x:TpvScalar):TpvScalar;
function EaseOutBack(x:TpvScalar):TpvScalar;
function EaseInOutBack(x:TpvScalar):TpvScalar;

function EaseInElastic(x:TpvScalar):TpvScalar;
function EaseOutElastic(x:TpvScalar):TpvScalar;
function EaseInOutElastic(x:TpvScalar):TpvScalar;

function EaseOutBounce(x:TpvScalar):TpvScalar;
function EaseInBounce(x:TpvScalar):TpvScalar;
function EaseInOutBounce(x:TpvScalar):TpvScalar;

function LerpEaseOutBounce(const aTime,aDuration,aMin,aMax:TpvScalar):TpvScalar;

implementation

function RoundDownToPowerOfTwo(x:TpvUInt32):TpvUInt32;
begin

 if x=0 then begin

  // Handle zero case
  result:=0;

 end else begin

  // / Propagate the highest bit to the right
  x:=x or (x shr 1);
  x:=x or (x shr 2);
  x:=x or (x shr 4);
  x:=x or (x shr 8);
  x:=x or (x shr 16);

  // Subtract half of the value to get the previous power of 2
  result:=x-(x shr 1);

 end;

end;

function RoundDownToPowerOfTwo64(x:TpvUInt64):TpvUInt64;
begin

 if x=0 then begin

  // Handle zero case
  result:=0;

 end else begin

  // / Propagate the highest bit to the right
  x:=x or (x shr 1);
  x:=x or (x shr 2);
  x:=x or (x shr 4);
  x:=x or (x shr 8);
  x:=x or (x shr 16);
  x:=x or (x shr 32);

  // Subtract half of the value to get the previous power of 2
  result:=x-(x shr 1);

 end;

end;

function RoundDownToPowerOfTwoSizeUInt(x:TpvSizeUInt):TpvSizeUInt;
begin

 if x=0 then begin

  // Handle zero case
  result:=0;

 end else begin

  // / Propagate the highest bit to the right
  x:=x or (x shr 1);
  x:=x or (x shr 2);
  x:=x or (x shr 4);
  x:=x or (x shr 8);
  x:=x or (x shr 16);
{$ifdef CPU64}
  x:=x or (x shr 32);
{$endif}

  // Subtract half of the value to get the previous power of 2
  result:=x-(x shr 1);

 end;

end;

function RoundUpToPowerOfTwo(x:TpvUInt32):TpvUInt32;
begin
 dec(x);
 x:=x or (x shr 1);
 x:=x or (x shr 2);
 x:=x or (x shr 4);
 x:=x or (x shr 8);
 x:=x or (x shr 16);
 result:=x+1;
end;

function RoundUpToPowerOfTwo64(x:TpvUInt64):TpvUInt64;
begin
 dec(x);
 x:=x or (x shr 1);
 x:=x or (x shr 2);
 x:=x or (x shr 4);
 x:=x or (x shr 8);
 x:=x or (x shr 16);
 x:=x or (x shr 32);
 result:=x+1;
end;

function RoundUpToPowerOfTwoSizeUInt(x:TpvSizeUInt):TpvSizeUInt;
begin
 dec(x);
 x:=x or (x shr 1);
 x:=x or (x shr 2);
 x:=x or (x shr 4);
 x:=x or (x shr 8);
 x:=x or (x shr 16);
{$ifdef CPU64}
 x:=x or (x shr 32);
{$endif}
 result:=x+1;
end;

function RoundNearestToPowerOfTwo(x:TpvUInt32):TpvUInt32; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
var a,b:TpvUInt32;
begin
 a:=RoundDownToPowerOfTwo(x);
 b:=RoundUpToPowerOfTwo(x);
 if (x-a)<(b-x) then begin
  result:=a;
 end else begin
  result:=b;
 end;
end;

function RoundNearestToPowerOfTwo64(x:TpvUInt64):TpvUInt64; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
var a,b:TpvUInt64;
begin
 a:=RoundDownToPowerOfTwo64(x);
 b:=RoundUpToPowerOfTwo64(x);
 if (x-a)<(b-x) then begin
  result:=a;
 end else begin
  result:=b;
 end;
end;

function RoundNearestToPowerOfTwoSizeUInt(x:TpvSizeUInt):TpvSizeUInt; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
var a,b:TpvUInt32;
begin
 a:=RoundDownToPowerOfTwoSizeUInt(x);
 b:=RoundUpToPowerOfTwoSizeUInt(x);
 if (x-a)<(b-x) then begin
  result:=a;
 end else begin
  result:=b;
 end;
end;

function RoundUp(x,y:TpvUInt32):TpvUInt32; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
var m:TpvUInt32;
begin
 m:=y-1;
 if (y and m)=0 then begin
  result:=(x+m) and not TpvUInt32(m);
 end else begin
  result:=((x+m) div y)*y;
 end;
end;

function RoundUp64(x,y:TpvUInt64):TpvUInt64; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
var m:TpvUInt64;
begin
 m:=y-1;
 if (y and m)=0 then begin
  result:=(x+m) and not TpvUInt64(m);
 end else begin
  result:=((x+m) div y)*y;
 end;
end;

function RoundUpSizeUInt(x,y:TpvSizeUInt):TpvSizeUInt; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
var m:TpvSizeUInt;
begin
 m:=y-1;
 if (y and m)=0 then begin
  result:=(x+m) and not TpvSizeUInt(m);
 end else begin
  result:=((x+m) div y)*y;
 end;
end;

function IntLog2(x:TpvUInt32):TpvUInt32; {$if defined(fpc)}{$ifdef CAN_INLINE}inline;{$endif}
begin
 if x<>0 then begin
  result:=BSRDWord(x);
 end else begin
  result:=0;
 end;
end;
{$elseif defined(cpu386)}
asm
 test eax,eax
 jz @Done
 bsr eax,eax
 @Done:
end;
{$elseif defined(cpux86_64)}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsr eax,ecx
{$else}
 bsr eax,edi
{$endif}
 jnz @Done
 xor eax,eax
@Done:
end;
{$else}
begin
 x:=x or (x shr 1);
 x:=x or (x shr 2);
 x:=x or (x shr 4);
 x:=x or (x shr 8);
 x:=x or (x shr 16);
 x:=x shr 1;
 dec(x,(x shr 1) and $55555555);
 x:=((x shr 2) and $33333333)+(x and $33333333);
 x:=((x shr 4)+x) and $0f0f0f0f;
 inc(x,x shr 8);
 inc(x,x shr 16);
 result:=x and $3f;
end;
{$ifend}

function IntLog264(x:TpvUInt64):TpvUInt32; {$if defined(fpc)}{$ifdef CAN_INLINE}inline;{$endif}
begin
 if x<>0 then begin
  result:=BSRQWord(x);
 end else begin
  result:=0;
 end;
end;
{$elseif defined(cpu386)}
asm
 bsr eax,dword ptr [x+4]
 jz @LowPart
 add eax,32
 jmp @Done
@LowPart:
 xor ecx,ecx
 bsr eax,dword ptr [x+0]
 jnz @Done
 xor eax,eax
@Done:
end;
{$elseif defined(cpux86_64)}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsr rax,rcx
{$else}
 bsr rax,rdi
{$endif}
 jnz @Done
 xor eax,eax
@Done:
end;
{$else}
begin
 x:=x or (x shr 1);
 x:=x or (x shr 2);
 x:=x or (x shr 4);
 x:=x or (x shr 8);
 x:=x or (x shr 16);
 x:=x or (x shr 32);
 x:=x shr 1;
 dec(x,(x shr 1) and $5555555555555555);
 x:=((x shr 2) and $3333333333333333)+(x and $3333333333333333);
 x:=((x shr 4)+x) and $0f0f0f0f0f0f0f0f;
 inc(x,x shr 8);
 inc(x,x shr 16);
 inc(x,x shr 32);
 result:=x and $7f;
end;
{$ifend}

{$if defined(fpc) and (defined(cpu386) or defined(cpux64) or defined(cpuamd64))}
// For to avoid "Fatal: Internal error 200604201" at the FreePascal compiler, when >= -O2 is used
function Sign(const aValue:TpvScalar):TpvInt32;
begin
 if aValue<0.0 then begin
  result:=-1;
 end else if aValue>0.0 then begin
  result:=1;
 end else begin
  result:=0;
 end;
end;
{$ifend}

function Modulo(x,y:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=x-(floor(x/y)*y);
end;

function ModuloPos(x,y:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
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

function IEEERemainder(x,y:TpvScalar):TpvScalar;
begin
 result:=x-(round(x/y)*y);
end;

function Modulus(x,y:TpvScalar):TpvScalar;
begin
 result:=(abs(x)-(abs(y)*(floor(abs(x)/abs(y)))))*Sign(x);
end;

function CastFloatToUInt32(const v:TpvFloat):TpvUInt32;
begin
 result:=PpvUInt32(Pointer(@v))^;
end;

function CastUInt32ToFloat(const v:TpvUInt32):TpvFloat;
begin
 result:=PpvFloat(Pointer(@v))^;
end;

function SignNonZero(const v:TpvFloat):TpvInt32;
begin
 result:=1-(TpvInt32(TpvUInt32(TpvUInt32(PpvUInt32(Pointer(@v))^) shr 31)) shl 1);
end;

function Determinant4x4(const v0,v1,v2,v3:TpvVector4):TpvScalar;
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

function OldSolveQuadraticRoots(const a,b,c:TpvScalar;out t0,t1:TpvScalar):boolean;
var a2,d,InverseDenominator:TpvScalar;
begin
 result:=false;
 d:=sqr(b)-(4.0*(a*c));
 if d<0.0 then begin
  exit;
 end else begin
  a2:=a*2.0;
  if abs(a2)<1e-7 then begin
   exit;
  end else begin
   InverseDenominator:=1.0/a2;
   if abs(d)<EPSILON then begin
    t0:=(-b)*InverseDenominator;
    t1:=t0;
   end else begin
    d:=sqrt(d);
    t0:=((-b)+d)*InverseDenominator;
    t1:=((-b)-d)*InverseDenominator;
    if t0>t1 then begin
     d:=t0;
     t0:=t1;
     t1:=d;
    end;
   end;
   result:=true;
  end;
 end;
end;

// The SolveQuadraticRoots function offers a significant improvement over the OldSolveQuadraticRoots
// function in terms of numerical stability and accuracy. In computing, especially for floating-point
// numbers, the representation and precision of real numbers are limited, which can lead to issues
// like loss of significance and catastrophic cancellation. This problem is particularly acute when
// dealing with values that are very close in magnitude but have opposite signs.
// The OldSolveQuadraticRoots function uses a direct approach to calculate the roots of the quadratic
// equation, which suffers from these numerical stability issues. Specifically, when 'b' and the
// square root of the discriminant ('d') in the quadratic formula have values close to each other
// but opposite in sign, it can lead to significant errors due to rounding and cancellation.
// The SolveQuadraticRoots function addresses this by using an alternative formulation:
// q = -0.5 * (b + sign(b) * sqrt(b^2 - 4ac))
// t0 = q / a
// t1 = c / q
// This approach ensures that the terms added to compute 'q' always have the same sign, thus avoiding
// the catastrophic cancellation that can occur in the OldSolveQuadraticRoots function. By doing so,
// SolveQuadraticRoots provides more reliable and accurate results, particularly in edge cases where
// precision is crucial.
function SolveQuadraticRoots(const a,b,c:TpvScalar;out t0,t1:TpvScalar):boolean;
var d,q,t:TpvScalar;
begin
 d:=sqr(b)-(4.0*(a*c));
 if d<0.0 then begin
  result:=false;
 end else begin
  if d=0.0 then begin
   t0:=((-0.5)*b)/a;
   t1:=t0;
  end else begin
   if b>0 then begin
    q:=(-0.5)*(b+sqrt(d));
   end else begin
    q:=(-0.5)*(b-sqrt(d));
   end;
   t0:=q/a;
   t1:=c/q;
   if t0>t1 then begin
    t:=t0;
    t0:=t1;
    t1:=t;
   end;
  end;
  result:=true;
 end;
end;

function LinearPolynomialRoot(const a,b:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if abs(a)>EPSILON then begin
  result:=-(b/a);
 end else begin
  result:=0.0;
 end;
end;

function QuadraticPolynomialRoot(const a,b,c:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
var d,InverseDenominator,t0,t1:TpvScalar;
begin
 if abs(a)>EPSILON then begin
  d:=sqr(b)-(4.0*(a*c));
  InverseDenominator:=1.0/(2.0*a);
  if d>=0.0 then begin
   if d<EPSILON then begin
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

function CubicPolynomialRoot(const a,b,c,d:TpvScalar):TpvScalar;
var f,g,h,hs,r,s,t,u,i,j,k,l,m,n,p,t0,t1,t2:TpvScalar;
begin
 if abs(a)>EPSILON then begin
  if abs(1.0-a)<EPSILON then begin
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

function FloatLerp(const aV1,aV2,aTime:TpvScalar):TpvScalar;
begin
 if aTime<0.0 then begin
  result:=aV1;
 end else if aTime>1.0 then begin
  result:=aV2;
 end else begin
  result:=(aV1*(1.0-aTime))+(aV2*aTime);
 end;
end;

function DoubleLerp(const aV1,aV2,aTime:TpvDouble):TpvDouble;
begin
 if aTime<0.0 then begin
  result:=aV1;
 end else if aTime>1.0 then begin
  result:=aV2;
 end else begin
  result:=(aV1*(1.0-aTime))+(aV2*aTime);
 end;
end;

{ TpvIntVector2 }

constructor TpvInt32Vector2.Create(const aX:TpvInt32);
begin
 x:=aX;
 y:=aX;
end;

constructor TpvInt32Vector2.Create(const aX,aY:TpvInt32);
begin
 x:=aX;
 y:=aY;
end;

class function TpvInt32Vector2.InlineableCreate(const aX:TpvInt32):TpvInt32Vector2;
begin
 result.x:=aX;
 result.y:=aX;
end;

class function TpvInt32Vector2.InlineableCreate(const aX,aY:TpvInt32):TpvInt32Vector2;
begin
 result.x:=aX;
 result.y:=aY;
end;

class operator TpvInt32Vector2.Implicit(const aScalar:TpvInt32):TpvInt32Vector2;
begin
 result.x:=aScalar;
 result.y:=aScalar;
end;

class operator TpvInt32Vector2.Explicit(const aScalar:TpvInt32):TpvInt32Vector2;
begin
 result.x:=aScalar;
 result.y:=aScalar;
end;

class operator TpvInt32Vector2.Equal(const aLeft,aRight:TpvInt32Vector2):boolean;
begin
 result:=(aLeft.x=aRight.x) and (aLeft.y=aRight.y);
end;

class operator TpvInt32Vector2.NotEqual(const aLeft,aRight:TpvInt32Vector2):boolean;
begin
 result:=(aLeft.x<>aRight.x) or (aLeft.y<>aRight.y);
end;

class operator TpvInt32Vector2.Add(const a,b:TpvInt32Vector2):TpvInt32Vector2;
begin
 result.x:=a.x+b.x;
 result.y:=a.y+b.y;
end;

class operator TpvInt32Vector2.Subtract(const a,b:TpvInt32Vector2):TpvInt32Vector2;
begin
 result.x:=a.x-b.x;
 result.y:=a.y-b.y;
end;

class operator TpvInt32Vector2.Negative(const aValue:TpvInt32Vector2):TpvInt32Vector2;
begin
 result.x:=-aValue.x;
 result.y:=-aValue.y;
end;

class operator TpvInt32Vector2.Positive(const aValue:TpvInt32Vector2):TpvInt32Vector2;
begin
 result.x:=aValue.x;
 result.y:=aValue.y;
end;

class operator TpvInt32Vector2.Multiply(const aLeft,aRight:TpvInt32Vector2):TpvInt32Vector2;
begin
 result.x:=aLeft.x*aRight.x;
 result.y:=aLeft.y*aRight.y;
end;

class operator TpvInt32Vector2.Multiply(const aLeft:TpvInt32Vector2;const aRight:TpvInt32):TpvInt32Vector2;
begin
 result.x:=aLeft.x*aRight;
 result.y:=aLeft.y*aRight;
end;

class operator TpvInt32Vector2.Multiply(const aLeft:TpvInt32;const aRight:TpvInt32Vector2):TpvInt32Vector2;
begin
 result.x:=aLeft*aRight.x;
 result.y:=aLeft*aRight.y;
end;

class operator TpvInt32Vector2.Divide(const aLeft,aRight:TpvInt32Vector2):TpvInt32Vector2;
begin
 if aRight.x<>0 then begin
  result.x:=aLeft.x div aRight.x;
 end else begin
  result.x:=0;
 end;
 if aRight.y<>0 then begin
  result.y:=aLeft.y div aRight.y;
 end else begin
  result.y:=0;
 end;
end;

class operator TpvInt32Vector2.Divide(const aLeft:TpvInt32Vector2;const aRight:TpvInt32):TpvInt32Vector2;
begin
 if aRight<>0 then begin
  result.x:=aLeft.x div aRight;
  result.y:=aLeft.y div aRight;
 end else begin
  result.x:=0;
  result.y:=0;
 end;
end;

class operator TpvInt32Vector2.Divide(const aLeft:TpvInt32;const aRight:TpvInt32Vector2):TpvInt32Vector2;
begin
 if aRight.x<>0 then begin
  result.x:=aLeft div aRight.x;
 end else begin
  result.x:=0;
 end;
 if aRight.y<>0 then begin
  result.y:=aLeft div aRight.y;
 end else begin
  result.y:=0;
 end;
end;

function TpvInt32Vector2.Length:TpvScalar;
begin
 result:=sqrt(sqr(x)+sqr(y));
end;

{ TpvVector2 }

constructor TpvVector2.Create(const aX:TpvScalar);
begin
 x:=aX;
 y:=aX;
end;

constructor TpvVector2.Create(const aX,aY:TpvScalar);
begin
 x:=aX;
 y:=aY;
end;

class function TpvVector2.InlineableCreate(const aX:TpvScalar):TpvVector2;
begin
 result.x:=aX;
 result.y:=aX;
end;

class function TpvVector2.InlineableCreate(const aX,aY:TpvScalar):TpvVector2;
begin
 result.x:=aX;
 result.y:=aY;
end;

class operator TpvVector2.Implicit(const aScalar:TpvScalar):TpvVector2;
begin
 result.x:=aScalar;
 result.y:=aScalar;
end;

class operator TpvVector2.Explicit(const aScalar:TpvScalar):TpvVector2;
begin
 result.x:=aScalar;
 result.y:=aScalar;
end;

class operator TpvVector2.Equal(const aLeft,aRight:TpvVector2):boolean;
begin
 result:=SameValue(aLeft.x,aRight.x) and SameValue(aLeft.y,aRight.y);
end;

class operator TpvVector2.NotEqual(const aLeft,aRight:TpvVector2):boolean;
begin
 result:=(not SameValue(aLeft.x,aRight.x)) or (not SameValue(aLeft.y,aRight.y));
end;

class operator TpvVector2.Inc(const aValue:TpvVector2):TpvVector2;
begin
 result.x:=aValue.x+1.0;
 result.y:=aValue.y+1.0;
end;

class operator TpvVector2.Dec(const aValue:TpvVector2):TpvVector2;
begin
 result.x:=aValue.x-1.0;
 result.y:=aValue.y-1.0;
end;

class operator TpvVector2.Add(const a,b:TpvVector2):TpvVector2;
begin
 result.x:=a.x+b.x;
 result.y:=a.y+b.y;
end;

class operator TpvVector2.Add(const a:TpvVector2;const b:TpvScalar):TpvVector2;
begin
 result.x:=a.x+b;
 result.y:=a.y+b;
end;

class operator TpvVector2.Add(const a:TpvScalar;const b:TpvVector2):TpvVector2;
begin
 result.x:=a+b.x;
 result.y:=a+b.y;
end;

class operator TpvVector2.Subtract(const a,b:TpvVector2):TpvVector2;
begin
 result.x:=a.x-b.x;
 result.y:=a.y-b.y;
end;

class operator TpvVector2.Subtract(const a:TpvVector2;const b:TpvScalar):TpvVector2;
begin
 result.x:=a.x-b;
 result.y:=a.y-b;
end;

class operator TpvVector2.Subtract(const a:TpvScalar;const b:TpvVector2): TpvVector2;
begin
 result.x:=a-b.x;
 result.y:=a-b.y;
end;

class operator TpvVector2.Multiply(const a,b:TpvVector2):TpvVector2;
begin
 result.x:=a.x*b.x;
 result.y:=a.y*b.y;
end;

class operator TpvVector2.Multiply(const a:TpvVector2;const b:TpvScalar):TpvVector2;
begin
 result.x:=a.x*b;
 result.y:=a.y*b;
end;

class operator TpvVector2.Multiply(const a:TpvScalar;const b:TpvVector2):TpvVector2;
begin
 result.x:=a*b.x;
 result.y:=a*b.y;
end;

class operator TpvVector2.Divide(const a,b:TpvVector2):TpvVector2;
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
end;

class operator TpvVector2.Divide(const a:TpvVector2;const b:TpvScalar):TpvVector2;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
end;

class operator TpvVector2.Divide(const a:TpvScalar;const b:TpvVector2):TpvVector2;
begin
 result.x:=a/b.x;
 result.y:=a/b.y;
end;

class operator TpvVector2.IntDivide(const a,b:TpvVector2):TpvVector2;
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
end;

class operator TpvVector2.IntDivide(const a:TpvVector2;const b:TpvScalar):TpvVector2;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
end;

class operator TpvVector2.IntDivide(const a:TpvScalar;const b:TpvVector2):TpvVector2;
begin
 result.x:=a/b.x;
 result.y:=a/b.y;
end;

class operator TpvVector2.Modulus(const a,b:TpvVector2):TpvVector2;
begin
 result.x:=Modulus(a.x,b.x);
 result.y:=Modulus(a.y,b.y);
end;

class operator TpvVector2.Modulus(const a:TpvVector2;const b:TpvScalar):TpvVector2;
begin
 result.x:=Modulus(a.x,b);
 result.y:=Modulus(a.y,b);
end;

class operator TpvVector2.Modulus(const a:TpvScalar;const b:TpvVector2):TpvVector2;
begin
 result.x:=Modulus(a,b.x);
 result.y:=Modulus(a,b.y);
end;

class operator TpvVector2.Negative(const aValue:TpvVector2):TpvVector2;
begin
 result.x:=-aValue.x;
 result.y:=-aValue.y;
end;

class operator TpvVector2.Positive(const aValue:TpvVector2):TpvVector2;
begin
 result:=aValue;
end;

{$i PasVulkan.Math.TpvVector2.Swizzle.Implementations.inc}

function TpvVector2.GetComponent(const aIndex:TpvInt32):TpvScalar;
begin
 result:=RawComponents[aIndex];
end;

procedure TpvVector2.SetComponent(const aIndex:TpvInt32;const aValue:TpvScalar);
begin
 RawComponents[aIndex]:=aValue;
end;

function TpvVector2.Perpendicular:TpvVector2;
begin
 result.x:=-y;
 result.y:=x;
end;

function TpvVector2.Length:TpvScalar;
begin
 result:=sqrt(sqr(x)+sqr(y));
end;

function TpvVector2.SquaredLength:TpvScalar;
begin
 result:=sqr(x)+sqr(y);
end;

function TpvVector2.Normalize:TpvVector2;
var Factor:TpvScalar;
begin
 Factor:=sqrt(sqr(x)+sqr(y));
 if Factor<>0.0 then begin
  Factor:=1.0/Factor;
  result.x:=x*Factor;
  result.y:=y*Factor;
 end else begin
  result.x:=0.0;
  result.y:=0.0;
 end;
end;

function TpvVector2.Abs:TpvVector2;
begin
 result.x:=System.Abs(x);
 result.y:=System.Abs(y);
end;

function TpvVector2.Truncate:TpvVector2;
begin
 result.x:=System.Trunc(x);
 result.y:=System.Trunc(y);
end;

function TpvVector2.Round:TpvVector2;
begin
 result.x:=System.Round(x);
 result.y:=System.Round(y);
end;

function TpvVector2.Floor:TpvVector2;
begin
 result.x:=Math.Floor(x);
 result.y:=Math.Floor(y);
end;

function TpvVector2.Ceil:TpvVector2;
begin
 result.x:=Math.Ceil(x);
 result.y:=Math.Ceil(y);
end;

function TpvVector2.Fract:TpvVector2;
begin
 result.x:=System.Frac(x);
 result.y:=System.Frac(y);
end;

function TpvVector2.DistanceTo(const aToVector:TpvVector2):TpvScalar;
begin
 result:=sqrt(sqr(x-aToVector.x)+sqr(y-aToVector.y));
end;

function TpvVector2.Dot(const aWithVector:TpvVector2):TpvScalar;
begin
 result:=(x*aWithVector.x)+(y*aWithVector.y);
end;

function TpvVector2.Cross(const aVector:TpvVector2):TpvVector2;
begin
 result.x:=(y*aVector.x)-(x*aVector.y);
 result.y:=(x*aVector.y)-(y*aVector.x);
end;

function TpvVector2.Lerp(const aToVector:TpvVector2;const aTime:TpvScalar):TpvVector2;
var InvT:TpvScalar;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aToVector;
 end else begin
  InvT:=1.0-aTime;
  result.x:=(x*InvT)+(aToVector.x*aTime);
  result.y:=(y*InvT)+(aToVector.y*aTime);
 end;
end;

function TpvVector2.Nlerp(const aToVector:TpvVector2;const aTime:TpvScalar):TpvVector2;
begin
 result:=self.Lerp(aToVector,aTime).Normalize;
end;

function TpvVector2.Slerp(const aToVector:TpvVector2;const aTime:TpvScalar):TpvVector2;
var DotProduct,Theta,Sinus,Cosinus:TpvScalar;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aToVector;
 end else if self=aToVector then begin
  result:=aToVector;
 end else begin
  DotProduct:=self.Dot(aToVector);
  if DotProduct<-1.0 then begin
   DotProduct:=-1.0;
  end else if DotProduct>1.0 then begin
   DotProduct:=1.0;
  end;
  Theta:=ArcCos(DotProduct)*aTime;
  Sinus:=0.0;
  Cosinus:=0.0;
  SinCos(Theta,Sinus,Cosinus);
  result:=(self*Cosinus)+((aToVector-(self*DotProduct)).Normalize*Sinus);
 end;
end;

function TpvVector2.Sqlerp(const aB,aC,aD:TpvVector2;const aTime:TpvScalar):TpvVector2;
begin
 result:=Slerp(aD,aTime).Slerp(aB.Slerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

function TpvVector2.Angle(const aOtherFirstVector,aOtherSecondVector:TpvVector2):TpvScalar;
var DeltaAB,DeltaCB:TpvVector2;
    LengthAB,LengthCB:TpvScalar;
begin
 DeltaAB:=self-aOtherFirstVector;
 DeltaCB:=aOtherSecondVector-aOtherFirstVector;
 LengthAB:=DeltaAB.Length;
 LengthCB:=DeltaCB.Length;
 if (LengthAB=0.0) or (LengthCB=0.0) then begin
  result:=0.0;
 end else begin
  result:=ArcCos(DeltaAB.Dot(DeltaCB)/(LengthAB*LengthCB));
 end;
end;

function TpvVector2.Rotate(const aAngle:TpvScalar):TpvVector2;
var Sinus,Cosinus:TpvScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(aAngle,Sinus,Cosinus);
 result.x:=(x*Cosinus)-(y*Sinus);
 result.y:=(y*Cosinus)+(x*Sinus);
end;

function TpvVector2.Rotate(const aCenter:TpvVector2;const aAngle:TpvScalar):TpvVector2;
var Sinus,Cosinus:TpvScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(aAngle,Sinus,Cosinus);
 result.x:=(((x-aCenter.x)*Cosinus)-((y-aCenter.y)*Sinus))+aCenter.x;
 result.y:=(((y-aCenter.y)*Cosinus)+((x-aCenter.x)*Sinus))+aCenter.y;
end;

constructor TpvVector3.Create(const aX:TpvScalar);
begin
 x:=aX;
 y:=aX;
 z:=aX;
end;

constructor TpvVector3.Create(const aX,aY,aZ:TpvScalar);
begin
 x:=aX;
 y:=aY;
 z:=aZ;
end;

constructor TpvVector3.Create(const aXY:TpvVector2;const aZ:TpvScalar=0.0);
begin
 Vector2:=aXY;
 z:=aZ;
end;

class function TpvVector3.InlineableCreate(const aX:TpvScalar):TpvVector3;
begin
 result.x:=aX;
 result.y:=aX;
 result.z:=aX;
end;

class function TpvVector3.InlineableCreate(const aX,aY,aZ:TpvScalar):TpvVector3;
begin
 result.x:=aX;
 result.y:=aY;
 result.z:=aZ;
end;

class function TpvVector3.InlineableCreate(const aXY:TpvVector2;const aZ:TpvScalar=0.0):TpvVector3;
begin
 result.Vector2:=aXY;
 result.z:=aZ;
end;

class function TpvVector3.InlineableCreate(const aXYZ:TpvVector3):TpvVector3;
begin
 result:=aXYZ;
end;

class operator TpvVector3.Implicit(const a:TpvScalar):TpvVector3;
begin
 result.x:=a;
 result.y:=a;
 result.z:=a;
end;

class operator TpvVector3.Explicit(const a:TpvScalar):TpvVector3;
begin
 result.x:=a;
 result.y:=a;
 result.z:=a;
end;

class operator TpvVector3.Equal(const a,b:TpvVector3):boolean;
begin
 result:=SameValue(a.x,b.x) and SameValue(a.y,b.y) and SameValue(a.z,b.z);
end;

class operator TpvVector3.NotEqual(const a,b:TpvVector3):boolean;
begin
 result:=(not SameValue(a.x,b.x)) or (not SameValue(a.y,b.y)) or (not SameValue(a.z,b.z));
end;

class operator TpvVector3.Inc({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
const One:TpvFloat=1.0;
asm
{$if defined(ExplicitX64SIMDRegs)}
 movss xmm0,dword ptr [rdx+0]
 movss xmm1,dword ptr [rdx+4]
 movss xmm2,dword ptr [rdx+8]
{$else}
 movss xmm0,dword ptr [a+0]
 movss xmm1,dword ptr [a+4]
 movss xmm2,dword ptr [a+8]
{$ifend}
{$if defined(cpu386)}
 movss xmm3,dword ptr [One]
{$elseif defined(fpc)}
 movss xmm3,dword ptr [rip+One]
{$else}
 movss xmm3,dword ptr [rel One]
{$ifend}
 addss xmm0,xmm3
 addss xmm1,xmm3
 addss xmm2,xmm3
{$if defined(ExplicitX64SIMDRegs)}
 movss dword ptr [rcx+0],xmm0
 movss dword ptr [rcx+4],xmm1
 movss dword ptr [rcx+8],xmm2
{$else}
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
{$ifend}
end;
{$else}
begin
 result.x:=a.x+1.0;
 result.y:=a.y+1.0;
 result.z:=a.z+1.0;
end;
{$ifend}

class operator TpvVector3.Dec({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
const One:TpvFloat=1.0;
asm
{$if defined(ExplicitX64SIMDRegs)}
 movss xmm0,dword ptr [rdx+0]
 movss xmm1,dword ptr [rdx+4]
 movss xmm2,dword ptr [rdx+8]
{$else}
 movss xmm0,dword ptr [a+0]
 movss xmm1,dword ptr [a+4]
 movss xmm2,dword ptr [a+8]
{$ifend}
{$if defined(cpu386)}
 movss xmm3,dword ptr [One]
{$elseif defined(fpc)}
 movss xmm3,dword ptr [rip+One]
{$else}
 movss xmm3,dword ptr [rel One]
{$ifend}
 subss xmm0,xmm3
 subss xmm1,xmm3
 subss xmm2,xmm3
{$if defined(ExplicitX64SIMDRegs)}
 movss dword ptr [rcx+0],xmm0
 movss dword ptr [rcx+4],xmm1
 movss dword ptr [rcx+8],xmm2
{$else}
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
{$ifend}
end;
{$else}
begin
 result.x:=a.x-1.0;
 result.y:=a.y-1.0;
 result.z:=a.z-1.0;
end;
{$ifend}

class operator TpvVector3.Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector3):TpvVector3;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
 movss xmm0,dword ptr [rdx+0]
 movss xmm1,dword ptr [rdx+4]
 movss xmm2,dword ptr [rdx+8]
 addss xmm0,dword ptr [r8+0]
 addss xmm1,dword ptr [r8+4]
 addss xmm2,dword ptr [r8+8]
 movss dword ptr [rcx+0],xmm0
 movss dword ptr [rcx+4],xmm1
 movss dword ptr [rcx+8],xmm2
{$else}
 movss xmm0,dword ptr [a+0]
 movss xmm1,dword ptr [a+4]
 movss xmm2,dword ptr [a+8]
 addss xmm0,dword ptr [b+0]
 addss xmm1,dword ptr [b+4]
 addss xmm2,dword ptr [b+8]
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
{$ifend}
end;
{$else}
begin
 result.x:=a.x+b.x;
 result.y:=a.y+b.y;
 result.z:=a.z+b.z;
end;
{$ifend}

class operator TpvVector3.Add(const a:TpvVector3;const b:TpvScalar):TpvVector3;
begin
 result.x:=a.x+b;
 result.y:=a.y+b;
 result.z:=a.z+b;
end;

class operator TpvVector3.Add(const a:TpvScalar;const b:TpvVector3):TpvVector3;
begin
 result.x:=a+b.x;
 result.y:=a+b.y;
 result.z:=a+b.z;
end;

class operator TpvVector3.Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector3):TpvVector3;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
 movss xmm0,dword ptr [rdx+0]
 movss xmm1,dword ptr [rdx+4]
 movss xmm2,dword ptr [rdx+8]
 subss xmm0,dword ptr [r8+0]
 subss xmm1,dword ptr [r8+4]
 subss xmm2,dword ptr [r8+8]
 movss dword ptr [rcx+0],xmm0
 movss dword ptr [rcx+4],xmm1
 movss dword ptr [rcx+8],xmm2
{$else}
 movss xmm0,dword ptr [a+0]
 movss xmm1,dword ptr [a+4]
 movss xmm2,dword ptr [a+8]
 subss xmm0,dword ptr [b+0]
 subss xmm1,dword ptr [b+4]
 subss xmm2,dword ptr [b+8]
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
{$ifend}
end;
{$else}
begin
 result.x:=a.x-b.x;
 result.y:=a.y-b.y;
 result.z:=a.z-b.z;
end;
{$ifend}

class operator TpvVector3.Subtract(const a:TpvVector3;const b:TpvScalar):TpvVector3;
begin
 result.x:=a.x-b;
 result.y:=a.y-b;
 result.z:=a.z-b;
end;

class operator TpvVector3.Subtract(const a:TpvScalar;const b:TpvVector3): TpvVector3;
begin
 result.x:=a-b.x;
 result.y:=a-b.y;
 result.z:=a-b.z;
end;

class operator TpvVector3.Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector3):TpvVector3;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
 movss xmm0,dword ptr [rdx+0]
 movss xmm1,dword ptr [rdx+4]
 movss xmm2,dword ptr [rdx+8]
 mulss xmm0,dword ptr [r8+0]
 mulss xmm1,dword ptr [r8+4]
 mulss xmm2,dword ptr [r8+8]
 movss dword ptr [rcx+0],xmm0
 movss dword ptr [rcx+4],xmm1
 movss dword ptr [rcx+8],xmm2
{$else}
 movss xmm0,dword ptr [a+0]
 movss xmm1,dword ptr [a+4]
 movss xmm2,dword ptr [a+8]
 mulss xmm0,dword ptr [b+0]
 mulss xmm1,dword ptr [b+4]
 mulss xmm2,dword ptr [b+8]
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
{$ifend}
end;
{$else}
begin
 result.x:=a.x*b.x;
 result.y:=a.y*b.y;
 result.z:=a.z*b.z;
end;
{$ifend}

class operator TpvVector3.Multiply(const a:TpvVector3;const b:TpvScalar):TpvVector3;
begin
 result.x:=a.x*b;
 result.y:=a.y*b;
 result.z:=a.z*b;
end;

class operator TpvVector3.Multiply(const a:TpvScalar;const b:TpvVector3):TpvVector3;
begin
 result.x:=a*b.x;
 result.y:=a*b.y;
 result.z:=a*b.z;
end;

class operator TpvVector3.Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector3):TpvVector3;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
 movss xmm0,dword ptr [rdx+0]
 movss xmm1,dword ptr [rdx+4]
 movss xmm2,dword ptr [rdx+8]
 divss xmm0,dword ptr [r8+0]
 divss xmm1,dword ptr [r8+4]
 divss xmm2,dword ptr [r8+8]
 movss dword ptr [rcx+0],xmm0
 movss dword ptr [rcx+4],xmm1
 movss dword ptr [rcx+8],xmm2
{$else}
 movss xmm0,dword ptr [a+0]
 movss xmm1,dword ptr [a+4]
 movss xmm2,dword ptr [a+8]
 divss xmm0,dword ptr [b+0]
 divss xmm1,dword ptr [b+4]
 divss xmm2,dword ptr [b+8]
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
{$ifend}
end;
{$else}
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
 result.z:=a.z/b.z;
end;
{$ifend}

class operator TpvVector3.Divide(const a:TpvVector3;const b:TpvScalar):TpvVector3;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
 result.z:=a.z/b;
end;

class operator TpvVector3.Divide(const a:TpvScalar;const b:TpvVector3):TpvVector3;
begin
 result.x:=a/b.x;
 result.y:=a/b.y;
 result.z:=a/b.z;
end;

class operator TpvVector3.IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector3):TpvVector3;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
 movss xmm0,dword ptr [rdx+0]
 movss xmm1,dword ptr [rdx+4]
 movss xmm2,dword ptr [rdx+8]
 divss xmm0,dword ptr [r8+0]
 divss xmm1,dword ptr [r8+4]
 divss xmm2,dword ptr [r8+8]
 movss dword ptr [rcx+0],xmm0
 movss dword ptr [rcx+4],xmm1
 movss dword ptr [rcx+8],xmm2
{$else}
 movss xmm0,dword ptr [a+0]
 movss xmm1,dword ptr [a+4]
 movss xmm2,dword ptr [a+8]
 divss xmm0,dword ptr [b+0]
 divss xmm1,dword ptr [b+4]
 divss xmm2,dword ptr [b+8]
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
{$ifend}
end;
{$else}
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
 result.z:=a.z/b.z;
end;
{$ifend}

class operator TpvVector3.IntDivide(const a:TpvVector3;const b:TpvScalar):TpvVector3;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
 result.z:=a.z/b;
end;

class operator TpvVector3.IntDivide(const a:TpvScalar;const b:TpvVector3):TpvVector3;
begin
 result.x:=a/b.x;
 result.y:=a/b.y;
 result.z:=a/b.z;
end;

class operator TpvVector3.Modulus(const a,b:TpvVector3):TpvVector3;
begin
 result.x:=Modulus(a.x,b.x);
 result.y:=Modulus(a.y,b.y);
 result.z:=Modulus(a.z,b.z);
end;

class operator TpvVector3.Modulus(const a:TpvVector3;const b:TpvScalar):TpvVector3;
begin
 result.x:=Modulus(a.x,b);
 result.y:=Modulus(a.y,b);
 result.z:=Modulus(a.z,b);
end;

class operator TpvVector3.Modulus(const a:TpvScalar;const b:TpvVector3):TpvVector3;
begin
 result.x:=Modulus(a,b.x);
 result.y:=Modulus(a,b.y);
 result.z:=Modulus(a,b.z);
end;

class operator TpvVector3.Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
 xorps xmm0,xmm0
 xorps xmm1,xmm1
 xorps xmm2,xmm2
{$if defined(ExplicitX64SIMDRegs)}
 subss xmm0,dword ptr [rdx+0]
 subss xmm1,dword ptr [rdx+4]
 subss xmm2,dword ptr [rdx+8]
 movss dword ptr [rcx+0],xmm0
 movss dword ptr [rcx+4],xmm1
 movss dword ptr [rcx+8],xmm2
{$else}
 subss xmm0,dword ptr [a+0]
 subss xmm1,dword ptr [a+4]
 subss xmm2,dword ptr [a+8]
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
{$ifend}
end;
{$else}
begin
 result.x:=-a.x;
 result.y:=-a.y;
 result.z:=-a.z;
end;
{$ifend}

class operator TpvVector3.Positive(const a:TpvVector3):TpvVector3;
begin
 result:=a;
end;

{$i PasVulkan.Math.TpvVector3.Swizzle.Implementations.inc}

function TpvVector3.GetComponent(const aIndex:TpvInt32):TpvScalar;
begin
 result:=RawComponents[aIndex];
end;

procedure TpvVector3.SetComponent(const aIndex:TpvInt32;const aValue:TpvScalar);
begin
 RawComponents[aIndex]:=aValue;
end;

function TpvVector3.Flip:TpvVector3;
begin
 result.x:=x;
 result.y:=z;
 result.z:=-y;
end;

function TpvVector3.Perpendicular:TpvVector3;
var v,p:TpvVector3;
begin
 v:=self.Normalize;
 p.x:=System.abs(v.x);
 p.y:=System.abs(v.y);
 p.z:=System.abs(v.z);
 if (p.x<=p.y) and (p.x<=p.z) then begin
  p.x:=1.0;
  p.y:=0.0;
  p.z:=0.0;
 end else if (p.y<=p.x) and (p.y<=p.z) then begin
  p.x:=0.0;
  p.y:=1.0;
  p.z:=0.0;
 end else begin
  p.x:=0.0;
  p.y:=0.0;
  p.z:=1.0;
 end;
 result:=p-(v*v.Dot(p));
end;

function TpvVector3.OneUnitOrthogonalVector:TpvVector3;
var MinimumAxis:TpvInt32;
    l:TpvScalar;
begin
 if System.abs(x)<System.abs(y) then begin
  if System.abs(x)<System.abs(z) then begin
   MinimumAxis:=0;
  end else begin
   MinimumAxis:=2;
  end;
 end else begin
  if System.abs(y)<System.abs(z) then begin
   MinimumAxis:=1;
  end else begin
   MinimumAxis:=2;
  end;
 end;
 case MinimumAxis of
  0:begin
   l:=sqrt(sqr(y)+sqr(z));
   result.x:=0.0;
   result.y:=-(z/l);
   result.z:=y/l;
  end;
  1:begin
   l:=sqrt(sqr(x)+sqr(z));
   result.x:=-(z/l);
   result.y:=0.0;
   result.z:=x/l;
  end;
  else begin
   l:=sqrt(sqr(x)+sqr(y));
   result.x:=-(y/l);
   result.y:=x/l;
   result.z:=0.0;
  end;
 end;
end;

function TpvVector3.OneUnitSmoothOrthogonalVector:TpvVector3;
var t:TpvVector3;
begin
 t.x:=self.y-self.z;
 t.y:=self.z-self.x;
 t.z:=self.x-self.y;
 result:=(t-(self*self.Dot(t))).Normalize;
end;

function TpvVector3.Length:TpvScalar;
{$if defined(SIMD) and defined(cpu386)}
asm
 xorps xmm2,xmm2
 movss xmm0,dword ptr [eax+0]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + y*y + x*x
 sqrtss xmm0,xmm1
 movss dword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
 xorps xmm2,xmm2
//{$ifdef Windows}
 movss xmm0,dword ptr [rcx+0]
 movss xmm1,dword ptr [rcx+4]
 movss xmm2,dword ptr [rcx+8]
//{$else}
// movss xmm0,dword ptr [rdi+0]
// movss xmm1,dword ptr [rdi+4]
// movss xmm2,dword ptr [rdi+8]
//{$endif}
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + y*y + x*x
 sqrtss xmm0,xmm1
{$ifdef fpc}
 movss dword ptr [result],xmm0
{$else}
//movaps xmm0,xmm0
{$endif}
end;
{$else}
begin
 result:=sqrt(sqr(x)+sqr(y)+sqr(z));
end;
{$ifend}

function TpvVector3.SquaredLength:TpvScalar;
{$if defined(SIMD) and defined(cpu386)}
asm
 xorps xmm2,xmm2
 movss xmm0,dword ptr [eax+0]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm0,xmm1         // xmm0 = ?, ?, ?, z*z + y*y + x*x
 movss dword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
 xorps xmm2,xmm2
//{$ifdef Windows}
 movss xmm0,dword ptr [rcx+0]
 movss xmm1,dword ptr [rcx+4]
 movss xmm2,dword ptr [rcx+8]
(*{$else}
 movss xmm0,dword ptr [rdi+0]
 movss xmm1,dword ptr [rdi+4]
 movss xmm2,dword ptr [rdi+8]
{$endif}*)
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm0,xmm1         // xmm0 = ?, ?, ?, z*z + y*y + x*x
{$ifdef fpc}
 movss dword ptr [result],xmm0
{$else}
//movaps xmm0,xmm0
{$endif}
end;
{$else}
begin
 result:=sqr(x)+sqr(y)+sqr(z);
end;
{$ifend}

function TpvVector3.Normalize:TpvVector3;
{$if defined(SIMD) and defined(cpu386)}
asm
 xorps xmm2,xmm2
 movss xmm0,dword ptr [eax+0]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 movaps xmm2,xmm0
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + y*y + x*x
 sqrtss xmm0,xmm1        // not rsqrtss! because rsqrtss has only 12-bit accuracy
 shufps xmm0,xmm0,$00
 divps xmm2,xmm0
 movaps xmm1,xmm2
 subps xmm1,xmm2
 cmpps xmm1,xmm2,7
 andps xmm2,xmm1
 movaps xmm0,xmm2
 movaps xmm1,xmm2
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
 xorps xmm2,xmm2
//{$ifdef Windows}
 movss xmm0,dword ptr [rcx+0]
 movss xmm1,dword ptr [rcx+4]
 movss xmm2,dword ptr [rcx+8]
(*{$else}
 movss xmm0,dword ptr [rdi+0]
 movss xmm1,dword ptr [rdi+4]
 movss xmm2,dword ptr [rdi+8]
{$endif}*)
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 movaps xmm2,xmm0
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + y*y + x*x
 sqrtss xmm0,xmm1        // not rsqrtss! because rsqrtss has only 12-bit accuracy
 shufps xmm0,xmm0,$00
 divps xmm2,xmm0
 movaps xmm1,xmm2
 subps xmm1,xmm2
 cmpps xmm1,xmm2,7
 andps xmm2,xmm1
 movaps xmm0,xmm2
 movaps xmm1,xmm2
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
end;
{$else}
var Factor:TpvScalar;
begin
 Factor:=sqrt(sqr(x)+sqr(y)+sqr(z));
 if Factor<>0.0 then begin
  Factor:=1.0/Factor;
  result.x:=x*Factor;
  result.y:=y*Factor;
  result.z:=z*Factor;
 end else begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
 end;
end;
{$ifend}

function TpvVector3.DistanceTo({$ifdef fpc}constref{$else}const{$endif} aToVector:TpvVector3):TpvScalar;
{$if defined(SIMD) and defined(cpu386)}
asm
 xorps xmm2,xmm2
 movss xmm0,dword ptr [eax+0]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 subss xmm0,dword ptr [edx+0]
 subss xmm1,dword ptr [edx+4]
 subss xmm2,dword ptr [edx+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + y*y + x*x
 sqrtss xmm0,xmm1
 movss dword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
 xorps xmm2,xmm2
//{$ifdef Windows}
 movss xmm0,dword ptr [rcx+0]
 movss xmm1,dword ptr [rcx+4]
 movss xmm2,dword ptr [rcx+8]
 subss xmm0,dword ptr [rdx+0]
 subss xmm1,dword ptr [rdx+4]
 subss xmm2,dword ptr [rdx+8]
(*{$else}
 movss xmm0,dword ptr [rdi+0]
 movss xmm1,dword ptr [rdi+4]
 movss xmm2,dword ptr [rdi+8]
 subss xmm0,dword ptr [rsi+0]
 subss xmm1,dword ptr [rsi+4]
 subss xmm2,dword ptr [rsi+8]
{$endif}*)
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 mulps xmm0,xmm0         // xmm0 = ?, z*z, y*y, x*x
 movhlps xmm1,xmm0       // xmm1 = ?, ?, ?, z*z
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + x*x
 shufps xmm0,xmm0,$55    // xmm0 = ?, ?, ?, y*y
 addss xmm1,xmm0         // xmm1 = ?, ?, ?, z*z + y*y + x*x
 sqrtss xmm0,xmm1
{$ifdef fpc}
 movss dword ptr [result],xmm0
{$else}
//movaps xmm0,xmm0
{$endif}
end;
{$else}
begin
 result:=sqrt(sqr(x-aToVector.x)+sqr(y-aToVector.y)+sqr(z-aToVector.z));
end;
{$ifend}

function TpvVector3.Min(const aWith:TpvVector3):TpvVector3;
begin
 result.x:=Math.Min(x,aWith.x);
 result.y:=Math.Min(y,aWith.y);
 result.z:=Math.Min(z,aWith.z);
end;

function TpvVector3.Max(const aWith:TpvVector3):TpvVector3;
begin
 result.x:=Math.Max(x,aWith.x);
 result.y:=Math.Max(y,aWith.y);
 result.z:=Math.Max(z,aWith.z);
end;

function TpvVector3.Abs:TpvVector3;
{$if defined(SIMD) and defined(cpu386)}
asm
 movss xmm0,dword ptr [eax+0]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 xorps xmm1,xmm1
 subps xmm1,xmm0
 maxps xmm0,xmm1
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movss xmm0,dword ptr [rcx+0]
 movss xmm1,dword ptr [rcx+4]
 movss xmm2,dword ptr [rcx+8]
(*{$else}
 movss xmm0,dword ptr [rdi+0]
 movss xmm1,dword ptr [rdi+4]
 movss xmm2,dword ptr [rdi+8]
{$endif}*)
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 xorps xmm1,xmm1
 subps xmm1,xmm0
 maxps xmm0,xmm1
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
end;
{$else}
begin
 result.x:=System.abs(x);
 result.y:=System.abs(y);
 result.z:=System.abs(z);
end;
{$ifend}

function TpvVector3.Truncate:TpvVector3;
{$if defined(SIMD) and defined(cpu386)}
asm
 movss xmm0,dword ptr [eax+0]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 roundps xmm0,xmm0,3
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movss xmm0,dword ptr [rcx+0]
 movss xmm1,dword ptr [rcx+4]
 movss xmm2,dword ptr [rcx+8]
(*{$else}
 movss xmm0,dword ptr [rdi+0]
 movss xmm1,dword ptr [rdi+4]
 movss xmm2,dword ptr [rdi+8]
{$endif}*)
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 roundps xmm0,xmm0,3
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
end;
{$else}
begin
 result.x:=System.trunc(x);
 result.y:=System.trunc(y);
 result.z:=System.trunc(z);
end;
{$ifend}

function TpvVector3.Round:TpvVector3;
{$if defined(SIMD) and defined(cpu386)}
asm
 movss xmm0,dword ptr [eax+0]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 roundps xmm0,xmm0,0
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movss xmm0,dword ptr [rcx+0]
 movss xmm1,dword ptr [rcx+4]
 movss xmm2,dword ptr [rcx+8]
(*{$else}
 movss xmm0,dword ptr [rdi+0]
 movss xmm1,dword ptr [rdi+4]
 movss xmm2,dword ptr [rdi+8]
{$endif}*)
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 roundps xmm0,xmm0,0
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
end;
{$else}
begin
 result.x:=System.Round(x);
 result.y:=System.Round(y);
 result.z:=System.Round(z);
end;
{$ifend}

function TpvVector3.Floor:TpvVector3;
{$if defined(SIMD) and defined(cpu386)}
asm
 movss xmm0,dword ptr [eax+0]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 roundps xmm0,xmm0,1
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movss xmm0,dword ptr [rcx+0]
 movss xmm1,dword ptr [rcx+4]
 movss xmm2,dword ptr [rcx+8]
(*{$else}
 movss xmm0,dword ptr [rdi+0]
 movss xmm1,dword ptr [rdi+4]
 movss xmm2,dword ptr [rdi+8]
{$endif}*)
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 roundps xmm0,xmm0,1
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
end;
{$else}
begin
 result.x:=Math.Floor(x);
 result.y:=Math.Floor(y);
 result.z:=Math.Floor(z);
end;
{$ifend}

function TpvVector3.Ceil:TpvVector3;
{$if defined(SIMD) and defined(cpu386)}
asm
 movss xmm0,dword ptr [eax+0]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 roundps xmm0,xmm0,2
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movss xmm0,dword ptr [rcx+0]
 movss xmm1,dword ptr [rcx+4]
 movss xmm2,dword ptr [rcx+8]
(*{$else}
 movss xmm0,dword ptr [rdi+0]
 movss xmm1,dword ptr [rdi+4]
 movss xmm2,dword ptr [rdi+8]
{$endif}*)
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 roundps xmm0,xmm0,2
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
end;
{$else}
begin
 result.x:=Math.Ceil(x);
 result.y:=Math.Ceil(y);
 result.z:=Math.Ceil(z);
end;
{$ifend}

function TpvVector3.Fract:TpvVector3;
begin
 result.x:=System.Frac(x);
 result.y:=System.Frac(y);
 result.z:=System.Frac(z);
end;

function TpvVector3.Dot({$ifdef fpc}constref{$else}const{$endif} aWithVector:TpvVector3):TpvScalar;
{$if defined(SIMD) and defined(cpu386)}
asm
 movss xmm0,dword ptr [eax+0]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 mulss xmm0,dword ptr [edx+0]
 mulss xmm1,dword ptr [edx+4]
 mulss xmm2,dword ptr [edx+8]
 addss xmm0,xmm1
 addss xmm0,xmm2
 movss dword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movss xmm0,dword ptr [rcx+0]
 movss xmm1,dword ptr [rcx+4]
 movss xmm2,dword ptr [rcx+8]
 mulss xmm0,dword ptr [rdx+0]
 mulss xmm1,dword ptr [rdx+4]
 mulss xmm2,dword ptr [rdx+8]
(*{$else}
 movss xmm0,dword ptr [rdi+0]
 movss xmm1,dword ptr [rdi+4]
 movss xmm2,dword ptr [rdi+8]
 mulss xmm0,dword ptr [rsi+0]
 mulss xmm1,dword ptr [rsi+4]
 mulss xmm2,dword ptr [rsi+8]
{$endif}*)
 addss xmm0,xmm1
 addss xmm0,xmm2
{$ifdef fpc}
 movss dword ptr [result],xmm0
{$else}
//movaps xmm0,xmm0
{$endif}
end;
{$else}
begin
 result:=(x*aWithVector.x)+(y*aWithVector.y)+(z*aWithVector.z);
end;
{$ifend}


function TpvVector3.AngleTo(const aToVector:TpvVector3):TpvScalar;
var d:single;
begin
 d:=sqrt(SquaredLength*aToVector.SquaredLength);
 if d<>0.0 then begin
  result:=Dot(aToVector)/d;
 end else begin
  result:=0.0;
 end
end;

function TpvVector3.Cross({$ifdef fpc}constref{$else}const{$endif} aOtherVector:TpvVector3):TpvVector3;
{$if defined(SIMD) and defined(cpu386)}
asm
{$ifdef SSEVector3CrossOtherVariant}
 xorps xmm2,xmm2
 xorps xmm4,xmm4
 movss xmm0,dword ptr [eax+0]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 movss xmm2,dword ptr [edx+0]
 movss xmm3,dword ptr [edx+4]
 movss xmm4,dword ptr [edx+8]
 movlhps xmm2,xmm3
 shufps xmm2,xmm4,$88
 movaps xmm1,xmm0
 movaps xmm3,xmm2
 shufps xmm0,xmm0,$c9
 shufps xmm1,xmm1,$d2
 shufps xmm2,xmm2,$d2
 shufps xmm3,xmm3,$c9
 mulps xmm0,xmm2
 mulps xmm1,xmm3
 subps xmm0,xmm1
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [ecx+0],xmm0
 movss dword ptr [ecx+4],xmm1
 movss dword ptr [ecx+8],xmm2
{$else}
 xorps xmm2,xmm2
 xorps xmm3,xmm3
 movss xmm0,dword ptr [eax+0]
 movss xmm1,dword ptr [eax+4]
 movss xmm2,dword ptr [eax+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 movss xmm1,dword ptr [edx+0]
 movss xmm2,dword ptr [edx+4]
 movss xmm3,dword ptr [edx+8]
 movlhps xmm1,xmm2
 shufps xmm1,xmm3,$88
 movaps xmm2,xmm0
 movaps xmm3,xmm1
 shufps xmm0,xmm0,$12
 shufps xmm1,xmm1,$09
 shufps xmm2,xmm2,$09
 shufps xmm3,xmm3,$12
 mulps xmm0,xmm1
 mulps xmm2,xmm3
 subps xmm2,xmm0
 movaps xmm0,xmm2
 movaps xmm1,xmm2
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [ecx+0],xmm0
 movss dword ptr [ecx+4],xmm1
 movss dword ptr [ecx+8],xmm2
{$endif}
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
{$ifdef SSEVector3CrossOtherVariant}
//{$ifdef Windows}
 xorps xmm2,xmm2
 xorps xmm4,xmm4
 movss xmm0,dword ptr [rcx+0]
 movss xmm1,dword ptr [rcx+4]
 movss xmm2,dword ptr [rcx+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 movss xmm2,dword ptr [r8+0]
 movss xmm3,dword ptr [r8+4]
 movss xmm4,dword ptr [r8+8]
 movlhps xmm2,xmm3
 shufps xmm2,xmm4,$88
(*{$else}
 xorps xmm2,xmm2
 xorps xmm4,xmm4
 movss xmm0,dword ptr [rdi+0]
 movss xmm1,dword ptr [rdi+4]
 movss xmm2,dword ptr [rdi+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 movss xmm2,dword ptr [rsi+0]
 movss xmm3,dword ptr [rsi+4]
 movss xmm4,dword ptr [rsi+8]
 movlhps xmm2,xmm3
 shufps xmm2,xmm4,$88
{$endif}*)
 movaps xmm1,xmm0
 movaps xmm3,xmm2
 shufps xmm0,xmm0,$c9
 shufps xmm1,xmm1,$d2
 shufps xmm2,xmm2,$d2
 shufps xmm3,xmm3,$c9
 mulps xmm0,xmm2
 mulps xmm1,xmm3
 subps xmm0,xmm1
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
//{$ifdef Windows}
 movss dword ptr [rdx+0],xmm0
 movss dword ptr [rdx+4],xmm1
 movss dword ptr [rdx+8],xmm2
(*{$else}
 movss dword ptr [rax+0],xmm0
 movss dword ptr [rax+4],xmm1
 movss dword ptr [rax+8],xmm2
{$endif}*)
{$else}
//{$ifdef Windows}
 xorps xmm2,xmm2
 xorps xmm3,xmm3
 movss xmm0,dword ptr [rcx+0]
 movss xmm1,dword ptr [rcx+4]
 movss xmm2,dword ptr [rcx+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 movss xmm1,dword ptr [r8+0]
 movss xmm2,dword ptr [r8+4]
 movss xmm3,dword ptr [r8+8]
 movlhps xmm1,xmm2
 shufps xmm1,xmm3,$88
(*{$else}
 xorps xmm2,xmm2
 xorps xmm3,xmm3
 movss xmm0,dword ptr [rdi+0]
 movss xmm1,dword ptr [rdi+4]
 movss xmm2,dword ptr [rdi+8]
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
 movss xmm1,dword ptr [rsi+0]
 movss xmm2,dword ptr [rsi+4]
 movss xmm3,dword ptr [rsi+8]
 movlhps xmm1,xmm2
 shufps xmm1,xmm3,$88
{$endif}*)
 movaps xmm2,xmm0
 movaps xmm3,xmm1
 shufps xmm0,xmm0,$12
 shufps xmm1,xmm1,$09
 shufps xmm2,xmm2,$09
 shufps xmm3,xmm3,$12
 mulps xmm0,xmm1
 mulps xmm2,xmm3
 subps xmm2,xmm0
 movaps xmm0,xmm2
 movaps xmm1,xmm2
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
//{$ifdef Windows}
 movss dword ptr [rdx+0],xmm0
 movss dword ptr [rdx+4],xmm1
 movss dword ptr [rdx+8],xmm2
(*{$else}
 movss dword ptr [rax+0],xmm0
 movss dword ptr [rax+4],xmm1
 movss dword ptr [rax+8],xmm2
{$endif}*)
{$endif}
end;
{$else}
begin
 result.x:=(y*aOtherVector.z)-(z*aOtherVector.y);
 result.y:=(z*aOtherVector.x)-(x*aOtherVector.z);
 result.z:=(x*aOtherVector.y)-(y*aOtherVector.x);
end;
{$ifend}

function TpvVector3.Lerp(const aToVector:TpvVector3;const aTime:TpvScalar):TpvVector3;
var InvT:TpvScalar;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aToVector;
 end else begin
  InvT:=1.0-aTime;
  result:=(self*InvT)+(aToVector*aTime);
 end;
end;

function TpvVector3.Nlerp(const aToVector:TpvVector3;const aTime:TpvScalar):TpvVector3;
begin
 result:=self.Lerp(aToVector,aTime).Normalize;
end;

function TpvVector3.Slerp(const aToVector:TpvVector3;const aTime:TpvScalar):TpvVector3;
var //DotProduct,Theta,Sinus,Cosinus:TpvScalar;
    SelfLength,ToVectorLength:TpvScalar;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aToVector;
 end else if self=aToVector then begin
  result:=aToVector;
 end else begin
  SelfLength:=self.Length;
  ToVectorLength:=aToVector.Length;
  if Math.Min(System.Abs(SelfLength),System.Abs(ToVectorLength))<1e-7 then begin
   result:=(self*(1.0-aTime))+(aToVector*aTime);
  end else begin
   result:=TpvVector3.InlineableCreate(TpvQuaternion.Identity.Slerp(TpvQuaternion.CreateFromToRotation(self,
                                                                                                       aToVector),
                                                                    aTime)*self.Normalize)*
           ((SelfLength*(1.0-aTime))+(ToVectorLength*aTime));
  end;
{ DotProduct:=self.Dot(aToVector);
  if DotProduct<-1.0 then begin
   DotProduct:=-1.0;
  end else if DotProduct>1.0 then begin
   DotProduct:=1.0;
  end;
  Theta:=ArcCos(DotProduct)*aTime;
  Sinus:=0.0;
  Cosinus:=0.0;
  SinCos(Theta,Sinus,Cosinus);
  result:=(self*Cosinus)+((aToVector-(self*DotProduct)).Normalize*Sinus);}
 end;
end;

function TpvVector3.Sqlerp(const aB,aC,aD:TpvVector3;const aTime:TpvScalar):TpvVector3;
begin
 result:=Slerp(aD,aTime).Slerp(aB.Slerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

function TpvVector3.Angle(const aOtherFirstVector,aOtherSecondVector:TpvVector3):TpvScalar;
var DeltaAB,DeltaCB:TpvVector3;
    LengthAB,LengthCB:TpvScalar;
begin
 DeltaAB:=self-aOtherFirstVector;
 DeltaCB:=aOtherSecondVector-aOtherFirstVector;
 LengthAB:=DeltaAB.Length;
 LengthCB:=DeltaCB.Length;
 if (LengthAB=0.0) or (LengthCB=0.0) then begin
  result:=0.0;
 end else begin
  result:=ArcCos(DeltaAB.Dot(DeltaCB)/(LengthAB*LengthCB));
 end;
end;

function TpvVector3.RotateX(const aAngle:TpvScalar):TpvVector3;
var Sinus,Cosinus:TpvScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(aAngle,Sinus,Cosinus);
 result.x:=x;
 result.y:=(y*Cosinus)-(z*Sinus);
 result.z:=(y*Sinus)+(z*Cosinus);
end;

function TpvVector3.RotateY(const aAngle:TpvScalar):TpvVector3;
var Sinus,Cosinus:TpvScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(aAngle,Sinus,Cosinus);
 result.x:=(z*Sinus)+(x*Cosinus);
 result.y:=y;
 result.z:=(z*Cosinus)-(x*Sinus);
end;

function TpvVector3.RotateZ(const aAngle:TpvScalar):TpvVector3;
var Sinus,Cosinus:TpvScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(aAngle,Sinus,Cosinus);
 result.x:=(x*Cosinus)-(y*Sinus);
 result.y:=(x*Sinus)+(y*Cosinus);
 result.z:=z;
end;

function TpvVector3.ProjectToBounds(const aMinVector,aMaxVector:TpvVector3):TpvScalar;
begin
 if x<0.0 then begin
  result:=x*aMaxVector.x;
 end else begin
  result:=x*aMinVector.x;
 end;
 if y<0.0 then begin
  result:=result+(y*aMaxVector.y);
 end else begin
  result:=result+(y*aMinVector.y);
 end;
 if z<0.0 then begin
  result:=result+(z*aMaxVector.z);
 end else begin
  result:=result+(z*aMinVector.z);
 end;
end;

constructor TpvVector4.Create(const aX:TpvScalar);
begin
 x:=aX;
 y:=aX;
 z:=aX;
 w:=aX;
end;

constructor TpvVector4.Create(const aX,aY,aZ,aW:TpvScalar);
begin
 x:=aX;
 y:=aY;
 z:=aZ;
 w:=aW;
end;

constructor TpvVector4.Create(const aXY:TpvVector2;const aZ:TpvScalar=0.0;const aW:TpvScalar=1.0);
begin
 x:=aXY.x;
 y:=aXY.y;
 z:=aZ;
 w:=aW;
end;

constructor TpvVector4.Create(const aXYZ:TpvVector3;const aW:TpvScalar=1.0);
begin
 x:=aXYZ.x;
 y:=aXYZ.y;
 z:=aXYZ.z;
 w:=aW;
end;

class function TpvVector4.InlineableCreate(const aX:TpvScalar):TpvVector4;
begin
 result.x:=aX;
 result.y:=aX;
 result.z:=aX;
 result.w:=aX;
end;

class function TpvVector4.InlineableCreate(const aX,aY,aZ,aW:TpvScalar):TpvVector4;
begin
 result.x:=aX;
 result.y:=aY;
 result.z:=aZ;
 result.w:=aW;
end;

class function TpvVector4.InlineableCreate(const aXY:TpvVector2;const aZ:TpvScalar=0.0;const aW:TpvScalar=0.0):TpvVector4;
begin
 result.Vector2:=aXY;
 result.z:=aZ;
 result.w:=aW;
end;

class function TpvVector4.InlineableCreate(const aXYZ:TpvVector3;const aW:TpvScalar=0.0):TpvVector4;
begin
 result.Vector3:=aXYZ;
 result.w:=aW;
end;

class operator TpvVector4.Implicit(const a:TpvScalar):TpvVector4;
begin
 result.x:=a;
 result.y:=a;
 result.z:=a;
 result.w:=a;
end;

class operator TpvVector4.Explicit(const a:TpvScalar):TpvVector4;
begin
 result.x:=a;
 result.y:=a;
 result.z:=a;
 result.w:=a;
end;

class operator TpvVector4.Equal(const a,b:TpvVector4):boolean;
begin
 result:=SameValue(a.x,b.x) and SameValue(a.y,b.y) and SameValue(a.z,b.z) and SameValue(a.w,b.w);
end;

class operator TpvVector4.NotEqual(const a,b:TpvVector4):boolean;
begin
 result:=(not SameValue(a.x,b.x)) or (not SameValue(a.y,b.y)) or (not SameValue(a.z,b.z)) or (not SameValue(a.w,b.w));
end;

class operator TpvVector4.Inc({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4;
{$if defined(SIMD) and defined(cpu386)}
const One:TpvVector4=(x:1.0;y:1.0;z:1.0;w:1.0);
asm
 movups xmm0,dqword ptr [a]
 movups xmm1,dqword ptr [One]
 addps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
const One:TpvVector4=(x:1.0;y:1.0;z:1.0;w:1.0);
asm
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [rdx]
{$else}
 movups xmm0,dqword ptr [a]
{$ifend}
{$ifdef fpc}
 movups xmm1,dqword ptr [rip+One]
{$else}
 movups xmm1,dqword ptr [rel One]
{$endif}
 addps xmm0,xmm1
{$if defined(ExplicitX64SIMDRegs)}
 movups dqword ptr [rcx],xmm0
{$else}
 movups dqword ptr [result],xmm0
{$ifend}
end;
{$else}
begin
 result.x:=a.x+1.0;
 result.y:=a.y+1.0;
 result.z:=a.z+1.0;
 result.w:=a.w+1.0;
end;
{$ifend}

class operator TpvVector4.Dec({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4;
{$if defined(SIMD) and defined(cpu386)}
const One:TpvVector4=(x:1.0;y:1.0;z:1.0;w:1.0);
asm
 movups xmm0,dqword ptr [a]
 movups xmm1,dqword ptr [One]
 subps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
const One:TpvVector4=(x:1.0;y:1.0;z:1.0;w:1.0);
asm
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [rdx]
{$else}
 movups xmm0,dqword ptr [a]
{$ifend}
{$ifdef fpc}
 movups xmm1,dqword ptr [rip+One]
{$else}
 movups xmm1,dqword ptr [rel One]
{$endif}
 subps xmm0,xmm1
{$if defined(ExplicitX64SIMDRegs)}
 movups dqword ptr [rcx],xmm0
{$else}
 movups dqword ptr [result],xmm0
{$ifend}
end;
{$else}
begin
 result.x:=a.x-1.0;
 result.y:=a.y-1.0;
 result.z:=a.z-1.0;
 result.w:=a.w-1.0;
end;
{$ifend}

class operator TpvVector4.Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector4):TpvVector4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [rdx]
 movups xmm1,dqword ptr [r8]
{$else}
 movups xmm0,dqword ptr [a]
 movups xmm1,dqword ptr [b]
{$ifend}
 addps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=a.x+b.x;
 result.y:=a.y+b.y;
 result.z:=a.z+b.z;
 result.w:=a.w+b.w;
end;
{$ifend}

class operator TpvVector4.Add(const a:TpvVector4;const b:TpvScalar):TpvVector4;
begin
 result.x:=a.x+b;
 result.y:=a.y+b;
 result.z:=a.z+b;
 result.w:=a.w+b;
end;

class operator TpvVector4.Add(const a:TpvScalar;const b:TpvVector4):TpvVector4;
begin
 result.x:=a+b.x;
 result.y:=a+b.y;
 result.z:=a+b.z;
 result.w:=a+b.w;
end;

class operator TpvVector4.Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector4):TpvVector4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [rdx]
 movups xmm1,dqword ptr [r8]
{$else}
 movups xmm0,dqword ptr [a]
 movups xmm1,dqword ptr [b]
{$ifend}
 subps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=a.x-b.x;
 result.y:=a.y-b.y;
 result.z:=a.z-b.z;
 result.w:=a.w-b.w;
end;
{$ifend}

class operator TpvVector4.Subtract(const a:TpvVector4;const b:TpvScalar):TpvVector4;
begin
 result.x:=a.x-b;
 result.y:=a.y-b;
 result.z:=a.z-b;
 result.w:=a.w-b;
end;

class operator TpvVector4.Subtract(const a:TpvScalar;const b:TpvVector4): TpvVector4;
begin
 result.x:=a-b.x;
 result.y:=a-b.y;
 result.z:=a-b.z;
 result.w:=a-b.w;
end;

class operator TpvVector4.Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector4):TpvVector4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [rdx]
 movups xmm1,dqword ptr [r8]
{$else}
 movups xmm0,dqword ptr [a]
 movups xmm1,dqword ptr [b]
{$ifend}
 mulps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=a.x*b.x;
 result.y:=a.y*b.y;
 result.z:=a.z*b.z;
 result.w:=a.w*b.w;
end;
{$ifend}

class operator TpvVector4.Multiply(const a:TpvVector4;const b:TpvScalar):TpvVector4;
begin
 result.x:=a.x*b;
 result.y:=a.y*b;
 result.z:=a.z*b;
 result.w:=a.w*b;
end;

class operator TpvVector4.Multiply(const a:TpvScalar;const b:TpvVector4):TpvVector4;
begin
 result.x:=a*b.x;
 result.y:=a*b.y;
 result.z:=a*b.z;
 result.w:=a*b.w;
end;

class operator TpvVector4.Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector4):TpvVector4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [rdx]
 movups xmm1,dqword ptr [r8]
{$else}
 movups xmm0,dqword ptr [a]
 movups xmm1,dqword ptr [b]
{$ifend}
 divps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
 result.z:=a.z/b.z;
 result.w:=a.w/b.w;
end;
{$ifend}

class operator TpvVector4.Divide(const a:TpvVector4;const b:TpvScalar):TpvVector4;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
 result.z:=a.z/b;
 result.w:=a.w/b;
end;

class operator TpvVector4.Divide(const a:TpvScalar;const b:TpvVector4):TpvVector4;
begin
 result.x:=a/b.x;
 result.y:=a/b.y;
 result.z:=a/b.z;
 result.w:=a/b.z;
end;

class operator TpvVector4.IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvVector4):TpvVector4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [rdx]
 movups xmm1,dqword ptr [r8]
{$else}
 movups xmm0,dqword ptr [a]
 movups xmm1,dqword ptr [b]
{$ifend}
 divps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
 result.z:=a.z/b.z;
 result.w:=a.w/b.w;
end;
{$ifend}

class operator TpvVector4.IntDivide(const a:TpvVector4;const b:TpvScalar):TpvVector4;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
 result.z:=a.z/b;
 result.w:=a.w/b;
end;

class operator TpvVector4.IntDivide(const a:TpvScalar;const b:TpvVector4):TpvVector4;
begin
 result.x:=a/b.x;
 result.y:=a/b.y;
 result.z:=a/b.z;
 result.w:=a/b.w;
end;

class operator TpvVector4.Modulus(const a,b:TpvVector4):TpvVector4;
begin
 result.x:=Modulus(a.x,b.x);
 result.y:=Modulus(a.y,b.y);
 result.z:=Modulus(a.z,b.z);
 result.w:=Modulus(a.w,b.w);
end;

class operator TpvVector4.Modulus(const a:TpvVector4;const b:TpvScalar):TpvVector4;
begin
 result.x:=Modulus(a.x,b);
 result.y:=Modulus(a.y,b);
 result.z:=Modulus(a.z,b);
 result.w:=Modulus(a.w,b);
end;

class operator TpvVector4.Modulus(const a:TpvScalar;const b:TpvVector4):TpvVector4;
begin
 result.x:=Modulus(a,b.x);
 result.y:=Modulus(a,b.y);
 result.z:=Modulus(a,b.z);
 result.w:=Modulus(a,b.w);
end;

class operator TpvVector4.Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
 xorps xmm0,xmm0
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm1,dqword ptr [rdx]
{$else}
 movups xmm1,dqword ptr [a]
{$ifend}
 subps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=-a.x;
 result.y:=-a.y;
 result.z:=-a.z;
 result.w:=-a.w;
end;
{$ifend}

class operator TpvVector4.Positive(const a:TpvVector4):TpvVector4;
begin
 result:=a;
end;

{$i PasVulkan.Math.TpvVector4.Swizzle.Implementations.inc}

function TpvVector4.GetComponent(const aIndex:TpvInt32):TpvScalar;
begin
 result:=RawComponents[aIndex];
end;

procedure TpvVector4.SetComponent(const aIndex:TpvInt32;const aValue:TpvScalar);
begin
 RawComponents[aIndex]:=aValue;
end;

function TpvVector4.Flip:TpvVector4;
begin
 result.x:=x;
 result.y:=z;
 result.z:=-y;
 result.w:=w;
end;

function TpvVector4.Perpendicular:TpvVector4;
var v,p:TpvVector4;
begin
 v:=self.Normalize;
 p.x:=System.abs(v.x);
 p.y:=System.abs(v.y);
 p.z:=System.abs(v.z);
 p.w:=System.abs(v.w);
 if (p.x<=p.y) and (p.x<=p.z) and (p.x<=p.w) then begin
  p.x:=1.0;
  p.y:=0.0;
  p.z:=0.0;
  p.w:=0.0;
 end else if (p.y<=p.x) and (p.y<=p.z) and (p.y<=p.w) then begin
  p.x:=0.0;
  p.y:=1.0;
  p.z:=0.0;
  p.w:=0.0;
 end else if (p.z<=p.x) and (p.z<=p.y) and (p.z<=p.w) then begin
  p.x:=0.0;
  p.y:=0.0;
  p.z:=0.0;
  p.w:=1.0;
 end else begin
  p.x:=0.0;
  p.y:=0.0;
  p.z:=1.0;
  p.w:=0.0;
 end;
 result:=p-(v*v.Dot(p));
end;

function TpvVector4.Length:TpvScalar;
{$if defined(SIMD) and defined(cpu386)}
asm
 movups xmm0,dqword ptr [eax]
 mulps xmm0,xmm0         // xmm0 = w*w, z*z, y*y, x*x
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$4e    // xmm1 = z*z, w*w, x*x, y*y
 addps xmm0,xmm1         // xmm0 = xmm0 + xmm1 = (zw*zw, zw*zw, xy*zw, xy*zw)
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$b1    // xmm0 = xy*xy, xy*xy, zw*zw, zw*zw
 addps xmm1,xmm0         // xmm1 = xmm1 + xmm0 = (xyzw, xyzw, xyzw, xyzw)
 sqrtss xmm0,xmm1
 movss dword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
(*{$else}
 movups xmm0,dqword ptr [rdi]
{$endif}*)
 mulps xmm0,xmm0         // xmm0 = w*w, z*z, y*y, x*x
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$4e    // xmm1 = z*z, w*w, x*x, y*y
 addps xmm0,xmm1         // xmm0 = xmm0 + xmm1 = (zw*zw, zw*zw, xy*zw, xy*zw)
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$b1    // xmm0 = xy*xy, xy*xy, zw*zw, zw*zw
 addps xmm1,xmm0         // xmm1 = xmm1 + xmm0 = (xyzw, xyzw, xyzw, xyzw)
 sqrtss xmm0,xmm1
{$ifdef fpc}
 movss dword ptr [result],xmm0
{$else}
//movaps xmm0,xmm0
{$endif}
end;
{$else}
begin
 result:=sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));
end;
{$ifend}

function TpvVector4.SquaredLength:TpvScalar;
{$if defined(SIMD) and defined(cpu386)}
asm
 movups xmm0,dqword ptr [eax]
 mulps xmm0,xmm0         // xmm0 = w*w, z*z, y*y, x*x
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$4e    // xmm1 = z*z, w*w, x*x, y*y
 addps xmm0,xmm1         // xmm0 = xmm0 + xmm1 = (zw*zw, zw*zw, xy*zw, xy*zw)
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$b1    // xmm0 = xy*xy, xy*xy, zw*zw, zw*zw
 addps xmm1,xmm0         // xmm1 = xmm1 + xmm0 = (xyzw, xyzw, xyzw, xyzw)
 movss dword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
(*{$else}
 movups xmm0,dqword ptr [rdi]
{$endif}*)
 mulps xmm0,xmm0         // xmm0 = w*w, z*z, y*y, x*x
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$4e    // xmm1 = z*z, w*w, x*x, y*y
 addps xmm0,xmm1         // xmm0 = xmm0 + xmm1 = (zw*zw, zw*zw, xy*zw, xy*zw)
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$b1    // xmm0 = xy*xy, xy*xy, zw*zw, zw*zw
 addps xmm1,xmm0         // xmm1 = xmm1 + xmm0 = (xyzw, xyzw, xyzw, xyzw)
{$ifdef fpc}
 movss dword ptr [result],xmm0
{$else}
//movaps xmm0,xmm0
{$endif}
end;
{$else}
begin
 result:=sqr(x)+sqr(y)+sqr(z)+sqr(w);
end;
{$ifend}

function TpvVector4.Normalize:TpvVector4;
{$if defined(SIMD) and defined(cpu386)}
asm
 movups xmm0,dqword ptr [eax]
 movaps xmm2,xmm0
 mulps xmm0,xmm0         // xmm0 = w*w, z*z, y*y, x*x
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$4e    // xmm1 = z*z, w*w, x*x, y*y
 addps xmm0,xmm1         // xmm0 = xmm0 + xmm1 = (zw*zw, zw*zw, xy*zw, xy*zw)
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$b1    // xmm0 = xy*xy, xy*xy, zw*zw, zw*zw
 addps xmm1,xmm0         // xmm1 = xmm1 + xmm0 = (xyzw, xyzw, xyzw, xyzw)
 sqrtss xmm0,xmm1        // not rsqrtss! because rsqrtss has only 12-bit accuracy
 shufps xmm0,xmm0,$00
 divps xmm2,xmm0
 movaps xmm1,xmm2
 subps xmm1,xmm2
 cmpps xmm1,xmm2,7
 andps xmm2,xmm1
 movups dqword ptr [edx],xmm2
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
(*{$else}
 movups xmm0,dqword ptr [rdi]
{$endif}*)
 movaps xmm2,xmm0
 mulps xmm0,xmm0         // xmm0 = w*w, z*z, y*y, x*x
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$4e    // xmm1 = z*z, w*w, x*x, y*y
 addps xmm0,xmm1         // xmm0 = xmm0 + xmm1 = (zw*zw, zw*zw, xy*zw, xy*zw)
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$b1    // xmm0 = xy*xy, xy*xy, zw*zw, zw*zw
 addps xmm1,xmm0         // xmm1 = xmm1 + xmm0 = (xyzw, xyzw, xyzw, xyzw)
 sqrtss xmm0,xmm1        // not rsqrtss! because rsqrtss has only 12-bit accuracy
 shufps xmm0,xmm0,$00
 divps xmm2,xmm0
 movaps xmm1,xmm2
 subps xmm1,xmm2
 cmpps xmm1,xmm2,7
 andps xmm2,xmm1
//{$ifdef Windows}
 movups dqword ptr [rdx],xmm2
(*{$else}
 movups dqword ptr [rax],xmm2
{$endif}*)
end;
{$else}
var Factor:TpvScalar;
begin
 Factor:=sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));
 if Factor<>0.0 then begin
  Factor:=1.0/Factor;
  result.x:=x*Factor;
  result.y:=y*Factor;
  result.z:=z*Factor;
  result.w:=w*Factor;
 end else begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
  result.w:=0.0;
 end;
end;
{$ifend}

function TpvVector4.DistanceTo({$ifdef fpc}constref{$else}const{$endif} b:TpvVector4):TpvScalar;
{$if defined(SIMD) and defined(cpu386)}
asm
 movups xmm0,dqword ptr [eax]
 movups xmm1,dqword ptr [edx]
 subps xmm0,xmm1
 mulps xmm0,xmm0         // xmm0 = w*w, z*z, y*y, x*x
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$4e    // xmm1 = z*z, w*w, x*x, y*y
 addps xmm0,xmm1         // xmm0 = xmm0 + xmm1 = (zw*zw, zw*zw, xy*zw, xy*zw)
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$b1    // xmm0 = xy*xy, xy*xy, zw*zw, zw*zw
 addps xmm1,xmm0         // xmm1 = xmm1 + xmm0 = (xyzw, xyzw, xyzw, xyzw)
 sqrtss xmm0,xmm1
 movss dword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
 movups xmm1,dqword ptr [rdx]
(*{$else}
 movups xmm0,dqword ptr [rdi]
 movups xmm1,dqword ptr [rsi]
{$endif}*)
 subps xmm0,xmm1
 mulps xmm0,xmm0         // xmm0 = w*w, z*z, y*y, x*x
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$4e    // xmm1 = z*z, w*w, x*x, y*y
 addps xmm0,xmm1         // xmm0 = xmm0 + xmm1 = (zw*zw, zw*zw, xy*zw, xy*zw)
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$b1    // xmm0 = xy*xy, xy*xy, zw*zw, zw*zw
 addps xmm1,xmm0         // xmm1 = xmm1 + xmm0 = (xyzw, xyzw, xyzw, xyzw)
 sqrtss xmm0,xmm1
{$ifdef fpc}
 movss dword ptr [result],xmm0
{$else}
//movaps xmm0,xmm0
{$endif}
end;
{$else}
begin
 result:=sqrt(sqr(x-b.x)+sqr(y-b.y)+sqr(z-b.z)+sqr(w-b.w));
end;
{$ifend}

function TpvVector4.Abs:TpvVector4;
{$if defined(SIMD) and defined(cpu386)}
asm
 movups xmm0,dqword ptr [eax]
 xorps xmm1,xmm1
 subps xmm1,xmm0
 maxps xmm0,xmm1
 movups dqword ptr [edx],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
(*{$else}
 movups xmm0,dqword ptr [rdi]
{$endif}*)
 xorps xmm1,xmm1
 subps xmm1,xmm0
 maxps xmm0,xmm1
//{$ifdef Windows}
 movups dqword ptr [rdx],xmm0
(*{$else}
 movups dqword ptr [rax],xmm0
{$endif}*)
end;
{$else}
begin
 result.x:=System.abs(x);
 result.y:=System.abs(y);
 result.z:=System.abs(z);
 result.w:=System.abs(w);
end;
{$ifend}

function TpvVector4.Dot({$ifdef fpc}constref{$else}const{$endif} b:TpvVector4):TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend}
{$if defined(SIMD) and defined(cpu386)}
asm
 movups xmm0,dqword ptr [eax]
 movups xmm1,dqword ptr [edx]
 mulps xmm0,xmm1
 movaps xmm1,xmm0
 shufps xmm1,xmm0,$b1
 addps xmm0,xmm1
 movhlps xmm1,xmm0
 addss xmm0,xmm1
 movss dword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
 movups xmm1,dqword ptr [rdx]
(*{$else}
 movups xmm0,dqword ptr [rdi]
 movups xmm1,dqword ptr [rsi]
{$endif}*)
 mulps xmm0,xmm1
 movaps xmm1,xmm0
 shufps xmm1,xmm0,$b1
 addps xmm0,xmm1
 movhlps xmm1,xmm0
 addss xmm0,xmm1
{$ifdef fpc}
 movss dword ptr [result],xmm0
{$else}
//movaps xmm0,xmm0
{$endif}
end;
{$else}
begin
 result:=(x*b.x)+(y*b.y)+(z*b.z)+(w*b.w);
end;
{$ifend}

function TpvVector4.AngleTo(const b:TpvVector4):TpvScalar;
var d:single;
begin
 d:=sqrt(SquaredLength*b.SquaredLength);
 if d<>0.0 then begin
  result:=Dot(b)/d;
 end else begin
  result:=0.0;
 end
end;

function TpvVector4.Cross({$ifdef fpc}constref{$else}const{$endif} b:TpvVector4):TpvVector4;
{$if defined(SIMD) and defined(cpu386)}
const AndMask:array[0..3] of TpvUInt32=($ffffffff,$ffffffff,$ffffffff,$00000000);
      OrMask:array[0..3] of TpvUInt32=($00000000,$00000000,$00000000,$3f800000);
asm
{$ifdef SSEVector3CrossOtherVariant}
 movups xmm0,dqword ptr [eax]
 movups xmm2,dqword ptr [edx]
 movups xmm4,dqword ptr [AndMask]
 movups xmm5,dqword ptr [OrMask]
 andps xmm0,xmm4
 andps xmm2,xmm4
 movaps xmm1,xmm0
 movaps xmm3,xmm2
 shufps xmm0,xmm0,$c9
 shufps xmm1,xmm1,$d2
 shufps xmm2,xmm2,$d2
 shufps xmm3,xmm3,$c9
 mulps xmm0,xmm2
 mulps xmm1,xmm3
 subps xmm0,xmm1
 andps xmm0,xmm4
 orps xmm0,xmm5
 movups dqword ptr [ecx],xmm0
{$else}
 movups xmm0,dqword ptr [eax]
 movups xmm1,dqword ptr [edx]
 movups xmm4,dqword ptr [AndMask]
 movups xmm5,dqword ptr [OrMask]
 andps xmm0,xmm4
 andps xmm1,xmm4
 movaps xmm2,xmm0
 movaps xmm3,xmm1
 shufps xmm0,xmm0,$12
 shufps xmm1,xmm1,$09
 shufps xmm2,xmm2,$09
 shufps xmm3,xmm3,$12
 mulps xmm0,xmm1
 mulps xmm2,xmm3
 subps xmm2,xmm0
 andps xmm2,xmm4
 orps xmm2,xmm5
 movups dqword ptr [ecx],xmm2
{$endif}
end;
{$elseif defined(SIMD) and defined(cpux64)}
const AndMask:array[0..3] of TpvUInt32=($ffffffff,$ffffffff,$ffffffff,$00000000);
      OrMask:array[0..3] of TpvUInt32=($00000000,$00000000,$00000000,$3f800000);
asm
{$ifdef SSEVector3CrossOtherVariant}
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
 movups xmm2,dqword ptr [r8]
(*{$else}
 movups xmm0,dqword ptr [rdi]
 movups xmm2,dqword ptr [rsi]
{$endif}*)
{$ifdef fpc}
 movups xmm4,dqword ptr [rip+AndMask]
 movups xmm5,dqword ptr [rip+OrMask]
{$else}
 movups xmm4,dqword ptr [rel AndMask]
 movups xmm5,dqword ptr [rel OrMask]
{$endif}
 andps xmm0,xmm4
 andps xmm2,xmm4
 movaps xmm1,xmm0
 movaps xmm3,xmm2
 shufps xmm0,xmm0,$c9
 shufps xmm1,xmm1,$d2
 shufps xmm2,xmm2,$d2
 shufps xmm3,xmm3,$c9
 mulps xmm0,xmm2
 mulps xmm1,xmm3
 subps xmm0,xmm1
 andps xmm0,xmm4
 orps xmm0,xmm5
//{$ifdef Windows}
 movups dqword ptr [rdx],xmm0
(*{$else}
 movups dqword ptr [rax],xmm0
{$endif}*)
{$else}
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
 movups xmm1,dqword ptr [r8]
(*{$else}
 movups xmm0,dqword ptr [rdi]
 movups xmm1,dqword ptr [rsi]
{$endif}*)
{$ifdef fpc}
 movups xmm4,dqword ptr [rip+AndMask]
 movups xmm5,dqword ptr [rip+OrMask]
{$else}
 movups xmm4,dqword ptr [rel AndMask]
 movups xmm5,dqword ptr [rel OrMask]
{$endif}
 andps xmm0,xmm4
 andps xmm1,xmm4
 movaps xmm2,xmm0
 movaps xmm3,xmm1
 shufps xmm0,xmm0,$12
 shufps xmm1,xmm1,$09
 shufps xmm2,xmm2,$09
 shufps xmm3,xmm3,$12
 mulps xmm0,xmm1
 mulps xmm2,xmm3
 subps xmm2,xmm0
 andps xmm2,xmm4
 orps xmm2,xmm5
//{$ifdef Windows}
 movups dqword ptr [rdx],xmm2
(*{$else}
 movups dqword ptr [rax],xmm2
{$endif}*)
{$endif}
end;
{$else}
begin
 result.x:=(y*b.z)-(z*b.y);
 result.y:=(z*b.x)-(x*b.z);
 result.z:=(x*b.y)-(y*b.x);
 result.w:=1.0;
end;
{$ifend}

function TpvVector4.Lerp(const aToVector:TpvVector4;const aTime:TpvScalar):TpvVector4;
var InvT:TpvScalar;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aToVector;
 end else begin
  InvT:=1.0-aTime;
  result.x:=(x*InvT)+(aToVector.x*aTime);
  result.y:=(y*InvT)+(aToVector.y*aTime);
  result.z:=(z*InvT)+(aToVector.z*aTime);
  result.w:=(w*InvT)+(aToVector.w*aTime);
 end;
end;

function TpvVector4.Nlerp(const aToVector:TpvVector4;const aTime:TpvScalar):TpvVector4;
begin
 result:=self.Lerp(aToVector,aTime).Normalize;
end;

function TpvVector4.Slerp(const aToVector:TpvVector4;const aTime:TpvScalar):TpvVector4;
var DotProduct,Theta,Sinus,Cosinus:TpvScalar;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aToVector;
 end else if self=aToVector then begin
  result:=aToVector;
 end else begin
  DotProduct:=self.Dot(aToVector);
  if DotProduct<-1.0 then begin
   DotProduct:=-1.0;
  end else if DotProduct>1.0 then begin
   DotProduct:=1.0;
  end;
  Theta:=ArcCos(DotProduct)*aTime;
  Sinus:=0.0;
  Cosinus:=0.0;
  SinCos(Theta,Sinus,Cosinus);
  result:=(self*Cosinus)+((aToVector-(self*DotProduct)).Normalize*Sinus);
 end;
end;

function TpvVector4.Sqlerp(const aB,aC,aD:TpvVector4;const aTime:TpvScalar):TpvVector4;
begin
 result:=Slerp(aD,aTime).Slerp(aB.Slerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

function TpvVector4.Angle(const aOtherFirstVector,aOtherSecondVector:TpvVector4):TpvScalar;
var DeltaAB,DeltaCB:TpvVector4;
    LengthAB,LengthCB:TpvScalar;
begin
 DeltaAB:=self-aOtherFirstVector;
 DeltaCB:=aOtherSecondVector-aOtherFirstVector;
 LengthAB:=DeltaAB.Length;
 LengthCB:=DeltaCB.Length;
 if (LengthAB=0.0) or (LengthCB=0.0) then begin
  result:=0.0;
 end else begin
  result:=ArcCos(DeltaAB.Dot(DeltaCB)/(LengthAB*LengthCB));
 end;
end;

function TpvVector4.RotateX(const aAngle:TpvScalar):TpvVector4;
var Sinus,Cosinus:TpvScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(aAngle,Sinus,Cosinus);
 result.x:=x;
 result.y:=(y*Cosinus)-(z*Sinus);
 result.z:=(y*Sinus)+(z*Cosinus);
 result.w:=w;
end;

function TpvVector4.RotateY(const aAngle:TpvScalar):TpvVector4;
var Sinus,Cosinus:TpvScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(aAngle,Sinus,Cosinus);
 result.x:=(z*Sinus)+(x*Cosinus);
 result.y:=y;
 result.z:=(z*Cosinus)-(x*Sinus);
 result.w:=w;
end;

function TpvVector4.RotateZ(const aAngle:TpvScalar):TpvVector4;
var Sinus,Cosinus:TpvScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(aAngle,Sinus,Cosinus);
 result.x:=(x*Cosinus)-(y*Sinus);
 result.y:=(x*Sinus)+(y*Cosinus);
 result.z:=z;
 result.w:=w;
end;

function TpvVector4.Rotate(const aAngle:TpvScalar;const aAxis:TpvVector3):TpvVector4;
begin
 result:=TpvMatrix4x4.CreateRotate(aAngle,aAxis)*self;
end;

function TpvVector4.ProjectToBounds(const aMinVector,aMaxVector:TpvVector4):TpvScalar;
begin
 if x<0.0 then begin
  result:=x*aMaxVector.x;
 end else begin
  result:=x*aMinVector.x;
 end;
 if y<0.0 then begin
  result:=result+(y*aMaxVector.y);
 end else begin
  result:=result+(y*aMinVector.y);
 end;
 if z<0.0 then begin
  result:=result+(z*aMaxVector.z);
 end else begin
  result:=result+(z*aMinVector.z);
 end;
 if w<0.0 then begin
  result:=result+(w*aMaxVector.w);
 end else begin
  result:=result+(w*aMinVector.w);
 end;
end;

{$i PasVulkan.Math.TpvVector2Helper.Swizzle.Implementations.inc}
{$i PasVulkan.Math.TpvVector3Helper.Swizzle.Implementations.inc}
{$i PasVulkan.Math.TpvVector4Helper.Swizzle.Implementations.inc}

constructor TpvPlane.Create(const aNormal:TpvVector3;const aDistance:TpvScalar);
begin
 Normal:=aNormal;
 Distance:=aDistance;
end;

constructor TpvPlane.Create(const aX,aY,aZ,aDistance:TpvScalar);
begin
 Normal.x:=aX;
 Normal.y:=aY;
 Normal.z:=aZ;
 Distance:=aDistance;
end;

constructor TpvPlane.Create(const aA,aB,aC:TpvVector3);
begin
 Normal:=((aB-aA).Cross(aC-aA)).Normalize;
 Distance:=-((Normal.x*aA.x)+(Normal.y*aA.y)+(Normal.z*aA.z));
end;

constructor TpvPlane.Create(const aA,aB,aC:TpvVector4);
begin
 Normal:=((aB.xyz-aA.xyz).Cross(aC.xyz-aA.xyz)).Normalize;
 Distance:=-((Normal.x*aA.x)+(Normal.y*aA.y)+(Normal.z*aA.z));
end;

constructor TpvPlane.Create(const aVector:TpvVector4);
begin
 Normal.x:=aVector.x;
 Normal.y:=aVector.y;
 Normal.z:=aVector.z;
 Distance:=aVector.w;
end;

function TpvPlane.ToVector:TpvVector4;
begin
 result.x:=Normal.x;
 result.y:=Normal.y;
 result.z:=Normal.z;
 result.w:=Distance;
end;

function TpvPlane.Normalize:TpvPlane;
var l:TpvScalar;
begin
 l:=Normal.Length;
 if l>0.0 then begin
  l:=1.0/l;
  result.Normal:=Normal*l;
  result.Distance:=Distance*l;
 end else begin
  result.Normal:=0.0;
  result.Distance:=0.0;
 end;
end;

function TpvPlane.DistanceTo(const aPoint:TpvVector3):TpvScalar;
begin
 result:=Normal.Dot(aPoint)+Distance;
end;

function TpvPlane.DistanceTo(const aPoint:TpvVector4):TpvScalar;
begin
 result:=Normal.Dot(aPoint.xyz)+(aPoint.w*Distance);
end;

procedure TpvPlane.ClipSegment(const aP0,aP1:TpvVector3;out aClipped:TpvVector3);
begin
 aClipped:=aP0+((aP1-aP0).Normalize*(-DistanceTo(aP0)));
//aClipped:=aP0+((aP1-aP0)*((-DistanceTo(aP0))/Normal.Dot(aP1-aP0)));
end;

function TpvPlane.ClipSegmentClosest(const aP0,aP1:TpvVector3;out aClipped0,aClipped1:TpvVector3):TpvInt32;
var d0,d1:TpvScalar;
begin
 d0:=-DistanceTo(aP0);
 d1:=-DistanceTo(aP1);
 if (d0>(-EPSILON)) and (d1>(-EPSILON)) then begin
  if d0<d1 then begin
   result:=0;
   aClipped0:=aP0;
   aClipped1:=aP1;
  end else begin
   result:=1;
   aClipped0:=aP1;
   aClipped1:=aP0;
  end;
 end else if (d0<EPSILON) and (d1<EPSILON) then begin
  if d0>d1 then begin
   result:=2;
   aClipped0:=aP0;
   aClipped1:=aP1;
  end else begin
   result:=3;
   aClipped0:=aP1;
   aClipped1:=aP0;
  end;
 end else begin
  if d0<d1 then begin
   result:=4;
   aClipped1:=aP0;
  end else begin
   result:=5;
   aClipped1:=aP1;
  end;
  aClipped0:=aP1-aP0;
  aClipped0:=aP0+(aClipped0*((-d0)/Normal.Dot(aClipped0)));
 end;
end;

function TpvPlane.ClipSegmentLine(var aP0,aP1:TpvVector3):boolean;
var d0,d1:TpvScalar;
    o0,o1:boolean;
begin
 d0:=DistanceTo(aP0);
 d1:=DistanceTo(aP1);
 o0:=d0<0.0;
 o1:=d1<0.0;
 if o0 and o1 then begin
  // Both points are below which means that the whole line segment is below => return false
  result:=false;
 end else begin
  // At least one point is above or in the plane which means that the line segment is above => return true
  if (o0<>o1) and (abs(d0-d1)>EPSILON) then begin
   if o0 then begin
    // aP1 is above or in the plane which means that the line segment is above => clip l0
    aP0:=aP0+((aP1-aP0)*(d0/(d0-d1)));
   end else begin
    // aP0 is above or in the plane which means that the line segment is above => clip l1
    aP1:=aP0+((aP1-aP0)*(d0/(d0-d1)));
   end;
  end else begin
   // Near parallel case => no clipping
  end;
  result:=true;
 end;
end;

constructor TpvQuaternion.Create(const aX:TpvScalar);
begin
 x:=aX;
 y:=aX;
 z:=aX;
 w:=aX;
end;

constructor TpvQuaternion.Create(const aX,aY,aZ,aW:TpvScalar);
begin
 x:=aX;
 y:=aY;
 z:=aZ;
 w:=aW;
end;

constructor TpvQuaternion.Create(const aVector:TpvVector4);
begin
 Vector:=aVector;
end;

constructor TpvQuaternion.CreateFromScaledAngleAxis(const aScaledAngleAxis:TpvVector3);
var Angle,Sinus,Coefficent:TpvScalar;
    t:TpvVector3;
begin
 t:=aScaledAngleAxis*0.5;
 Angle:=sqrt(sqr(t.x)+sqr(t.y)+sqr(t.z));
 Sinus:=sin(Angle);
 w:=cos(Angle);
 if System.Abs(Sinus)>1e-6 then begin
  Coefficent:=Sinus/Angle;
  x:=t.x*Coefficent;
  y:=t.y*Coefficent;
  z:=t.z*Coefficent;
 end else begin
  x:=t.x;
  y:=t.y;
  z:=t.z;
 end;
end;

constructor TpvQuaternion.CreateFromAngularVelocity(const aAngularVelocity:TpvVector3);
var Magnitude,Sinus,Cosinus,SinusGain:TpvScalar;
begin
 Magnitude:=aAngularVelocity.Length;
 if Magnitude<EPSILON then begin
  x:=0.0;
  y:=0.0;
  z:=0.0;
  w:=1.0;
 end else begin
  SinCos(Magnitude*0.5,Sinus,Cosinus);
  SinusGain:=Sinus/Magnitude;
  x:=aAngularVelocity.x*SinusGain;
  y:=aAngularVelocity.y*SinusGain;
  z:=aAngularVelocity.z*SinusGain;
  w:=Cosinus;
 end;
end;

constructor TpvQuaternion.CreateFromAngleAxis(const aAngle:TpvScalar;const aAxis:TpvVector3);
var s:TpvScalar;
begin
{s:=sin(aAngle*0.5);
 w:=cos(aAngle*0.5);}
 SinCos(aAngle*0.5,s,w);
 x:=aAxis.x*s;
 y:=aAxis.y*s;
 z:=aAxis.z*s;
 self:=self.Normalize;
end;

constructor TpvQuaternion.CreateFromEuler(const aPitch,aYaw,aRoll:TpvScalar);
var sp,sy,sr,cp,cy,cr:TpvScalar;
begin
 // Order of rotations: aRoll (Z), aPitch (X), aYaw (Y)
 SinCos(aPitch*0.5,sp,cp);
 SinCos(aYaw*0.5,sy,cy);
 SinCos(aRoll*0.5,sr,cr);
{sp:=sin(aPitch*0.5);
 sy:=sin(aYaw*0.5);
 sr:=sin(aRoll*0.5);
 cp:=cos(aPitch*0.5);
 cy:=cos(aYaw*0.5);
 cr:=cos(aRoll*0.5);}
 Vector:=TpvVector4.Create((sp*cy*cr)+(cp*sy*sr),
                           (cp*sy*cr)-(sp*cy*sr),
                           (cp*cy*sr)-(sp*sy*cr),
                           (cp*cy*cr)+(sp*sy*sr)
                          ).Normalize;
end;

constructor TpvQuaternion.CreateFromEuler(const aAngles:TpvVector3);
var sp,sy,sr,cp,cy,cr:TpvScalar;
begin
 // Order of rotations: Roll (Z), Pitch (X), Yaw (Y)
 SinCos(aAngles.Pitch*0.5,sp,cp);
 SinCos(aAngles.Yaw*0.5,sy,cy);
 SinCos(aAngles.Roll*0.5,sr,cr);
{sp:=sin(aAngles.Pitch*0.5);
 sy:=sin(aAngles.Yaw*0.5);
 sr:=sin(aAngles.Roll*0.5);
 cp:=cos(aAngles.Pitch*0.5);
 cy:=cos(aAngles.Yaw*0.5);
 cr:=cos(aAngles.Roll*0.5);//}
 Vector:=TpvVector4.Create((sp*cy*cr)+(cp*sy*sr),
                           (cp*sy*cr)-(sp*cy*sr),
                           (cp*cy*sr)-(sp*sy*cr),
                           (cp*cy*cr)+(sp*sy*sr)
                          ).Normalize;
end;

constructor TpvQuaternion.CreateFromNormalizedSphericalCoordinates(const aNormalizedSphericalCoordinates:TpvNormalizedSphericalCoordinates);
begin
 x:=cos(aNormalizedSphericalCoordinates.Latitude)*sin(aNormalizedSphericalCoordinates.Longitude);
 y:=sin(aNormalizedSphericalCoordinates.Latitude);
 z:=cos(aNormalizedSphericalCoordinates.Latitude)*cos(aNormalizedSphericalCoordinates.Longitude);
 w:=0.0;
end;

constructor TpvQuaternion.CreateFromToRotation(const aFromDirection,aToDirection:TpvVector3);
var FromDirection,ToDirection:TpvVector3;
    DotProduct:TpvScalar;
begin
 FromDirection:=aFromDirection.Normalize;
 ToDirection:=aToDirection.Normalize;
 DotProduct:=FromDirection.Dot(ToDirection);
 if System.Abs(DotProduct)>=1.0 then begin
  if DotProduct>0.0 then begin
   self:=TpvQuaternion.Identity;
  end else begin
   self:=TpvQuaternion.CreateFromAngleAxis(PI,FromDirection.Perpendicular);
  end;
 end else begin
  Vector.xyz:=FromDirection.Cross(ToDirection);
  Vector.w:=DotProduct+sqrt(FromDirection.SquaredLength*ToDirection.SquaredLength);
  Vector:=Vector.Normalize;
 end;
end;

constructor TpvQuaternion.CreateFromLookRotation(const aForward,aUp:TpvVector3);
var m0,m1,m2:TpvVector3;
    t,s:TpvScalar;
begin
 m2:=aForward.Normalize;
 m0:=((aUp.Normalize).Cross(aForward)).Normalize;
 m1:=(m2.Cross(m0)).Normalize;
 t:=m0.x+(m1.y+m2.z);
 if t>2.9999999 then begin
  self.x:=0.0;
  self.y:=0.0;
  self.z:=0.0;
  self.w:=1.0;
 end else if t>0.0000001 then begin
  s:=sqrt(1.0+t)*2.0;
  self.x:=(m1.z-m2.y)/s;
  self.y:=(m2.x-m0.z)/s;
  self.z:=(m0.y-m1.x)/s;
  self.w:=s*0.25;
 end else if (m0.x>m1.y) and (m0.x>m2.z) then begin
  s:=sqrt(1.0+(m0.x-(m1.y+m2.z)))*2.0;
  self.x:=s*0.25;
  self.y:=(m1.x+m0.y)/s;
  self.z:=(m2.x+m0.z)/s;
  self.w:=(m1.z-m2.y)/s;
 end else if m1.y>m2.z then begin
  s:=sqrt(1.0+(m1.y-(m0.x+m2.z)))*2.0;
  self.x:=(m1.x+m0.y)/s;
  self.y:=s*0.25;
  self.z:=(m2.y+m1.z)/s;
  self.w:=(m2.x-m0.z)/s;
 end else begin
  s:=sqrt(1.0+(m2.z-(m0.x+m1.y)))*2.0;
  self.x:=(m2.x+m0.z)/s;
  self.y:=(m2.y+m1.z)/s;
  self.z:=s*0.25;
  self.w:=(m0.y-m1.x)/s;
 end;
 self:=self.Normalize;
end;

constructor TpvQuaternion.CreateFromCols(const aC0,aC1,aC2:TpvVector3);
begin
 if aC2.z<0.0 then begin
  if aC0.x>aC1.y then begin
   self:=TpvQuaternion.Create(((1.0+aC0.x)-aC1.y)-aC2.z,aC0.y+aC1.x,aC2.x+aC0.Z,aC1.z-aC2.y).Normalize;
  end else begin
   self:=TpvQuaternion.Create(aC0.y+aC1.x,((1.0-aC0.x)+aC1.y)-aC2.z,aC1.z+aC2.y,aC2.x-aC0.z).Normalize;
  end;
 end else begin
  if aC0.x<-aC1.y then begin
   self:=TpvQuaternion.Create(aC2.x+aC0.z,aC1.z+aC2.y,((1.0-aC0.x)-aC1.y)+aC2.z,aC0.y-aC1.x).Normalize;
  end else begin
   self:=TpvQuaternion.Create(aC1.z-aC2.y,aC2.x-aC0.z,aC0.y-aC1.x,((1.0+aC0.x)+aC1.y)+aC2.z).Normalize;
  end;
 end;
end;

constructor TpvQuaternion.CreateFromXY(const aX,aY:TpvVector3);
var c0,c1,c2:TpvVector3;
begin
 c2:=(aX.Cross(aY)).Normalize;
 c1:=(c2.Cross(aX)).Normalize;
 c0:=aX.Normalize;
 self:=TpvQuaternion.CreateFromCols(c0,c1,c2);
end;

class operator TpvQuaternion.Implicit(const a:TpvScalar):TpvQuaternion;
begin
 result.x:=a;
 result.y:=a;
 result.z:=a;
 result.w:=a;
end;

class operator TpvQuaternion.Explicit(const a:TpvScalar):TpvQuaternion;
begin
 result.x:=a;
 result.y:=a;
 result.z:=a;
 result.w:=a;
end;

class operator TpvQuaternion.Equal(const a,b:TpvQuaternion):boolean;
begin
 result:=SameValue(a.x,b.x) and SameValue(a.y,b.y) and SameValue(a.z,b.z) and SameValue(a.w,b.w);
end;

class operator TpvQuaternion.NotEqual(const a,b:TpvQuaternion):boolean;
begin
 result:=(not SameValue(a.x,b.x)) or (not SameValue(a.y,b.y)) or (not SameValue(a.z,b.z)) or (not SameValue(a.w,b.w));
end;

class operator TpvQuaternion.Inc({$ifdef fpc}constref{$else}const{$endif} a:TpvQuaternion):TpvQuaternion;
{$if defined(SIMD) and defined(cpu386)}
const One:TpvQuaternion=(x:1.0;y:1.0;z:1.0;w:1.0);
asm
 movups xmm0,dqword ptr [a]
 movups xmm1,dqword ptr [One]
 addps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
const One:TpvQuaternion=(x:1.0;y:1.0;z:1.0;w:1.0);
asm
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [rdx]
{$else}
 movups xmm0,dqword ptr [a]
{$ifend}
{$ifdef fpc}
 movups xmm1,dqword ptr [rip+One]
{$else}
 movups xmm1,dqword ptr [rel One]
{$endif}
 addps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=a.x+1.0;
 result.y:=a.y+1.0;
 result.z:=a.z+1.0;
 result.w:=a.w+1.0;
end;
{$ifend}

class operator TpvQuaternion.Dec({$ifdef fpc}constref{$else}const{$endif} a:TpvQuaternion):TpvQuaternion;
{$if defined(SIMD) and defined(cpu386)}
const One:TpvQuaternion=(x:1.0;y:1.0;z:1.0;w:1.0);
asm
 movups xmm0,dqword ptr [a]
 movups xmm1,dqword ptr [One]
 subps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
const One:TpvQuaternion=(x:1.0;y:1.0;z:1.0;w:1.0);
asm
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [rdx]
{$else}
 movups xmm0,dqword ptr [a]
{$ifend}
{$ifdef fpc}
 movups xmm1,dqword ptr [rip+One]
{$else}
 movups xmm1,dqword ptr [rel One]
{$endif}
 subps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=a.x-1.0;
 result.y:=a.y-1.0;
 result.z:=a.z-1.0;
 result.w:=a.w-1.0;
end;
{$ifend}

class operator TpvQuaternion.Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvQuaternion):TpvQuaternion;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [rdx]
 movups xmm1,dqword ptr [r8]
{$else}
 movups xmm0,dqword ptr [a]
 movups xmm1,dqword ptr [b]
{$ifend}
 addps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=a.x+b.x;
 result.y:=a.y+b.y;
 result.z:=a.z+b.z;
 result.w:=a.w+b.w;
end;
{$ifend}

class operator TpvQuaternion.Add(const a:TpvQuaternion;const b:TpvScalar):TpvQuaternion;
begin
 result.x:=a.x+b;
 result.y:=a.y+b;
 result.z:=a.z+b;
 result.w:=a.w+b;
end;

class operator TpvQuaternion.Add(const a:TpvScalar;const b:TpvQuaternion):TpvQuaternion;
begin
 result.x:=a+b.x;
 result.y:=a+b.y;
 result.z:=a+b.z;
 result.w:=a+b.w;
end;

class operator TpvQuaternion.Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvQuaternion):TpvQuaternion;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [rdx]
 movups xmm1,dqword ptr [r8]
{$else}
 movups xmm0,dqword ptr [a]
 movups xmm1,dqword ptr [b]
{$ifend}
 subps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=a.x-b.x;
 result.y:=a.y-b.y;
 result.z:=a.z-b.z;
 result.w:=a.w-b.w;
end;
{$ifend}

class operator TpvQuaternion.Subtract(const a:TpvQuaternion;const b:TpvScalar):TpvQuaternion;
begin
 result.x:=a.x-b;
 result.y:=a.y-b;
 result.z:=a.z-b;
 result.w:=a.w-b;
end;

class operator TpvQuaternion.Subtract(const a:TpvScalar;const b:TpvQuaternion): TpvQuaternion;
begin
 result.x:=a-b.x;
 result.y:=a-b.y;
 result.z:=a-b.z;
 result.w:=a-b.w;
end;

class operator TpvQuaternion.Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvQuaternion):TpvQuaternion;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
const XORMaskW:array[0..3] of TpvUInt32=($00000000,$00000000,$00000000,$80000000);
asm
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm4,dqword ptr [rdx]
{$else}
 movups xmm4,dqword ptr [a]
{$ifend}
 movaps xmm0,xmm4
 shufps xmm0,xmm4,$49
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm2,dqword ptr [r8]
{$else}
 movups xmm2,dqword ptr [b]
{$ifend}
 movaps xmm3,xmm2
 movaps xmm1,xmm2
 shufps xmm3,xmm2,$52 // 001010010b
 mulps xmm3,xmm0
 movaps xmm0,xmm4
 shufps xmm0,xmm4,$24 // 000100100b
 shufps xmm1,xmm2,$3f // 000111111b
{$ifdef cpu386}
 movups xmm5,dqword ptr [XORMaskW]
{$else}
{$ifdef fpc}
 movups xmm5,dqword ptr [rip+XORMaskW]
{$else}
 movups xmm5,dqword ptr [rel XORMaskW]
{$endif}
{$endif}
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
 result.x:=((a.w*b.x)+(a.x*b.w)+(a.y*b.z))-(a.z*b.y);
 result.y:=((a.w*b.y)+(a.y*b.w)+(a.z*b.x))-(a.x*b.z);
 result.z:=((a.w*b.z)+(a.z*b.w)+(a.x*b.y))-(a.y*b.x);
 result.w:=(a.w*b.w)-((a.x*b.x)+(a.y*b.y)+(a.z*b.z));
end;
{$ifend}

class operator TpvQuaternion.Multiply(const a:TpvQuaternion;const b:TpvScalar):TpvQuaternion;
begin
 result.x:=a.x*b;
 result.y:=a.y*b;
 result.z:=a.z*b;
 result.w:=a.w*b;
end;

class operator TpvQuaternion.Multiply(const a:TpvScalar;const b:TpvQuaternion):TpvQuaternion;
begin
 result.x:=a*b.x;
 result.y:=a*b.y;
 result.z:=a*b.z;
 result.w:=a*b.w;
end;

class operator TpvQuaternion.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvQuaternion;{$ifdef fpc}constref{$else}const{$endif} b:TpvVector3):TpvVector3;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
const Mask:array[0..3] of TpvUInt32=($ffffffff,$ffffffff,$ffffffff,$00000000);
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}

 // q = a
 // v = b

{$if defined(ExplicitX64SIMDRegs)}
 movups xmm4,dqword ptr [rdx] // xmm4 = q.xyzw
{$else}
 movups xmm4,dqword ptr [a] // xmm4 = q.xyzw
{$ifend}

 xorps xmm7,xmm7
{$if defined(ExplicitX64SIMDRegs)}
 movss xmm5,dword ptr [r8+0]
 movss xmm6,dword ptr [r8+4]
 movss xmm7,dword ptr [r8+8]
{$else}
 movss xmm5,dword ptr [b+0]
 movss xmm6,dword ptr [b+4]
 movss xmm7,dword ptr [b+8]
{$ifend}
 movlhps xmm5,xmm6
 shufps xmm5,xmm7,$88
//movups xmm5,dqword ptr [b] // xmm5 = v.xyz?

 movaps xmm6,xmm4
 shufps xmm6,xmm6,$ff // xmm6 = q.wwww

{$ifdef cpu386}
 movups xmm7,dqword ptr [Mask] // xmm7 = Mask
{$else}
{$ifdef fpc}
 movups xmm7,dqword ptr [rip+Mask] // xmm7 = Mask
{$else}
 movups xmm7,dqword ptr [rel Mask] // xmm7 = Mask
{$endif}
{$endif}

 andps xmm4,xmm7 // xmm4 = q.xyz0

 andps xmm5,xmm7 // xmm5 = v.xyz0

 // t:=Vector3ScalarMul(Vector3Cross(qv,v),2.0);
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

 // xmm6 = Vector3Add(v,Vector3ScalarMul(t,q.w))
 mulps xmm6,xmm2 // xmm6 = q.wwww, xmm2 = t
 addps xmm6,xmm5 // xmm5 = v

 // Vector3Cross(qv,t)
 movaps xmm1,xmm4 // xmm4 = qv
 movaps xmm3,xmm2 // xmm2 = t
 shufps xmm4,xmm4,$12
 shufps xmm2,xmm2,$09
 shufps xmm1,xmm1,$09
 shufps xmm3,xmm3,$12
 mulps xmm4,xmm2
 mulps xmm1,xmm3
 subps xmm1,xmm4

 // result:=Vector3Add(Vector3Add(v,Vector3ScalarMul(t,q.w)),Vector3Cross(qv,t));
 addps xmm1,xmm6

 movaps xmm0,xmm1
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
//movups dqword ptr [result],xmm1

{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}

end;
{$else}
var t:TpvVector3;
begin
 // q = a
 // v = b
 // t = 2 * cross(q.xyz, v)
 // v' = v + q.w * t + cross(q.xyz, t)
 t:=a.Vector.xyz.Cross(b)*2.0;
 result:=(b+(a.w*t))+a.Vector.xyz.Cross(t);
end;
{$ifend}

class operator TpvQuaternion.Multiply(const a:TpvVector3;const b:TpvQuaternion):TpvVector3;
begin
 result:=b.Inverse*a;
end;

class operator TpvQuaternion.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvQuaternion;{$ifdef fpc}constref{$else}const{$endif} b:TpvVector4):TpvVector4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
const AndMask:array[0..3] of TpvUInt32=($ffffffff,$ffffffff,$ffffffff,$00000000);
      OrMask:array[0..3] of TpvUInt32=($00000000,$00000000,$00000000,$3f800000);
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}

 // q = a
 // v = b

{$if defined(ExplicitX64SIMDRegs)}
 movups xmm4,dqword ptr [rdx] // xmm4 = q.xyzw

 movups xmm5,dqword ptr [r8] // xmm5 = v.xyz?
{$else}
 movups xmm4,dqword ptr [a] // xmm4 = q.xyzw

 movups xmm5,dqword ptr [b] // xmm5 = v.xyz?
{$ifend}

 movaps xmm6,xmm4
 shufps xmm6,xmm6,$ff // xmm6 = q.wwww

{$ifdef cpu386}
 movups xmm7,dqword ptr [AndMask] // xmm7 = AndMask
{$else}
{$ifdef fpc}
 movups xmm7,dqword ptr [rip+AndMask] // xmm7 = AndMask
{$else}
 movups xmm7,dqword ptr [rel AndMask] // xmm7 = AndMask
{$endif}
{$endif}

 andps xmm4,xmm7 // xmm4 = q.xyz0

 andps xmm5,xmm7 // xmm5 = v.xyz0

 // t:=Vector3ScalarMul(Vector3Cross(qv,v),2.0);
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

 // xmm6 = Vector3Add(v,Vector3ScalarMul(t,q.w))
 mulps xmm6,xmm2 // xmm6 = q.wwww, xmm2 = t
 addps xmm6,xmm5 // xmm5 = v

 // Vector3Cross(qv,t)
 movaps xmm1,xmm4 // xmm4 = qv
 movaps xmm3,xmm2 // xmm2 = t
 shufps xmm4,xmm4,$12
 shufps xmm2,xmm2,$09
 shufps xmm1,xmm1,$09
 shufps xmm3,xmm3,$12
 mulps xmm4,xmm2
 mulps xmm1,xmm3
 subps xmm1,xmm4

{$ifdef cpu386}
 movups xmm4,dqword ptr [OrMask] // xmm4 = OrMask
{$else}
{$ifdef fpc}
 movups xmm4,dqword ptr [rip+OrMask] // xmm4 = OrMask
{$else}
 movups xmm4,dqword ptr [rel OrMask] // xmm4 = OrMask
{$endif}
{$endif}

 // result:=Vector3Add(Vector3Add(v,Vector3ScalarMul(t,q.w)),Vector3Cross(qv,t));
 addps xmm1,xmm6

 andps xmm1,xmm7 // xmm1 = xmm1.xyz0
 orps xmm1,xmm4 // xmm1 = xmm1.xyz1

 movups dqword ptr [result],xmm1

{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}

end;
{$else}
var t:TpvVector3;
begin
 // q = a
 // v = b
 // t = 2 * cross(q.xyz, v)
 // v' = v + q.w * t + cross(q.xyz, t)
 t:=a.Vector.xyz.Cross(b.xyz)*2.0;
 result.xyz:=(b.xyz+(a.w*t))+a.Vector.xyz.Cross(t);
 result.w:=1.0;
end;
{$ifend}

class operator TpvQuaternion.Multiply(const a:TpvVector4;const b:TpvQuaternion):TpvVector4;
begin
 result:=b.Inverse*a;
end;

class operator TpvQuaternion.Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvQuaternion):TpvQuaternion;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [rdx]
 movups xmm1,dqword ptr [r8]
{$else}
 movups xmm0,dqword ptr [a]
 movups xmm1,dqword ptr [b]
{$ifend}
 divps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
 result.z:=a.z/b.z;
 result.w:=a.w/b.w;
end;
{$ifend}

class operator TpvQuaternion.Divide(const a:TpvQuaternion;const b:TpvScalar):TpvQuaternion;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
 result.z:=a.z/b;
 result.w:=a.w/b;
end;

class operator TpvQuaternion.Divide(const a:TpvScalar;const b:TpvQuaternion):TpvQuaternion;
begin
 result.x:=a/b.x;
 result.y:=a/b.y;
 result.z:=a/b.z;
 result.w:=a/b.z;
end;

class operator TpvQuaternion.IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvQuaternion):TpvQuaternion;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [rdx]
 movups xmm1,dqword ptr [r8]
{$else}
 movups xmm0,dqword ptr [a]
 movups xmm1,dqword ptr [b]
{$ifend}
 divps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
 result.z:=a.z/b.z;
 result.w:=a.w/b.w;
end;
{$ifend}

class operator TpvQuaternion.IntDivide(const a:TpvQuaternion;const b:TpvScalar):TpvQuaternion;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
 result.z:=a.z/b;
 result.w:=a.w/b;
end;

class operator TpvQuaternion.IntDivide(const a:TpvScalar;const b:TpvQuaternion):TpvQuaternion;
begin
 result.x:=a/b.x;
 result.y:=a/b.y;
 result.z:=a/b.z;
 result.w:=a/b.w;
end;

class operator TpvQuaternion.Modulus(const a,b:TpvQuaternion):TpvQuaternion;
begin
 result.x:=Modulus(a.x,b.x);
 result.y:=Modulus(a.y,b.y);
 result.z:=Modulus(a.z,b.z);
 result.w:=Modulus(a.w,b.w);
end;

class operator TpvQuaternion.Modulus(const a:TpvQuaternion;const b:TpvScalar):TpvQuaternion;
begin
 result.x:=Modulus(a.x,b);
 result.y:=Modulus(a.y,b);
 result.z:=Modulus(a.z,b);
 result.w:=Modulus(a.w,b);
end;

class operator TpvQuaternion.Modulus(const a:TpvScalar;const b:TpvQuaternion):TpvQuaternion;
begin
 result.x:=Modulus(a,b.x);
 result.y:=Modulus(a,b.y);
 result.z:=Modulus(a,b.z);
 result.w:=Modulus(a,b.w);
end;

class operator TpvQuaternion.Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvQuaternion):TpvQuaternion;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
 xorps xmm0,xmm0
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm1,dqword ptr [rdx]
{$else}
 movups xmm1,dqword ptr [a]
{$ifend}
 subps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=-a.x;
 result.y:=-a.y;
 result.z:=-a.z;
 result.w:=-a.w;
end;
{$ifend}

class operator TpvQuaternion.Positive(const a:TpvQuaternion):TpvQuaternion;
begin
 result:=a;
end;

function TpvQuaternion.GetComponent(const aIndex:TpvInt32):TpvScalar;
begin
 result:=RawComponents[aIndex];
end;

procedure TpvQuaternion.SetComponent(const aIndex:TpvInt32;const aValue:TpvScalar);
begin
 RawComponents[aIndex]:=aValue;
end;

function TpvQuaternion.ToNormalizedSphericalCoordinates:TpvNormalizedSphericalCoordinates;
var ty:TpvScalar;
begin
 ty:=y;
 if ty<-1.0 then begin
  ty:=-1.0;
 end else if ty>1.0 then begin
  ty:=1.0;
 end;
 result.Latitude:=ArcSin(ty);
 if (sqr(x)+sqr(z))>0.00005 then begin
  result.Longitude:=ArcTan2(x,z);
 end else begin
  result.Longitude:=0.0;
 end;
end;

function TpvQuaternion.ToEuler:TpvVector3;
var t:TpvScalar;
begin
 // Order of rotations: Roll (Z), Pitch (X), Yaw (Y)
 t:=2.0*((x*w)-(y*z));
 if t<-0.995 then begin
  result.Pitch:=-HalfPI;
  result.Yaw:=0.0;
  result.Roll:=-ArcTan2(2.0*((x*z)-(y*w)),1.0-(2.0*(sqr(y)+sqr(z))));
 end else if t>0.995 then begin
  result.Pitch:=HalfPI;
  result.Yaw:=0.0;
  result.Roll:=ArcTan2(2.0*((x*z)-(y*w)),1.0-(2.0*(sqr(y)+sqr(z))));
 end else begin
  result.Pitch:=ArcSin(t);
  result.Yaw:=ArcTan2(2.0*((x*z)+(y*w)),1.0-(2.0*(sqr(x)+sqr(y))));
  result.Roll:=ArcTan2(2.0*((x*y)+(z*w)),1.0-(2.0*(sqr(x)+sqr(z))));
 end;
end;

function TpvQuaternion.ToPitch:TpvScalar;
var t:TpvScalar;
begin
 // Order of rotations: Roll (Z), Pitch (X), Yaw (Y)
 t:=2.0*((x*w)-(y*z));
 if t<-0.995 then begin
  result:=-HalfPI;
 end else if t>0.995 then begin
  result:=HalfPI;
 end else begin
  result:=ArcSin(t);
 end;
end;

function TpvQuaternion.ToYaw:TpvScalar;
var t:TpvScalar;
begin
 // Order of rotations: Roll (Z), Pitch (X), Yaw (Y)
 t:=2.0*((x*w)-(y*z));
 if System.abs(t)>0.995 then begin
  result:=0.0;
 end else begin
  result:=ArcTan2(2.0*((x*z)+(y*w)),1.0-(2.0*(sqr(x)+sqr(y))));
 end;
end;

function TpvQuaternion.ToRoll:TpvScalar;
var t:TpvScalar;
begin
 // Order of rotations: Roll (Z), Pitch (X), Yaw (Y)
 t:=2.0*((x*w)-(y*z));
 if t<-0.995 then begin
  result:=-ArcTan2(2.0*((x*z)-(y*w)),1.0-(2.0*(sqr(y)+sqr(z))));
 end else if t>0.995 then begin
  result:=ArcTan2(2.0*((x*z)-(y*w)),1.0-(2.0*(sqr(y)+sqr(z))));
 end else begin
  result:=ArcTan2(2.0*((x*y)+(z*w)),1.0-(2.0*(sqr(x)+sqr(z))));
 end;
end;

function TpvQuaternion.ToAngularVelocity:TpvVector3;
var Angle,Gain:TpvScalar;
begin
 if System.abs(1.0-w)<EPSILON then begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
 end else begin
  Angle:=ArcCos(System.abs(w));
  Gain:=(Sign(w)*2.0)*(Angle/Sin(Angle));
  result.x:=x*Gain;
  result.y:=y*Gain;
  result.z:=z*Gain;
 end;
end;

procedure TpvQuaternion.ToAngleAxis(out aAngle:TpvScalar;out aAxis:TpvVector3);
var SinAngle:TpvScalar;
    Quaternion:TpvQuaternion;
begin
 Quaternion:=Normalize;
 SinAngle:=sqrt(1.0-sqr(Quaternion.w));
 if System.abs(SinAngle)<EPSILON then begin
  SinAngle:=1.0;
 end;
 aAngle:=2.0*ArcCos(Quaternion.w);
 aAxis.x:=Quaternion.x/SinAngle;
 aAxis.y:=Quaternion.y/SinAngle;
 aAxis.z:=Quaternion.z/SinAngle;
end;

function TpvQuaternion.ToScaledAngleAxis:TpvVector3;
begin
 result:=Log.Vector.xyz*2.0;
end;

function TpvQuaternion.Generator:TpvVector3;
var s:TpvScalar;
begin
 s:=sqrt(1.0-sqr(w));
 result.x:=x;
 result.y:=y;
 result.z:=z;
 if s>0.0 then begin
  result:=result*s;
 end;
 result:=result*(2.0*ArcTan2(s,w));
end;

function TpvQuaternion.Flip:TpvQuaternion;
begin
 result.x:=x;
 result.y:=z;
 result.z:=-y;
 result.w:=w;
end;

function TpvQuaternion.Perpendicular:TpvQuaternion;
var v,p:TpvQuaternion;
begin
 v:=self.Normalize;
 p.x:=System.abs(v.x);
 p.y:=System.abs(v.y);
 p.z:=System.abs(v.z);
 p.w:=System.abs(v.w);
 if (p.x<=p.y) and (p.x<=p.z) and (p.x<=p.w) then begin
  p.x:=1.0;
  p.y:=0.0;
  p.z:=0.0;
  p.w:=0.0;
 end else if (p.y<=p.x) and (p.y<=p.z) and (p.y<=p.w) then begin
  p.x:=0.0;
  p.y:=1.0;
  p.z:=0.0;
  p.w:=0.0;
 end else if (p.z<=p.x) and (p.z<=p.y) and (p.z<=p.w) then begin
  p.x:=0.0;
  p.y:=0.0;
  p.z:=0.0;
  p.w:=1.0;
 end else begin
  p.x:=0.0;
  p.y:=0.0;
  p.z:=1.0;
  p.w:=0.0;
 end;
 result:=p-(v*v.Dot(p));
end;

function TpvQuaternion.Conjugate:TpvQuaternion;
{$if defined(SIMD) and defined(cpu386)}
const XORMask:array[0..3] of TpvUInt32=($80000000,$80000000,$80000000,$00000000);
asm
 movups xmm0,dqword ptr [eax]
 movups xmm1,dqword ptr [XORMask]
 xorps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
const XORMask:array[0..3] of TpvUInt32=($80000000,$80000000,$80000000,$00000000);
asm
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
(*{$else}
 movups xmm0,dqword ptr [rdi]
{$endif}*)
{$ifdef fpc}
 movups xmm1,dqword ptr [rip+XORMask]
{$else}
 movups xmm1,dqword ptr [rel XORMask]
{$endif}
 xorps xmm0,xmm1
 movups dqword ptr [result],xmm0
end;
{$else}
begin
 result.x:=-x;
 result.y:=-y;
 result.z:=-z;
 result.w:=w;
end;
{$ifend}

function TpvQuaternion.Inverse:TpvQuaternion;
{$if defined(SIMD) and defined(cpu386)}
const XORMask:array[0..3] of TpvUInt32=($80000000,$80000000,$80000000,$00000000);
asm
 movups xmm2,dqword ptr [eax]
 movups xmm3,dqword ptr [XORMask]
 movaps xmm0,xmm2
 mulps xmm0,xmm0
 movhlps xmm1,xmm0
 addps xmm0,xmm1
 pshufd xmm1,xmm0,$01
 addss xmm0,xmm1
 sqrtss xmm0,xmm0           // not rsqrtss! because rsqrtss has only 12-bit accuracy
 shufps xmm0,xmm0,$00
 divps xmm2,xmm0
 xorps xmm2,xmm3
 movups dqword ptr [result],xmm2
end;
{$elseif defined(SIMD) and defined(cpux64)}
const XORMask:array[0..3] of TpvUInt32=($80000000,$80000000,$80000000,$00000000);
asm
//{$ifdef Windows}
 movups xmm2,dqword ptr [rcx]
(*{$else}
 movups xmm2,dqword ptr [rdi]
{$endif}*)
{$ifdef fpc}
 movups xmm3,dqword ptr [rip+XORMask]
{$else}
 movups xmm3,dqword ptr [rel XORMask]
{$endif}
 movaps xmm0,xmm2
 mulps xmm0,xmm0
 movhlps xmm1,xmm0
 addps xmm0,xmm1
 pshufd xmm1,xmm0,$01
 addss xmm0,xmm1
 sqrtss xmm0,xmm0            // not rsqrtss! because rsqrtss has only 12-bit accuracy
 shufps xmm0,xmm0,$00
 divps xmm2,xmm0
 xorps xmm2,xmm3
 movups dqword ptr [result],xmm2
end;
{$else}
var Normal:TpvScalar;
begin
 Normal:=sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));
 if Normal>0.0 then begin
  Normal:=1.0/Normal;
 end;
 result.x:=-(x*Normal);
 result.y:=-(y*Normal);
 result.z:=-(z*Normal);
 result.w:=w*Normal;
end;
{$ifend}

function TpvQuaternion.Length:TpvScalar;
{$if defined(SIMD) and defined(cpu386)}
asm
 movups xmm0,dqword ptr [eax]
 mulps xmm0,xmm0
 movhlps xmm1,xmm0
 addps xmm0,xmm1
 pshufd xmm1,xmm0,$01
 addss xmm1,xmm0
 sqrtss xmm0,xmm1
 movss dword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
(*{$else}
 movups xmm0,dqword ptr [rdi]
{$endif}*)
 mulps xmm0,xmm0
 movhlps xmm1,xmm0
 addps xmm0,xmm1
 pshufd xmm1,xmm0,$01
 addss xmm1,xmm0
 sqrtss xmm0,xmm1
{$ifdef fpc}
 movss dword ptr [result],xmm0
{$else}
//movaps xmm0,xmm0
{$endif}
end;
{$else}
begin
 result:=sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));
end;
{$ifend}

function TpvQuaternion.SquaredLength:TpvScalar;
{$if defined(SIMD) and defined(cpu386)}
asm
 movups xmm0,dqword ptr [eax]
 mulps xmm0,xmm0
 movhlps xmm1,xmm0
 addps xmm0,xmm1
 pshufd xmm1,xmm0,$01
 addss xmm0,xmm1
 movss dword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
(*{$else}
 movups xmm0,dqword ptr [rdi]
{$endif}*)
 mulps xmm0,xmm0
 movhlps xmm1,xmm0
 addps xmm0,xmm1
 pshufd xmm1,xmm0,$01
 addss xmm0,xmm1
{$ifdef fpc}
 movss dword ptr [result],xmm0
{$else}
//movaps xmm0,xmm0
{$endif}
end;
{$else}
begin
 result:=sqr(x)+sqr(y)+sqr(z)+sqr(w);
end;
{$ifend}

function TpvQuaternion.Normalize:TpvQuaternion;
{$if defined(SIMD) and defined(cpu386)}
asm
 movups xmm0,dqword ptr [eax]
 movaps xmm2,xmm0
 mulps xmm0,xmm0
 movhlps xmm1,xmm0
 addps xmm0,xmm1
 pshufd xmm1,xmm0,$01
 addss xmm0,xmm1
 sqrtss xmm0,xmm0               // not rsqrtss! because rsqrtss has only 12-bit accuracy
 shufps xmm0,xmm0,$00
 divps xmm2,xmm0
 subps xmm1,xmm2
 cmpps xmm1,xmm0,7
 andps xmm2,xmm1
 movups dqword ptr [edx],xmm2
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
(*{$else}
 movups xmm0,dqword ptr [rdi]
{$endif}*)
 movaps xmm2,xmm0
 mulps xmm0,xmm0
 movhlps xmm1,xmm0
 addps xmm0,xmm1
 pshufd xmm1,xmm0,$01
 addss xmm0,xmm1
 sqrtss xmm0,xmm0                // not rsqrtss! because rsqrtss has only 12-bit accuracy
 shufps xmm0,xmm0,$00
 divps xmm2,xmm0
 subps xmm1,xmm2
 cmpps xmm1,xmm0,7
 andps xmm2,xmm1
//{$ifdef Windows}
 movups dqword ptr [rdx],xmm2
(*{$else}
 movups dqword ptr [result],xmm2
{$endif}*)
end;
{$else}
var Factor:TpvScalar;
begin
 Factor:=sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));
 if Factor<>0.0 then begin
  Factor:=1.0/Factor;
  result.x:=x*Factor;
  result.y:=y*Factor;
  result.z:=z*Factor;
  result.w:=w*Factor;
 end else begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
  result.w:=0.0;
 end;
end;
{$ifend}

function TpvQuaternion.DistanceTo({$ifdef fpc}constref{$else}const{$endif} b:TpvQuaternion):TpvScalar;
{$if defined(SIMD) and defined(cpu386)}
asm
 movups xmm0,dqword ptr [eax]
 movups xmm1,dqword ptr [edx]
 subps xmm0,xmm1
 mulps xmm0,xmm0         // xmm0 = w*w, z*z, y*y, x*x
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$4e    // xmm1 = z*z, w*w, x*x, y*y
 addps xmm0,xmm1         // xmm0 = xmm0 + xmm1 = (zw*zw, zw*zw, xy*zw, xy*zw)
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$b1    // xmm0 = xy*xy, xy*xy, zw*zw, zw*zw
 addps xmm1,xmm0         // xmm1 = xmm1 + xmm0 = (xyzw, xyzw, xyzw, xyzw)
 sqrtss xmm0,xmm1
 movss dword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
 movups xmm1,dqword ptr [rdx]
(*{$else}
 movups xmm0,dqword ptr [rdi]
 movups xmm1,dqword ptr [rsi]
{$endif}*)
 subps xmm0,xmm1
 mulps xmm0,xmm0         // xmm0 = w*w, z*z, y*y, x*x
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$4e    // xmm1 = z*z, w*w, x*x, y*y
 addps xmm0,xmm1         // xmm0 = xmm0 + xmm1 = (zw*zw, zw*zw, xy*zw, xy*zw)
 movaps xmm1,xmm0        // xmm1 = xmm0
 shufps xmm1,xmm1,$b1    // xmm0 = xy*xy, xy*xy, zw*zw, zw*zw
 addps xmm1,xmm0         // xmm1 = xmm1 + xmm0 = (xyzw, xyzw, xyzw, xyzw)
 sqrtss xmm0,xmm1
{$ifdef fpc}
 movss dword ptr [result],xmm0
{$else}
//movaps xmm0,xmm0
{$endif}
end;
{$else}
begin
 result:=sqrt(sqr(x-b.x)+sqr(y-b.y)+sqr(z-b.z)+sqr(w-b.w));
end;
{$ifend}

function TpvQuaternion.Abs:TpvQuaternion;
{$if defined(SIMD) and defined(cpu386)}
asm
 movups xmm0,dqword ptr [eax]
 xorps xmm1,xmm1
 subps xmm1,xmm0
 maxps xmm0,xmm1
 movups dqword ptr [edx],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
(*{$else}
 movups xmm0,dqword ptr [rdi]
{$endif}*)
 xorps xmm1,xmm1
 subps xmm1,xmm0
 maxps xmm0,xmm1
//{$ifdef Windows}
 movups dqword ptr [rdx],xmm0
(*{$else}
 movups dqword ptr [rax],xmm0
{$endif}*)
end;
{$else}
begin
 result.x:=System.abs(x);
 result.y:=System.abs(y);
 result.z:=System.abs(z);
 result.w:=System.abs(w);
end;
{$ifend}

function TpvQuaternion.Exp:TpvQuaternion;
var Angle,Sinus,Coefficent:TpvScalar;
begin
 Angle:=sqrt(sqr(x)+sqr(y)+sqr(z));
 Sinus:=sin(Angle);
 result.w:=cos(Angle);
 if System.Abs(Sinus)>1e-6 then begin
  Coefficent:=Sinus/Angle;
  result.x:=x*Coefficent;
  result.y:=y*Coefficent;
  result.z:=z*Coefficent;
 end else begin
  result.x:=x;
  result.y:=y;
  result.z:=z;
 end;
end;

function TpvQuaternion.Log:TpvQuaternion;
var Theta,SinTheta,Coefficent:TpvScalar;
begin
 result.x:=x;
 result.y:=y;
 result.z:=z;
 result.w:=0.0;
 if System.Abs(w)<1.0 then begin
  Theta:=ArcCos(w);
  SinTheta:=sin(Theta);
  if System.Abs(SinTheta)>1e-6 then begin
   Coefficent:=Theta/SinTheta;
   result.x:=result.x*Coefficent;
   result.y:=result.y*Coefficent;
   result.z:=result.z*Coefficent;
  end;
 end;
end;

function TpvQuaternion.Dot({$ifdef fpc}constref{$else}const{$endif} b:TpvQuaternion):TpvScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef CAN_INLINE}inline;{$endif}{$ifend}
{$if defined(SIMD) and defined(cpu386)}
asm
 movups xmm0,dqword ptr [eax]
 movups xmm1,dqword ptr [edx]
 mulps xmm0,xmm1
 movaps xmm1,xmm0
 shufps xmm1,xmm0,$b1
 addps xmm0,xmm1
 movhlps xmm1,xmm0
 addss xmm0,xmm1
 movss dword ptr [result],xmm0
end;
{$elseif defined(SIMD) and defined(cpux64)}
asm
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx]
 movups xmm1,dqword ptr [rdx]
(*{$else}
 movups xmm0,dqword ptr [rdi]
 movups xmm1,dqword ptr [rsi]
{$endif}*)
 mulps xmm0,xmm1
 movaps xmm1,xmm0
 shufps xmm1,xmm0,$b1
 addps xmm0,xmm1
 movhlps xmm1,xmm0
 addss xmm0,xmm1
{$ifdef fpc}
 movss dword ptr [result],xmm0
{$else}
//movaps xmm0,xmm0
{$endif}
end;
{$else}
begin
 result:=(x*b.x)+(y*b.y)+(z*b.z)+(w*b.w);
end;
{$ifend}

function TpvQuaternion.Lerp(const aToQuaternion:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
var SignFactor:TpvScalar;
begin
 if Dot(aToQuaternion)<0.0 then begin
  SignFactor:=-1.0;
 end else begin
  SignFactor:=1.0;
 end;
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aToQuaternion*SignFactor;
 end else begin
  result:=(self*(1.0-aTime))+(aToQuaternion*(aTime*SignFactor));
 end;
end;

function TpvQuaternion.Nlerp(const aToQuaternion:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
begin
 result:=Lerp(aToQuaternion,aTime).Normalize;
end;

function TpvQuaternion.Slerp(const aToQuaternion:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
var Omega,co,so,s0,s1,s2:TpvScalar;
begin
 co:=Dot(aToQuaternion);
 if co<0.0 then begin
  co:=-co;
  s2:=-1.0;
 end else begin
  s2:=1.0;
 end;
 if (1.0-co)>EPSILON then begin
  Omega:=ArcCos(co);
  so:=sin(Omega);
  s0:=sin((1.0-aTime)*Omega)/so;
  s1:=sin(aTime*Omega)/so;
 end else begin
  s0:=1.0-aTime;
  s1:=aTime;
 end;
 result:=(s0*self)+(aToQuaternion*(s1*s2));
end;

function TpvQuaternion.ApproximatedSlerp(const aToQuaternion:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
var ca,d,a,b,k,o:TpvScalar;
begin
 // Idea from https://zeux.io/2015/07/23/approximating-slerp/
 ca:=Dot(aToQuaternion);
 d:=System.abs(ca);
 a:=1.0904+(d*(-3.2452+(d*(3.55645-(d*1.43519)))));
 b:=0.848013+(d*(-1.06021+(d*0.215638)));
 k:=(a*sqr(aTime-0.5))+b;
 o:=aTime+(((aTime*(aTime-0.5))*(aTime-1.0))*k);
 if ca<0.0 then begin
  result:=Nlerp(-aToQuaternion,o);
 end else begin
  result:=Nlerp(aToQuaternion,o);
 end;
end;

function TpvQuaternion.Elerp(const aToQuaternion:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
var SignFactor:TpvScalar;
begin
 if Dot(aToQuaternion)<0.0 then begin
  SignFactor:=-1.0;
 end else begin
  SignFactor:=1.0;
 end;
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aToQuaternion*SignFactor;
 end else begin
  result:=((Log*(1.0-aTime))+((aToQuaternion*SignFactor).Log*aTime)).Exp;
 end;
end;

function TpvQuaternion.Sqlerp(const aB,aC,aD:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
begin
 result:=Slerp(aD,aTime).Slerp(aB.Slerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

function TpvQuaternion.UnflippedSlerp(const aToQuaternion:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
var Omega,co,so,s0,s1:TpvScalar;
begin
 co:=Dot(aToQuaternion);
 if (1.0-co)>EPSILON then begin
  Omega:=ArcCos(co);
  so:=sin(Omega);
  s0:=sin((1.0-aTime)*Omega)/so;
  s1:=sin(aTime*Omega)/so;
 end else begin
  s0:=1.0-aTime;
  s1:=aTime;
 end;
 result:=(s0*self)+(aToQuaternion*s1);
end;

function TpvQuaternion.UnflippedApproximatedSlerp(const aToQuaternion:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
var d,a,b,k,o:TpvScalar;
begin
 // Idea from https://zeux.io/2015/07/23/approximating-slerp/
 d:=System.abs(Dot(aToQuaternion));
 a:=1.0904+(d*(-3.2452+(d*(3.55645-(d*1.43519)))));
 b:=0.848013+(d*(-1.06021+(d*0.215638)));
 k:=(a*sqr(aTime-0.5))+b;
 o:=aTime+(((aTime*(aTime-0.5))*(aTime-1.0))*k);
 result:=Nlerp(aToQuaternion,o);
end;

function TpvQuaternion.UnflippedSqlerp(const aB,aC,aD:TpvQuaternion;const aTime:TpvScalar):TpvQuaternion;
begin
 result:=UnflippedSlerp(aD,aTime).UnflippedSlerp(aB.UnflippedSlerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

function TpvQuaternion.AngleBetween(const aP:TpvQuaternion):TpvScalar;
var Difference:TpvQuaternion;
begin
 Difference:=(self*aP.Inverse).Abs;
 result:=ArcCos(Clamp(Difference.w,-1.0,1.0))*2.0;
end;

function TpvQuaternion.Between(const aP:TpvQuaternion):TpvQuaternion;
var c:TpvVector3;
begin
 c:=aP.Vector.xyz.Cross(self.Vector.xyz);
 result:=TpvQuaternion.Create(c.x,c.y,c.z,sqrt(aP.Vector.xyz.SquaredLength*self.Vector.xyz.SquaredLength)+aP.Vector.xyz.Dot(self.Vector.xyz)).Normalize;
end;

class procedure TpvQuaternion.Hermite(out aRotation:TpvQuaternion;out aVelocity:TpvVector3;const aTime:TpvScalar;const aR0,aR1:TpvQuaternion;const aV0,aV1:TpvVector3);
var t2,t3,w1,w2,w3,q1,q2,q3:TpvScalar;
    r1r0:TpvVector3;
begin
 t2:=sqr(aTime);
 t3:=t2*aTime;
 w1:=(3.0*t2)-(2.0*t3);
 w2:=(t3-(2.0*t2))+aTime;
 w3:=t3-t2;
 q1:=(6.0*aTime)-(6.0*t2);
 q2:=((3.0*t2)-(4.0*aTime))+1.0;
 q3:=(3.0*t2)-(2.0*aTime);
 r1r0:=((aR1*aR0.Inverse).Abs).ToScaledAngleAxis;
 aRotation:=TpvQuaternion.CreateFromScaledAngleAxis((r1r0*w1)+(aV0*w2)+(aV1*w3))*aR0;
 aVelocity:=(q1*r1r0)+(aV0*q2)+(aV1*q3);
end;

class procedure TpvQuaternion.CatmullRom(out aRotation:TpvQuaternion;out aVelocity:TpvVector3;const aTime:TpvScalar;const aR0,aR1,aR2,aR3:TpvQuaternion);
var r1r0,r2r1,r3r2,v1,v2:TpvVector3;
begin
 r1r0:=((aR1*aR0.Inverse).Abs).ToScaledAngleAxis;
 r2r1:=((aR2*aR1.Inverse).Abs).ToScaledAngleAxis;
 r3r2:=((aR3*aR2.Inverse).Abs).ToScaledAngleAxis;
 v1:=(r1r0+r2r1)*0.5;
 v2:=(r2r1+r3r2)*0.5;
 TpvQuaternion.Hermite(aRotation,aVelocity,aTime,aR1,aR2,v1,v2);
end;

function TpvQuaternion.RotateAroundAxis(const aVector:TpvQuaternion):TpvQuaternion;
begin
 result.x:=((x*aVector.w)+(z*aVector.y))-(y*aVector.z);
 result.y:=((x*aVector.z)+(y*aVector.w))-(z*aVector.x);
 result.z:=((y*aVector.x)+(z*aVector.w))-(x*aVector.y);
 result.w:=((x*aVector.x)+(y*aVector.y))+(z*aVector.z);
end;

function TpvQuaternion.Integrate(const aOmega:TpvVector3;const aDeltaTime:TpvScalar):TpvQuaternion;
var ThetaLenSquared,ThetaLen,s,w:TpvScalar;
    Theta:TpvVector3;
begin
 Theta:=aOmega*(aDeltaTime*0.5);
 ThetaLenSquared:=Theta.SquaredLength;
 if (sqr(ThetaLenSquared)/24.0)<EPSILON then begin
  s:=1.0-(ThetaLenSquared/6.0);
  w:=1.0-(ThetaLenSquared*0.5);
 end else begin
  ThetaLen:=sqrt(ThetaLenSquared);
  s:=sin(ThetaLen)/ThetaLen;
  w:=cos(ThetaLen);
 end;
 result.Vector.xyz:=Theta*s;
 result.Vector.w:=w;
 result:=result*self;
end;

function TpvQuaternion.Spin(const aOmega:TpvVector3;const aDeltaTime:TpvScalar):TpvQuaternion;
var wq:TpvQuaternion;
begin
 wq.x:=aOmega.x*aDeltaTime;
 wq.y:=aOmega.y*aDeltaTime;
 wq.z:=aOmega.z*aDeltaTime;
 wq.w:=0.0;
 result:=(self+((wq*self)*0.5)).Normalize;
end;

{constructor TpvMatrix2x2.Create;
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
end;//}

constructor TpvMatrix2x2.Create(const pX:TpvScalar);
begin
 RawComponents[0,0]:=pX;
 RawComponents[0,1]:=pX;
 RawComponents[1,0]:=pX;
 RawComponents[1,1]:=pX;
end;

constructor TpvMatrix2x2.Create(const pXX,pXY,pYX,pYY:TpvScalar);
begin
 RawComponents[0,0]:=pXX;
 RawComponents[0,1]:=pXY;
 RawComponents[1,0]:=pYX;
 RawComponents[1,1]:=pYY;
end;

constructor TpvMatrix2x2.Create(const pX,pY:TpvVector2);
begin
 RawComponents[0,0]:=pX.x;
 RawComponents[0,1]:=pX.y;
 RawComponents[1,0]:=pY.x;
 RawComponents[1,1]:=pY.y;
end;

class operator TpvMatrix2x2.Implicit(const a:TpvScalar):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a;
 result.RawComponents[0,1]:=a;
 result.RawComponents[1,0]:=a;
 result.RawComponents[1,1]:=a;
end;

class operator TpvMatrix2x2.Explicit(const a:TpvScalar):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a;
 result.RawComponents[0,1]:=a;
 result.RawComponents[1,0]:=a;
 result.RawComponents[1,1]:=a;
end;

class operator TpvMatrix2x2.Equal(const a,b:TpvMatrix2x2):boolean;
begin
 result:=SameValue(a.RawComponents[0,0],b.RawComponents[0,0]) and
         SameValue(a.RawComponents[0,1],b.RawComponents[0,1]) and
         SameValue(a.RawComponents[1,0],b.RawComponents[1,0]) and
         SameValue(a.RawComponents[1,1],b.RawComponents[1,1]);
end;

class operator TpvMatrix2x2.NotEqual(const a,b:TpvMatrix2x2):boolean;
begin
 result:=(not SameValue(a.RawComponents[0,0],b.RawComponents[0,0])) or
         (not SameValue(a.RawComponents[0,1],b.RawComponents[0,1])) or
         (not SameValue(a.RawComponents[1,0],b.RawComponents[1,0])) or
         (not SameValue(a.RawComponents[1,1],b.RawComponents[1,1]));
end;

class operator TpvMatrix2x2.Inc(const a:TpvMatrix2x2):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]+1.0;
 result.RawComponents[0,1]:=a.RawComponents[0,1]+1.0;
 result.RawComponents[1,0]:=a.RawComponents[1,0]+1.0;
 result.RawComponents[1,1]:=a.RawComponents[1,1]+1.0;
end;

class operator TpvMatrix2x2.Dec(const a:TpvMatrix2x2):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]-1.0;
 result.RawComponents[0,1]:=a.RawComponents[0,1]-1.0;
 result.RawComponents[1,0]:=a.RawComponents[1,0]-1.0;
 result.RawComponents[1,1]:=a.RawComponents[1,1]-1.0;
end;

class operator TpvMatrix2x2.Add(const a,b:TpvMatrix2x2):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]+b.RawComponents[0,0];
 result.RawComponents[0,1]:=a.RawComponents[0,1]+b.RawComponents[0,1];
 result.RawComponents[1,0]:=a.RawComponents[1,0]+b.RawComponents[1,0];
 result.RawComponents[1,1]:=a.RawComponents[1,1]+b.RawComponents[1,1];
end;

class operator TpvMatrix2x2.Add(const a:TpvMatrix2x2;const b:TpvScalar):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]+b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]+b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]+b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]+b;
end;

class operator TpvMatrix2x2.Add(const a:TpvScalar;const b:TpvMatrix2x2):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a+b.RawComponents[0,0];
 result.RawComponents[0,1]:=a+b.RawComponents[0,1];
 result.RawComponents[1,0]:=a+b.RawComponents[1,0];
 result.RawComponents[1,1]:=a+b.RawComponents[1,1];
end;

class operator TpvMatrix2x2.Subtract(const a,b:TpvMatrix2x2):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]-b.RawComponents[0,0];
 result.RawComponents[0,1]:=a.RawComponents[0,1]-b.RawComponents[0,1];
 result.RawComponents[1,0]:=a.RawComponents[1,0]-b.RawComponents[1,0];
 result.RawComponents[1,1]:=a.RawComponents[1,1]-b.RawComponents[1,1];
end;

class operator TpvMatrix2x2.Subtract(const a:TpvMatrix2x2;const b:TpvScalar):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]-b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]-b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]-b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]-b;
end;

class operator TpvMatrix2x2.Subtract(const a:TpvScalar;const b:TpvMatrix2x2): TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a-b.RawComponents[0,0];
 result.RawComponents[0,1]:=a-b.RawComponents[0,1];
 result.RawComponents[1,0]:=a-b.RawComponents[1,0];
 result.RawComponents[1,1]:=a-b.RawComponents[1,1];
end;

class operator TpvMatrix2x2.Multiply(const a,b:TpvMatrix2x2):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=(a.RawComponents[0,0]*b.RawComponents[0,0])+(a.RawComponents[0,1]*b.RawComponents[1,0]);
 result.RawComponents[0,1]:=(a.RawComponents[0,0]*b.RawComponents[0,1])+(a.RawComponents[0,1]*b.RawComponents[1,1]);
 result.RawComponents[1,0]:=(a.RawComponents[1,0]*b.RawComponents[0,0])+(a.RawComponents[1,1]*b.RawComponents[1,0]);
 result.RawComponents[1,1]:=(a.RawComponents[1,0]*b.RawComponents[0,1])+(a.RawComponents[1,1]*b.RawComponents[1,1]);
end;

class operator TpvMatrix2x2.Multiply(const a:TpvMatrix2x2;const b:TpvScalar):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]*b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]*b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]*b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]*b;
end;

class operator TpvMatrix2x2.Multiply(const a:TpvScalar;const b:TpvMatrix2x2):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a*b.RawComponents[0,0];
 result.RawComponents[0,1]:=a*b.RawComponents[0,1];
 result.RawComponents[1,0]:=a*b.RawComponents[1,0];
 result.RawComponents[1,1]:=a*b.RawComponents[1,1];
end;

class operator TpvMatrix2x2.Multiply(const a:TpvMatrix2x2;const b:TpvVector2):TpvVector2;
begin
 result.x:=(a.RawComponents[0,0]*b.x)+(a.RawComponents[1,0]*b.y);
 result.y:=(a.RawComponents[0,1]*b.x)+(a.RawComponents[1,1]*b.y);
end;

class operator TpvMatrix2x2.Multiply(const a:TpvVector2;const b:TpvMatrix2x2):TpvVector2;
begin
 result.x:=(a.x*b.RawComponents[0,0])+(a.y*b.RawComponents[0,1]);
 result.y:=(a.x*b.RawComponents[1,0])+(a.y*b.RawComponents[1,1]);
end;

class operator TpvMatrix2x2.Divide(const a,b:TpvMatrix2x2):TpvMatrix2x2;
begin
 result:=a*b.Inverse;
end;

class operator TpvMatrix2x2.Divide(const a:TpvMatrix2x2;const b:TpvScalar):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]/b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]/b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]/b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]/b;
end;

class operator TpvMatrix2x2.Divide(const a:TpvScalar;const b:TpvMatrix2x2):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a/b.RawComponents[0,0];
 result.RawComponents[0,1]:=a/b.RawComponents[0,1];
 result.RawComponents[1,0]:=a/b.RawComponents[1,0];
 result.RawComponents[1,1]:=a/b.RawComponents[1,1];
end;

class operator TpvMatrix2x2.IntDivide(const a,b:TpvMatrix2x2):TpvMatrix2x2;
begin
 result:=a*b.Inverse;
end;

class operator TpvMatrix2x2.IntDivide(const a:TpvMatrix2x2;const b:TpvScalar):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]/b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]/b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]/b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]/b;
end;

class operator TpvMatrix2x2.IntDivide(const a:TpvScalar;const b:TpvMatrix2x2):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=a/b.RawComponents[0,0];
 result.RawComponents[0,1]:=a/b.RawComponents[0,1];
 result.RawComponents[1,0]:=a/b.RawComponents[1,0];
 result.RawComponents[1,1]:=a/b.RawComponents[1,1];
end;

class operator TpvMatrix2x2.Modulus(const a,b:TpvMatrix2x2):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=Modulo(a.RawComponents[0,0],b.RawComponents[0,0]);
 result.RawComponents[0,1]:=Modulo(a.RawComponents[0,1],b.RawComponents[0,1]);
 result.RawComponents[1,0]:=Modulo(a.RawComponents[1,0],b.RawComponents[1,0]);
 result.RawComponents[1,1]:=Modulo(a.RawComponents[1,1],b.RawComponents[1,1]);
end;

class operator TpvMatrix2x2.Modulus(const a:TpvMatrix2x2;const b:TpvScalar):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=Modulo(a.RawComponents[0,0],b);
 result.RawComponents[0,1]:=Modulo(a.RawComponents[0,1],b);
 result.RawComponents[1,0]:=Modulo(a.RawComponents[1,0],b);
 result.RawComponents[1,1]:=Modulo(a.RawComponents[1,1],b);
end;

class operator TpvMatrix2x2.Modulus(const a:TpvScalar;const b:TpvMatrix2x2):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=Modulo(a,b.RawComponents[0,0]);
 result.RawComponents[0,1]:=Modulo(a,b.RawComponents[0,1]);
 result.RawComponents[1,0]:=Modulo(a,b.RawComponents[1,0]);
 result.RawComponents[1,1]:=Modulo(a,b.RawComponents[1,1]);
end;

class operator TpvMatrix2x2.Negative(const a:TpvMatrix2x2):TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=-a.RawComponents[0,0];
 result.RawComponents[0,1]:=-a.RawComponents[0,1];
 result.RawComponents[1,0]:=-a.RawComponents[1,0];
 result.RawComponents[1,1]:=-a.RawComponents[1,1];
end;

class operator TpvMatrix2x2.Positive(const a:TpvMatrix2x2):TpvMatrix2x2;
begin
 result:=a;
end;

function TpvMatrix2x2.GetComponent(const pIndexA,pIndexB:TpvInt32):TpvScalar;
begin
 result:=RawComponents[pIndexA,pIndexB];
end;

procedure TpvMatrix2x2.SetComponent(const pIndexA,pIndexB:TpvInt32;const pValue:TpvScalar);
begin
 RawComponents[pIndexA,pIndexB]:=pValue;
end;

function TpvMatrix2x2.GetColumn(const pIndex:TpvInt32):TpvVector2;
begin
 result.x:=RawComponents[pIndex,0];
 result.y:=RawComponents[pIndex,1];
end;

procedure TpvMatrix2x2.SetColumn(const pIndex:TpvInt32;const pValue:TpvVector2);
begin
 RawComponents[pIndex,0]:=pValue.x;
 RawComponents[pIndex,1]:=pValue.y;
end;

function TpvMatrix2x2.GetRow(const pIndex:TpvInt32):TpvVector2;
begin
 result.x:=RawComponents[0,pIndex];
 result.y:=RawComponents[1,pIndex];
end;

procedure TpvMatrix2x2.SetRow(const pIndex:TpvInt32;const pValue:TpvVector2);
begin
 RawComponents[0,pIndex]:=pValue.x;
 RawComponents[1,pIndex]:=pValue.y;
end;

function TpvMatrix2x2.Determinant:TpvScalar;
begin
 result:=(RawComponents[0,0]*RawComponents[1,1])-(RawComponents[0,1]*RawComponents[1,0]);
end;

function TpvMatrix2x2.Inverse:TpvMatrix2x2;
var d:TpvScalar;
begin
 d:=(RawComponents[0,0]*RawComponents[1,1])-(RawComponents[0,1]*RawComponents[1,0]);
 if d<>0.0 then begin
  d:=1.0/d;
  result.RawComponents[0,0]:=RawComponents[1,1]*d;
  result.RawComponents[0,1]:=-(RawComponents[0,1]*d);
  result.RawComponents[1,0]:=-(RawComponents[1,0]*d);
  result.RawComponents[1,1]:=RawComponents[0,0]*d;
 end else begin
  result:=TpvMatrix2x2.Identity;
 end;
end;

function TpvMatrix2x2.Transpose:TpvMatrix2x2;
begin
 result.RawComponents[0,0]:=RawComponents[0,0];
 result.RawComponents[0,1]:=RawComponents[1,0];
 result.RawComponents[1,0]:=RawComponents[0,1];
 result.RawComponents[1,1]:=RawComponents[1,1];
end;

class function TpvDecomposedMatrix3x3.Create:TpvDecomposedMatrix3x3;
begin
 result.Scale:=TpvVector3.Create(1.0,1.0,1.0);
 result.Skew:=TpvVector3.Create(0.0,0.0,0.0);
 result.Rotation:=TpvQuaternion.Create(0.0,0.0,0.0,1.0);
 result.Valid:=true;
end;

function TpvDecomposedMatrix3x3.Lerp(const b:TpvDecomposedMatrix3x3;const t:TpvScalar):TpvDecomposedMatrix3x3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result.Scale:=Scale.Lerp(b.Scale,t);
  result.Skew:=Skew.Lerp(b.Skew,t);
  result.Rotation:=Rotation.Lerp(b.Rotation,t);
 end;
end;

function TpvDecomposedMatrix3x3.Nlerp(const b:TpvDecomposedMatrix3x3;const t:TpvScalar):TpvDecomposedMatrix3x3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result.Scale:=Scale.Lerp(b.Scale,t);
  result.Skew:=Skew.Lerp(b.Skew,t);
  result.Rotation:=Rotation.Nlerp(b.Rotation,t);
 end;
end;

function TpvDecomposedMatrix3x3.Slerp(const b:TpvDecomposedMatrix3x3;const t:TpvScalar):TpvDecomposedMatrix3x3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result.Scale:=Scale.Lerp(b.Scale,t);
  result.Skew:=Skew.Lerp(b.Skew,t);
  result.Rotation:=Rotation.Slerp(b.Rotation,t);
 end;
end;

function TpvDecomposedMatrix3x3.Elerp(const b:TpvDecomposedMatrix3x3;const t:TpvScalar):TpvDecomposedMatrix3x3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result.Scale:=Scale.Lerp(b.Scale,t);
  result.Skew:=Skew.Lerp(b.Skew,t);
  result.Rotation:=Rotation.Elerp(b.Rotation,t);
 end;
end;

function TpvDecomposedMatrix3x3.Sqlerp(const aB,aC,aD:TpvDecomposedMatrix3x3;const aTime:TpvScalar):TpvDecomposedMatrix3x3;
begin
 result:=Slerp(aD,aTime).Slerp(aB.Slerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

{constructor TpvMatrix3x3.Create;
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
end;//}

constructor TpvMatrix3x3.Create(const pX:TpvScalar);
begin
 RawComponents[0,0]:=pX;
 RawComponents[0,1]:=pX;
 RawComponents[0,2]:=pX;
 RawComponents[1,0]:=pX;
 RawComponents[1,1]:=pX;
 RawComponents[1,2]:=pX;
 RawComponents[2,0]:=pX;
 RawComponents[2,1]:=pX;
 RawComponents[2,2]:=pX;
end;

constructor TpvMatrix3x3.Create(const pXX,pXY,pXZ,pYX,pYY,pYZ,pZX,pZY,pZZ:TpvScalar);
begin
 RawComponents[0,0]:=pXX;
 RawComponents[0,1]:=pXY;
 RawComponents[0,2]:=pXZ;
 RawComponents[1,0]:=pYX;
 RawComponents[1,1]:=pYY;
 RawComponents[1,2]:=pYZ;
 RawComponents[2,0]:=pZX;
 RawComponents[2,1]:=pZY;
 RawComponents[2,2]:=pZZ;
end;

constructor TpvMatrix3x3.Create(const pX,pY,pZ:TpvVector3);
begin
 RawComponents[0,0]:=pX.x;
 RawComponents[0,1]:=pX.y;
 RawComponents[0,2]:=pX.z;
 RawComponents[1,0]:=pY.x;
 RawComponents[1,1]:=pY.y;
 RawComponents[1,2]:=pY.z;
 RawComponents[2,0]:=pZ.x;
 RawComponents[2,1]:=pZ.y;
 RawComponents[2,2]:=pZ.z;
end;

constructor TpvMatrix3x3.CreateRotateX(const Angle:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[1,0]:=0.0;
 SinCos(Angle,RawComponents[1,2],RawComponents[1,1]);
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=-RawComponents[1,2];
 RawComponents[2,2]:=RawComponents[1,1];
end;

constructor TpvMatrix3x3.CreateRotateY(const Angle:TpvScalar);
begin
 SinCos(Angle,RawComponents[2,0],RawComponents[0,0]);
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=-RawComponents[2,0];
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=RawComponents[0,0];
end;

constructor TpvMatrix3x3.CreateRotateZ(const Angle:TpvScalar);
begin
 SinCos(Angle,RawComponents[0,1],RawComponents[0,0]);
 RawComponents[0,2]:=0.0;
 RawComponents[1,0]:=-RawComponents[0,1];
 RawComponents[1,1]:=RawComponents[0,0];
 RawComponents[1,2]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
end;

constructor TpvMatrix3x3.CreateRotate(const Angle:TpvScalar;const Axis:TpvVector3);
var SinusAngle,CosinusAngle:TpvScalar;
begin
 SinCos(Angle,SinusAngle,CosinusAngle);
 RawComponents[0,0]:=CosinusAngle+((1.0-CosinusAngle)*sqr(Axis.x));
 RawComponents[1,0]:=((1.0-CosinusAngle)*Axis.x*Axis.y)-(Axis.z*SinusAngle);
 RawComponents[2,0]:=((1.0-CosinusAngle)*Axis.x*Axis.z)+(Axis.y*SinusAngle);
 RawComponents[0,1]:=((1.0-CosinusAngle)*Axis.x*Axis.z)+(Axis.z*SinusAngle);
 RawComponents[1,1]:=CosinusAngle+((1.0-CosinusAngle)*sqr(Axis.y));
 RawComponents[2,1]:=((1.0-CosinusAngle)*Axis.y*Axis.z)-(Axis.x*SinusAngle);
 RawComponents[0,2]:=((1.0-CosinusAngle)*Axis.x*Axis.z)-(Axis.y*SinusAngle);
 RawComponents[1,2]:=((1.0-CosinusAngle)*Axis.y*Axis.z)+(Axis.x*SinusAngle);
 RawComponents[2,2]:=CosinusAngle+((1.0-CosinusAngle)*sqr(Axis.z));
end;

constructor TpvMatrix3x3.CreateSkewYX(const Angle:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=tan(Angle);
 RawComponents[0,2]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
end;

constructor TpvMatrix3x3.CreateSkewZX(const Angle:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=tan(Angle);
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
end;

constructor TpvMatrix3x3.CreateSkewXY(const Angle:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[1,0]:=tan(Angle);
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
end;

constructor TpvMatrix3x3.CreateSkewZY(const Angle:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=tan(Angle);
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
end;

constructor TpvMatrix3x3.CreateSkewXZ(const Angle:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[2,0]:=tan(Angle);
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
end;

constructor TpvMatrix3x3.CreateSkewYZ(const Angle:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=tan(Angle);
 RawComponents[2,2]:=1.0;
end;

constructor TpvMatrix3x3.CreateScale(const sx,sy:TpvScalar);
begin
 RawComponents[0,0]:=sx;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=sy;
 RawComponents[1,2]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
end;

constructor TpvMatrix3x3.CreateScale(const sx,sy,sz:TpvScalar);
begin
 RawComponents[0,0]:=sx;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=sy;
 RawComponents[1,2]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=sz;
end;

constructor TpvMatrix3x3.CreateScale(const pScale:TpvVector2);
begin
 RawComponents[0,0]:=pScale.x;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=pScale.y;
 RawComponents[1,2]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
end;

constructor TpvMatrix3x3.CreateScale(const pScale:TpvVector3);
begin
 RawComponents[0,0]:=pScale.x;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=pScale.y;
 RawComponents[1,2]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=pScale.z;
end;

constructor TpvMatrix3x3.CreateTranslation(const tx,ty:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[2,0]:=tx;
 RawComponents[2,1]:=ty;
 RawComponents[2,2]:=1.0;
end;

constructor TpvMatrix3x3.CreateTranslation(const pTranslation:TpvVector2);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[2,0]:=pTranslation.x;
 RawComponents[2,1]:=pTranslation.y;
 RawComponents[2,2]:=1.0;
end;

constructor TpvMatrix3x3.CreateFromToRotation(const FromDirection,ToDirection:TpvVector3);
var e,h,hvx,hvz,hvxy,hvxz,hvyz:TpvScalar;
    x,u,v,c:TpvVector3;
begin
 e:=FromDirection.Dot(ToDirection);
 if abs(e)>(1.0-EPSILON) then begin
  x:=FromDirection.Abs;
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
  u:=x-FromDirection;
  v:=x-ToDirection;
  c.x:=2.0/(sqr(u.x)+sqr(u.y)+sqr(u.z));
  c.y:=2.0/(sqr(v.x)+sqr(v.y)+sqr(v.z));
  c.z:=c.x*c.y*((u.x*v.x)+(u.y*v.y)+(u.z*v.z));
  RawComponents[0,0]:=1.0+((c.z*(v.x*u.x))-((c.y*(v.x*v.x))+(c.x*(u.x*u.x))));
  RawComponents[0,1]:=(c.z*(v.x*u.y))-((c.y*(v.x*v.y))+(c.x*(u.x*u.y)));
  RawComponents[0,2]:=(c.z*(v.x*u.z))-((c.y*(v.x*v.z))+(c.x*(u.x*u.z)));
  RawComponents[1,0]:=(c.z*(v.y*u.x))-((c.y*(v.y*v.x))+(c.x*(u.y*u.x)));
  RawComponents[1,1]:=1.0+((c.z*(v.y*u.y))-((c.y*(v.y*v.y))+(c.x*(u.y*u.y))));
  RawComponents[1,2]:=(c.z*(v.y*u.z))-((c.y*(v.y*v.z))+(c.x*(u.y*u.z)));
  RawComponents[2,0]:=(c.z*(v.z*u.x))-((c.y*(v.z*v.x))+(c.x*(u.z*u.x)));
  RawComponents[2,1]:=(c.z*(v.z*u.y))-((c.y*(v.z*v.y))+(c.x*(u.z*u.y)));
  RawComponents[2,2]:=1.0+((c.z*(v.z*u.z))-((c.y*(v.z*v.z))+(c.x*(u.z*u.z))));
 end else begin
  v:=FromDirection.Cross(ToDirection);
  h:=1.0/(1.0+e);
  hvx:=h*v.x;
  hvz:=h*v.z;
  hvxy:=hvx*v.y;
  hvxz:=hvx*v.z;
  hvyz:=hvz*v.y;
  RawComponents[0,0]:=e+(hvx*v.x);
  RawComponents[0,1]:=hvxy-v.z;
  RawComponents[0,2]:=hvxz+v.y;
  RawComponents[1,0]:=hvxy+v.z;
  RawComponents[1,1]:=e+(h*sqr(v.y));
  RawComponents[1,2]:=hvyz-v.x;
  RawComponents[2,0]:=hvxz-v.y;
  RawComponents[2,1]:=hvyz+v.x;
  RawComponents[2,2]:=e+(hvz*v.z);
 end;
end;

constructor TpvMatrix3x3.CreateConstruct(const pForwards,pUp:TpvVector3);
var RightVector,UpVector,ForwardVector:TpvVector3;
begin
 ForwardVector:=(-pForwards).Normalize;
 RightVector:=pUp.Cross(ForwardVector).Normalize;
 UpVector:=ForwardVector.Cross(RightVector).Normalize;
 RawComponents[0,0]:=RightVector.x;
 RawComponents[0,1]:=RightVector.y;
 RawComponents[0,2]:=RightVector.z;
 RawComponents[1,0]:=UpVector.x;
 RawComponents[1,1]:=UpVector.y;
 RawComponents[1,2]:=UpVector.z;
 RawComponents[2,0]:=ForwardVector.x;
 RawComponents[2,1]:=ForwardVector.y;
 RawComponents[2,2]:=ForwardVector.z;
end;

constructor TpvMatrix3x3.CreateConstructForwardUp(const aForward,aUp:TpvVector3);
var RightVector,UpVector,ForwardVector:TpvVector3;
begin
 ForwardVector:=aForward.Normalize;
 RightVector:=aUp.Normalize.Cross(ForwardVector).Normalize;
 UpVector:=ForwardVector.Cross(RightVector).Normalize;
 RawComponents[0,0]:=RightVector.x;
 RawComponents[0,1]:=RightVector.y;
 RawComponents[0,2]:=RightVector.z;
 RawComponents[1,0]:=UpVector.x;
 RawComponents[1,1]:=UpVector.y;
 RawComponents[1,2]:=UpVector.z;
 RawComponents[2,0]:=ForwardVector.x;
 RawComponents[2,1]:=ForwardVector.y;
 RawComponents[2,2]:=ForwardVector.z;
end;

constructor TpvMatrix3x3.CreateOuterProduct(const u,v:TpvVector3);
begin
 RawComponents[0,0]:=u.x*v.x;
 RawComponents[0,1]:=u.x*v.y;
 RawComponents[0,2]:=u.x*v.z;
 RawComponents[1,0]:=u.y*v.x;
 RawComponents[1,1]:=u.y*v.y;
 RawComponents[1,2]:=u.y*v.z;
 RawComponents[2,0]:=u.z*v.x;
 RawComponents[2,1]:=u.z*v.y;
 RawComponents[2,2]:=u.z*v.z;
end;

constructor TpvMatrix3x3.CreateFromQuaternion(ppvQuaternion:TpvQuaternion);
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:TpvScalar;
begin
 ppvQuaternion:=ppvQuaternion.Normalize;
 qx2:=ppvQuaternion.x+ppvQuaternion.x;
 qy2:=ppvQuaternion.y+ppvQuaternion.y;
 qz2:=ppvQuaternion.z+ppvQuaternion.z;
 qxqx2:=ppvQuaternion.x*qx2;
 qxqy2:=ppvQuaternion.x*qy2;
 qxqz2:=ppvQuaternion.x*qz2;
 qxqw2:=ppvQuaternion.w*qx2;
 qyqy2:=ppvQuaternion.y*qy2;
 qyqz2:=ppvQuaternion.y*qz2;
 qyqw2:=ppvQuaternion.w*qy2;
 qzqz2:=ppvQuaternion.z*qz2;
 qzqw2:=ppvQuaternion.w*qz2;
 RawComponents[0,0]:=1.0-(qyqy2+qzqz2);
 RawComponents[0,1]:=qxqy2+qzqw2;
 RawComponents[0,2]:=qxqz2-qyqw2;
 RawComponents[1,0]:=qxqy2-qzqw2;
 RawComponents[1,1]:=1.0-(qxqx2+qzqz2);
 RawComponents[1,2]:=qyqz2+qxqw2;
 RawComponents[2,0]:=qxqz2+qyqw2;
 RawComponents[2,1]:=qyqz2-qxqw2;
 RawComponents[2,2]:=1.0-(qxqx2+qyqy2);
end;

constructor TpvMatrix3x3.CreateFromQTangent(pQTangent:TpvQuaternion);
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:TpvScalar;
begin
 pQTangent:=pQTangent.Normalize;
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
 RawComponents[0,0]:=1.0-(qyqy2+qzqz2);
 RawComponents[0,1]:=qxqy2+qzqw2;
 RawComponents[0,2]:=qxqz2-qyqw2;
 RawComponents[1,0]:=qxqy2-qzqw2;
 RawComponents[1,1]:=1.0-(qxqx2+qzqz2);
 RawComponents[1,2]:=qyqz2+qxqw2;
 RawComponents[2,0]:=(RawComponents[0,1]*RawComponents[1,2])-(RawComponents[0,2]*RawComponents[1,1]);
 RawComponents[2,1]:=(RawComponents[0,2]*RawComponents[1,0])-(RawComponents[0,0]*RawComponents[1,2]);
 RawComponents[2,2]:=(RawComponents[0,0]*RawComponents[1,1])-(RawComponents[0,1]*RawComponents[1,0]);
{RawComponents[2,0]:=qxqz2+qyqw2;
 RawComponents[2,1]:=qyqz2-qxqw2;
 RawComponents[2,2]:=1.0-(qxqx2+qyqy2);}
 if pQTangent.w<0.0 then begin
  RawComponents[2,0]:=-RawComponents[2,0];
  RawComponents[2,1]:=-RawComponents[2,1];
  RawComponents[2,2]:=-RawComponents[2,2];
 end;
end;

constructor TpvMatrix3x3.CreateRecomposed(const DecomposedMatrix3x3:TpvDecomposedMatrix3x3);
begin

 self:=TpvMatrix3x3.CreateFromQuaternion(DecomposedMatrix3x3.Rotation);

 if DecomposedMatrix3x3.Skew.z<>0.0 then begin // YZ
  self:=TpvMatrix3x3.Create(1.0,0.0,0.0,
                            0.0,1.0,0.0,
                            0.0,DecomposedMatrix3x3.Skew.z,1.0)*self;
 end;

 if DecomposedMatrix3x3.Skew.y<>0.0 then begin // XZ
  self:=TpvMatrix3x3.Create(1.0,0.0,0.0,
                            0.0,1.0,0.0,
                            DecomposedMatrix3x3.Skew.y,0.0,1.0)*self;
 end;

 if DecomposedMatrix3x3.Skew.x<>0.0 then begin // XY
  self:=TpvMatrix3x3.Create(1.0,0.0,0.0,
                            DecomposedMatrix3x3.Skew.x,1.0,0.0,
                            0.0,0.0,1.0)*self;
 end;

 self:=TpvMatrix3x3.CreateScale(DecomposedMatrix3x3.Scale)*self;

end;

class operator TpvMatrix3x3.Implicit(const a:TpvScalar):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a;
 result.RawComponents[0,1]:=a;
 result.RawComponents[0,2]:=a;
 result.RawComponents[1,0]:=a;
 result.RawComponents[1,1]:=a;
 result.RawComponents[1,2]:=a;
 result.RawComponents[2,0]:=a;
 result.RawComponents[2,1]:=a;
 result.RawComponents[2,2]:=a;
end;

class operator TpvMatrix3x3.Explicit(const a:TpvScalar):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a;
 result.RawComponents[0,1]:=a;
 result.RawComponents[0,2]:=a;
 result.RawComponents[1,0]:=a;
 result.RawComponents[1,1]:=a;
 result.RawComponents[1,2]:=a;
 result.RawComponents[2,0]:=a;
 result.RawComponents[2,1]:=a;
 result.RawComponents[2,2]:=a;
end;

class operator TpvMatrix3x3.Equal(const a,b:TpvMatrix3x3):boolean;
begin
 result:=SameValue(a.RawComponents[0,0],b.RawComponents[0,0]) and
         SameValue(a.RawComponents[0,1],b.RawComponents[0,1]) and
         SameValue(a.RawComponents[0,2],b.RawComponents[0,2]) and
         SameValue(a.RawComponents[1,0],b.RawComponents[1,0]) and
         SameValue(a.RawComponents[1,1],b.RawComponents[1,1]) and
         SameValue(a.RawComponents[1,2],b.RawComponents[1,2]) and
         SameValue(a.RawComponents[2,0],b.RawComponents[2,0]) and
         SameValue(a.RawComponents[2,1],b.RawComponents[2,1]) and
         SameValue(a.RawComponents[2,2],b.RawComponents[2,2]);
end;

class operator TpvMatrix3x3.NotEqual(const a,b:TpvMatrix3x3):boolean;
begin
 result:=(not SameValue(a.RawComponents[0,0],b.RawComponents[0,0])) or
         (not SameValue(a.RawComponents[0,1],b.RawComponents[0,1])) or
         (not SameValue(a.RawComponents[0,2],b.RawComponents[0,2])) or
         (not SameValue(a.RawComponents[1,0],b.RawComponents[1,0])) or
         (not SameValue(a.RawComponents[1,1],b.RawComponents[1,1])) or
         (not SameValue(a.RawComponents[1,2],b.RawComponents[1,2])) or
         (not SameValue(a.RawComponents[2,0],b.RawComponents[2,0])) or
         (not SameValue(a.RawComponents[2,1],b.RawComponents[2,1])) or
         (not SameValue(a.RawComponents[2,2],b.RawComponents[2,2]));
end;

class operator TpvMatrix3x3.Inc(const a:TpvMatrix3x3):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]+1.0;
 result.RawComponents[0,1]:=a.RawComponents[0,1]+1.0;
 result.RawComponents[0,2]:=a.RawComponents[0,2]+1.0;
 result.RawComponents[1,0]:=a.RawComponents[1,0]+1.0;
 result.RawComponents[1,1]:=a.RawComponents[1,1]+1.0;
 result.RawComponents[1,2]:=a.RawComponents[1,2]+1.0;
 result.RawComponents[2,0]:=a.RawComponents[2,0]+1.0;
 result.RawComponents[2,1]:=a.RawComponents[2,1]+1.0;
 result.RawComponents[2,2]:=a.RawComponents[2,2]+1.0;
end;

class operator TpvMatrix3x3.Dec(const a:TpvMatrix3x3):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]-1.0;
 result.RawComponents[0,1]:=a.RawComponents[0,1]-1.0;
 result.RawComponents[0,2]:=a.RawComponents[0,2]-1.0;
 result.RawComponents[1,0]:=a.RawComponents[1,0]-1.0;
 result.RawComponents[1,1]:=a.RawComponents[1,1]-1.0;
 result.RawComponents[1,2]:=a.RawComponents[1,2]-1.0;
 result.RawComponents[2,0]:=a.RawComponents[2,0]-1.0;
 result.RawComponents[2,1]:=a.RawComponents[2,1]-1.0;
 result.RawComponents[2,2]:=a.RawComponents[2,2]-1.0;
end;

class operator TpvMatrix3x3.Add(const a,b:TpvMatrix3x3):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]+b.RawComponents[0,0];
 result.RawComponents[0,1]:=a.RawComponents[0,1]+b.RawComponents[0,1];
 result.RawComponents[0,2]:=a.RawComponents[0,2]+b.RawComponents[0,2];
 result.RawComponents[1,0]:=a.RawComponents[1,0]+b.RawComponents[1,0];
 result.RawComponents[1,1]:=a.RawComponents[1,1]+b.RawComponents[1,1];
 result.RawComponents[1,2]:=a.RawComponents[1,2]+b.RawComponents[1,2];
 result.RawComponents[2,0]:=a.RawComponents[2,0]+b.RawComponents[2,0];
 result.RawComponents[2,1]:=a.RawComponents[2,1]+b.RawComponents[2,1];
 result.RawComponents[2,2]:=a.RawComponents[2,2]+b.RawComponents[2,2];
end;

class operator TpvMatrix3x3.Add(const a:TpvMatrix3x3;const b:TpvScalar):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]+b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]+b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]+b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]+b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]+b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]+b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]+b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]+b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]+b;
end;

class operator TpvMatrix3x3.Add(const a:TpvScalar;const b:TpvMatrix3x3):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a+b.RawComponents[0,0];
 result.RawComponents[0,1]:=a+b.RawComponents[0,1];
 result.RawComponents[0,2]:=a+b.RawComponents[0,2];
 result.RawComponents[1,0]:=a+b.RawComponents[1,0];
 result.RawComponents[1,1]:=a+b.RawComponents[1,1];
 result.RawComponents[1,2]:=a+b.RawComponents[1,2];
 result.RawComponents[2,0]:=a+b.RawComponents[2,0];
 result.RawComponents[2,1]:=a+b.RawComponents[2,1];
 result.RawComponents[2,2]:=a+b.RawComponents[2,2];
end;

class operator TpvMatrix3x3.Subtract(const a,b:TpvMatrix3x3):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]-b.RawComponents[0,0];
 result.RawComponents[0,1]:=a.RawComponents[0,1]-b.RawComponents[0,1];
 result.RawComponents[0,2]:=a.RawComponents[0,2]-b.RawComponents[0,2];
 result.RawComponents[1,0]:=a.RawComponents[1,0]-b.RawComponents[1,0];
 result.RawComponents[1,1]:=a.RawComponents[1,1]-b.RawComponents[1,1];
 result.RawComponents[1,2]:=a.RawComponents[1,2]-b.RawComponents[1,2];
 result.RawComponents[2,0]:=a.RawComponents[2,0]-b.RawComponents[2,0];
 result.RawComponents[2,1]:=a.RawComponents[2,1]-b.RawComponents[2,1];
 result.RawComponents[2,2]:=a.RawComponents[2,2]-b.RawComponents[2,2];
end;

class operator TpvMatrix3x3.Subtract(const a:TpvMatrix3x3;const b:TpvScalar):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]-b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]-b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]-b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]-b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]-b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]-b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]-b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]-b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]-b;
end;

class operator TpvMatrix3x3.Subtract(const a:TpvScalar;const b:TpvMatrix3x3):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a-b.RawComponents[0,0];
 result.RawComponents[0,1]:=a-b.RawComponents[0,1];
 result.RawComponents[0,2]:=a-b.RawComponents[0,2];
 result.RawComponents[1,0]:=a-b.RawComponents[1,0];
 result.RawComponents[1,1]:=a-b.RawComponents[1,1];
 result.RawComponents[1,2]:=a-b.RawComponents[1,2];
 result.RawComponents[2,0]:=a-b.RawComponents[2,0];
 result.RawComponents[2,1]:=a-b.RawComponents[2,1];
 result.RawComponents[2,2]:=a-b.RawComponents[2,2];
end;

class operator TpvMatrix3x3.Multiply(const a,b:TpvMatrix3x3):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=(a.RawComponents[0,0]*b.RawComponents[0,0])+(a.RawComponents[0,1]*b.RawComponents[1,0])+(a.RawComponents[0,2]*b.RawComponents[2,0]);
 result.RawComponents[0,1]:=(a.RawComponents[0,0]*b.RawComponents[0,1])+(a.RawComponents[0,1]*b.RawComponents[1,1])+(a.RawComponents[0,2]*b.RawComponents[2,1]);
 result.RawComponents[0,2]:=(a.RawComponents[0,0]*b.RawComponents[0,2])+(a.RawComponents[0,1]*b.RawComponents[1,2])+(a.RawComponents[0,2]*b.RawComponents[2,2]);
 result.RawComponents[1,0]:=(a.RawComponents[1,0]*b.RawComponents[0,0])+(a.RawComponents[1,1]*b.RawComponents[1,0])+(a.RawComponents[1,2]*b.RawComponents[2,0]);
 result.RawComponents[1,1]:=(a.RawComponents[1,0]*b.RawComponents[0,1])+(a.RawComponents[1,1]*b.RawComponents[1,1])+(a.RawComponents[1,2]*b.RawComponents[2,1]);
 result.RawComponents[1,2]:=(a.RawComponents[1,0]*b.RawComponents[0,2])+(a.RawComponents[1,1]*b.RawComponents[1,2])+(a.RawComponents[1,2]*b.RawComponents[2,2]);
 result.RawComponents[2,0]:=(a.RawComponents[2,0]*b.RawComponents[0,0])+(a.RawComponents[2,1]*b.RawComponents[1,0])+(a.RawComponents[2,2]*b.RawComponents[2,0]);
 result.RawComponents[2,1]:=(a.RawComponents[2,0]*b.RawComponents[0,1])+(a.RawComponents[2,1]*b.RawComponents[1,1])+(a.RawComponents[2,2]*b.RawComponents[2,1]);
 result.RawComponents[2,2]:=(a.RawComponents[2,0]*b.RawComponents[0,2])+(a.RawComponents[2,1]*b.RawComponents[1,2])+(a.RawComponents[2,2]*b.RawComponents[2,2]);
end;

class operator TpvMatrix3x3.Multiply(const a:TpvMatrix3x3;const b:TpvScalar):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]*b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]*b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]*b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]*b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]*b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]*b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]*b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]*b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]*b;
end;

class operator TpvMatrix3x3.Multiply(const a:TpvScalar;const b:TpvMatrix3x3):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a*b.RawComponents[0,0];
 result.RawComponents[0,1]:=a*b.RawComponents[0,1];
 result.RawComponents[0,2]:=a*b.RawComponents[0,2];
 result.RawComponents[1,0]:=a*b.RawComponents[1,0];
 result.RawComponents[1,1]:=a*b.RawComponents[1,1];
 result.RawComponents[1,2]:=a*b.RawComponents[1,2];
 result.RawComponents[2,0]:=a*b.RawComponents[2,0];
 result.RawComponents[2,1]:=a*b.RawComponents[2,1];
 result.RawComponents[2,2]:=a*b.RawComponents[2,2];
end;

class operator TpvMatrix3x3.Multiply(const a:TpvMatrix3x3;const b:TpvVector2):TpvVector2;
begin
 result.x:=(a.RawComponents[0,0]*b.x)+(a.RawComponents[1,0]*b.y)+a.RawComponents[2,0];
 result.y:=(a.RawComponents[0,1]*b.x)+(a.RawComponents[1,1]*b.y)+a.RawComponents[2,1];
end;

class operator TpvMatrix3x3.Multiply(const a:TpvVector2;const b:TpvMatrix3x3):TpvVector2;
begin
 result.x:=(a.x*b.RawComponents[0,0])+(a.y*b.RawComponents[0,1])+b.RawComponents[0,2];
 result.y:=(a.x*b.RawComponents[1,0])+(a.y*b.RawComponents[1,1])+b.RawComponents[1,2];
end;

class operator TpvMatrix3x3.Multiply(const a:TpvMatrix3x3;const b:TpvVector3):TpvVector3;
begin
 result.x:=(a.RawComponents[0,0]*b.x)+(a.RawComponents[1,0]*b.y)+(a.RawComponents[2,0]*b.z);
 result.y:=(a.RawComponents[0,1]*b.x)+(a.RawComponents[1,1]*b.y)+(a.RawComponents[2,1]*b.z);
 result.z:=(a.RawComponents[0,2]*b.x)+(a.RawComponents[1,2]*b.y)+(a.RawComponents[2,2]*b.z);
end;

class operator TpvMatrix3x3.Multiply(const a:TpvVector3;const b:TpvMatrix3x3):TpvVector3;
begin
 result.x:=(a.x*b.RawComponents[0,0])+(a.y*b.RawComponents[0,1])+(a.z*b.RawComponents[0,2]);
 result.y:=(a.x*b.RawComponents[1,0])+(a.y*b.RawComponents[1,1])+(a.z*b.RawComponents[1,2]);
 result.z:=(a.x*b.RawComponents[2,0])+(a.y*b.RawComponents[2,1])+(a.z*b.RawComponents[2,2]);
end;

class operator TpvMatrix3x3.Multiply(const a:TpvMatrix3x3;const b:TpvVector4):TpvVector4;
begin
 result.x:=(a.RawComponents[0,0]*b.x)+(a.RawComponents[1,0]*b.y)+(a.RawComponents[2,0]*b.z);
 result.y:=(a.RawComponents[0,1]*b.x)+(a.RawComponents[1,1]*b.y)+(a.RawComponents[2,1]*b.z);
 result.z:=(a.RawComponents[0,2]*b.x)+(a.RawComponents[1,2]*b.y)+(a.RawComponents[2,2]*b.z);
 result.w:=b.w;
end;

class operator TpvMatrix3x3.Multiply(const a:TpvVector4;const b:TpvMatrix3x3):TpvVector4;
begin
 result.x:=(a.x*b.RawComponents[0,0])+(a.y*b.RawComponents[0,1])+(a.z*b.RawComponents[0,2]);
 result.y:=(a.x*b.RawComponents[1,0])+(a.y*b.RawComponents[1,1])+(a.z*b.RawComponents[1,2]);
 result.z:=(a.x*b.RawComponents[2,0])+(a.y*b.RawComponents[2,1])+(a.z*b.RawComponents[2,2]);
 result.w:=a.w;
end;

class operator TpvMatrix3x3.Multiply(const a:TpvMatrix3x3;const b:TpvPlane):TpvPlane;
begin
 result.Normal:=a.Inverse.Transpose*b.Normal;
 result.Distance:=result.Normal.Dot(a*((b.Normal*b.Distance)));
end;

class operator TpvMatrix3x3.Multiply(const a:TpvPlane;const b:TpvMatrix3x3):TpvPlane;
begin
 result:=b.Transpose*a;
end;

class operator TpvMatrix3x3.Divide(const a,b:TpvMatrix3x3):TpvMatrix3x3;
begin
 result:=a*b.Inverse;
end;

class operator TpvMatrix3x3.Divide(const a:TpvMatrix3x3;const b:TpvScalar):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]/b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]/b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]/b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]/b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]/b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]/b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]/b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]/b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]/b;
end;

class operator TpvMatrix3x3.Divide(const a:TpvScalar;const b:TpvMatrix3x3):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a/b.RawComponents[0,0];
 result.RawComponents[0,1]:=a/b.RawComponents[0,1];
 result.RawComponents[0,2]:=a/b.RawComponents[0,2];
 result.RawComponents[1,0]:=a/b.RawComponents[1,0];
 result.RawComponents[1,1]:=a/b.RawComponents[1,1];
 result.RawComponents[1,2]:=a/b.RawComponents[1,2];
 result.RawComponents[2,0]:=a/b.RawComponents[2,0];
 result.RawComponents[2,1]:=a/b.RawComponents[2,1];
 result.RawComponents[2,2]:=a/b.RawComponents[2,2];
end;

class operator TpvMatrix3x3.IntDivide(const a,b:TpvMatrix3x3):TpvMatrix3x3;
begin
 result:=a*b.Inverse;
end;

class operator TpvMatrix3x3.IntDivide(const a:TpvMatrix3x3;const b:TpvScalar):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]/b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]/b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]/b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]/b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]/b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]/b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]/b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]/b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]/b;
end;

class operator TpvMatrix3x3.IntDivide(const a:TpvScalar;const b:TpvMatrix3x3):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=a/b.RawComponents[0,0];
 result.RawComponents[0,1]:=a/b.RawComponents[0,1];
 result.RawComponents[0,2]:=a/b.RawComponents[0,2];
 result.RawComponents[1,0]:=a/b.RawComponents[1,0];
 result.RawComponents[1,1]:=a/b.RawComponents[1,1];
 result.RawComponents[1,2]:=a/b.RawComponents[1,2];
 result.RawComponents[2,0]:=a/b.RawComponents[2,0];
 result.RawComponents[2,1]:=a/b.RawComponents[2,1];
 result.RawComponents[2,2]:=a/b.RawComponents[2,2];
end;

class operator TpvMatrix3x3.Modulus(const a,b:TpvMatrix3x3):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=Modulo(a.RawComponents[0,0],b.RawComponents[0,0]);
 result.RawComponents[0,1]:=Modulo(a.RawComponents[0,1],b.RawComponents[0,1]);
 result.RawComponents[0,2]:=Modulo(a.RawComponents[0,2],b.RawComponents[0,2]);
 result.RawComponents[1,0]:=Modulo(a.RawComponents[1,0],b.RawComponents[1,0]);
 result.RawComponents[1,1]:=Modulo(a.RawComponents[1,1],b.RawComponents[1,1]);
 result.RawComponents[1,2]:=Modulo(a.RawComponents[1,2],b.RawComponents[1,2]);
 result.RawComponents[2,0]:=Modulo(a.RawComponents[2,0],b.RawComponents[2,0]);
 result.RawComponents[2,1]:=Modulo(a.RawComponents[2,1],b.RawComponents[2,1]);
 result.RawComponents[2,2]:=Modulo(a.RawComponents[2,2],b.RawComponents[2,2]);
end;

class operator TpvMatrix3x3.Modulus(const a:TpvMatrix3x3;const b:TpvScalar):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=Modulo(a.RawComponents[0,0],b);
 result.RawComponents[0,1]:=Modulo(a.RawComponents[0,1],b);
 result.RawComponents[0,2]:=Modulo(a.RawComponents[0,2],b);
 result.RawComponents[1,0]:=Modulo(a.RawComponents[1,0],b);
 result.RawComponents[1,1]:=Modulo(a.RawComponents[1,1],b);
 result.RawComponents[1,2]:=Modulo(a.RawComponents[1,2],b);
 result.RawComponents[2,0]:=Modulo(a.RawComponents[2,0],b);
 result.RawComponents[2,1]:=Modulo(a.RawComponents[2,1],b);
 result.RawComponents[2,2]:=Modulo(a.RawComponents[2,2],b);
end;

class operator TpvMatrix3x3.Modulus(const a:TpvScalar;const b:TpvMatrix3x3):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=Modulo(a,b.RawComponents[0,0]);
 result.RawComponents[0,1]:=Modulo(a,b.RawComponents[0,1]);
 result.RawComponents[0,2]:=Modulo(a,b.RawComponents[0,2]);
 result.RawComponents[1,0]:=Modulo(a,b.RawComponents[1,0]);
 result.RawComponents[1,1]:=Modulo(a,b.RawComponents[1,1]);
 result.RawComponents[1,2]:=Modulo(a,b.RawComponents[1,2]);
 result.RawComponents[2,0]:=Modulo(a,b.RawComponents[2,0]);
 result.RawComponents[2,1]:=Modulo(a,b.RawComponents[2,1]);
 result.RawComponents[2,2]:=Modulo(a,b.RawComponents[2,2]);
end;

class operator TpvMatrix3x3.Negative(const a:TpvMatrix3x3):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=-a.RawComponents[0,0];
 result.RawComponents[0,1]:=-a.RawComponents[0,1];
 result.RawComponents[0,2]:=-a.RawComponents[0,2];
 result.RawComponents[1,0]:=-a.RawComponents[1,0];
 result.RawComponents[1,1]:=-a.RawComponents[1,1];
 result.RawComponents[1,2]:=-a.RawComponents[1,2];
 result.RawComponents[2,0]:=-a.RawComponents[2,0];
 result.RawComponents[2,1]:=-a.RawComponents[2,1];
 result.RawComponents[2,2]:=-a.RawComponents[2,2];
end;

class operator TpvMatrix3x3.Positive(const a:TpvMatrix3x3):TpvMatrix3x3;
begin
 result:=a;
end;

function TpvMatrix3x3.GetComponent(const pIndexA,pIndexB:TpvInt32):TpvScalar;
begin
 result:=RawComponents[pIndexA,pIndexB];
end;

procedure TpvMatrix3x3.SetComponent(const pIndexA,pIndexB:TpvInt32;const pValue:TpvScalar);
begin
 RawComponents[pIndexA,pIndexB]:=pValue;
end;

function TpvMatrix3x3.GetColumn(const pIndex:TpvInt32):TpvVector3;
begin
 result.x:=RawComponents[pIndex,0];
 result.y:=RawComponents[pIndex,1];
 result.z:=RawComponents[pIndex,2];
end;

procedure TpvMatrix3x3.SetColumn(const pIndex:TpvInt32;const pValue:TpvVector3);
begin
 RawComponents[pIndex,0]:=pValue.x;
 RawComponents[pIndex,1]:=pValue.y;
 RawComponents[pIndex,2]:=pValue.z;
end;

function TpvMatrix3x3.GetRow(const pIndex:TpvInt32):TpvVector3;
begin
 result.x:=RawComponents[0,pIndex];
 result.y:=RawComponents[1,pIndex];
 result.z:=RawComponents[2,pIndex];
end;

procedure TpvMatrix3x3.SetRow(const pIndex:TpvInt32;const pValue:TpvVector3);
begin
 RawComponents[0,pIndex]:=pValue.x;
 RawComponents[1,pIndex]:=pValue.y;
 RawComponents[2,pIndex]:=pValue.z;
end;

function TpvMatrix3x3.Determinant:TpvScalar;
begin
 result:=((RawComponents[0,0]*((RawComponents[1,1]*RawComponents[2,2])-(RawComponents[1,2]*RawComponents[2,1])))-
          (RawComponents[0,1]*((RawComponents[1,0]*RawComponents[2,2])-(RawComponents[1,2]*RawComponents[2,0]))))+
          (RawComponents[0,2]*((RawComponents[1,0]*RawComponents[2,1])-(RawComponents[1,1]*RawComponents[2,0])));
end;

function TpvMatrix3x3.Inverse:TpvMatrix3x3;
var d:TpvScalar;
begin
 d:=((RawComponents[0,0]*((RawComponents[1,1]*RawComponents[2,2])-(RawComponents[1,2]*RawComponents[2,1])))-
     (RawComponents[0,1]*((RawComponents[1,0]*RawComponents[2,2])-(RawComponents[1,2]*RawComponents[2,0]))))+
     (RawComponents[0,2]*((RawComponents[1,0]*RawComponents[2,1])-(RawComponents[1,1]*RawComponents[2,0])));
 if d<>0.0 then begin
  d:=1.0/d;
  result.RawComponents[0,0]:=((RawComponents[1,1]*RawComponents[2,2])-(RawComponents[1,2]*RawComponents[2,1]))*d;
  result.RawComponents[0,1]:=((RawComponents[0,2]*RawComponents[2,1])-(RawComponents[0,1]*RawComponents[2,2]))*d;
  result.RawComponents[0,2]:=((RawComponents[0,1]*RawComponents[1,2])-(RawComponents[0,2]*RawComponents[1,1]))*d;
  result.RawComponents[1,0]:=((RawComponents[1,2]*RawComponents[2,0])-(RawComponents[1,0]*RawComponents[2,2]))*d;
  result.RawComponents[1,1]:=((RawComponents[0,0]*RawComponents[2,2])-(RawComponents[0,2]*RawComponents[2,0]))*d;
  result.RawComponents[1,2]:=((RawComponents[0,2]*RawComponents[1,0])-(RawComponents[0,0]*RawComponents[1,2]))*d;
  result.RawComponents[2,0]:=((RawComponents[1,0]*RawComponents[2,1])-(RawComponents[1,1]*RawComponents[2,0]))*d;
  result.RawComponents[2,1]:=((RawComponents[0,1]*RawComponents[2,0])-(RawComponents[0,0]*RawComponents[2,1]))*d;
  result.RawComponents[2,2]:=((RawComponents[0,0]*RawComponents[1,1])-(RawComponents[0,1]*RawComponents[1,0]))*d;
 end else begin
  result:=TpvMatrix3x3.Identity;
 end;
end;

function TpvMatrix3x3.Transpose:TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=RawComponents[0,0];
 result.RawComponents[0,1]:=RawComponents[1,0];
 result.RawComponents[0,2]:=RawComponents[2,0];
 result.RawComponents[1,0]:=RawComponents[0,1];
 result.RawComponents[1,1]:=RawComponents[1,1];
 result.RawComponents[1,2]:=RawComponents[2,1];
 result.RawComponents[2,0]:=RawComponents[0,2];
 result.RawComponents[2,1]:=RawComponents[1,2];
 result.RawComponents[2,2]:=RawComponents[2,2];
end;

function TpvMatrix3x3.Adjugate:TpvMatrix3x3;
begin
 result.RawVectors[0]:=RawVectors[1].Cross(RawVectors[2]);
 result.RawVectors[1]:=RawVectors[2].Cross(RawVectors[0]);
 result.RawVectors[2]:=RawVectors[0].Cross(RawVectors[1]);
{result.RawComponents[0,0]:=(RawComponents[1,1]*RawComponents[2,2])-(RawComponents[1,2]*RawComponents[2,1]);
 result.RawComponents[0,1]:=(RawComponents[1,2]*RawComponents[2,0])-(RawComponents[1,0]*RawComponents[2,2]);
 result.RawComponents[0,2]:=(RawComponents[1,0]*RawComponents[2,1])-(RawComponents[1,1]*RawComponents[2,0]);
 result.RawComponents[1,0]:=(RawComponents[0,2]*RawComponents[2,1])-(RawComponents[0,1]*RawComponents[2,2]);
 result.RawComponents[1,1]:=(RawComponents[0,0]*RawComponents[2,2])-(RawComponents[0,2]*RawComponents[2,0]);
 result.RawComponents[1,2]:=(RawComponents[0,1]*RawComponents[2,0])-(RawComponents[0,0]*RawComponents[2,1]);
 result.RawComponents[2,0]:=(RawComponents[0,1]*RawComponents[1,2])-(RawComponents[0,2]*RawComponents[1,1]);
 result.RawComponents[2,1]:=(RawComponents[0,2]*RawComponents[1,0])-(RawComponents[0,0]*RawComponents[1,2]);
 result.RawComponents[2,2]:=(RawComponents[0,0]*RawComponents[1,1])-(RawComponents[0,1]*RawComponents[1,0]);}
end;

function TpvMatrix3x3.EulerAngles:TpvVector3;
var v0,v1:TpvVector3;
begin
 if abs((-1.0)-RawComponents[0,2])<EPSILON then begin
  result.x:=0.0;
  result.y:=HalfPI;
  result.z:=ArcTan2(RawComponents[1,0],RawComponents[2,0]);
 end else if abs(1.0-RawComponents[0,2])<EPSILON then begin
  result.x:=0.0;
  result.y:=-HalfPI;
  result.z:=ArcTan2(-RawComponents[1,0],-RawComponents[2,0]);
 end else begin
  v0.x:=-ArcSin(RawComponents[0,2]);
  v1.x:=PI-v0.x;
  v0.y:=ArcTan2(RawComponents[1,2]/cos(v0.x),RawComponents[2,2]/cos(v0.x));
  v1.y:=ArcTan2(RawComponents[1,2]/cos(v1.x),RawComponents[2,2]/cos(v1.x));
  v0.z:=ArcTan2(RawComponents[0,1]/cos(v0.x),RawComponents[0,0]/cos(v0.x));
  v1.z:=ArcTan2(RawComponents[0,1]/cos(v1.x),RawComponents[0,0]/cos(v1.x));
  if v0.SquaredLength<v1.SquaredLength then begin
   result:=v0;
  end else begin
   result:=v1;
  end;
 end;
end;

function TpvMatrix3x3.Normalize:TpvMatrix3x3;
begin
 result.Right:=Right.Normalize;
 result.Up:=Up.Normalize;
 result.Forwards:=Forwards.Normalize;
end;

function TpvMatrix3x3.OrthoNormalize:TpvMatrix3x3;
begin
 result.Normal:=Normal.Normalize;
 result.Tangent:=(Tangent-(result.Normal*Tangent.Dot(result.Normal))).Normalize;
 result.Bitangent:=result.Normal.Cross(result.Tangent).Normalize;
 result.Bitangent:=result.Bitangent-(result.Normal*result.Bitangent.Dot(result.Normal));
 result.Bitangent:=(result.Bitangent-(result.Tangent*result.Bitangent.Dot(result.Tangent))).Normalize;
 result.Tangent:=result.Bitangent.Cross(result.Normal).Normalize;
 result.Normal:=result.Tangent.Cross(result.Bitangent).Normalize;
end;

function TpvMatrix3x3.RobustOrthoNormalize(const Tolerance:TpvScalar=1e-3):TpvMatrix3x3;
var Bisector,Axis:TpvVector3;
begin
 begin
  if Normal.Length<Tolerance then begin
   // Degenerate case, compute new normal
   Normal:=Tangent.Cross(Bitangent);
   if Normal.Length<Tolerance then begin
    result.Tangent:=TpvVector3.XAxis;
    result.Bitangent:=TpvVector3.YAxis;
    result.Normal:=TpvVector3.ZAxis;
    exit;
   end;
  end;
  result.Normal:=Normal.Normalize;
 end;
 begin
  // Project tangent and bitangent onto the normal orthogonal plane
  result.Tangent:=Tangent-(result.Normal*Tangent.Dot(result.Normal));
  result.Bitangent:=Bitangent-(result.Normal*Bitangent.Dot(result.Normal));
 end;
 begin
  // Check for several degenerate cases
  if result.Tangent.Length<Tolerance then begin
   if result.Bitangent.Length<Tolerance then begin
    result.Tangent:=result.Normal.Normalize;
    if (result.Tangent.x<=result.Tangent.y) and (result.Tangent.x<=result.Tangent.z) then begin
     result.Tangent:=TpvVector3.XAxis;
    end else if (result.Tangent.y<=result.Tangent.x) and (result.Tangent.y<=result.Tangent.z) then begin
     result.Tangent:=TpvVector3.YAxis;
    end else begin
     result.Tangent:=TpvVector3.ZAxis;
    end;
    result.Tangent:=result.Tangent-(result.Normal*result.Tangent.Dot(result.Normal));
    result.Bitangent:=result.Normal.Cross(result.Tangent).Normalize;
   end else begin
    result.Tangent:=result.Bitangent.Cross(result.Normal).Normalize;
   end;
  end else begin
   result.Tangent:=result.Tangent.Normalize;
   if result.Bitangent.Length<Tolerance then begin
    result.Bitangent:=result.Normal.Cross(result.Tangent).Normalize;
   end else begin
    result.Bitangent:=result.Bitangent.Normalize;
    Bisector:=result.Tangent+result.Bitangent;
    if Bisector.Length<Tolerance then begin
     Bisector:=result.Tangent;
    end else begin
     Bisector:=Bisector.Normalize;
    end;
    Axis:=Bisector.Cross(result.Normal).Normalize;
    if Axis.Dot(Tangent)>0.0 then begin
     result.Tangent:=(Bisector+Axis).Normalize;
     result.Bitangent:=(Bisector-Axis).Normalize;
    end else begin
     result.Tangent:=(Bisector-Axis).Normalize;
     result.Bitangent:=(Bisector+Axis).Normalize;
    end;
   end;
  end;
 end;
 result.Bitangent:=result.Normal.Cross(result.Tangent).Normalize;
 result.Tangent:=result.Bitangent.Cross(result.Normal).Normalize;
 result.Normal:=result.Tangent.Cross(result.Bitangent).Normalize;
end;

function TpvMatrix3x3.ToQuaternion:TpvQuaternion;
var t,s:TpvScalar;
begin
 t:=RawComponents[0,0]+(RawComponents[1,1]+RawComponents[2,2]);
 if t>2.9999999 then begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
  result.w:=1.0;
 end else if t>0.0000001 then begin
  s:=sqrt(1.0+t)*2.0;
  result.x:=(RawComponents[1,2]-RawComponents[2,1])/s;
  result.y:=(RawComponents[2,0]-RawComponents[0,2])/s;
  result.z:=(RawComponents[0,1]-RawComponents[1,0])/s;
  result.w:=s*0.25;
 end else if (RawComponents[0,0]>RawComponents[1,1]) and (RawComponents[0,0]>RawComponents[2,2]) then begin
  s:=sqrt(1.0+(RawComponents[0,0]-(RawComponents[1,1]+RawComponents[2,2])))*2.0;
  result.x:=s*0.25;
  result.y:=(RawComponents[1,0]+RawComponents[0,1])/s;
  result.z:=(RawComponents[2,0]+RawComponents[0,2])/s;
  result.w:=(RawComponents[1,2]-RawComponents[2,1])/s;
 end else if RawComponents[1,1]>RawComponents[2,2] then begin
  s:=sqrt(1.0+(RawComponents[1,1]-(RawComponents[0,0]+RawComponents[2,2])))*2.0;
  result.x:=(RawComponents[1,0]+RawComponents[0,1])/s;
  result.y:=s*0.25;
  result.z:=(RawComponents[2,1]+RawComponents[1,2])/s;
  result.w:=(RawComponents[2,0]-RawComponents[0,2])/s;
 end else begin
  s:=sqrt(1.0+(RawComponents[2,2]-(RawComponents[0,0]+RawComponents[1,1])))*2.0;
  result.x:=(RawComponents[2,0]+RawComponents[0,2])/s;
  result.y:=(RawComponents[2,1]+RawComponents[1,2])/s;
  result.z:=s*0.25;
  result.w:=(RawComponents[0,1]-RawComponents[1,0])/s;
 end;
 result:=result.Normalize;
end;

function TpvMatrix3x3.ToQTangent(const aThreshold:TpvDouble):TpvQuaternion;
var Scale,t,s,Renormalization:TpvScalar;
begin
 if ((((((RawComponents[0,0]*RawComponents[1,1]*RawComponents[2,2])+
         (RawComponents[0,1]*RawComponents[1,2]*RawComponents[2,0])
        )+
        (RawComponents[0,2]*RawComponents[1,0]*RawComponents[2,1])
       )-
       (RawComponents[0,2]*RawComponents[1,1]*RawComponents[2,0])
      )-
      (RawComponents[0,1]*RawComponents[1,0]*RawComponents[2,2])
     )-
     (RawComponents[0,0]*RawComponents[1,2]*RawComponents[2,1])
    )<0.0 then begin
  // Reflection matrix, so flip y axis in case the tangent frame encodes a reflection
  Scale:=-1.0;
 end else begin
  // Rotation matrix, so nothing is doing to do
  Scale:=1.0;
 end;
 begin
  // Convert to quaternion
  t:=RawComponents[0,0]+(RawComponents[1,1]+(RawComponents[2,2]*Scale));
  if t>2.9999999 then begin
   result.x:=0.0;
   result.y:=0.0;
   result.z:=0.0;
   result.w:=1.0;
  end else if t>0.0000001 then begin
   s:=sqrt(1.0+t)*2.0;
   result.x:=(RawComponents[1,2]-(RawComponents[2,1]*Scale))/s;
   result.y:=((RawComponents[2,0]*Scale)-RawComponents[0,2])/s;
   result.z:=(RawComponents[0,1]-RawComponents[1,0])/s;
   result.w:=s*0.25;
  end else if (RawComponents[0,0]>RawComponents[1,1]) and (RawComponents[0,0]>(RawComponents[2,2]*Scale)) then begin
   s:=sqrt(1.0+(RawComponents[0,0]-(RawComponents[1,1]+(RawComponents[2,2]*Scale))))*2.0;
   result.x:=s*0.25;
   result.y:=(RawComponents[1,0]+RawComponents[0,1])/s;
   result.z:=((RawComponents[2,0]*Scale)+RawComponents[0,2])/s;
   result.w:=(RawComponents[1,2]-(RawComponents[2,1]*Scale))/s;
  end else if RawComponents[1,1]>(RawComponents[2,2]*Scale) then begin
   s:=sqrt(1.0+(RawComponents[1,1]-(RawComponents[0,0]+(RawComponents[2,2]*Scale))))*2.0;
   result.x:=(RawComponents[1,0]+RawComponents[0,1])/s;
   result.y:=s*0.25;
   result.z:=((RawComponents[2,1]*Scale)+RawComponents[1,2])/s;
   result.w:=((RawComponents[2,0]*Scale)-RawComponents[0,2])/s;
  end else begin
   s:=sqrt(1.0+((RawComponents[2,2]*Scale)-(RawComponents[0,0]+RawComponents[1,1])))*2.0;
   result.x:=((RawComponents[2,0]*Scale)+RawComponents[0,2])/s;
   result.y:=((RawComponents[2,1]*Scale)+RawComponents[1,2])/s;
   result.z:=s*0.25;
   result.w:=(RawComponents[0,1]-RawComponents[1,0])/s;
  end;
  result:=result.Normalize;
 end;
 begin
  // Make sure, that we don't end up with 0 as w component
  if abs(result.w)<=aThreshold then begin
   Renormalization:=sqrt(1.0-sqr(aThreshold));
   result.x:=result.x*Renormalization;
   result.y:=result.y*Renormalization;
   result.z:=result.z*Renormalization;
   if result.w>0.0 then begin
    result.w:=aThreshold;
   end else begin
    result.w:=-aThreshold;
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

function TpvMatrix3x3.SimpleLerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result:=(self*(1.0-t))+(b*t);
 end;
end;

function TpvMatrix3x3.SimpleNlerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3;
var Scale:TpvVector3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  Scale:=TpvVector3.Create(Right.Length,
                           Up.Length,
                           Forwards.Length).Lerp(TpvVector3.Create(b.Right.Length,
                                                                   b.Up.Length,
                                                                   b.Forwards.Length),
                                                 t);
  result:=TpvMatrix3x3.CreateFromQuaternion(Normalize.ToQuaternion.Nlerp(b.Normalize.ToQuaternion,t));
  result.Right:=result.Right*Scale.x;
  result.Up:=result.Up*Scale.y;
  result.Forwards:=result.Forwards*Scale.z;
 end;
end;

function TpvMatrix3x3.SimpleSlerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3;
var Scale:TpvVector3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  Scale:=TpvVector3.Create(Right.Length,
                           Up.Length,
                           Forwards.Length).Lerp(TpvVector3.Create(b.Right.Length,
                                                                   b.Up.Length,
                                                                   b.Forwards.Length),
                                                 t);
  result:=TpvMatrix3x3.CreateFromQuaternion(Normalize.ToQuaternion.Slerp(b.Normalize.ToQuaternion,t));
  result.Right:=result.Right*Scale.x;
  result.Up:=result.Up*Scale.y;
  result.Forwards:=result.Forwards*Scale.z;
 end;
end;

function TpvMatrix3x3.SimpleElerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3;
var Scale:TpvVector3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  Scale:=TpvVector3.Create(Right.Length,
                           Up.Length,
                           Forwards.Length).Lerp(TpvVector3.Create(b.Right.Length,
                                                                   b.Up.Length,
                                                                   b.Forwards.Length),
                                                 t);
  result:=TpvMatrix3x3.CreateFromQuaternion(Normalize.ToQuaternion.Elerp(b.Normalize.ToQuaternion,t));
  result.Right:=result.Right*Scale.x;
  result.Up:=result.Up*Scale.y;
  result.Forwards:=result.Forwards*Scale.z;
 end;
end;

function TpvMatrix3x3.SimpleSqlerp(const aB,aC,aD:TpvMatrix3x3;const aTime:TpvScalar):TpvMatrix3x3;
begin
 result:=SimpleSlerp(aD,aTime).SimpleSlerp(aB.SimpleSlerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

function TpvMatrix3x3.Lerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result:=TpvMatrix3x3.CreateRecomposed(Decompose.Lerp(b.Decompose,t));
 end;
end;

function TpvMatrix3x3.Nlerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result:=TpvMatrix3x3.CreateRecomposed(Decompose.Nlerp(b.Decompose,t));
 end;
end;

function TpvMatrix3x3.Slerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result:=TpvMatrix3x3.CreateRecomposed(Decompose.Slerp(b.Decompose,t));
 end;
end;

function TpvMatrix3x3.Elerp(const b:TpvMatrix3x3;const t:TpvScalar):TpvMatrix3x3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result:=TpvMatrix3x3.CreateRecomposed(Decompose.Elerp(b.Decompose,t));
 end;
end;

function TpvMatrix3x3.Sqlerp(const aB,aC,aD:TpvMatrix3x3;const aTime:TpvScalar):TpvMatrix3x3;
begin
 result:=Slerp(aD,aTime).Slerp(aB.Slerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

function TpvMatrix3x3.MulInverse(const a:TpvVector3):TpvVector3;
{var d:TpvScalar;
begin
 d:=((RawComponents[0,0]*((RawComponents[1,1]*RawComponents[2,2])-(RawComponents[2,1]*RawComponents[1,2])))-
     (RawComponents[0,1]*((RawComponents[1,0]*RawComponents[2,2])-(RawComponents[2,0]*RawComponents[1,2]))))+
     (RawComponents[0,2]*((RawComponents[1,0]*RawComponents[2,1])-(RawComponents[2,0]*RawComponents[1,1])));
 if d<>0.0 then begin
  d:=1.0/d;
 end;
 result.x:=((a.x*((RawComponents[1,1]*RawComponents[2,2])-(RawComponents[1,2]*RawComponents[2,1])))+(a.y*((RawComponents[1,2]*RawComponents[2,0])-(RawComponents[1,0]*RawComponents[2,2])))+(a.z*((RawComponents[1,0]*RawComponents[2,1])-(RawComponents[1,1]*RawComponents[2,0]))))*d;
 result.y:=((RawComponents[0,0]*((a.y*RawComponents[2,2])-(a.z*RawComponents[2,1])))+(RawComponents[0,1]*((a.z*RawComponents[2,0])-(a.x*RawComponents[2,2])))+(RawComponents[0,2]*((a.x*RawComponents[2,1])-(a.y*RawComponents[2,0]))))*d;
 result.z:=((RawComponents[0,0]*((RawComponents[1,1]*a.z)-(RawComponents[1,2]*a.y)))+(RawComponents[0,1]*((RawComponents[1,2]*a.x)-(RawComponents[1,0]*a.z)))+(RawComponents[0,2]*((RawComponents[1,0]*a.y)-(RawComponents[1,1]*a.x))))*d;
end;}
begin
 result:=Inverse*a;
end;

function TpvMatrix3x3.MulInverse(const a:TpvVector4):TpvVector4;
{var d:TpvScalar;
begin
 d:=((RawComponents[0,0]*((RawComponents[1,1]*RawComponents[2,2])-(RawComponents[2,1]*RawComponents[1,2])))-
     (RawComponents[0,1]*((RawComponents[1,0]*RawComponents[2,2])-(RawComponents[2,0]*RawComponents[1,2]))))+
     (RawComponents[0,2]*((RawComponents[1,0]*RawComponents[2,1])-(RawComponents[2,0]*RawComponents[1,1])));
 if d<>0.0 then begin
  d:=1.0/d;
 end;
 result.x:=((a.x*((RawComponents[1,1]*RawComponents[2,2])-(RawComponents[1,2]*RawComponents[2,1])))+(a.y*((RawComponents[1,2]*RawComponents[2,0])-(RawComponents[1,0]*RawComponents[2,2])))+(a.z*((RawComponents[1,0]*RawComponents[2,1])-(RawComponents[1,1]*RawComponents[2,0]))))*d;
 result.y:=((RawComponents[0,0]*((a.y*RawComponents[2,2])-(a.z*RawComponents[2,1])))+(RawComponents[0,1]*((a.z*RawComponents[2,0])-(a.x*RawComponents[2,2])))+(RawComponents[0,2]*((a.x*RawComponents[2,1])-(a.y*RawComponents[2,0]))))*d;
 result.z:=((RawComponents[0,0]*((RawComponents[1,1]*a.z)-(RawComponents[1,2]*a.y)))+(RawComponents[0,1]*((RawComponents[1,2]*a.x)-(RawComponents[1,0]*a.z)))+(RawComponents[0,2]*((RawComponents[1,0]*a.y)-(RawComponents[1,1]*a.x))))*d;
 result.w:=a.w;
end;}
begin
 result:=Inverse*a;
end;

function TpvMatrix3x3.Decompose:TpvDecomposedMatrix3x3;
var LocalMatrix:TpvMatrix3x3;
begin

 if (RawComponents[0,0]=1.0) and
    (RawComponents[0,1]=0.0) and
    (RawComponents[0,2]=0.0) and
    (RawComponents[1,0]=0.0) and
    (RawComponents[1,1]=1.0) and
    (RawComponents[1,2]=0.0) and
    (RawComponents[2,0]=0.0) and
    (RawComponents[2,1]=0.0) and
    (RawComponents[2,2]=1.0) then begin

  result.Scale:=TpvVector3.Create(1.0,1.0,1.0);
  result.Skew:=TpvVector3.Create(0.0,0.0,0.0);
  result.Rotation:=TpvQuaternion.Create(0.0,0.0,0.0,1.0);

  result.Valid:=true;

 end else if Determinant=0.0 then begin

  result.Valid:=false;

 end else begin

  LocalMatrix:=self;

  result.Scale.x:=LocalMatrix.Right.Length;
  LocalMatrix.Right:=LocalMatrix.Right.Normalize;

  result.Skew.x:=LocalMatrix.Right.Dot(LocalMatrix.Up);
  LocalMatrix.Up:=LocalMatrix.Up-(LocalMatrix.Right*result.Skew.x);

  result.Scale.y:=LocalMatrix.Up.Length;
  LocalMatrix.Up:=LocalMatrix.Up.Normalize;

  result.Skew.x:=result.Skew.x/result.Scale.y;

  result.Skew.y:=LocalMatrix.Right.Dot(LocalMatrix.Forwards);
  LocalMatrix.Forwards:=LocalMatrix.Forwards-(LocalMatrix.Right*result.Skew.y);
  result.Skew.z:=LocalMatrix.Up.Dot(LocalMatrix.Forwards);
  LocalMatrix.Forwards:=LocalMatrix.Forwards-(LocalMatrix.Up*result.Skew.z);

  result.Scale.z:=LocalMatrix.Forwards.Length;
  LocalMatrix.Forwards:=LocalMatrix.Forwards.Normalize;

  result.Skew.yz:=result.Skew.yz/result.Scale.z;

  if LocalMatrix.Right.Dot(LocalMatrix.Up.Cross(LocalMatrix.Forwards))<0.0 then begin
   result.Scale.x:=-result.Scale.x;
   LocalMatrix:=-LocalMatrix;
  end;

  result.Rotation:=LocalMatrix.ToQuaternion;

  result.Valid:=true;

 end;

end;

class function TpvDecomposedMatrix4x4.Create:TpvDecomposedMatrix4x4;
begin
 result.Perspective:=TpvVector4.Create(0.0,0.0,0.0,1.0);
 result.Translation:=TpvVector3.Create(0.0,0.0,0.0);
 result.Scale:=TpvVector3.Create(1.0,1.0,1.0);
 result.Skew:=TpvVector3.Create(0.0,0.0,0.0);
 result.Rotation:=TpvQuaternion.Create(0.0,0.0,0.0,1.0);
 result.Valid:=true;
end;

function TpvDecomposedMatrix4x4.Lerp(const b:TpvDecomposedMatrix4x4;const t:TpvScalar):TpvDecomposedMatrix4x4;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result.Perspective:=Perspective.Lerp(b.Perspective,t);
  result.Translation:=Translation.Lerp(b.Translation,t);
  result.Scale:=Scale.Lerp(b.Scale,t);
  result.Skew:=Skew.Lerp(b.Skew,t);
  result.Rotation:=Rotation.Lerp(b.Rotation,t);
 end;
end;

function TpvDecomposedMatrix4x4.Nlerp(const b:TpvDecomposedMatrix4x4;const t:TpvScalar):TpvDecomposedMatrix4x4;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result.Perspective:=Perspective.Lerp(b.Perspective,t);
  result.Translation:=Translation.Lerp(b.Translation,t);
  result.Scale:=Scale.Lerp(b.Scale,t);
  result.Skew:=Skew.Lerp(b.Skew,t);
  result.Rotation:=Rotation.Nlerp(b.Rotation,t);
 end;
end;

function TpvDecomposedMatrix4x4.Slerp(const b:TpvDecomposedMatrix4x4;const t:TpvScalar):TpvDecomposedMatrix4x4;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result.Perspective:=Perspective.Lerp(b.Perspective,t);
  result.Translation:=Translation.Lerp(b.Translation,t);
  result.Scale:=Scale.Lerp(b.Scale,t);
  result.Skew:=Skew.Lerp(b.Skew,t);
  result.Rotation:=Rotation.Slerp(b.Rotation,t);
 end;
end;

function TpvDecomposedMatrix4x4.Elerp(const b:TpvDecomposedMatrix4x4;const t:TpvScalar):TpvDecomposedMatrix4x4;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result.Perspective:=Perspective.Lerp(b.Perspective,t);
  result.Translation:=Translation.Lerp(b.Translation,t);
  result.Scale:=Scale.Lerp(b.Scale,t);
  result.Skew:=Skew.Lerp(b.Skew,t);
  result.Rotation:=Rotation.Elerp(b.Rotation,t);
 end;
end;

function TpvDecomposedMatrix4x4.Sqlerp(const aB,aC,aD:TpvDecomposedMatrix4x4;const aTime:TpvScalar):TpvDecomposedMatrix4x4;
begin
 result:=Slerp(aD,aTime).Slerp(aB.Slerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

{constructor TpvMatrix4x4.Create;
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;//}

constructor TpvMatrix4x4.Create(const pX:TpvScalar);
begin
 RawComponents[0,0]:=pX;
 RawComponents[0,1]:=pX;
 RawComponents[0,2]:=pX;
 RawComponents[0,3]:=pX;
 RawComponents[1,0]:=pX;
 RawComponents[1,1]:=pX;
 RawComponents[1,2]:=pX;
 RawComponents[1,3]:=pX;
 RawComponents[2,0]:=pX;
 RawComponents[2,1]:=pX;
 RawComponents[2,2]:=pX;
 RawComponents[2,3]:=pX;
 RawComponents[3,0]:=pX;
 RawComponents[3,1]:=pX;
 RawComponents[3,2]:=pX;
 RawComponents[3,3]:=pX;
end;

constructor TpvMatrix4x4.Create(const pXX,pXY,pXZ,pXW,pYX,pYY,pYZ,pYW,pZX,pZY,pZZ,pZW,pWX,pWY,pWZ,pWW:TpvScalar);
begin
 RawComponents[0,0]:=pXX;
 RawComponents[0,1]:=pXY;
 RawComponents[0,2]:=pXZ;
 RawComponents[0,3]:=pXW;
 RawComponents[1,0]:=pYX;
 RawComponents[1,1]:=pYY;
 RawComponents[1,2]:=pYZ;
 RawComponents[1,3]:=pYW;
 RawComponents[2,0]:=pZX;
 RawComponents[2,1]:=pZY;
 RawComponents[2,2]:=pZZ;
 RawComponents[2,3]:=pZW;
 RawComponents[3,0]:=pWX;
 RawComponents[3,1]:=pWY;
 RawComponents[3,2]:=pWZ;
 RawComponents[3,3]:=pWW;
end;

constructor TpvMatrix4x4.Create(const pX,pY,pZ:TpvVector3);
begin
 RawComponents[0,0]:=pX.x;
 RawComponents[0,1]:=pX.y;
 RawComponents[0,2]:=pX.z;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=pY.x;
 RawComponents[1,1]:=pY.y;
 RawComponents[1,2]:=pY.z;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=pZ.x;
 RawComponents[2,1]:=pZ.y;
 RawComponents[2,2]:=pZ.z;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.Create(const pX,pY,pZ,pW:TpvVector3);
begin
 RawComponents[0,0]:=pX.x;
 RawComponents[0,1]:=pX.y;
 RawComponents[0,2]:=pX.z;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=pY.x;
 RawComponents[1,1]:=pY.y;
 RawComponents[1,2]:=pY.z;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=pZ.x;
 RawComponents[2,1]:=pZ.y;
 RawComponents[2,2]:=pZ.z;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=pW.x;
 RawComponents[3,1]:=pW.y;
 RawComponents[3,2]:=pW.z;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.Create(const pX,pY,pZ,pW:TpvVector4);
begin
 RawComponents[0,0]:=pX.x;
 RawComponents[0,1]:=pX.y;
 RawComponents[0,2]:=pX.z;
 RawComponents[0,3]:=pX.w;
 RawComponents[1,0]:=pY.x;
 RawComponents[1,1]:=pY.y;
 RawComponents[1,2]:=pY.z;
 RawComponents[1,3]:=pY.w;
 RawComponents[2,0]:=pZ.x;
 RawComponents[2,1]:=pZ.y;
 RawComponents[2,2]:=pZ.z;
 RawComponents[2,3]:=pZ.w;
 RawComponents[3,0]:=pW.x;
 RawComponents[3,1]:=pW.y;
 RawComponents[3,2]:=pW.z;
 RawComponents[3,3]:=pW.w;
end;

constructor TpvMatrix4x4.Create(const pMatrix:TpvMatrix3x3);
begin
 RawComponents[0,0]:=pMatrix.RawComponents[0,0];
 RawComponents[0,1]:=pMatrix.RawComponents[0,1];
 RawComponents[0,2]:=pMatrix.RawComponents[0,2];
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=pMatrix.RawComponents[1,0];
 RawComponents[1,1]:=pMatrix.RawComponents[1,1];
 RawComponents[1,2]:=pMatrix.RawComponents[1,2];
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=pMatrix.RawComponents[2,0];
 RawComponents[2,1]:=pMatrix.RawComponents[2,1];
 RawComponents[2,2]:=pMatrix.RawComponents[2,2];
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateRotateX(const Angle:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 SinCos(Angle,RawComponents[1,2],RawComponents[1,1]);
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=-RawComponents[1,2];
 RawComponents[2,2]:=RawComponents[1,1];
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateRotateY(const Angle:TpvScalar);
begin
 SinCos(Angle,RawComponents[2,0],RawComponents[0,0]);
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=-RawComponents[2,0];
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=RawComponents[0,0];
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateRotateZ(const Angle:TpvScalar);
begin
 SinCos(Angle,RawComponents[0,1],RawComponents[0,0]);
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=-RawComponents[0,1];
 RawComponents[1,1]:=RawComponents[0,0];
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateRotate(const Angle:TpvScalar;const Axis:TpvVector3);
var SinusAngle,CosinusAngle:TpvScalar;
begin
 SinCos(Angle,SinusAngle,CosinusAngle);
 RawComponents[0,0]:=CosinusAngle+((1.0-CosinusAngle)*sqr(Axis.x));
 RawComponents[1,0]:=((1.0-CosinusAngle)*Axis.x*Axis.y)-(Axis.z*SinusAngle);
 RawComponents[2,0]:=((1.0-CosinusAngle)*Axis.x*Axis.z)+(Axis.y*SinusAngle);
 RawComponents[0,3]:=0.0;
 RawComponents[0,1]:=((1.0-CosinusAngle)*Axis.x*Axis.z)+(Axis.z*SinusAngle);
 RawComponents[1,1]:=CosinusAngle+((1.0-CosinusAngle)*sqr(Axis.y));
 RawComponents[2,1]:=((1.0-CosinusAngle)*Axis.y*Axis.z)-(Axis.x*SinusAngle);
 RawComponents[1,3]:=0.0;
 RawComponents[0,2]:=((1.0-CosinusAngle)*Axis.x*Axis.z)-(Axis.y*SinusAngle);
 RawComponents[1,2]:=((1.0-CosinusAngle)*Axis.y*Axis.z)+(Axis.x*SinusAngle);
 RawComponents[2,2]:=CosinusAngle+((1.0-CosinusAngle)*sqr(Axis.z));
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateRotation(const pMatrix:TpvMatrix4x4);
begin
 RawComponents[0,0]:=pMatrix.RawComponents[0,0];
 RawComponents[0,1]:=pMatrix.RawComponents[0,1];
 RawComponents[0,2]:=pMatrix.RawComponents[0,2];
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=pMatrix.RawComponents[1,0];
 RawComponents[1,1]:=pMatrix.RawComponents[1,1];
 RawComponents[1,2]:=pMatrix.RawComponents[1,2];
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=pMatrix.RawComponents[2,0];
 RawComponents[2,1]:=pMatrix.RawComponents[2,1];
 RawComponents[2,2]:=pMatrix.RawComponents[2,2];
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateSkewYX(const Angle:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=tan(Angle);
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateSkewZX(const Angle:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=tan(Angle);
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateSkewXY(const Angle:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=tan(Angle);
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateSkewZY(const Angle:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=tan(Angle);
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateSkewXZ(const Angle:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=tan(Angle);
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateSkewYZ(const Angle:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=tan(Angle);
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateScale(const sx,sy:TpvScalar);
begin
 RawComponents[0,0]:=sx;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=sy;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateScale(const pScale:TpvVector2);
begin
 RawComponents[0,0]:=pScale.x;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=pScale.y;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateScale(const sx,sy,sz:TpvScalar);
begin
 RawComponents[0,0]:=sx;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=sy;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=sz;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateScale(const pScale:TpvVector3);
begin
 RawComponents[0,0]:=pScale.x;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=pScale.y;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=pScale.z;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateScale(const sx,sy,sz,sw:TpvScalar);
begin
 RawComponents[0,0]:=sx;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=sy;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=sz;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=sw;
end;

constructor TpvMatrix4x4.CreateScale(const pScale:TpvVector4);
begin
 RawComponents[0,0]:=pScale.x;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=pScale.y;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=pScale.z;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=pScale.w;
end;

constructor TpvMatrix4x4.CreateTranslation(const tx,ty:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=tx;
 RawComponents[3,1]:=ty;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateTranslation(const pTranslation:TpvVector2);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=pTranslation.x;
 RawComponents[3,1]:=pTranslation.y;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateTranslation(const tx,ty,tz:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=tx;
 RawComponents[3,1]:=ty;
 RawComponents[3,2]:=tz;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateTranslation(const pTranslation:TpvVector3);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=pTranslation.x;
 RawComponents[3,1]:=pTranslation.y;
 RawComponents[3,2]:=pTranslation.z;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateTranslation(const tx,ty,tz,tw:TpvScalar);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=tx;
 RawComponents[3,1]:=ty;
 RawComponents[3,2]:=tz;
 RawComponents[3,3]:=tw;
end;

constructor TpvMatrix4x4.CreateTranslation(const pTranslation:TpvVector4);
begin
 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=pTranslation.x;
 RawComponents[3,1]:=pTranslation.y;
 RawComponents[3,2]:=pTranslation.z;
 RawComponents[3,3]:=pTranslation.w;
end;

constructor TpvMatrix4x4.CreateTranslated(const pMatrix:TpvMatrix4x4;pTranslation:TpvVector3);
begin
 RawComponents[0]:=pMatrix.RawComponents[0];
 RawComponents[1]:=pMatrix.RawComponents[1];
 RawComponents[2]:=pMatrix.RawComponents[2];
 RawComponents[3,0]:=(pMatrix.RawComponents[0,0]*pTranslation.x)+(pMatrix.RawComponents[1,0]*pTranslation.y)+(pMatrix.RawComponents[2,0]*pTranslation.z)+pMatrix.RawComponents[3,0];
 RawComponents[3,1]:=(pMatrix.RawComponents[0,1]*pTranslation.x)+(pMatrix.RawComponents[1,1]*pTranslation.y)+(pMatrix.RawComponents[2,1]*pTranslation.z)+pMatrix.RawComponents[3,1];
 RawComponents[3,2]:=(pMatrix.RawComponents[0,2]*pTranslation.x)+(pMatrix.RawComponents[1,2]*pTranslation.y)+(pMatrix.RawComponents[2,2]*pTranslation.z)+pMatrix.RawComponents[3,2];
 RawComponents[3,3]:=(pMatrix.RawComponents[0,3]*pTranslation.x)+(pMatrix.RawComponents[1,3]*pTranslation.y)+(pMatrix.RawComponents[2,3]*pTranslation.z)+pMatrix.RawComponents[3,3];
end;

constructor TpvMatrix4x4.CreateTranslated(const pMatrix:TpvMatrix4x4;pTranslation:TpvVector4);
begin
 RawComponents[0]:=pMatrix.RawComponents[0];
 RawComponents[1]:=pMatrix.RawComponents[1];
 RawComponents[2]:=pMatrix.RawComponents[2];
 RawComponents[3,0]:=(pMatrix.RawComponents[0,0]*pTranslation.x)+(pMatrix.RawComponents[1,0]*pTranslation.y)+(pMatrix.RawComponents[2,0]*pTranslation.z)+(pMatrix.RawComponents[3,0]*pTranslation.w);
 RawComponents[3,1]:=(pMatrix.RawComponents[0,1]*pTranslation.x)+(pMatrix.RawComponents[1,1]*pTranslation.y)+(pMatrix.RawComponents[2,1]*pTranslation.z)+(pMatrix.RawComponents[3,1]*pTranslation.w);
 RawComponents[3,2]:=(pMatrix.RawComponents[0,2]*pTranslation.x)+(pMatrix.RawComponents[1,2]*pTranslation.y)+(pMatrix.RawComponents[2,2]*pTranslation.z)+(pMatrix.RawComponents[3,2]*pTranslation.w);
 RawComponents[3,3]:=(pMatrix.RawComponents[0,3]*pTranslation.x)+(pMatrix.RawComponents[1,3]*pTranslation.y)+(pMatrix.RawComponents[2,3]*pTranslation.z)+(pMatrix.RawComponents[3,3]*pTranslation.w);
end;

constructor TpvMatrix4x4.CreateFromToRotation(const FromDirection,ToDirection:TpvVector3);
var e,h,hvx,hvz,hvxy,hvxz,hvyz:TpvScalar;
    x,u,v,c:TpvVector3;
begin
 e:=FromDirection.Dot(ToDirection);
 if abs(e)>(1.0-EPSILON) then begin
  x:=FromDirection.Abs;
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
  u:=x-FromDirection;
  v:=x-ToDirection;
  c.x:=2.0/(sqr(u.x)+sqr(u.y)+sqr(u.z));
  c.y:=2.0/(sqr(v.x)+sqr(v.y)+sqr(v.z));
  c.z:=c.x*c.y*((u.x*v.x)+(u.y*v.y)+(u.z*v.z));
  RawComponents[0,0]:=1.0+((c.z*(v.x*u.x))-((c.y*(v.x*v.x))+(c.x*(u.x*u.x))));
  RawComponents[0,1]:=(c.z*(v.x*u.y))-((c.y*(v.x*v.y))+(c.x*(u.x*u.y)));
  RawComponents[0,2]:=(c.z*(v.x*u.z))-((c.y*(v.x*v.z))+(c.x*(u.x*u.z)));
  RawComponents[0,3]:=0.0;
  RawComponents[1,0]:=(c.z*(v.y*u.x))-((c.y*(v.y*v.x))+(c.x*(u.y*u.x)));
  RawComponents[1,1]:=1.0+((c.z*(v.y*u.y))-((c.y*(v.y*v.y))+(c.x*(u.y*u.y))));
  RawComponents[1,2]:=(c.z*(v.y*u.z))-((c.y*(v.y*v.z))+(c.x*(u.y*u.z)));
  RawComponents[1,3]:=0.0;
  RawComponents[2,0]:=(c.z*(v.z*u.x))-((c.y*(v.z*v.x))+(c.x*(u.z*u.x)));
  RawComponents[2,1]:=(c.z*(v.z*u.y))-((c.y*(v.z*v.y))+(c.x*(u.z*u.y)));
  RawComponents[2,2]:=1.0+((c.z*(v.z*u.z))-((c.y*(v.z*v.z))+(c.x*(u.z*u.z))));
  RawComponents[2,3]:=0.0;
  RawComponents[3,0]:=0.0;
  RawComponents[3,1]:=0.0;
  RawComponents[3,2]:=0.0;
  RawComponents[3,3]:=1.0;
 end else begin
  v:=FromDirection.Cross(ToDirection);
  h:=1.0/(1.0+e);
  hvx:=h*v.x;
  hvz:=h*v.z;
  hvxy:=hvx*v.y;
  hvxz:=hvx*v.z;
  hvyz:=hvz*v.y;
  RawComponents[0,0]:=e+(hvx*v.x);
  RawComponents[0,1]:=hvxy-v.z;
  RawComponents[0,2]:=hvxz+v.y;
  RawComponents[0,3]:=0.0;
  RawComponents[1,0]:=hvxy+v.z;
  RawComponents[1,1]:=e+(h*sqr(v.y));
  RawComponents[1,2]:=hvyz-v.x;
  RawComponents[1,3]:=0.0;
  RawComponents[2,0]:=hvxz-v.y;
  RawComponents[2,1]:=hvyz+v.x;
  RawComponents[2,2]:=e+(hvz*v.z);
  RawComponents[2,3]:=0.0;
  RawComponents[3,0]:=0.0;
  RawComponents[3,1]:=0.0;
  RawComponents[3,2]:=0.0;
  RawComponents[3,3]:=1.0;
 end;
end;

constructor TpvMatrix4x4.CreateConstruct(const pForwards,pUp:TpvVector3);
var RightVector,UpVector,ForwardVector:TpvVector3;
begin
 ForwardVector:=(-pForwards).Normalize;
 RightVector:=pUp.Cross(ForwardVector).Normalize;
 UpVector:=ForwardVector.Cross(RightVector).Normalize;
 RawComponents[0,0]:=RightVector.x;
 RawComponents[0,1]:=RightVector.y;
 RawComponents[0,2]:=RightVector.z;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=UpVector.x;
 RawComponents[1,1]:=UpVector.y;
 RawComponents[1,2]:=UpVector.z;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=ForwardVector.x;
 RawComponents[2,1]:=ForwardVector.y;
 RawComponents[2,2]:=ForwardVector.z;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateOuterProduct(const u,v:TpvVector3);
begin
 RawComponents[0,0]:=u.x*v.x;
 RawComponents[0,1]:=u.x*v.y;
 RawComponents[0,2]:=u.x*v.z;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=u.y*v.x;
 RawComponents[1,1]:=u.y*v.y;
 RawComponents[1,2]:=u.y*v.z;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=u.z*v.x;
 RawComponents[2,1]:=u.z*v.y;
 RawComponents[2,2]:=u.z*v.z;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateFromQuaternion(ppvQuaternion:TpvQuaternion);
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:TpvScalar;
begin
 ppvQuaternion:=ppvQuaternion.Normalize;
 qx2:=ppvQuaternion.x+ppvQuaternion.x;
 qy2:=ppvQuaternion.y+ppvQuaternion.y;
 qz2:=ppvQuaternion.z+ppvQuaternion.z;
 qxqx2:=ppvQuaternion.x*qx2;
 qxqy2:=ppvQuaternion.x*qy2;
 qxqz2:=ppvQuaternion.x*qz2;
 qxqw2:=ppvQuaternion.w*qx2;
 qyqy2:=ppvQuaternion.y*qy2;
 qyqz2:=ppvQuaternion.y*qz2;
 qyqw2:=ppvQuaternion.w*qy2;
 qzqz2:=ppvQuaternion.z*qz2;
 qzqw2:=ppvQuaternion.w*qz2;
 RawComponents[0,0]:=1.0-(qyqy2+qzqz2);
 RawComponents[0,1]:=qxqy2+qzqw2;
 RawComponents[0,2]:=qxqz2-qyqw2;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=qxqy2-qzqw2;
 RawComponents[1,1]:=1.0-(qxqx2+qzqz2);
 RawComponents[1,2]:=qyqz2+qxqw2;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=qxqz2+qyqw2;
 RawComponents[2,1]:=qyqz2-qxqw2;
 RawComponents[2,2]:=1.0-(qxqx2+qyqy2);
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateFromQTangent(pQTangent:TpvQuaternion);
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:TpvScalar;
begin
 pQTangent:=pQTangent.Normalize;
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
 RawComponents[0,0]:=1.0-(qyqy2+qzqz2);
 RawComponents[0,1]:=qxqy2+qzqw2;
 RawComponents[0,2]:=qxqz2-qyqw2;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=qxqy2-qzqw2;
 RawComponents[1,1]:=1.0-(qxqx2+qzqz2);
 RawComponents[1,2]:=qyqz2+qxqw2;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=(RawComponents[0,1]*RawComponents[1,2])-(RawComponents[0,2]*RawComponents[1,1]);
 RawComponents[2,1]:=(RawComponents[0,2]*RawComponents[1,0])-(RawComponents[0,0]*RawComponents[1,2]);
 RawComponents[2,2]:=(RawComponents[0,0]*RawComponents[1,1])-(RawComponents[0,1]*RawComponents[1,0]);
{RawComponents[2,0]:=qxqz2+qyqw2;
 RawComponents[2,1]:=qyqz2-qxqw2;
 RawComponents[2,2]:=1.0-(qxqx2+qyqy2);}
 if pQTangent.w<0.0 then begin
  RawComponents[2,0]:=-RawComponents[2,0];
  RawComponents[2,1]:=-RawComponents[2,1];
  RawComponents[2,2]:=-RawComponents[2,2];
 end;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateReflect(const PpvPlane:TpvPlane);
var Plane:TpvPlane;
    l:TpvScalar;
begin
 Plane:=PpvPlane;
 l:=sqr(Plane.Normal.x)+sqr(Plane.Normal.y)+sqr(Plane.Normal.z);
 if l>0.0 then begin
  l:=sqrt(l);
  Plane.Normal.x:=Plane.Normal.x/l;
  Plane.Normal.y:=Plane.Normal.y/l;
  Plane.Normal.z:=Plane.Normal.z/l;
  Plane.Distance:=Plane.Distance/l;
 end else begin
  Plane.Normal.x:=0.0;
  Plane.Normal.y:=0.0;
  Plane.Normal.z:=0.0;
  Plane.Distance:=0.0;
 end;
 RawComponents[0,0]:=1.0-(2.0*(Plane.Normal.x*Plane.Normal.x));
 RawComponents[0,1]:=-(2.0*(Plane.Normal.x*Plane.Normal.y));
 RawComponents[0,2]:=-(2.0*(Plane.Normal.x*Plane.Normal.z));
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=-(2.0*(Plane.Normal.x*Plane.Normal.y));
 RawComponents[1,1]:=1.0-(2.0*(Plane.Normal.y*Plane.Normal.y));
 RawComponents[1,2]:=-(2.0*(Plane.Normal.y*Plane.Normal.z));
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=-(2.0*(Plane.Normal.z*Plane.Normal.x));
 RawComponents[2,1]:=-(2.0*(Plane.Normal.z*Plane.Normal.y));
 RawComponents[2,2]:=1.0-(2.0*(Plane.Normal.z*Plane.Normal.z));
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=-(2.0*(Plane.Distance*Plane.Normal.x));
 RawComponents[3,1]:=-(2.0*(Plane.Distance*Plane.Normal.y));
 RawComponents[3,2]:=-(2.0*(Plane.Distance*Plane.Normal.z));
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateFrustumLeftHandedNegativeOneToPositiveOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=(zNear*2.0)/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=(zNear*2.0)/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=(Right+Left)/rml;
 RawComponents[2,1]:=(Top+Bottom)/tmb;
 RawComponents[2,2]:=(zFar+zNear)/fmn;
 RawComponents[2,3]:=1.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=(-((zFar*zNear)*2.0))/fmn;
 RawComponents[3,3]:=0.0;
end;

constructor TpvMatrix4x4.CreateFrustumLeftHandedZeroToOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=(zNear*2.0)/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=(zNear*2.0)/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=(Right+Left)/rml;
 RawComponents[2,1]:=(Top+Bottom)/tmb;
 RawComponents[2,2]:=zFar/fmn;
 RawComponents[2,3]:=1.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=(-(zFar*zNear))/fmn;
 RawComponents[3,3]:=0.0;
end;

constructor TpvMatrix4x4.CreateFrustumLeftHandedOneToZero(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=(zNear*2.0)/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=(zNear*2.0)/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=(Right+Left)/rml;
 RawComponents[2,1]:=(Top+Bottom)/tmb;
 RawComponents[2,2]:=(-zNear)/fmn;
 RawComponents[2,3]:=1.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=(zFar*zNear)/fmn;
 RawComponents[3,3]:=0.0;
end;

constructor TpvMatrix4x4.CreateFrustumRightHandedNegativeOneToPositiveOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=(zNear*2.0)/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=(zNear*2.0)/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=(Right+Left)/rml;
 RawComponents[2,1]:=(Top+Bottom)/tmb;
 RawComponents[2,2]:=(-(zFar+zNear))/fmn;
 RawComponents[2,3]:=-1.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=(-((zFar*zNear)*2.0))/fmn;
 RawComponents[3,3]:=0.0;
end;

constructor TpvMatrix4x4.CreateFrustumRightHandedZeroToOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=(zNear*2.0)/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=(zNear*2.0)/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=(Right+Left)/rml;
 RawComponents[2,1]:=(Top+Bottom)/tmb;
 RawComponents[2,2]:=zFar/(zNear-zFar);
 RawComponents[2,3]:=-1.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=(-(zFar*zNear))/fmn;
 RawComponents[3,3]:=0.0;
end;

constructor TpvMatrix4x4.CreateFrustumRightHandedOneToZero(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=(zNear*2.0)/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=(zNear*2.0)/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=(Right+Left)/rml;
 RawComponents[2,1]:=(Top+Bottom)/tmb;
 RawComponents[2,2]:=zNear/fmn;
 RawComponents[2,3]:=-1.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=(zNear*zFar)/fmn;
 RawComponents[3,3]:=0.0;
end;

constructor TpvMatrix4x4.CreateFrustum(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=(zNear*2.0)/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=(zNear*2.0)/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=(Right+Left)/rml;
 RawComponents[2,1]:=(Top+Bottom)/tmb;
 RawComponents[2,2]:=(-(zFar+zNear))/fmn;
 RawComponents[2,3]:=-1.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=(-((zFar*zNear)*2.0))/fmn;
 RawComponents[3,3]:=0.0;
end;

constructor TpvMatrix4x4.CreateOrthoLeftHandedNegativeOneToPositiveOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=2.0/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=2.0/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=2.0/fmn;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=(-(Right+Left))/rml;
 RawComponents[3,1]:=(-(Top+Bottom))/tmb;
 RawComponents[3,2]:=(-(zFar+zNear))/fmn;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateOrthoLeftHandedZeroToOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=2.0/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=2.0/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0/fmn;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=(-(Right+Left))/rml;
 RawComponents[3,1]:=(-(Top+Bottom))/tmb;
 RawComponents[3,2]:=(-zNear)/fmn;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateOrthoRightHandedNegativeOneToPositiveOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=2.0/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=2.0/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=(-2.0)/fmn;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=(-(Right+Left))/rml;
 RawComponents[3,1]:=(-(Top+Bottom))/tmb;
 RawComponents[3,2]:=(-(zFar+zNear))/fmn;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateOrthoRightHandedZeroToOne(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=2.0/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=2.0/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=(-1.0)/fmn;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=(-(Right+Left))/rml;
 RawComponents[3,1]:=(-(Top+Bottom))/tmb;
 RawComponents[3,2]:=(-zNear)/fmn;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateOrtho(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=2.0/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=2.0/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=(-2.0)/fmn;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=(-(Right+Left))/rml;
 RawComponents[3,1]:=(-(Top+Bottom))/tmb;
 RawComponents[3,2]:=(-(zFar+zNear))/fmn;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateOrthoLH(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=2.0/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=2.0/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0/fmn;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0;
 RawComponents[3,1]:=0;
 RawComponents[3,2]:=(-zNear)/fmn;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateOrthoRH(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=2.0/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=2.0/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0/fmn;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0;
 RawComponents[3,1]:=0;
 RawComponents[3,2]:=zNear/fmn;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateOrthoOffCenterLH(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=2.0/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=2.0/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0/fmn;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=(Right+Left)/rml;
 RawComponents[3,1]:=(Top+Bottom)/tmb;
 RawComponents[3,2]:=zNear/fmn;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateOrthoOffCenterRH(const Left,Right,Bottom,Top,zNear,zFar:TpvScalar);
var rml,tmb,fmn:TpvScalar;
begin
 rml:=Right-Left;
 tmb:=Top-Bottom;
 fmn:=zFar-zNear;
 RawComponents[0,0]:=2.0/rml;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=2.0/tmb;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=(-2.0)/fmn;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=(-(Right+Left))/rml;
 RawComponents[3,1]:=(-(Top+Bottom))/tmb;
 RawComponents[3,2]:=(-(zFar+zNear))/fmn;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreatePerspectiveLeftHandedNegativeOneToPositiveOne(const fovy,Aspect,zNear,zFar:TpvScalar);
var Sine,Cotangent,ZDelta,Radians:TpvScalar;
begin
 Radians:=(fovy*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=TpvMatrix4x4.Identity.RawComponents;
  RawComponents[0,0]:=Cotangent/aspect;
  RawComponents[1,1]:=Cotangent;
  RawComponents[2,2]:=(-(zFar+zNear))/(zFar-zNear);
  RawComponents[2,3]:=1.0;
  RawComponents[3,2]:=(-(2.0*zNear*zFar))/(zFar-zNear);
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvMatrix4x4.CreatePerspectiveLeftHandedZeroToOne(const fovy,Aspect,zNear,zFar:TpvScalar);
var Sine,Cotangent,ZDelta,Radians:TpvScalar;
begin
 Radians:=(fovy*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=TpvMatrix4x4.Identity.RawComponents;
  RawComponents[0,0]:=Cotangent/aspect;
  RawComponents[1,1]:=Cotangent;
  RawComponents[2,2]:=zFar/(zFar-zNear);
  RawComponents[2,3]:=1.0;
  RawComponents[3,2]:=(-(zNear*zFar))/(zFar-zNear);
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvMatrix4x4.CreatePerspectiveLeftHandedOneToZero(const fovy,Aspect,zNear,zFar:TpvScalar);
var Sine,Cotangent,ZDelta,Radians:TpvScalar;
begin
 Radians:=(fovy*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=TpvMatrix4x4.Identity.RawComponents;
  RawComponents[0,0]:=Cotangent/aspect;
  RawComponents[1,1]:=Cotangent;
  RawComponents[2,2]:=(-zNear)/(zFar-zNear);
  RawComponents[2,3]:=1.0;
  RawComponents[3,2]:=(zNear*zFar)/(zFar-zNear);
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvMatrix4x4.CreatePerspectiveRightHandedNegativeOneToPositiveOne(const fovy,Aspect,zNear,zFar:TpvScalar);
var Sine,Cotangent,ZDelta,Radians:TpvScalar;
begin
 Radians:=(fovy*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=TpvMatrix4x4.Identity.RawComponents;
  RawComponents[0,0]:=Cotangent/aspect;
  RawComponents[1,1]:=Cotangent;
  RawComponents[2,2]:=(-(zFar+zNear))/(zFar-zNear);
  RawComponents[2,3]:=-1.0;
  RawComponents[3,2]:=(-(2.0*zNear*zFar))/(zFar-zNear);
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvMatrix4x4.CreatePerspectiveRightHandedZeroToOne(const fovy,Aspect,zNear,zFar:TpvScalar);
var Sine,Cotangent,ZDelta,Radians:TpvScalar;
begin
 Radians:=(fovy*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=TpvMatrix4x4.Identity.RawComponents;
  RawComponents[0,0]:=Cotangent/aspect;
  RawComponents[1,1]:=Cotangent;
  RawComponents[2,2]:=zFar/(zNear-zFar);
  RawComponents[2,3]:=-1.0;
  RawComponents[3,2]:=(-(zNear*zFar))/(zFar-zNear);
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvMatrix4x4.CreatePerspectiveRightHandedOneToZero(const fovy,Aspect,zNear,zFar:TpvScalar);
var Sine,Cotangent,ZDelta,Radians:TpvScalar;
begin
 Radians:=(fovy*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=TpvMatrix4x4.Identity.RawComponents;
  RawComponents[0,0]:=Cotangent/aspect;
  RawComponents[1,1]:=Cotangent;
  RawComponents[2,2]:=zNear/(zFar-zNear);
  RawComponents[2,3]:=-1.0;
  RawComponents[3,2]:=(zNear*zFar)/(zFar-zNear);
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvMatrix4x4.CreatePerspectiveReversedZ(const aFOVY,aAspectRatio,aZNear:TpvScalar);
var t,sx,sy:TpvScalar;
begin
 t:=tan(aFOVY*DEG2RAD*0.5);
 sy:=1.0/t;
 sx:=sy/aAspectRatio;
 RawComponents[0,0]:=sx;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=sy;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=0.0;
 RawComponents[2,3]:=-1.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=aZNear;
 RawComponents[3,3]:=0.0;
end;

constructor TpvMatrix4x4.CreatePerspective(const fovy,Aspect,zNear,zFar:TpvScalar);
var Sine,Cotangent,ZDelta,Radians:TpvScalar;
begin
 Radians:=(fovy*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=TpvMatrix4x4.Identity.RawComponents;
  RawComponents[0,0]:=Cotangent/aspect;
  RawComponents[1,1]:=Cotangent;
  RawComponents[2,2]:=(-(zFar+zNear))/ZDelta;
  RawComponents[2,3]:=-1.0;
  RawComponents[3,2]:=(-(2.0*zNear*zFar))/ZDelta;
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvMatrix4x4.CreateHorizontalFOVPerspectiveLeftHandedNegativeOneToPositiveOne(const fovx,Aspect,zNear,zFar:TpvScalar);
var Sine,Cotangent,ZDelta,Radians:TpvScalar;
begin
 Radians:=(fovx*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=TpvMatrix4x4.Identity.RawComponents;
  RawComponents[0,0]:=Cotangent;
  RawComponents[1,1]:=Cotangent*aspect;
  RawComponents[2,2]:=(-(zFar+zNear))/(zFar-zNear);
  RawComponents[2,3]:=1.0;
  RawComponents[3,2]:=(-(2.0*zNear*zFar))/(zFar-zNear);
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvMatrix4x4.CreateHorizontalFOVPerspectiveLeftHandedZeroToOne(const fovx,Aspect,zNear,zFar:TpvScalar);
var Sine,Cotangent,ZDelta,Radians:TpvScalar;
begin
 Radians:=(fovx*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=TpvMatrix4x4.Identity.RawComponents;
  RawComponents[0,0]:=Cotangent;
  RawComponents[1,1]:=Cotangent*aspect;
  RawComponents[2,2]:=zFar/(zFar-zNear);
  RawComponents[2,3]:=1.0;
  RawComponents[3,2]:=(-(zNear*zFar))/(zFar-zNear);
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvMatrix4x4.CreateHorizontalFOVPerspectiveLeftHandedOneToZero(const fovx,Aspect,zNear,zFar:TpvScalar);
var Sine,Cotangent,ZDelta,Radians:TpvScalar;
begin
 Radians:=(fovx*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=TpvMatrix4x4.Identity.RawComponents;
  RawComponents[0,0]:=Cotangent;
  RawComponents[1,1]:=Cotangent*aspect;
  RawComponents[2,2]:=(-zNear)/(zFar-zNear);
  RawComponents[2,3]:=1.0;
  RawComponents[3,2]:=(zNear*zFar)/(zFar-zNear);
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvMatrix4x4.CreateHorizontalFOVPerspectiveRightHandedNegativeOneToPositiveOne(const fovx,Aspect,zNear,zFar:TpvScalar);
var Sine,Cotangent,ZDelta,Radians:TpvScalar;
begin
 Radians:=(fovx*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=TpvMatrix4x4.Identity.RawComponents;
  RawComponents[0,0]:=Cotangent;
  RawComponents[1,1]:=Cotangent*aspect;
  RawComponents[2,2]:=(-(zFar+zNear))/(zFar-zNear);
  RawComponents[2,3]:=-1.0;
  RawComponents[3,2]:=(-(2.0*zNear*zFar))/(zFar-zNear);
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvMatrix4x4.CreateHorizontalFOVPerspectiveRightHandedZeroToOne(const fovx,Aspect,zNear,zFar:TpvScalar);
var Sine,Cotangent,ZDelta,Radians:TpvScalar;
begin
 Radians:=(fovx*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=TpvMatrix4x4.Identity.RawComponents;
  RawComponents[0,0]:=Cotangent;
  RawComponents[1,1]:=Cotangent*aspect;
  RawComponents[2,2]:=zFar/(zNear-zFar);
  RawComponents[2,3]:=-1.0;
  RawComponents[3,2]:=(-(zNear*zFar))/(zFar-zNear);
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvMatrix4x4.CreateHorizontalFOVPerspectiveRightHandedOneToZero(const fovx,Aspect,zNear,zFar:TpvScalar);
var Sine,Cotangent,ZDelta,Radians:TpvScalar;
begin
 Radians:=(fovx*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=TpvMatrix4x4.Identity.RawComponents;
  RawComponents[0,0]:=Cotangent;
  RawComponents[1,1]:=Cotangent*aspect;
  RawComponents[2,2]:=zNear/(zFar-zNear);
  RawComponents[2,3]:=-1.0;
  RawComponents[3,2]:=(zNear*zFar)/(zFar-zNear);
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvMatrix4x4.CreateHorizontalFOVPerspectiveReversedZ(const aFOVX,aAspectRatio,aZNear:TpvScalar);
var t,sx,sy:TpvScalar;
begin
 t:=tan(aFOVX*DEG2RAD*0.5);
 sx:=1.0/t;
 sy:=sx*aAspectRatio;
 RawComponents[0,0]:=sx;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=sy;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=0.0;
 RawComponents[2,3]:=-1.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=aZNear;
 RawComponents[3,3]:=0.0;
end;

constructor TpvMatrix4x4.CreateHorizontalFOVPerspective(const fovx,Aspect,zNear,zFar:TpvScalar);
var Sine,Cotangent,ZDelta,Radians:TpvScalar;
begin
 Radians:=(fovx*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=TpvMatrix4x4.Identity.RawComponents;
  RawComponents[0,0]:=Cotangent;
  RawComponents[1,1]:=Cotangent*aspect;
  RawComponents[2,2]:=(-(zFar+zNear))/ZDelta;
  RawComponents[2,3]:=-1.0;
  RawComponents[3,2]:=(-(2.0*zNear*zFar))/ZDelta;
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvMatrix4x4.CreateInverseLookAt(const Eye,Center,Up:TpvVector3);
var RightVector,UpVector,ForwardVector:TpvVector3;
begin
 ForwardVector:=(Eye-Center).Normalize;
 RightVector:=(Up.Cross(ForwardVector)).Normalize;
 UpVector:=(ForwardVector.Cross(RightVector)).Normalize;
 RawComponents[0,0]:=RightVector.x;
 RawComponents[0,1]:=RightVector.y;
 RawComponents[0,2]:=RightVector.z;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=UpVector.x;
 RawComponents[1,1]:=UpVector.y;
 RawComponents[1,2]:=UpVector.z;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=ForwardVector.x;
 RawComponents[2,1]:=ForwardVector.y;
 RawComponents[2,2]:=ForwardVector.z;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=Eye.x;
 RawComponents[3,1]:=Eye.y;
 RawComponents[3,2]:=Eye.z;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateLookAt(const Eye,Center,Up:TpvVector3);
var RightVector,UpVector,ForwardVector:TpvVector3;
begin
 ForwardVector:=(Eye-Center).Normalize;
 RightVector:=(Up.Cross(ForwardVector)).Normalize;
 UpVector:=(ForwardVector.Cross(RightVector)).Normalize;
 RawComponents[0,0]:=RightVector.x;
 RawComponents[1,0]:=RightVector.y;
 RawComponents[2,0]:=RightVector.z;
 RawComponents[3,0]:=-((RightVector.x*Eye.x)+(RightVector.y*Eye.y)+(RightVector.z*Eye.z));
 RawComponents[0,1]:=UpVector.x;
 RawComponents[1,1]:=UpVector.y;
 RawComponents[2,1]:=UpVector.z;
 RawComponents[3,1]:=-((UpVector.x*Eye.x)+(UpVector.y*Eye.y)+(UpVector.z*Eye.z));
 RawComponents[0,2]:=ForwardVector.x;
 RawComponents[1,2]:=ForwardVector.y;
 RawComponents[2,2]:=ForwardVector.z;
 RawComponents[3,2]:=-((ForwardVector.x*Eye.x)+(ForwardVector.y*Eye.y)+(ForwardVector.z*Eye.z));
 RawComponents[0,3]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateFill(const Eye,RightVector,UpVector,ForwardVector:TpvVector3);
begin
 RawComponents[0,0]:=RightVector.x;
 RawComponents[1,0]:=RightVector.y;
 RawComponents[2,0]:=RightVector.z;
 RawComponents[3,0]:=-((RightVector.x*Eye.x)+(RightVector.y*Eye.y)+(RightVector.z*Eye.z));
 RawComponents[0,1]:=UpVector.x;
 RawComponents[1,1]:=UpVector.y;
 RawComponents[2,1]:=UpVector.z;
 RawComponents[3,1]:=-((UpVector.x*Eye.x)+(UpVector.y*Eye.y)+(UpVector.z*Eye.z));
 RawComponents[0,2]:=ForwardVector.x;
 RawComponents[1,2]:=ForwardVector.y;
 RawComponents[2,2]:=ForwardVector.z;
 RawComponents[3,2]:=-((ForwardVector.x*Eye.x)+(ForwardVector.y*Eye.y)+(ForwardVector.z*Eye.z));
 RawComponents[0,3]:=0.0;
 RawComponents[1,3]:=0.0;
 RawComponents[2,3]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateConstructX(const xAxis:TpvVector3);
var a,b,c:TpvVector3;
begin
 a:=xAxis.Normalize;
 RawComponents[0,0]:=a.x;
 RawComponents[0,1]:=a.y;
 RawComponents[0,2]:=a.z;
 RawComponents[0,3]:=0.0;
//b:=TpvVector3.Create(0.0,0.0,1.0).Cross(a).Normalize;
 b:=a.Perpendicular.Normalize;
 RawComponents[1,0]:=b.x;
 RawComponents[1,1]:=b.y;
 RawComponents[1,2]:=b.z;
 RawComponents[1,3]:=0.0;
 c:=b.Cross(a).Normalize;
 RawComponents[2,0]:=c.x;
 RawComponents[2,1]:=c.y;
 RawComponents[2,2]:=c.z;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateConstructY(const yAxis:TpvVector3);
var a,b,c:TpvVector3;
begin
 a:=yAxis.Normalize;
 RawComponents[1,0]:=a.x;
 RawComponents[1,1]:=a.y;
 RawComponents[1,2]:=a.z;
 RawComponents[1,3]:=0.0;
 b:=a.Perpendicular.Normalize;
 RawComponents[0,0]:=b.x;
 RawComponents[0,1]:=b.y;
 RawComponents[0,2]:=b.z;
 RawComponents[0,3]:=0.0;
 c:=b.Cross(a).Normalize;
 RawComponents[2,0]:=c.x;
 RawComponents[2,1]:=c.y;
 RawComponents[2,2]:=c.z;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateConstructZ(const zAxis:TpvVector3);
var a,b,c:TpvVector3;
begin
 a:=zAxis.Normalize;
 RawComponents[2,0]:=a.x;
 RawComponents[2,1]:=a.y;
 RawComponents[2,2]:=a.z;
 RawComponents[2,3]:=0.0;
//b:=TpvVector3.Create(0.0,1.0,0.0).Cross(a).Normalize;
 b:=a.Perpendicular.Normalize;
 RawComponents[1,0]:=b.x;
 RawComponents[1,1]:=b.y;
 RawComponents[1,2]:=b.z;
 RawComponents[1,3]:=0.0;
 c:=b.Cross(a).Normalize;
 RawComponents[0,0]:=c.x;
 RawComponents[0,1]:=c.y;
 RawComponents[0,2]:=c.z;
 RawComponents[0,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4.CreateProjectionMatrixClip(const ProjectionMatrix:TpvMatrix4x4;const ClipPlane:TpvPlane);
var q,c:TpvVector4;
begin
 RawComponents:=ProjectionMatrix.RawComponents;
 q.x:=(Sign(ClipPlane.Normal.x)+RawComponents[2,0])/RawComponents[0,0];
 q.y:=(Sign(ClipPlane.Normal.y)+RawComponents[2,1])/RawComponents[1,1];
 q.z:=-1.0;
 q.w:=(1.0+RawComponents[2,2])/RawComponents[3,2];
 c.x:=ClipPlane.Normal.x;
 c.y:=ClipPlane.Normal.y;
 c.z:=ClipPlane.Normal.z;
 c.w:=ClipPlane.Distance;
 c:=c*(2.0/c.Dot(q));
 RawComponents[0,2]:=c.x;
 RawComponents[1,2]:=c.y;
 RawComponents[2,2]:=c.z+1.0;
 RawComponents[3,2]:=c.w;
end;

constructor TpvMatrix4x4.CreateRecomposed(const DecomposedMatrix4x4:TpvDecomposedMatrix4x4);
begin

 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=DecomposedMatrix4x4.Perspective.x;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=DecomposedMatrix4x4.Perspective.y;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=DecomposedMatrix4x4.Perspective.z;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=DecomposedMatrix4x4.Perspective.w;

//self:=TpvMatrix4x4.CreateTranslation(DecomposedMatrix4x4.Translation)*self;
 Translation:=Translation+
              (Right*DecomposedMatrix4x4.Translation.x)+
              (Up*DecomposedMatrix4x4.Translation.y)+
              (Forwards*DecomposedMatrix4x4.Translation.z);

 self:=TpvMatrix4x4.CreateFromQuaternion(DecomposedMatrix4x4.Rotation)*self;

 if DecomposedMatrix4x4.Skew.z<>0.0 then begin // YZ
  self:=TpvMatrix4x4.Create(1.0,0.0,0.0,0.0,
                            0.0,1.0,0.0,0.0,
                            0.0,DecomposedMatrix4x4.Skew.z,1.0,0.0,
                            0.0,0.0,0.0,1.0)*self;
 end;

 if DecomposedMatrix4x4.Skew.y<>0.0 then begin // XZ
  self:=TpvMatrix4x4.Create(1.0,0.0,0.0,0.0,
                            0.0,1.0,0.0,0.0,
                            DecomposedMatrix4x4.Skew.y,0.0,1.0,0.0,
                            0.0,0.0,0.0,1.0)*self;
 end;

 if DecomposedMatrix4x4.Skew.x<>0.0 then begin // XY
  self:=TpvMatrix4x4.Create(1.0,0.0,0.0,0.0,
                            DecomposedMatrix4x4.Skew.x,1.0,0.0,0.0,
                            0.0,0.0,1.0,0.0,
                            0.0,0.0,0.0,1.0)*self;
 end;

 self:=TpvMatrix4x4.CreateScale(DecomposedMatrix4x4.Scale)*self;

end;

class operator TpvMatrix4x4.Implicit({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar):TpvMatrix4x4;
begin
 result.RawComponents[0,0]:=a;
 result.RawComponents[0,1]:=a;
 result.RawComponents[0,2]:=a;
 result.RawComponents[0,3]:=a;
 result.RawComponents[1,0]:=a;
 result.RawComponents[1,1]:=a;
 result.RawComponents[1,2]:=a;
 result.RawComponents[1,3]:=a;
 result.RawComponents[2,0]:=a;
 result.RawComponents[2,1]:=a;
 result.RawComponents[2,2]:=a;
 result.RawComponents[2,3]:=a;
 result.RawComponents[3,0]:=a;
 result.RawComponents[3,1]:=a;
 result.RawComponents[3,2]:=a;
 result.RawComponents[3,3]:=a;
end;

class operator TpvMatrix4x4.Explicit({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar):TpvMatrix4x4;
begin
 result.RawComponents[0,0]:=a;
 result.RawComponents[0,1]:=a;
 result.RawComponents[0,2]:=a;
 result.RawComponents[0,3]:=a;
 result.RawComponents[1,0]:=a;
 result.RawComponents[1,1]:=a;
 result.RawComponents[1,2]:=a;
 result.RawComponents[1,3]:=a;
 result.RawComponents[2,0]:=a;
 result.RawComponents[2,1]:=a;
 result.RawComponents[2,2]:=a;
 result.RawComponents[2,3]:=a;
 result.RawComponents[3,0]:=a;
 result.RawComponents[3,1]:=a;
 result.RawComponents[3,2]:=a;
 result.RawComponents[3,3]:=a;
end;

class operator TpvMatrix4x4.Equal({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):boolean;
begin
 result:=SameValue(a.RawComponents[0,0],b.RawComponents[0,0]) and
         SameValue(a.RawComponents[0,1],b.RawComponents[0,1]) and
         SameValue(a.RawComponents[0,2],b.RawComponents[0,2]) and
         SameValue(a.RawComponents[0,3],b.RawComponents[0,3]) and
         SameValue(a.RawComponents[1,0],b.RawComponents[1,0]) and
         SameValue(a.RawComponents[1,1],b.RawComponents[1,1]) and
         SameValue(a.RawComponents[1,2],b.RawComponents[1,2]) and
         SameValue(a.RawComponents[1,3],b.RawComponents[1,3]) and
         SameValue(a.RawComponents[2,0],b.RawComponents[2,0]) and
         SameValue(a.RawComponents[2,1],b.RawComponents[2,1]) and
         SameValue(a.RawComponents[2,2],b.RawComponents[2,2]) and
         SameValue(a.RawComponents[2,3],b.RawComponents[2,3]) and
         SameValue(a.RawComponents[3,0],b.RawComponents[3,0]) and
         SameValue(a.RawComponents[3,1],b.RawComponents[3,1]) and
         SameValue(a.RawComponents[3,2],b.RawComponents[3,2]) and
         SameValue(a.RawComponents[3,3],b.RawComponents[3,3]);
end;

class operator TpvMatrix4x4.NotEqual({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):boolean;
begin
 result:=(not SameValue(a.RawComponents[0,0],b.RawComponents[0,0])) or
         (not SameValue(a.RawComponents[0,1],b.RawComponents[0,1])) or
         (not SameValue(a.RawComponents[0,2],b.RawComponents[0,2])) or
         (not SameValue(a.RawComponents[0,3],b.RawComponents[0,3])) or
         (not SameValue(a.RawComponents[1,0],b.RawComponents[1,0])) or
         (not SameValue(a.RawComponents[1,1],b.RawComponents[1,1])) or
         (not SameValue(a.RawComponents[1,2],b.RawComponents[1,2])) or
         (not SameValue(a.RawComponents[1,3],b.RawComponents[1,3])) or
         (not SameValue(a.RawComponents[2,0],b.RawComponents[2,0])) or
         (not SameValue(a.RawComponents[2,1],b.RawComponents[2,1])) or
         (not SameValue(a.RawComponents[2,2],b.RawComponents[2,2])) or
         (not SameValue(a.RawComponents[2,3],b.RawComponents[2,3])) or
         (not SameValue(a.RawComponents[3,0],b.RawComponents[3,0])) or
         (not SameValue(a.RawComponents[3,1],b.RawComponents[3,1])) or
         (not SameValue(a.RawComponents[3,2],b.RawComponents[3,2])) or
         (not SameValue(a.RawComponents[3,3],b.RawComponents[3,3]));
end;

class operator TpvMatrix4x4.Inc({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
const cOne:array[0..3] of single=(1.0,1.0,1.0,1.0);
asm
 movups xmm0,dqword ptr [a+0]
 movups xmm1,dqword ptr [a+16]
 movups xmm2,dqword ptr [a+32]
 movups xmm3,dqword ptr [a+48]
{$ifdef cpu386}
 movups xmm4,dqword ptr [cOne]
{$else}
{$ifdef fpc}
 movups xmm4,dqword ptr [rip+cOne]
{$else}
 movups xmm4,dqword ptr [rel cOne]
{$endif}
{$endif}
 addps xmm0,xmm4
 addps xmm1,xmm4
 addps xmm2,xmm4
 addps xmm3,xmm4
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3
end;
{$else}
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]+1.0;
 result.RawComponents[0,1]:=a.RawComponents[0,1]+1.0;
 result.RawComponents[0,2]:=a.RawComponents[0,2]+1.0;
 result.RawComponents[0,3]:=a.RawComponents[0,3]+1.0;
 result.RawComponents[1,0]:=a.RawComponents[1,0]+1.0;
 result.RawComponents[1,1]:=a.RawComponents[1,1]+1.0;
 result.RawComponents[1,2]:=a.RawComponents[1,2]+1.0;
 result.RawComponents[1,3]:=a.RawComponents[1,3]+1.0;
 result.RawComponents[2,0]:=a.RawComponents[2,0]+1.0;
 result.RawComponents[2,1]:=a.RawComponents[2,1]+1.0;
 result.RawComponents[2,2]:=a.RawComponents[2,2]+1.0;
 result.RawComponents[2,3]:=a.RawComponents[2,3]+1.0;
 result.RawComponents[3,0]:=a.RawComponents[3,0]+1.0;
 result.RawComponents[3,1]:=a.RawComponents[3,1]+1.0;
 result.RawComponents[3,2]:=a.RawComponents[3,2]+1.0;
 result.RawComponents[3,3]:=a.RawComponents[3,3]+1.0;
end;
{$ifend}

class operator TpvMatrix4x4.Dec({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
const cOne:array[0..3] of single=(1.0,1.0,1.0,1.0);
asm
 movups xmm0,dqword ptr [a+0]
 movups xmm1,dqword ptr [a+16]
 movups xmm2,dqword ptr [a+32]
 movups xmm3,dqword ptr [a+48]
{$ifdef cpu386}
 movups xmm4,dqword ptr [cOne]
{$else}
{$ifdef fpc}
 movups xmm4,dqword ptr [rip+cOne]
{$else}
 movups xmm4,dqword ptr [rel cOne]
{$endif}
{$endif}
 subps xmm0,xmm4
 subps xmm1,xmm4
 subps xmm2,xmm4
 subps xmm3,xmm4
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3
end;
{$else}
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]-1.0;
 result.RawComponents[0,1]:=a.RawComponents[0,1]-1.0;
 result.RawComponents[0,2]:=a.RawComponents[0,2]-1.0;
 result.RawComponents[0,3]:=a.RawComponents[0,3]-1.0;
 result.RawComponents[1,0]:=a.RawComponents[1,0]-1.0;
 result.RawComponents[1,1]:=a.RawComponents[1,1]-1.0;
 result.RawComponents[1,2]:=a.RawComponents[1,2]-1.0;
 result.RawComponents[1,3]:=a.RawComponents[1,3]-1.0;
 result.RawComponents[2,0]:=a.RawComponents[2,0]-1.0;
 result.RawComponents[2,1]:=a.RawComponents[2,1]-1.0;
 result.RawComponents[2,2]:=a.RawComponents[2,2]-1.0;
 result.RawComponents[2,3]:=a.RawComponents[2,3]-1.0;
 result.RawComponents[3,0]:=a.RawComponents[3,0]-1.0;
 result.RawComponents[3,1]:=a.RawComponents[3,1]-1.0;
 result.RawComponents[3,2]:=a.RawComponents[3,2]-1.0;
 result.RawComponents[3,3]:=a.RawComponents[3,3]-1.0;
end;
{$ifend}

class operator TpvMatrix4x4.Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}

 movups xmm0,dqword ptr [a+0]
 movups xmm1,dqword ptr [a+16]
 movups xmm2,dqword ptr [a+32]
 movups xmm3,dqword ptr [a+48]
 movups xmm4,dqword ptr [b+0]
 movups xmm5,dqword ptr [b+16]
 movups xmm6,dqword ptr [b+32]
 movups xmm7,dqword ptr [b+48]
 addps xmm0,xmm4
 addps xmm1,xmm5
 addps xmm2,xmm6
 addps xmm3,xmm7
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3

{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}

end;
{$else}
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]+b.RawComponents[0,0];
 result.RawComponents[0,1]:=a.RawComponents[0,1]+b.RawComponents[0,1];
 result.RawComponents[0,2]:=a.RawComponents[0,2]+b.RawComponents[0,2];
 result.RawComponents[0,3]:=a.RawComponents[0,3]+b.RawComponents[0,3];
 result.RawComponents[1,0]:=a.RawComponents[1,0]+b.RawComponents[1,0];
 result.RawComponents[1,1]:=a.RawComponents[1,1]+b.RawComponents[1,1];
 result.RawComponents[1,2]:=a.RawComponents[1,2]+b.RawComponents[1,2];
 result.RawComponents[1,3]:=a.RawComponents[1,3]+b.RawComponents[1,3];
 result.RawComponents[2,0]:=a.RawComponents[2,0]+b.RawComponents[2,0];
 result.RawComponents[2,1]:=a.RawComponents[2,1]+b.RawComponents[2,1];
 result.RawComponents[2,2]:=a.RawComponents[2,2]+b.RawComponents[2,2];
 result.RawComponents[2,3]:=a.RawComponents[2,3]+b.RawComponents[2,3];
 result.RawComponents[3,0]:=a.RawComponents[3,0]+b.RawComponents[3,0];
 result.RawComponents[3,1]:=a.RawComponents[3,1]+b.RawComponents[3,1];
 result.RawComponents[3,2]:=a.RawComponents[3,2]+b.RawComponents[3,2];
 result.RawComponents[3,3]:=a.RawComponents[3,3]+b.RawComponents[3,3];
end;
{$ifend}

class operator TpvMatrix4x4.Add({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvScalar):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movss xmm4,dword ptr [r8] // FreePascal: load from memory (constref)
{$else}
 movss xmm4,xmm2 // Delphi: otherwise from another xmm register
{$endif}
 movups xmm0,dqword ptr [rdx+0]
 movups xmm1,dqword ptr [rdx+16]
 movups xmm2,dqword ptr [rdx+32]
 movups xmm3,dqword ptr [rdx+48]
{$else}
 movups xmm0,dqword ptr [a+0]
 movups xmm1,dqword ptr [a+16]
 movups xmm2,dqword ptr [a+32]
 movups xmm3,dqword ptr [a+48]
 movss xmm4,dword ptr [b]
{$ifend}
 shufps xmm4,xmm4,$00
 addps xmm0,xmm4
 addps xmm1,xmm4
 addps xmm2,xmm4
 addps xmm3,xmm4
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3
end;
{$else}
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]+b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]+b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]+b;
 result.RawComponents[0,3]:=a.RawComponents[0,3]+b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]+b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]+b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]+b;
 result.RawComponents[1,3]:=a.RawComponents[1,3]+b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]+b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]+b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]+b;
 result.RawComponents[2,3]:=a.RawComponents[2,3]+b;
 result.RawComponents[3,0]:=a.RawComponents[3,0]+b;
 result.RawComponents[3,1]:=a.RawComponents[3,1]+b;
 result.RawComponents[3,2]:=a.RawComponents[3,2]+b;
 result.RawComponents[3,3]:=a.RawComponents[3,3]+b;
end;
{$ifend}

class operator TpvMatrix4x4.Add({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movss xmm0,dword ptr [rdx] // FreePascal: load from memory (constref)
{$else}
 movss xmm0,xmm1 // Delphi: otherwise from another xmm register
{$endif}
{$else}
 movss xmm0,dword ptr [a]
{$ifend}
 shufps xmm0,xmm0,$00
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 movaps xmm3,xmm0
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movups xmm4,dqword ptr [r8+0]
 movups xmm5,dqword ptr [r8+16]
 movups xmm6,dqword ptr [r8+32]
 movups xmm7,dqword ptr [r8+48]
{$else}
 movups xmm4,dqword ptr [rdx+0]
 movups xmm5,dqword ptr [rdx+16]
 movups xmm6,dqword ptr [rdx+32]
 movups xmm7,dqword ptr [rdx+48]
{$endif}
{$else}
 movups xmm4,dqword ptr [b+0]
 movups xmm5,dqword ptr [b+16]
 movups xmm6,dqword ptr [b+32]
 movups xmm7,dqword ptr [b+48]
{$ifend}
 addps xmm0,xmm4
 addps xmm1,xmm5
 addps xmm2,xmm6
 addps xmm3,xmm7
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3
{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}
end;
{$else}
begin
 result.RawComponents[0,0]:=a+b.RawComponents[0,0];
 result.RawComponents[0,1]:=a+b.RawComponents[0,1];
 result.RawComponents[0,2]:=a+b.RawComponents[0,2];
 result.RawComponents[0,3]:=a+b.RawComponents[0,3];
 result.RawComponents[1,0]:=a+b.RawComponents[1,0];
 result.RawComponents[1,1]:=a+b.RawComponents[1,1];
 result.RawComponents[1,2]:=a+b.RawComponents[1,2];
 result.RawComponents[1,3]:=a+b.RawComponents[1,3];
 result.RawComponents[2,0]:=a+b.RawComponents[2,0];
 result.RawComponents[2,1]:=a+b.RawComponents[2,1];
 result.RawComponents[2,2]:=a+b.RawComponents[2,2];
 result.RawComponents[2,3]:=a+b.RawComponents[2,3];
 result.RawComponents[3,0]:=a+b.RawComponents[3,0];
 result.RawComponents[3,1]:=a+b.RawComponents[3,1];
 result.RawComponents[3,2]:=a+b.RawComponents[3,2];
 result.RawComponents[3,3]:=a+b.RawComponents[3,3];
end;
{$ifend}

class operator TpvMatrix4x4.Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}
 movups xmm0,dqword ptr [a+0]
 movups xmm1,dqword ptr [a+16]
 movups xmm2,dqword ptr [a+32]
 movups xmm3,dqword ptr [a+48]
 movups xmm4,dqword ptr [b+0]
 movups xmm5,dqword ptr [b+16]
 movups xmm6,dqword ptr [b+32]
 movups xmm7,dqword ptr [b+48]
 subps xmm0,xmm4
 subps xmm1,xmm5
 subps xmm2,xmm6
 subps xmm3,xmm7
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3
{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}
end;
{$else}
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]-b.RawComponents[0,0];
 result.RawComponents[0,1]:=a.RawComponents[0,1]-b.RawComponents[0,1];
 result.RawComponents[0,2]:=a.RawComponents[0,2]-b.RawComponents[0,2];
 result.RawComponents[0,3]:=a.RawComponents[0,3]-b.RawComponents[0,3];
 result.RawComponents[1,0]:=a.RawComponents[1,0]-b.RawComponents[1,0];
 result.RawComponents[1,1]:=a.RawComponents[1,1]-b.RawComponents[1,1];
 result.RawComponents[1,2]:=a.RawComponents[1,2]-b.RawComponents[1,2];
 result.RawComponents[1,3]:=a.RawComponents[1,3]-b.RawComponents[1,3];
 result.RawComponents[2,0]:=a.RawComponents[2,0]-b.RawComponents[2,0];
 result.RawComponents[2,1]:=a.RawComponents[2,1]-b.RawComponents[2,1];
 result.RawComponents[2,2]:=a.RawComponents[2,2]-b.RawComponents[2,2];
 result.RawComponents[2,3]:=a.RawComponents[2,3]-b.RawComponents[2,3];
 result.RawComponents[3,0]:=a.RawComponents[3,0]-b.RawComponents[3,0];
 result.RawComponents[3,1]:=a.RawComponents[3,1]-b.RawComponents[3,1];
 result.RawComponents[3,2]:=a.RawComponents[3,2]-b.RawComponents[3,2];
 result.RawComponents[3,3]:=a.RawComponents[3,3]-b.RawComponents[3,3];
end;
{$ifend}

class operator TpvMatrix4x4.Subtract({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvScalar):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movss xmm4,dword ptr [r8] // FreePascal: load from memory (constref)
{$else}
 movss xmm4,xmm2 // Delphi: otherwise from another xmm register
{$endif}
 movups xmm0,dqword ptr [rdx+0]
 movups xmm1,dqword ptr [rdx+16]
 movups xmm2,dqword ptr [rdx+32]
 movups xmm3,dqword ptr [rdx+48]
{$else}
 movups xmm0,dqword ptr [a+0]
 movups xmm1,dqword ptr [a+16]
 movups xmm2,dqword ptr [a+32]
 movups xmm3,dqword ptr [a+48]
 movss xmm4,dword ptr [b]
{$ifend}
 shufps xmm4,xmm4,$00
 subps xmm0,xmm4
 subps xmm1,xmm4
 subps xmm2,xmm4
 subps xmm3,xmm4
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3
end;
{$else}
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]-b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]-b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]-b;
 result.RawComponents[0,3]:=a.RawComponents[0,3]-b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]-b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]-b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]-b;
 result.RawComponents[1,3]:=a.RawComponents[1,3]-b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]-b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]-b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]-b;
 result.RawComponents[2,3]:=a.RawComponents[2,3]-b;
 result.RawComponents[3,0]:=a.RawComponents[3,0]-b;
 result.RawComponents[3,1]:=a.RawComponents[3,1]-b;
 result.RawComponents[3,2]:=a.RawComponents[3,2]-b;
 result.RawComponents[3,3]:=a.RawComponents[3,3]-b;
end;
{$ifend}

class operator TpvMatrix4x4.Subtract({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4): TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movss xmm0,dword ptr [rdx] // FreePascal: load from memory (constref)
{$else}
 movss xmm0,xmm1 // Delphi: otherwise from another xmm register
{$endif}
{$else}
 movss xmm0,dword ptr [a]
{$ifend}
 shufps xmm0,xmm0,$00
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 movaps xmm3,xmm0
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movups xmm4,dqword ptr [r8+0]
 movups xmm5,dqword ptr [r8+16]
 movups xmm6,dqword ptr [r8+32]
 movups xmm7,dqword ptr [r8+48]
{$else}
 movups xmm4,dqword ptr [rdx+0]
 movups xmm5,dqword ptr [rdx+16]
 movups xmm6,dqword ptr [rdx+32]
 movups xmm7,dqword ptr [rdx+48]
{$endif}
{$else}
 movups xmm4,dqword ptr [b+0]
 movups xmm5,dqword ptr [b+16]
 movups xmm6,dqword ptr [b+32]
 movups xmm7,dqword ptr [b+48]
{$ifend}
 subps xmm0,xmm4
 subps xmm1,xmm5
 subps xmm2,xmm6
 subps xmm3,xmm7
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3
{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}
end;
{$else}
begin
 result.RawComponents[0,0]:=a-b.RawComponents[0,0];
 result.RawComponents[0,1]:=a-b.RawComponents[0,1];
 result.RawComponents[0,2]:=a-b.RawComponents[0,2];
 result.RawComponents[0,3]:=a-b.RawComponents[0,3];
 result.RawComponents[1,0]:=a-b.RawComponents[1,0];
 result.RawComponents[1,1]:=a-b.RawComponents[1,1];
 result.RawComponents[1,2]:=a-b.RawComponents[1,2];
 result.RawComponents[1,3]:=a-b.RawComponents[1,3];
 result.RawComponents[2,0]:=a-b.RawComponents[2,0];
 result.RawComponents[2,1]:=a-b.RawComponents[2,1];
 result.RawComponents[2,2]:=a-b.RawComponents[2,2];
 result.RawComponents[2,3]:=a-b.RawComponents[2,3];
 result.RawComponents[3,0]:=a-b.RawComponents[3,0];
 result.RawComponents[3,1]:=a-b.RawComponents[3,1];
 result.RawComponents[3,2]:=a-b.RawComponents[3,2];
 result.RawComponents[3,3]:=a-b.RawComponents[3,3];
end;
{$ifend}

class operator TpvMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}

{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [r8+0]
 movups xmm1,dqword ptr [r8+16]
 movups xmm2,dqword ptr [r8+32]
 movups xmm3,dqword ptr [r8+48]

 movups xmm7,dqword ptr [rdx+0]
{$else}
 movups xmm0,dqword ptr [b+0]
 movups xmm1,dqword ptr [b+16]
 movups xmm2,dqword ptr [b+32]
 movups xmm3,dqword ptr [b+48]

 movups xmm7,dqword ptr [a+0]
{$ifend}
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

{$if defined(ExplicitX64SIMDRegs)}
 movups xmm7,dqword ptr [rdx+16]
{$else}
 movups xmm7,dqword ptr [a+16]
{$ifend}
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

{$if defined(ExplicitX64SIMDRegs)}
 movups xmm7,dqword ptr [rdx+32]
{$else}
 movups xmm7,dqword ptr [a+32]
{$ifend}
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

{$if defined(ExplicitX64SIMDRegs)}
 movups xmm7,dqword ptr [rdx+48]
{$else}
 movups xmm7,dqword ptr [a+48]
{$ifend}
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

{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}

end;
{$else}
begin
 result.RawComponents[0,0]:=(a.RawComponents[0,0]*b.RawComponents[0,0])+(a.RawComponents[0,1]*b.RawComponents[1,0])+(a.RawComponents[0,2]*b.RawComponents[2,0])+(a.RawComponents[0,3]*b.RawComponents[3,0]);
 result.RawComponents[0,1]:=(a.RawComponents[0,0]*b.RawComponents[0,1])+(a.RawComponents[0,1]*b.RawComponents[1,1])+(a.RawComponents[0,2]*b.RawComponents[2,1])+(a.RawComponents[0,3]*b.RawComponents[3,1]);
 result.RawComponents[0,2]:=(a.RawComponents[0,0]*b.RawComponents[0,2])+(a.RawComponents[0,1]*b.RawComponents[1,2])+(a.RawComponents[0,2]*b.RawComponents[2,2])+(a.RawComponents[0,3]*b.RawComponents[3,2]);
 result.RawComponents[0,3]:=(a.RawComponents[0,0]*b.RawComponents[0,3])+(a.RawComponents[0,1]*b.RawComponents[1,3])+(a.RawComponents[0,2]*b.RawComponents[2,3])+(a.RawComponents[0,3]*b.RawComponents[3,3]);
 result.RawComponents[1,0]:=(a.RawComponents[1,0]*b.RawComponents[0,0])+(a.RawComponents[1,1]*b.RawComponents[1,0])+(a.RawComponents[1,2]*b.RawComponents[2,0])+(a.RawComponents[1,3]*b.RawComponents[3,0]);
 result.RawComponents[1,1]:=(a.RawComponents[1,0]*b.RawComponents[0,1])+(a.RawComponents[1,1]*b.RawComponents[1,1])+(a.RawComponents[1,2]*b.RawComponents[2,1])+(a.RawComponents[1,3]*b.RawComponents[3,1]);
 result.RawComponents[1,2]:=(a.RawComponents[1,0]*b.RawComponents[0,2])+(a.RawComponents[1,1]*b.RawComponents[1,2])+(a.RawComponents[1,2]*b.RawComponents[2,2])+(a.RawComponents[1,3]*b.RawComponents[3,2]);
 result.RawComponents[1,3]:=(a.RawComponents[1,0]*b.RawComponents[0,3])+(a.RawComponents[1,1]*b.RawComponents[1,3])+(a.RawComponents[1,2]*b.RawComponents[2,3])+(a.RawComponents[1,3]*b.RawComponents[3,3]);
 result.RawComponents[2,0]:=(a.RawComponents[2,0]*b.RawComponents[0,0])+(a.RawComponents[2,1]*b.RawComponents[1,0])+(a.RawComponents[2,2]*b.RawComponents[2,0])+(a.RawComponents[2,3]*b.RawComponents[3,0]);
 result.RawComponents[2,1]:=(a.RawComponents[2,0]*b.RawComponents[0,1])+(a.RawComponents[2,1]*b.RawComponents[1,1])+(a.RawComponents[2,2]*b.RawComponents[2,1])+(a.RawComponents[2,3]*b.RawComponents[3,1]);
 result.RawComponents[2,2]:=(a.RawComponents[2,0]*b.RawComponents[0,2])+(a.RawComponents[2,1]*b.RawComponents[1,2])+(a.RawComponents[2,2]*b.RawComponents[2,2])+(a.RawComponents[2,3]*b.RawComponents[3,2]);
 result.RawComponents[2,3]:=(a.RawComponents[2,0]*b.RawComponents[0,3])+(a.RawComponents[2,1]*b.RawComponents[1,3])+(a.RawComponents[2,2]*b.RawComponents[2,3])+(a.RawComponents[2,3]*b.RawComponents[3,3]);
 result.RawComponents[3,0]:=(a.RawComponents[3,0]*b.RawComponents[0,0])+(a.RawComponents[3,1]*b.RawComponents[1,0])+(a.RawComponents[3,2]*b.RawComponents[2,0])+(a.RawComponents[3,3]*b.RawComponents[3,0]);
 result.RawComponents[3,1]:=(a.RawComponents[3,0]*b.RawComponents[0,1])+(a.RawComponents[3,1]*b.RawComponents[1,1])+(a.RawComponents[3,2]*b.RawComponents[2,1])+(a.RawComponents[3,3]*b.RawComponents[3,1]);
 result.RawComponents[3,2]:=(a.RawComponents[3,0]*b.RawComponents[0,2])+(a.RawComponents[3,1]*b.RawComponents[1,2])+(a.RawComponents[3,2]*b.RawComponents[2,2])+(a.RawComponents[3,3]*b.RawComponents[3,2]);
 result.RawComponents[3,3]:=(a.RawComponents[3,0]*b.RawComponents[0,3])+(a.RawComponents[3,1]*b.RawComponents[1,3])+(a.RawComponents[3,2]*b.RawComponents[2,3])+(a.RawComponents[3,3]*b.RawComponents[3,3]);
end;
{$ifend}

class operator TpvMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvScalar):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movss xmm4,dword ptr [r8] // FreePascal: load from memory (constref)
{$else}
 movss xmm4,xmm2 // Delphi: otherwise from another xmm register
{$endif}
 movups xmm0,dqword ptr [rdx+0]
 movups xmm1,dqword ptr [rdx+16]
 movups xmm2,dqword ptr [rdx+32]
 movups xmm3,dqword ptr [rdx+48]
{$else}
 movups xmm0,dqword ptr [a+0]
 movups xmm1,dqword ptr [a+16]
 movups xmm2,dqword ptr [a+32]
 movups xmm3,dqword ptr [a+48]
 movss xmm4,dword ptr [b]
{$ifend}
 shufps xmm4,xmm4,$00
 mulps xmm0,xmm4
 mulps xmm1,xmm4
 mulps xmm2,xmm4
 mulps xmm3,xmm4
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3
end;
{$else}
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]*b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]*b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]*b;
 result.RawComponents[0,3]:=a.RawComponents[0,3]*b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]*b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]*b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]*b;
 result.RawComponents[1,3]:=a.RawComponents[1,3]*b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]*b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]*b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]*b;
 result.RawComponents[2,3]:=a.RawComponents[2,3]*b;
 result.RawComponents[3,0]:=a.RawComponents[3,0]*b;
 result.RawComponents[3,1]:=a.RawComponents[3,1]*b;
 result.RawComponents[3,2]:=a.RawComponents[3,2]*b;
 result.RawComponents[3,3]:=a.RawComponents[3,3]*b;
end;
{$ifend}

class operator TpvMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movss xmm0,dword ptr [rdx] // FreePascal: load from memory (constref)
{$else}
 movss xmm0,xmm1 // Delphi: otherwise from another xmm register
{$endif}
{$else}
 movss xmm0,dword ptr [a]
{$ifend}
 shufps xmm0,xmm0,$00
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 movaps xmm3,xmm0
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movups xmm4,dqword ptr [r8+0]
 movups xmm5,dqword ptr [r8+16]
 movups xmm6,dqword ptr [r8+32]
 movups xmm7,dqword ptr [r8+48]
{$else}
 movups xmm4,dqword ptr [rdx+0]
 movups xmm5,dqword ptr [rdx+16]
 movups xmm6,dqword ptr [rdx+32]
 movups xmm7,dqword ptr [rdx+48]
{$endif}
{$else}
 movups xmm4,dqword ptr [b+0]
 movups xmm5,dqword ptr [b+16]
 movups xmm6,dqword ptr [b+32]
 movups xmm7,dqword ptr [b+48]
{$ifend}
 mulps xmm0,xmm4
 mulps xmm1,xmm5
 mulps xmm2,xmm6
 mulps xmm3,xmm7
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3
{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}
end;
{$else}
begin
 result.RawComponents[0,0]:=a*b.RawComponents[0,0];
 result.RawComponents[0,1]:=a*b.RawComponents[0,1];
 result.RawComponents[0,2]:=a*b.RawComponents[0,2];
 result.RawComponents[0,3]:=a*b.RawComponents[0,3];
 result.RawComponents[1,0]:=a*b.RawComponents[1,0];
 result.RawComponents[1,1]:=a*b.RawComponents[1,1];
 result.RawComponents[1,2]:=a*b.RawComponents[1,2];
 result.RawComponents[1,3]:=a*b.RawComponents[1,3];
 result.RawComponents[2,0]:=a*b.RawComponents[2,0];
 result.RawComponents[2,1]:=a*b.RawComponents[2,1];
 result.RawComponents[2,2]:=a*b.RawComponents[2,2];
 result.RawComponents[2,3]:=a*b.RawComponents[2,3];
 result.RawComponents[3,0]:=a*b.RawComponents[3,0];
 result.RawComponents[3,1]:=a*b.RawComponents[3,1];
 result.RawComponents[3,2]:=a*b.RawComponents[3,2];
 result.RawComponents[3,3]:=a*b.RawComponents[3,3];
end;
{$ifend}

class operator TpvMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvVector2):TpvVector2;
begin
 result.x:=(a.RawComponents[0,0]*b.x)+(a.RawComponents[1,0]*b.y)+a.RawComponents[3,0];
 result.y:=(a.RawComponents[0,1]*b.x)+(a.RawComponents[1,1]*b.y)+a.RawComponents[3,1];
end;

class operator TpvMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvVector2;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvVector2;
begin
 result.x:=(a.x*b.RawComponents[0,0])+(a.y*b.RawComponents[0,1])+b.RawComponents[0,3];
 result.y:=(a.x*b.RawComponents[1,0])+(a.y*b.RawComponents[1,1])+b.RawComponents[1,3];
end;

class operator TpvMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvVector3):TpvVector3;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
const Mask:array[0..3] of TpvUInt32=($ffffffff,$ffffffff,$ffffffff,$00000000);
      cOne:array[0..3] of TpvScalar=(0.0,0.0,0.0,1.0);
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}
 xorps xmm2,xmm2
{$if defined(ExplicitX64SIMDRegs)}
 movss xmm0,dword ptr [r8+0]
 movss xmm1,dword ptr [r8+4]
 movss xmm2,dword ptr [r8+8]
{$else}
 movss xmm0,dword ptr [b+0]
 movss xmm1,dword ptr [b+4]
 movss xmm2,dword ptr [b+8]
{$ifend}
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
//movups xmm0,dqword ptr [b]     // d c b a
{$ifdef cpu386}
 movups xmm1,dqword ptr [Mask]
 movups xmm2,dqword ptr [cOne]
{$else}
{$ifdef fpc}
 movups xmm1,dqword ptr [rip+Mask]
 movups xmm2,dqword ptr [rip+cOne]
{$else}
 movups xmm1,dqword ptr [rel Mask]
 movups xmm2,dqword ptr [rel cOne]
{$endif}
{$endif}
 andps xmm0,xmm1
 addps xmm0,xmm2
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 movaps xmm3,xmm0               // d c b a
 shufps xmm0,xmm0,$00           // a a a a 00000000b
 shufps xmm1,xmm1,$55           // b b b b 01010101b
 shufps xmm2,xmm2,$aa           // c c c c 10101010b
 shufps xmm3,xmm3,$ff           // d d d d 11111111b
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm4,dqword ptr [rdx+0]
 movups xmm5,dqword ptr [rdx+16]
 movups xmm6,dqword ptr [rdx+32]
 movups xmm7,dqword ptr [rdx+48]
{$else}
 movups xmm4,dqword ptr [a+0]
 movups xmm5,dqword ptr [a+16]
 movups xmm6,dqword ptr [a+32]
 movups xmm7,dqword ptr [a+48]
{$ifend}
 mulps xmm0,xmm4
 mulps xmm1,xmm5
 mulps xmm2,xmm6
 mulps xmm3,xmm7
 addps xmm0,xmm1
 addps xmm2,xmm3
 addps xmm0,xmm2
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
//movups dqword ptr [result],xmm0
{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}
end;
{$else}
begin
 result.x:=(a.RawComponents[0,0]*b.x)+(a.RawComponents[1,0]*b.y)+(a.RawComponents[2,0]*b.z)+a.RawComponents[3,0];
 result.y:=(a.RawComponents[0,1]*b.x)+(a.RawComponents[1,1]*b.y)+(a.RawComponents[2,1]*b.z)+a.RawComponents[3,1];
 result.z:=(a.RawComponents[0,2]*b.x)+(a.RawComponents[1,2]*b.y)+(a.RawComponents[2,2]*b.z)+a.RawComponents[3,2];
end;
{$ifend}

class operator TpvMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvVector3;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
const Mask:array[0..3] of TpvUInt32=($ffffffff,$ffffffff,$ffffffff,$00000000);
      cOne:array[0..3] of TpvScalar=(0.0,0.0,0.0,1.0);
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}
 xorps xmm2,xmm2
{$if defined(ExplicitX64SIMDRegs)}
 movss xmm0,dword ptr [rdx+0]
 movss xmm1,dword ptr [rdx+4]
 movss xmm2,dword ptr [rdx+8]
{$else}
 movss xmm0,dword ptr [a+0]
 movss xmm1,dword ptr [a+4]
 movss xmm2,dword ptr [a+8]
{$ifend}
 movlhps xmm0,xmm1
 shufps xmm0,xmm2,$88
//movups xmm0,dqword ptr [a]     // d c b a
{$ifdef cpu386}
 movups xmm1,dqword ptr [Mask]
 movups xmm2,dqword ptr [cOne]
{$else}
{$ifdef fpc}
 movups xmm1,dqword ptr [rip+Mask]
 movups xmm2,dqword ptr [rip+cOne]
{$else}
 movups xmm1,dqword ptr [rel Mask]
 movups xmm2,dqword ptr [rel cOne]
{$endif}
{$endif}
 andps xmm0,xmm1
 addps xmm0,xmm2
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 movaps xmm3,xmm0               // d c b a
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm4,dqword ptr [r8+0]
 movups xmm5,dqword ptr [r8+16]
 movups xmm6,dqword ptr [r8+32]
 movups xmm7,dqword ptr [r8+48]
{$else}
 movups xmm4,dqword ptr [b+0]
 movups xmm5,dqword ptr [b+16]
 movups xmm6,dqword ptr [b+32]
 movups xmm7,dqword ptr [b+48]
{$ifend}
 mulps xmm0,xmm4
 mulps xmm1,xmm5
 mulps xmm2,xmm6
 mulps xmm3,xmm7
 addps xmm0,xmm1
 addps xmm2,xmm3
 addps xmm0,xmm2
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 shufps xmm1,xmm1,$55
 shufps xmm2,xmm2,$aa
 movss dword ptr [result+0],xmm0
 movss dword ptr [result+4],xmm1
 movss dword ptr [result+8],xmm2
//movups dqword ptr [result],xmm0
{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}
end;
{$else}
begin
 result.x:=(a.x*b.RawComponents[0,0])+(a.y*b.RawComponents[0,1])+(a.z*b.RawComponents[0,2])+b.RawComponents[0,3];
 result.y:=(a.x*b.RawComponents[1,0])+(a.y*b.RawComponents[1,1])+(a.z*b.RawComponents[1,2])+b.RawComponents[1,3];
 result.z:=(a.x*b.RawComponents[2,0])+(a.y*b.RawComponents[2,1])+(a.z*b.RawComponents[2,2])+b.RawComponents[2,3];
end;
{$ifend}

class operator TpvMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvVector4):TpvVector4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [r8]   // d c b a
{$else}
 movups xmm0,dqword ptr [b]     // d c b a
{$ifend}
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 movaps xmm3,xmm0               // d c b a
 shufps xmm0,xmm0,$00           // a a a a 00000000b
 shufps xmm1,xmm1,$55           // b b b b 01010101b
 shufps xmm2,xmm2,$aa           // c c c c 10101010b
 shufps xmm3,xmm3,$ff           // d d d d 11111111b
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm4,dqword ptr [rdx+0]
 movups xmm5,dqword ptr [rdx+16]
 movups xmm6,dqword ptr [rdx+32]
 movups xmm7,dqword ptr [rdx+48]
{$else}
 movups xmm4,dqword ptr [a+0]
 movups xmm5,dqword ptr [a+16]
 movups xmm6,dqword ptr [a+32]
 movups xmm7,dqword ptr [a+48]
{$ifend}
 mulps xmm0,xmm4
 mulps xmm1,xmm5
 mulps xmm2,xmm6
 mulps xmm3,xmm7
 addps xmm0,xmm1
 addps xmm2,xmm3
 addps xmm0,xmm2
 movups dqword ptr [result],xmm0
{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}
end;
{$else}
begin
 result.x:=(a.RawComponents[0,0]*b.x)+(a.RawComponents[1,0]*b.y)+(a.RawComponents[2,0]*b.z)+(a.RawComponents[3,0]*b.w);
 result.y:=(a.RawComponents[0,1]*b.x)+(a.RawComponents[1,1]*b.y)+(a.RawComponents[2,1]*b.z)+(a.RawComponents[3,1]*b.w);
 result.z:=(a.RawComponents[0,2]*b.x)+(a.RawComponents[1,2]*b.y)+(a.RawComponents[2,2]*b.z)+(a.RawComponents[3,2]*b.w);
 result.w:=(a.RawComponents[0,3]*b.x)+(a.RawComponents[1,3]*b.y)+(a.RawComponents[2,3]*b.z)+(a.RawComponents[3,3]*b.w);
end;
{$ifend}

class operator TpvMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvVector4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm0,dqword ptr [rdx]   // d c b a
{$else}
 movups xmm0,dqword ptr [a]     // d c b a
{$ifend}
 movaps xmm1,xmm0               // d c b a
 movaps xmm2,xmm0               // d c b a
 movaps xmm3,xmm0               // d c b a
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm4,dqword ptr [r8+0]
 movups xmm5,dqword ptr [r8+16]
 movups xmm6,dqword ptr [r8+32]
 movups xmm7,dqword ptr [r8+48]
{$else}
 movups xmm4,dqword ptr [b+0]
 movups xmm5,dqword ptr [b+16]
 movups xmm6,dqword ptr [b+32]
 movups xmm7,dqword ptr [b+48]
{$ifend}
 mulps xmm0,xmm4
 mulps xmm1,xmm5
 mulps xmm2,xmm6
 mulps xmm3,xmm7
 addps xmm0,xmm1
 addps xmm2,xmm3
 addps xmm0,xmm2
 movups dqword ptr [result],xmm0
{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}
end;
{$else}
begin
 result.x:=(a.x*b.RawComponents[0,0])+(a.y*b.RawComponents[0,1])+(a.z*b.RawComponents[0,2])+(a.w*b.RawComponents[0,3]);
 result.y:=(a.x*b.RawComponents[1,0])+(a.y*b.RawComponents[1,1])+(a.z*b.RawComponents[1,2])+(a.w*b.RawComponents[1,3]);
 result.z:=(a.x*b.RawComponents[2,0])+(a.y*b.RawComponents[2,1])+(a.z*b.RawComponents[2,2])+(a.w*b.RawComponents[2,3]);
 result.w:=(a.x*b.RawComponents[3,0])+(a.y*b.RawComponents[3,1])+(a.z*b.RawComponents[3,2])+(a.w*b.RawComponents[3,3]);
end;
{$ifend}

class operator TpvMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvPlane):TpvPlane;
begin
 result.Normal:=a.Inverse.Transpose.MulBasis(b.Normal);
 result.Distance:=result.Normal.Dot(a*((b.Normal*b.Distance)));
end;

class operator TpvMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvPlane;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvPlane;
begin
 result:=b.Transpose*a;
end;

class operator TpvMatrix4x4.Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):TpvMatrix4x4;
begin
 result:=a*b.Inverse;
end;

class operator TpvMatrix4x4.Divide({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvScalar):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movss xmm4,dword ptr [r8] // FreePascal: load from memory (constref)
{$else}
 movss xmm4,xmm2 // Delphi: otherwise from another xmm register
{$endif}
 movups xmm0,dqword ptr [rdx+0]
 movups xmm1,dqword ptr [rdx+16]
 movups xmm2,dqword ptr [rdx+32]
 movups xmm3,dqword ptr [rdx+48]
{$else}
 movups xmm0,dqword ptr [a+0]
 movups xmm1,dqword ptr [a+16]
 movups xmm2,dqword ptr [a+32]
 movups xmm3,dqword ptr [a+48]
 movss xmm4,dword ptr [b]
{$ifend}
 shufps xmm4,xmm4,$00
 divps xmm0,xmm4
 divps xmm1,xmm4
 divps xmm2,xmm4
 divps xmm3,xmm4
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3
end;
{$else}
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]/b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]/b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]/b;
 result.RawComponents[0,3]:=a.RawComponents[0,3]/b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]/b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]/b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]/b;
 result.RawComponents[1,3]:=a.RawComponents[1,3]/b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]/b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]/b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]/b;
 result.RawComponents[2,3]:=a.RawComponents[2,3]/b;
 result.RawComponents[3,0]:=a.RawComponents[3,0]/b;
 result.RawComponents[3,1]:=a.RawComponents[3,1]/b;
 result.RawComponents[3,2]:=a.RawComponents[3,2]/b;
 result.RawComponents[3,3]:=a.RawComponents[3,3]/b;
end;
{$ifend}

class operator TpvMatrix4x4.Divide({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movss xmm0,dword ptr [rdx] // FreePascal: load from memory (constref)
{$else}
 movss xmm0,xmm1 // Delphi: otherwise from another xmm register
{$endif}
{$else}
 movss xmm0,dword ptr [a]
{$ifend}
 shufps xmm0,xmm0,$00
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 movaps xmm3,xmm0
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movups xmm4,dqword ptr [r8+0]
 movups xmm5,dqword ptr [r8+16]
 movups xmm6,dqword ptr [r8+32]
 movups xmm7,dqword ptr [r8+48]
{$else}
 movups xmm4,dqword ptr [rdx+0]
 movups xmm5,dqword ptr [rdx+16]
 movups xmm6,dqword ptr [rdx+32]
 movups xmm7,dqword ptr [rdx+48]
{$endif}
{$else}
 movups xmm4,dqword ptr [b+0]
 movups xmm5,dqword ptr [b+16]
 movups xmm6,dqword ptr [b+32]
 movups xmm7,dqword ptr [b+48]
{$ifend}
 divps xmm0,xmm4
 divps xmm1,xmm5
 divps xmm2,xmm6
 divps xmm3,xmm7
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3
{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}
end;
{$else}
begin
 result.RawComponents[0,0]:=a/b.RawComponents[0,0];
 result.RawComponents[0,1]:=a/b.RawComponents[0,1];
 result.RawComponents[0,2]:=a/b.RawComponents[0,2];
 result.RawComponents[0,3]:=a/b.RawComponents[0,3];
 result.RawComponents[1,0]:=a/b.RawComponents[1,0];
 result.RawComponents[1,1]:=a/b.RawComponents[1,1];
 result.RawComponents[1,2]:=a/b.RawComponents[1,2];
 result.RawComponents[1,3]:=a/b.RawComponents[1,3];
 result.RawComponents[2,0]:=a/b.RawComponents[2,0];
 result.RawComponents[2,1]:=a/b.RawComponents[2,1];
 result.RawComponents[2,2]:=a/b.RawComponents[2,2];
 result.RawComponents[2,3]:=a/b.RawComponents[2,3];
 result.RawComponents[3,0]:=a/b.RawComponents[3,0];
 result.RawComponents[3,1]:=a/b.RawComponents[3,1];
 result.RawComponents[3,2]:=a/b.RawComponents[3,2];
 result.RawComponents[3,3]:=a/b.RawComponents[3,3];
end;
{$ifend}

class operator TpvMatrix4x4.IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):TpvMatrix4x4;
begin
 result:=a*b.Inverse;
end;

class operator TpvMatrix4x4.IntDivide({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvScalar):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
asm
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movss xmm4,dword ptr [r8] // FreePascal: load from memory (constref)
{$else}
 movss xmm4,xmm2 // Delphi: otherwise from another xmm register
{$endif}
 movups xmm0,dqword ptr [rdx+0]
 movups xmm1,dqword ptr [rdx+16]
 movups xmm2,dqword ptr [rdx+32]
 movups xmm3,dqword ptr [rdx+48]
{$else}
 movups xmm0,dqword ptr [a+0]
 movups xmm1,dqword ptr [a+16]
 movups xmm2,dqword ptr [a+32]
 movups xmm3,dqword ptr [a+48]
 movss xmm4,dword ptr [b]
{$ifend}
 shufps xmm4,xmm4,$00
 divps xmm0,xmm4
 divps xmm1,xmm4
 divps xmm2,xmm4
 divps xmm3,xmm4
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3
end;
{$else}
begin
 result.RawComponents[0,0]:=a.RawComponents[0,0]/b;
 result.RawComponents[0,1]:=a.RawComponents[0,1]/b;
 result.RawComponents[0,2]:=a.RawComponents[0,2]/b;
 result.RawComponents[0,3]:=a.RawComponents[0,3]/b;
 result.RawComponents[1,0]:=a.RawComponents[1,0]/b;
 result.RawComponents[1,1]:=a.RawComponents[1,1]/b;
 result.RawComponents[1,2]:=a.RawComponents[1,2]/b;
 result.RawComponents[1,3]:=a.RawComponents[1,3]/b;
 result.RawComponents[2,0]:=a.RawComponents[2,0]/b;
 result.RawComponents[2,1]:=a.RawComponents[2,1]/b;
 result.RawComponents[2,2]:=a.RawComponents[2,2]/b;
 result.RawComponents[2,3]:=a.RawComponents[2,3]/b;
 result.RawComponents[3,0]:=a.RawComponents[3,0]/b;
 result.RawComponents[3,1]:=a.RawComponents[3,1]/b;
 result.RawComponents[3,2]:=a.RawComponents[3,2]/b;
 result.RawComponents[3,3]:=a.RawComponents[3,3]/b;
end;
{$ifend}

class operator TpvMatrix4x4.IntDivide({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movss xmm0,dword ptr [rdx] // FreePascal: load from memory (constref)
{$else}
 movss xmm0,xmm1 // Delphi: otherwise from another xmm register
{$endif}
{$else}
 movss xmm0,dword ptr [a]
{$ifend}
 shufps xmm0,xmm0,$00
 movaps xmm1,xmm0
 movaps xmm2,xmm0
 movaps xmm3,xmm0
{$if defined(ExplicitX64SIMDRegs)}
{$ifdef fpc}
 movups xmm4,dqword ptr [r8+0]
 movups xmm5,dqword ptr [r8+16]
 movups xmm6,dqword ptr [r8+32]
 movups xmm7,dqword ptr [r8+48]
{$else}
 movups xmm4,dqword ptr [rdx+0]
 movups xmm5,dqword ptr [rdx+16]
 movups xmm6,dqword ptr [rdx+32]
 movups xmm7,dqword ptr [rdx+48]
{$endif}
{$else}
 movups xmm4,dqword ptr [b+0]
 movups xmm5,dqword ptr [b+16]
 movups xmm6,dqword ptr [b+32]
 movups xmm7,dqword ptr [b+48]
{$ifend}
 divps xmm0,xmm4
 divps xmm1,xmm5
 divps xmm2,xmm6
 divps xmm3,xmm7
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3
{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}
end;
{$else}
begin
 result.RawComponents[0,0]:=a/b.RawComponents[0,0];
 result.RawComponents[0,1]:=a/b.RawComponents[0,1];
 result.RawComponents[0,2]:=a/b.RawComponents[0,2];
 result.RawComponents[0,3]:=a/b.RawComponents[0,3];
 result.RawComponents[1,0]:=a/b.RawComponents[1,0];
 result.RawComponents[1,1]:=a/b.RawComponents[1,1];
 result.RawComponents[1,2]:=a/b.RawComponents[1,2];
 result.RawComponents[1,3]:=a/b.RawComponents[1,3];
 result.RawComponents[2,0]:=a/b.RawComponents[2,0];
 result.RawComponents[2,1]:=a/b.RawComponents[2,1];
 result.RawComponents[2,2]:=a/b.RawComponents[2,2];
 result.RawComponents[2,3]:=a/b.RawComponents[2,3];
 result.RawComponents[3,0]:=a/b.RawComponents[3,0];
 result.RawComponents[3,1]:=a/b.RawComponents[3,1];
 result.RawComponents[3,2]:=a/b.RawComponents[3,2];
 result.RawComponents[3,3]:=a/b.RawComponents[3,3];
end;
{$ifend}

class operator TpvMatrix4x4.Modulus({$ifdef fpc}constref{$else}const{$endif} a,b:TpvMatrix4x4):TpvMatrix4x4;
begin
 result.RawComponents[0,0]:=Modulo(a.RawComponents[0,0],b.RawComponents[0,0]);
 result.RawComponents[0,1]:=Modulo(a.RawComponents[0,1],b.RawComponents[0,1]);
 result.RawComponents[0,2]:=Modulo(a.RawComponents[0,2],b.RawComponents[0,2]);
 result.RawComponents[0,3]:=Modulo(a.RawComponents[0,3],b.RawComponents[0,3]);
 result.RawComponents[1,0]:=Modulo(a.RawComponents[1,0],b.RawComponents[1,0]);
 result.RawComponents[1,1]:=Modulo(a.RawComponents[1,1],b.RawComponents[1,1]);
 result.RawComponents[1,2]:=Modulo(a.RawComponents[1,2],b.RawComponents[1,2]);
 result.RawComponents[1,3]:=Modulo(a.RawComponents[1,3],b.RawComponents[1,3]);
 result.RawComponents[2,0]:=Modulo(a.RawComponents[2,0],b.RawComponents[2,0]);
 result.RawComponents[2,1]:=Modulo(a.RawComponents[2,1],b.RawComponents[2,1]);
 result.RawComponents[2,2]:=Modulo(a.RawComponents[2,2],b.RawComponents[2,2]);
 result.RawComponents[2,3]:=Modulo(a.RawComponents[2,3],b.RawComponents[2,3]);
 result.RawComponents[3,0]:=Modulo(a.RawComponents[3,0],b.RawComponents[3,0]);
 result.RawComponents[3,1]:=Modulo(a.RawComponents[3,1],b.RawComponents[3,1]);
 result.RawComponents[3,2]:=Modulo(a.RawComponents[3,2],b.RawComponents[3,2]);
 result.RawComponents[3,3]:=Modulo(a.RawComponents[3,3],b.RawComponents[3,3]);
end;

class operator TpvMatrix4x4.Modulus({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvScalar):TpvMatrix4x4;
begin
 result.RawComponents[0,0]:=Modulo(a.RawComponents[0,0],b);
 result.RawComponents[0,1]:=Modulo(a.RawComponents[0,1],b);
 result.RawComponents[0,2]:=Modulo(a.RawComponents[0,2],b);
 result.RawComponents[0,3]:=Modulo(a.RawComponents[0,3],b);
 result.RawComponents[1,0]:=Modulo(a.RawComponents[1,0],b);
 result.RawComponents[1,1]:=Modulo(a.RawComponents[1,1],b);
 result.RawComponents[1,2]:=Modulo(a.RawComponents[1,2],b);
 result.RawComponents[1,3]:=Modulo(a.RawComponents[1,3],b);
 result.RawComponents[2,0]:=Modulo(a.RawComponents[2,0],b);
 result.RawComponents[2,1]:=Modulo(a.RawComponents[2,1],b);
 result.RawComponents[2,2]:=Modulo(a.RawComponents[2,2],b);
 result.RawComponents[2,3]:=Modulo(a.RawComponents[2,3],b);
 result.RawComponents[3,0]:=Modulo(a.RawComponents[3,0],b);
 result.RawComponents[3,1]:=Modulo(a.RawComponents[3,1],b);
 result.RawComponents[3,2]:=Modulo(a.RawComponents[3,2],b);
 result.RawComponents[3,3]:=Modulo(a.RawComponents[3,3],b);
end;

class operator TpvMatrix4x4.Modulus({$ifdef fpc}constref{$else}const{$endif} a:TpvScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvMatrix4x4):TpvMatrix4x4;
begin
 result.RawComponents[0,0]:=Modulo(a,b.RawComponents[0,0]);
 result.RawComponents[0,1]:=Modulo(a,b.RawComponents[0,1]);
 result.RawComponents[0,2]:=Modulo(a,b.RawComponents[0,2]);
 result.RawComponents[0,3]:=Modulo(a,b.RawComponents[0,3]);
 result.RawComponents[1,0]:=Modulo(a,b.RawComponents[1,0]);
 result.RawComponents[1,1]:=Modulo(a,b.RawComponents[1,1]);
 result.RawComponents[1,2]:=Modulo(a,b.RawComponents[1,2]);
 result.RawComponents[1,3]:=Modulo(a,b.RawComponents[1,3]);
 result.RawComponents[2,0]:=Modulo(a,b.RawComponents[2,0]);
 result.RawComponents[2,1]:=Modulo(a,b.RawComponents[2,1]);
 result.RawComponents[2,2]:=Modulo(a,b.RawComponents[2,2]);
 result.RawComponents[2,3]:=Modulo(a,b.RawComponents[2,3]);
 result.RawComponents[3,0]:=Modulo(a,b.RawComponents[3,0]);
 result.RawComponents[3,1]:=Modulo(a,b.RawComponents[3,1]);
 result.RawComponents[3,2]:=Modulo(a,b.RawComponents[3,2]);
 result.RawComponents[3,3]:=Modulo(a,b.RawComponents[3,3]);
end;

class operator TpvMatrix4x4.Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvMatrix4x4):TpvMatrix4x4;
{$if defined(SIMD) and (defined(cpu386) or defined(cpux64))}
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}
 xorps xmm0,xmm0
 xorps xmm1,xmm1
 xorps xmm2,xmm2
 xorps xmm3,xmm3
{$if defined(ExplicitX64SIMDRegs)}
 movups xmm4,dqword ptr [rdx+0]
 movups xmm5,dqword ptr [rdx+16]
 movups xmm6,dqword ptr [rdx+32]
 movups xmm7,dqword ptr [rdx+48]
{$else}
 movups xmm4,dqword ptr [a+0]
 movups xmm5,dqword ptr [a+16]
 movups xmm6,dqword ptr [a+32]
 movups xmm7,dqword ptr [a+48]
{$ifend}
 subps xmm0,xmm4
 subps xmm1,xmm5
 subps xmm2,xmm6
 subps xmm3,xmm7
 movups dqword ptr [result+0],xmm0
 movups dqword ptr [result+16],xmm1
 movups dqword ptr [result+32],xmm2
 movups dqword ptr [result+48],xmm3
{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}
end;
{$else}
begin
 result.RawComponents[0,0]:=-a.RawComponents[0,0];
 result.RawComponents[0,1]:=-a.RawComponents[0,1];
 result.RawComponents[0,2]:=-a.RawComponents[0,2];
 result.RawComponents[0,3]:=-a.RawComponents[0,3];
 result.RawComponents[1,0]:=-a.RawComponents[1,0];
 result.RawComponents[1,1]:=-a.RawComponents[1,1];
 result.RawComponents[1,2]:=-a.RawComponents[1,2];
 result.RawComponents[1,3]:=-a.RawComponents[1,3];
 result.RawComponents[2,0]:=-a.RawComponents[2,0];
 result.RawComponents[2,1]:=-a.RawComponents[2,1];
 result.RawComponents[2,2]:=-a.RawComponents[2,2];
 result.RawComponents[2,3]:=-a.RawComponents[2,3];
 result.RawComponents[3,0]:=-a.RawComponents[3,0];
 result.RawComponents[3,1]:=-a.RawComponents[3,1];
 result.RawComponents[3,2]:=-a.RawComponents[3,2];
 result.RawComponents[3,3]:=-a.RawComponents[3,3];
end;
{$ifend}

class operator TpvMatrix4x4.Positive(const a:TpvMatrix4x4):TpvMatrix4x4;
begin
 result:=a;
end;

function TpvMatrix4x4.GetComponent(const pIndexA,pIndexB:TpvInt32):TpvScalar;
begin
 result:=RawComponents[pIndexA,pIndexB];
end;

procedure TpvMatrix4x4.SetComponent(const pIndexA,pIndexB:TpvInt32;const pValue:TpvScalar);
begin
 RawComponents[pIndexA,pIndexB]:=pValue;
end;

function TpvMatrix4x4.GetColumn(const pIndex:TpvInt32):TpvVector4;
begin
 result.x:=RawComponents[pIndex,0];
 result.y:=RawComponents[pIndex,1];
 result.z:=RawComponents[pIndex,2];
 result.w:=RawComponents[pIndex,3];
end;

procedure TpvMatrix4x4.SetColumn(const pIndex:TpvInt32;const pValue:TpvVector4);
begin
 RawComponents[pIndex,0]:=pValue.x;
 RawComponents[pIndex,1]:=pValue.y;
 RawComponents[pIndex,2]:=pValue.z;
 RawComponents[pIndex,3]:=pValue.w;
end;

function TpvMatrix4x4.GetRow(const pIndex:TpvInt32):TpvVector4;
begin
 result.x:=RawComponents[0,pIndex];
 result.y:=RawComponents[1,pIndex];
 result.z:=RawComponents[2,pIndex];
 result.w:=RawComponents[3,pIndex];
end;

procedure TpvMatrix4x4.SetRow(const pIndex:TpvInt32;const pValue:TpvVector4);
begin
 RawComponents[0,pIndex]:=pValue.x;
 RawComponents[1,pIndex]:=pValue.y;
 RawComponents[2,pIndex]:=pValue.z;
 RawComponents[3,pIndex]:=pValue.w;
end;

function TpvMatrix4x4.Determinant:TpvScalar;
{$if defined(SIMD) and defined(cpu386)}
asm
 movups xmm0,dqword ptr [eax+32]
 movups xmm1,dqword ptr [eax+48]
 movups xmm2,dqword ptr [eax+16]
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
 movups xmm6,dqword ptr [eax+0]
 mulps xmm5,xmm6
 movhlps xmm7,xmm5
 addps xmm5,xmm7
 movaps xmm6,xmm5
 shufps xmm6,xmm6,$01
 addss xmm5,xmm6
 movss dword ptr [result],xmm5
end;
{$elseif defined(SIMD) and defined(cpux64)}
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx+32]
 movups xmm1,dqword ptr [rcx+48]
 movups xmm2,dqword ptr [rcx+16]
(*{$else}
 movups xmm0,dqword ptr [rdi+32]
 movups xmm1,dqword ptr [rdi+48]
 movups xmm2,dqword ptr [rdi+16]
{$endif}*)
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
//{$ifdef Windows}
 movups xmm6,dqword ptr [rcx+0]
(*{$else}
 movups xmm6,dqword ptr [rdi+0]
{$endif}*)
 mulps xmm5,xmm6
 movhlps xmm7,xmm5
 addps xmm5,xmm7
 movaps xmm6,xmm5
 shufps xmm6,xmm6,$01
 addss xmm5,xmm6
{$ifdef fpc}
 movss dword ptr [result],xmm5
{$else}
 movaps xmm0,xmm5
{$endif}
//{$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
//{$endif}
end;
{$else}
begin
 result:=(RawComponents[0,0]*((((RawComponents[1,1]*RawComponents[2,2]*RawComponents[3,3])-(RawComponents[1,1]*RawComponents[2,3]*RawComponents[3,2]))-(RawComponents[2,1]*RawComponents[1,2]*RawComponents[3,3])+(RawComponents[2,1]*RawComponents[1,3]*RawComponents[3,2])+(RawComponents[3,1]*RawComponents[1,2]*RawComponents[2,3]))-(RawComponents[3,1]*RawComponents[1,3]*RawComponents[2,2])))+
         (RawComponents[0,1]*(((((-(RawComponents[1,0]*RawComponents[2,2]*RawComponents[3,3]))+(RawComponents[1,0]*RawComponents[2,3]*RawComponents[3,2])+(RawComponents[2,0]*RawComponents[1,2]*RawComponents[3,3]))-(RawComponents[2,0]*RawComponents[1,3]*RawComponents[3,2]))-(RawComponents[3,0]*RawComponents[1,2]*RawComponents[2,3]))+(RawComponents[3,0]*RawComponents[1,3]*RawComponents[2,2])))+
         (RawComponents[0,2]*(((((RawComponents[1,0]*RawComponents[2,1]*RawComponents[3,3])-(RawComponents[1,0]*RawComponents[2,3]*RawComponents[3,1]))-(RawComponents[2,0]*RawComponents[1,1]*RawComponents[3,3]))+(RawComponents[2,0]*RawComponents[1,3]*RawComponents[3,1])+(RawComponents[3,0]*RawComponents[1,1]*RawComponents[2,3]))-(RawComponents[3,0]*RawComponents[1,3]*RawComponents[2,1])))+
         (RawComponents[0,3]*(((((-(RawComponents[1,0]*RawComponents[2,1]*RawComponents[3,2]))+(RawComponents[1,0]*RawComponents[2,2]*RawComponents[3,1])+(RawComponents[2,0]*RawComponents[1,1]*RawComponents[3,2]))-(RawComponents[2,0]*RawComponents[1,2]*RawComponents[3,1]))-(RawComponents[3,0]*RawComponents[1,1]*RawComponents[2,2]))+(RawComponents[3,0]*RawComponents[1,2]*RawComponents[2,1])));
end;
{$ifend}

function TpvMatrix4x4.Translate(const aVector:TpvVector3):TpvMatrix4x4; 
begin
// result:=self*TpvMatrix4x4.CreateTranslation(aVector);
 result:=self;
 result.RawComponents[3,0]:=result.RawComponents[3,0]+aVector.x;
 result.RawComponents[3,1]:=result.RawComponents[3,1]+aVector.y;
 result.RawComponents[3,2]:=result.RawComponents[3,2]+aVector.z;
end;

function TpvMatrix4x4.SimpleInverse:TpvMatrix4x4;
begin
 result.RawComponents[0,0]:=RawComponents[0,0];
 result.RawComponents[0,1]:=RawComponents[1,0];
 result.RawComponents[0,2]:=RawComponents[2,0];
 result.RawComponents[0,3]:=RawComponents[0,3];
 result.RawComponents[1,0]:=RawComponents[0,1];
 result.RawComponents[1,1]:=RawComponents[1,1];
 result.RawComponents[1,2]:=RawComponents[2,1];
 result.RawComponents[1,3]:=RawComponents[1,3];
 result.RawComponents[2,0]:=RawComponents[0,2];
 result.RawComponents[2,1]:=RawComponents[1,2];
 result.RawComponents[2,2]:=RawComponents[2,2];
 result.RawComponents[2,3]:=RawComponents[2,3];
 result.RawComponents[3,0]:=-PpvVector3(pointer(@RawComponents[3,0]))^.Dot(TpvVector3.Create(RawComponents[0,0],RawComponents[0,1],RawComponents[0,2]));
 result.RawComponents[3,1]:=-PpvVector3(pointer(@RawComponents[3,0]))^.Dot(TpvVector3.Create(RawComponents[1,0],RawComponents[1,1],RawComponents[1,2]));
 result.RawComponents[3,2]:=-PpvVector3(pointer(@RawComponents[3,0]))^.Dot(TpvVector3.Create(RawComponents[2,0],RawComponents[2,1],RawComponents[2,2]));
 result.RawComponents[3,3]:=RawComponents[3,3];
end;

function TpvMatrix4x4.Inverse:TpvMatrix4x4;
{$if defined(SIMD) and defined(cpu386)}
asm
 mov ecx,esp
 and esp,$fffffff0
 sub esp,$b0
 movlps xmm2,qword ptr [eax+8]
 movlps xmm4,qword ptr [eax+40]
 movhps xmm2,qword ptr [eax+24]
 movhps xmm4,qword ptr [eax+56]
 movlps xmm3,qword ptr [eax+32]
 movlps xmm1,qword ptr [eax]
 movhps xmm3,qword ptr [eax+48]
 movhps xmm1,qword ptr [eax+16]
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
{$elseif defined(SIMD) and defined(cpux64)}
{-$ifdef Windows}
var StackSave0,StackSave1:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave0],xmm6
 movups dqword ptr [StackSave1],xmm7
{-$endif}
 mov r9,rsp
 mov r8,$fffffffffffffff0
 and rsp,r8
 sub rsp,$b0
//{$ifdef Windows}
 movlps xmm2,qword ptr [rcx+8]
 movlps xmm4,qword ptr [rcx+40]
 movhps xmm2,qword ptr [rcx+24]
 movhps xmm4,qword ptr [rcx+56]
 movlps xmm3,qword ptr [rcx+32]
 movlps xmm1,qword ptr [rcx]
 movhps xmm3,qword ptr [rcx+48]
 movhps xmm1,qword ptr [rcx+16]
(*{$else}
 movlps xmm2,qword ptr [rdi+8]
 movlps xmm4,qword ptr [rdi+40]
 movhps xmm2,qword ptr [rdi+24]
 movhps xmm4,qword ptr [rdi+56]
 movlps xmm3,qword ptr [rdi+32]
 movlps xmm1,qword ptr [rdi]
 movhps xmm3,qword ptr [rdi+48]
 movhps xmm1,qword ptr [rdi+16]
{$endif}*)
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
 movaps dqword ptr [rsp+16],xmm2
 movaps xmm2,xmm4
 mulps xmm2,xmm7
 addps xmm2,xmm3
 movaps xmm3,xmm7
 shufps xmm7,xmm7,$4e
 mulps xmm3,xmm1
 movaps dqword ptr [rsp+32],xmm3
 movaps xmm3,xmm4
 mulps xmm3,xmm7
 mulps xmm7,xmm1
 subps xmm2,xmm3
 movaps xmm3,xmm6
 shufps xmm3,xmm3,$4e
 mulps xmm3,xmm4
 shufps xmm3,xmm3,$b1
 movaps dqword ptr [rsp+48],xmm7
 movaps xmm7,xmm5
 mulps xmm5,xmm3
 addps xmm5,xmm2
 movaps xmm2,xmm3
 shufps xmm3,xmm3,$4e
 mulps xmm2,xmm1
 movaps dqword ptr [rsp+64],xmm4
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
 movaps dqword ptr [rsp],xmm5
 addps xmm1,xmm7
 movaps xmm5,xmm1
 shufps xmm1,xmm1,$b1
 addss xmm1,xmm5
 movaps xmm5,xmm6
 mulps xmm5,xmm2
 shufps xmm5,xmm5,$b1
 movaps xmm7,xmm5
 shufps xmm5,xmm5,$4e
 movaps dqword ptr [rsp+80],xmm4
 movaps xmm4,dqword ptr [rsp+64]
 movaps dqword ptr [rsp+64],xmm6
 movaps xmm6,xmm4
 mulps xmm6,xmm7
 addps xmm6,xmm3
 movaps xmm3,xmm4
 mulps xmm3,xmm5
 subps xmm3,xmm6
 movaps xmm6,xmm4
 mulps xmm6,xmm2
 shufps xmm6,xmm6,$b1
 movaps dqword ptr [rsp+112],xmm5
 movaps xmm5,dqword ptr [rsp+64]
 movaps dqword ptr [rsp+128],xmm7
 movaps xmm7,xmm6
 mulps xmm7,xmm5
 addps xmm7,xmm3
 movaps xmm3,xmm6
 shufps xmm3,xmm3,$4e
 movaps dqword ptr [rsp+144],xmm4
 movaps xmm4,xmm5
 mulps xmm5,xmm3
 movaps dqword ptr [rsp+160],xmm4
 movaps xmm4,xmm6
 movaps xmm6,xmm7
 subps xmm6,xmm5
 movaps xmm5,xmm0
 movaps xmm7,dqword ptr [rsp+16]
 subps xmm5,xmm7
 shufps xmm5,xmm5,$4e
 movaps xmm7,dqword ptr [rsp+80]
 mulps xmm4,xmm7
 mulps xmm3,xmm7
 subps xmm5,xmm4
 mulps xmm2,xmm7
 addps xmm3,xmm5
 shufps xmm2,xmm2,$b1
 movaps xmm4,xmm2
 shufps xmm4,xmm4,$4e
 movaps xmm5,dqword ptr [rsp+144]
 movaps xmm0,xmm6
 movaps xmm6,xmm5
 mulps xmm5,xmm2
 mulps xmm6,xmm4
 addps xmm5,xmm3
 movaps xmm3,xmm4
 movaps xmm4,xmm5
 subps xmm4,xmm6
 movaps xmm5,dqword ptr [rsp+48]
 movaps xmm6,dqword ptr [rsp+32]
 subps xmm5,xmm6
 shufps xmm5,xmm5,$4e
 movaps xmm6,[rsp+128]
 mulps xmm6,xmm7
 subps xmm6,xmm5
 movaps xmm5,dqword ptr [rsp+112]
 mulps xmm7,xmm5
 subps xmm6,xmm7
 movaps xmm5,dqword ptr [rsp+160]
 mulps xmm2,xmm5
 mulps xmm5,xmm3
 subps xmm6,xmm2
 movaps xmm2,xmm5
 addps xmm2,xmm6
 movaps xmm6,xmm0
 movaps xmm0,xmm1
 movaps xmm1,dqword ptr [rsp]
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
 mov rsp,r9
{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave0]
 movups xmm7,dqword ptr [StackSave1]
{-$endif}
end;
{$else}
var t0,t4,t8,t12,d:TpvScalar;
begin
 t0:=(((RawComponents[1,1]*RawComponents[2,2]*RawComponents[3,3])-(RawComponents[1,1]*RawComponents[2,3]*RawComponents[3,2]))-(RawComponents[2,1]*RawComponents[1,2]*RawComponents[3,3])+(RawComponents[2,1]*RawComponents[1,3]*RawComponents[3,2])+(RawComponents[3,1]*RawComponents[1,2]*RawComponents[2,3]))-(RawComponents[3,1]*RawComponents[1,3]*RawComponents[2,2]);
 t4:=((((-(RawComponents[1,0]*RawComponents[2,2]*RawComponents[3,3]))+(RawComponents[1,0]*RawComponents[2,3]*RawComponents[3,2])+(RawComponents[2,0]*RawComponents[1,2]*RawComponents[3,3]))-(RawComponents[2,0]*RawComponents[1,3]*RawComponents[3,2]))-(RawComponents[3,0]*RawComponents[1,2]*RawComponents[2,3]))+(RawComponents[3,0]*RawComponents[1,3]*RawComponents[2,2]);
 t8:=((((RawComponents[1,0]*RawComponents[2,1]*RawComponents[3,3])-(RawComponents[1,0]*RawComponents[2,3]*RawComponents[3,1]))-(RawComponents[2,0]*RawComponents[1,1]*RawComponents[3,3]))+(RawComponents[2,0]*RawComponents[1,3]*RawComponents[3,1])+(RawComponents[3,0]*RawComponents[1,1]*RawComponents[2,3]))-(RawComponents[3,0]*RawComponents[1,3]*RawComponents[2,1]);
 t12:=((((-(RawComponents[1,0]*RawComponents[2,1]*RawComponents[3,2]))+(RawComponents[1,0]*RawComponents[2,2]*RawComponents[3,1])+(RawComponents[2,0]*RawComponents[1,1]*RawComponents[3,2]))-(RawComponents[2,0]*RawComponents[1,2]*RawComponents[3,1]))-(RawComponents[3,0]*RawComponents[1,1]*RawComponents[2,2]))+(RawComponents[3,0]*RawComponents[1,2]*RawComponents[2,1]);
 d:=(RawComponents[0,0]*t0)+(RawComponents[0,1]*t4)+(RawComponents[0,2]*t8)+(RawComponents[0,3]*t12);
 if d<>0.0 then begin
  d:=1.0/d;
  result.RawComponents[0,0]:=t0*d;
  result.RawComponents[0,1]:=(((((-(RawComponents[0,1]*RawComponents[2,2]*RawComponents[3,3]))+(RawComponents[0,1]*RawComponents[2,3]*RawComponents[3,2])+(RawComponents[2,1]*RawComponents[0,2]*RawComponents[3,3]))-(RawComponents[2,1]*RawComponents[0,3]*RawComponents[3,2]))-(RawComponents[3,1]*RawComponents[0,2]*RawComponents[2,3]))+(RawComponents[3,1]*RawComponents[0,3]*RawComponents[2,2]))*d;
  result.RawComponents[0,2]:=(((((RawComponents[0,1]*RawComponents[1,2]*RawComponents[3,3])-(RawComponents[0,1]*RawComponents[1,3]*RawComponents[3,2]))-(RawComponents[1,1]*RawComponents[0,2]*RawComponents[3,3]))+(RawComponents[1,1]*RawComponents[0,3]*RawComponents[3,2])+(RawComponents[3,1]*RawComponents[0,2]*RawComponents[1,3]))-(RawComponents[3,1]*RawComponents[0,3]*RawComponents[1,2]))*d;
  result.RawComponents[0,3]:=(((((-(RawComponents[0,1]*RawComponents[1,2]*RawComponents[2,3]))+(RawComponents[0,1]*RawComponents[1,3]*RawComponents[2,2])+(RawComponents[1,1]*RawComponents[0,2]*RawComponents[2,3]))-(RawComponents[1,1]*RawComponents[0,3]*RawComponents[2,2]))-(RawComponents[2,1]*RawComponents[0,2]*RawComponents[1,3]))+(RawComponents[2,1]*RawComponents[0,3]*RawComponents[1,2]))*d;
  result.RawComponents[1,0]:=t4*d;
  result.RawComponents[1,1]:=((((RawComponents[0,0]*RawComponents[2,2]*RawComponents[3,3])-(RawComponents[0,0]*RawComponents[2,3]*RawComponents[3,2]))-(RawComponents[2,0]*RawComponents[0,2]*RawComponents[3,3])+(RawComponents[2,0]*RawComponents[0,3]*RawComponents[3,2])+(RawComponents[3,0]*RawComponents[0,2]*RawComponents[2,3]))-(RawComponents[3,0]*RawComponents[0,3]*RawComponents[2,2]))*d;
  result.RawComponents[1,2]:=(((((-(RawComponents[0,0]*RawComponents[1,2]*RawComponents[3,3]))+(RawComponents[0,0]*RawComponents[1,3]*RawComponents[3,2])+(RawComponents[1,0]*RawComponents[0,2]*RawComponents[3,3]))-(RawComponents[1,0]*RawComponents[0,3]*RawComponents[3,2]))-(RawComponents[3,0]*RawComponents[0,2]*RawComponents[1,3]))+(RawComponents[3,0]*RawComponents[0,3]*RawComponents[1,2]))*d;
  result.RawComponents[1,3]:=(((((RawComponents[0,0]*RawComponents[1,2]*RawComponents[2,3])-(RawComponents[0,0]*RawComponents[1,3]*RawComponents[2,2]))-(RawComponents[1,0]*RawComponents[0,2]*RawComponents[2,3]))+(RawComponents[1,0]*RawComponents[0,3]*RawComponents[2,2])+(RawComponents[2,0]*RawComponents[0,2]*RawComponents[1,3]))-(RawComponents[2,0]*RawComponents[0,3]*RawComponents[1,2]))*d;
  result.RawComponents[2,0]:=t8*d;
  result.RawComponents[2,1]:=(((((-(RawComponents[0,0]*RawComponents[2,1]*RawComponents[3,3]))+(RawComponents[0,0]*RawComponents[2,3]*RawComponents[3,1])+(RawComponents[2,0]*RawComponents[0,1]*RawComponents[3,3]))-(RawComponents[2,0]*RawComponents[0,3]*RawComponents[3,1]))-(RawComponents[3,0]*RawComponents[0,1]*RawComponents[2,3]))+(RawComponents[3,0]*RawComponents[0,3]*RawComponents[2,1]))*d;
  result.RawComponents[2,2]:=(((((RawComponents[0,0]*RawComponents[1,1]*RawComponents[3,3])-(RawComponents[0,0]*RawComponents[1,3]*RawComponents[3,1]))-(RawComponents[1,0]*RawComponents[0,1]*RawComponents[3,3]))+(RawComponents[1,0]*RawComponents[0,3]*RawComponents[3,1])+(RawComponents[3,0]*RawComponents[0,1]*RawComponents[1,3]))-(RawComponents[3,0]*RawComponents[0,3]*RawComponents[1,1]))*d;
  result.RawComponents[2,3]:=(((((-(RawComponents[0,0]*RawComponents[1,1]*RawComponents[2,3]))+(RawComponents[0,0]*RawComponents[1,3]*RawComponents[2,1])+(RawComponents[1,0]*RawComponents[0,1]*RawComponents[2,3]))-(RawComponents[1,0]*RawComponents[0,3]*RawComponents[2,1]))-(RawComponents[2,0]*RawComponents[0,1]*RawComponents[1,3]))+(RawComponents[2,0]*RawComponents[0,3]*RawComponents[1,1]))*d;
  result.RawComponents[3,0]:=t12*d;
  result.RawComponents[3,1]:=(((((RawComponents[0,0]*RawComponents[2,1]*RawComponents[3,2])-(RawComponents[0,0]*RawComponents[2,2]*RawComponents[3,1]))-(RawComponents[2,0]*RawComponents[0,1]*RawComponents[3,2]))+(RawComponents[2,0]*RawComponents[0,2]*RawComponents[3,1])+(RawComponents[3,0]*RawComponents[0,1]*RawComponents[2,2]))-(RawComponents[3,0]*RawComponents[0,2]*RawComponents[2,1]))*d;
  result.RawComponents[3,2]:=(((((-(RawComponents[0,0]*RawComponents[1,1]*RawComponents[3,2]))+(RawComponents[0,0]*RawComponents[1,2]*RawComponents[3,1])+(RawComponents[1,0]*RawComponents[0,1]*RawComponents[3,2]))-(RawComponents[1,0]*RawComponents[0,2]*RawComponents[3,1]))-(RawComponents[3,0]*RawComponents[0,1]*RawComponents[1,2]))+(RawComponents[3,0]*RawComponents[0,2]*RawComponents[1,1]))*d;
  result.RawComponents[3,3]:=(((((RawComponents[0,0]*RawComponents[1,1]*RawComponents[2,2])-(RawComponents[0,0]*RawComponents[1,2]*RawComponents[2,1]))-(RawComponents[1,0]*RawComponents[0,1]*RawComponents[2,2]))+(RawComponents[1,0]*RawComponents[0,2]*RawComponents[2,1])+(RawComponents[2,0]*RawComponents[0,1]*RawComponents[1,2]))-(RawComponents[2,0]*RawComponents[0,2]*RawComponents[1,1]))*d;
 end;
end;
{$ifend}

function TpvMatrix4x4.Transpose:TpvMatrix4x4;
{$if defined(SIMD) and defined(cpu386)}
asm
 movups xmm0,dqword ptr [eax+0]
 movups xmm4,dqword ptr [eax+16]
 movups xmm2,dqword ptr [eax+32]
 movups xmm5,dqword ptr [eax+48]
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
{$elseif defined(SIMD) and defined(cpux64)}
{-$ifdef Windows}
var StackSave:array[0..3] of single;
{-$endif}
asm
{-$ifdef Windows}
 movups dqword ptr [StackSave],xmm6
{-$endif}
//{$ifdef Windows}
 movups xmm0,dqword ptr [rcx+0]
 movups xmm4,dqword ptr [rcx+16]
 movups xmm2,dqword ptr [rcx+32]
 movups xmm5,dqword ptr [rcx+48]
(*{$else}
 movups xmm0,dqword ptr [rdi+0]
 movups xmm4,dqword ptr [rdi+16]
 movups xmm2,dqword ptr [rdi+32]
 movups xmm5,dqword ptr [rdi+48]
{$endif}*)
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
{-$ifdef Windows}
 movups xmm6,dqword ptr [StackSave]
{-$endif}
end;
{$else}
begin
 result.RawComponents[0,0]:=RawComponents[0,0];
 result.RawComponents[0,1]:=RawComponents[1,0];
 result.RawComponents[0,2]:=RawComponents[2,0];
 result.RawComponents[0,3]:=RawComponents[3,0];
 result.RawComponents[1,0]:=RawComponents[0,1];
 result.RawComponents[1,1]:=RawComponents[1,1];
 result.RawComponents[1,2]:=RawComponents[2,1];
 result.RawComponents[1,3]:=RawComponents[3,1];
 result.RawComponents[2,0]:=RawComponents[0,2];
 result.RawComponents[2,1]:=RawComponents[1,2];
 result.RawComponents[2,2]:=RawComponents[2,2];
 result.RawComponents[2,3]:=RawComponents[3,2];
 result.RawComponents[3,0]:=RawComponents[0,3];
 result.RawComponents[3,1]:=RawComponents[1,3];
 result.RawComponents[3,2]:=RawComponents[2,3];
 result.RawComponents[3,3]:=RawComponents[3,3];
end;
{$ifend}

function TpvMatrix4x4.Adjugate:TpvMatrix3x3;
begin
 result.RawVectors[0]:=RawVectors[1].xyz.Cross(RawVectors[2].xyz);
 result.RawVectors[1]:=RawVectors[2].xyz.Cross(RawVectors[0].xyz);
 result.RawVectors[2]:=RawVectors[0].xyz.Cross(RawVectors[1].xyz);
{result.RawComponents[0,0]:=(RawComponents[1,1]*RawComponents[2,2])-(RawComponents[1,2]*RawComponents[2,1]);
 result.RawComponents[0,1]:=(RawComponents[1,2]*RawComponents[2,0])-(RawComponents[1,0]*RawComponents[2,2]);
 result.RawComponents[0,2]:=(RawComponents[1,0]*RawComponents[2,1])-(RawComponents[1,1]*RawComponents[2,0]);
 result.RawComponents[1,0]:=(RawComponents[0,2]*RawComponents[2,1])-(RawComponents[0,1]*RawComponents[2,2]);
 result.RawComponents[1,1]:=(RawComponents[0,0]*RawComponents[2,2])-(RawComponents[0,2]*RawComponents[2,0]);
 result.RawComponents[1,2]:=(RawComponents[0,1]*RawComponents[2,0])-(RawComponents[0,0]*RawComponents[2,1]);
 result.RawComponents[2,0]:=(RawComponents[0,1]*RawComponents[1,2])-(RawComponents[0,2]*RawComponents[1,1]);
 result.RawComponents[2,1]:=(RawComponents[0,2]*RawComponents[1,0])-(RawComponents[0,0]*RawComponents[1,2]);
 result.RawComponents[2,2]:=(RawComponents[0,0]*RawComponents[1,1])-(RawComponents[0,1]*RawComponents[1,0]);}
end;

function TpvMatrix4x4.EulerAngles:TpvVector3;
var v0,v1:TpvVector3;
begin
 if abs((-1.0)-RawComponents[0,2])<EPSILON then begin
  result.x:=0.0;
  result.y:=HalfPI;
  result.z:=ArcTan2(RawComponents[1,0],RawComponents[2,0]);
 end else if abs(1.0-RawComponents[0,2])<EPSILON then begin
  result.x:=0.0;
  result.y:=-HalfPI;
  result.z:=ArcTan2(-RawComponents[1,0],-RawComponents[2,0]);
 end else begin
  v0.x:=-ArcSin(RawComponents[0,2]);
  v1.x:=PI-v0.x;
  v0.y:=ArcTan2(RawComponents[1,2]/cos(v0.x),RawComponents[2,2]/cos(v0.x));
  v1.y:=ArcTan2(RawComponents[1,2]/cos(v1.x),RawComponents[2,2]/cos(v1.x));
  v0.z:=ArcTan2(RawComponents[0,1]/cos(v0.x),RawComponents[0,0]/cos(v0.x));
  v1.z:=ArcTan2(RawComponents[0,1]/cos(v1.x),RawComponents[0,0]/cos(v1.x));
  if v0.SquaredLength<v1.SquaredLength then begin
   result:=v0;
  end else begin
   result:=v1;
  end;
 end;
end;

function TpvMatrix4x4.Normalize:TpvMatrix4x4;
begin
 result.Right.xyz:=Right.xyz.Normalize;
 result.RawComponents[0,3]:=RawComponents[0,3];
 result.Up.xyz:=Up.xyz.Normalize;
 result.RawComponents[1,3]:=RawComponents[1,3];
 result.Forwards.xyz:=Forwards.xyz.Normalize;
 result.RawComponents[2,3]:=RawComponents[2,3];
 result.Translation:=Translation;
end;

function TpvMatrix4x4.OrthoNormalize:TpvMatrix4x4;
begin
 result.Normal.xyz:=Normal.xyz.Normalize;
 result.Tangent.xyz:=(Tangent.xyz-(result.Normal.xyz*Tangent.xyz.Dot(result.Normal.xyz))).Normalize;
 result.Bitangent.xyz:=result.Normal.xyz.Cross(result.Tangent.xyz).Normalize;
 result.Bitangent.xyz:=result.Bitangent.xyz-(result.Normal.xyz*result.Bitangent.xyz.Dot(result.Normal.xyz));
 result.Bitangent.xyz:=(result.Bitangent.xyz-(result.Tangent.xyz*result.Bitangent.xyz.Dot(result.Tangent.xyz))).Normalize;
 result.Tangent.xyz:=result.Bitangent.xyz.Cross(result.Normal.xyz).Normalize;
 result.Normal.xyz:=result.Tangent.xyz.Cross(result.Bitangent.xyz).Normalize;
 result.RawComponents[0,3]:=RawComponents[0,3];
 result.RawComponents[1,3]:=RawComponents[1,3];
 result.RawComponents[2,3]:=RawComponents[2,3];
 result.RawComponents[3,3]:=RawComponents[3,3];
 result.RawComponents[3,0]:=RawComponents[3,0];
 result.RawComponents[3,1]:=RawComponents[3,1];
 result.RawComponents[3,2]:=RawComponents[3,2];
end;

function TpvMatrix4x4.RobustOrthoNormalize(const Tolerance:TpvScalar=1e-3):TpvMatrix4x4;
var Bisector,Axis:TpvVector3;
begin
 begin
  if Normal.xyz.Length<Tolerance then begin
   // Degenerate case, compute new Normal.xyz
   Normal.xyz:=Tangent.xyz.Cross(Bitangent.xyz);
   if Normal.xyz.Length<Tolerance then begin
    result.Tangent.xyz:=TpvVector3.XAxis;
    result.Bitangent.xyz:=TpvVector3.YAxis;
    result.Normal.xyz:=TpvVector3.ZAxis;
    result.RawComponents[0,3]:=RawComponents[0,3];
    result.RawComponents[1,3]:=RawComponents[1,3];
    result.RawComponents[2,3]:=RawComponents[2,3];
    result.RawComponents[3,3]:=RawComponents[3,3];
    result.RawComponents[3,0]:=RawComponents[3,0];
    result.RawComponents[3,1]:=RawComponents[3,1];
    result.RawComponents[3,2]:=RawComponents[3,2];
    exit;
   end;
  end;
  result.Normal.xyz:=Normal.xyz.Normalize;
 end;
 begin
  // Project Tangent.xyz and Bitangent.xyz onto the Normal.xyz orthogonal plane
  result.Tangent.xyz:=Tangent.xyz-(result.Normal.xyz*Tangent.xyz.Dot(result.Normal.xyz));
  result.Bitangent.xyz:=Bitangent.xyz-(result.Normal.xyz*Bitangent.xyz.Dot(result.Normal.xyz));
 end;
 begin
  // Check for several degenerate cases
  if result.Tangent.xyz.Length<Tolerance then begin
   if result.Bitangent.xyz.Length<Tolerance then begin
    result.Tangent.xyz:=result.Normal.xyz.Normalize;
    if (result.Tangent.xyz.x<=result.Tangent.xyz.y) and (result.Tangent.xyz.x<=result.Tangent.xyz.z) then begin
     result.Tangent.xyz:=TpvVector3.XAxis;
    end else if (result.Tangent.xyz.y<=result.Tangent.xyz.x) and (result.Tangent.xyz.y<=result.Tangent.xyz.z) then begin
     result.Tangent.xyz:=TpvVector3.YAxis;
    end else begin
     result.Tangent.xyz:=TpvVector3.ZAxis;
    end;
    result.Tangent.xyz:=result.Tangent.xyz-(result.Normal.xyz*result.Tangent.xyz.Dot(result.Normal.xyz));
    result.Bitangent.xyz:=result.Normal.xyz.Cross(result.Tangent.xyz).Normalize;
   end else begin
    result.Tangent.xyz:=result.Bitangent.xyz.Cross(result.Normal.xyz).Normalize;
   end;
  end else begin
   result.Tangent.xyz:=result.Tangent.xyz.Normalize;
   if result.Bitangent.xyz.Length<Tolerance then begin
    result.Bitangent.xyz:=result.Normal.xyz.Cross(result.Tangent.xyz).Normalize;
   end else begin
    result.Bitangent.xyz:=result.Bitangent.xyz.Normalize;
    Bisector:=result.Tangent.xyz+result.Bitangent.xyz;
    if Bisector.Length<Tolerance then begin
     Bisector:=result.Tangent.xyz;
    end else begin
     Bisector:=Bisector.Normalize;
    end;
    Axis:=Bisector.Cross(result.Normal.xyz).Normalize;
    if Axis.Dot(Tangent.xyz)>0.0 then begin
     result.Tangent.xyz:=(Bisector+Axis).Normalize;
     result.Bitangent.xyz:=(Bisector-Axis).Normalize;
    end else begin
     result.Tangent.xyz:=(Bisector-Axis).Normalize;
     result.Bitangent.xyz:=(Bisector+Axis).Normalize;
    end;
   end;
  end;
 end;
 result.Bitangent.xyz:=result.Normal.xyz.Cross(result.Tangent.xyz).Normalize;
 result.Tangent.xyz:=result.Bitangent.xyz.Cross(result.Normal.xyz).Normalize;
 result.Normal.xyz:=result.Tangent.xyz.Cross(result.Bitangent.xyz).Normalize;
 result.RawComponents[0,3]:=RawComponents[0,3];
 result.RawComponents[1,3]:=RawComponents[1,3];
 result.RawComponents[2,3]:=RawComponents[2,3];
 result.RawComponents[3,3]:=RawComponents[3,3];
 result.RawComponents[3,0]:=RawComponents[3,0];
 result.RawComponents[3,1]:=RawComponents[3,1];
 result.RawComponents[3,2]:=RawComponents[3,2];
end;

function TpvMatrix4x4.ToQuaternion:TpvQuaternion;
var t,s:TpvScalar;
begin
 t:=RawComponents[0,0]+(RawComponents[1,1]+RawComponents[2,2]);
 if t>2.9999999 then begin
  result.x:=0.0;
  result.y:=0.0;
  result.z:=0.0;
  result.w:=1.0;
 end else if t>0.0000001 then begin
  s:=sqrt(1.0+t)*2.0;
  result.x:=(RawComponents[1,2]-RawComponents[2,1])/s;
  result.y:=(RawComponents[2,0]-RawComponents[0,2])/s;
  result.z:=(RawComponents[0,1]-RawComponents[1,0])/s;
  result.w:=s*0.25;
 end else if (RawComponents[0,0]>RawComponents[1,1]) and (RawComponents[0,0]>RawComponents[2,2]) then begin
  s:=sqrt(1.0+(RawComponents[0,0]-(RawComponents[1,1]+RawComponents[2,2])))*2.0;
  result.x:=s*0.25;
  result.y:=(RawComponents[1,0]+RawComponents[0,1])/s;
  result.z:=(RawComponents[2,0]+RawComponents[0,2])/s;
  result.w:=(RawComponents[1,2]-RawComponents[2,1])/s;
 end else if RawComponents[1,1]>RawComponents[2,2] then begin
  s:=sqrt(1.0+(RawComponents[1,1]-(RawComponents[0,0]+RawComponents[2,2])))*2.0;
  result.x:=(RawComponents[1,0]+RawComponents[0,1])/s;
  result.y:=s*0.25;
  result.z:=(RawComponents[2,1]+RawComponents[1,2])/s;
  result.w:=(RawComponents[2,0]-RawComponents[0,2])/s;
 end else begin
  s:=sqrt(1.0+(RawComponents[2,2]-(RawComponents[0,0]+RawComponents[1,1])))*2.0;
  result.x:=(RawComponents[2,0]+RawComponents[0,2])/s;
  result.y:=(RawComponents[2,1]+RawComponents[1,2])/s;
  result.z:=s*0.25;
  result.w:=(RawComponents[0,1]-RawComponents[1,0])/s;
 end;
 result:=result.Normalize;
end;

function TpvMatrix4x4.ToQTangent(const aThreshold:TpvDouble):TpvQuaternion;
var Scale,t,s,Renormalization:TpvScalar;
begin
 if ((((((RawComponents[0,0]*RawComponents[1,1]*RawComponents[2,2])+
         (RawComponents[0,1]*RawComponents[1,2]*RawComponents[2,0])
        )+
        (RawComponents[0,2]*RawComponents[1,0]*RawComponents[2,1])
       )-
       (RawComponents[0,2]*RawComponents[1,1]*RawComponents[2,0])
      )-
      (RawComponents[0,1]*RawComponents[1,0]*RawComponents[2,2])
     )-
     (RawComponents[0,0]*RawComponents[1,2]*RawComponents[2,1])
    )<0.0 then begin
  // Reflection matrix, so flip y axis in case the tangent frame encodes a reflection
  Scale:=-1.0;
 end else begin
  // Rotation matrix, so nothing is doing to do
  Scale:=1.0;
 end;
 begin
  // Convert to quaternion
  t:=RawComponents[0,0]+(RawComponents[1,1]+(RawComponents[2,2]*Scale));
  if t>2.9999999 then begin
   result.x:=0.0;
   result.y:=0.0;
   result.z:=0.0;
   result.w:=1.0;
  end else if t>0.0000001 then begin
   s:=sqrt(1.0+t)*2.0;
   result.x:=(RawComponents[1,2]-(RawComponents[2,1]*Scale))/s;
   result.y:=((RawComponents[2,0]*Scale)-RawComponents[0,2])/s;
   result.z:=(RawComponents[0,1]-RawComponents[1,0])/s;
   result.w:=s*0.25;
  end else if (RawComponents[0,0]>RawComponents[1,1]) and (RawComponents[0,0]>(RawComponents[2,2]*Scale)) then begin
   s:=sqrt(1.0+(RawComponents[0,0]-(RawComponents[1,1]+(RawComponents[2,2]*Scale))))*2.0;
   result.x:=s*0.25;
   result.y:=(RawComponents[1,0]+RawComponents[0,1])/s;
   result.z:=((RawComponents[2,0]*Scale)+RawComponents[0,2])/s;
   result.w:=(RawComponents[1,2]-(RawComponents[2,1]*Scale))/s;
  end else if RawComponents[1,1]>(RawComponents[2,2]*Scale) then begin
   s:=sqrt(1.0+(RawComponents[1,1]-(RawComponents[0,0]+(RawComponents[2,2]*Scale))))*2.0;
   result.x:=(RawComponents[1,0]+RawComponents[0,1])/s;
   result.y:=s*0.25;
   result.z:=((RawComponents[2,1]*Scale)+RawComponents[1,2])/s;
   result.w:=((RawComponents[2,0]*Scale)-RawComponents[0,2])/s;
  end else begin
   s:=sqrt(1.0+((RawComponents[2,2]*Scale)-(RawComponents[0,0]+RawComponents[1,1])))*2.0;
   result.x:=((RawComponents[2,0]*Scale)+RawComponents[0,2])/s;
   result.y:=((RawComponents[2,1]*Scale)+RawComponents[1,2])/s;
   result.z:=s*0.25;
   result.w:=(RawComponents[0,1]-RawComponents[1,0])/s;
  end;
  result:=result.Normalize;
 end;
 begin
  // Make sure, that we don't end up with 0 as w component
  if abs(result.w)<=aThreshold then begin
   Renormalization:=sqrt(1.0-sqr(aThreshold));
   result.x:=result.x*Renormalization;
   result.y:=result.y*Renormalization;
   result.z:=result.z*Renormalization;
   if result.w>0.0 then begin
    result.w:=aThreshold;
   end else begin
    result.w:=-aThreshold;
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

function TpvMatrix4x4.ToMatrix3x3:TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=RawComponents[0,0];
 result.RawComponents[0,1]:=RawComponents[0,1];
 result.RawComponents[0,2]:=RawComponents[0,2];
 result.RawComponents[1,0]:=RawComponents[1,0];
 result.RawComponents[1,1]:=RawComponents[1,1];
 result.RawComponents[1,2]:=RawComponents[1,2];
 result.RawComponents[2,0]:=RawComponents[2,0];
 result.RawComponents[2,1]:=RawComponents[2,1];
 result.RawComponents[2,2]:=RawComponents[2,2];
end;

function TpvMatrix4x4.ToRotation:TpvMatrix4x4;
begin
 result.RawComponents[0,0]:=RawComponents[0,0];
 result.RawComponents[0,1]:=RawComponents[0,1];
 result.RawComponents[0,2]:=RawComponents[0,2];
 result.RawComponents[0,3]:=0.0;
 result.RawComponents[1,0]:=RawComponents[1,0];
 result.RawComponents[1,1]:=RawComponents[1,1];
 result.RawComponents[1,2]:=RawComponents[1,2];
 result.RawComponents[1,3]:=0.0;
 result.RawComponents[2,0]:=RawComponents[2,0];
 result.RawComponents[2,1]:=RawComponents[2,1];
 result.RawComponents[2,2]:=RawComponents[2,2];
 result.RawComponents[2,3]:=0.0;
 result.RawComponents[3,0]:=0.0;
 result.RawComponents[3,1]:=0.0;
 result.RawComponents[3,2]:=0.0;
 result.RawComponents[3,3]:=1.0;
end;

function TpvMatrix4x4.SimpleLerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result:=(self*(1.0-t))+(b*t);
 end;
end;

function TpvMatrix4x4.SimpleNlerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4;
var InvT:TpvScalar;
    Scale:TpvVector3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  Scale:=TpvVector3.Create(Right.xyz.Length,
                           Up.xyz.Length,
                           Forwards.xyz.Length).Lerp(TpvVector3.Create(b.Right.xyz.Length,
                                                                       b.Up.xyz.Length,
                                                                       b.Forwards.xyz.Length),
                                                     t);
  result:=TpvMatrix4x4.CreateFromQuaternion(Normalize.ToQuaternion.Nlerp(b.Normalize.ToQuaternion,t));
  result.Right.xyz:=result.Right.xyz*Scale.x;
  result.Up.xyz:=result.Up.xyz*Scale.y;
  result.Forwards.xyz:=result.Forwards.xyz*Scale.z;
  result.Translation:=Translation.Lerp(b.Translation,t);
  InvT:=1.0-t;
  result[0,3]:=(RawComponents[0,3]*InvT)+(b.RawComponents[0,3]*t);
  result[1,3]:=(RawComponents[1,3]*InvT)+(b.RawComponents[1,3]*t);
  result[2,3]:=(RawComponents[2,3]*InvT)+(b.RawComponents[2,3]*t);
 end;
end;

function TpvMatrix4x4.SimpleSlerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4;
var InvT:TpvScalar;
    Scale:TpvVector3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  Scale:=TpvVector3.Create(Right.xyz.Length,
                           Up.xyz.Length,
                           Forwards.xyz.Length).Lerp(TpvVector3.Create(b.Right.xyz.Length,
                                                                       b.Up.xyz.Length,
                                                                       b.Forwards.xyz.Length),
                                                     t);
  result:=TpvMatrix4x4.CreateFromQuaternion(Normalize.ToQuaternion.Slerp(b.Normalize.ToQuaternion,t));
  result.Right.xyz:=result.Right.xyz*Scale.x;
  result.Up.xyz:=result.Up.xyz*Scale.y;
  result.Forwards.xyz:=result.Forwards.xyz*Scale.z;
  result.Translation:=Translation.Lerp(b.Translation,t);
  InvT:=1.0-t;
  result[0,3]:=(RawComponents[0,3]*InvT)+(b.RawComponents[0,3]*t);
  result[1,3]:=(RawComponents[1,3]*InvT)+(b.RawComponents[1,3]*t);
  result[2,3]:=(RawComponents[2,3]*InvT)+(b.RawComponents[2,3]*t);
 end;
end;

function TpvMatrix4x4.SimpleElerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4;
var InvT:TpvScalar;
    Scale:TpvVector3;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  Scale:=TpvVector3.Create(Right.xyz.Length,
                           Up.xyz.Length,
                           Forwards.xyz.Length).Lerp(TpvVector3.Create(b.Right.xyz.Length,
                                                                       b.Up.xyz.Length,
                                                                       b.Forwards.xyz.Length),
                                                     t);
  result:=TpvMatrix4x4.CreateFromQuaternion(Normalize.ToQuaternion.Elerp(b.Normalize.ToQuaternion,t));
  result.Right.xyz:=result.Right.xyz*Scale.x;
  result.Up.xyz:=result.Up.xyz*Scale.y;
  result.Forwards.xyz:=result.Forwards.xyz*Scale.z;
  result.Translation:=Translation.Lerp(b.Translation,t);
  InvT:=1.0-t;
  result[0,3]:=(RawComponents[0,3]*InvT)+(b.RawComponents[0,3]*t);
  result[1,3]:=(RawComponents[1,3]*InvT)+(b.RawComponents[1,3]*t);
  result[2,3]:=(RawComponents[2,3]*InvT)+(b.RawComponents[2,3]*t);
 end;
end;

function TpvMatrix4x4.SimpleSqlerp(const aB,aC,aD:TpvMatrix4x4;const aTime:TpvScalar):TpvMatrix4x4;
begin
 result:=SimpleSlerp(aD,aTime).SimpleSlerp(aB.SimpleSlerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

function TpvMatrix4x4.Lerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result:=TpvMatrix4x4.CreateRecomposed(Decompose.Lerp(b.Decompose,t));
 end;
end;

function TpvMatrix4x4.Nlerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result:=TpvMatrix4x4.CreateRecomposed(Decompose.Nlerp(b.Decompose,t));
 end;
end;

function TpvMatrix4x4.Slerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result:=TpvMatrix4x4.CreateRecomposed(Decompose.Slerp(b.Decompose,t));
 end;
end;

function TpvMatrix4x4.Elerp(const b:TpvMatrix4x4;const t:TpvScalar):TpvMatrix4x4;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result:=TpvMatrix4x4.CreateRecomposed(Decompose.Elerp(b.Decompose,t));
 end;
end;

function TpvMatrix4x4.Sqlerp(const aB,aC,aD:TpvMatrix4x4;const aTime:TpvScalar):TpvMatrix4x4;
begin
 result:=Slerp(aD,aTime).Slerp(aB.Slerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

function TpvMatrix4x4.MulInverse({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3;
{var d:TpvScalar;
begin
 d:=((RawComponents[0,0]*((RawComponents[1,1]*RawComponents[2,2])-(RawComponents[2,1]*RawComponents[1,2])))-
     (RawComponents[0,1]*((RawComponents[1,0]*RawComponents[2,2])-(RawComponents[2,0]*RawComponents[1,2]))))+
     (RawComponents[0,2]*((RawComponents[1,0]*RawComponents[2,1])-(RawComponents[2,0]*RawComponents[1,1])));
 if d<>0.0 then begin
  d:=1.0/d;
 end;
 result.x:=((a.x*((RawComponents[1,1]*RawComponents[2,2])-(RawComponents[1,2]*RawComponents[2,1])))+(a.y*((RawComponents[1,2]*RawComponents[2,0])-(RawComponents[1,0]*RawComponents[2,2])))+(a.z*((RawComponents[1,0]*RawComponents[2,1])-(RawComponents[1,1]*RawComponents[2,0]))))*d;
 result.y:=((RawComponents[0,0]*((a.y*RawComponents[2,2])-(a.z*RawComponents[2,1])))+(RawComponents[0,1]*((a.z*RawComponents[2,0])-(a.x*RawComponents[2,2])))+(RawComponents[0,2]*((a.x*RawComponents[2,1])-(a.y*RawComponents[2,0]))))*d;
 result.z:=((RawComponents[0,0]*((RawComponents[1,1]*a.z)-(RawComponents[1,2]*a.y)))+(RawComponents[0,1]*((RawComponents[1,2]*a.x)-(RawComponents[1,0]*a.z)))+(RawComponents[0,2]*((RawComponents[1,0]*a.y)-(RawComponents[1,1]*a.x))))*d;
end;}
begin
 result:=Inverse*a;
end;

function TpvMatrix4x4.MulInverse({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4;
{var d:TpvScalar;
begin
 d:=((RawComponents[0,0]*((RawComponents[1,1]*RawComponents[2,2])-(RawComponents[2,1]*RawComponents[1,2])))-
     (RawComponents[0,1]*((RawComponents[1,0]*RawComponents[2,2])-(RawComponents[2,0]*RawComponents[1,2]))))+
     (RawComponents[0,2]*((RawComponents[1,0]*RawComponents[2,1])-(RawComponents[2,0]*RawComponents[1,1])));
 if d<>0.0 then begin
  d:=1.0/d;
 end;
 result.x:=((a.x*((RawComponents[1,1]*RawComponents[2,2])-(RawComponents[1,2]*RawComponents[2,1])))+(a.y*((RawComponents[1,2]*RawComponents[2,0])-(RawComponents[1,0]*RawComponents[2,2])))+(a.z*((RawComponents[1,0]*RawComponents[2,1])-(RawComponents[1,1]*RawComponents[2,0]))))*d;
 result.y:=((RawComponents[0,0]*((a.y*RawComponents[2,2])-(a.z*RawComponents[2,1])))+(RawComponents[0,1]*((a.z*RawComponents[2,0])-(a.x*RawComponents[2,2])))+(RawComponents[0,2]*((a.x*RawComponents[2,1])-(a.y*RawComponents[2,0]))))*d;
 result.z:=((RawComponents[0,0]*((RawComponents[1,1]*a.z)-(RawComponents[1,2]*a.y)))+(RawComponents[0,1]*((RawComponents[1,2]*a.x)-(RawComponents[1,0]*a.z)))+(RawComponents[0,2]*((RawComponents[1,0]*a.y)-(RawComponents[1,1]*a.x))))*d;
 result.w:=a.w;
end;}
begin
 result:=Inverse*a;
end;

function TpvMatrix4x4.MulInverted({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3;
var p:TpvVector3;
begin
 p.x:=a.x-RawComponents[3,0];
 p.y:=a.y-RawComponents[3,1];
 p.z:=a.z-RawComponents[3,2];
 result.x:=(RawComponents[0,0]*p.x)+(RawComponents[0,1]*p.y)+(RawComponents[0,2]*p.z);
 result.y:=(RawComponents[1,0]*p.x)+(RawComponents[1,1]*p.y)+(RawComponents[1,2]*p.z);
 result.z:=(RawComponents[2,0]*p.x)+(RawComponents[2,1]*p.y)+(RawComponents[2,2]*p.z);
end;

function TpvMatrix4x4.MulInverted({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4;
var p:TpvVector3;
begin
 p.x:=a.x-RawComponents[3,0];
 p.y:=a.y-RawComponents[3,1];
 p.z:=a.z-RawComponents[3,2];
 result.x:=(RawComponents[0,0]*p.x)+(RawComponents[0,1]*p.y)+(RawComponents[0,2]*p.z);
 result.y:=(RawComponents[1,0]*p.x)+(RawComponents[1,1]*p.y)+(RawComponents[1,2]*p.z);
 result.z:=(RawComponents[2,0]*p.x)+(RawComponents[2,1]*p.y)+(RawComponents[2,2]*p.z);
 result.w:=a.w;
end;

function TpvMatrix4x4.MulBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3;
begin
 result.x:=(RawComponents[0,0]*a.x)+(RawComponents[1,0]*a.y)+(RawComponents[2,0]*a.z);
 result.y:=(RawComponents[0,1]*a.x)+(RawComponents[1,1]*a.y)+(RawComponents[2,1]*a.z);
 result.z:=(RawComponents[0,2]*a.x)+(RawComponents[1,2]*a.y)+(RawComponents[2,2]*a.z);
end;

function TpvMatrix4x4.MulBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4;
begin
 result.x:=(RawComponents[0,0]*a.x)+(RawComponents[1,0]*a.y)+(RawComponents[2,0]*a.z);
 result.y:=(RawComponents[0,1]*a.x)+(RawComponents[1,1]*a.y)+(RawComponents[2,1]*a.z);
 result.z:=(RawComponents[0,2]*a.x)+(RawComponents[1,2]*a.y)+(RawComponents[2,2]*a.z);
 result.w:=a.w;
end;

function TpvMatrix4x4.MulAbsBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3;
begin
 result.x:=(abs(RawComponents[0,0])*a.x)+(abs(RawComponents[1,0])*a.y)+(abs(RawComponents[2,0])*a.z);
 result.y:=(abs(RawComponents[0,1])*a.x)+(abs(RawComponents[1,1])*a.y)+(abs(RawComponents[2,1])*a.z);
 result.z:=(abs(RawComponents[0,2])*a.x)+(abs(RawComponents[1,2])*a.y)+(abs(RawComponents[2,2])*a.z);
end;

function TpvMatrix4x4.MulAbsBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4;
begin
 result.x:=(abs(RawComponents[0,0])*a.x)+(abs(RawComponents[1,0])*a.y)+(abs(RawComponents[2,0])*a.z);
 result.y:=(abs(RawComponents[0,1])*a.x)+(abs(RawComponents[1,1])*a.y)+(abs(RawComponents[2,1])*a.z);
 result.z:=(abs(RawComponents[0,2])*a.x)+(abs(RawComponents[1,2])*a.y)+(abs(RawComponents[2,2])*a.z);
 result.w:=a.w;
end;

function TpvMatrix4x4.MulTransposedBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3;
begin
 result.x:=(RawComponents[0,0]*a.x)+(RawComponents[0,1]*a.y)+(RawComponents[0,2]*a.z);
 result.y:=(RawComponents[1,0]*a.x)+(RawComponents[1,1]*a.y)+(RawComponents[1,2]*a.z);
 result.z:=(RawComponents[2,0]*a.x)+(RawComponents[2,1]*a.y)+(RawComponents[2,2]*a.z);
end;

function TpvMatrix4x4.MulTransposedBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4;
begin
 result.x:=(RawComponents[0,0]*a.x)+(RawComponents[0,1]*a.y)+(RawComponents[0,2]*a.z);
 result.y:=(RawComponents[1,0]*a.x)+(RawComponents[1,1]*a.y)+(RawComponents[1,2]*a.z);
 result.z:=(RawComponents[2,0]*a.x)+(RawComponents[2,1]*a.y)+(RawComponents[2,2]*a.z);
 result.w:=a.w;
end;

function TpvMatrix4x4.MulHomogen({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3):TpvVector3;
var Temporary:TpvVector4;
begin
 Temporary:=self*TpvVector4.InlineableCreate(a,1.0);
 result:=Temporary.xyz/Temporary.w;
end;

function TpvMatrix4x4.MulHomogen({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4):TpvVector4;
begin
 result:=self*a;
 result:=result/result.w;
end;

function TpvMatrix4x4.Decompose:TpvDecomposedMatrix4x4;
var LocalMatrix,PerspectiveMatrix:TpvMatrix4x4;
    BasisMatrix:TpvMatrix3x3;
begin

 if RawComponents[3,3]=0.0 then begin

  result.Valid:=false;

 end else if (RawComponents[0,0]=1.0) and
             (RawComponents[0,1]=0.0) and
             (RawComponents[0,2]=0.0) and
             (RawComponents[0,3]=0.0) and
             (RawComponents[1,0]=0.0) and
             (RawComponents[1,1]=1.0) and
             (RawComponents[1,2]=0.0) and
             (RawComponents[1,3]=0.0) and
             (RawComponents[2,0]=0.0) and
             (RawComponents[2,1]=0.0) and
             (RawComponents[2,2]=1.0) and
             (RawComponents[2,3]=0.0) and
             (RawComponents[3,0]=0.0) and
             (RawComponents[3,1]=0.0) and
             (RawComponents[3,2]=0.0) and
             (RawComponents[3,3]=1.0) then begin

  result.Perspective:=TpvVector4.Create(0.0,0.0,0.0,1.0);
  result.Translation:=TpvVector3.Create(0.0,0.0,0.0);
  result.Scale:=TpvVector3.Create(1.0,1.0,1.0);
  result.Skew:=TpvVector3.Create(0.0,0.0,0.0);
  result.Rotation:=TpvQuaternion.Create(0.0,0.0,0.0,1.0);

  result.Valid:=true;

 end else begin

  LocalMatrix.Tangent:=Tangent/RawComponents[3,3];
  LocalMatrix.Bitangent:=Bitangent/RawComponents[3,3];
  LocalMatrix.Normal:=Normal/RawComponents[3,3];
  LocalMatrix.Translation:=Translation/RawComponents[3,3];

  PerspectiveMatrix:=LocalMatrix;
  PerspectiveMatrix.RawComponents[0,3]:=0.0;
  PerspectiveMatrix.RawComponents[1,3]:=0.0;
  PerspectiveMatrix.RawComponents[2,3]:=0.0;
  PerspectiveMatrix.RawComponents[3,3]:=1.0;

  if PerspectiveMatrix.Determinant=0.0 then begin

   result.Valid:=false;

  end else begin

   if (LocalMatrix.RawComponents[0,3]<>0.0) or
      (LocalMatrix.RawComponents[1,3]<>0.0) or
      (LocalMatrix.RawComponents[2,3]<>0.0) then begin

    result.Perspective:=PerspectiveMatrix.Inverse.Transpose*TpvVector4.Create(LocalMatrix.RawComponents[0,3],
                                                                              LocalMatrix.RawComponents[1,3],
                                                                              LocalMatrix.RawComponents[2,3],
                                                                              LocalMatrix.RawComponents[3,3]);

    LocalMatrix.RawComponents[0,3]:=0.0;
    LocalMatrix.RawComponents[1,3]:=0.0;
    LocalMatrix.RawComponents[2,3]:=0.0;
    LocalMatrix.RawComponents[3,3]:=1.0;

   end else begin
    result.Perspective.x:=0.0;
    result.Perspective.y:=0.0;
    result.Perspective.z:=0.0;
    result.Perspective.w:=1.0;
   end;

   result.Translation:=LocalMatrix.Translation.xyz;
   LocalMatrix.Translation.xyz:=TpvVector3.Create(0.0,0.0,0.0);

   BasisMatrix:=ToMatrix3x3;

   result.Scale.x:=BasisMatrix.Right.Length;
   BasisMatrix.Right:=BasisMatrix.Right.Normalize;

   result.Skew.x:=BasisMatrix.Right.Dot(BasisMatrix.Up);
   BasisMatrix.Up:=BasisMatrix.Up-(BasisMatrix.Right*result.Skew.x);

   result.Scale.y:=BasisMatrix.Up.Length;
   BasisMatrix.Up:=BasisMatrix.Up.Normalize;

   result.Skew.x:=result.Skew.x/result.Scale.y;

   result.Skew.y:=BasisMatrix.Right.Dot(BasisMatrix.Forwards);
   BasisMatrix.Forwards:=BasisMatrix.Forwards-(BasisMatrix.Right*result.Skew.y);
   result.Skew.z:=BasisMatrix.Up.Dot(BasisMatrix.Forwards);
   BasisMatrix.Forwards:=BasisMatrix.Forwards-(BasisMatrix.Up*result.Skew.z);

   result.Scale.z:=BasisMatrix.Forwards.Length;
   BasisMatrix.Forwards:=BasisMatrix.Forwards.Normalize;

   result.Skew.yz:=result.Skew.yz/result.Scale.z;

   if BasisMatrix.Right.Dot(BasisMatrix.Up.Cross(BasisMatrix.Forwards))<0.0 then begin
    result.Scale.x:=-result.Scale.x;
    BasisMatrix:=-BasisMatrix;
   end;

   result.Rotation:=BasisMatrix.ToQuaternion;

   result.Valid:=true;

  end;

 end;

end;

constructor TpvDualQuaternion.Create(const pQ0,PQ1:TpvQuaternion);
begin
 RawQuaternions[0]:=pQ0;
 RawQuaternions[1]:=pQ1;
end;

constructor TpvDualQuaternion.CreateFromRotationTranslationScale(const pRotation:TpvQuaternion;const pTranslation:TpvVector3;const pScale:TpvScalar);
begin
 RawQuaternions[0]:=pRotation.Normalize;
 RawQuaternions[1]:=((0.5/RawQuaternions[0].Length)*RawQuaternions[0])*TpvQuaternion.Create(pTranslation.x,pTranslation.y,pTranslation.z,0.0);
 RawQuaternions[0]:=RawQuaternions[0]*pScale;
end;

constructor TpvDualQuaternion.CreateFromMatrix(const pMatrix:TpvMatrix4x4);
begin
 RawQuaternions[0]:=pMatrix.ToQuaternion;
 RawQuaternions[1]:=((0.5/RawQuaternions[0].Length)*RawQuaternions[0])*TpvQuaternion.Create(pMatrix.Translation.x,pMatrix.Translation.y,pMatrix.Translation.z,0.0);
 RawQuaternions[0]:=RawQuaternions[0]*((pMatrix.Right.xyz.Length+pMatrix.Up.xyz.Length+pMatrix.Forwards.xyz.Length)/3.0);
end;

class operator TpvDualQuaternion.Implicit(const a:TpvMatrix4x4):TpvDualQuaternion;
begin
 result:=TpvDualQuaternion.CreateFromMatrix(a);
end;

class operator TpvDualQuaternion.Explicit(const a:TpvMatrix4x4):TpvDualQuaternion;
begin
 result:=TpvDualQuaternion.CreateFromMatrix(a);
end;

class operator TpvDualQuaternion.Implicit(const a:TpvDualQuaternion):TpvMatrix4x4;
var Scale:TpvScalar;
begin
 Scale:=a.RawQuaternions[0].Length;
 result:=TpvMatrix4x4.CreateFromQuaternion(a.RawQuaternions[0].Normalize);
 result.Right.xyz:=result.Right.xyz*Scale;
 result.Up.xyz:=result.Up.xyz*Scale;
 result.Forwards.xyz:=result.Forwards.xyz*Scale;
 result.Translation.xyz:=TpvQuaternion((2.0*a.RawQuaternions[0].Conjugate)*a.RawQuaternions[1]).Vector.xyz;
end;

class operator TpvDualQuaternion.Explicit(const a:TpvDualQuaternion):TpvMatrix4x4;
var Scale:TpvScalar;
begin
 Scale:=a.RawQuaternions[0].Length;
 result:=TpvMatrix4x4.CreateFromQuaternion(a.RawQuaternions[0].Normalize);
 result.Right.xyz:=result.Right.xyz*Scale;
 result.Up.xyz:=result.Up.xyz*Scale;
 result.Forwards.xyz:=result.Forwards.xyz*Scale;
 result.Translation.xyz:=TpvQuaternion((2.0*a.RawQuaternions[0].Conjugate)*a.RawQuaternions[1]).Vector.xyz;
end;

class operator TpvDualQuaternion.Equal(const a,b:TpvDualQuaternion):boolean;
begin
 result:=(a.RawQuaternions[0]=b.RawQuaternions[0]) and
         (a.RawQuaternions[1]=b.RawQuaternions[1]);
end;

class operator TpvDualQuaternion.NotEqual(const a,b:TpvDualQuaternion):boolean;
begin
 result:=(a.RawQuaternions[0]<>b.RawQuaternions[0]) or
         (a.RawQuaternions[1]<>b.RawQuaternions[1]);
end;

class operator TpvDualQuaternion.Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvDualQuaternion):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=a.RawQuaternions[0]+b.RawQuaternions[0];
 result.RawQuaternions[1]:=a.RawQuaternions[1]+b.RawQuaternions[1];
end;

class operator TpvDualQuaternion.Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvDualQuaternion):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=a.RawQuaternions[0]-b.RawQuaternions[0];
 result.RawQuaternions[1]:=a.RawQuaternions[1]-b.RawQuaternions[1];
end;

class operator TpvDualQuaternion.Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvDualQuaternion):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=a.RawQuaternions[0]*b.RawQuaternions[0];
 result.RawQuaternions[1]:=((a.RawQuaternions[0]*b.RawQuaternions[1])/a.RawQuaternions[0].Length)+(a.RawQuaternions[1]*b.RawQuaternions[1]);
end;

class operator TpvDualQuaternion.Multiply(const a:TpvDualQuaternion;const b:TpvScalar):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=a.RawQuaternions[0]*b;
 result.RawQuaternions[1]:=a.RawQuaternions[1]*b;
end;

class operator TpvDualQuaternion.Multiply(const a:TpvScalar;const b:TpvDualQuaternion):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=a*b.RawQuaternions[0];
 result.RawQuaternions[1]:=a*b.RawQuaternions[1];
end;

class operator TpvDualQuaternion.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvDualQuaternion;{$ifdef fpc}constref{$else}const{$endif} b:TpvVector3):TpvVector3;
begin
 result:=TpvQuaternion(a.RawQuaternions[0].Conjugate*((2.0*a.RawQuaternions[1])+(TpvQuaternion.Create(b.x,b.y,b.z,0.0)*a.RawQuaternions[0]))).Vector.xyz;
end;

class operator TpvDualQuaternion.Multiply(const a:TpvVector3;const b:TpvDualQuaternion):TpvVector3;
begin
 result:=b.Inverse*a;
end;

class operator TpvDualQuaternion.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvDualQuaternion;{$ifdef fpc}constref{$else}const{$endif} b:TpvVector4):TpvVector4;
begin
 result.xyz:=TpvQuaternion(a.RawQuaternions[0].Conjugate*((2.0*a.RawQuaternions[1])+(TpvQuaternion.Create(b.x,b.y,b.z,0.0)*a.RawQuaternions[0]))).Vector.xyz;
 result.w:=1.0;
end;

class operator TpvDualQuaternion.Multiply(const a:TpvVector4;const b:TpvDualQuaternion):TpvVector4;
begin
 result:=b.Inverse*a;
end;

class operator TpvDualQuaternion.Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvDualQuaternion):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=a.RawQuaternions[0]/b.RawQuaternions[0];
 result.RawQuaternions[1]:=a.RawQuaternions[1]/b.RawQuaternions[1];
end;

class operator TpvDualQuaternion.Divide(const a:TpvDualQuaternion;const b:TpvScalar):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=a.RawQuaternions[0]/b;
 result.RawQuaternions[1]:=a.RawQuaternions[1]/b;
end;

class operator TpvDualQuaternion.Divide(const a:TpvScalar;const b:TpvDualQuaternion):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=a/b.RawQuaternions[0];
 result.RawQuaternions[1]:=a/b.RawQuaternions[1];
end;

class operator TpvDualQuaternion.IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvDualQuaternion):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=a.RawQuaternions[0]/b.RawQuaternions[0];
 result.RawQuaternions[1]:=a.RawQuaternions[1]/b.RawQuaternions[1];
end;

class operator TpvDualQuaternion.IntDivide(const a:TpvDualQuaternion;const b:TpvScalar):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=a.RawQuaternions[0]/b;
 result.RawQuaternions[1]:=a.RawQuaternions[1]/b;
end;

class operator TpvDualQuaternion.IntDivide(const a:TpvScalar;const b:TpvDualQuaternion):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=a/b.RawQuaternions[0];
 result.RawQuaternions[1]:=a/b.RawQuaternions[1];
end;

class operator TpvDualQuaternion.Modulus(const a,b:TpvDualQuaternion):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=a.RawQuaternions[0] mod b.RawQuaternions[0];
 result.RawQuaternions[1]:=a.RawQuaternions[1] mod b.RawQuaternions[1];
end;

class operator TpvDualQuaternion.Modulus(const a:TpvDualQuaternion;const b:TpvScalar):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=a.RawQuaternions[0] mod b;
 result.RawQuaternions[1]:=a.RawQuaternions[1] mod b;
end;

class operator TpvDualQuaternion.Modulus(const a:TpvScalar;const b:TpvDualQuaternion):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=a mod b.RawQuaternions[0];
 result.RawQuaternions[1]:=a mod b.RawQuaternions[1];
end;

class operator TpvDualQuaternion.Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvDualQuaternion):TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=-a.RawQuaternions[0];
 result.RawQuaternions[1]:=-a.RawQuaternions[1];
end;

class operator TpvDualQuaternion.Positive(const a:TpvDualQuaternion):TpvDualQuaternion;
begin
 result:=a;
end;

function TpvDualQuaternion.Flip:TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=RawQuaternions[0].Flip;
 result.RawQuaternions[1]:=RawQuaternions[1].Flip;
end;

function TpvDualQuaternion.Conjugate:TpvDualQuaternion;
begin
 result.RawQuaternions[0].x:=-RawQuaternions[0].x;
 result.RawQuaternions[0].y:=-RawQuaternions[0].y;
 result.RawQuaternions[0].z:=-RawQuaternions[0].z;
 result.RawQuaternions[0].w:=RawQuaternions[0].w;
 result.RawQuaternions[1].x:=RawQuaternions[1].x;
 result.RawQuaternions[1].y:=RawQuaternions[1].y;
 result.RawQuaternions[1].z:=RawQuaternions[1].z;
 result.RawQuaternions[1].w:=-RawQuaternions[1].w;
end;

function TpvDualQuaternion.Inverse:TpvDualQuaternion;
begin
 result.RawQuaternions[0]:=RawQuaternions[0].Conjugate;
 result.RawQuaternions[1]:=((-result.RawQuaternions[0])*RawQuaternions[1])*result.RawQuaternions[0];
 result:=result/RawQuaternions[0].Length;
end;

function TpvDualQuaternion.Normalize:TpvDualQuaternion;
var Scale:TpvScalar;
begin
 Scale:=RawQuaternions[0].Length;
 result.RawQuaternions[0]:=RawQuaternions[0]/Scale;
 result.RawQuaternions[1]:=RawQuaternions[1]/Scale;
 result.RawQuaternions[1]:=result.RawQuaternions[1]-(result.RawQuaternions[0].Dot(result.RawQuaternions[1])*result.RawQuaternions[0]);
end;

constructor TpvSegment.Create(const p0,p1:TpvVector3);
begin
 Points[0]:=p0;
 Points[1]:=p1;
end;

function TpvSegment.SquaredDistanceTo(const p:TpvVector3):TpvScalar;
var pq,pp:TpvVector3;
    e,f:TpvScalar;
begin
 pq:=Points[1]-Points[0];
 pp:=p-Points[0];
 e:=pp.Dot(pq);
 if e<=0.0 then begin
  result:=pp.SquaredLength;
 end else begin
  f:=pq.SquaredLength;
  if e<f then begin
   result:=pp.SquaredLength-(sqr(e)/f);
  end else begin
   result:=(p-Points[1]).SquaredLength;
  end;
 end;
end;

function TpvSegment.SquaredDistanceTo(const p:TpvVector3;out Nearest:TpvVector3):TpvScalar;
var t,DotUV:TpvScalar;
    Diff,v:TpvVector3;
begin
 Diff:=p-Points[0];
 v:=Points[1]-Points[0];
 t:=v.Dot(Diff);
 if t>0.0 then begin
  DotUV:=v.SquaredLength;
  if t<DotUV then begin
   t:=t/DotUV;
   Diff:=Diff-(v*t);
  end else begin
   t:=1;
   Diff:=Diff-v;
  end;
 end else begin
  t:=0.0;
 end;
 Nearest:=Points[0].Lerp(Points[1],t);
 result:=Diff.SquaredLength;
end;

procedure TpvSegment.ClosestPointTo(const p:TpvVector3;out Time:TpvScalar;out ClosestPoint:TpvVector3);
var u,v:TpvVector3;
begin
 u:=Points[1]-Points[0];
 v:=p-Points[0];
 Time:=u.Dot(v)/u.SquaredLength;
 if Time<=0.0 then begin
  ClosestPoint:=Points[0];
 end else if Time>=1.0 then begin
  ClosestPoint:=Points[1];
 end else begin
  ClosestPoint:=(Points[0]*(1.0-Time))+(Points[1]*Time);
 end;
end;

function TpvSegment.Transform(const Transform:TpvMatrix4x4):TpvSegment;
begin
 result.Points[0]:=Transform*Points[0];
 result.Points[1]:=Transform*Points[1];
end;

procedure TpvSegment.ClosestPoints(const SegmentB:TpvSegment;out TimeA:TpvScalar;out ClosestPointA:TpvVector3;out TimeB:TpvScalar;out ClosestPointB:TpvVector3);
var dA,dB,r:TpvVector3;
    a,b,c,{d,}e,f,Denominator,aA,aB,bA,bB:TpvScalar;
begin
 dA:=Points[1]-Points[0];
 dB:=SegmentB.Points[1]-SegmentB.Points[0];
 r:=Points[0]-SegmentB.Points[0];
 a:=dA.SquaredLength;
 e:=dB.SquaredLength;
 f:=dB.Dot(r);
 if (a<EPSILON) and (e<EPSILON) then begin
  // segment a and b are both points
  TimeA:=0.0;
  TimeB:=0.0;
  ClosestPointA:=Points[0];
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
   c:=dA.Dot(r);
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
    b:=dA.Dot(dB);
    Denominator:=(a*e)-sqr(b);
		if Denominator<EPSILON then begin
     // segments are parallel
     aA:=dB.Dot(Points[0]);
     aB:=dB.Dot(Points[1]);
     bA:=dB.Dot(SegmentB.Points[0]);
     bB:=dB.Dot(SegmentB.Points[1]);
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
      ClosestPointB:=SegmentB.Points[0]+(dB*TimeB);
      ClosestPointTo(ClosestPointB,TimeB,ClosestPointA);
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
  ClosestPointA:=Points[0]+(dA*TimeA);
  ClosestPointB:=SegmentB.Points[0]+(dB*TimeB);
 end;
end;

function TpvSegment.Intersect(const SegmentB:TpvSegment;out TimeA,TimeB:TpvScalar;out IntersectionPoint:TpvVector3):boolean;
var PointA:TpvVector3;
begin
 ClosestPoints(SegmentB,TimeA,PointA,TimeB,IntersectionPoint);
 result:=(PointA-IntersectionPoint).SquaredLength<EPSILON;
end;

function TpvRelativeSegment.SquaredSegmentDistanceTo(const pOtherRelativeSegment:TpvRelativeSegment;out t0,t1:TpvScalar):TpvScalar;
var kDiff:TpvVector3;
    fA00,fA01,fA11,fB0,fC,fDet,fB1,fS,fT,fSqrDist,fTmp,fInvDet:TpvScalar;
begin
 kDiff:=self.Origin-pOtherRelativeSegment.Origin;
 fA00:=self.Delta.SquaredLength;
 fA01:=-self.Delta.Dot(pOtherRelativeSegment.Delta);
 fA11:=pOtherRelativeSegment.Delta.SquaredLength;
 fB0:=kDiff.Dot(self.Delta);
 fC:=kDiff.SquaredLength;
 fDet:=abs((fA00*fA11)-(fA01*fA01));
 if fDet>=EPSILON then begin
  // line segments are not parallel
  fB1:=-kDiff.Dot(pOtherRelativeSegment.Delta);
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
    fB1:=-kDiff.Dot(pOtherRelativeSegment.Delta);
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
    fB1:=-kDiff.Dot(pOtherRelativeSegment.Delta);
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

constructor TpvTriangle.Create(const pA,pB,pC:TpvVector3);
begin
 Points[0]:=pA;
 Points[1]:=pB;
 Points[2]:=pC;
 Normal:=((pB-pA).Cross(pC-pA)).Normalize;
end;

function TpvTriangle.Contains(const p:TpvVector3):boolean;
var vA,vB,vC:TpvVector3;
    dAB,dAC,dBC:TpvScalar;
begin
 vA:=Points[0]-p;
 vB:=Points[1]-p;
 vC:=Points[2]-p;
 dAB:=vA.Dot(vB);
 dAC:=vA.Dot(vC);
 dBC:=vB.Dot(vC);
 if ((dBC*dAC)-(vC.SquaredLength*dAB))<0.0 then begin
  result:=false;
 end else begin
  result:=((dAB*dBC)-(dAC*vB.SquaredLength))>=0.0;
 end;
end;

procedure TpvTriangle.ProjectToVector(const Vector:TpvVector3;out TriangleMin,TriangleMax:TpvScalar);
var Projection:TpvScalar;
begin
 Projection:=Vector.Dot(Points[0]);
 TriangleMin:=Projection;
 TriangleMax:=Projection;
 Projection:=Vector.Dot(Points[1]);
 TriangleMin:=Min(TriangleMin,Projection);
 TriangleMax:=Max(TriangleMax,Projection);
 Projection:=Vector.Dot(Points[2]);
 TriangleMin:=Min(TriangleMin,Projection);
 TriangleMax:=Max(TriangleMax,Projection);
end;

function TpvTriangle.ProjectToPoint(var pPoint:TpvVector3;out s,t:TpvScalar):TpvScalar;
var Diff,Edge0,Edge1:TpvVector3;
    A00,A01,A11,B0,C,Det,B1,SquaredDistance,InvDet,Tmp0,Tmp1,Numer,Denom:TpvScalar;
begin
 Diff:=Points[0]-pPoint;
 Edge0:=Points[1]-Points[0];
 Edge1:=Points[2]-Points[0];
 A00:=Edge0.SquaredLength;
 A01:=Edge0.Dot(Edge1);
 A11:=Edge1.SquaredLength;
 B0:=Diff.Dot(Edge0);
 B1:=Diff.Dot(Edge1);
 C:=Diff.SquaredLength;
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
 pPoint.x:=Points[0].x+((Edge0.x*s)+(Edge1.x*t));
 pPoint.y:=Points[0].y+((Edge0.y*s)+(Edge1.y*t));
 pPoint.z:=Points[0].z+((Edge0.z*s)+(Edge1.z*t));
 result:=abs(SquaredDistance);
end;

function TpvTriangle.SegmentIntersect(const Segment:TpvSegment;out Time:TpvScalar;out IntersectionPoint:TpvVector3):boolean;
var Switched:boolean;
    d,t,v,w:TpvScalar;
    vAB,vAC,pBA,vApA,e,n:TpvVector3;
    s:TpvSegment;
begin

 result:=false;

 Time:=NaN;

 IntersectionPoint:=TpvVector3.Origin;

 Switched:=false;

 vAB:=Points[1]-Points[0];
 vAC:=Points[2]-Points[0];

 pBA:=Segment.Points[0]-Segment.Points[1];

 n:=vAB.Cross(vAC);

 d:=n.Dot(pBA);

 if abs(d)<EPSILON then begin
  exit; // segment is parallel
 end else if d<0.0 then begin
  s.Points[0]:=Segment.Points[1];
  s.Points[1]:=Segment.Points[0];
  Switched:=true;
  pBA:=s.Points[0]-s.Points[1];
  d:=-d;
 end else begin
  s:=Segment;
 end;

 vApA:=s.Points[0]-Points[0];
 t:=n.Dot(vApA);
 e:=pBA.Cross(vApA);

 v:=vAC.Dot(e);
 if (v<0.0) or (v>d) then begin
  exit; // intersects outside triangle
 end;

 w:=-vAB.Dot(e);
 if (w<0.0) or ((v+w)>d) then begin
  exit; // intersects outside triangle
 end;

 d:=1.0/d;
 t:=t*d;
 v:=v*d;
 w:=w*d;
 Time:=t;

 IntersectionPoint:=Points[0]+((vAB*v)+(vAC*w));

 if Switched then begin
	Time:=1.0-Time;
 end;

 result:=(Time>=0.0) and (Time<=1.0);
end;

function TpvTriangle.ClosestPointTo(const Point:TpvVector3;out ClosestPoint:TpvVector3):boolean;
var u,v,w,d1,d2,d3,d4,d5,d6,Denominator:TpvScalar;
    vAB,vAC,vAp,vBp,vCp:TpvVector3;
begin
 result:=false;

 vAB:=Points[1]-Points[0];
 vAC:=Points[2]-Points[0];
 vAp:=Point-Points[0];

 d1:=vAB.Dot(vAp);
 d2:=vAC.Dot(vAp);
 if (d1<=0.0) and (d2<=0.0) then begin
	ClosestPoint:=Points[0]; // closest point is vertex A
	exit;
 end;

 vBp:=Point-Points[1];
 d3:=vAB.Dot(vBp);
 d4:=vAC.Dot(vBp);
 if (d3>=0.0) and (d4<=d3) then begin
	ClosestPoint:=Points[1]; // closest point is vertex B
	exit;
 end;

 w:=(d1*d4)-(d3*d2);
 if (w<=0.0) and (d1>=0.0) and (d3<=0.0) then begin
 	// closest point is along edge 1-2
	ClosestPoint:=Points[0]+(vAB*(d1/(d1-d3)));
  exit;
 end;

 vCp:=Point-Points[2];
 d5:=vAB.Dot(vCp);
 d6:=vAC.Dot(vCp);
 if (d6>=0.0) and (d5<=d6) then begin
	ClosestPoint:=Points[2]; // closest point is vertex C
	exit;
 end;

 v:=(d5*d2)-(d1*d6);
 if (v<=0.0) and (d2>=0.0) and (d6<=0.0) then begin
 	// closest point is along edge 1-3
	ClosestPoint:=Points[0]+(vAC*(d2/(d2-d6)));
  exit;
 end;

 u:=(d3*d6)-(d5*d4);
 if (u<=0.0) and ((d4-d3)>=0.0) and ((d5-d6)>=0.0) then begin
	// closest point is along edge 2-3
	ClosestPoint:=Points[1]+((Points[2]-Points[1])*((d4-d3)/((d4-d3)+(d5-d6))));
  exit;
 end;

 Denominator:=1.0/(u+v+w);

 ClosestPoint:=Points[0]+((vAB*(v*Denominator))+(vAC*(w*Denominator)));

 result:=true;
end;

function TpvTriangle.ClosestPointTo(const Segment:TpvSegment;out Time:TpvScalar;out pClosestPointOnSegment,pClosestPointOnTriangle:TpvVector3):boolean;
var MinDist,dtri,d1,d2,sa,sb,dist:TpvScalar;
    pAInside,pBInside:boolean;
    pa,pb:TpvVector3;
    Edge:TpvSegment;
begin

 result:=SegmentIntersect(Segment,Time,pClosestPointOnTriangle);

 if result then begin

 	// segment intersects triangle
  pClosestPointOnSegment:=pClosestPointOnTriangle;

 end else begin

  MinDist:=MAX_SCALAR;

  pClosestPointOnSegment:=TpvVector3.Origin;

  dtri:=Normal.Dot(Points[0]);

  pAInside:=Contains(Segment.Points[0]);
  pBInside:=Contains(Segment.Points[1]);

  if pAInside and pBInside then begin
   // both points inside triangle
   d1:=Normal.Dot(Segment.Points[0])-dtri;
   d2:=Normal.Dot(Segment.Points[1])-dtri;
   if abs(d2-d1)<EPSILON then begin
    // segment is parallel to triangle
    pClosestPointOnSegment:=(Segment.Points[0]+Segment.Points[1])*0.5;
    MinDist:=d1;
    Time:=0.5;
   end	else if abs(d1)<abs(d2) then begin
    pClosestPointOnSegment:=Segment.Points[0];
    MinDist:=d1;
    Time:=0.0;
   end else begin
    pClosestPointOnSegment:=Segment.Points[1];
    MinDist:=d2;
    Time:=1.0;
   end;
   pClosestPointOnTriangle:=pClosestPointOnSegment+(Normal*(-MinDist));
   result:=true;
   exit;
  end else if pAInside then begin
   // one point is inside triangle
   pClosestPointOnSegment:=Segment.Points[0];
   Time:=0.0;
   MinDist:=Normal.Dot(pClosestPointOnSegment)-dtri;
   pClosestPointOnTriangle:=pClosestPointOnSegment+(Normal*(-MinDist));
   MinDist:=sqr(MinDist);
  end else if pBInside then begin
   // one point is inside triangle
   pClosestPointOnSegment:=Segment.Points[1];
   Time:=1.0;
   MinDist:=Normal.Dot(pClosestPointOnSegment)-dtri;
   pClosestPointOnTriangle:=pClosestPointOnSegment+(Normal*(-MinDist));
   MinDist:=sqr(MinDist);
  end;

  // test edge 1
  Edge.Points[0]:=Points[0];
  Edge.Points[1]:=Points[1];
  Segment.ClosestPoints(Edge,sa,pa,sb,pb);
  Dist:=(pa-pb).SquaredLength;
  if Dist<MinDist then begin
   MinDist:=Dist;
   Time:=sa;
   pClosestPointOnSegment:=pa;
   pClosestPointOnTriangle:=pb;
  end;

  // test edge 2
  Edge.Points[0]:=Points[1];
  Edge.Points[1]:=Points[2];
  Segment.ClosestPoints(Edge,sa,pa,sb,pb);
  Dist:=(pa-pb).SquaredLength;
  if Dist<MinDist then begin
   MinDist:=Dist;
   Time:=sa;
   pClosestPointOnSegment:=pa;
   pClosestPointOnTriangle:=pb;
  end;

  // test edge 3
  Edge.Points[0]:=Points[2];
  Edge.Points[1]:=Points[0];
  Segment.ClosestPoints(Edge,sa,pa,sb,pb);
  Dist:=(pa-pb).SquaredLength;
  if Dist<MinDist then begin
// MinDist:=Dist;
   Time:=sa;
   pClosestPointOnSegment:=pa;
   pClosestPointOnTriangle:=pb;
  end;

 end;

end;

function TpvTriangle.GetClosestPointTo(const pPoint:TpvVector3;out ClosestPoint:TpvVector3;out s,t:TpvScalar):TpvScalar;
var Diff,Edge0,Edge1:TpvVector3;
    A00,A01,A11,B0,C,Det,B1,SquaredDistance,InvDet,Tmp0,Tmp1,Numer,Denom:TpvScalar;
begin
 Diff:=Points[0]-pPoint;
 Edge0:=Points[1]-Points[0];
 Edge1:=Points[2]-Points[0];
 A00:=Edge0.SquaredLength;
 A01:=Edge0.Dot(Edge1);
 A11:=Edge1.SquaredLength;
 B0:=Diff.Dot(Edge0);
 B1:=Diff.Dot(Edge1);
 C:=Diff.SquaredLength;
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
 ClosestPoint.x:=Points[0].x+((Edge0.x*s)+(Edge1.x*t));
 ClosestPoint.y:=Points[0].y+((Edge0.y*s)+(Edge1.y*t));
 ClosestPoint.z:=Points[0].z+((Edge0.z*s)+(Edge1.z*t));
 result:=abs(SquaredDistance);
end;

function TpvTriangle.GetClosestPointTo(const pPoint:TpvVector3;out ClosestPoint:TpvVector3):TpvScalar;
var s,t:TpvScalar;
begin
 result:=GetClosestPointTo(pPoint,ClosestPoint,s,t);
end;

function TpvTriangle.DistanceTo(const Point:TpvVector3):TpvScalar;
var SegmentTriangle:TpvSegmentTriangle;
    s,t:TpvScalar;
begin
 SegmentTriangle.Origin:=Points[0];
 SegmentTriangle.Edge0:=Points[1]-Points[0];
 SegmentTriangle.Edge1:=Points[2]-Points[0];
 SegmentTriangle.Edge2:=SegmentTriangle.Edge1-SegmentTriangle.Edge0;
{result:=}SegmentTriangle.SquaredPointTriangleDistance(Point,s,t);
{if result>EPSILON then begin
  result:=sqrt(result);
 end else if result<EPSILON then begin
  result:=-sqrt(-result);
 end else begin
  result:=0;
 end;}
 result:=Point.DistanceTo(SegmentTriangle.Origin+((SegmentTriangle.Edge0*s)+(SegmentTriangle.Edge1*t)));
end;

function TpvTriangle.SquaredDistanceTo(const Point:TpvVector3):TpvScalar;
var SegmentTriangle:TpvSegmentTriangle;
    s,t:TpvScalar;
begin
 SegmentTriangle.Origin:=Points[0];
 SegmentTriangle.Edge0:=Points[1]-Points[0];
 SegmentTriangle.Edge1:=Points[2]-Points[0];
 SegmentTriangle.Edge2:=SegmentTriangle.Edge1-SegmentTriangle.Edge0;
 result:=SegmentTriangle.SquaredPointTriangleDistance(Point,s,t);
end;

function TpvTriangle.RayIntersection(const RayOrigin,RayDirection:TpvVector3;var Time,u,v:TpvScalar):boolean;
var e0,e1,p,t,q:TpvVector3;
    Determinant,InverseDeterminant:TpvScalar;
begin
 result:=false;

 e0.x:=Points[1].x-Points[0].x;
 e0.y:=Points[1].y-Points[0].y;
 e0.z:=Points[1].z-Points[0].z;
 e1.x:=Points[2].x-Points[0].x;
 e1.y:=Points[2].y-Points[0].y;
 e1.z:=Points[2].z-Points[0].z;

 p.x:=(RayDirection.y*e1.z)-(RayDirection.z*e1.y);
 p.y:=(RayDirection.z*e1.x)-(RayDirection.x*e1.z);
 p.z:=(RayDirection.x*e1.y)-(RayDirection.y*e1.x);

 Determinant:=(e0.x*p.x)+(e0.y*p.y)+(e0.z*p.z);
 if Determinant<EPSILON then begin
  exit;
 end;

 t.x:=RayOrigin.x-Points[0].x;
 t.y:=RayOrigin.y-Points[0].y;
 t.z:=RayOrigin.z-Points[0].z;

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

function TpvSegmentTriangle.RelativeSegmentIntersection(const ppvSegment:TpvRelativeSegment;out tS,tT0,tT1:TpvScalar):boolean;
var u,v,t,a,f:TpvScalar;
    e1,e2,p,s,q:TpvVector3;
begin
 result:=false;
 tS:=0.0;
 tT0:=0.0;
 tT1:=0.0;

 e1:=Edge0;
 e2:=Edge1;

 p:=ppvSegment.Delta.Cross(e2);
 a:=e1.Dot(p);
 if abs(a)<EPSILON then begin
  exit;
 end;

 f:=1.0/a;

 s:=ppvSegment.Origin-Origin;
 u:=f*s.Dot(p);
 if (u<0.0) or (u>1.0) then begin
  exit;
 end;

 q:=s.Cross(e1);
 v:=f*ppvSegment.Delta.Dot(q);
 if (v<0.0) or ((u+v)>1.0) then begin
  exit;
 end;

 t:=f*e2.Dot(q);
 if (t<0.0) or (t>1.0) then begin
  exit;
 end;

 tS:=t;
 tT0:=u;
 tT1:=v;

 result:=true;
end;

function TpvSegmentTriangle.SquaredPointTriangleDistance(const pPoint:TpvVector3;out pfSParam,pfTParam:TpvScalar):TpvScalar;
var kDiff:TpvVector3;
    fA00,fA01,fA11,fB0,fC,fDet,fB1,fS,fT,fSqrDist,fInvDet,fTmp0,fTmp1,fNumer,fDenom:TpvScalar;
begin
 kDiff:=self.Origin-pPoint;
 fA00:=self.Edge0.SquaredLength;
 fA01:=self.Edge0.Dot(self.Edge1);
 fA11:=self.Edge1.SquaredLength;
 fB0:=kDiff.Dot(self.Edge0);
 fB1:=kDiff.Dot(self.Edge1);
 fC:=kDiff.SquaredLength;
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

function TpvSegmentTriangle.SquaredDistanceTo(const ppvRelativeSegment:TpvRelativeSegment;out segT,triT0,triT1:TpvScalar):TpvScalar;
var s,t,u,distEdgeSq,startTriSq,endTriSq:TpvScalar;
    tseg:TpvRelativeSegment;
begin
 result:=INFINITY;
 if RelativeSegmentIntersection(ppvRelativeSegment,segT,triT0,triT1) then begin
  segT:=0.0;
  triT0:=0.0;
  triT1:=0.0;
  result:=0.0;
  exit;
 end;
 tseg.Origin:=Origin;
 tseg.Delta:=Edge0;
 distEdgeSq:=ppvRelativeSegment.SquaredSegmentDistanceTo(tseg,s,t);
 if distEdgeSq<result then begin
  result:=distEdgeSq;
  segT:=s;
  triT0:=t;
  triT1:=0.0;
 end;
 tseg.Delta:=Edge1;
 distEdgeSq:=ppvRelativeSegment.SquaredSegmentDistanceTo(tseg,s,t);
 if distEdgeSq<result then begin
  result:=distEdgeSq;
  segT:=s;
  triT0:=0.0;
  triT1:=t;
 end;
 tseg.Origin:=Origin+Edge1;
 tseg.Delta:=Edge2;
 distEdgeSq:=ppvRelativeSegment.SquaredSegmentDistanceTo(tseg,s,t);
 if distEdgeSq<result then begin
  result:=distEdgeSq;
  segT:=s;
  triT0:=1.0-t;
  triT1:=t;
 end;
 startTriSq:=SquaredPointTriangleDistance(ppvRelativeSegment.Origin,t,u);
 if startTriSq<result then begin
  result:=startTriSq;
  segT:=0.0;
  triT0:=t;
  triT1:=u;
 end;
 endTriSq:=SquaredPointTriangleDistance(ppvRelativeSegment.Origin+ppvRelativeSegment.Delta,t,u);
 if endTriSq<result then begin
  result:=endTriSq;
  segT:=1.0;
  triT0:=t;
  triT1:=u;
 end;
end;

procedure TpvOBB.ProjectToVector(const Vector:TpvVector3;out OBBMin,OBBMax:TpvScalar);
var ProjectionCenter,ProjectionRadius:TpvScalar;
begin
 ProjectionCenter:=Center.Dot(Vector);
 ProjectionRadius:=abs(Vector.Dot(Axis[0])*HalfExtents.x)+
                   abs(Vector.Dot(Axis[1])*HalfExtents.y)+
                   abs(Vector.Dot(Axis[2])*HalfExtents.z);
 OBBMin:=ProjectionCenter-ProjectionRadius;
 OBBMax:=ProjectionCenter+ProjectionRadius;
end;

function TpvOBB.Intersect(const aWith:TpvOBB;const aThreshold:TpvScalar):boolean;
 function Check(const aRelativePosition,aAxis:TpvVector3):boolean; {$ifdef fpc}inline;{$endif}
 begin
   result:=abs(aRelativePosition.Dot(aAxis))<=
           ((abs((Axis[0]*HalfExtents.x).Dot(aAxis))+
             abs((Axis[1]*HalfExtents.y).Dot(aAxis))+
             abs((Axis[2]*HalfExtents.z).Dot(aAxis))+
             abs((aWith.Axis[0]*aWith.HalfExtents.x).Dot(aAxis))+
             abs((aWith.Axis[1]*aWith.HalfExtents.y).Dot(aAxis))+
             abs((aWith.Axis[2]*aWith.HalfExtents.z).Dot(aAxis)))+
             aThreshold);
 end;
var RelativePosition:TpvVector3;
begin
 RelativePosition:=aWith.Center-Center;
 result:=Check(RelativePosition,Axis[0]) and
         Check(RelativePosition,Axis[1]) and
         Check(RelativePosition,Axis[2]) and
         Check(RelativePosition,aWith.Axis[0]) and
         Check(RelativePosition,aWith.Axis[1]) and
         Check(RelativePosition,aWith.Axis[2]) and
         Check(RelativePosition,Axis[0].Cross(aWith.Axis[0])) and
         Check(RelativePosition,Axis[0].Cross(aWith.Axis[1])) and
         Check(RelativePosition,Axis[0].Cross(aWith.Axis[2])) and
         Check(RelativePosition,Axis[1].Cross(aWith.Axis[0])) and
         Check(RelativePosition,Axis[1].Cross(aWith.Axis[1])) and
         Check(RelativePosition,Axis[1].Cross(aWith.Axis[2])) and
         Check(RelativePosition,Axis[2].Cross(aWith.Axis[0])) and
         Check(RelativePosition,Axis[2].Cross(aWith.Axis[1])) and
         Check(RelativePosition,Axis[2].Cross(aWith.Axis[2]));
end;

function TpvOBB.RelativeSegmentIntersection(const ppvRelativeSegment:TpvRelativeSegment;out fracOut:TpvScalar;out posOut,NormalOut:TpvVector3):boolean;
var min_,max_,e,f,t1,t2,t:TpvScalar;
    p{,h}:TpvVector3;
    dirMax,dirMin,dir:TpvInt32;
begin
 result:=false;

 fracOut:=1e+34;
 posOut:=TpvVector3.Origin;
 normalOut:=TpvVector3.Origin;

 min_:=-1e+34;
 max_:=1e+34;

 p:=Center-ppvRelativeSegment.Origin;
//h:=HalfExtents;

 dirMax:=0;
 dirMin:=0;

 for dir:=0 to 2 do begin
  e:=Axis[Dir].Dot(p);
  f:=Axis[Dir].Dot(ppvRelativeSegment.Delta);
  if abs(f)>EPSILON then begin
   t1:=(e+HalfExtents.RawComponents[dir])/f;
   t2:=(e-HalfExtents.RawComponents[dir])/f;
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
  end else if (((-e)-HalfExtents.RawComponents[dir])>0.0) or (((-e)+HalfExtents.RawComponents[dir])<0.0) then begin
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

 posOut:=ppvRelativeSegment.Origin+(ppvRelativeSegment.Delta*fracOut);

 if Axis[dir].Dot(ppvRelativeSegment.Delta)>0.0 then begin
  normalOut:=-Axis[dir];
 end else begin
  normalOut:=Axis[dir];
 end;

 result:=true;
end;

function TpvOBB.TriangleIntersection(const Triangle:TpvTriangle;out Position,Normal:TpvVector3;out Penetration:TpvScalar):boolean;
const OBBEdges:array[0..11,0..1] of TpvInt32=
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
      ModuloThree:array[0..5] of TpvInt32=(0,1,2,0,1,2);
var OBBVertices:array[0..7] of TpvVector3;
    TriangleVertices,TriangleEdges:array[0..2] of TpvVector3;
    TriangleNormal,BestAxis,CurrentAxis,v,p,n,pt0,pt1:TpvVector3;
    BestPenetration,CurrentPenetration,tS,tT0,tT1:TpvScalar;
    BestAxisIndex,i,j:TpvInt32;
    seg,s1,s2:TpvRelativeSegment;
    SegmentTriangle:TpvSegmentTriangle;
begin
 result:=false;

 // ---
 OBBVertices[0]:=self.Center+(self.Axis[0]*(-self.HalfExtents.x))+(self.Axis[1]*(-self.HalfExtents.y))+(self.Axis[2]*(-self.HalfExtents.z));
 // +--
 OBBVertices[1]:=self.Center+(self.Axis[0]*self.HalfExtents.x)+(self.Axis[1]*(-self.HalfExtents.y))+(self.Axis[2]*(-self.HalfExtents.z));
 // ++-
 OBBVertices[2]:=self.Center+(self.Axis[0]*self.HalfExtents.x)+(self.Axis[1]*self.HalfExtents.y)+(self.Axis[2]*(-self.HalfExtents.z));
 // -+-
 OBBVertices[3]:=self.Center+(self.Axis[0]*(-self.HalfExtents.x))+(self.Axis[1]*self.HalfExtents.y)+(self.Axis[2]*(-self.HalfExtents.z));
 // --+
 OBBVertices[4]:=self.Center+(self.Axis[0]*(-self.HalfExtents.x))+(self.Axis[1]*(-self.HalfExtents.y))+(self.Axis[2]*self.HalfExtents.z);
 // +-+
 OBBVertices[5]:=self.Center+(self.Axis[0]*self.HalfExtents.x)+(self.Axis[1]*(-self.HalfExtents.y))+(self.Axis[2]*self.HalfExtents.z);
 // +++
 OBBVertices[6]:=self.Center+(self.Axis[0]*self.HalfExtents.x)+(self.Axis[1]*self.HalfExtents.y)+(self.Axis[2]*self.HalfExtents.z);
 // -++
 OBBVertices[7]:=self.Center+(self.Axis[0]*(-self.HalfExtents.x))+(self.Axis[1]*(-self.HalfExtents.y))+(self.Axis[2]*self.HalfExtents.z);

 TriangleVertices[0]:=Triangle.Points[0];
 TriangleVertices[1]:=Triangle.Points[1];
 TriangleVertices[2]:=Triangle.Points[2];

 TriangleEdges[0]:=Triangle.Points[1]-Triangle.Points[0];
 TriangleEdges[1]:=Triangle.Points[2]-Triangle.Points[1];
 TriangleEdges[2]:=Triangle.Points[0]-Triangle.Points[2];

 TriangleNormal:=TriangleEdges[0].Cross(TriangleEdges[1]).Normalize;

 BestPenetration:=0;
 BestAxis:=TpvVector3.Origin;
 BestAxisIndex:=-1;

 for i:=0 to 2 do begin
  CurrentPenetration:=DoSpanIntersect(@OBBVertices[0],8,@TriangleVertices[0],3,self.Axis[i],CurrentAxis);
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
   CurrentPenetration:=DoSpanIntersect(@OBBVertices[0],8,@TriangleVertices[0],3,self.Axis[i].Cross(TriangleEdges[j]),CurrentAxis);
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
  v:=TpvVector3.Origin;
  SegmentTriangle.Origin:=Triangle.Points[0];
  SegmentTriangle.Edge0:=Triangle.Points[1]-Triangle.Points[0];
  SegmentTriangle.Edge1:=Triangle.Points[2]-Triangle.Points[0];
  for i:=0 to 11 do begin
   seg.Origin:=OBBVertices[OBBEdges[i,0]];
   seg.Delta:=OBBVertices[OBBEdges[i,1]]-OBBVertices[OBBEdges[i,0]];
   if SegmentTriangle.RelativeSegmentIntersection(seg,tS,tT0,tT1) then begin
    v:=v+seg.Origin+(seg.Delta*tS);
    inc(j);
   end;
  end;
  for i:=0 to 2 do begin
   pt0:=TriangleVertices[i];
   pt1:=TriangleVertices[ModuloThree[i+1]];
   s1.Origin:=pt0;
   s1.Delta:=pt1-pt0;
   s2.Origin:=pt1;
   s2.Delta:=pt0-pt1;
   if RelativeSegmentIntersection(s1,tS,p,n) then begin
    v:=v+p;
    inc(j);
   end;
   if RelativeSegmentIntersection(s2,tS,p,n) then begin
    v:=v+p;
    inc(j);
   end;
  end;
  if j>0 then begin
   Position:=v/j;
  end else begin
   ClosestPointToOBB(self,(Triangle.Points[0]+Triangle.Points[1]+Triangle.Points[2])/3.0,Position);
  end;
 end;

 result:=true;

end;

function TpvOBB.TriangleIntersection(const ppvTriangle:TpvTriangle;const MTV:PpvVector3=nil):boolean;
var TriangleEdges:array[0..2] of TpvVector3;
    TriangleNormal{,d},ProjectionVector:TpvVector3;
    TriangleMin,TriangleMax,OBBMin,OBBMax,Projection,BestOverlap,Overlap:TpvScalar;
    OBBAxisIndex,TriangleEdgeIndex:TpvInt32;
    BestAxis,TheAxis:TpvVector3;
begin
 result:=false;

 TriangleEdges[0]:=ppvTriangle.Points[1]-ppvTriangle.Points[0];
 TriangleEdges[1]:=ppvTriangle.Points[2]-ppvTriangle.Points[0];
 TriangleEdges[2]:=ppvTriangle.Points[2]-ppvTriangle.Points[1];

 TriangleNormal:=TriangleEdges[0].Cross(TriangleEdges[1]);

 //d:=TriangleEdges[0]-Center;

 TriangleMin:=TriangleNormal.Dot(ppvTriangle.Points[0]);
 TriangleMax:=TriangleMin;
 ProjectToVector(TriangleNormal,OBBMin,OBBMax);
 if (TriangleMin>OBBMax) or (TriangleMax<OBBMin) then begin
  exit;
 end;
 BestAxis:=TriangleNormal;
 BestOverlap:=GetOverlap(OBBMin,OBBMax,TriangleMin,TriangleMax);

 for OBBAxisIndex:=0 to 2 do begin
  TheAxis:=self.Axis[OBBAxisIndex];
  ppvTriangle.ProjectToVector(TheAxis,TriangleMin,TriangleMax);
  Projection:=TheAxis.Dot(Center);
  OBBMin:=Projection-HalfExtents.RawComponents[OBBAxisIndex];
  OBBMax:=Projection+HalfExtents.RawComponents[OBBAxisIndex];
  if (TriangleMin>OBBMax) or (TriangleMax<OBBMin) then begin
   exit;
  end;
  Overlap:=GetOverlap(OBBMin,OBBMax,TriangleMin,TriangleMax);
  if Overlap<BestOverlap then begin
   BestAxis:=TheAxis;
   BestOverlap:=Overlap;
  end;
 end;

 for OBBAxisIndex:=0 to 2 do begin
  for TriangleEdgeIndex:=0 to 2 do begin
   ProjectionVector:=TriangleEdges[TriangleEdgeIndex].Cross(Axis[OBBAxisIndex]);
   ProjectToVector(ProjectionVector,OBBMin,OBBMax);
   ppvTriangle.ProjectToVector(ProjectionVector,TriangleMin,TriangleMax);
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
  MTV^:=BestAxis*BestOverlap;
 end;

 result:=true;
end;

constructor TpvAABB.Create(const pMin,pMax:TpvVector3);
begin
 Min:=pMin;
 Max:=pMax;
end;

constructor TpvAABB.CreateFromOBB(const OBB:TpvOBB);
var t:TpvVector3;
begin
 t.x:=abs((OBB.Matrix[0,0]*OBB.HalfExtents.x)+(OBB.Matrix[1,0]*OBB.HalfExtents.y)+(OBB.Matrix[2,0]*OBB.HalfExtents.z));
 t.y:=abs((OBB.Matrix[0,1]*OBB.HalfExtents.x)+(OBB.Matrix[1,1]*OBB.HalfExtents.y)+(OBB.Matrix[2,1]*OBB.HalfExtents.z));
 t.z:=abs((OBB.Matrix[0,2]*OBB.HalfExtents.x)+(OBB.Matrix[1,2]*OBB.HalfExtents.y)+(OBB.Matrix[2,2]*OBB.HalfExtents.z));
 Min.x:=OBB.Center.x-t.x;
 Min.y:=OBB.Center.y-t.y;
 Min.z:=OBB.Center.z-t.z;
 Max.x:=OBB.Center.x+t.x;
 Max.y:=OBB.Center.y+t.y;
 Max.z:=OBB.Center.z+t.z;
end;

function TpvAABB.Cost:TpvScalar;
begin
 result:=(Max.x-Min.x)+(Max.y-Min.y)+(Max.z-Min.z); // Manhattan distance
end;

function TpvAABB.Volume:TpvScalar;
begin
 result:=(Max.x-Min.x)*(Max.y-Min.y)*(Max.z-Min.z); // Volume
end;

function TpvAABB.Area:TpvScalar;
begin
 result:=2.0*((abs(Max.x-Min.x)*abs(Max.y-Min.y))+
              (abs(Max.y-Min.y)*abs(Max.z-Min.z))+
              (abs(Max.x-Min.x)*abs(Max.z-Min.z)));
end;

function TpvAABB.Center:TpvVector3;
begin
 result:=(Min+Max)*0.5;
end;

function TpvAABB.Flip:TpvAABB;
var a,b:TpvVector3;
begin
 a:=Min.Flip;
 b:=Max.Flip;
 result.Min.x:=Math.Min(a.x,b.x);
 result.Min.y:=Math.Min(a.y,b.y);
 result.Min.z:=Math.Min(a.z,b.z);
 result.Max.x:=Math.Max(a.x,b.x);
 result.Max.y:=Math.Max(a.y,b.y);
 result.Max.z:=Math.Max(a.z,b.z);
end;

function TpvAABB.SquareMagnitude:TpvScalar;
begin
 result:=sqr(Max.x-Min.x)+(Max.y-Min.y)+sqr(Max.z-Min.z);
end;

function TpvAABB.ToOBB(const aTransform:TpvMatrix4x4):TpvOBB;
begin
 result.Center:=aTransform*((Min+Max)*0.5);
 result.HalfExtents:=(Max-Min)*0.5;
 result.Matrix:=aTransform.ToMatrix3x3;
end;

function TpvAABB.Resize(const f:TpvScalar):TpvAABB;
var v:TpvVector3;
begin
 v:=(Max-Min)*f;
 result.Min:=Min-v;
 result.Max:=Max+v;
end;

procedure TpvAABB.DirectCombine(const WithAABB:TpvAABB);
begin
 Min.x:=Math.Min(Min.x,WithAABB.Min.x);
 Min.y:=Math.Min(Min.y,WithAABB.Min.y);
 Min.z:=Math.Min(Min.z,WithAABB.Min.z);
 Max.x:=Math.Max(Max.x,WithAABB.Max.x);
 Max.y:=Math.Max(Max.y,WithAABB.Max.y);
 Max.z:=Math.Max(Max.z,WithAABB.Max.z);
end;

procedure TpvAABB.DirectCombineVector3(const v:TpvVector3);
begin
 Min.x:=Math.Min(Min.x,v.x);
 Min.y:=Math.Min(Min.y,v.y);
 Min.z:=Math.Min(Min.z,v.z);
 Max.x:=Math.Max(Max.x,v.x);
 Max.y:=Math.Max(Max.y,v.y);
 Max.z:=Math.Max(Max.z,v.z);
end;

function TpvAABB.Combine(const WithAABB:TpvAABB):TpvAABB;
begin
 result.Min.x:=Math.Min(Min.x,WithAABB.Min.x);
 result.Min.y:=Math.Min(Min.y,WithAABB.Min.y);
 result.Min.z:=Math.Min(Min.z,WithAABB.Min.z);
 result.Max.x:=Math.Max(Max.x,WithAABB.Max.x);
 result.Max.y:=Math.Max(Max.y,WithAABB.Max.y);
 result.Max.z:=Math.Max(Max.z,WithAABB.Max.z);
end;

function TpvAABB.CombineVector3(const v:TpvVector3):TpvAABB;
begin
 result.Min.x:=Math.Min(Min.x,v.x);
 result.Min.y:=Math.Min(Min.y,v.y);
 result.Min.z:=Math.Min(Min.z,v.z);
 result.Max.x:=Math.Max(Max.x,v.x);
 result.Max.y:=Math.Max(Max.y,v.y);
 result.Max.z:=Math.Max(Max.z,v.z);
end;

function TpvAABB.Enlarge(const aWithAABB:TpvAABB):boolean;
begin
 result:=false;
 if aWithAABB.Min.x<Min.x then begin
  Min.x:=aWithAABB.Min.x;
  result:=true;
 end;
 if aWithAABB.Min.y<Min.y then begin
  Min.y:=aWithAABB.Min.y;
  result:=true;
 end;
 if aWithAABB.Min.z<Min.z then begin
  Min.z:=aWithAABB.Min.z;
  result:=true;
 end;
 if aWithAABB.Max.x>Max.x then begin
  Max.x:=aWithAABB.Max.x;
  result:=true;
 end;
 if aWithAABB.Max.y>Max.y then begin
  Max.y:=aWithAABB.Max.y;
  result:=true;
 end;
 if aWithAABB.Max.z>Max.z then begin
  Max.z:=aWithAABB.Max.z;
  result:=true;
 end;
end;

function TpvAABB.DistanceTo(const ToAABB:TpvAABB):TpvScalar;
begin
 result:=0.0;
 if Min.x>ToAABB.Max.x then begin
  result:=result+sqr(ToAABB.Max.x-Min.x);
 end else if ToAABB.Min.x>Max.x then begin
  result:=result+sqr(Max.x-ToAABB.Min.x);
 end;
 if Min.y>ToAABB.Max.y then begin
  result:=result+sqr(ToAABB.Max.y-Min.y);
 end else if ToAABB.Min.y>Max.y then begin
  result:=result+sqr(Max.y-ToAABB.Min.y);
 end;
 if Min.z>ToAABB.Max.z then begin
  result:=result+sqr(ToAABB.Max.z-Min.z);
 end else if ToAABB.Min.z>Max.z then begin
  result:=result+sqr(Max.z-ToAABB.Min.z);
 end;
 if result>0.0 then begin
  result:=sqrt(result);
 end;
end;

function TpvAABB.Radius:TpvScalar;
begin
 result:=Math.Max(Min.DistanceTo((Min+Max)*0.5),Max.DistanceTo((Min+Max)*0.5));
end;

function TpvAABB.Compare(const WithAABB:TpvAABB):boolean;
begin
 result:=(Min=WithAABB.Min) and (Max=WithAABB.Max);
end;

function TpvAABB.Intersect(const aWith:TpvOBB;const aThreshold:TpvScalar):boolean;
var OBBCenterToAABBCenter,AABBHalfExtents:TpvVector3;
begin
 OBBCenterToAABBCenter:=aWith.Center-Min.Lerp(Max,0.5);
 AABBHalfExtents:=(Max-Min)*0.5;
 result:=((abs(OBBCenterToAABBCenter.Dot(aWith.Axis[0]))-AABBHalfExtents.Dot(aWith.Axis[0]))<=(aWith.HalfExtents.Dot(aWith.Axis[0])+aThreshold)) and
         ((abs(OBBCenterToAABBCenter.Dot(aWith.Axis[1]))-AABBHalfExtents.Dot(aWith.Axis[1]))<=(aWith.HalfExtents.Dot(aWith.Axis[1])+aThreshold)) and
         ((abs(OBBCenterToAABBCenter.Dot(aWith.Axis[2]))-AABBHalfExtents.Dot(aWith.Axis[2]))<=(aWith.HalfExtents.Dot(aWith.Axis[2])+aThreshold));
end;

function TpvAABB.Intersect(const WithAABB:TpvAABB;Threshold:TpvScalar):boolean;
begin
 result:=(((Max.x+Threshold)>=(WithAABB.Min.x-Threshold)) and ((Min.x-Threshold)<=(WithAABB.Max.x+Threshold))) and
         (((Max.y+Threshold)>=(WithAABB.Min.y-Threshold)) and ((Min.y-Threshold)<=(WithAABB.Max.y+Threshold))) and
         (((Max.z+Threshold)>=(WithAABB.Min.z-Threshold)) and ((Min.z-Threshold)<=(WithAABB.Max.z+Threshold)));
end;

class function TpvAABB.Intersect(const aAABBMin,aAABBMax:TpvVector3;const WithAABB:TpvAABB;Threshold:TpvScalar):boolean;
begin
 result:=(((aAABBMax.x+Threshold)>=(WithAABB.Min.x-Threshold)) and ((aAABBMin.x-Threshold)<=(WithAABB.Max.x+Threshold))) and
         (((aAABBMax.y+Threshold)>=(WithAABB.Min.y-Threshold)) and ((aAABBMin.y-Threshold)<=(WithAABB.Max.y+Threshold))) and
         (((aAABBMax.z+Threshold)>=(WithAABB.Min.z-Threshold)) and ((aAABBMin.z-Threshold)<=(WithAABB.Max.z+Threshold)));
end;

function TpvAABB.Contains(const AABB:TpvAABB;const aThreshold:TpvScalar=EPSILON):boolean;
begin
 result:=((Min.x-aThreshold)<=(AABB.Min.x+aThreshold)) and
         ((Min.y-aThreshold)<=(AABB.Min.y+aThreshold)) and
         ((Min.z-aThreshold)<=(AABB.Min.z+aThreshold)) and
         ((Max.x+aThreshold)>=(AABB.Min.x-aThreshold)) and
         ((Max.y+aThreshold)>=(AABB.Min.y-aThreshold)) and
         ((Max.z+aThreshold)>=(AABB.Min.z-aThreshold)) and
         ((Min.x-aThreshold)<=(AABB.Max.x+aThreshold)) and
         ((Min.y-aThreshold)<=(AABB.Max.y+aThreshold)) and
         ((Min.z-aThreshold)<=(AABB.Max.z+aThreshold)) and
         ((Max.x+aThreshold)>=(AABB.Max.x-aThreshold)) and
         ((Max.y+aThreshold)>=(AABB.Max.y-aThreshold)) and
         ((Max.z+aThreshold)>=(AABB.Max.z-aThreshold));
end;

class function TpvAABB.Contains(const aAABBMin,aAABBMax:TpvVector3;const aAABB:TpvAABB;const aThreshold:TpvScalar=EPSILON):boolean;
begin
 result:=((aAABBMin.x-aThreshold)<=(aAABB.Min.x+aThreshold)) and
         ((aAABBMin.y-aThreshold)<=(aAABB.Min.y+aThreshold)) and
         ((aAABBMin.z-aThreshold)<=(aAABB.Min.z+aThreshold)) and
         ((aAABBMax.x+aThreshold)>=(aAABB.Min.x-aThreshold)) and
         ((aAABBMax.y+aThreshold)>=(aAABB.Min.y-aThreshold)) and
         ((aAABBMax.z+aThreshold)>=(aAABB.Min.z-aThreshold)) and
         ((aAABBMin.x-aThreshold)<=(aAABB.Max.x+aThreshold)) and
         ((aAABBMin.y-aThreshold)<=(aAABB.Max.y+aThreshold)) and
         ((aAABBMin.z-aThreshold)<=(aAABB.Max.z+aThreshold)) and
         ((aAABBMax.x+aThreshold)>=(aAABB.Max.x-aThreshold)) and
         ((aAABBMax.y+aThreshold)>=(aAABB.Max.y-aThreshold)) and
         ((aAABBMax.z+aThreshold)>=(aAABB.Max.z-aThreshold));
end;

function TpvAABB.Contains(const Vector:TpvVector3):boolean;
begin
 result:=((Vector.x>=(Min.x-EPSILON)) and (Vector.x<=(Max.x+EPSILON))) and
         ((Vector.y>=(Min.y-EPSILON)) and (Vector.y<=(Max.y+EPSILON))) and
         ((Vector.z>=(Min.z-EPSILON)) and (Vector.z<=(Max.z+EPSILON)));
end;

class function TpvAABB.Contains(const aAABBMin,aAABBMax,aVector:TpvVector3):boolean;
begin
 result:=((aVector.x>=(aAABBMin.x-EPSILON)) and (aVector.x<=(aAABBMax.x+EPSILON))) and
         ((aVector.y>=(aAABBMin.y-EPSILON)) and (aVector.y<=(aAABBMax.y+EPSILON))) and
         ((aVector.z>=(aAABBMin.z-EPSILON)) and (aVector.z<=(aAABBMax.z+EPSILON)));
end;

function TpvAABB.Contains(const aOBB:TpvOBB):boolean;
var Axes:array[0..3] of TpvVector3;
begin
 Axes[0]:=aOBB.Axis[0]*aOBB.HalfExtents.x;
 Axes[1]:=aOBB.Axis[1]*aOBB.HalfExtents.y;
 Axes[2]:=aOBB.Axis[2]*aOBB.HalfExtents.z;
 Axes[3]:=Axes[0]+Axes[1]+Axes[2];
 result:=Contains(aOBB.Center-Axes[0]) and Contains(aOBB.Center-Axes[1]) and Contains(aOBB.Center-Axes[2]) and Contains(aOBB.Center-Axes[3]) and
         Contains(aOBB.Center+Axes[0]) and Contains(aOBB.Center+Axes[1]) and Contains(aOBB.Center+Axes[2]) and Contains(aOBB.Center+Axes[3]);
end;

function TpvAABB.Touched(const Vector:TpvVector3;const Threshold:TpvScalar=1e-5):boolean;
begin
 result:=((Vector.x>=(Min.x-Threshold)) and (Vector.x<=(Max.x+Threshold))) and
         ((Vector.y>=(Min.y-Threshold)) and (Vector.y<=(Max.y+Threshold))) and
         ((Vector.z>=(Min.z-Threshold)) and (Vector.z<=(Max.z+Threshold)));
end;

function TpvAABB.GetIntersection(const WithAABB:TpvAABB):TpvAABB;
begin
 result.Min.x:=Math.Max(Min.x,WithAABB.Min.x);
 result.Min.y:=Math.Max(Min.y,WithAABB.Min.y);
 result.Min.z:=Math.Max(Min.z,WithAABB.Min.z);
 result.Max.x:=Math.Min(Max.x,WithAABB.Max.x);
 result.Max.y:=Math.Min(Max.y,WithAABB.Max.y);
 result.Max.z:=Math.Min(Max.z,WithAABB.Max.z);
end;

function TpvAABB.FastRayIntersection(const Origin,Direction:TpvVector3):boolean;
var t0,t1:TpvVector3;
begin
 // Although it might seem this doesn't address edge cases where
 // Direction.{x,y,z} equals zero, it is indeed correct. This is
 // because the comparisons still work as expected when infinities
 // emerge from zero division. Rays that are parallel to an axis
 // and positioned outside the box will lead to tmin being infinity
 // or tmax turning into negative infinity, yet for rays located
 // within the box, the values for tmin and tmax will remain unchanged.
 t0:=(Min-Origin)/Direction;
 t1:=(Max-Origin)/Direction;
 result:=Math.Max(0.0,Math.Max(Math.Max(Math.Min(Math.Min(t0.x,t1.x),Infinity),
                               Math.Min(Math.Min(t0.y,t1.y),Infinity)),
                               Math.Min(Math.Min(t0.z,t1.z),Infinity)))<=
         Math.Min(Math.Min(Math.Max(Math.Max(t0.x,t1.x),NegInfinity),
                           Math.Max(Math.Max(t0.y,t1.y),NegInfinity)),
                           Math.Max(Math.Max(t0.z,t1.z),NegInfinity));
end;
{var Center,BoxExtents,Diff:TpvVector3;
begin
 Center:=(Min+Max)*0.5;
 BoxExtents:=Center-Min;
 Diff:=Origin-Center;
 result:=not ((((abs(Diff.x)>BoxExtents.x) and ((Diff.x*Direction.x)>=0)) or
               ((abs(Diff.y)>BoxExtents.y) and ((Diff.y*Direction.y)>=0)) or
               ((abs(Diff.z)>BoxExtents.z) and ((Diff.z*Direction.z)>=0))) or
              ((abs((Direction.y*Diff.z)-(Direction.z*Diff.y))>((BoxExtents.y*abs(Direction.z))+(BoxExtents.z*abs(Direction.y)))) or
               (abs((Direction.z*Diff.x)-(Direction.x*Diff.z))>((BoxExtents.x*abs(Direction.z))+(BoxExtents.z*abs(Direction.x)))) or
               (abs((Direction.x*Diff.y)-(Direction.y*Diff.x))>((BoxExtents.x*abs(Direction.y))+(BoxExtents.y*abs(Direction.x))))));
end;}

class function TpvAABB.FastRayIntersection(const aAABBMin,aAABBMax:TpvVector3;const Origin,Direction:TpvVector3):boolean;
var t0,t1:TpvVector3;
begin
 // Although it might seem this doesn't address edge cases where
 // Direction.{x,y,z} equals zero, it is indeed correct. This is
 // because the comparisons still work as expected when infinities
 // emerge from zero division. Rays that are parallel to an axis
 // and positioned outside the box will lead to tmin being infinity
 // or tmax turning into negative infinity, yet for rays located
 // within the box, the values for tmin and tmax will remain unchanged.
 t0:=(aAABBMin-Origin)/Direction;
 t1:=(aAABBMax-Origin)/Direction;
 result:=Math.Max(0.0,Math.Max(Math.Max(Math.Min(Math.Min(t0.x,t1.x),Infinity),
                               Math.Min(Math.Min(t0.y,t1.y),Infinity)),
                               Math.Min(Math.Min(t0.z,t1.z),Infinity)))<=
         Math.Min(Math.Min(Math.Max(Math.Max(t0.x,t1.x),NegInfinity),
                           Math.Max(Math.Max(t0.y,t1.y),NegInfinity)),
                           Math.Max(Math.Max(t0.z,t1.z),NegInfinity));
end;
{var Center,BoxExtents,Diff:TpvVector3;
begin
 Center:=(aAABBMin+aAABBMax)*0.5;
 BoxExtents:=Center-aAABBMin;
 Diff:=Origin-Center;
 result:=not ((((abs(Diff.x)>BoxExtents.x) and ((Diff.x*Direction.x)>=0)) or
               ((abs(Diff.y)>BoxExtents.y) and ((Diff.y*Direction.y)>=0)) or
               ((abs(Diff.z)>BoxExtents.z) and ((Diff.z*Direction.z)>=0))) or
              ((abs((Direction.y*Diff.z)-(Direction.z*Diff.y))>((BoxExtents.y*abs(Direction.z))+(BoxExtents.z*abs(Direction.y)))) or
               (abs((Direction.z*Diff.x)-(Direction.x*Diff.z))>((BoxExtents.x*abs(Direction.z))+(BoxExtents.z*abs(Direction.x)))) or
               (abs((Direction.x*Diff.y)-(Direction.y*Diff.x))>((BoxExtents.x*abs(Direction.y))+(BoxExtents.y*abs(Direction.x))))));
end;}

function TpvAABB.RayIntersectionHitDistance(const Origin,Direction:TpvVector3;var HitDist:TpvScalar):boolean;
var DirFrac:TpvVector3;
    t:array[0..5] of TpvScalar;
    tMin,tMax:TpvScalar;
begin
 DirFrac.x:=1.0/Direction.x;
 DirFrac.y:=1.0/Direction.y;
 DirFrac.z:=1.0/Direction.z;
 t[0]:=(Min.x-Origin.x)*DirFrac.x;
 t[1]:=(Max.x-Origin.x)*DirFrac.x;
 t[2]:=(Min.y-Origin.y)*DirFrac.y;
 t[3]:=(Max.y-Origin.y)*DirFrac.y;
 t[4]:=(Min.z-Origin.z)*DirFrac.z;
 t[5]:=(Max.z-Origin.z)*DirFrac.z;
 tMin:=Math.Max(Math.Max(Math.Min(t[0],t[1]),Math.Min(t[2],t[3])),Math.Min(t[4],t[5]));
 tMax:=Math.Min(Math.Min(Math.Max(t[0],t[1]),Math.Max(t[2],t[3])),Math.Max(t[4],t[5]));
 if (tMax<0) or (tMin>tMax) then begin
  HitDist:=tMax;
  result:=false;
 end else begin
  HitDist:=tMin;
  result:=true;
 end;
end;

function TpvAABB.RayIntersectionHitPoint(const Origin,Direction:TpvVector3;out HitPoint:TpvVector3):boolean;
const RIGHT=0;
      LEFT=1;
      MIDDLE=2;
var i,WhicHPlane:TpvInt32;
    Inside:longbool;
    Quadrant:array[0..2] of TpvInt32;
    MaxT,CandidatePlane:TpvVector3;
begin
 Inside:=true;
 for i:=0 to 2 do begin
  if Origin.RawComponents[i]<Min.RawComponents[i] then begin
   Quadrant[i]:=LEFT;
   CandidatePlane.RawComponents[i]:=Min.RawComponents[i];
   Inside:=false;
  end else if Origin.RawComponents[i]>Max.RawComponents[i] then begin
   Quadrant[i]:=RIGHT;
   CandidatePlane.RawComponents[i]:=Max.RawComponents[i];
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
   if (Quadrant[i]<>MIDDLE) and (Direction.RawComponents[i]<>0.0) then begin
    MaxT.RawComponents[i]:=(CandidatePlane.RawComponents[i]-Origin.RawComponents[i])/Direction.RawComponents[i];
   end else begin
    MaxT.RawComponents[i]:=-1.0;
   end;
  end;
  WhichPlane:=0;
  for i:=1 to 2 do begin
   if MaxT.RawComponents[WhichPlane]<MaxT.RawComponents[i] then begin
    WhichPlane:=i;
   end;
  end;
  if MaxT.RawComponents[WhichPlane]<0.0 then begin
   result:=false;
  end else begin
   for i:=0 to 2 do begin
    if WhichPlane<>i then begin
     HitPoint.RawComponents[i]:=Origin.RawComponents[i]+(MaxT.RawComponents[WhichPlane]*Direction.RawComponents[i]);
     if (HitPoint.RawComponents[i]<Min.RawComponents[i]) or (HitPoint.RawComponents[i]>Min.RawComponents[i]) then begin
      result:=false;
      exit;
     end;
    end else begin
     HitPoint.RawComponents[i]:=CandidatePlane.RawComponents[i];
    end;
   end;
   result:=true;
  end;
 end;
end;

function TpvAABB.RayIntersection(const Origin,Direction:TpvVector3;out Time:TpvScalar):boolean;
var InvDirection,a,b:TpvVector3;
    TimeMin,TimeMax:TpvScalar;
begin
 InvDirection:=TpvVector3.AllAxis/Direction;
 a:=(Min-Origin)*InvDirection;
 b:=(Max-Origin)*InvDirection;
 TimeMin:=Math.Max(Math.Max(Math.Min(a.x,b.x),Math.Min(a.y,b.y)),Math.Min(a.z,b.z));
 TimeMax:=Math.Min(Math.Min(Math.Max(a.x,b.x),Math.Max(a.y,b.y)),Math.Max(a.z,b.z));
 if (TimeMax<0.0) or (TimeMin>TimeMax) then begin
  Time:=TimeMax;
  result:=false;
 end else begin
  if TimeMin<0.0 then begin
   Time:=TimeMax;
  end else begin
   Time:=TimeMin;
  end;
  result:=true;
 end;
end;

class function TpvAABB.RayIntersection(const aAABBMin,aAABBMax:TpvVector3;const Origin,Direction:TpvVector3;out Time:TpvScalar):boolean;
var InvDirection,a,b:TpvVector3;
    TimeMin,TimeMax:TpvScalar;
begin
 InvDirection:=TpvVector3.AllAxis/Direction;
 a:=(aAABBMin-Origin)*InvDirection;
 b:=(aAABBMax-Origin)*InvDirection;
 TimeMin:=Math.Max(Math.Max(Math.Min(a.x,b.x),Math.Min(a.y,b.y)),Math.Min(a.z,b.z));
 TimeMax:=Math.Min(Math.Min(Math.Max(a.x,b.x),Math.Max(a.y,b.y)),Math.Max(a.z,b.z));
 if (TimeMax<0.0) or (TimeMin>TimeMax) then begin
  Time:=TimeMax;
  result:=false;
 end else begin
  if TimeMin<0.0 then begin
   Time:=TimeMax;
  end else begin
   Time:=TimeMin;
  end;
  result:=true;
 end;
end;

function TpvAABB.LineIntersection(const StartPoint,EndPoint:TpvVector3):boolean;
var Direction,InvDirection,a,b:TpvVector3;
    Len,TimeMin,TimeMax:TpvScalar;
begin
 if Contains(StartPoint) or Contains(EndPoint) then begin
  result:=true;
 end else begin
  Direction:=EndPoint-StartPoint;
  Len:=Direction.Length;
  if Len<>0.0 then begin
   Direction:=Direction/Len;
  end;
  InvDirection:=TpvVector3.AllAxis/Direction;
  a:=((Min-TpvVector3.InlineableCreate(EPSILON,EPSILON,EPSILON))-StartPoint)*InvDirection;
  b:=((Max+TpvVector3.InlineableCreate(EPSILON,EPSILON,EPSILON))-StartPoint)*InvDirection;
  TimeMin:=Math.Max(Math.Max(Math.Min(a.x,a.y),Math.Min(a.z,b.x)),Math.Min(b.y,b.z));
  TimeMax:=Math.Min(Math.Min(Math.Max(a.x,a.y),Math.Max(a.z,b.x)),Math.Max(b.y,b.z));
  result:=((TimeMin<=TimeMax) and (TimeMax>=0.0)) and (TimeMin<=(Len+EPSILON));
 end;
end;

class function TpvAABB.LineIntersection(const aAABBMin,aAABBMax:TpvVector3;const StartPoint,EndPoint:TpvVector3):boolean;
var Direction,InvDirection,a,b:TpvVector3;
    Len,TimeMin,TimeMax:TpvScalar;
begin
 if TpvAABB.Contains(aAABBMin,aAABBMax,StartPoint) or TpvAABB.Contains(aAABBMin,aAABBMax,EndPoint) then begin
  result:=true;
 end else begin
  Direction:=EndPoint-StartPoint;
  Len:=Direction.Length;
  if Len<>0.0 then begin
   Direction:=Direction/Len;
  end;
  InvDirection:=TpvVector3.AllAxis/Direction;
  a:=((aAABBMin-TpvVector3.InlineableCreate(EPSILON,EPSILON,EPSILON))-StartPoint)*InvDirection;
  b:=((aAABBMax+TpvVector3.InlineableCreate(EPSILON,EPSILON,EPSILON))-StartPoint)*InvDirection;
  TimeMin:=Math.Max(Math.Max(Math.Min(a.x,a.y),Math.Min(a.z,b.x)),Math.Min(b.y,b.z));
  TimeMax:=Math.Min(Math.Min(Math.Max(a.x,a.y),Math.Max(a.z,b.x)),Math.Max(b.y,b.z));
  result:=((TimeMin<=TimeMax) and (TimeMax>=0.0)) and (TimeMin<=(Len+EPSILON));
 end;
end;

function TpvAABB.TriangleIntersection(const Triangle:TpvTriangle):boolean;
 function FindMin(const a,b,c:TpvScalar):TpvScalar; //{$ifdef CAN_INLINE}inline;{$endif}
 begin
  result:=a;
  if result>b then begin
   result:=b;
  end;
  if result>c then begin
   result:=c;
  end;
 end;
 function FindMax(const a,b,c:TpvScalar):TpvScalar; //{$ifdef CAN_INLINE}inline;{$endif}
 begin
  result:=a;
  if result<b then begin
   result:=b;
  end;
  if result<c then begin
   result:=c;
  end;
 end;
 function PlaneBoxOverlap(const Normal:TpvVector3;d:TpvFloat;MaxBox:TpvVector3):boolean; //{$ifdef CAN_INLINE}inline;{$endif}
 var vmin,vmax:TpvVector3;
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
  if (Normal.Dot(vmin)+d)>0 then begin
   result:=false;
  end else if (Normal.Dot(vmax)+d)>=0 then begin
   result:=true;
  end else begin
   result:=false;
  end;
 end;
var BoxCenter,BoxHalfSize,Normal,v0,v1,v2,e0,e1,e2:TpvVector3;
    fex,fey,fez,Distance,r:TpvFloat;
 function AxisTestX01(a,b,fa,fb:TpvFloat):boolean;
 var p0,p2,pmin,pmax,Radius:TpvFloat;
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
 function AxisTestX2(a,b,fa,fb:TpvFloat):boolean;
 var p0,p1,pmin,pmax,Radius:TpvFloat;
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
 function AxisTestY02(a,b,fa,fb:TpvFloat):boolean;
 var p0,p2,pmin,pmax,Radius:TpvFloat;
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
 function AxisTestY1(a,b,fa,fb:TpvFloat):boolean;
 var p0,p1,pmin,pmax,Radius:TpvFloat;
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
 function AxisTestZ12(a,b,fa,fb:TpvFloat):boolean;
 var p1,p2,pmin,pmax,Radius:TpvFloat;
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
 function AxisTestZ0(a,b,fa,fb:TpvFloat):boolean;
 var p0,p1,pmin,pmax,Radius:TpvFloat;
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
 procedure FindMinMax(const a,b,c:TpvFloat;var omin,omax:TpvFloat);
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
 BoxCenter:=(Min+Max)*0.5;
 BoxHalfSize:=(Max-Min)*0.5;
 v0:=Triangle.Points[0]-BoxCenter;
 v1:=Triangle.Points[1]-BoxCenter;
 v2:=Triangle.Points[2]-BoxCenter;
 e0:=v1-v0;
 e1:=v2-v1;
 e2:=v0-v2;
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
 Normal:=e0.Cross(e1);
 Distance:=abs(Normal.Dot(v0));
 r:=(BoxHalfSize.x*abs(Normal.x))+(BoxHalfSize.y*abs(Normal.y))+(BoxHalfSize.z*abs(Normal.z));
 result:=Distance<=r;//PlaneBoxOverlap(Normal,-Normal.Dot(v0),BoxHalfSize);
end;

function TpvAABB.Transform(const Transform:TpvMatrix3x3):TpvAABB;
var Center,Temp,Extents:TpvVector3;
begin
 Center:=(Min+Max)*0.5;
 Temp:=(Max-Min)*0.5;
 Extents.x:=(abs(Transform.RawComponents[0,0])*Temp.x)+(abs(Transform.RawComponents[1,0])*Temp.y)+(abs(Transform.RawComponents[2,0])*Temp.z);
 Extents.y:=(abs(Transform.RawComponents[0,1])*Temp.x)+(abs(Transform.RawComponents[1,1])*Temp.y)+(abs(Transform.RawComponents[2,1])*Temp.z);
 Extents.z:=(abs(Transform.RawComponents[0,2])*Temp.x)+(abs(Transform.RawComponents[1,2])*Temp.y)+(abs(Transform.RawComponents[2,2])*Temp.z);
 result.Min:=Center-Extents;
 result.Max:=Center+Extents;
end;
{begin
 result.Min.x:=0.0;
 result.Min.y:=0.0;
 result.Min.z:=0.0;
 result.Max.x:=0.0;
 result.Max.y:=0.0;
 result.Max.z:=0.0;
 if Transform.RawComponents[0,0]>0.0 then begin
  result.Min.x:=result.Min.x+(Transform.RawComponents[0,0]*Min.x);
  result.Max.x:=result.Max.x+(Transform.RawComponents[0,0]*Max.x);
 end else begin
  result.Min.x:=result.Min.x+(Transform.RawComponents[0,0]*Max.x);
  result.Max.x:=result.Max.x+(Transform.RawComponents[0,0]*Min.x);
 end;
 if Transform.RawComponents[0,1]>0.0 then begin
  result.Min.y:=result.Min.y+(Transform.RawComponents[0,1]*Min.x);
  result.Max.y:=result.Max.y+(Transform.RawComponents[0,1]*Max.x);
 end else begin
  result.Min.y:=result.Min.y+(Transform.RawComponents[0,1]*Max.x);
  result.Max.y:=result.Max.y+(Transform.RawComponents[0,1]*Min.x);
 end;
 if Transform.RawComponents[0,2]>0.0 then begin
  result.Min.z:=result.Min.z+(Transform.RawComponents[0,2]*Min.x);
  result.Max.z:=result.Max.z+(Transform.RawComponents[0,2]*Max.x);
 end else begin
  result.Min.z:=result.Min.z+(Transform.RawComponents[0,2]*Max.x);
  result.Max.z:=result.Max.z+(Transform.RawComponents[0,2]*Min.x);
 end;
 if Transform.RawComponents[1,0]>0.0 then begin
  result.Min.x:=result.Min.x+(Transform.RawComponents[1,0]*Min.y);
  result.Max.x:=result.Max.x+(Transform.RawComponents[1,0]*Max.y);
 end else begin
  result.Min.x:=result.Min.x+(Transform.RawComponents[1,0]*Max.y);
  result.Max.x:=result.Max.x+(Transform.RawComponents[1,0]*Min.y);
 end;
 if Transform.RawComponents[1,1]>0.0 then begin
  result.Min.y:=result.Min.y+(Transform.RawComponents[1,1]*Min.y);
  result.Max.y:=result.Max.y+(Transform.RawComponents[1,1]*Max.y);
 end else begin
  result.Min.y:=result.Min.y+(Transform.RawComponents[1,1]*Max.y);
  result.Max.y:=result.Max.y+(Transform.RawComponents[1,1]*Min.y);
 end;
 if Transform.RawComponents[1,2]>0.0 then begin
  result.Min.z:=result.Min.z+(Transform.RawComponents[1,2]*Min.y);
  result.Max.z:=result.Max.z+(Transform.RawComponents[1,2]*Max.y);
 end else begin
  result.Min.z:=result.Min.z+(Transform.RawComponents[1,2]*Max.y);
  result.Max.z:=result.Max.z+(Transform.RawComponents[1,2]*Min.y);
 end;
 if Transform.RawComponents[2,0]>0.0 then begin
  result.Min.x:=result.Min.x+(Transform.RawComponents[2,0]*Min.z);
  result.Max.x:=result.Max.x+(Transform.RawComponents[2,0]*Max.z);
 end else begin
  result.Min.x:=result.Min.x+(Transform.RawComponents[2,0]*Max.z);
  result.Max.x:=result.Max.x+(Transform.RawComponents[2,0]*Min.z);
 end;
 if Transform.RawComponents[2,1]>0.0 then begin
  result.Min.y:=result.Min.y+(Transform.RawComponents[2,1]*Min.z);
  result.Max.y:=result.Max.y+(Transform.RawComponents[2,1]*Max.z);
 end else begin
  result.Min.y:=result.Min.y+(Transform.RawComponents[2,1]*Max.z);
  result.Max.y:=result.Max.y+(Transform.RawComponents[2,1]*Min.z);
 end;
 if Transform.RawComponents[2,2]>0.0 then begin
  result.Min.z:=result.Min.z+(Transform.RawComponents[2,2]*Min.z);
  result.Max.z:=result.Max.z+(Transform.RawComponents[2,2]*Max.z);
 end else begin
  result.Min.z:=result.Min.z+(Transform.RawComponents[2,2]*Max.z);
  result.Max.z:=result.Max.z+(Transform.RawComponents[2,2]*Min.z);
 end;
end;}
{var i,j:TpvInt32;
    a,b:TpvScalar;
begin
 result.Min.x:=0.0;
 result.Min.y:=0.0;
 result.Min.z:=0.0;
 result.Max.x:=0.0;
 result.Max.y:=0.0;
 result.Max.z:=0.0;
 for i:=0 to 2 do begin
  for j:=0 to 2 do begin
   a:=Transform[j,i]*Min.RawComponents[j];
   b:=Transform[j,i]*Max.RawComponents[j];
   if a<b then begin
    result.Min.RawComponents[i]:=result.Min.RawComponents[i]+a;
    result.Max.RawComponents[i]:=result.Max.RawComponents[i]+b;
   end else begin
    result.Min.RawComponents[i]:=result.Min.RawComponents[i]+b;
    result.Max.RawComponents[i]:=result.Max.RawComponents[i]+a;
   end;
  end;
 end;
end;}

function TpvAABB.Transform(const Transform:TpvMatrix4x4):TpvAABB;
var Center,Extents:TpvVector3;
begin
 Center:=(Transform*TpvVector4.InlineableCreate((Min+Max)*0.5,1.0)).xyz;
 Extents:=Transform.MulAbsBasis((Max-Min)*0.5);
 result.Min:=Center-Extents;
 result.Max:=Center+Extents;
end;
{begin
 result.Min.x:=Transform.RawComponents[3,0];
 result.Min.y:=Transform.RawComponents[3,1];
 result.Min.z:=Transform.RawComponents[3,2];
 result.Max:=result.Min;
 if Transform.RawComponents[0,0]>0.0 then begin
  result.Min.x:=result.Min.x+(Transform.RawComponents[0,0]*Min.x);
  result.Max.x:=result.Max.x+(Transform.RawComponents[0,0]*Max.x);
 end else begin
  result.Min.x:=result.Min.x+(Transform.RawComponents[0,0]*Max.x);
  result.Max.x:=result.Max.x+(Transform.RawComponents[0,0]*Min.x);
 end;
 if Transform.RawComponents[0,1]>0.0 then begin
  result.Min.y:=result.Min.y+(Transform.RawComponents[0,1]*Min.x);
  result.Max.y:=result.Max.y+(Transform.RawComponents[0,1]*Max.x);
 end else begin
  result.Min.y:=result.Min.y+(Transform.RawComponents[0,1]*Max.x);
  result.Max.y:=result.Max.y+(Transform.RawComponents[0,1]*Min.x);
 end;
 if Transform.RawComponents[0,2]>0.0 then begin
  result.Min.z:=result.Min.z+(Transform.RawComponents[0,2]*Min.x);
  result.Max.z:=result.Max.z+(Transform.RawComponents[0,2]*Max.x);
 end else begin
  result.Min.z:=result.Min.z+(Transform.RawComponents[0,2]*Max.x);
  result.Max.z:=result.Max.z+(Transform.RawComponents[0,2]*Min.x);
 end;
 if Transform.RawComponents[1,0]>0.0 then begin
  result.Min.x:=result.Min.x+(Transform.RawComponents[1,0]*Min.y);
  result.Max.x:=result.Max.x+(Transform.RawComponents[1,0]*Max.y);
 end else begin
  result.Min.x:=result.Min.x+(Transform.RawComponents[1,0]*Max.y);
  result.Max.x:=result.Max.x+(Transform.RawComponents[1,0]*Min.y);
 end;
 if Transform.RawComponents[1,1]>0.0 then begin
  result.Min.y:=result.Min.y+(Transform.RawComponents[1,1]*Min.y);
  result.Max.y:=result.Max.y+(Transform.RawComponents[1,1]*Max.y);
 end else begin
  result.Min.y:=result.Min.y+(Transform.RawComponents[1,1]*Max.y);
  result.Max.y:=result.Max.y+(Transform.RawComponents[1,1]*Min.y);
 end;
 if Transform.RawComponents[1,2]>0.0 then begin
  result.Min.z:=result.Min.z+(Transform.RawComponents[1,2]*Min.y);
  result.Max.z:=result.Max.z+(Transform.RawComponents[1,2]*Max.y);
 end else begin
  result.Min.z:=result.Min.z+(Transform.RawComponents[1,2]*Max.y);
  result.Max.z:=result.Max.z+(Transform.RawComponents[1,2]*Min.y);
 end;
 if Transform.RawComponents[2,0]>0.0 then begin
  result.Min.x:=result.Min.x+(Transform.RawComponents[2,0]*Min.z);
  result.Max.x:=result.Max.x+(Transform.RawComponents[2,0]*Max.z);
 end else begin
  result.Min.x:=result.Min.x+(Transform.RawComponents[2,0]*Max.z);
  result.Max.x:=result.Max.x+(Transform.RawComponents[2,0]*Min.z);
 end;
 if Transform.RawComponents[2,1]>0.0 then begin
  result.Min.y:=result.Min.y+(Transform.RawComponents[2,1]*Min.z);
  result.Max.y:=result.Max.y+(Transform.RawComponents[2,1]*Max.z);
 end else begin
  result.Min.y:=result.Min.y+(Transform.RawComponents[2,1]*Max.z);
  result.Max.y:=result.Max.y+(Transform.RawComponents[2,1]*Min.z);
 end;
 if Transform.RawComponents[2,2]>0.0 then begin
  result.Min.z:=result.Min.z+(Transform.RawComponents[2,2]*Min.z);
  result.Max.z:=result.Max.z+(Transform.RawComponents[2,2]*Max.z);
 end else begin
  result.Min.z:=result.Min.z+(Transform.RawComponents[2,2]*Max.z);
  result.Max.z:=result.Max.z+(Transform.RawComponents[2,2]*Min.z);
 end;
end;}
{var Size:TpvVector3;
    Basis:array[0..2] of TpvVector3;
    Temp:array[0..7] of TpvVector3;
begin
 Size:=Max-Min;
 Basis[0]:=TpvVector3.InlineableCreate(Transform.RawComponents[0,0],Transform.RawComponents[0,1],Transform.RawComponents[0,2])*Size;
 Basis[1]:=TpvVector3.InlineableCreate(Transform.RawComponents[1,0],Transform.RawComponents[1,1],Transform.RawComponents[1,2])*Size;
 Basis[2]:=TpvVector3.InlineableCreate(Transform.RawComponents[2,0],Transform.RawComponents[2,1],Transform.RawComponents[2,2])*Size;
 Temp[0]:=(Transform*TpvVector4.InlineableCreate(Min,1.0)).xyz;
 Temp[1]:=Temp[0]+Basis[0];
 Temp[2]:=Temp[0]+Basis[1];
 Temp[3]:=Temp[1]+Basis[1];
 Temp[4]:=Temp[0]+Basis[2];
 Temp[5]:=Temp[1]+Basis[2];
 Temp[6]:=Temp[2]+Basis[2];
 Temp[7]:=Temp[3]+Basis[2];
 result.Min:=Temp[0].Min(Temp[1].Min(Temp[2].Min(Temp[3].Min(Temp[4].Min(Temp[5].Min(Temp[6].Min(Temp[7])))))));
 result.Max:=Temp[0].Max(Temp[1].Max(Temp[2].Max(Temp[3].Max(Temp[4].Max(Temp[5].Max(Temp[6].Max(Temp[7])))))));
end;}
{var i,j:TpvInt32;
    a,b:TpvScalar;
begin
 result.Min.x:=Transform[3,0];
 result.Min.y:=Transform[3,1];
 result.Min.z:=Transform[3,2];
 result.Max:=result.Min;
 for i:=0 to 2 do begin
  for j:=0 to 2 do begin
   a:=Transform[j,i]*Min.RawComponents[j];
   b:=Transform[j,i]*Max.RawComponents[j];
   if a<b then begin
    result.Min.RawComponents[i]:=result.Min.RawComponents[i]+a;
    result.Max.RawComponents[i]:=result.Max.RawComponents[i]+b;
   end else begin
    result.Min.RawComponents[i]:=result.Min.RawComponents[i]+b;
    result.Max.RawComponents[i]:=result.Max.RawComponents[i]+a;
   end;
  end;
 end;
end;}

function TpvAABB.HomogenTransform(const aTransform:TpvMatrix4x4):TpvAABB;
var Center,Extents:TpvVector3;
begin
 if (abs(aTransform.RawComponents[0,3])+abs(aTransform.RawComponents[1,3])+abs(aTransform.RawComponents[2,3])+(abs(aTransform.RawComponents[3,3]-1.0))<1e-6) then begin
  // Affine => fast but more specialized code path
  Center:=(aTransform*TpvVector4.InlineableCreate((Min+Max)*0.5,1.0)).xyz;
  Extents:=aTransform.MulAbsBasis((Max-Min)*0.5);
  result.Min:=Center-Extents;
  result.Max:=Center+Extents;
 end else begin
  // Non-affine => slow but more flexible code path
  result:=MatrixMul(aTransform);
 end;
end;

function TpvAABB.MatrixMul(const Transform:TpvMatrix3x3):TpvAABB;
var Index:TpvInt32;
    v:TpvVector3;
begin
 for Index:=0 to 7 do begin
  v:=Transform*TpvVector3.InlineableCreate(MinMax[(Index shr 0) and 1].x,
                                           MinMax[(Index shr 1) and 1].y,
                                           MinMax[(Index shr 2) and 1].z);
  if Index=0 then begin
   result.Min:=v;
   result.Max:=v;
  end else begin
   if result.Min.x>v.x then begin
    result.Min.x:=v.x;
   end;
   if result.Min.y>v.y then begin
    result.Min.y:=v.y;
   end;
   if result.Min.z>v.z then begin
    result.Min.z:=v.z;
   end;
   if result.Max.x<v.x then begin
    result.Max.x:=v.x;
   end;
   if result.Max.y<v.y then begin
    result.Max.y:=v.y;
   end;
   if result.Max.z<v.z then begin
    result.Max.z:=v.z;
   end;
  end;
 end;
end;

function TpvAABB.MatrixMul(const Transform:TpvMatrix4x4):TpvAABB;
var Index:TpvInt32;
    v:TpvVector4;
begin
 for Index:=0 to 7 do begin
  v:=Transform*TpvVector4.InlineableCreate(MinMax[(Index shr 0) and 1].x,
                                           MinMax[(Index shr 1) and 1].y,
                                           MinMax[(Index shr 2) and 1].z,
                                           1.0);
  v.xyz:=v.xyz/v.w;
  if Index=0 then begin
   result.Min:=v.xyz;
   result.Max:=v.xyz;
  end else begin
   if result.Min.x>v.x then begin
    result.Min.x:=v.x;
   end;
   if result.Min.y>v.y then begin
    result.Min.y:=v.y;
   end;
   if result.Min.z>v.z then begin
    result.Min.z:=v.z;
   end;
   if result.Max.x<v.x then begin
    result.Max.x:=v.x;
   end;
   if result.Max.y<v.y then begin
    result.Max.y:=v.y;
   end;
   if result.Max.z<v.z then begin
    result.Max.z:=v.z;
   end;
  end;
 end;
end;

function TpvAABB.ScissorRect(out Scissor:TpvClipRect;const mvp:TpvMatrix4x4;const vp:TpvClipRect;zcull:boolean):boolean;
var p:TpvVector4;
    i,x,y,z_far,z_near:TpvInt32;
begin
 z_near:=0;
 z_far:=0;
 for i:=0 to 7 do begin

  // Get bound edge point
  p.x:=MinMax[i and 1].x;
  p.y:=MinMax[(i shr 1) and 1].y;
  p.z:=MinMax[(i shr 2) and 1].z;
  p.w:=1.0;

  // Project
  p:=mvp*p;
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

function TpvAABB.ScissorRect(out Scissor:TpvFloatClipRect;const mvp:TpvMatrix4x4;const vp:TpvFloatClipRect;zcull:boolean):boolean;
var p:TpvVector4;
    i,z_far,z_near:TpvInt32;
begin
 z_near:=0;
 z_far:=0;
 for i:=0 to 7 do begin

  // Get bound edge point
  p.x:=MinMax[i and 1].x;
  p.y:=MinMax[(i shr 1) and 1].y;
  p.z:=MinMax[(i shr 2) and 1].z;
  p.w:=1.0;

  // Project
  p:=mvp*p;
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

function TpvAABB.MovingTest(const aAABBTo,bAABBFrom,bAABBTo:TpvAABB;var t:TpvScalar):boolean;
var Axis,AxisSamples,Samples,Sample,FirstSample:TpvInt32;
    aAABB,bAABB:TpvAABB;
    f{,MinRadius},Size,Distance,BestDistance:TpvScalar;
    HasDistance:boolean;
begin
 if Intersect(bAABBFrom) then begin
  t:=0.0;
  result:=true;
 end else begin
  result:=false;
  if Combine(aAABBTo).Intersect(bAABBFrom.Combine(bAABBTo)) then begin
   FirstSample:=0;
   Samples:=1;
   for Axis:=0 to 2 do begin
    if Min.RawComponents[Axis]>aAABBTo.Max.RawComponents[Axis] then begin
     Distance:=Min.RawComponents[Axis]-aAABBTo.Max.RawComponents[Axis];
    end else if aAABBTo.Min.RawComponents[Axis]>Max.RawComponents[Axis] then begin
     Distance:=aAABBTo.Min.RawComponents[Axis]-Max.RawComponents[Axis];
    end else begin
     Distance:=0;
    end;
    Size:=Math.Min(abs(Max.RawComponents[Axis]-Min.RawComponents[Axis]),abs(aAABBTo.Max.RawComponents[Axis]-aAABBTo.Min.RawComponents[Axis]));
    if Size>0.0 then begin
     AxisSamples:=round((Distance+Size)/Size);
     if Samples<AxisSamples then begin
      Samples:=AxisSamples;
     end;
    end;
    if bAABBFrom.Min.RawComponents[Axis]>bAABBTo.Max.RawComponents[Axis] then begin
     Distance:=bAABBFrom.Min.RawComponents[Axis]-bAABBTo.Max.RawComponents[Axis];
    end else if bAABBTo.Min.RawComponents[Axis]>bAABBFrom.Max.RawComponents[Axis] then begin
     Distance:=bAABBTo.Min.RawComponents[Axis]-bAABBFrom.Max.RawComponents[Axis];
    end else begin
     Distance:=0;
    end;
    Size:=Math.Min(abs(bAABBFrom.Max.RawComponents[Axis]-bAABBFrom.Min.RawComponents[Axis]),abs(bAABBTo.Max.RawComponents[Axis]-bAABBTo.Min.RawComponents[Axis]));
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
    aAABB.Min:=Min.Lerp(aAABBTo.Min,f);
    aAABB.Max:=Max.Lerp(aAABBTo.Max,f);
    bAABB.Min:=bAABBFrom.Min.Lerp(bAABBTo.Min,f);
    bAABB.Max:=bAABBFrom.Max.Lerp(bAABBTo.Max,f);
    if aAABB.Intersect(bAABB) then begin
     t:=f;
     result:=true;
     break;
    end else begin
     Distance:=aAABB.DistanceTo(bAABB);
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

function TpvAABB.SweepTest(const bAABB:TpvAABB;const aV,bV:TpvVector3;var FirstTime,LastTime:TpvScalar):boolean;
var Axis:TpvInt32;
    v,tMin,tMax:TpvVector3;
begin
 if Intersect(bAABB) then begin
  FirstTime:=0.0;
  LastTime:=0.0;
  result:=true;
 end else begin
  v:=bV-aV;
  for Axis:=0 to 2 do begin
   if v.RawComponents[Axis]<0.0 then begin
    tMin.RawComponents[Axis]:=(Max.RawComponents[Axis]-bAABB.Min.RawComponents[Axis])/v.RawComponents[Axis];
    tMax.RawComponents[Axis]:=(Min.RawComponents[Axis]-bAABB.Max.RawComponents[Axis])/v.RawComponents[Axis];
   end else if v.RawComponents[Axis]>0.0 then begin
    tMin.RawComponents[Axis]:=(Min.RawComponents[Axis]-bAABB.Max.RawComponents[Axis])/v.RawComponents[Axis];
    tMax.RawComponents[Axis]:=(Max.RawComponents[Axis]-bAABB.Min.RawComponents[Axis])/v.RawComponents[Axis];
   end else if (Max.RawComponents[Axis]>=bAABB.Min.RawComponents[Axis]) and (Min.RawComponents[Axis]<=bAABB.Max.RawComponents[Axis]) then begin
    tMin.RawComponents[Axis]:=0.0;
    tMax.RawComponents[Axis]:=1.0;
   end else begin
    result:=false;
    exit;
   end;
  end;
  FirstTime:=Math.Max(Math.Max(tMin.x,tMin.y),tMin.z);
  LastTime:=Math.Min(Math.Min(tMax.x,tMax.y),tMax.z);
  result:=(LastTime>=0.0) and (FirstTime<=1.0) and (FirstTime<=LastTime);
 end;
end;

constructor TpvSphere.Create(const pCenter:TpvVector3;const pRadius:TpvScalar);
begin
 Center:=pCenter;
 Radius:=pRadius;
end;

constructor TpvSphere.Create(const aVector:TpvVector4);
begin
 Center:=aVector.xyz;
 Radius:=aVector.w;
end;

constructor TpvSphere.CreateFromAABB(const ppvAABB:TpvAABB);
begin
 Center:=(ppvAABB.Min+ppvAABB.Max)*0.5;
 Radius:=ppvAABB.Min.DistanceTo(ppvAABB.Max)*0.5;
end;

constructor TpvSphere.CreateFromFrustum(const zNear,zFar,FOV,AspectRatio:TpvScalar;const Position,Direction:TpvVector3);
var ViewLen,Width,Height:TpvScalar;
begin
 ViewLen:=zFar-zNear;
 Height:=ViewLen*tan((FOV*0.5)*DEG2RAD);
 Width:=Height*AspectRatio;
 Radius:=TpvVector3.Create(Width,Height,ViewLen).DistanceTo(TpvVector3.Create(0.0,0.0,zNear+(ViewLen*0.5)));
 Center:=Position+(Direction*((ViewLen*0.5)+zNear));
end;

function TpvSphere.ToVector4:TpvVector4;
begin
 result:=TpvVector4.InlineableCreate(Center,Radius);
end;

function TpvSphere.ToAABB(const pScale:TpvScalar=1.0):TpvAABB;
begin
 result.Min.x:=Center.x-(Radius*pScale);
 result.Min.y:=Center.y-(Radius*pScale);
 result.Min.z:=Center.z-(Radius*pScale);
 result.Max.x:=Center.x+(Radius*pScale);
 result.Max.y:=Center.y+(Radius*pScale);
 result.Max.z:=Center.z+(Radius*pScale);
end;

function TpvSphere.Cull(const p:array of TpvPlane):boolean;
var i:TpvInt32;
begin
 result:=true;
 for i:=0 to length(p)-1 do begin
  if p[i].DistanceTo(Center)<-Radius then begin
   result:=false;
   exit;
  end;
 end;
end;

function TpvSphere.Contains(const b:TpvSphere):boolean;
begin
 result:=((Radius+EPSILON)>=(b.Radius-EPSILON)) and ((Center-b.Center).Length<=((Radius+EPSILON)-(b.Radius-EPSILON)));
end;

function TpvSphere.Contains(const v:TpvVector3):boolean;
begin
 result:=Center.DistanceTo(v)<(Radius+EPSILON);
end;

function TpvSphere.DistanceTo(const b:TpvSphere):TpvScalar;
begin
 result:=Max((Center-b.Center).Length-(Radius+b.Radius),0.0);
end;

function TpvSphere.DistanceTo(const b:TpvVector3):TpvScalar;
begin
 result:=Max(Center.DistanceTo(b)-Radius,0.0);
end;

function TpvSphere.Intersect(const b:TpvSphere):boolean;
begin
 result:=(Center-b.Center).Length<=(Radius+b.Radius+(EPSILON*2.0));
end;

function TpvSphere.Intersect(const b:TpvAABB):boolean;
var c:TpvVector3;
begin
 c.x:=Min(Max(Center.x,b.Min.x),b.Max.x);
 c.y:=Min(Max(Center.y,b.Min.y),b.Max.y);
 c.z:=Min(Max(Center.z,b.Min.z),b.Max.z);
 result:=(c-Center).SquaredLength<sqr(Radius);
end;

function TpvSphere.FastRayIntersection(const Origin,Direction:TpvVector3):boolean;
var m:TpvVector3;
    p,d:TpvScalar;
begin
 m:=Origin-Center;
 p:=-m.Dot(Direction);
 d:=(sqr(p)-m.SquaredLength)+sqr(Radius);
 result:=(d>0.0) and ((p+sqrt(d))>0.0);
end;

function TpvSphere.RayIntersection(const Origin,Direction:TpvVector3;out Time:TpvScalar):boolean;
var SphereCenterToRayOrigin:TpvVector3;
    a,b,c,t0,t1:TpvScalar;
begin
 SphereCenterToRayOrigin:=Origin-Center;
 a:=Direction.SquaredLength;
 b:=2.0*SphereCenterToRayOrigin.Dot(Direction);
 c:=SphereCenterToRayOrigin.SquaredLength-sqr(Radius);
 if SolveQuadraticRoots(a,b,c,t0,t1) then begin
  if t0<0.0 then begin
   if t1<0.0 then begin
    // Sphere is behind, abort
    result:=false;
    exit;
   end else begin
    // Inside sphere
    Time:=t1;
    result:=true;
   end;
  end else begin
   if t1<0.0 then begin
    // Inside sphere
    Time:=t0;
   end else begin
    // Sphere is ahead, return the nearest value
    if t0<t1 then begin
     Time:=t0;
    end else begin
     Time:=t1;
    end;
   end;
   result:=true;
  end;
 end else begin
  result:=false;
 end;
end;

{function TpvSphere.RayIntersection(const Origin,Direction:TpvVector3;out Time:TpvScalar):boolean;
var SphereCenterToRayOrigin:TpvVector3;
    a,b,c,t0,t1,t:TpvScalar;
begin
 SphereCenterToRayOrigin:=Origin-Center;
 a:=Direction.SquaredLength;
 b:=2.0*SphereCenterToRayOrigin.Dot(Direction);
 c:=SphereCenterToRayOrigin.SquaredLength-sqr(Radius);
 if SolveQuadraticRoots(a,b,c,t0,t1) then begin
  if t0>t1 then begin
   t:=t0;
   t0:=t1;
   t1:=t;
  end;
  if t0<0.0 then begin
   t0:=t1;
   if t0<0.0 then begin
    result:=false;
    exit;
   end;
  end;
  Time:=t0;
  result:=true;
 end else begin
  result:=false;
 end;
end;}

function TpvSphere.Extends(const WithSphere:TpvSphere):TpvSphere;
var x0,y0,z0,r0,x1,y1,z1,r1,xn,yn,zn,dn,t:TpvScalar;
begin
 x0:=Center.x;
 y0:=Center.y;
 z0:=Center.z;
 r0:=Radius;

 x1:=WithSphere.Center.x;
 y1:=WithSphere.Center.y;
 z1:=WithSphere.Center.z;
 r1:=WithSphere.Radius;

 xn:=x1-x0;
 yn:=y1-y0;
 zn:=z1-z0;
 dn:=sqrt(sqr(xn)+sqr(yn)+sqr(zn));
 if abs(dn)<EPSILON then begin
  result:=self;
  exit;
 end;

 if (dn+r1)<r0 then begin
  result:=self;
  exit;
 end;

 result.Radius:=(dn+r0+r1)*0.5;
 t:=(result.Radius-r0)/dn;
 result.Center.x:=x0+(xn*t);
 result.Center.y:=y0+(xn*t);
 result.Center.z:=z0+(xn*t);
end;

function TpvSphere.Transform(const Transform:TpvMatrix4x4):TpvSphere;
begin
 result.Center:=Transform*Center;
 result.Radius:=result.Center.DistanceTo(Transform*TpvVector3.Create(Center.x,Center.y+Radius,Center.z));
end;

function TpvSphere.TriangleIntersection(const Triangle:TpvTriangle;out Position,Normal:TpvVector3;out Depth:TpvScalar):boolean;
var SegmentTriangle:TpvSegmentTriangle;
    Dist,d2,s,t:TpvScalar;
begin
 result:=false;
 if ((Triangle.Normal.Dot(Center)-Triangle.Normal.Dot(Triangle.Points[0]))-Radius)<EPSILON then begin
  SegmentTriangle.Origin:=Triangle.Points[0];
  SegmentTriangle.Edge0:=Triangle.Points[1]-Triangle.Points[0];
  SegmentTriangle.Edge1:=Triangle.Points[2]-Triangle.Points[0];
  SegmentTriangle.Edge2:=SegmentTriangle.Edge1-SegmentTriangle.Edge0;
  d2:=SegmentTriangle.SquaredPointTriangleDistance(Center,s,t);
  if d2<sqr(Radius) then begin
   Dist:=sqrt(d2);
   Depth:=Radius-Dist;
   if Dist>EPSILON then begin
    Normal:=((Center-(SegmentTriangle.Origin+((SegmentTriangle.Edge0*s)+(SegmentTriangle.Edge1*t))))).Normalize;
   end else begin
    Normal:=Triangle.Normal;
   end;
   Position:=Center-(Normal*Radius);
   result:=true;
  end;
 end;
end;

function TpvSphere.TriangleIntersection(const SegmentTriangle:TpvSegmentTriangle;const TriangleNormal:TpvVector3;out Position,Normal:TpvVector3;out Depth:TpvScalar):boolean;
var Dist,d2,s,t:TpvScalar;
begin
 result:=false;
 d2:=SegmentTriangle.SquaredPointTriangleDistance(Center,s,t);
 if d2<sqr(Radius) then begin
  Dist:=sqrt(d2);
  Depth:=Radius-Dist;
  if Dist>EPSILON then begin
   Normal:=((Center-(SegmentTriangle.Origin+((SegmentTriangle.Edge0*s)+(SegmentTriangle.Edge1*t))))).Normalize;
  end else begin
   Normal:=TriangleNormal;
  end;
  Position:=Center-(Normal*Radius);
  result:=true;
 end;
end;

function TpvSphere.SweptIntersection(const SphereB:TpvSphere;const VelocityA,VelocityB:TpvVector3;out TimeFirst,TimeLast:TpvScalar):boolean;
var ab,vab:TpvVector3;
    rab,a,b,c:TpvScalar;
begin
 result:=false;
 ab:=SphereB.Center-Center;
 vab:=VelocityB-VelocityA;
 rab:=Radius+SphereB.Radius;
 c:=ab.SquaredLength-sqr(rab);
 if c<=0.0 then begin
  TimeFirst:=0.0;
  TimeLast:=0.0;
  result:=true;
 end else begin
  a:=vab.SquaredLength;
  b:=2.0*vab.Dot(ab);
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

constructor TpvSphereCoords.CreateFromCartesianVector(const v:TpvVector3);
begin
 Radius:=v.Length;
 Theta:=ArcCos(v.z/Radius);
 Phi:=Sign(v.y)*ArcCos(v.x/sqrt(v.x*v.x+v.y*v.y));
end;

constructor TpvSphereCoords.CreateFromCartesianVector(const v:TpvVector4);
begin
 Radius:=v.Length;
 Theta:=ArcCos(v.z/Radius);
 Phi:=Sign(v.y)*ArcCos(v.x/sqrt(v.x*v.x+v.y*v.y));
end;

function TpvSphereCoords.ToCartesianVector:TpvVector3;
begin
 result.x:=Radius*sin(Theta)*cos(Phi);
 result.y:=Radius*sin(Theta)*sin(Phi);
 result.z:=Radius*cos(Theta);
end;

constructor TpvRect.CreateFromVkRect2D(const aFrom:TVkRect2D);
begin
 Left:=aFrom.offset.x;
 Top:=aFrom.offset.y;
 Right:=aFrom.offset.x+aFrom.extent.width;
 Bottom:=aFrom.offset.y+aFrom.extent.height;
end;

constructor TpvRect.CreateAbsolute(const aLeft,aTop,aRight,aBottom:TpvFloat);
begin
 Left:=aLeft;
 Top:=aTop;
 Right:=aRight;
 Bottom:=aBottom;
end;

constructor TpvRect.CreateAbsolute(const aLeftTop,aRightBottom:TpvVector2);
begin
 LeftTop:=aLeftTop;
 RightBottom:=aRightBottom;
end;

constructor TpvRect.CreateRelative(const aLeft,aTop,aWidth,aHeight:TpvFloat);
begin
 Left:=aLeft;
 Top:=aTop;
 Right:=aLeft+aWidth;
 Bottom:=aTop+aHeight;
end;

constructor TpvRect.CreateRelative(const aLeftTop,aSize:TpvVector2);
begin
 LeftTop:=aLeftTop;
 RightBottom:=aLeftTop+aSize;
end;

class operator TpvRect.Implicit(const a:TVkRect2D):TpvRect;
begin
 result:=TpvRect.CreateFromVkRect2D(a);
end;

class operator TpvRect.Explicit(const a:TVkRect2D):TpvRect;
begin
 result:=TpvRect.CreateFromVkRect2D(a);
end;

class operator TpvRect.Implicit(const a:TpvRect):TVkRect2D;
begin
 result:=a.ToVkRect2D;
end;

class operator TpvRect.Explicit(const a:TpvRect):TVkRect2D;
begin
 result:=a.ToVkRect2D;
end;

class operator TpvRect.Equal(const a,b:TpvRect):boolean;
begin
 result:=a.Vector4=b.Vector4;
end;

class operator TpvRect.NotEqual(const a,b:TpvRect):boolean;
begin
 result:=a.Vector4<>b.Vector4;
end;

function TpvRect.Cost:TpvScalar;
begin
 result:=(Max.x-Min.x)+(Max.y-Min.y); // Manhattan distance
end;

function TpvRect.Area:TpvScalar;
begin
 result:=abs(Max.x-Min.x)*abs(Max.y-Min.y);
end;

function TpvRect.Center:TpvVector2;
begin
 result.x:=(Min.x*0.5)+(Max.x*0.5);
 result.y:=(Min.y*0.5)+(Max.y*0.5);
end;

function TpvRect.Combine(const aWithRect:TpvRect):TpvRect;
begin
 result.Min.x:=Math.Min(Min.x,aWithRect.Min.x);
 result.Min.y:=Math.Min(Min.y,aWithRect.Min.y);
 result.Max.x:=Math.Max(Max.x,aWithRect.Max.x);
 result.Max.y:=Math.Max(Max.y,aWithRect.Max.y);
end;

function TpvRect.Combine(const aWithPoint:TpvVector2):TpvRect;
begin
 result.Min.x:=Math.Min(Min.x,aWithPoint.x);
 result.Min.y:=Math.Min(Min.y,aWithPoint.y);
 result.Max.x:=Math.Max(Max.x,aWithPoint.x);
 result.Max.y:=Math.Max(Max.y,aWithPoint.y);
end;

procedure TpvRect.DirectCombine(const aWithRect:TpvRect);
begin
 Min.x:=Math.Min(Min.x,aWithRect.Min.x);
 Min.y:=Math.Min(Min.y,aWithRect.Min.y);
 Max.x:=Math.Max(Max.x,aWithRect.Max.x);
 Max.y:=Math.Max(Max.y,aWithRect.Max.y);
end;

procedure TpvRect.DirectCombine(const aWithPoint:TpvVector2);
begin
 Min.x:=Math.Min(Min.x,aWithPoint.x);
 Min.y:=Math.Min(Min.y,aWithPoint.y);
 Max.x:=Math.Max(Max.x,aWithPoint.x);
 Max.y:=Math.Max(Max.y,aWithPoint.y);
end;

function TpvRect.Intersect(const aWithRect:TpvRect;Threshold:TpvScalar=EPSILON):boolean;
begin
 result:=(((Max.x+Threshold)>=(aWithRect.Min.x-Threshold)) and ((Min.x-Threshold)<=(aWithRect.Max.x+Threshold))) and
         (((Max.y+Threshold)>=(aWithRect.Min.y-Threshold)) and ((Min.y-Threshold)<=(aWithRect.Max.y+Threshold)));
end;

function TpvRect.Contains(const aWithRect:TpvRect;Threshold:TpvScalar=EPSILON):boolean;
begin
 result:=((Min.x-Threshold)<=(aWithRect.Min.x+Threshold)) and ((Min.y-Threshold)<=(aWithRect.Min.y+Threshold)) and
         ((Max.x+Threshold)>=(aWithRect.Min.x+Threshold)) and ((Max.y+Threshold)>=(aWithRect.Min.y+Threshold)) and
         ((Min.x-Threshold)<=(aWithRect.Max.x-Threshold)) and ((Min.y-Threshold)<=(aWithRect.Max.y-Threshold)) and
         ((Max.x+Threshold)>=(aWithRect.Max.x-Threshold)) and ((Max.y+Threshold)>=(aWithRect.Max.y-Threshold));
end;

function TpvRect.GetIntersection(const WithAABB:TpvRect):TpvRect;
begin
 result.Min.x:=Math.Max(Min.x,WithAABB.Min.x);
 result.Min.y:=Math.Max(Min.y,WithAABB.Min.y);
 result.Max.x:=Math.Min(Max.x,WithAABB.Max.x);
 result.Max.y:=Math.Min(Max.y,WithAABB.Max.y);
end;

function TpvRect.Touched(const aPosition:TpvVector2;Threshold:TpvScalar=EPSILON):boolean;
begin
 result:=((aPosition.x>=(Min.x-Threshold)) and (aPosition.x<=(Max.x+Threshold))) and
         ((aPosition.y>=(Min.y-Threshold)) and (aPosition.y<=(Max.y+Threshold)));
end;

function TpvRect.ToVkRect2D:TVkRect2D;
begin
 result.offset.x:=trunc(floor(Left));
 result.offset.y:=trunc(floor(Top));
 result.extent.width:=trunc(ceil(Right-Left));
 result.extent.height:=trunc(ceil(Bottom-Top));
end;

function TpvRect.GetWidth:TpvFloat;
begin
 result:=Right-Left;
end;

procedure TpvRect.SetWidth(const aWidth:TpvFloat);
begin
 Right:=Left+aWidth;
end;

function TpvRect.GetHeight:TpvFloat;
begin
 result:=Bottom-Top;
end;

procedure TpvRect.SetHeight(const aHeight:TpvFloat);
begin
 Bottom:=Top+aHeight;
end;

function TpvRect.GetSize:TpvVector2;
begin
 result:=Max-Min;
end;

procedure TpvRect.SetSize(const aSize:TpvVector2);
begin
 Max:=Min+aSize;
end;

function Exp2(const aValue:TpvDouble):TpvDouble;
begin
 result:=Power(2.0,aValue);
//result:=Exp(aValue*LN2);
end;

function Cross(const a,b:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.Cross(b);
end;

function Cross(const a,b:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.Cross(b);
end;

function Cross(const a,b:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.Cross(b);
end;

function Dot(const a,b:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a*b;
end;

function Dot(const a,b:TpvVector2):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.Dot(b);
end;

function Dot(const a,b:TpvVector3):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.Dot(b);
end;

function Dot(const a,b:TpvVector4):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.Dot(b);
end;

function Distance(const a,b:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=abs(a-b);
end;

function Distance(const a,b:TpvVector2):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.DistanceTo(b);
end;

function Distance(const a,b:TpvVector3):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.DistanceTo(b);
end;

function Distance(const a,b:TpvVector4):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.DistanceTo(b);
end;

function Len(const a:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=abs(a);
end;

function Len(const a:TpvVector2):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.Length;
end;

function Len(const a:TpvVector3):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.Length;
end;

function Len(const a:TpvVector4):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.Length;
end;

function Normalize(const a:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a;
end;

function Normalize(const a:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.Normalize;
end;

function Normalize(const a:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.Normalize;
end;

function Normalize(const a:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a.Normalize;
end;

function Minimum(const a,b:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=Min(a,b);
end;

function Minimum(const a,b:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Min(a.x,b.x);
 result.y:=Min(a.y,b.y);
end;

function Minimum(const a,b:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Min(a.x,b.x);
 result.y:=Min(a.y,b.y);
 result.z:=Min(a.z,b.z);
end;

function Minimum(const a,b:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Min(a.x,b.x);
 result.y:=Min(a.y,b.y);
 result.z:=Min(a.z,b.z);
 result.w:=Min(a.w,b.w);
end;

function Maximum(const a,b:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=Max(a,b);
end;

function Maximum(const a,b:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Max(a.x,b.x);
 result.y:=Max(a.y,b.y);
end;

function Maximum(const a,b:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Max(a.x,b.x);
 result.y:=Max(a.y,b.y);
 result.z:=Max(a.z,b.z);
end;

function Maximum(const a,b:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Max(a.x,b.x);
 result.y:=Max(a.y,b.y);
 result.z:=Max(a.z,b.z);
 result.w:=Max(a.w,b.w);
end;

function Pow(const a,b:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=Power(a,b);
end;

function Pow(const a,b:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Power(a.x,b.x);
 result.y:=Power(a.y,b.y);
end;

function Pow(const a,b:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Power(a.x,b.x);
 result.y:=Power(a.y,b.y);
 result.z:=Power(a.z,b.z);
end;

function Pow(const a,b:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Power(a.x,b.x);
 result.y:=Power(a.y,b.y);
 result.z:=Power(a.z,b.z);
 result.w:=Power(a.w,b.w);
end;

function FaceForward(const N,I:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if (N*I)>0.0 then begin
  result:=-N;
 end else begin
  result:=N;
 end;
end;

function FaceForward(const N,I:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if N.Dot(I)>0.0 then begin
  result:=-N;
 end else begin
  result:=N;
 end;
end;

function FaceForward(const N,I:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if N.Dot(I)>0.0 then begin
  result:=-N;
 end else begin
  result:=N;
 end;
end;

function FaceForward(const N,I:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if N.Dot(I)>0.0 then begin
  result:=-N;
 end else begin
  result:=N;
 end;
end;

function FaceForward(const N,I,Nref:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if (I*Nref)>0.0 then begin
  result:=-N;
 end else begin
  result:=N;
 end;
end;

function FaceForward(const N,I,Nref:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if I.Dot(Nref)>0.0 then begin
  result:=-N;
 end else begin
  result:=N;
 end;
end;

function FaceForward(const N,I,Nref:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if I.Dot(Nref)>0.0 then begin
  result:=-N;
 end else begin
  result:=N;
 end;
end;

function FaceForward(const N,I,Nref:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if I.Dot(Nref)>0.0 then begin
  result:=-N;
 end else begin
  result:=N;
 end;
end;

function Reflect(const I,N:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=I-((2.0*(N*I))*N);
end;

function Reflect(const I,N:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=I-((2.0*N.Dot(I))*N);
end;

function Reflect(const I,N:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=I-((2.0*N.Dot(I))*N);
end;

function Reflect(const I,N:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=I-((2.0*N.Dot(I))*N);
end;

function Refract(const I,N:TpvScalar;const Eta:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
var NdotI,k:TpvScalar;
begin
 NdotI:=N*I;
 k:=1.0-(sqr(Eta)*(1.0-sqr(NdotI)));
 if k>=0.0 then begin
  result:=((Eta*I)-((Eta*NdotI)+sqrt(k))*N);
 end else begin
  result:=0.0;
 end;
end;

function Refract(const I,N:TpvVector2;const Eta:TpvScalar):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
var NdotI,k:TpvScalar;
begin
 NdotI:=N.Dot(I);
 k:=1.0-(sqr(Eta)*(1.0-sqr(NdotI)));
 if k>=0.0 then begin
  result:=((Eta*I)-((Eta*NdotI)+sqrt(k))*N);
 end else begin
  result:=0.0;
 end;
end;

function Refract(const I,N:TpvVector3;const Eta:TpvScalar):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
var NdotI,k:TpvScalar;
begin
 NdotI:=N.Dot(I);
 k:=1.0-(sqr(Eta)*(1.0-sqr(NdotI)));
 if k>=0.0 then begin
  result:=((Eta*I)-((Eta*NdotI)+sqrt(k))*N);
 end else begin
  result:=0.0;
 end;
end;

function Refract(const I,N:TpvVector4;const Eta:TpvScalar):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
var NdotI,k:TpvScalar;
begin
 NdotI:=N.Dot(I);
 k:=1.0-(sqr(Eta)*(1.0-sqr(NdotI)));
 if k>=0.0 then begin
  result:=((Eta*I)-((Eta*NdotI)+sqrt(k))*N);
 end else begin
  result:=0.0;
 end;
end;

function Clamp(const Value,MinValue,MaxValue:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=Min(Max(Value,MinValue),MaxValue);
end;

function Clamp(const Value,MinValue,MaxValue:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Min(Max(Value.x,MinValue.x),MaxValue.x);
 result.y:=Min(Max(Value.y,MinValue.y),MaxValue.y);
end;

function Clamp(const Value,MinValue,MaxValue:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Min(Max(Value.x,MinValue.x),MaxValue.x);
 result.y:=Min(Max(Value.y,MinValue.y),MaxValue.y);
 result.z:=Min(Max(Value.z,MinValue.z),MaxValue.z);
end;

function Clamp(const Value,MinValue,MaxValue:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Min(Max(Value.x,MinValue.x),MaxValue.x);
 result.y:=Min(Max(Value.y,MinValue.y),MaxValue.y);
 result.z:=Min(Max(Value.z,MinValue.z),MaxValue.z);
 result.w:=Min(Max(Value.w,MinValue.w),MaxValue.w);
end;

function Mix(const a,b,t:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if t<=0.0 then begin
  result:=a;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result:=(a*(1.0-t))+(b*t);
 end;
end;

function Mix(const a,b,t:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Mix(a.x,b.x,t.x);
 result.y:=Mix(a.y,b.y,t.y);
end;

function Mix(const a,b,t:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Mix(a.x,b.x,t.x);
 result.y:=Mix(a.y,b.y,t.y);
 result.z:=Mix(a.z,b.z,t.z);
end;

function Mix(const a,b,t:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Mix(a.x,b.x,t.x);
 result.y:=Mix(a.y,b.y,t.y);
 result.z:=Mix(a.z,b.z,t.z);
 result.w:=Mix(a.w,b.w,t.w);
end;

function Step(const Edge,Value:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if Value<Edge then begin
  result:=0.0;
 end else begin
  result:=1.0;
 end;
end;

function Step(const Edge,Value:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Step(Edge.x,Value.x);
 result.y:=Step(Edge.y,Value.y);
end;

function Step(const Edge,Value:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Step(Edge.x,Value.x);
 result.y:=Step(Edge.y,Value.y);
 result.z:=Step(Edge.z,Value.z);
end;

function Step(const Edge,Value:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=Step(Edge.x,Value.x);
 result.y:=Step(Edge.y,Value.y);
 result.z:=Step(Edge.z,Value.z);
 result.w:=Step(Edge.w,Value.w);
end;

function NearestStep(const Edge0,Edge1,Value:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=(Value-Edge0)/(Edge1-Edge0);
 if result<0.5 then begin
  result:=0.0;
 end else begin
  result:=1.0;
 end;
end;

function NearestStep(const Edge0,Edge1,Value:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=NearestStep(Edge0.x,Edge1.x,Value.x);
 result.y:=NearestStep(Edge0.y,Edge1.y,Value.y);
end;

function NearestStep(const Edge0,Edge1,Value:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=NearestStep(Edge0.x,Edge1.x,Value.x);
 result.y:=NearestStep(Edge0.y,Edge1.y,Value.y);
 result.z:=NearestStep(Edge0.z,Edge1.z,Value.z);
end;

function NearestStep(const Edge0,Edge1,Value:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=NearestStep(Edge0.x,Edge1.x,Value.x);
 result.y:=NearestStep(Edge0.y,Edge1.y,Value.y);
 result.z:=NearestStep(Edge0.z,Edge1.z,Value.z);
 result.w:=NearestStep(Edge0.w,Edge1.w,Value.w);
end;

function LinearStep(const Edge0,Edge1,Value:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=(Value-Edge0)/(Edge1-Edge0);
 if result<=0.0 then begin
  result:=0.0;
 end else if result>=1.0 then begin
  result:=1.0;
 end;
end;

function LinearStep(const Edge0,Edge1,Value:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=LinearStep(Edge0.x,Edge1.x,Value.x);
 result.y:=LinearStep(Edge0.y,Edge1.y,Value.y);
end;

function LinearStep(const Edge0,Edge1,Value:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=LinearStep(Edge0.x,Edge1.x,Value.x);
 result.y:=LinearStep(Edge0.y,Edge1.y,Value.y);
 result.z:=LinearStep(Edge0.z,Edge1.z,Value.z);
end;

function LinearStep(const Edge0,Edge1,Value:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=LinearStep(Edge0.x,Edge1.x,Value.x);
 result.y:=LinearStep(Edge0.y,Edge1.y,Value.y);
 result.z:=LinearStep(Edge0.z,Edge1.z,Value.z);
 result.w:=LinearStep(Edge0.w,Edge1.w,Value.w);
end;

function SmoothStep(const Edge0,Edge1,Value:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=(Value-Edge0)/(Edge1-Edge0);
 if result<=0.0 then begin
  result:=0.0;
 end else if result>=1.0 then begin
  result:=1.0;
 end else begin
  result:=sqr(result)*(3.0-(2.0*result));
 end;
end;

function SmoothStep(const Edge0,Edge1,Value:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=SmoothStep(Edge0.x,Edge1.x,Value.x);
 result.y:=SmoothStep(Edge0.y,Edge1.y,Value.y);
end;

function SmoothStep(const Edge0,Edge1,Value:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=SmoothStep(Edge0.x,Edge1.x,Value.x);
 result.y:=SmoothStep(Edge0.y,Edge1.y,Value.y);
 result.z:=SmoothStep(Edge0.z,Edge1.z,Value.z);
end;

function SmoothStep(const Edge0,Edge1,Value:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=SmoothStep(Edge0.x,Edge1.x,Value.x);
 result.y:=SmoothStep(Edge0.y,Edge1.y,Value.y);
 result.z:=SmoothStep(Edge0.z,Edge1.z,Value.z);
 result.w:=SmoothStep(Edge0.w,Edge1.w,Value.w);
end;

function SmootherStep(const Edge0,Edge1,Value:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=(Value-Edge0)/(Edge1-Edge0);
 if result<=0.0 then begin
  result:=0.0;
 end else if result>=1.0 then begin
  result:=1.0;
 end else begin
  result:=(sqr(result)*result)*(result*((result*6.0)-15.0)+10);
 end;
end;

function SmootherStep(const Edge0,Edge1,Value:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=SmootherStep(Edge0.x,Edge1.x,Value.x);
 result.y:=SmootherStep(Edge0.y,Edge1.y,Value.y);
end;

function SmootherStep(const Edge0,Edge1,Value:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=SmootherStep(Edge0.x,Edge1.x,Value.x);
 result.y:=SmootherStep(Edge0.y,Edge1.y,Value.y);
 result.z:=SmootherStep(Edge0.z,Edge1.z,Value.z);
end;

function SmootherStep(const Edge0,Edge1,Value:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=SmootherStep(Edge0.x,Edge1.x,Value.x);
 result.y:=SmootherStep(Edge0.y,Edge1.y,Value.y);
 result.z:=SmootherStep(Edge0.z,Edge1.z,Value.z);
 result.w:=SmootherStep(Edge0.w,Edge1.w,Value.w);
end;

function SmoothestStep(const Edge0,Edge1,Value:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=(Value-Edge0)/(Edge1-Edge0);
 if result<=0.0 then begin
  result:=0.0;
 end else if result>=1.0 then begin
  result:=1.0;
 end else begin
  result:=((((-20.0)*sqr(result)*result)+(70.0*sqr(result)))-(84.0*result)+35.0)*sqr(sqr(result));
 end;
end;

function SmoothestStep(const Edge0,Edge1,Value:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=SmoothestStep(Edge0.x,Edge1.x,Value.x);
 result.y:=SmoothestStep(Edge0.y,Edge1.y,Value.y);
end;

function SmoothestStep(const Edge0,Edge1,Value:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=SmoothestStep(Edge0.x,Edge1.x,Value.x);
 result.y:=SmoothestStep(Edge0.y,Edge1.y,Value.y);
 result.z:=SmoothestStep(Edge0.z,Edge1.z,Value.z);
end;

function SmoothestStep(const Edge0,Edge1,Value:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=SmoothestStep(Edge0.x,Edge1.x,Value.x);
 result.y:=SmoothestStep(Edge0.y,Edge1.y,Value.y);
 result.z:=SmoothestStep(Edge0.z,Edge1.z,Value.z);
 result.w:=SmoothestStep(Edge0.w,Edge1.w,Value.w);
end;

function SuperSmoothestStep(const Edge0,Edge1,Value:TpvScalar):TpvScalar; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=(Value-Edge0)/(Edge1-Edge0);
 if result<=0.0 then begin
  result:=0.0;
 end else if result>=1.0 then begin
  result:=1.0;
 end else begin
  result:=0.5-(cos((0.5-(cos(result*PI)*0.5))*PI)*0.5);
 end;
end;

function SuperSmoothestStep(const Edge0,Edge1,Value:TpvVector2):TpvVector2; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=SuperSmoothestStep(Edge0.x,Edge1.x,Value.x);
 result.y:=SuperSmoothestStep(Edge0.y,Edge1.y,Value.y);
end;

function SuperSmoothestStep(const Edge0,Edge1,Value:TpvVector3):TpvVector3; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=SuperSmoothestStep(Edge0.x,Edge1.x,Value.x);
 result.y:=SuperSmoothestStep(Edge0.y,Edge1.y,Value.y);
 result.z:=SuperSmoothestStep(Edge0.z,Edge1.z,Value.z);
end;

function SuperSmoothestStep(const Edge0,Edge1,Value:TpvVector4):TpvVector4; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result.x:=SuperSmoothestStep(Edge0.x,Edge1.x,Value.x);
 result.y:=SuperSmoothestStep(Edge0.y,Edge1.y,Value.y);
 result.z:=SuperSmoothestStep(Edge0.z,Edge1.z,Value.z);
 result.w:=SuperSmoothestStep(Edge0.w,Edge1.w,Value.w);
end;

procedure DoCalculateInterval(const Vertices:PpvVector3Array;const Count:TpvInt32;const Axis:TpvVector3;out OutMin,OutMax:TpvScalar);
var Distance:TpvScalar;
    Index:TpvInt32;
begin
 Distance:=Vertices^[0].Dot(Axis);
 OutMin:=Distance;
 OutMax:=Distance;
 for Index:=1 to Count-1 do begin
  Distance:=Vertices^[Index].Dot(Axis);
  if OutMin>Distance then begin
   OutMin:=Distance;
  end;
  if OutMax<Distance then begin
   OutMax:=Distance;
  end;
 end;
end;

function DoSpanIntersect(const Vertices1:PpvVector3Array;const Count1:TpvInt32;const Vertices2:PpvVector3Array;const Count2:TpvInt32;const AxisTest:TpvVector3;out AxisPenetration:TpvVector3):TpvScalar;
var min1,max1,min2,max2,len1,len2:TpvScalar;
begin
 AxisPenetration:=AxisTest.Normalize;
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
   AxisPenetration:=-AxisPenetration;
  end;
 end;
end;

function BoxGetDistanceToPoint(Point:TpvVector3;const Center,Size:TpvVector3;const InvTransformMatrix,TransformMatrix:TpvMatrix4x4;var ClosestBoxPoint:TpvVector3):TpvScalar;
var HalfSize:TpvVector3;
begin
 result:=0;
 ClosestBoxPoint:=(InvTransformMatrix*Point)-Center;
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
 ClosestBoxPoint:=TransformMatrix*(ClosestBoxPoint+Center);
end;

function GetDistanceFromLine(const p0,p1,p:TpvVector3;var Projected:TpvVector3;const Time:PpvScalar=nil):TpvScalar;
var p10:TpvVector3;
    t:TpvScalar;
begin
 p10:=p1-p0;
 t:=p10.Length;
 if t<EPSILON then begin
  p10:=TpvVector3.Origin;
 end else begin
  p10:=p10/t;
 end;
 t:=p10.Dot(p-p0);
 if assigned(Time) then begin
  Time^:=t;
 end;
 Projected:=p0+(p10*t);
 result:=(p-Projected).Length;
end;

procedure LineClosestApproach(const pa,ua,pb,ub:TpvVector3;var Alpha,Beta:TpvScalar);
var p:TpvVector3;
    uaub,q1,q2,d:TpvScalar;
begin
 p:=pb-pa;
 uaub:=ua.Dot(ub);
 q1:=ua.Dot(p);
 q2:=ub.Dot(p);
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

procedure ClosestLineBoxPoints(const p1,p2,c:TpvVector3;const ir,r:TpvMatrix4x4;const side:TpvVector3;var lret,bret:TpvVector3);
const tanchorepsilon:TpvFloat={$ifdef physicsdouble}1e-307{$else}1e-19{$endif};
var tmp,s,v,sign,v2,h:TpvVector3;
    region:array[0..2] of TpvInt32;
    tanchor:array[0..2] of TpvScalar;
    i:TpvInt32;
    t,dd2dt,nextt,nextdd2dt:TpvScalar;
    DoGetAnswer:boolean;
begin
 s:=ir*(p1-c);
 v:=ir*(p2-p1);
 for i:=0 to 2 do begin
  if v.RawComponents[i]<0 then begin
   s.RawComponents[i]:=-s.RawComponents[i];
   v.RawComponents[i]:=-v.RawComponents[i];
   sign.RawComponents[i]:=-1;
  end else begin
   sign.RawComponents[i]:=1;
  end;
 end;
 v2:=v*v;
 h:=side*0.5;
 for i:=0 to 2 do begin
  if v.RawComponents[i]>tanchorepsilon then begin
   if s.RawComponents[i]<-h.RawComponents[i] then begin
    region[i]:=-1;
    tanchor[i]:=((-h.RawComponents[i])-s.RawComponents[i])/v.RawComponents[i];
   end else begin
    if s.RawComponents[i]>h.RawComponents[i] then begin
     region[i]:=1;
    end else begin
     region[i]:=0;
    end;
    tanchor[i]:=(h.RawComponents[i]-s.RawComponents[i])/v.RawComponents[i];
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
   dd2dt:=dd2dt-(v2.RawComponents[i]*tanchor[i]);
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
     nextdd2dt:=nextdd2dt+(v2.RawComponents[i]*(nextt-tanchor[i]));
    end;
   end;
   if nextdd2dt>=0 then begin
    t:=t-(dd2dt/((nextdd2dt-dd2dt)/(nextt-t)));
    DoGetAnswer:=true;
    break;
   end;
   for i:=0 to 2 do begin
    if abs(tanchor[i]-nextt)<EPSILON then begin
     tanchor[i]:=(h.RawComponents[i]-s.RawComponents[i])/v.RawComponents[i];
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
 lret:=p1+((p2-p1)*t);
 for i:=0 to 2 do begin
  tmp.RawComponents[i]:=sign.RawComponents[i]*(s.RawComponents[i]+(t*v.RawComponents[i]));
  if tmp.RawComponents[i]<-h.RawComponents[i] then begin
   tmp.RawComponents[i]:=-h.RawComponents[i];
  end else if tmp.RawComponents[i]>h.RawComponents[i] then begin
   tmp.RawComponents[i]:=h.RawComponents[i];
  end;
 end;
 bret:=c+(r*tmp);
end;

procedure ClosestLineSegmentPoints(const a0,a1,b0,b1:TpvVector3;var cp0,cp1:TpvVector3);
var a0a1,b0b1,a0b0,a0b1,a1b0,a1b1,n:TpvVector3;
    la,lb,k,da0,da1,da2,da3,db0,db1,db2,db3,det,Alpha,Beta:TpvScalar;
begin
 a0a1:=a1-a0;
 b0b1:=b1-b0;
 a0b0:=b0-a0;
 da0:=a0a1.Dot(a0b0);
 db0:=b0b1.Dot(a0b0);
 if (da0<=0) and (db0>=0) then begin
  cp0:=a0;
  cp1:=b0;
  exit;
 end;
 a0b1:=b1-a0;
 da1:=a0a1.Dot(a0b1);
 db1:=b0b1.Dot(a0b1);
 if (da1<=0) and (db1<=0) then begin
  cp0:=a0;
  cp1:=b1;
  exit;
 end;
 a1b0:=b0-a1;
 da2:=a0a1.Dot(a1b0);
 db2:=b0b1.Dot(a1b0);
 if (da2>=0) and (db2>=0) then begin
  cp0:=a1;
  cp1:=b0;
  exit;
 end;
 a1b1:=b1-a1;
 da3:=a0a1.Dot(a1b1);
 db3:=b0b1.Dot(a1b1);
 if (da3>=0) and (db3<=0) then begin
  cp0:=a1;
  cp1:=b1;
  exit;
 end;
 la:=a0a1.Dot(a0a1);
 if (da0>=0) and (da2<=0) then begin
  k:=da0/la;
  n:=a0b0-(a0a1*k);
  if b0b1.Dot(n)>=0 then begin
   cp0:=a0+(a0a1*k);
   cp1:=b0;
   exit;
  end;
 end;
 if (da1>=0) and (da3<=0) then begin
  k:=da1/la;
  n:=a0b1-(a0a1*k);
  if b0b1.Dot(n)<=0 then begin
   cp0:=a0+(a0a1*k);
   cp1:=b1;
   exit;
  end;
 end;
 lb:=b0b1.Dot(b0b1);
 if (db0<=0) and (db1>=0) then begin
  k:=-db0/lb;
  n:=(b0b1*k)-a0a1;
  if a0a1.Dot(n)>=0 then begin
   cp0:=a0;
   cp1:=b0+(b0b1*k);
   exit;
  end;
 end;
 if (db2<=0) and (db3>=0) then begin
  k:=-db2/lb;
  n:=(b0b1*k)-a1b0;
  if a0a1.Dot(n)>=0 then begin
   cp0:=a1;
   cp1:=b0+(b0b1*k);
   exit;
  end;
 end;
 k:=a0a1.Dot(b0b1);
 det:=(la*lb)-sqr(k);
 if det<=EPSILON then begin
  cp0:=a0;
  cp1:=b0;
 end else begin
  det:=1/det;
  Alpha:=((lb*da0)-(k*db0))*det;
  Beta:=((k*da0)-(la*db0))*det;
  cp0:=a0+(a0a1*Alpha);
  cp1:=b0+(b0b1*Beta);
 end;
end;

function LineSegmentIntersection(const a0,a1,b0,b1:TpvVector3;const p:PpvVector3=nil):boolean;
var da,db,dc,cdadb:TpvVector3;
    t:TpvScalar;
begin
 result:=false;
 da:=a1-a0;
 db:=b1-b0;
 dc:=b0-a0;
 cdadb:=da.Cross(db);
 if abs(cdadb.Dot(dc))>EPSILON then begin
  // Lines are not coplanar
  exit;
 end;
 t:=dc.Cross(db).Dot(cdadb)/cdadb.SquaredLength;
 if (t>=0.0) and (t<=1.0) then begin
  if assigned(p) then begin
   p^:=a0.Lerp(a1,t);
  end;
  result:=true;
 end;
end;

function LineLineIntersection(const a0,a1,b0,b1:TpvVector3;const pa:PpvVector3=nil;const pb:PpvVector3=nil;const ta:PpvScalar=nil;const tb:PpvScalar=nil):boolean;
var p02,p32,p10:TpvVector3;
    d0232,d3210,d0210,d3232,d1010,Numerator,Denominator,lta,ltb:TpvScalar;
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
   pa^:=a0.Lerp(a1,lta);
  end;
  if assigned(pb) then begin
   pb^:=b0.Lerp(b1,ltb);
  end;
 end;

 result:=true;
end;

function IsPointsSameSide(const p0,p1,Origin,Direction:TpvVector3):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=Direction.Cross(p0-Origin).Dot(Direction.Cross(p1-Origin))>=0.0;
end;

function PointInTriangle(const p0,p1,p2,Normal,p:TpvVector3):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
var r0,r1,r2:TpvScalar;
begin
 r0:=(p1-p0).Cross(Normal).Dot(p-p0);
 r1:=(p2-p1).Cross(Normal).Dot(p-p1);
 r2:=(p0-p2).Cross(Normal).Dot(p-p2);
 result:=((r0>0.0) and (r1>0.0) and (r2>0.0)) or ((r0<=0.0) and (r1<=0.0) and (r2<=0.0));
end;

function PointInTriangle(const p0,p1,p2,p:TpvVector3):boolean; overload; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=IsPointsSameSide(p,p0,p1,p2-p1) and
         IsPointsSameSide(p,p1,p0,p2-p0) and
         IsPointsSameSide(p,p2,p0,p1-p0);
end;

function GetOverlap(const MinA,MaxA,MinB,MaxB:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
var Mins,Maxs:TpvScalar;
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

function OldTriangleTriangleIntersection(const a0,a1,a2,b0,b1,b2:TpvVector3):boolean;
const EPSILON=1e-2;
      LINEEPSILON=1e-6;
var Index,NextIndex,RemainingIndex,i,j,k,h:TpvInt32;
    tS,tT0,tT1:TpvScalar;
    v:array[0..1,0..2] of TpvVector3;
    SegmentTriangles:array[0..1] of TpvSegmentTriangle;
    Segment:TpvRelativeSegment;
    lv,plv:TpvVector3;
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
 SegmentTriangles[0].Edge0:=a1-a0;
 SegmentTriangles[0].Edge1:=a2-a0;
 SegmentTriangles[1].Origin:=b0;
 SegmentTriangles[1].Edge0:=b1-b0;
 SegmentTriangles[1].Edge1:=b2-b0;
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
     Segment.Delta:=v[0,NextIndex]-v[0,Index];
     j:=1;
    end;
    1:begin
     Segment.Origin:=v[1,Index];
     Segment.Delta:=v[1,NextIndex]-v[1,Index];
     j:=0;
    end;
    2:begin
     Segment.Origin:=v[0,Index];
     Segment.Delta:=((v[0,NextIndex]+v[0,RemainingIndex])*0.5)-v[0,Index];
     j:=1;
    end;
    else begin
     Segment.Origin:=v[1,Index];
     Segment.Delta:=((v[1,NextIndex]+v[1,RemainingIndex])*0.5)-v[1,Index];
     j:=0;
    end;
   end;
   if SegmentTriangles[j].RelativeSegmentIntersection(Segment,tS,tT0,tT1) then begin
    OK:=true;
    if i<2 then begin
     lv:=Segment.Origin+(Segment.Delta*tS);
     for k:=0 to 2 do begin
      h:=k+1;
      if h>2 then begin
       dec(h,2);
      end;
      if GetDistanceFromLine(v[j,k],v[j,h],lv,plv)<EPSILON then begin
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

function TriangleTriangleIntersection(const v0,v1,v2,u0,u1,u2:TpvVector3):boolean;
const EPSILON=1e-6;
 procedure SORT(var a,b:TpvScalar); {$ifdef CAN_INLINE}inline;{$endif}
 var c:TpvScalar;
 begin
  if a>b then begin
   c:=a;
   a:=b;
   b:=c;
  end;
 end;
 procedure ISECT(const VV0,VV1,VV2,D0,D1,D2:TpvScalar;var isect0,isect1:TpvScalar); {$ifdef CAN_INLINE}inline;{$endif}
 begin
  isect0:=VV0+(((VV1-VV0)*D0)/(D0-D1));
  isect1:=VV0+(((VV2-VV0)*D0)/(D0-D2));
 end;
 function EDGE_EDGE_TEST(const v0,u0,u1:TpvVector3;const Ax,Ay:TpvScalar;const i0,i1:TpvInt32):boolean; {$ifdef CAN_INLINE}inline;{$endif}
 var Bx,By,Cx,Cy,e,f,d:TpvScalar;
 begin
  result:=false;
  Bx:=U0.RawComponents[i0]-U1.RawComponents[i0];
  By:=U0.RawComponents[i1]-U1.RawComponents[i1];
  Cx:=V0.RawComponents[i0]-U0.RawComponents[i0];
  Cy:=V0.RawComponents[i1]-U0.RawComponents[i1];
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
 function POINT_IN_TRI(const v0,u0,u1,u2:TpvVector3;const i0,i1:TpvInt32):boolean;
 var a,b,c,d0,d1,d2:TpvScalar;
 begin

  // is T1 completly inside T2?
  // check if V0 is inside tri(U0,U1,U2)

  a:=U1.RawComponents[i1]-U0.RawComponents[i1];
  b:=-(U1.RawComponents[i0]-U0.RawComponents[i0]);
  c:=(-(a*U0.RawComponents[i0]))-(b*U0.RawComponents[i1]);
  d0:=((a*V0.RawComponents[i0])+(b*V0.RawComponents[i1]))+c;

  a:=U2.RawComponents[i1]-U1.RawComponents[i1];
  b:=-(U2.RawComponents[i0]-U1.RawComponents[i0]);
  c:=(-(a*U1.RawComponents[i0]))-(b*U1.RawComponents[i1]);
  d1:=((a*V0.RawComponents[i0])+(b*V0.RawComponents[i1]))+c;

  a:=U0.RawComponents[i1]-U2.RawComponents[i1];
  b:=-(U0.RawComponents[i0]-U2.RawComponents[i0]);
  c:=(-(a*U2.RawComponents[i0]))-(b*U2.RawComponents[i1]);
  d2:=((a*V0.RawComponents[i0])+(b*V0.RawComponents[i1]))+c;

  result:=((d0*d1)>0.0) and ((d0*d2)>0.0);
 end;
 function EDGE_AGAINST_TRI_EDGES(const v0,v1,u0,u1,u2:TpvVector3;const i0,i1:TpvInt32):boolean;
 var Ax,Ay:TpvScalar;
 begin
  Ax:=v1.RawComponents[i0]-v0.RawComponents[i0];
  Ay:=v1.RawComponents[i1]-v0.RawComponents[i1];
  result:=EDGE_EDGE_TEST(V0,U0,U1,Ax,Ay,i0,i1) or // test edge U0,U1 against V0,V1
          EDGE_EDGE_TEST(V0,U1,U2,Ax,Ay,i0,i1) or // test edge U1,U2 against V0,V1
          EDGE_EDGE_TEST(V0,U2,U0,Ax,Ay,i0,i1);   // test edge U2,U1 against V0,V1
 end;
 function coplanar_tri_tri(const n,v0,v1,v2,u0,u1,u2:TpvVector3):boolean;
 var i0,i1:TpvInt32;
     a:TpvVector3;
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
 function COMPUTE_INTERVALS(const N1:TpvVector3;const VV0,VV1,VV2,D0,D1,D2,D0D1,D0D2:TpvScalar;var isect0,isect1:TpvScalar):boolean;
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
var index:TpvInt32;
    d1,d2,du0,du1,du2,dv0,dv1,dv2,du0du1,du0du2,dv0dv1,dv0dv2,vp0,vp1,vp2,up0,up1,up2,b,c,m:TpvScalar;
    isect1,isect2:array[0..1] of TpvScalar;
    e1,e2,n1,n2,d:TpvVector3;
begin

 result:=false;

 // compute plane equation of triangle(V0,V1,V2)
 e1:=v1-v0;
 e2:=v2-v0;
 n1:=e1.Cross(e2);
 d1:=-n1.Dot(v0);

 // put U0,U1,U2 into plane equation 1 to compute signed distances to the plane
 du0:=n1.Dot(u0)+d1;
 du1:=n1.Dot(u1)+d1;
 du2:=n1.Dot(u2)+d1;

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
 e1:=u1-u0;
 e2:=u2-u0;
 n2:=e1.Cross(e2);
 d2:=-n2.Dot(u0);

 // put V0,V1,V2 into plane equation 2
 dv0:=n2.Dot(v0)+d2;
 dv1:=n2.Dot(v1)+d2;
 dv2:=n2.Dot(v2)+d2;

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
 d:=n1.Cross(n2);

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
//m:=c;
  index:=2;
 end;

 // this is the simplified projection onto L
 vp0:=v0.RawComponents[index];
 vp1:=v1.RawComponents[index];
 vp2:=v2.RawComponents[index];

 up0:=u0.RawComponents[index];
 up1:=u1.RawComponents[index];
 up2:=u2.RawComponents[index];

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

function UnclampedClosestPointToLine(const LineStartPoint,LineEndPoint,Point:TpvVector3;const ClosestPointOnLine:PpvVector3=nil;const Time:PpvScalar=nil):TpvScalar;
var LineSegmentPointsDifference,ClosestPoint:TpvVector3;
    LineSegmentLengthSquared,PointOnLineSegmentTime:TpvScalar;
begin
 LineSegmentPointsDifference:=LineEndPoint-LineStartPoint;
 LineSegmentLengthSquared:=LineSegmentPointsDifference.SquaredLength;
 if LineSegmentLengthSquared<EPSILON then begin
  PointOnLineSegmentTime:=0.0;
  ClosestPoint:=LineStartPoint;
 end else begin
  PointOnLineSegmentTime:=(Point-LineStartPoint).Dot(LineSegmentPointsDifference)/LineSegmentLengthSquared;
  ClosestPoint:=LineStartPoint+(LineSegmentPointsDifference*PointOnLineSegmentTime);
 end;
 if assigned(ClosestPointOnLine) then begin
  ClosestPointOnLine^:=ClosestPoint;
 end;
 if assigned(Time) then begin
  Time^:=PointOnLineSegmentTime;
 end;
 result:=Point.DistanceTo(ClosestPoint);
end;

function ClosestPointToLine(const LineStartPoint,LineEndPoint,Point:TpvVector3;const ClosestPointOnLine:PpvVector3=nil;const Time:PpvScalar=nil):TpvScalar;
var LineSegmentPointsDifference,ClosestPoint:TpvVector3;
    LineSegmentLengthSquared,PointOnLineSegmentTime:TpvScalar;
begin
 LineSegmentPointsDifference:=LineEndPoint-LineStartPoint;
 LineSegmentLengthSquared:=LineSegmentPointsDifference.SquaredLength;
 if LineSegmentLengthSquared<EPSILON then begin
  PointOnLineSegmentTime:=0.0;
  ClosestPoint:=LineStartPoint;
 end else begin
  PointOnLineSegmentTime:=(Point-LineStartPoint).Dot(LineSegmentPointsDifference)/LineSegmentLengthSquared;
  if PointOnLineSegmentTime<=0.0 then begin
   PointOnLineSegmentTime:=0.0;
   ClosestPoint:=LineStartPoint;
  end else if PointOnLineSegmentTime>=1.0 then begin
   PointOnLineSegmentTime:=1.0;
   ClosestPoint:=LineEndPoint;
  end else begin
   ClosestPoint:=LineStartPoint+(LineSegmentPointsDifference*PointOnLineSegmentTime);
  end;
 end;
 if assigned(ClosestPointOnLine) then begin
  ClosestPointOnLine^:=ClosestPoint;
 end;
 if assigned(Time) then begin
  Time^:=PointOnLineSegmentTime;
 end;
 result:=Point.DistanceTo(ClosestPoint);
end;

function ClosestPointToRect(const Rect:TpvRect;const Point:TpvVector2;const ClosestPointOnRect:PpvVector2):TpvScalar; //{$ifdef CAN_INLINE}inline;{$endif}
var ClosestPoint:TpvVector2;
begin
 ClosestPoint.x:=Min(Max(Point.x,Rect.Min.x),Rect.Max.x);
 ClosestPoint.y:=Min(Max(Point.y,Rect.Min.y),Rect.Max.y);
 if assigned(ClosestPointOnRect) then begin
  ClosestPointOnRect^:=ClosestPoint;
 end;
 result:=ClosestPoint.DistanceTo(Point);
end;

function ClosestPointToAABB(const AABB:TpvAABB;const Point:TpvVector3;const ClosestPointOnAABB:PpvVector3):TpvScalar; //{$ifdef CAN_INLINE}inline;{$endif}
var ClosestPoint:TpvVector3;
begin
 ClosestPoint.x:=Min(Max(Point.x,AABB.Min.x),AABB.Max.x);
 ClosestPoint.y:=Min(Max(Point.y,AABB.Min.y),AABB.Max.y);
 ClosestPoint.z:=Min(Max(Point.z,AABB.Min.z),AABB.Max.z);
 if assigned(ClosestPointOnAABB) then begin
  ClosestPointOnAABB^:=ClosestPoint;
 end;
 result:=ClosestPoint.DistanceTo(Point);
end;

function ClosestPointToOBB(const OBB:TpvOBB;const Point:TpvVector3;out ClosestPoint:TpvVector3):TpvScalar; //{$ifdef CAN_INLINE}inline;{$endif}
var DistanceVector:TpvVector3;
begin
 DistanceVector:=Point-OBB.Center;
 ClosestPoint:=OBB.Center+
               (OBB.Axis[0]*Min(Max(DistanceVector.Dot(OBB.Axis[0]),-OBB.HalfExtents.RawComponents[0]),OBB.HalfExtents.RawComponents[0]))+
               (OBB.Axis[1]*Min(Max(DistanceVector.Dot(OBB.Axis[1]),-OBB.HalfExtents.RawComponents[1]),OBB.HalfExtents.RawComponents[1]))+
               (OBB.Axis[2]*Min(Max(DistanceVector.Dot(OBB.Axis[2]),-OBB.HalfExtents.RawComponents[2]),OBB.HalfExtents.RawComponents[2]));
 result:=ClosestPoint.DistanceTo(Point);
end;

function ClosestPointToSphere(const Sphere:TpvSphere;const Point:TpvVector3;out ClosestPoint:TpvVector3):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=Max(0.0,Sphere.Center.DistanceTo(Point)-Sphere.Radius);
 ClosestPoint:=Point+((Sphere.Center-Point).Normalize*result);
end;

function ClosestPointToCapsule(const Capsule:TpvCapsule;const Point:TpvVector3;out ClosestPoint:TpvVector3;const Time:PpvScalar=nil):TpvScalar; //{$ifdef CAN_INLINE}inline;{$endif}
var LineSegmentPointsDifference,LineClosestPoint:TpvVector3;
    LineSegmentLengthSquared,PointOnLineSegmentTime:TpvScalar;
begin
 LineSegmentPointsDifference:=Capsule.LineEndPoint-Capsule.LineStartPoint;
 LineSegmentLengthSquared:=LineSegmentPointsDifference.SquaredLength;
 if LineSegmentLengthSquared<EPSILON then begin
  PointOnLineSegmentTime:=0.0;
  LineClosestPoint:=Capsule.LineStartPoint;
 end else begin
  PointOnLineSegmentTime:=(Point-Capsule.LineStartPoint).Dot(LineSegmentPointsDifference)/LineSegmentLengthSquared;
  if PointOnLineSegmentTime<=0.0 then begin
   PointOnLineSegmentTime:=0.0;
   LineClosestPoint:=Capsule.LineStartPoint;
  end else if PointOnLineSegmentTime>=1.0 then begin
   PointOnLineSegmentTime:=1.0;
   LineClosestPoint:=Capsule.LineEndPoint;
  end else begin
   LineClosestPoint:=Capsule.LineStartPoint+(LineSegmentPointsDifference*PointOnLineSegmentTime);
  end;
 end;
 LineSegmentPointsDifference:=LineClosestPoint-Point;
 result:=Max(0.0,LineSegmentPointsDifference.Length-Capsule.Radius);
 ClosestPoint:=Point+(LineSegmentPointsDifference.Normalize*result);
 if assigned(Time) then begin
  Time^:=PointOnLineSegmentTime;
 end;
end;

function ClosestPointToTriangle(const a,b,c,p:TpvVector3;out ClosestPoint:TpvVector3):TpvScalar;
var ab,ac,bc,pa,pb,pc,ap,bp,cp,n:TpvVector3;
    snom,sdenom,tnom,tdenom,unom,udenom,vc,vb,va,u,v,w:TpvScalar;
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

 // Determine the parametric position s for the projection of P onto AB (i.e. P� = A+s*AB, where
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

function SquaredDistanceFromPointToAABB(const AABB:TpvAABB;const Point:TpvVector3):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
var ClosestPoint:TpvVector3;
begin
 ClosestPoint.x:=Min(Max(Point.x,AABB.Min.x),AABB.Max.x);
 ClosestPoint.y:=Min(Max(Point.y,AABB.Min.y),AABB.Max.y);
 ClosestPoint.z:=Min(Max(Point.z,AABB.Min.z),AABB.Max.z);
 result:=(ClosestPoint-Point).SquaredLength;
end;

function SquaredDistanceFromPointToTriangle(const p,a,b,c:TpvVector3):TpvScalar;
var ab,ac,bc,pa,pb,pc,ap,bp,cp,n:TpvVector3;
    snom,sdenom,tnom,tdenom,unom,udenom,vc,vb,va,u,v,w:TpvScalar;
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

 // Determine the parametric position s for the projection of P onto AB (i.e. PPU2 = A+s*AB, where
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

function IsParallel(const a,b:TpvVector3;const Tolerance:TpvScalar=1e-5):boolean; {$ifdef CAN_INLINE}inline;{$endif}
var t:TpvVector3;
begin
 t:=a-(b*(a.Length/b.Length));
 result:=(abs(t.x)<Tolerance) and (abs(t.y)<Tolerance) and (abs(t.z)<Tolerance);
end;

function Vector3ToAnglesLDX(v:TpvVector3):TpvVector3;
var Yaw,Pitch:TpvScalar;
begin
 if (v.x=0.0) and (v.y=0.0) then begin
  Yaw:=0.0;
  if v.z>0.0 then begin
   Pitch:=HalfPI;
  end else begin
   Pitch:=PI*1.5;
  end;
 end else begin
  if v.x<>0.0 then begin
   Yaw:=arctan2(v.y,v.x);
  end else if v.y>0.0 then begin
   Yaw:=HalfPI;
  end else begin
   Yaw:=PI;
  end;
  if Yaw<0.0 then begin
   Yaw:=Yaw+TwoPI;
  end;
  Pitch:=ArcTan2(v.z,sqrt(sqr(v.x)+sqr(v.y)));
  if Pitch<0.0 then begin
   Pitch:=Pitch+TwoPI;
  end;
 end;
 result.Pitch:=-Pitch;
 result.Yaw:=Yaw;
 result.Roll:=0.0;
end;

procedure AnglesToVector3LDX(const Angles:TpvVector3;var ForwardVector,RightVector,UpVector:TpvVector3);
var cp,sp,cy,sy,cr,sr:TpvScalar;
begin
 cp:=cos(Angles.Pitch);
 sp:=sin(Angles.Pitch);
 cy:=cos(Angles.Yaw);
 sy:=sin(Angles.Yaw);
 cr:=cos(Angles.Roll);
 sr:=sin(Angles.Roll);
 ForwardVector:=TpvVector3.Create(cp*cy,cp*sy,-sp).Normalize;
 RightVector:=TpvVector3.Create(((-(sr*sp*cy))-(cr*(-sy))),((-(sr*sp*sy))-(cr*cy)),-(sr*cp)).Normalize;
 UpVector:=TpvVector3.Create((cr*sp*cy)+((-sr)*(-sy)),(cr*sp*sy)+((-sr)*cy),cr*cp).Normalize;
end;

function UnsignedAngle(const v0,v1:TpvVector3):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
begin
//result:=ArcCos(v0.Normalize.Dot(v1)));
 result:=ArcTan2(v0.Cross(v1).Length,v0.Dot(v1));
 if IsNaN(result) or IsInfinite(result) or (abs(result)<1e-12) then begin
  result:=0.0;
 end else begin
  result:=ModuloPos(result,TwoPI);
 end;
end;

function AngleDegClamp(a:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
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

function AngleDegDiff(a,b:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=AngleDegClamp(AngleDegClamp(b)-AngleDegClamp(a));
end;

function AngleClamp(a:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
begin
 a:=ModuloPos(ModuloPos(a+PI,TwoPI)+TwoPI,TwoPI)-PI;
 while a<(-OnePI) do begin
  a:=a+TwoPI;
 end;
 while a>OnePI do begin
  a:=a-TwoPI;
 end;
 result:=a;
end;

function AngleDiff(a,b:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=AngleClamp(AngleClamp(b)-AngleClamp(a));
end;

function AngleLerp(a,b,x:TpvScalar):TpvScalar; {$ifdef CAN_INLINE}inline;{$endif}
begin
{if (b-a)>PI then begin
  b:=b-TwoPI;
 end;
 if (b-a)<(-PI) then begin
  b:=b+TwoPI;
 end;
 result:=a+((b-a)*x);}
 result:=a+(AngleDiff(a,b)*x);
end;

function UnitTimeClamp(a:TpvDouble):TpvDouble;
begin
 a:=ModuloPos(a,1.0);
 while a<0.0 do begin
  a:=a+1.0;
 end;
 while a>1.0 do begin
  a:=a-1.0;
 end;
 result:=a;
end;

function UnitTimeDiff(a,b:TpvDouble;const aBackwards:boolean):TpvDouble;
begin
 a:=ModuloPos(a,1.0);
 b:=ModuloPos(b,1.0);
 if aBackwards then begin
  if a<b then begin
   a:=a+1.0;
  end;
 end else begin
  if b<a then begin
   b:=b+1.0;
  end;
 end;
 result:=b-a;
end;

function UnitTimeLerp(a,b,x:TpvDouble;const aBackwards:boolean):TpvDouble;
begin
 a:=frac(frac(a)+1.0);
 b:=frac(frac(b)+1.0);
 if aBackwards then begin
  if a<b then begin
   a:=a+1.0;
  end;
 end else begin
  if b<a then begin
   b:=b+1.0;
  end;
 end;
 if x<=0.0 then begin
  result:=a;
 end else if x>=1.0 then begin
  result:=b;
 end else begin
  result:=(a*(1.0-x))+(b*x);
 end;
 result:=frac(result);
end;

function UnitTimeLerp(a,b,x:TpvDouble):TpvDouble;
begin
 result:=UnitTimeLerp(a,b,x,b<a);
end;

function NonUnitTimeLerp(a,b,x:TpvDouble):TpvDouble;
begin
 if x<=0.0 then begin
  result:=a;
 end else if x>=1.0 then begin
  result:=b;
 end else begin
  result:=(a*(1.0-x))+(b*x);
 end;
end;

function InertiaTensorTransform(const Inertia,Transform:TpvMatrix3x3):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=(Transform*Inertia)*Transform.Transpose;
end;

function InertiaTensorParallelAxisTheorem(const Center:TpvVector3;const Mass:TpvScalar):TpvMatrix3x3; {$ifdef CAN_INLINE}inline;{$endif}
var CenterDotCenter:TpvScalar;
begin
 CenterDotCenter:=sqr(Center.x)+sqr(Center.y)+sqr(Center.z);
 result[0,0]:=((TpvMatrix3x3.Identity[0,0]*CenterDotCenter)-(Center.x*Center.x))*Mass;
 result[0,1]:=((TpvMatrix3x3.Identity[0,1]*CenterDotCenter)-(Center.y*Center.x))*Mass;
 result[0,2]:=((TpvMatrix3x3.Identity[0,2]*CenterDotCenter)-(Center.z*Center.x))*Mass;
 result[1,0]:=((TpvMatrix3x3.Identity[1,0]*CenterDotCenter)-(Center.x*Center.y))*Mass;
 result[1,1]:=((TpvMatrix3x3.Identity[1,1]*CenterDotCenter)-(Center.y*Center.y))*Mass;
 result[1,2]:=((TpvMatrix3x3.Identity[1,2]*CenterDotCenter)-(Center.z*Center.y))*Mass;
 result[2,0]:=((TpvMatrix3x3.Identity[2,0]*CenterDotCenter)-(Center.x*Center.z))*Mass;
 result[2,1]:=((TpvMatrix3x3.Identity[2,1]*CenterDotCenter)-(Center.y*Center.z))*Mass;
 result[2,2]:=((TpvMatrix3x3.Identity[2,2]*CenterDotCenter)-(Center.z*Center.z))*Mass;
end;

procedure OrthoNormalize(var Tangent,Bitangent,Normal:TpvVector3);
begin
 Normal:=Normal.Normalize;
 Tangent:=(Tangent-(Normal*Tangent.Dot(Normal))).Normalize;
 Bitangent:=Normal.Cross(Tangent).Normalize;
 Bitangent:=Bitangent-(Normal*Bitangent.Dot(Normal));
 Bitangent:=(Bitangent-(Tangent*Bitangent.Dot(Tangent))).Normalize;
 Tangent:=Bitangent.Cross(Normal).Normalize;
 Normal:=Tangent.Cross(Bitangent).Normalize;
end;

procedure RobustOrthoNormalize(var Tangent,Bitangent,Normal:TpvVector3;const Tolerance:TpvScalar=1e-3);
var Bisector,Axis:TpvVector3;
begin
 begin
  if Normal.Length<Tolerance then begin
   // Degenerate case, compute new normal
   Normal:=Tangent.Cross(Bitangent);
   if Normal.Length<Tolerance then begin
    Tangent:=TpvVector3.XAxis;
    Bitangent:=TpvVector3.YAxis;
    Normal:=TpvVector3.ZAxis;
    exit;
   end;
  end;
  Normal:=Normal.Normalize;
 end;
 begin
  // Project tangent and bitangent onto the normal orthogonal plane
  Tangent:=Tangent-(Normal*Tangent.Dot(Normal));
  Bitangent:=Bitangent-(Normal*Bitangent.Dot(Normal));
 end;
 begin
  // Check for several degenerate cases
  if Tangent.Length<Tolerance then begin
   if Bitangent.Length<Tolerance then begin
    Tangent:=Normal.Normalize;
    if (Tangent.x<=Tangent.y) and (Tangent.x<=Tangent.z) then begin
     Tangent:=TpvVector3.XAxis;
    end else if (Tangent.y<=Tangent.x) and (Tangent.y<=Tangent.z) then begin
     Tangent:=TpvVector3.YAxis;
    end else begin
     Tangent:=TpvVector3.ZAxis;
    end;
    Tangent:=Tangent-(Normal*Tangent.Dot(Normal));
    Bitangent:=Normal.Cross(Tangent).Normalize;
   end else begin
    Tangent:=Bitangent.Cross(Normal).Normalize;
   end;
  end else begin
   Tangent:=Tangent.Normalize;
   if Bitangent.Length<Tolerance then begin
    Bitangent:=Normal.Cross(Tangent).Normalize;
   end else begin
    Bitangent:=Bitangent.Normalize;
    Bisector:=Tangent+Bitangent;
    if Bisector.Length<Tolerance then begin
     Bisector:=Tangent;
    end else begin
     Bisector:=Bisector.Normalize;
    end;
    Axis:=Bisector.Cross(Normal).Normalize;
    if Axis.Dot(Tangent)>0.0 then begin
     Tangent:=(Bisector+Axis).Normalize;
     Bitangent:=(Bisector-Axis).Normalize;
    end else begin
     Tangent:=(Bisector-Axis).Normalize;
     Bitangent:=(Bisector+Axis).Normalize;
    end;
   end;
  end;
 end;
 Bitangent:=Normal.Cross(Tangent).Normalize;
 Tangent:=Bitangent.Cross(Normal).Normalize;
 Normal:=Tangent.Cross(Bitangent).Normalize;
end;

function MaxOverlaps(const Min1,Max1,Min2,Max2:TpvScalar;var LowerLim,UpperLim:TpvScalar):boolean;
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

function GetHaltonSequence(const aIndex,aPrimeBase:TpvUInt32):TpvDouble;
var f,OneOverPrimeBase:TpvDouble;
    Current,CurrentDiv:TpvInt32;
begin
 result:=0.0;
 OneOverPrimeBase:=1.0/aPrimeBase;
 f:=OneOverPrimeBase;
 Current:=aIndex;
 while Current>0 do begin
  CurrentDiv:=Current div aPrimeBase;
  result:=result+(f*(Current-(CurrentDiv*aPrimeBase)));
  Current:=CurrentDiv;
  f:=f*OneOverPrimeBase;
 end;
end;

function ConvertRGB32FToRGB9E5(r,g,b:TpvFloat):TpvUInt32;
const RGB9E5_EXPONENT_BITS=5;
      RGB9E5_MANTISSA_BITS=9;
      RGB9E5_EXP_BIAS=15;
      RGB9E5_MAX_VALID_BIASED_EXP=31;
      MAX_RGB9E5_EXP=RGB9E5_MAX_VALID_BIASED_EXP-RGB9E5_EXP_BIAS;
      RGB9E5_MANTISSA_VALUES=1 shl RGB9E5_MANTISSA_BITS;
      MAX_RGB9E5_MANTISSA=RGB9E5_MANTISSA_VALUES-1;
      MAX_RGB9E5=((MAX_RGB9E5_MANTISSA+0.0)/RGB9E5_MANTISSA_VALUES)*(1 shl MAX_RGB9E5_EXP);
      EPSILON_RGB9E5=(1.0/RGB9E5_MANTISSA_VALUES)/(1 shl RGB9E5_EXP_BIAS);
var Exponent,MaxMantissa,ri,gi,bi:TpvInt32;
    MaxComponent,Denominator:TpvFloat;
    CastedMaxComponent:TpvUInt32 absolute MaxComponent;
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
 Exponent:=(TpvInt32(CastedMaxComponent and $7f800000) shr 23)-127;
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
 result:=TpvUInt32(ri) or (TpvUInt32(gi) shl 9) or (TpvUInt32(bi) shl 18) or (TpvUInt32(Exponent and 31) shl 27);
end;

function PackFP32FloatToM6E5Float(const pValue:TpvFloat):TpvUInt32;
const Float32MantissaBits=23;
      Float32ExponentBits=8;
      Float32Bits=32;
      Float32ExponentBias=127;
      Float6E5MantissaBits=6;
      Float6E5MantissaMask=(1 shl Float6E5MantissaBits)-1;
      Float6E5ExponentBits=5;
      Float6E5Bits=11;
      Float6E5ExponentBias=15;
var CastedValue:TpvUInt32 absolute pValue;
    Exponent,Mantissa:TpvUInt32;
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

function PackFP32FloatToM5E5Float(const pValue:TpvFloat):TpvUInt32;
const Float32MantissaBits=23;
      Float32ExponentBits=8;
      Float32Bits=32;
      Float32ExponentBias=127;
      Float5E5MantissaBits=5;
      Float5E5MantissaMask=(1 shl Float5E5MantissaBits)-1;
      Float5E5ExponentBits=5;
      Float5E5Bits=10;
      Float5E5ExponentBias=15;
var CastedValue:TpvUInt32 absolute pValue;
    Exponent,Mantissa:TpvUInt32;
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

function Float32ToFloat11(const pValue:TpvFloat):TpvUInt32;
const EXPONENT_BIAS=15;
      EXPONENT_BITS=$1f;
      EXPONENT_SHIFT=6;
      MANTISSA_BITS=$3f;
      MANTISSA_SHIFT=23-EXPONENT_SHIFT;
      MAX_EXPONENT=EXPONENT_BITS shl EXPONENT_SHIFT;
var CastedValue:TpvUInt32 absolute pValue;
    Sign:TpvUInt32;
    Exponent,Mantissa:TpvInt32;
begin
 Sign:=CastedValue shr 31;
 Exponent:=TpvInt32(TpvUInt32((CastedValue and $7f800000) shr 23))-127;
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
 end else if pValue>65024.0 then begin
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

function Float32ToFloat10(const pValue:TpvFloat):TpvUInt32;
const EXPONENT_BIAS=15;
      EXPONENT_BITS=$1f;
      EXPONENT_SHIFT=5;
      MANTISSA_BITS=$1f;
      MANTISSA_SHIFT=23-EXPONENT_SHIFT;
      MAX_EXPONENT=EXPONENT_BITS shl EXPONENT_SHIFT;
var CastedValue:TpvUInt32 absolute pValue;
    Sign:TpvUInt32;
    Exponent,Mantissa:TpvInt32;
begin
 Sign:=CastedValue shr 31;
 Exponent:=TpvInt32(TpvUInt32((CastedValue and $7f800000) shr 23))-127;
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
 end else if pValue>64512.0 then begin
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

function ConvertRGB32FToR11FG11FB10F(const r,g,b:TpvFloat):TpvUInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
//result:=(PackFP32FloatToM6E5Float(r) and $7ff) or ((PackFP32FloatToM6E5Float(g) and $7ff) shl 11) or ((PackFP32FloatToM5E5Float(b) and $3ff) shl 22);
 result:=(Float32ToFloat11(r) and $7ff) or ((Float32ToFloat11(g) and $7ff) shl 11) or ((Float32ToFloat10(b) and $3ff) shl 22);
end;

function EncodeAsRGB10A2UNorm(const aVector:TpvVector4):TpvUInt32;
var r,g,b,a:TpvUInt32;
begin
 r:=round(Min(Max(aVector.r,0.0),1.0)*1023.0);
 g:=round(Min(Max(aVector.g,0.0),1.0)*1023.0);
 b:=round(Min(Max(aVector.b,0.0),1.0)*1023.0);
 a:=round(Min(Max(aVector.a,0.0),1.0)*3.0);
 result:=(r and $3ff) or ((g and $3ff) shl 10) or ((b and $3ff) shl 20) or ((a and 3) shl 30);
end;

function DecodeFromRGB10A2UNorm(const aValue:TpvUInt32):TpvVector4;
var r,g,b,a:TpvUInt32;
begin
 r:=(aValue shr 0) and $3ff;
 g:=(aValue shr 10) and $3ff;
 b:=(aValue shr 20) and $3ff;
 a:=(aValue shr 30) and 3;
 result.r:=r/1023.0;
 result.g:=g/1023.0;
 result.b:=b/1023.0;
 result.a:=a/3.0;
end;

function EncodeAsRGB10A2SNorm(const aVector:TpvVector4):TpvUInt32;
var r,g,b,a:TpvUInt32;
begin
 r:=TpvUInt32(TpvInt32(round(Min(Max(aVector.r,-1.0),1.0)*511.0)));
 g:=TpvUInt32(TpvInt32(round(Min(Max(aVector.g,-1.0),1.0)*511.0)));
 b:=TpvUInt32(TpvInt32(round(Min(Max(aVector.b,-1.0),1.0)*511.0)));
 a:=TpvUInt32(TpvInt32(round(Min(Max(aVector.a,-1.0),1.0)*1.0)));
 result:=(r and $3ff) or ((g and $3ff) shl 10) or ((b and $3ff) shl 20) or ((a and 3) shl 30);
end;

function DecodeFromRGB10A2SNorm(const aValue:TpvUInt32):TpvVector4;
var r,g,b,a:TpvUInt32;
begin
{$if declared(SARLongint)}
{$if true}
 
 // More efficient version

 // Extract the red, green, blue and alpha components, together with sign extension
 r:=TpvUInt32(TpvInt32(SARLongint(TpvInt32(TpvUInt32(aValue shl 22)),22)));
 g:=TpvUInt32(TpvInt32(SARLongint(TpvInt32(TpvUInt32(aValue shl 12)),22)));
 b:=TpvUInt32(TpvInt32(SARLongint(TpvInt32(TpvUInt32(aValue shl 2)),22)));
 a:=TpvUInt32(TpvInt32(SARLongint(TpvInt32(TpvUInt32(aValue shl 0)),30)));

{$else}

 // More readable version (slower), which is equivalent to the above version, but which shows more what is happening    

 // Extract the red, green, blue and alpha components, together with sign extension
 r:=TpvUInt32(TpvInt32(SARLongint(TpvInt32(TpvUInt32((aValue shr 0) and $3ff)) shl 22,22)));
 g:=TpvUInt32(TpvInt32(SARLongint(TpvInt32(TpvUInt32((aValue shr 10) and $3ff)) shl 22,22)));
 b:=TpvUInt32(TpvInt32(SARLongint(TpvInt32(TpvUInt32((aValue shr 20) and $3ff)) shl 22,22)));
 a:=TpvUInt32(TpvInt32(SARLongint(TpvInt32(TpvUInt32((aValue shr 30) and 3)) shl 30,30)));

{$ifend} 
{$else}
 
 // Fallback version when SARLongint is not available for artithmetic right shiftings, and it is the even more readable 
 // reference version at the same time.

 // Extract the red, green, blue and alpha components
 r:=(aValue shr 0) and $3ff;
 g:=(aValue shr 10) and $3ff;
 b:=(aValue shr 20) and $3ff;
 a:=(aValue shr 30) and 3;

 // Sign extend the red, green and blue components
 if (r and $200)<>0 then begin
  r:=r or $fffffc00;
 end;
 if (g and $200)<>0 then begin
  g:=g or $fffffc00;
 end;
 if (b and $200)<>0 then begin
  b:=b or $fffffc00;
 end;
 if (a and 2)<>0 then begin
  a:=a or $fffffffc;
 end;

{$ifend} 

 // Normalize the red, green, blue and alpha components
 result.r:=TpvInt32(r)/511.0;
 result.g:=TpvInt32(g)/511.0;
 result.b:=TpvInt32(b)/511.0;
 result.a:=TpvInt32(a){/1.0}; // No need to normalize the alpha component, because it is already normalized

end;

function PackInt8TangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvInt8PackedTangentSpace;
begin
 result.x:=Min(Max(round((ArcSin(aNormal.z)/PI)*127.0),-128),127);
 result.y:=Min(Max(round((ArcTan2(aNormal.y,aNormal.x)/PI)*127.0),-128),127);
 result.z:=Min(Max(round((ArcSin(aTangent.z)/PI)*127.0),-128),127);
 result.w:=Min(Max(round((ArcTan2(aTangent.y,aTangent.x)/PI)*127.0),-128),127);
end;

procedure UnpackInt8TangentSpace(const aPackedTangentSpace:TpvInt8PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);
var Latitude,Longitude:TpvScalar;
begin
 Latitude:=(aPackedTangentSpace.x/127.0)*PI;
 Longitude:=(aPackedTangentSpace.y/127.0)*PI;
 aNormal.x:=cos(Latitude)*cos(Longitude);
 aNormal.y:=cos(Latitude)*sin(Longitude);
 aNormal.z:=sin(Latitude);
 Latitude:=(aPackedTangentSpace.z/127.0)*PI;
 Longitude:=(aPackedTangentSpace.w/127.0)*PI;
 aTangent.x:=cos(Latitude)*cos(Longitude);
 aTangent.y:=cos(Latitude)*sin(Longitude);
 aTangent.z:=sin(Latitude);
 aBitangent:=(aNormal.Cross(aTangent)).Normalize;
end;

function PackInt16TangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvInt16PackedTangentSpace;
begin
 result.x:=Min(Max(round((ArcSin(aNormal.z)/PI)*32767.0),-32768),32767);
 result.y:=Min(Max(round((ArcTan2(aNormal.y,aNormal.x)/PI)*32767.0),-32768),32767);
 result.z:=Min(Max(round((ArcSin(aTangent.z)/PI)*32767.0),-32768),32767);
 result.w:=Min(Max(round((ArcTan2(aTangent.y,aTangent.x)/PI)*32767.0),-32768),32767);
end;

procedure UnpackInt16TangentSpace(const aPackedTangentSpace:TpvInt16PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);
var Latitude,Longitude:TpvScalar;
begin
 Latitude:=(aPackedTangentSpace.x/32767.0)*PI;
 Longitude:=(aPackedTangentSpace.y/32767.0)*PI;
 aNormal.x:=cos(Latitude)*cos(Longitude);
 aNormal.y:=cos(Latitude)*sin(Longitude);
 aNormal.z:=sin(Latitude);
 Latitude:=(aPackedTangentSpace.z/32767.0)*PI;
 Longitude:=(aPackedTangentSpace.w/32767.0)*PI;
 aTangent.x:=cos(Latitude)*cos(Longitude);
 aTangent.y:=cos(Latitude)*sin(Longitude);
 aTangent.z:=sin(Latitude);
 aBitangent:=(aNormal.Cross(aTangent)).Normalize;
end;

function PackInt8QTangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvInt8PackedTangentSpace;
var q:TpvQuaternion;
begin
 q:=TpvMatrix3x3.Create(aTangent,aBitangent,aNormal).ToQTangent(QTangentThreshold8Bit);
 result.x:=Min(Max(round(q.x*127.0),-128),127);
 result.y:=Min(Max(round(q.y*127.0),-128),127);
 result.z:=Min(Max(round(q.z*127.0),-128),127);
 result.w:=Min(Max(round(q.w*127.0),-128),127);
end;

procedure UnpackInt8QTangentSpace(const aPackedTangentSpace:TpvInt8PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);
var q:TpvQuaternion;
    m:TpvMatrix3x3;
begin
 q.x:=aPackedTangentSpace.x/127.0;
 q.y:=aPackedTangentSpace.y/127.0;
 q.z:=aPackedTangentSpace.z/127.0;
 q.w:=aPackedTangentSpace.w/127.0;
 m:=TpvMatrix3x3.CreateFromQTangent(q);
 aTangent.x:=m[0,0];
 aTangent.y:=m[0,1];
 aTangent.z:=m[0,2];
 aBitangent.x:=m[1,0];
 aBitangent.y:=m[1,1];
 aBitangent.z:=m[1,2];
 aNormal.x:=m[2,0];
 aNormal.y:=m[2,1];
 aNormal.z:=m[2,2];
end;

function PackInt16QTangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvInt16PackedTangentSpace;
var q:TpvQuaternion;
begin
 q:=TpvMatrix3x3.Create(aTangent,aBitangent,aNormal).ToQTangent(QTangentThreshold16Bit);
 result.x:=Min(Max(round(q.x*32767.0),-32768),32767);
 result.y:=Min(Max(round(q.y*32767.0),-32768),32767);
 result.z:=Min(Max(round(q.z*32767.0),-32768),32767);
 result.w:=Min(Max(round(q.w*32767.0),-32768),32767);
end;

procedure UnpackInt16QTangentSpace(const aPackedTangentSpace:TpvInt16PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);
var q:TpvQuaternion;
    m:TpvMatrix3x3;
begin
 q.x:=aPackedTangentSpace.x/32767.0;
 q.y:=aPackedTangentSpace.y/32767.0;
 q.z:=aPackedTangentSpace.z/32767.0;
 q.w:=aPackedTangentSpace.w/32767.0;
 m:=TpvMatrix3x3.CreateFromQTangent(q);
 aTangent.x:=m[0,0];
 aTangent.y:=m[0,1];
 aTangent.z:=m[0,2];
 aBitangent.x:=m[1,0];
 aBitangent.y:=m[1,1];
 aBitangent.z:=m[1,2];
 aNormal.x:=m[2,0];
 aNormal.y:=m[2,1];
 aNormal.z:=m[2,2];
end;

function PackUInt8TangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvUInt8PackedTangentSpace;
begin
 result.x:=Min(Max((round((ArcSin(aNormal.z)/PI)*127.0)+128),0),255);
 result.y:=Min(Max((round((ArcTan2(aNormal.y,aNormal.x)/PI)*127.0)+128),0),255);
 result.z:=Min(Max((round((ArcSin(aTangent.z)/PI)*127.0)+128),0),255);
 result.w:=Min(Max((round((ArcTan2(aTangent.y,aTangent.x)/PI)*127.0)+128),0),255);
end;

procedure UnpackUInt8TangentSpace(const aPackedTangentSpace:TpvUInt8PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);
var Latitude,Longitude:TpvScalar;
begin
 Latitude:=((aPackedTangentSpace.x-128.0)/127.0)*PI;
 Longitude:=((aPackedTangentSpace.y-128.0)/127.0)*PI;
 aNormal.x:=cos(Latitude)*cos(Longitude);
 aNormal.y:=cos(Latitude)*sin(Longitude);
 aNormal.z:=sin(Latitude);
 Latitude:=((aPackedTangentSpace.z-128.0)/127.0)*PI;
 Longitude:=((aPackedTangentSpace.w-128.0)/127.0)*PI;
 aTangent.x:=cos(Latitude)*cos(Longitude);
 aTangent.y:=cos(Latitude)*sin(Longitude);
 aTangent.z:=sin(Latitude);
 aBitangent:=(aNormal.Cross(aTangent)).Normalize;
end;

function PackUInt16TangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvUInt16PackedTangentSpace;
begin
 result.x:=Min(Max((round((ArcSin(aNormal.z)/PI)*32767.0)+32768),0),65535);
 result.y:=Min(Max((round((ArcTan2(aNormal.y,aNormal.x)/PI)*32767.0)+32768),0),65535);
 result.z:=Min(Max((round((ArcSin(aTangent.z)/PI)*32767.0)+32768),0),255);
 result.w:=Min(Max((round((ArcTan2(aTangent.y,aTangent.x)/PI)*32767.0)+32768),0),65535);
end;

procedure UnpackUInt16TangentSpace(const aPackedTangentSpace:TpvUInt16PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);
var Latitude,Longitude:TpvScalar;
begin
 Latitude:=((aPackedTangentSpace.x-32768.0)/32767.0)*PI;
 Longitude:=((aPackedTangentSpace.y-32768.0)/32767.0)*PI;
 aNormal.x:=cos(Latitude)*cos(Longitude);
 aNormal.y:=cos(Latitude)*sin(Longitude);
 aNormal.z:=sin(Latitude);
 Latitude:=((aPackedTangentSpace.z-32768.0)/32767.0)*PI;
 Longitude:=((aPackedTangentSpace.w-32768.0)/32767.0)*PI;
 aTangent.x:=cos(Latitude)*cos(Longitude);
 aTangent.y:=cos(Latitude)*sin(Longitude);
 aTangent.z:=sin(Latitude);
 aBitangent:=(aNormal.Cross(aTangent)).Normalize;
end;

function PackUInt8QTangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvUInt8PackedTangentSpace;
var q:TpvQuaternion;
begin
 q:=TpvMatrix3x3.Create(aTangent,aBitangent,aNormal).ToQTangent(QTangentThreshold8Bit);
 result.x:=Min(Max((round(q.x*127.0)+128),0),255);
 result.y:=Min(Max((round(q.y*127.0)+128),0),255);
 result.z:=Min(Max((round(q.z*127.0)+128),0),255);
 result.w:=Min(Max((round(q.w*127.0)+128),0),255);
end;

procedure UnpackUInt8QTangentSpace(const aPackedTangentSpace:TpvUInt8PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);
var q:TpvQuaternion;
    m:TpvMatrix3x3;
begin
 q.x:=(aPackedTangentSpace.x-128.0)/127.0;
 q.y:=(aPackedTangentSpace.y-128.0)/127.0;
 q.z:=(aPackedTangentSpace.z-128.0)/127.0;
 q.w:=(aPackedTangentSpace.w-128.0)/127.0;
 m:=TpvMatrix3x3.CreateFromQTangent(q);
 aTangent.x:=m[0,0];
 aTangent.y:=m[0,1];
 aTangent.z:=m[0,2];
 aBitangent.x:=m[1,0];
 aBitangent.y:=m[1,1];
 aBitangent.z:=m[1,2];
 aNormal.x:=m[2,0];
 aNormal.y:=m[2,1];
 aNormal.z:=m[2,2];
end;

function PackUInt16QTangentSpace(const aTangent,aBitangent,aNormal:TpvVector3):TpvUInt16PackedTangentSpace;
var q:TpvQuaternion;
begin
 q:=TpvMatrix3x3.Create(aTangent,aBitangent,aNormal).ToQTangent(QTangentThreshold16Bit);
 result.x:=Min(Max((round(q.x*32767.0)+32768),0),65535);
 result.y:=Min(Max((round(q.y*32767.0)+32768),0),65535);
 result.z:=Min(Max((round(q.z*32767.0)+32768),0),65535);
 result.w:=Min(Max((round(q.w*32767.0)+32768),0),65535);
end;

procedure UnpackUInt16QTangentSpace(const aPackedTangentSpace:TpvUInt16PackedTangentSpace;out aTangent,aBitangent,aNormal:TpvVector3);
var q:TpvQuaternion;
    m:TpvMatrix3x3;
begin
 q.x:=(aPackedTangentSpace.x-32768.0)/32767.0;
 q.y:=(aPackedTangentSpace.y-32768.0)/32767.0;
 q.z:=(aPackedTangentSpace.z-32768.0)/32767.0;
 q.w:=(aPackedTangentSpace.w-32768.0)/32767.0;
 m:=TpvMatrix3x3.CreateFromQTangent(q);
 aTangent.x:=m[0,0];
 aTangent.y:=m[0,1];
 aTangent.z:=m[0,2];
 aBitangent.x:=m[1,0];
 aBitangent.y:=m[1,1];
 aBitangent.z:=m[1,2];
 aNormal.x:=m[2,0];
 aNormal.y:=m[2,1];
 aNormal.z:=m[2,2];
end;

function ConvertLinearToSRGB(const aColor:TpvFloat):TpvFloat;
const InverseGamma=1.0/2.4;
begin
 if aColor<0.0031308 then begin
  result:=aColor*12.92;
 end else if aColor<1.0 then begin
  result:=(Power(aColor,InverseGamma)*1.055)-0.055;
 end else begin
  result:=1.0;
 end;
end;

function ConvertLinearToSRGB(const aColor:TpvVector3):TpvVector3;
const InverseGamma=1.0/2.4;
var ChannelIndex:TpvInt32;
begin
 for ChannelIndex:=0 to 2 do begin
  if aColor[ChannelIndex]<0.0031308 then begin
   result[ChannelIndex]:=aColor[ChannelIndex]*12.92;
  end else if aColor[ChannelIndex]<1.0 then begin
   result[ChannelIndex]:=(Power(aColor[ChannelIndex],InverseGamma)*1.055)-0.055;
  end else begin
   result[ChannelIndex]:=1.0;
  end;
 end;
end;

function ConvertLinearToSRGB(const aColor:TpvVector4):TpvVector4;
const InverseGamma=1.0/2.4;
var ChannelIndex:TpvInt32;
begin
 for ChannelIndex:=0 to 2 do begin
  if aColor[ChannelIndex]<0.0031308 then begin
   result[ChannelIndex]:=aColor[ChannelIndex]*12.92;
  end else if aColor[ChannelIndex]<1.0 then begin
   result[ChannelIndex]:=(Power(aColor[ChannelIndex],InverseGamma)*1.055)-0.055;
  end else begin
   result[ChannelIndex]:=1.0;
  end;
 end;
 result.a:=aColor.a;
end;

function ConvertSRGBToLinear(const aColor:TpvFloat):TpvFloat;
const Inverse12d92=1.0/12.92;
begin
 if aColor<0.04045 then begin
  result:=aColor*Inverse12d92;
 end else if aColor<1.0 then begin
  result:=Power((aColor+0.055)/1.055,2.4);
 end else begin
  result:=1.0;
 end;
end;

function ConvertSRGBToLinear(const aColor:TpvVector3):TpvVector3;
const Inverse12d92=1.0/12.92;
var ChannelIndex:TpvInt32;
begin
 for ChannelIndex:=0 to 2 do begin
  if aColor[ChannelIndex]<0.04045 then begin
   result[ChannelIndex]:=aColor[ChannelIndex]*Inverse12d92;
  end else if aColor[ChannelIndex]<1.0 then begin
   result[ChannelIndex]:=Power((aColor[ChannelIndex]+0.055)/1.055,2.4);
  end else begin
   result[ChannelIndex]:=1.0;
  end;
 end;
end;

function ConvertSRGBToLinear(const aColor:TpvVector4):TpvVector4;
const Inverse12d92=1.0/12.92;
var ChannelIndex:TpvInt32;
begin
 for ChannelIndex:=0 to 2 do begin
  if aColor[ChannelIndex]<0.04045 then begin
   result[ChannelIndex]:=aColor[ChannelIndex]*Inverse12d92;
  end else if aColor[ChannelIndex]<1.0 then begin
   result[ChannelIndex]:=Power((aColor[ChannelIndex]+0.055)/1.055,2.4);
  end else begin
   result[ChannelIndex]:=1.0;
  end;
 end;
 result.a:=aColor.a;
end;

function ConvertHSVToRGB(const aHSV:TpvVector3):TpvVector3;
var Angle,Sector,FracSector,h,s,v,p,q,t:TpvScalar;
    IntSector:TpvInt32;
begin
 s:=aHSV.y;
 if SameValue(s,0.0) then begin
  result:=aHSV.zzz;
 end else begin
  h:=aHSV.x;
  Angle:=frac(h)*360.0;
  Sector:=Angle/60.0;
  IntSector:=trunc(Sector);
  FracSector:=frac(Sector);
  v:=aHSV.z;
  p:=v*(1.0-s);
  q:=v*(1.0-(s*FracSector));
  t:=v*(1.0-(s*(1.0-FracSector)));
  case IntSector of
   0:begin
    result:=TpvVector3.InlineableCreate(v,t,p);
   end;
   1:begin
    result:=TpvVector3.InlineableCreate(q,v,p);
   end;
   2:begin
    result:=TpvVector3.InlineableCreate(p,v,t);
   end;
   3:begin
    result:=TpvVector3.InlineableCreate(p,q,v);
   end;
   4:begin
    result:=TpvVector3.InlineableCreate(t,p,v);
   end;
   else begin
    result:=TpvVector3.InlineableCreate(v,p,q);
   end;
  end;
 end;
end;

function ConvertRGBToHSV(const aRGB:TpvVector3):TpvVector3;
var MinValue,MaxValue,Delta,h,s,v:TpvScalar;
begin
 MinValue:=Min(aRGB.x,Min(aRGB.y,aRGB.z));
 MaxValue:=Max(aRGB.x,Max(aRGB.y,aRGB.z));
 v:=MaxValue;
 Delta:=MaxValue-MinValue;
 if Delta<1e-5 then begin
  result:=TpvVector3.InlineableCreate(0.0,0.0,v);
 end else if MaxValue>0.0 then begin
  s:=Delta/MaxValue;
  if SameValue(aRGB.x,MaxValue) then begin
   h:=(aRGB.y-aRGB.z)/Delta;
  end else if SameValue(aRGB.y,MaxValue) then begin
   h:=2.0+((aRGB.z-aRGB.x)/Delta);
  end else begin
   h:=4.0+((aRGB.x-aRGB.y)/Delta);
  end;
  h:=(h*60.0);
  if h<0.0 then begin
   h:=h+360.0;
  end else if h>360.0 then begin
   h:=h-360.0;
  end;
  h:=h/360.0;
  result:=TpvVector3.InlineableCreate(h,s,v);
 end else begin
  result:=TpvVector3.InlineableCreate(-1.0,0.0,v);
 end;
end;

constructor TpvVector2Property.Create(const aVector:PpvVector2);
begin
 inherited Create;
 fVector:=aVector;
 fOnChange:=nil;
end;

destructor TpvVector2Property.Destroy;
begin
 inherited Destroy;
end;

function TpvVector2Property.GetX:TpvScalar;
begin
 result:=fVector^.x;
end;

function TpvVector2Property.GetY:TpvScalar;
begin
 result:=fVector^.y;
end;

function TpvVector2Property.GetVector:TpvVector2;
begin
 result:=fVector^;
end;

procedure TpvVector2Property.SetX(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.x<>aNewValue) then begin
  fVector^.x:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.x:=aNewValue;
 end;
end;

procedure TpvVector2Property.SetY(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.y<>aNewValue) then begin
  fVector^.y:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.y:=aNewValue;
 end;
end;

procedure TpvVector2Property.SetVector(const aNewVector:TpvVector2);
begin
 if assigned(fOnChange) and ((fVector^.x<>aNewVector.x) or (fVector^.y<>aNewVector.y)) then begin
  fVector^:=aNewVector;
  fOnChange(self);
 end else begin
  fVector^:=aNewVector;
 end;
end;

constructor TpvVector3Property.Create(const aVector:PpvVector3);
begin
 inherited Create;
 fVector:=aVector;
 fOnChange:=nil;
end;

destructor TpvVector3Property.Destroy;
begin
 inherited Destroy;
end;

function TpvVector3Property.GetX:TpvScalar;
begin
 result:=fVector^.x;
end;

function TpvVector3Property.GetY:TpvScalar;
begin
 result:=fVector^.y;
end;

function TpvVector3Property.GetZ:TpvScalar;
begin
 result:=fVector^.z;
end;

function TpvVector3Property.GetVector:TpvVector3;
begin
 result:=fVector^;
end;

procedure TpvVector3Property.SetX(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.x<>aNewValue) then begin
  fVector^.x:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.x:=aNewValue;
 end;
end;

procedure TpvVector3Property.SetY(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.y<>aNewValue) then begin
  fVector^.y:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.y:=aNewValue;
 end;
end;

procedure TpvVector3Property.SetZ(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.z<>aNewValue) then begin
  fVector^.z:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.z:=aNewValue;
 end;
end;

procedure TpvVector3Property.SetVector(const aNewVector:TpvVector3);
begin
 if assigned(fOnChange) and ((fVector^.x<>aNewVector.x) or (fVector^.y<>aNewVector.y) or (fVector^.z<>aNewVector.z)) then begin
  fVector^:=aNewVector;
  fOnChange(self);
 end else begin
  fVector^:=aNewVector;
 end;
end;

constructor TpvVector4Property.Create(const aVector:PpvVector4);
begin
 inherited Create;
 fVector:=aVector;
 fOnChange:=nil;
end;

destructor TpvVector4Property.Destroy;
begin
 inherited Destroy;
end;

function TpvVector4Property.GetX:TpvScalar;
begin
 result:=fVector^.x;
end;

function TpvVector4Property.GetY:TpvScalar;
begin
 result:=fVector^.y;
end;

function TpvVector4Property.GetZ:TpvScalar;
begin
 result:=fVector^.z;
end;

function TpvVector4Property.GetW:TpvScalar;
begin
 result:=fVector^.w;
end;

function TpvVector4Property.GetVector:TpvVector4;
begin
 result:=fVector^;
end;

procedure TpvVector4Property.SetX(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.x<>aNewValue) then begin
  fVector^.x:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.x:=aNewValue;
 end;
end;

procedure TpvVector4Property.SetY(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.y<>aNewValue) then begin
  fVector^.y:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.y:=aNewValue;
 end;
end;

procedure TpvVector4Property.SetZ(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.z<>aNewValue) then begin
  fVector^.z:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.z:=aNewValue;
 end;
end;

procedure TpvVector4Property.SetW(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.w<>aNewValue) then begin
  fVector^.w:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.w:=aNewValue;
 end;
end;

procedure TpvVector4Property.SetVector(const aNewVector:TpvVector4);
begin
 if assigned(fOnChange) and ((fVector^.x<>aNewVector.x) or (fVector^.y<>aNewVector.y) or (fVector^.z<>aNewVector.z) or (fVector^.w<>aNewVector.w)) then begin
  fVector^:=aNewVector;
  fOnChange(self);
 end else begin
  fVector^:=aNewVector;
 end;
end;

constructor TpvQuaternionProperty.Create(const AQuaternion:PpvQuaternion);
begin
 inherited Create;
 fQuaternion:=AQuaternion;
 fOnChange:=nil;
end;

destructor TpvQuaternionProperty.Destroy;
begin
 inherited Destroy;
end;

function TpvQuaternionProperty.GetX:TpvScalar;
begin
 result:=fQuaternion^.x;
end;

function TpvQuaternionProperty.GetY:TpvScalar;
begin
 result:=fQuaternion^.y;
end;

function TpvQuaternionProperty.GetZ:TpvScalar;
begin
 result:=fQuaternion^.z;
end;

function TpvQuaternionProperty.GetW:TpvScalar;
begin
 result:=fQuaternion^.w;
end;

function TpvQuaternionProperty.GetQuaternion:TpvQuaternion;
begin
 result:=fQuaternion^;
end;

procedure TpvQuaternionProperty.SetX(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fQuaternion^.x<>aNewValue) then begin
  fQuaternion^.x:=aNewValue;
  fOnChange(self);
 end else begin
  fQuaternion^.x:=aNewValue;
 end;
end;

procedure TpvQuaternionProperty.SetY(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fQuaternion^.y<>aNewValue) then begin
  fQuaternion^.y:=aNewValue;
  fOnChange(self);
 end else begin
  fQuaternion^.y:=aNewValue;
 end;
end;

procedure TpvQuaternionProperty.SetZ(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fQuaternion^.z<>aNewValue) then begin
  fQuaternion^.z:=aNewValue;
  fOnChange(self);
 end else begin
  fQuaternion^.z:=aNewValue;
 end;
end;

procedure TpvQuaternionProperty.SetW(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fQuaternion^.w<>aNewValue) then begin
  fQuaternion^.w:=aNewValue;
  fOnChange(self);
 end else begin
  fQuaternion^.w:=aNewValue;
 end;
end;

procedure TpvQuaternionProperty.SetQuaternion(const aNewQuaternion:TpvQuaternion);
begin
 if assigned(fOnChange) and ((fQuaternion^.x<>aNewQuaternion.x) or (fQuaternion^.y<>aNewQuaternion.y) or (fQuaternion^.z<>aNewQuaternion.z) or (fQuaternion^.w<>aNewQuaternion.w)) then begin
  fQuaternion^:=aNewQuaternion;
  fOnChange(self);
 end else begin
  fQuaternion^:=aNewQuaternion;
 end;
end;

constructor TpvAngleProperty.Create(const aRadianAngle:PpvScalar);
begin
 inherited Create;
 fRadianAngle:=aRadianAngle;
 fOnChange:=nil;
end;

destructor TpvAngleProperty.Destroy;
begin
 inherited Destroy;
end;

function TpvAngleProperty.GetAngle:TpvScalar;
begin
 result:=fRadianAngle^*RAD2DEG;
end;

function TpvAngleProperty.GetRadianAngle:TpvScalar;
begin
 result:=fRadianAngle^;
end;

procedure TpvAngleProperty.SetAngle(const aNewValue:TpvScalar);
begin
 SetRadianAngle(aNewValue*DEG2RAD);
end;

procedure TpvAngleProperty.SetRadianAngle(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fRadianAngle^<>aNewValue) then begin
  fRadianAngle^:=aNewValue;
  fOnChange(self);
 end else begin
  fRadianAngle^:=aNewValue;
 end;
end;

constructor TpvRotation3DProperty.Create(const AQuaternion:PpvQuaternion);
begin
 inherited Create;
 fQuaternion:=AQuaternion;
 fOnChange:=nil;
end;

destructor TpvRotation3DProperty.Destroy;
begin
 inherited Destroy;
end;

function TpvRotation3DProperty.GetX:TpvScalar;
begin
 result:=fQuaternion^.x;
end;

function TpvRotation3DProperty.GetY:TpvScalar;
begin
 result:=fQuaternion^.y;
end;

function TpvRotation3DProperty.GetZ:TpvScalar;
begin
 result:=fQuaternion^.z;
end;

function TpvRotation3DProperty.GetW:TpvScalar;
begin
 result:=fQuaternion^.w;
end;

function TpvRotation3DProperty.GetPitch:TpvScalar;
begin
 result:=fQuaternion^.Normalize.ToEuler.Pitch*RAD2DEG;
end;

function TpvRotation3DProperty.GetYaw:TpvScalar;
begin
 result:=fQuaternion^.Normalize.ToEuler.Yaw*RAD2DEG;
end;

function TpvRotation3DProperty.GetRoll:TpvScalar;
begin
 result:=fQuaternion^.Normalize.ToEuler.Roll*RAD2DEG;
end;

function TpvRotation3DProperty.GetQuaternion:TpvQuaternion;
begin
 result:=fQuaternion^;
end;

procedure TpvRotation3DProperty.SetX(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fQuaternion^.x<>aNewValue) then begin
  fQuaternion^.x:=aNewValue;
  fOnChange(self);
 end else begin
  fQuaternion^.x:=aNewValue;
 end;
end;

procedure TpvRotation3DProperty.SetY(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fQuaternion^.y<>aNewValue) then begin
  fQuaternion^.y:=aNewValue;
  fOnChange(self);
 end else begin
  fQuaternion^.y:=aNewValue;
 end;
end;

procedure TpvRotation3DProperty.SetZ(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fQuaternion^.z<>aNewValue) then begin
  fQuaternion^.z:=aNewValue;
  fOnChange(self);
 end else begin
  fQuaternion^.z:=aNewValue;
 end;
end;

procedure TpvRotation3DProperty.SetW(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fQuaternion^.w<>aNewValue) then begin
  fQuaternion^.w:=aNewValue;
  fOnChange(self);
 end else begin
  fQuaternion^.w:=aNewValue;
 end;
end;

procedure TpvRotation3DProperty.SetPitch(const aNewValue:TpvScalar);
var Angles:TpvVector3;
begin
 Angles:=fQuaternion^.Normalize.ToEuler;
 Angles.Pitch:=aNewValue*DEG2RAD;
 SetQuaternion(TpvQuaternion.CreateFromEuler(Angles));
end;

procedure TpvRotation3DProperty.SetYaw(const aNewValue:TpvScalar);
var Angles:TpvVector3;
begin
 Angles:=fQuaternion^.Normalize.ToEuler;
 Angles.Yaw:=aNewValue*DEG2RAD;
 SetQuaternion(TpvQuaternion.CreateFromEuler(Angles));
end;

procedure TpvRotation3DProperty.SetRoll(const aNewValue:TpvScalar);
var Angles:TpvVector3;
begin
 Angles:=fQuaternion^.Normalize.ToEuler;
 Angles.Roll:=aNewValue*DEG2RAD;
 SetQuaternion(TpvQuaternion.CreateFromEuler(Angles));
end;

procedure TpvRotation3DProperty.SetQuaternion(const aNewQuaternion:TpvQuaternion);
begin
 if assigned(fOnChange) and ((fQuaternion^.x<>aNewQuaternion.x) or (fQuaternion^.y<>aNewQuaternion.y) or (fQuaternion^.z<>aNewQuaternion.z) or (fQuaternion^.w<>aNewQuaternion.w)) then begin
  fQuaternion^:=aNewQuaternion;
  fOnChange(self);
 end else begin
  fQuaternion^:=aNewQuaternion;
 end;
end;

constructor TpvColorRGBProperty.Create(const aVector:PpvVector3);
begin
 inherited Create;
 fVector:=aVector;
 fOnChange:=nil;
end;

destructor TpvColorRGBProperty.Destroy;
begin
 inherited Destroy;
end;

function TpvColorRGBProperty.GetR:TpvScalar;
begin
 result:=fVector^.r;
end;

function TpvColorRGBProperty.GetG:TpvScalar;
begin
 result:=fVector^.g;
end;

function TpvColorRGBProperty.GetB:TpvScalar;
begin
 result:=fVector^.b;
end;

function TpvColorRGBProperty.GetVector:TpvVector3;
begin
 result:=fVector^;
end;

procedure TpvColorRGBProperty.SetR(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.r<>aNewValue) then begin
  fVector^.r:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.r:=aNewValue;
 end;
end;

procedure TpvColorRGBProperty.SetG(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.g<>aNewValue) then begin
  fVector^.g:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.g:=aNewValue;
 end;
end;

procedure TpvColorRGBProperty.SetB(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.b<>aNewValue) then begin
  fVector^.b:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.b:=aNewValue;
 end;
end;

procedure TpvColorRGBProperty.SetVector(const aNewVector:TpvVector3);
begin
 if assigned(fOnChange) and ((fVector^.r<>aNewVector.r) or (fVector^.g<>aNewVector.g) or (fVector^.b<>aNewVector.b)) then begin
  fVector^:=aNewVector;
  fOnChange(self);
 end else begin
  fVector^:=aNewVector;
 end;
end;

constructor TpvColorRGBAProperty.Create(const aVector:PpvVector4);
begin
 inherited Create;
 fVector:=aVector;
 fOnChange:=nil;
end;

destructor TpvColorRGBAProperty.Destroy;
begin
 inherited Destroy;
end;

function TpvColorRGBAProperty.GetR:TpvScalar;
begin
 result:=fVector^.r;
end;

function TpvColorRGBAProperty.GetG:TpvScalar;
begin
 result:=fVector^.g;
end;

function TpvColorRGBAProperty.GetB:TpvScalar;
begin
 result:=fVector^.b;
end;

function TpvColorRGBAProperty.GetA:TpvScalar;
begin
 result:=fVector^.a;
end;

function TpvColorRGBAProperty.GetVector:TpvVector4;
begin
 result:=fVector^;
end;

procedure TpvColorRGBAProperty.SetR(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.r<>aNewValue) then begin
  fVector^.r:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.r:=aNewValue;
 end;
end;

procedure TpvColorRGBAProperty.SetG(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.g<>aNewValue) then begin
  fVector^.g:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.g:=aNewValue;
 end;
end;

procedure TpvColorRGBAProperty.SetB(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.b<>aNewValue) then begin
  fVector^.b:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.b:=aNewValue;
 end;
end;

procedure TpvColorRGBAProperty.SetA(const aNewValue:TpvScalar);
begin
 if assigned(fOnChange) and (fVector^.a<>aNewValue) then begin
  fVector^.a:=aNewValue;
  fOnChange(self);
 end else begin
  fVector^.a:=aNewValue;
 end;
end;

procedure TpvColorRGBAProperty.SetVector(const aNewVector:TpvVector4);
begin
 if assigned(fOnChange) and ((fVector^.r<>aNewVector.r) or (fVector^.g<>aNewVector.g) or (fVector^.b<>aNewVector.b) or (fVector^.a<>aNewVector.a)) then begin
  fVector^:=aNewVector;
  fOnChange(self);
 end else begin
  fVector^:=aNewVector;
 end;
end;

function SolveQuadratic(const a,b,c:TpvDouble;out r0,r1:TpvDouble):TpvSizeInt;
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
   r0:=(-c)/b;
   result:=1;
  end;
 end else begin
  d:=sqr(b)+((4.0*a)*c);
  if IsZero(d) then begin
   r0:=(-b)/(2.0*a);
   result:=1;
  end else if d>0.0 then begin
   d:=sqrt(d);
   r0:=((-b)+d)/(2.0*a);
   r1:=((-b)-d)/(2.0*a);
   result:=2;
  end else begin
   result:=0;
  end;
 end;
end;

function SolveCubic(const a,b,c,d:TpvDouble;out r0,r1,r2:TpvDouble):TpvSizeInt;
const ONE_OVER_3=1.0/3.0;
      ONE_OVER_9=1.0/9.0;
      ONE_OVER_54=1.0/9.0;
var a0,a1,a2,o,q,r,d_,u,Theta,t:TpvDouble;
begin
 if IsZero(a) then begin
  result:=SolveQuadratic(b,c,d,r0,r1);
 end else begin
  result:=0;
  a2:=b/a;
  a1:=c/a;
  a0:=d/a;
  q:=(a1*ONE_OVER_3)-(sqr(a2)*ONE_OVER_9);
  r:=((27.0*a0)+(a2*((2.0*sqr(a2))-(9.0*a1))))*ONE_OVER_54;
  d_:=(q*sqr(q))+sqr(r);
  o:=(-ONE_OVER_3)*a2;
  if IsZero(d_) then begin
   if IsZero(r) then begin
    r0:=0.0;
    result:=1;
   end else begin
    u:=Power(-r,ONE_OVER_3);
    r0:=(2.0*u)+o;
    r1:=-u;
    result:=2;
   end;
  end else if d>0 then begin
   d_:=sqrt(d_);
   r0:=(Power(d_-r,ONE_OVER_3)-Power(d_+r,ONE_OVER_3))+o;
   result:=1;
  end else begin
   Theta:=ArcCos((-r)/sqrt(-(sqr(q)*q)))*ONE_OVER_3;
   t:=2*sqrt(-q);
   r0:=(t*cos(Theta))+o;
   r1:=((-t)*cos(Theta+(PI*ONE_OVER_3)))+o;
   r2:=((-t)*cos(Theta-(PI*ONE_OVER_3)))+o;
   result:=3;
  end;
 end;
end;

function SolveQuartic(const a,b,c,d,e:TpvDouble;out r0,r1,r2,r3:TpvDouble):TpvSizeInt;
var Index,OtherIndex,CubSols:TpvSizeInt;
    a_,b_,c_,d_,y,rs,tmp,ds,es:TpvDouble;
    SolValid:array[0..3] of boolean;
    Results:array[0..3] of TpvDouble;
    CubicSols:array[0..2] of TpvDouble;
begin
 if IsZero(a) then begin
  result:=SolveCubic(b,c,d,e,r0,r1,r2);
 end else begin
  SolValid[0]:=false;
  SolValid[1]:=false;
  SolValid[2]:=false;
  SolValid[3]:=false;
  a_:=b/a;
  b_:=c/a;
  c_:=d/a;
  d_:=e/a;
  CubSols:=SolveCubic(1.0,
                      -b,
                      (a_*c_)-(4.0*d_),
                      (((-sqr(a_))*d_)+((4.0*b_)*d_))-sqr(c_),
                      CubicSols[0],
                      CubicSols[1],
                      CubicSols[2]);
  if CubSols>0 then begin
   result:=0;
   y:=CubicSols[0];
   rs:=((sqr(a_)*0.25)-b_)+y;
   if IsZero(rs) then begin
    tmp:=sqr(y)-(4.0*d_);
    if tmp<0 then begin
     exit;
    end;
    ds:=(((3.0*sqr(a_))*0.25)-(2*b))+(2.0*tmp);
    es:=(((3.0*sqr(a_))*0.25)-(2*b))-(2.0*tmp);
    if ds>=0.0 then begin
     ds:=sqrt(ds);
     SolValid[0]:=true;
     SolValid[1]:=true;
     inc(result,2);
     Results[0]:=((-0.25)*a)-(ds*0.5);
     Results[1]:=((-0.25)*a)+(ds*0.5);
    end;
    if es>=0.0 then begin
     es:=sqrt(es);
     SolValid[2]:=true;
     SolValid[3]:=true;
     inc(result,2);
     Results[2]:=((-0.25)*a)-(es*0.5);
     Results[3]:=((-0.25)*a)+(es*0.5);
    end;
   end else if rs>0.0 then begin
    rs:=sqrt(rs);
    ds:=(((0.75*sqr(a_))-rs)-(2.0*b_))+((((4.0*(a_*b_))-(8.0*c_))-(sqr(a_)*a_))/(4.0*rs));
    es:=(((0.75*sqr(a_))-rs)-(2.0*b_))-((((4.0*(a_*b_))-(8.0*c_))-(sqr(a_)*a_))/(4.0*rs));
    if ds>=0.0 then begin
     ds:=sqrt(ds);
     SolValid[0]:=true;
     SolValid[1]:=true;
     inc(result,2);
     Results[0]:=(((-0.25)*a)+(rs*0.5))-(ds*0.5);
     Results[1]:=(((-0.25)*a)+(rs*0.5))+(ds*0.5);
    end;
    if es>=0.0 then begin
     es:=sqrt(es);
     SolValid[2]:=true;
     SolValid[3]:=true;
     inc(result,2);
     Results[2]:=(((-0.25)*a)-(rs*0.5))-(es*0.5);
     Results[3]:=(((-0.25)*a)-(rs*0.5))+(es*0.5);
    end;
    OtherIndex:=0;
    for Index:=0 to result-1 do begin
     while (OtherIndex<4) and not SolValid[OtherIndex] do begin
      inc(OtherIndex);
     end;
     Results[Index]:=Results[OtherIndex];
     inc(OtherIndex);
    end;
    r0:=Results[0];
    r1:=Results[1];
    r2:=Results[2];
    r3:=Results[3];
   end else begin
    result:=0;
   end;
  end else begin
   result:=0;
  end;
 end;
end;

function GetRootsDerivative(const aCoefs:array of TpvDouble):TpvDoubleDynamicArray;
var Index:TpvSizeInt;
begin
 result:=nil;
 SetLength(result,length(aCoefs)-1);
 for Index:=0 to length(aCoefs)-2 do begin
  result[Index]:=aCoefs[Index+1]*(Index+1);
 end;
end;

function PolyEval(const aCoefs:array of TpvDouble;const aValue:TpvDouble):TpvDouble;
var Index:TpvSizeInt;
begin
 result:=0.0;
 for Index:=0 to length(aCoefs)-1 do begin
  result:=(result*aValue)+aCoefs[Index];
 end;
end;

function GetRootBisection(const aCoefs:array of TpvDouble;aMin,aMax:TpvDouble;out aResult:TpvDouble):Boolean;
const TOLERANCE=1e-6;
      ACCURACY=6;
var MinValue,MaxValue,Value,t0,t1:TpvDouble;
    Iterations,Index:TpvSizeInt;
begin
 MinValue:=PolyEval(aCoefs,aMin);
 MaxValue:=PolyEval(aCoefs,aMax);
 if abs(MinValue)<TOLERANCE then begin
  aResult:=MinValue;
  result:=true;
 end else if abs(MaxValue)<TOLERANCE then begin
  aResult:=MaxValue;
  result:=true;
 end else if (MinValue*MaxValue)<=0.0 then begin
  t0:=ln(aMax-aMin);
  t1:=ln(10.0)*ACCURACY;
  Iterations:=Trunc(Ceil((t0+t1)/ln(2)));
  for Index:=0 to Iterations-1 do begin
   aResult:=(aMin+aMax)*0.5;
   Value:=PolyEval(aCoefs,aResult);
   if abs(Value)<TOLERANCE then begin
    result:=true;
    exit;
   end;
   if (Value*MinValue)<0.0 then begin
    aMax:=aResult;
    MaxValue:=Value;
   end else begin
    aMin:=aResult;
    MinValue:=Value;
   end;
  end;
  result:=false;
 end else begin
  result:=false;
 end;
end;

function SolveRootsInInterval(const aCoefs:array of TpvDouble;const aMin,aMax:TpvDouble):TpvDoubleDynamicArray;
var Derivative,DerivativeRoots:TpvDoubleDynamicArray;
    Count,Index:TpvSizeInt;
    Root:TpvDouble;
begin
 result:=nil;
 case length(aCoefs) of
  0:begin
  end;
  1..2:begin
   if GetRootBisection(aCoefs,aMin,aMax,Root) then begin
    SetLength(result,1);
    result[0]:=Root;
   end;
  end;
  else begin
   Count:=0;
   try
    SetLength(result,length(aCoefs)+2);
    Derivative:=GetRootsDerivative(aCoefs);
    DerivativeRoots:=SolveRootsInInterval(Derivative,aMin,aMax);
    if length(DerivativeRoots)>0 then begin
     if GetRootBisection(aCoefs,aMin,DerivativeRoots[0],Root) then begin
      result[Count]:=Root;
      inc(Count);
     end;
     for Index:=0 to length(DerivativeRoots)-2 do begin
      if GetRootBisection(aCoefs,DerivativeRoots[Index],DerivativeRoots[Index+1],Root) then begin
       result[Count]:=Root;
       inc(Count);
      end;
     end;
     if GetRootBisection(aCoefs,DerivativeRoots[length(DerivativeRoots)-1],aMax,Root) then begin
      result[Count]:=Root;
      inc(Count);
     end;
    end else begin
     if GetRootBisection(aCoefs,aMin,aMax,Root) then begin
      result[Count]:=Root;
      inc(Count);
     end;
    end;
   finally
    SetLength(result,Count);
   end;
  end;
 end;
end;

constructor TpvPolynomial.Create(const aCoefs:array of TpvDouble);
begin
 SetLength(Coefs,length(aCoefs));
 if length(aCoefs)>0 then begin
  Move(aCoefs[0],Coefs[0],length(aCoefs)*SizeOf(TpvDouble));
 end;
end;

function TpvPolynomial.GetDegree:TpvSizeInt;
begin
 result:=length(Coefs)-1;
end;

function TpvPolynomial.Eval(const aValue:TpvDouble):TpvDouble;
var Index:TpvSizeInt;
begin
 result:=0.0;
 for Index:=0 to length(Coefs)-1 do begin
  result:=(result*aValue)+Coefs[Index];
 end;
end;

procedure TpvPolynomial.SimplifyEquals(const aThreshold:TpvDouble=1e-12);
var Index,NewLength:TpvSizeInt;
begin
 NewLength:=length(Coefs);
 for Index:=length(Coefs)-1 downto 0 do begin
  if Coefs[Index]<=aThreshold then begin
   NewLength:=Index;
  end else begin
   break;
  end;
 end;
 if length(Coefs)<>NewLength then begin
  SetLength(Coefs,NewLength);
 end;
end;

function TpvPolynomial.GetDerivative:TpvPolynomial;
var Index:TpvSizeInt;
begin
 result.Coefs:=nil;
 SetLength(result.Coefs,length(Coefs)-1);
 for Index:=1 to length(Coefs)-1 do begin
  result.Coefs[Index-1]:=Coefs[Index]*Index;
 end;
end;

function TpvPolynomial.GetLinearRoots:TpvDoubleDynamicArray;
begin
 result:=nil;
 if not IsZero(Coefs[1]) then begin
  SetLength(result,1);
  result[0]:=-(Coefs[0]/Coefs[1]);
 end;
end;

function TpvPolynomial.GetQuadraticRoots:TpvDoubleDynamicArray;
var a,b,c,d:TpvDouble;
begin
 result:=nil;
 if GetDegree=2 then begin
  a:=Coefs[2];
  b:=Coefs[1];
  c:=Coefs[0];
  d:=sqr(b)-(4.0*c);
  if IsZero(d) then begin
   SetLength(result,1);
   result[0]:=(-0.5)*b;
  end else if d>0.0 then begin
   d:=sqrt(d);
   SetLength(result,2);
   result[0]:=((-b)+d)*0.5;
   result[1]:=((-b)-d)*0.5;
  end;
 end;
end;

function TpvPolynomial.GetCubicRoots:TpvDoubleDynamicArray;
var c3,c2,c1,c0,a,b,Offset,d,hb,t,r,Distance,Angle,Cosinus,Sinus,Sqrt3:TpvDouble;
begin
 result:=nil;
 if GetDegree=3 then begin
  c3:=Coefs[3];
  c2:=Coefs[2]/c3;
  c1:=Coefs[1]/c3;
  c0:=Coefs[0]/c3;
  a:=((3.0*c1)-sqr(c2))/3.0;
  b:=((((2.0*sqr(c2))*c2)-((9.0*c1)*c2))+(27.0*c0))/27.0;
  Offset:=c2/3.0;
  d:=(sqr(b)*0.25)+((sqr(a)*a)/27.0);
  hb:=b*0.5;
  if IsZero(abs(d)) then begin
   if hb>=0.0 then begin
    t:=-Power(hb,1.0/3.0);
   end else begin
    t:=Power(-hb,1.0/3.0);
   end;
   SetLength(result,2);
   result[0]:=(2.0*t)-Offset;
   result[1]:=(-t)-Offset;
  end else if d>0.0 then begin
   d:=sqrt(d);
   t:=(-hb)+d;
   if t>=0.0 then begin
    r:=Power(t,1.0/3.0);
   end else begin
    r:=Power(-t,1.0/3.0);
   end;
   t:=(-hb)-d;
   if t>=0.0 then begin
    r:=r+Power(t,1.0/3.0);
   end else begin
    r:=r-Power(-t,1.0/3.0);
   end;
   SetLength(result,1);
   result[0]:=r-Offset;
  end else if d<0.0 then begin
   Distance:=sqrt((-a)/3.0);
   Angle:=ArcTan2(sqrt(-d),-hb)/3.0;
   Cosinus:=cos(Angle);
   Sinus:=sin(Angle);
   Sqrt3:=sqrt(3.0);
   SetLength(result,3);
   result[0]:=((2.0*Distance)*Cosinus)-Offset;
   result[1]:=((-Distance)*(Cosinus+(Sqrt3*Sinus)))-Offset;
   result[2]:=((-Distance)*(Cosinus-(Sqrt3*Sinus)))-Offset;
  end;
 end;
end;

function TpvPolynomial.GetQuarticRoots:TpvDoubleDynamicArray;
var c4,c3,c2,c1,c0,y,d,f,t2,t1,Plus,Minus:TpvDouble;
    ResolveRoots:TpvDoubleDynamicArray;
begin
 result:=nil;
 if GetDegree=4 then begin
  c4:=Coefs[4];
  c3:=Coefs[3]/c4;
  c2:=Coefs[2]/c4;
  c1:=Coefs[1]/c4;
  c0:=Coefs[0]/c4;
  ResolveRoots:=(TpvPolynomial.Create([1.0,-c2,(c3*c1)-(4.0*c0),((((-c3)*c3)*c0)+((4.0*c2)*c0))-sqr(c1)])).GetCubicRoots;
  y:=ResolveRoots[0];
  d:=((sqr(c3)*0.25)-c2)+y;
  if IsZero(abs(d)) then begin
   t2:=sqr(y)-(4.0*c0);
   if (t2>=0.0) or IsZero(t2) then begin
    if t2<0.0 then begin
     t2:=0.0;
    end;
    t2:=2.0*sqrt(t2);
    t1:=((3.0*c3)*c3)-(2.0*c2);
    d:=t1+t2;
    if (d>0.0) and not IsZero(d) then begin
     d:=sqrt(d);
     SetLength(result,2);
     result[0]:=(c3*(-0.25))+(d*0.5);
     result[1]:=(c3*(-0.25))-(d*0.5);
    end;
    d:=t1-t2;
    if (d>0.0) and not IsZero(d) then begin
     d:=sqrt(d);
     SetLength(result,2);
     result[0]:=(c3*(-0.25))+(d*0.5);
     result[1]:=(c3*(-0.25))-(d*0.5);
    end;
   end;
  end else if d>0.0 then begin
   d:=sqrt(d);
   t1:=((((3.0*c3)*c3)*0.25)-sqr(d))-(2.0*c2);
   t2:=((((4.0*c3)*c2)-(8.0*c1))-((c3*c3)*c3))/(4.0*d);
   Plus:=t1+t2;
   Minus:=t1-t2;
   if not IsZero(Plus) then begin
    f:=sqrt(Plus);
    if not IsZero(Minus) then begin
     SetLength(result,4);
     result[0]:=(c3*(-0.25))+((d+f)*0.5);
     result[1]:=(c3*(-0.25))+((d-f)*0.5);
     f:=sqrt(Minus);
     result[2]:=(c3*(-0.25))+((f-d)*0.5);
     result[3]:=(c3*(-0.25))-((f+d)*0.5);
    end else begin
     SetLength(result,2);
     result[0]:=(c3*(-0.25))+((d+f)*0.5);
     result[1]:=(c3*(-0.25))+((d-f)*0.5);
    end;
   end else if not IsZero(Minus) then begin
    f:=sqrt(Minus);
    SetLength(result,2);
    result[0]:=(c3*(-0.25))+((f-d)*0.5);
    result[1]:=(c3*(-0.25))-((f+d)*0.5);
   end;
  end else begin
   // No roots
  end;
 end;
end;

function TpvPolynomial.GetRoots:TpvDoubleDynamicArray;
begin
 SimplifyEquals;
 case GetDegree of
  0:begin
   result:=nil;
  end;
  1:begin
   result:=GetLinearRoots;
  end;
  2:begin
   result:=GetQuadraticRoots;
  end;
  3:begin
   result:=GetCubicRoots;
  end;
  4:begin
   result:=GetQuarticRoots;
  end;
  else begin
   result:=nil;
  end;
 end;
end;

function TpvPolynomial.Bisection(aMin,aMax:TpvDouble;out aResult:TpvDouble):Boolean;
const TOLERANCE=1e-6;
      ACCURACY=6;
var MinValue,MaxValue,Value,t0,t1:TpvDouble;
    Iterations,Index:TpvSizeInt;
begin
 MinValue:=Eval(aMin);
 MaxValue:=Eval(aMax);
 if abs(MinValue)<TOLERANCE then begin
  aResult:=MinValue;
  result:=true;
 end else if abs(MaxValue)<TOLERANCE then begin
  aResult:=MaxValue;
  result:=true;
 end else if (MinValue*MaxValue)<=0.0 then begin
  t0:=ln(aMax-aMin);
  t1:=ln(10.0)*ACCURACY;
  Iterations:=Trunc(Ceil((t0+t1)/ln(2)));
  for Index:=0 to Iterations-1 do begin
   aResult:=(aMin+aMax)*0.5;
   Value:=Eval(aResult);
   if abs(Value)<TOLERANCE then begin
    result:=true;
    exit;
   end;
   if (Value*MinValue)<0.0 then begin
    aMax:=aResult;
    MaxValue:=Value;
   end else begin
    aMin:=aResult;
    MinValue:=Value;
   end;
  end;
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TpvPolynomial.GetRootsInInterval(const aMin,aMax:TpvDouble):TpvDoubleDynamicArray;
var Derivative:TpvPolynomial;
    DerivativeRoots:TpvDoubleDynamicArray;
    Count,Index:TpvSizeInt;
    Root:TpvDouble;
begin
 result:=nil;
 case length(Coefs) of
  0:begin
  end;
  1..2:begin
   if Bisection(aMin,aMax,Root) then begin
    SetLength(result,1);
    result[0]:=Root;
   end;
  end;
  else begin
   Count:=0;
   try
    SetLength(result,length(Coefs)+2);
    Derivative:=GetDerivative;
    DerivativeRoots:=Derivative.GetRootsInInterval(aMin,aMax);
    if length(DerivativeRoots)>0 then begin
     if Bisection(aMin,DerivativeRoots[0],Root) then begin
      result[Count]:=Root;
      inc(Count);
     end;
     for Index:=0 to length(DerivativeRoots)-2 do begin
      if Bisection(DerivativeRoots[Index],DerivativeRoots[Index+1],Root) then begin
       result[Count]:=Root;
       inc(Count);
      end;
     end;
     if Bisection(DerivativeRoots[length(DerivativeRoots)-1],aMax,Root) then begin
      result[Count]:=Root;
      inc(Count);
     end;
    end else begin
     if Bisection(aMin,aMax,Root) then begin
      result[Count]:=Root;
      inc(Count);
     end;
    end;
   finally
    SetLength(result,Count);
   end;
  end;
 end;
end;

// 32-bit normal encoding from Journal of Computer Graphics Techniques Vol. 3, No. 2, 2014
function EncodeNormalAsUInt32(const aNormal:TpvVector3):TpvUInt32;
var Projected0,Projected1:TpvUInt32;
    InversedL1Norm,Encoded0,Encoded1:TpvScalar;
begin
 InversedL1Norm:=1.0/(abs(aNormal.x)+abs(aNormal.y)+abs(aNormal.z));
 if aNormal.z<0.0 then begin
  Encoded0:=1.0-abs(aNormal.y*InversedL1Norm)*SignNonZero(aNormal.x);
  Encoded1:=1.0-abs(aNormal.x*InversedL1Norm)*SignNonZero(aNormal.y);
 end else begin
  Encoded0:=aNormal.x*InversedL1Norm;
  Encoded1:=aNormal.y*InversedL1Norm;
 end;
 Projected0:=((CastFloatToUInt32(Encoded0) and TpvUInt32($80000000)) shr 16) or ((CastFloatToUInt32((abs(Encoded0)+2.0)*0.5) and TpvUInt32($7fffff)) shr 8);
 Projected1:=((CastFloatToUInt32(Encoded1) and TpvUInt32($80000000)) shr 16) or ((CastFloatToUInt32((abs(Encoded1)+2.0)*0.5) and TpvUInt32($7fffff)) shr 8);
 if (Projected0 and $7fff)=0 then begin
  Projected0:=0;
 end;
 if (Projected1 and $7fff)=0 then begin
  Projected1:=0;
 end;
 result:=(Projected1 shl 16) or Projected0;
end;

function DecodeNormalFromUInt32(const aNormal:TpvUInt32):TpvVector3;
var Projected0,Projected1:TpvUInt32;
    t:TpvScalar;
begin
 Projected0:=aNormal and TpvUInt32($ffff);
 Projected1:=aNormal shr 16;
 result.x:=CastUInt32ToFloat(CastFloatToUInt32((CastUInt32ToFloat(TpvUInt32($3f800000) or ((Projected0 and TpvUInt32($7fff)) shl 8))*2.0)-2.0) or ((Projected0 and TpvUInt32($8000)) shl 16));
 result.y:=CastUInt32ToFloat(CastFloatToUInt32((CastUInt32ToFloat(TpvUInt32($3f800000) or ((Projected1 and TpvUInt32($7fff)) shl 8))*2.0)-2.0) or ((Projected1 and TpvUInt32($8000)) shl 16));
 result.z:=1.0-(abs(result.x)+abs(result.y));
 if result.z<0.0 then begin
  t:=result.x;
  result.x:=(1.0-abs(result.y))*SignNonZero(t);
  result.y:=(1.0-abs(t))*SignNonZero(result.y);
 end;
 result:=result.Normalize;
end;

function OctahedralProjectionMappingEncode(const aVector:TpvVector3):TpvVector2;
var Vector:TpvVector3;
begin
 Vector:=aVector.Normalize;
 result:=Vector.xy/(abs(Vector.x)+abs(Vector.y)+abs(Vector.z));
 if Vector.z<0.0 then begin
  result:=(TpvVector2.InlineableCreate(1.0,1.0)-result.yx.Abs)*
           TpvVector2.InlineableCreate(SignNonZero(result.x),SignNonZero(result.y));
 end;
 result:=(result*0.5)+TpvVector2.InlineableCreate(0.5,0.5);
end;

function OctahedralProjectionMappingDecode(const aVector:TpvVector2):TpvVector3;
var ix,iy:TpvInt32;
begin
 ix:=floor(aVector.x);
 iy:=floor(aVector.y);
 result.x:=aVector.x-ix;
 result.y:=aVector.y-iy;
 if ((ix+iy) and 1)<>0 then begin
  result.xy:=TpvVector2.InlineableCreate(1.0,1.0)-result.xy;
 end;
 result.xy:=(result.xy*2.0)-TpvVector2.InlineableCreate(1.0,1.0);
 result.z:=(1.0-abs(result.x))-abs(result.y);
 if result.z<0 then begin
  result.xy:=(TpvVector2.InlineableCreate(1.0,1.0)-result.yx.Abs)*TpvVector2.InlineableCreate(SignNonZero(result.x),SignNonZero(result.y));
 end;
 result:=result.Normalize;
end;

function OctahedralProjectionMappingSignedEncode(const aVector:TpvVector3):TpvVector2;
var Vector:TpvVector3;
begin
 Vector:=aVector.Normalize;
 result:=Vector.xy/(abs(Vector.x)+abs(Vector.y)+abs(Vector.z));
 if Vector.z<0.0 then begin
  result:=(TpvVector2.InlineableCreate(1.0,1.0)-result.yx.Abs)*
           TpvVector2.InlineableCreate(SignNonZero(result.x),SignNonZero(result.y));
 end;
end;

function OctahedralProjectionMappingSignedDecode(const aVector:TpvVector2):TpvVector3;
begin
 result:=TpvVector3.InlineableCreate(aVector.xy,(1.0-abs(aVector.x))-abs(aVector.y));
 if result.z<0 then begin
  result.xy:=(TpvVector2.InlineableCreate(1.0,1.0)-result.yx.Abs)*TpvVector2.InlineableCreate(SignNonZero(result.x),SignNonZero(result.y));
 end;
 result:=result.Normalize;
end;

function OctEncode(const aVector:TpvVector3;const aFloorX,aFloorY:Boolean):TpvInt16Vector2; overload;
var Vector:TpvVector3;
    x,y,s,tx,ty:TpvScalar;
begin
 Vector:=aVector.Normalize;
 s:=abs(Vector.x)+abs(Vector.y)+abs(Vector.z);
 x:=Vector.x/s;
 y:=Vector.y/s;
 if Vector.z<0.0 then begin
  tx:=1.0-abs(y);
  if x<0.0 then begin
   tx:=-tx;
  end;
  ty:=1.0-abs(x);
  if y<0.0 then begin
   ty:=-ty;
  end;
  x:=tx;
  y:=ty;
 end;
 if aFloorX then begin
  result.x:=Min(Max(trunc(Floor(x*32767.0)),-32767),32767);
 end else begin
  result.x:=Min(Max(trunc(Ceil(x*32767.0)),-32767),32767);
 end;
 if aFloorY then begin
  result.y:=Min(Max(trunc(Floor(y*32767.0)),-32767),32767);
 end else begin
  result.y:=Min(Max(trunc(Ceil(y*32767.0)),-32767),32767);
 end;
end;

function OctDecode(const aOct:TpvInt16Vector2):TpvVector3;
var x,y,z,s,tx,ty:TpvScalar;
begin
 x:=Max(-32767,aOct.x)/32767.0;
 y:=Max(-32767,aOct.y)/32767.0;
 z:=(1.0-abs(x))-abs(y);
 if z<0 then begin
  tx:=1.0-abs(y);
  if x<0.0 then begin
   tx:=-tx;
  end;
  ty:=1.0-abs(x);
  if y<0.0 then begin
   ty:=-ty;
  end;
  x:=tx;
  y:=ty;
 end;
 result:=TpvVector3.Create(x,y,z).Normalize;
end;

function OctEncode(const aVector:TpvVector3):TpvInt16Vector2; overload;
var Vector:TpvVector3;
    Oct:TpvInt16Vector2;
    BestDot,Dot:TpvScalar;
begin

 Vector:=aVector.Normalize;

 result:=OctEncode(Vector,false,false);
 BestDot:=Vector.Dot(OctDecode(result));

 Oct:=OctEncode(Vector,false,true);
 Dot:=Vector.Dot(OctDecode(Oct));
 if BestDot>Dot then begin
  result:=Oct;
  BestDot:=Dot;
 end;

 Oct:=OctEncode(Vector,true,true);
 Dot:=Vector.Dot(OctDecode(Oct));
 if BestDot>Dot then begin
  result:=Oct;
  BestDot:=Dot;
 end;

 Oct:=OctEncode(Vector,true,false);
 Dot:=Vector.Dot(OctDecode(Oct));
 if BestDot>Dot then begin
  result:=Oct;
  BestDot:=Dot;
 end;

end;

function EncodeDiamondUnsigned(const aVector:TpvVector2):TpvScalar;
var SignYOver4:TpvScalar;
begin
 SignYOver4:=SignNonZero(aVector.y)*0.25;
 result:=(0.5+SignYOver4)-(SignYOver4*(aVector.x/(abs(aVector.x)+abs(aVector.y))));
end;

function DecodeDiamondUnsigned(const aValue:TpvScalar):TpvVector2;
var SignPMinusHalf,x,y:TpvScalar;
begin
 SignPMinusHalf:=SignNonZero(aValue-0.5);
 x:=(1.0+(SignPMinusHalf*2.0))-(SignPMinusHalf*4.0*aValue);
 y:=SignPMinusHalf*(1.0-abs(x));
 result:=TpvVector2.InlineableCreate(x,y).Normalize;
end;

function EncodeDiamondSigned(const aVector:TpvVector2):TpvScalar;
begin
 result:=(1.0-(aVector.x/(abs(aVector.x)+abs(aVector.y))))*SignNonZero(aVector.y)*0.5;
end;

function DecodeDiamondSigned(const aValue:TpvScalar):TpvVector2;
var SignPMinusHalf,x,y:TpvScalar;
begin
 SignPMinusHalf:=SignNonZero(aValue);
 x:=1.0-(aValue*SignPMinusHalf*2.0);
 y:=SignPMinusHalf*(1.0-abs(x));
 result:=TpvVector2.InlineableCreate(x,y).Normalize;
end;

function EncodeTangentSpaceAsRGB10A2SNorm(const aTangent,aBitangent,aNormal:TpvVector3):TpvUInt32;
var OctahedronNormal,TangentInCanonicalSpace:TpvVector2;
    Normal,Tangent,CanonicalDirectionA,CanonicalDirectionB:TpvVector3;
    TangentDiamond,BitangentSign:TpvScalar;
    TemporaryVector4:TpvVector4;
begin

 Normal:=aNormal.Normalize;
 Tangent:=aTangent.Normalize;

 // Encode the normal as octahedron normal
 OctahedronNormal:=OctahedralProjectionMappingSignedEncode(Normal);

 // Find the canonical directions
 CanonicalDirectionA:=(Normal.zxy-(Normal.zxy.Dot(Normal))).Normalize.Cross(Normal);
 CanonicalDirectionB:=Normal.Cross(CanonicalDirectionA);

 TangentInCanonicalSpace:=TpvVector2.InlineableCreate(Tangent.Dot(CanonicalDirectionA),Tangent.Dot(CanonicalDirectionB));

 TangentDiamond:=EncodeDiamondSigned(TangentInCanonicalSpace);

 BitangentSign:=SignNonZero(Normal.Cross(Tangent).Dot(aBitangent));

 TemporaryVector4:=TpvVector4.InlineableCreate(OctahedronNormal.x,OctahedronNormal.y,TangentDiamond,BitangentSign);

 result:=EncodeAsRGB10A2SNorm(TemporaryVector4);

end;

function EncodeTangentSpaceAsRGB10A2SNorm(const aMatrix:TpvMatrix3x3):TpvUInt32;
begin
 result:=EncodeTangentSpaceAsRGB10A2SNorm(aMatrix.Tangent,aMatrix.Bitangent,aMatrix.Normal);
end;

procedure DecodeTangentSpaceFromRGB10A2SNorm(const aValue:TpvUInt32;out aTangent,aBitangent,aNormal:TpvVector3);
var TemporaryVector4:TpvVector4;
    OctahedronNormal,TangentInCanonicalSpace:TpvVector2;
    Normal,Tangent,CanonicalDirectionA,CanonicalDirectionB:TpvVector3;
begin

 TemporaryVector4:=DecodeFromRGB10A2SNorm(aValue);

 OctahedronNormal:=TemporaryVector4.xy;

 Normal:=OctahedralProjectionMappingSignedDecode(OctahedronNormal);

 // Find the canonical directions
 CanonicalDirectionA:=(Normal.zxy-(Normal.zxy.Dot(Normal))).Normalize.Cross(Normal);
 CanonicalDirectionB:=Normal.Cross(CanonicalDirectionA);

 TangentInCanonicalSpace:=DecodeDiamondSigned(TemporaryVector4.z);

 Tangent:=((CanonicalDirectionA*TangentInCanonicalSpace.x)+(CanonicalDirectionB*TangentInCanonicalSpace.y)).Normalize;

 aTangent:=Tangent;
 aBitangent:=Normal.Cross(Tangent).Normalize*TemporaryVector4.w;
 aNormal:=Normal;

end;

procedure DecodeTangentSpaceFromRGB10A2SNorm(const aValue:TpvUInt32;out aMatrix3x3:TpvMatrix3x3);
var Tangent,Bitangent,Normal:TpvVector3;
begin
 DecodeTangentSpaceFromRGB10A2SNorm(aValue,Tangent,Bitangent,Normal);
 aMatrix3x3.Tangent:=Tangent;
 aMatrix3x3.Bitangent:=Bitangent;
 aMatrix3x3.Normal:=Normal;
end;

// 10bit 10bit 9bit for the 3 smaller components of the quaternion and 1bit for the sign of the bitangent and 2bit for the
// largest component index for the reconstruction of the largest component of the quaternion.
// Since the three smallest components of a quaternion are between -1/sqrt(2) and 1/sqrt(2), we can rescale them to -1 .. 1
// while encoding, and then rescale them back to -1/sqrt(2) .. 1/sqrt(2) while decoding, for a better precision.
function EncodeQTangentUI32(const aTangent,aBitangent:TpvVector3;aNormal:TpvVector3):TpvUInt32;
var Scale,t,s:TpvScalar;
    q:TpvVector4;
    AbsQ:TpvVector4;
    MaxComponentIndex:TpvInt32;
begin
 if ((((((aTangent.x*aBitangent.y*aNormal.z)+
         (aTangent.y*aBitangent.z*aNormal.x)
        )+
        (aTangent.z*aBitangent.x*aNormal.y)
       )-
       (aTangent.z*aBitangent.y*aNormal.x)
      )-
      (aTangent.y*aBitangent.x*aNormal.z)
     )-
     (aTangent.x*aBitangent.z*aNormal.y)
    )<0.0 then begin
  // Reflection matrix, so flip y axis in case the tangent frame encodes a reflection
  Scale:=-1.0;
  aNormal:=-aNormal;
 end else begin
  // Rotation matrix, so nothing is doing to do
  Scale:=1.0;
 end;
 t:=aTangent.x+(aBitangent.y+aNormal.z);
 if t>2.9999999 then begin
  q:=TpvVector4.InlineableCreate(0.0,0.0,0.0,1.0);
 end else if t>0.0000001 then begin
  s:=sqrt(1.0+t)*2.0;
  q:=TpvVector4.InlineableCreate(TpvVector3.InlineableCreate(aBitangent.z-aNormal.y,aNormal.x-aTangent.z,aTangent.y-aBitangent.x)/s,s*0.25).Normalize;
 end else if (aTangent.x>aBitangent.y) and (aTangent.x>aNormal.z) then begin
  s:=sqrt(1.0+(aTangent.x-(aBitangent.y+aNormal.z)))*2.0;
  q:=TpvVector4.InlineableCreate(TpvVector3.InlineableCreate(aBitangent.x+aTangent.y,aNormal.x+aTangent.z,aBitangent.z-aNormal.y)/s,s*0.25).wxyz.Normalize;
 end else if aBitangent.y>aNormal.z then begin
  s:=sqrt(1.0+(aBitangent.y-(aTangent.x+aNormal.z)))*2.0;
  q:=TpvVector4.InlineableCreate(TpvVector3.InlineableCreate(aBitangent.x+aTangent.y,aNormal.y+aBitangent.z,aNormal.x-aTangent.z)/s,s*0.25).xwyz.Normalize;
 end else begin
  s:=sqrt(1.0+(aNormal.z-(aTangent.x+aBitangent.y)))*2.0;
  q:=TpvVector4.InlineableCreate(TpvVector3.InlineableCreate(aNormal.x+aTangent.z,aNormal.y+aBitangent.z,aTangent.y-aBitangent.x)/s,s*0.25).xywz.Normalize;
 end;
 AbsQ:=q.Abs;
 if AbsQ.x>AbsQ.y then begin
  if AbsQ.x>AbsQ.z then begin
   if AbsQ.x>AbsQ.w then begin
    MaxComponentIndex:=0;
   end else begin
    MaxComponentIndex:=3;
   end;
  end else begin
   if AbsQ.z>AbsQ.w then begin
    MaxComponentIndex:=2;
   end else begin
    MaxComponentIndex:=3;
   end;
  end;
 end else begin
  if AbsQ.y>AbsQ.z then begin
   if AbsQ.y>AbsQ.w then begin
    MaxComponentIndex:=1;
   end else begin
    MaxComponentIndex:=3;
   end;
  end else begin
   if AbsQ.z>AbsQ.w then begin
    MaxComponentIndex:=2;
   end else begin
    MaxComponentIndex:=3;
   end;
  end;
 end;
 case MaxComponentIndex of
  0:begin
   q:=q.yzwx;
  end;
  1:begin
   q:=q.xzwy;
  end; 
  2:begin
   q:=q.xywz;
  end;
  else {3:}begin
   q:=q.xyzw;
  end;
 end;
 q.xyz:=q.xyz*1.4142135623730951;
 if q.w<0.0 then begin
  q:=-q;
 end;
 result:=((TpvUInt32(round(clamp(q.x*511.0,-511.0,511.0)+512.0)) and $3ff) shl 0) or
         ((TpvUInt32(round(clamp(q.y*511.0,-511.0,511.0)+512.0)) and $3ff) shl 10) or
         ((TpvUInt32(round(clamp(q.z*255.0,-255.0,255.0)+256.0)) and $1ff) shl 20) or
         (TpvUInt32(Ord((aTangent.Cross(aNormal).Dot(aBitangent)*Scale)<0.0) and 1) shl 29) or
         ((TpvUInt32(MaxComponentIndex and 3) shl 30));
end;

function EncodeQTangentUI32(const aMatrix:TpvMatrix3x3):TpvUInt32;
begin
 result:=EncodeQTangentUI32(aMatrix.Tangent,aMatrix.Bitangent,aMatrix.Normal);
end;

function EncodeQTangentUI32(const aMatrix:TpvMatrix4x4):TpvUInt32;
begin
 result:=EncodeQTangentUI32(aMatrix.Tangent.xyz,aMatrix.Bitangent.xyz,aMatrix.Normal.xyz);
end;

procedure DecodeQTangentUI32Vectors(const aValue:TpvUInt32;out aTangent,aBitangent,aNormal:TpvVector3);
const DivVector3:TpvVector3=(x:511.0;y:511.0;z:255.0);
var q:TpvVector4;
    t2,tx,ty,tz:TpvVector3;
begin
 q:=TpvVector4.InlineableCreate((TpvVector3.InlineableCreate(
                                  TpvInt32((aValue shr 0) and $3ff)-512,
                                  TpvInt32((aValue shr 10) and $3ff)-512,
                                  TpvInt32((aValue shr 20) and $1ff)-256
                                 )/DivVector3)*0.7071067811865475,0.0);
 q.w:=sqrt(1.0-Clamp(q.xyz.SquaredLength,0.0,1.0));
 case (aValue shr 30) and 3 of
  0:begin
   q:=q.wxyz.Normalize;
  end;
  1:begin
   q:=q.xwyz.Normalize;
  end;
  2:begin
   q:=q.xywz.Normalize;
  end;
  else {3:}begin
   q:=q.xyzw.Normalize;
  end;
 end;
 t2:=q.xyz*2.0;
 tx:=q.xxx*t2.xyz;
 ty:=q.yyy*t2.xyz;
 tz:=q.www*t2.xyz;
 aTangent:=TpvVector3.InlineableCreate(1.0-(ty.y+(q.z*t2.z)),tx.y+tz.z,tx.z-tz.y).Normalize;
 aNormal:=TpvVector3.InlineableCreate(tx.z+tz.y,ty.z-tz.x,1.0-(tx.x+ty.y)).Normalize;
 aBitangent:=aTangent.Cross(aNormal)*TpvScalar(TpvInt32(1-((Ord((aValue and (TpvUInt32(1) shl 29))<>0) and 1) shl 1)));
end;

function DecodeQTangentUI32(const aValue:TpvUInt32):TpvMatrix3x3;
begin
 DecodeQTangentUI32Vectors(aValue,result.Tangent,result.Bitangent,result.Normal);
end;

function TessellateTriangle(const aIndex,aResolution:TpvSizeInt;const aInputVertices:PpvVector3Array;const aOutputVertices:PpvVector3Array):TpvMatrix3x3;
var BarycentricIndex:TpvSizeInt;
    y,x,InverseResolution,t:TpvFloat;
    Inversed:Boolean;
    bc0,bc1,bc2:TpvVector2;
    uvw,p:TpvVector3;
begin

 // Setup some variables for the barycentric coordinates
 y:=floor(sqrt(aIndex));
 x:=(aIndex-sqr(y))*0.5;
 InverseResolution:=1.0/aResolution;

 // Check if it is a inverted triangle case
 Inversed:=frac(x)>0.4;

 // Calculate the barycentric coordinates of the triangle, which is made of three points.
 begin

  // Calculate the first barycentric coordinate of the triangle
  bc0:=TpvVector2.InlineableCreate(x,(aResolution+0.0)-y)*InverseResolution;
  if Inversed then begin
   bc0:=bc0+TpvVector2.InlineableCreate(0.5*InverseResolution,0.0);
  end;

  // Calculate the second barycentric coordinate of the triangle
  bc1:=bc0+TpvVector2.InlineableCreate(InverseResolution,-InverseResolution);
  if Inversed then begin
   bc1:=bc1-TpvVector2.InlineableCreate(InverseResolution,0.0);
  end;

  // Calculate the third barycentric coordinate of the triangle
  bc2:=bc0;
  if Inversed then begin
   bc2:=bc2-TpvVector2.InlineableCreate(InverseResolution,0.0);
  end else begin
   bc2:=bc2-TpvVector2.InlineableCreate(0.0,InverseResolution);
  end;

 end;

 // Put the barycentric coordinates into a 3x3 matrix for easier access, including the third w coordinate, which is just 1.0 - (u + v).
 result.RawVectors[0]:=TpvVector3.InlineableCreate(bc0,1.0-(bc0.x+bc0.y));
 result.RawVectors[1]:=TpvVector3.InlineableCreate(bc1,1.0-(bc1.x+bc1.y));
 result.RawVectors[2]:=TpvVector3.InlineableCreate(bc2,1.0-(bc2.x+bc2.y));

 // Maybe not really necessary, but just for safety reasons, clamp the barycentric coordinates to the triangle for to avoid possible out-of-bound coordinates.
 for BarycentricIndex:=0 to 2 do begin
  uvw:=result.RawVectors[BarycentricIndex];
  p:=(aInputVertices^[0]*uvw.x)+(aInputVertices^[1]*uvw.y)+(aInputVertices^[2]*uvw.z);
  if uvw.x<0.0 then begin
   t:=Clamp((p-aInputVertices^[1]).Dot(aInputVertices^[2]-aInputVertices^[1])/(aInputVertices^[2]-aInputVertices^[1]).Dot(aInputVertices^[2]-aInputVertices^[1]),0.0,1.0);
   result.RawVectors[BarycentricIndex]:=TpvVector3.Create(0.0,1.0-t,t);
  end else if uvw.y<0.0 then begin
   t:=Clamp((p-aInputVertices^[2]).Dot(aInputVertices^[0]-aInputVertices^[2])/(aInputVertices^[0]-aInputVertices^[2]).Dot(aInputVertices^[0]-aInputVertices^[2]),0.0,1.0);
   result.RawVectors[BarycentricIndex]:=TpvVector3.Create(t,0.0,1.0-t);
  end else if uvw.z<0.0 then begin
   t:=Clamp((p-aInputVertices^[0]).Dot(aInputVertices^[1]-aInputVertices^[0])/(aInputVertices^[1]-aInputVertices^[0]).Dot(aInputVertices^[1]-aInputVertices^[0]),0.0,1.0);
   result.RawVectors[BarycentricIndex]:=TpvVector3.Create(1.0-t,t,0.0);
  end;
 end;

 // Calculate the output vertices by multiplying the barycentric coordinates with the input vertices.
 aOutputVertices^[0]:=(aInputVertices^[0]*result.RawVectors[0].x)+(aInputVertices^[1]*result.RawVectors[0].y)+(aInputVertices^[2]*result.RawVectors[0].z);
 aOutputVertices^[1]:=(aInputVertices^[0]*result.RawVectors[1].x)+(aInputVertices^[1]*result.RawVectors[1].y)+(aInputVertices^[2]*result.RawVectors[1].z);
 aOutputVertices^[2]:=(aInputVertices^[0]*result.RawVectors[2].x)+(aInputVertices^[1]*result.RawVectors[2].y)+(aInputVertices^[2]*result.RawVectors[2].z);

 // Return the barycentric coordinates for other possible calculations like texture coordinate interpolation and the like.
 // result is already set

end;

function IndirectTessellateTriangle(const aIndex,aResolution:TpvSizeInt;const aInputVertices:PPpvVector3Array;const aOutputVertices:PPpvVector3Array):TpvMatrix3x3;
var BarycentricIndex:TpvSizeInt;
    y,x,InverseResolution,t:TpvFloat;
    Inversed:Boolean;
    bc0,bc1,bc2:TpvVector2;
    uvw,p:TpvVector3;
begin

 // Setup some variables for the barycentric coordinates
 y:=floor(sqrt(aIndex));
 x:=(aIndex-sqr(y))*0.5;
 InverseResolution:=1.0/aResolution;

 // Check if it is a inverted triangle case
 Inversed:=frac(x)>0.4;

 // Calculate the barycentric coordinates of the triangle, which is made of three points.
 begin

  // Calculate the first barycentric coordinate of the triangle
  bc0:=TpvVector2.InlineableCreate(x,(aResolution+0.0)-y)*InverseResolution;
  if Inversed then begin
   bc0:=bc0+TpvVector2.InlineableCreate(0.5*InverseResolution,0.0);
  end;

  // Calculate the second barycentric coordinate of the triangle
  bc1:=bc0+TpvVector2.InlineableCreate(InverseResolution,-InverseResolution);
  if Inversed then begin
   bc1:=bc1-TpvVector2.InlineableCreate(InverseResolution,0.0);
  end;

  // Calculate the third barycentric coordinate of the triangle
  bc2:=bc0;
  if Inversed then begin
   bc2:=bc2-TpvVector2.InlineableCreate(InverseResolution,0.0);
  end else begin
   bc2:=bc2-TpvVector2.InlineableCreate(0.0,InverseResolution);
  end;

 end;

 // Put the barycentric coordinates into a 3x3 matrix for easier access, including the third w coordinate, which is just 1.0 - (u + v).
 result.RawVectors[0]:=TpvVector3.InlineableCreate(bc0,1.0-(bc0.x+bc0.y));
 result.RawVectors[1]:=TpvVector3.InlineableCreate(bc1,1.0-(bc1.x+bc1.y));
 result.RawVectors[2]:=TpvVector3.InlineableCreate(bc2,1.0-(bc2.x+bc2.y));

 // Maybe not really necessary, but just for safety reasons, clamp the barycentric coordinates to the triangle for to avoid possible out-of-bound coordinates.
 for BarycentricIndex:=0 to 2 do begin
  uvw:=result.RawVectors[BarycentricIndex];
  p:=(aInputVertices^[0]^*uvw.x)+(aInputVertices^[1]^*uvw.y)+(aInputVertices^[2]^*uvw.z);
  if uvw.x<0.0 then begin
   t:=Clamp((p-aInputVertices^[1]^).Dot(aInputVertices^[2]^-aInputVertices^[1]^)/(aInputVertices^[2]^-aInputVertices^[1]^).Dot(aInputVertices^[2]^-aInputVertices^[1]^),0.0,1.0);
   result.RawVectors[BarycentricIndex]:=TpvVector3.Create(0.0,1.0-t,t);
  end else if uvw.y<0.0 then begin
   t:=Clamp((p-aInputVertices^[2]^).Dot(aInputVertices^[0]^-aInputVertices^[2]^)/(aInputVertices^[0]^-aInputVertices^[2]^).Dot(aInputVertices^[0]^-aInputVertices^[2]^),0.0,1.0);
   result.RawVectors[BarycentricIndex]:=TpvVector3.Create(t,0.0,1.0-t);
  end else if uvw.z<0.0 then begin
   t:=Clamp((p-aInputVertices^[0]^).Dot(aInputVertices^[1]^-aInputVertices^[0]^)/(aInputVertices^[1]^-aInputVertices^[0]^).Dot(aInputVertices^[1]^-aInputVertices^[0]^),0.0,1.0);
   result.RawVectors[BarycentricIndex]:=TpvVector3.Create(1.0-t,t,0.0);
  end;
 end;

 // Calculate the output vertices by multiplying the barycentric coordinates with the input vertices.
 aOutputVertices^[0]^:=(aInputVertices^[0]^*result.RawVectors[0].x)+(aInputVertices^[1]^*result.RawVectors[0].y)+(aInputVertices^[2]^*result.RawVectors[0].z);
 aOutputVertices^[1]^:=(aInputVertices^[0]^*result.RawVectors[1].x)+(aInputVertices^[1]^*result.RawVectors[1].y)+(aInputVertices^[2]^*result.RawVectors[1].z);
 aOutputVertices^[2]^:=(aInputVertices^[0]^*result.RawVectors[2].x)+(aInputVertices^[1]^*result.RawVectors[2].y)+(aInputVertices^[2]^*result.RawVectors[2].z);

 // Return the barycentric coordinates for other possible calculations like texture coordinate interpolation and the like.
 // result is already set

end;

(*
function EaseInSine(x:TpvScalar):TpvScalar;
function EaseOutSine(x:TpvScalar):TpvScalar;
function EaseInOutSine(x:TpvScalar):TpvScalar;

function EaseInQuad(x:TpvScalar):TpvScalar;
function EaseOutQuad(x:TpvScalar):TpvScalar;
function EaseInOutQuad(x:TpvScalar):TpvScalar;

function EaseInCubic(x:TpvScalar):TpvScalar;
function EaseOutCubic(x:TpvScalar):TpvScalar;
function EaseInOutCubic(x:TpvScalar):TpvScalar;

function EaseInQuart(x:TpvScalar):TpvScalar;
function EaseOutQuart(x:TpvScalar):TpvScalar;
function EaseInOutQuart(x:TpvScalar):TpvScalar;

function EaseInQuint(x:TpvScalar):TpvScalar;
function EaseOutQuint(x:TpvScalar):TpvScalar;
function EaseInOutQuint(x:TpvScalar):TpvScalar;

function EaseInExpo(x:TpvScalar):TpvScalar;
function EaseOutExpo(x:TpvScalar):TpvScalar;
function EaseInOutExpo(x:TpvScalar):TpvScalar;
*)

function EaseInSine(x:TpvScalar):TpvScalar;
begin
 result:=1.0-cos((x*PI)*0.5);
end;

function EaseOutSine(x:TpvScalar):TpvScalar;
begin
 result:=sin((x*PI)*0.5);
end;

function EaseInOutSine(x:TpvScalar):TpvScalar;
begin
 result:=0.5*(1.0-cos(x*PI));
end;

function EaseInQuad(x:TpvScalar):TpvScalar;
begin
 result:=sqr(x);
end;

function EaseOutQuad(x:TpvScalar):TpvScalar;
begin
 result:=1.0-sqr(1.0-x);
end;

function EaseInOutQuad(x:TpvScalar):TpvScalar;
begin
 if x<0.5 then begin
  result:=2.0*sqr(x);
 end else begin
  result:=1.0-(2.0*sqr(1.0-x));
 end;
end;

function EaseInCubic(x:TpvScalar):TpvScalar;
begin
 result:=sqr(x)*x;
end;

function EaseOutCubic(x:TpvScalar):TpvScalar;
begin
 result:=1.0-(sqr(1.0-x)*(1.0-x));
end;

function EaseInOutCubic(x:TpvScalar):TpvScalar;
begin
 if x<0.5 then begin
  result:=4.0*sqr(x)*x;
 end else begin
  result:=1.0-((4.0*sqr(1.0-x)*(1.0-x)));
 end;
end;

function EaseInQuart(x:TpvScalar):TpvScalar;
begin
 result:=sqr(sqr(x));
end;

function EaseOutQuart(x:TpvScalar):TpvScalar;
begin
 result:=1.0-sqr(sqr(1.0-x));
end;

function EaseInOutQuart(x:TpvScalar):TpvScalar;
begin
 if x<0.5 then begin
  result:=8.0*sqr(sqr(x));
 end else begin
  result:=1.0-(8.0*sqr(sqr(1.0-x)));
 end;
end;

function EaseInQuint(x:TpvScalar):TpvScalar;
begin
 result:=sqr(sqr(x))*x;
end;

function EaseOutQuint(x:TpvScalar):TpvScalar;
begin
 result:=1.0-(sqr(sqr(1.0-x))*(1.0-x));
end;

function EaseInOutQuint(x:TpvScalar):TpvScalar;
begin
 if x<0.5 then begin
  result:=16.0*sqr(sqr(x))*x;
 end else begin
  result:=1.0-(16.0*sqr(sqr(1.0-x))*(1.0-x));
 end;
end;

function EaseInExpo(x:TpvScalar):TpvScalar;
begin
 if x<=0.0 then begin
  result:=0.0;
 end else begin
  result:=Power(2.0,10.0*(x-1.0));
 end;
end;

function EaseOutExpo(x:TpvScalar):TpvScalar;
begin
 if x>=1.0 then begin
  result:=1.0;
 end else begin
  result:=1.0-Power(2.0,-10.0*x);
 end;
end;

function EaseInOutExpo(x:TpvScalar):TpvScalar;
begin
 if x<=0.0 then begin
  result:=0.0;
 end else if x>=1.0 then begin
  result:=1.0;
 end else begin
  if x<0.5 then begin
   result:=0.5*Power(2.0,(20.0*x)-10.0);
  end else begin
   result:=0.5*(2.0-Power(2.0,10.0-(20.0*x)));
  end;
 end;
end;

function EaseInCircle(x:TpvScalar):TpvScalar;
begin
 result:=1.0-sqrt(1.0-sqr(x));
end;

function EaseOutCircle(x:TpvScalar):TpvScalar;
begin
 result:=sqrt(1.0-sqr(x-1.0));
end;

function EaseInOutCircle(x:TpvScalar):TpvScalar;
begin
 if x<0.5 then begin
  result:=0.5*(1.0-sqrt(1.0-sqr(x*2.0)));
 end else begin
  result:=0.5*(sqrt(1.0-sqr((x*2.0)-2.0))+1.0);
 end;
end;

function EaseInBack(x:TpvScalar):TpvScalar;
const c1=1.70158;
      c3=c1+1.0;
begin
 result:=(c3*(x*x*x))-(c1*x*x);
end;

function EaseOutBack(x:TpvScalar):TpvScalar;
const c1=1.70158;
      c3=c1+1.0;
begin
 x:=x-1.0;
 result:=1.0+(c3*(x*x*x))+(c1*x*x);
end;

function EaseInOutBack(x:TpvScalar):TpvScalar;
const c1=1.70158;
      c2=c1*1.525;
begin
 if x<0.5 then begin
  result:=(sqr(2.0*x)*(((c2+1.0)*2.0*x)-c2))*0.5;
 end else begin
  result:=((sqr((2.0*x)-2.0)*((c2+1.0)*((x*2.0)-2.0)+c2))+2.0)*0.5;
 end;
end;

function EaseInElastic(x:TpvScalar):TpvScalar;
const c4=(2.0*PI)/3.0;
begin
 if x<=0.0 then begin
  result:=0.0;
 end else if x>=1.0 then begin
  result:=1.0;
 end else begin
  result:=-Power(2.0,(10*x)-10)*sin(((x*10)-10.75)*c4);
 end;
end;

function EaseOutElastic(x:TpvScalar):TpvScalar;
const c4=(2.0*PI)/3.0;
begin
 if x<=0.0 then begin
  result:=0.0;
 end else if x>=1.0 then begin
  result:=1.0;
 end else begin
  result:=(Power(2.0,(-10)*x)*sin(((x*10)-0.75)*c4))+1;
 end;
end;

function EaseInOutElastic(x:TpvScalar):TpvScalar;
const c4=(2.0*PI)/4.5;
begin
 if x<=0.0 then begin
  result:=0.0;
 end else if x>=1.0 then begin
  result:=1.0;
 end else begin
  if x<0.5 then begin
   result:=-(Power(2.0,(20*x)-10)*sin(((20*x)-11.125)*c4))*0.5;
  end else begin
   result:=(Power(2.0,(-20)*x)*sin(((20*x)-11.125)*c4))*0.5+1.0;
  end;
 end;
end;

function EaseOutBounce(x:TpvScalar):TpvScalar;
const n1=7.5625;
      d1=2.75;
      d11=1.0/d1;
      d12=2.0/d1;
      d13=2.5/d1;
      d14=1.5/d1;
      d15=2.25/d1;
      d16=2.625/d1;
begin
 if x<=0.0 then begin
  result:=0.0;
 end else if x>=1.0 then begin
  result:=1.0;
 end else begin
  if x<d11 then begin
   result:=n1*sqr(x);
  end else if x<d12 then begin
   result:=(n1*sqr(x-d14))+0.75;
  end else if x<d13 then begin
   result:=(n1*sqr(x-d15))+0.9375;
  end else begin
   result:=(n1*sqr(x-d16))+0.984375;
  end;
 end;
end;

function EaseInBounce(x:TpvScalar):TpvScalar;
begin
 result:=1.0-EaseOutBounce(1.0-x);
end;

function EaseInOutBounce(x:TpvScalar):TpvScalar;
begin
 if x<0.5 then begin
  result:=EaseInBounce(x*2.0)*0.5;
 end else begin
  result:=(EaseOutBounce((x*2.0)-1.0)*0.5)+0.5;
 end;
end;

function LerpEaseOutBounce(const aTime,aDuration,aMin,aMax:TpvScalar):TpvScalar;
const b1=4/11;
      b2=6/11;
      b3=8/11;
      b4=3/4;
      b5=9/11;
      b6=10/11;
      b7=15/16;
      b8=21/22;
      b9=63/64;
      b0=1.0/(b1*b1);
var Time:TpvScalar;
begin
 Time:=aTime/aDuration;
 if Time<=0.0 then begin
  Time:=0.0;
 end else if Time>=1.0 then begin
  Time:=1.0;
 end;
 if Time<b1 then begin
  result:=sqr(Time)*b0;
 end else if Time<b3 then begin
	result:=(sqr(Time-b2)*b0)+b4;
 end else if Time<b6 then begin
  result:=(sqr(Time-b5)*b0)+b7;
 end else begin
	result:=(sqr(Time-b8)*b0)+b9;
 end;
 result:=(aMin*(1.0-result))+(result*aMax);
end;

initialization
end.
