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
unit PasVulkan.Utils;
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
     PasVulkan.Types;

type TpvSwap<T>=class
      public
       class procedure Swap(var aValue,aOtherValue:T); static; inline;
     end;

     TpvUntypedSortCompareFunction=function(const a,b:TpvPointer):TpvInt32;

     TpvIndirectSortCompareFunction=function(const a,b:TpvPointer):TpvInt32;

     TpvTypedSort<T>=class
      private
       type PStackItem=^TStackItem;
            TStackItem=record
             Left,Right,Depth:TpvInt32;
            end;
      public
       type TpvTypedSortCompareFunction=function(const a,b:T):TpvInt32;
      public
       class procedure IntroSort(const pItems:TpvPointer;const pLeft,pRight:TpvInt32); overload;
       class procedure IntroSort(const pItems:TpvPointer;const pLeft,pRight:TpvInt32;const pCompareFunc:TpvTypedSortCompareFunction); overload;
     end;

{$ifdef fpc}
     TpvNativeComparableTypedSort<T>=class
      private
       type PStackItem=^TStackItem;
            TStackItem=record
             Left,Right,Depth:TpvInt32;
            end;
      public
       type TpvNativeComparableTypedSortCompareFunction=function(const a,b:T):TpvInt32;
      public
       class procedure IntroSort(const pItems:TpvPointer;const pLeft,pRight:TpvInt32); overload;
       class procedure IntroSort(const pItems:TpvPointer;const pLeft,pRight:TpvInt32;const pCompareFunc:TpvNativeComparableTypedSortCompareFunction); overload;
     end;
{$endif}

     TpvTopologicalSortNodeDependsOnKeys=array of TpvInt32;

     PpvTopologicalSortNode=^TpvTopologicalSortNode;
     TpvTopologicalSortNode=record
      Key:TpvInt32;
      DependsOnKeys:TpvTopologicalSortNodeDependsOnKeys;
     end;

     TpvTopologicalSortNodes=array of TpvTopologicalSortNode;

     TpvTopologicalSortVisitedBitmap=array of TpvUInt32;

     TpvTopologicalSortStack=array of TpvInt32;

     TpvTopologicalSortKeyToNodeIndex=array of TpvInt32;

     TpvTopologicalSortKeys=array of TpvInt32;

     TpvTopologicalSort=class
      private
       fNodes:TpvTopologicalSortNodes;
       fCount:TpvInt32;
       fCountKeys:TpvInt32;
{$ifdef UseIndexingForTopologicalSorting}
       fKeyToNodeIndex:TpvTopologicalSortKeyToNodeIndex;
{$endif}
       fVisitedBitmap:TpvTopologicalSortVisitedBitmap;
       fVisitedBitmapSize:TpvInt32;
       fStack:TpvTopologicalSortStack;
       fSortedKeys:TpvTopologicalSortKeys;
       fDirty:boolean;
       fSolveDirty:boolean;
       fCyclicState:TpvInt32;
       function GetNode(const aIndex:TpvInt32):TpvTopologicalSortNode;
       procedure SetNode(const aIndex:TpvInt32;const aNode:TpvTopologicalSortNode);
       function GetSortedKey(const aIndex:TpvInt32):TpvInt32;
       procedure SetCount(const aNewCount:TpvInt32);
       procedure Setup;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       procedure Add(const aKey:TpvInt32;const aDependsOnKeys:array of TpvInt32);
       procedure Solve(const aBackwards:boolean=false);
       function Cyclic:boolean;
       property Nodes[const aIndex:TpvInt32]:TpvTopologicalSortNode read GetNode write SetNode;
       property SortedKeys[const aIndex:TpvInt32]:TpvInt32 read GetSortedKey;
       property Count:TpvInt32 read fCount write SetCount;
     end;

     TpvTaggedTopologicalSort=class
      public
       type TKey=class;
            TKeys=array of TKey;
            TKey=class
             private
              fTag:TpvPtrUInt;
              fDependOnKeys:TKeys;
              fCountDependOnKeys:TpvSizeInt;
              fVisitedState:TpvUInt32;
              fIndex:TpvSizeInt;
             public
              constructor Create(const aTag:TpvPtrUInt); reintroduce;
              destructor Destroy; override;
              procedure AddDependOnKey(const aKey:TKey);
             published 
              property Tag:TpvPtrUInt read fTag;
              property Index:TpvSizeInt read fIndex;
            end;
      private
       fKeys:TKeys;
       fCountKeys:TpvSizeInt;
       fCyclic:Boolean;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       function Add(const aTag:TpvPtrUInt):TKey;
       procedure AddDependOnKey(const aKey,aDependOnKey:TKey);
       function Solve(const aBackwards:Boolean=false):Boolean;
      public
       property Keys:TKeys read fKeys; 
      published
       property Cyclic:Boolean read fCyclic;
       property CountKeys:TpvSizeInt read fCountKeys;
     end;

var pvCacheStoragePath:TpvUTF8String='';
    pvLocalStoragePath:TpvUTF8String='';
    pvRoamingStoragePath:TpvUTF8String='';

procedure DebugBreakPoint;

{$ifdef fpc}
function DumpCallStack:string;
{$endif}

function DumpExceptionCallStack(e:Exception):string;

function CombineTwoUInt32IntoOneUInt64(const a,b:TpvUInt32):TpvUInt64; {$ifdef caninline}inline;{$endif}

// Sorts data direct inplace
procedure UntypedDirectIntroSort(const pItems:TpvPointer;const pLeft,pRight,pElementSize:TpvInt32;const pCompareFunc:TpvUntypedSortCompareFunction);

// Sorts data indirect outplace with an extra TpvPointer array
procedure IndirectIntroSort(const pItems:TpvPointer;const pLeft,pRight:TpvInt32;const pCompareFunc:TpvIndirectSortCompareFunction);

function MatchPattern(Input,Pattern:PAnsiChar):boolean;

function IsPathSeparator(const aChar:AnsiChar):Boolean;
function CorrectPathSeparators(const aPath:TpvRawByteString):TpvRawByteString;
function ExpandRelativePath(const aRelativePath:TpvRawByteString;const aBasePath:TpvRawByteString=''):TpvRawByteString;
function ConvertPathToRelative(aAbsolutePath,aBasePath:TpvRawByteString):TpvRawByteString;
function ExtractFilePath(aPath:TpvRawByteString):TpvRawByteString;

function GetCacheFileName(const aCacheStoragePath,aFileName:TpvUTF8String;const aRootPath:TpvUTF8String=''):TpvUTF8String;

function EnsureDirectoryExistsForFileName(const aFileName:TpvUTF8String):Boolean;

function SizeToHumanReadableString(const aSize:TpvUInt64):TpvRawByteString;

implementation

uses PasVulkan.Math,
     Generics.Defaults;

procedure DebugBreakPoint;{$if defined(cpuarm)}assembler; // E7FFDEFE
asm
 .long 0xFEDEFFE7
end;
{$elseif defined(cpu386)}assembler; {$ifdef fpc}nostackframe;{$endif}
asm
 db $cc // int3
end;
{$elseif defined(cpux86_64)}assembler; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
 db $cc // int3
end;
{$else}
begin
end;
{$ifend}

{$ifdef fpc}
function DumpCallStack:string;
const LineEnding={$if defined(Windows) or defined(Win32) or defined(Win64)}#13#10{$else}#10{$ifend};
var bp,Address,OldBP:Pointer;
begin
 result:='';
 bp:=get_caller_frame(get_frame);
 while assigned(bp) do begin
  Address:=get_caller_addr(bp);
  Result:=Result+BackTraceStrFunc(Address)+LineEnding;
  OldBP:=bp;
  bp:=get_caller_frame(bp);
  if (TpvPtrUInt(bp)<=TpvPtrUInt(OldBP)) or (TpvPtrUInt(bp)>(TpvPtrUInt(StackBottom)+TpvPtrUInt(StackLength))) then begin
   bp:=nil;
  end;
 end;
end;
{$endif}

function DumpExceptionCallStack(e:Exception):string;
const LineEnding={$if defined(Windows) or defined(Win32) or defined(Win64)}#13#10{$else}#10{$ifend};
{$if defined(fpc)}
var Index:TpvInt32;
    Frames:PPointer;
{$else}
{$ifend}
begin
 result:='Program exception! '+LineEnding+'Stack trace:'+LineEnding+LineEnding;
 if assigned(e) then begin
  result:=result+'Exception class: '+e.ClassName+LineEnding+'Message: '+e.Message+LineEnding;
 end;
{$if defined(fpc)}
 result:=result+BackTraceStrFunc(ExceptAddr);
 Frames:=ExceptFrames;
 for Index:=0 to ExceptFrameCount-1 do begin
  result:=result+LineEnding+BackTraceStrFunc(Frames);
  inc(Frames);
 end;
{$else}
{$ifend}
end;

