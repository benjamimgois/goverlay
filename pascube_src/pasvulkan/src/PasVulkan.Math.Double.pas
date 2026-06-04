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
unit PasVulkan.Math.Double;
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
     Vulkan,
     PasVulkan.Math;

type TpvVector2D=record
      public
       x,y:TpvDouble;
       constructor Create(const aFrom:TpvVector2); overload;
       constructor Create(const aX,aY:TpvDouble); overload;
       class operator Implicit(const aFrom:TpvVector2):TpvVector2D;
       class operator Implicit(const aFrom:TpvVector2D):TpvVector2;
       class operator Explicit(const aFrom:TpvVector2):TpvVector2D;
       class operator Explicit(const aFrom:TpvVector2D):TpvVector2;
       class operator Equal(const aLeft,aRight:TpvVector2D):boolean;
       class operator NotEqual(const aLeft,aRight:TpvVector2D):boolean;
       class operator Add(const aLeft,aRight:TpvVector2D):TpvVector2D;
       class operator Subtract(const aLeft,aRight:TpvVector2D):TpvVector2D;
       class operator Multiply(const aLeft,aRight:TpvVector2D):TpvVector2D;
       class operator Multiply(const aLeft:TpvVector2D;const aRight:TpvDouble):TpvVector2D;
       class operator Divide(const aLeft,aRight:TpvVector2D):TpvVector2D;
       class operator Divide(const aLeft:TpvVector2D;const aRight:TpvDouble):TpvVector2D;
       class operator Negative(const aVector:TpvVector2D):TpvVector2D;
       function Cross(const aWith:TpvVector2D):TpvVector2D;
       function Dot(const aWith:TpvVector2D):TpvDouble;
       function Length:TpvDouble;
       function SquaredLength:TpvDouble;
       function Normalize:TpvVector2D;
       function Lerp(const aWith:TpvVector2D;const aTime:TpvDouble):TpvVector2D;
       function Nlerp(const aWith:TpvVector2D;const aTime:TpvDouble):TpvVector2D;
       function Slerp(const aWith:TpvVector2D;const aTime:TpvDouble):TpvVector2D;
       function Sqlerp(const aB,aC,aD:TpvVector2D;const aTime:TpvDouble):TpvVector2D;
       function ToVector:TpvVector2;
     end;
     PpvVector2D=^TpvVector2D;

     TpvVector3D=record
      public
       constructor Create(const aFrom:TpvVector3); overload;
       constructor Create(const aX,aY,aZ:TpvDouble); overload;
       class operator Implicit(const aFrom:TpvVector3):TpvVector3D;
       class operator Implicit(const aFrom:TpvVector3D):TpvVector3;
       class operator Explicit(const aFrom:TpvVector3):TpvVector3D;
       class operator Explicit(const aFrom:TpvVector3D):TpvVector3;
       class operator Equal(const aLeft,aRight:TpvVector3D):boolean;
       class operator NotEqual(const aLeft,aRight:TpvVector3D):boolean;
       class operator Add(const aLeft,aRight:TpvVector3D):TpvVector3D;
       class operator Subtract(const aLeft,aRight:TpvVector3D):TpvVector3D;
       class operator Multiply(const aLeft,aRight:TpvVector3D):TpvVector3D;
       class operator Multiply(const aLeft:TpvVector3D;const aRight:TpvDouble):TpvVector3D;
       class operator Divide(const aLeft,aRight:TpvVector3D):TpvVector3D;
       class operator Divide(const aLeft:TpvVector3D;const aRight:TpvDouble):TpvVector3D;
       class operator Negative(const aVector:TpvVector3D):TpvVector3D;
       function Cross(const aWith:TpvVector3D):TpvVector3D;
       function Spacing(const aWith:TpvVector3D):TpvDouble;
       function Dot(const aWith:TpvVector3D):TpvDouble;
       function Length:TpvDouble;
       function SquaredLength:TpvDouble;
       function DistanceTo(const aWith:TpvVector3D):TpvDouble;
       function Normalize:TpvVector3D;
       function Perpendicular:TpvVector3D;
       function Orthogonal:TpvVector3D;
       function Lerp(const aWith:TpvVector3D;const aTime:TpvDouble):TpvVector3D;
       function Nlerp(const aWith:TpvVector3D;const aTime:TpvDouble):TpvVector3D;
       function Slerp(const aWith:TpvVector3D;const aTime:TpvDouble):TpvVector3D;
       function Sqlerp(const aB,aC,aD:TpvVector3D;const aTime:TpvDouble):TpvVector3D;
       function ToVector:TpvVector3;
      public
       case TpvInt32 of
        0:(x,y,z:TpvDouble);
        1:(xy:TpvVector2D);
     end;
     PpvVector3D=^TpvVector3D;

     TpvVector4D=record
      public
       constructor Create(const aFrom:TpvVector4); overload;
       constructor Create(const aX,aY,aZ,aW:TpvDouble); overload;
       class operator Implicit(const aFrom:TpvVector4):TpvVector4D;
       class operator Implicit(const aFrom:TpvVector4D):TpvVector4;
       class operator Explicit(const aFrom:TpvVector4):TpvVector4D;
       class operator Explicit(const aFrom:TpvVector4D):TpvVector4;
       class operator Equal(const aLeft,aRight:TpvVector4D):boolean;
       class operator NotEqual(const aLeft,aRight:TpvVector4D):boolean;
       class operator Add(const aLeft,aRight:TpvVector4D):TpvVector4D;
       class operator Subtract(const aLeft,aRight:TpvVector4D):TpvVector4D;
       class operator Multiply(const aLeft,aRight:TpvVector4D):TpvVector4D;
       class operator Multiply(const aLeft:TpvVector4D;const aRight:TpvDouble):TpvVector4D;
       class operator Divide(const aLeft,aRight:TpvVector4D):TpvVector4D;
       class operator Divide(const aLeft:TpvVector4D;const aRight:TpvDouble):TpvVector4D;
       class operator Negative(const aVector:TpvVector4D):TpvVector4D;
       function Dot(const aWith:TpvVector4D):TpvDouble;
       function Length:TpvDouble;
       function SquaredLength:TpvDouble;
       function Normalize:TpvVector4D;
       function Lerp(const aWith:TpvVector4D;const aTime:TpvDouble):TpvVector4D;
       function Nlerp(const aWith:TpvVector4D;const aTime:TpvDouble):TpvVector4D;
       function Slerp(const aWith:TpvVector4D;const aTime:TpvDouble):TpvVector4D;
       function Sqlerp(const aB,aC,aD:TpvVector4D;const aTime:TpvDouble):TpvVector4D;
       function ToVector:TpvVector4;
      public
       case TpvInt32 of
        0:(x,y,z,w:TpvDouble);
        1:(xyz:TpvVector3D);
        2:(xy:TpvVector2D);
     end;
     PpvVector4D=^TpvVector4D;

     TpvQuaternionD=record
      public
       constructor Create(const aFrom:TpvQuaternion); overload;
       constructor Create(const aX,aY,aZ,aW:TpvDouble); overload;
       constructor Create(const aMatrix:TpvMatrix3x3); overload;
       constructor Create(const aMatrix:TpvMatrix4x4); overload;
       constructor CreateFromAxisAngle(const aAxis:TpvVector3D;const aAngle:TpvDouble);
       constructor CreateFromToRotation(const aFromDirection,aToDirection:TpvVector3D);
       class operator Implicit(const aFrom:TpvQuaternion):TpvQuaternionD;
       class operator Implicit(const aFrom:TpvQuaternionD):TpvQuaternion;
       class operator Explicit(const aFrom:TpvQuaternion):TpvQuaternionD;
       class operator Explicit(const aFrom:TpvQuaternionD):TpvQuaternion;
       class operator Equal(const aLeft,aRight:TpvQuaternionD):boolean;
       class operator NotEqual(const aLeft,aRight:TpvQuaternionD):boolean;
       class operator Add(const aLeft,aRight:TpvQuaternionD):TpvQuaternionD;
       class operator Subtract(const aLeft,aRight:TpvQuaternionD):TpvQuaternionD;
       class operator Multiply(const aLeft,aRight:TpvQuaternionD):TpvQuaternionD;
       class operator Multiply(const aLeft:TpvQuaternionD;const aRight:TpvDouble):TpvQuaternionD;
       class operator Multiply(const aLeft:TpvDouble;const aRight:TpvQuaternionD):TpvQuaternionD;
       class operator Multiply(const aLeft:TpvQuaternionD;const aRight:TpvVector3D):TpvVector3D;
       class operator Multiply(const aLeft:TpvVector3D;const aRight:TpvQuaternionD):TpvVector3D;
       class operator Divide(const aLeft,aRight:TpvQuaternionD):TpvQuaternionD;
       class operator Negative(const aQuaternion:TpvQuaternionD):TpvQuaternionD;
       function Dot(const aWith:TpvQuaternionD):TpvDouble;
       function Length:TpvDouble;
       function SquaredLength:TpvDouble;
       function Normalize:TpvQuaternionD;
       function Conjugate:TpvQuaternionD;
       function Inverse:TpvQuaternionD;
       function Log:TpvQuaternionD;
       function Exp:TpvQuaternionD; 
       function Lerp(const aWith:TpvQuaternionD;const aTime:TpvDouble):TpvQuaternionD;
       function Nlerp(const aWith:TpvQuaternionD;const aTime:TpvDouble):TpvQuaternionD;
       function Slerp(const aWith:TpvQuaternionD;const aTime:TpvDouble):TpvQuaternionD;
       function ApproximatedSlerp(const aWith:TpvQuaternionD;const aTime:TpvDouble):TpvQuaternionD;
       function Elerp(const aWith:TpvQuaternionD;const aTime:TpvDouble):TpvQuaternionD;
       function Sqlerp(const aB,aC,aD:TpvQuaternionD;const aTime:TpvDouble):TpvQuaternionD;
       function ToMatrix3x3:TpvMatrix3x3;
       function ToMatrix4x4:TpvMatrix4x4;
       function ToVector:TpvVector4;
       function ToQuaternion:TpvQuaternion;
       function ToEuler:TpvVector3D;
       function ToPitch:TpvDouble;
       function ToYaw:TpvDouble;
       function ToRoll:TpvDouble;
      public
       case TpvInt32 of
        0:(x,y,z,w:TpvDouble);
        1:(Vector:TpvVector4D);
        2:(xyz:TpvVector3D);
        3:(xy:TpvVector2D);
     end;
     PpvQuaternionD=^TpvQuaternionD;

     TpvDecomposedMatrix3x3D=record
      public
       Valid:boolean;
       Scale:TpvVector3D;
       Skew:TpvVector3D; // XY XZ YZ
       Rotation:TpvQuaternionD;
       class function Create:TpvDecomposedMatrix3x3D; static;
       function Lerp(const aWith:TpvDecomposedMatrix3x3D;const aTime:TpvDouble):TpvDecomposedMatrix3x3D; 
       function Nlerp(const aWith:TpvDecomposedMatrix3x3D;const aTime:TpvDouble):TpvDecomposedMatrix3x3D;
       function Slerp(const aWith:TpvDecomposedMatrix3x3D;const aTime:TpvDouble):TpvDecomposedMatrix3x3D;
       function Elerp(const aWith:TpvDecomposedMatrix3x3D;const aTime:TpvDouble):TpvDecomposedMatrix3x3D;
       function Sqlerp(const aB,aC,aD:TpvDecomposedMatrix3x3D;const aTime:TpvDouble):TpvDecomposedMatrix3x3D;
     end;      
     PpvDecomposedMatrix3x3D=^TpvDecomposedMatrix3x3D;

     TpvMatrix3x3D=record
      public
       constructor Create(const aXX,aXY,aXZ,aYX,aYY,aYZ,aZX,aZY,aZZ:TpvDouble); overload;
       constructor Create(const aTangent,aBitangent,aNormal:TpvVector3D); overload;
       constructor Create(const aFrom:TpvMatrix3x3); overload;
       constructor Create(const aFrom:TpvMatrix4x4); overload;
       constructor Create(const aFrom:TpvQuaternion); overload;
       constructor Create(const aFrom:TpvQuaternionD); overload;
       constructor Create(const aFrom:TpvDecomposedMatrix3x3D); overload;
       class operator Implicit(const aFrom:TpvMatrix3x3):TpvMatrix3x3D;
       class operator Implicit(const aFrom:TpvMatrix3x3D):TpvMatrix3x3;
       class operator Implicit(const aFrom:TpvMatrix4x4):TpvMatrix3x3D;
       class operator Implicit(const aFrom:TpvMatrix3x3D):TpvMatrix4x4;
       class operator Implicit(const aFrom:TpvQuaternion):TpvMatrix3x3D;
       class operator Implicit(const aFrom:TpvQuaternionD):TpvMatrix3x3D;
       class operator Implicit(const aFrom:TpvDecomposedMatrix3x3D):TpvMatrix3x3D;
       class operator Implicit(const aFrom:TpvMatrix3x3D):TpvQuaternion;
       class operator Implicit(const aFrom:TpvMatrix3x3D):TpvQuaternionD;
       class operator Implicit(const aFrom:TpvMatrix3x3D):TpvDecomposedMatrix3x3D;
       class operator Explicit(const aFrom:TpvMatrix3x3):TpvMatrix3x3D;
       class operator Explicit(const aFrom:TpvMatrix3x3D):TpvMatrix3x3;
       class operator Explicit(const aFrom:TpvMatrix4x4):TpvMatrix3x3D;
       class operator Explicit(const aFrom:TpvMatrix3x3D):TpvMatrix4x4;
       class operator Explicit(const aFrom:TpvQuaternion):TpvMatrix3x3D;
       class operator Explicit(const aFrom:TpvQuaternionD):TpvMatrix3x3D;
       class operator Explicit(const aFrom:TpvDecomposedMatrix3x3D):TpvMatrix3x3D;
       class operator Explicit(const aFrom:TpvMatrix3x3D):TpvQuaternion;
       class operator Explicit(const aFrom:TpvMatrix3x3D):TpvQuaternionD;
       class operator Explicit(const aFrom:TpvMatrix3x3D):TpvDecomposedMatrix3x3D;
       class operator Equal(const aLeft,aRight:TpvMatrix3x3D):boolean;
       class operator NotEqual(const aLeft,aRight:TpvMatrix3x3D):boolean;
       class operator Add(const aLeft,aRight:TpvMatrix3x3D):TpvMatrix3x3D;
       class operator Subtract(const aLeft,aRight:TpvMatrix3x3D):TpvMatrix3x3D;
       class operator Multiply(const aLeft,aRight:TpvMatrix3x3D):TpvMatrix3x3D;
       class operator Multiply(const aLeft:TpvMatrix3x3D;const aRight:TpvDouble):TpvMatrix3x3D;
       class operator Multiply(const aLeft:TpvDouble;const aRight:TpvMatrix3x3D):TpvMatrix3x3D;
       class operator Multiply(const aLeft:TpvMatrix3x3D;const aRight:TpvVector3D):TpvVector3D;
       class operator Multiply(const aLeft:TpvVector3D;const aRight:TpvMatrix3x3D):TpvVector3D;
       class operator Multiply(const aLeft:TpvMatrix3x3D;const aRight:TpvVector4D):TpvVector4D;
       class operator Multiply(const aLeft:TpvVector4D;const aRight:TpvMatrix3x3D):TpvVector4D;
       class operator Divide(const aLeft,aRight:TpvMatrix3x3D):TpvMatrix3x3D;
       class operator Divide(const aLeft:TpvMatrix3x3D;const aRight:TpvDouble):TpvMatrix3x3D;
       class operator Negative(const aMatrix:TpvMatrix3x3D):TpvMatrix3x3D;
       function Transpose:TpvMatrix3x3D;
       function Determinant:TpvDouble;
       function Inverse:TpvMatrix3x3D;
       function Adjugate:TpvMatrix3x3D;
       function ToMatrix3x3:TpvMatrix3x3;       
       function ToQuaternionD:TpvQuaternionD;
       function Decompose:TpvDecomposedMatrix3x3D;
       function Lerp(const aWith:TpvMatrix3x3D;const aTime:TpvDouble):TpvMatrix3x3D;
       function Nlerp(const aWith:TpvMatrix3x3D;const aTime:TpvDouble):TpvMatrix3x3D;
       function Slerp(const aWith:TpvMatrix3x3D;const aTime:TpvDouble):TpvMatrix3x3D;
       function Elerp(const aWith:TpvMatrix3x3D;const aTime:TpvDouble):TpvMatrix3x3D;
       function Sqlerp(const aB,aC,aD:TpvMatrix3x3D;const aTime:TpvDouble):TpvMatrix3x3D;
      public
       case TpvInt32 of
        0:(RawComponents:array[0..2,0..2] of TpvDouble);
        1:(RawVectors:array[0..2] of TpvVector3D);
        2:(Columns:array[0..2] of TpvVector3D);
        3:(Right,Up,Forwards:TpvVector3D);
        4:(Tangent,Bitangent,Normal:TpvVector3D);
     end;
     PpvMatrix3x3D=^TpvMatrix3x3D;

     TpvDecomposedMatrix4x4D=record
      public
       Valid:boolean;
       Perspective:TpvVector4D;
       Translation:TpvVector3D;
       Scale:TpvVector3D;
       Skew:TpvVector3D; // XY XZ YZ
       Rotation:TpvQuaternionD;
       class function Create:TpvDecomposedMatrix4x4D; static;
       function Lerp(const aWith:TpvDecomposedMatrix4x4D;const aTime:TpvDouble):TpvDecomposedMatrix4x4D; 
       function Nlerp(const aWith:TpvDecomposedMatrix4x4D;const aTime:TpvDouble):TpvDecomposedMatrix4x4D;
       function Slerp(const aWith:TpvDecomposedMatrix4x4D;const aTime:TpvDouble):TpvDecomposedMatrix4x4D;
       function Elerp(const aWith:TpvDecomposedMatrix4x4D;const aTime:TpvDouble):TpvDecomposedMatrix4x4D;
       function Sqlerp(const aB,aC,aD:TpvDecomposedMatrix4x4D;const aTime:TpvDouble):TpvDecomposedMatrix4x4D;
     end;     
     PpvDecomposedMatrix4x4D=^TpvDecomposedMatrix4x4D;

     TpvMatrix4x4D=record
      public
       constructor Create(const aXX,aXY,aXZ,aXW,aYX,aYY,aYZ,aYW,aZX,aZY,aZZ,aZW,aWX,aWY,aWZ,aWW:TpvDouble); overload;
       constructor Create(const aTangent,aBitangent,aNormal,aTranslation:TpvVector3D); overload;
       constructor Create(const aFrom:TpvMatrix3x3); overload;
       constructor Create(const aFrom:TpvMatrix4x4); overload;
       constructor Create(const aFrom:TpvQuaternion); overload;
       constructor Create(const aFrom:TpvQuaternionD); overload;
       constructor Create(const aFrom:TpvDecomposedMatrix4x4D); overload;
       constructor CreateTranslation(const aTranslation:TpvVector3D);
       constructor CreateInverseLookAt(const Eye,Center,Up:TpvVector3D);
       constructor CreateLookAt(const Eye,Center,Up:TpvVector3D);
       class operator Implicit(const aFrom:TpvMatrix3x3):TpvMatrix4x4D;
       class operator Implicit(const aFrom:TpvMatrix4x4D):TpvMatrix3x3;
       class operator Implicit(const aFrom:TpvMatrix4x4):TpvMatrix4x4D;
       class operator Implicit(const aFrom:TpvMatrix4x4D):TpvMatrix4x4;
       class operator Implicit(const aFrom:TpvQuaternion):TpvMatrix4x4D;
       class operator Implicit(const aFrom:TpvQuaternionD):TpvMatrix4x4D;
       class operator Implicit(const aFrom:TpvDecomposedMatrix4x4D):TpvMatrix4x4D;
       class operator Implicit(const aFrom:TpvMatrix4x4D):TpvQuaternion;
       class operator Implicit(const aFrom:TpvMatrix4x4D):TpvQuaternionD;
       class operator Implicit(const aFrom:TpvMatrix4x4D):TpvDecomposedMatrix4x4D;
       class operator Explicit(const aFrom:TpvMatrix3x3):TpvMatrix4x4D;
       class operator Explicit(const aFrom:TpvMatrix4x4D):TpvMatrix3x3;
       class operator Explicit(const aFrom:TpvMatrix4x4):TpvMatrix4x4D;
       class operator Explicit(const aFrom:TpvMatrix4x4D):TpvMatrix4x4;
       class operator Explicit(const aFrom:TpvQuaternion):TpvMatrix4x4D;
       class operator Explicit(const aFrom:TpvQuaternionD):TpvMatrix4x4D;
       class operator Explicit(const aFrom:TpvDecomposedMatrix4x4D):TpvMatrix4x4D;
       class operator Explicit(const aFrom:TpvMatrix4x4D):TpvQuaternion;
       class operator Explicit(const aFrom:TpvMatrix4x4D):TpvQuaternionD;
       class operator Explicit(const aFrom:TpvMatrix4x4D):TpvDecomposedMatrix4x4D;
       class operator Equal(const aLeft,aRight:TpvMatrix4x4D):boolean;
       class operator NotEqual(const aLeft,aRight:TpvMatrix4x4D):boolean;
       class operator Add(const aLeft,aRight:TpvMatrix4x4D):TpvMatrix4x4D;
       class operator Subtract(const aLeft,aRight:TpvMatrix4x4D):TpvMatrix4x4D;
       class operator Multiply(const aLeft,aRight:TpvMatrix4x4D):TpvMatrix4x4D;
       class operator Multiply(const aLeft:TpvMatrix4x4D;const aRight:TpvDouble):TpvMatrix4x4D;
       class operator Multiply(const aLeft:TpvDouble;const aRight:TpvMatrix4x4D):TpvMatrix4x4D;
       class operator Multiply(const aLeft:TpvMatrix4x4D;const aRight:TpvVector3D):TpvVector4D;
       class operator Multiply(const aLeft:TpvVector3D;const aRight:TpvMatrix4x4D):TpvVector4D;
       class operator Multiply(const aLeft:TpvMatrix4x4D;const aRight:TpvVector4D):TpvVector4D;
       class operator Multiply(const aLeft:TpvVector4D;const aRight:TpvMatrix4x4D):TpvVector4D;
       class operator Divide(const aLeft,aRight:TpvMatrix4x4D):TpvMatrix4x4D;
       class operator Divide(const aLeft:TpvMatrix4x4D;const aRight:TpvDouble):TpvMatrix4x4D;
       class operator Negative(const aMatrix:TpvMatrix4x4D):TpvMatrix4x4D;
       function MulInverted({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3D):TpvVector3D; overload;
       function MulInverted({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4D):TpvVector4D; overload;
       function MulBasis(const aVector:TpvVector3):TpvVector3; overload;
       function MulBasis(const aVector:TpvVector3D):TpvVector3D; overload;
       function MulHomogen(const aVector:TpvVector3):TpvVector3; overload;
       function MulHomogen(const aVector:TpvVector3D):TpvVector3D; overload;
       function MulInverse(const aVector:TpvVector3):TpvVector3; overload;
       function MulInverse(const aVector:TpvVector3D):TpvVector3D; overload;
       function Transpose:TpvMatrix4x4D;
       function Determinant:TpvDouble;
       function SimpleInverse:TpvMatrix4x4D;
       function Inverse:TpvMatrix4x4D;
       function Adjugate:TpvMatrix4x4D;
       function ToMatrix4x4:TpvMatrix4x4;
       function ToQuaternionD:TpvQuaternionD;
       function Decompose:TpvDecomposedMatrix4x4D;
       function ToDoubleSingleFloatingPointMatrix4x4:TpvMatrix4x4;
       function Normalize:TpvMatrix4x4D;
       function OrthoNormalize:TpvMatrix4x4D;
       function RobustOrthoNormalize(const Tolerance:TpvDouble=1e-3):TpvMatrix4x4D;
       function SimpleLerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
       function SimpleNlerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
       function SimpleSlerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
       function SimpleElerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
       function SimpleSqlerp(const aB,aC,aD:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
       function Lerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
       function Nlerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
       function Slerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
       function Elerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
       function Sqlerp(const aB,aC,aD:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
      public
       case TpvInt32 of
        0:(RawComponents:array[0..3,0..3] of TpvDouble);
        1:(RawVectors:array[0..3] of TpvVector4D);
        2:(Columns:array[0..3] of TpvVector4D);
        3:(Right,Up,Forwards,Translation:TpvVector4D);
        4:(Tangent,Bitangent,Normal,Offset:TpvVector4D);
     end;
     PpvMatrix4x4D=^TpvMatrix4x4D;

     TpvTransform3D=record
      public
       Position:TpvVector3D;
       Orientation:TpvQuaternionD;
       Scale:TpvVector3D;
       constructor Create(const aPosition:TpvVector3D;const aOrientation:TpvQuaternionD;const aScale:TpvVector3D); overload;
       constructor Create(const aPosition:TpvVector3D;const aOrientation:TpvQuaternionD); overload;
       constructor Create(const aPosition:TpvVector3D); overload;
       constructor Create(const aFrom:TpvMatrix4x4); overload;
       constructor Create(const aFrom:TpvMatrix4x4D); overload;
       class operator Implicit(const aFrom:TpvMatrix4x4):TpvTransform3D;
       class operator Implicit(const aFrom:TpvMatrix4x4D):TpvTransform3D;
       class operator Implicit(const aFrom:TpvTransform3D):TpvMatrix4x4;
       class operator Implicit(const aFrom:TpvTransform3D):TpvMatrix4x4D;
       class operator Explicit(const aFrom:TpvMatrix4x4):TpvTransform3D;
       class operator Explicit(const aFrom:TpvMatrix4x4D):TpvTransform3D;
       class operator Explicit(const aFrom:TpvTransform3D):TpvMatrix4x4;
       class operator Explicit(const aFrom:TpvTransform3D):TpvMatrix4x4D;
       class operator Equal(const aLeft,aRight:TpvTransform3D):boolean;
       class operator NotEqual(const aLeft,aRight:TpvTransform3D):boolean;
       function Lerp(const aWith:TpvTransform3D;const aTime:TpvDouble):TpvTransform3D;
       function Nlerp(const aWith:TpvTransform3D;const aTime:TpvDouble):TpvTransform3D;
       function Slerp(const aWith:TpvTransform3D;const aTime:TpvDouble):TpvTransform3D;
       function Elerp(const aWith:TpvTransform3D;const aTime:TpvDouble):TpvTransform3D;
       function Sqlerp(const aB,aC,aD:TpvTransform3D;const aTime:TpvDouble):TpvTransform3D;
     end;
     PpvTransform3D=^TpvTransform3D;

procedure SplitDouble(const a:TpvDouble;out aHi,aLo:TpvFloat);

implementation

// http://andrewthall.org/papers/df64_qf128.pdf
procedure SplitDouble(const a:TpvDouble;out aHi,aLo:TpvFloat);
const SPLITER:TpvDouble=(1 shl 29)+1; 
var t,tHi,tLo:TpvDouble;
begin
 t:=a*SPLITER;
 tHi:=t-(t-a);
 tLo:=a-tHi;
 aHi:=tHi;
 aLo:=tLo;
end;

{ TpvVector2D }

constructor TpvVector2D.Create(const aFrom:TpvVector2);
begin
 x:=aFrom.x;
 y:=aFrom.y;
end;

constructor TpvVector2D.Create(const aX,aY:TpvDouble);
begin
 x:=aX;
 y:=aY;
end;

class operator TpvVector2D.Implicit(const aFrom:TpvVector2):TpvVector2D;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
end;

class operator TpvVector2D.Implicit(const aFrom:TpvVector2D):TpvVector2;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
end;

class operator TpvVector2D.Explicit(const aFrom:TpvVector2):TpvVector2D;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
end;

class operator TpvVector2D.Explicit(const aFrom:TpvVector2D):TpvVector2;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
end;

class operator TpvVector2D.Equal(const aLeft,aRight:TpvVector2D):boolean;
begin
 result:=SameValue(aLeft.x,aRight.x) and
         SameValue(aLeft.y,aRight.y);
end;

class operator TpvVector2D.NotEqual(const aLeft,aRight:TpvVector2D):boolean;
begin
 result:=not (SameValue(aLeft.x,aRight.x) and
              SameValue(aLeft.y,aRight.y));
end;

class operator TpvVector2D.Add(const aLeft,aRight:TpvVector2D):TpvVector2D;
begin
 result.x:=aLeft.x+aRight.x;
 result.y:=aLeft.y+aRight.y;
end;

class operator TpvVector2D.Subtract(const aLeft,aRight:TpvVector2D):TpvVector2D;
begin
 result.x:=aLeft.x-aRight.x;
 result.y:=aLeft.y-aRight.y;
end;

class operator TpvVector2D.Multiply(const aLeft,aRight:TpvVector2D):TpvVector2D;
begin
 result.x:=aLeft.x*aRight.x;
 result.y:=aLeft.y*aRight.y;
end;

class operator TpvVector2D.Multiply(const aLeft:TpvVector2D;const aRight:TpvDouble):TpvVector2D;
begin
 result.x:=aLeft.x*aRight;
 result.y:=aLeft.y*aRight;
end;

class operator TpvVector2D.Divide(const aLeft,aRight:TpvVector2D):TpvVector2D;
begin
 result.x:=aLeft.x/aRight.x;
 result.y:=aLeft.y/aRight.y;
end;

class operator TpvVector2D.Divide(const aLeft:TpvVector2D;const aRight:TpvDouble):TpvVector2D;
begin
 result.x:=aLeft.x/aRight;
 result.y:=aLeft.y/aRight;
end;

class operator TpvVector2D.Negative(const aVector:TpvVector2D):TpvVector2D;
begin
 result.x:=-aVector.x;
 result.y:=-aVector.y;
end;

function TpvVector2D.Cross(const aWith:TpvVector2D):TpvVector2D;
begin
 result.x:=(y*aWith.x)-(x*aWith.y);
 result.y:=(x*aWith.y)-(y*aWith.x);
end;

function TpvVector2D.Dot(const aWith:TpvVector2D):TpvDouble;
begin
 result:=(x*aWith.x)+(y*aWith.y);
end;

function TpvVector2D.Length:TpvDouble;
begin
 result:=sqrt(sqr(x)+sqr(y));
end;

function TpvVector2D.SquaredLength:TpvDouble;
begin
 result:=sqr(x)+sqr(y);
end;

function TpvVector2D.Normalize:TpvVector2D;
var l:TpvDouble;
begin
 l:=Length;
 if l>0.0 then begin
  result:=self/l;
 end else begin
  result:=self;
 end; 
end;

function TpvVector2D.Lerp(const aWith:TpvVector2D;const aTime:TpvDouble):TpvVector2D;
var InverseTime:TpvDouble;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  InverseTime:=1.0-aTime;
  result.x:=(x*InverseTime)+(aWith.x*aTime);
  result.y:=(y*InverseTime)+(aWith.y*aTime);
 end;
end;

function TpvVector2D.Nlerp(const aWith:TpvVector2D;const aTime:TpvDouble):TpvVector2D;
begin
 result:=Lerp(aWith,aTime).Normalize;
end;

function TpvVector2D.Slerp(const aWith:TpvVector2D;const aTime:TpvDouble):TpvVector2D;
var DotProduct,Theta,Sinus,Cosinus:TpvDouble;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else if self=aWith then begin
  result:=aWith;
 end else begin
  DotProduct:=Dot(aWith);
  if DotProduct<-1.0 then begin
   DotProduct:=-1.0;
  end else if DotProduct>1.0 then begin
   DotProduct:=1.0;
  end;
  Theta:=ArcCos(DotProduct)*aTime;
  SinCos(Theta,Sinus,Cosinus);
  result:=(self*Cosinus)+((aWith-(self*DotProduct)).Normalize*Sinus);
 end;
end;

function TpvVector2D.Sqlerp(const aB,aC,aD:TpvVector2D;const aTime:TpvDouble):TpvVector2D;
begin
 result:=Slerp(aD,aTime).Slerp(aB.Slerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

function TpvVector2D.ToVector:TpvVector2;
begin
 result.x:=x;
 result.y:=y;
end;

{ TpvVector3D }

constructor TpvVector3D.Create(const aFrom:TpvVector3);
begin
 x:=aFrom.x;
 y:=aFrom.y;
 z:=aFrom.z;
end;

constructor TpvVector3D.Create(const aX,aY,aZ:TpvDouble);
begin
 x:=aX;
 y:=aY;
 z:=aZ;
end;

class operator TpvVector3D.Implicit(const aFrom:TpvVector3):TpvVector3D;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
 result.z:=aFrom.z;
end;

class operator TpvVector3D.Implicit(const aFrom:TpvVector3D):TpvVector3;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
 result.z:=aFrom.z;
end;

class operator TpvVector3D.Explicit(const aFrom:TpvVector3):TpvVector3D;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
 result.z:=aFrom.z;
end;

class operator TpvVector3D.Explicit(const aFrom:TpvVector3D):TpvVector3;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
 result.z:=aFrom.z;
end;

class operator TpvVector3D.Equal(const aLeft,aRight:TpvVector3D):boolean;
begin
 result:=SameValue(aLeft.x,aRight.x) and
         SameValue(aLeft.y,aRight.y) and
         SameValue(aLeft.z,aRight.z);
end;

class operator TpvVector3D.NotEqual(const aLeft,aRight:TpvVector3D):boolean;
begin
 result:=not (SameValue(aLeft.x,aRight.x) and
              SameValue(aLeft.y,aRight.y) and
              SameValue(aLeft.z,aRight.z));
end;

class operator TpvVector3D.Add(const aLeft,aRight:TpvVector3D):TpvVector3D;
begin
 result.x:=aLeft.x+aRight.x;
 result.y:=aLeft.y+aRight.y;
 result.z:=aLeft.z+aRight.z;
end;

class operator TpvVector3D.Subtract(const aLeft,aRight:TpvVector3D):TpvVector3D;
begin
 result.x:=aLeft.x-aRight.x;
 result.y:=aLeft.y-aRight.y;
 result.z:=aLeft.z-aRight.z;
end;

class operator TpvVector3D.Multiply(const aLeft,aRight:TpvVector3D):TpvVector3D;
begin
 result.x:=aLeft.x*aRight.x;
 result.y:=aLeft.y*aRight.y;
 result.z:=aLeft.z*aRight.z;
end;

class operator TpvVector3D.Multiply(const aLeft:TpvVector3D;const aRight:TpvDouble):TpvVector3D;
begin
 result.x:=aLeft.x*aRight;
 result.y:=aLeft.y*aRight;
 result.z:=aLeft.z*aRight;
end;

class operator TpvVector3D.Divide(const aLeft,aRight:TpvVector3D):TpvVector3D;
begin
 result.x:=aLeft.x/aRight.x;
 result.y:=aLeft.y/aRight.y;
 result.z:=aLeft.z/aRight.z;
end;

class operator TpvVector3D.Divide(const aLeft:TpvVector3D;const aRight:TpvDouble):TpvVector3D;
begin
 result.x:=aLeft.x/aRight;
 result.y:=aLeft.y/aRight;
 result.z:=aLeft.z/aRight;
end;

class operator TpvVector3D.Negative(const aVector:TpvVector3D):TpvVector3D;
begin
 result.x:=-aVector.x;
 result.y:=-aVector.y;
 result.z:=-aVector.z;
end;

function TpvVector3D.Cross(const aWith:TpvVector3D):TpvVector3D;
begin
 result.x:=(y*aWith.z)-(z*aWith.y);
 result.y:=(z*aWith.x)-(x*aWith.z);
 result.z:=(x*aWith.y)-(y*aWith.x);
end;

function TpvVector3D.Spacing(const aWith:TpvVector3D):TpvDouble;
begin
 result:=abs(x-aWith.x)+abs(y-aWith.y)+abs(z-aWith.z);
end;

function TpvVector3D.Dot(const aWith:TpvVector3D):TpvDouble;
begin
 result:=(x*aWith.x)+(y*aWith.y)+(z*aWith.z);
end;

function TpvVector3D.Length:TpvDouble;
begin
 result:=sqrt(sqr(x)+sqr(y)+sqr(z));
end;

function TpvVector3D.SquaredLength:TpvDouble;
begin
 result:=sqr(x)+sqr(y)+sqr(z);
end;

function TpvVector3D.Normalize:TpvVector3D;
begin
 result:=self/Length;
end;

function TpvVector3D.DistanceTo(const aWith:TpvVector3D):TpvDouble;
begin
 result:=(self-aWith).Length;
end;

function TpvVector3D.Perpendicular:TpvVector3D;
var v,p:TpvVector3D;
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

function TpvVector3D.Orthogonal:TpvVector3D;
var a,p:TpvVector3D;
begin
 a:=Normalize;
 p.x:=System.abs(a.x);
 p.y:=System.abs(a.y);
 p.z:=System.abs(a.z);
 if (p.x<=p.y) and (p.x<=p.z) then begin
  result:=TpvVector3D.Create(0.0,a.z,-a.y);
 end else if p.y<p.z then begin
  result:=TpvVector3D.Create(a.z,0.0,-a.x);
 end else begin
  result:=TpvVector3D.Create(a.y,-a.x,0.0);
 end;
end;

function TpvVector3D.Lerp(const aWith:TpvVector3D;const aTime:TpvDouble):TpvVector3D;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  result:=(self*(1.0-aTime))+(aWith*aTime);
 end;
end;

function TpvVector3D.Nlerp(const aWith:TpvVector3D;const aTime:TpvDouble):TpvVector3D;
begin
 result:=Lerp(aWith,aTime).Normalize;
end;
   
function TpvVector3D.Slerp(const aWith:TpvVector3D;const aTime:TpvDouble):TpvVector3D;
var //DotProduct,Theta,Sinus,Cosinus:TpvDouble;
    SelfLength,ToVectorLength:TpvDouble;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else if self=aWith then begin
  result:=aWith;
 end else begin
  SelfLength:=Length;
  ToVectorLength:=aWith.Length;
  if Min(abs(SelfLength),abs(ToVectorLength))<1e-7 then begin
   result:=(self*(1.0-aTime))+(aWith*aTime);
  end else begin
   result:=(TpvQuaternionD.Create(0.0,0.0,0.0,1.0).Slerp(TpvQuaternionD.CreateFromToRotation(self.Normalize,
                                                                                             aWith.Normalize),
                                                         aTime)*self.Normalize).ToVector.xyz*
           ((SelfLength*(1.0-aTime))+(ToVectorLength*aTime));
  end;
{ DotProduct:=self.Dot(aWith);
  if DotProduct<-1.0 then begin
   DotProduct:=-1.0;
  end else if DotProduct>1.0 then begin
   DotProduct:=1.0;
  end;
  Theta:=ArcCos(DotProduct)*aTime;
  SinCos(Theta,Sinus,Cosinus);
  result:=(self*Cosinus)+((aWith-(self*DotProduct)).Normalize*Sinus);}  
 end;
end;

function TpvVector3D.Sqlerp(const aB,aC,aD:TpvVector3D;const aTime:TpvDouble):TpvVector3D;
begin
 result:=Slerp(aD,aTime).Slerp(aB.Slerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

function TpvVector3D.ToVector:TpvVector3;
begin
 result.x:=x;
 result.y:=y;
 result.z:=z;
end;

{ TpvVector4D }

constructor TpvVector4D.Create(const aFrom:TpvVector4);
begin
 x:=aFrom.x;
 y:=aFrom.y;
 z:=aFrom.z;
 w:=aFrom.w;
end;

constructor TpvVector4D.Create(const aX,aY,aZ,aW:TpvDouble);
begin
 x:=aX;
 y:=aY;
 z:=aZ;
 w:=aW;
end;

class operator TpvVector4D.Implicit(const aFrom:TpvVector4):TpvVector4D;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
 result.z:=aFrom.z;
 result.w:=aFrom.w;
end;

class operator TpvVector4D.Implicit(const aFrom:TpvVector4D):TpvVector4;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
 result.z:=aFrom.z;
 result.w:=aFrom.w;
end;

class operator TpvVector4D.Explicit(const aFrom:TpvVector4):TpvVector4D;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
 result.z:=aFrom.z;
 result.w:=aFrom.w;
end;

class operator TpvVector4D.Explicit(const aFrom:TpvVector4D):TpvVector4;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
 result.z:=aFrom.z;
 result.w:=aFrom.w;
end;

class operator TpvVector4D.Equal(const aLeft,aRight:TpvVector4D):boolean;
begin
 result:=SameValue(aLeft.x,aRight.x) and
         SameValue(aLeft.y,aRight.y) and
         SameValue(aLeft.z,aRight.z) and
         SameValue(aLeft.w,aRight.w);
end;

class operator TpvVector4D.NotEqual(const aLeft,aRight:TpvVector4D):boolean;
begin
 result:=not (SameValue(aLeft.x,aRight.x) and
              SameValue(aLeft.y,aRight.y) and
              SameValue(aLeft.z,aRight.z) and
              SameValue(aLeft.w,aRight.w));
end;

class operator TpvVector4D.Add(const aLeft,aRight:TpvVector4D):TpvVector4D;
begin
 result.x:=aLeft.x+aRight.x;
 result.y:=aLeft.y+aRight.y;
 result.z:=aLeft.z+aRight.z;
 result.w:=aLeft.w+aRight.w;
end;

class operator TpvVector4D.Subtract(const aLeft,aRight:TpvVector4D):TpvVector4D;
begin
 result.x:=aLeft.x-aRight.x;
 result.y:=aLeft.y-aRight.y;
 result.z:=aLeft.z-aRight.z;
 result.w:=aLeft.w-aRight.w;
end;

class operator TpvVector4D.Multiply(const aLeft,aRight:TpvVector4D):TpvVector4D;
begin
 result.x:=aLeft.x*aRight.x;
 result.y:=aLeft.y*aRight.y;
 result.z:=aLeft.z*aRight.z;
 result.w:=aLeft.w*aRight.w;
end;

class operator TpvVector4D.Multiply(const aLeft:TpvVector4D;const aRight:TpvDouble):TpvVector4D;
begin
 result.x:=aLeft.x*aRight;
 result.y:=aLeft.y*aRight;
 result.z:=aLeft.z*aRight;
 result.w:=aLeft.w*aRight;
end;

class operator TpvVector4D.Divide(const aLeft,aRight:TpvVector4D):TpvVector4D;
begin
 result.x:=aLeft.x/aRight.x;
 result.y:=aLeft.y/aRight.y;
 result.z:=aLeft.z/aRight.z;
 result.w:=aLeft.w/aRight.w;
end;

class operator TpvVector4D.Divide(const aLeft:TpvVector4D;const aRight:TpvDouble):TpvVector4D;
begin
 result.x:=aLeft.x/aRight;
 result.y:=aLeft.y/aRight;
 result.z:=aLeft.z/aRight;
 result.w:=aLeft.w/aRight;
end;

class operator TpvVector4D.Negative(const aVector:TpvVector4D):TpvVector4D;
begin
 result.x:=-aVector.x;
 result.y:=-aVector.y;
 result.z:=-aVector.z;
 result.w:=-aVector.w;
end;

function TpvVector4D.Dot(const aWith:TpvVector4D):TpvDouble;
begin
 result:=(x*aWith.x)+(y*aWith.y)+(z*aWith.z)+(w*aWith.w);
end;

function TpvVector4D.Length:TpvDouble;
begin
 result:=sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));
end;

function TpvVector4D.SquaredLength:TpvDouble;
begin
 result:=sqr(x)+sqr(y)+sqr(z)+sqr(w);
end;

function TpvVector4D.Normalize:TpvVector4D;
var l:TpvDouble;
begin
 l:=Length;
 if l>0.0 then begin
  result:=self/l;
 end else begin
  result:=self;
 end;
end;

function TpvVector4D.Lerp(const aWith:TpvVector4D;const aTime:TpvDouble):TpvVector4D;
var InverseTime:TpvDouble;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  InverseTime:=1.0-aTime;
  result.x:=(x*InverseTime)+(aWith.x*aTime);
  result.y:=(y*InverseTime)+(aWith.y*aTime);
  result.z:=(z*InverseTime)+(aWith.z*aTime);
  result.w:=(w*InverseTime)+(aWith.w*aTime);
 end;
end;

function TpvVector4D.Nlerp(const aWith:TpvVector4D;const aTime:TpvDouble):TpvVector4D;
begin
 result:=Lerp(aWith,aTime).Normalize;
end;

function TpvVector4D.Slerp(const aWith:TpvVector4D;const aTime:TpvDouble):TpvVector4D;
var DotProduct,Theta,Sinus,Cosinus:TpvDouble;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else if self=aWith then begin
  result:=aWith;
 end else begin
  DotProduct:=Dot(aWith);
  if DotProduct<-1.0 then begin
   DotProduct:=-1.0;
  end else if DotProduct>1.0 then begin
   DotProduct:=1.0;
  end;
  Theta:=ArcCos(DotProduct)*aTime;
  SinCos(Theta,Sinus,Cosinus);
  result:=(self*Cosinus)+((aWith-(self*DotProduct)).Normalize*Sinus);
 end;
end;

function TpvVector4D.Sqlerp(const aB,aC,aD:TpvVector4D;const aTime:TpvDouble):TpvVector4D;
begin
 result:=Slerp(aD,aTime).Slerp(aB.Slerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

function TpvVector4D.ToVector:TpvVector4;
begin
 result.x:=x;
 result.y:=y;
 result.z:=z;
 result.w:=w;
end;

{ TpvQuaternionD }

constructor TpvQuaternionD.Create(const aFrom:TpvQuaternion);
begin
 x:=aFrom.x;
 y:=aFrom.y;
 z:=aFrom.z;
 w:=aFrom.w;
end;

constructor TpvQuaternionD.Create(const aX,aY,aZ,aW:TpvDouble);
begin
 x:=aX;
 y:=aY;
 z:=aZ;
 w:=aW;
end;

constructor TpvQuaternionD.Create(const aMatrix:TpvMatrix3x3);
var t,s:TpvDouble;
begin
 t:=aMatrix.RawComponents[0,0]+(aMatrix.RawComponents[1,1]+aMatrix.RawComponents[2,2]);
 if t>2.9999999 then begin
  x:=0.0;
  y:=0.0;
  z:=0.0;
  w:=1.0;
 end else if t>0.0000001 then begin
  s:=sqrt(1.0+t)*2.0;
  x:=(aMatrix.RawComponents[1,2]-aMatrix.RawComponents[2,1])/s;
  y:=(aMatrix.RawComponents[2,0]-aMatrix.RawComponents[0,2])/s;
  z:=(aMatrix.RawComponents[0,1]-aMatrix.RawComponents[1,0])/s;
  w:=s*0.25;
 end else if (aMatrix.RawComponents[0,0]>aMatrix.RawComponents[1,1]) and (aMatrix.RawComponents[0,0]>aMatrix.RawComponents[2,2]) then begin
  s:=sqrt(1.0+(aMatrix.RawComponents[0,0]-(aMatrix.RawComponents[1,1]+aMatrix.RawComponents[2,2])))*2.0;
  x:=s*0.25;
  y:=(aMatrix.RawComponents[1,0]+aMatrix.RawComponents[0,1])/s;
  z:=(aMatrix.RawComponents[2,0]+aMatrix.RawComponents[0,2])/s;
  w:=(aMatrix.RawComponents[1,2]-aMatrix.RawComponents[2,1])/s;
 end else if aMatrix.RawComponents[1,1]>aMatrix.RawComponents[2,2] then begin
  s:=sqrt(1.0+(aMatrix.RawComponents[1,1]-(aMatrix.RawComponents[0,0]+aMatrix.RawComponents[2,2])))*2.0;
  x:=(aMatrix.RawComponents[1,0]+aMatrix.RawComponents[0,1])/s;
  y:=s*0.25;
  z:=(aMatrix.RawComponents[2,1]+aMatrix.RawComponents[1,2])/s;
  w:=(aMatrix.RawComponents[2,0]-aMatrix.RawComponents[0,2])/s;
 end else begin
  s:=sqrt(1.0+(aMatrix.RawComponents[2,2]-(aMatrix.RawComponents[0,0]+aMatrix.RawComponents[1,1])))*2.0;
  x:=(aMatrix.RawComponents[2,0]+aMatrix.RawComponents[0,2])/s;
  y:=(aMatrix.RawComponents[2,1]+aMatrix.RawComponents[1,2])/s;
  z:=s*0.25;
  w:=(aMatrix.RawComponents[0,1]-aMatrix.RawComponents[1,0])/s;
 end;
 t:=sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));
 if t>0.0 then begin
  x:=x/t;
  y:=y/t;
  z:=z/t;
  w:=w/t;
 end;
end;

constructor TpvQuaternionD.Create(const aMatrix:TpvMatrix4x4);
var t,s:TpvDouble;
begin
 t:=aMatrix.RawComponents[0,0]+(aMatrix.RawComponents[1,1]+aMatrix.RawComponents[2,2]);
 if t>2.9999999 then begin
  x:=0.0;
  y:=0.0;
  z:=0.0;
  w:=1.0;
 end else if t>0.0000001 then begin
  s:=sqrt(1.0+t)*2.0;
  x:=(aMatrix.RawComponents[1,2]-aMatrix.RawComponents[2,1])/s;
  y:=(aMatrix.RawComponents[2,0]-aMatrix.RawComponents[0,2])/s;
  z:=(aMatrix.RawComponents[0,1]-aMatrix.RawComponents[1,0])/s;
  w:=s*0.25;
 end else if (aMatrix.RawComponents[0,0]>aMatrix.RawComponents[1,1]) and (aMatrix.RawComponents[0,0]>aMatrix.RawComponents[2,2]) then begin
  s:=sqrt(1.0+(aMatrix.RawComponents[0,0]-(aMatrix.RawComponents[1,1]+aMatrix.RawComponents[2,2])))*2.0;
  x:=s*0.25;
  y:=(aMatrix.RawComponents[1,0]+aMatrix.RawComponents[0,1])/s;
  z:=(aMatrix.RawComponents[2,0]+aMatrix.RawComponents[0,2])/s;
  w:=(aMatrix.RawComponents[1,2]-aMatrix.RawComponents[2,1])/s;
 end else if aMatrix.RawComponents[1,1]>aMatrix.RawComponents[2,2] then begin
  s:=sqrt(1.0+(aMatrix.RawComponents[1,1]-(aMatrix.RawComponents[0,0]+aMatrix.RawComponents[2,2])))*2.0;
  x:=(aMatrix.RawComponents[1,0]+aMatrix.RawComponents[0,1])/s;
  y:=s*0.25;
  z:=(aMatrix.RawComponents[2,1]+aMatrix.RawComponents[1,2])/s;
  w:=(aMatrix.RawComponents[2,0]-aMatrix.RawComponents[0,2])/s;
 end else begin
  s:=sqrt(1.0+(aMatrix.RawComponents[2,2]-(aMatrix.RawComponents[0,0]+aMatrix.RawComponents[1,1])))*2.0;
  x:=(aMatrix.RawComponents[2,0]+aMatrix.RawComponents[0,2])/s;
  y:=(aMatrix.RawComponents[2,1]+aMatrix.RawComponents[1,2])/s;
  z:=s*0.25;
  w:=(aMatrix.RawComponents[0,1]-aMatrix.RawComponents[1,0])/s;
 end;
 t:=sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));
 if t>0.0 then begin
  x:=x/t;
  y:=y/t;
  z:=z/t;
  w:=w/t;
 end;
end;

constructor TpvQuaternionD.CreateFromAxisAngle(const aAxis:TpvVector3D;const aAngle:TpvDouble);
var sa2,l:TpvDouble;    
begin
 SinCos(aAngle*0.5,sa2,w);
 x:=aAxis.x*sa2;
 y:=aAxis.y*sa2;
 z:=aAxis.z*sa2;
 l:=sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));
 if l>0.0 then begin
  x:=x/l;
  y:=y/l;
  z:=z/l;
  w:=w/l;
 end;
