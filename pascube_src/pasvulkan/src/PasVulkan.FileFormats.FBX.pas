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
unit PasVulkan.FileFormats.FBX;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
 {$warn duplicate_ctor_dtor off}
{$endif}

{$scopedenums on}

interface

uses SysUtils,Classes,Math,StrUtils,PasDblStrUtils,Generics.Collections,TypInfo,Variants,PasVulkan.Types;

type EFBX=class(Exception);

     TpvFBXLoader=class;

     PpvFBXScalar=^TpvFBXScalar;
     TpvFBXScalar=TpvDouble;

     PpvFBXSizeInt=^TpvFBXSizeInt;
     TpvFBXSizeInt={$ifdef fpc}SizeInt{$else}NativeInt{$endif};

     PpvFBXPtrInt=^TpvFBXPtrInt;
     TpvFBXPtrInt={$ifdef fpc}PtrInt{$else}NativeInt{$endif};

     PpvFBXPtrUInt=^TpvFBXPtrUInt;
     TpvFBXPtrUInt={$ifdef fpc}PtrUInt{$else}NativeUInt{$endif};

     TpvFBXBytes=array of TpvUInt8;

     TpvFBXString=RawByteString;

     TpvFBXBooleanArray=array of Boolean;

     TpvFBXInt8Array=array of TpvInt8;

     TpvFBXInt16Array=array of TpvInt16;

     TpvFBXUInt32Array=array of TpvUInt32;

     TpvFBXInt32Array=array of TpvInt32;

     TpvFBXInt64Array=array of TpvInt64;

     TpvFBXFloat32Array=array of TpvFloat;

     TpvFBXFloat64Array=array of TpvDouble;

     TpvFBXInt64List=class(TList<TpvInt64>);

     TpvFBXFloat64List=class(TList<TpvDouble>);

     PpvFBXVector2=^TpvFBXVector2;
     TpvFBXVector2=record
      public
       constructor Create(const pX:TpvFBXScalar); overload;
       constructor Create(const pX,pY:TpvFBXScalar); overload;
       class operator Implicit(const a:TpvFBXScalar):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Explicit(const a:TpvFBXScalar):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Equal(const a,b:TpvFBXVector2):boolean; {$ifdef caninline}inline;{$endif}
       class operator NotEqual(const a,b:TpvFBXVector2):boolean; {$ifdef caninline}inline;{$endif}
       class operator Inc(const a:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Dec(const a:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Add(const a,b:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Add(const a:TpvFBXVector2;const b:TpvFBXScalar):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Add(const a:TpvFBXScalar;const b:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Subtract(const a,b:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Subtract(const a:TpvFBXVector2;const b:TpvFBXScalar):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Subtract(const a:TpvFBXScalar;const b:TpvFBXVector2): TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Multiply(const a,b:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Multiply(const a:TpvFBXVector2;const b:TpvFBXScalar):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Multiply(const a:TpvFBXScalar;const b:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Divide(const a,b:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Divide(const a:TpvFBXVector2;const b:TpvFBXScalar):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Divide(const a:TpvFBXScalar;const b:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator IntDivide(const a,b:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator IntDivide(const a:TpvFBXVector2;const b:TpvFBXScalar):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator IntDivide(const a:TpvFBXScalar;const b:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Modulus(const a,b:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Modulus(const a:TpvFBXVector2;const b:TpvFBXScalar):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Modulus(const a:TpvFBXScalar;const b:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Negative(const a:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       class operator Positive(const a:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
      private
      private
       function GetComponent(const pIndex:TpvInt32):TpvFBXScalar; {$ifdef caninline}inline;{$endif}
       procedure SetComponent(const pIndex:TpvInt32;const pValue:TpvFBXScalar); {$ifdef caninline}inline;{$endif}
      public
       function Perpendicular:TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       function Length:TpvFBXScalar; {$ifdef caninline}inline;{$endif}
       function SquaredLength:TpvFBXScalar; {$ifdef caninline}inline;{$endif}
       function Normalize:TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       function DistanceTo(const b:TpvFBXVector2):TpvFBXScalar; {$ifdef caninline}inline;{$endif}
       function Dot(const b:TpvFBXVector2):TpvFBXScalar; {$ifdef caninline}inline;{$endif}
       function Cross(const b:TpvFBXVector2):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       function Lerp(const b:TpvFBXVector2;const t:TpvFBXScalar):TpvFBXVector2; {$ifdef caninline}inline;{$endif}
       function Angle(const b,c:TpvFBXVector2):TpvFBXScalar; {$ifdef caninline}inline;{$endif}
       function Rotate(const Angle:TpvFBXScalar):TpvFBXVector2; overload; {$ifdef caninline}inline;{$endif}
       function Rotate(const Center:TpvFBXVector2;const Angle:TpvFBXScalar):TpvFBXVector2; overload; {$ifdef caninline}inline;{$endif}
       property Components[const pIndex:TpvInt32]:TpvFBXScalar read GetComponent write SetComponent; default;
       case TpvUInt8 of
        0:(RawComponents:array[0..1] of TpvFBXScalar);
        1:(x,y:TpvFBXScalar);
        2:(u,v:TpvFBXScalar);
        3:(s,t:TpvFBXScalar);
        4:(r,g:TpvFBXScalar);
     end;

     PpvFBXVector3=^TpvFBXVector3;
     TpvFBXVector3=record
      public
       constructor Create(const pX:TpvFBXScalar); overload;
       constructor Create(const pX,pY,pZ:TpvFBXScalar); overload;
       constructor Create(const pXY:TpvFBXVector2;const pZ:TpvFBXScalar=0.0); overload;
       class operator Implicit(const a:TpvFBXScalar):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator Explicit(const a:TpvFBXScalar):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator Equal(const a,b:TpvFBXVector3):boolean; {$ifdef caninline}inline;{$endif}
       class operator NotEqual(const a,b:TpvFBXVector3):boolean; {$ifdef caninline}inline;{$endif}
       class operator Inc({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Dec({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector3):TpvFBXVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Add(const a:TpvFBXVector3;const b:TpvFBXScalar):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator Add(const a:TpvFBXScalar;const b:TpvFBXVector3):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector3):TpvFBXVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Subtract(const a:TpvFBXVector3;const b:TpvFBXScalar):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator Subtract(const a:TpvFBXScalar;const b:TpvFBXVector3):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector3):TpvFBXVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Multiply(const a:TpvFBXVector3;const b:TpvFBXScalar):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator Multiply(const a:TpvFBXScalar;const b:TpvFBXVector3):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector3):TpvFBXVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Divide(const a:TpvFBXVector3;const b:TpvFBXScalar):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator Divide(const a:TpvFBXScalar;const b:TpvFBXVector3):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector3):TpvFBXVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator IntDivide(const a:TpvFBXVector3;const b:TpvFBXScalar):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator IntDivide(const a:TpvFBXScalar;const b:TpvFBXVector3):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator Modulus(const a,b:TpvFBXVector3):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator Modulus(const a:TpvFBXVector3;const b:TpvFBXScalar):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator Modulus(const a:TpvFBXScalar;const b:TpvFBXVector3):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       class operator Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Positive(const a:TpvFBXVector3):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
      private
      private
       function GetComponent(const pIndex:TpvInt32):TpvFBXScalar; {$ifdef caninline}inline;{$endif}
       procedure SetComponent(const pIndex:TpvInt32;const pValue:TpvFBXScalar); {$ifdef caninline}inline;{$endif}
      public
       function Flip:TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       function Perpendicular:TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       function OneUnitOrthogonalVector:TpvFBXVector3;
       function Length:TpvFBXScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function SquaredLength:TpvFBXScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function Normalize:TpvFBXVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function DistanceTo({$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector3):TpvFBXScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function Abs:TpvFBXVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function Dot({$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector3):TpvFBXScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function AngleTo(const b:TpvFBXVector3):TpvFBXScalar; {$ifdef caninline}inline;{$endif}
       function Cross({$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector3):TpvFBXVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function Lerp(const b:TpvFBXVector3;const t:TpvFBXScalar):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       function Angle(const b,c:TpvFBXVector3):TpvFBXScalar; {$ifdef caninline}inline;{$endif}
       function RotateX(const Angle:TpvFBXScalar):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       function RotateY(const Angle:TpvFBXScalar):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       function RotateZ(const Angle:TpvFBXScalar):TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       function ProjectToBounds(const MinVector,MaxVector:TpvFBXVector3):TpvFBXScalar;
       property Components[const pIndex:TpvInt32]:TpvFBXScalar read GetComponent write SetComponent; default;
       case TpvUInt8 of
        0:(RawComponents:array[0..2] of TpvFBXScalar);
        1:(x,y,z:TpvFBXScalar);
        2:(r,g,b:TpvFBXScalar);
        3:(s,t,p:TpvFBXScalar);
        4:(Pitch,Yaw,Roll:TpvFBXScalar);
        6:(Vector2:TpvFBXVector2);
     end;

     PpvFBXVector4=^TpvFBXVector4;
     TpvFBXVector4=record
      public
       constructor Create(const pX:TpvFBXScalar); overload;
       constructor Create(const pX,pY,pZ,pW:TpvFBXScalar); overload;
       constructor Create(const pXY:TpvFBXVector2;const pZ:TpvFBXScalar=0.0;const pW:TpvFBXScalar=1.0); overload;
       constructor Create(const pXYZ:TpvFBXVector3;const pW:TpvFBXScalar=1.0); overload;
       class operator Implicit(const a:TpvFBXScalar):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator Explicit(const a:TpvFBXScalar):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator Equal(const a,b:TpvFBXVector4):boolean; {$ifdef caninline}inline;{$endif}
       class operator NotEqual(const a,b:TpvFBXVector4):boolean; {$ifdef caninline}inline;{$endif}
       class operator Inc({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Dec({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector4):TpvFBXVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Add(const a:TpvFBXVector4;const b:TpvFBXScalar):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator Add(const a:TpvFBXScalar;const b:TpvFBXVector4):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector4):TpvFBXVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Subtract(const a:TpvFBXVector4;const b:TpvFBXScalar):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator Subtract(const a:TpvFBXScalar;const b:TpvFBXVector4): TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector4):TpvFBXVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Multiply(const a:TpvFBXVector4;const b:TpvFBXScalar):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator Multiply(const a:TpvFBXScalar;const b:TpvFBXVector4):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector4):TpvFBXVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Divide(const a:TpvFBXVector4;const b:TpvFBXScalar):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator Divide(const a:TpvFBXScalar;const b:TpvFBXVector4):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector4):TpvFBXVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator IntDivide(const a:TpvFBXVector4;const b:TpvFBXScalar):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator IntDivide(const a:TpvFBXScalar;const b:TpvFBXVector4):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator Modulus(const a,b:TpvFBXVector4):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator Modulus(const a:TpvFBXVector4;const b:TpvFBXScalar):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator Modulus(const a:TpvFBXScalar;const b:TpvFBXVector4):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       class operator Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Positive(const a:TpvFBXVector4):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
      private
      private
       function GetComponent(const pIndex:TpvInt32):TpvFBXScalar; {$ifdef caninline}inline;{$endif}
       procedure SetComponent(const pIndex:TpvInt32;const pValue:TpvFBXScalar); {$ifdef caninline}inline;{$endif}
      public
       function Flip:TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       function Perpendicular:TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       function Length:TpvFBXScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function SquaredLength:TpvFBXScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function Normalize:TpvFBXVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function DistanceTo({$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector4):TpvFBXScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function Abs:TpvFBXVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function Dot({$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector4):TpvFBXScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function AngleTo(const b:TpvFBXVector4):TpvFBXScalar; {$ifdef caninline}inline;{$endif}
       function Cross({$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector4):TpvFBXVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function Lerp(const b:TpvFBXVector4;const t:TpvFBXScalar):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       function Angle(const b,c:TpvFBXVector4):TpvFBXScalar; {$ifdef caninline}inline;{$endif}
       function RotateX(const Angle:TpvFBXScalar):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       function RotateY(const Angle:TpvFBXScalar):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       function RotateZ(const Angle:TpvFBXScalar):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       function Rotate(const Angle:TpvFBXScalar;const Axis:TpvFBXVector3):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       function ProjectToBounds(const MinVector,MaxVector:TpvFBXVector4):TpvFBXScalar;
      public
       property Components[const pIndex:TpvInt32]:TpvFBXScalar read GetComponent write SetComponent; default;
       case TpvUInt8 of
        0:(RawComponents:array[0..3] of TpvFBXScalar);
        1:(x,y,z,w:TpvFBXScalar);
        2:(r,g,b,a:TpvFBXScalar);
        3:(s,t,p,q:TpvFBXScalar);
        5:(Vector2:TpvFBXVector2);
        6:(Vector3:TpvFBXVector3);
     end;

     PpvFBXColor=^TpvFBXColor;
     TpvFBXColor=record
      private
       function GetComponent(const pIndex:TpvInt32):TpvDouble; inline;
       procedure SetComponent(const pIndex:TpvInt32;const pValue:TpvDouble); inline;
      public
       constructor Create(const pFrom:TpvFBXColor); overload;
       constructor Create(const pRed,pGreen,pBlue:TpvDouble;const pAlpha:TpvDouble=1.0); overload;
       constructor Create(const pArray:array of TpvDouble); overload;
       function ToString:TpvFBXString;
       property Components[const pIndex:TpvInt32]:TpvDouble read GetComponent write SetComponent; default;
       case TpvInt32 of
        0:(
         Red:TpvDouble;
         Green:TpvDouble;
         Blue:TpvDouble;
         Alpha:TpvDouble;
        );
        1:(
         RawComponents:array[0..3] of TpvDouble;
        );
        2:(
         Vector2:TpvFBXVector2;
        );
        3:(
         Vector3:TpvFBXVector3;
        );
        4:(
         Vector4:TpvFBXVector4;
        );
     end;

     PpvFBXMatrix4x4=^TpvFBXMatrix4x4;
     TpvFBXMatrix4x4=record
      public
//     constructor Create; overload;
       constructor Create(const pX:TpvFBXScalar); overload;
       constructor Create(const pXX,pXY,pXZ,pXW,pYX,pYY,pYZ,pYW,pZX,pZY,pZZ,pZW,pWX,pWY,pWZ,pWW:TpvFBXScalar); overload;
       constructor Create(const pX,pY,pZ,pW:TpvFBXVector4); overload;
       constructor CreateRotateX(const Angle:TpvFBXScalar);
       constructor CreateRotateY(const Angle:TpvFBXScalar);
       constructor CreateRotateZ(const Angle:TpvFBXScalar);
       constructor CreateRotate(const Angle:TpvFBXScalar;const Axis:TpvFBXVector3);
       constructor CreateRotation(const pMatrix:TpvFBXMatrix4x4); overload;
       constructor CreateScale(const sx,sy,sz:TpvFBXScalar); overload;
       constructor CreateScale(const pScale:TpvFBXVector3); overload;
       constructor CreateScale(const sx,sy,sz,sw:TpvFBXScalar); overload;
       constructor CreateScale(const pScale:TpvFBXVector4); overload;
       constructor CreateTranslation(const tx,ty,tz:TpvFBXScalar); overload;
       constructor CreateTranslation(const pTranslation:TpvFBXVector3); overload;
       constructor CreateTranslation(const tx,ty,tz,tw:TpvFBXScalar); overload;
       constructor CreateTranslation(const pTranslation:TpvFBXVector4); overload;
       constructor CreateTranslated(const pMatrix:TpvFBXMatrix4x4;pTranslation:TpvFBXVector3); overload;
       constructor CreateTranslated(const pMatrix:TpvFBXMatrix4x4;pTranslation:TpvFBXVector4); overload;
       constructor CreateFromToRotation(const FromDirection,ToDirection:TpvFBXVector3);
       constructor CreateConstruct(const pForwards,pUp:TpvFBXVector3);
       constructor CreateOuterProduct(const u,v:TpvFBXVector3);
       constructor CreateFrustum(const Left,Right,Bottom,Top,zNear,zFar:TpvFBXScalar);
       constructor CreateOrtho(const Left,Right,Bottom,Top,zNear,zFar:TpvFBXScalar);
       constructor CreateOrthoLH(const Left,Right,Bottom,Top,zNear,zFar:TpvFBXScalar);
       constructor CreateOrthoRH(const Left,Right,Bottom,Top,zNear,zFar:TpvFBXScalar);
       constructor CreateOrthoOffCenterLH(const Left,Right,Bottom,Top,zNear,zFar:TpvFBXScalar);
       constructor CreateOrthoOffCenterRH(const Left,Right,Bottom,Top,zNear,zFar:TpvFBXScalar);
       constructor CreatePerspective(const fovy,Aspect,zNear,zFar:TpvFBXScalar);
       constructor CreateLookAt(const Eye,Center,Up:TpvFBXVector3);
       constructor CreateFill(const Eye,RightVector,UpVector,ForwardVector:TpvFBXVector3);
       constructor CreateConstructX(const xAxis:TpvFBXVector3);
       constructor CreateConstructY(const yAxis:TpvFBXVector3);
       constructor CreateConstructZ(const zAxis:TpvFBXVector3);
       class operator Implicit({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Explicit({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Equal({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):boolean; {$ifdef caninline}inline;{$endif}
       class operator NotEqual({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):boolean; {$ifdef caninline}inline;{$endif}
       class operator Inc({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Dec({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Add({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXScalar):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Add({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Subtract({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXScalar):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Subtract({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4): TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXScalar):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector3):TpvFBXVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4):TpvFBXVector3; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector4):TpvFBXVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4):TpvFBXVector4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$ifdef caninline}inline;{$endif}
       class operator Divide({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXScalar):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Divide({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$ifdef caninline}inline;{$endif}
       class operator IntDivide({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXScalar):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator IntDivide({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Modulus({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$ifdef caninline}inline;{$endif}
       class operator Modulus({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXScalar):TpvFBXMatrix4x4; {$ifdef caninline}inline;{$endif}
       class operator Modulus({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$ifdef caninline}inline;{$endif}
       class operator Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       class operator Positive(const a:TpvFBXMatrix4x4):TpvFBXMatrix4x4; {$ifdef caninline}inline;{$endif}
      private
       function GetComponent(const pIndexA,pIndexB:TpvInt32):TpvFBXScalar; {$ifdef caninline}inline;{$endif}
       procedure SetComponent(const pIndexA,pIndexB:TpvInt32;const pValue:TpvFBXScalar); {$ifdef caninline}inline;{$endif}
       function GetColumn(const pIndex:TpvInt32):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       procedure SetColumn(const pIndex:TpvInt32;const pValue:TpvFBXVector4); {$ifdef caninline}inline;{$endif}
       function GetRow(const pIndex:TpvInt32):TpvFBXVector4; {$ifdef caninline}inline;{$endif}
       procedure SetRow(const pIndex:TpvInt32;const pValue:TpvFBXVector4); {$ifdef caninline}inline;{$endif}
      public
       function Determinant:TpvFBXScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function SimpleInverse:TpvFBXMatrix4x4; {$ifdef caninline}inline;{$endif}
       function Inverse:TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function Transpose:TpvFBXMatrix4x4; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
       function EulerAngles:TpvFBXVector3; {$ifdef caninline}inline;{$endif}
       function Normalize:TpvFBXMatrix4x4; {$ifdef caninline}inline;{$endif}
       function OrthoNormalize:TpvFBXMatrix4x4; {$ifdef caninline}inline;{$endif}
       function RobustOrthoNormalize(const Tolerance:TpvFBXScalar=1e-3):TpvFBXMatrix4x4; {$ifdef caninline}inline;{$endif}
       function ToRotation:TpvFBXMatrix4x4; {$ifdef caninline}inline;{$endif}
       function SimpleLerp(const b:TpvFBXMatrix4x4;const t:TpvFBXScalar):TpvFBXMatrix4x4; {$ifdef caninline}inline;{$endif}
       function MulInverse({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3; overload; {$ifdef caninline}inline;{$endif}
       function MulInverse({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4; overload; {$ifdef caninline}inline;{$endif}
       function MulInverted({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3; overload; {$ifdef caninline}inline;{$endif}
       function MulInverted({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4; overload; {$ifdef caninline}inline;{$endif}
       function MulBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3; overload; {$ifdef caninline}inline;{$endif}
       function MulBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4; overload; {$ifdef caninline}inline;{$endif}
       function MulTransposedBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3; overload; {$ifdef caninline}inline;{$endif}
       function MulTransposedBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4; overload; {$ifdef caninline}inline;{$endif}
       function MulHomogen({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3; overload; {$ifdef caninline}inline;{$endif}
       function MulHomogen({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4; overload; {$ifdef caninline}inline;{$endif}
       property Components[const pIndexA,pIndexB:TpvInt32]:TpvFBXScalar read GetComponent write SetComponent; default;
       property Columns[const pIndex:TpvInt32]:TpvFBXVector4 read GetColumn write SetColumn;
       property Rows[const pIndex:TpvInt32]:TpvFBXVector4 read GetRow write SetRow;
       case TpvInt32 of
        0:(RawComponents:array[0..3,0..3] of TpvFBXScalar);
        1:(LinearRawComponents:array[0..15] of TpvFBXScalar);
        2:(m00,m01,m02,m03,m10,m11,m12,m13,m20,m21,m22,m23,m30,m31,m32,m33:TpvFBXScalar);
        3:(Tangent,Bitangent,Normal,Translation:TpvFBXVector4);
        4:(Right,Up,Forwards,Offset:TpvFBXVector4);
     end;

     PpvFBXTime=^TpvFBXTime;
     TpvFBXTime=TpvInt64;

     PpvFBXTimeSpan=^TpvFBXTimeSpan;

     TpvFBXTimeSpan=record
      private
       function GetComponent(const pIndex:TpvInt32):TpvFBXTime; inline;
       procedure SetComponent(const pIndex:TpvInt32;const pValue:TpvFBXTime); inline;
      public
       constructor Create(const pFrom:TpvFBXTimeSpan); overload;
       constructor Create(const pStartTime,pEndTime:TpvFBXTime); overload;
       constructor Create(const pArray:array of TpvFBXTime); overload;
       function ToString:TpvFBXString;
       property Components[const pIndex:TpvInt32]:TpvFBXTime read GetComponent write SetComponent; default;
       case TpvInt32 of
        0:(
         StartTime:TpvFBXTime;
         EndTime:TpvFBXTime;
        );
        1:(
         RawComponents:array[0..1] of TpvFBXTime;
        );
     end;

     TpvFBXBaseObject=class(TPersistent)
      private
      public
       constructor Create; reintroduce; virtual;
       destructor Destroy; override;
     end;

     TpvFBXVector2Property=class(TpvFBXBaseObject)
      private
       fVector:TpvFBXVector2;
       function GetX:TpvDouble; inline;
       procedure SetX(const pValue:TpvDouble); inline;
       function GetY:TpvDouble; inline;
       procedure SetY(const pValue:TpvDouble); inline;
      public
       constructor Create; reintroduce; overload;
       constructor Create(const pFrom:TpvFBXVector2); reintroduce; overload;
       constructor Create(const pX,pY:TpvDouble); reintroduce; overload;
       constructor Create(const pArray:array of TpvDouble); reintroduce; overload;
       destructor Destroy; override;
       property Vector:TpvFBXVector2 read fVector write fVector;
      published
       property x:TpvDouble read GetX write SetX;
       property y:TpvDouble read GetY write SetY;
     end;

     TpvFBXVector3Property=class(TpvFBXBaseObject)
      private
       fVector:TpvFBXVector3;
       function GetX:TpvDouble; inline;
       procedure SetX(const pValue:TpvDouble); inline;
       function GetY:TpvDouble; inline;
       procedure SetY(const pValue:TpvDouble); inline;
       function GetZ:TpvDouble; inline;
       procedure SetZ(const pValue:TpvDouble); inline;
      public
       constructor Create; reintroduce; overload;
       constructor Create(const pFrom:TpvFBXVector3); reintroduce; overload;
       constructor Create(const pX,pY,pZ:TpvDouble); reintroduce; overload;
       constructor Create(const pArray:array of TpvDouble); reintroduce; overload;
       destructor Destroy; override;
       property Vector:TpvFBXVector3 read fVector write fVector;
      published
       property x:TpvDouble read GetX write SetX;
       property y:TpvDouble read GetY write SetY;
       property z:TpvDouble read GetZ write SetZ;
     end;

     TpvFBXVector4Property=class(TpvFBXBaseObject)
      private
       fVector:TpvFBXVector4;
       function GetX:TpvDouble; inline;
       procedure SetX(const pValue:TpvDouble); inline;
       function GetY:TpvDouble; inline;
       procedure SetY(const pValue:TpvDouble); inline;
       function GetZ:TpvDouble; inline;
       procedure SetZ(const pValue:TpvDouble); inline;
       function GetW:TpvDouble; inline;
       procedure SetW(const pValue:TpvDouble); inline;
      public
       constructor Create; reintroduce; overload;
       constructor Create(const pFrom:TpvFBXVector4); reintroduce; overload;
       constructor Create(const pX,pY,pZ,pW:TpvDouble); reintroduce; overload;
       constructor Create(const pArray:array of TpvDouble); reintroduce; overload;
       destructor Destroy; override;
       property Vector:TpvFBXVector4 read fVector write fVector;
      published
       property x:TpvDouble read GetX write SetX;
       property y:TpvDouble read GetY write SetY;
       property z:TpvDouble read GetZ write SetZ;
       property w:TpvDouble read GetW write SetW;
     end;

     TpvFBXColorProperty=class(TpvFBXBaseObject)
      private
       fColor:TpvFBXColor;
       function GetRed:TpvDouble; inline;
       procedure SetRed(const pValue:TpvDouble); inline;
       function GetGreen:TpvDouble; inline;
       procedure SetGreen(const pValue:TpvDouble); inline;
       function GetBlue:TpvDouble; inline;
       procedure SetBlue(const pValue:TpvDouble); inline;
       function GetAlpha:TpvDouble; inline;
       procedure SetAlpha(const pValue:TpvDouble); inline;
      public
       constructor Create; reintroduce; overload;
       constructor Create(const pFrom:TpvFBXColor); reintroduce; overload;
       constructor Create(const pRed,pGreen,pBlue:TpvDouble;const pAlpha:TpvDouble=1.0); reintroduce; overload;
       constructor Create(const pArray:array of TpvDouble); reintroduce; overload;
       destructor Destroy; override;
       property Color:TpvFBXColor read fColor write fColor;
      published
       property Red:TpvDouble read GetRed write SetRed;
       property Green:TpvDouble read GetGreen write SetGreen;
       property Blue:TpvDouble read GetBlue write SetBlue;
       property Alpha:TpvDouble read GetAlpha write SetAlpha;
       property r:TpvDouble read GetRed write SetRed;
       property g:TpvDouble read GetGreen write SetGreen;
       property b:TpvDouble read GetBlue write SetBlue;
       property a:TpvDouble read GetAlpha write SetAlpha;
     end;

     TpvFBXObject=class;

     TpvFBXProperty=class(TpvFBXBaseObject)
      private
       fBaseObject:TObject;
       fBaseName:TpvFBXString;
       fBasePropInfo:PPropInfo;
       fValue:Variant;
       fConnectedFrom:TpvFBXObject;
      public
       constructor Create(const pBaseObject:TObject=nil;const pBaseName:TpvFBXString='';const pBasePropInfo:PPropInfo=nil); reintroduce; overload;
       constructor Create(const pValue:Variant;const pBaseObject:TObject=nil;const pBaseName:TpvFBXString='';const pBasePropInfo:PPropInfo=nil); reintroduce; overload;
       destructor Destroy; override;
       function GetValue:Variant;
       procedure SetValue(const pValue:Variant);
       property Value:Variant read GetValue write SetValue;
       property ConnectedFrom:TpvFBXObject read fConnectedFrom write fConnectedFrom;
     end;

     TpvFBXPropertyList=class(TObjectList<TpvFBXProperty>);

     TpvFBXPropertyNameMap=class(TDictionary<TpvFBXString,TpvFBXProperty>);

     TpvFBXElement=class;

     TpvFBXNode=class;

     TpvFBXNodeAttribute=class;

     TpvFBXObjects=array of TpvFBXObject;

     TpvFBXObjectList=class(TObjectList<TpvFBXObject>);

     TpvFBXNodeAttributeList=class(TObjectList<TpvFBXNodeAttribute>);

     TpvFBXObject=class(TpvFBXBaseObject)
      private
       fLoader:TpvFBXLoader;
       fElement:TpvFBXElement;
       fID:TpvInt64;
       fName:TpvFBXString;
       fType_:TpvFBXString;
       fProperties:TpvFBXPropertyList;
       fPropertyNameMap:TpvFBXPropertyNameMap;
       fConnectedFrom:TpvFBXObjectList;
       fNodeAttributes:TpvFBXNodeAttributeList;
       fReference:TpvFBXString;
      protected
       fConnectedTo:TpvFBXObjectList;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); reintroduce; virtual;
       destructor Destroy; override;
       procedure AfterConstruction; override;
       procedure BeforeDestruction; override;
       function GetParentNode:TpvFBXNode;
       function FindConnectionsByType(const pType_:TpvFBXString):TpvFBXObjects;
       procedure ConnectTo(const pObject:TpvFBXObject); virtual;
       procedure ConnectToProperty(const pObject:TpvFBXObject;const pPropertyName:TpvFBXString);
       function AddProperty(const pPropertyName:TpvFBXString):TpvFBXProperty; overload;
       function AddProperty(const pPropertyName:TpvFBXString;const pValue:Variant):TpvFBXProperty; overload;
       procedure SetProperty(const pPropertyName:TpvFBXString;const pValue:Variant);
       function GetProperty(const pPropertyName:TpvFBXString):Variant;
      public
       property Loader:TpvFBXLoader read fLoader;
       property Element:TpvFBXElement read fElement;
       property ID:TpvInt64 read fID write fID;
       property Name:TpvFBXString read fName write fName;
       property Type_:TpvFBXString read fType_ write fType_;
       property Properties:TpvFBXPropertyList read fProperties;
       property PropertyByName:TpvFBXPropertyNameMap read fPropertyNameMap;
       property ConnectedFrom:TpvFBXObjectList read fConnectedFrom;
       property ConnectedTo:TpvFBXObjectList read fConnectedTo;
       property NodeAttributes:TpvFBXNodeAttributeList read fNodeAttributes;
       property Reference:TpvFBXString read fReference write fReference;
      published
     end;

     TpvFBXNodeList=class(TObjectList<TpvFBXNode>);

     TpvFBXNode=class(TpvFBXObject)
      private
       fParent:TpvFBXNode;
       fChildren:TpvFBXNodeList;
       fLclTranslation:TpvFBXVector3Property;
       fLclRotation:TpvFBXVector3Property;
       fLclScaling:TpvFBXVector3Property;
       fVisibility:Boolean;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
       procedure ConnectTo(const pObject:TpvFBXObject); override;
      published
       property Parent:TpvFBXNode read fParent write fParent;
       property Children:TpvFBXNodeList read fChildren write fChildren;
       property LclTranslation:TpvFBXVector3Property read fLclTranslation write fLclTranslation;
       property LclRotation:TpvFBXVector3Property read fLclRotation write fLclRotation;
       property LclScaling:TpvFBXVector3Property read fLclScaling write fLclScaling;
       property Visibility:Boolean read fVisibility write fVisibility;
     end;

     TpvFBXNodeAttribute=class(TpvFBXObject)
     end;

     TpvFBXNull=class(TpvFBXNodeAttribute)
     end;

     TpvFBXElementProperty=class;

     TpvFBXElementList=class(TObjectList<TpvFBXElement>);

     TpvFBXElementNameMap=class(TDictionary<TpvFBXString,TpvFBXElement>);

     TpvFBXElementPropertyList=class(TObjectList<TpvFBXElementProperty>);

     TpvFBXElementPropertyNameMap=class(TDictionary<TpvFBXString,TpvFBXElementProperty>);

     TpvFBXElement=class(TpvFBXBaseObject)
      private
       fID:TpvFBXString;
       fChildren:TpvFBXElementList;
       fChildrenNameMap:TpvFBXElementNameMap;
       fProperties:TpvFBXElementPropertyList;
      public
       constructor Create(const pID:TpvFBXString); reintroduce; virtual;
       destructor Destroy; override;
       function AddChildren(const pElement:TpvFBXElement):TpvInt32;
       function AddProperty(const pProperty:TpvFBXElementProperty):TpvInt32;
       property ID:TpvFBXString read fID;
       property Children:TpvFBXElementList read fChildren;
       property ChildrenByName:TpvFBXElementNameMap read fChildrenNameMap;
       property Properties:TpvFBXElementPropertyList read fProperties;
     end;

     TpvFBXElementProperty=class(TpvFBXBaseObject)
      private
      public
       constructor Create; override;
       destructor Destroy; override;
       function GetArrayLength:TpvFBXSizeInt; virtual;
       function GetVariantValue(const pIndex:TpvFBXSizeInt=0):Variant; virtual;
       function GetString(const pIndex:TpvFBXSizeInt=0):TpvFBXString; virtual;
       function GetBoolean(const pIndex:TpvFBXSizeInt=0):Boolean; virtual;
       function GetInteger(const pIndex:TpvFBXSizeInt=0):TpvInt64; virtual;
       function GetFloat(const pIndex:TpvFBXSizeInt=0):TpvDouble; virtual;
     end;

     TpvFBXElementPropertyBoolean=class(TpvFBXElementProperty)
      private
       fValue:Boolean;
      public
       constructor Create(const pValue:Boolean); reintroduce;
       destructor Destroy; override;
       function GetArrayLength:TpvFBXSizeInt; override;
       function GetVariantValue(const pIndex:TpvFBXSizeInt=0):Variant; override;
       function GetString(const pIndex:TpvFBXSizeInt=0):TpvFBXString; override;
       function GetBoolean(const pIndex:TpvFBXSizeInt=0):Boolean; override;
       function GetInteger(const pIndex:TpvFBXSizeInt=0):TpvInt64; override;
       function GetFloat(const pIndex:TpvFBXSizeInt=0):TpvDouble; override;
      published
       property Value:Boolean read fValue;
     end;

     TpvFBXElementPropertyInteger=class(TpvFBXElementProperty)
      private
       fValue:TpvInt64;
      public
       constructor Create(const pValue:TpvInt64); reintroduce;
       destructor Destroy; override;
       function GetArrayLength:TpvFBXSizeInt; override;
       function GetVariantValue(const pIndex:TpvFBXSizeInt=0):Variant; override;
       function GetString(const pIndex:TpvFBXSizeInt=0):TpvFBXString; override;
       function GetBoolean(const pIndex:TpvFBXSizeInt=0):Boolean; override;
       function GetInteger(const pIndex:TpvFBXSizeInt=0):TpvInt64; override;
       function GetFloat(const pIndex:TpvFBXSizeInt=0):TpvDouble; override;
      published
       property Value:TpvInt64 read fValue;
     end;

     TpvFBXElementPropertyFloat=class(TpvFBXElementProperty)
      private
       fValue:TpvDouble;
      public
       constructor Create(const pValue:TpvDouble); reintroduce;
       destructor Destroy; override;
       function GetArrayLength:TpvFBXSizeInt; override;
       function GetVariantValue(const pIndex:TpvFBXSizeInt=0):Variant; override;
       function GetString(const pIndex:TpvFBXSizeInt=0):TpvFBXString; override;
       function GetBoolean(const pIndex:TpvFBXSizeInt=0):Boolean; override;
       function GetInteger(const pIndex:TpvFBXSizeInt=0):TpvInt64; override;
       function GetFloat(const pIndex:TpvFBXSizeInt=0):TpvDouble; override;
      published
       property Value:TpvDouble read fValue;
     end;

     TpvFBXElementPropertyBytes=class(TpvFBXElementProperty)
      private
       fValue:TpvFBXBytes;
      public
       constructor Create(const pValue:TpvFBXBytes); reintroduce;
       destructor Destroy; override;
       function GetArrayLength:TpvFBXSizeInt; override;
       function GetVariantValue(const pIndex:TpvFBXSizeInt=0):Variant; override;
       function GetString(const pIndex:TpvFBXSizeInt=0):TpvFBXString; override;
       function GetBoolean(const pIndex:TpvFBXSizeInt=0):Boolean; override;
       function GetInteger(const pIndex:TpvFBXSizeInt=0):TpvInt64; override;
       function GetFloat(const pIndex:TpvFBXSizeInt=0):TpvDouble; override;
       property Value:TpvFBXBytes read fValue;
     end;

     TpvFBXElementPropertyString=class(TpvFBXElementProperty)
      private
       fValue:TpvFBXString;
      public
       constructor Create(const pValue:TpvFBXString); reintroduce;
       destructor Destroy; override;
       function GetArrayLength:TpvFBXSizeInt; override;
       function GetVariantValue(const pIndex:TpvFBXSizeInt=0):Variant; override;
       function GetString(const pIndex:TpvFBXSizeInt=0):TpvFBXString; override;
       function GetBoolean(const pIndex:TpvFBXSizeInt=0):Boolean; override;
       function GetInteger(const pIndex:TpvFBXSizeInt=0):TpvInt64; override;
       function GetFloat(const pIndex:TpvFBXSizeInt=0):TpvDouble; override;
      published
       property Value:TpvFBXString read fValue;
     end;

     TpvFBXElementPropertyArrayDataType=
      (
       Bool,
       Int8,
       Int16,
       Int32,
       Int64,
       Float32,
       Float64
      );

     TpvFBXElementPropertyArray=class(TpvFBXElementProperty)
      private
       const DataTypeSizes:array[TpvFBXElementPropertyArrayDataType.Bool..TpvFBXElementPropertyArrayDataType.Float64] of TpvFBXSizeInt=
              (
               1,
               1,
               2,
               4,
               8,
               4,
               8
              );
      private
       fData:TpvFBXBytes;
       fDataType:TpvFBXElementPropertyArrayDataType;
       fDataTypeSize:TpvFBXSizeInt;
       fDataCount:TpvFBXSizeInt;
      public
       constructor Create(const pData:pointer;const pDataCount:TpvFBXSizeInt;const pDataType:TpvFBXElementPropertyArrayDataType); reintroduce;
       constructor CreateFrom(const pStream:TStream;const pDataType:TpvFBXElementPropertyArrayDataType); reintroduce;
       destructor Destroy; override;
       function GetArrayLength:TpvFBXSizeInt; override;
       function GetVariantValue(const pIndex:TpvFBXSizeInt=0):Variant; override;
       function GetString(const pIndex:TpvFBXSizeInt=0):TpvFBXString; override;
       function GetBoolean(const pIndex:TpvFBXSizeInt=0):Boolean; override;
       function GetInteger(const pIndex:TpvFBXSizeInt=0):TpvInt64; override;
       function GetFloat(const pIndex:TpvFBXSizeInt=0):TpvDouble; override;
     end;

     EFBXParser=class(EFBX);

     TpvFBXParser=class
      private
       fStream:TStream;
       fVersion:TpvUInt32;
      public
       constructor Create(const pStream:TStream); reintroduce; virtual;
       destructor Destroy; override;
       function SceneName:TpvFBXString; virtual;
       function GetName(const pRawName:TpvFBXString):TpvFBXString; virtual;
       function ConstructName(const pNames:array of TpvFBXString):TpvFBXString; virtual;
       function NextElement:TpvFBXElement; virtual;
       function Parse:TpvFBXElement; virtual;
      published
       property Version:TpvUInt32 read fVersion;
     end;

     EFBXASCIIParser=class(EFBXParser);

     TpvFBXASCIIParserTokenKind=
      (
       None,
       EOF,
       String_,
       Comma,
       LeftBrace,
       RightBrace,
       Colon,
       Star,
       Int64,
       Float64,
       AlphaNumberic
      );

     PpvFBXASCIIParserToken=^TpvFBXASCIIParserToken;
     TpvFBXASCIIParserToken=record
      StringValue:TpvFBXString;
      case Kind:TpvFBXASCIIParserTokenKind of
       TpvFBXASCIIParserTokenKind.Int64:(
        Int64Value:TpvInt64;
       );
       TpvFBXASCIIParserTokenKind.Float64:(
        Float64Value:TpvDouble;
       );
     end;

     TpvFBXASCIIParser=class(TpvFBXParser)
      private
       type TFileSignature=array[0..4] of AnsiChar;
       const FILE_SIGNATURE:TFileSignature=';'#32'FBX';
             AlphaNumberic=['a'..'z','A'..'Z','0'..'9','|','_','-','+','.','*'];
      private
       fCurrentToken:TpvFBXASCIIParserToken;
       function SkipWhiteSpace:boolean;
       procedure NextToken;
      public
       constructor Create(const pStream:TStream); override;
       destructor Destroy; override;
       function SceneName:TpvFBXString; override;
       function GetName(const pRawName:TpvFBXString):TpvFBXString; override;
       function ConstructName(const pNames:array of TpvFBXString):TpvFBXString; override;
       function NextElement:TpvFBXElement; override;
       function Parse:TpvFBXElement; override;
     end;

     EFBXBinaryParser=class(EFBXParser);

     TpvFBXBinaryParser=class(TpvFBXParser)
      private
       type TFileSignature=array[0..20] of AnsiChar;
            TNameSeparator=array[0..1] of AnsiChar;
       const FILE_SIGNATURE:TFileSignature='Kaydara FBX Binary'#$20#$20#$00;
             TYPE_BOOL=67; // 'C'
             TYPE_BYTE=66; // 'B'
             TYPE_INT16=89; // 'Y'
             TYPE_INT32=73; // 'I'
             TYPE_INT64=76; // 'L'
             TYPE_FLOAT32=70; // 'F'
             TYPE_FLOAT64=68; // 'D'
             TYPE_ARRAY_BOOL=99; // 'c'
             TYPE_ARRAY_BYTE=98; // 'b'
             TYPE_ARRAY_INT16=121; // 'y'
             TYPE_ARRAY_INT32=105; // 'i'
             TYPE_ARRAY_INT64=108; // 'l'
             TYPE_ARRAY_FLOAT32=102; // 'f'
             TYPE_ARRAY_FLOAT64=100; // 'd'
             TYPE_BYTES=82; // 'R'
             TYPE_STRING=83; // 'S'
             NAME_SEPARATOR:TNameSeparator=#$00#$01;
      private
       function ReadInt8:TpvInt8;
       function ReadInt16:TpvInt16;
       function ReadInt32:TpvInt32;
       function ReadInt64:TpvInt64;
       function ReadUInt8:TpvUInt8;
       function ReadUInt16:TpvUInt16;
       function ReadUInt32:TpvUInt32;
       function ReadUInt64:TpvUInt64;
       function ReadFloat32:TpvFloat;
       function ReadFloat64:TpvDouble;
       function ReadString(const pLength:TpvInt32):TpvFBXString;
      public
       constructor Create(const pStream:TStream); override;
       destructor Destroy; override;
       function SceneName:TpvFBXString; override;
       function GetName(const pRawName:TpvFBXString):TpvFBXString; override;
       function ConstructName(const pNames:array of TpvFBXString):TpvFBXString; override;
       function NextElement:TpvFBXElement; override;
       function Parse:TpvFBXElement; override;
     end;

     PpvFBXTimeMode=^TpvFBXTimeMode;
     TpvFBXTimeMode=
      (
       Default=0,
       FPS_120=1,
       FPS_100=2,
       FPS_60=3,
       FPS_50=4,
       FPS_48=5,
       FPS_30=6,
       FPS_30_DROP=7,
       NTSC_DROP_FRAME=8,
       NTSC_FULL_FRAME=9,
       PAL=10,
       FPS_24=11,
       FPS_1000=12,
       FILM_FULL_FRAME=13,
       Custom=14,
       FPS_96=15,
       FPS_72=16,
       FPS_59_DOT_94=17
      );

     TpvFBXObjectNameMap=class(TDictionary<TpvFBXString,TpvFBXObject>);

     TpvFBXCamera=class;

     TpvFBXLight=class;

     TpvFBXGeometry=class;

     TpvFBXMesh=class;

     TpvFBXSkeleton=class;

     TpvFBXMaterial=class;

     TpvFBXAnimationStack=class;

     TpvFBXDeformer=class;

     TpvFBXTexture=class;

     TpvFBXPose=class;

     TpvFBXVideo=class;

     TpvFBXTake=class;

     TpvFBXPropertyNameRemap=class(TDictionary<TpvFBXString,TpvFBXString>);

     TpvFBXCameraList=class(TObjectList<TpvFBXCamera>);

     TpvFBXLightList=class(TObjectList<TpvFBXLight>);

     TpvFBXMeshList=class(TObjectList<TpvFBXMesh>);

     TpvFBXSkeletonList=class(TObjectList<TpvFBXSkeleton>);

     TpvFBXMaterialList=class(TObjectList<TpvFBXMaterial>);

     TpvFBXAnimationStackList=class(TObjectList<TpvFBXAnimationStack>);

     TpvFBXDeformerList=class(TObjectList<TpvFBXDeformer>);

     TpvFBXTextureList=class(TObjectList<TpvFBXTexture>);

     TpvFBXPoseList=class(TObjectList<TpvFBXPose>);

     TpvFBXVideoList=class(TObjectList<TpvFBXVideo>);

     TpvFBXTakeList=class(TObjectList<TpvFBXTake>);

     TpvFBXHeader=class(TpvFBXObject);

     TpvFBXSceneInfo=class(TpvFBXObject);

     TpvFBXScene=class(TpvFBXObject)
      private
       fHeader:TpvFBXHeader;
       fSceneInfo:TpvFBXSceneInfo;
       fAllObjects:TpvFBXObjectNameMap;
       fCameras:TpvFBXCameraList;
       fLights:TpvFBXLightList;
       fMeshes:TpvFBXMeshList;
       fSkeletons:TpvFBXSkeletonList;
       fMaterials:TpvFBXMaterialList;
       fAnimationStackList:TpvFBXAnimationStackList;
       fDeformers:TpvFBXDeformerList;
       fTextures:TpvFBXTextureList;
       fPoses:TpvFBXPoseList;
       fVideos:TpvFBXVideoList;
       fTakes:TpvFBXTakeList;
       fCurrentTake:TpvFBXTake;
       fRootNodes:TpvFBXObjectList;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
       property Header:TpvFBXHeader read fHeader;
       property SceneInfo:TpvFBXSceneInfo read fSceneInfo;
       property AllObjects:TpvFBXObjectNameMap read fAllObjects;
       property Cameras:TpvFBXCameraList read fCameras;
       property Lights:TpvFBXLightList read fLights;
       property Meshes:TpvFBXMeshList read fMeshes;
       property Skeletons:TpvFBXSkeletonList read fSkeletons;
       property Materials:TpvFBXMaterialList read fMaterials;
       property AnimationStackList:TpvFBXAnimationStackList read fAnimationStackList;
       property Deformers:TpvFBXDeformerList read fDeformers;
       property Textures:TpvFBXTextureList read fTextures;
       property Poses:TpvFBXPoseList read fPoses;
       property Videos:TpvFBXVideoList read fVideos;
       property Takes:TpvFBXTakeList read fTakes;
       property CurrentTake:TpvFBXTake read fCurrentTake;
       property RootNodes:TpvFBXObjectList read fRootNodes;
     end;

     TpvFBXGlobalSettings=class(TpvFBXObject)
      private
       fUpAxis:TpvInt32;
       fUpAxisSign:TpvInt32;
       fFrontAxis:TpvInt32;
       fFrontAxisSign:TpvInt32;
       fCoordAxis:TpvInt32;
       fCoordAxisSign:TpvInt32;
       fOriginalUpAxis:TpvInt32;
       fOriginalUpAxisSign:TpvInt32;
       fUnitScaleFactor:TpvDouble;
       fOriginalUnitScaleFactor:TpvDouble;
       fAmbientColor:TpvFBXColor;
       fDefaultCamera:TpvFBXString;
       fTimeMode:TpvFBXTimeMode;
       fTimeProtocol:TpvInt32;
       fSnapOnFrameMode:TpvInt32;
       fTimeSpan:TpvFBXTimeSpan;
       fCustomFrameRate:TpvDouble;
       function GetTimeSpanStart:TpvFBXTime; inline;
       procedure SetTimeSpanStart(const pValue:TpvFBXTime); inline;
       function GetTimeSpanStop:TpvFBXTime; inline;
       procedure SetTimeSpanStop(const pValue:TpvFBXTime); inline;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
       property AmbientColor:TpvFBXColor read fAmbientColor write fAmbientColor;
       property TimeSpan:TpvFBXTimeSpan read fTimeSpan write fTimeSpan;
      published
       property UpAxis:TpvInt32 read fUpAxis write fUpAxis;
       property UpAxisSign:TpvInt32 read fUpAxisSign write fUpAxisSign;
       property FrontAxis:TpvInt32 read fFrontAxis write fFrontAxis;
       property FrontAxisSign:TpvInt32 read fFrontAxisSign write fFrontAxisSign;
       property CoordAxis:TpvInt32 read fCoordAxis write fCoordAxis;
       property CoordAxisSign:TpvInt32 read fCoordAxisSign write fCoordAxisSign;
       property OriginalUpAxis:TpvInt32 read fOriginalUpAxis write fOriginalUpAxis;
       property OriginalUpAxisSign:TpvInt32 read fOriginalUpAxisSign write fOriginalUpAxisSign;
       property UnitScaleFactor:TpvDouble read fUnitScaleFactor write fUnitScaleFactor;
       property OriginalUnitScaleFactor:TpvDouble read fOriginalUnitScaleFactor write fOriginalUnitScaleFactor;
       property DefaultCamera:TpvFBXString read fDefaultCamera write fDefaultCamera;
       property TimeMode:TpvFBXTimeMode read fTimeMode write fTimeMode;
       property TimeProtocol:TpvInt32 read fTimeProtocol write fTimeProtocol;
       property SnapOnFrameMode:TpvInt32 read fSnapOnFrameMode write fSnapOnFrameMode;
       property TimeSpanStart:TpvFBXTime read GetTimeSpanStart write SetTimeSpanStart;
       property TimeSpanStop:TpvFBXTime read GetTimeSpanStop write SetTimeSpanStop;
       property CustomFrameRate:TpvDouble read fCustomFrameRate write fCustomFrameRate;
     end;

     TpvFBXCamera=class(TpvFBXObject)
      private
       fPosition:TpvFBXVector3Property;
       fLookAt:TpvFBXVector3Property;
       fCameraOrthoZoom:TpvDouble;
       fRoll:TpvDouble;
       fFieldOfView:TpvDouble;
       fFrameColor:TpvFBXColorProperty;
       fNearPlane:TpvDouble;
       fFarPlane:TpvDouble;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
      published
       property Position:TpvFBXVector3Property read fPosition write fPosition;
       property LookAt:TpvFBXVector3Property read fLookAt write fLookAt;
       property CameraOrthoZoom:TpvDouble read fCameraOrthoZoom write fCameraOrthoZoom;
       property Roll:TpvDouble read fRoll write fRoll;
       property FieldOfView:TpvDouble read fFieldOfView write fFieldOfView;
       property FrameColor:TpvFBXColorProperty read fFrameColor write fFrameColor;
       property NearPlane:TpvDouble read fNearPlane write fNearPlane;
       property FarPlane:TpvDouble read fFarPlane write fFarPlane;
     end;

     TpvFBXLight=class(TpvFBXObject)
      public
       const SPOT=0;
             POINT=1;
             DIRECTIONAL=2;
             NO_DECAY=0;
             LINEAR_DECAY=1;
             QUADRATIC_DECAY=2;
             CUBIC_DECAY=3;
      private
       fColor:TpvFBXColorProperty;
       fIntensity:TpvDouble;
       fConeAngle:TpvDouble;
       fDecay:TpvInt32;
       fLightType:TpvInt32;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
      published
       property Color:TpvFBXColorProperty read fColor write fColor;
       property Intensity:TpvDouble read fIntensity write fIntensity;
       property ConeAngle:TpvDouble read fConeAngle write fConeAngle;
       property Decay:TpvInt32 read fDecay write fDecay;
       property LightType:TpvInt32 read fLightType write fLightType;
     end;

     TpvFBXGeometry=class(TpvFBXNodeAttribute);

     PpvFBXMappingMode=^TpvFBXMappingMode;
     TpvFBXMappingMode=
      (
       fmmNone,
       fmmByVertex,
       fmmByPolygonVertex,
       fmmByPolygon,
       fmmByEdge,
       fmmAllSame
      );

     PpvFBXReferenceMode=^TpvFBXReferenceMode;
     TpvFBXReferenceMode=
      (
       frmDirect,
       frmIndex,
       frmIndexToDirect
      );

     TpvFBXLayerElement<TDataType>=class(TpvFBXBaseObject)
      public
       type TpvFBXLayerElementIntegerList=class(TList<TpvInt64>);
            TpvFBXLayerElementDataList=class(TList<TDataType>);
      private
       fMappingMode:TpvFBXMappingMode;
       fReferenceMode:TpvFBXReferenceMode;
       fIndexArray:TpvFBXLayerElementIntegerList;
       fByPolygonVertexIndexArray:TpvFBXLayerElementIntegerList;
       fData:TpvFBXLayerElementDataList;
       function GetItem(const pIndex:TpvFBXSizeInt):TDataType; inline;
       procedure SetItem(const pIndex:TpvFBXSizeInt;const pItem:TDataType); inline;
      public
       constructor Create; override;
       destructor Destroy; override;
       procedure Finish(const pMesh:TpvFBXMesh);
       property Items[const pIndex:TpvFBXSizeInt]:TDataType read GetItem write SetItem; default;
      published
       property MappingMode:TpvFBXMappingMode read fMappingMode;
       property ReferenceMode:TpvFBXReferenceMode read fReferenceMode;
       property IndexArray:TpvFBXLayerElementIntegerList read fIndexArray;
       property ByPolygonVertexIndexArray:TpvFBXLayerElementIntegerList read fByPolygonVertexIndexArray;
       property Data:TpvFBXLayerElementDataList read fData;
     end;

     TpvFBXLayerElementVector2=class(TpvFBXLayerElement<TpvFBXVector2>);

     TpvFBXLayerElementVector3=class(TpvFBXLayerElement<TpvFBXVector3>);

     TpvFBXLayerElementVector4=class(TpvFBXLayerElement<TpvFBXVector4>);

     TpvFBXLayerElementColor=class(TpvFBXLayerElement<TpvFBXColor>);

     TpvFBXLayerElementInteger=class(TpvFBXLayerElement<TpvInt64>);

     TpvFBXLayer=class(TpvFBXBaseObject)
      private
       fNormals:TpvFBXLayerElementVector3;
       fTangents:TpvFBXLayerElementVector3;
       fBitangents:TpvFBXLayerElementVector3;
       fUVs:TpvFBXLayerElementVector2;
       fColors:TpvFBXLayerElementColor;
       fMaterials:TpvFBXLayerElementInteger;
      public
       constructor Create; override;
       destructor Destroy; override;
      published
       property Normals:TpvFBXLayerElementVector3 read fNormals;
       property Tangents:TpvFBXLayerElementVector3 read fTangents;
       property Bitangents:TpvFBXLayerElementVector3 read fBitangents;
       property UVs:TpvFBXLayerElementVector2 read fUVs;
       property Colors:TpvFBXLayerElementColor read fColors;
       property Materials:TpvFBXLayerElementInteger read fMaterials write fMaterials;
     end;

     TpvFBXLayers=class(TObjectList<TpvFBXLayer>);

     TpvFBXCluster=class;

     TpvFBXMeshVertices=class(TList<TpvFBXVector3>);

     TpvFBXMeshIndices=class(TList<TpvInt64>);

     TpvFBXMeshPolygons=class(TObjectList<TpvFBXMeshIndices>);

     PpvFBXMeshEdge=^TpvFBXMeshEdge;
     TpvFBXMeshEdge=array[0..1] of TpvInt64;

     TpvFBXMeshEdges=class(TList<TpvFBXMeshEdge>);

     PpvFBXMeshClusterMapItem=^TpvFBXMeshClusterMapItem;
     TpvFBXMeshClusterMapItem=record
      Cluster:TpvFBXCluster;
      Weight:TpvDouble;
     end;

     TpvFBXMeshClusterMapItemList=class(TList<TpvFBXMeshClusterMapItem>);

     TpvFBXMeshClusterMap=class(TObjectList<TpvFBXMeshClusterMapItemList>);

     PpvFBXMeshTriangleVertex=^TpvFBXMeshTriangleVertex;
     TpvFBXMeshTriangleVertex=record
      Position:TpvFBXVector3;
      Normal:TpvFBXVector3;
      Tangent:TpvFBXVector3;
      Bitangent:TpvFBXVector3;
      UV:TpvFBXVector2;
      Color:TpvFBXColor;
      Material:TpvInt32;
     end;

     TpvFBXMeshTriangleVertexList=class(TList<TpvFBXMeshTriangleVertex>);

     TpvFBXMesh=class(TpvFBXGeometry)
      private
       fVertices:TpvFBXMeshVertices;
       fPolygons:TpvFBXMeshPolygons;
       fEdges:TpvFBXMeshEdges;
       fLayers:TpvFBXLayers;
       fClusterMap:TpvFBXMeshClusterMap;
       fTriangleVertices:TpvFBXMeshTriangleVertexList;
       fTriangleIndices:TpvFBXInt64List;
       fMaterials:TpvFBXMaterialList;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
       procedure ConnectTo(const pObject:TpvFBXObject); override;
       procedure Finish;
      published
       property Vertices:TpvFBXMeshVertices read fVertices;
       property Polygons:TpvFBXMeshPolygons read fPolygons;
       property Edges:TpvFBXMeshEdges read fEdges;
       property Layers:TpvFBXLayers read fLayers;
       property ClusterMap:TpvFBXMeshClusterMap read fClusterMap;
       property TriangleVertices:TpvFBXMeshTriangleVertexList read fTriangleVertices;
       property TriangleIndices:TpvFBXInt64List read fTriangleIndices;
       property Materials:TpvFBXMaterialList read fMaterials;
     end;

     TpvFBXSkeleton=class(TpvFBXNode)
      public
       const ROOT=0;
             LIMB=1;
             LIMB_NODE=2;
             EFFECTOR=3;
      private
       fSkeletonType:TpvInt32;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
      published
       property SkeletonType:TpvInt32 read fSkeletonType;
     end;

     TpvFBXSkeletonRoot=class(TpvFBXSkeleton);

     TpvFBXSkeletonLimb=class(TpvFBXSkeleton);

     TpvFBXSkeletonLimbNode=class(TpvFBXSkeleton);

     TpvFBXSkeletonEffector=class(TpvFBXSkeleton);

     TpvFBXMaterial=class(TpvFBXObject)
      private
       fShadingModel:TpvFBXString;
       fMultiLayer:Boolean;
       fAmbientColor:TpvFBXColorProperty;
       fDiffuseColor:TpvFBXColorProperty;
       fTransparencyFactor:TpvDouble;
       fEmissive:TpvFBXColorProperty;
       fAmbient:TpvFBXColorProperty;
       fDiffuse:TpvFBXColorProperty;
       fOpacity:TpvDouble;
       fSpecular:TpvFBXColorProperty;
       fSpecularFactor:TpvDouble;
       fShininess:TpvDouble;
       fShininessExponent:TpvDouble;
       fReflection:TpvFBXColorProperty;
       fReflectionFactor:TpvDouble;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
       procedure ConnectTo(const pObject:TpvFBXObject); override;
      published
       property ShadingModel:TpvFBXString read fShadingModel write fShadingModel;
       property MultiLayer:Boolean read fMultiLayer write fMultiLayer;
       property AmbientColor:TpvFBXColorProperty read fAmbientColor write fAmbientColor;
       property DiffuseColor:TpvFBXColorProperty read fDiffuseColor write fDiffuseColor;
       property TransparencyFactor:TpvDouble read fTransparencyFactor write fTransparencyFactor;
       property Emissive:TpvFBXColorProperty read fEmissive write fEmissive;
       property Ambient:TpvFBXColorProperty read fAmbient write fAmbient;
       property Diffuse:TpvFBXColorProperty read fDiffuse write fDiffuse;
       property Opacity:TpvDouble read fOpacity write fOpacity;
       property Specular:TpvFBXColorProperty read fSpecular write fSpecular;
       property SpecularFactor:TpvDouble read fSpecularFactor write fSpecularFactor;
       property Shininess:TpvDouble read fShininess write fShininess;
       property ShininessExponent:TpvDouble read fShininessExponent write fShininessExponent;
       property Reflection:TpvFBXColorProperty read fReflection write fReflection;
       property ReflectionFactor:TpvDouble read fReflectionFactor write fReflectionFactor;
     end;

     TpvFBXAnimationStack=class(TpvFBXObject)
      private
       fDescription:TpvFBXString;
       fLocalStart:TpvFBXTime;
       fLocalStop:TpvFBXTime;
       fReferenceStart:TpvFBXTime;
       fReferenceStop:TpvFBXTime;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
      published
       property Description:TpvFBXString read fDescription write fDescription;
       property LocalStart:TpvFBXTime read fLocalStart write fLocalStart;
       property LocalStop:TpvFBXTime read fLocalStop write fLocalStop;
       property ReferenceStart:TpvFBXTime read fReferenceStart write fReferenceStart;
       property ReferenceStop:TpvFBXTime read fReferenceStop write fReferenceStop;
     end;

     TpvFBXAnimationLayer=class(TpvFBXObject)
      public
       const BLEND_ADDITIVE=0;
             BLEND_OVERRIDE=1;
             BLEND_OVERRIDE_PASSTHROUGH=2;
             ROTATION_BY_LAYER=0;
             ROTATION_BY_CHANNEL=1;
             SCALE_MULTIPLY=0;
             SCALE_ADDITIVE=1;
      private
       fWeight:TpvDouble;
       fMute:Boolean;
       fSolo:Boolean;
       fLock:Boolean;
       fColor:TpvFBXColorProperty;
       fBlendMode:TpvInt32;
       fRotationAccumulationMode:TpvInt32;
       fScaleAccumulationMode:TpvInt32;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
      published
       property Weight:TpvDouble read fWeight write fWeight;
       property Mute:Boolean read fMute write fMute;
       property Solo:Boolean read fSolo write fSolo;
       property Lock:Boolean read fLock write fLock;
       property Color:TpvFBXColorProperty read fColor write fColor;
       property BlendMode:TpvInt32 read fBlendMode write fBlendMode;
       property RotationAccumulationMode:TpvInt32 read fRotationAccumulationMode write fRotationAccumulationMode;
       property ScaleAccumulationMode:TpvInt32 read fScaleAccumulationMode write fScaleAccumulationMode;
     end;

     TpvFBXAnimationCurveNode=class(TpvFBXObject)
      private
       fX:TpvDouble;
       fY:TpvDouble;
       fZ:TpvDouble;
      published
       property x:TpvDouble read fX write fX;
       property y:TpvDouble read fY write fY;
       property z:TpvDouble read fZ write fZ;
     end;

     TpvFBXDeformer=class(TpvFBXObject)
     end;

     TpvFBXSkinDeformer=class(TpvFBXDeformer)
      public
       const RIGID=0;
             LINEAR=1;
             DUAL_QUATERNION=2;
             BLEND=3;
      private
       fLink_DeformAcuracy:TpvInt32;
       fSkinningType:TpvInt32;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
      published
       property Link_DeformAcuracy:TpvInt32 read fLink_DeformAcuracy write fLink_DeformAcuracy;
       property SkinningType:TpvInt32 read fSkinningType write fSkinningType;
       property Clusters:TpvFBXObjectList read fConnectedTo;
     end;

     TpvFBXCluster=class(TpvFBXDeformer)
      public
       const NORMALIZE=0;
             ADDITIVE=1;
             TOTAL_ONE=2;
      private
       fIndexes:TpvFBXInt64Array;
       fWeights:TpvFBXFloat64Array;
       fTransform:TpvFBXMatrix4x4;
       fTransformLink:TpvFBXMatrix4x4;
       fLinkMode:TpvInt32;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
       function GetLink:TpvFBXNode;
       property Transform:TpvFBXMatrix4x4 read fTransform write fTransform;
       property TransformLink:TpvFBXMatrix4x4 read fTransformLink write fTransformLink;
      published
       property Indexes:TpvFBXInt64Array read fIndexes write fIndexes;
       property Weights:TpvFBXFloat64Array read fWeights write fWeights;
       property LinkMode:TpvInt32 read fLinkMode write fLinkMode;
     end;

     TpvFBXTexture=class(TpvFBXNode)
      private
       fFileName:TpvFBXString;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
      published
       property FileName:TpvFBXString read fFileName write fFileName;
     end;

     TpvFBXFolder=class(TpvFBXObject);

     TpvFBXConstraint=class(TpvFBXObject);

     PpvFBXAnimationKeyDataFloats=^TpvFBXAnimationKeyDataFloats;
     TpvFBXAnimationKeyDataFloats=array[0..5] of TpvFloat;

     TpvFBXAnimationKey=class
      public
       const DEFAULT_WEIGHT=1.0/3.0;
             MIN_WEIGHT=0.000099999997;
             MAX_WEIGHT=0.99;
             DEFAULT_VELOCITY=0;
             TANGENT_AUTO=$00000100;
             TANGENT_TCB=$00000200;
             TANGENT_USER=$00000400;
             TANGENT_GENERIC_BREAK=$00000800;
             TANGENT_BREAK=TANGENT_GENERIC_BREAK or TANGENT_USER;
             TANGENT_AUTO_BREAK=TANGENT_GENERIC_BREAK or TANGENT_AUTO;
             TANGENT_GENERIC_CLAMP=$00001000;
             TANGENT_GENERIC_TIME_INDEPENDENT=$00002000;
             TANGENT_GENERIC_CLAMP_PROGRESSIVE=$00004000 or TANGENT_GENERIC_TIME_INDEPENDENT;
             TANGENT_MASK=$00007f00;
             INTERPOLATION_CONSTANT=$00000002;
             INTERPOLATION_LINEAR=$00000004;
             INTERPOLATION_CUBIC=$00000008;
             INTERPOLATION_MASK=$0000000e;
             WEIGHTED_NONE=$00000000;
             WEIGHTED_RIGHT=$01000000;
             WEIGHTED_NEXT_LEFT=$02000000;
             WEIGHTED_ALL=WEIGHTED_RIGHT or WEIGHTED_NEXT_LEFT;
             WEIGHT_MASK=$03000000;
             CONSTANT_STANDARD=$00000000;
             CONSTANT_NEXT=$00000100;
             CONSTANT_MASK=$00000100;
             VELOCITY_NONE=$00000000;
             VELOCITY_RIGHT=$10000000;
             VELOCITY_NEXT_LEFT=$20000000;
             VELOCITY_ALL=VELOCITY_RIGHT or VELOCITY_NEXT_LEFT;
             VELOCITY_MASK=$30000000;
             VISIBILITY_NONE=$00000000;
             VISIBILITY_SHOW_LEFT=$00100000;
             VISIBILITY_SHOW_RIGHT=$00200000;
             VISIBILITY_SHOW_BOTH=VISIBILITY_SHOW_LEFT or VISIBILITY_SHOW_RIGHT;
             VISIBILITY_MASK=$00300000;
             RightSlopeIndex=0;
             NextLeftSlopeIndex=1;
             WeightsIndex=2;
             RightWeightIndex=2;
             NextLeftWeightIndex=3;
             VelocityIndex=4;
             RightVelocityIndex=4;
             NextLeftVelocityIndex=5;
             TCBTensionIndex=0;
             TCBContinuityIndex=1;
             TCBBiasIndex=2;
             DefaultDataFloats:TpvFBXAnimationKeyDataFloats=
              (
               0,                // RightSlope, TCBTension
               0,                // NextLeftSlope, TCBContinuity
               DEFAULT_WEIGHT,   // RightWeight, TCBBias
               DEFAULT_WEIGHT,   // NextLeftWeight
               DEFAULT_VELOCITY, // RightVelocity
               DEFAULT_VELOCITY  // NextLeftVelocity
              );
      private
       fTime:TpvFBXTime;
       fValue:TpvDouble;
       fTangentMode:TpvInt32;
       fInterpolation:TpvInt32;
       fWeight:TpvInt32;
       fConstant:TpvInt32;
       fVelocity:TpvInt32;
       fVisibility:TpvInt32;
       fDataFloats:TpvFBXAnimationKeyDataFloats;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       property DataFloats:TpvFBXAnimationKeyDataFloats read fDataFloats write fDataFloats;
      published
       property Time:TpvFBXTime read fTime write fTime;
       property Value:TpvDouble read fValue write fValue;
       property TangentMode:TpvInt32 read fTangentMode write fTangentMode;
       property Interpolation:TpvInt32 read fInterpolation write fInterpolation;
       property Weight:TpvInt32 read fWeight write fWeight;
       property Constant:TpvInt32 read fConstant write fConstant;
       property Velocity:TpvInt32 read fVelocity write fVelocity;
       property Visibility:TpvInt32 read fVisibility write fVisibility;
     end;

     TpvFBXAnimationKeyList=class(TObjectList<TpvFBXAnimationKey>);

     TpvFBXAnimationCurve=class(TpvFBXNode)
      private
       fDefaultValue:TpvDouble;
       fAnimationKeys:TpvFBXAnimationKeyList;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       constructor CreateOldFBX6000(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
       destructor Destroy; override;
      published
       property DefaultValue:TpvDouble read fDefaultValue write fDefaultValue;
       property AnimationKeys:TpvFBXAnimationKeyList read fAnimationKeys;
     end;

     TpvFBXPoseNodeMatrixMap=class(TDictionary<TpvFBXNode,TpvFBXMatrix4x4>);

     TpvFBXPose=class(TpvFBXObject)
      private
       fPoseType:TpvFBXString;
       fNodeMatrixMap:TpvFBXPoseNodeMatrixMap;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
       function GetMatrix(const pNode:TpvFBXNode):TpvFBXMatrix4x4;
      published
       property PoseType:TpvFBXString read fPoseType;
       property NodeMatrixMap:TpvFBXPoseNodeMatrixMap read fNodeMatrixMap;
     end;

     TpvFBXVideo=class(TpvFBXObject)
      private
       fFileName:TpvFBXString;
       fUseMipMap:Boolean;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
      published
       property FileName:TpvFBXString read fFileName write fFileName;
       property UseMipMap:Boolean read fUseMipMap write fUseMipMap;
     end;

     TpvFBXTake=class(TpvFBXObject)
      private
       fFileName:TpvFBXString;
       fLocalTimeSpan:TpvFBXTimeSpan;
       fReferenceTimeSpan:TpvFBXTimeSpan;
      public
       constructor Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString); override;
       destructor Destroy; override;
       property LocalTimeSpan:TpvFBXTimeSpan read fLocalTimeSpan write fLocalTimeSpan;
       property ReferenceTimeSpan:TpvFBXTimeSpan read fReferenceTimeSpan write fReferenceTimeSpan;
      published
       property FileName:TpvFBXString read fFileName write fFileName;
     end;

     TpvFBXTimeUtils=class
      public
       const UnitsPerSecond=TpvInt64(46186158000);
             InverseUnitsPerSecond=1.0/TpvInt64(46186158000);
             Zero=TpvInt64(0);
             Infinite=TpvInt64($7fffffffffffffff);
             FramesPerSecondValues:array[TpvFBXTimeMode.Default..TpvFBXTimeMode.FPS_59_DOT_94] of TpvDouble=
              (
               60.0,
               120.0,
               100.0,
               60.0,
               50.0,
               48.0,
               30.0,
               29.97,
               30.0,
               29.97,
               50.0,
               24.0,
               1000.0,
               24.0,
               1.0,
               96.0,
               72.0,
               59.94
              );
      private
       fGlobalSettings:TpvFBXGlobalSettings;
      public
       constructor Create(const pGlobalSettings:TpvFBXGlobalSettings); reintroduce;
       destructor Destroy; override;
       function TimeToFrame(const pTime:TpvFBXTime;const pTimeMode:TpvFBXTimeMode=TpvFBXTimeMode.Default):TpvDouble;
       function FrameToSeconds(const pFrame:TpvDouble;const pTimeMode:TpvFBXTimeMode=TpvFBXTimeMode.Default):TpvDouble;
       function TimeToSeconds(const pTime:TpvFBXTime):TpvDouble;
     end;

     TpvFBXAllocatedList=class(TObjectList<TObject>);

     TpvFBXLoader=class
      private
       fFileVersion:TpvInt32;
       fAllocatedList:TpvFBXAllocatedList;
       fScene:TpvFBXScene;
       fGlobalSettings:TpvFBXGlobalSettings;
       fTimeUtils:TpvFBXTimeUtils;
       fRootElement:TpvFBXElement;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure LoadFromStream(const pStream:TStream);
       procedure LoadFromFile(const pFileName:UTF8String);
      published
       property FileVersion:TpvInt32 read fFileVersion;
       property Scene:TpvFBXScene read fScene;
       property GlobalSettings:TpvFBXGlobalSettings read fGlobalSettings;
       property TimeUtils:TpvFBXTimeUtils read fTimeUtils;
     end;

var PropertyNameRemap:TpvFBXPropertyNameRemap=nil;

const FBXMatrix4x4Identity:TpvFBXMatrix4x4=(RawComponents:((1.0,0.0,0.0,0.0),(0.0,1.0,0.0,0.0),(0.0,0.0,1.0,0.0),(0.0,0.0,0.0,1.0)););

function Modulus(x,y:TpvFBXScalar):TpvFBXScalar; {$ifdef caninline}inline;{$endif}

function DoInflate(InData:pointer;InLen:TpvUInt32;var DestData:pointer;var DestLen:TpvUInt32;ParseHeader:boolean):boolean;

function StreamReadInt8(const pStream:TStream):TpvInt8;
function StreamReadInt16(const pStream:TStream):TpvInt16;
function StreamReadInt32(const pStream:TStream):TpvInt32;
function StreamReadInt64(const pStream:TStream):TpvInt64;
function StreamReadUInt8(const pStream:TStream):TpvUInt8;
function StreamReadUInt16(const pStream:TStream):TpvUInt16;
function StreamReadUInt32(const pStream:TStream):TpvUInt32;
function StreamReadUInt64(const pStream:TStream):TpvUInt64;
function StreamReadFloat32(const pStream:TStream):TpvFloat;
function StreamReadFloat64(const pStream:TStream):TpvDouble;

implementation

function Modulus(x,y:TpvFBXScalar):TpvFBXScalar; {$ifdef caninline}inline;{$endif}
begin
 result:=(abs(x)-(abs(y)*(floor(abs(x)/abs(y)))))*sign(x);
end;

function DoInflate(InData:pointer;InLen:TpvUInt32;var DestData:pointer;var DestLen:TpvUInt32;ParseHeader:boolean):boolean;
const CLCIndex:array[0..18] of TpvUInt8=(16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15);
type pword=^TpvUInt16;
     PTree=^TTree;
     TTree=packed record
      Table:array[0..15] of TpvUInt16;
      Translation:array[0..287] of TpvUInt16;
     end;
     PBuffer=^TBuffer;
     TBuffer=array[0..65535] of TpvUInt8;
     PLengths=^TLengths;
     TLengths=array[0..288+32-1] of TpvUInt8;
     POffsets=^TOffsets;
     TOffsets=array[0..15] of TpvUInt16;
     PBits=^TBits;
     TBits=array[0..29] of TpvUInt8;
     PBase=^TBase;
     TBase=array[0..29] of TpvUInt16;
var Tag,BitCount,DestSize:TpvUInt32;
    SymbolLengthTree,DistanceTree,FixedSymbolLengthTree,FixedDistanceTree:PTree;
    LengthBits,DistanceBits:PBits;
    LengthBase,DistanceBase:PBase;
    Source,SourceEnd:pansichar;
    Dest:pansichar;
 procedure IncSize(length:TpvUInt32);
 var j:TpvUInt32;
 begin
  if (DestLen+length)>=DestSize then begin
   if DestSize=0 then begin
    DestSize:=1;
   end;
   while (DestLen+length)>=DestSize do begin
    inc(DestSize,DestSize);
   end;
   j:=TpvFBXPtrUInt(Dest)-TpvFBXPtrUInt(DestData);
   ReAllocMem(DestData,DestSize);
   TpvFBXPtrUInt(Dest):=TpvFBXPtrUInt(DestData)+j;
  end;
 end;
 function adler32(data:pointer;length:TpvUInt32):TpvUInt32;
 const BASE=65521;
       NMAX=5552;
 var buf:pansichar;
     s1,s2,k,i:TpvUInt32;
 begin
  s1:=1;
  s2:=0;
  buf:=data;
  while length>0 do begin
   if length<NMAX then begin
    k:=length;
   end else begin
    k:=NMAX;
   end;
   dec(length,k);
   for i:=1 to k do begin
    inc(s1,TpvUInt8(buf^));
    inc(s2,s1);
    inc(buf);
   end;
   s1:=s1 mod BASE;
   s2:=s2 mod BASE;
  end;
  result:=(s2 shl 16) or s1;
 end;
 procedure BuildBitsBase(Bits:pansichar;Base:pword;Delta,First:TpvInt32);
 var i,Sum:TpvInt32;
 begin
  for i:=0 to Delta-1 do begin
   Bits[i]:=ansichar(#0);
  end;
  for i:=0 to (30-Delta)-1 do begin
   Bits[i+Delta]:=ansichar(TpvUInt8(i div Delta));
  end;
  Sum:=First;
  for i:=0 to 29 do begin
   Base^:=Sum;
   inc(Base);
   inc(Sum,1 shl TpvUInt8(Bits[i]));
  end;
 end;
 procedure BuildFixedTrees(var lt,dt:TTree);
 var i:TpvInt32;
 begin
  for i:=0 to 6 do begin
   lt.Table[i]:=0;
  end;
  lt.Table[7]:=24;
  lt.Table[8]:=152;
  lt.Table[9]:=112;
  for i:=0 to 23 do begin
   lt.Translation[i]:=256+i;
  end;
  for i:=0 to 143 do begin
   lt.Translation[24+i]:=i;
  end;
  for i:=0 to 7 do begin
   lt.Translation[168+i]:=280+i;
  end;
  for i:=0 to 111 do begin
   lt.Translation[176+i]:=144+i;
  end;
  for i:=0 to 4 do begin
   dt.Table[i]:=0;
  end;
  dt.Table[5]:=32;
  for i:=0 to 31 do begin
   dt.Translation[i]:=i;
  end;
 end;
 procedure BuildTree(var t:TTree;Lengths:pansichar;Num:TpvInt32);
 var Offsets:POffsets;
     i:TpvInt32;
     Sum:TpvUInt32;
 begin
  New(Offsets);
  try
   for i:=0 to 15 do begin
    t.Table[i]:=0;
   end;
   for i:=0 to Num-1 do begin
    inc(t.Table[TpvUInt8(Lengths[i])]);
   end;
   t.Table[0]:=0;
   Sum:=0;
   for i:=0 to 15 do begin
    Offsets^[i]:=Sum;
    inc(Sum,t.Table[i]);
   end;
   for i:=0 to Num-1 do begin
    if lengths[i]<>ansichar(#0) then begin
     t.Translation[Offsets^[TpvUInt8(lengths[i])]]:=i;
     inc(Offsets^[TpvUInt8(lengths[i])]);
    end;
   end;
  finally
   Dispose(Offsets);
  end;
 end;
 function GetBit:TpvUInt32;
 begin
  if BitCount=0 then begin
   Tag:=TpvUInt8(Source^);
   inc(Source);
   BitCount:=7;
  end else begin
   dec(BitCount);
  end;
  result:=Tag and 1;
  Tag:=Tag shr 1;
 end;
 function ReadBits(Num,Base:TpvUInt32):TpvUInt32;
 var Limit,Mask:TpvUInt32;
 begin
  result:=0;
  if Num<>0 then begin
   Limit:=1 shl Num;
   Mask:=1;
   while Mask<Limit do begin
    if GetBit<>0 then begin
     inc(result,Mask);
    end;
    Mask:=Mask shl 1;
   end;
  end;
  inc(result,Base);
 end;
 function DecodeSymbol(var t:TTree):TpvUInt32;
 var Sum,c,l:TpvInt32;
 begin
  Sum:=0;
  c:=0;
  l:=0;
  repeat
   c:=(c*2)+TpvInt32(GetBit);
   inc(l);
   inc(Sum,t.Table[l]);
   dec(c,t.Table[l]);
  until not (c>=0);
  result:=t.Translation[Sum+c];
 end;
 procedure DecodeTrees(var lt,dt:TTree);
 var CodeTree:PTree;
     Lengths:PLengths;
     hlit,hdist,hclen,i,num,length,clen,Symbol,Prev:TpvUInt32;
 begin
  New(CodeTree);
  New(Lengths);
  try
   FillChar(CodeTree^,sizeof(TTree),ansichar(#0));
   FillChar(Lengths^,sizeof(TLengths),ansichar(#0));
   hlit:=ReadBits(5,257);
   hdist:=ReadBits(5,1);
   hclen:=ReadBits(4,4);
   for i:=0 to 18 do begin
    lengths^[i]:=0;
   end;
   for i:=1 to hclen do begin
    clen:=ReadBits(3,0);
    lengths^[CLCIndex[i-1]]:=clen;
   end;
   BuildTree(CodeTree^,pansichar(pointer(@lengths^[0])),19);
   num:=0;
   while num<(hlit+hdist) do begin
    Symbol:=DecodeSymbol(CodeTree^);
    case Symbol of
     16:begin
      prev:=lengths^[num-1];
      length:=ReadBits(2,3);
      while length>0 do begin
       lengths^[num]:=prev;
       inc(num);
       dec(length);
      end;
     end;
     17:begin
      length:=ReadBits(3,3);
      while length>0 do begin
       lengths^[num]:=0;
       inc(num);
       dec(length);
      end;
     end;
     18:begin
      length:=ReadBits(7,11);
      while length>0 do begin
       lengths^[num]:=0;
       inc(num);
       dec(length);
      end;
     end;
     else begin
      lengths^[num]:=Symbol;
      inc(num);
     end;
    end;
   end;
   BuildTree(lt,pansichar(pointer(@lengths^[0])),hlit);
   BuildTree(dt,pansichar(pointer(@lengths^[hlit])),hdist);
  finally
   Dispose(CodeTree);
   Dispose(Lengths);
  end;
 end;
 function InflateBlockData(var lt,dt:TTree):boolean;
 var Symbol:TpvUInt32;
     Length,Distance,Offset,i:TpvInt32;
 begin
  result:=false;
  while (Source<SourceEnd) or (BitCount>0) do begin
   Symbol:=DecodeSymbol(lt);
   if Symbol=256 then begin
    result:=true;
    break;
   end;
   if Symbol<256 then begin
    IncSize(1);
    Dest^:=ansichar(TpvUInt8(Symbol));
    inc(Dest);
    inc(DestLen);
   end else begin
    dec(Symbol,257);
    Length:=ReadBits(LengthBits^[Symbol],LengthBase^[Symbol]);
    Distance:=DecodeSymbol(dt);
    Offset:=ReadBits(DistanceBits^[Distance],DistanceBase^[Distance]);
    IncSize(length);
    for i:=0 to length-1 do begin
     Dest[i]:=Dest[i-Offset];
    end;
    inc(Dest,Length);
    inc(DestLen,Length);
   end;
  end;
 end;
 function InflateUncompressedBlock:boolean;
 var length,invlength:TpvUInt32;
 begin
  result:=false;
  length:=(TpvUInt8(source[1]) shl 8) or TpvUInt8(source[0]);
  invlength:=(TpvUInt8(source[3]) shl 8) or TpvUInt8(source[2]);
  if length<>((not invlength) and $ffff) then begin
   exit;
  end;
  IncSize(length);
  inc(Source,4);
  if Length>0 then begin
   Move(Source^,Dest^,Length);
   inc(Source,Length);
   inc(Dest,Length);
  end;
  BitCount:=0;
  inc(DestLen,Length);
  result:=true;
 end;
 function InflateFixedBlock:boolean;
 begin
  result:=InflateBlockData(FixedSymbolLengthTree^,FixedDistanceTree^);
 end;
 function InflateDynamicBlock:boolean;
 begin
  DecodeTrees(SymbolLengthTree^,DistanceTree^);
  result:=InflateBlockData(SymbolLengthTree^,DistanceTree^);
 end;
 function Uncompress:boolean;
 var Final,r:boolean;
     BlockType:TpvUInt32;
 begin
  result:=false;
  BitCount:=0;
  Final:=false;
  while not Final do begin
   Final:=GetBit<>0;
   BlockType:=ReadBits(2,0);
   case BlockType of
    0:begin
     r:=InflateUncompressedBlock;
    end;
    1:begin
     r:=InflateFixedBlock;
    end;
    2:begin
     r:=InflateDynamicBlock;
    end;
    else begin
     r:=false;
    end;
   end;
   if not r then begin
    exit;
   end;
  end;
  result:=true;
 end;
 function UncompressZLIB:boolean;
 var cmf,flg:TpvUInt8;
     a32:TpvUInt32;
 begin
  result:=false;
  Source:=InData;
  cmf:=TpvUInt8(Source[0]);
  flg:=TpvUInt8(Source[1]);
  if ((((cmf shl 8)+flg) mod 31)<>0) or ((cmf and $f)<>8) or ((cmf shr 4)>7) or ((flg and $20)<>0) then begin
   exit;
  end;
  a32:=(TpvUInt8(Source[InLen-4]) shl 24) or (TpvUInt8(Source[InLen-3]) shl 16) or (TpvUInt8(Source[InLen-2]) shl 8) or (TpvUInt8(Source[InLen-1]) shl 0);
  inc(Source,2);
  dec(InLen,6);
  SourceEnd:=@Source[InLen];
  result:=Uncompress;
  if not result then begin
   exit;
  end;
  result:=adler32(DestData,DestLen)=a32;
 end;
 function UncompressDirect:boolean;
 begin
  Source:=InData;
  SourceEnd:=@Source[InLen];
  result:=Uncompress;
 end;
begin
 DestData:=nil;
 LengthBits:=nil;
 DistanceBits:=nil;
 LengthBase:=nil;
 DistanceBase:=nil;
 SymbolLengthTree:=nil;
 DistanceTree:=nil;
 FixedSymbolLengthTree:=nil;
 FixedDistanceTree:=nil;
 try
  New(LengthBits);
  New(DistanceBits);
  New(LengthBase);
  New(DistanceBase);
  New(SymbolLengthTree);
  New(DistanceTree);
  New(FixedSymbolLengthTree);
  New(FixedDistanceTree);
  try
   begin
    FillChar(LengthBits^,sizeof(TBits),ansichar(#0));
    FillChar(DistanceBits^,sizeof(TBits),ansichar(#0));
    FillChar(LengthBase^,sizeof(TBase),ansichar(#0));
    FillChar(DistanceBase^,sizeof(TBase),ansichar(#0));
    FillChar(SymbolLengthTree^,sizeof(TTree),ansichar(#0));
    FillChar(DistanceTree^,sizeof(TTree),ansichar(#0));
    FillChar(FixedSymbolLengthTree^,sizeof(TTree),ansichar(#0));
    FillChar(FixedDistanceTree^,sizeof(TTree),ansichar(#0));
   end;
   begin
    BuildFixedTrees(FixedSymbolLengthTree^,FixedDistanceTree^);
    BuildBitsBase(pansichar(pointer(@LengthBits^[0])),pword(pointer(@LengthBase^[0])),4,3);
    BuildBitsBase(pansichar(pointer(@DistanceBits^[0])),pword(pointer(@DistanceBase^[0])),2,1);
    LengthBits^[28]:=0;
    LengthBase^[28]:=258;
   end;
   begin
    GetMem(DestData,4096);
    DestSize:=4096;
    Dest:=DestData;
    DestLen:=0;
    if ParseHeader then begin
     result:=UncompressZLIB;
    end else begin
     result:=UncompressDirect;
    end;
    if result then begin
     ReAllocMem(DestData,DestLen);
    end else if assigned(DestData) then begin
     FreeMem(DestData);
     DestData:=nil;
    end;
   end;
  finally
   if assigned(LengthBits) then begin
    Dispose(LengthBits);
   end;
   if assigned(DistanceBits) then begin
    Dispose(DistanceBits);
   end;
   if assigned(LengthBase) then begin
    Dispose(LengthBase);
   end;
   if assigned(DistanceBase) then begin
    Dispose(DistanceBase);
   end;
   if assigned(SymbolLengthTree) then begin
    Dispose(SymbolLengthTree);
   end;
   if assigned(DistanceTree) then begin
    Dispose(DistanceTree);
   end;
   if assigned(FixedSymbolLengthTree) then begin
    Dispose(FixedSymbolLengthTree);
   end;
   if assigned(FixedDistanceTree) then begin
    Dispose(FixedDistanceTree);
   end;
  end;
 except
  result:=false;
 end;
end;

constructor TpvFBXVector2.Create(const pX:TpvFBXScalar);
begin
 x:=pX;
 y:=pX;
end;

constructor TpvFBXVector2.Create(const pX,pY:TpvFBXScalar);
begin
 x:=pX;
 y:=pY;
end;

class operator TpvFBXVector2.Implicit(const a:TpvFBXScalar):TpvFBXVector2;
begin
 result.x:=a;
 result.y:=a;
end;

class operator TpvFBXVector2.Explicit(const a:TpvFBXScalar):TpvFBXVector2;
begin
 result.x:=a;
 result.y:=a;
end;

class operator TpvFBXVector2.Equal(const a,b:TpvFBXVector2):boolean;
begin
 result:=SameValue(a.x,b.x) and SameValue(a.y,b.y);
end;

class operator TpvFBXVector2.NotEqual(const a,b:TpvFBXVector2):boolean;
begin
 result:=(not SameValue(a.x,b.x)) or (not SameValue(a.y,b.y));
end;

class operator TpvFBXVector2.Inc(const a:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=a.x+1.0;
 result.y:=a.y+1.0;
end;

class operator TpvFBXVector2.Dec(const a:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=a.x-1.0;
 result.y:=a.y-1.0;
end;

class operator TpvFBXVector2.Add(const a,b:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=a.x+b.x;
 result.y:=a.y+b.y;
end;

class operator TpvFBXVector2.Add(const a:TpvFBXVector2;const b:TpvFBXScalar):TpvFBXVector2;
begin
 result.x:=a.x+b;
 result.y:=a.y+b;
end;

class operator TpvFBXVector2.Add(const a:TpvFBXScalar;const b:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=a+b.x;
 result.y:=a+b.y;
end;

class operator TpvFBXVector2.Subtract(const a,b:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=a.x-b.x;
 result.y:=a.y-b.y;
end;

class operator TpvFBXVector2.Subtract(const a:TpvFBXVector2;const b:TpvFBXScalar):TpvFBXVector2;
begin
 result.x:=a.x-b;
 result.y:=a.y-b;
end;

class operator TpvFBXVector2.Subtract(const a:TpvFBXScalar;const b:TpvFBXVector2): TpvFBXVector2;
begin
 result.x:=a-b.x;
 result.y:=a-b.y;
end;

class operator TpvFBXVector2.Multiply(const a,b:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=a.x*b.x;
 result.y:=a.y*b.y;
end;

class operator TpvFBXVector2.Multiply(const a:TpvFBXVector2;const b:TpvFBXScalar):TpvFBXVector2;
begin
 result.x:=a.x*b;
 result.y:=a.y*b;
end;

class operator TpvFBXVector2.Multiply(const a:TpvFBXScalar;const b:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=a*b.x;
 result.y:=a*b.y;
end;

class operator TpvFBXVector2.Divide(const a,b:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
end;

class operator TpvFBXVector2.Divide(const a:TpvFBXVector2;const b:TpvFBXScalar):TpvFBXVector2;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
end;

class operator TpvFBXVector2.Divide(const a:TpvFBXScalar;const b:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=a/b.x;
 result.y:=a/b.y;
end;

class operator TpvFBXVector2.IntDivide(const a,b:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
end;

class operator TpvFBXVector2.IntDivide(const a:TpvFBXVector2;const b:TpvFBXScalar):TpvFBXVector2;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
end;

class operator TpvFBXVector2.IntDivide(const a:TpvFBXScalar;const b:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=a/b.x;
 result.y:=a/b.y;
end;

class operator TpvFBXVector2.Modulus(const a,b:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=Modulus(a.x,b.x);
 result.y:=Modulus(a.y,b.y);
end;

class operator TpvFBXVector2.Modulus(const a:TpvFBXVector2;const b:TpvFBXScalar):TpvFBXVector2;
begin
 result.x:=Modulus(a.x,b);
 result.y:=Modulus(a.y,b);
end;

class operator TpvFBXVector2.Modulus(const a:TpvFBXScalar;const b:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=Modulus(a,b.x);
 result.y:=Modulus(a,b.y);
end;

class operator TpvFBXVector2.Negative(const a:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=-a.x;
 result.y:=-a.y;
end;

class operator TpvFBXVector2.Positive(const a:TpvFBXVector2):TpvFBXVector2;
begin
 result:=a;
end;

function TpvFBXVector2.GetComponent(const pIndex:TpvInt32):TpvFBXScalar;
begin
 result:=RawComponents[pIndex];
end;

procedure TpvFBXVector2.SetComponent(const pIndex:TpvInt32;const pValue:TpvFBXScalar);
begin
 RawComponents[pIndex]:=pValue;
end;

function TpvFBXVector2.Perpendicular:TpvFBXVector2;
begin
 result.x:=-y;
 result.y:=x;
end;

function TpvFBXVector2.Length:TpvFBXScalar;
begin
 result:=sqrt(sqr(x)+sqr(y));
end;

function TpvFBXVector2.SquaredLength:TpvFBXScalar;
begin
 result:=sqr(x)+sqr(y);
end;

function TpvFBXVector2.Normalize:TpvFBXVector2;
var Factor:TpvFBXScalar;
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

function TpvFBXVector2.DistanceTo(const b:TpvFBXVector2):TpvFBXScalar;
begin
 result:=sqrt(sqr(x-b.x)+sqr(y-b.y));
end;

function TpvFBXVector2.Dot(const b:TpvFBXVector2):TpvFBXScalar;
begin
 result:=(x*b.x)+(y*b.y);
end;

function TpvFBXVector2.Cross(const b:TpvFBXVector2):TpvFBXVector2;
begin
 result.x:=(y*b.x)-(x*b.y);
 result.y:=(x*b.y)-(y*b.x);
end;

function TpvFBXVector2.Lerp(const b:TpvFBXVector2;const t:TpvFBXScalar):TpvFBXVector2;
var InvT:TpvFBXScalar;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  InvT:=1.0-t;
  result.x:=(x*InvT)+(b.x*t);
  result.y:=(y*InvT)+(b.y*t);
 end;
end;

function TpvFBXVector2.Angle(const b,c:TpvFBXVector2):TpvFBXScalar;
var DeltaAB,DeltaCB:TpvFBXVector2;
    LengthAB,LengthCB:TpvFBXScalar;
begin
 DeltaAB:=self-b;
 DeltaCB:=c-b;
 LengthAB:=DeltaAB.Length;
 LengthCB:=DeltaCB.Length;
 if (LengthAB=0.0) or (LengthCB=0.0) then begin
  result:=0.0;
 end else begin
  result:=ArcCos(DeltaAB.Dot(DeltaCB)/(LengthAB*LengthCB));
 end;
end;

function TpvFBXVector2.Rotate(const Angle:TpvFBXScalar):TpvFBXVector2;
var Sinus,Cosinus:TpvFBXScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(Angle,Sinus,Cosinus);
 result.x:=(x*Cosinus)-(y*Sinus);
 result.y:=(y*Cosinus)+(x*Sinus);
end;

function TpvFBXVector2.Rotate(const Center:TpvFBXVector2;const Angle:TpvFBXScalar):TpvFBXVector2;
var Sinus,Cosinus:TpvFBXScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(Angle,Sinus,Cosinus);
 result.x:=(((x-Center.x)*Cosinus)-((y-Center.y)*Sinus))+Center.x;
 result.y:=(((y-Center.y)*Cosinus)+((x-Center.x)*Sinus))+Center.y;
end;

constructor TpvFBXVector3.Create(const pX:TpvFBXScalar);
begin
 x:=pX;
 y:=pX;
 z:=pX;
end;

constructor TpvFBXVector3.Create(const pX,pY,pZ:TpvFBXScalar);
begin
 x:=pX;
 y:=pY;
 z:=pZ;
end;

constructor TpvFBXVector3.Create(const pXY:TpvFBXVector2;const pZ:TpvFBXScalar=0.0);
begin
 x:=pXY.x;
 y:=pXY.y;
 z:=pZ;
end;

class operator TpvFBXVector3.Implicit(const a:TpvFBXScalar):TpvFBXVector3;
begin
 result.x:=a;
 result.y:=a;
 result.z:=a;
end;

class operator TpvFBXVector3.Explicit(const a:TpvFBXScalar):TpvFBXVector3;
begin
 result.x:=a;
 result.y:=a;
 result.z:=a;
end;

class operator TpvFBXVector3.Equal(const a,b:TpvFBXVector3):boolean;
begin
 result:=SameValue(a.x,b.x) and SameValue(a.y,b.y) and SameValue(a.z,b.z);
end;

class operator TpvFBXVector3.NotEqual(const a,b:TpvFBXVector3):boolean;
begin
 result:=(not SameValue(a.x,b.x)) or (not SameValue(a.y,b.y)) or (not SameValue(a.z,b.z));
end;

class operator TpvFBXVector3.Inc({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=a.x+1.0;
 result.y:=a.y+1.0;
 result.z:=a.z+1.0;
end;

class operator TpvFBXVector3.Dec({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=a.x-1.0;
 result.y:=a.y-1.0;
 result.z:=a.z-1.0;
end;

class operator TpvFBXVector3.Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=a.x+b.x;
 result.y:=a.y+b.y;
 result.z:=a.z+b.z;
end;

class operator TpvFBXVector3.Add(const a:TpvFBXVector3;const b:TpvFBXScalar):TpvFBXVector3;
begin
 result.x:=a.x+b;
 result.y:=a.y+b;
 result.z:=a.z+b;
end;

class operator TpvFBXVector3.Add(const a:TpvFBXScalar;const b:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=a+b.x;
 result.y:=a+b.y;
 result.z:=a+b.z;
end;

class operator TpvFBXVector3.Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=a.x-b.x;
 result.y:=a.y-b.y;
 result.z:=a.z-b.z;
end;

class operator TpvFBXVector3.Subtract(const a:TpvFBXVector3;const b:TpvFBXScalar):TpvFBXVector3;
begin
 result.x:=a.x-b;
 result.y:=a.y-b;
 result.z:=a.z-b;
end;

class operator TpvFBXVector3.Subtract(const a:TpvFBXScalar;const b:TpvFBXVector3): TpvFBXVector3;
begin
 result.x:=a-b.x;
 result.y:=a-b.y;
 result.z:=a-b.z;
end;

class operator TpvFBXVector3.Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=a.x*b.x;
 result.y:=a.y*b.y;
 result.z:=a.z*b.z;
end;

class operator TpvFBXVector3.Multiply(const a:TpvFBXVector3;const b:TpvFBXScalar):TpvFBXVector3;
begin
 result.x:=a.x*b;
 result.y:=a.y*b;
 result.z:=a.z*b;
end;

class operator TpvFBXVector3.Multiply(const a:TpvFBXScalar;const b:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=a*b.x;
 result.y:=a*b.y;
 result.z:=a*b.z;
end;

class operator TpvFBXVector3.Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
 result.z:=a.z/b.z;
end;

class operator TpvFBXVector3.Divide(const a:TpvFBXVector3;const b:TpvFBXScalar):TpvFBXVector3;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
 result.z:=a.z/b;
end;

class operator TpvFBXVector3.Divide(const a:TpvFBXScalar;const b:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=a/b.x;
 result.y:=a/b.y;
 result.z:=a/b.z;
end;

class operator TpvFBXVector3.IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
 result.z:=a.z/b.z;
end;

class operator TpvFBXVector3.IntDivide(const a:TpvFBXVector3;const b:TpvFBXScalar):TpvFBXVector3;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
 result.z:=a.z/b;
end;

class operator TpvFBXVector3.IntDivide(const a:TpvFBXScalar;const b:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=a/b.x;
 result.y:=a/b.y;
 result.z:=a/b.z;
end;

class operator TpvFBXVector3.Modulus(const a,b:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=Modulus(a.x,b.x);
 result.y:=Modulus(a.y,b.y);
 result.z:=Modulus(a.z,b.z);
end;

class operator TpvFBXVector3.Modulus(const a:TpvFBXVector3;const b:TpvFBXScalar):TpvFBXVector3;
begin
 result.x:=Modulus(a.x,b);
 result.y:=Modulus(a.y,b);
 result.z:=Modulus(a.z,b);
end;

class operator TpvFBXVector3.Modulus(const a:TpvFBXScalar;const b:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=Modulus(a,b.x);
 result.y:=Modulus(a,b.y);
 result.z:=Modulus(a,b.z);
end;

class operator TpvFBXVector3.Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=-a.x;
 result.y:=-a.y;
 result.z:=-a.z;
end;

class operator TpvFBXVector3.Positive(const a:TpvFBXVector3):TpvFBXVector3;
begin
 result:=a;
end;

function TpvFBXVector3.GetComponent(const pIndex:TpvInt32):TpvFBXScalar;
begin
 result:=RawComponents[pIndex];
end;

procedure TpvFBXVector3.SetComponent(const pIndex:TpvInt32;const pValue:TpvFBXScalar);
begin
 RawComponents[pIndex]:=pValue;
end;

function TpvFBXVector3.Flip:TpvFBXVector3;
begin
 result.x:=x;
 result.y:=z;
 result.z:=-y;
end;

function TpvFBXVector3.Perpendicular:TpvFBXVector3;
var v,p:TpvFBXVector3;
begin
 v:=p.Normalize;
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

function TpvFBXVector3.OneUnitOrthogonalVector:TpvFBXVector3;
var MinimumAxis:TpvInt32;
    l:TpvFBXScalar;
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

function TpvFBXVector3.Length:TpvFBXScalar;
begin
 result:=sqrt(sqr(x)+sqr(y)+sqr(z));
end;

function TpvFBXVector3.SquaredLength:TpvFBXScalar;
begin
 result:=sqr(x)+sqr(y)+sqr(z);
end;

function TpvFBXVector3.Normalize:TpvFBXVector3;
var Factor:TpvFBXScalar;
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

function TpvFBXVector3.DistanceTo({$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector3):TpvFBXScalar;
begin
 result:=sqrt(sqr(x-b.x)+sqr(y-b.y)+sqr(z-b.z));
end;

function TpvFBXVector3.Abs:TpvFBXVector3;
begin
 result.x:=System.Abs(x);
 result.y:=System.Abs(y);
 result.z:=System.Abs(z);
end;

function TpvFBXVector3.Dot({$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector3):TpvFBXScalar;
begin
 result:=(x*b.x)+(y*b.y)+(z*b.z);
end;

function TpvFBXVector3.AngleTo(const b:TpvFBXVector3):TpvFBXScalar;
var d:TpvFloat;
begin
 d:=sqrt(SquaredLength*b.SquaredLength);
 if d<>0.0 then begin
  result:=Dot(b)/d;
 end else begin
  result:=0.0;
 end
end;

function TpvFBXVector3.Cross({$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=(y*b.z)-(z*b.y);
 result.y:=(z*b.x)-(x*b.z);
 result.z:=(x*b.y)-(y*b.x);
end;

function TpvFBXVector3.Lerp(const b:TpvFBXVector3;const t:TpvFBXScalar):TpvFBXVector3;
var InvT:TpvFBXScalar;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  InvT:=1.0-t;
  result:=(self*InvT)+(b*t);
 end;
end;

function TpvFBXVector3.Angle(const b,c:TpvFBXVector3):TpvFBXScalar;
var DeltaAB,DeltaCB:TpvFBXVector3;
    LengthAB,LengthCB:TpvFBXScalar;
begin
 DeltaAB:=self-b;
 DeltaCB:=c-b;
 LengthAB:=DeltaAB.Length;
 LengthCB:=DeltaCB.Length;
 if (LengthAB=0.0) or (LengthCB=0.0) then begin
  result:=0.0;
 end else begin
  result:=ArcCos(DeltaAB.Dot(DeltaCB)/(LengthAB*LengthCB));
 end;
end;

function TpvFBXVector3.RotateX(const Angle:TpvFBXScalar):TpvFBXVector3;
var Sinus,Cosinus:TpvFBXScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(Angle,Sinus,Cosinus);
 result.x:=x;
 result.y:=(y*Cosinus)-(z*Sinus);
 result.z:=(y*Sinus)+(z*Cosinus);
end;

function TpvFBXVector3.RotateY(const Angle:TpvFBXScalar):TpvFBXVector3;
var Sinus,Cosinus:TpvFBXScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(Angle,Sinus,Cosinus);
 result.x:=(z*Sinus)+(x*Cosinus);
 result.y:=y;
 result.z:=(z*Cosinus)-(x*Sinus);
end;

function TpvFBXVector3.RotateZ(const Angle:TpvFBXScalar):TpvFBXVector3;
var Sinus,Cosinus:TpvFBXScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(Angle,Sinus,Cosinus);
 result.x:=(x*Cosinus)-(y*Sinus);
 result.y:=(x*Sinus)+(y*Cosinus);
 result.z:=z;
end;

function TpvFBXVector3.ProjectToBounds(const MinVector,MaxVector:TpvFBXVector3):TpvFBXScalar;
begin
 if x<0.0 then begin
  result:=x*MaxVector.x;
 end else begin
  result:=x*MinVector.x;
 end;
 if y<0.0 then begin
  result:=result+(y*MaxVector.y);
 end else begin
  result:=result+(y*MinVector.y);
 end;
 if z<0.0 then begin
  result:=result+(z*MaxVector.z);
 end else begin
  result:=result+(z*MinVector.z);
 end;
end;

constructor TpvFBXVector4.Create(const pX:TpvFBXScalar);
begin
 x:=pX;
 y:=pX;
 z:=pX;
 w:=pX;
end;

constructor TpvFBXVector4.Create(const pX,pY,pZ,pW:TpvFBXScalar);
begin
 x:=pX;
 y:=pY;
 z:=pZ;
 w:=pW;
end;

constructor TpvFBXVector4.Create(const pXY:TpvFBXVector2;const pZ:TpvFBXScalar=0.0;const pW:TpvFBXScalar=1.0);
begin
 x:=pXY.x;
 y:=pXY.y;
 z:=pZ;
 w:=pW;
end;

constructor TpvFBXVector4.Create(const pXYZ:TpvFBXVector3;const pW:TpvFBXScalar=1.0);
begin
 x:=pXYZ.x;
 y:=pXYZ.y;
 z:=pXYZ.z;
 w:=pW;
end;

class operator TpvFBXVector4.Implicit(const a:TpvFBXScalar):TpvFBXVector4;
begin
 result.x:=a;
 result.y:=a;
 result.z:=a;
 result.w:=a;
end;

class operator TpvFBXVector4.Explicit(const a:TpvFBXScalar):TpvFBXVector4;
begin
 result.x:=a;
 result.y:=a;
 result.z:=a;
 result.w:=a;
end;

class operator TpvFBXVector4.Equal(const a,b:TpvFBXVector4):boolean;
begin
 result:=SameValue(a.x,b.x) and SameValue(a.y,b.y) and SameValue(a.z,b.z) and SameValue(a.w,b.w);
end;

class operator TpvFBXVector4.NotEqual(const a,b:TpvFBXVector4):boolean;
begin
 result:=(not SameValue(a.x,b.x)) or (not SameValue(a.y,b.y)) or (not SameValue(a.z,b.z)) or (not SameValue(a.w,b.w));
end;

class operator TpvFBXVector4.Inc({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=a.x+1.0;
 result.y:=a.y+1.0;
 result.z:=a.z+1.0;
 result.w:=a.w+1.0;
end;

class operator TpvFBXVector4.Dec({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=a.x-1.0;
 result.y:=a.y-1.0;
 result.z:=a.z-1.0;
 result.w:=a.w-1.0;
end;

class operator TpvFBXVector4.Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=a.x+b.x;
 result.y:=a.y+b.y;
 result.z:=a.z+b.z;
 result.w:=a.w+b.w;
end;

class operator TpvFBXVector4.Add(const a:TpvFBXVector4;const b:TpvFBXScalar):TpvFBXVector4;
begin
 result.x:=a.x+b;
 result.y:=a.y+b;
 result.z:=a.z+b;
 result.w:=a.w+b;
end;

class operator TpvFBXVector4.Add(const a:TpvFBXScalar;const b:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=a+b.x;
 result.y:=a+b.y;
 result.z:=a+b.z;
 result.w:=a+b.w;
end;

class operator TpvFBXVector4.Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=a.x-b.x;
 result.y:=a.y-b.y;
 result.z:=a.z-b.z;
 result.w:=a.w-b.w;
end;

class operator TpvFBXVector4.Subtract(const a:TpvFBXVector4;const b:TpvFBXScalar):TpvFBXVector4;
begin
 result.x:=a.x-b;
 result.y:=a.y-b;
 result.z:=a.z-b;
 result.w:=a.w-b;
end;

class operator TpvFBXVector4.Subtract(const a:TpvFBXScalar;const b:TpvFBXVector4): TpvFBXVector4;
begin
 result.x:=a-b.x;
 result.y:=a-b.y;
 result.z:=a-b.z;
 result.w:=a-b.w;
end;

class operator TpvFBXVector4.Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=a.x*b.x;
 result.y:=a.y*b.y;
 result.z:=a.z*b.z;
 result.w:=a.w*b.w;
end;

class operator TpvFBXVector4.Multiply(const a:TpvFBXVector4;const b:TpvFBXScalar):TpvFBXVector4;
begin
 result.x:=a.x*b;
 result.y:=a.y*b;
 result.z:=a.z*b;
 result.w:=a.w*b;
end;

class operator TpvFBXVector4.Multiply(const a:TpvFBXScalar;const b:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=a*b.x;
 result.y:=a*b.y;
 result.z:=a*b.z;
 result.w:=a*b.w;
end;

class operator TpvFBXVector4.Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
 result.z:=a.z/b.z;
 result.w:=a.w/b.w;
end;

class operator TpvFBXVector4.Divide(const a:TpvFBXVector4;const b:TpvFBXScalar):TpvFBXVector4;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
 result.z:=a.z/b;
 result.w:=a.w/b;
end;

class operator TpvFBXVector4.Divide(const a:TpvFBXScalar;const b:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=a/b.x;
 result.y:=a/b.y;
 result.z:=a/b.z;
 result.w:=a/b.z;
end;

class operator TpvFBXVector4.IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=a.x/b.x;
 result.y:=a.y/b.y;
 result.z:=a.z/b.z;
 result.w:=a.w/b.w;
end;

class operator TpvFBXVector4.IntDivide(const a:TpvFBXVector4;const b:TpvFBXScalar):TpvFBXVector4;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
 result.z:=a.z/b;
 result.w:=a.w/b;
end;

class operator TpvFBXVector4.IntDivide(const a:TpvFBXScalar;const b:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=a/b.x;
 result.y:=a/b.y;
 result.z:=a/b.z;
 result.w:=a/b.w;
end;

class operator TpvFBXVector4.Modulus(const a,b:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=Modulus(a.x,b.x);
 result.y:=Modulus(a.y,b.y);
 result.z:=Modulus(a.z,b.z);
 result.w:=Modulus(a.w,b.w);
end;

class operator TpvFBXVector4.Modulus(const a:TpvFBXVector4;const b:TpvFBXScalar):TpvFBXVector4;
begin
 result.x:=Modulus(a.x,b);
 result.y:=Modulus(a.y,b);
 result.z:=Modulus(a.z,b);
 result.w:=Modulus(a.w,b);
end;

class operator TpvFBXVector4.Modulus(const a:TpvFBXScalar;const b:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=Modulus(a,b.x);
 result.y:=Modulus(a,b.y);
 result.z:=Modulus(a,b.z);
 result.w:=Modulus(a,b.w);
end;

class operator TpvFBXVector4.Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=-a.x;
 result.y:=-a.y;
 result.z:=-a.z;
 result.w:=-a.w;
end;

class operator TpvFBXVector4.Positive(const a:TpvFBXVector4):TpvFBXVector4;
begin
 result:=a;
end;

function TpvFBXVector4.GetComponent(const pIndex:TpvInt32):TpvFBXScalar;
begin
 result:=RawComponents[pIndex];
end;

procedure TpvFBXVector4.SetComponent(const pIndex:TpvInt32;const pValue:TpvFBXScalar);
begin
 RawComponents[pIndex]:=pValue;
end;

function TpvFBXVector4.Flip:TpvFBXVector4;
begin
 result.x:=x;
 result.y:=z;
 result.z:=-y;
 result.w:=w;
end;

function TpvFBXVector4.Perpendicular:TpvFBXVector4;
var v,p:TpvFBXVector4;
begin
 v:=p.Normalize;
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

function TpvFBXVector4.Length:TpvFBXScalar;
begin
 result:=sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));
end;

function TpvFBXVector4.SquaredLength:TpvFBXScalar;
begin
 result:=sqr(x)+sqr(y)+sqr(z)+sqr(w);
end;

function TpvFBXVector4.Normalize:TpvFBXVector4;
var Factor:TpvFBXScalar;
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

function TpvFBXVector4.DistanceTo({$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector4):TpvFBXScalar;
begin
 result:=sqrt(sqr(x-b.x)+sqr(y-b.y)+sqr(z-b.z)+sqr(w-b.w));
end;

function TpvFBXVector4.Abs:TpvFBXVector4;
begin
 result.x:=System.Abs(x);
 result.y:=System.Abs(y);
 result.z:=System.Abs(z);
 result.w:=System.Abs(w);
end;

function TpvFBXVector4.Dot({$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector4):TpvFBXScalar; {$if not (defined(cpu386) or defined(cpux64))}{$ifdef caninline}inline;{$endif}{$ifend}
begin
 result:=(x*b.x)+(y*b.y)+(z*b.z)+(w*b.w);
end;

function TpvFBXVector4.AngleTo(const b:TpvFBXVector4):TpvFBXScalar;
var d:TpvFloat;
begin
 d:=sqrt(SquaredLength*b.SquaredLength);
 if d<>0.0 then begin
  result:=Dot(b)/d;
 end else begin
  result:=0.0;
 end
end;

function TpvFBXVector4.Cross({$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=(y*b.z)-(z*b.y);
 result.y:=(z*b.x)-(x*b.z);
 result.z:=(x*b.y)-(y*b.x);
 result.w:=1.0;
end;

function TpvFBXVector4.Lerp(const b:TpvFBXVector4;const t:TpvFBXScalar):TpvFBXVector4;
var InvT:TpvFBXScalar;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  InvT:=1.0-t;
  result.x:=(x*InvT)+(b.x*t);
  result.y:=(y*InvT)+(b.y*t);
  result.z:=(z*InvT)+(b.z*t);
  result.w:=(w*InvT)+(b.w*t);
 end;
end;

function TpvFBXVector4.Angle(const b,c:TpvFBXVector4):TpvFBXScalar;
var DeltaAB,DeltaCB:TpvFBXVector4;
    LengthAB,LengthCB:TpvFBXScalar;
begin
 DeltaAB:=self-b;
 DeltaCB:=c-b;
 LengthAB:=DeltaAB.Length;
 LengthCB:=DeltaCB.Length;
 if (LengthAB=0.0) or (LengthCB=0.0) then begin
  result:=0.0;
 end else begin
  result:=ArcCos(DeltaAB.Dot(DeltaCB)/(LengthAB*LengthCB));
 end;
end;

function TpvFBXVector4.RotateX(const Angle:TpvFBXScalar):TpvFBXVector4;
var Sinus,Cosinus:TpvFBXScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(Angle,Sinus,Cosinus);
 result.x:=x;
 result.y:=(y*Cosinus)-(z*Sinus);
 result.z:=(y*Sinus)+(z*Cosinus);
 result.w:=w;
end;

function TpvFBXVector4.RotateY(const Angle:TpvFBXScalar):TpvFBXVector4;
var Sinus,Cosinus:TpvFBXScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(Angle,Sinus,Cosinus);
 result.x:=(z*Sinus)+(x*Cosinus);
 result.y:=y;
 result.z:=(z*Cosinus)-(x*Sinus);
 result.w:=w;
end;

function TpvFBXVector4.RotateZ(const Angle:TpvFBXScalar):TpvFBXVector4;
var Sinus,Cosinus:TpvFBXScalar;
begin
 Sinus:=0.0;
 Cosinus:=0.0;
 SinCos(Angle,Sinus,Cosinus);
 result.x:=(x*Cosinus)-(y*Sinus);
 result.y:=(x*Sinus)+(y*Cosinus);
 result.z:=z;
 result.w:=w;
end;

function TpvFBXVector4.Rotate(const Angle:TpvFBXScalar;const Axis:TpvFBXVector3):TpvFBXVector4;
begin
 result:=TpvFBXMatrix4x4.CreateRotate(Angle,Axis)*self;
end;

function TpvFBXVector4.ProjectToBounds(const MinVector,MaxVector:TpvFBXVector4):TpvFBXScalar;
begin
 if x<0.0 then begin
  result:=x*MaxVector.x;
 end else begin
  result:=x*MinVector.x;
 end;
 if y<0.0 then begin
  result:=result+(y*MaxVector.y);
 end else begin
  result:=result+(y*MinVector.y);
 end;
 if z<0.0 then begin
  result:=result+(z*MaxVector.z);
 end else begin
  result:=result+(z*MinVector.z);
 end;
 if w<0.0 then begin
  result:=result+(w*MaxVector.w);
 end else begin
  result:=result+(w*MinVector.w);
 end;
end;

constructor TpvFBXColor.Create(const pFrom:TpvFBXColor);
begin
 self:=pFrom;
end;

constructor TpvFBXColor.Create(const pRed,pGreen,pBlue:TpvDouble;const pAlpha:TpvDouble=1.0);
begin
 Red:=pRed;
 Green:=pGreen;
 Blue:=pBlue;
 Alpha:=pAlpha;
end;

constructor TpvFBXColor.Create(const pArray:array of TpvDouble);
begin
 Red:=pArray[0];
 Green:=pArray[1];
 Blue:=pArray[2];
 Alpha:=pArray[3];
end;

function TpvFBXColor.GetComponent(const pIndex:TpvInt32):TpvDouble;
begin
 result:=RawComponents[pIndex];
end;

procedure TpvFBXColor.SetComponent(const pIndex:TpvInt32;const pValue:TpvDouble);
begin
 RawComponents[pIndex]:=pValue;
end;

function TpvFBXColor.ToString:TpvFBXString;
begin
 result:='{{R:{'+ConvertDoubleToString(Red,omStandard,-1)+'} G:{'+ConvertDoubleToString(Green,omStandard,-1)+'} B:{'+ConvertDoubleToString(Blue,omStandard,-1)+'} A:{'+ConvertDoubleToString(Alpha,omStandard,-1)+'}}}';
end;

constructor TpvFBXMatrix4x4.Create(const pX:TpvFBXScalar);
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

constructor TpvFBXMatrix4x4.Create(const pXX,pXY,pXZ,pXW,pYX,pYY,pYZ,pYW,pZX,pZY,pZZ,pZW,pWX,pWY,pWZ,pWW:TpvFBXScalar);
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

constructor TpvFBXMatrix4x4.Create(const pX,pY,pZ,pW:TpvFBXVector4);
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

constructor TpvFBXMatrix4x4.CreateRotateX(const Angle:TpvFBXScalar);
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

constructor TpvFBXMatrix4x4.CreateRotateY(const Angle:TpvFBXScalar);
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

constructor TpvFBXMatrix4x4.CreateRotateZ(const Angle:TpvFBXScalar);
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

constructor TpvFBXMatrix4x4.CreateRotate(const Angle:TpvFBXScalar;const Axis:TpvFBXVector3);
var SinusAngle,CosinusAngle:TpvFBXScalar;
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

constructor TpvFBXMatrix4x4.CreateRotation(const pMatrix:TpvFBXMatrix4x4);
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

constructor TpvFBXMatrix4x4.CreateScale(const sx,sy,sz:TpvFBXScalar);
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

constructor TpvFBXMatrix4x4.CreateScale(const pScale:TpvFBXVector3);
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

constructor TpvFBXMatrix4x4.CreateScale(const sx,sy,sz,sw:TpvFBXScalar);
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

constructor TpvFBXMatrix4x4.CreateScale(const pScale:TpvFBXVector4);
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

constructor TpvFBXMatrix4x4.CreateTranslation(const tx,ty,tz:TpvFBXScalar);
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

constructor TpvFBXMatrix4x4.CreateTranslation(const pTranslation:TpvFBXVector3);
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

constructor TpvFBXMatrix4x4.CreateTranslation(const tx,ty,tz,tw:TpvFBXScalar);
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

constructor TpvFBXMatrix4x4.CreateTranslation(const pTranslation:TpvFBXVector4);
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

constructor TpvFBXMatrix4x4.CreateTranslated(const pMatrix:TpvFBXMatrix4x4;pTranslation:TpvFBXVector3);
begin
 RawComponents[0]:=pMatrix.RawComponents[0];
 RawComponents[1]:=pMatrix.RawComponents[1];
 RawComponents[2]:=pMatrix.RawComponents[2];
 RawComponents[3,0]:=(pMatrix.RawComponents[0,0]*pTranslation.x)+(pMatrix.RawComponents[1,0]*pTranslation.y)+(pMatrix.RawComponents[2,0]*pTranslation.z)+pMatrix.RawComponents[3,0];
 RawComponents[3,1]:=(pMatrix.RawComponents[0,1]*pTranslation.x)+(pMatrix.RawComponents[1,1]*pTranslation.y)+(pMatrix.RawComponents[2,1]*pTranslation.z)+pMatrix.RawComponents[3,1];
 RawComponents[3,2]:=(pMatrix.RawComponents[0,2]*pTranslation.x)+(pMatrix.RawComponents[1,2]*pTranslation.y)+(pMatrix.RawComponents[2,2]*pTranslation.z)+pMatrix.RawComponents[3,2];
 RawComponents[3,3]:=(pMatrix.RawComponents[0,3]*pTranslation.x)+(pMatrix.RawComponents[1,3]*pTranslation.y)+(pMatrix.RawComponents[2,3]*pTranslation.z)+pMatrix.RawComponents[3,3];
end;

constructor TpvFBXMatrix4x4.CreateTranslated(const pMatrix:TpvFBXMatrix4x4;pTranslation:TpvFBXVector4);
begin
 RawComponents[0]:=pMatrix.RawComponents[0];
 RawComponents[1]:=pMatrix.RawComponents[1];
 RawComponents[2]:=pMatrix.RawComponents[2];
 RawComponents[3,0]:=(pMatrix.RawComponents[0,0]*pTranslation.x)+(pMatrix.RawComponents[1,0]*pTranslation.y)+(pMatrix.RawComponents[2,0]*pTranslation.z)+(pMatrix.RawComponents[3,0]*pTranslation.w);
 RawComponents[3,1]:=(pMatrix.RawComponents[0,1]*pTranslation.x)+(pMatrix.RawComponents[1,1]*pTranslation.y)+(pMatrix.RawComponents[2,1]*pTranslation.z)+(pMatrix.RawComponents[3,1]*pTranslation.w);
 RawComponents[3,2]:=(pMatrix.RawComponents[0,2]*pTranslation.x)+(pMatrix.RawComponents[1,2]*pTranslation.y)+(pMatrix.RawComponents[2,2]*pTranslation.z)+(pMatrix.RawComponents[3,2]*pTranslation.w);
 RawComponents[3,3]:=(pMatrix.RawComponents[0,3]*pTranslation.x)+(pMatrix.RawComponents[1,3]*pTranslation.y)+(pMatrix.RawComponents[2,3]*pTranslation.z)+(pMatrix.RawComponents[3,3]*pTranslation.w);
end;

constructor TpvFBXMatrix4x4.CreateFromToRotation(const FromDirection,ToDirection:TpvFBXVector3);
const EPSILON=1e-8;
var e,h,hvx,hvz,hvxy,hvxz,hvyz:TpvFBXScalar;
    x,u,v,c:TpvFBXVector3;
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

constructor TpvFBXMatrix4x4.CreateConstruct(const pForwards,pUp:TpvFBXVector3);
var RightVector,UpVector,ForwardVector:TpvFBXVector3;
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

constructor TpvFBXMatrix4x4.CreateOuterProduct(const u,v:TpvFBXVector3);
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

constructor TpvFBXMatrix4x4.CreateFrustum(const Left,Right,Bottom,Top,zNear,zFar:TpvFBXScalar);
var rml,tmb,fmn:TpvFBXScalar;
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

constructor TpvFBXMatrix4x4.CreateOrtho(const Left,Right,Bottom,Top,zNear,zFar:TpvFBXScalar);
var rml,tmb,fmn:TpvFBXScalar;
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

constructor TpvFBXMatrix4x4.CreateOrthoLH(const Left,Right,Bottom,Top,zNear,zFar:TpvFBXScalar);
var rml,tmb,fmn:TpvFBXScalar;
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

constructor TpvFBXMatrix4x4.CreateOrthoRH(const Left,Right,Bottom,Top,zNear,zFar:TpvFBXScalar);
var rml,tmb,fmn:TpvFBXScalar;
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

constructor TpvFBXMatrix4x4.CreateOrthoOffCenterLH(const Left,Right,Bottom,Top,zNear,zFar:TpvFBXScalar);
var rml,tmb,fmn:TpvFBXScalar;
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

constructor TpvFBXMatrix4x4.CreateOrthoOffCenterRH(const Left,Right,Bottom,Top,zNear,zFar:TpvFBXScalar);
var rml,tmb,fmn:TpvFBXScalar;
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

constructor TpvFBXMatrix4x4.CreatePerspective(const fovy,Aspect,zNear,zFar:TpvFBXScalar);
const DEG2RAD=180.0/pi;
var Sine,Cotangent,ZDelta,Radians:TpvFBXScalar;
begin
 Radians:=(fovy*0.5)*DEG2RAD;
 ZDelta:=zFar-zNear;
 Sine:=sin(Radians);
 if not ((ZDelta=0) or (Sine=0) or (aspect=0)) then begin
  Cotangent:=cos(Radians)/Sine;
  RawComponents:=FBXMatrix4x4Identity.RawComponents;
  RawComponents[0,0]:=Cotangent/aspect;
  RawComponents[1,1]:=Cotangent;
  RawComponents[2,2]:=(-(zFar+zNear))/ZDelta;
  RawComponents[2,3]:=-1-0;
  RawComponents[3,2]:=(-(2.0*zNear*zFar))/ZDelta;
  RawComponents[3,3]:=0.0;
 end;
end;

constructor TpvFBXMatrix4x4.CreateLookAt(const Eye,Center,Up:TpvFBXVector3);
var RightVector,UpVector,ForwardVector:TpvFBXVector3;
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

constructor TpvFBXMatrix4x4.CreateFill(const Eye,RightVector,UpVector,ForwardVector:TpvFBXVector3);
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

constructor TpvFBXMatrix4x4.CreateConstructX(const xAxis:TpvFBXVector3);
var a,b,c:TpvFBXVector3;
begin
 a:=xAxis.Normalize;
 RawComponents[0,0]:=a.x;
 RawComponents[0,1]:=a.y;
 RawComponents[0,2]:=a.z;
 RawComponents[0,3]:=0.0;
//b:=TpvFBXVector3.Create(0.0,0.0,1.0).Cross(a).Normalize;
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

constructor TpvFBXMatrix4x4.CreateConstructY(const yAxis:TpvFBXVector3);
var a,b,c:TpvFBXVector3;
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

constructor TpvFBXMatrix4x4.CreateConstructZ(const zAxis:TpvFBXVector3);
var a,b,c:TpvFBXVector3;
begin
 a:=zAxis.Normalize;
 RawComponents[2,0]:=a.x;
 RawComponents[2,1]:=a.y;
 RawComponents[2,2]:=a.z;
 RawComponents[2,3]:=0.0;
//b:=TpvFBXVector3.Create(0.0,1.0,0.0).Cross(a).Normalize;
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

class operator TpvFBXMatrix4x4.Implicit({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Explicit({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Equal({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):boolean;
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

class operator TpvFBXMatrix4x4.NotEqual({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):boolean;
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

class operator TpvFBXMatrix4x4.Inc({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Dec({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Add({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Add({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXScalar):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Add({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Subtract({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Subtract({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXScalar):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Subtract({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4): TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXScalar):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=(a.RawComponents[0,0]*b.x)+(a.RawComponents[1,0]*b.y)+(a.RawComponents[2,0]*b.z)+a.RawComponents[3,0];
 result.y:=(a.RawComponents[0,1]*b.x)+(a.RawComponents[1,1]*b.y)+(a.RawComponents[2,1]*b.z)+a.RawComponents[3,1];
 result.z:=(a.RawComponents[0,2]*b.x)+(a.RawComponents[1,2]*b.y)+(a.RawComponents[2,2]*b.z)+a.RawComponents[3,2];
end;

class operator TpvFBXMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4):TpvFBXVector3;
begin
 result.x:=(a.x*b.RawComponents[0,0])+(a.y*b.RawComponents[0,1])+(a.z*b.RawComponents[0,2])+b.RawComponents[0,3];
 result.y:=(a.x*b.RawComponents[1,0])+(a.y*b.RawComponents[1,1])+(a.z*b.RawComponents[1,2])+b.RawComponents[1,3];
 result.z:=(a.x*b.RawComponents[2,0])+(a.y*b.RawComponents[2,1])+(a.z*b.RawComponents[2,2])+b.RawComponents[2,3];
end;

class operator TpvFBXMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=(a.RawComponents[0,0]*b.x)+(a.RawComponents[1,0]*b.y)+(a.RawComponents[2,0]*b.z)+(a.RawComponents[3,0]*b.w);
 result.y:=(a.RawComponents[0,1]*b.x)+(a.RawComponents[1,1]*b.y)+(a.RawComponents[2,1]*b.z)+(a.RawComponents[3,1]*b.w);
 result.z:=(a.RawComponents[0,2]*b.x)+(a.RawComponents[1,2]*b.y)+(a.RawComponents[2,2]*b.z)+(a.RawComponents[3,2]*b.w);
 result.w:=(a.RawComponents[0,3]*b.x)+(a.RawComponents[1,3]*b.y)+(a.RawComponents[2,3]*b.z)+(a.RawComponents[3,3]*b.w);
end;

class operator TpvFBXMatrix4x4.Multiply({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4):TpvFBXVector4;
begin
 result.x:=(a.x*b.RawComponents[0,0])+(a.y*b.RawComponents[0,1])+(a.z*b.RawComponents[0,2])+(a.w*b.RawComponents[0,3]);
 result.y:=(a.x*b.RawComponents[1,0])+(a.y*b.RawComponents[1,1])+(a.z*b.RawComponents[1,2])+(a.w*b.RawComponents[1,3]);
 result.z:=(a.x*b.RawComponents[2,0])+(a.y*b.RawComponents[2,1])+(a.z*b.RawComponents[2,2])+(a.w*b.RawComponents[2,3]);
 result.w:=(a.x*b.RawComponents[3,0])+(a.y*b.RawComponents[3,1])+(a.z*b.RawComponents[3,2])+(a.w*b.RawComponents[3,3]);
end;

class operator TpvFBXMatrix4x4.Divide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
begin
 result:=a*b.Inverse;
end;

class operator TpvFBXMatrix4x4.Divide({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXScalar):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Divide({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.IntDivide({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
begin
 result:=a*b.Inverse;
end;

class operator TpvFBXMatrix4x4.IntDivide({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXScalar):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.IntDivide({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Modulus({$ifdef fpc}constref{$else}const{$endif} a,b:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
begin
 result.RawComponents[0,0]:=Modulus(a.RawComponents[0,0],b.RawComponents[0,0]);
 result.RawComponents[0,1]:=Modulus(a.RawComponents[0,1],b.RawComponents[0,1]);
 result.RawComponents[0,2]:=Modulus(a.RawComponents[0,2],b.RawComponents[0,2]);
 result.RawComponents[0,3]:=Modulus(a.RawComponents[0,3],b.RawComponents[0,3]);
 result.RawComponents[1,0]:=Modulus(a.RawComponents[1,0],b.RawComponents[1,0]);
 result.RawComponents[1,1]:=Modulus(a.RawComponents[1,1],b.RawComponents[1,1]);
 result.RawComponents[1,2]:=Modulus(a.RawComponents[1,2],b.RawComponents[1,2]);
 result.RawComponents[1,3]:=Modulus(a.RawComponents[1,3],b.RawComponents[1,3]);
 result.RawComponents[2,0]:=Modulus(a.RawComponents[2,0],b.RawComponents[2,0]);
 result.RawComponents[2,1]:=Modulus(a.RawComponents[2,1],b.RawComponents[2,1]);
 result.RawComponents[2,2]:=Modulus(a.RawComponents[2,2],b.RawComponents[2,2]);
 result.RawComponents[2,3]:=Modulus(a.RawComponents[2,3],b.RawComponents[2,3]);
 result.RawComponents[3,0]:=Modulus(a.RawComponents[3,0],b.RawComponents[3,0]);
 result.RawComponents[3,1]:=Modulus(a.RawComponents[3,1],b.RawComponents[3,1]);
 result.RawComponents[3,2]:=Modulus(a.RawComponents[3,2],b.RawComponents[3,2]);
 result.RawComponents[3,3]:=Modulus(a.RawComponents[3,3],b.RawComponents[3,3]);
end;

class operator TpvFBXMatrix4x4.Modulus({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXScalar):TpvFBXMatrix4x4;
begin
 result.RawComponents[0,0]:=Modulus(a.RawComponents[0,0],b);
 result.RawComponents[0,1]:=Modulus(a.RawComponents[0,1],b);
 result.RawComponents[0,2]:=Modulus(a.RawComponents[0,2],b);
 result.RawComponents[0,3]:=Modulus(a.RawComponents[0,3],b);
 result.RawComponents[1,0]:=Modulus(a.RawComponents[1,0],b);
 result.RawComponents[1,1]:=Modulus(a.RawComponents[1,1],b);
 result.RawComponents[1,2]:=Modulus(a.RawComponents[1,2],b);
 result.RawComponents[1,3]:=Modulus(a.RawComponents[1,3],b);
 result.RawComponents[2,0]:=Modulus(a.RawComponents[2,0],b);
 result.RawComponents[2,1]:=Modulus(a.RawComponents[2,1],b);
 result.RawComponents[2,2]:=Modulus(a.RawComponents[2,2],b);
 result.RawComponents[2,3]:=Modulus(a.RawComponents[2,3],b);
 result.RawComponents[3,0]:=Modulus(a.RawComponents[3,0],b);
 result.RawComponents[3,1]:=Modulus(a.RawComponents[3,1],b);
 result.RawComponents[3,2]:=Modulus(a.RawComponents[3,2],b);
 result.RawComponents[3,3]:=Modulus(a.RawComponents[3,3],b);
end;

class operator TpvFBXMatrix4x4.Modulus({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXScalar;{$ifdef fpc}constref{$else}const{$endif} b:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
begin
 result.RawComponents[0,0]:=Modulus(a,b.RawComponents[0,0]);
 result.RawComponents[0,1]:=Modulus(a,b.RawComponents[0,1]);
 result.RawComponents[0,2]:=Modulus(a,b.RawComponents[0,2]);
 result.RawComponents[0,3]:=Modulus(a,b.RawComponents[0,3]);
 result.RawComponents[1,0]:=Modulus(a,b.RawComponents[1,0]);
 result.RawComponents[1,1]:=Modulus(a,b.RawComponents[1,1]);
 result.RawComponents[1,2]:=Modulus(a,b.RawComponents[1,2]);
 result.RawComponents[1,3]:=Modulus(a,b.RawComponents[1,3]);
 result.RawComponents[2,0]:=Modulus(a,b.RawComponents[2,0]);
 result.RawComponents[2,1]:=Modulus(a,b.RawComponents[2,1]);
 result.RawComponents[2,2]:=Modulus(a,b.RawComponents[2,2]);
 result.RawComponents[2,3]:=Modulus(a,b.RawComponents[2,3]);
 result.RawComponents[3,0]:=Modulus(a,b.RawComponents[3,0]);
 result.RawComponents[3,1]:=Modulus(a,b.RawComponents[3,1]);
 result.RawComponents[3,2]:=Modulus(a,b.RawComponents[3,2]);
 result.RawComponents[3,3]:=Modulus(a,b.RawComponents[3,3]);
end;

class operator TpvFBXMatrix4x4.Negative({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
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

class operator TpvFBXMatrix4x4.Positive(const a:TpvFBXMatrix4x4):TpvFBXMatrix4x4;
begin
 result:=a;
end;

function TpvFBXMatrix4x4.GetComponent(const pIndexA,pIndexB:TpvInt32):TpvFBXScalar;
begin
 result:=RawComponents[pIndexA,pIndexB];
end;

procedure TpvFBXMatrix4x4.SetComponent(const pIndexA,pIndexB:TpvInt32;const pValue:TpvFBXScalar);
begin
 RawComponents[pIndexA,pIndexB]:=pValue;
end;

function TpvFBXMatrix4x4.GetColumn(const pIndex:TpvInt32):TpvFBXVector4;
begin
 result.x:=RawComponents[pIndex,0];
 result.y:=RawComponents[pIndex,1];
 result.z:=RawComponents[pIndex,2];
 result.w:=RawComponents[pIndex,3];
end;

procedure TpvFBXMatrix4x4.SetColumn(const pIndex:TpvInt32;const pValue:TpvFBXVector4);
begin
 RawComponents[pIndex,0]:=pValue.x;
 RawComponents[pIndex,1]:=pValue.y;
 RawComponents[pIndex,2]:=pValue.z;
 RawComponents[pIndex,3]:=pValue.w;
end;

function TpvFBXMatrix4x4.GetRow(const pIndex:TpvInt32):TpvFBXVector4;
begin
 result.x:=RawComponents[0,pIndex];
 result.y:=RawComponents[1,pIndex];
 result.z:=RawComponents[2,pIndex];
 result.w:=RawComponents[3,pIndex];
end;

procedure TpvFBXMatrix4x4.SetRow(const pIndex:TpvInt32;const pValue:TpvFBXVector4);
begin
 RawComponents[0,pIndex]:=pValue.x;
 RawComponents[1,pIndex]:=pValue.y;
 RawComponents[2,pIndex]:=pValue.z;
 RawComponents[3,pIndex]:=pValue.w;
end;

function TpvFBXMatrix4x4.Determinant:TpvFBXScalar;
begin
 result:=(RawComponents[0,0]*((((RawComponents[1,1]*RawComponents[2,2]*RawComponents[3,3])-(RawComponents[1,1]*RawComponents[2,3]*RawComponents[3,2]))-(RawComponents[2,1]*RawComponents[1,2]*RawComponents[3,3])+(RawComponents[2,1]*RawComponents[1,3]*RawComponents[3,2])+(RawComponents[3,1]*RawComponents[1,2]*RawComponents[2,3]))-(RawComponents[3,1]*RawComponents[1,3]*RawComponents[2,2])))+
         (RawComponents[0,1]*(((((-(RawComponents[1,0]*RawComponents[2,2]*RawComponents[3,3]))+(RawComponents[1,0]*RawComponents[2,3]*RawComponents[3,2])+(RawComponents[2,0]*RawComponents[1,2]*RawComponents[3,3]))-(RawComponents[2,0]*RawComponents[1,3]*RawComponents[3,2]))-(RawComponents[3,0]*RawComponents[1,2]*RawComponents[2,3]))+(RawComponents[3,0]*RawComponents[1,3]*RawComponents[2,2])))+
         (RawComponents[0,2]*(((((RawComponents[1,0]*RawComponents[2,1]*RawComponents[3,3])-(RawComponents[1,0]*RawComponents[2,3]*RawComponents[3,1]))-(RawComponents[2,0]*RawComponents[1,1]*RawComponents[3,3]))+(RawComponents[2,0]*RawComponents[1,3]*RawComponents[3,1])+(RawComponents[3,0]*RawComponents[1,1]*RawComponents[2,3]))-(RawComponents[3,0]*RawComponents[1,3]*RawComponents[2,1])))+
         (RawComponents[0,3]*(((((-(RawComponents[1,0]*RawComponents[2,1]*RawComponents[3,2]))+(RawComponents[1,0]*RawComponents[2,2]*RawComponents[3,1])+(RawComponents[2,0]*RawComponents[1,1]*RawComponents[3,2]))-(RawComponents[2,0]*RawComponents[1,2]*RawComponents[3,1]))-(RawComponents[3,0]*RawComponents[1,1]*RawComponents[2,2]))+(RawComponents[3,0]*RawComponents[1,2]*RawComponents[2,1])));
end;

function TpvFBXMatrix4x4.SimpleInverse:TpvFBXMatrix4x4;
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
 result.RawComponents[3,0]:=-PpvFBXVector3(pointer(@RawComponents[3,0]))^.Dot(TpvFBXVector3.Create(RawComponents[0,0],RawComponents[0,1],RawComponents[0,2]));
 result.RawComponents[3,1]:=-PpvFBXVector3(pointer(@RawComponents[3,0]))^.Dot(TpvFBXVector3.Create(RawComponents[1,0],RawComponents[1,1],RawComponents[1,2]));
 result.RawComponents[3,2]:=-PpvFBXVector3(pointer(@RawComponents[3,0]))^.Dot(TpvFBXVector3.Create(RawComponents[2,0],RawComponents[2,1],RawComponents[2,2]));
 result.RawComponents[3,3]:=RawComponents[3,3];
end;

function TpvFBXMatrix4x4.Inverse:TpvFBXMatrix4x4;
var t0,t4,t8,t12,d:TpvFBXScalar;
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

function TpvFBXMatrix4x4.Transpose:TpvFBXMatrix4x4;
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

function TpvFBXMatrix4x4.EulerAngles:TpvFBXVector3;
const EPSILON=1e-8;
var v0,v1:TpvFBXVector3;
begin
 if abs((-1.0)-RawComponents[0,2])<EPSILON then begin
  result.x:=0.0;
  result.y:=pi*0.5;
  result.z:=ArcTan2(RawComponents[1,0],RawComponents[2,0]);
 end else if abs(1.0-RawComponents[0,2])<EPSILON then begin
  result.x:=0.0;
  result.y:=-(pi*0.5);
  result.z:=ArcTan2(-RawComponents[1,0],-RawComponents[2,0]);
 end else begin
  v0.x:=-ArcSin(RawComponents[0,2]);
  v1.x:=pi-v0.x;
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

function TpvFBXMatrix4x4.Normalize:TpvFBXMatrix4x4;
begin
 result.Right.Vector3:=Right.Vector3.Normalize;
 result.RawComponents[0,3]:=RawComponents[0,3];
 result.Up.Vector3:=Up.Vector3.Normalize;
 result.RawComponents[1,3]:=RawComponents[1,3];
 result.Forwards.Vector3:=Forwards.Vector3.Normalize;
 result.RawComponents[2,3]:=RawComponents[2,3];
 result.Translation:=Translation;
end;

function TpvFBXMatrix4x4.OrthoNormalize:TpvFBXMatrix4x4;
var Backup:TpvFBXVector3;
begin
 Backup.x:=RawComponents[0,3];
 Backup.y:=RawComponents[1,3];
 Backup.z:=RawComponents[2,3];
 Normal.Vector3:=Normal.Vector3.Normalize;
 Tangent.Vector3:=(Tangent.Vector3-(Normal.Vector3*Tangent.Vector3.Dot(Normal.Vector3))).Normalize;
 Bitangent.Vector3:=Normal.Vector3.Cross(Tangent.Vector3).Normalize;
 Bitangent.Vector3:=Bitangent.Vector3-(Normal.Vector3*Bitangent.Vector3.Dot(Normal.Vector3));
 Bitangent.Vector3:=(Bitangent.Vector3-(Tangent.Vector3*Bitangent.Vector3.Dot(Tangent.Vector3))).Normalize;
 Tangent.Vector3:=Bitangent.Vector3.Cross(Normal.Vector3).Normalize;
 Normal.Vector3:=Tangent.Vector3.Cross(Bitangent.Vector3).Normalize;
 result.RawComponents:=RawComponents;
 result.RawComponents[0,3]:=Backup.x;
 result.RawComponents[1,3]:=Backup.y;
 result.RawComponents[2,3]:=Backup.z;
end;

function TpvFBXMatrix4x4.RobustOrthoNormalize(const Tolerance:TpvFBXScalar=1e-3):TpvFBXMatrix4x4;
var Backup,Bisector,Axis:TpvFBXVector3;
begin
 Backup.x:=RawComponents[0,3];
 Backup.y:=RawComponents[1,3];
 Backup.z:=RawComponents[2,3];
 begin
  if Normal.Vector3.Length<Tolerance then begin
   // Degenerate case, compute new normal
   Normal.Vector3:=Tangent.Vector3.Cross(Bitangent.Vector3);
   if Normal.Vector3.Length<Tolerance then begin
    Tangent.Vector3:=TpvFBXVector3.Create(1.0,0.0,0.0);
    Bitangent.Vector3:=TpvFBXVector3.Create(0.0,1.0,0.0);
    Normal.Vector3:=TpvFBXVector3.Create(0.0,0.0,1.0);
    RawComponents[0,3]:=Backup.x;
    RawComponents[1,3]:=Backup.y;
    RawComponents[2,3]:=Backup.z;
    exit;
   end;
  end;
  Normal.Vector3:=Normal.Vector3.Normalize;
 end;
 begin
  // Project tangent and bitangent onto the normal orthogonal plane
  Tangent.Vector3:=Tangent.Vector3-(Normal.Vector3*Tangent.Vector3.Dot(Normal.Vector3));
  Bitangent.Vector3:=Bitangent.Vector3-(Normal.Vector3*Bitangent.Vector3.Dot(Normal.Vector3));
 end;
 begin
  // Check for several degenerate cases
  if Tangent.Vector3.Length<Tolerance then begin
   if Bitangent.Vector3.Length<Tolerance then begin
    Tangent.Vector3:=Normal.Vector3.Normalize;
    if (Tangent.x<=Tangent.y) and (Tangent.x<=Tangent.z) then begin
     Tangent.Vector3:=TpvFBXVector3.Create(1.0,0.0,0.0);
    end else if (Tangent.y<=Tangent.x) and (Tangent.y<=Tangent.z) then begin
     Tangent.Vector3:=TpvFBXVector3.Create(0.0,1.0,0.0);
    end else begin
     Tangent.Vector3:=TpvFBXVector3.Create(0.0,0.0,1.0);
    end;
    Tangent.Vector3:=Tangent.Vector3-(Normal.Vector3*Tangent.Vector3.Dot(Normal.Vector3));
    Bitangent.Vector3:=Normal.Vector3.Cross(Tangent.Vector3).Normalize;
   end else begin
    Tangent.Vector3:=Bitangent.Vector3.Cross(Normal.Vector3).Normalize;
   end;
  end else begin
   Tangent.Vector3:=Tangent.Vector3.Normalize;
   if Bitangent.Vector3.Length<Tolerance then begin
    Bitangent.Vector3:=Normal.Vector3.Cross(Tangent.Vector3).Normalize;
   end else begin
    Bitangent.Vector3:=Bitangent.Vector3.Normalize;
    Bisector:=Tangent.Vector3+Bitangent.Vector3;
    if Bisector.Length<Tolerance then begin
     Bisector:=Tangent.Vector3;
    end else begin
     Bisector:=Bisector.Normalize;
    end;
    Axis:=Bisector.Cross(Normal.Vector3).Normalize;
    if Axis.Dot(Tangent.Vector3)>0.0 then begin
     Tangent.Vector3:=(Bisector+Axis).Normalize;
     Bitangent.Vector3:=(Bisector-Axis).Normalize;
    end else begin
     Tangent.Vector3:=(Bisector-Axis).Normalize;
     Bitangent.Vector3:=(Bisector+Axis).Normalize;
    end;
   end;
  end;
 end;
 Bitangent.Vector3:=Normal.Vector3.Cross(Tangent.Vector3).Normalize;
 Tangent.Vector3:=Bitangent.Vector3.Cross(Normal.Vector3).Normalize;
 Normal.Vector3:=Tangent.Vector3.Cross(Bitangent.Vector3).Normalize;
 result.RawComponents:=RawComponents;
 result.RawComponents[0,3]:=Backup.x;
 result.RawComponents[1,3]:=Backup.y;
 result.RawComponents[2,3]:=Backup.z;
end;

function TpvFBXMatrix4x4.ToRotation:TpvFBXMatrix4x4;
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

function TpvFBXMatrix4x4.SimpleLerp(const b:TpvFBXMatrix4x4;const t:TpvFBXScalar):TpvFBXMatrix4x4;
begin
 if t<=0.0 then begin
  result:=self;
 end else if t>=1.0 then begin
  result:=b;
 end else begin
  result:=(self*(1.0-t))+(b*t);
 end;
end;

function TpvFBXMatrix4x4.MulInverse({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3;
var d:TpvFBXScalar;
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
end;

function TpvFBXMatrix4x4.MulInverse({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4;
var d:TpvFBXScalar;
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
end;

function TpvFBXMatrix4x4.MulInverted({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3;
var p:TpvFBXVector3;
begin
 p.x:=a.x-RawComponents[3,0];
 p.y:=a.y-RawComponents[3,1];
 p.z:=a.z-RawComponents[3,2];
 result.x:=(RawComponents[0,0]*p.x)+(RawComponents[0,1]*p.y)+(RawComponents[0,2]*p.z);
 result.y:=(RawComponents[1,0]*p.x)+(RawComponents[1,1]*p.y)+(RawComponents[1,2]*p.z);
 result.z:=(RawComponents[2,0]*p.x)+(RawComponents[2,1]*p.y)+(RawComponents[2,2]*p.z);
end;

function TpvFBXMatrix4x4.MulInverted({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4;
var p:TpvFBXVector3;
begin
 p.x:=a.x-RawComponents[3,0];
 p.y:=a.y-RawComponents[3,1];
 p.z:=a.z-RawComponents[3,2];
 result.x:=(RawComponents[0,0]*p.x)+(RawComponents[0,1]*p.y)+(RawComponents[0,2]*p.z);
 result.y:=(RawComponents[1,0]*p.x)+(RawComponents[1,1]*p.y)+(RawComponents[1,2]*p.z);
 result.z:=(RawComponents[2,0]*p.x)+(RawComponents[2,1]*p.y)+(RawComponents[2,2]*p.z);
 result.w:=a.w;
end;

function TpvFBXMatrix4x4.MulBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=(RawComponents[0,0]*a.x)+(RawComponents[1,0]*a.y)+(RawComponents[2,0]*a.z);
 result.y:=(RawComponents[0,1]*a.x)+(RawComponents[1,1]*a.y)+(RawComponents[2,1]*a.z);
 result.z:=(RawComponents[0,2]*a.x)+(RawComponents[1,2]*a.y)+(RawComponents[2,2]*a.z);
end;

function TpvFBXMatrix4x4.MulBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=(RawComponents[0,0]*a.x)+(RawComponents[1,0]*a.y)+(RawComponents[2,0]*a.z);
 result.y:=(RawComponents[0,1]*a.x)+(RawComponents[1,1]*a.y)+(RawComponents[2,1]*a.z);
 result.z:=(RawComponents[0,2]*a.x)+(RawComponents[1,2]*a.y)+(RawComponents[2,2]*a.z);
 result.w:=a.w;
end;

function TpvFBXMatrix4x4.MulTransposedBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3;
begin
 result.x:=(RawComponents[0,0]*a.x)+(RawComponents[0,1]*a.y)+(RawComponents[0,2]*a.z);
 result.y:=(RawComponents[1,0]*a.x)+(RawComponents[1,1]*a.y)+(RawComponents[1,2]*a.z);
 result.z:=(RawComponents[2,0]*a.x)+(RawComponents[2,1]*a.y)+(RawComponents[2,2]*a.z);
end;

function TpvFBXMatrix4x4.MulTransposedBasis({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4;
begin
 result.x:=(RawComponents[0,0]*a.x)+(RawComponents[0,1]*a.y)+(RawComponents[0,2]*a.z);
 result.y:=(RawComponents[1,0]*a.x)+(RawComponents[1,1]*a.y)+(RawComponents[1,2]*a.z);
 result.z:=(RawComponents[2,0]*a.x)+(RawComponents[2,1]*a.y)+(RawComponents[2,2]*a.z);
 result.w:=a.w;
end;

function TpvFBXMatrix4x4.MulHomogen({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector3):TpvFBXVector3;
var Temporary:TpvFBXVector4;
begin
 Temporary:=self*TpvFBXVector4.Create(a,1.0);
 Temporary:=Temporary/Temporary.w;
 result:=Temporary.Vector3;
end;

function TpvFBXMatrix4x4.MulHomogen({$ifdef fpc}constref{$else}const{$endif} a:TpvFBXVector4):TpvFBXVector4;
begin
 result:=self*a;
 result:=result/result.w;
end;

constructor TpvFBXTimeSpan.Create(const pFrom:TpvFBXTimeSpan);
begin
 self:=pFrom;
end;

constructor TpvFBXTimeSpan.Create(const pStartTime,pEndTime:TpvFBXTime);
begin
 StartTime:=pStartTime;
 EndTime:=pEndTime;
end;

constructor TpvFBXTimeSpan.Create(const pArray:array of TpvFBXTime);
begin
 StartTime:=pArray[0];
 EndTime:=pArray[1];
end;

function TpvFBXTimeSpan.GetComponent(const pIndex:TpvInt32):TpvFBXTime;
begin
 result:=RawComponents[pIndex];
end;

procedure TpvFBXTimeSpan.SetComponent(const pIndex:TpvInt32;const pValue:TpvFBXTime);
begin
 RawComponents[pIndex]:=pValue;
end;

function TpvFBXTimeSpan.ToString:TpvFBXString;
begin
 result:=TpvFBXString('{{StartTime:{'+IntToStr(StartTime)+'} EndTime:{'+IntToStr(EndTime)+'}}}');
end;

constructor TpvFBXVector2Property.Create;
begin
 inherited Create;
 fVector.x:=0.0;
 fVector.y:=0.0;
end;

constructor TpvFBXVector2Property.Create(const pFrom:TpvFBXVector2);
begin
 inherited Create;
 fVector:=pFrom;
end;

constructor TpvFBXVector2Property.Create(const pX,pY:TpvDouble);
begin
 inherited Create;
 fVector.x:=pX;
 fVector.y:=pY;
end;

constructor TpvFBXVector2Property.Create(const pArray:array of TpvDouble);
begin
 inherited Create;
 fVector.x:=pArray[0];
 fVector.y:=pArray[1];
end;

destructor TpvFBXVector2Property.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXVector2Property.GetX:TpvDouble;
begin
 result:=fVector.x;
end;

procedure TpvFBXVector2Property.SetX(const pValue:TpvDouble);
begin
 fVector.x:=pValue;
end;

function TpvFBXVector2Property.GetY:TpvDouble;
begin
 result:=fVector.y;
end;

procedure TpvFBXVector2Property.SetY(const pValue:TpvDouble);
begin
 fVector.y:=pValue;
end;

constructor TpvFBXVector3Property.Create;
begin
 inherited Create;
 fVector.x:=0.0;
 fVector.y:=0.0;
 fVector.z:=0.0;
end;

constructor TpvFBXVector3Property.Create(const pFrom:TpvFBXVector3);
begin
 inherited Create;
 fVector:=pFrom;
end;

constructor TpvFBXVector3Property.Create(const pX,pY,pZ:TpvDouble);
begin
 inherited Create;
 fVector.x:=pX;
 fVector.y:=pY;
 fVector.z:=pZ;
end;

constructor TpvFBXVector3Property.Create(const pArray:array of TpvDouble);
begin
 inherited Create;
 fVector.x:=pArray[0];
 fVector.y:=pArray[1];
 fVector.z:=pArray[2];
end;

destructor TpvFBXVector3Property.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXVector3Property.GetX:TpvDouble;
begin
 result:=fVector.x;
end;

procedure TpvFBXVector3Property.SetX(const pValue:TpvDouble);
begin
 fVector.x:=pValue;
end;

function TpvFBXVector3Property.GetY:TpvDouble;
begin
 result:=fVector.y;
end;

procedure TpvFBXVector3Property.SetY(const pValue:TpvDouble);
begin
 fVector.y:=pValue;
end;

function TpvFBXVector3Property.GetZ:TpvDouble;
begin
 result:=fVector.z;
end;

procedure TpvFBXVector3Property.SetZ(const pValue:TpvDouble);
begin
 fVector.z:=pValue;
end;

constructor TpvFBXVector4Property.Create;
begin
 inherited Create;
 fVector.x:=0.0;
 fVector.y:=0.0;
 fVector.z:=0.0;
 fVector.w:=0.0;
end;

constructor TpvFBXVector4Property.Create(const pFrom:TpvFBXVector4);
begin
 inherited Create;
 fVector:=pFrom;
end;

constructor TpvFBXVector4Property.Create(const pX,pY,pZ,pW:TpvDouble);
begin
 inherited Create;
 fVector.x:=pX;
 fVector.y:=pY;
 fVector.z:=pZ;
 fVector.w:=pw;
end;

constructor TpvFBXVector4Property.Create(const pArray:array of TpvDouble);
begin
 inherited Create;
 fVector.x:=pArray[0];
 fVector.y:=pArray[1];
 fVector.z:=pArray[2];
 fVector.w:=pArray[3];
end;

destructor TpvFBXVector4Property.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXVector4Property.GetX:TpvDouble;
begin
 result:=fVector.x;
end;

procedure TpvFBXVector4Property.SetX(const pValue:TpvDouble);
begin
 fVector.x:=pValue;
end;

function TpvFBXVector4Property.GetY:TpvDouble;
begin
 result:=fVector.y;
end;

procedure TpvFBXVector4Property.SetY(const pValue:TpvDouble);
begin
 fVector.y:=pValue;
end;

function TpvFBXVector4Property.GetZ:TpvDouble;
begin
 result:=fVector.z;
end;

procedure TpvFBXVector4Property.SetZ(const pValue:TpvDouble);
begin
 fVector.z:=pValue;
end;

function TpvFBXVector4Property.GetW:TpvDouble;
begin
 result:=fVector.w;
end;

procedure TpvFBXVector4Property.SetW(const pValue:TpvDouble);
begin
 fVector.w:=pValue;
end;

constructor TpvFBXColorProperty.Create;
begin
 inherited Create;
 fColor.Red:=0.0;
 fColor.Green:=0.0;
 fColor.Blue:=0.0;
 fColor.Alpha:=0.0;
end;

constructor TpvFBXColorProperty.Create(const pFrom:TpvFBXColor);
begin
 inherited Create;
 fColor:=pFrom;
end;

constructor TpvFBXColorProperty.Create(const pRed,pGreen,pBlue:TpvDouble;const pAlpha:TpvDouble=1.0);
begin
 inherited Create;
 fColor.Red:=pRed;
 fColor.Green:=pGreen;
 fColor.Blue:=pBlue;
 fColor.Alpha:=pAlpha;
end;

constructor TpvFBXColorProperty.Create(const pArray:array of TpvDouble);
begin
 inherited Create;
 fColor.Red:=pArray[0];
 fColor.Green:=pArray[1];
 fColor.Blue:=pArray[2];
 fColor.Alpha:=pArray[3];
end;

destructor TpvFBXColorProperty.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXColorProperty.GetRed:TpvDouble;
begin
 result:=fColor.Red;
end;

procedure TpvFBXColorProperty.SetRed(const pValue:TpvDouble);
begin
 fColor.Red:=pValue;
end;

function TpvFBXColorProperty.GetGreen:TpvDouble;
begin
 result:=fColor.Green;
end;

procedure TpvFBXColorProperty.SetGreen(const pValue:TpvDouble);
begin
 fColor.Green:=pValue;
end;

function TpvFBXColorProperty.GetBlue:TpvDouble;
begin
 result:=fColor.Blue;
end;

procedure TpvFBXColorProperty.SetBlue(const pValue:TpvDouble);
begin
 fColor.Blue:=pValue;
end;

function TpvFBXColorProperty.GetAlpha:TpvDouble;
begin
 result:=fColor.Alpha;
end;

procedure TpvFBXColorProperty.SetAlpha(const pValue:TpvDouble);
begin
 fColor.Alpha:=pValue;
end;

function StreamReadInt8(const pStream:TStream):TpvInt8;
begin
 result:=0;
 pStream.ReadBuffer(result,SizeOf(TpvInt8));
end;

function StreamReadInt16(const pStream:TStream):TpvInt16;
type TBytes=array[0..1] of TpvUInt8;
var Bytes:TBytes;
    Temporary:TpvUInt16;
begin
 Bytes[0]:=0;
 pStream.ReadBuffer(Bytes,SizeOf(TBytes));
 Temporary:=(TpvUInt16(Bytes[0]) shl 0) or (TpvUInt16(Bytes[1]) shl 8);
 result:=TpvInt16(pointer(@Temporary)^);
end;

function StreamReadInt32(const pStream:TStream):TpvInt32;
type TBytes=array[0..3] of TpvUInt8;
var Bytes:TBytes;
    Temporary:TpvUInt32;
begin
 Bytes[0]:=0;
 pStream.ReadBuffer(Bytes,SizeOf(TBytes));
 Temporary:=(TpvUInt32(Bytes[0]) shl 0) or (TpvUInt32(Bytes[1]) shl 8) or (TpvUInt32(Bytes[2]) shl 16) or (TpvUInt32(Bytes[3]) shl 24);
 result:=TpvInt32(pointer(@Temporary)^);
end;

function StreamReadInt64(const pStream:TStream):TpvInt64;
type TBytes=array[0..7] of TpvUInt8;
var Bytes:TBytes;
    Temporary:TpvUInt64;
begin
 Bytes[0]:=0;
 pStream.ReadBuffer(Bytes,SizeOf(TBytes));
 Temporary:=(TpvUInt64(Bytes[0]) shl 0) or (TpvUInt64(Bytes[1]) shl 8) or (TpvUInt64(Bytes[2]) shl 16) or (TpvUInt64(Bytes[3]) shl 24) or (TpvUInt64(Bytes[4]) shl 32) or (TpvUInt64(Bytes[5]) shl 40) or (TpvUInt64(Bytes[6]) shl 48) or (TpvUInt64(Bytes[7]) shl 56);
 result:=TpvInt64(pointer(@Temporary)^);
end;

function StreamReadUInt8(const pStream:TStream):TpvUInt8;
begin
 result:=0;
 pStream.ReadBuffer(result,SizeOf(TpvUInt8));
end;

function StreamReadUInt16(const pStream:TStream):TpvUInt16;
type TBytes=array[0..1] of TpvUInt8;
var Bytes:TBytes;
begin
 Bytes[0]:=0;
 pStream.ReadBuffer(Bytes,SizeOf(TBytes));
 result:=(TpvUInt16(Bytes[0]) shl 0) or (TpvUInt16(Bytes[1]) shl 8);
end;

function StreamReadUInt32(const pStream:TStream):TpvUInt32;
type TBytes=array[0..3] of TpvUInt8;
var Bytes:TBytes;
begin
 Bytes[0]:=0;
 pStream.ReadBuffer(Bytes,SizeOf(TBytes));
 result:=(TpvUInt32(Bytes[0]) shl 0) or (TpvUInt32(Bytes[1]) shl 8) or (TpvUInt32(Bytes[2]) shl 16) or (TpvUInt32(Bytes[3]) shl 24);
end;

function StreamReadUInt64(const pStream:TStream):TpvUInt64;
type TBytes=array[0..7] of TpvUInt8;
var Bytes:TBytes;
begin
 Bytes[0]:=0;
 pStream.ReadBuffer(Bytes,SizeOf(TBytes));
 result:=(TpvUInt64(Bytes[0]) shl 0) or (TpvUInt64(Bytes[1]) shl 8) or (TpvUInt64(Bytes[2]) shl 16) or (TpvUInt64(Bytes[3]) shl 24) or (TpvUInt64(Bytes[4]) shl 32) or (TpvUInt64(Bytes[5]) shl 40) or (TpvUInt64(Bytes[6]) shl 48) or (TpvUInt64(Bytes[7]) shl 56);
end;

function StreamReadFloat32(const pStream:TStream):TpvFloat;
begin
 TpvUInt32(pointer(@result)^):=StreamReadUInt32(pStream);
end;

function StreamReadFloat64(const pStream:TStream):TpvDouble;
begin
 TpvUInt64(pointer(@result)^):=StreamReadUInt64(pStream);
end;

constructor TpvFBXBaseObject.Create;
begin
 inherited Create;
end;

destructor TpvFBXBaseObject.Destroy;
begin
 inherited Destroy;
end;

constructor TpvFBXElement.Create(const pID:TpvFBXString);
begin
 inherited Create;
 fID:=pID;
 fChildren:=TpvFBXElementList.Create(true);
 fChildrenNameMap:=TpvFBXElementNameMap.Create;
 fProperties:=TpvFBXElementPropertyList.Create(true);
end;

destructor TpvFBXElement.Destroy;
begin
 fProperties.Free;
 fChildrenNameMap.Free;
 fChildren.Free;
 inherited Destroy;
end;

function TpvFBXElement.AddChildren(const pElement:TpvFBXElement):TpvInt32;
begin
 result:=fChildren.Add(pElement);
 if not fChildrenNameMap.ContainsKey(pElement.fID) then begin
  fChildrenNameMap.Add(pElement.fID,pElement);
 end;
end;

function TpvFBXElement.AddProperty(const pProperty:TpvFBXElementProperty):TpvInt32;
begin
 result:=fProperties.Add(pProperty);
end;

constructor TpvFBXElementProperty.Create;
begin
 inherited Create;
end;

destructor TpvFBXElementProperty.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXElementProperty.GetArrayLength:TpvFBXSizeInt;
begin
 result:=1;
end;

function TpvFBXElementProperty.GetVariantValue(const pIndex:TpvFBXSizeInt=0):Variant;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=0;
end;

function TpvFBXElementProperty.GetString(const pIndex:TpvFBXSizeInt=0):TpvFBXString;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=TpvFBXString(String(GetVariantValue));
end;

function TpvFBXElementProperty.GetBoolean(const pIndex:TpvFBXSizeInt=0):Boolean;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=GetVariantValue;
end;

function TpvFBXElementProperty.GetInteger(const pIndex:TpvFBXSizeInt=0):TpvInt64;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=GetVariantValue;
end;

function TpvFBXElementProperty.GetFloat(const pIndex:TpvFBXSizeInt=0):TpvDouble;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=GetVariantValue;
end;

constructor TpvFBXElementPropertyBoolean.Create(const pValue:Boolean);
begin
 inherited Create;
 fValue:=pValue;
end;

destructor TpvFBXElementPropertyBoolean.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXElementPropertyBoolean.GetArrayLength:TpvFBXSizeInt;
begin
 result:=1;
end;

function TpvFBXElementPropertyBoolean.GetVariantValue(const pIndex:TpvFBXSizeInt=0):Variant;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=fValue;
end;

function TpvFBXElementPropertyBoolean.GetString(const pIndex:TpvFBXSizeInt=0):TpvFBXString;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 if fValue then begin
  result:='true';
 end else begin
  result:='false';
 end;
end;

function TpvFBXElementPropertyBoolean.GetBoolean(const pIndex:TpvFBXSizeInt=0):Boolean;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=fValue;
end;

function TpvFBXElementPropertyBoolean.GetInteger(const pIndex:TpvFBXSizeInt=0):TpvInt64;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=ord(fValue) and 1;
end;

function TpvFBXElementPropertyBoolean.GetFloat(const pIndex:TpvFBXSizeInt=0):TpvDouble;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=ord(fValue) and 1;
end;

constructor TpvFBXElementPropertyInteger.Create(const pValue:TpvInt64);
begin
 inherited Create;
 fValue:=pValue;
end;

destructor TpvFBXElementPropertyInteger.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXElementPropertyInteger.GetArrayLength:TpvFBXSizeInt;
begin
 result:=1;
end;

function TpvFBXElementPropertyInteger.GetVariantValue(const pIndex:TpvFBXSizeInt=0):Variant;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=fValue;
end;

function TpvFBXElementPropertyInteger.GetString(const pIndex:TpvFBXSizeInt=0):TpvFBXString;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=TpvFBXString(IntToStr(fValue));
end;

function TpvFBXElementPropertyInteger.GetBoolean(const pIndex:TpvFBXSizeInt=0):Boolean;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=fValue<>0;
end;

function TpvFBXElementPropertyInteger.GetInteger(const pIndex:TpvFBXSizeInt=0):TpvInt64;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=fValue;
end;

function TpvFBXElementPropertyInteger.GetFloat(const pIndex:TpvFBXSizeInt=0):TpvDouble;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=fValue;
end;

constructor TpvFBXElementPropertyFloat.Create(const pValue:TpvDouble);
begin
 inherited Create;
 fValue:=pValue;
end;

destructor TpvFBXElementPropertyFloat.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXElementPropertyFloat.GetArrayLength:TpvFBXSizeInt;
begin
 result:=1;
end;

function TpvFBXElementPropertyFloat.GetVariantValue(const pIndex:TpvFBXSizeInt=0):Variant;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=fValue;
end;

function TpvFBXElementPropertyFloat.GetString(const pIndex:TpvFBXSizeInt=0):TpvFBXString;
var f:TpvDouble;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 f:=fValue;
 result:=ConvertDoubleToString(f,omStandard,-1);
end;

function TpvFBXElementPropertyFloat.GetBoolean(const pIndex:TpvFBXSizeInt=0):Boolean;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=fValue<>0.0;
end;

function TpvFBXElementPropertyFloat.GetInteger(const pIndex:TpvFBXSizeInt=0):TpvInt64;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=trunc(fValue);
end;

function TpvFBXElementPropertyFloat.GetFloat(const pIndex:TpvFBXSizeInt=0):TpvDouble;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=fValue;
end;

constructor TpvFBXElementPropertyBytes.Create(const pValue:TpvFBXBytes);
begin
 inherited Create;
 fValue:=pValue;
end;

destructor TpvFBXElementPropertyBytes.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXElementPropertyBytes.GetArrayLength:TpvFBXSizeInt;
begin
 result:=length(fValue);
end;

function TpvFBXElementPropertyBytes.GetVariantValue(const pIndex:TpvFBXSizeInt=0):Variant;
begin
 if (pIndex<0) or (pIndex>=length(fValue)) then begin
  raise ERangeError.Create('Array index must be greater than or equal zero and less than '+IntToStr(length(fValue)));
 end;
 result:=fValue[pIndex];
end;

function TpvFBXElementPropertyBytes.GetString(const pIndex:TpvFBXSizeInt=0):TpvFBXString;
begin
 if (pIndex<0) or (pIndex>=length(fValue)) then begin
  raise ERangeError.Create('Array index must be greater than or equal zero and less than '+IntToStr(length(fValue)));
 end;
 result:=TpvFBXString(IntToStr(fValue[pIndex]));
end;

function TpvFBXElementPropertyBytes.GetBoolean(const pIndex:TpvFBXSizeInt=0):Boolean;
begin
 if (pIndex<0) or (pIndex>=length(fValue)) then begin
  raise ERangeError.Create('Array index must be greater than or equal zero and less than '+IntToStr(length(fValue)));
 end;
 result:=fValue[pIndex]<>0.0;
end;

function TpvFBXElementPropertyBytes.GetInteger(const pIndex:TpvFBXSizeInt=0):TpvInt64;
begin
 if (pIndex<0) or (pIndex>=length(fValue)) then begin
  raise ERangeError.Create('Array index must be greater than or equal zero and less than '+IntToStr(length(fValue)));
 end;
 result:=fValue[pIndex];
end;

function TpvFBXElementPropertyBytes.GetFloat(const pIndex:TpvFBXSizeInt=0):TpvDouble;
begin
 if (pIndex<0) or (pIndex>=length(fValue)) then begin
  raise ERangeError.Create('Array index must be greater than or equal zero and less than '+IntToStr(length(fValue)));
 end;
 result:=fValue[pIndex];
end;

constructor TpvFBXElementPropertyString.Create(const pValue:TpvFBXString);
begin
 inherited Create;
 fValue:=pValue;
end;

destructor TpvFBXElementPropertyString.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXElementPropertyString.GetArrayLength:TpvFBXSizeInt;
begin
 result:=1;
end;

function TpvFBXElementPropertyString.GetVariantValue(const pIndex:TpvFBXSizeInt=0):Variant;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=fValue;
end;

function TpvFBXElementPropertyString.GetString(const pIndex:TpvFBXSizeInt=0):TpvFBXString;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=fValue;
end;

function TpvFBXElementPropertyString.GetBoolean(const pIndex:TpvFBXSizeInt=0):Boolean;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=(fValue<>'false') and (fValue<>'0');
end;

function TpvFBXElementPropertyString.GetInteger(const pIndex:TpvFBXSizeInt=0):TpvInt64;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 result:=StrToIntDef(String(fValue),0);
end;

function TpvFBXElementPropertyString.GetFloat(const pIndex:TpvFBXSizeInt=0):TpvDouble;
var OK:TPasDblStrUtilsBoolean;
begin
 if pIndex<>0 then begin
  raise ERangeError.Create('Array index must be zero');
 end;
 OK:=false;
 result:=ConvertStringToDouble(TPasDblStrUtilsString(fValue),rmNearest,@OK,-1);
 if not OK then begin
  result:=0.0;
 end;
end;

constructor TpvFBXElementPropertyArray.Create(const pData:pointer;const pDataCount:TpvFBXSizeInt;const pDataType:TpvFBXElementPropertyArrayDataType);
begin
 inherited Create;

 fData:=nil;
 fDataType:=pDataType;
 fDataTypeSize:=DataTypeSizes[fDataType];
 fDataCount:=pDataCount;

 if fDataCount>0 then begin
  SetLength(fData,fDataCount*fDataTypeSize);
  Move(pData^,fData[0],fDataCount*fDataTypeSize);
 end;

end;

constructor TpvFBXElementPropertyArray.CreateFrom(const pStream:TStream;const pDataType:TpvFBXElementPropertyArrayDataType);
const UNCOMPRESSED=0;
      ZLIB_COMPRESSED=1;
var DataStream:TStream;
    Encoding,CompressedLength,Index,OutSize:TpvUInt32;
    OutData:pointer;
begin

 inherited Create;

 fData:=nil;
 fDataType:=pDataType;
 fDataTypeSize:=DataTypeSizes[fDataType];

 fDataCount:=StreamReadUInt32(pStream);
 Encoding:=StreamReadUInt32(pStream);
 CompressedLength:=StreamReadUInt32(pStream);

 DataStream:=TMemoryStream.Create;
 try
  DataStream.CopyFrom(pStream,CompressedLength);
  DataStream.Seek(0,soBeginning);

  case Encoding of
   UNCOMPRESSED:begin
   end;
   ZLIB_COMPRESSED:begin
    OutData:=nil;
    OutSize:=0;
    try
     if DoInflate(TMemoryStream(DataStream).Memory,TMemoryStream(DataStream).Size,OutData,OutSize,true) then begin
{     DataStream.Free;
      DataStream:=TMemoryStream.Create;}
      TMemoryStream(DataStream).Clear;
      TMemoryStream(DataStream).Seek(0,soBeginning);
      TMemoryStream(DataStream).Write(OutData^,OutSize);
      TMemoryStream(DataStream).Seek(0,soBeginning);
     end else begin
      raise EFBXBinaryParser.Create('Corrupt binary FBX file');
     end;
    finally
     if assigned(OutData) then begin
      FreeMem(OutData);
      OutData:=nil;
     end;
    end;
   end;
  end;

  if TpvInt64(fDataCount*fDataTypeSize)<>DataStream.Size then begin
   raise EFBXBinaryParser.Create('Corrupt binary FBX file');
  end;

  SetLength(fData,fDataCount*fDataTypeSize);

  for Index:=1 to fDataCount do begin
   case fDataType of
    TpvFBXElementPropertyArrayDataType.Bool:begin
     Boolean(pointer(@fData[TpvFBXSizeInt(Index-1)*fDataTypeSize])^):=StreamReadUInt8(DataStream)<>0;
    end;
    TpvFBXElementPropertyArrayDataType.Int8:begin
     TpvInt8(pointer(@fData[TpvFBXSizeInt(Index-1)*fDataTypeSize])^):=StreamReadInt8(DataStream);
    end;
    TpvFBXElementPropertyArrayDataType.Int16:begin
     TpvInt16(pointer(@fData[TpvFBXSizeInt(Index-1)*fDataTypeSize])^):=StreamReadInt16(DataStream);
    end;
    TpvFBXElementPropertyArrayDataType.Int32:begin
     TpvInt32(pointer(@fData[TpvFBXSizeInt(Index-1)*fDataTypeSize])^):=StreamReadInt32(DataStream);
    end;
    TpvFBXElementPropertyArrayDataType.Int64:begin
     TpvInt64(pointer(@fData[TpvFBXSizeInt(Index-1)*fDataTypeSize])^):=StreamReadInt64(DataStream);
    end;
    TpvFBXElementPropertyArrayDataType.Float32:begin
     TpvFloat(pointer(@fData[TpvFBXSizeInt(Index-1)*fDataTypeSize])^):=StreamReadFloat32(DataStream);
    end;
    TpvFBXElementPropertyArrayDataType.Float64:begin
     TpvDouble(pointer(@fData[TpvFBXSizeInt(Index-1)*fDataTypeSize])^):=StreamReadFloat64(DataStream);
    end;
   end;
  end;

 finally
  DataStream.Free;
 end;

end;

destructor TpvFBXElementPropertyArray.Destroy;
begin
 fData:=nil;
 inherited Destroy;
end;

function TpvFBXElementPropertyArray.GetArrayLength:TpvFBXSizeInt;
begin
 result:=fDataCount;
end;

function TpvFBXElementPropertyArray.GetVariantValue(const pIndex:TpvFBXSizeInt=0):Variant;
begin
 if (pIndex<0) or (pIndex>=fDataCount) then begin
  raise ERangeError.Create('Array index must be greater than or equal zero and less than '+IntToStr(fDataCount));
 end;
 case fDataType of
  TpvFBXElementPropertyArrayDataType.Bool:begin
   result:=Boolean(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Int8:begin
   result:=TpvInt8(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Int16:begin
   result:=TpvInt16(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Int32:begin
   result:=TpvInt32(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Int64:begin
   result:=TpvInt64(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Float32:begin
   result:=TpvFloat(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Float64:begin
   result:=TpvDouble(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  else begin
   Assert(false,'Unsupported data type');
   result:=0.0;
  end;
 end;
end;

function TpvFBXElementPropertyArray.GetString(const pIndex:TpvFBXSizeInt=0):TpvFBXString;
begin
 if (pIndex<0) or (pIndex>=fDataCount) then begin
  raise ERangeError.Create('Array index must be greater than or equal zero and less than '+IntToStr(fDataCount));
 end;
 case fDataType of
  TpvFBXElementPropertyArrayDataType.Bool:begin
   if Boolean(pointer(@fData[pIndex*fDataTypeSize])^) then begin
    result:='true';
   end else begin
    result:='false';
   end;
  end;
  TpvFBXElementPropertyArrayDataType.Int8:begin
   result:=TpvFBXString(IntToStr(TpvInt8(pointer(@fData[pIndex*fDataTypeSize])^)));
  end;
  TpvFBXElementPropertyArrayDataType.Int16:begin
   result:=TpvFBXString(IntToStr(TpvInt16(pointer(@fData[pIndex*fDataTypeSize])^)));
  end;
  TpvFBXElementPropertyArrayDataType.Int32:begin
   result:=TpvFBXString(IntToStr(TpvInt32(pointer(@fData[pIndex*fDataTypeSize])^)));
  end;
  TpvFBXElementPropertyArrayDataType.Int64:begin
   result:=TpvFBXString(IntToStr(TpvInt64(pointer(@fData[pIndex*fDataTypeSize])^)));
  end;
  TpvFBXElementPropertyArrayDataType.Float32:begin
   result:=TpvFBXString(ConvertDoubleToString(TpvFloat(pointer(@fData[pIndex*fDataTypeSize])^),omStandard,-1));
  end;
  TpvFBXElementPropertyArrayDataType.Float64:begin
   result:=TpvFBXString(ConvertDoubleToString(TpvDouble(pointer(@fData[pIndex*fDataTypeSize])^),omStandard,-1));
  end;
  else begin
   Assert(false,'Unsupported data type');
   result:='';
  end;
 end;
end;

function TpvFBXElementPropertyArray.GetBoolean(const pIndex:TpvFBXSizeInt=0):Boolean;
begin
 if (pIndex<0) or (pIndex>=fDataCount) then begin
  raise ERangeError.Create('Array index must be greater than or equal zero and less than '+IntToStr(fDataCount));
 end;
 case fDataType of
  TpvFBXElementPropertyArrayDataType.Bool:begin
   result:=Boolean(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Int8:begin
   result:=TpvInt8(pointer(@fData[pIndex*fDataTypeSize])^)<>0;
  end;
  TpvFBXElementPropertyArrayDataType.Int16:begin
   result:=TpvInt16(pointer(@fData[pIndex*fDataTypeSize])^)<>0;
  end;
  TpvFBXElementPropertyArrayDataType.Int32:begin
   result:=TpvInt32(pointer(@fData[pIndex*fDataTypeSize])^)<>0;
  end;
  TpvFBXElementPropertyArrayDataType.Int64:begin
   result:=TpvInt64(pointer(@fData[pIndex*fDataTypeSize])^)<>0;
  end;
  TpvFBXElementPropertyArrayDataType.Float32:begin
   result:=TpvFloat(pointer(@fData[pIndex*fDataTypeSize])^)<>0.0;
  end;
  TpvFBXElementPropertyArrayDataType.Float64:begin
   result:=TpvDouble(pointer(@fData[pIndex*fDataTypeSize])^)<>0.0;
  end;
  else begin
   Assert(false,'Unsupported data type');
   result:=false;
  end;
 end;
end;

function TpvFBXElementPropertyArray.GetInteger(const pIndex:TpvFBXSizeInt=0):TpvInt64;
begin
 if (pIndex<0) or (pIndex>=fDataCount) then begin
  raise ERangeError.Create('Array index must be greater than or equal zero and less than '+IntToStr(fDataCount));
 end;
 case fDataType of
  TpvFBXElementPropertyArrayDataType.Bool:begin
   result:=ord(Boolean(pointer(@fData[pIndex*fDataTypeSize])^)) and 1;
  end;
  TpvFBXElementPropertyArrayDataType.Int8:begin
   result:=TpvInt8(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Int16:begin
   result:=TpvInt16(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Int32:begin
   result:=TpvInt32(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Int64:begin
   result:=TpvInt64(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Float32:begin
   result:=trunc(TpvFloat(pointer(@fData[pIndex*fDataTypeSize])^));
  end;
  TpvFBXElementPropertyArrayDataType.Float64:begin
   result:=trunc(TpvDouble(pointer(@fData[pIndex*fDataTypeSize])^));
  end;
  else begin
   Assert(false,'Unsupported data type');
   result:=0;
  end;
 end;
end;

function TpvFBXElementPropertyArray.GetFloat(const pIndex:TpvFBXSizeInt=0):TpvDouble;
begin
 if (pIndex<0) or (pIndex>=fDataCount) then begin
  raise ERangeError.Create('Array index must be greater than or equal zero and less than '+IntToStr(fDataCount));
 end;
 case fDataType of
  TpvFBXElementPropertyArrayDataType.Bool:begin
   result:=ord(Boolean(pointer(@fData[pIndex*fDataTypeSize])^)) and 1;
  end;
  TpvFBXElementPropertyArrayDataType.Int8:begin
   result:=TpvInt8(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Int16:begin
   result:=TpvInt16(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Int32:begin
   result:=TpvInt32(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Int64:begin
   result:=TpvInt64(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Float32:begin
   result:=TpvFloat(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  TpvFBXElementPropertyArrayDataType.Float64:begin
   result:=TpvDouble(pointer(@fData[pIndex*fDataTypeSize])^);
  end;
  else begin
   Assert(false,'Unsupported data type');
   result:=0.0;
  end;
 end;
end;

constructor TpvFBXParser.Create(const pStream:TStream);
begin
 inherited Create;
 fStream:=pStream;
end;

destructor TpvFBXParser.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXParser.SceneName:TpvFBXString;
begin
 result:='';
end;

function TpvFBXParser.GetName(const pRawName:TpvFBXString):TpvFBXString;
begin
 result:=pRawName;
end;

function TpvFBXParser.ConstructName(const pNames:array of TpvFBXString):TpvFBXString;
begin
 result:='';
end;

function TpvFBXParser.NextElement:TpvFBXElement;
begin
 result:=nil;
end;

function TpvFBXParser.Parse:TpvFBXElement;
begin
 result:=nil;
end;

constructor TpvFBXASCIIParser.Create(const pStream:TStream);
var FileSignature:TFileSignature;
begin
 inherited Create(pStream);
 FileSignature[0]:=#0;
 fStream.ReadBuffer(FileSignature,SizeOf(TFileSignature));
 if FileSignature<>FILE_SIGNATURE then begin
  raise EFBXBinaryParser.Create('Not a valid ASCII FBX file');
 end;
 fStream.Seek(-SizeOf(TFileSignature),soCurrent);
end;

destructor TpvFBXASCIIParser.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXASCIIParser.SceneName:TpvFBXString;
begin
 result:='Model::Scene';
end;

function TpvFBXASCIIParser.GetName(const pRawName:TpvFBXString):TpvFBXString;
var Position:TpvFBXSizeInt;
begin
 for Position:=length(pRawName)-1 downto 1 do begin
  if (pRawName[Position]=':') and (pRawName[Position+1]=':') then begin
   result:=Copy(pRawName,Position+2,Length(pRawName)-(Position+1));
   exit;
  end;
 end;
 result:=pRawName;
end;

function TpvFBXASCIIParser.ConstructName(const pNames:array of TpvFBXString):TpvFBXString;
var Index:TpvInt32;
begin
 result:='';
 for Index:=0 to length(pNames)-1 do begin
  if Index>0 then begin
   result:=result+'::';
  end;
  result:=result+pNames[Index];
 end;
end;

function TpvFBXASCIIParser.SkipWhiteSpace:boolean;
var CurrentChar:AnsiChar;
begin
 result:=false;
 CurrentChar:=#0;
 while fStream.Position<fStream.Size do begin
  fStream.ReadBuffer(CurrentChar,SizeOf(AnsiChar));
  case CurrentChar of
   #8,#9,#32:begin
    // Do nothing
   end;
   #10:begin
    result:=true;
    if fStream.Position<fStream.Size then begin
     fStream.ReadBuffer(CurrentChar,SizeOf(AnsiChar));
     if CurrentChar<>#13 then begin
      fStream.Seek(-SizeOf(AnsiChar),soCurrent);
     end;
    end;
   end;
   #13:begin
    result:=true;
    if fStream.Position<fStream.Size then begin
     fStream.ReadBuffer(CurrentChar,SizeOf(AnsiChar));
     if CurrentChar<>#10 then begin
      fStream.Seek(-SizeOf(AnsiChar),soCurrent);
     end;
    end;
   end;
   ';':begin
    // Skip comment line
    result:=true;
    while fStream.Position<fStream.Size do begin
     fStream.ReadBuffer(CurrentChar,SizeOf(AnsiChar));
     case CurrentChar of
      #10:begin
       if fStream.Position<fStream.Size then begin
        fStream.ReadBuffer(CurrentChar,SizeOf(AnsiChar));
        if CurrentChar<>#13 then begin
         fStream.Seek(-SizeOf(AnsiChar),soCurrent);
        end;
       end;
       break;
      end;
      #13:begin
       if fStream.Position<fStream.Size then begin
        fStream.ReadBuffer(CurrentChar,SizeOf(AnsiChar));
        if CurrentChar<>#10 then begin
         fStream.Seek(-SizeOf(AnsiChar),soCurrent);
        end;
       end;
       break;
      end;
     end;
    end;
   end;
   else begin
    fStream.Seek(-SizeOf(AnsiChar),soCurrent);
    break;
   end;
  end;
 end;
end;

procedure TpvFBXASCIIParser.NextToken;
var Len:TpvInt64;
    CurrentChar:AnsiChar;
    OK:TPasDblStrUtilsBoolean;
begin

 fCurrentToken.StringValue:='';
 fCurrentToken.Kind:=TpvFBXASCIIParserTokenKind.None;

 SkipWhiteSpace;

 if fStream.Position>=fStream.Size then begin

  fCurrentToken.Kind:=TpvFBXASCIIParserTokenKind.EOF;

 end else begin

  CurrentChar:=#0;

  fStream.ReadBuffer(CurrentChar,SizeOf(AnsiChar));

  case CurrentChar of
   '"':begin
    fCurrentToken.Kind:=TpvFBXASCIIParserTokenKind.String_;
    while fStream.Position<fStream.Size do begin
     fStream.ReadBuffer(CurrentChar,SizeOf(AnsiChar));
     if CurrentChar='"' then begin
      break;
     end else begin
      fCurrentToken.StringValue:=fCurrentToken.StringValue+CurrentChar;
     end;
    end;
   end;
   ',':begin
    fCurrentToken.Kind:=TpvFBXASCIIParserTokenKind.Comma;
   end;
   '{':begin
    fCurrentToken.Kind:=TpvFBXASCIIParserTokenKind.LeftBrace;
   end;
   '}':begin
    fCurrentToken.Kind:=TpvFBXASCIIParserTokenKind.RightBrace;
   end;
   ':':begin
    fCurrentToken.Kind:=TpvFBXASCIIParserTokenKind.Colon;
   end;
   '*':begin
    fCurrentToken.Kind:=TpvFBXASCIIParserTokenKind.Star;
   end;
   '0'..'9','.','+','-':begin
    Len:=1;
    while fStream.Position<fStream.Size do begin
     fStream.ReadBuffer(CurrentChar,SizeOf(AnsiChar));
     if CurrentChar in ['0'..'9','.','+','-','a'..'f','A'..'F','x','X'] then begin
      inc(Len);
     end else begin
      fStream.Seek(-SizeOf(AnsiChar),soCurrent);
      break;
     end;
    end;
    fStream.Seek(-Len,soCurrent);
    SetLength(fCurrentToken.StringValue,Len*SizeOf(AnsiChar));
    fStream.ReadBuffer(fCurrentToken.StringValue[1],Len*SizeOf(AnsiChar));
    fCurrentToken.Int64Value:=StrToInt64Def(String(fCurrentToken.StringValue),-1);
    if TpvFBXString(IntToStr(fCurrentToken.Int64Value))=fCurrentToken.StringValue then begin
     fCurrentToken.Kind:=TpvFBXASCIIParserTokenKind.Int64;
    end else begin
     fCurrentToken.Kind:=TpvFBXASCIIParserTokenKind.Float64;
     OK:=false;
     fCurrentToken.Float64Value:=ConvertStringToDouble(fCurrentToken.StringValue,rmNearest,@OK,-1);
     if not OK then begin
      raise EFBXASCIIParser.Create('Invalid or corrupt ASCII FBX stream');
     end;
    end;
   end;
   'a'..'z','A'..'Z','|','_':begin
    fCurrentToken.Kind:=TpvFBXASCIIParserTokenKind.AlphaNumberic;
    Len:=1;
    while fStream.Position<fStream.Size do begin
     fStream.ReadBuffer(CurrentChar,SizeOf(AnsiChar));
     if CurrentChar in AlphaNumberic then begin
      inc(Len);
     end else begin
      fStream.Seek(-SizeOf(AnsiChar),soCurrent);
      break;
     end;
    end;
    fStream.Seek(-Len,soCurrent);
    SetLength(fCurrentToken.StringValue,Len*SizeOf(AnsiChar));
    fStream.ReadBuffer(fCurrentToken.StringValue[1],Len*SizeOf(AnsiChar));
   end;
   else begin
    fCurrentToken.Kind:=TpvFBXASCIIParserTokenKind.None;
   end;
  end;

 end;

end;

function TpvFBXASCIIParser.NextElement:TpvFBXElement;
type TProperties=array of TpvFBXASCIIParserToken;
     //PNumberDataType=^TNumberDataType;
     TNumberDataType=
      (
       Int64,
       Float64
      );
     PNumber=^TNumber;
     TNumber=record
      case DataType:TNumberDataType of
       TNumberDataType.Int64:(
        Int64Value:TpvInt64;
       );
       TNumberDataType.Float64:(
        Float64Value:TpvDouble;
       );
     end;
     TNumbers=array of TNumber;
var Current,Element:TpvFBXElement;
    Properties:TProperties;
    Numbers:TNumbers;
    Number:PNumber;
    Int64Array:TpvFBXInt64Array;
    Float64Array:TpvFBXFloat64Array;
    CountProperties,CountNumbers,Index:TpvInt32;
    HasFloat:boolean;
    OldToken:TpvFBXASCIIParserToken;
    OldPosition:TpvInt64;
 procedure FlushProperties;
 var Index:TpvInt32;
     Token:PpvFBXASCIIParserToken;
 begin
  try
   for Index:=0 to CountProperties-1 do begin
    Token:=@Properties[Index];
    case Token^.Kind of
     TpvFBXASCIIParserTokenKind.Int64:begin
      Current.AddProperty(TpvFBXElementPropertyInteger.Create(Token^.Int64Value));
     end;
     TpvFBXASCIIParserTokenKind.Float64:begin
      Current.AddProperty(TpvFBXElementPropertyFloat.Create(Token^.Float64Value));
     end;
     TpvFBXASCIIParserTokenKind.String_:begin
      Current.AddProperty(TpvFBXElementPropertyString.Create(Token^.StringValue));
     end;
     TpvFBXASCIIParserTokenKind.AlphaNumberic:begin
      Current.AddProperty(TpvFBXElementPropertyString.Create(Token^.StringValue));
     end;
     else begin
      raise EFBXASCIIParser.Create('Invalid or corrupt ASCII FBX stream');
     end;
    end;
   end;
  finally
   CountProperties:=0;
  end;
 end;
begin

 if fCurrentToken.Kind<>TpvFBXASCIIParserTokenKind.AlphaNumberic then begin
  raise EFBXASCIIParser.Create('Invalid or corrupt ASCII FBX stream');
 end;

 result:=TpvFBXElement.Create(fCurrentToken.StringValue);

 Current:=result;

 NextToken;

 if fCurrentToken.Kind<>TpvFBXASCIIParserTokenKind.Colon then begin
  raise EFBXASCIIParser.Create('Invalid or corrupt ASCII FBX stream');
 end;

 NextToken;

 Properties:=nil;
 CountProperties:=0;

 try

  repeat

   case fCurrentToken.Kind of
    TpvFBXASCIIParserTokenKind.EOF:begin
     break;
    end;
    TpvFBXASCIIParserTokenKind.LeftBrace:begin
     FlushProperties;
     NextToken;
     repeat
      case fCurrentToken.Kind of
       TpvFBXASCIIParserTokenKind.EOF:begin
        raise EFBXASCIIParser.Create('Invalid or corrupt ASCII FBX stream');
       end;
       TpvFBXASCIIParserTokenKind.RightBrace:begin
        NextToken;
        break;
       end;
       else begin
        Element:=NextElement;
        if assigned(Element) then begin
         result.AddChildren(Element);
        end else begin
         raise EFBXASCIIParser.Create('Invalid or corrupt ASCII FBX stream');
        end;
       end;
      end;
     until false;
     break;
    end;
    TpvFBXASCIIParserTokenKind.Star:begin

     FlushProperties;

     NextToken;

     if not (fCurrentToken.Kind in [TpvFBXASCIIParserTokenKind.Int64,TpvFBXASCIIParserTokenKind.Float64]) then begin
      raise EFBXASCIIParser.Create('Invalid or corrupt ASCII FBX stream');
     end;

     NextToken;

     if fCurrentToken.Kind<>TpvFBXASCIIParserTokenKind.LeftBrace then begin
      raise EFBXASCIIParser.Create('Invalid or corrupt ASCII FBX stream');
     end;

     NextToken;

     if fCurrentToken.Kind<>TpvFBXASCIIParserTokenKind.AlphaNumberic then begin
      raise EFBXASCIIParser.Create('Invalid or corrupt ASCII FBX stream');
     end;

     NextToken;

     if fCurrentToken.Kind<>TpvFBXASCIIParserTokenKind.Colon then begin
      raise EFBXASCIIParser.Create('Invalid or corrupt ASCII FBX stream');
     end;

     NextToken;

     Numbers:=nil;
     try

      HasFloat:=false;

      CountNumbers:=0;
      try

       repeat
        case fCurrentToken.Kind of
         TpvFBXASCIIParserTokenKind.RightBrace,TpvFBXASCIIParserTokenKind.EOF:begin
          break;
         end;
         TpvFBXASCIIParserTokenKind.Int64:begin
          Index:=CountNumbers;
          inc(CountNumbers);
          if length(Numbers)<CountNumbers then begin
           SetLength(Numbers,CountNumbers*2);
          end;
          Number:=@Numbers[Index];
          Number^.DataType:=TNumberDataType.Int64;
          Number^.Int64Value:=fCurrentToken.Int64Value;
          NextToken;
          if fCurrentToken.Kind=TpvFBXASCIIParserTokenKind.Comma then begin
           NextToken;
          end else begin
           break;
          end;
         end;
         TpvFBXASCIIParserTokenKind.Float64:begin
          Index:=CountNumbers;
          inc(CountNumbers);
          if length(Numbers)<CountNumbers then begin
           SetLength(Numbers,CountNumbers*2);
          end;
          Number:=@Numbers[Index];
          Number^.DataType:=TNumberDataType.Float64;
          Number^.Float64Value:=fCurrentToken.Float64Value;
          HasFloat:=true;
          NextToken;
          if fCurrentToken.Kind=TpvFBXASCIIParserTokenKind.Comma then begin
           NextToken;
          end else begin
           break;
          end;
         end;
         else begin
          break;
         end;
        end;
       until false;

      finally
       SetLength(Numbers,CountNumbers);
      end;

      if HasFloat then begin
       Float64Array:=nil;
       try
        SetLength(Float64Array,CountNumbers);
        for Index:=0 to CountNumbers-1 do begin
         Number:=@Numbers[Index];
         case Number^.DataType of
          TNumberDataType.Int64:begin
           Float64Array[Index]:=Number^.Int64Value;
          end;
          TNumberDataType.Float64:begin
           Float64Array[Index]:=Number^.Float64Value;
          end;
          else begin
           raise EFBXASCIIParser.Create('Invalid or corrupt ASCII FBX stream');
          end;
         end;
        end;
        Current.AddProperty(TpvFBXElementPropertyArray.Create(@Float64Array[0],length(Float64Array),TpvFBXElementPropertyArrayDataType.Float64));
       finally
        Float64Array:=nil;
       end;
      end else begin
       Int64Array:=nil;
       try
        SetLength(Int64Array,CountNumbers);
        for Index:=0 to CountNumbers-1 do begin
         Number:=@Numbers[Index];
         case Number^.DataType of
          TNumberDataType.Int64:begin
           Int64Array[Index]:=Number^.Int64Value;
          end;
          TNumberDataType.Float64:begin
           Int64Array[Index]:=trunc(Number^.Float64Value);
          end;
          else begin
           raise EFBXASCIIParser.Create('Invalid or corrupt ASCII FBX stream');
          end;
         end;
        end;
        Current.AddProperty(TpvFBXElementPropertyArray.Create(@Int64Array[0],length(Int64Array),TpvFBXElementPropertyArrayDataType.Int64));
       finally
        Int64Array:=nil;
       end;
      end;

     finally
      Numbers:=nil;
     end;

     if fCurrentToken.Kind<>TpvFBXASCIIParserTokenKind.RightBrace then begin
      raise EFBXASCIIParser.Create('Invalid or corrupt ASCII FBX stream');
     end;

     NextToken;

     break;

    end;
    TpvFBXASCIIParserTokenKind.String_,TpvFBXASCIIParserTokenKind.Int64,TpvFBXASCIIParserTokenKind.Float64:begin
     Index:=CountProperties;
     inc(CountProperties);
     if length(Properties)<CountProperties then begin
      SetLength(Properties,CountProperties*2);
     end;
     Properties[Index]:=fCurrentToken;
     NextToken;
     case fCurrentToken.Kind of
      TpvFBXASCIIParserTokenKind.Comma:begin
       NextToken;
      end;
      TpvFBXASCIIParserTokenKind.LeftBrace:begin
      end;
      TpvFBXASCIIParserTokenKind.RightBrace,TpvFBXASCIIParserTokenKind.EOF:begin
       break;
      end;
      else begin
       break;
      end;
     end;
    end;
    TpvFBXASCIIParserTokenKind.AlphaNumberic:begin
     OldToken:=fCurrentToken;
     OldPosition:=fStream.Position;
     NextToken;
     if fCurrentToken.Kind=TpvFBXASCIIParserTokenKind.Colon then begin
      fStream.Seek(OldPosition,soBeginning);
      fCurrentToken:=OldToken;
      break;
     end;
     Index:=CountProperties;
     inc(CountProperties);
     if length(Properties)<CountProperties then begin
      SetLength(Properties,CountProperties*2);
     end;
     Properties[Index]:=OldToken;
     case fCurrentToken.Kind of
      TpvFBXASCIIParserTokenKind.Comma:begin
       NextToken;
      end;
      TpvFBXASCIIParserTokenKind.LeftBrace:begin
      end;
      TpvFBXASCIIParserTokenKind.RightBrace,TpvFBXASCIIParserTokenKind.EOF:begin
       break;
      end;
      else begin
       break;
      end;
     end;
    end;
   end;
  until false;

  FlushProperties;

 finally
  Properties:=nil;
 end;

end;

function TpvFBXASCIIParser.Parse:TpvFBXElement;
var Element:TpvFBXElement;
begin
 result:=TpvFBXElement.Create('');
 if assigned(result) then begin
  try
   NextToken;
   while fCurrentToken.Kind<>TpvFBXASCIIParserTokenKind.EOF do begin
    Element:=NextElement;
    if assigned(Element) then begin
     result.AddChildren(Element);
    end else begin
     break;
    end;
   end;
  except
   FreeAndNil(result);
   raise;
  end;
 end;
end;

constructor TpvFBXBinaryParser.Create(const pStream:TStream);
var FileSignature:TFileSignature;
begin
 inherited Create(pStream);
 FileSignature[0]:=#0;
 fStream.ReadBuffer(FileSignature,SizeOf(TFileSignature));
 if FileSignature<>FILE_SIGNATURE then begin
  raise EFBXBinaryParser.Create('Not a valid binary FBX file');
 end;
 ReadUInt16;
 fVersion:=ReadUInt32;
end;

destructor TpvFBXBinaryParser.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXBinaryParser.SceneName:TpvFBXString;
begin
 result:='Scene'#0#1'Model';
end;

function TpvFBXBinaryParser.GetName(const pRawName:TpvFBXString):TpvFBXString;
var Position:TpvFBXSizeInt;
begin
 Position:=Pos(#0,String(pRawName));
 if Position>0 then begin
  result:=Copy(pRawName,1,Position-1);
 end else begin
  result:=pRawName;
 end;
end;

function TpvFBXBinaryParser.ConstructName(const pNames:array of TpvFBXString):TpvFBXString;
var Index:TpvInt32;
begin
 result:='';
 for Index:=0 to length(pNames)-1 do begin
  if Index>0 then begin
   result:=TpvFBXString(#0#1)+result;
  end;
  result:=pNames[Index]+result;
 end;
end;

function TpvFBXBinaryParser.ReadInt8:TpvInt8;
begin
 result:=0;
 fStream.ReadBuffer(result,SizeOf(TpvInt8));
end;

function TpvFBXBinaryParser.ReadInt16:TpvInt16;
type TBytes=array[0..1] of TpvUInt8;
var Bytes:TBytes;
    Temporary:TpvUInt16;
begin
 Bytes[0]:=0;
 fStream.ReadBuffer(Bytes,SizeOf(TBytes));
 Temporary:=(TpvUInt16(Bytes[0]) shl 0) or (TpvUInt16(Bytes[1]) shl 8);
 result:=TpvInt16(pointer(@Temporary)^);
end;

function TpvFBXBinaryParser.ReadInt32:TpvInt32;
type TBytes=array[0..3] of TpvUInt8;
var Bytes:TBytes;
    Temporary:TpvUInt32;
begin
 Bytes[0]:=0;
 fStream.ReadBuffer(Bytes,SizeOf(TBytes));
 Temporary:=(TpvUInt32(Bytes[0]) shl 0) or (TpvUInt32(Bytes[1]) shl 8) or (TpvUInt32(Bytes[2]) shl 16) or (TpvUInt32(Bytes[3]) shl 24);
 result:=TpvInt32(pointer(@Temporary)^);
end;

function TpvFBXBinaryParser.ReadInt64:TpvInt64;
type TBytes=array[0..7] of TpvUInt8;
var Bytes:TBytes;
    Temporary:TpvUInt64;
begin
 Bytes[0]:=0;
 fStream.ReadBuffer(Bytes,SizeOf(TBytes));
 Temporary:=(TpvUInt64(Bytes[0]) shl 0) or (TpvUInt64(Bytes[1]) shl 8) or (TpvUInt64(Bytes[2]) shl 16) or (TpvUInt64(Bytes[3]) shl 24) or (TpvUInt64(Bytes[4]) shl 32) or (TpvUInt64(Bytes[5]) shl 40) or (TpvUInt64(Bytes[6]) shl 48) or (TpvUInt64(Bytes[7]) shl 56);
 result:=TpvInt64(pointer(@Temporary)^);
end;

function TpvFBXBinaryParser.ReadUInt8:TpvUInt8;
begin
 result:=0;
 fStream.ReadBuffer(result,SizeOf(TpvUInt8));
end;

function TpvFBXBinaryParser.ReadUInt16:TpvUInt16;
type TBytes=array[0..1] of TpvUInt8;
var Bytes:TBytes;
begin
 Bytes[0]:=0;
 fStream.ReadBuffer(Bytes,SizeOf(TBytes));
 result:=(TpvUInt16(Bytes[0]) shl 0) or (TpvUInt16(Bytes[1]) shl 8);
end;

function TpvFBXBinaryParser.ReadUInt32:TpvUInt32;
type TBytes=array[0..3] of TpvUInt8;
var Bytes:TBytes;
begin
 Bytes[0]:=0;
 fStream.ReadBuffer(Bytes,SizeOf(TBytes));
 result:=(TpvUInt32(Bytes[0]) shl 0) or (TpvUInt32(Bytes[1]) shl 8) or (TpvUInt32(Bytes[2]) shl 16) or (TpvUInt32(Bytes[3]) shl 24);
end;

function TpvFBXBinaryParser.ReadUInt64:TpvUInt64;
type TBytes=array[0..7] of TpvUInt8;
var Bytes:TBytes;
begin
 Bytes[0]:=0;
 fStream.ReadBuffer(Bytes,SizeOf(TBytes));
 result:=(TpvUInt64(Bytes[0]) shl 0) or (TpvUInt64(Bytes[1]) shl 8) or (TpvUInt64(Bytes[2]) shl 16) or (TpvUInt64(Bytes[3]) shl 24) or (TpvUInt64(Bytes[4]) shl 32) or (TpvUInt64(Bytes[5]) shl 40) or (TpvUInt64(Bytes[6]) shl 48) or (TpvUInt64(Bytes[7]) shl 56);
end;

function TpvFBXBinaryParser.ReadFloat32:TpvFloat;
begin
 TpvUInt32(pointer(@result)^):=ReadUInt32;
end;

function TpvFBXBinaryParser.ReadFloat64:TpvDouble;
begin
 TpvUInt64(pointer(@result)^):=ReadUInt64;
end;

function TpvFBXBinaryParser.ReadString(const pLength:TpvInt32):TpvFBXString;
begin
 result:='';
 if pLength>0 then begin
  SetLength(result,pLength);
  fStream.ReadBuffer(result[1],pLength);
 end;
end;

function TpvFBXBinaryParser.NextElement:TpvFBXElement;
const BLOCK_SENTINEL_LENGTH=13;
var EndOffset,CountProperties,PropertiesLength,NameLength,
    PropertyIndex,PropertyDataType:TpvUInt32;
    Bytes:TpvFBXBytes;
    Element:TpvFBXElement;
begin

 EndOffset:=ReadUInt32;
 CountProperties:=ReadUInt32;
 PropertiesLength:=ReadUInt32;
 NameLength:=ReadUInt8;

 if EndOffset=0 then begin
  // Behind a object record, there is 13 zero bytes, which should then match up with the EndOffset.
  result:=nil;
  exit;
 end;

 result:=TpvFBXElement.Create(ReadString(NameLength));

 if (CountProperties>0) and (PropertiesLength>0) then begin
  for PropertyIndex:=1 to CountProperties do begin
   PropertyDataType:=ReadUInt8;
   case PropertyDataType of
    TYPE_BOOL:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyBoolean.Create(ReadUInt8<>0));
    end;
    TYPE_BYTE:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyInteger.Create(ReadInt8));
    end;
    TYPE_INT16:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyInteger.Create(ReadInt16));
    end;
    TYPE_INT32:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyInteger.Create(ReadInt32));
    end;
    TYPE_INT64:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyInteger.Create(ReadInt64));
    end;
    TYPE_FLOAT32:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyFloat.Create(ReadFloat32));
    end;
    TYPE_FLOAT64:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyFloat.Create(ReadFloat64));
    end;
    TYPE_BYTES:begin
     Bytes:=nil;
     try
      SetLength(Bytes,ReadUInt32);
      if length(Bytes)>0 then begin
       fStream.ReadBuffer(Bytes[0],length(Bytes));
      end;
      TpvFBXElement(result).AddProperty(TpvFBXElementPropertyBytes.Create(Bytes));
     finally
      Bytes:=nil;
     end;
    end;
    TYPE_STRING:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyString.Create(ReadString(ReadUInt32)));
    end;
    TYPE_ARRAY_FLOAT32:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyArray.CreateFrom(fStream,TpvFBXElementPropertyArrayDataType.Float32));
    end;
    TYPE_ARRAY_FLOAT64:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyArray.CreateFrom(fStream,TpvFBXElementPropertyArrayDataType.Float64));
    end;
    TYPE_ARRAY_INT16:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyArray.CreateFrom(fStream,TpvFBXElementPropertyArrayDataType.Int16));
    end;
    TYPE_ARRAY_INT32:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyArray.CreateFrom(fStream,TpvFBXElementPropertyArrayDataType.Int32));
    end;
    TYPE_ARRAY_INT64:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyArray.CreateFrom(fStream,TpvFBXElementPropertyArrayDataType.Int64));
    end;
    TYPE_ARRAY_BYTE:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyArray.CreateFrom(fStream,TpvFBXElementPropertyArrayDataType.Int8));
    end;
    TYPE_ARRAY_BOOL:begin
     TpvFBXElement(result).AddProperty(TpvFBXElementPropertyArray.CreateFrom(fStream,TpvFBXElementPropertyArrayDataType.Bool));
    end;
    else begin
     //
    end;
   end;
  end;
 end;

 if fStream.Position<EndOffset then begin
  while (fStream.Position+(BLOCK_SENTINEL_LENGTH-1))<EndOffset do begin
   Element:=NextElement;
   if assigned(Element) then begin
    TpvFBXElement(result).AddChildren(Element);
   end;
  end;
 end;

 if fStream.Position<>EndOffset then begin
  raise EFBXBinaryParser.Create('Corrupt binary FBX file');
 end;

end;

function TpvFBXBinaryParser.Parse:TpvFBXElement;
var Element:TpvFBXElement;
begin
 result:=TpvFBXElement.Create('');
 if assigned(result) then begin
  try
   while fStream.Position<fStream.Size do begin
    Element:=NextElement;
    if assigned(Element) then begin
     result.AddChildren(Element);
    end else begin
     break;
    end;
   end;
  except
   FreeAndNil(result);
   raise
  end;
 end;
end;

constructor TpvFBXTimeUtils.Create(const pGlobalSettings:TpvFBXGlobalSettings);
begin
 inherited Create;
 fGlobalSettings:=pGlobalSettings;
end;

destructor TpvFBXTimeUtils.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXTimeUtils.TimeToFrame(const pTime:TpvFBXTime;const pTimeMode:TpvFBXTimeMode=TpvFBXTimeMode.Default):TpvDouble;
var FramesPerSecond:TpvDouble;
begin
 if (pTimeMode=TpvFBXTimeMode.Custom) or
    ((pTimeMode=TpvFBXTimeMode.Default) and (fGlobalSettings.fTimeMode=TpvFBXTimeMode.Custom)) then begin
  FramesPerSecond:=Max(1.0,fGlobalSettings.fCustomFrameRate);
 end else if pTimeMode=TpvFBXTimeMode.Default then begin
  FramesPerSecond:=FramesPerSecondValues[fGlobalSettings.fTimeMode];
 end else begin
  FramesPerSecond:=FramesPerSecondValues[pTimeMode];
 end;
 result:=pTime*(FramesPerSecond/TpvFBXTimeUtils.UnitsPerSecond);
end;

function TpvFBXTimeUtils.FrameToSeconds(const pFrame:TpvDouble;const pTimeMode:TpvFBXTimeMode=TpvFBXTimeMode.Default):TpvDouble;
var FramesPerSecond:TpvDouble;
begin
 if (pTimeMode=TpvFBXTimeMode.Custom) or
    ((pTimeMode=TpvFBXTimeMode.Default) and (fGlobalSettings.fTimeMode=TpvFBXTimeMode.Custom)) then begin
  FramesPerSecond:=Max(1,fGlobalSettings.fCustomFrameRate);
 end else if pTimeMode=TpvFBXTimeMode.Default then begin
  FramesPerSecond:=FramesPerSecondValues[fGlobalSettings.fTimeMode];
 end else begin
  FramesPerSecond:=FramesPerSecondValues[pTimeMode];
 end;
 result:=pFrame/FramesPerSecond;
end;

function TpvFBXTimeUtils.TimeToSeconds(const pTime:TpvFBXTime):TpvDouble;
begin
 result:=pTime/TpvFBXTimeUtils.UnitsPerSecond;
end;

constructor TpvFBXProperty.Create(const pBaseObject:TObject;const pBaseName:TpvFBXString;const pBasePropInfo:PPropInfo);
begin
 inherited Create;
 fBaseObject:=pBaseObject;
 if not PropertyNameRemap.TryGetValue(pBaseName,fBaseName) then begin
  fBaseName:=pBaseName;
 end;
 fBasePropInfo:=pBasePropInfo;
 if assigned(fBaseObject) and not assigned(fBasePropInfo) then begin
  fBasePropInfo:=GetPropInfo(fBaseObject,String(fBaseName));
 end;
end;

constructor TpvFBXProperty.Create(const pValue:Variant;const pBaseObject:TObject;const pBaseName:TpvFBXString;const pBasePropInfo:PPropInfo);
begin
 Create(pBaseObject,pBaseName,pBasePropInfo);
 if not VarIsEmpty(pValue) then begin
  if assigned(fBasePropInfo) then begin
   SetVariantProp(fBaseObject,fBasePropInfo,pValue);
  end else begin
   fValue:=pValue;
  end;
 end;
end;

destructor TpvFBXProperty.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXProperty.GetValue:Variant;
begin
 if assigned(fBasePropInfo) then begin
  result:=GetVariantProp(fBaseObject,fBasePropInfo);
 end else begin
  result:=fValue;
 end;
end;

procedure TpvFBXProperty.SetValue(const pValue:Variant);
begin
 if assigned(fBasePropInfo) then begin
  SetVariantProp(fBaseObject,fBasePropInfo,pValue);
 end else begin
  fValue:=pValue;
 end;
end;

constructor TpvFBXObject.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
begin
 inherited Create;
 fLoader:=pLoader;
 fElement:=pElement;
 fID:=pID;
 fName:=pName;
 fType_:=pType_;
 fProperties:=TpvFBXPropertyList.Create(true);
 fPropertyNameMap:=TpvFBXPropertyNameMap.Create;
 fConnectedFrom:=TpvFBXObjectList.Create(false);
 fConnectedTo:=TpvFBXObjectList.Create(false);
 fNodeAttributes:=TpvFBXNodeAttributeList.Create(false);
 fReference:='';
end;

destructor TpvFBXObject.Destroy;
begin
 FreeAndNil(fProperties);
 FreeAndNil(fPropertyNameMap);
 FreeAndNil(fConnectedFrom);
 FreeAndNil(fConnectedTo);
 FreeAndNil(fNodeAttributes);
 inherited Destroy;
end;

procedure TpvFBXObject.AfterConstruction;
begin
 inherited AfterConstruction;
 fLoader.fAllocatedList.Add(self);
end;

procedure TpvFBXObject.BeforeDestruction;
var Index:TpvFBXSizeInt;
begin
 Index:=fLoader.fAllocatedList.IndexOf(self);
 if Index>=0 then begin
  fLoader.fAllocatedList.Extract(self);
 end;
 inherited BeforeDestruction;
end;

function TpvFBXObject.GetParentNode:TpvFBXNode;
var CurrentObject:TpvFBXObject;
begin
 if self is TpvFBXNode then begin
  result:=TpvFBXNode(self);
 end else begin
  for CurrentObject in fConnectedFrom do begin
   if CurrentObject is TpvFBXNode then begin
    result:=TpvFBXNode(CurrentObject);
    exit;
   end;
  end;
  for CurrentObject in fConnectedFrom do begin
   result:=CurrentObject.GetParentNode;
   if assigned(result) then begin
    exit;
   end;
  end;
  result:=nil;
 end;
end;

function TpvFBXObject.FindConnectionsByType(const pType_:TpvFBXString):TpvFBXObjects;
var CurrentObject:TpvFBXObject;
    Count:TpvInt32;
begin
 Count:=0;
 for CurrentObject in fConnectedTo do begin
  if CurrentObject.fType_=pType_ then begin
   inc(Count);
  end;
 end;
 result:=nil;
 SetLength(result,Count);
 Count:=0;
 for CurrentObject in fConnectedTo do begin
  if CurrentObject.fType_=pType_ then begin
   result[Count]:=CurrentObject;
   inc(Count);
  end;
 end;
end;

procedure TpvFBXObject.ConnectTo(const pObject:TpvFBXObject);
begin
 fConnectedTo.Add(pObject);
 pObject.fConnectedFrom.Add(self);
end;

procedure TpvFBXObject.ConnectToProperty(const pObject:TpvFBXObject;const pPropertyName:TpvFBXString);
var PropertyName:TpvFBXString;
begin
 if not PropertyNameRemap.TryGetValue(pPropertyName,PropertyName) then begin
  PropertyName:=pPropertyName;
 end;
 AddProperty(pPropertyName).ConnectedFrom:=pObject;
end;

function TpvFBXObject.AddProperty(const pPropertyName:TpvFBXString):TpvFBXProperty;
var PropertyName:TpvFBXString;
begin
 if not PropertyNameRemap.TryGetValue(pPropertyName,PropertyName) then begin
  PropertyName:=pPropertyName;
 end;
 if not fPropertyNameMap.TryGetValue(PropertyName,result) then begin
  result:=TpvFBXProperty.Create(self,PropertyName,nil);
  fPropertyNameMap.AddOrSetValue(PropertyName,result);
 end;
end;

function TpvFBXObject.AddProperty(const pPropertyName:TpvFBXString;const pValue:Variant):TpvFBXProperty;
var PropertyName:TpvFBXString;
begin
 if not PropertyNameRemap.TryGetValue(pPropertyName,PropertyName) then begin
  PropertyName:=pPropertyName;
 end;
 if not fPropertyNameMap.TryGetValue(PropertyName,result) then begin
  result:=TpvFBXProperty.Create(pValue,self,PropertyName,nil);
  fPropertyNameMap.AddOrSetValue(PropertyName,result);
 end;
end;

procedure TpvFBXObject.SetProperty(const pPropertyName:TpvFBXString;const pValue:Variant);
var p:TpvFBXProperty;
    PropertyName:TpvFBXString;
begin
 if not PropertyNameRemap.TryGetValue(pPropertyName,PropertyName) then begin
  PropertyName:=pPropertyName;
 end;
 if fPropertyNameMap.TryGetValue(PropertyName,p) then begin
  p.SetValue(pValue);
 end;
end;

function TpvFBXObject.GetProperty(const pPropertyName:TpvFBXString):Variant;
var p:TpvFBXProperty;
    PropertyName:TpvFBXString;
begin
 if not PropertyNameRemap.TryGetValue(pPropertyName,PropertyName) then begin
  PropertyName:=pPropertyName;
 end;
 if fPropertyNameMap.TryGetValue(PropertyName,p) then begin
  result:=p.GetValue;
 end else begin
  VarClear(result);
 end;
end;

constructor TpvFBXNode.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
begin

 inherited Create(pLoader,pElement,pID,pName,pType_);

 fParent:=nil;

 fChildren:=TpvFBXNodeList.Create(false);

 fLclTranslation:=TpvFBXVector3Property.Create(0.0,0.0,0.0);

 fLclRotation:=TpvFBXVector3Property.Create(0.0,0.0,0.0);

 fLclScaling:=TpvFBXVector3Property.Create(1.0,1.0,1.0);

 fVisibility:=true;

end;

destructor TpvFBXNode.Destroy;
begin
 FreeAndNil(fChildren);
 FreeAndNil(fLclTranslation);
 FreeAndNil(fLclRotation);
 FreeAndNil(fLclScaling);
 inherited Destroy;
end;

procedure TpvFBXNode.ConnectTo(const pObject:TpvFBXObject);
begin
 if fType_='Transform' then begin
  if (fConnectedTo.Count>0) and (fConnectedTo[0] is TpvFBXMesh) then begin
   if assigned(pObject) and (pObject is TpvFBXMaterial) then begin
    TpvFBXMesh(fConnectedTo[0]).fMaterials.Add(TpvFBXMaterial(pObject));
   end;
  end;
 end;
 if assigned(pObject) and (pObject is TpvFBXNode) then begin
  fChildren.Add(TpvFBXNode(pObject));
  TpvFBXNode(pObject).fParent:=self;
 end else begin
  inherited ConnectTo(pObject);
 end;
end;

constructor TpvFBXScene.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
begin
 inherited Create(pLoader,pElement,pID,pName,pType_);
 fAllObjects:=TpvFBXObjectNameMap.Create;
 fHeader:=TpvFBXHeader.Create(pLoader,nil,0,'','');
 fSceneInfo:=nil;
 fCameras:=TpvFBXCameraList.Create(false);
 fLights:=TpvFBXLightList.Create(false);
 fMeshes:=TpvFBXMeshList.Create(false);
 fSkeletons:=TpvFBXSkeletonList.Create(false);
 fMaterials:=TpvFBXMaterialList.Create(false);
 fAnimationStackList:=TpvFBXAnimationStackList.Create(false);
 fDeformers:=TpvFBXDeformerList.Create(false);
 fTextures:=TpvFBXTextureList.Create(false);
 fPoses:=TpvFBXPoseList.Create(false);
 fVideos:=TpvFBXVideoList.Create(false);
 fTakes:=TpvFBXTakeList.Create(false);
 fCurrentTake:=nil;
 fRootNodes:=TpvFBXObjectList.Create(false);
end;

destructor TpvFBXScene.Destroy;
begin
 fCurrentTake:=nil;
 FreeAndNil(fAllObjects);
 FreeAndNil(fHeader);
 FreeAndNil(fSceneInfo);
 FreeAndNil(fCameras);
 FreeAndNil(fLights);
 FreeAndNil(fMeshes);
 FreeAndNil(fSkeletons);
 FreeAndNil(fMaterials);
 FreeAndNil(fAnimationStackList);
 FreeAndNil(fDeformers);
 FreeAndNil(fTextures);
 FreeAndNil(fPoses);
 FreeAndNil(fVideos);
 FreeAndNil(fTakes);
 FreeAndNil(fRootNodes);
 inherited Destroy;
end;

constructor TpvFBXGlobalSettings.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
begin
 inherited Create(pLoader,pElement,pID,pName,pType_);
 fUpAxis:=1;
 fUpAxisSign:=1;
 fFrontAxis:=2;
 fFrontAxisSign:=1;
 fCoordAxis:=0;
 fCoordAxisSign:=1;
 fOriginalUpAxis:=0;
 fOriginalUpAxisSign:=1;
 fUnitScaleFactor:=1.0;
 fOriginalUnitScaleFactor:=1.0;
 fAmbientColor:=TpvFBXColor.Create(0.0,0.0,0.0,0.0);
 fDefaultCamera:='';
 fTimeMode:=TpvFBXTimeMode.Default;
 fTimeProtocol:=0;
 fSnapOnFrameMode:=0;
 fTimeSpan:=TpvFBXTimeSpan.Create(0,0);
 fCustomFrameRate:=-1.0;
end;

destructor TpvFBXGlobalSettings.Destroy;
begin
 inherited Destroy;
end;

function TpvFBXGlobalSettings.GetTimeSpanStart:TpvFBXTime;
begin
 result:=fTimeSpan.StartTime;
end;

procedure TpvFBXGlobalSettings.SetTimeSpanStart(const pValue:TpvFBXTime);
begin
 fTimeSpan.StartTime:=pValue;
end;

function TpvFBXGlobalSettings.GetTimeSpanStop:TpvFBXTime;
begin
 result:=fTimeSpan.EndTime;
end;

procedure TpvFBXGlobalSettings.SetTimeSpanStop(const pValue:TpvFBXTime);
begin
 fTimeSpan.EndTime:=pValue;
end;

constructor TpvFBXCamera.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
var SubElement,SubSubElement:TpvFBXElement;
begin

 inherited Create(pLoader,pElement,pID,pName,pType_);

 fPosition:=TpvFBXVector3Property.Create(0.0,0.0,0.0);
 fLookAt:=TpvFBXVector3Property.Create(0.0,0.0,0.0);
 fCameraOrthoZoom:=1.0;
 fRoll:=0.0;
 fFieldOfView:=0.0;
 fFrameColor:=TpvFBXColorProperty.Create(0.0,0.0,0.0,1.0);
 fNearPlane:=1.0;
 fFarPlane:=10000.0;

 for SubElement in pElement.Children do begin
  if (SubElement.ID='CameraOrthoZoom') and
     (SubElement.Properties.Count>0) then begin
   fCameraOrthoZoom:=SubElement.Properties[0].GetFloat;
  end else if (SubElement.ID='LookAt') and
              (SubElement.Properties.Count>2) then begin
   fLookAt.x:=SubElement.Properties[0].GetFloat;
   fLookAt.y:=SubElement.Properties[1].GetFloat;
   fLookAt.z:=SubElement.Properties[2].GetFloat;
  end else if (SubElement.ID='Position') and
              (SubElement.Properties.Count>2) then begin
   fPosition.x:=SubElement.Properties[0].GetFloat;
   fPosition.y:=SubElement.Properties[1].GetFloat;
   fPosition.z:=SubElement.Properties[2].GetFloat;
  end else if SubElement.ID='Properties60' then begin
   for SubSubElement in SubElement.Children do begin
    if ((SubSubElement.ID='P') or (SubSubElement.ID='Property')) and
       (SubSubElement.Properties.Count>0) then begin
     if (SubSubElement.Properties[0].GetString='Roll') and (3<SubSubElement.Properties.Count) then begin
      fRoll:=SubSubElement.Properties[3].GetFloat;
     end else if (SubSubElement.Properties[0].GetString='FieldOfView') and (3<SubSubElement.Properties.Count) then begin
      fFieldOfView:=SubSubElement.Properties[3].GetFloat;
     end else if (SubSubElement.Properties[0].GetString='FrameColor') and (5<SubSubElement.Properties.Count) then begin
      fFrameColor.Red:=SubSubElement.Properties[3].GetFloat;
      fFrameColor.Green:=SubSubElement.Properties[4].GetFloat;
      fFrameColor.Blue:=SubSubElement.Properties[5].GetFloat;
     end else if (SubSubElement.Properties[0].GetString='NearPlane') and (3<SubSubElement.Properties.Count) then begin
      fNearPlane:=SubSubElement.Properties[3].GetFloat;
     end else if (SubSubElement.Properties[0].GetString='FarPlane') and (3<SubSubElement.Properties.Count) then begin
      fFarPlane:=SubSubElement.Properties[3].GetFloat;
     end;
    end;
   end;
  end;
 end;

end;

destructor TpvFBXCamera.Destroy;
begin
 FreeAndNil(fPosition);
 FreeAndNil(fLookAt);
 FreeAndNil(fFrameColor);
 inherited Destroy;
end;

constructor TpvFBXLight.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
var SubElement,SubSubElement:TpvFBXElement;
begin

 inherited Create(pLoader,pElement,pID,pName,pType_);

 fColor:=TpvFBXColorProperty.Create(1.0,1.0,1.0,1.0);
 fIntensity:=1.0;
 fConeAngle:=1.0;
 fDecay:=NO_DECAY;
 fLightType:=DIRECTIONAL;

 for SubElement in pElement.Children do begin
  if SubElement.ID='Properties60' then begin
   for SubSubElement in SubElement.Children do begin
    if ((SubSubElement.ID='P') or (SubSubElement.ID='Property')) and
       (SubSubElement.Properties.Count>0) then begin
     if (SubSubElement.Properties[0].GetString='Color') and (5<SubSubElement.Properties.Count) then begin
      fColor.Red:=SubSubElement.Properties[3].GetFloat;
      fColor.Green:=SubSubElement.Properties[4].GetFloat;
      fColor.Blue:=SubSubElement.Properties[5].GetFloat;
     end else if (SubSubElement.Properties[0].GetString='Intensity') and (3<SubSubElement.Properties.Count) then begin
      fIntensity:=SubSubElement.Properties[3].GetFloat;
     end else if (SubSubElement.Properties[0].GetString='Cone angle') and (3<SubSubElement.Properties.Count) then begin
      fConeAngle:=SubSubElement.Properties[3].GetFloat;
     end else if (SubSubElement.Properties[0].GetString='LightType') and (3<SubSubElement.Properties.Count) then begin
      fLightType:=SubSubElement.Properties[3].GetInteger;
     end else if (SubSubElement.Properties[0].GetString='Decay') and (3<SubSubElement.Properties.Count) then begin
      fDecay:=SubSubElement.Properties[3].GetInteger;
     end;
    end;
   end;
  end;
 end;

end;

destructor TpvFBXLight.Destroy;
begin
 FreeAndNil(fColor);
 inherited Destroy;
end;

constructor TpvFBXLayerElement<TDataType>.Create;
begin
 inherited Create;
 fMappingMode:=TpvFBXMappingMode.fmmNone;
 fReferenceMode:=TpvFBXReferenceMode.frmDirect;
 fIndexArray:=TpvFBXLayerElementIntegerList.Create;
 fByPolygonVertexIndexArray:=TpvFBXLayerElementIntegerList.Create;
 fData:=TpvFBXLayerElementDataList.Create;
end;

destructor TpvFBXLayerElement<TDataType>.Destroy;
begin
 FreeAndNil(fIndexArray);
 FreeAndNil(fByPolygonVertexIndexArray);
 FreeAndNil(fData);
 inherited Destroy;
end;

procedure TpvFBXLayerElement<TDataType>.Finish(const pMesh:TpvFBXMesh);
type TEdgeMap=TDictionary<TpvFBXMeshEdge,TpvInt64>;
var Index,SubIndex:TpvInt32;
    DataIndex:TpvInt64;
    EdgeMap:TEdgeMap;
    Edge:TpvFBXMeshEdge;
begin
 fByPolygonVertexIndexArray.Clear;
 case fMappingMode of
  TpvFBXMappingMode.fmmByVertex:begin
   for Index:=0 to pMesh.fPolygons.Count-1 do begin
    for SubIndex:=0 to pMesh.fPolygons[Index].Count-1 do begin
     DataIndex:=pMesh.fPolygons[Index][SubIndex];
     if (fReferenceMode=TpvFBXReferenceMode.frmDirect) or (DataIndex>=fIndexArray.Count) then begin
      fByPolygonVertexIndexArray.Add(DataIndex);
     end else begin
      fByPolygonVertexIndexArray.Add(fIndexArray[DataIndex]);
     end;
    end;
   end;
  end;
  TpvFBXMappingMode.fmmByPolygon:begin
   DataIndex:=0;
   for Index:=0 to pMesh.fPolygons.Count-1 do begin
    for SubIndex:=0 to pMesh.fPolygons[Index].Count-1 do begin
     if (fReferenceMode=TpvFBXReferenceMode.frmDirect) or (DataIndex>=fIndexArray.Count) then begin
      fByPolygonVertexIndexArray.Add(DataIndex);
     end else begin
      fByPolygonVertexIndexArray.Add(fIndexArray[DataIndex]);
     end;
    end;
    inc(DataIndex);
   end;
  end;
  TpvFBXMappingMode.fmmByPolygonVertex:begin
   DataIndex:=0;
   for Index:=0 to pMesh.fPolygons.Count-1 do begin
    for SubIndex:=0 to pMesh.fPolygons[Index].Count-1 do begin
     if (fReferenceMode=TpvFBXReferenceMode.frmDirect) or (DataIndex>=fIndexArray.Count) then begin
      fByPolygonVertexIndexArray.Add(DataIndex);
     end else begin
      fByPolygonVertexIndexArray.Add(fIndexArray[DataIndex]);
     end;
     inc(DataIndex);
    end;
   end;
  end;
  TpvFBXMappingMode.fmmByEdge:begin
   EdgeMap:=TEdgeMap.Create;
   try
    for Index:=0 to pMesh.fEdges.Count-1 do begin
     EdgeMap.AddOrSetValue(pMesh.fEdges[Index],Index);
    end;
    for Index:=0 to pMesh.fPolygons.Count-1 do begin
     for SubIndex:=0 to pMesh.fPolygons[Index].Count-1 do begin
      Edge[0]:=pMesh.fPolygons[Index][SubIndex];
      Edge[1]:=pMesh.fPolygons[Index][(SubIndex+1) mod pMesh.fPolygons[Index].Count];
      if not EdgeMap.TryGetValue(Edge,DataIndex) then begin
       Edge[1]:=pMesh.fPolygons[Index][SubIndex];
       Edge[0]:=pMesh.fPolygons[Index][(SubIndex+1) mod pMesh.fPolygons[Index].Count];
       if not EdgeMap.TryGetValue(Edge,DataIndex) then begin
        DataIndex:=0;
       end;
      end;
      if (fReferenceMode=TpvFBXReferenceMode.frmDirect) or (DataIndex>=fIndexArray.Count) then begin
       fByPolygonVertexIndexArray.Add(DataIndex);
      end else begin
       fByPolygonVertexIndexArray.Add(fIndexArray[DataIndex]);
      end;
      inc(DataIndex);
     end;
    end;
   finally
    EdgeMap.Free;
   end;
  end;
  TpvFBXMappingMode.fmmAllSame:begin
   for Index:=0 to pMesh.fPolygons.Count-1 do begin
    for SubIndex:=0 to pMesh.fPolygons[Index].Count-1 do begin
     if (fReferenceMode=TpvFBXReferenceMode.frmDirect) or (fIndexArray.Count=0) then begin
      fByPolygonVertexIndexArray.Add(0);
     end else begin
      fByPolygonVertexIndexArray.Add(fIndexArray[0]);
     end;
    end;
   end;
  end;
  else begin
   raise EFBX.Create('Unknown mapping mode');
  end;
 end;
end;

function TpvFBXLayerElement<TDataType>.GetItem(const pIndex:TpvFBXSizeInt):TDataType;
begin
 result:=fData[pIndex];
end;

procedure TpvFBXLayerElement<TDataType>.SetItem(const pIndex:TpvFBXSizeInt;const pItem:TDataType);
begin
 fData[pIndex]:=pItem;
end;

constructor TpvFBXLayer.Create;
begin
 inherited Create;
 fNormals:=TpvFBXLayerElementVector3.Create;
 fTangents:=TpvFBXLayerElementVector3.Create;
 fBitangents:=TpvFBXLayerElementVector3.Create;
 fUVs:=TpvFBXLayerElementVector2.Create;
 fColors:=TpvFBXLayerElementColor.Create;
 fMaterials:=TpvFBXLayerElementInteger.Create;
end;

destructor TpvFBXLayer.Destroy;
begin
 FreeAndNil(fNormals);
 FreeAndNil(fTangents);
 FreeAndNil(fBitangents);
 FreeAndNil(fUVs);
 FreeAndNil(fColors);
 FreeAndNil(fMaterials);
 inherited Destroy;
end;

constructor TpvFBXMesh.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
 function GetLayer(const pLayerIndex:TpvInt32):TpvFBXLayer;
 begin
  while fLayers.Count<=pLayerIndex do begin
   fLayers.Add(TpvFBXLayer.Create);
  end;
  result:=fLayers[pLayerIndex];
 end;
 function StringToMappingMode(pValue:TpvFBXString):TpvFBXMappingMode;
 begin
  pValue:=TpvFBXString(LowerCase(String(pValue)));
  if (pValue='byvertex') or
     (pValue='byvertice') or
     (pValue='byvertices') or
     (pValue='bycontrolpoint') then begin
   result:=TpvFBXMappingMode.fmmByVertex;
  end else if pValue='bypolygonvertex' then begin
   result:=TpvFBXMappingMode.fmmByPolygonVertex;
  end else if pValue='bypolygon' then begin
   result:=TpvFBXMappingMode.fmmByPolygon;
  end else if pValue='byedge' then begin
   result:=TpvFBXMappingMode.fmmByEdge;
  end else if pValue='allsame' then begin
   result:=TpvFBXMappingMode.fmmAllSame;
  end else begin
   result:=TpvFBXMappingMode.fmmNone;
  end;
 end;
 function StringToReferenceMode(pValue:TpvFBXString):TpvFBXReferenceMode;
 begin
  pValue:=TpvFBXString(LowerCase(String(pValue)));
  if pValue='direct' then begin
   result:=TpvFBXReferenceMode.frmDirect;
  end else if pValue='index' then begin
   result:=TpvFBXReferenceMode.frmIndex;
  end else if pValue='indextodirect' then begin
   result:=TpvFBXReferenceMode.frmIndexToDirect;
  end else begin
   result:=TpvFBXReferenceMode.frmDirect;
  end;
 end;
var SubElement,SubSubElement,ArrayElement:TpvFBXElement;
    Index,LayerIndex:TpvInt32;
    Value:TpvInt64;
    IntList:TpvFBXInt64List;
    FloatList:TpvFBXFloat64List;
    Polygon:TpvFBXMeshIndices;
    Edge:TpvFBXMeshEdge;
    Layer:TpvFBXLayer;
begin

 inherited Create(pLoader,pElement,pID,pName,pType_);

 fVertices:=TpvFBXMeshVertices.Create;

 fPolygons:=TpvFBXMeshPolygons.Create(true);

 fEdges:=TpvFBXMeshEdges.Create;

 fLayers:=TpvFBXLayers.Create(true);

 fClusterMap:=TpvFBXMeshClusterMap.Create(true);

 fTriangleVertices:=TpvFBXMeshTriangleVertexList.Create;

 fTriangleIndices:=TpvFBXInt64List.Create;

 fMaterials:=TpvFBXMaterialList.Create(false);

 if assigned(pElement) then begin
  for SubElement in pElement.Children do begin
   if SubElement.ID='Vertices' then begin
    FloatList:=TpvFBXFloat64List.Create;
    try
     if (SubElement.Properties.Count=1) and (SubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
      FloatList.Capacity:=SubElement.Properties[0].GetArrayLength;
      for Index:=1 to SubElement.Properties[0].GetArrayLength do begin
       FloatList.Add(SubElement.Properties[0].GetFloat(Index-1));
      end;
     end else begin
      if SubElement.Children.Count=1 then begin
       ArrayElement:=SubElement.Children[0];
      end else begin
       ArrayElement:=SubElement;
      end;
      if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
       FloatList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
       for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
        FloatList.Add(ArrayElement.Properties[0].GetFloat(Index-1));
       end;
      end else begin
       FloatList.Capacity:=ArrayElement.Properties.Count;
       for Index:=1 to ArrayElement.Properties.Count do begin
        FloatList.Add(ArrayElement.Properties[Index-1].GetFloat);
       end;
      end;
     end;
     Index:=0;
     while (Index+2)<FloatList.Count do begin
      fVertices.Add(TpvFBXVector3.Create(FloatList[Index+0],FloatList[Index+1],FloatList[Index+2]));
      inc(Index,3);
     end;
    finally
     FloatList.Free;
    end;
   end else if SubElement.ID='PolygonVertexIndex' then begin
    IntList:=TpvFBXInt64List.Create;
    try
     if (SubElement.Properties.Count=1) and (SubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
      IntList.Capacity:=SubElement.Properties[0].GetArrayLength;
      for Index:=1 to SubElement.Properties[0].GetArrayLength do begin
       IntList.Add(SubElement.Properties[0].GetInteger(Index-1));
      end;
     end else begin
      if SubElement.Children.Count=1 then begin
       ArrayElement:=SubElement.Children[0];
      end else begin
       ArrayElement:=SubElement;
      end;
      if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
       IntList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
       for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
        IntList.Add(ArrayElement.Properties[0].GetInteger(Index-1));
       end;
      end else begin
       IntList.Capacity:=ArrayElement.Properties.Count;
       for Index:=1 to ArrayElement.Properties.Count do begin
        IntList.Add(ArrayElement.Properties[Index-1].GetInteger);
       end;
      end;
     end;
     Polygon:=nil;
     for Value in IntList do begin
      if not assigned(Polygon) then begin
       Polygon:=TpvFBXMeshIndices.Create;
       fPolygons.Add(Polygon);
      end;
      if Value<0 then begin
       Polygon.Add(not Value);
       Polygon:=nil;
      end else begin
       Polygon.Add(Value);
      end;
     end;
    finally
     IntList.Free;
    end;
   end else if SubElement.ID='Edges' then begin
    IntList:=TpvFBXInt64List.Create;
    try
     if (SubElement.Properties.Count=1) and (SubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
      IntList.Capacity:=SubElement.Properties[0].GetArrayLength;
      for Index:=1 to SubElement.Properties[0].GetArrayLength do begin
       IntList.Add(SubElement.Properties[0].GetInteger(Index-1));
      end;
     end else begin
      if SubElement.Children.Count=1 then begin
       ArrayElement:=SubElement.Children[0];
      end else begin
       ArrayElement:=SubElement;
      end;
      if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
       IntList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
       for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
        IntList.Add(ArrayElement.Properties[0].GetInteger(Index-1));
       end;
      end else begin
       IntList.Capacity:=ArrayElement.Properties.Count;
       for Index:=1 to ArrayElement.Properties.Count do begin
        IntList.Add(ArrayElement.Properties[Index-1].GetInteger);
       end;
      end;
     end;
     Index:=0;
     while (Index+1)<IntList.Count do begin
      Edge[0]:=IntList[Index+0];
      Edge[1]:=IntList[Index+1];
      fEdges.Add(Edge);
      inc(Index,2);
     end;
    finally
     IntList.Free;
    end;
   end else if (SubElement.ID='LayerElementNormal') or (SubElement.ID='LayerElementNormals') then begin
    LayerIndex:=SubElement.Properties[0].GetInteger;
    if LayerIndex>=0 then begin
     Layer:=GetLayer(LayerIndex);
     if assigned(Layer) then begin
      for SubSubElement in SubElement.Children do begin
       if SubSubElement.ID='MappingInformationType' then begin
        if SubSubElement.Properties.Count>0 then begin
         Layer.Normals.fMappingMode:=StringToMappingMode(SubSubElement.Properties[0].GetString);
        end;
       end else if SubSubElement.ID='ReferenceInformationType' then begin
        if SubSubElement.Properties.Count>0 then begin
         Layer.Normals.fReferenceMode:=StringToReferenceMode(SubSubElement.Properties[0].GetString);
        end;
       end else if (SubSubElement.ID='Normal') or (SubSubElement.ID='Normals') then begin
        FloatList:=TpvFBXFloat64List.Create;
        try
         if (SubSubElement.Properties.Count=1) and (SubSubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
          FloatList.Capacity:=SubSubElement.Properties[0].GetArrayLength;
          for Index:=1 to SubSubElement.Properties[0].GetArrayLength do begin
           FloatList.Add(SubSubElement.Properties[0].GetFloat(Index-1));
          end;
         end else begin
          if SubSubElement.Children.Count=1 then begin
           ArrayElement:=SubSubElement.Children[0];
          end else begin
           ArrayElement:=SubSubElement;
          end;
          if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
           FloatList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
           for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
            FloatList.Add(ArrayElement.Properties[0].GetFloat(Index-1));
           end;
          end else begin
           FloatList.Capacity:=ArrayElement.Properties.Count;
           for Index:=1 to ArrayElement.Properties.Count do begin
            FloatList.Add(ArrayElement.Properties[Index-1].GetFloat);
           end;
          end;
         end;
         Index:=0;
         while (Index+2)<FloatList.Count do begin
          Layer.Normals.fData.Add(TpvFBXVector3.Create(FloatList[Index+0],FloatList[Index+1],FloatList[Index+2]));
          inc(Index,3);
         end;
        finally
         FloatList.Free;
        end;
       end else if (SubSubElement.ID='NormalIndex') or (SubSubElement.ID='NormalsIndex') then begin
        IntList:=TpvFBXInt64List.Create;
        try
         if (SubSubElement.Properties.Count=1) and (SubSubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
          IntList.Capacity:=SubSubElement.Properties[0].GetArrayLength;
          for Index:=1 to SubSubElement.Properties[0].GetArrayLength do begin
           IntList.Add(SubSubElement.Properties[0].GetInteger(Index-1));
          end;
         end else begin
          if SubSubElement.Children.Count=1 then begin
           ArrayElement:=SubSubElement.Children[0];
          end else begin
           ArrayElement:=SubSubElement;
          end;
          if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
           IntList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
           for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
            IntList.Add(ArrayElement.Properties[0].GetInteger(Index-1));
           end;
          end else begin
           IntList.Capacity:=ArrayElement.Properties.Count;
           for Index:=1 to ArrayElement.Properties.Count do begin
            IntList.Add(ArrayElement.Properties[Index-1].GetInteger);
           end;
          end;
         end;
         for Value in IntList do begin
          Layer.Normals.fIndexArray.Add(Value);
         end;
        finally
         IntList.Free;
        end;
       end;
      end;
      Layer.Normals.Finish(self);
     end;
    end;
   end else if (SubElement.ID='LayerElementTangent') or (SubElement.ID='LayerElementTangents') then begin
    LayerIndex:=SubElement.Properties[0].GetInteger;
    if LayerIndex>=0 then begin
     Layer:=GetLayer(LayerIndex);
     if assigned(Layer) then begin
      for SubSubElement in SubElement.Children do begin
       if SubSubElement.ID='MappingInformationType' then begin
        if SubSubElement.Properties.Count>0 then begin
         Layer.Tangents.fMappingMode:=StringToMappingMode(SubSubElement.Properties[0].GetString);
        end;
       end else if SubSubElement.ID='ReferenceInformationType' then begin
        if SubSubElement.Properties.Count>0 then begin
         Layer.Tangents.fReferenceMode:=StringToReferenceMode(SubSubElement.Properties[0].GetString);
        end;
       end else if (SubSubElement.ID='Tangent') or (SubSubElement.ID='Tangents') then begin
        FloatList:=TpvFBXFloat64List.Create;
        try
         if (SubSubElement.Properties.Count=1) and (SubSubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
          FloatList.Capacity:=SubSubElement.Properties[0].GetArrayLength;
          for Index:=1 to SubSubElement.Properties[0].GetArrayLength do begin
           FloatList.Add(SubSubElement.Properties[0].GetFloat(Index-1));
          end;
         end else begin
          if SubSubElement.Children.Count=1 then begin
           ArrayElement:=SubSubElement.Children[0];
          end else begin
           ArrayElement:=SubSubElement;
          end;
          if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
           FloatList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
           for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
            FloatList.Add(ArrayElement.Properties[0].GetFloat(Index-1));
           end;
          end else begin
           FloatList.Capacity:=ArrayElement.Properties.Count;
           for Index:=1 to ArrayElement.Properties.Count do begin
            FloatList.Add(ArrayElement.Properties[Index-1].GetFloat);
           end;
          end;
         end;
         Index:=0;
         while (Index+2)<FloatList.Count do begin
          Layer.Tangents.fData.Add(TpvFBXVector3.Create(FloatList[Index+0],FloatList[Index+1],FloatList[Index+2]));
          inc(Index,3);
         end;
        finally
         FloatList.Free;
        end;
       end else if (SubSubElement.ID='TangentIndex') or (SubSubElement.ID='TangentsIndex') then begin
        IntList:=TpvFBXInt64List.Create;
        try
         if (SubSubElement.Properties.Count=1) and (SubSubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
          IntList.Capacity:=SubSubElement.Properties[0].GetArrayLength;
          for Index:=1 to SubSubElement.Properties[0].GetArrayLength do begin
           IntList.Add(SubSubElement.Properties[0].GetInteger(Index-1));
          end;
         end else begin
          if SubSubElement.Children.Count=1 then begin
           ArrayElement:=SubSubElement.Children[0];
          end else begin
           ArrayElement:=SubSubElement;
          end;
          if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
           IntList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
           for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
            IntList.Add(ArrayElement.Properties[0].GetInteger(Index-1));
           end;
          end else begin
           IntList.Capacity:=ArrayElement.Properties.Count;
           for Index:=1 to ArrayElement.Properties.Count do begin
            IntList.Add(ArrayElement.Properties[Index-1].GetInteger);
           end;
          end;
         end;
         for Value in IntList do begin
          Layer.Tangents.fIndexArray.Add(Value);
         end;
        finally
         IntList.Free;
        end;
       end;
      end;
      Layer.Tangents.Finish(self);
     end;
    end;
   end else if (SubElement.ID='LayerElementBinormal') or (SubElement.ID='LayerElementBinormals') then begin
    LayerIndex:=SubElement.Properties[0].GetInteger;
    if LayerIndex>=0 then begin
     Layer:=GetLayer(LayerIndex);
     if assigned(Layer) then begin
      for SubSubElement in SubElement.Children do begin
       if SubSubElement.ID='MappingInformationType' then begin
        if SubSubElement.Properties.Count>0 then begin
         Layer.Bitangents.fMappingMode:=StringToMappingMode(SubSubElement.Properties[0].GetString);
        end;
       end else if SubSubElement.ID='ReferenceInformationType' then begin
        if SubSubElement.Properties.Count>0 then begin
         Layer.Bitangents.fReferenceMode:=StringToReferenceMode(SubSubElement.Properties[0].GetString);
        end;
       end else if (SubSubElement.ID='Binormal') or (SubSubElement.ID='Binormals') then begin
        FloatList:=TpvFBXFloat64List.Create;
        try
         if (SubSubElement.Properties.Count=1) and (SubSubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
          FloatList.Capacity:=SubSubElement.Properties[0].GetArrayLength;
          for Index:=1 to SubSubElement.Properties[0].GetArrayLength do begin
           FloatList.Add(SubSubElement.Properties[0].GetFloat(Index-1));
          end;
         end else begin
          if SubSubElement.Children.Count=1 then begin
           ArrayElement:=SubSubElement.Children[0];
          end else begin
           ArrayElement:=SubSubElement;
          end;
          if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
           FloatList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
           for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
            FloatList.Add(ArrayElement.Properties[0].GetFloat(Index-1));
           end;
          end else begin
           FloatList.Capacity:=ArrayElement.Properties.Count;
           for Index:=1 to ArrayElement.Properties.Count do begin
            FloatList.Add(ArrayElement.Properties[Index-1].GetFloat);
           end;
          end;
         end;
         Index:=0;
         while (Index+2)<FloatList.Count do begin
          Layer.Bitangents.fData.Add(TpvFBXVector3.Create(FloatList[Index+0],FloatList[Index+1],FloatList[Index+2]));
          inc(Index,3);
         end;
        finally
         FloatList.Free;
        end;
       end else if (SubSubElement.ID='BinormalIndex') or (SubSubElement.ID='BinormalsIndex') then begin
        IntList:=TpvFBXInt64List.Create;
        try
         if (SubSubElement.Properties.Count=1) and (SubSubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
          IntList.Capacity:=SubSubElement.Properties[0].GetArrayLength;
          for Index:=1 to SubSubElement.Properties[0].GetArrayLength do begin
           IntList.Add(SubSubElement.Properties[0].GetInteger(Index-1));
          end;
         end else begin
          if SubSubElement.Children.Count=1 then begin
           ArrayElement:=SubSubElement.Children[0];
          end else begin
           ArrayElement:=SubSubElement;
          end;
          if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
           IntList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
           for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
            IntList.Add(ArrayElement.Properties[0].GetInteger(Index-1));
           end;
          end else begin
           IntList.Capacity:=ArrayElement.Properties.Count;
           for Index:=1 to ArrayElement.Properties.Count do begin
            IntList.Add(ArrayElement.Properties[Index-1].GetInteger);
           end;
          end;
         end;
         for Value in IntList do begin
          Layer.Bitangents.fIndexArray.Add(Value);
         end;
        finally
         IntList.Free;
        end;
       end;
      end;
      Layer.Bitangents.Finish(self);
     end;
    end;
   end else if (SubElement.ID='LayerElementColor') or (SubElement.ID='LayerElementColors') then begin
    LayerIndex:=SubElement.Properties[0].GetInteger;
    if LayerIndex>=0 then begin
     Layer:=GetLayer(LayerIndex);
     if assigned(Layer) then begin
      for SubSubElement in SubElement.Children do begin
       if SubSubElement.ID='MappingInformationType' then begin
        if SubSubElement.Properties.Count>0 then begin
         Layer.Colors.fMappingMode:=StringToMappingMode(SubSubElement.Properties[0].GetString);
        end;
       end else if SubSubElement.ID='ReferenceInformationType' then begin
        if SubSubElement.Properties.Count>0 then begin
         Layer.Colors.fReferenceMode:=StringToReferenceMode(SubSubElement.Properties[0].GetString);
        end;
       end else if (SubSubElement.ID='Color') or (SubSubElement.ID='Colors') then begin
        FloatList:=TpvFBXFloat64List.Create;
        try
         if (SubSubElement.Properties.Count=1) and (SubSubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
          FloatList.Capacity:=SubSubElement.Properties[0].GetArrayLength;
          for Index:=1 to SubSubElement.Properties[0].GetArrayLength do begin
           FloatList.Add(SubSubElement.Properties[0].GetFloat(Index-1));
          end;
         end else begin
          if SubSubElement.Children.Count=1 then begin
           ArrayElement:=SubSubElement.Children[0];
          end else begin
           ArrayElement:=SubSubElement;
          end;
          if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
           FloatList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
           for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
            FloatList.Add(ArrayElement.Properties[0].GetFloat(Index-1));
           end;
          end else begin
           FloatList.Capacity:=ArrayElement.Properties.Count;
           for Index:=1 to ArrayElement.Properties.Count do begin
            FloatList.Add(ArrayElement.Properties[Index-1].GetFloat);
           end;
          end;
         end;
         Index:=0;
         while (Index+3)<FloatList.Count do begin
          Layer.Colors.fData.Add(TpvFBXColor.Create(FloatList[Index+0],FloatList[Index+1],FloatList[Index+2],FloatList[Index+3]));
          inc(Index,4);
         end;
        finally
         FloatList.Free;
        end;
       end else if (SubSubElement.ID='ColorIndex') or (SubSubElement.ID='ColorsIndex') then begin
        IntList:=TpvFBXInt64List.Create;
        try
         if (SubSubElement.Properties.Count=1) and (SubSubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
          IntList.Capacity:=SubSubElement.Properties[0].GetArrayLength;
          for Index:=1 to SubSubElement.Properties[0].GetArrayLength do begin
           IntList.Add(SubSubElement.Properties[0].GetInteger(Index-1));
          end;
         end else begin
          if SubSubElement.Children.Count=1 then begin
           ArrayElement:=SubSubElement.Children[0];
          end else begin
           ArrayElement:=SubSubElement;
          end;
          if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
           IntList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
           for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
            IntList.Add(ArrayElement.Properties[0].GetInteger(Index-1));
           end;
          end else begin
           IntList.Capacity:=ArrayElement.Properties.Count;
           for Index:=1 to ArrayElement.Properties.Count do begin
            IntList.Add(ArrayElement.Properties[Index-1].GetInteger);
           end;
          end;
         end;
         for Value in IntList do begin
          Layer.Colors.fIndexArray.Add(Value);
         end;
        finally
         IntList.Free;
        end;
       end;
      end;
      Layer.Colors.Finish(self);
     end;
    end;
   end else if (SubElement.ID='LayerElementUV') or (SubElement.ID='LayerElementUVs') then begin
    LayerIndex:=SubElement.Properties[0].GetInteger;
    if LayerIndex>=0 then begin
     Layer:=GetLayer(LayerIndex);
     if assigned(Layer) then begin
      for SubSubElement in SubElement.Children do begin
       if SubSubElement.ID='MappingInformationType' then begin
        if SubSubElement.Properties.Count>0 then begin
         Layer.UVs.fMappingMode:=StringToMappingMode(SubSubElement.Properties[0].GetString);
        end;
       end else if SubSubElement.ID='ReferenceInformationType' then begin
        if SubSubElement.Properties.Count>0 then begin
         Layer.UVs.fReferenceMode:=StringToReferenceMode(SubSubElement.Properties[0].GetString);
        end;
       end else if (SubSubElement.ID='UV') or (SubSubElement.ID='UVs') then begin
        FloatList:=TpvFBXFloat64List.Create;
        try
         if (SubSubElement.Properties.Count=1) and (SubSubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
          FloatList.Capacity:=SubSubElement.Properties[0].GetArrayLength;
          for Index:=1 to SubSubElement.Properties[0].GetArrayLength do begin
           FloatList.Add(SubSubElement.Properties[0].GetFloat(Index-1));
          end;
         end else begin
          if SubSubElement.Children.Count=1 then begin
           ArrayElement:=SubSubElement.Children[0];
          end else begin
           ArrayElement:=SubSubElement;
          end;
          if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
           FloatList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
           for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
            FloatList.Add(ArrayElement.Properties[0].GetFloat(Index-1));
           end;
          end else begin
           FloatList.Capacity:=ArrayElement.Properties.Count;
           for Index:=1 to ArrayElement.Properties.Count do begin
            FloatList.Add(ArrayElement.Properties[Index-1].GetFloat);
           end;
          end;
         end;
         Index:=0;
         while (Index+1)<FloatList.Count do begin
          Layer.UVs.fData.Add(TpvFBXVector2.Create(FloatList[Index+0],FloatList[Index+1]));
          inc(Index,2);
         end;
        finally
         FloatList.Free;
        end;
       end else if (SubSubElement.ID='UVIndex') or (SubSubElement.ID='UVsIndex') then begin
        IntList:=TpvFBXInt64List.Create;
        try
         if (SubSubElement.Properties.Count=1) and (SubSubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
          IntList.Capacity:=SubSubElement.Properties[0].GetArrayLength;
          for Index:=1 to SubSubElement.Properties[0].GetArrayLength do begin
           IntList.Add(SubSubElement.Properties[0].GetInteger(Index-1));
          end;
         end else begin
          if SubSubElement.Children.Count=1 then begin
           ArrayElement:=SubSubElement.Children[0];
          end else begin
           ArrayElement:=SubSubElement;
          end;
          if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
           IntList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
           for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
            IntList.Add(ArrayElement.Properties[0].GetInteger(Index-1));
           end;
          end else begin
           IntList.Capacity:=ArrayElement.Properties.Count;
           for Index:=1 to ArrayElement.Properties.Count do begin
            IntList.Add(ArrayElement.Properties[Index-1].GetInteger);
           end;
          end;
         end;
         for Value in IntList do begin
          Layer.UVs.fIndexArray.Add(Value);
         end;
        finally
         IntList.Free;
        end;
       end;
      end;
      Layer.UVs.Finish(self);
     end;
    end;
   end else if (SubElement.ID='LayerElementMaterial') or (SubElement.ID='LayerElementMaterials') then begin
    LayerIndex:=SubElement.Properties[0].GetInteger;
    if LayerIndex>=0 then begin
     Layer:=GetLayer(LayerIndex);
     if assigned(Layer) then begin
      for SubSubElement in SubElement.Children do begin
       if SubSubElement.ID='MappingInformationType' then begin
        if SubSubElement.Properties.Count>0 then begin
         Layer.Materials.fMappingMode:=StringToMappingMode(SubSubElement.Properties[0].GetString);
        end;
       end else if SubSubElement.ID='ReferenceInformationType' then begin
        if SubSubElement.Properties.Count>0 then begin
         Layer.Materials.fReferenceMode:=StringToReferenceMode(SubSubElement.Properties[0].GetString);
        end;
       end else if (SubSubElement.ID='Material') or (SubSubElement.ID='Materials') then begin
        IntList:=TpvFBXInt64List.Create;
        try
         if (SubSubElement.Properties.Count=1) and (SubSubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
          IntList.Capacity:=SubSubElement.Properties[0].GetArrayLength;
          for Index:=1 to SubSubElement.Properties[0].GetArrayLength do begin
           IntList.Add(SubSubElement.Properties[0].GetInteger(Index-1));
          end;
         end else begin
          if SubSubElement.Children.Count=1 then begin
           ArrayElement:=SubSubElement.Children[0];
          end else begin
           ArrayElement:=SubSubElement;
          end;
          if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
           IntList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
           for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
            IntList.Add(ArrayElement.Properties[0].GetInteger(Index-1));
           end;
          end else begin
           IntList.Capacity:=ArrayElement.Properties.Count;
           for Index:=1 to ArrayElement.Properties.Count do begin
            IntList.Add(ArrayElement.Properties[Index-1].GetInteger);
           end;
          end;
         end;
         for Value in IntList do begin
          Layer.Materials.fData.Add(Value);
         end;
        finally
         IntList.Free;
        end;
       end else if (SubSubElement.ID='MaterialIndex') or (SubSubElement.ID='MaterialsIndex') then begin
        IntList:=TpvFBXInt64List.Create;
        try
         if (SubSubElement.Properties.Count=1) and (SubSubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
          IntList.Capacity:=SubSubElement.Properties[0].GetArrayLength;
          for Index:=1 to SubSubElement.Properties[0].GetArrayLength do begin
           IntList.Add(SubSubElement.Properties[0].GetInteger(Index-1));
          end;
         end else begin
          if SubSubElement.Children.Count=1 then begin
           ArrayElement:=SubSubElement.Children[0];
          end else begin
           ArrayElement:=SubSubElement;
          end;
          if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
           IntList.Capacity:=ArrayElement.Properties[0].GetArrayLength;
           for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
            IntList.Add(ArrayElement.Properties[0].GetInteger(Index-1));
           end;
          end else begin
           IntList.Capacity:=ArrayElement.Properties.Count;
           for Index:=1 to ArrayElement.Properties.Count do begin
            IntList.Add(ArrayElement.Properties[Index-1].GetInteger);
           end;
          end;
         end;
         for Value in IntList do begin
          Layer.Materials.fIndexArray.Add(Value);
         end;
        finally
         IntList.Free;
        end;
       end;
      end;
      Layer.Materials.Finish(self);
     end;
    end;
   end;
  end;
 end;

end;

destructor TpvFBXMesh.Destroy;
begin
 FreeAndNil(fVertices);
 FreeAndNil(fPolygons);
 FreeAndNil(fEdges);
 FreeAndNil(fLayers);
 FreeAndNil(fClusterMap);
 FreeAndNil(fTriangleVertices);
 FreeAndNil(fTriangleIndices);
 FreeAndNil(fMaterials);
 inherited Destroy;
end;

procedure TpvFBXMesh.ConnectTo(const pObject:TpvFBXObject);
begin
 if assigned(pObject) and (pObject is TpvFBXMaterial) then begin
  fMaterials.Add(TpvFBXMaterial(pObject));
 end;
 inherited ConnectTo(pObject);
end;

procedure TpvFBXMesh.Finish;
type TTriangleVertexMap=TDictionary<TpvFBXMeshTriangleVertex,TpvInt64>;
var PolygonIndex,Index,SubIndex,WorkIndex,PolygonVertexIndex:TpvInt32;
    VertexIndex,TriangleVertexIndex,ClusterIndex:TpvInt64;
    Skins,Clusters:TpvFBXObjects;
    Skin,Cluster:TpvFBXObject;
    ClusterMapItem:TpvFBXMeshClusterMapItem;
    Polygon:TpvFBXMeshIndices;
    TriangleVertex:TpvFBXMeshTriangleVertex;
    TriangleVertexMap:TTriangleVertexMap;
    Layer:TpvFBXLayer;
    HasBlendShapes:boolean;
 function FillTriangleVertex(const pVertexIndex,pPolygonVertexIndex:TpvInt64):TpvFBXMeshTriangleVertex;
 begin
  FillChar(result,SizeOf(TpvFBXMeshTriangleVertex),#0);
  result.Position:=fVertices[pVertexIndex];
  if assigned(Layer) then begin
   if pPolygonVertexIndex<Layer.fNormals.fByPolygonVertexIndexArray.Count then begin
    result.Normal:=Layer.fNormals.fData[Layer.fNormals.fByPolygonVertexIndexArray[pPolygonVertexIndex]];
   end;
   if pPolygonVertexIndex<Layer.fTangents.fByPolygonVertexIndexArray.Count then begin
    result.Tangent:=Layer.fTangents.fData[Layer.fTangents.fByPolygonVertexIndexArray[pPolygonVertexIndex]];
   end;
   if pPolygonVertexIndex<Layer.fBitangents.fByPolygonVertexIndexArray.Count then begin
    result.Bitangent:=Layer.fBitangents.fData[Layer.fBitangents.fByPolygonVertexIndexArray[pPolygonVertexIndex]];
   end;
   if pPolygonVertexIndex<Layer.fUVs.fByPolygonVertexIndexArray.Count then begin
    result.UV:=Layer.fUVs.fData[Layer.fUVs.fByPolygonVertexIndexArray[pPolygonVertexIndex]];
   end;
   if pPolygonVertexIndex<Layer.fColors.fByPolygonVertexIndexArray.Count then begin
    result.Color:=Layer.fColors.fData[Layer.fColors.fByPolygonVertexIndexArray[pPolygonVertexIndex]];
   end;
   if pPolygonVertexIndex<Layer.fMaterials.fByPolygonVertexIndexArray.Count then begin
    result.Material:=Layer.fMaterials.fData[Layer.fMaterials.fByPolygonVertexIndexArray[pPolygonVertexIndex]];
   end;
  end;
 end;
begin

 fClusterMap.Clear;
 for Index:=0 to fVertices.Count-1 do begin
  fClusterMap.Add(TpvFBXMeshClusterMapItemList.Create);
 end;

 Skins:=FindConnectionsByType('Skin');
 try
  for Skin in Skins do begin
   Clusters:=Skin.FindConnectionsByType('Cluster');
   for Cluster in Clusters do begin
    if (length(TpvFBXCluster(Cluster).fIndexes)>0) and (length(TpvFBXCluster(Cluster).fWeights)>0) then begin
     ClusterMapItem.Cluster:=TpvFBXCluster(Cluster);
     for Index:=0 to length(TpvFBXCluster(Cluster).fIndexes)-1 do begin
      ClusterIndex:=TpvFBXCluster(Cluster).fIndexes[Index];
      ClusterMapItem.Weight:=TpvFBXCluster(Cluster).fWeights[Index];
      fClusterMap[ClusterIndex].Add(ClusterMapItem);
     end;
    end;
   end;
  end;
 finally
  Skins:=nil;
 end;

 if fLayers.Count>0 then begin
  Layer:=fLayers[0];
 end else begin
  Layer:=nil;
 end;

 HasBlendShapes:=false;

 if HasBlendShapes then begin
  PolygonVertexIndex:=0;
  for PolygonIndex:=0 to fPolygons.Count-1 do begin
   Polygon:=fPolygons[PolygonIndex];
   for Index:=0 to Polygon.Count-1 do begin
    TriangleVertexIndex:=fTriangleVertices.Add(FillTriangleVertex(Polygon[WorkIndex],PolygonVertexIndex+Index));
   end;
   inc(PolygonVertexIndex,Polygon.Count);
  end;
 end else begin
  TriangleVertexMap:=TTriangleVertexMap.Create;
  try
   PolygonVertexIndex:=0;
   for PolygonIndex:=0 to fPolygons.Count-1 do begin
    Polygon:=fPolygons[PolygonIndex];
    for Index:=0 to Polygon.Count-3 do begin
     for SubIndex:=0 to 2 do begin
      case SubIndex of
       1:begin
        WorkIndex:=Index+1;
       end;
       2:begin
        WorkIndex:=Index+2;
       end;
       else begin
        WorkIndex:=0;
       end;
      end;
      TriangleVertex:=FillTriangleVertex(Polygon[WorkIndex],PolygonVertexIndex+WorkIndex);
      if not TriangleVertexMap.TryGetValue(TriangleVertex,TriangleVertexIndex) then begin
       TriangleVertexIndex:=fTriangleVertices.Add(TriangleVertex);
       TriangleVertexMap.AddOrSetValue(TriangleVertex,TriangleVertexIndex);
      end;
      fTriangleIndices.Add(TriangleVertexIndex);
     end;
    end;
    inc(PolygonVertexIndex,Polygon.Count);
   end;
  finally
   TriangleVertexMap.Free;
  end;
 end;

end;

constructor TpvFBXSkeleton.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
begin
 inherited Create(pLoader,pElement,pID,pName,pType_);
 if pType_='Root' then begin
  fSkeletonType:=ROOT;
 end else if pType_='Limb' then begin
  fSkeletonType:=LIMB;
 end else if pType_='LimbNode' then begin
  fSkeletonType:=LIMB_NODE;
 end else if pType_='Effector' then begin
  fSkeletonType:=EFFECTOR;
 end else begin
  fSkeletonType:=LIMB;
 end;
end;

destructor TpvFBXSkeleton.Destroy;
begin
 inherited Destroy;
end;

constructor TpvFBXMaterial.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
var SubElement,SubSubElement:TpvFBXElement;
    PropertyName:TpvFBXString;
    ValuePropertyIndex:TpvInt32;
begin
 inherited Create(pLoader,pElement,pID,pName,pType_);

 fShadingModel:='lambert';
 fMultiLayer:=false;
 fAmbientColor:=TpvFBXColorProperty.Create(0.0,0.0,0.0,1.0);
 fDiffuseColor:=TpvFBXColorProperty.Create(1.0,1.0,1.0,1.0);
 fTransparencyFactor:=1.0;
 fEmissive:=TpvFBXColorProperty.Create(0.0,0.0,0.0,1.0);
 fAmbient:=TpvFBXColorProperty.Create(0.0,0.0,0.0,1.0);
 fDiffuse:=TpvFBXColorProperty.Create(1.0,1.0,1.0,1.0);
 fOpacity:=1.0;
 fSpecular:=TpvFBXColorProperty.Create(1.0,1.0,1.0,1.0);
 fSpecularFactor:=0.0;
 fShininess:=1.0;
 fShininessExponent:=1.0;
 fReflection:=TpvFBXColorProperty.Create(1.0,1.0,1.0,1.0);
 fReflectionFactor:=0.0;

 for SubElement in pElement.Children do begin
  if SubElement.ID='ShadingModel' then begin
   fShadingModel:=SubElement.Properties[0].GetString;
  end else if (SubElement.ID='Properties60') or
              (SubElement.ID='Properties70') then begin
   if SubElement.ID='Properties60' then begin
    ValuePropertyIndex:=3;
   end else begin
    ValuePropertyIndex:=4;
   end;
   for SubSubElement in SubElement.Children do begin
    if (SubSubElement.ID='P') or (SubSubElement.ID='Property') then begin
     PropertyName:=SubSubElement.Properties[0].GetString;
     if PropertyName='ShadingModel' then begin
      fShadingModel:=SubSubElement.Properties[ValuePropertyIndex].GetString;
     end else if PropertyName='MultiLayer' then begin
      fMultiLayer:=SubSubElement.Properties[ValuePropertyIndex].GetBoolean;
     end else if PropertyName='AmbientColor' then begin
      fAmbientColor.Red:=SubSubElement.Properties[ValuePropertyIndex+0].GetFloat;
      fAmbientColor.Green:=SubSubElement.Properties[ValuePropertyIndex+1].GetFloat;
      fAmbientColor.Blue:=SubSubElement.Properties[ValuePropertyIndex+2].GetFloat;
     end else if PropertyName='DiffuseColor' then begin
      fDiffuseColor.Red:=SubSubElement.Properties[ValuePropertyIndex+0].GetFloat;
      fDiffuseColor.Green:=SubSubElement.Properties[ValuePropertyIndex+1].GetFloat;
      fDiffuseColor.Blue:=SubSubElement.Properties[ValuePropertyIndex+2].GetFloat;
     end else if PropertyName='TransparencyFactor' then begin
      fTransparencyFactor:=SubSubElement.Properties[ValuePropertyIndex].GetFloat;
     end else if PropertyName='Emissive' then begin
      fEmissive.Red:=SubSubElement.Properties[ValuePropertyIndex+0].GetFloat;
      fEmissive.Green:=SubSubElement.Properties[ValuePropertyIndex+1].GetFloat;
      fEmissive.Blue:=SubSubElement.Properties[ValuePropertyIndex+2].GetFloat;
     end else if PropertyName='Ambient' then begin
      fAmbient.Red:=SubSubElement.Properties[ValuePropertyIndex+0].GetFloat;
      fAmbient.Green:=SubSubElement.Properties[ValuePropertyIndex+1].GetFloat;
      fAmbient.Blue:=SubSubElement.Properties[ValuePropertyIndex+2].GetFloat;
     end else if PropertyName='Diffuse' then begin
      fDiffuse.Red:=SubSubElement.Properties[ValuePropertyIndex+0].GetFloat;
      fDiffuse.Green:=SubSubElement.Properties[ValuePropertyIndex+1].GetFloat;
      fDiffuse.Blue:=SubSubElement.Properties[ValuePropertyIndex+2].GetFloat;
     end else if PropertyName='Opacity' then begin
      fOpacity:=SubSubElement.Properties[ValuePropertyIndex].GetFloat;
     end else if PropertyName='Specular' then begin
      fSpecular.Red:=SubSubElement.Properties[ValuePropertyIndex+0].GetFloat;
      fSpecular.Green:=SubSubElement.Properties[ValuePropertyIndex+1].GetFloat;
      fSpecular.Blue:=SubSubElement.Properties[ValuePropertyIndex+2].GetFloat;
     end else if PropertyName='Shininess' then begin
      fShininess:=SubSubElement.Properties[ValuePropertyIndex].GetFloat;
     end else if PropertyName='ShininessExponent' then begin
      fShininessExponent:=SubSubElement.Properties[ValuePropertyIndex].GetFloat;
     end else if PropertyName='Reflection' then begin
      fReflection.Red:=SubSubElement.Properties[ValuePropertyIndex+0].GetFloat;
      fReflection.Green:=SubSubElement.Properties[ValuePropertyIndex+1].GetFloat;
      fReflection.Blue:=SubSubElement.Properties[ValuePropertyIndex+2].GetFloat;
     end else if PropertyName='ReflectionFactor' then begin
      fReflectionFactor:=SubSubElement.Properties[ValuePropertyIndex].GetFloat;
     end;
    end;
   end;
  end;
 end;

end;

destructor TpvFBXMaterial.Destroy;
begin
 FreeAndNil(fAmbientColor);
 FreeAndNil(fDiffuseColor);
 FreeAndNil(fEmissive);
 FreeAndNil(fAmbient);
 FreeAndNil(fDiffuse);
 FreeAndNil(fSpecular);
 FreeAndNil(fReflection);
 inherited Destroy;
end;

procedure TpvFBXMaterial.ConnectTo(const pObject:TpvFBXObject);
begin
 if assigned(pObject) and (pObject is TpvFBXMesh) then begin
  TpvFBXMesh(pObject).fMaterials.Add(self);
 end;
 inherited ConnectTo(pObject);
end;

constructor TpvFBXAnimationStack.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
var SubElement,SubSubElement:TpvFBXElement;
    PropertyName:TpvFBXString;
    ValuePropertyIndex:TpvInt32;
begin
 inherited Create(pLoader,pElement,pID,pName,pType_);

 fDescription:='';
 fLocalStart:=0;
 fLocalStop:=0;
 fReferenceStart:=0;
 fReferenceStop:=0;

 if assigned(pElement) then begin
  for SubElement in pElement.Children do begin
   if (SubElement.ID='Properties60') or
      (SubElement.ID='Properties70') then begin
    if SubElement.ID='Properties60' then begin
     ValuePropertyIndex:=3;
    end else begin
     ValuePropertyIndex:=4;
    end;
    for SubSubElement in SubElement.Children do begin
     if (SubSubElement.ID='P') or (SubSubElement.ID='Property') then begin
      PropertyName:=SubSubElement.Properties[0].GetString;
      if PropertyName='Description' then begin
       fDescription:=SubSubElement.Properties[ValuePropertyIndex].GetString;
      end else if PropertyName='LocalStart' then begin
       fLocalStart:=SubSubElement.Properties[ValuePropertyIndex].GetInteger;
      end else if PropertyName='LocalStop' then begin
       fLocalStop:=SubSubElement.Properties[ValuePropertyIndex].GetInteger;
      end else if PropertyName='ReferenceStart' then begin
       fReferenceStart:=SubSubElement.Properties[ValuePropertyIndex].GetInteger;
      end else if PropertyName='ReferenceStop' then begin
       fReferenceStop:=SubSubElement.Properties[ValuePropertyIndex].GetInteger;
      end;
     end;
    end;
   end;
  end;
 end;

end;

destructor TpvFBXAnimationStack.Destroy;
begin
 inherited Destroy;
end;

constructor TpvFBXAnimationLayer.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
var SubElement:TpvFBXElement;
begin
 inherited Create(pLoader,pElement,pID,pName,pType_);

 fWeight:=100.0;
 fMute:=false;
 fSolo:=false;
 fLock:=false;
 fColor:=TpvFBXColorProperty.Create(0.8,0.8,0.8,1.0);
 fBlendMode:=BLEND_ADDITIVE;
 fRotationAccumulationMode:=ROTATION_BY_LAYER;
 fScaleAccumulationMode:=SCALE_MULTIPLY;

 if assigned(pElement) then begin
  for SubElement in pElement.Children do begin
   if SubElement.ID='Weight' then begin
    fWeight:=SubElement.Properties[0].GetFloat;
   end else if SubElement.ID='Mute' then begin
    fMute:=SubElement.Properties[0].GetBoolean;
   end else if SubElement.ID='Solo' then begin
    fSolo:=SubElement.Properties[0].GetBoolean;
   end else if SubElement.ID='Lock' then begin
    fLock:=SubElement.Properties[0].GetBoolean;
   end else if SubElement.ID='Color' then begin
    fColor.Red:=SubElement.Properties[0].GetFloat;
    fColor.Green:=SubElement.Properties[1].GetFloat;
    fColor.Blue:=SubElement.Properties[2].GetFloat;
   end else if SubElement.ID='BlendMode' then begin
    fBlendMode:=SubElement.Properties[0].GetInteger;
   end else if SubElement.ID='RotationAccumulationMode' then begin
    fRotationAccumulationMode:=SubElement.Properties[0].GetInteger;
   end else if SubElement.ID='ScaleAccumulationMode' then begin
    fScaleAccumulationMode:=SubElement.Properties[0].GetInteger;
   end;
  end;
 end;

end;

destructor TpvFBXAnimationLayer.Destroy;
begin
 FreeAndNil(fColor);
 inherited Destroy;
end;

constructor TpvFBXSkinDeformer.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
var SubElement:TpvFBXElement;
begin
 inherited Create(pLoader,pElement,pID,pName,pType_);

 fLink_DeformAcuracy:=50;
 fSkinningType:=RIGID;

 for SubElement in pElement.Children do begin
  if SubElement.ID='Link_DeformAcuracy' then begin
   fLink_DeformAcuracy:=SubElement.Properties[0].GetInteger;
  end else if SubElement.ID='SkinningType' then begin
   if SubElement.Properties[0].GetString='Rigid' then begin
    fSkinningType:=RIGID;
   end else if SubElement.Properties[0].GetString='Linear' then begin
    fSkinningType:=LINEAR;
   end else if SubElement.Properties[0].GetString='DualQuaternion' then begin
    fSkinningType:=DUAL_QUATERNION;
   end else if SubElement.Properties[0].GetString='Blend' then begin
    fSkinningType:=BLEND;
   end;
  end;
 end;

end;

destructor TpvFBXSkinDeformer.Destroy;
begin
 inherited Destroy;
end;

constructor TpvFBXCluster.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
var SubElement,ArrayElement:TpvFBXElement;
    Index:TpvUInt32;
begin
 inherited Create(pLoader,pElement,pID,pName,pType_);

 fIndexes:=nil;
 fWeights:=nil;
 fTransform:=FBXMatrix4x4Identity;;
 fTransformLink:=FBXMatrix4x4Identity;
 fLinkMode:=NORMALIZE;

 for SubElement in pElement.Children do begin
  if SubElement.ID='Indexes' then begin
   if (SubElement.Properties.Count=1) and (SubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
    SetLength(fIndexes,SubElement.Properties[0].GetArrayLength);
    for Index:=1 to SubElement.Properties[0].GetArrayLength do begin
     fIndexes[Index-1]:=SubElement.Properties[0].GetInteger(Index-1);
    end;
   end else begin
    if SubElement.Children.Count=1 then begin
     ArrayElement:=SubElement.Children[0];
    end else begin
     ArrayElement:=SubElement;
    end;
    if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
     SetLength(fIndexes,ArrayElement.Properties[0].GetArrayLength);
     for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
      fIndexes[Index-1]:=ArrayElement.Properties[0].GetInteger(Index-1);
     end;
    end else begin
     SetLength(fIndexes,ArrayElement.Properties.Count);
     for Index:=1 to ArrayElement.Properties.Count do begin
      fIndexes[Index-1]:=ArrayElement.Properties[Index-1].GetInteger;
     end;
    end;
   end;
  end else if SubElement.ID='Weights' then begin
   if (SubElement.Properties.Count=1) and (SubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
    SetLength(fWeights,SubElement.Properties[0].GetArrayLength);
    for Index:=1 to SubElement.Properties[0].GetArrayLength do begin
     fWeights[Index-1]:=SubElement.Properties[0].GetFloat(Index-1);
    end;
   end else begin
    if SubElement.Children.Count=1 then begin
     ArrayElement:=SubElement.Children[0];
    end else begin
     ArrayElement:=SubElement;
    end;
    if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
     SetLength(fWeights,ArrayElement.Properties[0].GetArrayLength);
     for Index:=1 to ArrayElement.Properties[0].GetArrayLength do begin
      fWeights[Index-1]:=ArrayElement.Properties[0].GetFloat(Index-1);
     end;
    end else begin
     SetLength(fWeights,ArrayElement.Properties.Count);
     for Index:=1 to ArrayElement.Properties.Count do begin
      fWeights[Index-1]:=ArrayElement.Properties[Index-1].GetFloat;
     end;
    end;
   end;
  end else if SubElement.ID='Transform' then begin
   if (SubElement.Properties.Count=1) and (SubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
    for Index:=1 to Min(16,SubElement.Properties[0].GetArrayLength) do begin
     fTransform.LinearRawComponents[Index-1]:=SubElement.Properties[0].GetFloat(Index-1);
    end;
   end else begin
    if SubElement.Children.Count=1 then begin
     ArrayElement:=SubElement.Children[0];
    end else begin
     ArrayElement:=SubElement;
    end;
    if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
     for Index:=1 to Min(16,ArrayElement.Properties[0].GetArrayLength) do begin
      fTransform.LinearRawComponents[Index-1]:=ArrayElement.Properties[0].GetFloat(Index-1);
     end;
    end else begin
     for Index:=1 to Min(16,ArrayElement.Properties.Count) do begin
      fTransform.LinearRawComponents[Index-1]:=ArrayElement.Properties[Index-1].GetFloat;
     end;
    end;
   end;
  end else if SubElement.ID='TransformLink' then begin
   if (SubElement.Properties.Count=1) and (SubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
    for Index:=1 to Min(16,SubElement.Properties[0].GetArrayLength) do begin
     fTransformLink.LinearRawComponents[Index-1]:=SubElement.Properties[0].GetFloat(Index-1);
    end;
   end else begin
    if SubElement.Children.Count=1 then begin
     ArrayElement:=SubElement.Children[0];
    end else begin
     ArrayElement:=SubElement;
    end;
    if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
     for Index:=1 to Min(16,ArrayElement.Properties[0].GetArrayLength) do begin
      fTransformLink.LinearRawComponents[Index-1]:=ArrayElement.Properties[0].GetFloat(Index-1);
     end;
    end else begin
     for Index:=1 to Min(16,ArrayElement.Properties.Count) do begin
      fTransformLink.LinearRawComponents[Index-1]:=ArrayElement.Properties[Index-1].GetFloat;
     end;
    end;
   end;
  end;
 end;

end;

destructor TpvFBXCluster.Destroy;
begin
 fIndexes:=nil;
 fWeights:=nil;
 inherited Destroy;
end;

function TpvFBXCluster.GetLink:TpvFBXNode;
begin
 if fConnectedTo.Count>0 then begin
  result:=TpvFBXNode(fConnectedTo[0]);
 end else begin
  result:=nil;
 end;
end;

constructor TpvFBXTexture.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
var SubElement:TpvFBXElement;
begin
 inherited Create(pLoader,pElement,pID,pName,pType_);

 fFileName:='';

 for SubElement in pElement.Children do begin
  if SubElement.ID='FileName' then begin
   fFileName:=SubElement.Properties[0].GetString;
  end;
 end;

end;

destructor TpvFBXTexture.Destroy;
begin
 fFileName:='';
 inherited Destroy;
end;

constructor TpvFBXAnimationKey.Create;
begin
 inherited Create;
 fTime:=0;
 fValue:=0.0;
 fTangentMode:=TANGENT_AUTO;
 fInterpolation:=INTERPOLATION_LINEAR;
 fWeight:=WEIGHTED_NONE;
 fConstant:=CONSTANT_STANDARD;
 fVelocity:=VELOCITY_NONE;
 fVisibility:=VISIBILITY_NONE;
 fDataFloats:=DefaultDataFloats;
end;

destructor TpvFBXAnimationKey.Destroy;
begin
 inherited Destroy;
end;

constructor TpvFBXAnimationCurve.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
var SubElement:TpvFBXElement;
    Index,OtherIndex,YetOtherIndex,AttrCount,Flags:TpvUInt32;
    Data0,Data1,Data2,Data3:TpvInt64;
    KeyTime,KeyValue,KeyAttrFlags,KeyAttrDataFloat,KeyAttrRefCount:TpvFBXElementPropertyArray;
    Key:TpvFBXAnimationKey;
begin

 inherited Create(pLoader,pElement,pID,pName,pType_);

 fDefaultValue:=0;

 fAnimationKeys:=TpvFBXAnimationKeyList.Create(true);

 KeyTime:=nil;
 KeyValue:=nil;
 KeyAttrFlags:=nil;
 KeyAttrDataFloat:=nil;
 KeyAttrRefCount:=nil;

 if assigned(pElement) then begin

  for SubElement in pElement.Children do begin
   if SubElement.ID='Default' then begin
    if SubElement.Properties.Count>0 then begin
     fDefaultValue:=SubElement.Properties[0].GetFloat;
    end;
   end else if SubElement.ID='KeyVer' then begin
    if SubElement.Properties.Count>0 then begin
     Data0:=SubElement.Properties[0].GetInteger;
     if (Data0<>4008) and (Data0<>4009) then begin
      raise EFBX.Create('Not implemented TpvFBXAnimationCurve KeyVer version '+IntToStr(Data0));
     end;
    end else begin
     raise EFBX.Create('Not implemented feature');
    end;
   end else if SubElement.ID='KeyTime' then begin
    if (SubElement.Properties.Count>0) and (SubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
     KeyTime:=TpvFBXElementPropertyArray(SubElement.Properties[0]);
    end;
   end else if SubElement.ID='KeyValueFloat' then begin
    if (SubElement.Properties.Count>0) and (SubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
     KeyValue:=TpvFBXElementPropertyArray(SubElement.Properties[0]);
    end;
   end else if SubElement.ID='KeyAttrFlags' then begin
    if (SubElement.Properties.Count>0) and (SubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
     KeyAttrFlags:=TpvFBXElementPropertyArray(SubElement.Properties[0]);
    end;
   end else if SubElement.ID='KeyAttrDataFloat' then begin
    if (SubElement.Properties.Count>0) and (SubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
     KeyAttrDataFloat:=TpvFBXElementPropertyArray(SubElement.Properties[0]);
    end;
   end else if SubElement.ID='KeyAttrRefCount' then begin
    if (SubElement.Properties.Count>0) and (SubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
     KeyAttrRefCount:=TpvFBXElementPropertyArray(SubElement.Properties[0]);
    end;
   end;
  end;

  if (assigned(KeyTime) and assigned(KeyValue)) and
     (Min(KeyTime.GetArrayLength,KeyValue.GetArrayLength)>0) then begin

   for Index:=1 to Min(KeyTime.GetArrayLength,KeyValue.GetArrayLength) do begin
    Key:=TpvFBXAnimationKey.Create;
    fAnimationKeys.Add(Key);
    Key.fTime:=KeyTime.GetInteger(Index-1);
    Key.fValue:=KeyTime.GetFloat(Index-1);
   end;

   if assigned(KeyAttrRefCount) and
      assigned(KeyAttrDataFloat) and
      assigned(KeyAttrFlags) then begin

    OtherIndex:=0;
    YetOtherIndex:=0;
    for Index:=1 to KeyAttrRefCount.GetArrayLength do begin
     AttrCount:=KeyAttrRefCount.GetInteger(Index-1);
     Data0:=KeyAttrDataFloat.GetInteger((YetOtherIndex shl 2) or 0);
     Data1:=KeyAttrDataFloat.GetInteger((YetOtherIndex shl 2) or 1);
     Data2:=KeyAttrDataFloat.GetInteger((YetOtherIndex shl 2) or 2);
     Data3:=KeyAttrDataFloat.GetInteger((YetOtherIndex shl 2) or 3);
     Flags:=KeyAttrFlags.GetInteger(YetOtherIndex);
     while AttrCount>0 do begin
      dec(AttrCount);
      if TpvFBXSizeInt(OtherIndex)<TpvFBXSizeInt(fAnimationKeys.Count) then begin
       Key:=fAnimationKeys[OtherIndex];
       Key.fTangentMode:=Flags and TpvFBXAnimationKey.TANGENT_MASK;
       Key.fInterpolation:=Flags and TpvFBXAnimationKey.INTERPOLATION_MASK;
       Key.fWeight:=Flags and TpvFBXAnimationKey.WEIGHT_MASK;
       Key.fConstant:=Flags and TpvFBXAnimationKey.CONSTANT_MASK;
       Key.fVelocity:=Flags and TpvFBXAnimationKey.VELOCITY_MASK;
       Key.fVisibility:=Flags and TpvFBXAnimationKey.VISIBILITY_MASK;
       Key.fDataFloats[TpvFBXAnimationKey.RightWeightIndex]:=(Data2 and $0000ffff)/9999.0;
       Key.fDataFloats[TpvFBXAnimationKey.NextLeftWeightIndex]:=((Data2 shr 16) and $0000ffff)/9999.0;
      end else begin
       break;
      end;
      inc(OtherIndex);
     end;
     if TpvFBXSizeInt(OtherIndex)<TpvFBXSizeInt(fAnimationKeys.Count) then begin
      inc(YetOtherIndex);
     end else begin
      break;
     end;
    end;

   end;

  end;

 end;

end;

constructor TpvFBXAnimationCurve.CreateOldFBX6000(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
var SubElement,ArrayElement:TpvFBXElement;
    Index:TpvUInt32;
    Data0:TpvInt64;
    Key:TpvFBXAnimationKey;
    InterpolationType:TpvFBXString;
begin

 inherited Create(pLoader,pElement,pID,pName,pType_);

 fDefaultValue:=0;

 fAnimationKeys:=TpvFBXAnimationKeyList.Create(true);

 if assigned(pElement) then begin

  ArrayElement:=nil;

  for SubElement in pElement.Children do begin
   if SubElement.ID='Default' then begin
    if SubElement.Properties.Count>0 then begin
     fDefaultValue:=SubElement.Properties[0].GetFloat;
    end;
   end else if SubElement.ID='KeyVer' then begin
    if SubElement.Properties.Count>0 then begin
     Data0:=SubElement.Properties[0].GetInteger;
     if (Data0<>4005) and (Data0<>4006) and (Data0<>4007) then begin
      raise EFBX.Create('Not implemented TpvFBXAnimationCurve KeyVer version '+IntToStr(Data0));
     end;
    end else begin
     raise EFBX.Create('Not implemented feature');
    end;
   end else if SubElement.ID='Key' then begin
    ArrayElement:=SubElement;
   end;
  end;

  if assigned(ArrayElement) then begin
   Index:=0;
   while Index<TpvInt64(ArrayElement.fProperties.Count) do begin
    Key:=TpvFBXAnimationKey.Create;
    fAnimationKeys.Add(Key);

    Key.fTime:=ArrayElement.Properties[Index].GetInteger;
    inc(Index);

    if Index<TpvInt64(ArrayElement.fProperties.Count) then begin
     Key.fValue:=ArrayElement.Properties[Index].GetFloat;
     inc(Index);
    end else begin
     break;
    end;

    if Index<TpvInt64(ArrayElement.fProperties.Count) then begin
     InterpolationType:=ArrayElement.Properties[Index].GetString;
     inc(Index);

     if InterpolationType='C' then begin
      Key.fInterpolation:=TpvFBXAnimationKey.INTERPOLATION_CONSTANT;
      if ArrayElement.Properties[Index].GetString='s' then begin
       Key.fConstant:=TpvFBXAnimationKey.CONSTANT_STANDARD;
      end else if ArrayElement.Properties[Index].GetString='n' then begin
       Key.fConstant:=TpvFBXAnimationKey.CONSTANT_NEXT;
      end;
      inc(Index);
     end else if InterpolationType='L' then begin
      Key.fInterpolation:=TpvFBXAnimationKey.INTERPOLATION_LINEAR;
     end else if InterpolationType='true' then begin
      Key.fInterpolation:=TpvFBXAnimationKey.INTERPOLATION_CUBIC;
      Key.fDataFloats[TpvFBXAnimationKey.RightWeightIndex]:=ArrayElement.Properties[Index+0].GetFloat;
      Key.fDataFloats[TpvFBXAnimationKey.NextLeftWeightIndex]:=ArrayElement.Properties[Index+1].GetFloat;
      inc(Index,2);
     end else begin
      Key.fInterpolation:=TpvFBXAnimationKey.INTERPOLATION_CUBIC;
      if ArrayElement.Properties[Index].GetString='s' then begin
       Key.fConstant:=TpvFBXAnimationKey.CONSTANT_STANDARD;
      end else if ArrayElement.Properties[Index].GetString='n' then begin
       Key.fConstant:=TpvFBXAnimationKey.CONSTANT_NEXT;
      end;
      Key.fDataFloats[TpvFBXAnimationKey.RightWeightIndex]:=ArrayElement.Properties[Index+1].GetFloat;
      Key.fDataFloats[TpvFBXAnimationKey.NextLeftWeightIndex]:=ArrayElement.Properties[Index+2].GetFloat;
      inc(Index,4);
     end;

    end else begin
     break;
    end;

   end;
  end;

 end;

end;

destructor TpvFBXAnimationCurve.Destroy;
begin
 FreeAndNil(fAnimationKeys);
 inherited Destroy;
end;

constructor TpvFBXPose.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
var SubElement,SubSubElement,ArrayElement:TpvFBXElement;
    Index:TpvInt32;
    Matrix:TpvFBXMatrix4x4;
    NodeName:TpvFBXString;
    Node:TpvFBXObject;
begin

 inherited Create(pLoader,pElement,pID,pName,pType_);

 fPoseType:='BindPose';
 fNodeMatrixMap:=TpvFBXPoseNodeMatrixMap.Create;

 for SubElement in pElement.Children do begin
  if SubElement.ID='Type' then begin
   fPoseType:=SubElement.Properties[0].GetString;
  end else if SubElement.ID='PoseNode' then begin
   Matrix:=FBXMatrix4x4Identity;
   NodeName:=TpvFBXString(#0#1#2);
   for SubSubElement in SubElement.Children do begin
    if SubSubElement.ID='Node' then begin
     NodeName:=SubSubElement.Properties[0].GetString;
    end else if SubSubElement.ID='Matrix' then begin
     if (SubSubElement.Properties.Count=1) and (SubSubElement.Properties[0] is TpvFBXElementPropertyArray) then begin
      for Index:=1 to Min(16,SubSubElement.Properties[0].GetArrayLength) do begin
       Matrix.LinearRawComponents[Index-1]:=SubSubElement.Properties[0].GetFloat(Index-1);
      end;
     end else begin
      if SubSubElement.Children.Count=1 then begin
       ArrayElement:=SubSubElement.Children[0];
      end else begin
       ArrayElement:=SubSubElement;
      end;
      if (ArrayElement.Properties.Count=1) and (ArrayElement.Properties[0] is TpvFBXElementPropertyArray) then begin
       for Index:=1 to Min(16,ArrayElement.Properties[0].GetArrayLength) do begin
        Matrix.LinearRawComponents[Index-1]:=ArrayElement.Properties[0].GetFloat(Index-1);
       end;
      end else begin
       for Index:=1 to Min(16,ArrayElement.Properties.Count) do begin
        Matrix.LinearRawComponents[Index-1]:=ArrayElement.Properties[Index-1].GetFloat;
       end;
      end;
     end;
    end;
   end;
   if length(NodeName)>0 then begin
    if fLoader.fScene.AllObjects.TryGetValue(NodeName,Node) then begin
     if assigned(Node) then begin
      if Node is TpvFBXNode then begin
       fNodeMatrixMap.AddOrSetValue(TpvFBXNode(Node),Matrix);
      end else begin
       raise EFBX.Create('Wrong object type of "'+String(NodeName)+'", it must be TpvFBXNode and not '+Node.ClassName);
      end;
     end;
    end;
   end;
  end;
 end;

end;

destructor TpvFBXPose.Destroy;
begin
 FreeAndNil(fNodeMatrixMap);
 inherited Destroy;
end;

function TpvFBXPose.GetMatrix(const pNode:TpvFBXNode):TpvFBXMatrix4x4;
begin
 result:=FBXMatrix4x4Identity;
 if not fNodeMatrixMap.TryGetValue(pNode,result) then begin
  result:=FBXMatrix4x4Identity;
 end;
end;

constructor TpvFBXVideo.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
var SubElement:TpvFBXElement;
begin

 inherited Create(pLoader,pElement,pID,pName,pType_);

 fFileName:='';
 fUseMipMap:=false;

 for SubElement in pElement.Children do begin
  if (SubElement.ID='Filename') or (SubElement.ID='FileName') then begin
   fFileName:=SubElement.Properties[0].GetString;
  end else if SubElement.ID='UseMipMap' then begin
   fUseMipMap:=SubElement.Properties[0].GetBoolean;
  end;
 end;

end;

destructor TpvFBXVideo.Destroy;
begin
 fFileName:='';
 inherited Destroy;
end;

constructor TpvFBXTake.Create(const pLoader:TpvFBXLoader;const pElement:TpvFBXElement;const pID:TpvInt64;const pName,pType_:TpvFBXString);
var SubElement:TpvFBXElement;
begin

 inherited Create(pLoader,pElement,pID,pName,pType_);

 fFileName:='';
 fLocalTimeSpan.StartTime:=0;
 fLocalTimeSpan.EndTime:=0;
 fReferenceTimeSpan.StartTime:=0;
 fReferenceTimeSpan.EndTime:=0;

 for SubElement in pElement.Children do begin
  if (SubElement.ID='Filename') or (SubElement.ID='FileName') then begin
   fFileName:=SubElement.Properties[0].GetString;
  end else if SubElement.ID='LocalTime' then begin
   fLocalTimeSpan.StartTime:=SubElement.Properties[0].GetInteger;
   fLocalTimeSpan.EndTime:=SubElement.Properties[1].GetInteger;
  end else if SubElement.ID='ReferenceTime' then begin
   fReferenceTimeSpan.StartTime:=SubElement.Properties[0].GetInteger;
   fReferenceTimeSpan.EndTime:=SubElement.Properties[1].GetInteger;
  end;
 end;

end;

destructor TpvFBXTake.Destroy;
begin
 fFileName:='';
 inherited Destroy;
end;

constructor TpvFBXLoader.Create;
begin
 inherited Create;
 fAllocatedList:=TpvFBXAllocatedList.Create(true);
 fScene:=nil;
 fGlobalSettings:=nil;
 fTimeUtils:=TpvFBXTimeUtils.Create(fGlobalSettings);
 fRootElement:=nil;
end;

destructor TpvFBXLoader.Destroy;
begin
 FreeAndNil(fTimeUtils);
 FreeAndNil(fGlobalSettings);
 FreeAndNil(fScene);
 FreeAndNil(fRootElement);
 while fAllocatedList.Count>0 do begin
  fAllocatedList[fAllocatedList.Count-1].Free;
 end;
 FreeAndNil(fAllocatedList);
 inherited Destroy;
end;

procedure TpvFBXLoader.LoadFromStream(const pStream:TStream);
var Parser:TpvFBXParser;
 procedure ProcessFBXHeaderExtension(const pFBXHeaderExtensionElement:TpvFBXElement);
 var Element,SubElement:TpvFBXElement;
 begin
  for Element in pFBXHeaderExtensionElement.Children do begin
   if Element.ID='OtherFlags' then begin
    for SubElement in Element.Children do begin
     if SubElement.Properties.Count=1 then begin
      fScene.fHeader.AddProperty(SubElement.ID,SubElement.Properties[0].GetVariantValue);
     end;
    end;
   end else begin
    if Element.Properties.Count=1 then begin
     if Element.ID='FBXVersion' then begin
      fFileVersion:=Element.Properties[0].GetInteger;
     end;
     fScene.fHeader.AddProperty(Element.ID,Element.Properties[0].GetVariantValue);
    end;
   end;
  end;
 end;
 procedure ProcessGlobalSettings(const pGlobalSettingsElement:TpvFBXElement);
 var Properties,PropertyElement:TpvFBXElement;
     ValuePropertyIndex:TpvInt32;
     PropertyName:TpvFBXString;
 begin
  if not assigned(fGlobalSettings) then begin
   fGlobalSettings:=TpvFBXGlobalSettings.Create(self,pGlobalSettingsElement,0,TpvFBXString(#0'GlobalSettings'#255),'');
  end;
  if pGlobalSettingsElement.ChildrenByName.TryGetValue('Properties60',Properties) then begin
   ValuePropertyIndex:=3;
  end else if pGlobalSettingsElement.ChildrenByName.TryGetValue('Properties70',Properties) then begin
   ValuePropertyIndex:=4;
  end else begin
   Properties:=nil;
   ValuePropertyIndex:=0;
  end;
  if assigned(Properties) then begin
   for PropertyElement in Properties.Children do begin
    if (PropertyElement.ID='P') and (PropertyElement.fProperties.Count>0) then begin
     PropertyName:=PropertyElement.fProperties[0].GetString;
     if (PropertyName='UpAxis') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fUpAxis:=PropertyElement.fProperties[ValuePropertyIndex].GetInteger;
      continue;
     end;
     if (PropertyName='UpAxisSign') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fUpAxisSign:=PropertyElement.fProperties[ValuePropertyIndex].GetInteger;
      continue;
     end;
     if (PropertyName='FrontAxis') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fFrontAxis:=PropertyElement.fProperties[ValuePropertyIndex].GetInteger;
      continue;
     end;
     if (PropertyName='FrontAxisSign') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fFrontAxisSign:=PropertyElement.fProperties[ValuePropertyIndex].GetInteger;
      continue;
     end;
     if (PropertyName='CoordAxis') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fCoordAxis:=PropertyElement.fProperties[ValuePropertyIndex].GetInteger;
      continue;
     end;
     if (PropertyName='CoordAxisSign') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fCoordAxisSign:=PropertyElement.fProperties[ValuePropertyIndex].GetInteger;
      continue;
     end;
     if (PropertyName='OriginalUpAxis') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fOriginalUpAxis:=PropertyElement.fProperties[ValuePropertyIndex].GetInteger;
      continue;
     end;
     if (PropertyName='OriginalUpAxisSign') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fOriginalUpAxisSign:=PropertyElement.fProperties[ValuePropertyIndex].GetInteger;
      continue;
     end;
     if (PropertyName='UnitScaleFactor') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fUnitScaleFactor:=PropertyElement.fProperties[ValuePropertyIndex].GetFloat;
      continue;
     end;
     if (PropertyName='OriginalUnitScaleFactor') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fOriginalUnitScaleFactor:=PropertyElement.fProperties[ValuePropertyIndex].GetFloat;
      continue;
     end;
     if (PropertyName='AmbientColor') and
        ((ValuePropertyIndex+2)<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fAmbientColor.Red:=PropertyElement.fProperties.Items[ValuePropertyIndex+0].GetFloat;
      fGlobalSettings.fAmbientColor.Green:=PropertyElement.fProperties.Items[ValuePropertyIndex+1].GetFloat;
      fGlobalSettings.fAmbientColor.Blue:=PropertyElement.fProperties.Items[ValuePropertyIndex+2].GetFloat;
      continue;
     end;
     if (PropertyName='DefaultCamera') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fDefaultCamera:=PropertyElement.fProperties[ValuePropertyIndex].GetString;
      continue;
     end;
     if (PropertyName='TimeMode') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fTimeMode:=TpvFBXTimeMode(PropertyElement.fProperties[ValuePropertyIndex].GetInteger);
      continue;
     end;
     if (PropertyName='TimeProtocol') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fTimeProtocol:=PropertyElement.fProperties[ValuePropertyIndex].GetInteger;
      continue;
     end;
     if (PropertyName='SnapOnFrameMode') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fSnapOnFrameMode:=PropertyElement.fProperties[ValuePropertyIndex].GetInteger;
      continue;
     end;
     if (PropertyName='TimeSpanStart') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fTimeSpan.StartTime:=PropertyElement.fProperties[ValuePropertyIndex].GetInteger;
      continue;
     end;
     if (PropertyName='TimeSpanStop') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fTimeSpan.EndTime:=PropertyElement.fProperties[ValuePropertyIndex].GetInteger;
      continue;
     end;
     if (PropertyName='CustomFrameRate') and
        (ValuePropertyIndex<PropertyElement.fProperties.Count) then begin
      fGlobalSettings.fCustomFrameRate:=PropertyElement.fProperties[ValuePropertyIndex].GetFloat;
      continue;
     end;
     if ValuePropertyIndex<PropertyElement.fProperties.Count then begin
      fGlobalSettings.AddProperty(PropertyName,PropertyElement.fProperties[ValuePropertyIndex].GetVariantValue);
     end;
    end;
   end;
  end;
 end;
 procedure ProcessObjects(const pObjectsElement:TpvFBXElement);
  procedure ProcessModel(const pModelElement:TpvFBXElement);
  var ID:TpvInt64;
      RawName,Type_,Name:TpvFBXString;
      StringList:TStringList;
      Node,MeshNode:TpvFBXNode;
      Camera:TpvFBXCamera;
      Light:TpvFBXLight;
      Mesh:TpvFBXMesh;
      Skeleton:TpvFBXSkeleton;
  begin
   if pModelElement.fProperties.Count=3 then begin
    ID:=pModelElement.fProperties[0].GetInteger;
    RawName:=pModelElement.fProperties[1].GetString;
    Type_:=pModelElement.fProperties[2].GetString;
   end else begin
    ID:=0;
    RawName:=pModelElement.fProperties[0].GetString;
    Type_:=pModelElement.fProperties[1].GetString;
   end;
   Name:=Parser.GetName(RawName);
   if Type_='Camera' then begin
    Camera:=TpvFBXCamera.Create(self,pModelElement,ID,Name,Type_);
    if ID<>0 then begin
     fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),Camera);
    end;
    fScene.fAllObjects.AddOrSetValue(RawName,Camera);
    fScene.fAllObjects.AddOrSetValue(Name,Camera);
    fScene.fCameras.Add(Camera);
   end else if Type_='Light' then begin
    Light:=TpvFBXLight.Create(self,pModelElement,ID,Name,Type_);
    if ID<>0 then begin
     fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),Light);
    end;
    fScene.fAllObjects.AddOrSetValue(RawName,Light);
    fScene.fAllObjects.AddOrSetValue(Name,Light);
    fScene.fLights.Add(Light);
   end else if Type_='Mesh' then begin
    if ID=0 then begin
     // For older versions of FBX
     MeshNode:=TpvFBXNode.Create(self,pModelElement,ID,Name,'Transform');
     fScene.fAllObjects.AddOrSetValue(RawName,MeshNode);
     fScene.fAllObjects.AddOrSetValue(Name,MeshNode);
     Mesh:=TpvFBXMesh.Create(self,pModelElement,ID,Name,'Mesh');
     fScene.fMeshes.Add(Mesh);
     MeshNode.ConnectTo(Mesh);
    end else begin
     // For newer versions of FBX
     Node:=TpvFBXNode.Create(self,pModelElement,ID,Name,'Transform');
     if ID<>0 then begin
      fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),Node);
     end;
     fScene.fAllObjects.AddOrSetValue(RawName,Node);
     fScene.fAllObjects.AddOrSetValue(Name,Node);
    end;
   end else if (Type_='Limb') or (Type_='LimbNode') then begin
    if Type_='Limb' then begin
     Skeleton:=TpvFBXSkeletonLimb.Create(self,pModelElement,ID,Name,Type_);
    end else begin
     Skeleton:=TpvFBXSkeletonLimbNode.Create(self,pModelElement,ID,Name,Type_);
    end;
    if ID<>0 then begin
     fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),Skeleton);
    end;
    fScene.fAllObjects.AddOrSetValue(RawName,Skeleton);
    fScene.fAllObjects.AddOrSetValue(Name,Skeleton);
    fScene.fSkeletons.Add(Skeleton);
   end else begin
    StringList:=TStringList.Create;
    try
     StringList.Delimiter:=':';
     StringList.StrictDelimiter:=true;
     StringList.DelimitedText:=String(Name);
     if StringList.Count>1 then begin
      Name:=TpvFBXString(StringList[1]);
      Node:=TpvFBXNode.Create(self,pModelElement,ID,Name,Type_);
      Node.fReference:=TpvFBXString(StringList[0]);
      if ID<>0 then begin
       fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),Node);
      end;
      fScene.fAllObjects.AddOrSetValue(RawName,Node);
      fScene.fAllObjects.AddOrSetValue(Name,Node);
     end else begin
      Node:=TpvFBXNode.Create(self,pModelElement,ID,Name,Type_);
      if ID<>0 then begin
       fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),Node);
      end;
      fScene.fAllObjects.AddOrSetValue(RawName,Node);
      fScene.fAllObjects.AddOrSetValue(Name,Node);
     end;
    finally
     StringList.Free;
    end;
   end;
  end;
  procedure ProcessGeometry(const pGeometryElement:TpvFBXElement);
  var ID:TpvInt64;
      Type_:TpvFBXString;
      Mesh:TpvFBXMesh;
  begin
   ID:=pGeometryElement.fProperties[0].GetInteger;
   Type_:=pGeometryElement.fProperties[2].GetString;
   if (Type_='Mesh') or (Type_='Shape') then begin
    Mesh:=TpvFBXMesh.Create(self,pGeometryElement,ID,TpvFBXString(IntToStr(ID)),'Mesh');
    if ID<>0 then begin
     fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),Mesh);
    end;
    fScene.fMeshes.Add(Mesh);
   end;
  end;
  procedure ProcessMaterial(const pMaterialElement:TpvFBXElement);
  var ID:TpvInt64;
      RawName,Name:TpvFBXString;
      Material:TpvFBXMaterial;
  begin
   if pMaterialElement.fProperties.Count=3 then begin
    ID:=pMaterialElement.fProperties[0].GetInteger;
    RawName:=pMaterialElement.fProperties[1].GetString;
   end else begin
    ID:=0;
    RawName:=pMaterialElement.fProperties[0].GetString;
   end;
   Name:=Parser.GetName(RawName);
   Material:=TpvFBXMaterial.Create(self,pMaterialElement,ID,Name,'Material');
   fScene.AllObjects.AddOrSetValue(RawName,Material);
   fScene.AllObjects.AddOrSetValue(Name,Material);
   if ID<>0 then begin
    fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),Material);
   end;
   fScene.fMaterials.Add(Material);
  end;
  procedure ProcessAnimationStack(const pAnimationStackElement:TpvFBXElement);
  var ID:TpvInt64;
      RawName,Name:TpvFBXString;
      AnimationStack:TpvFBXAnimationStack;
  begin
   if pAnimationStackElement.fProperties.Count=3 then begin
    ID:=pAnimationStackElement.fProperties[0].GetInteger;
    RawName:=pAnimationStackElement.fProperties[1].GetString;
   end else begin
    ID:=0;
    RawName:=pAnimationStackElement.fProperties[0].GetString;
   end;
   Name:=Parser.GetName(RawName);
   AnimationStack:=TpvFBXAnimationStack.Create(self,pAnimationStackElement,ID,Name,'AnimStack');
   fScene.AllObjects.AddOrSetValue(RawName,AnimationStack);
   fScene.AllObjects.AddOrSetValue(Name,AnimationStack);
   if ID<>0 then begin
    fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),AnimationStack);
   end;
   fScene.fAnimationStackList.Add(AnimationStack);
  end;
  procedure ProcessAnimationLayer(const pAnimationLayerElement:TpvFBXElement);
  var ID:TpvInt64;
      RawName,Name:TpvFBXString;
      AnimationLayer:TpvFBXAnimationLayer;
  begin
   if pAnimationLayerElement.fProperties.Count=3 then begin
    ID:=pAnimationLayerElement.fProperties[0].GetInteger;
    RawName:=pAnimationLayerElement.fProperties[1].GetString;
   end else begin
    ID:=0;
    RawName:=pAnimationLayerElement.fProperties[0].GetString;
   end;
   Name:=Parser.GetName(RawName);
   AnimationLayer:=TpvFBXAnimationLayer.Create(self,pAnimationLayerElement,ID,Name,'AnimLayer');
   fScene.AllObjects.AddOrSetValue(RawName,AnimationLayer);
   fScene.AllObjects.AddOrSetValue(Name,AnimationLayer);
   if ID<>0 then begin
    fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),AnimationLayer);
   end;
  end;
  procedure ProcessAnimationCurveNode(const pAnimationCurveNodeElement:TpvFBXElement);
  var ID:TpvInt64;
      RawName,Name:TpvFBXString;
      AnimationCurveNode:TpvFBXAnimationCurveNode;
  begin
   if pAnimationCurveNodeElement.fProperties.Count=3 then begin
    ID:=pAnimationCurveNodeElement.fProperties[0].GetInteger;
    RawName:=pAnimationCurveNodeElement.fProperties[1].GetString;
   end else begin
    ID:=0;
    RawName:=pAnimationCurveNodeElement.fProperties[0].GetString;
   end;
   Name:=Parser.GetName(RawName);
   AnimationCurveNode:=TpvFBXAnimationCurveNode.Create(self,pAnimationCurveNodeElement,ID,Name,'AnimCurveNode');
   fScene.AllObjects.AddOrSetValue(RawName,AnimationCurveNode);
   fScene.AllObjects.AddOrSetValue(Name,AnimationCurveNode);
   if ID<>0 then begin
    fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),AnimationCurveNode);
   end;
  end;
  procedure ProcessDeformer(const pDeformerElement:TpvFBXElement);
  var ID:TpvInt64;
      RawName,Name,Type_:TpvFBXString;
      Deformer:TpvFBXDeformer;
  begin
   if pDeformerElement.fProperties.Count=3 then begin
    ID:=pDeformerElement.fProperties[0].GetInteger;
    RawName:=pDeformerElement.fProperties[1].GetString;
    Type_:=pDeformerElement.fProperties[2].GetString;
   end else begin
    ID:=0;
    RawName:=pDeformerElement.fProperties[0].GetString;
    Type_:=pDeformerElement.fProperties[1].GetString;
   end;
   Name:=Parser.GetName(RawName);
   if Type_='Skin' then begin
    Deformer:=TpvFBXSkinDeformer.Create(self,pDeformerElement,ID,Name,'Skin');
   end else if Type_='Cluster' then begin
    Deformer:=TpvFBXCluster.Create(self,pDeformerElement,ID,Name,'Cluster');
   end else begin
    Deformer:=nil;
   end;
   if assigned(Deformer) then begin
    fScene.AllObjects.AddOrSetValue(RawName,Deformer);
    fScene.AllObjects.AddOrSetValue(Name,Deformer);
    if ID<>0 then begin
     fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),Deformer);
    end;
    fScene.fDeformers.Add(Deformer);
   end;
  end;
  procedure ProcessTexture(const pTextureElement:TpvFBXElement);
  var ID:TpvInt64;
      RawName,Name:TpvFBXString;
      Texture:TpvFBXTexture;
  begin
   if pTextureElement.fProperties.Count=3 then begin
    ID:=pTextureElement.fProperties[0].GetInteger;
    RawName:=pTextureElement.fProperties[1].GetString;
   end else begin
    ID:=0;
    RawName:=pTextureElement.fProperties[0].GetString;
   end;
   Name:=Parser.GetName(RawName);
   Texture:=TpvFBXTexture.Create(self,pTextureElement,ID,Name,'Texture');
   fScene.AllObjects.AddOrSetValue(RawName,Texture);
   fScene.AllObjects.AddOrSetValue(Name,Texture);
   if ID<>0 then begin
    fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),Texture);
   end;
   fScene.fTextures.Add(Texture);
  end;
  procedure ProcessFolder(const pFolderElement:TpvFBXElement);
  var ID:TpvInt64;
      RawName,Name:TpvFBXString;
      Folder:TpvFBXFolder;
  begin
   if pFolderElement.fProperties.Count=3 then begin
    ID:=pFolderElement.fProperties[0].GetInteger;
    RawName:=pFolderElement.fProperties[1].GetString;
   end else begin
    ID:=0;
    RawName:=pFolderElement.fProperties[0].GetString;
   end;
   Name:=Parser.GetName(RawName);
   Folder:=TpvFBXFolder.Create(self,pFolderElement,ID,Name,'Folder');
   fScene.AllObjects.AddOrSetValue(RawName,Folder);
   fScene.AllObjects.AddOrSetValue(Name,Folder);
   if ID<>0 then begin
    fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),Folder);
   end;
  end;
  procedure ProcessConstraint(const pConstraintElement:TpvFBXElement);
  var ID:TpvInt64;
      RawName,Name:TpvFBXString;
      Constraint:TpvFBXConstraint;
  begin
   if pConstraintElement.fProperties.Count=3 then begin
    ID:=pConstraintElement.fProperties[0].GetInteger;
    RawName:=pConstraintElement.fProperties[1].GetString;
   end else begin
    ID:=0;
    RawName:=pConstraintElement.fProperties[0].GetString;
   end;
   Name:=Parser.GetName(RawName);
   Constraint:=TpvFBXConstraint.Create(self,pConstraintElement,ID,Name,'Constraint');
   fScene.AllObjects.AddOrSetValue(RawName,Constraint);
   fScene.AllObjects.AddOrSetValue(Name,Constraint);
   if ID<>0 then begin
    fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),Constraint);
   end;
  end;
  procedure ProcessAnimationCurve(const pAnimationCurveElement:TpvFBXElement);
  var ID:TpvInt64;
      RawName,Name:TpvFBXString;
      AnimationCurve:TpvFBXAnimationCurve;
  begin
   if pAnimationCurveElement.fProperties.Count=3 then begin
    ID:=pAnimationCurveElement.fProperties[0].GetInteger;
    RawName:=pAnimationCurveElement.fProperties[1].GetString;
   end else begin
    ID:=0;
    RawName:=pAnimationCurveElement.fProperties[0].GetString;
   end;
   Name:=Parser.GetName(RawName);
   AnimationCurve:=TpvFBXAnimationCurve.Create(self,pAnimationCurveElement,ID,Name,'AnimCurve');
   fScene.AllObjects.AddOrSetValue(RawName,AnimationCurve);
   fScene.AllObjects.AddOrSetValue(Name,AnimationCurve);
   if ID<>0 then begin
    fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),AnimationCurve);
   end;
  end;
  procedure ProcessNodeAttribute(const pNodeAttributeElement:TpvFBXElement);
  var ID:TpvInt64;
      RawName,Name:TpvFBXString;
      NodeAttribute:TpvFBXNodeAttribute;
  begin
   if pNodeAttributeElement.fProperties.Count=3 then begin
    ID:=pNodeAttributeElement.fProperties[0].GetInteger;
    RawName:=pNodeAttributeElement.fProperties[1].GetString;
   end else begin
    ID:=0;
    RawName:=pNodeAttributeElement.fProperties[0].GetString;
   end;
   Name:=Parser.GetName(RawName);
   NodeAttribute:=TpvFBXNodeAttribute.Create(self,pNodeAttributeElement,ID,Name,'NodeAttribute');
   fScene.AllObjects.AddOrSetValue(RawName,NodeAttribute);
   fScene.AllObjects.AddOrSetValue(Name,NodeAttribute);
   if ID<>0 then begin
    fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),NodeAttribute);
   end;
  end;
  procedure ProcessSceneInfo(const pSceneInfoElement:TpvFBXElement);
  begin
   FreeAndNil(fScene.fSceneInfo);
   fScene.fSceneInfo:=TpvFBXSceneInfo.Create(self,pSceneInfoElement,0,pSceneInfoElement.ID,'SceneInfo');
  end;
  procedure ProcessPose(const pPoseElement:TpvFBXElement);
  begin
   fScene.fPoses.Add(TpvFBXPose.Create(self,pPoseElement,0,pPoseElement.Properties[0].GetString,pPoseElement.Properties[1].GetString));
  end;
  procedure ProcessVideo(const pVideoElement:TpvFBXElement);
  var ID:TpvInt64;
      RawName,Name:TpvFBXString;
      Video:TpvFBXVideo;
  begin
   if pVideoElement.fProperties.Count=3 then begin
    ID:=pVideoElement.fProperties[0].GetInteger;
    RawName:=pVideoElement.fProperties[1].GetString;
   end else begin
    ID:=0;
    RawName:=pVideoElement.fProperties[0].GetString;
   end;
   Name:=Parser.GetName(RawName);
   Video:=TpvFBXVideo.Create(self,pVideoElement,ID,Name,'Video');
   fScene.AllObjects.AddOrSetValue(RawName,Video);
   fScene.AllObjects.AddOrSetValue(Name,Video);
   if ID<>0 then begin
    fScene.AllObjects.AddOrSetValue(TpvFBXString(IntToStr(ID)),Video);
   end;
   fScene.fVideos.Add(Video);
  end;
 var Element:TpvFBXElement;
 begin
  for Element in pObjectsElement.Children do begin
   if Element.ID='Model' then begin
    ProcessModel(Element);
   end else if Element.ID='Geometry' then begin
    ProcessGeometry(Element);
   end else if Element.ID='Material' then begin
    ProcessMaterial(Element);
   end else if Element.ID='AnimationStack' then begin
    ProcessAnimationStack(Element);
   end else if Element.ID='AnimationLayer' then begin
    ProcessAnimationLayer(Element);
   end else if Element.ID='AnimationCurveNode' then begin
    ProcessAnimationCurveNode(Element);
   end else if Element.ID='Deformer' then begin
    ProcessDeformer(Element);
   end else if Element.ID='Texture' then begin
    ProcessTexture(Element);
   end else if Element.ID='Folder' then begin
    ProcessFolder(Element);
   end else if Element.ID='Constraint' then begin
    ProcessConstraint(Element);
   end else if Element.ID='AnimationCurve' then begin
    ProcessAnimationCurve(Element);
   end else if Element.ID='NodeAttribute' then begin
    ProcessNodeAttribute(Element);
   end else if Element.ID='GlobalSettings' then begin
    ProcessGlobalSettings(Element);
   end else if Element.ID='SceneInfo' then begin
    ProcessSceneInfo(Element);
   end else if Element.ID='Pose' then begin
    ProcessPose(Element);
   end else if Element.ID='Video' then begin
    ProcessVideo(Element);
   end;
  end;
 end;
 procedure ProcessConnections(const pConnectionsElement:TpvFBXElement);
 var Element:TpvFBXElement;
     Type_,Src,Dst,Attribute:TpvFBXString;
     SrcObject,DstObject:TpvFBXObject;
     StringList:TStringList;
     Mesh:TpvFBXMesh;
 begin
  for Element in pConnectionsElement.Children do begin
   if (Element.ID='C') or (Element.ID='Connect') then begin
    Type_:=Element.Properties[0].GetString;
    if Type_='OO' then begin
     Src:=Element.Properties[1].GetString;
     Dst:=Element.Properties[2].GetString;
     if fScene.fAllObjects.TryGetValue(Src,SrcObject) then begin
      if assigned(SrcObject) then begin
       if (Dst='0') or (Dst=Parser.SceneName) then begin
        fScene.fRootNodes.Add(SrcObject);
       end else if fScene.fAllObjects.TryGetValue(Dst,DstObject) then begin
        if assigned(DstObject) then begin
         DstObject.ConnectTo(SrcObject);
        end;
       end;
      end;
     end;
    end else if Type_='OP' then begin
     Src:=Element.Properties[1].GetString;
     Dst:=Element.Properties[2].GetString;
     Attribute:=Element.Properties[3].GetString;
     if length(Attribute)>0 then begin
      if Pos('|',String(Attribute))>0 then begin
       StringList:=TStringList.Create;
       try
        StringList.Delimiter:='|';
        StringList.StrictDelimiter:=true;
        StringList.DelimitedText:=String(Attribute);
        if StringList.Count>0 then begin
         Attribute:=TpvFBXString(StringList[StringList.Count-1]);
        end;
       finally
        StringList.Free;
       end;
      end;
      if length(Attribute)>0 then begin
       if fScene.fAllObjects.TryGetValue(Src,SrcObject) then begin
        if assigned(SrcObject) then begin
         if fScene.fAllObjects.TryGetValue(Dst,DstObject) then begin
          if assigned(DstObject) then begin
           DstObject.ConnectToProperty(SrcObject,Attribute);
          end;
         end;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
  begin
   // Older FBX versions are connecting deformers to the transform instead of the mesh. So, that must fix it here
   for Mesh in fScene.fMeshes do begin
    if Mesh.fConnectedFrom.Count>0 then begin
     for SrcObject in Mesh.fConnectedFrom do begin
      if SrcObject is TpvFBXNode then begin
       for DstObject in SrcObject.fConnectedTo do begin
        if DstObject is TpvFBXDeformer then begin
         if not Mesh.fConnectedTo.Contains(DstObject) then begin
          Mesh.ConnectTo(DstObject);
         end;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 procedure ProcessTakes(const pTakesElement:TpvFBXElement);
 var CurrentTakeName:TpvFBXString;
  procedure ProcessTake(const pTakeElement:TpvFBXElement);
  var Element,SubElement,SubSubElement,SubSubSubElement:TpvFBXElement;
      TakeName,Name,SubElementKind,SubSubElementKind,SubSubSubElementKind:TpvFBXString;
      Object_:TpvFBXObject;
      Take:TpvFBXTake;
      AnimationStack:TpvFBXAnimationStack;
      AnimationLayer:TpvFBXAnimationLayer;
      AnimationCurveNode:TpvFBXAnimationCurveNode;
      AnimationCurve:TpvFBXAnimationCurve;
  begin
   TakeName:=pTakeElement.Properties[0].GetString;
   Take:=TpvFBXTake.Create(self,pTakeElement,0,TakeName,'Take');
   fScene.fTakes.Add(Take);
   if CurrentTakeName=TakeName then begin
    fScene.fCurrentTake:=Take;
   end;
   if fFileVersion<7000 then begin
    begin
     AnimationStack:=TpvFBXAnimationStack.Create(self,nil,0,Parser.ConstructName([TpvFBXString('AnimStack'),TakeName]),'AnimStack');
     fScene.AllObjects.AddOrSetValue(TakeName,AnimationStack);
     fScene.AllObjects.AddOrSetValue(AnimationStack.Name,AnimationStack);
     fScene.fAnimationStackList.Add(AnimationStack);
     AnimationStack.fDescription:=TakeName;
     AnimationStack.fLocalStart:=Take.fLocalTimeSpan.StartTime;
     AnimationStack.fLocalStop:=Take.fLocalTimeSpan.EndTime;
     AnimationStack.fReferenceStart:=Take.fReferenceTimeSpan.StartTime;
     AnimationStack.fReferenceStop:=Take.fReferenceTimeSpan.EndTime;
    end;
    begin
     AnimationLayer:=TpvFBXAnimationLayer.Create(self,nil,0,Parser.ConstructName([TpvFBXString('AnimLayer'),TakeName]),'AnimLayer');
     fScene.AllObjects.AddOrSetValue(TakeName,AnimationLayer);
     fScene.AllObjects.AddOrSetValue(AnimationLayer.Name,AnimationLayer);
     AnimationLayer.ConnectTo(AnimationStack);
    end;
    for Element in pTakeElement.Children do begin
     if Element.ID='Model' then begin
      Name:=Element.Properties[0].GetString;
      Object_:=Scene.AllObjects[Name];
      if assigned(Object_) then begin
       for SubElement in Element.Children do begin
        if (SubElement.ID='C') or (SubElement.ID='Channel') then begin
         SubElementKind:=SubElement.Properties[0].GetString;
         if SubElementKind='Transform' then begin
          for SubSubElement in SubElement.Children do begin
           if (SubSubElement.ID='C') or (SubSubElement.ID='Channel') then begin
            SubSubElementKind:=SubSubElement.Properties[0].GetString;
            if (SubSubElementKind='T') or
               (SubSubElementKind='R') or
               (SubSubElementKind='S') then begin
             if SubSubElementKind='T' then begin
              AnimationCurveNode:=TpvFBXAnimationCurveNode.Create(self,nil,0,'T','AnimCurveNode');
              AnimationCurveNode.ConnectTo(AnimationLayer);
              Object_.ConnectToProperty(AnimationCurveNode,'Lcl Translation');
             end else if SubSubElementKind='R' then begin
              AnimationCurveNode:=TpvFBXAnimationCurveNode.Create(self,nil,0,'R','AnimCurveNode');
              AnimationCurveNode.ConnectTo(AnimationLayer);
              Object_.ConnectToProperty(AnimationCurveNode,'Lcl Rotation');
             end else{if SubSubElementKind='S' then}begin
              AnimationCurveNode:=TpvFBXAnimationCurveNode.Create(self,nil,0,'S','AnimCurveNode');
              AnimationCurveNode.ConnectTo(AnimationLayer);
              Object_.ConnectToProperty(AnimationCurveNode,'Lcl Scaling');
             end;
             for SubSubSubElement in SubSubElement.Children do begin
              if (SubSubSubElement.ID='C') or (SubSubSubElement.ID='Channel') then begin
               SubSubSubElementKind:=SubSubSubElement.Properties[0].GetString;
               if (SubSubSubElementKind='X') or
                  (SubSubSubElementKind='Y') or
                  (SubSubSubElementKind='Z') then begin
                AnimationCurve:=TpvFBXAnimationCurve.CreateOldFBX6000(self,SubSubSubElement,0,Parser.ConstructName([TpvFBXString('AnimCurve'),TakeName,SubElementKind,SubSubElementKind,SubSubSubElementKind]),'AnimCurve');
                AnimationCurveNode.ConnectToProperty(AnimationCurve,SubSubSubElementKind);
               end;
              end;
             end;
            end;
           end;
          end;
         end else if SubElementKind='Visibility' then begin
          AnimationCurveNode:=TpvFBXAnimationCurveNode.Create(self,nil,0,'Visibility','AnimCurveNode');
          AnimationCurveNode.ConnectTo(AnimationLayer);
          Object_.ConnectToProperty(AnimationCurveNode,'Visibility');
          AnimationCurve:=TpvFBXAnimationCurve.CreateOldFBX6000(self,SubElement,0,Parser.ConstructName([TpvFBXString('AnimCurve'),TakeName,SubElementKind]),'AnimCurve');
          AnimationCurveNode.ConnectToProperty(AnimationCurve,SubElementKind);
         end;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 var Element:TpvFBXElement;
 begin
  CurrentTakeName:='';
  for Element in pTakesElement.Children do begin
   if Element.ID='Current' then begin
    CurrentTakeName:=Element.Properties[0].GetString;
   end else if Element.ID='Take' then begin
    ProcessTake(Element);
   end;
  end;
 end;
var FirstByte:TpvUInt8;
    ChildElement:TpvFBXElement;
    Mesh:TpvFBXMesh;
begin

 FirstByte:=0;

 pStream.ReadBuffer(FirstByte,SizeOf(TpvUInt8));

 pStream.Seek(-SizeOf(TpvUInt8),soCurrent);

 Parser:=nil;
 try

  case FirstByte of
   ord(';'):begin
    Parser:=TpvFBXASCIIParser.Create(pStream);
   end;
   ord('K'):begin
    Parser:=TpvFBXBinaryParser.Create(pStream);
   end;
  end;

  if not assigned(Parser) then begin
   raise EFBX.Create('Invalid oder corrupt FBX file');
  end;

  FreeAndNil(fGlobalSettings);

  FreeAndNil(fScene);

  FreeAndNil(fRootElement);

  fRootElement:=Parser.Parse;
  if assigned(fRootElement) then begin
   try
    fScene:=TpvFBXScene.Create(self,fRootElement,0,TpvFBXString(#0'Scene'#255),'');
    if fRootElement.ChildrenByName.TryGetValue('FBXHeaderExtension',ChildElement) then begin
     ProcessFBXHeaderExtension(ChildElement);
    end;
    if fRootElement.ChildrenByName.TryGetValue('GlobalSettings',ChildElement) then begin
     ProcessGlobalSettings(ChildElement);
    end;
    if fRootElement.ChildrenByName.TryGetValue('Objects',ChildElement) then begin
     ProcessObjects(ChildElement);
    end;
    if fRootElement.ChildrenByName.TryGetValue('Connections',ChildElement) then begin
     ProcessConnections(ChildElement);
    end;
    if fRootElement.ChildrenByName.TryGetValue('Takes',ChildElement) then begin
     ProcessTakes(ChildElement);
    end;
   finally
   end;
  end;

  for Mesh in fScene.fMeshes do begin
   Mesh.Finish;
  end;

 finally
  Parser.Free;
 end;

end;

procedure TpvFBXLoader.LoadFromFile(const pFileName:UTF8String);
var fs:TFileStream;
    ms:TMemoryStream;
begin
 fs:=TFileStream.Create(String(pFileName),fmOpenRead or fmShareDenyWrite);
 try
  ms:=TMemoryStream.Create;
  try
   ms.LoadFromStream(fs);
   ms.Seek(0,soBeginning);
   LoadFromStream(ms);
  finally
   ms.Free;
  end;
 finally
  fs.Free;
 end;
end;

initialization
 PropertyNameRemap:=TpvFBXPropertyNameRemap.Create;
 PropertyNameRemap.AddOrSetValue(TpvFBXString('Lcl Translation'),TpvFBXString('LclTranslation'));
 PropertyNameRemap.AddOrSetValue(TpvFBXString('Lcl Rotation'),TpvFBXString('LclRotation'));
 PropertyNameRemap.AddOrSetValue(TpvFBXString('Lcl Scaling'),TpvFBXString('LclScaling'));
 PropertyNameRemap.AddOrSetValue(TpvFBXString('X'),TpvFBXString('x'));
 PropertyNameRemap.AddOrSetValue(TpvFBXString('Y'),TpvFBXString('y'));
 PropertyNameRemap.AddOrSetValue(TpvFBXString('Z'),TpvFBXString('z'));
finalization
 PropertyNameRemap.Free;
end.

