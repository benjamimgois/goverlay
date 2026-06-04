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
unit PasVulkan.JSON;
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
     PasJSON,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Math.Double,
     PasVulkan.Collections,
     PasVulkan.Utils;

type TpvJSONUtils=class
      class procedure ResolveTemplates(const aJSONItem:TPasJSONItem); static;
      class procedure ResolveInheritances(const aJSONItem:TPasJSONItem); static;
     end;

function JSONToVector2(const aVectorJSONItem:TPasJSONItem;const aDefault:TpvVector2):TpvVector2;
function Vector2ToJSON(const aVector:TpvVector2):TPasJSONItemArray;

function JSONToVector3(const aVectorJSONItem:TPasJSONItem;const aDefault:TpvVector3):TpvVector3;
function Vector3ToJSON(const aVector:TpvVector3):TPasJSONItemArray;

function JSONToVector4(const aVectorJSONItem:TPasJSONItem;const aDefault:TpvVector4):TpvVector4;
function Vector4ToJSON(const aVector:TpvVector4):TPasJSONItemArray;

function JSONToMatrix4x4(const aMatrixJSONItem:TPasJSONItem;const aDefault:TpvMatrix4x4):TpvMatrix4x4;
function Matrix4x4ToJSON(const aMatrix:TpvMatrix4x4):TPasJSONItemArray;

function JSONToVector2D(const aVectorJSONItem:TPasJSONItem;const aDefault:TpvVector2D):TpvVector2D;
function Vector2DToJSON(const aVector:TpvVector2D):TPasJSONItemArray;

function JSONToVector3D(const aVectorJSONItem:TPasJSONItem;const aDefault:TpvVector3D):TpvVector3D;
function Vector3DToJSON(const aVector:TpvVector3D):TPasJSONItemArray;

function JSONToVector4D(const aVectorJSONItem:TPasJSONItem;const aDefault:TpvVector4D):TpvVector4D;
function Vector4DToJSON(const aVector:TpvVector4D):TPasJSONItemArray;

function JSONToMatrix4x4D(const aMatrixJSONItem:TPasJSONItem;const aDefault:TpvMatrix4x4D):TpvMatrix4x4D;
function Matrix4x4DToJSON(const aMatrix:TpvMatrix4x4D):TPasJSONItemArray;

implementation

function JSONToVector2(const aVectorJSONItem:TPasJSONItem;const aDefault:TpvVector2):TpvVector2;
begin
 if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemArray) and (TPasJSONItemArray(aVectorJSONItem).Count=2) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[0],0.0);
  result.y:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[1],0.0);
 end else if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemObject) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['x'],0.0);
  result.y:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['y'],0.0);
 end else begin
  result:=aDefault;
 end;
end;

function Vector2ToJSON(const aVector:TpvVector2):TPasJSONItemArray;
begin
 result:=TPasJSONItemArray.Create;
 result.Add(TPasJSONItemNumber.Create(aVector.x));
 result.Add(TPasJSONItemNumber.Create(aVector.y));
end;

function JSONToVector3(const aVectorJSONItem:TPasJSONItem;const aDefault:TpvVector3):TpvVector3;
begin
 if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemArray) and (TPasJSONItemArray(aVectorJSONItem).Count=3) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[0],0.0);
  result.y:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[1],0.0);
  result.z:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[2],0.0);
 end else if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemObject) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['x'],TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['pitch'],0.0));
  result.y:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['y'],TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['yaw'],0.0));
  result.z:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['z'],TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['roll'],0.0));
 end else begin
  result:=aDefault;
 end;
end;

function Vector3ToJSON(const aVector:TpvVector3):TPasJSONItemArray;
begin
 result:=TPasJSONItemArray.Create;
 result.Add(TPasJSONItemNumber.Create(aVector.x));
 result.Add(TPasJSONItemNumber.Create(aVector.y));
 result.Add(TPasJSONItemNumber.Create(aVector.z));
end;

