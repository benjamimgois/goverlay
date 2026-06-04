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
unit PasVulkan.ConvexHullGenerator2D;
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
     PasVulkan.Math;

type TpvConvexHull2DPixels=array of boolean;

procedure GetConvexHull2D(const Pixels:TpvConvexHull2DPixels;
                          const Width,Height:TpvInt32;
                          out ConvexHullVertices:TpvVector2DynamicArray;
                          CountVertices:TpvInt32;
                          out CenterX,CenterY,CenterRadius:TpvFloat;
                          const BorderExtendX:TpvFloat=1.0;
                          const BorderExtendY:TpvFloat=1.0;
                          const ConvexHullMode:TpvInt32=0);

implementation

function IsLeft(const p0,p1,p2:TpvVector2):TpvFloat;
begin
 result:=((p1.x-p0.x)*(p2.y-p0.y))-((p2.x-p0.x)*(p1.y-p0.y));
end;

function FindPerpendicularDistance(const p,p1,p2:TpvVector2):TpvFloat;
var slope,intercept:TpvFloat;
begin
 if p1.x=p2.x then begin
  result:=abs(p.x-p1.x);
 end else begin
  slope:=(p2.y-p1.y)/(p2.x-p1.x);
  intercept:=p1.y-(slope*p1.x);
  result:=abs(((slope*p.x)-p.y)+intercept)/sqrt(sqr(slope)+1);
 end;
end;

function RamerDouglasPeucker(const Points:TpvVector2DynamicArray;Epsilon:TpvFloat):TpvVector2DynamicArray;
var FirstPoint,LastPoint:TpvVector2;
    Index,i,j:TpvInt32;
    Distance,BestDistance:TpvFloat;
    r1,r2:TpvVector2DynamicArray;
begin
 if length(Points)<3 then begin
  result:=copy(Points);
 end else begin
  result:=nil;
  FirstPoint:=Points[0];
  LastPoint:=Points[length(Points)-1];
  Index:=-1;
  BestDistance:=0;
  for i:=1 to length(Points)-1 do begin
   Distance:=FindPerpendicularDistance(Points[i],FirstPoint,LastPoint);
   if BestDistance<Distance then begin
    BestDistance:=Distance;
    Index:=i;
   end;
  end;
  if BestDistance>Epsilon then begin
   r1:=RamerDouglasPeucker(copy(Points,0,Index+1),Epsilon);
   r2:=RamerDouglasPeucker(copy(Points,Index,(length(Points)-Index)+1),Epsilon);
   SetLength(result,(length(r1)-1)+length(r2));
   for i:=0 to length(r1)-2 do begin
    result[i]:=r1[i];
   end;
   j:=length(r1)-1;
   for i:=0 to length(r2)-1 do begin
    result[i+j]:=r2[i];
   end;
  end else begin
   SetLength(result,2);
   result[0]:=FirstPoint;
   result[1]:=LastPoint;
  end;
 end;
end;

function GenerateConvexHull(const Points:TpvVector2DynamicArray):TpvVector2DynamicArray;
var bot,top,i,n,minmin,minmax,maxmin,maxmax:TpvInt32;
    xmin,xmax:TpvFloat;
