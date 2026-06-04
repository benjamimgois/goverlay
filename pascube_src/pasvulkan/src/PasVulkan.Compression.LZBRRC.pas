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
unit PasVulkan.Compression.LZBRRC;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$rangechecks off}
{$overflowchecks off}

{$ifdef fpc}
 {$optimization off}
 {$optimization level1}
{$endif}

interface

uses SysUtils,
     Classes,
     Math,
     PasVulkan.Math,
     PasVulkan.Types;

// LZBRRC is a LZ77-based compression algorithm but with range coding for the entropy coding, so it
// is pretty fast and it does also compress very well, but LZMA is still better at the compression
// ratio. LZBRRC is also very fast at decompression, so it is a good choice for games, because it is
// fast at both compression and decompression, and it compresses very well, so it saves a lot of space.

type TpvLZBRRCLevel=0..9;
     PpvLZBRRCLevel=^TpvLZBRRCLevel;

function LZBRRCCompress(const aInData:TpvPointer;const aInLen:TpvUInt64;out aDestData:TpvPointer;out aDestLen:TpvUInt64;const aLevel:TpvLZBRRCLevel=5;const aWithSize:boolean=true):boolean;

{$if defined(fpc) and defined(cpuamd64)}
function LZBRRCFastDecompress(const aInData:TpvPointer;aInLen:TpvUInt64;var aDestData:TpvPointer;out aDestLen:TpvUInt64;const aOutputSize:TpvInt64=-1;const aWithSize:boolean=true):boolean;
{$ifend}

function LZBRRCDecompress(const aInData:TpvPointer;aInLen:TpvUInt64;var aDestData:TpvPointer;out aDestLen:TpvUInt64;const aOutputSize:TpvInt64=-1;const aWithSize:boolean=true):boolean;

implementation

{$if not declared(BSRDWord)}
{$if defined(cpu386)}
function BSRDWord(Value:TpvUInt32):TpvUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 bsr eax,eax
 jnz @Done
 mov eax,255
@Done:
end;
{$elseif defined(cpuamd64) or defined(cpux64)}
function BSRDWord(Value:TpvUInt32):TpvUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsr eax,ecx
{$else}
 bsr eax,edi
{$endif}
 jnz @Done
 mov eax,255
@Done:
end;
{$else}
function BSRDWord(Value:TpvUInt32):TpvUInt32;
const BSRDebruijn32Multiplicator=TpvUInt32($07c4acdd);
      BSRDebruijn32Shift=27;
      BSRDebruijn32Mask=31;
      BSRDebruijn32Table:array[0..31] of TpvInt32=(0,9,1,10,13,21,2,29,11,14,16,18,22,25,3,30,8,12,20,28,15,17,24,7,19,27,23,6,26,5,4,31);
begin
 if Value=0 then begin
  result:=255;
 end else begin
  Value:=Value or (Value shr 1);
  Value:=Value or (Value shr 2);
  Value:=Value or (Value shr 4);
  Value:=Value or (Value shr 8);
  Value:=Value or (Value shr 16);
  result:=BSRDebruijn32Table[((Value*BSRDebruijn32Multiplicator) shr BSRDebruijn32Shift) and BSRDebruijn32Mask];
 end;
end;
{$ifend}
{$ifend}

const FlagModel=0;
      PreviousMatchModel=2;
      MatchLowModel=3;
      LiteralModel=35;
      Gamma0Model=291;
      Gamma1Model=547;
      SizeModels=803;
      HashBits=12;
      HashSize=1 shl HashBits;
      HashMask=HashSize-1;
      HashShift=32-HashBits;
      WindowSize=32768;
      WindowMask=WindowSize-1;
      MinMatch=2;
      MaxMatch=$20000000;
      MaxOffset=$40000000;

procedure BytewiseMemoryMove(const aSource;var aDestination;const aLength:TpvSizeUInt);{$if defined(CPU386)} register; assembler; {$ifdef fpc}nostackframe;{$endif}
asm
 push esi
 push edi
 mov esi,eax
 mov edi,edx
 cld
 rep movsb
 pop edi
 pop esi