function JSONToVector4(const aVectorJSONItem:TPasJSONItem;const aDefault:TpvVector4):TpvVector4;
begin
 if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemArray) and (TPasJSONItemArray(aVectorJSONItem).Count=4) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[0],0.0);
  result.y:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[1],0.0);
  result.z:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[2],0.0);
  result.w:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[3],0.0);
 end else if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemObject) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['x'],0.0);
  result.y:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['y'],0.0);
  result.z:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['z'],0.0);
  result.w:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['w'],0.0);
 end else begin
  result:=aDefault;
 end;
end;

function Vector4ToJSON(const aVector:TpvVector4):TPasJSONItemArray;
begin
 result:=TPasJSONItemArray.Create;
 result.Add(TPasJSONItemNumber.Create(aVector.x));
 result.Add(TPasJSONItemNumber.Create(aVector.y));
 result.Add(TPasJSONItemNumber.Create(aVector.z));
 result.Add(TPasJSONItemNumber.Create(aVector.w));
end;

function JSONToMatrix4x4(const aMatrixJSONItem:TPasJSONItem;const aDefault:TpvMatrix4x4):TpvMatrix4x4;
begin
 if assigned(aMatrixJSONItem) and (aMatrixJSONItem is TPasJSONItemArray) and (TPasJSONItemArray(aMatrixJSONItem).Count=16) then begin
  result.RawComponents[0,0]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[0],1.0);
  result.RawComponents[0,1]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[1],0.0);
  result.RawComponents[0,2]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[2],0.0);
  result.RawComponents[0,3]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[3],0.0);
  result.RawComponents[1,0]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[4],0.0);
  result.RawComponents[1,1]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[5],1.0);
  result.RawComponents[1,2]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[6],0.0);
  result.RawComponents[1,3]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[7],0.0);
  result.RawComponents[2,0]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[8],0.0);
  result.RawComponents[2,1]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[9],0.0);
  result.RawComponents[2,2]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[10],1.0);
  result.RawComponents[2,3]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[11],0.0);
  result.RawComponents[3,0]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[12],0.0);
  result.RawComponents[3,1]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[13],0.0);
  result.RawComponents[3,2]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[14],0.0);
  result.RawComponents[3,3]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[15],1.0);
 end else if assigned(aMatrixJSONItem) and (aMatrixJSONItem is TPasJSONItemObject) then begin
  result.RawComponents[0,0]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m00'],1.0);
  result.RawComponents[0,1]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m01'],0.0);
  result.RawComponents[0,2]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m02'],0.0);
  result.RawComponents[0,3]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m03'],0.0);
  result.RawComponents[1,0]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m10'],0.0);
  result.RawComponents[1,1]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m11'],1.0);
  result.RawComponents[1,2]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m12'],0.0);
  result.RawComponents[1,3]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m13'],0.0);
  result.RawComponents[2,0]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m20'],0.0);
  result.RawComponents[2,1]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m21'],0.0);
  result.RawComponents[2,2]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m22'],1.0);
  result.RawComponents[2,3]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m23'],0.0);
  result.RawComponents[3,0]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m30'],0.0);
  result.RawComponents[3,1]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m31'],0.0);
  result.RawComponents[3,2]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m32'],0.0);
  result.RawComponents[3,3]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m33'],1.0);
 end else begin
  result:=aDefault;
 end;
end;

function Matrix4x4ToJSON(const aMatrix:TpvMatrix4x4):TPasJSONItemArray;
begin
 result:=TPasJSONItemArray.Create;
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[0,0]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[0,1]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[0,2]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[0,3]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[1,0]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[1,1]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[1,2]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[1,3]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[2,0]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[2,1]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[2,2]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[2,3]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[3,0]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[3,1]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[3,2]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[3,3]));
end;


function JSONToVector2D(const aVectorJSONItem:TPasJSONItem;const aDefault:TpvVector2D):TpvVector2D;
begin
 if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemArray) and (TPasJSONItemArray(aVectorJSONItem).Count=2) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[0],0.0);
  result.y:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[1],0.0);
 end else if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemObject) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['x'],0.0);
  result.y:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['y'],0.0);
 end else begin
  result:=aDefault;
 end;
end;