begin

 // indices for bottom and top of the stack
 //bot:=0;
 top:=-1;

 n:=length(Points);

 result:=nil;
 SetLength(result,n*3);

 // Get the indices of points with min x-coord and min|max y-coord
 minmin:=0;
 xmin:=Points[0].x;
 i:=1;
 while i<n do begin
  if Points[i].x<>xmin then begin
   break;
  end;
  inc(i);
 end;
 minmax:=i-1;

 if minmax=(n-1) then begin
  SetLength(result,3);
  // degenerate case: all x-coords == xmin
  inc(top);
  result[top]:=Points[minmin];
  if Points[minmax].y<>Points[minmin].y then begin
   // a nontrivial segment
   inc(top);
   result[top]:=Points[minmax];
  end;
  // add polygon endpoint
  inc(top);
  result[top]:=Points[minmin];
  SetLength(result,top+1);
  exit;
 end;

 // Get the indices of points with max x-coord and min|max y-coord
 maxmax:=n-1;
 xmax:=Points[n-1].x;
 i:=n-2;
 while i>=0 do begin
  if Points[i].x<>xmax then begin
   break;
  end;
  dec(i);
 end;
 maxmin:=i+1;

 // Compute the lower hull on the stack H
 inc(top);
 result[top]:=Points[minmin];      // push minmin point onto stack
 i:=minmax;
 while true do begin
  inc(i);
  if i<=maxmin then begin
   // the lower line joins P[minmin] with P[maxmin]
   if (IsLeft(Points[minmin],Points[maxmin],Points[i])>=0) and (i<maxmin) then begin
    // ignore P[i] above or on the lower line
    continue;
   end;
   while top>0 do begin
    // test if P[i] is left of the line at the stack top
    if IsLeft(result[top-1],result[top],Points[i])>0 then begin
     break;
    end else begin
     // pop top point off stack
     dec(top);
    end;
   end;
   // push P[i] onto stack
   inc(top);
   result[top]:=Points[i];
  end else begin
   break;
  end;
 end;
 if maxmax<>maxmin then begin
  // if distinct xmax points
  // push maxmax point onto stack
  inc(top);
  result[top]:=Points[maxmax];
 end;
 bot:=top; // the bottom point of the upper hull stack
 i:=maxmin;
 while true do begin
  dec(i);
  if i>=minmax then begin
   // the upper line joins P[maxmax] with P[minmax]
   if (IsLeft(Points[maxmax],Points[minmax],Points[i])>=0) and (i>minmax) then begin
    // ignore P[i] below or on the upper line
    continue;
   end;
   // at least 2 points on the upper stack
   while top>bot do begin
    // test if P[i] is left of the line at the stack top
    if IsLeft(result[top-1],result[top],Points[i])>0 then begin
     break;         // P[i] is a new hull vertex
    end else begin
     // pop top point off stack
     dec(top);
    end;
   end;
   // push P[i] onto stack
   inc(top);
   result[top]:=Points[i];
  end else begin
   break;
  end;
 end;
 if minmax<>minmin then begin
  // push joining endpoint onto stack
  inc(top);
  result[top]:=Points[minmin];
 end;

 if (abs(result[0].x-result[top].x)>(1e-18)) or (abs(result[0].y-result[top].y)>(1e-18)) then begin
  SetLength(result,top+2);
  result[top+1]:=result[0];
 end else begin
  SetLength(result,top+1);
 end;

end;

function VisvalingamWhyatt(const Points:TpvVector2DynamicArray;MaxCount:TpvInt32):TpvVector2DynamicArray;
var Index,Count,MinIndex:TpvInt32;
    MinArea,Area:TpvFloat;
begin
 result:=copy(Points);
 Count:=length(result);
 while (Count>3) and (Count>MaxCount) do begin
  MinIndex:=0;
  MinArea:=0;
  for Index:=1 to Count-2 do begin
   Area:=abs(((result[Index-1].x-result[Index+1].x)*(result[Index].y-result[Index-1].y))-
             ((result[Index-1].x-result[Index].x)*(result[Index+1].y-result[Index-1].y)))*0.5;
   if (MinIndex=0) or (MinArea>Area) then begin
    MinArea:=Area;
    MinIndex:=Index;
   end;
  end;
  for Index:=MinIndex to Count-2 do begin
   result[Index]:=result[Index+1];
  end;
  dec(Count);
 end;
 SetLength(result,Count);
end;

function VisvalingamWhyattModified(const Points:TpvVector2DynamicArray;MinimumArea:TpvFloat;MaxCount:TpvInt32):TpvVector2DynamicArray;
var Index,Count,MinIndex:TpvInt32;
    MinArea,Area:TpvFloat;
begin
 result:=copy(Points);
 Count:=length(result);
 while (Count>3) and (Count>MaxCount) do begin
  MinIndex:=0;
  MinArea:=0;
  for Index:=1 to Count-2 do begin
   Area:=abs(((result[Index-1].x-result[Index+1].x)*(result[Index].y-result[Index-1].y))-
             ((result[Index-1].x-result[Index].x)*(result[Index+1].y-result[Index-1].y)))*0.5;
   if (Area<=MinimumArea) and ((MinIndex=0) or (MinArea>Area)) then begin
    MinArea:=Area;
    MinIndex:=Index;
   end;
  end;
  if MinIndex=0 then begin
   break;
  end else begin
   for Index:=MinIndex to Count-2 do begin
    result[Index]:=result[Index+1];
   end;
   dec(Count);
  end;
 end;
 SetLength(result,Count);
end;

function GetArea(const Points:TpvVector2DynamicArray):TpvFloat;
var i:TpvInt32;
begin
 result:=0;
 for i:=0 to length(Points)-2 do begin
  result:=result+((Points[i].x*Points[i+1].y)-(Points[i+1].x*Points[i].y));
 end;
 result:=result*0.5;
end;

