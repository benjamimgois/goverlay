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
unit PasVulkan.Geometry.IcoSphere;
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

// Generate an icosphere iteratively with a given tessellation resolution per triangle 
procedure IterativelyGenerateIcoSphere(const aResolution:TpvSizeInt;out aVertices:TpvVector3DynamicArray;out aTexCoords:TpvVector2DynamicArray;out aIndices:TpvUInt32DynamicArray;const aRadius:TpvFloat=1.0);

// Generate an icosphere recursively with a given minimum count of vertices instead of a recursion depth level for somewhat better control.
// However negative aCountMinimumVertices values are used as forced recursion depth levels, when it is really explicitly needed.
procedure RecursivelyGenerateIcoSphere(const aCountMinimumVertices:TpvSizeInt;out aVertices:TpvVector3DynamicArray;out aTexCoords:TpvVector2DynamicArray;out aIndices:TpvUInt32DynamicArray;const aRadius:TpvFloat=1.0);

implementation

uses PasVulkan.Geometry.Utils;

procedure GenerateTexCoords(const aVertices:TpvVector3DynamicArray;out aTexCoords:TpvVector2DynamicArray;const aIndices:TpvUInt32DynamicArray;const aFixUVs:Boolean);
var Index,Count:TpvSizeInt;
    ta,tb,tc:PpvVector2;
begin
 
 // Set length of texture coordinates array
 SetLength(aTexCoords,length(aVertices));

 // Calculate texture coordinates
 for Index:=0 to length(aVertices)-1 do begin
  aTexCoords[Index]:=TpvVector2.Create(0.5+ArcTan2(aVertices[Index].z,aVertices[Index].x)/TwoPI,0.5-ArcSin(aVertices[Index].y)/PI);
 end;

 // Fix UVs
 if aFixUVs then begin

  Index:=0;
  Count:=length(aIndices);
  while (Index+2)<Count do begin

   ta:=@aTexCoords[aIndices[Index+0]];
   tb:=@aTexCoords[aIndices[Index+1]];
   tc:=@aTexCoords[aIndices[Index+2]];

   if ((tb^.x-ta^.x)>=0.5) and not SameValue(ta^.y,1.0) then begin
    tb^.x:=tb^.x-1.0;
   end;

   if (tc^.x-tb^.x)>0.5 then begin
    tc^.x:=tc^.x-1.0;
   end;

   if (ta^.x>0.5) and ((ta^.x-tc^.x)>0.5) or (SameValue(ta^.x,1.0) and SameValue(tc^.y,0.0)) then begin
    ta^.x:=ta^.x-1.0;
   end;

   if (tb^.x>0.5) and ((tb^.x-ta^.x)>0.5) then begin
    tb^.x:=tb^.x-1.0;
   end;

   if SameValue(ta^.y,0.0) or SameValue(ta^.y,1.0) then begin
    ta^.x:=(tb^.x+tc^.x)*0.5;
   end;

   if SameValue(tb^.y,0.0) or SameValue(tb^.y,1.0) then begin
    tb^.x:=(ta^.x+tc^.x)*0.5;
   end;

   if SameValue(tc^.y,0.0) or SameValue(tc^.y,1.0) then begin
    tc^.x:=(ta^.x+tb^.x)*0.5;
   end;

   inc(Index,3);
  end;

 end;

end;

