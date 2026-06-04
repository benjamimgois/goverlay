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
unit PasVulkan.Profiler;
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

uses {$ifdef windows}Windows,{$else}{$ifdef unix}BaseUnix,Unix,UnixType,{$endif}{$endif}SysUtils,Classes,SyncObjs,PasVulkan.Types;

type TpvProfiler=class
      public
       class procedure SectionBegin(const Name:TpvUTF8String); static; {$ifdef cpu386}register;{$endif}
       class procedure SectionEnd; static;  {$ifdef cpu386}register;{$endif}
     end;

implementation

{$ifdef PasVulkanProfiler}

const HashBits=16;
      HashSize=1 shl HashBits;
      HashMask=HashSize-1;

type PSectionAddressHashItem=^TSectionAddressHashItem;
     TSectionAddressHashItem=record
      GarbageCollectorNext:pointer;
      Next:PSectionAddressHashItem;
      ReturnAddress:pointer;
      Name:PAnsiChar; // Not a TpvUTF8String, because it is not a reference counted string, and all records should be non-managed types here for the "garbage collector"            
      Count:TpvInt64;
      TotalTime:TpvInt64;
      MinTime:TpvInt64;
      MaxTime:TpvInt64;
     end;

     PSectionAddressHashTable=^TSectionAddressHashTable;
     TSectionAddressHashTable=array[0..HashSize-1] of PSectionAddressHashItem;

     PPThreadStackItem=^PThreadStackItem;
     PThreadStackItem=^TThreadStackItem;
     TThreadStackItem=record
      GarbageCollectorNext:pointer;
      Next:PThreadStackItem;
      SectionAddress:PSectionAddressHashItem;
      StartTime:TpvInt64;
     end;

     PThreadStackHashItem=^TThreadStackHashItem;
     TThreadStackHashItem=record
      GarbageCollectorNext:pointer;
      Next:PThreadStackHashItem;
      ID:TpvPtrUInt;
      Stack:PThreadStackItem;
     end;

    PThreadStackHashTable=^TThreadStackHashTable;
    TThreadStackHashTable=array[0..HashSize-1] of PThreadStackHashItem;

var CriticalSection:TCriticalSection;
    GarbageCollectorRoot:pointer;
    SectionAddressHashTable:TSectionAddressHashTable;
    ThreadStackHashTable:TThreadStackHashTable;
    FreeThreadStackItems:PThreadStackItem;
    FrequencyShift,Frequency:TpvInt64;

procedure InitTimer;
begin
 FrequencyShift:=0;
{$ifdef windows}
 if QueryPerformanceFrequency(Frequency) then begin
  while (Frequency and $ffffffffe0000000)<>0 do begin
   Frequency:=Frequency shr 1;
   inc(FrequencyShift);
  end;
 end else begin
  Frequency:=1000;
 end;
{$else}
{$ifdef linux}
  Frequency:=1000000000;
{$else}
{$ifdef unix}
  Frequency:=1000000;
{$else}
  Frequency:=1000;
{$endif}
{$endif}
{$endif}
end;

function GetTime:TpvInt64;
{$ifdef linux}
var NowTimeSpec:TimeSpec;
    ia,ib:TpvInt64;
{$else}
{$ifdef unix}
var tv:timeval;
    tz:timezone;
    ia,ib:TpvInt64;
{$endif}
{$endif}
begin
{$ifdef windows}
 if not QueryPerformanceCounter(result) then begin
  result:=GetTickCount;
 end;
{$else}
{$ifdef linux}
 clock_gettime(CLOCK_MONOTONIC,@NowTimeSpec);
 ia:=TpvInt64(NowTimeSpec.tv_sec)*TpvInt64(1000000000);
 ib:=NowTimeSpec.tv_nsec;
 result:=ia+ib;
{$else}
{$ifdef unix}
  tz.tz_minuteswest:=0;
  tz.tz_dsttime:=0;
  fpgettimeofday(@tv,@tz);
  ia:=TpvInt64(tv.tv_sec)*TpvInt64(1000000);
  ib:=tv.tv_usec;
  result:=ia+ib;
{$else}
 result:=0;
{$endif}
{$endif}
{$endif}
 result:=result shr FrequencyShift;
end;

function GetStackForThread:PPThreadStackItem;
var ID,Hash,Index:TpvPtrUInt;
    Item:PThreadStackHashItem;
