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
unit PasVulkan.BufferRangeAllocator;
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
     PasMP,
     PasVulkan.Collections,
     PasVulkan.Math,
     PasVulkan.Types;

type { TpvBufferRangeAllocator }
     TpvBufferRangeAllocator=class
      public
       type TOnResize=procedure(const aSender:TpvBufferRangeAllocator;const aNewCapacity:TpvInt64) of object;
            TOnDefragmentMove=procedure(const aSender:TpvBufferRangeAllocator;const aOldOffset,aNewOffset,aSize:TpvInt64) of object;
            { TRange }
            TRange=class;
            { TRangeRedBlackTree }
            TRangeRedBlackTree=TpvInt64RedBlackTree<TRange>;
            TRange=class
             public
              type TAllocationType=
                    (
                     Free,
                     Allocated
                    );
                   PAllocationType=^TAllocationType;
             private
              fBufferRangeAllocator:TpvBufferRangeAllocator;
              fOffset:TpvInt64;
              fSize:TpvInt64;
              fAlignment:TpvInt64;
              fAllocationType:TAllocationType;
              fOffsetRedBlackTreeNode:TRangeRedBlackTree.TNode;
              fSizeRedBlackTreeNode:TRangeRedBlackTree.TNode;
             public
              constructor Create(const aBufferRangeAllocator:TpvBufferRangeAllocator;const aOffset,aSize,aAlignment:TpvInt64;const aAllocationType:TAllocationType); reintroduce;
              destructor Destroy; override;
              procedure Update(const aOffset,aSize,aAlignment:TpvInt64;const aAllocationType:TAllocationType);
            end;
            { TBufferRange }
            TBufferRange=record
             public
              Offset:TpvInt64;
              Size:TpvInt64;
              Alignment:TpvInt64;
             public
              procedure Clear;
            end;
            PBufferRange=^TBufferRange;            
       const EmptyBufferRange:TBufferRange=(Offset:-1;Size:0;Alignment:0);
      private
       fOffsetRedBlackTree:TRangeRedBlackTree;
       fSizeRedBlackTree:TRangeRedBlackTree;
       fCapacity:TpvInt64;
       fOnResize:TOnResize;
       fAllocated:TpvInt64;
       fLock:TPasMPCriticalSection;
      public
       constructor Create(const aCapacity:TpvInt64=0); reintroduce;
       destructor Destroy; override;
       function Allocate(const aSize:TpvInt64;const aAlignment:TpvInt64=1):TpvInt64;
       function Release(const aOffset:TpvInt64;const aSize:TpvInt64=-1):Boolean;
       function AllocateBufferRange(const aSize:TpvInt64;const aAlignment:TpvInt64=1):TBufferRange;
       function AllocateBufferRangeWithOffsetChangeCheck(var aBufferRange:TBufferRange):Boolean;
       procedure ReleaseBufferRange(const aBufferRange:TBufferRange);
       procedure ReleaseBufferRangeAndNil(var aBufferRange:TBufferRange);
       function CalculateFragmentationFactor:TpvDouble;
       function Defragment(const aMove:TOnDefragmentMove):Boolean;
      published
       property Capacity:TpvInt64 read fCapacity;
       property OnResize:TOnResize read fOnResize write fOnResize; 
     end;

implementation

uses PasVulkan.Utils;

{ TpvBufferRangeAllocator.TRange }

constructor TpvBufferRangeAllocator.TRange.Create(const aBufferRangeAllocator:TpvBufferRangeAllocator;const aOffset,aSize,aAlignment:TpvInt64;const aAllocationType:TAllocationType);
begin
 inherited Create;
 fBufferRangeAllocator:=aBufferRangeAllocator;
 fOffset:=aOffset;
 fSize:=aSize;
 fAlignment:=aAlignment;
 fAllocationType:=aAllocationType;
 fOffsetRedBlackTreeNode:=fBufferRangeAllocator.fOffsetRedBlackTree.Insert(aOffset,self);
 if fAllocationType=TpvBufferRangeAllocator.TRange.TAllocationType.Free then begin
  fSizeRedBlackTreeNode:=fBufferRangeAllocator.fSizeRedBlackTree.Insert(aSize,self);
 end;
end;

