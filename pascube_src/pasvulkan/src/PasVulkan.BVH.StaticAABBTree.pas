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
unit PasVulkan.BVH.StaticAABBTree;
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
{$endif}

{$define NonRecursive}

{$ifndef fpc}
 {$scopedenums on}
{$endif}

{$warnings off}

interface

uses SysUtils,Classes,Math,
     PasVulkan.Types,
     PasVulkan.Math;

type TpvBVHStaticAABBTree=class
      public
       type TTreeProxy=record
             AABB:TpvAABB;
             UserData:TpvPtrInt;
             Next:TpvSizeInt;
            end;
            PTreeProxy=^TTreeProxy;
            TTreeProxies=array of TTreeProxy;
            TTreeNode=record
             AABB:TpvAABB;
             Children:array[0..1] of TpvSizeInt;
             Proxies:TpvSizeInt;
            end;
            PTreeNode=^TTreeNode;
            TTreeNodes=array of TTreeNode;
      public
       Proxies:TTreeProxies;
       ProxiesCount:TpvSizeInt;
       Nodes:TTreeNodes;
       NodeCount:TpvSizeInt;
       Root:TpvSizeInt;
       constructor Create;
       destructor Destroy; override;
       procedure CreateProxy(const aAABB:TpvAABB;const aUserData:TpvPtrInt);
       procedure Build(const aThreshold:TpvSizeInt=8;const aMaxDepth:TpvSizeInt=64;const aKDTree:boolean=false);
     end;

implementation

{ TpvBVHStaticAABBTree }

constructor TpvBVHStaticAABBTree.Create;
begin
 inherited Create;
 Proxies:=nil;
 ProxiesCount:=0;
 Nodes:=nil;
 NodeCount:=-1;
 Root:=-1;
end;

destructor TpvBVHStaticAABBTree.Destroy;
begin
 SetLength(Proxies,0);
 SetLength(Nodes,0);
 inherited Destroy;
end;

procedure TpvBVHStaticAABBTree.CreateProxy(const aAABB:TpvAABB;const aUserData:TpvPtrInt);
var Index:TpvSizeInt;
begin
 Index:=ProxiesCount;
 inc(ProxiesCount);
 if ProxiesCount>=length(Proxies) then begin
  SetLength(Proxies,RoundUpToPowerOfTwo(ProxiesCount));
 end;
 Proxies[Index].AABB:=aAABB;
 Proxies[Index].UserData:=aUserData;
 Proxies[Index].Next:=Index-1;
end;

procedure TpvBVHStaticAABBTree.Build(const aThreshold:TpvSizeInt=8;const aMaxDepth:TpvSizeInt=64;const aKDTree:boolean=false);
var Counter,StackPointer,Node,Depth,LeftCount,RightCount,ParentCount,Axis,BestAxis,Proxy,Balance,BestBalance,
    NextProxy,LeftNode,RightNode,TargetNode:TpvSizeInt;
    Stack:array of TpvSizeInt;
    Center:TpvVector3;
    LeftAABB,RightAABB:TpvAABB;