end;

constructor TpvQuaternionD.CreateFromToRotation(const aFromDirection,aToDirection:TpvVector3D);
var FromDirection,ToDirection,t:TpvVector3D;
    DotProduct,Len:TpvDouble;
begin
 FromDirection:=aFromDirection.Normalize;
 ToDirection:=aToDirection.Normalize;
 DotProduct:=FromDirection.Dot(ToDirection);
 if abs(DotProduct)>=1.0 then begin
  if DotProduct>0.0 then begin
   x:=0.0;
   y:=0.0;
   z:=0.0;
   w:=1.0;
  end else begin
   self:=TpvQuaternionD.CreateFromAxisAngle(FromDirection.Perpendicular,PI);
  end;
 end else begin
  t:=FromDirection.Cross(ToDirection);
  x:=t.x;
  y:=t.y;
  z:=t.z;
  w:=DotProduct+sqrt(FromDirection.SquaredLength*ToDirection.SquaredLength);
  Len:=sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));
  if Len>0.0 then begin
   x:=x/Len;
   y:=y/Len;
   z:=z/Len;
   w:=w/Len;
  end;
 end;
end;

class operator TpvQuaternionD.Implicit(const aFrom:TpvQuaternion):TpvQuaternionD;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
 result.z:=aFrom.z;
 result.w:=aFrom.w;