function FixLastPoint(const Points:TpvVector2DynamicArray):TpvVector2DynamicArray;
var c:TpvInt32;
begin
 result:=copy(Points);
 c:=length(Points);
 if (c>0) and ((abs(Points[0].x-Points[c-1].x)>(1e-18)) or (abs(Points[0].y-Points[c-1].y)>(1e-18))) then begin
  SetLength(result,c+1);
  result[c]:=Points[0];
 end;
end;

function FixNoLastPoint(const Points:TpvVector2DynamicArray):TpvVector2DynamicArray;
var c:TpvInt32;
begin
 result:=copy(Points);
 c:=length(Points);
 if (c>0) and ((abs(Points[0].x-Points[c-1].x)<=(1e-18)) and (abs(Points[0].y-Points[c-1].y)<=(1e-18))) then begin
  SetLength(result,c-1);
 end;
end;

function FixOrder(const Points:TpvVector2DynamicArray):TpvVector2DynamicArray;
var i,j:TpvInt32;
begin
 result:=copy(Points);
 if GetArea(Points)<0 then begin
  // If it is clockwise, so make it counterclockwise
  j:=length(Points);
  for i:=0 to length(Points)-1 do begin
   result[j-(i+1)]:=Points[i];
  end;
 end;
end;

function SortPoints(const Points:TpvVector2DynamicArray):TpvVector2DynamicArray;
var i:TpvInt32;
    p:TpvVector2;
begin
 result:=copy(Points);
 i:=0;
 while i<(length(result)-1) do begin
  if (result[i].y>result[i+1].y) or ((result[i].y=result[i+1].y) and (result[i].x>result[i+1].x)) then begin
   p:=result[i];
   result[i]:=result[i+1];
   result[i+1]:=p;
   if i>0 then begin
    dec(i);
   end else begin
    inc(i);
   end;
  end else begin
   inc(i);
  end;
 end;
end;

function SegmentSegmentIntersection(const a1,a2,b1,b2:TpvVector2):TpvFloat;
const epsilon=0.0000000001;
var r1,r2:TpvVector2;
    A,B,s,t:TpvFloat;
begin
 r1.x:=a2.x-a1.x;
 r1.y:=a2.y-a1.y;
 r2.x:=b2.x-b1.x;
 r2.y:=b2.y-b1.y;
 if r1.x=0 then begin
  result:=-1;
  exit;
 end;
 A:=(a1.y-b1.y)+((r1.y/r1.x)*(b1.x-a1.x));
 B:=r2.y-((r1.y/r1.x)*r2.x);
 if B=0 then begin
  result:=-1;
  exit;
 end;
 s:=A/B;
 if (s<=epsilon) or (s>(1.0+epsilon)) then begin
  result:=-1;
  exit;
 end;
 t:=((b1.x-a1.x)+(s*r2.x))/r1.x;
 if (t<epsilon) or (t>(1.0+epsilon)) then begin
  result:=-1;
  exit;
 end;
 result:=t;
end;

function SegmentHullIntersection(const Points:TpvVector2DynamicArray;const a1,a2:TpvVector2):boolean;
var i:TpvInt32;
begin
 result:=false;
 for i:=0 to length(Points)-2 do begin
  if SegmentSegmentIntersection(a1,a2,Points[i],Points[i+1])>=0 then begin
   result:=true;
   break;
  end;
 end;
end;

function PointHullIntersection(const Points:TpvVector2DynamicArray;const p:TpvVector2):boolean;
var i:TpvInt32;
    d:TpvFloat;
    Sign,FirstSign:boolean;
begin
 result:=true;
 FirstSign:=false;
 for i:=0 to length(Points)-2 do begin
  d:=((p.y-Points[i].y)*(Points[i+1].x-Points[i].x))-((p.x-Points[i].x)*(Points[i+1].y-Points[i].y));
  if d<>0 then begin
   Sign:=d>0;
   if i=0 then begin
    FirstSign:=Sign;
   end else if Sign<>FirstSign then begin
    result:=false;
    break;
   end;
  end;
 end;
end;

function PointInHull(const Points:TpvVector2DynamicArray;const p:TpvVector2):boolean;
var i,j:TpvInt32;
    d0,d1:TpvVector2;
    d:TpvFloat;
    s:boolean;
begin
 result:=false;
 j:=length(Points)-2;
 for i:=0 to length(Points)-3 do begin
  if ((Points[i].y>p.y)<>(Points[j].y>p.y)) and
	   (p.x<(((Points[j].x-Points[i].x)*((p.y-Points[i].y)/(Points[j].y-Points[i].y)))+Points[i].x)) then begin
   result:=not result;
  end;
  j:=i;
 end;
end;