begin
 SetLength(Proxies,ProxiesCount);
 if ProxiesCount>0 then begin
  Stack:=nil;
  try
   Root:=0;
   NodeCount:=1;
   SetLength(Nodes,Max(NodeCount,ProxiesCount));
   Nodes[0].AABB:=Proxies[0].AABB;
   for Counter:=1 to ProxiesCount-1 do begin
    Nodes[0].AABB:=Nodes[0].AABB.Combine(Proxies[Counter].AABB);
   end;
   for Counter:=0 to ProxiesCount-2 do begin
    Proxies[Counter].Next:=Counter+1;
   end;
   Proxies[ProxiesCount-1].Next:=-1;
   Nodes[0].Proxies:=0;
   Nodes[0].Children[0]:=-1;
   Nodes[0].Children[1]:=-1;
   SetLength(Stack,16);
   Stack[0]:=0;
   Stack[1]:=aMaxDepth;
   StackPointer:=2;
   while StackPointer>0 do begin
    dec(StackPointer,2);
    Node:=Stack[StackPointer];
    Depth:=Stack[StackPointer+1];
    if (Node>=0) and (Nodes[Node].Proxies>=0) then begin
     Proxy:=Nodes[Node].Proxies;
     Nodes[Node].AABB:=Proxies[Proxy].AABB;
     Proxy:=Proxies[Proxy].Next;
     ParentCount:=1;
     while Proxy>=0 do begin
      Nodes[Node].AABB:=Nodes[Node].AABB.Combine(Proxies[Proxy].AABB);
      inc(ParentCount);
      Proxy:=Proxies[Proxy].Next;
     end;
     if (Depth<>0) and ((ParentCount>2) and (ParentCount>=aThreshold)) then begin
      Center:=(Nodes[Node].AABB.Min+Nodes[Node].AABB.Max)*0.5;
      BestAxis:=-1;
      BestBalance:=$7fffffff;
      for Axis:=0 to 3 do begin
       LeftCount:=0;
       RightCount:=0;
       ParentCount:=0;
       LeftAABB:=Nodes[Node].AABB;
       RightAABB:=Nodes[Node].AABB;
       LeftAABB.Max.xyz[Axis]:=Center.xyz[Axis];
       RightAABB.Min.xyz[Axis]:=Center.xyz[Axis];
       Proxy:=Nodes[Node].Proxies;
       if aKDTree then begin
        while Proxy>=0 do begin
         if LeftAABB.Contains(Proxies[Proxy].AABB) then begin
          inc(LeftCount);
         end else if RightAABB.Contains(Proxies[Proxy].AABB) then begin
          inc(RightCount);
         end else begin
          inc(ParentCount);
         end;
         Proxy:=Proxies[Proxy].Next;
        end;
        if (LeftCount>0) and (RightCount>0) then begin
         Balance:=abs(RightCount-LeftCount);
         if (BestBalance>Balance) and ((LeftCount+RightCount)>=ParentCount) and ((LeftCount+RightCount+ParentCount)>=aThreshold) then begin
          BestBalance:=Balance;
          BestAxis:=Axis;
         end;
        end;
       end else begin
        while Proxy>=0 do begin
         if ((Proxies[Proxy].AABB.Min+Proxies[Proxy].AABB.Max)*0.5).xyz[Axis]<RightAABB.Min.xyz[Axis] then begin
          inc(LeftCount);
         end else begin
          inc(RightCount);
         end;
         Proxy:=Proxies[Proxy].Next;
        end;
        if (LeftCount>0) and (RightCount>0) then begin
         Balance:=abs(RightCount-LeftCount);
         if BestBalance>Balance then begin
          BestBalance:=Balance;
          BestAxis:=Axis;
         end;
        end;
       end;
      end;
      if BestAxis>=0 then begin
       LeftNode:=NodeCount;
       RightNode:=NodeCount+1;
       inc(NodeCount,2);
       if NodeCount>=length(Nodes) then begin
        SetLength(Nodes,RoundUpToPowerOfTwo(NodeCount));
       end;
       LeftAABB:=Nodes[Node].AABB;
       RightAABB:=Nodes[Node].AABB;
       LeftAABB.Max.xyz[BestAxis]:=Center.xyz[BestAxis];
       RightAABB.Min.xyz[BestAxis]:=Center.xyz[BestAxis];
       Proxy:=Nodes[Node].Proxies;
       Nodes[LeftNode].Proxies:=-1;
       Nodes[RightNode].Proxies:=-1;
       Nodes[Node].Proxies:=-1;
       if aKDTree then begin
        while Proxy>=0 do begin
         NextProxy:=Proxies[Proxy].Next;
         if LeftAABB.Contains(Proxies[Proxy].AABB) then begin
          TargetNode:=LeftNode;
         end else if RightAABB.Contains(Proxies[Proxy].AABB) then begin
          TargetNode:=RightNode;
         end else begin
          TargetNode:=Node;
         end;
         Proxies[Proxy].Next:=Nodes[TargetNode].Proxies;
         Nodes[TargetNode].Proxies:=Proxy;
         Proxy:=NextProxy;
        end;
       end else begin
        while Proxy>=0 do begin
         NextProxy:=Proxies[Proxy].Next;
         if ((Proxies[Proxy].AABB.Min+Proxies[Proxy].AABB.Max)*0.5).xyz[BestAxis]<RightAABB.Min.xyz[BestAxis] then begin
          TargetNode:=LeftNode;
         end else begin
          TargetNode:=RightNode;
         end;
         Proxies[Proxy].Next:=Nodes[TargetNode].Proxies;
         Nodes[TargetNode].Proxies:=Proxy;
         Proxy:=NextProxy;
        end;
       end;
       Nodes[Node].Children[0]:=LeftNode;
       Nodes[Node].Children[1]:=RightNode;
       Nodes[LeftNode].AABB:=LeftAABB;
       Nodes[LeftNode].Children[0]:=-1;
       Nodes[LeftNode].Children[1]:=-1;
       Nodes[RightNode].AABB:=RightAABB;
       Nodes[RightNode].Children[0]:=-1;
       Nodes[RightNode].Children[1]:=-1;
       if (StackPointer+4)>=length(Stack) then begin
        SetLength(Stack,RoundUpToPowerOfTwo(StackPointer+4));
       end;
       Stack[StackPointer+0]:=LeftNode;
       Stack[StackPointer+1]:=Max(-1,Depth-1);
       Stack[StackPointer+2]:=RightNode;
       Stack[StackPointer+3]:=Max(-1,Depth-1);
       inc(StackPointer,4);
      end;
     end;
    end;
   end;
   SetLength(Nodes,NodeCount);
  finally
   Stack:=nil;
  end;
 end else begin
  NodeCount:=0;
  SetLength(Nodes,0);
 end;
end;

end.