end;

class operator TpvQuaternionD.Implicit(const aFrom:TpvQuaternionD):TpvQuaternion;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
 result.z:=aFrom.z;
 result.w:=aFrom.w;
end;

class operator TpvQuaternionD.Explicit(const aFrom:TpvQuaternion):TpvQuaternionD;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
 result.z:=aFrom.z;
 result.w:=aFrom.w;
end;

class operator TpvQuaternionD.Explicit(const aFrom:TpvQuaternionD):TpvQuaternion;
begin
 result.x:=aFrom.x;
 result.y:=aFrom.y;
 result.z:=aFrom.z;
 result.w:=aFrom.w;
end;

class operator TpvQuaternionD.Equal(const aLeft,aRight:TpvQuaternionD):boolean;
begin
 result:=SameValue(aLeft.x,aRight.x) and
         SameValue(aLeft.y,aRight.y) and
         SameValue(aLeft.z,aRight.z) and
         SameValue(aLeft.w,aRight.w);
end;

class operator TpvQuaternionD.NotEqual(const aLeft,aRight:TpvQuaternionD):boolean;
begin
 result:=not (SameValue(aLeft.x,aRight.x) and
              SameValue(aLeft.y,aRight.y) and
              SameValue(aLeft.z,aRight.z) and
              SameValue(aLeft.w,aRight.w));
end;

class operator TpvQuaternionD.Add(const aLeft,aRight:TpvQuaternionD):TpvQuaternionD;
begin
 result.x:=aLeft.x+aRight.x;
 result.y:=aLeft.y+aRight.y;
 result.z:=aLeft.z+aRight.z;
 result.w:=aLeft.w+aRight.w;
end;

class operator TpvQuaternionD.Subtract(const aLeft,aRight:TpvQuaternionD):TpvQuaternionD;
begin
 result.x:=aLeft.x-aRight.x;
 result.y:=aLeft.y-aRight.y;
 result.z:=aLeft.z-aRight.z;
 result.w:=aLeft.w-aRight.w;
end;

class operator TpvQuaternionD.Multiply(const aLeft,aRight:TpvQuaternionD):TpvQuaternionD;
begin
 result.x:=(((aLeft.w*aRight.x)+(aLeft.x*aRight.w))+(aLeft.y*aRight.z))-(aLeft.z*aRight.y);
 result.y:=(((aLeft.w*aRight.y)-(aLeft.x*aRight.z))+(aLeft.y*aRight.w))+(aLeft.z*aRight.x);
 result.z:=(((aLeft.w*aRight.z)+(aLeft.x*aRight.y))-(aLeft.y*aRight.x))+(aLeft.z*aRight.w);
 result.w:=(((aLeft.w*aRight.w)-(aLeft.x*aRight.x))-(aLeft.y*aRight.y))-(aLeft.z*aRight.z);
end;

class operator TpvQuaternionD.Multiply(const aLeft:TpvQuaternionD;const aRight:TpvDouble):TpvQuaternionD;
begin
 result.x:=aLeft.x*aRight;
 result.y:=aLeft.y*aRight;
 result.z:=aLeft.z*aRight;
 result.w:=aLeft.w*aRight;
end;

class operator TpvQuaternionD.Multiply(const aLeft:TpvDouble;const aRight:TpvQuaternionD):TpvQuaternionD;
begin
 result.x:=aLeft*aRight.x;
 result.y:=aLeft*aRight.y;
 result.z:=aLeft*aRight.z;
 result.w:=aLeft*aRight.w;
end;

class operator TpvQuaternionD.Multiply(const aLeft:TpvQuaternionD;const aRight:TpvVector3D):TpvVector3D;
var t,qv:TpvVector3D;
begin
 qv:=TpvVector3D.Create(aLeft.x,aLeft.y,aLeft.z);
 t:=qv.Cross(aRight)*2.0;
 result:=(aRight+(t*aLeft.w))+qv.Cross(t);
end;

class operator TpvQuaternionD.Multiply(const aLeft:TpvVector3D;const aRight:TpvQuaternionD):TpvVector3D;
var qt:TpvQuaternionD;
    t,qv:TpvVector3D;
begin
 qt:=aRight.Inverse;
 qv:=TpvVector3D.Create(qt.x,qt.y,qt.z);
 t:=qv.Cross(aLeft)*2.0;
 result:=(aLeft+(t*qt.w))+qv.Cross(t);
end;

class operator TpvQuaternionD.Divide(const aLeft,aRight:TpvQuaternionD):TpvQuaternionD;
begin
 result:=aLeft*aRight.Inverse;
end;

class operator TpvQuaternionD.Negative(const aQuaternion:TpvQuaternionD):TpvQuaternionD;
begin
 result.x:=-aQuaternion.x;
 result.y:=-aQuaternion.y;
 result.z:=-aQuaternion.z;
 result.w:=-aQuaternion.w;
end;

function TpvQuaternionD.Dot(const aWith:TpvQuaternionD):TpvDouble;
begin
 result:=(x*aWith.x)+(y*aWith.y)+(z*aWith.z)+(w*aWith.w);
end;

function TpvQuaternionD.Length:TpvDouble;
begin
 result:=sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));
end;

function TpvQuaternionD.SquaredLength:TpvDouble;
begin
 result:=sqr(x)+sqr(y)+sqr(z)+sqr(w);
end;

function TpvQuaternionD.Normalize:TpvQuaternionD;
var InverseLength:TpvDouble;
begin
 InverseLength:=1.0/Length;
 result.x:=x*InverseLength;
 result.y:=y*InverseLength;
 result.z:=z*InverseLength;
 result.w:=w*InverseLength;
end;

function TpvQuaternionD.Conjugate:TpvQuaternionD;
begin
 result.x:=-x;
 result.y:=-y;
 result.z:=-z;
 result.w:=w;
end;

function TpvQuaternionD.Inverse:TpvQuaternionD;
var InverseLength:TpvDouble;
begin
 InverseLength:=1.0/sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));
 result.x:=-x*InverseLength;
 result.y:=-y*InverseLength;
 result.z:=-z*InverseLength;
 result.w:=w*InverseLength;
end;

function TpvQuaternionD.Exp:TpvQuaternionD;
var Angle,Sinus,Coefficent:TpvDouble;
begin
 Angle:=sqrt(sqr(x)+sqr(y)+sqr(z));
 SinCos(Angle,Sinus,Coefficent);
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

function TpvQuaternionD.Log:TpvQuaternionD;
var Theta,SinTheta,Coefficent:TpvDouble;
begin
 result.x:=x;
 result.y:=y;
 result.z:=z;
 result.w:=0.0;
 if System.Abs(w)<1.0 then begin
  Theta:=ArcCos(w);
  SinCos(Theta,SinTheta,Coefficent);
  if System.Abs(SinTheta)>1e-6 then begin
   Coefficent:=Theta/SinTheta;
   result.x:=result.x*Coefficent;
   result.y:=result.y*Coefficent;
   result.z:=result.z*Coefficent;
  end;
 end;
end;

function TpvQuaternionD.Lerp(const aWith:TpvQuaternionD;const aTime:TpvDouble):TpvQuaternionD;
var InverseTime:TpvDouble;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  InverseTime:=1.0-aTime;
  result.x:=(x*InverseTime)+(aWith.x*aTime);
  result.y:=(y*InverseTime)+(aWith.y*aTime);
  result.z:=(z*InverseTime)+(aWith.z*aTime);
  result.w:=(w*InverseTime)+(aWith.w*aTime);
 end;
end;

function TpvQuaternionD.Nlerp(const aWith:TpvQuaternionD;const aTime:TpvDouble):TpvQuaternionD;
begin
 result:=Lerp(aWith,aTime).Normalize;
end;

function TpvQuaternionD.Slerp(const aWith:TpvQuaternionD;const aTime:TpvDouble):TpvQuaternionD;
var Omega,co,so,s0,s1,s2:TpvDouble;
begin
 co:=(x*aWith.x)+(y*aWith.y)+(z*aWith.z)+(w*aWith.w);
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
 result:=(s0*self)+(aWith*(s1*s2));
end;

function TpvQuaternionD.ApproximatedSlerp(const aWith:TpvQuaternionD;const aTime:TpvDouble):TpvQuaternionD;
var ca,d,a,b,k,o:TpvDouble;
begin
 ca:=(x*aWith.x)+(y*aWith.y)+(z*aWith.z)+(w*aWith.w);
 d:=abs(ca);
 a:=1.0904+(d*(-3.2452+(d*(3.55645-(d*1.43519)))));
 b:=0.848013+(d*(-1.06021+(d*0.215638)));
 k:=(a*sqr(aTime-0.5))+b;
 o:=aTime+(((aTime*(aTime-0.5))*(aTime-1.0))*k);
 if ca<0.0 then begin
  result:=Nlerp(-aWith,o);
 end else begin
  result:=Nlerp(aWith,o);
 end;
end;

function TpvQuaternionD.Elerp(const aWith:TpvQuaternionD;const aTime:TpvDouble):TpvQuaternionD;
var SignFactor:TpvDouble;
begin
 if Dot(aWith)<0.0 then begin
  SignFactor:=-1.0;
 end else begin
  SignFactor:=1.0;
 end;
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith*SignFactor;
 end else begin
  result:=((Log*(1.0-aTime))+((aWith*SignFactor).Log*aTime)).Exp;
 end;
end;