function Vector2DToJSON(const aVector:TpvVector2D):TPasJSONItemArray;
begin
 result:=TPasJSONItemArray.Create;
 result.Add(TPasJSONItemNumber.Create(aVector.x));
 result.Add(TPasJSONItemNumber.Create(aVector.y));
end;

function JSONToVector3D(const aVectorJSONItem:TPasJSONItem;const aDefault:TpvVector3D):TpvVector3D;
begin
 if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemArray) and (TPasJSONItemArray(aVectorJSONItem).Count=3) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[0],0.0);
  result.y:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[1],0.0);
  result.z:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[2],0.0);
 end else if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemObject) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['x'],TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['pitch'],0.0));
  result.y:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['y'],TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['yaw'],0.0));
  result.z:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['z'],TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['roll'],0.0));
 end else begin
  result:=aDefault;
 end;
end;

function Vector3DToJSON(const aVector:TpvVector3D):TPasJSONItemArray;
begin
 result:=TPasJSONItemArray.Create;
 result.Add(TPasJSONItemNumber.Create(aVector.x));
 result.Add(TPasJSONItemNumber.Create(aVector.y));
 result.Add(TPasJSONItemNumber.Create(aVector.z));
end;

function JSONToVector4D(const aVectorJSONItem:TPasJSONItem;const aDefault:TpvVector4D):TpvVector4D;
begin
 if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemArray) and (TPasJSONItemArray(aVectorJSONItem).Count=4) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[0],0.0);
  result.y:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[1],0.0);
  result.z:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[2],0.0);
  result.w:=TPasJSON.GetNumber(TPasJSONItemArray(aVectorJSONItem).Items[3],0.0);
 end else if assigned(aVectorJSONItem) and (aVectorJSONItem is TPasJSONItemObject) then begin
  result.x:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['x'],0.0);
  result.y:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['y'],0.0);
  result.z:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['z'],0.0);
  result.w:=TPasJSON.GetNumber(TPasJSONItemObject(aVectorJSONItem).Properties['w'],0.0);
 end else begin
  result:=aDefault;
 end;
end;

function Vector4DToJSON(const aVector:TpvVector4D):TPasJSONItemArray;
begin
 result:=TPasJSONItemArray.Create;
 result.Add(TPasJSONItemNumber.Create(aVector.x));
 result.Add(TPasJSONItemNumber.Create(aVector.y));
 result.Add(TPasJSONItemNumber.Create(aVector.z));
 result.Add(TPasJSONItemNumber.Create(aVector.w));
end;

function JSONToMatrix4x4D(const aMatrixJSONItem:TPasJSONItem;const aDefault:TpvMatrix4x4D):TpvMatrix4x4D;
begin
 if assigned(aMatrixJSONItem) and (aMatrixJSONItem is TPasJSONItemArray) and (TPasJSONItemArray(aMatrixJSONItem).Count=16) then begin
  result.RawComponents[0,0]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[0],1.0);
  result.RawComponents[0,1]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[1],0.0);
  result.RawComponents[0,2]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[2],0.0);
  result.RawComponents[0,3]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[3],0.0);
  result.RawComponents[1,0]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[4],0.0);
  result.RawComponents[1,1]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[5],1.0);
  result.RawComponents[1,2]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[6],0.0);
  result.RawComponents[1,3]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[7],0.0);
  result.RawComponents[2,0]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[8],0.0);
  result.RawComponents[2,1]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[9],0.0);
  result.RawComponents[2,2]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[10],1.0);
  result.RawComponents[2,3]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[11],0.0);
  result.RawComponents[3,0]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[12],0.0);
  result.RawComponents[3,1]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[13],0.0);
  result.RawComponents[3,2]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[14],0.0);
  result.RawComponents[3,3]:=TPasJSON.GetNumber(TPasJSONItemArray(aMatrixJSONItem).Items[15],1.0);
 end else if assigned(aMatrixJSONItem) and (aMatrixJSONItem is TPasJSONItemObject) then begin
  result.RawComponents[0,0]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m00'],1.0);
  result.RawComponents[0,1]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m01'],0.0);
  result.RawComponents[0,2]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m02'],0.0);
  result.RawComponents[0,3]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m03'],0.0);
  result.RawComponents[1,0]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m10'],0.0);
  result.RawComponents[1,1]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m11'],1.0);
  result.RawComponents[1,2]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m12'],0.0);
  result.RawComponents[1,3]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m13'],0.0);
  result.RawComponents[2,0]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m20'],0.0);
  result.RawComponents[2,1]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m21'],0.0);
  result.RawComponents[2,2]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m22'],1.0);
  result.RawComponents[2,3]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m23'],0.0);
  result.RawComponents[3,0]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m30'],0.0);
  result.RawComponents[3,1]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m31'],0.0);
  result.RawComponents[3,2]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m32'],0.0);
  result.RawComponents[3,3]:=TPasJSON.GetNumber(TPasJSONItemObject(aMatrixJSONItem).Properties['m33'],1.0);
 end else begin
  result:=aDefault;
 end;
