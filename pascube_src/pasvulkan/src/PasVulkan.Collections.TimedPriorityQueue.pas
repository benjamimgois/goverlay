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
unit PasVulkan.Collections.TimedPriorityQueue;
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
     Math,
     PasMP,
     PasVulkan.Types,
     PasVulkan.Math;

type EpvTimedPriorityQueue=class(Exception);

     { TpvTimedPriorityQueue }
     TpvTimedPriorityQueue<T>=class
      public
       const K=4; // 4-ary heap
             StateEmpty=0;
             StateUsed=1;
             StateDeleted=2;
       type THandle=TpvUInt64;
            PHandle=^THandle;
            THandleArray=array of THandle;
            TTime=TpvDouble;
            PTime=^TTime;
            TPriority=TpvInt32;
            PPriority=^TPriority;
            TData=T;
            PData=^TData;
            TNode=record
             Time:TTime;                  // Time
             Priority:TPriority;          // Priority (higher value = higher priority)
             Sequence:TpvUInt64;          // Stable tiebreaker
             Handle:THandle;              // Handle
             Data:TData;                  // User payload
             Dead:Boolean;                // Optional for lazy cancel
            end;
            PNode=^TNode;
            TNodeArray=array of TNode;
            TIndexArray=array of TpvSizeInt;
            TMapEntry=record
             Key:THandle;
             Value:TpvSizeInt;
             State:TpvUInt8;
            end;
            PMapEntry=^TMapEntry;
            TMapEntryArray=array of TMapEntry;
            TTraversalMethod=function(const aNode:PNode):boolean of object;
            TSerializationData=class // For serialization purposes, including handle management state for persistent queues
             private
              fHandleCounter:THandle;
              fHandleFreeList:THandleArray;
              fNodes:TNodeArray;
             public
              constructor Create; reintroduce;
              destructor Destroy; override;
             public
              property HandleCounter:THandle read fHandleCounter write fHandleCounter;
              property HandleFreeList:THandleArray read fHandleFreeList write fHandleFreeList;
              property Nodes:TNodeArray read fNodes write fNodes;
            end;
      private

       // Nodes storage (flat array, never moved)
       fNodes:TNodeArray;
       fNodeCount:TpvSizeInt;
       
       // Heap of indices into fNodes (only indices are moved during heap operations)
       fHeap:TIndexArray;
       fHeapPosition:TIndexArray;
       fCount:TpvSizeInt;
       fSequenceCounter:TpvUInt64;
       fHandleCounter:THandle;
       fUniqueHandles:Boolean;
       fBruteforceSearchForUnusedHandlesAtOverflow:Boolean;
       fDoubleFloatingPointCompatibility:Boolean;
       fHandleCounterOverflowed:Boolean;
       fExceptionOnHandleOverflow:Boolean;

       // Freelist of reusable node indices (stack)
       fFreeList:TIndexArray;
       fFreeTop:TpvSizeInt;

       // Freelist of reusable handles (stack)
       fHandleFreeList:THandleArray;
       fHandleFreeTop:TpvSizeInt;

       // Handle->Index open-addressing map (AoS)
       fMap:TMapEntryArray;
       fMapSize:TpvSizeInt;         // Capacity (power of two)
       fMapCount:TpvSizeInt;        // Total entries in map (excluding tombstones)
       fMapDeletedCount:TpvSizeInt; // Count of tombstones
       fMapSlotMask:TpvSizeInt;     // Mask (fMapSize-1)

       // Map methods
       class function MapHash(const aHandle:THandle):TpvUInt64; static; inline;
       procedure MapInit(const aCapacity:TpvSizeInt);
       procedure MapRehash(const aNewCapacity:TpvSizeInt);
       procedure MapEnsure; inline;
       procedure MapPut(const aHandle:THandle;const aIndex:TpvSizeInt);
       function MapTryGet(const aHandle:THandle;out aIndex:TpvSizeInt):Boolean;
       function MapContains(const aHandle:THandle):Boolean;
       procedure MapDelete(const aHandle:THandle);
       
       // Handle methods
       procedure PopulateHandleFreeListOnOverflow;
       function GetNextHandle:THandle; inline;

       // Heap methods
       procedure Resequence;
       procedure EnsureCapacity(const aNeed:TpvSizeInt);
       function Less(const aIndexA,aIndexB:TpvSizeInt):Boolean; inline;
       procedure Swap(const aIndexA,aIndexB:TpvSizeInt); inline;
       procedure SiftUp(aIndex:TpvSizeInt);
       procedure SiftDown(aIndex:TpvSizeInt);
       procedure RemoveAt(aIndex:TpvSizeInt);
       procedure BulkCleanDeadAndRebuildHeap;

      public

       constructor Create(const aInitialCapacity:TpvSizeInt=16;const aMapCapacity:TpvSizeInt=65536);
       destructor Destroy; override;
      
       procedure Clear;
      
       function Push(const aTime:TTime;const aPriority:TPriority;const aData:TData):THandle;
      
       function Cancel(const aHandle:THandle):Boolean;     // eager remove
       function MarkCancel(const aHandle:THandle):Boolean; // lazy mark

       function PeekEarliest(const aData:PData;const aTime:PTime;const aPriority:PPriority;const aHandle:PHandle):Boolean;
       function PopEarliest(const aData:PData;const aTime:PTime;const aPriority:PPriority;const aHandle:PHandle):Boolean;

       function PeekEarliestNode(out aNode:TNode):Boolean;
       function PopEarliestNode(out aNode:TNode):Boolean;

       function PeekEarliestData(out aData:TData):Boolean;
       function PopEarliestData(out aData:TData):Boolean;

       function PeekEarliestTime(out aTime:TTime):Boolean;
       function PopEarliestTime(out aTime:TTime):Boolean;

       function PeekEarliestPriority(out aPriority:TPriority):Boolean;
       function PopEarliestPriority(out aPriority:TPriority):Boolean;

       function Pop:Boolean; inline;

       // Traverse all entries in arbitrary order, skipping dead entries. Useful for usage with a garbage collector of data for
       // to mark these entries as live when these are used together with a scripting engine. 
       // Don't use when you need ordered traversal.
       function Traverse(const aTraversalMethod:TTraversalMethod):Boolean;

       procedure ShiftByTime(const aDeltaTime:TTime;const aRemoveNegativeTime:Boolean=false);

       procedure Serialize(const aSerializationData:TSerializationData);
       procedure Deserialize(const aSerializationData:TSerializationData);

      published

       property Count:TpvSizeInt read fCount;

       // When enabled, ensures that each handle is unique and never reused, even after cancellation or popping.
       // This is useful to prevent accidental cancellation of old handles that may be in use again at a later time,
       // for example at entity/component systems and similar use cases.
       property UniqueHandles:Boolean read fUniqueHandles write fUniqueHandles;

       // When enabled, performs a one-time bruteforce scan to find all unused handles when handle overflow occurs.
       // It will be never occur in practice, but this ensures that all possible handles are reused before raising 
       // an exception. It's just a theoretical safety measure, given that future systems have very large RAM sizes,
       // otherwise it would lead to a out-of-memory situation, when the memory required for the scan exceeds
       // available memory on today's systems.
       property BruteforceSearchForUnusedHandlesAtOverflow:Boolean read fBruteforceSearchForUnusedHandlesAtOverflow write fBruteforceSearchForUnusedHandlesAtOverflow;

       // When enabled, limits handle values to 53 bits to ensure compatibility with double-precision floating point 
       // representation. It's recommended to enable this when handles may be passed through JavaScript, POCA, Lua or 
       // other scripting engines that use double-precision floating point for their numeric values.
       property DoubleFloatingPointCompatibility:Boolean read fDoubleFloatingPointCompatibility write fDoubleFloatingPointCompatibility;

       // When enabled, immediately raises an exception when handle overflow occurs, otherwise it just wraps around. 
       // It is useful to catch programming errors where too many handles are created. But it would be never occur 
       // in practice, since even 53-bit handles allow for over 9 quadrillion unique handles, which is more than enough
       // for most applications in their complete runtime lifetime.
       property ExceptionOnHandleOverflow:Boolean read fExceptionOnHandleOverflow write fExceptionOnHandleOverflow;

       
     end;