class procedure TpvSwap<T>.Swap(var aValue,aOtherValue:T);
var Temporary:T;
begin
 Temporary:=aValue;
 aValue:=aOtherValue;
 aOtherValue:=Temporary;
end;

function CombineTwoUInt32IntoOneUInt64(const a,b:TpvUInt32):TpvUInt64; {$ifdef caninline}inline;{$endif}
begin
 result:=(TpvUInt64(a) shl 32) or b;
end;

procedure MemorySwap(pA,pB:TpvPointer;pSize:TpvInt32);
var Temp:TpvInt32;
begin
 while pSize>=SizeOf(TpvInt32) do begin
  Temp:=TpvUInt32(pA^);
  TpvUInt32(pA^):=TpvUInt32(pB^);
  TpvUInt32(pB^):=Temp;
  inc(TpvPtrUInt(pA),SizeOf(TpvUInt32));
  inc(TpvPtrUInt(pB),SizeOf(TpvUInt32));
  dec(pSize,SizeOf(TpvUInt32));
 end;
 while pSize>=SizeOf(TpvUInt8) do begin
  Temp:=TpvUInt8(pA^);
  TpvUInt8(pA^):=TpvUInt8(pB^);
  TpvUInt8(pB^):=Temp;
  inc(TpvPtrUInt(pA),SizeOf(TpvUInt8));
  inc(TpvPtrUInt(pB),SizeOf(TpvUInt8));
  dec(pSize,SizeOf(TpvUInt8));
 end;
end;

procedure UntypedDirectIntroSort(const pItems:TpvPointer;const pLeft,pRight,pElementSize:TpvInt32;const pCompareFunc:TpvUntypedSortCompareFunction);
type PByteArray=^TByteArray;
     TByteArray=array[0..$3fffffff] of TpvUInt8;
     PStackItem=^TStackItem;
     TStackItem=record
      Left,Right,Depth:TpvInt32;
     end;
var Left,Right,Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:TpvInt32;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
begin
 if pLeft<pRight then begin
  StackItem:=@Stack[0];
  StackItem^.Left:=pLeft;
  StackItem^.Right:=pRight;
  StackItem^.Depth:=IntLog2((pRight-pLeft)+1) shl 1;
  inc(StackItem);
  while TpvPtrUInt(TpvPointer(StackItem))>TpvPtrUInt(TpvPointer(@Stack[0])) do begin
   dec(StackItem);
   Left:=StackItem^.Left;
   Right:=StackItem^.Right;
   Depth:=StackItem^.Depth;
   Size:=(Right-Left)+1;
   if Size<16 then begin
    // Insertion sort
    iA:=Left;
    iB:=iA+1;
    while iB<=Right do begin
     iC:=iB;
     while (iA>=Left) and
           (iC>=Left) and
           (pCompareFunc(TpvPointer(@PByteArray(pItems)^[iA*pElementSize]),TpvPointer(@PByteArray(pItems)^[iC*pElementSize]))>0) do begin
      MemorySwap(@PByteArray(pItems)^[iA*pElementSize],@PByteArray(pItems)^[iC*pElementSize],pElementSize);
      dec(iA);
      dec(iC);
     end;
     iA:=iB;
     inc(iB);
    end;
   end else begin
    if (Depth=0) or (TpvPtrUInt(TpvPointer(StackItem))>=TpvPtrUInt(TpvPointer(@Stack[high(Stack)-1]))) then begin
     // Heap sort
     i:=Size div 2;
     repeat
      if i>0 then begin
       dec(i);
      end else begin
       dec(Size);
       if Size>0 then begin
        MemorySwap(@PByteArray(pItems)^[(Left+Size)*pElementSize],@PByteArray(pItems)^[Left*pElementSize],pElementSize);
       end else begin
        break;
       end;
      end;
      Parent:=i;
      repeat
       Child:=(Parent*2)+1;
       if Child<Size then begin
        if (Child<(Size-1)) and (pCompareFunc(TpvPointer(@PByteArray(pItems)^[(Left+Child)*pElementSize]),TpvPointer(@PByteArray(pItems)^[(Left+Child+1)*pElementSize]))<0) then begin
         inc(Child);
        end;
        if pCompareFunc(TpvPointer(@PByteArray(pItems)^[(Left+Parent)*pElementSize]),TpvPointer(@PByteArray(pItems)^[(Left+Child)*pElementSize]))<0 then begin
         MemorySwap(@PByteArray(pItems)^[(Left+Parent)*pElementSize],@PByteArray(pItems)^[(Left+Child)*pElementSize],pElementSize);
         Parent:=Child;
         continue;
        end;
       end;
       break;
      until false;
     until false;
    end else begin
     // Quick sort width median-of-three optimization
     Middle:=Left+((Right-Left) shr 1);
     if (Right-Left)>3 then begin
      if pCompareFunc(TpvPointer(@PByteArray(pItems)^[Left*pElementSize]),TpvPointer(@PByteArray(pItems)^[Middle*pElementSize]))>0 then begin
       MemorySwap(@PByteArray(pItems)^[Left*pElementSize],@PByteArray(pItems)^[Middle*pElementSize],pElementSize);
      end;
      if pCompareFunc(TpvPointer(@PByteArray(pItems)^[Left*pElementSize]),TpvPointer(@PByteArray(pItems)^[Right*pElementSize]))>0 then begin
       MemorySwap(@PByteArray(pItems)^[Left*pElementSize],@PByteArray(pItems)^[Right*pElementSize],pElementSize);
      end;
      if pCompareFunc(TpvPointer(@PByteArray(pItems)^[Middle*pElementSize]),TpvPointer(@PByteArray(pItems)^[Right*pElementSize]))>0 then begin
       MemorySwap(@PByteArray(pItems)^[Middle*pElementSize],@PByteArray(pItems)^[Right*pElementSize],pElementSize);
      end;
     end;
     Pivot:=Middle;
     i:=Left;
     j:=Right;
     repeat
      while (i<Right) and (pCompareFunc(TpvPointer(@PByteArray(pItems)^[i*pElementSize]),TpvPointer(@PByteArray(pItems)^[Pivot*pElementSize]))<0) do begin
       inc(i);
      end;
      while (j>=i) and (pCompareFunc(TpvPointer(@PByteArray(pItems)^[j*pElementSize]),TpvPointer(@PByteArray(pItems)^[Pivot*pElementSize]))>0) do begin
       dec(j);
      end;
      if i>j then begin
       break;
      end else begin
       if i<>j then begin
        MemorySwap(@PByteArray(pItems)^[i*pElementSize],@PByteArray(pItems)^[j*pElementSize],pElementSize);
        if Pivot=i then begin
         Pivot:=j;
        end else if Pivot=j then begin
         Pivot:=i;
        end;
       end;
       inc(i);
       dec(j);
      end;
     until false;
     if i<Right then begin
      StackItem^.Left:=i;
      StackItem^.Right:=Right;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
     if Left<j then begin
      StackItem^.Left:=Left;
      StackItem^.Right:=j;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
    end;
   end;
  end;
 end;
end;

procedure IndirectIntroSort(const pItems:TpvPointer;const pLeft,pRight:TpvInt32;const pCompareFunc:TpvIndirectSortCompareFunction);
type PPointers=^TPointers;
     TPointers=array[0..$ffff] of TpvPointer;
     PStackItem=^TStackItem;
     TStackItem=record
      Left,Right,Depth:TpvInt32;
     end;
var Left,Right,Depth,i,j,Middle,Size,Parent,Child:TpvInt32;
    Pivot,Temp:TpvPointer;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