end;

function Matrix4x4DToJSON(const aMatrix:TpvMatrix4x4D):TPasJSONItemArray;
begin
 result:=TPasJSONItemArray.Create;
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[0,0]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[0,1]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[0,2]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[0,3]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[1,0]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[1,1]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[1,2]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[1,3]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[2,0]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[2,1]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[2,2]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[2,3]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[3,0]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[3,1]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[3,2]));
 result.Add(TPasJSONItemNumber.Create(aMatrix.RawComponents[3,3]));
end;

{ TpvJSONUtils }

class procedure TpvJSONUtils.ResolveTemplates(const aJSONItem:TPasJSONItem);
type TStackItem=record
      Level:TpvSizeInt;
      JSONItem:TPasJSONItem;
     end;
     TStack=TpvDynamicStack<TStackItem>;
     TJSONItemObjectQueue=TpvDynamicQueue<TPasJSONItemObject>;
 function NewStackItem(const aLevel:TpvSizeInt;const aJSONItem:TPasJSONItem):TStackItem;
 begin
  result.Level:=aLevel;
  result.JSONItem:=aJSONItem;
 end;
var JSONItemTemplates,JSONItem,TemplateJSONItem:TPasJSONItem;
    JSONItemObject,
    TemporaryJSONItemObject:TPasJSONItemObject;
    JSONItemObjectProperty:TPasJSONItemObjectProperty;
    Stack:TStack;
    StackItem:TStackItem;
    TemplateName:TPasJSONUTF8String;
    JSONItemObjectQueue:TJSONItemObjectQueue;