implementation

{ TpvTimedPriorityQueue<T>.TSerializationData }

constructor TpvTimedPriorityQueue<T>.TSerializationData.Create;
begin
 inherited Create;
 fHandleCounter:=1;
 fHandleFreeList:=nil;
 fNodes:=nil;
end;

destructor TpvTimedPriorityQueue<T>.TSerializationData.Destroy;
begin
 fHandleFreeList:=nil;
 fNodes:=nil;
 inherited Destroy;
end;

{ TpvTimedPriorityQueue<T> }

// === Map ===============================================================

class function TpvTimedPriorityQueue<T>.MapHash(const aHandle:THandle):TpvUInt64; 
const Multiplier=TpvUInt64($9e3779b97f4a7c15); // 64-bit golden ratio
var Value:TpvUInt64;
begin
 Value:=aHandle*Multiplier;
 result:=Value xor (Value shr 33);
end;

procedure TpvTimedPriorityQueue<T>.MapInit(const aCapacity:TpvSizeInt);
var Index,Capacity:TpvSizeInt;
begin
 Capacity:=TpvSizeInt(RoundUpToPowerOfTwoSizeUInt(TpvSizeUInt(Max(16,aCapacity)))); // Ensure power of two
 SetLength(fMap,Capacity);
 for Index:=0 to length(fMap)-1 do begin
  fMap[Index].State:=StateEmpty;
 end;
 fMapSize:=Capacity;
 fMapSlotMask:=Capacity-1;
 fMapCount:=0;
 fMapDeletedCount:=0;
end;

procedure TpvTimedPriorityQueue<T>.MapRehash(const aNewCapacity:TpvSizeInt);
var OldMap:TMapEntryArray;
    Index:TpvSizeInt;
begin
 OldMap:=fMap;
 fMap:=nil; // Dereference old map, so that OldMap keeps the reference without conflict with MapInit and MapPut
 MapInit(aNewCapacity);
 for Index:=0 to length(OldMap)-1 do begin
  if OldMap[Index].State=StateUsed then begin
   MapPut(OldMap[Index].Key,OldMap[Index].Value);
  end;
 end;
end;

procedure TpvTimedPriorityQueue<T>.MapEnsure;
begin
 if (fMapSize>0) and (((fMapCount*10)>=(fMapSize*7))or (((fMapCount+fMapDeletedCount)*10)>=(fMapSize*8))) then begin
  MapRehash(TpvSizeInt(RoundUpToPowerOfTwoSizeUInt(TpvSizeUInt(fMapSize) shl 1)));
 end;
end;

procedure TpvTimedPriorityQueue<T>.MapPut(const aHandle:THandle;const aIndex:TpvSizeInt);
var Position,FirstDeleted:TpvSizeInt;
    HashKey:TpvUInt64;
    MapEntry:PMapEntry;
begin
 if fMapSize=0 then begin
  MapInit(16);
 end;
 MapEnsure;
 HashKey:=MapHash(aHandle);
 Position:=TpvSizeInt(HashKey and TpvUInt64(fMapSlotMask));
 FirstDeleted:=-1;
 while true do begin
  MapEntry:=@fMap[Position];
  if MapEntry^.State=StateEmpty then begin
   if FirstDeleted>=0 then begin
    Position:=FirstDeleted;
    MapEntry:=@fMap[Position];
   end;
   MapEntry^.Key:=aHandle;
   MapEntry^.Value:=aIndex;
   MapEntry^.State:=StateUsed;
   inc(fMapCount);
   exit;
  end else begin
   if MapEntry^.State=StateDeleted then begin
    if FirstDeleted<0 then begin
     FirstDeleted:=Position;
    end;
   end else if MapEntry^.Key=aHandle then begin
    MapEntry^.Value:=aIndex;
    exit;
   end;
   Position:=(Position+1) and fMapSlotMask;
  end;
 end;