begin
 if pLeft<pRight then begin
  StackItem:=@Stack[0];
  StackItem^.Left:=pLeft;
  StackItem^.Right:=pRight;
  StackItem^.Depth:=IntLog2((pRight-pLeft)+1) shl 1;
  inc(StackItem);
  while TpvPtrUInt(TpvPointer(StackItem))>TpvPtrUInt(TpvPointer(@Stack[0])) do begin
   dec(StackItem);
   Left:=StackItem^.Left;
   Right:=StackItem^.Right;
   Depth:=StackItem^.Depth;
   Size:=(Right-Left)+1;
   if Size<16 then begin
    // Insertion sort
    for i:=Left+1 to Right do begin
     Temp:=PPointers(pItems)^[i];
     j:=i-1;
     if (j>=Left) and (pCompareFunc(PPointers(pItems)^[j],Temp)>0) then begin
      repeat
       PPointers(pItems)^[j+1]:=PPointers(pItems)^[j];
       dec(j);
      until not ((j>=Left) and (pCompareFunc(PPointers(pItems)^[j],Temp)>0));
      PPointers(pItems)^[j+1]:=Temp;
     end;
    end;
   end else begin
    if (Depth=0) or (TpvPtrUInt(TpvPointer(StackItem))>=TpvPtrUInt(TpvPointer(@Stack[high(Stack)-1]))) then begin
     // Heap sort
     i:=Size div 2;
     Temp:=nil;
     repeat
      if i>0 then begin
       dec(i);
       Temp:=PPointers(pItems)^[Left+i];
      end else begin
       dec(Size);
       if Size>0 then begin
        Temp:=PPointers(pItems)^[Left+Size];
        PPointers(pItems)^[Left+Size]:=PPointers(pItems)^[Left];
       end else begin
        break;
       end;
      end;
      Parent:=i;
      Child:=(i*2)+1;
      while Child<Size do begin
       if ((Child+1)<Size) and (pCompareFunc(PPointers(pItems)^[Left+Child+1],PPointers(pItems)^[Left+Child])>0) then begin
        inc(Child);
       end;
       if pCompareFunc(PPointers(pItems)^[Left+Child],Temp)>0 then begin
        PPointers(pItems)^[Left+Parent]:=PPointers(pItems)^[Left+Child];
        Parent:=Child;
        Child:=(Parent*2)+1;
       end else begin
        break;
       end;
      end;
      PPointers(pItems)^[Left+Parent]:=Temp;
     until false;
    end else begin
     // Quick sort width median-of-three optimization
     Middle:=Left+((Right-Left) shr 1);
     if (Right-Left)>3 then begin
      if pCompareFunc(PPointers(pItems)^[Left],PPointers(pItems)^[Middle])>0 then begin
       Temp:=PPointers(pItems)^[Left];
       PPointers(pItems)^[Left]:=PPointers(pItems)^[Middle];
       PPointers(pItems)^[Middle]:=Temp;
      end;
      if pCompareFunc(PPointers(pItems)^[Left],PPointers(pItems)^[Right])>0 then begin
       Temp:=PPointers(pItems)^[Left];
       PPointers(pItems)^[Left]:=PPointers(pItems)^[Right];
       PPointers(pItems)^[Right]:=Temp;
      end;
      if pCompareFunc(PPointers(pItems)^[Middle],PPointers(pItems)^[Right])>0 then begin
       Temp:=PPointers(pItems)^[Middle];
       PPointers(pItems)^[Middle]:=PPointers(pItems)^[Right];
       PPointers(pItems)^[Right]:=Temp;
      end;
     end;
     Pivot:=PPointers(pItems)^[Middle];
     i:=Left;
     j:=Right;
     repeat
      while (i<Right) and (pCompareFunc(PPointers(pItems)^[i],Pivot)<0) do begin
       inc(i);
      end;
      while (j>=i) and (pCompareFunc(PPointers(pItems)^[j],Pivot)>0) do begin
       dec(j);
      end;
      if i>j then begin
       break;
      end else begin
       if i<>j then begin
        Temp:=PPointers(pItems)^[i];
        PPointers(pItems)^[i]:=PPointers(pItems)^[j];
        PPointers(pItems)^[j]:=Temp;
       end;
       inc(i);
       dec(j);
      end;
     until false;
     if i<Right then begin
      StackItem^.Left:=i;
      StackItem^.Right:=Right;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
     if Left<j then begin
      StackItem^.Left:=Left;
      StackItem^.Right:=j;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
    end;
   end;
  end;
 end;
end;

class procedure TpvTypedSort<T>.IntroSort(const pItems:TpvPointer;const pLeft,pRight:TpvInt32);
type PItem=^TItem;
     TItem=T;
     PItemArray=^TItemArray;
     TItemArray=array of TItem;
var Left,Right,Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:TpvInt32;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
    Temp:T;
    Comparer:IComparer<T>;
begin
 Comparer:=TComparer<T>.Default;
 if pLeft<pRight then begin
  StackItem:=@Stack[0];
  StackItem^.Left:=pLeft;
  StackItem^.Right:=pRight;
  StackItem^.Depth:=IntLog2((pRight-pLeft)+1) shl 1;
  inc(StackItem);
  while TpvPtrUInt(TpvPointer(StackItem))>TpvPtrUInt(TpvPointer(@Stack[0])) do begin
   dec(StackItem);
   Left:=StackItem^.Left;
   Right:=StackItem^.Right;
   Depth:=StackItem^.Depth;
   Size:=(Right-Left)+1;
   if Size<16 then begin
    // Insertion sort
    iA:=Left;
    iB:=iA+1;
    while iB<=Right do begin
     iC:=iB;
     while (iA>=Left) and
           (iC>=Left) and
           (Comparer.Compare(PItemArray(pItems)^[iA],PItemArray(pItems)^[iC])>0) do begin
      Temp:=PItemArray(pItems)^[iA];
      PItemArray(pItems)^[iA]:=PItemArray(pItems)^[iC];
      PItemArray(pItems)^[iC]:=Temp;
      dec(iA);
      dec(iC);
     end;
     iA:=iB;
     inc(iB);
    end;
   end else begin
    if (Depth=0) or (TpvPtrUInt(TpvPointer(StackItem))>=TpvPtrUInt(TpvPointer(@Stack[high(Stack)-1]))) then begin
     // Heap sort
     i:=Size div 2;
     repeat
      if i>0 then begin
       dec(i);
      end else begin
       dec(Size);
       if Size>0 then begin
        Temp:=PItemArray(pItems)^[Left+Size];
        PItemArray(pItems)^[Left+Size]:=PItemArray(pItems)^[Left];
        PItemArray(pItems)^[Left]:=Temp;
       end else begin
        break;
       end;
      end;
      Parent:=i;
      repeat
       Child:=(Parent*2)+1;
       if Child<Size then begin
        if (Child<(Size-1)) and (Comparer.Compare(PItemArray(pItems)^[Left+Child],PItemArray(pItems)^[Left+Child+1])<0) then begin
         inc(Child);
        end;
        if Comparer.Compare(PItemArray(pItems)^[Left+Parent],PItemArray(pItems)^[Left+Child])<0 then begin
         Temp:=PItemArray(pItems)^[Left+Parent];
         PItemArray(pItems)^[Left+Parent]:=PItemArray(pItems)^[Left+Child];
         PItemArray(pItems)^[Left+Child]:=Temp;
         Parent:=Child;
         continue;
        end;
       end;
       break;
      until false;
     until false;
    end else begin
     // Quick sort width median-of-three optimization
     Middle:=Left+((Right-Left) shr 1);
     if (Right-Left)>3 then begin
      if Comparer.Compare(PItemArray(pItems)^[Left],PItemArray(pItems)^[Middle])>0 then begin
       Temp:=PItemArray(pItems)^[Left];
       PItemArray(pItems)^[Left]:=PItemArray(pItems)^[Middle];
       PItemArray(pItems)^[Middle]:=Temp;
      end;
      if Comparer.Compare(PItemArray(pItems)^[Left],PItemArray(pItems)^[Right])>0 then begin
       Temp:=PItemArray(pItems)^[Left];
       PItemArray(pItems)^[Left]:=PItemArray(pItems)^[Right];
       PItemArray(pItems)^[Right]:=Temp;
      end;
      if Comparer.Compare(PItemArray(pItems)^[Middle],PItemArray(pItems)^[Right])>0 then begin
       Temp:=PItemArray(pItems)^[Middle];
       PItemArray(pItems)^[Middle]:=PItemArray(pItems)^[Right];
       PItemArray(pItems)^[Right]:=Temp;
      end;
     end;
     Pivot:=Middle;
     i:=Left;
     j:=Right;
     repeat
      while (i<Right) and (Comparer.Compare(PItemArray(pItems)^[i],PItemArray(pItems)^[Pivot])<0) do begin
       inc(i);
      end;
      while (j>=i) and (Comparer.Compare(PItemArray(pItems)^[j],PItemArray(pItems)^[Pivot])>0) do begin
       dec(j);
      end;
      if i>j then begin
       break;
      end else begin
       if i<>j then begin
        Temp:=PItemArray(pItems)^[i];
        PItemArray(pItems)^[i]:=PItemArray(pItems)^[j];
        PItemArray(pItems)^[j]:=Temp;
        if Pivot=i then begin
         Pivot:=j;
        end else if Pivot=j then begin
         Pivot:=i;
        end;
       end;
       inc(i);
       dec(j);
      end;
     until false;
     if i<Right then begin
      StackItem^.Left:=i;
      StackItem^.Right:=Right;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
     if Left<j then begin
      StackItem^.Left:=Left;
      StackItem^.Right:=j;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
    end;
   end;
  end;
 end;
