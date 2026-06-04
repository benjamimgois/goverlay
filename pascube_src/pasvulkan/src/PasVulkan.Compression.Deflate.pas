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
unit PasVulkan.Compression.Deflate;
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
{$if not defined(fpc)}
     System.ZLIB,
{$ifend}
     PasVulkan.Math,
     PasVulkan.Types;

type PpvDeflateMode=^TpvDeflateMode;
     TpvDeflateMode=
      (
       None=0,
       VeryFast=1,
       Faster=2,
       Fast=3,
       FasterThanMedium=4,
       Medium=5,
       SlowerThanMedium=6,
       MoreSlowerThanMedium=7,
       YetMoreSlowerThanMedium=8,
       Slow=9
      );

function DoDeflate(const aInData:TpvPointer;const aInLen:TpvSizeUInt;var aDestData:TpvPointer;var aDestLen:TpvSizeUInt;const aMode:TpvDeflateMode;const aWithHeader:boolean):boolean;

function DoInflate(const aInData:TpvPointer;aInLen:TpvSizeUInt;var aDestData:TpvPointer;var aDestLen:TpvSizeUInt;const aParseHeader:boolean):boolean;

implementation

{$if defined(fpc) and (defined(Linux) or defined(Android))}
uses zlib;
{$ifend}

{$if not (defined(fpc) and (defined(Linux) or defined(Android)))}
const LengthCodes:array[0..28,0..3] of TpvUInt32=
       ( // Code, ExtraBits, Min, Max
        (257,0,3,3),
        (258,0,4,4),
        (259,0,5,5),
        (260,0,6,6),
        (261,0,7,7),
        (262,0,8,8),
        (263,0,9,9),
        (264,0,10,10),
        (265,1,11,12),
        (266,1,13,14),
        (267,1,15,16),
        (268,1,17,18),
        (269,2,19,22),
        (270,2,23,26),
        (271,2,27,30),
        (272,2,31,34),
        (273,3,35,42),
        (274,3,43,50),
        (275,3,51,58),
        (276,3,59,66),
        (277,4,67,82),
        (278,4,83,98),
        (279,4,99,114),
        (280,4,115,130),
        (281,5,131,162),
        (282,5,163,194),
        (283,5,195,226),
        (284,5,227,257),
        (285,0,258,258)
       );
      DistanceCodes:array[0..29,0..3] of TpvUInt32=
       ( // Code, ExtraBits, Min, Max
        (0,0,1,1),
        (1,0,2,2),
        (2,0,3,3),
        (3,0,4,4),
        (4,1,5,6),
        (5,1,7,8),
        (6,2,9,12),
        (7,2,13,16),
        (8,3,17,24),
        (9,3,25,32),
        (10,4,33,48),
        (11,4,49,64),
        (12,5,65,96),
        (13,5,97,128),
        (14,6,129,192),
        (15,6,193,256),
        (16,7,257,384),
        (17,7,385,512),
        (18,8,513,768),
        (19,8,769,1024),
        (20,9,1025,1536),
        (21,9,1537,2048),
        (22,10,2049,3072),
        (23,10,3073,4096),
        (24,11,4097,6144),
        (25,11,6145,8192),
        (26,12,8193,12288),
        (27,12,12289,16384),
        (28,13,16385,24576),
        (29,13,24577,32768)
       );

var LengthCodesLookUpTable:array[0..258] of TpvInt32;
    DistanceCodesLookUpTable:array[0..32768] of TpvInt32;

procedure InitializeLookUpTables;
var Index,ValueIndex:TpvInt32;
begin
 for Index:=0 to length(LengthCodes)-1 do begin
  for ValueIndex:=IfThen(Index=0,0,LengthCodes[Index,2]) to LengthCodes[Index,3] do begin
   LengthCodesLookUpTable[ValueIndex]:=Index;
  end;
 end;
 for Index:=0 to length(DistanceCodes)-1 do begin
  for ValueIndex:=IfThen(Index=0,0,DistanceCodes[Index,2]) to DistanceCodes[Index,3] do begin
   DistanceCodesLookUpTable[ValueIndex]:=Index;
  end;
 end;
end;
{$ifend}

function DoDeflate(const aInData:TpvPointer;const aInLen:TpvSizeUInt;var aDestData:TpvPointer;var aDestLen:TpvSizeUInt;const aMode:TpvDeflateMode;const aWithHeader:boolean):boolean;
{$if not defined(fpc)}
const OutChunkSize=65536;
var d_stream:z_stream;
    r,Level:TpvInt32;
    Allocated,Have:TpvSizeUInt;