destructor TpvBufferRangeAllocator.TRange.Destroy;
begin
 fBufferRangeAllocator.fOffsetRedBlackTree.Remove(fOffsetRedBlackTreeNode);
 if fAllocationType=TpvBufferRangeAllocator.TRange.TAllocationType.Free then begin
  fBufferRangeAllocator.fSizeRedBlackTree.Remove(fSizeRedBlackTreeNode);
 end;
 inherited Destroy;
end;

procedure TpvBufferRangeAllocator.TRange.Update(const aOffset,aSize,aAlignment:TpvInt64;const aAllocationType:TAllocationType);
begin
 if fOffset<>aOffset then begin
  fBufferRangeAllocator.fOffsetRedBlackTree.Remove(fOffsetRedBlackTreeNode);
  fOffsetRedBlackTreeNode:=fBufferRangeAllocator.fOffsetRedBlackTree.Insert(aOffset,self);
 end;
 if ((fAllocationType=TpvBufferRangeAllocator.TRange.TAllocationType.Free)<>(aAllocationType=TpvBufferRangeAllocator.TRange.TAllocationType.Free)) or (fSize<>aSize) then begin
  if fAllocationType=TpvBufferRangeAllocator.TRange.TAllocationType.Free then begin
   fBufferRangeAllocator.fSizeRedBlackTree.Remove(fSizeRedBlackTreeNode);
  end;
  if aAllocationType=TpvBufferRangeAllocator.TRange.TAllocationType.Free then begin
   fSizeRedBlackTreeNode:=fBufferRangeAllocator.fSizeRedBlackTree.Insert(aSize,self);
  end;
 end;
 fOffset:=aOffset;
 fSize:=aSize;
 fAlignment:=aAlignment;
 fAllocationType:=aAllocationType;
end;

{ TpvBufferRangeAllocator.TBufferRange }

procedure TpvBufferRangeAllocator.TBufferRange.Clear;
begin
 Offset:=-1;
 Size:=0;
end;

{ TpvBufferRangeAllocator }

constructor TpvBufferRangeAllocator.Create(const aCapacity:TpvInt64=0);
begin
 inherited Create;
 fLock:=TPasMPCriticalSection.Create;
 fOffsetRedBlackTree:=TRangeRedBlackTree.Create;
 fSizeRedBlackTree:=TRangeRedBlackTree.Create;
 fOnResize:=nil;
 fAllocated:=0;
 fCapacity:=aCapacity;
 if fCapacity>0 then begin
  TpvBufferRangeAllocator.TRange.Create(self,0,fCapacity,1,TpvBufferRangeAllocator.TRange.TAllocationType.Free);
 end;
end;

destructor TpvBufferRangeAllocator.Destroy;
begin
 if assigned(fOffsetRedBlackTree) then begin
  while assigned(fOffsetRedBlackTree.Root) do begin
   fOffsetRedBlackTree.Root.Value.Free;
  end;
 end;
 FreeAndNil(fOffsetRedBlackTree);
 FreeAndNil(fSizeRedBlackTree);
 FreeAndNil(fLock);
 inherited Destroy;
end;

function TpvBufferRangeAllocator.Allocate(const aSize:TpvInt64;const aAlignment:TpvInt64=1):TpvInt64;
var Range:TRange;
    Node,OtherNode:TRangeRedBlackTree.TNode;
    RangeBeginOffset,RangeEndOffset,PayloadBeginOffset,PayloadEndOffset,Alignment:TpvInt64;