end;

class procedure TpvTypedSort<T>.IntroSort(const pItems:TpvPointer;const pLeft,pRight:TpvInt32;const pCompareFunc:TpvTypedSortCompareFunction);
type PItem=^TItem;
     TItem=T;
     PItemArray=^TItemArray;
     TItemArray=array[0..65535] of TItem;
var Left,Right,Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:TpvInt32;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
    Temp:T;
begin
 if pLeft<pRight then begin
  StackItem:=@Stack[0];
  StackItem^.Left:=pLeft;
  StackItem^.Right:=pRight;
  StackItem^.Depth:=IntLog2((pRight-pLeft)+1) shl 1;
  inc(StackItem);
  while TpvPtrUInt(TpvPointer(StackItem))>TpvPtrUInt(TpvPointer(@Stack[0])) do begin
   dec(StackItem);
   Left:=StackItem^.Left;
   Right:=StackItem^.Right;
   Depth:=StackItem^.Depth;
   Size:=(Right-Left)+1;
   if Size<16 then begin
    // Insertion sort
    iA:=Left;
    iB:=iA+1;
    while iB<=Right do begin
     iC:=iB;
     while (iA>=Left) and
           (iC>=Left) and
           (pCompareFunc(PItemArray(pItems)^[iA],PItemArray(pItems)^[iC])>0) do begin
      Temp:=PItemArray(pItems)^[iA];
      PItemArray(pItems)^[iA]:=PItemArray(pItems)^[iC];
      PItemArray(pItems)^[iC]:=Temp;
      dec(iA);
      dec(iC);
     end;
     iA:=iB;
     inc(iB);
    end;
   end else begin
    if (Depth=0) or (TpvPtrUInt(TpvPointer(StackItem))>=TpvPtrUInt(TpvPointer(@Stack[high(Stack)-1]))) then begin
     // Heap sort
     i:=Size div 2;
     repeat
      if i>0 then begin
       dec(i);
      end else begin
       dec(Size);
       if Size>0 then begin
        Temp:=PItemArray(pItems)^[Left+Size];
        PItemArray(pItems)^[Left+Size]:=PItemArray(pItems)^[Left];
        PItemArray(pItems)^[Left]:=Temp;
       end else begin
        break;
       end;
      end;
      Parent:=i;
      repeat
       Child:=(Parent*2)+1;
       if Child<Size then begin
        if (Child<(Size-1)) and (pCompareFunc(PItemArray(pItems)^[Left+Child],PItemArray(pItems)^[Left+Child+1])<0) then begin
         inc(Child);
        end;
        if pCompareFunc(PItemArray(pItems)^[Left+Parent],PItemArray(pItems)^[Left+Child])<0 then begin
         Temp:=PItemArray(pItems)^[Left+Parent];
         PItemArray(pItems)^[Left+Parent]:=PItemArray(pItems)^[Left+Child];
         PItemArray(pItems)^[Left+Child]:=Temp;
         Parent:=Child;
         continue;
        end;
       end;
       break;
      until false;
     until false;
    end else begin
     // Quick sort width median-of-three optimization
     Middle:=Left+((Right-Left) shr 1);
     if (Right-Left)>3 then begin
      if pCompareFunc(PItemArray(pItems)^[Left],PItemArray(pItems)^[Middle])>0 then begin
       Temp:=PItemArray(pItems)^[Left];
       PItemArray(pItems)^[Left]:=PItemArray(pItems)^[Middle];
       PItemArray(pItems)^[Middle]:=Temp;
      end;
      if pCompareFunc(PItemArray(pItems)^[Left],PItemArray(pItems)^[Right])>0 then begin
       Temp:=PItemArray(pItems)^[Left];
       PItemArray(pItems)^[Left]:=PItemArray(pItems)^[Right];
       PItemArray(pItems)^[Right]:=Temp;
      end;
      if pCompareFunc(PItemArray(pItems)^[Middle],PItemArray(pItems)^[Right])>0 then begin
       Temp:=PItemArray(pItems)^[Middle];
       PItemArray(pItems)^[Middle]:=PItemArray(pItems)^[Right];
       PItemArray(pItems)^[Right]:=Temp;
      end;
     end;
     Pivot:=Middle;
     i:=Left;
     j:=Right;
     repeat
      while (i<Right) and (pCompareFunc(PItemArray(pItems)^[i],PItemArray(pItems)^[Pivot])<0) do begin
       inc(i);
      end;
      while (j>=i) and (pCompareFunc(PItemArray(pItems)^[j],PItemArray(pItems)^[Pivot])>0) do begin
       dec(j);
      end;
      if i>j then begin
       break;
      end else begin
       if i<>j then begin
        Temp:=PItemArray(pItems)^[i];
        PItemArray(pItems)^[i]:=PItemArray(pItems)^[j];
        PItemArray(pItems)^[j]:=Temp;
        if Pivot=i then begin
         Pivot:=j;
        end else if Pivot=j then begin
         Pivot:=i;
        end;
       end;
       inc(i);
       dec(j);
      end;
     until false;
     if i<Right then begin
      StackItem^.Left:=i;
      StackItem^.Right:=Right;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
     if Left<j then begin
      StackItem^.Left:=Left;
      StackItem^.Right:=j;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
    end;
   end;
  end;
 end;
end;

{$ifdef fpc}
class procedure TpvNativeComparableTypedSort<T>.IntroSort(const pItems:TpvPointer;const pLeft,pRight:TpvInt32);
type PItem=^TItem;
     TItem=T;
     PItemArray=^TItemArray;
     TItemArray=array of TItem;
var Left,Right,Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:TpvInt32;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
    Temp:T;
begin
 if pLeft<pRight then begin
  StackItem:=@Stack[0];
  StackItem^.Left:=pLeft;
  StackItem^.Right:=pRight;
  StackItem^.Depth:=IntLog2((pRight-pLeft)+1) shl 1;
  inc(StackItem);
  while TpvPtrUInt(TpvPointer(StackItem))>TpvPtrUInt(TpvPointer(@Stack[0])) do begin
   dec(StackItem);
   Left:=StackItem^.Left;
   Right:=StackItem^.Right;
   Depth:=StackItem^.Depth;
   Size:=(Right-Left)+1;
   if Size<16 then begin
    // Insertion sort
    iA:=Left;
    iB:=iA+1;
    while iB<=Right do begin
     iC:=iB;
     while (iA>=Left) and
           (iC>=Left) and
           (PItemArray(pItems)^[iA]>PItemArray(pItems)^[iC]) do begin
      Temp:=PItemArray(pItems)^[iA];
      PItemArray(pItems)^[iA]:=PItemArray(pItems)^[iC];
      PItemArray(pItems)^[iC]:=Temp;
      dec(iA);
      dec(iC);
     end;
     iA:=iB;
     inc(iB);
    end;
   end else begin
    if (Depth=0) or (TpvPtrUInt(TpvPointer(StackItem))>=TpvPtrUInt(TpvPointer(@Stack[high(Stack)-1]))) then begin
     // Heap sort
     i:=Size div 2;
     repeat
      if i>0 then begin
       dec(i);
      end else begin
       dec(Size);
       if Size>0 then begin
        Temp:=PItemArray(pItems)^[Left+Size];
        PItemArray(pItems)^[Left+Size]:=PItemArray(pItems)^[Left];
        PItemArray(pItems)^[Left]:=Temp;
       end else begin
        break;
       end;
      end;
      Parent:=i;
      repeat
       Child:=(Parent*2)+1;
       if Child<Size then begin
        if (Child<(Size-1)) and (PItemArray(pItems)^[Left+Child]<PItemArray(pItems)^[Left+Child+1]) then begin
         inc(Child);
        end;
        if PItemArray(pItems)^[Left+Parent]<PItemArray(pItems)^[Left+Child] then begin
         Temp:=PItemArray(pItems)^[Left+Parent];
         PItemArray(pItems)^[Left+Parent]:=PItemArray(pItems)^[Left+Child];
         PItemArray(pItems)^[Left+Child]:=Temp;
         Parent:=Child;
         continue;
        end;
       end;
       break;
      until false;
     until false;
    end else begin
     // Quick sort width median-of-three optimization
     Middle:=Left+((Right-Left) shr 1);
     if (Right-Left)>3 then begin
      if PItemArray(pItems)^[Left]>PItemArray(pItems)^[Middle] then begin
       Temp:=PItemArray(pItems)^[Left];
       PItemArray(pItems)^[Left]:=PItemArray(pItems)^[Middle];
       PItemArray(pItems)^[Middle]:=Temp;
      end;
      if PItemArray(pItems)^[Left]>PItemArray(pItems)^[Right] then begin
       Temp:=PItemArray(pItems)^[Left];
       PItemArray(pItems)^[Left]:=PItemArray(pItems)^[Right];
       PItemArray(pItems)^[Right]:=Temp;
      end;
      if PItemArray(pItems)^[Middle]>PItemArray(pItems)^[Right] then begin
       Temp:=PItemArray(pItems)^[Middle];
       PItemArray(pItems)^[Middle]:=PItemArray(pItems)^[Right];
       PItemArray(pItems)^[Right]:=Temp;
      end;
     end;
     Pivot:=Middle;
     i:=Left;
     j:=Right;
     repeat
      while (i<Right) and (PItemArray(pItems)^[i]<PItemArray(pItems)^[Pivot]) do begin
       inc(i);
      end;
      while (j>=i) and (PItemArray(pItems)^[j]>PItemArray(pItems)^[Pivot]) do begin
       dec(j);
      end;
      if i>j then begin
       break;
      end else begin
       if i<>j then begin
        Temp:=PItemArray(pItems)^[i];
        PItemArray(pItems)^[i]:=PItemArray(pItems)^[j];
        PItemArray(pItems)^[j]:=Temp;
        if Pivot=i then begin
         Pivot:=j;
        end else if Pivot=j then begin
         Pivot:=i;
        end;
       end;
       inc(i);
       dec(j);
      end;
     until false;
     if i<Right then begin
      StackItem^.Left:=i;
      StackItem^.Right:=Right;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
     if Left<j then begin
      StackItem^.Left:=Left;
      StackItem^.Right:=j;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
    end;
   end;
  end;
 end;