begin
 result:=false;
 aDestLen:=0;
 Allocated:=0;
 aDestData:=nil;
 FillChar(d_stream,SizeOf(z_stream),AnsiChar(#0));
 Level:=Min(Max(TpvInt32(aMode),0),9);
 if aWithHeader then begin
  r:=deflateInit(d_stream,Level);
 end else begin
  r:=deflateInit2(d_stream,Level,Z_DEFLATED,-15{MAX_WBITS},9{Z_MEM_LEVEL},Z_DEFAULT_STRATEGY);
 end;
 try
  if r=Z_OK then begin
   try
    d_stream.next_in:=aInData;
    d_stream.avail_in:=aInLen;
    Allocated:=deflateBound(d_stream,aInLen);
    if Allocated<RoundUpToPowerOfTwo(aInLen) then begin
     Allocated:=RoundUpToPowerOfTwo(aInLen);
    end;
    if Allocated<OutChunkSize then begin
     Allocated:=OutChunkSize;
    end;
    GetMem(aDestData,Allocated);
    d_stream.next_out:=aDestData;
    d_stream.avail_out:=Allocated;
    r:=deflate(d_stream,Z_FINISH);
    aDestLen:=d_stream.total_out;
   finally
    if r=Z_STREAM_END then begin
     r:=deflateEnd(d_stream);
    end else begin
     deflateEnd(d_stream);
    end;
   end;
  end;
 finally
  if (r=Z_OK) or (r=Z_STREAM_END) then begin
   if assigned(aDestData) then begin
    ReallocMem(aDestData,aDestLen);
   end else begin
    aDestLen:=0;
   end;
   result:=true;
  end else begin
   if assigned(aDestData) then begin
    FreeMem(aDestData);
   end;
   aDestData:=nil;
  end;
 end;
end;
{$elseif defined(fpc) and (defined(Linux) or defined(Android))}
const OutChunkSize=65536;
var d_stream:z_stream;
    r,Level:TpvInt32;
    Allocated,Have:TpvSizeUInt;
begin
 result:=false;
 aDestLen:=0;
 Allocated:=0;
 aDestData:=nil;
 FillChar(d_stream,SizeOf(z_stream),AnsiChar(#0));
 Level:=Min(Max(TpvInt32(aMode),0),9);
 if aWithHeader then begin
  r:=deflateInit(d_stream,Level);
 end else begin
  r:=deflateInit2(d_stream,Level,Z_DEFLATED,-15{MAX_WBITS},9{Z_MEM_LEVEL},Z_DEFAULT_STRATEGY);
 end;
 try
  if r=Z_OK then begin
   try
    d_stream.next_in:=aInData;
    d_stream.avail_in:=aInLen;
    Allocated:=deflateBound(d_stream,aInLen);
    if Allocated<RoundUpToPowerOfTwo(aInLen) then begin
     Allocated:=RoundUpToPowerOfTwo(aInLen);
    end;
    if Allocated<OutChunkSize then begin
     Allocated:=OutChunkSize;
    end;
    GetMem(aDestData,Allocated);
    d_stream.next_out:=aDestData;
    d_stream.avail_out:=Allocated;
    r:=deflate(d_stream,Z_FINISH);
    aDestLen:=d_stream.total_out;
   finally
    if r=Z_STREAM_END then begin
     r:=deflateEnd(d_stream);
    end else begin
     deflateEnd(d_stream);
    end;
   end;
  end;
 finally
  if (r=Z_OK) or (r=Z_STREAM_END) then begin
   if assigned(aDestData) then begin
    ReallocMem(aDestData,aDestLen);
   end else begin
    aDestLen:=0;
   end;
   result:=true;
  end else begin
   if assigned(aDestData) then begin
    FreeMem(aDestData);
   end;
   aDestData:=nil;
  end;
 end;
end;
{$else}
const HashBits=16;
      HashSize=1 shl HashBits;
      HashMask=HashSize-1;
      HashShift=32-HashBits;
      WindowSize=32768;
      WindowMask=WindowSize-1;
      MinMatch=3;
      MaxMatch=258;
      MaxOffset=32768;
      MirrorBytes:array[TpvUInt8] of TpvUInt8=
       (
        $00,$80,$40,$c0,$20,$a0,$60,$e0,
        $10,$90,$50,$d0,$30,$b0,$70,$f0,
        $08,$88,$48,$c8,$28,$a8,$68,$e8,
        $18,$98,$58,$d8,$38,$b8,$78,$f8,
        $04,$84,$44,$c4,$24,$a4,$64,$e4,
        $14,$94,$54,$d4,$34,$b4,$74,$f4,
        $0c,$8c,$4c,$cc,$2c,$ac,$6c,$ec,
        $1c,$9c,$5c,$dc,$3c,$bc,$7c,$fc,
        $02,$82,$42,$c2,$22,$a2,$62,$e2,
        $12,$92,$52,$d2,$32,$b2,$72,$f2,
        $0a,$8a,$4a,$ca,$2a,$aa,$6a,$ea,
        $1a,$9a,$5a,$da,$3a,$ba,$7a,$fa,
        $06,$86,$46,$c6,$26,$a6,$66,$e6,
        $16,$96,$56,$d6,$36,$b6,$76,$f6,
        $0e,$8e,$4e,$ce,$2e,$ae,$6e,$ee,
        $1e,$9e,$5e,$de,$3e,$be,$7e,$fe,
        $01,$81,$41,$c1,$21,$a1,$61,$e1,
        $11,$91,$51,$d1,$31,$b1,$71,$f1,
        $09,$89,$49,$c9,$29,$a9,$69,$e9,
        $19,$99,$59,$d9,$39,$b9,$79,$f9,
        $05,$85,$45,$c5,$25,$a5,$65,$e5,
        $15,$95,$55,$d5,$35,$b5,$75,$f5,
        $0d,$8d,$4d,$cd,$2d,$ad,$6d,$ed,
        $1d,$9d,$5d,$dd,$3d,$bd,$7d,$fd,
        $03,$83,$43,$c3,$23,$a3,$63,$e3,
        $13,$93,$53,$d3,$33,$b3,$73,$f3,
        $0b,$8b,$4b,$cb,$2b,$ab,$6b,$eb,
        $1b,$9b,$5b,$db,$3b,$bb,$7b,$fb,
        $07,$87,$47,$c7,$27,$a7,$67,$e7,
        $17,$97,$57,$d7,$37,$b7,$77,$f7,
        $0f,$8f,$4f,$cf,$2f,$af,$6f,$ef,
        $1f,$9f,$5f,$df,$3f,$bf,$7f,$ff
       );
       MultiplyDeBruijnBytePosition:array[0..31] of byte=(0,0,3,0,3,1,3,0,3,2,2,1,3,2,0,1,3,3,1,2,2,2,2,0,3,1,2,0,1,0,1,1);
type PHashTable=^THashTable;
     THashTable=array[0..HashSize-1] of PpvUInt8;
     PChainTable=^TChainTable;
     TChainTable=array[0..WindowSize-1] of TpvPointer;
     PThreeBytes=^TThreeBytes;
     TThreeBytes=array[0..2] of TpvUInt8;
     PBytes=^TBytes;
     TBytes=array[0..$7ffffffe] of TpvUInt8;
var OutputBits,CountOutputBits:TpvUInt32;
    AllocatedDestSize:TpvUInt64;
 procedure DoOutputBits(const aBits,aCountBits:TpvUInt32);
 begin
  Assert((CountOutputBits+aCountBits)<=32);
  OutputBits:=OutputBits or (aBits shl CountOutputBits);
  inc(CountOutputBits,aCountBits);
  while CountOutputBits>=8 do begin
   if AllocatedDestSize<(aDestLen+1) then begin
    AllocatedDestSize:=(aDestLen+1) shl 1;
    ReallocMem(aDestData,AllocatedDestSize);
   end;
   PBytes(aDestData)^[aDestLen]:=OutputBits and $ff;
   inc(aDestLen);
   OutputBits:=OutputBits shr 8;
   dec(CountOutputBits,8);
  end;
 end;
 procedure DoOutputLiteral(const aValue:TpvUInt8);
 begin
  case aValue of
   0..143:begin
    DoOutputBits(MirrorBytes[$30+aValue],8);
   end;
   else begin
    DoOutputBits((MirrorBytes[$90+(aValue-144)] shl 1) or 1,9);
   end;
  end;
 end;
 procedure DoOutputCopy(const aDistance,aLength:TpvUInt32);
 var Remain,ToDo,Index:TpvUInt32;
 begin
  Remain:=aLength;
  while Remain>0 do begin
   case Remain of
    0..258:begin
     ToDo:=Remain;
    end;
    259..260:begin
     ToDo:=Remain-3;
    end;
    else begin
     ToDo:=258;
    end;
   end;
   dec(Remain,ToDo);
   Index:=LengthCodesLookUpTable[Min(Max(ToDo,0),258)];
   if LengthCodes[Index,0]<=279 then begin
    DoOutputBits(MirrorBytes[(LengthCodes[Index,0]-256) shl 1],7);
   end else begin
    DoOutputBits(MirrorBytes[$c0+(LengthCodes[Index,0]-280)],8);
   end;
   if LengthCodes[Index,1]<>0 then begin
    DoOutputBits(ToDo-LengthCodes[Index,2],LengthCodes[Index,1]);
   end;
   Index:=DistanceCodesLookUpTable[Min(Max(aDistance,0),32768)];
   DoOutputBits(MirrorBytes[DistanceCodes[Index,0] shl 3],5);
   if DistanceCodes[Index,1]<>0 then begin
    DoOutputBits(aDistance-DistanceCodes[Index,2],DistanceCodes[Index,1]);
   end;
  end;
 end;
 procedure OutputStartBlock;
 begin
  DoOutputBits(1,1); // Final block
  DoOutputBits(1,2); // Static huffman block
 end;
 procedure OutputEndBlock;
 begin
  DoOutputBits(0,7); // Close block
  DoOutputBits(0,7); // Make sure all bits are flushed
 end;
 function Adler32(const aData:TpvPointer;const aLength:TpvSizeUInt):TpvUInt32;
 const Base=65521;
       MaximumCountAtOnce=5552;
 var Buf:PpvRawByteChar;
     Remain,ToDo,Index:TpvSizeUInt;
     s1,s2:TpvUInt32;
 begin
  s1:=1;
  s2:=0;
  Buf:=aData;
  Remain:=aLength;
  while Remain>0 do begin
   if Remain<MaximumCountAtOnce then begin
    ToDo:=Remain;
   end else begin
    ToDo:=MaximumCountAtOnce;
   end;
   dec(Remain,ToDo);
   for Index:=1 to ToDo do begin
    inc(s1,TpvUInt8(Buf^));
    inc(s2,s1);
    inc(Buf);
   end;
   s1:=s1 mod Base;
   s2:=s2 mod Base;
  end;
  result:=(s2 shl 16) or s1;
 end;
var CurrentPointer,EndPointer,EndSearchPointer,Head,CurrentPossibleMatch:PpvUInt8;
    BestMatchDistance,BestMatchLength,MatchLength,MaximumMatchLength,CheckSum,Step,MaxSteps,
    Difference,Offset,SkipStrength,UnsuccessfulFindMatchAttempts:TpvUInt32;
    HashTable:PHashTable;
    ChainTable:PChainTable;
    HashTableItem:PPpvUInt8;
    DoCompression,Greedy:boolean;
begin
 result:=false;
 AllocatedDestSize:=SizeOf(TpvUInt32);
 GetMem(aDestData,AllocatedDestSize);
 aDestLen:=0;
 InitializeLookUpTables;
 try
  DoCompression:=aMode<>TpvDeflateMode.None;
  MaxSteps:=1 shl TpvInt32(aMode);
  SkipStrength:=(32-9)+TpvInt32(aMode);
  Greedy:=TpvInt32(aMode)>=1;
  OutputBits:=0;
  CountOutputBits:=0;
  if DoCompression then begin
   if aWithHeader then begin
    DoOutputBits($78,8); // CMF
    DoOutputBits($9c,8); // FLG Default Compression
   end;
   OutputStartBlock;
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
      if (BestMatchDistance>0) and (BestMatchLength>1) then begin
       DoOutputCopy(BestMatchDistance,BestMatchLength);
      end else begin
       if SkipStrength>31 then begin
        DoOutputLiteral(CurrentPointer^);
       end else begin
        Step:=UnsuccessfulFindMatchAttempts shr SkipStrength;
        Offset:=0;
        while (Offset<Step) and (({%H-}TpvPtrUInt(CurrentPointer)+Offset)<{%H-}TpvPtrUInt(EndSearchPointer)) do begin
         DoOutputLiteral(PpvUInt8Array(CurrentPointer)^[Offset]);
         inc(Offset);
        end;
        BestMatchLength:=Offset;
        inc(UnsuccessfulFindMatchAttempts,ord(UnsuccessfulFindMatchAttempts<TpvUInt32($ffffffff)) and 1);
       end;
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
      DoOutputLiteral(CurrentPointer^);
      inc(CurrentPointer);
     end;
    finally
     FreeMem(ChainTable);
    end;
   finally
    FreeMem(HashTable);
   end;
   OutputEndBlock;
  end else begin
   if aWithHeader then begin
    if AllocatedDestSize<(aDestLen+2) then begin
     AllocatedDestSize:=(aDestLen+2) shl 1;
     ReallocMem(aDestData,AllocatedDestSize);
    end;
    PBytes(aDestData)^[aDestLen+0]:=$78; // CMF
    PBytes(aDestData)^[aDestLen+1]:=$01; // FLG No Compression
    inc(aDestLen,2);
   end;
   if aInLen>0 then begin
    if AllocatedDestSize<(aDestLen+aInLen) then begin
     AllocatedDestSize:=(aDestLen+aInLen) shl 1;
     ReallocMem(aDestData,AllocatedDestSize);
    end;
    Move(aInData^,PBytes(aDestData)^[aDestLen],aInLen);
    inc(aDestLen,aInLen);
   end;
  end;
  if aWithHeader then begin
   CheckSum:=Adler32(aInData,aInLen);
   if AllocatedDestSize<(aDestLen+4) then begin
    AllocatedDestSize:=(aDestLen+4) shl 1;
    ReallocMem(aDestData,AllocatedDestSize);
   end;
   PBytes(aDestData)^[aDestLen+0]:=(CheckSum shr 24) and $ff;
   PBytes(aDestData)^[aDestLen+1]:=(CheckSum shr 16) and $ff;
   PBytes(aDestData)^[aDestLen+2]:=(CheckSum shr 8) and $ff;
   PBytes(aDestData)^[aDestLen+3]:=(CheckSum shr 0) and $ff;
   inc(aDestLen,4);
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
{$ifend}

function DoInflate(const aInData:TpvPointer;aInLen:TpvSizeUInt;var aDestData:TpvPointer;var aDestLen:TpvSizeUInt;const aParseHeader:boolean):boolean;
{$if not defined(fpc)}
const OutChunkSize=65536;
var d_stream:z_stream;
    r:TpvInt32;
    Allocated,Have:TpvSizeUInt;
begin
 result:=false;
 aDestLen:=0;
 Allocated:=0;
 aDestData:=nil;
 FillChar(d_stream,SizeOf(z_stream),AnsiChar(#0));
 d_stream.next_in:=aInData;
 d_stream.avail_in:=aInLen;
 if aParseHeader then begin
  r:=inflateInit(d_stream);
 end else begin
  r:=inflateInit2(d_stream,-15{MAX_WBITS});
 end;
 try
  if r=Z_OK then begin
   try
    Allocated:=RoundUpToPowerOfTwo(aInLen);
    if Allocated<OutChunkSize then begin
     Allocated:=OutChunkSize;
    end;
    GetMem(aDestData,Allocated);
    repeat
     repeat
      if Allocated<(aDestLen+OutChunkSize) then begin
       Allocated:=RoundUpToPowerOfTwo(aDestLen+OutChunkSize);
       if assigned(aDestData) then begin
        ReallocMem(aDestData,Allocated);
       end else begin
        GetMem(aDestData,Allocated);
       end;
      end;
      d_stream.next_out:=@PpvUInt8Array(aDestData)^[aDestLen];
      d_stream.avail_out:=OutChunkSize;
      r:=Inflate(d_stream,Z_NO_FLUSH);
      if r<Z_OK then begin
       break;
      end;
      if d_stream.avail_out<OutChunkSize then begin
       inc(aDestLen,OutChunkSize-d_stream.avail_out);
      end;
     until d_stream.avail_out<>0;
    until (r<Z_OK) or (r=Z_STREAM_END);
   finally
    if r=Z_STREAM_END then begin
     r:=InflateEnd(d_stream);
    end else begin
     InflateEnd(d_stream);
    end;
   end;
  end;
 finally
  if (r=Z_OK) or (r=Z_STREAM_END) then begin
   if assigned(aDestData) then begin
    ReallocMem(aDestData,aDestLen);
   end else begin
    aDestLen:=0;
   end;
   result:=true;
  end else begin
   if assigned(aDestData) then begin
    FreeMem(aDestData);
   end;
   aDestData:=nil;
  end;
 end;
end;
{$elseif defined(fpc) and (defined(Linux) or defined(Android))}
const OutChunkSize=65536;
var d_stream:z_stream;
    r:TpvInt32;
    Allocated,Have:TpvSizeUInt;
begin
 result:=false;
 aDestLen:=0;
 Allocated:=0;
 aDestData:=nil;
 FillChar(d_stream,SizeOf(z_stream),AnsiChar(#0));
 d_stream.next_in:=aInData;
 d_stream.avail_in:=aInLen;
 if aParseHeader then begin
  r:=inflateInit(d_stream);
 end else begin
  r:=inflateInit2(d_stream,-15{MAX_WBITS});
 end;
 try
  if r=Z_OK then begin
   try
    Allocated:=RoundUpToPowerOfTwo(aInLen);
    if Allocated<OutChunkSize then begin
     Allocated:=OutChunkSize;
    end;
    GetMem(aDestData,Allocated);
    repeat
     repeat
      if Allocated<(aDestLen+OutChunkSize) then begin
       Allocated:=RoundUpToPowerOfTwo(aDestLen+OutChunkSize);
       if assigned(aDestData) then begin
        ReallocMem(aDestData,Allocated);
       end else begin
        GetMem(aDestData,Allocated);
       end;
      end;
      d_stream.next_out:=@PpvUInt8Array(aDestData)^[aDestLen];
      d_stream.avail_out:=OutChunkSize;
      r:=Inflate(d_stream,Z_NO_FLUSH);
      if r<Z_OK then begin
       break;
      end;
      if d_stream.avail_out<OutChunkSize then begin
       inc(aDestLen,OutChunkSize-d_stream.avail_out);
      end;
     until d_stream.avail_out<>0;
    until (r<Z_OK) or (r=Z_STREAM_END);
   finally
    if r=Z_STREAM_END then begin
     r:=InflateEnd(d_stream);
    end else begin
     InflateEnd(d_stream);
    end;
   end;
  end;
 finally
  if (r=Z_OK) or (r=Z_STREAM_END) then begin
   if assigned(aDestData) then begin
    ReallocMem(aDestData,aDestLen);
   end else begin
    aDestLen:=0;
   end;
   result:=true;
  end else begin
   if assigned(aDestData) then begin
    FreeMem(aDestData);
   end;
   aDestData:=nil;
  end;
 end;
end;
{$else}
const CLCIndex:array[0..18] of TpvUInt8=(16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15);
type pword=^TpvUInt16;
     PTree=^TTree;
     TTree=packed record
      Table:array[0..15] of TpvUInt16;
      Translation:array[0..287] of TpvUInt16;
     end;
     PBuffer=^TBuffer;
     TBuffer=array[0..65535] of TpvUInt8;
     PLengths=^TLengths;
     TLengths=array[0..288+32-1] of TpvUInt8;
     POffsets=^TOffsets;
     TOffsets=array[0..15] of TpvUInt16;
     PBits=^TBits;
     TBits=array[0..29] of TpvUInt8;
     PBase=^TBase;
     TBase=array[0..29] of TpvUInt16;
var Tag,BitCount,DestSize:TpvUInt32;
    SymbolLengthTree,DistanceTree,FixedSymbolLengthTree,FixedDistanceTree:PTree;
    LengthBits,DistanceBits:PBits;
    LengthBase,DistanceBase:PBase;
    Source,SourceEnd:PpvRawByteChar;
    Dest:PpvRawByteChar;
 procedure IncSize(length:TpvUInt32);
 var j:TpvUInt32;
 begin
  if (aDestLen+length)>=DestSize then begin
   if DestSize=0 then begin
    DestSize:=1;
   end;
   while (aDestLen+length)>=DestSize do begin
    inc(DestSize,DestSize);
   end;
   j:=TpvPtrUInt(Dest)-TpvPtrUInt(aDestData);
   ReAllocMem(aDestData,DestSize);
   TpvPtrUInt(Dest):=TpvPtrUInt(aDestData)+j;
  end;
 end;
 function Adler32(data:TpvPointer;length:TpvSizeUInt):TpvUInt32;
 const BASE=65521;
       NMAX=5552;
 var buf:PpvRawByteChar;
     s1,s2:TpvUInt32;
     k,i:TpvSizeUInt;
 begin
  s1:=1;
  s2:=0;
  buf:=data;
  while length>0 do begin
   if length<NMAX then begin
    k:=length;
   end else begin
    k:=NMAX;
   end;
   dec(length,k);
   for i:=1 to k do begin
    inc(s1,TpvUInt8(buf^));
    inc(s2,s1);
    inc(buf);
   end;
   s1:=s1 mod BASE;
   s2:=s2 mod BASE;
  end;
  result:=(s2 shl 16) or s1;
 end;
 procedure BuildBitsBase(Bits:PpvRawByteChar;Base:pword;Delta,First:TpvInt32);
 var i,Sum:TpvInt32;
 begin
  for i:=0 to Delta-1 do begin
   Bits[i]:=TpvRawByteChar(#0);
  end;
  for i:=0 to (30-Delta)-1 do begin
   Bits[i+Delta]:=TpvRawByteChar(TpvUInt8(i div Delta));
  end;
  Sum:=First;
  for i:=0 to 29 do begin
   Base^:=Sum;
   inc(Base);
   inc(Sum,1 shl TpvUInt8(Bits[i]));
  end;
 end;
 procedure BuildFixedTrees(var lt,dt:TTree);
 var i:TpvInt32;
 begin
  for i:=0 to 6 do begin
   lt.Table[i]:=0;
  end;
  lt.Table[7]:=24;
  lt.Table[8]:=152;
  lt.Table[9]:=112;
  for i:=0 to 23 do begin
   lt.Translation[i]:=256+i;
  end;
  for i:=0 to 143 do begin
   lt.Translation[24+i]:=i;
  end;
  for i:=0 to 7 do begin
   lt.Translation[168+i]:=280+i;
  end;
  for i:=0 to 111 do begin
   lt.Translation[176+i]:=144+i;
  end;
  for i:=0 to 4 do begin
   dt.Table[i]:=0;
  end;
  dt.Table[5]:=32;
  for i:=0 to 31 do begin
   dt.Translation[i]:=i;
  end;
 end;
 procedure BuildTree(var t:TTree;Lengths:PpvRawByteChar;Num:TpvInt32);
 var Offsets:POffsets;
     i:TpvInt32;
     Sum:TpvUInt32;
 begin
  New(Offsets);
  try
   for i:=0 to 15 do begin
    t.Table[i]:=0;
   end;
   for i:=0 to Num-1 do begin
    inc(t.Table[TpvUInt8(Lengths[i])]);
   end;
   t.Table[0]:=0;
   Sum:=0;
   for i:=0 to 15 do begin
    Offsets^[i]:=Sum;
    inc(Sum,t.Table[i]);
   end;
   for i:=0 to Num-1 do begin
    if lengths[i]<>TpvRawByteChar(#0) then begin
     t.Translation[Offsets^[TpvUInt8(lengths[i])]]:=i;
     inc(Offsets^[TpvUInt8(lengths[i])]);
    end;
   end;
  finally
   Dispose(Offsets);
  end;
 end;
 function GetBit:TpvUInt32;
 begin
  if BitCount=0 then begin
   Tag:=TpvUInt8(Source^);
   inc(Source);
   BitCount:=7;
  end else begin
   dec(BitCount);
  end;
  result:=Tag and 1;
  Tag:=Tag shr 1;
 end;
 function ReadBits(Num,Base:TpvUInt32):TpvUInt32;
 var Limit,Mask:TpvUInt32;
 begin
  result:=0;
  if Num<>0 then begin
   Limit:=1 shl Num;
   Mask:=1;
   while Mask<Limit do begin
    if GetBit<>0 then begin
     inc(result,Mask);
    end;
    Mask:=Mask shl 1;
   end;
  end;
  inc(result,Base);
 end;
 function DecodeSymbol(var t:TTree):TpvUInt32;
 var Sum,c,l:TpvInt32;
 begin
  Sum:=0;
  c:=0;
  l:=0;
  repeat
   c:=(c*2)+TpvInt32(GetBit);
   inc(l);
   inc(Sum,t.Table[l]);
   dec(c,t.Table[l]);
  until not (c>=0);
  result:=t.Translation[Sum+c];
 end;
 procedure DecodeTrees(var lt,dt:TTree);
 var CodeTree:PTree;
     Lengths:PLengths;
     hlit,hdist,hclen,i,num,length,clen,Symbol,Prev:TpvUInt32;
 begin
  New(CodeTree);
  New(Lengths);
  try
   FillChar(CodeTree^,sizeof(TTree),TpvRawByteChar(#0));
   FillChar(Lengths^,sizeof(TLengths),TpvRawByteChar(#0));
   hlit:=ReadBits(5,257);
   hdist:=ReadBits(5,1);
   hclen:=ReadBits(4,4);
   for i:=0 to 18 do begin
    lengths^[i]:=0;
   end;
   for i:=1 to hclen do begin
    clen:=ReadBits(3,0);
    lengths^[CLCIndex[i-1]]:=clen;
   end;
   BuildTree(CodeTree^,PpvRawByteChar(TpvPointer(@lengths^[0])),19);
   num:=0;
   while num<(hlit+hdist) do begin
    Symbol:=DecodeSymbol(CodeTree^);
    case Symbol of
     16:begin
      prev:=lengths^[num-1];
      length:=ReadBits(2,3);
      while length>0 do begin
       lengths^[num]:=prev;
       inc(num);
       dec(length);
      end;
     end;
     17:begin
      length:=ReadBits(3,3);
      while length>0 do begin
       lengths^[num]:=0;
       inc(num);
       dec(length);
      end;
     end;
     18:begin
      length:=ReadBits(7,11);
      while length>0 do begin
       lengths^[num]:=0;
       inc(num);
       dec(length);
      end;
     end;
     else begin
      lengths^[num]:=Symbol;
      inc(num);
     end;
    end;
   end;
   BuildTree(lt,PpvRawByteChar(TpvPointer(@lengths^[0])),hlit);
   BuildTree(dt,PpvRawByteChar(TpvPointer(@lengths^[hlit])),hdist);
  finally
   Dispose(CodeTree);
   Dispose(Lengths);
  end;
 end;
 function InflateBlockData(var lt,dt:TTree):boolean;
 var Symbol:TpvUInt32;
     Length,Distance,Offset,i:TpvInt32;
 begin
  result:=false;
  while (Source<SourceEnd) or (BitCount>0) do begin
   Symbol:=DecodeSymbol(lt);
   if Symbol=256 then begin
    result:=true;
    break;
   end;
   if Symbol<256 then begin
    IncSize(1);
    Dest^:=TpvRawByteChar(TpvUInt8(Symbol));
    inc(Dest);
    inc(aDestLen);
   end else begin
    dec(Symbol,257);
    Length:=ReadBits(LengthBits^[Symbol],LengthBase^[Symbol]);
    Distance:=DecodeSymbol(dt);
    Offset:=ReadBits(DistanceBits^[Distance],DistanceBase^[Distance]);
    IncSize(length);
    for i:=0 to length-1 do begin
     Dest[i]:=Dest[i-Offset];
    end;
    inc(Dest,Length);
    inc(aDestLen,Length);
   end;
  end;
 end;
 function InflateUncompressedBlock:boolean;
 var length,invlength:TpvUInt32;
 begin
  result:=false;
  length:=(TpvUInt8(source[1]) shl 8) or TpvUInt8(source[0]);
  invlength:=(TpvUInt8(source[3]) shl 8) or TpvUInt8(source[2]);
  if length<>((not invlength) and $ffff) then begin
   exit;
  end;
  IncSize(length);
  inc(Source,4);
  if Length>0 then begin
   Move(Source^,Dest^,Length);
   inc(Source,Length);
   inc(Dest,Length);
  end;
  BitCount:=0;
  inc(aDestLen,Length);
  result:=true;
 end;
 function InflateFixedBlock:boolean;
 begin
  result:=InflateBlockData(FixedSymbolLengthTree^,FixedDistanceTree^);
 end;
 function InflateDynamicBlock:boolean;
 begin
  DecodeTrees(SymbolLengthTree^,DistanceTree^);
  result:=InflateBlockData(SymbolLengthTree^,DistanceTree^);
 end;
 function Uncompress:boolean;
 var Final,r:boolean;
     BlockType:TpvUInt32;
 begin
  result:=false;
  BitCount:=0;
  Final:=false;
  while not Final do begin
   Final:=GetBit<>0;
   BlockType:=ReadBits(2,0);
   case BlockType of
    0:begin
     r:=InflateUncompressedBlock;
    end;
    1:begin
     r:=InflateFixedBlock;
    end;
    2:begin
     r:=InflateDynamicBlock;
    end;
    else begin
     r:=false;
    end;
   end;
   if not r then begin
    exit;
   end;
  end;
  result:=true;
 end;
 function UncompressZLIB:boolean;
 var cmf,flg:TpvUInt8;
     a32:TpvUInt32;
 begin
  result:=false;
  Source:=aInData;
  cmf:=TpvUInt8(Source[0]);
  flg:=TpvUInt8(Source[1]);
  if ((((cmf shl 8)+flg) mod 31)<>0) or ((cmf and $f)<>8) or ((cmf shr 4)>7) or ((flg and $20)<>0) then begin
   exit;
  end;
  a32:=(TpvUInt8(Source[aInLen-4]) shl 24) or (TpvUInt8(Source[aInLen-3]) shl 16) or (TpvUInt8(Source[aInLen-2]) shl 8) or (TpvUInt8(Source[aInLen-1]) shl 0);
  inc(Source,2);
  dec(aInLen,6);
  SourceEnd:=@Source[aInLen];
  result:=Uncompress;
  if not result then begin
   exit;
  end;
  result:=Adler32(aDestData,aDestLen)=a32;
 end;
 function UncompressDirect:boolean;
 begin
  Source:=aInData;
  SourceEnd:=@Source[aInLen];
  result:=Uncompress;
 end;
begin
 aDestData:=nil;
 LengthBits:=nil;
 DistanceBits:=nil;
 LengthBase:=nil;
 DistanceBase:=nil;
 SymbolLengthTree:=nil;
 DistanceTree:=nil;
 FixedSymbolLengthTree:=nil;
 FixedDistanceTree:=nil;
 try
  New(LengthBits);
  New(DistanceBits);
  New(LengthBase);
  New(DistanceBase);
  New(SymbolLengthTree);
  New(DistanceTree);
  New(FixedSymbolLengthTree);
  New(FixedDistanceTree);
  try
   begin
    FillChar(LengthBits^,sizeof(TBits),TpvRawByteChar(#0));
    FillChar(DistanceBits^,sizeof(TBits),TpvRawByteChar(#0));
    FillChar(LengthBase^,sizeof(TBase),TpvRawByteChar(#0));
    FillChar(DistanceBase^,sizeof(TBase),TpvRawByteChar(#0));
    FillChar(SymbolLengthTree^,sizeof(TTree),TpvRawByteChar(#0));
    FillChar(DistanceTree^,sizeof(TTree),TpvRawByteChar(#0));
    FillChar(FixedSymbolLengthTree^,sizeof(TTree),TpvRawByteChar(#0));
    FillChar(FixedDistanceTree^,sizeof(TTree),TpvRawByteChar(#0));
   end;
   begin
    BuildFixedTrees(FixedSymbolLengthTree^,FixedDistanceTree^);
    BuildBitsBase(PpvRawByteChar(TpvPointer(@LengthBits^[0])),pword(TpvPointer(@LengthBase^[0])),4,3);
    BuildBitsBase(PpvRawByteChar(TpvPointer(@DistanceBits^[0])),pword(TpvPointer(@DistanceBase^[0])),2,1);
    LengthBits^[28]:=0;
    LengthBase^[28]:=258;
   end;
   begin
    GetMem(aDestData,4096);
    DestSize:=4096;
    Dest:=aDestData;
    aDestLen:=0;
    if aParseHeader then begin
     result:=UncompressZLIB;
    end else begin
     result:=UncompressDirect;
    end;
    if result then begin
     ReAllocMem(aDestData,aDestLen);
    end else if assigned(aDestData) then begin
     FreeMem(aDestData);
     aDestData:=nil;
    end;
   end;
  finally
   if assigned(LengthBits) then begin
    Dispose(LengthBits);
   end;
   if assigned(DistanceBits) then begin
    Dispose(DistanceBits);
   end;
   if assigned(LengthBase) then begin
    Dispose(LengthBase);
   end;
   if assigned(DistanceBase) then begin
    Dispose(DistanceBase);
   end;
   if assigned(SymbolLengthTree) then begin
    Dispose(SymbolLengthTree);
   end;
   if assigned(DistanceTree) then begin
    Dispose(DistanceTree);
   end;
   if assigned(FixedSymbolLengthTree) then begin
    Dispose(FixedSymbolLengthTree);
   end;
   if assigned(FixedDistanceTree) then begin
    Dispose(FixedDistanceTree);
   end;
  end;
 except
  result:=false;
 end;
end;
{$ifend}

{$if not (defined(fpc) and (defined(Linux) or defined(Android)))}
initialization
 InitializeLookUpTables;
{$ifend}
end.
