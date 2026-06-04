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
unit PasVulkan.Scene3D.Tipsify;
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
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Collections;

procedure TipsifyIndexBuffer(const aIndices:Pointer;const aCountIndices,aCountVertices,aCacheSize:TpvSizeInt;const aOptimizedIndices:Pointer;out aCountOptimizedIndices:TpvSizeInt);

implementation

// Based on "Fast Triangle Reordering for Vertex Locality and Reduced Overdraw" by Sander et al. 

procedure TipsifyIndexBuffer(const aIndices:Pointer;const aCountIndices,aCountVertices,aCacheSize:TpvSizeInt;const aOptimizedIndices:Pointer;out aCountOptimizedIndices:TpvSizeInt);
type TBooleanDynamicArray=TpvDynamicArray<Boolean>;
     TSizeIntDynamicArray=TpvDynamicArray<TpvSizeInt>;
     TSizeIntQueue=TpvDynamicQueue<TpvSizeInt>;
var Index,Triangle,CurrentVertex,TimeStamp,Cursor,TriangleOffset,
    CountTriangles,a,b,c,NextVertex,HighestPriority,Priority,
    VertexIndex:TpvSizeInt;
    TrianglesPerVertex:TSizeIntDynamicArray;
    IndexBufferOffset:TSizeIntDynamicArray;
    TriangleData:TSizeIntDynamicArray;
    LiveTriCount:TSizeIntDynamicArray;
    CacheTimeStamps:TSizeIntDynamicArray;
    DeadEndStack:TSizeIntQueue;
    OneRing:TSizeIntDynamicArray;
    EmittedTriangles:TBooleanDynamicArray;
