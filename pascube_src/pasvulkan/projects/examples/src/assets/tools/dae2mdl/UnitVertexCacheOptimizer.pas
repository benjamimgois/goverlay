unit UnitVertexCacheOptimizer;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$j+}

interface

uses SysUtils,Classes,Math;

type TVertexCacheOptimizerIndices=array of longint;

function OptimizeForVertexCache(Indices:TVertexCacheOptimizerIndices;CountTriangles,CountVertices:longint;var OutIndices,OutTriangles:TVertexCacheOptimizerIndices):boolean;

implementation

type PScoreType=^TScoreType;
     TScoreType=word;

     PAdjacencyType=^TAdjacencyType;
     TAdjacencyType=byte;

     PVertexIndexType=^TVertexIndexType;
     TVertexIndexType=longint;

     PCachePosType=^TCachePosType;
     TCachePosType=shortint;

     PTriangleIndexType=^TTriangleIndexType;
     TTriangleIndexType=longint;

     PArrayIndexType=^TArrayIndexType;
     TArrayIndexType=longint;

const VERTEX_CACHE_SIZE=8;
      CACHE_FUNCTION_LENGTH=32;

      SCORE_SCALING=7281;

      MAX_ADJACENCY=high(TAdjacencyType);

      CACHE_SCORE_TABLE_SIZE=32;
      VALENCE_SCORE_TABLE_SIZE=32;

      CACHE_DECAY_POWER=1.5;
      LAST_TRI_SCORE=0.75;
      VALENCE_BOOST_SCALE=2.0;
      VALENCE_BOOST_POWER=0.5;

var CachePositionScore:array[0..CACHE_SCORE_TABLE_SIZE-1] of TScoreType;
    ValenceScore:array[0..VALENCE_SCORE_TABLE_SIZE-1] of TScoreType;

procedure InitializeVertexCacheOptimizer;
const Scaler=1.0/(CACHE_FUNCTION_LENGTH-3);
var i:longint;
    Score,ValenceBoost:single;
begin
 for i:=0 to CACHE_SCORE_TABLE_SIZE-1 do begin
  Score:=0.0;
  if i<3 then begin
 	 // This vertex was used in the last triangle,
	 // so it has a fixed score, which ever of the three
	 // it's in. Otherwise, you can get very different
	 // answers depending on whether you add
	 // the triangle 1,2,3 or 3,1,2 - which is silly
	 Score:=LAST_TRI_SCORE;
	end else begin
	 Score:=power(1.0-((i-3)*Scaler),CACHE_DECAY_POWER);
  end;
  CachePositionScore[i]:=trunc(SCORE_SCALING*Score);
 end;
 ValenceScore[0]:=0;
 for i:=1 to VALENCE_SCORE_TABLE_SIZE-1 do begin
  // Bonus points for having a low number of tris still to
  // use the vert, so we get rid of lone verts quickly
	ValenceBoost:=power(i,-VALENCE_BOOST_POWER);
  Score:=VALENCE_BOOST_SCALE*ValenceBoost;
	ValenceScore[i]:=trunc(SCORE_SCALING*Score);
 end;
end;

function FindVertexScore(const NumActiveTris,CachePosition:longint):TScoreType;
begin
 result:=0;
 if NumActiveTris>0 then begin
  if CachePosition>=0 then begin
   inc(result,CachePositionScore[CachePosition]);
  end;
  if NumActiveTris<VALENCE_SCORE_TABLE_SIZE then begin
   inc(result,ValenceScore[NumActiveTris]);
  end;
 end;
end;

function OptimizeForVertexCache(Indices:TVertexCacheOptimizerIndices;CountTriangles,CountVertices:longint;var OutIndices,OutTriangles:TVertexCacheOptimizerIndices):boolean;
type TNumActiveTris=array of TAdjacencyType;
     TOffsets=array of TArrayIndexType;
     TLastScore=array of TScoreType;
     TCacheTag=array of TCachePosType;
     TTriangleAdded=array of longword;
     TTriangleScore=array of TScoreType;
     TTriangleIndices=array of TTriangleIndexType;
     TOutTriangles=array of TTriangleIndexType;
     TCache=array[0..(VERTEX_CACHE_SIZE+3)-1] of longint;