end;

function TpvTimedPriorityQueue<T>.MapTryGet(const aHandle:THandle;out aIndex:TpvSizeInt):Boolean;
var Position:TpvSizeInt;
    HashKey:TpvUInt64;
    MapEntry:PMapEntry;
begin
 if fMapSize>0 then begin
  HashKey:=MapHash(aHandle);
  Position:=TpvSizeInt(HashKey and TpvUInt64(fMapSlotMask));
  while true do begin
   MapEntry:=@fMap[Position];
   if MapEntry^.State=StateEmpty then begin
    result:=false;
    exit;
   end else begin
    if (MapEntry^.State=StateUsed) and (MapEntry^.Key=aHandle) then begin
     aIndex:=MapEntry^.Value;
     result:=true;
     exit;
    end else begin
     Position:=(Position+1) and fMapSlotMask;
    end;
   end;
  end;
 end;
 result:=false;
end;

function TpvTimedPriorityQueue<T>.MapContains(const aHandle:THandle):Boolean;
var Position:TpvSizeInt;
    HashKey:TpvUInt64;
    MapEntry:PMapEntry;
begin
 if fMapSize>0 then begin
  HashKey:=MapHash(aHandle);
  Position:=TpvSizeInt(HashKey and TpvUInt64(fMapSlotMask));
  while true do begin
   MapEntry:=@fMap[Position];
   if MapEntry^.State=StateEmpty then begin
    result:=false;
    exit;
   end else begin
    if (MapEntry^.State=StateUsed) and (MapEntry^.Key=aHandle) then begin
     result:=true;
     exit;
    end else begin
     Position:=(Position+1) and fMapSlotMask;
    end;
   end;
  end;
 end;
 result:=false;
end;

procedure TpvTimedPriorityQueue<T>.MapDelete(const aHandle:THandle);
var Position:TpvSizeInt;
    HashKey:TpvUInt64;
    MapEntry:PMapEntry;
begin
 if fMapSize>0 then begin
  HashKey:=MapHash(aHandle);
  Position:=TpvSizeInt(HashKey and TpvUInt64(fMapSlotMask));
  while true do begin
   MapEntry:=@fMap[Position];
   if MapEntry^.State=StateEmpty then begin
    exit; // Not found
   end else begin
    if (MapEntry^.State=StateUsed) and (MapEntry^.Key=aHandle) then begin
     MapEntry^.State:=StateDeleted; // Tombstone
     dec(fMapCount);
     inc(fMapDeletedCount);
     exit;
    end else begin 
     Position:=(Position+1) and fMapSlotMask;
    end; 
   end; 
  end;
 end;
end; 

// === Handle ==========================================================

procedure TpvTimedPriorityQueue<T>.PopulateHandleFreeListOnOverflow;
var Handle,MaxHandle:THandle;
    FreeIndex:TpvSizeInt;
begin
 
 // One-time bruteforce scan to find all unused handles when overflow occurs
 // This populates the handle free list with gaps in the handle space
 
 // Determine maximum handle value based on compatibility mode
 if fDoubleFloatingPointCompatibility then begin
  MaxHandle:=TpvUInt64($001fffffffffffff); // 53-bit limit for double precision
 end else begin
  MaxHandle:=High(TpvUInt64); // Full 64-bit range
 end;

 // Scan entire handle space (skip handle 0 as it's reserved)
 Handle:=1;
 while Handle<=MaxHandle do begin
  
  // Check if this handle is not currently in use
  if not MapContains(Handle) then begin
   
   // Add unused handle to free list
   FreeIndex:=fHandleFreeTop;
   inc(fHandleFreeTop);
   if length(fHandleFreeList)<=fHandleFreeTop then begin
    SetLength(fHandleFreeList,fHandleFreeTop+((fHandleFreeTop+1) shr 1));
   end;
   fHandleFreeList[FreeIndex]:=Handle;

  end;

  // Next handle
  inc(Handle);
  
  // Skip zero on wraparound (should never happen in practice)
  if Handle=0 then begin
   break;
  end;

 end;

 // If no free handles found after scan, raise exception
 if fHandleFreeTop=0 then begin
  raise EpvTimedPriorityQueue.Create('No more handles available');
 end;

end;

function TpvTimedPriorityQueue<T>.GetNextHandle:THandle;
begin
 
 // Get current handle counter as result
 result:=fHandleCounter;
 
 // Increment handle counter, wrapping around if necessary 
 if fDoubleFloatingPointCompatibility then begin
  // When double floating point compatibility is requested, limit to 53 bits
  fHandleCounter:=(fHandleCounter+1) and TpvUInt64($001fffffffffffff);
 end else begin
  // Otherwise normal increment for full 64-bit range
  inc(fHandleCounter);
 end;

 // Skip zero handle, as it is reserved for invalid or non-existent handles
 if fHandleCounter=0 then begin
  fHandleCounter:=1;
 end;

end;

// === Heap ============================================================

procedure TpvTimedPriorityQueue<T>.Resequence;
var Index,NodeIndex:TpvSizeInt;
    Node:PNode;
    NewSequence:TpvUInt64;