procedure IterativelyGenerateIcoSphere(const aResolution:TpvSizeInt;out aVertices:TpvVector3DynamicArray;out aTexCoords:TpvVector2DynamicArray;out aIndices:TpvUInt32DynamicArray;const aRadius:TpvFloat);
type TVertexHashMap=TpvHashMap<TpvVector3,TpvUInt32>; // $ffffffff = invalid index
const GoldenRatio=1.61803398874989485; // (1.0 + sqrt(5.0)) / 2.0 (golden ratio)
      IcosahedronLength=1.902113032590307; // sqrt(sqr(1) + sqr(GoldenRatio))
      IcosahedronNorm=0.5257311121191336; // 1.0 / IcosahedronLength
      IcosahedronNormGoldenRatio=0.85065080835204; // GoldenRatio / IcosahedronLength
      FaceVertices:array[0..11] of TpvVector3=(
       (x:0.0;y:IcosahedronNorm;z:IcosahedronNormGoldenRatio),
       (x:0.0;y:-IcosahedronNorm;z:IcosahedronNormGoldenRatio),
       (x:IcosahedronNorm;y:IcosahedronNormGoldenRatio;z:0.0),
       (x:-IcosahedronNorm;y:IcosahedronNormGoldenRatio;z:0.0),
       (x:IcosahedronNormGoldenRatio;y:0.0;z:IcosahedronNorm),
       (x:-IcosahedronNormGoldenRatio;y:0.0;z:IcosahedronNorm),
       (x:0.0;y:-IcosahedronNorm;z:-IcosahedronNormGoldenRatio),
       (x:0.0;y:IcosahedronNorm;z:-IcosahedronNormGoldenRatio),
       (x:-IcosahedronNorm;y:-IcosahedronNormGoldenRatio;z:0.0),
       (x:IcosahedronNorm;y:-IcosahedronNormGoldenRatio;z:0.0),
       (x:-IcosahedronNormGoldenRatio;y:0.0;z:-IcosahedronNorm),
       (x:IcosahedronNormGoldenRatio;y:0.0;z:-IcosahedronNorm)
      );
      FaceIndices:array[0..19,0..2] of TpvUInt32=(
       (0,5,1),(0,3,5),(0,2,3),(0,4,2),(0,1,4),
       (1,5,8),(5,3,10),(3,2,7),(2,4,11),(4,1,9),
       (7,11,6),(11,9,6),(9,8,6),(8,10,6),(10,7,6),
       (2,11,7),(4,9,11),(1,8,9),(5,10,8),(3,7,10)
      );
var VertexHashMap:TVertexHashMap;
    FaceIndex,Index,VertexIndex,CountVertices,CountIndices:TpvSizeInt; 
    IndexValue:TpvUInt32;
    TessellationFaceVertices:array[0..2] of TpvVector3;
    TessellatedVertices:array[0..2] of TpvVector3;
begin

 // Generate icosahedron and tessellate it iteratively without recursion
 begin

  CountVertices:=0;
  try

   CountIndices:=0;
   try

    // Peeallocate possible approximate memory for vertices and indices in advance, so we don't need to reallocate memory during the tessellation process in the best case 
    SetLength(aVertices,20*(aResolution+1)*(aResolution+1)*3);
    SetLength(aIndices,20*(aResolution+1)*(aResolution+1)*3);

    VertexHashMap:=TVertexHashMap.Create(TpvUInt32($ffffffff)); // $ffffffff = invalid index as default value
    try

     for FaceIndex:=0 to 19 do begin

      TessellationFaceVertices[0]:=FaceVertices[FaceIndices[FaceIndex,2]];
      TessellationFaceVertices[1]:=FaceVertices[FaceIndices[FaceIndex,1]];
      TessellationFaceVertices[2]:=FaceVertices[FaceIndices[FaceIndex,0]];

      for Index:=0 to (aResolution*aResolution)-1 do begin

       TessellateTriangle(Index,aResolution,@TessellationFaceVertices[0],@TessellatedVertices[0]);

       for VertexIndex:=0 to 2 do begin

        // Try to find vertex in hash map
        IndexValue:=VertexHashMap[TessellatedVertices[VertexIndex]];
        
        // If vertex is not found in hash map, add it to the vertices list and hash map
        if IndexValue=TpvUInt32($ffffffff) then begin

         // Create new vertex, when it is not found in hash map
         IndexValue:=CountVertices;
         if length(aVertices)<=CountVertices then begin
          SetLength(aVertices,(CountVertices+1)+((CountVertices+1) shr 1));
         end;
         aVertices[CountVertices]:=TessellatedVertices[VertexIndex];
         inc(CountVertices);

         // Add vertex to hash map
         VertexHashMap.Add(TessellatedVertices[VertexIndex],IndexValue);

        end;

        // Add index to indices list
        if length(aIndices)<=CountIndices then begin
         SetLength(aIndices,(CountIndices+1)+((CountIndices+1) shr 1));
        end;
        aIndices[CountIndices]:=IndexValue;
        inc(CountIndices);

       end;     

      end;

     end;   

     // Generate texture coordinates
     GenerateTexCoords(aVertices,aTexCoords,aIndices,false);

     // Fix wrap around UVs
     FixWrapAroundUVs(aVertices,aTexCoords,aIndices);

    finally
     FreeAndNil(VertexHashMap);
    end;

   finally
    SetLength(aIndices,CountIndices); // Shrink to fit to the actual count of indices
   end;

  finally
   SetLength(aVertices,CountVertices); // Shrink to fit to the actual count of vertices
  end;  

 end;  

 // Normalize vertices and scale them by radius
 begin
  for Index:=0 to CountVertices-1 do begin
   aVertices[Index]:=aVertices[Index].Normalize*aRadius;
  end; 
 end; 