function InRect(const a,b,c:TpvVector2):boolean;
begin
 if b.x=c.x then begin
  result:=(a.y>=Math.min(b.y,c.y)) and (a.y<=Math.max(b.y, c.y));
 end else if b.y=c.y then begin
  result:=(a.x>=Math.min(b.x,c.x)) and (a.x<=Math.max(b.x,c.x));
 end else begin
  result:=((a.x>=Math.min(b.x,c.x)) and (a.x<=Math.max(b.x,c.x))) and
          ((a.y>=Math.min(b.y,c.y)) and (a.y<=Math.max(b.y,c.y)));
 end;
end;

function GetLineIntersection(const a1,a2,b1,b2:TpvVector2;var HitPoint:TpvVector2):boolean;
var dax,dbx,day,dby,Den,A,B:TpvFloat;
begin
 result:=false;
 dax:=a1.x-a2.x;
 dbx:=b1.x-b2.x;
 day:=a1.y-a2.y;
 dby:=b1.y-b2.y;
 Den:=(dax*dby)-(day*dbx);
 if abs(Den)<1e-20 then begin
  exit;
 end;
 A:=(a1.x*a2.y)-(a1.y*a2.x);
 B:=(b1.x*b2.y)-(b1.y*b2.x);
 HitPoint.x:=((A*dbx)-(dax*B))/Den;
 HitPoint.y:=((A*dby)-(day*B))/Den;
 result:=InRect(HitPoint,a1,a2) and InRect(HitPoint,b1,b2);
end;

function FindOptimalPolygon(const Points:TpvVector2DynamicArray;VertexCount:TpvInt32;var DestArea:TpvFloat):TpvVector2DynamicArray;
type TLine=record
      Start:TpvVector2;
      Difference:TpvVector2;
     end;
     TLines=array of TLine;
var Vertices,Edges,Dest:TpvVector2DynamicArray;
    Counters:array of TpvInt32;
    Lines:TLines;
    First:boolean;
    MinArea:TpvFloat;
 function Perp(const u,v:TpvVector2):TpvFloat;
 begin
  result:=(u.x*v.y)-(u.y*v.x);
 end;
 function Intersect(var HitPoint:TpvVector2;const Line0,Line1:TLine):boolean;
 var d,t:TpvFloat;
     Difference:TpvVector2;
 begin
  result:=false;
  d:=Perp(Line0.Difference,Line1.Difference);
  if abs(d)<1e-12 then begin
   exit;
  end;
  Difference.x:=Line0.Start.x-Line1.Start.x;
  Difference.y:=Line0.Start.y-Line1.Start.y;
  t:=Perp(Line1.Difference,Difference)/d;
  if t<0.5 then begin
   exit;
  end;
  HitPoint.x:=Line0.Start.x+(Line0.Difference.x*t);
  HitPoint.y:=Line0.Start.y+(Line0.Difference.y*t);
  result:=true;
 end;
 procedure DoLevel(Level:TpvInt32);
 var i:TpvInt32;
     Area:TpvFloat;
 begin
  if (Level+1)=VertexCount then begin
   while Counters[Level]<length(Lines) do begin
    if Intersect(Vertices[Level-1],Lines[Counters[Level-1]],Lines[Counters[Level]]) then begin
     if Intersect(Vertices[Level],Lines[Counters[Level]],Lines[Counters[0]]) then begin
      for i:=0 to VertexCount-2 do begin
       Edges[i].x:=Vertices[i+1].x-Vertices[0].x;
       Edges[i].y:=Vertices[i+1].y-Vertices[0].y;
      end;
      Area:=0;
      for i:=0 to VertexCount-3 do begin
       Area:=Area+((Edges[i].y*Edges[i+1].x)-(Edges[i].x*Edges[i+1].y));
      end;
      Area:=abs(Area)*0.5;
      if First or (Area<MinArea) then begin
       First:=false;
       MinArea:=Area;
       for i:=0 to VertexCount-1 do begin
        Dest[i]:=Vertices[i];
       end;
      end;
     end;
    end;
    inc(Counters[Level]);
   end;
  end else begin
   while Counters[Level]<length(Lines) do begin
    if Intersect(Vertices[Level-1],Lines[Counters[Level-1]],Lines[Counters[Level]]) then begin
     Counters[Level+1]:=Counters[Level]+1;
     DoLevel(Level+1);
    end;
    inc(Counters[Level]);
   end;
  end;
 end;