begin

 if aSize>0 then begin

  Alignment:=RoundUpToPowerOfTwo64(aAlignment);

  fLock.Acquire;
  try

   repeat

    // Best-fit search
    Node:=fSizeRedBlackTree.Root;
    while assigned(Node) do begin
     if aSize<Node.Key then begin
      if assigned(Node.Left) then begin
       // If free block is too big, then go to left
       Node:=Node.Left;
       continue;
      end else begin
       // If free block is too big and there is no left children node, then try to find suitable smaller but not too small free blocks
       while assigned(Node) and (Node.Key>aSize) do begin
        OtherNode:=Node.Predecessor;
        if assigned(OtherNode) and (OtherNode.Key>=aSize) then begin
         Node:=OtherNode;
        end else begin
         break;
        end;
       end;
       break;
      end;
     end else if aSize>Node.Key then begin
      if assigned(Node.Right) then begin
       // If free block is too small, go to right
       Node:=Node.Right;
       continue;
      end else begin
       // If free block is too small and there is no right children node, then try to find suitable bigger but not too small free blocks
       while assigned(Node) and (Node.Key<aSize) do begin
        OtherNode:=Node.Successor;
        if assigned(OtherNode) then begin
         Node:=OtherNode;
        end else begin
         break;
        end;
       end;
       break;
      end;
     end else begin
      // Perfect match
      break;
     end;
    end;

    // Check block for if it fits to the desired alignment, otherwise search for a better suitable block
    if Alignment>1 then begin
     while assigned(Node) and (Node.Key>=aSize) do begin
      Range:=Node.Value;
      if ((Range.fOffset and (Alignment-1))<>0) and
         ((Range.fOffset+(Alignment-(Range.fOffset and (Alignment-1)))+aSize)>=(Range.fOffset+Range.fSize)) then begin
       // If free block is alignment-technical too small, then try to find with-alignment-technical suitable bigger blocks
       Node:=Node.Successor;
      end else begin
       break;
      end;
     end;
    end;

    // If a suitable free block was found, then allocate it
    if assigned(Node) and (Node.Key>=aSize) then begin

     Range:=Node.Value;

     RangeBeginOffset:=Range.fOffset;

     RangeEndOffset:=RangeBeginOffset+Range.fSize;

{$if false}

     // Prefer to allocate from the end of the range
     PayloadBeginOffset:=RangeEndOffset-aSize;
     if (Alignment>1) and ((PayloadBeginOffset and (Alignment-1))<>0) then begin
      dec(PayloadBeginOffset,PayloadBeginOffset and (Alignment-1));
      if PayloadBeginOffset<RangeBeginOffset then begin
       PayloadBeginOffset:=RangeBeginOffset; // For just to be sure
      end;
     end;

{$else}

     // Prefer to allocate from the beginning of the range
     PayloadBeginOffset:=RangeBeginOffset;
     if (Alignment>1) and ((PayloadBeginOffset and (Alignment-1))<>0) then begin
      inc(PayloadBeginOffset,Alignment-(PayloadBeginOffset and (Alignment-1)));
     end;

{$ifend}

     PayloadEndOffset:=PayloadBeginOffset+aSize;

     if (PayloadBeginOffset<PayloadEndOffset) and
        (PayloadEndOffset<=RangeEndOffset) then begin

      Range.Update(PayloadBeginOffset,PayloadEndOffset-PayloadBeginOffset,Alignment,TpvBufferRangeAllocator.TRange.TAllocationType.Allocated);

      result:=Range.fOffset;

      inc(fAllocated,Range.fSize);

      if RangeBeginOffset<PayloadBeginOffset then begin
       TpvBufferRangeAllocator.TRange.Create(self,RangeBeginOffset,PayloadBeginOffset-RangeBeginOffset,1,TpvBufferRangeAllocator.TRange.TAllocationType.Free);
      end;

      if PayloadEndOffset<RangeEndOffset then begin
       TpvBufferRangeAllocator.TRange.Create(self,PayloadEndOffset,RangeEndOffset-PayloadEndOffset,1,TpvBufferRangeAllocator.TRange.TAllocationType.Free);
      end;

      exit;

     end;

    end;

    // Otherwise, try to resize the buffer
    result:=fCapacity;
    inc(fCapacity,aSize);
    if assigned(fOnResize) then begin
     fOnResize(self,fCapacity);
    end;
    Node:=fOffsetRedBlackTree.RightMost;
    if assigned(Node) and assigned(Node.Value) and (Node.Value.fAllocationType=TpvBufferRangeAllocator.TRange.TAllocationType.Free) then begin
     Node.Value.Update(Node.Value.fOffset,(result+aSize)-Node.Value.fOffset,1,TpvBufferRangeAllocator.TRange.TAllocationType.Free);
    end else begin
     TpvBufferRangeAllocator.TRange.Create(self,result,aSize,1,TpvBufferRangeAllocator.TRange.TAllocationType.Free);
    end;

   until false;

  finally
   fLock.Release;
  end;

 end else begin

  result:=-1;

 end;

