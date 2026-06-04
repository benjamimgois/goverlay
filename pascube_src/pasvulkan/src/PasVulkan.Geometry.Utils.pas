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
unit PasVulkan.Geometry.Utils;
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

// Fixes wrap around UVs to ensure that the UVs are continuous in the range [0,1] as much as possible 
procedure FixWrapAroundUVs(var aVertices:TpvVector3DynamicArray;var aTexCoords:TpvVector2DynamicArray;var aIndices:TpvUInt32DynamicArray);

implementation

procedure FixWrapAroundUVs(var aVertices:TpvVector3DynamicArray;var aTexCoords:TpvVector2DynamicArray;var aIndices:TpvUInt32DynamicArray);
var OriginalCountVertices,OriginalCountIndices,CountVertices,CountIndices,Index,VertexIndex:TpvSizeInt;
    VertexIndices:array[0..2] of TpvSizeInt;
    Vertices:array[0..2] of TpvVector3;
    UVs:array[0..2] of TpvVector2;
    UVOffsets:array[0..2] of TpvVector2;
    MustDuplicateVertices:array[0..2] of boolean;
    CanAlignXToZero,CanAlignYToZero:boolean;
    MaxOffset:TpvFloat;
begin

 OriginalCountVertices:=length(aVertices);

 OriginalCountIndices:=length(aIndices);

 CountVertices:=OriginalCountVertices;

 CountIndices:=OriginalCountIndices;
 try

  Index:=0;
  while (Index+2)<OriginalCountIndices do begin

   VertexIndices[0]:=aIndices[Index+0];
   VertexIndices[1]:=aIndices[Index+1];
   VertexIndices[2]:=aIndices[Index+2];

   Vertices[0]:=aVertices[VertexIndices[0]];
   Vertices[1]:=aVertices[VertexIndices[1]];
   Vertices[2]:=aVertices[VertexIndices[2]];

   UVs[0]:=aTexCoords[VertexIndices[0]];
   UVs[1]:=aTexCoords[VertexIndices[1]];
   UVs[2]:=aTexCoords[VertexIndices[2]];

   // Check UVs for wrapping arounds and fix them by duplicating vertices
   if (abs(UVs[0].x-UVs[1].x)>0.5) or
      (abs(UVs[0].x-UVs[2].x)>0.5) or
      (abs(UVs[1].x-UVs[2].x)>0.5) or
      (abs(UVs[0].y-UVs[1].y)>0.5) or
      (abs(UVs[0].y-UVs[2].y)>0.5) or
      (abs(UVs[1].y-UVs[2].y)>0.5) then begin

    MustDuplicateVertices[0]:=false;
    MustDuplicateVertices[1]:=false;
    MustDuplicateVertices[2]:=false;

    UVOffsets[0]:=TpvVector2.InlineableCreate(0.0,0.0);
    UVOffsets[1]:=TpvVector2.InlineableCreate(0.0,0.0);
    UVOffsets[2]:=TpvVector2.InlineableCreate(0.0,0.0);

    if abs((UVs[0].x+UVOffsets[0].x)-(UVs[1].x+UVOffsets[1].x))>0.5 then begin
     if (UVs[0].x+UVOffsets[0].x)<(UVs[1].x+UVOffsets[1].x) then begin
      MustDuplicateVertices[0]:=true;
      UVOffsets[0].x:=UVOffsets[0].x+1.0;
     end else begin
      MustDuplicateVertices[1]:=true;
      UVOffsets[1].x:=UVOffsets[1].x+1.0;
     end;
    end;

    if abs((UVs[0].x+UVOffsets[0].x)-(UVs[2].x+UVOffsets[2].x))>0.5 then begin
     if (UVs[0].x+UVOffsets[0].x)<(UVs[2].x+UVOffsets[2].x) then begin
      MustDuplicateVertices[0]:=true;
      UVOffsets[0].x:=UVOffsets[0].x+1.0;
     end else begin
      MustDuplicateVertices[2]:=true;
      UVOffsets[2].x:=UVOffsets[2].x+1.0;
     end;
    end;

    if abs((UVs[1].x+UVOffsets[1].x)-(UVs[2].x+UVOffsets[2].x))>0.5 then begin
     if (UVs[1].x+UVOffsets[1].x)<(UVs[2].x+UVOffsets[2].x) then begin
      MustDuplicateVertices[1]:=true;
      UVOffsets[1].x:=UVOffsets[1].x+1.0;
     end else begin
      MustDuplicateVertices[2]:=true;
      UVOffsets[2].x:=UVOffsets[2].x+1.0;
     end;
    end;

    if abs((UVs[0].y+UVOffsets[0].y)-(UVs[1].y+UVOffsets[1].y))>0.5 then begin
     if (UVs[0].y+UVOffsets[0].y)<(UVs[1].y+UVOffsets[1].y) then begin
      MustDuplicateVertices[0]:=true;
      UVOffsets[0].y:=UVOffsets[0].y+1.0;
     end else begin
      MustDuplicateVertices[1]:=true;
      UVOffsets[1].y:=UVOffsets[1].y+1.0;
     end;
    end;

    if abs((UVs[0].y+UVOffsets[0].y)-(UVs[2].y+UVOffsets[2].y))>0.5 then begin
     if (UVs[0].y+UVOffsets[0].y)<(UVs[2].y+UVOffsets[2].y) then begin
      MustDuplicateVertices[0]:=true;
      UVOffsets[0].y:=UVOffsets[0].y+1.0;
     end else begin
      MustDuplicateVertices[2]:=true;
      UVOffsets[2].y:=UVOffsets[2].y+1.0;
     end;
    end;

    if abs((UVs[1].y+UVOffsets[1].y)-(UVs[2].y+UVOffsets[2].y))>0.5 then begin
     if (UVs[1].y+UVOffsets[1].y)<(UVs[2].y+UVOffsets[2].y) then begin
      MustDuplicateVertices[1]:=true;
      UVOffsets[1].y:=UVOffsets[1].y+1.0;
     end else begin
      MustDuplicateVertices[2]:=true;
      UVOffsets[2].y:=UVOffsets[2].y+1.0;
     end;
    end;

    if MustDuplicateVertices[0] or MustDuplicateVertices[1] or MustDuplicateVertices[2] then begin

     // Check if we can align to zero
     CanAlignXToZero:=((UVs[0].x+UVOffsets[0].x)>=1.0) and ((UVs[1].x+UVOffsets[1].x)>=1.0) and ((UVs[2].x+UVOffsets[2].x)>=1.0);
     CanAlignYToZero:=((UVs[0].y+UVOffsets[0].y)>=1.0) and ((UVs[1].y+UVOffsets[1].y)>=1.0) and ((UVs[2].y+UVOffsets[2].y)>=1.0);

     if CanAlignXToZero or CanAlignYToZero then begin

      // Try to find the common maximum offset for all UVs first, if possible, otherwise just subtract 1.0 as fallback, for to
      // ensure that the UVs are in the range [0.0,1.0] after the offsets have been applied as much as possible. Anyway, when
      // the texture sampler is set to repeat, the UVs will be wrapped around anyway, so it doesn't matter if the UVs are in the
      // range [0.0,1.0] or not, but it's better for other aspects with working with the UVs, like for example for post processing
      // and post editing of the UVs or even for texture coordinate quantization, to have them in the range [0.0,1.0] as much as
      // possible.

      if CanAlignXToZero then begin
       MaxOffset:=Floor(Max(Max(UVs[0].x+UVOffsets[0].x,UVs[1].x+UVOffsets[1].x),UVs[2].x+UVOffsets[2].x));
       if ((UVs[0].x+UVOffsets[0].x)>=MaxOffset) and ((UVs[1].x+UVOffsets[1].x)>=MaxOffset) and ((UVs[2].x+UVOffsets[2].x)>=MaxOffset) then begin
        UVOffsets[0].x:=UVOffsets[0].x-MaxOffset;
        UVOffsets[1].x:=UVOffsets[1].x-MaxOffset;
        UVOffsets[2].x:=UVOffsets[2].x-MaxOffset;
       end else begin
        UVOffsets[0].x:=UVOffsets[0].x-1.0;
        UVOffsets[1].x:=UVOffsets[1].x-1.0;
        UVOffsets[2].x:=UVOffsets[2].x-1.0;
       end;
      end;

      if CanAlignYToZero then begin
       MaxOffset:=Floor(Max(Max(UVs[0].y+UVOffsets[0].y,UVs[1].y+UVOffsets[1].y),UVs[2].y+UVOffsets[2].y));
       if ((UVs[0].y+UVOffsets[0].y)>=MaxOffset) and ((UVs[1].y+UVOffsets[1].y)>=MaxOffset) and ((UVs[2].y+UVOffsets[2].y)>=MaxOffset) then begin
        UVOffsets[0].y:=UVOffsets[0].y-MaxOffset;
        UVOffsets[1].y:=UVOffsets[1].y-MaxOffset;
        UVOffsets[2].y:=UVOffsets[2].y-MaxOffset;
       end else begin
        UVOffsets[0].y:=UVOffsets[0].y-1.0;
        UVOffsets[1].y:=UVOffsets[1].y-1.0;
        UVOffsets[2].y:=UVOffsets[2].y-1.0;
       end;
      end;

      VertexIndices[0]:=CountVertices;
      inc(CountVertices);
      if length(aVertices)<CountVertices then begin
       SetLength(aVertices,CountVertices+((CountVertices+1) shr 1));
      end;
      if length(aTexCoords)<CountVertices then begin
       SetLength(aTexCoords,CountVertices+((CountVertices+1) shr 1));
      end;
      aVertices[VertexIndices[0]]:=Vertices[0];
      aTexCoords[VertexIndices[0]]:=UVs[0]+UVOffsets[0];

      VertexIndices[1]:=CountVertices;
      inc(CountVertices);
      if length(aVertices)<CountVertices then begin
       SetLength(aVertices,CountVertices+((CountVertices+1) shr 1));
      end;
      if length(aTexCoords)<CountVertices then begin
       SetLength(aTexCoords,CountVertices+((CountVertices+1) shr 1));
      end;
      aVertices[VertexIndices[1]]:=Vertices[1];
      aTexCoords[VertexIndices[1]]:=UVs[1]+UVOffsets[1];

      VertexIndices[2]:=CountVertices;
      inc(CountVertices);
      if length(aVertices)<CountVertices then begin
       SetLength(aVertices,CountVertices+((CountVertices+1) shr 1));
      end;
      if length(aTexCoords)<CountVertices then begin
       SetLength(aTexCoords,CountVertices+((CountVertices+1) shr 1));
      end;
      aVertices[VertexIndices[2]]:=Vertices[2];
      aTexCoords[VertexIndices[2]]:=UVs[2]+UVOffsets[2];

     end else begin

      if MustDuplicateVertices[0] then begin
       VertexIndices[0]:=CountVertices;
       inc(CountVertices);
       if length(aVertices)<CountVertices then begin
        SetLength(aVertices,CountVertices+((CountVertices+1) shr 1));
       end;
       if length(aTexCoords)<CountVertices then begin
        SetLength(aTexCoords,CountVertices+((CountVertices+1) shr 1));
       end;
       aVertices[VertexIndices[0]]:=Vertices[0];
       aTexCoords[VertexIndices[0]]:=UVs[0]+UVOffsets[0];
      end;

      if MustDuplicateVertices[1] then begin
       VertexIndices[1]:=CountVertices;
       inc(CountVertices);
       if length(aVertices)<CountVertices then begin
        SetLength(aVertices,CountVertices+((CountVertices+1) shr 1));
       end;
       if length(aTexCoords)<CountVertices then begin
        SetLength(aTexCoords,CountVertices+((CountVertices+1) shr 1));
       end;
       aVertices[VertexIndices[1]]:=Vertices[1];
       aTexCoords[VertexIndices[1]]:=UVs[1]+UVOffsets[1];
      end;

      if MustDuplicateVertices[2] then begin
       VertexIndices[2]:=CountVertices;
       inc(CountVertices);
       if length(aVertices)<CountVertices then begin
        SetLength(aVertices,CountVertices+((CountVertices+1) shr 1));
       end;
       if length(aTexCoords)<CountVertices then begin
        SetLength(aTexCoords,CountVertices+((CountVertices+1) shr 1));
       end;
       aVertices[VertexIndices[2]]:=Vertices[2];
       aTexCoords[VertexIndices[2]]:=UVs[2]+UVOffsets[2];
      end;

     end;

     aIndices[Index+0]:=VertexIndices[0];
     aIndices[Index+1]:=VertexIndices[1];
     aIndices[Index+2]:=VertexIndices[2];

    end;

   end;

   inc(Index,3);

  end;

 finally

  SetLength(aVertices,CountVertices);
  SetLength(aTexCoords,CountVertices);
  SetLength(aIndices,CountIndices);

 end; 

end;

end.