end;

class procedure TpvNativeComparableTypedSort<T>.IntroSort(const pItems:TpvPointer;const pLeft,pRight:TpvInt32;const pCompareFunc:TpvNativeComparableTypedSortCompareFunction);
type PItem=^TItem;
     TItem=T;
     PItemArray=^TItemArray;
     TItemArray=array[0..65535] of TItem;
var Left,Right,Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:TpvInt32;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
    Temp:T;
begin
 if pLeft<pRight then begin
  StackItem:=@Stack[0];
  StackItem^.Left:=pLeft;
  StackItem^.Right:=pRight;
  StackItem^.Depth:=IntLog2((pRight-pLeft)+1) shl 1;
  inc(StackItem);
  while TpvPtrUInt(TpvPointer(StackItem))>TpvPtrUInt(TpvPointer(@Stack[0])) do begin
   dec(StackItem);
   Left:=StackItem^.Left;
   Right:=StackItem^.Right;
   Depth:=StackItem^.Depth;
   Size:=(Right-Left)+1;
   if Size<16 then begin
    // Insertion sort
    iA:=Left;
    iB:=iA+1;
    while iB<=Right do begin
     iC:=iB;
     while (iA>=Left) and
           (iC>=Left) and
           (pCompareFunc(PItemArray(pItems)^[iA],PItemArray(pItems)^[iC])>0) do begin
      Temp:=PItemArray(pItems)^[iA];
      PItemArray(pItems)^[iA]:=PItemArray(pItems)^[iC];
      PItemArray(pItems)^[iC]:=Temp;
      dec(iA);
      dec(iC);
     end;
     iA:=iB;
     inc(iB);
    end;
   end else begin
    if (Depth=0) or (TpvPtrUInt(TpvPointer(StackItem))>=TpvPtrUInt(TpvPointer(@Stack[high(Stack)-1]))) then begin
     // Heap sort
     i:=Size div 2;
     repeat
      if i>0 then begin
       dec(i);
      end else begin
       dec(Size);
       if Size>0 then begin
        Temp:=PItemArray(pItems)^[Left+Size];
        PItemArray(pItems)^[Left+Size]:=PItemArray(pItems)^[Left];
        PItemArray(pItems)^[Left]:=Temp;
       end else begin
        break;
       end;
      end;
      Parent:=i;
      repeat
       Child:=(Parent*2)+1;
       if Child<Size then begin
        if (Child<(Size-1)) and (pCompareFunc(PItemArray(pItems)^[Left+Child],PItemArray(pItems)^[Left+Child+1])<0) then begin
         inc(Child);
        end;
        if pCompareFunc(PItemArray(pItems)^[Left+Parent],PItemArray(pItems)^[Left+Child])<0 then begin
         Temp:=PItemArray(pItems)^[Left+Parent];
         PItemArray(pItems)^[Left+Parent]:=PItemArray(pItems)^[Left+Child];
         PItemArray(pItems)^[Left+Child]:=Temp;
         Parent:=Child;
         continue;
        end;
       end;
       break;
      until false;
     until false;
    end else begin
     // Quick sort width median-of-three optimization
     Middle:=Left+((Right-Left) shr 1);
     if (Right-Left)>3 then begin
      if pCompareFunc(PItemArray(pItems)^[Left],PItemArray(pItems)^[Middle])>0 then begin
       Temp:=PItemArray(pItems)^[Left];
       PItemArray(pItems)^[Left]:=PItemArray(pItems)^[Middle];
       PItemArray(pItems)^[Middle]:=Temp;
      end;
      if pCompareFunc(PItemArray(pItems)^[Left],PItemArray(pItems)^[Right])>0 then begin
       Temp:=PItemArray(pItems)^[Left];
       PItemArray(pItems)^[Left]:=PItemArray(pItems)^[Right];
       PItemArray(pItems)^[Right]:=Temp;
      end;
      if pCompareFunc(PItemArray(pItems)^[Middle],PItemArray(pItems)^[Right])>0 then begin
       Temp:=PItemArray(pItems)^[Middle];
       PItemArray(pItems)^[Middle]:=PItemArray(pItems)^[Right];
       PItemArray(pItems)^[Right]:=Temp;
      end;
     end;
     Pivot:=Middle;
     i:=Left;
     j:=Right;
     repeat
      while (i<Right) and (pCompareFunc(PItemArray(pItems)^[i],PItemArray(pItems)^[Pivot])<0) do begin
       inc(i);
      end;
      while (j>=i) and (pCompareFunc(PItemArray(pItems)^[j],PItemArray(pItems)^[Pivot])>0) do begin
       dec(j);
      end;
      if i>j then begin
       break;
      end else begin
       if i<>j then begin
        Temp:=PItemArray(pItems)^[i];
        PItemArray(pItems)^[i]:=PItemArray(pItems)^[j];
        PItemArray(pItems)^[j]:=Temp;
        if Pivot=i then begin
         Pivot:=j;
        end else if Pivot=j then begin
         Pivot:=i;
        end;
       end;
       inc(i);
       dec(j);
      end;
     until false;
     if i<Right then begin
      StackItem^.Left:=i;
      StackItem^.Right:=Right;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
     if Left<j then begin
      StackItem^.Left:=Left;
      StackItem^.Right:=j;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
    end;
   end;
  end;
 end;
end;
{$endif}