end;

function TpvBufferRangeAllocator.Release(const aOffset:TpvInt64;const aSize:TpvInt64=-1):Boolean;
var Node,OtherNode:TRangeRedBlackTree.TNode;
    Range,OtherRange:TRange;
    TempOffset,TempSize:TpvInt64;
begin

 result:=false;

 fLock.Acquire;
 try

  Node:=fOffsetRedBlackTree.Find(aOffset);
  if assigned(Node) then begin

   Range:=Node.Value;
   if Range.fAllocationType<>TpvBufferRangeAllocator.TRange.TAllocationType.Free then begin

    dec(fAllocated,Range.fSize);

    // Freeing including coalescing free blocks
    while assigned(Node) do begin

     // Coalescing previous free block with current block
     OtherNode:=Range.fOffsetRedBlackTreeNode.Predecessor;
     if assigned(OtherNode) and (OtherNode.Value.fAllocationType=TpvBufferRangeAllocator.TRange.TAllocationType.Free) then begin
      OtherRange:=OtherNode.Value;
      TempOffset:=OtherRange.fOffset;
      TempSize:=(Range.fOffset+Range.fSize)-TempOffset;
      OtherRange.Update(TempOffset,TempSize,1,TpvBufferRangeAllocator.TRange.TAllocationType.Free);
      FreeAndNil(Range);
      Range:=OtherRange;
      Node:=OtherNode;
      continue;
     end;

     // Coalescing current block with next free block
     OtherNode:=Range.fOffsetRedBlackTreeNode.Successor;
     if assigned(OtherNode) and (OtherNode.Value.fAllocationType=TpvBufferRangeAllocator.TRange.TAllocationType.Free) then begin
      OtherRange:=OtherNode.Value;
      TempOffset:=Range.fOffset;
      TempSize:=(OtherRange.fOffset+OtherRange.fSize)-TempOffset;
      Range.Update(TempOffset,TempSize,1,TpvBufferRangeAllocator.TRange.TAllocationType.Free);
      FreeAndNil(OtherRange);
      continue;
     end;

     if Range.fAllocationType<>TpvBufferRangeAllocator.TRange.TAllocationType.Free then begin
      // Mark block as free
      Range.Update(Range.fOffset,Range.fSize,1,TpvBufferRangeAllocator.TRange.TAllocationType.Free);
     end;
     break;

    end;

    result:=true;

   end;

  end;

 finally
  fLock.Release;
 end;

end;

function TpvBufferRangeAllocator.AllocateBufferRange(const aSize:TpvInt64;const aAlignment:TpvInt64):TBufferRange;
begin
 result.Offset:=Allocate(aSize,aAlignment);
 result.Size:=aSize;
 result.Alignment:=aAlignment;
end;

// Use it "ONLY" in combination with defragmentation, since it is not a reallocation, just a normal allocation with checking if the offset has changed!
function TpvBufferRangeAllocator.AllocateBufferRangeWithOffsetChangeCheck(var aBufferRange:TBufferRange):boolean;
var OldOffset:TpvInt64;
begin
 if (aBufferRange.Offset>=0) and (aBufferRange.Size>0) then begin
  OldOffset:=aBufferRange.Offset;
  aBufferRange.Offset:=Allocate(aBufferRange.Size);
  result:=OldOffset<>aBufferRange.Offset;
 end else begin
  result:=false; 
 end;
end;

procedure TpvBufferRangeAllocator.ReleaseBufferRange(const aBufferRange:TBufferRange);
begin
 if (aBufferRange.Offset>=0) and (aBufferRange.Size>0) then begin
  Release(aBufferRange.Offset,aBufferRange.Size);
 end;
end;

procedure TpvBufferRangeAllocator.ReleaseBufferRangeAndNil(var aBufferRange:TBufferRange);
begin
 if (aBufferRange.Offset>=0) and (aBufferRange.Size>0) then begin
  Release(aBufferRange.Offset,aBufferRange.Size);
 end;
 aBufferRange.Offset:=-1;
 aBufferRange.Size:=0;
 aBufferRange.Alignment:=0;
end;