begin
{$ifdef windows}
 ID:=GetCurrentThreadID;
{$else}
{$ifdef fpc}
 ID:=GetThreadID;
{$else}
 ID:=0;
{$endif}
{$endif}
 Hash:=ID*TpvPtrUInt($9e3779b1);
 Index:=Hash and HashMask;
 Item:=ThreadStackHashTable[Index];
 while assigned(Item) do begin
  if Item^.ID=ID then begin
   result:=@Item^.Stack;
   exit;
  end;
  Item:=Item^.Next;
 end;
 GetMem(Item,SizeOf(TThreadStackHashItem));
 FillChar(Item^,SizeOf(TThreadStackHashItem),AnsiChar(#0));
 Item^.GarbageCollectorNext:=GarbageCollectorRoot;
 GarbageCollectorRoot:=Item;
 Item^.ID:=ID;
 Item^.Stack:=nil;
 Item^.Next:=ThreadStackHashTable[Index];
 ThreadStackHashTable[Index]:=Item;
 result:=@Item^.Stack;
end;

function GetSectionAddressHashItem(const Address:pointer):PSectionAddressHashItem;
var Hash,ID,Index:TpvPtrUInt;
begin
 ID:=TpvPtrUInt(Address);
 Hash:=ID*TpvPtrUInt($9e3779b1);
 Index:=Hash and HashMask;
 result:=SectionAddressHashTable[Index];
 while assigned(result) do begin
  if result^.ReturnAddress=Address then begin
   exit;
  end else begin
   result:=result^.Next;
  end;
 end;
 GetMem(result,SizeOf(TSectionAddressHashItem));
 FillChar(result^,SizeOf(TSectionAddressHashItem),AnsiChar(#0));
 result^.GarbageCollectorNext:=GarbageCollectorRoot;
 GarbageCollectorRoot:=result;
 result^.ReturnAddress:=Address;
 result^.Count:=0;
 result^.Next:=SectionAddressHashTable[Index];
 SectionAddressHashTable[Index]:=result;
end;

{$endif}

class procedure TpvProfiler.SectionBegin(const Name:TpvUTF8String); {$ifdef cpu386}register;{$endif}
{$ifdef PasVulkanProfiler}
var CurrentReturnAddress:pointer;
    NamePointer:PAnsiChar;
    NameLength:TpvSizeInt; 
    ThreadStackItem:PThreadStackItem;
    SectionAddressHashItem:PSectionAddressHashItem;
    SectionBeginStack:PPThreadStackItem;
begin
{$if defined(fpc)}
 CurrentReturnAddress:=Get_Caller_Addr(Get_Frame);
{$elseif declared(ReturnAddress)}
 CurrentReturnAddress:=System.ReturnAddress;
{$elseif defined(cpu386)}
 asm
  mov ecx,dword ptr [ebp+4]
  mov dword ptr CurrentReturnAddress,ecx
 end;
{$else}
 // WARNING: Not a clean solution! :-)
 CurrentReturnAddress:=pointer(pointer(TpvPtrUInt(TpvPtrUInt(pointer(@Name))+(sizeof(pointer)*2)))^);
{$ifend}
 CriticalSection.Enter;
 try
  SectionAddressHashItem:=GetSectionAddressHashItem(CurrentReturnAddress);
  NameLength:=Length(Name);
  if NameLength=0 then begin
   SectionAddressHashItem^.Name:=nil;
  end else begin
   GetMem(NamePointer,NameLength+1+SizeOf(pointer)); // additional space for the garbage collector next pointer
   FillChar(NamePointer^,NameLength+1+SizeOf(pointer),AnsiChar(#0));
   Pointer(NamePointer)^:=GarbageCollectorRoot;
   GarbageCollectorRoot:=NamePointer;
   inc(PpvUInt8(NamePointer),SizeOf(pointer)); // skip the garbage collector next pointer for payload of the string
   Move(Name[1],NamePointer^,NameLength); // copy the string to the allocated memory
   NamePointer[NameLength]:=#0; // add the null terminator
   SectionAddressHashItem^.Name:=NamePointer; // assign the pointer to the string to the hash item
  end;
  inc(SectionAddressHashItem^.Count);
  if assigned(FreeThreadStackItems) then begin
   ThreadStackItem:=FreeThreadStackItems;
   FreeThreadStackItems:=ThreadStackItem^.Next;
  end else begin
   GetMem(ThreadStackItem,SizeOf(TThreadStackItem));
   FillChar(ThreadStackItem^,SizeOf(TThreadStackItem),AnsiChar(#0));
   ThreadStackItem^.GarbageCollectorNext:=GarbageCollectorRoot;
   GarbageCollectorRoot:=ThreadStackItem;
  end;
  SectionBeginStack:=GetStackForThread;
  ThreadStackItem^.SectionAddress:=SectionAddressHashItem;
  ThreadStackItem^.Next:=SectionBeginStack^;
  SectionBeginStack^:=ThreadStackItem;
  ThreadStackItem^.StartTime:=GetTime;
 finally
  CriticalSection.Leave;
 end;
end;
{$else}
begin
end;
{$endif}

class procedure TpvProfiler.SectionEnd; {$ifdef cpu386}register;{$endif}
{$ifdef PasVulkanProfiler}
var EndTime,TimeDifference:TpvInt64;
    SectionBeginStack:PPThreadStackItem;
    SectionAddressHashItem:PSectionAddressHashItem;
    ThreadStackItem:PThreadStackItem;
begin
 EndTime:=GetTime;
 CriticalSection.Enter;
 try
  SectionBeginStack:=GetStackForThread;
  if assigned(SectionBeginStack) then begin
   SectionAddressHashItem:=SectionBeginStack^^.SectionAddress;
   TimeDifference:=EndTime-SectionBeginStack^^.StartTime;
   inc(SectionAddressHashItem^.TotalTime,TimeDifference);
   if SectionAddressHashItem^.Count<=1 then begin
    SectionAddressHashItem^.MinTime:=TimeDifference;
    SectionAddressHashItem^.MaxTime:=TimeDifference;
   end else begin
    if SectionAddressHashItem^.MinTime>TimeDifference then begin
     SectionAddressHashItem^.MinTime:=TimeDifference;
    end;
    if SectionAddressHashItem^.MaxTime<TimeDifference then begin
     SectionAddressHashItem^.MaxTime:=TimeDifference;
    end;
   end;
   ThreadStackItem:=SectionBeginStack^^.Next;
   SectionBeginStack^^.Next:=FreeThreadStackItems;
   FreeThreadStackItems:=SectionBeginStack^;
   SectionBeginStack^:=ThreadStackItem;
  end;
 finally
  CriticalSection.Leave;
 end;
end;
{$else}
begin
end;
{$endif}

{$ifdef PasVulkanProfiler}
{$ifdef PasVulkanProfilerPopStackAtEnd}
procedure PopStack;
var Index:TpvSizeInt;
    EndTime,TimeDifference:TpvInt64;
    ThreadStackHashItem:PThreadStackHashItem;
    ThreadStackItem:PThreadStackItem;
    SectionAddressHashItem:PSectionAddressHashItem;
begin
 EndTime:=GetTime;
 CriticalSection.Enter;
 try
  for Index:=low(TThreadStackHashTable) to high(TThreadStackHashTable) do begin
   ThreadStackHashItem:=ThreadStackHashTable[Index];
   while assigned(ThreadStackHashItem) do begin
    ThreadStackItem:=ThreadStackHashItem^.Stack;
    while assigned(ThreadStackItem) do begin
     if assigned(ThreadStackItem^.SectionAddress) then begin
      SectionAddressHashItem:=ThreadStackItem^.SectionAddress;
      TimeDifference:=EndTime-ThreadStackItem^.StartTime;
      inc(SectionAddressHashItem^.TotalTime,TimeDifference);
      if SectionAddressHashItem^.Count<=1 then begin
       SectionAddressHashItem^.MinTime:=TimeDifference;
       SectionAddressHashItem^.MaxTime:=TimeDifference;
      end else begin
       if SectionAddressHashItem^.MinTime>TimeDifference then begin
        SectionAddressHashItem^.MinTime:=TimeDifference;
       end;
       if SectionAddressHashItem^.MaxTime<TimeDifference then begin
        SectionAddressHashItem^.MaxTime:=TimeDifference;
       end;
      end;
     end;
     ThreadStackItem:=ThreadStackItem^.Next;
    end;
    ThreadStackHashItem:=ThreadStackHashItem^.Next;
   end;
  end;
 finally
  CriticalSection.Leave;
 end;
end;
{$endif}

procedure OutputResults;
type TItem=record
      Name:TpvUTF8String;
      Count:TpvInt64;
      TotalTime:double;
      MinTime:double;
      MaxTime:double;
      AverageTime:double;
     end;
     PItem=^TItem;
     TItems=array of TItem;
var Index,Count:TpvSizeInt;
    Items:TItems;
    Item:PItem;
    TempItem:TItem;
    tf:TextFile;
    SectionAddressHashItem:PSectionAddressHashItem;
begin
 Items:=nil;
 try
  Count:=0;
  for Index:=low(TSectionAddressHashTable) to high(TSectionAddressHashTable) do begin
   SectionAddressHashItem:=SectionAddressHashTable[Index];
   while assigned(SectionAddressHashItem) do begin
    inc(Count);
    SectionAddressHashItem:=SectionAddressHashItem^.Next;
   end;
  end;
  SetLength(Items,Count);
  Count:=0;
  for Index:=low(TSectionAddressHashTable) to high(TSectionAddressHashTable) do begin
   SectionAddressHashItem:=SectionAddressHashTable[Index];
   while assigned(SectionAddressHashItem) do begin
    Item:=@Items[Count];
    Item^.Name:=SectionAddressHashItem^.Name;
    Item^.Count:=SectionAddressHashItem^.Count;
    Item^.TotalTime:=SectionAddressHashItem^.TotalTime/Frequency;
    Item^.MinTime:=SectionAddressHashItem^.MinTime/Frequency;
    Item^.MaxTime:=SectionAddressHashItem^.MaxTime/Frequency;
    Item^.AverageTime:=Item^.TotalTime/Item^.Count;
    inc(Count);
    SectionAddressHashItem:=SectionAddressHashItem^.Next;
   end;
  end;
  Index:=0;
  while (Index+1)<Count do begin
   if Items[Index].MaxTime<Items[Index+1].MaxTime then begin
    TempItem:=Items[Index];
    Items[Index]:=Items[Index+1];
    Items[Index+1]:=TempItem;
    if Index>0 then begin
     dec(Index);
    end else begin
     inc(Index);
    end;
   end else begin
    inc(Index);
   end;
  end;
  AssignFile(tf,'profiling_results.csv');
  try
   {$i-}Rewrite(tf);{$i+}
   if IOResult=0 then begin
    writeln(tf,'Name;Count;Total time (s);Min. time (s);Max. time (s);Average time(s)');
    for Index:=0 to Count-1 do begin
     Item:=@Items[Index];
     writeln(tf,Item^.Name,';',
                Item^.Count,';',
                Item^.TotalTime:1:16,';',
                Item^.MinTime:1:16,';',
                Item^.MaxTime:1:16,';',
                Item^.AverageTime:1:16);
    end;
    Flush(tf);
   end;
  finally
   CloseFile(tf);
  end;
  AssignFile(tf,'profiling_results.txt');
  try
   {$i-}Rewrite(tf);{$i+}
   if IOResult=0 then begin
    writeln(tf,'Name':64,' ',
               'Count':24,' ',
               'Total time (s)':24,' ',
               'Min. time (s)':24,' ',
               'Max. time (s)':24,' ',
               'Average time (s)':24);
    for Index:=0 to Count-1 do begin
     Item:=@Items[Index];
     writeln(tf,Item^.Name:64,' ',
                Item^.Count:24,' ',
                Item^.TotalTime:24:16,' ',
                Item^.MinTime:24:16,' ',
                Item^.MaxTime:24:16,' ',
                Item^.AverageTime:24:16);
    end;
    Flush(tf);
   end;
  finally
   CloseFile(tf);
  end;
 finally
  SetLength(Items,0);
 end;
end;

procedure CleanUp;
var Current,Next:pointer;
begin
 CriticalSection.Enter;
 try
  Current:=GarbageCollectorRoot;
  GarbageCollectorRoot:=nil;
  while assigned(Current) do begin
   Next:=pointer(Current^);
   FreeMem(Current);
   Current:=Next;
  end;
 finally
  CriticalSection.Leave;
 end;
end;
{$endif}

initialization
{$ifdef PasVulkanProfiler}
 InitTimer;
 CriticalSection:=TCriticalSection.Create;
 GarbageCollectorRoot:=nil;
 FillChar(SectionAddressHashTable,SizeOf(TSectionAddressHashTable),AnsiChar(#0));
 FillChar(ThreadStackHashTable,SizeOf(ThreadStackHashTable),AnsiChar(#0));
 FreeThreadStackItems:=nil;
{$endif}
finalization
{$ifdef PasVulkanProfiler}
{$ifdef PasVulkanProfilerPopStackAtEnd}
 PopStack;
{$endif}
 OutputResults;
 CleanUp;
 CriticalSection.Free;
{$endif}
end.