end;

type TVector3Array=TpvDynamicArray<TpvVector3>;
     TIndexArray=TpvDynamicArray<TpvUInt32>;

procedure Subdivide(var aVertices:TVector3Array;var aIndices:TIndexArray;const aSubdivisions:TpvSizeInt=2);
type TVectorHashMap=TpvHashMap<TpvVector3,TpvSizeInt>;
var SubdivisionIndex,IndexIndex,VertexIndex:TpvSizeInt;
    NewIndices:TIndexArray;
    v0,v1,v2,va,vb,vc:TpvVector3;
    i0,i1,i2,ia,ib,ic:TpvUInt32;
    VectorHashMap:TVectorHashMap;
begin

 NewIndices.Initialize;
 try

  VectorHashMap:=TVectorHashMap.Create(-1);
  try

   for VertexIndex:=0 to aVertices.Count-1 do begin
    VectorHashMap.Add(aVertices.Items[VertexIndex],VertexIndex);
   end;

   for SubdivisionIndex:=1 to aSubdivisions do begin

    NewIndices.Count:=0;

    IndexIndex:=0;
    while (IndexIndex+2)<aIndices.Count do begin

     i0:=aIndices.Items[IndexIndex+0];
     i1:=aIndices.Items[IndexIndex+1];
     i2:=aIndices.Items[IndexIndex+2];

     v0:=aVertices.Items[i0];
     v1:=aVertices.Items[i1];
     v2:=aVertices.Items[i2];

     va:=Mix(v0,v1,0.5);
     vb:=Mix(v1,v2,0.5);
     vc:=Mix(v2,v0,0.5);

     VertexIndex:=VectorHashMap[va];
     if VertexIndex<0 then begin
      VertexIndex:=aVertices.Add(va);
      VectorHashMap.Add(va,VertexIndex);
     end;
     ia:=VertexIndex;

     VertexIndex:=VectorHashMap[vb];
     if VertexIndex<0 then begin
      VertexIndex:=aVertices.Add(vb);
      VectorHashMap.Add(vb,VertexIndex);
     end;
     ib:=VertexIndex;

     VertexIndex:=VectorHashMap[vc];
     if VertexIndex<0 then begin
      VertexIndex:=aVertices.Add(vc);
      VectorHashMap.Add(vc,VertexIndex);
     end;
     ic:=VertexIndex;

     NewIndices.Add([i0,ia,ic]);
     NewIndices.Add([i1,ib,ia]);
     NewIndices.Add([i2,ic,ib]);
     NewIndices.Add([ia,ib,ic]);

     inc(IndexIndex,3);

    end;

    aIndices.Assign(NewIndices);

   end;

  finally
   FreeAndNil(VectorHashMap);
  end;

 finally
  NewIndices.Finalize;
 end;

end;

procedure NormalizeVertices(var aVertices:TVector3Array);
var VertexIndex:TpvSizeInt;
begin
 for VertexIndex:=0 to aVertices.Count-1 do begin
  aVertices.Items[VertexIndex]:=aVertices.Items[VertexIndex].Normalize;
 end;
end;