function TpvQuaternionD.Sqlerp(const aB,aC,aD:TpvQuaternionD;const aTime:TpvDouble):TpvQuaternionD;
begin
 result:=Slerp(aD,aTime).Slerp(aB.Slerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

function TpvQuaternionD.ToMatrix3x3:TpvMatrix3x3;
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:TpvDouble;
    Quaternion:TpvQuaternionD;
begin 
 Quaternion:=self.Normalize;
 qx2:=Quaternion.x+Quaternion.x;
 qy2:=Quaternion.y+Quaternion.y;
 qz2:=Quaternion.z+Quaternion.z;
 qxqx2:=Quaternion.x*qx2;
 qxqy2:=Quaternion.x*qy2;
 qxqz2:=Quaternion.x*qz2;
 qxqw2:=Quaternion.w*qx2;
 qyqy2:=Quaternion.y*qy2;
 qyqz2:=Quaternion.y*qz2;
 qyqw2:=Quaternion.w*qy2;
 qzqz2:=Quaternion.z*qz2;
 qzqw2:=Quaternion.w*qz2;
 result.RawComponents[0,0]:=1.0-(qyqy2+qzqz2);
 result.RawComponents[0,1]:=qxqy2+qzqw2;
 result.RawComponents[0,2]:=qxqz2-qyqw2;
 result.RawComponents[1,0]:=qxqy2-qzqw2;
 result.RawComponents[1,1]:=1.0-(qxqx2+qzqz2);
 result.RawComponents[1,2]:=qyqz2+qxqw2;
 result.RawComponents[2,0]:=qxqz2+qyqw2;
 result.RawComponents[2,1]:=qyqz2-qxqw2;
 result.RawComponents[2,2]:=1.0-(qxqx2+qyqy2);
end;

function TpvQuaternionD.ToMatrix4x4:TpvMatrix4x4;
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:TpvDouble;
    Quaternion:TpvQuaternionD;
begin
 Quaternion:=self.Normalize;
 qx2:=Quaternion.x+Quaternion.x;
 qy2:=Quaternion.y+Quaternion.y;
 qz2:=Quaternion.z+Quaternion.z;
 qxqx2:=Quaternion.x*qx2;
 qxqy2:=Quaternion.x*qy2;
 qxqz2:=Quaternion.x*qz2;
 qxqw2:=Quaternion.w*qx2;
 qyqy2:=Quaternion.y*qy2;
 qyqz2:=Quaternion.y*qz2;
 qyqw2:=Quaternion.w*qy2;
 qzqz2:=Quaternion.z*qz2;
 qzqw2:=Quaternion.w*qz2;
 result.RawComponents[0,0]:=1.0-(qyqy2+qzqz2);
 result.RawComponents[0,1]:=qxqy2+qzqw2;
 result.RawComponents[0,2]:=qxqz2-qyqw2;
 result.RawComponents[0,3]:=0.0;
 result.RawComponents[1,0]:=qxqy2-qzqw2;
 result.RawComponents[1,1]:=1.0-(qxqx2+qzqz2);
 result.RawComponents[1,2]:=qyqz2+qxqw2;
 result.RawComponents[1,3]:=0.0;
 result.RawComponents[2,0]:=qxqz2+qyqw2;
 result.RawComponents[2,1]:=qyqz2-qxqw2;
 result.RawComponents[2,2]:=1.0-(qxqx2+qyqy2);
 result.RawComponents[2,3]:=0.0;
 result.RawComponents[3,0]:=0.0;
 result.RawComponents[3,1]:=0.0;
 result.RawComponents[3,2]:=0.0;
 result.RawComponents[3,3]:=1.0;
end;

function TpvQuaternionD.ToVector:TpvVector4;
begin
 result.x:=x;
 result.y:=y;
 result.z:=z;
 result.w:=w;
end;

function TpvQuaternionD.ToQuaternion:TpvQuaternion;
begin
 result.x:=x;
 result.y:=y;
 result.z:=z;
 result.w:=w;
end;

function TpvQuaternionD.ToEuler:TpvVector3D;
var t:TpvDouble;
begin
 // Order of rotations: Roll (Z), Pitch (X), Yaw (Y)
 t:=2.0*((x*w)-(y*z));
 if t<-0.995 then begin
  result.x:=-HalfPI;
  result.y:=0.0;
  result.z:=-ArcTan2(2.0*((x*z)-(y*w)),1.0-(2.0*(sqr(y)+sqr(z))));
 end else if t>0.995 then begin
  result.x:=HalfPI;
  result.y:=0.0;
  result.z:=ArcTan2(2.0*((x*z)-(y*w)),1.0-(2.0*(sqr(y)+sqr(z))));
 end else begin
  result.x:=ArcSin(t);
  result.y:=ArcTan2(2.0*((x*z)+(y*w)),1.0-(2.0*(sqr(x)+sqr(y))));
  result.z:=ArcTan2(2.0*((x*y)+(z*w)),1.0-(2.0*(sqr(x)+sqr(z))));
 end;
end;

function TpvQuaternionD.ToPitch:TpvDouble;
var t:TpvDouble;
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

function TpvQuaternionD.ToYaw:TpvDouble;
var t:TpvDouble;
begin
 // Order of rotations: Roll (Z), Pitch (X), Yaw (Y)
 t:=2.0*((x*w)-(y*z));
 if System.abs(t)>0.995 then begin
  result:=0.0;
 end else begin
  result:=ArcTan2(2.0*((x*z)+(y*w)),1.0-(2.0*(sqr(x)+sqr(y))));
 end;
end;

function TpvQuaternionD.ToRoll:TpvDouble;
var t:TpvDouble;
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

class function TpvDecomposedMatrix3x3D.Create:TpvDecomposedMatrix3x3D;
begin
 result.Scale:=TpvVector3D.Create(1.0,1.0,1.0);
 result.Skew:=TpvVector3D.Create(0.0,0.0,0.0);
 result.Rotation:=TpvQuaternionD.Create(0.0,0.0,0.0,1.0);
 result.Valid:=true;
end;

function TpvDecomposedMatrix3x3D.Lerp(const aWith:TpvDecomposedMatrix3x3D;const aTime:TpvDouble):TpvDecomposedMatrix3x3D;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  result.Scale:=Scale.Lerp(aWith.Scale,aTime);
  result.Skew:=Skew.Lerp(aWith.Skew,aTime);
  result.Rotation:=Rotation.Lerp(aWith.Rotation,aTime);
 end;
end;

function TpvDecomposedMatrix3x3D.Nlerp(const aWith:TpvDecomposedMatrix3x3D;const aTime:TpvDouble):TpvDecomposedMatrix3x3D;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  result.Scale:=Scale.Lerp(aWith.Scale,aTime);
  result.Skew:=Skew.Lerp(aWith.Skew,aTime);
  result.Rotation:=Rotation.Nlerp(aWith.Rotation,aTime);
 end;
end;

function TpvDecomposedMatrix3x3D.Slerp(const aWith:TpvDecomposedMatrix3x3D;const aTime:TpvDouble):TpvDecomposedMatrix3x3D;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  result.Scale:=Scale.Lerp(aWith.Scale,aTime);
  result.Skew:=Skew.Lerp(aWith.Skew,aTime);
  result.Rotation:=Rotation.Slerp(aWith.Rotation,aTime);
 end;
end;

function TpvDecomposedMatrix3x3D.Elerp(const aWith:TpvDecomposedMatrix3x3D;const aTime:TpvDouble):TpvDecomposedMatrix3x3D;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  result.Scale:=Scale.Lerp(aWith.Scale,aTime);
  result.Skew:=Skew.Lerp(aWith.Skew,aTime);
  result.Rotation:=Rotation.Elerp(aWith.Rotation,aTime);
 end;
end;

function TpvDecomposedMatrix3x3D.Sqlerp(const aB,aC,aD:TpvDecomposedMatrix3x3D;const aTime:TpvDouble):TpvDecomposedMatrix3x3D;
begin
 result:=Slerp(aD,aTime).Slerp(aB.Slerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

constructor TpvMatrix3x3D.Create(const aXX,aXY,aXZ,aYX,aYY,aYZ,aZX,aZY,aZZ:TpvDouble);
begin
 RawComponents[0,0]:=aXX;
 RawComponents[0,1]:=aXY;
 RawComponents[0,2]:=aXZ;
 RawComponents[1,0]:=aYX;
 RawComponents[1,1]:=aYY;
 RawComponents[1,2]:=aYZ;
 RawComponents[2,0]:=aZX;
 RawComponents[2,1]:=aZY;
 RawComponents[2,2]:=aZZ;
end;

constructor TpvMatrix3x3D.Create(const aTangent,aBitangent,aNormal:TpvVector3D);
begin
 Tangent:=aTangent;
 Bitangent:=aBitangent;
 Normal:=aNormal;
end;

constructor TpvMatrix3x3D.Create(const aFrom:TpvMatrix3x3);
begin
 RawComponents[0,0]:=aFrom.RawComponents[0,0];
 RawComponents[0,1]:=aFrom.RawComponents[0,1];
 RawComponents[0,2]:=aFrom.RawComponents[0,2];
 RawComponents[1,0]:=aFrom.RawComponents[1,0];
 RawComponents[1,1]:=aFrom.RawComponents[1,1];
 RawComponents[1,2]:=aFrom.RawComponents[1,2];
 RawComponents[2,0]:=aFrom.RawComponents[2,0];
 RawComponents[2,1]:=aFrom.RawComponents[2,1];
 RawComponents[2,2]:=aFrom.RawComponents[2,2];
end;

constructor TpvMatrix3x3D.Create(const aFrom:TpvMatrix4x4);
begin
 RawComponents[0,0]:=aFrom.RawComponents[0,0];
 RawComponents[0,1]:=aFrom.RawComponents[0,1];
 RawComponents[0,2]:=aFrom.RawComponents[0,2];
 RawComponents[1,0]:=aFrom.RawComponents[1,0];
 RawComponents[1,1]:=aFrom.RawComponents[1,1];
 RawComponents[1,2]:=aFrom.RawComponents[1,2];
 RawComponents[2,0]:=aFrom.RawComponents[2,0];
 RawComponents[2,1]:=aFrom.RawComponents[2,1];
 RawComponents[2,2]:=aFrom.RawComponents[2,2];
end;

constructor TpvMatrix3x3D.Create(const aFrom:TpvQuaternion);
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:TpvDouble;
    From:TpvQuaternion;
begin
 From:=aFrom.Normalize;
 qx2:=From.x+From.x;
 qy2:=From.y+From.y;
 qz2:=From.z+From.z;
 qxqx2:=From.x*qx2;
 qxqy2:=From.x*qy2;
 qxqz2:=From.x*qz2;
 qxqw2:=From.w*qx2;
 qyqy2:=From.y*qy2;
 qyqz2:=From.y*qz2;
 qyqw2:=From.w*qy2;
 qzqz2:=From.z*qz2;
 qzqw2:=From.w*qz2;
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

constructor TpvMatrix3x3D.Create(const aFrom:TpvQuaternionD);
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:TpvDouble;
    From:TpvQuaternionD;
begin
 From:=aFrom.Normalize;
 qx2:=From.x+From.x;
 qy2:=From.y+From.y;
 qz2:=From.z+From.z;
 qxqx2:=From.x*qx2;
 qxqy2:=From.x*qy2;
 qxqz2:=From.x*qz2;
 qxqw2:=From.w*qx2;
 qyqy2:=From.y*qy2;
 qyqz2:=From.y*qz2;
 qyqw2:=From.w*qy2;
 qzqz2:=From.z*qz2;
 qzqw2:=From.w*qz2;
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

constructor TpvMatrix3x3D.Create(const aFrom:TpvDecomposedMatrix3x3D);
begin
 self:=TpvMatrix3x3D.Create(aFrom.Rotation);
 if aFrom.Skew.z<>0.0 then begin // YZ
  self:=TpvMatrix3x3D.Create(1.0,0.0,0.0,
                             0.0,1.0,0.0,
                             0.0,aFrom.Skew.z,1.0)*self;
 end;
 if aFrom.Skew.y<>0.0 then begin // XZ
  self:=TpvMatrix3x3D.Create(1.0,0.0,0.0,
                             0.0,1.0,0.0,
                             aFrom.Skew.y,0.0,1.0)*self;
 end;
 if aFrom.Skew.x<>0.0 then begin // XY
  self:=TpvMatrix3x3D.Create(1.0,0.0,0.0,
                             aFrom.Skew.x,1.0,0.0,
                             0.0,0.0,1.0)*self;
 end;
 self:=TpvMatrix3x3D.Create(aFrom.Scale.x,0.0,0.0,
                            0.0,aFrom.Scale.y,0.0,
                            0.0,0.0,aFrom.Scale.z)*self;
end;

class operator TpvMatrix3x3D.Implicit(const aFrom:TpvMatrix3x3):TpvMatrix3x3D;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
end;

class operator TpvMatrix3x3D.Implicit(const aFrom:TpvMatrix3x3D):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
end;

class operator TpvMatrix3x3D.Implicit(const aFrom:TpvMatrix4x4):TpvMatrix3x3D;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
end;

class operator TpvMatrix3x3D.Implicit(const aFrom:TpvMatrix3x3D):TpvMatrix4x4;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[0,3]:=0.0;
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[1,3]:=0.0;
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
 result.RawComponents[2,3]:=0.0;
 result.RawComponents[3,0]:=0.0;
 result.RawComponents[3,1]:=0.0;
 result.RawComponents[3,2]:=0.0;
 result.RawComponents[3,3]:=1.0;
end;

class operator TpvMatrix3x3D.Implicit(const aFrom:TpvQuaternion):TpvMatrix3x3D;
begin
 result:=TpvMatrix3x3D.Create(aFrom);
end;

class operator TpvMatrix3x3D.Implicit(const aFrom:TpvQuaternionD):TpvMatrix3x3D;
begin
 result:=TpvMatrix3x3D.Create(aFrom);
end;

class operator TpvMatrix3x3D.Implicit(const aFrom:TpvDecomposedMatrix3x3D):TpvMatrix3x3D;
begin
 result:=TpvMatrix3x3D.Create(aFrom);
end;

class operator TpvMatrix3x3D.Implicit(const aFrom:TpvMatrix3x3D):TpvQuaternion;
begin
 result:=aFrom.ToQuaternionD.ToQuaternion;
end;

class operator TpvMatrix3x3D.Implicit(const aFrom:TpvMatrix3x3D):TpvQuaternionD;
begin
 result:=aFrom.ToQuaternionD;
end;

class operator TpvMatrix3x3D.Implicit(const aFrom:TpvMatrix3x3D):TpvDecomposedMatrix3x3D;
begin
 result:=aFrom.Decompose;
end;

class operator TpvMatrix3x3D.Explicit(const aFrom:TpvMatrix3x3):TpvMatrix3x3D;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
end;

class operator TpvMatrix3x3D.Explicit(const aFrom:TpvMatrix3x3D):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
end;

class operator TpvMatrix3x3D.Explicit(const aFrom:TpvMatrix4x4):TpvMatrix3x3D;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
end;

class operator TpvMatrix3x3D.Explicit(const aFrom:TpvMatrix3x3D):TpvMatrix4x4;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[0,3]:=0.0;
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[1,3]:=0.0;
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
 result.RawComponents[2,3]:=0.0;
 result.RawComponents[3,0]:=0.0;
 result.RawComponents[3,1]:=0.0;
 result.RawComponents[3,2]:=0.0;
 result.RawComponents[3,3]:=1.0;
end;

class operator TpvMatrix3x3D.Explicit(const aFrom:TpvQuaternion):TpvMatrix3x3D;
begin
 result:=TpvMatrix3x3D.Create(aFrom);
end;

class operator TpvMatrix3x3D.Explicit(const aFrom:TpvQuaternionD):TpvMatrix3x3D;
begin
 result:=TpvMatrix3x3D.Create(aFrom);
end;

class operator TpvMatrix3x3D.Explicit(const aFrom:TpvDecomposedMatrix3x3D):TpvMatrix3x3D;
begin
 result:=TpvMatrix3x3D.Create(aFrom);
end;

class operator TpvMatrix3x3D.Explicit(const aFrom:TpvMatrix3x3D):TpvQuaternion;
begin
 result:=aFrom.ToQuaternionD.ToQuaternion;
end;

class operator TpvMatrix3x3D.Explicit(const aFrom:TpvMatrix3x3D):TpvQuaternionD;
begin
 result:=aFrom.ToQuaternionD;
end;

class operator TpvMatrix3x3D.Explicit(const aFrom:TpvMatrix3x3D):TpvDecomposedMatrix3x3D;
begin
 result:=aFrom.Decompose;
end;

class operator TpvMatrix3x3D.Equal(const aLeft,aRight:TpvMatrix3x3D):boolean;
begin
 result:=(aLeft.RawComponents[0,0]=aRight.RawComponents[0,0]) and
         (aLeft.RawComponents[0,1]=aRight.RawComponents[0,1]) and
         (aLeft.RawComponents[0,2]=aRight.RawComponents[0,2]) and
         (aLeft.RawComponents[1,0]=aRight.RawComponents[1,0]) and
         (aLeft.RawComponents[1,1]=aRight.RawComponents[1,1]) and
         (aLeft.RawComponents[1,2]=aRight.RawComponents[1,2]) and
         (aLeft.RawComponents[2,0]=aRight.RawComponents[2,0]) and
         (aLeft.RawComponents[2,1]=aRight.RawComponents[2,1]) and
         (aLeft.RawComponents[2,2]=aRight.RawComponents[2,2]);
end;

class operator TpvMatrix3x3D.NotEqual(const aLeft,aRight:TpvMatrix3x3D):boolean;
begin
 result:=(aLeft.RawComponents[0,0]<>aRight.RawComponents[0,0]) or
         (aLeft.RawComponents[0,1]<>aRight.RawComponents[0,1]) or
         (aLeft.RawComponents[0,2]<>aRight.RawComponents[0,2]) or
         (aLeft.RawComponents[1,0]<>aRight.RawComponents[1,0]) or
         (aLeft.RawComponents[1,1]<>aRight.RawComponents[1,1]) or
         (aLeft.RawComponents[1,2]<>aRight.RawComponents[1,2]) or
         (aLeft.RawComponents[2,0]<>aRight.RawComponents[2,0]) or
         (aLeft.RawComponents[2,1]<>aRight.RawComponents[2,1]) or
         (aLeft.RawComponents[2,2]<>aRight.RawComponents[2,2]);
end;

class operator TpvMatrix3x3D.Add(const aLeft,aRight:TpvMatrix3x3D):TpvMatrix3x3D;
begin
 result.RawComponents[0,0]:=aLeft.RawComponents[0,0]+aRight.RawComponents[0,0];
 result.RawComponents[0,1]:=aLeft.RawComponents[0,1]+aRight.RawComponents[0,1];
 result.RawComponents[0,2]:=aLeft.RawComponents[0,2]+aRight.RawComponents[0,2];
 result.RawComponents[1,0]:=aLeft.RawComponents[1,0]+aRight.RawComponents[1,0];
 result.RawComponents[1,1]:=aLeft.RawComponents[1,1]+aRight.RawComponents[1,1];
 result.RawComponents[1,2]:=aLeft.RawComponents[1,2]+aRight.RawComponents[1,2];
 result.RawComponents[2,0]:=aLeft.RawComponents[2,0]+aRight.RawComponents[2,0];
 result.RawComponents[2,1]:=aLeft.RawComponents[2,1]+aRight.RawComponents[2,1];
 result.RawComponents[2,2]:=aLeft.RawComponents[2,2]+aRight.RawComponents[2,2];
end;

class operator TpvMatrix3x3D.Subtract(const aLeft,aRight:TpvMatrix3x3D):TpvMatrix3x3D;
begin
 result.RawComponents[0,0]:=aLeft.RawComponents[0,0]-aRight.RawComponents[0,0];
 result.RawComponents[0,1]:=aLeft.RawComponents[0,1]-aRight.RawComponents[0,1];
 result.RawComponents[0,2]:=aLeft.RawComponents[0,2]-aRight.RawComponents[0,2];
 result.RawComponents[1,0]:=aLeft.RawComponents[1,0]-aRight.RawComponents[1,0];
 result.RawComponents[1,1]:=aLeft.RawComponents[1,1]-aRight.RawComponents[1,1];
 result.RawComponents[1,2]:=aLeft.RawComponents[1,2]-aRight.RawComponents[1,2];
 result.RawComponents[2,0]:=aLeft.RawComponents[2,0]-aRight.RawComponents[2,0];
 result.RawComponents[2,1]:=aLeft.RawComponents[2,1]-aRight.RawComponents[2,1];
 result.RawComponents[2,2]:=aLeft.RawComponents[2,2]-aRight.RawComponents[2,2];
end;

class operator TpvMatrix3x3D.Multiply(const aLeft,aRight:TpvMatrix3x3D):TpvMatrix3x3D;
begin
 result.RawComponents[0,0]:=(aLeft.RawComponents[0,0]*aRight.RawComponents[0,0])+(aLeft.RawComponents[0,1]*aRight.RawComponents[1,0])+(aLeft.RawComponents[0,2]*aRight.RawComponents[2,0]);
 result.RawComponents[0,1]:=(aLeft.RawComponents[0,0]*aRight.RawComponents[0,1])+(aLeft.RawComponents[0,1]*aRight.RawComponents[1,1])+(aLeft.RawComponents[0,2]*aRight.RawComponents[2,1]);
 result.RawComponents[0,2]:=(aLeft.RawComponents[0,0]*aRight.RawComponents[0,2])+(aLeft.RawComponents[0,1]*aRight.RawComponents[1,2])+(aLeft.RawComponents[0,2]*aRight.RawComponents[2,2]);
 result.RawComponents[1,0]:=(aLeft.RawComponents[1,0]*aRight.RawComponents[0,0])+(aLeft.RawComponents[1,1]*aRight.RawComponents[1,0])+(aLeft.RawComponents[1,2]*aRight.RawComponents[2,0]);
 result.RawComponents[1,1]:=(aLeft.RawComponents[1,0]*aRight.RawComponents[0,1])+(aLeft.RawComponents[1,1]*aRight.RawComponents[1,1])+(aLeft.RawComponents[1,2]*aRight.RawComponents[2,1]);
 result.RawComponents[1,2]:=(aLeft.RawComponents[1,0]*aRight.RawComponents[0,2])+(aLeft.RawComponents[1,1]*aRight.RawComponents[1,2])+(aLeft.RawComponents[1,2]*aRight.RawComponents[2,2]);
 result.RawComponents[2,0]:=(aLeft.RawComponents[2,0]*aRight.RawComponents[0,0])+(aLeft.RawComponents[2,1]*aRight.RawComponents[1,0])+(aLeft.RawComponents[2,2]*aRight.RawComponents[2,0]);
 result.RawComponents[2,1]:=(aLeft.RawComponents[2,0]*aRight.RawComponents[0,1])+(aLeft.RawComponents[2,1]*aRight.RawComponents[1,1])+(aLeft.RawComponents[2,2]*aRight.RawComponents[2,1]);
 result.RawComponents[2,2]:=(aLeft.RawComponents[2,0]*aRight.RawComponents[0,2])+(aLeft.RawComponents[2,1]*aRight.RawComponents[1,2])+(aLeft.RawComponents[2,2]*aRight.RawComponents[2,2]);
end;

class operator TpvMatrix3x3D.Multiply(const aLeft:TpvMatrix3x3D;const aRight:TpvDouble):TpvMatrix3x3D;
begin
 result.RawComponents[0,0]:=aLeft.RawComponents[0,0]*aRight;
 result.RawComponents[0,1]:=aLeft.RawComponents[0,1]*aRight;
 result.RawComponents[0,2]:=aLeft.RawComponents[0,2]*aRight;
 result.RawComponents[1,0]:=aLeft.RawComponents[1,0]*aRight;
 result.RawComponents[1,1]:=aLeft.RawComponents[1,1]*aRight;
 result.RawComponents[1,2]:=aLeft.RawComponents[1,2]*aRight;
 result.RawComponents[2,0]:=aLeft.RawComponents[2,0]*aRight;
 result.RawComponents[2,1]:=aLeft.RawComponents[2,1]*aRight;
 result.RawComponents[2,2]:=aLeft.RawComponents[2,2]*aRight;
end;

class operator TpvMatrix3x3D.Multiply(const aLeft:TpvDouble;const aRight:TpvMatrix3x3D):TpvMatrix3x3D;
begin
 result.RawComponents[0,0]:=aLeft*aRight.RawComponents[0,0];
 result.RawComponents[0,1]:=aLeft*aRight.RawComponents[0,1];
 result.RawComponents[0,2]:=aLeft*aRight.RawComponents[0,2];
 result.RawComponents[1,0]:=aLeft*aRight.RawComponents[1,0];
 result.RawComponents[1,1]:=aLeft*aRight.RawComponents[1,1];
 result.RawComponents[1,2]:=aLeft*aRight.RawComponents[1,2];
 result.RawComponents[2,0]:=aLeft*aRight.RawComponents[2,0];
 result.RawComponents[2,1]:=aLeft*aRight.RawComponents[2,1];
 result.RawComponents[2,2]:=aLeft*aRight.RawComponents[2,2];
end;

class operator TpvMatrix3x3D.Multiply(const aLeft:TpvMatrix3x3D;const aRight:TpvVector3D):TpvVector3D;
begin
 result.x:=(aLeft.RawComponents[0,0]*aRight.x)+(aLeft.RawComponents[1,0]*aRight.y)+(aLeft.RawComponents[2,0]*aRight.z);
 result.y:=(aLeft.RawComponents[0,1]*aRight.x)+(aLeft.RawComponents[1,1]*aRight.y)+(aLeft.RawComponents[2,1]*aRight.z);
 result.z:=(aLeft.RawComponents[0,2]*aRight.x)+(aLeft.RawComponents[1,2]*aRight.y)+(aLeft.RawComponents[2,2]*aRight.z);
end;

class operator TpvMatrix3x3D.Multiply(const aLeft:TpvVector3D;const aRight:TpvMatrix3x3D):TpvVector3D;
begin
 result.x:=(aLeft.x*aRight.RawComponents[0,0])+(aLeft.y*aRight.RawComponents[0,1])+(aLeft.z*aRight.RawComponents[0,2]);
 result.y:=(aLeft.x*aRight.RawComponents[1,0])+(aLeft.y*aRight.RawComponents[1,1])+(aLeft.z*aRight.RawComponents[1,2]);
 result.z:=(aLeft.x*aRight.RawComponents[2,0])+(aLeft.y*aRight.RawComponents[2,1])+(aLeft.z*aRight.RawComponents[2,2]);
end;

class operator TpvMatrix3x3D.Multiply(const aLeft:TpvMatrix3x3D;const aRight:TpvVector4D):TpvVector4D;
begin
 result.x:=(aLeft.RawComponents[0,0]*aRight.x)+(aLeft.RawComponents[1,0]*aRight.y)+(aLeft.RawComponents[2,0]*aRight.z);
 result.y:=(aLeft.RawComponents[0,1]*aRight.x)+(aLeft.RawComponents[1,1]*aRight.y)+(aLeft.RawComponents[2,1]*aRight.z);
 result.z:=(aLeft.RawComponents[0,2]*aRight.x)+(aLeft.RawComponents[1,2]*aRight.y)+(aLeft.RawComponents[2,2]*aRight.z);
 result.w:=aRight.w;
end;

class operator TpvMatrix3x3D.Multiply(const aLeft:TpvVector4D;const aRight:TpvMatrix3x3D):TpvVector4D;
begin
 result.x:=(aLeft.x*aRight.RawComponents[0,0])+(aLeft.y*aRight.RawComponents[0,1])+(aLeft.z*aRight.RawComponents[0,2]);
 result.y:=(aLeft.x*aRight.RawComponents[1,0])+(aLeft.y*aRight.RawComponents[1,1])+(aLeft.z*aRight.RawComponents[1,2]);
 result.z:=(aLeft.x*aRight.RawComponents[2,0])+(aLeft.y*aRight.RawComponents[2,1])+(aLeft.z*aRight.RawComponents[2,2]);
 result.w:=aLeft.w;
end;

class operator TpvMatrix3x3D.Divide(const aLeft,aRight:TpvMatrix3x3D):TpvMatrix3x3D;
begin
 result:=aLeft*aRight.Inverse;
end;

class operator TpvMatrix3x3D.Divide(const aLeft:TpvMatrix3x3D;const aRight:TpvDouble):TpvMatrix3x3D;
begin
 result.RawComponents[0,0]:=aLeft.RawComponents[0,0]/aRight;
 result.RawComponents[0,1]:=aLeft.RawComponents[0,1]/aRight;
 result.RawComponents[0,2]:=aLeft.RawComponents[0,2]/aRight;
 result.RawComponents[1,0]:=aLeft.RawComponents[1,0]/aRight;
 result.RawComponents[1,1]:=aLeft.RawComponents[1,1]/aRight;
 result.RawComponents[1,2]:=aLeft.RawComponents[1,2]/aRight;
 result.RawComponents[2,0]:=aLeft.RawComponents[2,0]/aRight;
 result.RawComponents[2,1]:=aLeft.RawComponents[2,1]/aRight;
 result.RawComponents[2,2]:=aLeft.RawComponents[2,2]/aRight;
end;

class operator TpvMatrix3x3D.Negative(const aMatrix:TpvMatrix3x3D):TpvMatrix3x3D;
begin
 result.RawComponents[0,0]:=-aMatrix.RawComponents[0,0];
 result.RawComponents[0,1]:=-aMatrix.RawComponents[0,1];
 result.RawComponents[0,2]:=-aMatrix.RawComponents[0,2];
 result.RawComponents[1,0]:=-aMatrix.RawComponents[1,0];
 result.RawComponents[1,1]:=-aMatrix.RawComponents[1,1];
 result.RawComponents[1,2]:=-aMatrix.RawComponents[1,2];
 result.RawComponents[2,0]:=-aMatrix.RawComponents[2,0];
 result.RawComponents[2,1]:=-aMatrix.RawComponents[2,1];
 result.RawComponents[2,2]:=-aMatrix.RawComponents[2,2];
end;

function TpvMatrix3x3D.Transpose:TpvMatrix3x3D;
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

function TpvMatrix3x3D.Determinant:TpvDouble;
begin
 result:=(((((RawComponents[0,0]*RawComponents[1,1]*RawComponents[2,2])+
             (RawComponents[0,1]*RawComponents[1,2]*RawComponents[2,0]))+
            (RawComponents[0,2]*RawComponents[1,0]*RawComponents[2,1]))-
           (RawComponents[0,2]*RawComponents[1,1]*RawComponents[2,0]))-
          (RawComponents[0,1]*RawComponents[1,0]*RawComponents[2,2]))-
         (RawComponents[0,0]*RawComponents[1,2]*RawComponents[2,1]);
end;

function TpvMatrix3x3D.Inverse:TpvMatrix3x3D;
var DeterminantValue:TpvDouble;
begin
 DeterminantValue:=Determinant;
 if DeterminantValue<>0.0 then begin
  DeterminantValue:=1.0/DeterminantValue;
  result.RawComponents[0,0]:=(((RawComponents[1,1]*RawComponents[2,2])-(RawComponents[1,2]*RawComponents[2,1]))*DeterminantValue);
  result.RawComponents[0,1]:=(((RawComponents[0,2]*RawComponents[2,1])-(RawComponents[0,1]*RawComponents[2,2]))*DeterminantValue);
  result.RawComponents[0,2]:=(((RawComponents[0,1]*RawComponents[1,2])-(RawComponents[0,2]*RawComponents[1,1]))*DeterminantValue);
  result.RawComponents[1,0]:=(((RawComponents[1,2]*RawComponents[2,0])-(RawComponents[1,0]*RawComponents[2,2]))*DeterminantValue);
  result.RawComponents[1,1]:=(((RawComponents[0,0]*RawComponents[2,2])-(RawComponents[0,2]*RawComponents[2,0]))*DeterminantValue);
  result.RawComponents[1,2]:=(((RawComponents[1,0]*RawComponents[0,2])-(RawComponents[0,0]*RawComponents[1,2]))*DeterminantValue);
  result.RawComponents[2,0]:=(((RawComponents[1,0]*RawComponents[2,1])-(RawComponents[1,1]*RawComponents[2,0]))*DeterminantValue);
  result.RawComponents[2,1]:=(((RawComponents[0,1]*RawComponents[2,0])-(RawComponents[0,0]*RawComponents[2,1]))*DeterminantValue);
  result.RawComponents[2,2]:=(((RawComponents[0,0]*RawComponents[1,1])-(RawComponents[0,1]*RawComponents[1,0]))*DeterminantValue);
 end else begin
  result:=TpvMatrix3x3D.Create(0.0,0.0,0.0,
                               0.0,0.0,0.0,
                               0.0,0.0,0.0);
 end; 
end;

function TpvMatrix3x3D.Adjugate:TpvMatrix3x3D;
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

function TpvMatrix3x3D.ToMatrix3x3:TpvMatrix3x3;
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

function TpvMatrix3x3D.ToQuaternionD:TpvQuaternionD;
var t,s:TpvDouble;
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
 t:=sqrt(sqr(result.x)+sqr(result.y)+sqr(result.z)+sqr(result.w));
 if t>0.0 then begin
  result.x:=result.x/t;
  result.y:=result.y/t;
  result.z:=result.z/t;
  result.w:=result.w/t;
 end;
end;

function TpvMatrix3x3D.Decompose:TpvDecomposedMatrix3x3D;
var LocalMatrix:TpvMatrix3x3D;
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

  result.Scale:=TpvVector3D.Create(1.0,1.0,1.0);
  result.Skew:=TpvVector3D.Create(0.0,0.0,0.0);
  result.Rotation:=TpvQuaternionD.Create(0.0,0.0,0.0,1.0);
  
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

  result.Skew.y:=result.Skew.y/result.Scale.z;
  result.Skew.z:=result.Skew.z/result.Scale.z;

  if LocalMatrix.Right.Dot(LocalMatrix.Up.Cross(LocalMatrix.Forwards))<0.0 then begin
   result.Scale.x:=-result.Scale.x;
   LocalMatrix:=-LocalMatrix;
  end;

  result.Rotation:=LocalMatrix.ToQuaternionD;

  result.Valid:=true;

 end;

end;

function TpvMatrix3x3D.Lerp(const aWith:TpvMatrix3x3D;const aTime:TpvDouble):TpvMatrix3x3D;
var InverseTime:TpvDouble;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  InverseTime:=1.0-aTime;
  result.RawComponents[0,0]:=(RawComponents[0,0]*InverseTime)+(aWith.RawComponents[0,0]*aTime);
  result.RawComponents[0,1]:=(RawComponents[0,1]*InverseTime)+(aWith.RawComponents[0,1]*aTime);
  result.RawComponents[0,2]:=(RawComponents[0,2]*InverseTime)+(aWith.RawComponents[0,2]*aTime);
  result.RawComponents[1,0]:=(RawComponents[1,0]*InverseTime)+(aWith.RawComponents[1,0]*aTime);
  result.RawComponents[1,1]:=(RawComponents[1,1]*InverseTime)+(aWith.RawComponents[1,1]*aTime);
  result.RawComponents[1,2]:=(RawComponents[1,2]*InverseTime)+(aWith.RawComponents[1,2]*aTime);
  result.RawComponents[2,0]:=(RawComponents[2,0]*InverseTime)+(aWith.RawComponents[2,0]*aTime);
  result.RawComponents[2,1]:=(RawComponents[2,1]*InverseTime)+(aWith.RawComponents[2,1]*aTime);
  result.RawComponents[2,2]:=(RawComponents[2,2]*InverseTime)+(aWith.RawComponents[2,2]*aTime);
 end;
end;

function TpvMatrix3x3D.Nlerp(const aWith:TpvMatrix3x3D;const aTime:TpvDouble):TpvMatrix3x3D;
begin
 result:=TpvMatrix3x3D.Create(Decompose.Nlerp(aWith.Decompose,aTime));
end;

function TpvMatrix3x3D.Slerp(const aWith:TpvMatrix3x3D;const aTime:TpvDouble):TpvMatrix3x3D;
begin
 result:=TpvMatrix3x3D.Create(Decompose.Slerp(aWith.Decompose,aTime));
end;

function TpvMatrix3x3D.Elerp(const aWith:TpvMatrix3x3D;const aTime:TpvDouble):TpvMatrix3x3D;
begin
 result:=TpvMatrix3x3D.Create(Decompose.Elerp(aWith.Decompose,aTime));
end;

function TpvMatrix3x3D.Sqlerp(const aB,aC,aD:TpvMatrix3x3D;const aTime:TpvDouble):TpvMatrix3x3D;
begin
 result:=TpvMatrix3x3D.Create(Decompose.Sqlerp(aB.Decompose,aC.Decompose,aD.Decompose,aTime));
end;

class function TpvDecomposedMatrix4x4D.Create:TpvDecomposedMatrix4x4D;
begin
 result.Perspective:=TpvVector4D.Create(0.0,0.0,0.0,1.0);
 result.Translation:=TpvVector3D.Create(0.0,0.0,0.0);
 result.Scale:=TpvVector3D.Create(1.0,1.0,1.0);
 result.Skew:=TpvVector3D.Create(0.0,0.0,0.0);
 result.Rotation:=TpvQuaternionD.Create(0.0,0.0,0.0,1.0);
 result.Valid:=true;
end;

function TpvDecomposedMatrix4x4D.Lerp(const aWith:TpvDecomposedMatrix4x4D;const aTime:TpvDouble):TpvDecomposedMatrix4x4D;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  result.Perspective:=Perspective.Lerp(aWith.Perspective,aTime);
  result.Translation:=Translation.Lerp(aWith.Translation,aTime);
  result.Scale:=Scale.Lerp(aWith.Scale,aTime);
  result.Skew:=Skew.Lerp(aWith.Skew,aTime);
  result.Rotation:=Rotation.Lerp(aWith.Rotation,aTime);
 end;
end;

function TpvDecomposedMatrix4x4D.Nlerp(const aWith:TpvDecomposedMatrix4x4D;const aTime:TpvDouble):TpvDecomposedMatrix4x4D;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  result.Perspective:=Perspective.Lerp(aWith.Perspective,aTime);
  result.Translation:=Translation.Lerp(aWith.Translation,aTime);
  result.Scale:=Scale.Lerp(aWith.Scale,aTime);
  result.Skew:=Skew.Lerp(aWith.Skew,aTime);
  result.Rotation:=Rotation.Nlerp(aWith.Rotation,aTime);
 end;
end;

function TpvDecomposedMatrix4x4D.Slerp(const aWith:TpvDecomposedMatrix4x4D;const aTime:TpvDouble):TpvDecomposedMatrix4x4D;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  result.Perspective:=Perspective.Lerp(aWith.Perspective,aTime);
  result.Translation:=Translation.Lerp(aWith.Translation,aTime);
  result.Scale:=Scale.Lerp(aWith.Scale,aTime);
  result.Skew:=Skew.Lerp(aWith.Skew,aTime);
  result.Rotation:=Rotation.Slerp(aWith.Rotation,aTime);
 end;
end;

function TpvDecomposedMatrix4x4D.Elerp(const aWith:TpvDecomposedMatrix4x4D;const aTime:TpvDouble):TpvDecomposedMatrix4x4D;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  result.Perspective:=Perspective.Lerp(aWith.Perspective,aTime);
  result.Translation:=Translation.Lerp(aWith.Translation,aTime);
  result.Scale:=Scale.Lerp(aWith.Scale,aTime);
  result.Skew:=Skew.Lerp(aWith.Skew,aTime);
  result.Rotation:=Rotation.Elerp(aWith.Rotation,aTime);
 end;
end;

function TpvDecomposedMatrix4x4D.Sqlerp(const aB,aC,aD:TpvDecomposedMatrix4x4D;const aTime:TpvDouble):TpvDecomposedMatrix4x4D;
begin
 result:=Slerp(aD,aTime).Slerp(aB.Slerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

constructor TpvMatrix4x4D.Create(const aXX,aXY,aXZ,aXW,aYX,aYY,aYZ,aYW,aZX,aZY,aZZ,aZW,aWX,aWY,aWZ,aWW:TpvDouble);
begin
 RawComponents[0,0]:=aXX;
 RawComponents[0,1]:=aXY;
 RawComponents[0,2]:=aXZ;
 RawComponents[0,3]:=aXW;
 RawComponents[1,0]:=aYX;
 RawComponents[1,1]:=aYY;
 RawComponents[1,2]:=aYZ;
 RawComponents[1,3]:=aYW;
 RawComponents[2,0]:=aZX;
 RawComponents[2,1]:=aZY;
 RawComponents[2,2]:=aZZ;
 RawComponents[2,3]:=aZW;
 RawComponents[3,0]:=aWX;
 RawComponents[3,1]:=aWY;
 RawComponents[3,2]:=aWZ;
 RawComponents[3,3]:=aWW;
end;

constructor TpvMatrix4x4D.Create(const aTangent,aBitangent,aNormal,aTranslation:TpvVector3D);
begin
 RawComponents[0,0]:=aTangent.x;
 RawComponents[0,1]:=aTangent.y;
 RawComponents[0,2]:=aTangent.z;
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=aBitangent.x;
 RawComponents[1,1]:=aBitangent.y;
 RawComponents[1,2]:=aBitangent.z;
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=aNormal.x;
 RawComponents[2,1]:=aNormal.y;
 RawComponents[2,2]:=aNormal.z;
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=aTranslation.x;
 RawComponents[3,1]:=aTranslation.y;
 RawComponents[3,2]:=aTranslation.z;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4D.Create(const aFrom:TpvMatrix3x3);
begin
 RawComponents[0,0]:=aFrom.RawComponents[0,0];
 RawComponents[0,1]:=aFrom.RawComponents[0,1];
 RawComponents[0,2]:=aFrom.RawComponents[0,2];
 RawComponents[0,3]:=0.0;
 RawComponents[1,0]:=aFrom.RawComponents[1,0];
 RawComponents[1,1]:=aFrom.RawComponents[1,1];
 RawComponents[1,2]:=aFrom.RawComponents[1,2];
 RawComponents[1,3]:=0.0;
 RawComponents[2,0]:=aFrom.RawComponents[2,0];
 RawComponents[2,1]:=aFrom.RawComponents[2,1];
 RawComponents[2,2]:=aFrom.RawComponents[2,2];
 RawComponents[2,3]:=0.0;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4D.Create(const aFrom:TpvMatrix4x4);
begin
 RawComponents[0,0]:=aFrom.RawComponents[0,0];
 RawComponents[0,1]:=aFrom.RawComponents[0,1];
 RawComponents[0,2]:=aFrom.RawComponents[0,2];
 RawComponents[0,3]:=aFrom.RawComponents[0,3];
 RawComponents[1,0]:=aFrom.RawComponents[1,0];
 RawComponents[1,1]:=aFrom.RawComponents[1,1];
 RawComponents[1,2]:=aFrom.RawComponents[1,2];
 RawComponents[1,3]:=aFrom.RawComponents[1,3];
 RawComponents[2,0]:=aFrom.RawComponents[2,0];
 RawComponents[2,1]:=aFrom.RawComponents[2,1];
 RawComponents[2,2]:=aFrom.RawComponents[2,2];
 RawComponents[2,3]:=aFrom.RawComponents[2,3];
 RawComponents[3,0]:=aFrom.RawComponents[3,0];
 RawComponents[3,1]:=aFrom.RawComponents[3,1];
 RawComponents[3,2]:=aFrom.RawComponents[3,2];
 RawComponents[3,3]:=aFrom.RawComponents[3,3];
end;

constructor TpvMatrix4x4D.Create(const aFrom:TpvQuaternion);
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:TpvDouble;
    From:TpvQuaternion;
begin
 From:=aFrom.Normalize;
 qx2:=From.x+From.x;
 qy2:=From.y+From.y;
 qz2:=From.z+From.z;
 qxqx2:=From.x*qx2;
 qxqy2:=From.x*qy2;
 qxqz2:=From.x*qz2;
 qxqw2:=From.w*qx2;
 qyqy2:=From.y*qy2;
 qyqz2:=From.y*qz2;
 qyqw2:=From.w*qy2;
 qzqz2:=From.z*qz2;
 qzqw2:=From.w*qz2;
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

constructor TpvMatrix4x4D.Create(const aFrom:TpvQuaternionD);
var qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2:TpvDouble;
    From:TpvQuaternionD;
begin
 From:=aFrom.Normalize;
 qx2:=From.x+From.x;
 qy2:=From.y+From.y;
 qz2:=From.z+From.z;
 qxqx2:=From.x*qx2;
 qxqy2:=From.x*qy2;
 qxqz2:=From.x*qz2;
 qxqw2:=From.w*qx2;
 qyqy2:=From.y*qy2;
 qyqz2:=From.y*qz2;
 qyqw2:=From.w*qy2;
 qzqz2:=From.z*qz2;
 qzqw2:=From.w*qz2;
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

constructor TpvMatrix4x4D.Create(const aFrom:TpvDecomposedMatrix4x4D);
begin

 RawComponents[0,0]:=1.0;
 RawComponents[0,1]:=0.0;
 RawComponents[0,2]:=0.0;
 RawComponents[0,3]:=aFrom.Perspective.x;
 RawComponents[1,0]:=0.0;
 RawComponents[1,1]:=1.0;
 RawComponents[1,2]:=0.0;
 RawComponents[1,3]:=aFrom.Perspective.y;
 RawComponents[2,0]:=0.0;
 RawComponents[2,1]:=0.0;
 RawComponents[2,2]:=1.0;
 RawComponents[2,3]:=aFrom.Perspective.z;
 RawComponents[3,0]:=0.0;
 RawComponents[3,1]:=0.0;
 RawComponents[3,2]:=0.0;
 RawComponents[3,3]:=aFrom.Perspective.w;

 Translation:=Translation+
              (Right*aFrom.Translation.x)+
              (Up*aFrom.Translation.y)+
              (Forwards*aFrom.Translation.z);

 self:=TpvMatrix4x4D.Create(aFrom.Rotation)*self;

 if aFrom.Skew.z<>0.0 then begin // YZ
  self:=TpvMatrix4x4D.Create(1.0,0.0,0.0,0.0,
                            0.0,1.0,0.0,0.0,
                            0.0,aFrom.Skew.z,1.0,0.0,
                            0.0,0.0,0.0,1.0)*self;
 end;

 if aFrom.Skew.y<>0.0 then begin // XZ
  self:=TpvMatrix4x4D.Create(1.0,0.0,0.0,0.0,
                            0.0,1.0,0.0,0.0,
                            aFrom.Skew.y,0.0,1.0,0.0,
                            0.0,0.0,0.0,1.0)*self;
 end;

 if aFrom.Skew.x<>0.0 then begin // XY
  self:=TpvMatrix4x4D.Create(1.0,0.0,0.0,0.0,
                            aFrom.Skew.x,1.0,0.0,0.0,
                            0.0,0.0,1.0,0.0,
                            0.0,0.0,0.0,1.0)*self;
 end;

 self:=TpvMatrix4x4D.Create(aFrom.Scale.x,0.0,0.0,0.0,
                            0.0,aFrom.Scale.y,0.0,0.0,
                            0.0,0.0,aFrom.Scale.z,0.0,
                            0.0,0.0,0.0,1.0)*self;

end;

constructor TpvMatrix4x4D.CreateTranslation(const aTranslation:TpvVector3D);
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
 RawComponents[3,0]:=aTranslation.x;
 RawComponents[3,1]:=aTranslation.y;
 RawComponents[3,2]:=aTranslation.z;
 RawComponents[3,3]:=1.0;
end;

constructor TpvMatrix4x4D.CreateInverseLookAt(const Eye,Center,Up:TpvVector3D);
var RightVector,UpVector,ForwardVector:TpvVector3D;
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

constructor TpvMatrix4x4D.CreateLookAt(const Eye,Center,Up:TpvVector3D);
var RightVector,UpVector,ForwardVector:TpvVector3D;
begin
 ForwardVector:=(Center-Eye).Normalize;
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



class operator TpvMatrix4x4D.Implicit(const aFrom:TpvMatrix3x3):TpvMatrix4x4D;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[0,3]:=0.0;
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[1,3]:=0.0;
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
 result.RawComponents[2,3]:=0.0;
 result.RawComponents[3,0]:=0.0;
 result.RawComponents[3,1]:=0.0;
 result.RawComponents[3,2]:=0.0;
 result.RawComponents[3,3]:=1.0;
end;

class operator TpvMatrix4x4D.Implicit(const aFrom:TpvMatrix4x4D):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
end;

class operator TpvMatrix4x4D.Implicit(const aFrom:TpvMatrix4x4):TpvMatrix4x4D;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[0,3]:=aFrom.RawComponents[0,3];
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[1,3]:=aFrom.RawComponents[1,3];
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
 result.RawComponents[2,3]:=aFrom.RawComponents[2,3];
 result.RawComponents[3,0]:=aFrom.RawComponents[3,0];
 result.RawComponents[3,1]:=aFrom.RawComponents[3,1];
 result.RawComponents[3,2]:=aFrom.RawComponents[3,2];
 result.RawComponents[3,3]:=aFrom.RawComponents[3,3];
end;

class operator TpvMatrix4x4D.Implicit(const aFrom:TpvMatrix4x4D):TpvMatrix4x4;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[0,3]:=aFrom.RawComponents[0,3];
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[1,3]:=aFrom.RawComponents[1,3];
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
 result.RawComponents[2,3]:=aFrom.RawComponents[2,3];
 result.RawComponents[3,0]:=aFrom.RawComponents[3,0];
 result.RawComponents[3,1]:=aFrom.RawComponents[3,1];
 result.RawComponents[3,2]:=aFrom.RawComponents[3,2];
 result.RawComponents[3,3]:=aFrom.RawComponents[3,3];
end;

class operator TpvMatrix4x4D.Implicit(const aFrom:TpvQuaternion):TpvMatrix4x4D;
begin
 result:=TpvMatrix4x4D.Create(aFrom);
end;

class operator TpvMatrix4x4D.Implicit(const aFrom:TpvQuaternionD):TpvMatrix4x4D;
begin
 result:=TpvMatrix4x4D.Create(aFrom);
end;

class operator TpvMatrix4x4D.Implicit(const aFrom:TpvDecomposedMatrix4x4D):TpvMatrix4x4D;
begin
 result:=TpvMatrix4x4D.Create(aFrom);
end;

class operator TpvMatrix4x4D.Implicit(const aFrom:TpvMatrix4x4D):TpvQuaternion;
begin
 result:=aFrom.ToQuaternionD.ToQuaternion;
end;

class operator TpvMatrix4x4D.Implicit(const aFrom:TpvMatrix4x4D):TpvQuaternionD;
begin
 result:=aFrom.ToQuaternionD;
end;

class operator TpvMatrix4x4D.Implicit(const aFrom:TpvMatrix4x4D):TpvDecomposedMatrix4x4D;
begin
 result:=aFrom.Decompose;
end;

class operator TpvMatrix4x4D.Explicit(const aFrom:TpvMatrix3x3):TpvMatrix4x4D;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[0,3]:=0.0;
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[1,3]:=0.0;
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
 result.RawComponents[2,3]:=0.0;
 result.RawComponents[3,0]:=0.0;
 result.RawComponents[3,1]:=0.0;
 result.RawComponents[3,2]:=0.0;
 result.RawComponents[3,3]:=1.0;
end;

class operator TpvMatrix4x4D.Explicit(const aFrom:TpvMatrix4x4D):TpvMatrix3x3;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
end;

class operator TpvMatrix4x4D.Explicit(const aFrom:TpvMatrix4x4):TpvMatrix4x4D;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[0,3]:=aFrom.RawComponents[0,3];
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[1,3]:=aFrom.RawComponents[1,3];
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
 result.RawComponents[2,3]:=aFrom.RawComponents[2,3];
 result.RawComponents[3,0]:=aFrom.RawComponents[3,0];
 result.RawComponents[3,1]:=aFrom.RawComponents[3,1];
 result.RawComponents[3,2]:=aFrom.RawComponents[3,2];
 result.RawComponents[3,3]:=aFrom.RawComponents[3,3];
end;

class operator TpvMatrix4x4D.Explicit(const aFrom:TpvMatrix4x4D):TpvMatrix4x4;
begin
 result.RawComponents[0,0]:=aFrom.RawComponents[0,0];
 result.RawComponents[0,1]:=aFrom.RawComponents[0,1];
 result.RawComponents[0,2]:=aFrom.RawComponents[0,2];
 result.RawComponents[0,3]:=aFrom.RawComponents[0,3];
 result.RawComponents[1,0]:=aFrom.RawComponents[1,0];
 result.RawComponents[1,1]:=aFrom.RawComponents[1,1];
 result.RawComponents[1,2]:=aFrom.RawComponents[1,2];
 result.RawComponents[1,3]:=aFrom.RawComponents[1,3];
 result.RawComponents[2,0]:=aFrom.RawComponents[2,0];
 result.RawComponents[2,1]:=aFrom.RawComponents[2,1];
 result.RawComponents[2,2]:=aFrom.RawComponents[2,2];
 result.RawComponents[2,3]:=aFrom.RawComponents[2,3];
 result.RawComponents[3,0]:=aFrom.RawComponents[3,0];
 result.RawComponents[3,1]:=aFrom.RawComponents[3,1];
 result.RawComponents[3,2]:=aFrom.RawComponents[3,2];
 result.RawComponents[3,3]:=aFrom.RawComponents[3,3];
end;

class operator TpvMatrix4x4D.Explicit(const aFrom:TpvQuaternion):TpvMatrix4x4D;
begin
 result:=TpvMatrix4x4D.Create(aFrom);
end;

class operator TpvMatrix4x4D.Explicit(const aFrom:TpvQuaternionD):TpvMatrix4x4D;
begin
 result:=TpvMatrix4x4D.Create(aFrom);
end;

class operator TpvMatrix4x4D.Explicit(const aFrom:TpvDecomposedMatrix4x4D):TpvMatrix4x4D;
begin
 result:=TpvMatrix4x4D.Create(aFrom);
end;

class operator TpvMatrix4x4D.Explicit(const aFrom:TpvMatrix4x4D):TpvQuaternion;
begin
 result:=aFrom.ToQuaternionD.ToQuaternion;
end;

class operator TpvMatrix4x4D.Explicit(const aFrom:TpvMatrix4x4D):TpvQuaternionD;
begin
 result:=aFrom.ToQuaternionD;
end;

class operator TpvMatrix4x4D.Explicit(const aFrom:TpvMatrix4x4D):TpvDecomposedMatrix4x4D;
begin
 result:=aFrom.Decompose;
end;

class operator TpvMatrix4x4D.Equal(const aLeft,aRight:TpvMatrix4x4D):boolean;
begin
 result:=(aLeft.RawComponents[0,0]=aRight.RawComponents[0,0]) and
         (aLeft.RawComponents[0,1]=aRight.RawComponents[0,1]) and
         (aLeft.RawComponents[0,2]=aRight.RawComponents[0,2]) and
         (aLeft.RawComponents[0,3]=aRight.RawComponents[0,3]) and
         (aLeft.RawComponents[1,0]=aRight.RawComponents[1,0]) and
         (aLeft.RawComponents[1,1]=aRight.RawComponents[1,1]) and
         (aLeft.RawComponents[1,2]=aRight.RawComponents[1,2]) and
         (aLeft.RawComponents[1,3]=aRight.RawComponents[1,3]) and
         (aLeft.RawComponents[2,0]=aRight.RawComponents[2,0]) and
         (aLeft.RawComponents[2,1]=aRight.RawComponents[2,1]) and
         (aLeft.RawComponents[2,2]=aRight.RawComponents[2,2]) and
         (aLeft.RawComponents[2,3]=aRight.RawComponents[2,3]) and
         (aLeft.RawComponents[3,0]=aRight.RawComponents[3,0]) and
         (aLeft.RawComponents[3,1]=aRight.RawComponents[3,1]) and
         (aLeft.RawComponents[3,2]=aRight.RawComponents[3,2]) and
         (aLeft.RawComponents[3,3]=aRight.RawComponents[3,3]);
end;

class operator TpvMatrix4x4D.NotEqual(const aLeft,aRight:TpvMatrix4x4D):boolean;
begin
 result:=(aLeft.RawComponents[0,0]<>aRight.RawComponents[0,0]) or
         (aLeft.RawComponents[0,1]<>aRight.RawComponents[0,1]) or
         (aLeft.RawComponents[0,2]<>aRight.RawComponents[0,2]) or
         (aLeft.RawComponents[0,3]<>aRight.RawComponents[0,3]) or
         (aLeft.RawComponents[1,0]<>aRight.RawComponents[1,0]) or
         (aLeft.RawComponents[1,1]<>aRight.RawComponents[1,1]) or
         (aLeft.RawComponents[1,2]<>aRight.RawComponents[1,2]) or
         (aLeft.RawComponents[1,3]<>aRight.RawComponents[1,3]) or
         (aLeft.RawComponents[2,0]<>aRight.RawComponents[2,0]) or
         (aLeft.RawComponents[2,1]<>aRight.RawComponents[2,1]) or
         (aLeft.RawComponents[2,2]<>aRight.RawComponents[2,2]) or
         (aLeft.RawComponents[2,3]<>aRight.RawComponents[2,3]) or
         (aLeft.RawComponents[3,0]<>aRight.RawComponents[3,0]) or
         (aLeft.RawComponents[3,1]<>aRight.RawComponents[3,1]) or
         (aLeft.RawComponents[3,2]<>aRight.RawComponents[3,2]) or
         (aLeft.RawComponents[3,3]<>aRight.RawComponents[3,3]);
end;

class operator TpvMatrix4x4D.Add(const aLeft,aRight:TpvMatrix4x4D):TpvMatrix4x4D;
begin
 result.RawComponents[0,0]:=aLeft.RawComponents[0,0]+aRight.RawComponents[0,0];
 result.RawComponents[0,1]:=aLeft.RawComponents[0,1]+aRight.RawComponents[0,1];
 result.RawComponents[0,2]:=aLeft.RawComponents[0,2]+aRight.RawComponents[0,2];
 result.RawComponents[0,3]:=aLeft.RawComponents[0,3]+aRight.RawComponents[0,3];
 result.RawComponents[1,0]:=aLeft.RawComponents[1,0]+aRight.RawComponents[1,0];
 result.RawComponents[1,1]:=aLeft.RawComponents[1,1]+aRight.RawComponents[1,1];
 result.RawComponents[1,2]:=aLeft.RawComponents[1,2]+aRight.RawComponents[1,2];
 result.RawComponents[1,3]:=aLeft.RawComponents[1,3]+aRight.RawComponents[1,3];
 result.RawComponents[2,0]:=aLeft.RawComponents[2,0]+aRight.RawComponents[2,0];
 result.RawComponents[2,1]:=aLeft.RawComponents[2,1]+aRight.RawComponents[2,1];
 result.RawComponents[2,2]:=aLeft.RawComponents[2,2]+aRight.RawComponents[2,2];
 result.RawComponents[2,3]:=aLeft.RawComponents[2,3]+aRight.RawComponents[2,3];
 result.RawComponents[3,0]:=aLeft.RawComponents[3,0]+aRight.RawComponents[3,0];
 result.RawComponents[3,1]:=aLeft.RawComponents[3,1]+aRight.RawComponents[3,1];
 result.RawComponents[3,2]:=aLeft.RawComponents[3,2]+aRight.RawComponents[3,2];
 result.RawComponents[3,3]:=aLeft.RawComponents[3,3]+aRight.RawComponents[3,3];
end;

class operator TpvMatrix4x4D.Subtract(const aLeft,aRight:TpvMatrix4x4D):TpvMatrix4x4D;
begin
 result.RawComponents[0,0]:=aLeft.RawComponents[0,0]-aRight.RawComponents[0,0];
 result.RawComponents[0,1]:=aLeft.RawComponents[0,1]-aRight.RawComponents[0,1];
 result.RawComponents[0,2]:=aLeft.RawComponents[0,2]-aRight.RawComponents[0,2];
 result.RawComponents[0,3]:=aLeft.RawComponents[0,3]-aRight.RawComponents[0,3];
 result.RawComponents[1,0]:=aLeft.RawComponents[1,0]-aRight.RawComponents[1,0];
 result.RawComponents[1,1]:=aLeft.RawComponents[1,1]-aRight.RawComponents[1,1];
 result.RawComponents[1,2]:=aLeft.RawComponents[1,2]-aRight.RawComponents[1,2];
 result.RawComponents[1,3]:=aLeft.RawComponents[1,3]-aRight.RawComponents[1,3];
 result.RawComponents[2,0]:=aLeft.RawComponents[2,0]-aRight.RawComponents[2,0];
 result.RawComponents[2,1]:=aLeft.RawComponents[2,1]-aRight.RawComponents[2,1];
 result.RawComponents[2,2]:=aLeft.RawComponents[2,2]-aRight.RawComponents[2,2];
 result.RawComponents[2,3]:=aLeft.RawComponents[2,3]-aRight.RawComponents[2,3];
 result.RawComponents[3,0]:=aLeft.RawComponents[3,0]-aRight.RawComponents[3,0];
 result.RawComponents[3,1]:=aLeft.RawComponents[3,1]-aRight.RawComponents[3,1];
 result.RawComponents[3,2]:=aLeft.RawComponents[3,2]-aRight.RawComponents[3,2];
 result.RawComponents[3,3]:=aLeft.RawComponents[3,3]-aRight.RawComponents[3,3];
end;

class operator TpvMatrix4x4D.Multiply(const aLeft,aRight:TpvMatrix4x4D):TpvMatrix4x4D;
begin
 result.RawComponents[0,0]:=(aLeft.RawComponents[0,0]*aRight.RawComponents[0,0])+(aLeft.RawComponents[0,1]*aRight.RawComponents[1,0])+(aLeft.RawComponents[0,2]*aRight.RawComponents[2,0])+(aLeft.RawComponents[0,3]*aRight.RawComponents[3,0]);
 result.RawComponents[0,1]:=(aLeft.RawComponents[0,0]*aRight.RawComponents[0,1])+(aLeft.RawComponents[0,1]*aRight.RawComponents[1,1])+(aLeft.RawComponents[0,2]*aRight.RawComponents[2,1])+(aLeft.RawComponents[0,3]*aRight.RawComponents[3,1]);
 result.RawComponents[0,2]:=(aLeft.RawComponents[0,0]*aRight.RawComponents[0,2])+(aLeft.RawComponents[0,1]*aRight.RawComponents[1,2])+(aLeft.RawComponents[0,2]*aRight.RawComponents[2,2])+(aLeft.RawComponents[0,3]*aRight.RawComponents[3,2]);
 result.RawComponents[0,3]:=(aLeft.RawComponents[0,0]*aRight.RawComponents[0,3])+(aLeft.RawComponents[0,1]*aRight.RawComponents[1,3])+(aLeft.RawComponents[0,2]*aRight.RawComponents[2,3])+(aLeft.RawComponents[0,3]*aRight.RawComponents[3,3]);
 result.RawComponents[1,0]:=(aLeft.RawComponents[1,0]*aRight.RawComponents[0,0])+(aLeft.RawComponents[1,1]*aRight.RawComponents[1,0])+(aLeft.RawComponents[1,2]*aRight.RawComponents[2,0])+(aLeft.RawComponents[1,3]*aRight.RawComponents[3,0]);
 result.RawComponents[1,1]:=(aLeft.RawComponents[1,0]*aRight.RawComponents[0,1])+(aLeft.RawComponents[1,1]*aRight.RawComponents[1,1])+(aLeft.RawComponents[1,2]*aRight.RawComponents[2,1])+(aLeft.RawComponents[1,3]*aRight.RawComponents[3,1]);
 result.RawComponents[1,2]:=(aLeft.RawComponents[1,0]*aRight.RawComponents[0,2])+(aLeft.RawComponents[1,1]*aRight.RawComponents[1,2])+(aLeft.RawComponents[1,2]*aRight.RawComponents[2,2])+(aLeft.RawComponents[1,3]*aRight.RawComponents[3,2]);
 result.RawComponents[1,3]:=(aLeft.RawComponents[1,0]*aRight.RawComponents[0,3])+(aLeft.RawComponents[1,1]*aRight.RawComponents[1,3])+(aLeft.RawComponents[1,2]*aRight.RawComponents[2,3])+(aLeft.RawComponents[1,3]*aRight.RawComponents[3,3]);
 result.RawComponents[2,0]:=(aLeft.RawComponents[2,0]*aRight.RawComponents[0,0])+(aLeft.RawComponents[2,1]*aRight.RawComponents[1,0])+(aLeft.RawComponents[2,2]*aRight.RawComponents[2,0])+(aLeft.RawComponents[2,3]*aRight.RawComponents[3,0]);
 result.RawComponents[2,1]:=(aLeft.RawComponents[2,0]*aRight.RawComponents[0,1])+(aLeft.RawComponents[2,1]*aRight.RawComponents[1,1])+(aLeft.RawComponents[2,2]*aRight.RawComponents[2,1])+(aLeft.RawComponents[2,3]*aRight.RawComponents[3,1]);
 result.RawComponents[2,2]:=(aLeft.RawComponents[2,0]*aRight.RawComponents[0,2])+(aLeft.RawComponents[2,1]*aRight.RawComponents[1,2])+(aLeft.RawComponents[2,2]*aRight.RawComponents[2,2])+(aLeft.RawComponents[2,3]*aRight.RawComponents[3,2]);
 result.RawComponents[2,3]:=(aLeft.RawComponents[2,0]*aRight.RawComponents[0,3])+(aLeft.RawComponents[2,1]*aRight.RawComponents[1,3])+(aLeft.RawComponents[2,2]*aRight.RawComponents[2,3])+(aLeft.RawComponents[2,3]*aRight.RawComponents[3,3]);
 result.RawComponents[3,0]:=(aLeft.RawComponents[3,0]*aRight.RawComponents[0,0])+(aLeft.RawComponents[3,1]*aRight.RawComponents[1,0])+(aLeft.RawComponents[3,2]*aRight.RawComponents[2,0])+(aLeft.RawComponents[3,3]*aRight.RawComponents[3,0]);
 result.RawComponents[3,1]:=(aLeft.RawComponents[3,0]*aRight.RawComponents[0,1])+(aLeft.RawComponents[3,1]*aRight.RawComponents[1,1])+(aLeft.RawComponents[3,2]*aRight.RawComponents[2,1])+(aLeft.RawComponents[3,3]*aRight.RawComponents[3,1]);
 result.RawComponents[3,2]:=(aLeft.RawComponents[3,0]*aRight.RawComponents[0,2])+(aLeft.RawComponents[3,1]*aRight.RawComponents[1,2])+(aLeft.RawComponents[3,2]*aRight.RawComponents[2,2])+(aLeft.RawComponents[3,3]*aRight.RawComponents[3,2]);
 result.RawComponents[3,3]:=(aLeft.RawComponents[3,0]*aRight.RawComponents[0,3])+(aLeft.RawComponents[3,1]*aRight.RawComponents[1,3])+(aLeft.RawComponents[3,2]*aRight.RawComponents[2,3])+(aLeft.RawComponents[3,3]*aRight.RawComponents[3,3]);
end;

class operator TpvMatrix4x4D.Multiply(const aLeft:TpvMatrix4x4D;const aRight:TpvDouble):TpvMatrix4x4D;
begin
 result.RawComponents[0,0]:=aLeft.RawComponents[0,0]*aRight;
 result.RawComponents[0,1]:=aLeft.RawComponents[0,1]*aRight;
 result.RawComponents[0,2]:=aLeft.RawComponents[0,2]*aRight;
 result.RawComponents[0,3]:=aLeft.RawComponents[0,3]*aRight;
 result.RawComponents[1,0]:=aLeft.RawComponents[1,0]*aRight;
 result.RawComponents[1,1]:=aLeft.RawComponents[1,1]*aRight;
 result.RawComponents[1,2]:=aLeft.RawComponents[1,2]*aRight;
 result.RawComponents[1,3]:=aLeft.RawComponents[1,3]*aRight;
 result.RawComponents[2,0]:=aLeft.RawComponents[2,0]*aRight;
 result.RawComponents[2,1]:=aLeft.RawComponents[2,1]*aRight;
 result.RawComponents[2,2]:=aLeft.RawComponents[2,2]*aRight;
 result.RawComponents[2,3]:=aLeft.RawComponents[2,3]*aRight;
 result.RawComponents[3,0]:=aLeft.RawComponents[3,0]*aRight;
 result.RawComponents[3,1]:=aLeft.RawComponents[3,1]*aRight;
 result.RawComponents[3,2]:=aLeft.RawComponents[3,2]*aRight;
 result.RawComponents[3,3]:=aLeft.RawComponents[3,3]*aRight;
end;

class operator TpvMatrix4x4D.Multiply(const aLeft:TpvDouble;const aRight:TpvMatrix4x4D):TpvMatrix4x4D;
begin
 result.RawComponents[0,0]:=aLeft*aRight.RawComponents[0,0];
 result.RawComponents[0,1]:=aLeft*aRight.RawComponents[0,1];
 result.RawComponents[0,2]:=aLeft*aRight.RawComponents[0,2];
 result.RawComponents[0,3]:=aLeft*aRight.RawComponents[0,3];
 result.RawComponents[1,0]:=aLeft*aRight.RawComponents[1,0];
 result.RawComponents[1,1]:=aLeft*aRight.RawComponents[1,1];
 result.RawComponents[1,2]:=aLeft*aRight.RawComponents[1,2];
 result.RawComponents[1,3]:=aLeft*aRight.RawComponents[1,3];
 result.RawComponents[2,0]:=aLeft*aRight.RawComponents[2,0];
 result.RawComponents[2,1]:=aLeft*aRight.RawComponents[2,1];
 result.RawComponents[2,2]:=aLeft*aRight.RawComponents[2,2];
 result.RawComponents[2,3]:=aLeft*aRight.RawComponents[2,3];
 result.RawComponents[3,0]:=aLeft*aRight.RawComponents[3,0];
 result.RawComponents[3,1]:=aLeft*aRight.RawComponents[3,1];
 result.RawComponents[3,2]:=aLeft*aRight.RawComponents[3,2];
 result.RawComponents[3,3]:=aLeft*aRight.RawComponents[3,3];
end;

class operator TpvMatrix4x4D.Multiply(const aLeft:TpvMatrix4x4D;const aRight:TpvVector3D):TpvVector4D;
begin
 result.x:=(aLeft.RawComponents[0,0]*aRight.x)+(aLeft.RawComponents[1,0]*aRight.y)+(aLeft.RawComponents[2,0]*aRight.z)+aLeft.RawComponents[3,0];
 result.y:=(aLeft.RawComponents[0,1]*aRight.x)+(aLeft.RawComponents[1,1]*aRight.y)+(aLeft.RawComponents[2,1]*aRight.z)+aLeft.RawComponents[3,1];
 result.z:=(aLeft.RawComponents[0,2]*aRight.x)+(aLeft.RawComponents[1,2]*aRight.y)+(aLeft.RawComponents[2,2]*aRight.z)+aLeft.RawComponents[3,2];
 result.w:=(aLeft.RawComponents[0,3]*aRight.x)+(aLeft.RawComponents[1,3]*aRight.y)+(aLeft.RawComponents[2,3]*aRight.z)+aLeft.RawComponents[3,3];
end;

class operator TpvMatrix4x4D.Multiply(const aLeft:TpvVector3D;const aRight:TpvMatrix4x4D):TpvVector4D;
begin
 result.x:=(aLeft.x*aRight.RawComponents[0,0])+(aLeft.y*aRight.RawComponents[0,1])+(aLeft.z*aRight.RawComponents[0,2])+aRight.RawComponents[0,3];
 result.y:=(aLeft.x*aRight.RawComponents[1,0])+(aLeft.y*aRight.RawComponents[1,1])+(aLeft.z*aRight.RawComponents[1,2])+aRight.RawComponents[1,3];
 result.z:=(aLeft.x*aRight.RawComponents[2,0])+(aLeft.y*aRight.RawComponents[2,1])+(aLeft.z*aRight.RawComponents[2,2])+aRight.RawComponents[2,3];
 result.w:=(aLeft.x*aRight.RawComponents[3,0])+(aLeft.y*aRight.RawComponents[3,1])+(aLeft.z*aRight.RawComponents[3,2])+aRight.RawComponents[3,3];
end;

class operator TpvMatrix4x4D.Multiply(const aLeft:TpvMatrix4x4D;const aRight:TpvVector4D):TpvVector4D;
begin
 result.x:=(aLeft.RawComponents[0,0]*aRight.x)+(aLeft.RawComponents[1,0]*aRight.y)+(aLeft.RawComponents[2,0]*aRight.z)+(aLeft.RawComponents[3,0]*aRight.w);
 result.y:=(aLeft.RawComponents[0,1]*aRight.x)+(aLeft.RawComponents[1,1]*aRight.y)+(aLeft.RawComponents[2,1]*aRight.z)+(aLeft.RawComponents[3,1]*aRight.w);
 result.z:=(aLeft.RawComponents[0,2]*aRight.x)+(aLeft.RawComponents[1,2]*aRight.y)+(aLeft.RawComponents[2,2]*aRight.z)+(aLeft.RawComponents[3,2]*aRight.w);
 result.w:=(aLeft.RawComponents[0,3]*aRight.x)+(aLeft.RawComponents[1,3]*aRight.y)+(aLeft.RawComponents[2,3]*aRight.z)+(aLeft.RawComponents[3,3]*aRight.w);
end;

class operator TpvMatrix4x4D.Multiply(const aLeft:TpvVector4D;const aRight:TpvMatrix4x4D):TpvVector4D;
begin
 result.x:=(aLeft.x*aRight.RawComponents[0,0])+(aLeft.y*aRight.RawComponents[0,1])+(aLeft.z*aRight.RawComponents[0,2])+(aLeft.w*aRight.RawComponents[0,3]);
 result.y:=(aLeft.x*aRight.RawComponents[1,0])+(aLeft.y*aRight.RawComponents[1,1])+(aLeft.z*aRight.RawComponents[1,2])+(aLeft.w*aRight.RawComponents[1,3]);
 result.z:=(aLeft.x*aRight.RawComponents[2,0])+(aLeft.y*aRight.RawComponents[2,1])+(aLeft.z*aRight.RawComponents[2,2])+(aLeft.w*aRight.RawComponents[2,3]);
 result.w:=(aLeft.x*aRight.RawComponents[3,0])+(aLeft.y*aRight.RawComponents[3,1])+(aLeft.z*aRight.RawComponents[3,2])+(aLeft.w*aRight.RawComponents[3,3]);
end;

class operator TpvMatrix4x4D.Divide(const aLeft,aRight:TpvMatrix4x4D):TpvMatrix4x4D;
begin
 result:=aLeft*aRight.Inverse;
end;

class operator TpvMatrix4x4D.Divide(const aLeft:TpvMatrix4x4D;const aRight:TpvDouble):TpvMatrix4x4D;
begin
 result.RawComponents[0,0]:=aLeft.RawComponents[0,0]/aRight;
 result.RawComponents[0,1]:=aLeft.RawComponents[0,1]/aRight;
 result.RawComponents[0,2]:=aLeft.RawComponents[0,2]/aRight;
 result.RawComponents[0,3]:=aLeft.RawComponents[0,3]/aRight;
 result.RawComponents[1,0]:=aLeft.RawComponents[1,0]/aRight;
 result.RawComponents[1,1]:=aLeft.RawComponents[1,1]/aRight;
 result.RawComponents[1,2]:=aLeft.RawComponents[1,2]/aRight;
 result.RawComponents[1,3]:=aLeft.RawComponents[1,3]/aRight;
 result.RawComponents[2,0]:=aLeft.RawComponents[2,0]/aRight;
 result.RawComponents[2,1]:=aLeft.RawComponents[2,1]/aRight;
 result.RawComponents[2,2]:=aLeft.RawComponents[2,2]/aRight;
 result.RawComponents[2,3]:=aLeft.RawComponents[2,3]/aRight;
 result.RawComponents[3,0]:=aLeft.RawComponents[3,0]/aRight;
 result.RawComponents[3,1]:=aLeft.RawComponents[3,1]/aRight;
 result.RawComponents[3,2]:=aLeft.RawComponents[3,2]/aRight;
 result.RawComponents[3,3]:=aLeft.RawComponents[3,3]/aRight;
end;

class operator TpvMatrix4x4D.Negative(const aMatrix:TpvMatrix4x4D):TpvMatrix4x4D;
begin
 result.RawComponents[0,0]:=-aMatrix.RawComponents[0,0];
 result.RawComponents[0,1]:=-aMatrix.RawComponents[0,1];
 result.RawComponents[0,2]:=-aMatrix.RawComponents[0,2];
 result.RawComponents[0,3]:=-aMatrix.RawComponents[0,3];
 result.RawComponents[1,0]:=-aMatrix.RawComponents[1,0];
 result.RawComponents[1,1]:=-aMatrix.RawComponents[1,1];
 result.RawComponents[1,2]:=-aMatrix.RawComponents[1,2];
 result.RawComponents[1,3]:=-aMatrix.RawComponents[1,3];
 result.RawComponents[2,0]:=-aMatrix.RawComponents[2,0];
 result.RawComponents[2,1]:=-aMatrix.RawComponents[2,1];
 result.RawComponents[2,2]:=-aMatrix.RawComponents[2,2];
 result.RawComponents[2,3]:=-aMatrix.RawComponents[2,3];
 result.RawComponents[3,0]:=-aMatrix.RawComponents[3,0];
 result.RawComponents[3,1]:=-aMatrix.RawComponents[3,1];
 result.RawComponents[3,2]:=-aMatrix.RawComponents[3,2];
 result.RawComponents[3,3]:=-aMatrix.RawComponents[3,3];
end;

function TpvMatrix4x4D.MulInverted({$ifdef fpc}constref{$else}const{$endif} a:TpvVector3D):TpvVector3D;
var p:TpvVector3D;
begin
 p.x:=a.x-RawComponents[3,0];
 p.y:=a.y-RawComponents[3,1];
 p.z:=a.z-RawComponents[3,2];
 result.x:=(RawComponents[0,0]*p.x)+(RawComponents[0,1]*p.y)+(RawComponents[0,2]*p.z);
 result.y:=(RawComponents[1,0]*p.x)+(RawComponents[1,1]*p.y)+(RawComponents[1,2]*p.z);
 result.z:=(RawComponents[2,0]*p.x)+(RawComponents[2,1]*p.y)+(RawComponents[2,2]*p.z);
end;

function TpvMatrix4x4D.MulInverted({$ifdef fpc}constref{$else}const{$endif} a:TpvVector4D):TpvVector4D;
var p:TpvVector3D;
begin
 p.x:=a.x-RawComponents[3,0];
 p.y:=a.y-RawComponents[3,1];
 p.z:=a.z-RawComponents[3,2];
 result.x:=(RawComponents[0,0]*p.x)+(RawComponents[0,1]*p.y)+(RawComponents[0,2]*p.z);
 result.y:=(RawComponents[1,0]*p.x)+(RawComponents[1,1]*p.y)+(RawComponents[1,2]*p.z);
 result.z:=(RawComponents[2,0]*p.x)+(RawComponents[2,1]*p.y)+(RawComponents[2,2]*p.z);
 result.w:=a.w;
end;

function TpvMatrix4x4D.MulBasis(const aVector:TpvVector3):TpvVector3;
begin
 result.x:=(RawComponents[0,0]*aVector.x)+(RawComponents[1,0]*aVector.y)+(RawComponents[2,0]*aVector.z);
 result.y:=(RawComponents[0,1]*aVector.x)+(RawComponents[1,1]*aVector.y)+(RawComponents[2,1]*aVector.z);
 result.z:=(RawComponents[0,2]*aVector.x)+(RawComponents[1,2]*aVector.y)+(RawComponents[2,2]*aVector.z);
end;

function TpvMatrix4x4D.MulBasis(const aVector:TpvVector3D):TpvVector3D;
begin
 result.x:=(RawComponents[0,0]*aVector.x)+(RawComponents[1,0]*aVector.y)+(RawComponents[2,0]*aVector.z);
 result.y:=(RawComponents[0,1]*aVector.x)+(RawComponents[1,1]*aVector.y)+(RawComponents[2,1]*aVector.z);
 result.z:=(RawComponents[0,2]*aVector.x)+(RawComponents[1,2]*aVector.y)+(RawComponents[2,2]*aVector.z);
end;

function TpvMatrix4x4D.MulHomogen(const aVector:TpvVector3):TpvVector3;
var w:TpvDouble;
begin
 w:=(RawComponents[0,3]*aVector.x)+(RawComponents[1,3]*aVector.y)+(RawComponents[2,3]*aVector.z)+RawComponents[3,3];
 if w<>0.0 then begin
  result.x:=((RawComponents[0,0]*aVector.x)+(RawComponents[1,0]*aVector.y)+(RawComponents[2,0]*aVector.z)+RawComponents[3,0])/w;
  result.y:=((RawComponents[0,1]*aVector.x)+(RawComponents[1,1]*aVector.y)+(RawComponents[2,1]*aVector.z)+RawComponents[3,1])/w;
  result.z:=((RawComponents[0,2]*aVector.x)+(RawComponents[1,2]*aVector.y)+(RawComponents[2,2]*aVector.z)+RawComponents[3,2])/w;
 end else begin
  result:=aVector;
 end;
end;

function TpvMatrix4x4D.MulHomogen(const aVector:TpvVector3D):TpvVector3D;
var w:TpvDouble;
begin
 w:=(RawComponents[0,3]*aVector.x)+(RawComponents[1,3]*aVector.y)+(RawComponents[2,3]*aVector.z)+RawComponents[3,3];
 if w<>0.0 then begin
  result.x:=((RawComponents[0,0]*aVector.x)+(RawComponents[1,0]*aVector.y)+(RawComponents[2,0]*aVector.z)+RawComponents[3,0])/w;
  result.y:=((RawComponents[0,1]*aVector.x)+(RawComponents[1,1]*aVector.y)+(RawComponents[2,1]*aVector.z)+RawComponents[3,1])/w;
  result.z:=((RawComponents[0,2]*aVector.x)+(RawComponents[1,2]*aVector.y)+(RawComponents[2,2]*aVector.z)+RawComponents[3,2])/w;
 end else begin
  result:=aVector;
 end;
end;

function TpvMatrix4x4D.MulInverse(const aVector:TpvVector3):TpvVector3;
begin
 result:=Inverse.MulHomogen(aVector);
end;

function TpvMatrix4x4D.MulInverse(const aVector:TpvVector3D):TpvVector3D;
begin
 result:=Inverse.MulHomogen(aVector);
end;

function TpvMatrix4x4D.Transpose:TpvMatrix4x4D;
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

function TpvMatrix4x4D.Determinant:TpvDouble;
begin
 result:=(RawComponents[0,0]*((((RawComponents[1,1]*RawComponents[2,2]*RawComponents[3,3])-(RawComponents[1,1]*RawComponents[2,3]*RawComponents[3,2]))-(RawComponents[2,1]*RawComponents[1,2]*RawComponents[3,3])+(RawComponents[2,1]*RawComponents[1,3]*RawComponents[3,2])+(RawComponents[3,1]*RawComponents[1,2]*RawComponents[2,3]))-(RawComponents[3,1]*RawComponents[1,3]*RawComponents[2,2])))+
         (RawComponents[0,1]*(((((-(RawComponents[1,0]*RawComponents[2,2]*RawComponents[3,3]))+(RawComponents[1,0]*RawComponents[2,3]*RawComponents[3,2])+(RawComponents[2,0]*RawComponents[1,2]*RawComponents[3,3]))-(RawComponents[2,0]*RawComponents[1,3]*RawComponents[3,2]))-(RawComponents[3,0]*RawComponents[1,2]*RawComponents[2,3]))+(RawComponents[3,0]*RawComponents[1,3]*RawComponents[2,2])))+
         (RawComponents[0,2]*(((((RawComponents[1,0]*RawComponents[2,1]*RawComponents[3,3])-(RawComponents[1,0]*RawComponents[2,3]*RawComponents[3,1]))-(RawComponents[2,0]*RawComponents[1,1]*RawComponents[3,3]))+(RawComponents[2,0]*RawComponents[1,3]*RawComponents[3,1])+(RawComponents[3,0]*RawComponents[1,1]*RawComponents[2,3]))-(RawComponents[3,0]*RawComponents[1,3]*RawComponents[2,1])))+
         (RawComponents[0,3]*(((((-(RawComponents[1,0]*RawComponents[2,1]*RawComponents[3,2]))+(RawComponents[1,0]*RawComponents[2,2]*RawComponents[3,1])+(RawComponents[2,0]*RawComponents[1,1]*RawComponents[3,2]))-(RawComponents[2,0]*RawComponents[1,2]*RawComponents[3,1]))-(RawComponents[3,0]*RawComponents[1,1]*RawComponents[2,2]))+(RawComponents[3,0]*RawComponents[1,2]*RawComponents[2,1])));
end;

function TpvMatrix4x4D.SimpleInverse:TpvMatrix4x4D;
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
 result.RawComponents[3,0]:=-PpvVector3D(pointer(@RawComponents[3,0]))^.Dot(TpvVector3D.Create(RawComponents[0,0],RawComponents[0,1],RawComponents[0,2]));
 result.RawComponents[3,1]:=-PpvVector3D(pointer(@RawComponents[3,0]))^.Dot(TpvVector3D.Create(RawComponents[1,0],RawComponents[1,1],RawComponents[1,2]));
 result.RawComponents[3,2]:=-PpvVector3D(pointer(@RawComponents[3,0]))^.Dot(TpvVector3D.Create(RawComponents[2,0],RawComponents[2,1],RawComponents[2,2]));
 result.RawComponents[3,3]:=RawComponents[3,3];
end;

function TpvMatrix4x4D.Inverse:TpvMatrix4x4D;
var t0,t4,t8,t12,d:TpvDouble;
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

function TpvMatrix4x4D.Adjugate:TpvMatrix4x4D;
begin
{result.RawVectors[0]:=RawVectors[1].Cross(RawVectors[2]);
 result.RawVectors[1]:=RawVectors[2].Cross(RawVectors[0]);
 result.RawVectors[2]:=RawVectors[0].Cross(RawVectors[1]);}
 result.RawComponents[0,0]:=(RawComponents[1,1]*RawComponents[2,2])-(RawComponents[1,2]*RawComponents[2,1]);
 result.RawComponents[0,1]:=(RawComponents[1,2]*RawComponents[2,0])-(RawComponents[1,0]*RawComponents[2,2]);
 result.RawComponents[0,2]:=(RawComponents[1,0]*RawComponents[2,1])-(RawComponents[1,1]*RawComponents[2,0]);
 result.RawComponents[0,3]:=0.0;
 result.RawComponents[1,0]:=(RawComponents[0,2]*RawComponents[2,1])-(RawComponents[0,1]*RawComponents[2,2]);
 result.RawComponents[1,1]:=(RawComponents[0,0]*RawComponents[2,2])-(RawComponents[0,2]*RawComponents[2,0]);
 result.RawComponents[1,2]:=(RawComponents[0,1]*RawComponents[2,0])-(RawComponents[0,0]*RawComponents[2,1]);
 result.RawComponents[1,3]:=0.0;
 result.RawComponents[2,0]:=(RawComponents[0,1]*RawComponents[1,2])-(RawComponents[0,2]*RawComponents[1,1]);
 result.RawComponents[2,1]:=(RawComponents[0,2]*RawComponents[1,0])-(RawComponents[0,0]*RawComponents[1,2]);
 result.RawComponents[2,2]:=(RawComponents[0,0]*RawComponents[1,1])-(RawComponents[0,1]*RawComponents[1,0]);
 result.RawComponents[2,3]:=0.0;
 result.RawComponents[3,0]:=0.0;
 result.RawComponents[3,1]:=0.0;
 result.RawComponents[3,2]:=0.0;
 result.RawComponents[3,3]:=0.0;
end;

function TpvMatrix4x4D.ToMatrix4x4:TpvMatrix4x4;
begin
 result.RawComponents[0,0]:=RawComponents[0,0];
 result.RawComponents[0,1]:=RawComponents[0,1];
 result.RawComponents[0,2]:=RawComponents[0,2];
 result.RawComponents[0,3]:=RawComponents[0,3];
 result.RawComponents[1,0]:=RawComponents[1,0];
 result.RawComponents[1,1]:=RawComponents[1,1];
 result.RawComponents[1,2]:=RawComponents[1,2];
 result.RawComponents[1,3]:=RawComponents[1,3];
 result.RawComponents[2,0]:=RawComponents[2,0];
 result.RawComponents[2,1]:=RawComponents[2,1];
 result.RawComponents[2,2]:=RawComponents[2,2];
 result.RawComponents[2,3]:=RawComponents[2,3];
 result.RawComponents[3,0]:=RawComponents[3,0];
 result.RawComponents[3,1]:=RawComponents[3,1];
 result.RawComponents[3,2]:=RawComponents[3,2];
 result.RawComponents[3,3]:=RawComponents[3,3];
end;

function TpvMatrix4x4D.ToQuaternionD:TpvQuaternionD;
var t,s:TpvDouble;
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
 t:=sqrt(sqr(result.x)+sqr(result.y)+sqr(result.z)+sqr(result.w));
 if t>0.0 then begin
  result.x:=result.x/t;
  result.y:=result.y/t;
  result.z:=result.z/t;
  result.w:=result.w/t;
 end;
end;

function TpvMatrix4x4D.ToDoubleSingleFloatingPointMatrix4x4:TpvMatrix4x4;
begin

 // Right vector / Tangent
 result.RawComponents[0,0]:=RawComponents[0,0];
 result.RawComponents[0,1]:=RawComponents[0,1];
 result.RawComponents[0,2]:=RawComponents[0,2];

 // Up vector / Bitangent
 result.RawComponents[1,0]:=RawComponents[1,0];
 result.RawComponents[1,1]:=RawComponents[1,1];
 result.RawComponents[1,2]:=RawComponents[1,2];

 // Forward vector / Normal
 result.RawComponents[2,0]:=RawComponents[2,0];
 result.RawComponents[2,1]:=RawComponents[2,1];
 result.RawComponents[2,2]:=RawComponents[2,2];

 // Translation
 SplitDouble(RawComponents[3,0],result.RawComponents[3,0],result.RawComponents[0,3]);
 SplitDouble(RawComponents[3,1],result.RawComponents[3,1],result.RawComponents[1,3]);
 SplitDouble(RawComponents[3,2],result.RawComponents[3,2],result.RawComponents[2,3]);

 // Set the last column and row
 result.RawComponents[3,3]:=-RawComponents[3,3]; // For to signaling the matrix as a double single floating point matrix

end;

function TpvMatrix4x4D.Decompose:TpvDecomposedMatrix4x4D;
var LocalMatrix,PerspectiveMatrix:TpvMatrix4x4D;
    BasisMatrix:TpvMatrix3x3D;
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

  result.Perspective:=TpvVector4D.Create(0.0,0.0,0.0,1.0);
  result.Translation:=TpvVector3D.Create(0.0,0.0,0.0);
  result.Scale:=TpvVector3D.Create(1.0,1.0,1.0);
  result.Skew:=TpvVector3D.Create(0.0,0.0,0.0);
  result.Rotation:=TpvQuaternionD.Create(0.0,0.0,0.0,1.0);

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

    result.Perspective:=PerspectiveMatrix.Inverse.Transpose*TpvVector4D.Create(LocalMatrix.RawComponents[0,3],
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
   LocalMatrix.Translation.xyz:=TpvVector3D.Create(0.0,0.0,0.0);

   BasisMatrix.RawComponents[0,0]:=RawComponents[0,0];
   BasisMatrix.RawComponents[0,1]:=RawComponents[0,1];
   BasisMatrix.RawComponents[0,2]:=RawComponents[0,2];
   BasisMatrix.RawComponents[1,0]:=RawComponents[1,0];
   BasisMatrix.RawComponents[1,1]:=RawComponents[1,1];
   BasisMatrix.RawComponents[1,2]:=RawComponents[1,2];
   BasisMatrix.RawComponents[2,0]:=RawComponents[2,0];
   BasisMatrix.RawComponents[2,1]:=RawComponents[2,1];
   BasisMatrix.RawComponents[2,2]:=RawComponents[2,2];

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

   result.Skew.y:=result.Skew.y/result.Scale.z;
   result.Skew.z:=result.Skew.z/result.Scale.z;

   if BasisMatrix.Right.Dot(BasisMatrix.Up.Cross(BasisMatrix.Forwards))<0.0 then begin
    result.Scale.x:=-result.Scale.x;
    BasisMatrix:=-BasisMatrix;
   end;

   result.Rotation:=BasisMatrix.ToQuaternionD;

   result.Valid:=true;

  end;

 end;

end;

function TpvMatrix4x4D.Normalize:TpvMatrix4x4D;
begin
 result.Right.xyz:=Right.xyz.Normalize;
 result.RawComponents[0,3]:=RawComponents[0,3];
 result.Up.xyz:=Up.xyz.Normalize;
 result.RawComponents[1,3]:=RawComponents[1,3];
 result.Forwards.xyz:=Forwards.xyz.Normalize;
 result.RawComponents[2,3]:=RawComponents[2,3];
 result.Translation:=Translation;
end;

function TpvMatrix4x4D.OrthoNormalize:TpvMatrix4x4D;
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

function TpvMatrix4x4D.RobustOrthoNormalize(const Tolerance:TpvDouble):TpvMatrix4x4D;
var Bisector,Axis:TpvVector3D;
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

function TpvMatrix4x4D.SimpleLerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
var InvTime:TpvDouble;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  InvTime:=1.0-aTime;
  result.RawComponents[0,0]:=(RawComponents[0,0]*InvTime)+(aWith.RawComponents[0,0]*aTime);
  result.RawComponents[0,1]:=(RawComponents[0,1]*InvTime)+(aWith.RawComponents[0,1]*aTime);
  result.RawComponents[0,2]:=(RawComponents[0,2]*InvTime)+(aWith.RawComponents[0,2]*aTime);
  result.RawComponents[0,3]:=(RawComponents[0,3]*InvTime)+(aWith.RawComponents[0,3]*aTime);
  result.RawComponents[1,0]:=(RawComponents[1,0]*InvTime)+(aWith.RawComponents[1,0]*aTime);
  result.RawComponents[1,1]:=(RawComponents[1,1]*InvTime)+(aWith.RawComponents[1,1]*aTime);
  result.RawComponents[1,2]:=(RawComponents[1,2]*InvTime)+(aWith.RawComponents[1,2]*aTime);
  result.RawComponents[1,3]:=(RawComponents[1,3]*InvTime)+(aWith.RawComponents[1,3]*aTime);
  result.RawComponents[2,0]:=(RawComponents[2,0]*InvTime)+(aWith.RawComponents[2,0]*aTime);
  result.RawComponents[2,1]:=(RawComponents[2,1]*InvTime)+(aWith.RawComponents[2,1]*aTime);
  result.RawComponents[2,2]:=(RawComponents[2,2]*InvTime)+(aWith.RawComponents[2,2]*aTime);
  result.RawComponents[2,3]:=(RawComponents[2,3]*InvTime)+(aWith.RawComponents[2,3]*aTime);
  result.RawComponents[3,0]:=(RawComponents[3,0]*InvTime)+(aWith.RawComponents[3,0]*aTime);
  result.RawComponents[3,1]:=(RawComponents[3,1]*InvTime)+(aWith.RawComponents[3,1]*aTime);
  result.RawComponents[3,2]:=(RawComponents[3,2]*InvTime)+(aWith.RawComponents[3,2]*aTime);
  result.RawComponents[3,3]:=(RawComponents[3,3]*InvTime)+(aWith.RawComponents[3,3]*aTime);
 end;
end;

function TpvMatrix4x4D.SimpleNlerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
var InvT:TpvDouble;
    Scale:TpvVector3D;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  Scale:=TpvVector3.Create(Right.xyz.Length,
                           Up.xyz.Length,
                           Forwards.xyz.Length).Lerp(TpvVector3.Create(aWith.Right.xyz.Length,
                                                                       aWith.Up.xyz.Length,
                                                                       aWith.Forwards.xyz.Length),
                                                     aTime);
  result:=TpvMatrix4x4D.Create(Normalize.ToQuaternionD.Nlerp(aWith.Normalize.ToQuaternionD,aTime));
  result.Right.xyz:=result.Right.xyz*Scale.x;
  result.Up.xyz:=result.Up.xyz*Scale.y;
  result.Forwards.xyz:=result.Forwards.xyz*Scale.z;
  result.Translation:=Translation.Lerp(aWith.Translation,aTime);
  InvT:=1.0-aTime;
  result.RawComponents[0,3]:=(RawComponents[0,3]*InvT)+(aWith.RawComponents[0,3]*aTime);
  result.RawComponents[1,3]:=(RawComponents[1,3]*InvT)+(aWith.RawComponents[1,3]*aTime);
  result.RawComponents[2,3]:=(RawComponents[2,3]*InvT)+(aWith.RawComponents[2,3]*aTime);
 end;
end;

function TpvMatrix4x4D.SimpleSlerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
var InvT:TpvDouble;
    Scale:TpvVector3D;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  Scale:=TpvVector3.Create(Right.xyz.Length,
                           Up.xyz.Length,
                           Forwards.xyz.Length).Lerp(TpvVector3.Create(aWith.Right.xyz.Length,
                                                                       aWith.Up.xyz.Length,
                                                                       aWith.Forwards.xyz.Length),
                                                     aTime);
  result:=TpvMatrix4x4D.Create(Normalize.ToQuaternionD.Slerp(aWith.Normalize.ToQuaternionD,aTime));
  result.Right.xyz:=result.Right.xyz*Scale.x;
  result.Up.xyz:=result.Up.xyz*Scale.y;
  result.Forwards.xyz:=result.Forwards.xyz*Scale.z;
  result.Translation:=Translation.Lerp(aWith.Translation,aTime);
  InvT:=1.0-aTime;
  result.RawComponents[0,3]:=(RawComponents[0,3]*InvT)+(aWith.RawComponents[0,3]*aTime);
  result.RawComponents[1,3]:=(RawComponents[1,3]*InvT)+(aWith.RawComponents[1,3]*aTime);
  result.RawComponents[2,3]:=(RawComponents[2,3]*InvT)+(aWith.RawComponents[2,3]*aTime);
 end;
end;

function TpvMatrix4x4D.SimpleElerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
var InvT:TpvDouble;
    Scale:TpvVector3D;
begin
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  Scale:=TpvVector3.Create(Right.xyz.Length,
                           Up.xyz.Length,
                           Forwards.xyz.Length).Lerp(TpvVector3.Create(aWith.Right.xyz.Length,
                                                                       aWith.Up.xyz.Length,
                                                                       aWith.Forwards.xyz.Length),
                                                     aTime);
  result:=TpvMatrix4x4D.Create(Normalize.ToQuaternionD.Elerp(aWith.Normalize.ToQuaternionD,aTime));
  result.Right.xyz:=result.Right.xyz*Scale.x;
  result.Up.xyz:=result.Up.xyz*Scale.y;
  result.Forwards.xyz:=result.Forwards.xyz*Scale.z;
  result.Translation:=Translation.Lerp(aWith.Translation,aTime);
  InvT:=1.0-aTime;
  result.RawComponents[0,3]:=(RawComponents[0,3]*InvT)+(aWith.RawComponents[0,3]*aTime);
  result.RawComponents[1,3]:=(RawComponents[1,3]*InvT)+(aWith.RawComponents[1,3]*aTime);
  result.RawComponents[2,3]:=(RawComponents[2,3]*InvT)+(aWith.RawComponents[2,3]*aTime);
 end;
end;

function TpvMatrix4x4D.SimpleSqlerp(const aB,aC,aD:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
begin
 result:=SimpleSlerp(aD,aTime).SimpleSlerp(aB.SimpleSlerp(aC,aTime),(2.0*aTime)*(1.0-aTime));
end;

function TpvMatrix4x4D.Lerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
var InverseTime:TpvDouble;
begin 
 if aTime<=0.0 then begin
  result:=self;
 end else if aTime>=1.0 then begin
  result:=aWith;
 end else begin
  InverseTime:=1.0-aTime;
  result.RawComponents[0,0]:=(RawComponents[0,0]*InverseTime)+(aWith.RawComponents[0,0]*aTime);
  result.RawComponents[0,1]:=(RawComponents[0,1]*InverseTime)+(aWith.RawComponents[0,1]*aTime);
  result.RawComponents[0,2]:=(RawComponents[0,2]*InverseTime)+(aWith.RawComponents[0,2]*aTime);
  result.RawComponents[0,3]:=(RawComponents[0,3]*InverseTime)+(aWith.RawComponents[0,3]*aTime);
  result.RawComponents[1,0]:=(RawComponents[1,0]*InverseTime)+(aWith.RawComponents[1,0]*aTime);
  result.RawComponents[1,1]:=(RawComponents[1,1]*InverseTime)+(aWith.RawComponents[1,1]*aTime);
  result.RawComponents[1,2]:=(RawComponents[1,2]*InverseTime)+(aWith.RawComponents[1,2]*aTime);
  result.RawComponents[1,3]:=(RawComponents[1,3]*InverseTime)+(aWith.RawComponents[1,3]*aTime);
  result.RawComponents[2,0]:=(RawComponents[2,0]*InverseTime)+(aWith.RawComponents[2,0]*aTime);
  result.RawComponents[2,1]:=(RawComponents[2,1]*InverseTime)+(aWith.RawComponents[2,1]*aTime);
  result.RawComponents[2,2]:=(RawComponents[2,2]*InverseTime)+(aWith.RawComponents[2,2]*aTime);
  result.RawComponents[2,3]:=(RawComponents[2,3]*InverseTime)+(aWith.RawComponents[2,3]*aTime);
  result.RawComponents[3,0]:=(RawComponents[3,0]*InverseTime)+(aWith.RawComponents[3,0]*aTime);
  result.RawComponents[3,1]:=(RawComponents[3,1]*InverseTime)+(aWith.RawComponents[3,1]*aTime);
  result.RawComponents[3,2]:=(RawComponents[3,2]*InverseTime)+(aWith.RawComponents[3,2]*aTime);
  result.RawComponents[3,3]:=(RawComponents[3,3]*InverseTime)+(aWith.RawComponents[3,3]*aTime);
 end;
end;

function TpvMatrix4x4D.Nlerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
begin
 result:=TpvMatrix4x4D.Create(Decompose.Nlerp(aWith.Decompose,aTime));
end;

function TpvMatrix4x4D.Slerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
begin
 result:=TpvMatrix4x4D.Create(Decompose.Slerp(aWith.Decompose,aTime));
end;

function TpvMatrix4x4D.Elerp(const aWith:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
begin
 result:=TpvMatrix4x4D.Create(Decompose.Elerp(aWith.Decompose,aTime));
end;

function TpvMatrix4x4D.Sqlerp(const aB,aC,aD:TpvMatrix4x4D;const aTime:TpvDouble):TpvMatrix4x4D;
begin
 result:=TpvMatrix4x4D.Create(Decompose.Sqlerp(aB.Decompose,aC.Decompose,aD.Decompose,aTime));
end;

constructor TpvTransform3D.Create(const aPosition:TpvVector3D;const aOrientation:TpvQuaternionD;const aScale:TpvVector3D);
begin
 Position:=aPosition;
 Orientation:=aOrientation;
 Scale:=aScale;
end;

constructor TpvTransform3D.Create(const aPosition:TpvVector3D;const aOrientation:TpvQuaternionD);
begin
 Position:=aPosition;
 Orientation:=aOrientation;
 Scale:=TpvVector3D.Create(1.0,1.0,1.0);
end;

constructor TpvTransform3D.Create(const aPosition:TpvVector3D);
begin
 Position:=aPosition;
 Orientation:=TpvQuaternionD.Create(0.0,0.0,0.0,1.0);
 Scale:=TpvVector3D.Create(1.0,1.0,1.0);
end;

constructor TpvTransform3D.Create(const aFrom:TpvMatrix4x4);
begin
 Position:=aFrom.Translation.xyz;
 Orientation:=aFrom.ToQuaternion;
 Scale.x:=aFrom.Right.xyz.Length;
 Scale.y:=aFrom.Up.xyz.Length;
 Scale.z:=aFrom.Forwards.xyz.Length;
end;

constructor TpvTransform3D.Create(const aFrom:TpvMatrix4x4D);
begin
 Position:=aFrom.Translation.xyz;
 Orientation:=aFrom.ToQuaternionD;
 Scale.x:=aFrom.Right.xyz.Length;
 Scale.y:=aFrom.Up.xyz.Length;
 Scale.z:=aFrom.Forwards.xyz.Length;
end;

class operator TpvTransform3D.Implicit(const aFrom:TpvMatrix4x4):TpvTransform3D;
begin
 result:=TpvTransform3D.Create(aFrom);
end;

class operator TpvTransform3D.Implicit(const aFrom:TpvMatrix4x4D):TpvTransform3D;
begin
 result:=TpvTransform3D.Create(aFrom);
end;

class operator TpvTransform3D.Implicit(const aFrom:TpvTransform3D):TpvMatrix4x4;
begin
 result:=TpvMatrix4x4.CreateFromQuaternion(aFrom.Orientation.ToQuaternion);
 result.Right.xyz:=result.Right.xyz*aFrom.Scale.x;
 result.Up.xyz:=result.Up.xyz*aFrom.Scale.y;
 result.Forwards.xyz:=result.Forwards.xyz*aFrom.Scale.z;
 result.Translation.xyz:=aFrom.Position;
end;

class operator TpvTransform3D.Implicit(const aFrom:TpvTransform3D):TpvMatrix4x4D;
begin
 result:=TpvMatrix4x4D.Create(aFrom.Orientation);
 result.Right.xyz:=result.Right.xyz*aFrom.Scale.x;
 result.Up.xyz:=result.Up.xyz*aFrom.Scale.y;
 result.Forwards.xyz:=result.Forwards.xyz*aFrom.Scale.z;
 result.Translation.xyz:=aFrom.Position;
end;

class operator TpvTransform3D.Explicit(const aFrom:TpvMatrix4x4):TpvTransform3D;
begin
 result:=TpvTransform3D.Create(aFrom);
end;

class operator TpvTransform3D.Explicit(const aFrom:TpvMatrix4x4D):TpvTransform3D;
begin
 result:=TpvTransform3D.Create(aFrom);
end;

class operator TpvTransform3D.Explicit(const aFrom:TpvTransform3D):TpvMatrix4x4;
begin
 result:=TpvMatrix4x4.CreateFromQuaternion(aFrom.Orientation.ToQuaternion);
 result.Right.xyz:=result.Right.xyz*aFrom.Scale.x;
 result.Up.xyz:=result.Up.xyz*aFrom.Scale.y;
 result.Forwards.xyz:=result.Forwards.xyz*aFrom.Scale.z;
 result.Translation.xyz:=aFrom.Position;
end;

class operator TpvTransform3D.Explicit(const aFrom:TpvTransform3D):TpvMatrix4x4D;
begin
 result:=TpvMatrix4x4D.Create(aFrom.Orientation);
 result.Right.xyz:=result.Right.xyz*aFrom.Scale.x;
 result.Up.xyz:=result.Up.xyz*aFrom.Scale.y;
 result.Forwards.xyz:=result.Forwards.xyz*aFrom.Scale.z;
 result.Translation.xyz:=aFrom.Position;
end;

class operator TpvTransform3D.Equal(const aLeft,aRight:TpvTransform3D):boolean;
begin
 result:=(aLeft.Position=aRight.Position) and
         (aLeft.Orientation=aRight.Orientation) and
         (aLeft.Scale=aRight.Scale);
end;

class operator TpvTransform3D.NotEqual(const aLeft,aRight:TpvTransform3D):boolean;
begin
 result:=(aLeft.Position<>aRight.Position) or
         (aLeft.Orientation<>aRight.Orientation) or
         (aLeft.Scale<>aRight.Scale);
end;

function TpvTransform3D.Lerp(const aWith:TpvTransform3D;const aTime:TpvDouble):TpvTransform3D;
begin
 result.Position:=Position.Lerp(aWith.Position,aTime);
 result.Orientation:=Orientation.Lerp(aWith.Orientation,aTime);
 result.Scale:=Scale.Lerp(aWith.Scale,aTime);
end;

function TpvTransform3D.Nlerp(const aWith:TpvTransform3D;const aTime:TpvDouble):TpvTransform3D;
begin
 result.Position:=Position.Lerp(aWith.Position,aTime);
 result.Orientation:=Orientation.Nlerp(aWith.Orientation,aTime);
 result.Scale:=Scale.Lerp(aWith.Scale,aTime);
end;

function TpvTransform3D.Slerp(const aWith:TpvTransform3D;const aTime:TpvDouble):TpvTransform3D;
begin
 result.Position:=Position.Lerp(aWith.Position,aTime);
 result.Orientation:=Orientation.Slerp(aWith.Orientation,aTime);
 result.Scale:=Scale.Lerp(aWith.Scale,aTime);
end;

function TpvTransform3D.Elerp(const aWith:TpvTransform3D;const aTime:TpvDouble):TpvTransform3D;
begin
 result.Position:=Position.Lerp(aWith.Position,aTime);
 result.Orientation:=Orientation.Elerp(aWith.Orientation,aTime);
 result.Scale:=Scale.Lerp(aWith.Scale,aTime);
end;

function TpvTransform3D.Sqlerp(const aB,aC,aD:TpvTransform3D;const aTime:TpvDouble):TpvTransform3D;
begin
 result.Position:=Position.Lerp(aB.Position,aTime);
 result.Orientation:=Orientation.Sqlerp(aB.Orientation,aC.Orientation,aD.Orientation,aTime);
 result.Scale:=Scale.Lerp(aB.Scale,aTime);
end;

end.