var i:TpvInt32;
begin
 Vertices:=nil;
 Edges:=nil;
 Dest:=nil;
 Lines:=nil;
 Counters:=nil;
 if (length(Points)>=3) and (VertexCount>=3) then begin
  try
   SetLength(Vertices,VertexCount);
   SetLength(Edges,VertexCount);
   SetLength(Dest,VertexCount);
   SetLength(Counters,VertexCount);

   First:=true;

   MinArea:=0;

   SetLength(Lines,length(Points));
   if GetArea(Points)<0 then begin
    // Input is clockwise
    for i:=0 to length(Points)-1 do begin
     Lines[i].Start:=Points[i];
     Lines[i].Difference.x:=Points[(i+1) mod length(Points)].x-Lines[i].Start.x;
     Lines[i].Difference.y:=Points[(i+1) mod length(Points)].y-Lines[i].Start.y;
    end;
   end else begin
    // Input is counterclockwise
    for i:=0 to length(Points)-1 do begin
     Lines[i].Start:=Points[length(Points)-(i+1)];
     Lines[i].Difference.x:=Points[length(Points)-(((i+1) mod length(Points))+1)].x-Lines[i].Start.x;
     Lines[i].Difference.y:=Points[length(Points)-(((i+1) mod length(Points))+1)].y-Lines[i].Start.y;
    end;
   end;

   for i:=0 to VertexCount-1 do begin
    Counters[i]:=0;
   end;

   while Counters[0]<length(Lines) do begin
    Counters[1]:=Counters[0]+1;
    while Counters[1]<length(Lines) do begin
     if Intersect(Vertices[0],Lines[Counters[0]],Lines[Counters[1]]) then begin
      Counters[2]:=Counters[1]+1;
      DoLevel(2);
     end;
     inc(Counters[1]);
    end;
    inc(Counters[0]);
   end;

   DestArea:=MinArea;

  finally
   SetLength(Vertices,0);
   SetLength(Edges,0);
   SetLength(Lines,0);
   SetLength(Counters,0);
  end;
 end;
 result:=Dest;
end;

function FixConvexHull(const OptimizedPoints,OriginalPoints:TpvVector2DynamicArray):TpvVector2DynamicArray;
var Count,Index,OtherIndex,OtherOtherIndex:TpvInt32;
    pA,pB,oA,oB:PpvVector2;
    AB,Normal,HitPoint,MidPoint,CenterPoint,BestHitPoint:TpvVector2;
    First,Last,Denominator,Distance,BestDistance,t,d,x1,y1,x2,y2:TpvFloat;
    OK:boolean;
begin
 result:=copy(OptimizedPoints);
 Count:=length(result);
 CenterPoint.x:=0;
 CenterPoint.y:=0;
 x1:=0.0;
 y1:=0.0;
 x2:=0.0;
 y2:=0.0;
 for OtherIndex:=0 to length(OriginalPoints)-1 do begin
  oA:=@OriginalPoints[OtherIndex];
  if OtherIndex=0 then begin
   x1:=oA^.x;
   y1:=oA^.y;
   x2:=oA^.x;
   y2:=oA^.y;
  end else begin
   x1:=Min(x1,oA^.x);
   y1:=Min(y1,oA^.y);
   x2:=Max(x2,oA^.x);
   y2:=Max(y2,oA^.y);
  end;
 end;
 CenterPoint.x:=(x1+x2)*0.5;
 CenterPoint.y:=(y1+y2)*0.5;
 OK:=true;
 while OK and (Count>3) do begin
  OK:=false;
  Index:=0;
  while Index<(Count-1) do begin
   pA:=@result[Index+0];
   pB:=@result[Index+1];
   AB.x:=pB^.x-pA^.x;
   AB.y:=pB^.y-pA^.y;
   MidPoint.x:=(pA^.x+pB^.x)*0.25;
   MidPoint.y:=(pA^.y+pB^.y)*0.25;
   if PointHullIntersection(OriginalPoints,MidPoint) then begin
    inc(Count);
    SetLength(result,Count);
    for OtherOtherIndex:=Count-1 downto Index+2 do begin
     result[OtherOtherIndex]:=result[OtherOtherIndex-1];
    end;
    result[Index+1].x:=MidPoint.x;
    result[Index+1].y:=MidPoint.y;
    inc(Index);
    OK:=true;
   end;
   pA:=@result[Index+0];
   pB:=@result[Index+1];
   First:=0;
   Last:=0;
   BestDistance:=0;
   for OtherIndex:=0 to length(OriginalPoints)-2 do begin
    oA:=@OriginalPoints[OtherIndex+0];
    oB:=@OriginalPoints[OtherIndex+1];
    if GetLineIntersection(pA^,pB^,oA^,oB^,HitPoint) then begin
     if ((abs(HitPoint.x-pA^.x)+abs(HitPoint.y-pA^.y))>0) and
        ((abs(HitPoint.x-pB^.x)+abs(HitPoint.y-pB^.y))>0) then begin
      Distance:=sqr(CenterPoint.x-HitPoint.x)+sqr(CenterPoint.y-HitPoint.y);
      if BestDistance<Distance then begin
       BestDistance:=Distance;
       BestHitPoint:=HitPoint;
      end;
     end;
    end;
   end;
   if BestDistance>0 then begin
    inc(Count);
    SetLength(result,Count);
    for OtherOtherIndex:=Count-1 downto Index+2 do begin
     result[OtherOtherIndex]:=result[OtherOtherIndex-1];
    end;
    result[Index+1].x:=BestHitPoint.x;
    result[Index+1].y:=BestHitPoint.y;
   end;
   inc(Index);
  end;
 end;
 SetLength(result,Count);