begin

 aCountOptimizedIndices:=0;

 TrianglesPerVertex.Initialize;
 try

  IndexBufferOffset.Initialize;
  try

   TriangleData.Initialize;
   try

    // Count how often a vertex is used in the index buffer
    TrianglesPerVertex.Resize(aCountVertices);
    FillChar(TrianglesPerVertex.Items[0],TrianglesPerVertex.Count*SizeOf(TpvUInt32),#0);
    for Index:=0 to aCountIndices-1 do begin
     inc(TrianglesPerVertex.Items[PpvUInt32Array(aIndices)^[Index]]);
    end;

	   // Calculate the offsets for to need to look up into the index buffer for a given triangle
    TriangleOffset:=0;
    IndexBufferOffset.Resize(aCountVertices);
    FillChar(IndexBufferOffset.Items[0],IndexBufferOffset.Count*SizeOf(TpvUInt32),#0);
    for Index:=0 to aCountVertices-1 do begin
     IndexBufferOffset.Items[Index]:=TriangleOffset;
     inc(TriangleOffset,TrianglesPerVertex.Items[Index]);
    end;

    // Build the triangle data
    CountTriangles:=aCountIndices div 3;
    TriangleData.Resize(TriangleOffset);
    for Index:=0 to CountTriangles-1 do begin

     a:=PpvUInt32Array(aIndices)^[(Index*3)+0];
     b:=PpvUInt32Array(aIndices)^[(Index*3)+1];
     c:=PpvUInt32Array(aIndices)^[(Index*3)+2];

     TriangleData.Items[IndexBufferOffset.Items[a]]:=Index;
     inc(IndexBufferOffset.Items[a]);

     TriangleData.Items[IndexBufferOffset.Items[b]]:=Index;
     inc(IndexBufferOffset.Items[b]);

     TriangleData.Items[IndexBufferOffset.Items[c]]:=Index;
     inc(IndexBufferOffset.Items[c]);

    end;

    LiveTriCount.Initialize;
    try

     LiveTriCount.Assign(TrianglesPerVertex);

     CacheTimeStamps.Initialize;
     try

      CacheTimeStamps.Resize(aCountVertices);
      FillChar(CacheTimeStamps.Items[0],CacheTimeStamps.Count*SizeOf(TpvUInt32),#0);

      DeadEndStack.Initialize;
      try

       EmittedTriangles.Initialize;
       try

        EmittedTriangles.Resize(aCountIndices div 3);
        FillChar(EmittedTriangles.Items[0],EmittedTriangles.Count*SizeOf(Boolean),#0);

        CurrentVertex:=0;
        TimeStamp:=aCacheSize+1;
        Cursor:=1;

        OneRing.Initialize;
        try

         while CurrentVertex>=0 do begin

          OneRing.Clear;

          for Index:=IndexBufferOffset.Items[CurrentVertex] to (IndexBufferOffset.Items[CurrentVertex]+TrianglesPerVertex.Items[CurrentVertex])-1 do begin

           Triangle:=TriangleData.Items[Index];

           if not EmittedTriangles.Items[Triangle] then begin

            a:=PpvUInt32Array(aIndices)^[(Triangle*3)+0];
            b:=PpvUInt32Array(aIndices)^[(Triangle*3)+1];
            c:=PpvUInt32Array(aIndices)^[(Triangle*3)+2];

            PpvUInt32Array(aOptimizedIndices)^[aCountOptimizedIndices+0]:=a;
            PpvUInt32Array(aOptimizedIndices)^[aCountOptimizedIndices+1]:=a;
            PpvUInt32Array(aOptimizedIndices)^[aCountOptimizedIndices+2]:=a;
            inc(aCountOptimizedIndices,3);

            DeadEndStack.Enqueue(a);
            DeadEndStack.Enqueue(b);
            DeadEndStack.Enqueue(c);

            OneRing.Add(a);
            OneRing.Add(b);
            OneRing.Add(c);

            dec(LiveTriCount.Items[a]);
            dec(LiveTriCount.Items[b]);
            dec(LiveTriCount.Items[c]);

            if (TpvSizeInt(TimeStamp)-TpvSizeInt(CacheTimeStamps.Items[a]))>TpvSizeInt(aCacheSize) then begin
             CacheTimeStamps.Items[a]:=TimeStamp;
             inc(TimeStamp);
            end;

            if (TpvSizeInt(TimeStamp)-TpvSizeInt(CacheTimeStamps.Items[b]))>TpvSizeInt(aCacheSize) then begin
             CacheTimeStamps.Items[b]:=TimeStamp;
             inc(TimeStamp);
            end;

            if (TpvSizeInt(TimeStamp)-TpvSizeInt(CacheTimeStamps.Items[c]))>TpvSizeInt(aCacheSize) then begin
             CacheTimeStamps.Items[c]:=TimeStamp;
             inc(TimeStamp);
            end;

            EmittedTriangles.Items[Triangle]:=true;

           end;

          end;

          // Get next vertex
          NextVertex:=-1;
          HighestPriority:=-1;
          for Index:=0 to OneRing.Count-1 do begin
           VertexIndex:=OneRing.Items[Index];
           if LiveTriCount.Items[VertexIndex]>0 then begin
            Priority:=0;
            if ((TimeStamp+(LiveTriCount.Items[VertexIndex]*2))-CacheTimeStamps.Items[VertexIndex])<=aCacheSize then begin
             Priority:=TimeStamp-CacheTimeStamps.Items[VertexIndex];
            end;
            if HighestPriority<Priority then begin
             HighestPriority:=Priority;
             NextVertex:=VertexIndex;
            end;
           end;
          end;

          if NextVertex<0 then begin

           // Skip dead end

           while DeadEndStack.Dequeue(VertexIndex) do begin
            if LiveTriCount.Items[VertexIndex]>0 then begin
             NextVertex:=VertexIndex;
             break;
            end;
           end;

           if NextVertex<0 then begin

            while Cursor<LiveTriCount.Count do begin
             if LiveTriCount.Items[Cursor]>0 then begin
              NextVertex:=Cursor;
              break;
             end else begin
              inc(Cursor);
             end;
            end;

           end;

          end;

          CurrentVertex:=NextVertex;

         end;

        finally
         OneRing.Finalize;
        end;

       finally
        EmittedTriangles.Finalize;
       end;

      finally
       DeadEndStack.Finalize;
      end;

     finally
      CacheTimeStamps.Finalize;
     end;

    finally
     LiveTriCount.Finalize;
    end;

   finally
    TriangleData.Finalize;
   end;

  finally
   IndexBufferOffset.Finalize;
  end;

 finally
  TrianglesPerVertex.Finalize;
 end;

end;

end.