begin
 
 // Reassign sequence numbers in heap order to maintain stable ordering
 // This prevents sequence counter overflow (though practically impossible)
 // Nodes in heap order get incrementing sequences, preserving their relative order
 NewSequence:=0;
 for Index:=0 to fCount-1 do begin
  NodeIndex:=fHeap[Index];
  Node:=@fNodes[NodeIndex];
  if not Node^.Dead then begin
   Node^.Sequence:=NewSequence;
   inc(NewSequence);
  end;
 end;

 // Reset sequence counter to continue from where we left off
 fSequenceCounter:=NewSequence;

end;

procedure TpvTimedPriorityQueue<T>.EnsureCapacity(const aNeed:TpvSizeInt);
var NewCapacity,OldCapacity:TpvSizeInt;
begin
 if length(fNodes)<aNeed then begin
  OldCapacity:=length(fNodes);
  NewCapacity:=RoundUpToPowerOfTwo64(Max(16,Max(OldCapacity,aNeed)));
  SetLength(fNodes,NewCapacity);
  SetLength(fHeap,NewCapacity);
  SetLength(fHeapPosition,NewCapacity);
  SetLength(fFreeList,NewCapacity);
  if NewCapacity>OldCapacity then begin
   FillChar(fHeapPosition[OldCapacity],(NewCapacity-OldCapacity)*SizeOf(TpvSizeInt),#$ff); // Initialize to -1
  end;
 end;
end;

function TpvTimedPriorityQueue<T>.Less(const aIndexA,aIndexB:TpvSizeInt):Boolean;
var NodeA,NodeB:PNode;
begin
 NodeA:=@fNodes[fHeap[aIndexA]];
 NodeB:=@fNodes[fHeap[aIndexB]];
 if NodeA^.Time<>NodeB^.Time then begin
  result:=NodeA^.Time<NodeB^.Time; // Earlier time means higher priority
 end else begin
  if NodeA^.Priority<>NodeB^.Priority then begin
   result:=NodeA^.Priority>NodeB^.Priority; // Higher priority value means higher priority
  end else begin
   result:=NodeA^.Sequence<NodeB^.Sequence;
  end;
 end;
end;

procedure TpvTimedPriorityQueue<T>.Swap(const aIndexA,aIndexB:TpvSizeInt);
var TempIndex:TpvSizeInt;
begin
 TempIndex:=fHeap[aIndexA];
 fHeap[aIndexA]:=fHeap[aIndexB];
 fHeap[aIndexB]:=TempIndex;
 // keep O(1) cancel mapping valid
 fHeapPosition[fHeap[aIndexA]]:=aIndexA;
 fHeapPosition[fHeap[aIndexB]]:=aIndexB;
end;

procedure TpvTimedPriorityQueue<T>.SiftUp(aIndex:TpvSizeInt);
var ParentIndex:TpvSizeInt;
begin
 while aIndex>0 do begin
  ParentIndex:=(aIndex-1) div K;
  if Less(aIndex,ParentIndex) then begin
   Swap(aIndex,ParentIndex);
   aIndex:=ParentIndex;
  end else begin 
   break;
  end;
 end;
end;

procedure TpvTimedPriorityQueue<T>.SiftDown(aIndex:TpvSizeInt);
var Child1,Child2,Child3,Child4,MinimumIndex:TpvSizeInt;
begin
 
 // K-ary heap sift-down
 while true do begin
  
  // Calculate first child index
  Child1:=(aIndex*K)+1;
  
  // If no children (out of bounds), exit
  if Child1>=fCount then begin

   break;

  end else begin

   // Find smallest child
   MinimumIndex:=Child1;
   Child2:=Child1+1;
   if (Child2<fCount) and Less(Child2,MinimumIndex) then begin
    MinimumIndex:=Child2;
   end;
   Child3:=Child1+2;
   if (Child3<fCount) and Less(Child3,MinimumIndex) then begin
    MinimumIndex:=Child3;
   end;
   Child4:=Child1+3;
   if (Child4<fCount) and Less(Child4,MinimumIndex) then begin
    MinimumIndex:=Child4;
   end;

   // Compare parent vs smallest child - only swap if child is smaller
   if Less(MinimumIndex,aIndex) then begin
    Swap(aIndex,MinimumIndex);
    aIndex:=MinimumIndex;
   end else begin
    break;
   end;

  end; 

 end;

end;

procedure TpvTimedPriorityQueue<T>.RemoveAt(aIndex:TpvSizeInt);
{$if false}
// More efficient version deciding direction only once. TODO: Verify correctness
var LastIndex,NodeIndex,ParentIndex,MoveIndex,FreeIndex:TpvSizeInt;
    Node:PNode;
begin
 LastIndex:=fCount-1;
 NodeIndex:=fHeap[aIndex];
 Node:=@fNodes[NodeIndex];

 // Remove handle from map
 MapDelete(Node^.Handle);

 // Add handle to handle free list
 FreeIndex:=fHandleFreeTop;
 inc(fHandleFreeTop);
 if length(fHandleFreeList)<=fHandleFreeTop then begin
  SetLength(fHandleFreeList,fHandleFreeTop+((fHandleFreeTop+1) shr 1));
 end;
 fHandleFreeList[FreeIndex]:=Node^.Handle;

 if aIndex<>LastIndex then begin
  // Move last heap entry into the hole at aIndex
  fHeap[aIndex]:=fHeap[LastIndex];
  fHeapPosition[fHeap[aIndex]]:=aIndex;

  // Shrink heap
  dec(fCount);

  // Decide direction once
  MoveIndex:=aIndex;
  if MoveIndex>0 then begin
   ParentIndex:=(MoveIndex-1) div K;
   if Less(MoveIndex,ParentIndex) then begin
    // Key is smaller than parent, so it can only move up
    SiftUp(MoveIndex);
   end else begin
    // Otherwise it can only move down
    SiftDown(MoveIndex);
   end;
  end else begin
   // At root, can only move down
   SiftDown(MoveIndex);
  end;

 end else begin
  // Removing the last element
  dec(fCount);
 end;

 // Return node slot to freelist
 fHeapPosition[NodeIndex]:=-1;
 
 // Clear tombstone mark for reuse
 Node^.Dead:=false;

 // Add node index to free list
 FreeIndex:=fFreeTop;
 inc(fFreeTop);
 if length(fFreeList)<=fFreeTop then begin
  SetLength(fFreeList,fFreeTop+((fFreeTop+1) shr 1));
 end;
 fFreeList[FreeIndex]:=NodeIndex;

 // Release managed fields early
 Finalize(Node^.Data);
 FillChar(Node^.Data,SizeOf(TData),#0);

end;
{$else}
// More straightforward but less efficient version
var LastIndex,NodeIndex,FreeIndex:TpvSizeInt;
    Node:PNode;
begin
 
 LastIndex:=fCount-1;
 NodeIndex:=fHeap[aIndex];
 Node:=@fNodes[NodeIndex];

 // Remove handle from map
 MapDelete(Node^.Handle);

 // Add handle to handle free list
 FreeIndex:=fHandleFreeTop;
 inc(fHandleFreeTop);
 if length(fHandleFreeList)<=fHandleFreeTop then begin
  SetLength(fHandleFreeList,fHandleFreeTop+((fHandleFreeTop+1) shr 1));
 end;
 fHandleFreeList[FreeIndex]:=Node^.Handle;

 if aIndex<>LastIndex then begin
  fHeap[aIndex]:=fHeap[LastIndex];
  fHeapPosition[fHeap[aIndex]]:=aIndex;
  dec(fCount);
  SiftDown(aIndex);
  SiftUp(aIndex);
 end else begin
  dec(fCount);
 end;
 
 // Return node slot to freelist
 fHeapPosition[NodeIndex]:=-1;

 // Clear tombstone mark for reuse
 Node^.Dead:=false; 

 // Add node index to free list
 FreeIndex:=fFreeTop;
 inc(fFreeTop);
 if length(fFreeList)<=fFreeTop then begin
  SetLength(fFreeList,fFreeTop+((fFreeTop+1) shr 1));
 end;
 fFreeList[FreeIndex]:=NodeIndex;

 // Release managed fields early
 Finalize(Node^.Data);
 FillChar(Node^.Data,SizeOf(TData),#0);

end;
{$ifend}

procedure TpvTimedPriorityQueue<T>.BulkCleanDeadAndRebuildHeap;
var Index,LiveCount,NodeIndex,FreeIndex:TpvSizeInt;
    Node:PNode;
begin

 // Compact live entries in-place at the front of fHeap
 LiveCount:=0;
 for Index:=0 to fCount-1 do begin

  // Get node index from heap
  NodeIndex:=fHeap[Index];
 
  // Get node pointer
  Node:=@fNodes[NodeIndex];
  
  // Check if node is marked dead
  if Node^.Dead then begin

   // Remove dead entry in bulk: drop handle, finalize payload, put on freelist
   MapDelete(Node^.Handle);

   // Add handle to handle free list
   FreeIndex:=fHandleFreeTop;
   inc(fHandleFreeTop);
   if length(fHandleFreeList)<=fHandleFreeTop then begin
    SetLength(fHandleFreeList,fHandleFreeTop+((fHandleFreeTop+1) shr 1));
   end;
   fHandleFreeList[FreeIndex]:=Node^.Handle;   
   
   // Release managed fields early
   Finalize(Node^.Data);
   FillChar(Node^.Data,SizeOf(TData),#0);
   
   // Clear tombstone mark for reuse
   Node^.Dead:=false; 

   // Mark heap position as free
   fHeapPosition[NodeIndex]:=-1;

   // Add node index to free list
   FreeIndex:=fFreeTop;
   inc(fFreeTop);
   if length(fFreeList)<=fFreeTop then begin
    SetLength(fFreeList,fFreeTop+((fFreeTop+1) shr 1));
   end;
   fFreeList[fFreeTop]:=NodeIndex;

  end else begin
   
   // Keep live entry
   fHeap[LiveCount]:=NodeIndex;
   inc(LiveCount);

  end;

 end;

 // Update heap count to number of live entries
 fCount:=LiveCount;

 // Rebuild positions for live nodes
 for Index:=0 to fCount-1 do begin
  fHeapPosition[fHeap[Index]]:=Index;
 end;

 // Bottom-up heapify for K-ary heap in O(n)
 // Last internal node is (fCount-2) div K; loop down to 0
 if fCount>1 then begin
  for Index:=((fCount-2) div K) downto 0 do begin
   SiftDown(Index);
  end;
 end;

end;

// === Public ==========================================================

constructor TpvTimedPriorityQueue<T>.Create(const aInitialCapacity:TpvSizeInt;const aMapCapacity:TpvSizeInt);
var InitialCapacity:TpvSizeInt;
begin
 inherited Create;
 InitialCapacity:=Max(16,aInitialCapacity);
 fNodes:=nil;
 fHeap:=nil;
 fHeapPosition:=nil;
 fFreeList:=nil;
 SetLength(fNodes,InitialCapacity);
 SetLength(fHeap,InitialCapacity);
 SetLength(fHeapPosition,InitialCapacity);
 SetLength(fFreeList,InitialCapacity);
 SetLength(fHandleFreeList,InitialCapacity);
 FillChar(fHeapPosition[0],InitialCapacity*SizeOf(TpvSizeInt),#$ff); // Initialize to -1
 fNodeCount:=0;
 fCount:=0;
 fSequenceCounter:=0;
 fHandleCounter:=1;
 fUniqueHandles:=false;
 fBruteforceSearchForUnusedHandlesAtOverflow:=false;
 fDoubleFloatingPointCompatibility:=false;
 fHandleCounterOverflowed:=false;
 fExceptionOnHandleOverflow:=true;
 fFreeTop:=0;
 fHandleFreeTop:=0;
 fMap:=nil;
 MapInit(aMapCapacity);
end;

destructor TpvTimedPriorityQueue<T>.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TpvTimedPriorityQueue<T>.Clear;
begin
 fNodes:=nil;
 fHeap:=nil;
 fHeapPosition:=nil;
 fFreeList:=nil;
 fHandleFreeList:=nil;
 fNodeCount:=0;
 fCount:=0;
 fSequenceCounter:=0;
 fHandleCounter:=1;
 fHandleCounterOverflowed:=false;
 fFreeTop:=0;
 fHandleFreeTop:=0;
 fMap:=nil;
 fMapSize:=0;
 fMapCount:=0;
 fMapDeletedCount:=0;
 fMapSlotMask:=0; 
end;

function TpvTimedPriorityQueue<T>.Push(const aTime:TTime;const aPriority:TPriority;const aData:TData):THandle;
var HeapIndex,NodeIndex:TpvSizeInt;
    Node:PNode;
begin

 // Reuse a freed node slot if available
 if fFreeTop>0 then begin
  dec(fFreeTop);
  NodeIndex:=fFreeList[fFreeTop];
 end else begin
  EnsureCapacity(fNodeCount+1);
  NodeIndex:=fNodeCount;
  inc(fNodeCount);
 end;

 // Get handle: reuse from free list or allocate new
 if fUniqueHandles then begin

  // Unique handles requested: always allocate new handle, unless overflowed

  // First check for previous overflow 
  if fHandleCounterOverflowed then begin

   // Handle counter has overflowed before

   // When bruteforce search is enabled, do one-time population of handle free list
   if fBruteforceSearchForUnusedHandlesAtOverflow then begin

    // Do one-time bruteforce scan to populate handle free list with all gaps
    // After this, we just use the free list normally (no more bruteforce)
    PopulateHandleFreeListOnOverflow;

    // Disable bruteforce flag now that free list is populated
    fBruteforceSearchForUnusedHandlesAtOverflow:=false;

   end;

   // Try to get handle from free list (populated by bruteforce or regular frees)
   if fHandleFreeTop>0 then begin

    // Get handle from free list
    dec(fHandleFreeTop);
    result:=fHandleFreeList[fHandleFreeTop];

   end else begin

    // Check if we should raise exception on overflow 
    if fExceptionOnHandleOverflow then begin

     // Raise exception on handle overflow  

     // No more handles available (free list exhausted and counter overflowed)
     raise EpvTimedPriorityQueue.Create('No more unique handles available');

    end else begin
     
     // Otherwise allocate new handle normally (will wrap around)
     result:=GetNextHandle;

    end; 

   end;

  end else begin
  
   // No previous overflow: allocate new handle normally
   result:=GetNextHandle;

   // Check for overflow and set flag
   if fHandleCounter=1 then begin
    fHandleCounterOverflowed:=true;
   end; 

  end; 

 end else begin 

  // Non-unique handles: try to reuse from free list first

  // Reuse handle from free list if available
  if fHandleFreeTop>0 then begin

   // Get handle from free list
   dec(fHandleFreeTop);
   result:=fHandleFreeList[fHandleFreeTop];

  end else begin

   // Allocate new handle
   result:=GetNextHandle;
   
   // Wrap around check, when handle counter overflows, raise exception, 
   // since free list is also exhausted, so there are no more handles available
   if fHandleCounter=1 then begin
    if fExceptionOnHandleOverflow then begin
     raise EpvTimedPriorityQueue.Create('No more handles available');
    end else begin
     // Just wrap around (non-unique handles)
     // Note: this will eventually reuse old handles that may still be in use
     // if the user keeps creating new handles without reusing old ones.
    end;
   end;

  end;

 end;

 // Initialize node
 Node:=@fNodes[NodeIndex];
 Node^.Time:=aTime;
 Node^.Priority:=aPriority;
 Node^.Sequence:=fSequenceCounter;
 inc(fSequenceCounter);
 Node^.Handle:=result;
 Node^.Data:=aData;
 Node^.Dead:=false;

 // Insert into map
 MapPut(result,NodeIndex);

 // Insert into heap
 HeapIndex:=fCount;
 fHeap[HeapIndex]:=NodeIndex;
 fHeapPosition[NodeIndex]:=HeapIndex;
 inc(fCount);
 SiftUp(HeapIndex);

 // Resequence if sequence counter is about to overflow, to keep stable tiebreaking working.
 // But it will never happen in practice, as it would require billions of insertions per second for years.
 // But we do it for correctness and completeness, just in case.  
 if fSequenceCounter>=TpvUInt64($fffffffffffffffe) then begin
  Resequence;
 end;

end;

function TpvTimedPriorityQueue<T>.Cancel(const aHandle:THandle):Boolean;
var NodeIndex,HeapIndex:TpvSizeInt;
begin
 if MapTryGet(aHandle,NodeIndex) then begin
  HeapIndex:=fHeapPosition[NodeIndex];
  result:=(HeapIndex>=0) and (HeapIndex<fCount) and (fHeap[HeapIndex]=NodeIndex);
  if result then begin
   RemoveAt(HeapIndex);
  end;
 end else begin
  result:=false;
 end;
end;

function TpvTimedPriorityQueue<T>.MarkCancel(const aHandle:THandle):Boolean;
var NodeIndex:TpvSizeInt;
begin
 if MapTryGet(aHandle,NodeIndex) then begin
  fNodes[NodeIndex].Dead:=true;
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TpvTimedPriorityQueue<T>.PeekEarliest(const aData:PData;const aTime:PTime;const aPriority:PPriority;const aHandle:PHandle):Boolean;
var Node:PNode;
begin
 while (fCount>0) and fNodes[fHeap[0]].Dead do begin
  RemoveAt(0);
 end;
 result:=fCount>0;
 if result then begin
  Node:=@fNodes[fHeap[0]];
  if assigned(aData) then begin
   aData^:=Node^.Data;
  end;
  if assigned(aTime) then begin
   aTime^:=Node^.Time;
  end;
  if assigned(aPriority) then begin
   aPriority^:=Node^.Priority;
  end;
  if assigned(aHandle) then begin
   aHandle^:=Node^.Handle;
  end;
 end;
end;

function TpvTimedPriorityQueue<T>.PopEarliest(const aData:PData;const aTime:PTime;const aPriority:PPriority;const aHandle:PHandle):Boolean;
var Node:PNode;
begin
 while fCount>0 do begin
  Node:=@fNodes[fHeap[0]];
  if Node^.Dead then begin
   RemoveAt(0);
  end else begin
   if assigned(aData) then begin
    aData^:=Node^.Data;
   end;
   if assigned(aTime) then begin
    aTime^:=Node^.Time;
   end;
   if assigned(aPriority) then begin
    aPriority^:=Node^.Priority;
   end;
   if assigned(aHandle) then begin
    aHandle^:=Node^.Handle;
   end;
   RemoveAt(0);  
   result:=true;
   exit;
  end;
 end;
 result:=false;
end;

function TpvTimedPriorityQueue<T>.PeekEarliestNode(out aNode:TNode):Boolean;
var Node:PNode;
begin
 while (fCount>0) and fNodes[fHeap[0]].Dead do begin
  RemoveAt(0);
 end;
 result:=fCount>0;
 if result then begin
  Node:=@fNodes[fHeap[0]];
  aNode:=Node^;
 end;
end;

function TpvTimedPriorityQueue<T>.PopEarliestNode(out aNode:TNode):Boolean;
var Node:PNode;
begin
 while fCount>0 do begin
  Node:=@fNodes[fHeap[0]];
  if Node^.Dead then begin
   RemoveAt(0);
  end else begin
   aNode:=Node^;
   RemoveAt(0);
   result:=true;
   exit;
  end;
 end;
 result:=false;
end;

function TpvTimedPriorityQueue<T>.PeekEarliestData(out aData:TData):Boolean;
var Node:PNode;
begin
 while (fCount>0) and fNodes[fHeap[0]].Dead do begin
  RemoveAt(0);
 end;
 result:=fCount>0;
 if result then begin
  Node:=@fNodes[fHeap[0]];
  aData:=Node^.Data;
 end;
end;

function TpvTimedPriorityQueue<T>.PopEarliestData(out aData:TData):Boolean;
var Node:PNode;
begin
 while fCount>0 do begin
  Node:=@fNodes[fHeap[0]];
  if Node^.Dead then begin
   RemoveAt(0);
  end else begin
   aData:=Node^.Data;
   RemoveAt(0);
   result:=true;
   exit;
  end;
 end;
 result:=false;
end; 

function TpvTimedPriorityQueue<T>.PeekEarliestTime(out aTime:TTime):Boolean;
var Node:PNode;
begin
 while (fCount>0) and fNodes[fHeap[0]].Dead do begin
  RemoveAt(0);
 end;
 result:=fCount>0;
 if result then begin
  Node:=@fNodes[fHeap[0]];
  aTime:=Node^.Time;
 end;
end;

function TpvTimedPriorityQueue<T>.PopEarliestTime(out aTime:TTime):Boolean;
var Node:PNode;
begin
 while fCount>0 do begin
  Node:=@fNodes[fHeap[0]];
  if Node^.Dead then begin
   RemoveAt(0);
  end else begin
   aTime:=Node^.Time;
   RemoveAt(0);
   result:=true;
   exit;
  end;
 end;
 result:=false; 
end; 

function TpvTimedPriorityQueue<T>.PeekEarliestPriority(out aPriority:TPriority):Boolean;
var Node:PNode;
begin
 while (fCount>0) and fNodes[fHeap[0]].Dead do begin
  RemoveAt(0);
 end;
 result:=fCount>0;
 if result then begin
  Node:=@fNodes[fHeap[0]];
  aPriority:=Node^.Priority;
 end;
end;

function TpvTimedPriorityQueue<T>.PopEarliestPriority(out aPriority:TPriority):Boolean;
var Node:PNode;
begin
 while fCount>0 do begin
  Node:=@fNodes[fHeap[0]];
  if Node^.Dead then begin
   RemoveAt(0);
  end else begin
   aPriority:=Node^.Priority;
   RemoveAt(0);
   result:=true;
   exit;
  end;
 end;
 result:=false;
end;

function TpvTimedPriorityQueue<T>.Pop:Boolean;
var Node:PNode;
begin
 while fCount>0 do begin
  Node:=@fNodes[fHeap[0]];
  if Node^.Dead then begin
   RemoveAt(0);
  end else begin
   RemoveAt(0);
   result:=true;
   exit;
  end;
 end;
 result:=false;
end;

function TpvTimedPriorityQueue<T>.Traverse(const aTraversalMethod:TTraversalMethod):Boolean;
var Index,NodeIndex:TpvSizeInt;
    Node:PNode;
begin
 result:=false;
 for Index:=0 to fCount-1 do begin
  NodeIndex:=fHeap[Index];
  Node:=@fNodes[NodeIndex];
  if not Node^.Dead then begin
   if aTraversalMethod(Node) then begin
    result:=true;
   end;
  end;
 end;
end;  

procedure TpvTimedPriorityQueue<T>.ShiftByTime(const aDeltaTime:TTime;const aRemoveNegativeTime:Boolean);
var Index,Expired:TpvSizeInt;
    Node:PNode;
begin
 
 if fCount>0 then begin

  // Adjust all times by the delta time 
  for Index:=0 to fCount-1 do begin
   Node:=@fNodes[fHeap[Index]];
   Node^.Time:=Node^.Time-aDeltaTime; 
  end;
 
  // Remove all nodes that are now in the past (time < 0.0) via lazy marking,
  // then clean them from the heap top until the earliest is in the future.
  // We use lazy marking first to avoid O(n log n) heap removals.
  if aRemoveNegativeTime then begin

   Expired:=0;
   for Index:=0 to fCount-1 do begin
    Node:=@fNodes[fHeap[Index]];
    if (not Node^.Dead) and (Node^.Time<0.0) then begin
     Node^.Dead:=true;
     inc(Expired);
    end;
   end;

   // If any expired nodes were found, clean them from the heap
   if Expired>0 then begin

    // If a significant portion of nodes are expired, do a bulk clean and rebuild the heap
    if Expired>(fCount shr 2) then begin

     BulkCleanDeadAndRebuildHeap;

    end else begin

     // Now clean the heap by removing all dead nodes at the top
     while (fCount>0) and fNodes[fHeap[0]].Dead do begin
      RemoveAt(0);
     end;

    end;

   end;

  end;

 end;

end; 

procedure TpvTimedPriorityQueue<T>.Serialize(const aSerializationData:TSerializationData);
var Index,LiveCount,NodeIndex:TpvSizeInt;
    Node:PNode;
begin

 // Clean dead nodes and rebuild heap to ensure only live nodes are serialized
 BulkCleanDeadAndRebuildHeap;

 // Serialize handle management state
 aSerializationData.fHandleCounter:=fHandleCounter;
 if fHandleFreeTop>0 then begin
  SetLength(aSerializationData.fHandleFreeList,fHandleFreeTop);
  Move(fHandleFreeList[0],aSerializationData.fHandleFreeList[0],fHandleFreeTop*SizeOf(THandle));
 end else begin
  aSerializationData.fHandleFreeList:=nil;
 end;

 // Serialize only live nodes in heap order (preserves sequence ordering)
 // First count live nodes
 LiveCount:=0;
 for Index:=0 to fCount-1 do begin
  NodeIndex:=fHeap[Index];
  Node:=@fNodes[NodeIndex];
  if not Node^.Dead then begin
   inc(LiveCount);
  end;
 end;

 // If any live nodes, copy them
 if LiveCount>0 then begin

  // Allocate space for live nodes
  SetLength(aSerializationData.fNodes,LiveCount);
  
  // Copy live nodes in heap order
  if LiveCount>0 then begin
   LiveCount:=0;
   for Index:=0 to fCount-1 do begin
    NodeIndex:=fHeap[Index];
    Node:=@fNodes[NodeIndex];
    if not Node^.Dead then begin
     // Copy element-wise because TData may contain managed types
     aSerializationData.fNodes[LiveCount]:=Node^;
     inc(LiveCount);
    end;
   end;
  end;

 end else begin
 
  // No live nodes
  aSerializationData.fNodes:=nil;

 end;

end;

procedure TpvTimedPriorityQueue<T>.Deserialize(const aSerializationData:TSerializationData);
var Index,LiveCount,NodeIndex,FreeIndex:TpvSizeInt;
    Node:PNode;
    SequenceCounter:TpvUInt64;
begin
 
 // Clear current state
 Clear;

 // Restore handle management state
 fHandleCounter:=aSerializationData.fHandleCounter;
 fHandleFreeTop:=length(aSerializationData.fHandleFreeList);
 if fHandleFreeTop>0 then begin
  SetLength(fHandleFreeList,fHandleFreeTop);
  Move(aSerializationData.fHandleFreeList[0],fHandleFreeList[0],fHandleFreeTop*SizeOf(THandle));
 end else begin
  fHandleFreeList:=nil;
 end;

 // Restore nodes
 fNodeCount:=length(aSerializationData.fNodes);
 if fNodeCount>0 then begin
  EnsureCapacity(fNodeCount);
  // Copy nodes element-wise because TData may contain managed types
  for Index:=0 to fNodeCount-1 do begin
   fNodes[Index]:=aSerializationData.fNodes[Index];
  end;
 end;

 // Initialize map with the appropriate estimated capacity
 MapInit(TpvSizeInt(RoundUpToPowerOfTwoSizeUInt(TpvSizeUInt(Max(16,fNodeCount shl 1)))));

 // Rebuild heap with only live (non-dead) nodes
 LiveCount:=0;
 SequenceCounter:=0;
 for Index:=0 to fNodeCount-1 do begin
  Node:=@fNodes[Index];
  if SequenceCounter<Node^.Sequence then begin
   SequenceCounter:=Node^.Sequence;
  end;
  if not Node^.Dead then begin
   // Add to heap
   fHeap[LiveCount]:=Index;
   fHeapPosition[Index]:=LiveCount;
   // Add to map
   MapPut(Node^.Handle,Index);
   inc(LiveCount);
  end else begin
   // Dead node: add to free list
   fHeapPosition[Index]:=-1;
   FreeIndex:=fFreeTop;
   inc(fFreeTop);
   if length(fFreeList)<=fFreeTop then begin
    SetLength(fFreeList,fFreeTop+((fFreeTop+1) shr 1));
   end;
   fFreeList[FreeIndex]:=Index;
  end;
 end;

 // Update heap count
 fCount:=LiveCount;

 // Update sequence counter
 fSequenceCounter:=SequenceCounter+1;

 // Reassign sequence numbers in heap order to maintain stable ordering
 // This prevents sequence counter overflow (though practically impossible)
 // Nodes in heap order get incrementing sequences, preserving their relative order
 Resequence;

 // Bottom-up heapify for K-ary heap in O(n)
 // Last internal node is (fCount-2) div K; loop down to 0
 if fCount>1 then begin
  for Index:=((fCount-2) div K) downto 0 do begin
   SiftDown(Index);
  end;
 end;

end;

end.