end;

procedure GetConvexHull2D(const Pixels:TpvConvexHull2DPixels;
                          const Width,Height:TpvInt32;
                          out ConvexHullVertices:TpvVector2DynamicArray;
                          CountVertices:TpvInt32;
                          out CenterX,CenterY,CenterRadius:TpvFloat;
                          const BorderExtendX:TpvFloat=1.0;
                          const BorderExtendY:TpvFloat=1.0;
                          const ConvexHullMode:TpvInt32=0);
var SpriteW,SpriteH,rx1,ry1,rx2,ry2,x,y,x1,x2,y1,y2,c,c2,i,j,k,n,p:TpvInt32;
    SpriteBitmap,SpriteBitmap2:TpvConvexHull2DPixels;
    WorkVertices,HullVertices,OriginalHullVertices:TpvVector2DynamicArray;
    b,OK:boolean;
    cx,cy,cr,r,d:TpvFloat;
begin
 ConvexHullVertices:=nil;
 CenterX:=0.0;
 CenterY:=0.0;
 CenterRadius:=0.0;
 SpriteBitmap:=nil;
 SpriteBitmap2:=nil;
 WorkVertices:=nil;
 HullVertices:=nil;
 OriginalHullVertices:=nil;
 if (Width>0) and (Height>0) then begin
  try

   // Get width and height
   SpriteW:=Width;
   SpriteH:=Height;

   // Initialize arrays
   SetLength(SpriteBitmap,SpriteW*SpriteH);
   SetLength(SpriteBitmap2,SpriteW*SpriteH);
   for x:=0 to (SpriteW*SpriteH)-1 do begin
    SpriteBitmap[x]:=Pixels[x];
    SpriteBitmap2[x]:=false;
   end;

   // Content size detection
   rx1:=SpriteW+1;
   ry1:=SpriteH+1;
   rx2:=-1;
   ry2:=-1;
   for y:=0 to SpriteH-1 do begin
    for x:=0 to SpriteW-1 do begin
     if SpriteBitmap[(y*SpriteW)+x] then begin
      rx1:=min(rx1,x);
      ry1:=min(ry1,y);
      rx2:=max(rx2,x);
      ry2:=max(ry2,y);
     end;
    end;
   end;

   case ConvexHullMode of
    0:begin
     c:=4;
     SetLength(WorkVertices,4);
     WorkVertices[0].x:=0.0;
     WorkVertices[0].y:=0.0;
     WorkVertices[1].x:=(SpriteW-1.0)+BorderExtendX;
     WorkVertices[1].y:=0.0;
     WorkVertices[2].x:=(SpriteW-1.0)+BorderExtendX;
     WorkVertices[2].y:=(SpriteH-1.0)+BorderExtendY;
     WorkVertices[3].x:=0.0;
     WorkVertices[3].y:=(SpriteH-1.0)+BorderExtendY;
    end;
    1:begin
     c:=4;
     SetLength(WorkVertices,4);
     WorkVertices[0].x:=rx1;
     WorkVertices[0].y:=ry1;
     WorkVertices[1].x:=rx2+BorderExtendX;
     WorkVertices[1].y:=ry1;
     WorkVertices[2].x:=rx2+BorderExtendX;
     WorkVertices[2].y:=ry2+BorderExtendY;
     WorkVertices[3].x:=rx1;
     WorkVertices[3].y:=ry2+BorderExtendY;
    end;
    else begin

     // Outer edge detection
     for y:=0 to SpriteH-1 do begin
      x1:=SpriteW+1;
      x2:=-1;
      for x:=0 to SpriteW-1 do begin
       if SpriteBitmap[(y*SpriteW)+x] then begin
        x1:=min(x1,x);
        x2:=max(x2,x);
       end;
      end;
      for x:=0 to SpriteW-1 do begin
       SpriteBitmap2[(y*SpriteW)+x]:=(x=x1) or (x=x2);
      end;
     end;
     for x:=0 to SpriteW-1 do begin
      y1:=SpriteH+1;
      y2:=-1;
      for y:=0 to SpriteH-1 do begin
       if SpriteBitmap[(y*SpriteW)+x] then begin
        y1:=min(y1,y);
        y2:=max(y2,y);
       end;
      end;
      for y:=0 to SpriteH-1 do begin
       SpriteBitmap2[(y*SpriteW)+x]:=SpriteBitmap2[(y*SpriteW)+x] or ((y=y1) or (y=y2));
      end;
     end;

     // Reduce the count of points
     for y:=0 to SpriteH-1 do begin
      for x:=0 to SpriteW-1 do begin
       b:=SpriteBitmap2[(y*SpriteW)+x];
       if b then begin
        if ((x>0) and SpriteBitmap2[(y*SpriteW)+(x-1)]) and (((x+1)<SpriteW) and SpriteBitmap2[(y*SpriteW)+(x+1)]) then begin
         b:=false;
        end else if ((y>0) and SpriteBitmap2[((y-1)*SpriteW)+x]) and (((y+1)<SpriteH) and SpriteBitmap2[((y+1)*SpriteW)+x]) then begin
         b:=false;
        end else if (((x>0) and (y>0)) and SpriteBitmap2[((y-1)*SpriteW)+(x-1)]) and ((((x+1)<SpriteW) and ((y+1)<SpriteH)) and SpriteBitmap2[((y+1)*SpriteW)+(x+1)]) then begin
         b:=false;
        end else if ((((x+1)<SpriteW) and (y>0)) and SpriteBitmap2[((y-1)*SpriteW)+(x+1)]) and (((x>0) and ((y+1)<SpriteH)) and SpriteBitmap2[((y+1)*SpriteW)+(x-1)]) then begin
         b:=false;
        end;
       end;
       SpriteBitmap[(y*SpriteW)+x]:=b;
      end;
     end;

     // Generate work vector array
     c:=0;
     i:=-1;
     for y:=0 to SpriteH-1 do begin
      for x:=0 to SpriteW-1 do begin
       if SpriteBitmap[(y*SpriteW)+x] then begin
        i:=y;
        inc(c);
        break;
       end;
      end;
      for x:=SpriteW-1 downto 0 do begin
       if SpriteBitmap[(y*SpriteW)+x] then begin
        i:=y;
        inc(c);
        break;
       end;
      end;
     end;
     SetLength(WorkVertices,c+2);
     c:=0;
     for y:=0 to SpriteH-1 do begin
      for x:=0 to SpriteW-1 do begin
       if SpriteBitmap[(y*SpriteW)+x] then begin
        WorkVertices[c].x:=x;
        WorkVertices[c].y:=y;
        inc(c);
        break;
       end;
      end;
      for x:=SpriteW-1 downto 0 do begin
       if SpriteBitmap[(y*SpriteW)+x] then begin
        WorkVertices[c].x:=x+BorderExtendX;
        WorkVertices[c].y:=y;
        inc(c);
        break;
       end;
      end;
      if (y=i) and (BorderExtendY<>0.0) then begin
       for x:=0 to SpriteW-1 do begin
        if SpriteBitmap[(y*SpriteW)+x] then begin
         WorkVertices[c].x:=x;
         WorkVertices[c].y:=y+BorderExtendY;
         inc(c);
         break;
        end;
       end;
       for x:=SpriteW-1 downto 0 do begin
        if SpriteBitmap[(y*SpriteW)+x] then begin
         WorkVertices[c].x:=x+BorderExtendX;
         WorkVertices[c].y:=y+BorderExtendY;
         inc(c);
         break;
        end;
       end;
      end;
     end;
     SetLength(WorkVertices,c);

    end;
   end;

   if c>0 then begin
    HullVertices:=GenerateConvexHull(SortPoints(WorkVertices));
    c:=length(HullVertices);
    cx:=(rx1+rx2)*0.5;
    cy:=(ry1+ry2)*0.5;
    cr:=0;
    for i:=0 to c-1 do begin
     cr:=max(cr,sqr(cx-HullVertices[i].x)+sqr(cy-HullVertices[i].y));
    end;
    cr:=min(sqrt(cr),sqrt(sqr(rx2-rx1)+sqr(ry2-ry1))*0.5);
    cr:=ceil(cr);
    if CountVertices<4 then begin
     CountVertices:=4;
    end;
    OriginalHullVertices:=copy(HullVertices);
    c2:=length(FixNoLastPoint(HullVertices));
    if c2>CountVertices then begin
     if CountVertices<12 then begin

      HullVertices:=FindOptimalPolygon(FixNoLastPoint(HullVertices),CountVertices,r);

      for i:=0 to length(HullVertices)-1 do begin
       if HullVertices[i].x<cx then begin
        HullVertices[i].x:=floor(HullVertices[i].x);
       end else if HullVertices[i].x>cx then begin
        HullVertices[i].x:=ceil(HullVertices[i].x);
       end;
       if HullVertices[i].y<cy then begin
        HullVertices[i].y:=floor(HullVertices[i].y);
       end else if HullVertices[i].y>cy then begin
        HullVertices[i].y:=ceil(HullVertices[i].y);
       end;
      end;

      HullVertices:=GenerateConvexHull(SortPoints(FixNoLastPoint(HullVertices)));

     end else begin

      if (CountVertices<=17) and (c>17) then begin
       HullVertices:=GenerateConvexHull(SortPoints(FixNoLastPoint(RamerDouglasPeucker(FixOrder(HullVertices),1))));
       HullVertices:=GenerateConvexHull(SortPoints(FixNoLastPoint(VisvalingamWhyattModified(FixOrder(HullVertices),4,17))));
       c2:=length(FixNoLastPoint(HullVertices));
      end;
      if (CountVertices<=50) and (c>50) then begin
       HullVertices:=GenerateConvexHull(SortPoints(FixNoLastPoint(VisvalingamWhyatt(FixOrder(HullVertices),51))));
      end;
      c2:=length(FixNoLastPoint(HullVertices));
      if c2>CountVertices then begin
       if CountVertices<12 then begin
        HullVertices:=FindOptimalPolygon(FixNoLastPoint(HullVertices),CountVertices,r);
       end else begin
        HullVertices:=GenerateConvexHull(SortPoints(FixNoLastPoint(VisvalingamWhyatt(FixOrder(HullVertices),CountVertices+1))));
       end;
      end;

      for i:=0 to length(HullVertices)-1 do begin
       if HullVertices[i].x<cx then begin
        HullVertices[i].x:=floor(HullVertices[i].x);
       end else if HullVertices[i].x>cx then begin
        HullVertices[i].x:=ceil(HullVertices[i].x);
       end;
       if HullVertices[i].y<cy then begin
        HullVertices[i].y:=floor(HullVertices[i].y);
       end else if HullVertices[i].y>cy then begin
        HullVertices[i].y:=ceil(HullVertices[i].y);
       end;
      end;

      HullVertices:=GenerateConvexHull(SortPoints(FixNoLastPoint(HullVertices)));

      for c:=0 to length(OriginalHullVertices)-1 do begin
       OK:=true;
       for i:=0 to length(OriginalHullVertices)-1 do begin
        n:=0;
        p:=0;
        for j:=0 to length(HullVertices)-1 do begin
         if SameValue(HullVertices[j].x,OriginalHullVertices[i].x) and
            SameValue(HullVertices[j].y,OriginalHullVertices[i].y) then begin
          OK:=true;
          break;
         end;
         k:=j+1;
         if j>=length(HullVertices) then begin
          k:=0;
         end;
         d:=((OriginalHullVertices[i].x-HullVertices[j].x)*(HullVertices[k].y-HullVertices[j].y))-
            ((OriginalHullVertices[i].y-HullVertices[j].y)*(HullVertices[k].x-HullVertices[j].x));
         if d<0.0 then begin
          inc(n);
         end else if d>0.0 then begin
          inc(p);
         end;
         if (p>0) and (n>0) then begin
          OK:=false;
          break;
         end;
        end;
        if not OK then begin
         SetLength(HullVertices,length(HullVertices)+1);
         HullVertices[length(HullVertices)-1]:=OriginalHullVertices[i];
         HullVertices:=GenerateConvexHull(SortPoints(FixNoLastPoint(HullVertices)));
         break;
        end;
       end;
       if OK then begin
        break;
       end;
      end;

     end;

    end;
    ConvexHullVertices:=FixNoLastPoint(FixOrder(HullVertices));
    CenterX:=cx;
    CenterY:=cy;
    CenterRadius:=cr;
   end;

  finally
   SetLength(SpriteBitmap,0);
   SetLength(SpriteBitmap2,0);
   SetLength(WorkVertices,0);
   SetLength(HullVertices,0);
  end;
 end;
end;

end.
