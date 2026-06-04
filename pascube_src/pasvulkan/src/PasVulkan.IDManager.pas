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
unit PasVulkan.IDManager;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}

interface

uses SysUtils,
     Classes,
     PasMP,
     PasVulkan.Types,
     PasVulkan.Collections;

type EpvIDManager=class(Exception);

     TpvGenericIDManager<T>=class
      private
       type TIDManagerIntegerList=TpvGenericList<T>;
      private
       fCriticalSection:TPasMPCriticalSection;
       fIDCounter:T;
       fIDFreeList:TIDManagerIntegerList;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       function AllocateID:T;
       procedure FreeID(aID:T);
       property IDCounter:T read fIDCounter;
       property IDFreeList:TIDManagerIntegerList read fIDFreeList;
     end;

     TpvIDManager=class
      private
       type TIDManagerFreeStack=TPasMPUnboundedStack<TpvUInt32>;
{$ifdef Debug}
            TIDManagerGenerationArray=array of TpvUInt32;
            TIDManagerTypeArray=array of TpvUInt32;
            TIDManagerUsedBitmap=array of TpvUInt32;
{$endif}
      private
       fIDCounter:TpvUInt32;
       fFreeStack:TIDManagerFreeStack;
{$ifdef Debug}
       fMultipleReaderSingleWriterLock:TPasMPMultipleReaderSingleWriterLock;
       fGenerationArray:TIDManagerGenerationArray;
       fTypeArray:TIDManagerTypeArray;
       fUsedBitmap:TIDManagerUsedBitmap;
{$else}
       fGenerationCounter:TpvUInt32;
{$endif}
      public
       constructor Create;
       destructor Destroy; override;
       function AllocateID(const aType:TpvUInt32=0):TpvID;
       function CheckID(const aID:TpvID):boolean;
       procedure FreeID(const aID:TpvID);
       property IDCounter:TpvUInt32 read fIDCounter;
     end;

implementation