begin
 if assigned(aJSONItem) and (aJSONItem is TPasJSONItemObject) then begin
  JSONItemTemplates:=TPasJSONItemObject(aJSONItem).Properties['templates'];
  if assigned(JSONItemTemplates) and (JSONItemTemplates is TPasJSONItemObject) then begin
   Stack.Initialize;
   try
    Stack.Push(NewStackItem(0,TPasJSONItemObject(aJSONItem)));
    JSONItemObjectQueue.Initialize;
    try
     while Stack.Pop(StackItem) do begin
      if StackItem.JSONItem is TPasJSONItemArray then begin
       for JSONItem in TPasJSONItemArray(StackItem.JSONItem) do begin
        if assigned(JSONItem) and
           ((JSONItem is TPasJSONItemArray) or
            (JSONItem is TPasJSONItemObject)) then begin
         Stack.Push(NewStackItem(StackItem.Level+1,JSONItem));
        end;
       end;
      end else if StackItem.JSONItem is TPasJSONItemObject then begin
       for JSONItemObjectProperty in TPasJSONItemObject(StackItem.JSONItem) do begin
        if JSONItemObjectProperty.Key='templates' then begin
         if (StackItem.Level>0) and
            assigned(JSONItemObjectProperty.Value) and
            (JSONItemObjectProperty.Value is TPasJSONItemArray) then begin
          for JSONItem in TPasJSONItemArray(JSONItemObjectProperty.Value) do begin
           TemplateName:=TPasJSON.GetString(JSONItem,'');
           if length(TemplateName)>0 then begin
            TemplateJSONItem:=TPasJSONItemObject(JSONItemTemplates).Properties[TemplateName];
            if assigned(TemplateJSONItem) and (TemplateJSONItem is TPasJSONItemObject) then begin
             JSONItemObjectQueue.Enqueue(TPasJSONItemObject(TemplateJSONItem));
            end;
           end;
          end;
         end;
        end else begin
         if assigned(JSONItemObjectProperty.Value) and
            ((JSONItemObjectProperty.Value is TPasJSONItemArray) or
             (JSONItemObjectProperty.Value is TPasJSONItemObject)) then begin
          Stack.Push(NewStackItem(StackItem.Level+1,JSONItemObjectProperty.Value));
         end;
        end;
       end;
       if StackItem.Level>0 then begin
        TPasJSONItemObject(StackItem.JSONItem).Delete(TPasJSONItemObject(StackItem.JSONItem).Indices['templates']);
        try
         if JSONItemObjectQueue.Count>0 then begin
          TemporaryJSONItemObject:=TPasJSONItemObject.Create;
          try
           while JSONItemObjectQueue.Dequeue(JSONItemObject) do begin
            TemporaryJSONItemObject.Merge(JSONItemObject,[TPasJSONMergeFlag.ForceObjectPropertyValueDestinationType]);
           end;
           TemporaryJSONItemObject.Merge(TPasJSONItemObject(StackItem.JSONItem),[TPasJSONMergeFlag.ForceObjectPropertyValueDestinationType]);
           TPasJSONItemObject(StackItem.JSONItem).Clear;
           TPasJSONItemObject(StackItem.JSONItem).Merge(TemporaryJSONItemObject);
          finally
           FreeAndNil(TemporaryJSONItemObject);
          end;
         end;
        finally
         JSONItemObjectQueue.Clear;
        end;
       end;
      end;
     end;
    finally
     JSONItemObjectQueue.Finalize;
    end;
   finally
    Stack.Finalize;
   end;
   TPasJSONItemObject(aJSONItem).Delete(TPasJSONItemObject(aJSONItem).Indices['templates']);
  end;
 end;
end;

class procedure TpvJSONUtils.ResolveInheritances(const aJSONItem:TPasJSONItem);
type TInt32DynamicArray=TpvDynamicArray<TpvInt32>;
     TObjectNameHashMap=TpvStringHashMap<TpvInt32>;
     TObjectItem=record
      Index:TpvInt32;
      Name:TpvUTF8String;
      JSONItemObject:TPasJSONItemObject;
      Dependencies:TInt32DynamicArray;
     end;
     PObjectItem=^TObjectItem;
     TObjectItemDynamicArray=TpvDynamicArray<TObjectItem>;
     TStringDynamicArray=TpvDynamicArray<TpvUTF8String>;
var Index,OtherIndex:TpvSizeInt;
    YetOtherIndex:TpvInt32;
    ObjectItemDynamicArray:TObjectItemDynamicArray;
    JSONItemObjectProperty:TPasJSONItemObjectProperty;
    JSONItemObject,
    TemporaryJSONItemObject:TPasJSONItemObject;
    ParentJSONItem:TPasJSONItem;
    ObjectItem,
    OtherObjectItem:PObjectItem;
    ParentObjectNames:TStringDynamicArray;
    ObjectName:TpvUTF8String;
    ObjectNameHashMap:TObjectNameHashMap;
    TopologicalSort:TpvTopologicalSort;