// Calculate fragmentation factor 
function TpvBufferRangeAllocator.CalculateFragmentationFactor:TpvDouble;
var TotalFreeMemory,LargestFreeBlock:TpvInt64;
    Node:TRangeRedBlackTree.TNode;
    Range:TRange;
begin
 fLock.Acquire;
 try
  TotalFreeMemory:=0;
  LargestFreeBlock:=0;
  Node:=fOffsetRedBlackTree.LeftMost;
  while assigned(Node) do begin
   Range:=Node.Value;
   if assigned(Range) and (Range.fAllocationType=TpvBufferRangeAllocator.TRange.TAllocationType.Free) then begin
    inc(TotalFreeMemory,Range.fSize);
    if LargestFreeBlock<Range.fSize then begin
     LargestFreeBlock:=Range.fSize;
    end;
   end;
   Node:=Node.Successor;
  end;
  if TotalFreeMemory=0 then begin
   result:=0.0;
  end else begin
   result:=(TotalFreeMemory-LargestFreeBlock)/TotalFreeMemory;
  end;
 finally
  fLock.Release;
 end;
end;

function TpvBufferRangeAllocator.Defragment(const aMove:TOnDefragmentMove):Boolean;
type TNodes=array of TRangeRedBlackTree.TNode;
var Index,CountAllocatedNodes:TpvSizeInt;
    AllocatedNodes:TNodes;
    Node,NextNode:TRangeRedBlackTree.TNode;
    OriginalOffset,Offset,TotalSize,Alignment:TpvInt64;
begin

 result:=false;

 fLock.Acquire;
 try

  AllocatedNodes:=nil;
  try

   // Collect allocated nodes, get total size and free all free nodes 
   TotalSize:=0;
   CountAllocatedNodes:=0;
   Node:=fOffsetRedBlackTree.LeftMost;
   while assigned(Node) do begin
    NextNode:=Node.Successor;
    if assigned(Node.Value) then begin 
     Offset:=Node.Value.fOffset+Node.Value.fSize;
     if TotalSize<Offset then begin
      TotalSize:=Offset;
     end;
     if Node.Value.fAllocationType=TpvBufferRangeAllocator.TRange.TAllocationType.Free then begin
      Node.Value.Free;
     end else begin
      if length(AllocatedNodes)<=CountAllocatedNodes then begin
       SetLength(AllocatedNodes,(CountAllocatedNodes+1)+((CountAllocatedNodes+1) shr 1));
      end;
      AllocatedNodes[CountAllocatedNodes]:=Node;
      inc(CountAllocatedNodes);
     end;
    end;
    Node:=NextNode;
   end;

   // Finalize allocated nodes array size
   SetLength(AllocatedNodes,CountAllocatedNodes);

   // Assign new offsets, create free nodes for the gaps between the allocated nodes while checking and correcting the alignment, and
   // move the data if the offset has changed
   Offset:=0;
   for Index:=0 to CountAllocatedNodes-1 do begin
    Node:=AllocatedNodes[Index];
    OriginalOffset:=Node.Value.fOffset;
    Alignment:=Node.Value.fAlignment;
    if (Alignment>1) and ((Offset and (Alignment-1))<>0) then begin
     inc(Offset,Alignment-(Offset and (Alignment-1)));
    end;
    if Offset<>Node.Value.fOffset then begin
     if OriginalOffset<Offset then begin
      TpvBufferRangeAllocator.TRange.Create(self,OriginalOffset,Offset-OriginalOffset,1,TpvBufferRangeAllocator.TRange.TAllocationType.Free);
     end;
     result:=true;
     if assigned(aMove) then begin
      aMove(self,Node.Value.fOffset,Offset,Node.Value.fSize);
     end;
     Node.Value.Update(Offset,Node.Value.fSize,1,Node.Value.fAllocationType);
    end;
    inc(Offset,Node.Value.fSize);
   end;

   // Create new free node at the end
   if Offset<TotalSize then begin
    TpvBufferRangeAllocator.TRange.Create(self,Offset,TotalSize-Offset,1,TpvBufferRangeAllocator.TRange.TAllocationType.Free);
   end;
    
  finally
   AllocatedNodes:=nil;
  end;

 finally
  fLock.Release;
 end;

end;

end.