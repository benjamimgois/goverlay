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
unit PasVulkan.Compression.LZBRS;
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

// LZBRS is a simple LZ77/LZSS-style algorithm like BriefLZ, but with 32-bit tags instead 16-bit tags,
// and with end tag (match with offset 0)

// Not to be confused with the old equal-named LRBRS from BeRoEXEPacker, which was 8-bit byte-wise tag-based.

type TpvLZBRSLevel=0..9;
     PpvLZBRSLevel=^TpvLZBRSLevel;

function LZBRSCompress(const aInData:TpvPointer;const aInLen:TpvUInt64;out aDestData:TpvPointer;out aDestLen:TpvUInt64;const aLevel:TpvLZBRSLevel=5;const aWithSize:boolean=true):boolean;

function LZBRSDecompress(const aInData:TpvPointer;aInLen:TpvUInt64;var aDestData:TpvPointer;out aDestLen:TpvUInt64;const aOutputSize:TpvInt64=-1;const aWithSize:boolean=true):boolean;

implementation

function LZBRSCompress(const aInData:TpvPointer;const aInLen:TpvUInt64;out aDestData:TpvPointer;out aDestLen:TpvUInt64;const aLevel:TpvLZBRSLevel;const aWithSize:boolean):boolean;
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
    Difference,Offset,SkipStrength,UnsuccessfulFindMatchAttempts,
    BitCount:TpvUInt32;
    HashTable:PHashTable;
    ChainTable:PChainTable;
    HashTableItem:PPpvUInt8;
    Greedy:boolean;
    Tag:TpvUInt32;
    TagPointer:TpvUInt64;
    AllocatedDestSize:TpvUInt64;
 procedure DoOutputBlock(const aData:Pointer;const aSize:TpvUInt64);
 begin
  if aSize>0 then begin
   if AllocatedDestSize<(aDestLen+aSize) then begin
    AllocatedDestSize:=(aDestLen+aSize) shl 1;
    ReallocMem(aDestData,AllocatedDestSize);
   end;
   Move(aData^,PBytes(aDestData)^[aDestLen],aSize);
   inc(aDestLen,aSize);
  end;
 end;
 function DoOutputUInt8(const aValue:TpvUInt8):TpvUInt64;
 begin
  if AllocatedDestSize<(aDestLen+SizeOf(TpvUInt8)) then begin
   AllocatedDestSize:=(aDestLen+SizeOf(TpvUInt8)) shl 1;
   ReallocMem(aDestData,AllocatedDestSize);
  end;
  result:=aDestLen;
  PpvUInt8(Pointer(@PBytes(aDestData)^[aDestLen]))^:=aValue;
  inc(aDestLen,SizeOf(TpvUInt8));
 end;
 function DoOutputUInt16(const aValue:TpvUInt16):TpvUInt64;
 begin
{$ifdef little_endian}
  if AllocatedDestSize<(aDestLen+SizeOf(TpvUInt16)) then begin
   AllocatedDestSize:=(aDestLen+SizeOf(TpvUInt16)) shl 1;
   ReallocMem(aDestData,AllocatedDestSize);
  end;
  result:=aDestLen;
  PpvUInt16(Pointer(@PBytes(aDestData)^[aDestLen]))^:=aValue;
  inc(aDestLen,SizeOf(TpvUInt16));
{$else}
  result:=DoOutputUInt8((aValue shr 0) and $ff);
  DoOutputUInt8((aValue shr 8) and $ff);
{$endif}
 end;
 procedure DoOutputUInt24(const aValue:TpvUInt32);
 begin
{$ifdef LITTLE_ENDIAN}
  if AllocatedDestSize<(aDestLen+SizeOf(TpvUInt16)) then begin
   AllocatedDestSize:=(aDestLen+SizeOf(TpvUInt16)) shl 1;
   ReallocMem(aDestData,AllocatedDestSize);
  end;
  PpvUInt16(Pointer(@PBytes(aDestData)^[aDestLen]))^:=aValue and $ffff;
  inc(aDestLen,SizeOf(TpvUInt16));
{$else}
  DoOutputUInt8((aValue shr 0) and $ff);
  DoOutputUInt8((aValue shr 8) and $ff);
{$endif}
  DoOutputUInt8((aValue shr 16) and $ff);
 end;
 function DoOutputUInt32(const aValue:TpvUInt32):TpvUInt64;
 begin
{$ifdef LITTLE_ENDIAN}
  if AllocatedDestSize<(aDestLen+SizeOf(TpvUInt32)) then begin
   AllocatedDestSize:=(aDestLen+SizeOf(TpvUInt32)) shl 1;
   ReallocMem(aDestData,AllocatedDestSize);
  end;
  result:=aDestLen;
  PpvUInt32(Pointer(@PBytes(aDestData)^[aDestLen]))^:=aValue;
  inc(aDestLen,SizeOf(TpvUInt32));
{$else}
  result:=DoOutputUInt8((aValue shr 0) and $ff);
  DoOutputUInt8((aValue shr 8) and $ff);
  DoOutputUInt8((aValue shr 16) and $ff);
  DoOutputUInt8((aValue shr 32) and $ff);
{$endif}
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
 procedure DoOutputBit(Bit:boolean);
 begin
  if BitCount=0 then begin
{$ifdef BIG_ENDIAN}
   Tag:=((Tag and TpvUInt64($ff000000) shr 24) or
        ((Tag and TpvUInt64($00ff0000) shr 8) or
        ((Tag and TpvUInt64($0000ff00) shl 8) or
        ((Tag and TpvUInt64($000000ff) shl 24);
{$endif}
   PpvUInt32(Pointer(@PBytes(aDestData)^[TagPointer]))^:=Tag;
   if AllocatedDestSize<(aDestLen+SizeOf(TpvUInt32)) then begin
    AllocatedDestSize:=(aDestLen+SizeOf(TpvUInt32)) shl 1;
    ReallocMem(aDestData,AllocatedDestSize);
   end;
   TagPointer:=aDestLen;
   inc(aDestLen,SizeOf(TpvUInt32));
   BitCount:=31;
  end else begin
   dec(BitCount);
  end;
  Tag:=(Tag shl 1) or (ord(Bit) and 1);
 end;
 procedure DoOutputBits(Value,Bits:TpvUInt32);
 var ToDo:TpvUInt32;
     RemainBits:TpvUInt32;
 begin
  RemainBits:=Bits;
  while RemainBits>0 do begin
   if BitCount=0 then begin
{$ifdef BIG_ENDIAN}
    Tag:=((Tag and TpvUInt64($ff000000) shr 24) or
         ((Tag and TpvUInt64($00ff0000) shr 8) or
         ((Tag and TpvUInt64($0000ff00) shl 8) or
         ((Tag and TpvUInt64($000000ff) shl 24);
{$endif}
    PpvUInt32(Pointer(@PBytes(aDestData)^[TagPointer]))^:=Tag;
    if AllocatedDestSize<(aDestLen+SizeOf(TpvUInt32)) then begin
     AllocatedDestSize:=(aDestLen+SizeOf(TpvUInt32)) shl 1;
     ReallocMem(aDestData,AllocatedDestSize);
    end;
    TagPointer:=aDestLen;
    inc(aDestLen,SizeOf(TpvUInt32));
    BitCount:=32;
   end;
   if RemainBits<BitCount then begin
    ToDo:=RemainBits;
   end else begin
    ToDo:=BitCount;
   end;
   dec(BitCount,ToDo);
   dec(RemainBits,ToDo);
   Tag:=(Tag shl ToDo) or ((Value shr RemainBits) and ((TpvUInt32(1) shl ToDo)-1));
  end;
 end;
 procedure DoOutputGamma(Value:TpvUInt32);
 const LookUpTable:array[0..511,0..1] of TpvUInt32=
        (
	       (0,0),
	       (0,0),
	       ($00,2),($02,2),
	       ($04,4),($06,4),($0c,4),($0e,4),
	       ($14,6),($16,6),($1c,6),($1e,6),
	       ($34,6),($36,6),($3c,6),($3e,6),
	       ($54,8),($56,8),($5c,8),($5e,8),
	       ($74,8),($76,8),($7c,8),($7e,8),
	       ($d4,8),($d6,8),($dc,8),($de,8),
	       ($f4,8),($f6,8),($fc,8),($fe,8),
	       ($154,10),($156,10),($15c,10),($15e,10),
	       ($174,10),($176,10),($17c,10),($17e,10),
	       ($1d4,10),($1d6,10),($1dc,10),($1de,10),
	       ($1f4,10),($1f6,10),($1fc,10),($1fe,10),
	       ($354,10),($356,10),($35c,10),($35e,10),
	       ($374,10),($376,10),($37c,10),($37e,10),
	       ($3d4,10),($3d6,10),($3dc,10),($3de,10),
	       ($3f4,10),($3f6,10),($3fc,10),($3fe,10),
	       ($554,12),($556,12),($55c,12),($55e,12),
	       ($574,12),($576,12),($57c,12),($57e,12),
	       ($5d4,12),($5d6,12),($5dc,12),($5de,12),
	       ($5f4,12),($5f6,12),($5fc,12),($5fe,12),
	       ($754,12),($756,12),($75c,12),($75e,12),
	       ($774,12),($776,12),($77c,12),($77e,12),
	       ($7d4,12),($7d6,12),($7dc,12),($7de,12),
	       ($7f4,12),($7f6,12),($7fc,12),($7fe,12),
	       ($d54,12),($d56,12),($d5c,12),($d5e,12),
	       ($d74,12),($d76,12),($d7c,12),($d7e,12),
	       ($dd4,12),($dd6,12),($ddc,12),($dde,12),
	       ($df4,12),($df6,12),($dfc,12),($dfe,12),
	       ($f54,12),($f56,12),($f5c,12),($f5e,12),
	       ($f74,12),($f76,12),($f7c,12),($f7e,12),
	       ($fd4,12),($fd6,12),($fdc,12),($fde,12),
	       ($ff4,12),($ff6,12),($ffc,12),($ffe,12),
	       ($1554,14),($1556,14),($155c,14),($155e,14),
	       ($1574,14),($1576,14),($157c,14),($157e,14),
	       ($15d4,14),($15d6,14),($15dc,14),($15de,14),
	       ($15f4,14),($15f6,14),($15fc,14),($15fe,14),
	       ($1754,14),($1756,14),($175c,14),($175e,14),
	       ($1774,14),($1776,14),($177c,14),($177e,14),
	       ($17d4,14),($17d6,14),($17dc,14),($17de,14),
	       ($17f4,14),($17f6,14),($17fc,14),($17fe,14),
	       ($1d54,14),($1d56,14),($1d5c,14),($1d5e,14),
	       ($1d74,14),($1d76,14),($1d7c,14),($1d7e,14),
	       ($1dd4,14),($1dd6,14),($1ddc,14),($1dde,14),
	       ($1df4,14),($1df6,14),($1dfc,14),($1dfe,14),
	       ($1f54,14),($1f56,14),($1f5c,14),($1f5e,14),
	       ($1f74,14),($1f76,14),($1f7c,14),($1f7e,14),
	       ($1fd4,14),($1fd6,14),($1fdc,14),($1fde,14),
	       ($1ff4,14),($1ff6,14),($1ffc,14),($1ffe,14),
	       ($3554,14),($3556,14),($355c,14),($355e,14),
	       ($3574,14),($3576,14),($357c,14),($357e,14),
	       ($35d4,14),($35d6,14),($35dc,14),($35de,14),
	       ($35f4,14),($35f6,14),($35fc,14),($35fe,14),
	       ($3754,14),($3756,14),($375c,14),($375e,14),
	       ($3774,14),($3776,14),($377c,14),($377e,14),
	       ($37d4,14),($37d6,14),($37dc,14),($37de,14),
	       ($37f4,14),($37f6,14),($37fc,14),($37fe,14),
	       ($3d54,14),($3d56,14),($3d5c,14),($3d5e,14),
	       ($3d74,14),($3d76,14),($3d7c,14),($3d7e,14),
	       ($3dd4,14),($3dd6,14),($3ddc,14),($3dde,14),
	       ($3df4,14),($3df6,14),($3dfc,14),($3dfe,14),
	       ($3f54,14),($3f56,14),($3f5c,14),($3f5e,14),
	       ($3f74,14),($3f76,14),($3f7c,14),($3f7e,14),
	       ($3fd4,14),($3fd6,14),($3fdc,14),($3fde,14),
	       ($3ff4,14),($3ff6,14),($3ffc,14),($3ffe,14),
	       ($5554,16),($5556,16),($555c,16),($555e,16),
	       ($5574,16),($5576,16),($557c,16),($557e,16),
	       ($55d4,16),($55d6,16),($55dc,16),($55de,16),
	       ($55f4,16),($55f6,16),($55fc,16),($55fe,16),
	       ($5754,16),($5756,16),($575c,16),($575e,16),
	       ($5774,16),($5776,16),($577c,16),($577e,16),
	       ($57d4,16),($57d6,16),($57dc,16),($57de,16),
	       ($57f4,16),($57f6,16),($57fc,16),($57fe,16),
	       ($5d54,16),($5d56,16),($5d5c,16),($5d5e,16),
	       ($5d74,16),($5d76,16),($5d7c,16),($5d7e,16),
	       ($5dd4,16),($5dd6,16),($5ddc,16),($5dde,16),
	       ($5df4,16),($5df6,16),($5dfc,16),($5dfe,16),
	       ($5f54,16),($5f56,16),($5f5c,16),($5f5e,16),
	       ($5f74,16),($5f76,16),($5f7c,16),($5f7e,16),
	       ($5fd4,16),($5fd6,16),($5fdc,16),($5fde,16),
	       ($5ff4,16),($5ff6,16),($5ffc,16),($5ffe,16),
	       ($7554,16),($7556,16),($755c,16),($755e,16),
	       ($7574,16),($7576,16),($757c,16),($757e,16),
	       ($75d4,16),($75d6,16),($75dc,16),($75de,16),
	       ($75f4,16),($75f6,16),($75fc,16),($75fe,16),
	       ($7754,16),($7756,16),($775c,16),($775e,16),
	       ($7774,16),($7776,16),($777c,16),($777e,16),
	       ($77d4,16),($77d6,16),($77dc,16),($77de,16),
	       ($77f4,16),($77f6,16),($77fc,16),($77fe,16),
	       ($7d54,16),($7d56,16),($7d5c,16),($7d5e,16),
	       ($7d74,16),($7d76,16),($7d7c,16),($7d7e,16),
	       ($7dd4,16),($7dd6,16),($7ddc,16),($7dde,16),
	       ($7df4,16),($7df6,16),($7dfc,16),($7dfe,16),
	       ($7f54,16),($7f56,16),($7f5c,16),($7f5e,16),
	       ($7f74,16),($7f76,16),($7f7c,16),($7f7e,16),
	       ($7fd4,16),($7fd6,16),($7fdc,16),($7fde,16),
	       ($7ff4,16),($7ff6,16),($7ffc,16),($7ffe,16),
	       ($d554,16),($d556,16),($d55c,16),($d55e,16),
	       ($d574,16),($d576,16),($d57c,16),($d57e,16),
	       ($d5d4,16),($d5d6,16),($d5dc,16),($d5de,16),
	       ($d5f4,16),($d5f6,16),($d5fc,16),($d5fe,16),
	       ($d754,16),($d756,16),($d75c,16),($d75e,16),
	       ($d774,16),($d776,16),($d77c,16),($d77e,16),
	       ($d7d4,16),($d7d6,16),($d7dc,16),($d7de,16),
	       ($d7f4,16),($d7f6,16),($d7fc,16),($d7fe,16),
	       ($dd54,16),($dd56,16),($dd5c,16),($dd5e,16),
	       ($dd74,16),($dd76,16),($dd7c,16),($dd7e,16),
	       ($ddd4,16),($ddd6,16),($dddc,16),($ddde,16),
	       ($ddf4,16),($ddf6,16),($ddfc,16),($ddfe,16),
	       ($df54,16),($df56,16),($df5c,16),($df5e,16),
	       ($df74,16),($df76,16),($df7c,16),($df7e,16),
	       ($dfd4,16),($dfd6,16),($dfdc,16),($dfde,16),
	       ($dff4,16),($dff6,16),($dffc,16),($dffe,16),
	       ($f554,16),($f556,16),($f55c,16),($f55e,16),
	       ($f574,16),($f576,16),($f57c,16),($f57e,16),
	       ($f5d4,16),($f5d6,16),($f5dc,16),($f5de,16),
	       ($f5f4,16),($f5f6,16),($f5fc,16),($f5fe,16),
	       ($f754,16),($f756,16),($f75c,16),($f75e,16),
	       ($f774,16),($f776,16),($f77c,16),($f77e,16),
	       ($f7d4,16),($f7d6,16),($f7dc,16),($f7de,16),
	       ($f7f4,16),($f7f6,16),($f7fc,16),($f7fe,16),
	       ($fd54,16),($fd56,16),($fd5c,16),($fd5e,16),
	       ($fd74,16),($fd76,16),($fd7c,16),($fd7e,16),
	       ($fdd4,16),($fdd6,16),($fddc,16),($fdde,16),
	       ($fdf4,16),($fdf6,16),($fdfc,16),($fdfe,16),
	       ($ff54,16),($ff56,16),($ff5c,16),($ff5e,16),
	       ($ff74,16),($ff76,16),($ff7c,16),($ff7e,16),
	       ($ffd4,16),($ffd6,16),($ffdc,16),($ffde,16),
	       ($fff4,16),($fff6,16),($fffc,16),($fffe,16)
        );
 var Mask:TpvUInt32;
 begin
  if Value<=High(LookUpTable) then begin
   DoOutputBits(LookUpTable[Value,0],LookUpTable[Value,1]);
  end else begin
{$if declared(BSRDWord)}
   Mask:=TpvUInt32(1) shl (BSRDWord(Value)-1);
{$else}
   Mask:=Value shr 1;
   while (Mask and (Mask-1))<>0 do begin
    Mask:=Mask and (Mask-1);
   end;
{$ifend}
   DoOutputBit((Value and Mask)<>0);
   Mask:=Mask shr 1;
   while Mask<>0 do begin
    DoOutputBit(true);
    DoOutputBit((Value and Mask)<>0);
    Mask:=Mask shr 1;
   end;
   DoOutputBit(false);
  end;
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
  Greedy:=aLevel>=TpvLZBRSLevel(1);
  if aWithSize then begin
   DoOutputUInt64(aInLen);
  end;
  BitCount:=32;
  TagPointer:=DoOutputUInt32(0);
  Tag:=0;
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
     if (BestMatchLength>4) or ((BestMatchLength=4) and (BestMatchDistance<$7e00)) then begin
      DoOutputBit(true);
      DoOutputGamma(BestMatchLength-2);
      DoOutputGamma((BestMatchDistance shr 8)+2);
      DoOutputUInt8(BestMatchDistance and $ff);
     end else begin
      if (SkipStrength>31) and (BestMatchLength=1) then begin
       DoOutputBit(false);
       DoOutputUInt8(CurrentPointer^);
      end else begin
       BestMatchLength:=1;
       if BestMatchLength=1 then begin
        Step:=UnsuccessfulFindMatchAttempts shr SkipStrength;
       end else begin
        Step:=BestMatchLength;
       end;
       Offset:=0;
       while Offset<Step do begin
        if ({%H-}TpvPtrUInt(CurrentPointer)+Offset)<{%H-}TpvPtrUInt(EndSearchPointer) then begin
         DoOutputBit(false);
         DoOutputUInt8(PpvUInt8Array(CurrentPointer)^[Offset]);
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
     DoOutputBit(false);
     DoOutputUInt8(CurrentPointer^);
     inc(CurrentPointer);
    end;
   finally
    FreeMem(ChainTable);
   end;
  finally
   FreeMem(HashTable);
  end;
  begin
   // End tag
   DoOutputBit(true);
   DoOutputGamma(2);
   DoOutputGamma(2);
   DoOutputUInt8(0);
  end;
  begin
   // Flush bits
   Tag:=Tag shl BitCount;
{$ifdef BIG_ENDIAN}
   Tag:=((Tag and TpvUInt64($ff000000) shr 24) or
        ((Tag and TpvUInt64($00ff0000) shr 8) or
        ((Tag and TpvUInt64($0000ff00) shl 8) or
        ((Tag and TpvUInt64($000000ff) shl 24);
{$endif}
   PpvUInt32(Pointer(@PBytes(aDestData)^[TagPointer]))^:=Tag;
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

function LZBRSDecompress(const aInData:TpvPointer;aInLen:TpvUInt64;var aDestData:TpvPointer;out aDestLen:TpvUInt64;const aOutputSize:TpvInt64;const aWithSize:boolean):boolean;
type TBlock1=TpvUInt8;
     TBlock2=TpvUInt16;
     TBlock3=array[0..2] of TpvUInt8;
     TBlock4=TpvUInt32;
     TBlock5=array[0..4] of TpvUInt8;
     TBlock6=array[0..5] of TpvUInt8;
     TBlock7=array[0..6] of TpvUInt8;
     TBlock8=TpvUInt64;
     TBlock16=array[0..1] of TpvUInt64;
     TBlock32=array[0..3] of TpvUInt64;
     TBlock64=array[0..7] of TpvUInt64;
     PBlock1=^TBlock1;
     PBlock2=^TBlock2;
     PBlock3=^TBlock3;
     PBlock4=^TBlock4;
     PBlock5=^TBlock5;
     PBlock6=^TBlock6;
     PBlock7=^TBlock7;
     PBlock8=^TBlock8;
     PBlock16=^TBlock16;
     PBlock32=^TBlock32;
     PBlock64=^TBlock64;
var InputPointer,InputEnd,OutputPointer,OutputEnd,CopyFromPointer:PpvUInt8;
    Len,Offset,Tag,BitCount:TpvUInt32;
    OutputSize:TpvUInt64;
    OK,Allocated:boolean;
function GetBit:TpvUInt32;
 begin
  if BitCount=0 then begin
   if (TpvPtrUInt(InputPointer)+SizeOf(TpvUInt32))>TpvPtrUInt(InputEnd) then begin
    OK:=false;
    result:=0;
    exit;
   end;
   Tag:=TpvUInt32(pointer(InputPointer)^);
{$ifdef BIG_ENDIAN}
   Tag:=((Tag and TpvUInt64($ff000000) shr 24) or
        ((Tag and TpvUInt64($00ff0000) shr 8) or
        ((Tag and TpvUInt64($0000ff00) shl 8) or
        ((Tag and TpvUInt64($000000ff) shl 24);
{$endif}
   inc(InputPointer,SizeOf(TpvUInt32));
   BitCount:=31;
  end else begin
   dec(BitCount);
  end;
  result:=Tag shr 31;
  Tag:=Tag shl 1;
 end;
 function GetGamma:TpvUInt32;
 const LookUpTable:array[0..255,0..1] of TpvUInt8=
        (
         (2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),
         (2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),
         (2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),
         (2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),
         (2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),
         (2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),
         (2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),
         (2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),(2,2),
         (4,4),(4,4),(4,4),(4,4),(4,4),(4,4),(4,4),(4,4),
         (4,4),(4,4),(4,4),(4,4),(4,4),(4,4),(4,4),(4,4),
         (8,6),(8,6),(8,6),(8,6),
         (16,8),(16,0),(17,8),(17,0),
         (9,6),(9,6),(9,6),(9,6),
         (18,8),(18,0),(19,8),(19,0),
         (5,4),(5,4),(5,4),(5,4),(5,4),(5,4),(5,4),(5,4),
         (5,4),(5,4),(5,4),(5,4),(5,4),(5,4),(5,4),(5,4),
         (10,6),(10,6),(10,6),(10,6),
         (20,8),(20,0),(21,8),(21,0),
         (11,6),(11,6),(11,6),(11,6),
         (22,8),(22,0),(23,8),(23,0),
         (3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),
         (3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),
         (3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),
         (3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),
         (3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),
         (3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),
         (3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),
         (3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),(3,2),
         (6,4),(6,4),(6,4),(6,4),(6,4),(6,4),(6,4),(6,4),
         (6,4),(6,4),(6,4),(6,4),(6,4),(6,4),(6,4),(6,4),
         (12,6),(12,6),(12,6),(12,6),
         (24,8),(24,0),(25,8),(25,0),
         (13,6),(13,6),(13,6),(13,6),
         (26,8),(26,0),(27,8),(27,0),
         (7,4),(7,4),(7,4),(7,4),(7,4),(7,4),(7,4),(7,4),
         (7,4),(7,4),(7,4),(7,4),(7,4),(7,4),(7,4),(7,4),
         (14,6),(14,6),(14,6),(14,6),
         (28,8),(28,0),(29,8),(29,0),
         (15,6),(15,6),(15,6),(15,6),
         (30,8),(30,0),(31,8),(31,0)
        );
 var Top,Shift:TpvUInt8;
 begin
  result:=1;
  if BitCount>=8 then begin
   Top:=Tag shr 24;
   result:=LookUpTable[Top,0];
   Shift:=LookUpTable[Top,1];
   if Shift<>0 then begin
    Tag:=Tag shl Shift;
    dec(BitCount,Shift);
    exit;
   end;
   Tag:=Tag shl 8;
   dec(BitCount,8);
  end;
  repeat
   result:=(result shl 1) or GetBit;
  until GetBit=0;
 end;
begin

 // If the input size is too small, then exit early
 if (aWithSize and (aInLen<(SizeOf(TpvUInt64)+SizeOf(TpvUInt32)))) or ((not aWithSize) and (aInLen<SizeOf(TpvUInt32))) then begin
  result:=false;
  exit;
 end;

 // Setup stuff
 InputPointer:=aInData;
 InputEnd:=@PpvUInt8Array(InputPointer)^[aInLen];

 if aWithSize then begin
  OutputSize:=PpvUInt64(InputPointer)^;
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
  inc(PpvUInt64(InputPointer));
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

 OutputPointer:=aDestData;
 OutputEnd:=@PpvUInt8Array(OutputPointer)^[OutputSize];

 result:=true;

 Tag:=TpvUInt32(pointer(InputPointer)^);
{$ifdef BIG_ENDIAN}
 Tag:=((Tag and TpvUInt64($ff000000) shr 24) or
      ((Tag and TpvUInt64($00ff0000) shr 8) or
      ((Tag and TpvUInt64($0000ff00) shl 8) or
      ((Tag and TpvUInt64($000000ff) shl 24);
{$endif}
 inc(InputPointer,SizeOf(TpvUInt32));
 BitCount:=32;

{Tag:=0;
 BitCount:=0;}

 while TpvPtrUInt(InputPointer)<TpvPtrUInt(InputEnd) do begin

  OK:=true;

  if GetBit<>0 then begin

   Len:=GetGamma+2;

   Offset:=GetGamma-2;

   if (TpvPtrUInt(InputPointer)>=TpvPtrUInt(InputEnd)) or not OK then begin
    result:=false;
    break;
   end;

   Offset:=(Offset shl 8) or InputPointer^;
   inc(InputPointer);

   if Offset=0 then begin

    // End code
    break;

   end else begin

    CopyFromPointer:=pointer(TpvPtrUInt(TpvPtrUInt(OutputPointer)-TpvPtrUInt(Offset)));
    if (TpvPtrUInt(CopyFromPointer)<TpvPtrUInt(aDestData)) or
       ((TpvPtrUInt(OutputPointer)+TpvPtrUInt(Len))>TpvPtrUInt(OutputEnd)) then begin
     result:=false;
     break;
    end;

    if (TpvPtrUInt(CopyFromPointer)<TpvPtrUInt(OutputPointer)) and (TpvPtrUInt(OutputPointer)<(TpvPtrUInt(CopyFromPointer)+TpvPtrUInt(Len))) then begin

     // Overlapping

     while Len>0 do begin
      OutputPointer^:=CopyFromPointer^;
      inc(OutputPointer);
      inc(CopyFromPointer);
      dec(Len);
     end;

    end else begin

     // Non-overlapping

     if Len>SizeOf(TBlock8) then begin

      while Len>=SizeOf(TBlock64) do begin
       PBlock64(pointer(OutputPointer))^:=PBlock64(pointer(CopyFromPointer))^;
       inc(OutputPointer,SizeOf(TBlock64));
       inc(CopyFromPointer,SizeOf(TBlock64));
       dec(Len,SizeOf(TBlock64));
      end;

      while Len>=SizeOf(TBlock32) do begin
       PBlock32(pointer(OutputPointer))^:=PBlock32(pointer(CopyFromPointer))^;
       inc(OutputPointer,SizeOf(TBlock32));
       inc(CopyFromPointer,SizeOf(TBlock32));
       dec(Len,SizeOf(TBlock32));
      end;

      while Len>=SizeOf(TBlock16) do begin
       PBlock16(pointer(OutputPointer))^:=PBlock16(pointer(CopyFromPointer))^;
       inc(OutputPointer,SizeOf(TBlock16));
       inc(CopyFromPointer,SizeOf(TBlock16));
       dec(Len,SizeOf(TBlock16));
      end;

      while Len>=SizeOf(TBlock8) do begin
       PBlock8(pointer(OutputPointer))^:=PBlock8(pointer(CopyFromPointer))^;
       inc(OutputPointer,SizeOf(TBlock8));
       inc(CopyFromPointer,SizeOf(TBlock8));
       dec(Len,SizeOf(TBlock8));
      end;

     end;

     case Len of

      0:begin

       // Do nothing in this case

      end;

      1:begin

       PBlock1(pointer(OutputPointer))^:=PBlock1(pointer(CopyFromPointer))^;
       inc(OutputPointer,SizeOf(TBlock1));

      end;

      2:begin

       PBlock2(pointer(OutputPointer))^:=PBlock2(pointer(CopyFromPointer))^;
       inc(OutputPointer,SizeOf(TBlock2));

      end;

      3:begin

       PBlock3(pointer(OutputPointer))^:=PBlock3(pointer(CopyFromPointer))^;
       inc(OutputPointer,SizeOf(TBlock3));

      end;

      4:begin

       PBlock4(pointer(OutputPointer))^:=PBlock4(pointer(CopyFromPointer))^;
       inc(OutputPointer,SizeOf(TBlock4));

      end;

      5:begin

       PBlock5(pointer(OutputPointer))^:=PBlock5(pointer(CopyFromPointer))^;
       inc(OutputPointer,SizeOf(TBlock5));

      end;

      6:begin

       PBlock6(pointer(OutputPointer))^:=PBlock6(pointer(CopyFromPointer))^;
       inc(OutputPointer,SizeOf(TBlock6));

      end;

      7:begin

       PBlock7(pointer(OutputPointer))^:=PBlock7(pointer(CopyFromPointer))^;
       inc(OutputPointer,SizeOf(TBlock7));

      end;

      8:begin

       PBlock8(pointer(OutputPointer))^:=PBlock8(pointer(CopyFromPointer))^;
       inc(OutputPointer,SizeOf(TBlock8));

      end;

      else begin

       Assert(false);

      end;

     end;

    end;

   end;

  end else begin

   if (TpvPtrUInt(InputPointer)>=TpvPtrUInt(InputEnd)) or not OK then begin
    result:=false;
    break;
   end;

   OutputPointer^:=InputPointer^;
   inc(OutputPointer);
   inc(InputPointer);

  end;

 end;

 OutputSize:=TpvPtrUInt(TpvPtrUInt(OutputPointer)-TpvPtrUInt(aDestData));

 if (not aWithSize) and (aOutputSize<0) then begin
  aDestLen:=OutputSize;
 end;

 if not (result and (aDestLen=OutputSize)) then begin
  result:=false;
  aDestLen:=0;
  if Allocated then begin
   FreeMem(aDestData);
   aDestData:=nil;
  end;
 end;

end;

initialization
end.