begin
 if assigned(aJSONItem) and (aJSONItem is TPasJSONItemObject) then begin
  ObjectItemDynamicArray.Initialize;
  try
   ObjectNameHashMap:=TObjectNameHashMap.Create(-1);
   try
    ParentObjectNames.Initialize;
    try
     for JSONItemObjectProperty in TPasJSONItemObject(aJSONItem) do begin
      if assigned(JSONItemObjectProperty.Value) and (JSONItemObjectProperty.Value is TPasJSONItemObject) then begin
       JSONItemObject:=TPasJSONItemObject(JSONItemObjectProperty.Value);
       OtherIndex:=ObjectItemDynamicArray.AddNewIndex;
       ObjectItem:=@ObjectItemDynamicArray.Items[OtherIndex];
       ObjectItem^.Index:=OtherIndex;
       ObjectItem^.Name:=JSONItemObjectProperty.Key;
       ObjectItem^.JSONItemObject:=JSONItemObject;
       ObjectItem^.Dependencies.Initialize;
       ObjectNameHashMap.Add(ObjectItem^.Name,OtherIndex);
      end;
     end;
     ObjectItemDynamicArray.Finish;
     for Index:=0 to ObjectItemDynamicArray.Count-1 do begin
      ObjectItem:=@ObjectItemDynamicArray.Items[Index];
      JSONItemObject:=ObjectItem^.JSONItemObject;
      ParentObjectNames.Clear;
      ObjectName:=TPasJSON.GetString(JSONItemObject.Properties['parent'],'');
      if length(ObjectName)>0 then begin
       ParentObjectNames.Add(ObjectName);
      end;
      ParentJSONItem:=JSONItemObject.Properties['parents'];
      if assigned(ParentJSONItem) and (ParentJSONItem is TPasJSONItemArray) then begin
       for OtherIndex:=0 to TPasJSONItemArray(ParentJSONItem).Count-1 do begin
        ObjectName:=TPasJSON.GetString(TPasJSONItemArray(ParentJSONItem).Items[OtherIndex],'');
        if length(ObjectName)>0 then begin
         ParentObjectNames.Add(ObjectName);
        end;
       end;
      end;
      ParentObjectNames.Finish;
      JSONItemObject.Delete(JSONItemObject.Indices['parent']);
      JSONItemObject.Delete(JSONItemObject.Indices['parents']);
      for OtherIndex:=0 to ParentObjectNames.Count-1 do begin
       ObjectName:=ParentObjectNames.Items[OtherIndex];
       if ObjectNameHashMap.TryGet(ObjectName,YetOtherIndex) then begin
        if (Index<>YetOtherIndex) and
           (ObjectItemDynamicArray.Items[YetOtherIndex].Name=ObjectName) then begin
         ObjectItem^.Dependencies.Add(YetOtherIndex);
        end;
       end;
      end;
     end;
    finally
     ParentObjectNames.Finalize;
    end;
   finally
    FreeAndNil(ObjectNameHashMap);
   end;
   for Index:=0 to ObjectItemDynamicArray.Count-1 do begin
    ObjectItemDynamicArray.Items[Index].Dependencies.Finish;
   end;
   TopologicalSort:=TpvTopologicalSort.Create;
   try
    for Index:=0 to ObjectItemDynamicArray.Count-1 do begin
     ObjectItem:=@ObjectItemDynamicArray.Items[Index];
     TopologicalSort.Add(Index,ObjectItem^.Dependencies.Items);
    end;
    TopologicalSort.Solve(true);
    for Index:=0 to TopologicalSort.Count-1 do begin
     ObjectItem:=@ObjectItemDynamicArray.Items[TopologicalSort.SortedKeys[Index]];
     if ObjectItem^.Dependencies.Count>0 then begin
      TemporaryJSONItemObject:=TPasJSONItemObject.Create;
      try
       for OtherIndex:=0 to ObjectItem^.Dependencies.Count-1 do begin
        OtherObjectItem:=@ObjectItemDynamicArray.Items[ObjectItem^.Dependencies.Items[OtherIndex]];
        TemporaryJSONItemObject.Merge(OtherObjectItem^.JSONItemObject,[TPasJSONMergeFlag.ForceObjectPropertyValueDestinationType]);
       end;
       TemporaryJSONItemObject.Merge(ObjectItem^.JSONItemObject,[TPasJSONMergeFlag.ForceObjectPropertyValueDestinationType]);
       ObjectItem^.JSONItemObject.Clear;
       ObjectItem^.JSONItemObject.Merge(TemporaryJSONItemObject,[TPasJSONMergeFlag.ForceObjectPropertyValueDestinationType]);
      finally
       FreeAndNil(TemporaryJSONItemObject);
      end;
     end;
    end;
   finally
    FreeAndNil(TopologicalSort);
   end;
  finally
   ObjectItemDynamicArray.Finalize;
  end;
 end;
end;

end.