procedure CreateIcosahedronSphere(var aVertices:TVector3Array;var aIndices:TIndexArray;const aCountMinimumVertices:TpvSizeInt=4096);
const GoldenRatio=1.61803398874989485; // (1.0+sqrt(5.0))/2.0 (golden ratio)
      IcosahedronLength=1.902113032590307; // sqrt(sqr(1)+sqr(GoldenRatio))
      IcosahedronNorm=0.5257311121191336; // 1.0 / IcosahedronLength
      IcosahedronNormGoldenRatio=0.85065080835204; // GoldenRatio / IcosahedronLength
      IcosaheronVertices:array[0..11] of TpvVector3=
       (
        (x:0.0;y:IcosahedronNorm;z:IcosahedronNormGoldenRatio),
        (x:0.0;y:-IcosahedronNorm;z:IcosahedronNormGoldenRatio),
        (x:IcosahedronNorm;y:IcosahedronNormGoldenRatio;z:0.0),
        (x:-IcosahedronNorm;y:IcosahedronNormGoldenRatio;z:0.0),
        (x:IcosahedronNormGoldenRatio;y:0.0;z:IcosahedronNorm),
        (x:-IcosahedronNormGoldenRatio;y:0.0;z:IcosahedronNorm),
        (x:0.0;y:-IcosahedronNorm;z:-IcosahedronNormGoldenRatio),
        (x:0.0;y:IcosahedronNorm;z:-IcosahedronNormGoldenRatio),
        (x:-IcosahedronNorm;y:-IcosahedronNormGoldenRatio;z:0.0),
        (x:IcosahedronNorm;y:-IcosahedronNormGoldenRatio;z:0.0),
        (x:-IcosahedronNormGoldenRatio;y:0.0;z:-IcosahedronNorm),
        (x:IcosahedronNormGoldenRatio;y:0.0;z:-IcosahedronNorm)
       );
      IcosahedronIndices:array[0..(20*3)-1] of TpvUInt32=
       (
        0,5,1,0,3,5,0,2,3,0,4,2,0,1,4,
        1,5,8,5,3,10,3,2,7,2,4,11,4,1,9,
        7,11,6,11,9,6,9,8,6,8,10,6,10,7,6,
        2,11,7,4,9,11,1,8,9,5,10,8,3,7,10
       );
var SubdivisionLevel,Count:TpvSizeInt;
begin

 if aCountMinimumVertices>=0 then begin
  Count:=12;
  SubdivisionLevel:=0;
  while Count<aCountMinimumVertices do begin
   Count:=12+((10*((2 shl SubdivisionLevel)+1))*((2 shl SubdivisionLevel)-1));
   inc(SubdivisionLevel);
  end;
 end else begin
  SubdivisionLevel:=-aCountMinimumVertices; // Use negative values as subdivision levels
 end;

 aVertices.Assign(IcosaheronVertices);

 aIndices.Assign(IcosahedronIndices);

 Subdivide(aVertices,aIndices,SubdivisionLevel);

 NormalizeVertices(aVertices);

end;                                                                              

procedure RecursivelyGenerateIcoSphere(const aCountMinimumVertices:TpvSizeInt;out aVertices:TpvVector3DynamicArray;out aTexCoords:TpvVector2DynamicArray;out aIndices:TpvUInt32DynamicArray;const aRadius:TpvFloat=1.0);
var Index:TpvSizeInt;
    Vertices:TVector3Array;
    Indices:TIndexArray;
begin

 Vertices.Initialize;
 try

  Indices.Initialize;
  try

   // Create icosahedron sphere
   CreateIcosahedronSphere(Vertices,Indices,aCountMinimumVertices);

   // Normalize vertices and scale them by radius 
   for Index:=0 to Vertices.Count-1 do begin
    Vertices.Items[Index]:=Vertices.Items[Index].Normalize*aRadius;
   end;

   // Copy vertices to output vertices array 
   SetLength(aVertices,Vertices.Count);
   Move(Vertices.Items[0],aVertices[0],Vertices.Count*SizeOf(TpvVector3));

   // Copy indices to output indices array
   SetLength(aIndices,Indices.Count);
   Move(Indices.Items[0],aIndices[0],Indices.Count*SizeOf(TpvUInt32));

   // Generate texture coordinates
   GenerateTexCoords(aVertices,aTexCoords,aIndices,false);

   // Fix wrap around UVs
   FixWrapAroundUVs(aVertices,aTexCoords,aIndices);

  finally
   Indices.Finalize;
  end;

 finally
  Vertices.Finalize;
 end;

end;

end.
