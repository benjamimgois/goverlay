(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                       Version see PasVulkan.Framework.pas                  *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2026, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
 *    http://github.com/BeRo1985/pasvulkan                                    *
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
unit PasVulkan.HierarchicalGenerationArray;
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
     PasMP,
     PasVulkan.Types;

type

 { TpvHierarchicalGenerationArray }

 TpvHierarchicalGenerationArray=record
  public
   const BlockShift=6;
         BlockSize=1 shl BlockShift; // 64
         BlockMask=BlockSize-1;
    type TSizeIntDynamicArray=array of TpvSizeInt;
         TUInt64DynamicArrayDynamicArray=array of TpvUInt64DynamicArray;
  private
   fCount:TpvSizeInt;
   fLevelCount:TpvSizeInt;
   fLevelSizes:TSizeIntDynamicArray;
   fLevels:TUInt64DynamicArrayDynamicArray;
   procedure SyncFromBlock(var aMaster:TpvHierarchicalGenerationArray;const aLevel,aBlockIndex:TpvSizeInt;var aDirtyMin,aDirtyMax:TpvSizeInt);
  public
   procedure Initialize;
   procedure Finalize;
   procedure EnsureCapacity(const aCount:TpvSizeInt); // Ensure capacity for at least aCount elements, growing hierarchy as needed
   procedure Mark(const aIndex:TpvSizeInt;const aGeneration:TpvUInt64); // Mark a single element as dirty with the given generation (thread-safe for parent propagation via CAS)
   procedure MarkRange(const aMinIndex,aMaxIndex:TpvSizeInt;const aGeneration:TpvUInt64); // Mark a range of elements as dirty (inclusive min..max)
   procedure MarkAll(const aGeneration:TpvUInt64); // Mark all elements as dirty
   function GetGeneration(const aIndex:TpvSizeInt):TpvUInt64; // Get generation of a single element
   procedure SyncFrom(var aMaster:TpvHierarchicalGenerationArray;out aDirtyMin,aDirtyMax:TpvSizeInt); // Sync from master: walk hierarchy top-down, find dirty elements, update self, return dirty range
  public 
   property Count:TpvSizeInt read fCount;
   property Generation[const aIndex:TpvSizeInt]:TpvUInt64 read GetGeneration; default;
 end;

implementation

procedure TpvHierarchicalGenerationArray.Initialize;
begin
 fCount:=0;
 fLevelCount:=0;
 fLevelSizes:=nil;
 fLevels:=nil;
end;

procedure TpvHierarchicalGenerationArray.Finalize;
var LevelIndex:TpvSizeInt;
begin
 for LevelIndex:=0 to fLevelCount-1 do begin
  fLevels[LevelIndex]:=nil;
 end;
 fLevels:=nil;
 fLevelSizes:=nil;
 fCount:=0;
 fLevelCount:=0;
end;

procedure TpvHierarchicalGenerationArray.EnsureCapacity(const aCount:TpvSizeInt);
var LevelIndex,NewLevelCount,OldLevelCount,OldLevelSizeAtLevel,LevelSize,BlockIndex,ChildBase,ChildEnd,ChildIndex:TpvSizeInt;
    MaxGen:TpvUInt64;
    NeedRebuildParents:Boolean;
begin
 
 if fCount<aCount then begin
 
  // Calculate required level count
  NewLevelCount:=1;
  LevelSize:=aCount;
  while LevelSize>1 do begin
   LevelSize:=(LevelSize+BlockMask) shr BlockShift;
   inc(NewLevelCount);
  end;
 
  // Grow level arrays if needed
  OldLevelCount:=fLevelCount;
  NeedRebuildParents:=OldLevelCount<NewLevelCount;
  if NeedRebuildParents then begin
   SetLength(fLevelSizes,NewLevelCount);
   SetLength(fLevels,NewLevelCount);
   for LevelIndex:=OldLevelCount to NewLevelCount-1 do begin
    fLevelSizes[LevelIndex]:=0;
    fLevels[LevelIndex]:=nil;
   end;
  end;
  fLevelCount:=NewLevelCount;

  // Resize each level (level 0 = elements, higher = blocks)
  LevelSize:=aCount;
  for LevelIndex:=0 to fLevelCount-1 do begin
   if LevelSize>fLevelSizes[LevelIndex] then begin
    SetLength(fLevels[LevelIndex],LevelSize);
   end;
   fLevelSizes[LevelIndex]:=LevelSize;
   LevelSize:=(LevelSize+BlockMask) shr BlockShift;
  end;
  fCount:=aCount;

  // When new hierarchy levels were added, rebuild parent blocks from children
  // so that existing level 0 generations are correctly reflected in the new parents
  if NeedRebuildParents then begin
   for LevelIndex:=1 to fLevelCount-1 do begin
    for BlockIndex:=0 to fLevelSizes[LevelIndex]-1 do begin
     ChildBase:=BlockIndex shl BlockShift;
     ChildEnd:=ChildBase+BlockMask;
     if ChildEnd>=fLevelSizes[LevelIndex-1] then begin
      ChildEnd:=fLevelSizes[LevelIndex-1]-1;
     end;
     MaxGen:=0;
     for ChildIndex:=ChildBase to ChildEnd do begin
      if fLevels[LevelIndex-1][ChildIndex]>MaxGen then begin
       MaxGen:=fLevels[LevelIndex-1][ChildIndex];
      end;
     end;
     if fLevels[LevelIndex][BlockIndex]<MaxGen then begin
      fLevels[LevelIndex][BlockIndex]:=MaxGen;
     end;
    end;
   end;
  end;

 end;

end;

procedure TpvHierarchicalGenerationArray.Mark(const aIndex:TpvSizeInt;const aGeneration:TpvUInt64);
var LevelIndex,BlockIndex:TpvSizeInt;
    OldValue:TpvUInt64;
begin

 if (aIndex>=0) and (aIndex<fCount) then begin

  fLevels[0][aIndex]:=aGeneration;

  BlockIndex:=aIndex;

  for LevelIndex:=1 to fLevelCount-1 do begin

   BlockIndex:=BlockIndex shr BlockShift;

   // Atomic max: CAS loop ensures highest generation always wins
   repeat
    OldValue:=fLevels[LevelIndex][BlockIndex];
    if OldValue>=aGeneration then begin
     exit;
    end;
   until TPasMPInterlocked.CompareExchange(TPasMPUInt64(fLevels[LevelIndex][BlockIndex]),TPasMPUInt64(aGeneration),TPasMPUInt64(OldValue))=TPasMPUInt64(OldValue);

  end;

 end;

end;

procedure TpvHierarchicalGenerationArray.MarkRange(const aMinIndex,aMaxIndex:TpvSizeInt;const aGeneration:TpvUInt64);
var Index,LevelIndex,MinBlock,MaxBlock,BlockIndex:TpvSizeInt;
    OldValue:TpvUInt64;
begin

 if (aMinIndex>=0) and (aMaxIndex>=aMinIndex) and (aMaxIndex<fCount) then begin

  // Set all level 0 elements in range
  for Index:=aMinIndex to aMaxIndex do begin
   fLevels[0][Index]:=aGeneration;
  end;
 
  // Propagate up through hierarchy
  MinBlock:=aMinIndex;
  MaxBlock:=aMaxIndex;
  for LevelIndex:=1 to fLevelCount-1 do begin
   MinBlock:=MinBlock shr BlockShift;
   MaxBlock:=MaxBlock shr BlockShift;
   for BlockIndex:=MinBlock to MaxBlock do begin
    repeat
     OldValue:=fLevels[LevelIndex][BlockIndex];
     if OldValue>=aGeneration then begin
      break;
     end;
    until TPasMPInterlocked.CompareExchange(TPasMPUInt64(fLevels[LevelIndex][BlockIndex]),TPasMPUInt64(aGeneration),TPasMPUInt64(OldValue))=TPasMPUInt64(OldValue);
   end;
  end;

 end;

end;

procedure TpvHierarchicalGenerationArray.MarkAll(const aGeneration:TpvUInt64);
var LevelIndex,Index:TpvSizeInt;
begin
 for LevelIndex:=0 to fLevelCount-1 do begin
  for Index:=0 to fLevelSizes[LevelIndex]-1 do begin
   fLevels[LevelIndex][Index]:=aGeneration;
  end;
 end;
end;

function TpvHierarchicalGenerationArray.GetGeneration(const aIndex:TpvSizeInt):TpvUInt64;
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  result:=fLevels[0][aIndex];
 end else begin
  result:=0;
 end;
end;

procedure TpvHierarchicalGenerationArray.SyncFromBlock(var aMaster:TpvHierarchicalGenerationArray;const aLevel,aBlockIndex:TpvSizeInt;var aDirtyMin,aDirtyMax:TpvSizeInt);
var ChildBase,ChildEnd,ChildIndex:TpvSizeInt;
begin

 if aLevel<=1 then begin
  
  // Leaf level: children are individual elements at level 0
  ChildBase:=aBlockIndex shl BlockShift;
  ChildEnd:=ChildBase+BlockMask;
  if ChildEnd>=fCount then begin
   ChildEnd:=fCount-1;
  end;
  
  for ChildIndex:=ChildBase to ChildEnd do begin
   if fLevels[0][ChildIndex]<aMaster.fLevels[0][ChildIndex] then begin
    fLevels[0][ChildIndex]:=aMaster.fLevels[0][ChildIndex];
    if ChildIndex<aDirtyMin then begin
     aDirtyMin:=ChildIndex;
    end;
    if ChildIndex>aDirtyMax then begin
     aDirtyMax:=ChildIndex;
    end;
   end;
  end;

 end else begin

  // Interior level: children are blocks at level aLevel-1
  
  ChildBase:=aBlockIndex shl BlockShift;
  
  ChildEnd:=ChildBase+BlockMask;
  if ChildEnd>=fLevelSizes[aLevel-1] then begin
   ChildEnd:=fLevelSizes[aLevel-1]-1;
  end;

  for ChildIndex:=ChildBase to ChildEnd do begin
   if fLevels[aLevel-1][ChildIndex]<aMaster.fLevels[aLevel-1][ChildIndex] then begin
    SyncFromBlock(aMaster,aLevel-1,ChildIndex,aDirtyMin,aDirtyMax);
    fLevels[aLevel-1][ChildIndex]:=aMaster.fLevels[aLevel-1][ChildIndex];
   end;
  end;

 end;

end;

procedure TpvHierarchicalGenerationArray.SyncFrom(var aMaster:TpvHierarchicalGenerationArray;out aDirtyMin,aDirtyMax:TpvSizeInt);
var TopLevel,BlockIndex:TpvSizeInt;
begin
 
 aDirtyMin:=High(TpvSizeInt); 
 aDirtyMax:=-1;

 if (fCount<=0) or (fLevelCount<=0) then begin
  exit;
 end;

 if fLevelCount=1 then begin

  // Only level 0 exists, scan all elements directly
  for BlockIndex:=0 to fCount-1 do begin
  
   if fLevels[0][BlockIndex]<aMaster.fLevels[0][BlockIndex] then begin
  
    fLevels[0][BlockIndex]:=aMaster.fLevels[0][BlockIndex];

    if BlockIndex<aDirtyMin then begin
     aDirtyMin:=BlockIndex;
    end;
    
    if BlockIndex>aDirtyMax then begin
     aDirtyMax:=BlockIndex;
    end;

   end;

  end;

 end else begin
  
  // Walk hierarchy top-down, skip unchanged subtrees
 
  TopLevel:=fLevelCount-1;

  for BlockIndex:=0 to fLevelSizes[TopLevel]-1 do begin
   
   if fLevels[TopLevel][BlockIndex]<aMaster.fLevels[TopLevel][BlockIndex] then begin

    SyncFromBlock(aMaster,TopLevel,BlockIndex,aDirtyMin,aDirtyMax);

    fLevels[TopLevel][BlockIndex]:=aMaster.fLevels[TopLevel][BlockIndex];

   end;

  end;

 end;

end;

end.