end;
{$elseif defined(CPUAMD64) or defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 // Win64 ABI: rcx, rdx, r8, r9, rest on stack (scratch registers: rax, rcx, rdx, r8, r9, r10, r11)
 push rdi
 push rsi
 mov rsi,rcx
 mov rdi,rdx
 mov rcx,r8
{$else}
 // SystemV ABI: rdi, rsi, rdx, rcx, r8, r9, rest on stack (scratch registers: rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11)
 xchg rsi,rdi
 mov rcx,rdx
{$endif}
 cld
 rep movsb
{$ifdef win64}
 pop rsi
 pop rdi
{$endif}
end;
{$else}
var Index:TpvSizeUInt;
    Source,Destination:PpvUInt8Array;
begin
 if aLength>0 then begin
  Source:=TpvPointer(@aSource);
  Destination:=TpvPointer(@aDestination);
  for Index:=0 to aLength-1 do begin
   Destination^[Index]:=Source^[Index];
  end;
 end;
end;
{$ifend}

procedure RLELikeSideEffectAwareMemoryMove(const aSource;var aDestination;const aLength:TpvSizeUInt);
begin
 if aLength>0 then begin
  if ({%H-}TpvSizeUInt(TpvPointer(@aSource))+aLength)<={%H-}TpvSizeUInt(TpvPointer(@aDestination)) then begin
   // Non-overlapping, so we an use an optimized memory move function
   Move(aSource,aDestination,aLength);
  end else begin
   // Overlapping, so we must do copy byte-wise for to get the free RLE-like side-effect included
   BytewiseMemoryMove(aSource,aDestination,aLength);
  end;
 end;
end;

function LZBRRCCompress(const aInData:TpvPointer;const aInLen:TpvUInt64;out aDestData:TpvPointer;out aDestLen:TpvUInt64;const aLevel:TpvLZBRRCLevel;const aWithSize:boolean):boolean;
const HashBits=16;
      HashSize=1 shl HashBits;
      HashMask=HashSize-1;
      HashShift=32-HashBits;
      WindowSize=32768;
      WindowMask=WindowSize-1;
      MinMatch=3;
      MaxMatch=258;
      MaxOffset=TpvUInt32($7fffffff);
      MultiplyDeBruijnBytePosition:array[0..31] of TpvUInt8=(0,0,3,0,3,1,3,0,3,2,2,1,3,2,0,1,3,3,1,2,2,2,2,0,3,1,2,0,1,0,1,1);
type PHashTable=^THashTable;
     THashTable=array[0..HashSize-1] of PpvUInt8;
     PChainTable=^TChainTable;
     TChainTable=array[0..WindowSize-1] of TpvPointer;
     PThreeBytes=^TThreeBytes;
     TThreeBytes=array[0..2] of TpvUInt8;
     PBytes=^TBytes;
     TBytes=array[0..$7ffffffe] of TpvUInt8;
var CurrentPointer,EndPointer,EndSearchPointer,Head,CurrentPossibleMatch:PpvUInt8;
    BestMatchDistance,BestMatchLength,MatchLength,Step,MaxSteps,
    Difference,Offset,SkipStrength,UnsuccessfulFindMatchAttempts:TpvUInt32;
    HashTable:PHashTable;
    ChainTable:PChainTable;
    HashTableItem:PPpvUInt8;
    Greedy:boolean;
    LiteralStart:PpvUInt8;
    LiteralLength:TpvUInt64;
    AllocatedDestSize:TpvUInt64;
    {$ifndef CPU64}Code,{$endif}Range,Cache,CountFFBytes,LastMatchDistance:TpvUInt32;
    {$ifdef CPU64}Code:TpvUInt64;{$endif}
    Model:array[0..SizeModels-1] of TpvUInt32;
    LastWasMatch,FirstByte,First{$ifndef CPU64},Carry{$endif},OK:boolean;
    MinDestLen:TpvUInt32;
 procedure EncoderShift;
{$ifdef CPU64}
 var Carry:boolean;
{$endif}
 begin
{$ifdef CPU64}
  Carry:=(Code and TpvUInt64($ffffffff00000000))<>0;
{$endif}
  if (Code<$ff000000) or Carry then begin
   if FirstByte then begin
    FirstByte:=false;
   end else begin
    if AllocatedDestSize<(aDestLen+1) then begin
     AllocatedDestSize:=(aDestLen+1) shl 1;
     ReallocMem(aDestData,AllocatedDestSize);
    end;
    PpvUInt8Array(aDestData)^[aDestLen]:=Cache+TpvUInt8(ord(Carry) and 1);
    inc(aDestLen);
   end;
   while CountFFBytes<>0 do begin
    dec(CountFFBytes);
    if AllocatedDestSize<(aDestLen+1) then begin
     AllocatedDestSize:=(aDestLen+1) shl 1;
     ReallocMem(aDestData,AllocatedDestSize);
    end;
    PpvUInt8Array(aDestData)^[aDestLen]:=$ff+TpvUInt8(ord(Carry) and 1);
    inc(aDestLen);
   end;
   Cache:=(Code shr 24) and $ff;
  end else begin
   inc(CountFFBytes);
  end;
  Code:=(Code shl 8){$ifdef CPU64}and TpvUInt32($ffffffff){$endif};
  Carry:=false;
 end;
 function EncodeBit(ModelIndex,Move,Bit:TpvInt32):TpvInt32;
 var Bound{$ifndef CPU64},OldCode{$endif}:TpvUInt32;
 begin
  Bound:=(Range shr 12)*Model[ModelIndex];
  if Bit=0 then begin
   Range:=Bound;
   inc(Model[ModelIndex],(4096-Model[ModelIndex]) shr Move);
  end else begin
{$ifndef CPU64}
   OldCode:=Code;
{$endif}
   inc(Code,Bound);
{$ifndef CPU64}
   Carry:=Carry or (Code<OldCode);
{$endif}
   dec(Range,Bound);
   dec(Model[ModelIndex],Model[ModelIndex] shr Move);
  end;
  while Range<$1000000 do begin
   Range:=Range shl 8;
   EncoderShift;
  end;
  result:=Bit;
 end;
 procedure EncoderFlush;
 var Counter:TpvInt32;
 begin
  for Counter:=1 to 5 do begin
   EncoderShift;
  end;
 end;
 procedure EncodeTree(ModelIndex,Bits,Move,Value:TpvInt32);
 var Context:TpvInt32;
 begin
  Context:=1;
  while Bits>0 do begin
   dec(Bits);
   Context:=(Context shl 1) or EncodeBit(ModelIndex+Context,Move,(Value shr Bits) and 1);
  end;
 end;
 procedure EncodeGamma(ModelIndex,Value:TpvUInt32);
{$if true}
 var Index:TpvInt32;
     Context:TpvUInt8;
 begin
  Context:=1;
  for Index:=Max(1,BSRDWord(Value))-1 downto 0 do begin
   Context:=(Context shl 1) or TpvUInt32(EncodeBit(ModelIndex+Context,5,TpvUInt32(-Index) shr 31));
   Context:=(Context shl 1) or TpvUInt32(EncodeBit(ModelIndex+Context,5,TpvUInt32(-((Value shr Index) and 1)) shr 31));
  end;
 end;
{$else}
 var Mask:TpvUInt32;
     Context:TpvUInt8;
 begin
  Mask:=Value shr 1;
  while (Mask and (Mask-1))<>0 do begin
   Mask:=Mask and (Mask-1);
  end;
  Context:=1;
  while Mask<>0 do begin
   Context:=(Context shl 1) or TpvUInt32(EncodeBit(ModelIndex+Context,5,TpvUInt32(-(Mask shr 1)) shr 31));
   Context:=(Context shl 1) or TpvUInt32(EncodeBit(ModelIndex+Context,5,TpvUInt32(-(Value and Mask)) shr 31));
   Mask:=Mask shr 1;
  end;
 end;
{$ifend}
 procedure EncodeEnd(ModelIndex:TpvInt32);
 var Bits:TpvUInt32;
     Context:TpvUInt8;
 begin
  Context:=1;
  Bits:=32;
  while Bits>0 do begin
   dec(Bits);
   Context:=(Context shl 1) or EncodeBit(ModelIndex+Context,5,TpvUInt32(-Bits) shr 31);
   EncodeBit(ModelIndex+Context,5,0);
   Context:=Context shl 1;
  end;
 end;
 procedure DoOutputUInt64(const aValue:TpvUInt64);
 begin
{$ifdef LITTLE_ENDIAN}
  if AllocatedDestSize<(aDestLen+SizeOf(TpvUInt64)) then begin
   AllocatedDestSize:=(aDestLen+SizeOf(TpvUInt64)) shl 1;
   ReallocMem(aDestData,AllocatedDestSize);
  end;
  PpvUInt64(Pointer(@PBytes(aDestData)^[aDestLen]))^:=aValue;
  inc(aDestLen,SizeOf(TpvUInt64));
{$else}
  DoOutputUInt8((aValue shr 0) and $ff);
  DoOutputUInt8((aValue shr 8) and $ff);
  DoOutputUInt8((aValue shr 16) and $ff);
  DoOutputUInt8((aValue shr 24) and $ff);
  DoOutputUInt8((aValue shr 32) and $ff);
  DoOutputUInt8((aValue shr 40) and $ff);
  DoOutputUInt8((aValue shr 48) and $ff);
  DoOutputUInt8((aValue shr 56) and $ff);
{$endif}
 end;
begin
 result:=false;
 AllocatedDestSize:=aInLen;
 if AllocatedDestSize<SizeOf(TpvUInt32) then begin
  AllocatedDestSize:=SizeOf(TpvUInt32);
 end;
 GetMem(aDestData,AllocatedDestSize);
 aDestLen:=0;
 try
  MaxSteps:=1 shl TpvInt32(aLevel);
  SkipStrength:=(32-9)+TpvInt32(aLevel);
  Greedy:=aLevel>=TpvLZBRRCLevel(1);
  LastWasMatch:=false;
  FirstByte:=true;
  First:=true;
  OK:=true;
  CountFFBytes:=0;
  Range:=$ffffffff;
  Code:=0;
  LastMatchDistance:=$ffffffff;
  for Step:=0 to SizeModels-1 do begin
   Model[Step]:=2048;
  end;
  LiteralStart:=nil;
  LiteralLength:=0;
  if aWithSize then begin
   DoOutputUInt64(aInLen);
  end;
  GetMem(HashTable,SizeOf(THashTable));
  try
   FillChar(HashTable^,SizeOf(THashTable),#0);
   GetMem(ChainTable,SizeOf(TChainTable));
   try
    FillChar(ChainTable^,SizeOf(TChainTable),#0);
    CurrentPointer:=aInData;
    EndPointer:={%H-}TpvPointer(TpvPtrUInt(TpvPtrUInt(CurrentPointer)+TpvPtrUInt(aInLen)));
    EndSearchPointer:={%H-}TpvPointer(TpvPtrUInt((TpvPtrUInt(CurrentPointer)+TpvPtrUInt(aInLen))-TpvPtrUInt(TpvInt64(Max(TpvInt64(MinMatch),TpvInt64(SizeOf(TpvUInt32)))))));
    UnsuccessfulFindMatchAttempts:=TpvUInt32(1) shl SkipStrength;
    while {%H-}TpvPtrUInt(CurrentPointer)<{%H-}TpvPtrUInt(EndSearchPointer) do begin
     HashTableItem:=@HashTable[((((PpvUInt32(TpvPointer(CurrentPointer))^ and TpvUInt32({$if defined(FPC_BIG_ENDIAN)}$ffffff00{$else}$00ffffff{$ifend}){$if defined(FPC_BIG_ENDIAN)}shr 8{$ifend}))*TpvUInt32($1e35a7bd)) shr HashShift) and HashMask];
     Head:=HashTableItem^;
     CurrentPossibleMatch:=Head;
     BestMatchDistance:=0;
     BestMatchLength:=1;
     if First then begin
      First:=false;
      EncodeTree(LiteralModel,8,4,PpvUInt8(CurrentPointer)^);
     end else begin
      Step:=0;
      while assigned(CurrentPossibleMatch) and
            ({%H-}TpvPtrUInt(CurrentPointer)>{%H-}TpvPtrUInt(CurrentPossibleMatch)) and
            (TpvPtrInt({%H-}TpvPtrUInt({%H-}TpvPtrUInt(CurrentPointer)-{%H-}TpvPtrUInt(CurrentPossibleMatch)))<TpvPtrInt(MaxOffset)) do begin
       Difference:=PpvUInt32(TpvPointer(@PBytes(CurrentPointer)^[0]))^ xor PpvUInt32(TpvPointer(@PBytes(CurrentPossibleMatch)^[0]))^;
       if (Difference and TpvUInt32({$if defined(FPC_BIG_ENDIAN)}$ffffff00{$else}$00ffffff{$ifend}))=0 then begin
        if (BestMatchLength<=({%H-}TpvPtrUInt(EndPointer)-{%H-}TpvPtrUInt(CurrentPointer))) and
           (PBytes(CurrentPointer)^[BestMatchLength-1]=PBytes(CurrentPossibleMatch)^[BestMatchLength-1]) then begin
         MatchLength:=MinMatch;
         while ({%H-}TpvPtrUInt(@PBytes(CurrentPointer)^[MatchLength+(SizeOf(TpvUInt32)-1)])<{%H-}TpvPtrUInt(EndPointer)) do begin
          Difference:=PpvUInt32(TpvPointer(@PBytes(CurrentPointer)^[MatchLength]))^ xor PpvUInt32(TpvPointer(@PBytes(CurrentPossibleMatch)^[MatchLength]))^;
          if Difference=0 then begin
           inc(MatchLength,SizeOf(TpvUInt32));
          end else begin
{$if defined(FPC_BIG_ENDIAN)}
           if (Difference shr 16)<>0 then begin
            inc(MatchLength,not (Difference shr 24));
           end else begin
            inc(MatchLength,2+(not (Difference shr 8)));
           end;
{$else}
           inc(MatchLength,MultiplyDeBruijnBytePosition[TpvUInt32(TpvUInt32(Difference and (-Difference))*TpvUInt32($077cb531)) shr 27]);
{$ifend}
           break;
          end;
         end;
         if BestMatchLength<MatchLength then begin
          BestMatchDistance:={%H-}TpvPtrUInt({%H-}TpvPtrUInt(CurrentPointer)-{%H-}TpvPtrUInt(CurrentPossibleMatch));
          BestMatchLength:=MatchLength;
         end;
        end;
       end;
       inc(Step);
       if Step<MaxSteps then begin
        CurrentPossibleMatch:=ChainTable^[({%H-}TpvPtrUInt(CurrentPossibleMatch)-{%H-}TpvPtrUInt(aInData)) and WindowMask];
       end else begin
        break;
       end;
      end;
      if (BestMatchDistance>0) and
         (((BestMatchDistance<96) and (BestMatchLength>1)) or
          ((BestMatchDistance>=96) and (BestMatchLength>3)) or
          ((BestMatchDistance>=2048) and (BestMatchLength>4))) then begin
   //  writeln('C: ',BestMatchLength,' ',{%H-}TpvPtrUInt(CurrentPointer)-{%H-}TpvPtrUInt(aInData),' ',({%H-}TpvPtrUInt(CurrentPointer)-{%H-}TpvPtrUInt(aInData))+BestMatchLength);
       MatchLength:=BestMatchLength;
       EncodeBit(FlagModel+TpvUInt8(ord(LastWasMatch) and 1),5,1);
       if (not LastWasMatch) and (BestMatchDistance=LastMatchDistance) then begin
        EncodeBit(PreviousMatchModel,5,1);
       end else begin
        if not LastWasMatch then begin
         EncodeBit(PreviousMatchModel,5,0);
        end;
        Offset:=BestMatchDistance-1;
        EncodeGamma(Gamma0Model,(Offset shr 4)+2);
        EncodeTree(MatchLowModel+((ord((Offset shr 4)<>0) and 1) shl 4),4,5,Offset and $f);
        dec(MatchLength,(ord(BestMatchDistance>=96) and 1)+(ord(BestMatchDistance>=2048) and 1));
       end;
       EncodeGamma(Gamma1Model,MatchLength);
       LastWasMatch:=true;
       LastMatchDistance:=BestMatchDistance;
       UnsuccessfulFindMatchAttempts:=TpvUInt32(1) shl SkipStrength;
      end else begin
       if (SkipStrength>31) and (BestMatchLength=1) then begin
        EncodeBit(FlagModel+TpvUInt8(ord(LastWasMatch) and 1),5,0);
        EncodeTree(LiteralModel,8,4,CurrentPointer^);
        LastWasMatch:=false;
       end else begin
        if BestMatchLength=1 then begin
         Step:=UnsuccessfulFindMatchAttempts shr SkipStrength;
        end else begin
         Step:=BestMatchLength;
        end;
        Offset:=0;
        while Offset<Step do begin
         if ({%H-}TpvPtrUInt(CurrentPointer)+Offset)<{%H-}TpvPtrUInt(EndSearchPointer) then begin
          EncodeBit(FlagModel+TpvUInt8(ord(LastWasMatch) and 1),5,0);
          EncodeTree(LiteralModel,8,4,PpvUInt8Array(CurrentPointer)^[Offset]);
          LastWasMatch:=false;
          inc(Offset);
         end else begin
          BestMatchLength:=Offset; // Because we reached EndSearchPointer, so that the tail remaining literal stuff is processing the right remaining offset then
          break;
         end;
        end;
        if BestMatchLength=1 then begin
         BestMatchLength:=Offset;
         inc(UnsuccessfulFindMatchAttempts,ord(UnsuccessfulFindMatchAttempts<TpvUInt32($ffffffff)) and 1);
        end;
       end;
      end;
     end;
     if not OK then begin
      break;
     end;
     HashTableItem^:=CurrentPointer;
     ChainTable^[({%H-}TpvPtrUInt(CurrentPointer)-{%H-}TpvPtrUInt(aInData)) and WindowMask]:=Head;
     if Greedy then begin
      inc(CurrentPointer);
      dec(BestMatchLength);
      while (BestMatchLength>0) and ({%H-}TpvPtrUInt(CurrentPointer)<{%H-}TpvPtrUInt(EndSearchPointer)) do begin
       HashTableItem:=@HashTable[((((PpvUInt32(TpvPointer(CurrentPointer))^ and TpvUInt32({$if defined(FPC_BIG_ENDIAN)}$ffffff00{$else}$00ffffff{$ifend}){$if defined(FPC_BIG_ENDIAN)}shr 8{$ifend}))*TpvUInt32($1e35a7bd)) shr HashShift) and HashMask];
       Head:=HashTableItem^;
       HashTableItem^:=CurrentPointer;
       ChainTable^[({%H-}TpvPtrUInt(CurrentPointer)-{%H-}TpvPtrUInt(aInData)) and WindowMask]:=Head;
       inc(CurrentPointer);
       dec(BestMatchLength);
      end;
     end;
     inc(CurrentPointer,BestMatchLength);
    end;
    while {%H-}TpvPtrUInt(CurrentPointer)<{%H-}TpvPtrUInt(EndPointer) do begin
     EncodeBit(FlagModel+TpvUInt8(ord(LastWasMatch) and 1),5,0);
     EncodeTree(LiteralModel,8,4,CurrentPointer^);
     LastWasMatch:=false;
     inc(CurrentPointer);
    end;
    EncodeBit(FlagModel+TpvUInt8(ord(LastWasMatch) and 1),5,1);
    if not LastWasMatch then begin
     EncodeBit(PreviousMatchModel,5,0);
    end;
    EncodeEnd(Gamma0Model);
    MinDestLen:=Max(2,aDestLen+1);
    EncoderFlush;
    if OK then begin
     while (aDestLen>MinDestLen) and (PpvUInt8Array(aDestData)^[aDestLen-1]=0) do begin
      dec(aDestLen);
     end;
    end;
   finally
    FreeMem(ChainTable);
   end;
  finally
   FreeMem(HashTable);
  end;
 finally
  if aDestLen>0 then begin
   ReallocMem(aDestData,aDestLen);
   result:=true;
  end else if assigned(aDestData) then begin
   FreeMem(aDestData);
   aDestData:=nil;
  end;
 end;
end;

{$if defined(fpc) and defined(cpuamd64)}
{$if defined(cpuamd64)}
{$warnings off}
function LZBRRCDecompressASM(aSrc,aDst:Pointer):TpvUInt64; {$ifdef fpc}{$if defined(Windows)}ms_abi_cdecl;{$else}sysv_abi_cdecl{$ifend}{$endif} assembler; {$ifdef fpc}nostackframe;{$endif}
const FlagModel=0;
      PrevMatchModel=2;
      MatchLowModel=3;
      LiteralModel=35;
      Gamma0Model=291;
      Gamma1Model=547;
      SizeModels=803;
      LocalSize=(SizeModels+2)*4;
      Models=-LocalSize;
asm
{$ifndef fpc}
 .noframe
{$endif}
 push rbp
 mov rbp,rsp
 sub rsp,LocalSize

 push rbx
 push rsi
 push rdi

 cld
{$ifdef Windows}
 mov rsi,rcx
{$else}
 xchg rsi,rdi
 mov rdx,rdi
{$endif}

 lodsd
 bswap eax
 mov r8d,eax // Code

 xor eax,eax
 not eax
 mov r9d,eax // Range

 not eax
 mov ah,$08 // mov eax,2048
 mov ecx,SizeModels
 lea rdi,dword ptr [rbp+Models]
 repe stosd

 mov rdi,rdx
 push rdi

 jmp @Main

  @DecodeBit: // result = eax, Move = ecx, ModelIndex = eax
   push rbx
   push rdx

    // Bound:=(Range shr 12)*Model[ModelIndex];
    mov eax,eax
    lea rdx,qword ptr [rbp+Models+rax*4]
    mov eax,dword ptr [rdx]
    mov ebx,r9d
    shr ebx,12
    push rdx
    imul eax,ebx
    pop rdx

    // if Code<Bound then begin
    cmp eax,r8d
    jbe @DecodeBitYes

     // Range:=Bound;
     mov r9d,eax

     // inc(Model[ModelIndex],(4096-Model[ModelIndex]) shr Move);
     xor rax,rax // mov eax,4096
     mov ah,$10
     sub eax,dword ptr [rdx]
     shr eax,cl
     add dword ptr [rdx],eax

     // result:=0;
     xor rax,rax

     jmp @CheckRenormalization

    @DecodeBitYes:

     // dec(Code,Bound);
     sub r8d,eax

     // dec(Range,Bound);
     sub r9d,eax

     // dec(Model[ModelIndex],Model[ModelIndex] shr Move);
     mov eax,dword ptr [rdx]
     shr eax,cl
     sub dword ptr [rdx],eax

     // result:=1;
     xor eax,eax
     inc eax
     jmp @CheckRenormalization

    @DoRenormalization:
     shl r8d,8
     movzx edx,byte ptr [rsi]
     inc rsi
     or r8d,edx
     shl r9d,8
    @CheckRenormalization:
     cmp r9d,$1000000
     jb @DoRenormalization

   pop rdx
   pop rbx

   bt eax,0 // Carry flay = first LSB bit of eax
  ret

  @DecodeTree: // result = eax, MaxValue = eax, Move = ecx, ModelIndex = edx
   push rdi
   mov edi,eax
   // result:=1;
   xor eax,eax
   inc eax
   @DecodeTreeLoop:
    // while result<MaxValue do begin
    cmp eax,edi
    jge @DecodeTreeLoopDone
     // result:=(result shl 1) or DecodeBit(ModelIndex+result,Move);
     push rax
     add eax,edx
     call @DecodeBit
     pop rax
     adc eax,eax
     jmp @DecodeTreeLoop
   @DecodeTreeLoopDone:
   sub eax,edi
   pop rdi
   ret

  @DecodeGamma0: // result = eax, ModelIndex = edx
   push rbx
   push rdx
   mov rdx,Gamma0Model
   jmp @DecodeGamma
  @DecodeGamma1: // result = eax, ModelIndex = edx
   push rbx
   push rdx
   mov rdx,Gamma1Model
  @DecodeGamma: // result = eax, ModelIndex = edx
   xor eax,eax // result:=1;
   inc eax
   mov ebx,eax // Conext:=1;
   @DecodeGammaLoop:
    push rax
     mov cl,5 // Move:=5;
     lea eax,[edx+ebx] // ModelIndex+Context
     call @DecodeBit
     adc bl,bl         // Context:=(Context shl 1) or NewBit;
     lea eax,[edx+ebx] // ModelIndex+Context
     call @DecodeBit
     mov cl,al
    pop rax
    add eax,eax       // Value:=(Value shl 1) or NewBit;
    or al,cl
    add bl,bl
    or bl,cl
    test bl,2
   jnz @DecodeGammaLoop
   pop rdx
   pop rbx
   ret

 @Main:
  xor rbx,rbx // Last offset
  xor rdx,rdx // bit 1=LastWasMatch, bit 0=Flag

 @Loop:

  // if Flag then begin
  test dl,1
  jz @Literal

  @Match:
    // if (not LastWasMatch) and (DecodeBit(PrevMatchModel,5)<>0) then begin
    test dl,2
    jnz @NormalMatch
     xor eax,eax // PrevMatchModel
     mov al,PrevMatchModel
     mov cl,5
     call @DecodeBit
     jnc @NormalMatch
      xor ecx,ecx // Len=0
      jmp @DoMatch
     @NormalMatch:

      // Offset:=DecodeGamma(Gamma0Model);
      call @DecodeGamma0

      // if Offset=0 then exit;
      test eax,eax
      jz @WeAreDone

      // dec(Offset,2);
      lea ebx,[eax-2]

      // Offset:=((Offset shl 4)+DecodeTree(MatchLowModel+(ord(Offset<>0) shl 4),16,5))+1;
      push rdx
      test ebx,ebx
      setnz dl
      movzx edx,dl
      shl edx,4
      add edx,MatchLowModel
      mov cl,5
      xor eax,eax
      mov al,16
      call @DecodeTree
      pop rdx
      shl ebx,4
      lea ebx,[eax+ebx+1]

      // Len:=ord(Offset>=96)+ord(Offset>=2048);
      xor ecx,ecx
      xor eax,eax
      cmp ebx,2048
      setge al
      add ecx,eax
      cmp ebx,96
      setge al
      add ecx,eax

     @DoMatch:

     or dl,2 // LastWasMatch = true

     // inc(Len,DecodeGamma(Gamma1Model));
     push rcx
     call @DecodeGamma1
     pop rcx
     add ecx,eax

     push rsi
      mov rsi,rdi
      mov ebx,ebx
      sub rsi,rbx
      repe movsb
     pop rsi

   jmp @NextFlag

  @Literal:
   // byte(pointer(Destination)^):=DecodeTree(LiteralModel,256,4);
   push rdx
   xor eax,eax // mov eax,256
   inc ah
   mov cl,4
   mov edx,LiteralModel
   call @DecodeTree
   pop rdx
   // inc(Destination);
   stosb
   // LastWasMatch:=false;
   and dl,$fd

  @NextFlag:
   // Flag:=boolean(byte(DecodeBit(FlagModel+byte(boolean(LastWasMatch)),5)));
   movzx eax,dl
   and al,1
   mov cl,5
   call @DecodeBit
   and dl,$fe
   or dl,al

  jmp @Loop

 @WeAreDone:

 mov rax,rdi
 pop rdi
 sub rax,rdi

 pop rdi
 pop rsi
 pop rbx

 mov rsp,rbp
 pop rbp
end;
{$warnings on}
{$ifend}

 function LZBRRCFastDecompress(const aInData:TpvPointer;aInLen:TpvUInt64;var aDestData:TpvPointer;out aDestLen:TpvUInt64;const aOutputSize:TpvInt64;const aWithSize:boolean):boolean;
var OutputSize,DestLen:TpvUInt64;
    Allocated:boolean;
begin
 result:=false;
 if aInLen>=12 then begin
  if aWithSize then begin
   OutputSize:=PpvUInt64(aInData)^;
{$ifdef BIG_ENDIAN}
   OutputSize:=((OutputSize and TpvUInt64($ff00000000000000)) shr 56) or
               ((OutputSize and TpvUInt64($00ff000000000000)) shr 40) or
               ((OutputSize and TpvUInt64($0000ff0000000000)) shr 24) or
               ((OutputSize and TpvUInt64($000000ff00000000)) shr 8) or
               ((OutputSize and TpvUInt64($00000000ff000000)) shl 8) or
               ((OutputSize and TpvUInt64($0000000000ff0000)) shl 24) or
               ((OutputSize and TpvUInt64($000000000000ff00)) shl 40) or
               ((OutputSize and TpvUInt64($00000000000000ff)) shl 56);
{$endif}
  end else begin
   if aOutputSize>=0 then begin
    OutputSize:=aOutputSize;
   end else begin
    OutputSize:=0;
   end;
  end;
  if OutputSize=0 then begin
   result:=true;
   exit;
  end;
  aDestLen:=OutputSize;
  if (aOutputSize>=0) and (aDestLen<>TpvUInt64(aOutputSize)) then begin
   result:=false;
   aDestLen:=0;
   exit;
  end;
  Allocated:=not assigned(aDestData);
  if Allocated then begin
   if ((not aWithSize) and (aOutputSize<=0)) or (OutputSize=0) then begin
    result:=false;
    aDestLen:=0;
    exit;
   end;
   GetMem(aDestData,OutputSize);
  end;
  if aWithSize then begin
   DestLen:=LZBRRCDecompressASM(@PpvUInt8Array(aInData)^[8],aDestData);
  end else begin
   DestLen:=LZBRRCDecompressASM(@PpvUInt8Array(aInData)^[0],aDestData);
  end;
  if (not aWithSize) and (aOutputSize<0) then begin
   aDestLen:=DestLen;
  end;
  if DestLen=aDestLen then begin
   result:=true;
  end else begin
   if Allocated then begin
    FreeMem(aDestData);
    aDestData:=nil;
   end;
   aDestLen:=0;
   result:=false;
  end;
 end;
end;
{$ifend}

function LZBRRCDecompress(const aInData:TpvPointer;aInLen:TpvUInt64;var aDestData:TpvPointer;out aDestLen:TpvUInt64;const aOutputSize:TpvInt64;const aWithSize:boolean):boolean;
var Code,Range,Position:TpvUInt32;
    Model:array[0..SizeModels-1] of TpvUInt32;
    OK:boolean;
 function DecodeBit(ModelIndex,Move:TpvInt32):TpvInt32;
 var Bound:TpvUInt32;
 begin
  Bound:=(Range shr 12)*Model[ModelIndex];
  if Code<Bound then begin
   Range:=Bound;
   inc(Model[ModelIndex],(4096-Model[ModelIndex]) shr Move);
   result:=0;
  end else begin
   dec(Code,Bound);
   dec(Range,Bound);
   dec(Model[ModelIndex],Model[ModelIndex] shr Move);
   result:=1;
  end;
  while Range<$1000000 do begin
   if Position<aInLen then begin
    Code:=(Code shl 8) or PpvUInt8Array(aInData)^[Position];
   end else begin
    if Position<(aInLen+5) then begin
     Code:=Code shl 8;
    end else begin
     OK:=false;
     break;
    end;
   end;
   inc(Position);
   Range:=Range shl 8;
  end;
 end;
 function DecodeTree(ModelIndex,MaxValue,Move:TpvInt32):TpvInt32;
 begin
  result:=1;
  while OK and (result<MaxValue) do begin
   result:=(result shl 1) or DecodeBit(ModelIndex+result,Move);
  end;
  dec(result,MaxValue);
 end;
 function DecodeGamma(ModelIndex:TpvInt32):TpvInt32;
 var Context:TpvUInt8;
 begin
  result:=1;
  Context:=1;
  repeat
   Context:=(Context shl 1) or DecodeBit(ModelIndex+Context,5);
   result:=(result shl 1) or DecodeBit(ModelIndex+Context,5);
   Context:=(Context shl 1) or (result and 1);
  until (not OK) or ((Context and 2)=0);
 end;
var Len,Offset,LastOffset,DestLen,Value:TpvInt32;
    Flag,LastWasMatch,Allocated:boolean;
    OutputSize:TpvUInt64;
begin
 result:=false;
 if (aWithSize and (aInLen>=12)) or ((not aWithSize) and (aInLen>=4)) then begin
  OK:=true;
  if aWithSize then begin
   OutputSize:=PpvUInt64(aInData)^;
{$ifdef BIG_ENDIAN}
   OutputSize:=((OutputSize and TpvUInt64($ff00000000000000)) shr 56) or
               ((OutputSize and TpvUInt64($00ff000000000000)) shr 40) or
               ((OutputSize and TpvUInt64($0000ff0000000000)) shr 24) or
               ((OutputSize and TpvUInt64($000000ff00000000)) shr 8) or
               ((OutputSize and TpvUInt64($00000000ff000000)) shl 8) or
               ((OutputSize and TpvUInt64($0000000000ff0000)) shl 24) or
               ((OutputSize and TpvUInt64($000000000000ff00)) shl 40) or
               ((OutputSize and TpvUInt64($00000000000000ff)) shl 56);
{$endif}
  end else begin
   if aOutputSize>=0 then begin
    OutputSize:=aOutputSize;
   end else begin
    OutputSize:=0;
   end;
  end;
  if OutputSize=0 then begin
   result:=true;
   exit;
  end;
  aDestLen:=OutputSize;
  if (aOutputSize>=0) and (aDestLen<>TpvUInt64(aOutputSize)) then begin
   result:=false;
   aDestLen:=0;
   exit;
  end;
  Allocated:=not assigned(aDestData);
  if Allocated then begin
   if ((not aWithSize) and (aOutputSize<=0)) or (OutputSize=0) then begin
    result:=false;
    aDestLen:=0;
    exit;
   end;
   GetMem(aDestData,OutputSize);
  end;
  if aWithSize then begin
   Code:=(PpvUInt8Array(aInData)^[8] shl 24) or
         (PpvUInt8Array(aInData)^[9] shl 16) or
         (PpvUInt8Array(aInData)^[10] shl 8) or
         (PpvUInt8Array(aInData)^[11] shl 0);
   Position:=12;
  end else begin
   Code:=(PpvUInt8Array(aInData)^[0] shl 24) or
         (PpvUInt8Array(aInData)^[1] shl 16) or
         (PpvUInt8Array(aInData)^[2] shl 8) or
         (PpvUInt8Array(aInData)^[3] shl 0);
   Position:=4;
  end;
  Range:=$ffffffff;
  for Value:=0 to SizeModels-1 do begin
   Model[Value]:=2048;
  end;
  LastOffset:=0;
  LastWasMatch:=false;
  Flag:=false;
  DestLen:=0;
  repeat
   if Flag then begin
    if (not LastWasMatch) and (DecodeBit(PreviousMatchModel,5)<>0) then begin
     if OK then begin
      Offset:=LastOffset;
      Len:=0;
     end else begin
      if Allocated then begin
       FreeMem(aDestData);
       aDestData:=nil;
      end;
      aDestLen:=0;
      result:=false;
      exit;
     end;
    end else begin
     Offset:=DecodeGamma(Gamma0Model);
     if OK then begin
      if Offset=0 then begin
       break;
      end else begin
       dec(Offset,2);
       Offset:=((Offset shl 4)+DecodeTree(MatchLowModel+((ord(Offset<>0) and 1) shl 4),16,5))+1;
       Len:=(ord(Offset>=96) and 1)+(ord(Offset>=2048) and 1);
      end;
     end else begin
      if Allocated then begin
       FreeMem(aDestData);
       aDestData:=nil;
      end;
      aDestLen:=0;
      result:=false;
      exit;
     end;
    end;
    LastOffset:=Offset;
    LastWasMatch:=true;
    inc(Len,DecodeGamma(Gamma1Model));
//  writeln('D: ',DestLen,' ',Len,' ',DestLen+Len);
    if (TpvSizeUInt(DestLen+Len)<=TpvSizeUInt(OutputSize)) and
       (TpvSizeUInt(Offset)<=TpvSizeUInt(DestLen)) then begin
     RLELikeSideEffectAwareMemoryMove(PpvUInt8Array(aDestData)^[DestLen-Offset],
                                      PpvUInt8Array(aDestData)^[DestLen],
                                      Len);
     inc(DestLen,Len);
    end else begin
     if Allocated then begin
      FreeMem(aDestData);
      aDestData:=nil;
     end;
     aDestLen:=0;
     result:=false;
     exit;
    end;
   end else begin
    Value:=DecodeTree(LiteralModel,256,4);
    if OK and (TpvSizeUInt(DestLen)<TpvSizeUInt(OutputSize)) then begin
     PpvUInt8Array(aDestData)^[DestLen]:=Value;
     inc(DestLen);
     LastWasMatch:=false;
    end else begin
     if Allocated then begin
      FreeMem(aDestData);
      aDestData:=nil;
     end;
     aDestLen:=0;
     result:=false;
     exit;
    end;
   end;
   Flag:=boolean(byte(DecodeBit(FlagModel+TpvUInt8(ord(LastWasMatch) and 1),5)));
  until false;
  if (not aWithSize) and (aOutputSize<0) then begin
   aDestLen:=DestLen;
  end;
  if DestLen=aDestLen then begin
   result:=true;
  end else begin
   if Allocated then begin
    FreeMem(aDestData);
    aDestData:=nil;
   end;
   aDestLen:=0;
   result:=false;
  end;
 end;
end;

initialization
end.
