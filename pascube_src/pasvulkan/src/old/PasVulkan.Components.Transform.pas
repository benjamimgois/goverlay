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
unit PasVulkan.Components.Transform;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

uses SysUtils,
     Classes,
     Math,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.EntityComponentSystem;

type TpvComponentTransformFlag=
      (
       Static,
       RelativePosition,
       RelativeRotation,
       RelativeScale
      );

     TpvComponentTransformFlags=set of TpvComponentTransformFlag;

     TpvComponentTransform=class(TpvComponent)
      private
       fFlags:TpvComponentTransformFlags;
       fPosition:TpvVector3Property;
       fRotation:TpvQuaternionProperty;
       fScale:TpvVector3Property;
       fParent:TpvEntityID;
      public
       RawPosition:TpvVector3;
       RawRotation:TpvQuaternion;
       RawScale:TpvVector3;
       RawMatrix:TpvMatrix4x4;
       constructor Create; override;
       destructor Destroy; override;
       class function ClassPath:string; override;
       class function ClassUUID:TpvUUID; override;
      published
       property Position:TpvVector3Property read fPosition write fPosition;
       property Rotation:TpvQuaternionProperty read fRotation write fRotation;
       property Scale:TpvVector3Property read fScale write fScale;
       property Parent:TpvEntityID read fParent write fParent;
       property Flags:TpvComponentTransformFlags read fFlags write fFlags;
     end;

implementation

constructor TpvComponentTransform.Create;
begin
 inherited Create;
 RawPosition:=TpvVector3.Origin;
 RawRotation:=TpvQuaternion.Identity;
 RawScale:=TpvVector3.Create(1.0,1.0,1.0);
 fFlags:=[];
 fPosition:=TpvVector3Property.Create(@RawPosition);
 fRotation:=TpvQuaternionProperty.Create(@RawRotation);
 fScale:=TpvVector3Property.Create(@RawScale);
 fParent:=-1;
end;

destructor TpvComponentTransform.Destroy;
begin
 FreeAndNil(fPosition);
 FreeAndNil(fRotation);
 FreeAndNil(fScale);
 inherited Destroy;
end;

class function TpvComponentTransform.ClassPath:string;
begin
 result:='Transform';
end;

class function TpvComponentTransform.ClassUUID:TpvUUID;
begin
 result.UInt64s[0]:=TpvUInt64($9a22d45f4e3943d3);
 result.UInt64s[1]:=TpvUInt64($b1520b1ce1cabfe9);
end;

initialization
end.