function MatchPattern(Input,Pattern:PAnsiChar):boolean;
begin
 result:=true;
 while true do begin
  case Pattern[0] of
   #0:begin
    result:=Input[0]=#0;
    exit;
   end;
   '*':begin
    inc(Pattern);
    if Pattern[0]=#0 then begin
     result:=true;
     exit;
    end;
    while Input[0]<>#0 do begin
     if MatchPattern(Input,Pattern) then begin
      result:=true;
      exit;
     end;
     inc(Input);
    end;
   end;
   '?':begin
    if Input[0]=#0 then begin
     result:=false;
     exit;
    end;
    inc(Input);
    inc(Pattern);
   end;
   '[':begin
    if Pattern[1] in [#0,'[',']'] then begin
     result:=false;
     exit;
    end;
    if Pattern[1]='^' then begin
     inc(Pattern,2);
     result:=true;
     while Pattern[0]<>']' do begin
      if Pattern[1]='-' then begin
       if (Input[0]>=Pattern[0]) and (Input[0]<=Pattern[2]) then begin
        result:=false;
        break;
       end else begin
        inc(Pattern,3);
       end;
      end else begin
       if Input[0]=Pattern[0] then begin
        result:=false;
        break;
       end else begin
        inc(Pattern);
       end;
      end;
     end;
    end else begin
     inc(Pattern);
     result:=false;
     while Pattern[0]<>']' do begin
      if Pattern[1]='-' then begin
       if (Input[0]>=Pattern[0]) and (Input[0]<=Pattern[2]) then begin
        result:=true;
        break;
       end else begin
        inc(Pattern,3);
       end;
      end else begin
       if Input[0]=Pattern[0] then begin
        result:=true;
        break;
       end else begin
        inc(Pattern);
       end;
      end;
     end;
    end;
    if result then begin
     inc(Input);
     while not (Pattern[0] in [']',#0]) do begin
      inc(Pattern);
     end;
     if Pattern[0]=#0 then begin
      result:=false;
      exit;
     end else begin
      inc(Pattern);
     end;
    end else begin
     exit;
    end;
   end;
   else begin
    if Input[0]<>Pattern[0] then begin
     result:=false;
     break;
    end;
    inc(Input);
    inc(Pattern);
   end;
  end;
 end;
end;

constructor TpvTopologicalSort.Create;
begin
 inherited Create;
 fNodes:=nil;
 fCount:=0;
 fCountKeys:=0;
{$ifdef UseIndexingForTopologicalSorting}
 fKeyToNodeIndex:=nil;
{$endif}
 fVisitedBitmap:=nil;
 fVisitedBitmapSize:=0;
 fStack:=nil;
 SetLength(fStack,32);
 fSortedKeys:=nil;
 fDirty:=true;
 fSolveDirty:=true;
 fCyclicState:=-1;
end;

destructor TpvTopologicalSort.Destroy;
begin
 SetLength(fNodes,0);
{$ifdef UseIndexingForTopologicalSorting}
 SetLength(fKeyToNodeIndex,0);
{$endif}
 SetLength(fVisitedBitmap,0);
 SetLength(fStack,0);
 SetLength(fSortedKeys,0);
 inherited Destroy;
end;

procedure TpvTopologicalSort.Clear;
begin
 fCount:=0;
 fDirty:=true;
 fSolveDirty:=true;
 fCyclicState:=-1;
end;

function TpvTopologicalSort.GetNode(const aIndex:TpvInt32):TpvTopologicalSortNode;
begin
 result:=fNodes[aIndex];
end;

procedure TpvTopologicalSort.SetNode(const aIndex:TpvInt32;const aNode:TpvTopologicalSortNode);
begin
 fNodes[aIndex]:=aNode;
end;

function TpvTopologicalSort.GetSortedKey(const aIndex:TpvInt32):TpvInt32;
begin
 result:=fSortedKeys[aIndex];
end;

procedure TpvTopologicalSort.SetCount(const aNewCount:TpvInt32);
begin
 fCount:=aNewCount;
 if length(fNodes)<fCount then begin
  SetLength(fNodes,fCount*2);
 end;
end;

procedure TpvTopologicalSort.Add(const aKey:TpvInt32;const aDependsOnKeys:array of TpvInt32);
var Index:TpvInt32;
    Node:PpvTopologicalSortNode;
begin
 Index:=fCount;
 SetCount(fCount+1);
 Node:=@fNodes[Index];
 Node^.Key:=aKey;
 SetLength(Node^.DependsOnKeys,length(aDependsOnKeys));
 if length(aDependsOnKeys)>0 then begin
  Move(aDependsOnKeys[0],Node^.DependsOnKeys[0],length(aDependsOnKeys)*SizeOf(TpvInt32));
 end;
 fDirty:=true;
 fSolveDirty:=true;
 fCyclicState:=-1;
end;

procedure TpvTopologicalSort.Setup;
var Index:TpvInt32;
    Node:PpvTopologicalSortNode;
begin
 if fDirty then begin
  fCountKeys:=0;
  for Index:=0 to fCount-1 do begin
   Node:=@fNodes[Index];
   if fCountKeys<=Node^.Key then begin
    fCountKeys:=Node^.Key+1;
   end;
  end;
  if fCountKeys>0 then begin
{$ifdef UseIndexingForTopologicalSorting}
   if length(fKeyToNodeIndex)<fCountKeys then begin
    SetLength(fKeyToNodeIndex,fCountKeys);
   end;
   FillChar(fKeyToNodeIndex[0],fCountKeys*SizeOf(TpvInt32),#$ff);
   for Index:=0 to fCount-1 do begin
    fKeyToNodeIndex[fNodes[Index].Key]:=Index;
   end;
{$endif}
   fVisitedBitmapSize:=(fCountKeys+31) shr 5;
   if length(fVisitedBitmap)<fVisitedBitmapSize then begin
    SetLength(fVisitedBitmap,fVisitedBitmapSize);
   end;
   FillChar(fVisitedBitmap[0],fVisitedBitmapSize*SizeOf(TpvUInt32),#0);
  end;
  if length(fSortedKeys)<fCount then begin
   SetLength(fSortedKeys,fCount);
  end;
  fDirty:=false;
 end;
end;

procedure TpvTopologicalSort.Solve(const aBackwards:boolean=false);
var Index,SubIndex,StackPointer,Key,DependsOnKey,CountDependOnKeys,SortIndex:TpvInt32;
    Node:PpvTopologicalSortNode;
begin
 if fDirty then begin
  Setup;
 end;
 if fSolveDirty then begin
  if fCountKeys>0 then begin
   FillChar(fVisitedBitmap[0],fVisitedBitmapSize*SizeOf(TpvUInt32),#0);
   if aBackwards then begin
    SortIndex:=0;
   end else begin
    SortIndex:=fCount;
   end;
   for Index:=0 to fCount-1 do begin
    Key:=fNodes[Index].Key;
    if (Key>=0) and (Key<fCountKeys) and
       ((fVisitedBitmap[Key shr 5] and (TpvUInt32(1) shl (Key and 31)))=0) then begin
     StackPointer:=0;
     if length(fStack)<(StackPointer+2) then begin
      SetLength(fStack,(StackPointer+2)*2);
     end;
     fStack[StackPointer]:=Key;
     inc(StackPointer);
     while StackPointer>0 do begin
      dec(StackPointer);
      Key:=fStack[StackPointer];
      if Key<0 then begin
       Key:=-(Key+1);
       if aBackwards then begin
        if SortIndex<fCount then begin
         fSortedKeys[SortIndex]:=Key;
         inc(SortIndex);
        end;
       end else begin
        if SortIndex>1 then begin
         dec(SortIndex);
         fSortedKeys[SortIndex]:=Key;
        end;
       end;
      end else if (Key<fCountKeys) and
                  ((fVisitedBitmap[Key shr 5] and (TpvUInt32(1) shl (Key and 31)))=0) then begin
       fVisitedBitmap[Key shr 5]:=fVisitedBitmap[Key shr 5] or (TpvUInt32(1) shl (Key and 31));
 {$ifdef UseIndexingForTopologicalSorting}
       if fKeyToNodeIndex[Key]>=0 then begin
        Node:=@fNodes[fKeyToNodeIndex[Key]];
       end else begin
        Node:=nil;
       end;
 {$else}
       Node:=nil;
       for SubIndex:=0 to fCount-1 do begin
        if fNodes[SubIndex].Key=Key then begin
         Node:=@fNodes[SubIndex];
         break;
        end;
       end;
 {$endif}
       if assigned(Node) then begin
        CountDependOnKeys:=length(Node^.DependsOnKeys);
        if length(fStack)<(StackPointer+CountDependOnKeys+1) then begin
         SetLength(fStack,(StackPointer+CountDependOnKeys+1)*2);
        end;
        fStack[StackPointer]:=-(Key+1);
        inc(StackPointer);
        for SubIndex:=CountDependOnKeys-1 downto 0 do begin
         DependsOnKey:=Node^.DependsOnKeys[SubIndex];
         if (DependsOnKey>=0) and (DependsOnKey<fCountKeys) then begin
          fStack[StackPointer]:=DependsOnKey;
          inc(StackPointer);
         end;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
  fSolveDirty:=false;
 end;
end;

function TpvTopologicalSort.Cyclic:boolean;
var Index,SubIndex,StackPointer,Key,DependsOnKey,CountDependOnKeys:TpvInt32;
    Node:PpvTopologicalSortNode;
begin
 if fCyclicState>=0 then begin
  result:=fCyclicState<>0;
 end else begin
  result:=false;
  if fDirty then begin
   Setup;
  end;
  if fCountKeys>0 then begin
   FillChar(fVisitedBitmap[0],fVisitedBitmapSize*SizeOf(TpvUInt32),#0);
   for Index:=0 to fCount-1 do begin
    Key:=fNodes[Index].Key;
    if (Key>=0) and (Key<fCountKeys) then begin
     StackPointer:=0;
     if length(fStack)<(StackPointer+2) then begin
      SetLength(fStack,(StackPointer+2)*2);
     end;
     fStack[StackPointer]:=Key;
     inc(StackPointer);
     while StackPointer>0 do begin
      dec(StackPointer);
      Key:=fStack[StackPointer];
      if Key<0 then begin
       Key:=-(Key+1);
       fVisitedBitmap[Key shr 5]:=fVisitedBitmap[Key shr 5] and not (TpvUInt32(1) shl (Key and 31));
      end else if (fVisitedBitmap[Key shr 5] and (TpvUInt32(1) shl (Key and 31)))=0 then begin
       fVisitedBitmap[Key shr 5]:=fVisitedBitmap[Key shr 5] or (TpvUInt32(1) shl (Key and 31));
 {$ifdef UseIndexingForTopologicalSorting}
       if fKeyToNodeIndex[Key]>=0 then begin
        Node:=@fNodes[fKeyToNodeIndex[Key]];
       end else begin
        Node:=nil;
       end;
 {$else}
       Node:=nil;
       for SubIndex:=0 to fCount-1 do begin
        if fNodes[SubIndex].Key=Key then begin
         Node:=@fNodes[SubIndex];
         break;
        end;
       end;
 {$endif}
       if assigned(Node) then begin
        CountDependOnKeys:=length(Node^.DependsOnKeys);
        if length(fStack)<(StackPointer+CountDependOnKeys+1) then begin
         SetLength(fStack,(StackPointer+CountDependOnKeys+1)*2);
        end;
        fStack[StackPointer]:=-(Key+1);
        inc(StackPointer);
        for SubIndex:=CountDependOnKeys-1 downto 0 do begin
         DependsOnKey:=Node^.DependsOnKeys[SubIndex];
         if (DependsOnKey>=0) and (DependsOnKey<fCountKeys) then begin
          fStack[StackPointer]:=DependsOnKey;
          inc(StackPointer);
         end;
        end;
       end;
      end else begin
       result:=true;
       break;
      end;
     end;
     if result then begin
      break;
     end;
    end;
   end;
  end;
  if result then begin
   fCyclicState:=1;
  end else begin
   fCyclicState:=0;
  end;
 end;
end;

constructor TpvTaggedTopologicalSort.TKey.Create(const aTag:TpvPtrUInt);
begin
 inherited Create;
 fTag:=aTag;
 fDependOnKeys:=nil;
 fCountDependOnKeys:=0;
 fVisitedState:=0;
 fIndex:=-1;
end;

destructor TpvTaggedTopologicalSort.TKey.Destroy;
begin
 fDependOnKeys:=nil;
 fCountDependOnKeys:=0;
 inherited Destroy;
end;

procedure TpvTaggedTopologicalSort.TKey.AddDependOnKey(const aKey:TpvTaggedTopologicalSort.TKey);
begin
 if length(fDependOnKeys)<=fCountDependOnKeys then begin
  SetLength(fDependOnKeys,(fCountDependOnKeys+1)*2);
 end;
 fDependOnKeys[fCountDependOnKeys]:=aKey;
 inc(fCountDependOnKeys);
end;

constructor TpvTaggedTopologicalSort.Create;
begin
 inherited Create;
 fKeys:=nil;
 fCountKeys:=0;
 fCyclic:=false;
end;

destructor TpvTaggedTopologicalSort.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TpvTaggedTopologicalSort.Clear;
var Index:TpvSizeInt;
begin
 for Index:=0 to fCountKeys-1 do begin
  FreeAndNil(fKeys[Index]);
 end;
 fKeys:=nil;
 fCountKeys:=0;
 fCyclic:=false;
end;

function TpvTaggedTopologicalSort.Add(const aTag:TpvPtrUInt):TpvTaggedTopologicalSort.TKey;
begin
 result:=TpvTaggedTopologicalSort.TKey.Create(aTag);
 if length(fKeys)<=fCountKeys then begin
  SetLength(fKeys,(fCountKeys+1)*2);
 end;
 fKeys[fCountKeys]:=result;
 inc(fCountKeys);
end;

procedure TpvTaggedTopologicalSort.AddDependOnKey(const aKey,aDependOnKey:TpvTaggedTopologicalSort.TKey);
begin
 aKey.AddDependOnKey(aDependOnKey);
end;

function TpvTaggedTopologicalSort.Solve(const aBackwards:Boolean):Boolean;
var Index,SubIndex,StackPointer,CountDependOnKeys,IndexCounter:TpvSizeInt;
    Key,DependsOnKey:TpvTaggedTopologicalSort.TKey;
    Stack:TpvTaggedTopologicalSort.TKeys;
begin

 fCyclic:=false;

 for Index:=0 to fCountKeys-1 do begin
  Key:=fKeys[Index];
  Key.fVisitedState:=0;
  Key.fIndex:=-1;
 end;

 Stack:=nil;
 try

  IndexCounter:=0;

  for Index:=0 to fCountKeys-1 do begin
   Key:=fKeys[Index];
   if Key.fVisitedState=0 then begin
    StackPointer:=0;
    if length(Stack)<(StackPointer+1) then begin
     SetLength(Stack,(StackPointer+1)*2);
    end; 
    Stack[StackPointer]:=Key;
    inc(StackPointer);
    while StackPointer>0 do begin
     dec(StackPointer);
     Key:=Stack[StackPointer];
     if assigned(Key) then begin
      case Key.fVisitedState of
       0:begin
        Key.fVisitedState:=1; // Visited and recursive relevant for cycle detection
        CountDependOnKeys:=Key.fCountDependOnKeys;
        if length(Stack)<(StackPointer+CountDependOnKeys+1) then begin
         SetLength(Stack,(StackPointer+CountDependOnKeys+1)*2);
        end;
        Stack[StackPointer]:=Key;
        inc(StackPointer);
        for SubIndex:=CountDependOnKeys-1 downto 0 do begin
         DependsOnKey:=Key.fDependOnKeys[SubIndex];
         if assigned(DependsOnKey) then begin
          case DependsOnKey.fVisitedState of
           0:begin
            Stack[StackPointer]:=DependsOnKey;
            inc(StackPointer);
           end;
           1:begin
            fCyclic:=true;
            break;            
           end;
           else begin
            // Nothing to do in this case 
           end;
          end;
         end;
        end;
        if fCyclic then begin
         break;
        end;
       end;
       1:begin
        Key.fVisitedState:=2; // Visited but no more recursive relevant for cycle detection
        Key.fIndex:=IndexCounter;
        inc(IndexCounter);
       end; 
       else begin
        // Nothing to do in this case 
       end;
      end;
     end;
    end;
   end;
  end;

 finally
  Stack:=nil;
 end;

 if aBackwards then begin
  for Index:=0 to fCountKeys-1 do begin
   Key:=fKeys[Index];
   Key.fIndex:=IndexCounter-(Key.fIndex+1);
  end;
 end;

 result:=not fCyclic;

end; 

function IsPathSeparator(const aChar:AnsiChar):Boolean;
begin
 case aChar of
  '/','\':begin
   result:=true;
  end;
  else begin
   result:=false;
  end;
 end;
end;

function CorrectPathSeparators(const aPath:TpvRawByteString):TpvRawByteString;
const DestinationPathSeparator={$ifdef Windows}'\'{$else}'/'{$endif};
var Index:TpvInt32;
begin
 result:=aPath;
 for Index:=1 to length(result) do begin
  if IsPathSeparator(result[Index]) then begin
   result[Index]:=DestinationPathSeparator;
  end;
 end;
end;

function ExpandRelativePath(const aRelativePath:TpvRawByteString;const aBasePath:TpvRawByteString=''):TpvRawByteString;
var InputIndex,OutputIndex:TpvInt32;
    InputPath:TpvRawByteString;
    PathSeparator:AnsiChar;
begin
 if (length(aRelativePath)>0) and
    (IsPathSeparator(aRelativePath[1]) or
     ((length(aRelativePath)>1) and
      (aRelativePath[1] in ['a'..'z','A'..'Z']) and
      (aRelativePath[2]=':'))) then begin
  InputPath:=aRelativePath;
 end else begin
  if (length(aBasePath)>1) and not IsPathSeparator(aBasePath[length(aBasePath)]) then begin
   PathSeparator:=#0;
   for InputIndex:=1 to length(aBasePath) do begin
    if IsPathSeparator(aBasePath[InputIndex]) then begin
     PathSeparator:=aBasePath[InputIndex];
     break;
    end;
   end;
   if PathSeparator=#0 then begin
    for InputIndex:=1 to length(aRelativePath) do begin
     if IsPathSeparator(aRelativePath[InputIndex]) then begin
      PathSeparator:=aRelativePath[InputIndex];
      break;
     end;
    end;
    if PathSeparator=#0 then begin
     PathSeparator:='/';
    end;
   end;
   InputPath:=aBasePath+PathSeparator;
  end else begin
   InputPath:=aBasePath;
  end;
  InputPath:=InputPath+aRelativePath;
 end;
 result:=InputPath;
 InputIndex:=1;
 OutputIndex:=1;
 while InputIndex<=length(InputPath) do begin
  if (((InputIndex+1)<=length(InputPath)) and (InputPath[InputIndex]='.') and IsPathSeparator(InputPath[InputIndex+1])) or
     ((InputIndex=length(InputPath)) and (InputPath[InputIndex]='.')) then begin
   inc(InputIndex,2);
   if OutputIndex=1 then begin
    inc(OutputIndex,2);
   end;
  end else if (((InputIndex+1)<=length(InputPath)) and (InputPath[InputIndex]='.') and (InputPath[InputIndex+1]='.')) and
              ((((InputIndex+2)<=length(InputPath)) and IsPathSeparator(InputPath[InputIndex+2])) or
               ((InputIndex+1)=length(InputPath))) then begin
   inc(InputIndex,3);
   if OutputIndex=1 then begin
    inc(OutputIndex,3);
   end else if OutputIndex>1 then begin
    dec(OutputIndex,2);
    while (OutputIndex>0) and not IsPathSeparator(result[OutputIndex]) do begin
     dec(OutputIndex);
    end;
    inc(OutputIndex);
   end;
  end else if IsPathSeparator(InputPath[InputIndex]) then begin
   if (InputIndex=1) and
      ((InputIndex+1)<=length(InputPath)) and
      IsPathSeparator(InputPath[InputIndex+1]) and
      ((length(InputPath)=2) or
       (((InputIndex+2)<=Length(InputPath)) and not IsPathSeparator(InputPath[InputIndex+2]))) then begin
    result[OutputIndex]:=InputPath[InputIndex];
    result[OutputIndex+1]:=InputPath[InputIndex+1];
    inc(InputIndex,2);
    inc(OutputIndex,2);
   end else begin
    if (OutputIndex=1) or ((OutputIndex>1) and not IsPathSeparator(result[OutputIndex-1])) then begin
     result[OutputIndex]:=InputPath[InputIndex];
     inc(OutputIndex);
    end;
    inc(InputIndex);
   end;
  end else begin
   while (InputIndex<=length(InputPath)) and not IsPathSeparator(InputPath[InputIndex]) do begin
    result[OutputIndex]:=InputPath[InputIndex];
    inc(InputIndex);
    inc(OutputIndex);
   end;
   if InputIndex<=length(InputPath) then begin
    result[OutputIndex]:=InputPath[InputIndex];
    inc(InputIndex);
    inc(OutputIndex);
   end;
  end;
 end;
 SetLength(result,OutputIndex-1);
end;

function ConvertPathToRelative(aAbsolutePath,aBasePath:TpvRawByteString):TpvRawByteString;
var AbsolutePathIndex,BasePathIndex:TpvInt32;
    PathSeparator:AnsiChar;
begin
 if length(aBasePath)=0 then begin
  result:=aAbsolutePath;
 end else begin
  aAbsolutePath:=ExpandRelativePath(aAbsolutePath);
  aBasePath:=ExpandRelativePath(aBasePath);
  PathSeparator:=#0;
  for BasePathIndex:=1 to length(aBasePath) do begin
   if IsPathSeparator(aBasePath[BasePathIndex]) then begin
    PathSeparator:=aBasePath[BasePathIndex];
    break;
   end;
  end;
  if PathSeparator=#0 then begin
   for AbsolutePathIndex:=1 to length(aAbsolutePath) do begin
    if IsPathSeparator(aAbsolutePath[AbsolutePathIndex]) then begin
     PathSeparator:=aAbsolutePath[AbsolutePathIndex];
     break;
    end;
   end;
   if PathSeparator=#0 then begin
    PathSeparator:='/';
   end;
  end;
  if length(aBasePath)>1 then begin
   if IsPathSeparator(aBasePath[length(aBasePath)]) then begin
    if (length(aAbsolutePath)>1) and IsPathSeparator(aAbsolutePath[length(aAbsolutePath)]) then begin
     if (aAbsolutePath=aBasePath) and (aAbsolutePath[1]<>'.') and (aBasePath[1]<>'.') then begin
      result:='.'+PathSeparator;
      exit;
     end;
    end;
   end else begin
    aBasePath:=aBasePath+PathSeparator;
   end;
  end;
  AbsolutePathIndex:=1;
  BasePathIndex:=1;
  while (BasePathIndex<=Length(aBasePath)) and
        (AbsolutePathIndex<=Length(aAbsolutePath)) and
        ((aBasePath[BasePathIndex]=aAbsolutePath[AbsolutePathIndex]) or
         (IsPathSeparator(aBasePath[BasePathIndex]) and IsPathSeparator(aAbsolutePath[AbsolutePathIndex]))) do begin
   inc(AbsolutePathIndex);
   inc(BasePathIndex);
  end;
  if ((BasePathIndex<=length(aBasePath)) and not IsPathSeparator(aBasePath[BasePathIndex])) or
     ((AbsolutePathIndex<=length(aAbsolutePath)) and not IsPathSeparator(aAbsolutePath[AbsolutePathIndex])) then begin
   while (BasePathIndex>1) and not IsPathSeparator(aBasePath[BasePathIndex-1]) do begin
    dec(AbsolutePathIndex);
    dec(BasePathIndex);
   end;
  end;
  if BasePathIndex<=Length(aBasePath) then begin
   result:='';
   while BasePathIndex<=Length(aBasePath) do begin
    if IsPathSeparator(aBasePath[BasePathIndex]) then begin
     result:=result+'..'+PathSeparator;
    end;
    inc(BasePathIndex);
   end;
  end else begin
   result:='.'+PathSeparator;
  end;
  if AbsolutePathIndex<=length(aAbsolutePath) then begin
   result:=result+copy(aAbsolutePath,AbsolutePathIndex,(length(aAbsolutePath)-AbsolutePathIndex)+1);
  end;
 end;
end;

function ExtractFilePath(aPath:TpvRawByteString):TpvRawByteString;
var Index:TpvInt32;
begin
 result:=aPath;
 for Index:=length(result) downto 1 do begin
  if IsPathSeparator(result[Index]) then begin
   SetLength(result,Index);
   exit;
  end;
 end;
end;

function GetCacheFileName(const aCacheStoragePath,aFileName:TpvUTF8String;const aRootPath:TpvUTF8String):TpvUTF8String;
begin
 if length(aCacheStoragePath)>0 then begin
  result:=ExpandRelativePath(ConvertPathToRelative(aFileName,aRootPath),
                             TpvUTF8String(IncludeTrailingPathDelimiter(String(aCacheStoragePath))));
 end else begin
  result:=aFileName;
 end;
end;

{$if not defined(fpc)}
// Delphi's ForceDirectories is not working as expected, so we need to implement our own 
function ForceDirectories(const aDirectory:TpvUTF8String):Boolean;
var Index:TpvInt32;
    Directory:TpvUTF8String;
begin
 Directory:=IncludeTrailingPathDelimiter(CorrectPathSeparators(aDirectory));
 for Index:=1 to length(Directory) do begin
  if IsPathSeparator(Directory[Index]) then begin
   try
    if not DirectoryExists(copy(Directory,1,Index)) then begin
     if not CreateDir(copy(Directory,1,Index)) then begin
      result:=false;
      exit;
     end;
    end;
   except
    result:=false;
    exit;
   end;
  end;
 end;
 result:=true;
end;
{$ifend}

function EnsureDirectoryExistsForFileName(const aFileName:TpvUTF8String):Boolean;
var FilePath:String;
begin
 FilePath:=ExtractFilePath(String(CorrectPathSeparators(aFileName)));
 result:=DirectoryExists(FilePath);
 if not result then begin
  result:=ForceDirectories(FilePath);
  if result then begin
   result:=DirectoryExists(FilePath);
  end;
 end;
end;

function SizeToHumanReadableString(const aSize:TpvUInt64):TpvRawByteString;
const Suffixes:array[0..5] of TpvRawByteString=('B','KiB','MiB','GiB','TiB','PiB');
var Index:TpvInt32;
    Size:TpvDouble;
begin
 Size:=aSize;
 Index:=0;
 while (Size>=1024.0) and (Index<5) do begin
  Size:=Size/1024.0;
  inc(Index);
 end;
 Str(Size:1:2,Result);
 result:=result+' '+Suffixes[Index];
end;

end.