constructor TpvGenericIDManager<T>.Create;
begin
 inherited Create;
 fCriticalSection:=TPasMPCriticalSection.Create;
 FillChar(fIDCounter,SizeOf(T),#0);
 case SizeOf(T) of
  1:begin
   inc(PpvUInt8(@fIDCounter)^);
  end;
  2:begin
   inc(PpvUInt16(@fIDCounter)^);
  end;
  4:begin
   inc(PpvUInt32(@fIDCounter)^);
  end;
  8:begin
   inc(PpvUInt64(@fIDCounter)^);
  end;
  else begin
   Assert(false);
  end;
 end;
 fIDFreeList:=TIDManagerIntegerList.Create;
end;

destructor TpvGenericIDManager<T>.Destroy;
begin
 fIDFreeList.Free;
 fCriticalSection.Free;
 inherited Destroy;
end;

function TpvGenericIDManager<T>.AllocateID:T;
begin
 fCriticalSection.Enter;
 try
  if fIDFreeList.Count>0 then begin
   result:=fIDFreeList.Items[fIDFreeList.Count-1];
   fIDFreeList.Delete(fIDFreeList.Count-1);
  end else begin
   result:=fIDCounter;
   case SizeOf(T) of
    1:begin
     inc(PpvUInt8(@fIDCounter)^);
    end;
    2:begin
     inc(PpvUInt16(@fIDCounter)^);
    end;
    4:begin
     inc(PpvUInt32(@fIDCounter)^);
    end;
    8:begin
     inc(PpvUInt64(@fIDCounter)^);
    end;
    else begin
     Assert(false);
    end;
   end;
  end;
 finally
  fCriticalSection.Leave;
 end;
end;

procedure TpvGenericIDManager<T>.FreeID(aID:T);
begin
 fCriticalSection.Enter;
 try
  fIDFreeList.Add(aID);
 finally
  fCriticalSection.Leave;
 end;
end;

constructor TpvIDManager.Create;
begin
 inherited Create;
 TPasMPInterlocked.Write(fIDCounter,0);
 fFreeStack:=TIDManagerFreeStack.Create;
{$ifdef Debug}
 fMultipleReaderSingleWriterLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 fGenerationArray:=nil;
 fTypeArray:=nil;
 fUsedBitmap:=nil;
{$else}
 fGenerationCounter:=0;
{$endif}
end;

destructor TpvIDManager.Destroy;
begin
 fFreeStack.Free;
{$ifdef Debug}
 fMultipleReaderSingleWriterLock.Free;
 fGenerationArray:=nil;
 fTypeArray:=nil;
 fUsedBitmap:=nil;
{$endif}
 inherited Destroy;
end;

function TpvIDManager.AllocateID(const aType:TpvUInt32=0):TpvID;
{$ifdef Debug}
var NewSize,OldSize,Index,Generation:TpvUInt32;
begin
 Index:=0;
 if fFreeStack.Pop(Index) then begin
  fMultipleReaderSingleWriterLock.AcquireRead;
  try
   Generation:=fGenerationArray[Index];
   fTypeArray[Index]:=aType;
   TPasMPInterlocked.BitwiseOr(fUsedBitmap[Index shr 5],TpvUInt32(1) shl (Index and 31));
  finally
   fMultipleReaderSingleWriterLock.ReleaseRead;
  end;
 end else begin
  Index:=TPasMPInterlocked.Increment(fIDCounter);
  if Index=0 then begin
   Index:=TPasMPInterlocked.Increment(fIDCounter);
  end;
  Generation:=0;
  fMultipleReaderSingleWriterLock.AcquireRead;
  try
   begin
    OldSize:=length(fGenerationArray);
    if OldSize<=Index then begin
     NewSize:=(Index+1) shl 1;
     if OldSize<NewSize then begin
      fMultipleReaderSingleWriterLock.ReadToWrite;
      try
       OldSize:=length(fGenerationArray);
       if OldSize<NewSize then begin
        SetLength(fGenerationArray,NewSize);
        FillChar(fGenerationArray[OldSize],(NewSize-OldSize)*SizeOf(TpvUInt32),#$ff);
       end;
      finally
       fMultipleReaderSingleWriterLock.WriteToRead;
      end;
     end;
    end;
   end;
   begin
    OldSize:=length(fTypeArray);
    if OldSize<=Index then begin
     NewSize:=(Index+1) shl 1;
     if OldSize<NewSize then begin
      fMultipleReaderSingleWriterLock.ReadToWrite;
      try
       OldSize:=length(fTypeArray);
       if OldSize<NewSize then begin
        SetLength(fTypeArray,NewSize);
        FillChar(fTypeArray[OldSize],(NewSize-OldSize)*SizeOf(TpvUInt32),#$ff);
       end;
      finally
       fMultipleReaderSingleWriterLock.WriteToRead;
      end;
     end;
    end;
   end;
   begin
    OldSize:=length(fUsedBitmap);
    NewSize:=(Index+31) shr 5;
    if OldSize<=NewSize then begin
     NewSize:=(NewSize+1) shl 1;
     if OldSize<NewSize then begin
      fMultipleReaderSingleWriterLock.ReadToWrite;
      try
       OldSize:=length(fUsedBitmap);
       if OldSize<NewSize then begin
        SetLength(fUsedBitmap,NewSize);
        FillChar(fUsedBitmap[OldSize],(NewSize-OldSize)*SizeOf(TpvUInt32),#$00);
       end;
      finally
       fMultipleReaderSingleWriterLock.WriteToRead;
      end;
     end;
    end;
   end;
   fGenerationArray[Index]:=0;
   fTypeArray[Index]:=aType;
   TPasMPInterlocked.BitwiseOr(fUsedBitmap[Index shr 5],TpvUInt32(1) shl (Index and 31));
  finally
   fMultipleReaderSingleWriterLock.ReleaseRead;
  end;
 end;
 result:=(Index and $ffffffff) or (TpvUInt64(Generation and $ffff) shl 32) or (TpvUInt64(aType and $ffff) shl 48);
end;
{$else}
var Index:TpvUInt32;
begin
 if not fFreeStack.Pop(Index) then begin
  Index:=TPasMPInterlocked.Increment(fIDCounter);
  if Index=0 then begin
   Index:=TPasMPInterlocked.Increment(fIDCounter);
  end;
 end;
 result:=Index or (TpvUInt64(TPasMPInterlocked.Increment(fGenerationCounter)) shl 32);
end;
{$endif}

function TpvIDManager.CheckID(const aID:TpvID):boolean;
{$ifdef Debug}
var Index,Generation,Type_:TpvUInt32;
begin
 Index:=aID and $ffffffff;
 if Index<>0 then begin
  Generation:=(aID shr 32) and $ffff;
  Type_:=(aID shr 48) and $ffff;
  fMultipleReaderSingleWriterLock.AcquireRead;
  try
   result:=((Index<TpvUInt32(length(fGenerationArray))) and (Generation=fGenerationArray[Index])) and
           ((Index<TpvUInt32(length(fTypeArray))) and  (Type_=fTypeArray[Index])) and
           ((fUsedBitmap[Index shr 5] and (TpvUInt32(1) shl (Index and 31)))<>0);
  finally
   fMultipleReaderSingleWriterLock.ReleaseRead;
  end;
 end else begin
  result:=false;
 end;
end;
{$else}
begin
 result:=(aID and $ffffffff)<>0;
end;
{$endif}

procedure TpvIDManager.FreeID(const aID:TpvID);
{$ifdef Debug}
var Index,Generation,Type_:TpvUInt32;
begin
 Index:=aID and $ffffffff;
 if Index<>0 then begin
  Generation:=(aID shr 32) and $ffff;
  Type_:=(aID shr 48) and $ffff;
  fMultipleReaderSingleWriterLock.AcquireRead;
  try
   if ((Index<TpvUInt32(length(fGenerationArray))) and (Generation=fGenerationArray[Index])) and
      ((Index<TpvUInt32(length(fTypeArray))) and  (Type_=fTypeArray[Index])) and
      ((fUsedBitmap[Index shr 5] and (TpvUInt32(1) shl (Index and 31)))<>0) then begin
    fGenerationArray[Index]:=(fGenerationArray[Index]+1) and $ffff;
    fTypeArray[Index]:=$ffffffff;
    TPasMPInterlocked.BitwiseAnd(fUsedBitmap[Index shr 5],not (TpvUInt32(1) shl (Index and 31)));
    fFreeStack.Push(Index);
   end else begin
    if (Index<TpvUInt32(length(fGenerationArray))) and (Generation<>fGenerationArray[Index]) then begin
     raise EpvIDManager.Create('ID #'+IntToStr(Index)+' has wrong generation #'+IntToStr(Generation));
    end else if (Index<TpvUInt32(length(fTypeArray))) and (Type_<>fTypeArray[Index]) then begin
     raise EpvIDManager.Create('ID #'+IntToStr(Index)+' has wrong type #'+IntToStr(Type_));
    end else begin
     raise EpvIDManager.Create('ID #'+IntToStr(Index)+' lookup error');
    end;
   end;
  finally
   fMultipleReaderSingleWriterLock.ReleaseRead;
  end;
 end else begin
  raise EpvIDManager.Create('ID #'+IntToStr(Index)+' has a null index');
 end;
end;
{$else}
begin
//Assert((aID and $ffffffff)<>0);
 fFreeStack.Push(aID and $ffffffff);
end;
{$endif}

end.