var i,j,k,v,t,Sum,BestTriangle,BestScore,OutPos,ScanPos,EndPos:longint;
    NewScore,Diff:TScoreType;
    NumActiveTris:TNumActiveTris;
    Offsets:TOffsets;
    LastScore:TLastScore;
    CacheTag:TCacheTag;
    TriangleAdded:TTriangleAdded;
    TriangleScore:TTriangleScore;
    TriangleIndices:TTriangleIndices;
    Cache:TCache;
begin
 result:=false;
 NumActiveTris:=nil;
 Offsets:=nil;
 LastScore:=nil;
 CacheTag:=nil;
 TriangleAdded:=nil;
 TriangleScore:=nil;
 TriangleIndices:=nil;
 OutIndices:=nil;
 OutTriangles:=nil;
 try

  // First scan over the vertex data, count the total number of
  // occurrances of each vertex
  SetLength(NumActiveTris,CountVertices);
  for i:=0 to CountVertices-1 do begin
   NumActiveTris[i]:=0;
  end;
  for i:=0 to (CountTriangles*3)-1 do begin
   if NumActiveTris[Indices[i]]=MAX_ADJACENCY then begin
    SetLength(NumActiveTris,0);
    exit;
   end;
   inc(NumActiveTris[Indices[i]]);
  end;

  // Allocate the rest of the arrays
  SetLength(Offsets,CountVertices);
  SetLength(LastScore,CountVertices);
  SetLength(CacheTag,CountVertices);

  for i:=0 to CountVertices-1 do begin
   Offsets[i]:=0;
   LastScore[i]:=0;
   CacheTag[i]:=0;
  end;

  SetLength(TriangleAdded,(CountTriangles+31) shr 5);
  for i:=0 to length(TriangleAdded)-1 do begin
   TriangleAdded[i]:=0;
  end;

  SetLength(TriangleScore,CountTriangles);
  for i:=0 to length(TriangleScore)-1 do begin
   TriangleScore[i]:=0;
  end;

  SetLength(TriangleIndices,CountTriangles*3);
  for i:=0 to length(TriangleIndices)-1 do begin
   TriangleIndices[i]:=0;
  end;

  // Count the triangle array offset for each vertex,
  // initialize the rest of the data.
  Sum:=0;
  for i:=0 to CountVertices-1 do begin
   Offsets[i]:=Sum;
   inc(Sum,NumActiveTris[i]);
   NumActiveTris[i]:=0;
   CacheTag[i]:=-1;
  end;

  // Fill the vertex data structures with indices to the triangles
  // using each vertex
  k:=0;
  for i:=0 to CountTriangles-1 do begin
   for j:=0 to 2 do begin
    v:=Indices[k];
    inc(k);
    TriangleIndices[Offsets[v]+NumActiveTris[v]]:=i;
    inc(NumActiveTris[v]);
   end;
  end;

  // Initialize the score for all vertices
  for i:=0 to CountVertices-1 do begin
   LastScore[i]:=FindVertexScore(NumActiveTris[i],CacheTag[i]);
   for j:=0 to numActiveTris[i]-1 do begin
    inc(TriangleScore[TriangleIndices[Offsets[i]+j]],LastScore[i]);
   end;
  end;

  // Find the best triangle
  BestTriangle:=-1;
  BestScore:=-1;
  for i:=0 to CountTriangles-1 do begin
   if TriangleScore[i]>BestScore then begin
    BestScore:=TriangleScore[i];
    BestTriangle:=i;
   end;
  end;

  // Allocate the output array
  SetLength(OutTriangles,CountTriangles);
  OutPos:=0;

  // Initialize the cache
  for i:=Low(TCache) to High(TCache) do begin
   Cache[i]:=-1;
  end;

  ScanPos:=0;

  // Output the currently best triangle, as long as there
  // are triangles left to output.
  while BestTriangle>=0 do begin

   // Mark the triangle as added.
   TriangleAdded[BestTriangle shr 5]:=TriangleAdded[BestTriangle shr 5] or (1 shl (BestTriangle and 31));

   // Output this triangle.
   OutTriangles[OutPos]:=BestTriangle;
   inc(OutPos);
   for i:=0 to 2 do begin

    // Update this vertex
    v:=Indices[(BestTriangle*3)+i];

    // Check the current cache position, if it
    // is in the cache
    EndPos:=CacheTag[v];
    if (EndPos<0) or (EndPos>high(TCache)) then begin
     EndPos:=VERTEX_CACHE_SIZE+i;
    end;

    // Move all cache entries from the previous position
    // in the cache to the new target position (i) one
    // step backwards.
    for j:=EndPos downto i+1 do begin
     Cache[j]:=Cache[j-1];
     // If this cache slot contains a real
     // vertex, update its cache tag.
     if Cache[j]>=0 then begin
      inc(CacheTag[Cache[j]]);
     end;
    end;

    // Insert the current vertex into its new target
    // slot.
    Cache[i]:=v;
    CacheTag[v]:=i;

    // Find the current triangle in the list of active
    // triangles and remove it (moving the last
    // triangle in the list to the slot of this triangle).
    for j:=0 to NumActiveTris[v]-1 do begin
     if TriangleIndices[Offsets[v]+j]=BestTriangle then begin
      TriangleIndices[Offsets[v]+j]:=TriangleIndices[(Offsets[v]+NumActiveTris[v])-1];
      break;
     end;
    end;

    // Shorten the list.
    dec(NumActiveTris[v]);
   end;

   // Update the scores of all triangles in the cache
   for i:=0 to (VERTEX_CACHE_SIZE+3)-1 do begin
    v:=Cache[i];

    if v<0 then begin
     break;
    end;

    // This vertex has been pushed outside of the
    // actual cache
    if i>=VERTEX_CACHE_SIZE then begin
     CacheTag[v]:=-1;
     Cache[i]:=-1;
    end;

    NewScore:=FindVertexScore(NumActiveTris[v],CacheTag[v]);

    Diff:=NewScore-LastScore[v];
    for j:=0 to numActiveTris[v]-1 do begin
     inc(TriangleScore[TriangleIndices[Offsets[v]+j]],Diff);
    end;
    LastScore[v]:=NewScore;
    
   end;

   // Find the besttriangle referenced by vertices in the
   // cache
   BestTriangle:=-1;
   BestScore:=-1;
   for i:=0 to VERTEX_CACHE_SIZE-1 do begin
    if Cache[i]<0 then begin
     break;
    end;

    v:=Cache[i];
    for j:=0 to NumActiveTris[v]-1 do begin
     t:=TriangleIndices[Offsets[v]+j];
     if TriangleScore[t]>BestScore then begin
      BestTriangle:=t;
      BestScore:=TriangleScore[t];
     end;
    end;
   end;

   // If no active triangle was found at all, continue
   // scanning the whole list of triangles
   if BestTriangle<0 then begin
    while ScanPos<CountTriangles do begin
     if (TriangleAdded[ScanPos shr 5] and (1 shl (ScanPos and 31)))=0 then begin
      BestTriangle:=ScanPos;
      break;
     end;
     inc(ScanPos);
    end;
   end;

  end;

  SetLength(OutIndices,length(Indices));
  OutPos:=0;
  for i:=0 to CountTriangles-1 do begin
   t:=OutTriangles[i];
   for j:=0 to 2 do begin
    OutIndices[OutPos]:=Indices[(t*3)+j];
    inc(OutPos);
   end;
  end;

  result:=true;

 finally
  SetLength(NumActiveTris,0);
  SetLength(Offsets,0);
  SetLength(LastScore,0);
  SetLength(CacheTag,0);
  SetLength(TriangleAdded,0);
  SetLength(TriangleScore,0);
  SetLength(TriangleIndices,0);
 end;
end;

initialization
 InitializeVertexCacheOptimizer;
end.

