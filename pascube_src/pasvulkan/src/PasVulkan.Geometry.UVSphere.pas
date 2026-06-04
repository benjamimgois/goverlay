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
unit PasVulkan.Geometry.UVSphere;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

{$scopedenums on}

interface

uses Classes,SysUtils,Math,PasMP,PasDblStrUtils,PasVulkan.Types,PasVulkan.Math,PasVulkan.Collections,PasVulkan.Utils;

procedure GenerateUVSphere(const aCountStacks,aCountSlices:TpvSizeInt;out aVertices:TpvVector3DynamicArray;out aTexCoords:TpvVector2DynamicArray;out aIndices:TpvUInt32DynamicArray;const aRadius:TpvFloat=1.0);

implementation

procedure GenerateUVSphere(const aCountStacks,aCountSlices:TpvSizeInt;out aVertices:TpvVector3DynamicArray;out aTexCoords:TpvVector2DynamicArray;out aIndices:TpvUInt32DynamicArray;const aRadius:TpvFloat=1.0);
var Index:TpvSizeInt;
    StackIndex,SliceIndex:TpvSizeInt;
    VertexIndex:TpvSizeInt;
    Vertex:PpvVector3;
    VertexIndex0,VertexIndex1,VertexIndex2,VertexIndex3:TpvUInt32;
    SinPhi,CosPhi,SinTheta,CosTheta:TpvFloat;
begin

 SetLength(aVertices,(aCountStacks+1)*(aCountSlices+1));
 SetLength(aTexCoords,(aCountStacks+1)*(aCountSlices+1));
 SetLength(aIndices,aCountStacks*aCountSlices*6);

 VertexIndex:=0;

 for StackIndex:=0 to aCountStacks do begin
  SinCos(((StackIndex/TpvFloat(aCountStacks))-0.5)*PI,SinPhi,CosPhi);
  for SliceIndex:=0 to aCountSlices do begin
   SinCos((SliceIndex/TpvFloat(aCountSlices))*TwoPI,SinTheta,CosTheta);
   aVertices[VertexIndex]:=TpvVector3.InlineableCreate(CosPhi*SinTheta,SinPhi,CosPhi*CosTheta)*aRadius;
   aTexCoords[VertexIndex]:=TpvVector2.InlineableCreate(SliceIndex/TpvFloat(aCountSlices),StackIndex/TpvFloat(aCountStacks));
   inc(VertexIndex);
  end;
 end;

 Index:=0;

 for StackIndex:=0 to aCountStacks-1 do begin

  for SliceIndex:=0 to aCountSlices-1 do begin

   VertexIndex0:=TpvUInt32(((StackIndex+0)*(aCountSlices+1))+(SliceIndex+0));
   VertexIndex1:=TpvUInt32(((StackIndex+1)*(aCountSlices+1))+(SliceIndex+0));
   VertexIndex2:=TpvUInt32(((StackIndex+1)*(aCountSlices+1))+(SliceIndex+1));
   VertexIndex3:=TpvUInt32(((StackIndex+0)*(aCountSlices+1))+(SliceIndex+1));

   // Check winding order
   if (aVertices[VertexIndex0].Dot(aVertices[VertexIndex2].Cross(aVertices[VertexIndex1]))<0.0) and 
      (aVertices[VertexIndex0].Dot(aVertices[VertexIndex3].Cross(aVertices[VertexIndex2]))<0.0) then begin

    aIndices[Index+0]:=VertexIndex0;
    aIndices[Index+1]:=VertexIndex1;
    aIndices[Index+2]:=VertexIndex2;

    aIndices[Index+3]:=VertexIndex0;
    aIndices[Index+4]:=VertexIndex2;
    aIndices[Index+5]:=VertexIndex3;

   end else begin

    aIndices[Index+0]:=VertexIndex0;
    aIndices[Index+1]:=VertexIndex2;
    aIndices[Index+2]:=VertexIndex1;

    aIndices[Index+3]:=VertexIndex0;
    aIndices[Index+4]:=VertexIndex3;
    aIndices[Index+5]:=VertexIndex2;
   
   end;

   inc(Index,6);

  end;
  
 end;

end;

end.
